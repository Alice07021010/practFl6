import 'package:flutter/material.dart';

import '../services/theme_controller.dart';

class ThemeButton extends StatelessWidget {
  final ThemeController controller;

  const ThemeButton({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: controller.toggle,
      icon: Icon(
        controller.isDark
            ? Icons.light_mode
            : Icons.dark_mode,
      ),
    );
  }
}