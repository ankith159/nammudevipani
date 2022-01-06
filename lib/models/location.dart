import 'dart:convert';

List<Location> allLocationFromJson(String str) {
  final jsonData = json.decode(str);
  return new List<Location>.from(jsonData['data'].map((x) => Location.fromJson(x)));
}

class Location {
  int id;
  String name;

  Location({
    this.id,
    this.name,
  });

  factory Location.fromJson(Map<String, dynamic> json) => new Location(
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}

List<Area> allAreaFromJson(String str) {
  final jsonData = json.decode(str);
  return new List<Area>.from(jsonData.map((x) => Area.fromJson(x)));
}

class Area {
  int id;
  String name;

  Area({
    this.id,
    this.name,
  });

  factory Area.fromJson(Map<String, dynamic> json) => new Area(
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}