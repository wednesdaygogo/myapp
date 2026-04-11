# 健康报告趋势功能 + 蜡笔美学UI 实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 为健康管理APP添加多报告趋势功能，并将全部UI改造为蜡笔美学风格。

**Architecture:** 采用Flutter + Riverpod架构。数据层新增Provider支持报告统计和指标历史查询。UI层创建蜡笔风格组件库，改造所有现有页面。趋势图使用fl_chart库绘制。

**Tech Stack:** Flutter, Riverpod 2.x, Hive, fl_chart ^0.68.0, go_router

---

## 文件结构

### 新增文件
```
lib/core/theme/
├── crayon_theme.dart              # 蜡笔配色常量

lib/core/widgets/
├── crayon_card.dart               # 手绘边框卡片
├── crayon_button.dart             # 涂鸦风格按钮  
├── crayon_avatar.dart             # 蜡笔头像组件
├── crayon_input.dart              # 手绘输入框
├── crayon_segmented_button.dart   # 涂鸦分段按钮
├── crayon_painters.dart           # 手绘效果CustomPainter
├── crayon_background.dart         # 纸张纹理背景
└── indicator_trend_chart.dart     # 趋势图组件

lib/features/health_report/
├── providers/report_stats_provider.dart    # 报告统计Provider
├── providers/indicator_history_provider.dart # 指标历史Provider
└── ui/pages/person_report_detail_page.dart # 家人报告详情页

lib/domain/entities/
├── person_report_stats.dart       # 报告统计数据结构
├── indicator_data_point.dart      # 指标数据点
└── indicator_query.dart           # 指标查询参数

assets/
├── textures/paper_texture.png     # 纸张纹理（程序生成）
├── icons/star.svg                 # 星星图标（程序生成）
└── avatars/                       # 预设头像（程序生成）

test/
├── core/widgets/crayon_widgets_test.dart
├── features/health_report/providers/report_stats_test.dart
├── features/health_report/providers/indicator_history_test.dart
└── integration/report_trend_flow_test.dart
```

### 修改文件
```
pubspec.yaml                       # 添加fl_chart依赖、assets配置
lib/main.dart                      # 注册assets
lib/core/router/app_router.dart    # 新增/reports/person/:id路由
lib/features/health_report/ui/pages/report_list_page.dart # 改造为家人卡片列表
lib/features/person/ui/pages/person_list_page.dart        # 蜡笔风格改造
lib/features/person/ui/pages/person_detail_page.dart      # 蜡笔风格改造
lib/features/person/ui/pages/person_form_page.dart        # 蜡笔风格改造
lib/features/family_tree/ui/pages/family_tree_page.dart   # 蜡笔风格改造
```

---

## Phase 1: 数据层基础

### Task 1: 添加fl_chart依赖和assets配置

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: 添加fl_chart依赖和assets配置**

```yaml
# 在dependencies部分添加
dependencies:
  fl_chart: ^0.68.0

# 在flutter部分添加assets
flutter:
  assets:
    - assets/textures/
    - assets/icons/
    - assets/avatars/
```

- [ ] **Step 2: 运行flutter pub get**

Run: `flutter pub get`
Expected: 成功安装依赖

- [ ] **Step 3: 创建assets目录结构**

Run: `mkdir -p assets/textures assets/icons assets/avatars`
Expected: 目录创建成功

- [ ] **Step 4: Commit**

```bash
git add pubspec.yaml
git commit -m "chore: add fl_chart dependency and assets configuration"
```

---

### Task 2: 创建报告统计数据结构

**Files:**
- Create: `lib/domain/entities/person_report_stats.dart`
- Create: `lib/domain/entities/indicator_data_point.dart`
- Create: `lib/domain/entities/indicator_query.dart`

- [ ] **Step 1: 创建PersonReportStats类**

```dart
// lib/domain/entities/person_report_stats.dart
class PersonReportStats {
  final int personId;
  final int reportCount;
  final DateTime? latestReportDate;

  const PersonReportStats({
    required this.personId,
    required this.reportCount,
    this.latestReportDate,
  });

  String get latestReportDateText {
    if (latestReportDate == null) return '';
    return '${latestReportDate!.year}-${latestReportDate!.month.toString().padLeft(2, '0')}';
  }
}
```

- [ ] **Step 2: 创建IndicatorDataPoint类**

```dart
// lib/domain/entities/indicator_data_point.dart
class IndicatorDataPoint {
  final DateTime date;
  final double value;
  final double? secondValue; // 血压舒张压
  final int reportId;
  final bool isAbnormal;

  const IndicatorDataPoint({
    required this.date,
    required this.value,
    this.secondValue,
    required this.reportId,
    this.isAbnormal = false,
  });
}
```

- [ ] **Step 3: 创建IndicatorQuery类**

```dart
// lib/domain/entities/indicator_query.dart
class IndicatorQuery {
  final int personId;
  final String indicatorType; // '血糖'/'血压'/'血脂'/自定义名称

  const IndicatorQuery({
    required this.personId,
    required this.indicatorType,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IndicatorQuery &&
          personId == other.personId &&
          indicatorType == other.indicatorType;

  @override
  int get hashCode => Object.hash(personId, indicatorType);
}
```

- [ ] **Step 4: Commit**

```bash
git add lib/domain/entities/
git commit -m "feat: add report stats and indicator history data structures"
```

---

### Task 3: 创建报告统计Provider

**Files:**
- Create: `lib/features/health_report/providers/report_stats_provider.dart`

- [ ] **Step 1: 创建personReportStatsProvider**

```dart
// lib/features/health_report/providers/report_stats_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/person_report_stats.dart';
import '../../../data/models/health_report.dart';
import '../providers/health_report_provider.dart';

/// 单个家人的报告统计
final personReportStatsProvider = Provider.family<PersonReportStats, int>((ref, personId) {
  final allReports = ref.watch(healthReportsProvider);
  final personReports = allReports.where((r) => r.personId == personId).toList();
  
  if (personReports.isEmpty) {
    return PersonReportStats(personId: personId, reportCount: 0);
  }
  
  // 按日期排序，取最近
  personReports.sort((a, b) => b.reportDate.compareTo(a.reportDate));
  final latestDate = personReports.first.reportDate;
  
  return PersonReportStats(
    personId: personId,
    reportCount: personReports.length,
    latestReportDate: latestDate,
  );
});

/// 所有家人的报告统计列表
final personsWithReportStatsProvider = Provider<List<PersonWithStats>>((ref) {
  final allReports = ref.watch(healthReportsProvider);
  final persons = ref.watch(personsProvider);
  
  return persons.map((person) {
    final reports = allReports.where((r) => r.personId == person.id).toList();
    reports.sort((a, b) => b.reportDate.compareTo(a.reportDate));
    
    return PersonWithStats(
      person: person,
      stats: PersonReportStats(
        personId: person.id,
        reportCount: reports.length,
        latestReportDate: reports.isEmpty ? null : reports.first.reportDate,
      ),
    );
  }).toList();
});

/// 家人+统计组合结构
class PersonWithStats {
  final Person person;
  final PersonReportStats stats;
  
  const PersonWithStats({required this.person, required this.stats});
}
```

