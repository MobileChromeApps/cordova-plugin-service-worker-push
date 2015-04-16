var exec = require('cordova/exec');
var serviceWorker = require('org.apache.cordova.serviceworker.ServiceWorker');

function PushManager() {}

PushManager.prototype.subscribe = function() {
    return new Promise(function(resolve, reject) {
	function callback(token) {
	    exec(null, null, "Push", "storeDeviceToken", [token]);
	    resolve(new PushSubscription(token));
	}
	window.plugins.pushNotification.register(callback, reject, 
	{
	    "badge":"true",
	    "sound":"true",
	    "alert":"true",
	    "ecb":""
	});
    });
};

PushManager.prototype.getSubscription = function() {
    return new Promise(function(resolve, reject) {
	function callback(token) {
	    resolve(new PushSubscription(token));
	}
	exec(callback, reject, "Push", "getDeviceToken", []);
    });
};

PushManager.prototype.hasPermission = function() {
    return new Promise(function(resolve, reject) {
	exec(resolve, reject, "Push", "hasPermission", []);
    });
};

navigator.serviceWorker.ready.then(function(serviceWorkerRegistration) {
    serviceWorkerRegistration.pushManager = new PushManager();
    exec(null, null, "Push", "setupPush", []);
});

module.exports = PushManager;
