import 'package:flutter/material.dart';

class CustomStepper extends StatelessWidget {
  final List<CustomStep> steps;
  final int currentStepIndex;

  const CustomStepper({Key? key, required this.steps, required this.currentStepIndex})
      : assert(steps.length >= 2),
        assert(currentStepIndex < steps.length),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < steps.length; i++)
          _buildStepWidget(context, i, steps[i])
      ],
    );
  }

  Widget _buildStepWidget(BuildContext context, int index, CustomStep step) {
    final isFirst = index == 0;
    final isLast = index == steps.length - 1;
    final shouldHighlight = index <= currentStepIndex;
    final shouldHighlightNext = index < currentStepIndex;
    final color = shouldHighlight ? Colors.black : Colors.white;
    final nextColor = shouldHighlightNext ? Colors.black : Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomPaint(
            size: const Size(20, 60),
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
            style:
                Theme.of(context).textTheme.bodyText2?.copyWith(color: color),
          )
        ],
      ),
    );
  }
}

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

    if (!isFirstStep) {
      canvas.drawLine(const Offset(_dotRadius, 0),
          Offset(_dotRadius, size.height / 2), paint..strokeWidth = _lineWidth);
    }

    if (!isLastStep) {
      canvas.drawLine(
          Offset(_dotRadius, size.height / 2),
          Offset(_dotRadius, size.height),
          paint
            ..strokeWidth = _lineWidth
            ..color = nextColor);
    }

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
