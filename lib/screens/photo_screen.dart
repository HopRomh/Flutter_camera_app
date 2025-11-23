import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class PhotoScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  PhotoScreen(this.cameras);

  @override
  _PhotoScreenState createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> {
  late CameraController controllerl;
  bool isCapturing = false;
  // switch camera
  int _SelectCameraIndex = 0;
  bool _isFrontCamera = false;
  // flash
  bool _isFlash = false;
  //focuse camera
  Offset? _focusPoint;
  // zoom
  double _currentZoom = 1.0;
  File? _capturedImage;

  @override
  void initState() {
    super.initState();
    controllerl = CameraController(widget.cameras[0], ResolutionPreset.max);
    controllerl.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controllerl.dispose();
    super.dispose();
  }

  void _switchCamera() async {
    if (controllerl != null){
      await controllerl.dispose();
    }
  _SelectCameraIndex = (_SelectCameraIndex + 1)% widget.cameras.length;

  _initCamerars(_SelectCameraIndex);
  }

  Future<void> _initCamerars(int cameraIndex) async {
    controllerl = CameraController(widget.cameras[cameraIndex], ResolutionPreset.max);
    try {
      await controllerl.initialize();
      setState(() {
        if (cameraIndex == 0){
          _isFrontCamera = false;

        }
        else{
          _isFrontCamera = true;
        }
      });

    }catch (e) {
      print("Error: ${e}");
    }
    if (mounted){
      setState(() {
        
      });
    }
  }



  // void photoscupter() async{
  //   if(controllerl.value.isInitialized){
  //     return;

  //   }

    
  // }



  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Stack(
            children: [
              // Camera preview на весь экран
              Positioned.fill(
                top: 50, // чтобы сверху была панель
                bottom: 170, // чтобы снизу была панель
                child: CameraPreview(controllerl),
              ),

              // Верхняя панель
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 50,
                  color: Color.fromRGBO(0, 0, 0, 0.5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(Icons.flash_off, color: Colors.white),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ),

 // Нижняя панель
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: 170,
                  color: Color.fromRGBO(0, 0, 0, 0.4),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Text(
                          "Camera",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      // _commeentButton();
                                    },
                                    child: Icon(
                                      Icons.whatshot_sharp,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                ),

                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      // photoscupter();
                                    },
                                    child: Center(
                                      child: Container(
                                        height: 70,
                                        width: 70,
                                        decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            50,
                                          ),
                                          border: Border.all(
                                            width: 4,
                                            color: Colors.white,
                                            style: BorderStyle.solid,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                  
                                ),

                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      _switchCamera();
                                    },
                                    child: Icon(
                                      Icons.cameraswitch_outlined,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                ),
                              ],
                            )


                            
                          ],
                        ),
                      ),
                      
                    ],
                  ),
                ),
              ),


            ],
          );
        },
      ),
    );
  }
}

