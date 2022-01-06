import 'dart:convert';

List<Shop> allShopFromJson(String str) {
  final jsonData = json.decode(str);
  return new List<Shop>.from(jsonData['data'].map((x) => Shop.fromJson(x)));
}

class Shop {
  int id;
  String name;
  String image;
  String description;
  String opening_time;
  String closing_time;

  Shop({
    this.id,
    this.name,
    this.image,
    this.description,
    this.opening_time,
    this.closing_time,
  });

  factory Shop.fromJson(Map<String, dynamic> json) => new Shop(
    id: json["id"],
    name: json["name"],
    image: json["image"],
    description: json["description"],
    opening_time: json["opening_time"],
    closing_time: json["closing_time"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "image": image,
    "description": description,
    "opening_time": opening_time,
    "closing_time": closing_time,
  };
}