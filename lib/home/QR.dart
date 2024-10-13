import 'package:flutter/material.dart';

import '../components/qr/barcode_scanner_analyze_image.dart';
import '../components/qr/barcode_scanner_listview.dart';
import '../components/qr/barcode_scanner_pageview.dart';
import '../components/qr/barcode_scanner_returning_image.dart';

class QRPage extends StatelessWidget {
  const QRPage({super.key});

  Widget _buildItem(BuildContext context, String label, Widget page) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => page,
              ),
            );
          },
          child: Text(label),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mobile Scanner Example')),
      body: Center(
        child: ListView(
          children: [
            _buildItem(
              context,
              'MobileScanner with ListView',
              const BarcodeScannerListView(),
            ),
            _buildItem(
              context,
              'MobileScanner with Controller (return image)',
              const BarcodeScannerReturningImage(),
            ),
            _buildItem(
              context,
              'MobileScanner with PageView',
              const BarcodeScannerPageView(),
            ),
            _buildItem(
              context,
              'Analyze image from file',
              const BarcodeScannerAnalyzeImage(),
            ),
          ],
        ),
      ),
    );
  }
}
