import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

class Audio {
  bool isAudioEnabled;
  VoidCallback showAudioBarOnTap;

  CollectionReference mobileReference =
      FirebaseFirestore.instance.collection('mobile_commands');

  Audio({
    required this.isAudioEnabled,
    required this.showAudioBarOnTap,
  });

  void selectAudioOnTap() {
    mobileReference.add({'audio': isAudioEnabled == true ? '0' : '1'});
    Vibration.cancel();
    Vibration.vibrate(duration: 25, amplitude: 100);
    isAudioEnabled = !isAudioEnabled;
    showAudioBarOnTap();
  }

  Widget selectAudioWidget() {
    return GestureDetector(
      onTap: () {
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
            isAudioEnabled
                ? Icons.volume_up_outlined
                : Icons.volume_off_outlined,
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
