import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wear/wear.dart';
import 'package:wear_camera_remote/wear/screens/photo_mode.dart';
import 'package:wear_camera_remote/wear/screens/settings_screen.dart';
import 'package:wear_camera_remote/wear/screens/video_mode.dart';
import 'package:wear_camera_remote/wear/voice/voice_control.dart';

enum CameraMode {
  photo,
  video,
}

class CameraRemoteScreen extends StatefulWidget {
  @override
  State<CameraRemoteScreen> createState() => _CameraRemoteScreenState();
}

class _CameraRemoteScreenState extends State<CameraRemoteScreen> {
  bool isRecordingInProgress = false;
  bool isRecordingPaused = false;

  CameraMode currentCameraMode = CameraMode.photo;

  CollectionReference mobileReference =
      FirebaseFirestore.instance.collection('mobile_commands');
  CollectionReference wearReference =
      FirebaseFirestore.instance.collection('wear_commands');

  static const openAppChannel = MethodChannel('iniyan.com/appOpen');

  VoiceControl? voice;
  PhotoMode? photoMode;
  VideoMode? videoMode;

  @override
  void initState() {
    super.initState();
    initializeListeners();
    voice = VoiceControl(setStateCallBack: () {
      setState(() {});
    });
    voice!.initializeSpeechToText();
  }

  @override
  void dispose() {
    voice!.cancelListening();
    voice!.cancelListeningTimer();
    super.dispose();
  }

  void initializeListeners() {
    mobileReference.snapshots().listen((QuerySnapshot snapshot) {
      if (snapshot.size != 0) {
        for (var element in snapshot.docChanges) {
          List<String> data = element.doc.data().toString().split(': ');
          String key = data[0].substring(1);
          dynamic value = data[1].substring(0, data[1].length - 1);
          debugPrint('COMMAND: $key $value');
          mobileReference.doc(element.doc.id).delete();
        }
      }
    });
  }

  void createPhotoMode() {
    photoMode = PhotoMode(
      isRecordingInProgress: isRecordingInProgress,
      mobileReference: mobileReference,
      wearReference: wearReference,
      onTap: () {
        isRecordingInProgress = photoMode!.getIsRecordingInProgress;
        setState(() {});
      },
      settingsOnTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SettingsScreen(
              voice: voice!,
              currentCameraMode: currentCameraMode,
            ),
          ),
        );
      },
      changeToVideoMode: () {
        currentCameraMode = CameraMode.video;
        setState(() {});
      },
    );
  }

  void createVideoMode() {
    videoMode = VideoMode(
      isRecordingInProgress: isRecordingInProgress,
      isRecordingPaused: isRecordingPaused,
      mobileReference: mobileReference,
      wearReference: wearReference,
      onTap: () {
        isRecordingInProgress = videoMode!.getIsRecordingInProgress;
        isRecordingPaused = videoMode!.getIsRecordingPaused;
        setState(() {});
      },
      settingsOnTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SettingsScreen(
              voice: voice!,
              currentCameraMode: currentCameraMode,
            ),
          ),
        );
      },
      changeToCameraMode: () {
        currentCameraMode = CameraMode.photo;
        setState(() {});
      },
    );
  }

  Future openAppOnPhone() async {
    await openAppChannel.invokeMethod('openAppOnPhone');
    debugPrint('Mobile App Should have opened');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    currentCameraMode == CameraMode.photo
        ? createPhotoMode()
        : createVideoMode();
    return WatchShape(
      builder: (BuildContext context, WearShape shape, Widget? child) {
        Size screenSize = MediaQuery.of(context).size;
        return Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: GestureDetector(
              onVerticalDragEnd: (DragEndDetails details) {
                double sensitivity = 10;
                if (details.primaryVelocity! > sensitivity ||
                    details.primaryVelocity! < -sensitivity) {
                  wearReference.add({'flipCamera': '0'});
                }
              },
              child: Container(
                height: screenSize.height,
                width: screenSize.width,
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: shape == WearShape.round
                      ? BoxShape.circle
                      : BoxShape.rectangle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(
                    5.0,
                  ),
                  child:
                      // Column(
                      //   children: [
                      //     Text(
                      //       'On Phone',
                      //       style: TextStyle(
                      //         color: Colors.white,
                      //       ),
                      //     ),
                      //     ElevatedButton(
                      //       onPressed: openAppOnPhone,
                      //       child: Text('Open App'),
                      //     )
                      //   ],
                      // )
                      currentCameraMode == CameraMode.photo
                          ? photoMode!.buildPhotoModeUI()
                          : videoMode!.buildVideoModeUI(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
