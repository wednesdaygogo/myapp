class FormValidators {
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) return '姓名不能为空';
    if (value.trim().length < 2) return '姓名至少需要2个字符';
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return null;
    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(value)) return '请输入有效手机号';
    return null;
  }

  static String? validateBirthDate(DateTime? value) {
    if (value != null && value.isAfter(DateTime.now())) return '出生日期不能是未来';
    return null;
  }
}
