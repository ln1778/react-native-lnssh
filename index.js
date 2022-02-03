'use strict';

const ReactNative = require('react-native');
const Carams = require('./carams');
const ImagerPicker = require('./ImagePicker');
const {
    NativeModules,
} = ReactNative;

module.exports = NativeModules.LnsshModule;
module.exports.Carams=Carams.default;
module.exports.ImagerPicker=ImagerPicker.default;