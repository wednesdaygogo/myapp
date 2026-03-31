import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../../features/person/ui/pages/person_list_page.dart';
import '../../features/person/ui/pages/person_detail_page.dart';
import '../../features/person/ui/pages/person_form_page.dart';
import '../../features/health_report/ui/pages/report_list_page.dart';
import '../../features/health_report/ui/pages/report_detail_page.dart';
import '../../features/health_report/ui/pages/report_import_page.dart';

// Shell with bottom navigation
class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    int currentIndex = 0;
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/reports')) {
      currentIndex = 1;
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textSecondary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.people), label: '家人'),
          BottomNavigationBarItem(icon: Icon(Icons.description), label: '报告'),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/persons');
              break;
            case 1:
              context.go('/reports');
              break;
          }
        },
      ),
    );
  }
}

// Router provider
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/persons',
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/persons',
            builder: (context, state) => const PersonListPage(),
          ),
          GoRoute(
            path: '/persons/new',
            builder: (context, state) => const PersonFormPage(),
          ),
          GoRoute(
            path: '/persons/:id',
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
              return PersonDetailPage(personId: id);
            },
          ),
          GoRoute(
            path: '/persons/:id/edit',
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
              return PersonFormPage(personId: id);
            },
          ),
          GoRoute(
            path: '/reports',
            builder: (context, state) => const ReportListPage(),
          ),
          GoRoute(
            path: '/reports/import',
            builder: (context, state) => const ReportImportPage(),
          ),
          GoRoute(
            path: '/reports/:id',
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
              return ReportDetailPage(reportId: id);
            },
          ),
        ],
      ),
    ],
  );
});
