package com.rni18nexample;

import android.app.Activity;

import com.facebook.react.ReactActivity;
import com.facebook.react.bridge.ReadableMap;

public class MainActivity extends ReactActivity {
  public static Activity activity;
  /**
     * Returns the name of the main component registered from JavaScript.
     * This is used to schedule rendering of the component.
     */
    @Override
    protected String getMainComponentName() {
      activity = this;
      return "RNI18nExample";
    }

}
