# Flutter Health Records Management App

## TL;DR

> **Quick Summary**: Build a Flutter health records app (iOS + Web) with Person CRUD, health report PDF import (blood glucose, blood pressure, blood lipids), and CoinGlass-inspired light theme UI.
>
> **Deliverables**:
> - Flutter project scaffolding (iOS + Web)
> - Person management module (create, list, detail, edit, delete with photo)
> - Health report import module (PDF extraction + manual entry fallback)
> - Isar database with Person → HealthRecord relationships
> - Material 3 light theme with CoinGlass-inspired data cards
>
> **Estimated Effort**: Medium (2-3 weeks)
> **Parallel Execution**: YES - 5 waves with 5-7 tasks each
> **Critical Path**: Task 1 → Task 6 → Task 7-10 → Task 11-13 → Task 14-20 → Integration → Final QA

---

## Context

### Original Request
用户希望开发一个Flutter健康管理APP，主要功能是管理家人的体检报告。核心功能包括：
1. 人物创建和信息录入
2. 体检报告导入（PDF）
3. 数据卡片展示人物信息，点击进入详情

### Interview Summary
**Key Discussions**:
- [Platform]: iOS + Web (Flutter)
- [Scale]: 10+ family members expected
- [UI style]: Light theme inspired by CoinGlass (data cards, orange accent)
- [PDF parsing]: Generic text extraction + manual entry fallback (no hospital-specific templates)
- [Test strategy]: Tests-after (add tests after implementation)
- [Photo storage]: Local filesystem for iOS, base64 for Web
- [Indicators]: Blood glucose (mmol/L), blood pressure (120/80 format), blood lipids (TC/TG/HDL/LDL)
- [Required fields]: Only name is required for Person creation

**Research Findings**:
- [Flutter architecture]: Layer-first (core/data/domain) + Feature-first (features/)
- [State management]: Riverpod 2.x (compile-time safety, best for health data)
- [Navigation]: go_router with ShellRoute (official Flutter recommendation)
- [Local storage]: Isar database (type-safe, relationships, web support via IndexedDB)
- [CoinGlass UI]: Light theme, orange #FF6B35 accent, 16dp rounded cards, Material 3

### Metis Review
**Identified Gaps** (addressed):
- [Isar web support]: Added verification task as Wave 1 first priority
- [Photo storage for web]: Decided: base64 in Isar for web, file path for iOS
- [Indicator units]: Confirmed mmol/L for glucose, full 4 lipid indicators
- [Validation rules]: Only name required, age auto-calculated from birthdate
- [Cascade delete]: Delete Person → cascade delete all HealthRecords
- [PDF limits]: 20MB max, password-protected PDFs rejected with error message

---

## Work Objectives

### Core Objective
创建一个Flutter健康管理APP，允许用户管理10+家庭成员的体检报告数据，支持PDF导入和手动录入。

### Concrete Deliverables
- `.sisyphus/plans/health-records-app.md` - This work plan
- `lib/` - Flutter application source code
- `lib/features/person/` - Person CRUD module
- `lib/features/health_report/` - Health report import module
- `lib/core/theme/` - Material 3 light theme
- `lib/data/` - Isar database schemas and repositories
- Working iOS app (iPhone simulator test)
- Working Web app (Chrome browser test)

### Definition of Done
- [ ] All features functional on iOS simulator and Chrome browser
- [ ] Can create, list, view, edit, delete Person with photo
- [ ] Can import PDF health reports with 3 indicator extraction
- [ ] Manual entry works as fallback when PDF parsing fails
- [ ] Data persists across app restarts
- [ ] All widget tests pass: `flutter test`
- [ ] No compiler errors: `flutter analyze`

### Must Have
- Person CRUD with 8 fields (name required, others optional)
- Health report import via PDF (text extraction + manual fallback)
- 3 health indicators: blood glucose (mmol/L), blood pressure (systolic/diastolic mmHg), blood lipids (TC/TG/HDL/LDL mmol/L)
- Isar database with proper relationships
- Riverpod 2.x state management
- go_router navigation
- Material 3 light theme (CoinGlass-inspired)
- iOS camera/photo permissions handled
- Web file picker functional

### Must NOT Have (Guardrails)
❌ Authentication / user accounts / login system
❌ Cloud sync / remote backup / API backend
❌ Data export (PDF, CSV, Excel generation)
❌ Health trend charts / visualizations / graphs
❌ Appointment reminders / push notifications
❌ Medication tracking
❌ Doctor profiles / hospital management
❌ Multi-language (i18n) support
❌ Dark mode toggle
❌ Data sharing features
❌ More than 3 health indicators in MVP
❌ More than 8 person fields
❌ Hospital-specific PDF parsers
❌ Repository interfaces "for future flexibility"
❌ Comprehensive error logging infrastructure
❌ Undo/redo functionality

---

## Verification Strategy (MANDATORY)

> **ZERO HUMAN INTERVENTION** — ALL verification is agent-executed. No exceptions.
> Acceptance criteria requiring "user manually tests/confirms" are FORBIDDEN.

### Test Decision
- **Infrastructure exists**: NO (new project)
- **Automated tests**: YES (Tests-after)
- **Framework**: Flutter test framework (`flutter test`)
- **Test types**: Unit tests (domain/logic), Widget tests (UI), Integration tests (data persistence)

### QA Policy
Every task MUST include agent-executed QA scenarios.
Evidence saved to `.sisyphus/evidence/task-{N}-{scenario-slug}.{ext}`.

- **Frontend/UI**: Use Playwright (playwright skill) — Navigate Flutter web, interact, assert DOM, screenshot
- **TUI/CLI**: Use interactive_bash (tmux) — Run flutter commands, send keystrokes, validate output
- **API/Backend**: Use Bash (curl) — Not applicable (local-only app)
- **Library/Module**: Use Bash (flutter test) — Run unit/widget tests, verify output

---

## Execution Strategy

### Parallel Execution Waves

> Maximize throughput by grouping independent tasks into parallel waves.
> Each wave completes before the next begins.
> Target: 5-7 tasks per wave.

```
Wave 1 (Start Immediately — foundation + scaffolding):
├── Task 1: Verify Isar Flutter Web Support [quick]
├── Task 2: Create Flutter Project Structure [quick]
├── Task 3: Setup Material 3 Light Theme [visual-engineering]
├── Task 4: Setup go_router Navigation Shell [quick]
├── Task 5: Define Data Schema v1 [quick]
└── Task 6: Generate Isar Adapters [quick]

Wave 2 (After Wave 1 — Data Layer):
├── Task 7: Implement Isar Person Repository [unspecified-high]
├── Task 8: Implement Isar Health Report Repository [unspecified-high]
├── Task 9: Implement PDF Text Extraction Service [deep]
├── Task 10: Implement Health Indicator Parser [deep]
└── Task 11: Implement Photo Storage Service [quick]

Wave 3 (After Wave 2 — Domain/State Layer):
├── Task 12: Implement Person Provider (Riverpod) [quick]
├── Task 13: Implement Health Report Provider (Riverpod) [quick]
├── Task 14: Implement Form Validation Logic [quick]
├── Task 15: Implement PDF Import State Machine [deep]
└── Task 16: Create Domain Entities [quick]

Wave 4 (After Wave 3 — UI Layer):
├── Task 17: Person List Page (Card Layout) [visual-engineering]
├── Task 18: Person Detail Page [visual-engineering]
├── Task 19: Person Create/Edit Form Page [visual-engineering]
├── Task 20: Photo Picker Integration [quick]
├── Task 21: Health Report List Page [visual-engineering]
├── Task 22: Health Report Import Flow (PDF picker + parsing) [visual-engineering]
├── Task 23: Health Report Manual Entry Form [visual-engineering]
└── Task 24: Health Report Detail Page [visual-engineering]

Wave 5 (After Wave 4 — Integration):
├── Task 25: Integration: Person Flow End-to-End [deep]
├── Task 26: Integration: Health Report Flow End-to-End [deep]
├── Task 27: Platform-specific: iOS Permissions Setup [quick]
├── Task 28: Platform-specific: Web File Picker Setup [quick]
└── Task 29: Add Unit Tests for Domain Layer [unspecified-high]

Wave 6 (After Wave 5 — Widget Tests):
├── Task 30: Add Widget Tests for Person UI [unspecified-high]
├── Task 31: Add Widget Tests for Health Report UI [unspecified-high]
├── Task 32: Add Integration Tests for Data Persistence [unspecified-high]
└── Task 33: Performance Test: 100+ Records List [quick]

Wave FINAL (After ALL tasks — 4 parallel reviews):
├── Task F1: Plan Compliance Audit (oracle)
├── Task F2: Code Quality Review (unspecified-high)
├── Task F3: Real Manual QA (unspecified-high)
└── Task F4: Scope Fidelity Check (deep)
-> Present results -> Get explicit user okay

Wave 7 (After Final Verification Approved — GitHub Integration):
├── Task 34: Initialize Git Repository [quick]
└── Task 35: Create GitHub Repository and Push [quick]
-> Output: GitHub repository URL

Critical Path: Task 1 → Task 5 → Task 7-10 → Task 12-15 → Task 17-24 → Task 25-26 → Task 29-33 → F1-F4 → Task 34-35
Parallel Speedup: ~60% faster than sequential
Max Concurrent: 6 (Waves 1 & 4)
```

### Dependency Matrix

| Task | Depends On | Blocks |
|------|------------|--------|
| 1 | — | 7, 8, 11 |
| 2 | — | 3, 4, 5 |
| 3 | 2 | 17, 18, 19, 21-24 |
| 4 | 2 | 17, 21 |
| 5 | 2 | 6, 7, 8 |
| 6 | 5 | 7, 8 |
| 7 | 5, 6, 1 | 12, 17-20, 25 |
| 8 | 5, 6, 1 | 13, 21-24, 26 |
| 9 | 2 | 10, 15, 22 |
| 10 | 9 | 15, 22, 23 |
| 11 | 1, 2 | 20 |
| 12 | 7, 16 | 17-20, 25 |
| 13 | 8, 16 | 21-24, 26 |
| 14 | 16 | 19, 23 |
| 15 | 9, 10 | 22 |
| 16 | 5 | 12, 13, 14 |
| 17 | 3, 4, 7, 12 | 25 |
| 18 | 3, 4, 7, 12 | 25 |
| 19 | 3, 14, 12 | 25 |
| 20 | 11, 17 | 25 |
| 21 | 3, 4, 8, 13 | 26 |
| 22 | 3, 9, 10, 15, 13 | 26 |
| 23 | 3, 14, 13 | 26 |
| 24 | 3, 8, 13 | 26 |
| 25 | 17-20 | F3 |
| 26 | 21-24 | F3 |
| 27 | 2 | F3 |
| 28 | 2 | F3 |
| 29 | 12-15 | F2 |
| 30 | 17-20 | F2 |
| 31 | 21-24 | F2 |
| 32 | 7, 8 | F2 |
| 33 | 7, 17 | F2 |
| 34 | F1-F4 approved | 35 |
| 35 | 34 + user provides repo URL | — |

### Agent Dispatch Summary

