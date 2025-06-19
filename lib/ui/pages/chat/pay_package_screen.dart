import 'package:flutter/material.dart';
import '../../../domain/entities/tour_package.dart';

enum PaymentMethod { none, card, yape }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pago',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
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
                    'assets/images/visa.png', // Reemplaza con tu asset
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
                    'assets/images/mastercard.png', // Reemplaza con tu asset
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
                    'assets/images/dinersclub.png', // Reemplaza con tu asset
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
                    'assets/images/american.png', // Reemplaza con tu asset
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
                    'assets/images/yape.png', // Reemplaza con tu asset
                    height: 50,
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
                  // Aquí irá la lógica para continuar con el método seleccionado
                  print('Método seleccionado: $_selectedMethod');
                  // TODO: Implementar navegación o cambio de estado
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
}