package com.lnssh.utils;


import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.os.Environment;

public class Tools {
	/**
	 * 检查是否存在SDCard
	 *
	 * @return
	 */
	public static boolean hasSdcard() {
		String state = Environment.getExternalStorageState();
		if (state.equals(Environment.MEDIA_MOUNTED)) {
			return true;
		} else {
			return false;
		}
	}

	/**
	 * 2 * 获取版本
	 */
	public static int getVersion(Context context) {
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

	/**
	 * 2 * 获取版本名称
	 */
	public static String getVersionName(Context context) {
		try {
			PackageManager manager = context.getPackageManager();
			PackageInfo info = manager.getPackageInfo(context.getPackageName(),0);
			String version = info.versionName;
			return version;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return "";
	}
}
