import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/app_background.dart';
import '../../core/app_colors.dart';
import '../../core/app_localizations.dart';
import '../../core/language_provider.dart';

class LanguagesScreen extends StatefulWidget {
  const LanguagesScreen({super.key});

  @override
  State<LanguagesScreen> createState() => _LanguagesScreenState();
}

class _LanguagesScreenState extends State<LanguagesScreen> {
  static const List<String> _languageCodes = ['en', 'ar'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final languageProvider = context.watch<LanguageProvider>();
    final loc = AppLocalizations.of(context);
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: theme.colorScheme.onSurface,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        loc.translate('language'),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Languages list
                Expanded(
                  child: ListView.separated(
                    itemCount: _languageCodes.length,
                    separatorBuilder: (context, index) =>
                        Divider(height: 1, color: theme.dividerColor),
                    itemBuilder: (context, index) {
                      final code = _languageCodes[index];
                      final label = code == 'en'
                          ? loc.translate('languageEnglish')
                          : loc.translate('languageArabic');
                      return ListTile(
                        title: Text(label),
                        trailing:
                            languageProvider.selectedLocale.languageCode == code
                                ? const Icon(Icons.check,
                                    color: AppColors.primary)
                                : null,
                        onTap: () async {
                          await languageProvider.setLocale(Locale(code));
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}