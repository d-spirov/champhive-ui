class MoneyAmount {
  const MoneyAmount(this.value, this.currency);

  final double value;
  final String currency;

  String get formatted {
    final fixed = value.toStringAsFixed(2);
    if (currency.isEmpty) return fixed;
    return '$fixed $currency';
  }

  static double parse(Object? raw) {
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw) ?? 0;
    return 0;
  }
}

class PaymentCopyBlock {
  const PaymentCopyBlock({
    required this.key,
    required this.label,
    required this.value,
  });

  final String key;
  final String label;
  final String value;

  factory PaymentCopyBlock.fromJson(Map<String, dynamic> json) {
    return PaymentCopyBlock(
      key: json['key'] as String? ?? '',
      label: json['label'] as String? ?? '',
      value: json['value'] as String? ?? '',
    );
  }
}

class PaymentInstruction {
  const PaymentInstruction({
    required this.railCode,
    required this.qrSupported,
    required this.reference,
    required this.amount,
    required this.currency,
    required this.copyBlocks,
    this.qrPayload,
  });

  final String railCode;
  final bool qrSupported;
  final String? qrPayload;
  final String reference;
  final double amount;
  final String currency;
  final List<PaymentCopyBlock> copyBlocks;

  factory PaymentInstruction.fromJson(Map<String, dynamic> json) {
    final blocks = <PaymentCopyBlock>[];
    final raw = json['copyBlocks'];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map) {
          blocks.add(PaymentCopyBlock.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }
    return PaymentInstruction(
      railCode: json['railCode'] as String? ?? '',
      qrSupported: json['qrSupported'] as bool? ?? false,
      qrPayload: json['qrPayload'] as String?,
      reference: json['reference'] as String? ?? '',
      amount: MoneyAmount.parse(json['amount']),
      currency: json['currency'] as String? ?? '',
      copyBlocks: blocks,
    );
  }
}

class FeeObligation {
  const FeeObligation({
    required this.id,
    required this.clubId,
    required this.memberId,
    required this.period,
    required this.description,
    required this.amount,
    required this.settledAmount,
    required this.outstandingAmount,
    required this.currency,
    required this.dueDate,
    required this.status,
    required this.generatedAtUtc,
    this.memberName,
    this.referenceNumber,
    this.isOverdue = false,
    this.paymentInstruction,
    this.updatedAtUtc,
  });

  final String id;
  final String clubId;
  final String memberId;
  final String? memberName;
  final String period;
  final String description;
  final double amount;
  final double settledAmount;
  final double outstandingAmount;
  final String currency;
  final DateTime? dueDate;
  final String status;
  final bool isOverdue;
  final String? referenceNumber;
  final DateTime generatedAtUtc;
  final DateTime? updatedAtUtc;
  final PaymentInstruction? paymentInstruction;

  bool get isOpen =>
      status == 'open' || status == 'partiallyPaid' || outstandingAmount > 0;

  String get moneyLabel => MoneyAmount(outstandingAmount, currency).formatted;

  factory FeeObligation.fromJson(Map<String, dynamic> json) {
    final instruction = json['paymentInstruction'];
    return FeeObligation(
      id: json['id']?.toString() ?? '',
      clubId: json['clubId']?.toString() ?? '',
      memberId: json['memberId']?.toString() ?? '',
      memberName: json['memberName'] as String?,
      period: json['period'] as String? ?? '',
      description: json['description'] as String? ?? '',
      amount: MoneyAmount.parse(json['amount']),
      settledAmount: MoneyAmount.parse(json['settledAmount']),
      outstandingAmount: MoneyAmount.parse(json['outstandingAmount']),
      currency: json['currency'] as String? ?? '',
      dueDate: DateTime.tryParse(json['dueDate'] as String? ?? ''),
      status: json['status'] as String? ?? '',
      isOverdue: json['isOverdue'] as bool? ?? false,
      referenceNumber: json['referenceNumber'] as String?,
      generatedAtUtc:
          DateTime.tryParse(json['generatedAtUtc'] as String? ?? '')?.toUtc() ??
              DateTime.now().toUtc(),
      updatedAtUtc:
          DateTime.tryParse(json['updatedAtUtc'] as String? ?? '')?.toUtc(),
      paymentInstruction: instruction is Map
          ? PaymentInstruction.fromJson(Map<String, dynamic>.from(instruction))
          : null,
    );
  }
}

