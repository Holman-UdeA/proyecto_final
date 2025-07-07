class Message {
  var _idMessage;
  var _text;
  var _senderId;
  var _timestamp;

  Message(this._idMessage, this._text, this._senderId, this._timestamp);

  get idMessage => _idMessage;

  get timestamp => _timestamp;

  set timestamp(value) {
    _timestamp = value;
  }

  get senderId => _senderId;

  set senderId(value) {
    _senderId = value;
  }

  get text => _text;

  set text(value) {
    _text = value;
  }

  set idMessage(value) {
    _idMessage = value;
  }

  Map<String, dynamic> toJson() => {
    "idMessage": _idMessage,
    "text": _text,
    "senderId": _senderId,
    "timestamp": _timestamp,
  };

  Message.fromJson(Map<String, dynamic> json)
      : _idMessage = json["idMessage"],
        _text = json["text"],
        _senderId = json["senderId"],
        _timestamp = json["timestamp"];
}