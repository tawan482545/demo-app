import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _cameraController;
  late Interpreter _interpreter;
  late List<String> _labels;
  bool _isDetecting = false;
  String _result = "กำลังโหลด...";

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(
      cameras[0],
      ResolutionPreset.medium,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );
    await _cameraController.initialize();

    _interpreter = await Interpreter.fromAsset(
      'converted_tflite/model_unquant.tflite',
    );
    _labels = await rootBundle
        .loadString('assets/converted_tflite/labels.txt')
        .then((s) => s.split('\n'));

    if (!mounted) return;
    setState(() {});

    _cameraController.startImageStream((CameraImage image) async {
      if (_isDetecting) return;
      _isDetecting = true;

      try {
        final input = await _convertCameraImage(image);
        var inputShape = _interpreter.getInputTensor(0).shape;
        var outputShape = _interpreter.getOutputTensor(0).shape;

        var inputList = input.buffer.asFloat32List().reshape(inputShape);
        var output = List.filled(
          outputShape.reduce((a, b) => a * b),
          0.0,
        ).reshape(outputShape);

        _interpreter.run(inputList, output);

        final outputList = output[0] as List<double>;
        final maxIndex = outputList.indexWhere(
          (e) => e == outputList.reduce((a, b) => a > b ? a : b),
        );

        setState(() {
          _result = _labels[maxIndex];
        });
      } catch (e) {
        debugPrint("Error during inference: $e");
      }

      _isDetecting = false;
    });
  }

  Future<Float32List> _convertCameraImage(CameraImage image) async {
    final int width = image.width;
    final int height = image.height;
    final img.Image imageBuffer = img.Image(width, height);

    final plane = image.planes[0];
    final bytesPerRow = plane.bytesPerRow;
    final bytes = plane.bytes;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final pixel = bytes[y * bytesPerRow + x];
        imageBuffer.setPixel(x, y, img.getColor(pixel, pixel, pixel));
      }
    }

    final img.Image resizedImage = img.copyResize(
      imageBuffer,
      width: 224,
      height: 224,
    );
    final Float32List input = Float32List(224 * 224 * 3);
    int i = 0;

    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        final pixel = resizedImage.getPixel(x, y);
        input[i++] = ((pixel >> 16) & 0xFF) / 255.0;
        input[i++] = ((pixel >> 8) & 0xFF) / 255.0;
        input[i++] = (pixel & 0xFF) / 255.0;
      }
    }

    return input;
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _interpreter.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI กล้องตรวจจับ'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body:
          _cameraController.value.isInitialized
              ? Stack(
                children: [
                  CameraPreview(_cameraController),
                  Positioned(
                    bottom: 30,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _result,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              )
              : const Center(child: CircularProgressIndicator()),
    );
  }
}
