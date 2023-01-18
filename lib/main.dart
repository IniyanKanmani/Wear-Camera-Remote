import 'package:camera/camera.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock/wakelock.dart';
import 'package:wear_camera_remote/mobile/screens/camera_screen.dart';
import 'package:wear_camera_remote/mobile/services/request_permission.dart';
import 'package:wear_camera_remote/wear/screens/camera_remote_screen.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Wakelock.enable();

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

  if (androidInfo.version.release == '12') {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    cameras = await availableCameras();
    RequestPermission requestPermission = RequestPermission();
    await requestPermission.askRequiredPermission();
  }

  runApp(
    CameraRemote(
      release: androidInfo.version.release,
    ),
  );
}

class CameraRemote extends StatelessWidget {
  final String release;

  const CameraRemote({Key? key, required this.release}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: release == '12' ? CameraScreen() : CameraRemoteScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
