// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';

// late List<CameraDescription> _cameras;

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   _cameras = await availableCameras();
//   runApp(const CameraApp());
// }

// class CameraApp extends StatefulWidget {
//   const CameraApp({super.key});

//   @override
//   State<CameraApp> createState() => _CameraAppState();
// }

// class _CameraAppState extends State<CameraApp> {
//   late CameraController controller;

//   @override
//   void initState() {
//     super.initState();
//     controller = CameraController(_cameras[0], ResolutionPreset.max);

//     controller
//         .initialize()
//         .then((_) async {
//           if (!mounted) return;

//           // Вся настройка камеры
//           await controller.setFlashMode(FlashMode.always);
//           // double minZoom = await controller.getMinZoomLevel();
//           // double maxZoom = await controller.getMaxZoomLevel();

//           await controller.setZoomLevel(2.0);
//           await controller.setExposureMode(ExposureMode.locked);
//           await controller.setFocusMode(FocusMode.auto);

//           setState(() {});
//         })
//         .catchError((Object e) {
//           if (e is CameraException) {
//             switch (e.code) {
//               case 'CameraAccessDenied':
//                 //Handle access errors here.
//                 break;
//               default:
//                 // erorrs..
//                 break;
//             }
//           }
//         });
//   }

//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!controller.value.isInitialized) {
//       return Container();
//     }

//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: Scaffold(
//         body: Stack(
//           children: [
//             Center(
//               child: AspectRatio(
//                 aspectRatio: controller.value.aspectRatio,
//                 child: CameraPreview(controller),
//               ),
//             ),

//             // Positioned(
//             //   bottom: 20,
//             //   left: 0,
//             //   right: 0,
//             //   child: Center(
//             //     child: FloatingActionButton(
//             //       heroTag: "take_photo",
//             //       onPressed: takePhoto,
//             //       child: Icon(Icons.camera),
//             //     ),
//             //   ),
//             // ),

//             // Positioned(
//             //   left: 20,
//             //   bottom: 20,
//             //   child: FloatingActionButton(
//             //     heroTag: "switch_camera",
//             //     onPressed: switchCamera,
//             //     child: Icon(Icons.cameraswitch),
//             //   ),
//             // ),


//             // Positioned(
//             //   right: 20,
//             //   bottom: 20,
//             //   child: FloatingActionButton(
//             //     heroTag: "menu",
//             //     onPressed: openMenu,
//             //     child: Icon(Icons.more_vert),
//             //   ),
//             // ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'app_camera.dart';
import 'package:camera/camera.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const CameraApp());
}
