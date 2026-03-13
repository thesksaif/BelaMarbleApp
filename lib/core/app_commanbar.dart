import 'package:flutter/material.dart';

import 'app_colors.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool centerTitle;
  final List<Widget>? actions;
  final Widget? leading;

  const CommonAppBar({
    super.key,
    required this.title,
    this.centerTitle = true,
    this.actions,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.appbar,
      elevation: 0,
      centerTitle: centerTitle,
      iconTheme: const IconThemeData(color: Colors.black),

      // -----------------
      // 🔥 Default Back Button
      // -----------------
      leading: leading,

      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),

      actions: actions,
      foregroundColor: Colors.white,
      shadowColor: Colors.white,
      surfaceTintColor: Colors.white,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
