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
  String get navDashboard => 'Главная';

  @override
  String get navExpenses => 'Расходы';

  @override
  String get recentOperations => 'Последние операции';

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
  String get settingsExport => 'Экспорт';

  @override
  String get settingsIntegrations => 'Интеграции';

  @override
  String get settingsDebug => 'Отладка и логи';

  @override
  String get settingsThanks => 'Благодарности';

  @override
  String get thanksTitle => 'Благодарности';

  @override
  String get thanksDescription =>
      'Если Valtero вам помогает, можно сказать спасибо небольшой суммой в ETH или Bitcoin. Скопируйте адрес ниже и отправьте из совместимого кошелька.';

  @override
  String get thanksEthLabel => 'Адрес ETH';

  @override
  String get thanksCopyEthAddress => 'Скопировать ETH';

  @override
  String get thanksBtcLabel => 'Адрес Bitcoin';

  @override
  String get thanksCopyBtcAddress => 'Скопировать Bitcoin';

  @override
  String get settingsContactDeveloper => 'Написать разработчику';

  @override
  String get contactDeveloperTitle => 'Написать разработчику';

  @override
  String get contactDeveloperDescription =>
      'Вопросы, идеи или баги — на почту ниже. Логи приложения можно отправить из Настройки → Отладка и логи.';

  @override
  String get contactDeveloperEmailLabel => 'Email';

  @override
  String get contactDeveloperCopyEmail => 'Скопировать email';

  @override
  String get contactDeveloperSendEmail => 'Отправить письмо';

  @override
  String get contactDeveloperSendFailed =>
      'Не удалось открыть почтовый клиент. Скопируйте адрес вручную.';

  @override
  String get integrationsSuggest => 'Предложить интеграцию';

  @override
  String get integrationsSuggestHint =>
      'Нужен другой сервис? Напишите разработчику.';

  @override
  String debugLogsSendHint(String email) {
    return '«Поделиться» — отправить файл лога кому угодно. «Отправить разработчику» откроет почту на $email с вложением. Скопировать email / логи — в кнопках внизу.';
  }

  @override
  String get integrationConnected => 'Подключено';

  @override
  String get integrationNotConnected => 'Не подключено';

  @override
  String get integrationTestConnection => 'Проверить соединение';

  @override
  String get integrationSave => 'Сохранить';

  @override
  String get integrationDisconnect => 'Отключить';

  @override
  String get connectionOk => 'Соединение успешно';

  @override
  String get connectionFailed => 'Не удалось подключиться';

  @override
  String get connectionNetwork =>
      'Нет сети или не удалось разрешить DNS. Проверьте интернет, VPN или DNS и повторите.';

  @override
  String get connectionMissingFields => 'Заполните все обязательные поля';

  @override
  String get connectionInvalidToken => 'Неверный токен бота';

  @override
  String get connectionInvalidChat =>
      'Неверный chat id или бот не имеет доступа';

  @override
  String get connectionInvalidKey => 'Неверный API-ключ';

  @override
  String get showSecret => 'Показать';

  @override
  String get hideSecret => 'Скрыть';

  @override
  String get integrationTelegramTitle => 'Telegram';

  @override
  String get integrationTelegramDescription =>
      'Отправка экспорта расходов в чат Telegram через бота.';

  @override
  String get integrationFrankfurterTitle => 'Frankfurter';

  @override
  String get integrationFrankfurterDescription =>
      'Бесплатные курсы ECB (без API-ключа). Используются автоматически, если ExchangeRate-API не подключён.';

  @override
  String get integrationFrankfurterHint =>
      'Встроенный запасной источник. Проверка api.frankfurter.dev — если она падает, курсы не обновятся, пока не заработает сеть/DNS. Только валюты из набора ECB.';

  @override
  String get integrationExchangeRateApiTitle => 'ExchangeRate-API';

  @override
  String get integrationExchangeRateApiDescription =>
      'Курсы через ключ с exchangerate-api.com (API v6). Ключи с exchangeratesapi.io не подойдут. Без ключа используется Frankfurter (ECB).';

  @override
  String get exchangeRateApiEnabled =>
      'Использовать ExchangeRate-API для курсов';

  @override
  String get integrationGoogleDriveSyncTitle => 'Синхронизация Google Drive';

  @override
  String get integrationGoogleDriveSyncDescription =>
      'Зашифрованная автоматическая синхронизация между устройствами через Google Drive. Google не видит расходы — только шифротекст.';

  @override
  String get googleDriveSignIn => 'Войти через Google';

  @override
  String get googleDriveSyncNow => 'Синхронизировать';

  @override
  String get googleDriveSyncOk => 'Синхронизация завершена';

  @override
  String get googleDriveSyncPassphrase => 'Пароль синхронизации';

  @override
  String get googleDriveSyncPassphraseHint =>
      'Используется только на устройстве для шифрования. Google его не получает. На всех устройствах должен быть один и тот же пароль.';

  @override
  String get googleDrivePassphraseTooShort =>
      'Пароль должен быть не короче 8 символов';

  @override
  String get googleDriveWrongPassphrase =>
      'Неверный пароль для удалённой копии';

  @override
  String get googleDriveMissingClientId =>
      'Не задан Google OAuth client id. Скопируйте local.oauth.env.example → local.oauth.env, укажите GOOGLE_OAUTH_CLIENT_ID_DESKTOP / _ANDROID и пересоберите (make run-*).';

  @override
  String get googleDriveReauthRequired => 'Войдите в Google снова';

  @override
  String get googleDriveSyncPaused =>
      'Синхронизация приостановлена — вы вышли из аккаунта';

  @override
  String get googleDriveSignInFailed => 'Не удалось войти в Google';

  @override
  String get googleDriveAuthCanceled => 'Вход через Google отменён';

  @override
  String get googleDriveAccessDenied =>
      'Доступ Google отклонён. Разрешите права Drive и повторите вход.';

  @override
  String get googleDriveAndroidCustomUriHint =>
      'На Android откройте Google Cloud Console → Android OAuth-клиент → Advanced settings и включите «Custom URI scheme», затем повторите вход. Для новых Android-клиентов Google по умолчанию блокирует этот redirect.';

  @override
  String get googleDriveMissingClientSecret =>
      'Не задан client secret для Desktop OAuth. В Google Cloud Console откройте Desktop OAuth-клиент, скопируйте Client secret в local.oauth.env как GOOGLE_OAUTH_CLIENT_SECRET_DESKTOP и пересоберите (make run-linux).';

  @override
  String googleDriveLastSynced(String when) {
    return 'Последняя синхронизация: $when';
  }

  @override
  String get relativeTimeJustNow => 'Только что';

  @override
  String relativeTimeMinutesAgo(int count) {
    return '$count мин назад';
  }

  @override
  String relativeTimeHoursAgo(int count) {
    return '$count ч назад';
  }

  @override
  String relativeTimeDaysAgo(int count) {
    return '$count д назад';
  }

  @override
  String get googleDriveSyncStatusHint => 'Время последней синхронизации';

  @override
  String get actionSuccessStatusHint => 'Время последнего действия';

  @override
  String get googleDriveSharedTitle =>
      'Общая синхронизация (другие аккаунты Google)';

  @override
  String get googleDriveSharedDescription =>
      'Расшарить зашифрованный файл с другим человеком. Нужно дополнительное разрешение Google (drive.file); для публичного релиза может потребоваться верификация OAuth.';

  @override
  String get googleDriveShareEmail => 'Email участника';

  @override
  String get googleDriveShareAdd => 'Поделиться';

  @override
  String get googleDriveShareOk => 'Доступ выдан';

  @override
  String get googleDriveShareFailed => 'Не удалось расшарить файл';

  @override
  String get googleDriveSharedFileInaccessible =>
      'Нет доступа к общему файлу синхронизации. Войдите снова и разрешите доступ к файлам Drive, когда Google спросит (нужно для синхронизации между аккаунтами), или поделитесь файлом с соавтором ещё раз.';

  @override
  String get googleDriveRevokeOk => 'Доступ отозван';

  @override
  String get googleDriveRevokeFailed => 'Не удалось отозвать доступ';

  @override
  String get googleDriveInvalidEmail => 'Введите корректный email';

  @override
  String get googleDriveRemoteNewerSchemaTitle => 'Нужно обновить приложение';

  @override
  String googleDriveRemoteNewerSchema(
    int remoteSchema,
    int localSchema,
    String remoteApp,
  ) {
    return 'Облачный снимок создан более новой версией приложения (схема $remoteSchema, приложение $remoteApp). На этом устройстве схема $localSchema. Синхронизация остановлена, чтобы не перезаписать новые данные. Обновите приложение и повторите попытку.';
  }

  @override
  String get googleDriveUnsupportedFormat =>
      'Формат файла облачной синхронизации не поддерживается этой версией приложения';

  @override
  String get googleDriveHelpTitle =>
      'Как работает синхронизация через Google Drive';

  @override
  String get googleDriveHelpSameAccountTitle =>
      'Тот же аккаунт Google на другом устройстве';

  @override
  String get googleDriveHelpSameAccountBody =>
      '1. На этом устройстве: задайте пароль синхронизации и войдите через Google.\n2. На другом устройстве: войдите тем же аккаунтом Google и введите тот же пароль.\n3. Синхронизация идёт после входа и по кнопке «Синхронизировать». Больше ничего настраивать не нужно.';

  @override
  String get googleDriveHelpCrossAccountTitle => 'Разные аккаунты Google';

  @override
  String get googleDriveHelpCrossAccountBody =>
      'Аккаунт 1 (владелец):\n1. Задайте пароль синхронизации и войдите через Google.\n2. В блоке «Поделиться с другим аккаунтом» укажите email аккаунта 2 и поделитесь.\n\nАккаунт 2 (участник):\n1. Нажмите «Подключиться к чужой синхронизации».\n2. Войдите через Google (нужен расширенный доступ к Drive, чтобы найти расшаренный файл).\n3. Выберите файл синхронизации и введите тот же пароль, что у аккаунта 1.\n4. «Синхронизировать» обменивает данные через этот общий файл в обе стороны.';

  @override
  String get googleDriveHelpPassphraseNote =>
      'Пароль никогда не уходит в Google — там только зашифрованные данные. Всем участникам нужно знать и ввести один и тот же пароль.';

  @override
  String get googleDriveHelpRegenNote =>
      'Если после подключения сменить или перегенерировать пароль, другие устройства и аккаунты перестанут расшифровывать данные, пока не введут новый пароль.';

  @override
  String get googleDriveJoinShared => 'Подключиться к чужой синхронизации';

  @override
  String get googleDriveJoinPickTitle => 'Расшаренные файлы синхронизации';

  @override
  String get googleDriveJoinPickEmpty =>
      'Расшаренных файлов Valtero не найдено. Попросите владельца сначала поделиться с этим аккаунтом Google.';

  @override
  String get googleDriveJoinConfirm => 'Подключиться';

  @override
  String get googleDriveJoinedAs => 'Подключено к общей синхронизации';

  @override
  String get googleDriveLeaveShared => 'Отключиться от общей синхронизации';

  @override
  String get googleDrivePassphraseChangeTitle =>
      'Сменить пароль синхронизации?';

  @override
  String get googleDrivePassphraseChangeBody =>
      'Другие устройства и аккаунты перестанут синхронизироваться, пока не введут новый пароль. Продолжить?';

  @override
  String googleDriveSharedFrom(String email) {
    return 'От $email';
  }

  @override
  String fetchAllRatesFrom(String service) {
    return 'Получить все курсы из $service';
  }

  @override
  String fetchAllRatesDone(int count, String service) {
    return 'Сохранено $count курсов из $service в локальный кэш';
  }

  @override
  String fetchRateFromService(String service) {
    return 'Получить из $service';
  }

  @override
  String rateFetchedFromCache(String service) {
    return 'Курс из локального кэша ($service). Нажмите обновление, чтобы скачать заново.';
  }

  @override
  String get rateRefreshPair => 'Обновить этот курс';

  @override
  String ratesFetchCooldown(int minutes) {
    return 'Следующий сетевой запрос через $minutes мин (чтобы хватило бесплатного лимита)';
  }

  @override
  String flagUnavailableTooltip(String code) {
    return 'Нет флага для $code';
  }

  @override
  String get telegramNotConnectedHint =>
      'Подключите Telegram в Настройки → Интеграции, чтобы отправлять экспорт туда.';

  @override
  String get openTelegramIntegration => 'Открыть настройки Telegram';

  @override
  String get openExchangeRateApiIntegration => 'Настроить ExchangeRate-API';

  @override
  String get rateSourceConnected => 'Курсы: ExchangeRate-API (подключено)';

  @override
  String get rateSourceFrankfurter => 'Frankfurter';

  @override
  String get debugLoggingEnabled => 'Подробные логи';

  @override
  String get debugLoggingDescription =>
      'При включении в лог пишутся подробные события. Ошибки пишутся всегда. Секреты (API-ключи, токены бота, chat id, парольные фразы) никогда не записываются.';

  @override
  String get debugViewLogs => 'Содержимое лога';

  @override
  String get debugShareLogs => 'Поделиться';

  @override
  String get debugSendToDeveloper => 'Отправить разработчику';

  @override
  String get debugCopyLogs => 'Скопировать логи';

  @override
  String get debugClearLogs => 'Очистить логи';

  @override
  String get debugRefreshLogs => 'Обновить лог';

  @override
  String get debugLogsEmpty => 'Записей в логе пока нет.';

  @override
  String get debugLogsShared => 'Файл лога готов к отправке';

  @override
  String get debugLogsEmailed => 'Открыт выбор почтового приложения';

  @override
  String get debugLogsEmailFallback =>
      'Не удалось приложить файл. Путь к логу скопирован — вставьте или приложите его в письме.';

  @override
  String get debugLogsCopied => 'Логи скопированы в буфер';

  @override
  String get debugLogsCleared => 'Логи очищены';

  @override
  String get settingsDataSync => 'Резервная копия и синхронизация';

  @override
  String get dataSyncTitle => 'Резервная копия и синхронизация';

  @override
  String get dataSyncExport => 'Экспорт';

  @override
  String get dataSyncImport => 'Импорт';

  @override
  String get dataSyncChooseFile => 'Выбрать файл копии';

  @override
  String get dataSyncFileSelected => 'Файл копии выбран';

  @override
  String get dataSyncImportFromFile => 'Импорт из файла';

  @override
  String get dataSyncImportMergeHint =>
      'Импорт данных из файла. Существующие траты не будут перезаписаны — добавятся новые данные.';

  @override
  String get dataSyncGuide =>
      'Экспорт: создайте зашифрованную копию с парольной фразой, затем сохраните или отправьте файл. Импорт: загрузите этот файл на этом или другом устройстве и введите ту же фразу, чтобы восстановить данные. Синхронизация — обмен этим файлом между устройствами.';

  @override
  String get dataSyncShareManualTitle => 'Как отправить копию';

  @override
  String get dataSyncShareManualGuide =>
      'Встроенная кнопка «Поделиться» на этой платформе недоступна. После сохранения файла отправьте его сами, например:\n• приложите к письму по почте;\n• отправьте в Telegram (или другом мессенджере) как документ;\n• загрузите в облако (Google Drive, Dropbox и т.п.) или скопируйте на флешку.\nНа другом устройстве откройте «Резервная копия и синхронизация» → Импорт → выберите файл и введите ту же парольную фразу.';

  @override
  String get dataSyncCopyFilePath => 'Скопировать путь к файлу';

  @override
  String get dataSyncPassphrase => 'Парольная фраза';

  @override
  String get dataSyncGeneratePassphrase => 'Сгенерировать фразу';

  @override
  String get dataSyncCopyPassphrase => 'Скопировать фразу';

  @override
  String get dataSyncGenerateShort => 'Сгенерировать';

  @override
  String get dataSyncCopyShort => 'Скопировать';

  @override
  String get dataSyncShowPassphrase => 'Показать фразу';

  @override
  String get dataSyncHidePassphrase => 'Скрыть фразу';

  @override
  String get dataSyncApplyAppearance => 'Применить оформление из копии';

  @override
  String get dataSyncApplyAppearanceHint =>
      'Восстановит тему, язык, форматы сумм и дат, часовой пояс и валюты отчёта из резервной копии. Выключите, чтобы оставить текущий вид на этом устройстве.';

  @override
  String get dataSyncPassphraseWarning =>
      'Сохраните парольную фразу в надёжном месте. Без неё резервную копию открыть нельзя.';

  @override
  String get dataSyncExportDone => 'Резервная копия сохранена';

  @override
  String get dataSyncExportFailed => 'Не удалось сохранить резервную копию';

  @override
  String dataSyncImportDone(int expenses, int incomes, int tags, int payments) {
    return 'Импортировано: $expenses трат, $incomes доходов, $tags тегов, $payments способов оплаты';
  }

  @override
  String get dataSyncWrongPassphrase => 'Неверная фраза или повреждённый файл';

  @override
  String get dataSyncUnsupportedFormat =>
      'Неподдерживаемый или повреждённый файл резервной копии';

  @override
  String get dataSyncNewerSchema =>
      'Для этой копии нужна более новая версия приложения';

  @override
  String get dataSyncIntegrationsNotTransferred =>
      'API-ключи и данные Telegram в резервную копию не входят.';

  @override
  String get dataSyncGoogleDriveHint =>
      'Также можно включить автоматическую зашифрованную синхронизацию через Google Drive — без ручного обмена файлами между устройствами.';

  @override
  String get dataSyncGoogleDriveSetup => 'Подключить Google Drive Sync';

  @override
  String get dataSyncGoogleDriveManage => 'Открыть настройки Google Drive Sync';

  @override
  String dataSyncImportDoneWithDuplicates(
    int expenses,
    int incomes,
    int tags,
    int payments,
    int skipped,
  ) {
    return 'Импортировано: $expenses трат, $incomes доходов, $tags тегов, $payments способов оплаты (пропущено дублей: $skipped)';
  }

  @override
  String get dataSyncDuplicatesFoundTitle => 'Найдены возможные дубли';

  @override
  String get dataSyncDuplicatesFoundHint =>
      'Эти входящие траты или доходы похожи на уже существующие (тот же день, сумма и валюта). Выберите, как поступить с каждой.';

  @override
  String get dataSyncMarkAsDuplicate => 'Пометить как дубль';

  @override
  String get dataSyncMarkAsUnique => 'Пометить как уникальную';

  @override
  String get dataSyncMarkSelectedAsDuplicate => 'Выбранные → дубли';

  @override
  String get dataSyncMarkSelectedAsUnique => 'Выбранные → уникальные';

  @override
  String get dataSyncMarkAllAsDuplicate => 'Все → дубли';

  @override
  String get dataSyncMarkAllAsUnique => 'Все → уникальные';

  @override
  String get dataSyncContinueImport => 'Продолжить импорт';

  @override
  String get dataSyncIncomingExpense => 'Входящая';

  @override
  String get dataSyncExistingExpense => 'Существующая';

  @override
  String get possibleDuplicateTooltip => 'Возможный дубль';

  @override
  String possibleDuplicatesBannerTitle(int count) {
    return 'Возможные дубли ($count)';
  }

  @override
  String get duplicateReviewSheetTitle => 'Возможные дубли';

  @override
  String get duplicateMarkNotDuplicate => 'Это не дубль';

  @override
  String get duplicateConflictDialogTitle => 'Найдена похожая трата';

  @override
  String get duplicateConflictDialogHint =>
      'Уже есть трата с тем же днём, суммой и валютой.';

  @override
  String get duplicateSaveAsUnique => 'Сохранить как уникальную';

  @override
  String get duplicateDeleteMatchAndSave => 'Удалить похожую и сохранить';

  @override
  String get duplicateYourExpense => 'Ваша трата';

  @override
  String get duplicateMatchingExpense => 'Похожая трата';

  @override
  String get duplicateYourIncome => 'Ваш доход';

  @override
  String get duplicateMatchingIncome => 'Похожий доход';

  @override
  String get dashboardRestoreFromBackup => 'Восстановить из копии';

  @override
  String get selectCountry => 'Выбрать страну';

  @override
  String get addExpense => 'Добавить трату';

  @override
  String get editExpense => 'Изменить трату';

  @override
  String get expenseDetails => 'Детали операции';

  @override
  String get close => 'Закрыть';

  @override
  String get amount => 'Сумма';

  @override
  String get amountRequired => 'Введите корректную сумму';

  @override
  String get amountCalculatorTooltip => 'Калькулятор суммы';

  @override
  String get amountCalculatorTitle => 'Калькулятор суммы';

  @override
  String get amountCalculatorOriginal => 'Старая сумма';

  @override
  String get amountCalculatorResult => 'Итого';

  @override
  String get amountCalculatorOperand => 'Значение';

  @override
  String get amountCalculatorApply => 'Применить';

  @override
  String get amountCalculatorOpAdd => 'Добавить к';

  @override
  String get amountCalculatorOpSubtract => 'Вычесть из';

  @override
  String get amountCalculatorOpMultiply => 'Умножить на';

  @override
  String get amountCalculatorOpDivide => 'Поделить на';

  @override
  String get amountCalculatorOpPercentOf => 'Процент от';

  @override
  String get amountCalculatorErrorEmpty => 'Введите значение';

  @override
  String get amountCalculatorErrorDivideByZero => 'Нельзя делить на ноль';

  @override
  String get amountCalculatorErrorNonPositive => 'Итог должен быть больше нуля';

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
  String get create => 'Создать';

  @override
  String get ok => 'OK';

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
  String get confirmDeleteExpenseDescription =>
      'Эта трата будет удалена безвозвратно.';

  @override
  String get expenseDeleted => 'Трата удалена';

  @override
  String get confirmDeleteIncome => 'Удалить этот доход?';

  @override
  String get confirmDeleteIncomeDescription =>
      'Эта запись о доходе будет удалена безвозвратно.';

  @override
  String get incomeDeleted => 'Доход удалён';

  @override
  String bulkSelectedCount(int count) {
    return 'Выбрано: $count';
  }

  @override
  String bulkAndMore(int count) {
    return '…и ещё $count';
  }

  @override
  String get bulkDeleteTitle => 'Удалить траты?';

  @override
  String bulkDeleteDescription(String list) {
    return 'Эти траты будут удалены безвозвратно:\n$list';
  }

  @override
  String get bulkChangeTags => 'Изменить теги';

  @override
  String get bulkChangeTagsTitle => 'Изменить теги';

  @override
  String bulkChangeTagsDescription(String list) {
    return 'Новые теги заменят текущие у:\n$list';
  }

  @override
  String get bulkChangeCountry => 'Изменить страну';

  @override
  String get bulkChangeCountryTitle => 'Изменить страну';

  @override
  String bulkChangeCountryDescription(String list) {
    return 'Страна будет обновлена у:\n$list';
  }

  @override
  String get bulkChangeCurrency => 'Изменить валюту';

  @override
  String get bulkChangeCurrencyTitle => 'Изменить валюту';

  @override
  String bulkChangeCurrencyDescription(String currency, String list) {
    return 'Суммы будут конвертированы в $currency у:\n$list';
  }

  @override
  String bulkExpensesDeleted(int count) {
    return 'Удалено трат: $count';
  }

  @override
  String bulkExpensesUpdated(int count) {
    return 'Обновлено трат: $count';
  }

  @override
  String get bulkDeleteTitleIncome => 'Удалить пополнения?';

  @override
  String bulkDeleteDescriptionIncome(String list) {
    return 'Эти пополнения будут удалены безвозвратно:\n$list';
  }

  @override
  String bulkIncomeDeleted(int count) {
    return 'Удалено пополнений: $count';
  }

  @override
  String bulkIncomeUpdated(int count) {
    return 'Обновлено пополнений: $count';
  }

  @override
  String get bulkDeleteTitleCashFlow => 'Удалить операции?';

  @override
  String bulkDeleteDescriptionCashFlow(String list) {
    return 'Эти операции будут удалены безвозвратно:\n$list';
  }

  @override
  String bulkCashFlowDeleted(int count) {
    return 'Удалено операций: $count';
  }

  @override
  String bulkCashFlowUpdated(int count) {
    return 'Обновлено операций: $count';
  }

  @override
  String get bulkChangeTagsMixedKinds =>
      'Для изменения тегов выберите только траты или только пополнения';

  @override
  String get bulkCurrencyRateUnavailable =>
      'Не удалось конвертировать: курс недоступен';

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
  String get expense => 'Трата';

  @override
  String get income => 'Доход';

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
  String get dateFormat => 'Отображение даты';

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
  String get tagSalary => 'Зарплата';

  @override
  String get tagSale => 'Продажа';

  @override
  String get tagGift => 'Подарок';

  @override
  String get tagRefund => 'Возврат';

  @override
  String get tagInvestment => 'Инвестиции';

  @override
  String get tagOtherIncome => 'Прочий доход';

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
  String get chartByTagCustom => 'Категория';

  @override
  String get chartTagKindHintCategories =>
      'Каждая трата учитывается один раз внутри выбранного типа; без тега попадает в «не указано». Отображаются только категории.';

  @override
  String get chartTagKindHintSubcategories =>
      'Каждая трата учитывается один раз внутри выбранного типа; без тега попадает в «не указано». Отображаются категории и подкатегории.';

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
  String get chartTypeDonut => 'Круговая диаграмма';

  @override
  String get chartTypeColumn => 'Столбчатая диаграмма';

  @override
  String get chartTypeColumnByDate => 'Столбцы по дате';

  @override
  String get chartTypeLine => 'Линейный график';

  @override
  String get chartShowCategories => 'Категории';

  @override
  String get chartShowSubcategories => 'Подкатегории';

  @override
  String get chartOtherSeries => 'Другое';

  @override
  String get googleDriveSyncInProgress => 'Синхронизация…';

  @override
  String googleDriveSyncDoneWithCounts(int expensesAdded, int incomesAdded) {
    return 'Синхронизация завершена: добавлено расходов — $expensesAdded, доходов — $incomesAdded';
  }

  @override
  String googleDriveSyncDoneWithDuplicates(
    int expensesAdded,
    int incomesAdded,
    int skipped,
  ) {
    return 'Синхронизация завершена: добавлено расходов — $expensesAdded, доходов — $incomesAdded, пропущено дубликатов — $skipped';
  }

  @override
  String get chartHelpBody =>
      'На графике учитываются траты во всех валютах. Если курс не указан, суммы показываются в исходной валюте. Итоги могут смешивать валюты, пока курсы не заданы.';

  @override
  String get expensesSummaryHelpTitle => 'О сводке расходов';

  @override
  String get expensesSummaryHelpBody =>
      'Итоги сгруппированы по сохранённой валюте. Кнопка конвертации переводит суммы в списке в одну валюту; итог конвертации показывает, сколько расходов удалось пересчитать.';

  @override
  String get incomeSummaryHelpTitle => 'О сводке доходов';

  @override
  String get incomeSummaryHelpBody =>
      'Итоги сгруппированы по сохранённой валюте. Кнопка конвертации переводит суммы в списке в одну валюту; итог конвертации показывает, сколько доходов удалось пересчитать.';

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
  String get tagKindSectionIncome => 'Категория дохода';

  @override
  String get tagKindUnspecifiedCountry => 'Страна не указана';

  @override
  String get tagKindUnspecifiedTrip => 'Поездка не указана';

  @override
  String get tagKindUnspecifiedCustom => 'Категория не указана';

  @override
  String get tagKindUnspecifiedIncome => 'Категория дохода не указана';

  @override
  String get tagKindSingleSelectHint =>
      'Один тег из группы; группы необязательны';

  @override
  String get tagIcon => 'Иконка';

  @override
  String get tagIconNone => 'Без иконки';

  @override
  String get addIncome => 'Добавить доход';

  @override
  String get editIncome => 'Изменить доход';

  @override
  String get navIncome => 'Доходы';

  @override
  String get directionExpenses => 'Расходы';

  @override
  String get directionIncome => 'Доходы';

  @override
  String get directionCashFlow => 'Баланс';

  @override
  String get cashFlowIncome => 'Доходы';

  @override
  String get cashFlowExpense => 'Расходы';

  @override
  String get cashFlowNet => 'Итого';

  @override
  String get summaryCashFlow => 'Денежный поток';

  @override
  String get cashFlowSummaryHelpTitle => 'Сводка по денежному потоку';

  @override
  String get cashFlowSummaryHelpBody =>
      'Показывает доходы, расходы и итог по каждой валюте. Конвертация использует текущие курсы; операции без курса не включаются в общий итог.';

  @override
  String summaryPerCurrencyOperationCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count операции',
      many: '$count операций',
      few: '$count операции',
      one: '1 операция',
    );
    return '$_temp0';
  }

  @override
  String get columnType => 'Тип';

  @override
  String get operationTypeIncome => 'Доход';

  @override
  String get operationTypeExpense => 'Расход';

  @override
  String get exportIncome => 'Экспорт доходов';

  @override
  String get duplicateConflictIncomeTitle => 'Найден похожий доход';

  @override
  String get showIncomeList => 'Показать доходы';

  @override
  String get fabShow => 'Показать';

  @override
  String get showCashFlow => 'Показать баланс';

  @override
  String get noIncomeYet => 'Пока нет доходов';

  @override
  String get incomeEmptyTitle => 'Пока нет доходов';

  @override
  String get noMatchingIncome => 'Нет доходов по выбранным фильтрам';

  @override
  String get noMatchingOperations => 'Нет операций по выбранным фильтрам';

  @override
  String get noOperationsYet => 'Пока нет операций';

  @override
  String chartMissingRatesAlertGeneric(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count операции показаны без курса конвертации',
      many: '$count операций показано без курса конвертации',
      few: '$count операции показаны без курса конвертации',
      one: '1 операция показана без курса конвертации',
    );
    return '$_temp0';
  }

  @override
  String get guideSectionIncomeTitle => 'Доходы';

  @override
  String get guideSectionIncomeBody =>
      'Нажмите + и выберите «Добавить доход» (или откройте вкладку «Доходы»). Поступление с теми же полями суммы, валюты, оплаты, страны и даты, что и у трат; для доходов — свои категории (зарплата, продажа, подарок и др.). Проверка возможных дублей работает так же.';

  @override
  String get guideSectionCashFlowTitle => 'Баланс';

  @override
  String get guideSectionCashFlowBody =>
      'Вкладка «Баланс» сравнивает доходы и расходы. По умолчанию — кольцевая диаграмма (сумма доходов против суммы расходов); можно переключить на столбцы по дням, неделям, месяцам или годам. Фильтры по дате и валюте общие; категории и оплата остаются на вкладках «Расходы» и «Доходы».';

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
      'Выберите способ оплаты по умолчанию для новых трат и доходов. Это не привязка оплаты к приложению — только пресет при создании операций. Встроенные способы нельзя удалить.';

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
  String get chartByDay => 'Дни';

  @override
  String get chartByWeek => 'Недели';

  @override
  String get chartByDate => 'По дате';

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
  String get summaryCount => 'Расходов';

  @override
  String get summaryExpenses => 'Расходы';

  @override
  String get summaryCurrencies => 'Валют';

  @override
  String summaryPerCurrencyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count расхода',
      many: '$count расходов',
      few: '$count расхода',
      one: '1 расход',
    );
    return '$_temp0';
  }

  @override
  String summaryPerCurrencyIncomeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дохода',
      many: '$count доходов',
      few: '$count дохода',
      one: '1 доход',
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
  String get columnOriginalAmount => 'Начальная сумма';

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
      'Пример — так будет выглядеть график после добавления трат или доходов';

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
      'Нажмите + внизу экрана и выберите «Добавить трату» или «Добавить доход». Укажите сумму и валюту, при необходимости конвертируйте в отчётную валюту, выберите страну и категории, сохраните. Если уже есть трата с тем же днём, суммой и валютой, можно сохранить как уникальную, удалить похожую или отменить. Нажмите на существующую трату, чтобы изменить её в той же форме — у поля суммы есть иконка калькулятора для пересчёта. Пока трат нет, на дашборде — пример графика со ссылкой на это руководство.';

  @override
  String get guideSectionExpenseTrackingTitle => 'Отслеживание расходов';

  @override
  String get guideSectionExpenseTrackingBody =>
      'У каждой траты хранятся сумма, валюта, дата, необязательная страна (ISO), способ оплаты, категории и заметка. Исходные сумма и валюта всегда сохраняются, даже если вы конвертируете в отчётную валюту. При редактировании нажмите иконку калькулятора у поля суммы, чтобы добавить, вычесть, умножить, разделить или взять процент от текущей суммы. В списке трат можно отметить несколько строк и сразу удалить их или изменить теги, страну или валюту. Возможные дубли (тот же день, исходная сумма и валюта) помечаются значком; откройте баннер, чтобы удалить строку или отметить «это не дубль».';

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
      'Курсы обновляются в фоне, если устарели (примерно раз в сутки). Подключите ExchangeRate-API в Настройки → Интеграции, обновите вручную, задайте свои курсы и просмотрите все пары в Настройки → Валюта и курсы. Без ключа используется Frankfurter (ECB).';

  @override
  String get guideSectionExportTitle => 'Экспорт';

  @override
  String get guideSectionExportBody =>
      'Выгружайте траты в CSV или JSON. Сохраните файл, поделитесь им или скопируйте в буфер из меню экспорта или Настройки → Экспорт. Telegram появляется как назначение только после подключения в Интеграциях.';

  @override
  String get guideSectionDataSyncTitle => 'Резервная копия и синхронизация';

  @override
  String get guideSectionDataSyncBody =>
      'Создайте зашифрованную копию трат, тегов, способов оплаты, ручных курсов и настроек отображения. Защитите своей парольной фразой или сгенерированной. Сохраните файл (на Android/iOS через «Поделиться» можно сохранить в файлы / загрузки), затем отправьте (почта, Telegram как документ, облако, флешка). Импорт и Google Drive Sync объединяют операции по правилу «побеждает последняя правка» (включая удаления). Сопоставление — по стабильному sync id или по тому же дню, сумме и валюте, если совпадение однозначное. Только неоднозначные дубли по-прежнему спрашивают: пропустить или импортировать как уникальные. Восстановите из Настройки → Резервная копия и синхронизация или с пустого дашборда. API-ключи и Telegram в копию не входят.';

  @override
  String get guideSectionTelegramTitle => 'Шаринг через Telegram';

  @override
  String get guideSectionTelegramBody =>
      'Подключите Telegram в Настройки → Интеграции, укажите токен бота и chat id, проверьте соединение — и отправляйте файл экспорта из меню экспорта.';

  @override
  String get guideSectionIntegrationsTitle => 'Интеграции';

  @override
  String get guideSectionIntegrationsBody =>
      'Опциональные сервисы (Telegram, Frankfurter, ExchangeRate-API, синхронизация Google Drive) живут в Настройки → Интеграции. У каждой свой форма. Frankfurter встроен (курсы ECB, без ключа) и используется, если ExchangeRate-API не подключён. Google Drive Sync шифрует снимок локально, кладёт его в appDataFolder и подтягивает/сливает при запуске и после правок. Общий доступ между аккаунтами — отдельный файл и разрешение drive.file. Зависимые пункты UI появляются только пока интеграция подключена.';

  @override
  String get guideSectionDebugTitle => 'Отладка и логи';

  @override
  String get guideSectionDebugBody =>
      'В Настройки → Отладка и логи можно включить подробные логи. Ошибки пишутся всегда. Лог можно просмотреть, скопировать, поделиться с кем угодно или отправить разработчику письмом с вложением; секреты маскируются.';

  @override
  String get guideSectionFiltersTitle => 'Фильтры';

  @override
  String get guideSectionFiltersBody =>
      'Фильтруйте по периоду, валюте, тегам и оплате на дашборде и в списке трат. Оба экрана показывают компактную полосу сводки, которая открывает фильтры в полноэкранном листе. Применяйте или сбрасывайте фильтры в любой момент.';

  @override
  String get guideSectionVoiceExpenseTitle => 'Голосовой ввод трат';

  @override
  String get guideSectionVoiceExpenseBody =>
      'На Android откройте «Добавить трату» и нажмите микрофон. Говорите по паттерну сумма → валюта → категория → оплата (пример: кофе 350 рублей карта). Проверьте распознанное, затем «Создать» — поля формы заполнятся, или «Отмена» — останутся пустыми. Аудио и расшифровку не сохраняем (заметка из речи не заполняется); в логи попадают только ошибки распознавания. Используется системное распознавание речи телефона; язык диктовки не ограничен языком интерфейса приложения. На Linux и Windows недоступно.';

  @override
  String get voiceExpenseMicTooltip => 'Надиктовать трату';

  @override
  String get voiceExpenseTitle => 'Надиктовать трату';

  @override
  String get voiceExpenseInitializing => 'Запуск микрофона…';

  @override
  String get voiceExpenseListening => 'Слушаю…';

  @override
  String get voiceExpenseSpeakHint => 'Назовите сумму и детали';

  @override
  String get voiceExpensePatternHint =>
      'Паттерн: сумма → валюта → категория → оплата';

  @override
  String get voiceExpensePatternExample => 'Пример: кофе 350 рублей карта';

  @override
  String get voiceExpensePrivacyNote =>
      'Аудио и расшифровку не сохраняем. В логи попадают только ошибки распознавания.';

  @override
  String get voiceExpenseHeardLabel => 'Услышано';

  @override
  String get voiceExpenseDoneListening => 'Готово';

  @override
  String get voiceExpenseRecognized => 'Распознано';

  @override
  String get voiceExpenseNotDetected => 'Не определено';

  @override
  String get voiceExpenseCreate => 'Создать';

  @override
  String get voiceExpenseRetry => 'Ещё раз';

  @override
  String get voiceExpenseUnavailable =>
      'Распознавание речи недоступно. Проверьте разрешение микрофона.';

  @override
  String get voiceExpenseEmpty => 'Ничего не распознано. Попробуйте ещё раз.';

  @override
  String get subcategory => 'Подкатегория';

  @override
  String get subcategoryNone => 'Нет';

  @override
  String get addSubcategory => 'Добавить подкатегорию';

  @override
  String get parentCategory => 'Родительская категория';

  @override
  String get topLevelCategory => 'Категория верхнего уровня';

  @override
  String get tagHouseholdSupplies => 'Хозтовары';

  @override
  String get tagAlcohol => 'Алкоголь';

  @override
  String get tagSnacks => 'Снеки';

  @override
  String get tagFuel => 'Бензин';

  @override
  String get tagRepair => 'Ремонт';

  @override
  String get tagTuning => 'Тюнинг';

  @override
  String get tagRent => 'Аренда';

  @override
  String get tagUtilitiesBill => 'Коммунальные';

  @override
  String get tagFurniture => 'Мебель';

  @override
  String get tagRestaurant => 'Ресторан';

  @override
  String get tagCafe => 'Кафе';

  @override
  String get tagDelivery => 'Доставка';

  @override
  String get tagLabTests => 'Анализы';

  @override
  String get tagDoctor => 'Врач';

  @override
  String get tagMedications => 'Лекарства';

  @override
  String get tagCinema => 'Кино';

  @override
  String get tagGames => 'Игры';

  @override
  String get tagStreaming => 'Стриминг';

  @override
  String get tagClothing => 'Одежда';

  @override
  String get tagElectronics => 'Электроника';

  @override
  String get tagGiftsShopping => 'Подарки';

  @override
  String get tagFlights => 'Авиабилеты';

  @override
  String get tagHotels => 'Отели';

  @override
  String get tagTours => 'Экскурсии';

  @override
  String get tagBonus => 'Премия';

  @override
  String get tagOvertime => 'Сверхурочные';

  @override
  String get tagAdvance => 'Аванс';

  @override
  String get tagPersonalItems => 'Личные вещи';

  @override
  String get tagPropertySale => 'Недвижимость';

  @override
  String get tagVehicleSale => 'Автомобиль';

  @override
  String get tagFamilyGift => 'Семья';

  @override
  String get tagFriendsGift => 'Друзья';

  @override
  String get tagHolidayGift => 'Праздник';

  @override
  String get tagTaxRefund => 'Налоговый возврат';

  @override
  String get tagPurchaseRefund => 'Возврат покупки';

  @override
  String get tagInsuranceRefund => 'Страховой возврат';

  @override
  String get tagDividends => 'Дивиденды';

  @override
  String get tagInterestIncome => 'Проценты';

  @override
  String get tagCapitalGains => 'Прирост капитала';

  @override
  String get tagFreelance => 'Фриланс';

  @override
  String get tagCashback => 'Кэшбэк';

  @override
  String get tagSideGig => 'Подработка';

  @override
  String get tagPetFood => 'Корм для животных';

  @override
  String get tagBabyFood => 'Детское питание';

  @override
  String get tagParking => 'Парковка';

  @override
  String get tagTaxi => 'Такси';

  @override
  String get tagPublicTransit => 'Общественный транспорт';

  @override
  String get tagDacha => 'Дача';

  @override
  String get tagHomeRepairs => 'Ремонт дома';

  @override
  String get tagCleaning => 'Уборка';

  @override
  String get tagInternet => 'Интернет';

  @override
  String get tagDentistry => 'Стоматология';

  @override
  String get tagOptics => 'Оптика';

  @override
  String get tagEvents => 'Мероприятия';

  @override
  String get tagHobbies => 'Хобби';

  @override
  String get tagHomeGoods => 'Товары для дома';

  @override
  String get tagBeauty => 'Красота';

  @override
  String get tagTravelInsurance => 'Страховка';

  @override
  String get tagVisas => 'Визы';
}
