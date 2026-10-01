enum BiologicalSex { female, male, unspecified }
class UserProfile {
  const UserProfile({required this.heightCm, required this.weightKg, required this.age, required this.sex, required this.activityFactor, required this.targetLossKgPerWeek});
  final double heightCm, weightKg, activityFactor, targetLossKgPerWeek;
  final int age;
  final BiologicalSex sex;
  double get bmi => weightKg / ((heightCm / 100) * (heightCm / 100));
  double get bmr {
    final base = 10 * weightKg + 6.25 * heightCm - 5 * age;
    return base + (sex == BiologicalSex.male ? 5 : sex == BiologicalSex.female ? -161 : -78);
  }
  double get maintenanceCalories => bmr * activityFactor;
  double get safeDailyCalories {
    final requestedDeficit = targetLossKgPerWeek.clamp(0, 0.75) * 1100;
    return (maintenanceCalories - requestedDeficit).clamp(1200, double.infinity).toDouble();
  }
}
