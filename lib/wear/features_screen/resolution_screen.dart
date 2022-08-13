import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wear/wear.dart';
import 'package:wear_camera_remote/wear/constants/constants.dart';

class ResolutionScreen extends StatelessWidget {
  ResolutionScreen({Key? key}) : super(key: key);

  Size? screenSize;
  WearShape? wearShape;
  CollectionReference mobileReference =
      FirebaseFirestore.instance.collection('mobile_commands');
  CollectionReference wearReference =
      FirebaseFirestore.instance.collection('wear_commands');

  Widget resolutionScreenWidgets(BuildContext context) {
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
              text: 'Resolution',
            ),
            kSettingButtonWidget(
              icons: Icons.arrow_back_outlined,
              text: 'Back',
              onTap: () {
                Navigator.pop(context);
              },
            ),
            kSettingButtonWidget(
              icons: Icons.photo_size_select_small_outlined,
              text: 'Low',
              onTap: () {
                wearReference.add({'resolution': '0'});
                Navigator.pop(context);
              },
            ),
            kSettingButtonWidget(
              icons: Icons.photo_size_select_small_outlined,
              text: 'Medium',
              onTap: () {
                wearReference.add({'resolution': '1'});
                Navigator.pop(context);
              },
            ),
            kSettingButtonWidget(
              icons: Icons.photo_size_select_small_outlined,
              text: 'High',
              onTap: () {
                wearReference.add({'resolution': '2'});
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
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
              resolutionScreenWidgets(context),
            ],
          ),
        );
      },
    );
  }
}
