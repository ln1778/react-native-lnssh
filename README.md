# React Native Lnssh (mobile)
A lnssh for react-native, hide when application loaded

## Installation
```sh
npm install react-native-lnssh --save
```
### Installation (iOS pod install)

* cd ios
* 在 Podfile 文件上添加   pod 'WHToast','~>0.1.0'
                        pod 'MBProgressHUD', '~> 1.2.0'
* pod install

* In AppDelegate.m
```objc
...
#import <Lnssh/LnsshManager.h> //<--- import
...
RCTRootView *rootView = [[RCTRootView alloc] initWithBundleURL:jsCodeLocation
                                                      moduleName:@"KitchenSink"
                                               initialProperties:nil
                                                   launchOptions:launchOptions];
  
  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  UIViewController *rootViewController = [[UIViewController alloc] init];
  rootViewController.view = rootView;
  self.window.rootViewController = rootViewController;
  [self.window makeKeyAndVisible];
  [LnsshManager show:rootView]; //<--- add show SplashScreen
  [LnsshManager CheckVersionHost:@"http://.....version.json"]; //<--- 检查版本更新 add CheckVersionHost
  return YES;
```
* In Info.plis

```objc
添加 Privacy - Photo Library Additions Usage Description,
Privacy - Photo Library Additions Usage ,DescriptionNSPhotoLibraryUsageDescription ,
PHAuthorizationStatusLimited 权限

```


### Installation (Android) old version < 0.60
```gradle
...
include ':react-native-lnssh'
project(':react-native-lnssh').projectDir = new File(settingsDir, '../node_modules/react-native-lnssh/android')
```

* In `android/app/build.gradle`

```gradle
...
dependencies {
    ...
    implementation project(':react-native-lnssh')
}
```

* register module (in MainApplication.java)

```java
......
import com.lnssh.LnsshPackage;  // <--- import

......

@Override
protected List<ReactPackage> getPackages() {
   ......
   new LnsshPackage(),            // <------ add here [the seconde params is translucent]
   ......
}

```

* register module (in MainActivity.java)

```java
public class MainActivity extends ReactActivity {
    public static Activity activity;           // <------ add 
    public LnsshManager lnsshmanager; // <------ add here
    ......
    @Override
    protected String getMainComponentName() {
        activity = this;    // <------ add here
        lnsshmanager=new LnsshManager(this);  // <------ add here
       lnsshmanager.splash_show(R.drawable.splash);// <------ 如果设置启动页 add here
       // lnsshmanager.CheckVersionHost("https://......./version.json",false)  《-----检查版本更新 add here
       ......
    }
}
```
* set  permission (in AndroidManifest.xml)
```java
<uses-permission android:name="android.permission.DOWNLOAD_WITHOUT_NOTIFICATION" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.ACCESS_DOWNLOAD_MANAGER"/>
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />
```
* add networkSecurityConfig (in AndroidManifest.xml)

```java
<application
.....
android:networkSecurityConfig="@xml/network_security_config"
...
/>
```

* add file_paths(in AndroidManifest.xml)
```java
<provider
		android:name="androidx.core.content.FileProvider"
		android:authorities="${ApplicationId}.fileprovider"
		android:exported="false"
		android:grantUriPermissions="true">
		<meta-data
			android:name="android.support.FILE_PROVIDER_PATHS"
			android:resource="@xml/file_paths" />
	</provider>
```
* in file_paths.xml

```java 
<?xml version="1.0" encoding="utf-8"?>
<paths xmlns:android="http://schemas.android.com/apk/res/android">
	<root-path name="root" path="/" />
	......
	<files-path name="app_down" path="/lnssh/apk/" />   //<----add here
	<files-path name="share_files" path="/lnssh/record/" />  //<----add here
</paths>

```
* in network_security_config.xml
```java 
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
	<base-config cleartextTrafficPermitted="true" />
</network-security-config>

```
```
* Copy lines to proguard-rules.pro:
```java
-keep class com.tencent.mm.sdk.** {
  *;
}

```

```
*Integrating with login and share

If you are going to integrate login or share functions, you need to create a package named 'wxapi' in your application package and a class named WXEntryActivity in it.

```java 
package com.lnssh.wxapi;

import android.app.Activity;
import android.os.Bundle;
import com.theweflex.react.WeChatModule;

public class WXEntryActivity extends Activity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    WeChatModule.handleIntent(getIntent());
    finish();
  }
}

```
```
* Then add the following node to AndroidManifest.xml:

```java 
<manifest>
  <application>
    <activity
      android:name=".wxapi.WXEntryActivity"
      android:label="@string/app_name"
      android:exported="true"
    />
  </application>
</manifest>
```
```
*Integrating the WeChat Payment

If you are going to integrate payment functionality by using this library, then create a package named also wxapi in your application package and a class named WXPayEntryActivity, this is used to bypass the response to JS level:
```java 
package your.package.wxapi;

import android.app.Activity;
import android.os.Bundle;
import com.theweflex.react.WeChatModule;

public class WXPayEntryActivity extends Activity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    WeChatModule.handleIntent(getIntent());
    finish();
  }
}
```
```
*Then add the following node to AndroidManifest.xml:
```java 
<manifest>
  <application>
    <activity
      android:name=".wxapi.WXPayEntryActivity"
      android:label="@string/app_name"
      android:exported="true"
    />
  </application>
</manifest>
```

## Usage

### Example
```js
'use strict';
var React = require('react');
var ReactNative = require('react-native');
var {
    AppRegistry,
    View,
    Text,
    NativeModules
} = ReactNative;
var {LnsshModule,Toast,ImagePicker,Carams,permissionSetting} = NativeModules;

var KitchenSink = React.createClass({
    componentDidMount: function() {
       LnsshModule.splash_hide();

    },
    render() {
        return(
            <View>
                <Text>
                    fangyunjiang is a good developer!
                </Text>
            </View>
        );
    }
});

AppRegistry.registerComponent('KitchenSink', () => KitchenSink);
```

