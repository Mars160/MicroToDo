import QtQuick
import authserver
import "./http.js" as Http

Item {
    property var hR: new Http.Request()
    property string accessToken: ""
    property real expireAt: 0

    property string baseUrl : "https://graph.microsoft.com/v1.0/me/todo"

    property string clientID: "c6bd3fe0-989e-48b7-8425-d5ae917f650a"
    property string scope: "User.Read Tasks.ReadWrite"

    AuthServer {
        id: authserver

        onGetCode: c => {
            code = c
            console.log(code)
            hR.request(
                "POST",
                "https://login.microsoftonline.com/common/oauth2/v2.0/token",
                {
                    "client_id": clientID,
                    "scope": scope,
                    "code": code,
                    "redirect_uri": "http://localhost:65412/auth",
                    "grant_type": "authorization_code",
                },
                {
                    "Content-Type": "application/x-www-form-urlencoded",
                },
                (response) => {
                    let json = JSON.parse(response)
                    let now = (new Date).getTime()
                    expireAt = now + (json.expires_in - 60) * 1000;
                    accessToken = json.access_token

                    storage.set("refreshToken", json.refresh_token)
                    console.log(json.refresh_token)
                },
                (error) => {
                    let j = JSON.stringify(error)
                    console.log(j)
                }
            )

            delay(30000, authserver.stop)
        }
    }

    Timer {
        id: timer
    }

    function delay(delayTime, callback) {
        timer.interval = delayTime;
        timer.repeat = false;
        timer.triggered.connect(callback)
        timer.start()
    }

    function auth() {
        if (port === 0) {
            port = authserver.serve()
        } else if (code !== "") {
            console.log(code)
        }
    }

    property int port: 0
    property string code: ""

    function refreshToken(onsuccess = null) {
        hR.request(
            "POST",
            "https://login.microsoftonline.com/common/oauth2/v2.0/token",
            {
                "client_id": clientID,
                "refresh_token": storage.get("refreshToken"),
                "grant_type": "refresh_token",
            },
            {
                "Content-Type": "application/x-www-form-urlencoded",
            },
            (response) => {
                let json = JSON.parse(response)
                let now = (new Date).getTime()
                expireAt = now + (json.expires_in - 60) * 1000;
                accessToken = json.access_token

                storage.set("refreshToken", json.refresh_token)

                if(onsuccess !== null) {
                    onsuccess()
                }
            },
            (error) => {
                let j = JSON.stringify(error)
                console.log(j)
            }
        )
    }

    function request(method, url, params = null, headers = null, onsuccess = null, onerror = null, ontimeout = null){
        let now = (new Date).getTime()
        if(now > expireAt) {
            refreshToken(() => {
                request(method, url, params, headers, onsuccess, onerror, ontimeout)
            })
        } else {
            if(headers === null || headers === undefined) {
                headers = {
                    "Authorization": "Bearer " + accessToken
                }
            } else if(!headers.hasOwnProperty("Authorization")) {
                headers["Authorization"] = "Bearer " + accessToken
            }
            hR.request(method, url, params, headers, onsuccess, onerror, ontimeout)
        }
    }

    function getLists(onsuccess = null, onerror = null) {
        request(
            "GET",
            baseUrl + "/lists",
            null,
            null,
            onsuccess,
            onerror,
        )
    }

    function getTasks(Id, onsuccess = null, onerror = null) {
        request(
            "GET",
            baseUrl + "/lists/" + Id + "/tasks",
            null,
            null,
            onsuccess,
            onerror,
        )
    }

    function updateTask(listId, taskID, param, onsuccess = null, onerror = null) {
        request(
            "PATCH",
            baseUrl + "/lists/" + listId + "/tasks/" + taskID,
            param,
            {
                "Content-Type": "application/json"
            },
            onsuccess,
            onerror,
        )
    }
}
