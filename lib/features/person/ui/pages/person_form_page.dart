import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/person_provider.dart';
import '../../../../data/models/person.dart';

class PersonFormPage extends ConsumerStatefulWidget {
  final int? personId;
  const PersonFormPage({super.key, this.personId});

  @override
  ConsumerState<PersonFormPage> createState() => _PersonFormPageState();
}

class _PersonFormPageState extends ConsumerState<PersonFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _gender;
  String? _relationship;
  DateTime? _birthDate;

  @override
  void initState() {
    super.initState();
    if (widget.personId != null) {
      Future.microtask(() {
        ref.read(selectedPersonIdProvider.notifier).state = widget.personId;
        final person = ref.read(selectedPersonProvider);
        if (person != null) {
          _nameController.text = person.name;
          _phoneController.text = person.phone ?? '';
          _gender = person.gender;
          _relationship = person.relationship;
          _birthDate = person.birthDate;
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    final person = Person(
      id: widget.personId ?? 0,
      name: _nameController.text,
      gender: _gender,
      birthDate: _birthDate,
      phone: _phoneController.text.isEmpty ? null : _phoneController.text,
      relationship: _relationship,
    );

    await ref.read(personsProvider.notifier).savePerson(person);

    if (!mounted) return;
    context.go('/persons');
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.personId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '编辑家人' : '新增家人'),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: AppTheme.textPrimary,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          children: [
            _buildSectionTitle('基本信息'),
            const SizedBox(height: AppTheme.spacingMd),
            _buildTextField(
              controller: _nameController,
              label: '姓名',
              required: true,
              validator: (v) => v?.isEmpty == true ? '必填' : null,
            ),
            const SizedBox(height: AppTheme.spacingMd),
            _buildDropdownField(
              value: _gender,
              label: '性别',
              items: ['男', '女', '其他'],
              onChanged: (v) => setState(() => _gender = v),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            _buildDateField(
              label: '出生日期',
              selectedDate: _birthDate,
              onTap: _selectDate,
            ),
            const SizedBox(height: AppTheme.spacingLg),
            _buildSectionTitle('联系方式'),
            const SizedBox(height: AppTheme.spacingMd),
            _buildTextField(
              controller: _phoneController,
              label: '电话',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: AppTheme.spacingMd),
            _buildDropdownField(
              value: _relationship,
              label: '与本人的关系',
              items: ['本人', '配偶', '父亲', '母亲', '子女', '其他'],
              onChanged: (v) => setState(() => _relationship = v),
            ),
            const SizedBox(height: AppTheme.spacingXl),
            ElevatedButton(
              onPressed: _saveForm,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppTheme.textSecondary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool required = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String label,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
      items:
          items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? selectedDate,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
          vertical: AppTheme.spacingMd,
        ),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppTheme.borderColor, width: 0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedDate == null ? '选择日期' : _formatDate(selectedDate),
              style: TextStyle(
                fontSize: 16,
                color: selectedDate == null
                    ? AppTheme.textTertiary
                    : AppTheme.textPrimary,
              ),
            ),
            const Icon(
              Icons.calendar_today,
              size: 20,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
