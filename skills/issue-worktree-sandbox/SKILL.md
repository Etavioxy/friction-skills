---
name: issue-worktree-sandbox
description: 创建候选 worktree，在其中处理、验证并关闭当前绑定 Issue。触发词：候选修复、issue worktree、sandbox 修复、候选分支。
---

# Issue Worktree Sandbox

在候选 worktree 中让处理 agent 完成当前绑定 Issue 的候选处理。

## 快速流程

```text
创建候选 worktree，并保证主分支不存在此 Issue
→ 在候选 worktree 中单独提交绑定 Issue
→ 创建并 append Issue draft
→ 调查、尝试绕过、候选修复与验证
→ 多次交叉验证
→ 调用 issue-lifecycle 完成 agent review，并将候选版本的绑定 Issue 标为 fixed
```

## 可修改范围

候选 worktree 中处理当前绑定 Issue 所必需的项目文件，包括代码、配置、测试、项目脚本、绑定 Issue 与对应 Issue draft。

候选 worktree 中已有的无关未提交改动不得整理、提交或删除。

## 影响半径

影响半径以绑定 Issue 的问题边界及其明确影响为上限。除候选 worktree 内的项目文件与运行行为外，因项目性质和问题需要，候选处理可能影响项目配置、缓存、服务进程，以及注册表、环境变量、共享资源等系统级状态。每项实际影响都必须依据项目文档与实际环境确认；未确认属于该 Issue 影响范围的状态、或仅为顺手优化而扩大的模块与行为，不得改变。

## 执行步骤

### 1. 建立候选 worktree

从原工作区当前分支的 `HEAD` 创建：

```text
candidate-fix/issue-<N>-<short-slug>
```

路径：`.claude/worktrees/` 已被项目 .gitignore 忽略，或仓库有 .gitignore 补一行 → 仓库内 `.claude/worktrees/`，并提交 .gitignore；否则（无 ignore）→ `~/.claude/candidate-fix-worktrees/<project_name>/issue-<N>-<short-slug>/`。

绑定 Issue 未提交时，复制 `issues.md` 到候选 worktree，再在原工作区 restore `issues.md`。绑定 Issue 已提交时，无需复制或 restore。保证主分支不存在此 Issue。

### 2. 固化绑定 Issue

绑定 Issue 未提交时，在候选 worktree 中将其作为 `issues.md` 的独占提交。绑定 Issue 已提交时，不重复登记或提交。

`issues.md` 的任何变更始终独占一次提交。

### 3. 创建 Issue draft

创建：

```text
drafts/issue-<N>-<short-slug>.md
```

先 append 对绑定 Issue 的初始理解。之后只 append，不删除或改写既有记录。

Issue draft 完整记录候选处理的初始理解、可修改范围、影响半径、调查发现、方案与取舍、绕过尝试、候选修复关键决定、验证证据、失败与回退、agent review 后修正、候选结论及仍无法满足的部分。用户纠正、主 agent 纠正，以及独立问题的关联与处理/不处理理由也必须记录。

阶段总结必须覆盖上述内容出现、被修正、扩展、推翻或得到新证据的过程；按实际过程 append 到 Issue draft，不删除或改写既有记录。

Issue draft 可随候选代码提交，或独立随时提交，不要求独占提交。

### 4. 候选处理与验证

依据绑定 Issue、项目文档与实际环境确认范围和影响，在确认范围内调查、尝试绕过、候选修复与验证；它们不要求固定线性顺序。

进行候选修复和对代码进行修改时，保持原子提交。

每次提交都应进行阶段总结，汇总本阶段新确认、修正、扩展、推翻的内容及其证据，并完整 append 到 Issue draft。

按绑定 Issue 选择行为复现、回归范围、实现对照、自动化测试、工具验证与观测、环境覆盖等方向交叉验证。

- 自动化测试：先查当前项目已有测试，按其模式补充单元测试、集成测试或模拟测试。
- 工具验证与观测：使用项目已有工具、脚本或适配工具取得可复查证据，例如 curl、Chrome DevTools、已有 scripts。
- 不自行引入新测试框架、依赖或安装新工具。

关键验证失败时，将失败证据 append 到 Issue draft，回到候选处理。

候选处理中发现的问题若是绑定 Issue 的必经依赖，纳入当前处理，不新建 Issue，并在 draft 说明理由。

独立发现或需 reopen 的问题，立即从主 worktree 当前分支 HEAD 建立：

```text
from-candidate-fix-<N>/issue-<M>-<short-slug>
```

的登记专用 sparse worktree。仅登记/reopen Issue 并提交；不修复、不创建 Issue draft，保留该 sparse worktree 与分支。在当前 Issue draft append 发现、关联与未处理原因。

### 5. 关闭候选 Issue

候选处理与交叉验证完成后，请 invoke [[issue-lifecycle]] 的关闭流程。agent review 发现问题时，将证据 append 到 Issue draft，回到候选处理。review 通过后，由 `issue-lifecycle` 确认 Issue、Issue draft、修复变更与验证证据一致，再将候选版本的绑定 Issue 标为 `fixed` 并提交。

## 关键约束

- 只处理当前绑定 Issue；候选版本的 `fixed` 不代表主路径已采纳。
- 采纳候选分支到主分支（`candidate-fix/*` → 主分支）时用 `git merge --no-ff`——保留候选提交边界为 merge commit，便于追溯；不使用 fast-forward。
- 原工作区不在候选处理的可修改范围中；仅移除本次未提交的绑定 Issue，以保证主分支不存在它。
- 具体 Git 操作、项目进程与外部状态操作按当前项目文档、相关 Skill、registry 边界和实际环境确定。
