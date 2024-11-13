import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shoppin_and_go/services/cart_api_service.dart';
import 'package:shoppin_and_go/services/device_id_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final cartService = CartApiService(
      baseUrl: 'http://ec2-3-38-128-6.ap-northeast-2.compute.amazonaws.com');
  String? connectedCartCode;

  @override
  void initState() {
    super.initState();
    _checkExistingConnection();
  }

  Future<void> _checkExistingConnection() async {
    final connections =
        (await cartService.getCartConnections(DeviceIdService.deviceId))
            .where((connection) => connection.connected)
            .toList();
    setState(() {
      connectedCartCode =
          connections.isNotEmpty ? connections[0].cartCode : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _checkCameraPermission(context);
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
          if (connectedCartCode != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 40,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/cart',
                      arguments: connectedCartCode,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color.fromRGBO(0xDB, 0x1E, 0x17, 1),
                      width: 1.5,
                    ),
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        '사용하던 카트가 있습니다',
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 16,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 24,
                        color: Color.fromRGBO(0xDB, 0x1E, 0x17, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
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
}
