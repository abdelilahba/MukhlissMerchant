import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mukhlissmagasin/features/language/presentation/cubit/language_cubit.dart';
import 'package:mukhlissmagasin/l10n/app_localizations.dart';


class LanguageSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<LanguageCubit>();
    final currentLocale = context.watch<LanguageCubit>().state;

    final languages = [
      {
        'code': 'fr',
        'name': 'Français',
        'flag': '🇫🇷',
        'nativeName': 'Français'
      },
      {
        'code': 'ar',
        'name': 'Arabe',
         'flag': '🇲🇦',
        'nativeName': 'العربية'
      },
      {
        'code': 'en', // Corrigé de 'an' à 'en'
        'name': 'Anglais',
        'flag': '🇺🇸',
        'nativeName': 'English'
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
        Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.language,
                  color: Colors.black,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                l10n. selectiondelaluangue ,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color:Colors.black,
                  ),
                ),
              ],
            ),
          ),
          
          // Language Options
          ...languages.map((language) {
            final isSelected = currentLocale.languageCode == language['code'];
            
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected 
                    ? const Color.fromARGB(255, 224, 237, 248)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected 
                      ? const Color.fromARGB(255, 224, 237, 248)
                      : Colors.transparent,
                  width: 1,
                ),
              ),
              child: InkWell(
                onTap: () => cubit.changeLanguage(Locale(language['code']!)),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      // Flag
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.3),
                            width: 0.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            language['flag']!,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Language names
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              language['name']!,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: isSelected 
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                            Text(
                              language['nativeName']!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Check icon
                      AnimatedScale(
                        scale: isSelected ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color:const Color.fromARGB(255, 137, 178, 212),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
          
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// Version alternative avec un design plus compact
class CompactLanguageSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LanguageCubit>();
    final currentLocale = context.watch<LanguageCubit>().state;

    final languages = [
      {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
      {'code': 'ar', 'name': 'العربية', 'flag': '🇸🇦'},
      {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Langue',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: languages.map((language) {
              final isSelected = currentLocale.languageCode == language['code'];
              
              return Expanded(
                child: GestureDetector(
                  onTap: () => cubit.changeLanguage(Locale(language['code']!)),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Theme.of(context).primaryColor
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected 
                            ? Theme.of(context).primaryColor
                            : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          language['flag']!,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          language['name']!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isSelected 
                                ? Colors.white
                                : Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}