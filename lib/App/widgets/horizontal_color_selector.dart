import 'package:flutter/material.dart';
import '../core/models/paint_model.dart';

class HorizontalColorSelector extends StatelessWidget {
  final List<PaintBottle> bottles;
  final PaintType selectedType;
  final ValueChanged<PaintType> onColorSelected;

  const HorizontalColorSelector({
    super.key,
    required this.bottles,
    required this.selectedType,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: bottles.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final bottle = bottles[index];
          final bool isSelected = bottle.type == selectedType;
          final Color chipColor = bottle.color;

          return GestureDetector(
            onTap: () => onColorSelected(bottle.type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? chipColor.withValues(alpha: 0.25)
                    : const Color(0xFFF0F4FF),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected ? chipColor : const Color(0xFFD0E1FF),
                  width: isSelected ? 2.5 : 1.2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: chipColor.withValues(alpha: 0.4),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: const Color(0xFF74B9FF).withValues(alpha: 0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Emoji / Circle badge
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: chipColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: chipColor.withValues(alpha: 0.5),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      bottle.emoji,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 8),

                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bottle.name,
                        style: const TextStyle(
                          color: Color(0xFF2C3E50),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: chipColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${bottle.availableMl.round()} ml',
                          style: TextStyle(
                            color: bottle.type == PaintType.black
                                ? const Color(0xFF2C3E50)
                                : (bottle.type == PaintType.white
                                    ? Colors.grey.shade800
                                    : chipColor),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
