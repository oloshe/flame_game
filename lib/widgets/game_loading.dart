import 'package:flutter/material.dart';

class GameLoading extends StatelessWidget {
  const GameLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: Color(0xff6797bb),
            ),
            const SizedBox(height: 10),
            Text(
              'editorLoading'.lang,
              style: const TextStyle(color: Color(0xff6797bb)),
            ),
          ],
        ),
      ),
    );
  }
}
