import 'package:flutter/material.dart';
import 'app_camera.dart';
import 'package:camera/camera.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const CameraApp());
  // Widget build(BuildContext context) { 
  //   return MaterialApp(
  //     theme: ThemeData(
  //       primarySwatch: Color.fromARGB(0, 62, 142, 241),
  //     ),
  //   )
  // }
}
