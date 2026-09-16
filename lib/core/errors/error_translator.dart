import 'app_exceptions.dart';

class ErrorDisplayInfo {
  final String title;
  final String explanation;
  final String primaryActionLabel;
  final String? secondaryActionLabel;

  const ErrorDisplayInfo({
    required this.title,
    required this.explanation,
    required this.primaryActionLabel,
    this.secondaryActionLabel,
  });
}

class ErrorTranslator {
  static ErrorDisplayInfo translate(Object error) {
    if (error is CorruptedPdfException) {
      return const ErrorDisplayInfo(
        title: 'Unable to process document',
        explanation:
            'This PDF file has a corrupted cross-reference table or unreadable content.',
        primaryActionLabel: 'Try Another File',
      );
    } else if (error is PasswordProtectedPdfException) {
      return const ErrorDisplayInfo(
        title: 'Encrypted PDF Document',
        explanation:
            'Password-protected PDFs require unlocking before merging or editing.',
        primaryActionLabel: 'Unlock File',
        secondaryActionLabel: 'Try Another File',
      );
    } else if (error is InsufficientStorageException) {
      return const ErrorDisplayInfo(
        title: 'Low Storage Warning',
        explanation:
            'Device low on storage. Free up space to complete conversion.',
        primaryActionLabel: 'Retry Operation',
      );
    } else if (error is FileAccessDeniedException) {
      return const ErrorDisplayInfo(
        title: 'Permission Denied',
        explanation: 'Access to the requested file or directory was denied.',
        primaryActionLabel: 'Grant Access',
      );
    } else if (error is UnsupportedFileTypeException) {
      return const ErrorDisplayInfo(
        title: 'Unsupported File Type',
        explanation: 'The selected file extension or format is not supported.',
        primaryActionLabel: 'Select Supported File',
      );
    } else if (error is OperationCancelledException) {
      return const ErrorDisplayInfo(
        title: 'Operation Cancelled',
        explanation: 'The current job was stopped by the user.',
        primaryActionLabel: 'Start Over',
      );
    } else {
      return ErrorDisplayInfo(
        title: 'Unexpected Error',
        explanation: error is AppException
            ? error.message
            : 'An unexpected error occurred while processing.',
        primaryActionLabel: 'Try Again',
      );
    }
  }
}
