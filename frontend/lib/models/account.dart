class AccountModel {
  const AccountModel({
    required this.customerName,
    required this.accountNumber,
    required this.accountType,
    required this.branchName,
    required this.availableBalance,
    required this.currentBalance,
    required this.status,
    required this.openedOn,
  });

  final String customerName;
  final String accountNumber;
  final String accountType;
  final String branchName;
  final String availableBalance;
  final String currentBalance;
  final String status;
  final String openedOn;
}
