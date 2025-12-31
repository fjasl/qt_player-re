#include <QApplication>
#include <QQmlApplicationEngine>
#include <QSystemTrayIcon>
#include <QMenu>
#include <QAction>
#include <QQuickWindow>
#include <QDesktopServices>
#include <QUrl>

int main(int argc, char *argv[])
{
    // 1. 必须用 QApplication 以支持原生菜单
    QApplication app(argc, argv);
    app.setQuitOnLastWindowClosed(false);

    QQmlApplicationEngine engine;

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
    tray->setIcon(QIcon(":/icon/icons/icon.png"));
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
