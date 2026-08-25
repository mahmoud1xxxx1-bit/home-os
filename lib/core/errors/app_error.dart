class AppError implements Exception {
  const AppError([this.messageKey = 'genericError']);

  final String messageKey;
}
