import 'package:flutter/material.dart';
import '../core/models/paint_model.dart';

class PaintBottleSlider extends StatelessWidget {
  final PaintBottle bottle;
  final ValueChanged<double> onChanged;

  const PaintBottleSlider({
    super.key,
    required this.bottle,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final Color bottleColor = bottle.color;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF74B9FF).withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: bottleColor.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Bottle Color Badge & Emoji
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: bottleColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: bottleColor.withValues(alpha: 0.6),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              bottle.emoji,
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(width: 12),

          // Label & Slider
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      bottle.name,
                      style: const TextStyle(
                        color: Color(0xFF2C3E50),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: bottleColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${bottle.availableMl.round()} ml',
                        style: TextStyle(
                          color: bottle.type == PaintType.black
                              ? const Color(0xFF2C3E50)
                              : (bottle.type == PaintType.white
                                  ? Colors.grey.shade800
                                  : bottleColor),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 8,
                    activeTrackColor: bottleColor,
                    inactiveTrackColor: bottleColor.withValues(alpha: 0.2),
                    thumbColor: Colors.white,
                    overlayColor: bottleColor.withValues(alpha: 0.3),
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 10,
                      elevation: 4,
                    ),
                  ),
                  child: Slider(
                    value: bottle.availableMl,
                    min: 0,
                    max: 100,
                    divisions: 100,
                    onChanged: onChanged,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
