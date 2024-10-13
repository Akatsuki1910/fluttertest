import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import './scanner_button_widgets.dart';
import './scanner_error_widget.dart';

final barcodeScannerControllerProvider = StateNotifierProvider<
    BarcodeScannerControllerNotifier, MobileScannerController>(
  (ref) => BarcodeScannerControllerNotifier(),
);

class BarcodeScannerControllerNotifier
    extends StateNotifier<MobileScannerController> {
  BarcodeScannerControllerNotifier()
      : super(MobileScannerController(torchEnabled: true));

  Future<void> start() async {
    await state.start();
  }

  Future<void> stop() async {
    await state.stop();
  }

  Future<void> disposeController() async {
    await state.dispose();
  }

  void setZoom(double zoomFactor) {
    state.setZoomScale(zoomFactor);
  }
}

class BarcodeScannerListView extends HookConsumerWidget {
  const BarcodeScannerListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(barcodeScannerControllerProvider);

    useEffect(() {
      final lifecycleEventHandler = LifecycleEventHandler(
        resumeCallBack: () async {
          await controller.start();
        },
        suspendingCallBack: () async {
          await controller.stop();
        },
      );

      WidgetsBinding.instance.addObserver(lifecycleEventHandler);

      return () {
        WidgetsBinding.instance.removeObserver(lifecycleEventHandler);
      };
    }, [controller]);

    return Scaffold(
      appBar: AppBar(title: const Text('With ListView')),
      backgroundColor: Colors.black,
      body: BarcodeScanner(controller: controller),
    );
  }
}

class BarcodeScanner extends HookConsumerWidget {
  const BarcodeScanner({super.key, required this.controller});
  final MobileScannerController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zoomFactor = useState(0.0);

