import 'package:flutter/material.dart';

class AppRoutes {
  static const String home = '/';
  static const String recentFiles = '/recent_files';
  static const String settings = '/settings';
  static const String imagesToPdf = '/images_to_pdf';
  static const String mergePdf = '/merge_pdf';
  static const String splitPdf = '/split_pdf';
  static const String pdfToImages = '/pdf_to_images';
  static const String compressPdf = '/compress_pdf';
  static const String managePages = '/manage_pages';

  static Route<dynamic> onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => const PlaceholderScreen(title: 'Home'),
        );
      case recentFiles:
        return MaterialPageRoute(
          builder: (_) => const PlaceholderScreen(title: 'Recent Files'),
        );
      case settings:
        return MaterialPageRoute(
          builder: (_) => const PlaceholderScreen(title: 'Settings'),
        );
      case imagesToPdf:
        return MaterialPageRoute(
          builder: (_) => const PlaceholderScreen(title: 'Images → PDF'),
        );
      case mergePdf:
        return MaterialPageRoute(
          builder: (_) => const PlaceholderScreen(title: 'Merge PDF'),
        );
      case splitPdf:
        return MaterialPageRoute(
          builder: (_) => const PlaceholderScreen(title: 'Split PDF'),
        );
      case pdfToImages:
        return MaterialPageRoute(
          builder: (_) => const PlaceholderScreen(title: 'PDF → Images'),
        );
      case compressPdf:
        return MaterialPageRoute(
          builder: (_) => const PlaceholderScreen(title: 'Compress PDF'),
        );
      case managePages:
        return MaterialPageRoute(
          builder: (_) => const PlaceholderScreen(title: 'Manage Pages'),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route not found: ${routeSettings.name}'),
            ),
          ),
        );
    }
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text(
          '$title Placeholder Screen',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}
