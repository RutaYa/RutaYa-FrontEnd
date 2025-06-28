import 'package:flutter/material.dart';
import '../../../main.dart';
import '../../../application/get_tour_packages_use_case.dart';
import '../../../application/delete_tour_package_use_case.dart';
import '../../../domain/entities/tour_package.dart';
import '../../../domain/entities/itinerary_item.dart';
import '../chat/package_details.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});

  @override
  State<ReservationsScreen> createState() => ReservationsScreenState();
}

class ReservationsScreenState extends State<ReservationsScreen> {
  List<TourPackage> tourPackages = [];
  bool isLoading = false;
  String? errorMessage;
  bool _isDeletePackageLoading = false;

  @override
  void initState() {
    super.initState();
    print("🚀 ReservationsScreen initState ejecutado");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("📱 PostFrameCallback ejecutado - iniciando carga");
      _loadReservationData();
    });
  }

  void refreshIfNeeded() {
    if (mounted) {
      print('🔄 Community tab seleccionada - Refrescando datos');
      _loadReservationData();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print("🔄 didChangeDependencies ejecutado");
  }

  Future<void> _loadReservationData() async {
    print("🔍 _loadReservationData iniciado");

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      print("🏭 Obteniendo GetTourPackagesUseCase del getIt");
      final getTourPackagesUseCase = getIt<GetTourPackagesUseCase>();

      print("📡 Llamando a getTourPackages()");
      final List<TourPackage>? packageResponse = await getTourPackagesUseCase.getTourPackages();

      print("📦 Respuesta recibida: ${packageResponse?.length ?? 0} paquetes");

      if (packageResponse != null) {
        setState(() {
          tourPackages = packageResponse;
          isLoading = false;
        });
        print("✅ Datos cargados exitosamente: ${tourPackages.length} paquetes");
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Error al cargar los datos';
        });
        print("❌ Respuesta nula del backend");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error: $e';
      });
      print("💥 Error en _loadReservationData: $e");
    }
  }

  // Filtrar paquetes reservados (pagados)
  List<TourPackage> get reservedPackages => tourPackages.where((package) => package.isPaid).toList();

  // Filtrar paquetes pendientes (no pagados)
  List<TourPackage> get pendingPackages => tourPackages.where((package) => !package.isPaid).toList();

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

  String _formatDateTime(String dateString) {
    try {
      final DateTime date = DateTime.parse(dateString);
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  void _deletePendingPackage(TourPackage package) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Eliminar Reserva'),
              content: Text('¿Estás seguro de que deseas eliminar "${package.title}"?'),
              actions: [
                TextButton(
                  onPressed: _isDeletePackageLoading ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: _isDeletePackageLoading
                      ? null
                      : () => _confirmAndDeletePackage(package, setStateDialog),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFDC2626),
                  ),
                  child: _isDeletePackageLoading
                      ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDC2626)),
                    ),
                  )
                      : const Text('Eliminar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmAndDeletePackage(TourPackage package, void Function(void Function()) setStateDialog) async {
    setStateDialog(() => _isDeletePackageLoading = true);

    try {
      final deleteTourPackageUseCase = getIt<DeleteTourPackageUseCase>();
      final success = await deleteTourPackageUseCase.deleteTourPackage(package.id);

      if (success) {
        if (mounted) {
          Navigator.of(context).pop(); // Cierra el diálogo
          setState(() {
            tourPackages.remove(package);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reserva eliminada')),
          );
        }
      } else {
        _showErrorSnackBar('No se pudo eliminar la reserva.');
        setStateDialog(() => _isDeletePackageLoading = false);
      }
    } catch (e) {
      print('❌ Error al eliminar la reserva: $e');
      _showErrorSnackBar('Error al eliminar la reserva.');
      setStateDialog(() => _isDeletePackageLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Mis Reservaciones',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 25,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey[200],
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.grey))
          : errorMessage != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadReservationData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626), // Botón rojo elegante
                foregroundColor: Colors.white,
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      )
          : tourPackages.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.travel_explore, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No tienes reservaciones',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Explora nuestros tours y crea tu primera reserva',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      )
          : RefreshIndicator(
        color: const Color(0xFFDC2626), // Indicador de refresh rojo
        onRefresh: _loadReservationData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sección de Reservas Confirmadas
              if (reservedPackages.isNotEmpty) ...[
                Row(
                  children: [
                    Container(
                      width: 3,
                      height: 20,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC2626), // Rojo elegante
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Reservas Confirmadas',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...reservedPackages.map((package) => _buildReservedPackageCard(package)),
                const SizedBox(height: 32),
              ],

              // Sección de Reservas Pendientes
              if (pendingPackages.isNotEmpty) ...[
                Row(
                  children: [
                    Container(
                      width: 3,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.amber[700],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Pendientes de Pago',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...pendingPackages.map((package) => _buildPendingPackageCard(package)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReservedPackageCard(TourPackage package) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con título y estado
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    package.title,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                )
              ],
            ),
          ),

          // Descripción
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              package.description,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Información de la reserva
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[500]),
                const SizedBox(width: 6),
                Text(
                  _formatDate(package.startDate),
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: Colors.grey[500]),
                const SizedBox(width: 6),
                Text(
                  _formatDateTime(package.startDate),
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
                const SizedBox(width: 16),
                Icon(Icons.people, size: 16, color: Colors.grey[500]),
                const SizedBox(width: 6),
                Text(
                  '${package.quantity} ${package.quantity == 1 ? 'Adulto' : 'Adultos'}',
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Separador
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: Colors.grey[200],
          ),

          // Footer con precio y botón
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'S/ ${package.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C2C2C), // Precio en rojo elegante
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PackageDetails(package: package, isFromChat: false)
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF52525),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: const Text(
                    'Ver Detalles',
                    style: TextStyle(
                      color: Color(0xFFFFFFFF), // Texto rojo
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingPackageCard(TourPackage package) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con título, estado y eliminar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    package.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.amber[200]!),
                  ),
                  child: Text(
                    'PENDIENTE',
                    style: TextStyle(
                      color: Colors.amber[700],
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _deletePendingPackage(package),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Descripción
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              package.description,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Información de la reserva
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[500]),
                const SizedBox(width: 6),
                Text(
                  _formatDate(package.startDate),
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: Colors.grey[500]),
                const SizedBox(width: 6),
                Text(
                  _formatDateTime(package.startDate),
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
                const SizedBox(width: 16),
                Icon(Icons.people, size: 16, color: Colors.grey[500]),
                const SizedBox(width: 6),
                Text(
                  '${package.quantity} ${package.quantity == 1 ? 'Adulto' : 'Adultos'}',
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Separador
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: Colors.grey[200],
          ),

          // Footer con precio y botón
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'S/ ${package.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C2C2C), // Precio en rojo elegante
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PackageDetails(package: package, isFromChat: false)
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF52525),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: const Text(
                    'Ver Detalles',
                    style: TextStyle(
                      color: Color(0xFFFFFFFF), // Texto rojo
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}