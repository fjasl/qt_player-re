#include "LrcParser.h"
#include <QFile>
#include <QTextStream>
#include <QRegularExpression>
#include <QDebug>

// 优化 1: 使用 QStringView 处理时间戳，彻底避免 split() 产生的临时字符串
double LrcParser::timeToSeconds(QStringView timestamp) {
    int colonIdx = timestamp.indexOf(':');
    if (colonIdx == -1) return -1.0;

    bool ok;
    int minutes = timestamp.left(colonIdx).toInt(&ok);
    if (!ok) return -1.0;

    QStringView rest = timestamp.mid(colonIdx + 1);
    int dotIdx = rest.indexOf('.');

    double seconds = 0.0;
    double milliseconds = 0.0;

    if (dotIdx == -1) {
        seconds = rest.toDouble(&ok);
    } else {
        seconds = rest.left(dotIdx).toDouble(&ok);
        QStringView msView = rest.mid(dotIdx + 1).left(3); // 取毫秒前三位
        QString msStr = msView.toString();
        // 补齐位数，例如 .1 变为 100ms
        while (msStr.length() < 3) msStr += '0';
        milliseconds = msStr.toDouble();
    }

    return minutes * 60.0 + seconds + (milliseconds / 1000.0);
}

bool LrcParser::loadAndParseLrcFile(const QString &filePath) {
    m_list.clear();

    if (filePath.isEmpty()) {
        m_list.append({0.0, "纯音乐，请欣赏"});
        return true;
    }

    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) return false;

    // 优化 2: 预分配内存，减少 QList 扩容拷贝开销
    m_list.reserve(200);

    QTextStream in(&file);
    in.setEncoding(QStringConverter::Utf8); // Qt 6 明确编码

    // 优化 3: 静态正则表达式，避免每次解析行都重新构建正则引擎
    static const QRegularExpression lineRegex(R"(^\[(\d+:\d+(?:\.\d+)?)\](.*))");

    while (!in.atEnd()) {
        QString line = in.readLine().trimmed();
        if (line.isEmpty()) continue;

        auto match = lineRegex.match(line);
        if (match.hasMatch()) {
            // 使用 match.capturedView 进一步减少拷贝（Qt 6 特性）
            double timeVal = timeToSeconds(match.capturedView(1));
            QString text = match.captured(2).trimmed();

            if (timeVal >= 0 && !text.isEmpty()) {
                m_list.append({timeVal, std::move(text)}); // 使用 move 语义
            }
        }
    }

    // 排序保持一致性
    std::sort(m_list.begin(), m_list.end(), [](const LyricLine &a, const LyricLine &b) {
        return a.time < b.time;
    });

    return !m_list.isEmpty();
}

// 优化 4: 使用 std::upper_bound 实现二分查找，性能从 O(N) 提升到 O(log N)
int LrcParser::findLyricByTime(double currentTimeInSeconds) const {
    if (m_list.isEmpty()) return 0;

    // 查找第一个时间大于当前时间的元素
    auto it = std::upper_bound(m_list.begin(), m_list.end(), currentTimeInSeconds,
                               [](double val, const LyricLine& line) {
                                   return val < line.time;
                               });

    // 如果 it 指向第一个，说明还没开始唱
    if (it == m_list.begin()) return 0;

    // 返回前一个元素的索引
    return static_cast<int>(std::distance(m_list.begin(), std::prev(it)));
}
