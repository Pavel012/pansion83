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
//		PeriodFrom = BegOfMonth(CurrentDate()); // Current month
//		PeriodTo = EndOfMonth(PeriodFrom);
//	EndIf;
//КонецПроцедуры //pmFillAttributesWithDefaultValues
//
////-----------------------------------------------------------------------------
//Function pmGetReportParametersPresentation() Экспорт
//	vParamPresentation = "";
//	If НЕ ЗначениеЗаполнено(PeriodFrom) And НЕ ЗначениеЗаполнено(PeriodTo) Тогда
//		vParamPresentation = vParamPresentation + NStr("en='Report period is not set';ru='Период отчета не установлен';de='Berichtszeitraum nicht festgelegt'") + 
//		                     ";" + Chars.LF;
//	ElsIf НЕ ЗначениеЗаполнено(PeriodFrom) And ЗначениеЗаполнено(PeriodTo) Тогда
//		vParamPresentation = vParamPresentation + NStr("ru = 'Период c '; en = 'Period from '") + 
//		                     Format(PeriodFrom, "DF='dd.MM.yyyy'") + 
//		                     ";" + Chars.LF;
//	ElsIf ЗначениеЗаполнено(PeriodFrom) And НЕ ЗначениеЗаполнено(PeriodTo) Тогда
//		vParamPresentation = vParamPresentation + NStr("ru = 'Период по '; en = 'Period to '") + 
//		                     Format(PeriodTo, "DF='dd.MM.yyyy'") + 
//		                     ";" + Chars.LF;
//	ElsIf PeriodFrom = PeriodTo Тогда
//		vParamPresentation = vParamPresentation + NStr("ru = 'Период на '; en = 'Period on '") + 
//		                     Format(PeriodFrom, "DF='dd.MM.yyyy'") + 
//		                     ";" + Chars.LF;
//	ElsIf PeriodFrom < PeriodTo Тогда
//		vParamPresentation = vParamPresentation + NStr("ru = 'Период '; en = 'Period '") + PeriodPresentation(BegOfDay(PeriodFrom), EndOfDay(PeriodTo), cmLocalizationCode()) + 
//		                     ";" + Chars.LF;
//	Else
//		vParamPresentation = vParamPresentation + NStr("en='Period is wrong!';ru='Неправильно задан период!';de='Der Zeitraum wurde falsch eingetragen!'") + 
//		                     ";" + Chars.LF;
//	EndIf;
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
//	If ЗначениеЗаполнено(Отдел) Тогда
//		If НЕ Отдел.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("ru = 'Отдел '; en = 'Отдел '") + 
//			                     TrimAll(Отдел.Description) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("ru = 'Группа отделов '; en = 'Departments folder '") + 
//			                     TrimAll(Отдел.Description) + 
//			                     ";" + Chars.LF;
//		EndIf;
//	EndIf;							 
//	If ЗначениеЗаполнено(СекцияНомеров) Тогда
//		If НЕ СекцияНомеров.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("en='ГруппаНомеров section ';ru='Секция номеров ';de='Sektion der Zimmer'") + 
//			                     TrimAll(СекцияНомеров.Description) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("ru = 'Группа секций номеров '; en = 'ГруппаНомеров sections folder '") + 
//			                     TrimAll(СекцияНомеров.Description) + 
//			                     ";" + Chars.LF;
//		EndIf;
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
//	ReportBuilder.Parameters.Вставить("qPeriodFrom", BegOfDay(PeriodFrom));
//	ReportBuilder.Parameters.Вставить("qPeriodTo", EndOfDay(PeriodTo));
//	ReportBuilder.Parameters.Вставить("qHotel", Гостиница);
//	ReportBuilder.Parameters.Вставить("qIsEmptyHotel", НЕ ЗначениеЗаполнено(Гостиница));
//	ReportBuilder.Parameters.Вставить("qRoom", ГруппаНомеров);
//	ReportBuilder.Parameters.Вставить("qIsEmptyRoom", НЕ ЗначениеЗаполнено(ГруппаНомеров));
//	ReportBuilder.Parameters.Вставить("qRoomSection", СекцияНомеров);
//	ReportBuilder.Parameters.Вставить("qIsEmptyRoomSection", НЕ ЗначениеЗаполнено(СекцияНомеров));
//	ReportBuilder.Parameters.Вставить("qEmployee", Employee);
//	ReportBuilder.Parameters.Вставить("qIsEmptyEmployee", НЕ ЗначениеЗаполнено(Employee));
//	ReportBuilder.Parameters.Вставить("qDepartment", Отдел);
//	ReportBuilder.Parameters.Вставить("qIsEmptyDepartment", НЕ ЗначениеЗаполнено(Отдел));
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
////	cmApplyReportAppearance(ThisObject, pSpreadsheet, vTemplateAttributes);
//КонецПроцедуры //pmGenerate
//
////-----------------------------------------------------------------------------
//Процедура pmInitializeReportBuilder() Экспорт
//	ReportBuilder = New ReportBuilder();
//	
//	// Initialize default query text
//	QueryText = 
//	"SELECT
//	|	EmployeeWorkingTimeSchedule.Employee AS Employee,
//	|	EmployeeWorkingTimeSchedule.НомерРазмещения,
//	|	EmployeeWorkingTimeSchedule.Секция,
//	|	EmployeeWorkingTimeSchedule.Period AS Period,
//	|	WEEK(EmployeeWorkingTimeSchedule.Period) AS AccountingWeek,
//	|	MONTH(EmployeeWorkingTimeSchedule.Period) AS AccountingMonth,
//	|	QUARTER(EmployeeWorkingTimeSchedule.Period) AS AccountingQuarter,
//	|	YEAR(EmployeeWorkingTimeSchedule.Period) AS AccountingYear,
//	|	EmployeeWorkingTimeSchedule.Hours AS Hours,
//	|	EmployeeWorkingTimeSchedule.ScheduleDayType
//	|{SELECT
//	|	Employee.*,
//	|	EmployeeWorkingTimeSchedule.Отдел.*,
//	|	Секция.*,
//	|	НомерРазмещения.*,
//	|	Period,
//	|	AccountingWeek,
//	|	AccountingMonth,
//	|	AccountingQuarter,
//	|	AccountingYear,
//	|	Hours,
//	|	ScheduleDayType.*,
//	|	EmployeeWorkingTimeSchedule.Timetable.*,
//	|	EmployeeWorkingTimeSchedule.Гостиница.*,
//	|	EmployeeWorkingTimeSchedule.Remarks}
//	|FROM
//	|	InformationRegister.EmployeeWorkingTimeSchedule AS EmployeeWorkingTimeSchedule
//	|WHERE
//	|	(EmployeeWorkingTimeSchedule.Employee IN HIERARCHY (&qEmployee)
//	|			OR &qIsEmptyEmployee)
//	|	AND (EmployeeWorkingTimeSchedule.Гостиница IN HIERARCHY (&qHotel)
//	|			OR &qIsEmptyHotel)
//	|	AND (EmployeeWorkingTimeSchedule.НомерРазмещения IN HIERARCHY (&qRoom)
//	|			OR &qIsEmptyRoom)
//	|	AND (EmployeeWorkingTimeSchedule.Секция IN HIERARCHY (&qRoomSection)
//	|			OR &qIsEmptyRoomSection)
//	|	AND (EmployeeWorkingTimeSchedule.Отдел IN HIERARCHY (&qDepartment)
//	|			OR &qIsEmptyDepartment)
//	|	AND EmployeeWorkingTimeSchedule.Period >= &qPeriodFrom
//	|	AND EmployeeWorkingTimeSchedule.Period <= &qPeriodTo
//	|{WHERE
//	|	EmployeeWorkingTimeSchedule.Employee.*,
//	|	EmployeeWorkingTimeSchedule.Отдел.*,
//	|	EmployeeWorkingTimeSchedule.Секция.*,
//	|	EmployeeWorkingTimeSchedule.НомерРазмещения.*,
//	|	EmployeeWorkingTimeSchedule.Period,
//	|	EmployeeWorkingTimeSchedule.Hours,
//	|	EmployeeWorkingTimeSchedule.ScheduleDayType.*,
//	|	EmployeeWorkingTimeSchedule.Timetable.*,
//	|	EmployeeWorkingTimeSchedule.Гостиница.*,
//	|	EmployeeWorkingTimeSchedule.Remarks}
//	|
//	|ORDER BY
//	|	EmployeeWorkingTimeSchedule.Employee.ПорядокСортировки,
//	|	Employee,
//	|	Period
//	|{ORDER BY
//	|	Employee.*,
//	|	EmployeeWorkingTimeSchedule.Отдел.*,
//	|	Секция.*,
//	|	НомерРазмещения.*,
//	|	Period,
//	|	Hours,
//	|	ScheduleDayType.*,
//	|	EmployeeWorkingTimeSchedule.Timetable.*,
//	|	EmployeeWorkingTimeSchedule.Гостиница.*,
//	|	EmployeeWorkingTimeSchedule.Remarks}
//	|TOTALS
//	|	SUM(Hours)
//	|BY
//	|	OVERALL,
//	|	Employee,
//	|	Period
//	|{TOTALS BY
//	|	Period,
//	|	AccountingWeek,
//	|	AccountingMonth,
//	|	AccountingQuarter,
//	|	AccountingYear,
//	|	Employee.*,
//	|	EmployeeWorkingTimeSchedule.Отдел.*,
//	|	Секция.*,
//	|	НомерРазмещения.*,
//	|	Hours,
//	|	ScheduleDayType.*,
//	|	EmployeeWorkingTimeSchedule.Timetable.*,
//	|	EmployeeWorkingTimeSchedule.Гостиница.*}";
//	ReportBuilder.Text = QueryText;
//	ReportBuilder.FillSettings();
//	
//	// Initialize report builder with default query
//	vRB = New ReportBuilder(QueryText);
//	vRBSettings = vRB.GetSettings(True, True, True, True, True);
//	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
//	
//	// Set default report builder header text
//	ReportBuilder.HeaderText = NStr("EN='Employee working time schedule';RU='График рабочего времени сотрудников';de='Arbeitszeitplan der Mitarbeiter'");
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
