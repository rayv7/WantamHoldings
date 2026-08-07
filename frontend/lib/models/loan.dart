class LoanModel {
  const LoanModel({
    required this.eligibilityStatus,
    required this.maxLoanAmount,
    required this.interestRate,
    required this.maxRepaymentPeriod,
    required this.activeLoan,
    required this.loanHistory,
  });

  final String eligibilityStatus;
  final String maxLoanAmount;
  final String interestRate;
  final String maxRepaymentPeriod;
  final ActiveLoan? activeLoan;
  final List<LoanHistoryItem> loanHistory;
}

class ActiveLoan {
  const ActiveLoan({
    required this.type,
    required this.originalAmount,
    required this.outstandingBalance,
    required this.monthlyInstallment,
    required this.nextPayment,
    required this.status,
  });

  final String type;
  final String originalAmount;
  final String outstandingBalance;
  final String monthlyInstallment;
  final String nextPayment;
  final String status;
}

class LoanHistoryItem {
  const LoanHistoryItem({
    required this.type,
    required this.amount,
    required this.issuedDate,
    required this.status,
  });

  final String type;
  final String amount;
  final String issuedDate;
  final String status;
}
