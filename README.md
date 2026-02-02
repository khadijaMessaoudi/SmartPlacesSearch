# SmartPlaces

**Student:** Messaoudi Khadija   
**Course:** DMIU – 2025–2026  
**Platform:** Flutter   

## Project Overview

SmartPlaces is a Flutter application that allows users to search for places such as restaurants, cafes, and pharmacies, view them on a map, and manage their favorite locations. The app demonstrates Flutter development skills, including navigation between multiple screens, state management, data persistence, and communication with a remote service.

Main features of the application include:  
- Searching for places by name and displaying them on an interactive map.  
- Adding and removing favorite places stored in Firebase Firestore.  
- Viewing a list of favorite places with real-time updates.  
- Zooming, recentering, and clearing search results on the map.  
- User authentication (signup, login, logout).  

## User Experience

### Map Screen
- Users can search for places using the search bar at the top.  
- Search results are displayed as markers on the map.  
- Clicking on a marker opens a dialog with the place name, address, and an option to add or remove it from favorites.  
- Floating action buttons allow users to recenter the map, zoom in/out, and clear search results.  

### Favorites Screen
- Displays a list of favorite places with name and address.  
- Users can remove favorites directly from the list.  
- Logout button is available in the app bar.  

### Navigation
- The app uses named routes for smooth navigation between screens: login, signup, map, and favorites.  


## Technology Stack

- **Flutter & Dart** – main development framework.  
- **Firebase Authentication** – handles user signup, login, and logout.  
- **Cloud Firestore** – stores favorite places for each user.  
- **Flutter Map & OpenStreetMap API** – interactive map functionality.  
- **http package** – fetch search results from OpenStreetMap Nominatim API.  

## Implementation Details

- Favorites are managed in real-time using Firestore streams for automatic UI updates.  
- Local state is used to track which places are liked for immediate feedback.  
- The map markers update dynamically based on search results.  
- Proper error handling is implemented for network requests and Firebase operations.  

## Challenges and Solutions

- **Challenge:** Integrating map markers with dynamic favorites.  
  **Solution:** Used a combination of Flutter state management and Firestore streams to update markers in real time.  

- **Challenge:** Handling user authentication and secure data storage.  
  **Solution:** Firebase Authentication ensures secure login/signup, while favorites are stored under each user’s document in Firestore.  

## Packages Used

- `flutter_map` – for map functionality  
- `latlong2` – for map coordinates  
- `http` – for API requests  
- `firebase_auth` – for user authentication  
- `cloud_firestore` – for storing favorites  
- `url_launcher` – to open external links  
- `provider` or built-in `setState` – for state management  

## How to Run

1. Clone the repository:  
   ```bash
   git clone https://github.com/khadijaMessaoudi/SmartPlacesSearch


2 Install dependencies:

    flutter pub get


Run the app:

    flutter run
