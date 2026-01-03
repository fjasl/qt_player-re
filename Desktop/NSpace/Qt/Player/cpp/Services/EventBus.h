// EventBus.h
#include <QObject>
#include <QVariantMap>

class EventBus : public QObject {
    Q_OBJECT
public:
    static EventBus& instance() {
        static EventBus inst;
        return inst;
    }

    // 当后端处理完逻辑，通过此方法通知前端
    void emitEvent(const QString& eventName, const QVariantMap& payload) {
        emit backendEvent(eventName, payload);
    }

signals:
    // QML 监听这个信号
    void backendEvent(QString event, QVariantMap payload);

private:
    explicit EventBus(QObject *parent = nullptr) : QObject(parent) {}
};
