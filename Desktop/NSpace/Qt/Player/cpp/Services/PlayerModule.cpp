#include "PlayerModule.h"
#include "Connector.h" // 对应你的 StateMachine 类
#include "EventBus.h"
#include <QVariantMap>

// 注意：不要再写 class PlayerModule { ... }
// 直接实现 init 方法
void PlayerModule::init() {
    auto& sm = Connector::instance();

    // 注册：播放逻辑，增加标识符 "main_player_logic"
    sm.registerHandler("media_play", "main_player_logic", [](const QVariantMap& data, const Context& ctx) {
        qDebug() << "[Player] 执行播放，ID:" << data.value("id").toString();

        QVariantMap payload;
        payload["action"] = "PLAY";
        payload["id"] = data.value("id");

        EventBus::instance().emitEvent("player_cmd", payload);
    });

    // 注册：停止逻辑，增加标识符 "main_stop_logic"
    sm.registerHandler("media_stop", "main_stop_logic", [](const QVariantMap& data, const Context& ctx) {
        qDebug() << "[Player] 执行停止";

        QVariantMap payload;
        payload["action"] = "STOP";

        EventBus::instance().emitEvent("player_cmd", payload);
    });

    sm.registerHandler("media_prev", "prev_button_click", [](const QVariantMap& data, const Context& ctx) {
        qDebug() << "后端收到prev button 点击信号";


        EventBus::instance().emitEvent("test", {});
    });
}

