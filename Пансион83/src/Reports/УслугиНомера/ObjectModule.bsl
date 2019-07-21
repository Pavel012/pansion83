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
//	If НЕ IsBlankString(RoomServiceChargeType) Тогда
//		vParamPresentation = vParamPresentation + NStr("ru = 'Тип начисления на номер '; en = 'ГруппаНомеров service charge type '") + 
//							 TrimAll(RoomServiceChargeType) + 
//							 ";" + Chars.LF;
//	EndIf;					 
//	If ЗначениеЗаполнено(RoomService) Тогда
//		If НЕ RoomService.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("ru = 'Услуга на номер '; en = 'ГруппаНомеров service '") + 
//			                     TrimAll(RoomService.Description) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("ru = 'Группа услуг '; en = 'Services folder '") + 
//			                     TrimAll(RoomService.Description) + 
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
//	ReportBuilder.Parameters.Вставить("qRoomServiceChargeType", RoomServiceChargeType);
//	ReportBuilder.Parameters.Вставить("qRoomServiceChargeTypeIsEmpty", IsBlankString(RoomServiceChargeType));
//	ReportBuilder.Parameters.Вставить("qRoomService", RoomService);
//	ReportBuilder.Parameters.Вставить("qRoomServiceIsEmpty", НЕ ЗначениеЗаполнено(RoomService));
//	ReportBuilder.Parameters.Вставить("qRoom", ГруппаНомеров);
//	ReportBuilder.Parameters.Вставить("qRoomIsEmpty", НЕ ЗначениеЗаполнено(ГруппаНомеров));
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
//	|	УслугиНомера.Period,
//	|	УслугиНомера.ServiceDate AS ServiceDate,
//	|	УслугиНомера.RoomServiceChargeType,
//	|	УслугиНомера.RoomService,
//	|	УслугиНомера.НомерРазмещения,
//	|	УслугиНомера.Количество AS Количество,
//	|	УслугиНомера.Цена,
//	|	УслугиНомера.Валюта,
//	|	УслугиНомера.Сумма AS Сумма,
//	|	УслугиНомера.FixedServiceSum AS FixedServiceSum,
//	|	УслугиНомера.Примечания,
//	|	УслугиНомера.СчетПроживания
//	|{SELECT
//	|	Period,
//	|	(HOUR(УслугиНомера.Period)) AS AccountingHour,
//	|	(BEGINOFPERIOD(УслугиНомера.Period, DAY)) AS УчетнаяДата,
//	|	(WEEK(УслугиНомера.Period)) AS AccountingWeek,
//	|	(MONTH(УслугиНомера.Period)) AS AccountingMonth,
//	|	(QUARTER(УслугиНомера.Period)) AS AccountingQuarter,
//	|	(YEAR(УслугиНомера.Period)) AS AccountingYear,
//	|	УслугиНомера.Recorder.*,
//	|	ServiceDate,
//	|	(HOUR(УслугиНомера.ServiceDate)) AS ServiceHour,
//	|	(BEGINOFPERIOD(УслугиНомера.ServiceDate, DAY)) AS ServiceDay,
//	|	(WEEK(УслугиНомера.ServiceDate)) AS ServiceWeek,
//	|	(MONTH(УслугиНомера.ServiceDate)) AS ServiceMonth,
//	|	(QUARTER(УслугиНомера.ServiceDate)) AS ServiceQuarter,
//	|	(YEAR(УслугиНомера.ServiceDate)) AS ServiceYear,
//	|	RoomServiceChargeType,
//	|	RoomService.*,
//	|	НомерРазмещения.*,
//	|	Количество,
//	|	Цена,
//	|	Валюта.*,
//	|	Сумма,
//	|	FixedServiceSum,
//	|	Примечания,
//	|	СчетПроживания.*,
//	|	УслугиНомера.Гостиница.*,
//	|	УслугиНомера.Фирма.*,
//	|	УслугиНомера.RoomServicePriceIsWithVAT,
//	|	УслугиНомера.ЕдИзмерения,
//	|	УслугиНомера.СтавкаНДС.*,
//	|	УслугиНомера.СуммаНДС,
//	|	УслугиНомера.Начисление.*,
//	|	УслугиНомера.FixedService.*,
//	|	УслугиНомера.FixedServiceVATRate.*,
//	|	УслугиНомера.FixedServiceVATSum,
//	|	УслугиНомера.FixedServiceCharge.*,
//	|	УслугиНомера.ExchangeRateDate,
//	|	УслугиНомера.Автор.*,
//	|	УслугиНомера.PointInTime}
//	|FROM
//	|	AccumulationRegister.УслугиНомера AS УслугиНомера
//	|WHERE
//	|	(УслугиНомера.Гостиница IN HIERARCHY (&qHotel)
//	|			OR &qHotelIsEmpty)
//	|	AND УслугиНомера.ServiceDate >= &qPeriodFrom
//	|	AND УслугиНомера.ServiceDate < &qPeriodTo
//	|	AND (УслугиНомера.RoomServiceChargeType = &qRoomServiceChargeType
//	|			OR &qRoomServiceChargeTypeIsEmpty)
//	|	AND (УслугиНомера.RoomService IN HIERARCHY (&qRoomService)
//	|			OR &qRoomServiceIsEmpty)
//	|	AND (УслугиНомера.НомерРазмещения IN HIERARCHY (&qRoom)
//	|			OR &qRoomIsEmpty)
//	|{WHERE
//	|	УслугиНомера.Period,
//	|	УслугиНомера.Recorder.*,
//	|	УслугиНомера.ServiceDate,
//	|	УслугиНомера.RoomServiceChargeType,
//	|	УслугиНомера.RoomService.*,
//	|	УслугиНомера.НомерРазмещения.*,
//	|	УслугиНомера.Количество,
//	|	УслугиНомера.Цена,
//	|	УслугиНомера.Валюта.*,
//	|	УслугиНомера.Сумма,
//	|	УслугиНомера.FixedServiceSum,
//	|	УслугиНомера.Примечания,
//	|	УслугиНомера.СчетПроживания.*,
//	|	УслугиНомера.Гостиница.*,
//	|	УслугиНомера.Фирма.*,
//	|	УслугиНомера.RoomServicePriceIsWithVAT,
//	|	УслугиНомера.ЕдИзмерения,
//	|	УслугиНомера.СтавкаНДС.*,
//	|	УслугиНомера.СуммаНДС,
//	|	УслугиНомера.Начисление.*,
//	|	УслугиНомера.FixedService.*,
//	|	УслугиНомера.FixedServiceVATRate.*,
//	|	УслугиНомера.FixedServiceVATSum,
//	|	УслугиНомера.FixedServiceCharge.*,
//	|	УслугиНомера.ExchangeRateDate,
//	|	УслугиНомера.CurrencyExchangeRate,
//	|	УслугиНомера.Автор.*,
//	|	УслугиНомера.PointInTime}
//	|
//	|ORDER BY
//	|	ServiceDate
//	|{ORDER BY
//	|	Period,
//	|	УслугиНомера.Recorder.*,
//	|	ServiceDate,
//	|	RoomServiceChargeType,
//	|	RoomService.*,
//	|	НомерРазмещения.*,
//	|	Количество,
//	|	Цена,
//	|	Валюта.*,
//	|	Сумма,
//	|	FixedServiceSum,
//	|	СчетПроживания.*,
//	|	УслугиНомера.Гостиница.*,
//	|	УслугиНомера.Фирма.*,
//	|	УслугиНомера.СтавкаНДС.*,
//	|	УслугиНомера.СуммаНДС,
//	|	УслугиНомера.Начисление.*,
//	|	УслугиНомера.FixedService.*,
//	|	УслугиНомера.FixedServiceVATRate.*,
//	|	УслугиНомера.FixedServiceVATSum,
//	|	УслугиНомера.FixedServiceCharge.*,
//	|	УслугиНомера.ExchangeRateDate,
//	|	УслугиНомера.CurrencyExchangeRate,
//	|	УслугиНомера.Автор.*,
//	|	УслугиНомера.PointInTime}
//	|TOTALS
//	|	SUM(Количество),
//	|	SUM(Сумма),
//	|	SUM(FixedServiceSum)
//	|BY
//	|	OVERALL
//	|{TOTALS BY
//	|	(HOUR(УслугиНомера.Period)) AS AccountingHour,
//	|	(BEGINOFPERIOD(УслугиНомера.Period, DAY)) AS УчетнаяДата,
//	|	(WEEK(УслугиНомера.Period)) AS AccountingWeek,
//	|	(MONTH(УслугиНомера.Period)) AS AccountingMonth,
//	|	(QUARTER(УслугиНомера.Period)) AS AccountingQuarter,
//	|	(YEAR(УслугиНомера.Period)) AS AccountingYear,
//	|	(HOUR(УслугиНомера.ServiceDate)) AS ServiceHour,
//	|	(BEGINOFPERIOD(УслугиНомера.ServiceDate, DAY)) AS ServiceDay,
//	|	(WEEK(УслугиНомера.ServiceDate)) AS ServiceWeek,
//	|	(MONTH(УслугиНомера.ServiceDate)) AS ServiceMonth,
//	|	(QUARTER(УслугиНомера.ServiceDate)) AS ServiceQuarter,
//	|	(YEAR(УслугиНомера.ServiceDate)) AS ServiceYear,
//	|	RoomServiceChargeType,
//	|	RoomService.*,
//	|	НомерРазмещения.*,
//	|	Валюта.*,
//	|	СчетПроживания.*,
//	|	УслугиНомера.Гостиница.*,
//	|	УслугиНомера.Фирма.*,
//	|	УслугиНомера.RoomServicePriceIsWithVAT,
//	|	УслугиНомера.ЕдИзмерения,
//	|	УслугиНомера.СтавкаНДС.*,
//	|	УслугиНомера.FixedService.*,
//	|	УслугиНомера.FixedServiceVATRate.*,
//	|	УслугиНомера.ExchangeRateDate,
//	|	УслугиНомера.Автор.*}";
//	ReportBuilder.Text = QueryText;
//	ReportBuilder.FillSettings();
//	
//	// Initialize report builder with default query
//	vRB = New ReportBuilder(QueryText);
//	vRBSettings = vRB.GetSettings(True, True, True, True, True);
//	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
//	
//	// Set default report builder header text
//	ReportBuilder.HeaderText = NStr("EN='ГруппаНомеров services';RU='Услуги на номера';de='Dienstleistungen pro Zimmer'");
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
