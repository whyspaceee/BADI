import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:sports_buddy/services/firestore_service.dart';

class MapService {
  Location _location;

  MapService(this._location);

  Future<LocationData> getUserLocation() {
    return _location.getLocation();
  }
}
