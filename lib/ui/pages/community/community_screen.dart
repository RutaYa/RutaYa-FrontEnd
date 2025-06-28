import 'package:flutter/material.dart';
import '../../../domain/entities/destination_rate.dart';
import '../../../domain/entities/package_rate.dart';
import '../../../domain/entities/community_response.dart';
import '../../../main.dart';
import '../../../application/get_community_rate_use_case.dart';
import 'all_destinations_rate.dart';
import 'all_package_rate.dart';
import '../home/destination_detail_screen.dart';
import '../chat/package_details.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => CommunityScreenState();
}

class CommunityScreenState extends State<CommunityScreen> {
  List<DestinationRate> destinationRates = [];
  List<PackageRate> packageRates = [];
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCommunityData();
  }

  void refreshIfNeeded() {
    if (mounted) {
      print('🔄 Community tab seleccionada - Refrescando datos');
      _loadCommunityData();
    }
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

  void _navigateToAllDestinations() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllDestinationsRate(
          destinationRates: destinationRates,
        ),
      ),
    );
  }

  void _navigateToAllPackages() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllPackageRate(
          packageRates: packageRates,
        ),
      ),
    );
  }

  void _navigateToDestinationDetail(DestinationRate rate) {
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

  void _navigateToPackageDetail(PackageRate rate) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PackageDetails(
          package: rate.tourPackage,
          isFromChat: false,
        ),
      ),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Reseñas de Destinos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    TextButton(
                      onPressed: _navigateToAllDestinations,
                      child: Text(
                        'Ver todos',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...destinationRates.take(3).map((rate) => _buildDestinationRateCard(rate)),
                const SizedBox(height: 24),
              ],

              // Sección de Calificaciones de Paquetes
              if (packageRates.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Reseñas de Paquetes Turísticos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    TextButton(
                      onPressed: _navigateToAllPackages,
                      child: Text(
                        'Ver todos',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...packageRates.take(3).map((rate) => _buildPackageRateCard(rate)),
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
      padding: const EdgeInsets.all(12),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar circular con inicial
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.blue[100],
            child: Text(
              rate.user.firstName.isNotEmpty
                  ? rate.user.firstName[0].toUpperCase()
                  : 'U',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Contenido principal
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Usuario y calificación
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${rate.user.firstName} ${rate.user.lastName}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < rate.stars ? Icons.star : Icons.star_border,
                          size: 14,
                          color: Colors.amber,
                        );
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Destino
                Text(
                  rate.destination.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                // Comentario resumido
                if (rate.comment.isNotEmpty)
                  Text(
                    rate.comment.length > 60
                        ? '${rate.comment.substring(0, 60)}...'
                        : rate.comment,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 6),
                // Fecha
                Text(
                  _formatDate(rate.createdAt),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Botón Ver
          TextButton(
            onPressed: () => _navigateToDestinationDetail(rate),
            style: TextButton.styleFrom(
              minimumSize: const Size(50, 30),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
            child: Text(
              'Ver',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.redAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageRateCard(PackageRate rate) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar circular con inicial
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.green[100],
            child: Text(
              rate.user.firstName.isNotEmpty
                  ? rate.user.firstName[0].toUpperCase()
                  : 'U',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Contenido principal
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Usuario y calificación
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${rate.user.firstName} ${rate.user.lastName}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < rate.stars ? Icons.star : Icons.star_border,
                          size: 14,
                          color: Colors.amber,
                        );
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Título del paquete
                Text(
                  rate.tourPackage.title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Días y precio
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 10, color: Colors.grey[500]),
                    const SizedBox(width: 2),
                    Text(
                      '${rate.tourPackage.days}d',
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.attach_money, size: 10, color: Colors.grey[500]),
                    Text(
                      'S/ ${rate.tourPackage.price.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Comentario resumido
                if (rate.comment.isNotEmpty)
                  Text(
                    rate.comment.length > 60
                        ? '${rate.comment.substring(0, 60)}...'
                        : rate.comment,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 6),
                // Fecha
                Text(
                  _formatDate(rate.createdAt),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Botón Ver
          TextButton(
            onPressed: () => _navigateToPackageDetail(rate),
            style: TextButton.styleFrom(
              minimumSize: const Size(50, 30),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
            child: Text(
              'Ver',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.redAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}