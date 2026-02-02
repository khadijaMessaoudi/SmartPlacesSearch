import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import '../models/place.dart';
import '../services/firebase_favorites_service.dart';

class MapScreen extends StatefulWidget {
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final FirebaseFavoritesService favoritesService = FirebaseFavoritesService();

  List<Place> places = [];
  Set<String> likedPlacesIds = {};
  TextEditingController searchController = TextEditingController();

  final LatLng mapCenter = LatLng(43.7266, 12.6365);
  final MapController mapController = MapController();

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  void loadFavorites() async {
    final favorites = await favoritesService.getFavorites();
    setState(() {
      likedPlacesIds = favorites.map((p) => p.id).toSet();
    });
  }

  Future<void> searchPlaces(String query) async {
    if (query.trim().isEmpty) return;

    final double lat = mapCenter.latitude;
    final double lng = mapCenter.longitude;
    final double delta = 0.1;

    final viewbox =
        '${lng - delta},${lat + delta},${lng + delta},${lat - delta}';

    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search'
      '?q=${Uri.encodeComponent(query)}'
      '&format=json'
      '&limit=50'
      '&viewbox=$viewbox'
      '&bounded=1',
    );

    final response = await http.get(
      url,
      headers: {'User-Agent': 'SmartPlaces Flutter App'},
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      setState(() {
        places = data.map((item) {
          return Place(
            id: item['place_id'].toString(),
            name: item['display_name'].split(',')[0],
            lat: double.parse(item['lat']),
            lng: double.parse(item['lon']),
            address: item['display_name'],
          );
        }).toList();
      });
    }
  }

  void toggleFavorite(Place p) async {
    if (!likedPlacesIds.contains(p.id)) {
      likedPlacesIds.add(p.id);
      await favoritesService.addFavorite(p);
    } else {
      likedPlacesIds.remove(p.id);
      await favoritesService.removeFavorite(p);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            Expanded(
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "restaurant, café, pharmacie...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onSubmitted: (_) => searchPlaces(searchController.text),
              ),
            ),
            SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.search, color: Colors.blue),
              onPressed: () => searchPlaces(searchController.text),
            ),
          ],
        ),
      ),

      // ================= MAP =================
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: mapCenter,
              initialZoom: 15,
              minZoom: 12,
              maxZoom: 18,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.smartplaces',
              ),
              MarkerLayer(
                markers: places.map((p) {
                  final isFav = likedPlacesIds.contains(p.id);
                  return Marker(
                    point: LatLng(p.lat, p.lng),
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text(p.name),
                            content: Text(p.address),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text("Fermer"),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  toggleFavorite(p);
                                  Navigator.pop(context);
                                },
                                icon: Icon(
                                  isFav
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                ),
                                label: Text(isFav ? "Retirer" : "Ajouter"),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Icon(
                        isFav ? Icons.favorite : Icons.location_on,
                        color: isFav ? Colors.pink : Colors.red,
                        size: 40,
                      ),
                    ),
                  );
                }).toList(),
              ),
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    'OpenStreetMap contributors',
                    onTap: () async {
                      final url = Uri.parse(
                        'https://openstreetmap.org/copyright',
                      );
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),

          // Boutons flottants (inchangés)
          Positioned(
            bottom: 160,
            right: 10,
            child: FloatingActionButton(
              heroTag: "center",
              mini: true,
              child: Icon(Icons.my_location),
              onPressed: () {
                mapController.move(mapCenter, 15);
              },
            ),
          ),
          Positioned(
            bottom: 100,
            right: 10,
            child: FloatingActionButton(
              heroTag: "zoomIn",
              mini: true,
              child: Icon(Icons.add),
              onPressed: () {
                mapController.move(
                  mapController.camera.center,
                  mapController.camera.zoom + 1,
                );
              },
            ),
          ),
          Positioned(
            bottom: 40,
            right: 10,
            child: FloatingActionButton(
              heroTag: "zoomOut",
              mini: true,
              child: Icon(Icons.remove),
              onPressed: () {
                mapController.move(
                  mapController.camera.center,
                  mapController.camera.zoom - 1,
                );
              },
            ),
          ),
        ],
      ),

      // ================= BOTTOM NAV =================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          if (index == 1) {
            Navigator.pushNamed(context, '/favorites');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Carte"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Favoris"),
        ],
      ),
    );
  }
}