- [ ] **Step 2: 添加必要imports**

需要在文件顶部添加：
```dart
import '../../../data/models/person.dart';
import '../../person/providers/person_provider.dart';
```

- [ ] **Step 3: Commit**

```bash
git add lib/features/health_report/providers/report_stats_provider.dart
git commit -m "feat: add person report stats providers"
```

---

### Task 4: 创建指标历史Provider

**Files:**
- Create: `lib/features/health_report/providers/indicator_history_provider.dart`

- [ ] **Step 1: 创建indicatorHistoryProvider**

```dart
// lib/features/health_report/providers/indicator_history_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../domain/entities/indicator_data_point.dart';
import '../../../domain/entities/indicator_query.dart';
import '../../../data/models/health_indicator.dart';
import '../../../data/models/health_report.dart';
import 'health_report_provider.dart';

const String healthIndicatorsBoxName = 'healthIndicators';

/// 指标历史数据Provider
final indicatorHistoryProvider = Provider.family<List<IndicatorDataPoint>, IndicatorQuery>((ref, query) {
  final reports = ref.watch(healthReportsProvider);
  final personReports = reports.where((r) => r.personId == query.personId).toList();
  
  // 按日期排序
  personReports.sort((a, b) => a.reportDate.compareTo(b.reportDate));
  
  final dataPoints = <IndicatorDataPoint>[];
  final indicatorBox = Hive.box<HealthIndicator>(healthIndicatorsBoxName);
  
  for (final report in personReports) {
    final indicators = indicatorBox.values.where((i) => i.reportId == report.id).toList();
    final matchingIndicator = indicators.where((i) => i.type == query.indicatorType).firstOrNull;
    
    if (matchingIndicator != null) {
      dataPoints.add(IndicatorDataPoint(
        date: report.reportDate,
        value: matchingIndicator.value,
        secondValue: matchingIndicator.secondValue,
        reportId: report.id,
        isAbnormal: matchingIndicator.isAbnormal,
      ));
    }
  }
  
  return dataPoints;
});

/// 某家人的所有指标类型列表（用于选择器）
final indicatorTypesByPersonProvider = Provider.family<List<String>, int>((ref, personId) {
  final reports = ref.watch(healthReportsProvider);
  final personReports = reports.where((r) => r.personId == personId).toList();
  
  final types = <String>{};
  final indicatorBox = Hive.box<HealthIndicator>(healthIndicatorsBoxName);
  
  for (final report in personReports) {
    final indicators = indicatorBox.values.where((i) => i.reportId == report.id);
    for (final indicator in indicators) {
      types.add(indicator.type);
    }
  }
  
  // 固定类型排序
  final fixedTypes = ['血糖', '血压', '血脂'];
  final customTypes = types.where((t) => !fixedTypes.contains(t)).toList();
  
  return [...fixedTypes, ...customTypes];
});
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/health_report/providers/indicator_history_provider.dart
git commit -m "feat: add indicator history provider for trend charts"
```

---

### Task 5: 新增报告详情页路由

**Files:**
- Modify: `lib/core/router/app_router.dart`

- [ ] **Step 1: 在routes数组中添加新路由**

在现有 `/reports/:id` 路由之前添加：

```dart
GoRoute(
  path: '/reports/person/:personId',
  builder: (context, state) {
    final personId = int.tryParse(state.pathParameters['personId'] ?? '') ?? 0;
    return PersonReportDetailPage(personId: personId);
  },
),
```

- [ ] **Step 2: 添加import**

在文件顶部添加：
```dart
import '../../features/health_report/ui/pages/person_report_detail_page.dart';
```

- [ ] **Step 3: Commit**

```bash
git add lib/core/router/app_router.dart
git commit -m "feat: add person report detail page route"
```

---

## Phase 2: 蜡笔风格组件库

### Task 6: 创建蜡笔配色主题

**Files:**
- Create: `lib/core/theme/crayon_theme.dart`

- [ ] **Step 1: 创建CrayonTheme类**

```dart
// lib/core/theme/crayon_theme.dart
import 'package:flutter/material.dart';

/// 蜡笔美学配色（温暖大地色系）
class CrayonTheme {
  CrayonTheme._();

  // 核心颜色
  static const Color forestGreen = Color(0xFF4A7C59);
  static const Color mustardYellow = Color(0xFFE5B844);
  static const Color brickRed = Color(0xFFB8472A);
  static const Color creamWhite = Color(0xFFF5F1E6);
  static const Color darkBrown = Color(0xFF3D2914);
  static const Color softPink = Color(0xFFF8E4E1);
  
  // 辅助颜色
  static const Color lightGreen = Color(0xFF6B9B7A);
  static const Color warmOrange = Color(0xFFD4956A);
  static const Color skyBlue = Color(0xFF7BA3C9);
  
  // 间距
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  
  // 圆角（手绘风格，稍大）
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  
  // 手绘边框参数
  static const double borderWiggleAmount = 3.0; // 歪扭幅度
  static const double borderWidth = 2.5;
  
  // 获取蜡笔风格文字主题
  static TextTheme get crayonTextTheme => const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w600,
      color: darkBrown,
      letterSpacing: 0.5,
    ),
    headlineMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: darkBrown,
      letterSpacing: 0.3,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w500,
      color: darkBrown,
      letterSpacing: 0.2,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: darkBrown,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: darkBrown,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: darkBrown,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: darkBrown,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: forestGreen,
    ),
  );
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/core/theme/crayon_theme.dart
git commit -m "feat: add crayon theme color constants"
```

---

### Task 7: 创建手绘效果绘制器

**Files:**
- Create: `lib/core/widgets/crayon_painters.dart`

