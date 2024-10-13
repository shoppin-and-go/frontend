import 'package:flutter/material.dart';

// qr code 받기 위해 StatefulWidget 으로 수정
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
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
                // Navigator.pushNamed(context, '/qr_scan');
                // Navigator.pushNamed(context, '/scanner');
                _navigateAndDisplaySelection(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// pop 된 qr code SnackBar 로 띄워주기
Future<void> _navigateAndDisplaySelection(BuildContext context) async {
  // Navigator.push returns a Future that completes after calling
  // Navigator.pop on the Selection Screen.
  final result = await Navigator.pushNamed(context, '/qr_scan');

  if (!context.mounted) return;
  ScaffoldMessenger.of(context)
    ..removeCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text('$result')));
}