- **Wave 1**: **6 agents** — T1 → quick, T2 → quick, T3 → visual-engineering, T4 → quick, T5 → quick, T6 → quick
- **Wave 2**: **5 agents** — T7 → unspecified-high, T8 → unspecified-high, T9 → deep, T10 → deep, T11 → quick
- **Wave 3**: **5 agents** — T12 → quick, T13 → quick, T14 → quick, T15 → deep, T16 → quick
- **Wave 4**: **8 agents** — T17-T19 → visual-engineering, T20 → quick, T21-T24 → visual-engineering
- **Wave 5**: **5 agents** — T25-T26 → deep, T27-T28 → quick, T29 → unspecified-high
- **Wave 6**: **4 agents** — T30-T31 → unspecified-high, T32 → unspecified-high, T33 → quick
- **FINAL**: **4 agents** — F1 → oracle, F2 → unspecified-high, F3 → unspecified-high, F4 → deep
- **Wave 7**: **2 agents** — T34 → quick, T35 → quick (sequential, after user approval)

---

## TODOs

> Implementation + Test = ONE Task. Never separate.
> EVERY task MUST have: Recommended Agent Profile + Parallelization info + QA Scenarios.
> **A task WITHOUT QA Scenarios is INCOMPLETE. No exceptions.**

- [x] 1. Verify Isar Flutter Web Support

  **STATUS**: PARTIAL - Test project created but dependency resolution blocked. Proceeding with Isar 2.x in main project. See issues.md for details.

  **What to do**:
  - Create minimal Flutter web test project
  - Add Isar dependencies: `isar`, `isar_flutter_libs`
  - Test basic CRUD operations on Chrome
  - Verify IndexedDB storage works correctly
  - Document any limitations or issues found

  **Must NOT do**:
  - Build full app features
  - Add unnecessary dependencies
  - Create complex schemas

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Simple verification task, single focus
  - **Skills**: []
    - No specialized skills needed

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Tasks 2-6)
  - **Blocks**: 7, 8, 11
  - **Blocked By**: None

  **References**:
  - Official docs: `https://isar.dev/flutter.html` - Isar Flutter integration guide
  - Official docs: `https://isar.dev/web.html` - Isar web-specific considerations

  **Acceptance Criteria**:
  - [ ] Isar web demo project created
  - [ ] CRUD operations verified on Chrome
  - [ ] Performance acceptable (< 100ms for 10 records)
  - [ ] Findings documented in plan

  **QA Scenarios**:
  ```
  Scenario: Isar Web CRUD Verification
    Tool: Bash (flutter commands)
    Preconditions: Flutter SDK installed, Chrome available
    Steps:
      1. flutter create isar_web_test --platforms=web
      2. Add isar dependencies to pubspec.yaml
      3. flutter pub get
      4. Create simple Isar collection with 2 fields
      5. Run build_runner: flutter pub run build_runner build
      6. flutter run -d chrome
      7. In browser console, test insert + read + delete
    Expected Result: All CRUD operations work without errors
    Evidence: .sisyphus/evidence/task-1-isar-web-test.txt
  ```

  **Commit**: YES (groups with Wave 1)
  - Message: `test: verify isar web support`
  - Files: `test_projects/isar_web_test/`

- [x] 2. Create Flutter Project Structure

  **What to do**:
  - Run `flutter create health_records --platforms=ios,web`
  - Set up feature-first folder structure
  - Add dependencies: riverpod, riverpod_annotation, go_router, isar, isar_flutter_libs, pdf, image_picker, intl, freezed_annotation
  - Create AGENTS.md with build/lint/test commands
  - Initialize git repository

  **Must NOT do**:
  - Implement any features
  - Add dev dependencies for tests (yet)
  - Create complex configurations

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Standard project scaffolding
  - **Skills**: []
    - No specialized skills needed

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Tasks 1, 3-6)
  - **Blocks**: 3, 4, 5
  - **Blocked By**: None

  **References**:
  - Flutter docs: `https://docs.flutter.dev/app-architecture/guide` - Architecture patterns
  - Official docs: `https://docs.flutter.dev/platform-integration/platform-channels` - Platform considerations

  **Acceptance Criteria**:
  - [ ] Project created with iOS + Web support
  - [ ] Folder structure follows feature-first pattern
  - [ ] All dependencies added to pubspec.yaml
  - [ ] AGENTS.md created (150 lines, includes commands)
  - [ ] git init completed

  **QA Scenarios**:
  ```
  Scenario: Project Structure Verification
    Tool: Bash (flutter commands)
    Preconditions: Flutter SDK installed
    Steps:
      1. Verify project directory exists
      2. flutter pub get
      3. flutter analyze
      4. Check lib/ folder structure matches plan
      5. Verify AGENTS.md exists
    Expected Result: No analyzer errors, structure matches specification
    Evidence: .sisyphus/evidence/task-2-structure.txt

  Scenario: Dependency Verification
    Tool: Bash
    Preconditions: pubspec.yaml exists
    Steps:
      1. grep riverpod pubspec.yaml
      2. grep go_router pubspec.yaml
      3. grep isar pubspec.yaml
    Expected Result: All required dependencies present
    Evidence: .sisyphus/evidence/task-2-dependencies.txt
  ```

  **Commit**: YES (groups with Wave 1)
  - Message: `feat: initial project structure`
  - Files: All project files

- [x] 3. Setup Material 3 Light Theme

  **What to do**:
  - Create `lib/core/theme/app_theme.dart`
  - Define color scheme: Primary #FF6B35 (orange), Background #FFFFFF, Surface #F5F5F5, Text #212121
  - Configure Material 3 theme with CardTheme (16dp rounded corners)
  - Set typography: Inter font family (fallback to system fonts)
  - Create theme provider with Riverpod

  **Must NOT do**:
  - Add dark mode toggle
  - Create multiple theme variants
  - Add theme customization UI

  **Recommended Agent Profile**:
  - **Category**: `visual-engineering`
    - Reason: UI/styling task requiring design decisions
  - **Skills**: [`frontend-ui-ux`]
    - `frontend-ui-ux`: Theme design and Material 3 styling expertise

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Tasks 1-2, 4-6)
  - **Blocks**: 17, 18, 19, 21-24
  - **Blocked By**: Task 2

  **References**:
  - Flutter docs: `https://docs.flutter.dev/ui/material/material3` - Material 3 guide
  - CoinGlass colors: Primary orange #FF6B35 from research

  **Acceptance Criteria**:
  - [ ] AppTheme class created with Material 3 config
  - [ ] ColorScheme uses CoinGlass-inspired colors
  - [ ] CardTheme configured with 16dp rounded corners
  - [ ] Typography defined with Inter font references
  - [ ] Theme provider accessible via Riverpod

  **QA Scenarios**:
  ```
  Scenario: Theme Application Verification
    Tool: Bash (flutter commands)
    Preconditions: Theme file created
    Steps:
      1. Verify app_theme.dart exists
      2. Check ThemeMode.light is default
      3. Verify CardTheme borderRadius = BorderRadius.circular(16)
      4. Check primary color = Color(0xFFFF6B35)
    Expected Result: Theme file contains correct specifications
    Evidence: .sisyphus/evidence/task-3-theme-spec.txt

  Scenario: Theme Widget Test
    Tool: Bash (flutter test)
    Preconditions: Theme implementation complete
    Steps:
      1. Create test widget using AppTheme
      2. flutter test test/core/theme/app_theme_test.dart
    Expected Result: Theme test passes
    Evidence: .sisyphus/evidence/task-3-theme-test.txt
  ```

  **Commit**: YES (groups with Wave 1)
  - Message: `feat: material 3 light theme`
  - Files: `lib/core/theme/`

- [x] 4. Setup go_router Navigation Shell

  **What to do**:
  - Create `lib/core/router/app_router.dart`
  - Define routes: /persons, /persons/:id, /persons/new, /reports, /reports/:id, /reports/import
  - Setup ShellRoute with BottomNavigationBar for main routes
  - Configure redirect logic for initial landing
  - Create navigation provider with Riverpod

  **Must NOT do**:
  - Add authentication guards
  - Create complex nested routing
  - Add URL query parameter handling

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Standard navigation setup with known patterns
  - **Skills**: []
    - No specialized skills needed

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Tasks 1-3, 5-6)
  - **Blocks**: 17, 21
  - **Blocked By**: Task 2

  **References**:
  - Flutter docs: `https://docs.flutter.dev/ui/navigation` - Navigation guide
  - Package docs: `https://pub.dev/packages/go_router` - go_router API

  **Acceptance Criteria**:
  - [ ] AppRouter configured with go_router
  - [ ] ShellRoute with bottom navigation defined
  - [ ] Routes for persons and reports modules
  - [ ] Router provider accessible via Riverpod

  **QA Scenarios**:
  ```
  Scenario: Navigation Route Verification
    Tool: Bash (flutter commands)
    Preconditions: Router file created
    Steps:
      1. Verify app_router.dart exists
      2. Check /persons route defined
      3. Check /reports route defined
      4. Verify ShellRoute wraps main routes
    Expected Result: All routes defined correctly
    Evidence: .sisyphus/evidence/task-4-router-spec.txt

  Scenario: Navigation Test
    Tool: Bash (flutter test)
    Preconditions: Router implementation complete
    Steps:
      1. Create test verifying route navigation
      2. flutter test test/core/router/app_router_test.dart
    Expected Result: Navigation test passes
    Evidence: .sisyphus/evidence/task-4-router-test.txt
  ```

  **Commit**: YES (groups with Wave 1)
  - Message: `feat: go_router navigation setup`
  - Files: `lib/core/router/`

- [x] 5. Define Data Schema v1

  **What to do**:
  - Create Isar schemas in `lib/data/models/`
  - Person: id, name (required), gender, birthDate, idNumber, phone, photoPath, relationship
  - HealthReport: id, personId (link), reportDate, source (pdf/manual), pdfPath
  - HealthIndicator: id, reportId (link), type (glucose/pressure/lipid), value, unit, isAbnormal
  - Define relationships: Person.linksTo(HealthReports), HealthReport.linksTo(Indicators)
  - Document schema decisions for future migrations

  **Must NOT do**:
  - Add fields beyond the 8 specified for Person
  - Add health indicators beyond glucose/pressure/lipid
  - Create abstract repository interfaces

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Schema definition is straightforward configuration
  - **Skills**: []
    - No specialized skills needed

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Tasks 1-4, 6)
  - **Blocks**: 6, 7, 8
  - **Blocked By**: Task 2

  **References**:
  - Isar docs: `https://isar.dev/schema.html` - Schema definition guide
  - Isar docs: `https://isar.dev/relationships.html` - Relationship setup

  **Acceptance Criteria**:
  - [ ] Person schema with 8 fields defined
  - [ ] HealthReport schema with relationships defined
  - [ ] HealthIndicator schema with 3 indicator types
  - [ ] Relationships properly linked
  - [ ] Schema documentation created

  **QA Scenarios**:
  ```
  Scenario: Schema Compilation Verification
    Tool: Bash (dart analyze)
    Preconditions: Schema files created
    Steps:
      1. Verify person.dart exists
      2. Verify health_report.dart exists
      3. Verify health_indicator.dart exists
      4. Check @collection annotations present
      5. Check links defined correctly
    Expected Result: Schema files have correct Isar annotations
    Evidence: .sisyphus/evidence/task-5-schema-spec.txt
  ```

  **Commit**: YES (groups with Wave 1)
  - Message: `feat: isar data schema v1`
  - Files: `lib/data/models/`

