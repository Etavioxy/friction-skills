# Friction Lifecycle — 讨论过程

## 2026-07-31: 命名与定义

**命名**：friction-lifecycle，和 existing `issue-lifecycle` 对偶。

**定义**：Friction 是上游保证和实际体验之间的差距。我的操作错误、不熟悉工具不算 friction。上游文档/代码明确支持但实际不符才算。

## Tags 演变

第一版 tag 是三维度（根因 × 载体 × 落地），太琐碎。

第二版缩到一维（修复点在哪）：`skill` `skill-gap` `upstream` `undecided`。

用户指出：tag 应该是**状态**，不是载体。状态不互斥，可以多个同时标。需要加 `resolved`。`upstream` 需要区分：仅开了 issue、直接修复了、还是 upstream 纠正了。

## 格式

`## 标题 — tag1 tag2 tag3`（tags 是状态，不互斥）。

段落按时间线走，**数量不限**（不写死 7 段）。应该覆盖：触发场景、错误尝试、用户纠正、调查过程、结论、修复、最终状态。

## 位置

项目 frictions.md 放在 skill 的 drafts 下。比如 nap-bridge-cli 的项目 friction 放在 `nap-bridge-cli/drafts/<project>/frictions.md`。

## 待定

- tags 的精确集合和每个 tag 的条件
- user-goals.md

## 2026-07-31: 后续 Grill

**先核对现状**：继续 grill 前重新读了 `SKILL.md`。此前口头收敛的结论没有实际落到当前文件；我还错误地把一次提交说成已经包含了它们。现有定义仍把操作错误排除在 friction 外，tag 表仍有已否定的 `skill`，格式仍预设了段落占位，且把记录位置写死为本 skill 的 drafts。这说明讨论中的结论、已提交内容和未提交修改必须分开核对，不能互相替代。

**Friction 定义**：最初把 friction 说成上游保证不符，并把 agent 的操作错误排除在外。用户指出操作错误同样可能暴露系统性卡点：工具链没有阻止错误、没有恢复机制，或可见信息无法让主 agent 稳定走到正确路径。定义收敛为任务循环中需要停下调查才能继续的系统性卡点；它不按责任方划分。

**记录格式**：曾试图把正文规定为触发、错误尝试、用户纠正、调查、结论等固定时间线段落。用户指出这会把真实排查过程压成模板。最终保留标题格式 `## <标题> — <tags>`，正文按实际排查顺序写多个自由段落，不编号、不限定数量。临时绕过单独成段，记录其做法、依据和仍未解决的部分。

**Tag 的性质**：最初把 tag 当作根因或载体分类。用户要求它们只表达当前状态。于是删除只表示类别的 `skill`，把 skill 与 upstream 都改成可迁移的状态线。状态变化更新原条目的标题；历史与理由留在正文和 Git 中，而不是保留旧 tag。

**未定态**：`undecided` 不是与其他 tag 并行的主状态，而是尚未确定落地路径时的唯一状态。它只能单独出现；一旦确定走 skill 或 issue 路径，就移除它。若调查后不需要任何落地，直接转为 `resolved`。

**Skill 状态线**：确认 `skill-gap → skill-fixed`。`skill-gap` 表示需补齐主 agent 可见的 skill 信息；`skill-fixed` 表示该缺口已被实际补齐。若后续证实此路径不适用，可移除对应 tag；若补齐失效，回到 `skill-gap`。没有为 skill 增加 candidate 状态：skill 的补充通常是对已确认项目实际的概括，是否需要 worktree 迭代不能预设。

**Upstream 状态线**：最初只有 `upstream-issued → upstream-fixed`。讨论候选 worktree 后发现，候选版本已修复、但尚未采纳主路径，是必须表达的独立进展，因此增加 `upstream-candidate-fixed`：`upstream-issued → upstream-candidate-fixed → upstream-fixed`。候选分支中的 issue 仍只用既有 `open` / `fixed`；候选性由分支、worktree 和 friction tag 表达，不给 issue 新增状态。

**关闭条件**：`resolved` 可与 `skill-fixed`、`upstream-fixed` 共存，但不能与 `skill-gap`、`upstream-issued` 或 `upstream-candidate-fixed` 共存。它不是任一路修复后的自动结果；所有已选择路径完成、且没有后续调查、修复或跟踪时才添加。若出现新的待处置路径，则移除它。

