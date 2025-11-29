class PaymentResult {
  final String status;
  final String message;
  final String? transactionId;
  final String? bookingReference;
  final String? paymentMethod;

  PaymentResult({
    required this.status,
    required this.message,
    this.transactionId,
    this.bookingReference,
    this.paymentMethod,
  });

  factory PaymentResult.fromJson(Map<String, dynamic> json) {
    return PaymentResult(
      status: json['status'],
      message: json['message'],
      transactionId: json['transaction_id'],
      bookingReference: json['booking_reference'],
      paymentMethod: json['payment_method'],
    );
  }

  bool get isSuccess => status == 'success';
}

