import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wear/wear.dart';
import 'package:wear_camera_remote/wear/constants/constants.dart';

class AudioScreen extends StatelessWidget {
  Size? screenSize;
  WearShape? wearShape;
  bool isAudioEnabled;

  CollectionReference wearReference =
      FirebaseFirestore.instance.collection('wear_commands');

  AudioScreen({
    required this.isAudioEnabled,
  });

  Widget audioScreenWidgets(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(
          left: 20.0,
          right: 20.0,
          top: 25.0,
          bottom: 30.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            kSettingTextWidget(
              text: 'Audio',
            ),
            kSettingButtonWidget(
              icons: Icons.arrow_back_outlined,
              text: 'Back',
              onTap: () {
                Navigator.pop(context, false);
              },
            ),
            kSettingButtonWidget(
              icons: Icons.volume_off_outlined,
              text: 'Off',
              onTap: () {
                wearReference.add({'audio': '0'});
                Navigator.pop(context, true);
              },
              current: !isAudioEnabled,
            ),
            kSettingButtonWidget(
              icons: Icons.volume_up_outlined,
              text: 'On',
              onTap: () {
                wearReference.add({'audio': '1'});
                Navigator.pop(context, true);
              },
              current: isAudioEnabled,
            ),
          ],
        ),
      ),
    );
  }

  void setIsAudioEnabled(bool isAudioEnabled) {
    this.isAudioEnabled = isAudioEnabled;
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
              audioScreenWidgets(context),
            ],
          ),
        );
      },
    );
  }
}