- [x] 6. Generate Isar Adapters

  **What to do**:
  - Add build_runner dependencies: `build_runner`, `isar_generator`
  - Run `flutter pub run build_runner build --delete-conflicting-outputs`
  - Verify generated .isar files exist
  - Create Isar initialization service in `lib/core/services/isar_service.dart`

  **Must NOT do**:
  - Manually edit generated files
  - Add custom serialization logic
  - Skip build_runner step

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Standard code generation task
  - **Skills**: []
    - No specialized skills needed

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Tasks 1-5)
  - **Blocks**: 7, 8
  - **Blocked By**: Task 5

  **References**:
  - Isar docs: `https://isar.dev/quickstart.html` - Build runner setup

  **Acceptance Criteria**:
  - [ ] build_runner generates adapter files
  - [ ] Generated files compile without errors
  - [ ] IsarService created for database initialization
  - [ ] Database opens successfully with all schemas

  **QA Scenarios**:
  ```
  Scenario: Adapter Generation Verification
    Tool: Bash (flutter commands)
    Preconditions: Schemas defined, dependencies added
    Steps:
      1. flutter pub get
      2. flutter pub run build_runner build --delete-conflicting-outputs
      3. Check .isar files exist in lib/data/models/
      4. flutter analyze
    Expected Result: Build succeeds, no analyzer errors
    Evidence: .sisyphus/evidence/task-6-adapters-gen.txt

  Scenario: Isar Initialization Test
    Tool: Bash (flutter test)
    Preconditions: IsarService created
    Steps:
      1. Create test opening Isar database
      2. flutter test test/core/services/isar_service_test.dart
    Expected Result: Database opens successfully
    Evidence: .sisyphus/evidence/task-6-isar-init.txt
  ```

  **Commit**: YES (groups with Wave 1)
  - Message: `feat: isar adapters generated`
  - Files: Generated adapter files, `lib/core/services/isar_service.dart`

- [x] 7. Implement Isar Person Repository

  **What to do**:
  - Create `lib/data/repositories/person_repository.dart`
  - Implement CRUD: insert, getAll, getById, update, delete (cascade to reports)
  - Add search/filter: by name, by relationship type
  - Handle photo path storage (empty string if no photo)
  - Implement pagination for large lists (10+ persons)

  **Must NOT do**:
  - Create abstract repository interface
  - Add caching layer
  - Implement soft delete

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
    - Reason: Data layer implementation with business logic
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2 (with Tasks 8-11)
  - **Blocks**: 12, 17-20, 25
  - **Blocked By**: Task 5, Task 6, Task 1

  **References**:
  - Isar docs: `https://isar.dev/crud.html` - CRUD operations
  - Isar docs: `https://isar.dev/queries.html` - Query/filter syntax
  - Pattern: `lib/data/models/person.dart` - Schema to implement against

  **Acceptance Criteria**:
  - [ ] PersonRepository class created
  - [ ] All CRUD operations implemented
  - [ ] Delete cascades to associated HealthReports
  - [ ] Search by name works
  - [ ] Filter by relationship works

  **QA Scenarios**:
  ```
  Scenario: Person CRUD Operations Test
    Tool: Bash (flutter test)
    Preconditions: Isar initialized
    Steps:
      1. Create test inserting Person with name="张三"
      2. Query all persons, verify count=1
      3. Query by id, verify name matches
      4. Update name to="李四"
      5. Verify update persisted
      6. Delete person
      7. Verify count=0
    Expected Result: All CRUD operations pass
    Evidence: .sisyphus/evidence/task-7-person-crud.txt

  Scenario: Cascade Delete Verification
    Tool: Bash (flutter test)
    Preconditions: Person with HealthReports exists
    Steps:
      1. Create Person
      2. Create 2 HealthReports linked to Person
      3. Delete Person
      4. Query HealthReports, verify count=0
    Expected Result: HealthReports deleted when Person deleted
    Evidence: .sisyphus/evidence/task-7-cascade-delete.txt
  ```

  **Commit**: YES (groups with Wave 2)
  - Message: `feat: person repository implementation`
  - Files: `lib/data/repositories/person_repository.dart`

- [x] 8. Implement Isar Health Report Repository

  **What to do**:
  - Create `lib/data/repositories/health_report_repository.dart`
  - Implement CRUD: insert, getAll, getById, getByPersonId, update, delete
  - Link reports to Person via personId
  - Store PDF path when imported from file
  - Store source type (pdf/manual)
  - Implement indicators sub-collection access

  **Must NOT do**:
  - Create abstract repository interface
  - Add PDF parsing logic (separate task)
  - Implement report sharing

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
    - Reason: Data layer implementation with relationships
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2 (with Tasks 7, 9-11)
  - **Blocks**: 13, 21-24, 26
  - **Blocked By**: Task 5, Task 6, Task 1

  **References**:
  - Isar docs: `https://isar.dev/crud.html` - CRUD operations
  - Pattern: `lib/data/models/health_report.dart` - Schema to implement
  - Pattern: `lib/data/models/health_indicator.dart` - Indicator schema

  **Acceptance Criteria**:
  - [ ] HealthReportRepository created
  - [ ] CRUD operations implemented
  - [ ] getByPersonId returns all reports for a person
  - [ ] Indicator links work correctly
  - [ ] PDF path stored correctly

  **QA Scenarios**:
  ```
  Scenario: Health Report CRUD Test
    Tool: Bash (flutter test)
    Preconditions: Person exists, Isar initialized
    Steps:
      1. Create Person
      2. Create HealthReport with personId
      3. Query by personId, verify count=1
      4. Update report source to "manual"
      5. Delete report
      6. Verify count=0
    Expected Result: All CRUD operations pass
    Evidence: .sisyphus/evidence/task-8-report-crud.txt

  Scenario: Report-Person Link Verification
    Tool: Bash (flutter test)
    Preconditions: Person and HealthReport exist
    Steps:
      1. Create Person
      2. Create 3 HealthReports linked to same Person
      3. Query reports by personId
      4. Verify all 3 returned
    Expected Result: Link relationship works correctly
    Evidence: .sisyphus/evidence/task-8-link-test.txt
  ```

  **Commit**: YES (groups with Wave 2)
  - Message: `feat: health report repository implementation`
  - Files: `lib/data/repositories/health_report_repository.dart`

- [x] 9. Implement PDF Text Extraction Service

  **What to do**:
  - Create `lib/core/services/pdf_extraction_service.dart`
  - Use `pdf` package to extract text from PDF pages
  - Handle multi-page PDFs
  - Handle PDF read errors gracefully (return empty string)
  - Limit file size check (reject > 20MB)
  - Test with sample health report PDFs

  **Must NOT do**:
  - Implement indicator parsing (separate task)
  - Add OCR for image-based PDFs
  - Handle password-protected PDFs

  **Recommended Agent Profile**:
  - **Category**: `deep`
    - Reason: Complex PDF handling with error cases
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2 (with Tasks 7-8, 10-11)
  - **Blocks**: 10, 15, 22
  - **Blocked By**: Task 2

  **References**:
  - Package docs: `https://pub.dev/packages/pdf` - PDF text extraction API
  - Pattern: `https://pub.dev/documentation/pdf/latest/pdf/PdfDocument-class.html` - PdfDocument usage

  **Acceptance Criteria**:
  - [ ] PdfExtractionService created
  - [ ] Text extraction from PDF pages works
  - [ ] File size validation implemented
  - [ ] Error handling for corrupted PDFs
  - [ ] Returns extracted text or empty on failure

  **QA Scenarios**:
  ```
  Scenario: PDF Text Extraction Test
    Tool: Bash (flutter test)
    Preconditions: Sample PDF file available
    Steps:
      1. Create test PDF file with sample text
      2. Call extractText() with PDF path
      3. Verify text content returned
      4. Verify no exceptions thrown
    Expected Result: Text successfully extracted
    Evidence: .sisyphus/evidence/task-9-pdf-extract.txt

  Scenario: Large PDF Rejection Test
    Tool: Bash (flutter test)
    Preconditions: Large PDF (> 20MB)
    Steps:
      1. Create mock large PDF scenario
      2. Call extractText() with large file path
      3. Verify returns empty with error flag
    Expected Result: Large files rejected gracefully
    Evidence: .sisyphus/evidence/task-9-size-limit.txt

  Scenario: Corrupted PDF Handling
    Tool: Bash (flutter test)
    Preconditions: Invalid/corrupted PDF
    Steps:
      1. Create corrupted PDF file
      2. Call extractText()
      3. Verify returns empty, no crash
    Expected Result: Corrupted PDF handled gracefully
    Evidence: .sisyphus/evidence/task-9-corrupt-pdf.txt
  ```

  **Commit**: YES (groups with Wave 2)
  - Message: `feat: pdf text extraction service`
  - Files: `lib/core/services/pdf_extraction_service.dart`

- [x] 10. Implement Health Indicator Parser

  **What to do**:
  - Create `lib/core/services/indicator_parser_service.dart`
  - Parse text for 3 indicators:
    - Blood glucose: regex for "血糖" + mmol/L value
    - Blood pressure: regex for "血压" + systolic/diastolic (120/80 format)
    - Blood lipids: regex for "胆固醇/甘油三酯/HDL/LDL" + values
  - Return structured Indicator objects with type, value, unit
  - Mark abnormal values based on reference ranges
  - Return partial results if some indicators not found

  **Must NOT do**:
  - Parse indicators beyond glucose/pressure/lipid
  - Add hospital-specific template matching
  - Require all indicators to be found

  **Recommended Agent Profile**:
  - **Category**: `deep`
    - Reason: Regex parsing logic with Chinese text patterns
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2 (with Tasks 7-9, 11)
  - **Blocks**: 15, 22, 23
  - **Blocked By**: Task 9

  **References**:
  - Sample text patterns (Chinese medical reports):
    - "空腹血糖: 5.6 mmol/L"
    - "血压: 120/80 mmHg"
    - "总胆固醇(TC): 4.5 mmol/L"
    - "甘油三酯(TG): 1.2 mmol/L"

  **Acceptance Criteria**:
  - [ ] IndicatorParserService created
  - [ ] Blood glucose parsed correctly (mmol/L)
  - [ ] Blood pressure parsed (systolic/diastolic mmHg)
  - [ ] All 4 lipid indicators parsed (TC/TG/HDL/LDL)
  - [ ] Abnormal values flagged
  - [ ] Partial results returned when indicators missing

  **QA Scenarios**:
  ```
  Scenario: Glucose Parsing Test
    Tool: Bash (flutter test)
    Preconditions: Parser service created
    Steps:
      1. Input text: "空腹血糖: 5.6 mmol/L"
      2. Call parseGlucose()
      3. Verify value=5.6, unit="mmol/L"
      4. Verify isAbnormal=false (normal range 3.9-6.1)
    Expected Result: Glucose parsed correctly
    Evidence: .sisyphus/evidence/task-10-glucose-parse.txt

  Scenario: Blood Pressure Parsing Test
    Tool: Bash (flutter test)
    Preconditions: Parser service created
    Steps:
      1. Input text: "血压: 120/80 mmHg"
      2. Call parseBloodPressure()
      3. Verify systolic=120, diastolic=80
      4. Verify isAbnormal=false
    Expected Result: Blood pressure parsed correctly
    Evidence: .sisyphus/evidence/task-10-pressure-parse.txt

  Scenario: Lipid Parsing Test
    Tool: Bash (flutter test)
    Preconditions: Parser service created
    Steps:
      1. Input text with TC/TG/HDL/LDL values
      2. Call parseLipids()
      3. Verify all 4 values extracted
      4. Verify units="mmol/L"
    Expected Result: All lipid indicators parsed
    Evidence: .sisyphus/evidence/task-10-lipid-parse.txt

  Scenario: Partial Parsing Test
    Tool: Bash (flutter test)
    Preconditions: Parser service created
    Steps:
      1. Input text with only glucose (missing other indicators)
      2. Call parseAll()
      3. Verify glucose returned, others null
    Expected Result: Partial results returned without error
    Evidence: .sisyphus/evidence/task-10-partial-parse.txt
  ```

  **Commit**: YES (groups with Wave 2)
  - Message: `feat: health indicator parser service`
  - Files: `lib/core/services/indicator_parser_service.dart`

