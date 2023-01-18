package com.example.wear_camera_remote;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.view.InputDeviceCompat;
import androidx.core.view.MotionEventCompat;
import androidx.core.view.ViewConfigurationCompat;
import androidx.wear.input.WearableButtons;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

import android.content.Context;
import android.util.AttributeSet;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewConfiguration;

import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.wearable.Node;
import com.google.android.gms.wearable.NodeApi;
import com.google.android.gms.wearable.Wearable;

import java.util.List;
import java.util.concurrent.TimeUnit;

public class MainActivity extends FlutterActivity {
    private static final String APP_OPEN_CHANNEL = "iniyan.com/appOpen";
    private static final String PHYSICAL_BUTTONS_CHANNEL = "iniyan.com/physicalButton";
    private static final String MOBILE_PATH = "/mobile";
    private static final int CONNECTION_TIME_OUT_MS = 100;
    private GoogleApiClient googleApiClient;
    private String nodeId;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
//        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), APP_OPEN_CHANNEL)
//                .setMethodCallHandler(
//                        (call, result) -> {
//                            System.out.println("configureFlutterEngine is called");
//                            if (call.method.equals("openAppOnPhone")) {
//                                openAppOnPhone();
//                            } else {
//                                result.notImplemented();
//                            }
//                        }
//                );
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), PHYSICAL_BUTTONS_CHANNEL).setMethodCallHandler(
                (call, result) -> {
                    System.out.println("configureFlutterEngine is called with" + PHYSICAL_BUTTONS_CHANNEL);
                    if (call.method.equals("getWearablePhysicalButtons")) {
                        getWearablePhysicalButtons();
                    } else {
                        result.notImplemented();
                    }
                }
        );
    }

    public void getWearablePhysicalButtons() {
        int count = WearableButtons.getButtonCount(this);
        System.out.println("No of Buttons: " + count);
//        WearableButtons.ButtonInfo buttonInfo1 = WearableButtons.getButtonInfo(getActivity(), KeyEvent.KEYCODE_STEM_1);
//        WearableButtons.ButtonInfo buttonInfo2 = WearableButtons.getButtonInfo(getActivity(), KeyEvent.KEYCODE_STEM_2);
//        WearableButtons.ButtonInfo buttonInfo3 = WearableButtons.getButtonInfo(getActivity(), KeyEvent.KEYCODE_STEM_3);
//        assert buttonInfo1 != null;
//        System.out.println(buttonInfo1.getKeycode());
//        assert buttonInfo2 != null;
//        System.out.println(buttonInfo2.getKeycode());
//        assert buttonInfo3 != null;
//        System.out.println(buttonInfo3.getKeycode());
        View myView = new MyView(this);
        System.out.println(myView.isFocusable());
        myView.setFocusable(true);
        System.out.println(myView.isFocusable());
        myView.requestFocus();
        myView.setOnGenericMotionListener((view, motionEvent) -> {
            if (motionEvent.getAction() == MotionEvent.ACTION_SCROLL &&
                    motionEvent.isFromSource(InputDeviceCompat.SOURCE_ROTARY_ENCODER)
            ) {
                System.out.println("Found Some Rotation");
//                     Don't forget the negation here
//                    float delta = -motionEvent.getAxisValue(MotionEventCompat.AXIS_SCROLL) *
//                            ViewConfigurationCompat.getScaledVerticalScrollFactor(
//                                    ViewConfiguration.get(context), context
//                            );

//                     Swap these axes to scroll horizontally instead
//                    view.scrollBy(0, Math.round(delta));

                return true;
            }
            return false;
        });
    }

    @Override
// Activity
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (event.getRepeatCount() == 0) {
            if (keyCode == KeyEvent.KEYCODE_STEM_1) {
                System.out.println("Key Pressed : " + keyCode);
                return true;
            } else if (keyCode == KeyEvent.KEYCODE_STEM_2) {
                System.out.println("Key Pressed : " + keyCode);
                return true;
            } else if (keyCode == KeyEvent.KEYCODE_STEM_3) {
                System.out.println("Key Pressed : " + keyCode);
                return true;
            }
            System.out.println("Key Pressed OutSide : " + keyCode);
        }
        return super.onKeyDown(keyCode, event);
    }

//    public void openAppOnPhone() {
//        System.out.println("openAppOnPhone is called");
//        initGoogleApiClient();
////        sendMessageToPhone();
//    }
//
//    private void initGoogleApiClient() {
//        System.out.println("initGoogleApiClient is called");
//        googleApiClient = getGoogleApi(this);
//        retrieveDeviceNode();
//    }
//
//    private GoogleApiClient getGoogleApi(Context context) {
//        return new GoogleApiClient.Builder(context).addApi(Wearable.API).build();
//    }
//
//    private void retrieveDeviceNode() {
//        new Thread(new Runnable() {
//            @Override
//            public void run() {
//
//                System.out.println("retrieveDeviceNode is called");
//                if (googleApiClient != null && !(googleApiClient.isConnected() || googleApiClient.isConnecting()))
//                    googleApiClient.blockingConnect(CONNECTION_TIME_OUT_MS, TimeUnit.MILLISECONDS);
//
//                System.out.println("retrieveDeviceNode middle");
//
//                if (googleApiClient != null) {
//                    NodeApi.GetConnectedNodesResult result = Wearable.NodeApi.getConnectedNodes(googleApiClient).await();
//                    List<Node> nodes = result.getNodes();
//                    if (nodes.size() > 0) {
//                        nodeId = nodes.get(0).getId();
//                        System.out.println(nodeId);
//                        String nodeName = nodes.get(0).getDisplayName();
//                        System.out.println(nodeName);
//                    }
//                    googleApiClient.disconnect();
//                }
//                System.out.println("sendMessageToPhone is called ");
//                if (googleApiClient != null && !(googleApiClient.isConnected() || googleApiClient.isConnecting()))
//                    googleApiClient.blockingConnect(CONNECTION_TIME_OUT_MS, TimeUnit.MILLISECONDS);
//
//                if (googleApiClient != null) {
//                    Wearable.MessageApi.sendMessage(googleApiClient, nodeId, MOBILE_PATH, null);
//                    googleApiClient.disconnect();
//                }
//                System.out.println("prog over");
//            }
//        }).start();
//    }
}

class MyView extends View {

    public MyView(Context context) {
        super(context);
    }
}
