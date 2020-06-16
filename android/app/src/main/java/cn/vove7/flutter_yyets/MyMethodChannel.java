package cn.vove7.flutter_yyets;

import android.util.Log;

import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.view.FlutterView;

/**
 * # MyMethodChannel
 * <p>
 * Created on 2020/6/15
 *
 * @author Vove
 */
class MyMethodChannel {
    private static final String METHOD_CHANNEL = "cn.vove7.flutter_yyets/channel";

    private MethodChannel channel;
    private RRResManager rrResManager = new RRResManager();

    public MyMethodChannel(FlutterView fv) {
        channel = new MethodChannel(fv, METHOD_CHANNEL);
        channel.setMethodCallHandler((call, result) -> {
            Log.d("Flutter", "channel:  " + call.method + "(" + call.arguments + ")");
            try {
                Method[] m = RRResManager.class.getDeclaredMethods();
                for (Method method : m) {
                    if (call.method.equals(method.getName())) {
                        Object res;
                        if (method.getParameterTypes().length == 0) {
                            res = method.invoke(rrResManager);
                        } else {
                            res = method.invoke(rrResManager, call.arguments);
                        }
                        result.success(res);
                        return;
                    }
                }
                result.notImplemented();
            } catch (Exception e) {
                e.printStackTrace();
                result.error(e.getMessage(), null, null);
            }
        });
    }
}
