var exec = require('cordova/exec');
var serviceWorker = require('org.apache.cordova.serviceworker.ServiceWorker');

PushManager = function() {};

PushManager.prototype.subscribe = function() {
    return new Promise(function(resolve, reject) {
	var success = function(token) {
	    exec(null, null, "Push", "storeDeviceToken", [token]);
	    resolve(new PushSubscription(token));
	};
	var failure = function(err) {
	    reject(err);
	};
	window.plugins.pushNotification.register(success, failure, 
	{
	    "badge":"true",
	    "sound":"true",
	    "alert":"true",
	    "ecb":null
	});
    });
};

PushManager.prototype.getSubscription = function() {
    return new Promise(function(resolve, reject) {
	var success = function(token) {
	    resolve(new PushSubscription(token));
	};
	var failure = function(err) {
	    reject(err);
	};
	exec(success, failure, "Push", "getDeviceToken", []);
    });
};

PushManager.prototype.hasPermission = function() {
    return new Promise(function(resolve, reject) {
	var success = function(status) {
	    if (status === "granted") {
		resolve(0);
	    }
	    if (status === "denied") {
		resolve(1);
	    }
	};
	var failure = function(err) {
	    reject(err);
	};
	exec(success, failure, "Push", "hasPermission", []);
    });
};

navigator.serviceWorker.ready.then(function(serviceWorkerRegistration) {
    serviceWorkerRegistration.pushManager = new PushManager();
    exec(null, null, "Push", "setupPush", []);
});

module.exports = PushManager;
