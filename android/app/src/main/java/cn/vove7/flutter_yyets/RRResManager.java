package cn.vove7.flutter_yyets;

import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.util.Log;

import androidx.core.content.FileProvider;

import com.google.gson.Gson;
import com.yyets.zimuzu.db.DBCache;
import com.yyets.zimuzu.db.bean.FilmCacheBean;
import com.yyets.zimuzu.fileloader.RRFilmDownloadManager;

import java.io.File;
import java.util.Map;
import java.util.Objects;

import cn.vove7.rr_lib.InitCp;
import io.flutter.plugin.common.EventChannel;
import tv.zimuzu.sdk.p4pclient.P4PClientEvent;
import tv.zimuzu.sdk.p4pclient.P4PStat;


/**
 * Created by 11324 on 2020/4/14
 */
@SuppressWarnings("unused")
class RRResManager implements P4PClientEvent {

    @Override
    public void onP4PClientInited() {

    }

    @Override
    public void onP4PClientRestarted() {

    }

    @Override
    public void onP4PClientStarted() {

    }

    Gson gson = new Gson();

    @Override
    public void onTaskStat(P4PStat p4PStat) {
        EventChannel.EventSink es = MainActivity.eventSink;
        if (es != null) {
            es.success(gson.toJson(p4PStat));
        }
    }

    public RRResManager() {
        RRFilmDownloadManager.instance.setP4PListener(this);
    }

    String getAllItems() {
        return gson.toJson(DBCache.instance.getAllCacheItemsByTime());
    }

    boolean isDownloadComplete(Map<String, String> data) {
        return DBCache.instance.hasDownloadComplete(
                data.get("filmid"),
                data.get("season"),
                data.get("episode")
        );
    }

    boolean startDownload(Map<String, Object> filmData) {
        FilmCacheBean bean = FilmCacheBean.parseFromUri(
                (String) Objects.requireNonNull(filmData.get("p4pUrl")),
                (String) filmData.get("filmId"),
                (String) filmData.get("filmImg")
        );
        String fn = (String) filmData.get("filmName");
        if (fn != null) {
            bean.mFilmName = fn;
        }
        String season = (String) filmData.get("season");
        if (season != null) {
            bean.mSeason = season;
        }
        String episode = (String) filmData.get("episode");
        if (episode != null) {
            bean.mEpisode = episode;
        }

        FilmCacheBean cache = DBCache.instance.getCacheByUri((String) filmData.get("p4pUrl"));
        if (cache != null && cache.isFinished()) {
            Log.d("11324 :", "startDownload  ----> 已下载完成" + filmData);
            return false;
        }
        if (RRFilmDownloadManager.getStatus(bean) == RRFilmDownloadManager.STATUS_DOWNLOADING) {
            Log.d("11324 :", "startDownload  ----> 正在下载中" + filmData);
            return false;
        }
        RRFilmDownloadManager.instance.downloadFilm(bean);
        return true;
    }

    void pauseAll() {
        RRFilmDownloadManager.instance.pauseAllLoading();
    }

    void resumeAll() {
        RRFilmDownloadManager.downloadUncompleteTask();
    }

    int getStatus(Map bean) {
        Gson g = new Gson();
        FilmCacheBean b = g.fromJson(g.toJson(bean), FilmCacheBean.class);
        return RRFilmDownloadManager.getStatus(b);
    }

    void resumeByFileId(String fileId) throws Exception {

        FilmCacheBean bean = null;
        for (FilmCacheBean f : RRFilmDownloadManager.getUncompletedList()) {
            if (f.mFileId.equals(fileId)) {
                bean = f;
                break;
            }
        }
        if (bean != null) {
            RRFilmDownloadManager.instance.resumeFilmDownload(bean);
        } else {
            throw new Exception("不存在任务: " + fileId);
        }
    }

    boolean deleteDownload(String fileId) {
        return RRFilmDownloadManager.instance.cancelDownload(fileId);
    }

    void pauseByFileId(String fileId) {
        RRFilmDownloadManager.instance.pauseLoading(fileId);
    }

    boolean playByExternal(String filePath) {
        Intent playIntent = new Intent(Intent.ACTION_VIEW);
        File f = new File(filePath);
        playIntent.setType("video/*");
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            Uri contentUri = FileProvider.getUriForFile(
                    InitCp.androidContext,
                    BuildConfig.APPLICATION_ID + ".fileProvider", f);
            playIntent.setData(contentUri);
            playIntent.putExtra(Intent.EXTRA_STREAM, contentUri);
            playIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
        } else {
            Uri uri = Uri.fromFile(f);
            playIntent.putExtra(Intent.EXTRA_STREAM, uri);
            playIntent.setData(uri);
        }
        int s = InitCp.androidContext
                .getPackageManager()
                .queryIntentActivities(playIntent, 0).size();
        if (s > 0) {
            Intent ci = Intent.createChooser(playIntent, "选择播放方式");
            ci.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            InitCp.androidContext.startActivity(ci);
            return true;
        } else {
            return false;
        }
    }
}
