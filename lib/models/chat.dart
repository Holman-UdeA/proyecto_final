class Chat {
  var _idChat;
  var _users;
  var _lastMessage;
  var _lastSenderId;
  var _lastTimestamp;
  var _createdAt;

  Chat(
    this._idChat,
    this._users,
    this._lastMessage,
    this._lastSenderId,
    this._lastTimestamp,
    this._createdAt,
  );

  get idChat => _idChat;

  get createdAt => _createdAt;

  set createdAt(value) {
    _createdAt = value;
  }

  get lastTimestamp => _lastTimestamp;

  set lastTimestamp(value) {
    _lastTimestamp = value;
  }

  get lastSenderId => _lastSenderId;

  set lastSenderId(value) {
    _lastSenderId = value;
  }

  get lastMessage => _lastMessage;

  set lastMessage(value) {
    _lastMessage = value;
  }

  get users => _users;

  set users(value) {
    _users = value;
  }

  set idChat(value) {
    _idChat = value;
  }

  Map<String, dynamic> toJson() => {
    "idChat": _idChat,
    "users": _users,
    "lastMessage": _lastMessage,
    "lastSenderId": _lastSenderId,
    "lastTimestamp": _lastTimestamp,
    "createdAt": _createdAt,
  };

  Chat.fromJson(Map<String, dynamic> json)
    : _idChat = json["idChat"],
      _users = json["users"],
      _lastMessage = json["lastMessage"],
      _lastSenderId = json["lastSenderId"],
      _lastTimestamp = json["lastTimestamp"],
      _createdAt = json["createdAt"];
}
