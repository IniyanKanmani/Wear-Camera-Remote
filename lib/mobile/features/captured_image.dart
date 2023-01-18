import 'dart:io';

import 'package:flutter/material.dart';

class CapturedImage {
  String capturedFilePath;
  double currentPreviewRatio;
  VoidCallback capturedImageOnTap;

  CapturedImage({
    required this.capturedFilePath,
    required this.currentPreviewRatio,
    required this.capturedImageOnTap,
  });

  Widget capturedImageWidget() {
    return GestureDetector(
      onTap: () {
        capturedImageOnTap();
      },
      child: capturedFilePath != ''
          ? Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                border: Border.all(
                  width: 0.75,
                  color: Colors.white,
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                controller: ScrollController(
                  initialScrollOffset: 60 * currentPreviewRatio / 2 - 60 / 2,
                ),
                physics: const NeverScrollableScrollPhysics(),
                child: Image(
                  height: 60 * currentPreviewRatio,
                  width: 60,
                  image: FileImage(
                    File(capturedFilePath),
                  ),
                ),
              ),
            )
          : Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(
                  width: 0.75,
                  color: Colors.white,
                ),
              ),
            ),
    );
  }

  void setCapturedFilePath(String path) {
    capturedFilePath = path;
  }
}
