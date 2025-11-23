// import 'dart:io';
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart';
// import 'package:geolocator/geolocator.dart';

// class PhotoScreen extends StatefulWidget {
//   final List<CameraDescription> cameras;
//   PhotoScreen(this.cameras);

//   @override
//   _PhotoScreenState createState() => _PhotoScreenState();
// }

// class _PhotoScreenState extends State<PhotoScreen> {
//   late CameraController controllerl;
//   bool isCapturing = false;

//   int _SelectCameraIndex = 0;
//   bool _isFrontCamera = false;
//   File? _capturedImage;

//   TextEditingController _commentController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _initCamera(_SelectCameraIndex);
//   }

//   Future<void> _initCamera(int cameraIndex) async {
//     controllerl = CameraController(widget.cameras[cameraIndex], ResolutionPreset.max);
//     try {
//       await controllerl.initialize();
//       setState(() {
//         _isFrontCamera = cameraIndex != 0;
//       });
//     } catch (e) {
//       print("Error initializing camera: $e");
//     }
//   }

//   @override
//   void dispose() {
//     controllerl.dispose();
//     _commentController.dispose();
//     super.dispose();
//   }

//   void _switchCamera() async {
//     if (controllerl.value.isInitialized) {
//       await controllerl.dispose();
//     }
//     _SelectCameraIndex = (_SelectCameraIndex + 1) % widget.cameras.length;
//     _initCamera(_SelectCameraIndex);
//   }

//   Future<Position> _getCurrentLocation() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       return Future.error('Location services are disabled.');
//     }
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         return Future.error('Location permissions are denied');
//       }
//     }
//     if (permission == LocationPermission.deniedForever) {
//       return Future.error('Location permissions are permanently denied.');
//     }
//     return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//   }

//   void photoscupter() async {
//     if (!controllerl.value.isInitialized || isCapturing) return;

//     setState(() => isCapturing = true);
//     try {
//       final XFile imageFile = await controllerl.takePicture();
//       _capturedImage = File(imageFile.path);

//       Position position = await _getCurrentLocation();
//       String comment = _commentController.text;

//       await _uploadPhoto(comment, position.latitude, position.longitude, _capturedImage!);
//     } catch (e) {
//       print("Error capturing photo: $e");
//     } finally {
//       setState(() => isCapturing = false);
//     }
//   }

//   Future<void> _uploadPhoto(String comment, double lat, double lon, File photo) async {
//     var uri = Uri.parse("https://flutter-sandbox.free.beeceptor.com/upload_photo/");
//     var request = MultipartRequest('POST', uri);

//     request.fields['comment'] = comment;
//     request.fields['latitude'] = lat.toString();
//     request.fields['longitude'] = lon.toString();
//     request.files.add(await MultipartFile.fromPath('photo', photo.path));

//     try {
//       var response = await request.send();
//       if (response.statusCode == 200) {
//         print("Photo uploaded successfully");
//       } else {
//         print("Upload failed: ${response.statusCode}");
//       }
//     } catch (e) {
//       print("Upload error: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: Colors.black,
//         body: LayoutBuilder(
//           builder: (BuildContext context, BoxConstraints constraints) {
//             return Stack(
//               children: [
//                 // Camera preview
//                 Positioned.fill(
//                   top: 50,
//                   bottom: 170,
//                   child: controllerl.value.isInitialized
//                       ? CameraPreview(controllerl)
//                       : Center(child: CircularProgressIndicator()),
//                 ),
//                 // Верхняя панель
//                 Positioned(
//                   top: 0,
//                   left: 0,
//                   right: 0,
//                   child: Container(
//                     height: 50,
//                     color: Color.fromRGBO(0, 0, 0, 0.5),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: [
//                         IconButton(
//                           icon: Icon(Icons.flash_off, color: Colors.white),
//                           onPressed: () {},
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 // Нижняя панель
//                 Positioned(
//                   left: 0,
//                   right: 0,
//                   bottom: 0,
//                   child: Container(
//                     height: 170,
//                     color: Color.fromRGBO(0, 0, 0, 0.4),
//                     child: Column(
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.only(top: 12),
//                           child: Text(
//                             "Camera",
//                             style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                         SizedBox(height: 12),
//                         Expanded(
//                           child: Row(
//                             children: [
//                               // Поле комментария слева
//                               Expanded(
//                                 flex: 3,
//                                 child: Padding(
//                                   padding: const EdgeInsets.only(left: 16.0),
//                                   child: Material(
//                                     color: Colors.transparent,
//                                     child: TextField(
//                                       controller: _commentController,
//                                       style: TextStyle(color: Colors.white),
//                                       decoration: InputDecoration(
//                                         hintText: "Комментарий",
//                                         hintStyle: TextStyle(color: Colors.white70),
//                                         filled: true,
//                                         fillColor: Colors.black26,
//                                         border: OutlineInputBorder(
//                                           borderRadius: BorderRadius.circular(8),
//                                           borderSide: BorderSide.none,
//                                         ),
//                                         contentPadding: EdgeInsets.symmetric(
//                                             horizontal: 12, vertical: 8),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               // Кнопка камеры по центру
//                               Expanded(
//                                 flex: 1,
//                                 child: GestureDetector(
//                                   onTap: photoscupter,
//                                   child: Center(
//                                     child: Container(
//                                       height: 70,
//                                       width: 70,
//                                       decoration: BoxDecoration(
//                                         color: Colors.transparent,
//                                         borderRadius: BorderRadius.circular(50),
//                                         border: Border.all(
//                                             width: 4, color: Colors.white),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               // Переключение камеры справа
//                               Expanded(
//                                 flex: 1,
//                                 child: GestureDetector(
//                                   onTap: _switchCamera,
//                                   child: Icon(
//                                     Icons.cameraswitch_outlined,
//                                     color: Colors.white,
//                                     size: 40,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 )
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
