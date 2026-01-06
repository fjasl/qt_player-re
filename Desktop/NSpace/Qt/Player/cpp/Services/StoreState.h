// app_state.h

#pragma once

#include <QVariantMap>
#include <QVariantList>
#include <QString>
#include <QDebug>

class AppState
{
public:
    // 播放模式枚举
    enum PlayMode {
        SingleLoop,
        Shuffle
    };

    QVariantList playlistRecord = {};

    // ==================== 公共模板（供外部使用） ====================

    // 单个歌曲轨道的默认模板（用于 playlist 中的每一项）
    static inline const QVariantMap TrackTemplate = []() {
        QVariantMap tmpl;
        tmpl["path"] = "";
        tmpl["lyric_bind"] = "";
        tmpl["liked_count"] = -1;
        return tmpl;
    }();

    // 当前播放轨道的默认模板
    static inline const QVariantMap CurrentTrackTemplate = []() {
        QVariantMap tmpl;
        tmpl["index"] = -1;
        tmpl["path"] = "";
        tmpl["position"] = -1;
        tmpl["duration"] = -1;
        tmpl["title"] = "";
        tmpl["artist"] = "";
        tmpl["likedCount"] = -1;
        tmpl["lyric_bind"] = "";
        tmpl["cover"] = "";
        return tmpl;
    }();

    // 上次会话恢复信息模板
    static inline const QVariantMap LastSessionTemplate = []() {
        QVariantMap tmpl;
        tmpl["index"]=-1;
        tmpl["path"] = "";
        tmpl["position"] = -1;
        tmpl["play_mode"] = "single_loop";
        tmpl["lyric_bind"] = "";
        return tmpl;
    }();

    // 歌词数据模板
    static inline const QVariantMap LyricTemplate = []() {
        QVariantMap tmpl;
        tmpl["LyricList"] = QVariantList();
        tmpl["currentLyricRow"] = -1;
        return tmpl;
    }();

    // 完整的初始状态模板（如果你也想暴露整个默认状态）
    static QVariantMap defaultState() {
        QVariantMap state;
        state["playlist"] = QVariantList();
        state["current_track"] = CurrentTrackTemplate;
        state["is_playing"] = false;
        state["play_mode"] = "single_loop";
        state["volume"] = 0;
        state["last_session"] = LastSessionTemplate;
        state["Lyric"] = LyricTemplate;
        state["settings"] = QVariantMap();
        return state;
    }


    AppState();

    // ==================== 万能通用方法 ====================

    /**
     * @brief 获取多级路径的值
     * 支持语法： "playlist[0].path"   "current_track.title"   "Lyric.currentLyricRow"
     * @param path 路径字符串
     * @return 对应的 QVariant，如果路径不存在返回无效 QVariant
     */
    QVariant get(const QString& path) const;

    /**
     * @brief 设置多级路径的值
     * 支持语法同 get()
     * 如果路径不存在或索引越界，会自动创建中间层（数组/对象），并在非法索引时输出 qWarning()
     * @param path 路径字符串
     * @param value 要设置的值
     */
    void set(const QString& path, const QVariant& value);

    // ==================== 辅助方法 ====================

    QString playModeToString(PlayMode mode) const {
        return (mode == SingleLoop) ? QStringLiteral("single_loop") : QStringLiteral("shuffle");
    }
    // AppState.h 增加
    PlayMode stringToPlayMode(const QString& modeStr) const {
        if (modeStr == QLatin1String("shuffle")) {
            return AppState::Shuffle;
        }
        // 默认为单曲循环或其他逻辑
        return AppState::SingleLoop;
    }

    // 如果你还想暴露当前播放模式（可选）
    QString currentPlayMode() const;
    void setCurrentPlayMode(PlayMode mode);
    void mergeStates(const QVariantMap& loaded);
    QVariantMap getState() const { return m_state; }
    void recursiveMerge(QVariantMap& base, const QVariantMap& loaded);
//==============================playlist ===========================
    /**
 * @brief 向播放列表追加歌曲
 * @param trackData 包含歌曲信息的 Map。缺失字段将自动使用默认模板补齐
 */
    void appendSong(const QVariantMap& trackData = QVariantMap());

    /**
 * @brief 通过索引移除播放列表中的歌曲
 * @param index 要移除的项索引
 */
    void removeSong(int index);
    /**
 * @brief 专用接口：获取播放列表中指定索引的歌曲对象
 */
    QVariantMap getSong(int index) const;
    /**
 * @brief 替换整个播放列表
 * @param newList 新的歌曲列表
 */
    void setPlaylist(const QVariantList& newList);

    /**
 * @brief 让指定索引歌曲的点赞数 +1
 * @param index 歌曲在播放列表中的索引
 */
    void incrementLikedCount(int index);

//============================current_track ===================
    /**
 * @brief 整体更新当前播放的曲目信息
 */
    void setCurrentTrack(const QVariantMap& trackData);

    /**
 * @brief 更新当前播放曲目的特定属性 (如 "position", "duration")
 */
    void updateCurrentTrackField(const QString& field, const QVariant& value);
//=================last_session ========================



    /**
 * @brief 从当前曲目 current_track 中提取关键信息同步到 last_session
 * 包含：path, position, lyric_bind 等
 */
    void syncCurrentToLastSession();


private:
    // ==================== 私有状态数据 ====================
    QVariantMap m_state;



    // 内部工具：解析路径为 parts（支持 [index] 语法）
    static QStringList parsePath(const QString& path);

    // 内部工具：根据 parts 获取引用（用于 set）
    QVariant resolveRef(QStringList parts);
    const QVariant resolveRef(QStringList parts) const;

    QVariant updateRecursive(QVariant current, QStringList parts, const QVariant& value);
};

