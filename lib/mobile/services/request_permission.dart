import 'package:permission_handler/permission_handler.dart';

class RequestPermission {
  Future<void> askRequiredPermission() async {
    Permission permissionCamera = Permission.camera;
    // Permission permissionLocationWIU = Permission.locationWhenInUse;
    // Permission permissionBluetooth = Permission.bluetooth;
    // Permission permissionBluetoothScan = Permission.bluetoothScan;
    // Permission permissionBluetoothAdvertise = Permission.bluetoothAdvertise;
    // Permission permissionBluetoothConnect = Permission.bluetoothConnect;
    // Permission permissionStorage = Permission.storage;
    await permissionCamera.request();
    // await permissionLocationWIU.request();
    // await permissionBluetooth.request();
    // await permissionBluetoothScan.request();
    // await permissionBluetoothAdvertise.request();
    // await permissionBluetoothConnect.request();
    // await permissionStorage.request();
  }
}
