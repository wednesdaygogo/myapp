import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:isar/isar.dart';
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
        final person = ref.read(selectedPersonProvider).value;
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

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    final person = Person()
      ..id = widget.personId ?? Isar.autoIncrement
      ..name = _nameController.text
      ..gender = _gender
      ..birthDate = _birthDate
      ..phone = _phoneController.text.isEmpty ? null : _phoneController.text
      ..relationship = _relationship;

    await ref.read(personNotifierProvider.notifier).createPerson(person);

    if (!mounted) return;
    context.go('/persons');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.personId == null ? '新增家人' : '编辑家人')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: '姓名 *'),
                validator: (v) => v?.isEmpty == true ? '必填' : null),
            DropdownButtonFormField<String>(
                initialValue: _gender,
                items: ['男', '女', '其他']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _gender = v),
                decoration: const InputDecoration(labelText: '性别')),
            ListTile(
                title: Text(_birthDate == null
                    ? '选择出生日期'
                    : _birthDate.toString().split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                      context: context,
                      initialDate: _birthDate ?? DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now());
                  if (picked != null) setState(() => _birthDate = picked);
                }),
            TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: '电话'),
                keyboardType: TextInputType.phone),
            DropdownButtonFormField<String>(
                initialValue: _relationship,
                items: ['本人', '配偶', '父亲', '母亲', '子女', '其他']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _relationship = v),
                decoration: const InputDecoration(labelText: '关系')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _saveForm, child: const Text('保存')),
          ],
        ),
      ),
    );
  }
}
