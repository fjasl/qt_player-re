#ifndef EXTRACTMETADATA_H
#define EXTRACTMETADATA_H
#include <QString>
#include <QVariantMap>

class MusicMetadataHelper {
public:
    // 输入文件路径，返回包含所有标签信息的键值对
    static QVariantMap extractMetadata(const QString &filePath);
};
#endif // EXTRACTMETADATA_H
