import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:rutaya/domain/entities/user_preferences.dart';
import 'package:rutaya/ui/pages/chat/package_details.dart';
import '../../../data/repositories/local_storage_service.dart';
import '../../../domain/entities/message.dart';
import '../../../domain/entities/destination.dart';
import '../../../domain/entities/tour_package.dart';
import '../../../main.dart';
import '../../../application/send_message_use_case.dart';

class ChatScreen extends StatefulWidget {
  final Destination? destination;

  const ChatScreen({Key? key, this.destination}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final localStorageService = LocalStorageService();
  List<Message> messages = [];
  bool _isLoading = true;
  bool _isBotTyping = false;
  int _messageIdCounter = 1;

  // Controlador de animación para los puntos
  late AnimationController _typingAnimationController;

  @override
  void initState() {
    super.initState();
    _typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _loadMessages();
  }

  // Función para detectar y parsear JSON
  TourPackage? _extractTourPackageFromMessage(String message) {
    try {
      print("Mensaje recibido: $message"); // Debug

      // Buscar JSON en el mensaje
      final jsonStart = message.indexOf('{');
      final jsonEnd = message.lastIndexOf('}');

      if (jsonStart == -1 || jsonEnd == -1 || jsonEnd <= jsonStart) {
        print("No se encontró JSON válido en el mensaje"); // Debug
        return null;
      }

      final jsonString = message.substring(jsonStart, jsonEnd + 1);
      print("JSON extraído: $jsonString"); // Debug

      final Map<String, dynamic> json = jsonDecode(jsonString);
      print("JSON decodificado: $json"); // Debug

      // Verificar si tiene la estructura correcta
      if (!json.containsKey('title') ||
          !json.containsKey('description') ||
          !json.containsKey('start_date') ||
          !json.containsKey('price')) {
        print("JSON no tiene la estructura esperada"); // Debug
        return null;
      }

      // Agregar campos faltantes para el constructor
      json['user_id'] = json['user_id'] ?? 0; // ID por defecto
      json['is_paid'] = json['is_paid'] ?? false; // No pagado por defecto

      print("PROCESADOOOOOOOOOOOOO Y SALE: ");
      print(json);

      // Crear el tour package usando el factory constructor
      final tourPackage = TourPackage.fromJson(json);

      print("TourPackage creado: ${tourPackage.title}"); // Debug
      return tourPackage;

    } catch (e) {
      print("Error al extraer tour package: $e"); // Debug
      print("Stack trace: ${e.toString()}"); // Debug adicional
      return null;
    }
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Intentar cargar mensajes existentes de la BD
      final existingMessages = await localStorageService.getAllMessages();

      if(widget.destination!=null){
        setState(() {
          _messageController.text="Me gustaria saber mas sobre ${widget.destination?.name}";
        });
      }

      if (existingMessages.isNotEmpty) {
        // Si hay mensajes existentes, mostrarlos
        setState(() {
          messages = existingMessages;
          _messageIdCounter = existingMessages.length + 1;
          _isLoading = false;
        });
      } else {
        // Si no hay mensajes, generar mensaje de bienvenida
        await _generateAndStoreWelcomeMessage();
      }

      _scrollToBottom();
    } catch (e) {
      print('Error al cargar mensajes: $e');
      // En caso de error, generar mensaje de bienvenida por defecto
      await _generateAndStoreWelcomeMessage();
    }
  }

  Future<void> _generateAndStoreWelcomeMessage() async {
    try {
      final userPreferences = await localStorageService.getCurrentUserPreferences();
      final welcomeMessage = await _generateWelcomeMessage(userPreferences!);

      // Guardar el mensaje de bienvenida en la BD
      await _storeMessage(welcomeMessage);

      setState(() {
        messages = [welcomeMessage];
        _messageIdCounter = 2;
        _isLoading = false;
      });
    } catch (e) {
      print('Error al generar mensaje de bienvenida: $e');
      // Crear mensaje por defecto si falla todo
      final defaultMessage = Message(
        id: 1,
        message : "¡Hola! Soy el asistente virtual de RutasYa. ¿En qué puedo ayudarte hoy?",
        isBot: true,
        timestamp: DateTime.now().toIso8601String(),
      );

      await _storeMessage(defaultMessage);

      setState(() {
        messages = [defaultMessage];
        _messageIdCounter = 2;
        _isLoading = false;
      });
    }
  }

  Future<Message> _generateWelcomeMessage(UserPreferences userPreferences) async {
    String message;

    message = "¡Hola! Soy el asistente virtual de RutasYa. ¿En qué puedo ayudarte hoy?";

    return Message(
      id: 1,
      message: message,
      isBot: true,
      timestamp: DateTime.now().toIso8601String(),
    );
  }

  Future<void> _storeMessage(Message message) async {
    try {
      await localStorageService.insertMessage(message);
    } catch (e) {
      print('Error al guardar mensaje: $e');
    }
  }

