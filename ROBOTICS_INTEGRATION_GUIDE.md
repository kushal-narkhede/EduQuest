# Robotics Course Integration Guide

## Overview

This guide walks through the complete Robotics course integration for EduQuest, covering Flutter UI, MongoDB schemas, server endpoints, and testing.

## Quick Start

### Flutter Setup

1. Load Robotics assets:
```dart
import 'lib/helpers/robotics_assets_loader.dart';
import 'lib/helpers/robotics_repository.dart';

final repo = RoboticsRepository();
await repo.load();
final curriculum = repo.getCurriculum();
```

2. Validate content:
```dart
import 'lib/helpers/robotics_repository.dart';

final issues = RoboticsValidator.validatePayload(curriculum);
if (issues.isNotEmpty) {
  print('Validation errors: $issues');
}
```

3. Fetch from server:
```dart
final client = RemoteApiClient();
final course = await client.getRoboticsCourse();
final modules = await client.getRoboticsModules(
  courseId,
  difficulty: 'Beginner',
  tags: ['Control'],
  modes: ['Lightning'],
);
final assessments = await client.getRoboticsAssessments(
  moduleId,
  type: 'MCQ',
  difficulty: 'Intermediate',
);
```

### Server Setup

1. Ensure `server/.env` includes `MONGODB_URI`:
```env
MONGODB_URI=mongodb+srv://<user>:<password>@<cluster>.mongodb.net/<database>
```

2. Seed the database:
```bash
cd server
npm install
node scripts/seed_robotics.js
```

3. Start the server:
```bash
npm run dev
```

Endpoints available:
- `GET /robotics/courses/robotics`
- `GET /robotics/modules/:courseId?difficulty=Beginner&tags=Control&modes=Lightning&page=1&pageSize=20`
- `GET /robotics/assessments/:moduleId?type=MCQ&difficulty=Intermediate&page=1&pageSize=50`
- `POST /robotics/sync/robotics` (upsert with version conflict resolution)

## Content Structure

### Assets (assets/robotics/)
- `curriculum.json` – Modules, lessons, objectives, glossary
- `mcq_bank.json` – Multiple-choice questions with rationales
- `concept_checks.json` – Short-answer items with rubric snippets
- `frq_bank.json` – Free-response questions with rubrics and AI hints
- `coding_frq.json` – Coding tasks with test harnesses
- `problem_sets.json` – Derivations and worked examples
- `study_sets.json` – Study sets for import
- `memory_master_cards.json` – Flashcard pairs
- `chapters.json` – Textbook-style summaries
- `readings.json` – Open educational resources
- `labs.json` – Virtual/physical practice activities
- `coding_exercises.json` – Quick coding tasks for Lightning mode
- `competitions_prep.json` – Strategy guides, practice scenarios
- `treasure_hunt.json` – Campaign clues and maps
- `schemas/` – CSV/JSON schemas, tag vocabularies, validation rules

### MongoDB Collections
- `courses` – Course metadata, outcomes, tags
- `modules` – Modules with glossary and tags
- `assessments` – MCQ, FRQ, coding FRQ, concept checks, problem sets
- `game_assets` – Puzzle images, treasure maps, audio
- `achievements` – Robotics-specific badges and milestones
- `study_sets` – Importable study sets
- `users_robotics_progress` – User progress per module (future)

## Validation Rules

All items must include:
- `module` and `lesson` fields
- `tags` with `difficulty`, `modes`, `domains`, `time`
- MCQ: rationales for correct answer and all distractors
- FRQ: rubric with ≥3 criteria + level descriptors
- CodingFRQ: ≥3 tests including ≥1 edge case
- Assets: paths must resolve to existing files

Use `RoboticsValidator.validatePayload()` to check.

## Quiz Modes

### Lightning
- MCQs only
- 30–60 second time limits
- Can use 50/50 power-up
- Instant feedback

### Survival
- MCQs + concept checks
- Lives drain on wrong answers
- Can earn extra lives via correct streaks
- FRQ questions count as heavy penalties

### Memory Master
- Flashcard pairs (front/back)
- Concept checks serve as cards
- No time limit
- Shuffle and repeat

### Puzzle Quest
- Unlock puzzle pieces via correct answers
- MCQs and concept checks grant pieces
- Assemble puzzle to reveal lesson summary
- Rewards power-ups on completion

### Treasure Hunt
- Campaign maps with 10–15 nodes
- Gate items: MCQ, concept check, FRQ
- Fail-forward: wrong answer triggers alternate route
- Rewards: points and power-ups

### FRQ Mode
- All FRQ types
- AI grader provides feedback
- No time limit (or optional extended)
- Power-ups disabled or limited

## Gamification Hooks

### Points
- MCQ (Beginner): 10 pts
- MCQ (Intermediate): 25 pts
- MCQ (Advanced): 50 pts
- FRQ (correct): 100–200 pts
- Puzzle completion: 50 pts

### Achievements
- "Gear Guru" – Master mechanics
- "Control Sage" – Perfect PID tuning
- "Sensor Scout" – Solve sensor fusion
- "Vision Voyager" – Complete vision module
- "ROS Ranger" – Master ROS basics

### Power-ups
- 50/50 – Eliminates 2 distractors (MCQ only)
- Time Freeze – Extend timer (Lightning/Survival)
- Double Points – 2× for next item
- Skip FRQ – Skip one FRQ (limited uses)

## Testing

Run validation tests:
```bash
npm test  # server-side
flutter test test/robotics_validation.test.dart  # Flutter
```

Example Flutter test:
```dart
test('MCQ without rationale fails', () {
  final mcq = {...};
  final issues = RoboticsValidator.validateAssessment(mcq);
  expect(issues.any((i) => i.contains('rationale')), true);
});
```

## Contributing

To add new content:

1. Follow the CSV/JSON schemas in `assets/robotics/schemas/`.
2. Run validation: `RoboticsValidator.validatePayload(data)`.
3. If remote sync: POST to `/robotics/sync/robotics` with version metadata.
4. Update `tag_vocabularies.json` if adding new tags.
5. Add tests for new item types.

## Troubleshooting

**Can't load assets?**
- Ensure files are listed in `pubspec.yaml` under `assets:`.
- Run `flutter pub get` and `flutter clean`.

**Validation fails?**
- Check all required fields per item type.
- Ensure tags match controlled vocabularies.
- Verify rationales (MCQ) and rubrics (FRQ) are complete.

**Server not syncing?**
- Verify `MONGODB_URI` is correct.
- Check network connectivity and firewall.
- Ensure payload includes `metadata.version` and `metadata.last_updated`.

**FRQ grading not working?**
- Verify rubric has ≥3 criteria.
- Check AI hint keywords are present.
- Ensure test cases have expected outputs.

## References

- Curriculum: [assets/robotics/curriculum.json](assets/robotics/curriculum.json)
- Server models: [server/src/models/roboticsModels.ts](server/src/models/roboticsModels.ts)
- Flutter helpers: [lib/helpers/robotics_repository.dart](lib/helpers/robotics_repository.dart)
- API: [server/src/routes/robotics.ts](server/src/routes/robotics.ts)
