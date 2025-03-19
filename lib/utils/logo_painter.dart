import 'package:flutter/material.dart';
import 'dart:math' as math;

class LogoPainter extends CustomPainter {
  final Color baseColor;
  final bool isWatermark;
  
  LogoPainter({
    required this.baseColor,
    this.isWatermark = false,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    
    // Create the circular path for text
    final textPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius * 0.85));
    
    // Paint settings
    final textPaint = Paint()
      ..color = isWatermark 
          ? baseColor.withOpacity(0.25) 
          : baseColor
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.0;
    
    // For the circular text
    final textStyle = TextStyle(
      color: isWatermark ? baseColor.withOpacity(0.3) : baseColor,
      fontSize: radius * 0.22,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.5,
    );
    
    // Draw the D in the center
    final dTextStyle = TextStyle(
      color: isWatermark ? baseColor.withOpacity(0.25) : baseColor,
      fontSize: radius * 0.9,
      fontWeight: FontWeight.bold,
    );
    
    final dTextSpan = TextSpan(
      text: 'D',
      style: dTextStyle,
    );
    
    final dTextPainter = TextPainter(
      text: dTextSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    
    dTextPainter.layout();
    dTextPainter.paint(
      canvas, 
      Offset(
        center.dx - dTextPainter.width / 2, 
        center.dy - dTextPainter.height / 2
      )
    );
    
    // Draw the circular text "DRUNKHUB"
    canvas.save();
    
    // Draw the text around the circle
    final text = "DRUNKHUB";
    final double textAngle = 2 * math.pi / text.length;
    final double startAngle = -math.pi / 2 - (text.length / 2 * textAngle);
    
    for (int i = 0; i < text.length; i++) {
      final angle = startAngle + i * textAngle;
      canvas.save();
      canvas.translate(
        center.dx + radius * 0.7 * math.cos(angle),
        center.dy + radius * 0.7 * math.sin(angle),
      );
      
      // Rotate each character to align with the circle
      canvas.rotate(angle + math.pi / 2);
      
      final charStyle = TextStyle(
        color: isWatermark ? baseColor.withOpacity(0.3) : baseColor,
        fontSize: radius * 0.22,
        fontWeight: FontWeight.bold,
      );
      
      final charSpan = TextSpan(
        text: text[i],
        style: charStyle,
      );
      
      final charPainter = TextPainter(
        text: charSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      
      charPainter.layout();
      charPainter.paint(
        canvas, 
        Offset(-charPainter.width / 2, -charPainter.height / 2)
      );
      
      canvas.restore();
    }
    
    // Draw a snake-like circular arrow (ouroboros)
    final arrowPaint = Paint()
      ..color = isWatermark ? baseColor.withOpacity(0.2) : baseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.03
      ..strokeCap = StrokeCap.round;
    
    final arrowPath = Path();
    const double arrowStartAngle = -math.pi / 4;
    const double arrowSweepAngle = 2 * math.pi - math.pi / 8;
    
    arrowPath.addArc(
      Rect.fromCircle(center: center, radius: radius * 0.85),
      arrowStartAngle,
      arrowSweepAngle,
    );
    
    canvas.drawPath(arrowPath, arrowPaint);
    
    // Draw arrow head
    final arrowHeadAngle = arrowStartAngle + arrowSweepAngle;
    final arrowHeadPoint = Offset(
      center.dx + radius * 0.85 * math.cos(arrowHeadAngle),
      center.dy + radius * 0.85 * math.sin(arrowHeadAngle),
    );
    
    final arrowHeadPath = Path();
    final headLength = radius * 0.15;
    final angle1 = arrowHeadAngle - math.pi / 6;
    final angle2 = arrowHeadAngle + math.pi / 6;
    
    arrowHeadPath.moveTo(arrowHeadPoint.dx, arrowHeadPoint.dy);
    arrowHeadPath.lineTo(
      arrowHeadPoint.dx - headLength * math.cos(angle1),
      arrowHeadPoint.dy - headLength * math.sin(angle1),
    );
    arrowHeadPath.moveTo(arrowHeadPoint.dx, arrowHeadPoint.dy);
    arrowHeadPath.lineTo(
      arrowHeadPoint.dx - headLength * math.cos(angle2),
      arrowHeadPoint.dy - headLength * math.sin(angle2),
    );
    
    canvas.drawPath(arrowHeadPath, arrowPaint);
    
    canvas.restore();
  }
  
  @override
  bool shouldRepaint(covariant LogoPainter oldDelegate) {
    return oldDelegate.baseColor != baseColor ||
           oldDelegate.isWatermark != isWatermark;
  }
}

class CircularDrunkHubLogo extends StatelessWidget {
  final double size;
  final Color color;
  final bool isWatermark;
  
  const CircularDrunkHubLogo({
    super.key,
    required this.size,
    required this.color,
    this.isWatermark = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: LogoPainter(
          baseColor: color,
          isWatermark: isWatermark,
        ),
      ),
    );
  }
} 