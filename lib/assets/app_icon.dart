import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'dart:typed_data';
import '../utils/logo_painter.dart';

/// Generate app icon as a PNG file
///
/// Usage:
/// 1. Run this file
/// 2. Save the generated PNG
/// 3. Use it as the app icon in Android and iOS
Future<Uint8List> generateAppIcon() async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  
  // The standard size for app icons
  const size = Size(1024, 1024);
  
  // Draw a gradient background
  final bgPaint = Paint()
    ..shader = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF1A237E), // Deep Blue
        Color(0xFF7B1FA2), // Purple
      ],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
  
  // Draw the background
  canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);
  
  // Create and draw the logo
  final logoPainter = LogoPainter(
    baseColor: Colors.white,
    isWatermark: false,
  );
  
  // Draw the logo slightly larger than the canvas to crop the edges
  final logoSize = Size(size.width * 0.8, size.height * 0.8);
  final logoOffset = Offset(
    (size.width - logoSize.width) / 2,
    (size.height - logoSize.height) / 2,
  );
  
  canvas.save();
  canvas.translate(logoOffset.dx, logoOffset.dy);
  logoPainter.paint(canvas, logoSize);
  canvas.restore();
  
  // Convert to an image
  final picture = recorder.endRecording();
  final img = await picture.toImage(size.width.toInt(), size.height.toInt());
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  
  return byteData!.buffer.asUint8List();
}

/// Widget to preview the app icon
class AppIconPreview extends StatelessWidget {
  final double size;
  
  const AppIconPreview({
    super.key,
    this.size = 200,
  });
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.2), // Rounded corners for app icon
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1A237E), // Deep Blue
                Color(0xFF7B1FA2), // Purple
              ],
            ),
          ),
          child: Center(
            child: CircularDrunkHubLogo(
              size: size * 0.8,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
} 