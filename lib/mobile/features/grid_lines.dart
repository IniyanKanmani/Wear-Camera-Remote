import 'package:flutter/material.dart';

class GridLines {
  double? height;
  double? width;

  GridLines({
    this.height,
    this.width,
  });

  Widget drawLines(bool isHorizontal) {
    double thickness = 1.0;
    return SizedBox(
      height: isHorizontal ? thickness : height,
      width: isHorizontal ? width : thickness,
      child: Container(
        color: Colors.white54,
      ),
    );
  }

  Widget gridLinesWidget() {
    return SizedBox(
      height: height,
      width: width,
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              drawLines(false),
              drawLines(false),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              drawLines(true),
              drawLines(true),
            ],
          ),
        ],
      ),
    );
  }
}
