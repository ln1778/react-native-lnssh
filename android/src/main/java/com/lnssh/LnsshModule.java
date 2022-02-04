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

import androidx.annotation.RequiresApi;
import androidx.core.content.FileProvider;

import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableMap;
import com.google.zxing.aztec.decoder.Decoder;
import com.lnssh.dialogs.RCTSplashScreen;
import com.lnssh.utils.ConfigurationUtil;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import android.os.Environment;
import android.provider.MediaStore;
import android.provider.Settings;
import android.text.TextUtils;
import com.facebook.react.bridge.Promise;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.lang.String;
import java.net.URL;
import java.util.Base64;
import java.util.UUID;

public class LnsshModule extends ReactContextBaseJavaModule implements ActivityEventListener {
  final ReactApplicationContext CONTEXT;
  public static final int REQUEST_SEND_IMAGE = 13001;
  public static final int REQUEST_SEND_TEXT = 13002;
  Activity activity;
  Callback callback;
	private static Bitmap mBitmap;
	private static ReactContext myContext;

  public LnsshModule(ReactApplicationContext reactContext) {
    super(reactContext);
	  CONTEXT = reactContext;
	  myContext=reactContext;
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
	public void splash_show(){
		RCTSplashScreen.native_show();
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
   /**
     * 保存图片到图库
     * @param bmp
     */
    public static void saveImageToGallery(Context context,Bitmap bmp ) {
		File appDir = new File(Environment.getExternalStorageDirectory(), "Boohee");
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
	   Bitmap bmp=base64ToBitmap(imgsrc);
	   saveImageToGallery(myContext,bmp);
	   successback.invoke("true");
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
