import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

class Resolution {
  bool isRearCamera;
  double pixels;
  ResolutionPreset currentResolutionPreset;
  VoidCallback showResolutionBarOnTap;
  VoidCallback setResolutionOnTap;
  List<ResolutionPreset> resolutionPresets;
  List<Widget> resolutionPresetWidgets = [];
  Map<ResolutionPreset, double>? resolutionValues;

  Resolution({
    required this.isRearCamera,
    required this.pixels,
    required this.currentResolutionPreset,
    required this.resolutionPresets,
    required this.showResolutionBarOnTap,
    required this.setResolutionOnTap,
  });

  List<ResolutionPreset> findMaxResolution() {
    List<ResolutionPreset> presets = [];
    if (pixels >= 240.0) {
      presets.add(ResolutionPreset.low);
    }
    if (pixels >= 480.0) {
      presets.add(ResolutionPreset.medium);
    }
    if (pixels >= 720.0) {
      presets.add(ResolutionPreset.high);
    }
    if (pixels >= 1080.0) {
      presets.add(ResolutionPreset.veryHigh);
    }
    if (pixels >= 2160.0) {
      presets.add(ResolutionPreset.ultraHigh);
    }
    if (pixels > 2160.0) {
      presets.add(ResolutionPreset.max);
    }
    return presets;
  }

  Future<void> setResolutionValues() async {
    resolutionValues = {
      ResolutionPreset.low: 240.0,
      ResolutionPreset.medium: 480.0,
      ResolutionPreset.high: 720.0,
      ResolutionPreset.veryHigh: 1080.0,
      ResolutionPreset.ultraHigh: 2160.0,
      ResolutionPreset.max: pixels,
    };
  }

  void selectResolutionOnTap(int i) {
    Vibration.cancel();
    Vibration.vibrate(duration: 25, amplitude: 100);
    currentResolutionPreset = resolutionPresets[i];
    setResolutionOnTap();
  }

  Widget selectResolutionWidget() {
    return GestureDetector(
      onTap: () {
        Vibration.cancel();
        Vibration.vibrate(duration: 25, amplitude: 100);
        showResolutionBarOnTap();
      },
      child: const Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 10.0,
        ),
        child: SizedBox(
          height: 30,
          width: 30,
          child: Icon(
            Icons.photo_size_select_small_sharp,
            color: Colors.white,
            size: 30.0,
          ),
        ),
      ),
    );
  }

  Widget resolutionBarWidget() {
    bool isResolutionPresetEmpty = resolutionPresets.isEmpty;
    resolutionPresets =
        isResolutionPresetEmpty ? findMaxResolution() : resolutionPresets;
    currentResolutionPreset = isResolutionPresetEmpty
        ? resolutionPresets[resolutionPresets.length - 1]
        : currentResolutionPreset;
    if (resolutionPresetWidgets.isEmpty) {
      for (int i = 0; i < resolutionPresets.length; i++) {
        resolutionPresetWidgets.add(
          GestureDetector(
            onTap: () {
              // Vibration.cancel();
              // Vibration.vibrate(duration: 25, amplitude: 100);
              // currentResolutionPreset = resolutionPresets[i];
              // setResolutionOnTap();
              selectResolutionOnTap(i);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15.0,
                vertical: 10.0,
              ),
              child: Center(
                child: Text(
                  resolutionPresets[i].toString().split('.')[1].toUpperCase(),
                  style: TextStyle(
                    fontSize: 16.0,
                    color: currentResolutionPreset == resolutionPresets[i]
                        ? Colors.red
                        : Colors.white,
                    fontFamily: 'F56',
                    fontWeight: FontWeight.w100,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        height: 70.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: resolutionPresetWidgets,
        ),
      ),
    );
  }

  bool get getIsRearCamera {
    return isRearCamera;
  }

  Map<ResolutionPreset, double> get getResolutionValues {
    return resolutionValues!;
  }

  ResolutionPreset get getCurrentResolutionPreset {
    return currentResolutionPreset;
  }

  List<ResolutionPreset> get getResolutionPresets {
    return resolutionPresets;
  }

  void callSelectResolutionOnTap(int value) {
    bool isResolutionPresetEmpty = resolutionPresets.isEmpty;
    resolutionPresets =
        isResolutionPresetEmpty ? findMaxResolution() : resolutionPresets;
    currentResolutionPreset = isResolutionPresetEmpty
        ? resolutionPresets[resolutionPresets.length - 1]
        : currentResolutionPreset;
    selectResolutionOnTap(value);
  }
}
