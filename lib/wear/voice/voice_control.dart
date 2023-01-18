import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:wear/wear.dart';
import 'package:wear_camera_remote/wear/screens/camera_remote_screen.dart';

class VoiceControl {
  Size? screenSize;
  WearShape? wearShape;

  SpeechToText? speechToText;
  bool speechEnabled = false;
  String lastWords = '';
  Timer? listeningTimer;

  bool isPhotoCapturing;
  bool isRecordingInProgress;
  bool isRecordingPaused;
  bool isRearCamera;
  bool isAudioEnabled;
  int currentFlash;
  int currentTimer;
  double currentPreviewRatio;
  int currentResolution;
  CameraMode currentCameraMode;
  VoidCallback setStateCallBack;

  CollectionReference wearReference =
      FirebaseFirestore.instance.collection('wear_commands');

  VoiceControl({
    required this.isPhotoCapturing,
    required this.isRecordingInProgress,
    required this.isRecordingPaused,
    required this.isRearCamera,
    required this.isAudioEnabled,
    required this.currentFlash,
    required this.currentTimer,
    required this.currentPreviewRatio,
    required this.currentResolution,
    required this.currentCameraMode,
    required this.setStateCallBack,
  });

  void initializeSpeechToText() async {
    if (!speechEnabled) {
      speechToText = SpeechToText();
      speechEnabled = await speechToText!.initialize();
    }
    // speechEnabled ? initializeTimer() : {};
  }

  void initializeTimer() {
    (listeningTimer != null && listeningTimer!.isActive)
        ? cancelListeningTimer()
        : {};
    speechToText!.isNotListening ? startListening() : {};
    listeningTimer = Timer(const Duration(seconds: 10), () {
      // speechToText!.isListening ? stopListening() : {};
      cancelListeningTimer();
      initializeTimer();
    });
  }

  void cancelListeningTimer() {
    if (listeningTimer != null) listeningTimer!.cancel();
  }

  void startListening() async {
    debugPrint('IsListening in StartListening: ${speechToText!.isListening}');
    await speechToText!.listen(
      // listenFor: const Duration(seconds: 4),
      onResult: onSpeechResult,
    );
    setStateCallBack();
  }

  void stopListening() async {
    debugPrint('IsListening in StopListening: ${speechToText!.isListening}');
    await speechToText!.stop();
  }

  void cancelListening() async {
    debugPrint('IsListening in CancelListening: ${speechToText!.isListening}');
    await speechToText!.cancel();
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    if (result.finalResult) {
      List<SpeechRecognitionWords> alternateWords = result.alternates;
      debugPrint('${result.finalResult} ${alternateWords.toString()}');
      debugPrint('IsListening in OnSpeechResult: ${speechToText!.isListening}');
      lastWords = result.recognizedWords;
      // debugPrint(lastWords);
      pushCommandsToDatabase(alternateWords);
      initializeTimer();
    }
  }

