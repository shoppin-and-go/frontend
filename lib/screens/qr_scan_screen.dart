import 'package:flutter/material.dart';
import 'package:shoppin_and_go/services/cart_api_service.dart';
import 'package:shoppin_and_go/models/exceptions.dart';
import 'package:shoppin_and_go/services/device_id_service.dart';

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({super.key});

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  final cartService = CartApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          // QR 스캐너 뷰
          Expanded(flex: 9, child: _buildQrView(context)),
          // 하단에 직접 코드 입력 버튼 추가
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: _manualCodeInput, // 버튼 클릭 시 직접 코드 입력 함수 호출
                  child: const Text("직접 코드 입력"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // QR 스캐너 뷰를 빌드하는 위젯
  Widget _buildQrView(BuildContext context) {
    // 화면 크기에 맞춰 QR 스캔 영역 크기 설정
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;

    return Stack(
      children: [
        // 반투명한 검정색 배경
        Container(
          color: Colors.black54,
        ),
        Center(
          child: Container(
            width: scanArea,
            height: scanArea,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  // 좌앙 텍스트 추가
                  const Center(
                    child: Text(
                      "카메라를 사용할 수 없습니다.\n직접 코드 입력을 통해 연결하세요",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ),
                  // 좌상단
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        border: Border(
                          left: BorderSide(color: Color(0xFFDB1E17), width: 6),
                          top: BorderSide(color: Color(0xFFDB1E17), width: 6),
                        ),
                      ),
                    ),
                  ),
                  // 우상단
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        border: Border(
                          right: BorderSide(color: Color(0xFFDB1E17), width: 6),
                          top: BorderSide(color: Color(0xFFDB1E17), width: 6),
                        ),
                      ),
                    ),
                  ),
                  // 좌하단
                  Positioned(
                    left: 0,
                    bottom: 0,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        border: Border(
                          left: BorderSide(color: Color(0xFFDB1E17), width: 6),
                          bottom:
                              BorderSide(color: Color(0xFFDB1E17), width: 6),
                        ),
                      ),
                    ),
                  ),
                  // 우하단
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        border: Border(
                          right: BorderSide(color: Color(0xFFDB1E17), width: 6),
                          bottom:
                              BorderSide(color: Color(0xFFDB1E17), width: 6),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 사용자가 직접 코드를 입력할 수 있는 다이얼로그
  Future<void> _manualCodeInput() async {
    bool easterEgg = false;
    String? code = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        TextEditingController textController = TextEditingController(
          text: 'cart-',
        );
        return AlertDialog(
          title: const Text("코드 입력"),
          content: Column(
            mainAxisSize: MainAxisSize.min, // Column의 크기를 내용물에 맞게 조절
            crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
            children: [
              TextField(
                controller: textController,
                decoration: const InputDecoration(hintText: "코드를 입력하세요"),
              ),
              const SizedBox(height: 8), // 간격 추가
              const Text(
                "시연 가능 카트: cart-1, cart-2",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context, textController.text); // 입력 완료 시 값 반환
              },
              child: const Text("확인"),
            ),
            TextButton(
              onPressed: () {
                if (textController.text == 'disconnect') {
                  easterEgg = true;
                }
                Navigator.pop(context, null); // 취소 시 null 반환
              },
              child: const Text("취소"),
            ),
          ],
        );
      },
    );

    // 현재 디바이스와 연결된 카트를 해제
    if (easterEgg) {
      await cartService.disconnectFromAllCarts(DeviceIdService.deviceId);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('${DeviceIdService.deviceId}와의 연결을 해제했습니다.')),
        );
    }
    // 입력한 코드가 null이 아니고 비어 있지 않을 경우 API 호출
    if (code != null && code.isNotEmpty && mounted) {
      await _tryConnectCart(code);
    }
  }

  // 카트 연결 및 처리 함수
  Future<void> _tryConnectCart(String code) async {
    try {
      final response = await cartService.connectCart(
        DeviceIdService.deviceId,
        code,
      );

      if (!mounted) return;
      Navigator.pop(context, response.result.connection.cartCode);
    } catch (e) {
      if (!mounted) return;

      String errorMessage = '알 수 없는 오류가 발생했습니다.';
      if (e is CartNotFoundException) {
        errorMessage = '존재하지 않는 카트입니다.';
      } else if (e is DeviceAlreadyConnectedException) {
        if (e.message.contains('This device')) {
          errorMessage = '이미 다른 카트와 연결되어 있습니다.';
        } else {
          errorMessage = '이미 다른 디바이스와 연결되어 있습니다.';
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );

      Navigator.pop(context);
    }
  }
}
