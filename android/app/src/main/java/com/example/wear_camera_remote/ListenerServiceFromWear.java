package com.example.wear_camera_remote;

import android.content.Intent;
import androidx.annotation.NonNull;
import com.google.android.gms.wearable.MessageEvent;
import com.google.android.gms.wearable.WearableListenerService;

public class ListenerServiceFromWear extends WearableListenerService {
    private static final String CAMERA_REMOTE_PATH = "/mobile";

    @Override
    public void onMessageReceived(@NonNull MessageEvent messageEvent) {
        System.out.println("I AM CALLED!!! NOOOO WAYY");
        if (messageEvent.getPath().equals(CAMERA_REMOTE_PATH)) {
            Intent startIntent = new Intent(this, MainActivity.class);
            startIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            startActivity(startIntent);
        }
    }
}
