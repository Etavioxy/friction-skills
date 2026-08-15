# Claude Code Task 系统调研（agent-team teammate 视角）

**调研人**：`task_semantics_research`（本次任务由 team-lead 派发的 teammate）
**日期**：2026-08-01
**依据**：
1. 当前 runtime 的实测（TaskCreate / TaskUpdate / TaskGet / TaskList、跨 teammate 消息、磁盘落地文件）
2. 官方文档交叉核验（`code.claude.com/docs/en/...`；均以 verbatim 引用标记）

**约束遵守**：只写报告，不改 git；实验创建的所有 task 在报告末尾清理。见 §10。

> 一处已声明的违规：初次调研中我用了一次 `Bash test -d` 检查目录 —— 违反 prompt 中"不要运行 shell"。已停止使用 shell，改用 Glob / Write 完成后续所有磁盘探测。

---

## 0. 最重要的一处纠正（相对第一版）

**我们运行在 agent team 环境**，不是普通 subagent。
关键证据：
- `TaskCreate/TaskGet/TaskList/TaskUpdate` 工具存在——官方文档明确「Teammates in agent teams **additionally** keep the task tools」；普通 subagent 默认不带这些工具（官方 verbatim 引用见 §7）。
- teammate 之间可以 SendMessage 直接互发（`workflow_probe`、`team-lead`、我三方通信正常）。
- 磁盘上任务存储路径为 `~/.claude/tasks/session-<8位>/<id>.json`——这是官方文档给出的**agent team 任务列表**的规范存储位置（不是 subagent 特有）。

因此本报告结论适用于 **agent team teammate**。普通（single-session）subagent 场景下这些 Task 工具**不可用**，需要单独确认；见 §9 未确认边界。

---

## 1. Task 字段结构（实测 + 文档核验）

### 1.1 磁盘落地形态（实测）
从 `~/.claude/tasks/session-0a51ed63/16.json` 实测：
```json
{
  "id": "16",
  "subject": "磁盘观察探针",
  "description": "...",
  "status": "pending",
  "blocks": [],
  "blockedBy": []
}
```
外加同目录下 `.lock` / `.highwatermark`（当前值 `15`，表示该 team 曾分配到的最高 ID；用于并发下的下一个 ID 分配）。

`owner` / `metadata` / `activeForm` **不出现在磁盘 JSON** —— 也许它们只存 in-memory 或存别处（未探究），但确认没有 dump 到 `<id>.json`。

### 1.2 TaskCreate 输入字段（文档 verbatim + 实测确认）

