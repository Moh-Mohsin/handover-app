import 'package:flutter/material.dart';

class CustomStepper extends StatelessWidget {
  final List<CustomStep> steps;
  final int currentStepIndex;
  final TextStyle textStyle;

  const CustomStepper({
    Key? key,
    required this.steps,
    required this.currentStepIndex,
    required this.textStyle,
  })  : assert(steps.length >= 2),
        assert(currentStepIndex < steps.length),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < steps.length; i++)
          Expanded(child: _buildStepWidget(context, i, steps[i]))
      ],
    );
  }

  Widget _buildStepWidget(BuildContext context, int index, CustomStep step) {
    final isFirst = index == 0;
    final isLast = index == steps.length - 1;

    // highlight current step and steps befroe it
    final shouldHighlight = index <= currentStepIndex;

    final shouldHighlightNext = index < currentStepIndex;

    final color = shouldHighlight ? Colors.black : Colors.white;
    final nextColor = shouldHighlightNext ? Colors.black : Colors.white;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CustomPaint(
          size: const Size(20, double.infinity),
          painter: CustomStepIndicatorPainter(
              isFirstStep: isFirst,
              isLastStep: isLast,
              color: color,
              nextColor: nextColor),
        ),
        const SizedBox(
          width: 50,
        ),
        Text(
          step.title,
          style: textStyle.copyWith(color: color),
        )
      ],
    );
  }
}

/// this is a custom painter to draw the lines and dots for each step
class CustomStepIndicatorPainter extends CustomPainter {
  final bool isFirstStep;
  final bool isLastStep;
  final Color color;
  final Color nextColor;

  static const _lineWidth = 2.0;
  static const _dotRadius = _lineWidth * 2;

  CustomStepIndicatorPainter({
    required this.isFirstStep,
    required this.isLastStep,
    required this.color,
    required this.nextColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.style = PaintingStyle.fill;
    paint.color = color;

    // draw a vertical line from top to center unless its the first step
    if (!isFirstStep) {
      canvas.drawLine(const Offset(_dotRadius, 0),
          Offset(_dotRadius, size.height / 2), paint..strokeWidth = _lineWidth);
    }
    // draw a vertical line from center to bottom unless its the last step.
    // note that the color could be different from the first line since this line
    // is acutally for the next step
    if (!isLastStep) {
      canvas.drawLine(
          Offset(_dotRadius, size.height / 2),
          Offset(_dotRadius, size.height),
          paint
            ..strokeWidth = _lineWidth
            ..color = nextColor);
    }

    // this is the dot for the step, centered and always shown
    canvas.drawCircle(
        Offset(_dotRadius, size.height / 2), _dotRadius, paint..color = color);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class CustomStep {
  final String title;

  CustomStep(this.title);
}
