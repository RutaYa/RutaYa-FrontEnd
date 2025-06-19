import 'package:flutter/material.dart';
import '../../../main.dart';
import '../../../application/get_tour_packages_use_case.dart';
import '../../../domain/entities/tour_package.dart';
import '../../../domain/entities/itinerary_item.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  List<TourPackage> tourPackages = [];
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    print("🚀 ReservationsScreen initState ejecutado");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("📱 PostFrameCallback ejecutado - iniciando carga");
      _loadReservationData();
    });
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
      return '${date.day} de ${months[date.month - 1]}';
    } catch (e) {
      return dateString;
    }
  }

  String _formatDateTime(String dateString) {
    try {
      final DateTime date = DateTime.parse(dateString);
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} hrs';
    } catch (e) {
      return dateString;
    }
  }

  void _deletePendingPackage(TourPackage package) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar Reserva'),
          content: Text('¿Estás seguro de que deseas eliminar "${package.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  tourPackages.remove(package);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reserva eliminada')),
                );
              },
              style: TextButton.styleFrom(foregroundColor: const Color(0xFFF52525)),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  void _payPackage(TourPackage package) {
    // Aquí implementarías la lógica de pago
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Procesar Pago'),
          content: Text('¿Confirmas el pago de S/ ${package.price.toStringAsFixed(2)} para "${package.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                // Simular pago exitoso
                setState(() {
                  final index = tourPackages.indexOf(package);
                  if (index != -1) {
                    tourPackages[index] = TourPackage(
                      userId: package.userId,
                      title: package.title,
                      description: package.description,
                      startDate: package.startDate,
                      days: package.days,
                      quantity: package.quantity,
                      price: package.price,
                      isPaid: true, // Cambiar estado a pagado
                      itinerary: package.itinerary,
                    );
                  }
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pago procesado exitosamente')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF52525)),
              child: const Text('Pagar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Mis Reservaciones',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFF52525),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFF52525)))
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
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF52525)),
              child: const Text('Reintentar', style: TextStyle(color: Colors.white)),
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
        color: const Color(0xFFF52525),
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
                      width: 4,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF52525),
                        borderRadius: BorderRadius.all(Radius.circular(2)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Reservas Confirmadas',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF52525),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${reservedPackages.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
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
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.orange[600],
                        borderRadius: const BorderRadius.all(Radius.circular(2)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Pendientes de Pago',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange[600],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${pendingPackages.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
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
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icono circular
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 12, top: 4),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF52525), Color(0xFFF52525)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 16,
            ),
          ),
          // Contenido principal
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con fecha
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF52525),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDate(package.startDate),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'PAGADO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Contenido principal
                  Container(
                    color: Colors.grey[100],
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          package.title,
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          package.description,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 3,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            gradient: LinearGradient(
                              colors: [Colors.grey[300]!, Colors.grey[400]!],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.access_time, color: Colors.grey[500], size: 16),
                            const SizedBox(width: 4),
                            Text(
                              _formatDateTime(package.startDate),
                              style: TextStyle(color: Colors.grey[600], fontSize: 14),
                            ),
                            const SizedBox(width: 16),
                            Icon(Icons.people, color: Colors.grey[500], size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${package.quantity} ${package.quantity == 1 ? 'Adulto' : 'Adultos'}',
                              style: TextStyle(color: Colors.grey[600], fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'S/ ${package.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // Navegar a detalles del paquete
                                // Navigator.push(context, MaterialPageRoute(builder: (context) => PackageDetails(package: package)));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF52525),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                              child: const Text(
                                'Ver Detalles',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingPackageCard(TourPackage package) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icono circular
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 12, top: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange[600]!, Colors.orange[600]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.schedule,
              color: Colors.white,
              size: 16,
            ),
          ),
          // Contenido principal
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con fecha y botón eliminar
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange[600],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDate(package.startDate),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'PENDIENTE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => _deletePendingPackage(package),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Contenido principal
                  Container(
                    color: Colors.grey[100],
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          package.title,
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          package.description,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 3,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            gradient: LinearGradient(
                              colors: [Colors.orange[300]!, Colors.orange[400]!],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.access_time, color: Colors.grey[500], size: 16),
                            const SizedBox(width: 4),
                            Text(
                              _formatDateTime(package.startDate),
                              style: TextStyle(color: Colors.grey[600], fontSize: 14),
                            ),
                            const SizedBox(width: 16),
                            Icon(Icons.people, color: Colors.grey[500], size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${package.quantity} ${package.quantity == 1 ? 'Adulto' : 'Adultos'}',
                              style: TextStyle(color: Colors.grey[600], fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'S/ ${package.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _payPackage(package),
                              icon: const Icon(Icons.payment, size: 16),
                              label: const Text('Pagar Ahora'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[600],
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}