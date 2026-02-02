import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/place.dart';

class PlacesService {
  final String url =
      "https://raw.githubusercontent.com/tonusername/tonrepo/main/places.json"; // mettre ton lien

  Future<List<Place>> fetchPlaces() async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((p) => Place.fromJson(p)).toList();
    } else {
      throw Exception("Impossible de charger les lieux");
    }
  }
}
