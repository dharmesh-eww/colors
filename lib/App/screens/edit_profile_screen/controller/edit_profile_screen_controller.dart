import 'package:flutter/material.dart';
import 'package:statekit/statekit.dart';
import '../../../core/models/country_model.dart';
import '../../profile_page/controller/profile_page_controller.dart';
import '../binding/edit_profile_screen_binding.dart';

class EditProfileScreenController extends StateController<EditProfileScreenBinding> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  Country _selectedCountry = Country.defaultCountry;
  int _selectedAvatarIndex = 0;
  String _searchQuery = "";

  Country get selectedCountry => _selectedCountry;
  int get selectedAvatarIndex => _selectedAvatarIndex;
  String get searchQuery => _searchQuery;

  static const List<String> avatarEmojis = [
    "👤",
    "🤠",
    "🧙‍♂️",
    "👑",
    "🥷",
    "🦸‍♂️",
    "👩‍🎨",
    "👨‍🚀",
    "🏴‍☠️",
    "🕵️",
    "🦊",
    "🦁",
    "🐯",
    "🐼",
    "🐻",
    "🐺",
    "🦅",
    "🐉",
    "🦄",
    "🦉",
    "🐱",
    "🐶",
    "🐵",
    "🦩",
    "⚡",
    "🔥",
    "🌟",
    "🎨",
    "🧪",
    "💎",
    "🏆",
    "🔮",
  ];
  String get currentAvatarEmoji => avatarEmojis[_selectedAvatarIndex % avatarEmojis.length];

  List<Country> get filteredCountries {
    if (_searchQuery.trim().isEmpty) {
      return Country.allCountries;
    }
    final query = _searchQuery.toLowerCase().trim();
    return Country.allCountries.where((c) {
      return c.name.toLowerCase().contains(query) || c.code.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    try {
      final profileCtrl = Statekit.find<ProfilePageController>();
      nameController.text = profileCtrl.userName;
      _selectedCountry = profileCtrl.userCountry;
      _selectedAvatarIndex = profileCtrl.avatarIndex;
    } catch (_) {
      nameController.text = "Guest User";
      _selectedCountry = Country.defaultCountry;
      _selectedAvatarIndex = 0;
    }
  }

  void selectAvatar(int index) {
    _selectedAvatarIndex = index;
    update();
  }

  void selectCountry(Country country) {
    _selectedCountry = country;
    update();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    update();
  }

  void clearSearch() {
    searchController.clear();
    _searchQuery = "";
    update();
  }

  void saveProfile(BuildContext context) {
    final newName = nameController.text.trim().isEmpty ? "Guest User" : nameController.text.trim();
    try {
      final profileCtrl = Statekit.find<ProfilePageController>();
      profileCtrl.updateProfile(
        name: newName,
        country: _selectedCountry,
        avatarIndex: _selectedAvatarIndex,
      );
    } catch (_) {}

    Navigator.pop(context);
  }

  @override
  void dispose() {
    nameController.dispose();
    searchController.dispose();
    super.dispose();
  }
}