- [ ] **Step 1: 创建WigglyBorderPainter**

```dart
// lib/core/widgets/crayon_painters.dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/crayon_theme.dart';

/// 手绘歪扭边框绘制器
class WigglyBorderPainter extends CustomPainter {
  final Color borderColor;
  final double borderWidth;
  final double wiggleAmount;
  final double radius;
  
  WigglyBorderPainter({
    this.borderColor = CrayonTheme.darkBrown,
    this.borderWidth = CrayonTheme.borderWidth,
    this.wiggleAmount = CrayonTheme.borderWiggleAmount,
    this.radius = CrayonTheme.radiusMd,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      .color = borderColor
      .strokeWidth = borderWidth
      .style = PaintingStyle.stroke
      .strokeCap = StrokeCap.round
      .strokeJoin = StrokeJoin.round;
    
    final path = _createWigglyRRectPath(size);
    canvas.drawPath(path, paint);
  }
  
  Path _createWigglyRRectPath(Size size) {
    final path = Path();
    final wiggle = wiggleAmount;
    
    // 生成随机偏移的圆角矩形路径
    // 左上角
    path.moveTo(
      radius + _randomOffset(wiggle),
      wiggle + _randomOffset(wiggle),
    );
    
    // 顶边
    path.lineTo(
      size.width - radius + _randomOffset(wiggle),
      wiggle + _randomOffset(wiggle),
    );
    
    // 右上角弧
    path.arcToPoint(
      Offset(size.width - wiggle + _randomOffset(wiggle), radius + _randomOffset(wiggle)),
      radius: Radius.circular(radius),
    );
    
    // 右边
    path.lineTo(
      size.width - wiggle + _randomOffset(wiggle),
      size.height - radius + _randomOffset(wiggle),
    );
    
    // 右下角弧
    path.arcToPoint(
      Offset(size.width - radius + _randomOffset(wiggle), size.height - wiggle + _randomOffset(wiggle)),
      radius: Radius.circular(radius),
    );
    
    // 底边
    path.lineTo(
      radius + _randomOffset(wiggle),
      size.height - wiggle + _randomOffset(wiggle),
    );
    
    // 左下角弧
    path.arcToPoint(
      Offset(wiggle + _randomOffset(wiggle), size.height - radius + _randomOffset(wiggle)),
      radius: Radius.circular(radius),
    );
    
    // 左边
    path.lineTo(
      wiggle + _randomOffset(wiggle),
      radius + _randomOffset(wiggle),
    );
    
    // 左上角弧（闭合）
    path.arcToPoint(
      Offset(radius + _randomOffset(wiggle), wiggle + _randomOffset(wiggle)),
      radius: Radius.circular(radius),
    );
    
    return path;
  }
  
  double _randomOffset(double amount) {
    // 使用固定种子确保一致性（同一组件重绘时路径相同）
    return (DateTime.now().microsecondsSinceEpoch % 1000 / 500 - 1) * amount * 0.3;
  }
  
  @override
  bool shouldRepaint(covariant WigglyBorderPainter oldDelegate) {
    return borderColor != oldDelegate.borderColor || borderWidth != oldDelegate.borderWidth;
  }
}

/// 蜡笔风格折线绘制器（用于图表）
class CrayonLinePainter extends CustomPainter {
  final List<Offset> points;
  final Color lineColor;
  final double lineWidth;
  
  CrayonLinePainter({
    required this.points,
    this.lineColor = CrayonTheme.mustardYellow,
    this.lineWidth = 3.0,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    
    final paint = Paint()
      .color = lineColor
      .strokeWidth = lineWidth
      .style = PaintingStyle.stroke
      .strokeCap = StrokeCap.round;
    
    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);
    
    for (int i = 1; i < points.length; i++) {
      // 添加微小抖动模拟蜡笔效果
      final wiggle = 1.5;
      final dx = points[i].dx + (i % 2 == 0 ? wiggle : -wiggle);
      final dy = points[i].dy + ((i + 1) % 2 == 0 ? wiggle : -wiggle);
      path.lineTo(dx, dy);
    }
    
    canvas.drawPath(path, paint);
    
    // 绘制数据点
    for (final point in points) {
      canvas.drawCircle(point, 6, Paint()..color = lineColor);
    }
  }
  
  @override
  bool shouldRepaint(covariant CrayonLinePainter oldDelegate) {
    return points != oldDelegate.points || lineColor != oldDelegate.lineColor;
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/core/widgets/crayon_painters.dart
git commit -m "feat: add wiggly border and crayon line painters"
```

---

### Task 8: 创建纸张纹理背景组件

**Files:**
- Create: `lib/core/widgets/crayon_background.dart`

- [ ] **Step 1: 创建CrayonBackground组件**

```dart
// lib/core/widgets/crayon_background.dart
import 'package:flutter/material.dart';
import '../theme/crayon_theme.dart';

/// 纸张纹理背景（使用程序生成的噪点纹理）
class CrayonBackground extends StatelessWidget {
  final Widget child;
  
  const CrayonBackground({super.key, required this.child});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: CrayonTheme.creamWhite,
      child: Stack(
        children: [
          // 纹理层（使用CustomPaint生成噪点）
          Positioned.fill(
            child: CustomPaint(
              painter: _PaperTexturePainter(),
            ),
          ),
          // 内容层
          child,
        ],
      ),
    );
  }
}

/// 纸张纹理绘制器
class _PaperTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 绘制微妙的噪点纹理
    final paint = Paint()..color = Colors.white.withOpacity(0.03);
    
    for (int i = 0; i < size.width; i += 4) {
      for (int j = 0; j < size.height; j += 4) {
        if ((i + j) % 8 == 0) {
          canvas.drawRect(
            Rect.fromLTWH(i.toDouble(), j.toDouble(), 2, 2),
            paint,
          );
        }
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant _PaperTexturePainter oldDelegate) => false;
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/core/widgets/crayon_background.dart
git commit -m "feat: add crayon paper texture background widget"
```

---

### Task 9: 创建蜡笔卡片组件

**Files:**
- Create: `lib/core/widgets/crayon_card.dart`

- [ ] **Step 1: 创建CrayonCard组件**

