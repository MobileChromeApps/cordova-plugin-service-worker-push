Object.defineProperty(this, 'onpush', {
    configurable: false,
    enumerable: true,
    get: eventGetter('push'),
    set: eventSetter('push')
});

Object.defineProperty(this, 'onpushsubscriptionchange', {
    configurable: false,
    enumerable: true,
    get: eventGetter('pushsubscriptionchange'),
    set: eventSetter('pushsubscriptionchange')
});

PushEvent = function() {};

PushSubscriptionChangeEvent = function() {};

PushEvent.prototype = new ExtendableEvent('push');
PushSubscriptionChangeEvent = new ExtendableEvent('pushsubscriptionchange');

FirePushEvent = function(data) {
    var ev = new PushEvent();
    dispatchEvent(ev);
    if (ev.promises instanceof Array) {
	return Promise.all(ev.promises).then(function() {
	    sendSyncResponse(0);
	}, function() {
	    sendSyncResponse(1);
	});
    } else {
	sendSyncResponse(2);
    }
};

FirePushSubscriptionChangeEvent = function(data) {

};
