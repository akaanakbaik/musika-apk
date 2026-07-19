import 'package:flutter/material.dart';
import '../config/theme.dart';

class SourceBadge extends StatelessWidget {
  final String source;
  final double fontSize;
  final EdgeInsets padding;

  const SourceBadge({
    super.key,
    required this.source,
    this.fontSize = 9,
    this.padding = const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
  });

  @override
  Widget build(BuildContext context) {
    final color = _getSourceColor(source);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        source.toUpperCase(),
        style: TextStyle(
          fontSize: fontSize,
          color: color,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Color _getSourceColor(String source) {
    switch (source.toLowerCase()) {
      case 'youtube':
        return const Color(0xFFFF0000);
      case 'spotify':
        return AppTheme.primary;
      case 'apple':
        return const Color(0xFFFC3C44);
      case 'soundcloud':
        return const Color(0xFFFF7700);
      default:
        return Colors.grey;
    }
  }
}

class SourceIcon extends StatelessWidget {
  final String source;
  final double size;

  const SourceIcon({super.key, required this.source, this.size = 16});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    switch (source.toLowerCase()) {
      case 'youtube':
        icon = Icons.play_circle_fill;
        color = const Color(0xFFFF0000);
      case 'spotify':
        icon = Icons.music_note;
        color = AppTheme.primary;
      case 'apple':
        icon = Icons.apple;
        color = const Color(0xFFFC3C44);
      case 'soundcloud':
        icon = Icons.cloud;
        color = const Color(0xFFFF7700);
      default:
        icon = Icons.library_music;
        color = Colors.grey;
    }
    return Icon(icon, size: size, color: color);
  }
}
