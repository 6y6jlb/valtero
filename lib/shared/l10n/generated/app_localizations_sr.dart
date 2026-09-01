// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Serbian (`sr`).
class AppLocalizationsSr extends AppLocalizations {
  AppLocalizationsSr([String locale = 'sr']) : super(locale);

  @override
  String get appTitle => 'Valtero';

  @override
  String get navDashboard => 'Pregled';

  @override
  String get navExpenses => 'Troškovi';

  @override
  String get recentOperations => 'Nedavne operacije';

  @override
  String get navAdd => 'Dodaj';

  @override
  String get navTags => 'Oznake';

  @override
  String get navCurrency => 'Valuta';

  @override
  String get navExport => 'Izvoz';

  @override
  String get navSettings => 'Podešavanja';

  @override
  String get settingsAppearance => 'Izgled';

  @override
  String get settingsCurrency => 'Valuta i kursevi';

  @override
  String get settingsExport => 'Izvoz';

  @override
  String get settingsIntegrations => 'Integracije';

  @override
  String get settingsDebug => 'Otklanjanje grešaka i logovi';

  @override
  String get integrationConnected => 'Povezano';

  @override
  String get integrationNotConnected => 'Nije povezano';

  @override
  String get integrationTestConnection => 'Proveri vezu';

  @override
  String get integrationSave => 'Sačuvaj';

  @override
  String get integrationDisconnect => 'Prekini vezu';

  @override
  String get connectionOk => 'Veza uspešna';

  @override
  String get connectionFailed => 'Veza nije uspela';

  @override
  String get connectionNetwork =>
      'Nema mreže ili DNS nije uspeo. Proveri internet, VPN ili DNS i pokušaj ponovo.';

  @override
  String get connectionMissingFields => 'Popunite sva obavezna polja';

  @override
  String get connectionInvalidToken => 'Token bota nije važeći';

  @override
  String get connectionInvalidChat =>
      'Chat id nije važeći ili bot nema pristup';

  @override
  String get connectionInvalidKey => 'API ključ nije važeći';

  @override
  String get showSecret => 'Prikaži';

  @override
  String get hideSecret => 'Sakrij';

  @override
  String get integrationTelegramTitle => 'Telegram';

  @override
  String get integrationTelegramDescription =>
      'Šalji izvoz troškova u Telegram chat preko bota.';

  @override
  String get integrationFrankfurterTitle => 'Frankfurter';

  @override
  String get integrationFrankfurterDescription =>
      'Besplatni ECB kursevi (bez API ključa). Koriste se automatski ako ExchangeRate-API nije povezan.';

  @override
  String get integrationFrankfurterHint =>
      'Ugrađeni rezervni izvor. Provera api.frankfurter.dev — ako padne, kursevi se neće osvežiti dok mreža/DNS ne proradi. Samo valute iz ECB skupa.';

  @override
  String get integrationExchangeRateApiTitle => 'ExchangeRate-API';

  @override
  String get integrationExchangeRateApiDescription =>
      'Kursevi preko ključa sa exchangerate-api.com (API v6). Ključevi sa exchangeratesapi.io ne rade. Bez ključa koristi se Frankfurter (ECB).';

  @override
  String get exchangeRateApiEnabled => 'Koristi ExchangeRate-API za kurseve';

  @override
  String get integrationGoogleDriveSyncTitle => 'Google Drive sinhronizacija';

  @override
  String get integrationGoogleDriveSyncDescription =>
      'Šifrovana automatska sinhronizacija između uređaja preko Google Drive-a. Google ne vidi troškove — samo šifrovani sadržaj.';

  @override
  String get googleDriveSignIn => 'Prijava preko Google-a';

  @override
  String get googleDriveSyncNow => 'Sinhronizuj sada';

  @override
  String get googleDriveSyncOk => 'Sinhronizacija završena';

  @override
  String get googleDriveSyncPassphrase => 'Lozinka sinhronizacije';

  @override
  String get googleDriveSyncPassphraseHint =>
      'Koristi se samo na uređaju za šifrovanje. Google je nikad ne dobija. Ista lozinka na svim uređajima.';

  @override
  String get googleDrivePassphraseTooShort =>
      'Lozinka mora imati najmanje 8 karaktera';

  @override
  String get googleDriveWrongPassphrase =>
      'Pogrešna lozinka za udaljenu rezervnu kopiju';

  @override
  String get googleDriveMissingClientId =>
      'Nije podešen Google OAuth client id. Kopiraj local.oauth.env.example u local.oauth.env, postavi GOOGLE_OAUTH_CLIENT_ID_DESKTOP / _ANDROID i ponovo builduj (make run-*).';

  @override
  String get googleDriveReauthRequired => 'Prijavite se ponovo preko Google-a';

  @override
  String get googleDriveSignInFailed => 'Prijava preko Google-a nije uspela';

  @override
  String get googleDriveAuthCanceled => 'Prijava preko Google-a je otkazana';

  @override
  String get googleDriveAccessDenied =>
      'Google je odbio pristup. Dozvoli Drive dozvole i pokušaj ponovo.';

  @override
  String get googleDriveAndroidCustomUriHint =>
      'Na Androidu otvori Google Cloud Console → Android OAuth klijent → Advanced settings i uključi „Custom URI scheme“, pa pokušaj ponovo. Google po podrazumevanom blokira ovaj redirect za nove Android klijente.';

  @override
  String get googleDriveMissingClientSecret =>
      'Nedostaje client secret za Desktop OAuth. U Google Cloud Console otvori Desktop OAuth klijent, kopiraj Client secret u local.oauth.env kao GOOGLE_OAUTH_CLIENT_SECRET_DESKTOP i ponovo builduj (make run-linux).';

  @override
  String googleDriveLastSynced(String when) {
    return 'Poslednja sinhronizacija: $when';
  }

  @override
  String get relativeTimeJustNow => 'Upravo sada';

