import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/audio/audio_service.dart';
import '../../../models/dragon_character.dart';
import '../../../models/drawing_stroke.dart';
import '../painters/dragon_painter.dart';

class DragonCanvas extends StatefulWidget {
  final DragonCharacter character;
  final DragonPart selectedPart;
  final DrawingToolType selectedTool;
  final Color selectedColor;
  final double strokeWidth;
  final VoidCallback onStrokeCompleted;

  const DragonCanvas({
    super.key,
    required this.character,
    required this.selectedPart,
    required this.selectedTool,
    required this.selectedColor,
    this.strokeWidth = 16.0,
    required this.onStrokeCompleted,
  });

  @override
  State<DragonCanvas> createState() => _DragonCanvasState();
}

class _DragonCanvasState extends State<DragonCanvas> with SingleTickerProviderStateMixin {
  late AnimationController _idleAnimController;
  final List<Offset> _currentPoints = [];

  @override
  void initState() {
    super.initState();
    _idleAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _idleAnimController.dispose();
    super.dispose();
  }

  void _onPanStart(DragDownDetails details, BoxConstraints constraints) {
    setState(() {
      _currentPoints.clear();
      _currentPoints.add(details.localPosition);
    });
    context.read<AudioService>().playBrushStroke();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _currentPoints.add(details.localPosition);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_currentPoints.isNotEmpty) {
      final newStroke = DrawingStroke(
        points: List<Offset>.from(_currentPoints),
        color: widget.selectedTool == DrawingToolType.eraser
            ? _getBaseColorForPart(widget.selectedPart)
            : widget.selectedColor,
        strokeWidth: widget.strokeWidth,
        toolType: widget.selectedTool,
      );

      widget.character.addStroke(widget.selectedPart, newStroke);
      _currentPoints.clear();
      widget.onStrokeCompleted();
    }
  }

  Color _getBaseColorForPart(DragonPart part) {
    switch (part) {
      case DragonPart.horns:
        return widget.character.hornsColor;
      case DragonPart.wings:
        return widget.character.wingsColor;
      case DragonPart.tail:
        return widget.character.bodyColor;
      case DragonPart.belly:
        return widget.character.bellyColor;
      case DragonPart.body:
        return widget.character.bodyColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Tỷ lệ chuẩn vuông hoặc gần vuông cho nhân vật Chibi
        final canvasSize = Size(constraints.maxWidth, constraints.maxHeight);

        return GestureDetector(
          onPanDown: (details) => _onPanStart(details, constraints),
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          behavior: HitTestBehavior.opaque,
          child: AnimatedBuilder(
            animation: _idleAnimController,
            builder: (context, child) {
              return CustomPaint(
                size: canvasSize,
                painter: DragonPainter(
                  character: widget.character,
                  selectedPart: widget.selectedPart,
                  animationValue: _idleAnimController.value,
                  activeLiveStrokes: _currentPoints.isNotEmpty
                      ? [
                          DrawingStroke(
                            points: List<Offset>.from(_currentPoints),
                            color: widget.selectedTool == DrawingToolType.eraser
                                ? _getBaseColorForPart(widget.selectedPart)
                                : widget.selectedColor,
                            strokeWidth: widget.strokeWidth,
                            toolType: widget.selectedTool,
                          )
                        ]
                      : null,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

