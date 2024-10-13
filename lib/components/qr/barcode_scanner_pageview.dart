import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import './barcode_scanner_listview.dart';

class BarcodeScannerPageView extends StatefulWidget {
  const BarcodeScannerPageView({super.key});

  @override
  State<BarcodeScannerPageView> createState() => _BarcodeScannerPageViewState();
}

class _BarcodeScannerPageViewState extends State<BarcodeScannerPageView> {
  final MobileScannerController controller = MobileScannerController();

  final PageController pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('With PageView')),
      backgroundColor: Colors.black,
      body: PageView(
        controller: pageController,
        onPageChanged: (index) async {
          await controller.stop();

          await Future.delayed(const Duration(seconds: 1, milliseconds: 500));

          if (!mounted) {
            return;
          }

          unawaited(controller.start());
        },
        children: [
          BarcodeScanner(controller: controller),
          const SizedBox(),
          BarcodeScanner(controller: controller),
          BarcodeScanner(controller: controller),
        ],
      ),
    );
  }

  @override
  Future<void> dispose() async {
    pageController.dispose();
    super.dispose();
    await controller.dispose();
  }
}
