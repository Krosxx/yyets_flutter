package cn.vove7.flutter_yyets;

import android.os.Bundle;
import android.util.Log;

import java.lang.reflect.Method;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    private static final String METHOD_CHANNEL = "cn.vove7.flutter_yyets/channel";
    private static final String DOWNLOAD_EVENT_CHANNEL = "cn.vove7.flutter_yyets/download_event";

    RRResManager rrResManager;

    public static EventChannel.EventSink eventSink;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        rrResManager = new RRResManager();
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);
        PluginRegistry.Registrar registrar = registrarFor(DOWNLOAD_EVENT_CHANNEL);
        EventChannel downloadEventChannel = new EventChannel(registrar.messenger(), DOWNLOAD_EVENT_CHANNEL);
        downloadEventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object o, EventChannel.EventSink es) {
                eventSink = es;
            }

            @Override
            public void onCancel(Object o) {
                eventSink = null;
            }
        });
        new MethodChannel(getFlutterView(), METHOD_CHANNEL).setMethodCallHandler((call, result) -> {
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
