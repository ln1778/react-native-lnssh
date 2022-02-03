package com.lnssh.dialogs;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.Dialog;
import android.app.DownloadManager;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.provider.Settings;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.view.WindowManager;
import android.webkit.MimeTypeMap;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

import com.facebook.common.util.Hex;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;
import androidx.annotation.StyleRes;
import androidx.appcompat.app.AlertDialog;
import androidx.core.content.FileProvider;
import androidx.multidex.BuildConfig;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.lang.ref.WeakReference;
import java.security.MessageDigest;

import com.facebook.react.bridge.ReactApplicationContext;
import com.lnssh.DownloadUtil;
import com.lnssh.R;
import com.lnssh.receivers.InstallReceiver;
import com.lnssh.utils.ConfigurationUtil;

/**
 *  A simple string dialog with a "don't show again" checkbox
 *  If the checkbox has not previously been checked, the dialog will be shown, otherwise nothing will happen
 *  Make sure to use a unique tag for this dialog in the show() method
 */
public class VersionDialog  {
    private AlertDialog alertDialog;
    private Activity activity;
    private static String PREF_PREFIX = "dialog_";
    private TextView bt_cancal;
    private boolean isRegisterReceiver;
    private TextView bt_delect;
    private static boolean loading;
    private String content;//版本内容
    private static String tmpPath;
    private String versionName;//版本号
    private static String localPath;
    private static Context context;
    private ProgressBar mProgressBar;
    private LinearLayout btnbox;
    private LinearLayout progressbar_box;
    private static String apkpath;
    private TextView textView;
    private TextView titleView;
    private static String message;
    private static String title;
    private static String hosturl;

    private static String app_has_new;
    private static String app_hash;
    private static int app_android_build;
    private static Dialog mSplashDialog;
    private static WeakReference<Activity> mActivity;
    public static final int ACTIVITY_APP_INSTALL=40006;
    public String has_new;

