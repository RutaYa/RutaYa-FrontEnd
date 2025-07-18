import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
// Importa tus use cases y GetIt
import '../../../core/routes/app_routes.dart';
import '../../../application/get_travel_dates_use_case.dart';
import '../../../application/save_travel_dates_use_case.dart';
import '../../../main.dart'; // Tu archivo de GetIt

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // Separar fechas originales de fechas actuales
  final Set<DateTime> _originalDates = {}; // Fechas cargadas del backend
  final Set<DateTime> _selectedDates = {}; // Fechas actuales (incluye modificaciones)

  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  bool _isRangeMode = false;
  bool _isLoading = false;
  bool _isInitialLoading = true;
  DateTime _focusedDay = DateTime.now();
  String? _errorMessage;

  // Computed property para saber si hay cambios
  bool get _hasChanges {
    return !_selectedDates.difference(_originalDates).isEmpty ||
        !_originalDates.difference(_selectedDates).isEmpty;
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_ES', null);
    _loadTravelDates();
  }

  // Función para cargar las fechas desde el backend
  Future<void> _loadTravelDates() async {
    final getTravelDatesUseCase = getIt<GetTravelDatesUseCase>();

    try {
      setState(() {
        _isInitialLoading = true;
        _errorMessage = null;
      });

      final List<String> dateStrings = await getTravelDatesUseCase.getTravelDates();

      // Debug: Imprime las fechas recibidas del backend
      print('Fechas recibidas del backend: $dateStrings');

      if (dateStrings.isNotEmpty) {
        // Convertir las fechas string a DateTime normalizadas
        final Set<DateTime> loadedDates = {};
        for (String dateString in dateStrings) {
          try {
            final DateTime date = DateTime.parse(dateString);
            // IMPORTANTE: Normalizar la fecha eliminando la información de hora
            final DateTime normalizedDate = DateTime(date.year, date.month, date.day);
            loadedDates.add(normalizedDate);

            // Debug: Imprime cada fecha normalizada
            print('Fecha normalizada: $normalizedDate');
          } catch (e) {
            print('Error parsing date: $dateString - Error: $e');
          }
        }

        // Debug: Imprime el conjunto final de fechas
        print('Fechas cargadas finales: $loadedDates');

        setState(() {
          // Actualizar tanto las fechas originales como las seleccionadas
          _originalDates.clear();
          _originalDates.addAll(loadedDates);
          _selectedDates.clear();
          _selectedDates.addAll(loadedDates);
          _isInitialLoading = false;
        });

        // Debug: Verificar el estado después del setState
        print('Estado después de setState - _selectedDates: $_selectedDates');

      } else {
        setState(() {
          _originalDates.clear();
          _selectedDates.clear();
          _isInitialLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isInitialLoading = false;
        _errorMessage = 'Error al cargar las fechas guardadas';
      });
      _showSnackBar('Error al cargar las fechas guardadas', isError: true);
      print('Error loading travel dates: $e');
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    // Normalizar la fecha seleccionada
    final DateTime normalizedSelectedDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);

    setState(() {
      _focusedDay = focusedDay;

      if (_isRangeMode) {
        // Modo de selección por rango
        if (_rangeStart == null) {
          _rangeStart = normalizedSelectedDay;
          _rangeEnd = null;
        } else if (_rangeEnd == null && normalizedSelectedDay.isAfter(_rangeStart!)) {
          _rangeEnd = normalizedSelectedDay;
          _addRangeToSelection();
        } else {
          _rangeStart = normalizedSelectedDay;
          _rangeEnd = null;
        }
      } else {
        // Modo de selección individual
        if (_selectedDates.contains(normalizedSelectedDay)) {
          _selectedDates.remove(normalizedSelectedDay);
        } else {
          _selectedDates.add(normalizedSelectedDay);
        }
      }
    });

    // Debug: Verificar las fechas después de la selección
    print('Fecha seleccionada normalizada: $normalizedSelectedDay');
    print('¿Está en _selectedDates? ${_selectedDates.contains(normalizedSelectedDay)}');
    print('_selectedDates actuales: $_selectedDates');
  }

  void _addRangeToSelection() {
    if (_rangeStart != null && _rangeEnd != null) {
      DateTime current = _rangeStart!;
      while (current.isBefore(_rangeEnd!) || current.isAtSameMomentAs(_rangeEnd!)) {
        // Asegurar que las fechas del rango estén normalizadas
        final DateTime normalizedCurrent = DateTime(current.year, current.month, current.day);
        _selectedDates.add(normalizedCurrent);
        current = current.add(const Duration(days: 1));
      }
      _rangeStart = null;
      _rangeEnd = null;
    }
  }

  void _toggleSelectionMode() {
    setState(() {
      _isRangeMode = !_isRangeMode;
      _rangeStart = null;
      _rangeEnd = null;
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedDates.clear();
      _rangeStart = null;
      _rangeEnd = null;
    });
  }

  // Función para resetear a las fechas originales
  void _resetToOriginal() {
    setState(() {
      _selectedDates.clear();
      _selectedDates.addAll(_originalDates);
      _rangeStart = null;
      _rangeEnd = null;
    });
  }

  Future<void> _saveChanges() async {
    if (_selectedDates.isEmpty) {
      _showSnackBar('Selecciona al menos una fecha para guardar', isError: true);
      return;
    }

    final saveTravelDatesUseCase = getIt<SaveTravelDatesUseCase>();

    setState(() {
      _isLoading = true;
    });

    try {
      final List<String> dateStrings = _selectedDates
          .map((date) => date.toIso8601String().split('T')[0])
          .toList();

      dateStrings.sort();

      final bool success = await saveTravelDatesUseCase.saveTravelDates(dateStrings);

      setState(() {
        _isLoading = false;
      });

      if (success) {
        setState(() {
          // Actualizar las fechas originales con las que se acabaron de guardar
          _originalDates.clear();
          _originalDates.addAll(_selectedDates);
        });
        _showSnackBar('Fechas guardadas exitosamente', isError: false);
      } else {
        _showSnackBar('Error al guardar las fechas', isError: true);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Error al guardar las fechas', isError: true);
      print('Error saving travel dates: $e');
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<bool> _showExitDialog() async {
    if (!_hasChanges) return true;

    return await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            SizedBox(width: 8),
            Text('¿Guardar cambios?'),
          ],
        ),
        content: const Text(
          'Tienes cambios sin guardar. ¿Deseas guardar tus fechas de viaje antes de salir?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.main, // Reemplázalo por la ruta deseada
                    (route) => false, // Elimina todas las rutas anteriores
              );
            },
            child: const Text(
              'Salir sin guardar',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop(false);
              await _saveChanges();
              if (!_hasChanges && mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.main,
                      (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE40101),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    ) ?? false;
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
            _errorMessage ?? 'Error al cargar los datos',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadTravelDates,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE40101),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget para el skeleton del calendario
  Widget _buildCalendarSkeleton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header skeleton
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Bone.circle(size: 24),
                Bone.text(width: 120),
                Bone.circle(size: 24),
              ],
            ),
            const SizedBox(height: 16),
            // Days of week skeleton
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(7, (index) =>
                  Bone.text(width: 20)
              ),
            ),
            const SizedBox(height: 16),
            // Calendar grid skeleton
            Column(
              children: List.generate(6, (weekIndex) =>
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(7, (dayIndex) =>
                          Bone.circle(size: 32)
                      ),
                    ),
                  )
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para el skeleton de la descripción
  Widget _buildDescriptionSkeleton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE40101).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE40101).withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Bone.circle(size: 20),
              const SizedBox(width: 8),
              Bone.text(width: 200),
            ],
          ),
          const SizedBox(height: 8),
          Bone.text(width: double.infinity),
          const SizedBox(height: 4),
          Bone.text(width: 250),
        ],
      ),
    );
  }

  // Widget para el skeleton de los controles
  Widget _buildControlsSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: const Bone.text(width: double.infinity),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 80,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: const Bone.text(width: 80),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldPop = await _showExitDialog();
        if (shouldPop && mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
            onPressed: () async {
              final shouldPop = await _showExitDialog();
              if (shouldPop && mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
          title: const Text(
            'Fechas de Viaje',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
          actions: [
            // Indicador de cambios
            if (_hasChanges)
              Container(
                margin: const EdgeInsets.only(right: 8),
                child: const Icon(
                  Icons.circle,
                  color: Color(0xFFE40101),
                  size: 12,
                ),
              ),
            // Botón de recarga
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.black87),
              onPressed: _isInitialLoading ? null : _loadTravelDates,
              tooltip: 'Recargar fechas',
            ),
          ],
        ),
        body: _errorMessage != null
            ? _buildErrorWidget()
            : Skeletonizer(
          enabled: _isInitialLoading || _isLoading,
          child: Column(
            children: [
              // Descripción
              _isInitialLoading
                  ? _buildDescriptionSkeleton()
                  : Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE40101).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE40101).withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.calendar_today, color: Color(0xFFE40101), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Selecciona tus fechas de viaje',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Marca los días en los que te gustaría viajar. Puedes seleccionar días individuales o rangos completos.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                    // Mostrar estado de cambios
                    if (_hasChanges) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.orange.withOpacity(0.3)),
                        ),
                        child: const Text(
                          'Tienes cambios sin guardar',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Controles de selección
              _isInitialLoading
                  ? _buildControlsSkeleton()
                  : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _toggleSelectionMode,
                        icon: Icon(
                          _isRangeMode ? Icons.touch_app : Icons.date_range,
                          size: 18,
                        ),
                        label: Text(
                          _isRangeMode ? 'Selección individual' : 'Seleccionar por rango',
                          style: const TextStyle(fontSize: 12),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFE40101),
                          side: const BorderSide(color: Color(0xFFE40101)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: _selectedDates.isEmpty ? null : _clearSelection,
                      icon: const Icon(Icons.clear_all, size: 18),
                      label: const Text('Limpiar', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[600],
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      ),
                    ),
                    // Botón para resetear a original (solo si hay cambios)
                    if (_hasChanges) ...[
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: _resetToOriginal,
                        icon: const Icon(Icons.undo, size: 18),
                        label: const Text('Resetear', style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue[600],
                          side: BorderSide(color: Colors.blue[300]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Calendario
              Expanded(
                child: _isInitialLoading
                    ? _buildCalendarSkeleton()
                    : Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TableCalendar<DateTime>(
                    locale: 'es_ES',
                    firstDay: DateTime.now(),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    rangeStartDay: _rangeStart,
                    rangeEndDay: _rangeEnd,
                    selectedDayPredicate: (day) {
                      final normalizedDay = DateTime(day.year, day.month, day.day);
                      final isSelected = _selectedDates.contains(normalizedDay);

                      // Debug temporal - remover después de solucionar
                      if (isSelected) {
                        print('Día seleccionado en calendario: $normalizedDay');
                      }

                      return isSelected;
                    },
                    rangeSelectionMode: _isRangeMode ? RangeSelectionMode.toggledOn : RangeSelectionMode.toggledOff,
                    onDaySelected: _onDaySelected,
                    onPageChanged: (focusedDay) {
                      setState(() {
                        _focusedDay = focusedDay;
                      });
                    },
                    calendarFormat: CalendarFormat.month,
                    availableCalendarFormats: const {CalendarFormat.month: 'Mes'},
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      leftChevronIcon: Icon(Icons.chevron_left, color: Color(0xFFE40101)),
                      rightChevronIcon: Icon(Icons.chevron_right, color: Color(0xFFE40101)),
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                      weekendStyle: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: true,
                      weekendTextStyle: const TextStyle(color: Colors.black87),
                      holidayTextStyle: const TextStyle(color: Colors.black87),
                      todayDecoration: BoxDecoration(
                        color: Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: const BoxDecoration(
                        color: Color(0xFFE40101),
                        shape: BoxShape.circle,
                      ),
                      rangeStartDecoration: const BoxDecoration(
                        color: Color(0xFFE40101),
                        shape: BoxShape.circle,
                      ),
                      rangeEndDecoration: const BoxDecoration(
                        color: Color(0xFFE40101),
                        shape: BoxShape.circle,
                      ),
                      rangeHighlightColor: const Color(0xFFE40101).withOpacity(0.1),
                      markerDecoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),

              // Botón de guardar
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: _isInitialLoading || _isLoading || (!_hasChanges || _selectedDates.isEmpty) ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE40101),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(width: 8),
                      Text(
                        !_hasChanges
                            ? 'Sin cambios para guardar'
                            : _selectedDates.isEmpty
                            ? 'Selecciona fechas para guardar'
                            : 'Guardar cambios',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}