import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shoppin_and_go/services/cart_api_service.dart';
import 'package:shoppin_and_go/models/exceptions.dart';

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({super.key});

  @override
  State<StatefulWidget> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // CartApiService 인스턴스 생성
  final cartService = CartApiService(
      baseUrl: 'http://ec2-3-38-128-6.ap-northeast-2.compute.amazonaws.com');

  // 플랫폼에 따라 카메라 제어 (안드로이드: pause, iOS: resume)
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

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

    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated, // QRView가 생성되면 _onQRViewCreated 실행
      overlay: QrScannerOverlayShape(
          borderColor: const Color.fromRGBO(0xDB, 0x1E, 0x17, 1), // 스캐너 테두리 색상
          borderRadius: 10, // 테두리 둥근 정도
          borderLength: 30, // 테두리 길이
          borderWidth: 10, // 테두리 너비
          cutOutSize: scanArea), // 스캔 영역 크기
    );
  }

  // QR 스캐너 생성 시 호출되는 함수
  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;

    int counter = 0; // 여러 QR 인식 방지용 카운터
    controller.scannedDataStream.listen((scanData) async {
      if (counter > 0 || scanData.code == null) return;
      counter++;

      await controller.pauseCamera(); // 첫 인식 후 카메라 정지

      try {
        const deviceId = 'test-device-id'; // 임시 디바이스 ID 사용
        final response = await cartService.connectCart(
          deviceId,
          scanData.code!,
        );

        if (!mounted) return;
        Navigator.pop(context,
            response.result.connection.cartCode); // 스캔 완료 후 카트 코드 반환하며 화면 종료
      } catch (e) {
        if (!mounted) return;

        String errorMessage = '알 수 없는 오류가 발생했습니다.';
        if (e is CartNotFoundException) {
          errorMessage = '존재하지 않는 카트입니다.';
        } else if (e is DeviceAlreadyConnectedException) {
          errorMessage = '이미 다른 카트와 연결되어 있습니다.';
        }

        // 에러 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );

        Navigator.pop(context);
      }
    });
  }

  // 사용자가 직접 코드를 입력할 수 있는 다이얼로그
  Future<void> _manualCodeInput() async {
    String? code = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        TextEditingController textController = TextEditingController();
        return AlertDialog(
          title: const Text("코드 입력"),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(hintText: "코드를 입력하세요"),
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
                Navigator.pop(context, null); // 취소 시 null 반환
              },
              child: const Text("취소"),
            ),
          ],
        );
      },
    );

    // 입력한 코드가 null이 아니고 비어 있지 않을 경우 해당 코드 반환
    if (code != null && code.isNotEmpty && mounted) {
      Navigator.pop(context, code);
    }
  }

  // 위젯이 제거될 때 컨트롤러 리소스 해제
  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
