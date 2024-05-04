import QtQuick
import QtQuick.LocalStorage

Item {
    property var db: LocalStorage.openDatabaseSync("MicroToDoDB", "0.1", "A Thirdpart Microsoft ToDo Client", 1024 * 1024 * 1024 * 1024)
    Component.onCompleted: {
        exec("Create Table If not exists option(key TEXT PRIMARY KEY, value TEXT)")
    }

    function exec(sql) {
        db.transaction(function (tx) {
            tx.executeSql(sql)
        })
    }

    function get(key, type) {
        var value = null
        try {
            db.readTransaction(function (tx) {
                var rs = tx.executeSql("SELECT value FROM option WHERE key = ?", [key])
                if (rs.rows.length > 0) {
                    value = rs.rows.item(0).value
                }
            })
        } catch (e) {
            return null;
        }

        switch(type) {
        case 'n':
        case "N":
        case "Num":
        case "num":
        case "Number":
        case "number":
            if (value !== null) {
                value = parseFloat(value)
            }
            break;
        case "B":
        case "b":
        case "bool":
        case "Bool":
        case "Boolean":
        case "boolean":
            if (value !== null) {
                value = value === "true" ? true : false
            }
            break;
        case "S":
        case "s":
        case "String":
        case "string":
            break;
        case "O":
        case "o":
        case "Object":
        case "Obj":
        case "obj":
        case "object":
            if (value !== null) {
                value = JSON.parse(value)
            }
            break;
        default:
            break;
        }

        return value
    }

    function set(key, value) {
        db.transaction(function (tx) {
            tx.executeSql("INSERT OR REPLACE INTO option(key, value) VALUES(?, ?)", [key, value])
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
}
