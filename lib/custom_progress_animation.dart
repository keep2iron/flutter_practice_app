import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class CustomProgressAnimation extends StatefulWidget {
  final double radius;
  final List<Color> colors;
  final Color backgroundColor;
  final double strokeWidth;
  final double swipeAngle;

  const CustomProgressAnimation(
    this.radius,
    this.colors,
    this.backgroundColor,
    this.strokeWidth,
    this.swipeAngle, {
    Key key,
  }) : super(key: key);

  @override
  _CustomProgressAnimationState createState() =>
      _CustomProgressAnimationState();
}

class _CustomProgressAnimationState extends State<CustomProgressAnimation>
    with TickerProviderStateMixin {
  AnimationController _controller;
  AnimationController _angleController;

  Animation<double> _progressAnimation;
  Animation<double> _swipeAngleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: Duration(milliseconds: 1500), vsync: this);
    _angleController = AnimationController(
        duration: Duration(milliseconds: 1500), vsync: this);

    _progressAnimation = Tween<double>(begin: 0.0, end: math.pi * 2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          0.0,
          1.0,
          curve: Curves.easeIn,
        ),
      ),
    );

    _swipeAngleAnimation =
        Tween<double>(begin: widget.swipeAngle, end: widget.swipeAngle / 9)
            .animate(_angleController);

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    try {
      _controller.repeat(reverse: false).orCancel;
      _angleController.repeat(reverse: true).orCancel;
    } on TickerCanceled {}
  }

  @override
  void dispose() {
    _controller.dispose();
    _angleController.dispose();
    super.dispose();
  }

  /// progress in [0,PI]
  Widget _buildAnimationChild() {
    return CustomPaint(
      painter: CustomProgressPainter(
          widget.backgroundColor,
          widget.radius,
          widget.colors,
          widget.strokeWidth,
          _progressAnimation.value,
          _swipeAngleAnimation.value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, widget) {
        return _buildAnimationChild();
      },
      child: _buildAnimationChild(),
    );
  }
}

class CustomProgressPainter extends CustomPainter {
  final double radius;
  final double strokeWidth;
  final Color backgroundColor;
  final List<Color> colors;
  final double startAngle;
  final double swipeAngle;

  CustomProgressPainter(this.backgroundColor, this.radius, this.colors,
      this.strokeWidth, this.startAngle, this.swipeAngle);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final Paint backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Paint foreGroundPaint = Paint()
      ..shader = ui.Gradient.sweep(
        center,
        colors,
        null,
        TileMode.repeated,
        startAngle,
        startAngle + swipeAngle,
      )
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.save();
    canvas.drawCircle(center, radius, backgroundPaint);
    canvas.drawArc(
        Rect.fromCenter(center: center, width: radius * 2, height: radius * 2),
        this.startAngle,
        swipeAngle,
        false,
        foreGroundPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomProgressPainter oldDelegate) {
    return oldDelegate.radius != this.radius ||
        oldDelegate.strokeWidth != this.strokeWidth ||
        oldDelegate.backgroundColor != this.backgroundColor ||
        oldDelegate.colors != this.colors ||
        oldDelegate.startAngle != this.startAngle ||
        oldDelegate.swipeAngle != this.swipeAngle;
  }
}
