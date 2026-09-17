sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

class CorruptedPdfException extends AppException {
  const CorruptedPdfException(
      [super.message = 'The PDF file appears to be corrupted or invalid.']);
}

class PasswordProtectedPdfException extends AppException {
  const PasswordProtectedPdfException(
      [super.message =
          'Password-protected PDFs require unlocking before processing.']);
}

class InsufficientStorageException extends AppException {
  const InsufficientStorageException(
      [super.message = 'Device is low on storage to complete this task.']);
}

class FileAccessDeniedException extends AppException {
  const FileAccessDeniedException(
      [super.message = 'File access permission was denied.']);
}

class UnsupportedFileTypeException extends AppException {
  const UnsupportedFileTypeException(
      [super.message = 'The selected file type is not supported.']);
}

class OperationCancelledException extends AppException {
  const OperationCancelledException(
      [super.message = 'The operation was cancelled by the user.']);
}

class UnknownAppException extends AppException {
  const UnknownAppException([super.message = 'An unexpected error occurred.']);
}
