# cordova-plugin-push
Push plugin for Cordova service worker

##Sending a Silent Push to Service Worker
Using the following payload template, you can send messages to your service worker app while it is in the background without creating an alert that notifies the user.
```
{
    "aps" : {
	"content-available" : 1,
	"priority" : 5,
	"property1" : "myDataString",
	"property2" : "moreData",
	...
    }
}
```
Replace property1 etc. with your own data. This data will be provided within the event object given to the push event handler in your service worker script.

