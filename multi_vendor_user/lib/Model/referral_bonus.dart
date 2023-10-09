class ReferralBonusModel {
  final num referralBonus;
  final String fullname;
  final bool claim;

  ReferralBonusModel({
    required this.referralBonus,
    required this.fullname,
    required this.claim,
  });

  ReferralBonusModel.fromMap(
    Map<String, dynamic> data,
    id,
  )   : referralBonus = data['Referral Bonus'],
        fullname = data['Referred'],
        claim = data['Claim Bonus'];
}
