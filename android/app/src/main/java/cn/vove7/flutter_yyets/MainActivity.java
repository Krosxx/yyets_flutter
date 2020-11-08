package cn.vove7.flutter_yyets;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;

public class MainActivity extends FlutterActivity {
    private static final String DOWNLOAD_EVENT_CHANNEL = "cn.vove7.flutter_yyets/download_event";

    public static EventChannel.EventSink eventSink;

    @Override protected void onStop() {
        super.onStop();
        if (eventSink != null) {
            eventSink.success("onStop");
        }
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        EventChannel downloadEventChannel = new EventChannel(
                flutterEngine.getDartExecutor().getBinaryMessenger(),
                DOWNLOAD_EVENT_CHANNEL
        );

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
        new MyMethodChannel(
                flutterEngine.getDartExecutor().getBinaryMessenger()
        );
    }

}
