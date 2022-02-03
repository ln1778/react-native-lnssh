# React Native SplashScreen (remobile)
A lnssh for react-native, hide when application loaded

## Installation
```sh
npm install react-native-lnssh --save
```
### Installation (iOS)
* Drag Lnssh.xcodeproj to your project on Xcode.
* Click on your main project file (the one that represents the .xcodeproj) select Build Phases and drag libLnssh.a from the Products folder inside the Lnssh.xcodeproj.

* In AppDelegate.m
```objc
...
#import "Lnssh.h" //<--- import
...
RCTRootView *rootView = [[RCTRootView alloc] initWithBundleURL:jsCodeLocation
                                                      moduleName:@"KitchenSink"
                                               initialProperties:nil
                                                   launchOptions:launchOptions];
  [Lnssh show:rootView]; //<--- add show SplashScreen

  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  UIViewController *rootViewController = [[UIViewController alloc] init];
  rootViewController.view = rootView;
  self.window.rootViewController = rootViewController;
  [self.window makeKeyAndVisible];
  return YES;
```


### Installation (Android)
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
    compile project(':react-native-lnssh')
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
   new LnsshPackage(MainActivity.activity, true),            // <------ add here [the seconde params is translucent]
   ......
}

```

* register module (in MainActivity.java)

```java
public class MainActivity extends ReactActivity {
    public static Activity activity;           // <------ add here
    ......
    @Override
    protected String getMainComponentName() {
        activity = this;           // <------ add here
        ......
    }
}
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
} = ReactNative;
var SplashScreen = require('react-native-lnssh');

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
```

### constants
- `translucent` is translucent enable
### methods
- `hide()` hide SplashScreen

