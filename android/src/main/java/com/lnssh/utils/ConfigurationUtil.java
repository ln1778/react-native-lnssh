package com.lnssh.utils;

import android.os.Environment;

import java.io.File;


public class ConfigurationUtil {
	public static final String WEBVERSION = "https://chatapp.hwanc.net/hwancchat/app/version.json";
	public static final String APKHOST = "https://hcoins.oss-cn-hangzhou.aliyuncs.com/hwancchat.apk";
	public static final String BUNDLEHOST = "https://hcoins.oss-cn-hangzhou.aliyuncs.com/index.android.bundle";
	public static final String MARKETHOST = "https://chatapp.hwanc.net/redpack/";
	public static final String MARKETWSURL = "ws://122.228.244.50:6006";
	public static final String PAPERHOST = "https://chatapp.hwanc.net/redpack/";
	public static final String DAPPHOST = "http://ipfs.hgmalls.com/ipfs/";
	public static final int SUCCESSCODE = 1;//成功标识
	public static final int FAILURECODE = 0;//失败标识
	public static final int ERRORCODE = 2;//网络请求异常标识

	public static final int DBVERSION = 2;//数据库版本

	public static final String SDFILE = Environment.getExternalStoragePublicDirectory("") + File.separator + "hnlx/gt/";

	public static final String FILE_PATH = ConfigurationUtil.SDFILE + "camera" + File.separator;
	public static final String APK_PATH = "lnssh/"+ "apk" + File.separator;
	public static final String APK_PATH_ABSOULT = ConfigurationUtil.SDFILE+ "apk" + File.separator;
	public static final String RECORD_PATH_ABSOULT = ConfigurationUtil.SDFILE+ "apk" + File.separator;
}
