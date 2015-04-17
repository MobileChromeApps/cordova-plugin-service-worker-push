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

function PushEvent () {
    ExtendableEvent.call(this, 'push');
}

function PushSubscriptionChangeEvent () {
    ExtendableEvent.call(this, 'pushsubscriptionchange');
}

PushEvent.prototype = Object.create(ExtendableEvent.prototype);
PushEvent.constructor = PushEvent;

PushSubscriptionChangeEvent.prototype = Object.create(ExtendableEvent.prototype);
PushSubscriptionChangeEvent.constructor = PushSubscriptionChangeEvent;

function FirePushEvent(data, APNSData) {
    var ev = new PushEvent();
    ev.data = new PushMessageData(data);
    ev.APNSData = APNSData;
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
}

function FirePushSubscriptionChangeEvent(data) {
    dispatchEvent(new PushSubscriptionChangeEvent());
}
