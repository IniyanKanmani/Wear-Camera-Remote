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
  bool isPhotoCapturing = false;
  bool isRecordingInProgress = false;
  bool isRecordingPaused = false;
  bool isRearCamera = true;
  bool isAudioEnabled = true;
  bool isVoiceControlEnabled = false;

  int currentFlash = 0;
  int currentTimer = 0;
  double currentPreviewRatio = 4 / 3;
  int currentResolution = 2;

  CameraMode currentCameraMode = CameraMode.photo;

  CollectionReference mobileReference =
      FirebaseFirestore.instance.collection('mobile_commands');
  CollectionReference wearReference =
      FirebaseFirestore.instance.collection('wear_commands');

  static const openAppChannel = MethodChannel('iniyan.com/appOpen');
  static const physicalButtonChannel =
      MethodChannel('iniyan.com/physicalButton');

  VoiceControl? voice;
  PhotoMode? photoMode;
  VideoMode? videoMode;

  @override
  void initState() {
    super.initState();
    initialize();
    debugPrint('Screen Initialised');
  }

  @override
  void dispose() {
    debugPrint('Screen Disposed');
    voice!.cancelListening();
    voice!.cancelListeningTimer();
    super.dispose();
  }

  void initialize() {
    voice = VoiceControl(
        isPhotoCapturing: isPhotoCapturing,
        isRecordingInProgress: isRecordingInProgress,
        isRecordingPaused: isRecordingPaused,
        isRearCamera: isRearCamera,
        isAudioEnabled: isAudioEnabled,
        currentFlash: currentFlash,
        currentTimer: currentTimer,
        currentPreviewRatio: currentPreviewRatio,
        currentResolution: currentResolution,
        currentCameraMode: currentCameraMode,
        setStateCallBack: () {
          setState(() {});
        });
    voice!.initializeSpeechToText();
    initializeListeners();
  }

  void initializeListeners() {
    mobileReference.snapshots().listen((QuerySnapshot snapshot) async {
      if (snapshot.size != 0) {
        for (var element in snapshot.docChanges) {
          List<String> data = element.doc.data().toString().split(': ');
          String key = data[0].substring(1);
          String value = data[1].substring(0, data[1].length - 1);
          await executeCommands(key, value);
          debugPrint('COMMAND: $key $value');
          mobileReference.doc(element.doc.id).delete();
        }
      }
    });
  }

  Future<void> executeCommands(String key, String value) async {
    if (key == 'cameraMode') {
      currentCameraMode = value == '0' ? CameraMode.photo : CameraMode.video;
    } else if (key == 'capturePhoto') {
      isPhotoCapturing = value == '0' ? true : false;
    } else if (key == 'recordVideo') {
      isRecordingInProgress = value == '0' ? true : false;
    } else if (key == 'pauseVideo') {
      isRecordingPaused = value == '0' ? true : false;
    } else if (key == 'flipCamera') {
      isRearCamera = value == '0' ? true : false;
    } else if (key == 'flash') {
      currentFlash = int.parse(value);
    } else if (key == 'timer') {
      currentTimer = int.parse(value);
    } else if (key == 'previewRatio') {
      currentPreviewRatio = double.parse(value);
    } else if (key == 'resolution') {
      currentResolution = int.parse(value);
    } else if (key == 'audio') {
      isAudioEnabled = value == '0' ? true : false;
    }
    voice!.updateVariables(
      isPhotoCapturing: isPhotoCapturing,
      isRecordingInProgress: isRecordingInProgress,
      isRecordingPaused: isRecordingPaused,
      isRearCamera: isRearCamera,
      isAudioEnabled: isAudioEnabled,
      currentFlash: currentFlash,
      currentTimer: currentTimer,
      currentPreviewRatio: currentPreviewRatio,
      currentResolution: currentResolution,
      currentCameraMode: currentCameraMode,
    );
    setState(() {});
  }

  void createPhotoMode() {
    photoMode = PhotoMode(
      isPhotoCapturing: isPhotoCapturing,
      isRecordingInProgress: isRecordingInProgress,
      onTap: () {
        isRecordingInProgress = photoMode!.getIsRecordingInProgress;
        setState(() {});
      },
      settingsOnTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SettingsScreen(
              currentCameraMode: currentCameraMode,
              isRearCamera: isRearCamera,
              currentFlash: currentFlash,
              currentTimer: currentTimer,
              currentPreviewRatio: currentPreviewRatio,
              currentResolution: currentResolution,
              isAudioEnabled: isAudioEnabled,
              isVoiceControlEnabled: isVoiceControlEnabled,
              voice: voice!,
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
      settingsOnTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SettingsScreen(
              currentCameraMode: currentCameraMode,
              isRearCamera: isRearCamera,
              currentFlash: currentFlash,
              currentTimer: currentTimer,
              currentPreviewRatio: currentPreviewRatio,
              currentResolution: currentResolution,
              isAudioEnabled: isAudioEnabled,
              isVoiceControlEnabled: isVoiceControlEnabled,
              voice: voice!,
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

  Future getWearablePhysicalButtons() async {
    await physicalButtonChannel.invokeMethod('getWearablePhysicalButtons');
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
                  wearReference.add({'flipCamera': isRearCamera ? '1' : '0'});
                  isRearCamera = !isRearCamera;
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
                    child: Column(
                      children: [
                        // Text(
                        //   'On Phone',
                        //   style: TextStyle(
                        //     color: Colors.white,
                        //   ),
                        // ),
                        ElevatedButton(
                          onPressed: getWearablePhysicalButtons,
                          child: Text('Physical Buttons'),
                        )
                      ],
                    )
                    // currentCameraMode == CameraMode.photo
                    //     ? photoMode!.buildPhotoModeUI()
                    //     : videoMode!.buildVideoModeUI(),
                    ),
              ),
            ),
          ),
        );
      },
    );
  }
}
