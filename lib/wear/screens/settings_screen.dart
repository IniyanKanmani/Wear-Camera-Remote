import 'package:flutter/material.dart';
import 'package:wear/wear.dart';
import 'package:wear_camera_remote/wear/constants/constants.dart';
import 'package:wear_camera_remote/wear/features_screen/audio_screen.dart';
import 'package:wear_camera_remote/wear/features_screen/flash_screen.dart';
import 'package:wear_camera_remote/wear/features_screen/preview_ratio_screen.dart';
import 'package:wear_camera_remote/wear/features_screen/resolution_screen.dart';
import 'package:wear_camera_remote/wear/features_screen/timer_screen.dart';
import 'package:wear_camera_remote/wear/features_screen/voice_control_screen.dart';
import 'package:wear_camera_remote/wear/screens/camera_remote_screen.dart';
import 'package:wear_camera_remote/wear/voice/voice_control.dart';

class SettingsScreen extends StatefulWidget {
  CameraMode currentCameraMode;
  VoiceControl voice;

  SettingsScreen(
      {Key? key, required this.currentCameraMode, required this.voice})
      : super(key: key);

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
            kSettingButtonWidget(
              icons: Icons.flash_on_outlined,
              text: 'Flash',
              onTap: () {
                // Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FlashScreen(),
                  ),
                );
              },
            ),
            kSettingButtonWidget(
              icons: Icons.timer_outlined,
              text: 'Timer',
              onTap: () {
                // Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CaptureTimerScreen(),
                  ),
                );
              },
            ),
            kSettingButtonWidget(
              icons: Icons.screenshot_outlined,
              text: 'Preview Ratio',
              onTap: () {
                // Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PreviewRatioScreen(),
                  ),
                );
              },
            ),
            kSettingButtonWidget(
              icons: Icons.photo_size_select_small_outlined,
              text: 'Resolution',
              onTap: () {
                // Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResolutionScreen(),
                  ),
                );
              },
            ),
            if (widget.currentCameraMode == CameraMode.video)
              kSettingButtonWidget(
                icons: Icons.volume_up_outlined,
                text: 'Audio',
                onTap: () {
                  // Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AudioScreen(),
                    ),
                  );
                },
              ),
            kSettingButtonWidget(
              icons: Icons.record_voice_over_outlined,
              text: 'Voice Control',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VoiceControlScreen(
                      voice: widget.voice,
                    ),
                  ),
                );
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
