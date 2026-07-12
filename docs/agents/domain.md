# Domain Docs

## Before exploring, read these

- `CONTEXT.md` at the repo root.
- Relevant ADRs under `docs/adr/`.

If these files do not exist, proceed silently. The domain-modeling skill creates them lazily when terminology or decisions need recording.

## File structure

```text
/
├── CONTEXT.md
├── docs/adr/
└── src/
```

## Use the glossary’s vocabulary

Use terms defined in `CONTEXT.md` for issue titles, proposals, hypotheses, and tests. If a needed term is absent, reconsider whether it is established project language or note the gap for domain modeling.

## Flag ADR conflicts

Surface any conflict explicitly rather than silently overriding an existing ADR.
