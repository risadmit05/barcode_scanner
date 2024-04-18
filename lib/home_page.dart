import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:bancode_scanner/app_colors.dart';
import 'package:bancode_scanner/scan_qr_code.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('JOMUNA FILLING STATION')),
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(color: AppColros.primaryDark),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.2,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'BARCODE SCANNER ',
                  style: TextStyle(fontSize: 25, color: Colors.white),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'SCAN YOUR PRODUCT',
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Lottie.asset('assets/scan.json',
                    width: MediaQuery.of(context).size.height * 0.4,
                    height: MediaQuery.of(context).size.height * 0.4),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.to(const QRViewExample());
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColros.primaryColos),
                    child: const Text(
                      'SCAN NOW',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
