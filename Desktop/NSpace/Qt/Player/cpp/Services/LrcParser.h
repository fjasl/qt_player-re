#ifndef LRCPARSER_H
#define LRCPARSER_H

#include <QString>
#include <QList>
#include <QStringView>

struct LyricLine {
    double time;    // 毫秒级秒数
    QString text;   // 歌词文本
};

class LrcParser {
public:
    explicit LrcParser() = default;

    // 解析 LRC 文件
    bool loadAndParseLrcFile(const QString &filePath);

    // 二分查找：O(log N) 效率最高
    int findLyricByTime(double currentTimeInSeconds) const;

    // 获取完整列表
    const QList<LyricLine>& getParsedLyrics() const { return m_list; }

private:
    QList<LyricLine> m_list;

    // 内部工具：使用 QStringView 避免中间字符串拷贝
    double timeToSeconds(QStringView timestamp);
};

#endif
