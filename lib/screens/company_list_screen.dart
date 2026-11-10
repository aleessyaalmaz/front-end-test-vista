import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_provider.dart';
import '../models.dart';
import '../widgets.dart';
import 'create_company_screen.dart';
import 'create_service_screen.dart';

enum SortOption {
  nameAsc('A to Z'),
  nameDesc('Z to A'),
  newest('Newest first'),
  oldest('Oldest first');

  final String label;
  const SortOption(this.label);
}

class CompanyListScreen extends StatefulWidget {
  const CompanyListScreen({super.key});

  @override
  State<CompanyListScreen> createState() => _CompanyListScreenState();
}

class _CompanyListScreenState extends State<CompanyListScreen> {
  final _search = TextEditingController();
  String _query = '';
  SortOption _sort = SortOption.nameAsc;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  int _compare(Company a, Company b) => switch (_sort) {
        SortOption.nameAsc =>
          a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        SortOption.nameDesc =>
          b.name.toLowerCase().compareTo(a.name.toLowerCase()),
        SortOption.newest => b.id.compareTo(a.id),
        SortOption.oldest => a.id.compareTo(b.id),
      };

  void _open(Widget screen) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Companies'),
        actions: [
          PopupMenuButton<SortOption>(
            tooltip: 'Sort',
            icon: const Icon(Icons.sort),
            onSelected: (v) => setState(() => _sort = v),
            itemBuilder: (_) => SortOption.values
                .map((o) => CheckedPopupMenuItem(
                      value: o,
                      checked: o == _sort,
                      child: Text(o.label),
                    ))
                .toList(),
          ),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: p.isLoading ? null : p.loadCompanies,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: PageContainer(child: _buildBody(p)),
    );
  }

  Widget _buildBody(AppProvider p) {
    final cs = Theme.of(context).colorScheme;

    if (p.isLoading && p.companies.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (p.error != null && p.companies.isEmpty) {
      return Center(
        child: StateMessage(
          icon: Icons.cloud_off_outlined,
          title: "Couldn't load companies",
          message: p.error,
          action: FilledButton.icon(
            onPressed: p.loadCompanies,
            icon: const Icon(Icons.refresh),
            label: const Text('Try again'),
          ),
        ),
      );
    }

    final q = _query.toLowerCase();
    final filtered = p.companies
        .where((c) =>
            c.name.toLowerCase().contains(q) ||
            c.registrationNumber.toLowerCase().contains(q))
        .toList()
      ..sort(_compare);
    final serviceCount =
        p.companies.fold<int>(0, (sum, c) => sum + c.services.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 4),
        Text(
          '${plural(p.companies.length, 'company', 'companies')} · '
          '${plural(serviceCount, 'service')} · ${_sort.label}',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => _open(const CreateCompanyScreen()),
                icon: const Icon(Icons.add_business_outlined),
                label: const Text('New company'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: p.companies.isEmpty
                    ? null
                    : () => _open(const CreateServiceScreen()),
                icon: const Icon(Icons.room_service_outlined),
                label: const Text('New service'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _search,
          onChanged: (v) => setState(() => _query = v.trim()),
          decoration: InputDecoration(
            hintText: 'Search by name or registration number',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear',
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _search.clear();
                      setState(() => _query = '');
                    },
                  ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 3,
          child: p.isLoading ? const LinearProgressIndicator() : null,
        ),
        const SizedBox(height: 9),
        if (p.error != null) _ErrorBanner(message: p.error!),
        Expanded(
          child: RefreshIndicator(
            onRefresh: p.loadCompanies,
            child: filtered.isEmpty
                ? ListView(children: [
                    StateMessage(
                      icon: _query.isEmpty
                          ? Icons.business_outlined
                          : Icons.search_off,
                      title:
                          _query.isEmpty ? 'No companies yet' : 'No matches',
                      message: _query.isEmpty
                          ? 'Create your first company to get started.'
                          : 'Try a different name or registration number.',
                    ),
                  ])
                : ListView.separated(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _CompanyCard(company: filtered[i]),
                  ),
          ),
        ),
      ],
    );
  }
}

class _CompanyCard extends StatelessWidget {
  final Company company;
  const _CompanyCard({required this.company});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final initial =
        company.name.isEmpty ? '?' : company.name[0].toUpperCase();

    final services = List<Service>.of(company.services)
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return Card(
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: const Border(),
          collapsedShape: const Border(),
          tilePadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: CircleAvatar(
            backgroundColor: cs.primaryContainer,
            foregroundColor: cs.onPrimaryContainer,
            child: Text(initial,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          title: Text(
            company.name,
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _Pill(
                    icon: Icons.badge_outlined,
                    text: company.registrationNumber),
                _Pill(
                  icon: Icons.room_service_outlined,
                  text: plural(company.services.length, 'service'),
                ),
              ],
            ),
          ),
          children: services.isEmpty
              ? [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'No services yet',
                      style: tt.bodyMedium
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ),
                ]
              : services.map((s) => _ServiceRow(service: s)).toList(),
        ),
      ),
    );
  }
}

class _ServiceRow extends StatelessWidget {
  final Service service;
  const _ServiceRow({required this.service});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service.name,
                    style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  service.description,
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            formatPrice(service.price),
            style: tt.bodyLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Pill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: cs.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            text,
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: cs.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: TextStyle(color: cs.onErrorContainer)),
          ),
        ],
      ),
    );
  }
}