import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

class Flash {
  FlashMode currentFlashMode;
  Icon? currentFlashModeIcon;
  VoidCallback showFlashBarOnTap;
  VoidCallback setFlashOnTap;

  List<FlashMode> flashValues = FlashMode.values;
  List<IconData> flashIcons = [
    Icons.flash_off_sharp,
    Icons.flash_auto_sharp,
    Icons.flash_on_sharp,
    Icons.highlight_sharp,
  ];

  Flash(
      {required this.currentFlashMode,
      required this.showFlashBarOnTap,
      required this.setFlashOnTap});

  Widget selectFlashModeWidget() {
    currentFlashModeIcon = Icon(
      flashIcons[flashValues.indexOf(currentFlashMode)],
      color: Colors.white,
    );
    return GestureDetector(
      onTap: () {
        Vibration.cancel();
        Vibration.vibrate(duration: 25, amplitude: 100);
        showFlashBarOnTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 10.0,
        ),
        child: SizedBox(
          height: 30,
          width: 30,
          child: currentFlashModeIcon,
        ),
      ),
    );
  }

  void selectFlashOnTap(int i) {
    Vibration.cancel();
    Vibration.vibrate(duration: 25, amplitude: 100);
    currentFlashModeIcon = Icon(
      flashIcons[i],
      color: Colors.red,
    );
    currentFlashMode = flashValues[i];
    setFlashOnTap();
  }

  Widget flashBarWidget() {
    List<Widget> flashModeWidgets = [];
    for (int i = 0; i < flashIcons.length; i++) {
      flashModeWidgets.add(
        GestureDetector(
          onTap: () {
            selectFlashOnTap(i);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 10.0,
            ),
            child: SizedBox(
              height: 30.0,
              width: 30.0,
              child: Icon(
                flashIcons[i],
                color: currentFlashMode == flashValues[i]
                    ? Colors.red
                    : Colors.white,
              ),
            ),
          ),
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: flashModeWidgets,
    );
  }

  FlashMode get getCurrentFlashMode {
    return currentFlashMode;
  }

  void callSelectFlashOnTap(int value) {
    selectFlashOnTap(value);
  }
}
