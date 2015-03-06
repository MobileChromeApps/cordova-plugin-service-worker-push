var exec = require('cordova/exec');
var serviceWorker = require('org.apache.cordova.serviceworker.ServiceWorker');
var pushManager = require('./PushManager');

PushSubscription = function() {
    return this;
};

PushSubscription.prototype.unsubscribe = function() {
    return new Promise(function(resolve, reject) {
	var success = function() {

	};
	var failure = function(err) {
	    reject(err);
	};
    });
};

module.exports = PushSubscription;
