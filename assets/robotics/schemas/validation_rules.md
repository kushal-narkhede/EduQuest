# Validation Rules

- All items must include: `module`, `lesson`, and `tags` (difficulty, modes, domains, time).
- MCQ: Must include rationales for correct and all distractors; no missing rationales.
- FRQ: Rubrics must contain at least 3 criteria and level descriptors.
- Coding FRQ: Must include a test harness with at least 3 tests and 1 edge case.
- Asset references: paths in assets must resolve to existing files under `assets/`.
- Versioning: payloads must include `metadata.version` and `metadata.last_updated` (ISO date).
- Filtering: support filter by `difficulty`, `tags` (domains), and `modes`.