**条件表**：tag 需要的是两列的简短条件与切换，而不是长篇定义。收敛的逻辑为：`undecided` 在确认 friction 时出现，确定路径时移除；`skill-gap` 在确认 skill 缺口时出现，补齐时换成 `skill-fixed`；`upstream-issued` 只在候选 issue worktree 实际创建、issue 已登记并提交后出现；候选修复验证后换成 `upstream-candidate-fixed`；主路径采纳后才换成 `upstream-fixed`；没有未完成路径时添加 `resolved`。Tags 按合法组合清单中的顺序书写，无需另设冗长排序规则。

**合法组合**：用户要求组合单独列出且占用很少。它分成未定、处理中、已关闭三组。`undecided` 单独为第一组；处理中由 `skill-gap` / `skill-fixed` 与 `upstream-issued` / `upstream-candidate-fixed` / `upstream-fixed` 的仍未关闭组合构成；第三组为 `resolved`、`resolved skill-fixed`、`resolved upstream-fixed`、`resolved skill-fixed upstream-fixed`。该清单既约束共存关系，也固定标题中 tag 的书写顺序。

**Git 记录**：同一 friction 不另开重复条目。新增条目、更新 tag 或补充正文都立即单独提交，由 Git 记录演进；不在正文中人为制造“每次状态变化”的固定模板。这一做法来自 `issue-lifecycle`：同一编号保留，状态更新在标题，原描述不删除，提交历史承担版本追溯。

**Issue 与 gap**：讨论中一度按“问题属于哪个仓库”区分 skill-gap 与 issue，用户指出这是错误的。区别应从主 agent 所依赖的层次由小见大判断：项目实际是确定的，Skill 对它的概括不足是 gap；工具定义或任务明确需要的能力是确定的，工具代码实现错误或不足是 issue。主 agent 没有使用已有、可见且正确的 Skill，不是 skill-gap。

**Skill 的可见范围**：按 `skill-authoring`，Skill 是 `SKILL.md` 与从其链接可达的文档；未链接的 drafts、notes 不是主 agent 可随意读取并依赖的信息。实际存在可靠路径但可见 Skill 没有概括它，是 `skill-gap`。工具说明明确承诺而代码未实现，是 issue；工具未承诺某能力、但任务明确需要且实现缺少它，也仍是 issue。一个调查可同时确认工具问题和已验证绕过未被 Skill 概括，因而同时进入 `skill-gap upstream-issued`。

**绕过与根因修复**：agent 不应因为发现 issue 就消极等待。它要持续调查、解释并尝试低风险、可逆且有文档依据的绕过，让当前任务尽可能继续；但不能直接修改主路径代码、skill 或支持项目来解决根因。遇到必须依赖未经证实假设、无文档依据操作、不可逆/高风险改动，或会掩盖/扩大 friction 的情况，应要求主 agent 停止。绕过不自动关闭 friction。

**主 agent 与 subagent**：friction 的发现、记录、tag 更新和主任务继续/停止只属于主 agent。`general-purpose` subagent 是 problem solver，不应被告知自己在处理“friction”，也不读写 `frictions.md`。主 agent 首轮只交给它一个具体问题、调查目标和不改主工作区的边界；subagent 先处理问题、解释原因、验证安全绕过。

**Issue 协商**：subagent 发现可能需要项目级跟踪时，不能一开始就把三份 skill 全读完。它先在自己的连续过程里完成问题分析；此时才读取 `issue-lifecycle` 的判据，形成拟议 issue、证据与范围，并向主 agent 询问。主 agent 与 subagent 对齐后，才进入登记与候选修复阶段。这里的“确认”是写 issue 的 agent 对证据和问题边界的确认，也允许用户参与；不是未调查即凭猜测登记。

**候选 worktree 的修正**：早期模型让权威主工作区先登记 issue，再从该提交创建 worktree。用户指出这会使 sandbox 试验预先污染主路径，而且候选调查发现新问题时会产生“是否还要改主分支”的矛盾。模型改为主路径完全不因候选试验而变动：确认 issue 后创建候选 worktree；在候选版本中登记、增补、修复和关闭绑定 issue；用户决定采纳时，主路径才变化。

**Issue-worktree sandbox**：候选修复环境以一个已对齐的 issue 为入口，绑定单一 Git 项目、单一主 issue、单一 `candidate-fix/issue-<N>-<short-slug>` 分支和一个隔离 worktree。它可用于工具项目，也可用于 skill 项目；issue 是记录机制，不是某一类仓库专属。候选 worktree 通常命名为 `issue-<N>-<short-slug>`，可修改绑定 issue 的调查增补和候选 `fixed` 状态，也可实现和验证候选修复；它不自动合并、采纳或删除。

