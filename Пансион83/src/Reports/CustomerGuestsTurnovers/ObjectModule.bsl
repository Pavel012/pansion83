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
//	ReportBuilder.Parameters.Вставить("qForecastPeriodFrom", Max(BegOfDay(PeriodFrom), BegOfDay(CurrentDate())));
//	ReportBuilder.Parameters.Вставить("qForecastPeriodTo", ?(ЗначениеЗаполнено(PeriodTo), Max(PeriodTo, EndOfDay(CurrentDate()-24*3600)), '00010101'));
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
//	|	CustomerTotals.Гостиница AS Гостиница,
//	|	SUM(CustomerTotals.TotalSales) AS TotalSales,
//	|	SUM(CustomerTotals.TotalRoomsRented) AS TotalRoomsRented,
//	|	SUM(CustomerTotals.TotalBedsRented) AS TotalBedsRented,
//	|	SUM(CustomerTotals.TotalRoomRevenue) AS TotalRoomRevenue
//	|INTO CustomerTotals
//	|FROM
//	|	(SELECT
//	|		SalesTurnovers.Гостиница AS Гостиница,
//	|		SalesTurnovers.SalesTurnover AS TotalSales,
//	|		SalesTurnovers.RoomsRentedTurnover AS TotalRoomsRented,
//	|		SalesTurnovers.BedsRentedTurnover AS TotalBedsRented,
//	|		SalesTurnovers.RoomRevenueTurnover AS TotalRoomRevenue
//	|	FROM
//	|		AccumulationRegister.Продажи.Turnovers(
//	|				&qPeriodFrom,
//	|				&qPeriodTo,
//	|				Period,
//	|				Гостиница IN HIERARCHY (&qHotel)
//	|					AND (Услуга IN HIERARCHY (&qServicesList)
//	|						OR NOT &qUseServicesList)) AS SalesTurnovers
//	|	
//	|	UNION ALL
//	|	
//	|	SELECT
//	|		SalesForecastTurnovers.Гостиница,
//	|		SalesForecastTurnovers.SalesTurnover,
//	|		SalesForecastTurnovers.RoomsRentedTurnover,
//	|		SalesForecastTurnovers.BedsRentedTurnover,
//	|		SalesForecastTurnovers.RoomRevenueTurnover
//	|	FROM
//	|		AccumulationRegister.ПрогнозПродаж.Turnovers(
//	|				&qForecastPeriodFrom,
//	|				&qForecastPeriodTo,
//	|				Period,
//	|				Гостиница IN HIERARCHY (&qHotel)
//	|					AND (Услуга IN HIERARCHY (&qServicesList)
//	|						OR NOT &qUseServicesList)) AS SalesForecastTurnovers) AS CustomerTotals
//	|
//	|GROUP BY
//	|	CustomerTotals.Гостиница
//	|;
//	|
//	|////////////////////////////////////////////////////////////////////////////////
//	|SELECT
//	|	CustomerSales.Гостиница AS Гостиница,
//	|	CustomerSales.Фирма AS Фирма,
//	|	CustomerSales.Валюта AS Валюта,
//	|	CustomerSales.Агент AS Агент,
//	|	CustomerSales.Контрагент AS Контрагент,
//	|	CustomerSales.Договор AS Договор,
//	|	CustomerSales.ГруппаГостей AS ГруппаГостей,
//	|	CustomerSales.Тариф AS Тариф,
//	|	CustomerSales.УчетнаяДата AS УчетнаяДата,
//	|	CustomerSales.ДокОснование,
//	|	CustomerSales.Услуга AS Услуга,
//	|	CustomerSales.ClientLastCheckInDate AS ClientLastCheckInDate,
//	|	CustomerSales.ClientFirstCheckInDate AS ClientFirstCheckInDate,
//	|	CustomerSales.CustomerLastCheckInDate AS CustomerLastCheckInDate,
//	|	CustomerSales.CustomerFirstCheckInDate AS CustomerFirstCheckInDate,
//	|	CustomerSales.Продажи AS Продажи,
//	|	CustomerSales.ДоходНомеров AS ДоходНомеров,
//	|	CustomerSales.ДоходДопМеста AS ДоходДопМеста,
//	|	CustomerSales.ДоходНомеров - CustomerSales.ДоходДопМеста AS MainBedsRevenue,
//	|	CustomerSales.ПродажиБезНДС AS ПродажиБезНДС,
//	|	CustomerSales.ДоходПродажиБезНДС AS ДоходПродажиБезНДС,
//	|	CustomerSales.ДоходДопМестаБезНДС AS ДоходДопМестаБезНДС,
//	|	CustomerSales.ДоходПродажиБезНДС - CustomerSales.ДоходДопМестаБезНДС AS MainBedsRevenueWithoutVAT,
//	|	CustomerSales.СуммаКомиссии AS СуммаКомиссии,
//	|	CustomerSales.КомиссияБезНДС AS КомиссияБезНДС,
//	|	CustomerSales.СуммаСкидки AS СуммаСкидки,
//	|	CustomerSales.СуммаСкидкиБезНДС AS СуммаСкидкиБезНДС,
//	|	CustomerSales.ПроданоНомеров AS ПроданоНомеров,
//	|	CustomerSales.ПроданоМест AS ПроданоМест,
//	|	CustomerSales.ПроданоДопМест AS ПроданоДопМест,
//	|	CustomerSales.ЧеловекаДни AS ЧеловекаДни,
//	|	CustomerSales.ЗаездГостей AS ЗаездГостей,
//	|	CustomerSales.ЗаездНомеров AS ЗаездНомеров,
//	|	CustomerSales.ЗаездМест AS ЗаездМест,
//	|	CustomerSales.ЗаездДополнительныхМест AS ЗаездДополнительныхМест,
//	|	CustomerSales.Количество AS Количество,
//	|	CustomerSales.TotalSales AS TotalSales,
//	|	CustomerSales.TotalRoomRevenue AS TotalRoomRevenue,
//	|	CustomerSales.TotalRoomsRented AS TotalRoomsRented,
//	|	CustomerSales.TotalBedsRented AS TotalBedsRented,
//	|	CustomerSales.TotalSalesPercent AS TotalSalesPercent,
//	|	CustomerSales.TotalRoomRevenuePercent AS TotalRoomRevenuePercent,
//	|	CustomerSales.TotalRoomsRentedPercent AS TotalRoomsRentedPercent,
//	|	CustomerSales.TotalBedsRentedPercent AS TotalBedsRentedPercent,
//	|	CustomerSales.ADR AS ADR,
//	|	CustomerSales.ADBR AS ADBR,
//	|	CustomerSales.ADRWithoutVAT AS ADRWithoutVAT,
//	|	CustomerSales.ADBRWithoutVAT AS ADBRWithoutVAT,
//	|	CustomerSales.RevPAC AS RevPAC,
//	|	CustomerSales.RevPACWithoutVAT AS RevPACWithoutVAT,
//	|	CustomerSales.ALS AS ALS
//	|{SELECT
//	|	Гостиница.*,
//	|	Фирма.*,
//	|	Валюта.*,
//	|	Агент.*,
//	|	Контрагент.*,
//	|	Договор.*,
//	|	ГруппаГостей.*,
//	|	CustomerSales.Клиент.*,
//	|	Тариф.*,
//	|	Услуга.*,
//	|	ДокОснование.*,
//	|	CustomerSales.СпособОплаты.*,
//	|	CustomerSales.ТипКлиента.*,
//	|	CustomerSales.СчетПроживания.*,
//	|	CustomerSales.НомерРазмещения.*,
//	|	CustomerSales.ТипНомера.*,
//	|	CustomerSales.ВидРазмещения.*,
//	|	CustomerSales.TripPurpose.*,
//	|	CustomerSales.МаретингНапрвл.*,
//	|	CustomerSales.ИсточИнфоГостиница.*,
//	|	CustomerSales.Ресурс.*,
//	|	CustomerSales.ТипРесурса.*,
//	|	CustomerSales.Автор.*,
//	|	CustomerSales.Скидка,
//	|	CustomerSales.ТипСкидки.*,
//	|	CustomerSales.ДисконтКарт.*,
//	|	CustomerSales.ВидКомиссииАгента,
//	|	CustomerSales.КомиссияАгента,
//	|	CustomerSales.СтавкаНДС.*,
//	|	CustomerSales.Цена AS Цена,
//	|	CustomerSales.ПутевкаКурсовка.* AS ПутевкаКурсовка,
//	|	Продажи,
//	|	ДоходНомеров,
//	|	ДоходДопМеста,
//	|	MainBedsRevenue,
//	|	ПродажиБезНДС,
//	|	ДоходПродажиБезНДС,
//	|	ДоходДопМестаБезНДС,
//	|	MainBedsRevenueWithoutVAT,
//	|	СуммаКомиссии,
//	|	КомиссияБезНДС,
//	|	СуммаСкидки,
//	|	СуммаСкидкиБезНДС,
//	|	ПроданоНомеров,
//	|	ПроданоМест,
//	|	ПроданоДопМест,
//	|	ЧеловекаДни,
//	|	ЗаездГостей,
//	|	ЗаездНомеров,
//	|	ЗаездМест,
//	|	ЗаездДополнительныхМест,
//	|	Количество,
//	|	ClientLastCheckInDate,
//	|	ClientFirstCheckInDate,
//	|	CustomerLastCheckInDate,
//	|	CustomerFirstCheckInDate,
//	|	УчетнаяДата,
//	|	(WEEK(CustomerSales.УчетнаяДата)) AS AccountingWeek,
//	|	(MONTH(CustomerSales.УчетнаяДата)) AS AccountingMonth,
//	|	(QUARTER(CustomerSales.УчетнаяДата)) AS AccountingQuarter,
//	|	(YEAR(CustomerSales.УчетнаяДата)) AS AccountingYear,
//	|	TotalSales,
//	|	TotalRoomRevenue,
//	|	TotalRoomsRented,
//	|	TotalBedsRented,
//	|	TotalSalesPercent,
//	|	TotalRoomRevenuePercent,
//	|	TotalRoomsRentedPercent,
//	|	TotalBedsRentedPercent,
//	|	ADR,
//	|	ADBR,
//	|	ADRWithoutVAT,
//	|	ADBRWithoutVAT,
//	|	RevPAC,
//	|	RevPACWithoutVAT,
//	|	ALS}
//	|FROM
//	|	(SELECT
//	|		CustomerSalesTurnovers.Гостиница AS Гостиница,
//	|		CustomerSalesTurnovers.Фирма AS Фирма,
//	|		CustomerSalesTurnovers.Валюта AS Валюта,
//	|		CustomerSalesTurnovers.Агент AS Агент,
//	|		CustomerSalesTurnovers.Контрагент AS Контрагент,
//	|		CustomerSalesTurnovers.Договор AS Договор,
//	|		CustomerSalesTurnovers.ГруппаГостей AS ГруппаГостей,
//	|		CustomerSalesTurnovers.УчетнаяДата AS УчетнаяДата,
//	|		CustomerSalesTurnovers.Клиент AS Клиент,
//	|		CustomerSalesTurnovers.ДокОснование AS ДокОснование,
//	|		CustomerSalesTurnovers.Услуга AS Услуга,
//	|		CustomerSalesTurnovers.СпособОплаты AS СпособОплаты,
//	|		CustomerSalesTurnovers.ТипКлиента AS ТипКлиента,
//	|		CustomerSalesTurnovers.СчетПроживания AS СчетПроживания,
//	|		CustomerSalesTurnovers.Тариф AS Тариф,
//	|		CustomerSalesTurnovers.НомерРазмещения AS НомерРазмещения,
//	|		CustomerSalesTurnovers.ТипНомера AS ТипНомера,
//	|		CustomerSalesTurnovers.ВидРазмещения AS ВидРазмещения,
//	|		CustomerSalesTurnovers.TripPurpose AS TripPurpose,
//	|		CustomerSalesTurnovers.МаретингНапрвл AS МаретингНапрвл,
//	|		CustomerSalesTurnovers.ИсточИнфоГостиница AS ИсточИнфоГостиница,
//	|		CustomerSalesTurnovers.Ресурс AS Ресурс,
//	|		CustomerSalesTurnovers.ТипРесурса AS ТипРесурса,
//	|		CustomerSalesTurnovers.Автор AS Автор,
//	|		CustomerSalesTurnovers.Скидка AS Скидка,
//	|		CustomerSalesTurnovers.ТипСкидки AS ТипСкидки,
//	|		CustomerSalesTurnovers.ДисконтКарт AS ДисконтКарт,
//	|		CustomerSalesTurnovers.ВидКомиссииАгента AS ВидКомиссииАгента,
//	|		CustomerSalesTurnovers.КомиссияАгента AS КомиссияАгента,
//	|		CustomerSalesTurnovers.СтавкаНДС AS СтавкаНДС,
//	|		CustomerSalesTurnovers.Цена AS Цена,
//	|		CustomerSalesTurnovers.ПутевкаКурсовка AS ПутевкаКурсовка,
//	|		CustomerSalesTurnovers.SalesTurnover AS Продажи,
//	|		CustomerSalesTurnovers.RoomRevenueTurnover AS ДоходНомеров,
//	|		CustomerSalesTurnovers.ExtraBedRevenueTurnover AS ДоходДопМеста,
//	|		CustomerSalesTurnovers.SalesWithoutVATTurnover AS ПродажиБезНДС,
//	|		CustomerSalesTurnovers.RoomRevenueWithoutVATTurnover AS ДоходПродажиБезНДС,
//	|		CustomerSalesTurnovers.ExtraBedRevenueWithoutVATTurnover AS ДоходДопМестаБезНДС,
//	|		CustomerSalesTurnovers.CommissionSumTurnover AS СуммаКомиссии,
//	|		CustomerSalesTurnovers.CommissionSumWithoutVATTurnover AS КомиссияБезНДС,
//	|		CustomerSalesTurnovers.DiscountSumTurnover AS СуммаСкидки,
//	|		CustomerSalesTurnovers.DiscountSumWithoutVATTurnover AS СуммаСкидкиБезНДС,
//	|		CustomerSalesTurnovers.RoomsRentedTurnover AS ПроданоНомеров,
//	|		CustomerSalesTurnovers.BedsRentedTurnover AS ПроданоМест,
//	|		CustomerSalesTurnovers.AdditionalBedsRentedTurnover AS ПроданоДопМест,
//	|		CustomerSalesTurnovers.GuestDaysTurnover AS ЧеловекаДни,
//	|		CustomerSalesTurnovers.GuestsCheckedInTurnover AS ЗаездГостей,
//	|		CustomerSalesTurnovers.RoomsCheckedInTurnover AS ЗаездНомеров,
//	|		CustomerSalesTurnovers.BedsCheckedInTurnover AS ЗаездМест,
//	|		CustomerSalesTurnovers.AdditionalBedsCheckedInTurnover AS ЗаездДополнительныхМест,
//	|		CustomerSalesTurnovers.QuantityTurnover AS Количество,
//	|		ClientCheckInStatistics.LastCheckInDate AS ClientLastCheckInDate,
//	|		ClientCheckInStatistics.FirstCheckInDate AS ClientFirstCheckInDate,
//	|		CustomerCheckInStatistics.LastCheckInDate AS CustomerLastCheckInDate,
//	|		CustomerCheckInStatistics.FirstCheckInDate AS CustomerFirstCheckInDate,
//	|		CustomerTotalSales.TotalSales AS TotalSales,
//	|		CustomerTotalSales.TotalRoomRevenue AS TotalRoomRevenue,
//	|		CustomerTotalSales.TotalRoomsRented AS TotalRoomsRented,
//	|		CustomerTotalSales.TotalBedsRented AS TotalBedsRented,
//	|		CASE
//	|			WHEN CustomerTotalSales.TotalSales = 0
//	|				THEN 0
//	|			ELSE CustomerSalesTurnovers.SalesTurnover * 100 / CustomerTotalSales.TotalSales
//	|		END AS TotalSalesPercent,
//	|		CASE
//	|			WHEN CustomerTotalSales.TotalRoomRevenue = 0
//	|				THEN 0
//	|			ELSE CustomerSalesTurnovers.RoomRevenueTurnover * 100 / CustomerTotalSales.TotalRoomRevenue
//	|		END AS TotalRoomRevenuePercent,
//	|		CASE
//	|			WHEN CustomerTotalSales.TotalRoomsRented = 0
//	|				THEN 0
//	|			ELSE CustomerSalesTurnovers.RoomsRentedTurnover * 100 / CustomerTotalSales.TotalRoomsRented
//	|		END AS TotalRoomsRentedPercent,
//	|		CASE
//	|			WHEN CustomerTotalSales.TotalBedsRented = 0
//	|				THEN 0
//	|			ELSE CustomerSalesTurnovers.BedsRentedTurnover * 100 / CustomerTotalSales.TotalBedsRented
//	|		END AS TotalBedsRentedPercent,
//	|		CASE
//	|			WHEN CustomerSalesTurnovers.RoomsRentedTurnover = 0
//	|				THEN 0
//	|			ELSE CustomerSalesTurnovers.RoomRevenueTurnover / CustomerSalesTurnovers.RoomsRentedTurnover
//	|		END AS ADR,
//	|		CASE
//	|			WHEN CustomerSalesTurnovers.BedsRentedTurnover = 0
//	|				THEN 0
//	|			ELSE CustomerSalesTurnovers.RoomRevenueTurnover / CustomerSalesTurnovers.BedsRentedTurnover
//	|		END AS ADBR,
//	|		CASE
//	|			WHEN CustomerSalesTurnovers.RoomsRentedTurnover = 0
//	|				THEN 0
//	|			ELSE CustomerSalesTurnovers.RoomRevenueWithoutVATTurnover / CustomerSalesTurnovers.RoomsRentedTurnover
//	|		END AS ADRWithoutVAT,
//	|		CASE
//	|			WHEN CustomerSalesTurnovers.BedsRentedTurnover = 0
//	|				THEN 0
//	|			ELSE CustomerSalesTurnovers.RoomRevenueWithoutVATTurnover / CustomerSalesTurnovers.BedsRentedTurnover
//	|		END AS ADBRWithoutVAT,
//	|		CASE
//	|			WHEN CustomerSalesTurnovers.GuestDaysTurnover = 0
//	|				THEN 0
//	|			ELSE CustomerSalesTurnovers.RoomRevenueTurnover / CustomerSalesTurnovers.GuestDaysTurnover
//	|		END AS RevPAC,
//	|		CASE
//	|			WHEN CustomerSalesTurnovers.GuestDaysTurnover = 0
//	|				THEN 0
//	|			ELSE CustomerSalesTurnovers.RoomRevenueWithoutVATTurnover / CustomerSalesTurnovers.GuestDaysTurnover
//	|		END AS RevPACWithoutVAT,
//	|		CASE
//	|			WHEN CustomerSalesTurnovers.GuestsCheckedInTurnover = 0
//	|				THEN 0
//	|			ELSE CustomerSalesTurnovers.GuestDaysTurnover / CustomerSalesTurnovers.GuestsCheckedInTurnover
//	|		END AS ALS
//	|	FROM
//	|		(SELECT
//	|			SalesTurnovers.Гостиница AS Гостиница,
//	|			SalesTurnovers.Фирма AS Фирма,
//	|			SalesTurnovers.Валюта AS Валюта,
//	|			SalesTurnovers.Агент AS Агент,
//	|			SalesTurnovers.ДокОснование.Контрагент AS Контрагент,
//	|			SalesTurnovers.ДокОснование.Договор AS Договор,
//	|			SalesTurnovers.ГруппаГостей AS ГруппаГостей,
//	|			SalesTurnovers.УчетнаяДата AS УчетнаяДата,
//	|			SalesTurnovers.Клиент AS Клиент,
//	|			SalesTurnovers.ДокОснование AS ДокОснование,
//	|			SalesTurnovers.Услуга AS Услуга,
//	|			SalesTurnovers.СпособОплаты AS СпособОплаты,
//	|			SalesTurnovers.ТипКлиента AS ТипКлиента,
//	|			SalesTurnovers.СчетПроживания AS СчетПроживания,
//	|			SalesTurnovers.Тариф AS Тариф,
//	|			SalesTurnovers.НомерРазмещения AS НомерРазмещения,
//	|			SalesTurnovers.ТипНомера AS ТипНомера,
//	|			SalesTurnovers.ВидРазмещения AS ВидРазмещения,
//	|			SalesTurnovers.TripPurpose AS TripPurpose,
//	|			SalesTurnovers.МаретингНапрвл AS МаретингНапрвл,
//	|			SalesTurnovers.ИсточИнфоГостиница AS ИсточИнфоГостиница,
//	|			SalesTurnovers.Ресурс AS Ресурс,
//	|			SalesTurnovers.ТипРесурса AS ТипРесурса,
//	|			SalesTurnovers.Автор AS Автор,
//	|			SalesTurnovers.Скидка AS Скидка,
//	|			SalesTurnovers.ТипСкидки AS ТипСкидки,
//	|			SalesTurnovers.ДисконтКарт AS ДисконтКарт,
//	|			SalesTurnovers.ВидКомиссииАгента AS ВидКомиссииАгента,
//	|			SalesTurnovers.КомиссияАгента AS КомиссияАгента,
//	|			SalesTurnovers.СтавкаНДС AS СтавкаНДС,
//	|			SalesTurnovers.Цена AS Цена,
//	|			SalesTurnovers.ПутевкаКурсовка AS ПутевкаКурсовка,
//	|			SalesTurnovers.SalesTurnover AS SalesTurnover,
//	|			SalesTurnovers.RoomRevenueTurnover AS RoomRevenueTurnover,
//	|			SalesTurnovers.ExtraBedRevenueTurnover AS ExtraBedRevenueTurnover,
//	|			SalesTurnovers.SalesWithoutVATTurnover AS SalesWithoutVATTurnover,
//	|			SalesTurnovers.RoomRevenueWithoutVATTurnover AS RoomRevenueWithoutVATTurnover,
//	|			SalesTurnovers.ExtraBedRevenueWithoutVATTurnover AS ExtraBedRevenueWithoutVATTurnover,
//	|			SalesTurnovers.CommissionSumTurnover AS CommissionSumTurnover,
//	|			SalesTurnovers.CommissionSumWithoutVATTurnover AS CommissionSumWithoutVATTurnover,
//	|			SalesTurnovers.DiscountSumTurnover AS DiscountSumTurnover,
//	|			SalesTurnovers.DiscountSumWithoutVATTurnover AS DiscountSumWithoutVATTurnover,
//	|			SalesTurnovers.RoomsRentedTurnover AS RoomsRentedTurnover,
//	|			SalesTurnovers.BedsRentedTurnover AS BedsRentedTurnover,
//	|			SalesTurnovers.AdditionalBedsRentedTurnover AS AdditionalBedsRentedTurnover,
//	|			SalesTurnovers.GuestDaysTurnover AS GuestDaysTurnover,
//	|			SalesTurnovers.GuestsCheckedInTurnover AS GuestsCheckedInTurnover,
//	|			SalesTurnovers.RoomsCheckedInTurnover AS RoomsCheckedInTurnover,
//	|			SalesTurnovers.BedsCheckedInTurnover AS BedsCheckedInTurnover,
//	|			SalesTurnovers.AdditionalBedsCheckedInTurnover AS AdditionalBedsCheckedInTurnover,
//	|			SalesTurnovers.QuantityTurnover AS QuantityTurnover
//	|		FROM
//	|			AccumulationRegister.Продажи.Turnovers(
//	|					&qPeriodFrom,
//	|					&qPeriodTo,
//	|					Day,
//	|					Гостиница IN HIERARCHY (&qHotel)
//	|						AND (ДокОснование.Контрагент IN HIERARCHY (&qCustomer)
//	|							OR &qIsEmptyCustomer)
//	|						AND (ДокОснование.Договор = &qContract
//	|							OR &qIsEmptyContract)
//	|						AND (ГруппаГостей = &qGuestGroup
//	|							OR &qIsEmptyGuestGroup)
//	|						AND (Услуга IN HIERARCHY (&qServicesList)
//	|							OR NOT &qUseServicesList)) AS SalesTurnovers
//	|		
//	|		UNION ALL
//	|		
//	|		SELECT
//	|			SalesForecastTurnovers.Гостиница,
//	|			SalesForecastTurnovers.Фирма,
//	|			SalesForecastTurnovers.Валюта,
//	|			SalesForecastTurnovers.Агент,
//	|			SalesForecastTurnovers.ДокОснование.Контрагент,
//	|			SalesForecastTurnovers.ДокОснование.Договор,
//	|			SalesForecastTurnovers.ГруппаГостей,
//	|			SalesForecastTurnovers.УчетнаяДата,
//	|			SalesForecastTurnovers.Клиент,
//	|			SalesForecastTurnovers.ДокОснование,
//	|			SalesForecastTurnovers.Услуга,
//	|			SalesForecastTurnovers.СпособОплаты,
//	|			SalesForecastTurnovers.ТипКлиента,
//	|			SalesForecastTurnovers.СчетПроживания,
//	|			SalesForecastTurnovers.Тариф,
//	|			SalesForecastTurnovers.НомерРазмещения,
//	|			SalesForecastTurnovers.ТипНомера,
//	|			SalesForecastTurnovers.ВидРазмещения,
//	|			SalesForecastTurnovers.TripPurpose,
//	|			SalesForecastTurnovers.МаретингНапрвл,
//	|			SalesForecastTurnovers.ИсточИнфоГостиница,
//	|			SalesForecastTurnovers.Ресурс,
//	|			SalesForecastTurnovers.ТипРесурса,
//	|			SalesForecastTurnovers.Автор,
//	|			SalesForecastTurnovers.Скидка,
//	|			SalesForecastTurnovers.ТипСкидки,
//	|			SalesForecastTurnovers.ДисконтКарт,
//	|			SalesForecastTurnovers.ВидКомиссииАгента,
//	|			SalesForecastTurnovers.КомиссияАгента,
//	|			SalesForecastTurnovers.СтавкаНДС,
//	|			SalesForecastTurnovers.Цена,
//	|			SalesForecastTurnovers.ПутевкаКурсовка,
//	|			SalesForecastTurnovers.SalesTurnover,
//	|			SalesForecastTurnovers.RoomRevenueTurnover,
//	|			SalesForecastTurnovers.ExtraBedRevenueTurnover,
//	|			SalesForecastTurnovers.SalesWithoutVATTurnover,
//	|			SalesForecastTurnovers.RoomRevenueWithoutVATTurnover,
//	|			SalesForecastTurnovers.ExtraBedRevenueWithoutVATTurnover,
//	|			SalesForecastTurnovers.CommissionSumTurnover,
//	|			SalesForecastTurnovers.CommissionSumWithoutVATTurnover,
//	|			SalesForecastTurnovers.DiscountSumTurnover,
//	|			SalesForecastTurnovers.DiscountSumWithoutVATTurnover,
//	|			SalesForecastTurnovers.RoomsRentedTurnover,
//	|			SalesForecastTurnovers.BedsRentedTurnover,
//	|			SalesForecastTurnovers.AdditionalBedsRentedTurnover,
//	|			SalesForecastTurnovers.GuestDaysTurnover,
//	|			SalesForecastTurnovers.GuestsCheckedInTurnover,
//	|			SalesForecastTurnovers.RoomsCheckedInTurnover,
//	|			SalesForecastTurnovers.BedsCheckedInTurnover,
//	|			SalesForecastTurnovers.AdditionalBedsCheckedInTurnover,
//	|			SalesForecastTurnovers.QuantityTurnover
//	|		FROM
//	|			AccumulationRegister.ПрогнозПродаж.Turnovers(
//	|					&qForecastPeriodFrom,
//	|					&qForecastPeriodTo,
//	|					Day,
//	|					Гостиница IN HIERARCHY (&qHotel)
//	|						AND (ДокОснование.Контрагент IN HIERARCHY (&qCustomer)
//	|							OR &qIsEmptyCustomer)
//	|						AND (ДокОснование.Договор = &qContract
//	|							OR &qIsEmptyContract)
//	|						AND (ГруппаГостей = &qGuestGroup
//	|							OR &qIsEmptyGuestGroup)
//	|						AND (Услуга IN HIERARCHY (&qServicesList)
//	|							OR NOT &qUseServicesList)) AS SalesForecastTurnovers) AS CustomerSalesTurnovers
//	|			LEFT JOIN (SELECT
//	|				ЗагрузкаНомеров.Клиент AS Клиент,
//	|				MAX(ЗагрузкаНомеров.CheckInDate) AS LastCheckInDate,
//	|				MIN(ЗагрузкаНомеров.CheckInDate) AS FirstCheckInDate
//	|			FROM
//	|				AccumulationRegister.ЗагрузкаНомеров AS ЗагрузкаНомеров
//	|			WHERE
//	|				ЗагрузкаНомеров.IsAccommodation
//	|				AND ЗагрузкаНомеров.ЭтоЗаезд
//	|			
//	|			GROUP BY
//	|				ЗагрузкаНомеров.Клиент) AS ClientCheckInStatistics
//	|			ON CustomerSalesTurnovers.Клиент = ClientCheckInStatistics.Клиент
//	|			LEFT JOIN (SELECT
//	|				ЗагрузкаНомеров.Контрагент AS Контрагент,
//	|				MAX(ЗагрузкаНомеров.CheckInDate) AS LastCheckInDate,
//	|				MIN(ЗагрузкаНомеров.CheckInDate) AS FirstCheckInDate
//	|			FROM
//	|				AccumulationRegister.ЗагрузкаНомеров AS RoomInventory
//	|			WHERE
//	|				ЗагрузкаНомеров.IsAccommodation
//	|				AND ЗагрузкаНомеров.ЭтоЗаезд
//	|			
//	|			GROUP BY
//	|				ЗагрузкаНомеров.Контрагент) AS CustomerCheckInStatistics
//	|			ON CustomerSalesTurnovers.Контрагент = CustomerCheckInStatistics.Контрагент
//	|			LEFT JOIN (SELECT
//	|				CustomerTotals.Гостиница AS Гостиница,
//	|				CustomerTotals.TotalRoomRevenue AS TotalRoomRevenue,
//	|				CustomerTotals.TotalRoomsRented AS TotalRoomsRented,
//	|				CustomerTotals.TotalBedsRented AS TotalBedsRented,
//	|				CustomerTotals.TotalSales AS TotalSales
//	|			FROM
//	|				CustomerTotals AS CustomerTotals) AS CustomerTotalSales
//	|			ON CustomerSalesTurnovers.Гостиница = CustomerTotalSales.Гостиница) AS CustomerSales
//	|{WHERE
//	|	CustomerSales.Гостиница.*,
//	|	CustomerSales.Фирма.*,
//	|	CustomerSales.Валюта.*,
//	|	CustomerSales.Агент.*,
//	|	CustomerSales.Контрагент.*,
//	|	CustomerSales.Договор.*,
//	|	CustomerSales.ГруппаГостей.*,
//	|	CustomerSales.Клиент.*,
//	|	CustomerSales.Тариф.*,
//	|	CustomerSales.ДокОснование.*,
//	|	CustomerSales.СпособОплаты.*,
//	|	CustomerSales.Услуга.*,
//	|	CustomerSales.СпособОплаты.*,
//	|	CustomerSales.ТипКлиента.*,
//	|	CustomerSales.СчетПроживания.*,
//	|	CustomerSales.НомерРазмещения.*,
//	|	CustomerSales.ТипНомера.*,
//	|	CustomerSales.ВидРазмещения.*,
//	|	CustomerSales.TripPurpose.*,
//	|	CustomerSales.МаретингНапрвл.*,
//	|	CustomerSales.ИсточИнфоГостиница.*,
//	|	CustomerSales.Ресурс.*,
//	|	CustomerSales.ТипРесурса.*,
//	|	CustomerSales.Автор.*,
//	|	CustomerSales.Скидка,
//	|	CustomerSales.ТипСкидки.*,
//	|	CustomerSales.ДисконтКарт.*,
//	|	CustomerSales.ВидКомиссииАгента,
//	|	CustomerSales.КомиссияАгента,
//	|	CustomerSales.СтавкаНДС.*,
//	|	CustomerSales.Цена AS Цена,
//	|	CustomerSales.ПутевкаКурсовка.* AS ПутевкаКурсовка,
//	|	CustomerSales.Продажи AS Продажи,
//	|	CustomerSales.ДоходНомеров AS ДоходНомеров,
//	|	CustomerSales.ДоходДопМеста AS ДоходДопМеста,
//	|	CustomerSales.ПродажиБезНДС AS ПродажиБезНДС,
//	|	CustomerSales.ДоходПродажиБезНДС AS ДоходПродажиБезНДС,
//	|	CustomerSales.ДоходДопМестаБезНДС AS ДоходДопМестаБезНДС,
//	|	CustomerSales.СуммаКомиссии AS СуммаКомиссии,
//	|	CustomerSales.КомиссияБезНДС AS КомиссияБезНДС,
//	|	CustomerSales.СуммаСкидки AS СуммаСкидки,
//	|	CustomerSales.СуммаСкидкиБезНДС AS СуммаСкидкиБезНДС,
//	|	CustomerSales.ПроданоНомеров AS ПроданоНомеров,
//	|	CustomerSales.ПроданоМест AS ПроданоМест,
//	|	CustomerSales.ПроданоДопМест AS ПроданоДопМест,
//	|	CustomerSales.ЧеловекаДни AS ЧеловекаДни,
//	|	CustomerSales.ЗаездГостей AS ЗаездГостей,
//	|	CustomerSales.ЗаездНомеров AS ЗаездНомеров,
//	|	CustomerSales.ЗаездМест AS ЗаездМест,
//	|	CustomerSales.ЗаездДополнительныхМест AS ЗаездДополнительныхМест,
//	|	CustomerSales.Количество AS Количество,
//	|	CustomerSales.ClientLastCheckInDate AS ClientLastCheckInDate,
//	|	CustomerSales.ClientFirstCheckInDate AS ClientFirstCheckInDate,
//	|	CustomerSales.CustomerLastCheckInDate AS CustomerLastCheckInDate,
//	|	CustomerSales.CustomerFirstCheckInDate AS CustomerFirstCheckInDate,
//	|	CustomerSales.УчетнаяДата,
//	|	(WEEK(CustomerSales.УчетнаяДата)) AS AccountingWeek,
//	|	(MONTH(CustomerSales.УчетнаяДата)) AS AccountingMonth,
//	|	(QUARTER(CustomerSales.УчетнаяДата)) AS AccountingQuarter,
//	|	(YEAR(CustomerSales.УчетнаяДата)) AS AccountingYear,
//	|	CustomerSales.TotalSales AS TotalSales,
//	|	CustomerSales.TotalRoomRevenue AS TotalRoomRevenue,
//	|	CustomerSales.TotalRoomsRented AS TotalRoomsRented,
//	|	CustomerSales.TotalBedsRented AS TotalBedsRented,
//	|	CustomerSales.TotalSalesPercent AS TotalSalesPercent,
//	|	CustomerSales.TotalRoomRevenuePercent AS TotalRoomRevenuePercent,
//	|	CustomerSales.TotalRoomsRentedPercent AS TotalRoomsRentedPercent,
//	|	CustomerSales.TotalBedsRentedPercent AS TotalBedsRentedPercent,
//	|	CustomerSales.ADR AS ADR,
//	|	CustomerSales.ADBR AS ADBR,
//	|	CustomerSales.ADRWithoutVAT AS ADRWithoutVAT,
//	|	CustomerSales.ADBRWithoutVAT AS ADBRWithoutVAT,
//	|	CustomerSales.RevPAC AS RevPAC,
//	|	CustomerSales.RevPACWithoutVAT AS RevPACWithoutVAT,
//	|	CustomerSales.ALS AS ALS}
//	|
//	|ORDER BY
//	|	Валюта,
//	|	Контрагент
//	|{ORDER BY
//	|	Гостиница.*,
//	|	Фирма.*,
//	|	Валюта.*,
//	|	Агент.*,
//	|	Контрагент.*,
//	|	Договор.*,
//	|	ГруппаГостей.*,
//	|	CustomerSales.Клиент.*,
//	|	Тариф.*,
//	|	Услуга.*,
//	|	ДокОснование.*,
//	|	CustomerSales.СпособОплаты.*,
//	|	CustomerSales.СпособОплаты.*,
//	|	CustomerSales.ТипКлиента.*,
//	|	CustomerSales.СчетПроживания.*,
//	|	CustomerSales.НомерРазмещения.*,
//	|	CustomerSales.ТипНомера.*,
//	|	CustomerSales.ВидРазмещения.*,
//	|	CustomerSales.TripPurpose.*,
//	|	CustomerSales.МаретингНапрвл.*,
//	|	CustomerSales.ИсточИнфоГостиница.*,
//	|	CustomerSales.Ресурс.*,
//	|	CustomerSales.ТипРесурса.*,
//	|	CustomerSales.Автор.*,
//	|	CustomerSales.Скидка,
//	|	CustomerSales.ТипСкидки.*,
//	|	CustomerSales.ДисконтКарт.*,
//	|	CustomerSales.ВидКомиссииАгента,
//	|	CustomerSales.КомиссияАгента,
//	|	CustomerSales.СтавкаНДС.*,
//	|	CustomerSales.Цена AS Цена,
//	|	CustomerSales.ПутевкаКурсовка.* AS ПутевкаКурсовка,
//	|	Продажи,
//	|	ДоходНомеров,
//	|	ДоходДопМеста,
//	|	ПродажиБезНДС,
//	|	ДоходПродажиБезНДС,
//	|	ДоходДопМестаБезНДС,
//	|	СуммаКомиссии,
//	|	КомиссияБезНДС,
//	|	СуммаСкидки,
//	|	СуммаСкидкиБезНДС,
//	|	ПроданоНомеров,
//	|	ПроданоМест,
//	|	ПроданоДопМест,
//	|	ЧеловекаДни,
//	|	ЗаездГостей,
//	|	ЗаездНомеров,
//	|	ЗаездМест,
//	|	ЗаездДополнительныхМест,
//	|	Количество,
//	|	ClientLastCheckInDate,
//	|	ClientFirstCheckInDate,
//	|	CustomerLastCheckInDate,
//	|	CustomerFirstCheckInDate,
//	|	УчетнаяДата,
//	|	(WEEK(CustomerSales.УчетнаяДата)) AS AccountingWeek,
//	|	(MONTH(CustomerSales.УчетнаяДата)) AS AccountingMonth,
//	|	(QUARTER(CustomerSales.УчетнаяДата)) AS AccountingQuarter,
//	|	(YEAR(CustomerSales.УчетнаяДата)) AS AccountingYear,
//	|	TotalSales,
//	|	TotalRoomRevenue,
//	|	TotalRoomsRented,
//	|	TotalBedsRented,
//	|	TotalSalesPercent,
//	|	TotalRoomRevenuePercent,
//	|	TotalRoomsRentedPercent,
//	|	TotalBedsRentedPercent,
//	|	ADR,
//	|	ADBR,
//	|	ADRWithoutVAT,
//	|	ADBRWithoutVAT,
//	|	RevPAC,
//	|	RevPACWithoutVAT,
//	|	ALS}
//	|TOTALS
//	|	MAX(ClientLastCheckInDate),
//	|	MIN(ClientFirstCheckInDate),
//	|	MAX(CustomerLastCheckInDate),
//	|	MIN(CustomerFirstCheckInDate),
//	|	SUM(Продажи),
//	|	SUM(ДоходНомеров),
//	|	SUM(ДоходДопМеста),
//	|	SUM(MainBedsRevenue),
//	|	SUM(ПродажиБезНДС),
//	|	SUM(ДоходПродажиБезНДС),
//	|	SUM(ДоходДопМестаБезНДС),
//	|	SUM(MainBedsRevenueWithoutVAT),
//	|	SUM(СуммаКомиссии),
//	|	SUM(КомиссияБезНДС),
//	|	SUM(СуммаСкидки),
//	|	SUM(СуммаСкидкиБезНДС),
//	|	SUM(ПроданоНомеров),
//	|	SUM(ПроданоМест),
//	|	SUM(ПроданоДопМест),
//	|	SUM(ЧеловекаДни),
//	|	SUM(ЗаездГостей),
//	|	SUM(ЗаездНомеров),
//	|	SUM(ЗаездМест),
//	|	SUM(ЗаездДополнительныхМест),
//	|	SUM(Количество),
//	|	MAX(TotalSales),
//	|	MAX(TotalRoomRevenue),
//	|	MAX(TotalRoomsRented),
//	|	MAX(TotalBedsRented),
//	|	CASE
//	|		WHEN MAX(TotalSales) = 0
//	|			THEN 0
//	|		ELSE SUM(Продажи) * 100 / MAX(TotalSales)
//	|	END AS TotalSalesPercent,
//	|	CASE
//	|		WHEN MAX(TotalRoomRevenue) = 0
//	|			THEN 0
//	|		ELSE SUM(ДоходНомеров) * 100 / MAX(TotalRoomRevenue)
//	|	END AS TotalRoomRevenuePercent,
//	|	CASE
//	|		WHEN MAX(TotalRoomsRented) = 0
//	|			THEN 0
//	|		ELSE SUM(ПроданоНомеров) * 100 / MAX(TotalRoomsRented)
//	|	END AS TotalRoomsRentedPercent,
//	|	CASE
//	|		WHEN MAX(TotalBedsRented) = 0
//	|			THEN 0
//	|		ELSE SUM(ПроданоМест) * 100 / MAX(TotalBedsRented)
//	|	END AS TotalBedsRentedPercent,
//	|	CASE
//	|		WHEN SUM(ПроданоНомеров) = 0
//	|			THEN 0
//	|		ELSE SUM(ДоходНомеров) / SUM(ПроданоНомеров)
//	|	END AS ADR,
//	|	CASE
//	|		WHEN SUM(ПроданоМест) = 0
//	|			THEN 0
//	|		ELSE SUM(ДоходНомеров) / SUM(ПроданоМест)
//	|	END AS ADBR,
//	|	CASE
//	|		WHEN SUM(ПроданоНомеров) = 0
//	|			THEN 0
//	|		ELSE SUM(ДоходПродажиБезНДС) / SUM(ПроданоНомеров)
//	|	END AS ADRWithoutVAT,
//	|	CASE
//	|		WHEN SUM(ПроданоМест) = 0
//	|			THEN 0
//	|		ELSE SUM(ДоходПродажиБезНДС) / SUM(ПроданоМест)
//	|	END AS ADBRWithoutVAT,
//	|	CASE
//	|		WHEN SUM(ЧеловекаДни) = 0
//	|			THEN 0
//	|		ELSE SUM(ДоходНомеров) / SUM(ЧеловекаДни)
//	|	END AS RevPAC,
//	|	CASE
//	|		WHEN SUM(ЧеловекаДни) = 0
//	|			THEN 0
//	|		ELSE SUM(ДоходПродажиБезНДС) / SUM(ЧеловекаДни)
//	|	END AS RevPACWithoutVAT,
//	|	CASE
//	|		WHEN SUM(ЗаездГостей) = 0
//	|			THEN 0
//	|		ELSE SUM(ЧеловекаДни) / SUM(ЗаездГостей)
//	|	END AS ALS
//	|BY
//	|	OVERALL,
//	|	Валюта,
//	|	Контрагент HIERARCHY
//	|{TOTALS BY
//	|	Гостиница.*,
//	|	Фирма.*,
//	|	Валюта.*,
//	|	Агент.*,
//	|	Контрагент.*,
//	|	Договор.*,
//	|	ГруппаГостей.*,
//	|	CustomerSales.Клиент.*,
//	|	Тариф.*,
//	|	ДокОснование.*,
//	|	CustomerSales.СпособОплаты.*,
//	|	Услуга.*,
//	|	УчетнаяДата,
//	|	CustomerSales.СпособОплаты.*,
//	|	CustomerSales.ТипКлиента.*,
//	|	CustomerSales.СчетПроживания.*,
//	|	CustomerSales.НомерРазмещения.*,
//	|	CustomerSales.ТипНомера.*,
//	|	CustomerSales.ВидРазмещения.*,
//	|	CustomerSales.TripPurpose.*,
//	|	CustomerSales.МаретингНапрвл.*,
//	|	CustomerSales.ИсточИнфоГостиница.*,
//	|	CustomerSales.Ресурс.*,
//	|	CustomerSales.ТипРесурса.*,
//	|	CustomerSales.Автор.*,
//	|	CustomerSales.Скидка,
//	|	CustomerSales.ТипСкидки.*,
//	|	CustomerSales.ДисконтКарт.*,
//	|	CustomerSales.ВидКомиссииАгента,
//	|	CustomerSales.КомиссияАгента,
//	|	CustomerSales.СтавкаНДС.*,
//	|	CustomerSales.Цена AS Цена,
//	|	CustomerSales.ПутевкаКурсовка.* AS ПутевкаКурсовка,
//	|	ADR,
//	|	(WEEK(CustomerSales.УчетнаяДата)) AS AccountingWeek,
//	|	(MONTH(CustomerSales.УчетнаяДата)) AS AccountingMonth,
//	|	(QUARTER(CustomerSales.УчетнаяДата)) AS AccountingQuarter,
//	|	(YEAR(CustomerSales.УчетнаяДата)) AS AccountingYear}";
//	ReportBuilder.Text = QueryText;
//	ReportBuilder.FillSettings();
//	
//	// Initialize report builder with default query
//	vRB = New ReportBuilder(QueryText);
//	vRBSettings = vRB.GetSettings(True, True, True, True, True);
//	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
//	
//	// Set default report builder header text
//	ReportBuilder.HeaderText = NStr("EN='Контрагент guests turnovers'; RU='Обороты продаж по гостям от контрагентов'");
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
//	If pName = "Продажи" 
//	   Or pName = "ДоходНомеров" 
//	   Or pName = "ДоходДопМеста" 
//	   Or pName = "MainBedsRevenue" 
//	   Or pName = "ПродажиБезНДС" 
//	   Or pName = "ДоходПродажиБезНДС" 
//	   Or pName = "ДоходДопМестаБезНДС" 
//	   Or pName = "MainBedsRevenueWithoutVAT" 
//	   Or pName = "СуммаКомиссии" 
//	   Or pName = "КомиссияБезНДС" 
//	   Or pName = "СуммаСкидки" 
//	   Or pName = "СуммаСкидкиБезНДС" 
//	   Or pName = "ПроданоНомеров" 
//	   Or pName = "ПроданоМест" 
//	   Or pName = "ПроданоДопМест" 
//	   Or pName = "ЧеловекаДни" 
//	   Or pName = "ЗаездГостей" 
//	   Or pName = "ЗаездНомеров" 
//	   Or pName = "ЗаездМест" 
//	   Or pName = "ЗаездДополнительныхМест" 
//	   Or pName = "Количество" 
//	   Or pName = "TotalRoomRevenue" 
//	   Or pName = "TotalSales" 
//	   Or pName = "TotalRoomsRented" 
//	   Or pName = "TotalBedsRented" 
//	   Or pName = "TotalRoomRevenuePercent" 
//	   Or pName = "TotalSalesPercent"
//	   Or pName = "TotalRoomsRentedPercent" 
//	   Or pName = "TotalBedsRentedPercent" 
//	   Or pName = "ADR"
//	   Or pName = "ADBR"
//	   Or pName = "ADRWithoutVAT"
//	   Or pName = "ADBRWithoutVAT"
//	   Or pName = "RevPAC"
//	   Or pName = "RevPACWithoutVAT"
//	   Or pName = "ALS" Тогда
//		Return True;
//	Else
//		Return False;
//	EndIf;
//EndFunction //pmIsResource
//
////-----------------------------------------------------------------------------
//// Reports framework end
////-----------------------------------------------------------------------------
