#include "LifeStageModule.h"  // 确保包含正确的头文件
#include "Connector.h"
#include "EventBus.h"
#include "StoreState.h"
#include "Storage.h"

// 现在编译器就能识别 LifeStageModule 类了
void LifeStageModule::init() {
    auto& sm = Connector::instance();

    sm.registerHandler("window_ready","player_window_ready",[](const QVariantMap& data,const Context& ctx){

        QVariantMap payload;
        payload["playlist"] = ctx.appState->get("playlist");

        EventBus::instance().emitEvent("playlist_changed", {payload});
        qDebug() << "[Player] 成功通知qml2";
    });



}
