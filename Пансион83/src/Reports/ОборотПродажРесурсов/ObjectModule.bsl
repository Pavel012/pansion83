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
//	If НЕ ЗначениеЗаполнено(ПериодС) Тогда
//		ПериодС = BegOfMonth(CurrentDate()); // For beg of month
//		ПериодПо = EndOfDay(CurrentDate());
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
//	If НЕ ЗначениеЗаполнено(ПериодС) And НЕ ЗначениеЗаполнено(ПериодПо) Тогда
//		vParamPresentation = vParamPresentation + NStr("en='Report period is not set';ru='Период отчета не установлен';de='Berichtszeitraum nicht festgelegt'") + 
//		                     ";" + Chars.LF;
//	ElsIf НЕ ЗначениеЗаполнено(ПериодС) And ЗначениеЗаполнено(ПериодПо) Тогда
//		vParamPresentation = vParamPresentation + NStr("ru = 'Период c '; en = 'Period from '") + 
//		                     Format(ПериодС, "DF='dd.MM.yyyy HH:mm:ss'") + 
//		                     ";" + Chars.LF;
//	ElsIf ЗначениеЗаполнено(ПериодС) And НЕ ЗначениеЗаполнено(ПериодПо) Тогда
//		vParamPresentation = vParamPresentation + NStr("ru = 'Период по '; en = 'Period to '") + 
//		                     Format(ПериодПо, "DF='dd.MM.yyyy HH:mm:ss'") + 
//		                     ";" + Chars.LF;
//	ElsIf ПериодС = ПериодПо Тогда
//		vParamPresentation = vParamPresentation + NStr("ru = 'Период на '; en = 'Period on '") + 
//		                     Format(ПериодС, "DF='dd.MM.yyyy HH:mm:ss'") + 
//		                     ";" + Chars.LF;
//	ElsIf ПериодС < ПериодПо Тогда
//		vParamPresentation = vParamPresentation + NStr("ru = 'Период '; en = 'Period '") + PeriodPresentation(ПериодС, ПериодПо, cmLocalizationCode()) + 
//		                     ";" + Chars.LF;
//	Else
//		vParamPresentation = vParamPresentation + NStr("en='Period is wrong!';ru='Неправильно задан период!';de='Der Zeitraum wurde falsch eingetragen!'") + 
//		                     ";" + Chars.LF;
//	EndIf;
//	If ЗначениеЗаполнено(Resource) Тогда
//		vParamPresentation = vParamPresentation + NStr("en='Resource ';ru='Ресурс ';de='Ressource'") + 
//							 TrimAll(Resource.Description) + 
//							 ";" + Chars.LF;
//	EndIf;							 
//	If ЗначениеЗаполнено(ResourceType) Тогда
//		If НЕ ResourceType.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("en='Resource type ';ru='Тип ресурса ';de='Ressourcentyp'") + 
//			                     TrimAll(ResourceType.Description) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("en='Resource types folder ';ru='Группа типов ресурсов ';de='Gruppe Ressourcentypen'") + 
//			                     TrimAll(ResourceType.Description) + 
//			                     ";" + Chars.LF;
//		EndIf;
//	EndIf;							 
//	If ЗначениеЗаполнено(Service) Тогда
//		If НЕ Service.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("en='Service ';ru='Услуга ';de='Dienstleistung'") + 
//								 TrimAll(Service.Description) + 
//								 ";" + Chars.LF;
//		 Else
//			vParamPresentation = vParamPresentation + NStr("ru = 'Группа услуг '; en = 'Services folder '") + 
//								 TrimAll(Service.Description) + 
//								 ";" + Chars.LF;
//		 EndIf;							 
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
//	ReportBuilder.Parameters.Вставить("qPeriodFrom", ПериодС);
//	ReportBuilder.Parameters.Вставить("qPeriodTo", ПериодПо);
//	ReportBuilder.Parameters.Вставить("qResource", Resource);
//	ReportBuilder.Parameters.Вставить("qIsEmptyResource", НЕ ЗначениеЗаполнено(Resource));
//	ReportBuilder.Parameters.Вставить("qResourceType", ResourceType);
//	ReportBuilder.Parameters.Вставить("qIsEmptyResourceType", НЕ ЗначениеЗаполнено(ResourceType));
//	ReportBuilder.Parameters.Вставить("qEmptyResourceType", Справочники.ТипыРесурсов.EmptyRef());
//	ReportBuilder.Parameters.Вставить("qService", Service);
//	ReportBuilder.Parameters.Вставить("qIsEmptyService", НЕ ЗначениеЗаполнено(Service));
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
//	|	ResourceSales.Фирма AS Фирма,
//	|	ResourceSales.Гостиница AS Гостиница,
//	|	ResourceSales.Валюта AS Валюта,
//	|	ResourceSales.Ресурс AS Ресурс,
//	|	ResourceSales.ТипРесурса AS ТипРесурса,
//	|	ResourceSales.ТипКлиента AS ТипКлиента,
//	|	ResourceSales.Услуга AS Услуга,
//	|	ResourceSales.УчетнаяДата AS УчетнаяДата,
//	|	ResourceSales.ДокОснование,
//	|	ResourceSales.SalesTurnover AS Сумма,
//	|	ResourceSales.ResourceRevenueTurnover AS ДоходРес,
//	|	ResourceSales.SalesWithoutVATTurnover AS SumWithoutVAT,
//	|	ResourceSales.ResourceRevenueWithoutVATTurnover AS ДоходРесБезНДС,
//	|	ResourceSales.CommissionSumTurnover AS СуммаКомиссии,
//	|	ResourceSales.CommissionSumWithoutVATTurnover AS КомиссияБезНДС,
//	|	ResourceSales.DiscountSumTurnover AS СуммаСкидки,
//	|	ResourceSales.DiscountSumWithoutVATTurnover AS СуммаСкидкиБезНДС,
//	|	CASE
//	|		WHEN ResourceSales.Услуга.RoomRevenueAmountsOnly THEN
//	|			0
//	|		ELSE
//	|			ResourceSales.HoursRentedTurnover 
//	|	END AS ПроданоЧасовРесурса,
//	|	ResourceSales.QuantityTurnover AS Количество
//	|{SELECT
//	|	Фирма.*,
//	|	Гостиница.*,
//	|	Валюта.*,
//	|	Ресурс.*,
//	|	ТипРесурса.*,
//	|	ТипКлиента.*,
//	|	ResourceSales.МаретингНапрвл.* AS МаретингНапрвл,
//	|	ResourceSales.ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
//	|	Услуга.*,
//	|	ДокОснование.*,
//	|	Сумма,
//	|	ДоходРес,
//	|	SumWithoutVAT,
//	|	ДоходРесБезНДС,
//	|	СуммаКомиссии,
//	|	КомиссияБезНДС,
//	|	СуммаСкидки,
//	|	СуммаСкидкиБезНДС,
//	|	ПроданоЧасовРесурса,
//	|	Количество,
//	|	УчетнаяДата,
//	|	(WEEK(ResourceSales.УчетнаяДата)) AS AccountingWeek,
//	|	(MONTH(ResourceSales.УчетнаяДата)) AS AccountingMonth,
//	|	(QUARTER(ResourceSales.УчетнаяДата)) AS AccountingQuarter,
//	|	(YEAR(ResourceSales.УчетнаяДата)) AS AccountingYear,
//	|	ResourceSales.Агент.*,
//	|	ResourceSales.Контрагент.*,
//	|	ResourceSales.Договор.*,
//	|	ResourceSales.ГруппаГостей.*,
//	|	ResourceSales.Фирма.*}
//	|FROM
//	|	AccumulationRegister.Продажи.Turnovers(
//	|			&qPeriodFrom,
//	|			&qPeriodTo,
//	|			Day,
//	|			Гостиница IN HIERARCHY (&qHotel)
//	|				AND (Ресурс = &qResource
//	|					OR &qIsEmptyResource)
//	|				AND (ТипРесурса IN HIERARCHY (&qResourceType)
//	|					OR &qIsEmptyResourceType)
//	|				AND ТипРесурса <> &qEmptyResourceType
//	|				AND (Услуга IN HIERARCHY (&qService)
//	|					OR &qIsEmptyService)
//	|				AND (Услуга IN HIERARCHY (&qServicesList)
//	|					OR (NOT &qUseServicesList))) AS ResourceSales
//	|{WHERE
//	|	ResourceSales.Фирма.*,
//	|	ResourceSales.Гостиница.*,
//	|	ResourceSales.Валюта.*,
//	|	ResourceSales.Ресурс.*,
//	|	ResourceSales.ТипРесурса.*,
//	|	ResourceSales.ТипКлиента.*,
//	|	ResourceSales.МаретингНапрвл.* AS МаретингНапрвл,
//	|	ResourceSales.ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
//	|	ResourceSales.ДокОснование.*,
//	|	ResourceSales.Услуга.*,
//	|	ResourceSales.SalesTurnover AS Сумма,
//	|	ResourceSales.ResourceRevenueTurnover AS ДоходРес,
//	|	ResourceSales.SalesWithoutVATTurnover AS SumWithoutVAT,
//	|	ResourceSales.ResourceRevenueWithoutVATTurnover AS ДоходРесБезНДС,
//	|	ResourceSales.CommissionSumTurnover AS СуммаКомиссии,
//	|	ResourceSales.CommissionSumWithoutVATTurnover AS КомиссияБезНДС,
//	|	ResourceSales.DiscountSumTurnover AS СуммаСкидки,
//	|	ResourceSales.DiscountSumWithoutVATTurnover AS СуммаСкидкиБезНДС,
//	|	CASE
//	|		WHEN ResourceSales.Услуга.RoomRevenueAmountsOnly THEN
//	|			0
//	|		ELSE
//	|			ResourceSales.HoursRentedTurnover 
//	|	END AS ПроданоЧасовРесурса,
//	|	ResourceSales.QuantityTurnover AS Количество,
//	|	ResourceSales.УчетнаяДата,
//	|	(WEEK(ResourceSales.Period)) AS AccountingWeek,
//	|	(MONTH(ResourceSales.Period)) AS AccountingMonth,
//	|	(QUARTER(ResourceSales.Period)) AS AccountingQuarter,
//	|	(YEAR(ResourceSales.Period)) AS AccountingYear,
//	|	ResourceSales.Агент.*,
//	|	ResourceSales.Контрагент.*,
//	|	ResourceSales.Договор.*,
//	|	ResourceSales.ГруппаГостей.*,
//	|	ResourceSales.Фирма.*}
//	|
//	|ORDER BY
//	|	Валюта,
//	|	Ресурс
//	|{ORDER BY
//	|	Фирма.*,
//	|	Гостиница.*,
//	|	Валюта.*,
//	|	Ресурс.*,
//	|	ТипРесурса.*,
//	|	ТипКлиента.*,
//	|	ResourceSales.МаретингНапрвл.* AS МаретингНапрвл,
//	|	ResourceSales.ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
//	|	Услуга.*,
//	|	ДокОснование.*,
//	|	Сумма,
//	|	ДоходРес,
//	|	SumWithoutVAT,
//	|	ДоходРесБезНДС,
//	|	СуммаКомиссии,
//	|	КомиссияБезНДС,
//	|	СуммаСкидки,
//	|	СуммаСкидкиБезНДС,
//	|	ПроданоЧасовРесурса,
//	|	УчетнаяДата,
//	|	(WEEK(ResourceSales.УчетнаяДата)) AS AccountingWeek,
//	|	(MONTH(ResourceSales.УчетнаяДата)) AS AccountingMonth,
//	|	(QUARTER(ResourceSales.УчетнаяДата)) AS AccountingQuarter,
//	|	(YEAR(ResourceSales.УчетнаяДата)) AS AccountingYear,
//	|	ResourceSales.Агент.*,
//	|	ResourceSales.Контрагент.*,
//	|	ResourceSales.Договор.*,
//	|	ResourceSales.ГруппаГостей.*,
//	|	ResourceSales.Фирма.*}
//	|TOTALS
//	|	SUM(Сумма),
//	|	SUM(ДоходРес),
//	|	SUM(SumWithoutVAT),
//	|	SUM(ДоходРесБезНДС),
//	|	SUM(СуммаКомиссии),
//	|	SUM(КомиссияБезНДС),
//	|	SUM(СуммаСкидки),
//	|	SUM(СуммаСкидкиБезНДС),
//	|	SUM(ПроданоЧасовРесурса),
//	|	SUM(Количество)
//	|BY
//	|	OVERALL,
//	|	Валюта,
//	|	Ресурс HIERARCHY
//	|{TOTALS BY
//	|	ResourceSales.Фирма.*,
//	|	ResourceSales.Гостиница.*,
//	|	ResourceSales.Валюта.*,
//	|	ResourceSales.Ресурс.*,
//	|	ResourceSales.ТипРесурса.*,
//	|	ResourceSales.ТипКлиента.*,
//	|	ResourceSales.МаретингНапрвл.* AS МаретингНапрвл,
//	|	ResourceSales.ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
//	|	ResourceSales.ДокОснование.*,
//	|	ResourceSales.Услуга.*,
//	|	ResourceSales.УчетнаяДата,
//	|	(WEEK(ResourceSales.УчетнаяДата)) AS AccountingWeek,
//	|	(MONTH(ResourceSales.УчетнаяДата)) AS AccountingMonth,
//	|	(QUARTER(ResourceSales.УчетнаяДата)) AS AccountingQuarter,
//	|	(YEAR(ResourceSales.УчетнаяДата)) AS AccountingYear,
//	|	ResourceSales.Агент.*,
//	|	ResourceSales.Контрагент.*,
//	|	ResourceSales.Договор.*,
//	|	ResourceSales.ГруппаГостей.*,
//	|	ResourceSales.Фирма.*}";
//	ReportBuilder.Text = QueryText;
//	ReportBuilder.FillSettings();
//	
//	// Initialize report builder with default query
//	vRB = New ReportBuilder(QueryText);
//	vRBSettings = vRB.GetSettings(True, True, True, True, True);
//	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
//	
//	// Set default report builder header text
//	ReportBuilder.HeaderText = NStr("EN='Resource sales turnovers';RU='Обороты по продажам ресурсов';de='Umsätze zu Ressourcenverkäufen'");
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
//	   Or pName = "ДоходРес" 
//	   Or pName = "SumWithoutVAT" 
//	   Or pName = "ДоходРесБезНДС" 
//	   Or pName = "СуммаКомиссии" 
//	   Or pName = "КомиссияБезНДС" 
//	   Or pName = "СуммаСкидки" 
//	   Or pName = "СуммаСкидкиБезНДС" 
//	   Or pName = "ПроданоЧасовРесурса" 
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