```dart
// lib/core/widgets/crayon_card.dart
import 'package:flutter/material.dart';
import '../theme/crayon_theme.dart';
import 'crayon_painters.dart';

/// 蜡笔风格卡片（手绘边框）
class CrayonCard extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final Color borderColor;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  
  const CrayonCard({
    super.key,
    required this.child,
    this.backgroundColor = CrayonTheme.creamWhite,
    this.borderColor = CrayonTheme.darkBrown,
    this.padding = const EdgeInsets.all(CrayonTheme.spacingMd),
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(CrayonTheme.radiusMd),
        ),
        child: Stack(
          children: [
            child,
            // 手绘边框
            Positioned.fill(
              child: CustomPaint(
                painter: WigglyBorderPainter(
                  borderColor: borderColor,
                  radius: CrayonTheme.radiusMd,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/core/widgets/crayon_card.dart
git commit -m "feat: add crayon card widget with wiggly border"
```

---

### Task 10: 创建蜡笔按钮组件

**Files:**
- Create: `lib/core/widgets/crayon_button.dart`

- [ ] **Step 1: 创建CrayonButton组件**

```dart
// lib/core/widgets/crayon_button.dart
import 'package:flutter/material.dart';
import '../theme/crayon_theme.dart';
import 'crayon_painters.dart';

/// 蜡笔风格按钮
class CrayonButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final CrayonButtonType type;
  final bool isFullWidth;
  
  const CrayonButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.type = CrayonButtonType.primary,
    this.isFullWidth = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final colors = _getColors();
    
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: isFullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(
          horizontal: CrayonTheme.spacingLg,
          vertical: CrayonTheme.spacingMd,
        ),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(CrayonTheme.radiusMd),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null)
                  Icon(icon, color: colors.text, size: 20),
                if (icon != null) const SizedBox(width: CrayonTheme.spacingSm),
                Text(
                  text,
                  style: TextStyle(
                    color: colors.text,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            // 手绘边框
            Positioned.fill(
              child: CustomPaint(
                painter: WigglyBorderPainter(
                  borderColor: colors.border,
                  radius: CrayonTheme.radiusMd,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  _ButtonColors _getColors() {
    switch (type) {
      case CrayonButtonType.primary:
        return _ButtonColors(
          background: CrayonTheme.mustardYellow,
          text: CrayonTheme.darkBrown,
          border: CrayonTheme.darkBrown,
        );
      case CrayonButtonType.secondary:
        return _ButtonColors(
          background: CrayonTheme.forestGreen,
          text: Colors.white,
          border: CrayonTheme.forestGreen,
        );
      case CrayonButtonType.danger:
        return _ButtonColors(
          background: CrayonTheme.brickRed,
          text: Colors.white,
          border: CrayonTheme.brickRed,
        );
    }
  }
}

enum CrayonButtonType { primary, secondary, danger }

class _ButtonColors {
  final Color background;
  final Color text;
  final Color border;
  
  _ButtonColors({required this.background, required this.text, required this.border});
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/core/widgets/crayon_button.dart
git commit -m "feat: add crayon button widget with primary/secondary/danger types"
```

---

### Task 11: 创建蜡笔头像组件

**Files:**
- Create: `lib/core/widgets/crayon_avatar.dart`

- [ ] **Step 1: 创建CrayonAvatar组件**

```dart
// lib/core/widgets/crayon_avatar.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/crayon_theme.dart';
import 'crayon_painters.dart';

/// 预设头像列表
class PresetAvatars {
  static const List<String> names = ['bear', 'fox', 'cat', 'dog', 'panda', 'polar_bear', 'rabbit', 'owl'];
  
  static String getAssetPath(String name) => 'assets/avatars/$name.svg';
  
  // 显示名称映射（暂时用emoji代替SVG）
  static const Map<String, String> emojiMap = {
    'bear': '🐻',
    'fox': '🦊',
    'cat': '🐱',
    'dog': '🐶',
    'panda': '🐼',
    'polar_bear': '🐻‍❄️',
    'rabbit': '🐰',
    'owl': '🦉',
  };
}

/// 蜡笔风格头像
class CrayonAvatar extends StatelessWidget {
  final String? presetName;     // 预设头像名称
  final String? customImagePath; // 用户上传图片路径
  final double size;
  final Color borderColor;
  
  const CrayonAvatar({
    super.key,
    this.presetName,
    this.customImagePath,
    this.size = 60,
    this.borderColor = CrayonTheme.darkBrown,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: CrayonTheme.creamWhite,
      ),
      child: Stack(
        children: [
          // 头像内容
          Center(
            child: _buildAvatarContent(),
          ),
          // 手绘圆形边框
          Positioned.fill(
            child: CustomPaint(
              painter: _WigglyCirclePainter(
                borderColor: borderColor,
                borderWidth: CrayonTheme.borderWidth,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAvatarContent() {
    if (customImagePath != null && customImagePath!.isNotEmpty) {
      return ClipOval(
        child: Image.file(
          File(customImagePath!),
          width: size - 8,
          height: size - 8,
          fit: BoxFit.cover,
        ),
      );
    }
    
    if (presetName != null) {
      // 使用emoji暂时代替SVG
      final emoji = PresetAvatars.emojiMap[presetName!] ?? '👤';
      return Text(
        emoji,
        style: TextStyle(fontSize: size * 0.5),
      );
    }
    
    // 默认图标
    return Icon(
      Icons.person,
      size: size * 0.5,
      color: CrayonTheme.textSecondary,
    );
  }
}

/// 手绘圆形边框绘制器
class _WigglyCirclePainter extends CustomPainter {
  final Color borderColor;
  final double borderWidth;
  
  _WigglyCirclePainter({
    required this.borderColor,
    required this.borderWidth,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      .color = borderColor
      .strokeWidth = borderWidth
      .style = PaintingStyle.stroke
      .strokeCap = StrokeCap.round;
    
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - borderWidth;
    
    // 绘制带抖动的圆
    final path = Path();
    const segments = 32;
    
    for (int i = 0; i <= segments; i++) {
      final angle = (i / segments) * 2 * pi;
      final wiggle = (sin(angle * 4) * 1.5).clamp(-2.0, 2.0);
      final x = center.dx + (radius + wiggle) * cos(angle);
      final y = center.dy + (radius + wiggle) * sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant _WigglyCirclePainter oldDelegate) {
    return borderColor != oldDelegate.borderColor;
  }
}
```

需要在文件顶部添加：
```dart
import 'dart:math';
```

- [ ] **Step 2: Commit**

```bash
git add lib/core/widgets/crayon_avatar.dart
git commit -m "feat: add crayon avatar widget with preset emoji avatars"
```

