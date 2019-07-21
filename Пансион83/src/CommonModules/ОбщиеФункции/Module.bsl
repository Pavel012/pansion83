//-----------------------------------------------------------------------------
// Описание: создает объект внешнего процессора данных
// Параметры: элемент каталога внешнего процессора данных
// Возврат значение: объект процессора данных
//-----------------------------------------------------------------------------
Функция cmGetExternalDataProcessorObject(лВнешняяОбработкаСсылка) Экспорт
	// Retrieve binary data
	vDPBinary = лВнешняяОбработкаСсылка.ExternalProcessingStorage.Get();
	// Save it to the temp file 
	вКлючУникальности = Новый УникальныйИдентификатор();
	vTmpFileName = TempFilesDir() + String(вКлючУникальности);
	vDPBinary.Write(vTmpFileName);
	// Create processor object from the file and delete temp file
	Если лВнешняяОбработкаСсылка.ExternalProcessingType = Перечисления.ExternalProcessingTypes.DataProcessor Тогда
		vDPObj = ExternalDataProcessors.Create(vTmpFileName, Ложь);
		УдалитьФайлы(vTmpFileName);
		Возврат vDPObj;
	ИначеЕсли лВнешняяОбработкаСсылка.ExternalProcessingType = Перечисления.ExternalProcessingTypes.Report Тогда
		vRepObj = ExternalReports.Create(vTmpFileName, Ложь);
		УдалитьФайлы(vTmpFileName);
		Возврат vRepObj;
	КонецЕсли;
	Возврат Неопределено;
КонецФункции //cmGetExternalDataProcessorObject

//-----------------------------------------------------------------------------
// Описание: загружает объект внешнего процессора данных и открывает его форму по умолчанию
// Параметры: элемент каталога внешнего процессора данных, объект параметров, 
// Форма печати объекта, владелец формы обработчика данных
// значение: ИСТИНА если форма обработчика данных была успешно открыта, false если 
// любое исключение
//-----------------------------------------------------------------------------
Функция cmLoadExternalDataProcessor(pExtProc, pObj = Неопределено, pObjPrintingForm = Неопределено, pFormOwner = Неопределено) Экспорт
	Если ЗначениеЗаполнено(pExtProc) Тогда
		vExtProcData = pExtProc.ExternalProcessingStorage.Get();
		vExtProcPath = GetTempFileName(".efd");
		vExtProcData.Write(vExtProcPath);
		vExtProcObj = ExternalDataProcessors.Create(vExtProcPath, Ложь);
		vStruct = Новый Structure("InputParameter, ObjectPrintingForm", pObj, pObjPrintingForm);
		FillPropertyValues(vExtProcObj, vStruct);
		vFrm = vExtProcObj.ПолучитьФорму();
		vFrmStruct = Новый Structure("FormOwner", pFormOwner);
		FillPropertyValues(vFrm, vFrmStruct);
		vFrm.CloseOnOwnerClose = Ложь;
		vFrm.Open();
		УдалитьФайлы(vExtProcPath);
		Возврат Истина;
	КонецЕсли;
	Возврат Ложь;
КонецФункции //cmLoadExternalDataProcessor

//-----------------------------------------------------------------------------
// Description: Loads external spreadsheet template from the object printing form item
// Parameters: Object printing form
// Возврат value: Spreadsheet template 
//-----------------------------------------------------------------------------
Функция cmReadExternalSpreadsheetDocumentTemplate(pObjPrintingForm) Экспорт
	vВнешШаблон = Неопределено;
	Если ЗначениеЗаполнено(pObjPrintingForm) Тогда
		vExtTempData = pObjPrintingForm.ExternalTemplate.Get();
		Если vExtTempData <> Неопределено Тогда
			vВнешШаблон = Новый SpreadsheetDocument();
			vExtTempPath = GetTempFileName(".mxl");
			vExtTempData.Write(vExtTempPath);
			vВнешШаблон.Read(vExtTempPath);
			vВнешШаблон.TemplateLanguageCode = ?(ЗначениеЗаполнено(ПараметрыСеанса.ТекЛокализация), СокрЛП(ПараметрыСеанса.ТекЛокализация.Code), "RU");
			УдалитьФайлы(vExtTempPath);
		КонецЕсли;
	КонецЕсли;
	Возврат vВнешШаблон;
КонецФункции //cmReadExternalSpreadsheetDocumentTemplate

//-----------------------------------------------------------------------------
// Description: Returns localization code being currently used. This function will work if 
//              localization code was entered first in the Languages reference.
// Parameters: None
// Возврат value: String, Localization code for the session current language
//-----------------------------------------------------------------------------
Функция cmLocalizationCode() Экспорт
	vLocalizationCode = "";
	Если ЗначениеЗаполнено(ПараметрыСеанса.ТекЛокализация) Тогда
		Если НЕ ПустаяСтрока(ПараметрыСеанса.ТекЛокализация.LocalizationCode) Тогда
			vLocalizationCode = "L=" + СокрЛП(ПараметрыСеанса.ТекЛокализация.LocalizationCode);
		КонецЕсли;
	КонецЕсли;
	Возврат vLocalizationCode;
КонецФункции //cmLocalizationCode

//-----------------------------------------------------------------------------
// Description: Returns language reference by language code
// Parameters: Language code
// Возврат value: Language
//-----------------------------------------------------------------------------
Функция cmGetLanguageByCode(pLanguageCode) Экспорт
	vLanguage = Справочники.Локализация.RU;
	Если ЗначениеЗаполнено(ПараметрыСеанса.ТекЛокализация) Тогда
		vLanguage = ПараметрыСеанса.ТекЛокализация;
	КонецЕсли;
	Если НЕ ПустаяСтрока(pLanguageCode) Тогда
		vLanguageRef = Справочники.Локализация.FindByCode(СокрЛП(pLanguageCode));
		Если vLanguageRef <> Неопределено Тогда
			vLanguage = vLanguageRef;
		КонецЕсли;
	КонецЕсли;
	Возврат vLanguage;
КонецФункции //cmGetLanguageByCode

//-----------------------------------------------------------------------------
// Description: Returns day of week name or short name based on day of week number
// Parameters: Day of week number, Whether to return short or full day of week name
// Возврат value: String, Day of week name (Monday or Mo, Tuesday or Tu e.t.c.)
//-----------------------------------------------------------------------------
Функция cmGetDayOfWeekName(pDayOfWeek, pShort = Истина) Экспорт
	Если pDayOfWeek = 1 Тогда
		Если pShort Тогда
			Возврат NStr("en='mo';ru='пн';de='Mo'");
		Иначе
			Возврат NStr("en='Monday';ru='Понедельник';de='Montag'");
		КонецЕсли;
	ИначеЕсли pDayOfWeek = 2 Тогда
		Если pShort Тогда
			Возврат NStr("en='tu';ru='вт';de='Di'");
		Иначе
			Возврат NStr("en='Tuesday';ru='Вторник';de='Dienstag'");
		КонецЕсли;
	ИначеЕсли pDayOfWeek = 3 Тогда
		Если pShort Тогда
			Возврат NStr("en='we';ru='ср';de='Mi'");
		Иначе
			Возврат NStr("en='Wednesday';ru='Среда';de='Mittwoch'");
		КонецЕсли;
	ИначеЕсли pDayOfWeek = 4 Тогда
		Если pShort Тогда
			Возврат NStr("en='th';ru='чт';de='Цикл'");
		Иначе
			Возврат NStr("en='Thursday';ru='Четверг';de='Donnerstag'");
		КонецЕсли;
	ИначеЕсли pDayOfWeek = 5 Тогда
		Если pShort Тогда
			Возврат NStr("en='fr';ru='пт';de='Fr'");
		Иначе
			Возврат NStr("en='Friday';ru='Пятница';de='Freitag'");
		КонецЕсли;
	ИначеЕсли pDayOfWeek = 6 Тогда
		Если pShort Тогда
			Возврат NStr("en='sa';ru='сб';de='Sa'");
		Иначе
			Возврат NStr("en='Saturday';ru='Суббота';de='Samstag'");
		КонецЕсли;
	ИначеЕсли pDayOfWeek = 7 Тогда
		Если pShort Тогда
			Возврат NStr("en='su';ru='вс';de='So'");
		Иначе
			Возврат NStr("en='Sunday';ru='Воскресенье';de='Sonntag'");
		КонецЕсли;
	КонецЕсли;
КонецФункции //cmGetDayOfWeekName

//-----------------------------------------------------------------------------
// Description: Returns month name or short month name based on month number
// Parameters: Month number, Whether to return short or full month name
// Возврат value: String, Month name (December or Dec, February or Feb e.t.c.)
//-----------------------------------------------------------------------------
Функция cmGetMonthName(pMonthNumber, pShort = Ложь) Экспорт
	Если pMonthNumber = 1 Тогда
		Если pShort Тогда
			Возврат NStr("en='Jan';ru='Янв';de='Jan'");
		Иначе
			Возврат NStr("en='January';ru='Январь';de='Januar'");
		КонецЕсли;
	ИначеЕсли pMonthNumber = 2 Тогда
		Если pShort Тогда
			Возврат NStr("en='Feb';ru='Фев';de='Feb'");
		Иначе
			Возврат NStr("en='February';ru='Февраль';de='Februar'");
		КонецЕсли;
	ИначеЕсли pMonthNumber = 3 Тогда
		Если pShort Тогда
			Возврат NStr("en='Mar';ru='Мар';de='Mär'");
		Иначе
			Возврат NStr("en='March';ru='Март';de='März'");
		КонецЕсли;
	ИначеЕсли pMonthNumber = 4 Тогда
		Если pShort Тогда
			Возврат NStr("en='Apr';ru='Апр';de='Apr'");
		Иначе
			Возврат NStr("en='April';ru='Апрель';de='April'");
		КонецЕсли;
	ИначеЕсли pMonthNumber = 5 Тогда
		Если pShort Тогда
			Возврат NStr("en='May';ru='Май';de='Mai'");
		Иначе
			Возврат NStr("en='May';ru='Май';de='Mai'");
		КонецЕсли;
	ИначеЕсли pMonthNumber = 6 Тогда
		Если pShort Тогда
			Возврат NStr("en='Jun';ru='Июн';de='Jun'");
		Иначе
			Возврат NStr("en='June';ru='Июнь';de='Juni'");
		КонецЕсли;
	ИначеЕсли pMonthNumber = 7 Тогда
		Если pShort Тогда
			Возврат NStr("en='Jul';ru='Июл';de='Jul'");
		Иначе
			Возврат NStr("en='July';ru='Июль';de='Juli'");
		КонецЕсли;
	ИначеЕсли pMonthNumber = 8 Тогда
		Если pShort Тогда
			Возврат NStr("en='Aug';ru='Авг';de='Aug'");
		Иначе
			Возврат NStr("en='August';ru='Август';de='August'");
		КонецЕсли;
	ИначеЕсли pMonthNumber = 9 Тогда
		Если pShort Тогда
			Возврат NStr("en='Sep';ru='Сен';de='Sep'");
		Иначе
			Возврат NStr("en='September';ru='Сентябрь';de='September'");
		КонецЕсли;
	ИначеЕсли pMonthNumber = 10 Тогда
		Если pShort Тогда
			Возврат NStr("en='Oct';ru='Окт';de='Okt'");
		Иначе
			Возврат NStr("en='October';ru='Октябрь';de='Oktober'");
		КонецЕсли;
	ИначеЕсли pMonthNumber = 11 Тогда
		Если pShort Тогда
			Возврат NStr("en='Nov';ru='Ноя';de='Nov'");
		Иначе
			Возврат NStr("en='November';ru='Ноябрь';de='November'");
		КонецЕсли;
	ИначеЕсли pMonthNumber = 12 Тогда
		Если pShort Тогда
			Возврат NStr("en='Dec';ru='Дек';de='Dez'");
		Иначе
			Возврат NStr("en='December';ru='Декабрь';de='Dezember'");
		КонецЕсли;
	КонецЕсли;
КонецФункции //cmGetMonthName

//-----------------------------------------------------------------------------
// Description: Returns indent, i.e. one or several Tab chars based on catalog 
//              object group level. Если catalog object level is 1 then one Tab char 
//              is returned. Если catalog object level is 2 then two joined Tab chars 
//              are returned.
// Parameters: Catalog object, Initial number of Tab chars to use
// Возврат value: String, Joined Tab chars
//-----------------------------------------------------------------------------
Функция cmGetIndent(pObj, pInitialIndent = 0) Экспорт
	vLevel = pInitialIndent;
	Если ЗначениеЗаполнено(pObj) Тогда
		vLevel = vLevel + pObj.Level();
	КонецЕсли;
	vIndent = "";
	i = 0;
	Пока i < vLevel Цикл
		vIndent = vIndent + "  ";
		i = i + 1;
	КонецЦикла;
	Возврат vIndent;
КонецФункции //cmGetIndent

//-----------------------------------------------------------------------------
// Description: Returns string from current time and document reference presentation
// Parameters: Any document ref
// Возврат value: String
//-----------------------------------------------------------------------------
Функция cmGetMessageHeader(pDoc) Экспорт
	Возврат Формат(CurrentDate(), "DF='dd.MM.yyyy HH:mm:ss'") + 
	       ?(ЗначениеЗаполнено(pDoc), " " + String(pDoc), "") + " - ";
КонецФункции //cmGetMessageHeader

//-----------------------------------------------------------------------------
// Description: Adds time to the date 
// Parameters: Begin of date, Time, Whether to add additional 1 second or not
// Возврат value: Date with time
//-----------------------------------------------------------------------------
Функция cmAddTime(pDate, pTime, pIsCheckIn) Экспорт
	Если pIsCheckIn Тогда
		Возврат BegOfDay(pDate) + Hour(pTime)*3600 + Minute(pTime)*60 + 1;
	Иначе
		Возврат BegOfDay(pDate) + Hour(pTime)*3600 + Minute(pTime)*60;
	КонецЕсли;
КонецФункции //cmAddTime

//-----------------------------------------------------------------------------
// Description: Extracts time from the date with time
// Parameters: Date with time
// Возврат value: Time part of the date
//-----------------------------------------------------------------------------
Функция cmExtractTime(pDateTime) Экспорт
	vTime = Date(1, 1, 1, Hour(pDateTime), Minute(pDateTime), 0);
	Возврат vTime;
КонецФункции //cmExtractTime

//-----------------------------------------------------------------------------
// Description: Adds specified number of working days to the input date
// Parameters: Starting date, number of working days to add
// Возврат value: Date
//-----------------------------------------------------------------------------
Функция cmAddWorkingDays(pDate, pNumDays) Экспорт
	vDate = pDate;
	Для i = 1 По pNumDays Цикл
		vDate = vDate + 24*3600;
		Пока WeekDay(vDate) > 5 Цикл
			vDate = vDate + 24*3600;
		КонецЦикла;
	КонецЦикла;
	Возврат vDate;
КонецФункции //cmAddWorkingDays

//-----------------------------------------------------------------------------
// Description: Sets seconds part of time to one second
// Parameters: Date with time
// Возврат value: Date with time
//-----------------------------------------------------------------------------
Функция cm1SecondShift(pDateTime) Экспорт
	Возврат Date(Year(pDateTime), Month(pDateTime), Day(pDateTime), Hour(pDateTime), Minute(pDateTime), 1);
КонецФункции //cm1SecondShift

//-----------------------------------------------------------------------------
// Description: Sets seconds part of time to 0 second
// Parameters: Date with time
// Возврат value: Date with time
//-----------------------------------------------------------------------------
Функция cm0SecondShift(pDateTime) Экспорт
	Возврат Date(Year(pDateTime), Month(pDateTime), Day(pDateTime), Hour(pDateTime), Minute(pDateTime), 0);
КонецФункции //cm0SecondShift

//-----------------------------------------------------------------------------
// Description: Returns date & time from the timestamp string
// Parameters: Timestamp string like YYYY-MM-DDTHH:MM:SS.SSS
// Возврат value: Date with time
//-----------------------------------------------------------------------------
Функция cmGetDateFromTimestampPresentation(pTimestamp) Экспорт
	Попытка
		vDateTime = Date(Число(Лев(pTimestamp, 4)), Число(Сред(pTimestamp, 6, 2)), Число(Сред(pTimestamp, 9, 2)), Число(Сред(pTimestamp, 12, 2)), Число(Сред(pTimestamp, 15, 2)), Число(Сред(pTimestamp, 18, 2)));
	Исключение
		vDateTime = '00010101';
	КонецПопытки;
	Возврат vDateTime;
КонецФункции //cmGetDateFromTimestampPresentation

//-----------------------------------------------------------------------------
// Description: Returns date from the date string
// Parameters: Date string like YYYY-MM-DD
// Возврат value: Date
//-----------------------------------------------------------------------------
Функция cmGetDateFromDatePresentation(pTimestamp) Экспорт
	Попытка
		vDate = Date(Число(Лев(pTimestamp, 4)), Число(Сред(pTimestamp, 6, 2)), Число(Сред(pTimestamp, 9, 2)), 0, 0, 0);
	Исключение
		vDate = '00010101';
	КонецПопытки;
	Возврат vDate;
КонецФункции //cmGetDateFromDatePresentation

//-----------------------------------------------------------------------------
// Description: Returns text representation of the amount
// Parameters: Amount, Currency, Zero amount presentation, Target language, Wether to add currency char or not
// Возврат value: String, f.e. "$10 000,00" or "10 000,00 USD"
//-----------------------------------------------------------------------------
Функция cmFormatSum(pSum, pCurrency, pZeroPresentation = "", pLang = Неопределено, pNoCurrency = Ложь) Экспорт
	vFmtStr = "";
	Если ПустаяСтрока(pZeroPresentation) Тогда
		vFmtStr = "ND=17; NFD=2; NDS=; NGS=; NN=1";
	Иначе
		vFmtStr = "ND=17; NFD=2; NDS=; NGS=; " + pZeroPresentation + "; NN=1";
	КонецЕсли;
	vStr = Формат(pSum, vFmtStr);
	Если НЕ pNoCurrency And НЕ ПустаяСтрока(vStr) Тогда
		Если ЗначениеЗаполнено(pCurrency) Тогда
			vCurPres = cmGetCurrencyPresentation(pCurrency, pLang);
			Если СтрДлина(vCurPres) > 1 Тогда
				vStr = vStr + " " + vCurPres;
			Иначе
				Если pCurrency.PlaceSymbolBeforeSum Тогда
					vStr = vCurPres + vStr;
				Иначе
					vStr = vStr + vCurPres;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	Возврат vStr;
КонецФункции //cmFormatSum

//-----------------------------------------------------------------------------
// Description: Returns decimal hours quantity as XX hours YY minutes string
// Parameters: Decimal duration in hours, Whether to return empty string if duration is zero or not
// Возврат value: String, f.e. "3h30m" for the 3.5 duration
//-----------------------------------------------------------------------------
Функция cmFormatDurationInHours(pDuration, pFormatZero = Ложь) Экспорт
	vStr = "";
	Если pDuration <> 0 Тогда
		vH = Цел(pDuration);
		vM = Round((pDuration - vH)*60, 0);
		vStr = ?(vH = 0, "", Формат(vH, "ND=9; NFD=0; NZ=") + NStr("en='h';ru='ч';de='St.'")) + 
		       ?(vM = 0, "", ?(vH = 0, "", " ") + Формат(vM, "ND=9; NFD=0; NZ=") + NStr("en='m';ru='м';de='m'"));
	Иначе
		Если pFormatZero Тогда
			vStr = "0" + NStr("en='h';ru='ч';de='St.'");
		КонецЕсли;
	КонецЕсли;
	Возврат vStr;
КонецФункции //cmFormatDurationInHours

