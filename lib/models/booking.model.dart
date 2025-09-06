class Booking {
  final int id;
  final String pnr;
  final int userId;
  final int tripId;
  final int seatId;
  final String departureDate;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Booking({
    required this.id,
    required this.pnr,
    required this.userId,
    required this.tripId,
    required this.seatId,
    required this.departureDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory method untuk membuat objek Booking dari JSON
  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      pnr: json['pnr'],
      userId: json['user_id'],
      tripId: json['trip_id'],
      seatId: json['seat_id'],
      departureDate: json['departure_date'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
