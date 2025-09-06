class ApiConstant {
  // Mode environment: "dev" atau "prod"
  static const String env = "dev";

  // Base URL
  static String get baseUrl {
    if (env == "dev") {
      return "http://10.211.122.88:8000/api"; // lokal
      //ip hp 10.187.36.139
    } else {
      return "https://api.domain.com/api"; // server hosting
    }
  }

  // Auth
  static String get register => "$baseUrl/register";
  static String get login => "$baseUrl/login";

  // User
  static String get users => "$baseUrl/users";

  // Master data
  static String get trains => "$baseUrl/trains";
  static String get stations => "$baseUrl/stations";

  // Trip
  static String get pencariantrip => "$baseUrl/trips/search";

  // Seats (dynamic endpoint -> butuh trainId)
  static String seats(int trainId) => "$baseUrl/trains/$trainId/seats";
}
