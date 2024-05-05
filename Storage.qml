import QtQuick
import QtQuick.LocalStorage

Item {
    property var db: LocalStorage.openDatabaseSync(
                         "MicroToDoDB", "0.1",
                         "A Thirdpart Microsoft ToDo Client",
                         1024 * 1024 * 1024 * 1024)
    property var cache

    Component.onCompleted: {
        exec(`Create Table If not exists option(
            key TEXT PRIMARY KEY, 
            value TEXT)`)
        exec(`Create Table If not exists TaskList(
            Id VarChar(255) PRIMARY KEY,
            name TEXT)`)
        exec(`Create Table If not exists HideList(
            Id VarChar(255) PRIMARY KEY)`)
        exec(`Create Table If not exists Task(
            Id VarChar(255) PRIMARY KEY,
            name TEXT,
            listId VarChar(255))`)
        cache = {}
    }

    function exec(sql) {
        db.transaction(function (tx) {
            tx.executeSql(sql)
        })
    }

    function get(key, type) {
        let value = null
        try {
            db.readTransaction(function (tx) {
                let rs = tx.executeSql(
                            "SELECT value FROM option WHERE key = ?", [key])
                if (rs.rows.length > 0) {
                    value = rs.rows.item(0).value
                }
            })
        } catch (e) {
            return null
        }

        switch (type) {
        case 'n':
        case "N":
        case "Num":
        case "num":
        case "Number":
        case "number":
            if (value !== null) {
                value = parseFloat(value)
            }
            break
        case "B":
        case "b":
        case "bool":
        case "Bool":
        case "Boolean":
        case "boolean":
            if (value !== null) {
                value = value === "true" ? true : false
            }
            break
        case "S":
        case "s":
        case "String":
        case "string":
            break
        case "O":
        case "o":
        case "Object":
        case "Obj":
        case "obj":
        case "object":
            if (value !== null) {
                value = JSON.parse(value)
            }
            break
        default:
            break
        }

        return value
    }

    function set(key, value) {
        db.transaction(function (tx) {
            tx.executeSql(
                        "INSERT OR REPLACE INTO option(key, value) VALUES(?, ?)",
                        [key, value])
        })
    }

    function remove(key) {
        db.transaction(function (tx) {
            tx.executeSql("DELETE FROM option WHERE key = ?", [key])
        })
    }

    function clear() {
        db.transaction(function (tx) {
            tx.executeSql("DELETE FROM option")
        })
    }

    function setCache(key, value, expire = 0) {
        cache[key] = {
            "value": value,
            "expire": expire === 0 ? 0 : new Date().getTime() + expire
        }
    }

    function getCache(key) {
        if (cache[key] === undefined) {
            return null
        }

        if (cache[key].expire !== 0 && cache[key].expire < new Date().getTime()) {
            delete cache[key]
            return null
        }

        return cache[key].value
    }

    function taskList() {
        return {
            "get": (Id = null) => {
                if (Id === null) {
                    let value = []
                    try {
                        db.readTransaction(function (tx) {
                            let rs = tx.executeSql(
                                        "SELECT * FROM TaskList")
                            for (let i = 0; i < rs.rows.length; i++) {
                                value.push(rs.rows.item(i))
                            }
                        })
                    } catch (e) {
                        return []
                    }
                    return value
                } else {
                    let value = null
                    try {
                        db.readTransaction(function (tx) {
                            let rs = tx.executeSql(
                                        "SELECT * FROM TaskList WHERE Id = ?",
                                        [Id])
                            if (rs.rows.length > 0) {
                                value = rs.rows.item(0)
                            }
                        })
                    } catch (e) {
                        return null
                    }
                    return value
                }
            },
            "add": (Id, name) => {
                db.transaction(function (tx) {
                    tx.executeSql(
                                "INSERT OR REPLACE INTO TaskList(Id, name) VALUES(?, ?)",
                                [Id, name])
                })
            },
            "set": (lists) => {
                db.transaction(function (tx) {
                    tx.executeSql("DELETE FROM TaskList")
                    for (let i = 0; i < lists.length; i++) {
                        tx.executeSql(
                                    "INSERT OR REPLACE INTO TaskList(Id, name) VALUES(?, ?)",
                                    [lists[i].Id, lists[i].name])
                    }
                })
            },
            "remove": Id => {
                db.transaction(function (tx) {
                    tx.executeSql("DELETE FROM TaskList WHERE Id = ?", [Id])
                })
            },
            "clear": () => {
                db.transaction(function (tx) {
                    tx.executeSql("DELETE FROM TaskList")
                })
            }
        }
    }

    function task() {
        return {
            "get": (Id = null, isListId = true) => {
                if (Id === null) {
                    let value = []
                    try {
                        db.readTransaction(function (tx) {
                            let rs = tx.executeSql(
                                        "SELECT * FROM Task")
                            for (let i = 0; i < rs.rows.length; i++) {
                                value.push(rs.rows.item(i))
                            }
                        })
                    } catch (e) {
                        return []
                    }
                    return value
                } else if(isListId) {
                    let value = []
                    try {
                        db.readTransaction(function (tx) {
                            let rs = tx.executeSql(
                                        "SELECT * FROM Task WHERE listId = ?",
                                        [Id])
                            for (let i = 0; i < rs.rows.length; i++) {
                                value.push(rs.rows.item(i))
                            }
                        })
                    } catch (e) {
                        return null
                    }
                    return value
                } else {
                    let value = null
                    try {
                        db.readTransaction(function (tx) {
                            let rs = tx.executeSql(
                                        "SELECT * FROM Task WHERE Id = ?",
                                        [Id])
                            if (rs.rows.length > 0) {
                                value = rs.rows.item(0)
                            }
                        })
                    } catch (e) {
                        return null
                    }
                    return value
                }
            },
            "add": (Id, name, listId) => {
                db.transaction(function (tx) {
                    tx.executeSql(
                                "INSERT OR REPLACE INTO Task(Id, name, listId) VALUES(?, ?, ?)",
                                [Id, name, listId])
                })
            },
            "set": (tasks, listId) => {
                db.transaction(function (tx) {
                    tx.executeSql("DELETE FROM Task WHERE listID = ?", [listId])
                    for (let i = 0; i < tasks.length; i++) {
                        tx.executeSql(
                                    "INSERT OR REPLACE INTO Task(Id, name, listId) VALUES(?, ?, ?)",
                                    [tasks[i].Id, tasks[i].name, listId])
                    }
                })
            },
            "remove": Id => {
                db.transaction(function (tx) {
                    tx.executeSql("DELETE FROM Task WHERE Id = ?", [Id])
                })
            },
            "clear": () => {
                db.transaction(function (tx) {
                    tx.executeSql("DELETE FROM Task")
                })
            }
        }   
    }

    function hideList() {
        return {
            "get": () => {
                let value = []
                try {
                    db.readTransaction(function (tx) {
                        let rs = tx.executeSql(
                                    "SELECT * FROM HideList")
                        for (let i = 0; i < rs.rows.length; i++) {
                            value.push(rs.rows.item(i).Id)
                        }
                    })
                } catch (e) {
                    return []
                }
                return value
            },
            "add": Id => {
                db.transaction(function (tx) {
                    tx.executeSql(
                                "INSERT OR REPLACE INTO HideList(Id) VALUES(?)",
                                [Id])
                })
            },
            "set": (lists) => {
                db.transaction(function (tx) {
                    tx.executeSql("DELETE FROM HideList")
                    for (let i = 0; i < lists.length; i++) {
                        tx.executeSql(
                                    "INSERT OR REPLACE INTO HideList(Id) VALUES(?)",
                                    [lists[i].Id])
                    }
                })
            },
            "remove": Id => {
                db.transaction(function (tx) {
                    tx.executeSql("DELETE FROM HideList WHERE Id = ?", [Id])
                })
            },
            "clear": () => {
                db.transaction(function (tx) {
                    tx.executeSql("DELETE FROM HideList")
                })
            }
        }
    }
}
