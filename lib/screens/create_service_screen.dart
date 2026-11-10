import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../app_provider.dart';
import '../widgets.dart';

class CreateServiceScreen extends StatefulWidget {
  const CreateServiceScreen({super.key});

  @override
  State<CreateServiceScreen> createState() => _CreateServiceScreenState();
}

class _CreateServiceScreenState extends State<CreateServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _desc = TextEditingController();
  final _price = TextEditingController();
  int? _companyId;

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    _price.dispose();
    super.dispose();
  }

  String? _required(String? v, String label) =>
      (v == null || v.trim().isEmpty) ? '$label is required' : null;

  Future<void> _submit() async {
    final provider = context.read<AppProvider>();
    if (provider.isLoading || !_formKey.currentState!.validate()) return;
    final err = await provider.createService(
      _companyId!,
      _name.text.trim(),
      _desc.text.trim(),
      double.parse(_price.text.trim()),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(err ?? 'Service created')));
    if (err == null) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    return FormShell(
      title: 'New service',
      subtitle: 'Create a service and choose the company it belongs to.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<int>(
              initialValue: _companyId,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Company',
                prefixIcon: Icon(Icons.apartment_outlined),
              ),
              items: p.companies
                  .map((c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(c.name, overflow: TextOverflow.ellipsis),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _companyId = v),
              validator: (v) => v == null ? 'Select a company' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _name,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Service name',
                prefixIcon: Icon(Icons.room_service_outlined),
              ),
              validator: (v) => _required(v, 'Name'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _desc,
              minLines: 3,
              maxLines: 5,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Description',
                alignLabelWithHint: true,
              ),
              validator: (v) => _required(v, 'Description'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _price,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              decoration: const InputDecoration(
                labelText: 'Price',
                prefixText: 'RM ',
                prefixIcon: Icon(Icons.payments_outlined),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Price is required';
                final n = double.tryParse(v.trim());
                if (n == null) return 'Price must be a number';
                if (n <= 0) return 'Price must be greater than 0';
                return null;
              },
            ),
            const SizedBox(height: 24),
            SubmitButton(
              label: 'Create service',
              loading: p.isLoading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}