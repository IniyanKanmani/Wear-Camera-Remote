import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

class FlipCamera {
  VoidCallback flipCameraOnTap;

  FlipCamera({
    required this.flipCameraOnTap,
  });

  Future<void> switchCameraOnTap() async {
    Vibration.cancel();
    Vibration.vibrate(duration: 25, amplitude: 200);
    Vibration.vibrate(duration: 25, amplitude: 1);
    Vibration.vibrate(duration: 25, amplitude: 200);
    flipCameraOnTap();
  }

  Widget flipCameraWidget() {
    return GestureDetector(
      onTap: () async {
        await switchCameraOnTap();
      },
      child: const CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 30.0,
        child: Icon(
          Icons.cameraswitch_outlined,
          color: Colors.white,
          size: 40.0,
        ),
      ),
    );
  }

  Future<void> callSwitchCameraOnTap() async {
    await switchCameraOnTap();
  }
}
