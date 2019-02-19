var exec = require('cordova/exec');

var QrReader = function () {};

/**
 *
 */
QrReader.prototype.scan = function (successCallback, errorCallback) {
    exec(successCallback, errorCallback, "PGMyPlugin", "openQRReader", []);
}

var qrReader = new QrReader();

QrReader.install = function () {
    if (!window.plugins) {
      window.plugins = {};
    }
    window.plugins.qrReader = qrReader;
};

if (cordova) {
    cordova.addConstructor(QrReader.install);
}
module.exports = qrReader;