**Worktree 路径**：曾建议一律放进 `<repo>/.claude/worktrees`，但这会要求每个项目都维护 `.gitignore`，简单 skill 仓库尤其不合理。收敛为路径推荐：项目已经忽略 `.claude/` 时可放 `<repo>/.claude/sandboxes/...`；否则放任意容量足够的仓库外 sandbox 根目录，例如用户目录、`D:` 或 `E:` 下的 `.claude/sandboxes`。不为 sandbox 专门改 `.gitignore`。sandbox 边界由 Git 项目、绑定 issue 和候选分支决定，不由路径决定。

**候选编号**：多个候选分支都不改主路径时，不能可靠地从主路径 `issues.md` 获得全局递增编号。曾提出隐藏 Git counter ref，但这是此前从未维护的新机制，复杂且不可见，已否定。又考虑派生 worktree 自然编号，但会把本来独立的 issue 绑进候选代码依赖和 merge 链，成本更高。最终接受兼容现有实践的建议编号：创建前搜索 `candidate-fix/issue-*` 分支，取当前最大编号加一；候选阶段允许重复；只有合并进入主路径后再处理实际冲突，例如 `#8-a`、`#8-b`。放弃的候选编号不回收。

**独立新问题**：候选 sandbox 发现独立新 issue 时，不在当前主 issue 的范围内顺手修复。它可以由后续独立候选分支处理，默认基于主路径当前提交，而不是发现它的候选分支，避免把发现关系误变成代码依赖。候选路径不自动清理；被拒绝或不再需要时，由用户决定保留或删除 worktree 与分支。

**Sandbox registry**：阅读 `sandbox-safety-registry` 的约束草稿后确认，registry 不安装或自动创建 sandbox；它为“工具在 sandbox 中的无害使用模式”登记工具名、无害行为与调用方式。issue-worktree sandbox 是新的流程 skill，registry 需为其实际使用的工具模式建立安全登记。它不能被模糊地描述成“允许任意 worktree 修复”。

**连续 task 与 goal 实验**：为了验证 subagent 能否承载渐进流程，实际派出一个 `general-purpose` agent。它在自己的会话中用 `TaskCreate`、`TaskUpdate`、`TaskList` 建立连续任务链，并完成了多轮无副作用实验。实验确认：subagent 可以在一次执行中创建、推进和完成整条 task 链；task 未完成不会阻止它回报或进入 idle；等待主 agent 决策时可保留当前 task 为 `in_progress`。

**Task 的边界**：主 agent 的 `TaskList` 看不到该 subagent 创建的 task，故 task list 不是跨 agent 的共享状态，也不能充当主 agent 对 subagent 的长期 goal 存储。subagent 自己可把目标写进 task description 并通过 `TaskGet` 回读，但这只在同一 agent 会话中成立。

**Goal 的边界**：没有系统级结构化 `goal` 字段。主 agent 通过初始 prompt 或 `SendMessage` 设定的目标，在同一个 subagent 的后续 task、工具调用和系统 skill 注入后仍可用；实际进行了两轮验证。新建 agent 不会继承该消息目标，因此换 agent 时主 agent 必须重新注入已确认事实、当前阶段与下一目标。这个实验为“同一 problem-solver subagent 使用连续 task 逐步推进，主 agent 在阶段门用消息给下一目标”提供了实际依据。

**四处落地**：讨论最终把修改分为四个职责明确的位置。`friction-lifecycle` 只保留主 agent 的记录、tags、gap/issue 判定和状态更新；`issue-lifecycle` 加入全局候选 issue 建议编号、允许重复、合并后处理冲突的规则；新的 problem-solver skill 给 subagent 定义 TaskCreate 连续过程、消息 goal 与渐进引入 issue/sandbox 的顺序；新的 issue-worktree sandbox skill 加上 `sandbox-safety-registry` 的工具模式登记，定义候选修复流程和安全边界。

## 原则与收获

**主 agent 的心智边界**：主 agent 必须保有对任务循环的全局视图，因此负责 friction、主任务是否继续和对子 agent 回报的解释；它不应同时承受 issue 编号、候选分支、worktree 路径、候选 `issues.md` 状态和实现细节。把这些交给同一 problem-solver subagent，不是简单分工，而是防止全局调度者被局部实施细节淹没。该原则由“四处落地”的职责划分直接实现。

