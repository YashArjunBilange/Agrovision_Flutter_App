import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/app.dart';
import '../../../core/constants/app_colors.dart';
import '../domain/notification_model.dart';
import '../providers/notification_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMr = ref.watch(appLocaleProvider).languageCode == 'mr';
    final alertsAsync = ref.watch(farmAlertsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isMr ? 'शेती सूचना व इशारे' : 'Farm Alerts & Notifications',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(farmAlertsProvider),
          ),
        ],
      ),
      body: alertsAsync.when(
        data: (data) {
          if (data.alerts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.notifications_none_rounded, size: 64, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text(
                      isMr ? 'कोणतीही नवीन सूचना उपलब्ध नाही.' : 'No new notifications right now.',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(farmAlertsProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: data.alerts.length,
              itemBuilder: (context, index) {
                final alert = data.alerts[index];
                return _buildAlertCard(context, ref, alert, isMr);
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
    );
  }

  Widget _buildAlertCard(BuildContext context, WidgetRef ref, FarmAlertModel alert, bool isMr) {
    Color cardColor;
    Color iconColor;
    IconData iconData;

    switch (alert.type) {
      case 'weather':
        cardColor = Colors.orange.shade50;
        iconColor = Colors.deepOrange;
        iconData = Icons.thunderstorm_rounded;
        break;
      case 'task':
        cardColor = Colors.blue.shade50;
        iconColor = Colors.blue.shade700;
        iconData = Icons.task_alt_rounded;
        break;
      case 'warning':
        cardColor = Colors.red.shade50;
        iconColor = Colors.red.shade700;
        iconData = Icons.warning_amber_rounded;
        break;
      default:
        cardColor = Colors.green.shade50;
        iconColor = AppColors.primaryGreen;
        iconData = Icons.eco_rounded;
    }

    final dateFormat = DateFormat('dd MMM, hh:mm a');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: alert.severity == 'high' ? iconColor.withValues(alpha: 0.4) : Colors.grey.shade200,
          width: alert.severity == 'high' ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (alert.actionRoute != null && alert.actionRoute!.isNotEmpty) {
              context.go(alert.actionRoute!);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: cardColor,
                  radius: 22,
                  child: Icon(iconData, color: iconColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              isMr ? alert.titleMr : alert.titleEn,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                          if (alert.severity == 'high')
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isMr ? 'महत्त्वाचे' : 'URGENT',
                                style: TextStyle(color: Colors.red.shade900, fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isMr ? alert.messageMr : alert.messageEn,
                        style: const TextStyle(fontSize: 12, color: Colors.black87, height: 1.4),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            dateFormat.format(alert.createdAt),
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                          if (alert.actionRoute != null)
                            Row(
                              children: [
                                Text(
                                  isMr ? 'तपासा' : 'View',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: iconColor),
                                ),
                                Icon(Icons.chevron_right_rounded, size: 16, color: iconColor),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
