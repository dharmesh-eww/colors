import 'package:flutter/material.dart';
import '../core/models/paint_model.dart';

class ActiveBottleWidget extends StatefulWidget {
  final PaintBottle bottle;
  final ValueChanged<double> onPour;

  const ActiveBottleWidget({
    super.key,
    required this.bottle,
    required this.onPour,
  });

  @override
  State<ActiveBottleWidget> createState() => _ActiveBottleWidgetState();
}

class _ActiveBottleWidgetState extends State<ActiveBottleWidget> {
  double _pourAmountMl = 10.0;

  @override
  void didUpdateWidget(covariant ActiveBottleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_pourAmountMl > widget.bottle.availableMl) {
      _pourAmountMl = widget.bottle.availableMl.clamp(0.0, 100.0);
    }
    if (_pourAmountMl == 0 && widget.bottle.availableMl > 0) {
      _pourAmountMl = (widget.bottle.availableMl >= 10.0) ? 10.0 : widget.bottle.availableMl;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottle = widget.bottle;
    final Color bottleColor = bottle.color;
    final double maxAvailable = bottle.availableMl;
    final double fillRatio = (maxAvailable / 100.0).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: bottleColor.withValues(alpha: 0.35),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF74B9FF).withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header: Bottle Title & Available Readout
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    bottle.emoji,
                    style: const TextStyle(fontSize: 22),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${bottle.name} Bottle',
                    style: const TextStyle(
                      color: Color(0xFF2C3E50),
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: bottleColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: bottleColor.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  '${maxAvailable.round()} ml available',
                  style: TextStyle(
                    color: bottle.type == PaintType.black
                        ? const Color(0xFF2C3E50)
                        : (bottle.type == PaintType.white
                            ? Colors.grey.shade800
                            : bottleColor),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Central Graphic: 3D Bottle representation with liquid level
          Row(
            children: [
              // Bottle graphic container
              Container(
                width: 70,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2ECFF),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14),
                    bottom: Radius.circular(22),
                  ),
                  border: Border.all(
                    color: const Color(0xFFB0C8FF),
                    width: 2,
                  ),
                ),
                child: Stack(
                  children: [
                    // Liquid level
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: AnimatedFractionallySizedBox(
                        duration: const Duration(milliseconds: 300),
                        widthFactor: 1.0,
                        heightFactor: fillRatio,
                        child: Container(
                          decoration: BoxDecoration(
                            color: bottleColor,
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(20),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: bottleColor.withValues(alpha: 0.6),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Bottle neck highlight
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        height: 12,
                        width: 30,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Controls: Pour Amount Slider & Pour Button
              Expanded(
                child: maxAvailable <= 0
                    ? Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent),
                            SizedBox(width: 8),
                            Text(
                              'Bottle Empty! Reset to refill.',
                              style: TextStyle(
                                color: Colors.orangeAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Pour Amount:',
                                style: TextStyle(
                                  color: Color(0xFF2C3E50),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${_pourAmountMl.round()} ml',
                                style: TextStyle(
                                  color: bottleColor,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
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
                              value: _pourAmountMl.clamp(0.0, maxAvailable),
                              min: 0,
                              max: maxAvailable > 0 ? maxAvailable : 1.0,
                              divisions: maxAvailable > 0 ? maxAvailable.round() : 1,
                              onChanged: (val) {
                                setState(() {
                                  _pourAmountMl = val;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Pour Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: bottleColor,
                                foregroundColor: bottle.type == PaintType.white
                                    ? const Color(0xFF2C3E50)
                                    : Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 4,
                              ),
                              onPressed: _pourAmountMl > 0
                                  ? () {
                                      widget.onPour(_pourAmountMl);
                                    }
                                  : null,
                              icon: const Icon(Icons.water_drop_rounded, size: 20),
                              label: Text(
                                'POUR ${_pourAmountMl.round()} ml INTO MIX',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
