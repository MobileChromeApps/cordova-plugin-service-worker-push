var exec = require('cordova/exec');
var serviceWorker = require('org.apache.cordova.serviceworker.ServiceWorker');

function PushManager() {}

PushManager.prototype.subscribe = function(options) {
    return new Promise(function(resolve, reject) {
	options = options || {};
	function callback(token) {
	    exec(null, null, "Push", "storeDeviceToken", [token, options.userVisible]);
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

PushManager.prototype.hasPermission = function(options) {
    return new Promise(function(resolve, reject) {
	options = options || {};
	exec(resolve, reject, "Push", "hasPermission", [options.userVisible]);
    });
};

navigator.serviceWorker.ready.then(function(serviceWorkerRegistration) {
    serviceWorkerRegistration.pushManager = new PushManager();
    exec(null, null, "Push", "setupPush", []);
});

module.exports = PushManager;
