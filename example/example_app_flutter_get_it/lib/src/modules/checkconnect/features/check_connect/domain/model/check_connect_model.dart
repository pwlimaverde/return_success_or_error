final class CheckConnecModel {
  final bool connect;
  final String typeConect;
  CheckConnecModel({
    required this.connect,
    required this.typeConect,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CheckConnecModel &&
        other.connect == connect &&
        other.typeConect == typeConect;
  }

  @override
  int get hashCode => connect.hashCode ^ typeConect.hashCode;

  @override
  String toString() =>
      'CheckConnecModel(connect: $connect, typeConect: $typeConect)';
}
