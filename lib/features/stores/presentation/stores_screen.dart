import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/app.dart';
import '../../../core/constants/app_colors.dart';
import '../domain/store_model.dart';
import '../providers/store_provider.dart';

class StoresScreen extends ConsumerStatefulWidget {
  const StoresScreen({super.key});

  @override
  ConsumerState<StoresScreen> createState() => _StoresScreenState();
}

class _StoresScreenState extends ConsumerState<StoresScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _categories = [
    {'id': 'All', 'en': 'All Stores', 'mr': 'सर्व केंद्र'},
    {'id': 'Seeds', 'en': '🌱 Seeds', 'mr': '🌱 बियाणे'},
    {'id': 'Fertilizers', 'en': '🌾 Fertilizers', 'mr': '🌾 खते'},
    {'id': 'Pesticides', 'en': '🛡️ Pesticides', 'mr': '🛡️ औषधे'},
    {'id': 'Bio-Fertilizers', 'en': '🧪 Bio-Agri', 'mr': '🧪 जैविक'},
    {'id': 'Drip Equipment', 'en': '💧 Drip / Irrigation', 'mr': '💧 ठिबक'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _openGoogleMaps(double lat, double lon, String label) async {
    final Uri mapUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lon');
    if (await canLaunchUrl(mapUri)) {
      await launchUrl(mapUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMr = ref.watch(appLocaleProvider).languageCode == 'mr';
    final storesAsync = ref.watch(nearbyStoresProvider);
    final activeCategory = ref.watch(storeCategoryFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isMr ? 'जवळची कृषी सेवा केंद्रे' : 'Nearby Agri Stores & Inputs',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            color: Colors.white,
            child: Column(
              children: [
                // Search Input Field
                TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    ref.read(storeSearchQueryProvider.notifier).state = val;
                  },
                  decoration: InputDecoration(
                    hintText: isMr ? 'दुकान, डीलर किंवा तालुका शोधा...' : 'Search store name, dealer or taluka...',
                    hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: AppColors.primaryGreen),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              ref.read(storeSearchQueryProvider.notifier).state = '';
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Category Chips Row
                SizedBox(
                  height: 38,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final isSelected = activeCategory == cat['id'];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(
                            isMr ? cat['mr']! : cat['en']!,
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppColors.primaryGreen,
                          backgroundColor: Colors.grey.shade100,
                          side: BorderSide.none,
                          onSelected: (val) {
                            if (val) {
                              ref.read(storeCategoryFilterProvider.notifier).state = cat['id']!;
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFEEEEEE)),

          // Store List
          Expanded(
            child: storesAsync.when(
              data: (res) {
                if (res.stores.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.storefront_outlined, size: 56, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text(
                            isMr ? 'कोणतेही केंद्र आढळले नाही.' : 'No agri stores found for this search.',
                            style: const TextStyle(fontSize: 15, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(nearbyStoresProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: res.stores.length,
                    itemBuilder: (context, index) {
                      return _buildStoreCard(res.stores[index], isMr);
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(err.toString(), style: const TextStyle(color: Colors.red)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreCard(AgriStore store, bool isMr) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.1),
                  child: const Icon(Icons.storefront_rounded, color: AppColors.primaryGreen, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isMr ? store.nameMr : store.nameEn,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            store.dealerName,
                            style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500),
                          ),
                          if (store.isVerified) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.verified_rounded, color: Colors.blue, size: 14),
                            const SizedBox(width: 2),
                            Text(
                              isMr ? 'परवानाधारक' : 'Verified',
                              style: const TextStyle(fontSize: 11, color: Colors.blue, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                if (store.distanceKm != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${store.distanceKm!.toStringAsFixed(1)} km',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 10),

            // Address & Hours
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    isMr ? store.addressMr : store.addressEn,
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time_rounded, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  store.openingHours,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const Spacer(),
                const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                Text(
                  ' ${store.rating.toStringAsFixed(1)}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Category Chips
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: store.categories.map((c) {
                return Chip(
                  label: Text(c, style: const TextStyle(fontSize: 10, color: AppColors.primaryGreen)),
                  backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.08),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  side: BorderSide.none,
                );
              }).toList(),
            ),

            const Divider(height: 20),

            // Call & Directions Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryGreen,
                      side: const BorderSide(color: AppColors.primaryGreen),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    icon: const Icon(Icons.phone_in_talk_rounded, size: 16),
                    label: Text(isMr ? 'कॉल करा' : 'Call Store', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    onPressed: () => _makePhoneCall(store.phone),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    icon: const Icon(Icons.navigation_rounded, size: 16),
                    label: Text(isMr ? 'मार्ग (Maps)' : 'Directions', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    onPressed: () => _openGoogleMaps(
                      store.latitude,
                      store.longitude,
                      store.nameEn,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
