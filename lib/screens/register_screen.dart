import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                _navigateToScannerAndCart(context);
              },
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(24),
                backgroundColor: const Color.fromRGBO(0xDB, 0x1E, 0x17, 1),
                elevation: 8,
                shadowColor: Colors.black,
              ),
              child: const Icon(
                Icons.qr_code_scanner,
                size: 84,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              "카트를 등록하세요",
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// pop 된 qr code SnackBar 로 띄워주기
Future<void> _navigateToScannerAndCart(BuildContext context) async {
  // Navigator.push returns a Future that completes after calling
  // Navigator.pop on the Selection Screen.
  final result = await Navigator.pushNamed(context, '/scanner');

  if (!context.mounted) return;
  if (result != null) {
    // QR 스캔 결과가 있어야 snackbar를 띄우고 카트 화면으로 이동
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$result')));
    Navigator.pushNamed(context, '/cart', arguments: result);
  }
}
