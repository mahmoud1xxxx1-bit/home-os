import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../core/services/app_models.dart';
import '../../../core/services/local_repositories.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/responsive_page.dart';

class AssetFormScreen extends ConsumerStatefulWidget {
  const AssetFormScreen({super.key});

  @override
  ConsumerState<AssetFormScreen> createState() => _AssetFormScreenState();
}

class _AssetFormScreenState extends ConsumerState<AssetFormScreen> {
  final _name = TextEditingController();
  final _brand = TextEditingController();
  final _model = TextEditingController();
  final _serial = TextEditingController();
  final _price = TextEditingController();
  final _notes = TextEditingController();
  String _locationId = 'majlis';
  AssetCategory _category = AssetCategory.appliance;
  bool _more = false;

  @override
  void dispose() {
    _name.dispose();
    _brand.dispose();
    _model.dispose();
    _serial.dispose();
    _price.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final store = ref.watch(localStoreProvider);
    return ResponsivePage(
      title: l10n.addAsset,
      children: [
        AppCard(
          child: Column(
            children: [
              TextField(controller: _name, decoration: InputDecoration(labelText: l10n.name)),
              const SizedBox(height: 12),
              DropdownButtonFormField<AssetCategory>(
                initialValue: _category,
                decoration: InputDecoration(labelText: l10n.category),
                items: AssetCategory.values
                    .map((category) => DropdownMenuItem(value: category, child: Text(category.name)))
                    .toList(),
                onChanged: (value) => setState(() => _category = value ?? _category),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _locationId,
                decoration: InputDecoration(labelText: l10n.location),
                items: store
                    .watchLocations()
                    .map((location) => DropdownMenuItem(value: location.id, child: Text(location.name.value(lang))))
                    .toList(),
                onChanged: (value) => setState(() => _locationId = value ?? _locationId),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.image_rounded),
                title: Text(l10n.optionalImage),
                subtitle: Text(l10n.comingReady),
              ),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  onPressed: () => setState(() => _more = !_more),
                  icon: Icon(_more ? Icons.expand_less_rounded : Icons.expand_more_rounded),
                  label: Text(l10n.addMoreDetails),
                ),
              ),
              if (_more) ...[
                TextField(controller: _brand, decoration: InputDecoration(labelText: l10n.brand)),
                const SizedBox(height: 12),
                TextField(controller: _model, decoration: InputDecoration(labelText: l10n.model)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextField(controller: _serial, decoration: InputDecoration(labelText: l10n.serialNumber))),
                    InfoTip(title: l10n.serialNumber, message: l10n.serialTip),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(controller: _price, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: l10n.purchasePrice)),
                const SizedBox(height: 12),
                TextField(controller: _notes, maxLines: 3, decoration: InputDecoration(labelText: l10n.notes)),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    final now = DateTime.now();
                    final id = 'asset-${now.microsecondsSinceEpoch}';
                    store.addAsset(
                      HomeAsset(
                        id: id,
                        name: LocalizedText(ar: _name.text.trim().isEmpty ? 'جهاز جديد' : _name.text.trim(), en: _name.text.trim().isEmpty ? 'New asset' : _name.text.trim()),
                        category: _category,
                        locationId: _locationId,
                        brand: _brand.text.trim().isEmpty ? null : _brand.text.trim(),
                        model: _model.text.trim().isEmpty ? null : _model.text.trim(),
                        serialNumber: _serial.text.trim().isEmpty ? null : _serial.text.trim(),
                        purchasePrice: double.tryParse(_price.text),
                        notes: _notes.text.trim().isEmpty ? null : LocalizedText(ar: _notes.text.trim(), en: _notes.text.trim()),
                        createdAt: now,
                        updatedAt: now,
                      ),
                    );
                    ref.invalidate(assetsProvider);
                    context.go('/asset/$id');
                  },
                  child: Text(l10n.save),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
