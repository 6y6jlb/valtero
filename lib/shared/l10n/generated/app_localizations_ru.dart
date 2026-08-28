// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Valtero';

  @override
  String get navDashboard => 'Сводка';

  @override
  String get navExpenses => 'Траты';

  @override
  String get navAdd => 'Добавить';

  @override
  String get navTags => 'Теги';

  @override
  String get navCurrency => 'Валюта';

  @override
  String get navExport => 'Экспорт';

  @override
  String get navSettings => 'Настройки';

  @override
  String get settingsAppearance => 'Оформление';

  @override
  String get settingsCurrency => 'Валюта и курсы';

  @override
  String get settingsExport => 'Экспорт и Telegram';

  @override
  String get selectCountry => 'Выбрать страну';

  @override
  String get addExpense => 'Добавить трату';

  @override
  String get editExpense => 'Изменить трату';

  @override
  String get amount => 'Сумма';

  @override
  String get currency => 'Валюта';

  @override
  String get saveAsIs => 'Сохранить как есть';

  @override
  String get convertTo => 'Сконвертировать в';

  @override
  String exchangeRate(String rate) {
    return 'Курс: $rate';
  }

  @override
  String get rateUnavailable => 'Нет курса для этой пары';

  @override
  String get setRateNow => 'Указать курс';

  @override
  String get setManualRateTitle => 'Задать курс';

  @override
  String setManualRateHint(String base, String target) {
    return 'Сколько $target за 1 $base';
  }

  @override
  String get tag => 'Тег';

  @override
  String get note => 'Заметка';

  @override
  String get date => 'Дата';

  @override
  String get save => 'Сохранить';

  @override
  String get delete => 'Удалить';

  @override
  String get cancel => 'Отмена';

  @override
  String get yes => 'Да';

  @override
  String get no => 'Нет';

  @override
  String get confirmDeleteExpense => 'Удалить эту трату?';

  @override
  String get expenseDeleted => 'Трата удалена';

  @override
  String get add => 'Добавить';

  @override
  String get settings => 'Настройки';

  @override
  String get reportingCurrencies => 'Базовые валюты';

  @override
  String get primaryCurrency => 'Основная валюта';

  @override
  String get apiKey => 'Ключ ExchangeRate-API';

  @override
  String get validateKey => 'Проверить и привязать';

  @override
  String get refreshRates => 'Обновить курсы';

  @override
  String get manualRates => 'Ручные курсы';

  @override
  String get baseCurrency => 'Из';

  @override
  String get targetCurrency => 'В';

  @override
  String get rate => 'Курс';

  @override
  String get tagsTitle => 'Теги';

  @override
  String get suggestedTags => 'Предложенные теги';

  @override
  String get detectCountry => 'Определить страну снова';

  @override
  String get country => 'Страна';

  @override
  String get defaultTags => 'Теги по умолчанию';

  @override
  String get dismiss => 'Скрыть';

  @override
  String get exportTitle => 'Экспорт';

  @override
  String get exportCsv => 'CSV';

  @override
  String get exportJson => 'JSON';

  @override
  String get saveFile => 'Сохранить файл';

  @override
  String get share => 'Поделиться';

  @override
  String get copyAs => 'Скопировать как';

  @override
  String get copiedToClipboard => 'Скопировано в буфер';

  @override
  String get sendTelegram => 'Отправить в Telegram';

  @override
  String get telegramBotToken => 'Токен Telegram-бота';

  @override
  String get telegramChatId => 'Chat id Telegram';

  @override
  String get telegramEnabled => 'Включить Telegram';

  @override
  String get summaryTotal => 'Сумма';

  @override
  String get byTag => 'По тегам';

  @override
  String get byPeriod => 'По периоду';

  @override
  String get displayCurrency => 'Валюта отображения';

  @override
  String get noExpenses => 'Пока нет трат';

  @override
  String get expensesEmptyTitle => 'Пока нет трат';

  @override
  String get expensesEmptyBody =>
      'Добавьте первую трату, чтобы увидеть список, сводку и графики.';

  @override
  String get filterTag => 'Фильтр по тегу';

  @override
  String get filterCurrency => 'Фильтр по валюте';

  @override
  String get all => 'Все';

  @override
  String get theme => 'Тема';

  @override
  String get locale => 'Язык';

  @override
  String get moneyFormat => 'Отображение сумм';

  @override
  String get moneyFormatPreview => 'Пример';

  @override
  String get moneyFormatLocaleSymbol => 'По локали с символом';

  @override
  String get moneyFormatLocaleCode => 'По локали с кодом валюты';

  @override
  String get moneyFormatPlain => 'Простой (1234.56 CODE)';

  @override
  String get timeZone => 'Часовой пояс';

  @override
  String timeZoneSystem(String id) {
    return 'Системный ($id)';
  }

  @override
  String get system => 'Системная';

  @override
  String get light => 'Светлая';

  @override
  String get dark => 'Тёмная';

  @override
  String get keyValid => 'Ключ API действителен';

  @override
  String get keyInvalid => 'Ключ API недействителен';

  @override
  String get ratesRefreshed => 'Курсы обновлены';

  @override
  String get exportDone => 'Экспорт готов';

  @override
  String get telegramSent => 'Отправлено в Telegram';

  @override
  String get telegramFailed => 'Не удалось отправить в Telegram';

  @override
  String get telegramSetupNeeded =>
      'Включите Telegram и укажите токен бота и chat id, чтобы отправлять экспорт.';

  @override
  String get shareUnsupported => 'Поделиться файлом на этой платформе нельзя.';

  @override
  String get shareFailed => 'Не удалось поделиться файлом экспорта.';

  @override
  String get untagged => 'Без тега';

  @override
  String get periodDay => 'День';

  @override
  String get periodWeek => 'Неделя';

  @override
  String get periodMonth => 'Месяц';

  @override
  String get newTag => 'Новый тег';

  @override
  String get addTag => 'Добавить тег';

  @override
  String get tagGroceries => 'Продукты';

  @override
  String get tagTransport => 'Транспорт';

  @override
  String get tagHousing => 'Жильё';

  @override
  String get tagDining => 'Кафе и рестораны';

  @override
  String get tagHealth => 'Здоровье';

  @override
  String get tagEntertainment => 'Развлечения';

  @override
  String get tagShopping => 'Покупки';

  @override
  String get tagTravel => 'Путешествия';

  @override
  String get tagUtilities => 'Коммуналка';

  @override
  String get tagCash => 'Наличка';

  @override
  String get tagCard => 'Карта';

  @override
  String get tagCrypto => 'Крипта';

  @override
  String get tagTransfer => 'Перевод';

  @override
  String get tagEwallet => 'Электронный кошелёк';

  @override
  String tripTag(String region) {
    return 'Поездка: $region';
  }

  @override
  String get tagColor => 'Цвет';

  @override
  String get tagColorNone => 'Без цвета';

  @override
  String get chartBy => 'График по';

  @override
  String get chartByTags => 'Теги';

  @override
  String get chartByTagCountry => 'Страны';

  @override
  String get chartByPayment => 'Способ оплаты';

  @override
  String get chartByTagTrip => 'Поездки';

  @override
  String get chartByTagCustom => 'Свои теги';

  @override
  String get chartTagKindHint =>
      'Каждая трата учитывается один раз внутри выбранного типа; без тега попадает в «не указано»';

  @override
  String chartMissingRatesAlert(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count траты показаны без курса конвертации',
      many: '$count трат показано без курса конвертации',
      few: '$count траты показаны без курса конвертации',
      one: '1 трата показана без курса конвертации',
    );
    return '$_temp0';
  }

  @override
  String get chartHelpTitle => 'О графике';

  @override
  String get chartHelpBody =>
      'На графике учитываются траты во всех валютах. Если курс не указан, суммы показываются в исходной валюте. Итоги могут смешивать валюты, пока курсы не заданы.';

  @override
  String get expensesSummaryHelpTitle => 'О сводке трат';

  @override
  String get expensesSummaryHelpBody =>
      'Итоги сгруппированы по сохранённой валюте. Кнопка конвертации переводит суммы в списке в одну валюту; итог конвертации показывает, сколько трат удалось пересчитать.';

  @override
  String get displayCurrencyHelpBody =>
      'Выберите валюту для отображения сумм в списке. Исходные суммы всегда сохраняются. Отсутствующие курсы можно задать вручную перед конвертацией.';

  @override
  String get chartPaymentHint =>
      'У траты не больше одного способа оплаты; без выбора — «не указано»';

  @override
  String get tagKindSectionCountry => 'Страна';

  @override
  String get tagKindSectionTrip => 'Поездка';

  @override
  String get tagKindSectionCustom => 'Категория';

  @override
  String get tagKindUnspecifiedCountry => 'Страна не указана';

  @override
  String get tagKindUnspecifiedTrip => 'Поездка не указана';

  @override
  String get tagKindUnspecifiedCustom => 'Категория не указана';

  @override
  String get tagKindSingleSelectHint =>
      'Один тег из группы; группы необязательны';

  @override
  String get paymentMethod => 'Оплата';

  @override
  String get paymentMethodNone => 'Не указано';

  @override
  String get paymentMethodUnspecified => 'Оплата не указана';

  @override
  String get paymentMethodsTitle => 'Способы оплаты';

  @override
  String get paymentMethodsHint =>
      'Выберите значение по умолчанию для новых трат. Встроенные способы нельзя удалить.';

  @override
  String get paymentMethodNew => 'Новый способ оплаты';

  @override
  String get paymentMethodAdd => 'Добавить способ оплаты';

  @override
  String get paymentMethodEdit => 'Изменить способ оплаты';

  @override
  String get paymentMethodBuiltIn => 'Встроенный';

  @override
  String get paymentMethodClearDefault => 'Сбросить оплату по умолчанию';

  @override
  String get filterPayment => 'Оплата';

  @override
  String paymentSelected(int count) {
    return '$count выбрано';
  }

  @override
  String get chartByMonth => 'Месяцы';

  @override
  String get chartByCurrency => 'Валюта';

  @override
  String get chartByYear => 'Годы';

  @override
  String get filterTags => 'Фильтр тегов';

  @override
  String get excludeTag => 'Исключить';

  @override
  String get periodRange => 'Период';

  @override
  String get periodAll => 'Всё время';

  @override
  String get periodFrom => 'С';

  @override
  String get periodTo => 'По';

  @override
  String periodFromTo(String from, String to) {
    return '$from — $to';
  }

  @override
  String get periodToday => 'Сегодня';

  @override
  String get periodYesterday => 'Вчера';

  @override
  String get periodLast7Days => 'Последние 7 дней';

  @override
  String get periodLast30Days => 'Последние 30 дней';

  @override
  String get periodThisMonth => 'Этот месяц';

  @override
  String get periodLastMonth => 'Прошлый месяц';

  @override
  String get periodThisQuarter => 'Этот квартал';

  @override
  String get periodThisYear => 'Этот год';

  @override
  String get periodPreviousYear => 'Прошлый год';

  @override
  String get periodLast12Months => 'Последние 12 месяцев';

  @override
  String get periodCustom => 'Свой период';

  @override
  String get periodCustomHint => 'Укажите даты от и до';

  @override
  String get periodPickRange => 'Выбрать даты';

  @override
  String get showExpenses => 'Показать траты';

  @override
  String get sortBy => 'Сортировка';

  @override
  String get sortDate => 'Дата';

  @override
  String get sortAmount => 'Сумма';

  @override
  String get sortCurrency => 'Валюта';

  @override
  String get groupBy => 'Группировка';

  @override
  String get groupNone => 'Нет';

  @override
  String get groupDate => 'Дата';

  @override
  String get groupCurrency => 'Валюта';

  @override
  String get groupTag => 'Тег';

  @override
  String get groupTagCountry => 'Страна';

  @override
  String get groupPayment => 'Оплата';

  @override
  String get groupTagTrip => 'Поездка';

  @override
  String get groupTagCustom => 'Категория';

  @override
  String get groupTags => 'Теги';

  @override
  String get excludeTags => 'Исключить теги';

  @override
  String get ascending => 'По возрастанию';

  @override
  String get descending => 'По убыванию';

  @override
  String get viewRates => 'Смотреть курсы';

  @override
  String get allRates => 'Все курсы';

  @override
  String get addRate => 'Добавить курс';

  @override
  String get noRatesYet => 'Курсов пока нет — обновите или добавьте вручную';

  @override
  String get rateSourceApi => 'ExchangeRate-API';

  @override
  String get rateSourceFrankfurter => 'Frankfurter';

  @override
  String get rateSourceManual => 'Вручную';

  @override
  String get currencyFiat => 'Фиат';

  @override
  String get currencyCrypto => 'Крипта';

  @override
  String get currencyCustom => 'Свои';

  @override
  String get addCustomCurrency => 'Добавить валюту';

  @override
  String get currencyCode => 'Код валюты';

  @override
  String get filtersTitle => 'Фильтры';

  @override
  String get expandFilters => 'Показать фильтры';

  @override
  String get collapseFilters => 'Скрыть фильтры';

  @override
  String get applyFilters => 'Применить';

  @override
  String get clearFilters => 'Сбросить';

  @override
  String get filtersApplied => 'Применено';

  @override
  String get filtersCleared => 'Сброшено';

  @override
  String get selectTags => 'Теги';

  @override
  String tagsSelected(int count) {
    return '$count тегов';
  }

  @override
  String get summaryCount => 'Трат';

  @override
  String get summaryExpenses => 'Траты';

  @override
  String get summaryCurrencies => 'Валют';

  @override
  String summaryPerCurrencyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count траты',
      many: '$count трат',
      few: '$count траты',
      one: '1 трата',
    );
    return '$_temp0';
  }

  @override
  String summaryConvertedTotal(String currency) {
    return 'Итого в $currency';
  }

  @override
  String summaryPartialTotal(int converted, int total) {
    return 'Сконвертировано $converted из $total';
  }

  @override
  String totalRecords(int count) {
    return 'Всего: $count';
  }

  @override
  String get perPage => 'На странице';

  @override
  String get export => 'Выгрузка';

  @override
  String get listingView => 'Вид';

  @override
  String get viewList => 'Список';

  @override
  String get viewGrouping => 'Группировка';

  @override
  String get viewChart => 'График';

  @override
  String get columnDate => 'Дата';

  @override
  String get columnGroup => 'Группа';

  @override
  String get columnCount => 'Кол-во';

  @override
  String get columnAmount => 'Сумма';

  @override
  String get columnCurrency => 'Валюта';

  @override
  String get columnTags => 'Теги';

  @override
  String get noMatchingExpenses => 'Нет трат по выбранным фильтрам';

  @override
  String get displayIn => 'Отобразить в';

  @override
  String get displayOriginal => 'Исходные валюты';

  @override
  String get displayOriginalHint =>
      'Показывать сохранённые суммы без конвертации';

  @override
  String get ratesReady => 'Все курсы есть';

  @override
  String ratesMissingCount(int count) {
    return 'Нет курсов: $count';
  }

  @override
  String get pickOtherCurrency => 'Другая валюта…';

  @override
  String get missingRatesTitle => 'Конвертация невозможна';

  @override
  String missingRatesBody(int count, String target) {
    return 'Нет курсов для $count пар в $target. Укажите их, чтобы продолжить.';
  }

  @override
  String get retryConversion => 'Проверить снова';

  @override
  String missingRatesStill(int count) {
    return 'Всё ещё нет курсов: $count';
  }

  @override
  String get saveAsIsDescription =>
      'Сумма сохраняется в указанной валюте. Конвертация не выполняется.';

  @override
  String get tagsNoneSelected => 'Не выбрано';

  @override
  String tagsSelectedCount(int count) {
    return 'Выбрано: $count';
  }

  @override
  String get guideTitle => 'Что умеет Valtero';

  @override
  String get guideSubtitle =>
      'Краткий обзор основных возможностей. Нажмите на пункт, чтобы раскрыть.';

  @override
  String get guideOpenFromSettings => 'О возможностях';

  @override
  String get dashboardSampleChartLabel =>
      'Пример — так будет выглядеть график после добавления трат';

  @override
  String get dashboardOpenGuide => 'Что умеет приложение';

  @override
  String get chartLegendTitle => 'Сегменты';

  @override
  String chartLegendSummary(int visible, int total) {
    return 'Показано $visible из $total';
  }

  @override
  String get guideSampleGroceries => 'Продукты';

  @override
  String get guideSampleTransport => 'Транспорт';

  @override
  String get guideSampleDining => 'Кафе';

  @override
  String get guideSampleCountryRu => 'Россия';

  @override
  String get guideSampleCountryGe => 'Грузия';

  @override
  String get guideSampleCountryTr => 'Турция';

  @override
  String get guideSectionGettingStartedTitle => 'С чего начать';

  @override
  String get guideSectionGettingStartedBody =>
      'Нажмите + внизу экрана, чтобы открыть форму траты. Укажите сумму и валюту, при необходимости конвертируйте в отчётную валюту, выберите страну и категории, сохраните. Нажмите на существующую трату, чтобы изменить её в той же форме. Пока трат нет, на дашборде — пример графика со ссылкой на это руководство.';

  @override
  String get guideSectionExpenseTrackingTitle => 'Отслеживание расходов';

  @override
  String get guideSectionExpenseTrackingBody =>
      'У каждой траты хранятся сумма, валюта, дата, необязательная страна (ISO), способ оплаты, категории и заметка. Исходные сумма и валюта всегда сохраняются, даже если вы конвертируете в отчётную валюту.';

  @override
  String get guideSectionTagsTitle => 'Теги';

  @override
  String get guideSectionTagsBody =>
      'Категории описывают, на что ушла трата (продукты, транспорт…). Страна — отдельное поле траты, не тег. Способ оплаты тоже отдельный (наличные, карта, крипто или свой). Теги и способы оплаты — в Настройках.';

  @override
  String get guideSectionChartsTitle => 'Графики трат';

  @override
  String get guideSectionChartsBody =>
      'Круговая диаграмма на дашборде разбивает траты по стране, способу оплаты, категории, месяцам или валюте. Иконки под графиком переключают разбивку. Без страны, оплаты или категории — «не задано». Нажатие на сегмент открывает подходящие траты. Чип легенды скрывает/показывает долю. Под графиком — последние 10 трат и ссылка на полный список. «Показать траты» — список, группировка и график с сортировкой и страницами.';

  @override
  String get guideSectionExchangeRatesTitle => 'Обменные курсы';

  @override
  String get guideSectionExchangeRatesBody =>
      'Курсы обновляются в фоне, если устарели (примерно раз в сутки). Привяжите ключ ExchangeRate-API, обновите вручную, задайте свои курсы и просмотрите все пары в Настройки → Валюта и курсы.';

  @override
  String get guideSectionExportTitle => 'Экспорт';

  @override
  String get guideSectionExportBody =>
      'Выгружайте траты в CSV или JSON. Сохраните файл, поделитесь им или скопируйте в буфер из меню экспорта или Настройки → Экспорт и Telegram.';

  @override
  String get guideSectionTelegramTitle => 'Шаринг через Telegram';

  @override
  String get guideSectionTelegramBody =>
      'Включите Telegram в настройках экспорта, укажите токен бота и chat id — и отправляйте файл экспорта прямо в Telegram.';

  @override
  String get guideSectionFiltersTitle => 'Фильтры';

  @override
  String get guideSectionFiltersBody =>
      'Фильтруйте по периоду, валюте, тегам и оплате на дашборде и в списке трат. Оба экрана показывают компактную полосу сводки, которая открывает фильтры в полноэкранном листе. Применяйте или сбрасывайте фильтры в любой момент.';
}
