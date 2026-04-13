import 'dart:ui';

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

void main() async {
  // 确保 binding 初始化
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize pdfrx for PDF processing
  pdfrxFlutterInitialize();

  // 添加全局错误处理
  FlutterError.onError = (details) {
    debugPrint('FlutterError: ${details.exception}');
    debugPrint('StackTrace: ${details.stack}');
  };

  // 添加异步错误捕获
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    debugPrint('PlatformError: $error');
    debugPrint('StackTrace: $stackTrace');
    return true;
  };

  runApp(const ProviderScope(child: HealthApp()));
}

/// Hive初始化完成状态Provider
final hiveReadyProvider = StateProvider<bool>((ref) => false);

/// 主应用 - 显示SplashScreen，完成后切换到主界面
class HealthApp extends ConsumerStatefulWidget {
  const HealthApp({super.key});

  @override
  ConsumerState<HealthApp> createState() => _HealthAppState();
}

class _HealthAppState extends ConsumerState<HealthApp> {
  bool _initialized = false;
  String _status = '正在初始化...';
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    setState(() => _status = '正在初始化数据存储...');

    try {
      // 初始化 Hive
      await Hive.initFlutter();

      setState(() => _status = '正在注册数据类型...');

      // 注册适配器
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(PersonAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(HealthReportAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(HealthIndicatorAdapter());
      }

      setState(() => _status = '正在加载数据...');

      // 打开 boxes
      final personsBox = await Hive.openBox<Person>('persons');
      final reportsBox = await Hive.openBox<HealthReport>('healthReports');
      final indicatorsBox = await Hive.openBox<HealthIndicator>('healthIndicators');

      debugPrint('Hive boxes opened: persons=${personsBox.length}, reports=${reportsBox.length}, indicators=${indicatorsBox.length}');

      setState(() => _status = '初始化完成');

      // 标记Hive准备完成
      ref.read(hiveReadyProvider.notifier).state = true;

      // 等待一小段时间让用户看到完成状态
      await Future.delayed(const Duration(milliseconds: 300));

      setState(() => _initialized = true);
    } catch (e, stackTrace) {
      debugPrint('Initialization error: $e');
      debugPrint('StackTrace: $stackTrace');

      // 尝试恢复
      setState(() => _status = '正在修复数据...');

      try {
        await Hive.close();
        await Hive.deleteBoxFromDisk('persons');
        await Hive.deleteBoxFromDisk('healthReports');
        await Hive.deleteBoxFromDisk('healthIndicators');

        await Hive.initFlutter();
        Hive.registerAdapter(PersonAdapter());
        Hive.registerAdapter(HealthReportAdapter());
        Hive.registerAdapter(HealthIndicatorAdapter());

        await Hive.openBox<Person>('persons');
        await Hive.openBox<HealthReport>('healthReports');
        await Hive.openBox<HealthIndicator>('healthIndicators');

        debugPrint('Hive recovered successfully');

        ref.read(hiveReadyProvider.notifier).state = true;

        await Future.delayed(const Duration(milliseconds: 300));
        setState(() => _initialized = true);
      } catch (e2) {
        debugPrint('Recovery failed: $e2');
        setState(() {
          _hasError = true;
          _status = '初始化失败，请重启应用';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(_status, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _hasError = false;
                        _status = '正在初始化...';
                      });
                      _initApp();
                    },
                    child: const Text('重试'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (!_initialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: Scaffold(
          backgroundColor: const Color(0xFFF5F5F7),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo或图标
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF007AFF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  '健康管理',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 32),
                // 进度指示器
                const SizedBox(
                  width: 200,
                  child: LinearProgressIndicator(
                    backgroundColor: Color(0xFFE0E0E0),
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF007AFF)),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _status,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 初始化完成，显示主界面
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