'use strict';

const ReactNative = require('react-native');
import ImagePicker from "./ImagePicker";
import * as WeChat from './wxapi';

const {
    NativeModules,
} = ReactNative;
const {LnsshModule,permissionSetting,UpdateManager}=NativeModules;


export default {WeChat,ImagePicker,LnsshModule,permissionSetting,UpdateManager}