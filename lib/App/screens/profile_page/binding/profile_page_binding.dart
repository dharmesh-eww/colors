import 'package:statekit/statekit.dart';

abstract interface class ProfilePageBinding implements StateBinding {
  void signInWithGoogle();
  void signOut();
}