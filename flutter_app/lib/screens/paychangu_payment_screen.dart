import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/paychangu_service.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'payment_success_screen.dart';

class PayChanguPaymentScreen extends StatefulWidget {
  final String bookingReference;
  final double totalPrice;
  final String email;
  final String firstName;
  final String lastName;
  final String? listingTitle;
  final String? location;
  final String? checkIn;
  final String? checkOut;
  final int? guests;
  final int? nights;
  final double? pricePerNight;

  const PayChanguPaymentScreen({
    super.key,
    required this.bookingReference,
    required this.totalPrice,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.listingTitle,
    this.location,
    this.checkIn,
    this.checkOut,
    this.guests,
    this.nights,
    this.pricePerNight,
  });

  @override
  State<PayChanguPaymentScreen> createState() => _PayChanguPaymentScreenState();
}

class _PayChanguPaymentScreenState extends State<PayChanguPaymentScreen> {
  late final WebViewController controller;
  bool _isLoading = true;
  bool _paymentCompleted = false;

  @override
  void initState() {
    super.initState();
    
    final payChanguService = PayChanguService();
    final callbackUrl = 'https://travelbooking.app/callback?tx_ref=${widget.bookingReference}&status=success';
    final returnUrl = 'https://travelbooking.app/return?tx_ref=${widget.bookingReference}&status=failed';
    final htmlContent = payChanguService.generatePaymentHtml(
      amount: widget.totalPrice,
      currency: 'MWK',
      email: widget.email,
      firstName: widget.firstName,
      lastName: widget.lastName,
      callbackUrl: callbackUrl,
      returnUrl: returnUrl,
      reference: widget.bookingReference,
      description: 'Travel Booking - ${widget.bookingReference}',
      listingTitle: widget.listingTitle,
      location: widget.location,
      checkIn: widget.checkIn,
      checkOut: widget.checkOut,
      guests: widget.guests,
      nights: widget.nights,
      pricePerNight: widget.pricePerNight,
    );

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(true)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
            
            if (url.contains('travelbooking.app/callback') || 
                url.contains('travelbooking.app/return')) {
              _handlePaymentCallback(url);
            }
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
            
            if (url.contains('travelbooking.app/callback') || 
                (url.contains('paychangu.com') && url.contains('success'))) {
              _handlePaymentCallback(url);
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.contains('travelbooking.app/callback') || 
                request.url.contains('travelbooking.app/return')) {
              _handlePaymentCallback(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onWebResourceError: (WebResourceError error) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Payment page error: ${error.description}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
      )
      ..loadHtmlString(htmlContent);
  }

  void _handlePaymentCallback(String url) async {
    if (_paymentCompleted) return;
    
    final uri = Uri.parse(url);
    final txRef = uri.queryParameters['tx_ref'] ?? widget.bookingReference;
    final status = uri.queryParameters['status'];
    
    if (url.contains('/callback')) {
      _paymentCompleted = true;
      await _completePayment(txRef);
    } else if (url.contains('/return') && status == 'failed') {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment was cancelled or failed'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _completePayment(String txRef) async {
    try {
      final apiService = ApiService();
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;
      if (token != null) {
        apiService.setToken(token);
      }

      final result = await apiService.simulatePayment(
        bookingReference: widget.bookingReference,
        paymentMethod: 'paychangu',
      );

      if (!mounted) return;

      if (result.isSuccess) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => PaymentSuccessScreen(
              transactionId: txRef,
              bookingReference: widget.bookingReference,
              totalPrice: widget.totalPrice,
            ),
          ),
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message.isNotEmpty ? result.message : 'Payment verification failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PayChangu Payment'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