---

### Task 12: 创建蜡笔分段按钮组件

**Files:**
- Create: `lib/core/widgets/crayon_segmented_button.dart`

- [ ] **Step 1: 创建CrayonSegmentedButton组件**

```dart
// lib/core/widgets/crayon_segmented_button.dart
import 'package:flutter/material.dart';
import '../theme/crayon_theme.dart';

/// 蜡笔风格分段按钮（用于选择器）
class CrayonSegmentedButton<T> extends StatelessWidget {
  final List<_SegmentOption<T>> options;
  final T selectedValue;
  final ValueChanged<T>? onSelectionChanged;
  
  const CrayonSegmentedButton({
    super.key,
    required this.options,
    required this.selectedValue,
    this.onSelectionChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: CrayonTheme.spacingSm,
      runSpacing: CrayonTheme.spacingSm,
      children: options.map((option) {
        final isSelected = option.value == selectedValue;
        return GestureDetector(
          onTap: () => onSelectionChanged?.call(option.value),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: CrayonTheme.spacingMd,
              vertical: CrayonTheme.spacingSm,
            ),
            decoration: BoxDecoration(
              color: isSelected ? CrayonTheme.forestGreen : CrayonTheme.creamWhite,
              borderRadius: BorderRadius.circular(CrayonTheme.radiusSm),
              border: Border.all(
                color: isSelected ? CrayonTheme.forestGreen : CrayonTheme.darkBrown.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (option.icon != null)
                  Icon(
                    option.icon,
                    size: 16,
                    color: isSelected ? Colors.white : CrayonTheme.darkBrown,
                  ),
                if (option.icon != null) const SizedBox(width: 4),
                Text(
                  option.label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : CrayonTheme.darkBrown,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                if (isSelected)
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Text('✨', style: TextStyle(fontSize: 12)),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SegmentOption<T> {
  final T value;
  final String label;
  final IconData? icon;
  
  const _SegmentOption({
    required this.value,
    required this.label,
    this.icon,
  });
  
  // 便捷构造方法
  static _SegmentOption<T> create<T>(T value, String label, {IconData? icon}) {
    return _SegmentOption<T>(value: value, label: label, icon: icon);
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/core/widgets/crayon_segmented_button.dart
git commit -m "feat: add crayon segmented button widget for selectors"
```

---

### Task 13: 创建蜡笔输入框组件

**Files:**
- Create: `lib/core/widgets/crayon_input.dart`

- [ ] **Step 1: 创建CrayonInput组件**

```dart
// lib/core/widgets/crayon_input.dart
import 'package:flutter/material.dart';
import '../theme/crayon_theme.dart';
import 'crayon_painters.dart';

/// 蜡笔风格输入框
class CrayonInput extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final bool isRequired;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final Widget? suffixIcon;
  final bool readOnly;
  final VoidCallback? onTap;
  
  const CrayonInput({
    super.key,
    this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.isRequired = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.suffixIcon,
    this.readOnly = false,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: CrayonTheme.spacingSm),
            child: Row(
              children: [
                Text(
                  label!,
                  style: const TextStyle(
                    color: CrayonTheme.darkBrown,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                if (isRequired)
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Text('✏️', style: TextStyle(fontSize: 12)),
                  ),
              ],
            ),
          ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: CrayonTheme.spacingMd,
            vertical: CrayonTheme.spacingSm,
          ),
          decoration: BoxDecoration(
            color: CrayonTheme.creamWhite,
            borderRadius: BorderRadius.circular(CrayonTheme.radiusSm),
          ),
          child: Stack(
            children: [
              TextFormField(
                controller: controller,
                initialValue: initialValue,
                keyboardType: keyboardType,
                validator: validator,
                onChanged: onChanged,
                readOnly: readOnly,
                onTap: onTap,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(color: CrayonTheme.darkBrown.withOpacity(0.4)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  suffixIcon: suffixIcon,
                ),
                style: const TextStyle(
                  color: CrayonTheme.darkBrown,
                  fontSize: 14,
                ),
              ),
              // 手绘边框
              Positioned.fill(
                child: CustomPaint(
                  painter: WigglyBorderPainter(
                    borderColor: CrayonTheme.darkBrown.withOpacity(0.6),
                    radius: CrayonTheme.radiusSm,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/core/widgets/crayon_input.dart
git commit -m "feat: add crayon input widget with wiggly border"
```

---

## Phase 3: 趋势图组件

### Task 14: 创建趋势图组件

**Files:**
- Create: `lib/core/widgets/indicator_trend_chart.dart`

- [ ] **Step 1: 创建IndicatorTrendChart组件**