class ObligationsPage {
  const ObligationsPage({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.totalOutstanding,
    required this.openCount,
    required this.currency,
  });

  final List<FeeObligation> items;
  final int page;
  final int pageSize;
  final int totalCount;
  final double totalOutstanding;
  final int openCount;
  final String currency;

  factory ObligationsPage.fromJson(Map<String, dynamic> json) {
    final items = <FeeObligation>[];
    final raw = json['items'];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map) {
          items.add(FeeObligation.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }
    return ObligationsPage(
      items: items,
      page: (json['page'] as num?)?.toInt() ?? 1,
      pageSize: (json['pageSize'] as num?)?.toInt() ?? 30,
      totalCount: (json['totalCount'] as num?)?.toInt() ?? items.length,
      totalOutstanding: MoneyAmount.parse(json['totalOutstanding']),
      openCount: (json['openCount'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String? ?? '',
    );
  }
}

class ClubPayment {
  const ClubPayment({
    required this.id,
    required this.clubId,
    required this.memberId,
    required this.memberName,
    required this.amount,
    required this.currency,
    required this.method,
    required this.paidOn,
    required this.recordedAtUtc,
    required this.isVoid,
    required this.isVoided,
    this.notes,
    this.recordedByName,
    this.allocations = const [],
  });

  final String id;
  final String clubId;
  final String memberId;
  final String memberName;
  final double amount;
  final String currency;
  final String method;
  final DateTime? paidOn;
  final String? notes;
  final String? recordedByName;
  final DateTime recordedAtUtc;
  final bool isVoid;
  final bool isVoided;
  final List<PaymentAllocation> allocations;

  String get moneyLabel => MoneyAmount(amount, currency).formatted;

  factory ClubPayment.fromJson(Map<String, dynamic> json) {
    final allocs = <PaymentAllocation>[];
    final raw = json['allocations'];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map) {
          allocs.add(PaymentAllocation.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }
    return ClubPayment(
      id: json['id']?.toString() ?? '',
      clubId: json['clubId']?.toString() ?? '',
      memberId: json['memberId']?.toString() ?? '',
      memberName: json['memberName'] as String? ?? '',
      amount: MoneyAmount.parse(json['amount']),
      currency: json['currency'] as String? ?? '',
      method: json['method'] as String? ?? '',
      paidOn: DateTime.tryParse(json['paidOn'] as String? ?? ''),
      notes: json['notes'] as String?,
      recordedByName: json['recordedByName'] as String?,
      recordedAtUtc:
          DateTime.tryParse(json['recordedAtUtc'] as String? ?? '')?.toUtc() ??
              DateTime.now().toUtc(),
      isVoid: json['isVoid'] as bool? ?? false,
      isVoided: json['isVoided'] as bool? ?? false,
      allocations: allocs,
    );
  }
}

class PaymentAllocation {
  const PaymentAllocation({
    required this.obligationId,
    required this.period,
    required this.description,
    required this.amount,
    required this.currency,
  });

  final String obligationId;
  final String period;
  final String description;
  final double amount;
  final String currency;

  factory PaymentAllocation.fromJson(Map<String, dynamic> json) {
    return PaymentAllocation(
      obligationId: json['obligationId']?.toString() ?? '',
      period: json['period'] as String? ?? '',
      description: json['description'] as String? ?? '',
      amount: MoneyAmount.parse(json['amount']),
      currency: json['currency'] as String? ?? '',
    );
  }
}

class PaymentsPage {
  const PaymentsPage({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalCount,
  });

  final List<ClubPayment> items;
  final int page;
  final int pageSize;
  final int totalCount;

  factory PaymentsPage.fromJson(Map<String, dynamic> json) {
    final items = <ClubPayment>[];
    final raw = json['items'];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map) {
          items.add(ClubPayment.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }
    return PaymentsPage(
      items: items,
      page: (json['page'] as num?)?.toInt() ?? 1,
      pageSize: (json['pageSize'] as num?)?.toInt() ?? 30,
      totalCount: (json['totalCount'] as num?)?.toInt() ?? items.length,
    );
  }
}

class FamilyMemberFees {
  const FamilyMemberFees({
    required this.memberId,
    required this.firstName,
    required this.lastName,
    required this.clubId,
    required this.clubName,
    required this.relationship,
    required this.totalOutstanding,
    required this.currency,
    required this.openObligations,
    this.referenceNumber,
  });

  final String memberId;
  final String firstName;
  final String lastName;
  final String clubId;
  final String clubName;
  final String relationship;
  final String? referenceNumber;
  final double totalOutstanding;
  final String currency;
  final List<FeeObligation> openObligations;

  String get displayName => '$firstName $lastName'.trim();

  factory FamilyMemberFees.fromJson(Map<String, dynamic> json) {
    final obs = <FeeObligation>[];
    final raw = json['openObligations'];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map) {
          obs.add(FeeObligation.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }
    return FamilyMemberFees(
      memberId: json['memberId']?.toString() ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      clubId: json['clubId']?.toString() ?? '',
      clubName: json['clubName'] as String? ?? '',
      relationship: json['relationship'] as String? ?? '',
      referenceNumber: json['referenceNumber'] as String?,
      totalOutstanding: MoneyAmount.parse(json['totalOutstanding']),
      currency: json['currency'] as String? ?? '',
      openObligations: obs,
    );
  }
}

class FamilyFees {
  const FamilyFees({
    required this.members,
    required this.totalOutstanding,
    required this.currency,
    required this.mixedCurrency,
    required this.asOfUtc,
  });

  final List<FamilyMemberFees> members;
  final double totalOutstanding;
  final String currency;
  final bool mixedCurrency;
  final DateTime asOfUtc;

  factory FamilyFees.fromJson(Map<String, dynamic> json) {
    final members = <FamilyMemberFees>[];
    final raw = json['members'];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map) {
          members.add(FamilyMemberFees.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }
    return FamilyFees(
      members: members,
      totalOutstanding: MoneyAmount.parse(json['totalOutstanding']),
      currency: json['currency'] as String? ?? '',
      mixedCurrency: json['mixedCurrency'] as bool? ?? false,
      asOfUtc: DateTime.tryParse(json['asOfUtc'] as String? ?? '')?.toUtc() ??
          DateTime.now().toUtc(),
    );
  }
}

class FamilyFeeHistory {
  const FamilyFeeHistory({
    required this.obligations,
    required this.payments,
    required this.page,
    required this.pageSize,
    required this.totalCount,
  });

  final List<FeeObligation> obligations;
  final List<ClubPayment> payments;
  final int page;
  final int pageSize;
  final int totalCount;

  factory FamilyFeeHistory.fromJson(Map<String, dynamic> json) {
    final obligations = <FeeObligation>[];
    final payments = <ClubPayment>[];
    final oRaw = json['obligations'];
    if (oRaw is List) {
      for (final e in oRaw) {
        if (e is Map) {
          obligations.add(FeeObligation.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }
    final pRaw = json['payments'];
    if (pRaw is List) {
      for (final e in pRaw) {
        if (e is Map) {
          // FamilyPaymentResponse is a subset — reuse ClubPayment parser.
          payments.add(ClubPayment.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }
    return FamilyFeeHistory(
      obligations: obligations,
      payments: payments,
      page: (json['page'] as num?)?.toInt() ?? 1,
      pageSize: (json['pageSize'] as num?)?.toInt() ?? 30,
      totalCount: (json['totalCount'] as num?)?.toInt() ?? obligations.length,
    );
  }
}
