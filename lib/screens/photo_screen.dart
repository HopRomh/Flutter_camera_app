import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';


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
    controllerl.initialize().then((_){
      if(!mounted){
        return;
      }
      setState(() {
        
      });
    });
  }

  @override
  void dispose() { 
    controllerl.dispose();
    super.dispose();
    
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Stack(
            children: [
              
              Positioned.fill(child: CameraPreview(controllerl)),
              
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
                        onPressed: () {
                          
                        },
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