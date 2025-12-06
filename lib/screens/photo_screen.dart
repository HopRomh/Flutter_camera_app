import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

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
  // comment
  String _userComment = '';
  // location
  double? _latitude;
  double? _longitude;
  // upload status
  bool _isUploading = false;
  String _uploadStatus = '';
  // preview overlay visibility
  bool _showPreviewOverlay = false;

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
    // ignore: unnecessary_null_comparison
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



  void _showCommentDialog() {
    final TextEditingController commentController = TextEditingController();
    final BuildContext parentContext = context;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          title: const Text('Добавить комментарий',
          style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            style: const TextStyle(color: Colors.white),
            controller: commentController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Напишите ваш комментарий здесь',
              hintStyle: TextStyle(color: Colors.white60),
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена', style: TextStyle(color: Colors.red),),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _userComment = commentController.text;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(parentContext).showSnackBar(
                  const SnackBar(
                    content: Text('Ваш последний комментарий будет привязан к следующему сделанному фото'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Сохранить', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _FlashLight(){
    if (_isFlash == false){
      controllerl.setFlashMode(FlashMode.torch);
      setState(() {
        _isFlash = true;
      });
    } else {
      controllerl.setFlashMode(FlashMode.off);
      setState(() {
        _isFlash = false;
      });
    }
  }
  
  Future<void> _capturePhoto() async {
    if (!controllerl.value.isInitialized || isCapturing) return;

    try {
      setState(() {
        isCapturing = true;
      });

      final XFile rawImage = await controllerl.takePicture();
      final File imageFile = File(rawImage.path);

      setState(() {
        _capturedImage = imageFile;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Фото сделано'),
          duration: Duration(seconds: 2),
        ),
      );
      await _getLocation();

      if (_latitude == null || _longitude == null) {
        return;
      }

      _showPhotoUploadDialog();
    } 
    catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при съёмке: $e'),
        ),
      );
      print('Error grap photo: $e');
    } 
    finally {
      if (mounted) {
        setState(() {
          isCapturing = false;
        });
      }
    }
  }

  Future<bool> _getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Пожалуйста, включите GPS/Location на устройстве'),
            duration: Duration(seconds: 4),
          ),
        );
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Разрешение на использование геолокации отклонено'),
            duration: Duration(seconds: 4),
          ),
        );
        return false;
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Доступ к геолокации отключён. Разрешите в настройках приложения.'),
            duration: Duration(seconds: 5),
          ),
        );
        return false;
      }

      Position position = await Geolocator.getCurrentPosition(
        forceAndroidLocationManager: true,
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });

      return true;
    } catch (e) {
      print('Error getting location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при получении координат: $e'),
          duration: const Duration(seconds: 4),
        ),
      );
      return false;
    }
  }

  Future<void> _uploadPhotoToServer() async {
    if (_capturedImage == null || _latitude == null || _longitude == null) {
      print('Missing upload data');
      return;
    }

    try {
      setState(() {
        _isUploading = true;
        _uploadStatus = 'Отправка';
      });
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://hopromhphoto.free.beeceptor.com/upload_photo/'),
      );

      request.fields['comment'] = _userComment;
      request.fields['latitude'] = _latitude.toString();
      request.fields['longitude'] = _longitude.toString();

      request.files.add(
        await http.MultipartFile.fromPath(
          'photo',
          _capturedImage!.path,
        ),
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        setState(() {
          _uploadStatus = 'Успешно отправлено!';
        });
      } else {
        setState(() {
          _uploadStatus = 'Ошибка: ${response.statusCode}';
        });
        print('Upload error code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _uploadStatus = 'Ошибка: $e';
      });
      print('Upload error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _showPhotoUploadDialog() {
    setState(() {
      _showPreviewOverlay = true;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      _uploadPhotoToServer();
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Stack(
            children: [
              
              Positioned.fill(
                top: 50, 
                bottom: 170,
                child: CameraPreview(controllerl),
              ),

         
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
                        icon: Icon(
                          _isFlash ? Icons.flash_on : Icons.flash_off,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          _FlashLight();
                        },
                      ),
                    ],
                  ),
                ),
              ),


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
                                      _showCommentDialog();
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
                                      _capturePhoto();
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
                                        child: isCapturing
                                            ? const Center(
                                                child: SizedBox(
                                                  height: 24,
                                                  width: 24,
                                                  child: CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeWidth: 2,
                                                  ),
                                                ),
                                              )
                                            : null,
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


            
            if (_showPreviewOverlay)
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 600),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Ваше фото', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () {
                                        setState(() {
                                          _showPreviewOverlay = false;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                if (_capturedImage != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      _capturedImage!,
                                      height: 220,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                const SizedBox(height: 12),
                                const Text('Комментарий:', style: TextStyle(fontWeight: FontWeight.bold)),
                                Text(_userComment.isEmpty ? '(нет комментария)' : _userComment),
                                const SizedBox(height: 8),
                                const Text('Координаты:', style: TextStyle(fontWeight: FontWeight.bold)),
                                Text('Широта: ${_latitude?.toStringAsFixed(6) ?? "N/A"}'),
                                Text('Долгота: ${_longitude?.toStringAsFixed(6) ?? "N/A"}'),
                                const SizedBox(height: 12),
                                if (_isUploading)
                                  Row(
                                    children: [
                                      const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(_uploadStatus),
                                    ],
                                  )
                                else
                                  Text(
                                    _uploadStatus,
                                    style: TextStyle(color: _uploadStatus.contains('Успешно') ? Colors.green : Colors.red),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              ],
            );
        },
      ),
    ),
  );
  }
}

