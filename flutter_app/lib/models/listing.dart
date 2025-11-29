class Listing {
  final int id;
  final String type;
  final String title;
  final String? description;
  final String location;
  final double price;
  final double rating;
  final String? imageUrl;
  final String? availableFrom;
  final String? availableTo;

  Listing({
    required this.id,
    required this.type,
    required this.title,
    this.description,
    required this.location,
    required this.price,
    required this.rating,
    this.imageUrl,
    this.availableFrom,
    this.availableTo,
  });

  factory Listing.fromJson(Map<String, dynamic> json) {
    return Listing(
      id: int.parse(json['id'].toString()),
      type: json['type'],
      title: json['title'],
      description: json['description'],
      location: json['location'],
      price: double.parse(json['price'].toString()),
      rating: double.parse(json['rating'].toString()),
      imageUrl: json['image_url'],
      availableFrom: json['available_from'],
      availableTo: json['available_to'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'description': description,
      'location': location,
      'price': price,
      'rating': rating,
      'image_url': imageUrl,
      'available_from': availableFrom,
      'available_to': availableTo,
    };
  }
}