  @override
  String relativeTimeMinutesAgo(int count) {
    return 'pre $count min';
  }

  @override
  String relativeTimeHoursAgo(int count) {
    return 'pre $count h';
  }

  @override
  String relativeTimeDaysAgo(int count) {
    return 'pre $count d';
  }

  @override
  String get googleDriveSyncStatusHint => 'Vreme poslednje sinhronizacije';

  @override
  String get actionSuccessStatusHint => 'Vreme poslednje akcije';

  @override
  String get googleDriveSharedTitle =>
      'Zajednička sinhronizacija (drugi Google nalozi)';

  @override
  String get googleDriveSharedDescription =>
      'Podeli šifrovani fajl sa drugom osobom. Zahteva dozvolu drive.file; javno izdanje može zahtevati OAuth verifikaciju.';

  @override
  String get googleDriveShareEmail => 'Email saradnika';

  @override
  String get googleDriveShareAdd => 'Podeli emailom';

  @override
  String get googleDriveShareOk => 'Uspešno podeljeno';

  @override
  String get googleDriveShareFailed => 'Nije moguće podeliti fajl';

  @override
  String get googleDriveInvalidEmail => 'Unesite ispravan email';

  @override
  String get googleDriveRemoteNewerSchemaTitle =>
      'Potrebno je ažuriranje aplikacije';

  @override
  String googleDriveRemoteNewerSchema(
    int remoteSchema,
    int localSchema,
    String remoteApp,
  ) {
    return 'Podaci u oblaku su napisani novijom aplikacijom (šema $remoteSchema, app $remoteApp). Ovaj uređaj ima šemu $localSchema. Sinhronizacija je zaustavljena da se ne bi pregazili noviji podaci. Ažurirajte aplikaciju i pokušajte ponovo.';
  }

  @override
  String get googleDriveUnsupportedFormat =>
      'Format fajla sinhronizacije nije podržan ovom verzijom aplikacije';

  @override
  String get googleDriveHelpTitle => 'Kako radi Google Drive sinhronizacija';

  @override
  String get googleDriveHelpSameAccountTitle =>
      'Isti Google nalog na drugom uređaju';

  @override
  String get googleDriveHelpSameAccountBody =>
      '1. Na ovom uređaju: postavi lozinku sinhronizacije i prijavi se preko Google-a.\n2. Na drugom uređaju: prijavi se istim nalogom i unesi istu lozinku.\n3. Sinhronizacija ide posle prijave i na dugme Sinhronizuj. Ništa više nije potrebno.';

  @override
  String get googleDriveHelpCrossAccountTitle => 'Različiti Google nalozi';

  @override
  String get googleDriveHelpCrossAccountBody =>
      'Nalog 1 (vlasnik):\n1. Postavi lozinku i prijavi se preko Google-a.\n2. Pod „Podeli sa drugim nalogom“ unesi email naloga 2 i podeli.\n\nNalog 2 (učesnik):\n1. Pritisni „Pridruži se deljenoj sinhronizaciji“.\n2. Prijavi se preko Google-a (traži se širi pristup Drive-u da se nađe deljeni fajl).\n3. Izaberi deljeni fajl i unesi istu lozinku koju koristi nalog 1.\n4. Sinhronizuj razmenjuje podatke u oba smera preko tog fajla.';

  @override
  String get googleDriveHelpPassphraseNote =>
      'Lozinka nikad ne ide na Google — tamo je samo šifrovani sadržaj. Svi koji sinhronizuju moraju znati i uneti istu lozinku.';

  @override
  String get googleDriveHelpRegenNote =>
      'Ako posle povezivanja promeniš ili regenerišeš lozinku, drugi uređaji i nalozi prestaju da dešifruju dok ne unesu novu.';

  @override
  String get googleDriveJoinShared => 'Pridruži se deljenoj sinhronizaciji';

  @override
  String get googleDriveJoinPickTitle => 'Deljeni fajlovi sinhronizacije';

  @override
  String get googleDriveJoinPickEmpty =>
      'Nema deljenih Valtero fajlova. Traži od vlasnika da prvo podeli sa ovim Google nalogom.';

  @override
  String get googleDriveJoinConfirm => 'Pridruži se';

  @override
  String get googleDriveJoinedAs => 'Pridružen deljenoj sinhronizaciji';

  @override
  String get googleDriveLeaveShared => 'Napusti deljenu sinhronizaciju';

  @override
  String get googleDrivePassphraseChangeTitle =>
      'Promeniti lozinku sinhronizacije?';

  @override
  String get googleDrivePassphraseChangeBody =>
      'Drugi uređaji i nalozi prestaju da se sinhronizuju dok ne unesu novu lozinku. Nastaviti?';

  @override
  String googleDriveSharedFrom(String email) {
    return 'Od $email';
  }

  @override
  String fetchAllRatesFrom(String service) {
    return 'Preuzmi sve kurseve iz $service';
  }

  @override
  String fetchAllRatesDone(int count, String service) {
    return 'Sačuvano $count kurseva iz $service u lokalni keš';
  }

  @override
  String fetchRateFromService(String service) {
    return 'Preuzmi iz $service';
  }

  @override
  String rateFetchedFromCache(String service) {
    return 'Kurs iz lokalnog keša ($service). Pritisni osvežavanje da preuzmeš ponovo.';
  }

  @override
  String get rateRefreshPair => 'Osveži ovaj kurs';

  @override
  String ratesFetchCooldown(int minutes) {
    return 'Sledeći mrežni zahtev za $minutes min (besplatni API limit)';
  }

  @override
  String flagUnavailableTooltip(String code) {
    return 'Nema zastave za $code';
  }

  @override
  String get telegramNotConnectedHint =>
      'Poveži Telegram u Podešavanja → Integracije da šalješ izvoz tamo.';

  @override
  String get openTelegramIntegration => 'Otvori Telegram podešavanja';

