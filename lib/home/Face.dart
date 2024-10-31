import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class FacePage extends StatefulWidget {
  const FacePage({
    super.key,
    required this.cameras,
  });

  final List<CameraDescription> cameras;

  @override
  State<FacePage> createState() => _FacePageState();
}

class _FacePageState extends State<FacePage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late FaceDetector _detector;
  bool _isDetecting = false;
  Size? _imageSize;
  List<Face> _faces = [];

  @override
  void initState() {
    super.initState();
    _controller =
        CameraController(widget.cameras[0], ResolutionPreset.ultraHigh);
    _initializeControllerFuture = _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      _controller.startImageStream(_processImage);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _detector.close();
    super.dispose();
  }

  void _processImage(CameraImage cameraImage) async {
    if (!_isDetecting && mounted) {
      _isDetecting = true;

      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in cameraImage.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final Size imageSize =
          Size(cameraImage.width.toDouble(), cameraImage.height.toDouble());

      final InputImageRotation imageRotation =
          _rotationIntToImageRotation(widget.cameras[0].sensorOrientation);

      final InputImageFormat inputImageFormat =
          InputImageFormatValue.fromRawValue(cameraImage.format.raw) ??
              InputImageFormat.nv21;

      final inputImageData = InputImageMetadata(
        size: imageSize,
        rotation: imageRotation,
        format: inputImageFormat,
        bytesPerRow: cameraImage.planes[0].bytesPerRow,
      );

      final inputImage =
          InputImage.fromBytes(bytes: bytes, metadata: inputImageData);

      final options = FaceDetectorOptions();
      _detector = FaceDetector(options: options);
      final faces = await _detector.processImage(inputImage);

      setState(() {
        _imageSize =
            Size(cameraImage.height.toDouble(), cameraImage.width.toDouble());
        _faces = faces;
      });
      await Future.delayed(const Duration(milliseconds: 250));
      _isDetecting = false;
    }
  }

  InputImageRotation _rotationIntToImageRotation(int rotation) {
    switch (rotation) {
      case 0:
        return InputImageRotation.rotation0deg;
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
    }
    return InputImageRotation.rotation0deg;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: CustomPaint(
            foregroundPainter: FacePainter(
              _imageSize,
              _faces,
            ),
            child: FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return CameraPreview(_controller);
                } else {
                  return const CircularProgressIndicator();
                }
              },
            )));
  }
}

class FacePainter extends CustomPainter {
  FacePainter(this.absoluteImageSize, this.elements);

  final Size? absoluteImageSize;
  final List<Face> elements;
  final TextPainter painter = TextPainter(
    textDirection: TextDirection.ltr,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final s = absoluteImageSize ?? const Size(1, 1);
    print(absoluteImageSize);

    final double scaleX = size.width / s.width;
    final double scaleY = size.height / s.height;

    Rect scaleRect(Face container) {
      return Rect.fromLTRB(
        container.boundingBox.left * scaleX,
        container.boundingBox.top * scaleY,
        container.boundingBox.right * scaleX,
        container.boundingBox.bottom * scaleY,
      );
    }

    void drawLandmark(Face element) {
      element.landmarks.forEach((key, value) {
        // 認識した顔の描画
        painter.text = TextSpan(
          text: key.name,
          style: const TextStyle(
            color: Colors.white,
            backgroundColor: Colors.blue,
            fontSize: 8.0,
          ),
        );
        Offset position = Offset(
          (value?.position.x ?? 0) * scaleX,
          (value?.position.y ?? 0) * scaleY,
        );
        painter.layout();
        painter.paint(canvas, position);
      });
    }

    void drawContour(Face element) {
      element.contours.forEach((key, value) {
        final path = Path()
          ..moveTo(
            (value?.points[0].x ?? 0) * scaleX,
            (value?.points[0].y ?? 0) * scaleY,
          );
        for (var point in value!.points) {
          path.lineTo(
            point.x * scaleX,
            point.y * scaleY,
          );
        }
        path.moveTo(
          (value.points[0].x) * scaleX,
          (value.points[0].y) * scaleY,
        );
        final paint = Paint()
          ..color = Colors.green
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

        canvas.drawPath(path, paint);
      });
    }

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.blue
      ..strokeWidth = 2.0;

    for (Face element in elements) {
      canvas.drawRect(scaleRect(element), paint);
      // drawLandmark(element);
      // drawContour(element);
    }
  }

  @override
  bool shouldRepaint(FacePainter oldDelegate) {
    return true;
  }
}
