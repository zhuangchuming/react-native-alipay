声明：软件所有版本均来自：https://www.npmjs.com/package/react-native-alipay
使用npm install react-native-alipay安装的是原作者的内容
个人仅仅是修改了ios部分回调支付后的回调。
使用 npm install git+https://github.com/zhuangchuming/react-native-alipay.git安装本人仓库修改后的代码


以下均是原作者的原创：
## 安装

首先安装rnpm

```
npm install -g rnpm
```

推荐通过npm安装,譬如解压本文件夹到`../react-native-alipay`,则可以在项目文件下运行

```
npm install react-native-alipay
rnpm link react-native-alipay
```

此时应看到输出

```
rnpm-link info Linking react-native-alipay android dependency
rnpm-link info Android module react-native-alipay has been successfully linked
rnpm-link info Linking react-native-alipay ios dependency
rnpm-link info iOS module react-native-alipay has been successfully linked
```

为成功

Android: 添加混淆规则:

在`android/app/proguard-rules.pro`尾部,增加如下内容:

```
-keep class com.alipay.android.app.IAlixPay{*;}
-keep class com.alipay.android.app.IAlixPay$Stub{*;}
-keep class com.alipay.android.app.IRemoteServiceCallback{*;}
-keep class com.alipay.android.app.IRemoteServiceCallback$Stub{*;}
-keep class com.alipay.sdk.app.PayTask{ public *;}
-keep class com.alipay.sdk.app.AuthTask{ public *;}
```

iOS: 添加其它依赖库

以下文件需要手动添加到项目工程内:

node_modules/react-native-alipay/ios/SDK/AlipaySDK.bundle

node_modules/react-native-alipay/ios/SDK/AlipaySDK.framework (此文件也会自动添加到Link Binary With Libraries里)

在Build Settings中的Framework Search Paths中,增加:

$(SRCROOT)/../node_modules/react-native-alipay/ios/SDK

以下依赖库需要手动添加到Build Phases的Link Binary With Libraries中:

![](https://img.alicdn.com/top/i1/LB1PlBHKpXXXXXoXXXXXXXXXXXX)

iOS: 添加配置

在`Info.plist`中添加如下段落:

```
<key>NSAppTransportSecurity</key>
    <dict>
        <key>NSExceptionDomains</key>
        <dict>
            <key>alipay.com</key>
            <dict>
                <key>NSIncludesSubdomains</key>
                <true/>
                <key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key>
                <true/>
                <key>NSTemporaryExceptionMinimumTLSVersion</key>
                <string>TLSv1.0</string>
                <key>NSTemporaryExceptionRequiresForwardSecrecy</key>
                <false/>
            </dict>
            <key>alipayobjects.com</key>
            <dict>
                <key>NSIncludesSubdomains</key>
                <true/>
                <key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key>
                <true/>
                <key>NSTemporaryExceptionMinimumTLSVersion</key>
                <string>TLSv1.0</string>
                <key>NSTemporaryExceptionRequiresForwardSecrecy</key>
                <false/>
            </dict>
        </dict>
    </dict>
```

在`AppDelegate.m`文件中,确保有以下代码(如果你添加过其它第三方库,可能已经有了):

```
// 文件最开头
#import "../Libraries/LinkingIOS/RCTLinkingManager.h"

//@end之前
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
  return [RCTLinkingManager application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
}


```

另外为了兼容iOS 9.0以上设备,还需在Xcode中修改`Info.plist`

以文本方式打开,增加以下内容:

```
	<key>LSApplicationQueriesSchemes</key>
	<array>
		<string>alipay</string>
	</array>
```

或者在Xcode中打开`Info.plist`,增加类型为`Array`的项`LSApplicationQueriesSchemes`,并在其下增加`String`类型的项:`alipay`

在工程设置的Info项目里,最底部添加URL Types,

identifier填写alipay,URL Schemas填写一个不易冲突的,包含应用标识的字符串.

## API

#### pay(orderInfo[, showLoading]) => Promise<object>

调用支付接口进行支付

* orderInfo 一个字符串,为服务器返回的订单详情,多个key=value字符串用&分隔
* showLoading 是否显示切换进度条,默认为false,推荐填写true. iOS此选项不生效

返回对象:

* resultStatus 结果状态码,类型为字符串,为'9000'表示支付成功,为'8000'表示支付状态需与服务器确认,其余均表示支付失败,包括用户主动取消
    参考[支付宝文档-客户端返回码](https://doc.open.alipay.com/doc2/detail?treeId=59&articleId=103671&docType=1)
* result 本次操作返回的结果数据,详情参考[支付宝文档-同步通知参数说明](https://doc.open.alipay.com/doc2/detail.htm?spm=a219a.7386797.0.0.awIjtX&treeId=59&articleId=103665&docType=1)
* memo 保留参数，一般无内容。

> 同步返回的数据，对于商户在服务端没有收到异步通知的时候，可以依赖服务端对同步返回的结果来进行判断是否支付成功。同步返回的结果中，sign字段描述了请求的原始数据和服务端支付的状态一起拼接的签名信息。验证这个过程包括两个部分：1、原始数据是否跟商户请求支付的原始数据一致（必须验证这个）；2、验证这个签名是否能通过。上述1、2通过后，在sign字段中success=true才是可信的。

## 示例

```
import {Alert} from 'react-native';
import {pay} from 'react-native-alipay';
import {post} from '../api.js';

async function doPay() {
    const orderInfo = await post('/createOrder');
    const result = await pay(orderInfo, true);
    if (result.resultStatus === '9000') {
        Alert.alert('提示', '支付成功');
    } else if (result.resultStatus === '8000') {
        Alert.alert('提示', '支付结果确认中,请稍后查看您的账户确认支付结果');
    } else if (result.resultStatus !== '6001') {
        // 如果用户不是主动取消
        Alert.alert('提示', '支付失败');
    }
}

```
