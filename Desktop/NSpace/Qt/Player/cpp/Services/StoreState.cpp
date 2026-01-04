// app_state.cpp

#include "StoreState.h"
#include <QRegularExpression>

AppState::AppState()
{
    // 初始化所有状态（全部放在 private 的 m_state 中）

    QVariantMap trackTemplate;
    trackTemplate["path"] = "";
    trackTemplate["lyric_bind"] = "";
    trackTemplate["liked_count"] = -1;

    QVariantMap currentTrackTemplate;
    currentTrackTemplate["index"] = -1;
    currentTrackTemplate["path"] = "";
    currentTrackTemplate["position"] = -1;
    currentTrackTemplate["duration"] = -1;
    currentTrackTemplate["title"] = "";
    currentTrackTemplate["artist"] = "";
    currentTrackTemplate["likedCount"] = -1;
    currentTrackTemplate["lyric_bind"] = "";
    currentTrackTemplate["cover"] = "";

    QVariantMap lastSessionTemplate;
    lastSessionTemplate["path"] = "";
    lastSessionTemplate["position"] = -1;
    lastSessionTemplate["play_mode"] = "single_loop";
    lastSessionTemplate["lyric_bind"] = "";

    QVariantMap lyricTemplate;
    lyricTemplate["LyricList"] = QVariantList();
    lyricTemplate["currentLyricRow"] = -1;

    m_state = QVariantMap{
        {"playlist", QVariantList{ trackTemplate }},        // 初始一个空轨模板
        {"current_track", currentTrackTemplate},
        {"is_playing", false},
        {"play_mode", "single_loop"},
        {"volume", 0},
        {"last_session", lastSessionTemplate},
        {"Lyric", lyricTemplate},
        {"settings", QVariantMap()}
    };
}

// =============== 路径解析工具 ===============

QStringList AppState::parsePath(const QString& path)
{
    if (path.isEmpty())
        return {};

    QString p = path;
    // 将 [0] 转为 .0  支持数组索引
    p.replace(QRegularExpression(R"(\[(\d+)\])"), ".\\1");
    // 支持 ["key"] 或 ['key'] 转为 .key（可选，兼容性）
    p.replace(QRegularExpression(R"(\[["']([^"']+)["']\])"), ".\\1");

    return p.split('.', Qt::SkipEmptyParts);
}

// =============== get() 实现 ===============

QVariant AppState::get(const QString& path) const
{
    QStringList parts = parsePath(path);
    if (parts.isEmpty())
        return QVariant();

    QString firstKey = parts.takeFirst();
    if (!m_state.contains(firstKey)) return QVariant();

    // const QVariantMap* current = &m_state;

    //第一层处理
    QVariant current = m_state.value(firstKey);


    for (const QString& part : parts) {
        bool isIndex = false;
        int index = part.toInt(&isIndex);

        if (isIndex) {
            // 如果这一层路径是数字，尝试转为 List
            if (!current.canConvert<QVariantList>()) return QVariant();
            const QVariantList list = current.toList();
            if (index < 0 || index >= list.size()) return QVariant();
            current = list.at(index);
        } else {
            // 如果这一层路径是字符串，尝试转为 Map
            if (!current.canConvert<QVariantMap>()) return QVariant();
            const QVariantMap map = current.toMap();
            if (!map.contains(part)) return QVariant();
            current = map.value(part);
        }
    }


     return current;
}

// =============== set() 实现（支持自动创建中间层） ===============

QVariant AppState::updateRecursive(QVariant current, QStringList parts, const QVariant& value) {
    if (parts.isEmpty()) return value; // 到达终点，返回新值

    QString part = parts.takeFirst();
    bool isIndex = false;
    int index = part.toInt(&isIndex);

    if (isIndex) {
        // 数组处理：取出副本
        QVariantList list = current.canConvert<QVariantList>() ? current.toList() : QVariantList();

        // 自动扩展数组
        while (list.size() <= index) list.append(QVariantMap());

        // 递归修改子项，并将修改后的结果重新塞回 list
        list[index] = updateRecursive(list.at(index), parts, value);

        return list; // 返回修改后的整个 list 给上一层
    } else {
        // 对象处理：取出副本
        QVariantMap map = current.canConvert<QVariantMap>() ? current.toMap() : QVariantMap();

        // 递归修改键值，并将修改后的结果重新塞回 map
        map[part] = updateRecursive(map.value(part), parts, value);

        return map; // 返回修改后的整个 map 给上一层
    }
}



void AppState::set(const QString& path, const QVariant& value) {
    QStringList parts = parsePath(path);
    if (parts.isEmpty()) return;

    // 采用递归写回的方式：取出 -> 修改 -> 放回
    m_state = updateRecursive(m_state, parts, value).toMap();

    //emit stateChanged(); // 2026年标准：状态变更必须通知
}


// =============== 可选：播放模式便捷接口 ===============

AppState::PlayMode AppState::currentPlayMode() const
{
    QString mode = get("play_mode").toString();
    return (mode == "shuffle") ? Shuffle : SingleLoop;
}

void AppState::setCurrentPlayMode(PlayMode mode)
{
    set("play_mode", playModeToString(mode));
}


/**
 * @brief 递归合并两个 QVariantMap
 * @param base 内存中现有的完整模板 (会被更新)
 * @param loaded 从磁盘加载的部分数据 (覆写源)
 */
void AppState::mergeStates(QVariantMap& base, const QVariantMap& loaded) {
    for (auto it = loaded.constBegin(); it != loaded.constEnd(); ++it) {
        const QString& key = it.key();
        const QVariant& newValue = it.value();

        // 如果键不存在于模板中，可以选择跳过（保持模板纯净）或直接插入
        if (!base.contains(key)) {
            continue; // 按照你的需求：缺失就跳过
        }

        // 如果两边都是 Map，则进入递归合并
        if (base[key].canConvert<QVariantMap>() && newValue.canConvert<QVariantMap>()) {
            QVariantMap baseSubMap = base[key].toMap();
            mergeStates(baseSubMap, newValue.toMap());
            base[key] = baseSubMap;
        }
        // 如果是 List，通常建议直接替换（或者根据业务逻辑合并）
        else {
            base[key] = newValue;
        }
    }
}




