class PayChanguService {
  static const String publicKey = 'pub-test-8dUsTHO7JLzE6cRQuFyH9co3ko3GZkYV';
  static const String secretKey = 'sec-test-LWZzKZsVO1QwtOLFP8fqZys1T2qDt2Gf';
  static const String hostedPaymentUrl = 'https://api.paychangu.com/hosted-payment-page';
  String generatePaymentHtml({
    required double amount,
    required String currency,
    required String email,
    required String firstName,
    required String lastName,
    required String callbackUrl,
    required String returnUrl,
    String? reference,
    String? description,
    String? listingTitle,
    String? location,
    String? checkIn,
    String? checkOut,
    int? guests,
    int? nights,
    double? pricePerNight,
    Map<String, dynamic>? metadata,
  }) {
    final txRef = reference ?? 'TXN-${DateTime.now().millisecondsSinceEpoch}';
    final metaJson = metadata != null ? Uri.encodeComponent(metadata.toString()) : '';
    final checkInFormatted = checkIn ?? '';
    final checkOutFormatted = checkOut ?? '';
    
    return '''
<!DOCTYPE html>
<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PayChangu Payment - Travel Booking</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 20px;
            min-height: 100vh;
        }
        .container {
            max-width: 500px;
            margin: 0 auto;
        }
        .card {
            background: white;
            border-radius: 16px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            overflow: hidden;
            margin-bottom: 20px;
        }
        .header {
            background: linear-gradient(135deg, #1976D2 0%, #1565C0 100%);
            color: white;
            padding: 24px;
            text-align: center;
        }
        .header h1 {
            font-size: 24px;
            margin-bottom: 8px;
        }
        .header p {
            opacity: 0.9;
            font-size: 14px;
        }
        .content {
            padding: 24px;
        }
        .section {
            margin-bottom: 24px;
        }
        .section-title {
            font-size: 16px;
            font-weight: 600;
            color: #333;
            margin-bottom: 12px;
            padding-bottom: 8px;
            border-bottom: 2px solid #e0e0e0;
        }
        .detail-row {
            display: flex;
            justify-content: space-between;
            padding: 10px 0;
            border-bottom: 1px solid #f0f0f0;
        }
        .detail-row:last-child {
            border-bottom: none;
        }
        .detail-label {
            color: #666;
            font-size: 14px;
        }
        .detail-value {
            color: #333;
            font-weight: 600;
            font-size: 14px;
        }
        .bill-section {
            background: #f8f9fa;
            border-radius: 12px;
            padding: 16px;
            margin-top: 20px;
        }
        .bill-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 12px;
        }
        .bill-row.total {
            margin-top: 12px;
            padding-top: 12px;
            border-top: 2px solid #1976D2;
            font-size: 20px;
            font-weight: bold;
        }
        .bill-label {
            color: #666;
        }
        .bill-value {
            color: #1976D2;
            font-weight: bold;
        }
        .user-info {
            background: #e3f2fd;
            border-radius: 8px;
            padding: 16px;
            margin-bottom: 20px;
        }
        .user-info p {
            margin: 4px 0;
            font-size: 14px;
        }
        .submit-btn {
            width: 100%;
            padding: 18px;
            background: linear-gradient(135deg, #1976D2 0%, #1565C0 100%);
            color: white;
            border: none;
            border-radius: 12px;
            font-size: 18px;
            font-weight: bold;
            cursor: pointer;
            margin-top: 24px;
            box-shadow: 0 4px 15px rgba(25, 118, 210, 0.4);
            transition: transform 0.2s;
        }
        .submit-btn:active {
            transform: scale(0.98);
        }
        .loading {
            text-align: center;
            padding: 20px;
            color: #666;
        }
        .spinner {
            border: 3px solid #f3f3f3;
            border-top: 3px solid #1976D2;
            border-radius: 50%;
            width: 40px;
            height: 40px;
            animation: spin 1s linear infinite;
            margin: 20px auto;
        }
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="card">
            <div class="header">
                <h1>🛫 Travel Booking Payment</h1>
                <p>Secure payment via PayChangu</p>
            </div>
            <div class="content">
                <div class="section">
                    <div class="section-title">Booking Details</div>
                    ${listingTitle != null ? '<div class="detail-row"><span class="detail-label">Property:</span><span class="detail-value">${listingTitle.replaceAll("'", "\\'")}</span></div>' : ''}
                    ${location != null ? '<div class="detail-row"><span class="detail-label">Location:</span><span class="detail-value">${location.replaceAll("'", "\\'")}</span></div>' : ''}
                    ${checkInFormatted.isNotEmpty ? '<div class="detail-row"><span class="detail-label">Check-in:</span><span class="detail-value" id="checkInDate">$checkInFormatted</span></div>' : ''}
                    ${checkOutFormatted.isNotEmpty ? '<div class="detail-row"><span class="detail-label">Check-out:</span><span class="detail-value" id="checkOutDate">$checkOutFormatted</span></div>' : ''}
                    ${nights != null ? '<div class="detail-row"><span class="detail-label">Nights:</span><span class="detail-value">$nights</span></div>' : ''}
                    ${guests != null ? '<div class="detail-row"><span class="detail-label">Guests:</span><span class="detail-value">$guests</span></div>' : ''}
                    ${pricePerNight != null ? '<div class="detail-row"><span class="detail-label">Price per night:</span><span class="detail-value">$currency ${pricePerNight.toStringAsFixed(0)}</span></div>' : ''}
                </div>

                <div class="user-info">
                    <div class="section-title" style="border: none; margin-bottom: 8px;">Customer Information</div>
                    <p><strong>Name:</strong> $firstName $lastName</p>
                    <p><strong>Email:</strong> $email</p>
                    <p><strong>Booking Reference:</strong> $txRef</p>
                </div>

                <div class="bill-section">
                    <div class="bill-row total">
                        <span class="bill-label">Total Amount</span>
                        <span class="bill-value">$currency ${amount.toStringAsFixed(0)}</span>
                    </div>
                </div>

                <form id="paychanguForm" method="POST" action="$hostedPaymentUrl">
                    <input type="hidden" name="public_key" value="$publicKey" />
                    <input type="hidden" name="callback_url" value="$callbackUrl" />
                    <input type="hidden" name="return_url" value="$returnUrl" />
                    <input type="hidden" name="tx_ref" value="$txRef" />
                    <input type="hidden" name="amount" value="${amount.toStringAsFixed(0)}" />
                    <input type="hidden" name="currency" value="$currency" />
                    <input type="hidden" name="email" value="$email" />
                    <input type="hidden" name="first_name" value="$firstName" />
                    <input type="hidden" name="last_name" value="$lastName" />
                    <input type="hidden" name="title" value="Travel Booking Payment" />
                    <input type="hidden" name="description" value="${description ?? 'Travel booking payment - $txRef'}" />
                    ${metaJson.isNotEmpty ? '<input type="hidden" name="meta" value="$metaJson" />' : ''}
                    <button type="submit" class="submit-btn">Pay with PayChangu</button>
                </form>

                <div id="loading" class="loading" style="display: none;">
                    <div class="spinner"></div>
                    <p>Redirecting to secure payment page...</p>
                </div>
            </div>
        </div>
    </div>
    <script>
        function formatDate(dateStr) {
            if (!dateStr) return 'N/A';
            try {
                const date = new Date(dateStr);
                const day = String(date.getDate()).padStart(2, '0');
                const month = String(date.getMonth() + 1).padStart(2, '0');
                const year = date.getFullYear();
                return day + '/' + month + '/' + year;
            } catch (e) {
                return dateStr;
            }
        }
        
        window.onload = function() {
            const checkInEl = document.getElementById('checkInDate');
            const checkOutEl = document.getElementById('checkOutDate');
            if (checkInEl) checkInEl.textContent = formatDate(checkInEl.textContent);
            if (checkOutEl) checkOutEl.textContent = formatDate(checkOutEl.textContent);
        };
        
        document.getElementById('paychanguForm').addEventListener('submit', function(e) {
            document.getElementById('loading').style.display = 'block';
            document.querySelector('.submit-btn').style.display = 'none';
        });
        
        setTimeout(function() {
            document.getElementById('paychanguForm').submit();
        }, 3000);
    </script>
</body>
</html>
''';
  }

  Future<Map<String, dynamic>> verifyPayment(String reference) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      return {
        'status': 'success',
        'data': {
          'reference': reference,
          'status': 'paid',
        },
        'paid': true,
      };
        Uri.parse('$baseUrl/v1/payments/verify/$reference'),
        headers: {
          'Authorization': 'Bearer $secretKey',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'status': 'success',
          'data': data,
          'paid': data['status'] == 'success' || data['status'] == 'paid',
        };
      } else {
        return {
          'status': 'error',
          'message': 'Verification failed',
        };
      }
      */
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Network error: $e',
      };
    }
  }
}

