import 'package:statekit/statekit.dart';
import '../repository/tutorial_screen_repository.dart';
import '../binding/tutorial_screen_binding.dart';

class TutorialScreenController extends StateController<TutorialScreenBinding> {
  final TutorialScreenRepository _repository = TutorialScreenRepository();

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void dispose() {
    super.dispose();
  }
}