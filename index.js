'use strict';

const ReactNative = require('react-native');
const Carams = require('./carams');
const ImagePicker = require('./ImagePicker');
const {
    NativeModules,
} = ReactNative;
const {LnsshModule,permissionSetting,UpdateManager}=NativeModules;




export const myCarams=Carams.default;
export const myImagePicker=ImagePicker.default;
export {LnsshModule,permissionSetting,UpdateManager}