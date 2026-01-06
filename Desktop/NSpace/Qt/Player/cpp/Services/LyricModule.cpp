
#include "Connector.h"
#include "EventBus.h"
#include "StoreState.h"
#include "Storage.h"
#include "LyricModule.h"
#include <QFileDialog>
#include <QApplication>

// 现在编译器就能识别 LifeStageModule 类了
void LyricModule::init() {
    auto& sm = Connector::instance();

    sm.registerHandler("lyric_bind","player_lyric_bind",[](const QVariantMap& data,const Context& ctx){
        int index = data.value("index").toInt();

        // 1. 获取父窗口并配置单选对话框
        QWidget* parentWidget = QApplication::activeWindow();
        QFileDialog dialog(parentWidget);
        dialog.setWindowTitle(QObject::tr("选择歌词文件"));
        dialog.setFileMode(QFileDialog::ExistingFile); // 关键：设置为单选模式
        dialog.setNameFilter(QObject::tr("歌词文件 (*.lrc);;所有文件 (*.*)"));

        static QString lastLrcDir;
        if (!lastLrcDir.isEmpty()) dialog.setDirectory(lastLrcDir);

        // 2. 执行对话框
        if (dialog.exec() == QDialog::Accepted) {
            QStringList selected = dialog.selectedFiles();
            if (selected.isEmpty()) return;

            QString lrcPath = selected.first();
            lastLrcDir = QFileInfo(lrcPath).absolutePath();
            ctx.appState->setTrackLyric(index,lrcPath);

            Storage::instance().saveState(ctx.appState->getState());
            qDebug() << "[Player] 用户选择歌词:" << lrcPath;


        } else {
            qDebug() << "[Player] 用户取消了歌词选择";
        }


    });



}
