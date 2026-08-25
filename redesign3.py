import os
import re

def rewrite_empty_states():
    files = [
        ('lib/features/maintenance/presentation/maintenance_screen.dart', 'Icons.handyman_rounded', "lang == 'ar' ? 'لا توجد سجلات صيانة' : 'No maintenance records'"),
        ('lib/features/services/presentation/services_screen.dart', 'Icons.cleaning_services_rounded', "lang == 'ar' ? 'لا توجد خدمات' : 'No recurring services'"),
        ('lib/features/providers/presentation/providers_screen.dart', 'Icons.contacts_rounded', "lang == 'ar' ? 'لا يوجد مقدمو خدمة' : 'No providers'"),
        ('lib/features/warranties/presentation/warranties_screen.dart', 'Icons.verified_rounded', "lang == 'ar' ? 'لا توجد ضمانات' : 'No warranties'"),
        ('lib/features/documents/presentation/documents_screen.dart', 'Icons.description_rounded', "lang == 'ar' ? 'لا توجد مستندات' : 'No documents'"),
        ('lib/features/expenses/presentation/expenses_screen.dart', 'Icons.payments_rounded', "lang == 'ar' ? 'لا توجد مصاريف' : 'No expenses'"),
    ]
    
    for path, icon, msg in files:
        with open(path, 'r', encoding='utf-8') as f:
            content = f.read()
            
        # Regex to replace simple empty states with the EmptyState widget
        pattern = r"if \(.*\.isEmpty\)\s*const AppCard\(child: ListTile\(title: Text\('.*?'\)\)\)"
        pattern2 = r"if \(records\.isEmpty\)\s*AppCard\(\s*child: ListTile\(\s*leading: const Icon\(Icons\.handyman_rounded\),\s*title: Text\(lang == 'ar' \? 'لا توجد سجلات صيانة' : 'No maintenance records'\),\s*\),\s*\)"
        
        replacement = f"if (items.isEmpty) EmptyState(icon: {icon}, title: {msg}, message: lang == 'ar' ? 'يمكنك إضافة عنصر جديد الآن' : 'You can add a new item now', actionLabel: lang == 'ar' ? 'إضافة' : 'Add', onAction: () => _showForm(context, ref, null))"
        
        if 'maintenance' in path:
            content = re.sub(pattern2, f"if (records.isEmpty) EmptyState(icon: {icon}, title: {msg}, message: lang == 'ar' ? 'يمكنك إضافة سجل جديد الآن' : 'You can add a new record now', actionLabel: lang == 'ar' ? 'إضافة' : 'Add', onAction: () => _showForm(context, ref, null))", content)
        elif 'warranties' in path or 'documents' in path or 'expenses' in path:
            # these don't have _showForm defined yet, let's just make it do nothing for now
            replacement = f"if (items.isEmpty) EmptyState(icon: {icon}, title: {msg}, message: lang == 'ar' ? 'يمكنك إضافة عنصر جديد الآن' : 'You can add a new item now', actionLabel: lang == 'ar' ? 'إضافة' : 'Add', onAction: () {{}})"
            content = re.sub(pattern, replacement, content)
        else:
            content = re.sub(pattern, replacement, content)
            
        with open(path, 'w', encoding='utf-8') as f:
            f.write(content)

rewrite_empty_states()
print("Empty states updated.")
