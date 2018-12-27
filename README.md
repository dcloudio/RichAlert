## 简介
此 repository 为 [uni-app](https://uniapp.dcloud.io/) 原生端（iOS、Android）扩展的**富文本提示框** [RichAlert](http://ext.dcloud.net.cn/plugin?id=36) 插件示例 demo，现已将插件源码开源，供所有开发者一起学习交流，欢迎 star 以及提交pull request。

### uni-app 简介

[uni-app](https://uniapp.dcloud.io/) 是一个使用 Vue.js 开发跨平台应用的前端框架，开发者编写一套代码，可编译到 iOS、Android、H5、小程序等多个平台。

#### 扫码快速体验
一套代码编到4个平台，依次扫描4个二维码，亲自体验最全面的跨平台效果！

Android版本|iOS版本|H5版本|微信小程序版本
--------- |-------|-----|------------
<img src="https://img-cdn-qiniu.dcloud.net.cn/uniapp/doc/uni-android.png" width="150" height="150"/>|<img src="https://img-cdn-qiniu.dcloud.net.cn/uniapp/doc/uni-ios.png" width="150" height="150"/>|<img src="https://img-cdn-qiniu.dcloud.net.cn/uniapp/doc/uni-h5.png" width="150" height="150"/>|<img src="https://img.cdn.aliyun.dcloud.net.cn/guide/uniapp/gh_33446d7f7a26_430.jpg" width="150" height="150"/>|



## RichAlert
增强的原生提示框。可自定义颜色、按钮数量、放置超链接和checkbox。可覆盖页面中的原生组件

Android效果图|iOS效果图
----|----|
<img src="https://github.com/dcloudio/RichAlert/blob/master/imgs/android.png?raw=true" width="250" height=""/>|<img src="https://github.com/dcloudio/RichAlert/blob/master/imgs/IMG_7052.PNG?raw=true" width="250" height=""/>


## clone 项目到本地

`git clone https://github.com/dcloudio/RichAlert.git`


## Android

### 说明：
 + uniplugin_richalert moudle为RichAlert插件
 
### 运行
 + 使用android studio导入此工程，run 'app'即可体验RichAlert！


## iOS
### 运行
> **说明**：由于 github 不能上传大于100M的文件，iOS 当前工程中缺少 `liblibWeex.a` 库，请下载 [iOS离线SDK](http://ask.dcloud.net.cn/docs/#//ask.dcloud.net.cn/article/103)在目录 SDK/Libs 中拷贝 `liblibWeex.a` 到当前工程的 iOS/SDK/Libs 目录下

进入 iOS/HBuilder-uniPluginDemo 双击 `HBuilder-Integrate.xcodeproj` 运行即可


## 学习uni-app原生插件开发
 + [Android uni-app原生插件开发教程](https://ask.dcloud.net.cn/article/35416)
 + [iOS uni-app原生插件开发教程](https://ask.dcloud.net.cn/article/35415)

## License

[MIT](https://opensource.org/licenses/MIT)

Copyright (c) 2018 DCloud