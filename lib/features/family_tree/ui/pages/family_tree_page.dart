import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
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
      appBar: AppBar(
        title: const Text('家谱图谱'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            onPressed: () => context.go('/persons/new'),
            tooltip: '添加家庭成员',
          ),
        ],
      ),
      body: treeState.isEmpty
          ? _buildEmptyState(context)
          : _FamilyTreeView(state: treeState),
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
              color: AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.family_restroom_outlined,
              size: 40,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),
          Text(
            '暂无家庭成员',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            '添加家庭成员以生成家谱图谱',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: AppTheme.spacingXl),
          ElevatedButton.icon(
            onPressed: () => context.go('/persons/new'),
            icon: const Icon(Icons.add, size: 20),
            label: const Text('添加家庭成员'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingLg,
                vertical: AppTheme.spacingMd,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tree view with proper connection lines
class _FamilyTreeView extends StatelessWidget {
  final FamilyTreeState state;

  // Layout constants
  static const double nodeWidth = 120.0;
  static const double nodeHeight = 120.0;
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
      child: Container(
        width: canvasWidth,
        height: canvasHeight,
        child: Stack(
          children: [
            // Draw connection lines first (behind nodes)
            CustomPaint(
              size: Size(canvasWidth, canvasHeight),
              painter: _ConnectionLinePainter(state: state),
            ),

            // Parents row
            if (state.parents.isNotEmpty)
              _buildRow(
                context: context,
                y: parentsRowY,
                persons: state.parents,
                color: const Color(0xFF4CAF50),
              ),

            // Self + Spouse row
            _buildSelfAndSpouseRow(context),

            // Children row
            if (state.children.isNotEmpty)
              _buildRow(
                context: context,
                y: childrenRowY,
                persons: state.children,
                color: const Color(0xFF2196F3),
              ),
          ],
        ),
      ),
    );
  }

  double _calculateCanvasWidth() {
    // Calculate max width needed
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
    required Color color,
  }) {
    return Positioned(
      top: y,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: persons
            .map((p) => Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: horizontalSpacing / 2),
                  child: _buildPersonNode(context, p, color),
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
          final index = entry.key;
          final person = entry.value;
          final isSelf = person.relationship == '本人';
          final color =
              isSelf ? AppTheme.primaryColor : const Color(0xFFFF6B35);

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalSpacing / 2),
            child: _buildPersonNode(context, person, color, isSelf: isSelf),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPersonNode(BuildContext context, Person person, Color color,
      {bool isSelf = false}) {
    return GestureDetector(
      onTap: () => context.go('/persons/${person.id}'),
      child: Container(
        width: nodeWidth,
        height: nodeHeight,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color:
                isSelf ? AppTheme.primaryColor : color.withValues(alpha: 0.5),
            width: isSelf ? 2.5 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.12),
                border: Border.all(
                  color: color.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  person.name.isNotEmpty ? person.name[0] : '?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              person.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                person.relationship ?? '其他',
                style: TextStyle(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for connection lines
class _ConnectionLinePainter extends CustomPainter {
  final FamilyTreeState state;

  _ConnectionLinePainter({required this.state});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Calculate center X for the tree
    final centerX = size.width / 2;

    // Draw parent-to-self lines
    if (state.parents.isNotEmpty && state.selfPerson != null) {
      _drawParentToSelfLines(canvas, size, centerX, paint);
    }

    // Draw spouse connection
    if (state.spouse.isNotEmpty && state.selfPerson != null) {
      _drawSpouseLine(canvas, size, centerX, paint);
    }

    // Draw self-to-children lines
    if (state.children.isNotEmpty && state.selfPerson != null) {
      _drawSelfToChildrenLines(canvas, size, centerX, paint);
    }
  }

  void _drawParentToSelfLines(
      Canvas canvas, Size size, double centerX, Paint paint) {
    paint.color = const Color(0xFF4CAF50); // Green for parents

    final parentsCount = state.parents.length;
    final parentsRowWidth = parentsCount * _FamilyTreeView.nodeWidth +
        (parentsCount - 1) * _FamilyTreeView.horizontalSpacing;
    final parentsRowStartX = centerX - parentsRowWidth / 2;

    for (int i = 0; i < parentsCount; i++) {
      final parentX = parentsRowStartX +
          i * (_FamilyTreeView.nodeWidth + _FamilyTreeView.horizontalSpacing) +
          _FamilyTreeView.nodeWidth / 2;

      final parentBottomY =
          _FamilyTreeView.parentsRowY + _FamilyTreeView.nodeHeight;
      final selfTopY = _FamilyTreeView.selfRowY;

      // Draw vertical line from parent to horizontal connector
      canvas.drawLine(
        Offset(parentX, parentBottomY),
        Offset(parentX, parentBottomY + 30),
        paint,
      );
    }

    // Draw horizontal connector line
    final leftParentX = parentsRowStartX + _FamilyTreeView.nodeWidth / 2;
    final rightParentX =
        parentsRowStartX + parentsRowWidth - _FamilyTreeView.nodeWidth / 2;
    final connectorY =
        _FamilyTreeView.parentsRowY + _FamilyTreeView.nodeHeight + 30;

    canvas.drawLine(
      Offset(leftParentX, connectorY),
      Offset(rightParentX, connectorY),
      paint,
    );

    // Draw vertical line from center to self
    final selfTopY = _FamilyTreeView.selfRowY;
    canvas.drawLine(
      Offset(centerX, connectorY),
      Offset(centerX, selfTopY),
      paint,
    );
  }

  void _drawSpouseLine(Canvas canvas, Size size, double centerX, Paint paint) {
    paint.color = const Color(0xFFFF6B35); // Orange for spouse

    final selfAndSpouseCount = 1 + state.spouse.length;
    final rowWidth = selfAndSpouseCount * _FamilyTreeView.nodeWidth +
        (selfAndSpouseCount - 1) * _FamilyTreeView.horizontalSpacing;
    final rowStartX = centerX - rowWidth / 2;

    // Self is first, spouse(s) follow
    final selfX = rowStartX + _FamilyTreeView.nodeWidth / 2;
    final lastSpouseX = rowStartX + rowWidth - _FamilyTreeView.nodeWidth / 2;
    final lineY = _FamilyTreeView.selfRowY + _FamilyTreeView.nodeHeight / 2;

    // Draw horizontal line connecting self and spouse(s)
    canvas.drawLine(
      Offset(selfX + _FamilyTreeView.nodeWidth / 2 + 5, lineY),
      Offset(lastSpouseX - _FamilyTreeView.nodeWidth / 2 - 5, lineY),
      paint,
    );
  }

  void _drawSelfToChildrenLines(
      Canvas canvas, Size size, double centerX, Paint paint) {
    paint.color = const Color(0xFF2196F3); // Blue for children

    final selfBottomY = _FamilyTreeView.selfRowY + _FamilyTreeView.nodeHeight;
    final childrenTopY = _FamilyTreeView.childrenRowY;

    // Draw vertical line from self to children row
    canvas.drawLine(
      Offset(centerX, selfBottomY),
      Offset(centerX, childrenTopY - 30),
      paint,
    );

    // Draw horizontal connector for children
    final childrenCount = state.children.length;
    final childrenRowWidth = childrenCount * _FamilyTreeView.nodeWidth +
        (childrenCount - 1) * _FamilyTreeView.horizontalSpacing;
    final childrenRowStartX = centerX - childrenRowWidth / 2;
    final connectorY = childrenTopY - 30;

    final leftChildX = childrenRowStartX + _FamilyTreeView.nodeWidth / 2;
    final rightChildX =
        childrenRowStartX + childrenRowWidth - _FamilyTreeView.nodeWidth / 2;

    canvas.drawLine(
      Offset(leftChildX, connectorY),
      Offset(rightChildX, connectorY),
      paint,
    );

    // Draw vertical lines to each child
    for (int i = 0; i < childrenCount; i++) {
      final childX = childrenRowStartX +
          i * (_FamilyTreeView.nodeWidth + _FamilyTreeView.horizontalSpacing) +
          _FamilyTreeView.nodeWidth / 2;

      canvas.drawLine(
        Offset(childX, connectorY),
        Offset(childX, childrenTopY),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ConnectionLinePainter oldDelegate) {
    return oldDelegate.state.version != state.version;
  }
}
