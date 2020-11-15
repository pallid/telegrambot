#Использовать json
#Использовать logos

Перем ТокенАвторизации Экспорт;
Перем АдресСервиса	Экспорт;
Перем ФорматСообщений Экспорт;

Перем Соединение;
Перем ПарсерJSON;

Перем Лог;

Процедура Инициализировать() 
	
	АдресСервиса = "https://api.telegram.org";
	Соединение = Новый HTTPСоединение(АдресСервиса, 443);
	ПарсерJSON = Новый ПарсерJSON;
	ФорматСообщений = "";
	
	Лог = Логирование.ПолучитьЛог("oscript.lib.telegrambot");
	
КонецПроцедуры

#Область ПрограммныйИнтерфейс

Процедура УстановитьТокенАвторизации(Токен) Экспорт
	ТокенАвторизации = Токен;
КонецПроцедуры

Процедура УстановитьАдресСервиса(Адрес) Экспорт
	АдресСервиса = Адрес;
	Соединение = Новый HTTPСоединение(АдресСервиса, 443);
КонецПроцедуры

Процедура УстановитьФорматСообщений(Формат) Экспорт
	ФорматСообщений = Формат;	
КонецПроцедуры

Функция УстановитьВебхук(Адрес) Экспорт
	
	https = "https://";	
	Если Сред(Адрес, 1, 8) <> https Тогда
		Адрес = https + Адрес;
	КонецЕсли;
	
	Возврат СделатьХук(Адрес);
	
КонецФункции

Функция УбратьВебхук() Экспорт
	
	Возврат СделатьХук("");
	
КонецФункции

Функция ОтправитьДанные(Сообщение, Команда) Экспорт
	
	Ресурс = "/bot{TOKEN}/" + Команда; 
	Запрос = Новый HTTPЗапрос(ЗаменитьТокен(Ресурс));
	Запрос.Заголовки = ПолучитьЗаголовки();
	
	ТекстТелаЗапроса = ПарсерJSON.ЗаписатьJSON(Сообщение);
	КодированнаяСтрока = РаскодироватьСтроку(ТекстТелаЗапроса, СпособКодированияСтроки.КодировкаURL);
	Запрос.УстановитьТелоИзСтроки(КодированнаяСтрока);

	Лог.Отладка(КодированнаяСтрока);

	Попытка
		Ответ = Соединение.ОтправитьДляОбработки(Запрос);
	Исключение
		Лог.Ошибка("Не удалось отправить для обработки" + Ресурс);
		Возврат Неопределено;
	КонецПопытки;
	
	Возврат ПрочитатьОтветЗапроса(Ответ);
	
КонецФункции

Функция Отправить(Сообщение) Экспорт
	
	Команда = "sendMessage";
	Возврат ОтправитьДанные(Сообщение, Команда);
	
КонецФункции

Функция ОтредактироватьСообщение(Сообщение) Экспорт
	
	Команда = "editMessageText";
	Возврат ОтправитьДанные(Сообщение, Команда);
	
КонецФункции

Функция ОтредактироватьКлавиатуру(Сообщение) Экспорт
	
	Команда = "editMessageReplyMarkup";
	Возврат ОтправитьДанные(Сообщение, Команда);
	
КонецФункции

Функция ОправитьОтветНаКоллбекЗапрос(Сообщение) Экспорт
	
	Команда = "answerCallbackQuery";
	Возврат ОтправитьДанные(Сообщение, Команда);
	
КонецФункции

Функция ПереслатьСообщение(Сообщение) Экспорт

	Команда = "forwardMessage";
	Возврат ОтправитьДанные(Сообщение, Команда);

КонецФункции

Функция ОтправитьОпрос(Сообщение) Экспорт

	Команда = "sendPoll";
	Возврат ОтправитьДанные(Сообщение, Команда);

КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ПрочитатьОтветЗапроса(Знач Ответ)
	
	ТелоОтвета = Ответ.ПолучитьТелоКакСтроку();
	Если ТелоОтвета = Неопределено Тогда
		ТелоОтвета = "";
	КонецЕсли;

	Результат = Неопределено;
	Если ЗначениеЗаполнено(ТелоОтвета) Тогда
		Результат = ПарсерJSON.ПрочитатьJSON(ТелоОтвета);
	КонецЕсли;

	Если Результат["ok"] Тогда
		Лог.Отладка("Код состояния: %1", Ответ.КодСостояния);
		Лог.Отладка("Тело ответа: 
			|%1", ТелоОтвета);
	Иначе
		Лог.Ошибка("Код состояния: %1", Ответ.КодСостояния);
		Лог.Ошибка("Описание: %1", Результат["description"]);
	КонецЕсли;

	Возврат Результат;

КонецФункции

Функция ПолучитьЗаголовки()

	Заголовки = Новый Соответствие;
	Заголовки.Вставить("Content-type","application/json");

	Возврат Заголовки;

КонецФункции

Функция СделатьХук(Суффикс)
	
	Команда = "setWebhook";
	Ресурс = "/bot{TOKEN}/" + Команда + "?url=" + Суффикс; 
	Запрос = Новый HTTPЗапрос(ЗаменитьТокен(Ресурс));

	Попытка
		Ответ = Соединение.Получить(Запрос);
	Исключение
		Лог.Ошибка("Не удалось выполнить запрос" + Ресурс);
		Возврат Неопределено;
	КонецПопытки;	
	
	Возврат ПрочитатьОтветЗапроса(Ответ);
	
КонецФункции

Функция ОБоте() Экспорт
	
	Команда = "getMe";

	Возврат ОтправитьДанные(Неопределено, Команда);
	
КонецФункции

Функция ПолучитьОписаниеФайла(file_id) Экспорт
	
	Команда = "getFile";
	Параметры = Новый Структура("file_id", file_id);

	Возврат ОтправитьДанные(Параметры, Команда);
	
КонецФункции

// Передавать или ID, или готовый путь
Функция ПолучитьФайл(file_id="",file_path="") Экспорт
	
	Если НЕ ЗначениеЗаполнено(file_path) Тогда
		ОписаниеФайла = ПолучитьОписаниеФайла(file_id);
		file_path = ОписаниеФайла["result"]["file_path"];
	КонецЕсли;

	// https://api.telegram.org/file/bot<token>/<file_path>
	Ресурс = "/file/bot{TOKEN}/" + file_path;

	Запрос = Новый HTTPЗапрос(ЗаменитьТокен(Ресурс));

	Попытка
		Ответ = Соединение.Получить(Запрос);
	Исключение
		Лог.Ошибка("Не удалось выполнить запрос" + Ресурс);
		Возврат Неопределено;
	КонецПопытки;	
	
	Возврат Ответ.ПолучитьТелоКакДвоичныеДанные();
	
КонецФункции

Функция ЗаменитьТокен(Шаблон)
	Результат = СтрЗаменить(Шаблон, "{TOKEN}", ТокенАвторизации);
	Возврат Результат;
КонецФункции

#КонецОбласти

///////////////////////////////////////////////////////////////////////////////
// ТОЧКА ВХОДА
///////////////////////////////////////////////////////////////////////////////

Инициализировать();