- [x] 11. Implement Photo Storage Service

  **What to do**:
  - Create `lib/core/services/photo_storage_service.dart`
  - iOS: Save photos to app documents directory, store path in Isar
  - Web: Convert photo to base64, store in Isar (no filesystem access)
  - Use `image_picker` for camera/gallery access
  - Handle permission requests gracefully
  - Generate unique filenames with timestamp
  - Delete photos when Person deleted

  **Must NOT do**:
  - Implement photo compression (use original)
  - Add photo editing features
  - Support cloud photo storage

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Standard file storage pattern
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2 (with Tasks 7-10)
  - **Blocks**: 20
  - **Blocked By**: Task 1, Task 2

  **References**:
  - Package docs: `https://pub.dev/packages/image_picker` - Image picker API
  - Flutter docs: `https://docs.flutter.dev/platform-integration/platform-channels` - Platform considerations

  **Acceptance Criteria**:
  - [ ] PhotoStorageService created
  - [ ] iOS: Photos saved to documents directory
  - [ ] Web: Photos converted to base64
  - [ ] Unique filenames generated
  - [ ] Photo deletion handled

  **QA Scenarios**:
  ```
  Scenario: Photo Save Test (iOS pattern)
    Tool: Bash (flutter test)
    Preconditions: Service created, mock image data
    Steps:
      1. Create mock image bytes
      2. Call savePhoto() with image data
      3. Verify returns valid path string
      4. Verify path format: "/documents/photos/timestamp.jpg"
    Expected Result: Photo saved, path returned
    Evidence: .sisyphus/evidence/task-11-photo-save.txt

  Scenario: Base64 Conversion Test (Web pattern)
    Tool: Bash (flutter test)
    Preconditions: Service created, mock image
    Steps:
      1. Create mock image bytes
      2. Call savePhoto() with web=true flag
      3. Verify returns base64 string
    Expected Result: Base64 string returned for web
    Evidence: .sisyphus/evidence/task-11-base64.txt
  ```

  **Commit**: YES (groups with Wave 2)
  - Message: `feat: photo storage service`
  - Files: `lib/core/services/photo_storage_service.dart`

- [x] 12. Implement Person Provider (Riverpod)

  **What to do**:
  - Create `lib/features/person/providers/person_provider.dart`
  - Use Riverpod code generation (@riverpod annotation)
  - Provider methods: persons list, selected person, create/update/delete
  - Auto-refresh list after CRUD operations (ref.invalidateSelf)
  - Add loading/error states handling
  - Connect to PersonRepository

  **Must NOT do**:
  - Add caching logic (Riverpod handles this)
  - Create complex state machine
  - Add undo/redo functionality

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Standard Riverpod provider pattern
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 3 (with Tasks 13-16)
  - **Blocks**: 17-20, 25
  - **Blocked By**: Task 7, Task 16

  **References**:
  - Riverpod docs: `https://riverpod.dev/` - Provider patterns
  - Pattern: `lib/data/repositories/person_repository.dart` - Repository to connect

  **Acceptance Criteria**:
  - [ ] PersonProvider created with @riverpod
  - [ ] List provider returns all persons
  - [ ] CRUD operations update list automatically
  - [ ] Loading/error states handled
  - [ ] Connected to repository

  **QA Scenarios**:
  ```
  Scenario: Provider CRUD Test
    Tool: Bash (flutter test)
    Preconditions: Provider created, mock repository
    Steps:
      1. Create Person with provider
      2. Verify list provider updates
      3. Update person via provider
      4. Verify changes reflected
      5. Delete via provider
      6. Verify list empty
    Expected Result: Provider state updates correctly
    Evidence: .sisyphus/evidence/task-12-provider-crud.txt
  ```

  **Commit**: YES (groups with Wave 3)
  - Message: `feat: person riverpod provider`
  - Files: `lib/features/person/providers/`

- [x] 13. Implement Health Report Provider (Riverpod)

  **What to do**:
  - Create `lib/features/health_report/providers/health_report_provider.dart`
  - Provider methods: reports list, reports by person, selected report
  - Add PDF import state machine (pending → parsing → success/failed)
  - Manual entry state handling
  - Auto-refresh after operations
  - Connect to HealthReportRepository

  **Must NOT do**:
  - Add complex import orchestration (separate task)
  - Create report sharing logic
  - Add chart/visualization state

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Standard Riverpod provider pattern
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 3 (with Tasks 12, 14-16)
  - **Blocks**: 21-24, 26
  - **Blocked By**: Task 8, Task 16

  **References**:
  - Riverpod docs: `https://riverpod.dev/` - Provider patterns
  - Pattern: `lib/data/repositories/health_report_repository.dart` - Repository to connect

  **Acceptance Criteria**:
  - [ ] HealthReportProvider created
  - [ ] List and filtered providers working
  - [ ] PDF import state handled
  - [ ] Manual entry state handled
  - [ ] Connected to repository

  **QA Scenarios**:
  ```
  Scenario: Report Provider Test
    Tool: Bash (flutter test)
    Preconditions: Provider created
    Steps:
      1. Create HealthReport via provider
      2. Query by personId
      3. Verify list updates
      4. Delete report
      5. Verify list empty
    Expected Result: Provider CRUD works correctly
    Evidence: .sisyphus/evidence/task-13-report-provider.txt
  ```

  **Commit**: YES (groups with Wave 3)
  - Message: `feat: health report riverpod provider`
  - Files: `lib/features/health_report/providers/`

- [x] 14. Implement Form Validation Logic

  **What to do**:
  - Create `lib/core/utils/form_validators.dart`
  - Validators for Person: name (required, min 2 chars), phone (optional, format check), birthDate (not future)
  - Validators for HealthReport: reportDate required
  - Validators for indicators: value must be positive number
  - Return validation errors as strings
  - Integrate with Flutter Form widget

  **Must NOT do**:
  - Add ID number format validation (country-specific)
  - Add comprehensive phone validation (store as string)
  - Create custom validation widgets

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Utility functions with simple logic
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 3 (with Tasks 12-13, 15-16)
  - **Blocks**: 19, 23
  - **Blocked By**: Task 16

  **References**:
  - Flutter docs: `https://docs.flutter.dev/cookbook/forms/validation` - Form validation patterns

  **Acceptance Criteria**:
  - [ ] FormValidators class created
  - [ ] Name validator: required, min 2 chars
  - [ ] Phone validator: optional, basic format
  - [ ] BirthDate validator: not future date
  - [ ] Value validators: positive numbers

  **QA Scenarios**:
  ```
  Scenario: Name Validation Test
    Tool: Bash (flutter test)
    Preconditions: Validators created
    Steps:
      1. Call validateName("")
      2. Verify returns "姓名不能为空"
      3. Call validateName("张")
      4. Verify returns "姓名至少2个字符"
      5. Call validateName("张三")
      6. Verify returns null (valid)
    Expected Result: Validation rules enforced
    Evidence: .sisyphus/evidence/task-14-name-validation.txt

  Scenario: BirthDate Validation Test
    Tool: Bash (flutter test)
    Preconditions: Validators created
    Steps:
      1. Call validateBirthDate(DateTime.now().add(days: 1))
      2. Verify returns error
      3. Call validateBirthDate(DateTime.now().subtract(years: 30))
      4. Verify returns null (valid)
    Expected Result: Future dates rejected
    Evidence: .sisyphus/evidence/task-14-date-validation.txt
  ```

  **Commit**: YES (groups with Wave 3)
  - Message: `feat: form validation utilities`
  - Files: `lib/core/utils/form_validators.dart`

- [x] 15. Implement PDF Import State Machine

  **What to do**:
  - Create `lib/features/health_report/providers/import_state_provider.dart`
  - States: idle → fileSelected → extracting → parsing → saving → success/error
  - Handle each state transition with proper UI feedback
  - On parse failure: transition to manualEntry state
  - Save parsed indicators to HealthIndicator collection
  - Reset state after completion

  **Must NOT do**:
  - Add retry logic for failed imports
  - Create complex progress tracking
  - Add batch import support

  **Recommended Agent Profile**:
  - **Category**: `deep`
    - Reason: State machine with multiple transitions
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 3 (with Tasks 12-14, 16)
  - **Blocks**: 22
  - **Blocked By**: Task 9, Task 10

  **References**:
  - Pattern: `lib/core/services/pdf_extraction_service.dart` - PDF extraction
  - Pattern: `lib/core/services/indicator_parser_service.dart` - Indicator parsing

  **Acceptance Criteria**:
  - [ ] ImportStateProvider created
  - [ ] All state transitions defined
  - [ ] Parse failure → manualEntry transition
  - [ ] Success → report saved transition
  - [ ] Error states handled

  **QA Scenarios**:
  ```
  Scenario: Successful Import Flow
    Tool: Bash (flutter test)
    Preconditions: Services working, valid PDF
    Steps:
      1. Start in idle state
      2. Select PDF file → fileSelected
      3. Extract text → extracting → parsing
      4. Parse indicators → saving
      5. Save report → success
    Expected Result: Full flow completes successfully
    Evidence: .sisyphus/evidence/task-15-success-flow.txt

  Scenario: Parse Failure → Manual Entry
    Tool: Bash (flutter test)
    Preconditions: Services working, invalid PDF
    Steps:
      1. Start import
      2. PDF extraction succeeds
      3. Parsing fails (no indicators found)
      4. Transition to manualEntry state
    Expected Result: Manual entry fallback triggered
    Evidence: .sisyphus/evidence/task-15-parse-fallback.txt
  ```

  **Commit**: YES (groups with Wave 3)
  - Message: `feat: pdf import state machine`
  - Files: `lib/features/health_report/providers/import_state_provider.dart`

- [x] 16. Create Domain Entities

  **What to do**:
  - Create `lib/domain/entities/person_entity.dart`
  - Create `lib/domain/entities/health_report_entity.dart`
  - Create `lib/domain/entities/indicator_entity.dart`
  - Define clean domain models separate from Isar schemas
  - Add computed properties: age from birthDate, status from indicators
  - Define relationship between entities

  **Must NOT do**:
  - Add business logic beyond computed properties
  - Create complex inheritance hierarchies
  - Add serialization logic

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Entity definition is straightforward
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 3 (with Tasks 12-15)
  - **Blocks**: 12, 13, 14
  - **Blocked By**: Task 5

  **References**:
  - Flutter docs: `https://docs.flutter.dev/app-architecture/guide` - Domain layer patterns

  **Acceptance Criteria**:
  - [ ] PersonEntity created with age computed property
  - [ ] HealthReportEntity created
  - [ ] IndicatorEntity created with status computed
  - [ ] Entities separated from Isar models

  **QA Scenarios**:
  ```
  Scenario: Age Calculation Test
    Tool: Bash (flutter test)
    Preconditions: PersonEntity created
    Steps:
      1. Create PersonEntity with birthDate=30 years ago
      2. Access age property
      3. Verify age=30
    Expected Result: Age computed correctly
    Evidence: .sisyphus/evidence/task-16-age-calc.txt

  Scenario: Indicator Status Test
    Tool: Bash (flutter test)
    Preconditions: IndicatorEntity created
    Steps:
      1. Create IndicatorEntity with glucose=7.0 (high)
      2. Access status property
      3. Verify status="异常"
    Expected Result: Status computed from reference ranges
    Evidence: .sisyphus/evidence/task-16-indicator-status.txt
  ```

  **Commit**: YES (groups with Wave 3)
  - Message: `feat: domain entities`
  - Files: `lib/domain/entities/`

