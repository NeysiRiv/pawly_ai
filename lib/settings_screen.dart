import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameController = TextEditingController(text: 'Buddy');
  final _breedController = TextEditingController(text: 'Golden Retriever');
  final _ageController = TextEditingController(text: '2');
  int _dailyStepsGoal = 8000;
  bool _walkReminder = true;
  bool _feedReminder = true;
  bool _careReminder = false;

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── SECCIÓN: DATOS DEL PERRO ──
            _sectionTitle('🐾 Pet Info'),
            const SizedBox(height: 10),
            _settingsCard(
              child: Column(
                children: [
                  _inputField(
                    controller: _nameController,
                    label: 'Pet Name',
                    icon: Icons.pets,
                  ),
                  const Divider(height: 1),
                  _inputField(
                    controller: _breedController,
                    label: 'Breed',
                    icon: Icons.category,
                  ),
                  const Divider(height: 1),
                  _inputField(
                    controller: _ageController,
                    label: 'Age (years)',
                    icon: Icons.cake,
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── SECCIÓN: META DE PASOS ──
            _sectionTitle('🚶 Daily Steps Goal'),
            const SizedBox(height: 10),
            _settingsCard(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.directions_walk,
                            color: Color(0xFF43A047), size: 22),
                        const SizedBox(width: 12),
                        const Text(
                          'Goal',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '$_dailyStepsGoal steps',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF43A047),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Slider(
                    value: _dailyStepsGoal.toDouble(),
                    min: 2000,
                    max: 20000,
                    divisions: 18,
                    activeColor: const Color(0xFF4CAF50),
                    inactiveColor: const Color(0xFFE0E0E0),
                    onChanged: (v) =>
                        setState(() => _dailyStepsGoal = v.toInt()),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('2,000',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey)),
                        Text('20,000',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── SECCIÓN: NOTIFICACIONES ──
            _sectionTitle('🔔 Reminders'),
            const SizedBox(height: 10),
            _settingsCard(
              child: Column(
                children: [
                  _toggleRow(
                    icon: Icons.directions_walk,
                    iconColor: const Color(0xFF43A047),
                    label: 'Walk Reminder',
                    subtitle: 'Daily at 8:00 AM',
                    value: _walkReminder,
                    onChanged: (v) => setState(() => _walkReminder = v),
                  ),
                  const Divider(height: 1),
                  _toggleRow(
                    icon: Icons.set_meal,
                    iconColor: const Color(0xFFEF5350),
                    label: 'Feed Reminder',
                    subtitle: 'Daily at 12:00 PM',
                    value: _feedReminder,
                    onChanged: (v) => setState(() => _feedReminder = v),
                  ),
                  const Divider(height: 1),
                  _toggleRow(
                    icon: Icons.favorite,
                    iconColor: const Color(0xFF42A5F5),
                    label: 'Care Reminder',
                    subtitle: 'Daily at 6:00 PM',
                    value: _careReminder,
                    onChanged: (v) => setState(() => _careReminder = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── BOTÓN GUARDAR ──
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Settings saved!'),
                      backgroundColor: Color(0xFF4CAF50),
                    ),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Save Settings',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: Colors.grey,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _settingsCard({required Widget child}) {
    return Container(
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
      child: child,
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF43A047), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                labelText: label,
                border: InputBorder.none,
                labelStyle: const TextStyle(
                    fontSize: 13, color: Colors.grey),
              ),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _toggleRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700)),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF4CAF50),
          ),
        ],
      ),
    );
  }
}