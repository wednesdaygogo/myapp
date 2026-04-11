// lib/core/widgets/crayon_input.dart
import 'package:flutter/material.dart';
import '../theme/crayon_theme.dart';

/// 蜡笔风格输入框（简单边框）
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
            border: Border.all(
              color: CrayonTheme.darkBrown.withValues(alpha: 0.6),
              width: CrayonTheme.borderWidth,
            ),
          ),
          child: TextFormField(
            controller: controller,
            initialValue: initialValue,
            keyboardType: keyboardType,
            validator: validator,
            onChanged: onChanged,
            readOnly: readOnly,
            onTap: onTap,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: CrayonTheme.darkBrown.withValues(alpha: 0.4)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              suffixIcon: suffixIcon,
            ),
            style: const TextStyle(
              color: CrayonTheme.darkBrown,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}