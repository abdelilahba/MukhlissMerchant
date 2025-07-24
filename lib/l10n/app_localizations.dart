import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'My App'**
  String get appTitle;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @setting.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get setting;

  /// No description provided for @selectiondelaluangue.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get selectiondelaluangue;

  /// No description provided for @luangue.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get luangue;

  /// No description provided for @offrespeciale.
  ///
  /// In en, this message translates to:
  /// **'Special offers'**
  String get offrespeciale;

  /// No description provided for @pointfidelite.
  ///
  /// In en, this message translates to:
  /// **'loyalty points'**
  String get pointfidelite;

  /// No description provided for @pts.
  ///
  /// In en, this message translates to:
  /// **'pts'**
  String get pts;

  /// No description provided for @modifier.
  ///
  /// In en, this message translates to:
  /// **'Modify'**
  String get modifier;

  /// No description provided for @supprimer.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get supprimer;

  /// No description provided for @ajouteroffre.
  ///
  /// In en, this message translates to:
  /// **'Add an offer'**
  String get ajouteroffre;

  /// No description provided for @nouvelleoffre.
  ///
  /// In en, this message translates to:
  /// **'New Offer'**
  String get nouvelleoffre;

  /// No description provided for @modifieroffre.
  ///
  /// In en, this message translates to:
  /// **'Modifier Offre'**
  String get modifieroffre;

  /// No description provided for @modifieroffreexiste.
  ///
  /// In en, this message translates to:
  /// **'Modify your existing offer'**
  String get modifieroffreexiste;

  /// No description provided for @ajouternoouveauoffre.
  ///
  /// In en, this message translates to:
  /// **'Create an attractive offer for your customers'**
  String get ajouternoouveauoffre;

  /// No description provided for @bostezlesventes.
  ///
  /// In en, this message translates to:
  /// **'Boost your sales'**
  String get bostezlesventes;

  /// No description provided for @optimizeroffre.
  ///
  /// In en, this message translates to:
  /// **'Optimize your offer'**
  String get optimizeroffre;

  /// No description provided for @ajouterdetails.
  ///
  /// In en, this message translates to:
  /// **'Adjust the details to maximize impact'**
  String get ajouterdetails;

  /// No description provided for @credesoffre.
  ///
  /// In en, this message translates to:
  /// **'Create irresistible offers that convert'**
  String get credesoffre;

  /// No description provided for @detailoffre.
  ///
  /// In en, this message translates to:
  /// **'Offer details'**
  String get detailoffre;

  /// No description provided for @creationencours.
  ///
  /// In en, this message translates to:
  /// **'Creation in progress...'**
  String get creationencours;

  /// No description provided for @creeoffre.
  ///
  /// In en, this message translates to:
  /// **'Create the offer'**
  String get creeoffre;

  /// No description provided for @ajusterlesdetails.
  ///
  /// In en, this message translates to:
  /// **'Ajustez les détails pour maximiser l\'impact'**
  String get ajusterlesdetails;

  /// No description provided for @mantant.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get mantant;

  /// No description provided for @requis.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requis;

  /// No description provided for @point.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get point;

  /// No description provided for @menuprincipale.
  ///
  /// In en, this message translates to:
  /// **'Main Menu'**
  String get menuprincipale;

  /// No description provided for @acceuil.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get acceuil;

  /// No description provided for @offre.
  ///
  /// In en, this message translates to:
  /// **'Offers'**
  String get offre;

  /// No description provided for @recompences.
  ///
  /// In en, this message translates to:
  /// **'Awards'**
  String get recompences;

  /// No description provided for @caissier.
  ///
  /// In en, this message translates to:
  /// **'Cashier'**
  String get caissier;

  /// No description provided for @deconnexion.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get deconnexion;

  /// No description provided for @ajouterrecompence.
  ///
  /// In en, this message translates to:
  /// **'New Reward'**
  String get ajouterrecompence;

  /// No description provided for @echange.
  ///
  /// In en, this message translates to:
  /// **'Exchangeable with'**
  String get echange;

  /// No description provided for @modifierrecompence.
  ///
  /// In en, this message translates to:
  /// **'Edit Reward'**
  String get modifierrecompence;

  /// No description provided for @creeunerecompenceattractive.
  ///
  /// In en, this message translates to:
  /// **'Create an attractive reward to build loyalty'**
  String get creeunerecompenceattractive;

  /// No description provided for @modifierrecompenceexiste.
  ///
  /// In en, this message translates to:
  /// **'Edit your existing reward'**
  String get modifierrecompenceexiste;

  /// No description provided for @fidelisezclient.
  ///
  /// In en, this message translates to:
  /// **'Build customer loyalty'**
  String get fidelisezclient;

  /// No description provided for @peaufinez.
  ///
  /// In en, this message translates to:
  /// **'Refine your reward'**
  String get peaufinez;

  /// No description provided for @creerecompencesquiincitent.
  ///
  /// In en, this message translates to:
  /// **'Create rewards that encourage return visits'**
  String get creerecompencesquiincitent;

  /// No description provided for @ajuusterlesdetails.
  ///
  /// In en, this message translates to:
  /// **'Adjust the details to optimize engagement'**
  String get ajuusterlesdetails;

  /// No description provided for @detailsrecompence.
  ///
  /// In en, this message translates to:
  /// **'Reward Details'**
  String get detailsrecompence;

  /// No description provided for @descriptionrecompence.
  ///
  /// In en, this message translates to:
  /// **'Description of the reward'**
  String get descriptionrecompence;

  /// No description provided for @exemplerecompence.
  ///
  /// In en, this message translates to:
  /// **'Ex: 1 burger gratuit, Café offert, 10% de réduction'**
  String get exemplerecompence;

  /// No description provided for @entrerladescription.
  ///
  /// In en, this message translates to:
  /// **'Enter the reward description...'**
  String get entrerladescription;

  /// No description provided for @descriptionrequise.
  ///
  /// In en, this message translates to:
  /// **'Description is required'**
  String get descriptionrequise;

  /// No description provided for @pointrequise.
  ///
  /// In en, this message translates to:
  /// **'Points required'**
  String get pointrequise;

  /// No description provided for @pointrequismessage.
  ///
  /// In en, this message translates to:
  /// **'Points are required'**
  String get pointrequismessage;

  /// No description provided for @nombreinvaliide.
  ///
  /// In en, this message translates to:
  /// **'Invalid number'**
  String get nombreinvaliide;

  /// No description provided for @doitetresuperieur.
  ///
  /// In en, this message translates to:
  /// **'Must be greater than 0'**
  String get doitetresuperieur;

  /// No description provided for @modificationencour.
  ///
  /// In en, this message translates to:
  /// **'Modification in progress...'**
  String get modificationencour;

  /// No description provided for @creerecompence.
  ///
  /// In en, this message translates to:
  /// **'Create the reward'**
  String get creerecompence;

  /// No description provided for @enredisterlesmodifiaction.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get enredisterlesmodifiaction;

  /// No description provided for @espacecaisier.
  ///
  /// In en, this message translates to:
  /// **'Cashier area'**
  String get espacecaisier;

  /// No description provided for @bienvenucaissier.
  ///
  /// In en, this message translates to:
  /// **'Welcome to your space'**
  String get bienvenucaissier;

  /// No description provided for @interfacecaissier.
  ///
  /// In en, this message translates to:
  /// **'Cashier Interface'**
  String get interfacecaissier;

  /// No description provided for @gererfacilementcomptes.
  ///
  /// In en, this message translates to:
  /// **'Easily manage customer accounts and their balances'**
  String get gererfacilementcomptes;

  /// No description provided for @solde.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get solde;

  /// No description provided for @gerer.
  ///
  /// In en, this message translates to:
  /// **'Managed today'**
  String get gerer;

  /// No description provided for @transaction.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transaction;

  /// No description provided for @effectuee.
  ///
  /// In en, this message translates to:
  /// **'Performed'**
  String get effectuee;

  /// No description provided for @actionprincipale.
  ///
  /// In en, this message translates to:
  /// **'Main Actions'**
  String get actionprincipale;

  /// No description provided for @ajoutersolde.
  ///
  /// In en, this message translates to:
  /// **'Add Balance'**
  String get ajoutersolde;

  /// No description provided for @rechargezcompte.
  ///
  /// In en, this message translates to:
  /// **'Top up a customer\'s account by scanning their QR code'**
  String get rechargezcompte;

  /// No description provided for @montantajouter.
  ///
  /// In en, this message translates to:
  /// **'Amount to add'**
  String get montantajouter;

  /// No description provided for @scanerajoutermontant.
  ///
  /// In en, this message translates to:
  /// **'Enter the amount then scan the customer\'s QR code'**
  String get scanerajoutermontant;

  /// No description provided for @scannercleint.
  ///
  /// In en, this message translates to:
  /// **'Client Scanner'**
  String get scannercleint;

  /// No description provided for @gererrecompence.
  ///
  /// In en, this message translates to:
  /// **'Manage Rewards'**
  String get gererrecompence;

  /// No description provided for @aidezclientconsulterrecompence.
  ///
  /// In en, this message translates to:
  /// **'Help customers view and claim their rewards'**
  String get aidezclientconsulterrecompence;

  /// No description provided for @scannerrecompence.
  ///
  /// In en, this message translates to:
  /// **'Scan the customer\'s QR code to access their rewards'**
  String get scannerrecompence;

  /// No description provided for @scannerrecompenceqr.
  ///
  /// In en, this message translates to:
  /// **'Scanner for Rewards'**
  String get scannerrecompenceqr;

  /// No description provided for @commentmarche.
  ///
  /// In en, this message translates to:
  /// **'How does it work?'**
  String get commentmarche;

  /// No description provided for @validation.
  ///
  /// In en, this message translates to:
  /// **'Validation'**
  String get validation;

  /// No description provided for @confiremeztransaction.
  ///
  /// In en, this message translates to:
  /// **'Confirm transactions and notify the customer of changes'**
  String get confiremeztransaction;

  /// No description provided for @veuillez.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount (> 0)'**
  String get veuillez;

  /// No description provided for @soldede.
  ///
  /// In en, this message translates to:
  /// **'Balance of'**
  String get soldede;

  /// No description provided for @dhajoute.
  ///
  /// In en, this message translates to:
  /// **'DH added successfully!'**
  String get dhajoute;

  /// No description provided for @gerervospreference.
  ///
  /// In en, this message translates to:
  /// **'Manage your preferences'**
  String get gerervospreference;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @langue.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get langue;

  /// No description provided for @magazin.
  ///
  /// In en, this message translates to:
  /// **'Mukhlis shop'**
  String get magazin;

  /// No description provided for @compte.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get compte;

  /// No description provided for @profil.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profil;

  /// No description provided for @informationpers.
  ///
  /// In en, this message translates to:
  /// **'Personal information'**
  String get informationpers;

  /// No description provided for @securite.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get securite;

  /// No description provided for @motpassesecurise.
  ///
  /// In en, this message translates to:
  /// **'Mot de passe et sécurité'**
  String get motpassesecurise;

  /// No description provided for @confidentialite.
  ///
  /// In en, this message translates to:
  /// **'Confidentiality'**
  String get confidentialite;

  /// No description provided for @paramconfidentialite.
  ///
  /// In en, this message translates to:
  /// **'Privacy Settings'**
  String get paramconfidentialite;

  /// No description provided for @nomcomplet.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get nomcomplet;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'E-mail address'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phone;

  /// No description provided for @addresse.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addresse;

  /// No description provided for @ville.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get ville;

  /// No description provided for @codepostale.
  ///
  /// In en, this message translates to:
  /// **'Postal Code'**
  String get codepostale;

  /// No description provided for @nouveaumotpasse.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get nouveaumotpasse;

  /// No description provided for @laisserviede.
  ///
  /// In en, this message translates to:
  /// **'Leave blank to not change'**
  String get laisserviede;

  /// No description provided for @confirmer.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmer;

  /// No description provided for @champsrequis.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get champsrequis;

  /// No description provided for @necorrespontpas.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get necorrespontpas;

  /// No description provided for @changerimage.
  ///
  /// In en, this message translates to:
  /// **'Change profile picture'**
  String get changerimage;

  /// No description provided for @galerie.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get galerie;

  /// No description provided for @cout.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get cout;

  /// No description provided for @newsolde.
  ///
  /// In en, this message translates to:
  /// **'New balance'**
  String get newsolde;

  /// No description provided for @annuler.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get annuler;

  /// No description provided for @confirmerechange.
  ///
  /// In en, this message translates to:
  /// **'Confirm the exchange'**
  String get confirmerechange;

  /// No description provided for @descriptionnondisponible.
  ///
  /// In en, this message translates to:
  /// **'Description not available'**
  String get descriptionnondisponible;

  /// No description provided for @ilvousmanque.
  ///
  /// In en, this message translates to:
  /// **'you miss'**
  String get ilvousmanque;

  /// No description provided for @disponible.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get disponible;

  /// No description provided for @chargementdesrecompences.
  ///
  /// In en, this message translates to:
  /// **'Loading rewards...'**
  String get chargementdesrecompences;

  /// No description provided for @oups.
  ///
  /// In en, this message translates to:
  /// **'Oops! An error has occurred'**
  String get oups;

  /// No description provided for @ressayer.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get ressayer;

  /// No description provided for @choisissezrecompence.
  ///
  /// In en, this message translates to:
  /// **'Choose a reward that makes you happy'**
  String get choisissezrecompence;

  /// No description provided for @aucunerecompence.
  ///
  /// In en, this message translates to:
  /// **'No rewards available'**
  String get aucunerecompence;

  /// No description provided for @revenez.
  ///
  /// In en, this message translates to:
  /// **'Come back later to discover our new exclusive rewards'**
  String get revenez;

  /// No description provided for @felicitation.
  ///
  /// In en, this message translates to:
  /// **'Congratulations'**
  String get felicitation;

  /// No description provided for @vousvenezgagner.
  ///
  /// In en, this message translates to:
  /// **'You just won'**
  String get vousvenezgagner;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'points'**
  String get points;

  /// No description provided for @solderestant.
  ///
  /// In en, this message translates to:
  /// **'Remaining balance'**
  String get solderestant;

  /// No description provided for @terminer.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get terminer;

  /// No description provided for @scannerajoutersolde.
  ///
  /// In en, this message translates to:
  /// **'Customer Scanner - Add Balance'**
  String get scannerajoutersolde;

  /// No description provided for @scannervoiroffre.
  ///
  /// In en, this message translates to:
  /// **'Customer Scanner - See Offers'**
  String get scannervoiroffre;

  /// No description provided for @chnangercamera.
  ///
  /// In en, this message translates to:
  /// **'Change camera'**
  String get chnangercamera;

  /// No description provided for @scannerpourajoutersolde.
  ///
  /// In en, this message translates to:
  /// **'Scan the customer\'s QR code to add balance'**
  String get scannerpourajoutersolde;

  /// No description provided for @scannerpourvoiroffre.
  ///
  /// In en, this message translates to:
  /// **'Scan the customer\'s QR code to see offers'**
  String get scannerpourvoiroffre;

  /// No description provided for @vousserezrederigervers.
  ///
  /// In en, this message translates to:
  /// **'After adding the balance, you will be redirected to the available offers'**
  String get vousserezrederigervers;

  /// No description provided for @dh.
  ///
  /// In en, this message translates to:
  /// **'DH'**
  String get dh;

  /// No description provided for @ajoutencour.
  ///
  /// In en, this message translates to:
  /// **'Adding current balance...'**
  String get ajoutencour;

  /// No description provided for @traitementencouor.
  ///
  /// In en, this message translates to:
  /// **'Processing in progress...'**
  String get traitementencouor;

  /// No description provided for @redirectionversoffres.
  ///
  /// In en, this message translates to:
  /// **'Redirection to offers after adding...'**
  String get redirectionversoffres;

  /// No description provided for @qrcodeinvalide.
  ///
  /// In en, this message translates to:
  /// **'Invalid QR code: Incorrect format'**
  String get qrcodeinvalide;

  /// No description provided for @erreurtraitement.
  ///
  /// In en, this message translates to:
  /// **'Error while processing:'**
  String get erreurtraitement;

  /// No description provided for @qrreconu.
  ///
  /// In en, this message translates to:
  /// **'QR recognized'**
  String get qrreconu;

  /// No description provided for @navigation.
  ///
  /// In en, this message translates to:
  /// **'Navigation'**
  String get navigation;

  /// No description provided for @confirmation.
  ///
  /// In en, this message translates to:
  /// **'Confirmation'**
  String get confirmation;

  /// No description provided for @etevoussur.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get etevoussur;

  /// No description provided for @connecterpourcontinuer.
  ///
  /// In en, this message translates to:
  /// **'Log in to continue'**
  String get connecterpourcontinuer;

  /// No description provided for @veuillezsaisiremail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get veuillezsaisiremail;

  /// No description provided for @formatinvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid email format'**
  String get formatinvalid;

  /// No description provided for @motpasse.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get motpasse;

  /// No description provided for @veuillezsaisirpassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get veuillezsaisirpassword;

  /// No description provided for @motpassecotenir.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least 6 characters'**
  String get motpassecotenir;

  /// No description provided for @connexion.
  ///
  /// In en, this message translates to:
  /// **'Connection...'**
  String get connexion;

  /// No description provided for @seconnecter.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get seconnecter;

  /// No description provided for @decouvrezmeilleures.
  ///
  /// In en, this message translates to:
  /// **'Discover our best promotions'**
  String get decouvrezmeilleures;

  /// No description provided for @gererrecompenses.
  ///
  /// In en, this message translates to:
  /// **'Manage your rewards easily in Arabic'**
  String get gererrecompenses;

  /// No description provided for @trouvermeilleur.
  ///
  /// In en, this message translates to:
  /// **'Find the perfect gift among our best offers'**
  String get trouvermeilleur;

  /// No description provided for @chargementoffres.
  ///
  /// In en, this message translates to:
  /// **'Loading offers...'**
  String get chargementoffres;

  /// No description provided for @aucunoffre.
  ///
  /// In en, this message translates to:
  /// **'No offers available'**
  String get aucunoffre;

  /// No description provided for @commencezparcree.
  ///
  /// In en, this message translates to:
  /// **'Start by creating your first offer to attract your customers'**
  String get commencezparcree;

  /// No description provided for @offresupprimersucces.
  ///
  /// In en, this message translates to:
  /// **'Offer successfully deleted'**
  String get offresupprimersucces;

  /// No description provided for @supprimeroffre.
  ///
  /// In en, this message translates to:
  /// **'Delete offer'**
  String get supprimeroffre;

  /// No description provided for @etesvoussur.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this offer? This action is irreversible.'**
  String get etesvoussur;

  /// No description provided for @supprimerrecompence.
  ///
  /// In en, this message translates to:
  /// **'Remove reward'**
  String get supprimerrecompence;

  /// No description provided for @etesvoussurdesupprimerrecompense.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this reward? This action is irreversible.'**
  String get etesvoussurdesupprimerrecompense;
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
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

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
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
