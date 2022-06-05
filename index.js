'use strict';

const ReactNative = require('react-native');
const Carams = require('./carams');
const ImagePicker = require('./ImagePicker');
const WxApi = require('./wxapi');
const {
    NativeModules,
} = ReactNative;
const {LnsshModule,permissionSetting,UpdateManager}=NativeModules;


 const myCarams=Carams.default;
  const myImagePicker=ImagePicker.default;
  const myWxApi=WxApi.default;
export default {myWxApi,myCarams,myImagePicker,LnsshModule,permissionSetting,UpdateManager}