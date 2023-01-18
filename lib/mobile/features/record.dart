import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:vibration/vibration.dart';

class Record {
  bool isRecordingInProgress;
  bool isRecordingPaused;
  bool isTimerRunning = false;
  double currentPreviewRatio;
  String displayTime = '';
  Color? recordDotColor;
  StopWatchTimer? recordStopwatch;
  Future<void> Function() beforeRecordingVideo;
  VoidCallback setStateFunction;
  Future<void> Function() recordVideoOnTap;
  Future<void> Function() stopVideoOnTap;
  Future<void> Function() pauseVideoOnTap;
  Future<void> Function() resumeVideoOnTap;

  CollectionReference mobileReference =
      FirebaseFirestore.instance.collection('mobile_commands');

  Record({
    required this.isRecordingInProgress,
    required this.isRecordingPaused,
    required this.currentPreviewRatio,
    required this.beforeRecordingVideo,
    required this.setStateFunction,
    required this.recordVideoOnTap,
    required this.stopVideoOnTap,
    required this.pauseVideoOnTap,
    required this.resumeVideoOnTap,
  });

  void createStopWatch() {
    recordStopwatch = StopWatchTimer(
      mode: StopWatchMode.countUp,
      onChangeRawSecond: (int value) {
        displayTime = recordStopwatch!.isRunning
            ? StopWatchTimer.getDisplayTime(
                value * 1000,
                milliSecond: false,
              )
            : '';
        recordDotColor = (value % 2 == 0 && recordStopwatch!.isRunning)
            ? Colors.red
            : Colors.transparent;
        setStateFunction();
      },
    );
  }

  Future<void> recordOnTap() async {
    mobileReference.add({'cameraMode': '1'});
    mobileReference.add({'recordVideo': '0'});
    Vibration.cancel();
    Vibration.vibrate(duration: 25, amplitude: 250);
    Vibration.vibrate(duration: 50, amplitude: 1);
    Vibration.vibrate(duration: 25, amplitude: 250);
    isTimerRunning = true;
    setStateFunction();
    await beforeRecordingVideo();
    createStopWatch();
    recordStopwatch!.onExecute.add(StopWatchExecute.start);
    isRecordingInProgress = true;
    isRecordingPaused = false;
    await recordVideoOnTap();
    isTimerRunning = false;
  }

  Future<void> stopOnTap() async {
    mobileReference.add({'recordVideo': '1'});
    Vibration.cancel();
    Vibration.vibrate(duration: 25, amplitude: 250);
    Vibration.vibrate(duration: 50, amplitude: 1);
    Vibration.vibrate(duration: 25, amplitude: 250);
    recordStopwatch!.onExecute.add(StopWatchExecute.reset);
    isRecordingInProgress = false;
    isRecordingPaused = false;
    await stopVideoOnTap();
  }

  Future<void> pauseOnTap() async {
    mobileReference.add({'pauseVideo': '0'});
    Vibration.cancel();
    Vibration.vibrate(duration: 25, amplitude: 150);
    Vibration.vibrate(duration: 50, amplitude: 1);
    Vibration.vibrate(duration: 25, amplitude: 150);
    isRecordingInProgress = true;
    isRecordingPaused = true;
    await pauseVideoOnTap();
    recordStopwatch!.onExecute.add(StopWatchExecute.stop);
  }

  Future<void> resumeOnTap() async {
    mobileReference.add({'pauseVideo': '1'});
    Vibration.cancel();
    Vibration.vibrate(duration: 25, amplitude: 150);
    Vibration.vibrate(duration: 50, amplitude: 1);
    Vibration.vibrate(duration: 25, amplitude: 150);
    recordStopwatch!.onExecute.add(StopWatchExecute.start);
    isRecordingInProgress = true;
    isRecordingPaused = false;
    await resumeVideoOnTap();
  }

  Widget recordButtonWidget() {
    return GestureDetector(
      onTap: () async {
        await recordOnTap();
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            backgroundColor: isTimerRunning ? Colors.white70 : Colors.white,
            radius: 35,
          ),
          CircleAvatar(
            backgroundColor: isTimerRunning ? Colors.transparent : Colors.red,
            radius: 32.5,
          ),
        ],
      ),
    );
  }

  Widget stopButtonWidget() {
    return GestureDetector(
      onTap: () async {
        await stopOnTap();
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          const CircleAvatar(
            backgroundColor: Colors.white,
            radius: 35,
          ),
          Container(
            width: 30,
            height: 30,
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget pauseButtonWidget() {
    return GestureDetector(
      onTap: () async {
        await pauseOnTap();
      },
      child: const CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 30.0,
        child: Icon(
          Icons.pause_outlined,
          color: Colors.white,
          size: 45.0,
        ),
      ),
    );
  }

  Widget resumeButtonWidget() {
    return GestureDetector(
      onTap: () async {
        await resumeOnTap();
      },
      child: const CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 30.0,
        child: Icon(
          Icons.play_arrow_outlined,
          color: Colors.white,
          size: 45.0,
        ),
      ),
    );
  }

  Widget recordStopwatchWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 6.0,
          backgroundColor: recordDotColor,
        ),
        const SizedBox(
          width: 10.0,
        ),
        Text(
          displayTime,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15.5,
            fontFamily: 'F56',
            fontWeight: FontWeight.w100,
          ),
        ),
      ],
    );
  }

  bool get getIsRecodingInProgress {
    return isRecordingInProgress;
  }

  bool get getIsRecodingPaused {
    return isRecordingPaused;
  }

  Future<void> callRecordOnTap() async {
    await recordOnTap();
  }

  Future<void> callStopOnTap() async {
    await stopOnTap();
  }

  Future<void> callPauseOnTap() async {
    await pauseOnTap();
  }

  Future<void> callResumeOnTap() async {
    await resumeOnTap();
  }
}
