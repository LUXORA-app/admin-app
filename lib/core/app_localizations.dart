import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'settings': 'Settings',
      'language': 'Language',
      'profile': 'Profile',
      'appearance': 'Appearance',
      'logout': 'Log out',
      'search': 'Search',
      'login': 'Login',
      'signup': 'Sign Up',
      'email': 'Email',
      'password': 'Password',
      'forgotPassword': 'Forgot Password?',
      'resetPassword': 'Reset Password',
      'confirmPassword': 'Confirm Password',
      'name': 'Name',
      'dashboard': 'Dashboard',
      'users': 'Users',
      'landmarks': 'Landmarks',
      'explore': 'Explore',
      'chatBot': 'Chat bot',
      'scan': 'Scan',
      'gallery': 'Gallery',
      'welcome': 'Welcome!',
      'emailAddress': 'Email Address',
      'notAMember': 'Not a member? ',
      'registerNow': 'Register now',
      'seeMore': 'See more',
      'noLandmarksYet': 'No landmarks yet',
      'pleaseLoginFirst': 'Please login first.',
      'unknownLocation': 'Unknown location',
      'noDescriptionAvailable': 'No description available.',
      'pleaseEnterEmailAndPassword': 'Please enter email and password.',
      'dashboardOverview': 'Overview of your Luxora admin data',
      'recentUsers': 'Recent users',
      'noUsersYet': 'No users yet.',
      'quickActions': 'Quick actions',
      'editUsers': 'Edit users',
      'editLandmarks': 'Edit landmarks',
      'splashTagline': 'Let The Ancient Walls Speak',
      'adminPanel': 'Admin',
      'languageEnglish': 'English',
      'languageArabic': 'Arabic',
      'loggedOut': 'Logged out',
      'administrator': 'Administrator',
      'deleteUser': 'Delete user',
      'removeUserPermanently': 'Remove {name} permanently?',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'addUser': 'Add user',
      'add': 'Add',
      'searchUsersHint': 'Search by name or email',
      'noUsersMatchSearch': 'No users match your search.',
      'blocked': 'Blocked',
      'unblock': 'Unblock',
      'block': 'Block',
      'addLandmark': 'Add landmark',
      'editLandmark': 'Edit landmark',
      'description': 'Description',
      'latitude': 'Latitude',
      'longitude': 'Longitude',
      'latHint': '-90 to 90',
      'lngHint': '-180 to 180',
      'landmarkImage': 'Landmark Image',
      'photoUrl': 'Photo URL',
      'httpsHint': 'https://...',
      'pickFromDevice': 'Pick from device',
      'nameRequired': 'Name is required',
      'latitudeRange': 'Latitude must be between -90 and 90',
      'longitudeRange': 'Longitude must be between -180 and 180',
      'photoRequired': 'Please provide a Photo URL or pick an image',
      'saveChanges': 'Save changes',
      'deleteLandmark': 'Delete landmark',
      'removeLandmarkConfirm': 'Remove "{name}"?',
      'noLandmarksEmpty': 'No landmarks yet. Tap Add to create one.',
      'addShort': 'Add',
      'edit': 'Edit',
      'forgotPasswordTitle': 'Forgot Password',
      'forgotPasswordBody':
          'Enter your admin email address and we\'ll send you a 6-digit code to reset your password.',
      'pleaseEnterEmail': 'Please enter your email.',
      'sendCode': 'Send Code',
      'resetCodeSent': 'Reset code sent to your email.',
      'resettingPasswordFor': 'Resetting password for {email}',
      'digitCodeHint': '6-digit Code',
      'newPassword': 'New Password',
      'resetPasswordSuccess': 'Password reset successfully. You can now login.',
      'fillAllFields': 'Please fill all fields.',
      'passwordsDoNotMatch': 'Passwords do not match.',
      'signupSubtitle': 'Create an account to get started',
      'fullName': 'Full Name',
      'nationality': 'Nationality',
      'selectCountry': 'Select a country',
      'adminSecret': 'Admin Secret',
      'adminSecretHint': 'Enter ADMIN_REGISTER_SECRET',
      'fillAllFieldsAdminSecret':
          'Please fill all required fields including Admin Secret.',
      'alreadyHaveAccount': 'Already have an account? ',
      'editProfile': 'Edit Profile',
      'newPasswordOptional': 'New password (optional)',
      'confirmNewPassword': 'Confirm new password',
      'save': 'Save',
      'galleryPermissionRequired':
          'Gallery permission is required to pick an image.',
      'galleryPermission': 'Gallery Permission',
      'galleryPermissionBody':
          'We need gallery access to pick a profile image. Please enable it in the app settings.',
      'openSettings': 'Settings',
      'pleaseEnterYourName': 'Please enter your name.',
      'passwordMinLength': 'Password must be at least 8 characters.',
      'profileUpdated': 'Profile updated.',
      'about': 'About',
      'noDescriptionProvided': 'No description provided.',
      'emDash': '—',
    },
    'ar': {
      'settings': 'الإعدادات',
      'language': 'اللغة',
      'profile': 'الملف الشخصي',
      'appearance': 'المظهر',
      'logout': 'تسجيل الخروج',
      'search': 'بحث',
      'login': 'تسجيل الدخول',
      'signup': 'إنشاء حساب',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'forgotPassword': 'نسيت كلمة المرور؟',
      'resetPassword': 'إعادة تعيين كلمة المرور',
      'confirmPassword': 'تأكيد كلمة المرور',
      'name': 'الاسم',
      'dashboard': 'لوحة التحكم',
      'users': 'المستخدمون',
      'landmarks': 'المعالم',
      'explore': 'استكشف',
      'chatBot': 'شات بوت',
      'scan': 'مسح',
      'gallery': 'معرض الصور',
      'welcome': 'مرحباً!',
      'emailAddress': 'البريد الإلكتروني',
      'notAMember': 'لست عضواً؟ ',
      'registerNow': 'سجّل الآن',
      'seeMore': 'عرض المزيد',
      'noLandmarksYet': 'لا توجد معالم بعد',
      'pleaseLoginFirst': 'يرجى تسجيل الدخول أولاً.',
      'unknownLocation': 'موقع غير معروف',
      'noDescriptionAvailable': 'لا يوجد وصف متاح.',
      'pleaseEnterEmailAndPassword':
          'يرجى إدخال البريد الإلكتروني وكلمة المرور.',
      'dashboardOverview': 'نظرة عامة على بيانات لوحة تحكم Luxora',
      'recentUsers': 'أحدث المستخدمين',
      'noUsersYet': 'لا يوجد مستخدمون بعد.',
      'quickActions': 'إجراءات سريعة',
      'editUsers': 'تعديل المستخدمين',
      'editLandmarks': 'تعديل المعالم',
      'splashTagline': 'دع الجدران القديمة تتكلم',
      'adminPanel': 'إدارة',
      'languageEnglish': 'الإنجليزية',
      'languageArabic': 'العربية',
      'loggedOut': 'تم تسجيل الخروج',
      'administrator': 'مسؤول',
      'deleteUser': 'حذف المستخدم',
      'removeUserPermanently': 'إزالة {name} نهائياً؟',
      'cancel': 'إلغاء',
      'delete': 'حذف',
      'addUser': 'إضافة مستخدم',
      'add': 'إضافة',
      'searchUsersHint': 'ابحث بالاسم أو البريد',
      'noUsersMatchSearch': 'لا يوجد مستخدمون يطابقون بحثك.',
      'blocked': 'محظور',
      'unblock': 'إلغاء الحظر',
      'block': 'حظر',
      'addLandmark': 'إضافة معلم',
      'editLandmark': 'تعديل المعلم',
      'description': 'الوصف',
      'latitude': 'خط العرض',
      'longitude': 'خط الطول',
      'latHint': '-90 إلى 90',
      'lngHint': '-180 إلى 180',
      'landmarkImage': 'صورة المعلم',
      'photoUrl': 'رابط الصورة',
      'httpsHint': 'https://...',
      'pickFromDevice': 'اختر من الجهاز',
      'nameRequired': 'الاسم مطلوب',
      'latitudeRange': 'يجب أن يكون خط العرض بين -90 و 90',
      'longitudeRange': 'يجب أن يكون خط الطول بين -180 و 180',
      'photoRequired': 'يرجى إدخال رابط صورة أو اختيار صورة',
      'saveChanges': 'حفظ التغييرات',
      'deleteLandmark': 'حذف المعلم',
      'removeLandmarkConfirm': 'حذف "{name}"؟',
      'noLandmarksEmpty': 'لا توجد معالم بعد. اضغط إضافة لإنشاء معلم.',
      'addShort': 'إضافة',
      'edit': 'تعديل',
      'forgotPasswordTitle': 'نسيت كلمة المرور',
      'forgotPasswordBody':
          'أدخل بريد المسؤول الإلكتروني وسنرسل لك رمزاً مكوناً من 6 أرقام لإعادة تعيين كلمة المرور.',
      'pleaseEnterEmail': 'يرجى إدخال بريدك الإلكتروني.',
      'sendCode': 'إرسال الرمز',
      'resetCodeSent': 'تم إرسال رمز إعادة التعيين إلى بريدك.',
      'resettingPasswordFor': 'إعادة تعيين كلمة المرور لـ {email}',
      'digitCodeHint': 'رمز مكون من 6 أرقام',
      'newPassword': 'كلمة المرور الجديدة',
      'resetPasswordSuccess':
          'تم إعادة تعيين كلمة المرور. يمكنك تسجيل الدخول الآن.',
      'fillAllFields': 'يرجى ملء جميع الحقول.',
      'passwordsDoNotMatch': 'كلمتا المرور غير متطابقتين.',
      'signupSubtitle': 'أنشئ حساباً للبدء',
      'fullName': 'الاسم الكامل',
      'nationality': 'الجنسية',
      'selectCountry': 'اختر دولة',
      'adminSecret': 'سر المسؤول',
      'adminSecretHint': 'أدخل ADMIN_REGISTER_SECRET',
      'fillAllFieldsAdminSecret':
          'يرجى ملء جميع الحقول المطلوبة بما في ذلك سر المسؤول.',
      'alreadyHaveAccount': 'لديك حساب بالفعل؟ ',
      'editProfile': 'تعديل الملف الشخصي',
      'newPasswordOptional': 'كلمة مرور جديدة (اختياري)',
      'confirmNewPassword': 'تأكيد كلمة المرور الجديدة',
      'save': 'حفظ',
      'galleryPermissionRequired': 'يلزم إذن المعرض لاختيار صورة.',
      'galleryPermission': 'إذن المعرض',
      'galleryPermissionBody':
          'نحتاج الوصول إلى المعرض لاختيار صورة الملف الشخصي. يرجى تفعيله من إعدادات التطبيق.',
      'openSettings': 'الإعدادات',
      'pleaseEnterYourName': 'يرجى إدخال اسمك.',
      'passwordMinLength': 'يجب أن تكون كلمة المرور 8 أحرف على الأقل.',
      'profileUpdated': 'تم تحديث الملف الشخصي.',
      'about': 'نبذة',
      'noDescriptionProvided': 'لا يوجد وصف.',
      'emDash': '—',
    },
  };

  String translate(String key) {
    final langMap =
        _localizedValues[locale.languageCode] ?? _localizedValues['en']!;
    final enMap = _localizedValues['en']!;
    return langMap[key] ?? enMap[key] ?? key;
  }

  String translateWith(String key, Map<String, String> params) {
    var s = translate(key);
    params.forEach((k, v) {
      s = s.replaceAll('{$k}', v);
    });
    return s;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
