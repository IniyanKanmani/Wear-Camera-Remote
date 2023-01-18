import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// ignore: library_prefixes
import 'package:image/image.dart' as IMG;
import 'package:path_provider/path_provider.dart';
import 'package:vibration/vibration.dart';

class Capture {
  bool isTimerRunning = false;
  double currentPreviewRatio;
  Future<void> Function() beforeTakingPicture;
  Future<void> Function() takePicture;
  VoidCallback afterTakingPicture;
  VoidCallback setStateFunction;
  String? rawImagePath;
  String? capturedFilePath;

  CollectionReference mobileReference =
      FirebaseFirestore.instance.collection('mobile_commands');

  Capture({
    required this.currentPreviewRatio,
    required this.beforeTakingPicture,
    required this.takePicture,
    required this.afterTakingPicture,
    required this.setStateFunction,
  });

  Future<void> captureImageOnTap() async {
    mobileReference.add({'cameraMode': '0'});
    mobileReference.add({'capturePhoto': '0'});
    Vibration.cancel();
    Vibration.vibrate(duration: 25, amplitude: 250);
    Vibration.vibrate(duration: 50, amplitude: 1);
    Vibration.vibrate(duration: 25, amplitude: 250);
    isTimerRunning = true;
    setStateFunction();
    await beforeTakingPicture();
    await takePicture();
    isTimerRunning = false;
    await cropImage(rawImagePath!);
    File imageFile = File(rawImagePath!);
    int currentUnix = DateTime.now().millisecondsSinceEpoch;
    Directory? directory = await getExternalStorageDirectory();
    String fileFormat = imageFile.path.split('.').last;
    File copiedImage = await imageFile.copy(
      '${directory!.path}/$currentUnix.$fileFormat',
    );
    capturedFilePath = copiedImage.path;
    afterTakingPicture();
    mobileReference.add({'capturePhoto': '1'});
  }

  Future cropImage(String path) async {
    Uint8List bytes = await File(path).readAsBytes();
    IMG.Image? src = IMG.decodeImage(bytes);
    int offset = (src!.height - (src.width * currentPreviewRatio)) ~/ 2;
    IMG.Image destImage = IMG.copyCrop(src, 0, offset, src.width.toInt(),
        (src.width * currentPreviewRatio).toInt());
    await File(path).writeAsBytes(IMG.encodeJpg(destImage));
  }

  Widget captureButtonWidget() {
    return GestureDetector(
      onTap: () async {
        await captureImageOnTap();
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          const CircleAvatar(
            backgroundColor: Colors.white70,
            radius: 35,
          ),
          CircleAvatar(
            backgroundColor: isTimerRunning ? Colors.transparent : Colors.white,
            radius: 31.5,
          ),
        ],
      ),
    );
  }

  Widget videoCaptureButtonWidget() {
    return GestureDetector(
      onTap: () async {
        await captureImageOnTap();
      },
      child: const CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 30.0,
        child: Icon(
          Icons.photo_camera_outlined,
          color: Colors.white,
          size: 40.0,
        ),
      ),
    );
  }

  void setRawImagePath(String path) {
    rawImagePath = path;
  }

  String get getCapturedFilePath {
    return capturedFilePath!;
  }

  void callCaptureImageOnTap() async {
    await captureImageOnTap();
  }
}
