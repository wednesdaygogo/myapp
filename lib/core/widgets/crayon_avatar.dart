import 'dart:io';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/crayon_theme.dart';

/// 预设头像
class PresetAvatars {
  PresetAvatars._();

  static const List<String> names = [
    'bear',
    'fox',
    'cat',
    'dog',
    'panda',
    'polar_bear',
    'rabbit',
    'owl',
  ];

  static const Map<String, IconData> iconMap = {
    'bear': Icons.cruelty_free,       // 熊 - 动物轮廓
    'fox': Icons.smart_toy,           // 狐狸 - 聪明的形象
    'cat': Icons.face_4,              // 猫 - 带耳朵的脸
    'dog': Icons.pets,                // 狗 - 爪印
    'panda': Icons.face,              // 熊猫 - 圆脸
    'polar_bear': Icons.ac_unit,      // 北极熊 - 雪花/冷
    'rabbit': Icons.egg_alt,          // 兔子 - 蛋形（像兔子）
    'owl': Icons.visibility,          // 猫头鹰 - 大眼睛
  };

  static const Map<String, Color> colorMap = {
    'bear': Color(0xFF8B4513),
    'fox': Color(0xFFFF6B35),
    'cat': Color(0xFFFF9500),
    'dog': Color(0xFFD4A574),
    'panda': Color(0xFF333333),
    'polar_bear': Color(0xFFE8E8E8),
    'rabbit': Color(0xFFFFB6C1),
    'owl': Color(0xFF5D4E37),
  };
}

/// 手绘风格头像组件（简化边框）
class CrayonAvatar extends StatelessWidget {
  final String? presetName; // 预设头像名称
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
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
      ),
      child: Center(
        child: _buildAvatarContent(),
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
      final icon = PresetAvatars.iconMap[presetName!] ?? Icons.person;
      final color = PresetAvatars.colorMap[presetName!] ?? AppTheme.textSecondary;
      return Icon(icon, size: size * 0.5, color: color);
    }

    return Icon(Icons.person, size: size * 0.5, color: AppTheme.textSecondary);
  }
}