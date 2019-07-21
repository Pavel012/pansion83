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
//		PeriodFrom = BegOfMonth(CurrentDate()); // For beg of month
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
//	If ЗначениеЗаполнено(Контрагент) Тогда
//		If НЕ Контрагент.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("de='Firma';en='Контрагент ';ru='Контрагент '") + 
//			                     TrimAll(Контрагент.Description) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("de='Gruppe Firmen';en='Customers folder ';ru='Группа контрагентов '") + 
//			                     TrimAll(Контрагент.Description) + 
//			                     ";" + Chars.LF;
//		EndIf;
//	EndIf;							 
//	If ЗначениеЗаполнено(Contract) Тогда
//		vParamPresentation = vParamPresentation + NStr("en='Contract ';ru='Договор ';de='Vertrag '") + 
//							 TrimAll(Contract.Description) + 
//							 ";" + Chars.LF;
//	EndIf;							 
//	If ЗначениеЗаполнено(GuestGroup) Тогда
//		vParamPresentation = vParamPresentation + NStr("ru = 'Группа гостей '; en = 'Guest group '") + 
//							 TrimAll(TrimAll(GuestGroup.Code) + " " + TrimAll(GuestGroup.Description)) + 
//							 ";" + Chars.LF;
//	EndIf;							 
//	If ЗначениеЗаполнено(ServiceGroup) Тогда
//		If НЕ ServiceGroup.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("ru = 'Набор услуг '; en = 'Service group '") + 
//			                     TrimAll(ServiceGroup.Description) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("ru = 'Группа наборов услуг '; en = 'Service groups folder '") + 
//			                     TrimAll(ServiceGroup.Description) + 
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
//	ReportBuilder.Parameters.Вставить("qPeriodFrom", PeriodFrom);
//	ReportBuilder.Parameters.Вставить("qPeriodTo", PeriodTo);
//	ReportBuilder.Parameters.Вставить("qCustomer", Контрагент);
//	ReportBuilder.Parameters.Вставить("qIsEmptyCustomer", НЕ ЗначениеЗаполнено(Контрагент));
//	ReportBuilder.Parameters.Вставить("qContract", Contract);
//	ReportBuilder.Parameters.Вставить("qIsEmptyContract", НЕ ЗначениеЗаполнено(Contract));
//	ReportBuilder.Parameters.Вставить("qGuestGroup", GuestGroup);
//	ReportBuilder.Parameters.Вставить("qIsEmptyGuestGroup", НЕ ЗначениеЗаполнено(GuestGroup));
//	vUseServicesList = False;
//	vServicesList = New СписокЗначений();
//	If ЗначениеЗаполнено(ServiceGroup) Тогда
//		If НЕ ServiceGroup.IncludeAll Тогда
//			vUseServicesList = True;
//			vServicesList.LoadValues(ServiceGroup.Services.UnloadColumn("Услуга"));
//		EndIf;
//	EndIf;
//	ReportBuilder.Parameters.Вставить("qUseServicesList", vUseServicesList);
//	ReportBuilder.Parameters.Вставить("qServicesList", vServicesList);
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
//	|	ServiceSales.Гостиница AS Гостиница,
//	|	ServiceSales.Фирма AS Фирма,
//	|	ServiceSales.Валюта AS Валюта,
//	|	ServiceSales.Услуга AS Услуга,
//	|	ServiceSales.СпособОплаты AS СпособОплаты,
//	|	ServiceSales.ТипКлиента AS ТипКлиента,
//	|	ServiceSales.МаретингНапрвл AS МаретингНапрвл,
//	|	ServiceSales.ИсточИнфоГостиница AS ИсточИнфоГостиница,
//	|	ServiceSales.Цена,
//	|	ServiceSales.УчетнаяДата AS УчетнаяДата,
//	|	ServiceSales.ДокОснование,
//	|	ServiceSales.СчетПроживания,
//	|	ServiceSales.QuantityTurnover AS Количество,
//	|	ServiceSales.SalesTurnover AS Сумма,
//	|	ServiceSales.SalesWithoutVATTurnover AS SumWithoutVAT,
//	|	ServiceSales.CommissionSumTurnover AS СуммаКомиссии,
//	|	ServiceSales.CommissionSumWithoutVATTurnover AS КомиссияБезНДС,
//	|	ServiceSales.DiscountSumTurnover AS СуммаСкидки,
//	|	ServiceSales.DiscountSumWithoutVATTurnover AS СуммаСкидкиБезНДС
//	|{SELECT
//	|	Гостиница.*,
//	|	Фирма.*,
//	|	Валюта.*,
//	|	Услуга.*,
//	|	СпособОплаты.*,
//	|	ТипКлиента.*,
//	|	МаретингНапрвл.*,
//	|	ИсточИнфоГостиница.*,
//	|	Цена,
//	|	ДокОснование.*,
//	|	СчетПроживания.*,
//	|	Количество,
//	|	Сумма,
//	|	SumWithoutVAT,
//	|	СуммаКомиссии,
//	|	КомиссияБезНДС,
//	|	СуммаСкидки,
//	|	СуммаСкидкиБезНДС,
//	|	УчетнаяДата,
//	|	(WEEK(ServiceSales.УчетнаяДата)) AS AccountingWeek,
//	|	(MONTH(ServiceSales.УчетнаяДата)) AS AccountingMonth,
//	|	(QUARTER(ServiceSales.УчетнаяДата)) AS AccountingQuarter,
//	|	(YEAR(ServiceSales.УчетнаяДата)) AS AccountingYear}
//	|FROM
//	|	AccumulationRegister.Продажи.Turnovers(
//	|			&qPeriodFrom,
//	|			&qPeriodTo,
//	|			Day,
//	|			Гостиница IN HIERARCHY (&qHotel)
//	|				AND (ДокОснование.Контрагент IN HIERARCHY (&qCustomer)
//	|					OR &qIsEmptyCustomer)
//	|				AND (ДокОснование.Договор = &qContract
//	|					OR &qIsEmptyContract)
//	|				AND (ДокОснование.ГруппаГостей = &qGuestGroup
//	|					OR &qIsEmptyGuestGroup)
//	|				AND (Услуга IN HIERARCHY (&qServicesList)
//	|					OR (NOT &qUseServicesList))) AS ServiceSales
//	|{WHERE
//	|	ServiceSales.Гостиница.*,
//	|	ServiceSales.Фирма.*,
//	|	ServiceSales.Валюта.*,
//	|	ServiceSales.Услуга.*,
//	|	ServiceSales.СпособОплаты.*,
//	|	ServiceSales.ТипКлиента.*,
//	|	ServiceSales.МаретингНапрвл.*,
//	|	ServiceSales.ИсточИнфоГостиница.*,
//	|	ServiceSales.Цена,
//	|	ServiceSales.ДокОснование.*,
//	|	ServiceSales.СчетПроживания.*,
//	|	ServiceSales.QuantityTurnover AS Количество,
//	|	ServiceSales.SalesTurnover AS Сумма,
//	|	ServiceSales.SalesWithoutVATTurnover AS SumWithoutVAT,
//	|	ServiceSales.CommissionSumTurnover AS СуммаКомиссии,
//	|	ServiceSales.CommissionSumWithoutVATTurnover AS КомиссияБезНДС,
//	|	ServiceSales.DiscountSumTurnover AS СуммаСкидки,
//	|	ServiceSales.DiscountSumWithoutVATTurnover AS СуммаСкидкиБезНДС,
//	|	ServiceSales.УчетнаяДата,
//	|	(WEEK(ServiceSales.Period)) AS AccountingWeek,
//	|	(MONTH(ServiceSales.Period)) AS AccountingMonth,
//	|	(QUARTER(ServiceSales.Period)) AS AccountingQuarter,
//	|	(YEAR(ServiceSales.Period)) AS AccountingYear}
//	|
//	|ORDER BY
//	|	Валюта,
//	|	Услуга
//	|{ORDER BY
//	|	Гостиница.*,
//	|	Фирма.*,
//	|	Валюта.*,
//	|	Услуга.*,
//	|	СпособОплаты.*,
//	|	ТипКлиента.*,
//	|	МаретингНапрвл.*,
//	|	ИсточИнфоГостиница.*,
//	|	Цена,
//	|	ДокОснование.*,
//	|	СчетПроживания.*,
//	|	Количество AS Количество,
//	|	Сумма AS Сумма,
//	|	SumWithoutVAT AS SumWithoutVAT,
//	|	СуммаКомиссии AS СуммаКомиссии,
//	|	КомиссияБезНДС AS КомиссияБезНДС,
//	|	СуммаСкидки AS СуммаСкидки,
//	|	СуммаСкидкиБезНДС AS СуммаСкидкиБезНДС,
//	|	УчетнаяДата,
//	|	(WEEK(ServiceSales.УчетнаяДата)) AS AccountingWeek,
//	|	(MONTH(ServiceSales.УчетнаяДата)) AS AccountingMonth,
//	|	(QUARTER(ServiceSales.УчетнаяДата)) AS AccountingQuarter,
//	|	(YEAR(ServiceSales.УчетнаяДата)) AS AccountingYear}
//	|TOTALS
//	|	SUM(Количество),
//	|	SUM(Сумма),
//	|	SUM(SumWithoutVAT),
//	|	SUM(СуммаКомиссии),
//	|	SUM(КомиссияБезНДС),
//	|	SUM(СуммаСкидки),
//	|	SUM(СуммаСкидкиБезНДС)
//	|BY
//	|	OVERALL,
//	|	Валюта,
//	|	Услуга HIERARCHY
//	|{TOTALS BY
//	|	Гостиница.*,
//	|	Фирма.*,
//	|	Валюта.*,
//	|	Услуга.*,
//	|	СпособОплаты.*,
//	|	ТипКлиента.*,
//	|	МаретингНапрвл.*,
//	|	ИсточИнфоГостиница.*,
//	|	ДокОснование.*,
//	|	СчетПроживания.*,
//	|	Цена,
//	|	УчетнаяДата,
//	|	(WEEK(ServiceSales.УчетнаяДата)) AS AccountingWeek,
//	|	(MONTH(ServiceSales.УчетнаяДата)) AS AccountingMonth,
//	|	(QUARTER(ServiceSales.УчетнаяДата)) AS AccountingQuarter,
//	|	(YEAR(ServiceSales.УчетнаяДата)) AS AccountingYear}";
//	ReportBuilder.Text = QueryText;
//	ReportBuilder.FillSettings();
//	
//	// Initialize report builder with default query
//	vRB = New ReportBuilder(QueryText);
//	vRBSettings = vRB.GetSettings(True, True, True, True, True);
//	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
//	
//	// Set default report builder header text
//	ReportBuilder.HeaderText = NStr("en='Service sales turnovers';ru='Обороты продаж услуг';de='Umsätze der Dienstleistungsverkäufe'");
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
//	If pName = "Сумма" 
//	   Or pName = "SumWithoutVAT" 
//	   Or pName = "СуммаКомиссии" 
//	   Or pName = "КомиссияБезНДС" 
//	   Or pName = "СуммаСкидки" 
//	   Or pName = "СуммаСкидкиБезНДС" 
//	   Or pName = "Количество" Тогда
//		Return True;
//	Else
//		Return False;
//	EndIf;
//EndFunction //pmIsResource
//
////-----------------------------------------------------------------------------
//// Reports framework end
////-----------------------------------------------------------------------------
