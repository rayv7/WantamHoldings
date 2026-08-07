class TransactionModel {
  const TransactionModel({
    required this.type,
    required this.merchant,
    required this.date,
    required this.time,
    required this.amount,
    required this.status,
  });

  final String type;
  final String merchant;
  final String date;
  final String time;
  final String amount;
  final String status;
}
