import 'package:flutter/material.dart';
import '../../../domain/entities/destination_rate.dart';
import '../home/destination_detail_screen.dart';
import '../../../data/repositories/local_storage_service.dart';
import '../../../application/delete_destination_rate_use_case.dart';
import '../../../main.dart';

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
  final localStorageService = LocalStorageService();
  late List<DestinationRate> localDestinationRates;
  bool isDeleteLoading = false;

  @override
  void initState() {
    super.initState();
    localDestinationRates = List.from(widget.destinationRates);
  }

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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DestinationDetailScreen(
          destination: rate.destination,
          categoryName: 'Destino turistico',
          isFromHome: false,
        ),
      ),
    );
  }

  Future<void> _deleteDestinationRate(DestinationRate rate) async {
    setState(() {
      isDeleteLoading = true;
    });

    final deleteDestinationUseCase = getIt<DeleteDestinationRateUseCase>();

    try {
      final bool response = await deleteDestinationUseCase.deleteDestinationRated(rate.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response ? 'Reseña eliminada correctamente' : 'Error al eliminar la reseña'),
          backgroundColor: response ? Colors.green : Colors.red,
        ),
      );

      if (response) {
        setState(() {
          localDestinationRates.removeWhere((item) => item.id == rate.id);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error inesperado al eliminar la reseña'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isDeleteLoading = false;
      });
    }
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
          onPressed: () => Navigator.of(context).pop(localDestinationRates),
        ),
      ),
      body: localDestinationRates.isEmpty
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
        itemCount: localDestinationRates.length,
        itemBuilder: (context, index) {
          final rate = localDestinationRates[index];
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

          // Footer con botones
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FutureBuilder<int?>(
                future: localStorageService.getCurrentUserId(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data == int.tryParse(rate.user.id.toString())) {
                    return TextButton(
                      onPressed: isDeleteLoading ? null : () => _deleteDestinationRate(rate),
                      child: Text(
                        'Eliminar',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDeleteLoading ? Colors.grey : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
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