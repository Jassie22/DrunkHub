import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A utility class to manage app assets
class AppAssets {
  // SVG assets
  static const String appIconSvg = 'assets/images/app_icon.svg';
  
  /// Get the app icon as an SVG widget
  static Widget getAppIconSvg({
    double? width,
    double? height,
    Color? color,
    BoxFit fit = BoxFit.contain,
  }) {
    return SvgPicture.asset(
      appIconSvg,
      width: width,
      height: height,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
      fit: fit,
    );
  }
} 