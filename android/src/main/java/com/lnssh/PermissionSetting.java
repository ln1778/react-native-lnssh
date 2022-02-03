package com.lnssh;

import android.annotation.SuppressLint;
import android.app.AppOpsManager;
import android.app.Application;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.net.Uri;
import android.provider.Settings;


import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import android.os.Environment;


import java.io.File;
import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.math.BigDecimal;



/**
 * Created by linxp on 2017/12/18.
 */
public class PermissionSetting extends ReactContextBaseJavaModule {
    ReactApplicationContext CONTEXT;
   private static final String CHECK_OP_NO_THROW = "checkOpNoThrow";
   private static final String OP_POST_NOTIFICATION = "OP_POST_NOTIFICATION";

    public PermissionSetting(ReactApplicationContext reactContext) {
        super(reactContext);
        CONTEXT = reactContext;


    }

    private static boolean deleteDir(File dir) {
        if (dir != null && dir.isDirectory()) {
            String[] children = dir.list();
            for (int i = 0; i < children.length; i++) {
                boolean success = deleteDir(new File(dir, children[i]));
                if (!success) {
                    return false;
                }
            }
        }
        return dir.delete();
    }

    @Override
    public String getName() {
        return "permissionSetting";
    }

    public static String getFormatSize(double size) {
        double kiloByte = size / 1024;
        if (kiloByte < 1) {
//            return size + "Byte";
            return "0K";
        }

        double megaByte = kiloByte / 1024;
        if (megaByte < 1) {
            BigDecimal result1 = new BigDecimal(Double.toString(kiloByte));
            return result1.setScale(2, BigDecimal.ROUND_HALF_UP)
                    .toPlainString() + "K";
        }

        double gigaByte = megaByte / 1024;
        if (gigaByte < 1) {
            BigDecimal result2 = new BigDecimal(Double.toString(megaByte));
            return result2.setScale(2, BigDecimal.ROUND_HALF_UP)
                    .toPlainString() + "M";
        }

        double teraBytes = gigaByte / 1024;
        if (teraBytes < 1) {
            BigDecimal result3 = new BigDecimal(Double.toString(gigaByte));
            return result3.setScale(2, BigDecimal.ROUND_HALF_UP)
                    .toPlainString() + "GB";
        }
        BigDecimal result4 = new BigDecimal(teraBytes);
        return result4.setScale(2, BigDecimal.ROUND_HALF_UP).toPlainString()
                + "TB";
    }


    public static long getFolderSize(File file) throws Exception {
        long size = 0;
        try {
            File[] fileList = file.listFiles();
            for (int i = 0; i < fileList.length; i++) {
                // 如果下面还有文件
                if (fileList[i].isDirectory()) {
                    size = size + getFolderSize(fileList[i]);
                } else {
                    size = size + fileList[i].length();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return size;
    }
   public static String getTotalCacheSize(Context context) throws Exception {
        long cacheSize = getFolderSize(context.getCacheDir());
        if (Environment.getExternalStorageState().equals(Environment.MEDIA_MOUNTED)) {
            cacheSize += getFolderSize(context.getExternalCacheDir());
        }
        return getFormatSize(cacheSize);
    }

    public static void clearAllCache(Context context) {
        deleteDir(context.getCacheDir());
        if (Environment.getExternalStorageState().equals(Environment.MEDIA_MOUNTED)) {
            deleteDir(context.getExternalCacheDir());
        }
    }
    @SuppressLint("NewApi")
   public static boolean isNotificationEnabled(Context context) {
      AppOpsManager mAppOps = (AppOpsManager) context.getSystemService(Context.APP_OPS_SERVICE);
      ApplicationInfo appInfo = context.getApplicationInfo();
      String pkg = context.getApplicationContext().getPackageName();
      int uid = appInfo.uid;

      Class appOpsClass = null;
      /* Context.APP_OPS_MANAGER */
      try {
         appOpsClass = Class.forName(AppOpsManager.class.getName());
         Method checkOpNoThrowMethod = appOpsClass.getMethod(CHECK_OP_NO_THROW, Integer.TYPE, Integer.TYPE,
               String.class);
         Field opPostNotificationValue = appOpsClass.getDeclaredField(OP_POST_NOTIFICATION);

         int value = (Integer) opPostNotificationValue.get(Integer.class);
         return ((Integer) checkOpNoThrowMethod.invoke(mAppOps, value, uid, pkg) == AppOpsManager.MODE_ALLOWED);

      } catch (ClassNotFoundException e) {
         e.printStackTrace();
      } catch (NoSuchMethodException e) {
         e.printStackTrace();
      } catch (NoSuchFieldException e) {
         e.printStackTrace();
      } catch (InvocationTargetException e) {
         e.printStackTrace();
      } catch (IllegalAccessException e) {
         e.printStackTrace();
      }
      return false;
   }

      @ReactMethod
    public void getCacheSize(final Promise promise){
          String cache= null;
          try {
              cache = getTotalCacheSize(CONTEXT);
          } catch (Exception e) {
              e.printStackTrace();
          }
          promise.resolve(cache);
    }

    @ReactMethod
    public void clearCache(final Promise promise){
        clearAllCache(CONTEXT);
        promise.resolve(true);
    }

    @ReactMethod
    public void goPermission(){
        try{
           Intent intent=new Intent(android.provider.Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
            Uri uri = Uri.fromParts("package", "com.lnssh", null);
            intent.setData(uri);
            CONTEXT.startActivity(intent);
        } catch (Exception e) {//抛出异常就直接打开设置页面
            Intent intent = new Intent(Settings.ACTION_SETTINGS);
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            CONTEXT.startActivity(intent);
        }
    }

    @ReactMethod
    public void goWifi(){
        try{
                Intent intent = new Intent();
                intent.setAction("android.net.wifi.PICK_WIFI_NETWORK");
                CONTEXT.startActivity(intent);
        } catch (Exception e) {//抛出异常就直接打开设置页面
            Intent intent = new Intent(Settings.ACTION_SETTINGS);
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            CONTEXT.startActivity(intent);
        }
    }

    @ReactMethod
    public void getNotification(final Promise promise){
        promise.resolve(isNotificationEnabled(CONTEXT));
    }

}
