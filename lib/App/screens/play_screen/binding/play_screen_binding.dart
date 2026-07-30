import 'package:statekit/statekit.dart';
import '../../../core/models/paint_model.dart';

abstract interface class PlayScreenBinding implements StateBinding {
  void onPaintAmountChanged(PaintType type, double value);
  void onMixPressed();
  void onResetPressed();
}