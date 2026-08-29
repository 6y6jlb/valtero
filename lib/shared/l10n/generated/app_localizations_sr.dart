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
  String get settingsExport => 'Izvoz i Telegram';

  @override
  String get settingsDataSync => 'Rezervna kopija i sinhronizacija';

  @override
  String get dataSyncTitle => 'Rezervna kopija i sinhronizacija';

  @override
  String get dataSyncExport => 'Izvoz';

  @override
  String get dataSyncImport => 'Uvoz';

  @override
  String get dataSyncPassphrase => 'Lozinka-fraza';

  @override
  String get dataSyncGeneratePassphrase => 'Generiši frazu';

  @override
  String get dataSyncCopyPassphrase => 'Kopiraj frazu';

  @override
  String get dataSyncPassphraseWarning =>
      'Sačuvajte ovu frazu na sigurnom mestu. Bez nje se rezervna kopija ne može otvoriti.';

  @override
  String get dataSyncExportDone => 'Rezervna kopija sačuvana';

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
  String get dashboardRestoreFromBackup => 'Vrati iz rezervne kopije';

  @override
  String get selectCountry => 'Izaberi zemlju';

  @override
  String get addExpense => 'Dodaj trošak';

  @override
  String get editExpense => 'Izmeni trošak';

  @override
  String get amount => 'Iznos';

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
  String get expenseDeleted => 'Trošak obrisan';

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
  String get rateSourceFrankfurter => 'Frankfurter';

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
      'Dodirnite + na dnu ekrana da otvorite formular troška. Unesite iznos i valutu, po želji konvertujte u izveštajnu valutu, izaberite zemlju i kategorije, pa sačuvajte. Dodirnite postojeći trošak da ga izmenite u istom formularu. Do tada kontrolna tabla pokazuje primer grafikona sa linkom na ovaj vodič.';

  @override
  String get guideSectionExpenseTrackingTitle => 'Praćenje troškova';

  @override
  String get guideSectionExpenseTrackingBody =>
      'Svaki trošak čuva iznos, valutu, datum, opcionu zemlju (ISO), način plaćanja, kategorije i belešku. Originalni iznos i valuta se uvek čuvaju, čak i ako konvertujete u izveštajnu valutu.';

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
      'Kursevi se osvežavaju u pozadini kada zastare (oko svaka 24 sata). Poveži ključ ExchangeRate-API, osveži ručno, postavi izmene i pregledaj sve kurseve u Podešavanja → Valuta i kursevi.';

  @override
  String get guideSectionExportTitle => 'Izvoz';

  @override
  String get guideSectionExportBody =>
      'Izvezi troškove kao CSV ili JSON. Sačuvaj fajl, podeli ga ili kopiraj u clipboard iz menija izvoza ili Podešavanja → Izvoz i Telegram.';

  @override
  String get guideSectionDataSyncTitle => 'Rezervna kopija i sinhronizacija';

  @override
  String get guideSectionDataSyncBody =>
      'Napravite šifrovanu rezervnu kopiju troškova, oznaka, načina plaćanja, ručnih kurseva i podešavanja prikaza. Zaštitite je sopstvenom frazom ili generisanom. Vratite na drugom uređaju iz Podešavanja → Rezervna kopija i sinhronizacija, ili sa prazne kontrolne table. API ključevi i Telegram nikad nisu uključeni.';

  @override
  String get guideSectionTelegramTitle => 'Deljenje preko Telegrama';

  @override
  String get guideSectionTelegramBody =>
      'Omogući Telegram u podešavanjima izvoza, unesi token bota i chat id, zatim pošalji dokument izvoza direktno na Telegram.';

  @override
  String get guideSectionFiltersTitle => 'Filteri';

  @override
  String get guideSectionFiltersBody =>
      'Filtrirajte po periodu, valuti, oznakama i plaćanju na kontrolnoj tabli i stranici troškova. Oba koriste kompaktnu traku sažetka koja otvara filtere u celoekranskom listu. Primetite ili obrišite filtere u bilo kom trenutku.';
}
