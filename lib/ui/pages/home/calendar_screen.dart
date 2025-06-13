import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
// Importa tus use cases y GetIt
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

      if (dateStrings.isNotEmpty) {
        // Convertir las fechas string a DateTime
        final Set<DateTime> loadedDates = {};
        for (String dateString in dateStrings) {
          try {
            final DateTime date = DateTime.parse(dateString);
            loadedDates.add(DateTime(date.year, date.month, date.day));
          } catch (e) {
            print('Error parsing date: $dateString');
          }
        }

        setState(() {
          // Actualizar tanto las fechas originales como las seleccionadas
          _originalDates.clear();
          _originalDates.addAll(loadedDates);
          _selectedDates.clear();
          _selectedDates.addAll(loadedDates);
          _isInitialLoading = false;
        });
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
    setState(() {
      _focusedDay = focusedDay;

      if (_isRangeMode) {
        // Modo de selección por rango
        if (_rangeStart == null) {
          _rangeStart = selectedDay;
          _rangeEnd = null;
        } else if (_rangeEnd == null && selectedDay.isAfter(_rangeStart!)) {
          _rangeEnd = selectedDay;
          _addRangeToSelection();
        } else {
          _rangeStart = selectedDay;
          _rangeEnd = null;
        }
      } else {
        // Modo de selección individual
        if (_selectedDates.contains(selectedDay)) {
          _selectedDates.remove(selectedDay);
        } else {
          _selectedDates.add(selectedDay);
        }
      }
    });
  }

  void _addRangeToSelection() {
    if (_rangeStart != null && _rangeEnd != null) {
      DateTime current = _rangeStart!;
      while (current.isBefore(_rangeEnd!) || current.isAtSameMomentAs(_rangeEnd!)) {
        _selectedDates.add(current);
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
            onPressed: () => Navigator.of(context).pop(true),
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
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE40101),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Guardar y salir'),
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
        body: _isInitialLoading
            ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFFE40101)),
              SizedBox(height: 16),
              Text(
                'Cargando tus fechas...',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        )
            : _errorMessage != null
            ? _buildErrorWidget()
            : _isLoading
            ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFFE40101)),
              SizedBox(height: 16),
              Text(
                'Guardando tus fechas...',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        )
            : Column(
          children: [
            // Descripción actualizada
            Container(
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

            // Controles de selección actualizados
            Padding(
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
              child: Container(
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
                  selectedDayPredicate: (day) => _selectedDates.contains(day),
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

            // Botón de guardar actualizado
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: !_hasChanges || _selectedDates.isEmpty ? null : _saveChanges,
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 8),
                    Text(
                      !_hasChanges
                          ? 'Sin cambios para guardar'
                          : _selectedDates.isEmpty
                          ? 'Selecciona fechas para guardar'
                          : 'Guardar cambios (${_selectedDates.length} fecha${_selectedDates.length == 1 ? '' : 's'})',
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
    );
  }
}