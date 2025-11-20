import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'main.dart';
import 'widgets/buttons.dart';
import 'widgets/camera_widget.dart';

class CameraApp extends StatefulWidget {
  const CameraApp({super.key});

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late CameraController controller;

  void switchCamera() async {
    if (cameras.length < 2) return;

    int currentIndex = cameras.indexOf(controller.description);
    int newIndex = (currentIndex + 1) % cameras.length;

    await controller.dispose();

    controller = CameraController(
      cameras[newIndex],
      ResolutionPreset.ultraHigh,
      enableAudio: false,
    );


    await controller.initialize();

    if (!mounted) return;

    setState(() {});
  }



  @override
  void initState() {
    super.initState();
    controller = CameraController(cameras[0], ResolutionPreset.max);

    controller.initialize().then((_) async {
      if (!mounted) return;

      await controller.setFlashMode(FlashMode.always);
      await controller.setZoomLevel(2.0);
      await controller.setExposureMode(ExposureMode.locked);
      await controller.setFocusMode(FocusMode.auto);

      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) return Container();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          children: [
            CameraPreviewWidget(controller: controller),
            ButtonsOverlay(onSwitch: switchCamera),
          ],
        ),
      ),
    );
  }
}

