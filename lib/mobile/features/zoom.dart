import 'dart:async';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_core/src/theme/slider_theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:vibration/vibration.dart';

class Zoom {
  bool showZoomLevelBar;
  double minAvailableZoom;
  double currentZoomLevel;
  double maxAvailableZoom;
  VoidCallback zoomTimerFunction;
  VoidCallback setZoomLevelOnChanged;
  VoidCallback showZoomSliderOnTap;
  Timer? zoomTimer;

  Zoom({
    required this.showZoomLevelBar,
    required this.minAvailableZoom,
    required this.currentZoomLevel,
    required this.maxAvailableZoom,
    required this.zoomTimerFunction,
    required this.setZoomLevelOnChanged,
    required this.showZoomSliderOnTap,
  });

  void showZoomTimer() {
    if (zoomTimer != null && zoomTimer!.isActive) {
      zoomResetTimer();
    }
    showZoomLevelBar = true;
    zoomTimer = Timer(const Duration(seconds: 5), () {
      zoomResetTimer();
      zoomTimerFunction();
    });
  }

  void zoomResetTimer() {
    showZoomLevelBar = false;
    zoomTimer?.cancel();
  }

  Widget zoomLevelSliderWidget() {
    return SfSliderTheme(
      data: SfSliderThemeData(
        activeTrackColor: Colors.transparent,
        inactiveTrackColor: Colors.transparent,
        activeTickColor: Colors.white,
        inactiveTickColor: Colors.white,
        activeMinorTickColor: Colors.white70,
        inactiveMinorTickColor: Colors.white70,
        thumbColor: Colors.transparent,
        overlayColor: Colors.transparent,
        thumbRadius: 20,
        overlayRadius: 0.0,
        tickOffset: const Offset(0.0, -13.0),
        tickSize: const Size(2, 20),
        minorTickSize: const Size(1, 20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 10.0,
          vertical: 15.0,
        ),
        child: SfSlider(
          value: currentZoomLevel,
          interval: 1,
          stepSize: 0.1,
          showDividers: false,
          thumbIcon: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 18.0,
            ),
            color: Colors.red,
          ),
          minorTicksPerInterval: 4,
          min: minAvailableZoom,
          max: maxAvailableZoom,
          showTicks: true,
          showLabels: false,
          onChanged: (value) {
            Vibration.cancel();
            currentZoomLevel = double.parse(
              double.parse(value.toString()).toStringAsFixed(1),
            );
            if (currentZoomLevel % 1 == 0) {
              Vibration.vibrate(
                duration: 25,
                amplitude: 200,
              );
            } else if (currentZoomLevel * 10 % 2 == 0) {
              Vibration.vibrate(
                duration: 25,
                amplitude: 100,
              );
            }
            showZoomTimer();
            setZoomLevelOnChanged();
          },
        ),
      ),
    );
  }

  Widget zoomLevelTextWidget() {
    return GestureDetector(
      onTap: () {
        showZoomTimer();
        showZoomSliderOnTap();
      },
      child: Padding(
        padding: EdgeInsets.only(
          bottom: showZoomLevelBar ? 0.0 : 15.0,
        ),
        child: Text(
          '${currentZoomLevel}x',
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'F56',
            fontSize: 20.0,
          ),
        ),
      ),
    );
  }

  void setShowZoomLevelBar(bool value) {
    showZoomLevelBar = value;
  }

  bool get getShowZoomLevelBar {
    return showZoomLevelBar;
  }

  double get getCurrentZoomLevel {
    return currentZoomLevel;
  }
}
