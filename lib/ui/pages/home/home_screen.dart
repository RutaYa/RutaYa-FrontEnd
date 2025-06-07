import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Set para manejar favoritos
  final Set<int> _favorites = <int>{};

  // Variables para almacenar los datos del API
  List<Destination> suggestions = [];
  List<Destination> popular = [];
  List<Category> categories = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/v1/home/2/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        setState(() {
          // Cargar sugerencias
          suggestions = (jsonData['suggestions'] as List)
              .map((item) => Destination.fromJson(item))
              .toList();

          // Cargar populares
          popular = (jsonData['popular'] as List)
              .map((item) => Destination.fromJson(item))
              .toList();

          // Cargar categorías
          categories = (jsonData['categories'] as List)
              .map((item) => Category.fromJson(item))
              .toList();

          // Cargar favoritos iniciales
          _loadInitialFavorites();

          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Error al cargar los datos: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error de conexión: $e';
        isLoading = false;
      });
    }
  }

  void _loadInitialFavorites() {
    // Cargar favoritos de sugerencias
    for (var destination in suggestions) {
      if (destination.isFavorite) {
        _favorites.add(destination.id);
      }
    }

    // Cargar favoritos de populares
    for (var destination in popular) {
      if (destination.isFavorite) {
        _favorites.add(destination.id);
      }
    }

    // Cargar favoritos de categorías
    for (var category in categories) {
      for (var destination in category.destinations) {
        if (destination.isFavorite) {
          _favorites.add(destination.id);
        }
      }
    }
  }

  void _toggleFavorite(int destinationId) {
    setState(() {
      if (_favorites.contains(destinationId)) {
        _favorites.remove(destinationId);
      } else {
        _favorites.add(destinationId);
      }
    });

    // Aquí podrías hacer una llamada al API para actualizar el favorito
    // _updateFavoriteOnServer(destinationId, _favorites.contains(destinationId));
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
            : _buildContent(),
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
              if (suggestions.isNotEmpty) ...[
                _buildSectionTitle("Sugerencias para ti:", showViewAll: true),
                const SizedBox(height: 15),
                _buildHorizontalDestinationList(suggestions),
                const SizedBox(height: 30),
              ],

              // Más populares
              if (popular.isNotEmpty) ...[
                _buildSectionTitle("Más populares:", showViewAll: true),
                const SizedBox(height: 15),
                _buildHorizontalDestinationList(popular),
                const SizedBox(height: 30),
              ],

              // Categorías
              ...categories.map((category) {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "¡Hola, Viajero! 👋",
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
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar destinos en Perú...',
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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

  Widget _buildHorizontalDestinationList(List<Destination> destinations) {
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
              child: _buildDestinationCard(destinations[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDestinationCard(Destination destination) {
    final isFavorite = _favorites.contains(destination.id);

    return GestureDetector(
      onTap: () {
        // Navegar a detalles del destino
        print('Navegando a ${destination.name}');
      },
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
                  onTap: () => _toggleFavorite(destination.id),
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
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? const Color(0xFFFD0000) : Colors.grey[600],
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
        _buildHorizontalDestinationList(category.destinations),

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
        _buildHorizontalDestinationList(category.destinations),
        const SizedBox(height: 30),
      ],
    );
  }
}

// Modelos de datos actualizados para el API
class Destination {
  final int id;
  final String name;
  final String location;
  final String description;
  final String imageUrl;
  final bool isFavorite;
  final int? favoritesCount;

  Destination({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.imageUrl,
    this.isFavorite = false,
    this.favoritesCount,
  });

  factory Destination.fromJson(Map<String, dynamic> json) {
    return Destination(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      description: json['description'],
      imageUrl: json['image_url'] ?? '',
      isFavorite: json['isFavorite'] ?? false,
      favoritesCount: json['favorites_count'],
    );
  }
}

class Category {
  final int id;
  final String name;
  final List<Destination> destinations;

  Category({
    required this.id,
    required this.name,
    required this.destinations,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      destinations: (json['destinations'] as List)
          .map((item) => Destination.fromJson(item))
          .toList(),
    );
  }
}