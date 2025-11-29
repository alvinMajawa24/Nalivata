class Booking {
  final int id;
  final int userId;
  final int listingId;
  final String checkIn;
  final String checkOut;
  final int guests;
  final double totalPrice;
  final String status;
  final String bookingReference;
  final String? transactionId;
  final String? createdAt;
  final String? title;
  final String? type;
  final String? location;
  final String? imageUrl;
  final String? description;

  Booking({
    required this.id,
    required this.userId,
    required this.listingId,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    required this.totalPrice,
    required this.status,
    required this.bookingReference,
    this.transactionId,
    this.createdAt,
    this.title,
    this.type,
    this.location,
    this.imageUrl,
    this.description,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: int.parse(json['id'].toString()),
      userId: int.parse(json['user_id'].toString()),
      listingId: int.parse(json['listing_id'].toString()),
      checkIn: json['check_in'],
      checkOut: json['check_out'],
      guests: int.parse(json['guests'].toString()),
      totalPrice: double.parse(json['total_price'].toString()),
      status: json['status'],
      bookingReference: json['booking_reference'],
      transactionId: json['transaction_id'],
      createdAt: json['created_at'],
      title: json['title'],
      type: json['type'],
      location: json['location'],
      imageUrl: json['image_url'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'listing_id': listingId,
      'check_in': checkIn,
      'check_out': checkOut,
      'guests': guests,
      'total_price': totalPrice,
      'status': status,
      'booking_reference': bookingReference,
      'transaction_id': transactionId,
      'created_at': createdAt,
    };
  }
}