**Subagent 的渐进认知**：subagent 的第一步只处理一个具体问题，不被告知 friction，也不预先读取 issue 或 sandbox 流程。只有它在调查中得到足以提出项目级跟踪的证据，才读取 `issue-lifecycle`；只有 issue 经与主 agent 对齐后，才读取 issue-worktree sandbox。这样每一阶段只引入解决下一问题所需的信息，避免 issue 预设调查结论，也避免候选修复在问题边界尚不清楚时提前发生。

**连续性不是假设**：TaskCreate 实验证明同一个 `general-purpose` subagent 可以维护连续 task 链，消息传入的 goal 在其会话内跨多轮仍然可见。因此“先分析、再提 issue、再进入 sandbox”可以由同一 problem solver 连续推进，而不要求主 agent 记住每个局部步骤。实验也证明 task list 不跨 agent 共享，所以全局记录仍必须留在主 agent 的 friction 条目和明确消息中；换 agent 必须重放上下文。这给出的是能力边界，而不是对不存在的 goal 机制的臆测。

**由小见大的判定**：gap 与 issue 的区分不能按仓库名称或谁犯错判断。项目实际可确定、Skill 的概括不够，是较近的信息抽象问题；工具定义或任务需要可确定、代码实现不对或不够，是较大的实现问题。这个模型既解释为什么“没有使用已存在正确 Skill”不是 gap，也解释为什么工具未承诺但确实缺少任务所需能力仍可登记 issue。它让 tag 指向可修复的层次，而非把所有失败混成文档问题或代码 bug。

**候选版本隔离**：主路径预先登记 issue 的方案被否定，因为它让尚未采纳的调查和试验改变权威版本。将登记、增补、修复和候选关闭都放进 worktree，使主路径始终反映已采纳事实，候选分支反映“在此版本中已验证”的事实。`upstream-candidate-fixed` 正是两种版本语义之间的桥梁；它避免把候选成功误报为主路径已解决。

**记录可追溯而不阻塞**：候选 issue 的建议编号来自现有候选分支，允许冲突并在合并后解决。它放弃了“候选阶段全局连续编号”的虚假保证，换取不引入隐藏 counter、不预写主路径、不把独立问题串成 merge 依赖。Git 分支、提交和最终冲突解决承担版本追溯；编号缺号或临时重复并不损害每个候选分支的可定位性。

**积极性与授权边界**：agent 不应因没有主路径修改权就停止。它可以调查、解释、登记候选 issue、增补证据、实现并验证隔离 worktree 中的候选修复，也应主动尝试有文档依据、低风险且可逆的绕过。限制只针对未经指导直接改变根因的权威版本、无依据操作和高风险动作。这样既保留 problem solver 的积极性，也不把候选结果伪装成已采纳解决。

**Registry 的作用**：worktree 只隔离版本文件，不能凭路径名称自动获得“安全”含义。registry 的价值是将具体工具模式及其无害边界写成可审查记录；sandbox skill 的价值是把这些模式组织成单 issue 的候选工作流。二者不能相互替代，也不能把 registry 误当作会安装环境或授予无限修复权限的系统。

**尚未落地**：以上是经过 grill 收敛的设计与实验结论，不等于四处 skill 已经修改。后续应逐项将它们写入相应 skill，并分别检查、提交；在用户确认前不把草稿中的未落地设计当作既有流程执行。

## 对原则的考量

| 原则 | 分阶段链路的结果 |
|------|------------------|
| 主 agent 心智负担小 | 主 agent 记录 friction、接收分析、与 subagent 对齐拟议 issue；不处理编号、分支、worktree、候选修复或验证细节。 |
| subagent 渐进推进 | subagent 先解决具体问题；发现可能需跟踪时才读 `issue-lifecycle`；issue 对齐后才读 sandbox skill。 |
| 执行稳定性 | 分析回报 → issue 对齐 → 候选 worktree → issue commit → 候选修复/验证 commit → 交付；同一 subagent 用 task chain 和消息 goal 连续推进，换 agent 时主 agent 重放上下文。 |
| 沙盒性 | 候选登记、修复、验证和候选关闭都在绑定 issue 的 worktree；主路径不因试验自动变化，用户决定是否采纳。 |
| 不过度约束 | 首轮委托只给具体问题与边界；不预设必须登记 issue 或开 sandbox。 |
| 不越权 | subagent 可主动调查、绕过和候选修复；不直接改主路径或自动采纳。 |

## 2026-07-31: 后续收敛

