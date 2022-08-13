import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wear_camera_remote/wear/constants/constants.dart';

class VideoMode {
  bool isRecordingInProgress;
  bool isRecordingPaused;
  CollectionReference mobileReference;
  CollectionReference wearReference;
  VoidCallback onTap;
  VoidCallback settingsOnTap;
  VoidCallback changeToCameraMode;

  VideoMode({
    required this.isRecordingInProgress,
    required this.isRecordingPaused,
    required this.mobileReference,
    required this.wearReference,
    required this.onTap,
    required this.settingsOnTap,
    required this.changeToCameraMode,
  });

  Widget buildVideoModeUI() {
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
                onTap: settingsOnTap,
                child: kSettingIconWidget(
                  icons: Icons.settings_outlined,
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 14.0,
                bottom: 46.0,
              ),
              child: isRecordingInProgress
                  ? GestureDetector(
                      onTap: () {
                        isRecordingPaused = !isRecordingPaused;
                        wearReference
                            .add({'pauseVideo': isRecordingPaused ? '0' : '1'});
                        onTap();
                      },
                      child: kSettingIconWidget(
                        icons: isRecordingPaused
                            ? Icons.play_arrow_outlined
                            : Icons.pause_outlined,
                      ),
                    )
                  : const CircleAvatar(
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
                  wearReference.add({'cameraMode': '0'});
                  changeToCameraMode();
                },
                child: kSettingIconWidget(
                  icons: Icons.camera_alt_outlined,
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
            onTap: () {
              isRecordingInProgress = !isRecordingInProgress;
              wearReference
                  .add({'recordVideo': isRecordingInProgress ? '0' : '1'});
              isRecordingPaused =
                  !isRecordingInProgress ? false : isRecordingPaused;
              onTap();
            },
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 25.0,
                ),
                isRecordingInProgress
                    ? Container(
                        width: 20.0,
                        height: 20.0,
                        color: Colors.red,
                      )
                    : const CircleAvatar(
                        backgroundColor: Colors.red,
                        radius: 23.0,
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

  bool get getIsRecordingPaused {
    return isRecordingPaused;
  }
}
