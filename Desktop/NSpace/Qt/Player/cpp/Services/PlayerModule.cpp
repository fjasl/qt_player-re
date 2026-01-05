#include "PlayerModule.h"
#include "Connector.h" // 对应你的 StateMachine 类
#include "EventBus.h"
#include "StoreState.h"
#include "Storage.h"
#include <QVariantMap>  // 必须：用于识别 QMediaMetaData::CoverArtImage
#include <QImage>           // 必须：用于处理 QImage 对象
#include <QByteArray>       // 必须：用于存储二进制数据
#include <QBuffer>          // 必须：用于将图片数据写入内存缓冲区
#include <QVariant>         // 必须：用于处理 QVariant 转换
#include <QString>          // 必须：用于拼接 Base64 字符串
#include <QDebug>           // 建议：用于调试打印日志
#include <QFileDialog>      // 新增：用于 QFileDialog
#include <QApplication>


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
    sm.registerHandler("open_file","player_open_file",[](const QVariantMap& data, const Context& ctx){
        qDebug() << "[Player] 收到 open_file 请求，打开文件选择对话框";

        // 1. 获取合适的父窗口（推荐：当前活动窗口，避免对话框无父窗口）
        QWidget* parentWidget = QApplication::activeWindow();

        // 2. 创建通用文件对话框
        QFileDialog dialog(parentWidget);
        dialog.setWindowTitle("选择音乐文件");
        dialog.setFileMode(QFileDialog::ExistingFiles);  // 支持多选
        dialog.setNameFilter("音频文件 (*.mp3 *.flac *.wav *.ogg *.m4a *.wma *.aac);;所有文件 (*.*)");

        // 可选：记住上一次打开的目录
        static QString lastDir;
        if (!lastDir.isEmpty()) dialog.setDirectory(lastDir);

        // 3. 执行对话框（阻塞方式，适合事件处理器）
        if (dialog.exec() == QDialog::Accepted) {
            QStringList filePaths = dialog.selectedFiles();

            if (filePaths.isEmpty()) {
                qWarning() << "[Player] 用户未选择任何文件";
                return;
            }

            qDebug() << "[Player] 用户选择了" << filePaths.size() << "个文件";

            // ------------------- 你自己的逻辑写在这里 -------------------
            // QVariantList currentList = ctx.appState->get("playlist").toList();

            // QVariantMap newTrack = AppState::TrackTemplate;
            // for(const QString& path : filePaths){
            //     newTrack["path"] = path;
            //     newTrack["lyric_bind"] = "";
            //     newTrack["liked_count"] = 0;
            //     currentList.append(newTrack);
            // }
            // ctx.appState->setPlaylist(currentList);
            // Storage::instance().saveState(ctx.appState->getState());
            // qDebug() << "[Player] 存储了文件" ;

            QVariantList currentList = ctx.appState->get("playlist").toList();

            // 2. 构建一个现有的路径集合，用于快速查重（O(1) 查询）
            QSet<QString> existingPaths;
            existingPaths.reserve(currentList.size());  // 优化：预分配空间，避免频繁 rehash

            for (const QVariant& item : std::as_const(currentList)) {
                const QVariantMap track = item.toMap();
                QString path = track.value("path").toString();
                if (!path.isEmpty()) {
                    existingPaths.insert(path);
                }
            }

            // 3. 遍历用户选择的文件，只添加不存在的
            int addedCount = 0;
            QVariantMap trackTemplate = AppState::TrackTemplate;  // 使用公共模板

            for (const QString& path : filePaths) {
                if (path.isEmpty()) {
                    continue;  // 防御性检查
                }

                // 如果已经存在，跳过
                if (existingPaths.contains(path)) {
                    qDebug() << "[Player] 跳过重复文件:" << path;
                    continue;
                }

                // 不存在 → 新建 track 并追加
                QVariantMap newTrack = trackTemplate;  // 拷贝模板（高效）
                newTrack["path"] = path;
                newTrack["lyric_bind"] = "";
                newTrack["liked_count"] = 0;
                // 如果你以后想从文件名提取标题，可以在这里加逻辑
                // newTrack["title"] = QFileInfo(path).completeBaseName();

                currentList.append(newTrack);
                existingPaths.insert(path);  // 同步更新集合，防止同一批次内重复（极少见但保险）
                ++addedCount;
            }

            // 4. 如果有新增，才更新状态和保存（避免无意义 I/O）
            if (addedCount > 0) {
                ctx.appState->setPlaylist(currentList);
                Storage::instance().saveState(ctx.appState->getState());
                qDebug() << "[Player] 成功添加" << addedCount << "首新歌曲，已自动去重";
            } else {
                qDebug() << "[Player] 未添加任何新歌曲（全部重复或路径无效）";
            }

            // -------------------------------------------------------

            // 如果你需要记住本次打开的目录，可取消下面注释
            lastDir = dialog.directory().absolutePath();

            QVariantMap payload;
            payload["playlist"] = currentList;

            EventBus::instance().emitEvent("playlist_changed", {payload});
            qDebug() << "[Player] 成功通知qml";
        } else {
            qDebug() << "[Player] 用户取消了文件选择";
            // 用户取消，无需额外处理
        }
    });

}

