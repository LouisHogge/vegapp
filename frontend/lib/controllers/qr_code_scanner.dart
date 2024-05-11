import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

/// A widget that provides a QR code scanner functionality.
class QRCodeScanner extends StatefulWidget {
  /// A callback function that will be called when a barcode is scanned.
  final Function(Barcode) onResult;

  /// Creates a new instance of [QRCodeScanner].
  const QRCodeScanner({Key? key, required this.onResult}) : super(key: key);

  @override
  QRScannerCodeState createState() => QRScannerCodeState();
}

class QRScannerCodeState extends State<QRCodeScanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else {
      controller!.resumeCamera();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Colors.green,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: MediaQuery.of(context).size.width * 0.8,
      ),
    );
  }

  /// Callback function that is called when the QR view is created.
  ///
  /// It sets the [controller] and listens to the scanned data stream.
  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      widget.onResult(scanData);
    });
  }
}
