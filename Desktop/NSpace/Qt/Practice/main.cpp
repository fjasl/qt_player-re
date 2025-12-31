#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QApplication>
#include <QSystemTrayIcon>

int main(int argc, char *argv[])
{
    //QGuiApplication app(argc, argv);
    QApplication app(argc, argv);
    QApplication::setQuitOnLastWindowClosed(false);
    QQmlApplicationEngine engine;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("Practice", "Main");

    QSystemTrayIcon tray;
    tray.setIcon(QIcon(":/icon/icons/icon.png"));
    tray.setToolTip("Practice");
    tray.show();



    return app.exec();
}