- [x] 17. Person List Page (Card Layout)

  **What to do**:
  - Create `lib/features/person/ui/pages/person_list_page.dart`
  - Display persons as data cards (CoinGlass style)
  - Card content: photo thumbnail, name, relationship, age
  - Empty state: "暂无家人信息，点击添加"
  - Floating action button for add new person
  - Tap card → navigate to detail page
  - Pull-to-refresh for list update

  **Must NOT do**:
  - Add search/filter UI (simple list only)
  - Add pagination indicator
  - Add bulk operations

  **Recommended Agent Profile**:
  - **Category**: `visual-engineering`
    - Reason: UI implementation with specific design patterns
  - **Skills**: [`frontend-ui-ux`]
    - `frontend-ui-ux`: CoinGlass card layout styling

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 4 (with Tasks 18-24)
  - **Blocks**: 25
  - **Blocked By**: Task 3, Task 4, Task 7, Task 12

  **References**:
  - Pattern: `lib/core/theme/app_theme.dart` - CardTheme with 16dp rounded corners
  - Pattern: CoinGlass design: Full-width cards with photo-left layout

  **Acceptance Criteria**:
  - [ ] PersonListPage created
  - [ ] Cards display person info correctly
  - [ ] Empty state shown when no persons
  - [ ] FAB navigates to create page
  - [ ] Card tap navigates to detail

  **QA Scenarios**:
  ```
  Scenario: Person List Display (Web)
    Tool: Playwright (playwright skill)
    Preconditions: Flutter web running, 3 persons in database
    Steps:
      1. Navigate to http://localhost:PORT
      2. Wait for person list page
      3. Verify 3 cards displayed
      4. Verify each card shows name, relationship
      5. Verify photo thumbnails visible
    Expected Result: List displays all persons as cards
    Evidence: .sisyphus/evidence/task-17-list-web.png

  Scenario: Empty State Display
    Tool: Playwright (playwright skill)
    Preconditions: No persons in database
    Steps:
      1. Navigate to person list page
      2. Verify "暂无家人信息" text visible
      3. Verify FAB visible for adding
    Expected Result: Empty state with helpful message
    Evidence: .sisyphus/evidence/task-17-empty-state.png

  Scenario: Card Navigation
    Tool: Playwright (playwright skill)
    Preconditions: Person exists
    Steps:
      1. Click on person card
      2. Verify navigation to detail page
      3. Verify correct person ID in URL
    Expected Result: Tap navigates to detail
    Evidence: .sisyphus/evidence/task-17-card-nav.png
  ```

  **Commit**: YES (groups with Wave 4)
  - Message: `feat: person list page with card layout`
  - Files: `lib/features/person/ui/pages/person_list_page.dart`

- [x] 18. Person Detail Page

  **What to do**:
  - Create `lib/features/person/ui/pages/person_detail_page.dart`
  - Display all 8 fields: photo (large), name, gender, birthDate, age (computed), idNumber, phone, relationship
  - Edit button in AppBar → navigate to edit page
  - Delete button with confirmation dialog
  - List of health reports for this person (clickable)
  - Back navigation to list

  **Must NOT do**:
  - Add inline editing
  - Add report creation from detail page
  - Add data export button

  **Recommended Agent Profile**:
  - **Category**: `visual-engineering`
    - Reason: Detail page UI with multiple sections
  - **Skills**: [`frontend-ui-ux`]
    - `frontend-ui-ux`: Detail page layout design

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 4 (with Tasks 17, 19-24)
  - **Blocks**: 25
  - **Blocked By**: Task 3, Task 4, Task 7, Task 12

  **References**:
  - Pattern: `lib/core/theme/app_theme.dart` - Theme colors and typography

  **Acceptance Criteria**:
  - [ ] PersonDetailPage created
  - [ ] All 8 fields displayed
  - [ ] Photo displayed prominently
  - [ ] Edit/Delete buttons functional
  - [ ] Health reports list shown

  **QA Scenarios**:
  ```
  Scenario: Detail Page Display (Web)
    Tool: Playwright (playwright skill)
    Preconditions: Person with all fields exists
    Steps:
      1. Navigate to person detail page
      2. Verify photo visible
      3. Verify all text fields displayed
      4. Verify age computed and shown
      5. Verify edit/delete buttons present
    Expected Result: All person info displayed
    Evidence: .sisyphus/evidence/task-18-detail-web.png

  Scenario: Delete Confirmation
    Tool: Playwright (playwright skill)
    Preconditions: Person exists
    Steps:
      1. Click delete button
      2. Verify confirmation dialog appears
      3. Click confirm
      4. Verify navigated back to list
      5. Verify person removed from list
    Expected Result: Delete with confirmation works
    Evidence: .sisyphus/evidence/task-18-delete-confirm.png

  Scenario: Reports List on Detail
    Tool: Playwright (playwright skill)
    Preconditions: Person with 2 health reports
    Steps:
      1. Navigate to person detail
      2. Verify reports section visible
      3. Verify 2 reports listed
      4. Click report item
      5. Verify navigation to report detail
    Expected Result: Reports accessible from person detail
    Evidence: .sisyphus/evidence/task-18-reports-list.png
  ```

  **Commit**: YES (groups with Wave 4)
  - Message: `feat: person detail page`
  - Files: `lib/features/person/ui/pages/person_detail_page.dart`

- [x] 19. Person Create/Edit Form Page

  **What to do**:
  - Create `lib/features/person/ui/pages/person_form_page.dart`
  - Form fields: name (required), gender (dropdown), birthDate (date picker), idNumber, phone, relationship (dropdown), photo picker button
  - Save/Cancel buttons
  - Validation using FormValidators
  - Photo picker integration (camera/gallery)
  - Edit mode: pre-populate existing values

  **Must NOT do**:
  - Add photo editing (crop/filter)
  - Add advanced validation (ID format)
  - Add duplicate detection

  **Recommended Agent Profile**:
  - **Category**: `visual-engineering`
    - Reason: Form UI with multiple input types
  - **Skills**: [`frontend-ui-ux`]
    - `frontend-ui-ux`: Form layout and validation UX

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 4 (with Tasks 17-18, 20-24)
  - **Blocks**: 25
  - **Blocked By**: Task 3, Task 14, Task 12

  **References**:
  - Flutter docs: `https://docs.flutter.dev/cookbook/forms/validation` - Form patterns
  - Pattern: `lib/core/utils/form_validators.dart` - Validators to use

  **Acceptance Criteria**:
  - [ ] PersonFormPage created
  - [ ] All form fields implemented
  - [ ] Name validation (required)
  - [ ] Date picker for birthDate
  - [ ] Photo picker button
  - [ ] Edit mode pre-populates values

  **QA Scenarios**:
  ```
  Scenario: Create Person Form (Web)
    Tool: Playwright (playwright skill)
    Preconditions: Form page accessible
    Steps:
      1. Navigate to create person page
      2. Enter name="测试用户"
      3. Select gender="男"
      4. Select birthDate (30 years ago)
      5. Enter phone="13800138000"
      6. Select relationship="配偶"
      7. Click save
      8. Verify success, navigate to list
      9. Verify new person appears
    Expected Result: Person created successfully
    Evidence: .sisyphus/evidence/task-19-create-form.png

  Scenario: Name Validation Error
    Tool: Playwright (playwright skill)
    Preconditions: Form page accessible
    Steps:
      1. Navigate to create form
      2. Leave name empty
      3. Click save
      4. Verify validation error shown
      5. Verify form not submitted
    Expected Result: Validation prevents empty name
    Evidence: .sisyphus/evidence/task-19-name-error.png

  Scenario: Edit Existing Person
    Tool: Playwright (playwright skill)
    Preconditions: Person exists
    Steps:
      1. Navigate to person detail
      2. Click edit button
      3. Verify form pre-populated with existing values
      4. Change name
      5. Click save
      6. Verify changes reflected in detail page
    Expected Result: Edit mode works correctly
    Evidence: .sisyphus/evidence/task-19-edit-mode.png
  ```

  **Commit**: YES (groups with Wave 4)
  - Message: `feat: person create/edit form page`
  - Files: `lib/features/person/ui/pages/person_form_page.dart`

- [x] 20. Photo Picker Integration

  **What to do**:
  - Create `lib/features/person/ui/widgets/photo_picker_widget.dart`
  - Button to capture photo (camera) or select from gallery
  - Display selected photo in form (thumbnail)
  - iOS: Use image_picker with camera/gallery options
  - Web: Use file input for image selection
  - Handle permission requests gracefully
  - Photo preview before save

  **Must NOT do**:
  - Add photo editing (crop/rotate)
  - Add photo filters
  - Support multiple photos per person

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Widget integration with existing service
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 4 (with Tasks 17-19, 21-24)
  - **Blocks**: 25
  - **Blocked By**: Task 11, Task 17

  **References**:
  - Package docs: `https://pub.dev/packages/image_picker` - Image picker API
  - Pattern: `lib/core/services/photo_storage_service.dart` - Storage service

  **Acceptance Criteria**:
  - [ ] PhotoPickerWidget created
  - [ ] Camera option available (iOS)
  - [ ] Gallery option available (iOS)
  - [ ] File picker available (Web)
  - [ ] Photo preview displayed
  - [ ] Permissions handled

  **QA Scenarios**:
  ```
  Scenario: Photo Picker Display
    Tool: Bash (flutter test)
    Preconditions: Widget created
    Steps:
      1. Verify photo picker button visible
      2. Verify placeholder when no photo
    Expected Result: Picker UI rendered correctly
    Evidence: .sisyphus/evidence/task-20-picker-ui.txt

  Scenario: Photo Selection (Web)
    Tool: Playwright (playwright skill)
    Preconditions: Web app running, form page open
    Steps:
      1. Click photo picker button
      2. Select image file via file input
      3. Verify photo preview appears
      4. Save form
      5. Verify photo saved and displayed in detail
    Expected Result: Photo selected and saved correctly
    Evidence: .sisyphus/evidence/task-20-photo-web.png
  ```

  **Commit**: YES (groups with Wave 4)
  - Message: `feat: photo picker widget`
  - Files: `lib/features/person/ui/widgets/photo_picker_widget.dart`

