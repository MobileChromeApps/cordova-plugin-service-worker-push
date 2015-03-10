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
	exec(success, failure, "Push", "subscribe", []);
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
	    console.log("success");
	    resolve(true);
	};
	var failure = function(err) {
	    console.log("failure");
	    reject(err);
	};
	exec(success, failure, "Push", "hasPermission", []);
    });
};

navigator.serviceWorker.ready.then(function(serviceWorkerRegistration) {
    serviceWorkerRegistration.pushManager = new PushManager();
    //exec(null, null, "Push", "setupPush", []);
});

module.exports = PushManager;
