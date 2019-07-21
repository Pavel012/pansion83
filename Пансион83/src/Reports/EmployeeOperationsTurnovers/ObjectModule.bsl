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
//		If НЕ ЗначениеЗаполнено(PeriodFrom) Тогда
//			PeriodFrom = BegOfMonth(CurrentDate()); // For beg. of month
//			PeriodTo = EndOfDay(CurrentDate());
//		EndIf;
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
//	If ЗначениеЗаполнено(Article) Тогда
//		If НЕ Article.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("ru = 'Номенклатура '; en = 'Article '") + 
//			                     TrimAll(Article.Description) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("ru = 'Группа номенклатуры '; en = 'Articles folder '") + 
//			                     TrimAll(Article.Description) + 
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
//Процедура pmGenerate(pSpreadsheet, pAddChart = False) Экспорт
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
//	ReportBuilder.Parameters.Вставить("qEmployee", Employee);
//	ReportBuilder.Parameters.Вставить("qIsEmptyEmployee", НЕ ЗначениеЗаполнено(Employee));
//	ReportBuilder.Parameters.Вставить("qOperation", Operation);
//	ReportBuilder.Parameters.Вставить("qIsEmptyOperation", НЕ ЗначениеЗаполнено(Operation));
//	ReportBuilder.Parameters.Вставить("qArticle", Article);
//	ReportBuilder.Parameters.Вставить("qIsEmptyArticle", НЕ ЗначениеЗаполнено(Article));
//	ReportBuilder.Parameters.Вставить("qRoom", ГруппаНомеров);
//	ReportBuilder.Parameters.Вставить("qIsEmptyRoom", НЕ ЗначениеЗаполнено(ГруппаНомеров));
//	ReportBuilder.Parameters.Вставить("qRoomType", RoomType);
//	ReportBuilder.Parameters.Вставить("qIsEmptyRoomType", НЕ ЗначениеЗаполнено(RoomType));
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
//	
//	// Add chart 
//	If pAddChart Тогда
//		cmAddReportChart(pSpreadsheet, ThisObject);
//	EndIf;
//КонецПроцедуры //pmGenerate
//	
////-----------------------------------------------------------------------------
//Процедура pmInitializeReportBuilder() Экспорт
//	ReportBuilder = New ReportBuilder();
//	
//	// Initialize default query text
//	QueryText = 
//	"SELECT
//	|	EmployeeOperationsTurnoverTurnovers.Period AS УчетнаяДата,
//	|	EmployeeOperationsTurnoverTurnovers.Employee,
//	|	EmployeeOperationsTurnoverTurnovers.Гостиница,
//	|	EmployeeOperationsTurnoverTurnovers.ТипНомера,
//	|	EmployeeOperationsTurnoverTurnovers.НомерРазмещения,
//	|	EmployeeOperationsTurnoverTurnovers.Operation AS Operation,
//	|	EmployeeOperationsTurnoverTurnovers.Article AS Article,
//	|	EmployeeOperationsTurnoverTurnovers.ЕдИзмерения AS ЕдИзмерения,
//	|	EmployeeOperationsTurnoverTurnovers.CountTurnover AS CountTurnover,
//	|	EmployeeOperationsTurnoverTurnovers.DurationTurnover AS DurationTurnover,
//	|	EmployeeOperationsTurnoverTurnovers.DurationTurnover / 60 AS DurationInHoursTurnover,
//	|	EmployeeOperationsTurnoverTurnovers.RoomSpaceTurnover AS RoomSpaceTurnover,
//	|	EmployeeOperationsTurnoverTurnovers.NumberOfPersonsTurnover AS NumberOfPersonsTurnover,
//	|	EmployeeOperationsTurnoverTurnovers.QuantityTurnover AS QuantityTurnover
//	|{SELECT
//	|	УчетнаяДата,
//	|	(WEEK(EmployeeOperationsTurnoverTurnovers.Period)) AS AccountingWeek,
//	|	(MONTH(EmployeeOperationsTurnoverTurnovers.Period)) AS AccountingMonth,
//	|	(QUARTER(EmployeeOperationsTurnoverTurnovers.Period)) AS AccountingQuarter,
//	|	(YEAR(EmployeeOperationsTurnoverTurnovers.Period)) AS AccountingYear,
//	|	Employee.*,
//	|	Гостиница.*,
//	|	ТипНомера.*,
//	|	Operation.*,
//	|	Article.*,
//	|	ЕдИзмерения,
//	|	CountTurnover,
//	|	DurationTurnover,
//	|	DurationInHoursTurnover,
//	|	RoomSpaceTurnover,
//	|	NumberOfPersonsTurnover,
//	|	QuantityTurnover}
//	|FROM
//	|	AccumulationRegister.ОборотыРаботыПерсонал.Turnovers(
//	|			&qPeriodFrom,
//	|			&qPeriodTo,
//	|			Day,
//	|			(Employee IN HIERARCHY (&qEmployee)
//	|				OR &qIsEmptyEmployee)
//	|				AND (Operation IN HIERARCHY (&qOperation)
//	|					OR &qIsEmptyOperation)
//	|				AND (Article IN HIERARCHY (&qArticle)
//	|					OR &qIsEmptyArticle)
//	|				AND (ТипНомера IN HIERARCHY (&qRoomType)
//	|					OR &qIsEmptyRoomType)
//	|				AND (НомерРазмещения IN HIERARCHY (&qRoom)
//	|					OR &qIsEmptyRoom)
//	|				AND (Гостиница IN HIERARCHY (&qHotel)
//	|					OR &qIsEmptyHotel)) AS EmployeeOperationsTurnoverTurnovers
//	|{WHERE
//	|	EmployeeOperationsTurnoverTurnovers.Period AS УчетнаяДата,
//	|	EmployeeOperationsTurnoverTurnovers.Employee.*,
//	|	EmployeeOperationsTurnoverTurnovers.Гостиница.*,
//	|	EmployeeOperationsTurnoverTurnovers.ТипНомера.*,
//	|	EmployeeOperationsTurnoverTurnovers.НомерРазмещения.*,
//	|	EmployeeOperationsTurnoverTurnovers.Operation.*,
//	|	EmployeeOperationsTurnoverTurnovers.Article.*,
//	|	EmployeeOperationsTurnoverTurnovers.ЕдИзмерения,
//	|	EmployeeOperationsTurnoverTurnovers.CountTurnover,
//	|	EmployeeOperationsTurnoverTurnovers.DurationTurnover,
//	|	EmployeeOperationsTurnoverTurnovers.RoomSpaceTurnover,
//	|	EmployeeOperationsTurnoverTurnovers.NumberOfPersonsTurnover,
//	|	EmployeeOperationsTurnoverTurnovers.QuantityTurnover}
//	|{ORDER BY
//	|	УчетнаяДата,
//	|	Employee.*,
//	|	Гостиница.*,
//	|	ТипНомера.*,
//	|	НомерРазмещения.*,
//	|	Operation.*,
//	|	Article.*,
//	|	ЕдИзмерения,
//	|	CountTurnover,
//	|	DurationTurnover,
//	|	RoomSpaceTurnover,
//	|	NumberOfPersonsTurnover,
//	|	QuantityTurnover}
//	|TOTALS
//	|	SUM(CountTurnover),
//	|	SUM(DurationTurnover),
//	|	SUM(DurationInHoursTurnover),
//	|	SUM(RoomSpaceTurnover),
//	|	SUM(NumberOfPersonsTurnover),
//	|	SUM(QuantityTurnover)
//	|BY
//	|	OVERALL,
//	|	УчетнаяДата,
//	|	Operation,
//	|	Article
//	|{TOTALS BY
//	|	УчетнаяДата,
//	|	(WEEK(EmployeeOperationsTurnoverTurnovers.Period)) AS AccountingWeek,
//	|	(MONTH(EmployeeOperationsTurnoverTurnovers.Period)) AS AccountingMonth,
//	|	(QUARTER(EmployeeOperationsTurnoverTurnovers.Period)) AS AccountingQuarter,
//	|	(YEAR(EmployeeOperationsTurnoverTurnovers.Period)) AS AccountingYear,
//	|	Employee.*,
//	|	Гостиница.*,
//	|	ТипНомера.*,
//	|	НомерРазмещения.*,
//	|	Operation.*,
//	|	Article.*,
//	|	Unit}";
//	ReportBuilder.Text = QueryText;
//	ReportBuilder.FillSettings();
//	
//	// Initialize report builder with default query
//	vRB = New ReportBuilder(QueryText);
//	vRBSettings = vRB.GetSettings(True, True, True, True, True);
//	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
//	
//	// Set default report builder header text
//	ReportBuilder.HeaderText = NStr("EN='Employee operations turnovers';RU='Обороты по работам персонала';de='Umsätze nach Arbeit des Personals'");
//	
//	// Fill report builder fields presentations from the report template
//	cmFillReportAttributesPresentations(ThisObject);
//	
//	// Reset report builder template
//	ReportBuilder.Template = Неопределено;
//КонецПроцедуры //pmInitializeReportBuilder
//
////-----------------------------------------------------------------------------
//Function pmIsResource(pName) Экспорт
//	If pName = "CountTurnover" Or
//	   pName = "DurationTurnover" Or 
//	   pName = "DurationInHoursTurnover" Or 
//	   pName = "RoomSpaceTurnover" Or 
//	   pName = "NumberOfPersonsTurnover" Or 
//	   pName = "QuantityTurnover" Тогда
//		Return True;
//	Else
//		Return False;
//	EndIf;
//EndFunction //pmIsResource
//
////-----------------------------------------------------------------------------
//// Reports framework end
////-----------------------------------------------------------------------------
