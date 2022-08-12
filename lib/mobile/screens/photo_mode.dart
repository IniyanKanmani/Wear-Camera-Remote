import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:wear_camera_remote/mobile/features/capture.dart';
import 'package:wear_camera_remote/mobile/features/captured_image.dart';
import 'package:wear_camera_remote/mobile/features/flash.dart';
import 'package:wear_camera_remote/mobile/features/flip_camera.dart';
import 'package:wear_camera_remote/mobile/features/grid_lines.dart';
import 'package:wear_camera_remote/mobile/features/preview_ratio.dart';
import 'package:wear_camera_remote/mobile/features/resolution.dart';
import 'package:wear_camera_remote/mobile/features/timer.dart';
import 'package:wear_camera_remote/mobile/features/top_bar.dart';
import 'package:wear_camera_remote/mobile/features/zoom.dart';

class PhotoMode {
  bool isRearCamera = true;
  bool isCameraInitialized = false;

  bool showTopBar;
  bool showFlashModeBar;
  bool showCaptureTimerBar;
  bool showPreviewRatioBar;
  bool showResolutionPresetBar;
  bool showZoomLevelBar;

  double currentPreviewRatio;
  double screenWidth;
  double previewWidth;
  double previewHeight;

  CameraController controller;

  Resolution resolution;
  Zoom zoom;
  Flash flash;
  GridLines gridLines;
  Capture capture;
  CaptureTimer captureTimer;
  PreviewRatio previewRatio;
  FlipCamera flipCamera;
  CapturedImage capturedImage;
  TopBar topBar;
  VoidCallback changeToVideoMode;

  PhotoMode({
    required this.isRearCamera,
    required this.isCameraInitialized,
    required this.showTopBar,
    required this.showFlashModeBar,
    required this.showCaptureTimerBar,
    required this.showPreviewRatioBar,
    required this.showResolutionPresetBar,
    required this.showZoomLevelBar,
    required this.currentPreviewRatio,
    required this.screenWidth,
    required this.previewWidth,
    required this.previewHeight,
    required this.controller,
    required this.resolution,
    required this.zoom,
    required this.flash,
    required this.gridLines,
    required this.capture,
    required this.captureTimer,
    required this.previewRatio,
    required this.flipCamera,
    required this.capturedImage,
    required this.topBar,
    required this.changeToVideoMode,
  });

  Widget buildPhotoModeUI() {
    return isCameraInitialized
        ? Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: currentPreviewRatio == 20 / 9 ? 0.0 : 70.0,
                ),
                child: GestureDetector(
                  onVerticalDragEnd: (DragEndDetails details) {
                    double sensitivity = 10;
                    if (details.primaryVelocity! > sensitivity ||
                        details.primaryVelocity! < -sensitivity) {
                      flipCamera.switchCameraOnTap();
                    }
                  },
                  onHorizontalDragEnd: (DragEndDetails details) {
                    double sensitivity = 20;
                    if (details.primaryVelocity! < -sensitivity) {
                      changeToVideoMode();
                    }
                  },
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      SizedBox(
                        width: screenWidth,
                        height: screenWidth * currentPreviewRatio,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          controller: ScrollController(
                            initialScrollOffset: ((previewHeight -
                                    (previewWidth * currentPreviewRatio)) /
                                2),
                          ),
                          physics: const NeverScrollableScrollPhysics(),
                          child: AspectRatio(
                            aspectRatio: 1 / controller.value.aspectRatio,
                            child: CameraPreview(controller),
                          ),
                        ),
                      ),
                      gridLines.gridLinesWidget(),
                    ],
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Opacity(
                        opacity: 0.5,
                        child: Container(
                          width: screenWidth,
                          height: 70.0,
                          color: Colors.black,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (topBar.getShowTopBar && isRearCamera) ...[
                            flash.selectFlashModeWidget(),
                            captureTimer.selectTimerWidget(),
                            previewRatio.selectPreviewRatioWidget(),
                            resolution.selectResolutionWidget(),
                          ],
                          if (topBar.getShowTopBar && !isRearCamera) ...[
                            captureTimer.selectTimerWidget(),
                            previewRatio.selectPreviewRatioWidget(),
                            resolution.selectResolutionWidget(),
                          ],
                          if (showFlashModeBar) ...[
                            flash.flashBarWidget(),
                          ],
                          if (showCaptureTimerBar) ...[
                            captureTimer.timerBarWidget(),
                          ],
                          if (showPreviewRatioBar) ...[
                            previewRatio.previewRatioBarWidget(),
                          ],
                          if (showResolutionPresetBar) ...[
                            resolution.resolutionBarWidget(),
                          ],
                        ],
                      ),
                    ],
                  ),
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      SizedBox(
                        width: screenWidth,
                        height: screenWidth * 4 / 3,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          zoom.zoomLevelTextWidget(),
                          if (zoom.getShowZoomLevelBar)
                            zoom.zoomLevelSliderWidget(),
                        ],
                      ),
                    ],
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        Opacity(
                          opacity: 0.50,
                          child: Container(
                            width: screenWidth,
                            color: Colors.black,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 25.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  const Text(
                                    'PHOTO',
                                    style: TextStyle(
                                      fontFamily: 'F56',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w100,
                                      color: Colors.red,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: changeToVideoMode,
                                    child: const Text(
                                      'VIDEO',
                                      style: TextStyle(
                                        fontFamily: 'F56',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w100,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: screenWidth,
                                height: 40.0,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  capturedImage.capturedImageWidget(),
                                  capture.captureButtonWidget(),
                                  flipCamera.flipCameraWidget(),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          )
        : Container();
  }
}
