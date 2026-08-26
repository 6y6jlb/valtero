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
  String get rateUnavailable =>
      'Не удалось получить курс — введите вручную или откройте настройки валют';

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
  String get sendTelegram => 'Отправить в Telegram';

  @override
  String get telegramBotToken => 'Токен Telegram-бота';

  @override
  String get telegramChatId => 'Chat id Telegram';

  @override
  String get telegramEnabled => 'Включить Telegram';

  @override
  String get summaryTotal => 'Итого';

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
}
