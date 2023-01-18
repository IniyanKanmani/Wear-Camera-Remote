import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wear_camera_remote/wear/constants/constants.dart';

class PhotoMode {
  bool isPhotoCapturing;
  bool isRecordingInProgress;
  VoidCallback onTap;
  VoidCallback settingsOnTap;
  VoidCallback changeToVideoMode;

  CollectionReference wearReference =
      FirebaseFirestore.instance.collection('wear_commands');

  PhotoMode({
    required this.isPhotoCapturing,
    required this.isRecordingInProgress,
    required this.onTap,
    required this.settingsOnTap,
    required this.changeToVideoMode,
  });

  Widget buildPhotoModeUI() {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 14,
                bottom: 114.0,
              ),
              child: GestureDetector(
                onTap: () {
                  settingsOnTap();
                },
                child: kSettingIconWidget(
                  icons: Icons.settings_outlined,
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: const [
            Padding(
              padding: EdgeInsets.only(
                left: 14.0,
                bottom: 46.0,
              ),
              child: CircleAvatar(
                backgroundColor: Colors.white24,
                radius: 20.0,
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                right: 14.0,
                bottom: 46.0,
              ),
              child: GestureDetector(
                onTap: () {
                  wearReference.add({'cameraMode': '1'});
                  changeToVideoMode();
                },
                child: kSettingIconWidget(
                  icons: Icons.videocam_outlined,
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(
            bottom: 10.0,
          ),
          child: GestureDetector(
            onLongPress: () {
              isRecordingInProgress = !isRecordingInProgress;
              wearReference.add({'recordVideo': '0'});
              changeToVideoMode();
              onTap();
            },
            onTap: () async {
              wearReference.add({'capturePhoto': '0'});
            },
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.white70,
                  radius: 25.0,
                ),
                CircleAvatar(
                  backgroundColor:
                      isPhotoCapturing ? Colors.transparent : Colors.white,
                  radius: 22.0,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  bool get getIsRecordingInProgress {
    return isRecordingInProgress;
  }
}