```dart
// lib/core/widgets/indicator_trend_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/crayon_theme.dart';
import '../../domain/entities/indicator_data_point.dart';
import 'package:intl/intl.dart';

/// 指标趋势图组件
class IndicatorTrendChart extends StatelessWidget {
  final String indicatorType;
  final List<IndicatorDataPoint> dataPoints;
  final double height;
  
  const IndicatorTrendChart({
    super.key,
    required this.indicatorType,
    required this.dataPoints,
    this.height = 200,
  });
  
  @override
  Widget build(BuildContext context) {
    if (dataPoints.isEmpty) {
      return _buildEmptyState();
    }
    
    if (dataPoints.length == 1) {
      return _buildSinglePointState();
    }
    
    return Container(
      height: height,
      padding: const EdgeInsets.all(CrayonTheme.spacingMd),
      decoration: BoxDecoration(
        color: CrayonTheme.creamWhite,
        borderRadius: BorderRadius.circular(CrayonTheme.radiusMd),
      ),
      child: Column(
        children: [
          // 标题
          Text(
            '📈 $indicatorType 趋势',
            style: const TextStyle(
              color: CrayonTheme.darkBrown,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: CrayonTheme.spacingMd),
          // 图表
          Expanded(
            child: _buildChart(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Container(
      height: height,
      padding: const EdgeInsets.all(CrayonTheme.spacingMd),
      decoration: BoxDecoration(
        color: CrayonTheme.creamWhite,
        borderRadius: BorderRadius.circular(CrayonTheme.radiusMd),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.show_chart, size: 40, color: CrayonTheme.forestGreen),
          const SizedBox(height: CrayonTheme.spacingMd),
          Text('暂无$indicatorType数据', style: const TextStyle(color: CrayonTheme.darkBrown)),
          const SizedBox(height: CrayonTheme.spacingSm),
          Text('添加更多体检报告可查看趋势', style: TextStyle(color: CrayonTheme.darkBrown.withOpacity(0.6), fontSize: 12)),
        ],
      ),
    );
  }
  
  Widget _buildSinglePointState() {
    final point = dataPoints.first;
    return Container(
      height: height,
      padding: const EdgeInsets.all(CrayonTheme.spacingMd),
      decoration: BoxDecoration(
        color: CrayonTheme.creamWhite,
        borderRadius: BorderRadius.circular(CrayonTheme.radiusMd),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.star, size: 40, color: CrayonTheme.mustardYellow),
          const SizedBox(height: CrayonTheme.spacingMd),
          Text(
            _formatValue(point.value, point.secondValue),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: CrayonTheme.darkBrown),
          ),
          const SizedBox(height: CrayonTheme.spacingSm),
          Text(
            DateFormat('yyyy-MM').format(point.date),
            style: TextStyle(color: CrayonTheme.forestGreen, fontSize: 12),
          ),
          const SizedBox(height: CrayonTheme.spacingMd),
          Text('仅有一份报告，添加更多可查看趋势', style: TextStyle(color: CrayonTheme.darkBrown.withOpacity(0.6), fontSize: 12)),
        ],
      ),
    );
  }
  
  Widget _buildChart() {
    final spots = dataPoints.map((point) {
      final x = point.date.millisecondsSinceEpoch.toDouble();
      final y = point.value;
      return FlSpot(x, y);
    }).toList();
    
    // 计算Y轴范围
    final values = dataPoints.map((p) => p.value).toList();
    final minY = (values.reduce((a, b) => a < b ? a : b) * 0.9).floorToDouble();
    final maxY = (values.reduce((a, b) => a > b ? a : b) * 1.1).ceilToDouble();
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxY - minY) / 4,
          getDrawingHorizontalLine: (value) => FlLine(
            color: CrayonTheme.forestGreen.withOpacity(0.2),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(
                value.toStringAsFixed(1),
                style: const TextStyle(color: CrayonTheme.darkBrown, fontSize: 10),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                return Text(
                  DateFormat('MM/dd').format(date),
                  style: const TextStyle(color: CrayonTheme.darkBrown, fontSize: 10),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: CrayonTheme.darkBrown.withOpacity(0.3)),
        ),
        minX: spots.first.x,
        maxX: spots.last.x,
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: false,
            color: CrayonTheme.mustardYellow,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                final point = dataPoints[index];
                return FlDotCirclePainter(
                  radius: 6,
                  color: point.isAbnormal ? CrayonTheme.brickRed : CrayonTheme.mustardYellow,
                  strokeWidth: 2,
                  strokeColor: CrayonTheme.darkBrown,
                );
              },
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => CrayonTheme.creamWhite,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.spotIndex;
                final point = dataPoints[index];
                return LineTooltipItem(
                  '${_formatValue(point.value, point.secondValue)}\n${DateFormat('yyyy-MM-dd').format(point.date)}',
                  const TextStyle(color: CrayonTheme.darkBrown, fontSize: 12),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
  
  String _formatValue(double value, double? secondValue) {
    if (secondValue != null) {
      return '${value.toInt()}/${secondValue.toInt()}';
    }
    return value.toStringAsFixed(1);
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/core/widgets/indicator_trend_chart.dart
git commit -m "feat: add indicator trend chart widget using fl_chart"
```

---

## Phase 4: 页面改造

### Task 15: 创建家人报告详情页

**Files:**
- Create: `lib/features/health_report/ui/pages/person_report_detail_page.dart`

- [ ] **Step 1: 创建PersonReportDetailPage**

