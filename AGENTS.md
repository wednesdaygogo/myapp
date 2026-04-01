# AGENTS.md - Flutter Health Records App

> Guidelines for agentic coding agents working in this repository.

## Project Overview

**Name:** health_records  
**Language:** Dart/Flutter  
**Platforms:** iOS, Web  
**Architecture:** Feature-first with layer separation  
**State Management:** Riverpod 2.x  
**Database:** Hive (local storage)  
**Navigation:** go_router with ShellRoute

---

## Build / Lint / Test Commands

### Dependencies
```bash
flutter pub get                    # Install dependencies
flutter pub upgrade                # Upgrade dependencies
flutter pub outdated               # Check for outdated packages
```

### Build Commands
```bash
flutter run -d chrome              # Run on Chrome (Web)
flutter run -d iphone              # Run on iOS simulator
flutter build web                  # Build for Web production
flutter build ios                  # Build for iOS (requires macOS)
```

### Lint Commands
```bash
flutter analyze                    # Run static analysis
flutter analyze lib/               # Analyze specific directory
dart fix --apply                   # Auto-fix lint issues
```

### Test Commands
```bash
flutter test                       # Run all tests
flutter test test/domain/          # Run unit tests only
flutter test test/features/        # Run widget tests only
flutter test test/integration/     # Run integration tests only
flutter test test/form_validators_test.dart  # Run single test file
flutter test --coverage            # Run with coverage report
```

### Code Generation
```bash
flutter pub run build_runner build --delete-conflicting-outputs  # Generate adapters
flutter pub run build_runner watch                                # Watch mode
```

---

## Project Structure

```
lib/
├── main.dart                    # App entry point, Hive initialization
├── core/                        # Shared infrastructure
│   ├── router/                  # go_router configuration
│   ├── theme/                   # Material 3 theme, colors, spacing
│   └── utils/                   # Validators, helpers
├── data/                        # Data layer
│   ├── models/                  # Hive models with adapters (.g.dart)
│   └── repositories/            # Data access, CRUD operations
├── domain/                      # Domain layer
│   └── entities/                # Business entities with computed properties
└── features/                    # Feature modules
    ├── person/
    │   ├── providers/           # Riverpod providers
    │   └── ui/pages/            # Widgets and pages
    └── health_report/
        ├── providers/
        └── ui/pages/

test/
├── domain/                      # Unit tests for entities
├── features/*/ui/               # Widget tests
├── integration/                 # End-to-end flow tests
└── performance/                 # Performance tests
```

---

## Code Style Guidelines

### Imports
```dart
// 1. SDK imports (alphabetical)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// 2. Package imports (alphabetical)
import 'package:hive/hive.dart';

// 3. Relative imports (alphabetical)
import '../../../data/models/person.dart';
import '../../providers/person_provider.dart';
```

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Classes | PascalCase | `PersonRepository`, `PersonListPage` |
| Files | snake_case | `person_list_page.dart`, `person_provider.dart` |
| Variables | camelCase | `persons`, `selectedPersonId` |
| Constants | camelCase | `primaryColor`, `spacingMd` |
| Private members | _camelCase | `_persons`, `_isar` |
| Providers | xxxProvider | `personsProvider`, `personNotifierProvider` |

### Widget Patterns

**Stateless UI (ConsumerWidget):**
```dart
class PersonListPage extends ConsumerWidget {
  const PersonListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final persons = ref.watch(personsProvider);
    // ...
  }
}
```

**Stateful Forms (ConsumerStatefulWidget):**
```dart
class PersonFormPage extends ConsumerStatefulWidget {
  const PersonFormPage({super.key});

  @override
  ConsumerState<PersonFormPage> createState() => _PersonFormPageState();
}
```

### Provider Patterns

**Simple state:**
```dart
final personsProvider = StateProvider<List<Person>>((ref) => []);
```

