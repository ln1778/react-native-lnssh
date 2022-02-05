/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 *
 * @format
 */

import NativeInterface from './internal/nativeInterface';
import {processColor,Dimensions} from 'react-native';
import React, { Component } from 'react';
const { width,height } = Dimensions.get('window');

const DEFAULT_OPTIONS = {
  quality: 1.0,
  selectionLimit:1,
  includeBase64:true,
  includeExtra:true,
  mediaType:"photo",
  maxWidth:width,
  maxHeight:height,
  videoQuality:'high',
  cameraType:"back",
  saveToPhotos:true,
  durationLimit:3600
};


export default {
  launchCamera:(options, callback)=>{
    return NativeInterface.launchCamera(
      {
        ...DEFAULT_OPTIONS,
        ...options
      },
      callback,
    );
  },
  launchImageLibrary:(options, callback)=>{
    return NativeInterface.launchImageLibrary(
      {
        ...DEFAULT_OPTIONS,
        ...options,
      },
      callback,
    );
  }
};

// export default ImagePickersha;

