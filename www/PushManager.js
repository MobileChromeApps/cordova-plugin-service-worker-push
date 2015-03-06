var exec = require('cordova/exec');
var serviceWorker = require('org.apache.cordova.serviceworker.ServiceWorker');

PushManager = function() {
    return this;
};

PushManager.prototype.subscribe = function() {
    return new Promise(function(resolve, reject) {
	var success = function() {

	};
	var failure = function(err) {
	    reject(err);
	};
    });
};

PushManager.prototype.getSubscription = function() {
    return new Promise(function(resolve, reject) {
	var success = function() {
	
	};
	var failure = function(err) {
	    reject(err);
	};
    });
};

PushManager.prototype.hasPermission = function() {
    return new Promise(function(resolve, reject) {
	var success = function() {

	};
	var failure = function(err) {
	    reject(err);
	};
    });
};

navigator.serviceWorker.ready.then(function(serviceWorkerRegistration) {
    serviceWorkerRegistration.pushManager = new PushManager();
});

module.exports = PushManager;
