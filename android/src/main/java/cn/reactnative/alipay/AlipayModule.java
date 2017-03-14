package cn.reactnative.alipay;

import android.app.Activity;
import android.os.AsyncTask;

import com.alipay.sdk.app.PayTask;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.Date;
import java.util.List;

/**
 * Created by tdzl2003 on 3/31/16.
 */
public class AlipayModule extends ReactContextBaseJavaModule {

    public AlipayModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return "RCTAlipay";
    }

    @Override
    public void initialize() {
    }

    @Override
    public void onCatalystInstanceDestroy() {
    }

    @ReactMethod
    public void pay(String orderInfo, boolean showLoading, Promise promise) {
        AsyncPayTask task = new AsyncPayTask();
        task.orderInfo = orderInfo;
        task.showLoading = showLoading;
        task.promise = promise;
        task.activity = this.getCurrentActivity();
        if (task.activity == null) {
            promise.reject("NoActivity", "Cannot get current activity.");
            return;
        }

        task.execute();
    }

    private static class AsyncPayTask extends AsyncTask<Void, Void, Void>
    {
        public String orderInfo;
        public boolean showLoading;
        public Promise promise;
        public Activity activity;

        @Override
        protected Void doInBackground(Void... params) {
            try {
                PayTask alipay = new PayTask(activity);
                String result = alipay.pay(orderInfo, showLoading);
                promise.resolve(result);
            } catch (Throwable e){
                promise.reject(e);
            }
            return null;
        }
    }
}
