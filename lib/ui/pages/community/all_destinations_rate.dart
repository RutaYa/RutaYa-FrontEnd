import 'package:flutter/material.dart';
import '../../../domain/entities/destination_rate.dart';

class AllDestinationsRate extends StatefulWidget {
  final List<DestinationRate> destinationRates;

  const AllDestinationsRate({
    super.key,
    required this.destinationRates,
  });

  @override
  State<AllDestinationsRate> createState() => _AllDestinationsRateState();
}

class _AllDestinationsRateState extends State<AllDestinationsRate> {
  String _formatDate(String dateString) {
    try {
      final DateTime date = DateTime.parse(dateString);
      final List<String> months = [
        'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
        'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
      ];
      return '${date.day} de ${months[date.month - 1]} de ${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  void _showDestinationDetails(DestinationRate rate) {

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Reseñas de Destinos',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: widget.destinationRates.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay reseñas de destinos',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sé el primero en compartir tu experiencia',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.destinationRates.length,
        itemBuilder: (context, index) {
          final rate = widget.destinationRates[index];
          return _buildDestinationRateCard(rate);
        },
      ),
    );
  }

  Widget _buildDestinationRateCard(DestinationRate rate) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con usuario y calificación
          Row(
            children: [
              // Avatar circular con inicial
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blue[100],
                child: Text(
                  rate.user.firstName.isNotEmpty
                      ? rate.user.firstName[0].toUpperCase()
                      : 'U',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${rate.user.firstName} ${rate.user.lastName}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      _formatDate(rate.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Calificación con estrellas
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rate.stars ? Icons.star : Icons.star_border,
                    size: 16,
                    color: Colors.amber,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Información del destino
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: Colors.blue[600],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rate.destination.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        rate.destination.location,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Comentario completo
          if (rate.comment.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              rate.comment,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ],

          // Footer con botón de detalle
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => _showDestinationDetails(rate),
                child: Text(
                  'Ver destino',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}