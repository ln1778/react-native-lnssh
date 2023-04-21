'use strict';

const ReactNative = require('react-native');
import ImagePicker from "./ImagePicker";

const {
    NativeModules,
} = ReactNative;
const {LnsshModule,permissionSetting,UpdateManager}=NativeModules;


export default {ImagePicker,LnsshModule,permissionSetting,UpdateManager}