```dart
// lib/features/health_report/ui/pages/person_report_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/crayon_theme.dart';
import '../../../core/widgets/crayon_background.dart';
import '../../../core/widgets/crayon_card.dart';
import '../../../core/widgets/crayon_button.dart';
import '../../../core/widgets/crayon_segmented_button.dart';
import '../../../core/widgets/indicator_trend_chart.dart';
import '../../../core/widgets/crayon_avatar.dart';
import '../../../domain/entities/indicator_query.dart';
import '../../../data/models/health_report.dart';
import '../../../data/models/health_indicator.dart';
import '../../person/providers/person_provider.dart';
import '../providers/health_report_provider.dart';
import '../providers/report_stats_provider.dart';
import '../providers/indicator_history_provider.dart';

class PersonReportDetailPage extends ConsumerStatefulWidget {
  final int personId;
  
  const PersonReportDetailPage({super.key, required this.personId});
  
  @override
  ConsumerState<PersonReportDetailPage> createState() => _PersonReportDetailPageState();
}

class _PersonReportDetailPageState extends ConsumerState<PersonReportDetailPage> {
  int? _selectedReportId;
  String _selectedIndicatorType = '血糖';
  
  @override
  void initState() {
    super.initState();
    // 默认选择最近的报告
    Future.microtask(() {
      final reports = ref.read(personReportsProvider(widget.personId));
      if (reports.isNotEmpty) {
        setState(() {
          _selectedReportId = reports.first.id;
        });
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final person = ref.watch(personsProvider).where((p) => p.id == widget.personId).firstOrNull;
    final reports = ref.watch(personReportsProvider(widget.personId));
    final indicatorTypes = ref.watch(indicatorTypesByPersonProvider(widget.personId));
    
    if (person == null) {
      return Scaffold(body: Center(child: Text('未找到家人')));
    }
    
    return Scaffold(
      backgroundColor: CrayonTheme.creamWhite,
      appBar: AppBar(
        backgroundColor: CrayonTheme.creamWhite,
        title: Text('${person.name}的健康报告 ✨'),
        centerTitle: true,
        foregroundColor: CrayonTheme.darkBrown,
      ),
      body: CrayonBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(CrayonTheme.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 头像和名字
              Center(
                child: Column(
                  children: [
                    CrayonAvatar(
                      presetName: person.photoPath, // 暂用photoPath存储presetName
                      size: 80,
                    ),
                    const SizedBox(height: CrayonTheme.spacingSm),
                    Text(person.name, style: CrayonTheme.crayonTextTheme.titleLarge),
                  ],
                ),
              ),
              const SizedBox(height: CrayonTheme.spacingLg),
              
              // 报告选择器
              if (reports.isNotEmpty)
                CrayonCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('选择报告', style: CrayonTheme.crayonTextTheme.titleMedium),
                      const SizedBox(height: CrayonTheme.spacingSm),
                      Wrap(
                        spacing: CrayonTheme.spacingSm,
                        children: reports.map((report) {
                          final isSelected = report.id == _selectedReportId;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedReportId = report.id),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: CrayonTheme.spacingMd, vertical: CrayonTheme.spacingSm),
                              decoration: BoxDecoration(
                                color: isSelected ? CrayonTheme.forestGreen : CrayonTheme.creamWhite,
                                borderRadius: BorderRadius.circular(CrayonTheme.radiusSm),
                                border: Border.all(color: isSelected ? CrayonTheme.forestGreen : CrayonTheme.darkBrown.withOpacity(0.5)),
                              ),
                              child: Text(
                                DateFormat('yyyy-MM').format(report.reportDate) + (isSelected ? ' ✨' : ''),
                                style: TextStyle(color: isSelected ? Colors.white : CrayonTheme.darkBrown, fontWeight: FontWeight.w500),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: CrayonTheme.spacingMd),
              
              // 当前报告指标
              if (_selectedReportId != null)
                CrayonCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('📊 当前指标', style: CrayonTheme.crayonTextTheme.titleMedium),
                      const SizedBox(height: CrayonTheme.spacingMd),
                      _buildIndicatorList(_selectedReportId!),
                    ],
                  ),
                ),
              const SizedBox(height: CrayonTheme.spacingMd),
              
              // 指标类型选择器
              if (indicatorTypes.isNotEmpty)
                CrayonCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('📈 指标趋势', style: CrayonTheme.crayonTextTheme.titleMedium),
                      const SizedBox(height: CrayonTheme.spacingSm),
                      CrayonSegmentedButton<String>(
                        options: indicatorTypes.map((type) => _SegmentOption.create(type, type)).toList(),
                        selectedValue: _selectedIndicatorType,
                        onSelectionChanged: (value) => setState(() => _selectedIndicatorType = value),
                      ),
                      const SizedBox(height: CrayonTheme.spacingMd),
                      // 趋势图
                      IndicatorTrendChart(
                        indicatorType: _selectedIndicatorType,
                        dataPoints: ref.watch(indicatorHistoryProvider(
                          IndicatorQuery(personId: widget.personId, indicatorType: _selectedIndicatorType),
                        )),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: CrayonTheme.spacingMd),
              
              // 空状态提示
              if (reports.isEmpty)
                CrayonCard(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.description_outlined, size: 48, color: CrayonTheme.forestGreen),
                      const SizedBox(height: CrayonTheme.spacingMd),
                      Text('暂无体检报告', style: CrayonTheme.crayonTextTheme.titleMedium),
                      const SizedBox(height: CrayonTheme.spacingSm),
                      Text('点击添加报告开始记录', style: TextStyle(color: CrayonTheme.darkBrown.withOpacity(0.6))),
                      const SizedBox(height: CrayonTheme.spacingLg),
                      CrayonButton(
                        text: '添加报告',
                        icon: Icons.add,
                        onPressed: () => context.go('/reports/import'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildIndicatorList(int reportId) {
    final indicators = ref.watch(indicatorsByReportProvider(reportId));
    
    if (indicators.isEmpty) {
      return const Text('暂无指标数据');
    }
    
    return Column(
      children: indicators.map((indicator) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: CrayonTheme.spacingSm),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: CrayonTheme.forestGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(CrayonTheme.radiusSm),
                ),
                child: Icon(Icons.favorite, size: 18, color: CrayonTheme.forestGreen),
              ),
              const SizedBox(width: CrayonTheme.spacingMd),
              Text(indicator.type, style: const TextStyle(color: CrayonTheme.darkBrown)),
              const Spacer(),
              Text(
                _formatIndicatorValue(indicator),
                style: TextStyle(
                  color: indicator.isAbnormal ? CrayonTheme.brickRed : CrayonTheme.darkBrown,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (!indicator.isAbnormal)
                const Padding(padding: EdgeInsets.only(left: 4), child: Text('⭐', style: TextStyle(fontSize: 14))),
            ],
          ),
        );
      }).toList(),
    );
  }
  
  String _formatIndicatorValue(HealthIndicator indicator) {
    if (indicator.secondValue != null) {
      return '${indicator.value.toInt()}/${indicator.secondValue!.toInt()} ${indicator.unit}';
    }
    return '${indicator.value.toStringAsFixed(1)} ${indicator.unit}';
  }
}
```

需要修复导入：
```dart
import '../../../core/widgets/crayon_segmented_button.dart' show CrayonSegmentedButton, _SegmentOption;
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/health_report/ui/pages/person_report_detail_page.dart
git commit -m "feat: add person report detail page with trend chart"
```

---

### Task 16: 改造报告列表页

**Files:**
- Modify: `lib/features/health_report/ui/pages/report_list_page.dart`

- [ ] **Step 1: 读取现有文件了解结构**

先读取现有代码确认结构。

- [ ] **Step 2: 改造为家人卡片列表**

将 `ReportListPage` 改造为按家人分组显示，使用蜡笔风格组件。主要改动：
- 使用 `CrayonBackground` 作为背景
- 使用 `CrayonCard` 显示每个家人卡片
- 显示：头像、姓名、报告数量、最近报告日期
- 点击跳转到 `/reports/person/:personId`

- [ ] **Step 3: Commit**

```bash
git add lib/features/health_report/ui/pages/report_list_page.dart
git commit -m "refactor: transform report list page to crayon-style family cards"
```

---

### Task 17: 改造家人列表页

**Files:**
- Modify: `lib/features/person/ui/pages/person_list_page.dart`

- [ ] **Step 1: 添加蜡笔组件imports**

```dart
import '../../../core/theme/crayon_theme.dart';
import '../../../core/widgets/crayon_background.dart';
import '../../../core/widgets/crayon_card.dart';
import '../../../core/widgets/crayon_button.dart';
import '../../../core/widgets/crayon_avatar.dart';
```

- [ ] **Step 2: 替换Scaffold背景**

将背景改为 `CrayonTheme.creamWhite`，body使用 `CrayonBackground` 包裹。

- [ ] **Step 3: 替换家人卡片**

使用 `CrayonCard` + `CrayonAvatar` 显示每个家人。

- [ ] **Step 4: 替换添加按钮**

使用 `CrayonButton` 替换 FloatingActionButton。

- [ ] **Step 5: 应用配色**

