import 'package:flutter/material.dart';
import '../../../domain/entities/tour_package.dart';
import '../../../application/save_tour_package_use_case.dart';
import '../../../main.dart';
import 'itinerary_details.dart';
import 'pay_package_screen.dart';

class PackageDetails extends StatefulWidget {
  final TourPackage package;
  final bool isFromChat;

  const PackageDetails({
    super.key,
    required this.package,
    required this.isFromChat,
  });

  @override
  State<PackageDetails> createState() => _PackageDetailsState();
}

class _PackageDetailsState extends State<PackageDetails> {
  bool _isLoading = false;

  // Función para formatear la fecha
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final days = ['domingo', 'lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado'];
      final months = ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
        'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'];

      return '${days[date.weekday % 7]}, ${date.day} de ${months[date.month - 1]} de ${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  // Función para formatear fecha y hora
  String _formatDateTime(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final months = [
        'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
        'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
      ];

      // Formatear hora en 12h con sufijo a. m. / p. m.
      final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
      final minute = date.minute.toString().padLeft(2, '0');
      final period = date.hour < 12 ? 'a. m.' : 'p. m.';

      final formattedTime = '$hour:$minute $period';

      return '${date.day} de ${months[date.month - 1]} de ${date.year} • $formattedTime';
    } catch (e) {
      return dateString;
    }
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Paquete guardado. Puedes verlo en la sección de "Reservas"',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFFF52525),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Future<void> _saveTourPackage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final saveTourPackageUseCase = getIt<SaveTourPackageUseCase>();
      final success = await saveTourPackageUseCase.saveTourPackage(widget.package);

      setState(() {
        _isLoading = false;
      });

      if (success) {
        _showSuccessMessage();
      } else {
        _showErrorMessage('No se pudo guardar el paquete. Intenta nuevamente.');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorMessage('Error al guardar el paquete: ${e.toString()}');
    }
  }

  void _navigateToItinerary() {
    // Navegar a la pantalla del itinerario
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ItineraryDetails(package: widget.package)
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detalles del Paquete',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarjeta principal con los detalles
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con fecha
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(widget.package.startDate),
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Contenido principal
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título
                        Text(
                          widget.package.title,
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Descripción
                        Text(
                          widget.package.description,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Información detallada
                        _buildInfoRow(
                          Icons.access_time,
                          'Fecha y hora',
                          _formatDateTime(widget.package.startDate),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          Icons.event,
                          'Duración',
                          '${widget.package.days} ${widget.package.days == 1 ? 'día' : 'días'}',
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          Icons.people,
                          'Participantes',
                          '${widget.package.quantity} ${widget.package.quantity == 1 ? 'persona' : 'personas'}',
                        ),
                        const SizedBox(height: 24),
                        // Botón Ver Itinerario - Posición estratégica después de la descripción
                        Container(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: _navigateToItinerary,
                            icon: Icon(
                              Icons.map_outlined,
                              color: const Color(0xFFF52525),
                              size: 20,
                            ),
                            label: const Text(
                              'Ver Itinerario',
                              style: TextStyle(
                                color: Color(0xFFF52525),
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Color(0xFFF52525),
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Precio destacado
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Precio total',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${widget.package.price.toStringAsFixed(2)} PEN',
                                style: TextStyle(
                                  color: Colors.grey[800],
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Botones de acción
            widget.package.isPaid
                ? const SizedBox.shrink() // No mostrar nada si ya está pagado
                : Column(
              children: [
                // Botón de pagar ahora
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PayPackageScreen(package: widget.package),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF52525),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Pagar Ahora',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Botón de guardar para después
                widget.isFromChat
                    ? SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveTourPackage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.grey[600]!,
                        ),
                      ),
                    )
                        : Text(
                      'Guardar para Después',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                    : const SizedBox.shrink(), // Si no se debe mostrar, renderiza un widget vacío

              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.grey[500],
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}