- [x] 21. Health Report List Page

  **What to do**:
  - Create `lib/features/health_report/ui/pages/report_list_page.dart`
  - Display reports as cards with: person name, report date, source (PDF/Manual)
  - Filter by person dropdown (optional)
  - Import button (FAB) → navigate to import page
  - Tap card → navigate to detail page
  - Empty state: "暂无体检报告"

  **Must NOT do**:
  - Add date range filter
  - Add search functionality
  - Add batch delete

  **Recommended Agent Profile**:
  - **Category**: `visual-engineering`
    - Reason: Report list UI with filtering
  - **Skills**: [`frontend-ui-ux`]
    - `frontend-ui-ux`: List page layout and card styling

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 4 (with Tasks 17-20, 22-24)
  - **Blocks**: 26
  - **Blocked By**: Task 3, Task 4, Task 8, Task 13

  **References**:
  - Pattern: `lib/core/theme/app_theme.dart` - Card styling

  **Acceptance Criteria**:
  - [ ] ReportListPage created
  - [ ] Reports displayed as cards
  - [ ] Person filter dropdown
  - [ ] Import FAB functional
  - [ ] Card tap navigates to detail

  **QA Scenarios**:
  ```
  Scenario: Report List Display (Web)
    Tool: Playwright (playwright skill)
    Preconditions: 5 reports in database
    Steps:
      1. Navigate to reports list page
      2. Verify 5 cards displayed
      3. Verify each shows person name, date, source
    Expected Result: All reports displayed correctly
    Evidence: .sisyphus/evidence/task-21-report-list-web.png

  Scenario: Person Filter
    Tool: Playwright (playwright skill)
    Preconditions: Reports from multiple persons
    Steps:
      1. Navigate to reports list
      2. Select person from dropdown
      3. Verify list filtered to that person's reports only
    Expected Result: Filter works correctly
    Evidence: .sisyphus/evidence/task-21-person-filter.png

  Scenario: Import Navigation
    Tool: Playwright (playwright skill)
    Preconditions: Reports list page
    Steps:
      1. Click import FAB
      2. Verify navigation to import page
    Expected Result: Import button navigates correctly
    Evidence: .sisyphus/evidence/task-21-import-nav.png
  ```

  **Commit**: YES (groups with Wave 4)
  - Message: `feat: health report list page`
  - Files: `lib/features/health_report/ui/pages/report_list_page.dart`

- [x] 22. Health Report Import Flow (PDF picker + parsing)

  **What to do**:
  - Create `lib/features/health_report/ui/pages/report_import_page.dart`
  - PDF file picker (iOS: file picker, Web: file input)
  - Progress indicator during extraction/parsing
  - Display extracted indicators preview
  - Manual entry fallback form if parsing fails
  - Select person to associate with report
  - Save button to commit report

  **Must NOT do**:
  - Add batch PDF import
  - Add PDF preview rendering
  - Add hospital template selection

  **Recommended Agent Profile**:
  - **Category**: `visual-engineering`
    - Reason: Import flow UI with multiple states
  - **Skills**: [`frontend-ui-ux`, `playwright`]
    - `frontend-ui-ux`: Import flow UI design
    - `playwright`: Web file picker testing

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 4 (with Tasks 17-21, 23-24)
  - **Blocks**: 26
  - **Blocked By**: Task 3, Task 9, Task 10, Task 15, Task 13

  **References**:
  - Pattern: `lib/features/health_report/providers/import_state_provider.dart` - State machine
  - Pattern: `lib/core/services/pdf_extraction_service.dart` - Extraction
  - Pattern: `lib/core/services/indicator_parser_service.dart` - Parsing

  **Acceptance Criteria**:
  - [ ] ReportImportPage created
  - [ ] PDF picker functional (iOS/Web)
  - [ ] Progress indicator during processing
  - [ ] Extracted indicators preview
  - [ ] Manual entry fallback
  - [ ] Person selection dropdown
  - [ ] Save functionality

  **QA Scenarios**:
  ```
  Scenario: Successful PDF Import (Web)
    Tool: Playwright (playwright skill)
    Preconditions: Valid PDF with indicators
    Steps:
      1. Navigate to import page
      2. Select person from dropdown
      3. Upload valid PDF file
      4. Wait for extraction (progress visible)
      5. Verify indicators preview displayed
      6. Click save
      7. Verify success message
      8. Verify report in list
    Expected Result: PDF imported successfully
    Evidence: .sisyphus/evidence/task-22-pdf-import-success.png

  Scenario: Parsing Failure → Manual Entry
    Tool: Playwright (playwright skill)
    Preconditions: PDF with no recognizable indicators
    Steps:
      1. Navigate to import page
      2. Upload invalid PDF
      3. Verify parsing fails
      4. Verify manual entry form appears
      5. Enter indicators manually
      6. Save successfully
    Expected Result: Manual fallback works
    Evidence: .sisyphus/evidence/task-22-manual-fallback.png

  Scenario: Import Cancellation
    Tool: Playwright (playwright skill)
    Preconditions: Import page open
    Steps:
      1. Start PDF upload
      2. Click cancel during processing
      3. Verify returned to list
      4. Verify no report created
    Expected Result: Cancel aborts import
    Evidence: .sisyphus/evidence/task-22-cancel-import.png
  ```

  **Commit**: YES (groups with Wave 4)
  - Message: `feat: health report import flow`
  - Files: `lib/features/health_report/ui/pages/report_import_page.dart`

- [x] 23. Health Report Manual Entry Form

  **What to do**:
  - Create `lib/features/health_report/ui/widgets/manual_entry_form.dart`
  - Date picker for report date
  - Indicator input fields:
    - Blood glucose: value input + mmol/L unit
    - Blood pressure: systolic + diastolic inputs + mmHg unit
    - Blood lipids: TC, TG, HDL, LDL inputs + mmol/L unit
  - Validation: values must be positive numbers
  - Save/Cancel buttons
  - Used as fallback when PDF parsing fails

  **Must NOT do**:
  - Add indicator reference range display
  - Add abnormal value highlighting (in detail view only)
  - Add more indicators

  **Recommended Agent Profile**:
  - **Category**: `visual-engineering`
    - Reason: Form UI with multiple numeric inputs
  - **Skills**: [`frontend-ui-ux`]
    - `frontend-ui-ux`: Form layout for medical inputs

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 4 (with Tasks 17-22, 24)
  - **Blocks**: 26
  - **Blocked By**: Task 3, Task 14, Task 13

  **References**:
  - Pattern: `lib/core/utils/form_validators.dart` - Value validators

  **Acceptance Criteria**:
  - [ ] ManualEntryForm created
  - [ ] All 6 indicator inputs (glucose, BP systolic/diastolic, 4 lipids)
  - [ ] Date picker
  - [ ] Number validation
  - [ ] Save/Cancel buttons

  **QA Scenarios**:
  ```
  Scenario: Manual Entry Form Display
    Tool: Playwright (playwright skill)
    Preconditions: Form accessible
    Steps:
      1. Navigate to manual entry form
      2. Verify all input fields present
      3. Verify units displayed correctly
    Expected Result: All fields visible with correct labels
    Evidence: .sisyphus/evidence/task-23-manual-form-display.png

  Scenario: Valid Manual Entry
    Tool: Playwright (playwright skill)
    Preconditions: Form accessible
    Steps:
      1. Enter date: 2024-01-15
      2. Enter glucose: 5.6
      3. Enter BP: 120/80
      4. Enter lipids: TC=4.5, TG=1.2, HDL=1.8, LDL=2.8
      5. Click save
      6. Verify success
    Expected Result: Manual entry saved correctly
    Evidence: .sisyphus/evidence/task-23-valid-entry.png

  Scenario: Invalid Value Validation
    Tool: Playwright (playwright skill)
    Preconditions: Form accessible
    Steps:
      1. Enter glucose: -5 (invalid negative)
      2. Click save
      3. Verify validation error shown
      4. Form not submitted
    Expected Result: Negative values rejected
    Evidence: .sisyphus/evidence/task-23-invalid-value.png
  ```

  **Commit**: YES (groups with Wave 4)
  - Message: `feat: health report manual entry form`
  - Files: `lib/features/health_report/ui/widgets/manual_entry_form.dart`

- [x] 24. Health Report Detail Page

  **What to do**:
  - Create `lib/features/health_report/ui/pages/report_detail_page.dart`
  - Display: person name, report date, source (PDF/Manual)
  - Display all indicators with values and units:
    - Blood glucose (mmol/L) + status (正常/偏高/偏低)
    - Blood pressure (systolic/diastolic mmHg) + status
    - Blood lipids (TC/TG/HDL/LDL mmol/L) + status each
  - Abnormal values highlighted in red/orange
  - Delete button with confirmation
  - Back navigation

  **Must NOT do**:
  - Add edit functionality (re-import instead)
  - Add trend comparison with previous reports
  - Add recommendation/suggestion display

  **Recommended Agent Profile**:
  - **Category**: `visual-engineering`
    - Reason: Detail page with status highlighting
  - **Skills**: [`frontend-ui-ux`]
    - `frontend-ui-ux`: Medical data display with status colors

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 4 (with Tasks 17-23)
  - **Blocks**: 26
  - **Blocked By**: Task 3, Task 8, Task 13

  **References**:
  - Pattern: Status colors from theme: Green #00E676 (normal), Orange #FFAB00 (warning), Red #FF5252 (critical)

  **Acceptance Criteria**:
  - [ ] ReportDetailPage created
  - [ ] All indicators displayed
  - [ ] Status computed and displayed
  - [ ] Abnormal values color-coded
  - [ ] Delete button functional

  **QA Scenarios**:
  ```
  Scenario: Report Detail Display
    Tool: Playwright (playwright skill)
    Preconditions: Report with all indicators
    Steps:
      1. Navigate to report detail page
      2. Verify person name displayed
      3. Verify report date displayed
      4. Verify all 6 indicators shown with values
      5. Verify status for each indicator
    Expected Result: All report data displayed
    Evidence: .sisyphus/evidence/task-24-detail-display.png

  Scenario: Abnormal Value Highlighting
    Tool: Playwright (playwright skill)
    Preconditions: Report with high glucose
    Steps:
      1. Navigate to report detail
      2. Verify glucose=7.0 shown in red/orange
      3. Verify status="偏高"
    Expected Result: Abnormal values color-coded
    Evidence: .sisyphus/evidence/task-24-abnormal-color.png

  Scenario: Delete Report
    Tool: Playwright (playwright skill)
    Preconditions: Report exists
    Steps:
      1. Click delete button
      2. Confirm deletion
      3. Verify returned to list
      4. Verify report removed
    Expected Result: Delete works with confirmation
    Evidence: .sisyphus/evidence/task-24-delete-report.png
  ```

  **Commit**: YES (groups with Wave 4)
  - Message: `feat: health report detail page`
  - Files: `lib/features/health_report/ui/pages/report_detail_page.dart`

- [ ] 25. Integration: Person Flow End-to-End

  **What to do**:
  - Test complete person management flow
  - Create person → list → detail → edit → delete
  - Verify photo upload and display throughout flow
  - Verify data persistence after app restart simulation
  - Verify cascade delete (person → reports deleted)
  - Cross-verify on iOS and Web platforms

  **Must NOT do**:
  - Add edge case testing beyond flow
  - Add performance benchmarking

  **Recommended Agent Profile**:
  - **Category**: `deep`
    - Reason: Integration testing across multiple components
  - **Skills**: [`playwright`]
    - `playwright`: Web platform integration testing

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 5 (with Tasks 26-29)
  - **Blocks**: F3
  - **Blocked By**: Task 17-20

  **References**:
  - All person module tasks (17-20)

  **Acceptance Criteria**:
  - [ ] Full create-read-update-delete flow works
  - [ ] Photo persists correctly
  - [ ] Data survives simulated restart
  - [ ] Cascade delete verified

  **QA Scenarios**:
  ```
  Scenario: Full Person Flow (Web)
    Tool: Playwright (playwright skill)
    Preconditions: App running, empty database
    Steps:
      1. Navigate to app
      2. Click FAB to create person
      3. Fill form: name="测试用户1", gender="男", birthDate, phone, relationship="配偶"
      4. Upload photo
      5. Save → verify person appears in list
      6. Click card → verify detail page with photo
      7. Click edit → modify name to="测试用户2"
      8. Save → verify changes in detail
      9. Create health report for this person
      10. Click delete → confirm
      11. Verify person AND report deleted from list
    Expected Result: Complete flow works with cascade
    Evidence: .sisyphus/evidence/task-25-person-flow-web.png

  Scenario: Data Persistence (Web)
    Tool: Playwright (playwright skill)
    Preconditions: Person created
    Steps:
      1. Create person with all fields
      2. Close browser tab
      3. Re-open app URL
      4. Verify person still in list with correct data
    Expected Result: Data persists across sessions
    Evidence: .sisyphus/evidence/task-25-persistence-web.png
  ```

  **Commit**: YES (groups with Wave 5)
  - Message: `test: person flow integration`
  - Files: Test files for integration

