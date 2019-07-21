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
//		PeriodFrom = '20000101';
//		PeriodTo = EndOfDay(CurrentDate());
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
//	If ЗначениеЗаполнено(DiscountType) Тогда
//		If НЕ DiscountType.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("ru = 'Тип скидки '; en = 'Discount type '") + 
//			                     TrimAll(DiscountType.Description) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("ru = 'Группа типов скидок '; en = 'Discount types folder '") + 
//			                     TrimAll(DiscountType.Description) + 
//			                     ";" + Chars.LF;
//		EndIf;
//	EndIf;
//	If ЗначениеЗаполнено(ClientType) Тогда
//		If НЕ ClientType.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("en='Client type ';ru='Тип клиента ';de='Kundentyp'") + 
//			                     TrimAll(ClientType.Description) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("ru = 'Группа типов клиентов '; en = 'Client types folder '") + 
//			                     TrimAll(ClientType.Description) + 
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
//	ReportBuilder.Parameters.Вставить("qEmptyHotel", Справочники.Гостиницы.EmptyRef());
//	ReportBuilder.Parameters.Вставить("qPeriodFrom", PeriodFrom);
//	ReportBuilder.Parameters.Вставить("qPeriodTo", PeriodTo);
//	ReportBuilder.Parameters.Вставить("qDiscountType", DiscountType);
//	ReportBuilder.Parameters.Вставить("qIsEmptyDiscountType", НЕ ЗначениеЗаполнено(DiscountType));
//	ReportBuilder.Parameters.Вставить("qClientType", ClientType);
//	ReportBuilder.Parameters.Вставить("qIsEmptyClientType", НЕ ЗначениеЗаполнено(ClientType));
//	ReportBuilder.Parameters.Вставить("qEmptyDate", '00010101');
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
//	|	ДисконтныеКарты.Ref AS ДисконтКарт,
//	|	ДисконтныеКарты.Identifier AS Identifier,
//	|	ДисконтныеКарты.Клиент AS Клиент,
//	|	ДисконтныеКарты.ТипСкидки AS ТипСкидки,
//	|	ДисконтныеКарты.ТипКлиента AS ТипКлиента,
//	|	ДисконтныеКарты.ValidFrom AS ValidFrom,
//	|	ДисконтныеКарты.ValidTo AS ValidTo,
//	|	ДисконтныеКарты.TurnOffAutomaticDiscounts AS TurnOffAutomaticDiscounts,
//	|	ДисконтныеКарты.IsBlocked AS IsBlocked,
//	|	ДисконтныеКарты.Примечания AS Примечания,
//	|	1 AS CardsCount
//	|{SELECT
//	|	ДисконтКарт.* AS ДисконтКарт,
//	|	Identifier AS Identifier,
//	|	Клиент.* AS Клиент,
//	|	ДисконтныеКарты.Клиент.FullName AS ClientFullName,
//	|	ДисконтныеКарты.Клиент.ДатаРождения AS ClientDateOfBirth,
//	|	ДисконтныеКарты.Клиент.Телефон AS ClientPhone,
//	|	ДисконтныеКарты.Клиент.Fax AS ClientFax,
//	|	ДисконтныеКарты.Клиент.EMail AS ClientEMail,
//	|	ТипСкидки.* AS ТипСкидки,
//	|	ТипКлиента.* AS ТипКлиента,
//	|	ValidFrom AS ValidFrom,
//	|	ValidTo AS ValidTo,
//	|	TurnOffAutomaticDiscounts AS TurnOffAutomaticDiscounts,
//	|	IsBlocked AS IsBlocked,
//	|	Примечания AS Примечания,
//	|	CardsCount}
//	|FROM
//	|	Catalog.ДисконтныеКарты AS DiscountCards
//	|WHERE
//	|	(NOT ДисконтныеКарты.DeletionMark
//	|				AND (NOT &qIsEmptyDiscountType
//	|						AND ДисконтныеКарты.ТипСкидки IN HIERARCHY (&qDiscountType)
//	|					OR &qIsEmptyDiscountType)
//	|				AND (NOT &qIsEmptyClientType
//	|						AND ДисконтныеКарты.ТипКлиента IN HIERARCHY (&qClientType)
//	|					OR &qIsEmptyClientType)
//	|				AND ДисконтныеКарты.ValidFrom <> &qEmptyDate
//	|				AND ДисконтныеКарты.ValidFrom < &qPeriodTo
//	|			OR ДисконтныеКарты.ValidFrom = &qEmptyDate
//	|				AND ДисконтныеКарты.ValidTo <> &qEmptyDate
//	|				AND ДисконтныеКарты.ValidTo > &qPeriodFrom
//	|			OR ДисконтныеКарты.ValidTo = &qEmptyDate)
//	|{WHERE
//	|	ДисконтныеКарты.Ref.* AS ДисконтКарт,
//	|	ДисконтныеКарты.Identifier AS Identifier,
//	|	ДисконтныеКарты.Клиент.* AS Клиент,
//	|	ДисконтныеКарты.Клиент.FullName AS ClientFullName,
//	|	ДисконтныеКарты.Клиент.ДатаРождения AS ClientDateOfBirth,
//	|	ДисконтныеКарты.Клиент.Телефон AS ClientPhone,
//	|	ДисконтныеКарты.Клиент.Fax AS ClientFax,
//	|	ДисконтныеКарты.Клиент.EMail AS ClientEMail,
//	|	ДисконтныеКарты.ТипСкидки.* AS ТипСкидки,
//	|	ДисконтныеКарты.ТипКлиента.* AS ТипКлиента,
//	|	ДисконтныеКарты.ValidFrom AS ValidFrom,
//	|	ДисконтныеКарты.ValidTo AS ValidTo,
//	|	ДисконтныеКарты.TurnOffAutomaticDiscounts AS TurnOffAutomaticDiscounts,
//	|	ДисконтныеКарты.IsBlocked AS IsBlocked,
//	|	ДисконтныеКарты.Примечания AS Remarks}
//	|
//	|ORDER BY
//	|	ТипСкидки,
//	|	Клиент
//	|{ORDER BY
//	|	ДисконтКарт.* AS ДисконтКарт,
//	|	Identifier AS Identifier,
//	|	Клиент.* AS Клиент,
//	|	ДисконтныеКарты.Клиент.FullName AS ClientFullName,
//	|	ДисконтныеКарты.Клиент.ДатаРождения AS ClientDateOfBirth,
//	|	ДисконтныеКарты.Клиент.Телефон AS ClientPhone,
//	|	ДисконтныеКарты.Клиент.Fax AS ClientFax,
//	|	ДисконтныеКарты.Клиент.EMail AS ClientEMail,
//	|	ТипСкидки.* AS ТипСкидки,
//	|	ТипКлиента.* AS ТипКлиента,
//	|	ValidFrom AS ValidFrom,
//	|	ValidTo AS ValidTo,
//	|	TurnOffAutomaticDiscounts AS TurnOffAutomaticDiscounts,
//	|	IsBlocked AS IsBlocked,
//	|	Примечания AS Remarks}
//	|TOTALS
//	|	SUM(CardsCount)
//	|BY
//	|	OVERALL,
//	|	ТипСкидки
//	|{TOTALS BY
//	|	ДисконтКарт.* AS ДисконтКарт,
//	|	Identifier AS Identifier,
//	|	Клиент.* AS Клиент,
//	|	ДисконтныеКарты.Клиент.FullName AS ClientFullName,
//	|	ДисконтныеКарты.Клиент.ДатаРождения AS ClientDateOfBirth,
//	|	ДисконтныеКарты.Клиент.Телефон AS ClientPhone,
//	|	ДисконтныеКарты.Клиент.Fax AS ClientFax,
//	|	ДисконтныеКарты.Клиент.EMail AS ClientEMail,
//	|	ТипСкидки.* AS ТипСкидки,
//	|	ТипКлиента.* AS ТипКлиента,
//	|	ValidFrom AS ValidFrom,
//	|	ValidTo AS ValidTo,
//	|	TurnOffAutomaticDiscounts AS TurnOffAutomaticDiscounts,
//	|	IsBlocked AS IsBlocked}";
//	ReportBuilder.Text = QueryText;
//	ReportBuilder.FillSettings();
//	
//	// Initialize report builder with default query
//	vRB = New ReportBuilder(QueryText);
//	vRBSettings = vRB.GetSettings(True, True, True, True, True);
//	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
//	
//	// Set default report builder header text
//	ReportBuilder.HeaderText = NStr("EN='Guests with discount cards';RU='Гости с дисконтными картами';de='Gäste mit Diskontkarten'");
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
