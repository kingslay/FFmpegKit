# FFmpegKit ![GitHub release](https://img.shields.io/badge/release-v5.1-blue.svg) ![CocoaPods](https://img.shields.io/cocoapods/v/ffmpeg-kit-ios-min) 

`FFmpegKit` is a collection of tools to use `FFmpeg` in `iOS`, `macOS`, `tvOS`, `xrOS`, `visionOS`  applications.

It includes scripts to build `FFmpeg` native libraries, 


## Custom FFmpeg
edit main.swift And run
```bash
swift package BuildFFmpeg --disable-sandbox enable-libdav1d enable-openssl enable-libsrt
```
