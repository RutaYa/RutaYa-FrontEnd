import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../domain/entities/destination.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/home_response.dart';
import '../../../application/get_home_data_use_case.dart';
import '../../../application/alter_favorite_use_case.dart';
import '../../../data/repositories/local_storage_service.dart';
import '../../../domain/entities/user.dart';
import 'destination_detail_screen.dart';
import 'destination_search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State createState() => _HomeScreenState();
}

class _HomeScreenState extends State {
  final TextEditingController _searchController = TextEditingController();

  // Variables para almacenar los datos del API
  HomeResponse? homeData;
  bool isLoading = true;
  String? errorMessage;
  final LocalStorageService _storageService = LocalStorageService();
  User? currentUser;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  Future _loadHomeData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final user = await _storageService.getCurrentUser();

    final getHomeDataUseCase = getIt<GetHomeDataUseCase>();

    try {
      final HomeResponse? homeResponse = await getHomeDataUseCase.getHomeData();

      if (homeResponse != null) {
        setState(() {
          currentUser = user;
          homeData = homeResponse;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Error al cargar los datos';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error: $e';
      });
    }
  }

  Future _toggleFavorite(Destination destination) async {
    final alterFavoriteUseCase = getIt<AlterFavoriteUseCase>();

    final success = await alterFavoriteUseCase.alterFavorite(
        destination.id,
        destination.isFavorite
    );

    if (success) {
      setState(() {
        // Actualizar el destino local primero
        destination.isFavorite = !destination.isFavorite;

        // Sincronizar en todas las listas
        _syncFavoriteStatusAcrossAllLists(destination);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al actualizar favorito'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _navigateToDetail(Destination destination, String category) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DestinationDetailScreen(
          destination: destination,
          categoryName: category,
        ),
      ),
    );

    // Actualizar el estado del favorito en TODAS las listas
    setState(() {
      _syncFavoriteStatusAcrossAllLists(destination);
    });
  }

  void _syncFavoriteStatusAcrossAllLists(Destination updatedDestination) {
    if (homeData == null) return;

    // Actualizar en suggestions
    for (Destination dest in homeData!.suggestions) {
      if (dest.id == updatedDestination.id) {
        dest.isFavorite = updatedDestination.isFavorite;
      }
    }

    // Actualizar en popular
    for (Destination dest in homeData!.popular) {
      if (dest.id == updatedDestination.id) {
        dest.isFavorite = updatedDestination.isFavorite;
      }
    }

    // Actualizar en categorías
    for (Category category in homeData!.categories) {
      for (Destination dest in category.destinations) {
        if (dest.id == updatedDestination.id) {
          dest.isFavorite = updatedDestination.isFavorite;
        }
      }
    }
  }

  Future<void> navigateToDestinationSearch() async {
    if (homeData != null) {
      final updatedHomeResponse = await Navigator.push<HomeResponse>(
        context,
        MaterialPageRoute(
          builder: (context) => DestinationSearchScreen(
            homeResponse: homeData!,
          ),
        ),
      );

      // Si regresa un HomeResponse actualizado, actualizar el estado
      if (updatedHomeResponse != null) {
        setState(() {
          homeData = updatedHomeResponse;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
            ? _buildErrorWidget()
            : homeData != null
            ? _buildContent()
            : _buildEmptyWidget(),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
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
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadHomeData,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.travel_explore,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay datos disponibles',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadHomeData,
            child: const Text('Cargar datos'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _loadHomeData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con saludo
              _buildHeader(),

              const SizedBox(height: 20),

              // Barra de búsqueda
              _buildSearchBar(),

              const SizedBox(height: 30),

              // Sugerencias para ti
              if (homeData!.suggestions.isNotEmpty) ...[
                _buildSectionTitle("Sugerencias para ti:", showViewAll: true),
                const SizedBox(height: 15),
                _buildHorizontalDestinationList(homeData!.suggestions, "Sugerencia"),
                const SizedBox(height: 30),
              ],

              // Más populares
              if (homeData!.popular.isNotEmpty) ...[
                _buildSectionTitle("Más populares:", showViewAll: true),
                const SizedBox(height: 15),
                _buildHorizontalDestinationList(homeData!.popular, "Popular"),
                const SizedBox(height: 30),
              ],

              // Categorías
              ...homeData!.categories.map((category) {
                if (category.name == "Destinos Ocultoss") {
                  // Sección especial para destinos ocultos
                  return _buildHiddenGemsSection(category);
                } else {
                  // Secciones normales para otras categorías
                  return _buildCategorySection(category);
                }
              }).toList(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Texto de bienvenida y subtítulo
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hola ${currentUser?.firstName ?? 'Viajero'} ! 👋',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "Descubre los tesoros ocultos del Perú",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),

        // Icono pulsable de calendario
        GestureDetector(
          onTap: () {
            // Aquí va la acción que quieras realizar
            print('Ícono de calendario presionado');
            // Navigator.pushNamed(context, '/calendar'); por ejemplo
          },
          child: Icon(
            Icons.calendar_today,
            color: Color(0xFF303030),
            size: 28,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () {
        navigateToDestinationSearch();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: AbsorbPointer( // Evita que el TextField sea editable
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Buscar destinos en Perú...',
              hintStyle: TextStyle(color: Colors.grey[500]),
              prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {bool showViewAll = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalDestinationList(List<Destination> destinations, String category) {
    return SizedBox(
      height: 200, // Altura fija para las tarjetas
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: destinations.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              right: index == destinations.length - 1 ? 0 : 15,
            ),
            child: SizedBox(
              width: 160, // Ancho fijo para cada tarjeta
              child: _buildDestinationCard(destinations[index], category),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDestinationCard(Destination destination, String category) {
    return GestureDetector(
      onTap: () => _navigateToDetail(destination, category),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Imagen o placeholder
              Container(
                width: double.infinity,
                height: double.infinity,
                child: destination.imageUrl.isNotEmpty
                    ? Image.network(
                  destination.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.grey[300]!,
                            Colors.grey[200]!,
                          ],
                        ),
                      ),
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.grey[400],
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.grey[300]!,
                            Colors.grey[200]!,
                          ],
                        ),
                      ),
                      child: Icon(
                        Icons.landscape,
                        size: 40,
                        color: Colors.grey[400],
                      ),
                    );
                  },
                )
                    : Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.grey[300]!,
                        Colors.grey[200]!,
                      ],
                    ),
                  ),
                  child: Icon(
                    Icons.landscape,
                    size: 40,
                    color: Colors.grey[400],
                  ),
                ),
              ),

              // Overlay con gradiente
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),

              // Botón de favorito
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => _toggleFavorite(destination),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      destination.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: destination.isFavorite ? const Color(0xFFFD0000) : Colors.grey[600],
                      size: 16,
                    ),
                  ),
                ),
              ),

              // Información del destino
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destination.name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 12,
                          color: Colors.white.withOpacity(0.8),
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            destination.location,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.8),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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

  Widget _buildHiddenGemsSection(Category category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título especial para destinos ocultos
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color(0xFFFD0000).withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFFD0000).withOpacity(0.1),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFD0000),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.explore,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Destinos Ocultos 💎',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFD0000),
                      ),
                    ),
                    Text(
                      'Lugares únicos por descubrir',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 15),

        // Lista horizontal de destinos ocultos
        _buildHorizontalDestinationList(category.destinations, category.name),

        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildCategorySection(Category category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(category.name, showViewAll: true),
        const SizedBox(height: 15),
        _buildHorizontalDestinationList(category.destinations, category.name),
        const SizedBox(height: 30),
      ],
    );
  }
}