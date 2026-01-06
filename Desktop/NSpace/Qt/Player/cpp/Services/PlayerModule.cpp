#include "PlayerModule.h"
#include "Connector.h" // 对应你的 StateMachine 类
#include "EventBus.h"
#include "StoreState.h"
#include "Storage.h"
#include <taglib/fileref.h>
#include <taglib/tag.h>
#include <taglib/audioproperties.h>
#include "extractMetaData.h"
#include <QDebug>
#include <QFileInfo>

#include <QVariantMap>  // 必须：用于识别 QMediaMetaData::CoverArtImage
#include <QImage>           // 必须：用于处理 QImage 对象
#include <QByteArray>       // 必须：用于存储二进制数据
#include <QBuffer>          // 必须：用于将图片数据写入内存缓冲区
#include <QVariant>         // 必须：用于处理 QVariant 转换
#include <QString>          // 必须：用于拼接 Base64 字符串
#include <QDebug>           // 建议：用于调试打印日志
#include <QFileDialog>      // 新增：用于 QFileDialog
#include <QApplication>
#include <QRandomGenerator>



// 注意：不要再写 class PlayerModule { ... }
// 直接实现 init 方法
void PlayerModule::init() {


    auto& sm = Connector::instance();

    auto getNextTrackDelegate = [](AppState* state, AppState::PlayMode mode) -> int {
        if (!state) return -1;

        QVariantMap currentTrack = state->get("current_track").toMap();
        int curIdx = currentTrack.value("index", 0).toInt();
        int total = state->get("playlist").toList().size();

        if (total <= 0) return -1;

        switch (mode) {
        case AppState::PlayMode::SingleLoop:
            return curIdx;

        case AppState::PlayMode::Shuffle: {
            // 如果列表只有 1 首歌，随机结果只能是自己
            if (total <= 1) return 0;

            int nextIdx = curIdx;
            // 2026 推荐做法：通过循环排除当前索引，确保下一首不一样
            while (nextIdx == curIdx) {
                nextIdx = QRandomGenerator::global()->bounded(total);
            }
            return nextIdx;
        }

        default:
            return (curIdx + 1) % total;
        }
    };






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

                // --- 新增逻辑：初始化检查 ---
                // 获取当前的 current_track 状态
                QVariantMap currentTrack = ctx.appState->get("current_track").toMap();

                // 如果 index 为 -1，说明当前没在播放任何歌曲
                if (currentTrack.value("index").toInt() == -1 && !currentList.isEmpty()) {
                    qDebug() << "[Player] 检测到播放列表初始化，将第一首歌曲设为待播放状态";

                    // 1. 获取第一首歌的路径
                    QVariantMap firstTrackFromList = currentList.first().toMap();
                    QString firstPath = firstTrackFromList.value("path").toString();

                    // 2. 提取元数据 (包含标题、艺术家、时长、封面)
                    QVariantMap metadata = MusicMetadataHelper::extractMetadata(firstPath);

                    if (metadata.value("success").toBool()) {
                        // 3. 构造新的 current_track 状态
                        QVariantMap newCurrentTrack = AppState::CurrentTrackTemplate;
                        newCurrentTrack["index"] = 0;
                        newCurrentTrack["path"] = firstPath;
                        newCurrentTrack["title"] = metadata.value("title");
                        newCurrentTrack["artist"] = metadata.value("artist");
                        newCurrentTrack["position"] = 0;
                        newCurrentTrack["duration"] = metadata.value("duration");
                        newCurrentTrack["cover"] = metadata.value("cover"); // Base64

                        // 4. 更新 AppState
                        ctx.appState->setCurrentTrack(newCurrentTrack);
                        QVariantMap payload;
                        payload["current_track"] = newCurrentTrack;
                        EventBus::instance().emitEvent("playlist_changed", {payload});
                    }



                }
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
    sm.registerHandler("list_track_play","player_list_track_play",[=](const QVariantMap& data,const Context& ctx){
        int index = data.value("index").toInt();
        qDebug() << "[Player] 请求播放 index:" << index << "的音乐";

        QVariantList currentPlaylist = ctx.appState->get("playlist").toList();

        if (index < 0 || index >= currentPlaylist.size()) {
            qWarning() << "[Player] 播放失败：索引越界";
            return;
        }

        QVariantMap item = currentPlaylist.at(index).toMap();
        QString filePath = item.value("path").toString();

        if (filePath.isEmpty()) {
            qWarning() << "[Player] 播放失败：文件路径为空";
            return;
        }

        // 1. 提取元数据
        QVariantMap metadata = MusicMetadataHelper::extractMetadata(filePath);

        // 2. 整合完整的 current_track 数据
        // 将 playlist 中的基础信息 (index, path) 与 TagLib 提取的元数据合并
        QVariantMap currentTrack = metadata;
        currentTrack["index"] = index;
        currentTrack["path"] = filePath;
        // 确保 position 初始为 0
        currentTrack["position"] = 0;
        currentTrack["title"] = metadata.value("title");
        currentTrack["artist"] = metadata.value("artist");
        currentTrack["duration"] = metadata.value("duration");
        currentTrack["cover"] = metadata.value("cover"); // Base64

        // 3. 更新全局状态 AppState
        ctx.appState->set("current_track", currentTrack);


        // 4. 发送事件通知 QML 同步 UI
        // 假设你的 EventBus 接受事件名和数据载荷
        QVariantMap payload;
        payload["current_track"] = currentTrack;

        EventBus::instance().emitEvent("current_track", payload);

        ctx.appState->set("is_playing", true); // 更新播放状态
        payload["is_playing"] = true;
        EventBus::instance().emitEvent("player_state_changed",payload);


        QVariantList& history = ctx.appState->playlistRecord;
        int currentIndex = ctx.appState->get("current_track").toMap().value("index").toInt();
        if (history.isEmpty() || history.last().toInt() != currentIndex) {
            history.append(currentIndex);

            // 限制长度为 50
            if (history.size() > 50) {
                history.removeFirst();
            }
        }



        qDebug() << "[Player] 状态已更新并下发，当前索引:" << index;
    });
    sm.registerHandler("play_toggle", "player_play_toggle", [](const QVariantMap& data, const Context& ctx) {
        // 1. 获取当前播放状态
        bool isPlaying = ctx.appState->get("is_playing").toBool();

        // 2. 取反状态
        bool nextState = !isPlaying;

        // 3. 更新全局状态机
        ctx.appState->set("is_playing", nextState);

        // 5. 组装下发载荷
        QVariantMap payload;
        payload["is_playing"] = nextState;
        //payload["current_track"] = currentTrack; // 带上曲目信息确保前端同步

        // 6. 发送事件通知 UI 和音频引擎
        EventBus::instance().emitEvent("player_state_changed", payload);

        qDebug() << "[Player] 播放状态切换至:" << (nextState ? "播放" : "暂停");
    });

    sm.registerHandler("position_report", "player_position_report", [](const QVariantMap& data, const Context& ctx) {
        // 1. 从 payload 中获取进度（MediaPlayer 的 position 是毫秒）
        qint64 pos = data.value("position").toLongLong();

        // 2. 获取当前的 current_track 结构
        QVariantMap currentTrack = ctx.appState->get("current_track").toMap();

        // 3. 更新进度字段
        currentTrack["position"] = pos;

        ctx.appState->set("current_track", currentTrack);
    });

    sm.registerHandler("seek", "player_seek", [](const QVariantMap& data, const Context& ctx) {
        // 1. 获取前端传来的百分比 (0.0 ~ 1.0)
        double percent = data.value("percent").toDouble();

        // 2. 获取当前曲目信息，计算目标毫秒数
        QVariantMap currentTrack = ctx.appState->get("current_track").toMap();
        qint64 duration = currentTrack.value("duration").toLongLong(); // 假设 duration 单位是秒

        // 注意：如果你的 duration 单位是秒，需要 * 1000 转为毫秒
        // 如果提取元数据时存的就是毫秒，则直接相乘
        qint64 targetPosition = static_cast<qint64>(duration * 1000 * percent);

        qDebug() << "[Player] 跳转请求 - 比例:" << percent << "目标位置:" << targetPosition << "ms";

        // 3. 更新内存中的 position
        currentTrack["position"] = targetPosition;
        ctx.appState->set("current_track", currentTrack);

        // 4. 发送事件通知 QML 执行跳转
        QVariantMap payload;
        //payload["current_track"] = currentTrack;
        payload["target_position"] = targetPosition; // 额外带上此字段方便 QML 直接读取

        EventBus::instance().emitEvent("seek_handled", payload);
    });
    // 注册：手动点击下一首
    sm.registerHandler("play_next", "player_play_next", [=](const QVariantMap& data, const Context& ctx){
        // 1. 计算下一首索引
        QString modeStr = ctx.appState->currentPlayMode();

        // 2. 映射为枚举值
        AppState::PlayMode currentMode = ctx.appState->stringToPlayMode(modeStr);
        int nextIdx = getNextTrackDelegate(ctx.appState, currentMode);

        if (nextIdx == -1) return;

        // --- 关键对比逻辑 ---
        // 获取当前正在播放的索引
        int currentIdx = ctx.appState->get("current_track").toMap().value("index", -1).toInt();



        QVariantList playlist = ctx.appState->get("playlist").toList();
        QVariantMap item = playlist.at(nextIdx).toMap();
        QString filePath = item.value("path").toString();

        if (filePath.isEmpty()) return;

        // 3. 提取元数据
        QVariantMap metadata = MusicMetadataHelper::extractMetadata(filePath);

        // 4. 构造并存入状态
        QVariantMap currentTrack = metadata;
        currentTrack["index"] = nextIdx;
        currentTrack["path"] = filePath;
        currentTrack["position"] = 0;
        // 确保 position 初始为 0
        currentTrack["title"] = metadata.value("title");
        currentTrack["artist"] = metadata.value("artist");
        currentTrack["duration"] = metadata.value("duration");
        currentTrack["cover"] = metadata.value("cover"); // Base64
        ctx.appState->set("current_track", currentTrack);


        // 5. 发送完整更新事件
        QVariantMap payload;

        payload["current_track"] = currentTrack;
        EventBus::instance().emitEvent("current_track", payload);
        ctx.appState->set("is_playing", true);
        payload["is_playing"] = true;
        EventBus::instance().emitEvent("player_state_changed",payload);


        if (nextIdx == currentIdx) {

        }else{


            QVariantList& history = ctx.appState->playlistRecord;
            int currentIndex = ctx.appState->get("current_track").toMap().value("index").toInt();
            if (history.isEmpty() || history.last().toInt() != currentIndex) {
                history.append(currentIndex);

                // 限制长度为 50
                if (history.size() > 50) {
                    history.removeFirst();
                }
            }

        }




    });

    sm.registerHandler("switch_mode", "player_switch_mode", [=](const QVariantMap& data, const Context& ctx) {
        // 1. 先通过字符串反推当前枚举（或者从 AppState 逻辑获取）
        // 假设你存的是字符串，逻辑上也要能转回来做切换
        QString currentModeStr = ctx.appState->get("play_mode").toString();

        // 简单的切换逻辑
        AppState::PlayMode nextMode = (currentModeStr == QStringLiteral("single_loop"))
                                          ? AppState::Shuffle
                                          : AppState::SingleLoop;

        // 2. 直接调用 playModeToString 存入字符串！
        // 这样 syncCurrentToLastSession 时存入磁盘的就是 "single_loop" 而不是 0
        QString nextModeStr = ctx.appState->playModeToString(nextMode);
        ctx.appState->set("play_mode", nextModeStr);

        // 3. 发送给 QML 的也是字符串
        QVariantMap payload;
        payload["play_mode"] = nextModeStr;

        EventBus::instance().emitEvent("mode_switched", payload);

        qDebug() << "[Player] 播放模式已更新为字符串:" << nextModeStr;
    });

    sm.registerHandler("play_prev", "player_play_prev", [=](const QVariantMap& data, const Context& ctx){

        QVariantList& history = ctx.appState->playlistRecord;

        // 安全检查
        if (history.size() == 1) {
            // 历史中只有当前这首（或为空），无法回到“上一首”
            qDebug() << "[Player] 没有上一首可返回";
            // 可以选择播放第一首、保持当前、或暂停等
            return;
        }

        // 1. 移除当前这首（栈顶）
        history.removeLast();

        // 2. 拿到新的栈顶（原来的倒数第二个）
        int targetIdx = history.last().toInt();

        QVariantList currentPlaylist = ctx.appState->get("playlist").toList();

        if (targetIdx < 0 || targetIdx >= currentPlaylist.size()) {
            qWarning() << "[Player] 播放失败：索引越界";
            return;
        }

        QVariantMap item = currentPlaylist.at(targetIdx).toMap();
        QString filePath = item.value("path").toString();

        if (filePath.isEmpty()) {
            qWarning() << "[Player] 播放失败：文件路径为空";
            return;
        }

        // 1. 提取元数据
        QVariantMap metadata = MusicMetadataHelper::extractMetadata(filePath);

        // 2. 整合完整的 current_track 数据
        // 将 playlist 中的基础信息 (index, path) 与 TagLib 提取的元数据合并
        QVariantMap currentTrack = metadata;
        currentTrack["index"] = targetIdx;
        currentTrack["path"] = filePath;
        // 确保 position 初始为 0
        currentTrack["position"] = 0;

        // 3. 更新全局状态 AppState
        ctx.appState->set("current_track", currentTrack);

        QVariantMap payload;
        payload["current_track"] = currentTrack;

        EventBus::instance().emitEvent("current_track", payload);

        ctx.appState->set("is_playing", true); // 更新播放状态
        payload["is_playing"] = true;
        EventBus::instance().emitEvent("player_state_changed",payload);
    });
    sm.registerHandler("list_track_del","player_list_track_del",[](const QVariantMap& data,const Context& ctx){
        int index = data.value("index").toInt();


        ctx.appState->removeSong(index);

        QVariantMap payload;
        payload["playlist"] = ctx.appState->get("playlist");

        EventBus::instance().emitEvent("playlist_changed",payload);



    });




}

