import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:photo_app/screens/photo_screen.dart';


late List<CameraDescription> cameras;



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const PhotoApp());
}


class PhotoApp extends StatelessWidget {
  const PhotoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photos_app',
      home: PhotoScreen(cameras),
      debugShowCheckedModeBanner: false,
    );
  
  }

}