    public VersionDialog(Activity activity) {
        if (activity == null) return;

        mActivity = new WeakReference<Activity>(activity);

        activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (!activity.isFinishing()) {
                    WindowManager manager = activity.getWindowManager();
                    int height = manager.getDefaultDisplay().getHeight();
                    mSplashDialog = new Dialog(activity,R.style.CustomDialog);
                    mSplashDialog.setContentView(R.layout.versiondialog);
                    mSplashDialog.setCancelable(false);
                    //setCanceledOnTouchOutside(false);
                    //初始化界面控件
                    initView();
                    //初始化界面数据
                    refreshView();
                    //初始化界面控件的事件
                    initEvent();
                }
            }
        });
    }

    public void show() {
        if (!mSplashDialog.isShowing()) {
            mSplashDialog.show();
            Log.d("splash","show");
        }
        refreshView();
    }
    private void refreshView() {
        //如果用户自定了title和message
        if (!TextUtils.isEmpty(message)) {
            textView.setText(message);
        }
        titleView.setText(R.string.version_update);
    }
    /**
     * 初始化界面控件
     */
    private void initView() {
        textView=mSplashDialog.findViewById(R.id.version_content);
        titleView=mSplashDialog.findViewById(R.id.lay_view);
        bt_cancal = mSplashDialog.findViewById(R.id.cancal);
        bt_delect = mSplashDialog.findViewById(R.id.update);
        mProgressBar = (ProgressBar)mSplashDialog.findViewById(R.id.version_progressbar);
        progressbar_box= (LinearLayout)mSplashDialog.findViewById(R.id.version_progressbar_box);
        btnbox=(LinearLayout)mSplashDialog.findViewById(R.id.btnbox);

    }  /**
     * 初始化界面的确定和取消监听器
     */
    private void initEvent() {
        bt_cancal.setOnClickListener(this::onClick);
        bt_delect.setOnClickListener(this::onClick);
    }

    public VersionDialog setMessage(String message) {
        this.message = message;
        return this ;
    }
    public VersionDialog setHostUrl(String url) {
        this.hosturl = url;
        return this ;
    }

    public String getMessage() {
        return message;
    }
    public String getHash() {
        return app_hash;
    }
    public VersionDialog setHash(String hash) {
        this.app_hash = hash;
        return this ;
    }
    public String getHasNew() {
        return app_has_new;
    }
    public VersionDialog setgetHasNew(String has_new) {
        this.app_has_new = has_new;
        return this ;
    }
    public int getAppAndroidBuild() {
        return app_android_build;
    }
    public VersionDialog setAppAndroidBuild(int android_build) {
        this.app_android_build = android_build;
        return this ;
    }
    public void onClick(View v) {
      int id = v.getId();
      if (id == R.id.update) {
        Log.d("has_new", app_has_new);
        if (app_has_new != null) {
          if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            boolean hasInstallPermission = this.activity.getPackageManager().canRequestPackageInstalls();
            Log.d("hasInstallPermission", String.valueOf(hasInstallPermission));
            if (!hasInstallPermission) {
              startInstallPermissionSettingActivity();
            } else {
              downapk();
            }
          } else {
            if (this.has_new.equals("1")) {
              downbundle();
            } else {
              downapk();
            }
            btnbox.setVisibility(View.GONE);
          }
        }
        //this.dismiss();

        // 取消按钮
      } else if (id == R.id.cancal) {
        hide_dialog();
      }
    }
    public void hide_dialog(){
        if (activity == null) activity = mActivity.get();
        if (activity == null) return;
        activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (mSplashDialog != null && mSplashDialog.isShowing()) {
                    Log.d("versiondialog","hide111");
                    mSplashDialog.dismiss();
                    mSplashDialog=null;
                }
            }
        });
    }
  @RequiresApi(api = Build.VERSION_CODES.O)
  public void startInstallPermissionSettingActivity() {
    Log.d("startSettingActivity","start");
    Uri packageURI = Uri.parse("package:" + BuildConfig.APPLICATION_ID);
    Intent intent = new Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES, packageURI);
    this.activity.startActivityForResult(intent, ACTIVITY_APP_INSTALL);
  }
    public void downapk(){
        progressbar_box.setVisibility(View.VISIBLE);
        String downloadUrl =this.hosturl;
        Log.d("TAG", "download:" + downloadUrl);
        VersionDialog _this=this;
        DownloadUtil.getInstance().download(downloadUrl, ConfigurationUtil.APK_PATH_ABSOULT+"lnssh.apk", new DownloadUtil.OnDownloadListener() {
            @Override
            public void onDownloadSuccess(String path) {
                try {
                    File f = new File(path);
                    Log.d("apkpath:",path);
                    //Log.d("test",ha);
                    installAPK(f, context);
                    progressbar_box.setVisibility(View.GONE);
                    hide_dialog();
                    Toast.makeText(context, R.string.update_success_install, Toast.LENGTH_LONG).show();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
            @Override
            public void onDownloading(int progress) {
                Log.d("progress",String.valueOf(progress));
                mProgressBar.setProgress(progress);
                loading=false;
            }
            @Override
            public void onDownloadFailed() {
                Log.d("error","下载失败");
                loading=false;
                progressbar_box.setVisibility(View.GONE);
                hide_dialog();
                Toast.makeText(context, R.string.update_failed, Toast.LENGTH_LONG).show();
            }
        });
    }
    public void installAPK(File f,Context context){
        if (Build.VERSION.SDK_INT < 23) {
            Intent intents = new Intent();
            intents.setAction(Intent.ACTION_VIEW);
//                intents.addCategory("android.intent.category.DEFAULT");
            Uri files= Uri.fromFile(f);
            intents.setDataAndType(files, "application/vnd.android.package-archive");
            intents.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            context.startActivity(intents);
        } else if (Build.VERSION.SDK_INT >= 24) {
            install(context,f);
        } else {
            if (f.exists()) {
                openFile(f, context);
            } else {
            }
        }
    }
    public void install(Context context,File file){
        Intent intent = new Intent(Intent.ACTION_VIEW);
        Uri apkUri = FileProvider.getUriForFile(context, "com.lnssh.fileprovider", file);


//			Uri apkUri=Uri.parse("file://" + filePath);
        intent.addCategory("android.intent.category.DEFAULT");
        // 由于没有在Activity环境下启动Activity,设置下面的标签
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        //添加这一句表示对目标应用临时授权该Uri所代表的文件
        intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
        intent.setDataAndType(apkUri, "application/vnd.android.package-archive");
        context.startActivity(intent);
    }
    public void openFile(File file, Context context) {
        Intent intent = new Intent();
        intent.addFlags(268435456);
        intent.setAction("android.intent.action.VIEW");
        String type = getMIMEType(file);
        intent.setDataAndType(Uri.fromFile(file), type);
        try {
            context.startActivity(intent);
        } catch (Exception var5) {
            var5.printStackTrace();
            Toast.makeText(context, R.string.no_find_apk, Toast.LENGTH_SHORT).show();
        }
    }

    public String getMIMEType(File var0) {
        String var1 = "";
        String var2 = var0.getName();
        String var3 = var2.substring(var2.lastIndexOf(".") + 1, var2.length()).toLowerCase();
        var1 = MimeTypeMap.getSingleton().getMimeTypeFromExtension(var3);
        return var1;
    }
    public void downbundle(){
        tmpPath = this.activity.getApplicationContext().getFilesDir().getAbsolutePath() + "/tmp_bundle";
        localPath =this.activity.getApplicationContext().getFilesDir().getAbsolutePath() + "/bundle";
        progressbar_box.setVisibility(View.VISIBLE);
        String downloadUrl = this.hosturl;
        Log.d("TAG", "download:" + downloadUrl);
        Toast.makeText(context, R.string.back_install, Toast.LENGTH_LONG).show();
        VersionDialog _this=this;
        DownloadUtil.getInstance().download(downloadUrl, tmpPath, new DownloadUtil.OnDownloadListener() {
            @Override
            public void onDownloadSuccess(String path) {
                try {
                    File f = new File(path);
                    String ha= getHash(path,"MD5");
                    //Log.d("test",ha);
                    if(!ha.equals(app_hash)){
                        Toast.makeText(context,"hash error:"+ha+"!="+app_hash, Toast.LENGTH_LONG).show();
                        //promise.reject("400","hash error:"+ha+"!="+last_version.get("hash"));
                        return;
                    }
                    f.renameTo(new File(localPath + "/" + f.getName()));
                    saveLocalVersion(app_android_build);
                    progressbar_box.setVisibility(View.GONE);
                    hide_dialog();

                    Toast.makeText(context, R.string.update_success, Toast.LENGTH_LONG).show();

                } catch (JSONException e) {
                    e.printStackTrace();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
            @Override
            public void onDownloading(int progress) {
                Log.d("progress",String.valueOf(progress));
                mProgressBar.setProgress(progress);
                loading=false;
            }
            @Override
            public void onDownloadFailed() {
                loading=false;
                progressbar_box.setVisibility(View.GONE);
                hide_dialog();
                Toast.makeText(context, R.string.update_failed, Toast.LENGTH_LONG).show();
            }
        });
    }
    private String getHash(String fileName, String hashType) throws Exception {
        InputStream fis = new FileInputStream(fileName);
        byte buffer[] = new byte[1024];
        MessageDigest md5 = MessageDigest.getInstance(hashType);
        for (int numRead = 0; (numRead = fis.read(buffer)) > 0; ) {
            md5.update(buffer, 0, numRead);
        }
        fis.close();
        return Hex.encodeHex(md5.digest(),false);
    }
    public void saveLocalVersion(int newV) {
        SharedPreferences sp =this.activity.getSharedPreferences("local_version", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sp.edit();
        editor.putInt("local_v", newV);
        editor.commit();
        Log.d("TAG", "save v :" + newV);
    }
}
