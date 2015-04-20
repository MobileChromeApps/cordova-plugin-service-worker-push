function PushMessageData(data) {
    this.bytes = unescape(encodeURIComponent(data));
}

PushMessageData.prototype.arrayBuffer = function() {
    var buffer = new ArrayBuffer(this.bytes.length);
    var bufferView = new Uint8Array(buffer);
    for (var i = 0; i < this.bytes.length; i++) {
	bufferView[i] = this.bytes.charCodeAt(i);
    }
    return buffer;
};

PushMessageData.prototype.blob = function() {
    return new Blob([this.bytes]);
};

PushMessageData.prototype.json = function() {
    try{
	return JSON.parse(decodeURIComponent(escape(this.bytes)));
    } catch(e) {
	console.log('Exception in data.json');
	throw e;
    }
};

PushMessageData.prototype.text = function() {
    return decodeURIComponent(escape(this.bytes));
};
