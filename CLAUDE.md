# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Name:** health_records
**Type:** Flutter health records management app
**Platforms:** iOS + Web (macOS build artifacts present)
**Language:** Dart
**State Management:** Riverpod 2.x
**Database:** Hive (local storage with type adapters)
**Navigation:** go_router with ShellRoute

## Build / Test Commands

```bash
flutter pub get                    # Install dependencies
flutter run -d chrome              # Run on Chrome (Web)
flutter run -d iphone              # Run on iOS simulator
flutter build web                  # Build for Web production
flutter build ios                  # Build for iOS

flutter analyze                    # Static analysis
flutter test                       # Run all tests
flutter test test/domain/          # Unit tests only
flutter test test/features/        # Widget tests only
flutter test test/integration/     # Integration tests only
flutter test test/form_validators_test.dart  # Single test file

flutter pub run build_runner build --delete-conflicting-outputs  # Generate Hive adapters
flutter pub run build_runner watch  # Watch mode for adapter generation
```

## Architecture

**Layer-first + Feature-first hybrid:**

```
lib/
├── main.dart                    # Hive initialization, adapter registration
├── core/                        # Shared infrastructure
│   ├── router/                  # go_router with ShellRoute + BottomNav
│   ├── theme/                   # Material 3 minimalist light theme
│   ├── services/                # PDF extraction, indicator parsing
│   └── utils/                   # Form validators
├── data/                        # Data layer
│   ├── models/                  # Hive models (Person, HealthReport, HealthIndicator)
│   └── repositories/            # CRUD operations, cascade delete logic
├── domain/                      # Domain layer
│   └── entities/                # Business entities with computed properties
└── features/                    # Feature modules
    ├── person/                  # Person CRUD with family relationships
    ├── health_report/           # Health reports with PDF import
    └── family_tree/             # Family tree visualization (graphview)
```

**Key Architectural Patterns:**

1. **Hive Models**: All models extend `HiveObject` with `@HiveType` annotations. Field indices must be sequential. After model changes, run `build_runner` to regenerate `.g.dart` adapters.

2. **Riverpod Providers**: `StateNotifierProvider` for complex state, `StateProvider` for simple state. Providers follow naming pattern `xxxProvider` and `xxxNotifierProvider`.

3. **Cascade Delete**: `PersonRepository.delete()` automatically deletes all associated `HealthReport` and `HealthIndicator` records.

4. **Family Relationships**: Person model includes `fatherId`, `motherId`, `spouseId` fields for family tree construction. Use `getParentIds()` and `hasParents()` helper methods.

## Key Technical Details

### PDF Processing
- Uses `pdfrx` for native text extraction
- OCR fallback with `google_mlkit_text_recognition` on mobile (not available on web)
- Max file size: 20MB
- Extraction modes: native, ocr, hybrid
- Check `_isValidPdf()` before processing

### Health Indicators
Three indicator types stored in `HealthIndicator` model:
- Blood glucose (mmol/L)
- Blood pressure (systolic/diastolic mmHg format - uses `value` and `secondValue`)
- Blood lipids (TC/TG/HDL/LDL in mmol/L)

### Form Validation
- Only `name` field is required for Person creation
- Chinese error messages: `'姓名不能为空'`, `'请输入有效手机号'`
- Phone validation: Chinese mobile pattern `^1[3-9]\d{9}$`
- BirthDate validation: cannot be future date

### Photo Storage
- iOS: file path stored in `photoPath`
- Web: base64 encoding (not yet implemented in current code)

### Theme System
Minimalist Material 3 light theme (NOT CoinGlass-inspired):
- Primary: Subtle Blue `#007AFF`
- Background: Light Gray `#F5F5F7`
- Surface: Pure White `#FFFFFF`
- Cards: 12dp rounded corners with subtle borders (minimal shadows)
- Use `AppTheme` constants for spacing, colors, radius
- Extension methods on `BuildContext` for quick theme access

### Navigation Structure
Bottom navigation with 3 tabs:
- `/persons` - Family management
- `/reports` - Health reports
- `/family-tree` - Family tree visualization

ShellRoute wraps all routes to maintain bottom nav across pages.

### Platform Differences
- **Web**: No camera access, file picker for PDF/photos, IndexedDB for Hive, OCR not available
- **iOS**: Camera/photo permissions required in `Info.plist`, local file storage for photos, ML Kit OCR available

## Important Patterns

### Creating New Feature
1. Create `lib/features/<feature_name>/` directory structure
2. Add Hive model in `lib/data/models/` if needed
3. Run `build_runner` to generate adapter
4. Register adapter in `main.dart`
5. Create repository in `lib/data/repositories/`
6. Create Riverpod providers in `features/<feature_name>/providers/`
7. Add UI pages in `features/<feature_name>/ui/pages/`
8. Register routes in `lib/core/router/app_router.dart`

### Hive Model Changes
When modifying Hive models:
1. Update `@HiveField` indices (must be sequential, never reuse deleted indices)
2. Increment `@HiveType` typeId if breaking change
3. Run `flutter pub run build_runner build --delete-conflicting-outputs`
4. Models auto-register in `main.dart` via `Hive.registerAdapter()`

### Riverpod State Pattern
```dart
// Simple state
final selectedPersonIdProvider = StateProvider<int?>((ref) => null);

// Complex state with notifier
class PersonsNotifier extends StateNotifier<List<Person>> {
  PersonsNotifier() : super([]);

  Future<int?> savePerson(Person person) async {
    // State updates: state = [...state, newPerson];
  }
}

final personsProvider = StateNotifierProvider<PersonsNotifier, List<Person>>((ref) {
  return PersonsNotifier();
});
```

## Common Mistakes to Avoid

1. **Hive Field Indices**: Never reuse deleted field indices. Always add new fields with new indices.

2. **Cascade Delete**: When deleting a Person, must manually delete associated HealthReports in repository code.

3. **PDF on Web**: Cannot use OCR on web platform. Check `kIsWeb` before calling OCR methods.

4. **Provider Naming**: Follow `xxxProvider` and `xxxNotifierProvider` naming convention consistently.

5. **Theme Colors**: Do NOT use CoinGlass orange theme. Current theme uses subtle blue `#007AFF`.

6. **Required Fields**: Only Person `name` is required. All other fields optional.

7. **Age Calculation**: Auto-calculated from `birthDate` in Person model via `age` getter property.

8. **Chinese UI**: All user-facing strings must be in Chinese (e.g., `'家人管理'`, `'报告导入'`).

## Testing Structure

```
test/
├── domain/                      # Unit tests for entities
├── features/*/ui/               # Widget tests
├── integration/                 # End-to-end flow tests
├── performance/                 # Large dataset tests (100+ records)
└── form_validators_test.dart    # Validation logic tests
```

Test file naming:
- Unit tests: `*_test.dart`
- Widget tests: `*_ui_test.dart`
- Integration: `*_flow_test.dart`