  void pushCommandsToDatabase(List<SpeechRecognitionWords> alternateWords) {
    Map recognisedCommands = {};
    for (SpeechRecognitionWords speechRecognizedWords in alternateWords) {
      String words = speechRecognizedWords.recognizedWords;
      List<String> allWords = words.split(' ');
      List<String> photoWords = ['capture'];
      List<String> videoWords = ['record', 'pause', 'resume', 'stop', 'play'];
      List<String> capturePhoto = ['capture', 'cheese', 'smile'];
      List<String> flash = ['off', 'auto', 'on', 'torch'];
      List<String> timer = ['0', '1', '3', '5', '10'];
      Map<String, String> previewRatio = {
        '1': '${1 / 1}',
        '3': '${4 / 3}',
        '16': '${16 / 9}',
        '20': '${20 / 9}',
      };
      List<String> resolution = ['low', 'medium', 'high'];
      if (recognisedCommands.isEmpty) {
        for (String word in allWords) {
          word = word.toLowerCase();
          if (word == 'photo') {
            if (currentCameraMode != CameraMode.photo) {
              if (photoWords.any((element) => allWords.contains(element))) {
                continue;
              }
              debugPrint('KEYWORD : $word');
              recognisedCommands['cameraMode'] = '0';
            }
          } else if (word == 'video') {
            if (currentCameraMode != CameraMode.video) {
              if (videoWords.any((element) => allWords.contains(element))) {
                continue;
              }
              debugPrint('KEYWORD : $word');
              recognisedCommands['cameraMode'] = '1';
            }
          } else if (capturePhoto.any((element) => element == word)) {
            if (!isPhotoCapturing) {
              debugPrint('KEYWORD : $word');
              recognisedCommands
                  .addAll({'cameraMode': '0', 'capturePhoto': '0'});
            }
          } else if (word == 'record') {
            if (!isRecordingInProgress) {
              debugPrint('KEYWORD : $word');
              recognisedCommands
                  .addAll({'cameraMode': '1', 'recordVideo': '0'});
            }
          } else if (word == 'pause') {
            if (isRecordingInProgress && !isRecordingPaused) {
              debugPrint('KEYWORD : $word');
              recognisedCommands['pauseVideo'] = '0';
            }
          } else if (word == 'resume') {
            if (isRecordingInProgress && isRecordingPaused) {
              debugPrint('KEYWORD : $word');
              recognisedCommands['pauseVideo'] = '1';
            }
          } else if (word == 'stop') {
            if (!isRecordingInProgress) {
              debugPrint('KEYWORD : $word');
              recognisedCommands
                  .addAll({'cameraMode': '1', 'recordVideo': '1'});
            }
          } else if (word == 'flip') {
            debugPrint('KEYWORD : $word');
            recognisedCommands['flipCamera'] = isRearCamera ? '1' : '0';
          } else if (word == 'flash') {
            for (String innerWord in allWords) {
              if (flash.indexOf(innerWord) != currentFlash) {
                innerWord = innerWord.toLowerCase();
                if (flash.any((element) => element == innerWord)) {
                  debugPrint('KEYWORD : $word $innerWord');
                  recognisedCommands['flash'] =
                      flash.indexOf(innerWord).toString();
                  break;
                }
              } else {
                break;
              }
            }
          } else if (word == 'timer') {
            for (String innerWord in allWords) {
              if (innerWord != currentTimer.toString()) {
                innerWord = innerWord.toLowerCase();
                if (timer.any((element) => element == innerWord)) {
                  debugPrint('KEYWORD : $word $innerWord');
                  recognisedCommands['timer'] = timer
                      .firstWhere((element) => element == innerWord)
                      .toString();
                  break;
                }
              } else {
                break;
              }
            }
          } else if (word == 'ratio') {
            for (String innerWord in allWords) {
              if (innerWord != currentPreviewRatio.toString()) {
                innerWord = innerWord.toLowerCase();
                if (previewRatio.containsKey(innerWord)) {
                  debugPrint('KEYWORD : $word ${previewRatio[innerWord]}');
                  recognisedCommands['previewRatio'] =
                      previewRatio[innerWord].toString();
                  break;
                }
              } else {
                break;
              }
            }
          } else if (word == 'resolution') {
            for (String innerWord in allWords) {
              if (resolution.indexOf(innerWord) != currentResolution) {
                innerWord = innerWord.toLowerCase();
                if (resolution.any((element) => element == innerWord)) {
                  debugPrint('KEYWORD : $word $innerWord');
                  recognisedCommands['resolution'] =
                      resolution.indexOf(innerWord).toString();
                  break;
                }
              } else {
                break;
              }
            }
          } else if (word == 'audio') {
            debugPrint('KEYWORD : $word');
            recognisedCommands['audio'] = isAudioEnabled ? '0' : '1';
            break;
          }
        }
      } else {
        break;
      }
    }
    recognisedCommands.forEach((key, value) {
      wearReference.add({key.toString(): value.toString()});
    });
  }

  void updateVariables({
    required bool isPhotoCapturing,
    required bool isRecordingInProgress,
    required bool isRecordingPaused,
    required bool isRearCamera,
    required bool isAudioEnabled,
    required int currentFlash,
    required int currentTimer,
    required double currentPreviewRatio,
    required int currentResolution,
    required CameraMode currentCameraMode,
  }) {
    this.isPhotoCapturing = isPhotoCapturing;
    this.isRecordingInProgress = isRecordingInProgress;
    this.isRecordingPaused = isRecordingPaused;
    this.isRearCamera = isRearCamera;
    this.isAudioEnabled = isAudioEnabled;
    this.currentFlash = currentFlash;
    this.currentTimer = currentTimer;
    this.currentPreviewRatio = currentPreviewRatio;
    this.currentResolution = currentResolution;
    this.currentCameraMode = currentCameraMode;
  }
}
