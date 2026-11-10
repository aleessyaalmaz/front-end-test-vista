import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_provider.dart';
import '../widgets.dart';

class CreateCompanyScreen extends StatefulWidget {
  const CreateCompanyScreen({super.key});

  @override
  State<CreateCompanyScreen> createState() => _CreateCompanyScreenState();
}

class _CreateCompanyScreenState extends State<CreateCompanyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _reg = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _reg.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final provider = context.read<AppProvider>();
    if (provider.isLoading || !_formKey.currentState!.validate()) return;
    final err =
        await provider.createCompany(_name.text.trim(), _reg.text.trim());
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(err ?? 'Company created')));
    if (err == null) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.select<AppProvider, bool>((p) => p.isLoading);
    return FormShell(
      title: 'New company',
      subtitle: 'Add a company, then attach services to it.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _name,
              autofocus: true,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Company name',
                prefixIcon: Icon(Icons.business_outlined),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _reg,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              decoration: const InputDecoration(
                labelText: 'Registration number',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Registration number is required'
                  : null,
            ),
            const SizedBox(height: 24),
            SubmitButton(
              label: 'Create company',
              loading: loading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}