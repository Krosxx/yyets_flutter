package cn.vove7.flutter_yyets;

import android.util.Log;

import com.google.gson.Gson;
import com.yyets.zimuzu.db.DBCache;
import com.yyets.zimuzu.db.bean.FilmCacheBean;
import com.yyets.zimuzu.fileloader.RRFilmDownloadManager;

import java.util.Map;
import java.util.Objects;

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

    @Override
    public void onTaskStat(P4PStat p4PStat) {
        EventChannel.EventSink es = MainActivity.eventSink;
        if (es != null) {
            es.success(new Gson().toJson(p4PStat));
        }
    }

    public RRResManager() {
        RRFilmDownloadManager.instance.setP4PListener(this);
    }

    String getAllItems() {
        Gson g = new Gson();
        return g.toJson(DBCache.instance.getAllCacheItemsByTime());
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
        FilmCacheBean cache = DBCache.instance.getCacheByUri((String) filmData.get("p4pUrl"));
        if (cache!=null && cache.isFinished()) {
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

    void pauseByFileId(String fileId) {
        RRFilmDownloadManager.instance.pauseLoading(fileId);
    }

}
