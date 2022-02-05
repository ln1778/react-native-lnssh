'use strict';

const ReactNative = require('react-native');
const Carams = require('./carams');
const ImagePicker = require('./ImagePicker');
const {
    NativeModules,
} = ReactNative;

module.exports = NativeModules.LnsshModule;
module.exports.Carams=Carams.default;
module.exports.ImagePicker=ImagePicker.default;