  @override
  String get openExchangeRateApiIntegration => 'Podesi ExchangeRate-API';

  @override
  String get rateSourceConnected => 'Kursevi: ExchangeRate-API (povezano)';

  @override
  String get rateSourceFrankfurter => 'Frankfurter';

  @override
  String get debugLoggingEnabled => 'Detaljno logovanje';

  @override
  String get debugLoggingDescription =>
      'Kada je uključeno, pišu se detaljni događaji. Greške se uvek beleže. Tajne (API ključevi, tokeni, chat id, fraze) nikad se ne pišu.';

  @override
  String get debugViewLogs => 'Sadržaj loga';

  @override
  String get debugShareLogs => 'Pošalji programeru';

  @override
  String get debugCopyLogs => 'Kopiraj logove';

  @override
  String get debugClearLogs => 'Obriši logove';

  @override
  String get debugLogsEmpty => 'Još nema unosa u logu.';

  @override
  String get debugLogsShared => 'Log fajl spreman za deljenje';

  @override
  String get debugLogsCopied => 'Logovi kopirani u clipboard';

  @override
  String get debugLogsCleared => 'Logovi obrisani';

  @override
  String get settingsDataSync => 'Rezervna kopija i sinhronizacija';

  @override
  String get dataSyncTitle => 'Rezervna kopija i sinhronizacija';

  @override
  String get dataSyncExport => 'Izvoz';

  @override
  String get dataSyncImport => 'Uvoz';

  @override
  String get dataSyncChooseFile => 'Izaberi fajl kopije';

  @override
  String get dataSyncFileSelected => 'Fajl kopije izabran';

  @override
  String get dataSyncImportFromFile => 'Uvoz iz fajla';

  @override
  String get dataSyncImportMergeHint =>
      'Uvoz podataka iz fajla. Postojeći troškovi neće biti prepisani — dodaće se novi podaci.';

  @override
  String get dataSyncGuide =>
      'Izvoz: napravite šifrovanu rezervnu kopiju sa lozinka-frazom, zatim sačuvajte ili podelite fajl. Uvoz: učitajte taj fajl na ovom ili drugom uređaju i unesite istu frazu da biste vratili podatke. Sinhronizacija znači razmenu ovog fajla između uređaja.';

  @override
  String get dataSyncShareManualTitle => 'Kako poslati rezervnu kopiju';

  @override
  String get dataSyncShareManualGuide =>
      'Ugrađeno deljenje nije dostupno na ovoj platformi. Nakon što sačuvate fajl, pošaljite ga sami, na primer:\n• priložite ga u email;\n• pošaljite ga u Telegramu (ili drugom mesendžeru) kao dokument;\n• otpremite ga u cloud (Google Drive, Dropbox, …) ili kopirajte na USB.\nNa drugom uređaju otvorite Rezervna kopija i sinhronizacija → Uvoz → izaberite fajl i unesite istu lozinka-frazu.';

  @override
  String get dataSyncCopyFilePath => 'Kopiraj putanju fajla';

  @override
  String get dataSyncPassphrase => 'Lozinka-fraza';

  @override
  String get dataSyncGeneratePassphrase => 'Generiši frazu';

  @override
  String get dataSyncCopyPassphrase => 'Kopiraj frazu';

  @override
  String get dataSyncGenerateShort => 'Generiši';

  @override
  String get dataSyncCopyShort => 'Kopiraj';

  @override
  String get dataSyncShowPassphrase => 'Prikaži frazu';

  @override
  String get dataSyncHidePassphrase => 'Sakrij frazu';

  @override
  String get dataSyncApplyAppearance => 'Primeni izgled iz kopije';

  @override
  String get dataSyncApplyAppearanceHint =>
      'Vraća temu, jezik, formate novca i datuma, vremensku zonu i izveštajne valute iz rezervne kopije. Ostavi isključeno da zadržiš trenutni izgled na ovom uređaju.';

  @override
  String get dataSyncPassphraseWarning =>
      'Sačuvajte ovu frazu na sigurnom mestu. Bez nje se rezervna kopija ne može otvoriti.';

  @override
  String get dataSyncExportDone => 'Rezervna kopija sačuvana';

  @override
  String get dataSyncExportFailed => 'Nije moguće sačuvati rezervnu kopiju';

  @override
  String dataSyncImportDone(int expenses, int tags, int payments) {
    return 'Uvezeno $expenses troškova, $tags oznaka, $payments načina plaćanja';
  }

  @override
  String get dataSyncWrongPassphrase => 'Pogrešna fraza ili oštećen fajl';

  @override
  String get dataSyncUnsupportedFormat =>
      'Nepodržan ili nevažeći fajl rezervne kopije';

  @override
  String get dataSyncNewerSchema =>
      'Ova kopija zahteva noviju verziju aplikacije';

  @override
  String get dataSyncIntegrationsNotTransferred =>
      'API ključevi i Telegram podaci nisu uključeni u rezervne kopije.';

  @override
  String get dataSyncGoogleDriveHint =>
      'Možete i automatsku šifrovanu sinhronizaciju preko Google Drive-a — rezervne kopije se ažuriraju između uređaja bez ručne razmene fajlova.';

  @override
  String get dataSyncGoogleDriveSetup => 'Poveži Google Drive Sync';

  @override
  String get dataSyncGoogleDriveManage =>
      'Otvori podešavanja Google Drive Sync';

  @override
  String dataSyncImportDoneWithDuplicates(
    int expenses,
    int tags,
    int payments,
    int skipped,
  ) {
    return 'Uvezeno $expenses troškova, $tags oznaka, $payments načina plaćanja (preskočeno duplikata: $skipped)';
  }

  @override
  String get dataSyncDuplicatesFoundTitle => 'Pronađeni mogući duplikati';

  @override
  String get dataSyncDuplicatesFoundHint =>
      'Ovi dolazni troškovi liče na one koje već imate (isti dan, iznos i valuta). Izaberite kako da postupite sa svakim.';

