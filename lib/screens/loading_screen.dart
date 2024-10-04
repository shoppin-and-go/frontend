import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(0xDB, 0x1E, 0x17, 1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', width: 250),
            ElevatedButton(
              child: const Text('시작하기'),
              onPressed: () {
                Navigator.pushNamed(context, '/qr_scan');
              },
            ),
          ],
        ),
      ),
    );
  }
}
