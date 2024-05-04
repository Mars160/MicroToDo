#include <QGuiApplication>
#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQuickWindow>
#include <QMessageBox>

#include "authserver.h"

bool isSingleInstanceRunning(QString m_appName);
QLocalServer* startSingleInstanceServer(QString appName);

int main(int argc, char *argv[])
{
    if(isSingleInstanceRunning("MicroToDo")) {
        QApplication app(argc, argv);
        QMessageBox::critical(
            nullptr,
            "Error!",
            "Thers is another Instance is running!",
            QMessageBox::Yes
            );
        return 1;
    } else {
        QGuiApplication app(argc, argv);
        auto s = startSingleInstanceServer("MicroToDo");
        qmlRegisterType<AuthServer>("authserver", 1, 0, "AuthServer");

        QQmlApplicationEngine engine;
        QObject::connect(
            &engine,
            &QQmlApplicationEngine::objectCreationFailed,
            &app,
            []() { QCoreApplication::exit(-1); },
            Qt::QueuedConnection);
        engine.loadFromModule("MicroTODO", "Main");

        return app.exec();
    }
}

bool isSingleInstanceRunning(QString m_appName) {
    QLocalSocket socket;
    socket.connectToServer(m_appName);
    bool isOpen = socket.isOpen();
    socket.close();
    return isOpen;
}

QLocalServer* startSingleInstanceServer(QString appName) {
    QLocalServer* server = new QLocalServer;
    server->setSocketOptions(QLocalServer::WorldAccessOption);
    server->listen(appName);
    return server;
}
