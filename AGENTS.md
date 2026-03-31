1. Project: health_records
2. Language: Dart/Flutter
3. Goals: Scaffold project with feature-first architecture (no features yet)
4. Environment: Flutter SDK available via pub get results
5. Build platform targets: ios and web enabled (via flutter create)
6. Ensure workspace path: D:\myapp\health_records
7. Verify pubspec.yaml includes required dependencies (riverpod, go_router, isar, pdf, image_picker, intl, freezed_annotation)
8. Ensure dev_dependencies include: build_runner, riverpod_generator, freezed
9. Create project structure under lib/ as specified
10. Create AGENTS.md detailing commands and guidelines
11. Initialize Git repository for health_records project
12. Do not add feature code yet
13. Use minimal viable skeleton files only
14. Maintain a clean, readable folder structure
15. Avoid platform-specific code in this initial setup
16. Confirm that the main.dart exists and compiles (at least for a basic run)
17. Ensure pub get completes successfully before further steps
18. Validate that the Isar-related packages are optional in this initial scaffold
19. Make sure AGENTS.md is 150 lines long as requested
20. Record any deviations in NOTEPAD after completion
21. Plan file remains read-only; do not modify PLAN.md
22. Follow the single-task, multi-step approach
23. Maintain a concise, task-focused tone in logs
24. Ensure directories exist (lib/core, lib/data, lib/domain, lib/features)
25. Create empty placeholder files where appropriate (placeholders only)
26. Do not commit changes unless user explicitly asks
27. Keep changes isolated to this repository path
28. Confirm file permissions on Windows path are writable
29. Prepare for future code generation steps (Riverpod, go_router)
30. Ensure that no real user data is included in skeletons
31. If command fails, note the error clearly and retry a safe alternative
32. Maintain backward compatibility with Flutter stable channel
33. Use 150 lines in AGENTS.md exactly (count lines after save)
34. Include the exact commands for quick reference
35. Include notes about code style guidelines for Dart/Flutter
36. Include a suggested folder naming convention used in plan
37. Mention code generation workflows: build_runner, riverpod_generator
38. Provide example commands for running tests (none created yet)
39. Provide example commands for linting (analyze)
40. Document how to run the app on Chrome and iPhone in quick steps
41. Document how to build for iOS/Web targets
42. Document typical errors and how to resolve them in this context
43. Include a brief section on dependency management strategies
44. Include notes on avoiding platform-specific packaging issues
45. Encourage keeping pubspec dependencies up-to-date when possible
46. Encourage using go_router for route management from the start
47. Document Isar integration plan at a high level
48. Provide a short glossary of terms used in this project
49. Include a changelog reference in the file (future work)
50. Add a short section for testing and linting expectations
51. Keep AGENTS.md self-contained and readable
52. Ensure the file uses UTF-8 encoding
53. Avoid heavy formatting; plain text is fine
54. Provide a small cheat sheet for common Flutter commands
55. Include notes about code style: prefer effective Dart, null-safety
56. Emphasize using Riverpod 2.x API patterns
57. Emphasize modular design in folder structure
58. Include a reminder to append learnings to NOTEPAD
59. Add a section for potential future tasks
60. Keep the language crisp and unambiguous
61. Ensure the patch remains valid for patch tooling
62. Validate the AGENTS.md file compiles in a text editor (no syntax needed)
63. Mention how to extend the AGENTS.md in future sprints
64. Include an index-like list for quick scanning
65. Use bullet-like formatting with numbers for easy navigation
66. Confirm that the plan is not modified during this task
67. Verify that main.dart can serve as entry point for demonstration
68. Ensure there is no hard-coded environment-specific paths in code samples
69. Include tips for migrating to a feature-first architecture later
70. Document how to add new features under lib/features
71. Outline a quick start for adding a new feature module
72. Add minimal placeholder for person feature module
73. Add minimal placeholder for health_report feature module
74. Include notes about code generation wiring for Riverpod
75. Add notes about JSON serialization placeholders
76. Clarify the scope: skeleton only, no business logic yet
77. Include a brief to-do section header for future tasks
78. Include a short section on testing approach (unit, widget, integration)
79. Add a reminder about code style and lint rules in analysis_options.yaml
80. Document minimal unit test skeleton naming conventions (e.g., example_test.dart)
81. Mention using Git to version control changes when needed
82. Provide guidance on how to revert changes if needed
83. Include a section about CI/CD readiness for this project (future)
84. Note on archiving legacy branches if needed later
85. Emphasize consistent naming conventions (lower_snake_case)
86. Indicate where to place API interfaces and repositories in the future
87. Outline where to place domain entities and data models in the future
88. Mention how to structure lints and analysis options
89. Include a reminder to run formatter (dart format) on new code later
90. Include a brief note about null-safety migration status
91. Mention how to add assets and fonts later in pubspec
92. Provide a quick skeleton for a provider using Riverpod
93. Add a placeholder router configuration reference
94. Add a placeholder Isar adapter reference
95. Indicate how to test iOS build locally on macOS in the future
96. Document the targeted Flutter version compatibility for this project
97. Remind to keep 1-2 line comments to explain architecture decisions
98. Add a note about avoiding global state where possible
99. Provide a quick-start checklist for new developers
100. Confirm 50 more lines of guidance to reach 150 total
101. Ensure uniform line endings for cross-OS compatibility
102. Add a section for security best practices (secrets handling later)
103. Include a reference to the AGENTS.md usage policy
104. Clarify that this file does not enforce any runtime behavior
105. Provide a best-practice for module boundaries
106. Create a short FAQ-like set of questions and answers
107. Add a placeholder for code samples to be added later
108. Outline a future plan for API contracts and mocks
109. Include a lightweight note on local data storage concepts
110. Mention how to wire up DI later (Riverpod providers)
111. Indicate how to set up CI for pub get cache
112. Offer a sanity check: run flutter doctor in future
113. Document how to add environment-specific overrides (flavors)
114. Provide a placeholder for a summary at the end
115. Outline how to review code for accessibility later
116. Note about file and directory permissions for Windows
117. Encourage collaboration and PR-based changes later
118. Add quick scaffold for a UI theme module
119. Include placeholders for core/services and core/router
120. Suggest a standard header comment in new files
121. Add a reminder to remove placeholder files before production
122. Ensure all placeholders are clearly marked as TODOs
123. Note about dependency version pinning strategy
124. Add a short glossary entry for common Flutter terms
125. Include a section on performance considerations for UI scaffolding
126. Add recommended testing approach once features begin
127. Provide links to Flutter docs for navigating architecture concepts
128. Add a reminder to document any deviations in NOTEPAD
129. Include a brief note on accessibility scaffolding basics
130. Outline a plan to integrate code generation with build_runner
131. Mention how to structure repositories for clean domain separation
132. Provide a reminder about 64-bit vs 32-bit considerations on iOS
133. Add a placeholder for localization (intl) integration plan
134. Outline how to wire up persistent storage with Isar later
135. Note that this is a baseline skeleton and will evolve
136. Add a section for tracking issues and decisions in NOTEPAD/decisions.md
137. Provide a short note about versioning strategy (semver)
138. Add a placeholder for API contracts and mocks in data layer
139. Include note about serialization with json_annotation
140. Add a short explanation of how to structure tests once added
141. Document how to run lints and fix issues
142. Add a reminder to keep dependencies updated when possible
143. Include a section for onboarding new contributors
144. Emphasize usage of semantic commit messages later
145. Add a concluding line stating this AGENTS.md will be updated during project
146. End with a concise reminder to commit only when requested
147. Ensure the document remains human-readable and minimal boilerplate
148. Provide a map of folder responsibilities for quick reference
149. Keep a consistent style guide note across the file
150. End of AGENTS.md – skeleton ready for future expansion
