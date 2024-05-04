function Request() {
    this.id = 1
    this.request = request
}

function request(
    method,
    url,
    params = null,
    headers = null,
    onsuccess = null,
    onerror = null,
    ontimeout = null
) {
    let xhr = new XMLHttpRequest()
    let body = ''

    // Set params
    switch (method) {
        case 'GET':
            let urlParams = new URLSearchParams(params)
            url += '?' + urlParams.toString()
            break
        case 'POST':
        case 'PATCH':
            if (headers['Content-Type'] === 'application/json') {
                body = JSON.stringify(params)
            } else {
                let urlParams = new URLSearchParams(params)
                body = urlParams.toString()
            }
            break
    }
    xhr.open(method, url, true)

    // Set headers
    for (let key in headers) {
        xhr.setRequestHeader(key, headers[key])
    }

    xhr.send(body)

    xhr.onreadystatechange = function () {
        if (xhr.readyState === 4) {
            if (onsuccess !== null) onsuccess(xhr.responseText)
        }
    }

    xhr.onerror = function () {
        if (onerror !== null) onerror(xhr)
    }

    xhr.ontimeout = function () {
        if (ontimeout !== null) ontimeout(xhr)
    }
}
