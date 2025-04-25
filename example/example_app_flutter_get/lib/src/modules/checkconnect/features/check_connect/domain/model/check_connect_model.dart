final class CheckConnectModel {
  final bool connect;
  final String typeConect;
  CheckConnectModel({
    required this.connect,
    required this.typeConect,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CheckConnectModel &&
        other.connect == connect &&
        other.typeConect == typeConect;
  }

  @override
  int get hashCode => connect.hashCode ^ typeConect.hashCode;

  @override
  String toString() =>
      'CheckConnectModel(connect: $connect, typeConect: $typeConect)';
}
