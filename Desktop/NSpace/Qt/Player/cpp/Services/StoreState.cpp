// app_state.cpp

#include "StoreState.h"
#include <QRegularExpression>

AppState::AppState()
{
    m_state = defaultState();
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
//=================playlist 接口====================


void AppState::appendSong(const QVariantMap& trackData)
{
    // 1. 定义标准模板（用于补齐传入 trackData 缺失的字段）
    QVariantMap templateTrack;
    templateTrack["path"] = "";
    templateTrack["lyric_bind"] = "";
    templateTrack["liked_count"] = -1;

    // 2. 合并数据：以模板为底，用传入数据覆盖
    QVariantMap finalTrack = templateTrack;
    for (auto it = trackData.constBegin(); it != trackData.constEnd(); ++it) {
        finalTrack[it.key()] = it.value();
    }

    // 3. 获取当前列表长度
    QVariantList currentList = get("playlist").toList();
    int nextIndex = currentList.size();

    // 4. 利用 set 自动追加到末尾
    // path 语法如: "playlist[0]", "playlist[1]" ...
    set(QStringLiteral("playlist[%1]").arg(nextIndex), finalTrack);
}

void AppState::removeSong(int index)
{
    // 1. 获取当前的 playlist
    QVariant listVar = get("playlist");
    if (!listVar.canConvert<QVariantList>()) {
        qWarning() << "AppState::removeSong: 'playlist' is not a list or does not exist.";
        return;
    }

    QVariantList list = listVar.toList();

    // 2. 边界检查
    if (index < 0 || index >= list.size()) {
        qWarning() << "AppState::removeSong: Index" << index << "out of range (size:" << list.size() << ")";
        return;
    }

    // 3. 执行删除
    list.removeAt(index);

    // 4. 将修改后的列表写回状态机
    // 注意：这里直接对顶层的 "playlist" 进行覆盖设置
    set("playlist", list);

    // 如果你在 2026 年的项目中启用了信号，这里会自动触发 UI 更新
    // emit stateChanged();
}

QVariantMap AppState::getSong(int index) const {
    return get(QString("playlist[%1]").arg(index)).toMap();
}

void AppState::setPlaylist(const QVariantList& newList) {
    // 直接覆盖顶层的 playlist 键
    set(QStringLiteral("playlist"), newList);
}

void AppState::incrementLikedCount(int index) {
    // 1. 构造该项 liked_count 的完整路径
    QString path = QStringLiteral("playlist[%1].liked_count").arg(index);

    // 2. 获取当前值（如果不存在或非数字，toInt 会返回 0）
    int currentCount = get(path).toInt();

    // 3. 写回自增后的值
    set(path, currentCount + 1);
}
//=====================current_track================

void AppState::setCurrentTrack(const QVariantMap& trackData) {
    // 获取现有的 current_track 模板以补全缺失字段（可选，保证结构完整性）
    QVariantMap current = get("current_track").toMap();

    // 合并新数据
    for (auto it = trackData.constBegin(); it != trackData.constEnd(); ++it) {
        current[it.key()] = it.value();
    }

    // 整体写回
    set(QStringLiteral("current_track"), current);
}

void AppState::updateCurrentTrackField(const QString& field, const QVariant& value) {
    // 利用万能 set 接口直接定位字段，例如 "current_track.position"
    set(QStringLiteral("current_track.%1").arg(field), value);
}

//=================last_session ========================

void AppState::syncCurrentToLastSession() {
    // 1. 定义映射关系: [last_session字段] -> [current_track字段]
    QMap<QString, QString> mapping = {
        {"index",      "current_track.index"},
        {"path",       "current_track.path"},
        {"position",   "current_track.position"},
        {"lyric_bind", "current_track.lyric_bind"}
    };

    // 2. 遍历并同步
    auto it = mapping.constBegin();
    while (it != mapping.constEnd()) {
        QVariant value = get(it.value()); // 从 current_track 提取
        set(QStringLiteral("last_session.%1").arg(it.key()), value); // 填充到 last_session
        ++it;
    }

    // 3. 特殊处理：播放模式通常不在 current_track 里，直接从全局同步一次
    set("last_session.play_mode", get("play_mode"));
}




// =============== 可选：播放模式便捷接口 ===============

QString AppState::currentPlayMode() const
{
     return get("play_mode").toString();

}

void AppState::setCurrentPlayMode(PlayMode mode)
{
    set("play_mode", playModeToString(mode));
}




//=========================== 可选=================




void AppState::mergeStates(const QVariantMap& loaded) {
    // 调用内部递归函数，从根部开始合并
    recursiveMerge(m_state, loaded);
}

// 内部辅助函数（建议放在 private 作用域）
// void AppState::recursiveMerge(QVariantMap& base, const QVariantMap& loaded) {
//     for (auto it = loaded.constBegin(); it != loaded.constEnd(); ++it) {
//         const QString& key = it.key();
//         const QVariant& newValue = it.value();

//         // 核心规则：如果 m_state 模板里没有这个键，则直接忽略（保持模板纯净）
//         if (!base.contains(key)) {
//             continue;
//         }

//         // 情况 A：两边都是 Map，递归合并
//         if (base[key].canConvert<QVariantMap>() && newValue.canConvert<QVariantMap>()) {
//             QVariantMap baseSubMap = base[key].toMap();
//             recursiveMerge(baseSubMap, newValue.toMap());
//             base[key] = baseSubMap;
//         }
//         // 情况 B：基础类型或列表，直接用加载的数据覆盖模板默认值
//         else {
//             base[key] = newValue;
//         }
//     }
// }

void AppState::recursiveMerge(QVariantMap& base, const QVariantMap& loaded) {
    for (auto it = loaded.constBegin(); it != loaded.constEnd(); ++it) {
        const QString& key = it.key();
        const QVariant& newValue = it.value();

        // 1. 显式跳过不需要合并的键
        // 确保程序启动时 is_playing 始终维持模板中的 false，不被上次保存的状态覆盖
        if (key == QLatin1String("is_playing")) {
            continue;
        }

        // 2. 核心规则：如果 base 模板里没有这个键，则直接忽略
        if (!base.contains(key)) {
            continue;
        }

        // 情况 A：两边都是 Map，递归合并
        if (base[key].canConvert<QVariantMap>() && newValue.canConvert<QVariantMap>()) {
            QVariantMap baseSubMap = base[key].toMap();
            recursiveMerge(baseSubMap, newValue.toMap());
            base[key] = baseSubMap;
        }
        // 情况 B：基础类型或列表，直接覆盖
        else {
            base[key] = newValue;
        }
    }
}


