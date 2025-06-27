class User {
  var _uid;
  var _name;
  var _email;
  var _genre;
  var _rol;
  var _bornDate;
  var _urlPicture;

  User(
    this._uid,
    this._name,
    this._email,
    this._genre,
    this._rol,
    this._bornDate,
    this._urlPicture,
  );

  get uid => _uid;

  set uid(value) {
    _uid = value;
  }

  get name => _name;

  get urlPicture => _urlPicture;

  set urlPicture(value) {
    _urlPicture = value;
  }

  get bornDate => _bornDate;

  set bornDate(value) {
    _bornDate = value;
  }

  get rol => _rol;

  set rol(value) {
    _rol = value;
  }

  get genre => _genre;

  set genre(value) {
    _genre = value;
  }

  get email => _email;

  set email(value) {
    _email = value;
  }

  set name(value) {
    _name = value;
  }

  Map<String, dynamic> toJson() => {
    "uid": _uid,
    "name": _name,
    "email": _email,
    "genre": _genre,
    "rol": _rol,
    "bornDate": _bornDate,
    "ulrPicture": _urlPicture,
  };

  User.fromJson(Map<String, dynamic> json)
      : _uid = json['uid'],
        _name = json['name'],
        _email = json['email'],
        _genre = json["genre"],
        _rol = json['rol'],
        _bornDate = json['bornDate'],
        _urlPicture = json['ulrPicture'];
}