- [ ] 26. Integration: Health Report Flow End-to-End

  **What to do**:
  - Test complete health report flow
  - PDF import → parsing → preview → save → detail view
  - Manual entry flow when parsing fails
  - Verify indicator values and status calculations
  - Verify association with correct person
  - Verify data persistence

  **Must NOT do**:
  - Test all edge cases (covered in individual tasks)
  - Add chart visualization testing

  **Recommended Agent Profile**:
  - **Category**: `deep`
    - Reason: Integration testing across import flow
  - **Skills**: [`playwright`]
    - `playwright`: Web platform integration testing

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 5 (with Tasks 25, 27-29)
  - **Blocks**: F3
  - **Blocked By**: Task 21-24

  **References**:
  - All health report module tasks (21-24)
  - PDF extraction and parsing services

  **Acceptance Criteria**:
  - [ ] PDF import flow complete
  - [ ] Manual entry flow complete
  - [ ] Indicators saved correctly
  - [ ] Person association verified
  - [ ] Data persists

  **QA Scenarios**:
  ```
  Scenario: PDF Import Full Flow (Web)
    Tool: Playwright (playwright skill)
    Preconditions: Person exists, valid PDF ready
    Steps:
      1. Navigate to reports list
      2. Click import FAB
      3. Select person="测试用户1"
      4. Upload valid PDF containing health indicators
      5. Wait for parsing (progress visible)
      6. Verify indicator preview shows extracted values
      7. Click save
      8. Verify report appears in list
      9. Click report → verify detail with indicators
      10. Verify status calculations correct
    Expected Result: Full PDF import flow works
    Evidence: .sisyphus/evidence/task-26-pdf-flow-web.png

  Scenario: Manual Entry Flow (Web)
    Tool: Playwright (playwright skill)
    Preconditions: Person exists
    Steps:
      1. Navigate to reports list
      2. Click import FAB
      3. Select person
      4. Upload invalid PDF (no indicators)
      5. Verify manual entry form appears
      6. Enter all indicators manually
      7. Save → verify report created
      8. View detail → verify manual data correct
    Expected Result: Manual fallback flow works
    Evidence: .sisyphus/evidence/task-26-manual-flow-web.png

  Scenario: Report-Person Association
    Tool: Playwright (playwright skill)
    Preconditions: Multiple persons exist
    Steps:
      1. Create report for Person A
      2. Create report for Person B
      3. Filter reports by Person A
      4. Verify only Person A's report shown
      5. Navigate to Person A detail
      6. Verify report appears in their reports list
    Expected Result: Association works correctly
    Evidence: .sisyphus/evidence/task-26-association-web.png
  ```

  **Commit**: YES (groups with Wave 5)
  - Message: `test: health report flow integration`
  - Files: Test files for integration

- [ ] 27. Platform-specific: iOS Permissions Setup

  **What to do**:
  - Configure `ios/Runner/Info.plist` with permission descriptions:
    - NSCameraUsageDescription: "用于拍摄家人照片"
    - NSPhotoLibraryUsageDescription: "用于选择家人照片"
  - Verify permission dialogs appear correctly
  - Handle permission denied gracefully (show message, continue without photo)
  - Test on iOS simulator or device

  **Must NOT do**:
  - Add biometric authentication (Face ID)
  - Add push notifications permissions
  - Add location permissions

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Configuration file update
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 5 (with Tasks 25-26, 28-29)
  - **Blocks**: F3
  - **Blocked By**: Task 2

  **References**:
  - Apple doc: Info.plist permission keys

  **Acceptance Criteria**:
  - [ ] Info.plist updated with usage descriptions
  - [ ] Camera permission dialog shows correct text
  - [ ] Photo library permission dialog shows correct text
  - [ ] Permission denied handled gracefully

  **QA Scenarios**:
  ```
  Scenario: Info.plist Configuration
    Tool: Bash
    Preconditions: iOS folder exists
    Steps:
      1. grep NSCameraUsageDescription ios/Runner/Info.plist
      2. Verify description="用于拍摄家人照片"
      3. grep NSPhotoLibraryUsageDescription ios/Runner/Info.plist
      4. Verify description="用于选择家人照片"
    Expected Result: All permissions configured
    Evidence: .sisyphus/evidence/task-27-infoplist.txt

  Scenario: Permission Denial Handling
    Tool: Bash (flutter test)
    Preconditions: Mock permission denied
    Steps:
      1. Simulate permission denied scenario
      2. Verify app continues without photo
      3. Verify helpful message shown
    Expected Result: Graceful degradation when denied
    Evidence: .sisyphus/evidence/task-27-permission-denied.txt
  ```

  **Commit**: YES (groups with Wave 5)
  - Message: `feat: ios permissions configuration`
  - Files: `ios/Runner/Info.plist`

- [ ] 28. Platform-specific: Web File Picker Setup

  **What to do**:
  - Verify web/index.html has correct meta tags
  - Test file picker (PDF and images) works in Chrome
  - Handle large file rejection (> 20MB)
  - Handle file type validation (only PDF/images accepted)
  - Test IndexedDB storage limits

  **Must NOT do**:
  - Add PWA manifest (not needed for MVP)
  - Add service worker caching
  - Add file drag-and-drop (use standard picker)

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Web configuration verification
  - **Skills**: [`playwright`]
    - `playwright`: Web testing

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 5 (with Tasks 25-27, 29)
  - **Blocks**: F3
  - **Blocked By**: Task 2

  **References**:
  - Flutter web docs: Web considerations

  **Acceptance Criteria**:
  - [ ] Web file picker functional
  - [ ] Large file rejection works
  - [ ] File type validation works
  - [ ] IndexedDB storage tested

  **QA Scenarios**:
  ```
  Scenario: Web File Picker Test
    Tool: Playwright (playwright skill)
    Preconditions: Web app running
    Steps:
      1. Navigate to person create form
      2. Click photo picker
      3. Select image file from computer
      4. Verify image uploaded and preview shown
      5. Save form
      6. Verify photo in detail page
    Expected Result: Web file picker works
    Evidence: .sisyphus/evidence/task-28-web-picker.png

  Scenario: Large File Rejection (Web)
    Tool: Playwright (playwright skill)
    Preconditions: Large file (> 20MB) ready
    Steps:
      1. Navigate to PDF import page
      2. Attempt to upload large PDF
      3. Verify rejection message shown
      4. Verify no crash or freeze
    Expected Result: Large files rejected with message
    Evidence: .sisyphus/evidence/task-28-large-file.png

  Scenario: Invalid File Type Rejection
    Tool: Playwright (playwright skill)
    Preconditions: Non-PDF file ready
    Steps:
      1. Navigate to PDF import page
      2. Attempt to upload .txt or .exe file
      3. Verify rejection message
    Expected Result: Invalid types rejected
    Evidence: .sisyphus/evidence/task-28-invalid-type.png
  ```

  **Commit**: YES (groups with Wave 5)
  - Message: `feat: web file picker setup`
  - Files: `web/index.html` if modified

- [ ] 29. Add Unit Tests for Domain Layer

  **What to do**:
  - Create test files mirroring domain structure
  - Test PersonEntity age calculation
  - Test IndicatorEntity status calculation
  - Test form validators
  - Test PDF extraction service
  - Test indicator parser service
  - Ensure all tests pass: `flutter test`

  **Must NOT do**:
  - Add integration tests (separate task)
  - Add widget tests (separate task)
  - Add mock-heavy tests (prefer real logic tests)

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
    - Reason: Test writing requires careful logic verification
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 5 (with Tasks 25-28)
  - **Blocks**: F2
  - **Blocked By**: Task 12-15

  **References**:
  - Flutter docs: Testing guide
  - Pattern: All domain layer files

  **Acceptance Criteria**:
  - [ ] Unit tests for all domain entities
  - [ ] Unit tests for validators
  - [ ] Unit tests for PDF extraction
  - [ ] Unit tests for indicator parser
  - [ ] All tests pass

  **QA Scenarios**:
  ```
  Scenario: Domain Tests Execution
    Tool: Bash (flutter test)
    Preconditions: All test files created
    Steps:
      1. flutter test test/domain/
      2. Verify all tests pass
      3. Verify no skipped tests
    Expected Result: All domain unit tests pass
    Evidence: .sisyphus/evidence/task-29-domain-tests.txt

  Scenario: Validator Tests Execution
    Tool: Bash (flutter test)
    Preconditions: Validator tests created
    Steps:
      1. flutter test test/core/utils/form_validators_test.dart
      2. Verify all validation scenarios tested
      3. Verify edge cases covered
    Expected Result: All validator tests pass
    Evidence: .sisyphus/evidence/task-29-validator-tests.txt
  ```

  **Commit**: YES (groups with Wave 6)
  - Message: `test: domain layer unit tests`
  - Files: `test/domain/`, `test/core/utils/`

- [ ] 30. Add Widget Tests for Person UI

  **What to do**:
  - Create widget tests for PersonListPage
  - Create widget tests for PersonDetailPage
  - Create widget tests for PersonFormPage
  - Test navigation flows
  - Test empty state rendering
  - Test form validation UI feedback
  - Ensure all tests pass

  **Must NOT do**:
  - Add screenshot tests
  - Add accessibility tests
  - Test every edge case (focus on happy paths)

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
    - Reason: Widget tests require Flutter testing knowledge
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 6 (with Tasks 31-33)
  - **Blocks**: F2
  - **Blocked By**: Task 17-20

  **References**:
  - Flutter docs: Widget testing guide
  - Pattern: All person UI pages

  **Acceptance Criteria**:
  - [ ] Widget tests for PersonListPage
  - [ ] Widget tests for PersonDetailPage
  - [ ] Widget tests for PersonFormPage
  - [ ] Navigation tested
  - [ ] Empty state tested
  - [ ] All tests pass

  **QA Scenarios**:
  ```
  Scenario: Person Widget Tests Execution
    Tool: Bash (flutter test)
    Preconditions: All widget tests created
    Steps:
      1. flutter test test/features/person/ui/
      2. Verify all tests pass
      3. Verify coverage > 80% for person UI
    Expected Result: All person widget tests pass
    Evidence: .sisyphus/evidence/task-30-person-widget-tests.txt
  ```

  **Commit**: YES (groups with Wave 6)
  - Message: `test: person ui widget tests`
  - Files: `test/features/person/ui/`

