import 'package:flutter/material.dart';

class TradeLinkAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showBottomBorder;

  const TradeLinkAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.showBottomBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: Theme.of(context).textTheme.headlineLarge),
      leading: leading,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
