import 'package:statekit/statekit.dart';
import 'package:flutter/material.dart';
import '../binding/profile_page_binding.dart';
import '../controller/profile_page_controller.dart';

class ProfilePage extends StatekitView<ProfilePageController> implements ProfilePageBinding {
  ProfilePage({super.key, super.tag});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF8B5E3C),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6E3B1C), Color(0xFF532911), Color(0xFF421E0B)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFFFD700), width: 2.0),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B1E08).withValues(alpha: 0.5),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF5DEB3), Color(0xFFD4A055)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFFD700), width: 2.0),
                ),
                child: const Icon(Icons.person_rounded, size: 36, color: Color(0xFF5D4037)),
              ),
              const SizedBox(height: 16),
              const Text(
                'PROFILE',
                style: TextStyle(
                  color: Color(0xFFFFF1D6),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Player stats & achievements coming soon!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFF5DEB3),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void doSomething() {}
}
