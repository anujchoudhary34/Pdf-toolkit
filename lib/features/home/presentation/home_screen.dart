import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/routing/app_router.dart';
import 'widgets/tool_grid_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.picture_as_pdf, color: Color(0xFFBA1A1A)),
            const SizedBox(width: AppSpacing.sm),
            Text(
              AppConstants.appName,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF0D652D).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.verified_user,
                      size: 12, color: Color(0xFF0D652D)),
                  const SizedBox(width: 4),
                  Text(
                    'Offline • Secure',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: const Color(0xFF0D652D),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Document Engine',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.itemGap,
              mainAxisSpacing: AppSpacing.itemGap,
              childAspectRatio: 1.1,
              children: [
                ToolGridCard(
                  title: 'Images → PDF',
                  subtitle: 'Convert photos & scans to document',
                  icon: Icons.photo_library,
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.imagesToPdf),
                ),
                ToolGridCard(
                  title: 'Merge PDF',
                  subtitle: 'Combine multiple PDFs into one',
                  icon: Icons.call_merge,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.mergePdf),
                ),
                ToolGridCard(
                  title: 'Split PDF',
                  subtitle: 'Extract pages or split into parts',
                  icon: Icons.call_split,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.splitPdf),
                ),
                ToolGridCard(
                  title: 'PDF → Images',
                  subtitle: 'Export pages as PNG/JPG',
                  icon: Icons.image,
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.pdfToImages),
                ),
                ToolGridCard(
                  title: 'Compress PDF',
                  subtitle: 'Reduce file size with smart quality',
                  icon: Icons.compress,
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.compressPdf),
                ),
                ToolGridCard(
                  title: 'Manage Pages',
                  subtitle: 'Reorder, rotate, or delete pages',
                  icon: Icons.view_module,
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.managePages),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
