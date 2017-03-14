/**
 * Created by tdzl2003 on 4/13/16.
 */

import {NativeModules, DeviceEventEmitter} from 'react-native';

const NativeAlipay = NativeModules.Alipay;

Object.assign(exports, NativeAlipay);

const regParse = /^(\w+)=\{(.+)\}$/;
function parseResult(str) {
  if (typeof(str) !== 'string') {
    return str;
  }
  const ret = {};
  str.split(';').forEach(v=>{
    const m = regParse.exec(v);
    if (m){
      ret[m[1]] = m[2];
    }
  });
  return ret;
}

/*async*/ function pay(orderInfo, showLoading) {
  return NativeAlipay.pay(orderInfo, !!showLoading)
    .then(result=>parseResult(result));
};
exports.pay = pay;
