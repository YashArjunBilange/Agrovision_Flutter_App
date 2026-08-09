import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../farm/presentation/add_edit_farm_dialog.dart';
import '../../farm/providers/farm_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMr = ref.watch(appLocaleProvider).languageCode == 'mr';
    final user = ref.watch(currentUserProvider);
    final activeFarm = ref.watch(activeFarmProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 900 ? 4 : (screenWidth > 600 ? 3 : 2);
    final childAspectRatio = screenWidth > 600 ? 1.3 : 1.1;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(farmsProvider.notifier).loadFarms();
          },
          child: CustomScrollView(
            slivers: [
              // Top Custom App Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isMr ? 'राम राम 🙏' : 'Namaste 🙏',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondaryLight,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user?.fullName ?? (isMr ? 'शेतकरी मित्र' : 'Farmer Friend'),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          // Notifications Bell with Badge
                          IconButton(
                            icon: const Icon(Icons.notifications_outlined, color: AppColors.primaryGreen),
                            tooltip: isMr ? 'सूचना' : 'Notifications',
                            onPressed: () => context.push('/more/notifications'),
                          ),
                          // Theme Toggle
                          IconButton(
                            icon: Icon(
                              ref.watch(themeModeProvider) == ThemeMode.dark 
                                ? Icons.light_mode 
                                : Icons.dark_mode, 
                              color: AppColors.primaryGreen,
                            ),
                            tooltip: isMr ? 'थीम बदला' : 'Toggle Theme',
                            onPressed: () {
                              final current = ref.read(themeModeProvider);
                              ref.read(themeModeProvider.notifier).state = 
                                current == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
                            },
                          ),
                          // Language Switcher
                          ActionChip(
                            avatar: const Icon(Icons.language, size: 16, color: AppColors.primaryGreen),
                            label: Text(
                              isMr ? 'मराठी' : 'English',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            onPressed: () {
                              final newLocale = isMr ? const Locale('en') : const Locale('mr');
                              ref.read(appLocaleProvider.notifier).state = newLocale;
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Active Farm Context Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: _buildActiveFarmCard(context, ref, activeFarm, isMr),
                ),
              ),

              // Advisory Notice Banner
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryLight.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.secondaryLight.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.wb_sunny_rounded, color: Color(0xFFF57F17), size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isMr ? 'मका पीक विशेष सल्ला 🌽' : 'Maize Farming Advisory 🌽',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isMr
                                    ? 'लष्करी अळी (FAW) चा प्रादुर्भाव टाळण्यासाठी दर आठवड्याला पानांचे निरीक्षण करा.'
                                    : 'Scout leaves weekly for Fall Armyworm (FAW) whorl feeding symptoms.',
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Features Quick Grid Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Text(
                    isMr ? 'प्रमुख कृषी सेवा' : 'Agro Services',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              // Grid of Key Features
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: SliverGrid.count(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: childAspectRatio,
                  children: [
                    _buildFeatureCard(
                      context: context,
                      title: isMr ? 'रोग स्कॅनिंग' : 'Scan Disease',
                      subtitle: isMr ? 'AI द्वारे मका रोग ओळख' : 'Instant AI Diagnosis',
                      icon: Icons.document_scanner_rounded,
                      color: AppColors.primaryGreen,
                      onTap: () => context.go('/scan'),
                    ),
                    _buildFeatureCard(
                      context: context,
                      title: isMr ? 'पीक टप्पे व दिनदर्शिका' : 'Crop Lifecycle',
                      subtitle: isMr ? 'खत, पाणी व फवारणी वेळापत्रक' : 'Stage-wise calendar',
                      icon: Icons.calendar_month_rounded,
                      color: const Color(0xFFE65100),
                      onTap: () => context.push('/more/lifecycle'),
                    ),
                    _buildFeatureCard(
                      context: context,
                      title: isMr ? 'हवामान अंदाज' : 'Weather & Alerts',
                      subtitle: isMr ? 'पाऊस, तापमान व वारा' : 'Rain & agri forecast',
                      icon: Icons.cloud_outlined,
                      color: const Color(0xFF0277BD),
                      onTap: () => context.push('/more/weather'),
                    ),
                    _buildFeatureCard(
                      context: context,
                      title: isMr ? 'AI कृषी सल्लागार' : 'AI Agri Assistant',
                      subtitle: isMr ? 'कृषी तज्ञांशी बोला (मराठी/Eng)' : 'Chat with agronomist',
                      icon: Icons.smart_toy_rounded,
                      color: const Color(0xFF6A1B9A),
                      onTap: () => context.go('/assistant'),
                    ),
                    _buildFeatureCard(
                      context: context,
                      title: isMr ? 'खर्च व नफा नोंद' : 'Farm Economics',
                      subtitle: isMr ? 'बियाणे, खते व उत्पन्न हिशोब' : 'Cost & profit ledger',
                      icon: Icons.account_balance_wallet_outlined,
                      color: const Color(0xFF2E7D32),
                      onTap: () => context.push('/more/finance'),
                    ),
                    _buildFeatureCard(
                      context: context,
                      title: isMr ? 'जवळची कृषी दुकाने' : 'Nearby Agri Stores',
                      subtitle: isMr ? 'औषधे, खते व बियाणे विक्रेते' : 'Certified input dealers',
                      icon: Icons.storefront_outlined,
                      color: const Color(0xFFC2185B),
                      onTap: () => context.push('/more/stores'),
                    ),
                    _buildFeatureCard(
                      context: context,
                      title: isMr ? 'पीक शिफारस' : 'Crop Recommendation',
                      subtitle: isMr ? 'माती व हवामानानुसार निवड' : 'NPK & season matching',
                      icon: Icons.eco_rounded,
                      color: const Color(0xFF00897B),
                      onTap: () => context.push('/more/recommendations'),
                    ),
                    _buildFeatureCard(
                      context: context,
                      title: isMr ? 'शेती सूचना' : 'Farm Alerts',
                      subtitle: isMr ? 'कीड, रोग व धोक्याचे इशारे' : 'Pest & weather alerts',
                      icon: Icons.notifications_active_outlined,
                      color: const Color(0xFFFB8C00),
                      onTap: () => context.push('/more/notifications'),
                    ),
                  ],
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 30),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveFarmCard(
    BuildContext context,
    WidgetRef ref,
    dynamic activeFarm,
    bool isMr,
  ) {
    if (activeFarm == null) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.primaryGreen.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            const Icon(Icons.add_location_alt_outlined, color: AppColors.primaryGreen, size: 36),
            const SizedBox(height: 10),
            Text(
              isMr ? 'आपल्या शेताची नोंद करा' : 'Register Your Farm Plot',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              isMr
                  ? 'योग्य हवामान आणि पीक सल्ल्यासाठी आपले शेत जोडा.'
                  : 'Add your farm to receive plot-specific recommendations.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => AddEditFarmDialog.show(context),
              icon: const Icon(Icons.add),
              label: Text(isMr ? 'नवीन शेत जोडा' : 'Add Farm Plot'),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.place, color: Colors.white, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    isMr ? 'सक्रिय शेत' : 'ACTIVE FARM',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => context.go('/farm'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isMr ? 'शेत बदला' : 'Change',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 10),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            activeFarm.name,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            [activeFarm.village, activeFarm.taluka, activeFarm.district]
                .where((s) => s != null && (s as String).isNotEmpty)
                .join(', '),
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetricChip(
                Icons.square_foot,
                '${activeFarm.areaAcres.toStringAsFixed(1)} ${isMr ? "एकर" : "Acres"}',
              ),
              if (activeFarm.soilType != null)
                _buildMetricChip(Icons.layers, activeFarm.soilType!),
              if (activeFarm.irrigationType != null)
                _buildMetricChip(Icons.water_drop, activeFarm.irrigationType!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 13),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
