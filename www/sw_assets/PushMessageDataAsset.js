var PushMessageData = function(data) {
    this.bytes = data;
    return this;
};

PushMessageData.prototype.arrayBuffer = function() {
    var characters = btoa(this.bytes).split('');
    var array = [];
    for (var i = 0; i < characters.length; i++) {
	array.push(characters[i].charCodeAt(0));
    }
    return new Uint8Array(array).buffer;
};

PushMessageData.prototype.blob = function() {
    return new Blob([this.bytes]);
};

PushMessageData.prototype.json = function() {
    try{
	return JSON.parse(decodeURIComponent(escape(this.bytes)));
    } catch(e) {
	console.log("caught exception");
	throw e;
    }
};

PushMessageData.prototype.text = function() {
    return decodeURIComponent(escape(this.bytes));
};
