package com.lnssh;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.provider.MediaStore;
import android.provider.Settings;
import android.text.TextUtils;
import android.util.Base64;
import android.util.Log;
import com.facebook.common.util.Hex;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.CatalystInstance;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.ReadableNativeMap;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableNativeMap;

import java.io.BufferedOutputStream;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.lang.String;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import java.io.File;
import java.io.IOException;
import java.net.URL;
import java.security.MessageDigest;
import java.util.UUID;

import com.lnssh.R;
import com.lnssh.dialogs.VersionDialog;
import com.lnssh.utils.ConfigurationUtil;
import com.lnssh.utils.RuntimeUtil;
import com.lnssh.utils.Tools;
import okhttp3.Call;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;

import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.facebook.react.bridge.Callback;

import android.content.ServiceConnection;
import android.content.ComponentName;
import android.os.IBinder;
import android.view.View;
import android.widget.RelativeLayout;
import android.widget.Toast;
import androidx.annotation.Nullable;
import androidx.fragment.app.FragmentManager;

public class UpdateManager extends ReactContextBaseJavaModule {
    public static final String TAG = "update_mm";
    private static ReactContext myContext;
    private JSONObject last_version;
    private String localPath;
    private static ServiceConnection connection;
    private static long mDownLoadId;
    private String tmpPath;
    private static Callback dialogback;
    private static boolean loading;
    private static String filePath;
    private static Bitmap mBitmap;
    private static File mPhotoFile = null;
    private static boolean flag;
    private static boolean iconflag;
    private static Toast toast;
    private static WritableArray dappData;
    private static WritableArray iconData;
    public static Activity activity;
    private static ReactApplicationContext appContext;
    private static VersionDialog versionDialog;


	public UpdateManager(ReactApplicationContext reactContext) {
        super(reactContext);
	  	myContext=reactContext;
        this.appContext=reactContext;
        localPath = reactContext.getApplicationContext().getFilesDir().getAbsolutePath() + "/bundle";
        tmpPath = reactContext.getApplicationContext().getFilesDir().getAbsolutePath() + "/tmp_bundle";

        File f = new File(localPath);
        if (!f.exists()) {
            f.mkdirs();
        }
        connection = new ServiceConnection() {
            @Override
            public void onServiceConnected(ComponentName name, IBinder service) {

            }

            @Override
            public void onServiceDisconnected(ComponentName name) {

            }
        };
        loading=false;
    }

	@ReactMethod
	public void exitApp() {
		System.exit(0);
	}
	@ReactMethod
	public void toast(String text) {
    	if(text!=null&&!text.equals("")){
			Toast.makeText(myContext,text, Toast.LENGTH_LONG).show();
		}
	}

	public static void sendEvent(
						   String eventName,
						   @Nullable WritableMap params) {
		myContext
			.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
			.emit(eventName, params);
	}
    @Override
    public String getName() {
        return "UpdateManager";
    }
    @ReactMethod
    public void open(String type) {
        if (type.equals("1")) {
            MobileInfoUtils.jumpStartInterface(myContext);
        } else {
            Intent intent;
            try {
                intent = new Intent(android.provider.Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
				myContext.startActivity(intent);
            } catch (Exception e) {//抛出异常就直接打开设置页面
                intent = new Intent(Settings.ACTION_SETTINGS);
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                myContext.startActivity(intent);
            }
        }
    }
}
