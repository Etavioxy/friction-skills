---
name: friction-lifecycle
description: 任务循环的 friction 记录规范。发现 friction 时维护项目 frictions.md、更新状态并调度调查。触发词：friction、摩擦、卡点、上游保证。
---

# Friction 生命周期

## 定义

Friction 是任务循环中遇到的系统性卡点，需要停下调查才能继续。包括：上游保证与实际体验不符、工具链缺少阻止错误或恢复的机制，以及操作错误所暴露的系统性缺口。

## 格式

```markdown
## <标题> — <tag1> <tag2> ... <tagN>

<para1>：...

<para2>：...

...

<paraN>：...
```

正文按实际排查顺序写多个段落，数量不限，只追加，不修改已有段落，且禁止写"待调查"。每段直接陈述当时发生的事；可用前缀包括：`触发：`、`Skills 搜索：`、`尝试：`、`危险行为：`、`Agent 调查：`、`用户纠正：`、`增加 skill-gap：`、`增加 Issue：`、`绕过：`、`候选修复完成：`、`验证：`、`结论：`。

`Skills 搜索：` 只有真对 skills grep 相关关键词才能用；
`Agent 调查：` 只有真派了 general-purpose agent 并收到回报才能用。

Skills 搜索是指对全部 skills 进行 grep。

## Tags

Tags 标在标题后面，表示当前状态。同一状态线只保留当前 tag；历史和理由写入正文及 Git。

| Tag | 条件与切换 |
|-----|------------|
| `undecided` | 确认是 friction 时添加；确定任一落地路径时移除；无需落地时替换为 `resolved`。 |
| `skill-gap` | 确认可见 Skill 信息有缺口时添加；补齐时替换为 `skill-fixed`；证实无需此路径时移除。 |
| `skill-fixed` | `skill-gap` 补齐后替换得到；发现缺口仍存在时替换回 `skill-gap`。 |
| `upstream-issued` | 候选 issue worktree 已创建、绑定 issue 已登记并提交后添加；候选修复完成时替换为 `upstream-candidate-fixed`；证实无需此路径时移除。 |
| `upstream-candidate-fixed` | 绑定 issue 已在候选版本修复、验证并关闭时替换得到；候选失效时替换回 `upstream-issued`。 |
| `upstream-fixed` | 候选修复经用户采纳并在主路径落地后替换得到；用户确认 fix 已在上游主分支时直接取消 `upstream-candidate-fixed` 替换为 `upstream-fixed`；修复失效时替换回 `upstream-issued`。 |
| `resolved` | 不存在未完成路径时添加；出现新的待处置路径时移除。 |

## 合法 Tag 组合

Tags 按下列组合中的顺序书写。

```text
undecided

skill-gap
upstream-issued
upstream-candidate-fixed
skill-gap upstream-issued
skill-gap upstream-candidate-fixed
skill-gap upstream-fixed
skill-fixed upstream-issued
skill-fixed upstream-candidate-fixed

resolved
resolved skill-fixed
resolved upstream-fixed
resolved skill-fixed upstream-fixed
```

## Skill Gap 记录

判断 skill 信息缺口、理解 skill 的 Notes/spec 结构时，请 invoke [[skill-authoring]]。

确认 `skill-gap` 时，在 `skills/.skill-gaps` 的独立 Git 仓库创建并立即提交：`skills/.skill-gaps/<当前工作目录名>/missing-<information>.md`。其中当前工作目录名是 `frictions.md` 所在工作项目目录名

gap 文件格式：

```markdown
# <标题>

## 背景
<任务背景，为什么缺少>

（可选）## 调查确认
<自己或 agent 的调查过程和结论>

## 落点
<段落级落点，如 SKILL.md 的 ## 快速参考 节>

## 待插入文本
<完整内容，可直接合并>
```

需用户指导补充进 Skill。

## 调查委托

派 `general-purpose` agent 时，要求它自行 invoke `friction-problem-solver` skill。首轮委托提供具体问题、主要相关 Skill、可定位时的相关项目、已知事实与尝试、调查目标、危险行为与操作边界；不提供 `frictions.md` 或 tags。

## 处理流程

1. 确认 friction 后，先在当前任务的 `frictions.md` 建立 `undecided` 条目并立即单独提交，不猜测原因。
2. 搜索可见 Skills，记录搜索结果；搜索确认 friction 有上游项目归属时走上游路径（第 4 步），不建 gap 文件；确认 Skill 缺口时，创建对应 gap 文件并立即单独提交。
3. 按“调查委托”派 agent 处理具体问题。
4. 根据回报更新原 friction 条目和 tags，并立即单独提交。若需要项目级跟踪，与 agent 对齐拟议 Issue；然后要求 agent 继续候选修复。若 agent 回报为文档缺失而非行为缺陷，不登记为 Issue，退回 `skill-gap` 路径。
5. 主任务默认继续；若调查表明继续必须依赖未经证实的假设、无文档依据的操作、不可逆或高风险改动，或会掩盖/扩大问题，则停止并等待用户指导。
