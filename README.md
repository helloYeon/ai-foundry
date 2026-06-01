<!-- @format -->

# ai-foundry

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
└── sync/
    └── generate.py
```

各PRJはsubmodule / subtree / sync script

ポイントは「各AIツール専用ルールを直接メンテしない」構成にして、
共通ルールを1か所に寄せることです。
共通ルールRepo + 各AI用に自動生成
