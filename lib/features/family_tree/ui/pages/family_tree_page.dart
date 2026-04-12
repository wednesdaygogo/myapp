import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/crayon_theme.dart';
import '../../../../core/widgets/crayon_background.dart';
import '../../../../core/widgets/crayon_avatar.dart';
import '../../../../data/models/person.dart';
import '../../../person/providers/person_provider.dart';

/// Family tree state
class FamilyTreeState {
  final List<Person> persons;
  final Person? selfPerson;
  final List<Person> parents;
  final List<Person> spouse;
  final List<Person> children;
  final List<Person> siblings;
  final int version;

  const FamilyTreeState({
    required this.persons,
    this.selfPerson,
    required this.parents,
    required this.spouse,
    required this.children,
    required this.siblings,
    required this.version,
  });

  bool get isEmpty => persons.isEmpty;
  bool get isNotEmpty => persons.isNotEmpty;
  bool get hasSelf => selfPerson != null;
}

/// Family tree provider
final familyTreeGraphProvider = Provider<FamilyTreeState>((ref) {
  final persons = ref.watch(personsProvider);
  final version = Object.hashAll([...persons.map((p) => p.id), persons.length]);

  final selfPerson = persons.where((p) => p.relationship == '本人').firstOrNull;
  final parents = persons
      .where((p) => p.relationship == '父亲' || p.relationship == '母亲')
      .toList();
  final spouse = persons.where((p) => p.relationship == '配偶').toList();
  final children = persons.where((p) => p.relationship == '子女').toList();
  final siblings = persons
      .where((p) => p.relationship == '兄弟' || p.relationship == '姐妹')
      .toList();

  return FamilyTreeState(
    persons: persons,
    selfPerson: selfPerson,
    parents: parents,
    spouse: spouse,
    children: children,
    siblings: siblings,
    version: version,
  );
});

class FamilyTreePage extends ConsumerStatefulWidget {
  const FamilyTreePage({super.key});

  @override
  ConsumerState<FamilyTreePage> createState() => _FamilyTreePageState();
}

