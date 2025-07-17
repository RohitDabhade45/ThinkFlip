import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/auth_view_model.dart';
import '../models/scan_view_model.dart';
import '../theme_provider.dart';
import 'login_screen.dart';
import 'detail_text_view.dart';
import 'document_scanner_view.dart';
import 'history_view.dart';
import 'enter_text_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 80,
        title: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: colorScheme.primary,
              child: Text(
                (authVM.user?.name ?? 'U')[0].toUpperCase(),
                style: TextStyle(color: colorScheme.onPrimary, fontSize: 20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Welcome, ${authVM.user?.name ?? "User"}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
        actions: [
          Switch(
            value: themeProvider.isDarkMode,
            onChanged: themeProvider.toggleTheme,
            activeColor: colorScheme.primary,
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'History',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryView()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await authVM.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Quick Actions
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.document_scanner_outlined,
                    label: 'Scan Document',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DocumentScannerView(
                          onScanned: (scannedImages) {
                            Provider.of<ScanViewModel>(context, listen: false)
                                .processScannedImages(scannedImages);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.text_fields,
                    label: 'Enter Text',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EnterTextView()),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Documents',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                IconButton(
                  icon: const Icon(Icons.sort),
                  tooltip: 'Sort documents',
                  onPressed: () {
                    final scanViewModel = context.read<ScanViewModel>();
                    showMenu(
                      context: context,
                      position: RelativeRect.fromLTRB(
                        MediaQuery.of(context).size.width - 100,
                        kToolbarHeight + 120,
                        16,
                        0,
                      ),
                      items: [
                        PopupMenuItem(
                          value: SortOption.dateNewest,
                          child: Row(
                            children: [
                              Icon(
                                Icons.check,
                                color: scanViewModel.currentSort == SortOption.dateNewest
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.transparent,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              const Text('Newest First'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: SortOption.dateOldest,
                          child: Row(
                            children: [
                              Icon(
                                Icons.check,
                                color: scanViewModel.currentSort == SortOption.dateOldest
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.transparent,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              const Text('Oldest First'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: SortOption.nameAZ,
                          child: Row(
                            children: [
                              Icon(
                                Icons.check,
                                color: scanViewModel.currentSort == SortOption.nameAZ
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.transparent,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              const Text('Name A-Z'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: SortOption.nameZA,
                          child: Row(
                            children: [
                              Icon(
                                Icons.check,
                                color: scanViewModel.currentSort == SortOption.nameZA
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.transparent,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              const Text('Name Z-A'),
                            ],
                          ),
                        ),
                      ],
                    ).then((value) {
                      if (value != null) {
                        scanViewModel.sortDocuments(value);
                      }
                    });
                  },
                ),
              ],
            ),

            Expanded(
              child: Consumer<ScanViewModel>(
                builder: (context, svm, child) {
                  if (svm.allScannedDocs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.description_outlined,
                              size: 64, color: colorScheme.outline),
                          const SizedBox(height: 16),
                          Text(
                            "No scanned documents yet",
                            style: TextStyle(
                              fontSize: 16,
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: svm.allScannedDocs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final doc = svm.allScannedDocs[index];
                      return Card(
                        elevation: 2,
                        surfaceTintColor: colorScheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Icon(Icons.description_outlined,
                              color: colorScheme.primary),
                          title: Text(
                            doc.text,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            DateFormat.yMMMd().add_jm().format(doc.dateScanned),
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailTextView(
                                  myDetailedText: doc.text,
                                  imagePath: doc.imagePath,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        surfaceTintColor: colorScheme.surfaceVariant,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                backgroundColor: colorScheme.primary.withOpacity(0.1),
                child: Icon(icon, color: colorScheme.primary),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: Theme.of(context).textTheme.titleSmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
