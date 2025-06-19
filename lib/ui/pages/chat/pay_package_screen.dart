import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../domain/entities/tour_package.dart';
import '../../../core/routes/app_routes.dart';
import '../../../main.dart';
import '../../../application/save_tour_package_use_case.dart';
import '../../../application/pay_tour_package_use_case.dart';

enum PaymentMethod { none, card, yape }
enum PaymentStep { selection, form, processing }

class PayPackageScreen extends StatefulWidget {
  final TourPackage package;
  final bool isFromChat;

  const PayPackageScreen({
    super.key,
    required this.package,
    required this.isFromChat
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
  List<TextEditingController> _codeControllers = List.generate(6, (index) => TextEditingController());

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
    for (var controller in _codeControllers) {
      controller.dispose();
    }
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

  void _clearForms() {
    // Limpiar formulario de tarjeta
    _cardNumberController.clear();
    _expiryDateController.clear();
    _cvvController.clear();
    _cardHolderController.clear();

    // Limpiar formulario de Yape
    _phoneController.clear();
    for (var controller in _codeControllers) {
      controller.clear();
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
                // Limpiar formularios antes de continuar
                _clearForms();
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Título
          const Text(
            'Ingresa tu celular Yape',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),

          // Campo de número de celular
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(9),
              ],
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 16),
                hintText: '987 654 321',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 18,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  // Esto actualizará el estado del botón cuando cambie el teléfono
                });
              },
            ),
          ),
          const SizedBox(height: 32),

          // Título código de aprobación
          const Text(
            'Código de aprobación',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Campos de código de aprobación (6 dígitos)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(6, (index) {
              return Container(
                width: 45,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextFormField(
                  controller: _codeControllers[index],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(1),
                  ],
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    counterText: '',
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty && index < 5) {
                      FocusScope.of(context).nextFocus();
                    } else if (value.isEmpty && index > 0) {
                      FocusScope.of(context).previousFocus();
                    }
                    // Actualizar el estado del botón cuando cambie cualquier dígito
                    setState(() {});
                  },
                ),
              );
            }),
          ),
          const SizedBox(height: 32),

          // Texto "Encuéntralo en el menú de Yape"
          const Text(
            'Encuéntralo en el menú de Yape',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 40),

          // Botón Yapear
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _isFormValid() ? () {
                _processPayment();
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isFormValid()
                    ? const Color(0xFF722F8B) // Color morado de Yape
                    : Colors.grey[300],
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Yapear S/ ${widget.package.price.toStringAsFixed(2)}',
                style: TextStyle(
                  color: _isFormValid()
                      ? Colors.white
                      : Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Logo de Yape
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
    );
  }

  // Método para validar el formulario
  bool _isFormValid() {
    if (_phoneController.text.length != 9) return false;

    for (var controller in _codeControllers) {
      if (controller.text.isEmpty) return false;
    }

    return true;
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

  void _processPayment() async {
    setState(() {
      _currentStep = PaymentStep.processing;
    });

    try {
      bool success = false;

      if (widget.isFromChat) {
        print("ESTOY CREANDO UN PACKAGE PAGADO");

        final updatedPackage = widget.package.copyWith(isPaid: true);

        print(updatedPackage);

        final saveTourPackageUseCase = getIt<SaveTourPackageUseCase>();
        success = await saveTourPackageUseCase.saveTourPackage(updatedPackage);
      } else {
        print("ESTOY PAGANDO UN PACKAGE PENDIENTE");
        final payTourPackageUseCase = getIt<PayTourPackageUseCase>();
        success = await payTourPackageUseCase.payTourPackage(widget.package.id);
      }

      _showPaymentResult(success);
    } catch (e) {
      print('❌ Error en el proceso de pago: $e');
      _showPaymentResult(false);
    }
  }


  void _showPaymentResult(bool success) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
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
          // Botón: Ver mis reservas → index 2
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.main,
                    (route) => false,
                arguments: {
                  'initialIndex': 2,
                },
              );
            },
            child: const Text(
              'Ver mis reservas',
              style: TextStyle(color: Color(0xFFF52525)),
            ),
          ),
          // Botón: Volver al chat → index 1 (solo si viene del chat)
          if (widget.isFromChat)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.main,
                      (route) => false,
                  arguments: {
                    'initialIndex': 1,
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