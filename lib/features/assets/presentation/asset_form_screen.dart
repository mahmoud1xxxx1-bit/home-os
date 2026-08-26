import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/app_models.dart';
import '../../../core/services/local_repositories.dart';
import '../../../core/subscriptions/subscription_providers.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/responsive_page.dart';
import '../../../l10n/app_localizations.dart';

class AssetFormScreen extends ConsumerStatefulWidget {
  const AssetFormScreen({super.key});

  @override
  ConsumerState<AssetFormScreen> createState() => _AssetFormScreenState();
}

class _AssetFormScreenState extends ConsumerState<AssetFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _brand = TextEditingController();
  final _model = TextEditingController();
  final _serial = TextEditingController();
  final _price = TextEditingController();
  final _notes = TextEditingController();
  String? _locationId;
  AssetCategory _category = AssetCategory.appliance;
  bool _more = false;
  bool _saving = false;

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
    final locations = ref.watch(homeRepositoryProvider).watchLocations();
    _locationId ??= locations.isEmpty ? null : locations.first.id;

    return ResponsivePage(
      title: l10n.addAsset,
      children: [
        Text(
          lang == 'ar' ? 'أضف الأساسيات الآن، ويمكنك إكمال التفاصيل لاحقًا.' : 'Add the essentials now. You can complete the details later.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.5),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _name,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(labelText: l10n.name, prefixIcon: const Icon(Icons.devices_other_rounded)),
                  validator: (value) => value == null || value.trim().isEmpty ? (lang == 'ar' ? 'اكتب اسم الأصل' : 'Enter an asset name') : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<AssetCategory>(
                  initialValue: _category,
                  decoration: InputDecoration(labelText: l10n.category, prefixIcon: const Icon(Icons.category_outlined)),
                  items: AssetCategory.values.map((category) => DropdownMenuItem(value: category, child: Text(_categoryLabel(category, lang)))).toList(),
                  onChanged: (value) => setState(() => _category = value ?? _category),
                ),
                const SizedBox(height: 12),
                if (locations.isEmpty)
                  AppCard(
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.info_outline_rounded),
                          title: Text(lang == 'ar' ? 'أضف موقعًا أولًا' : 'Add a location first'),
                          subtitle: Text(lang == 'ar' ? 'كل أصل يجب أن يكون مرتبطًا بغرفة أو موقع واضح.' : 'Every asset needs a room or location.'),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => context.push('/manage/locations'),
                            icon: const Icon(Icons.add_location_alt_outlined),
                            label: Text(lang == 'ar' ? 'إضافة موقع الآن' : 'Add location now'),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  DropdownButtonFormField<String>(
                    initialValue: _locationId,
                    decoration: InputDecoration(labelText: l10n.location, prefixIcon: const Icon(Icons.room_outlined)),
                    items: locations.map((location) => DropdownMenuItem(value: location.id, child: Text(location.name.value(lang)))).toList(),
                    onChanged: (value) => setState(() => _locationId = value),
                  ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.image_outlined),
                  title: Text(l10n.optionalImage),
                  subtitle: Text(lang == 'ar' ? 'رفع الملفات سيتاح بعد تفعيل التخزين السحابي.' : 'File upload will be available after cloud storage is enabled.'),
                  trailing: const Icon(Icons.lock_clock_outlined),
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
                  TextField(controller: _brand, textInputAction: TextInputAction.next, decoration: InputDecoration(labelText: l10n.brand)),
                  const SizedBox(height: 12),
                  TextField(controller: _model, textInputAction: TextInputAction.next, decoration: InputDecoration(labelText: l10n.model)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: _serial, textInputAction: TextInputAction.next, decoration: InputDecoration(labelText: l10n.serialNumber))),
                      InfoTip(title: l10n.serialNumber, message: l10n.serialTip),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: _price, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: l10n.purchasePrice)),
                  const SizedBox(height: 12),
                  TextField(controller: _notes, maxLines: 3, textInputAction: TextInputAction.done, decoration: InputDecoration(labelText: l10n.notes)),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _saving || locations.isEmpty ? null : _save,
                    icon: _saving
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.check_rounded),
                    label: Text(l10n.save),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _locationId == null || _saving) return;

    final access = ref.read(accessDecisionProvider(LimitedResource.asset));
    if (!access.allowed) {
      if (mounted) context.push('/upgrade?reason=${access.reasonKey}');
      return;
    }

    setState(() => _saving = true);
    try {
      final now = DateTime.now();
      final id = 'asset-${now.microsecondsSinceEpoch}';
      ref.read(assetRepositoryProvider).addAsset(
            HomeAsset(
              id: id,
              name: LocalizedText(ar: _name.text.trim(), en: _name.text.trim()),
              category: _category,
              locationId: _locationId!,
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'تم حفظ الأصل وجارٍ مزامنته' : 'Asset saved and syncing')),
        );
        context.go('/asset/$id');
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'تعذر حفظ الأصل. حاول مرة أخرى.' : 'Could not save the asset. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _categoryLabel(AssetCategory category, String lang) {
    if (lang != 'ar') {
      return switch (category) {
        AssetCategory.hvac => 'HVAC',
        AssetCategory.kitchen => 'Kitchen',
        AssetCategory.appliance => 'Appliance',
        AssetCategory.electronics => 'Electronics',
        AssetCategory.plumbing => 'Plumbing',
        AssetCategory.vehicle => 'Vehicle',
        AssetCategory.other => 'Other',
      };
    }
    return switch (category) {
      AssetCategory.hvac => 'تكييف وتهوية',
      AssetCategory.kitchen => 'المطبخ',
      AssetCategory.appliance => 'أجهزة منزلية',
      AssetCategory.electronics => 'إلكترونيات',
      AssetCategory.plumbing => 'سباكة',
      AssetCategory.vehicle => 'مركبة',
      AssetCategory.other => 'أخرى',
    };
  }
}
