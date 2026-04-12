// lib/core/widgets/crayon_segmented_button.dart
import 'package:flutter/material.dart';
import '../theme/crayon_theme.dart';

/// 蜡笔风格分段按钮（用于选择器）
class CrayonSegmentedButton<T> extends StatelessWidget {
  final List<SegmentOption<T>> options;
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
                color: isSelected ? CrayonTheme.forestGreen : CrayonTheme.darkBrown.withValues(alpha: 0.5),
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
                    child: Icon(Icons.check, size: 12, color: Colors.white),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class SegmentOption<T> {
  final T value;
  final String label;
  final IconData? icon;

  const SegmentOption({
    required this.value,
    required this.label,
    this.icon,
  });

  // 便捷构造方法
  static SegmentOption<T> create<T>(T value, String label, {IconData? icon}) {
    return SegmentOption<T>(value: value, label: label, icon: icon);
  }
}