package com.lnssh;

import android.app.Activity;

import com.facebook.react.ReactPackage;
import com.facebook.react.bridge.JavaScriptModule;
import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.uimanager.ViewManager;
import com.lnssh.ImagePicker.ImagePickerModule;
import com.lnssh.RCTCame.RCTCameraModule;
import com.lnssh.dialogs.RCTSplashScreen;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class LnsshPackage implements ReactPackage{
  private Activity activity;
  private boolean translucent;

  public LnsshPackage() {
    
 }

  public LnsshPackage(Activity activity) {
    super();
     this.activity=activity;
  }
  @Override
  public List<NativeModule> createNativeModules(ReactApplicationContext reactContext) {
    List<NativeModule> modules = new ArrayList<>();
		modules.add(new LnsshModule(reactContext));
		modules.add(new PermissionSetting(reactContext));
        modules.add(new CusToast(reactContext));
        modules.add(new RCTCameraModule(reactContext));
        modules.add(new ImagePickerModule(reactContext));

    return modules;
  }

  // Deprecated in React Native 0.47
  public List<Class<? extends JavaScriptModule>> createJSModules() {
    return Collections.emptyList();
  }

  @Override
  public List<ViewManager> createViewManagers(ReactApplicationContext reactContext) {
    return Collections.emptyList();
  }
}
