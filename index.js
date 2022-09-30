'use strict';

const ReactNative = require('react-native');
import * as WeChat from './wxapi';
import ImagePicker from "./ImagePicker";
import Carams from "./carams";

const {
    NativeModules,
} = ReactNative;
const {LnsshModule,permissionSetting,UpdateManager}=NativeModules;


export default {WeChat,Carams,ImagePicker,LnsshModule,permissionSetting,UpdateManager}