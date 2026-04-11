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