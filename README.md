# react-native-lnssh
eact Native SplashScreen (remobile)
A lnssh for react-native, hide when application loaded

Installation
npm install @remobile/react-native-lnssh --save
Installation (iOS)
Drag Lnssh.xcodeproj to your project on Xcode.

Click on your main project file (the one that represents the .xcodeproj) select Build Phases and drag libRCTSplashScreen.a from the Products folder inside the Drag Lnssh.xcodeproj to your project on Xcode.
.xcodeproj.

In AppDelegate.m

...
#import "Drag Lnssh.xcodeproj to your project on Xcode.
.h" //<--- import
...
RCTRootView *rootView = [[RCTRootView alloc] initWithBundleURL:jsCodeLocation
                                                      moduleName:@"KitchenSink"
                                               initialProperties:nil
                                                   launchOptions:launchOptions];
  [RCTSplashScreen show:rootView]; //<--- add show SplashScreen

  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  UIViewController *rootViewController = [[UIViewController alloc] init];
  rootViewController.view = rootView;
  self.window.rootViewController = rootViewController;
  [self.window makeKeyAndVisible];
  return YES;
Installation (Android)
...
include ':react-native-lnssh'
project(':react-native-lnssh').projectDir = new File(settingsDir, '../node_modules/@remobile/react-native-lnssh/android')
In android/app/build.gradle
...
dependencies {
    ...
    compile project(':react-native-lnssh')
}
register module (in MainApplication.java)
......
import com.lnssh.LnsshPackage;  // <--- import

......

@Override
protected List<ReactPackage> getPackages() {
   ......
   new LnsshPackage(MainActivity.activity, true),            // <------ add here [the seconde params is translucent]
   ......
}
register module (in MainActivity.java)
public class MainActivity extends ReactActivity {
    public static Activity activity;           // <------ add here
    ......
    @Override
    protected String getMainComponentName() {
        activity = this;           // <------ add here
        ......
    }
}
Screencasts
gif

Usage
Example
'use strict';
var React = require('react');
var ReactNative = require('react-native');
var {
    AppRegistry,
    View,
    Text,
} = ReactNative;
var SplashScreen = require('@remobile/react-native-lnssh');

var KitchenSink = React.createClass({
    componentDidMount: function() {
        SplashScreen.hide();
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
constants
translucent is translucent enable
methods
hide() hide SplashScreen

mkdir -p ../android/app/src/main/res/drawable
cp ../ios/CardC/splash/splash.png ../android/app/src/main/res/drawable/splash.png