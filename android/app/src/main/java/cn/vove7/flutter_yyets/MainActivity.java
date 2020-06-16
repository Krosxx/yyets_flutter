package cn.vove7.flutter_yyets;

import android.os.Bundle;
import android.os.Handler;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    private static final String DOWNLOAD_EVENT_CHANNEL = "cn.vove7.flutter_yyets/download_event";


    public static EventChannel.EventSink eventSink;

    private MyMethodChannel methodChannel;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);
        bindChannel();
    }


    private void bindChannel() {
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
        methodChannel = new MyMethodChannel(getFlutterView());
    }

}
