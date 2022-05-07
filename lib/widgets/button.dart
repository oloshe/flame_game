import 'package:flutter/material.dart';

class NormalButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String text;
  const NormalButton({
    Key? key,
    this.onTap,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: const Color(0xff3d424b),
        side: const BorderSide(
          color: Color(0xff464c55),
        ),
      ),
      onPressed: onTap,
      child: Text(text, style: const TextStyle(color: Color(0xffa0a7b4))),
    );
  }
}

class MainButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String text;
  final EdgeInsets? padding;
  final Icon? icon;
  final double? gap;
  const MainButton({
    Key? key,
    this.onTap,
    required this.text,
    this.padding,
    this.icon,
    this.gap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: const Color(0xff568af2),
        side: BorderSide.none,
        primary: const Color(0xFF13598E),
        padding: padding,
      ),
      onPressed: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) icon!,
          if (icon != null && gap != null) SizedBox(width: gap),
          Text(text, style: const TextStyle(color: Colors.white))
        ],
      ),
    );
  }
}

class MyIconButton extends StatelessWidget {
  final VoidCallback? onTap;
  final IconData icon;
  final Color? color;
  final String? tooltip;
  const MyIconButton({
    Key? key,
    this.onTap,
    required this.icon,
    this.color,
    this.tooltip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      padding: EdgeInsets.zero,
      splashColor: Colors.transparent,
      highlightColor: Colors.black,
      color: color,
      tooltip: tooltip,
      icon: Icon(icon),
    );
  }
}
