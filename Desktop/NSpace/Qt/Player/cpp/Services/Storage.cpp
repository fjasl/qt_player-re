#include "Storage.h"
#include <QFile>
#include <QJsonDocument>
#include <QStandardPaths>
#include <QDir>
#include <QJsonObject>
#include <QSaveFile>
#include <QCoreApplication>


Storage& Storage::instance() {
    static Storage inst;
    return inst;
}

Storage::Storage(QObject* parent)
    : QObject(parent)
{
}

QString Storage::stateFilePath() const {
    // auto dir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    // QDir().mkpath(dir);
    // return dir + "/app_state.json";
    // 获取可执行文件所在的目录
    QString dir = QCoreApplication::applicationDirPath();

    // 构造完整路径
    return QDir(dir).filePath("app_state.json");

}

void Storage::saveState(const QVariantMap& state) {
    // 使用 QSaveFile 保证原子写入，防止断电导致文件损坏
    QSaveFile f(stateFilePath());
    if (!f.open(QIODevice::WriteOnly)) {
        qWarning() << "Could not open file for saving:" << f.errorString();
        return;
    }

    QJsonDocument doc(QJsonObject::fromVariantMap(state));
    // 写入数据
    f.write(doc.toJson(QJsonDocument::Indented));

    // 只有 commit 成功，才会真正替换原文件
    if (!f.commit()) {
        qWarning() << "Failed to commit state save!";
    }
}

QVariantMap Storage::loadState() {
    QFile f(stateFilePath());
    if (!f.exists()) return {};

    if (!f.open(QIODevice::ReadOnly)) {
        qWarning() << "Could not open state file for reading";
        return {};
    }

    QJsonParseError error;
    auto doc = QJsonDocument::fromJson(f.readAll(), &error);
    f.close();

    if (error.error != QJsonParseError::NoError) {
        qWarning() << "JSON Parse Error:" << error.errorString();
        return {};
    }

    return doc.object().toVariantMap();
}
