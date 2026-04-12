import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/crayon_theme.dart';
import '../../../../core/widgets/crayon_background.dart';
import '../../../../core/widgets/crayon_card.dart';
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
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入姓名')),
      );
      return;
    }

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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isEditing ? '编辑家人' : '新增家人'),
            const SizedBox(width: 8),
            Icon(Icons.edit, size: 20, color: CrayonTheme.forestGreen),
          ],
        ),
        centerTitle: true,
        foregroundColor: CrayonTheme.darkBrown,
        elevation: 0,
      ),
      body: CrayonBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(CrayonTheme.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar Section
              CrayonCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.face, color: CrayonTheme.forestGreen, size: 20),
                        const SizedBox(width: 8),
                        Text('选择头像', style: const TextStyle(
                          color: CrayonTheme.darkBrown,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        )),
                      ],
                    ),
                    const SizedBox(height: CrayonTheme.spacingMd),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: PresetAvatars.names.map((name) {
                        final isSelected = _selectedAvatar == name;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedAvatar = name),
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: isSelected ? CrayonTheme.forestGreen.withValues(alpha: 0.15) : CrayonTheme.creamWhite,
                              borderRadius: BorderRadius.circular(CrayonTheme.radiusMd),
                              border: Border.all(
                                color: isSelected ? CrayonTheme.forestGreen : CrayonTheme.darkBrown.withValues(alpha: 0.3),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                PresetAvatars.iconMap[name] ?? Icons.person,
                                size: 30,
                                color: PresetAvatars.colorMap[name] ?? CrayonTheme.darkBrown,
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

              // Name Input
              _buildInputCard(
                icon: Icons.person,
                label: '姓名',
                isRequired: true,
                child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: '请输入姓名',
                    hintStyle: TextStyle(color: CrayonTheme.darkBrown.withValues(alpha: 0.4)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(color: CrayonTheme.darkBrown, fontSize: 16),
                ),
              ),
              const SizedBox(height: CrayonTheme.spacingMd),

              // Gender Selection
              _buildSelectionCard(
                icon: Icons.wc,
                label: '性别',
                value: _gender,
                placeholder: '请选择',
                onTap: () => _showGenderPicker(),
              ),
              const SizedBox(height: CrayonTheme.spacingMd),

              // Birth Date
              _buildSelectionCard(
                icon: Icons.cake,
                label: '出生日期',
                value: _birthDate != null ? _formatDate(_birthDate!) : null,
                placeholder: '请选择',
                onTap: _selectDate,
              ),
              const SizedBox(height: CrayonTheme.spacingMd),

              // Phone Input
              _buildInputCard(
                icon: Icons.phone,
                label: '电话',
                isRequired: false,
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: '请输入电话号码',
                    hintStyle: TextStyle(color: CrayonTheme.darkBrown.withValues(alpha: 0.4)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(color: CrayonTheme.darkBrown, fontSize: 16),
                ),
              ),
              const SizedBox(height: CrayonTheme.spacingMd),

              // Relationship
              _buildSelectionCard(
                icon: Icons.family_restroom,
                label: '与本人的关系',
                value: _relationship,
                placeholder: '请选择',
                onTap: () => _showRelationshipPicker(),
              ),
              const SizedBox(height: CrayonTheme.spacingXl),

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

  Widget _buildInputCard({
    required IconData icon,
    required String label,
    required bool isRequired,
    required Widget child,
  }) {
    return CrayonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: CrayonTheme.forestGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(CrayonTheme.radiusSm),
                ),
                child: Icon(icon, size: 18, color: CrayonTheme.forestGreen),
              ),
              const SizedBox(width: 12),
              Text(label, style: const TextStyle(
                color: CrayonTheme.darkBrown,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              )),
              if (isRequired)
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Icon(Icons.edit, size: 12, color: CrayonTheme.forestGreen),
                ),
            ],
          ),
          const SizedBox(height: CrayonTheme.spacingSm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: CrayonTheme.spacingMd,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: CrayonTheme.creamWhite,
              borderRadius: BorderRadius.circular(CrayonTheme.radiusSm),
              border: Border.all(color: CrayonTheme.darkBrown.withValues(alpha: 0.4), width: 1.5),
            ),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionCard({
    required IconData icon,
    required String label,
    required String? value,
    required String placeholder,
    required VoidCallback onTap,
  }) {
    return CrayonCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: CrayonTheme.forestGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(CrayonTheme.radiusSm),
                ),
                child: Icon(icon, size: 18, color: CrayonTheme.forestGreen),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label, style: const TextStyle(
                  color: CrayonTheme.darkBrown,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                )),
              ),
            ],
          ),
          const SizedBox(height: CrayonTheme.spacingSm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: CrayonTheme.creamWhite,
              borderRadius: BorderRadius.circular(CrayonTheme.radiusSm),
              border: Border.all(color: CrayonTheme.darkBrown.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    value ?? placeholder,
                    style: TextStyle(
                      color: value != null ? CrayonTheme.darkBrown : CrayonTheme.darkBrown.withValues(alpha: 0.5),
                      fontSize: 14,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, size: 18, color: CrayonTheme.forestGreen),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showGenderPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: CrayonTheme.creamWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(CrayonTheme.radiusMd)),
      ),
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(CrayonTheme.spacingMd),
                child: Row(
                  children: [
                    Text('选择性别', style: const TextStyle(
                      color: CrayonTheme.darkBrown,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    )),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                      color: CrayonTheme.darkBrown,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ...['男', '女', '其他'].map((item) {
                final isSelected = item == _gender;
                return ListTile(
                  leading: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isSelected ? CrayonTheme.forestGreen.withValues(alpha: 0.15) : CrayonTheme.darkBrown.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(CrayonTheme.radiusSm),
                    ),
                    child: Icon(
                      item == '男' ? Icons.male : item == '女' ? Icons.female : Icons.transgender,
                      color: isSelected ? CrayonTheme.forestGreen : CrayonTheme.darkBrown.withValues(alpha: 0.5),
                      size: 18,
                    ),
                  ),
                  title: Text(item, style: TextStyle(
                    color: isSelected ? CrayonTheme.forestGreen : CrayonTheme.darkBrown,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  )),
                  trailing: isSelected ? const Icon(Icons.check, size: 18, color: CrayonTheme.forestGreen) : null,
                  onTap: () {
                    setState(() => _gender = item);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showRelationshipPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: CrayonTheme.creamWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(CrayonTheme.radiusMd)),
      ),
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(CrayonTheme.spacingMd),
                child: Row(
                  children: [
                    Text('选择关系', style: const TextStyle(
                      color: CrayonTheme.darkBrown,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    )),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                      color: CrayonTheme.darkBrown,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ...['本人', '配偶', '父亲', '母亲', '子女', '其他'].map((item) {
                final isSelected = item == _relationship;
                return ListTile(
                  leading: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isSelected ? CrayonTheme.forestGreen.withValues(alpha: 0.15) : CrayonTheme.darkBrown.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(CrayonTheme.radiusSm),
                    ),
                    child: Icon(
                      _getRelationshipIcon(item),
                      color: isSelected ? CrayonTheme.forestGreen : CrayonTheme.darkBrown.withValues(alpha: 0.5),
                      size: 18,
                    ),
                  ),
                  title: Text(item, style: TextStyle(
                    color: isSelected ? CrayonTheme.forestGreen : CrayonTheme.darkBrown,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  )),
                  trailing: isSelected ? const Icon(Icons.check, size: 18, color: CrayonTheme.forestGreen) : null,
                  onTap: () {
                    setState(() => _relationship = item);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getRelationshipIcon(String relationship) {
    switch (relationship) {
      case '本人': return Icons.person;
      case '配偶': return Icons.favorite;
      case '父亲': return Icons.man;
      case '母亲': return Icons.woman;
      case '子女': return Icons.child_care;
      default: return Icons.people;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}