将 `AppTheme.xxx` 替换为 `CrayonTheme.xxx`。

- [ ] **Step 6: Commit**

```bash
git add lib/features/person/ui/pages/person_list_page.dart
git commit -m "refactor: transform person list page to crayon style"
```

---

### Task 18: 改造家人详情页

**Files:**
- Modify: `lib/features/person/ui/pages/person_detail_page.dart`

- [ ] **Step 1: 添加imports**

添加蜡笔组件imports。

- [ ] **Step 2: 替换背景和头像**

使用 `CrayonBackground`，头像使用 `CrayonAvatar`。

- [ ] **Step 3: 替换信息卡片**

使用 `CrayonCard` 替换 `_buildInfoCard`。

- [ ] **Step 4: 添加报告区域**

底部添加健康报告摘要区域，点击跳转到 `/reports/person/:personId`。

- [ ] **Step 5: Commit**

```bash
git add lib/features/person/ui/pages/person_detail_page.dart
git commit -m "refactor: transform person detail page to crayon style"
```

---

### Task 19: 改造家人表单页

**Files:**
- Modify: `lib/features/person/ui/pages/person_form_page.dart`

- [ ] **Step 1: 添加头像选择区域**

添加预设头像选择器：
```dart
Wrap(
  spacing: CrayonTheme.spacingSm,
  children: PresetAvatars.names.map((name) {
    return GestureDetector(
      onTap: () => setState(() => _selectedAvatar = name),
      child: Container(
        decoration: BoxDecoration(
          border: _selectedAvatar == name ? Border.all(color: CrayonTheme.forestGreen, width: 2) : null,
        ),
        child: Text(PresetAvatars.emojiMap[name]!, style: TextStyle(fontSize: 32)),
      ),
    );
  }).toList(),
)
```

- [ ] **Step 2: 替换输入框和按钮**

使用 `CrayonInput` 和 `CrayonButton`。

- [ ] **Step 3: Commit**

```bash
git add lib/features/person/ui/pages/person_form_page.dart
git commit -m "refactor: transform person form page to crayon style with avatar selector"
```

---

### Task 20: 改造家谱图谱页

**Files:**
- Modify: `lib/features/family_tree/ui/pages/family_tree_page.dart`

- [ ] **Step 1: 改造节点样式**

节点颜色方案：
```dart
Color getNodeColor(String? relationship) {
  switch (relationship) {
    case '本人': return CrayonTheme.mustardYellow.withOpacity(0.2);
    case '父亲': case '母亲': return CrayonTheme.forestGreen.withOpacity(0.1);
    case '配偶': return CrayonTheme.softPink;
    default: return CrayonTheme.creamWhite;
  }
}
```

- [ ] **Step 2: 改造连接线**

- 父母线: `CrayonTheme.forestGreen`
- 配偶线: `CrayonTheme.brickRed` + 爱心图标
- 子女线: `CrayonTheme.mustardYellow`

- [ ] **Step 3: 添加手绘边框**

使用 `WigglyBorderPainter` 绘制节点边框。

- [ ] **Step 4: Commit**

```bash
git add lib/features/family_tree/ui/pages/family_tree_page.dart
git commit -m "refactor: transform family tree page to crayon style"
```

---

### Task 21: 改造报告列表页

**Files:**
- Modify: `lib/features/health_report/ui/pages/report_list_page.dart`

- [ ] **Step 1: 使用家人卡片布局**

```dart
final personStats = ref.watch(personsWithReportStatsProvider);

return ListView.builder(
  itemCount: personStats.length,
  itemBuilder: (context, index) {
    final item = personStats[index];
    return CrayonCard(
      onTap: () => context.go('/reports/person/${item.person.id}'),
      child: Row(
        children: [
          CrayonAvatar(presetName: item.person.photoPath),
          Text(item.person.name),
          Text('${item.stats.reportCount}份 · ${item.stats.latestReportDateText}'),
          Text('⭐ ⭐'),
        ],
      ),
    );
  },
);
```

- [ ] **Step 2: Commit**

```bash
git add lib/features/health_report/ui/pages/report_list_page.dart
git commit -m "refactor: transform report list page to family cards layout"
```

---

## Phase 5: 测试

### Task 22: Provider测试 - 报告统计

**Files:**
- Create: `test/features/health_report/providers/report_stats_test.dart`

- [ ] **Step 1: 编写测试**

```dart
void main() {
  group('personReportStatsProvider', () {
    test('returns correct count and latest date', () {
      final container = ProviderContainer();
      final stats = container.read(personReportStatsProvider(1));
      expect(stats.reportCount, equals(0));
      expect(stats.latestReportDate, isNull);
    });
  });
}
```

- [ ] **Step 2: Commit**

```bash
git add test/features/health_report/providers/report_stats_test.dart
git commit -m "test: add report stats provider tests"
```

---

### Task 23: Widget测试 - 蜡笔组件

**Files:**
- Create: `test/core/widgets/crayon_widgets_test.dart`

- [ ] **Step 1: 编写测试**

```dart
void main() {
  group('CrayonCard', () {
    testWidgets('renders child', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: CrayonCard(child: Text('Test'))),
      ));
      expect(find.text('Test'), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: Commit**

```bash
git add test/core/widgets/crayon_widgets_test.dart
git commit -m "test: add crayon widgets tests"
```

---

### Task 24: 集成测试 - 趋势流程

**Files:**
- Create: `test/integration/report_trend_flow_test.dart`

- [ ] **Step 1: 编写测试**

```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  testWidgets('view report trends', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    
    await tester.tap(find.text('报告'));
    await tester.pumpAndSettle();
    
    await tester.tap(find.byType(CrayonCard).first);
    await tester.pumpAndSettle();
    
    expect(find.byType(IndicatorTrendChart), findsOneWidget);
  });
}
```

- [ ] **Step 2: Commit**

```bash
git add test/integration/report_trend_flow_test.dart
git commit -m "test: add report trend flow integration test"
```

---

## 验收标准检查

完成所有任务后检查：
- [ ] 报告列表页显示家人卡片（姓名、报告数量、最近日期）
- [ ] 点击家人卡片跳转到报告详情页
- [ ] 报告详情页可选择不同报告查看指标
- [ ] 趋势图正确显示指标历史变化
- [ ] 所有页面采用蜡笔美学风格
- [ ] 手绘歪扭边框效果正确渲染
- [ ] 预设头像可选择并显示
- [ ] 所有测试通过