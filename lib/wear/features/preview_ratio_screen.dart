import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wear/wear.dart';
import 'package:wear_camera_remote/wear/constants/constants.dart';

class PreviewRatioScreen extends StatelessWidget {
  Size? screenSize;
  WearShape? wearShape;
  double currentPreviewRatio;

  CollectionReference wearReference =
      FirebaseFirestore.instance.collection('wear_commands');

  PreviewRatioScreen({
    required this.currentPreviewRatio,
  });

  Widget previewRatioScreenWidgets(BuildContext context) {
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
              text: 'Preview Ratio',
            ),
            kSettingButtonWidget(
              icons: Icons.arrow_back_outlined,
              text: 'Back',
              onTap: () {
                Navigator.pop(context, false);
              },
            ),
            kSettingButtonWidget(
              icons: Icons.screenshot_outlined,
              text: '1 : 1',
              onTap: () {
                wearReference.add({'previewRatio': '${1 / 1}'});
                Navigator.pop(context, true);
              },
              current: currentPreviewRatio == 1 / 1 ? true : false,
            ),
            kSettingButtonWidget(
              icons: Icons.screenshot_outlined,
              text: '3 : 4',
              onTap: () {
                wearReference.add({'previewRatio': '${4 / 3}'});
                Navigator.pop(context, true);
              },
              current: currentPreviewRatio == 4 / 3 ? true : false,
            ),
            kSettingButtonWidget(
              icons: Icons.screenshot_outlined,
              text: '9 : 16',
              onTap: () {
                wearReference.add({'previewRatio': '${16 / 9}'});
                Navigator.pop(context, true);
              },
              current: currentPreviewRatio == 16 / 9 ? true : false,
            ),
            kSettingButtonWidget(
              icons: Icons.screenshot_outlined,
              text: '9 : 20',
              onTap: () {
                wearReference.add({'previewRatio': '${20 / 9}'});
                Navigator.pop(context, true);
              },
              current: currentPreviewRatio == 20 / 9 ? true : false,
            ),
          ],
        ),
      ),
    );
  }

  void setCurrentPreviewRatio(double currentPreviewRatio) {
    this.currentPreviewRatio = currentPreviewRatio;
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
              previewRatioScreenWidgets(context),
            ],
          ),
        );
      },
    );
  }
}
