import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';

// Placeholder pages
class PersonListPage extends StatelessWidget {
  const PersonListPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('家人管理')),
      body: const Center(child: Text('家人列表 - 待实现')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/persons/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ReportListPage extends StatelessWidget {
  const ReportListPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('体检报告')),
      body: const Center(child: Text('报告列表 - 待实现')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/reports/import'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

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
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('新增家人')),
            ),
          ),
          GoRoute(
            path: '/reports',
            builder: (context, state) => const ReportListPage(),
          ),
          GoRoute(
            path: '/reports/import',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('导入报告')),
            ),
          ),
        ],
      ),
    ],
  );
});
