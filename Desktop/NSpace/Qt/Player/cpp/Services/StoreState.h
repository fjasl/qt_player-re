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

    // 如果你还想暴露当前播放模式（可选）
    PlayMode currentPlayMode() const;
    void setCurrentPlayMode(PlayMode mode);
    void mergeStates(QVariantMap& base, const QVariantMap& loaded);
    QVariantMap getState() const { return m_state; }

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

