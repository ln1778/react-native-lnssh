'use strict';

const ReactNative = require('react-native');
const Carams = require('./carams');
const ImagePicker = require('./ImagePicker');
import * as WeChat from './wxapi';

const {
    NativeModules,
} = ReactNative;
const {LnsshModule,permissionSetting,UpdateManager}=NativeModules;


 const myCarams=Carams.default;
  const myImagePicker=ImagePicker.default;
export default {WeChat,myCarams,myImagePicker,LnsshModule,permissionSetting,UpdateManager}