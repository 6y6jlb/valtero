// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Valtero';

  @override
  String get navDashboard => 'Panel';

  @override
  String get navExpenses => 'Gastos';

  @override
  String get recentOperations => 'Operaciones recientes';

  @override
  String get navAdd => 'Añadir';

  @override
  String get navTags => 'Etiquetas';

  @override
  String get navCurrency => 'Moneda';

  @override
  String get navExport => 'Exportar';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get settingsAppearance => 'Apariencia';

  @override
  String get settingsCurrency => 'Moneda y tipos de cambio';

  @override
  String get settingsExport => 'Exportar';

  @override
  String get settingsIntegrations => 'Integraciones';

  @override
  String get settingsDebug => 'Depuración y registros';

  @override
  String get integrationConnected => 'Conectado';

  @override
  String get integrationNotConnected => 'No conectado';

  @override
  String get integrationTestConnection => 'Probar conexión';

  @override
  String get integrationSave => 'Guardar';

  @override
  String get integrationDisconnect => 'Desconectar';

  @override
  String get connectionOk => 'Conexión correcta';

  @override
  String get connectionFailed => 'Error de conexión';

  @override
  String get connectionNetwork =>
      'Sin red o falló la resolución DNS. Comprueba internet, VPN o DNS e inténtalo de nuevo.';

  @override
  String get connectionMissingFields =>
      'Completa todos los campos obligatorios';

  @override
  String get connectionInvalidToken => 'El token del bot no es válido';

  @override
  String get connectionInvalidChat =>
      'El chat id no es válido o el bot no tiene acceso';

  @override
  String get connectionInvalidKey => 'La clave API no es válida';

  @override
  String get showSecret => 'Mostrar';

  @override
  String get hideSecret => 'Ocultar';

  @override
  String get integrationTelegramTitle => 'Telegram';

  @override
  String get integrationTelegramDescription =>
      'Envía exportaciones de gastos a un chat de Telegram mediante un bot.';

  @override
  String get integrationFrankfurterTitle => 'Frankfurter';

  @override
  String get integrationFrankfurterDescription =>
      'Tipos BCE gratuitos (sin clave API). Se usan automáticamente si ExchangeRate-API no está conectado.';

  @override
  String get integrationFrankfurterHint =>
      'Reserva integrada. Prueba api.frankfurter.dev: si falla, los tipos no se actualizarán hasta que la red/DNS funcione. Solo monedas del conjunto BCE.';

  @override
  String get integrationExchangeRateApiTitle => 'ExchangeRate-API';

  @override
  String get integrationExchangeRateApiDescription =>
      'Tipos de cambio con una clave de exchangerate-api.com (API v6). Las claves de exchangeratesapi.io no sirven. Sin clave se usa Frankfurter (BCE).';

  @override
  String get exchangeRateApiEnabled => 'Usar ExchangeRate-API para los tipos';

  @override
  String get integrationGoogleDriveSyncTitle =>
      'Sincronización con Google Drive';

  @override
  String get integrationGoogleDriveSyncDescription =>
      'Sincronización automática cifrada entre dispositivos vía Google Drive. Google no ve tus gastos — solo el texto cifrado.';

  @override
  String get googleDriveSignIn => 'Iniciar sesión con Google';

  @override
  String get googleDriveSyncNow => 'Sincronizar ahora';

  @override
  String get googleDriveSyncOk => 'Sincronización completada';

  @override
  String get googleDriveSyncPassphrase => 'Frase de sincronización';

  @override
  String get googleDriveSyncPassphraseHint =>
      'Solo se usa en este dispositivo para cifrar. Google nunca la recibe. Usa la misma frase en todos los dispositivos.';

  @override
  String get googleDrivePassphraseTooShort =>
      'La frase debe tener al menos 8 caracteres';

  @override
  String get googleDriveWrongPassphrase =>
      'Frase incorrecta para la copia remota';

  @override
  String get googleDriveMissingClientId =>
      'Falta el client id de Google OAuth. Copia local.oauth.env.example a local.oauth.env, pon GOOGLE_OAUTH_CLIENT_ID_DESKTOP / _ANDROID y vuelve a compilar (make run-*).';

  @override
  String get googleDriveReauthRequired => 'Vuelve a iniciar sesión con Google';

  @override
  String get googleDriveSignInFailed => 'No se pudo iniciar sesión con Google';

  @override
  String get googleDriveAuthCanceled =>
      'Se canceló el inicio de sesión con Google';

  @override
  String get googleDriveAccessDenied =>
      'Se denegó el acceso de Google. Concede permisos de Drive e inténtalo de nuevo.';

  @override
  String get googleDriveAndroidCustomUriHint =>
      'En Android, abre Google Cloud Console → tu cliente OAuth de Android → Advanced settings y activa “Custom URI scheme”, luego inténtalo de nuevo. Google bloquea este redirect por defecto en clientes Android nuevos.';

  @override
  String get googleDriveMissingClientSecret =>
      'Falta el client secret de OAuth de escritorio. En Google Cloud Console abre el cliente Desktop, copia el Client secret a local.oauth.env como GOOGLE_OAUTH_CLIENT_SECRET_DESKTOP y vuelve a compilar (make run-linux).';

  @override
  String googleDriveLastSynced(String when) {
    return 'Última sincronización: $when';
  }

  @override
  String get relativeTimeJustNow => 'Justo ahora';

  @override
  String relativeTimeMinutesAgo(int count) {
    return 'hace $count min';
  }

  @override
  String relativeTimeHoursAgo(int count) {
    return 'hace $count h';
  }

  @override
  String relativeTimeDaysAgo(int count) {
    return 'hace $count d';
  }

  @override
  String get googleDriveSyncStatusHint => 'Hora de la última sincronización';

  @override
  String get actionSuccessStatusHint => 'Hora de la última acción';

  @override
  String get googleDriveSharedTitle =>
      'Sincronización compartida (otras cuentas de Google)';

  @override
  String get googleDriveSharedDescription =>
      'Comparte el archivo cifrado con otra persona. Requiere el permiso drive.file; el lanzamiento público puede necesitar verificación OAuth.';

  @override
  String get googleDriveShareEmail => 'Correo del colaborador';

  @override
  String get googleDriveShareAdd => 'Compartir por correo';

  @override
  String get googleDriveShareOk => 'Compartido correctamente';

  @override
  String get googleDriveShareFailed => 'No se pudo compartir el archivo';

  @override
  String get googleDriveInvalidEmail => 'Introduce un correo válido';

  @override
  String get googleDriveRemoteNewerSchemaTitle =>
      'Actualiza la app para sincronizar';

  @override
  String googleDriveRemoteNewerSchema(
    int remoteSchema,
    int localSchema,
    String remoteApp,
  ) {
    return 'Los datos en la nube los escribió una app más nueva (esquema $remoteSchema, app $remoteApp). Este dispositivo usa el esquema $localSchema. La sincronización se detuvo para no sobrescribir datos más nuevos. Actualiza la app e inténtalo de nuevo.';
  }

  @override
  String get googleDriveUnsupportedFormat =>
      'El formato del archivo de sincronización no es compatible con esta versión';

  @override
  String get googleDriveHelpTitle =>
      'Cómo funciona la sincronización con Google Drive';

  @override
  String get googleDriveHelpSameAccountTitle =>
      'Misma cuenta de Google en otro dispositivo';

  @override
  String get googleDriveHelpSameAccountBody =>
      '1. En este dispositivo: define una frase de sincronización e inicia sesión con Google.\n2. En el otro dispositivo: inicia sesión con la misma cuenta e introduce la misma frase.\n3. La sincronización ocurre tras el inicio de sesión y al pulsar Sincronizar. No hace falta más.';

  @override
  String get googleDriveHelpCrossAccountTitle => 'Cuentas de Google distintas';

  @override
  String get googleDriveHelpCrossAccountBody =>
      'Cuenta 1 (propietario):\n1. Define una frase e inicia sesión con Google.\n2. En “Compartir con otra cuenta”, introduce el email de la cuenta 2 y comparte.\n\nCuenta 2 (invitado):\n1. Pulsa “Unirme a una sincronización compartida”.\n2. Inicia sesión con Google (se pide acceso amplio a Drive para encontrar el archivo).\n3. Elige el archivo compartido e introduce la misma frase que usó la cuenta 1.\n4. Sincronizar intercambia datos en ambas direcciones por ese archivo.';

  @override
  String get googleDriveHelpPassphraseNote =>
      'La frase nunca se envía a Google: solo se guarda cifrado. Todos los que sincronizan deben conocer e introducir la misma frase.';

  @override
  String get googleDriveHelpRegenNote =>
      'Si regeneras o cambias la frase tras conectar, los demás dispositivos dejarán de descifrar hasta introducir la nueva.';

  @override
  String get googleDriveJoinShared => 'Unirme a una sincronización compartida';

  @override
  String get googleDriveJoinPickTitle =>
      'Archivos de sincronización compartidos';

  @override
  String get googleDriveJoinPickEmpty =>
      'No hay archivos Valtero compartidos. Pide al propietario que comparta con esta cuenta primero.';

  @override
  String get googleDriveJoinConfirm => 'Unirme';

  @override
  String get googleDriveJoinedAs => 'Unido a sincronización compartida';

  @override
  String get googleDriveLeaveShared => 'Salir de la sincronización compartida';

  @override
  String get googleDrivePassphraseChangeTitle =>
      '¿Cambiar la frase de sincronización?';

  @override
  String get googleDrivePassphraseChangeBody =>
      'Otros dispositivos y cuentas dejarán de sincronizar hasta introducir la nueva frase. ¿Continuar?';

  @override
  String googleDriveSharedFrom(String email) {
    return 'De $email';
  }

  @override
  String fetchAllRatesFrom(String service) {
    return 'Obtener todos los tipos de $service';
  }

  @override
  String fetchAllRatesDone(int count, String service) {
    return 'Guardados $count tipos de $service en la caché local';
  }

  @override
  String fetchRateFromService(String service) {
    return 'Obtener de $service';
  }

  @override
  String rateFetchedFromCache(String service) {
    return 'Tipo de la caché local ($service). Pulsa actualizar para descargar de nuevo.';
  }

  @override
  String get rateRefreshPair => 'Actualizar este tipo';

  @override
  String ratesFetchCooldown(int minutes) {
    return 'Próxima descarga en $minutes min (cuota gratuita de la API)';
  }

  @override
  String flagUnavailableTooltip(String code) {
    return 'Sin bandera para $code';
  }

  @override
  String get telegramNotConnectedHint =>
      'Conecta Telegram en Ajustes → Integraciones para enviar exportaciones allí.';

  @override
  String get openTelegramIntegration => 'Abrir ajustes de Telegram';

  @override
  String get openExchangeRateApiIntegration => 'Configurar ExchangeRate-API';

  @override
  String get rateSourceConnected => 'Tipos: ExchangeRate-API (conectado)';

  @override
  String get rateSourceFrankfurter => 'Frankfurter';

  @override
  String get debugLoggingEnabled => 'Registro detallado';

  @override
  String get debugLoggingDescription =>
      'Al activarlo se escriben eventos detallados. Los errores se registran siempre. Los secretos (claves API, tokens, chat ids, frases) nunca se escriben.';

  @override
  String get debugViewLogs => 'Contenido del registro';

  @override
  String get debugShareLogs => 'Compartir con el desarrollador';

  @override
  String get debugCopyLogs => 'Copiar registros';

  @override
  String get debugClearLogs => 'Borrar registros';

  @override
  String get debugLogsEmpty => 'Aún no hay entradas en el registro.';

  @override
  String get debugLogsShared => 'Archivo de registro listo para compartir';

  @override
  String get debugLogsCopied => 'Registros copiados al portapapeles';

  @override
  String get debugLogsCleared => 'Registros borrados';

  @override
  String get settingsDataSync => 'Copia de seguridad y sincronización';

  @override
  String get dataSyncTitle => 'Copia de seguridad y sincronización';

  @override
  String get dataSyncExport => 'Exportar';

  @override
  String get dataSyncImport => 'Importar';

  @override
  String get dataSyncChooseFile => 'Elegir archivo de copia';

  @override
  String get dataSyncFileSelected => 'Archivo de copia seleccionado';

  @override
  String get dataSyncImportFromFile => 'Importar desde archivo';

  @override
  String get dataSyncImportMergeHint =>
      'Importar datos desde un archivo. Tus gastos existentes no se sobrescribirán: se añadirán los datos nuevos.';

  @override
  String get dataSyncGuide =>
      'Exportar: crea una copia cifrada con una frase de contraseña y guárdala o compártela. Importar: carga ese archivo en este u otro dispositivo e introduce la misma frase para restaurar. Sincronizar es intercambiar este archivo entre dispositivos.';

  @override
  String get dataSyncShareManualTitle => 'Cómo enviar la copia';

  @override
  String get dataSyncShareManualGuide =>
      'Compartir integrado no está disponible en esta plataforma. Después de guardar el archivo, envíalo tú mismo, por ejemplo:\n• adjúntalo a un correo;\n• envíalo por Telegram (u otro mensajero) como documento;\n• súbelo a la nube (Google Drive, Dropbox, …) o cópialo a un USB.\nEn el otro dispositivo abre Copia de seguridad y sincronización → Importar → elige el archivo e introduce la misma frase.';

  @override
  String get dataSyncCopyFilePath => 'Copiar ruta del archivo';

  @override
  String get dataSyncPassphrase => 'Frase de contraseña';

  @override
  String get dataSyncGeneratePassphrase => 'Generar frase';

  @override
  String get dataSyncCopyPassphrase => 'Copiar frase';

  @override
  String get dataSyncGenerateShort => 'Generar';

  @override
  String get dataSyncCopyShort => 'Copiar';

  @override
  String get dataSyncShowPassphrase => 'Mostrar frase';

  @override
  String get dataSyncHidePassphrase => 'Ocultar frase';

  @override
  String get dataSyncApplyAppearance => 'Aplicar apariencia de la copia';

  @override
  String get dataSyncApplyAppearanceHint =>
      'Restaura tema, idioma, formatos de dinero y fecha, zona horaria y monedas de informe de la copia. Déjalo apagado para mantener la apariencia actual de este dispositivo.';

  @override
  String get dataSyncPassphraseWarning =>
      'Guarda esta frase en un lugar seguro. Sin ella no se puede abrir la copia.';

  @override
  String get dataSyncExportDone => 'Copia guardada';

  @override
  String get dataSyncExportFailed => 'No se pudo guardar la copia';

  @override
  String dataSyncImportDone(int expenses, int tags, int payments) {
    return 'Importados $expenses gastos, $tags etiquetas, $payments métodos de pago';
  }

  @override
  String get dataSyncWrongPassphrase => 'Frase incorrecta o archivo dañado';

  @override
  String get dataSyncUnsupportedFormat =>
      'Archivo de copia no válido o no compatible';

  @override
  String get dataSyncNewerSchema =>
      'Esta copia requiere una versión más nueva de la app';

  @override
  String get dataSyncIntegrationsNotTransferred =>
      'Las claves API y las credenciales de Telegram no se incluyen en las copias.';

  @override
  String get dataSyncGoogleDriveHint =>
      'También puedes activar la sincronización cifrada automática con Google Drive — las copias se actualizan entre dispositivos sin intercambiar archivos manualmente.';

  @override
  String get dataSyncGoogleDriveSetup => 'Conectar Google Drive Sync';

  @override
  String get dataSyncGoogleDriveManage => 'Abrir ajustes de Google Drive Sync';

  @override
  String dataSyncImportDoneWithDuplicates(
    int expenses,
    int tags,
    int payments,
    int skipped,
  ) {
    return 'Importados $expenses gastos, $tags etiquetas, $payments métodos de pago ($skipped duplicados omitidos)';
  }

  @override
  String get dataSyncDuplicatesFoundTitle => 'Posibles duplicados encontrados';

  @override
  String get dataSyncDuplicatesFoundHint =>
      'Estos gastos entrantes se parecen a los que ya tienes (mismo día, importe y moneda). Elige cómo tratar cada uno.';

  @override
  String get dataSyncMarkAsDuplicate => 'Marcar como duplicado';

  @override
  String get dataSyncMarkAsUnique => 'Marcar como único';

  @override
  String get dataSyncMarkSelectedAsDuplicate => 'Seleccionados → duplicados';

  @override
  String get dataSyncMarkSelectedAsUnique => 'Seleccionados → únicos';

  @override
  String get dataSyncMarkAllAsDuplicate => 'Todos → duplicados';

  @override
  String get dataSyncMarkAllAsUnique => 'Todos → únicos';

  @override
  String get dataSyncContinueImport => 'Continuar importación';

  @override
  String get dataSyncIncomingExpense => 'Entrante';

  @override
  String get dataSyncExistingExpense => 'Existente';

  @override
  String get possibleDuplicateTooltip => 'Posible duplicado';

  @override
  String possibleDuplicatesBannerTitle(int count) {
    return 'Posibles duplicados ($count)';
  }

  @override
  String get duplicateReviewSheetTitle => 'Posibles duplicados';

  @override
  String get duplicateMarkNotDuplicate => 'No es un duplicado';

  @override
  String get duplicateConflictDialogTitle => 'Gasto similar encontrado';

  @override
  String get duplicateConflictDialogHint =>
      'Ya existe un gasto con el mismo día, importe y moneda.';

  @override
  String get duplicateSaveAsUnique => 'Guardar como único';

  @override
  String get duplicateDeleteMatchAndSave => 'Eliminar coincidencia y guardar';

  @override
  String get duplicateYourExpense => 'Tu gasto';

  @override
  String get duplicateMatchingExpense => 'Gasto coincidente';

  @override
  String get dashboardRestoreFromBackup => 'Restaurar desde copia';

  @override
  String get selectCountry => 'Seleccionar país';

  @override
  String get addExpense => 'Añadir gasto';

  @override
  String get editExpense => 'Editar gasto';

  @override
  String get amount => 'Importe';

  @override
  String get amountRequired => 'Introduce un importe válido';

  @override
  String get currency => 'Moneda';

  @override
  String get saveAsIs => 'Guardar tal cual';

  @override
  String get convertTo => 'Convertir a';

  @override
  String exchangeRate(String rate) {
    return 'Tipo: $rate';
  }

  @override
  String get rateUnavailable => 'No hay tipo de cambio para este par';

  @override
  String get setRateNow => 'Establecer tipo';

  @override
  String get setManualRateTitle => 'Establecer tipo de cambio';

  @override
  String setManualRateHint(String base, String target) {
    return 'Cuántos $target por 1 $base';
  }

  @override
  String get tag => 'Etiqueta';

  @override
  String get note => 'Nota';

  @override
  String get date => 'Fecha';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Eliminar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get confirmDeleteExpense => '¿Eliminar este gasto?';

  @override
  String get confirmDeleteExpenseDescription =>
      'Este gasto se eliminará permanentemente.';

  @override
  String get expenseDeleted => 'Gasto eliminado';

  @override
  String bulkSelectedCount(int count) {
    return '$count seleccionados';
  }

  @override
  String bulkAndMore(int count) {
    return '…y $count más';
  }

  @override
  String get bulkDeleteTitle => '¿Eliminar gastos?';

  @override
  String bulkDeleteDescription(String list) {
    return 'Estos gastos se eliminarán permanentemente:\n$list';
  }

  @override
  String get bulkChangeTags => 'Cambiar etiquetas';

  @override
  String get bulkChangeTagsTitle => 'Cambiar etiquetas';

  @override
  String bulkChangeTagsDescription(String list) {
    return 'Las nuevas etiquetas reemplazarán las actuales en:\n$list';
  }

  @override
  String get bulkChangeCountry => 'Cambiar país';

  @override
  String get bulkChangeCountryTitle => 'Cambiar país';

  @override
  String bulkChangeCountryDescription(String list) {
    return 'Se actualizará el país de:\n$list';
  }

  @override
  String get bulkChangeCurrency => 'Cambiar moneda';

  @override
  String get bulkChangeCurrencyTitle => 'Cambiar moneda';

  @override
  String bulkChangeCurrencyDescription(String currency, String list) {
    return 'Los importes se convertirán a $currency para:\n$list';
  }

  @override
  String bulkExpensesDeleted(int count) {
    return '$count gastos eliminados';
  }

  @override
  String bulkExpensesUpdated(int count) {
    return '$count gastos actualizados';
  }

  @override
  String get bulkCurrencyRateUnavailable =>
      'No se pudo convertir: tipo de cambio no disponible';

  @override
  String get add => 'Añadir';

  @override
  String get settings => 'Ajustes';

  @override
  String get reportingCurrencies => 'Monedas de informe';

  @override
  String get primaryCurrency => 'Moneda principal';

  @override
  String get apiKey => 'Clave de ExchangeRate-API';

  @override
  String get validateKey => 'Validar y vincular';

  @override
  String get refreshRates => 'Actualizar tipos ahora';

  @override
  String get manualRates => 'Tipos manuales';

  @override
  String get baseCurrency => 'De';

  @override
  String get targetCurrency => 'A';

  @override
  String get rate => 'Tipo';

  @override
  String get tagsTitle => 'Etiquetas';

  @override
  String get suggestedTags => 'Etiquetas sugeridas';

  @override
  String get detectCountry => 'Detectar país de nuevo';

  @override
  String get country => 'País';

  @override
  String get defaultTags => 'Etiquetas predeterminadas';

  @override
  String get dismiss => 'Descartar';

  @override
  String get exportTitle => 'Exportar';

  @override
  String get exportCsv => 'CSV';

  @override
  String get exportJson => 'JSON';

  @override
  String get saveFile => 'Guardar archivo';

  @override
  String get share => 'Compartir';

  @override
  String get copyAs => 'Copiar como';

  @override
  String get copiedToClipboard => 'Copiado al portapapeles';

  @override
  String get sendTelegram => 'Enviar a Telegram';

  @override
  String get telegramBotToken => 'Token del bot de Telegram';

  @override
  String get telegramChatId => 'Id del chat de Telegram';

  @override
  String get telegramEnabled => 'Activar Telegram';

  @override
  String get summaryTotal => 'Total';

  @override
  String get byTag => 'Por etiqueta';

  @override
  String get byPeriod => 'Por periodo';

  @override
  String get displayCurrency => 'Moneda de visualización';

  @override
  String get noExpenses => 'Aún no hay gastos';

  @override
  String get expensesEmptyTitle => 'Aún no hay gastos';

  @override
  String get expensesEmptyBody =>
      'Añade tu primer gasto para ver la lista, el resumen y los gráficos.';

  @override
  String get filterTag => 'Filtro de etiqueta';

  @override
  String get filterCurrency => 'Filtro de moneda';

  @override
  String get all => 'Todo';

  @override
  String get theme => 'Tema';

  @override
  String get locale => 'Idioma';

  @override
  String get moneyFormat => 'Visualización del dinero';

  @override
  String get moneyFormatPreview => 'Vista previa';

  @override
  String get moneyFormatLocaleSymbol => 'Local con símbolo';

  @override
  String get moneyFormatLocaleCode => 'Local con código de moneda';

  @override
  String get moneyFormatPlain => 'Simple (1234.56 CODE)';

  @override
  String get dateFormat => 'Visualización de fecha';

  @override
  String get timeZone => 'Zona horaria';

  @override
  String timeZoneSystem(String id) {
    return 'Sistema ($id)';
  }

  @override
  String get system => 'Sistema';

  @override
  String get light => 'Claro';

  @override
  String get dark => 'Oscuro';

  @override
  String get keyValid => 'La clave API es válida';

  @override
  String get keyInvalid => 'La clave API no es válida';

  @override
  String get ratesRefreshed => 'Tipos actualizados';

  @override
  String get exportDone => 'Exportación lista';

  @override
  String get telegramSent => 'Enviado a Telegram';

  @override
  String get telegramFailed => 'Error al enviar a Telegram';

  @override
  String get telegramSetupNeeded =>
      'Activa Telegram e introduce el token del bot y el id del chat para enviar exportaciones.';

  @override
  String get shareUnsupported =>
      'Compartir archivos no está disponible en esta plataforma.';

  @override
  String get shareFailed => 'No se pudo compartir el archivo de exportación.';

  @override
  String get untagged => 'Sin etiqueta';

  @override
  String get periodDay => 'Día';

  @override
  String get periodWeek => 'Semana';

  @override
  String get periodMonth => 'Mes';

  @override
  String get newTag => 'Nueva etiqueta';

  @override
  String get addTag => 'Añadir etiqueta';

  @override
  String get tagGroceries => 'Comestibles';

  @override
  String get tagTransport => 'Transporte';

  @override
  String get tagHousing => 'Vivienda';

  @override
  String get tagDining => 'Restaurantes';

  @override
  String get tagHealth => 'Salud';

  @override
  String get tagEntertainment => 'Ocio';

  @override
  String get tagShopping => 'Compras';

  @override
  String get tagTravel => 'Viajes';

  @override
  String get tagUtilities => 'Suministros';

  @override
  String get tagCash => 'Efectivo';

  @override
  String get tagCard => 'Tarjeta';

  @override
  String get tagCrypto => 'Cripto';

  @override
  String get tagTransfer => 'Transferencia bancaria';

  @override
  String get tagEwallet => 'Monedero electrónico';

  @override
  String tripTag(String region) {
    return 'Viaje: $region';
  }

  @override
  String get tagColor => 'Color';

  @override
  String get tagColorNone => 'Ninguno';

  @override
  String get chartBy => 'Gráfico por';

  @override
  String get chartByTags => 'Etiquetas';

  @override
  String get chartByTagCountry => 'Etiquetas de país';

  @override
  String get chartByPayment => 'Método de pago';

  @override
  String get chartByTagTrip => 'Etiquetas de viaje';

  @override
  String get chartByTagCustom => 'Etiquetas personalizadas';

  @override
  String get chartTagKindHint =>
      'Cada gasto cuenta una vez dentro de este tipo de etiqueta; las faltantes aparecen como no definidas';

  @override
  String chartMissingRatesAlert(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gastos mostrados sin tipos de cambio',
      one: '1 gasto mostrado sin tipo de cambio',
    );
    return '$_temp0';
  }

  @override
  String get chartHelpTitle => 'Acerca del gráfico';

  @override
  String get chartHelpBody =>
      'El gráfico incluye gastos en todas las monedas. Si falta un tipo de cambio, los importes se muestran en su moneda original. Los totales pueden mezclar monedas hasta que se definan los tipos de cambio.';

  @override
  String get expensesSummaryHelpTitle => 'Acerca del resumen de gastos';

  @override
  String get expensesSummaryHelpBody =>
      'Los totales se agrupan por moneda almacenada. Usa el botón de conversión para mostrar los importes de la lista en una moneda; el total convertido indica cuántos gastos se pudieron convertir.';

  @override
  String get displayCurrencyHelpBody =>
      'Elige una moneda para convertir los importes de la lista. Los importes originales siempre se conservan. Los tipos de cambio faltantes se pueden definir manualmente antes de convertir.';

  @override
  String get chartPaymentHint =>
      'Cada gasto tiene como máximo un método de pago; si falta, aparece como no definido';

  @override
  String get tagKindSectionCountry => 'País';

  @override
  String get tagKindSectionTrip => 'Viaje';

  @override
  String get tagKindSectionCustom => 'Categoría';

  @override
  String get tagKindUnspecifiedCountry => 'País no definido';

  @override
  String get tagKindUnspecifiedTrip => 'Viaje no definido';

  @override
  String get tagKindUnspecifiedCustom => 'Categoría no definida';

  @override
  String get tagKindSingleSelectHint =>
      'Una etiqueta por grupo; los grupos son opcionales';

  @override
  String get paymentMethod => 'Pago';

  @override
  String get paymentMethodNone => 'No definido';

  @override
  String get paymentMethodUnspecified => 'Pago no definido';

  @override
  String get paymentMethodsTitle => 'Métodos de pago';

  @override
  String get paymentMethodsHint =>
      'Elige uno predeterminado para nuevos gastos. Los métodos integrados no se pueden eliminar.';

  @override
  String get paymentMethodNew => 'Nuevo método de pago';

  @override
  String get paymentMethodAdd => 'Añadir método de pago';

  @override
  String get paymentMethodEdit => 'Editar método de pago';

  @override
  String get paymentMethodBuiltIn => 'Integrado';

  @override
  String get paymentMethodClearDefault => 'Quitar pago predeterminado';

  @override
  String get filterPayment => 'Pago';

  @override
  String paymentSelected(int count) {
    return '$count seleccionados';
  }

  @override
  String get chartByMonth => 'Meses';

  @override
  String get chartByCurrency => 'Moneda';

  @override
  String get chartByYear => 'Años';

  @override
  String get filterTags => 'Filtrar etiquetas';

  @override
  String get excludeTag => 'Excluir';

  @override
  String get periodRange => 'Periodo';

  @override
  String get periodAll => 'Todo el tiempo';

  @override
  String get periodFrom => 'Desde';

  @override
  String get periodTo => 'Hasta';

  @override
  String periodFromTo(String from, String to) {
    return '$from — $to';
  }

  @override
  String get periodToday => 'Hoy';

  @override
  String get periodYesterday => 'Ayer';

  @override
  String get periodLast7Days => 'Últimos 7 días';

  @override
  String get periodLast30Days => 'Últimos 30 días';

  @override
  String get periodThisMonth => 'Este mes';

  @override
  String get periodLastMonth => 'Mes pasado';

  @override
  String get periodThisQuarter => 'Este trimestre';

  @override
  String get periodThisYear => 'Este año';

  @override
  String get periodPreviousYear => 'Año anterior';

  @override
  String get periodLast12Months => 'Últimos 12 meses';

  @override
  String get periodCustom => 'Rango personalizado';

  @override
  String get periodCustomHint => 'Elige fechas de inicio y fin';

  @override
  String get periodPickRange => 'Elegir fechas';

  @override
  String get showExpenses => 'Ver gastos';

  @override
  String get sortBy => 'Ordenar por';

  @override
  String get sortDate => 'Fecha';

  @override
  String get sortAmount => 'Importe';

  @override
  String get sortCurrency => 'Moneda';

  @override
  String get groupBy => 'Agrupar por';

  @override
  String get groupNone => 'Ninguno';

  @override
  String get groupDate => 'Fecha';

  @override
  String get groupCurrency => 'Moneda';

  @override
  String get groupTag => 'Etiqueta';

  @override
  String get groupTagCountry => 'País';

  @override
  String get groupPayment => 'Pago';

  @override
  String get groupTagTrip => 'Viaje';

  @override
  String get groupTagCustom => 'Categoría';

  @override
  String get groupTags => 'Etiquetas';

  @override
  String get excludeTags => 'Excluir etiquetas';

  @override
  String get ascending => 'Ascendente';

  @override
  String get descending => 'Descendente';

  @override
  String get viewRates => 'Ver tipos';

  @override
  String get allRates => 'Todos los tipos';

  @override
  String get addRate => 'Añadir tipo';

  @override
  String get noRatesYet =>
      'Aún no hay tipos guardados — actualiza o añade uno manual';

  @override
  String get rateSourceApi => 'ExchangeRate-API';

  @override
  String get rateSourceManual => 'Manual';

  @override
  String get currencyFiat => 'Fiat';

  @override
  String get currencyCrypto => 'Cripto';

  @override
  String get currencyCustom => 'Personalizada';

  @override
  String get addCustomCurrency => 'Añadir moneda';

  @override
  String get currencyCode => 'Código de moneda';

  @override
  String get filtersTitle => 'Filtros';

  @override
  String get expandFilters => 'Mostrar filtros';

  @override
  String get collapseFilters => 'Ocultar filtros';

  @override
  String get applyFilters => 'Aplicar';

  @override
  String get clearFilters => 'Limpiar';

  @override
  String get filtersApplied => 'Filtros aplicados';

  @override
  String get filtersCleared => 'Filtros limpiados';

  @override
  String get selectTags => 'Etiquetas';

  @override
  String tagsSelected(int count) {
    return '$count etiquetas';
  }

  @override
  String get summaryCount => 'Gastos';

  @override
  String get summaryExpenses => 'Gastos';

  @override
  String get summaryCurrencies => 'Monedas';

  @override
  String summaryPerCurrencyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gastos',
      one: '1 gasto',
    );
    return '$_temp0';
  }

  @override
  String summaryConvertedTotal(String currency) {
    return 'Total en $currency';
  }

  @override
  String summaryPartialTotal(int converted, int total) {
    return 'Convertidos $converted de $total';
  }

  @override
  String totalRecords(int count) {
    return 'Total: $count';
  }

  @override
  String get perPage => 'Por página';

  @override
  String get export => 'Exportar';

  @override
  String get listingView => 'Vista';

  @override
  String get viewList => 'Lista';

  @override
  String get viewGrouping => 'Agrupación';

  @override
  String get viewChart => 'Gráfico';

  @override
  String get columnDate => 'Fecha';

  @override
  String get columnGroup => 'Grupo';

  @override
  String get columnCount => 'Cantidad';

  @override
  String get columnAmount => 'Importe';

  @override
  String get columnCurrency => 'Moneda';

  @override
  String get columnTags => 'Etiquetas';

  @override
  String get noMatchingExpenses => 'Ningún gasto coincide con los filtros';

  @override
  String get displayIn => 'Mostrar en';

  @override
  String get displayOriginal => 'Monedas originales';

  @override
  String get displayOriginalHint => 'Mostrar importes guardados sin conversión';

  @override
  String get ratesReady => 'Todos los tipos disponibles';

  @override
  String ratesMissingCount(int count) {
    return 'Faltan $count tipos';
  }

  @override
  String get pickOtherCurrency => 'Otra moneda…';

  @override
  String get missingRatesTitle => 'Conversión no posible';

  @override
  String missingRatesBody(int count, String target) {
    return 'Faltan tipos para $count pares hacia $target. Establécelos para continuar.';
  }

  @override
  String get retryConversion => 'Comprobar de nuevo';

  @override
  String missingRatesStill(int count) {
    return 'Aún faltan $count tipos';
  }

  @override
  String get saveAsIsDescription =>
      'El importe se guarda en la moneda que introdujiste. No se aplica conversión.';

  @override
  String get tagsNoneSelected => 'Ninguna seleccionada';

  @override
  String tagsSelectedCount(int count) {
    return '$count seleccionadas';
  }

  @override
  String get guideTitle => 'Qué puede hacer Valtero';

  @override
  String get guideSubtitle =>
      'Un breve recorrido por las funciones principales. Toca una sección para expandirla.';

  @override
  String get guideOpenFromSettings => 'Guía de la plataforma';

  @override
  String get dashboardSampleChartLabel =>
      'Ejemplo — así se verá tu gráfico cuando añadas gastos';

  @override
  String get dashboardOpenGuide => 'Qué puede hacer la app';

  @override
  String get chartLegendTitle => 'Segmentos';

  @override
  String chartLegendSummary(int visible, int total) {
    return '$visible de $total mostrados';
  }

  @override
  String get guideSampleGroceries => 'Comestibles';

  @override
  String get guideSampleTransport => 'Transporte';

  @override
  String get guideSampleDining => 'Restaurantes';

  @override
  String get guideSampleCountryRu => 'Rusia';

  @override
  String get guideSampleCountryGe => 'Georgia';

  @override
  String get guideSampleCountryTr => 'Turquía';

  @override
  String get guideSectionGettingStartedTitle => 'Primeros pasos';

  @override
  String get guideSectionGettingStartedBody =>
      'Toca el botón + en la parte inferior para abrir el formulario de gasto. Introduce importe y moneda, opcionalmente convierte a una moneda de informe, elige país y categorías, y guarda. Si ya existe un gasto con el mismo día, importe y moneda, puedes guardarlo como único, eliminar la coincidencia o cancelar. Toca un gasto existente para editarlo en el mismo formulario. Hasta entonces, el panel muestra un gráfico de ejemplo con enlace a esta guía.';

  @override
  String get guideSectionExpenseTrackingTitle => 'Seguimiento de gastos';

  @override
  String get guideSectionExpenseTrackingBody =>
      'Cada gasto guarda importe, moneda, fecha, país opcional (ISO), método de pago, etiquetas de categoría y nota. El importe y la moneda originales siempre se conservan, aunque conviertas a una moneda de informe. En la lista de gastos puedes seleccionar varias filas para eliminarlas o cambiar etiquetas, país o moneda a la vez. Los posibles duplicados (mismo día, importe original y moneda) muestran un aviso; abre el banner para eliminar una fila o marcarla como no duplicado.';

  @override
  String get guideSectionTagsTitle => 'Etiquetas';

  @override
  String get guideSectionTagsBody =>
      'Las categorías indican en qué gastaste (comida, transporte…). El país es un campo aparte del gasto, no una etiqueta. El pago también es aparte (efectivo, tarjeta, cripto o el tuyo). Gestiona etiquetas y métodos de pago en Ajustes.';

  @override
  String get guideSectionChartsTitle => 'Gráficos de gasto';

  @override
  String get guideSectionChartsBody =>
      'El gráfico de dona del panel desglosa el gasto por país, método de pago, categoría, meses o moneda. Cambia el desglose con los iconos bajo el gráfico. País, pago o categoría ausentes aparecen como no definidos. Toca un segmento para abrir gastos coincidentes. Toca un chip de la leyenda para mostrar u ocultar esa porción. Bajo el gráfico, los últimos 10 gastos y un enlace a la lista completa. «Ver gastos» ofrece lista, agrupación y gráfico con orden y paginación.';

  @override
  String get guideSectionExchangeRatesTitle => 'Tipos de cambio';

  @override
  String get guideSectionExchangeRatesBody =>
      'Los tipos se actualizan en segundo plano cuando están desactualizados (unas cada 24 horas). Conecta ExchangeRate-API en Ajustes → Integraciones, actualiza manualmente, define anulaciones y consulta todos los tipos en Ajustes → Moneda y tipos de cambio. Sin clave se usa Frankfurter (BCE).';

  @override
  String get guideSectionExportTitle => 'Exportar';

  @override
  String get guideSectionExportBody =>
      'Exporta gastos como CSV o JSON. Guarda un archivo, compártelo o cópialo al portapapeles desde el menú de exportación o Ajustes → Exportar. Telegram aparece como destino solo tras conectarlo en Integraciones.';

  @override
  String get guideSectionDataSyncTitle => 'Copia de seguridad y sincronización';

  @override
  String get guideSectionDataSyncBody =>
      'Crea una copia cifrada de gastos, etiquetas, métodos de pago, tipos manuales y ajustes de visualización. Protégela con tu frase o una generada. Guarda el archivo (en Android/iOS la hoja de compartir permite Guardar en Archivos / Descargas) y envíalo (correo, Telegram como documento, nube, USB). La importación fusiona: se conservan los gastos existentes y se añaden datos nuevos. Si los gastos entrantes se parecen a los que ya tienes (mismo día, importe y moneda), eliges cuáles omitir como duplicados y cuáles importar como únicos. Restaura desde Ajustes → Copia de seguridad y sincronización, o desde el panel vacío. Las claves API y Telegram nunca se incluyen.';

  @override
  String get guideSectionTelegramTitle => 'Compartir por Telegram';

  @override
  String get guideSectionTelegramBody =>
      'Conecta Telegram en Ajustes → Integraciones, introduce el token del bot y el id del chat, prueba la conexión y envía un documento desde el menú de exportación.';

  @override
  String get guideSectionIntegrationsTitle => 'Integraciones';

  @override
  String get guideSectionIntegrationsBody =>
      'Los servicios opcionales (Telegram, Frankfurter, ExchangeRate-API, sincronización con Google Drive) están en Ajustes → Integraciones. Cada uno tiene su formulario. Frankfurter está integrado (tipos BCE, sin clave) y se usa si ExchangeRate-API no está conectado. Google Drive Sync cifra una instantánea en el dispositivo, la guarda en appDataFolder y sincroniza al abrir y tras cambios. El uso compartido entre cuentas usa un archivo aparte y el permiso drive.file. Las funciones dependientes solo aparecen mientras la integración esté conectada.';

  @override
  String get guideSectionDebugTitle => 'Depuración y registros';

  @override
  String get guideSectionDebugBody =>
      'En Ajustes → Depuración y registros puedes activar el registro detallado. Los errores siempre se guardan. Puedes ver, copiar o compartir el archivo con un desarrollador; los secretos se ocultan.';

  @override
  String get guideSectionFiltersTitle => 'Filtros';

  @override
  String get guideSectionFiltersBody =>
      'Filtra por periodo, moneda, etiquetas y pago en el panel y en la página de gastos. Ambos usan una barra resumen compacta que abre los filtros en una hoja a pantalla completa. Aplica o limpia filtros en cualquier momento.';
}
