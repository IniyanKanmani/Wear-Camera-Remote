import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

class CaptureTimer {
  int time;
  VoidCallback showTimerBarOnTap;
  VoidCallback setTimerOnTap;

  CaptureTimer({
    required this.time,
    required this.showTimerBarOnTap,
    required this.setTimerOnTap,
  });

  Future? captureTimer;
  List<int> timerValues = [
    0,
    1,
    3,
    5,
    10,
  ];

  Future<void> setTimer() async {
    captureTimer = await Future.delayed(
      Duration(seconds: time),
      () {
        return null;
      },
    );
  }

  void selectTimerOnTap(int value) {
    Vibration.cancel();
    Vibration.vibrate(duration: 25, amplitude: 100);
    time = value;
    setTimerOnTap();
  }

  Widget selectTimerWidget() {
    return GestureDetector(
      onTap: () {
        Vibration.cancel();
        Vibration.vibrate(duration: 25, amplitude: 100);
        showTimerBarOnTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 13.5,
        ),
        child: Text(
          '${time}s',
          style: const TextStyle(
            fontSize: 18.5,
            fontWeight: FontWeight.w100,
            fontFamily: 'F56',
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget timerBarWidget() {
    List<Widget> timerWidgets = [];
    for (int value in timerValues) {
      timerWidgets.add(
        GestureDetector(
          onTap: () {
            // Vibration.cancel();
            // Vibration.vibrate(duration: 25, amplitude: 100);
            // time = value;
            // setTimerOnTap();
            selectTimerOnTap(value);
          },
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Center(
              child: Text(
                '${value}s',
                style: TextStyle(
                  fontFamily: 'F56',
                  fontSize: 16,
                  fontWeight: FontWeight.w100,
                  color: time == value ? Colors.red : Colors.white,
                ),
              ),
            ),
          ),
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: timerWidgets,
    );
  }

  int get getCurrentCaptureTimer {
    return time;
  }

  void callSelectTimerOnTap(int value) {
    selectTimerOnTap(value);
  }
}