**Complex state with notifier:**
```dart
class PersonNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  PersonNotifier(this._ref) : super(const AsyncData(null));

  Future<int?> createPerson(Person person) async {
    state = const AsyncLoading();
    try {
      // ... logic
      state = const AsyncData(null);
      return person.id;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}

final personNotifierProvider = StateNotifierProvider<PersonNotifier, AsyncValue<void>>((ref) {
  return PersonNotifier(ref);
});
```

### Error Handling

- Use `try/catch` blocks in async methods
- Return `AsyncError` in providers for UI feedback
- User-facing messages in Chinese: `'姓名不能为空'`
- Log errors with stack trace for debugging

```dart
try {
  // operation
  state = const AsyncData(null);
} catch (e, st) {
  state = AsyncError(e, st);
  return null;
}
```

### Model Patterns (Hive)

```dart
part 'person.g.dart';

@HiveType(typeId: 0)
class Person extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String? gender;

  Person({required this.name, this.gender});

  // Computed properties in model
  int get age {
    // calculation logic
  }
}
```

---

## Theme & Styling

### Colors (CoinGlass-inspired)
- Primary: `#FF6B35` (orange)
- Success: `#00E676` (green)
- Warning: `#FFAB00` (amber)
- Error: `#FF5252` (red)
- Background: `#FFFFFF` (white)
- Surface: `#F5F5F5` (light gray)

### Spacing
```dart
AppTheme.spacingXs   // 4.0
AppTheme.spacingSm   // 8.0
AppTheme.spacingMd   // 16.0
AppTheme.spacingLg   // 24.0
AppTheme.spacingXl   // 32.0
```

### Border Radius
```dart
AppTheme.radiusSm    // 8.0
AppTheme.radiusMd    // 12.0
AppTheme.radiusLg    // 16.0 (cards)
```

---

## Testing Guidelines

### Test File Naming
- Unit tests: `*_test.dart` in `test/domain/`
- Widget tests: `*_ui_test.dart` in `test/features/*/ui/`
- Integration: `*_flow_test.dart` in `test/integration/`

### Test Patterns
```dart
void main() {
  group('PersonEntity', () {
    test('age calculation', () {
      final person = PersonEntity(id: 1, name: 'Test', birthDate: birth);
      expect(person.age, equals(expected));
    });
  });
}
```

```dart
testWidgets('displays person list', (WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());
  expect(find.text('家人管理'), findsOneWidget);
});
```

---

## Common Patterns

### Adding a New Feature
1. Create `lib/features/<feature_name>/`
2. Add `providers/` for state management
3. Add `ui/pages/` for widgets
4. Register routes in `lib/core/router/app_router.dart`
5. Add Hive model if needed in `lib/data/models/`
6. Run `build_runner` to generate adapters

### Navigation
```dart
context.go('/persons');           // Navigate to route
context.go('/persons/${person.id}'); // With parameter
```

### Form Validation
```dart
TextFormField(
  validator: FormValidators.validateName,
  // ...
)
```

---

## Platform Considerations

### iOS
- Photo permissions configured in `ios/Runner/Info.plist`
- Camera and photo library usage descriptions required

### Web
- Hive uses IndexedDB for persistence
- File picker for photo/PDF selection
- No camera access on web

---

## Key Dependencies

| Package | Purpose |
|---------|---------|
| flutter_riverpod | State management |
| go_router | Declarative routing |
| hive + hive_flutter | Local database |
| pdf | PDF text extraction |
| image_picker | Camera/gallery access |
| intl | Date formatting |

---

## Forbidden Patterns

- `as any` or type suppression
- `@ts-ignore` equivalents
- Empty catch blocks
- Global mutable state outside providers
- Business logic in UI widgets
- Direct database access from UI

---

## Notes

- All user-facing strings in Chinese
- Only `name` is required for Person creation
- Cascade delete: Person deletion removes all HealthReports
- PDF limit: 20MB max file size
- Test coverage expected before final review