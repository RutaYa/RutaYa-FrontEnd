import 'package:flutter/material.dart';
import '../../data/repositories/local_storage_service.dart';
import '../../domain/entities/user.dart';

class PreferencesFormScreen extends StatefulWidget {
  final bool isFirstTime;

  const PreferencesFormScreen({
    super.key,
    this.isFirstTime = false,
  });

  @override
  State<PreferencesFormScreen> createState() => _PreferencesFormScreenState();
}

class _PreferencesFormScreenState extends State<PreferencesFormScreen> {
  final localStorageService = LocalStorageService();
  final _formKey = GlobalKey<FormState>();
  User? currentUser;

  // Controladores
  DateTime? _birthDate;
  String? _gender;

  // Preferencias de viaje
  List<String> _selectedInterests = [];
  String? _environment;
  String? _travelStyle;
  String? _budget;
  int _adrenalineLevel = 5;
  String? _hiddenPlaces;

  // Opciones
  final List<String> _interests = ['Cultura', 'Historia', 'Aventura', 'Deporte', 'Experiencias únicas'];
  final List<String> _environments = ['Playa', 'Montañas', 'Selva'];
  final List<String> _travelStyles = ['Sol@', 'En pareja', '2-3 personas más', '4+'];
  final List<String> _budgets = ['Max 350 USD', '351 - 700 USD', '701 USD+'];
  final List<String> _hiddenPlacesOptions = ['Sí', 'No'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future _loadData() async {
    final user = await localStorageService.getCurrentUser();
    setState(() {
      currentUser = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Preferencias',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Saludo personalizado
              Text(
                'Hola ${currentUser?.firstName} cuéntanos más sobre ti:',
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF6211F),
                ),
              ),
              const SizedBox(height: 15),

              // Preguntas generales
              _buildSectionTitle('Preguntas generales:'),
              const SizedBox(height: 20),

              _buildDateField(),
              const SizedBox(height: 20),

              _buildGenderDropdown(),
              const SizedBox(height: 30),

              // Preguntas para conocerte
              _buildSectionTitle('Preguntas para conocerte:'),
              const SizedBox(height: 20),

              _buildInterestsSection(),
              const SizedBox(height: 25),

              _buildEnvironmentDropdown(),
              const SizedBox(height: 25),

              _buildTravelStyleDropdown(),
              const SizedBox(height: 25),

              _buildBudgetDropdown(),
              const SizedBox(height: 25),

              _buildAdrenalineScale(),
              const SizedBox(height: 25),

              _buildHiddenPlacesDropdown(),
              const SizedBox(height: 40),

              // Botón de guardar
              _buildSaveButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A1A1A),
      ),
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fecha de nacimiento',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
              firstDate: DateTime(1920),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Color(0xFFF6211F),
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              setState(() {
                _birthDate = picked;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _birthDate != null
                      ? '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}'
                      : 'Seleccionar fecha',
                  style: TextStyle(
                    color: _birthDate != null ? Colors.black87 : Colors.grey.shade600,
                    fontSize: 16,
                  ),
                ),
                const Icon(Icons.calendar_today, color: Color(0xFFF6211F)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Género',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFF6211F)),
            ),
          ),
          hint: const Text('Seleccionar género'),
          value: _gender,
          items: ['Masculino', 'Femenino', 'Otro', 'Prefiero no decir']
              .map((gender) => DropdownMenuItem(
            value: gender,
            child: Text(gender),
          ))
              .toList(),
          onChanged: (value) {
            setState(() {
              _gender = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildInterestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '1. ¿Qué es lo primordial que buscas en un viaje? Elige máximo 2.',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _interests.map((interest) {
            final isSelected = _selectedInterests.contains(interest);
            return FilterChip(
              label: Text(interest),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected && _selectedInterests.length < 2) {
                    _selectedInterests.add(interest);
                  } else if (!selected) {
                    _selectedInterests.remove(interest);
                  }
                });
              },
              selectedColor: const Color(0xFFF6211F).withOpacity(0.2),
              checkmarkColor: const Color(0xFFF6211F),
              labelStyle: TextStyle(
                color: isSelected ? const Color(0xFFF6211F) : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? const Color(0xFFF6211F) : Colors.grey.shade300,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildEnvironmentDropdown() {
    return _buildDropdownField(
      '2. Te consideras una persona más de...',
      _environment,
      _environments,
          (value) => setState(() => _environment = value),
    );
  }

  Widget _buildTravelStyleDropdown() {
    return _buildDropdownField(
      '3. ¿Sueles viajar solo o acompañado?',
      _travelStyle,
      _travelStyles,
          (value) => setState(() => _travelStyle = value),
    );
  }

  Widget _buildBudgetDropdown() {
    return _buildDropdownField(
      '4. ¿Cuál es tu presupuesto estimado en un viaje de 1 semana?\nConsidera absolutamente todo (por persona).',
      _budget,
      _budgets,
          (value) => setState(() => _budget = value),
    );
  }

  Widget _buildHiddenPlacesDropdown() {
    return _buildDropdownField(
      '6. ¿Te gustaría conocer lugares ocultos en el Perú antes que se vuelvan más populares?',
      _hiddenPlaces,
      _hiddenPlacesOptions,
          (value) => setState(() => _hiddenPlaces = value),
    );
  }

  Widget _buildDropdownField(
      String label,
      String? value,
      List<String> options,
      void Function(String?) onChanged,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFF6211F)),
            ),
          ),
          hint: const Text('Seleccionar opción'),
          value: value,
          items: options
              .map((option) => DropdownMenuItem(
            value: option,
            child: Text(option),
          ))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildAdrenalineScale() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '5. Del 1 al 10, ¿qué tanto te gusta la adrenalina?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Text('1', style: TextStyle(fontSize: 14, color: Colors.grey)),
            Expanded(
              child: Slider(
                value: _adrenalineLevel.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                activeColor: const Color(0xFFF6211F),
                inactiveColor: const Color(0xFFF6211F).withOpacity(0.3),
                onChanged: (value) {
                  setState(() {
                    _adrenalineLevel = value.round();
                  });
                },
              ),
            ),
            const Text('10', style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF6211F).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Nivel: $_adrenalineLevel',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF6211F),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _savePreferences();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF6211F),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Guardar Preferencias',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _savePreferences() {
    // Aquí implementarías la lógica para guardar las preferencias
    // Por ejemplo, enviar a una API o guardar localmente

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preferencias guardadas exitosamente'),
        backgroundColor: Color(0xFFF6211F),
      ),
    );

    // Si es primera vez, navegar a la pantalla principal
    if (widget.isFirstTime) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}