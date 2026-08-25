import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In ar, this message translates to:
  /// **'Home OS'**
  String get appName;

  /// No description provided for @home.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get home;

  /// No description provided for @house.
  ///
  /// In ar, this message translates to:
  /// **'المنزل'**
  String get house;

  /// No description provided for @schedule.
  ///
  /// In ar, this message translates to:
  /// **'الجدول'**
  String get schedule;

  /// No description provided for @activity.
  ///
  /// In ar, this message translates to:
  /// **'السجل'**
  String get activity;

  /// No description provided for @more.
  ///
  /// In ar, this message translates to:
  /// **'المزيد'**
  String get more;

  /// No description provided for @next.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get next;

  /// No description provided for @start.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ'**
  String get start;

  /// No description provided for @skip.
  ///
  /// In ar, this message translates to:
  /// **'تخطي'**
  String get skip;

  /// No description provided for @continueAction.
  ///
  /// In ar, this message translates to:
  /// **'متابعة'**
  String get continueAction;

  /// No description provided for @onboarding1Title.
  ///
  /// In ar, this message translates to:
  /// **'كل ما يخص منزلك في مكان واحد'**
  String get onboarding1Title;

  /// No description provided for @onboarding1Body.
  ///
  /// In ar, this message translates to:
  /// **'احفظ الأجهزة والسيارات والخدمات والمستندات وتاريخ كل شيء.'**
  String get onboarding1Body;

  /// No description provided for @onboarding2Title.
  ///
  /// In ar, this message translates to:
  /// **'لا تنس الصيانة والضمانات'**
  String get onboarding2Title;

  /// No description provided for @onboarding2Body.
  ///
  /// In ar, this message translates to:
  /// **'تابع المواعيد المهمة قبل أن تتحول إلى مشكلة.'**
  String get onboarding2Body;

  /// No description provided for @onboarding3Title.
  ///
  /// In ar, this message translates to:
  /// **'احتفظ بتاريخ كل شيء'**
  String get onboarding3Title;

  /// No description provided for @onboarding3Body.
  ///
  /// In ar, this message translates to:
  /// **'سجل الصيانة والمصاريف والوثائق يبقى مرتبًا وسهل الرجوع.'**
  String get onboarding3Body;

  /// No description provided for @onboarding4Title.
  ///
  /// In ar, this message translates to:
  /// **'أنشئ منزلك الأول'**
  String get onboarding4Title;

  /// No description provided for @onboarding4Body.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ بمعلومة بسيطة ثم أضف التفاصيل لاحقًا.'**
  String get onboarding4Body;

  /// No description provided for @homeName.
  ///
  /// In ar, this message translates to:
  /// **'اسم المنزل'**
  String get homeName;

  /// No description provided for @homeTypeOptional.
  ///
  /// In ar, this message translates to:
  /// **'نوع المنزل اختياري'**
  String get homeTypeOptional;

  /// No description provided for @firstThing.
  ///
  /// In ar, this message translates to:
  /// **'ما أول شيء تريد إضافته؟'**
  String get firstThing;

  /// No description provided for @airConditioner.
  ///
  /// In ar, this message translates to:
  /// **'مكيف'**
  String get airConditioner;

  /// No description provided for @car.
  ///
  /// In ar, this message translates to:
  /// **'سيارة'**
  String get car;

  /// No description provided for @device.
  ///
  /// In ar, this message translates to:
  /// **'جهاز'**
  String get device;

  /// No description provided for @pool.
  ///
  /// In ar, this message translates to:
  /// **'مسبح'**
  String get pool;

  /// No description provided for @other.
  ///
  /// In ar, this message translates to:
  /// **'غير ذلك'**
  String get other;

  /// No description provided for @welcome.
  ///
  /// In ar, this message translates to:
  /// **'مرحبًا'**
  String get welcome;

  /// No description provided for @attention.
  ///
  /// In ar, this message translates to:
  /// **'يحتاج انتباهك'**
  String get attention;

  /// No description provided for @today.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get today;

  /// No description provided for @yourHome.
  ///
  /// In ar, this message translates to:
  /// **'منزلك'**
  String get yourHome;

  /// No description provided for @latestActivity.
  ///
  /// In ar, this message translates to:
  /// **'آخر النشاطات'**
  String get latestActivity;

  /// No description provided for @quickAdd.
  ///
  /// In ar, this message translates to:
  /// **'إضافة سريعة'**
  String get quickAdd;

  /// No description provided for @assets.
  ///
  /// In ar, this message translates to:
  /// **'الأجهزة'**
  String get assets;

  /// No description provided for @vehicles.
  ///
  /// In ar, this message translates to:
  /// **'السيارات'**
  String get vehicles;

  /// No description provided for @activeWarranties.
  ///
  /// In ar, this message translates to:
  /// **'ضمانات سارية'**
  String get activeWarranties;

  /// No description provided for @overdueTasks.
  ///
  /// In ar, this message translates to:
  /// **'مهام متأخرة'**
  String get overdueTasks;

  /// No description provided for @addAsset.
  ///
  /// In ar, this message translates to:
  /// **'إضافة جهاز'**
  String get addAsset;

  /// No description provided for @addVehicle.
  ///
  /// In ar, this message translates to:
  /// **'إضافة سيارة'**
  String get addVehicle;

  /// No description provided for @addMaintenance.
  ///
  /// In ar, this message translates to:
  /// **'إضافة صيانة'**
  String get addMaintenance;

  /// No description provided for @addReminder.
  ///
  /// In ar, this message translates to:
  /// **'إضافة تذكير'**
  String get addReminder;

  /// No description provided for @reminders.
  ///
  /// In ar, this message translates to:
  /// **'التذكيرات'**
  String get reminders;

  /// No description provided for @addDocument.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مستند'**
  String get addDocument;

  /// No description provided for @addService.
  ///
  /// In ar, this message translates to:
  /// **'إضافة خدمة'**
  String get addService;

  /// No description provided for @addExpense.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مصروف'**
  String get addExpense;

  /// No description provided for @name.
  ///
  /// In ar, this message translates to:
  /// **'الاسم'**
  String get name;

  /// No description provided for @category.
  ///
  /// In ar, this message translates to:
  /// **'الفئة'**
  String get category;

  /// No description provided for @location.
  ///
  /// In ar, this message translates to:
  /// **'المكان'**
  String get location;

  /// No description provided for @optionalImage.
  ///
  /// In ar, this message translates to:
  /// **'الصورة اختيارية'**
  String get optionalImage;

  /// No description provided for @addMoreDetails.
  ///
  /// In ar, this message translates to:
  /// **'إضافة تفاصيل أخرى'**
  String get addMoreDetails;

  /// No description provided for @brand.
  ///
  /// In ar, this message translates to:
  /// **'الشركة'**
  String get brand;

  /// No description provided for @model.
  ///
  /// In ar, this message translates to:
  /// **'الموديل'**
  String get model;

  /// No description provided for @serialNumber.
  ///
  /// In ar, this message translates to:
  /// **'الرقم التسلسلي'**
  String get serialNumber;

  /// No description provided for @purchaseDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الشراء'**
  String get purchaseDate;

  /// No description provided for @purchasePrice.
  ///
  /// In ar, this message translates to:
  /// **'السعر'**
  String get purchasePrice;

  /// No description provided for @warranty.
  ///
  /// In ar, this message translates to:
  /// **'الضمان'**
  String get warranty;

  /// No description provided for @notes.
  ///
  /// In ar, this message translates to:
  /// **'الملاحظات'**
  String get notes;

  /// No description provided for @save.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @overview.
  ///
  /// In ar, this message translates to:
  /// **'نظرة عامة'**
  String get overview;

  /// No description provided for @maintenance.
  ///
  /// In ar, this message translates to:
  /// **'الصيانة'**
  String get maintenance;

  /// No description provided for @documents.
  ///
  /// In ar, this message translates to:
  /// **'المستندات'**
  String get documents;

  /// No description provided for @expenses.
  ///
  /// In ar, this message translates to:
  /// **'المصاريف'**
  String get expenses;

  /// No description provided for @providers.
  ///
  /// In ar, this message translates to:
  /// **'مقدمو الخدمات'**
  String get providers;

  /// No description provided for @services.
  ///
  /// In ar, this message translates to:
  /// **'الخدمات'**
  String get services;

  /// No description provided for @warranties.
  ///
  /// In ar, this message translates to:
  /// **'الضمانات'**
  String get warranties;

  /// No description provided for @family.
  ///
  /// In ar, this message translates to:
  /// **'العائلة'**
  String get family;

  /// No description provided for @reports.
  ///
  /// In ar, this message translates to:
  /// **'التقارير'**
  String get reports;

  /// No description provided for @settings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settings;

  /// No description provided for @help.
  ///
  /// In ar, this message translates to:
  /// **'المساعدة'**
  String get help;

  /// No description provided for @noAssetsTitle.
  ///
  /// In ar, this message translates to:
  /// **'لم تضف أي جهاز بعد'**
  String get noAssetsTitle;

  /// No description provided for @noAssetsBody.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ بجهاز مهم مثل المكيف أو الثلاجة، ثم أضف التفاصيل لاحقًا.'**
  String get noAssetsBody;

  /// No description provided for @deletedAsset.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف الجهاز'**
  String get deletedAsset;

  /// No description provided for @undo.
  ///
  /// In ar, this message translates to:
  /// **'تراجع'**
  String get undo;

  /// No description provided for @serialTip.
  ///
  /// In ar, this message translates to:
  /// **'ستجد الرقم غالبًا على ملصق خلف الجهاز ويمكن تركه فارغًا.'**
  String get serialTip;

  /// No description provided for @warrantyTip.
  ///
  /// In ar, this message translates to:
  /// **'أدخل تاريخ انتهاء الضمان لنذكرك قبل انتهائه.'**
  String get warrantyTip;

  /// No description provided for @frequencyTip.
  ///
  /// In ar, this message translates to:
  /// **'حدد كل كم تريد تنفيذ هذه الخدمة أو الصيانة.'**
  String get frequencyTip;

  /// No description provided for @showTips.
  ///
  /// In ar, this message translates to:
  /// **'إظهار تلميحات الاستخدام'**
  String get showTips;

  /// No description provided for @theme.
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get theme;

  /// No description provided for @system.
  ///
  /// In ar, this message translates to:
  /// **'النظام'**
  String get system;

  /// No description provided for @light.
  ///
  /// In ar, this message translates to:
  /// **'فاتح'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In ar, this message translates to:
  /// **'داكن'**
  String get dark;

  /// No description provided for @language.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get language;

  /// No description provided for @arabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @account.
  ///
  /// In ar, this message translates to:
  /// **'الحساب'**
  String get account;

  /// No description provided for @defaultHome.
  ///
  /// In ar, this message translates to:
  /// **'المنزل الافتراضي'**
  String get defaultHome;

  /// No description provided for @currency.
  ///
  /// In ar, this message translates to:
  /// **'العملة'**
  String get currency;

  /// No description provided for @dateFormat.
  ///
  /// In ar, this message translates to:
  /// **'صيغة التاريخ'**
  String get dateFormat;

  /// No description provided for @notifications.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get notifications;

  /// No description provided for @defaultReminder.
  ///
  /// In ar, this message translates to:
  /// **'التذكير الافتراضي'**
  String get defaultReminder;

  /// No description provided for @privacy.
  ///
  /// In ar, this message translates to:
  /// **'الخصوصية'**
  String get privacy;

  /// No description provided for @biometricLock.
  ///
  /// In ar, this message translates to:
  /// **'القفل بالبصمة'**
  String get biometricLock;

  /// No description provided for @storage.
  ///
  /// In ar, this message translates to:
  /// **'التخزين'**
  String get storage;

  /// No description provided for @data.
  ///
  /// In ar, this message translates to:
  /// **'البيانات'**
  String get data;

  /// No description provided for @exportPlaceholder.
  ///
  /// In ar, this message translates to:
  /// **'التصدير'**
  String get exportPlaceholder;

  /// No description provided for @contactUs.
  ///
  /// In ar, this message translates to:
  /// **'تواصل معنا'**
  String get contactUs;

  /// No description provided for @privacyPolicy.
  ///
  /// In ar, this message translates to:
  /// **'سياسة الخصوصية'**
  String get privacyPolicy;

  /// No description provided for @terms.
  ///
  /// In ar, this message translates to:
  /// **'الشروط'**
  String get terms;

  /// No description provided for @about.
  ///
  /// In ar, this message translates to:
  /// **'حول التطبيق'**
  String get about;

  /// No description provided for @version.
  ///
  /// In ar, this message translates to:
  /// **'الإصدار'**
  String get version;

  /// No description provided for @logout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get logout;

  /// No description provided for @deleteAccount.
  ///
  /// In ar, this message translates to:
  /// **'حذف الحساب'**
  String get deleteAccount;

  /// No description provided for @genericError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر حفظ التغيير. حاول مرة أخرى.'**
  String get genericError;

  /// No description provided for @comingReady.
  ///
  /// In ar, this message translates to:
  /// **'واجهة محلية جاهزة للربط لاحقًا'**
  String get comingReady;

  /// No description provided for @thisMonth.
  ///
  /// In ar, this message translates to:
  /// **'هذا الشهر'**
  String get thisMonth;

  /// No description provided for @thisYear.
  ///
  /// In ar, this message translates to:
  /// **'هذا العام'**
  String get thisYear;

  /// No description provided for @byCategory.
  ///
  /// In ar, this message translates to:
  /// **'حسب الفئة'**
  String get byCategory;

  /// No description provided for @byAsset.
  ///
  /// In ar, this message translates to:
  /// **'حسب الأصل'**
  String get byAsset;

  /// No description provided for @valid.
  ///
  /// In ar, this message translates to:
  /// **'ساري'**
  String get valid;

  /// No description provided for @expiringSoon.
  ///
  /// In ar, this message translates to:
  /// **'قريب الانتهاء'**
  String get expiringSoon;

  /// No description provided for @expired.
  ///
  /// In ar, this message translates to:
  /// **'منتهي'**
  String get expired;

  /// No description provided for @provider.
  ///
  /// In ar, this message translates to:
  /// **'مقدم الخدمة'**
  String get provider;

  /// No description provided for @phone.
  ///
  /// In ar, this message translates to:
  /// **'الهاتف'**
  String get phone;

  /// No description provided for @frequency.
  ///
  /// In ar, this message translates to:
  /// **'التكرار'**
  String get frequency;

  /// No description provided for @cost.
  ///
  /// In ar, this message translates to:
  /// **'التكلفة'**
  String get cost;

  /// No description provided for @lastVisit.
  ///
  /// In ar, this message translates to:
  /// **'آخر زيارة'**
  String get lastVisit;

  /// No description provided for @nextVisit.
  ///
  /// In ar, this message translates to:
  /// **'الزيارة القادمة'**
  String get nextVisit;

  /// No description provided for @roleOwner.
  ///
  /// In ar, this message translates to:
  /// **'Owner'**
  String get roleOwner;

  /// No description provided for @roleAdmin.
  ///
  /// In ar, this message translates to:
  /// **'Admin'**
  String get roleAdmin;

  /// No description provided for @roleMember.
  ///
  /// In ar, this message translates to:
  /// **'Member'**
  String get roleMember;

  /// No description provided for @roleViewer.
  ///
  /// In ar, this message translates to:
  /// **'Viewer'**
  String get roleViewer;

  /// No description provided for @roleLimited.
  ///
  /// In ar, this message translates to:
  /// **'Limited'**
  String get roleLimited;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
