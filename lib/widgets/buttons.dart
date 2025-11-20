import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class ButtonsOverlay extends StatelessWidget {
  final VoidCallback onSwitch;

  const ButtonsOverlay({super.key, required this.onSwitch});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 20,
      bottom: 20,
      child: FloatingActionButton(
        heroTag: "switch_camera",
        onPressed: onSwitch,
        child: Icon(Icons.cameraswitch),
      ),
    );
  }
}
