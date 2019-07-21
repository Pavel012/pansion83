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
//	If ЗначениеЗаполнено(Resource) Тогда
//		vParamPresentation = vParamPresentation + NStr("en='Resource ';ru='Ресурс ';de='Ressource'") + 
//							 TrimAll(Resource.Description) + 
//							 ";" + Chars.LF;
//	EndIf;							 
//	If ЗначениеЗаполнено(Service) Тогда
//		If НЕ Service.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("en='Service ';ru='Услуга ';de='Dienstleistung'") + 
//			                     TrimAll(Service.Description) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("ru = 'Группа услуг '; en = 'Services folder '") + 
//			                     TrimAll(Service.Description) + 
//			                     ";" + Chars.LF;
//		EndIf;
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
//	ReportBuilder.Parameters.Вставить("qForecastPeriodFrom", Max(BegOfDay(PeriodFrom), BegOfDay(CurrentDate())));
//	ReportBuilder.Parameters.Вставить("qForecastPeriodTo", ?(ЗначениеЗаполнено(PeriodTo), Max(PeriodTo, EndOfDay(CurrentDate()-24*3600)), '00010101'));
//	ReportBuilder.Parameters.Вставить("qService", Service);
//	ReportBuilder.Parameters.Вставить("qResource", Resource);
//	ReportBuilder.Parameters.Вставить("qResourceIsEmpty", НЕ ЗначениеЗаполнено(Resource));
//	ReportBuilder.Parameters.Вставить("qEmptyResourceType", Справочники.ТипыРесурсов.EmptyRef());
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
//	|	ПрогнозПродаж.Period AS Period,
//	|	ПрогнозПродаж.Гостиница AS Гостиница,
//	|	ПрогнозПродаж.Услуга AS Услуга,
//	|	ПрогнозПродаж.Цена AS Цена,
//	|	ПрогнозПродаж.Ресурс AS Ресурс,
//	|	ПрогнозПродаж.Клиент AS Клиент,
//	|	ПрогнозПродаж.Recorder,
//	|	ПрогнозПродаж.ДокОснование,
//	|	ПрогнозПродаж.ЭтоСторно,
//	|	ПрогнозПродаж.Валюта AS Валюта,
//	|	ПрогнозПродаж.Количество AS Количество,
//	|	ПрогнозПродаж.QuantityFact AS QuantityFact,
//	|	ПрогнозПродаж.QuantityPlan AS QuantityPlan,
//	|	ПрогнозПродаж.Сумма AS Сумма,
//	|	ПрогнозПродаж.SumFact AS SumFact,
//	|	ПрогнозПродаж.SumPlan AS SumPlan,
//	|	ПрогнозПродаж.SumWithoutVAT AS SumWithoutVAT,
//	|	ПрогнозПродаж.SumWithoutVATFact AS SumWithoutVATFact,
//	|	ПрогнозПродаж.SumWithoutVATPlan AS SumWithoutVATPlan,
//	|	ПрогнозПродаж.СуммаКомиссии AS СуммаКомиссии,
//	|	ПрогнозПродаж.CommissionSumFact AS CommissionSumFact,
//	|	ПрогнозПродаж.CommissionSumPlan AS CommissionSumPlan,
//	|	ПрогнозПродаж.КомиссияБезНДС AS КомиссияБезНДС,
//	|	ПрогнозПродаж.CommissionSumWithoutVATFact AS CommissionSumWithoutVATFact,
//	|	ПрогнозПродаж.CommissionSumWithoutVATPlan AS CommissionSumWithoutVATPlan,
//	|	ПрогнозПродаж.СуммаСкидки AS СуммаСкидки,
//	|	ПрогнозПродаж.DiscountSumFact AS DiscountSumFact,
//	|	ПрогнозПродаж.DiscountSumPlan AS DiscountSumPlan,
//	|	ПрогнозПродаж.СуммаСкидкиБезНДС AS СуммаСкидкиБезНДС,
//	|	ПрогнозПродаж.DiscountSumWithoutVATFact AS DiscountSumWithoutVATFact,
//	|	ПрогнозПродаж.DiscountSumWithoutVATPlan AS DiscountSumWithoutVATPlan,
//	|	ПрогнозПродаж.ДоходРес AS ДоходРес,
//	|	ПрогнозПродаж.ResourceRevenueFact AS ResourceRevenueFact,
//	|	ПрогнозПродаж.ResourceRevenuePlan AS ResourceRevenuePlan,
//	|	ПрогнозПродаж.ДоходРесБезНДС AS ДоходРесБезНДС,
//	|	ПрогнозПродаж.ResourceRevenueWithoutVATFact AS ResourceRevenueWithoutVATFact,
//	|	ПрогнозПродаж.ResourceRevenueWithoutVATPlan AS ResourceRevenueWithoutVATPlan,
//	|	ПрогнозПродаж.ПроданоЧасовРесурса AS ПроданоЧасовРесурса,
//	|	ПрогнозПродаж.HoursRentedFact AS HoursRentedFact,
//	|	ПрогнозПродаж.HoursRentedPlan AS HoursRentedPlan
//	|{SELECT
//	|	Period AS Period,
//	|	ПрогнозПродаж.УчетнаяДата AS УчетнаяДата,
//	|	(HOUR(ПрогнозПродаж.Period)) AS AccountingHour,
//	|	(DAY(ПрогнозПродаж.УчетнаяДата)) AS AccountingDay,
//	|	(WEEK(ПрогнозПродаж.УчетнаяДата)) AS AccountingWeek,
//	|	(MONTH(ПрогнозПродаж.УчетнаяДата)) AS AccountingMonth,
//	|	(QUARTER(ПрогнозПродаж.УчетнаяДата)) AS AccountingQuarter,
//	|	(YEAR(ПрогнозПродаж.УчетнаяДата)) AS AccountingYear,
//	|	Гостиница.* AS Гостиница,
//	|	ПрогнозПродаж.Фирма.* AS Фирма,
//	|	Валюта.* AS Валюта,
//	|	Услуга.* AS Услуга,
//	|	ПрогнозПродаж.DateTimeFrom AS DateTimeFrom,
//	|	(HOUR(ПрогнозПродаж.DateTimeFrom)) AS FromHour,
//	|	(DAY(ПрогнозПродаж.DateTimeFrom)) AS FromDay,
//	|	(WEEK(ПрогнозПродаж.DateTimeFrom)) AS FromWeek,
//	|	(MONTH(ПрогнозПродаж.DateTimeFrom)) AS FromMonth,
//	|	(QUARTER(ПрогнозПродаж.DateTimeFrom)) AS FromQuarter,
//	|	(YEAR(ПрогнозПродаж.DateTimeFrom)) AS FromYear,
//	|	ПрогнозПродаж.DateTimeTo AS DateTimeTo,
//	|	ПрогнозПродаж.Продолжительность AS Продолжительность,
//	|	Цена AS Цена,
//	|	Клиент.* AS Клиент,
//	|	ПрогнозПродаж.ТипКлиента.* AS ТипКлиента,
//	|	ПрогнозПродаж.ClientAge AS ClientAge,
//	|	ПрогнозПродаж.ClientCitizenship.* AS ClientCitizenship,
//	|	ПрогнозПродаж.ClientRegion AS ClientRegion,
//	|	ПрогнозПродаж.ClientCity AS ClientCity,
//	|	ПрогнозПродаж.Агент.* AS Агент,
//	|	ПрогнозПродаж.Контрагент.* AS Контрагент,
//	|	ПрогнозПродаж.Договор.* AS Договор,
//	|	ПрогнозПродаж.ГруппаГостей.* AS ГруппаГостей,
//	|	ПрогнозПродаж.МаретингНапрвл.* AS МаретингНапрвл,
//	|	ПрогнозПродаж.ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
//	|	ПрогнозПродаж.СчетПроживания.* AS СчетПроживания,
//	|	Recorder.* AS Recorder,
//	|	ДокОснование.* AS ДокОснование,
//	|	ПрогнозПродаж.КоличествоЧеловек AS КоличествоЧеловек,
//	|	ПрогнозПродаж.ТипРесурса.* AS ТипРесурса,
//	|	Ресурс.* AS Ресурс,
//	|	ПрогнозПродаж.СтавкаНДС.* AS СтавкаНДС,
//	|	ПрогнозПродаж.Автор.* AS Автор,
//	|	ЭтоСторно AS ЭтоСторно,
//	|	Количество AS Количество,
//	|	QuantityPlan AS QuantityPlan,
//	|	QuantityFact AS QuantityFact,
//	|	Сумма AS Сумма,
//	|	SumPlan AS SumPlan,
//	|	SumFact AS SumFact,
//	|	SumWithoutVAT AS SumWithoutVAT,
//	|	SumWithoutVATPlan AS SumWithoutVATPlan,
//	|	SumWithoutVATFact AS SumWithoutVATFact,
//	|	СуммаКомиссии AS СуммаКомиссии,
//	|	CommissionSumPlan AS CommissionSumPlan,
//	|	CommissionSumFact AS CommissionSumFact,
//	|	КомиссияБезНДС AS КомиссияБезНДС,
//	|	CommissionSumWithoutVATPlan AS CommissionSumWithoutVATPlan,
//	|	CommissionSumWithoutVATFact AS CommissionSumWithoutVATFact,
//	|	СуммаСкидки AS СуммаСкидки,
//	|	DiscountSumPlan AS DiscountSumPlan,
//	|	DiscountSumFact AS DiscountSumFact,
//	|	СуммаСкидкиБезНДС AS СуммаСкидкиБезНДС,
//	|	DiscountSumWithoutVATPlan AS DiscountSumWithoutVATPlan,
//	|	DiscountSumWithoutVATFact AS DiscountSumWithoutVATFact,
//	|	ДоходРес AS ДоходРес,
//	|	ResourceRevenueFact AS ResourceRevenueFact,
//	|	ResourceRevenuePlan AS ResourceRevenuePlan,
//	|	ДоходРесБезНДС AS ДоходРесБезНДС,
//	|	ResourceRevenueWithoutVATFact AS ResourceRevenueWithoutVATFact,
//	|	ResourceRevenueWithoutVATPlan AS ResourceRevenueWithoutVATPlan,
//	|	ПроданоЧасовРесурса AS ПроданоЧасовРесурса,
//	|	HoursRentedFact AS HoursRentedFact,
//	|	HoursRentedPlan AS HoursRentedPlan}
//	|FROM
//	|	(SELECT
//	|		ResourceSales.Period AS Period,
//	|		ResourceSales.Гостиница AS Гостиница,
//	|		ResourceSales.Фирма AS Фирма,
//	|		ResourceSales.Валюта AS Валюта,
//	|		ResourceSales.Услуга AS Услуга,
//	|		ResourceSales.УчетнаяДата AS УчетнаяДата,
//	|		CASE
//	|			WHEN ResourceSales.Ресурс <> ResourceSales.ДокОснование.Ресурс
//	|				THEN DATEADD(ResourceSales.УчетнаяДата, SECOND, DATEDIFF(BEGINOFPERIOD(ResourceSales.ВремяС, DAY), ResourceSales.ВремяС, SECOND))
//	|			ELSE ResourceSales.ДокОснование.DateTimeFrom
//	|		END AS DateTimeFrom,
//	|		CASE
//	|			WHEN ResourceSales.Ресурс <> ResourceSales.ДокОснование.Ресурс
//	|					AND ResourceSales.ВремяПо >= ResourceSales.ВремяС
//	|				THEN DATEDIFF(ResourceSales.ВремяС, ResourceSales.ВремяПо, HOUR)
//	|			WHEN ResourceSales.Ресурс <> ResourceSales.ДокОснование.Ресурс
//	|					AND ResourceSales.ВремяПо < ResourceSales.ВремяС
//	|				THEN DATEDIFF(ResourceSales.ВремяС, DATEADD(ResourceSales.ВремяПо, SECOND, 86400), HOUR)
//	|			ELSE ResourceSales.ДокОснование.Продолжительность
//	|		END AS Продолжительность,
//	|		CASE
//	|			WHEN ResourceSales.Ресурс <> ResourceSales.ДокОснование.Ресурс
//	|					AND ResourceSales.ВремяПо >= ResourceSales.ВремяС
//	|				THEN DATEADD(ResourceSales.УчетнаяДата, SECOND, DATEDIFF(BEGINOFPERIOD(ResourceSales.ВремяПо, DAY), ResourceSales.ВремяПо, SECOND))
//	|			WHEN ResourceSales.Ресурс <> ResourceSales.ДокОснование.Ресурс
//	|					AND ResourceSales.ВремяПо < ResourceSales.ВремяС
//	|				THEN DATEADD(ResourceSales.УчетнаяДата, SECOND, DATEDIFF(BEGINOFPERIOD(ResourceSales.ВремяПо, DAY), ResourceSales.ВремяПо, SECOND) + 86400)
//	|			ELSE ResourceSales.ДокОснование.DateTimeTo
//	|		END AS DateTimeTo,
//	|		ResourceSales.Цена AS Цена,
//	|		ResourceSales.Ресурс AS Ресурс,
//	|		ResourceSales.Клиент AS Клиент,
//	|		ResourceSales.ТипКлиента AS ТипКлиента,
//	|		ResourceSales.Клиент.Age AS ClientAge,
//	|		ResourceSales.Клиент.Гражданство AS ClientCitizenship,
//	|		ResourceSales.Клиент.Region AS ClientRegion,
//	|		ResourceSales.Клиент.City AS ClientCity,
//	|		ResourceSales.Агент AS Агент,
//	|		ResourceSales.Контрагент AS Контрагент,
//	|		ResourceSales.Договор AS Договор,
//	|		ResourceSales.ГруппаГостей AS ГруппаГостей,
//	|		ResourceSales.МаретингНапрвл AS МаретингНапрвл,
//	|		ResourceSales.ИсточИнфоГостиница AS ИсточИнфоГостиница,
//	|		ResourceSales.СчетПроживания AS СчетПроживания,
//	|		ResourceSales.Recorder AS Recorder,
//	|		ResourceSales.ДокОснование AS ДокОснование,
//	|		ResourceSales.СпособОплаты AS СпособОплаты,
//	|		ResourceSales.ДокОснование.КоличествоЧеловек AS КоличествоЧеловек,
//	|		ResourceSales.ТипРесурса AS ТипРесурса,
//	|		ResourceSales.СтавкаНДС AS СтавкаНДС,
//	|		ResourceSales.Автор AS Автор,
//	|		ResourceSales.ЭтоСторно AS ЭтоСторно,
//	|		ResourceSales.Количество AS Количество,
//	|		0 AS QuantityPlan,
//	|		ResourceSales.Количество AS QuantityFact,
//	|		ResourceSales.Продажи AS Сумма,
//	|		0 AS SumPlan,
//	|		ResourceSales.Продажи AS SumFact,
//	|		ResourceSales.ПродажиБезНДС AS SumWithoutVAT,
//	|		0 AS SumWithoutVATPlan,
//	|		ResourceSales.ПродажиБезНДС AS SumWithoutVATFact,
//	|		ResourceSales.СуммаКомиссии AS СуммаКомиссии,
//	|		0 AS CommissionSumPlan,
//	|		ResourceSales.СуммаКомиссии AS CommissionSumFact,
//	|		ResourceSales.КомиссияБезНДС AS КомиссияБезНДС,
//	|		0 AS CommissionSumWithoutVATPlan,
//	|		ResourceSales.КомиссияБезНДС AS CommissionSumWithoutVATFact,
//	|		ResourceSales.СуммаСкидки AS СуммаСкидки,
//	|		0 AS DiscountSumPlan,
//	|		ResourceSales.СуммаСкидки AS DiscountSumFact,
//	|		ResourceSales.СуммаСкидкиБезНДС AS СуммаСкидкиБезНДС,
//	|		0 AS DiscountSumWithoutVATPlan,
//	|		ResourceSales.СуммаСкидкиБезНДС AS DiscountSumWithoutVATFact,
//	|		ResourceSales.ДоходРес AS ДоходРес,
//	|		0 AS ResourceRevenuePlan,
//	|		ResourceSales.ДоходРес AS ResourceRevenueFact,
//	|		ResourceSales.ДоходРесБезНДС AS ДоходРесБезНДС,
//	|		0 AS ResourceRevenueWithoutVATPlan,
//	|		ResourceSales.ДоходРесБезНДС AS ResourceRevenueWithoutVATFact,
//	|		ResourceSales.ПроданоЧасовРесурса AS ПроданоЧасовРесурса,
//	|		0 AS HoursRentedPlan,
//	|		ResourceSales.ПроданоЧасовРесурса AS HoursRentedFact
//	|	FROM
//	|		AccumulationRegister.Продажи AS ResourceSales
//	|	WHERE
//	|		ResourceSales.Гостиница IN HIERARCHY(&qHotel)
//	|		AND ResourceSales.Услуга IN HIERARCHY(&qService)
//	|		AND (ResourceSales.Услуга IN (&qServicesList)
//	|				OR NOT &qUseServicesList)
//	|		AND (ResourceSales.Ресурс = &qResource
//	|				OR &qResourceIsEmpty)
//	|		AND ResourceSales.ТипРесурса <> &qEmptyResourceType
//	|		AND ResourceSales.Period BETWEEN &qPeriodFrom AND &qPeriodTo
//	|	
//	|	UNION ALL
//	|	
//	|	SELECT
//	|		ПланПродажРесурсов.Period,
//	|		ПланПродажРесурсов.Гостиница,
//	|		ПланПродажРесурсов.Фирма,
//	|		ПланПродажРесурсов.Валюта,
//	|		ПланПродажРесурсов.Услуга,
//	|		ПланПродажРесурсов.УчетнаяДата,
//	|		CASE
//	|			WHEN ПланПродажРесурсов.Ресурс <> ПланПродажРесурсов.Recorder.Ресурс
//	|				THEN DATEADD(ПланПродажРесурсов.УчетнаяДата, SECOND, DATEDIFF(BEGINOFPERIOD(ПланПродажРесурсов.ВремяС, DAY), ПланПродажРесурсов.ВремяС, SECOND))
//	|			ELSE ПланПродажРесурсов.Recorder.DateTimeFrom
//	|		END,
//	|		CASE
//	|			WHEN ПланПродажРесурсов.Ресурс <> ПланПродажРесурсов.Recorder.Ресурс
//	|					AND ПланПродажРесурсов.ВремяПо >= ПланПродажРесурсов.ВремяС
//	|				THEN DATEDIFF(ПланПродажРесурсов.ВремяС, ПланПродажРесурсов.ВремяПо, HOUR)
//	|			WHEN ПланПродажРесурсов.Ресурс <> ПланПродажРесурсов.Recorder.Ресурс
//	|					AND ПланПродажРесурсов.ВремяПо < ПланПродажРесурсов.ВремяС
//	|				THEN DATEDIFF(ПланПродажРесурсов.ВремяС, DATEADD(ПланПродажРесурсов.ВремяПо, SECOND, 86400), HOUR)
//	|			ELSE ПланПродажРесурсов.Recorder.Продолжительность
//	|		END,
//	|		CASE
//	|			WHEN ПланПродажРесурсов.Ресурс <> ПланПродажРесурсов.Recorder.Ресурс
//	|					AND ПланПродажРесурсов.ВремяПо >= ПланПродажРесурсов.ВремяС
//	|				THEN DATEADD(ПланПродажРесурсов.УчетнаяДата, SECOND, DATEDIFF(BEGINOFPERIOD(ПланПродажРесурсов.ВремяПо, DAY), ПланПродажРесурсов.ВремяПо, SECOND))
//	|			WHEN ПланПродажРесурсов.Ресурс <> ПланПродажРесурсов.Recorder.Ресурс
//	|					AND ПланПродажРесурсов.ВремяПо < ПланПродажРесурсов.ВремяС
//	|				THEN DATEADD(ПланПродажРесурсов.УчетнаяДата, SECOND, DATEDIFF(BEGINOFPERIOD(ПланПродажРесурсов.ВремяПо, DAY), ПланПродажРесурсов.ВремяПо, SECOND) + 86400)
//	|			ELSE ПланПродажРесурсов.Recorder.DateTimeTo
//	|		END,
//	|		ПланПродажРесурсов.Цена,
//	|		ПланПродажРесурсов.Ресурс,
//	|		ПланПродажРесурсов.Клиент,
//	|		ПланПродажРесурсов.ТипКлиента,
//	|		ПланПродажРесурсов.Клиент.Age,
//	|		ПланПродажРесурсов.Клиент.Гражданство,
//	|		ПланПродажРесурсов.Клиент.Region,
//	|		ПланПродажРесурсов.Клиент.City,
//	|		ПланПродажРесурсов.Агент,
//	|		ПланПродажРесурсов.Контрагент,
//	|		ПланПродажРесурсов.Договор,
//	|		ПланПродажРесурсов.ГруппаГостей,
//	|		ПланПродажРесурсов.МаретингНапрвл,
//	|		ПланПродажРесурсов.ИсточИнфоГостиница,
//	|		ПланПродажРесурсов.СчетПроживания,
//	|		ПланПродажРесурсов.Recorder,
//	|		ПланПродажРесурсов.ДокОснование,
//	|		ПланПродажРесурсов.Recorder.PlannedPaymentMethod,
//	|		ПланПродажРесурсов.Recorder.КоличествоЧеловек,
//	|		ПланПродажРесурсов.ТипРесурса,
//	|		ПланПродажРесурсов.СтавкаНДС,
//	|		ПланПродажРесурсов.Автор,
//	|		ПланПродажРесурсов.ЭтоСторно,
//	|		ПланПродажРесурсов.Количество,
//	|		ПланПродажРесурсов.Количество,
//	|		0,
//	|		ПланПродажРесурсов.Продажи,
//	|		ПланПродажРесурсов.Продажи,
//	|		0,
//	|		ПланПродажРесурсов.ПродажиБезНДС,
//	|		ПланПродажРесурсов.ПродажиБезНДС,
//	|		0,
//	|		ПланПродажРесурсов.СуммаКомиссии,
//	|		ПланПродажРесурсов.СуммаКомиссии,
//	|		0,
//	|		ПланПродажРесурсов.КомиссияБезНДС,
//	|		ПланПродажРесурсов.КомиссияБезНДС,
//	|		0,
//	|		ПланПродажРесурсов.СуммаСкидки,
//	|		ПланПродажРесурсов.СуммаСкидки,
//	|		0,
//	|		ПланПродажРесурсов.СуммаСкидкиБезНДС,
//	|		ПланПродажРесурсов.СуммаСкидкиБезНДС,
//	|		0,
//	|		ПланПродажРесурсов.ДоходРес,
//	|		ПланПродажРесурсов.ДоходРес,
//	|		0,
//	|		ПланПродажРесурсов.ДоходРесБезНДС,
//	|		ПланПродажРесурсов.ДоходРесБезНДС,
//	|		0,
//	|		ПланПродажРесурсов.ПроданоЧасовРесурса,
//	|		ПланПродажРесурсов.ПроданоЧасовРесурса,
//	|		0
//	|	FROM
//	|		AccumulationRegister.ПрогнозПродаж AS ПланПродажРесурсов
//	|	WHERE
//	|		ПланПродажРесурсов.Гостиница IN HIERARCHY(&qHotel)
//	|		AND ПланПродажРесурсов.Услуга IN HIERARCHY(&qService)
//	|		AND (ПланПродажРесурсов.Услуга IN (&qServicesList)
//	|				OR NOT &qUseServicesList)
//	|		AND (ПланПродажРесурсов.Ресурс = &qResource
//	|				OR &qResourceIsEmpty)
//	|		AND ПланПродажРесурсов.ТипРесурса <> &qEmptyResourceType
//	|		AND ПланПродажРесурсов.Period BETWEEN &qForecastPeriodFrom AND &qForecastPeriodTo) AS ПрогнозПродаж
//	|{WHERE
//	|	ПрогнозПродаж.Period AS Period,
//	|	ПрогнозПродаж.Гостиница.* AS Гостиница,
//	|	ПрогнозПродаж.Фирма.* AS Фирма,
//	|	ПрогнозПродаж.Валюта.* AS Валюта,
//	|	ПрогнозПродаж.Услуга.* AS Услуга,
//	|	ПрогнозПродаж.УчетнаяДата AS УчетнаяДата,
//	|	ПрогнозПродаж.DateTimeFrom AS DateTimeFrom,
//	|	ПрогнозПродаж.Продолжительность AS Продолжительность,
//	|	ПрогнозПродаж.DateTimeTo AS DateTimeTo,
//	|	ПрогнозПродаж.Цена AS Цена,
//	|	ПрогнозПродаж.Клиент.* AS Клиент,
//	|	ПрогнозПродаж.ТипКлиента.* AS ТипКлиента,
//	|	ПрогнозПродаж.ClientAge AS ClientAge,
//	|	ПрогнозПродаж.ClientCitizenship.* AS ClientCitizenship,
//	|	ПрогнозПродаж.ClientRegion AS ClientRegion,
//	|	ПрогнозПродаж.ClientCity AS ClientCity,
//	|	ПрогнозПродаж.Агент.* AS Агент,
//	|	ПрогнозПродаж.Контрагент.* AS Контрагент,
//	|	ПрогнозПродаж.Договор.* AS Договор,
//	|	ПрогнозПродаж.ГруппаГостей.* AS ГруппаГостей,
//	|	ПрогнозПродаж.МаретингНапрвл.* AS МаретингНапрвл,
//	|	ПрогнозПродаж.ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
//	|	ПрогнозПродаж.СчетПроживания.* AS СчетПроживания,
//	|	ПрогнозПродаж.Recorder.* AS Recorder,
//	|	ПрогнозПродаж.ДокОснование.* AS ДокОснование,
//	|	ПрогнозПродаж.КоличествоЧеловек AS КоличествоЧеловек,
//	|	ПрогнозПродаж.ТипРесурса.* AS ТипРесурса,
//	|	ПрогнозПродаж.Ресурс.* AS Ресурс,
//	|	ПрогнозПродаж.СтавкаНДС.* AS СтавкаНДС,
//	|	ПрогнозПродаж.Автор.* AS Автор,
//	|	ПрогнозПродаж.ЭтоСторно AS ЭтоСторно,
//	|	ПрогнозПродаж.Количество AS Количество,
//	|	ПрогнозПродаж.QuantityPlan AS QuantityPlan,
//	|	ПрогнозПродаж.QuantityFact AS QuantityFact,
//	|	ПрогнозПродаж.Сумма AS Сумма,
//	|	ПрогнозПродаж.SumPlan AS SumPlan,
//	|	ПрогнозПродаж.SumFact AS SumFact,
//	|	ПрогнозПродаж.SumWithoutVAT AS SumWithoutVAT,
//	|	ПрогнозПродаж.SumWithoutVATPlan AS SumWithoutVATPlan,
//	|	ПрогнозПродаж.SumWithoutVATFact AS SumWithoutVATFact,
//	|	ПрогнозПродаж.СуммаКомиссии AS СуммаКомиссии,
//	|	ПрогнозПродаж.CommissionSumPlan AS CommissionSumPlan,
//	|	ПрогнозПродаж.CommissionSumFact AS CommissionSumFact,
//	|	ПрогнозПродаж.КомиссияБезНДС AS КомиссияБезНДС,
//	|	ПрогнозПродаж.CommissionSumWithoutVATPlan AS CommissionSumWithoutVATPlan,
//	|	ПрогнозПродаж.CommissionSumWithoutVATFact AS CommissionSumWithoutVATFact,
//	|	ПрогнозПродаж.СуммаСкидки AS СуммаСкидки,
//	|	ПрогнозПродаж.DiscountSumPlan AS DiscountSumPlan,
//	|	ПрогнозПродаж.DiscountSumFact AS DiscountSumFact,
//	|	ПрогнозПродаж.СуммаСкидкиБезНДС AS СуммаСкидкиБезНДС,
//	|	ПрогнозПродаж.DiscountSumWithoutVATPlan AS DiscountSumWithoutVATPlan,
//	|	ПрогнозПродаж.DiscountSumWithoutVATFact AS DiscountSumWithoutVATFact,
//	|	ПрогнозПродаж.ДоходРес AS ДоходРес,
//	|	ПрогнозПродаж.ResourceRevenueFact AS ResourceRevenueFact,
//	|	ПрогнозПродаж.ResourceRevenuePlan AS ResourceRevenuePlan,
//	|	ПрогнозПродаж.ДоходРесБезНДС AS ДоходРесБезНДС,
//	|	ПрогнозПродаж.ResourceRevenueWithoutVATFact AS ResourceRevenueWithoutVATFact,
//	|	ПрогнозПродаж.ResourceRevenueWithoutVATPlan AS ResourceRevenueWithoutVATPlan,
//	|	ПрогнозПродаж.ПроданоЧасовРесурса AS ПроданоЧасовРесурса,
//	|	ПрогнозПродаж.HoursRentedFact AS HoursRentedFact,
//	|	ПрогнозПродаж.HoursRentedPlan AS HoursRentedPlan}
//	|
//	|ORDER BY
//	|	Валюта,
//	|	Гостиница,
//	|	Услуга,
//	|	Ресурс,
//	|	Period
//	|{ORDER BY
//	|	Period AS Period,
//	|	Гостиница.* AS Гостиница,
//	|	ПрогнозПродаж.Фирма.* AS Фирма,
//	|	Валюта.* AS Валюта,
//	|	Услуга.* AS Услуга,
//	|	ПрогнозПродаж.УчетнаяДата AS УчетнаяДата,
//	|	ПрогнозПродаж.DateTimeFrom AS DateTimeFrom,
//	|	ПрогнозПродаж.Продолжительность AS Продолжительность,
//	|	ПрогнозПродаж.DateTimeTo AS DateTimeTo,
//	|	Цена AS Цена,
//	|	Клиент.* AS Клиент,
//	|	ПрогнозПродаж.ТипКлиента.* AS ТипКлиента,
//	|	ПрогнозПродаж.ClientAge AS ClientAge,
//	|	ПрогнозПродаж.ClientCitizenship.* AS ClientCitizenship,
//	|	ПрогнозПродаж.ClientRegion AS ClientRegion,
//	|	ПрогнозПродаж.ClientCity AS ClientCity,
//	|	ПрогнозПродаж.Агент.* AS Агент,
//	|	ПрогнозПродаж.Контрагент.* AS Контрагент,
//	|	ПрогнозПродаж.Договор.* AS Договор,
//	|	ПрогнозПродаж.ГруппаГостей.* AS ГруппаГостей,
//	|	ПрогнозПродаж.МаретингНапрвл.* AS МаретингНапрвл,
//	|	ПрогнозПродаж.ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
//	|	ПрогнозПродаж.СчетПроживания.* AS СчетПроживания,
//	|	Recorder.* AS Recorder,
//	|	ДокОснование.* AS ДокОснование,
//	|	ПрогнозПродаж.КоличествоЧеловек AS КоличествоЧеловек,
//	|	ПрогнозПродаж.ТипРесурса.* AS ТипРесурса,
//	|	Ресурс.* AS Ресурс,
//	|	ПрогнозПродаж.СтавкаНДС.* AS СтавкаНДС,
//	|	ПрогнозПродаж.Автор.* AS Автор,
//	|	ЭтоСторно AS ЭтоСторно,
//	|	Количество AS Количество,
//	|	QuantityPlan AS QuantityPlan,
//	|	QuantityFact AS QuantityFact,
//	|	Сумма AS Сумма,
//	|	SumPlan AS SumPlan,
//	|	SumFact AS SumFact,
//	|	SumWithoutVAT AS SumWithoutVAT,
//	|	SumWithoutVATPlan AS SumWithoutVATPlan,
//	|	SumWithoutVATFact AS SumWithoutVATFact,
//	|	СуммаКомиссии AS СуммаКомиссии,
//	|	CommissionSumPlan AS CommissionSumPlan,
//	|	CommissionSumFact AS CommissionSumFact,
//	|	КомиссияБезНДС AS КомиссияБезНДС,
//	|	CommissionSumWithoutVATPlan AS CommissionSumWithoutVATPlan,
//	|	CommissionSumWithoutVATFact AS CommissionSumWithoutVATFact,
//	|	СуммаСкидки AS СуммаСкидки,
//	|	DiscountSumPlan AS DiscountSumPlan,
//	|	DiscountSumFact AS DiscountSumFact,
//	|	СуммаСкидкиБезНДС AS СуммаСкидкиБезНДС,
//	|	DiscountSumWithoutVATPlan AS DiscountSumWithoutVATPlan,
//	|	DiscountSumWithoutVATFact AS DiscountSumWithoutVATFact,
//	|	ДоходРес AS ДоходРес,
//	|	ResourceRevenueFact AS ResourceRevenueFact,
//	|	ResourceRevenuePlan AS ResourceRevenuePlan,
//	|	ДоходРесБезНДС AS ДоходРесБезНДС,
//	|	ResourceRevenueWithoutVATFact AS ResourceRevenueWithoutVATFact,
//	|	ResourceRevenueWithoutVATPlan AS ResourceRevenueWithoutVATPlan,
//	|	ПроданоЧасовРесурса AS ПроданоЧасовРесурса,
//	|	HoursRentedFact AS HoursRentedFact,
//	|	HoursRentedPlan AS HoursRentedPlan}
//	|TOTALS
//	|	SUM(Количество),
//	|	SUM(QuantityFact),
//	|	SUM(QuantityPlan),
//	|	SUM(Сумма),
//	|	SUM(SumFact),
//	|	SUM(SumPlan),
//	|	SUM(SumWithoutVAT),
//	|	SUM(SumWithoutVATFact),
//	|	SUM(SumWithoutVATPlan),
//	|	SUM(СуммаКомиссии),
//	|	SUM(CommissionSumFact),
//	|	SUM(CommissionSumPlan),
//	|	SUM(КомиссияБезНДС),
//	|	SUM(CommissionSumWithoutVATFact),
//	|	SUM(CommissionSumWithoutVATPlan),
//	|	SUM(СуммаСкидки),
//	|	SUM(DiscountSumFact),
//	|	SUM(DiscountSumPlan),
//	|	SUM(СуммаСкидкиБезНДС),
//	|	SUM(DiscountSumWithoutVATFact),
//	|	SUM(DiscountSumWithoutVATPlan),
//	|	SUM(ДоходРес),
//	|	SUM(ResourceRevenueFact),
//	|	SUM(ResourceRevenuePlan),
//	|	SUM(ДоходРесБезНДС),
//	|	SUM(ResourceRevenueWithoutVATFact),
//	|	SUM(ResourceRevenueWithoutVATPlan),
//	|	SUM(ПроданоЧасовРесурса),
//	|	SUM(HoursRentedFact),
//	|	SUM(HoursRentedPlan)
//	|BY
//	|	OVERALL,
//	|	Валюта,
//	|	Гостиница,
//	|	Услуга,
//	|	Ресурс,
//	|	Period
//	|{TOTALS BY
//	|	Period AS Period,
//	|	(HOUR(ПрогнозПродаж.Period)) AS AccountingHour,
//	|	(DAY(ПрогнозПродаж.УчетнаяДата)) AS AccountingDay,
//	|	(WEEK(ПрогнозПродаж.УчетнаяДата)) AS AccountingWeek,
//	|	(MONTH(ПрогнозПродаж.УчетнаяДата)) AS AccountingMonth,
//	|	(QUARTER(ПрогнозПродаж.УчетнаяДата)) AS AccountingQuarter,
//	|	(YEAR(ПрогнозПродаж.УчетнаяДата)) AS AccountingYear,
//	|	(HOUR(ПрогнозПродаж.DateTimeFrom)) AS FromHour,
//	|	(DAY(ПрогнозПродаж.DateTimeFrom)) AS FromDay,
//	|	(WEEK(ПрогнозПродаж.DateTimeFrom)) AS FromWeek,
//	|	(MONTH(ПрогнозПродаж.DateTimeFrom)) AS FromMonth,
//	|	(QUARTER(ПрогнозПродаж.DateTimeFrom)) AS FromQuarter,
//	|	(YEAR(ПрогнозПродаж.DateTimeFrom)) AS FromYear,
//	|	Гостиница.* AS Гостиница,
//	|	ПрогнозПродаж.Фирма.* AS Фирма,
//	|	Валюта.* AS Валюта,
//	|	Услуга.* AS Услуга,
//	|	Цена AS Цена,
//	|	Клиент.* AS Клиент,
//	|	ПрогнозПродаж.ТипКлиента.* AS ТипКлиента,
//	|	ПрогнозПродаж.ClientAge AS ClientAge,
//	|	ПрогнозПродаж.ClientCitizenship.* AS ClientCitizenship,
//	|	ПрогнозПродаж.ClientRegion AS ClientRegion,
//	|	ПрогнозПродаж.ClientCity AS ClientCity,
//	|	ПрогнозПродаж.Агент.* AS Агент,
//	|	ПрогнозПродаж.Контрагент.* AS Контрагент,
//	|	ПрогнозПродаж.Договор.* AS Договор,
//	|	ПрогнозПродаж.ГруппаГостей.* AS ГруппаГостей,
//	|	ПрогнозПродаж.МаретингНапрвл.* AS МаретингНапрвл,
//	|	ПрогнозПродаж.ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
//	|	ПрогнозПродаж.СчетПроживания.* AS СчетПроживания,
//	|	Recorder.* AS Recorder,
//	|	ДокОснование.* AS ДокОснование,
//	|	ПрогнозПродаж.КоличествоЧеловек AS КоличествоЧеловек,
//	|	ПрогнозПродаж.ТипРесурса.* AS ТипРесурса,
//	|	Ресурс.* AS Ресурс,
//	|	ПрогнозПродаж.СтавкаНДС.* AS СтавкаНДС,
//	|	ПрогнозПродаж.Автор.* AS Автор,
//	|	ЭтоСторно AS IsStorno}";
//	ReportBuilder.Text = QueryText;
//	ReportBuilder.FillSettings();
//	
//	// Initialize report builder with default query
//	vRB = New ReportBuilder(QueryText);
//	vRBSettings = vRB.GetSettings(True, True, True, True, True);
//	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
//	
//	// Set default report builder header text
//	ReportBuilder.HeaderText = NStr("EN='Resource sales forecast';RU='Планируемые продажи ресурсов';de='Geplante Ressourcenverkäufen'");
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
//	If pName = "Количество" 
//	   Or pName = "QuantityFact" 
//	   Or pName = "QuantityPlan" 
//	   Or pName = "Сумма" 
//	   Or pName = "SumFact" 
//	   Or pName = "SumPlan" 
//	   Or pName = "SumWithoutVAT" 
//	   Or pName = "SumWithoutVATFact" 
//	   Or pName = "SumWithoutVATPlan" 
//	   Or pName = "СуммаКомиссии" 
//	   Or pName = "CommissionSumFact" 
//	   Or pName = "CommissionSumPlan" 
//	   Or pName = "КомиссияБезНДС" 
//	   Or pName = "CommissionSumWithoutVATFact" 
//	   Or pName = "CommissionSumWithoutVATPlan" 
//	   Or pName = "СуммаСкидки" 
//	   Or pName = "DiscountSumFact" 
//	   Or pName = "DiscountSumPlan" 
//	   Or pName = "СуммаСкидкиБезНДС" 
//	   Or pName = "DiscountSumWithoutVATFact" 
//	   Or pName = "DiscountSumWithoutVATPlan"
//	   Or pName = "ДоходРес" 
//	   Or pName = "ResourceRevenueFact" 
//	   Or pName = "ResourceRevenuePlan"
//	   Or pName = "ДоходРесБезНДС" 
//	   Or pName = "ResourceRevenueWithoutVATFact" 
//	   Or pName = "ResourceRevenueWithoutVATPlan"
//	   Or pName = "ПроданоЧасовРесурса" 
//	   Or pName = "HoursRentedFact" 
//	   Or pName = "HoursRentedPlan" Тогда
//		Return True;
//	Else
//		Return False;
//	EndIf;
//EndFunction //pmIsResource
//
////-----------------------------------------------------------------------------
//// Reports framework end
////-----------------------------------------------------------------------------