    final scanWindow = Rect.fromCenter(
      center: MediaQuery.sizeOf(context).center(Offset.zero),
      width: 200,
      height: 200,
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        MobileScanner(
          scanWindow: scanWindow,
          controller: controller,
          errorBuilder: (context, error, child) {
            return ScannerErrorWidget(error: error);
          },
          fit: BoxFit.contain,
        ),
        _buildBarcodeOverlay(controller),
        _buildScanWindow(scanWindow),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            alignment: Alignment.bottomCenter,
            height: 150,
            color: Colors.black.withOpacity(0.4),
            child: Column(
              children: [
                _buildZoomScaleSlider(controller, zoomFactor),
                Expanded(child: _buildBarcodesListView(controller)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ToggleFlashlightButton(controller: controller),
                    StartStopMobileScannerButton(controller: controller),
                    const Spacer(),
                    SwitchCameraButton(controller: controller),
                    AnalyzeImageFromGalleryButton(controller: controller),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBarcodesListView(MobileScannerController controller) {
    return StreamBuilder<BarcodeCapture>(
      stream: controller.barcodes,
      builder: (context, snapshot) {
        final barcodes = snapshot.data?.barcodes;

        if (barcodes == null || barcodes.isEmpty) {
          return const Center(
            child: Text(
              'Scan Something!',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          );
        }

        return ListView.builder(
          itemCount: barcodes.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                barcodes[index].rawValue ?? 'No raw value',
                overflow: TextOverflow.fade,
                style: const TextStyle(color: Colors.white),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildZoomScaleSlider(
    MobileScannerController controller,
    ValueNotifier<double> zoomFactor,
  ) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, state, child) {
        if (!state.isInitialized || !state.isRunning) {
          return const SizedBox.shrink();
        }

        final TextStyle labelStyle = Theme.of(context)
            .textTheme
            .headlineMedium!
            .copyWith(color: Colors.white);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Text(
                '0%',
                overflow: TextOverflow.fade,
                style: labelStyle,
              ),
              Expanded(
                child: Slider(
                  value: zoomFactor.value,
                  onChanged: (value) {
                    zoomFactor.value = value;
                    controller.setZoomScale(value);
                  },
                ),
              ),
              Text(
                '100%',
                overflow: TextOverflow.fade,
                style: labelStyle,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBarcodeOverlay(MobileScannerController controller) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, value, child) {
        if (!value.isInitialized || !value.isRunning || value.error != null) {
          return const SizedBox();
        }

        return StreamBuilder<BarcodeCapture>(
          stream: controller.barcodes,
          builder: (context, snapshot) {
            final BarcodeCapture? barcodeCapture = snapshot.data;

            if (barcodeCapture == null || barcodeCapture.barcodes.isEmpty) {
              return const SizedBox();
            }

            final scannedBarcode = barcodeCapture.barcodes.first;

            if (value.size.isEmpty ||
                scannedBarcode.size.isEmpty ||
                scannedBarcode.corners.isEmpty) {
              return const SizedBox();
            }

            return CustomPaint(
              painter: BarcodeOverlay(
                barcodeCorners: scannedBarcode.corners,
                barcodeSize: scannedBarcode.size,
                boxFit: BoxFit.contain,
                cameraPreviewSize: value.size,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildScanWindow(Rect scanWindowRect) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, value, child) {
        if (!value.isInitialized ||
            !value.isRunning ||
            value.error != null ||
            value.size.isEmpty) {
          return const SizedBox();
        }

        return CustomPaint(
          painter: ScannerOverlay(scanWindowRect),
        );
      },
    );
  }
}

class LifecycleEventHandler extends WidgetsBindingObserver {
  LifecycleEventHandler(
      {required this.resumeCallBack, required this.suspendingCallBack});

  final Future<void> Function() resumeCallBack;
  final Future<void> Function() suspendingCallBack;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      resumeCallBack();
    } else if (state == AppLifecycleState.paused) {
      suspendingCallBack();
    }
  }
}

class BarcodeOverlay extends CustomPainter {
  BarcodeOverlay({
    required this.barcodeCorners,
    required this.barcodeSize,
    required this.boxFit,
    required this.cameraPreviewSize,
  });

  final List<Offset> barcodeCorners;
  final Size barcodeSize;
  final BoxFit boxFit;
  final Size cameraPreviewSize;

  @override
  void paint(Canvas canvas, Size size) {
    if (barcodeCorners.isEmpty ||
        barcodeSize.isEmpty ||
        cameraPreviewSize.isEmpty) {
      return;
    }

    final adjustedSize = applyBoxFit(boxFit, cameraPreviewSize, size);

    double verticalPadding = size.height - adjustedSize.destination.height;
    double horizontalPadding = size.width - adjustedSize.destination.width;
    if (verticalPadding > 0) {
      verticalPadding = verticalPadding / 2;
    } else {
      verticalPadding = 0;
    }

    if (horizontalPadding > 0) {
      horizontalPadding = horizontalPadding / 2;
    } else {
      horizontalPadding = 0;
    }

    final double ratioWidth;
    final double ratioHeight;

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      ratioWidth = barcodeSize.width / adjustedSize.destination.width;
      ratioHeight = barcodeSize.height / adjustedSize.destination.height;
    } else {
      ratioWidth = cameraPreviewSize.width / adjustedSize.destination.width;
      ratioHeight = cameraPreviewSize.height / adjustedSize.destination.height;
    }

    final List<Offset> adjustedOffset = [
      for (final offset in barcodeCorners)
        Offset(
          offset.dx / ratioWidth + horizontalPadding,
          offset.dy / ratioHeight + verticalPadding,
        ),
    ];

    final cutoutPath = Path()..addPolygon(adjustedOffset, true);

    final backgroundPaint = Paint()
      ..color = Colors.red.withOpacity(0.3)
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;

    canvas.drawPath(cutoutPath, backgroundPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class ScannerOverlay extends CustomPainter {
  ScannerOverlay(this.scanWindow);

  final Rect scanWindow;

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()..addRect(Rect.largest);
    final cutoutPath = Path()..addRect(scanWindow);

    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;

    final backgroundWithCutout = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );
    canvas.drawPath(backgroundWithCutout, backgroundPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
