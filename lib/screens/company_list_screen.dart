import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_provider.dart';
import 'create_company_screen.dart';
import 'create_service_screen.dart';

class CompanyListScreen extends StatelessWidget {
  const CompanyListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    Widget body;

    if (p.isLoading && p.companies.isEmpty) {
      body = const Center(child: CircularProgressIndicator());
    } else if (p.error != null) {
      body = Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(p.error!),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: p.loadCompanies, child: const Text('Retry')),
        ]),
      );
    } else if (p.companies.isEmpty) {
      body = const Center(child: Text('No companies yet'));
    } else {
      body = RefreshIndicator(
        onRefresh: p.loadCompanies,
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 150),
          itemCount: p.companies.length,
          itemBuilder: (_, i) {
            final c = p.companies[i];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ExpansionTile(
                title: Text(c.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(c.registrationNumber),
                children: c.services.isEmpty
                    ? [const ListTile(title: Text('No services'))]
                    : c.services
                        .map((s) => ListTile(
                              title: Text(s.name),
                              subtitle: Text(s.description),
                              trailing: Text('RM ${s.price.toStringAsFixed(2)}'),
                            ))
                        .toList(),
              ),
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Companies')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: body,
        ),
      ),
      floatingActionButton: Column(mainAxisSize: MainAxisSize.min, children: [
        FloatingActionButton.extended(
          heroTag: 'svc',
          icon: const Icon(Icons.build),
          label: const Text('Add Service'),
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const CreateServiceScreen())),
        ),
        const SizedBox(height: 8),
        FloatingActionButton.extended(
          heroTag: 'co',
          icon: const Icon(Icons.business),
          label: const Text('Add Company'),
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const CreateCompanyScreen())),
        ),
      ]),
    );
  }
}