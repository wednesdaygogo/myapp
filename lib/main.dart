import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pdfrx/pdfrx.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/models/person.dart';
import 'data/models/health_report.dart';
import 'data/models/health_indicator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 添加全局错误处理
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exception}');
    debugPrint('StackTrace: ${details.stack}');
  };

  // Initialize pdfrx for PDF processing
  pdfrxFlutterInitialize();

  try {
    // 初始化 Hive
    await Hive.initFlutter();

    // 注册 adapters
    Hive.registerAdapter(PersonAdapter());
    Hive.registerAdapter(HealthReportAdapter());
    Hive.registerAdapter(HealthIndicatorAdapter());

    // 打开所有 boxes，确保在创建 ProviderScope 之前完成
    final personsBox = await Hive.openBox<Person>('persons');
    final reportsBox = await Hive.openBox<HealthReport>('healthReports');
    final indicatorsBox = await Hive.openBox<HealthIndicator>('healthIndicators');

    debugPrint('Hive boxes opened successfully');
    debugPrint('Persons box: ${personsBox.length} items');
    debugPrint('Reports box: ${reportsBox.length} items');
    debugPrint('Indicators box: ${indicatorsBox.length} items');
  } catch (e, stackTrace) {
    debugPrint('Error initializing Hive: $e');
    debugPrint('StackTrace: $stackTrace');
    // 即使初始化失败也继续运行应用
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: '健康管理',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh', 'CN'),
        Locale('en', 'US'),
      ],
      debugShowCheckedModeBanner: false,
    );
  }
}
