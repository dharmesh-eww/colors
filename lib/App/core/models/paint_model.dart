import 'package:flutter/material.dart';

enum PaintType { cyan, magenta, yellow, black, white }

class PaintBottle {
  final PaintType type;
  final String name;
  final Color color;
  final String hexCode;
  double availableMl; // remaining available in bottle (0 - 100 ml)
  double pouredMl; // total poured into current mixture (0 - 100 ml)

  PaintBottle({
    required this.type,
    required this.name,
    required this.color,
    required this.hexCode,
    this.availableMl = 100.0,
    this.pouredMl = 0.0,
  });

  PaintBottle copyWith({
    double? availableMl,
    double? pouredMl,
  }) {
    return PaintBottle(
      type: type,
      name: name,
      color: color,
      hexCode: hexCode,
      availableMl: availableMl ?? this.availableMl,
      pouredMl: pouredMl ?? this.pouredMl,
    );
  }
}
