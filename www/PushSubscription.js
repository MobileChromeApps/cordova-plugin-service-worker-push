var exec = require('cordova/exec');
var serviceWorker = require('org.apache.cordova.serviceworker.ServiceWorker');
var pushManager = require('./PushManager');

PushSubscription = function(deviceToken) {
    this.deviceToken = deviceToken;
    this.endpoint = deviceToken;
    this.subscriptionId = deviceToken;
};

PushSubscription.prototype.unsubscribe = function() {
    return new Promise(function(resolve, reject) {
	var success = function() {
	    var innerSuccess = function() {
		resolve(true);
	    };
	    window.plugins.pushNotification.unregister(innerSuccess, failure);
	};
	var failure = function(err) {
	    reject(err);
	};
    });
};

module.exports = PushSubscription;
