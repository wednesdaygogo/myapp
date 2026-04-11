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
      final emoji = PresetAvatars.emojiMap[presetName!] ?? '👤';
      return Text(emoji, style: TextStyle(fontSize: size * 0.5));
    }

    return Icon(Icons.person, size: size * 0.5, color: AppTheme.textSecondary);
  }
}