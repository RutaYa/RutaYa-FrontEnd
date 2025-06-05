import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Set para manejar favoritos
  final Set<String> _favorites = <String>{};

  // Datos de ejemplo de destinos peruanos
  final List<Destination> suggestedDestinations = [
    Destination(
      name: "Machu Picchu",
      location: "Cusco",
      imageUrl: "assets/images/machu_picchu.jpg",
      isPopular: true,
    ),
    Destination(
      name: "Lago Titicaca",
      location: "Puno",
      imageUrl: "assets/images/titicaca.jpg",
      isPopular: true,
    ),
    Destination(
      name: "Sacsayhuamán",
      location: "Cusco",
      imageUrl: "assets/images/sacsayhuaman.jpg",
      isPopular: true,
    ),
    Destination(
      name: "Valle Sagrado",
      location: "Cusco",
      imageUrl: "assets/images/valle_sagrado.jpg",
      isPopular: true,
    ),
  ];

  final List<Destination> popularDestinations = [
    Destination(
      name: "Huacachina",
      location: "Ica",
      imageUrl: "assets/images/huacachina.jpg",
      isPopular: true,
    ),
    Destination(
      name: "Líneas de Nazca",
      location: "Nazca",
      imageUrl: "assets/images/nazca.jpg",
      isPopular: true,
    ),
    Destination(
      name: "Arequipa",
      location: "Arequipa",
      imageUrl: "assets/images/arequipa.jpg",
      isPopular: true,
    ),
    Destination(
      name: "Trujillo",
      location: "La Libertad",
      imageUrl: "assets/images/trujillo.jpg",
      isPopular: true,
    ),
  ];

  final List<Destination> hiddenGems = [
    Destination(
      name: "Laguna 69",
      location: "Áncash",
      imageUrl: "assets/images/laguna69.jpg",
      isHidden: true,
    ),
    Destination(
      name: "Kuelap",
      location: "Amazonas",
      imageUrl: "assets/images/kuelap.jpg",
      isHidden: true,
    ),
    Destination(
      name: "Gocta",
      location: "Amazonas",
      imageUrl: "assets/images/gocta.jpg",
      isHidden: true,
    ),
  ];

  void _toggleFavorite(String destinationName) {
    setState(() {
      if (_favorites.contains(destinationName)) {
        _favorites.remove(destinationName);
      } else {
        _favorites.add(destinationName);
      }
    });
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
        child: SingleChildScrollView(
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
                _buildSectionTitle("Sugerencias para ti:", showViewAll: true),
                const SizedBox(height: 15),
                _buildHorizontalDestinationList(suggestedDestinations),

                const SizedBox(height: 30),

                // Más populares
                _buildSectionTitle("Más populares:", showViewAll: true),
                const SizedBox(height: 15),
                _buildHorizontalDestinationList(popularDestinations),

                const SizedBox(height: 30),

                // Destinos ocultos (especial)
                _buildHiddenGemsSection(),

                const SizedBox(height: 20),
              ],
            ),
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
        if (showViewAll)
          TextButton(
            onPressed: () {
              // Navegar a ver todos
            },
            child: Text(
              'Ver todos',
              style: TextStyle(
                color: const Color(0xFFFD0000),
                fontWeight: FontWeight.w500,
              ),
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
    final isFavorite = _favorites.contains(destination.name);

    return GestureDetector(
      onTap: () {
        // Navegar a detalles del destino
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
              // Imagen de placeholder con gradiente
              Container(
                width: double.infinity,
                height: double.infinity,
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
                  onTap: () => _toggleFavorite(destination.name),
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

              // Badge para destinos ocultos
              if (destination.isHidden)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFD0000),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Oculto',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
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

  Widget _buildHiddenGemsSection() {
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
              TextButton(
                onPressed: () {
                  // Ver todos los destinos ocultos
                },
                child: Text(
                  'Ver todos',
                  style: TextStyle(
                    color: const Color(0xFFFD0000),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 15),

        // Lista horizontal de destinos ocultos
        _buildHorizontalDestinationList(hiddenGems),
      ],
    );
  }
}

// Modelo de datos para destinos
class Destination {
  final String name;
  final String location;
  final String imageUrl;
  final bool isPopular;
  final bool isHidden;

  Destination({
    required this.name,
    required this.location,
    required this.imageUrl,
    this.isPopular = false,
    this.isHidden = false,
  });
}