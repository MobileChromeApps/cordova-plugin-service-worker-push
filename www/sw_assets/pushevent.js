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

PushEvent = function() {
    return this;
};

PushSubscriptionChangeEvent = function() {
    return this;
};

PushEvent.prototype = new ExtendableEvent('push');
PushSubscriptionChangeEvent = new ExtendableEvent('pushsubscriptionchange');

FirePushEvent = function(data) {
    var ev = new PushEvent();
    dispatchEvent(ev);
    if (ev.promises instanceof Array) {
	//call completion handler with success
    } else {
	// call completion handler with failure
    }
};

FirePushSubscriptionChangeEvent(data) {

};
