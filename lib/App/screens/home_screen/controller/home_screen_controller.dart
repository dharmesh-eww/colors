import 'package:statekit/statekit.dart';
import '../binding/home_screen_binding.dart';

class HomeScreenController extends StateController<HomeScreenBinding> {
  int _currentTabIndex = 0;

  int get currentTabIndex => _currentTabIndex;

  void changeTab(int index) {
    _currentTabIndex = index;
    update();
  }
}