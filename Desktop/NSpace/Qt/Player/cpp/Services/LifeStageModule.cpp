#include "LifeStageModule.h"  // 确保包含正确的头文件
#include "Connector.h"
#include "EventBus.h"
#include "StoreState.h"

// 现在编译器就能识别 LifeStageModule 类了
void LifeStageModule::init() {
    auto& sm = Connector::instance();

    sm.registerHandler("window_ready","player_window_ready",[](const QVariantMap& data,const Context& ctx){

        QVariantMap payload;
        payload["playlist"] = ctx.appState->get("playlist");

        EventBus::instance().emitEvent("playlist_changed", {payload});
        qDebug() << "[Player] 加载歌曲列表";



        // 1. 获取 last_session
        QVariantMap session = ctx.appState->get("last_session").toMap();

        // 2. 检查索引是否有效
        if (session.value("index").toInt() == -1) {
            qDebug() << "[Player] last_session 无效，尝试从 playlist[0] 恢复";

            QVariantList playlist = ctx.appState->get("playlist").toList();

            if (!playlist.isEmpty()) {
                // 取第一项内容 (注意：通常数组下标从 0 开始，如果你确定要第 2 个则填 1)
                QVariantMap firstTrack = playlist.at(0).toMap();

                // 将第一项的内容覆盖进 session 变量（作为回退方案）
                session["index"] = 0;
                session["path"] = firstTrack.value("path");
                session["lyric_bind"] = firstTrack.value("lyric_bind");
                session["position"] = 0;
                // 如果需要，也可以同步更新到 AppState 记录中
                ctx.appState->set("last_session", session);
            } else {
                qWarning() << "[Player] 播放列表也为空，无法恢复任何内容";
            }
        }
        payload["current_track"] = session;
        EventBus::instance().emitEvent("current_track", payload);

        //payload["current_track"] = ctx.appState->get("last_session");
        //EventBus::instance().emitEvent("current_track",{payload});


        QVariantList& history = ctx.appState->playlistRecord;
        int currentIndex = ctx.appState->get("current_track").toMap().value("index").toInt();
        history.append(currentIndex);



        payload["play_mode"] = ctx.appState->currentPlayMode();
        EventBus::instance().emitEvent("mode_switched", payload);


    });



}
