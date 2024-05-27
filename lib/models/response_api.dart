class ResponseAPI {
  bool success;
  int? code;
  String message;
  dynamic data;
  ResponseAPI(
    this.success,
    this.code,
    this.message,
    this.data,
  );
}
