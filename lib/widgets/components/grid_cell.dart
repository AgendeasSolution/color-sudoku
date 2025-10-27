import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import 'ball.dart';

class GridCell extends StatefulWidget {
  final Color? color;
  final bool isNext;
  final bool isPrefilled;

  const GridCell({
    super.key,
    this.color,
    this.isNext = false,
    this.isPrefilled = false,
  });

  @override
  State<GridCell> createState() => _GridCellState();
}

class _GridCellState extends State<GridCell> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    if (widget.isNext) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant GridCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isNext && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isNext && _pulseController.isAnimating) {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final shadowColor = Color.lerp(
          AppConstants.primaryAccentColor.withOpacity(0.6),
          AppConstants.primaryAccentColor.withOpacity(0.9),
          _pulseController.value,
        )!;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.cellBorderRadius),
            border: Border.all(
              color: widget.isNext ? AppConstants.primaryAccentColor : AppConstants.gridCellBorder,
              width: AppConstants.cellBorderWidth,
            ),
            gradient: LinearGradient(
              begin: Alignment(0.7, -0.7), // 145deg equivalent
              end: Alignment(-0.7, 0.7),
              colors: widget.isNext
                  ? const [Color(0xFF2B6CB0), Color(0xFF2C5282)]
                  : const [AppConstants.gridCellBgStart, AppConstants.gridCellBgEnd],
            ),
            boxShadow: widget.isNext
                ? [BoxShadow(
                    color: shadowColor,
                    blurRadius: AppConstants.cellNextShadowBlur,
                    spreadRadius: AppConstants.cellShadowSpread,
                  )]
                : widget.isPrefilled
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        )
                      ],
          ),
          child: child,
        );
      },
      child: widget.color != null
          ? FractionallySizedBox(
              widthFactor: AppConstants.ballSizeFactor,
              heightFactor: AppConstants.ballSizeFactor,
              child: AnimatedSwitcher(
                duration: widget.isPrefilled 
                    ? Duration.zero 
                    : const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return widget.isPrefilled 
                      ? (child ?? const SizedBox())
                      : ScaleTransition(scale: animation, child: child);
                },
                child: Ball(key: ValueKey(widget.color), color: widget.color!),
              ),
            )
          : null,
    );
  }
}
