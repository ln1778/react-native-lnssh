package com.lnssh;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Build;
import android.util.Log;

import androidx.core.content.FileProvider;

import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableMap;
import com.lnssh.dialogs.RCTSplashScreen;
import com.lnssh.utils.ConfigurationUtil;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.Base64;

public class LnsshModule extends ReactContextBaseJavaModule implements ActivityEventListener {
  final ReactApplicationContext CONTEXT;
  public static final int REQUEST_SEND_IMAGE = 13001;
  public static final int REQUEST_SEND_TEXT = 13002;
  Activity activity;
  Callback callback;

  public LnsshModule(ReactApplicationContext reactContext) {
    super(reactContext);
	  CONTEXT = reactContext;
  }

  @Override
  public String getName() {
    return "LnsshModule";
  }
  @SuppressLint("NewApi")
	@ReactMethod
	public void goshareToSocial(ReadableMap data, Callback callback){
		this.callback = callback;
		String title=data.getString("title");
		String imageName=data.getString("image");
		final Activity currentActivity = getCurrentActivity();
		Intent send = new Intent(Intent.ACTION_SEND);
		if(imageName!=null){
			File file = null;
			String fileName="share.png";
			BufferedOutputStream bos = null;
			java.io.FileOutputStream fos = null;
			String filePath = ConfigurationUtil.RECORD_PATH_ABSOULT;
			File dir = new File(filePath);
			if (!dir.exists() && !dir.isDirectory()) {
				dir.mkdirs();
			}
			try {
				Base64.Decoder decoder = Base64.getMimeDecoder();
				byte[] bytes = decoder.decode(imageName.getBytes());
				file=new File(filePath+"//"+fileName);
				fos = new java.io.FileOutputStream(file);
				bos = new BufferedOutputStream(fos);
				bos.write(bytes);
				Uri imageUri;
				if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
					imageUri = FileProvider.getUriForFile(this.getReactApplicationContext(), "ch.HmallsChat.app.fileprovider", file);
				} else {
					imageUri = Uri.fromFile(file);
				}
				send.putExtra(Intent.EXTRA_TEXT, title);
				send.putExtra(Intent.EXTRA_STREAM, imageUri);
				send.setType("image/*");
				currentActivity.startActivityForResult(Intent.createChooser(send,"我的分享"),REQUEST_SEND_IMAGE);
			} catch (Exception e) {
				e.printStackTrace();
                callback.invoke(getErrorMap("400",e.getMessage()));
			} finally {
				if (bos != null) {
					try {
						bos.close();
					} catch (IOException e) {
						e.printStackTrace();
					}
				}
				if (fos != null) {
					try {
						fos.close();
					} catch (IOException e) {
						e.printStackTrace();
					}
				}
			}
		}else{
			send.setType("text/plain");
			send.putExtra(Intent.EXTRA_TEXT, title);
			currentActivity.startActivityForResult(Intent.createChooser(send,"我的分享"),REQUEST_SEND_TEXT);
	    }
	}

	@ReactMethod
	public void splash_hide(){
     	RCTSplashScreen.hide();
	}
	@ReactMethod
	public void check_version(String hosturl){
	  UpdateManager.checkVersionUpdate((Context)this.activity,true,hosturl);
	}

	@ReactMethod
	public void isPinCodeWithImage(String uristring, Callback callback){
		Uri uri=Uri.parse(uristring);
		Bitmap bitmap = null;
		try {
			bitmap = BitmapFactory.decodeStream(this.CONTEXT.getContentResolver().openInputStream(uri));
			callback.invoke(null,QRHelper.getReult(bitmap));
		} catch (FileNotFoundException e) {
			callback.invoke(e,null);
			e.printStackTrace();
		}
	}

	static ReadableMap getCancelMap() {
		WritableMap map = Arguments.createMap();
		map.putBoolean("didCancel", true);
		return map;
	}
	static ReadableMap getErrorMap(String errCode, String errMsg) {
		WritableMap map = Arguments.createMap();
		map.putString("errorCode", errCode);
		if (errMsg != null) {
			map.putString("errorMessage", errMsg);
		}
		return map;
	}
	static ReadableMap getTextSuccessMap() {
		WritableMap map = Arguments.createMap();
		map.putBoolean("share_text", true);
		return map;
	}
	static ReadableMap getImageSuccessMap() {
		WritableMap map = Arguments.createMap();
		map.putBoolean("share_image", true);
		return map;
	}
	@Override
	public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data) {
		Log.d("nativemo:requestCode",String.valueOf(requestCode));
		Log.d("nativemo:resultCode",String.valueOf(resultCode));
		switch (requestCode) {
			case REQUEST_SEND_IMAGE:
				callback.invoke(getImageSuccessMap());
			break;
			case REQUEST_SEND_TEXT:
				callback.invoke(getTextSuccessMap());
			break;
		}
	}

  @Override
  public void onNewIntent(Intent intent) {

  }
}