- [ ] 31. Add Widget Tests for Health Report UI

  **What to do**:
  - Create widget tests for ReportListPage
  - Create widget tests for ReportImportPage
  - Create widget tests for ManualEntryForm
  - Create widget tests for ReportDetailPage
  - Test import flow states
  - Test manual entry form validation
  - Ensure all tests pass

  **Must NOT do**:
  - Add PDF processing widget tests (integration test)
  - Test every indicator combination
  - Add accessibility tests

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
    - Reason: Widget tests for complex UI flows
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 6 (with Tasks 30, 32-33)
  - **Blocks**: F2
  - **Blocked By**: Task 21-24

  **References**:
  - Pattern: All health report UI pages

  **Acceptance Criteria**:
  - [ ] Widget tests for ReportListPage
  - [ ] Widget tests for ReportImportPage
  - [ ] Widget tests for ManualEntryForm
  - [ ] Widget tests for ReportDetailPage
  - [ ] All tests pass

  **QA Scenarios**:
  ```
  Scenario: Report Widget Tests Execution
    Tool: Bash (flutter test)
    Preconditions: All widget tests created
    Steps:
      1. flutter test test/features/health_report/ui/
      2. Verify all tests pass
    Expected Result: All report widget tests pass
    Evidence: .sisyphus/evidence/task-31-report-widget-tests.txt
  ```

  **Commit**: YES (groups with Wave 6)
  - Message: `test: health report ui widget tests`
  - Files: `test/features/health_report/ui/`

- [ ] 32. Add Integration Tests for Data Persistence

  **What to do**:
  - Create integration tests for Isar database
  - Test Person CRUD operations with actual database
  - Test HealthReport CRUD operations
  - Test cascade delete behavior
  - Test database initialization and schema migration
  - Test data retrieval after simulated restart

  **Must NOT do**:
  - Add performance benchmarks
  - Test concurrent access edge cases
  - Add encryption tests (not implemented)

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
    - Reason: Integration tests require database setup
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 6 (with Tasks 30-31, 33)
  - **Blocks**: F2
  - **Blocked By**: Task 7, Task 8

  **References**:
  - Pattern: `lib/data/repositories/` - Repository implementations

  **Acceptance Criteria**:
  - [ ] Integration tests for Person persistence
  - [ ] Integration tests for HealthReport persistence
  - [ ] Cascade delete tested
  - [ ] Data retrieval tested
  - [ ] All tests pass

  **QA Scenarios**:
  ```
  Scenario: Integration Tests Execution
    Tool: Bash (flutter test)
    Preconditions: Integration tests created
    Steps:
      1. flutter test test/integration/
      2. Verify all persistence tests pass
      3. Verify database operations tested end-to-end
    Expected Result: All integration tests pass
    Evidence: .sisyphus/evidence/task-32-integration-tests.txt
  ```

  **Commit**: YES (groups with Wave 6)
  - Message: `test: data persistence integration tests`
  - Files: `test/integration/`

- [ ] 33. Performance Test: 100+ Records List

  **What to do**:
  - Create test inserting 100+ persons with reports
  - Measure list rendering time
  - Verify scrolling performance is smooth
  - Identify any performance bottlenecks
  - Document findings and recommendations

  **Must NOT do**:
  - Add performance optimization implementation
  - Add caching layer
  - Add pagination (defer if needed)

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Performance measurement task
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 6 (with Tasks 30-32)
  - **Blocks**: F2
  - **Blocked By**: Task 7, Task 17

  **References**:
  - Flutter docs: Performance guide

  **Acceptance Criteria**:
  - [ ] 100+ records inserted successfully
  - [ ] List rendering measured
  - [ ] Scrolling performance acceptable
  - [ ] Findings documented

  **QA Scenarios**:
  ```
  Scenario: Performance Test Execution
    Tool: Bash (flutter test)
    Preconditions: Performance test created
    Steps:
      1. Insert 100 persons
      2. Insert 200 health reports (2 per person)
      3. Measure list page render time
      4. Scroll through entire list
      5. Record frame rate and response time
    Expected Result: Performance acceptable (< 100ms render, smooth scroll)
    Evidence: .sisyphus/evidence/task-33-performance-test.txt

  Scenario: Web Performance Test
    Tool: Playwright (playwright skill)
    Preconditions: 100+ records in database
    Steps:
      1. Navigate to person list
      2. Measure initial load time
      3. Scroll through all cards
      4. Record timing metrics
    Expected Result: Web performance acceptable
    Evidence: .sisyphus/evidence/task-33-web-performance.png
  ```

  **Commit**: YES (groups with Wave 6)
  - Message: `test: performance test for 100+ records`
  - Files: `test/performance/`

---

## Final Verification Wave (MANDATORY)

> 4 review agents run in PARALLEL. ALL must APPROVE. Present consolidated results to user and get explicit "okay" before completing.

- [ ] F1. **Plan Compliance Audit** — `oracle`
  Read the plan end-to-end. For each "Must Have": verify implementation exists. For each "Must NOT Have": search codebase for forbidden patterns. Check evidence files exist. Compare deliverables against plan.
  Output: `Must Have [N/N] | Must NOT Have [N/N] | Tasks [N/N] | VERDICT: APPROVE/REJECT`

- [ ] F2. **Code Quality Review** — `unspecified-high`
  Run `flutter analyze` + `flutter test`. Review all changed files for: `as any`, `@ts-ignore` equivalents, empty catches, print statements in prod, commented-out code, unused imports. Check AI slop: excessive comments, over-abstraction, generic names.
  Output: `Analyze [PASS/FAIL] | Tests [N pass/N fail] | Files [N clean/N issues] | VERDICT`

- [ ] F3. **Real Manual QA** — `unspecified-high` (+ `playwright` skill for web)
  Start from clean state. Execute EVERY QA scenario from EVERY task. Test cross-task integration. Test edge cases: empty state, invalid input, large PDF. Save to `.sisyphus/evidence/final-qa/`.
  Output: `Scenarios [N/N pass] | Integration [N/N] | Edge Cases [N tested] | VERDICT`

- [ ] F4. **Scope Fidelity Check** — `deep`
  For each task: read "What to do", read actual diff. Verify 1:1 — everything in spec was built, nothing beyond spec was built. Check "Must NOT do" compliance. Detect cross-task contamination.
  Output: `Tasks [N/N compliant] | Contamination [CLEAN/N issues] | VERDICT`

---

## Commit Strategy

- **Wave 1**: `feat: initial project setup` — all Wave 1 files
- **Wave 2**: `feat: data layer implementation` — lib/data/, lib/core/services/
- **Wave 3**: `feat: domain layer with riverpod` — lib/domain/, lib/features/*/providers/
- **Wave 4**: `feat: ui implementation` — lib/features/*/ui/
- **Wave 5**: `feat: platform integration` — ios/Runner/Info.plist, web/
- **Wave 6**: `test: add automated tests` — test/
- Each commit runs: `flutter analyze && flutter test`

---

## Success Criteria

### Verification Commands
```bash
flutter analyze                    # Expected: No issues found
flutter test                       # Expected: All tests pass
flutter run -d chrome              # Expected: Web app launches successfully
flutter run -d iPhone              # Expected: iOS app launches successfully (requires simulator)
```

### Final Checklist
- [ ] All "Must Have" present and functional
- [ ] All "Must NOT Have" absent from codebase
- [ ] All tests pass
- [ ] iOS app works on simulator
- [ ] Web app works on Chrome
- [ ] Can create Person with photo
- [ ] Can import PDF health report
- [ ] Manual entry fallback works
- [ ] Data persists across restarts

---

## Wave 7: GitHub Repository Setup (After Final Verification Approved)

> This wave runs AFTER user explicitly approves Final Verification results.
> User will provide GitHub repository URL at execution time.

- [ ] 34. Initialize Git Repository

  **What to do**:
  - Initialize git repository: `git init`
  - Create `.gitignore` for Flutter project
  - Make initial commit with all code: `git add . && git commit -m "Initial commit: Flutter health records app"`
  - Verify commit history

  **Must NOT do**:
  - Push to remote (separate task)
  - Add sensitive files (.env, credentials)
  - Commit build artifacts (build/, .dart_tool/)

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Standard git initialization
  - **Skills**: [`git-master`]
    - `git-master`: Git best practices for atomic commits

  **Parallelization**:
  - **Can Run In Parallel**: NO (sequential with Task 35)
  - **Parallel Group**: Wave 7
  - **Blocks**: 35
  - **Blocked By**: Final Verification approved

  **References**:
  - Flutter gitignore template: `.gitignore` should include build/, .dart_tool/, .flutter-plugins, *.lock files

  **Acceptance Criteria**:
  - [ ] Git repository initialized
  - [ ] .gitignore configured correctly
  - [ ] Initial commit created
  - [ ] All source files committed

  **QA Scenarios**:
  ```
  Scenario: Git Init Verification
    Tool: Bash (git commands)
    Preconditions: Project directory exists
    Steps:
      1. git status
      2. Verify repository initialized
      3. git log --oneline
      4. Verify at least 1 commit exists
    Expected Result: Git repository ready with initial commit
    Evidence: .sisyphus/evidence/task-34-git-init.txt

  Scenario: Gitignore Check
    Tool: Bash
    Preconditions: .gitignore exists
    Steps:
      1. cat .gitignore
      2. Verify build/ excluded
      3. Verify .dart_tool/ excluded
      4. Verify *.lock files excluded
    Expected Result: Proper Flutter gitignore configured
    Evidence: .sisyphus/evidence/task-34-gitignore.txt
  ```

  **Commit**: NO (this IS the commit task)

- [ ] 35. Create GitHub Repository and Push

  **What to do**:
  - Create GitHub repository using `gh repo create` or user-provided URL
  - Add remote origin: `git remote add origin <REPO_URL>`
  - Push to main branch: `git push -u origin main`
  - Verify repository accessible on GitHub
  - Document repository URL for user

  **Must NOT do**:
  - Force push
  - Delete existing remote content
  - Push sensitive data

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Standard git push operation
  - **Skills**: [`git-master`]
    - `git-master`: Safe git operations with remote

  **Parallelization**:
  - **Can Run In Parallel**: NO (sequential, depends on Task 34)
  - **Parallel Group**: Wave 7
  - **Blocks**: None
  - **Blocked By**: Task 34 + User provides repo URL

  **References**:
  - GitHub CLI docs: `gh repo create --public --source=. --remote=origin`

  **Acceptance Criteria**:
  - [ ] GitHub repository created
  - [ ] Remote origin added
  - [ ] Code pushed to main branch
  - [ ] Repository URL documented

  **QA Scenarios**:
  ```
  Scenario: GitHub Push Verification
    Tool: Bash (git commands)
    Preconditions: Remote configured, credentials available
    Steps:
      1. git remote -v
      2. Verify origin URL correct
      3. git branch -a
      4. Verify main branch pushed
      5. gh repo view (or curl GitHub API)
      6. Verify repository accessible
    Expected Result: Code successfully pushed to GitHub
    Evidence: .sisyphus/evidence/task-35-github-push.txt

  Scenario: Repository URL Confirmation
    Tool: Bash
    Preconditions: Push completed
    Steps:
      1. git config --get remote.origin.url
      2. Output URL to user
    Expected Result: User receives repository URL
    Evidence: .sisyphus/evidence/task-35-repo-url.txt
  ```

  **Commit**: NO (pushing existing commits)

---

## GitHub Integration Summary

**Workflow**:
1. After Final Verification approved by user → Wave 7 starts
2. Task 34: Initialize local git repository
3. Task 35: User provides GitHub repo URL → Create and push

**User Actions Required**:
- Provide GitHub repository name or URL when Wave 7 starts
- Ensure GitHub CLI (`gh`) is authenticated OR provide manual URL

**Expected Output**:
```
✅ Repository created: https://github.com/<username>/health-records-app
✅ Code pushed to main branch
✅ Your Flutter app is now on GitHub!
```