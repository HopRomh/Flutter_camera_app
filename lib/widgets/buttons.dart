import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../main.dart';

class ButtonsOverlay extends StatelessWidget {
  final CameraController controller;
  final VoidCallback refresh;

  const ButtonsOverlay({super.key, required this.controller, required this.refresh});

  void switchCamera(BuildContext context) async {
    if (cameras.length < 2) return;

    int currentIndex = cameras.indexOf(controller.description);
    int newIndex = (currentIndex + 1) % cameras.length;

    await controller.dispose();
    CameraController(cameras[newIndex], ResolutionPreset.max);
    await controller.initialize();
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 20,
          bottom: 20,
          child: FloatingActionButton(
            heroTag: "switch_camera",
            onPressed: () => switchCamera(context),
            child: Icon(Icons.cameraswitch),
          ),
        ),
      ],
    );
  }
}
