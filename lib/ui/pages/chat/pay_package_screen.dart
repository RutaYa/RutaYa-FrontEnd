import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../domain/entities/tour_package.dart';
import '../../../core/routes/app_routes.dart';

enum PaymentMethod { none, card, yape }
enum PaymentStep { selection, form, processing }

class PayPackageScreen extends StatefulWidget {
  final TourPackage package;

  const PayPackageScreen({
    super.key,
    required this.package,
  });

  @override
  State<PayPackageScreen> createState() => _PayPackageScreenState();
}

class _PayPackageScreenState extends State<PayPackageScreen> {
  PaymentMethod _selectedMethod = PaymentMethod.none;
  PaymentStep _currentStep = PaymentStep.selection;

  // Controladores para formulario de tarjeta
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _cardHolderController = TextEditingController();

  // Controlador para Yape
  final TextEditingController _phoneController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _cardHolderController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (_currentStep == PaymentStep.form) {
              setState(() {
                _currentStep = PaymentStep.selection;
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          _getAppBarTitle(),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  String _getAppBarTitle() {
    switch (_currentStep) {
      case PaymentStep.selection:
        return 'Pago';
      case PaymentStep.form:
        return _selectedMethod == PaymentMethod.card ? 'Datos de Tarjeta' : 'Pago con Yape';
      case PaymentStep.processing:
        return 'Procesando...';
    }
  }

  Widget _buildBody() {
    switch (_currentStep) {
      case PaymentStep.selection:
        return _buildPaymentMethodSelection();
      case PaymentStep.form:
        return _selectedMethod == PaymentMethod.card
            ? _buildCardForm()
            : _buildYapeForm();
      case PaymentStep.processing:
        return _buildProcessingView();
    }
  }

  Widget _buildPaymentMethodSelection() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Elige un medio de pago',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),

          // Opción de Tarjeta de crédito y débito
          _buildPaymentOption(
            method: PaymentMethod.card,
            title: 'Tarjeta de crédito y débito',
            child: Row(
              children: [
                Image.asset(
                  'assets/images/visa.png',
                  height: 24,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('VISA', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                ),
                Image.asset(
                  'assets/images/mastercard.png',
                  height: 24,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('MC', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                ),
                Image.asset(
                  'assets/images/dinersclub.png',
                  height: 24,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('DINERS', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                ),
                Image.asset(
                  'assets/images/american.png',
                  height: 24,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue[800],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('AMEX', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                )
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Opción de Yape
          _buildPaymentOption(
            method: PaymentMethod.yape,
            title: 'Pago con Yape',
            child: Row(
              children: [
                Image.asset(
                  'assets/images/yape.png',
                  height: 50,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00D4AA),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('YAPE', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                      ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Botón Continuar
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _selectedMethod != PaymentMethod.none
                  ? () {
                setState(() {
                  _currentStep = PaymentStep.form;
                });
              }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedMethod != PaymentMethod.none
                    ? const Color(0xFFF52525)
                    : Colors.grey[300],
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Continuar',
                style: TextStyle(
                  color: _selectedMethod != PaymentMethod.none
                      ? Colors.white
                      : Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCardForm() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resumen del paquete
            _buildPackageSummary(),
            const SizedBox(height: 24),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Datos de la tarjeta',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Número de tarjeta
                    TextFormField(
                      controller: _cardNumberController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(16),
                        _CardNumberFormatter(),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Número de tarjeta',
                        hintText: '1234 5678 9012 3456',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFF52525), width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa el número de tarjeta';
                        }
                        if (value.replaceAll(' ', '').length < 13) {
                          return 'Número de tarjeta inválido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Nombre del titular
                    TextFormField(
                      controller: _cardHolderController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        labelText: 'Nombre del titular',
                        hintText: 'JUAN PEREZ',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFF52525), width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa el nombre del titular';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Fecha de vencimiento y CVV
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _expiryDateController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                              _ExpiryDateFormatter(),
                            ],
                            decoration: InputDecoration(
                              labelText: 'MM/AA',
                              hintText: '12/25',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFF52525), width: 2),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ingresa la fecha';
                              }
                              if (value.length < 5) {
                                return 'Fecha inválida';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _cvvController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                            ],
                            decoration: InputDecoration(
                              labelText: 'CVV',
                              hintText: '123',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFF52525), width: 2),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ingresa el CVV';
                              }
                              if (value.length < 3) {
                                return 'CVV inválido';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Botón de pago
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _processPayment();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF52525),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Pagar S/ ${widget.package.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildYapeForm() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resumen del paquete
          _buildPackageSummary(),
          const SizedBox(height: 24),

          const Text(
            'Pago con Yape',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),

          // Instrucciones
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Instrucciones:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                const Text('1. Abre tu app Yape'),
                const Text('2. Selecciona "Yapear"'),
                const Text('3. Ingresa el número: 987 654 321'),
                const Text('4. Monto: S/ '),
                Text('5. Concepto: Pago ${widget.package.title}'),
                const SizedBox(height: 12),
                const Text(
                  'Luego ingresa tu número de celular para confirmar:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Campo de teléfono
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(9),
            ],
            decoration: InputDecoration(
              labelText: 'Tu número de celular',
              hintText: '987654321',
              prefixText: '+51 ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFF52525), width: 2),
              ),
            ),
          ),

          const Spacer(),

          // Botón confirmar
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _phoneController.text.length == 9
                  ? () {
                _processPayment();
              }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _phoneController.text.length == 9
                    ? const Color(0xFFF52525)
                    : Colors.grey[300],
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Confirmar Pago',
                style: TextStyle(
                  color: _phoneController.text.length == 9
                      ? Colors.white
                      : Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPackageSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.package.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'S/ ${widget.package.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Color(0xFFF52525),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF52525)),
          ),
          SizedBox(height: 24),
          Text(
            'Procesando tu pago...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Por favor espera un momento',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required PaymentMethod method,
    required String title,
    required Widget child,
  }) {
    final isSelected = _selectedMethod == method;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = method;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFFF52525) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFFF52525) : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFF52525),
                  ),
                ),
              )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.black : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  child,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _processPayment() {
    setState(() {
      _currentStep = PaymentStep.processing;
    });

    // Simular procesamiento de pago
    Future.delayed(const Duration(seconds: 3), () {
      // Aquí iría la lógica real de pago
      _showPaymentResult(true); // true = éxito, false = error
    });
  }

  void _showPaymentResult(bool success) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white, // Fondo blanco
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Icon(
          success ? Icons.check_circle : Icons.error,
          color: success ? Colors.green : Colors.red,
          size: 64,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              success ? '¡Pago exitoso!' : 'Error en el pago',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              success
                  ? 'Tu reserva ha sido confirmada'
                  : 'Inténtalo nuevamente',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: success
            ? [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cerrar diálogo
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.main,
                    (route) => false, // Esto elimina todas las rutas anteriores
              );
            },
            child: const Text(
              'Ver mis reservas',
              style: TextStyle(color: Color(0xFFF52525)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cerrar diálogo
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.main,
                    (route) => false,
                arguments: {
                  'initialIndex': 1
                },
              );
            },
            child: const Text(
              'Volver al chat',
              style: TextStyle(color: Color(0xFFF52525)),
            ),
          ),
        ]
            : [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cerrar diálogo
              setState(() {
                _currentStep = PaymentStep.selection;
              });
            },
            child: const Text(
              'Reintentar',
              style: TextStyle(color: Color(0xFFF52525)),
            ),
          ),
        ],
      ),
    );
  }

}

// Formateadores personalizados
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final text = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i == 2) {
        buffer.write('/');
      }
      buffer.write(text[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}