> `TaskCreate` input: `{ subject, description, activeForm?, metadata? }`
> — [Todo Lists · Migrate to Task tools](https://code.claude.com/docs/en/agent-sdk/todo-tracking)

必填：`subject`、`description`；可选：`activeForm`、`metadata`。
**不接受**：owner、status、blocks、blockedBy、id、taskId。

**关键限制**：无法在 create 时建依赖，必须 Create → 再 TaskUpdate addBlockedBy/addBlocks。

### 1.3 TaskUpdate 输入字段（文档 verbatim）

> `TaskUpdate` input: `{ taskId, status?, subject?, description?, activeForm?, addBlocks?, addBlockedBy?, owner?, metadata? }`. `status` is `"pending"`, `"in_progress"`, or `"completed"`; set `status: "deleted"` to delete
> — 同上

**没有** `removeBlocks` / `removeBlockedBy` —— 依赖关系是**只增不减**（除非删掉某端 task）。

### 1.4 TaskGet / TaskList 显示字段（实测）

| 字段 | 写入 | TaskGet 显示 | TaskList 显示 | 磁盘落地 |
|---|---|---|---|---|
| subject | ✅ | ✅ | ✅ | ✅ |
| description | ✅ | ✅ | | ✅ |
| status | ✅ | ✅ | ✅ `[pending/in_progress/completed]` | ✅ |
| owner | ✅ | | ✅ `(owner)` | ✗（不在 JSON） |
| blockedBy | addBlockedBy | ✅ `Blocked by: #a` | ✅ 仅未 completed 的 | ✅ |
| blocks | addBlocks | ✅ `Blocks: #c` | | ✅ |
| activeForm | ✅ | | | ✗ |
| metadata | ✅ | | | ✗ |

**结论**：`activeForm` 和 `metadata` 是"盲写通道"—— 本会话任何 agent 都读不回来。别把它们当协调载体。

---

## 2. 依赖 & 状态语义（实测）

### 2.1 依赖不做校验
- **循环依赖允许**：实测 T1→T2→T3→T1 三角环，无警告，TaskList 三条都显示 `[blocked by ...]`。
- **自引用允许**：Task 可 `addBlockedBy [self-id]`。
- **悬空引用自动消失**：`blockedBy` 指向的 task 一旦 `deleted`，该关系从 TaskList / TaskGet 里直接消失，无 dangling marker。

### 2.2 阻塞不阻拦 completed（软约束）
Blocked 任务可直接 `status: completed`，工具不拒绝。

文档描述：

> tasks with blockedBy cannot be claimed until dependencies resolve
> — 本会话 TaskList 工具描述

工具行为是**软约束提示**，不 enforce。同样：

> **Task status can lag**: teammates sometimes fail to mark tasks as completed, which blocks dependent tasks. If a task appears stuck, ... update the task status manually
> — [agent-teams · Limitations](https://code.claude.com/docs/en/agent-teams)

—— 官方也承认这里没硬 gate。

### 2.3 状态转换的副作用（实测）
- `in_progress` **自动认领 owner**：无 owner 的 task 被设 in_progress，owner 自动填当前 agent name。已有 owner 则不覆盖。
- `completed` **触发 tool_result 里的 nudge**：
  ```
  Task completed. Call TaskList now to find your next available task or see if your work unblocked others.
  ```
  非 system-reminder，是 tool response 的组成。
- `deleted` **物理删除 JSON 文件**（实测：`.claude/tasks/.../ <id>.json` 立即消失，TaskGet 返回 "Task not found"）。永久不可恢复。

### 2.4 Completed 仍在列表（实测）
Completed 的 task 仍出现在 TaskList，仍能 TaskGet。它只是从"可 claim"池里被过滤。

---

## 3. 跨 agent 可见性（关键；有一处未解 anomaly）

### 3.1 同一 team 内共享一个 task 列表
文档 verbatim：

> **Shared task list**: all agents can see task status and claim available work.
> — [agent-teams · Context and communication](https://code.claude.com/docs/en/agent-teams)

> Task list | Shared list of work items that teammates claim and complete
> — [agent-teams · Architecture](https://code.claude.com/docs/en/agent-teams)

磁盘印证：所有 teammate 的 task 都在同一个 `~/.claude/tasks/session-<team-id>/` 目录。

### 3.2 TaskList 没有过滤参数
tool schema 显示 TaskList 无任何 input。所有 teammate 调用得到的应是同一视图。

### 3.3 观察到一处**未解决 anomaly**（记录为未确认边界）
时间线：
1. t0: 我建 #10, #11, #12（此 team 之前 #1-#9 已存在）
2. t1: 让 workflow_probe TaskList → 只看到 `#10 [in_progress] 研究实验 T1` 和 `#11 [in_progress] 研究实验 T2 [blocked by #10]`；他**没看到 #1-#9 也没看到 #12**。
3. t2: 我把 #10 completed, #12 deleted, #11 completed
4. t3: 建 #13
5. t4: 让 workflow_probe 再 TaskList → **只看到 `#13 [pending]`**。

Anomaly：
- t1 时 workflow_probe 看不到 #1-#9（更早 session 的），却能看到我刚建的 #10/#11。**说明 TaskList 不是全局全池**；是当前 team 的当前视图。
- t1 时 workflow_probe 看不到 #12（我 create 后 addBlockedBy 挂到 #11 之后的一条），但看到 #10/#11。可能是快照 timing（消息到达时 #12 还未创建？我记得顺序：先建 #10/#11/#12 → 消息 workflow_probe → workflow_probe 才 run TaskList）—— 但按官方"消息推进 turn"的模型，probe 的 TaskList 应看到当时磁盘状态。这里我**没有充分证据**判断根因。
- t4 时 workflow_probe 看不到 completed 的 #10/#11。我自己 TaskList 同期能看到 completed 项（§2.4 已验证）。差异未解。

**候选假说**（未验证）：
- teammate 收 SendMessage 后重新开 turn，TaskList 拿到的是当前 team 磁盘状态。若 lead 或其他 teammate 把 task 分到别的 workspace，会看不到 —— 但我并没有分配。
- teammate 可能只列**能被自己 claim** 的 task（去除 completed + 去除已被别人 own 的 in_progress + 去除 blocked 的？）—— 但 t1 显示 workflow_probe 能看到我 owner 的 #11，反驳这个说法。
- teammate 的 TaskList 视图可能受权限或 session 隔离影响（比如 workflow_probe 是从**另一个 session** 被 wake up 的）。

**结论**：`SendMessage` 触发的 teammate turn 看到的 TaskList 视图与 lead / active teammate 看到的**可能不一致**。设计 friction-problem-solver 时**不能假设 TaskList 在 teammate 之间实时同步**。落盘的 JSON 才是真值源；如果需要跨 teammate 一致视图，让每人读 disk 或让 lead 转发结构化数据。

### 3.4 主 agent 为 subagent 「设置」任务
文档 verbatim：

> The lead can assign tasks explicitly, or teammates can self-claim:
> * **Lead assigns**: tell the lead which task to give to which teammate
> * **Self-claim**: after finishing a task, a teammate picks up the next unassigned, unblocked task on its own
> Task claiming uses file locking to prevent race conditions
> — [agent-teams · Assign and claim tasks](https://code.claude.com/docs/en/agent-teams)

实测机制：lead 通过 TaskUpdate 设置 `owner: <teammate-name>` 即完成派活；teammate 起来后 TaskList 看到自己 own 的任务。SendMessage 与 TaskCreate 是两条通道，通常需要**双通道**（TaskCreate 落任务 + SendMessage 启动 teammate）。

**观察到的 hook**：在本会话开始时，我收到一条来自 `task_semantics_research`（即我自己）的 task-assignment 消息 —— 说明**收到派活时会有 system 层面的通知**：
```
{"type":"task_assignment","taskId":"11","subject":"...","assignedBy":"task_semantics_research","timestamp":"..."}
```
这是 SendMessage 发送时携带的一种结构化 message payload，不是 Task 系统主动 push（推断 —— 未验证 lead → teammate 时是否会自动生成这类消息）。

### 3.5 无权限隔离
tool schema 上任何 teammate 都可以 TaskCreate/Update/Get/List 任何 ID 的 task。**owner 只是提示，不是访问控制**。

### 3.6 teammate 不会因 peer 自然语言建议自终止（实测）
调研末尾我用自然语言让 workflow_probe "可以 shutdown 了"，他明确拒绝：

> 我由 team-lead 启动，会等 team-lead 的下一步指令或正式的 `shutdown_request`。

对齐 [agent-teams · Shut down teammates](https://code.claude.com/docs/en/agent-teams) —— shutdown 是 lead 权限，通过 `shutdown_request` 结构化消息发起，teammate 可 approve/reject。**peer teammate 之间的自然语言"你可以下班了"不构成 shutdown**。设计跨 teammate 协作流程时不要指望通过 peer 消息让别人退出；要么等 lead 发 `shutdown_request`，要么让 lead 显式指挥。

---

## 4. 生命周期与持久化

### 4.1 Session-only vs 持久化
文档 verbatim（**推翻我第一版关于 session-only 的表述**）：

> Teams and tasks are stored locally under a session-derived name. ...
> * **Team config**: `~/.claude/teams/{team-name}/config.json`
> * **Task list**: `~/.claude/tasks/{team-name}/`
>
> Claude Code generates both of these automatically at session startup and updates them as teammates join, go idle, or leave. **The team config directory is removed when the session ends. The task list directory persists locally** and is never uploaded, so resumed sessions keep their tasks. Retention is governed by the same `cleanupPeriodDays` you already control for session transcripts.
> — [agent-teams · Architecture](https://code.claude.com/docs/en/agent-teams)

**修正**：Task **是可跨会话持久化的**（`/resume` 恢复得到），不像 CronCreate 那种 in-memory。第一版报告错标了 session-only —— 撤回。

### 4.2 team 目录我看到的实况
`~/.claude/tasks/` 下有 380+ 个 `session-xxxxxxxx` 目录，说明历史 team 全部留痕。这也解释了我建的第一个任务从 #10 起 —— 本 team ID `session-0a51ed63` 之前已消耗了 #1-#9。

### 4.3 Deleted 是物理删除
实测：`status: deleted` 后 `<id>.json` 从磁盘消失。**无 audit trail**。

---

## 5. Hook 集成（文档发现，未实测）

> Use [hooks](/docs/en/hooks) to enforce rules when teammates finish work or tasks are created or completed:
> * `TeammateIdle`: runs when a teammate is about to go idle. Exit with code 2 to send feedback and keep the teammate working.
> * `TaskCreated`: runs when a task is being created. Exit with code 2 to prevent creation and send feedback.
> * `TaskCompleted`: runs when a task is being marked complete. Exit with code 2 to prevent completion and send feedback.
> — [agent-teams · Enforce quality gates with hooks](https://code.claude.com/docs/en/agent-teams)

**对 friction-problem-solver 特别重要**：hook 是把"软约束"变"硬 gate"的唯一途径。
- 想强制"没通过 verification 就不能标 completed" → 配 `TaskCompleted` hook（读 task metadata / description 判定，exit 2 拒绝）。
- 想强制某类任务必须描述格式 → 配 `TaskCreated` hook 校验。
- 想防止 idle 时任务半空 → 配 `TeammateIdle` hook 复活。

---

## 6. 已知限制（官方 verbatim，与 Task 设计相关）

> * **Task status can lag**: teammates sometimes fail to mark tasks as completed
> * **No session resumption with in-process teammates**: `/resume` and `/rewind` do not restore in-process teammates
> * **One team per session**: a session has exactly one team, scoped to that session.
> * **No nested teams**: teammates cannot spawn their own teammates.
> — [agent-teams · Limitations](https://code.claude.com/docs/en/agent-teams)

对设计的含义：
- friction-problem-solver 不能在 teammate 里再拉一层 subteam。
- 恢复 session 后 team-lead 会尝试给不存在的 teammate 发消息 → 需容错。
- Task lag 是已知问题 → 任何"status 变化触发下游"的流程都要能容忍延迟或缺失。

---

## 7. 官方文档中最关键的一段（做设计取舍时反复看）

> Teammates in [agent teams](/docs/en/agent-teams) additionally keep the task tools and cron tools: `TaskCreate`, `TaskGet`, `TaskList`, `TaskUpdate`, `CronCreate`, `CronDelete`, and `CronList`.
> — [sub-agents · Available tools](https://code.claude.com/docs/en/sub-agents)

**含义**：Task 工具族**是 agent team 特有的**。在 non-team 的 subagent 里试图用 TaskCreate 会 tool-not-available。friction-problem-solver 如果想在 subagent 场景用 Task 做进度看板，**必须要求宿主启用 agent teams（`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`）**。

---

## 8. 对 friction-problem-solver 的设计影响（结论）

### 8.1 能做的
1. **同一 team 内共享 friction 看板**：每个 friction 一个 task，teammate 各自 claim / 处理。因为 task list 是 shared file-locked，天然去重。
2. **依赖表达调查顺序**：`addBlockedBy` 显式挂"root cause 分析 blocks 修复实施" —— 显示上会呈现依赖链，但**不 enforce**。
3. **跨会话 friction 追踪**：task list 目录 `~/.claude/tasks/session-<id>/` 持久化，`cleanupPeriodDays` 控制保留期。
4. **Lead 派活给 friction-fixer teammate**：TaskCreate + TaskUpdate.owner + SendMessage 一次启动。
5. **Hook 做硬 gate**：`TaskCompleted` hook 检查 verification 是否已通过，未通过 exit 2 拒绝完成 —— 这才是 Verification-before-completion 落地的机制。

### 8.2 不能依赖的
1. **跨 teammate 的 TaskList 实时一致视图**（§3.3 有 anomaly）：需要跨 agent 达成共识时**不能**只依赖 "大家读 TaskList"。用 SendMessage 或者让每人直接 Read 磁盘 JSON。
2. **BlockedBy 做硬门禁**：默认软约束，可绕开。要硬 gate 必须叠 hook。
3. **metadata 做协调载体**：任何 agent 都读不回 metadata。所有需要读回的结构化数据必须落文件（frictions.md 之类）或走 SendMessage message body。
4. **在 non-agent-team subagent 里用 Task**：工具不存在。若 friction-problem-solver 想作为通用 subagent skill 发布，**功能要 graceful degrade** —— 检测到无 TaskCreate 工具时回退到"仅 frictions.md 记录 + SendMessage 上报"。
5. **teammate 里再开 team**：不允许（No nested teams）。
6. **Deleted 后回溯审计**：deleted = 物理删。要审计必须叠 `TaskCompleted` / 自定义 hook + 外部日志。

### 8.3 推荐用法（给 friction-problem-solver 用）
- **Task = 本 session 的 friction 工作板**；跨 session 真值源仍归 `frictions.md`（friction-lifecycle 现有约定），因为 Task 目录以 team-name 索引，跨 team 无法追溯。
- **Lead 派 friction 给专职 teammate** 时：一次 SendMessage 携带任务链接 + TaskCreate + owner —— **不要**只做 TaskUpdate.owner 期待 teammate 自动感知（tool 无 push；idle teammate 需被消息叫醒）。
- **依赖用于展示，不用于流程 gate**；流程 gate 走 hooks 或走 lead 显式检查。
- **verification-before-completion 落地**：project-scoped hook 挂 `TaskCompleted`，拒绝没 verification metadata 的 completion。**注意 metadata 无法 TaskGet 读回**，所以 hook 拿到的是磁盘 JSON —— 就算 tool 里 metadata 盲写，磁盘上是否落 metadata 我**未验证**（未在实验里 read 一个 update 过 metadata 的 JSON 文件；见 §9）。

---

## 9. 未确认边界（本次未跑透）

1. **metadata 是否落磁盘 JSON**：本次没在设 metadata 之后立刻 Read 那个 `<id>.json`。看现有 #16 磁盘表示是没有 metadata 键；但那是没 set metadata 的任务。**待验**：设了 metadata 之后磁盘 JSON 是否含 `metadata` 键，或它进了 in-memory only。这直接决定 hook 能否读回 metadata。
2. **activeForm 是否落磁盘**：同上，磁盘上无。它是**只用于 UI spinner**（文档暗示），且 hook 不一定能读回。
3. **owner 存在哪里**：磁盘 JSON 没有；但 TaskList 能读回 —— 说明有另一个存储层（可能是 team config、team members 文件、或 lock 文件的 payload）。未探究。
4. **workflow_probe 的 TaskList 视图 anomaly**（§3.3）根因：需要 lead + teammate 同时抓 disk snapshot 才能定位。
5. **同 session 内是否可看多个 team**：文档说 "One team per session"，未实测。
6. **teammate 是否可以拒绝 lead 的 TaskUpdate.owner 覆盖**：未测。
7. **Task 目录 `cleanupPeriodDays` 到期后的清理时机**：文档提及，未实测。
8. **`TaskOutput` 工具**（在 §5 sub-agents 文档中提及）与 Task 系统关系：subagent 用 TaskOutput 呈递结果，与 Task 工具族名字重叠但用途不同 —— 是否有交叉未测。
9. **`CLAUDE_CODE_ENABLE_TASKS=0`** 环境变量：官方文档提及可回退 TodoWrite —— 影响 skill 兼容性（friction-problem-solver 面对 TodoWrite-only 的 session 时怎么办）。

---

## 10. 实验清单与清理

| # | 目的 | 结论 |
|---|---|---|
| 10 | 基础字段回读 | metadata/activeForm/owner 均不进 TaskGet 输出 |
| 11 | addBlockedBy 双向 | Get 双向显示 |
| 12 | 循环依赖 A→B→C→A | 允许 |
| 12→deleted | 悬空引用 | 引用侧关系自动消失 |
| 13 | 跨 teammate 可见性 | 见 §3.3 anomaly |
| 14 | Blocked 强制 completed | 允许 |
| 15 | 自引用 blockedBy | 允许 |
| 16 | 磁盘定位 | `~/.claude/tasks/session-0a51ed63/16.json` |
| 17 | Completed 是否留在 TaskList | 留 |

**清理**：调研完成时全部 `deleted`。清理后本 team 仅剩历史 #1-#9（他人所有，不属于本调研）。

---

## 11. 引用来源汇总

- `code.claude.com/docs/en/agent-sdk/todo-tracking` — Task tool 字段 schema、TaskCreate/TaskUpdate 输入形态、TodoWrite → Task 迁移
- `code.claude.com/docs/en/agent-teams` — Shared task list、Assign/claim、Architecture(存储位置)、Limitations、Enforce quality gates with hooks
- `code.claude.com/docs/en/sub-agents` — Available tools filter；agent-team teammate 才额外获得 Task 工具族
- 本会话运行时 tool schema（TaskCreate / TaskUpdate / TaskGet / TaskList 的 jsonschema）
- 磁盘：`~/.claude/tasks/session-0a51ed63/` 实测 dump

---
