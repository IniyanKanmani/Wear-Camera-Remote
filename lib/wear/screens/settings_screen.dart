import 'package:flutter/material.dart';
import 'package:wear/wear.dart';
import 'package:wear_camera_remote/wear/constants/constants.dart';
import 'package:wear_camera_remote/wear/features/audio_screen.dart';
import 'package:wear_camera_remote/wear/features/flash_screen.dart';
import 'package:wear_camera_remote/wear/features/preview_ratio_screen.dart';
import 'package:wear_camera_remote/wear/features/resolution_screen.dart';
import 'package:wear_camera_remote/wear/features/timer_screen.dart';
import 'package:wear_camera_remote/wear/features/voice_control_screen.dart';
import 'package:wear_camera_remote/wear/screens/camera_remote_screen.dart';
import 'package:wear_camera_remote/wear/voice/voice_control.dart';

class SettingsScreen extends StatefulWidget {
  CameraMode currentCameraMode;
  bool isRearCamera;
  int currentFlash;
  int currentTimer;
  double currentPreviewRatio;
  int currentResolution;
  bool isAudioEnabled;
  bool isVoiceControlEnabled;
  VoiceControl voice;

  SettingsScreen({
    required this.currentCameraMode,
    required this.isRearCamera,
    required this.currentFlash,
    required this.currentTimer,
    required this.currentPreviewRatio,
    required this.currentResolution,
    required this.isAudioEnabled,
    required this.isVoiceControlEnabled,
    required this.voice,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Size? screenSize;
  WearShape? wearShape;

  @override
  void dispose() {
    widget.voice.cancelListening();
    widget.voice.cancelListeningTimer();
    super.dispose();
  }

  Widget settingsScreenWidgets() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(
          left: 20.0,
          right: 20.0,
          top: 25.0,
          bottom: 30.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            kSettingTextWidget(
              text: 'Settings',
            ),
            kSettingButtonWidget(
                icons: Icons.arrow_back_outlined,
                text: 'Back',
                onTap: () {
                  Navigator.pop(context);
                }),
            if (widget.isRearCamera)
              kSettingButtonWidget(
                icons: Icons.flash_on_outlined,
                text: 'Flash',
                onTap: () async {
                  dynamic chose = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FlashScreen(
                        currentFlash: widget.currentFlash,
                      ),
                    ),
                  );
                  chose ? Navigator.pop(context) : {};
                },
              ),
            kSettingButtonWidget(
              icons: Icons.timer_outlined,
              text: 'Timer',
              onTap: () async {
                dynamic chose = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CaptureTimerScreen(
                      currentTimer: widget.currentTimer,
                    ),
                  ),
                );
                chose ? Navigator.pop(context) : {};
              },
            ),
            kSettingButtonWidget(
              icons: Icons.screenshot_outlined,
              text: 'Preview Ratio',
              onTap: () async {
                dynamic chose = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PreviewRatioScreen(
                      currentPreviewRatio: widget.currentPreviewRatio,
                    ),
                  ),
                );
                chose ? Navigator.pop(context) : {};
              },
            ),
            kSettingButtonWidget(
              icons: Icons.photo_size_select_small_outlined,
              text: 'Resolution',
              onTap: () async {
                dynamic chose = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResolutionScreen(
                      currentResolution: widget.currentResolution,
                    ),
                  ),
                );
                chose ? Navigator.pop(context) : {};
              },
            ),
            if (widget.currentCameraMode == CameraMode.video)
              kSettingButtonWidget(
                icons: Icons.volume_up_outlined,
                text: 'Audio',
                onTap: () async {
                  dynamic chose = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AudioScreen(
                        isAudioEnabled: widget.isAudioEnabled,
                      ),
                    ),
                  );
                  chose ? Navigator.pop(context) : {};
                },
              ),
            kSettingButtonWidget(
              icons: Icons.record_voice_over_outlined,
              text: 'Voice Control',
              onTap: () async {
                dynamic chose = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VoiceControlScreen(
                      isVoiceControlEnabled: widget.isVoiceControlEnabled,
                      voice: widget.voice,
                    ),
                  ),
                );
                chose ? Navigator.pop(context) : {};
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        debugPrint('User Tried To close');
        return false;
      },
      child: WatchShape(
        builder: (BuildContext context, WearShape shape, Widget? child) {
          screenSize = MediaQuery.of(context).size;
          wearShape = shape;
          return Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: Opacity(
                    opacity: 0.25,
                    child: Container(
                      height: screenSize!.height,
                      width: screenSize!.width,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        shape: shape == WearShape.round
                            ? BoxShape.circle
                            : BoxShape.rectangle,
                      ),
                    ),
                  ),
                ),
                settingsScreenWidgets(),
              ],
            ),
          );
        },
      ),
    );
  }
}