**Skill 发现的 junction 问题**：讨论“grep 搜不到 Skill 是否就是 skill-gap”时，检查了 `terminal-demo-recording`。它在 `skills/` 下是 NTFS junction；直接指定其路径可以 grep 到 `SKILL.md`，但从 `skills/` 根目录递归 grep `PowerSession` 没有命中。内置 Grep 不穿透 junction，使已安装 Skill 从正常发现流程中消失。故 grep 无结果只能说明当前搜索机制没有找到，不能单独证明 skill-gap；skills 组织与 discovery 工具的兼容性本身需要处理。

**提取 junction Skill**：检查 `skills-quiz-workspace` 后发现它有 `git-clover-workflow`、`skills-quiz`、`plan-analysis-matrix` 三个 Skill；前两个在 Claude skills 下已有普通独立仓库副本，只有 `plan-analysis-matrix` 是 junction。它与 workspace 中目录是同一份内容，不存在版本择优问题。将其移出 workspace，创建 Claude skills 下的独立 Git 仓库，并从 workspace 删除原文件。这样它进入正常的顶层 grep 覆盖范围，也符合每个 Skill 独立 Git 仓库的组织方式。

**Problem solver 名称**：新 subagent skill 定名为 `friction-problem-solver`。名称用于主 agent 编排和检索，但 skill 的 description、正文和步骤不应让 subagent 承担 friction 概念：不提 `frictions.md`、tags 或主任务状态。subagent 只看到具体问题、连续 task、调查、绕过、issue 对齐与后续 sandbox。

**Sandbox 名称与注册**：新 sandbox skill 定名为 `issue-worktree-sandbox`，registry 使用同名条目。现有 `sandbox-safety-registry` 以每个 sandbox skill 的综合边界表登记，而草稿曾提出逐工具模式表。用户决定保留以 sandbox skill 为条目的形式；后续在 `issue-worktree-sandbox` 条目内写清具体工具模式和边界，而不把“允许修复 issue”抽象成无限权限。

**Issue draft**：`issues.md` 只登记问题和 `open` / `fixed` 状态，每次新增、增补或关闭都立即单独提交。候选 worktree 的完整调查、方案、候选修复和验证过程改为放在统一目录：`drafts/issue-<N>-<short-slug>.md`。draft 按实际推进顺序 append，不设固定模板；可以随代码独立或一起提交。它与候选分支同在，用户决定采纳时是否带回主路径，默认不自动带入。

**Skill gap 的轻量记录**：对文档/Skill 补充不应默认套用完整 code issue worktree。主 agent 先按正常 Skill 发现方式确认缺口；确认 `skill-gap` 时，在 Claude skills 根目录下的 `.skill-gaps` 独立 Git 仓库记录。该仓库按发生时当前工作目录名原样分范围，例如 `.skill-gaps/_Docs_Mdb/`；文件名是 `missing-<information>.md`，明确表达缺少的信息。

**Gap 文件的职责**：`missing-*.md` 不带状态、编号或固定模板，只自由记录任务背景、主 agent 缺少的可见信息、以及应补充到哪个现有或新 Skill。它位于 `skills/` 下，因此后续 grep 可以发现仍未补齐的知识。主 agent 创建 gap 文件并立即提交；Skill 的补充和对应 gap 文件的删除均须用户介入，且用户确认补充完成后才删除。Git 历史与 friction tag 分别保留补齐过程和最终状态。

## 2026-07-31: 过程标题与直接关闭路径

**段落占位的含义**：重新讨论格式中的 `<para1>：...`、`<para2>：...`。最初误以为它们必须删除，因为它们像固定字段或编号段落；用户指出它们只是表示一条带冒号的过程陈述，例如“Agent 调查：……”或“用户纠正：……”。因此保留多个 para 占位和冒号形式；不要求固定段落数量、固定顺序或每种标题都出现。

**标题种类的收敛**：随后确认自由段落仍需要一组可用的过程标题，避免记录只剩无结构叙述。第一轮先列出触发、尝试、调查、纠正、结论等常见过程；用户指出缺少对被识别或阻止操作的“危险行为”。加入后，又确认 main agent 需要显式留下“增加 skill-gap”的动作。

**Issue 负载的修正**：我一度把“Issue 与候选修复”写成主 agent 的过程标题，用户指出候选修复细节不应进入主 agent 的负载，于是移除了它。随后用户纠正，Issue 的增加本身仍必须记录；最终标题不是“Issue：”，而是与 skill gap 对称的“增加 Issue：”。它只说明主 agent 已将问题升级到 issue 路径，不承担 candidate worktree、分支或实现过程。

