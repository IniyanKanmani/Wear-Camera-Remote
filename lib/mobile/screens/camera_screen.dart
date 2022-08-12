import 'dart:async';
import 'dart:io' show Platform;

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:wear_camera_remote/main.dart';
import 'package:wear_camera_remote/mobile/features/audio.dart';
import 'package:wear_camera_remote/mobile/features/capture.dart';
import 'package:wear_camera_remote/mobile/features/captured_image.dart';
import 'package:wear_camera_remote/mobile/features/flash.dart';
import 'package:wear_camera_remote/mobile/features/flip_camera.dart';
import 'package:wear_camera_remote/mobile/features/grid_lines.dart';
import 'package:wear_camera_remote/mobile/features/preview_ratio.dart';
import 'package:wear_camera_remote/mobile/features/record.dart';
import 'package:wear_camera_remote/mobile/features/resolution.dart';
import 'package:wear_camera_remote/mobile/features/timer.dart';
import 'package:wear_camera_remote/mobile/features/top_bar.dart';
import 'package:wear_camera_remote/mobile/features/zoom.dart';
import 'package:wear_camera_remote/mobile/screens/photo_mode.dart';
import 'package:wear_camera_remote/mobile/screens/video_mode.dart';

enum CameraMode {
  photo,
  video,
}

class CameraScreen extends StatefulWidget {
  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  bool isRearCamera = true;
  bool isCameraInitialized = false;

  bool isRecordingInProgress = false;
  bool isRecordingPaused = false;
  bool isAudioEnabled = true;

  bool showTopBar = true;
  bool showFlashModeBar = false;
  bool showCaptureTimerBar = false;
  bool showPreviewRatioBar = false;
  bool showResolutionPresetBar = false;
  bool showZoomLevelBar = false;

  double minAvailableZoom = 1.0;
  double currentZoomLevel = 1.0;
  double maxAvailableZoom = 1.0;

  double? screenWidth;
  double? previewHeight;
  double? previewWidth;

  double currentPreviewRatio = 4 / 3;

  String capturedFilePath = '';

  int currentCaptureTime = 0;

  CameraMode? currentCameraMode;

  CameraController? controller;

  bool rearMaxResFound = false;
  bool frontMaxResFound = false;
  ResolutionPreset currentRearResolutionPreset = ResolutionPreset.max;
  ResolutionPreset currentFrontResolutionPreset = ResolutionPreset.max;
  final List<ResolutionPreset> rearResolutionPresets = [];
  final List<ResolutionPreset> frontResolutionPresets = [];

  XFile? capturedImageXFile;
  XFile? recordedVideoXFile;

  FlashMode? currentFlashMode;

  Resolution? resolution;
  Zoom? zoom;
  Flash? flash;
  GridLines? gridLines;
  Capture? capture;
  CaptureTimer? captureTimer;
  PreviewRatio? previewRatio;
  FlipCamera? flipCamera;
  CapturedImage? capturedImage;
  TopBar? topBar;
  Record? record;
  Audio? audio;

  PhotoMode? photoMode;
  VideoMode? videoMode;

  Map<String, dynamic>? previousPhotoModeSettings;
  Map<String, dynamic>? previousVideoModeSettings;

  CollectionReference mobileReference =
      FirebaseFirestore.instance.collection('mobile_commands');
  CollectionReference wearReference =
      FirebaseFirestore.instance.collection('wear_commands');

  DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  @override
  void initState() {
    super.initState();
    initializeListeners();
    debugPrint('OSVERSION:${Platform.version}');
    onNewCameraSelected(cameras[isRearCamera ? 0 : 1]);
    currentCameraMode = CameraMode.photo;
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void initializeListeners() {
    wearReference.snapshots().listen((QuerySnapshot snapshot) async {
      if (snapshot.size != 0) {
        for (DocumentChange element in snapshot.docChanges) {
          List<String> data = element.doc.data().toString().split(': ');
          String key = data[0].substring(1);
          dynamic value = data[1].substring(0, data[1].length - 1);
          await executeCommands(key, value);
          debugPrint('COMMAND: $key $value');
          wearReference.doc(element.doc.id).delete();
        }
      }
    });
  }

  Future<void> executeCommands(String key, dynamic value) async {
    if (key == 'capturePhoto') {
      currentCameraMode = CameraMode.photo;
      capture!.callCaptureImageOnTap();
      setState(() {});
    } else if (key == 'recordVideo') {
      currentCameraMode = CameraMode.video;
      value == '0'
          ? await record!.callRecordOnTap()
          : await record!.callStopOnTap();
      setState(() {});
    } else if (key == 'cameraMode') {
      Vibration.cancel();
      Vibration.vibrate(duration: 25, amplitude: 150);
      Vibration.vibrate(duration: 25, amplitude: 1);
      Vibration.vibrate(duration: 25, amplitude: 150);
      currentCameraMode = value == '0' ? CameraMode.photo : CameraMode.video;
      setState(() {});
    } else if (key == 'flipCamera') {
      await flipCamera!.callSwitchCameraOnTap();
    } else if (key == 'pauseVideo') {
      value == '0'
          ? await record!.callPauseOnTap()
          : await record!.callResumeOnTap();
      setState(() {});
    } else if (key == 'flash') {
      flash!.callSelectFlashOnTap(int.parse(value));
    } else if (key == 'timer') {
      captureTimer!.callSelectTimerOnTap(int.parse(value));
    } else if (key == 'previewRatio') {
      previewRatio!.callSelectPreviewRatioOnTap(double.parse(value));
    } else if (key == 'resolution') {
      resolution!.callSelectResolutionOnTap(int.parse(value));
    } else if (key == 'audio') {
      audio!.callSelectAudioOnTap();
    }
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    final CameraController? previousCameraController = controller;

    // Dispose the previous controller
    await previousCameraController?.dispose();

    // Instantiating the camera controller
    final CameraController cameraController = CameraController(
      cameraDescription,
      isRearCamera ? currentRearResolutionPreset : currentFrontResolutionPreset,
      imageFormatGroup: ImageFormatGroup.jpeg,
      enableAudio: isAudioEnabled,
    );

    // Replace with the new controller
    if (mounted) {
      controller = cameraController;
      setState(() {});
    }

    // Update UI if controller updated
    controller!.addListener(() {
      if (mounted) setState(() {});
    });

    // Initialize controller
    try {
      await controller!.initialize();
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }

    await createEssentialFeatures();

    // Update _isCameraInitialized
    if (mounted) {
      isCameraInitialized = controller!.value.isInitialized;
      setState(() {});
    }
    Map deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
    // debugPrint(deviceData.toString());
    deviceData.forEach((key, value) {
      debugPrint('key: $key    value: $value');
    });
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'androidId': build.androidId,
      'systemFeatures': build.systemFeatures,
    };
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      // Free up memory when camera not active
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // Reinitialize the camera with same properties
      onNewCameraSelected(cameraController.description);
    }
  }

  Future<void> createEssentialFeatures() async {
    previewWidth = controller!.value.previewSize!.height;
    previewHeight = controller!.value.previewSize!.width;
    screenWidth = MediaQuery.of(context).size.width;

    minAvailableZoom = await controller!.getMinZoomLevel();
    maxAvailableZoom = await controller!.getMaxZoomLevel();
    currentZoomLevel = minAvailableZoom;

    await controller!.setFlashMode(FlashMode.off);

    topBar = TopBar(
      showTopBar: showTopBar,
      beforeTimerFunction: () {
        showZoomLevelBar = false;
        zoom!.setShowZoomLevelBar(showZoomLevelBar);
      },
      afterTimerFunction: () {
        showTopBar = topBar!.getShowTopBar;
        setState(() {});
      },
      resetTimerFunction: () {
        showResolutionPresetBar = false;
        showFlashModeBar = false;
        showCaptureTimerBar = false;
        showPreviewRatioBar = false;
      },
    );

    if (isRearCamera) {
      currentFlashMode =
          flash == null ? controller!.value.flashMode : currentFlashMode;
      controller!.setFlashMode(currentFlashMode!);

      flash = Flash(
        currentFlashMode: currentFlashMode!,
        showFlashBarOnTap: () {
          showFlashModeBar = true;
          topBar!.showTopBarTimer();
          showTopBar = topBar!.getShowTopBar;
          setState(() {});
        },
        setFlashOnTap: () {
          currentFlashMode = flash!.getCurrentFlashMode;
          topBar!.topBarResetTimer();
          showTopBar = topBar!.getShowTopBar;
          controller!.setFlashMode(currentFlashMode!);
          setState(() {});
        },
      );
    }

    captureTimer = CaptureTimer(
      time: currentCaptureTime,
      showTimerBarOnTap: () {
        showCaptureTimerBar = true;
        topBar!.showTopBarTimer();
        showTopBar = topBar!.getShowTopBar;
        setState(() {});
      },
      setTimerOnTap: () {
        currentCaptureTime = captureTimer!.getCurrentCaptureTimer;
        topBar!.topBarResetTimer();
        showTopBar = topBar!.getShowTopBar;
        setState(() {});
      },
    );

    previewRatio = PreviewRatio(
      currentPreviewRatio: currentPreviewRatio,
      showPreviewRatioBarOnTap: () {
        showPreviewRatioBar = true;
        topBar!.showTopBarTimer();
        showTopBar = topBar!.getShowTopBar;
        setState(() {});
      },
      setPreviewRatioOnTap: () {
        double previousPreviewRatio = currentPreviewRatio;
        currentPreviewRatio = previewRatio!.getCurrentPreviewRatio;
        topBar!.topBarResetTimer();
        showTopBar = topBar!.getShowTopBar;
        if (currentPreviewRatio != previousPreviewRatio) {
          isCameraInitialized = false;
          onNewCameraSelected(
            controller!.description,
          );
        } else {
          setState(() {});
        }
      },
    );

    resolution = Resolution(
      isRearCamera: isRearCamera,
      pixels: controller!.value.previewSize!.height,
      currentResolutionPreset: isRearCamera
          ? currentRearResolutionPreset
          : currentFrontResolutionPreset,
      resolutionPresets:
          isRearCamera ? rearResolutionPresets : frontResolutionPresets,
      showResolutionBarOnTap: () {
        showResolutionPresetBar = true;
        topBar!.showTopBarTimer();
        showTopBar = topBar!.getShowTopBar;
        setState(() {});
      },
      setResolutionOnTap: () {
        topBar!.topBarResetTimer();
        showTopBar = topBar!.getShowTopBar;
        if (resolution!.getIsRearCamera) {
          if (!rearMaxResFound) {
            rearResolutionPresets.addAll(resolution!.getResolutionPresets);
            rearMaxResFound = true;
          }
          if (isRearCamera == resolution!.getIsRearCamera) {
            if (resolution!.getResolutionValues[currentRearResolutionPreset] ==
                resolution!.getResolutionValues[
                    resolution!.getCurrentResolutionPreset]) {
              setState(() {});
              return;
            }
          }
          currentRearResolutionPreset = resolution!.getCurrentResolutionPreset;
        } else {
          if (!frontMaxResFound) {
            frontResolutionPresets.addAll(resolution!.getResolutionPresets);
            frontMaxResFound = true;
          }
          if (isRearCamera == resolution!.getIsRearCamera) {
            if (resolution!.getResolutionValues[currentFrontResolutionPreset] ==
                resolution!.getResolutionValues[
                    resolution!.getCurrentResolutionPreset]) {
              setState(() {});
              return;
            }
          }
          currentFrontResolutionPreset = resolution!.getCurrentResolutionPreset;
        }
        isCameraInitialized = false;

        onNewCameraSelected(controller!.description);
      },
    );
    await resolution!.setResolutionValues();

    audio = Audio(
      isAudioEnabled: isAudioEnabled,
      showAudioBarOnTap: () {
        isAudioEnabled = audio!.getIsAudioEnabled;
        isCameraInitialized = false;
        onNewCameraSelected(controller!.description);
      },
    );

    gridLines = GridLines(
      height: screenWidth! * currentPreviewRatio,
      width: screenWidth!,
    );

    zoom = Zoom(
      showZoomLevelBar: showZoomLevelBar,
      minAvailableZoom: minAvailableZoom,
      currentZoomLevel: currentZoomLevel,
      maxAvailableZoom: maxAvailableZoom,
      zoomTimerFunction: () {
        setState(() {});
      },
      setZoomLevelOnChanged: () async {
        await controller!.setZoomLevel(zoom!.getCurrentZoomLevel);
        setState(() {});
      },
      showZoomSliderOnTap: () {
        setState(() {});
      },
    );

    capturedImage = CapturedImage(
      capturedFilePath: capturedFilePath,
      currentPreviewRatio: currentPreviewRatio,
      capturedImageOnTap: () {},
    );

    capture = Capture(
      currentPreviewRatio: currentPreviewRatio,
      beforeTakingPicture: () async {
        await captureTimer!.setTimer();
      },
      setStateFunction: () {
        setState(() {});
      },
      takePicture: () async {
        if (controller!.value.isTakingPicture) {
          return;
        }
        try {
          capturedImageXFile = await controller!.takePicture();
          capture!.setRawImagePath(capturedImageXFile!.path);
        } catch (e) {
          debugPrint('Error occurred while taking picture: $e');
        }
        return;
      },
      afterTakingPicture: () {
        capturedImage!.setCapturedFilePath(capture!.getCapturedFilePath);
        setState(() {});
      },
    );

    record = Record(
      isRecordingInProgress: isRecordingInProgress,
      isRecordingPaused: isRecordingPaused,
      currentPreviewRatio: currentPreviewRatio,
      beforeRecordingVideo: () async {
        await captureTimer!.setTimer();
      },
      setStateFunction: () {
        setState(() {});
      },
      recordVideoOnTap: () async {
        if (controller!.value.isRecordingVideo) {
          return;
        }
        try {
          await controller!.startVideoRecording();
          isRecordingInProgress = record!.getIsRecodingInProgress;
          isRecordingPaused = record!.getIsRecodingPaused;
          setState(() {});
        } catch (e) {
          debugPrint('Error: Recording video $e');
        }
      },
      stopVideoOnTap: () async {
        if (!controller!.value.isRecordingVideo) {
          return;
        }
        try {
          recordedVideoXFile = await controller!.stopVideoRecording();
          isRecordingInProgress = record!.getIsRecodingInProgress;
          isRecordingPaused = record!.getIsRecodingPaused;
          setState(() {});
        } catch (e) {
          debugPrint('Error: Stopping Video $e');
        }
      },
      pauseVideoOnTap: () async {
        if (!controller!.value.isRecordingVideo &&
            !controller!.value.isRecordingPaused) {
          return;
        }
        try {
          await controller!.pauseVideoRecording();
          isRecordingInProgress = record!.getIsRecodingInProgress;
          isRecordingPaused = record!.getIsRecodingPaused;
          setState(() {});
        } on CameraException catch (e) {
          debugPrint('Error: Pausing Video $e');
        }
      },
      resumeVideoOnTap: () async {
        if (!controller!.value.isRecordingVideo &&
            controller!.value.isRecordingPaused) {
          return;
        }
        try {
          await controller!.resumeVideoRecording();
          isRecordingInProgress = record!.getIsRecodingInProgress;
          isRecordingPaused = record!.getIsRecodingPaused;
          setState(() {});
        } on CameraException catch (e) {
          debugPrint('Error: Resume Video $e');
        }
      },
    );

    flipCamera = FlipCamera(
      flipCameraOnTap: () {
        isCameraInitialized = false;
        showTopBar = true;
        topBar!.setShowTopBar(showTopBar);
        showFlashModeBar = false;
        showCaptureTimerBar = false;
        showPreviewRatioBar = false;
        showResolutionPresetBar = false;
        showZoomLevelBar = false;
        topBar!.topBarResetTimer();
        showTopBar = topBar!.getShowTopBar;
        zoom!.setShowZoomLevelBar(showZoomLevelBar);
        zoom!.zoomResetTimer();
        onNewCameraSelected(cameras[!isRearCamera ? 0 : 1]);
        isRearCamera = !isRearCamera;
      },
    );
  }

  void createPhotoMode() {
    photoMode = PhotoMode(
        isRearCamera: isRearCamera,
        isCameraInitialized: isCameraInitialized,
        showTopBar: showTopBar,
        showFlashModeBar: showFlashModeBar,
        showCaptureTimerBar: showCaptureTimerBar,
        showPreviewRatioBar: showPreviewRatioBar,
        showResolutionPresetBar: showResolutionPresetBar,
        showZoomLevelBar: showZoomLevelBar,
        currentPreviewRatio: currentPreviewRatio,
        screenWidth: screenWidth!,
        previewWidth: previewWidth!,
        previewHeight: previewHeight!,
        controller: controller!,
        resolution: resolution!,
        zoom: zoom!,
        flash: flash!,
        gridLines: gridLines!,
        capture: capture!,
        captureTimer: captureTimer!,
        previewRatio: previewRatio!,
        flipCamera: flipCamera!,
        capturedImage: capturedImage!,
        topBar: topBar!,
        changeToVideoMode: () {
          Vibration.cancel();
          Vibration.vibrate(duration: 25, amplitude: 150);
          Vibration.vibrate(duration: 25, amplitude: 1);
          Vibration.vibrate(duration: 25, amplitude: 150);
          currentCameraMode = CameraMode.video;
          setState(() {});
        });
  }

  void createVideoMode() {
    videoMode = VideoMode(
      isRearCamera: isRearCamera,
      isCameraInitialized: isCameraInitialized,
      isRecordingInProgress: isRecordingInProgress,
      isRecordingPaused: isRecordingPaused,
      showTopBar: showTopBar,
      showFlashModeBar: showFlashModeBar,
      showCaptureTimerBar: showCaptureTimerBar,
      showPreviewRatioBar: showPreviewRatioBar,
      showResolutionPresetBar: showResolutionPresetBar,
      showZoomLevelBar: showZoomLevelBar,
      currentPreviewRatio: currentPreviewRatio,
      screenWidth: screenWidth!,
      previewWidth: previewWidth!,
      previewHeight: previewHeight!,
      controller: controller!,
      resolution: resolution!,
      zoom: zoom!,
      flash: flash!,
      gridLines: gridLines!,
      capture: capture!,
      captureTimer: captureTimer!,
      previewRatio: previewRatio!,
      flipCamera: flipCamera!,
      capturedImage: capturedImage!,
      topBar: topBar!,
      record: record!,
      audio: audio!,
      changeToPhotoMode: () {
        Vibration.cancel();
        Vibration.vibrate(duration: 25, amplitude: 150);
        Vibration.vibrate(duration: 25, amplitude: 1);
        Vibration.vibrate(duration: 25, amplitude: 150);
        currentCameraMode = CameraMode.photo;
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isCameraInitialized) {
      currentCameraMode == CameraMode.photo
          ? createPhotoMode()
          : createVideoMode();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: isCameraInitialized
          ? currentCameraMode == CameraMode.photo
              ? photoMode!.buildPhotoModeUI()
              : videoMode!.buildVideoModeUI()
          : Container(),
    );
  }
}
