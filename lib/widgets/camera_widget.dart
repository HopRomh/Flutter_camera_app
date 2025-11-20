
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraPreviewWidget extends StatelessWidget {
  final CameraController controller;

  const CameraPreviewWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) return Container();

    return SizedBox.expand(
      child: Transform.scale(
        scale: 1.3,
        child: CameraPreview(controller),
      ),
    );
  }
}



//     return SizedBox.expand(
//       child: CameraPreview(controller),
//     );
//   }
// }
// class CameraPreviewWidget extends StatefulWidget {
//   final CameraController controller;

//   const CameraPreviewWidget({super.key, required this.controller});

//   @override
//   State<CameraPreviewWidget> createState() => _CameraPreviewWidgetState();
// }

// class _CameraPreviewWidgetState extends State<CameraPreviewWidget> {
//   double _currentScale = 0.001;
//   double _baseScale = 0.001;

//   // ручные границы зума
//   final double _minZoom = 0.001;
//   final double _maxZoom = 0.001;

//   void _handleScaleStart(ScaleStartDetails details) {
//     _baseScale = _currentScale;
//   }

//   void _handleScaleUpdate(ScaleUpdateDetails details) async {
//     _currentScale = (_baseScale * details.scale).clamp(_minZoom, _maxZoom);
//     await widget.controller.setZoomLevel(_currentScale);
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!widget.controller.value.isInitialized) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     final size = widget.controller.value.previewSize!;
//     final deviceRatio = MediaQuery.of(context).size.width / MediaQuery.of(context).size.height;

//     return Transform.scale(
//       scale: size.aspectRatio / deviceRatio,
//       child: Center(
//         child: GestureDetector(
//           onScaleStart: _handleScaleStart,
//           onScaleUpdate: _handleScaleUpdate,
//           child: CameraPreview(widget.controller),
//         ),
//       ),
//     );
//   }
// }


 