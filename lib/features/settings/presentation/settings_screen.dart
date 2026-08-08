import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../farm/providers/farm_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMr = ref.watch(appLocaleProvider).languageCode == 'mr';
    final user = ref.watch(currentUserProvider);
    final activeFarm = ref.watch(activeFarmProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isMr ? 'अधिक सेवा व पर्याय' : 'Agro Services & More',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        children: [
          // Farmer Profile Header Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: const Icon(Icons.person_rounded, size: 36, color: Colors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.fullName ?? (isMr ? 'शेतकरी मित्र' : 'Farmer Friend'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user?.phone ?? '',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      if (activeFarm != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${activeFarm.name} • ${activeFarm.areaAcres} ${isMr ? 'एकर' : 'Acres'}',
                          style: const TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Section 1: Agricultural Intelligence Tools
          Text(
            isMr ? 'शेती व्यवस्थापन साधने' : 'Agri Management Tools',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),

          _buildNavTile(
            context: context,
            title: isMr ? 'हवामान अंदाज व फवारणी सल्ला' : 'Weather Forecast & Spray Window',
            subtitle: isMr ? 'सूक्ष्म-हवामान अंदाज व धोक्याचे इशारे' : 'Micro-climate & spray advisories',
            icon: Icons.wb_sunny_rounded,
            iconColor: const Color(0xFF0277BD),
            route: '/more/weather',
          ),
          _buildNavTile(
            context: context,
            title: isMr ? 'मका पीक दिनदर्शिका व टप्पे' : 'Maize Lifecycle & Task Tracker',
            subtitle: isMr ? 'बीजप्रक्रिया, खत नियोजन व पाणी व्यवस्थापन' : 'V1-R6 growth stages & tasks',
            icon: Icons.calendar_month_rounded,
            iconColor: const Color(0xFFE65100),
            route: '/more/lifecycle',
          ),
          _buildNavTile(
            context: context,
            title: isMr ? 'शेती नफा-तोटा व अर्थकारण' : 'Farm Economics & Accounting',
            subtitle: isMr ? 'खर्च, उत्पन्न व प्रति एकर नफा हिशोब' : 'P&L ledger & per-acre ROI',
            icon: Icons.account_balance_wallet_rounded,
            iconColor: const Color(0xFF2E7D32),
            route: '/more/finance',
          ),
          _buildNavTile(
            context: context,
            title: isMr ? 'जवळची कृषी सेवा केंद्रे' : 'Nearby Agri Stores & Inputs',
            subtitle: isMr ? 'खते, बियाणे व कीटकनाशके विक्रेते' : 'Certified Krishi Seva Kendras',
            icon: Icons.storefront_rounded,
            iconColor: const Color(0xFFC2185B),
            route: '/more/stores',
          ),
          _buildNavTile(
            context: context,
            title: isMr ? 'स्मार्ट पीक व वाण शिफारस' : 'Smart Crop Recommendation',
            subtitle: isMr ? 'माती व हवामानानुसार फायदेशीर पीक निवड' : 'NPK & season matching AI',
            icon: Icons.eco_rounded,
            iconColor: const Color(0xFF00897B),
            route: '/more/recommendations',
          ),
          _buildNavTile(
            context: context,
            title: isMr ? 'शेती सूचना व इशारे' : 'Farm Alerts & Notifications',
            subtitle: isMr ? 'कीड, रोग व हवामान सूचना' : 'Pest, disease & weather alerts',
            icon: Icons.notifications_active_rounded,
            iconColor: const Color(0xFFFB8C00),
            route: '/more/notifications',
          ),

          const SizedBox(height: 20),

          // Section 2: Preferences & Settings
          Text(
            isMr ? 'ॲप सेटिंग्ज व भाषा' : 'App Settings & Language',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE8F5E9),
                    child: Icon(Icons.language_rounded, color: AppColors.primaryGreen),
                  ),
                  title: Text(isMr ? 'भाषा बदला (Language)' : 'App Language'),
                  subtitle: Text(isMr ? 'सध्याची भाषा: मराठी' : 'Current Language: English'),
                  trailing: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'mr', label: Text('मराठी')),
                      ButtonSegment(value: 'en', label: Text('Eng')),
                    ],
                    selected: {isMr ? 'mr' : 'en'},
                    onSelectionChanged: (set) {
                      ref.read(appLocaleProvider.notifier).state = Locale(set.first);
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFFEBEE),
                    child: Icon(Icons.logout_rounded, color: Colors.red),
                  ),
                  title: Text(
                    isMr ? 'खात्यातून बाहेर पडा (Logout)' : 'Logout',
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(isMr ? 'लॉगआउट करायचे आहे का?' : 'Confirm Logout'),
                        content: Text(isMr ? 'तुम्हाला AgroVision मधून बाहेर पडायचे आहे का?' : 'Are you sure you want to log out?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text(isMr ? 'नाही' : 'Cancel'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                            onPressed: () {
                              Navigator.pop(ctx);
                              ref.read(authStateProvider.notifier).logout();
                            },
                            child: Text(isMr ? 'होय, लॉगआउट करा' : 'Logout'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
          Center(
            child: Text(
              'AgroVision v1.0.0 • Made with ❤️ for Indian Farmers',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildNavTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required String route,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withValues(alpha: 0.1),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        onTap: () => context.push(route),
      ),
    );
  }
}
