package com.lnssh;

import android.app.Activity;

import com.facebook.react.bridge.ReactApplicationContext;
import com.lnssh.dialogs.RCTSplashScreen;

public class LnsshManager {
    public static Activity activity;
    public RCTSplashScreen splashScreen;
    public int drawid;
    public LnsshManager(Activity activity) {
        this.activity = activity;

    }
    public static void splash_show(int drawableId){
        RCTSplashScreen.show(activity,drawableId);
    }
    public static void CheckVersionHost(String hosturl,boolean toastate){
        UpdateManager.checkVersionUpdate(activity,toastate,hosturl);
    }
}
