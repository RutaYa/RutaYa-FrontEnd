import 'package:flutter/material.dart';
import '../../../domain/entities/tour_package.dart';
import '../../../domain/entities/itinerary_item.dart';

class ItineraryDetails extends StatefulWidget {
  final TourPackage package;

  const ItineraryDetails({
    super.key,
    required this.package,
  });

  @override
  State<ItineraryDetails> createState() => _ItineraryDetailsState();
}

class _ItineraryDetailsState extends State<ItineraryDetails> {

  // Función para formatear fecha y hora
  String _formatDateTime(String dateString) {
    print(dateString);
    try {
      final date = DateTime.parse(dateString);

      final days = ['domingo', 'lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado'];
      final dayName = days[date.weekday % 7];
      final capitalizedDay = '${dayName[0].toUpperCase()}${dayName.substring(1)}';

      final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
      final minute = date.minute.toString().padLeft(2, '0');
      final period = date.hour < 12 ? 'a. m.' : 'p. m.';
      final formattedTime = '$hour:$minute $period';

      return '$capitalizedDay ${date.day} - $formattedTime';
    } catch (e) {
      return dateString;
    }
  }


  // Función para obtener icono según el tipo de actividad
  IconData _getActivityIcon(String description) {
    final desc = description.toLowerCase();

    if (desc.contains('hotel') || desc.contains('hospedaje') || desc.contains('alojamiento')) {
      return Icons.hotel;
    } else if (desc.contains('desayuno') || desc.contains('almuerzo') || desc.contains('cena') || desc.contains('comida')) {
      return Icons.restaurant;
    } else if (desc.contains('transporte') || desc.contains('bus') || desc.contains('transfer')) {
      return Icons.directions_bus;
    } else if (desc.contains('visita') || desc.contains('tour') || desc.contains('recorrido')) {
      return Icons.camera_alt;
    } else if (desc.contains('llegada') || desc.contains('salida') || desc.contains('partida')) {
      return Icons.flight;
    } else if (desc.contains('tiempo libre') || desc.contains('descanso')) {
      return Icons.schedule;
    } else {
      return Icons.place;
    }
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
          'Itinerario Detallado',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Header con título del paquete
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.package.title,
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.package.days} ${widget.package.days == 1 ? 'día' : 'días'} • ${widget.package.itinerary.length} actividades',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Lista del itinerario
          Expanded(
            child: widget.package.itinerary.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: widget.package.itinerary.length,
              itemBuilder: (context, index) {
                final item = widget.package.itinerary[index];
                final isLast = index == widget.package.itinerary.length - 1;

                return _buildTimelineItem(
                  item: item,
                  isLast: isLast,
                  index: index,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required ItineraryItem item,
    required bool isLast,
    required int index,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline visual (círculo e línea)
        Column(
          children: [
            // Círculo con icono
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF52525),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF52525).withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                _getActivityIcon(item.description),
                color: Colors.white,
                size: 20,
              ),
            ),
            // Línea conectora (no mostrar en el último item)
            if (!isLast)
              Container(
                width: 2,
                height: 60,
                color: Colors.grey[300],
                margin: const EdgeInsets.symmetric(vertical: 8),
              ),
          ],
        ),
        const SizedBox(width: 16),
        // Contenido de la actividad
        Expanded(
          child: Container(
            margin: EdgeInsets.only(bottom: isLast ? 0 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hora
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _formatDateTime(item.datetime),
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Descripción de la actividad
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey[200]!,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    item.description,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.map_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay itinerario disponible',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'El itinerario detallado se agregará pronto',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}