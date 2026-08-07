import 'package:statekit/statekit.dart';
import 'package:flutter/material.dart';
import '../../base_screen/view/base_screen.dart';
import '../../base_screen/view/custom_appbar.dart';
import '../binding/tutorial_screen_binding.dart';
import '../controller/tutorial_screen_controller.dart';

class TutorialScreen extends StatekitView<TutorialScreenController> implements TutorialScreenBinding {
  TutorialScreen({super.key, super.tag});

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      appBar: CustomAppbar(title: Text("tutorial screen")),
      body: StateBuilder<TutorialScreenController>(
        controller: controller,
        builder: (context, controller, child) {
          return Center(
            child: Text("tutorial screen"),
          );
        },
      ),
    );
  }

  @override
  void doSomething() {
    // TODO: implement doSomething
  }
}