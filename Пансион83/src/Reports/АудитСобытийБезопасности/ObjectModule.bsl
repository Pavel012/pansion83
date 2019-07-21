////-----------------------------------------------------------------------------
//// Reports framework start
////-----------------------------------------------------------------------------
//
////-----------------------------------------------------------------------------
//Процедура pmSaveReportAttributes() Экспорт
//	cmSaveReportAttributes(ThisObject);
//КонецПроцедуры //pmSaveReportAttributes
//
////-----------------------------------------------------------------------------
//Процедура pmLoadReportAttributes(pParameter = Неопределено) Экспорт
//	cmLoadReportAttributes(ThisObject, pParameter);
//КонецПроцедуры //pmLoadReportAttributes
//
////-----------------------------------------------------------------------------
//// Initialize attributes with default values
//// Attention: This procedure could be called AFTER some attributes initialization
//// routine, so it SHOULD NOT reset attributes being set before
////-----------------------------------------------------------------------------
//Процедура pmFillAttributesWithDefaultValues() Экспорт
//	// Fill parameters with default values
//	If НЕ ЗначениеЗаполнено(Гостиница) Тогда
//		Гостиница = ПараметрыСеанса.ТекущаяГостиница;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(PeriodFrom) Тогда
//		PeriodFrom = BegOfDay(CurrentDate()); // For today
//		PeriodTo = EndOfDay(PeriodFrom);
//	EndIf;
//КонецПроцедуры //pmFillAttributesWithDefaultValues
//
////-----------------------------------------------------------------------------
//Function pmGetReportParametersPresentation() Экспорт
//	vParamPresentation = "";
//	If ЗначениеЗаполнено(Гостиница) Тогда
//		If НЕ Гостиница.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("en='Гостиница ';ru='Гостиница ';de='Гостиница'") + 
//			                     Гостиница.GetObject().pmGetHotelPrintName(ПараметрыСеанса.ТекЛокализация) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("en='Hotels folder ';ru='Группа гостиниц ';de='Gruppe Hotels '") + 
//			                     Гостиница.GetObject().pmGetHotelPrintName(ПараметрыСеанса.ТекЛокализация) + 
//			                     ";" + Chars.LF;
//		EndIf;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(PeriodFrom) And НЕ ЗначениеЗаполнено(PeriodTo) Тогда
//		vParamPresentation = vParamPresentation + NStr("en='Report period is not set';ru='Период отчета не установлен';de='Berichtszeitraum nicht festgelegt'") + 
//		                     ";" + Chars.LF;
//	ElsIf НЕ ЗначениеЗаполнено(PeriodFrom) And ЗначениеЗаполнено(PeriodTo) Тогда
//		vParamPresentation = vParamPresentation + NStr("ru = 'Период c '; en = 'Period from '") + 
//		                     Format(PeriodFrom, "DF='dd.MM.yyyy HH:mm:ss'") + 
//		                     ";" + Chars.LF;
//	ElsIf ЗначениеЗаполнено(PeriodFrom) And НЕ ЗначениеЗаполнено(PeriodTo) Тогда
//		vParamPresentation = vParamPresentation + NStr("ru = 'Период по '; en = 'Period to '") + 
//		                     Format(PeriodTo, "DF='dd.MM.yyyy HH:mm:ss'") + 
//		                     ";" + Chars.LF;
//	ElsIf PeriodFrom = PeriodTo Тогда
//		vParamPresentation = vParamPresentation + NStr("ru = 'Период на '; en = 'Period on '") + 
//		                     Format(PeriodFrom, "DF='dd.MM.yyyy HH:mm:ss'") + 
//		                     ";" + Chars.LF;
//	ElsIf PeriodFrom < PeriodTo Тогда
//		vParamPresentation = vParamPresentation + NStr("ru = 'Период '; en = 'Period '") + PeriodPresentation(PeriodFrom, PeriodTo, cmLocalizationCode()) + 
//		                     ";" + Chars.LF;
//	Else
//		vParamPresentation = vParamPresentation + NStr("en='Period is wrong!';ru='Неправильно задан период!';de='Der Zeitraum wurde falsch eingetragen!'") + 
//		                     ";" + Chars.LF;
//	EndIf;
//	If НЕ IsBlankString(EventType) Тогда
//		vParamPresentation = vParamPresentation + NStr("ru = 'Тип события '; en = 'Event type '") + 
//							 TrimAll(EventType) + 
//							 ";" + Chars.LF;
//	EndIf;					 
//	If НЕ IsBlankString(CardType) Тогда
//		vParamPresentation = vParamPresentation + NStr("ru = 'Тип карты '; en = 'Card type '") + 
//							 TrimAll(CardType) + 
//							 ";" + Chars.LF;
//	EndIf;					 
//	If ЗначениеЗаполнено(RoomType) Тогда
//		If НЕ RoomType.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("en='ГруппаНомеров type ';ru='Тип номера ';de='Zimmertyp'") + 
//			                     TrimAll(RoomType.Description) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("en='ГруппаНомеров types folder ';ru='Группа типов номеров ';de='Gruppe Zimmertypen'") + 
//			                     TrimAll(RoomType.Description) + 
//			                     ";" + Chars.LF;
//		EndIf;
//	EndIf;							 
//	If ЗначениеЗаполнено(ГруппаНомеров) Тогда
//		If НЕ ГруппаНомеров.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("en='ГруппаНомеров ';ru='Номер ';de='Zimmer'") + 
//			                     TrimAll(ГруппаНомеров.Description) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("en='Rooms folder ';ru='Группа номеров ';de='Gruppe Zimmer '") + 
//			                     TrimAll(ГруппаНомеров.Description) + 
//			                     ";" + Chars.LF;
//		EndIf;
//	EndIf;							 
//	If ShowSuspiciousEventsOnly Тогда
//		vParamPresentation = vParamPresentation + NStr("en='Show vacant rooms events only';ru='Показывать только события в свободных номерах';de='Nur Ereignissen in freien Zimmern anzeigen'") + 
//							 ";" + Chars.LF;
//	EndIf;
//	Return vParamPresentation;
//EndFunction //pmGetReportParametersPresentation
//
////-----------------------------------------------------------------------------
//// Runs report
////-----------------------------------------------------------------------------
//Процедура pmGenerate(pSpreadsheet) Экспорт
//	Перем vTemplateAttributes;
//	
//	// Reset report builder template
//	ReportBuilder.Template = Неопределено;
//	
//	// Initialize report builder query generator attributes
//	ReportBuilder.PresentationAdding = PresentationAdditionType.Add;
//	
//	// Fill report parameters
//	ReportBuilder.Parameters.Вставить("qHotel", Гостиница);
//	ReportBuilder.Parameters.Вставить("qHotelIsEmpty", НЕ ЗначениеЗаполнено(Гостиница));
//	ReportBuilder.Parameters.Вставить("qPeriodFrom", PeriodFrom);
//	ReportBuilder.Parameters.Вставить("qPeriodTo", PeriodTo);
//	ReportBuilder.Parameters.Вставить("qEventType", EventType);
//	ReportBuilder.Parameters.Вставить("qEventTypeIsEmpty", IsBlankString(EventType));
//	ReportBuilder.Parameters.Вставить("qCardType", CardType);
//	ReportBuilder.Parameters.Вставить("qCardTypeIsEmpty", IsBlankString(CardType));
//	ReportBuilder.Parameters.Вставить("qRoomType", RoomType);
//	ReportBuilder.Parameters.Вставить("qRoomTypeIsEmpty", НЕ ЗначениеЗаполнено(RoomType));
//	ReportBuilder.Parameters.Вставить("qRoom", ГруппаНомеров);
//	ReportBuilder.Parameters.Вставить("qRoomIsEmpty", НЕ ЗначениеЗаполнено(ГруппаНомеров));
//	ReportBuilder.Parameters.Вставить("qShowSuspiciousEventsOnly", ShowSuspiciousEventsOnly);
//	
//	// Execute report builder query
//	ReportBuilder.Execute();
//	
//	// Apply appearance settings to the report template
//	//vTemplateAttributes = cmApplyReportTemplateAppearance(ThisObject);
//	
//	// Output report to the spreadsheet
//	ReportBuilder.Put(pSpreadsheet);
//	//ReportBuilder.Template.Show(); // For debug purpose
//
//	// Apply appearance settings to the report spreadsheet
//	//cmApplyReportAppearance(ThisObject, pSpreadsheet, vTemplateAttributes);
//КонецПроцедуры //pmGenerate
//	
////-----------------------------------------------------------------------------
//Процедура pmInitializeReportBuilder() Экспорт
//	ReportBuilder = New ReportBuilder();
//	
//	// Initialize default query text
//	QueryText = 
//	"SELECT
//	|	SafetySystemEvents.Period AS Period,
//	|	SafetySystemEvents.Автор AS Автор,
//	|	SafetySystemEvents.Гостиница AS Гостиница,
//	|	SafetySystemEvents.EventType,
//	|	SafetySystemEvents.НомерРазмещения AS НомерРазмещения,
//	|	SafetySystemEvents.CardType,
//	|	SafetySystemEvents.CardCode,
//	|	SafetySystemEvents.EventDescription,
//	|	SafetySystemEvents.ПериодС AS CardPeriodFrom,
//	|	SafetySystemEvents.ПериодПо AS CardPeriodTo,
//	|	SafetySystemEvents.ДокОснование AS CardDoc,
//	|	SafetySystemEvents.Клиент AS CardGuest,
//	|	SafetySystemEvents.IsActive,
//	|	Размещение.Recorder AS Doc,
//	|	Размещение.Клиент AS Клиент,
//	|	Размещение.CheckInDate AS CheckInDate,
//	|	Размещение.Продолжительность AS Продолжительность,
//	|	Размещение.CheckOutDate AS CheckOutDate,
//	|	1 AS СчетчикДокКвота,
//	|	SafetySystemEvents.NumberOfKeys AS NumberOfKeys
//	|{SELECT
//	|	Period,
//	|	Автор.*,
//	|	(HOUR(SafetySystemEvents.Period)) AS AccountingHour,
//	|	(BEGINOFPERIOD(SafetySystemEvents.Period, DAY)) AS УчетнаяДата,
//	|	(WEEK(SafetySystemEvents.Period)) AS AccountingWeek,
//	|	(MONTH(SafetySystemEvents.Period)) AS AccountingMonth,
//	|	(QUARTER(SafetySystemEvents.Period)) AS AccountingQuarter,
//	|	(YEAR(SafetySystemEvents.Period)) AS AccountingYear,
//	|	Гостиница.*,
//	|	EventType,
//	|	НомерРазмещения.*,
//	|	CardType,
//	|	CardCode,
//	|	EventDescription,
//	|	CardPeriodFrom,
//	|	CardPeriodTo,
//	|	CardDoc.*,
//	|	CardGuest.*,
//	|	IsActive,
//	|	Doc.*,
//	|	Клиент.*,
//	|	CheckInDate,
//	|	Продолжительность,
//	|	CheckOutDate,
//	|	Размещение.ТипКлиента.* AS ТипКлиента,
//	|	Размещение.Контрагент.* AS Контрагент,
//	|	Размещение.ТипКонтрагента.* AS ТипКонтрагента,
//	|	Размещение.Договор.* AS Договор,
//	|	Размещение.Агент.* AS Агент,
//	|	Размещение.СтатусРазмещения.* AS СтатусРазмещения,
//	|	Размещение.ТипНомера.* AS ТипНомера,
//	|	Размещение.ВидРазмещения.* AS ВидРазмещения,
//	|	Размещение.Тариф.* AS Тариф,
//	|	Размещение.Примечания AS Примечания,
//	|	Размещение.ГруппаГостей.* AS ГруппаГостей,
//	|	Размещение.КоличествоЧеловек AS КоличествоЧеловек,
//	|	Размещение.ПутевкаКурсовка.* AS ПутевкаКурсовка,
//	|	Размещение.КвотаНомеров.* AS КвотаНомеров,
//	|	Размещение.МаретингНапрвл.* AS МаретингНапрвл,
//	|	Размещение.TripPurpose.* AS TripPurpose,
//	|	Размещение.ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
//	|	Размещение.ДисконтКарт.* AS ДисконтКарт,
//	|	Размещение.ТипСкидки.* AS ТипСкидки,
//	|	Размещение.Скидка AS Скидка,
//	|	Размещение.КомиссияАгента AS КомиссияАгента,
//	|	Размещение.ВидКомиссииАгента AS ВидКомиссииАгента,
//	|	Размещение.PricePresentation AS PricePresentation,
//	|	Размещение.Reservation.* AS Reservation,
//	|	Размещение.IsMaster AS IsMaster,
//	|	СчетчикДокКвота,
//	|	NumberOfKeys}
//	|FROM
//	|	InformationRegister.SafetySystemEvents AS SafetySystemEvents
//	|		LEFT JOIN AccumulationRegister.ЗагрузкаНомеров AS Размещение
//	|		ON (Размещение.НомерРазмещения = SafetySystemEvents.НомерРазмещения)
//	|			AND (Размещение.CheckInDate <= SafetySystemEvents.Period)
//	|			AND (Размещение.CheckOutDate > SafetySystemEvents.Period)
//	|			AND (Размещение.IsAccommodation)
//	|			AND (Размещение.RecordType = VALUE(AccumulationRecordType.Expense))
//	|			AND (Размещение.CheckInDate = Размещение.Period)
//	|WHERE
//	|	SafetySystemEvents.Period >= &qPeriodFrom
//	|	AND SafetySystemEvents.Period <= &qPeriodTo
//	|	AND (SafetySystemEvents.EventType = &qEventType
//	|			OR &qEventTypeIsEmpty)
//	|	AND (SafetySystemEvents.CardType = &qCardType
//	|			OR &qCardTypeIsEmpty)
//	|	AND (SafetySystemEvents.НомерРазмещения.ТипНомера IN HIERARCHY (&qRoomType)
//	|			OR &qRoomTypeIsEmpty)
//	|	AND (SafetySystemEvents.НомерРазмещения IN HIERARCHY (&qRoom)
//	|			OR &qRoomIsEmpty)
//	|	AND (SafetySystemEvents.Гостиница IN HIERARCHY (&qHotel)
//	|			OR &qHotelIsEmpty)
//	|	AND (&qShowSuspiciousEventsOnly
//	|				AND Размещение.Recorder IS NULL 
//	|			OR NOT &qShowSuspiciousEventsOnly)
//	|{WHERE
//	|	SafetySystemEvents.Period,
//	|	SafetySystemEvents.Автор.* AS Автор,
//	|	SafetySystemEvents.Гостиница.* AS Гостиница,
//	|	SafetySystemEvents.EventType AS EventType,
//	|	SafetySystemEvents.НомерРазмещения.* AS НомерРазмещения,
//	|	SafetySystemEvents.CardType AS CardType,
//	|	SafetySystemEvents.CardCode AS CardCode,
//	|	SafetySystemEvents.EventDescription AS EventDescription,
//	|	SafetySystemEvents.ПериодС AS CardPeriodFrom,
//	|	SafetySystemEvents.ПериодПо AS CardPeriodTo,
//	|	SafetySystemEvents.ДокОснование.* AS CardDoc,
//	|	SafetySystemEvents.Клиент.* AS CardGuest,
//	|	SafetySystemEvents.IsActive AS IsActive,
//	|	Размещение.Recorder.* AS Doc,
//	|	Размещение.Клиент.* AS Клиент,
//	|	Размещение.CheckInDate AS CheckInDate,
//	|	Размещение.Продолжительность AS Продолжительность,
//	|	Размещение.CheckOutDate AS CheckOutDate,
//	|	Размещение.ТипКлиента.* AS ТипКлиента,
//	|	Размещение.Контрагент.* AS Контрагент,
//	|	Размещение.ТипКонтрагента.* AS ТипКонтрагента,
//	|	Размещение.Договор.* AS Договор,
//	|	Размещение.Агент.* AS Агент,
//	|	Размещение.СтатусРазмещения.* AS СтатусРазмещения,
//	|	Размещение.ТипНомера.* AS ТипНомера,
//	|	Размещение.ВидРазмещения.* AS ВидРазмещения,
//	|	Размещение.Тариф.* AS Тариф,
//	|	Размещение.Примечания AS Примечания,
//	|	Размещение.ГруппаГостей.* AS ГруппаГостей,
//	|	Размещение.КоличествоЧеловек AS КоличествоЧеловек,
//	|	Размещение.ПутевкаКурсовка.* AS ПутевкаКурсовка,
//	|	Размещение.КвотаНомеров.* AS КвотаНомеров,
//	|	Размещение.МаретингНапрвл.* AS МаретингНапрвл,
//	|	Размещение.TripPurpose.* AS TripPurpose,
//	|	Размещение.ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
//	|	Размещение.ДисконтКарт.* AS ДисконтКарт,
//	|	Размещение.ТипСкидки.* AS ТипСкидки,
//	|	Размещение.Скидка AS Скидка,
//	|	Размещение.КомиссияАгента AS КомиссияАгента,
//	|	Размещение.ВидКомиссииАгента AS ВидКомиссииАгента,
//	|	Размещение.PricePresentation AS PricePresentation,
//	|	Размещение.Reservation.* AS Reservation,
//	|	Размещение.IsMaster AS IsMaster,
//	|	SafetySystemEvents.NumberOfKeys}
//	|
//	|ORDER BY
//	|	Гостиница,
//	|	НомерРазмещения,
//	|	Period
//	|{ORDER BY
//	|	Period,
//	|	Гостиница.*,
//	|	EventType,
//	|	НомерРазмещения.*,
//	|	Автор.*,
//	|	CardType,
//	|	CardCode,
//	|	CardPeriodFrom,
//	|	CardPeriodTo,
//	|	CardDoc.*,
//	|	CardGuest.*,
//	|	IsActive,
//	|	Doc.*,
//	|	Размещение.Reservation.*,
//	|	Клиент.*,
//	|	CheckInDate,
//	|	Продолжительность,
//	|	CheckOutDate,
//	|	Размещение.ТипКлиента.* AS ТипКлиента,
//	|	Размещение.Контрагент.* AS Контрагент,
//	|	Размещение.ТипКонтрагента.* AS ТипКонтрагента,
//	|	Размещение.Договор.* AS Договор,
//	|	Размещение.Агент.* AS Агент,
//	|	Размещение.СтатусРазмещения.* AS СтатусРазмещения,
//	|	Размещение.ТипНомера.* AS ТипНомера,
//	|	Размещение.ВидРазмещения.* AS ВидРазмещения,
//	|	Размещение.Тариф.* AS Тариф,
//	|	Размещение.Примечания AS Примечания,
//	|	Размещение.ГруппаГостей.* AS ГруппаГостей,
//	|	Размещение.КоличествоЧеловек AS КоличествоЧеловек,
//	|	Размещение.ПутевкаКурсовка.* AS ПутевкаКурсовка,
//	|	Размещение.КвотаНомеров.* AS КвотаНомеров,
//	|	Размещение.МаретингНапрвл.* AS МаретингНапрвл,
//	|	Размещение.TripPurpose.* AS TripPurpose,
//	|	Размещение.ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
//	|	Размещение.ДисконтКарт.* AS ДисконтКарт,
//	|	Размещение.ТипСкидки.* AS ТипСкидки,
//	|	Размещение.Скидка AS Скидка,
//	|	Размещение.КомиссияАгента AS КомиссияАгента,
//	|	Размещение.ВидКомиссииАгента AS ВидКомиссииАгента,
//	|	Размещение.PricePresentation AS PricePresentation,
//	|	Размещение.IsMaster AS IsMaster,
//	|	NumberOfKeys}
//	|TOTALS
//	|	SUM(СчетчикДокКвота),
//	|	SUM(NumberOfKeys)
//	|BY
//	|	OVERALL
//	|{TOTALS BY
//	|	Period,
//	|	(HOUR(SafetySystemEvents.Period)) AS AccountingHour,
//	|	(BEGINOFPERIOD(SafetySystemEvents.Period, DAY)) AS УчетнаяДата,
//	|	(WEEK(SafetySystemEvents.Period)) AS AccountingWeek,
//	|	(MONTH(SafetySystemEvents.Period)) AS AccountingMonth,
//	|	(QUARTER(SafetySystemEvents.Period)) AS AccountingQuarter,
//	|	(YEAR(SafetySystemEvents.Period)) AS AccountingYear,
//	|	Гостиница.*,
//	|	EventType,
//	|	НомерРазмещения.*,
//	|	CardType,
//	|	CardCode,
//	|	Doc.*,
//	|	Клиент.*,
//	|	CheckInDate,
//	|	Продолжительность,
//	|	CheckOutDate,
//	|	Размещение.ТипКлиента.* AS ТипКлиента,
//	|	Размещение.Контрагент.* AS Контрагент,
//	|	Размещение.ТипКонтрагента.* AS ТипКонтрагента,
//	|	Размещение.Договор.* AS Договор,
//	|	Размещение.Агент.* AS Агент,
//	|	Размещение.СтатусРазмещения.* AS СтатусРазмещения,
//	|	Размещение.ТипНомера.* AS ТипНомера,
//	|	Размещение.ВидРазмещения.* AS ВидРазмещения,
//	|	Размещение.Тариф.* AS Тариф,
//	|	Размещение.Примечания AS Примечания,
//	|	Размещение.ГруппаГостей.* AS ГруппаГостей,
//	|	Размещение.КоличествоЧеловек AS КоличествоЧеловек,
//	|	Размещение.ПутевкаКурсовка.* AS ПутевкаКурсовка,
//	|	Размещение.КвотаНомеров.* AS КвотаНомеров,
//	|	Размещение.МаретингНапрвл.* AS МаретингНапрвл,
//	|	Размещение.TripPurpose.* AS TripPurpose,
//	|	Размещение.ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
//	|	Размещение.ДисконтКарт.* AS ДисконтКарт,
//	|	Размещение.ТипСкидки.* AS ТипСкидки,
//	|	Размещение.Скидка AS Скидка,
//	|	Размещение.КомиссияАгента AS КомиссияАгента,
//	|	Размещение.ВидКомиссииАгента AS ВидКомиссииАгента,
//	|	Размещение.PricePresentation AS PricePresentation,
//	|	Размещение.IsMaster AS IsMaster}";
//	ReportBuilder.Text = QueryText;
//	ReportBuilder.FillSettings();
//	
//	// Initialize report builder with default query
//	vRB = New ReportBuilder(QueryText);
//	vRBSettings = vRB.GetSettings(True, True, True, True, True);
//	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
//	
//	// Set default report builder header text
//	ReportBuilder.HeaderText = NStr("en='Safety system events audit';ru='Аудит событий системы безопасности';de='Audit der Ereignisse des Sicherheitssystems'");
//	
//	// Fill report builder fields presentations from the report template
//	cmFillReportAttributesPresentations(ThisObject);
//	
//	// Reset report builder template
//	ReportBuilder.Template = Неопределено;
//КонецПроцедуры //pmInitializeReportBuilder
//
////-----------------------------------------------------------------------------
//// Reports framework end
////-----------------------------------------------------------------------------
