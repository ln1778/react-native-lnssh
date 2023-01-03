package com.lnssh;

import static com.facebook.imageutils.HeifExifUtil.TAG;

import android.Manifest;
import android.annotation.SuppressLint;
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
import android.telephony.TelephonyManager;
import android.util.Log;

import androidx.core.app.ActivityCompat;
import androidx.annotation.RequiresApi;
import androidx.core.content.FileProvider;

import com.facebook.common.util.Hex;
import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableNativeMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.lnssh.dialogs.RCTSplashScreen;
import com.lnssh.utils.ConfigurationUtil;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;

import android.os.Environment;
import android.provider.MediaStore;
import android.provider.Settings;
import android.text.TextUtils;
import android.webkit.MimeTypeMap;
import android.widget.Toast;

import com.facebook.react.bridge.Promise;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.FileOutputStream;
import java.io.InputStream;
import java.lang.String;
import java.net.URL;
import java.security.MessageDigest;
import java.util.Base64;
import java.util.UUID;

import okhttp3.Call;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;

public class LnsshModule extends ReactContextBaseJavaModule implements ActivityEventListener {
	final ReactApplicationContext CONTEXT;
	public static final int REQUEST_SEND_IMAGE = 13001;
	public static final int REQUEST_SEND_TEXT = 13002;
	public static final int REQUEST_INSTALL = 21000;


	JSONObject last_version;
	String localPath;
	String tmpPath;
	Promise callback;
	private static Bitmap mBitmap;
	private static ReactContext myContext;
	boolean loading;
	public Promise downpromise;
	public Promise openpromise;
	int progressnum = 0;

	public LnsshModule(ReactApplicationContext reactContext) {
		super(reactContext);
		CONTEXT = reactContext;
		myContext = reactContext;
	}

	@Override
	public String getName() {
		return "LnsshModule";
	}

