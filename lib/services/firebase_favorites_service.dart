import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/place.dart';

class FirebaseFavoritesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  // Référence à la collection des favoris de l'utilisateur
  CollectionReference<Map<String, dynamic>>? get _favoritesCollection {
    if (_userId == null) return null;
    return _firestore.collection('users').doc(_userId).collection('favorites');
  }

  // Ajouter aux favoris
  Future<void> addFavorite(Place place) async {
    if (_favoritesCollection == null) return;

    try {
      await _favoritesCollection!.doc(place.id).set({
        'id': place.id,
        'name': place.name,
        'lat': place.lat,
        'lng': place.lng,
        'address': place.address,
        'addedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Erreur lors de l\'ajout aux favoris: $e');
      throw e;
    }
  }

  // Supprimer des favoris
  Future<void> removeFavorite(Place place) async {
    if (_favoritesCollection == null) return;

    try {
      await _favoritesCollection!.doc(place.id).delete();
    } catch (e) {
      print('Erreur lors de la suppression des favoris: $e');
      throw e;
    }
  }

  // Obtenir les favoris
  Future<List<Place>> getFavorites() async {
    if (_favoritesCollection == null) return [];

    try {
      QuerySnapshot snapshot = await _favoritesCollection!.get();
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Place.fromJson(data);
      }).toList();
    } catch (e) {
      print('Erreur lors de la récupération des favoris: $e');
      return [];
    }
  }

  // Stream des favoris (pour mise à jour en temps réel)
  Stream<List<Place>> get favoritesStream {
    if (_favoritesCollection == null) return Stream.value([]);

    return _favoritesCollection!.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Place.fromJson(data);
      }).toList();
    });
  }

  // Vérifier si un lieu est en favori
  Future<bool> isFavorite(String placeId) async {
    if (_favoritesCollection == null) return false;

    try {
      DocumentSnapshot doc = await _favoritesCollection!.doc(placeId).get();
      return doc.exists;
    } catch (e) {
      print('Erreur lors de la vérification des favoris: $e');
      return false;
    }
  }
}
