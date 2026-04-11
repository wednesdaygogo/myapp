import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/crayon_theme.dart';
import '../../../../core/widgets/crayon_background.dart';
import '../../../../core/widgets/crayon_card.dart';
import '../../../../core/widgets/crayon_input.dart';
import '../../../../core/widgets/crayon_button.dart';
import '../../../../core/widgets/crayon_avatar.dart';
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
  String? _selectedAvatar;

  @override
  void initState() {
    super.initState();
    if (widget.personId != null) {
      Future.microtask(() {
        if (!mounted) return;
        ref.read(selectedPersonIdProvider.notifier).state = widget.personId;
        final person = ref.read(selectedPersonProvider);
        if (person != null) {
          _nameController.text = person.name;
          _phoneController.text = person.phone ?? '';
          _gender = person.gender;
          _relationship = person.relationship;
          _birthDate = person.birthDate;
          _selectedAvatar = person.photoPath;
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
      photoPath: _selectedAvatar,
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
      backgroundColor: CrayonTheme.creamWhite,
      appBar: AppBar(
        backgroundColor: CrayonTheme.creamWhite,
        title: Text(isEditing ? '编辑家人 ✏️' : '新增家人 ✏️'),
        centerTitle: true,
        foregroundColor: CrayonTheme.darkBrown,
      ),
      body: CrayonBackground(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(CrayonTheme.spacingMd),
            children: [
              // Avatar Selector
              CrayonCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('选择头像 🎨', style: CrayonTheme.crayonTextTheme.titleMedium),
                    const SizedBox(height: CrayonTheme.spacingMd),
                    Wrap(
                      spacing: CrayonTheme.spacingSm,
                      runSpacing: CrayonTheme.spacingSm,
                      children: PresetAvatars.names.map((name) {
                        final isSelected = _selectedAvatar == name;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedAvatar = name),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(CrayonTheme.radiusSm),
                              border: isSelected
                                  ? Border.all(color: CrayonTheme.forestGreen, width: 2)
                                  : Border.all(color: CrayonTheme.darkBrown.withValues(alpha: 0.3), width: 1),
                            ),
                            child: Center(
                              child: Text(
                                PresetAvatars.emojiMap[name]!,
                                style: const TextStyle(fontSize: 28),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: CrayonTheme.spacingMd),

              // Basic Info
              CrayonCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('📋 基本信息', style: CrayonTheme.crayonTextTheme.titleMedium),
                    const SizedBox(height: CrayonTheme.spacingMd),
                    CrayonInput(
                      label: '姓名',
                      controller: _nameController,
                      isRequired: true,
                      validator: (v) => v?.isEmpty == true ? '姓名不能为空' : null,
                    ),
                    const SizedBox(height: CrayonTheme.spacingMd),
                    _buildDropdownRow('性别', ['男', '女', '其他'], _gender, (v) => setState(() => _gender = v)),
                    const SizedBox(height: CrayonTheme.spacingMd),
                    _buildDateRow('出生日期', _birthDate, _selectDate),
                  ],
                ),
              ),
              const SizedBox(height: CrayonTheme.spacingMd),

              // Contact & Relationship
              CrayonCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('📞 其他信息', style: CrayonTheme.crayonTextTheme.titleMedium),
                    const SizedBox(height: CrayonTheme.spacingMd),
                    CrayonInput(
                      label: '电话',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: CrayonTheme.spacingMd),
                    _buildDropdownRow('与本人的关系', ['本人', '配偶', '父亲', '母亲', '子女', '其他'], _relationship, (v) => setState(() => _relationship = v)),
                  ],
                ),
              ),
              const SizedBox(height: CrayonTheme.spacingLg),

              // Save Button
              CrayonButton(
                text: '保存',
                icon: Icons.save,
                onPressed: _saveForm,
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownRow(String label, List<String> items, String? value, ValueChanged<String?> onChanged) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: CrayonTheme.forestGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(CrayonTheme.radiusSm),
          ),
          child: const Icon(Icons.arrow_drop_down, size: 18, color: CrayonTheme.forestGreen),
        ),
        const SizedBox(width: CrayonTheme.spacingMd),
        Text(label, style: TextStyle(color: CrayonTheme.darkBrown.withValues(alpha: 0.7))),
        const Spacer(),
        GestureDetector(
          onTap: () => _showDropdown(label, items, value, onChanged),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: CrayonTheme.spacingSm, vertical: CrayonTheme.spacingSm),
            decoration: BoxDecoration(
              color: CrayonTheme.creamWhite,
              borderRadius: BorderRadius.circular(CrayonTheme.radiusSm),
              border: Border.all(color: CrayonTheme.darkBrown.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(value ?? '请选择', style: const TextStyle(color: CrayonTheme.darkBrown)),
                const SizedBox(width: 4),
                const Icon(Icons.unfold_more, size: 16, color: CrayonTheme.forestGreen),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showDropdown(String label, List<String> items, String? value, ValueChanged<String?> onChanged) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: CrayonTheme.creamWhite,
        title: Text(label, style: const TextStyle(color: CrayonTheme.darkBrown)),
        content: SizedBox(
          width: double.minPositive,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final isSelected = item == value;
              return ListTile(
                title: Text(item, style: TextStyle(
                  color: isSelected ? CrayonTheme.forestGreen : CrayonTheme.darkBrown,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                )),
                trailing: isSelected ? const Text('✨') : null,
                onTap: () {
                  onChanged(item);
                  Navigator.pop(ctx);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDateRow(String label, DateTime? selectedDate, VoidCallback onTap) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: CrayonTheme.forestGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(CrayonTheme.radiusSm),
          ),
          child: const Icon(Icons.calendar_today, size: 18, color: CrayonTheme.forestGreen),
        ),
        const SizedBox(width: CrayonTheme.spacingMd),
        Text(label, style: TextStyle(color: CrayonTheme.darkBrown.withValues(alpha: 0.7))),
        const Spacer(),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: CrayonTheme.spacingSm, vertical: CrayonTheme.spacingSm),
            decoration: BoxDecoration(
              color: CrayonTheme.creamWhite,
              borderRadius: BorderRadius.circular(CrayonTheme.radiusSm),
              border: Border.all(color: CrayonTheme.darkBrown.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selectedDate == null ? '选择日期' : _formatDate(selectedDate),
                  style: const TextStyle(color: CrayonTheme.darkBrown),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.unfold_more, size: 16, color: CrayonTheme.forestGreen),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}