	@RequiresApi(api = Build.VERSION_CODES.O)
	public void startInstallPermissionSettingActivity() {
		//   Uri packageURI = Uri.parse("package:" + BuildConfig.APPLICATION_ID);
		Uri packageURI = Uri.fromParts("package", CONTEXT.getApplicationContext().getPackageName(), null);
		Intent intent = new Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES, packageURI);
		this.CONTEXT.startActivityForResult(intent, REQUEST_INSTALL, null);
	}

	@SuppressLint("NewApi")
	@ReactMethod
	public void goshareToSocial(ReadableMap data, final Promise promise) {
		this.callback = promise;
		String title = data.getString("title");
		String imageName = data.getString("image");
		final Activity currentActivity = getCurrentActivity();
		Intent send = new Intent(Intent.ACTION_SEND);
		if (imageName != null) {
			File file = null;
			String fileName = "share.png";
			BufferedOutputStream bos = null;
			java.io.FileOutputStream fos = null;
			String filePath = ConfigurationUtil.RECORD_PATH_ABSOULT;
			File appDir = new File(Environment.getExternalStorageDirectory(), "/DCIM/Camera");
			//File dir = new File(filePath);
			if (!appDir.exists() && !appDir.isDirectory()) {
				appDir.mkdirs();
			}
			if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
				boolean hasInstallPermission = this.getReactApplicationContext().getPackageManager().canRequestPackageInstalls();
				Log.d("hasInstallPermission", String.valueOf(hasInstallPermission));
				if (!hasInstallPermission) {
					startInstallPermissionSettingActivity();
				} else {
					try {
						Base64.Decoder decoder = Base64.getMimeDecoder();
						byte[] bytes = decoder.decode(imageName.getBytes());
						file = new File(appDir, fileName);
						fos = new java.io.FileOutputStream(file);
						bos = new BufferedOutputStream(fos);
						bos.write(bytes);
						Uri imageUri;
						if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
							imageUri = FileProvider.getUriForFile(this.getReactApplicationContext(), this.myContext.getApplicationContext().getPackageName() + ".fileprovider", file);
						} else {
							imageUri = Uri.fromFile(file);
						}
						send.putExtra(Intent.EXTRA_TEXT, title);
						send.putExtra(Intent.EXTRA_STREAM, imageUri);
						send.setType("image/*");
						currentActivity.startActivityForResult(Intent.createChooser(send, "我的分享"), REQUEST_SEND_IMAGE);
					} catch (Exception e) {
						e.printStackTrace();
						this.callback.resolve(getErrorMap("400", e.getMessage()));
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
				}
			}
		} else {
			send.setType("text/plain");
			send.putExtra(Intent.EXTRA_TEXT, title);
			currentActivity.startActivityForResult(Intent.createChooser(send, "我的分享"), REQUEST_SEND_TEXT);
		}
	}

	@ReactMethod
	public void splash_show() {
		RCTSplashScreen.native_show();
	}

	@ReactMethod
	public void splash_hide() {
		RCTSplashScreen.hide();
	}

	@ReactMethod
	public void checkUpdate(String hostutl, final Promise promise) {
		OkHttpClient mOkHttpClient = new OkHttpClient();
		//创建一个Request
		final Request request = new Request.Builder()
				.url(hostutl)
				.build();
		//new call
		Call call = mOkHttpClient.newCall(request);
		//请求加入调度
		call.enqueue(new okhttp3.Callback() {
			@Override
			public void onFailure(Call call, IOException e) {
			}

			@Override
			public void onResponse(Call call, Response response) throws IOException {
				String rs = response.body().string();
				JSONObject datas = null;
				try {
					datas = new JSONObject(rs);
					Log.d(TAG, rs);
					Log.d(TAG, "rs:" + rs);
					last_version = datas;
					int llv = getLocalVersion();
					int serverV = datas.getInt("android_build");
					int qlserverV = datas.getInt("android_ql_build");

					int localV = LnsshModule.this.getVersionCode(LnsshModule.this.getReactApplicationContext());
					Log.d(TAG, "server v :" + serverV + " localV:" + localV + " llv:" + llv);
					if (localV < llv) {
						localV = llv;
					}
					WritableNativeMap map = new WritableNativeMap();
					if (qlserverV > localV) {
						map.putString("has_new", "2");
						map.putString("down_url", datas.getString("android_ql_url"));
					} else if (serverV > localV) {
						map.putString("has_new", "1");
						map.putString("down_url", datas.getString("android_url"));
					} else {
						map.putString("has_new", "0");
					}
					if (datas.getString("content") != null && !datas.getString("content").equals("")) {
						String content = datas.getString("content");
						map.putString("content", content);
					}

					promise.resolve(map);
				} catch (JSONException e) {
					e.printStackTrace();
					promise.reject("400", e.getMessage());
				}
			}
		});
	}

	private static String getHash(String fileName, String hashType) throws Exception {
		InputStream fis = new FileInputStream(fileName);
		byte buffer[] = new byte[1024];
		MessageDigest md5 = MessageDigest.getInstance(hashType);
		for (int numRead = 0; (numRead = fis.read(buffer)) > 0; ) {
			md5.update(buffer, 0, numRead);
		}
		fis.close();
		return Hex.encodeHex(md5.digest(), false);
	}

	@RequiresApi(api = Build.VERSION_CODES.O)
	@ReactMethod
	public void isInstallPermission(final Promise promise) {
		boolean hasInstallPermission = myContext.getPackageManager().canRequestPackageInstalls();
		if (!hasInstallPermission) {
			promise.reject("400", "第三方安装权限未打开");
			Toast.makeText(myContext, "第三方安装权限未打开", Toast.LENGTH_LONG).show();
		} else {
			promise.resolve("true");
		}
	}

	@RequiresApi(api = Build.VERSION_CODES.O)
	@ReactMethod
	public void openInstallPermission(final Promise promise) {
		openpromise = promise;
		startInstallPermissionSettingActivity();
	}

	@ReactMethod
	private void restartApp() {
		final Intent intent = myContext.getPackageManager().getLaunchIntentForPackage(myContext.getPackageName());
		intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
		myContext.startActivity(intent);

	}

	@ReactMethod
	public void downloadNew(String has_new, final Promise promise) {
		downpromise = promise;
		if (loading) {
			return;
		}
		loading = true;
		try {
			if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
				boolean hasInstallPermission = myContext.getPackageManager().canRequestPackageInstalls();
				Log.d("hasInstallPermission", String.valueOf(hasInstallPermission));
				if (!hasInstallPermission) {
					startInstallPermissionSettingActivity();
					promise.reject("400", "权限未打开");
				} else {
					if (has_new.equals("1")) {
						downbundle(last_version.getString("android_url"));
					} else {
						downapk(last_version.getString("android_ql_url"), last_version.getString("apk_name"));
					}
				}
			} else {
				Log.d("hasInstallPermission", has_new);
				if (has_new.equals("1")) {
					downbundle(last_version.getString("android_url"));
				} else {
					downapk(last_version.getString("android_ql_url"), last_version.getString("apk_name"));
				}
			}

		} catch (JSONException e) {
			e.printStackTrace();
		}
	}

	public void downbundle(String hosturl) {
		tmpPath = myContext.getApplicationContext().getFilesDir().getAbsolutePath() + "/tmp_bundle";
		localPath = myContext.getApplicationContext().getFilesDir().getAbsolutePath() + "/bundle";
		Log.d("TAG", "download:" + hosturl);
		Toast.makeText(myContext, R.string.back_install, Toast.LENGTH_LONG).show();
		DownloadUtil.getInstance().download(hosturl, tmpPath, new DownloadUtil.OnDownloadListener() {
			@Override
			public void onDownloadSuccess(String path) {
				try {
					File f = new File(path);
					String ha = getHash(path, "MD5");
					//Log.d("test",ha);
					if (!ha.equals(last_version.get("hash"))) {
						Toast.makeText(myContext, "hash error:" + ha + "!=" + last_version.get("hash"), Toast.LENGTH_LONG).show();
						downpromise.reject("400", "hash error:" + ha + "!=" + last_version.get("hash"));
						return;
					}
					f.renameTo(new File(localPath + "/" + f.getName()));
					saveLocalVersion(last_version.getInt("android_build"));
					downpromise.resolve("更新成功，下次启动即可生效");
					downpromise = null;
					//Toast.makeText(myContext, R.string.update_success, Toast.LENGTH_LONG).show();

				} catch (JSONException e) {
					e.printStackTrace();
					downpromise.reject("400", "下载失败");
					downpromise = null;
				} catch (Exception e) {
					e.printStackTrace();
					downpromise.reject("400", "下载失败");
					downpromise = null;
				}
			}

			@Override
			public void onDownloading(int progress) {
				Log.d("progress", String.valueOf(progress));
				myContext
						.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
						.emit("update_progress", String.valueOf(progress));
				loading = false;
			}

			@Override
			public void onDownloadFailed() {
				loading = false;
				downpromise.reject("400", "下载失败");
				downpromise = null;
				Toast.makeText(myContext, R.string.update_failed, Toast.LENGTH_LONG).show();
			}
		});
	}

	@ReactMethod
	public void InstallApk(String path, final Promise promise) {
		downpromise = promise;
		File f = new File(path);
		Log.d("apkpath:", path);
		//Log.d("test",ha);
		myinstallAPK(f);
	}

	@ReactMethod
	public void getPhoneNumber(final Promise promise) {
		try {
			TelephonyManager tm = (TelephonyManager) myContext.getSystemService(Context.TELEPHONY_SERVICE);

			String deviceid = tm.getDeviceId();

			if (ActivityCompat.checkSelfPermission(myContext, Manifest.permission.READ_SMS) != PackageManager.PERMISSION_GRANTED && ActivityCompat.checkSelfPermission(myContext, Manifest.permission.READ_PHONE_NUMBERS) != PackageManager.PERMISSION_GRANTED && ActivityCompat.checkSelfPermission(myContext, Manifest.permission.READ_PHONE_STATE) != PackageManager.PERMISSION_GRANTED) {
				promise.reject("400","权限不足");
			}else{
				String tel = tm.getLine1Number();//手机号码

				String imei = tm.getSimSerialNumber();

				String imsi = tm.getSubscriberId();
				WritableMap phonedata= Arguments.createMap();
				phonedata.putString("phoneNumber",tel);
				phonedata.putString("smsNumber",imei);
				phonedata.putString("smsId",imsi);
				phonedata.putString("deviceId",deviceid);
				promise.resolve(phonedata);
			}
		}catch (Exception e){
			promise.reject("400",e.getMessage());
		}
	}

	public void downapk(String hosturl,String apk_name){
		Log.d("TAG", "download:" + hosturl);

		String appDir =ConfigurationUtil.APK_PATH_ABSOULT+apk_name;
		DownloadUtil.getInstance().download(hosturl, appDir, new DownloadUtil.OnDownloadListener() {
			@Override
			public void onDownloadSuccess(String path) {
				if(progressnum==100){
					try {
						downpromise.resolve(path);
						downpromise=null;
						//Toast.makeText(myContext, R.string.update_success_install, Toast.LENGTH_LONG).show();
						progressnum=0;
						loading=false;
					} catch (Exception e) {
						progressnum=0;
						downpromise.reject("400","下载失败");
						downpromise=null;
						e.printStackTrace();
						loading=false;
					}
				}
			}
			@Override
			public void onDownloading(int progress) {
				Log.d("progress",String.valueOf(progress));
				progressnum =progress;
				myContext
						.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
						.emit("update_progress", String.valueOf(progress));

			}
			@Override
			public void onDownloadFailed() {
				Log.d("error","下载失败");
				loading=false;
				Toast.makeText(myContext, R.string.update_failed, Toast.LENGTH_LONG).show();
				downpromise.reject("400","下载失败");
				downpromise=null;
			}
		});
	}

	public void myinstallAPK(File f){
		if (Build.VERSION.SDK_INT < 23) {
			Intent intents = new Intent();
			intents.setAction(Intent.ACTION_VIEW);
//                intents.addCategory("android.intent.category.DEFAULT");
			Uri files= Uri.fromFile(f);
			intents.setDataAndType(files, "application/vnd.android.package-archive");
			intents.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
			downpromise.resolve("更新成功，下次启动即可生效");
			downpromise=null;
			myContext.startActivity(intents);

		} else if (Build.VERSION.SDK_INT >= 24) {
			install(f);
		} else {
			if (f.exists()) {
				openFile(f);
			} else {
			}
		}
	}
	public void install(File file){
		Intent intent = new Intent(Intent.ACTION_VIEW);
		Uri apkUri = FileProvider.getUriForFile(myContext, myContext.getApplicationContext().getPackageName()+".fileprovider", file);


//			Uri apkUri=Uri.parse("file://" + filePath);
		intent.addCategory("android.intent.category.DEFAULT");
		// 由于没有在Activity环境下启动Activity,设置下面的标签
		intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
		//添加这一句表示对目标应用临时授权该Uri所代表的文件
		intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
		intent.setDataAndType(apkUri, "application/vnd.android.package-archive");
		downpromise.resolve("更新成功，下次启动即可生效");
		downpromise=null;
		myContext.startActivity(intent);

	}
	public void openFile(File file) {
		Intent intent = new Intent();
		intent.addFlags(268435456);
		intent.setAction("android.intent.action.VIEW");
		String type = getMIMEType(file);
		intent.setDataAndType(Uri.fromFile(file), type);
		try {
			downpromise.resolve("更新成功，下次启动即可生效");
			downpromise=null;
			myContext.startActivity(intent);
		} catch (Exception var5) {
			var5.printStackTrace();
			downpromise.reject("400","安装失败");
			downpromise=null;
			Toast.makeText(myContext, R.string.no_find_apk, Toast.LENGTH_SHORT).show();
		}
	}

	public String getMIMEType(File var0) {
		String var1 = "";
		String var2 = var0.getName();
		String var3 = var2.substring(var2.lastIndexOf(".") + 1, var2.length()).toLowerCase();
		var1 = MimeTypeMap.getSingleton().getMimeTypeFromExtension(var3);
		return var1;
	}
	public void saveLocalVersion(int newV) {
		SharedPreferences sp = LnsshModule.this.getCurrentActivity().getSharedPreferences("local_version", Context.MODE_PRIVATE);
		SharedPreferences.Editor editor = sp.edit();
		editor.putInt("local_v", newV);
		editor.commit();
		Log.d(TAG, "save v :" + newV);
	}
	public int getLocalVersion() {
		SharedPreferences sp = LnsshModule.this.getCurrentActivity().getSharedPreferences("local_version", Context.MODE_PRIVATE);
		int v = sp.getInt("local_v", 0);
		return v;
	}


	public int getVersionCode(Context context) {
		PackageManager packageManager = context.getPackageManager();
		PackageInfo packageInfo;
		int versionCode = 0;
		try {
			packageInfo = packageManager.getPackageInfo(context.getPackageName(), 0);
			versionCode = packageInfo.versionCode;
		} catch (PackageManager.NameNotFoundException e) {
			e.printStackTrace();
		}
		return versionCode;
	}
	@ReactMethod
	public void isPinCodeWithImage(String uristring, Callback callback){
		Uri uri=Uri.parse(uristring);
		Bitmap bitmap = null;
		try {
			bitmap = BitmapFactory.decodeStream(this.CONTEXT.getContentResolver().openInputStream(uri));
			if(QRHelper.getReult(bitmap)!=null){
				callback.invoke(null,QRHelper.getReult(bitmap));
			}else{
				callback.invoke("识别错误",null);
			}

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
				this.callback.resolve(getImageSuccessMap());
				this.callback=null;
			break;
			case REQUEST_SEND_TEXT:
				this.callback.resolve(getTextSuccessMap());
				this.callback=null;
			case REQUEST_INSTALL:
				if(openpromise!=null){
					openpromise.resolve("true");
					openpromise=null;
				}
			break;
		}
	}

  @Override
  public void onNewIntent(Intent intent) {

  }
   /**
     * 保存图片到图库
     * @param bmp
     */
    public static void saveImageToGallery(Context context,Bitmap bmp ) {
		File appDir = new File(Environment.getExternalStorageDirectory(), "/DCIM/Camera");
		   if (!appDir.exists()) {

		   appDir.mkdir();
			}

			String fileName = System.currentTimeMillis() + ".jpg";
			File file = new File(appDir, fileName);
			try {

			FileOutputStream fos = new FileOutputStream(file);
			 bmp.compress(Bitmap.CompressFormat.JPEG, 100, fos);
			 fos.flush();
			 fos.close();
		   } catch (FileNotFoundException e) {

			 e.printStackTrace();
		   } catch (IOException e) {

			e.printStackTrace();
		   }

			// 其次把文件插入到系统图库
			try {

		   MediaStore.Images.Media.insertImage(context.getContentResolver(),
					  file.getAbsolutePath(), fileName, null);
		   } catch (FileNotFoundException e) {

					 e.printStackTrace();
			}
   }

   @RequiresApi(api = Build.VERSION_CODES.O)
   public static Bitmap base64ToBitmap(String base64Data) {
		   Base64.Decoder decoder = Base64.getMimeDecoder();
	     byte[] bytes =  decoder.decode(base64Data);
	     return BitmapFactory.decodeByteArray(bytes, 0, bytes.length);

   }
   @RequiresApi(api = Build.VERSION_CODES.O)
   @ReactMethod
   public void saveImage(String imgsrc, Callback successback){
	boolean hasInstallPermission = this.getReactApplicationContext().getPackageManager().canRequestPackageInstalls();
	Log.d("hasInstallPermission", String.valueOf(hasInstallPermission));
	if (!hasInstallPermission) {
		startInstallPermissionSettingActivity();
	} else {
	  try{
		Bitmap bmp=base64ToBitmap(imgsrc);
		saveImageToGallery(myContext,bmp);
		successback.invoke("true");
	  }catch(Exception e){
		successback.invoke("false");
	  }
	}
   }

   @ReactMethod
   public void donwloadSaveImg(String filePaths,final Promise promise) {
		 try {
			   if (!TextUtils.isEmpty(filePaths)) { //网络图片
				   // 对资源链接
				   URL url = new URL(filePaths);
				   //打开输入流
				   InputStream inputStream = url.openStream();
				   //对网上资源进行下载转换位图图片
				   mBitmap = BitmapFactory.decodeStream(inputStream);
				   inputStream.close();
			   }
			   saveFile((ReactApplicationContext) myContext,mBitmap);
			   promise.resolve("true");
		   } catch (IOException e) {
			   promise.reject("false");
			   e.printStackTrace();
		   } catch (Exception e) {
			   promise.reject("false");
			   e.printStackTrace();
		   }
   }



   public static void saveFile(ReactApplicationContext context,Bitmap bm ) throws IOException {
			   File dirFile = new File(Environment.getExternalStorageDirectory().getPath());
			   if (!dirFile.exists()) {
				   dirFile.mkdir();
			   }
			   File dirFile2 = new File(Environment.getExternalStorageDirectory().getPath()+"/DCIM");
			   if (!dirFile2.exists()) {
				   dirFile2.mkdir();
			   }
			   File dirFile3 = new File(Environment.getExternalStorageDirectory().getPath()+"/DCIM/Camera");
			   if (!dirFile3.exists()) {
				   dirFile3.mkdir();
			   }
			   String fileName = UUID.randomUUID().toString() + ".jpg";
			   File myCaptureFile = new File(Environment.getExternalStorageDirectory().getPath() + "/DCIM/Camera/" + fileName);
			   BufferedOutputStream bos = new BufferedOutputStream(new FileOutputStream(myCaptureFile));
			   bm.compress(Bitmap.CompressFormat.JPEG, 80, bos);
			   Intent intent = new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE);
			   Uri uri = Uri.fromFile(myCaptureFile);
			   intent.setData(uri);
			   context.sendBroadcast(intent);
			   bos.flush();
			   bos.close();
   }
}
