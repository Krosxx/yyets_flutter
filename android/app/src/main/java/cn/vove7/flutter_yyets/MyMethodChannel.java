package cn.vove7.flutter_yyets;

import android.util.Log;

import java.lang.reflect.Method;

import io.flutter.embedding.android.FlutterView;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;

/**
 * # MyMethodChannel
 * <p>
 * Created on 2020/6/15
 *
 * @author Vove
 */
class MyMethodChannel {
    private static final String METHOD_CHANNEL = "cn.vove7.flutter_yyets/channel";

    private final RRResManager rrResManager = new RRResManager();

    public MyMethodChannel(BinaryMessenger bm) {
        MethodChannel channel = new MethodChannel(bm, METHOD_CHANNEL);
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
