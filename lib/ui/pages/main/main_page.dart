import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import '../chat/chat_screen.dart';
import '../reservations/reservations_screen.dart';
import '../community/community_screen.dart';
import '../profile/profile_screen.dart';
import 'widgets/bottom_navigation_widget.dart';
import '../../../domain/entities/destination.dart';

class MainPage extends StatefulWidget {
  final int initialIndex;
  final Destination? destination;

  const MainPage({Key? key, this.initialIndex = 0, this.destination}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  Destination? _destination;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _destination = widget.destination;

    // ✅ Debug para ver qué llega
    print('🏠 MainPage inicializado:');
    print('   - Index: $_currentIndex');
    print('   - Destination: ${_destination?.name}');
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;

      // ✅ Si cambiamos de tab y NO vamos al chat, limpiar destination
      if (index != 1) {
        _destination = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const HomeScreen(),                          // 0
          ChatScreen(destination: _destination),       // 1 - ✅ Pasa el destination
          const ReservationsScreen(),                  // 2
          const CommunityScreen(),                     // 3
          const ProfileScreen(),                       // 4
        ],
      ),
      bottomNavigationBar: BottomNavigationWidget(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}