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
  String get summaryCurrencies => 'Валют';

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
  String get guideSectionGettingStartedTitle => 'С чего начать';

  @override
  String get guideSectionGettingStartedBody =>
      'Нажмите кнопку + внизу экрана, чтобы открыть форму добавления траты. Укажите сумму и валюту, при желании сконвертируйте в базовую валюту, выберите теги и сохраните. Пока трат нет, на сводке показывается пример графика со ссылкой на этот гайд.';

  @override
  String get guideSectionExpenseTrackingTitle => 'Отслеживание расходов';

  @override
  String get guideSectionExpenseTrackingBody =>
      'У каждой траты хранятся сумма, валюта, дата и необязательная заметка. Оригинальные сумма и валюта всегда сохраняются — даже если вы конвертируете в базовую валюту для хранения.';

  @override
  String get guideSectionTagsTitle => 'Теги';

  @override
  String get guideSectionTagsBody =>
      'Отмечайте траты страной (определяется автоматически или выбирается вручную), способом оплаты (нал, карта, крипто и др.) и своими метками. Управляйте тегами в Настройках или через иконку тегов на сводке.';

  @override
  String get guideSectionChartsTitle => 'Графики трат';

  @override
  String get guideSectionChartsBody =>
      'Круговая диаграмма на сводке показывает разбивку по тегам, месяцам или валюте. Переключайте вид иконками под графиком. Нажмите на сектор графика, чтобы открыть соответствующие траты. Кликом по цветной метке под графиком можно скрыть или показать сектор. Кнопка «Показать траты» открывает список, группировку и график с сортировкой и постраничным просмотром.';

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
      'Фильтруйте по периоду, валюте и тегам на сводке и на странице трат. Применяйте или сбрасывайте фильтры в любой момент; на сводке остаётся краткая строка, а полный набор открывается в модалке на весь экран.';
}
