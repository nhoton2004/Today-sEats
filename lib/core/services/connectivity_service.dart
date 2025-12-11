import 'package:connectivity_plus/connectivity_plus.dart';

/// Service to check network connectivity
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  /// Check if device has internet connection
  Future<bool> hasInternetConnection() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      
      // Check if connected via mobile data or wifi
      return connectivityResult.contains(ConnectivityResult.mobile) ||
             connectivityResult.contains(ConnectivityResult.wifi) ||
             connectivityResult.contains(ConnectivityResult.ethernet);
    } catch (e) {
      print('Error checking connectivity: $e');
      return false;
    }
  }

  /// Stream to listen to connectivity changes
  Stream<List<ConnectivityResult>> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged;
  }

  /// Get current connectivity status
  Future<List<ConnectivityResult>> getCurrentConnectivity() async {
    try {
      return await _connectivity.checkConnectivity();
    } catch (e) {
      print('Error getting connectivity: $e');
      return [ConnectivityResult.none];
    }
  }

  /// Check if specific connectivity type is available
  Future<bool> isConnectedVia(ConnectivityResult type) async {
    final results = await getCurrentConnectivity();
    return results.contains(type);
  }
}
