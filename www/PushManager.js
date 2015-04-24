var exec = require('cordova/exec');
var serviceWorker = require('org.apache.cordova.serviceworker.ServiceWorker');

function PushManager() {}

PushManager.prototype.subscribe = function(options) {
    return new Promise(function(resolve, reject) {
	options = options || {};
	function callback(token) {
	    exec(null, null, 'Push', 'storeSubscription', [token, options.userVisibleOnly]);
	    resolve(new PushSubscription(token));
	}
	window.plugins.pushNotification.register(callback, reject, 
	{
	    'badge':'true',
	    'sound':'true',
	    'alert':'true',
	    'ecb':''
	});
    });
};

PushManager.prototype.getSubscription = function() {
    return new Promise(function(resolve, reject) {
	function callback(token) {
	    resolve(new PushSubscription(token));
	}
	exec(callback, reject, 'Push', 'getSubscription', []);
    });
};

PushManager.prototype.permissionState = function(options) {
    return new Promise(function(resolve, reject) {
	options = options || {};
	exec(resolve, reject, 'Push', 'permissionState', [options.userVisibleOnly]);
    });
};

navigator.serviceWorker.ready.then(function(serviceWorkerRegistration) {
    serviceWorkerRegistration.pushManager = new PushManager();
    exec(null, null, 'Push', 'setupPush', []);
});

module.exports = PushManager;
