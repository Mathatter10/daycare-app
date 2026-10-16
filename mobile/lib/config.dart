/// Backend base URL. Override for local testing with
/// `flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8080`.
const String apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'https://daycare-api-v3in.onrender.com');
