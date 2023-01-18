import 'dart:async';

import 'package:flutter/material.dart';

class TopBar {
  bool showTopBar;
  Timer? topBarTimer;
  VoidCallback beforeTimerFunction;
  VoidCallback afterTimerFunction;
  VoidCallback resetTimerFunction;

  TopBar({
    required this.showTopBar,
    required this.beforeTimerFunction,
    required this.afterTimerFunction,
    required this.resetTimerFunction,
  });

  void showTopBarTimer() {
    if (topBarTimer != null && topBarTimer!.isActive) {
      topBarResetTimer();
    }
    showTopBar = false;
    beforeTimerFunction();
    topBarTimer = Timer(const Duration(seconds: 5), () {
      topBarResetTimer();
      afterTimerFunction();
    });
  }

  void topBarResetTimer() {
    if (topBarTimer == null) {
      return;
    }
    showTopBar = true;
    resetTimerFunction();
    topBarTimer!.cancel();
  }

  void setShowTopBar(bool value) {
    showTopBar = value;
  }

  get getShowTopBar {
    return showTopBar;
  }
}
