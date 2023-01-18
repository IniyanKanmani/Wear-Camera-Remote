import 'package:flutter/material.dart';

Widget kSettingIconWidget({
  required IconData icons,
  bool current = false,
}) {
  return CircleAvatar(
    backgroundColor: Colors.white24,
    radius: 20,
    child: Icon(
      icons,
      size: 25.0,
      color: current ? Colors.red : Colors.white,
    ),
  );
}

Widget kSettingButtonWidget({
  required IconData icons,
  required String text,
  required VoidCallback onTap,
  bool current = false,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.all(
        2.5,
      ),
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(
              30.0,
            ),
          ),
          color: Colors.white10,
        ),
        child: SizedBox(
          height: 45,
          child: Row(
            children: [
              kSettingIconWidget(
                icons: icons,
                current: current,
              ),
              Container(
                color: Colors.transparent,
                width: 10.0,
              ),
              Text(
                text,
                style: TextStyle(
                  color: current ? Colors.red : Colors.white,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget kSettingTextWidget({
  required String text,
}) {
  return Padding(
    padding: const EdgeInsets.only(
      right: 5.0,
      bottom: 10.0,
    ),
    child: Center(
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18.0,
        ),
      ),
    ),
  );
}
