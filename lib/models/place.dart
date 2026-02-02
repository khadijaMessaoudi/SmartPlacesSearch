class Place {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final String address;

  Place({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.address,
  });

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'lat': lat, 'lng': lng, 'address': address};
  }

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'],
      name: json['name'],
      lat: json['lat'],
      lng: json['lng'],
      address: json['address'],
    );
  }
}
