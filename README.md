<!-- @format -->

# ai-foundry

AIコーディングツール向けルール・スキル等の一元管理リポジトリ。

```bash
ai-foundry/
├── rules/
│   ├── coding.md
│   ├── security.md
│   └── git.md
│
├── skills/
│   ├── azure/
│   ├── terraform/
│   ├── fastapi/
│   └── threat-modeling/
│
├── prompts/
│
├── agents/
│   ├── cursor/
│   ├── claude/
│   └── kiro/
│
├── templates/
│
└── scripts/
    └── sync-rules.sh
```

## 同期

```bash
./scripts/sync-rules.sh --target ~/works/my-project [--dry-run]
```
