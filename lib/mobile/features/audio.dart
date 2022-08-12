import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

class Audio {
  bool isAudioEnabled;
  VoidCallback showAudioBarOnTap;

  Audio({
    required this.isAudioEnabled,
    required this.showAudioBarOnTap,
  });

  void selectAudioOnTap() {
    Vibration.cancel();
    Vibration.vibrate(duration: 25, amplitude: 100);
    isAudioEnabled = !isAudioEnabled;
    showAudioBarOnTap();
  }

  Widget selectAudioWidget() {
    return GestureDetector(
      onTap: () {
        // Vibration.cancel();
        // Vibration.vibrate(duration: 25, amplitude: 100);
        // isAudioEnabled = !isAudioEnabled;
        // showAudioBarOnTap();
        selectAudioOnTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 18.0,
          vertical: 10.0,
        ),
        child: SizedBox(
          height: 30.0,
          width: 30.0,
          child: Icon(
            isAudioEnabled ? Icons.volume_up_sharp : Icons.volume_off_sharp,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  bool get getIsAudioEnabled {
    return isAudioEnabled;
  }

  void callSelectAudioOnTap() {
    selectAudioOnTap();
  }
}
