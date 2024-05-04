#include "authserver.h"

AuthServer::AuthServer(QObject *parent)
    : QObject{parent}
{
    server = nullptr;
}

AuthServer::~AuthServer() {
    if(server == nullptr) {
        delete server;
        server = nullptr;
    }
    deleteLater();
}

int AuthServer::serve() {
    server = new QHttpServer(this);
    server->route("/", []() {
        return "Hello World";
    });

    server->route("/auth", QHttpServerRequest::Method::Get, [=](const QHttpServerRequest &req) {
        QUrlQuery uQry = req.query();
        code = uQry.queryItemValue("code");
        emit getCode(code);
        return "success!";
    });

    const auto port = this->server->listen(QHostAddress::Any, 65412);
    emit Serving(port);
    QString URL = "https://login.microsoftonline.com/common/oauth2/v2.0/authorize? \
                  client_id=c6bd3fe0-989e-48b7-8425-d5ae917f650a \
                  &response_type=code \
                  &redirect_uri=http%3A%2F%2Flocalhost%3A65412%2Fauth \
                  &response_mode=query \
                  &scope=offline_access%20User.Read%20Tasks.ReadWrite";
    QDesktopServices::openUrl(URL);
    return port;
}

void AuthServer::stop() {
    if(server == nullptr) {
        delete server;
        server = nullptr;
    }
    deleteLater();
}
