import 'package:flutter/material.dart';
import '../../../domain/entities/destination.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/home_response.dart';
import 'destination_detail_screen.dart';
import '../../../application/alter_favorite_use_case.dart';
import '../../../main.dart';

class DestinationSearchScreen extends StatefulWidget {
  final HomeResponse homeResponse;

  const DestinationSearchScreen({
    super.key,
    required this.homeResponse,
  });

  @override
  State<DestinationSearchScreen> createState() => _DestinationSearchScreenState();
}

class _DestinationSearchScreenState extends State<DestinationSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Destination> _filteredDestinations = [];
  List<Destination> _allDestinations = [];

  @override
  void initState() {
    super.initState();
    _extractAllDestinations();
    _filteredDestinations = _allDestinations;
    _searchController.addListener(_filterDestinations);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Actualizar favorito en TODAS las listas del HomeResponse
  Future _updateFavoriteStatus(Destination destination) async{
    final alterFavoriteUseCase = getIt<AlterFavoriteUseCase>();

    final success = await alterFavoriteUseCase.alterFavorite(
        destination.id,
        destination.isFavorite
    );
    if (success) {
      setState(() {
        // Actualizar en la lista filtrada
        destination.isFavorite = !destination.isFavorite;

        // Actualizar en suggestions
        for (Destination dest in widget.homeResponse.suggestions) {
          if (dest.id == destination.id) {
            dest.isFavorite = destination.isFavorite;
          }
        }

        // Actualizar en popular
        for (Destination dest in widget.homeResponse.popular) {
          if (dest.id == destination.id) {
            dest.isFavorite = destination.isFavorite;
          }
        }

        // Actualizar en categorías
        for (Category category in widget.homeResponse.categories) {
          for (Destination dest in category.destinations) {
            if (dest.id == destination.id) {
              dest.isFavorite = destination.isFavorite;
            }
          }
        }
      });
    }else{
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al actualizar favorito'),
          backgroundColor: Colors.red,
        ),
      );
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
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Regresar el HomeResponse actualizado
            Navigator.pop(context, widget.homeResponse);
          },
        ),
        title: const Text(
          'Buscar Destinos',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildSearchBar(),
          ),

          // Results
          Expanded(
            child: _filteredDestinations.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredDestinations.length,
              itemBuilder: (context, index) {
                return _buildDestinationItem(_filteredDestinations[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar destinos en Perú...',
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: 16,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey[500],
            size: 24,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon: Icon(
              Icons.clear,
              color: Colors.grey[500],
            ),
            onPressed: () {
              _searchController.clear();
            },
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildDestinationItem(Destination destination) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            destination.imageUrl,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.location_on,
                  color: Colors.grey[400],
                  size: 24,
                ),
              );
            },
          ),
        ),
        title: Text(
          destination.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              destination.location,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            if (destination.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                destination.description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            destination.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: destination.isFavorite ? Colors.red : Colors.grey[400],
            size: 24,
          ),
          onPressed: () => _updateFavoriteStatus(destination),
        ),
        onTap: () async {
          // Navegar al detalle y esperar resultado
          await _navigateToDetail(destination);
        },
      ),
    );
  }

  // Navegar al detalle y manejar actualizaciones
  Future<void> _navigateToDetail(Destination destination) async {
    final categoryName = _findCategoryForDestination(destination);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DestinationDetailScreen(
          destination: destination,
          categoryName: categoryName,
          isFromHome: true,
        ),
      ),
    );

    // Actualizar después de regresar del detalle
    setState(() {
      // Sincronizar el estado del favorito en TODAS las listas del HomeResponse
      _syncFavoriteStatusAcrossAllLists(destination);

      // Luego re-extraer y filtrar
      _extractAllDestinations();
      _filterDestinations();
    });
  }

  // Método para sincronizar el estado de favorito en todas las listas del HomeResponse
  void _syncFavoriteStatusAcrossAllLists(Destination updatedDestination) {
    // Actualizar en suggestions
    for (Destination dest in widget.homeResponse.suggestions) {
      if (dest.id == updatedDestination.id) {
        dest.isFavorite = updatedDestination.isFavorite;
      }
    }

    // Actualizar en popular
    for (Destination dest in widget.homeResponse.popular) {
      if (dest.id == updatedDestination.id) {
        dest.isFavorite = updatedDestination.isFavorite;
      }
    }

    // Actualizar en categorías
    for (Category category in widget.homeResponse.categories) {
      for (Destination dest in category.destinations) {
        if (dest.id == updatedDestination.id) {
          dest.isFavorite = updatedDestination.isFavorite;
        }
      }
    }
  }

  // Extraer todos los destinos del HomeResponse sin duplicados
  void _extractAllDestinations() {
    _allDestinations.clear();
    Set<int> addedIds = <int>{};

    // Agregar sugerencias
    for (Destination destination in widget.homeResponse.suggestions) {
      if (!addedIds.contains(destination.id)) {
        _allDestinations.add(destination);
        addedIds.add(destination.id);
      }
    }

    // Agregar populares
    for (Destination destination in widget.homeResponse.popular) {
      if (!addedIds.contains(destination.id)) {
        _allDestinations.add(destination);
        addedIds.add(destination.id);
      }
    }

    // Agregar destinos de categorías
    for (Category category in widget.homeResponse.categories) {
      for (Destination destination in category.destinations) {
        if (!addedIds.contains(destination.id)) {
          _allDestinations.add(destination);
          addedIds.add(destination.id);
        }
      }
    }
  }

  void _filterDestinations() {
    setState(() {
      if (_searchController.text.isEmpty) {
        _filteredDestinations = _allDestinations;
      } else {
        _filteredDestinations = _allDestinations
            .where((destination) =>
        destination.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            destination.location.toLowerCase().contains(_searchController.text.toLowerCase()))
            .toList();
      }
    });
  }

  // Encontrar la categoría de un destino
  String _findCategoryForDestination(Destination destination) {
    for (Category category in widget.homeResponse.categories) {
      if (category.destinations.any((dest) => dest.id == destination.id)) {
        return category.name;
      }
    }
    return 'Destino';
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No se encontraron destinos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Intenta con otro término de búsqueda',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}