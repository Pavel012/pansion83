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
//	If ЗначениеЗаполнено(Employee) Тогда
//		If НЕ Employee.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("en='Employee ';ru='Сотрудник ';de='Mitarbeiter'") + 
//			                     TrimAll(Employee.Description) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("ru = 'Группа сотрудников '; en = 'Employees folder '") + 
//			                     TrimAll(Employee.Description) + 
//			                     ";" + Chars.LF;
//		EndIf;
//	EndIf;
//	If ЗначениеЗаполнено(RoomStatus) Тогда
//		If НЕ RoomStatus.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("ru = 'Статус номеров '; en = 'ГруппаНомеров status '") + 
//			                     TrimAll(RoomStatus.Description) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("ru = 'Группа статусов номеров '; en = 'ГруппаНомеров statuses folder '") + 
//			                     TrimAll(RoomStatus.Description) + 
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
//	ReportBuilder.Parameters.Вставить("qIsEmptyHotel", НЕ ЗначениеЗаполнено(Гостиница));
//	ReportBuilder.Parameters.Вставить("qPeriodFrom", PeriodFrom);
//	ReportBuilder.Parameters.Вставить("qPeriodTo", PeriodTo);
//	ReportBuilder.Parameters.Вставить("qRoom", ГруппаНомеров);
//	ReportBuilder.Parameters.Вставить("qIsEmptyRoom", НЕ ЗначениеЗаполнено(ГруппаНомеров));
//	ReportBuilder.Parameters.Вставить("qRoomType", RoomType);
//	ReportBuilder.Parameters.Вставить("qIsEmptyRoomType", НЕ ЗначениеЗаполнено(RoomType));
//	ReportBuilder.Parameters.Вставить("qEmployee", Employee);
//	ReportBuilder.Parameters.Вставить("qIsEmptyEmployee", НЕ ЗначениеЗаполнено(Employee));
//	ReportBuilder.Parameters.Вставить("qRoomStatus", RoomStatus);
//	ReportBuilder.Parameters.Вставить("qIsEmptyRoomStatus", НЕ ЗначениеЗаполнено(RoomStatus));
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
//	|	ИсторияИзмСтатусаНомеров.Period AS Period,
//	|	BEGINOFPERIOD(ИсторияИзмСтатусаНомеров.Period, DAY) AS УчетнаяДата,
//	|	DAY(ИсторияИзмСтатусаНомеров.Period) AS AccountingDay,
//	|	WEEK(ИсторияИзмСтатусаНомеров.Period) AS AccountingWeek,
//	|	MONTH(ИсторияИзмСтатусаНомеров.Period) AS AccountingMonth,
//	|	QUARTER(ИсторияИзмСтатусаНомеров.Period) AS AccountingQuarter,
//	|	YEAR(ИсторияИзмСтатусаНомеров.Period) AS AccountingYear,
//	|	ИсторияИзмСтатусаНомеров.User AS Employee,
//	|	ИсторияИзмСтатусаНомеров.НомерРазмещения.Owner AS Гостиница,
//	|	ИсторияИзмСтатусаНомеров.НомерРазмещения,
//	|	ИсторияИзмСтатусаНомеров.НомерРазмещения.ТипНомера AS ТипНомера,
//	|	ИсторияИзмСтатусаНомеров.СтатусНомера,
//	|	ИсторияИзмСтатусаНомеров.Примечания
//	|{SELECT
//	|	Period,
//	|	НомерРазмещения.*,
//	|	ТипНомера.*,
//	|	Employee.*,
//	|	СтатусНомера.*,
//	|	Примечания,
//	|	(BEGINOFPERIOD(ИсторияИзмСтатусаНомеров.Period, DAY)) AS УчетнаяДата,
//	|	(DAY(ИсторияИзмСтатусаНомеров.Period)) AS AccountingDay,
//	|	(WEEK(ИсторияИзмСтатусаНомеров.Period)) AS AccountingWeek,
//	|	(MONTH(ИсторияИзмСтатусаНомеров.Period)) AS AccountingMonth,
//	|	(QUARTER(ИсторияИзмСтатусаНомеров.Period)) AS AccountingQuarter,
//	|	(YEAR(ИсторияИзмСтатусаНомеров.Period)) AS AccountingYear,
//	|	Гостиница.*}
//	|FROM
//	|	InformationRegister.ИсторияИзмСтатусаНомеров AS ИсторияИзмСтатусаНомеров
//	|WHERE
//	|	(ИсторияИзмСтатусаНомеров.User IN HIERARCHY (&qEmployee)
//	|			OR &qIsEmptyEmployee)
//	|	AND (ИсторияИзмСтатусаНомеров.НомерРазмещения.Owner IN HIERARCHY (&qHotel)
//	|			OR &qIsEmptyHotel)
//	|	AND (ИсторияИзмСтатусаНомеров.НомерРазмещения IN HIERARCHY (&qRoom)
//	|			OR &qIsEmptyRoom)
//	|	AND (ИсторияИзмСтатусаНомеров.НомерРазмещения.ТипНомера IN HIERARCHY (&qRoomType)
//	|			OR &qIsEmptyRoomType)
//	|	AND (ИсторияИзмСтатусаНомеров.СтатусНомера IN HIERARCHY (&qRoomStatus)
//	|			OR &qIsEmptyRoomStatus)
//	|	AND ИсторияИзмСтатусаНомеров.Period >= &qPeriodFrom
//	|	AND ИсторияИзмСтатусаНомеров.Period <= &qPeriodTo
//	|{WHERE
//	|	ИсторияИзмСтатусаНомеров.Period,
//	|	ИсторияИзмСтатусаНомеров.User.* AS Employee,
//	|	ИсторияИзмСтатусаНомеров.НомерРазмещения.Owner.* AS Гостиница,
//	|	ИсторияИзмСтатусаНомеров.НомерРазмещения.*,
//	|	ИсторияИзмСтатусаНомеров.НомерРазмещения.ТипНомера.* AS ТипНомера,
//	|	ИсторияИзмСтатусаНомеров.СтатусНомера.*,
//	|	ИсторияИзмСтатусаНомеров.Remarks}
//	|
//	|ORDER BY
//	|	Period
//	|{ORDER BY
//	|	Period,
//	|	Employee.*,
//	|	Гостиница.*,
//	|	НомерРазмещения.*,
//	|	ТипНомера.*,
//	|	СтатусНомера.*,
//	|	Remarks}
//	|TOTALS BY
//	|	OVERALL
//	|{TOTALS BY
//	|	УчетнаяДата,
//	|	AccountingDay,
//	|	AccountingWeek,
//	|	AccountingMonth,
//	|	AccountingQuarter,
//	|	AccountingYear,
//	|	Employee.*,
//	|	Гостиница.*,
//	|	НомерРазмещения.*,
//	|	ТипНомера.*,
//	|	СтатусНомера.*}";
//	ReportBuilder.Text = QueryText;
//	ReportBuilder.FillSettings();
//	
//	// Initialize report builder with default query
//	vRB = New ReportBuilder(QueryText);
//	vRBSettings = vRB.GetSettings(True, True, True, True, True);
//	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
//	
//	// Set default report builder header text
//	ReportBuilder.HeaderText = NStr("EN='ГруппаНомеров status change history';RU='История изменения статусов номеров';de=' Änderungsverlauf der Zimmerstatus'");
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