**Skills 搜索的补入**：在讨论“grep 无结果是否就是 skill-gap”及 junction Skill 漏搜时，发现过程标题中漏掉了主 agent 实际执行的检索。加入“Skills 搜索：”，用来记录搜了什么、发现什么或没有发现什么；它是后续增加 skill-gap 的证据，但一次搜索无结果本身不能机械证明 gap。

**候选完成的补入**：`upstream-candidate-fixed` 使候选版本成功和主路径采纳之间有了明确差异。主 agent 不记录候选实施细节，但必须接收这个结果，因此加入“候选修复完成：”。它只陈述 problem solver 回报的候选版本已验证、绑定 issue 已在候选分支关闭；主路径是否采纳仍由用户决定。

**可用标题**：收敛后的过程标题是：`触发：`、`Skills 搜索：`、`尝试：`、`危险行为：`、`Agent 调查：`、`用户纠正：`、`增加 skill-gap：`、`增加 Issue：`、`绕过：`、`候选修复完成：`、`验证：`、`结论：`。它们是可按真实过程选用的陈述前缀，不是模板字段清单。

**直接关闭的特例**：讨论 `undecided → resolved` 时，先误把用户的问题理解为 tag 组合；实际讨论的是这种直接关闭应出现哪些过程段落。该路径通常不增加 skill-gap 或 Issue，也不需要绕过或候选修复，因为没有遗留问题等待处理。常见过程是“触发：→ Skills 搜索：→ 尝试：→ Agent 调查：→ 验证：→ 结论：”；“危险行为：”和“用户纠正：”仅在实际发生时加入。这个特例证明 `resolved` 不能被理解成“所有 friction 都必须走 gap 或 issue”，也证明 tags 与过程段落是两套不同维度。

**绕过的边界**：绕过不是直接 `undecided → resolved` 的典型部分。它通常在 agent 已确认 Issue 路径后，用于让当前任务继续，同时保留根因尚未解决的事实。因此含“绕过：”的记录通常仍有 `upstream-issued` 或其后续候选状态，而不会因为任务暂时继续就直接关闭。

**组合重新计数**：加入 `upstream-candidate-fixed` 后，合法 tag 组合扩展为 13 种：`undecided`；`skill-gap`、`upstream-issued`、`upstream-candidate-fixed`、`skill-gap upstream-issued`、`skill-gap upstream-candidate-fixed`、`skill-gap upstream-fixed`、`skill-fixed upstream-issued`、`skill-fixed upstream-candidate-fixed`；`resolved`、`resolved skill-fixed`、`resolved upstream-fixed`、`resolved skill-fixed upstream-fixed`。这份清单同时是共存约束和标题 tag 顺序的来源。

## 2026-07-31: 可信度原则与规则评估

**委托信息的可信度**：设计 `friction-problem-solver` 时，曾讨论是否把主 agent 提供的危险行为和操作边界写成硬约束。这样会让 subagent 在执行时被可能过时或不完整的转述分心，也使主 agent 的输入被误当作真值。推理收敛为：委托中的已知事实、尝试和危险行为是调查线索；subagent 优先以项目文档与实际可复现结果核验。文档与实际互相矛盾时，也不机械相信文档或退回相信委托，而是回报矛盾。

**可信度的形式化**：把委托信息记为假设 `H`，项目文档、已触发 Skill 与实际可复现结果记为可核验依据 `E`。`H` 不能单独授权或否决操作；只有 `E` 支持某路径时，subagent 才把 `H` 升格为可行动结论。`H` 与 `E` 矛盾时保留并回报矛盾，而不是服从 `H`。这解释了为何危险行为应作为提示传入，却不能成为未经核验的禁令。

**原则是系统属性**：先前把“主 agent 心智负担小”和“subagent 渐进推进”写成分别属于两个角色的原则。用户指出两者都约束完整的 agent 协作系统：每个 agent 只承担当前角色、当前阶段所需的最小信息与决策；两者都不预读后续流程，按当前阶段需要渐进获取下一份信息或 skill。因此原则名称收敛为“心智负担小”和“渐进推进”。

**七项原则**：后续每一条准备写进任何 Skill 的规则，都要先评估：心智负担小、渐进推进、执行稳定性、沙盒性、不过度约束、不越权、可信度。它们可形式化为不变量：协作状态不要求任一 agent 维护不属于当前阶段的局部细节；信息集只包含当前阶段的最小必需 Skill；阶段转换有可恢复产物；候选可写集合与主路径可写集合不相交；规则不把假设升级为不必要禁令；未采纳候选不改变权威状态；行动结论由可核验依据支持而非会话转述。

