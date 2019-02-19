var exec = require('cordova/exec');

var QrReader = function () { };

/**
 *
 */
QrReader.prototype.scan = function (successCallback, errorCallback) {
    exec(successCallback, errorCallback, "PGMyPlugin", "openQRReader", []);
}
module.exports = new QrReader();
