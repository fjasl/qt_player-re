// StateMachine.h
#include "StoreState.h"
#include <QObject>
#include <QVariantMap>
#include <functional>
#include <QDebug>
#include <QList>
#include <QMap>

// 定义上下文结构，模拟 Node 里的 ctx
struct Context {
    // 可以在这里持有指向其他管理类的指针
    AppState* appState = nullptr;
    void* storage;
    QObject* eventBus;
};



using HandlerFunc = std::function<void(const QVariantMap&, const Context&)>;

struct HandlerEntry {
    QString name;
    HandlerFunc func;
};

class Connector : public QObject {
    Q_OBJECT
public:
    static Connector& instance() {
        static Connector inst;
        return inst;
    }


    /** 设置当前使用的 AppState 实例（最常用） */
    void setAppState(AppState* state)
    {
        m_context.appState = state;
        qDebug() << "[Connector] AppState pointer set:" << (state ? "valid" : "nullptr");
    }

    /** 设置通用 storage 指针（如果你需要） */
    void setStorage(void* storage)
    {
        m_context.storage = storage;
    }

    /** 设置 eventBus（如果你有 EventBus 单例） */
    void setEventBus(QObject* bus)
    {
        m_context.eventBus = bus;
    }


    /**
     * @param intent 事件意图 (例如 "media_play")
     * @param handlerName 回调的唯一标识名称 (用于查重)
     * @param fn 回调函数
     */
    void registerHandler(const QString& intent, const QString& handlerName, HandlerFunc fn) {
        // 1. 获取（或创建）该 intent 对应的回调列表
        QList<HandlerEntry>& entries = m_handlers[intent];

        // 2. 检查是否有重复名称的回调
        for (const auto& entry : entries) {
            if (entry.name == handlerName) {
                qWarning() << "[Connetor] Duplicate handler name ignored!"
                           << "Intent:" << intent
                           << "HandlerName:" << handlerName;
                return; // 重名，直接丢弃
            }
        }

        // 3. 无重复，存入列表
        entries.append({handlerName, fn});
        qDebug() << "[Connetor] Handler registered:" << intent << "->" << handlerName;
    }

    /**
    * @brief 反注册指定 intent 下的 handler
    * @return true = 找到并移除，false = 未找到
    */

    bool unregisterHandler(const QString& intent,
                                     const QString& handlerName)
    {
        if (!m_handlers.contains(intent)) {
            return false;
        }

        QList<HandlerEntry>& entries = m_handlers[intent];

        for (int i = 0; i < entries.size(); ++i) {
            if (entries[i].name == handlerName) {
                entries.removeAt(i);

                qDebug() << "[Connetor] Handler unregistered:"
                         << intent << "->" << handlerName;

                // 如果该 intent 下已经没有 handler 了，顺手清理
                if (entries.isEmpty()) {
                    m_handlers.remove(intent);
                }

                return true;
            }
        }

        return false;
    }


    // Q_INVOKABLE 分发事件
    Q_INVOKABLE void dispatch(const QString& intent, const QVariantMap& payload = QVariantMap()) {
        if (!m_handlers.contains(intent) || m_handlers[intent].isEmpty()) {
            qWarning() << "[Connetor] No handlers registered for intent:" << intent;
            return;
        }

        // Context ctx { nullptr, nullptr }; // 生产环境可传入实际指针

        // 4. 按顺序执行该 intent 下的所有回调
        const QList<HandlerEntry>& entries = m_handlers[intent];
        for (const auto& entry : entries) {
            try {
                entry.func(payload, m_context);
            } catch (...) {
                qCritical() << "[Connetor] Error executing handler:" << entry.name << "for intent:" << intent;
            }
        }
    }

private:
    // 数据结构：意图 -> 顺序列表(回调入口)
    QMap<QString, QList<HandlerEntry>> m_handlers;
    // 统一的 Context 实例，所有 handler 共享
    Context m_context;
    explicit Connector(QObject *parent = nullptr) : QObject(parent) {}
};
