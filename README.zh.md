# friction-skills

[English](README.md) | 中文

[![skills.sh](https://skills.sh/b/Etavioxy/friction-skills)](https://skills.sh/Etavioxy/friction-skills)

Harness 包括工具链、Context 工程、流程机制，定义：Friction 是由于 Harness 的问题导致的 Agent 能力损耗。

Friction Skills，尝试解决 Friction 的一套记录、调查、修复的流程。

为什么做、愿景是什么——见 [VISION.md](VISION.md)。

## 安装

### 一键安装

```bash
# 安装
npx skills add Etavioxy/friction-skills

# 卸载
npx skills remove friction-skills
```

### 手动安装

先 clone 本仓库，用脚本安装管理所有 skills，以 Claude 为例：

```bash
# 安装
./install.sh ~/.claude/skills/

# 卸载
./install.sh ~/.claude/skills/ --uninstall
```

## Skills

- [friction-lifecycle](skills/friction-lifecycle/SKILL.md) — friction 记录与调度
- [friction-problem-solver](skills/friction-problem-solver/SKILL.md) — 调查被委托的问题
- [issue-lifecycle](skills/issue-lifecycle/SKILL.md) — Git 内 Issue 编写规范
- [issue-worktree-sandbox](skills/issue-worktree-sandbox/SKILL.md) — 在 worktree 沙箱中做候选修复

## License

[MIT](LICENSE)
