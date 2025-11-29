import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart';
import '../services/paychangu_service.dart';
import '../services/api_service.dart';
import 'payment_success_screen.dart';

class PaymentProcessingScreen extends StatefulWidget {
  final String bookingReference;
  final String paymentMethod;
  final double totalPrice;

  const PaymentProcessingScreen({
    super.key,
    required this.bookingReference,
    required this.paymentMethod,
    required this.totalPrice,
  });

  @override
  State<PaymentProcessingScreen> createState() => _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState extends State<PaymentProcessingScreen> {
  bool _isProcessing = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _processPayment();
  }

  Future<void> _processPayment() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser;
      
      if (user == null) {
        setState(() {
          _isProcessing = false;
          _errorMessage = 'User not authenticated';
        });
        return;
      }

      final payChanguService = PayChanguService();
      final paymentResult = await payChanguService.initializePayment(
        amount: widget.totalPrice,
        currency: 'MWK',
        email: user.email,
        phoneNumber: '+265900000000', // Default phone - should be from user profile
        firstName: user.name.split(' ').first,
        lastName: user.name.split(' ').length > 1 ? user.name.split(' ').last : '',
        reference: widget.bookingReference,
        metadata: {
          'booking_reference': widget.bookingReference,
          'payment_method': widget.paymentMethod,
        },
      );

      if (!mounted) return;

      if (paymentResult['status'] == 'success' && paymentResult['payment_url'] != null) {
        final paymentUrl = paymentResult['payment_url'];
        final uri = Uri.parse(paymentUrl);
        
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          _checkPaymentStatus(paymentResult['reference']);
        } else {
          setState(() {
            _isProcessing = false;
            _errorMessage = 'Could not open payment page';
          });
        }
      } else {
        setState(() {
          _isProcessing = false;
          _errorMessage = paymentResult['message'] ?? 'Payment initialization failed';
        });
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _errorMessage = 'Error: $e';
      });
    }
  }

  Future<void> _checkPaymentStatus(String reference) async {
    final payChanguService = PayChanguService();
    
    for (int i = 0; i < 20; i++) {
      await Future.delayed(const Duration(seconds: 3));
      
      if (!mounted) return;
      
      final status = await payChanguService.verifyPayment(reference);
      
      if (status['status'] == 'success' && status['paid'] == true) {
        final apiService = ApiService();
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final token = authProvider.token;
        if (token != null) {
          apiService.setToken(token);
        }

        final result = await apiService.simulatePayment(
          bookingReference: widget.bookingReference,
          paymentMethod: widget.paymentMethod,
        );

        if (!mounted) return;

        if (result.isSuccess) {
          setState(() => _isProcessing = false);
          await Future.delayed(const Duration(milliseconds: 500));
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => PaymentSuccessScreen(
                transactionId: reference,
                bookingReference: widget.bookingReference,
                totalPrice: widget.totalPrice,
              ),
            ),
          );
          return;
        }
      }
    }
    
    if (mounted) {
      setState(() {
        _isProcessing = false;
        _errorMessage = 'Payment verification timeout. Please check your booking status.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Processing Payment'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: _isProcessing
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 24),
                  const Text(
                    'Processing your payment...',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please wait',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              )
            : _errorMessage != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.shade400,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Payment Failed',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade800,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Try Again'),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
      ),
    );
  }
}

