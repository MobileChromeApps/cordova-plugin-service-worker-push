# Push for Cordova Service Worker
Enable your app to receive and handle push messages with a service worker. This plugin is built on top of the existing popular [push plugin](https://github.com/phonegap-build/PushPlugin.git) and matches the API laid out in [this spec](https://w3c.github.io/push-api/). 
If your server has new content, it can send a silent push to wake up your app (even when it is in the background) and update its conent accordingly using the persistent service worker. The next time a user opens your app, the content is ready to go.

## Supported Platforms
- iOS

## Installation
To add this plugin to your project using cordova cli
```
cordova plugin add https://github.com/MobileChromeApps/cordova-plugin-service-worker-push.git
```

or, to install from npm:
```
cordova plugin add cordova-plugin-service-worker-push
```

To uninstall this plugin
```
cordova plugin rm cordova-plugin-service-worker-push
```

## Setting up Push Notifications
After your service worker is ready, you can use the service worker's ```pushManager``` to ```subscribe``` for push notifications. ```subscribe``` will prompt the user, asking for permission to send push notifications. When the user agrees, ```subscribe``` will return a promise that resolves with a ```PushSubscription``` that contains a unique token which you will provide to your server for sending notifications to that device.
```javascript
navigator.serviceWorker.ready.then(function (swReg) {
    swReg.pushManager.subscribe().then(function (pushSubscription) {
        myTokenToServerPostingFunction(pushSubscription.endpoint);
        /* or */
        myTokenToServerPostingFunction(pushSubscription.deviceToken);
    });
});
```
Note: To accommodate iOS's push API, the endpoint provided in the ```PushSubscription``` is simply the APNS device token. For convenience and code clarity, this implementation includes a non-spec property ```deviceToken``` for ```PushSubscription``` which has the same value as endpoint.

## Handling Push Events
When a device receives a push message a ```push``` event is dispatched in the service worker context. You can set an handler for this event by setting the service worker's ```onpush```.
```javascript
// In your service worker script
this.onpush = function (event) {
    event.waitUntil(new Promise(function (resolve, reject) {
        // Do some async update process here
        myAsyncFunction(event.data.text());
        ...
    }));
};
```
The ```event``` object received by the ```onpush``` handler has a ```data``` property and a non-spec ```APNSData``` property. ```data``` contains the bytes provided in the data property of a received push message's payload. These bytes can be accessed as an ArrayBuffer, Blob, JSON, or text using the ```data.arrayBuffer()```, ```data.blob()```, ```data.json()```, and ```data.text()``` functions respectively.

For convenience, ```event.APNSData``` is a JSON object containing the entire APNS payload that was received. ```APNSData``` does not require any specific formatting or property names on the server side, however it is not part of the spec.

## Sending a Silent Push to Service Worker
Using the following payload template, you can send messages to your service worker app while it is in the background without creating an alert that notifies the user.
```
{
    "aps" : {
	"content-available" : 1,
	"priority" : 5
    },
    "data" : "{\"data0\":\"myData0\", \"data1\":\"myData1\"}"
}
```
Replace the contents of ```data``` with your own data. This data will be provided within the event object given to the push event handler in your service worker script.

## 1.0.0 (April 29, 2015)
* Initial release
