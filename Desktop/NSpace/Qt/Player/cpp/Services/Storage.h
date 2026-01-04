#pragma once

#include <QObject>
#include <QVariantMap>

class Storage : public QObject {
    Q_OBJECT
public:
    static Storage& instance();

    QVariantMap loadState();
    void saveState(const QVariantMap& state);

private:
    explicit Storage(QObject* parent = nullptr);
    QString stateFilePath() const;
};
