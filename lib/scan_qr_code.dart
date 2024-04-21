import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:bancode_scanner/home_page.dart';
import 'package:bancode_scanner/model/api_response.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
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
  ApiResponse? apiResponse;
  bool isloading = false;

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
                if (apiResponse != null)
                  BuildResultShow(
                    apiResponse: apiResponse,
                    isLoading: isloading,
                  )
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
                // if (result != null) {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const HomePage(),
                    ),
                    (Route<dynamic> route) => false);
                // } else {
                //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                //       content: Text('No Scan Information found!!')));
                // }
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
      if (isNumericUsingRegularExpression(scanData.code!)) {
        controller.pauseCamera();
        if (kDebugMode) {
          print('--------------Scaned------');
          print(scanData.code);
          print('PPPPP');
        }

        callApi(scanData.code);
        setState(() {
          result = scanData;
        });
      }
    });
  }

  bool isNumericUsingRegularExpression(String string) {
    final numericRegex = RegExp(r'^-?(([0-9]*)|(([0-9]*)\.([0-9]*)))$');

    return numericRegex.hasMatch(string);
  }

  callApi(var code) async {
    isloading = true;
    setState(() {});
    apiResponse = await getCallAPI(code: code);
    isloading = false;
    setState(() {});
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

  getCallAPI({required var code}) async {
    try {
      final response =
          await http.get(Uri.parse('https://orginal.mallocsoft.com/$code'));
      var data = jsonDecode(response.body);

  
      if (response.statusCode == 200 && data['Status'] == true) {
        return ApiResponse.fromJson(data);
      } else {
        return ApiResponse(
            message: data['message'], status: false, value: null);
      }
    } catch (e) {
      print(e);
      return ApiResponse(message: e.toString(), status: false, value: null);
    }
  }
}

class BuildResultShow extends StatelessWidget {
  const BuildResultShow({
    super.key,
    required this.apiResponse,
    required this.isLoading,
  });

  final ApiResponse? apiResponse;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            CircularProgressIndicator(
              strokeWidth: 6,
            )
          ],
        ),
      );
    } else if (apiResponse!.status == true) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(
                  flex: 1,
                  child: Text(
                    'Product:',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '${apiResponse!.value!.product}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              children: [
                const Expanded(
                  flex: 1,
                  child: Text(
                    'EXPAIRE DATE:',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '${apiResponse!.value!.exdate}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              children: [
                const Expanded(
                  flex: 1,
                  child: Text(
                    'PRICE:',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '${apiResponse!.value!.price}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              children: [
                const Expanded(
                  flex: 1,
                  child: Text(
                    'MESSAGE',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '${apiResponse!.message}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            const Divider(),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(
                  flex: 1,
                  child: Text(
                    'MESSAGE',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '${apiResponse!.message}',
                    style: const TextStyle(fontSize: 12),
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
}
