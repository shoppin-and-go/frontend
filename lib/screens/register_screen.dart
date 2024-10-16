import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

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
                _checkCameraPermission(context); // 권환 확인
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

Future<void> _checkCameraPermission(BuildContext context) async {
  var status = await Permission.camera.status;
  if (status.isDenied) {
    // 권한이 없을 때 권한 요청
    status = await Permission.camera.request();
  }

  if (!context.mounted) return;
  if (status.isGranted) {
    // 권한이 허용된 경우에만 QR 스캔 화면으로 이동
    _navigateToScannerAndCart(context);
  } else if (status.isPermanentlyDenied) {
    // 영구 거부 상태일 때 사용자에게 설정으로 이동하도록 안내
    _showPermissionDeniedDialog(context);
  } else {
    // 권한이 없을 경우 안내 메시지 표시
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('카메라 권한이 필요합니다.')),
    );
  }
}

void _showPermissionDeniedDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: const Text('카메라 권한 필요'),
      content: const Text('이 기능을 사용하려면 설정에서 카메라 권한을 허용해야 합니다.'),
      actions: <Widget>[
        TextButton(
          child: const Text('취소'),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          child: const Text('설정으로 이동'),
          onPressed: () async {
            Navigator.pop(context);
            await openAppSettings();
          },
        ),
      ],
    ),
  );
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
