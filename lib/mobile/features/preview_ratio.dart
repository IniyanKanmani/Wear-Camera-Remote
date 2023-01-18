import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fraction/fraction.dart';
import 'package:vibration/vibration.dart';

class PreviewRatio {
  double currentPreviewRatio;
  VoidCallback showPreviewRatioBarOnTap;
  VoidCallback setPreviewRatioOnTap;
  List<double> previewRatioValues = [
    1 / 1,
    4 / 3,
    16 / 9,
    20 / 9,
  ];

  CollectionReference mobileReference =
      FirebaseFirestore.instance.collection('mobile_commands');

  PreviewRatio({
    required this.currentPreviewRatio,
    required this.showPreviewRatioBarOnTap,
    required this.setPreviewRatioOnTap,
  });

  void selectPreviewRatioOnTap(double ratio) {
    mobileReference.add({'previewRatio': '$ratio'});
    Vibration.cancel();
    Vibration.vibrate(duration: 25, amplitude: 100);
    currentPreviewRatio = ratio;
    setPreviewRatioOnTap();
  }

  Widget selectPreviewRatioWidget() {
    return GestureDetector(
      onTap: () {
        Vibration.cancel();
        Vibration.vibrate(duration: 25, amplitude: 100);
        showPreviewRatioBarOnTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 12.0,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
          decoration: BoxDecoration(
            border: Border.all(
              width: 0.5,
              color: Colors.white,
            ),
          ),
          child: Text(
            '${Fraction.fromDouble(currentPreviewRatio).denominator}:${Fraction.fromDouble(currentPreviewRatio).numerator}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w100,
              fontFamily: 'F56',
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget previewRatioBarWidget() {
    List<Widget> previewRatioWidgets = [];
    for (double ratio in previewRatioValues) {
      previewRatioWidgets.add(
        GestureDetector(
          onTap: () {
            selectPreviewRatioOnTap(ratio);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 12.0,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
              decoration: BoxDecoration(
                border: Border.all(
                  width: 0.5,
                  color:
                      currentPreviewRatio == ratio ? Colors.red : Colors.white,
                ),
              ),
              child: Text(
                '${Fraction.fromDouble(ratio).denominator}:${Fraction.fromDouble(ratio).numerator}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w100,
                  fontFamily: 'F56',
                  color:
                      currentPreviewRatio == ratio ? Colors.red : Colors.white,
                ),
              ),
            ),
          ),
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: previewRatioWidgets,
    );
  }

  double get getCurrentPreviewRatio {
    return currentPreviewRatio;
  }

  void callSelectPreviewRatioOnTap(double value) {
    selectPreviewRatioOnTap(value);
  }
}