class _FamilyTreePageState extends ConsumerState<FamilyTreePage> {
  @override
  Widget build(BuildContext context) {
    final treeState = ref.watch(familyTreeGraphProvider);

    return Scaffold(
      backgroundColor: CrayonTheme.creamWhite,
      appBar: AppBar(
        backgroundColor: CrayonTheme.creamWhite,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('家谱图谱'),
            const SizedBox(width: 8),
            Icon(Icons.account_tree, size: 20, color: CrayonTheme.forestGreen),
          ],
        ),
        centerTitle: true,
        foregroundColor: CrayonTheme.darkBrown,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            onPressed: () => context.go('/persons/new'),
            tooltip: '添加家庭成员',
          ),
        ],
      ),
      body: CrayonBackground(
        child: treeState.isEmpty
            ? _buildEmptyState(context)
            : _FamilyTreeView(state: treeState),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: CrayonTheme.forestGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.family_restroom_outlined,
              size: 40,
              color: CrayonTheme.forestGreen,
            ),
          ),
          const SizedBox(height: CrayonTheme.spacingLg),
          Text(
            '暂无家庭成员',
            style: CrayonTheme.crayonTextTheme.titleLarge,
          ),
          const SizedBox(height: CrayonTheme.spacingSm),
          Text(
            '添加家庭成员以生成家谱图谱',
            style: TextStyle(color: CrayonTheme.darkBrown.withValues(alpha: 0.6)),
          ),
          const SizedBox(height: CrayonTheme.spacingXl),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: CrayonTheme.spacingLg,
              vertical: CrayonTheme.spacingMd,
            ),
            decoration: BoxDecoration(
              color: CrayonTheme.forestGreen,
              borderRadius: BorderRadius.circular(CrayonTheme.radiusMd),
            ),
            child: GestureDetector(
              onTap: () => context.go('/persons/new'),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add, size: 20, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text('添加家庭成员', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tree view with crayon-style connection lines
class _FamilyTreeView extends StatelessWidget {
  final FamilyTreeState state;

  // Layout constants
  static const double nodeWidth = 120.0;
  static const double nodeHeight = 130.0;
  static const double horizontalSpacing = 30.0;
  static const double verticalSpacing = 80.0;

  // Row positions
  static const double parentsRowY = 20.0;
  static const double selfRowY = parentsRowY + nodeHeight + verticalSpacing;
  static const double childrenRowY = selfRowY + nodeHeight + verticalSpacing;

  const _FamilyTreeView({required this.state});

  @override
  Widget build(BuildContext context) {
    final canvasWidth = _calculateCanvasWidth();
    final canvasHeight = childrenRowY + nodeHeight + 40;

    return InteractiveViewer(
      constrained: false,
      boundaryMargin: const EdgeInsets.all(100),
      minScale: 0.5,
      maxScale: 2.0,
      child: SizedBox(
        width: canvasWidth,
        height: canvasHeight,
        child: Stack(
          children: [
            // Draw crayon connection lines first (behind nodes)
            CustomPaint(
              size: Size(canvasWidth, canvasHeight),
              painter: _CrayonConnectionLinePainter(state: state),
            ),

            // Parents row
            if (state.parents.isNotEmpty)
              _buildRow(
                context: context,
                y: parentsRowY,
                persons: state.parents,
              ),

            // Self + Spouse row
            _buildSelfAndSpouseRow(context),

            // Children row
            if (state.children.isNotEmpty)
              _buildRow(
                context: context,
                y: childrenRowY,
                persons: state.children,
              ),
          ],
        ),
      ),
    );
  }

  double _calculateCanvasWidth() {
    int maxNodesInRow = [
      state.parents.length,
      (state.selfPerson != null ? 1 : 0) + state.spouse.length,
      state.children.length,
    ].reduce((a, b) => a > b ? a : b);

    return (maxNodesInRow * nodeWidth) +
        ((maxNodesInRow - 1) * horizontalSpacing) +
        100;
  }

  Widget _buildRow({
    required BuildContext context,
    required double y,
    required List<Person> persons,
  }) {
    return Positioned(
      top: y,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: persons
            .map((p) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalSpacing / 2),
                  child: _buildPersonNode(context, p),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildSelfAndSpouseRow(BuildContext context) {
    final selfAndSpouse = [
      if (state.selfPerson != null) state.selfPerson!,
      ...state.spouse,
    ];

    if (selfAndSpouse.isEmpty) return const SizedBox();

    return Positioned(
      top: selfRowY,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: selfAndSpouse.asMap().entries.map((entry) {
          final person = entry.value;
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalSpacing / 2),
            child: _buildPersonNode(context, person),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPersonNode(BuildContext context, Person person) {
    return GestureDetector(
      onTap: () => context.go('/persons/${person.id}'),
      child: Container(
        width: nodeWidth,
        height: nodeHeight,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: CrayonTheme.creamWhite,
          borderRadius: BorderRadius.circular(CrayonTheme.radiusMd),
          border: Border.all(
            color: _getNodeColor(person.relationship),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CrayonAvatar(
              presetName: person.photoPath,
              size: 50,
              borderColor: _getNodeColor(person.relationship),
            ),
            const SizedBox(height: 8),
            Text(
              person.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: CrayonTheme.darkBrown,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getNodeColor(person.relationship).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                person.relationship ?? '其他',
                style: TextStyle(
                  fontSize: 10,
                  color: _getNodeColor(person.relationship),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getNodeColor(String? relationship) {
    switch (relationship) {
      case '本人':
        return CrayonTheme.mustardYellow;
      case '父亲':
      case '母亲':
        return CrayonTheme.forestGreen;
      case '配偶':
        return CrayonTheme.brickRed;
      case '子女':
        return CrayonTheme.mustardYellow;
      default:
        return CrayonTheme.darkBrown;
    }
  }
}

/// Crayon-style connection line painter
class _CrayonConnectionLinePainter extends CustomPainter {
  final FamilyTreeState state;

  _CrayonConnectionLinePainter({required this.state});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final centerX = size.width / 2;

    // Draw parent-to-self lines (forest green)
    if (state.parents.isNotEmpty && state.selfPerson != null) {
      paint.color = CrayonTheme.forestGreen;
      _drawParentToSelfLines(canvas, size, centerX, paint);
    }

    // Draw spouse connection (brick red)
    if (state.spouse.isNotEmpty && state.selfPerson != null) {
      paint.color = CrayonTheme.brickRed;
      _drawSpouseLine(canvas, size, centerX, paint);
    }

    // Draw self-to-children lines (mustard yellow)
    if (state.children.isNotEmpty && state.selfPerson != null) {
      paint.color = CrayonTheme.mustardYellow;
      _drawSelfToChildrenLines(canvas, size, centerX, paint);
    }
  }

  void _drawParentToSelfLines(Canvas canvas, Size size, double centerX, Paint paint) {
    final parentsCount = state.parents.length;
    final parentsRowWidth = parentsCount * _FamilyTreeView.nodeWidth +
        (parentsCount - 1) * _FamilyTreeView.horizontalSpacing;
    final parentsRowStartX = centerX - parentsRowWidth / 2;

    // Draw wiggly lines from each parent to connector
    for (int i = 0; i < parentsCount; i++) {
      final parentX = parentsRowStartX +
          i * (_FamilyTreeView.nodeWidth + _FamilyTreeView.horizontalSpacing) +
          _FamilyTreeView.nodeWidth / 2;

      final parentBottomY = _FamilyTreeView.parentsRowY + _FamilyTreeView.nodeHeight;
      final connectorY = parentBottomY + 30;

      _drawWigglyLine(canvas, Offset(parentX, parentBottomY), Offset(parentX, connectorY), paint);
    }

    // Draw horizontal connector
    final leftParentX = parentsRowStartX + _FamilyTreeView.nodeWidth / 2;
    final rightParentX = parentsRowStartX + parentsRowWidth - _FamilyTreeView.nodeWidth / 2;
    final connectorY = _FamilyTreeView.parentsRowY + _FamilyTreeView.nodeHeight + 30;

    _drawWigglyLine(canvas, Offset(leftParentX, connectorY), Offset(rightParentX, connectorY), paint);

    // Draw line from center to self
    final selfTopY = _FamilyTreeView.selfRowY;
    _drawWigglyLine(canvas, Offset(centerX, connectorY), Offset(centerX, selfTopY), paint);
  }

  void _drawSpouseLine(Canvas canvas, Size size, double centerX, Paint paint) {
    final selfAndSpouseCount = 1 + state.spouse.length;
    final rowWidth = selfAndSpouseCount * _FamilyTreeView.nodeWidth +
        (selfAndSpouseCount - 1) * _FamilyTreeView.horizontalSpacing;
    final rowStartX = centerX - rowWidth / 2;

    final selfX = rowStartX + _FamilyTreeView.nodeWidth / 2;
    final lastSpouseX = rowStartX + rowWidth - _FamilyTreeView.nodeWidth / 2;
    final lineY = _FamilyTreeView.selfRowY + _FamilyTreeView.nodeHeight / 2;

    _drawWigglyLine(canvas, Offset(selfX + _FamilyTreeView.nodeWidth / 2 + 5, lineY), Offset(lastSpouseX - _FamilyTreeView.nodeWidth / 2 - 5, lineY), paint);
  }

  void _drawSelfToChildrenLines(Canvas canvas, Size size, double centerX, Paint paint) {
    final selfBottomY = _FamilyTreeView.selfRowY + _FamilyTreeView.nodeHeight;
    final childrenTopY = _FamilyTreeView.childrenRowY;
    final connectorY = childrenTopY - 30;

    // Vertical line from self to children
    _drawWigglyLine(canvas, Offset(centerX, selfBottomY), Offset(centerX, connectorY), paint);

    // Horizontal connector for children
    final childrenCount = state.children.length;
    final childrenRowWidth = childrenCount * _FamilyTreeView.nodeWidth +
        (childrenCount - 1) * _FamilyTreeView.horizontalSpacing;
    final childrenRowStartX = centerX - childrenRowWidth / 2;

    final leftChildX = childrenRowStartX + _FamilyTreeView.nodeWidth / 2;
    final rightChildX = childrenRowStartX + childrenRowWidth - _FamilyTreeView.nodeWidth / 2;

    _drawWigglyLine(canvas, Offset(leftChildX, connectorY), Offset(rightChildX, connectorY), paint);

    // Vertical lines to each child
    for (int i = 0; i < childrenCount; i++) {
      final childX = childrenRowStartX +
          i * (_FamilyTreeView.nodeWidth + _FamilyTreeView.horizontalSpacing) +
          _FamilyTreeView.nodeWidth / 2;

      _drawWigglyLine(canvas, Offset(childX, connectorY), Offset(childX, childrenTopY), paint);
    }
  }

  void _drawWigglyLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    final path = Path();
    path.moveTo(start.dx, start.dy);

    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final distance = dx != 0 ? dx : dy;
    final steps = (distance.abs() / 10).ceil();

    for (int i = 1; i <= steps; i++) {
      final progress = i / steps;
      final x = start.dx + dx * progress;
      final y = start.dy + dy * progress;
      // Add small wiggle
      final wiggle = (i % 2 == 0 ? 1.5 : -1.5);
      final wiggleX = dy == 0 ? wiggle : 0;
      final wiggleY = dx == 0 ? wiggle : 0;
      path.lineTo(x + wiggleX, y + wiggleY);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CrayonConnectionLinePainter oldDelegate) {
    return oldDelegate.state.version != state.version;
  }
}