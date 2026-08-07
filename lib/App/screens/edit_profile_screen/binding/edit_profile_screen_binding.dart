import 'package:flutter/material.dart';
import 'package:statekit/statekit.dart';
import '../../../core/models/country_model.dart';

abstract interface class EditProfileScreenBinding implements StateBinding {
  void selectCountry(Country country);
  void saveProfile(BuildContext context);
}