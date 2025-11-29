class AirtimeRequest {
  final String network;
  final double amount;

  AirtimeRequest({
    required this.network,
    required this.amount,
  });

  Map<String, dynamic> toJson() {
    return {
      'network': network,
      'amount': amount,
    };
  }
}
