#ifndef AUTHSERVER_H
#define AUTHSERVER_H

#include <QObject>
#include <QHttpServer>
#include <QtQml>
#include <QDesktopServices>

class AuthServer : public QObject
{
    Q_OBJECT
    QML_ELEMENT
public:
    explicit AuthServer(QObject *parent = nullptr);
    ~AuthServer();
    Q_INVOKABLE int serve();
    Q_INVOKABLE void stop();
    QString code;

private:
    QHttpServer* server;

signals:
    void Serving(int port);
    void getCode(QString code);
};

#endif // AUTHSERVER_H