  void _sendMessage() async{
    if (_messageController.text.trim().isEmpty) return;

    final newMessage = Message(
      id: _messageIdCounter+=2,
      message: _messageController.text.trim(),
      isBot: false,
      timestamp: DateTime.now().toIso8601String(),
    );

    _storeMessage(newMessage);
    setState(() {
      messages.add(newMessage);
    });

    _messageController.clear();

    try {
      setState(() {
        _isBotTyping = true;
      });

      // Iniciar animación de typing
      _typingAnimationController.repeat();

      // Scroll hacia abajo para mostrar el indicador de typing
      _scrollToBottom();

      final sendMessageUseCase = getIt<SendMessageUseCase>();
      final messageResponse = await sendMessageUseCase.sendMessage(newMessage);

      setState(() {
        _isBotTyping = false;
      });

      // Detener animación de typing
      _typingAnimationController.stop();

      if (messageResponse != null) {

        print(messageResponse);
        _storeMessage(messageResponse);
        setState(() {
          messages.add(messageResponse);
        });

      } else {
        _showError('No se pudo registrar la mascota. Intenta nuevamente.');
      }
      _scrollToBottom();

    } catch (e) {
      setState(() {
        _isBotTyping = false;
      });
      _typingAnimationController.stop();
      _showError('Error al guardar la mascota: ${e.toString()}');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: _isLoading ? _buildLoadingIndicator() : _buildMessagesList(),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDC1A1A)),
          ),
          SizedBox(height: 16),
          Text(
            'Preparando tu asistente...',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      title: Row(
        children: [
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'RutasYa Asistente',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _isBotTyping ? 'Escribiendo...' : 'En línea',
                  style: TextStyle(
                    color: _isBotTyping ? const Color(0xFFF52525) : Colors.grey,
                    fontSize: 12,
                    fontWeight: _isBotTyping ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: messages.length + (_isBotTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length && _isBotTyping) {
          return _buildTypingIndicator();
        }
        final message = messages[index];

        // Verificar si es un mensaje del bot con JSON
        if (message.isBot) {
          print("Procesando mensaje del bot:..."); // Debug

          final tourPackage = _extractTourPackageFromMessage(message.message);
          if (tourPackage != null) {
            print("Mostrando tour package card para: ${tourPackage.title}"); // Debug
            return _buildTourPackageCard(tourPackage);
          } else {
            print("No se pudo extraer tour package, mostrando mensaje normal"); // Debug
          }
        }

        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildTourPackageCard(TourPackage package) {
    print("Construyendo tour package card: ${package.title}"); // Debug

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icono circular
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 12, top: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFF52525),
                  const Color(0xFFF52525),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy,
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
                border: Border.all(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con fecha
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFFF52525),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Text(
                      _formatDate(package.startDate),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
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
                        // Título
                        Text(
                          package.title,
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Descripción
                        Text(
                          package.description,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Barra de progreso decorativa
                        Container(
                          height: 3,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            gradient: LinearGradient(
                              colors: [
                                Colors.grey[300]!,
                                Colors.grey[400]!,
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Información del viaje
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: Colors.grey[500],
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDateTime(package.startDate),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.people,
                              color: Colors.grey[500],
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${package.quantity} ${package.quantity == 1 ? 'Adulto' : 'Adultos'}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Precio y botón
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PackageDetails(package: package, isFromChat: true)
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

  String _formatDate(String dateString) {
    try {
      print("Formateando fecha: $dateString"); // Debug

      // Intentar diferentes formatos de fecha
      DateTime date;
      if (dateString.contains('T')) {
        date = DateTime.parse(dateString);
      } else {
        // Formato YYYY-MM-DD
        date = DateTime.parse(dateString + 'T00:00:00');
      }

      final days = ['domingo', 'lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado'];
      final months = ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
        'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'];

      final result = '${days[date.weekday % 7]}, ${date.day} de ${months[date.month - 1]} de ${date.year}';
      print("Fecha formateada: $result"); // Debug
      return result;
    } catch (e) {
      print("Error al formatear fecha: $e"); // Debug
      return dateString;
    }
  }

  String _formatDateTime(String dateString) {
    try {
      print("Formateando fecha y hora: $dateString"); // Debug

      DateTime date;
      if (dateString.contains('T')) {
        date = DateTime.parse(dateString);
      } else {
        date = DateTime.parse(dateString + 'T08:00:00'); // Hora por defecto
      }

      final days = ['domingo', 'lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado'];
      final months = [
        'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
        'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
      ];

      final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
      final minute = date.minute.toString().padLeft(2, '0');
      final period = date.hour < 12 ? 'a. m.' : 'p. m.';

      final formattedTime = '$hour:$minute $period';
      final result = '${date.day} de ${months[date.month - 1]} de ${date.year} • $formattedTime';

      print("Fecha y hora formateada: $result"); // Debug
      return result;
    } catch (e) {
      print("Error al formatear fecha y hora: $e"); // Debug
      return dateString;
    }
  }


  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 8, top: 4),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF52525), Color(0xFFF52525)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy,
              color: Colors.white,
              size: 16,
            ),
          ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF52525), Color(0xFFF52525)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: _buildTypingAnimation(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingAnimation() {
    return AnimatedBuilder(
      animation: _typingAnimationController,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final animationValue = (_typingAnimationController.value - delay).clamp(0.0, 1.0);
            final opacity = (1.0 - (animationValue - 0.5).abs() * 2).clamp(0.3, 1.0);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(opacity),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildMessageBubble(Message message) {
    final isBot = message.isBot;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isBot) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8, top: 4),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF52525), Color(0xFFF52525)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: isBot
                    ? const LinearGradient(
                  colors: [Color(0xFFF52525), Color(0xFFF52525)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                    : null,
                color: isBot ? null : Colors.grey[200],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: isBot ? const Radius.circular(4) : const Radius.circular(20),
                  bottomRight: isBot ? const Radius.circular(20) : const Radius.circular(4),
                ),
              ),
              child: Text(
                message.message,
                style: TextStyle(
                  color: isBot ? Colors.white : const Color(0xFF2C3E50),
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (!isBot) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(left: 8, top: 4),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                color: Colors.grey[600],
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Escribe tu mensaje...',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF52525), Color(0xFFF52525)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: _isBotTyping ? null : _sendMessage, // Deshabilitar botón mientras tipea
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingAnimationController.dispose(); // Limpiar el controlador de animación
    super.dispose();
  }
}