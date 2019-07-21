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
//	If НЕ ЗначениеЗаполнено(PeriodCheckType) Тогда
//		PeriodCheckType = Перечисления.PeriodCheckTypes.Intersection;
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
//	If ЗначениеЗаполнено(Operation) Тогда
//		If НЕ Operation.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("ru = 'Работа '; en = 'Operation '") + 
//			                     TrimAll(Operation.Description) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("ru = 'Группа работ '; en = 'Operations folder '") + 
//			                     TrimAll(Operation.Description) + 
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
//	If НЕ ЗначениеЗаполнено(PeriodCheckType) Тогда
//		vParamPresentation = vParamPresentation + NStr("en='Report period check type is by operation registration time';ru='Проверка периода по дате и времени регистрации работы';de='Kontrolle des Zeitraums nach Datum und Uhrzeit der Registrierung der Arbeit'") + 
//		                     ";" + Chars.LF;
//	ElsIf PeriodCheckType = Перечисления.PeriodCheckTypes.Intersection Тогда
//		vParamPresentation = vParamPresentation + NStr("en='Operations for the period selected';ru='Отбор работ в выбранном периоде';de='Auswahl von Arbeiten im gewählten Zeitraum'") + 
//		                     ";" + Chars.LF;
//	ElsIf PeriodCheckType = Перечисления.PeriodCheckTypes.StartsInPeriod Тогда
//		vParamPresentation = vParamPresentation + NStr("en='Operations with start time in the period selected';ru='Отбор работ с временем начала работы в выбранном периоде';de='Auswahl von Arbeiten mit dem Zeitpunkt des Arbeitsbeginns im ausgewählten Zeitraum'") + 
//		                     ";" + Chars.LF;
//	ElsIf PeriodCheckType = Перечисления.PeriodCheckTypes.EndsInPeriod Тогда
//		vParamPresentation = vParamPresentation + NStr("en='Operations with finish time in the period selected';ru='Отбор работ с временем завершения работы в выбранном периоде';de='Auswahl von Arbeiten mit dem Zeitpunkt der Beendigung der Arbeit im ausgewählten Zeitraum'") + 
//		                     ";" + Chars.LF;
//	ElsIf PeriodCheckType = Перечисления.PeriodCheckTypes.StartsOrEndsInPeriod Тогда
//		vParamPresentation = vParamPresentation + NStr("en='Operations with start or finish time in the period selected';ru='Отбор работ с временем начала или завершения в выбранном периоде';de='Auswahl von Arbeiten mit dem Zeitpunkt des Beginns oder der Beendigung im ausgewählten Zeitraum'") + 
//		                     ";" + Chars.LF;
//	ElsIf PeriodCheckType = Перечисления.PeriodCheckTypes.DocDateInPeriod Тогда
//		vParamPresentation = vParamPresentation + NStr("en='Operations with registration time in the period selected';ru='Отбор работ с временем регистрации в выбранном периоде';de='Auswahl von Arbeiten mit dem Zeitpunkt der Registrierung im ausgewählten Zeitraum'") + 
//		                     ";" + Chars.LF;
//	Endif;		
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
//	ReportBuilder.Parameters.Вставить("qPeriodCheckType", PeriodCheckType);
//	ReportBuilder.Parameters.Вставить("qIntersection", Перечисления.PeriodCheckTypes.Intersection);
//	ReportBuilder.Parameters.Вставить("qCheckIn", Перечисления.PeriodCheckTypes.StartsInPeriod);
//	ReportBuilder.Parameters.Вставить("qCheckOut", Перечисления.PeriodCheckTypes.EndsInPeriod);
//	ReportBuilder.Parameters.Вставить("qCheckInOrCheckOut", Перечисления.PeriodCheckTypes.StartsOrEndsInPeriod);
//	ReportBuilder.Parameters.Вставить("qDocDateInPeriod", Перечисления.PeriodCheckTypes.DocDateInPeriod);
//	ReportBuilder.Parameters.Вставить("qRoom", ГруппаНомеров);
//	ReportBuilder.Parameters.Вставить("qIsEmptyRoom", НЕ ЗначениеЗаполнено(ГруппаНомеров));
//	ReportBuilder.Parameters.Вставить("qRoomType", RoomType);
//	ReportBuilder.Parameters.Вставить("qIsEmptyRoomType", НЕ ЗначениеЗаполнено(RoomType));
//	ReportBuilder.Parameters.Вставить("qEmployee", Employee);
//	ReportBuilder.Parameters.Вставить("qIsEmptyEmployee", НЕ ЗначениеЗаполнено(Employee));
//	ReportBuilder.Parameters.Вставить("qOperation", Operation);
//	ReportBuilder.Parameters.Вставить("qIsEmptyOperation", НЕ ЗначениеЗаполнено(Operation));
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
//	|	EmployeeOperationsHistory.Period AS Period,
//	|	BEGINOFPERIOD(EmployeeOperationsHistory.Period, DAY) AS УчетнаяДата,
//	|	DAY(EmployeeOperationsHistory.Period) AS AccountingDay,
//	|	WEEK(EmployeeOperationsHistory.Period) AS AccountingWeek,
//	|	MONTH(EmployeeOperationsHistory.Period) AS AccountingMonth,
//	|	QUARTER(EmployeeOperationsHistory.Period) AS AccountingQuarter,
//	|	YEAR(EmployeeOperationsHistory.Period) AS AccountingYear,
//	|	EmployeeOperationsHistory.Recorder,
//	|	EmployeeOperationsHistory.Employee,
//	|	EmployeeOperationsHistory.Гостиница,
//	|	EmployeeOperationsHistory.НомерРазмещения,
//	|	EmployeeOperationsHistory.ТипНомера,
//	|	EmployeeOperationsHistory.Operation,
//	|	EmployeeOperationsHistory.OperationStartTime,
//	|	EmployeeOperationsHistory.Продолжительность AS Продолжительность,
//	|	EmployeeOperationsHistory.OperationEndTime,
//	|	EmployeeOperationsHistory.RoomSpace AS RoomSpace,
//	|	EmployeeOperationsHistory.КоличествоЧеловек AS КоличествоЧеловек,
//	|	EmployeeOperationsHistory.PBXStartCode,
//	|	EmployeeOperationsHistory.PBXEndCode,
//	|	EmployeeOperationsHistory.Примечания,
//	|	EmployeeOperationsHistory.Автор
//	|{SELECT
//	|	Period,
//	|	НомерРазмещения.*,
//	|	ТипНомера.*,
//	|	Employee.*,
//	|	Operation.*,
//	|	OperationStartTime,
//	|	Продолжительность,
//	|	OperationEndTime,
//	|	RoomSpace,
//	|	КоличествоЧеловек,
//	|	PBXStartCode,
//	|	PBXEndCode,
//	|	Примечания,
//	|	УчетнаяДата,
//	|	AccountingDay,
//	|	AccountingWeek,
//	|	AccountingMonth,
//	|	AccountingQuarter,
//	|	AccountingYear,
//	|	Гостиница.*,
//	|	Recorder.*,
//	|	Автор.*,
//	|	EmployeeOperationsHistory.PointInTime}
//	|FROM
//	|	InformationRegister.EmployeeOperationsHistory AS EmployeeOperationsHistory
//	|WHERE
//	|	(EmployeeOperationsHistory.Employee IN HIERARCHY (&qEmployee)
//	|			OR &qIsEmptyEmployee)
//	|	AND (EmployeeOperationsHistory.Гостиница IN HIERARCHY (&qHotel)
//	|			OR &qIsEmptyHotel)
//	|	AND (EmployeeOperationsHistory.НомерРазмещения IN HIERARCHY (&qRoom)
//	|			OR &qIsEmptyRoom)
//	|	AND (EmployeeOperationsHistory.ТипНомера IN HIERARCHY (&qRoomType)
//	|			OR &qIsEmptyRoomType)
//	|	AND (EmployeeOperationsHistory.Operation IN HIERARCHY (&qOperation)
//	|			OR &qIsEmptyOperation)
//	|	AND (EmployeeOperationsHistory.OperationStartTime < &qPeriodTo
//	|				AND EmployeeOperationsHistory.OperationEndTime > &qPeriodFrom
//	|				AND &qPeriodCheckType = &qIntersection
//	|			OR EmployeeOperationsHistory.OperationStartTime >= &qPeriodFrom
//	|				AND EmployeeOperationsHistory.OperationStartTime < &qPeriodTo
//	|				AND (&qPeriodCheckType = &qCheckIn
//	|					OR &qPeriodCheckType = &qCheckInOrCheckOut)
//	|			OR EmployeeOperationsHistory.OperationEndTime > &qPeriodFrom
//	|				AND EmployeeOperationsHistory.OperationEndTime <= &qPeriodTo
//	|				AND (&qPeriodCheckType = &qCheckOut
//	|					OR &qPeriodCheckType = &qCheckInOrCheckOut)
//	|			OR EmployeeOperationsHistory.Recorder.ДатаДок >= &qPeriodFrom
//	|				AND EmployeeOperationsHistory.Recorder.ДатаДок < &qPeriodTo
//	|				AND &qPeriodCheckType = &qDocDateInPeriod)
//	|{WHERE
//	|	EmployeeOperationsHistory.Period,
//	|	EmployeeOperationsHistory.Recorder.*,
//	|	EmployeeOperationsHistory.Employee.*,
//	|	EmployeeOperationsHistory.Гостиница.*,
//	|	EmployeeOperationsHistory.НомерРазмещения.*,
//	|	EmployeeOperationsHistory.ТипНомера.*,
//	|	EmployeeOperationsHistory.Operation.*,
//	|	EmployeeOperationsHistory.OperationStartTime,
//	|	EmployeeOperationsHistory.Продолжительность,
//	|	EmployeeOperationsHistory.OperationEndTime,
//	|	EmployeeOperationsHistory.RoomSpace,
//	|	EmployeeOperationsHistory.КоличествоЧеловек,
//	|	EmployeeOperationsHistory.PBXStartCode,
//	|	EmployeeOperationsHistory.PBXEndCode,
//	|	EmployeeOperationsHistory.Примечания,
//	|	EmployeeOperationsHistory.Автор.*,
//	|	EmployeeOperationsHistory.PointInTime}
//	|
//	|ORDER BY
//	|	Period
//	|{ORDER BY
//	|	Period,
//	|	Recorder.*,
//	|	Employee.*,
//	|	Гостиница.*,
//	|	НомерРазмещения.*,
//	|	ТипНомера.*,
//	|	Operation.*,
//	|	OperationStartTime,
//	|	Продолжительность,
//	|	OperationEndTime,
//	|	RoomSpace,
//	|	КоличествоЧеловек,
//	|	PBXStartCode,
//	|	PBXEndCode,
//	|	Примечания,
//	|	Автор.*,
//	|	EmployeeOperationsHistory.PointInTime}
//	|TOTALS
//	|	SUM(Продолжительность),
//	|	SUM(RoomSpace),
//	|	SUM(КоличествоЧеловек)
//	|BY
//	|	OVERALL
//	|{TOTALS BY
//	|	УчетнаяДата,
//	|	AccountingDay,
//	|	AccountingWeek,
//	|	AccountingMonth,
//	|	AccountingQuarter,
//	|	AccountingYear,
//	|	Recorder.*,
//	|	Employee.*,
//	|	Гостиница.*,
//	|	НомерРазмещения.*,
//	|	ТипНомера.*,
//	|	Operation.*,
//	|	PBXStartCode,
//	|	PBXEndCode,
//	|	Автор.*}";
//	ReportBuilder.Text = QueryText;
//	ReportBuilder.FillSettings();
//	
//	// Initialize report builder with default query
//	vRB = New ReportBuilder(QueryText);
//	vRBSettings = vRB.GetSettings(True, True, True, True, True);
//	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
//	
//	// Set default report builder header text
//	ReportBuilder.HeaderText = NStr("EN='Employee operations history';RU='Протокол выполнения работ персоналом';de='Protokoll der Arbeitsausführung des Personals'");
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
