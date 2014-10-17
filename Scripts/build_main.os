﻿///////////////////////////////////////////////////////////////////////
//
// ОСНОВНОЙ СКРИПТ СЦЕНАРИЯ СБОРКИ
// ПРЕДОСТАВЛЯЕТ КОНТЕКСТ НАСТРОЕК ТЕКУЩЕГО СЦЕНАРИЯ СБОРКИ
//
///////////////////////////////////////////////////////////////////////

Перем мМенеджерКластера;
Перем мНастройки;
Перем мВыдаватьСообщенияСборки;

////////////////////////////////////////////////////////////////////
// Программный интерфейс

Функция ПолучитьВерсию() Экспорт
	Возврат "0.1";
КонецФункции

Функция Настройки() Экспорт
	Возврат мНастройки;
КонецФункции

Функция ПолучитьМенеджерКластера() Экспорт

	Если мМенеджерКластера = Неопределено Тогда
		ПодключитьСценарий("Scripts/cluster_manager.os", "МенеджерКластера");
		мМенеджерКластера = Новый МенеджерКластера();
		мМенеджерКластера.Инициализировать(ЭтотОбъект);
	КонецЕсли;

	Возврат мМенеджерКластера;
	
КонецФункции

Процедура СообщениеСборки(Знач Сообщение) Экспорт

	Если мВыдаватьСообщенияСборки Тогда
		Сообщить(Строка(ТекущаяДата()) + " " + Сообщение);
	КонецЕсли;
	
КонецПроцедуры

Функция ЗапуститьИПодождать(Знач Параметры) Экспорт

	СтрокаЗапуска = "";
	СтрокаДляЛога = "";
	Для Каждого Параметр Из Параметры Цикл
	
		СтрокаЗапуска = СтрокаЗапуска + " " + Параметр;
		
		Если Лев(Параметр,2) <> "/P" и Лев(Параметр,25) <> "/ConfigurationRepositoryP" Тогда
			СтрокаДляЛога = СтрокаДляЛога + " " + Параметр;
		КонецЕсли;
	
	КонецЦикла;

	КодВозврата = 0;
	
	Сообщить(мНастройки.ПутьК1С + СтрокаДляЛога);
	
	ЗапуститьПриложение(мНастройки.ПутьК1С + СтрокаЗапуска, , Истина, КодВозврата);
	
	Возврат КодВозврата;

КонецФункции

Функция ВыдаватьСообщенияСборки(Знач Выдавать = Неопределено) Экспорт
	
	ПредыдущееЗначение = мВыдаватьСообщенияСборки;
	
	Если Выдавать <> Неопределено Тогда
		мВыдаватьСообщенияСборки = Выдавать;
	КонецЕсли;
	
	Возврат ПредыдущееЗначение;
	
КонецФункции

////////////////////////////////////////////////////////////////////

Процедура Инициализация()
	
	Если мНастройки = Неопределено Тогда
	
		ПрочитатьНастройки();
		мВыдаватьСообщенияСборки = Истина;
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ПрочитатьНастройки()
	
	мНастройки = Новый Структура;
	СИ = Новый СистемнаяИнформация();
	
	Окружение = СИ.ПеременныеСреды();
	
	// Параметры сервера
	ХостСервера = Окружение["server_host"];
	ПортСервера = 1541;
	Поз = Найти(ХостСервера,":");
	Если Поз = 0 Тогда
		// порта нет, добавим имя с портом по умолчанию
		мНастройки.Вставить("ИмяСервера", ХостСервера + ":" + ПортСервера);
	Иначе
		// порт указан, добавлем в настройки, в том виде, как указано
		мНастройки.Вставить("ИмяСервера", ХостСервера);
		ХостСервера = Лев(ХостСервера, Поз-1);
	КонецЕсли;
	
	ПортАгента = Окружение["agent_port"];
	Если Не ПустаяСтрока(ПортАгента) Тогда
		мНастройки.Вставить("АдресАгентаСервера", ХостСервера + ":" + ПортАгента);
	Иначе
		// добавляем порт агента по умолчанию, если не было указано
		мНастройки.Вставить("АдресАгентаСервера", ХостСервера + ":" + 1540);
	КонецЕсли;
	
	мНастройки.Вставить("АдминистраторКластера", Окружение["cluster_admin"]);
	мНастройки.Вставить("ПарольАдминистратораКластера", Окружение["cluster_admin_password"]);
	мНастройки.Вставить("КлассCOMСоединения", Окружение["com_connector"]);
	
	// Параметры рабочей базы
	мНастройки.Вставить("ИмяБазы", Окружение["db_name"]);
	мНастройки.Вставить("АдминистраторБазы", Окружение["db_user"]);
	мНастройки.Вставить("ПарольАдминистратораБазы", Окружение["db_password"]);
	
	// Параметры хранилища
	мНастройки.Вставить("ПутьКХранилищу", Окружение["storage_connection"]);
	мНастройки.Вставить("ПользовательХранилища", Окружение["storage_user"]);
	мНастройки.Вставить("ПарольХранилища", Окружение["storage_password"]);
	
	// Прочие настройки
	мНастройки.Вставить("ПутьК1С", """" + Окружение["v8_executable"] + """");
	мНастройки.Вставить("СообщениеБлокировки", Окружение["lock_message"]);
	мНастройки.Вставить("ТаймаутБлокировки", Окружение["lock_timeout_sec"]);
	
	Если мНастройки.ТаймаутБлокировки = Неопределено Тогда
		мНастройки.ТаймаутБлокировки = 1000;
	КонецЕсли;
	
КонецПроцедуры


///////////////////////////////////////////////////////////////////
// Точка входа

Инициализация();