//-----------------------------------------------------------------------------
// Description: Преобразует строку в действительное 1С язык программирования переменной имя
// Parameters: Name to check and convert
// Возврат value: String
//-----------------------------------------------------------------------------
Функция cmGetValidName(Val pStr) Экспорт
	pStr = СокрЛП(pStr);
	pStr = СтрЗаменить(pStr, " ", "");
	pStr = СтрЗаменить(pStr, ".", "");
	pStr = СтрЗаменить(pStr, ",", "");
	pStr = СтрЗаменить(pStr, "-", "");
	pStr = СтрЗаменить(pStr, "=", "");
	pStr = СтрЗаменить(pStr, "*", "");
	pStr = СтрЗаменить(pStr, "+", "");
	pStr = СтрЗаменить(pStr, "(", "");
	pStr = СтрЗаменить(pStr, ")", "");
	pStr = СтрЗаменить(pStr, "&", "");
	pStr = СтрЗаменить(pStr, "?", "");
	pStr = СтрЗаменить(pStr, "&", "");
	pStr = СтрЗаменить(pStr, "^", "");
	pStr = СтрЗаменить(pStr, "%", "");
	pStr = СтрЗаменить(pStr, "$", "");
	pStr = СтрЗаменить(pStr, "#", "");
	pStr = СтрЗаменить(pStr, "№", "");
	pStr = СтрЗаменить(pStr, "@", "");
	pStr = СтрЗаменить(pStr, "!", "");
	pStr = СтрЗаменить(pStr, "~", "");
	pStr = СтрЗаменить(pStr, "<", "");
	pStr = СтрЗаменить(pStr, ">", "");
	pStr = СтрЗаменить(pStr, "/", "");
	pStr = СтрЗаменить(pStr, "|", "");
	pStr = СтрЗаменить(pStr, "\", "");
	pStr = СтрЗаменить(pStr, "[", "");
	pStr = СтрЗаменить(pStr, "]", "");
	pStr = СтрЗаменить(pStr, "{", "");
	pStr = СтрЗаменить(pStr, "}", "");
	pStr = СтрЗаменить(pStr, ";", "");
	pStr = СтрЗаменить(pStr, ":", "");
	pStr = СтрЗаменить(pStr, "'", "");
	pStr = СтрЗаменить(pStr, """", "");
	pStr = "N" + pStr; // Цикл not allow first digit
	Возврат pStr;
КонецФункции //cmGetValidName

//-----------------------------------------------------------------------------
// Description: Сheck the validity of E-Mail
// Parameters: E-Mail
// Возврат value: Boolean
//-----------------------------------------------------------------------------
Функция cmCheckEMailIsValid(pEMail) Экспорт
	Если НЕ ЗначениеЗаполнено(pEMail) ИЛИ СтрДлина(pEMail) < 6 Тогда
		Возврат Ложь;
	КонецЕсли;
	vAPos = Find(pEMail, "@");
	Если vAPos < 2 Тогда
		Возврат Ложь;
	КонецЕсли;
	vDotPos = СтрДлина(pEMail);
	Пока Сред(pEMail, vDotPos, 1)  <> "." And vDotPos > 0 Цикл
		vDotPos = vDotPos - 1;
	КонецЦикла;
	vStrLen = СтрДлина(pEMail);
	Если (vStrLen - 1) <= vDotPos ИЛИ vDotPos = 0 Тогда
		Возврат Ложь;
	КонецЕсли;
	Если (vDotPos - 1) <= vAPos Тогда
		Возврат Ложь;
	КонецЕсли;
	Возврат Истина;
КонецФункции //cmCheckEMailIsValid

//------------------------------------------------------------------------------
// Description: Converts string to the valid file name
// Parameters: Name to check and convert
// Возврат value: String
//-----------------------------------------------------------------------------
Функция cmGetValidFileName(pFileName) Экспорт
	vValidFileName = СокрЛП(pFileName);
	vValidFileName = СтрЗаменить(vValidFileName, "/", "");
	vValidFileName = СтрЗаменить(vValidFileName, "|", "");
	vValidFileName = СтрЗаменить(vValidFileName, "\", "");
	vValidFileName = СтрЗаменить(vValidFileName, "<", "");
	vValidFileName = СтрЗаменить(vValidFileName, ">", "");
	vValidFileName = СтрЗаменить(vValidFileName, ":", "");
	vValidFileName = СтрЗаменить(vValidFileName, "*", "");
	vValidFileName = СтрЗаменить(vValidFileName, "?", "");
	vValidFileName = СтрЗаменить(vValidFileName, """", "");
	Возврат vValidFileName;
КонецФункции //cmGetValidFileName

//------------------------------------------------------------------------------
// Description:Заменяет строки символов на другие
// Parameters: Source chars sequence, String where to replace, Target chars sequence
// Возврат value: String
//-----------------------------------------------------------------------------
Функция cmCharRepl(pSourceChars, pStr, pTargetChars) Экспорт
	vRes = pStr;
	Для i = 1 По СтрДлина(pSourceChars) Цикл
		vRes = СтрЗаменить(vRes, Сред(pSourceChars, i, 1), Сред(pTargetChars, i, 1));
	КонецЦикла;
	Возврат vRes;
КонецФункции //cmCharRepl

//-----------------------------------------------------------------------------
// Description: Adds int quantity to the document number presentation
// Parameters: Source document number, Quantity to add
// Возврат value: Новый document number
//-----------------------------------------------------------------------------
Функция cmAddToNumberWithPrefix(pNumber, pQuantity) Экспорт
	vRetNumber = "";
	vNumber = СокрЛП(pNumber);
	Попытка
		Если pQuantity > 0 Тогда
			Если НЕ ПустаяСтрока(vNumber) Тогда
				// Check prefix Должность (left chars or right)
				vNoPrefix = Ложь;
				vLeftPrefix = Ложь;
				vRightPrefix = Ложь;
				vChar = Лев(vNumber, 1);
				Если vChar >= "0" And vChar <= "9" Тогда
					vChar = Прав(vNumber, 1);
					Если vChar >= "0" And vChar <= "9" Тогда
						vNoPrefix = Истина;
					Иначе
						vRightPrefix = Истина;
					КонецЕсли;
				Иначе
					vLeftPrefix = Истина;
				КонецЕсли;
				Если vNoPrefix Тогда
					vNumberOfDigits = СтрДлина(vNumber);
					vRetNumber = Формат(Число(vNumber) + pQuantity - 1, "ND=" + String(vNumberOfDigits) + "; NFD=0; NZ=; NLZ=; NG=");
				ИначеЕсли vLeftPrefix Тогда
					vPrefix = "";
					Для i = 1 По СтрДлина(vNumber) Цикл
						vChar = Сред(vNumber, i, 1);
						Если vChar >= "0" And vChar <= "9" Тогда
							Прервать;
						Иначе
							vPrefix = vPrefix + vChar;
						КонецЕсли;
					КонецЦикла;
					vNumberOfDigits = СтрДлина(vNumber);
					vPrefixLen = СтрДлина(vPrefix);
					Если vPrefixLen < vNumberOfDigits Тогда
						Если НЕ ПустаяСтрока(vPrefix) Тогда
							vNumberOfDigits = vNumberOfDigits - vPrefixLen;
							vNumber = Сред(vNumber, vPrefixLen + 1);
						КонецЕсли;
						vRetNumber = vPrefix + Формат(Число(vNumber) + pQuantity - 1, "ND=" + String(vNumberOfDigits) + "; NFD=0; NZ=; NLZ=; NG=");
					КонецЕсли;
				ИначеЕсли vRightPrefix Тогда
					vPrefix = "";
					vNumberOfDigits = СтрДлина(vNumber);
					i = vNumberOfDigits;
					Пока i > 0 Цикл
						vChar = Сред(vNumber, i, 1);
						Если vChar >= "0" And vChar <= "9" Тогда
							Прервать;
						Иначе
							vPrefix = vChar + vPrefix;
						КонецЕсли;
						i = i - 1;
					КонецЦикла;
					vPrefixLen = СтрДлина(vPrefix);
					Если vPrefixLen < vNumberOfDigits Тогда
						Если НЕ ПустаяСтрока(vPrefix) Тогда
							vNumberOfDigits = vNumberOfDigits - vPrefixLen;
							vNumber = Лев(vNumber, vNumberOfDigits);
						КонецЕсли;
						vRetNumber = Формат(Число(vNumber) + pQuantity - 1, "ND=" + String(vNumberOfDigits) + "; NFD=0; NZ=; NLZ=; NG=") + vPrefix;
					КонецЕсли;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
	Исключение
	КонецПопытки;
	Возврат vRetNumber;
КонецФункции //cmAddToNumberWithPrefix 

//-----------------------------------------------------------------------------
// Description: Subtracts int quantity from the document number presentation
// Parameters: Source document number, Quantity to subtract
// Возврат value: Новый document number
//-----------------------------------------------------------------------------
Функция cmSubtractNumbersWithPrefix(pNumberTo, pNumberFrom) Экспорт
	vQty = 0;
	Попытка
		vNumberTo = СокрЛП(pNumberTo);
		vNumberFrom = СокрЛП(pNumberFrom);
		Если ПустаяСтрока(vNumberTo) ИЛИ ПустаяСтрока(vNumberFrom) Тогда
			Возврат vQty;
		КонецЕсли;
		// Check prefix Должность (left chars or right)
		vNoPrefix = Ложь;
		vLeftPrefix = Ложь;
		vRightPrefix = Ложь;
		vChar = Лев(vNumberFrom, 1);
		Если vChar >= "0" And vChar <= "9" Тогда
			vChar = Прав(vNumberFrom, 1);
			Если vChar >= "0" And vChar <= "9" Тогда
				vNoPrefix = Истина;
			Иначе
				vRightPrefix = Истина;
			КонецЕсли;
		Иначе
			vLeftPrefix = Истина;
		КонецЕсли;
		vQtyFrom = 0;
		vQtyTo = 0;
		Если vNoPrefix Тогда
			vQtyTo = Число(vNumberTo);
			vQtyFrom = Число(vNumberFrom);
		ИначеЕсли vLeftPrefix Тогда
			vPrefixTo = "";
			Для i = 1 По СтрДлина(vNumberTo) Цикл
				vChar = Сред(vNumberTo, i, 1);
				Если vChar >= "0" And vChar <= "9" Тогда
					Прервать;
				Иначе
					vPrefixTo = vPrefixTo + vChar;
				КонецЕсли;
			КонецЦикла;
			vPrefixToLen = СтрДлина(vPrefixTo);
			vNumberToLen = СтрДлина(vNumberTo);
			Если vPrefixToLen < vNumberToLen Тогда
				vQtyTo = Число(Сред(vNumberTo, vPrefixToLen + 1));
			КонецЕсли;
			vPrefixFrom = "";
			Для i = 1 По СтрДлина(vNumberFrom) Цикл
				vChar = Сред(vNumberFrom, i, 1);
				Если vChar >= "0" And vChar <= "9" Тогда
					Прервать;
				Иначе
					vPrefixFrom = vPrefixFrom + vChar;
				КонецЕсли;
			КонецЦикла;
			vPrefixFromLen = СтрДлина(vPrefixFrom);
			vNumberFromLen = СтрДлина(vNumberFrom);
			Если vPrefixFromLen < vNumberFromLen Тогда
				vQtyFrom = Число(Сред(vNumberFrom, vPrefixFromLen + 1));
			КонецЕсли;
			Если vPrefixFrom <> vPrefixTo Тогда
				vQtyTo = 0;
				vQtyFrom = 1;
			КонецЕсли;
		ИначеЕсли vRightPrefix Тогда
			vPrefixTo = "";
			vNumberToLen = СтрДлина(vNumberTo);
			i = vNumberToLen;
			Пока i > 0 Цикл
				vChar = Сред(vNumberTo, i, 1);
				Если vChar >= "0" And vChar <= "9" Тогда
					Прервать;
				Иначе
					vPrefixTo = vChar + vPrefixTo;
				КонецЕсли;
				i = i - 1;
			КонецЦикла;
			vPrefixToLen = СтрДлина(vPrefixTo);
			Если vPrefixToLen < vNumberToLen Тогда
				vQtyTo = Число(Лев(vNumberTo, vNumberToLen - vPrefixToLen));
			КонецЕсли;
			vPrefixFrom = "";
			vNumberFromLen = СтрДлина(vNumberFrom);
			i = vNumberFromLen;
			Пока i > 0 Цикл
				vChar = Сред(vNumberFrom, i, 1);
				Если vChar >= "0" And vChar <= "9" Тогда
					Прервать;
				Иначе
					vPrefixFrom = vChar + vPrefixFrom;
				КонецЕсли;
				i = i - 1;
			КонецЦикла;
			vPrefixFromLen = СтрДлина(vPrefixFrom);
			Если vPrefixFromLen < vNumberFromLen Тогда
				vQtyFrom = Число(Лев(vNumberFrom, vNumberFromLen - vPrefixFromLen));
			КонецЕсли;
			Если vPrefixFrom <> vPrefixTo Тогда
				vQtyTo = 0;
				vQtyFrom = 1;
			КонецЕсли;
		КонецЕсли;
		vQty = vQtyTo - vQtyFrom + 1;
		Если vQty < 0 Тогда
			vQty = 0;
		КонецЕсли;
	Исключение
		vQty = 0;
	КонецПопытки;
	Возврат vQty;
КонецФункции //cmSubtractNumbersWithPrefix

//-----------------------------------------------------------------------------
// Description: Applies default print settings to the report or other print form
// Parameters: Spreadsheet with form, Page orientation to set, Fit to page default value, Число of copies, Black and white default setting
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmSetDefaultPrintFormSettings(pSpreadsheet, pPageOrientation, pDefaultFitToPage = Истина, pCopies = 0, pBlackAndWhite = Неопределено) Экспорт
	pSpreadsheet.FitToPage = pDefaultFitToPage;
	pSpreadsheet.ReadOnly = Истина;
	pSpreadsheet.ShowHeaders = Ложь;
	pSpreadsheet.ShowGrid = Ложь;
	pSpreadsheet.PageOrientation = pPageOrientation;
	Если pCopies <> 0 Тогда
		pSpreadsheet.Copies = pCopies;
	КонецЕсли;
	Если pBlackAndWhite <> Неопределено Тогда
		pSpreadsheet.BlackAndWhite = pBlackAndWhite;
	КонецЕсли;
КонецПроцедуры //cmSetDefaultPrintFormSettings

//-----------------------------------------------------------------------------
// Description: Applies print settings to the report or other print form
// Parameters: Spreadsheet with form, Structure with print form settings
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmSetSpreadsheetSettings(pSpreadsheet, pPrintSettings) Экспорт
	pSpreadsheet.PrinterName = pPrintSettings.PrinterName;
	pSpreadsheet.FitToPage = pPrintSettings.FitToPage;
	pSpreadsheet.PrintScale = pPrintSettings.PrintScale;
	pSpreadsheet.Copies = pPrintSettings.Copies;
	Если pPrintSettings.CopiesPerPage = Перечисления.CopiesPerPage.Auto Тогда
		pSpreadsheet.PerPage = 0;
	ИначеЕсли pPrintSettings.CopiesPerPage = Перечисления.CopiesPerPage.One Тогда
		pSpreadsheet.PerPage = 1;
	ИначеЕсли pPrintSettings.CopiesPerPage = Перечисления.CopiesPerPage.Two Тогда
		pSpreadsheet.PerPage = 2;
	КонецЕсли;
	pSpreadsheet.Collate = pPrintSettings.Collate;
	Если pPrintSettings.PageOrientation = Перечисления.PageOrientations.Portrait Тогда
		pSpreadsheet.PageOrientation = PageOrientation.Portrait;
	ИначеЕсли pPrintSettings.PageOrientation = Перечисления.PageOrientations.Landscape Тогда
		pSpreadsheet.PageOrientation = PageOrientation.Landscape;
	КонецЕсли;
	Если НЕ ПустаяСтрока(pPrintSettings.PageSize) Тогда
		pSpreadsheet.PageSize = pPrintSettings.PageSize;
	КонецЕсли;
	pSpreadsheet.BlackAndWhite = pPrintSettings.BlackAndWhite;
	pSpreadsheet.TopMargin = pPrintSettings.TopMargin;
	pSpreadsheet.BottomMargin = pPrintSettings.BottomMargin;
	pSpreadsheet.LeftMargin = pPrintSettings.LeftMargin;
	pSpreadsheet.RightMargin = pPrintSettings.RightMargin;
	pSpreadsheet.HeaderSize = pPrintSettings.HeaderSize;
	pSpreadsheet.FooterSize = pPrintSettings.FooterSize;
КонецПроцедуры //cmSetSpreadsheetSettings

//-----------------------------------------------------------------------------
// Description: Builds report form save to file default name based on print form settings
// Parameters: Structure with print form settings, Default file name
// Возврат value: String, Print form save to file name
//-----------------------------------------------------------------------------
Функция cmGetPrintFormFileName(pPrintSettings, pFileName = "") Экспорт
	vFileName = pFileName;
	Если pPrintSettings <> Неопределено Тогда
		vFileName = ?(ПустаяСтрока(pPrintSettings.FileName), pFileName, pPrintSettings.FileName);
		Если pPrintSettings.AddTimeToTheFileName Тогда
			vFileName = vFileName + " " + Формат(CurrentDate(), "DF='yyyy-MM-dd HHmm'");
		КонецЕсли;
	КонецЕсли;
	Возврат vFileName;
КонецФункции //cmGetPrintFormFileName
	
//-----------------------------------------------------------------------------
// Description: Receives and performs output of form according to the print form settings
//              Output could be done to the screen, printer or to the file in different formats.
//              Send form by E-Mail is also supported
// Parameters: Print form, Structure with print form settings, Default file name, Language
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmDoSpreadsheetOutput(pSpreadsheet, pPrintSettings, pFileName, pLanguage = Неопределено) Экспорт
	vLanguage = pLanguage;
	Если НЕ ЗначениеЗаполнено(vLanguage) Тогда
		vLanguage = ПараметрыСеанса.ТекЛокализация;
	КонецЕсли;
	Если pPrintSettings <> Неопределено Тогда
		Если pPrintSettings.PrintDirection = Перечисления.PrintDirections.Printer Тогда
			Если ПустаяСтрока(pSpreadsheet.PrinterName) Тогда
				pSpreadsheet.Print(Ложь);
			Иначе
				pSpreadsheet.Print(Истина);
			КонецЕсли;
		Иначе
			// Get file and save catalog names
			vFileName = "";
			Если ПустаяСтрока(pFileName) Тогда
				Если ЗначениеЗаполнено(pPrintSettings.Report) Тогда
					vFileName = pPrintSettings.Report;
				ИначеЕсли ЗначениеЗаполнено(pPrintSettings.ObjectPrintingForm) Тогда
					vFileName = pPrintSettings.ObjectPrintingForm;
				Иначе
					vUUID = Новый UUID();
					vFileName = String(vUUID);
				КонецЕсли;
			Иначе
				vFileName = СокрЛП(pFileName);
			КонецЕсли;
			vFileSaveCatalog = "";
			Если ПустаяСтрока(pPrintSettings.FileSaveCatalog) Тогда
				vFileSaveCatalog = TempFilesDir();
			Иначе
				vFileSaveCatalog = СокрЛП(pPrintSettings.FileSaveCatalog);
			КонецЕсли;
			// Get full file name and save file
			vFullFileName = "";
			Если pPrintSettings.PrintDirection = Перечисления.PrintDirections.MXL Тогда
				vFileName = vFileName + ".mxl";
				vFullFileName = cmGetFullFileName(vFileName, vFileSaveCatalog);
				pSpreadsheet.Write(vFullFileName, SpreadsheetDocumentFileType.MXL);
			ИначеЕсли pPrintSettings.PrintDirection = Перечисления.PrintDirections.XLS Тогда
				vFileName = vFileName + ".xls";
				vFullFileName = cmGetFullFileName(vFileName, vFileSaveCatalog);
				pSpreadsheet.Write(vFullFileName, SpreadsheetDocumentFileType.XLS);
			ИначеЕсли pPrintSettings.PrintDirection = Перечисления.PrintDirections.XLSX Тогда
				vFileName = vFileName + ".xlsx";
				vFullFileName = cmGetFullFileName(vFileName, vFileSaveCatalog);
				pSpreadsheet.Write(vFullFileName, SpreadsheetDocumentFileType.XLSX);
			ИначеЕсли pPrintSettings.PrintDirection = Перечисления.PrintDirections.HTML Тогда
				vFileName = vFileName + ".html";
				vFullFileName = cmGetFullFileName(vFileName, vFileSaveCatalog);
				pSpreadsheet.Write(vFullFileName, SpreadsheetDocumentFileType.HTML);
			ИначеЕсли pPrintSettings.PrintDirection = Перечисления.PrintDirections.TXT Тогда
				vFileName = vFileName + ".txt";
				vFullFileName = cmGetFullFileName(vFileName, vFileSaveCatalog);
				pSpreadsheet.Write(vFullFileName, SpreadsheetDocumentFileType.TXT);
			ИначеЕсли pPrintSettings.PrintDirection = Перечисления.PrintDirections.PDF Тогда
				vFileName = vFileName + ".pdf";
				vFullFileName = cmGetFullFileName(vFileName, vFileSaveCatalog);
				pSpreadsheet.Write(vFullFileName, SpreadsheetDocumentFileType.PDF);
			КонецЕсли;
			// Check if we have to send file by e-mail
			Если НЕ ПустаяСтрока(pPrintSettings.EMails) Тогда
				vSubject = vFileName;
				vMessage = "Рассылка печатных форм:"+ vLanguage + Chars.LF + Chars.LF + 
				           vFileName + Chars.LF + Chars.LF + "C уважением, "+ vLanguage + Chars.LF + ПараметрыСеанса.ИмяКонфигурации + vLanguage;
				cmSendFileByEMailInBackground(vSubject, vMessage, pPrintSettings.EMails, vFileName, vFullFileName, vLanguage);
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры //cmDoSpreadsheetOutput

//-----------------------------------------------------------------------------
// Description: Parses passport data to the passport series and number
// Parameters: Passport data string, Возврат passport series string, return passport number string
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmParsePassportNumber(pPassport, rSeries, rNumber) Экспорт
	vPassport = СокрЛП(pPassport);
	rSeries = "";
	rNumber = vPassport;
	i = СтрДлина(vPassport);
	Пока i > 1 Цикл
		vChar = Сред(vPassport, i , 1);
		Если vChar = " " Тогда
			rNumber = СокрЛП(Сред(vPassport, i + 1));
			rSeries = СтрЗаменить(СокрЛП(Лев(vPassport, i - 1)), " ", "");
			Прервать;
		КонецЕсли;
		i = i - 1;
	КонецЦикла;
КонецПроцедуры //cmParsePassportNumber

//-----------------------------------------------------------------------------
// Description: Parses client full name string to last name, first name, second name and sex
// Parameters: Client full name string as Ivanov Ivan Ivanovich, 
//             Возврат client last name string, 
//             Возврат client first name string, 
//             Возврат client second name string, 
//             Возврат client sex enumeration reference
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmParseClientFullName(Val pFullName, rLastName, rFirstName, rSecondName, rSex = Неопределено) Экспорт
	rLastName = "";
	rFirstName = "";
	rSecondName = "";
	rSex = Неопределено;
	pFullName = СокрЛП(pFullName);
	// Попытка to parse guest full name to the 3 parts
	Если НЕ ПустаяСтрока(pFullName) Тогда
		pFullName = СтрЗаменить(pFullName, ".", " ");
		pFullName = СтрЗаменить(pFullName, "  ", " ");
		pFullName = СтрЗаменить(pFullName, "  ", " ");
		rLastName = pFullName;
		vBlankPos1 = Find(pFullName, " ");
		Если vBlankPos1 > 1 Тогда
			vBlankPos2 = Find(Сред(pFullName, vBlankPos1 + 1), " ");
			Если vBlankPos2 > 1 Тогда
				rLastName = СокрЛП(Лев(pFullName, vBlankPos1 - 1));
				rFirstName = СокрЛП(Сред(pFullName, vBlankPos1 + 1, vBlankPos2 - 1));
				rSecondName = СокрЛП(Прав(pFullName, СтрДлина(pFullName) - vBlankPos1 - vBlankPos2));
				// Попытка to fill gest sex
				rSex = cmGetSexByNames(rLastName, rFirstName, rSecondName);
			Иначе
				rLastName = СокрЛП(Лев(pFullName, vBlankPos1 - 1));
				rFirstName = СокрЛП(Сред(pFullName, vBlankPos1 + 1));
				// Попытка to fill gest sex
				rSex = cmGetSexByNames(rLastName, rFirstName, rSecondName);
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры //cmParseClientFullName

//-----------------------------------------------------------------------------
// Description: Converts comma delimeted list of e-mail addresses to the address array
// Parameters: String of addresses
// Возврат value: Array of addresses
//-----------------------------------------------------------------------------
Функция cmParseEMailAddress(pEMails) Экспорт
	vEMailsList = Новый СписокЗначений();
	vEMails = СокрЛП(pEMails);
	vPos = Find(vEMails, ",");
	Если vPos = 0 Тогда
		vEMailsList.Add(vEMails);
	Иначе
		Пока vPos > 0 Цикл
			vEMailsList.Add(СокрЛП(Лев(vEMails, vPos-1)));
			vEMails = СокрЛП(Сред(vEMails, vPos+1));
			vPos = Find(vEMails, ",");
		КонецЦикла;
		Если НЕ ПустаяСтрока(vEMails) Тогда
			vEMailsList.Add(СокрЛП(vEMails));
		КонецЕсли;
	КонецЕсли;
	Возврат vEMailsList;
КонецФункции //cmParseEMailAddress

//-----------------------------------------------------------------------------
// Description: Sends file by e-mail asynchronously
// Parameters: Mail subject, Mail text, Target addresses, File name to attach, Full file name, language
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmSendFileByEMailInBackground(pSubject, pMessage, pEMails, pFileName, pFullFileName, pLanguage = Неопределено) Экспорт
	vLanguage = pLanguage;
	Если НЕ ЗначениеЗаполнено(vLanguage) Тогда
		vLanguage = ПараметрыСеанса.ТекЛокализация;
	КонецЕсли;
	// Initialize parameters array
	vParams = Новый Array();
	vParams.Add(pSubject);
	vParams.Add(pMessage);
	vParams.Add(pEMails);
	vParams.Add(pFileName);
	vParams.Add(pFullFileName);
	vParams.Add(vLanguage);
	vParams.Add(Истина);
	vParams.Add(Неопределено);
	// Execute in the background
	//BackgroundJobs.Execute("РеглЗадания.cmSendFileByEMail", vParams, , pSubject);
КонецПроцедуры //cmSendFileByEMailInBackground

//-----------------------------------------------------------------------------
// Description: Builds full file name
// Parameters: File name, File catalog
// Возврат value: Full file name
//-----------------------------------------------------------------------------
Функция cmGetFullFileName(Val pFileName, Val pFileCatalog) Экспорт
	pFileName = СокрЛП(pFileName);
	pFileCatalog = СокрЛП(pFileCatalog);
	Если Прав(pFileCatalog, 1) = "\" Тогда
		Возврат pFileCatalog + pFileName;
	ИначеЕсли Прав(pFileCatalog, 1) = "/" Тогда
		Возврат pFileCatalog + pFileName;
	Иначе
		Возврат pFileCatalog + "\" + pFileName; // Windows format by default
	КонецЕсли;
КонецФункции //cmGetFullFileName

//-----------------------------------------------------------------------------
// Description: Returns short file name with type
// Parameters: Full file name as string
// Возврат value: String
//-----------------------------------------------------------------------------
Функция cmGetFileName(pFullFileName) Экспорт
	vFile = Новый File(pFullFileName);
	Если НЕ vFile.Exist() Тогда
		ВызватьИсключение NStr("en='File ';ru='Файл ';de='Datei '") + СокрЛП(pFullFileName) + NStr("en=' is not found!';ru=' не найден!';de=' nicht gefunden!'");
	ИначеЕсли НЕ vFile.IsFile() Тогда
		ВызватьИсключение NStr("en='Folders could not be choosen! ';ru='Выбирать папки нельзя!';de='Die Ordner dürfen nicht gewählt werden!'");
	КонецЕсли;
	Возврат vFile.Name;
КонецФункции //cmGetFileName

//-----------------------------------------------------------------------------
// Description: Sets protected flag to the given print form
// Parameters: Print form
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmSetSpreadsheetProtection(pSpreadsheet) Экспорт
	Если cmCheckUserPermissions("HavePermissionToEditPrintForms") Тогда
		pSpreadsheet.Protection = Ложь;
	Иначе
		pSpreadsheet.Protection = Истина;
	КонецЕсли;
КонецПроцедуры //cmSetSpreadsheetProtection

//-----------------------------------------------------------------------------
// Description: Returns default object printing form to be used when object's 
//              "Print" button is pressed
// Parameters: Type of object (objects empty reference), Print form language
// Возврат value: Object printing form
//-----------------------------------------------------------------------------
Функция cmGetDefaultObjectPrintingForm(pObjectType, pLanguage = Неопределено) Экспорт
	// Build and run query
	vQry = Новый Query;
	vQry.Text = 
	"SELECT
	|	ПечатныеФормы.Ref AS ObjectPrintingForm
	|FROM
	|	Catalog.ПечатныеФормы AS ПечатныеФормы
	|WHERE
	|	ПечатныеФормы.ObjectType = &qObjectType AND " + 
		?(ЗначениеЗаполнено(pLanguage), "(ПечатныеФормы.Language = &qLanguage OR ПечатныеФормы.Language = &qEmptyLanguage) AND ", "") + "
	|	(NOT ПечатныеФормы.DeletionMark) AND
	|	(NOT ПечатныеФормы.IsFolder) AND
	|	ПечатныеФормы.IsActive AND
	|	ПечатныеФормы.IsDefault
	|ORDER BY
	|	ПечатныеФормы.Code";
	vQry.SetParameter("qObjectType", pObjectType);
	vQry.SetParameter("qLanguage", pLanguage);
	vQry.SetParameter("qEmptyLanguage", Справочники.Локализация.EmptyRef());
	vForms = vQry.Execute().Unload();
	vForm = Неопределено;
	Для Each vFormsRow In vForms Цикл
		vForm = vFormsRow.ObjectPrintingForm;
		Break;
	КонецЦикла;
	Возврат vForm;
КонецФункции //cmGetDefaultObjectPrintingForm

//-----------------------------------------------------------------------------
// Description: Returns default object form action to be used when object's 
//              "Actions" button is pressed
// Parameters: Type of object (objects empty reference), Action form language
// Возврат value: Object form action
//-----------------------------------------------------------------------------
Функция cmGetDefaultObjectFormAction(pObjectType, pLanguage = Неопределено) Экспорт
	// Build and run query
	vQry = Новый Query;
	vQry.Text = 
	"SELECT
	|	ObjectFormActions.Ref AS ObjectFormAction
	|FROM
	|	Catalog.ObjectFormActions AS ObjectFormActions
	|WHERE
	|	ObjectFormActions.ObjectType = &qObjectType AND " + 
		?(ЗначениеЗаполнено(pLanguage), "(ObjectFormActions.Language = &qLanguage OR ObjectFormActions.Language = &qEmptyLanguage) AND ", "") + "
	|	(NOT ObjectFormActions.DeletionMark) AND
	|	(NOT ObjectFormActions.IsFolder) AND
	|	ObjectFormActions.IsActive AND
	|	ObjectFormActions.IsDefault
	|ORDER BY
	|	ObjectFormActions.Code";
	vQry.SetParameter("qObjectType", pObjectType);
	vQry.SetParameter("qLanguage", pLanguage);
	vQry.SetParameter("qEmptyLanguage", Справочники.Локализация.EmptyRef());
	vForms = vQry.Execute().Unload();
	vAction = Неопределено;
	Для Each vFormsRow In vForms Цикл
		vAction = vFormsRow.ObjectFormAction;
		Прервать;
	КонецЦикла;
	Возврат vAction;
КонецФункции //cmGetDefaultObjectFormAction

//-----------------------------------------------------------------------------
// Description: Returns full person name
// Parameters: Client reference
// Возврат value: String
//-----------------------------------------------------------------------------
Функция cmGetFullPersonName(pPerson) Экспорт
	Если ЗначениеЗаполнено(pPerson) Тогда
		Возврат СокрЛП(СокрЛП(pPerson.Фамилия) + " " + СокрЛП(pPerson.Имя) + " " + СокрЛП(pPerson.Отчество));
	Иначе
		Возврат "";
	КонецЕсли;
КонецФункции //cmGetFullPersonName

//-----------------------------------------------------------------------------
// Description: Returns guest sex by names
// Parameters: Last name, First name, Second name
// Возврат value: Перечисления.Sex.Ref
//-----------------------------------------------------------------------------
Функция cmGetSexByNames(pLastName, pFirstName, pSecondName) Экспорт
	Если СтрДлина(СокрЛП(pSecondName)) < 2 Тогда
		vLastCharLastName = ВРег(Прав(СокрЛП(pLastName), 1));
		vLastCharFirstName = ВРег(Прав(СокрЛП(pFirstName), 1));
		Если (vLastCharLastName = "А") ИЛИ (vLastCharLastName = "Я") ИЛИ
		   (vLastCharFirstName = "А") ИЛИ (vLastCharFirstName = "Я") Тогда
			Возврат Перечисления.Пол.Female;
		Иначе
			Возврат Перечисления.Пол.Male;
		КонецЕсли;
	Иначе
		vLastCharSecondName = ВРег(Прав(СокрЛП(pSecondName), 1));
		Если vLastCharSecondName = "А" Тогда
			Возврат Перечисления.Пол.Female;
		Иначе
			Возврат Перечисления.Пол.Male;
		КонецЕсли;
	КонецЕсли;
КонецФункции //cmGetSexByNames

//-----------------------------------------------------------------------------
// Description: Returns client's list with given identity document number and series
// Parameters: Identity document series, Identity document number
// Возврат value: Value list of clients
//-----------------------------------------------------------------------------
Функция cmGetClientsByIdentityDocumentSeriesAndNumber(pIDSeries, pIDNumber, pClientToSkip) Экспорт
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	Клиенты.Ref
	|FROM
	|	Catalog.Клиенты AS Клиенты
	|WHERE
	|	Клиенты.IdentityDocumentNumber = &qIDNumber
	|	AND Клиенты.IdentityDocumentSeries = &qIDSeries
	|	AND Клиенты.Ref <> &qClient
	|	AND NOT Клиенты.DeletionMark
	|	AND NOT Клиенты.IsFolder
	|
	|ORDER BY
	|	Клиенты.Description";
	vQry.SetParameter("qIDSeries", СокрЛП(pIDSeries));
	vQry.SetParameter("qIDNumber", СокрЛП(pIDNumber));
	vQry.SetParameter("qClient", pClientToSkip);
	vQryRes = vQry.Execute().Unload();
	Возврат vQryRes;
КонецФункции //cmGetClientsByIdentityDocumentSeriesAndNumber

//-----------------------------------------------------------------------------
// Description: Gets object printing forms list based on object type and language
// Parameters: Object type as empty object reference, language
// Возврат value: Value table with list of object printing forms
//-----------------------------------------------------------------------------
Функция cmGetObjectPrintingForms(pObjectType, pLanguage = Неопределено, pPostponedOnly = Ложь) Экспорт
	// Build and run query
	vQry = Новый Query;
	vQry.Text = 
	"SELECT
	|	ПечатныеФормы.Ref AS ObjectPrintingForm,
	|	ПечатныеФормы.Predefined,
	|	ПечатныеФормы.Code,
	|	ПечатныеФормы.Description,
	|	ПечатныеФормы.ObjectType,
	|	ПечатныеФормы.Language,
	|	ПечатныеФормы.ExternalProcessing,
	|	ПечатныеФормы.Report,
	|	ПечатныеФормы.AutomaticallyPrintOnFirstObjectWrite,
	|	ПечатныеФормы.Примечания,
	|	ПечатныеФормы.IsDefault
	|FROM
	|	Catalog.ПечатныеФормы AS ПечатныеФормы
	|WHERE
	|	ПечатныеФормы.ObjectType = &qObjectType
	|	AND NOT ПечатныеФормы.DeletionMark
	|	AND NOT ПечатныеФормы.IsFolder
	|	AND (NOT &qPostponedOnly
	|				AND NOT ПечатныеФормы.Parameter LIKE &qPostponed
	|			OR &qPostponedOnly
	|				AND ПечатныеФормы.Parameter LIKE &qPostponed)
	|	AND ПечатныеФормы.IsActive" + 
		?(ЗначениеЗаполнено(pLanguage), " AND (ПечатныеФормы.Language = &qLanguage OR ПечатныеФормы.Language = &qEmptyLanguage) ", "") + "
	|ORDER BY
	|	Code";
	vQry.SetParameter("qObjectType", pObjectType);
	vQry.SetParameter("qLanguage", pLanguage);
	vQry.SetParameter("qEmptyLanguage", Справочники.Локализация.EmptyRef());
	vQry.SetParameter("qPostponedOnly", pPostponedOnly);
	vQry.SetParameter("qPostponed", "%POSTPONED%");
	vForms = vQry.Execute().Unload();
	Возврат vForms;
КонецФункции //cmGetObjectPrintingForms

//-----------------------------------------------------------------------------
// Description: Gets object actions list based on object type and language
// Parameters: Object type as empty object reference, language
// Возврат value: Value table with list of object form actions
//-----------------------------------------------------------------------------
Функция cmGetObjectActions(pObjectType, pLanguage = Неопределено) Экспорт
	// Build and run query
	vQry = Новый Query;
	vQry.Text = 
	"SELECT
	|	ObjectFormActions.Ref AS ObjectFormAction,
	|	ObjectFormActions.Predefined,
	|	ObjectFormActions.Code,
	|	ObjectFormActions.Description,
	|	ObjectFormActions.ObjectFormActionButton,
	|	ObjectFormActions.ButtonCaption,
	|	ObjectFormActions.ButtonToolTip,
	|	ObjectFormActions.ButtonShortcut,
	|	ObjectFormActions.ObjectType,
	|	ObjectFormActions.Language,
	|	ObjectFormActions.AutomaticallyRunOnFirstObjectWrite,
	|	ObjectFormActions.DataProcessor,
	|	ObjectFormActions.ExternalProcessing,
	|	ObjectFormActions.Примечания,
	|	ObjectFormActions.IsDefault
	|FROM
	|	Catalog.ObjectFormActions AS ObjectFormActions
	|WHERE
	|	ObjectFormActions.ObjectType = &qObjectType AND 
	|	ObjectFormActions.DeletionMark = FALSE AND 
	|	ObjectFormActions.IsFolder = FALSE AND 
	|	ObjectFormActions.IsActive = TRUE " + 
		?(ЗначениеЗаполнено(pLanguage), " AND (ObjectFormActions.Language = &qLanguage OR ObjectFormActions.Language = &qEmptyLanguage) ", "") + "
	|ORDER BY
	|	Code";
	vQry.SetParameter("qObjectType", pObjectType);
	vQry.SetParameter("qLanguage", pLanguage);
	vQry.SetParameter("qEmptyLanguage", Справочники.Локализация.EmptyRef());
	vActions = vQry.Execute().Unload();
	Возврат vActions;
КонецФункции //cmGetObjectActions

//-----------------------------------------------------------------------------
// Description: Gets object templates list based on object type
// Parameters: Гостиница, Object type as empty object reference
// Возврат value: Value table with list of object templates
//-----------------------------------------------------------------------------
Функция cmGetObjectTemplates(pHotel, pObjectType) Экспорт
	// Build and run query
	vQry = Новый Query;
	vQry.Text = 
	"SELECT
	|	ШаблоныОпераций.Ref AS ObjectTemplate,
	|	ШаблоныОпераций.Code AS Code,
	|	ШаблоныОпераций.Description AS Description,
	|	ШаблоныОпераций.IsDefault AS IsDefault
	|FROM
	|	Catalog.ШаблоныОпераций AS ШаблоныОпераций
	|WHERE
	|	ШаблоныОпераций.Гостиница = &qHotel 
	|	AND ШаблоныОпераций.ObjectType = &qObjectType 
	|	AND ШаблоныОпераций.DeletionMark = FALSE 
	|	AND ШаблоныОпераций.IsFolder = FALSE 
	|	AND ШаблоныОпераций.IsActive = TRUE 
	|ORDER BY
	|	Code";
	vQry.SetParameter("qHotel", pHotel);
	vQry.SetParameter("qObjectType", pObjectType);
	vTemplates = vQry.Execute().Unload();
	Возврат vTemplates;
КонецФункции //cmGetObjectTemplates 

//-----------------------------------------------------------------------------
// Description: Gets employee permission group
// Parameters: Employee
// Возврат value: Permission group reference
//-----------------------------------------------------------------------------
Функция cmGetEmployeePermissionGroup(pEmployee) Экспорт
	vPermissionGroup = Справочники.НаборПрав.EmptyRef();
	Если ЗначениеЗаполнено(pEmployee) Тогда
		vEmployeeNonReplicatingAttrs = pEmployee.GetObject().pmGetNonReplicatingAttributes();
		Если vEmployeeNonReplicatingAttrs.Count() > 0 Тогда
			vPermissionGroup = vEmployeeNonReplicatingAttrs.Get(0).НаборПрав;
		Иначе
			vPermissionGroup = pEmployee.НаборПрав;
		КонецЕсли;
	КонецЕсли;
	Возврат vPermissionGroup;
КонецФункции //cmGetEmployeePermissionGroup

//-----------------------------------------------------------------------------
// Description: Checks employee permissions to do some action
// Parameters: Permission name
// Возврат value: Истина if employee has rights to perform an action or Ложь if not
//-----------------------------------------------------------------------------
Функция cmCheckUserPermissions(pPermissionName) Экспорт
	vUserHasPermissions = Ложь;
	Если ЗначениеЗаполнено(ПараметрыСеанса.ТекПользователь) Тогда
		vCurUsr = ПараметрыСеанса.ТекПользователь;
		Если ЗначениеЗаполнено(vCurUsr) Тогда
			vCurUsrPermGrp = cmGetEmployeePermissionGroup(vCurUsr);
			Если ЗначениеЗаполнено(vCurUsrPermGrp) Тогда
				Если vCurUsrPermGrp[pPermissionName] Тогда
					vUserHasPermissions = Истина;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	Возврат vUserHasPermissions;
КонецФункции //cmCheckUserPermissions

//-----------------------------------------------------------------------------
// Description: Returns value list of ГруппаНомеров rates allowed for the current employee
// Parameters: Period start date, Period end date
// Возврат value: Value list of ГруппаНомеров rates allowed
//-----------------------------------------------------------------------------
Функция cmGetAllowedRoomRates(pPeriodFrom = Неопределено, pPeriodTo = Неопределено) Экспорт
	vAllowedRoomRates = Новый СписокЗначений();
	// Get list of all ГруппаНомеров rates valid for the period
	Если ЗначениеЗаполнено(pPeriodFrom) ИЛИ ЗначениеЗаполнено(pPeriodTo) Тогда
		vQry = Новый Query();
		vQry.Text = 
		"SELECT
		|	Тарифы.Ref,
		|	ISNULL(Restrictions.CTA, FALSE) AS CTA
		|FROM
		|	Catalog.Тарифы AS Тарифы
		|		LEFT JOIN InformationRegister.RoomRateRestrictions AS Restrictions
		|		ON (NOT &qPeriodFromIsEmpty)
		|			AND Тарифы.Ref = Restrictions.Тариф
		|			AND (Restrictions.CTA)
		|			AND (Тарифы.Гостиница = Restrictions.Гостиница
		|				OR Restrictions.Гостиница = &qEmptyHotel)
		|			AND (Restrictions.УчетнаяДата = &qPeriodFrom
		|				OR Restrictions.DayOfWeek = &qDayOfWeek)
		|			AND (NOT Restrictions.IsForOnlineOnly)
		|WHERE
		|	NOT Тарифы.DeletionMark
		|	AND NOT Тарифы.IsFolder
		|	AND (&qPeriodFrom >= Тарифы.DateValidFrom
		|			OR &qPeriodFromIsEmpty)
		|	AND (Тарифы.DateValidTo <> &qEmptyDate
		|				AND &qPeriodTo <= ENDOFPERIOD(Тарифы.DateValidTo, DAY)
		|			OR &qPeriodToIsEmpty
		|			OR Тарифы.DateValidTo = &qEmptyDate)
		|	AND NOT ISNULL(Restrictions.CTA, FALSE)
		|
		|ORDER BY
		|	Тарифы.ПорядокСортировки,
		|	Тарифы.Description";
		vQry.SetParameter("qPeriodFrom", ?(ЗначениеЗаполнено(pPeriodFrom), BegOfDay(pPeriodFrom), '00010101'));
		vQry.SetParameter("qDayOfWeek", ?(ЗначениеЗаполнено(pPeriodFrom), WeekDay(pPeriodFrom), 0));
		vQry.SetParameter("qPeriodFromIsEmpty", НЕ ЗначениеЗаполнено(pPeriodFrom));
		vQry.SetParameter("qPeriodTo", ?(ЗначениеЗаполнено(pPeriodTo), BegOfDay(pPeriodTo), '00010101'));
		vQry.SetParameter("qPeriodToIsEmpty", НЕ ЗначениеЗаполнено(pPeriodTo));
		vQry.SetParameter("qEmptyDate", '00010101');
		vQry.SetParameter("qEmptyHotel", Справочники.Гостиницы.EmptyRef());
		vQryRes = vQry.Execute().Unload();
		Если vQryRes.Count() > 0 Тогда
			vAllowedRoomRates.LoadValues(vQryRes.UnloadColumn("Ссылка"));
		КонецЕсли;
	КонецЕсли;
	// Leave only allowed for this user ГруппаНомеров rates
	Если ЗначениеЗаполнено(ПараметрыСеанса.ТекПользователь) Тогда
		vCurUsr = ПараметрыСеанса.ТекПользователь;
		Если ЗначениеЗаполнено(vCurUsr) Тогда
			vCurUsrPermGrp = cmGetEmployeePermissionGroup(vCurUsr);
			Если ЗначениеЗаполнено(vCurUsrPermGrp) Тогда
				Если vCurUsrPermGrp.RoomRatesAllowed.Count() > 0 Тогда
					i = 0;
					Пока i < vAllowedRoomRates.Count() Цикл
						vAllowedRoomRatesItem = vAllowedRoomRates.Get(i);
						Если vCurUsrPermGrp.RoomRatesAllowed.Find(vAllowedRoomRatesItem.Value, "Тариф") = Неопределено Тогда
							vAllowedRoomRates.Delete(i);
						Иначе
							i = i + 1;
						КонецЕсли;
					КонецЦикла;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	Возврат vAllowedRoomRates;
КонецФункции //cmGetAllowedRoomRates

//-----------------------------------------------------------------------------
// Description: Returns value list of service packages allowed for the current employee
// Parameters: Period start date, Period end date, Resource
// Возврат value: Value list of service packages allowed
//-----------------------------------------------------------------------------
Функция cmGetAllowedServicePackages(pHotel, pPeriodFrom, pPeriodTo, pResource = Неопределено) Экспорт
	vAllowedServicePackages = Новый СписокЗначений();
	// Run query to get service packages valid for the period selected
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	ПакетыУслуг.Ref
	|FROM
	|	Catalog.ПакетыУслуг AS ПакетыУслуг
	|WHERE
	|	NOT ПакетыУслуг.DeletionMark
	|	AND NOT ПакетыУслуг.IsFolder
	|	AND ПакетыУслуг.DateValidFrom <= &qPeriodTo
	|	AND (ПакетыУслуг.DateValidTo >= &qPeriodFrom OR ПакетыУслуг.DateValidTo = &qEmptyDate)
	|	AND (ПакетыУслуг.Гостиница = &qHotel
	|			OR ПакетыУслуг.Гостиница = &qEmptyHotel)
	|
	|ORDER BY
	|	ПакетыУслуг.ПорядокСортировки";
	vQry.SetParameter("qPeriodFrom", BegOfDay(pPeriodFrom));
	vQry.SetParameter("qPeriodTo", BegOfDay(pPeriodTo));
	vQry.SetParameter("qEmptyDate", '00010101');
	vQry.SetParameter("qHotel", pHotel);
	vQry.SetParameter("qEmptyHotel", Справочники.Гостиницы.EmptyRef());
	vQryRes = vQry.Execute().Unload();
	// Filter service packages by resource
	Если ЗначениеЗаполнено(pResource) And pResource.ПакетыУслуг.Count() > 0 Тогда
		i = 0;
		Пока i < vQryRes.Count() Цикл
			vQryResRow = vQryRes.Get(i);
			Если pResource.ПакетыУслуг.Find(vQryResRow.Ref, "ServicePackage") = Неопределено Тогда
				vQryRes.Delete(i);
			Иначе
				i = i + 1;
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	// Fill value list
	vAllowedServicePackages.LoadValues(vQryRes.UnloadColumn("Ссылка"));
	// Возврат
	Возврат vAllowedServicePackages;
КонецФункции //cmGetAllowedServicePackages

//-----------------------------------------------------------------------------
// Description: Returns whether current employee has to see balances in the 
//              accommodation or reservation lists or not
// Parameters: None
// Возврат value: Истина/Ложь
//-----------------------------------------------------------------------------
Функция cmShowBalancesInLists() Экспорт
	vShowBalances = Истина;
	Если ЗначениеЗаполнено(ПараметрыСеанса.ТекПользователь) Тогда
		vCurUsr = ПараметрыСеанса.ТекПользователь;
		Если ЗначениеЗаполнено(vCurUsr) Тогда
			vCurUsrPermGrp = vCurUsr.НаборПрав;
			Если ЗначениеЗаполнено(vCurUsrPermGrp) Тогда
				vShowBalances = НЕ vCurUsrPermGrp.DoNotShowBalancesInLists;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	Возврат vShowBalances;
КонецФункции //cmShowBalancesInLists 

//-----------------------------------------------------------------------------
// Description: Parses address string into the structure of address elements like
//              country, region, district, city, street, house, flat and so on
// Parameters: Address string
// Возврат value: Address structure
//-----------------------------------------------------------------------------
Функция cmParseAddress(pAddress) Экспорт
	// Initialize return structure
	vAddrElements = Новый Structure("Country,PostCode,Region,Area,City,Street,House,Flat", 
	                              Справочники.Страны.EmptyRef(), "", "", "", "", "", "", "");
	// Initialize working variables
	vAddress = СокрЛП(pAddress);
	// Country
	vCommaPos = Find(vAddress, ",");
	Если vCommaPos = 0 Тогда
		vAddrElements.Country = Справочники.Страны.FindByDescription(vAddress, Истина);
		Если valueIsFilled(vAddrElements.Country) Тогда
			Возврат vAddrElements;
		КонецЕсли;		
	КонецЕсли;	
	vAddrElements.Country = Справочники.Страны.FindByDescription(Лев(vAddress, vCommaPos-1), Истина);
	vAddress = Сред(vAddress, vCommaPos+1);
	// Post index
	vCommaPos = Find(vAddress, ",");
	Если vCommaPos = 0 Тогда
		vAddrElements.PostCode = СокрЛП(vAddress);
		Возврат vAddrElements;
	КонецЕсли;	
	vAddrElements.PostCode = СокрЛП(Лев(vAddress, vCommaPos-1));
	vAddress = Сред(vAddress, vCommaPos+1);
	// Region
	vCommaPos = Find(vAddress, ",");
	Если vCommaPos = 0 Тогда
		vAddrElements.Region = СокрЛП(vAddress);
		Возврат vAddrElements;
	КонецЕсли;	
	vAddrElements.Region = СокрЛП(Лев(vAddress, vCommaPos-1));
	vAddress = Сред(vAddress, vCommaPos+1);
	// Area
	vCommaPos = Find(vAddress, ",");
	Если vCommaPos = 0 Тогда
		vAddrElements.Area = СокрЛП(vAddress);
		Возврат vAddrElements;
	КонецЕсли;	
	vAddrElements.Area = СокрЛП(Лев(vAddress, vCommaPos-1));
	vAddress = Сред(vAddress, vCommaPos+1);
	// City
	vCommaPos = Find(vAddress, ",");
	Если vCommaPos = 0 Тогда
		vAddrElements.City = СокрЛП(vAddress);
		Возврат vAddrElements;
	КонецЕсли;	
	vAddrElements.City = СокрЛП(Лев(vAddress, vCommaPos-1));
	vAddress = Сред(vAddress, vCommaPos+1);
	// Street
	vCommaPos = Find(vAddress, ",");
	Если vCommaPos = 0 Тогда
		vAddrElements.Street = СокрЛП(vAddress);
		Возврат vAddrElements;
	КонецЕсли;	
	vAddrElements.Street = СокрЛП(Лев(vAddress, vCommaPos-1));
	vAddress = Сред(vAddress, vCommaPos+1);
	// House
	vCommaPos = Find(vAddress, ",");
	Если vCommaPos = 0 Тогда
		vAddrElements.House = СокрЛП(vAddress);
		Возврат vAddrElements;
	КонецЕсли;	
	vAddrElements.House = СокрЛП(Лев(vAddress, vCommaPos-1));
	vAddress = Сред(vAddress, vCommaPos+1);
	// Flat
	vAddrElements.Flat = СокрЛП(vAddress);
	// Возврат address structure
	Возврат vAddrElements;
КонецФункции //cmParseAddress

//-----------------------------------------------------------------------------
// Description: Builds address string from the list of address elements like
//              country, region, district, city, street, house, flat and so on
// Parameters: Address elements
// Возврат value: Address string
//-----------------------------------------------------------------------------
Функция cmBuildAddress(pCountry = "", pPostCode = "", pRegion = "", pArea = "", pCity = "", pStreet = "", pHouse = "", pFlat = "") Экспорт
	// Build address string
	vAddress = СокрЛП(pCountry) + ", " + 
	           СокрЛП(pPostCode) + ", " +  
	           СокрЛП(pRegion) + ", " +  
	           СокрЛП(pArea) + ", " +  
	           СокрЛП(pCity) + ", " +  
	           СокрЛП(pStreet) + ", " +  
	           СокрЛП(pHouse) + ", " +  
	           СокрЛП(pFlat);
	// Remove trailing commas and blanks
	vAddress = СокрЛП(vAddress);
	vLen = СтрДлина(vAddress);
	i = vLen;
	Пока i > 0 Цикл
		vChar = Сред(vAddress, i, 1);
		Если vChar <> "," And vChar <> " " Тогда
			Прервать;
		Иначе
			Если i > 1 Тогда
				vAddress = Лев(vAddress, i - 1);
			Иначе
				vAddress = "";
			КонецЕсли;
		КонецЕсли;
		i = i - 1;
	КонецЦикла;
	// Возврат address
	Возврат vAddress;
КонецФункции //cmBuildAddress

//-----------------------------------------------------------------------------
// Description: Converts address string to the human readable form
// Parameters: Address string
// Возврат value: Human readable address string
//-----------------------------------------------------------------------------
Функция cmGetAddressPresentation(pAddress) Экспорт
	vAddress = СокрЛП(pAddress);
	Если Find(vAddress, Chars.LF) > 0 Тогда
		Возврат vAddress;
	КонецЕсли;
	Пока Лев(vAddress, 1) = "," Цикл
		Если Лев(vAddress, 2) = ", " Тогда
			vAddress = Прав(vAddress, СтрДлина(vAddress)-2);
		ИначеЕсли Лев(vAddress, 1) = "," Тогда
			vAddress = Прав(vAddress, СтрДлина(vAddress)-1);
		КонецЕсли;
		vAddress = СокрЛП(vAddress);
	КонецЦикла;
	vAddress = СтрЗаменить(vAddress, " , ", "");
	vAddress = СтрЗаменить(vAddress, ", , ", ", ");
	vAddress = СтрЗаменить(vAddress, ", , ", ", ");
	vAddress = СтрЗаменить(vAddress, ", , ", ", ");
	vAddress = СтрЗаменить(vAddress, ", , ", ", ");
	vAddress = СтрЗаменить(vAddress, ", , ", ", ");
	vAddress = СтрЗаменить(vAddress, ",,", ",");
	vAddress = СтрЗаменить(vAddress, ",,", ",");
	vAddress = СтрЗаменить(vAddress, ",,", ",");
	vAddress = СтрЗаменить(vAddress, ",,", ",");
	vAddress = СтрЗаменить(vAddress, ",,", ",");
	vAddress = СтрЗаменить(vAddress, "корп.", "к.");
	vAddress = СтрЗаменить(vAddress, "Корп.", "к.");
	vAddress = СтрЗаменить(vAddress, "кор.", "к.");
	vAddress = СтрЗаменить(vAddress, "Кор.", "к.");
	vAddress = СтрЗаменить(vAddress, "стр.", "с.");
	vAddress = СтрЗаменить(vAddress, "Стр.", "с.");
	Возврат СокрЛП(vAddress);
КонецФункции //cmGetAddressPresentation

//-----------------------------------------------------------------------------
// Description: Removes prefix and leading zeros from the document number
// Parameters: Document number
// Возврат value: Document number presentation
//-----------------------------------------------------------------------------
Функция cmGetDocumentNumberPresentation(pNumber) Экспорт
	vNumberPresentation = "";
	vNumber = СокрЛП(pNumber);
	Попытка
		vNumberLength = СтрДлина(vNumber);
		vPrefixLength = 0;
		Для i = 1 По vNumberLength Цикл
			vChar = Сред(vNumber, i, 1);
			Если (vChar < "0" ИЛИ vChar > "9") And vChar <> "/" Тогда
				vPrefixLength = i;
			КонецЕсли;
		КонецЦикла;
		Если vPrefixLength < vNumberLength Тогда
			vNumberPresentation = Сред(vNumber, vPrefixLength + 1);
			vNumberPresentation = Формат(Число(vNumberPresentation), "ND=12; NFD=0; NG=");
		КонецЕсли;
		Если ПустаяСтрока(vNumberPresentation) Тогда
			vNumberPresentation = vNumber;
		КонецЕсли;
	Исключение
		vNumberPresentation = СокрЛП(pNumber);
	КонецПопытки;
	Возврат vNumberPresentation;
КонецФункции //cmGetDocumentNumberPresentation	

//-----------------------------------------------------------------------------
// Description: Removes leading zeros from the document number
// Parameters: Document number
// Возврат value: Document number presentation
//-----------------------------------------------------------------------------
Функция cmRemoveLeadingZeroes(pNumber) Экспорт
	vNumberPresentation = "";
	vNumber = СокрЛП(pNumber);
	Попытка
		vNumberLength = СтрДлина(vNumber);
		Для i = 1 По vNumberLength Цикл
			vChar = Сред(vNumber, i, 1);
			Если vChar <> "0" Тогда
				Прервать;
			КонецЕсли;
		КонецЦикла;
		Если i < vNumberLength Тогда
			vNumberPresentation = Сред(vNumber, i);
		КонецЕсли;
		Если ПустаяСтрока(vNumberPresentation) Тогда
			vNumberPresentation = vNumber;
		КонецЕсли;
	Исключение
		vNumberPresentation = СокрЛП(pNumber);
	КонецПопытки;
	Возврат vNumberPresentation;
КонецФункции //cmRemoveLeadingZeroes	

//-----------------------------------------------------------------------------
// Description: Formats document date to the dd.MM.yyyy form
// Parameters: Date
// Возврат value: Date formatted
//-----------------------------------------------------------------------------
Функция cmGetDocumentDatePresentation(pDate) Экспорт
	Возврат Формат(pDate, "DF=dd.MM.yyyy");
КонецФункции //cmGetDocumentDatePresentation

//-----------------------------------------------------------------------------
// Description: Restores full document number (with prefix and leading zeros) from
//              document number presentation
// Parameters: Document number presentation, Гостиница
// Возврат value: Document number
//-----------------------------------------------------------------------------
Функция cmGetDocumentNumberFromPresentation(pNumberPresentation, pHotel, pCompany = Неопределено) Экспорт
	vNumber = "";
	vPresentation = СокрЛП(pNumberPresentation);
	Если СтрДлина(vPresentation) = 12 Тогда
		Возврат vPresentation;
	КонецЕсли;
	Если НЕ ПустаяСтрока(vPresentation) Тогда
		Попытка
			vPrefix = "";
			Если ЗначениеЗаполнено(pCompany) Тогда
				vPrefix = СокрЛП(pCompany.Prefix);
			ИначеЕсли ЗначениеЗаполнено(pHotel) Тогда
				vPrefix = СокрЛП(pHotel.GetObject().pmGetPrefix());
			ИначеЕсли ЗначениеЗаполнено(ПараметрыСеанса.ТекущаяГостиница) Тогда
				vPrefix = СокрЛП(ПараметрыСеанса.ТекущаяГостиница.GetObject().pmGetPrefix());
			КонецЕсли;
			Если НЕ ПустаяСтрока(vPrefix) Тогда
				Если Лев(vPresentation, Min(СтрДлина(vPrefix), СтрДлина(vPresentation))) <> vPrefix Тогда
					vPresentation = vPrefix + Формат(Число(vPresentation), "ND=" + String(12 - СтрДлина(vPrefix)) + "; NZ=; NLZ=; NG=");
				КонецЕсли;
			Иначе
				vPresentation = Формат(Число(vPresentation), "ND=12; NZ=; NLZ=; NG=");
			КонецЕсли;
		Исключение
		КонецПопытки;
		vNumber = vPresentation;
	КонецЕсли;
	Возврат vNumber;
КонецФункции //cmGetDocumentNumberFromPresentation

//-----------------------------------------------------------------------------
// Description: Restores full folio proforma number (with prefix and leading zeros) from
//              document number presentation
// Parameters: Document number presentation, Гостиница
// Возврат value: Document number
//-----------------------------------------------------------------------------
Функция cmGetFolioProformaNumberFromPresentation(pNumberPresentation, pHotel) Экспорт
	vNumber = "";
	vPresentation = СокрЛП(pNumberPresentation);
	Если НЕ ПустаяСтрока(vPresentation) Тогда
		Попытка
			vPrefix = "";
			Если ЗначениеЗаполнено(pHotel) Тогда
				vPrefix = СокрЛП(pHotel.GetObject().pmGetFolioProFormaNumberPrefix());
			ИначеЕсли ЗначениеЗаполнено(ПараметрыСеанса.ТекущаяГостиница) Тогда
				vPrefix = СокрЛП(ПараметрыСеанса.ТекущаяГостиница.GetObject().pmGetFolioProFormaNumberPrefix());
			КонецЕсли;
			Если НЕ ПустаяСтрока(vPrefix) Тогда
				Если Лев(vPresentation, Min(СтрДлина(vPrefix), СтрДлина(vPresentation))) <> vPrefix Тогда
					vPresentation = vPrefix + Формат(Число(vPresentation), "ND=" + String(12 - СтрДлина(vPrefix)) + "; NZ=; NLZ=; NG=");
				КонецЕсли;
			Иначе
				vPresentation = Формат(Число(vPresentation), "ND=12; NZ=; NLZ=; NG=");
			КонецЕсли;
		Исключение
		КонецПопытки;
		vNumber = vPresentation;
	КонецЕсли;
	Возврат vNumber;
КонецФункции //cmGetFolioProformaNumberFromPresentation

//-----------------------------------------------------------------------------
// Description: Restores full folio accounting number (with prefix and leading zeros) from
//              document number presentation
// Parameters: Document number presentation, Гостиница
// Возврат value: Document number
//-----------------------------------------------------------------------------
Функция cmGetFolioAccountingNumberFromPresentation(pNumberPresentation, pHotel) Экспорт
	vNumber = "";
	vPresentation = СокрЛП(pNumberPresentation);
	Если НЕ ПустаяСтрока(vPresentation) Тогда
		Попытка
			vPrefix = "";
			Если ЗначениеЗаполнено(pHotel) Тогда
				vPrefix = СокрЛП(pHotel.GetObject().pmGetFolioAccountingNumberPrefix());
			ИначеЕсли ЗначениеЗаполнено(ПараметрыСеанса.ТекущаяГостиница) Тогда
				vPrefix = СокрЛП(ПараметрыСеанса.ТекущаяГостиница.GetObject().pmGetFolioAccountingNumberPrefix());
			КонецЕсли;
			Если НЕ ПустаяСтрока(vPrefix) Тогда
				Если Лев(vPresentation, Min(СтрДлина(vPrefix), СтрДлина(vPresentation))) <> vPrefix Тогда
					vPresentation = vPrefix + Формат(Число(vPresentation), "ND=" + String(12 - СтрДлина(vPrefix)) + "; NZ=; NLZ=; NG=");
				КонецЕсли;
			Иначе
				vPresentation = Формат(Число(vPresentation), "ND=12; NZ=; NLZ=; NG=");
			КонецЕсли;
		Исключение
		КонецПопытки;
		vNumber = vPresentation;
	КонецЕсли;
	Возврат vNumber;
КонецФункции //cmGetFolioAccountingNumberFromPresentation

//-----------------------------------------------------------------------------
// Description: Rounds number
// Parameters: Число to round, number of decimal digits
// Возврат value: Rounded number
//-----------------------------------------------------------------------------
Функция cmRound(pNum, pDigits) Экспорт
	Возврат Round(pNum, pDigits);
КонецФункции //cmRound 

//-----------------------------------------------------------------------------
// Description: Rounds date to the int number of hours (fraction = 1) or 
//              minutes (fraction = 2)
// Parameters: Date, Round precision
// Возврат value: Date
//-----------------------------------------------------------------------------
Функция cmRoundDate(pDate, pFraction = 0) Экспорт
	vDate = pDate;
	Если pFraction = 0 Тогда
		vDate = BegOfDay(pDate);
	ИначеЕсли pFraction = 1 Тогда
		vDate = BegOfDay(pDate) + Hour(pDate) * 3600 + ?(Minute(pDate) >= 30, 3600, 0);
	ИначеЕсли pFraction = 2 Тогда
		vDate = BegOfDay(pDate) + Hour(pDate) * 3600 + Minute(pDate) + ?(Second(pDate) >= 30, 60, 0);
	КонецЕсли;
	Возврат vDate;
КонецФункции //cmRoundDate

//-----------------------------------------------------------------------------
// Description: Rounds date to necessary number of hours
// Parameters: Date, Число of hours
// Возврат value: Date
//-----------------------------------------------------------------------------
Функция cmRoundHours(pDate, pNumHours = 1) Экспорт
	Возврат BegOfDay(pDate) + Round(Hour(pDate)/pNumHours, 0) * pNumHours * 3600;
КонецФункции //cmRoundHours

//-----------------------------------------------------------------------------
// Description: Tries to find and return country by contry code
// Parameters: Country code
// Возврат value: Country or empty reference
//-----------------------------------------------------------------------------
Функция cmGetCountryByCode(pCountryCode) Экспорт
	vCountry = Справочники.Страны.FindByCode(pCountryCode);
	Если НЕ ЗначениеЗаполнено(vCountry) Тогда
		vCountry = Справочники.Страны.FindByAttribute("ISOCode3", СокрЛП(pCountryCode));
		Если НЕ ЗначениеЗаполнено(vCountry) Тогда
			vCountry = Справочники.Страны.FindByAttribute("ISOCode", СокрЛП(pCountryCode));
			Если НЕ ЗначениеЗаполнено(vCountry) Тогда
				vCountry = Справочники.Страны.FindByDescription(СокрЛП(pCountryCode), Истина);
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	Возврат vCountry;
КонецФункции //cmGetCountryByCode

//-----------------------------------------------------------------------------
// Description: Tries to find and return region by region code and country
// Parameters: Region code, Country
// Возврат value: Region or empty reference
//-----------------------------------------------------------------------------
Функция cmGetRegionByCode(pRegionCode, pCountry) Экспорт
	vRegion = Справочники.Regions.EmptyRef();
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	Regions.Ref AS Region
	|FROM
	|	Catalog.Regions AS Regions
	|WHERE
	|	Regions.Code = &qRegionCode
	|	AND Regions.Country = &qCountry
	|	AND Regions.DeletionMark = FALSE";
	vQry.SetParameter("qRegionCode", pRegionCode);
	vQry.SetParameter("qCountry", pCountry);
	vList = vQry.Execute().Unload();
	Для Each vListRow In vList Цикл
		vRegion = vListRow.Region;
		Прервать;
	КонецЦикла;
	Возврат vRegion;
КонецФункции //cmGetRegionByCode

//-----------------------------------------------------------------------------
// Description: Tries to find and return region by region description and country
// Parameters: Region description, Country
// Возврат value: Region or empty reference
//-----------------------------------------------------------------------------
Функция cmGetRegionByDescription(pRegionDescription, pCountry) Экспорт
	vRegion = Справочники.Regions.EmptyRef();
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	Regions.Ref AS Region
	|FROM
	|	Catalog.Regions AS Regions
	|WHERE
	|	Regions.Description = &qRegionDescription
	|	AND Regions.Country = &qCountry
	|	AND Regions.DeletionMark = FALSE";
	vQry.SetParameter("qRegionDescription", СокрЛП(pRegionDescription));
	vQry.SetParameter("qCountry", pCountry);
	vList = vQry.Execute().Unload();
	Для Each vListRow In vList Цикл
		vRegion = vListRow.Region;
		Прервать;
	КонецЦикла;
	Возврат vRegion;
КонецФункции //cmGetRegionByDescription

//-----------------------------------------------------------------------------
// Description: Tries to find and return area (district) by area code, region and country
// Parameters: Area code, Country, Region
// Возврат value: Area or empty reference
//-----------------------------------------------------------------------------
Функция cmGetAreaByCode(pAreaCode, pCountry, pRegion) Экспорт
	vArea = Справочники.Районы.EmptyRef();
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	Районы.Ref AS Area
	|FROM
	|	Catalog.Районы AS Areas
	|WHERE
	|	Районы.Code = &qAreaCode
	|	AND Районы.Country = &qCountry
	|	AND Районы.Region = &qRegion
	|	AND Районы.DeletionMark = FALSE";
	vQry.SetParameter("qAreaCode", pAreaCode);
	vQry.SetParameter("qCountry", pCountry);
	vQry.SetParameter("qRegion", pRegion);
	vList = vQry.Execute().Unload();
	Для Each vListRow In vList Цикл
		vArea = vListRow.Area;
		Прервать;
	КонецЦикла;
	Возврат vArea;
КонецФункции //cmGetAreaByCode

//-----------------------------------------------------------------------------
// Description: Tries to find and return area (district) by area description, region and country
// Parameters: Area description, Country, Region
// Возврат value: Area or empty reference
//-----------------------------------------------------------------------------
Функция cmGetAreaByDescription(pAreaDescription, pCountry, pRegion) Экспорт
	vArea = Справочники.Районы.EmptyRef();
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	Районы.Ref AS Area
	|FROM
	|	Catalog.Районы AS Areas
	|WHERE
	|	Районы.Description = &qAreaDescription
	|	AND Районы.Country = &qCountry
	|	AND Районы.Region = &qRegion
	|	AND Районы.DeletionMark = FALSE";
	vQry.SetParameter("qAreaDescription", СокрЛП(pAreaDescription));
	vQry.SetParameter("qCountry", pCountry);
	vQry.SetParameter("qRegion", pRegion);
	vList = vQry.Execute().Unload();
	Для Each vListRow In vList Цикл
		vArea = vListRow.Area;
		Прервать;
	КонецЦикла;
	Возврат vArea;
КонецФункции //cmGetAreaByDescription

//-----------------------------------------------------------------------------
// Description: Tries to find and return city by city code, area, region and country
// Parameters: City code, Country, Region, Area
// Возврат value: City or empty reference
//-----------------------------------------------------------------------------
Функция cmGetCityByCode(pCityCode, pCountry, pRegion, pArea) Экспорт
	vCity = Справочники.Cities.EmptyRef();
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	Cities.Ref AS City
	|FROM
	|	Catalog.Cities AS Cities
	|WHERE
	|	Cities.Code = &qCityCode
	|	AND Cities.Country = &qCountry
	|	AND Cities.Region = &qRegion
	|	AND Cities.Area = &qArea
	|	AND Cities.DeletionMark = FALSE";
	vQry.SetParameter("qCityCode", pCityCode);
	vQry.SetParameter("qCountry", pCountry);
	vQry.SetParameter("qRegion", pRegion);
	vQry.SetParameter("qArea", pArea);
	vList = vQry.Execute().Unload();
	Для Each vListRow In vList Цикл
		vCity = vListRow.City;
		Прервать;
	КонецЦикла;
	Возврат vCity;
КонецФункции //cmGetCityByCode

//-----------------------------------------------------------------------------
// Description: Tries to find and return city by city description, area, region and country
// Parameters: City description, Country, Region, Area
// Возврат value: City or empty reference
//-----------------------------------------------------------------------------
Функция cmGetCityByDescription(pCityDescription, pCountry, pRegion, pArea) Экспорт
	vCity = Справочники.Cities.EmptyRef();
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	Cities.Ref AS City
	|FROM
	|	Catalog.Cities AS Cities
	|WHERE
	|	Cities.Description = &qCityDescription
	|	AND Cities.Country = &qCountry
	|	AND Cities.Region = &qRegion
	|	AND Cities.Area = &qArea
	|	AND Cities.DeletionMark = FALSE";
	vQry.SetParameter("qCityDescription", СокрЛП(pCityDescription));
	vQry.SetParameter("qCountry", pCountry);
	vQry.SetParameter("qRegion", pRegion);
	vQry.SetParameter("qArea", pArea);
	vList = vQry.Execute().Unload();
	Для Each vListRow In vList Цикл
		vCity = vListRow.City;
		Прервать;
	КонецЦикла;
	Возврат vCity;
КонецФункции //cmGetCityByDescription

//-----------------------------------------------------------------------------
// Description: Tries to find and return street by street code, city, area, region and country
// Parameters: Street code, Country, Region, Area, City
// Возврат value: Street or empty reference
//-----------------------------------------------------------------------------
Функция cmGetStreetByCode(pStreetCode, pCountry, pRegion, pArea, pCity) Экспорт
	vStreet = Справочники.Streets.EmptyRef();
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	Streets.Ref AS Street
	|FROM
	|	Catalog.Streets AS Streets
	|WHERE
	|	Streets.Code = &qStreetCode
	|	AND Streets.Country = &qCountry
	|	AND Streets.Region = &qRegion
	|	AND Streets.Area = &qArea
	|	AND Streets.City = &qCity
	|	AND Streets.DeletionMark = FALSE";
	vQry.SetParameter("qStreetCode", pStreetCode);
	vQry.SetParameter("qCountry", pCountry);
	vQry.SetParameter("qRegion", pRegion);
	vQry.SetParameter("qArea", pArea);
	vQry.SetParameter("qCity", pCity);
	vList = vQry.Execute().Unload();
	Для Each vListRow In vList Цикл
		vStreet = vListRow.Street;
		Прервать;
	КонецЦикла;
	Возврат vStreet;
КонецФункции //cmGetStreetByCode

//-----------------------------------------------------------------------------
// Description: Tries to find and return street by street description, city, area, region and country
// Parameters: Street description, Country, Region, Area, City
// Возврат value: Street or empty reference
//-----------------------------------------------------------------------------
Функция cmGetStreetByDescription(pStreetDescription, pCountry, pRegion, pArea, pCity) Экспорт
	vStreet = Справочники.Streets.EmptyRef();
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	Streets.Ref AS Street
	|FROM
	|	Catalog.Streets AS Streets
	|WHERE
	|	Streets.Description = &qStreetDescription
	|	AND Streets.Country = &qCountry
	|	AND Streets.Region = &qRegion
	|	AND Streets.Area = &qArea
	|	AND Streets.City = &qCity
	|	AND Streets.DeletionMark = FALSE";
	vQry.SetParameter("qStreetDescription", СокрЛП(pStreetDescription));
	vQry.SetParameter("qCountry", pCountry);
	vQry.SetParameter("qRegion", pRegion);
	vQry.SetParameter("qArea", pArea);
	vQry.SetParameter("qCity", pCity);
	vList = vQry.Execute().Unload();
	Для Each vListRow In vList Цикл
		vStreet = vListRow.Street;
		Прервать;
	КонецЦикла;
	Возврат vStreet;
КонецФункции //cmGetStreetByDescription

//-----------------------------------------------------------------------------
// Процедура is used to initalize data processor object attributes from the
// parameters saved in the data processor catalog item
//-----------------------------------------------------------------------------
Процедура cmLoadDataProcessorAttributes(pDPObject, pParameter = Неопределено) Экспорт
	// Rename input parameters to the name being used to 
	// address attributes in dynamic parameters calculation
	DPO = pDPObject;
	// Get reference to the DataProcessor catalog item
	vDP = DPO.DataProcessor;
	Если ЗначениеЗаполнено(vDP) Тогда
		// 1. Apply static parameters if are filled
		vStatic = vDP.StaticParameters.Get();
		Если vStatic <> Неопределено Тогда
			// Static parameters are simple structure
			FillPropertyValues(DPO, vStatic);
			// Load data processor tabular parts
			Для Each vTP In DPO.Metadata().TabularSections Цикл
				Попытка
					DPO[vTP.Name].Load(vStatic["TP_" + vTP.Name]);
				Исключение
				КонецПопытки;
			КонецЦикла;
		КонецЕсли;
		// 2. Apply current hotel
		Попытка
			DPO.Гостиница = ПараметрыСеанса.ТекущаяГостиница;
		Исключение
		КонецПопытки;
		// 3. Apply dynamic parameters if are filled
		// "Dynamic parameters" is piece of source code working with DPO variable attributes.
		// F.e. the following sentence will be executed smoothly:
		// "DPO.PeriodFrom = BegOfDay(CurrentDate());"
		// PARM input parameter also could be used in calculations and could be of any type. 
		// F.e. it could be used to set up current Гостиница in the following example code:
		// "DPO.Гостиница = PARM;"
		vDynamic = СокрЛП(vDP.DynamicParameters);
		Если НЕ ПустаяСтрока(vDynamic) Тогда
			Execute(vDynamic);
		КонецЕсли;
		// 4. Call default attributes initialization procedure if static parameters were not set 
		Если vStatic = Неопределено Тогда
			// Fill attributes with default values
			DPO.pmFillAttributesWithDefaultValues();
		КонецЕсли;
	Иначе
		// Fill attributes with default values
		DPO.pmFillAttributesWithDefaultValues();
	КонецЕсли;
КонецПроцедуры //cmLoadDataProcessorAttributes

//-----------------------------------------------------------------------------
// Процедура is used to initalize report object attributes from the
// parameters saved in the report catalog item
//-----------------------------------------------------------------------------
Процедура cmLoadReportAttributes(pRepObject, pParameter = Неопределено) Экспорт
	// Rename input parameters to the name being used to 
	// address attributes in dynamic parameters calculation
	REP = pRepObject;

	// Initialize report builder
	Попытка
		REP.pmInitializeReportBuilder();
	Исключение
	КонецПопытки;
	// Get reference to the Report catalog item
	vRep = REP.Report;
	Если ЗначениеЗаполнено(vRep) Тогда
		// 1. Apply static parameters if are filled
		vStatic = vRep.StaticParameters.Get();
		Если vStatic <> Неопределено Тогда
			// Static parameters are simple structure
			FillPropertyValues(REP, vStatic);
			// Load report builder settings
			Попытка
				Если vStatic.ReportBuilderSettings <> Неопределено Тогда
					REP.ReportBuilder.SetSettings(vStatic.ReportBuilderSettings, Истина, Истина, Истина, Истина, Истина);
				КонецЕсли;
			Исключение
			КонецПопытки;
		КонецЕсли;
		// 2. Apply current hotel
		Попытка
			REP.Гостиница = ПараметрыСеанса.ТекущаяГостиница;
		Исключение
		КонецПопытки;
		// 3. Apply dynamic parameters if are filled
		// "Dynamic parameters" is piece of source code working with REP variable attributes.
		// F.e. the following sentence will be executed smoothly:
		// "REP.PeriodFrom = BegOfDay(CurrentDate());"
		// PARM input parameter also could be used in calculations and could be of any type. 
		// F.e. it could be used to set up current Гостиница in the following example code:
		// "REP.Гостиница = PARM;"
		vDynamic = СокрЛП(vRep.DynamicParameters);
		Если НЕ ПустаяСтрока(vDynamic) Тогда
			Execute(vDynamic);
		КонецЕсли;
		// 4. Call default attributes initialization procedure if static parameters were not set 
		Если vStatic = Неопределено Тогда
			// Fill attributes with default values
			REP.pmFillAttributesWithDefaultValues();
		КонецЕсли;
		// 5. Fill report builder header text with the report description
		Попытка
			Если ПустаяСтрока(vRep.ReportHeaderText) Тогда
				REP.ReportBuilder.HeaderText = vRep.Description;
			Иначе
				REP.ReportBuilder.HeaderText = vRep.ReportHeaderText;
			КонецЕсли;
		Исключение
		КонецПопытки;
	Иначе
		// Fill attributes with default values
		REP.pmFillAttributesWithDefaultValues();
	КонецЕсли;
КонецПроцедуры //cmLoadReportAttributes

//-----------------------------------------------------------------------------
// Description: Applies report builder settings saved in the report catalog item
//              to the report builder object
// Parameters: Report catalog item object
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmApplyReportBuilderSettings(pRepObject) Экспорт
	// Get reference to the Report catalog item
	vRep = pRepObject.Report;
	Если ЗначениеЗаполнено(vRep) Тогда
		vStatic = vRep.StaticParameters.Get();
		Если vStatic <> Неопределено Тогда
			// Load report builder settings
			Попытка
				Если vStatic.ReportBuilderSettings <> Неопределено Тогда
					pRepObject.ReportBuilder.SetSettings(vStatic.ReportBuilderSettings, Истина, Истина, Истина, Истина, Истина);
				КонецЕсли;
			Исключение
			КонецПопытки;
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры //cmApplyReportBuilderSettings

//-----------------------------------------------------------------------------
// Description: Saves current data processor object attributes to the data
//              processor catalog item
// Parameters: Data processor object
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmSaveDataProcessorAttributes(pDPObject) Экспорт
	// Get reference to the DataProcessor catalog item
	vDP = pDPObject.DataProcessor;
	Если ЗначениеЗаполнено(vDP) Тогда
		vDPObj = vDP.GetObject();
		// Initialize structure of the static parameters
		vStatic = Новый Structure();
		Для Each vAttr In pDPObject.Metadata().Attributes Цикл
			Если vAttr.Name <> "DataProcessor" Тогда
				vStatic.Вставить(vAttr.Name);
			КонецЕсли;
		КонецЦикла;
		// Fill structure from the data processor object attributes
		FillPropertyValues(vStatic, pDPObject);
		// Save all tabular parts
		Для Each vTP In pDPObject.Metadata().TabularSections Цикл
			vStatic.Вставить("TP_" + vTP.Name, pDPObject[vTP.Name].Unload());
		КонецЦикла;
		// Save structure in the value storage of the data processor catalog item
		vStaticVS = Новый ValueStorage(vStatic);
		vDPObj.StaticParameters = vStaticVS;
		vDPObj.Write();
		// Dynamic parameters could be changed only from the 
		// Data processor catalog item form
	КонецЕсли;
КонецПроцедуры //cmSaveDataProcessorAttributes

//-----------------------------------------------------------------------------
// Description: Saves current report object attributes to the report catalog item
// Parameters: Report object
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmSaveReportAttributes(pRepObject) Экспорт
	// Get reference to the Report catalog item
	vRep = pRepObject.Report;
	Если ЗначениеЗаполнено(vRep) Тогда
		vRepObj = vRep.GetObject();
		// Initialize structure of the static parameters
		vStatic = Новый Structure();
		Для Each vAttr In pRepObject.Metadata().Attributes Цикл
			Если vAttr.Name <> "Report" And vAttr.Name <> "ReportBuilder" Тогда
				vStatic.Вставить(vAttr.Name);
			КонецЕсли;
		КонецЦикла;
		// Fill structure from the report object attributes
		FillPropertyValues(vStatic, pRepObject);
		// Save report builder settings
		Попытка
			Если pRepObject.ReportBuilder <> Неопределено Тогда
				vStatic.Вставить("ReportBuilderSettings", pRepObject.ReportBuilder.GetSettings(Истина, Истина, Истина, Истина, Истина));
			КонецЕсли;
		Исключение
		КонецПопытки;
		// Save structure in the value storage of the report catalog item
		vStaticVS = Новый ValueStorage(vStatic);
		vRepObj.StaticParameters = vStaticVS;
		vRepObj.Write();
		// Dynamic parameters could be changed only from the 
		// report catalog item form
	КонецЕсли;
КонецПроцедуры //cmSaveReportAttributes

//-----------------------------------------------------------------------------
// Description: Returns structure of data processor object attributes converted to the
//              value storage to save it to the data processor catalog item
// Parameters: Data processor object
// Возврат value: Value storage from the structure of data processor object attributes 
//-----------------------------------------------------------------------------
Функция cmGetDataProcessorStaticParametersValue(pObject) Экспорт
	// Initialize structure of the static parameters
	vStatic = Новый Structure();
	Для Each vAttr In pObject.Metadata().Attributes Цикл
		Если vAttr.Name <> "DataProcessor" Тогда
			vStatic.Вставить(vAttr.Name);
		КонецЕсли;
	КонецЦикла;
	// Fill structure from the report object attributes
	FillPropertyValues(vStatic, pObject);
	// Create value storage
	Возврат Новый ValueStorage(vStatic);
КонецФункции //cmGetDataProcessorStaticParametersValue

//-----------------------------------------------------------------------------
// Description: Returns structure of report object attributes converted to the
//              value storage to save it to the report catalog item
// Parameters: Report object
// Возврат value: Value storage from the structure of report object attributes 
//-----------------------------------------------------------------------------
Функция cmGetReportStaticParametersValue(pObject) Экспорт
	// Initialize structure of the static parameters
	vStatic = Новый Structure();
	Для Each vAttr In pObject.Metadata().Attributes Цикл
		Если vAttr.Name <> "Report" And vAttr.Name <> "ReportBuilder" Тогда
			vStatic.Вставить(vAttr.Name);
		КонецЕсли;
	КонецЦикла;
	// Fill structure from the report object attributes
	FillPropertyValues(vStatic, pObject);
	// Save report builder settings
	Попытка
		Если pObject.ReportBuilder <> Неопределено Тогда
			vStatic.Вставить("ReportBuilderSettings", pObject.ReportBuilder.GetSettings(Истина, Истина, Истина, Истина, Истина));
		КонецЕсли;
	Исключение
	КонецПопытки;
	// Create value storage
	Возврат Новый ValueStorage(vStatic);
КонецФункции //cmGetReportStaticParametersValue

//-----------------------------------------------------------------------------
// Description: Returns list of reports based on reports catalog folder or item
// Parameters: Report catalog folder or item
// Возврат value: Value table with report catalog items 
//-----------------------------------------------------------------------------
Функция cmGetListOfReportsToRun(pReport) Экспорт
	vReps = Новый ValueTable();
	vReps.Columns.Add("Report", cmGetCatalogTypeDescription("Отчеты")); 
	// Fill list of reports to run	
	Если pReport.IsFolder Тогда
		vQry = Новый Query();
		vQry.Text = 
		"SELECT
		|	Отчеты.Ref AS Report
		|FROM
		|	Catalog.Отчеты AS Отчеты
		|WHERE
		|	Отчеты.Ref IN HIERARCHY (&qRepFolder)
		|	AND Отчеты.DeletionMark = FALSE
		|	AND Отчеты.IsFolder = FALSE
		|ORDER BY
		|	Отчеты.ПорядокСортировки";
		vQry.SetParameter("qRepFolder", pReport);
		vReps = vQry.Execute().Unload();
	Иначе
		Если НЕ pReport.ПометкаУдаления Тогда
			vRepRow = vReps.Add();
			vRepRow.Report = pReport;
		    vReps = vRepRow;
		Иначе
			ВызватьИсключение "Попытка выполнения помеченного на удаление отчета " + pReport + ". Выполнение невозможно!";
		КонецЕсли;
	КонецЕсли;
	Возврат vReps;
КонецФункции //cmGetListOfReportsToRun

//-----------------------------------------------------------------------------
// Description: Returns report object based on report catalog item
// Parameters: Report catalog item reference
// Возврат value: Report object
//-----------------------------------------------------------------------------
Функция cmBuildReportObject(pRep) Экспорт
	vRepObj = Неопределено;
	Если НЕ pRep.IsExternal Тогда
		vRepObj = Отчеты[СокрЛП(pRep.Report)].Создать();
	Иначе
		Если pRep.Report.ExternalProcessingType = Перечисления.ExternalProcessingTypes.Report Тогда
			vRepObj = cmGetExternalDataProcessorObject(pRep.Report);
		ИначеЕсли pRep.Report.ExternalProcessingType = Перечисления.ExternalProcessingTypes.Algorithm Тогда
			vAlgorithm = СокрЛП(pRep.Report.Algorithm);
			Execute(vAlgorithm);
		Иначе
			ВызватьИсключение "Попытка выполнения внешнего отчета с типом отличным от ""Отчет"" и ""Алгоритм"". Выполнение невозможно!";
		КонецЕсли;
	КонецЕсли;
	Возврат vRepObj;
КонецФункции //cmBuildReportObject

//-----------------------------------------------------------------------------
// Description: Generates reports catalog item report
// Parameters: Reports catalog item reference, Report parameter, 
//             Whether to generate report on form open or show empty report
// Возврат value: Истина if report was successfully generated, Ложь if exception was raised
//-----------------------------------------------------------------------------
Функция cmGenerateReport(pReport, pParameter = Неопределено, pGenerateOnOpen = Истина) Экспорт
	Попытка
		// Initialize list of reports to run
		vReps = cmGetListOfReportsToRun(pReport);
		// Run each report from the list
		Для Each vRepRow In vReps Цикл
			// Check user rights to open report
			Если НЕ cmCheckUserRightsToOpenReport(vRepRow.Report) Тогда
				ВызватьИсключение "У вас нет прав на формирование отчета: " + vRepRow.Report.Description + "!";
			КонецЕсли;
			vRepObj = cmBuildReportObject(vRepRow.Report);
			Если vRepObj <> Неопределено Тогда
				// Initialize report settings
				Попытка
					// Fill reference to the report catalog item
					vRepObj.Report = vRepRow.Report;
					// Load report catalog item attributes
					vRepObj.pmLoadReportAttributes(pParameter);
					// Open report's default form
					vRepFrm = vRepObj.ПолучитьФорму();
					vRepFrm.GenerateOnFormOpen = pGenerateOnOpen;
					vRepFrm.Open();
				Исключение
					// Open report's default form
					vRepFrm = vRepObj.ПолучитьФорму();
					vRepFrm.Open();
				КонецПопытки;
			КонецЕсли;
		КонецЦикла;
		Возврат Истина;
	Исключение
		vErrorDescription = ErrorDescription();
		vMessage = "Ошибка выполнения отчета " + pReport.Description + ПараметрыСеанса.ТекЛокализация + "! Описание ошибки:" +vErrorDescription;
		WriteLogEvent("Отчет.Сформировать", EventLogLevel.Warning, Metadata.Справочники.Отчеты, pReport, vMessage);
		Message(vMessage, MessageStatus.Attention);
		Возврат Ложь;
	КонецПопытки;
КонецФункции //cmGenerateReport

//-----------------------------------------------------------------------------
// Description: Builds list of reports catalog items by string key value and generates them all. 
// Parameters: String report key value 
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmGenerateReportsByKey(pKey) Экспорт
	// Get catalog items by key
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	Отчеты.Ref AS Report
	|FROM
	|	Catalog.Отчеты AS Отчеты
	|WHERE
	|	Отчеты.Key = &qKey
	|	AND Отчеты.DeletionMark = FALSE
	|
	|ORDER BY
	|	Отчеты.ПорядокСортировки,
	|	Отчеты.Code";
	vQry.SetParameter("qKey", pKey);
	vRepList = vQry.Execute().Unload();
	// Run all retrieved reports
	Для Each vRepRow In vRepList Цикл
		vRepRef = vRepRow.Report;
		cmGenerateReport(vRepRef);
	КонецЦикла;
КонецПроцедуры //cmGenerateReportsByKey

//-----------------------------------------------------------------------------
// Description: Builds list of data processors catalog items for the data processors
//              catalog folder or item given
// Parameters: Data processors catalog folder or item
// Возврат value: Value table with list of data processors catalog items
//-----------------------------------------------------------------------------
Функция cmGetListOfDataProcessorsToRun(pDataProcessor) Экспорт
	vDPs = Новый ValueTable();
	vDPs.Columns.Add("DataProcessor", cmGetCatalogTypeDescription("Обработки")); 
	// Fill list of data processors to run	
	Если pDataProcessor.IsFolder Тогда
		vQry = Новый Query();
		vQry.Text = 
		"SELECT
		|	Обработки.Ref AS DataProcessor
		|FROM
		|	Catalog.Обработки AS Обработки
		|WHERE
		|	Обработки.Ref IN HIERARCHY(&qDPFolder)
		|	AND Обработки.DeletionMark = FALSE
		|	AND Обработки.IsFolder = FALSE
		|
		|ORDER BY
		|	Обработки.ПорядокСортировки,
		|	Обработки.Code";
		vQry.SetParameter("qDPFolder", pDataProcessor);
		vDPs = vQry.Execute().Unload();
	Иначе
		Если НЕ pDataProcessor.DeletionMark Тогда
			vDPRow = vDPs.Add();
			vDPRow.DataProcessor = pDataProcessor;
		Иначе
			ВызватьИсключение "Попытка выполнения помеченной на удаление процедуры " + pDataProcessor + ". Выполнение невозможно!";
		КонецЕсли;
	КонецЕсли;
	Возврат vDPs;
КонецФункции //cmGetListOfDataProcessorsToRun 

//-----------------------------------------------------------------------------
// Описание: создает обработчик данных объекта из данных процессора элемента каталога
// Параметры: процессоры элемент каталога данных
// Возвращаемое значение: объект-обработчик данных
//-----------------------------------------------------------------------------
Функция cmBuildDataProcessorObject(pDP) Экспорт
	vDPObj = Неопределено;
	Если НЕ pDP.IsExternal Тогда
		vDPObj = Обработки[СокрЛП(pDP.Processing)].Create();
	Иначе
		Если pDP.Processing.ExternalProcessingType = Перечисления.ExternalProcessingTypes.DataProcessor Тогда
			vDPObj = cmGetExternalDataProcessorObject(pDP.Processing);
		ИначеЕсли pDP.Processing.ExternalProcessingType = Перечисления.ExternalProcessingTypes.Algorithm Тогда
			vAlgorithm = СокрЛП(pDP.Processing.Algorithm);
			Execute(vAlgorithm);
		Иначе
			ВызватьИсключение NStr("ru='Попытка выполнения внешней обработки с типом отличным от ""Обработка"" и ""Алгоритм"". Выполнение невозможно!';
			           |de='Versuch, die externe Bearbeitung mit einem anderen Typ als ""Bearbeitung"" und ""Algorithmus"" auszuführen. Ausführung ist nicht möglich!';
					   |en='Attempt to run external data processor with type different then ""Data processor"" and ""Algorithm"". Failed to proceed!'");
		КонецЕсли;
	КонецЕсли;
	Возврат vDPObj;
КонецФункции //cmBuildDataProcessorObject

//-----------------------------------------------------------------------------
// Description: Builds list of data processors available in the program. 
//              List includes data processors with DataProcessor attribute available only 
// Parameters: None
// Возврат value: Value list of data processor names
//-----------------------------------------------------------------------------
Функция cmFillDataProcessorsList() Экспорт
	vDPList = Новый СписокЗначений();
	Для Each vDPMetadata In Metadata.Обработки Цикл
		// Check that DataProcessor attribute exists
		vFound = Ложь;
		Для Each vDPAttr In vDPMetadata.Attributes Цикл
			Если vDPAttr.Name = "DataProcessor" Тогда
				vFound = Истина;
				Прервать;
			КонецЕсли;
		КонецЦикла;
		Если vFound Тогда
			vDPList.Add(vDPMetadata.Name, vDPMetadata.Name + " - " + vDPMetadata.Presentation());
		КонецЕсли;
	КонецЦикла;
	Возврат vDPList;
КонецФункции //cmFillDataProcessorsList

//-----------------------------------------------------------------------------
// Description: Builds list of reports available in the program. 
//              List includes reports with Report attribute available only 
// Parameters: None
// Возврат value: Value list of report names
//-----------------------------------------------------------------------------
Функция cmFillReportsList() Экспорт
	vRepList = Новый СписокЗначений();
	Для Each vRepMetadata In Metadata.Отчеты Цикл
		// Check that Report attribute exists
		vFound = Ложь;
		Для Each vRepAttr In vRepMetadata.Attributes Цикл
			Если vRepAttr.Name = "Report" Тогда
				vFound = Истина;
				Прервать;
			КонецЕсли;
		КонецЦикла;
		Если vFound Тогда
			vRepList.Add(vRepMetadata.Name, vRepMetadata.Name + " - " + vRepMetadata.Presentation());
		КонецЕсли;
	КонецЦикла;
	Возврат vRepList;
КонецФункции //cmFillReportsList

//-----------------------------------------------------------------------------
// Description: Builds list of catalogs available in the program. 
//              List includes all catalogs
// Parameters: None
// Возврат value: Value list of catalog names
//-----------------------------------------------------------------------------
Функция cmFillСправочникиList() Экспорт
	vCatList = Новый СписокЗначений();
	Для Each vCatMetadata In Metadata.Справочники Цикл
		vCatList.Add(vCatMetadata.Name, vCatMetadata.Name + " - " + vCatMetadata.Presentation());
	КонецЦикла;
	Возврат vCatList;
КонецФункции //cmFillСправочникиList

//-----------------------------------------------------------------------------
// Description: Returns SMTP authentication mode based on enum value
// Parameters: SMTP authentication types enum item
// Возврат value: SMTP authentication mode
//-----------------------------------------------------------------------------
Функция cmGetSMTPAuthentication(pSMTPAuthentication) Экспорт
	Если ЗначениеЗаполнено(pSMTPAuthentication) Тогда
		Если pSMTPAuthentication = Перечисления.SMTPAuthenticationTypes.CramMD5 Тогда
			Возврат SMTPAuthenticationMode.CramMD5;
		ИначеЕсли pSMTPAuthentication = Перечисления.SMTPAuthenticationTypes.Login Тогда
			Возврат SMTPAuthenticationMode.Login;
		ИначеЕсли pSMTPAuthentication = Перечисления.SMTPAuthenticationTypes.Plain Тогда
			Возврат SMTPAuthenticationMode.Plain;
		ИначеЕсли pSMTPAuthentication = Перечисления.SMTPAuthenticationTypes.None Тогда
			Возврат SMTPAuthenticationMode.None;
		ИначеЕсли pSMTPAuthentication = Перечисления.SMTPAuthenticationTypes.Default Тогда
			Возврат SMTPAuthenticationMode.Default;
		Иначе
			Возврат SMTPAuthenticationMode.Default;
		КонецЕсли;
	Иначе
		Возврат SMTPAuthenticationMode.Default;
	КонецЕсли;
КонецФункции //cmGetSMTPAuthentication

//-----------------------------------------------------------------------------
// Description: Returns POP3 authentication mode based on enum value
// Parameters: POP3 authentication types enum item
// Возврат value: POP3 authentication mode
//-----------------------------------------------------------------------------
Функция cmGetPOP3Authentication(pPOP3Authentication) Экспорт
	Если ЗначениеЗаполнено(pPOP3Authentication) Тогда
		Если pPOP3Authentication = Перечисления.POP3AuthenticationTypes.CramMD5 Тогда
			Возврат POP3AuthenticationMode.CramMD5;
		ИначеЕсли pPOP3Authentication = Перечисления.POP3AuthenticationTypes.APOP Тогда
			Возврат POP3AuthenticationMode.APOP;
		ИначеЕсли pPOP3Authentication = Перечисления.POP3AuthenticationTypes.General Тогда
			Возврат POP3AuthenticationMode.General;
		Иначе
			Возврат POP3AuthenticationMode.General;
		КонецЕсли;
	Иначе
		Возврат POP3AuthenticationMode.General;
	КонецЕсли;
КонецФункции //cmGetSMTPAuthentication

//-----------------------------------------------------------------------------
// Description: Returns left part of the report attribute name before point char
// Parameters: Full report attribute name
// Возврат value: Report attribute root name
//-----------------------------------------------------------------------------
Функция cmGetReportAttributeRootName(pName) Экспорт
	vName = СокрЛП(pName);
	vPointPos = Find(vName, ".");
	Если vPointPos > 0 Тогда
		Если vPointPos > 1 Тогда
			Возврат Лев(vName, vPointPos-1);
		Иначе
			Возврат vName;
		КонецЕсли;
	Иначе
		Возврат vName;
	КонецЕсли;
КонецФункции //cmGetReportAttributeRootName

//-----------------------------------------------------------------------------
// Description: Fill report builder field presentations from the report template
// Parameters: Report object
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmFillReportAttributesPresentations(pRepObj) Экспорт
	vTemplate = pRepObj.GetTemplate("ReportTemplate");
	vExtTemplate = cmReadExternalSpreadsheetDocumentTemplate(pRepObj.Report);
	Если vExtTemplate <> Неопределено Тогда
		vTemplate = vExtTemplate;
	КонецЕсли;
	Для Each vAttr In pRepObj.ReportBuilder.AvailableFields Цикл
		vAttrRange = vTemplate.Районы.Find(vAttr.Name);
		Если vAttrRange <> Неопределено Тогда
			vAttr.Presentation = СокрЛП(vAttrRange.Text);
		КонецЕсли;
	КонецЦикла;
	Для Each vAttr In pRepObj.ReportBuilder.SelectedFields Цикл
		vAttrRange = vTemplate.Районы.Find(vAttr.Name);
		Если vAttrRange <> Неопределено Тогда
			vAttr.Presentation = СокрЛП(vAttrRange.Text);
		КонецЕсли;
	КонецЦикла;
	Для Each vAttr In pRepObj.ReportBuilder.RowDimensions Цикл
		vAttrRange = vTemplate.Районы.Find(vAttr.Name);
		Если vAttrRange <> Неопределено Тогда
			vAttr.Presentation = СокрЛП(vAttrRange.Text);
		КонецЕсли;
	КонецЦикла;
	Для Each vAttr In pRepObj.ReportBuilder.ColumnDimensions Цикл
		vAttrRange = vTemplate.Районы.Find(vAttr.Name);
		Если vAttrRange <> Неопределено Тогда
			vAttr.Presentation = СокрЛП(vAttrRange.Text);
		КонецЕсли;
	КонецЦикла;
	Для Each vAttr In pRepObj.ReportBuilder.Order Цикл
		vAttrRange = vTemplate.Районы.Find(vAttr.Name);
		Если vAttrRange <> Неопределено Тогда
			vAttr.Presentation = СокрЛП(vAttrRange.Text);
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры //cmFillReportAttributesPresentations 

//-----------------------------------------------------------------------------
// Description: Replaces report query text with new one. Could be used to override 
//              report main query at the dynamic report parameter settings page
// Parameters: Report object, Новый query text
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmSetReportQueryText(pRepObj, pQueryText) Экспорт
	pRepObj.ReportBuilder.Text = pQueryText;
	pRepObj.ReportBuilder.FillSettings();
	cmFillReportAttributesPresentations(pRepObj);
	vStatic = pRepObj.Report.StaticParameters.Get();
	Если vStatic <> Неопределено Тогда
		Попытка
			Если vStatic.ReportBuilderSettings <> Неопределено Тогда
				pRepObj.ReportBuilder.SetSettings(vStatic.ReportBuilderSettings, Истина, Истина, Истина, Истина, Истина);
			КонецЕсли;
		Исключение
		КонецПопытки;
	КонецЕсли;
КонецПроцедуры //cmSetReportQueryText

//-----------------------------------------------------------------------------
// Description: Sets new report main query parameter value. Could be used after 
//              report main query was replaced 
// Parameters: Report object, Parameter name, Parameter value
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmSetReportParameter(prepObj, pParameterName, pParameterValue) Экспорт
	pRepObj.ReportBuilder.Parameters.Вставить(pParameterName, pParameterValue);
КонецПроцедуры //cmSetReportParameter

//-----------------------------------------------------------------------------
// Description: Returns report appearance template based on it's type
// Parameters: Report appearance template type
// Возврат value: Report appearance template
//-----------------------------------------------------------------------------
Функция cmGetAppearanceTemplate(pReportAppearanceTemplateType) Экспорт
	vTemplate = Неопределено;
	Попытка
		vTemplate = GetCommonTemplate("ReportAppearanceTemplate" + pReportAppearanceTemplateType.Metadata().EnumValues[Перечисления.ReportAppearanceTemplateTypes.IndexOf(pReportAppearanceTemplateType)].Name);
	Исключение
	КонецПопытки;
	Возврат vTemplate;
КонецФункции //cmGetAppearanceTemplate

//-----------------------------------------------------------------------------
// Description: Fills report page header text with hotel name and program name
// Parameters: Report spreadsheet
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmApplyReportHeader(pSpreadsheet) Экспорт
	// Add hotel name to the left report header
	pSpreadsheet.Header.LeftText = ?(ЗначениеЗаполнено(ПараметрыСеанса.ТекущаяГостиница), 
									 ПараметрыСеанса.ТекущаяГостиница.GetObject().pmGetHotelPrintName(ПараметрыСеанса.ТекЛокализация), "");
	// Add configuration name to the right report header
	pSpreadsheet.Header.RightText = СокрЛП(ПараметрыСеанса.ПредставлениеКонфигурации);
	// Set header text alignement
	pSpreadsheet.Header.VerticalAlign = VerticalAlign.Bottom;
	pSpreadsheet.Header.Enabled = Истина;
КонецПроцедуры //cmApplyReportHeader 

//-----------------------------------------------------------------------------
// Description: Fills report page footer text with report page number
// Parameters: Report spreadsheet
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmApplyReportFooter(pSpreadsheet) Экспорт
	// Add number of pages to the report footer
	pSpreadsheet.Footer.CenterText = NStr("en='Page ';ru='Страница ';de='Seite '") + "[&PageNumber]" + NStr("ru = ' из '; en = ' of '; de = ' von '") + "[&PagesTotal]";
	pSpreadsheet.Footer.VerticalAlign = VerticalAlign.Top;
	pSpreadsheet.Footer.Enabled = Истина;
КонецПроцедуры //cmApplyReportFooter

//-----------------------------------------------------------------------------
// Description: Hides report row groups for levels defined in report settings
// Parameters: Report object, Report spreadsheet control
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmShowRowGroupsLevel(pRepObj, pSpreadsheet) Экспорт
	Попытка 
		Если pRepObj.ReportColumnOverrides.Count() > 0 And pRepObj.ReportColumnOverrides.Columns.Count() > 0 Тогда
			c = pSpreadsheet.RowGroupLevelCount();
			i = pRepObj.ReportBuilder.RowDimensions.Count();
			Пока i > 0 Цикл
				i = i - 1;
				vAttr = pRepObj.ReportBuilder.RowDimensions.Get(i);
				vShowGroupClosed = Ложь;
				vOverrideRow = pRepObj.ReportColumnOverrides.Find(vAttr.Name, "ColumnName");
				Если vOverrideRow <> Неопределено Тогда
					Если pRepObj.ReportColumnOverrides.Columns.Find("ShowGroupClosed") <> Неопределено Тогда
						vShowGroupClosed = vOverrideRow.ShowGroupClosed;
					КонецЕсли;
				КонецЕсли;
				Если vShowGroupClosed Тогда
					r = 0;
					Для Each vGrpAttr In pRepObj.ReportBuilder.RowDimensions Цикл
						r = r + 1;
						Если vGrpAttr.Name = vAttr.Name Тогда
							Прервать;
						КонецЕсли;
						Если vGrpAttr.DimensionType = ReportBuilderDimensionType.Hierarchy Тогда
							r = r + 1;
						КонецЕсли;
					КонецЦикла;
					Если r <= c Тогда
						pSpreadsheet.ShowRowGroupLevel(r - 1);
					КонецЕсли;
				КонецЕсли;
			КонецЦикла;
		КонецЕсли;
	Исключение
	КонецПопытки;
КонецПроцедуры //cmShowRowGroupsLevel

//-----------------------------------------------------------------------------
// Description: Hides report column groups for levels defined in report settings
// Parameters: Report object, Report spreadsheet control
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmShowColumnGroupsLevel(pRepObj, pSpreadsheet) Экспорт
	Попытка 
		Если pRepObj.ReportColumnOverrides.Count() > 0 And pRepObj.ReportColumnOverrides.Columns.Count() > 0 Тогда
			c = pSpreadsheet.ColumnGroupLevelCount();
			i = pRepObj.ReportBuilder.ColumnDimensions.Count();
			Пока i > 0 Цикл
				i = i - 1;
				vAttr = pRepObj.ReportBuilder.ColumnDimensions.Get(i);
				vShowGroupClosed = Ложь;
				vOverrideRow = pRepObj.ReportColumnOverrides.Find(vAttr.Name, "ColumnName");
				Если vOverrideRow <> Неопределено Тогда
					Если pRepObj.ReportColumnOverrides.Columns.Find("ShowColumnGroupClosed") <> Неопределено Тогда
						vShowGroupClosed = vOverrideRow.ShowColumnGroupClosed;
					КонецЕсли;
				КонецЕсли;
				Если vShowGroupClosed Тогда
					r = 0;
					Для Each vGrpAttr In pRepObj.ReportBuilder.ColumnDimensions Цикл
						r = r + 1;
						Если vGrpAttr.Name = vAttr.Name Тогда
							Прервать;
						КонецЕсли;
						Если vGrpAttr.DimensionType = ReportBuilderDimensionType.Hierarchy Тогда
							r = r + 1;
						КонецЕсли;
					КонецЦикла;
					Если r <= c Тогда
						pSpreadsheet.ShowColumnGroupLevel(r - 1);
					КонецЕсли;
				КонецЕсли;
			КонецЦикла;
		КонецЕсли;
	Исключение
	КонецПопытки;
КонецПроцедуры //cmShowColumnGroupsLevel

//-----------------------------------------------------------------------------
// Description: Fills report header and footer, fixes report header
// Parameters: Report object, Report spreadsheet, Report template attributes structure
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmApplyReportAppearance(pRepObj, pSpreadsheet, pTemplateAttributes) Экспорт
	// Reset report appearance template
	pRepObj.ReportBuilder.AppearanceTemplate = Неопределено;
	// Fix report header horizontally
	Если pTemplateAttributes <> Неопределено Тогда
		Если НЕ pRepObj.ReportDoNotPutReportHeader And НЕ pRepObj.ReportDoNotPutTableHeader Тогда
			pSpreadsheet.FixedTop = pTemplateAttributes.TableHeaderBottom;
		КонецЕсли;
	КонецЕсли;
	// Report header
	Если НЕ pRepObj.ReportDoNotPutReportHeader Тогда
		cmApplyReportHeader(pSpreadsheet);
	КонецЕсли;
	// Report footer
	Если НЕ pRepObj.ReportDoNotPutReportFooter Тогда
		cmApplyReportFooter(pSpreadsheet);
	КонецЕсли;
	// Report groups
	cmShowRowGroupsLevel(pRepObj, pSpreadsheet);
	cmShowColumnGroupsLevel(pRepObj, pSpreadsheet);
КонецПроцедуры //cmApplyReportAppearance

//-----------------------------------------------------------------------------
// Description: Reformats report spreadsheet to the multicolumn view
// Parameters: Report object, Report spreadsheet
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmApplyReportMultiplePages(pRepObj, pSpreadsheet) Экспорт
	// Apply number of pages to be printed on the one paper sheet
	Если pRepObj.PerPage > 1 Тогда
		
		vTableHeight = pSpreadsheet.TableHeight;
		vReportArea = pSpreadsheet.Area(1, , vTableHeight);
		vReportArea.Ungroup();
		pSpreadsheet.ShowGroups = Ложь;
		vPages = Новый СписокЗначений();
		vProbeSpreadsheet = Новый SpreadsheetDocument();
		vProbeSpreadsheet.PrinterName = pSpreadsheet.PrinterName;
		vPageStart = 0;
		vTempSpreadsheet = Неопределено;
		i = 0;
		Пока i < pSpreadsheet.TableHeight Цикл
			Попытка
				
				vTempSpreadsheet = Новый SpreadsheetDocument();
				vReportArea = vTempSpreadsheet.Put(pSpreadsheet);
				Если (i + 2) < vTableHeight Тогда
					vTempSpreadsheet.DeleteArea(vTempSpreadsheet.Area(i + 2, , vTableHeight), SpreadsheetDocumentShiftType.Vertical);
				КонецЕсли;
				Если vPageStart > 0 Тогда
					vTempSpreadsheet.DeleteArea(vTempSpreadsheet.Area(1, , vPageStart), SpreadsheetDocumentShiftType.Vertical);
				Иначе
					vTempSpreadsheet.DeleteArea(vTempSpreadsheet.Area(1, , 5), SpreadsheetDocumentShiftType.Vertical);
				КонецЕсли;
				Если НЕ vProbeSpreadsheet.CheckPut(vTempSpreadsheet) Тогда
					vTempSpreadsheet.DeleteArea(vTempSpreadsheet.Area(vTempSpreadsheet.TableHeight, , vTempSpreadsheet.TableHeight), SpreadsheetDocumentShiftType.Vertical);
					vPages.Add(vTempSpreadsheet);
					vPageStart = i + 1;
				КонецЕсли;
			Исключение
				Возврат;
			КонецПопытки;
			i = i + 1;
		КонецЦикла;
		Если vTempSpreadsheet <> Неопределено Тогда
			Если vPages.Count() > 0 Тогда
				vPages.Add(vTempSpreadsheet);
			КонецЕсли;
		КонецЕсли;
		Если vPages.Count() > 1 Тогда
			vTargetSpreadsheet = Новый SpreadsheetDocument();
			pSpreadsheet.DeleteArea(pSpreadsheet.Area(6, , pSpreadsheet.TableHeight), SpreadsheetDocumentShiftType.Vertical);
			vTargetSpreadsheet.Put(pSpreadsheet);
			Для Each vPagesItem In vPages Цикл
				vPageSheet = vPagesItem.Value;
				vPageNumber = vPages.IndexOf(vPagesItem) + 1;
				Если vPageNumber = 1 Тогда
					vTargetSpreadsheet.Join(vPageSheet);
				ИначеЕсли vPageNumber > 1 And (vPageNumber - 1)/pRepObj.PerPage = Цел((vPageNumber - 1)/pRepObj.PerPage) Тогда
					vTargetSpreadsheet.Put(vPageSheet);
				Иначе
					vTargetSpreadsheet.Join(vPageSheet);
					// Set column width
					Для i = 1 По vPageSheet.TableWidth Цикл
						vSrcCol = vTargetSpreadsheet.Area(5, i, 5, i);
						vTgtCol = vTargetSpreadsheet.Area(5, vTargetSpreadsheet.TableWidth - vPageSheet.TableWidth + i, 5, vTargetSpreadsheet.TableWidth - vPageSheet.TableWidth + i);
						vTgtCol.ColumnWidth = vSrcCol.ColumnWidth;
					КонецЦикла;
				КонецЕсли;
			КонецЦикла;
			pSpreadsheet.Clear();
			pSpreadsheet.Put(vTargetSpreadsheet);
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры //cmApplyReportMultiplePages

//-----------------------------------------------------------------------------
// Description: Apply report print settings and do output other then on screen
// Parameters: Report object, Report spreadsheet, Default page orientation, 
//             Fit to page or not, Show report on screen or not, Default report name
// Возврат value: Истина if report has to be shown on screen, Ложь if not
//-----------------------------------------------------------------------------
Функция cmApplyReportPrintSettingsAndDoOutput(pRepObj, pSpreadsheet, pDefaultPageOrientation, pDefaultFitToPage = Истина, pOnScreen = Ложь, pDefaultReportName) Экспорт
	vOutputOnScreen = Истина;
	// Setup default attributes
	cmSetDefaultPrintFormSettings(pSpreadsheet, pDefaultPageOrientation, pDefaultFitToPage);
	// Check authorities
	cmSetSpreadsheetProtection(pSpreadsheet);
	// Get and fill workstation print form settings
	Если ЗначениеЗаполнено(ПараметрыСеанса.РабочееМесто) Тогда
		vWorkstationPrintSettings = ПараметрыСеанса.РабочееМесто.НастройкиПечатиРМ;
		Если ЗначениеЗаполнено(vWorkstationPrintSettings) Тогда
			// Попытка to find records for the current report
			vFilter = Новый Structure("Report, IsActive", pRepObj.Report, Истина);
			vPrintSettingsSet = vWorkstationPrintSettings.PrintFormsList.FindRows(vFilter);
			Если vPrintSettingsSet.Count() > 0 Тогда
				Для Each vPrintSettings In vPrintSettingsSet Цикл
					// Fill settings
					cmSetSpreadsheetSettings(pSpreadsheet, vPrintSettings);
					// Check printing direction
					Если vPrintSettings.PrintDirection <> Перечисления.PrintDirections.Screen And НЕ pOnScreen Тогда
						vName = cmGetPrintFormFileName(vPrintSettings, pDefaultReportName);
						cmDoSpreadsheetOutput(pSpreadsheet, vPrintSettings, vName);
						vOutputOnScreen = Ложь;
					КонецЕсли;
				КонецЦикла;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	Возврат vOutputOnScreen;
КонецФункции //cmApplyReportPrintSettingsAndDoOutput

//-----------------------------------------------------------------------------
// Description: Fills report filters presentation. It builds text list of filters 
//              applied to the report main query
// Parameters: Report object
// Возврат value: Text, description of filters applied to the report query
//-----------------------------------------------------------------------------
Функция cmGetReportFilterPresentation(pRepObj) Экспорт
	vFilterPresentation = "";
	vParametersPresentation = pRepObj.pmGetReportParametersPresentation();
	vFilterPresentation = vParametersPresentation;
	Для Each vFilter In pRepObj.ReportBuilder.Filter Цикл
		Если vFilter.Use Тогда
			vFilterPresentation = vFilterPresentation + String(vFilter) + ";" + Chars.LF;
		КонецЕсли;
	КонецЦикла;
	Возврат vFilterPresentation;
КонецФункции //cmGetReportFilterPresentation 

//-----------------------------------------------------------------------------
// Description: Returns Телефоны catalog item reference by text phone number
// Parameters: Text phone number, Гостиница
// Возврат value: Телефоны catalog item reference or Неопределено if nothing was found
//-----------------------------------------------------------------------------
Функция cmGetPhoneNumber(pPhoneNumber, pHotel) Экспорт
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	PhoneNumbers.Ref
	|FROM
	|	Catalog.PhoneNumbers AS PhoneNumbers
	|WHERE
	|	PhoneNumbers.IsFolder = FALSE
	|	AND PhoneNumbers.DeletionMark = FALSE
	|	AND PhoneNumbers.Owner = &qHotel
	|	AND PhoneNumbers.PhoneNumber = &qPhoneNumber";
	vQry.SetParameter("qHotel", pHotel);
	vQry.SetParameter("qPhoneNumber", pPhoneNumber);
	vList = vQry.Execute().Unload();
	
	vPhoneNumberRef = Неопределено;
	Если vList.Count() > 0 Тогда
		vRow = vList.Get(0);
		vPhoneNumberRef = vRow.Ref;
	КонецЕсли;
	
	Возврат vPhoneNumberRef;
КонецФункции //cmGetPhoneNumber

//-----------------------------------------------------------------------------
// Description: Returns door lock system driver data processor object for the 
//              door lock system switched to the current workstation
// Parameters: None
// Возврат value: Door lock system driver data processor object
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Описание: возвращает объект обработчика данных системного драйвера удостоверений личности для 
// системы удостоверений личности переключена на текущую рабочую станцию
// Параметры: Нет
// Значение Возврат: клиент удостоверения личности система драйвер устройства для обработки данных объекта
//-----------------------------------------------------------------------------
Функция мИдентКартСистемОбработка() Экспорт
	// Check parameters
	vWstn = ПараметрыСеанса.РабочееМесто;
	Если НЕ ЗначениеЗаполнено(vWstn) Тогда
		Возврат Неопределено;
	КонецЕсли;
	Если НЕ vWstn.ПодклСистемКартИдентф Тогда
		Возврат Неопределено;
	КонецЕсли;
	Если НЕ ЗначениеЗаполнено(vWstn.ПарамПодклСистемКартКлиентов) Тогда
		Возврат Неопределено;
	КонецЕсли;
	// Create data processor object
	Попытка
		vDataProcessorObj = Обработки.IdentityCardsProcessingDriver.Create();
		vDataProcessorObj.IdentityCardSystemParameters = vWstn.ПарамПодклСистемКартКлиентов;
		Возврат vDataProcessorObj;
	Исключение
		Возврат Неопределено;
	КонецПопытки;
КонецФункции //мИдентКартСистемОбработка

//-----------------------------------------------------------------------------
// Description: Returns barcodes scanner driver data processor object for the 
//              barcodes scanner switched to the current workstation
// Parameters: None
// Возврат value: Barcodes scanner driver data processor object
//-----------------------------------------------------------------------------
Функция cmGetBarcodesScannerDriverDataProcessor() Экспорт
	// Check parameters
	vWstn = ПараметрыСеанса.РабочееМесто;
	Если НЕ ЗначениеЗаполнено(vWstn) Тогда
		Возврат Неопределено;
	КонецЕсли;
	Если НЕ vWstn.ПодключенСканерШтрихКодов Тогда
		Возврат Неопределено;
	КонецЕсли;
	Если НЕ ЗначениеЗаполнено(vWstn.СканерПараметры) Тогда
		Возврат Неопределено;
	КонецЕсли;
	// Create data processor object
	Попытка
		vDataProcessorObj = Обработки.BarcodesScannerProcessingDriver.Create();
		vDataProcessorObj.СканерПараметры = vWstn.СканерПараметры;
		Возврат vDataProcessorObj;
	Исключение
		Возврат Неопределено;
	КонецПопытки;
КонецФункции //cmGetBarcodesScannerDriverDataProcessor
 
//-----------------------------------------------------------------------------
// Description: Returns images scanner driver data processor object for the 
//              images scanner switched to the current workstation
// Parameters: None
// Возврат value: Images scanner driver data processor object
//-----------------------------------------------------------------------------
Функция cmGetImagesScannerDriverDataProcessor() Экспорт
	// Check parameters
	vWstn = ПараметрыСеанса.РабочееМесто;
	Если НЕ ЗначениеЗаполнено(vWstn) Тогда
		Возврат Неопределено;
	КонецЕсли;
	Если НЕ vWstn.ПодключенСканерИзображений Тогда
		Возврат Неопределено;
	КонецЕсли;
	Если НЕ ЗначениеЗаполнено(vWstn.ImagesScannerConnectionParameters) Тогда
		Возврат Неопределено;
	КонецЕсли;
	// Create data processor object
	Попытка
		Если vWstn.ПараметрыСканераИзображений.ImageScannerDriver = Перечисления.ImageScannerDrivers.CognitiveScanifyAPI Тогда
			vDataProcessorObj = Обработки.CognitiveImageScannerDriver.Create();
			vDataProcessorObj.ПараметрыСканера = vWstn.ПараметрыСканераИзображений;
			Возврат vDataProcessorObj;
		ИначеЕсли vWstn.ПараметрыСканераИзображений.ImageScannerDriver = Перечисления.ImageScannerDrivers.AbbyyDocumentReaderSDKEngine ИЛИ vWstn.ПараметрыСканераИзображений.ImageScannerDriver = Перечисления.ImageScannerDrivers.AbbyyPassportReaderSDKEngine Тогда
			vDataProcessorObj = Обработки.AbbyyImageScannerDriver.Create();
			vDataProcessorObj.ПараметрыСканера = vWstn.ПараметрыСканераИзображений;
			Возврат vDataProcessorObj;
		ИначеЕсли vWstn.ПараметрыСканераИзображений.ImageScannerDriver = Перечисления.ImageScannerDrivers.Scan1C Тогда
			vDataProcessorObj = Обработки.ДрайверСканированияИзображений.Create();
			vDataProcessorObj.ПараметрыСканера = vWstn.ПараметрыСканераИзображений;
			Возврат vDataProcessorObj;
		Иначе
			Возврат Неопределено;
		КонецЕсли;
	Исключение
		Возврат Неопределено;
	КонецПопытки;
КонецФункции //cmGetImagesScannerDriverDataProcessor
 
//-----------------------------------------------------------------------------
// Description: Returns WEB camera images driver data processor object for the 
//              WEB camera switched to the current workstation
// Parameters: None
// Возврат value: WEB camera driver data processor object
//-----------------------------------------------------------------------------
Функция cmGetWEBCamDriverDataProcessor() Экспорт
			Возврат Неопределено;
	
КонецФункции //cmGetWEBCamDriverDataProcessor

//-----------------------------------------------------------------------------
// Description: Returns array of text lines built from the multi line text
// Parameters: Multi line text
// Возврат value: Array of text lines
//-----------------------------------------------------------------------------
Функция cmGetTextLinesArray(pTextStr) Экспорт
	vTxtArr = Новый Array;
	Если НЕ ПустаяСтрока(pTextStr) Тогда
		vTxt = Новый TextDocument();
		vTxt.SetText(pTextStr);
		Для i = 1 По vTxt.LineCount() Цикл
			vStr = vTxt.GetLine(i);
			vTxtArr.Add(vStr);
		КонецЦикла;
	КонецЕсли;
	Возврат vTxtArr;
КонецФункции //cmGetTextLinesArray

//-----------------------------------------------------------------------------
// Description: Tries to cast given text value to the number
// Parameters: Text number representation
// Возврат value: Число
//-----------------------------------------------------------------------------
Функция cmCastToNumber(pVal) Экспорт
	Попытка
		Если pVal = Неопределено Тогда
			Возврат 0;
		ИначеЕсли TypeOf(pVal) = Type("Число") Тогда
			Возврат pVal;
		Иначе
			Возврат Число(pVal);
		КонецЕсли;
	Исключение
		Попытка
			Возврат Число(cmGetDocumentNumberPresentation(pVal));
		Исключение
			Возврат 0;
		КонецПопытки;
	КонецПопытки;
КонецФункции //cmCastToNumber

//-----------------------------------------------------------------------------
// Description: Checks whether given two documents are bound by parent/child reference
// Parameters: Main document, document to check
// Возврат value: Истина if documents are bound to each other, false if not
//-----------------------------------------------------------------------------
Функция cmIsInDocumentChain(pDoc, pCheckDoc) Экспорт
	vIsInChain = Ложь;
	Если ЗначениеЗаполнено(pDoc) И ЗначениеЗаполнено(pCheckDoc) Тогда
		Если pDoc <> pCheckDoc Тогда
			vParentDoc = pDoc.ДокОснование;
			Пока ЗначениеЗаполнено(vParentDoc) Цикл
				Если vParentDoc = pCheckDoc Тогда
					vIsInChain = Истина;
					Прервать;
				КонецЕсли;
				vParentDoc = vParentDoc.ДокОснование;
			КонецЦикла;
		Иначе
			vIsInChain = Истина;
		КонецЕсли;
	КонецЕсли;
	Возврат vIsInChain;
КонецФункции //cmIsInDocumentChain

//-----------------------------------------------------------------------------
// Description: Returns value list of reports catalog items allowed to the given 
//              permission group
// Parameters: Permission groups catalog item
// Возврат value: Value list of reports 
//-----------------------------------------------------------------------------
Функция cmGetListOfAllowedReports(pPermissionGroup) Экспорт
	vQry = Новый Query();
	vQry.Text =
	"SELECT
	|	Отчеты.Ref
	|FROM
	|	Catalog.Отчеты AS Отчеты
	|WHERE
	|	(NOT Отчеты.DeletionMark)
	|	AND (NOT Отчеты.IsFolder)
	|	AND (Отчеты.PermissionGroup = &qPermissionGroup
	|			OR &qPermissionGroup IN
	|				(SELECT
	|					НаборПрав.PermissionGroup
	|				FROM
	|					Catalog.Отчеты.НаборПрав AS НаборПрав
	|				WHERE
	|					НаборПрав.Ref = Отчеты.Ref))
	|ORDER BY
	|	Отчеты.Code";
	vQry.SetParameter("qPermissionGroup", pPermissionGroup);
	vReports = vQry.Execute().Unload();
	vReportsList = Новый СписокЗначений();
	Если vReports.Count() > 0 Тогда
		vReportsList.LoadValues(vReports.UnloadColumn("Ref"));
	КонецЕсли;
	Возврат vReportsList;
КонецФункции //cmGetListOfAllowedReports

//-----------------------------------------------------------------------------
// Description: Returns value list of data processors catalog items allowed to 
//              the given permission group
// Parameters: Permission groups catalog item
// Возврат value: Value list of data processors
//-----------------------------------------------------------------------------
Функция cmGetListOfAllowedDataProcessors(pPermissionGroup) Экспорт
	vQry = Новый Query();
	vQry.Text =
	"SELECT
	|	Обработки.Ref
	|FROM
	|	Catalog.Обработки AS Обработки
	|WHERE
	|	(NOT Обработки.DeletionMark)
	|	AND (NOT Обработки.IsFolder)
	|	AND (Обработки.PermissionGroup = &qPermissionGroup
	|			OR &qPermissionGroup IN
	|				(SELECT
	|					НаборПрав.PermissionGroup
	|				FROM
	|					Catalog.Обработки.НаборПрав AS НаборПрав
	|				WHERE
	|					НаборПрав.Ref = Обработки.Ref))
	|ORDER BY
	|	Обработки.Code";
	vQry.SetParameter("qPermissionGroup", pPermissionGroup);
	vDPs = vQry.Execute().Unload();
	vDPsList = Новый СписокЗначений();
	Если vDPs.Count() > 0 Тогда
		vDPsList.LoadValues(vDPs.UnloadColumn("Ref"));
	КонецЕсли;
	Возврат vDPsList;
КонецФункции //cmGetListOfAllowedDataProcessors

//-----------------------------------------------------------------------------
// Description: Returns binary string representing positive decimal number
// Parameters: Decimal number
// Возврат value: Binary number presentation as string
//-----------------------------------------------------------------------------
Функция cmDec2Bin(pDec) Экспорт
	vBin = "";
	vDiv = pDec;
	Пока vDiv > 0 Цикл
		vIntDiv = Цел(vDiv/2);
		vBinChar = "0";
		Если vDiv <> vIntDiv*2 Тогда
			vBinChar = "1";
		КонецЕсли;
		vBin = vBinChar + vBin;
		vDiv = vIntDiv;
	КонецЦикла;
	Возврат vBin;
КонецФункции //cmDec2Bin

//-----------------------------------------------------------------------------
// Description: Returns positive decimal number representing binary string
// Parameters: Binary number presentation as string
// Возврат value: Decimal number
//-----------------------------------------------------------------------------
Функция cmBin2Dec(pBin) Экспорт
	vDec = 0;
	vLen = СтрДлина(pBin);
	Для i = 1 По vLen Цикл
		vDec = vDec + Число(Сред(pBin, i, 1)) * Pow(2, (vLen - i));
	КонецЦикла;
	Возврат vDec;
КонецФункции //cmBin2Dec

//-----------------------------------------------------------------------------
// Description: Returns hex string representing binary string
// Parameters: Binary number presentation as string
// Возврат value: Hex number presentation as string
//-----------------------------------------------------------------------------
Функция cmBin2Hex(Val pBin) Экспорт
	vHex = "";
	// Build conversion map
	vHexStruct = Новый Map();
	vHexStruct.Вставить("0000", "0");
	vHexStruct.Вставить("0001", "1");
	vHexStruct.Вставить("0010", "2");
	vHexStruct.Вставить("0011", "3");
	vHexStruct.Вставить("0100", "4");
	vHexStruct.Вставить("0101", "5");
	vHexStruct.Вставить("0110", "6");
	vHexStruct.Вставить("0111", "7");
	vHexStruct.Вставить("1000", "8");
	vHexStruct.Вставить("1001", "9");
	vHexStruct.Вставить("1010", "A");
	vHexStruct.Вставить("1011", "B");
	vHexStruct.Вставить("1100", "C");
	vHexStruct.Вставить("1101", "D");
	vHexStruct.Вставить("1110", "E");
	vHexStruct.Вставить("1111", "F");
	// Convert binary string to the length divided by 4
	vLen = СтрДлина(pBin);
	vNewLen = Цел(vLen/4);
	Если vNewLen <> vLen/4 Тогда
		vNewLen = vNewLen + 1;
	КонецЕсли;
	vNewLen = vNewLen*4;
	pBin = Формат(Число(pBin), "ND=" + vNewLen + "; NFD=0; NZ=; NLZ=; NG=");
	Для i = 1 По vNewLen/4 Цикл
		vHex = vHex + vHexStruct.Get(Сред(pBin, 1+4*(i-1), 4));
	КонецЦикла;
	Возврат vHex;
КонецФункции //cmBin2Hex

//-----------------------------------------------------------------------------
// Description: Returns decimal number of the hex char
// Parameters: Hex char as string
// Возврат value: Decimal number presentation as number
//-----------------------------------------------------------------------------
Функция cmHex2Dec(pHexChar) Экспорт
	Если pHexChar = "0" Тогда
		Возврат 0;
	ИначеЕсли pHexChar = "1" Тогда
		Возврат 1;
	ИначеЕсли pHexChar = "2" Тогда
		Возврат 2;
	ИначеЕсли pHexChar = "3" Тогда
		Возврат 3;
	ИначеЕсли pHexChar = "4" Тогда
		Возврат 4;
	ИначеЕсли pHexChar = "5" Тогда
		Возврат 5;
	ИначеЕсли pHexChar = "6" Тогда
		Возврат 6;
	ИначеЕсли pHexChar = "7" Тогда
		Возврат 7;
	ИначеЕсли pHexChar = "8" Тогда
		Возврат 8;
	ИначеЕсли pHexChar = "9" Тогда
		Возврат 9;
	ИначеЕсли ВРег(pHexChar) = "A" Тогда
		Возврат 10;
	ИначеЕсли ВРег(pHexChar) = "B" Тогда
		Возврат 11;
	ИначеЕсли ВРег(pHexChar) = "C" Тогда
		Возврат 12;
	ИначеЕсли ВРег(pHexChar) = "D" Тогда
		Возврат 13;
	ИначеЕсли ВРег(pHexChar) = "E" Тогда
		Возврат 14;
	ИначеЕсли ВРег(pHexChar) = "F" Тогда
		Возврат 15;
	КонецЕсли;
КонецФункции //cmHex2Dec

//-----------------------------------------------------------------------------
// Description: Returns null terminating string of given length
// Parameters: String to be encoded, Target string length
// Возврат value: Прав padded with blanks to the specified length null terminating string
//-----------------------------------------------------------------------------
Функция cmGetNullTerminatingString(pStr, pLen) Экспорт
	vStr = "";
	vStrLen = СтрДлина(pStr);
	Если vStrLen >= (pLen - 1) Тогда
		vStr = Лев(pStr, (pLen - 1)) + Символ(0);
	Иначе
		vStr = pStr;
		Для i = 1 По (pLen - vStrLen - 1) Цикл
			vStr = vStr + Символ(0);
		КонецЦикла;
		vStr = vStr + Символ(0);
	КонецЕсли;		
	Возврат vStr;
КонецФункции //cmGetNullTerminatingString

//-----------------------------------------------------------------------------
// Description: Returns map to get char index value for the appropriate hex byte
// Parameters: None
// Возврат value: Символ/Index Map
//-----------------------------------------------------------------------------
Функция cmGetByte2CharIndexMap() Экспорт
	vMap = Новый Map();
	
	vMap.Вставить("00", 0);
	vMap.Вставить("01", 1);
	vMap.Вставить("02", 2);
	vMap.Вставить("03", 3);
	vMap.Вставить("04", 4);
	vMap.Вставить("05", 5);
	vMap.Вставить("06", 6);
	vMap.Вставить("07", 7);
	vMap.Вставить("08", 8);
	vMap.Вставить("09", 9);
	vMap.Вставить("0A", 10);
	vMap.Вставить("0B", 11);
	vMap.Вставить("0C", 12);
	vMap.Вставить("0D", 13);
	vMap.Вставить("0E", 14);
	vMap.Вставить("0F", 15);
	
	vMap.Вставить("10", 16);
	vMap.Вставить("11", 17);
	vMap.Вставить("12", 18);
	vMap.Вставить("13", 19);
	vMap.Вставить("14", 20);
	vMap.Вставить("15", 21);
	vMap.Вставить("16", 22);
	vMap.Вставить("17", 23);
	vMap.Вставить("18", 24);
	vMap.Вставить("19", 25);
	vMap.Вставить("1A", 26);
	vMap.Вставить("1B", 27);
	vMap.Вставить("1C", 28);
	vMap.Вставить("1D", 29);
	vMap.Вставить("1E", 30);
	vMap.Вставить("1F", 31);
	
	vMap.Вставить("20", 32);
	vMap.Вставить("21", 33);
	vMap.Вставить("22", 34);
	vMap.Вставить("23", 35);
	vMap.Вставить("24", 36);
	vMap.Вставить("25", 37);
	vMap.Вставить("26", 38);
	vMap.Вставить("27", 39);
	vMap.Вставить("28", 40);
	vMap.Вставить("29", 41);
	vMap.Вставить("2A", 42);
	vMap.Вставить("2B", 43);
	vMap.Вставить("2C", 44);
	vMap.Вставить("2D", 45);
	vMap.Вставить("2E", 46);
	vMap.Вставить("2F", 47);
	
	vMap.Вставить("30", 48);
	vMap.Вставить("31", 49);
	vMap.Вставить("32", 50);
	vMap.Вставить("33", 51);
	vMap.Вставить("34", 52);
	vMap.Вставить("35", 53);
	vMap.Вставить("36", 54);
	vMap.Вставить("37", 55);
	vMap.Вставить("38", 56);
	vMap.Вставить("39", 57);
	vMap.Вставить("3A", 58);
	vMap.Вставить("3B", 59);
	vMap.Вставить("3C", 60);
	vMap.Вставить("3D", 61);
	vMap.Вставить("3E", 62);
	vMap.Вставить("3F", 63);
	
	vMap.Вставить("40", 64);
	vMap.Вставить("41", 65);
	vMap.Вставить("42", 66);
	vMap.Вставить("43", 67);
	vMap.Вставить("44", 68);
	vMap.Вставить("45", 69);
	vMap.Вставить("46", 70);
	vMap.Вставить("47", 71);
	vMap.Вставить("48", 72);
	vMap.Вставить("49", 73);
	vMap.Вставить("4A", 74);
	vMap.Вставить("4B", 75);
	vMap.Вставить("4C", 76);
	vMap.Вставить("4D", 77);
	vMap.Вставить("4E", 78);
	vMap.Вставить("4F", 79);
	
	vMap.Вставить("50", 80);
	vMap.Вставить("51", 81);
	vMap.Вставить("52", 82);
	vMap.Вставить("53", 83);
	vMap.Вставить("54", 84);
	vMap.Вставить("55", 85);
	vMap.Вставить("56", 86);
	vMap.Вставить("57", 87);
	vMap.Вставить("58", 88);
	vMap.Вставить("59", 89);
	vMap.Вставить("5A", 90);
	vMap.Вставить("5B", 91);
	vMap.Вставить("5C", 92);
	vMap.Вставить("5D", 93);
	vMap.Вставить("5E", 94);
	vMap.Вставить("5F", 95);
	
	vMap.Вставить("60", 96);
	vMap.Вставить("61", 97);
	vMap.Вставить("62", 98);
	vMap.Вставить("63", 99);
	vMap.Вставить("64", 100);
	vMap.Вставить("65", 101);
	vMap.Вставить("66", 102);
	vMap.Вставить("67", 103);
	vMap.Вставить("68", 104);
	vMap.Вставить("69", 105);
	vMap.Вставить("6A", 106);
	vMap.Вставить("6B", 107);
	vMap.Вставить("6C", 108);
	vMap.Вставить("6D", 109);
	vMap.Вставить("6E", 110);
	vMap.Вставить("6F", 111);
	
	vMap.Вставить("70", 112);
	vMap.Вставить("71", 113);
	vMap.Вставить("72", 114);
	vMap.Вставить("73", 115);
	vMap.Вставить("74", 116);
	vMap.Вставить("75", 117);
	vMap.Вставить("76", 118);
	vMap.Вставить("77", 119);
	vMap.Вставить("78", 120);
	vMap.Вставить("79", 121);
	vMap.Вставить("7A", 122);
	vMap.Вставить("7B", 123);
	vMap.Вставить("7C", 124);
	vMap.Вставить("7D", 125);
	vMap.Вставить("7E", 126);
	vMap.Вставить("7F", 127);
	
	vMap.Вставить("80", 1026);
	vMap.Вставить("81", 1027);
	vMap.Вставить("82", 8218);
	vMap.Вставить("83", 1107);
	vMap.Вставить("84", 8222);
	vMap.Вставить("85", 8230);
	vMap.Вставить("86", 8224);
	vMap.Вставить("87", 8225);
	vMap.Вставить("88", 8364);
	vMap.Вставить("89", 8240);
	vMap.Вставить("8A", 1033);
	vMap.Вставить("8B", 8249);
	vMap.Вставить("8C", 1034);
	vMap.Вставить("8D", 1036);
	vMap.Вставить("8E", 1035);
	vMap.Вставить("8F", 1039);
	
	vMap.Вставить("90", 1106);
	vMap.Вставить("91", 8216);
	vMap.Вставить("92", 8217);
	vMap.Вставить("93", 8220);
	vMap.Вставить("94", 8221);
	vMap.Вставить("95", 8226);
	vMap.Вставить("96", 8211);
	vMap.Вставить("97", 8212);
	vMap.Вставить("98", 152);
	vMap.Вставить("99", 8482);
	vMap.Вставить("9A", 1113);
	vMap.Вставить("9B", 8250);
	vMap.Вставить("9C", 1114);
	vMap.Вставить("9D", 1116);
	vMap.Вставить("9E", 1115);
	vMap.Вставить("9F", 1119);
	
	vMap.Вставить("A0", 160);
	vMap.Вставить("A1", 1038);
	vMap.Вставить("A2", 1118);
	vMap.Вставить("A3", 1032);
	vMap.Вставить("A4", 164);
	vMap.Вставить("A5", 1168);
	vMap.Вставить("A6", 166);
	vMap.Вставить("A7", 167);
	vMap.Вставить("A8", 1025);
	vMap.Вставить("A9", 169);
	vMap.Вставить("AA", 1028);
	vMap.Вставить("AB", 171);
	vMap.Вставить("AC", 172);
	vMap.Вставить("AD", 173);
	vMap.Вставить("AE", 174);
	vMap.Вставить("AF", 1031);
	
	vMap.Вставить("B0", 176);
	vMap.Вставить("B1", 177);
	vMap.Вставить("B2", 1030);
	vMap.Вставить("B3", 1110);
	vMap.Вставить("B4", 1169);
	vMap.Вставить("B5", 181);
	vMap.Вставить("B6", 182);
	vMap.Вставить("B7", 183);
	vMap.Вставить("B8", 1105);
	vMap.Вставить("B9", 8470);
	vMap.Вставить("BA", 1108);
	vMap.Вставить("BB", 187);
	vMap.Вставить("BC", 1112);
	vMap.Вставить("BD", 1029);
	vMap.Вставить("BE", 1109);
	vMap.Вставить("BF", 1111);
	
	vMap.Вставить("C0", 1040);
	vMap.Вставить("C1", 1041);
	vMap.Вставить("C2", 1042);
	vMap.Вставить("C3", 1043);
	vMap.Вставить("C4", 1044);
	vMap.Вставить("C5", 1045);
	vMap.Вставить("C6", 1046);
	vMap.Вставить("C7", 1047);
	vMap.Вставить("C8", 1048);
	vMap.Вставить("C9", 1049);
	vMap.Вставить("CA", 1050);
	vMap.Вставить("CB", 1051);
	vMap.Вставить("CC", 1052);
	vMap.Вставить("CD", 1053);
	vMap.Вставить("CE", 1054);
	vMap.Вставить("CF", 1055);
	
	vMap.Вставить("D0", 1056);
	vMap.Вставить("D1", 1057);
	vMap.Вставить("D2", 1058);
	vMap.Вставить("D3", 1059);
	vMap.Вставить("D4", 1060);
	vMap.Вставить("D5", 1061);
	vMap.Вставить("D6", 1062);
	vMap.Вставить("D7", 1063);
	vMap.Вставить("D8", 1064);
	vMap.Вставить("D9", 1065);
	vMap.Вставить("DA", 1066);
	vMap.Вставить("DB", 1067);
	vMap.Вставить("DC", 1068);
	vMap.Вставить("DD", 1069);
	vMap.Вставить("DE", 1070);
	vMap.Вставить("DF", 1071);
	
	vMap.Вставить("E0", 1072);
	vMap.Вставить("E1", 1073);
	vMap.Вставить("E2", 1074);
	vMap.Вставить("E3", 1075);
	vMap.Вставить("E4", 1076);
	vMap.Вставить("E5", 1077);
	vMap.Вставить("E6", 1078);
	vMap.Вставить("E7", 1079);
	vMap.Вставить("E8", 1080);
	vMap.Вставить("E9", 1081);
	vMap.Вставить("EA", 1082);
	vMap.Вставить("EB", 1083);
	vMap.Вставить("EC", 1084);
	vMap.Вставить("ED", 1085);
	vMap.Вставить("EE", 1086);
	vMap.Вставить("EF", 1087);
	
	vMap.Вставить("F0", 1088);
	vMap.Вставить("F1", 1089);
	vMap.Вставить("F2", 1090);
	vMap.Вставить("F3", 1091);
	vMap.Вставить("F4", 1092);
	vMap.Вставить("F5", 1093);
	vMap.Вставить("F6", 1094);
	vMap.Вставить("F7", 1095);
	vMap.Вставить("F8", 1096);
	vMap.Вставить("F9", 1097);
	vMap.Вставить("FA", 1098);
	vMap.Вставить("FB", 1099);
	vMap.Вставить("FC", 1100);
	vMap.Вставить("FD", 1101);
	vMap.Вставить("FE", 1102);
	vMap.Вставить("FF", 1103);
	
	Возврат vMap;
КонецФункции //cmGetByte2CharIndexMap

//-----------------------------------------------------------------------------
// Description: Returns binary string representing binary XOR with two binary numbers
// Parameters: First binary number presentation, Second binary number presentation
// Возврат value: XOR result binary presentation as string
//-----------------------------------------------------------------------------
Функция cmXOR(Val pBin1, Val pBin2) Экспорт
	vXOR = "";
	// Check that parameters length is the same
	vMaxLen = Max(СтрДлина(pBin1), СтрДлина(pBin2));
	pBin1 = Формат(Число(pBin1), "ND=" + vMaxLen + "; NFD=0; NZ=; NLZ=; NG=");
	pBin2 = Формат(Число(pBin2), "ND=" + vMaxLen + "; NFD=0; NZ=; NLZ=; NG=");
	// Цикл XOR
	Для i = 1 По vMaxLen Цикл
		vChar1 = Сред(pBin1, i, 1);
		vChar2 = Сред(pBin2, i, 1);
		Если vChar1 = vChar2 Тогда
			vXOR = vXOR + "0";
		Иначе
			vXOR = vXOR + "1";
		КонецЕсли;			
	КонецЦикла;
	Возврат vXOR;
КонецФункции //cmXOR

//-----------------------------------------------------------------------------
// Description: Calculates hex number returned as string representing 
//              longitudinal redundancy check sum for the input character string
// Parameters: Character string to process
// Возврат value: 2 LRC chars
//-----------------------------------------------------------------------------
Функция cmHexLRC(pStr) Экспорт
	vBinLRC = "00000000";
	Для i = 1 По СтрДлина(pStr) Цикл
		vBinLRC = cmXOR(vBinLRC, cmDec2Bin(CharCode(Сред(pStr, i, 1))));
	КонецЦикла;
	Возврат cmBin2Hex(vBinLRC);
КонецФункции //cmHexLRC

//-----------------------------------------------------------------------------
// Description: Checks longitudinal redundancy check sum for the input 
//              character string. Last two chars of string are assumed to be 
//              input check sum to be compared with new calculated one.
// Parameters: Character string to process
// Возврат value: Истина if check sum is right, false if not
//-----------------------------------------------------------------------------
Функция cmCheckHexLRC(pStr) Экспорт
	vNewHexLRC = cmHexLRC(Лев(pStr, СтрДлина(pStr)-2));
	vInpHexLRC = Прав(pStr, 2);
	Если vNewHexLRC = vInpHexLRC Тогда
		Возврат Истина;
	Иначе
		Возврат Ложь;
	КонецЕсли;
КонецФункции //cmCheckHexLRC

//-----------------------------------------------------------------------------
// Description: Always returns char(13) so far...
// Parameters: Character string to process
// Возврат value: Символ(13)
//-----------------------------------------------------------------------------
Функция cmCharLRC(pStr, pRet13 = Истина) Экспорт
	Если pRet13 Тогда
		Возврат Символ(13);
	Иначе
		vSeed = "00000000";
		Для i = 1 По СтрДлина(pStr) Цикл
			vChar = cmDec2Bin(CharCode(Сред(pStr, i, 1)));
			vSeed = cmXOR(vSeed, vChar);
		КонецЦикла;
		Возврат Символ(cmBin2Dec(vSeed));
	КонецЕсли;
КонецФункции //cmCharLRC

//-----------------------------------------------------------------------------
// Description: Checks longitudinal redundancy check sum for the input 
//              character string. Last one char of string is assumed to be 
//              input check sum to be compared with new calculated one.
// Parameters: Character string to process
// Возврат value: Истина if check sum is right, false if not
//-----------------------------------------------------------------------------
Функция cmCheckCharLRC(pStr, pRet13 = Истина) Экспорт
	vInpCharLRC = Прав(pStr, 1);
	vStr = Лев(pStr, СтрДлина(pStr) - 1);
	vNewCharLRC = cmCharLRC(vStr, pRet13);
	Если vNewCharLRC = Символ(13) ИЛИ vNewCharLRC = vInpCharLRC Тогда
		Возврат Истина;
	Иначе
		Возврат Ложь;
	КонецЕсли;
КонецФункции //cmCheckCharLRC

//-----------------------------------------------------------------------------
// Description: Calculates hex number returned as string representing simple 
//              check sum for the input character string
// Parameters: Character string to process
// Возврат value: Истина if check sum is right, false if not
//-----------------------------------------------------------------------------
Функция cmHexCSUM(pStr) Экспорт
	vDecCSUM = 0;
	Для i = 1 По СтрДлина(pStr) Цикл
		vDecCSUM = vDecCSUM + CharCode(Сред(pStr, i, 1));
		vDecCSUM = cmBin2Dec(Прав(cmDec2Bin(vDecCSUM), 8)); // Take last byte decimal code as next iteration seed
	КонецЦикла;
	vHexCSUM = cmBin2Hex(cmDec2Bin(vDecCSUM));
	Если СтрДлина(vHexCSUM) = 1 Тогда
		vHexCSUM = "0" + vHexCSUM;
	КонецЕсли;
	Возврат vHexCSUM;
КонецФункции //cmHexCSUM

//-----------------------------------------------------------------------------
// Description: Checks simple check sum for the input character string
// Parameters: Character string to process
// Возврат value: Истина if check sum is right, false if not
//-----------------------------------------------------------------------------
Функция cmCheckHexCSUM(pStr) Экспорт
	vNewHexCSUM = cmHexCSUM(Сред(pStr, 2, СтрДлина(pStr) - 4));
	vInpHexCSUM = Лев(Прав(pStr, 3), 2);
	Если vNewHexCSUM = vInpHexCSUM Тогда
		Возврат Истина;
	Иначе
		Возврат Ложь;
	КонецЕсли;
КонецФункции //cmCheckHexCSUM

//-----------------------------------------------------------------------------
// Description: Returns TCP\IP COM component license code
// Parameters: None
// Возврат value: License code
//-----------------------------------------------------------------------------
//Функция cmGetCSWSOCK6LicenseKey() Экспорт
//	Возврат "HODLMGFPHNNBOMRB";
//КонецФункции //cmGetCSWSOCK6LicenseKey

//-----------------------------------------------------------------------------
// Description: Appends right blanks to the given string up to the given string length
// Parameters: String, Length of string to return
// Возврат value: String
//-----------------------------------------------------------------------------
Функция cmAppendBlanks(pStr, pLen) Экспорт
	vStr = СокрЛП(pStr);
	Для i = 1 По pLen Цикл
		Если СтрДлина(vStr) = pLen Тогда
			Прервать;
		Иначе
			vStr = vStr + " ";
		КонецЕсли;
	КонецЦикла;
	Возврат vStr;
КонецФункции //cmAppendBlanks

//-----------------------------------------------------------------------------
// Description: Appends left blanks to the given string up to the given string length
// Parameters: String, Length of string to return
// Возврат value: String
//-----------------------------------------------------------------------------
Функция cmAppendLeftBlanks(pStr, pLen) Экспорт
	vStr = СокрЛП(pStr);
	Для i = 1 To pLen Цикл
		Если СтрДлина(vStr) = pLen Тогда
			Прервать;
		Иначе
			vStr = " " + vStr;
		КонецЕсли;
	КонецЦикла;
	Возврат vStr;
КонецФункции //cmAppendLeftBlanks

//-----------------------------------------------------------------------------
// Description: Returns value table with all report items
// Parameters: Reports catalog folder to filter reports by
// Возврат value: Value table
//-----------------------------------------------------------------------------
Функция cmGetAllReports(pReportsFolder = Неопределено) Экспорт
	// Build and run query
	vQry = Новый Query;
	vQry.Text = 
	"SELECT 
	|	Отчеты.Ref AS Report
	|FROM
	|	Catalog.Отчеты AS Отчеты
	|WHERE
	|	Отчеты.IsFolder = FALSE AND " +
		?(ЗначениеЗаполнено(pReportsFolder), "Отчеты.Ref IN HIERARCHY(&qReportsFolder) AND ", "") + "
	|	Отчеты.DeletionMark = FALSE
	|ORDER BY Отчеты.ПорядокСортировки";
	vQry.SetParameter("qReportsFolder", pReportsFolder);
	vList = vQry.Execute().Unload();
	Возврат vList;
КонецФункции //cmGetAllReports

//-----------------------------------------------------------------------------
// Description: Returns whether to show not enough rooms messages to the 
//              current user or not
// Parameters: None
// Возврат value: Ложь if messages shouldn't be shown, true if yes
//-----------------------------------------------------------------------------
Функция cmShowNotEnoughRoomsMessages() Экспорт
	Если ЗначениеЗаполнено(ПараметрыСеанса.ТекПользователь) Тогда
		Если ЗначениеЗаполнено(ПараметрыСеанса.ТекПользователь.НастройкиСотрудников) Тогда
			Если ПараметрыСеанса.ТекПользователь.НастройкиСотрудников.DoNotShowNotEnoughRoomsMessages Тогда
				Возврат Ложь;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	Возврат Истина;
КонецФункции //cmShowNotEnoughRoomsMessages

//-----------------------------------------------------------------------------
// Description: Returns value table with phone numbers for the given list of rooms
// Parameters: Value list of rooms
// Возврат value: Value table
//-----------------------------------------------------------------------------
Функция cmGetPhoneNumbersForRooms(pRooms) Экспорт
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	PhoneNumbers.Ref,
	|	PhoneNumbers.НомерРазмещения,
	|	PhoneNumbers.PhoneNumber AS PhoneNumber
	|FROM
	|	Catalog.PhoneNumbers AS PhoneNumbers
	|WHERE
	|	(NOT PhoneNumbers.DeletionMark)
	|	AND PhoneNumbers.НомерРазмещения IN(&qRoomsList)
	|ORDER BY
	|	PhoneNumber";
	vQry.SetParameter("qRoomsList", pRooms);
	vPhoneNumbers = vQry.Execute().Unload();
	Возврат vPhoneNumbers;
КонецФункции //cmGetPhoneNumbersForRooms

//-----------------------------------------------------------------------------
// Description: Checks whether given string is number or not
// Parameters: String with number presentation to be checked
// Возврат value: Истина if string could be converted to the number, false if not
//-----------------------------------------------------------------------------


//-----------------------------------------------------------------------------
// Description: Returns count of elemnts from the parameter iterator
// Parameters: СписокЗначений, Array, ValueTable, ...
// Возврат value: Count of elements as number
//-----------------------------------------------------------------------------
Функция cmCount(pIter) Экспорт
	Попытка
		Возврат pIter.Count();
	Исключение
	КонецПопытки;
	Возврат 0;
КонецФункции //cmCount

//-----------------------------------------------------------------------------
// Description: Replaces MS Excel file data with picture of those data. Excel file 
//              becames read only without any chance to edit it
// Parameters: Full path to the file to be converted, Spreadsheet 
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmDoExcelSpreadSheetReadOnly(pFilePath, pSpreadsheet) Экспорт
	// Get number of pages
	Попытка
		vPagesCount = pSpreadsheet.PageCount();
	Исключение
		ВызватьИсключение NStr("en='Please set up default windows printer first!';
		           |ru='Пожалуйста настройте в Windows хотя бы один принтер по умолчанию!';
				   |de='Bitte stellen Sie in Windows mindestens einen Drucker als Standard-Drucker ein!'");
	КонецПопытки;
	Попытка
		vFile = Новый File(pFilePath);
		Если vFile.Exist() And vFile.IsFile() Тогда
			vFileName = vFile.Name;
			// Assuming that MS Office is installed in the system
			vExcel = Новый COMObject("Excel.Application");
			vExcel.Workbooks.Open(pFilePath);
			vWorkbook = vExcel.Workbooks.Item(vFileName);
			vWorkbook.Parent.ActiveWindow.DisplayGridlines = Ложь;
			vSheet = vWorkbook.ActiveSheet;
			vSheet.PageSetup.Zoom = Ложь;
			vSheet.PageSetup.BlackAndWhite = Истина;
			vSheet.PageSetup.FitToPagesWide = 1;
			vSheet.PageSetup.FitToPagesTall = vPagesCount;
			vPrintRange = vSheet.UsedRange;
			vPrintRange.CopyPicture(1);
			vPrintRange.Worksheet.Paste(vPrintRange.Item(1));
			vPrintRange.Clear();
			вКлючУникальности = Новый UUID(); // Will be used as password
			vSheet.Protect(String(вКлючУникальности), Истина, Истина, Истина, , Истина, Ложь, Ложь, Ложь, Ложь, Ложь, Ложь, Ложь, Ложь, Ложь, Ложь);
			vWorkbook.Protect(String(вКлючУникальности), Истина, Ложь);
		    vWorkbook.Save();
		    vWorkbook.Close();
			vExcel = Неопределено;
		КонецЕсли;
	Исключение
		Message(ErrorDescription(), MessageStatus.Attention);
	КонецПопытки;
КонецПроцедуры //cmDoExcelSpreadSheetReadOnly

//-----------------------------------------------------------------------------
// Description: Removes commas from the text
// Parameters: Text
// Возврат value: Text without commas
//-----------------------------------------------------------------------------
Функция cmRemoveComma(pStr) Экспорт
	Возврат СтрЗаменить(СтрЗаменить(TrimR(pStr), ",", ""), Chars.LF, "");
КонецФункции //cmRemoveComma

//-----------------------------------------------------------------------------
// Description: Returns period presentation as string
// Parameters: Start of period date, End of period date
// Возврат value: String
//-----------------------------------------------------------------------------
Функция cmPeriodPresentation(pDateFrom, pDateTo) Экспорт
	vStr = "";
	Если BegOfDay(pDateFrom) = BegOfDay(pDateTo) Тогда
		vStr = Формат(pDateFrom, "DF=dd.MM.yy");
	Иначе
		vStr = Формат(pDateFrom, "DF=dd.MM.yy") + " - " + Формат(pDateTo, "DF=dd.MM.yy");
	КонецЕсли;
	Возврат vStr;	
КонецФункции //cmPeriodPresentation

//-----------------------------------------------------------------------------
// Description: This function checks whether current user has rights to open 
//              report form or not
// Parameters: Catalog Reports reference
// Возврат value: Boolean, true if user has rights, false if not
//-----------------------------------------------------------------------------
Функция cmCheckUserRightsToOpenReport(pReport) Экспорт
	vUserHasRights = Истина;
	Если НЕ cmCheckUserPermissions("HavePermissionToRunAllReports") Тогда
		Если ЗначениеЗаполнено(pReport) And ЗначениеЗаполнено(ПараметрыСеанса.ТекПользователь) Тогда
			vPermissionGroup = ПараметрыСеанса.ТекПользователь.НаборПрав;
			Если ЗначениеЗаполнено(vPermissionGroup) Тогда
				Если pReport.НаборПрав <> vPermissionGroup Тогда
					Если pReport.НаборПрав.Find(vPermissionGroup, "PermissionGroup") = Неопределено Тогда
						vUserHasRights = Ложь;
					КонецЕсли;
				КонецЕсли;
			Иначе
				vUserHasRights = Ложь;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	Возврат vUserHasRights;
КонецФункции //cmCheckUserRightsToOpenReport

//-----------------------------------------------------------------------------
// Description: This function checks whether current user has rights to execute 
//              data processor or not
// Parameters: Catalog Обработки reference
// Возврат value: Boolean, true if user has rights, false if not
//-----------------------------------------------------------------------------
Функция cmCheckUserRightsToExecuteDataProcessor(pDP) Экспорт
	vUserHasRights = Истина;
	Если НЕ cmCheckUserPermissions("HavePermissionToRunAllDataProcessors") Тогда
		Если ЗначениеЗаполнено(pDP) And ЗначениеЗаполнено(ПараметрыСеанса.ТекПользователь) Тогда
			vPermissionGroup = ПараметрыСеанса.ТекПользователь.НаборПрав;
			Если ЗначениеЗаполнено(vPermissionGroup) Тогда
				Если pDP.НаборПрав <> vPermissionGroup Тогда
					Если pDP.НаборПрав.Find(vPermissionGroup, "PermissionGroup") = Неопределено Тогда
						vUserHasRights = Ложь;
					КонецЕсли;
				КонецЕсли;
			Иначе
				vUserHasRights = Ложь;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	Возврат vUserHasRights;
КонецФункции //cmCheckUserRightsToExecuteDataProcessor

//-----------------------------------------------------------------------------
// Description: Load's report static and dynamic settings and parameters from the given XML file
// Parameters: Reports catalog item object, report settings file path
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmReadReportSettingsFromFile(pRepObj, pFileName) Экспорт
	vXMLReader = Новый XMLReader();
	vXMLReader.OpenFile(pFileName);
	Пока vXMLReader.Read() Цикл
		Если vXMLReader.NodeType = XMLNodeType.StartElement Тогда
			Если vXMLReader.Name = "htl:ReportSettings" Тогда
				Пока vXMLReader.ReadAttribute() Цикл
					Если vXMLReader.Name = "htl:report" Тогда
						Если vXMLReader.Value <> СокрЛП(pRepObj.Report) Тогда
							ВызватьИсключение NStr("en='Report settings you are trying to load from are of different report type!';
							           |ru='Тип отчета, настройки которого вы пытаетесь загрузить, отличается от типа текущего отчета!';
									   |de='Der Berichtstyp, dessen Einstellungen Sie zu laden versuchen, unterscheidet sich vom Typ des aktuellen Berichts!'");
						КонецЕсли;
					КонецЕсли;
				КонецЦикла;
			ИначеЕсли vXMLReader.Name = "htl:Dynamic" Тогда
				vXMLReader.Read();
				pRepObj.DynamicParameters = ReadXML(vXMLReader);
			ИначеЕсли vXMLReader.Name = "htl:Static" Тогда
				vXMLReader.Read();
				pRepObj.StaticParameters = ReadXML(vXMLReader);
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	vXMLReader.Close();
КонецПроцедуры //cmReadReportSettingsFromFile

//-----------------------------------------------------------------------------
// Description: Saves report static and dynamic settings and parameters to the given XML file
// Parameters: Reports catalog item reference or object, file path where to save 
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmWriteReportSettingsToFile(pRep, pFileName) Экспорт
	vNameSpaceURI = "http://1chotel.ru";
	vXMLWriter = Новый XMLWriter();
	vXMLWriter.OpenFile(pFileName, "UTF-8");
	vXMLWriter.WriteXMLDeclaration();
	vXMLWriter.WriteStartElement("Гостиница");
	vXMLWriter.WriteNamespaceMapping("htl", vNameSpaceURI);
	vXMLWriter.WriteStartElement("ReportSettings", vNameSpaceURI);
	vXMLWriter.WriteAttribute("report", vNameSpaceURI, СокрЛП(pRep.Report));
	vXMLWriter.WriteStartElement("Dynamic", vNameSpaceURI);
	WriteXML(vXMLWriter, pRep.DynamicParameters, XMLTypeAssignment.Explicit);
	vXMLWriter.WriteEndElement();
	vXMLWriter.WriteStartElement("Static", vNameSpaceURI);
	WriteXML(vXMLWriter, pRep.StaticParameters, XMLTypeAssignment.Explicit);
	vXMLWriter.WriteEndElement();
	vXMLWriter.WriteEndElement();
	vXMLWriter.WriteEndElement();
	vXMLWriter.Close();
КонецПроцедуры //cmWriteReportSettingsToFile

//-----------------------------------------------------------------------------
// Description: This function reads report default settings from the report template
// Parameters: Report name
// Возврат value: String, xml with report settings
//-----------------------------------------------------------------------------
Функция cmReadReportDefaultSettingFromTemplate(pReportObj) Экспорт
	vReportSettings = Неопределено;
	Попытка
		vFileName = GetTempFileName("xml");
		Reports[pReportObj.Report].GetTemplate("DefaultSettings").Write(vFileName);
		vFileReader = Новый TextReader(vFileName, TextEncoding.UTF8);
		vReportSettings = vFileReader.Read();
		vFileReader.Close();
		// Activate default report settings
		cmReadReportSettingsFromFile(pReportObj, vFileName);
	Исключение
	КонецПопытки;
	Возврат vReportSettings;
КонецФункции //cmReadReportDefaultSettingFromTemplate

//-----------------------------------------------------------------------------
// Description: This function converts string first character to upper case
// Parameters: String to be converted
// Возврат value: String
//-----------------------------------------------------------------------------
Функция cmFirstLetter2Upper(pStr) Экспорт 
	vStr = "";
	vStrLen = СтрДлина(pStr);
	Если vStrLen > 1 Тогда	
		vStr = ВРег(Лев(pStr, 1)) + Сред(pStr, 2);
		Возврат vStr;
	ИначеЕсли vStrLen = 1 Тогда
		Возврат ВРег(pStr);
	Иначе
		Возврат pStr;
	КонецЕсли;
КонецФункции //cmFirstLetter2Upper

//-----------------------------------------------------------------------------
// Description: This function converts string first character to lower case
// Parameters: String to be converted
// Возврат value: String
//-----------------------------------------------------------------------------
Функция cmFirstLetter2Lower(pStr) Экспорт 
	vStr = "";
	vStrLen = СтрДлина(pStr);
	Если vStrLen > 1 Тогда	
		vStr = Lower(Лев(pStr, 1)) + Сред(pStr, 2);
		Возврат vStr;
	ИначеЕсли vStrLen = 1 Тогда
		Возврат Lower(pStr);
	Иначе
		Возврат pStr;
	КонецЕсли;
КонецФункции //cmFirstLetter2Lower

//-----------------------------------------------------------------------------
// Description: This function char code into it's hex representation
// Parameters: Символ code
// Возврат value: String hex code representation
//-----------------------------------------------------------------------------
Функция cmHex(Val pValue) Экспорт
	vResult = "0";
    vValue = Число(pValue);
    Если vValue > 0 Тогда
        vValue = Цел(vValue);
        vResult = "";
        Пока vValue > 0 Цикл
            vResult = Сред("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ", vValue%16 + 1, 1) + vResult;
            vValue = Цел(vValue/16);
        КонецЦикла;
    КонецЕсли;
    Если СтрДлина(vResult) < 2 Тогда
        vResult = "0" + vResult;
    КонецЕсли;
    Возврат "%" + vResult;
КонецФункции //cmHex

//-----------------------------------------------------------------------------
// Description: Encodes http GET request string
// Parameters: URL string to be encoded
// Возврат value: Encoded URL string
//-----------------------------------------------------------------------------
Функция cmEncodeURL(pURL) Экспорт
    vResult = "";
    Для i = 1 По СтрДлина(pURL) Цикл
        ch = Сред(pURL, i, 1);
        vch = CharCode(ch);
        Если ("A" <= ch) And (ch <= "Z") Тогда // "A".."Z"
            vResult = vResult + ch;
        ИначеЕсли ("a" <= ch) And (ch <= "z") Тогда // "a".."z"
            vResult = vResult + ch;
        ИначеЕсли ("0" <= ch) And (ch <= "9") Тогда // "0".."9"
            vResult = vResult + ch;
        ИначеЕсли (ch = " ") ИЛИ (ch = "+") Тогда // space
            vResult = vResult + "+";
		ИначеЕсли (ch = "-") ИЛИ (ch = "_") // unreserved
            ИЛИ (ch = ".") ИЛИ (ch = "!")
            ИЛИ (ch = "~") ИЛИ (ch = "*")
            ИЛИ (ch = "") ИЛИ (ch = "(")
            ИЛИ (ch = ")") Тогда
            vResult = vResult + ch;
        ИначеЕсли (vch <= 127) Тогда  // other ASCII
            vResult = vResult + cmHex(vch);
        ИначеЕсли (vch <= 2047) Тогда // non-ASCII <= 0x7FF
            vResult = vResult + cmHex(192 + Цел(vch / 64));
            vResult = vResult + cmHex(128 + (vch % 64));
        Иначе                     // 0x7FF < ch <= 0xFFFF
            vResult = vResult + cmHex(224 + Цел(vch / 4096));
            vResult = vResult + cmHex(128 + (Цел(vch / 64) % 64));
            vResult = vResult + cmHex(128 + (vch % 64));
        КонецЕсли;
    КонецЦикла;
    Возврат vResult;
КонецФункции //cmEncodeURL

//-----------------------------------------------------------------------------
// 
//-----------------------------------------------------------------------------
Функция cmGetQRCodePicture(pCode) Экспорт
	vGoogleAPIAddr = "chart.apis.google.com";
	vAddrStart = "/chart?cht=qr&chs=200x200&chl=";
    vAddrEnd = cmEncodeURL(pCode);
	// HTTP connection
	vHTTPConnection = Неопределено;
	vProxy = cmGetInternetProxy(Неопределено, Ложь, vGoogleAPIAddr);
	Если vProxy <> Неопределено Тогда
		vHTTPConnection = Новый HTTPConnection(vGoogleAPIAddr, , , , vProxy, );
	Иначе
		vHTTPConnection = Новый HTTPConnection(vGoogleAPIAddr, , , , , );
	КонецЕсли;
	// Get temp file name 
	vResponseFileName = GetTempFileName("png");
	// GET request data
	vHTTPConnection.Get(Новый HTTPRequest(vAddrStart + vAddrEnd), vResponseFileName);
	// Create image object from data returned
	vCodeImage = Новый Picture(vResponseFileName, Ложь);
	// Delete temp file
	УдалитьФайлы(vResponseFileName);
	// Возврат code image
	Возврат vCodeImage;
КонецФункции //cmGetQRCodePicture

//-----------------------------------------------------------------------------
// This function fills docx template file with DocumentProperties field values
//-----------------------------------------------------------------------------
Процедура cmProcessDOCXFile(pFilePath, pFieldsStruct) Экспорт
	vF = Новый File(pFilePath);
	Если vF.Exist() And vF.IsFile() Тогда
		vFileName = vF.Name;
		vDirName = vF.BaseName;
		vFile = Новый ZipFileReader(TempFilesDir()+vFileName);
		vDocumentEntry = vFile.Items.Find("document.xml");
		Если vDocumentEntry <> Неопределено Тогда
			vFile.ExtractAll(TempFilesDir()+vDirName+"\");
			vFile.Close();
			vTextFile = Новый TextDocument;
			vTextFile.Read(TempFilesDir()+vDirName+"\word\document.xml", TextEncoding.UTF8);
			// Process all document fields
			Для Each vItem In pFieldsStruct Цикл
				vText = vTextFile.GetText();
				vItemKey = СокрЛП(vItem.Key);
				vSearchText = vText;
				vStep = 0;
				Пока Истина Цикл
					vBeginPos = Find(vSearchText, vItemKey); 
					Если vBeginPos <> 0 Тогда
						vBeginPos = vStep + vBeginPos;
						vStep = vBeginPos + СтрДлина(vItemKey) - 1;
						vSearchText = Сред(vText, vBeginPos + СтрДлина(vItemKey));
						vLeftText = Лев(vText, vBeginPos-1);
						vTempText = Прав(vText, СтрДлина(vText)-vBeginPos+1);
						vPos = Find(vTempText, "<w:fldChar w:fldCharType=""end""/></w:r>");
						Если vPos <> 0 Тогда
							vBegOfWTPos = Find(vTempText, "<w:t>");
							Если vBegOfWTPos <> 0 Тогда
								vLastEndOfWTPos = -1;
								vEndOfWTPos = 0;
								vCounter = 0;
								Пока (vCounter < vPos And vLastEndOfWTPos <> 0) Цикл
									vLastEndOfWTPos = Find(Прав(vTempText, СтрДлина(vTempText)-vCounter), "</w:t>");
									vCounter = vCounter + vLastEndOfWTPos + 6;
									Если vCounter < vPos And vLastEndOfWTPos <> 0 Тогда
										vEndOfWTPos = vCounter;
									КонецЕсли;
								КонецЦикла;
								vRightText = Прав(vTempText, СтрДлина(vTempText)-vEndOfWTPos+7);
								vMidLeftText = Лев(vTempText, vBegOfWTPos+4);
								vEndText = vLeftText + vMidLeftText + СтрЗаменить(cmEncodeXML(СокрЛП(vItem.Value), Истина), Chars.LF, "</w:t></w:r></w:p><w:p><w:r><w:t xml:space=""preserve"">") + vRightText;
								vTextFile.SetText(vEndText);
								vText = vEndText;
							КонецЕсли;
						КонецЕсли;
					Иначе
						Прервать;
					КонецЕсли;
				КонецЦикла;
			КонецЦикла;
			// Update and build file structure
			vTextFile.Write(TempFilesDir()+vDirName+"\word\document.xml");
			vWrFile = Новый ZipFileWriter(TempFilesDir()+vFileName);
			vWrFile.Add(TempFilesDir()+vDirName+"\*.*", ZIPStorePathMode.StoreRelativePath, ZIPSubDirProcessingMode.ProcessRecursively);
			vWrFile.Write();
			// Delete file content
			УдалитьФайлы(TempFilesDir()+vDirName+"\");
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры //cmProcessDOCXFile

//-----------------------------------------------------------------------------
// This function fills odt template file with DocumentProperties field values
//-----------------------------------------------------------------------------
Процедура cmProcessODTFile(pFilePath, pFieldsStruct) Экспорт
	vF = Новый File(pFilePath);
	Если vF.Exist() And vF.IsFile() Тогда
		vFileName = vF.Name;
		vDirName = vF.BaseName;
		vFile = Новый ZipFileReader(TempFilesDir()+vFileName);
		vDocumentEntry = vFile.Items.Find("meta.xml");
		
			Если vDocumentEntry <> Неопределено Тогда
			vFile.ExtractAll(TempFilesDir()+vDirName+"\");
			vFile.Close();
			vTextFile = Новый TextDocument;
			vTextFile.Read(TempFilesDir()+vDirName+"\content.xml", TextEncoding.UTF8);
			// Process all document fields
			Для Each vItem In pFieldsStruct Цикл
				vText = vTextFile.GetText();
				vItemKey = СокрЛП(vItem.Key);
				vSearchText = vText;
				vStep = 0;
				Пока Истина Цикл
					vBeginPos = Find(vSearchText, vItemKey); 
					Если vBeginPos <> 0 Тогда
						vBeginPos = vStep + vBeginPos;
						vStep = vBeginPos + СтрДлина(vItemKey) - 1;
						vSearchText = Сред(vText, vBeginPos + СтрДлина(vItemKey));
						vLeftText = Лев(vText, vBeginPos-1);
						vTempText = Прав(vText, СтрДлина(vText)-vBeginPos+1);
						vPos = Find(vTempText, "</text:user-defined>");
						Если vPos <> 0 Тогда
							vBegOfWTPos = Find(vTempText, ">");
							Если vBegOfWTPos <> 0 Тогда
								vRightText = Прав(vTempText, СтрДлина(vTempText)-vPos+1);
								vMidLeftText = Лев(vTempText, vBegOfWTPos);
								vEndText = vLeftText + vMidLeftText +  cmEncodeXML(СокрЛП(vItem.Value), Истина) + vRightText;
								vTextFile.SetText(vEndText);
								vText = vEndText;
							КонецЕсли;
						КонецЕсли;
					Иначе
						Прервать;
					КонецЕсли;
				КонецЦикла;
			КонецЦикла;
			// Change field type from "user-defined" to "text-input"
			vText = vTextFile.GetText();
			vText = СтрЗаменить(vText, "user-defined", "text-input");
			vTextFile.SetText(vText);
			// Update and build file structure
			vTextFile.Write(TempFilesDir()+vDirName+"\content.xml");
			vWrFile = Новый ZipFileWriter(TempFilesDir()+vFileName);
			vWrFile.Add(TempFilesDir()+vDirName+"\*.*", ZIPStorePathMode.StoreRelativePath, ZIPSubDirProcessingMode.ProcessRecursively);
			vWrFile.Write();
			// Delete file content
			УдалитьФайлы(TempFilesDir()+vDirName+"\");
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры //cmProcessODTFile

//-----------------------------------------------------------------------------
// This function replaces XML forbiden chars with substitutes
//-----------------------------------------------------------------------------
Функция cmEncodeXML(Val pText, pAmpOnly = Ложь) Экспорт
	vText = pText;
	Если pAmpOnly Тогда
		vText = СтрЗаменить(vText, "&", "&amp;");
	Иначе
		vText = СтрЗаменить(vText, """", "&quot;");
		vText = СтрЗаменить(vText, "©", "&copy;");
		vText = СтрЗаменить(vText, "®", "&reg;");
		vText = СтрЗаменить(vText, "™", "&trade;");
		vText = СтрЗаменить(vText, "„", "&bdquo;");
		vText = СтрЗаменить(vText, "“", "&ldquo;");
		vText = СтрЗаменить(vText, "«", "&laquo;");
		vText = СтрЗаменить(vText, "»", "&raquo;");
		vText = СтрЗаменить(vText, ">", "&gt;");
		vText = СтрЗаменить(vText, "<", "&lt;");
		vText = СтрЗаменить(vText, "≥", "&ge;");
		vText = СтрЗаменить(vText, "≤", "&le;");
		vText = СтрЗаменить(vText, "≈", "&asymp;");
		vText = СтрЗаменить(vText, "≠", "&ne;");
		vText = СтрЗаменить(vText, "≡", "&equiv;");
		vText = СтрЗаменить(vText, "§", "&sect;");
		vText = СтрЗаменить(vText, "&", "&amp;");
		vText = СтрЗаменить(vText, "∞", "&infin;");
	КонецЕсли;
	Возврат vText;
КонецФункции //cmEncodeXML

//-----------------------------------------------------------------------------
// TYPE DESCRIPTIONS
// Description: Functions below return type description objects of different types
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
Функция cmGetObjectTypeDescription(pObj) Экспорт
	vTypes = Новый Array();
	vTypes.Add(TypeOf(pObj));
	Возврат Новый TypeDescription(vTypes);
КонецФункции //cmGetObjectTypeDescription

//-----------------------------------------------------------------------------
Функция cmGetQuantityTypeDescription() Экспорт
	vNQ = Новый NumberQualifiers(19, 7);
	vTA = Новый Array;
	vTA.Add(Type("Число"));
	vTypeDescr = Новый TypeDescription(vTA, vNQ);
	Возврат vTypeDescr;
КонецФункции //cmGetQuantityTypeDescription

//-----------------------------------------------------------------------------
Функция cmGetSumTypeDescription() Экспорт
	vNQ = Новый NumberQualifiers(17, 2);
	vTA = Новый Array;
	vTA.Add(Type("Число"));
	vTypeDescr = Новый TypeDescription(vTA, vNQ);
	Возврат vTypeDescr;
КонецФункции //cmGetSumTypeDescription

//-----------------------------------------------------------------------------
Функция cmGetNumberTypeDescription(pTotalDigits, pDecDigits, pNonnegative = Ложь) Экспорт
	Если pNonnegative Тогда
		vNQ = Новый NumberQualifiers(pTotalDigits, pDecDigits, AllowedSign.Nonnegative);
	Иначе
		vNQ = Новый NumberQualifiers(pTotalDigits, pDecDigits);
	КонецЕсли;
	vTA = Новый Array;
	vTA.Add(Type("Число"));
	vTypeDescr = Новый TypeDescription(vTA, vNQ);
	Возврат vTypeDescr;
КонецФункции //cmGetNumberTypeDescription

//-----------------------------------------------------------------------------
Функция cmGetNumberAndStringTypeDescription(pTotalDigits, pDecDigits) Экспорт
	vNQ = Новый NumberQualifiers(pTotalDigits, pDecDigits);
	vTA = Новый Array;
	vTA.Add(Type("String"));
	vTA.Add(Type("Число"));
	vTypeDescr = Новый TypeDescription(vTA, vNQ);
	Возврат vTypeDescr;
КонецФункции //cmGetNumberAndStringTypeDescription

//-----------------------------------------------------------------------------
Функция cmGetCatalogTypeDescription(pCatalog) Экспорт
	vTA = Новый Массив;
	vTA.Add(Type("СправочникСсылка." + pCatalog));
	vTypeDescr = Новый TypeDescription(vTA);
	Возврат vTypeDescr;
КонецФункции //cmGetCatalogTypeDescription

//-----------------------------------------------------------------------------
Функция cmGetDocumentTypeDescription(pDocument) Экспорт
	vTA = Новый Array;
	vTA.Add(Type("ДокументСсылка." + pDocument));
	vTypeDescr = Новый TypeDescription(vTA);
	Возврат vTypeDescr;
КонецФункции //cmGetDocumentTypeDescription

//-----------------------------------------------------------------------------
Функция cmGetDateTimeTypeDescription() Экспорт
	vDQ = Новый DateQualifiers(DateFractions.DateTime);
	vTA = Новый Array;
	vTA.Add(Type("Date"));
	vTypeDescr = Новый TypeDescription(vTA, , , vDQ);
	Возврат vTypeDescr;
КонецФункции //cmGetDateTimeTypeDescription

//-----------------------------------------------------------------------------
Функция cmGetDateTypeDescription() Экспорт
	vDQ = Новый DateQualifiers(DateFractions.ДатаДок);
	vTA = Новый Array;
	vTA.Add(Type("Date"));
	vTypeDescr = Новый TypeDescription(vTA, , , vDQ);
	Возврат vTypeDescr;
КонецФункции //cmGetDateTypeDescription

//-----------------------------------------------------------------------------
Функция cmGetTimeTypeDescription() Экспорт
	vDQ = Новый DateQualifiers(DateFractions.Time);
	vTA = Новый Array;
	vTA.Add(Type("Date"));
	vTypeDescr = Новый TypeDescription(vTA, , , vDQ);
	Возврат vTypeDescr;
КонецФункции //cmGetTimeTypeDescription

//-----------------------------------------------------------------------------
Функция cmGetBooleanTypeDescription() Экспорт
	vTA = Новый Array;
	vTA.Add(Type("Boolean"));
	vTypeDescr = Новый TypeDescription(vTA);
	Возврат vTypeDescr;
КонецФункции //cmGetBooleanTypeDescription

//-----------------------------------------------------------------------------
Функция cmGetNumberOfPersonsTypeDescription() Экспорт
	vNQ = Новый NumberQualifiers(6, 0);
	vTA = Новый Array;
	vTA.Add(Type("Число"));
	vTypeDescr = Новый TypeDescription(vTA, vNQ);
	Возврат vTypeDescr;
КонецФункции //cmGetNumberOfPersonsTypeDescription

//-----------------------------------------------------------------------------
Функция cmGetLineNumberTypeDescription() Экспорт
	vNQ = Новый NumberQualifiers(4, 0);
	vTA = Новый Array;
	vTA.Add(Type("Число"));
	vTypeDescr = Новый TypeDescription(vTA, vNQ);
	Возврат vTypeDescr;
КонецФункции //cmGetLineNumberTypeDescription

//-----------------------------------------------------------------------------
Функция cmGetExchangeRateTypeDescription() Экспорт
	vNQ = Новый NumberQualifiers(19, 7);
	vTA = Новый Array;
	vTA.Add(Type("Число"));
	vTypeDescr = Новый TypeDescription(vTA, vNQ);
	Возврат vTypeDescr;
КонецФункции //cmGetExchangeRateTypeDescription

//-----------------------------------------------------------------------------
Функция cmGetDiscountTypeDescription() Экспорт
	vNQ = Новый NumberQualifiers(6, 2);
	vTA = Новый Array;
	vTA.Add(Type("Число"));
	vTypeDescr = Новый TypeDescription(vTA, vNQ);
	Возврат vTypeDescr;
КонецФункции //cmGetDiscountTypeDescription

//-----------------------------------------------------------------------------
Функция cmGetStringTypeDescription(pLength = 0, pAllowedLength = 0) Экспорт
	Если pLength <> 0 ИЛИ pAllowedLength <> 0 Тогда
		vSQ = Новый StringQualifiers(pLength, pAllowedLength);
		vTA = Новый Array;
		vTA.Add(Type("String"));
		vTypeDescr = Новый TypeDescription(vTA, , vSQ);
	Иначе
		vTA = Новый Array;
		vTA.Add(Type("String"));
		vTypeDescr = Новый TypeDescription(vTA);
	КонецЕсли;
	Возврат vTypeDescr;
КонецФункции //cmGetStringTypeDescription

//-----------------------------------------------------------------------------
Функция cmGetValueStorageTypeDescription() Экспорт
	vTA = Новый Array;
	vTA.Add(Type("ValueStorage"));
	vTypeDescr = Новый TypeDescription(vTA);
	Возврат vTypeDescr;
КонецФункции //cmGetValueStorageTypeDescription

//-----------------------------------------------------------------------------
Функция cmGetConfirmationTextTypeDescription() Экспорт
	vSQ = Новый StringQualifiers(100);
	vTA = Новый Array;
	vTA.Add(Type("String"));
	vTypeDescr = Новый TypeDescription(vTA, , vSQ);
	Возврат vTypeDescr;
КонецФункции //cmGetConfirmationTextTypeDescription

//-----------------------------------------------------------------------------
Функция cmGetAgentCommissionTypeDescription() Экспорт
	vNQ = Новый NumberQualifiers(6, 2);
	vTA = Новый Array;
	vTA.Add(Type("Число"));
	vTypeDescr = Новый TypeDescription(vTA, vNQ);
	Возврат vTypeDescr;
КонецФункции //cmGetAgentCommissionTypeDescription

//-----------------------------------------------------------------------------
Функция cmGetEnumTypeDescription(pEnum) Экспорт
	vTA = Новый Array;
	vTA.Add(Type("ПеречислениеСсылка."+pEnum));
	vTypeDescr = Новый TypeDescription(vTA);
	Возврат vTypeDescr;
КонецФункции //cmGetEnumTypeDescription

//-----------------------------------------------------------------------------
Функция cmGetSortCodeTypeDescription() Экспорт
	vNQ = Новый NumberQualifiers(8, 0);
	vTA = Новый Array;
	vTA.Add(Type("Число"));
	vTypeDescr = Новый TypeDescription(vTA, vNQ);
	Возврат vTypeDescr;
КонецФункции //cmGetSortCodeTypeDescription

//-----------------------------------------------------------------------------
Функция cmGetMaxSortCodeValue() Экспорт
	Возврат 99999999;
КонецФункции //cmGetMaxSortCodeValue

//-----------------------------------------------------------------------------
Функция cmGetCatalogCodeTypeDescription() Экспорт
	vSQ = Новый StringQualifiers(5);
	vTA = Новый Array;
	vTA.Add(Type("String"));
	vTypeDescr = Новый TypeDescription(vTA, , vSQ);
	Возврат vTypeDescr;
КонецФункции //cmGetCatalogCodeTypeDescription

//-----------------------------------------------------------------------------
Функция cmGetObjectsTypeDescription() Экспорт
	vTA = Новый Array;
	Для Each vCat In Metadata.Справочники Цикл
		vTA.Add(Type("CatalogRef." + vCat.Name));
	КонецЦикла;
	Для Each vDoc In Metadata.Documents Цикл
		vTA.Add(Type("DocumentRef." + vDoc.Name));
	КонецЦикла;
	vTypeDescr = Новый TypeDescription(vTA);
	Возврат vTypeDescr;
КонецФункции //cmGetObjectsTypeDescription

//-----------------------------------------------------------------------------
Функция cmGetObjectTemplatesTypeDescription() Экспорт
	vTA = Новый Array;
	vTA.Add(cmGetDocumentTypeDescription("Размещение"));
	vTA.Add(cmGetDocumentTypeDescription("Бронирование"));
	vTA.Add(cmGetDocumentTypeDescription("БроньУслуг"));
	vTA.Add(cmGetDocumentTypeDescription("СчетПроживания"));
	vTypeDescr = Новый TypeDescription(vTA);
	Возврат vTypeDescr;
КонецФункции //cmGetObjectTemplatesTypeDescription

//-----------------------------------------------------------------------------
Функция cmGetDayOfWeekShortNameTypeDescription() Экспорт
	vSQ = Новый StringQualifiers(2);
	vTA = Новый Array;
	vTA.Add(Type("String"));
	vTypeDescr = Новый TypeDescription(vTA, , vSQ);
	Возврат vTypeDescr;
КонецФункции //cmGetDayOfWeekShortNameTypeDescription

//-----------------------------------------------------------------------------
// Description: Replaces client name with code, clears all other idenification 
//              client data and clears all history records connected to that client
// Parameters: Reference to the client item
// Возврат value: Boolean, true if operation completed successfully
//-----------------------------------------------------------------------------
Процедура cmHideClientNameAndNameHistory(pClient) Экспорт
	vCltObj = pClient.GetObject();
	// Replace client name with client code
	vCltObj.Фамилия = ?(СокрЛП(vCltObj.Code), Формат(Число(vCltObj.Code), "ND=12; NFD=0; NG="), СокрЛП(vCltObj.Code));
	vCltObj.Имя = "";
	vCltObj.Отчество = "";
	vCltObj.Description = vCltObj.Фамилия;
	vCltObj.FullName = vCltObj.Фамилия;
	// Cliear other client identification data. 
	// We will skip clearing Гражданство, date of birth and address 
	// to avoid change in the sales statistics
	vCltObj.Телефон = "";
	//vCltObj.Fax = "";
	vCltObj.EMail = "";
	vCltObj.PlaceOfBirth = "";
	vCltObj.IdentityDocumentType = Неопределено;
	vCltObj.IdentityDocumentSeries = "";
	vCltObj.IdentityDocumentNumber = "";
	vCltObj.IdentityDocumentIssueDate = Неопределено;
	vCltObj.IdentityDocumentValidToDate = Неопределено;
	vCltObj.IdentityDocumentIssuedBy = "";
	//vCltObj.MilitaryRank = "";
	//vCltObj.Certificate = "";
	//vCltObj.PlaceOfEmployment = "";
	//vCltObj.PolicyOfMedicalInsurance = "";
	//vCltObj.AmbulatoryCard = "";
	vCltObj.Disablement = "";
	vCltObj.Children = "";
	vCltObj.Parents = "";
	vCltObj.Title = "";
	vCltObj.Salutation = "";
	vCltObj.Photo = Неопределено;
	vCltObj.Подпись = Неопределено;
	// Save changes
	vCltObj.Write();
	// Write client change history record
	vCltObj.pmWriteToClientChangeHistory(CurrentDate(), ПараметрыСеанса.ТекПользователь);
	// Clear client change history records
	vSet = InformationRegisters.ИсторияИзмКлиентов.CreateRecordSet();
	vSet.Filter.Клиент.ComparisonType = ComparisonType.Equal;
	vSet.Filter.Клиент.Value = pClient;
	vSet.Filter.Клиент.Use = Истина;
	vSet.Read();
	Для Each vSetRow In vSet Цикл
		FillPropertyValues(vSetRow, vCltObj);
		vSetRow.Changes = "";
	КонецЦикла;
	vSet.Write(Истина);
	// Find references to the client in the reservation change history and clear them either
	vSet = InformationRegisters.ИсторияБрони.CreateRecordSet();
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	Бронирование.Ref
	|FROM
	|	Document.Бронирование AS Бронирование
	|WHERE
	|	Бронирование.Клиент = &qClient
	|
	|ORDER BY
	|	Бронирование.PointInTime";
	vQry.SetParameter("qClient", pClient);
	vDocs = vQry.Execute().Unload();
	Для Each vDocsRow In vDocs Цикл
		// Update reservation full guest name
		vDocObj = vDocsRow.Ref.GetObject();
		Если СокрЛП(vDocObj.GuestFullName) <> СокрЛП(vCltObj.FullName) Тогда
			vDocObj.GuestFullName = vCltObj.FullName;
			vDocObj.Write(DocumentWriteMode.Write);
		КонецЕсли;
		// Update document change history
		vSet.Filter.Бронирование.ComparisonType = ComparisonType.Equal;
		vSet.Filter.Бронирование.Value = vDocsRow.Ref;
		vSet.Filter.Бронирование.Use = Истина;
		vSet.Read();
		Для Each vSetRow In vSet Цикл
			vSetRow.GuestFullName = vCltObj.FullName;
			vSetRow.Changes = "";
		КонецЦикла;
		vSet.Write(Истина);
	КонецЦикла;
	// Find references to the client in the resource reservation change history and clear them either
	vSet = InformationRegisters.ИсторияИзмБрониРесурсов.CreateRecordSet();
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	БроньУслуг.Ref
	|FROM
	|	Document.БроньУслуг AS БроньУслуг
	|WHERE
	|	БроньУслуг.Клиент = &qClient
	|
	|ORDER BY
	|	БроньУслуг.PointInTime";
	vQry.SetParameter("qClient", pClient);
	vDocs = vQry.Execute().Unload();
	Для Each vDocsRow In vDocs Цикл
		// Update document change history
		vSet.Filter.БроньУслуг.ComparisonType = ComparisonType.Equal;
		vSet.Filter.БроньУслуг.Value = vDocsRow.Ref;
		vSet.Filter.БроньУслуг.Use = Истина;
		vSet.Read();
		Для Each vSetRow In vSet Цикл
			vSetRow.Changes = "";
		КонецЦикла;
		vSet.Write(Истина);
	КонецЦикла;
	// Find references to the client in the accommodation change history and clear them either
	vSet = InformationRegisters.ИсторияИзмененийРазмещения.CreateRecordSet();
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	Размещение.Ref
	|FROM
	|	Document.Размещение AS Размещение
	|WHERE
	|	Размещение.Клиент = &qClient
	|
	|ORDER BY
	|	Размещение.PointInTime";
	vQry.SetParameter("qClient", pClient);
	vDocs = vQry.Execute().Unload();
	Для Each vDocsRow In vDocs Цикл
		// Update accommodation full guest name
		vDocObj = vDocsRow.Ref.GetObject();
		Если СокрЛП(vDocObj.GuestFullName) <> СокрЛП(vCltObj.FullName) Тогда
			vDocObj.GuestFullName = vCltObj.FullName;
			vDocObj.Write(DocumentWriteMode.Write);
		КонецЕсли;
		// Update document change history
		vSet.Filter.Размещение.ComparisonType = ComparisonType.Equal;
		vSet.Filter.Размещение.Value = vDocsRow.Ref;
		vSet.Filter.Размещение.Use = Истина;
		vSet.Read();
		Для Each vSetRow In vSet Цикл
			vSetRow.GuestFullName = vCltObj.FullName;
			vSetRow.Changes = "";
		КонецЦикла;
		vSet.Write(Истина);
	КонецЦикла;
	// Find references to the client in the foreigner record change history and clear them either
	vSet = InformationRegisters.ЖурналИзмененийМС.CreateRecordSet();
	vQry = Новый Query();
	vQry.Text = 
	"SELECT
	|	ForeignerRegistryRecord.Ref
	|FROM
	|	Document.ForeignerRegistryRecord AS ForeignerRegistryRecord
	|WHERE
	|	ForeignerRegistryRecord.Клиент = &qClient
	|
	|ORDER BY
	|	ForeignerRegistryRecord.PointInTime";
	vQry.SetParameter("qClient", pClient);
	vDocs = vQry.Execute().Unload();
	Для Each vDocsRow In vDocs Цикл
		// Update document
		vDocObj = vDocsRow.Ref.GetObject();
		FillPropertyValues(vDocObj, vCltObj, , "Автор, Примечания");
		vDocObj.Write(DocumentWriteMode.Write);
		// Update document change history
		vSet.Filter.ForeignerRegistryRecord.ComparisonType = ComparisonType.Equal;
		vSet.Filter.ForeignerRegistryRecord.Value = vDocsRow.Ref;
		vSet.Filter.ForeignerRegistryRecord.Use = Истина;
		vSet.Read();
		Для Each vSetRow In vSet Цикл
			FillPropertyValues(vSetRow, vCltObj, , "Автор, Примечания");
			vSetRow.Changes = "";
		КонецЦикла;
		vSet.Write(Истина);
	КонецЦикла;
КонецПроцедуры //cmHideClientNameAndNameHistory

//-----------------------------------------------------------------------------
// Description: Returns boolean true if file is editable i.e. word document, spreadsheet,
//              text or e-mail. Returns false if file is picture or pdf
// Parameters: File name
// Возврат value: Boolean, true if file is editable
//-----------------------------------------------------------------------------
Функция cmIsFileEditable(pExtension) Экспорт
	vFileExtensions = Lower(Constants.РасшРедакФайлов.Get());
	Если ПустаяСтрока(vFileExtensions) Тогда
		Если Lower(pExtension) = ".xls" 
		   ИЛИ Lower(pExtension) = ".xlsx"
		   ИЛИ Lower(pExtension) = ".doc"
		   ИЛИ Lower(pExtension) = ".docx"
		   ИЛИ Lower(pExtension) = ".txt"
		   ИЛИ Lower(pExtension) = ".rtf"
		   ИЛИ Lower(pExtension) = ".odt"
		   ИЛИ Lower(pExtension) = ".odf"
		   ИЛИ Lower(pExtension) = ".eml" Тогда
			Возврат Истина;
		КонецЕсли;
	Иначе
		vExtension = Lower(pExtension);
		Если Лев(pExtension, 1) = "." Тогда
			vExtension = Сред(vExtension, 2);
		КонецЕсли;
		Если Find(vFileExtensions, vExtension) > 0 Тогда
			Возврат Истина;
		КонецЕсли;
	КонецЕсли;
	Возврат Ложь;
КонецФункции //cmIsFileEditable

//-----------------------------------------------------------------------------
// Description: Returns path to 1C program common directory
// Parameters: None
// Возврат value: String
//-----------------------------------------------------------------------------
Функция cmCommonDir() Экспорт
	vDir = Lower(BinDir());
	vCommonPos = Find(vDir, "\1cv82\");
	Если vCommonPos > 0 Тогда
		vDir = Лев(vDir, vCommonPos + 5) + "\common\";
	КонецЕсли;
	Возврат vDir;
КонецФункции //cmCommonDir

//-----------------------------------------------------------------------------
// Description: Returns structure of report builder attributes initialized with
//              default values
// Parameters: None
// Возврат value: Structure
//-----------------------------------------------------------------------------
Функция cmGetReportBuilderAttributesStructure() Экспорт
	vStruct = Новый Structure();
	// Initialize details fill type

	
	// Set report formatting rules
	vStruct.Вставить("DimensionsPlacementOnRows", DimensionPlacementType.Together);
	vStruct.Вставить("DimensionAttributePlacementInRows", DimensionAttributePlacementType.WithDimensions);
	vStruct.Вставить("TotalsPlacementOnRows", TotalPlacementType.Header);
	
	vStruct.Вставить("DimensionsPlacementOnColumns", DimensionPlacementType.Together);
	vStruct.Вставить("DimensionAttributePlacementInColumns", DimensionAttributePlacementType.WithDimensions);
	vStruct.Вставить("TotalsPlacementOnColumns", TotalPlacementType.Header);
	
	// Apply report sections appearance rules
	vStruct.Вставить("PutReportHeader", Истина);
	vStruct.Вставить("PutTableHeader", Истина);
	vStruct.Вставить("PutDetailRecords", Истина);
	vStruct.Вставить("PutTableFooter", Истина);
	vStruct.Вставить("PutOveralls", Истина);
	vStruct.Вставить("PutReportFooter", Истина);
	
	// Show status
	vStruct.Вставить("ShowStatus", Истина);
	
	// User interrupt processing
	vStruct.Вставить("ProcessUserInterruption", Истина);
	
	// Возврат structure being build
	Возврат vStruct;
КонецФункции //cmGetReportBuilderAttributesStructure

//-----------------------------------------------------------------------------
// Description: Fills report builder attributes from the input structure
// Parameters: Report object, Attributes structure
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmSetReportBuilderAttributes(pRepObject, pAttributesStruct) Экспорт
	// Check user rights to open report
	Если НЕ cmCheckUserRightsToOpenReport(pRepObject.Report) Тогда
		ВызватьИсключение "У вас нет прав на формирование отчета:" + pRepObject.Report.Description + "!";
	КонецЕсли;
	
	// Initialize query fields presentation addition type 
	pRepObject.ReportBuilder.PresentationAdding = PresentationAdditionType.DontAdd;
	
	// Initialize details fill type
	pRepObject.ReportBuilder.DetailFillType = pAttributesStruct.DetailFillType;
	
	// Set report formatting rules
	pRepObject.ReportBuilder.DimensionsPlacementOnRows = ?(pRepObject.ReportDimensionsPlacementOnRowsType.IsEmpty(), 
	                                                       pAttributesStruct.DimensionsPlacementOnRows, 
	                                                       DimensionPlacementType[pRepObject.ReportDimensionsPlacementOnRowsType.Metadata().EnumValues[Перечисления.ReportDimensionsPlacementTypes.IndexOf(pRepObject.ReportDimensionsPlacementOnRowsType)].Name]);
	pRepObject.ReportBuilder.DimensionAttributePlacementInRows = ?(pRepObject.ReportDimensionAttributesPlacementInRowsType.IsEmpty(), 
	                                                               pAttributesStruct.DimensionAttributePlacementInRows, 
	                                                               DimensionAttributePlacementType[pRepObject.ReportDimensionAttributesPlacementInRowsType.Metadata().EnumValues[Перечисления.ReportDimensionAttributesPlacementTypes.IndexOf(pRepObject.ReportDimensionAttributesPlacementInRowsType)].Name]);
	pRepObject.ReportBuilder.TotalsPlacementOnRows = ?(pRepObject.ReportTotalsPlacementOnRowsType.IsEmpty(), 
	                                                   pAttributesStruct.TotalsPlacementOnRows, 
	                                                   TotalPlacementType[pRepObject.ReportTotalsPlacementOnRowsType.Metadata().EnumValues[Перечисления.ReportTotalsPlacementTypes.IndexOf(pRepObject.ReportTotalsPlacementOnRowsType)].Name]);
	
	pRepObject.ReportBuilder.DimensionsPlacementOnColumns = ?(pRepObject.ReportDimensionsPlacementOnColumnsType.IsEmpty(), 
	                                                          pAttributesStruct.DimensionsPlacementOnColumns, 
	                                                          DimensionPlacementType[pRepObject.ReportDimensionsPlacementOnColumnsType.Metadata().EnumValues[Перечисления.ReportDimensionsPlacementTypes.IndexOf(pRepObject.ReportDimensionsPlacementOnColumnsType)].Name]);
	pRepObject.ReportBuilder.DimensionAttributePlacementInColumns = ?(pRepObject.ReportDimensionAttributesPlacementInColumnsType.IsEmpty(), 
	                                                                  pAttributesStruct.DimensionAttributePlacementInColumns, 
	                                                                  DimensionAttributePlacementType[pRepObject.ReportDimensionAttributesPlacementInColumnsType.Metadata().EnumValues[Перечисления.ReportDimensionAttributesPlacementTypes.IndexOf(pRepObject.ReportDimensionAttributesPlacementInColumnsType)].Name]);
	pRepObject.ReportBuilder.TotalsPlacementOnColumns = ?(pRepObject.ReportTotalsPlacementOnColumnsType.IsEmpty(), 
	                                                      pAttributesStruct.TotalsPlacementOnColumns, 
	                                                      TotalPlacementType[pRepObject.ReportTotalsPlacementOnColumnsType.Metadata().EnumValues[Перечисления.ReportTotalsPlacementTypes.IndexOf(pRepObject.ReportTotalsPlacementOnColumnsType)].Name]);
	
	// Apply report sections appearance rules
	Если ЗначениеЗаполнено(pRepObject.ReportAppearanceTemplateType) Тогда
		pRepObject.ReportBuilder.PutReportHeader = НЕ pRepObject.ReportDoNotPutReportHeader;
		pRepObject.ReportBuilder.PutTableHeader = НЕ pRepObject.ReportDoNotPutTableHeader;
		pRepObject.ReportBuilder.PutDetailRecords = НЕ pRepObject.ReportDoNotPutDetailRecords;
		pRepObject.ReportBuilder.PutTableFooter = НЕ pRepObject.ReportDoNotPutTableFooter;
		pRepObject.ReportBuilder.PutOveralls = НЕ pRepObject.ReportDoNotPutOveralls;
		pRepObject.ReportBuilder.PutReportFooter = НЕ pRepObject.ReportDoNotPutReportFooter;
	Иначе
		pRepObject.ReportBuilder.PutReportHeader = pAttributesStruct.PutReportHeader;
		pRepObject.ReportBuilder.PutTableHeader = pAttributesStruct.PutTableHeader;
		pRepObject.ReportBuilder.PutDetailRecords = pAttributesStruct.PutDetailRecords;
		pRepObject.ReportBuilder.PutTableFooter = pAttributesStruct.PutTableFooter;
		pRepObject.ReportBuilder.PutOveralls = pAttributesStruct.PutOveralls;
		pRepObject.ReportBuilder.PutReportFooter = pAttributesStruct.PutReportFooter;
		
		pRepObject.ReportDoNotPutReportHeader = НЕ pAttributesStruct.PutReportHeader;
		pRepObject.ReportDoNotPutTableHeader = НЕ pAttributesStruct.PutTableHeader;
		pRepObject.ReportDoNotPutDetailRecords = НЕ pAttributesStruct.PutDetailRecords;
		pRepObject.ReportDoNotPutTableFooter = НЕ pAttributesStruct.PutTableFooter;
		pRepObject.ReportDoNotPutOveralls = НЕ pAttributesStruct.PutOveralls;
		pRepObject.ReportDoNotPutReportFooter = НЕ pAttributesStruct.PutReportFooter;
	КонецЕсли;
	
	// Set auto detail records
	Если НЕ pRepObject.ReportBuilder.PutOveralls Тогда
		pRepObject.ReportBuilder.AutoDetailRecords = Ложь;
	Иначе
		pRepObject.ReportBuilder.AutoDetailRecords = Истина;
	КонецЕсли;
	
	// Initialize report builder header text
	Если ПустаяСтрока(pRepObject.Report.ReportHeaderText) Тогда
		pRepObject.ReportBuilder.HeaderText = pRepObject.Report.Description;
	Иначе
		pRepObject.ReportBuilder.HeaderText = pRepObject.Report.ReportHeaderText;
	КонецЕсли;
	
	// Show status on put
	pRepObject.ReportBuilder.ShowStatus = pAttributesStruct.ShowStatus;
	
	// Initialize user interrupt processing
	pRepObject.ReportBuilder.ProcessUserInterruption = pAttributesStruct.ProcessUserInterruption;
КонецПроцедуры //cmSetReportBuilderAttributes

//-----------------------------------------------------------------------------
// Description: Checks if input ref is broken
// Parameters: Type of ref as string, f.e. "Catalog.Clients", "Document.SetRoomQuota"
// Возврат value: String
//-----------------------------------------------------------------------------
&AtServer
Функция cmIsBrokenRef(pSomething, pRef) Экспорт
	vQry = Новый Query;
	vQry.Text = 
	"SELECT
	|	Something.Ref
	|FROM
	|	"+pSomething+" AS Something
	|WHERE
	|	Something.Ref = &qRef";
	vQry.SetParameter("qRef", pRef);
	vQryResult = vQry.Execute().Choose();
	Пока vQryResult.Next() Цикл
		Возврат Ложь;
	КонецЦикла;
	Возврат Истина;
КонецФункции //cmIsBrokenRef

//-----------------------------------------------------------------------------
// Returns unit code by unit description
//-----------------------------------------------------------------------------
Функция cmGetUnitCode(pUnit) Экспорт
	Если ПустаяСтрока(pUnit) Тогда
		Возврат "---";
	Иначе
		vUnitRef = Справочники.ЕдИзмерения.FindByDescription(TrimR(pUnit), Ложь);
		Если ЗначениеЗаполнено(vUnitRef) Тогда
			Возврат СокрЛП(vUnitRef.Code);
		Иначе
			Возврат "---";
		КонецЕсли;
	КонецЕсли;
КонецФункции //cmGetUnitCode

//-----------------------------------------------------------------------------
// Returns chart object height for the report
//-----------------------------------------------------------------------------
Функция cmGetReportChartHeight(pRepObj) Экспорт
	Если pRepObj.ReportChartType = ChartType.Pie ИЛИ 
	   pRepObj.ReportChartType = ChartType.Pie3D ИЛИ 
	   pRepObj.ReportChartType = ChartType.Honeycomb ИЛИ 
	   pRepObj.ReportChartType = ChartType.BarGraph ИЛИ 
	   pRepObj.ReportChartType = ChartType.CeilGraph ИЛИ 
	   pRepObj.ReportChartType = ChartType.StackedArea ИЛИ 
	   pRepObj.ReportChartType = ChartType.StackedBar ИЛИ 
	   pRepObj.ReportChartType = ChartType.StackedBar3D ИЛИ 
	   pRepObj.ReportChartType = ChartType.StackedColumn ИЛИ 
	   pRepObj.ReportChartType = ChartType.StackedColumn3D ИЛИ 
	   pRepObj.ReportChartType = ChartType.StackedLine ИЛИ 
	   pRepObj.ReportChartType = ChartType.ConcaveSurface ИЛИ 
	   pRepObj.ReportChartType = ChartType.ConvexSurface ИЛИ 
	   pRepObj.ReportChartType = ChartType.NormalizedArea ИЛИ 
	   pRepObj.ReportChartType = ChartType.NormalizedBar ИЛИ 
	   pRepObj.ReportChartType = ChartType.NormalizedBar3D ИЛИ 
	   pRepObj.ReportChartType = ChartType.NormalizedColumn ИЛИ 
	   pRepObj.ReportChartType = ChartType.NormalizedColumn3D ИЛИ 
	   pRepObj.ReportChartType = ChartType.RadarArea ИЛИ 
	   pRepObj.ReportChartType = ChartType.RadarLine ИЛИ 
	   pRepObj.ReportChartType = ChartType.RadarNormalizedArea ИЛИ 
	   pRepObj.ReportChartType = ChartType.RadarStackedArea ИЛИ 
	   pRepObj.ReportChartType = ChartType.RadarStackedLine ИЛИ 
	   pRepObj.ReportChartType = ChartType.ShadedSurface ИЛИ 
	   pRepObj.ReportChartType = ChartType.Surface ИЛИ 
	   pRepObj.ReportChartType = ChartType.Waterfall ИЛИ 
	   pRepObj.ReportChartType = ChartType.WireframeSurface Тогда
		Возврат 240;
	Иначе
		Возврат 110;
	КонецЕсли;
КонецФункции //cmGetReportChartHeight

//-----------------------------------------------------------------------------
// Returns chart object width for the report
//-----------------------------------------------------------------------------
Функция cmGetReportChartWidth(pRepObj) Экспорт
	Если pRepObj.ReportPageOrientation = Перечисления.PageOrientations.Portrait Тогда
		Возврат 11;
	Иначе
		Возврат 17;
	КонецЕсли;
КонецФункции //cmGetReportChartWidth

//-----------------------------------------------------------------------------
// Description: Fills value table column headers with human readable names taken 
//              from the report template
// Parameters: Value table, Report object
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmFillValueTableColumnTitles(pValTbl, pRepObj) Экспорт
	// Get report template defined for the report
	vReportTemplate = pRepObj.GetTemplate("ReportTemplate");
	// Set column title
	Для Each vColumn In pValTbl.Columns Цикл
		// Попытка to get column name overrides
		vColumnHeaderDescription = "";
		Если pRepObj.ReportColumnOverrides.Count() > 0 Тогда
			vOverrideRow = Неопределено;
			Если pRepObj.ReportColumnOverrides.Columns.Count() > 0 Тогда
				vOverrideRow = pRepObj.ReportColumnOverrides.Find(vColumn.Name, "ColumnName");
			КонецЕсли;
			Если vOverrideRow <> Неопределено Тогда
				Попытка
					Если pRepObj.ReportColumnOverrides.Columns.Count() > 2 Тогда
						vColumnHeaderDescription = vOverrideRow.ColumnHeaderDescription;
					КонецЕсли;
				Исключение
				КонецПопытки;
			КонецЕсли;
		КонецЕсли;
		// Попытка to get report template range for the current column
		vReportAttrRange = vReportTemplate.Районы.Find(vColumn.Name);
		Если vReportAttrRange <> Неопределено Тогда
			vReportAttrHeaderRange = vReportTemplate.Районы.Find(vColumn.Name+"Header");
			Если vReportAttrHeaderRange <> Неопределено Тогда
				// Set colum title text
				Если НЕ ПустаяСтрока(vColumnHeaderDescription) Тогда
					vColumn.Title = vColumnHeaderDescription;
				Иначе
					vColumn.Title = vReportAttrHeaderRange.Text;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры //cmFillValueTableColumnTitles

//-----------------------------------------------------------------------------
// Description: Adds chart object to the report spreadsheet 
// Parameters: Report spreadsheet, Report object
// Возврат value: None
//-----------------------------------------------------------------------------
Процедура cmAddReportChart(pSpreadsheet, pRepObj) Экспорт
	// Вставить chart area
	vRepHeaderHeight = 3;
	pSpreadsheet.InsertArea(pSpreadsheet.Area(vRepHeaderHeight, , vRepHeaderHeight), pSpreadsheet.Area(vRepHeaderHeight+1, , vRepHeaderHeight+1), SpreadsheetDocumentShiftType.Vertical);
	vRepHeaderHeight = vRepHeaderHeight + 1;
	pSpreadsheet.Area(vRepHeaderHeight, , vRepHeaderHeight).Clear(Истина, Истина, Истина);
	pSpreadsheet.Area(vRepHeaderHeight, , vRepHeaderHeight).RowHeight = 5;
	pSpreadsheet.InsertArea(pSpreadsheet.Area(vRepHeaderHeight, , vRepHeaderHeight), pSpreadsheet.Area(vRepHeaderHeight+1, , vRepHeaderHeight+1), SpreadsheetDocumentShiftType.Vertical);
	vRepHeaderHeight = vRepHeaderHeight + 1;
	pSpreadsheet.Area(vRepHeaderHeight, , vRepHeaderHeight).Clear(Истина, Истина, Истина);
	pSpreadsheet.Area(vRepHeaderHeight, , vRepHeaderHeight).RowHeight = cmGetReportChartHeight(pRepObj);
	pSpreadsheet.InsertArea(pSpreadsheet.Area(vRepHeaderHeight, , vRepHeaderHeight), pSpreadsheet.Area(vRepHeaderHeight+1, , vRepHeaderHeight+1), SpreadsheetDocumentShiftType.Vertical);
	pSpreadsheet.Area(vRepHeaderHeight+1, , vRepHeaderHeight+1).Clear(Истина, Истина, Истина);
	pSpreadsheet.Area(vRepHeaderHeight+1, , vRepHeaderHeight+1).RowHeight = 5;
	
	// Add chart drawing object to the spreadsheet
	vDrawing = pSpreadsheet.Drawings.Add(SpreadsheetDocumentDrawingType.Chart);
	vDrawing.Name = "ReportChart";
	vDrawing.Place(pSpreadsheet.Area(vRepHeaderHeight, 2, vRepHeaderHeight, cmGetReportChartWidth(pRepObj)));
	vDrawing.LineColor = StyleColors.BorderColor;
	vChart = vDrawing.Object;
	
	// Disable chart
	vChart.RefreshEnabled = Ложь;
	// Fill chart parameters
	vChart.SeriesInRows = Ложь;
	vChart.TitleArea.Text = pRepObj.ReportBuilder.HeaderText;
	vChart.ValueLabelFormat = "ND=17; NFD=2; NZ="; 
	vChart.LabelType = ChartLabelType.Value; 
	Если pRepObj.ReportChartType <> Неопределено Тогда
		vChart.ChartType = pRepObj.ReportChartType;
	КонецЕсли;
	vChart.PlotArea.ShowScaleValueLines = Ложь;
	// Fill list of chart data source columns		
	vDimensionColumn = "";
	Если pRepObj.ReportBuilder.RowDimensions.Count() > 0 Тогда
		vDimensionColumn = pRepObj.ReportBuilder.RowDimensions.Get(0).Name;
	Иначе
		vDimensionColumn = pRepObj.ReportBuilder.SelectedFields.Get(0).Name;
	КонецЕсли;
	vDataSourceColumns = vDimensionColumn;
	Для Each vFld In pRepObj.ReportBuilder.SelectedFields Цикл
		Если pRepObj.pmIsResource(vFld.Name) Тогда
			Если pRepObj.ReportColumnOverrides.Columns.Count() > 4 Тогда
				vOverrideRow = pRepObj.ReportColumnOverrides.Find(vFld.Name, "ColumnName");
				Если vOverrideRow <> Неопределено Тогда
					Если vOverrideRow.ShowInChart Тогда
						vDataSourceColumns = vDataSourceColumns + ", " + vFld.Name;
					КонецЕсли;
				КонецЕсли;
			Иначе
				vDataSourceColumns = vDataSourceColumns + ", " + vFld.Name;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	// Get chart data source value table from the report builder data source
	vRBDataSource = pRepObj.ReportBuilder.Result.Unload();
	vRBDataSource = vRBDataSource.CopyColumns(vDataSourceColumns);
	Если pRepObj.ReportBuilder.RowDimensions.Count() = 0 Тогда
		vRBQryRes = pRepObj.ReportBuilder.Result.Choose(QueryResultIteration.Linear);
	Иначе
		vRBQryRes = pRepObj.ReportBuilder.Result.Choose(QueryResultIteration.ByGroups, vDimensionColumn);
	КонецЕсли;
	Пока vRBQryRes.Next() Цикл
		vRBDataSourceRow = vRBDataSource.Add();
		FillPropertyValues(vRBDataSourceRow, vRBQryRes);
	КонецЦикла;
	vChartDataSource = vRBDataSource.Copy(, vDataSourceColumns);
	// Fill chart data source columns titles from the report template column headers
	cmFillValueTableColumnTitles(vChartDataSource, pRepObj);
	// Connect data source to the chart
	Если НЕ ПустаяСтрока(vDimensionColumn) Тогда
		Если pRepObj.ReportBuilder.RowDimensions.Count() = 0 Тогда
			// Delete report totals row
			Если vChartDataSource.Count() > 0 Тогда
				vChartDataSource.Delete(vChartDataSource.Count() - 1);
			КонецЕсли;
		КонецЕсли;
		vChart.DataSource = vChartDataSource;
	КонецЕсли;
	// Draw chart
	vChart.RefreshEnabled = Истина;
	
	// Set spreadsheet output parameters
	pSpreadsheet.ReadOnly = Ложь;
	pSpreadsheet.ShowHeaders = Ложь;
	pSpreadsheet.ShowGrid = Ложь;
	pSpreadsheet.FixedTop = vRepHeaderHeight + 2;
КонецПроцедуры //cmAddReportChart

//-----------------------------------------------------------------------------
Функция cmGetFMSRecord(pText, pIsCode = Ложь, pType = "FMSListRU") Экспорт
	vQry = Новый Query();
	vQry.Text = 
	"SELECT TOP 2
	|	CodesFMS.Code AS Code,
	|	CodesFMS.ID AS ID,
	|	CodesFMS.Description AS Description
	|FROM
	|	InformationRegister.CodesFMS AS CodesFMS
	|WHERE
	|	CodesFMS.ТипРазмещения = &qType
	|	AND CodesFMS.Code LIKE &qCode
	|
	|ORDER BY
	|	Code";
	Если НЕ pIsCode Тогда
		vQry.Text = СтрЗаменить(vQry.Text,"AND CodesFMS.Code LIKE &qCode","AND CodesFMS.Description LIKE &qDescription");
		vQry.SetParameter("qDescription", "%"+СокрЛП(pText) + "%");
	КонецЕсли;
	vQry.SetParameter("qCode", СокрЛП(pText) + "%");
	vQry.SetParameter("qType", pType);
	Возврат vQry.Execute();
КонецФункции //cmGetFMSRecord 

//-----------------------------------------------------------------------------
Функция cmGetIssuedByRecord(pText, pIsCode = Ложь) Экспорт
	vQry = Новый Query();
	vQry.Text = 
	"SELECT TOP 2
	|	Клиенты.IdentityDocumentUnitCode AS Code,
	|	Клиенты.IdentityDocumentIssuedBy AS Description
	|FROM
	|	Catalog.Клиенты AS Клиенты
	|WHERE
	|	NOT Клиенты.DeletionMark
	|	AND NOT Клиенты.IsFolder
	|	AND (Клиенты.IdentityDocumentIssuedBy LIKE &qIssuedBy
	|			OR &qIsCode
	|				AND Клиенты.IdentityDocumentUnitCode = &qUnitCode)
	|GROUP BY
	|	Клиенты.IdentityDocumentUnitCode,
	|	Клиенты.IdentityDocumentIssuedBy
	|ORDER BY
	|	Description";
	vQry.SetParameter("qIssuedBy", СокрЛП(pText) + "%");
	vQry.SetParameter("qUnitCode", СокрЛП(pText));
	vQry.SetParameter("qIsCode", pIsCode);
	Возврат vQry.Execute();
КонецФункции //cmGetIssuedByRecord 

//-----------------------------------------------------------------------------
// Description: Returns if program is in simple mode
// Parameters: None
// Возврат value: Boolean
//-----------------------------------------------------------------------------
&AtServer
Функция cmIsSimpleMode() Экспорт
	vSimpleMode = Constants.ТонкиеФормы.Get();
	Если vSimpleMode Тогда
		Возврат vSimpleMode;
	Иначе
		Если ЗначениеЗаполнено(ПараметрыСеанса.ТекПользователь) Тогда
			vPGRef = cmGetEmployeePermissionGroup(ПараметрыСеанса.ТекПользователь);
			Если ЗначениеЗаполнено(vPGRef) Тогда
				Возврат vPGRef.ТонкиеФормы;
			Иначе
				Возврат Ложь;
			КонецЕсли;
		Иначе
			Возврат Ложь;
		КонецЕсли;
	КонецЕсли;
КонецФункции //cmIsSimpleMode





//-----------------------------------------------------------------------------
// Transliterate string from russian to english or from english to russian
//-----------------------------------------------------------------------------
Функция cmTransliterate(Val pStr) Экспорт
	vStr = СокрЛП(pStr);
	// Get string current language
	vIsInRussian = Истина;
	vEnABC = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	Для i = 1 По СтрДлина(vEnABC) Цикл
		vC = Сред(vEnABC, i, 1);
		Если Find(vEnABC, vC) > 0 Тогда
			vIsInRussian = Ложь;
			Прервать;
		КонецЕсли;
	КонецЦикла;
	Если vIsInRussian Тогда
		vStr = СтрЗаменить(vStr, "А", "A");
		vStr = СтрЗаменить(vStr, "а", "a");
		vStr = СтрЗаменить(vStr, "Б", "B");
		vStr = СтрЗаменить(vStr, "б", "b");
		vStr = СтрЗаменить(vStr, "В", "V");
		vStr = СтрЗаменить(vStr, "в", "v");
		vStr = СтрЗаменить(vStr, "Г", "G");
		vStr = СтрЗаменить(vStr, "г", "g");
		vStr = СтрЗаменить(vStr, "Д", "D");
		vStr = СтрЗаменить(vStr, "д", "d");
		vStr = СтрЗаменить(vStr, "Е", "E");
		vStr = СтрЗаменить(vStr, "е", "e");
		vStr = СтрЗаменить(vStr, "Ё", "E");
		vStr = СтрЗаменить(vStr, "ё", "e");
		vStr = СтрЗаменить(vStr, "Ж", "GH");
		vStr = СтрЗаменить(vStr, "ж", "gh");
		vStr = СтрЗаменить(vStr, "З", "Z");
		vStr = СтрЗаменить(vStr, "з", "z");
		vStr = СтрЗаменить(vStr, "И", "I");
		vStr = СтрЗаменить(vStr, "и", "i");
		vStr = СтрЗаменить(vStr, "Й", "Y");
		vStr = СтрЗаменить(vStr, "й", "y");
		vStr = СтрЗаменить(vStr, "К", "K");
		vStr = СтрЗаменить(vStr, "к", "k");
		vStr = СтрЗаменить(vStr, "Л", "L");
		vStr = СтрЗаменить(vStr, "л", "l");
		vStr = СтрЗаменить(vStr, "М", "M");
		vStr = СтрЗаменить(vStr, "м", "m");
		vStr = СтрЗаменить(vStr, "Н", "N");
		vStr = СтрЗаменить(vStr, "н", "n");
		vStr = СтрЗаменить(vStr, "О", "O");
		vStr = СтрЗаменить(vStr, "о", "o");
		vStr = СтрЗаменить(vStr, "П", "P");
		vStr = СтрЗаменить(vStr, "п", "p");
		vStr = СтрЗаменить(vStr, "Р", "R");
		vStr = СтрЗаменить(vStr, "р", "r");
		vStr = СтрЗаменить(vStr, "С", "S");
		vStr = СтрЗаменить(vStr, "с", "s");
		vStr = СтрЗаменить(vStr, "Т", "T");
		vStr = СтрЗаменить(vStr, "т", "t");
		vStr = СтрЗаменить(vStr, "У", "U");
		vStr = СтрЗаменить(vStr, "у", "u");
		vStr = СтрЗаменить(vStr, "Ф", "F");
		vStr = СтрЗаменить(vStr, "ф", "f");
		vStr = СтрЗаменить(vStr, "Х", "H");
		vStr = СтрЗаменить(vStr, "х", "h");
		vStr = СтрЗаменить(vStr, "Ц", "C");
		vStr = СтрЗаменить(vStr, "ц", "c");
		vStr = СтрЗаменить(vStr, "Ч", "CH");
		vStr = СтрЗаменить(vStr, "ч", "ch");
		vStr = СтрЗаменить(vStr, "Ш", "SH");
		vStr = СтрЗаменить(vStr, "ш", "sh");
		vStr = СтрЗаменить(vStr, "Щ", "SCH");
		vStr = СтрЗаменить(vStr, "щ", "sch");
		vStr = СтрЗаменить(vStr, "Ь", "");
		vStr = СтрЗаменить(vStr, "ь", "");
		vStr = СтрЗаменить(vStr, "Ы", "YI");
		vStr = СтрЗаменить(vStr, "ы", "yi");
		vStr = СтрЗаменить(vStr, "Ъ", "");
		vStr = СтрЗаменить(vStr, "ъ", "");
		vStr = СтрЗаменить(vStr, "Э", "E");
		vStr = СтрЗаменить(vStr, "э", "e");
		vStr = СтрЗаменить(vStr, "Ю", "YU");
		vStr = СтрЗаменить(vStr, "ю", "yu");
		vStr = СтрЗаменить(vStr, "Я", "YA");
		vStr = СтрЗаменить(vStr, "я", "ya");
	Иначе
		vStr = СтрЗаменить(vStr, "Ya", "Я");
		vStr = СтрЗаменить(vStr, "ya", "я");
		vStr = СтрЗаменить(vStr, "A", "А");
		vStr = СтрЗаменить(vStr, "a", "а");
		vStr = СтрЗаменить(vStr, "B", "Б");
		vStr = СтрЗаменить(vStr, "b", "б");
		vStr = СтрЗаменить(vStr, "Sch", "Щ");
		vStr = СтрЗаменить(vStr, "sch", "щ");
		vStr = СтрЗаменить(vStr, "Sh", "Ш");
		vStr = СтрЗаменить(vStr, "sh", "ш");
		vStr = СтрЗаменить(vStr, "Ch", "Ч");
		vStr = СтрЗаменить(vStr, "ch", "ч");
		vStr = СтрЗаменить(vStr, "Zh", "Ж");
		vStr = СтрЗаменить(vStr, "zh", "ж");
		vStr = СтрЗаменить(vStr, "C", "К");
		vStr = СтрЗаменить(vStr, "c", "к");
		vStr = СтрЗаменить(vStr, "D", "Д");
		vStr = СтрЗаменить(vStr, "d", "д");
		vStr = СтрЗаменить(vStr, "E", "Е");
		vStr = СтрЗаменить(vStr, "e", "е");
		vStr = СтрЗаменить(vStr, "F", "Ф");
		vStr = СтрЗаменить(vStr, "f", "ф");
		vStr = СтрЗаменить(vStr, "G", "Г");
		vStr = СтрЗаменить(vStr, "g", "г");
		vStr = СтрЗаменить(vStr, "H", "Х");
		vStr = СтрЗаменить(vStr, "h", "х");
		vStr = СтрЗаменить(vStr, "I", "И");
		vStr = СтрЗаменить(vStr, "i", "и");
		vStr = СтрЗаменить(vStr, "J", "Ж");
		vStr = СтрЗаменить(vStr, "j", "ж");
		vStr = СтрЗаменить(vStr, "K", "К");
		vStr = СтрЗаменить(vStr, "k", "к");
		vStr = СтрЗаменить(vStr, "L", "Л");
		vStr = СтрЗаменить(vStr, "l", "л");
		vStr = СтрЗаменить(vStr, "M", "М");
		vStr = СтрЗаменить(vStr, "m", "м");
		vStr = СтрЗаменить(vStr, "N", "Н");
		vStr = СтрЗаменить(vStr, "n", "н");
		vStr = СтрЗаменить(vStr, "O", "О");
		vStr = СтрЗаменить(vStr, "o", "о");
		vStr = СтрЗаменить(vStr, "P", "П");
		vStr = СтрЗаменить(vStr, "p", "п");
		vStr = СтрЗаменить(vStr, "Q", "К");
		vStr = СтрЗаменить(vStr, "q", "к");
		vStr = СтрЗаменить(vStr, "R", "Р");
		vStr = СтрЗаменить(vStr, "r", "р");
		vStr = СтрЗаменить(vStr, "S", "С");
		vStr = СтрЗаменить(vStr, "s", "с");
		vStr = СтрЗаменить(vStr, "T", "Т");
		vStr = СтрЗаменить(vStr, "t", "т");
		vStr = СтрЗаменить(vStr, "Yu", "Ю");
		vStr = СтрЗаменить(vStr, "yu", "ю");
		vStr = СтрЗаменить(vStr, "U", "У");
		vStr = СтрЗаменить(vStr, "u", "у");
		vStr = СтрЗаменить(vStr, "V", "В");
		vStr = СтрЗаменить(vStr, "v", "в");
		vStr = СтрЗаменить(vStr, "W", "В");
		vStr = СтрЗаменить(vStr, "w", "в");
		vStr = СтрЗаменить(vStr, "X", "Кс");
		vStr = СтрЗаменить(vStr, "x", "кс");
		vStr = СтрЗаменить(vStr, "Y", "Й");
		vStr = СтрЗаменить(vStr, "y", "й");
		vStr = СтрЗаменить(vStr, "Z", "З");
		vStr = СтрЗаменить(vStr, "z", "з");
	КонецЕсли;
	Возврат vStr;
КонецФункции //cmTransliterate