  @override
  String get dataSyncMarkAsDuplicate => 'Označi kao duplikat';

  @override
  String get dataSyncMarkAsUnique => 'Označi kao jedinstven';

  @override
  String get dataSyncMarkSelectedAsDuplicate => 'Izabrani → duplikati';

  @override
  String get dataSyncMarkSelectedAsUnique => 'Izabrani → jedinstveni';

  @override
  String get dataSyncMarkAllAsDuplicate => 'Svi → duplikati';

  @override
  String get dataSyncMarkAllAsUnique => 'Svi → jedinstveni';

  @override
  String get dataSyncContinueImport => 'Nastavi uvoz';

  @override
  String get dataSyncIncomingExpense => 'Dolazni';

  @override
  String get dataSyncExistingExpense => 'Postojeći';

  @override
  String get possibleDuplicateTooltip => 'Mogući duplikat';

  @override
  String possibleDuplicatesBannerTitle(int count) {
    return 'Mogući duplikati ($count)';
  }

  @override
  String get duplicateReviewSheetTitle => 'Mogući duplikati';

  @override
  String get duplicateMarkNotDuplicate => 'Nije duplikat';

  @override
  String get duplicateConflictDialogTitle => 'Pronađen sličan trošak';

  @override
  String get duplicateConflictDialogHint =>
      'Već postoji trošak sa istim danom, iznosom i valutom.';

  @override
  String get duplicateSaveAsUnique => 'Sačuvaj kao jedinstven';

  @override
  String get duplicateDeleteMatchAndSave => 'Obriši podudaranje i sačuvaj';

  @override
  String get duplicateYourExpense => 'Vaš trošak';

  @override
  String get duplicateMatchingExpense => 'Podudarni trošak';

  @override
  String get dashboardRestoreFromBackup => 'Vrati iz rezervne kopije';

  @override
  String get selectCountry => 'Izaberi zemlju';

  @override
  String get addExpense => 'Dodaj trošak';

  @override
  String get editExpense => 'Izmeni trošak';

  @override
  String get expenseDetails => 'Detalji troška';

  @override
  String get close => 'Zatvori';

  @override
  String get amount => 'Iznos';

  @override
  String get amountRequired => 'Unesite ispravan iznos';

  @override
  String get currency => 'Valuta';

  @override
  String get saveAsIs => 'Sačuvaj kako jeste';

  @override
  String get convertTo => 'Konvertuj u';

  @override
  String exchangeRate(String rate) {
    return 'Kurs: $rate';
  }

  @override
  String get rateUnavailable => 'Nema kursa za ovaj par';

  @override
  String get setRateNow => 'Postavi kurs';

  @override
  String get setManualRateTitle => 'Postavi kurs';

  @override
  String setManualRateHint(String base, String target) {
    return 'Koliko $target za 1 $base';
  }

  @override
  String get tag => 'Oznaka';

  @override
  String get note => 'Beleška';

  @override
  String get date => 'Datum';

  @override
  String get save => 'Sačuvaj';

  @override
  String get delete => 'Obriši';

  @override
  String get cancel => 'Otkaži';

  @override
  String get yes => 'Da';

  @override
  String get no => 'Ne';

  @override
  String get confirmDeleteExpense => 'Obrisati ovaj trošak?';

  @override
  String get confirmDeleteExpenseDescription =>
      'Ovaj trošak biće trajno obrisan.';

  @override
  String get expenseDeleted => 'Trošak obrisan';

  @override
  String bulkSelectedCount(int count) {
    return 'Izabrano: $count';
  }

  @override
  String bulkAndMore(int count) {
    return '…i još $count';
  }

  @override
  String get bulkDeleteTitle => 'Obrisati troškove?';

  @override
  String bulkDeleteDescription(String list) {
    return 'Ovi troškovi biće trajno obrisani:\n$list';
  }

  @override
  String get bulkChangeTags => 'Promeni oznake';

  @override
  String get bulkChangeTagsTitle => 'Promeni oznake';

  @override
  String bulkChangeTagsDescription(String list) {
    return 'Nove oznake zameniće postojeće na:\n$list';
  }

  @override
  String get bulkChangeCountry => 'Promeni zemlju';

  @override
  String get bulkChangeCountryTitle => 'Promeni zemlju';

  @override
  String bulkChangeCountryDescription(String list) {
    return 'Zemlja će biti ažurirana za:\n$list';
  }

  @override
  String get bulkChangeCurrency => 'Promeni valutu';

  @override
  String get bulkChangeCurrencyTitle => 'Promeni valutu';

  @override
  String bulkChangeCurrencyDescription(String currency, String list) {
    return 'Iznosi će biti konvertovani u $currency za:\n$list';
  }

  @override
  String bulkExpensesDeleted(int count) {
    return 'Obrisano troškova: $count';
  }

  @override
  String bulkExpensesUpdated(int count) {
    return 'Ažurirano troškova: $count';
  }

  @override
  String get bulkCurrencyRateUnavailable =>
      'Nije moguće konvertovati: kurs nije dostupan';

  @override
  String get add => 'Dodaj';

  @override
  String get settings => 'Podešavanja';

  @override
  String get reportingCurrencies => 'Valute izveštaja';

  @override
  String get primaryCurrency => 'Glavna valuta';

  @override
  String get apiKey => 'Ključ ExchangeRate-API';

  @override
  String get validateKey => 'Proveri i poveži';

  @override
  String get refreshRates => 'Osveži kurseve sada';

  @override
  String get manualRates => 'Ručni kursevi';

  @override
  String get baseCurrency => 'Iz';

  @override
  String get targetCurrency => 'U';

  @override
  String get rate => 'Kurs';

  @override
  String get tagsTitle => 'Oznake';

  @override
  String get suggestedTags => 'Predložene oznake';

  @override
  String get detectCountry => 'Ponovo otkrij zemlju';

  @override
  String get country => 'Zemlja';

