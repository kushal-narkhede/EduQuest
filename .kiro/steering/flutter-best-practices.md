---
inclusion: manual
---

# Flutter Development Best Practices

## Code Style
- Use `const` constructors wherever possible for performance
- Follow Dart naming conventions (camelCase for variables, PascalCase for classes)
- Keep widget build methods focused and extract complex widgets
- Use meaningful variable and function names

## State Management
- Use `setState()` for simple local state
- Consider BLoC pattern for complex state (already using flutter_bloc)
- Dispose controllers and timers in dispose() method
- Avoid rebuilding entire widget trees unnecessarily

## Performance
- Use `const` widgets to prevent unnecessary rebuilds
- Implement `ListView.builder` for long lists
- Optimize image assets (compress and use appropriate formats)
- Profile app performance with Flutter DevTools

## Database
- Use transactions for multiple related database operations
- Close database connections properly
- Handle database errors gracefully
- Use prepared statements to prevent SQL injection

## UI/UX
- Support both portrait and landscape orientations where appropriate
- Ensure text is readable on all theme backgrounds
- Provide loading indicators for async operations
- Handle edge cases (empty states, errors, no internet)

## Testing
- Write unit tests for business logic
- Write widget tests for UI components
- Test database operations
- Test API integration
