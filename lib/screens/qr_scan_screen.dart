import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({super.key});

  @override
  State<StatefulWidget> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // qr_code_scanner의 hot reload를 보장하려면 안드로이드의 경우에는 pauseCamera(),
  // iOS의 경우에는 resumeCamera()를 처리해줘야한다.
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
          //_buildQrView를 실행하면서 스캐너를 뷰에 뿌려줌
          Expanded(flex: 4, child: _buildQrView(context)),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // 디바이스의 크기에 따라 scanArea를 지정 반응형(?)과 비슷한 개념
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated, // QRView가 생성되면 _onQRViewCreated를 실행

      // QR을 읽힐 네모난 칸의 디자인을 설정
      overlay: QrScannerOverlayShape(
          borderColor: const Color.fromRGBO(0xDB, 0x1E, 0x17, 1), // 모서리 테두리 색
          borderRadius: 10, // 둥글게 둥글게
          borderLength: 30, // 테두리 길이 길면 길수록 네모에 가까워진다.
          borderWidth: 10, // 테두리 너비
          cutOutSize: scanArea),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller; // 컨트롤러를 통해 스캐너를 제어
    });

    // 인식시킬 QR코드가 여러개 붙어있을 경우 여러개를 한번에 인식해버리는
    // 문제가 발생하여 먼저 인식된 QR코드 하나만 인식하기위한 코드
    int counter = 0;
    controller.scannedDataStream.listen((scanData) async {
      counter++; // QR코드가 인식되면 counter를 1 올려준다.
      await controller.pauseCamera(); // 인식되었으니 카메라를 멈춘다.

      setState(() {
        result = scanData; // 스캔된 데이터를 담는다.

        // result를 다시 url로 담는다.
        String url = result!.code.toString();

        if (counter == 1) {
          // QR이 인식 되었을 경우 스캐너를 닫으며 결과를 넘긴다.
          Navigator.pop(context, url);
        }
      });
    });
  }

  // 사용이 끝나면 컨트롤러를 폐기
  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