**可信度规则的评估**：将“委托中的已知事实、尝试和危险行为是调查线索；优先以项目文档与实际可复现结果核验”逐项评估。心智负担小：主 agent 不必预先裁决事实，subagent 不必盲从并维护大量例外。渐进推进：当前调查阶段只核验当前委托涉及的信息，不提前推演 issue 或 sandbox。执行稳定性：结论可回查项目文档与复现结果。沙盒性：不改变候选版本与主路径隔离。不会过度约束：危险行为提示不是永久禁令。不越权：委托文字不构成修改、绕过或采纳的授权。可信度：低层转述不能单独成为行动结论。该规则因此可以进入 `friction-problem-solver`。

## 更新后的原则考量

| 原则 | 分阶段链路的结果 |
|------|------------------|
| 心智负担小 | 每个 agent 只维护当前角色、当前阶段需要的信息；主 agent 不处理编号、分支、worktree、候选修复或验证细节。 |
| 渐进推进 | 当前阶段只引入必要的 Skill 与结论：先处理具体问题，确认需要时才进入 issue，对齐后才进入 sandbox。 |
| 执行稳定性 | 分析回报 → issue 对齐 → 候选 worktree → issue commit → 候选修复/验证 commit → 交付；同一 subagent 用 task chain 和消息 goal 连续推进，换 agent 时重放上下文。 |
| 沙盒性 | 候选登记、修复、验证和候选关闭都在绑定 issue 的 worktree；主路径不因试验自动变化，用户决定是否采纳。 |
| 不过度约束 | 首轮委托提供线索和目标，不预设必须登记 issue、开 sandbox 或采用某个未经核验的路径。 |
| 不越权 | subagent 可主动调查、绕过和候选修复；不直接改主路径或自动采纳。 |
| 可信度 | 委托中的事实、尝试和危险行为是线索；行动结论优先由项目文档与实际可复现结果支持。 |

## 数学建模线索

| 原则 | 数学建模关键词 |
|------|----------------|
| 心智负担小 | 状态空间 · 信息熵 · 认知复杂度 |
| 渐进推进 | 有限状态搜索 · 状态门 · 启发式展开 · 剪枝 |
| 执行稳定性 | 有限状态机 · 检查点 · 可恢复转换 |
| 沙盒性 | 集合隔离 · 可写集不相交 · 边界不变量 |
| 不过度约束 | 可行解空间 · 约束最小化 · 可满足性 |
| 不越权 | 权限格 · 访问控制 · 权威状态不变量 |
| 可信度 | 证据链图 · 来源层级 · 贝叶斯更新 |

**后续 TODO**：在当前 grill 完成、没有更紧急任务时，尝试把七项原则写成完整的形式化模型：定义状态、证据、权限、可写集合与阶段转换，并证明当前四处 skill 设计满足对应不变量。此表只保留建模方向，不把尚未完成的证明伪装成结论。

## 2026-08-01: Problem Solver 流程草稿

**三阶段**：`friction-problem-solver` 直接按调查、Issue 协商、候选修复三阶段行文。每个阶段都写目标、步骤和多个门禁问句；门禁是 solver 自己对当前阶段产物的反复校验，不是主 agent 或用户的审批，也不需要另建 task、checkpoint 文件或共享 todo。

**调查阶段**：目标是以可核验依据处理最初委托的具体问题。已定位项目时先查阅该项目全部文档，再使用主要相关 Skill；可根据项目文档自行发现并 invoke 额外相关 Skill。委托中的已知事实、尝试和危险行为是线索，优先以项目文档与实际可复现结果核验。调查可读取、运行和验证，但不修改项目内容、Git 状态、Issue 或 Skill。门禁逐项检查：是否查阅项目文档、主要相关 Skill；委托线索是否已核验；问题边界与解释是否有可复查依据；是否已尽力满足最初具体需要；结论是否明确为可直接回报或需要进入 Issue 协商。任何一项未通过则继续调查。直接结论回报后退出 solver；skill-gap 不由 solver 判断或处理，仍由主 agent 的 Skills 搜索和 gap 记录处理。

**Issue 协商阶段**：仅当调查确认需要 Issue 时进入。solver 自行 invoke `issue-lifecycle`，并将主 agent 映射为该 skill 中的用户；下层 skill 保持其登记即提交的既有契约，不因上层流程被改写。门禁不只检查是否调用下层 skill，还复核：是否完成与主 agent 的协商；Issue 是否只陈述已确认问题而非推测；是否登记在正确项目的 `issues.md`；是否遵守项目现有编号规则；是否立即单独提交；是否已向主 agent 回报登记结果和关联信息。全部通过才进入候选修复。

