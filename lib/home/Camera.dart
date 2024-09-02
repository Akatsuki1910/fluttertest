import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({
    super.key,
    required this.cameras,
  });

  final List<CameraDescription> cameras;

  @override
  CameraPageState createState() => CameraPageState();
}

class CameraPageState extends State<CameraPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    print(widget.cameras.length);
    _controller =
        CameraController(widget.cameras[0], ResolutionPreset.ultraHigh);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return CameraPreview(_controller);
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () async {
              print('onTap');
              final image = await _controller.takePicture();
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ImagePreview(imagePath: image.path),
                  fullscreenDialog: true,
                ),
              );
            },
            onLongPress: () async {
              print('onLongPress');
              await _controller.startVideoRecording();
            },
            onLongPressUp: () async {
              print('onLongPressUp');
              final video = await _controller.stopVideoRecording();
              // 表示用の画面に遷移
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => VideoPreview(videoPath: video.path),
                  fullscreenDialog: true,
                ),
              );
            },
            child: ConstrainedBox(
                constraints: const BoxConstraints.expand(),
                child: const Icon(Icons.add_a_photo)),
          ),
          onPressed: () {},
        ));
  }
}

// 撮影した写真を表示する画面
class ImagePreview extends StatelessWidget {
  const ImagePreview({super.key, required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview')),
      body: Center(child: Image.network(imagePath)),
    );
  }
}

// 撮影した動画を表示する画面
class VideoPreview extends StatefulWidget {
  const VideoPreview({
    super.key,
    required this.videoPath,
  });

  final String videoPath;

  @override
  _VideoPreviewState createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  late VideoPlayerController _controller;
  late Future<void> _initializeControllerFuture;
  late VoidCallback _listener;
  bool playSwitch = false;
  bool _isPlayComplete = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoPath);
    _initializeControllerFuture = _controller.initialize().then((_) {
      setState(() {});

      _listener = () {
        if (!_controller.value.isPlaying) {
          print('finish');
          // 再生完了
          setState(() {
            _isPlayComplete = true;
          });
          _controller.pause();
        }
      };
      _controller.addListener(_listener);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Preview')),
        body: Center(
          child: FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (_, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: () async {
                            // 動画を最初から再生
                            await _controller.pause();
                            await _controller
                                .seekTo(Duration.zero)
                                .then((_) => _controller.play());
                            playSwitch = true;
                            setState(() {});
                          },
                          icon: const Icon(Icons.refresh),
                        ),
                        playSwitch && !_isPlayComplete
                            ? IconButton(
                                onPressed: () async {
                                  // 動画を一時停止
                                  await _controller.pause();
                                  playSwitch = !playSwitch;
                                  setState(() {});
                                },
                                icon: const Icon(Icons.pause),
                              )
                            : IconButton(
                                onPressed: () async {
                                  // 動画を再生
                                  await _controller.play();
                                  playSwitch = !playSwitch;
                                  _isPlayComplete = false;
                                  setState(() {});
                                },
                                icon: const Icon(Icons.play_arrow),
                              )
                      ],
                    ),
                  ],
                );
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
        ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
