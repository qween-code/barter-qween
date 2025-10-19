import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Notification preferences page
/// Allows users to customize notification settings
class NotificationPreferencesPage extends StatefulWidget {
  const NotificationPreferencesPage({Key? key}) : super(key: key);

  @override
  State<NotificationPreferencesPage> createState() =>
      _NotificationPreferencesPageState();
}

class _NotificationPreferencesPageState
    extends State<NotificationPreferencesPage> {
  late FirebaseFirestore _firestore;
  late FirebaseAuth _auth;

  // Preference states
  bool globalNotificationsEnabled = true;
  bool dontDisturbMode = false;

  // Category preferences
  Map<String, bool> categoryEnabled = {};
  Map<String, bool> categoryBatching = {};

  // Quiet hours
  bool quietHoursEnabled = false;
  TimeOfDay quietHourStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay quietHourEnd = const TimeOfDay(hour: 8, minute: 0);

  // Rate limiting
  int maxNotificationsPerHour = 0;

  @override
  void initState() {
    super.initState();
    _firestore = FirebaseFirestore.instance;
    _auth = FirebaseAuth.instance;
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final userDoc = await _firestore.collection('users').doc(userId).get();
      final preferences = userDoc.get('notificationPreferences') as Map<String, dynamic>? ?? {};

      setState(() {
        globalNotificationsEnabled =
            preferences['globalNotificationsEnabled'] as bool? ?? true;
        dontDisturbMode =
            preferences['dontDisturbMode'] as bool? ?? false;

        // Load category settings
        final messages = preferences['messages'] as Map<String, dynamic>? ?? {};
        categoryEnabled['messages'] = messages['enabled'] as bool? ?? true;
        categoryBatching['messages'] =
            messages['batchNotifications'] as bool? ?? false;

        final tradeOffers =
            preferences['tradeOffers'] as Map<String, dynamic>? ?? {};
        categoryEnabled['tradeOffers'] =
            tradeOffers['enabled'] as bool? ?? true;
        categoryBatching['tradeOffers'] =
            tradeOffers['batchNotifications'] as bool? ?? true;

        final items = preferences['items'] as Map<String, dynamic>? ?? {};
        categoryEnabled['items'] = items['enabled'] as bool? ?? true;
        categoryBatching['items'] =
            items['batchNotifications'] as bool? ?? true;

        final social = preferences['social'] as Map<String, dynamic>? ?? {};
        categoryEnabled['social'] = social['enabled'] as bool? ?? true;
        categoryBatching['social'] =
            social['batchNotifications'] as bool? ?? true;

        final campaigns =
            preferences['campaigns'] as Map<String, dynamic>? ?? {};
        categoryEnabled['campaigns'] =
            campaigns['enabled'] as bool? ?? true;
        categoryBatching['campaigns'] =
            campaigns['batchNotifications'] as bool? ?? true;

        final warnings = preferences['warnings'] as Map<String, dynamic>? ?? {};
        categoryEnabled['warnings'] =
            warnings['enabled'] as bool? ?? true;
        categoryBatching['warnings'] =
            warnings['batchNotifications'] as bool? ?? false;

        // Load quiet hours
        final quietHours =
            preferences['quietHours'] as Map<String, dynamic>? ?? {};
        quietHoursEnabled = quietHours['enabled'] as bool? ?? false;
        final startHour = quietHours['startHour'] as int? ?? 22;
        final endHour = quietHours['endHour'] as int? ?? 8;
        quietHourStart = TimeOfDay(hour: startHour, minute: 0);
        quietHourEnd = TimeOfDay(hour: endHour, minute: 0);

        maxNotificationsPerHour =
            preferences['maxNotificationsPerHour'] as int? ?? 0;
      });
    } catch (e) {
      debugPrint('❌ Error loading preferences: $e');
    }
  }

  Future<void> _savePreferences() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      await _firestore.collection('users').doc(userId).update({
        'notificationPreferences': {
          'globalNotificationsEnabled': globalNotificationsEnabled,
          'dontDisturbMode': dontDisturbMode,
          'messages': {
            'enabled': categoryEnabled['messages'] ?? true,
            'batchNotifications': categoryBatching['messages'] ?? false,
          },
          'tradeOffers': {
            'enabled': categoryEnabled['tradeOffers'] ?? true,
            'batchNotifications': categoryBatching['tradeOffers'] ?? true,
          },
          'items': {
            'enabled': categoryEnabled['items'] ?? true,
            'batchNotifications': categoryBatching['items'] ?? true,
          },
          'social': {
            'enabled': categoryEnabled['social'] ?? true,
            'batchNotifications': categoryBatching['social'] ?? true,
          },
          'campaigns': {
            'enabled': categoryEnabled['campaigns'] ?? true,
            'batchNotifications': categoryBatching['campaigns'] ?? true,
          },
          'warnings': {
            'enabled': categoryEnabled['warnings'] ?? true,
            'batchNotifications': categoryBatching['warnings'] ?? false,
          },
          'quietHours': {
            'enabled': quietHoursEnabled,
            'startHour': quietHourStart.hour,
            'endHour': quietHourEnd.hour,
          },
          'maxNotificationsPerHour': maxNotificationsPerHour,
        },
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Tercihler kaydedildi')),
        );
      }
    } catch (e) {
      debugPrint('❌ Error saving preferences: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Tercihler kaydedilemedi')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirim Tercihleri'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Global settings
            _buildSectionHeader('Genel Ayarlar'),
            _buildSwitchTile(
              title: 'Tüm Bildirimler',
              subtitle: 'Bildirimleri tamamen aç/kapat',
              value: globalNotificationsEnabled,
              onChanged: (value) {
                setState(() => globalNotificationsEnabled = value);
              },
            ),
            _buildSwitchTile(
              title: 'Rahatsız Etme Modu',
              subtitle: 'Tüm bildirimleri geçici olarak kapat',
              value: dontDisturbMode,
              onChanged: (value) {
                setState(() => dontDisturbMode = value);
              },
            ),
            const SizedBox(height: 24),

            // Category settings
            _buildSectionHeader('Bildirim Türleri'),
            _buildCategoryTile(
              title: 'Mesajlar',
              icon: Icons.message_outlined,
              categoryKey: 'messages',
              allowBatching: false,
            ),
            _buildCategoryTile(
              title: 'Ticari Teklifler',
              icon: Icons.handshake_outlined,
              categoryKey: 'tradeOffers',
              allowBatching: true,
            ),
            _buildCategoryTile(
              title: 'Ürünler',
              icon: Icons.shopping_bag_outlined,
              categoryKey: 'items',
              allowBatching: true,
            ),
            _buildCategoryTile(
              title: 'Sosyal',
              icon: Icons.people_outlined,
              categoryKey: 'social',
              allowBatching: true,
            ),
            _buildCategoryTile(
              title: 'Kampanyalar',
              icon: Icons.local_offer_outlined,
              categoryKey: 'campaigns',
              allowBatching: true,
            ),
            _buildCategoryTile(
              title: 'Uyarılar',
              icon: Icons.warning_outlined,
              categoryKey: 'warnings',
              allowBatching: false,
            ),
            const SizedBox(height: 24),

            // Quiet hours
            _buildSectionHeader('Sakin Saatler'),
            _buildSwitchTile(
              title: 'Sakin Saatleri Etkinleştir',
              subtitle: 'Bu saatlarda bildirim almayın',
              value: quietHoursEnabled,
              onChanged: (value) {
                setState(() => quietHoursEnabled = value);
              },
            ),
            if (quietHoursEnabled) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: const Text('Başlama Saati'),
                        subtitle: Text('${quietHourStart.hour}:00'),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: quietHourStart,
                          );
                          if (picked != null) {
                            setState(() => quietHourStart = picked);
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: const Text('Bitiş Saati'),
                        subtitle: Text('${quietHourEnd.hour}:00'),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: quietHourEnd,
                          );
                          if (picked != null) {
                            setState(() => quietHourEnd = picked);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _savePreferences,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Tercihler Kaydet',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildCategoryTile({
    required String title,
    required IconData icon,
    required String categoryKey,
    required bool allowBatching,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Etkinleştir'),
                  value: categoryEnabled[categoryKey] ?? true,
                  onChanged: (value) {
                    setState(() {
                      categoryEnabled[categoryKey] = value;
                    });
                  },
                ),
                if (allowBatching)
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Toplu Gönder'),
                    subtitle: const Text('Birden fazla bildirimi özet olarak gönder'),
                    value: categoryBatching[categoryKey] ?? false,
                    onChanged: (value) {
                      setState(() {
                        categoryBatching[categoryKey] = value;
                      });
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
