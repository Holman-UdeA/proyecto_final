class ServiceOfProfesional {
  var _idService;
  var _uidProfesional;
  var _nameService;
  var _description;
  var _price;
  var _duration;

  ServiceOfProfesional(
    this._idService,
    this._uidProfesional,
    this._nameService,
    this._description,
    this._price,
    this._duration,
  );

  get idService => _idService;

  get duration => _duration;

  set duration(value) {
    _duration = value;
  }

  get price => _price;

  set price(value) {
    _price = value;
  }

  get description => _description;

  set description(value) {
    _description = value;
  }

  get nameService => _nameService;

  set nameService(value) {
    _nameService = value;
  }

  get uidProfesional => _uidProfesional;

  set uidProfesional(value) {
    _uidProfesional = value;
  }

  set idService(value) {
    _idService = value;
  }

  Map<String, dynamic> toJson() => {
    "idService": _idService,
    "uidProfesional": _uidProfesional,
    "nameService": _nameService,
    "description": _description,
    "price": _price,
    "duration": _duration,
  };

  ServiceOfProfesional.fromJson(Map<String, dynamic> json)
    : _idService = json["idService"],
      _uidProfesional = json["uidProfesional"],
      _nameService = json["nameService"],
      _description = json["description"],
      _price = json["price"],
      _duration = json["duration"];
}