  @override
  String get defaultTags => 'Podrazumevane oznake';

  @override
  String get dismiss => 'Odbaci';

  @override
  String get exportTitle => 'Izvoz';

  @override
  String get exportCsv => 'CSV';

  @override
  String get exportJson => 'JSON';

  @override
  String get saveFile => 'Sačuvaj fajl';

  @override
  String get share => 'Podeli';

  @override
  String get copyAs => 'Kopiraj kao';

  @override
  String get copiedToClipboard => 'Kopirano u clipboard';

  @override
  String get sendTelegram => 'Pošalji na Telegram';

  @override
  String get telegramBotToken => 'Token Telegram bota';

  @override
  String get telegramChatId => 'Telegram chat id';

  @override
  String get telegramEnabled => 'Omogući Telegram';

  @override
  String get summaryTotal => 'Ukupno';

  @override
  String get byTag => 'Po oznaci';

  @override
  String get byPeriod => 'Po periodu';

  @override
  String get displayCurrency => 'Valuta prikaza';

  @override
  String get noExpenses => 'Još nema troškova';

  @override
  String get expensesEmptyTitle => 'Još nema troškova';

  @override
  String get expensesEmptyBody =>
      'Dodajte prvi trošak da biste videli listu, rezime i grafikone.';

  @override
  String get filterTag => 'Filter oznaka';

  @override
  String get filterCurrency => 'Filter valuta';

  @override
  String get all => 'Sve';

  @override
  String get theme => 'Tema';

  @override
  String get locale => 'Jezik';

  @override
  String get moneyFormat => 'Prikaz novca';

  @override
  String get moneyFormatPreview => 'Pregled';

  @override
  String get moneyFormatLocaleSymbol => 'Lokalno sa simbolom';

  @override
  String get moneyFormatLocaleCode => 'Lokalno sa kodom valute';

  @override
  String get moneyFormatPlain => 'Jednostavan (1234.56 CODE)';

  @override
  String get dateFormat => 'Prikaz datuma';

  @override
  String get timeZone => 'Vremenska zona';

  @override
  String timeZoneSystem(String id) {
    return 'Sistemska ($id)';
  }

  @override
  String get system => 'Sistem';

  @override
  String get light => 'Svetla';

  @override
  String get dark => 'Tamna';

  @override
  String get keyValid => 'API ključ je ispravan';

  @override
  String get keyInvalid => 'API ključ nije ispravan';

  @override
  String get ratesRefreshed => 'Kursevi osveženi';

  @override
  String get exportDone => 'Izvoz spreman';

  @override
  String get telegramSent => 'Poslato na Telegram';

  @override
  String get telegramFailed => 'Slanje na Telegram nije uspelo';

  @override
  String get telegramSetupNeeded =>
      'Uključi Telegram i unesi token bota i chat id da bi slao izvoze.';

  @override
  String get shareUnsupported =>
      'Deljenje fajlova nije dostupno na ovoj platformi.';

  @override
  String get shareFailed => 'Nije moguće podeliti fajl izvoza.';

  @override
  String get untagged => 'Bez oznake';

  @override
  String get periodDay => 'Dan';

  @override
  String get periodWeek => 'Nedelja';

  @override
  String get periodMonth => 'Mesec';

  @override
  String get newTag => 'Nova oznaka';

  @override
  String get addTag => 'Dodaj oznaku';

  @override
  String get tagGroceries => 'Namirnice';

  @override
  String get tagTransport => 'Prevoz';

  @override
  String get tagHousing => 'Stanovanje';

  @override
  String get tagDining => 'Hrana napolju';

  @override
  String get tagHealth => 'Zdravlje';

  @override
  String get tagEntertainment => 'Zabava';

  @override
  String get tagShopping => 'Kupovina';

  @override
  String get tagTravel => 'Putovanja';

  @override
  String get tagUtilities => 'Režije';

  @override
  String get tagCash => 'Gotovina';

  @override
  String get tagCard => 'Kartica';

  @override
  String get tagCrypto => 'Kripto';

  @override
  String get tagTransfer => 'Bankovni transfer';

  @override
  String get tagEwallet => 'E-novčanik';

  @override
  String tripTag(String region) {
    return 'Putovanje: $region';
  }

  @override
  String get tagColor => 'Boja';

  @override
  String get tagColorNone => 'Nijedna';

  @override
  String get chartBy => 'Grafikon po';

  @override
  String get chartByTags => 'Oznake';

  @override
  String get chartByTagCountry => 'Oznake zemlje';

  @override
  String get chartByPayment => 'Način plaćanja';

  @override
  String get chartByTagTrip => 'Oznake putovanja';

  @override
  String get chartByTagCustom => 'Prilagođene oznake';

  @override
  String get chartTagKindHint =>
      'Svaki trošak se računa jednom unutar ove vrste oznake; nedostajuće oznake se prikazuju kao nije postavljeno';

