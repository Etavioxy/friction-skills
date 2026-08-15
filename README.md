# friction-skills

English | [中文](README.zh.md)

[![skills.sh](https://skills.sh/b/Etavioxy/friction-skills)](https://skills.sh/Etavioxy/friction-skills)

A harness includes the toolchain, context engineering, and process mechanisms. Definition: friction is the loss of agent capability caused by problems in the harness.

Friction Skills — a set of processes for recording, investigating, and fixing friction.

See [VISION.md](VISION.md) for the vision and the why behind this repo.

## Install

### One-line install

```bash
# Install
npx skills add Etavioxy/friction-skills

# Uninstall
npx skills remove friction-skills
```

### Manual install

Clone this repo, then use the script to install and manage all skills (Claude example):

```bash
# Install
./install.sh ~/.claude/skills/

# Uninstall
./install.sh ~/.claude/skills/ --uninstall
```

## Skills

- [friction-lifecycle](skills/friction-lifecycle/SKILL.md) — record friction and dispatch investigation
- [friction-problem-solver](skills/friction-problem-solver/SKILL.md) — investigate a delegated problem
- [issue-lifecycle](skills/issue-lifecycle/SKILL.md) — Git-native issue writing conventions
- [issue-worktree-sandbox](skills/issue-worktree-sandbox/SKILL.md) — candidate fix in a worktree sandbox

## License

[MIT](LICENSE)
