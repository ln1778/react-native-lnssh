# React Native Lnssh (mobile)
A lnssh for react-native, hide when application loaded

## Installation
```sh
npm install react-native-lnssh --save
```
### Installation (iOS pod install)

* cd ios
* 在 Podfile 文件上添加   pod 'WHToast','~>0.1.0'

* pod install

* In AppDelegate.m
```objc
...
#import <Lnssh/Lnssh.h> //<--- import
...
RCTRootView *rootView = [[RCTRootView alloc] initWithBundleURL:jsCodeLocation
                                                      moduleName:@"KitchenSink"
                                               initialProperties:nil
                                                   launchOptions:launchOptions];
  [Lnssh show:rootView]; //<--- add show SplashScreen
  [Lnssh CheckVersionHost:@"http://.....version.json"]; //<--- 检查版本更新 add CheckVersionHost
  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  UIViewController *rootViewController = [[UIViewController alloc] init];
  rootViewController.view = rootView;
  self.window.rootViewController = rootViewController;
  [self.window makeKeyAndVisible];
  return YES;
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
var Lnsshmanager = require('react-native-lnssh');
var {LnsshModule} = NativeModules;

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

