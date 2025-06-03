import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