  @override
  String chartMissingRatesAlert(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count troškova prikazano bez kursa konverzije',
      few: '$count troška prikazana bez kursa konverzije',
      one: '1 trošak prikazan bez kursa konverzije',
    );
    return '$_temp0';
  }

  @override
  String get chartHelpTitle => 'O grafikonu';

  @override
  String get chartTypeDonut => 'Kružni grafikon';

  @override
  String get chartTypeColumn => 'Stubičasti grafikon';

  @override
  String get chartHelpBody =>
      'Grafikon uključuje troškove u svim valutama. Kada kurs nedostaje, iznosi se prikazuju u originalnoj valuti. Ukupni iznosi mogu mešati valute dok kursevi nisu postavljeni.';

  @override
  String get expensesSummaryHelpTitle => 'O rezimeu troškova';

  @override
  String get expensesSummaryHelpBody =>
      'Ukupni iznosi su grupisani po sačuvanoj valuti. Dugme za konverziju prikazuje iznose u listi u jednoj valuti; konvertovani ukupni iznos pokazuje koliko troškova je bilo moguće preračunati.';

  @override
  String get displayCurrencyHelpBody =>
      'Izaberite valutu za prikaz iznosa u listi. Originalni iznosi se uvek čuvaju. Nedostajuće kurseve možete ručno postaviti pre konverzije.';

  @override
  String get chartPaymentHint =>
      'Svaki trošak ima najviše jedan način plaćanja; ako nije izabran, prikazuje se kao nije postavljeno';

  @override
  String get tagKindSectionCountry => 'Zemlja';

  @override
  String get tagKindSectionTrip => 'Putovanje';

  @override
  String get tagKindSectionCustom => 'Kategorija';

  @override
  String get tagKindUnspecifiedCountry => 'Zemlja nije postavljena';

  @override
  String get tagKindUnspecifiedTrip => 'Putovanje nije postavljeno';

  @override
  String get tagKindUnspecifiedCustom => 'Kategorija nije postavljena';

  @override
  String get tagKindSingleSelectHint =>
      'Jedna oznaka po grupi; grupe su opcione';

  @override
  String get paymentMethod => 'Plaćanje';

  @override
  String get paymentMethodNone => 'Nije postavljeno';

  @override
  String get paymentMethodUnspecified => 'Plaćanje nije postavljeno';

  @override
  String get paymentMethodsTitle => 'Načini plaćanja';

  @override
  String get paymentMethodsHint =>
      'Izaberi podrazumevani za nove troškove. Ugrađene metode se ne mogu obrisati.';

  @override
  String get paymentMethodNew => 'Novi način plaćanja';

  @override
  String get paymentMethodAdd => 'Dodaj način plaćanja';

  @override
  String get paymentMethodEdit => 'Izmeni način plaćanja';

  @override
  String get paymentMethodBuiltIn => 'Ugrađeno';

  @override
  String get paymentMethodClearDefault => 'Ukloni podrazumevano plaćanje';

  @override
  String get filterPayment => 'Plaćanje';

  @override
  String paymentSelected(int count) {
    return '$count izabrano';
  }

  @override
  String get chartByMonth => 'Meseci';

  @override
  String get chartByDay => 'Dani';

  @override
  String get chartByWeek => 'Nedelje';

  @override
  String get chartByDate => 'Po datumu';

  @override
  String get chartByCurrency => 'Valuta';

  @override
  String get chartByYear => 'Godine';

  @override
  String get filterTags => 'Filter oznaka';

  @override
  String get excludeTag => 'Isključi';

  @override
  String get periodRange => 'Period';

  @override
  String get periodAll => 'Sve vreme';

  @override
  String get periodFrom => 'Od';

  @override
  String get periodTo => 'Do';

  @override
  String periodFromTo(String from, String to) {
    return '$from — $to';
  }

  @override
  String get periodToday => 'Danas';

  @override
  String get periodYesterday => 'Juče';

  @override
  String get periodLast7Days => 'Poslednjih 7 dana';

  @override
  String get periodLast30Days => 'Poslednjih 30 dana';

  @override
  String get periodThisMonth => 'Ovaj mesec';

  @override
  String get periodLastMonth => 'Prošli mesec';

  @override
  String get periodThisQuarter => 'Ovaj kvartal';

  @override
  String get periodThisYear => 'Ova godina';

  @override
  String get periodPreviousYear => 'Prethodna godina';

  @override
  String get periodLast12Months => 'Poslednjih 12 meseci';

  @override
  String get periodCustom => 'Prilagođeni opseg';

  @override
  String get periodCustomHint => 'Izaberi datume od i do';

  @override
  String get periodPickRange => 'Izaberi datume';

  @override
  String get showExpenses => 'Prikaži troškove';

  @override
  String get sortBy => 'Sortiraj po';

  @override
  String get sortDate => 'Datum';

  @override
  String get sortAmount => 'Iznos';

  @override
  String get sortCurrency => 'Valuta';

  @override
  String get groupBy => 'Grupiši po';

  @override
  String get groupNone => 'Nijedna';

  @override
  String get groupDate => 'Datum';

  @override
  String get groupCurrency => 'Valuta';

  @override
  String get groupTag => 'Oznaka';

  @override
  String get groupTagCountry => 'Zemlja';

  @override
  String get groupPayment => 'Plaćanje';

  @override
  String get groupTagTrip => 'Putovanje';

  @override
  String get groupTagCustom => 'Kategorija';

  @override
  String get groupTags => 'Oznake';

  @override
  String get excludeTags => 'Isključi oznake';

  @override
  String get ascending => 'Rastuće';

  @override
  String get descending => 'Opadajuće';

  @override
  String get viewRates => 'Prikaži kurseve';

  @override
  String get allRates => 'Svi kursevi';

  @override
  String get addRate => 'Dodaj kurs';

  @override
  String get noRatesYet =>
      'Još nema sačuvanih kurseva — osveži ili dodaj ručni kurs';

  @override
  String get rateSourceApi => 'ExchangeRate-API';

  @override
  String get rateSourceManual => 'Ručno';

  @override
  String get currencyFiat => 'Fiat';

  @override
  String get currencyCrypto => 'Kripto';

  @override
  String get currencyCustom => 'Prilagođena';

  @override
  String get addCustomCurrency => 'Dodaj valutu';

  @override
  String get currencyCode => 'Kod valute';

  @override
  String get filtersTitle => 'Filteri';

  @override
  String get expandFilters => 'Prikaži filtere';

  @override
  String get collapseFilters => 'Sakrij filtere';

  @override
  String get applyFilters => 'Primeni';

  @override
  String get clearFilters => 'Obriši';

  @override
  String get filtersApplied => 'Filteri primenjeni';

  @override
  String get filtersCleared => 'Filteri obrisani';

  @override
  String get selectTags => 'Oznake';

  @override
  String tagsSelected(int count) {
    return '$count oznaka';
  }

  @override
  String get summaryCount => 'Troškovi';

  @override
  String get summaryExpenses => 'Troškovi';

  @override
  String get summaryCurrencies => 'Valute';

  @override
  String summaryPerCurrencyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count troškova',
      few: '$count troška',
      one: '1 trošak',
    );
    return '$_temp0';
  }

  @override
  String summaryConvertedTotal(String currency) {
    return 'Ukupno u $currency';
  }

  @override
  String summaryPartialTotal(int converted, int total) {
    return 'Konvertovano $converted od $total';
  }

  @override
  String totalRecords(int count) {
    return 'Ukupno: $count';
  }

  @override
  String get perPage => 'Po stranici';

  @override
  String get export => 'Izvoz';

  @override
  String get listingView => 'Prikaz';

  @override
  String get viewList => 'Lista';

  @override
  String get viewGrouping => 'Grupisanje';

  @override
  String get viewChart => 'Grafikon';

  @override
  String get columnDate => 'Datum';

  @override
  String get columnGroup => 'Grupa';

  @override
  String get columnCount => 'Broj';

  @override
  String get columnAmount => 'Iznos';

  @override
  String get columnOriginalAmount => 'Početni iznos';

  @override
  String get columnCurrency => 'Valuta';

  @override
  String get columnTags => 'Oznake';

  @override
  String get noMatchingExpenses => 'Nema troškova koji odgovaraju filterima';

  @override
  String get displayIn => 'Prikaži u';

  @override
  String get displayOriginal => 'Originalne valute';

  @override
  String get displayOriginalHint => 'Prikaži sačuvane iznose bez konverzije';

  @override
  String get ratesReady => 'Svi kursevi dostupni';

  @override
  String ratesMissingCount(int count) {
    return 'Nedostaje $count kurseva';
  }

  @override
  String get pickOtherCurrency => 'Druga valuta…';

  @override
  String get missingRatesTitle => 'Konverzija nije moguća';

  @override
  String missingRatesBody(int count, String target) {
    return 'Nedostaju kursevi za $count parova ka $target. Postavi ih da nastaviš.';
  }

  @override
  String get retryConversion => 'Proveri ponovo';

  @override
  String missingRatesStill(int count) {
    return 'Još uvek nedostaje $count kurseva';
  }

  @override
  String get saveAsIsDescription =>
      'Iznos se čuva u valuti koju si uneo. Konverzija se ne primenjuje.';

  @override
  String get tagsNoneSelected => 'Nijedna izabrana';

  @override
  String tagsSelectedCount(int count) {
    return '$count izabrano';
  }

  @override
  String get guideTitle => 'Šta Valtero može';

  @override
  String get guideSubtitle =>
      'Kratak pregled glavnih funkcija. Dodirni odeljak da ga proširiš.';

  @override
  String get guideOpenFromSettings => 'Vodič platforme';

  @override
  String get dashboardSampleChartLabel =>
      'Primer — ovako će izgledati tvoj grafikon kada dodaš troškove';

  @override
  String get dashboardOpenGuide => 'Šta aplikacija može';

  @override
  String get chartLegendTitle => 'Segmenti';

  @override
  String chartLegendSummary(int visible, int total) {
    return 'Prikazano $visible od $total';
  }

  @override
  String get guideSampleGroceries => 'Namirnice';

  @override
  String get guideSampleTransport => 'Prevoz';

  @override
  String get guideSampleDining => 'Hrana napolju';

  @override
  String get guideSampleCountryRu => 'Rusija';

  @override
  String get guideSampleCountryGe => 'Gruzija';

  @override
  String get guideSampleCountryTr => 'Turska';

  @override
  String get guideSectionGettingStartedTitle => 'Početak';

  @override
  String get guideSectionGettingStartedBody =>
      'Dodirnite + na dnu ekrana da otvorite formular troška. Unesite iznos i valutu, po želji konvertujte u izveštajnu valutu, izaberite zemlju i kategorije, pa sačuvajte. Ako već postoji trošak sa istim danom, iznosom i valutom, možete sačuvati kao jedinstven, obrisati podudaranje ili otkazati. Dodirnite postojeći trošak da ga izmenite u istom formularu. Do tada kontrolna tabla pokazuje primer grafikona sa linkom na ovaj vodič.';

  @override
  String get guideSectionExpenseTrackingTitle => 'Praćenje troškova';

  @override
  String get guideSectionExpenseTrackingBody =>
      'Svaki trošak čuva iznos, valutu, datum, opcionu zemlju (ISO), način plaćanja, kategorije i belešku. Originalni iznos i valuta se uvek čuvaju, čak i ako konvertujete u izveštajnu valutu. Na listi troškova možete izabrati više redova da ih obrišete ili odjednom promenite oznake, zemlju ili valutu. Mogući duplikati (isti dan, originalni iznos i valuta) prikazuju upozorenje; otvorite baner da obrišete red ili označite da nije duplikat.';

  @override
  String get guideSectionTagsTitle => 'Oznake';

  @override
  String get guideSectionTagsBody =>
      'Kategorije označavaju na šta ste potrošili (namirnice, prevoz…). Zemlja je posebno polje troška, ne oznaka. Plaćanje je takođe posebno (gotovina, kartica, kripto ili sopstveno). Oznakama i načinima plaćanja upravljate u Podešavanjima.';

  @override
  String get guideSectionChartsTitle => 'Grafikoni potrošnje';

  @override
  String get guideSectionChartsBody =>
      'Krofna na kontrolnoj tabli razlaže potrošnju po zemlji, načinu plaćanja, kategoriji, mesecima ili valuti. Ikone ispod grafikona menjaju razlaganje. Nedostajuća zemlja, plaćanje ili kategorija prikazuju se kao nije navedeno. Dodirnite segment da otvorite odgovarajuće troškove. Čip legende prikazuje ili skriva isečak. Ispod grafikona su poslednjih 10 troškova i link na punu listu. „Prikaži troškove“ nudi listu, grupisanje i grafikon sa sortiranjem i paginacijom.';

  @override
  String get guideSectionExchangeRatesTitle => 'Kursevi';

  @override
  String get guideSectionExchangeRatesBody =>
      'Kursevi se osvežavaju u pozadini kada zastare (oko svaka 24 sata). Poveži ExchangeRate-API u Podešavanja → Integracije, osveži ručno, postavi izmene i pregledaj sve kurseve u Podešavanja → Valuta i kursevi. Bez ključa koristi se Frankfurter (ECB).';

  @override
  String get guideSectionExportTitle => 'Izvoz';

  @override
  String get guideSectionExportBody =>
      'Izvezi troškove kao CSV ili JSON. Sačuvaj fajl, podeli ga ili kopiraj u clipboard iz menija izvoza ili Podešavanja → Izvoz. Telegram se pojavljuje kao odredište tek nakon povezivanja u Integracijama.';

  @override
  String get guideSectionDataSyncTitle => 'Rezervna kopija i sinhronizacija';

  @override
  String get guideSectionDataSyncBody =>
      'Napravite šifrovanu rezervnu kopiju troškova, oznaka, načina plaćanja, ručnih kurseva i podešavanja prikaza. Zaštitite je sopstvenom frazom ili generisanom. Sačuvajte fajl (na Android/iOS preko deljenja možete sačuvati u Fajlove / Preuzimanja), zatim ga pošaljite (email, Telegram kao dokument, cloud, USB). Uvoz spaja podatke: postojeći troškovi ostaju, dodaju se novi. Ako dolazni troškovi liče na one koje već imate (isti dan, iznos i valuta), birate šta da preskočite kao duplikat, a šta da uvezete kao jedinstveno. Vratite iz Podešavanja → Rezervna kopija i sinhronizacija, ili sa prazne kontrolne table. API ključevi i Telegram nikad nisu uključeni.';

  @override
  String get guideSectionTelegramTitle => 'Deljenje preko Telegrama';

  @override
  String get guideSectionTelegramBody =>
      'Poveži Telegram u Podešavanja → Integracije, unesi token bota i chat id, proveri vezu, zatim pošalji dokument izvoza iz menija izvoza.';

  @override
  String get guideSectionIntegrationsTitle => 'Integracije';

  @override
  String get guideSectionIntegrationsBody =>
      'Opcioni servisi (Telegram, Frankfurter, ExchangeRate-API, Google Drive sinhronizacija) su u Podešavanja → Integracije. Svaki ima formu. Frankfurter je ugrađen (ECB kursevi, bez ključa) i koristi se kada ExchangeRate-API nije povezan. Google Drive Sync lokalno šifruje snimak, čuva ga u appDataFolder i sinhronizuje pri pokretanju i posle izmena. Deljenje između naloga koristi poseban fajl i dozvolu drive.file. Zavisne stavke UI-ja se pojavljuju samo dok je integracija povezana.';

  @override
  String get guideSectionDebugTitle => 'Otklanjanje grešaka i logovi';

  @override
  String get guideSectionDebugBody =>
      'U Podešavanja → Otklanjanje grešaka i logovi možeš uključiti detaljno logovanje. Greške se uvek beleže. Log možeš pregledati, kopirati ili poslati programeru; tajne se maskiraju.';

  @override
  String get guideSectionFiltersTitle => 'Filteri';

  @override
  String get guideSectionFiltersBody =>
      'Filtrirajte po periodu, valuti, oznakama i plaćanju na kontrolnoj tabli i stranici troškova. Oba koriste kompaktnu traku sažetka koja otvara filtere u celoekranskom listu. Primetite ili obrišite filtere u bilo kom trenutku.';

  @override
  String get guideSectionVoiceExpenseTitle => 'Glasovni unos troškova';

  @override
  String get guideSectionVoiceExpenseBody =>
      'Na Androidu otvorite Dodaj trošak i dodirnite mikrofon. Govorite po šablonu iznos → valuta → kategorija → plaćanje (primer: kafa 350 dinara kartica). Pregledajte prepoznato, zatim Kreiraj da popunite formular, ili Otkaži da ostane prazan. Audio i transkript se ne čuvaju; u logove ulaze samo greške. Koristi sistemsko prepoznavanje govora; jezik diktiranja nije ograničen jezikom interfejsa. Nije dostupno na Linuxu i Windowsu.';

  @override
  String get voiceExpenseMicTooltip => 'Diktiraj trošak';

  @override
  String get voiceExpenseTitle => 'Diktiraj trošak';

  @override
  String get voiceExpenseInitializing => 'Pokretanje mikrofona…';

  @override
  String get voiceExpenseListening => 'Slušam…';

  @override
  String get voiceExpenseSpeakHint => 'Izgovorite iznos i detalje';

  @override
  String get voiceExpensePatternHint =>
      'Šablon: iznos → valuta → kategorija → plaćanje';

  @override
  String get voiceExpensePatternExample => 'Primer: kafa 350 dinara kartica';

  @override
  String get voiceExpensePrivacyNote =>
      'Audio i transkript se ne čuvaju. U logove ulaze samo greške prepoznavanja.';

  @override
  String get voiceExpenseHeardLabel => 'Čuto';

  @override
  String get voiceExpenseDoneListening => 'Gotovo';

  @override
  String get voiceExpenseRecognized => 'Prepoznato';

  @override
  String get voiceExpenseNotDetected => 'Nije otkriveno';

  @override
  String get voiceExpenseCreate => 'Kreiraj';

  @override
  String get voiceExpenseRetry => 'Pokušaj ponovo';

  @override
  String get voiceExpenseUnavailable =>
      'Prepoznavanje govora nije dostupno. Proverite dozvolu za mikrofon.';

  @override
  String get voiceExpenseEmpty => 'Ništa nije prepoznato. Pokušajte ponovo.';
}
