#include <QApplication>
#include <QQmlApplicationEngine>
#include <QSystemTrayIcon>
#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>         // 必须引入，用于注入对象
#include <QSystemTrayIcon>
#include <QMenu>
#include <QAction>
#include <QQuickWindow>
#include <QDesktopServices>
#include <QUrl>

#include "Connector.h"
#include "EventBus.h"
#include "LogicManager.h"

int main(int argc, char *argv[])
{
    // 1. 必须用 QApplication 以支持原生菜单
    QApplication app(argc, argv);
    app.setQuitOnLastWindowClosed(false);


    // 2. 初始化 C++ 业务逻辑模块 (注册 Handler)
    // 这步必须在引擎加载 QML 之前，确保 QML 触发信号时 Handler 已就绪
    AppLogic::initAll();


    QQmlApplicationEngine engine;

    // 3. 将单例注入 QML 全局环境
    // 这样在 QML 中可以直接使用 Connetor.dispatch(...) 和 EventBus.onBackendEvent
    engine.rootContext()->setContextProperty("Connetor", &Connector::instance());
    engine.rootContext()->setContextProperty("EventBus", &EventBus::instance());



    // 2. 保持你原本的模块加载方式
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    // 注意：这里要匹配你项目创建时的模块名和文件名
    engine.loadFromModule("Practice", "Main");


    // 3. 安全地获取根窗口对象
    QQuickWindow *window = nullptr;
    if (!engine.rootObjects().isEmpty()) {
        window = qobject_cast<QQuickWindow *>(engine.rootObjects().first());
    }

    // 4. 创建托盘
    QSystemTrayIcon *tray = new QSystemTrayIcon(&app);
    tray->setIcon(QIcon(":/tray/icons/tray/icon.png"));
    tray->setToolTip("Practice");

    // 5. 创建菜单
    QMenu *menu = new QMenu();

    QAction *toggleAction = new QAction("显示/隐藏", menu);
    QObject::connect(toggleAction, &QAction::triggered, [window]() {
        if (!window) return;
        if (window->isVisible()) {
            window->hide();
        } else {
            window->show();
            window->raise();
            window->requestActivate();
        }
    });

    QAction *contactAction = new QAction("联系作者", menu);
    QObject::connect(contactAction, &QAction::triggered, []() {
        QDesktopServices::openUrl(QUrl("https://space.bilibili.com/636291411"));
    });

    QAction *quitAction = new QAction("退出", menu);
    QObject::connect(quitAction, &QAction::triggered, &app, &QApplication::quit);

    menu->addAction(toggleAction);
    menu->addAction(contactAction);
    menu->addSeparator();
    menu->addAction(quitAction);

    tray->setContextMenu(menu);
    tray->show();

    return app.exec();
}
