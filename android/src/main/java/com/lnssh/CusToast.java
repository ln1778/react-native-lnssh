package com.lnssh;

import android.app.Activity;
import android.content.Context;
import android.widget.Toast;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;

class CusToast extends ReactContextBaseJavaModule {
  Context myContext;
  public CusToast(ReactApplicationContext reactContext) {
    this.myContext = reactContext;
  }
    @Override
    public String getName() {
        return "Toast";
    }
 public void info(String text){
    if(text!=null&&!text.equals("")){
        Toast.makeText(myContext,text, Toast.LENGTH_LONG).show();
    }
 }

}
