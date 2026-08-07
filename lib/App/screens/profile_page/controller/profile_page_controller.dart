import 'package:statekit/statekit.dart';
import '../../../core/models/country_model.dart';
import '../binding/profile_page_binding.dart';

class ProfilePageController extends StateController<ProfilePageBinding> {
  bool _isSignedIn = false;
  bool _isLoading = false;
  String _userName = "Guest User";
  Country _userCountry = Country.defaultCountry;
  int _avatarIndex = 0;

  static const List<String> avatarEmojis = [
    "👤", "🤠", "🧙‍♂️", "👑", "🥷", "🦸‍♂️", "👩‍🎨", "👨‍🚀", "🏴‍☠️", "🕵️",
    "🦊", "🦁", "🐯", "🐼", "🐻", "🐺", "🦅", "🐉", "🦄", "🦉", "🐱", "🐶", "🐵", "🦩",
    "⚡", "🔥", "🌟", "🎨", "🧪", "💎", "🏆", "🔮"
  ];

  final int _levelsCompleted = 42;
  final int _starsEarned = 118;

  bool get isSignedIn => _isSignedIn;
  bool get isLoading => _isLoading;
  String get userName => _userName;
  Country get userCountry => _userCountry;
  int get avatarIndex => _avatarIndex;
  String get currentAvatarEmoji => avatarEmojis[_avatarIndex % avatarEmojis.length];
  int get levelsCompleted => _levelsCompleted;
  int get starsEarned => _starsEarned;

  void updateProfile({required String name, required Country country, int? avatarIndex}) {
    _userName = name;
    _userCountry = country;
    if (avatarIndex != null) {
      _avatarIndex = avatarIndex;
    }
    update();
  }

  void signInWithGoogle() async {
    if (_isLoading) return;
    _isLoading = true;
    update();

    await Future.delayed(const Duration(milliseconds: 600));

    _isSignedIn = true;
    _userName = "Alex Rivers";
    _isLoading = false;
    update();
  }

  void signOut() async {
    if (_isLoading) return;
    _isLoading = true;
    update();

    await Future.delayed(const Duration(milliseconds: 400));

    _isSignedIn = false;
    _userName = "Guest User";
    _isLoading = false;
    update();
  }
}