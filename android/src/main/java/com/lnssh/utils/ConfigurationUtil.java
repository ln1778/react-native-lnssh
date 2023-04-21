package com.lnssh.utils;

import android.os.Environment;

import java.io.File;


public class ConfigurationUtil {
	public static String WEBVERSION = "https://chatapp.hwanc.net/hwancchat/app/version.json";
	public static String APKHOST = "https://hcoins.oss-cn-hangzhou.aliyuncs.com/hwancchat.apk";
	public static String BUNDLEHOST = "https://hcoins.oss-cn-hangzhou.aliyuncs.com/index.android.bundle";
	public static String APK_NAME="lnssh.apk";
	public static final int SUCCESSCODE = 1;//成功标识
	public static final int FAILURECODE = 0;//失败标识
	public static final int ERRORCODE = 2;//网络请求异常标识

	public static final int DBVERSION = 2;//数据库版本

	public static final String SDFILE = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)+ File.separator;

	public static final String FILE_PATH = ConfigurationUtil.SDFILE + "camera" + File.separator;
	public static final String APK_PATH = "apk" + File.separator;
	public static final String APK_PATH_ABSOULT = ConfigurationUtil.SDFILE+ "apk" + File.separator;
	public static final String RECORD_PATH_ABSOULT = ConfigurationUtil.SDFILE+ "record" + File.separator;

  public static void setApkHost(String url){
	APKHOST=url;
  }
  public static void setWebVersion(String url){
	WEBVERSION=url;
  }
  public static void setBundleHost(String url){
	BUNDLEHOST=url;
  }
  public static void setApkName(String name){
	APK_NAME=name;
  }
}