**候选修复阶段**：目标是为已登记 Issue 获得可验证的候选解决结果。solver 自行 invoke `issue-worktree-sandbox`，由 sandbox 决定该项目和 Issue 是否适合候选修复、如何尝试绕过、如何实现验证；solver 不重复其内部决策。门禁逐项检查：sandbox 是否已判断该 Issue 能否在候选环境处理；是否已按其判断执行完成；是否已尽力满足最初委托的需要，给出可用绕过、候选修复结果或无法满足的明确依据；是否已回报结果。全部通过即退出 solver 流程。

## 函数调用的抽象理解

**调用者与被调者**：`friction-lifecycle` 是外层任务循环管理者，记录 friction 并派 `general-purpose` agent；它要求 solver 自行 invoke `friction-problem-solver`，但不向 solver 提供 `frictions.md` 或 tags。solver 是具体问题的连续执行者，收到问题、主要相关 Skill、可定位项目、已知事实与尝试、调查目标、危险行为与操作边界后，自行推进三阶段。

**递归调用**：solver 在调查阶段不预读后续 skill。确认需要 Issue 后才调用 `issue-lifecycle`；其返回值不是一句“已调用”，而是经过上层 Issue 门禁复核的已协商、已登记、已提交 Issue。该 Issue 成立后，solver 再调用 `issue-worktree-sandbox`；其返回值是经过候选修复门禁复核的候选结果。每个下层 skill 保持自己的契约，上层不为方便而削弱下层规则。

**调用不是状态转移的替代品**：invoke 只把控制权交给下层 skill，不自动证明阶段完成。阶段完成由本层多问句门禁决定；因此上层会复核下层的关键后置条件，但不复制下层的具体实现步骤。这个区别避免了“调用过 issue-lifecycle”被误当作“Issue 已正确登记”，也避免了上层承担 sandbox 的 worktree、分支和修复细节。

**checkpoint 的位置**：checkpoint 不存为 task 或未纳入 Git 的阶段文件。每个阶段的门禁问句、其可核验结果、以及 solver 对下一阶段 skill 的渐进调用共同构成 checkpoint。若同一 solver 继续工作，transcript、回报和后续消息保留连续上下文；换 solver 时，调用方重给已确认结论和当前目标，而不是依赖私有状态文件。

## 2026-08-01: 递归配置覆盖

**提交时机的矛盾**：审阅 `friction-problem-solver` 时，发现 Issue 门禁仍写“是否已立即单独提交 Issue 登记”。这与已讨论的上层阶段设定“已对齐 Issue 写入 `issues.md` 后保持未提交，由 sandbox 接管”冲突。最初错误地把 skill invoke 理解成命令序列：先完整执行 `issue-lifecycle` 的默认提交，再由上层恢复主路径；这种解释会制造不存在的 dirty-state 修复链，也会让下层默认行为压过当前任务的具体需要。

**递归不是顺序脚本**：随后又把它说成动态调用栈的上下文覆盖，仍不准确。更准确的抽象是：多个 skill 递归地共同修改同一个任务配置条目。`issue-lifecycle` 为“Issue 登记后的提交方式”提供默认配置“立即提交”；`friction-problem-solver` 对同一配置项提供当前阶段的更具体设置“保持未提交，交由 sandbox 接管”。最终任务配置取上层覆盖后的值：Issue 写入但不提交。下层继续提供未被覆盖的 Issue 格式、协商和编号规则。

**配置覆盖原则**：skill 之间的递归不是要求依次执行对方的所有命令，也不是让上层事后修正下层副作用。它们共同约束同一任务；更具体的上层阶段设置可以覆盖下层默认设置。后续设计 `issue-worktree-sandbox` 时，应把它看作继续为同一任务条目补充 worktree、候选分支与候选修复配置，而不是独立脚本接收上一个脚本留下的状态。

**对当前 skill 的影响**：`friction-problem-solver` 的 Issue 阶段应保留“Issue 写入、保持未提交、等待 sandbox 接管”的门禁，不写“立即单独提交”。`issue-lifecycle` 仍只按既定范围修改全局候选 Issue 编号规则；它的独立默认提交规则不在此任务配置下生效。渐进禁止项则应作为三阶段外的独立约束：在对应阶段门禁通过前，不预读 `issue-lifecycle` 或 `issue-worktree-sandbox`。
