#include "PlayerModule.h"
#include "Connector.h" // 对应你的 StateMachine 类
#include "EventBus.h"
#include <QVariantMap>  // 必须：用于识别 QMediaMetaData::CoverArtImage
#include <QImage>           // 必须：用于处理 QImage 对象
#include <QByteArray>       // 必须：用于存储二进制数据
#include <QBuffer>          // 必须：用于将图片数据写入内存缓冲区
#include <QVariant>         // 必须：用于处理 QVariant 转换
#include <QString>          // 必须：用于拼接 Base64 字符串
#include <QDebug>           // 建议：用于调试打印日志


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

    sm.registerHandler("cover_request", "player_cover_request", [](const QVariantMap& data, const Context& ctx) {
        // 1. 从播放器元数据中提取 QVariant (假设你已经拿到了 metaData)
        // 你的日志显示这是一个 QVariant(QImage)
        QVariant rawImage = data.value("image");

        if (rawImage.canConvert<QImage>()) {
            QImage img = rawImage.value<QImage>();

            // 2. 将 QImage 转为 Base64 字符串
            QByteArray ba;
            QBuffer buffer(&ba);
            buffer.open(QIODevice::WriteOnly);
            img.save(&buffer, "JPG"); // 建议使用 JPG 减小传输体积

            QString base64Data = QString("data:image/jpeg;base64,") + ba.toBase64();

            // 3. 通过 EventBus 发送给前端
            QVariantMap payload;
            payload["base64"] = base64Data;
            EventBus::instance().emitEvent("cover_request_reply", payload);

            qDebug() << "[Connector] Cover sent to frontend, size:" << base64Data.length();
        } else {
            qWarning() << "[Connector] No valid cover image found in metadata";
        }


    });
}

