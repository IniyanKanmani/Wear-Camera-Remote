import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wear/wear.dart';
import 'package:wear_camera_remote/wear/constants/constants.dart';

class FlashScreen extends StatelessWidget {
  FlashScreen({Key? key}) : super(key: key);

  Size? screenSize;
  WearShape? wearShape;
  CollectionReference mobileReference =
      FirebaseFirestore.instance.collection('mobile_commands');
  CollectionReference wearReference =
      FirebaseFirestore.instance.collection('wear_commands');

  Widget flashScreenWidgets(BuildContext context) {
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
              text: 'Flash',
            ),
            kSettingButtonWidget(
              icons: Icons.arrow_back_outlined,
              text: 'Back',
              onTap: () {
                Navigator.pop(context);
              },
            ),
            kSettingButtonWidget(
              icons: Icons.flash_off_outlined,
              text: 'Off',
              onTap: () {
                wearReference.add({'flash': '0'});
                Navigator.pop(context);
              },
            ),
            kSettingButtonWidget(
              icons: Icons.flash_auto_outlined,
              text: 'Auto',
              onTap: () {
                wearReference.add({'flash': '1'});
                Navigator.pop(context);
              },
            ),
            kSettingButtonWidget(
              icons: Icons.flash_on_outlined,
              text: 'On',
              onTap: () {
                wearReference.add({'flash': '2'});
                Navigator.pop(context);
              },
            ),
            kSettingButtonWidget(
              icons: Icons.highlight_outlined,
              text: 'Torch',
              onTap: () {
                wearReference.add({'flash': '3'});
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
              flashScreenWidgets(context),
            ],
          ),
        );
      },
    );
  }
}
