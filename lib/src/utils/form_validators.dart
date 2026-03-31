class FormValidators {
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Name is required';
    return null;
  }

  static String? validateAge(int? age) {
    if (age == null || age < 0) return 'Invalid age';
    return null;
  }
}
