import 'dart:developer';
import 'dart:io';

import 'package:bancode_scanner/home_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bancode_scanner/app_colors.dart';

import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRViewExample extends StatefulWidget {
  const QRViewExample({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
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
          Expanded(flex: 4, child: _buildQrView(context)),
          Expanded(
            flex: 2,
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  'Scan Information',
                  style: TextStyle(fontSize: 20),
                ),
                const Divider(),
                if (result != null)
                  BuildResultShow(result: result)
                else
                  const Text(''),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          )
        ],
      ),
      bottomNavigationBar: Container(
        height: 50,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () {
                if (result != null) {
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const HomePage(),
                      ),
                      (Route<dynamic> route) => false);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('No Scan Information found!!')));
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColros.primaryColos),
              child: const Row(
                children: [
                  Text(
                    'Ok DONE',
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Icon(
                    Icons.done,
                    color: Colors.white,
                  )
                ],
              ),
            ),
            const SizedBox(
              width: 20,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 280.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: AppColros.primaryColos,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      controller.pauseCamera();
      if (kDebugMode) {
        print('--------------Scaned------');
        print(scanData);
        print('PPPPP');
      }
      setState(() {
        result = scanData;
      });
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

class BuildResultShow extends StatelessWidget {
  const BuildResultShow({
    super.key,
    required this.result,
  });

  final Barcode? result;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                flex: 1,
                child: Text(
                  'REG NO:',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '${result!.code}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          const Divider(),
          const Row(
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  'BRAND:',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Mojo',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          const Divider(),
          const Row(
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  'EXPAIRE DATE:',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '01-10-2024',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          const Divider(),
          const Row(
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  'WEIGHT',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '250ml',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          const Divider(),
        ],
      ),
    );
  }
}
