import 'package:flutter/material.dart';
import 'package:wear/wear.dart';
import 'package:wear_camera_remote/wear/constants/constants.dart';
import 'package:wear_camera_remote/wear/voice/voice_control.dart';

class VoiceControlScreen extends StatelessWidget {
  Size? screenSize;
  WearShape? wearShape;
  bool isVoiceControlEnabled;
  VoiceControl voice;

  VoiceControlScreen({
    required this.isVoiceControlEnabled,
    required this.voice,
  });

  Widget voiceControlScreenWidgets(BuildContext context) {
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
              text: 'Voice Control',
            ),
            kSettingButtonWidget(
              icons: Icons.arrow_back_outlined,
              text: 'Back',
              onTap: () {
                Navigator.pop(context, false);
              },
            ),
            kSettingButtonWidget(
              icons: Icons.voice_over_off_outlined,
              text: 'Off',
              onTap: () {
                voice.stopListening();
                voice.cancelListeningTimer();
                Navigator.pop(context, true);
              },
              current: !isVoiceControlEnabled,
            ),
            kSettingButtonWidget(
              icons: Icons.record_voice_over_outlined,
              text: 'On',
              onTap: () {
                voice.initializeTimer();
                Navigator.pop(context, true);
              },
              current: isVoiceControlEnabled,
            ),
          ],
        ),
      ),
    );
  }

  void setIsVoiceControlEnabled(bool isVoiceControlEnabled) {
    this.isVoiceControlEnabled = isVoiceControlEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return WatchShape(
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
              voiceControlScreenWidgets(context),
            ],
          ),
        );
      },
    );
  }
}
