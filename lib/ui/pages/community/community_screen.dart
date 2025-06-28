import 'package:flutter/material.dart';
import '../../../domain/entities/destination_rate.dart';
import '../../../domain/entities/package_rate.dart';
import '../../../domain/entities/community_response.dart';
import '../../../main.dart';
import '../../../application/get_community_rate_use_case.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  List<DestinationRate> destinationRates = [];
  List<PackageRate> packageRates = [];
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCommunityData();
  }

  Future<void> _loadCommunityData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final getCommunityRateUseCase = getIt<GetCommunityRateUseCase>();

    try {
      final CommunityResponse? communityResponse = await getCommunityRateUseCase.getCommunityRate();

      if (communityResponse != null) {
        setState(() {
          destinationRates = communityResponse.destinationRates;
          packageRates = communityResponse.packageRates;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Error al cargar los datos de la comunidad';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error: $e';
      });
    }
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(rate.destination.name),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Información del usuario
                Row(
                  children: [
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
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _formatDate(rate.createdAt),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Calificación
                Row(
                  children: [
                    const Text('Calificación: ', style: TextStyle(fontWeight: FontWeight.w600)),
                    ...List.generate(5, (index) {
                      return Icon(
                        index < rate.stars ? Icons.star : Icons.star_border,
                        size: 20,
                        color: Colors.amber,
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 16),

                // Comentario completo
                if (rate.comment.isNotEmpty) ...[
                  const Text('Comentario:', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(
                    rate.comment,
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  void _showPackageDetails(PackageRate rate) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(rate.tourPackage.title),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Información del usuario
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.green[100],
                      child: Text(
                        rate.user.firstName.isNotEmpty
                            ? rate.user.firstName[0].toUpperCase()
                            : 'U',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
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
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _formatDate(rate.createdAt),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Información del paquete
                Text(
                  rate.tourPackage.description,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text('${rate.tourPackage.days} días'),
                    const SizedBox(width: 16),
                    Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
                    Text(
                      'S/ ${rate.tourPackage.price.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Calificación
                Row(
                  children: [
                    const Text('Calificación: ', style: TextStyle(fontWeight: FontWeight.w600)),
                    ...List.generate(5, (index) {
                      return Icon(
                        index < rate.stars ? Icons.star : Icons.star_border,
                        size: 20,
                        color: Colors.amber,
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 16),

                // Comentario completo
                if (rate.comment.isNotEmpty) ...[
                  const Text('Comentario:', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(
                    rate.comment,
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Comunidad',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCommunityData,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadCommunityData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sección de Calificaciones de Destinos
              if (destinationRates.isNotEmpty) ...[
                const Text(
                  'Reseñas de Destinos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                ...destinationRates.map((rate) => _buildDestinationRateCard(rate)),
                const SizedBox(height: 24),
              ],

              // Sección de Calificaciones de Paquetes
              if (packageRates.isNotEmpty) ...[
                const Text(
                  'Reseñas de Paquetes Turísticos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                ...packageRates.map((rate) => _buildPackageRateCard(rate)),
              ],

              // Mensaje cuando no hay reseñas
              if (destinationRates.isEmpty && packageRates.isEmpty)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 100),
                      Icon(
                        Icons.rate_review_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay reseñas disponibles',
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
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDestinationRateCard(DestinationRate rate) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                      rate.destination.name,
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

          // Comentario con vista previa y botón "Ver más"
          if (rate.comment.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              rate.comment.length > 100
                  ? '${rate.comment.substring(0, 100)}...'
                  : rate.comment,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
            if (rate.comment.length > 100) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _showDestinationDetails(rate),
                child: Text(
                  'Ver más',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],

          // Fecha formateada y botón de detalle
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDate(rate.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
              if (rate.comment.length <= 100)
                GestureDetector(
                  onTap: () => _showDestinationDetails(rate),
                  child: Text(
                    'Ver detalle',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[600],
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

  Widget _buildPackageRateCard(PackageRate rate) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                backgroundColor: Colors.green[100],
                child: Text(
                  rate.user.firstName.isNotEmpty
                      ? rate.user.firstName[0].toUpperCase()
                      : 'U',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
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
                      'Paquete Turístico',
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

          // Información del paquete
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rate.tourPackage.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${rate.tourPackage.days} días',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.attach_money,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    Text(
                      'S/ ${rate.tourPackage.price.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Comentario con vista previa y botón "Ver más"
          if (rate.comment.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              rate.comment.length > 100
                  ? '${rate.comment.substring(0, 100)}...'
                  : rate.comment,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
            if (rate.comment.length > 100) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _showPackageDetails(rate),
                child: Text(
                  'Ver más',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],

          // Fecha formateada y botón de detalle
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDate(rate.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
              if (rate.comment.length <= 100)
                GestureDetector(
                  onTap: () => _showPackageDetails(rate),
                  child: Text(
                    'Ver detalle',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[600],
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