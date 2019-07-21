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
//	// Check if there are any filters set for the report builder
//	vFilterIsNotSet = True;
//	For Each vFilterRow In ReportBuilder.Filter Do
//		If vFilterRow.Use Тогда
//			vFilterIsNotSet = False;
//			Break;
//		EndIf;
//	EndDo;
//	// Check if there is any custom ordering applied for the report builder
//	vOrderIsNotSet = True;
//	If ReportBuilder.Order.Count() > 0 Тогда
//		vOrderIsNotSet = False;
//	EndIf;
//	
//	// Reset report builder template
//	ReportBuilder.Template = Неопределено;
//	
//	// Initialize report builder query generator attributes
//	ReportBuilder.PresentationAdding = PresentationAdditionType.Add;
//	
//	// Run main query to get data
//	vQry = New Query();
//	vQry.Text = TrimAll(QueryText);
//	vQry.SetParameter("qHotel", Гостиница);
//	vQry.SetParameter("qPeriodFrom", PeriodFrom);
//	vQry.SetParameter("qPeriodTo", PeriodTo);
//	vQry.SetParameter("qForecastPeriodFrom", Max(BegOfDay(PeriodFrom), BegOfDay(CurrentDate())));
//	vQry.SetParameter("qForecastPeriodTo", ?(ЗначениеЗаполнено(PeriodTo), Max(PeriodTo, EndOfDay(CurrentDate()-24*3600)), '00010101'));
//	vQry.SetParameter("qResource", Resource);
//	vQry.SetParameter("qIsEmptyResource", НЕ ЗначениеЗаполнено(Resource));
//	vQry.SetParameter("qResourceType", ResourceType);
//	vQry.SetParameter("qIsEmptyResourceType", НЕ ЗначениеЗаполнено(ResourceType));
//	vQry.SetParameter("qEmptyResourceType", Справочники.ТипыРесурсов.EmptyRef());
//	vQry.SetParameter("qService", Service);
//	vQry.SetParameter("qIsEmptyService", НЕ ЗначениеЗаполнено(Service));
//	vUseServicesList = False;
//	vServicesList = New СписокЗначений();
//	If ЗначениеЗаполнено(ServiceGroup) Тогда
//		If НЕ ServiceGroup.IncludeAll Тогда
//			vUseServicesList = True;
//			vServicesList.LoadValues(ServiceGroup.Services.UnloadColumn("Услуга"));
//		EndIf;
//	EndIf;
//	vQry.SetParameter("qUseServicesList", vUseServicesList);
//	vQry.SetParameter("qServicesList", vServicesList);
//	vResults = vQry.Execute().Unload();
//	
//	// Move totals row to the last row Должность
//	If vResults.Count() > 0 Тогда
//		vRow = vResults.Get(0);
//		
//		// Move first row to the last Должность or remove totals if there are filters or custom ordering
//		If vResults.Count() > 1 Тогда
//			If vFilterIsNotSet And vOrderIsNotSet Тогда
//				vResults.Move(vRow, vResults.Count() - 1);
//			Else
//				vResults.Delete(vRow);
//			EndIf;
//		EndIf;
//	EndIf;
//	
//	vDaysRentedQry = New Query();
//	vDaysRentedQry.Text = 
//	"SELECT
//	|	ОборотПродажРесурсов.ResourceRevenueTurnover,
//	|	ОборотПродажРесурсов.HoursRentedTurnover
//	|FROM
//	|	AccumulationRegister.Продажи.Turnovers(&qBegOfDay, &qEndOfDay, Period, Ресурс = &qResource) AS ОборотПродажРесурсов";
//	
//	// Initialize report totals
//	vTotalWorkingHours = 0;
//	vTotalWorkingDays = 0;
//	vTotalRevenuePlanned = 0;
//	vTotalDaysRented = 0;
//	
//	// For each row in resulting table run query to get working days, working hours, revenue planned
//	i = 0;
//	For Each vRow In vResults Do
//		// Initialize resource totals
//		vWorkingHours = 0;
//		vWorkingDays = 0;
//		vRevenuePlanned = 0;
//		vDaysRented = 0;
//		
//		If ЗначениеЗаполнено(vRow.Resource) Тогда
//			// Do for each period day in the resources calendar
//			If ЗначениеЗаполнено(vRow.Resource) Тогда
//				vCurResource = vRow.Resource;
//				If ЗначениеЗаполнено(vCurResource.Calendar) Тогда
//					vDays = vCurResource.Calendar.GetObject().pmGetDays(PeriodFrom, PeriodTo);
//					For Each vDaysRow In vDays Do
//						If ЗначениеЗаполнено(vDaysRow.Timetable) Тогда
//							If vDaysRow.Timetable.WorkingHoursPerDay > 0 Тогда
//								vWorkingDays = vWorkingDays + 1;
//								vWorkingHours = vWorkingHours + vDaysRow.Timetable.WorkingHoursPerDay;
//								vRevenuePlanned = vRevenuePlanned + vDaysRow.Timetable.WorkingHoursPerDay*vCurResource.RackRate;
//							EndIf;
//						ElsIf vCurResource.RoundTheClockOperation Тогда
//							vWorkingDays = vWorkingDays + 1;
//							vWorkingHours = vWorkingHours + 24;
//							vRevenuePlanned = vRevenuePlanned + 24*vCurResource.RackRate;
//						EndIf;
//						// Check if this day was sold
//						vDaysRentedQry.SetParameter("qBegOfDay", BegOfDay(vDaysRow.Period));
//						vDaysRentedQry.SetParameter("qEndOfDay", EndOfDay(vDaysRow.Period));
//						vDaysRentedQry.SetParameter("qResource", vCurResource);
//						vDaysRentedQryRes = vDaysRentedQry.Execute().Unload();
//						For Each vDaysRentedQryResRow In vDaysRentedQryRes Do
//							If vDaysRentedQryResRow.ResourceRevenueTurnover > 0 Or
//							   vDaysRentedQryResRow.HoursRentedTurnover > 0 Тогда
//								vDaysRented = vDaysRented + 1;
//								Break;
//							EndIf;
//						EndDo;
//					EndDo;
//				ElsIf vCurResource.RoundTheClockOperation Тогда
//					vWorkingDays = Round((EndOfDay(PeriodTo) - BegOfDay(PeriodFrom))/(24*3600), 0);
//					vWorkingHours = vWorkingDays*24;
//					vRevenuePlanned = vWorkingHours*vCurResource.RackRate;
//				EndIf;
//			EndIf;
//			
//			// Fill resource totals
//			vRow.WorkingHours = vWorkingHours;
//			vRow.WorkingDays = vWorkingDays;
//			vRow.RevenuePlanned = vRevenuePlanned;
//			vRow.DaysRented = vDaysRented;
//	
//			// Fill resource percents
//			vRow.WorkingHoursPercent = ?(vRow.WorkingHours = 0, 0, 100 * vRow.HoursRented/vRow.WorkingHours);
//			vRow.WorkingDaysPercent = ?(vRow.WorkingDays = 0, 0, 100 * vRow.DaysRented/vRow.WorkingDays);
//			vRow.RevenuePercent = ?(vRow.RevenuePlanned = 0, 0, 100 * vRow.ResourceRevenue/vRow.RevenuePlanned);
//			
//			// Fill report totals
//			If ЗначениеЗаполнено(vRow.Resource) Тогда
//				vTotalWorkingHours = vTotalWorkingHours + vWorkingHours;
//				vTotalWorkingDays = vTotalWorkingDays + vWorkingDays;
//				vTotalRevenuePlanned = vTotalRevenuePlanned + vRevenuePlanned;
//				vTotalDaysRented = vTotalDaysRented + vDaysRented;
//			EndIf;
//		EndIf;
//		
//		i = i + 1;
//	EndDo;
//	
//	// Calculate percents for report totals row
//	If vResults.Count() > 0 Тогда
//		vTotalsRow = vResults.Get(vResults.Count()-1);
//		
//		// Fill totals
//		vTotalsRow.WorkingHours = vTotalWorkingHours;
//		vTotalsRow.WorkingDays = vTotalWorkingDays;
//		vTotalsRow.RevenuePlanned = vTotalRevenuePlanned;
//		vTotalsRow.DaysRented = vTotalDaysRented;
//
//		// Fill percents
//		vTotalsRow.WorkingHoursPercent = ?(vRow.WorkingHours = 0, 0, 100 * vTotalsRow.ПроданоЧасовРесурса/vTotalsRow.WorkingHours);
//		vTotalsRow.WorkingDaysPercent = ?(vRow.WorkingDays = 0, 0, 100 * vTotalsRow.DaysRented/vTotalsRow.WorkingDays);
//		vTotalsRow.RevenuePercent = ?(vRow.RevenuePlanned = 0, 0, 100 * vTotalsRow.ДоходРес/vTotalsRow.RevenuePlanned);
//	EndIf;
//	
//	// Save current report builder settings
//	vCurReportBuilderSettings = ReportBuilder.GetSettings(True, True, True, True, True);
//	
//	// Set resulting table as data source for the report builder
//	ReportBuilder.DataSource = New DataSourceDescription(vResults);
//	
//	// Fill report builder fields presentations from the report template
//	cmFillReportAttributesPresentations(ThisObject);
//	
//	// Apply current report builder settings
//	ReportBuilder.SetSettings(vCurReportBuilderSettings);
//	
//	// Execute report builder
//	ReportBuilder.Execute();
//	
//	// Apply appearance settings to the report template
//	//vTemplateAttributes = cmApplyReportTemplateAppearance(ThisObject);
//	
//	// Output report to the spreadsheet
//	ReportBuilder.Put(pSpreadsheet);
//	//ReportBuilder.Template.Show(); // For debug purpose
//
//	// Add totals caption and appearance to the last report row
//	If vResults.Count() > 0 And vFilterIsNotSet And vOrderIsNotSet Тогда
//		vLastRepRow = pSpreadsheet.Area(pSpreadsheet.TableHeight-2, 2, pSpreadsheet.TableHeight-2, pSpreadsheet.TableWidth);
//		vLastRepRow.Font = New Font(pSpreadsheet.Area(pSpreadsheet.TableHeight-2, 2, pSpreadsheet.TableHeight-2, 2).Font, , , True);
//		vLastRepRow.BackColor = pSpreadsheet.Area(4, 2, 4, 2).BackColor;
//		pSpreadsheet.Area(pSpreadsheet.TableHeight-2, 2, pSpreadsheet.TableHeight-2, 2).Text = NStr("en='Totals';ru='Итог';de='Ergebnis'");
//	EndIf;
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
//	|	ResourceSales.Валюта AS Валюта,
//	|	ResourceSales.Гостиница AS Гостиница,
//	|	ResourceSales.Ресурс AS Ресурс,
//	|	SUM(ResourceSales.SumTurnover) AS Сумма,
//	|	SUM(ResourceSales.SumWithoutVATTurnover) AS SumWithoutVAT,
//	|	SUM(ResourceSales.QuantityTurnover) AS Количество,
//	|	SUM(ResourceSales.ResourceRevenueTurnover) AS ДоходРес,
//	|	SUM(ResourceSales.ResourceRevenueWithoutVATTurnover) AS ДоходРесБезНДС,
//	|	SUM(ResourceSales.CommissionSumTurnover) AS СуммаКомиссии,
//	|	SUM(ResourceSales.CommissionSumWithoutVATTurnover) AS КомиссияБезНДС,
//	|	SUM(ResourceSales.DiscountSumTurnover) AS СуммаСкидки,
//	|	SUM(ResourceSales.DiscountSumWithoutVATTurnover) AS СуммаСкидкиБезНДС,
//	|	SUM(ResourceSales.HoursRentedTurnover) AS ПроданоЧасовРесурса,
//	|	0 AS DaysRented,
//	|	0 AS WorkingHours,
//	|	0 AS WorkingDays,
//	|	0 AS RevenuePlanned,
//	|	0 AS WorkingHoursPercent,
//	|	0 AS WorkingDaysPercent,
//	|	0 AS RevenuePercent
//	|{SELECT
//	|	Валюта.*,
//	|	Гостиница.*,
//	|	Ресурс.*,
//	|	Сумма,
//	|	SumWithoutVAT,
//	|	Количество,
//	|	ДоходРес,
//	|	ДоходРесБезНДС,
//	|	СуммаКомиссии,
//	|	КомиссияБезНДС,
//	|	СуммаСкидки,
//	|	СуммаСкидкиБезНДС,
//	|	ПроданоЧасовРесурса,
//	|	DaysRented,
//	|	WorkingHours,
//	|	WorkingDays,
//	|	RevenuePlanned,
//	|	WorkingHoursPercent,
//	|	WorkingDaysPercent,
//	|	RevenuePercent}
//	|FROM
//	|	(SELECT
//	|		ОборотПродажРесурсов.Валюта AS Валюта,
//	|		ОборотПродажРесурсов.Гостиница AS Гостиница,
//	|		ОборотПродажРесурсов.Ресурс AS Ресурс,
//	|		ОборотПродажРесурсов.SalesTurnover AS SumTurnover,
//	|		ОборотПродажРесурсов.SalesWithoutVATTurnover AS SumWithoutVATTurnover,
//	|		ОборотПродажРесурсов.QuantityTurnover AS QuantityTurnover,
//	|		ОборотПродажРесурсов.ResourceRevenueTurnover AS ResourceRevenueTurnover,
//	|		ОборотПродажРесурсов.ResourceRevenueWithoutVATTurnover AS ResourceRevenueWithoutVATTurnover,
//	|		ОборотПродажРесурсов.CommissionSumTurnover AS CommissionSumTurnover,
//	|		ОборотПродажРесурсов.CommissionSumWithoutVATTurnover AS CommissionSumWithoutVATTurnover,
//	|		ОборотПродажРесурсов.DiscountSumTurnover AS DiscountSumTurnover,
//	|		ОборотПродажРесурсов.DiscountSumWithoutVATTurnover AS DiscountSumWithoutVATTurnover,
//	|		ОборотПродажРесурсов.HoursRentedTurnover AS HoursRentedTurnover
//	|	FROM
//	|		AccumulationRegister.Продажи.Turnovers(
//	|				&qPeriodFrom,
//	|				&qPeriodTo,
//	|				Period,
//	|				Гостиница IN HIERARCHY (&qHotel)
//	|					AND (Ресурс IN HIERARCHY (&qResource)
//	|						OR &qIsEmptyResource)
//	|					AND (ТипРесурса IN HIERARCHY (&qResourceType)
//	|						OR &qIsEmptyResourceType)
//	|					AND ТипРесурса <> &qEmptyResourceType
//	|					AND (Услуга IN HIERARCHY (&qService)
//	|						OR &qIsEmptyService)
//	|					AND (Услуга IN HIERARCHY (&qServicesList)
//	|						OR (NOT &qUseServicesList))) AS ОборотПродажРесурсов
//	|	
//	|	UNION ALL
//	|	
//	|	SELECT
//	|		ResourceSalesForecastTurnovers.Валюта,
//	|		ResourceSalesForecastTurnovers.Гостиница,
//	|		ResourceSalesForecastTurnovers.Ресурс,
//	|		ResourceSalesForecastTurnovers.SalesTurnover,
//	|		ResourceSalesForecastTurnovers.SalesWithoutVATTurnover,
//	|		ResourceSalesForecastTurnovers.QuantityTurnover,
//	|		ResourceSalesForecastTurnovers.ResourceRevenueTurnover,
//	|		ResourceSalesForecastTurnovers.ResourceRevenueWithoutVATTurnover,
//	|		ResourceSalesForecastTurnovers.CommissionSumTurnover,
//	|		ResourceSalesForecastTurnovers.CommissionSumWithoutVATTurnover,
//	|		ResourceSalesForecastTurnovers.DiscountSumTurnover,
//	|		ResourceSalesForecastTurnovers.DiscountSumWithoutVATTurnover,
//	|		ResourceSalesForecastTurnovers.HoursRentedTurnover
//	|	FROM
//	|		AccumulationRegister.ПрогнозПродаж.Turnovers(
//	|				&qForecastPeriodFrom,
//	|				&qForecastPeriodTo,
//	|				Period,
//	|				Гостиница IN HIERARCHY (&qHotel)
//	|					AND (Ресурс IN HIERARCHY (&qResource)
//	|						OR &qIsEmptyResource)
//	|					AND (ТипРесурса IN HIERARCHY (&qResourceType)
//	|						OR &qIsEmptyResourceType)
//	|					AND ТипРесурса <> &qEmptyResourceType
//	|					AND (Услуга IN HIERARCHY (&qService)
//	|						OR &qIsEmptyService)
//	|					AND (Услуга IN HIERARCHY (&qServicesList)
//	|						OR (NOT &qUseServicesList))) AS ResourceSalesForecastTurnovers) AS ResourceSales
//	|{WHERE
//	|	ResourceSales.Валюта.*,
//	|	ResourceSales.Гостиница.*,
//	|	ResourceSales.Ресурс.* AS Ресурс,
//	|	(SUM(ResourceSales.SumTurnover)) AS Сумма,
//	|	(SUM(ResourceSales.SumWithoutVATTurnover)) AS SumWithoutVAT,
//	|	(SUM(ResourceSales.QuantityTurnover)) AS Количество,
//	|	(SUM(ResourceSales.ResourceRevenueTurnover)) AS ДоходРес,
//	|	(SUM(ResourceSales.ResourceRevenueWithoutVATTurnover)) AS ДоходРесБезНДС,
//	|	(SUM(ResourceSales.CommissionSumTurnover)) AS СуммаКомиссии,
//	|	(SUM(ResourceSales.CommissionSumWithoutVATTurnover)) AS КомиссияБезНДС,
//	|	(SUM(ResourceSales.DiscountSumTurnover)) AS СуммаСкидки,
//	|	(SUM(ResourceSales.DiscountSumWithoutVATTurnover)) AS СуммаСкидкиБезНДС,
//	|	(SUM(ResourceSales.HoursRentedTurnover)) AS ПроданоЧасовРесурса,
//	|	(0) AS DaysRented,
//	|	(0) AS WorkingHours,
//	|	(0) AS WorkingDays,
//	|	(0) AS RevenuePlanned,
//	|	(0) AS WorkingHoursPercent,
//	|	(0) AS WorkingDaysPercent,
//	|	(0) AS RevenuePercent}
//	|
//	|GROUP BY
//	|	ResourceSales.Валюта,
//	|	ResourceSales.Гостиница,
//	|	ResourceSales.Ресурс
//	|
//	|ORDER BY
//	|	ResourceSales.Валюта.ПорядокСортировки,
//	|	ResourceSales.Гостиница.ПорядокСортировки,
//	|	ResourceSales.Ресурс.ПорядокСортировки
//	|{ORDER BY
//	|	Валюта.*,
//	|	Гостиница.*,
//	|	Ресурс.*,
//	|	Сумма,
//	|	SumWithoutVAT,
//	|	Количество,
//	|	ДоходРес,
//	|	ДоходРесБезНДС,
//	|	СуммаКомиссии,
//	|	КомиссияБезНДС,
//	|	СуммаСкидки,
//	|	СуммаСкидкиБезНДС,
//	|	ПроданоЧасовРесурса,
//	|	DaysRented,
//	|	WorkingHours,
//	|	WorkingDays,
//	|	RevenuePlanned,
//	|	WorkingHoursPercent,
//	|	WorkingDaysPercent,
//	|	RevenuePercent}
//	|TOTALS
//	|	SUM(Сумма),
//	|	SUM(SumWithoutVAT),
//	|	SUM(Количество),
//	|	SUM(ДоходРес),
//	|	SUM(ДоходРесБезНДС),
//	|	SUM(СуммаКомиссии),
//	|	SUM(КомиссияБезНДС),
//	|	SUM(СуммаСкидки),
//	|	SUM(СуммаСкидкиБезНДС),
//	|	SUM(ПроданоЧасовРесурса)
//	|BY
//	|	OVERALL";
//	ReportBuilder.Text = QueryText;
//	ReportBuilder.FillSettings();
//	
//	// Initialize report builder with default query
//	vRB = New ReportBuilder(QueryText);
//	vRBSettings = vRB.GetSettings(True, True, True, True, True);
//	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
//	
//	// Set default report builder header text
//	ReportBuilder.HeaderText = NStr("EN='Resource sales percents';RU='Проценты продаж по ресурсам';de='Prozente aus Verkäufen nach Ressourcen'");
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
//	   Or pName = "Количество" 
//	   Or pName = "ДоходРес" 
//	   Or pName = "ДоходРесБезНДС" 
//	   Or pName = "СуммаКомиссии" 
//	   Or pName = "КомиссияБезНДС" 
//	   Or pName = "СуммаСкидки" 
//	   Or pName = "СуммаСкидкиБезНДС" 
//	   Or pName = "ПроданоЧасовРесурса" 
//	   Or pName = "DaysRented"
//	   Or pName = "WorkingHours"
//	   Or pName = "WorkingDays"
//	   Or pName = "RevenuePlanned"
//	   Or pName = "WorkingHoursPercent"
//	   Or pName = "WorkingDaysPercent"
//	   Or pName = "RevenuePercent" Тогда
//		Return True;
//	Else
//		Return False;
//	EndIf;
//EndFunction //pmIsResource
//
////-----------------------------------------------------------------------------
//// Reports framework end
////-----------------------------------------------------------------------------
