'use strict';

const ReactNative = require('react-native');
const Carams = require('./carams');
const ImagePicker = require('./ImagePicker');
const {
    NativeModules,
} = ReactNative;
const {LnsshModule,permissionSetting,UpdateManager}=NativeModules;


 const myCarams=Carams.default;
  const myImagePicker=ImagePicker.default;
export default {myCarams,myImagePicker,LnsshModule,permissionSetting,UpdateManager}