---
inclusion: manual
---

# EduQuest Project Structure

## Directory Organization

### `/lib`
Main Flutter application code

- `/ai` - AI chat integration with BLoC pattern
  - `/bloc` - BLoC state management
  - `/models` - Data models
  - `/repos` - Repository pattern for data access
  - `/utils` - AI-specific utilities

- `/data` - Static data and question banks
  - `questions.dart` - Quiz questions
  - `premade_study_sets.dart` - Pre-made study content

- `/helpers` - Business logic and data access
  - `database_helper.dart` - SQLite operations
  - `remote_api_client.dart` - Backend API client
  - `frq_manager.dart` - Free response question management

- `/screens` - UI screens
  - `/modes` - Different quiz game modes
  - Other screens for navigation and features

- `/utils` - Utility classes and configuration
  - `config.dart` - App configuration

### `/server`
Node.js backend with Express and MongoDB

- `/src` - Server source code
  - `/models` - Mongoose schemas
  - `/routes` - API endpoints
  - `index.js` - Server entry point

### `/assets`
Static assets (images, animations, prompts)

## Naming Conventions
- Screens: `*_screen.dart`
- Helpers: `*_helper.dart`
- Models: `*_model.dart`
- Widgets: descriptive names in `snake_case.dart`
