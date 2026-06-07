import 'package:flutter/material.dart';

import 'astro_core.dart';
import 'astro_display.dart';

class AspectMark extends StatelessWidget {
  final AspectType type;
  final Color color;
  final double size;
  final FontWeight fontWeight;

  const AspectMark({
    super.key,
    required this.type,
    required this.color,
    this.size = 16,
    this.fontWeight = FontWeight.w900,
  });

  @override
  Widget build(BuildContext context) {
    final scaledSize = size * aspectGlyphSizeScale(type);
    return Text(
      aspectGlyph(type),
      textAlign: TextAlign.center,
      style: TextStyle(
        color: color,
        fontSize: scaledSize,
        fontWeight: fontWeight,
        height: 1,
        letterSpacing: 0,
        fontFamily: aspectGlyphFontFamily(type),
        fontFamilyFallback: aspectGlyphFontFamilyFallback(type),
      ),
    );
  }
}

class AspectNameMarkLabel extends StatelessWidget {
  final String leading;
  final String trailing;
  final AspectType type;
  final Color color;
  final double fontSize;
  final FontWeight fontWeight;

  const AspectNameMarkLabel({
    super.key,
    required this.leading,
    required this.trailing,
    required this.type,
    required this.color,
    required this.fontSize,
    required this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    final base = TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: 0,
    );
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: base,
        children: [
          TextSpan(text: leading),
          TextSpan(
            text: ' ${aspectGlyph(type)} ',
            style: base.copyWith(
              fontSize: fontSize * aspectGlyphSizeScale(type),
              fontFamily: aspectGlyphFontFamily(type),
              fontFamilyFallback: aspectGlyphFontFamilyFallback(type),
            ),
          ),
          TextSpan(text: trailing),
        ],
      ),
    );
  }
}
