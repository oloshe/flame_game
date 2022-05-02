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
  const MainButton({
    Key? key,
    this.onTap,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: const Color(0xff568af2),
        side: BorderSide.none,
        primary: const Color(0xFF13598E),
      ),
      onPressed: onTap,
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }
}
