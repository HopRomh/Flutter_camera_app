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
            ButtonsOverlay(controller: controller, refresh: () => setState(() {})),
          ],
        ),
      ),
    );
  }
}
