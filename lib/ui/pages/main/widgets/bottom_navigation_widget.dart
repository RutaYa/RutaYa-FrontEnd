import 'package:flutter/material.dart';

class BottomNavigationWidget extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavigationWidget({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Stack(
        children: [
          Container(
            height: 80,
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  iconOutlined: Icons.home_outlined,
                  iconFilled: Icons.home,
                  label: 'Home',
                ),
                _buildNavItem(
                  index: 1,
                  iconOutlined: Icons.chat_bubble_outline,
                  iconFilled: Icons.chat_bubble,
                  label: 'Chat',
                ),
                _buildNavItem(
                  index: 2,
                  iconOutlined: Icons.calendar_today_outlined,
                  iconFilled: Icons.calendar_today,
                  label: 'Reservas',
                ),
                _buildNavItem(
                  index: 3,
                  iconOutlined: Icons.groups_outlined,
                  iconFilled: Icons.groups,
                  label: 'Comunidad',
                ),
                _buildNavItem(
                  index: 4,
                  iconOutlined: Icons.person_outline,
                  iconFilled: Icons.person,
                  label: 'Perfil',
                ),
              ],
            ),
          ),
          // Línea superior animada
          AnimatedAlign(
            alignment: _getAlignment(currentIndex),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Container(
              width: MediaQuery.of(context).size.width / 5,
              height: 3,
              color: const Color(0xFFFD0000),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData iconOutlined,
    required IconData iconFilled,
    required String label,
  }) {
    final isActive = currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? iconFilled : iconOutlined,
              size: 27,
              color: isActive ? Colors.black54 : Colors.grey,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.black54 : Colors.grey,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Alignment _getAlignment(int index) {
    switch (index) {
      case 0:
        return Alignment(-1.0, -1.0);
      case 1:
        return Alignment(-0.5, -1.0);
      case 2:
        return Alignment(0.0, -1.0);
      case 3:
        return Alignment(0.5, -1.0);
      case 4:
        return Alignment(1.0, -1.0);
      default:
        return Alignment(-1.0, -1.0);
    }
  }
}
