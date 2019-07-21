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
//	If ЗначениеЗаполнено(ClientCitizenship) Тогда
//		If НЕ ClientCitizenship.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("ru = 'Страна '; en = 'Country '") + 
//			                     TrimAll(ClientCitizenship.Description) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("ru = 'Группа стран '; en = 'Countries folder '") + 
//			                     TrimAll(ClientCitizenship.Description) + 
//			                     ";" + Chars.LF;
//		EndIf;
//	EndIf;							 
//						 
//	If ЗначениеЗаполнено(SourceOfBusiness) Тогда
//		If НЕ SourceOfBusiness.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("ru = 'Источник информации '; en = 'Source of buisiness '") + 
//			                     TrimAll(SourceOfBusiness.Description) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("ru = 'Группа источников '; en = 'Source of business folder '") + 
//			                     TrimAll(SourceOfBusiness.Description) + 
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
//	ReportBuilder.Parameters.Вставить("qEmptyDate", '00010101');
//	ReportBuilder.Parameters.Вставить("qClientCitizenship", ClientCitizenship);
//	ReportBuilder.Parameters.Вставить("qIsEmptyClientCitizenship", НЕ ЗначениеЗаполнено(ClientCitizenship));
//	ReportBuilder.Parameters.Вставить("qSourceOfBusiness", SourceOfBusiness);
//	ReportBuilder.Parameters.Вставить("qIsEmptySourceOfBusiness", НЕ ЗначениеЗаполнено(SourceOfBusiness));
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
//	ReportBuilder.Parameters.Вставить("qUndefinedAge", NStr("en='1. <Неопределено>';ru='1. <Не указан>';de='1. <Nicht angegeben>'"));
//	ReportBuilder.Parameters.Вставить("qChild", NStr("en='2. Child (1 - 14)';ru='2. Ребенок (1 - 14)';de='2. Kind (1 - 14)'"));
//	ReportBuilder.Parameters.Вставить("qTeenager", NStr("en='3. Teenager (15 - 21)';ru='3. Тинейджер (15 - 21)';de='3. Teenager (15-21)'"));
//	ReportBuilder.Parameters.Вставить("q2229", NStr("en='4. Adult (22 - 29)';ru='4. Взрослый (22 - 29)';de='4. Erwachsener (22 - 29)'"));
//	ReportBuilder.Parameters.Вставить("q3039", NStr("en='5. Adult (30 - 39)';ru='5. Взрослый (30 - 39)';de='5. Erwachsener (30 - 39)'"));
//	ReportBuilder.Parameters.Вставить("q4049", NStr("en='6. Adult (40 - 49)';ru='6. Взрослый (40 - 49)';de='6. Erwachsener (40 - 49)'"));
//	ReportBuilder.Parameters.Вставить("q5059", NStr("en='7. Adult (50 - 59)';ru='7. Взрослый (50 - 59)';de='7. Erwachsener (50-59)'"));
//	ReportBuilder.Parameters.Вставить("qGreater60", NStr("en='8. Above 60';ru='8. Старше 60';de='8. älter als 60'"));
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
//	|	TotalInventoryBalanceAndTurnovers.Гостиница AS Гостиница,
//	|	SUM(TotalInventoryBalanceAndTurnovers.CounterClosingBalance) AS CounterClosingBalance,
//	|	SUM(TotalInventoryBalanceAndTurnovers.TotalRoomsClosingBalance) AS ВсегоНомеров,
//	|	SUM(TotalInventoryBalanceAndTurnovers.TotalBedsClosingBalance) AS ВсегоМест,
//	|	-SUM(TotalInventoryBalanceAndTurnovers.RoomsBlockedClosingBalance) AS TotalRoomsBlocked,
//	|	-SUM(TotalInventoryBalanceAndTurnovers.BedsBlockedClosingBalance) AS TotalBedsBlocked,
//	|	SUM(TotalInventoryBalanceAndTurnovers.ExpectedGuestsCheckedInTurnover) AS TotalGuestsReservedReceipt,
//	|	SUM(TotalInventoryBalanceAndTurnovers.ExpectedGuestsCheckedOutTurnover) AS TotalGuestsReservedExpense,
//	|	SUM(TotalInventoryBalanceAndTurnovers.InHouseGuestsReceipt) AS TotalInHouseGuestsReceipt,
//	|	SUM(TotalInventoryBalanceAndTurnovers.InHouseGuestsExpense) AS TotalInHouseGuestsExpense
//	|INTO HotelInventoryTotals
//	|FROM
//	|	AccumulationRegister.ЗагрузкаНомеров.BalanceAndTurnovers(&qPeriodFrom, &qPeriodTo, Day, RegisterRecordsAndPeriodBoundaries, Гостиница IN HIERARCHY (&qHotel)) AS TotalInventoryBalanceAndTurnovers
//	|
//	|GROUP BY
//	|	TotalInventoryBalanceAndTurnovers.Гостиница
//	|;
//	|
//	|////////////////////////////////////////////////////////////////////////////////
//	|SELECT
//	|	GeoSales.Валюта AS Валюта,
//	|	GeoSales.Гостиница AS Гостиница,
//	|	GeoSales.ClientCitizenship AS ClientCitizenship,
//	|	GeoSales.ClientRegion AS ClientRegion,
//	|	GeoSales.ClientCity AS ClientCity,
//	|	GeoSales.ClientAge AS ClientAge,
//	|	GeoSales.МаретингНапрвл AS МаретингНапрвл,
//	|	GeoSales.ИсточИнфоГостиница AS ИсточИнфоГостиница,
//	|	GeoSales.TripPurpose AS TripPurpose,
//	|	GeoSales.Фирма AS Фирма,
//	|	GeoSales.УчетнаяДата AS УчетнаяДата,
//	|	GeoSales.ДокОснование,
//	|	GeoSales.Услуга AS Услуга,
//	|	GeoSales.RoomsPerPeriod AS RoomsPerPeriod,
//	|	GeoSales.BedsPerPeriod AS BedsPerPeriod,
//	|	GeoSales.RoomsBlockedPerPeriod AS RoomsBlockedPerPeriod,
//	|	GeoSales.BedsBlockedPerPeriod AS BedsBlockedPerPeriod,
//	|	CASE
//	|		WHEN GeoSales.ПроданоНомеров = 0
//	|			THEN 0
//	|		ELSE GeoSales.ДоходНомеров / GeoSales.ПроданоНомеров
//	|	END AS AverageRoomPrice,
//	|	CASE
//	|		WHEN GeoSales.ПроданоМест = 0
//	|			THEN 0
//	|		ELSE GeoSales.ДоходНомеров / GeoSales.ПроданоМест
//	|	END AS AverageBedPrice,
//	|	CASE
//	|		WHEN GeoSales.RoomsPerPeriod = 0
//	|			THEN 0
//	|		ELSE GeoSales.ДоходНомеров / GeoSales.RoomsPerPeriod
//	|	END AS RevPAR,
//	|	CASE
//	|		WHEN GeoSales.BedsPerPeriod = 0
//	|			THEN 0
//	|		ELSE GeoSales.ДоходНомеров / GeoSales.BedsPerPeriod
//	|	END AS RevPAB,
//	|	CASE
//	|		WHEN GeoSales.ПроданоНомеров = 0
//	|			THEN 0
//	|		ELSE GeoSales.ДоходПродажиБезНДС / GeoSales.ПроданоНомеров
//	|	END AS AverageRoomPriceWithoutVAT,
//	|	CASE
//	|		WHEN GeoSales.ПроданоМест = 0
//	|			THEN 0
//	|		ELSE GeoSales.ДоходПродажиБезНДС / GeoSales.ПроданоМест
//	|	END AS AverageBedPriceWithoutVAT,
//	|	CASE
//	|		WHEN GeoSales.RoomsPerPeriod = 0
//	|			THEN 0
//	|		ELSE GeoSales.ДоходПродажиБезНДС / GeoSales.RoomsPerPeriod
//	|	END AS RevPARWithoutVAT,
//	|	CASE
//	|		WHEN GeoSales.BedsPerPeriod = 0
//	|			THEN 0
//	|		ELSE GeoSales.ДоходПродажиБезНДС / GeoSales.BedsPerPeriod
//	|	END AS RevPABWithoutVAT,
//	|	CASE
//	|		WHEN GeoSales.RoomsPerPeriod = 0
//	|			THEN 0
//	|		ELSE GeoSales.ПроданоНомеров * 100 / GeoSales.RoomsPerPeriod
//	|	END AS RoomsRentedPercent,
//	|	CASE
//	|		WHEN GeoSales.BedsPerPeriod = 0
//	|			THEN 0
//	|		ELSE GeoSales.ПроданоМест * 100 / GeoSales.BedsPerPeriod
//	|	END AS BedsRentedPercent,
//	|	CASE
//	|		WHEN GeoSales.RoomsPerPeriod - GeoSales.RoomsBlockedPerPeriod = 0
//	|			THEN 0
//	|		ELSE GeoSales.ПроданоНомеров * 100 / (GeoSales.RoomsPerPeriod - GeoSales.RoomsBlockedPerPeriod)
//	|	END AS RoomsRentedPercentWithRoomBlocks,
//	|	CASE
//	|		WHEN GeoSales.BedsPerPeriod - GeoSales.BedsBlockedPerPeriod = 0
//	|			THEN 0
//	|		ELSE GeoSales.ПроданоМест * 100 / (GeoSales.BedsPerPeriod - GeoSales.BedsBlockedPerPeriod)
//	|	END AS BedsRentedPercentWithRoomBlocks,
//	|	GeoSales.Продажи AS Продажи,
//	|	GeoSales.ДоходНомеров AS ДоходНомеров,
//	|	GeoSales.ДоходДопМеста AS ДоходДопМеста,
//	|	GeoSales.MainBedsRevenue AS MainBedsRevenue,
//	|	GeoSales.ПродажиБезНДС AS ПродажиБезНДС,
//	|	GeoSales.ДоходПродажиБезНДС AS ДоходПродажиБезНДС,
//	|	GeoSales.ДоходДопМестаБезНДС AS ДоходДопМестаБезНДС,
//	|	GeoSales.MainBedsRevenueWithoutVAT AS MainBedsRevenueWithoutVAT,
//	|	GeoSales.СуммаКомиссии AS СуммаКомиссии,
//	|	GeoSales.КомиссияБезНДС AS КомиссияБезНДС,
//	|	GeoSales.СуммаСкидки AS СуммаСкидки,
//	|	GeoSales.СуммаСкидкиБезНДС AS СуммаСкидкиБезНДС,
//	|	GeoSales.ПроданоНомеров AS ПроданоНомеров,
//	|	GeoSales.ПроданоМест AS ПроданоМест,
//	|	GeoSales.ПроданоДопМест AS ПроданоДопМест,
//	|	GeoSales.ЧеловекаДни AS ЧеловекаДни,
//	|	GeoSales.ЗаездГостей AS ЗаездГостей,
//	|	GeoSales.ЗаездНомеров AS ЗаездНомеров,
//	|	GeoSales.ЗаездМест AS ЗаездМест,
//	|	GeoSales.ЗаездДополнительныхМест AS ЗаездДополнительныхМест,
//	|	GeoSales.Количество AS Количество,
//	|	GeoSales.TotalSalesAmount AS TotalSalesAmount,
//	|	CASE
//	|		WHEN GeoSales.TotalSalesAmount = 0
//	|			THEN 0
//	|		ELSE GeoSales.Продажи * 100 / GeoSales.TotalSalesAmount
//	|	END AS TotalSalesPercent
//	|{SELECT
//	|	Валюта.*,
//	|	Гостиница.*,
//	|	ClientCitizenship.*,
//	|	ClientRegion,
//	|	ClientCity,
//	|	ClientAge,
//	|	МаретингНапрвл.*,
//	|	ИсточИнфоГостиница.*,
//	|	TripPurpose.*,
//	|	Услуга.*,
//	|	Фирма.*,
//	|	ДокОснование.*,
//	|	TotalSalesAmount,
//	|	TotalSalesPercent,
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
//	|	RoomsPerPeriod,
//	|	BedsPerPeriod,
//	|	RoomsBlockedPerPeriod,
//	|	BedsBlockedPerPeriod,
//	|	AverageRoomPrice,
//	|	AverageBedPrice,
//	|	RevPAR,
//	|	RevPAB,
//	|	AverageRoomPriceWithoutVAT,
//	|	AverageBedPriceWithoutVAT,
//	|	RevPARWithoutVAT,
//	|	RevPABWithoutVAT,
//	|	RoomsRentedPercent,
//	|	BedsRentedPercent,
//	|	RoomsRentedPercentWithRoomBlocks,
//	|	BedsRentedPercentWithRoomBlocks,
//	|	(CASE
//	|			WHEN GeoSales.ClientAge IS NULL 
//	|				THEN &qUndefinedAge
//	|			WHEN ISNULL(GeoSales.ClientDateOfBirth, &qEmptyDate) = &qEmptyDate
//	|				THEN &qUndefinedAge
//	|			WHEN GeoSales.ClientAge < 15
//	|				THEN &qChild
//	|			WHEN GeoSales.ClientAge < 22
//	|				THEN &qTeenager
//	|			WHEN GeoSales.ClientAge < 30
//	|				THEN &q2229
//	|			WHEN GeoSales.ClientAge < 40
//	|				THEN &q3039
//	|			WHEN GeoSales.ClientAge < 50
//	|				THEN &q4049
//	|			WHEN GeoSales.ClientAge < 60
//	|				THEN &q5059
//	|			ELSE &qGreater60
//	|		END) AS AgeRange,
//	|	УчетнаяДата,
//	|	(WEEK(GeoSales.УчетнаяДата)) AS AccountingWeek,
//	|	(MONTH(GeoSales.УчетнаяДата)) AS AccountingMonth,
//	|	(QUARTER(GeoSales.УчетнаяДата)) AS AccountingQuarter,
//	|	(YEAR(GeoSales.УчетнаяДата)) AS AccountingYear}
//	|FROM
//	|	(SELECT
//	|		GeoSalesTurnovers.Валюта AS Валюта,
//	|		GeoSalesTurnovers.Гостиница AS Гостиница,
//	|		GeoSalesTurnovers.Клиент.ДатаРождения AS ClientDateOfBirth,
//	|		GeoSalesTurnovers.Клиент.Гражданство AS ClientCitizenship,
//	|		GeoSalesTurnovers.Клиент.Region AS ClientRegion,
//	|		GeoSalesTurnovers.Клиент.City AS ClientCity,
//	|		GeoSalesTurnovers.Клиент.Age AS ClientAge,
//	|		GeoSalesTurnovers.МаретингНапрвл AS МаретингНапрвл,
//	|		GeoSalesTurnovers.ИсточИнфоГостиница AS ИсточИнфоГостиница,
//	|		GeoSalesTurnovers.TripPurpose AS TripPurpose,
//	|		GeoSalesTurnovers.Фирма AS Фирма,
//	|		GeoSalesTurnovers.УчетнаяДата AS УчетнаяДата,
//	|		GeoSalesTurnovers.ДокОснование AS ДокОснование,
//	|		GeoSalesTurnovers.Услуга AS Услуга,
//	|		GeoSalesTurnovers.SalesTurnover AS Продажи,
//	|		GeoSalesTurnovers.RoomRevenueTurnover AS ДоходНомеров,
//	|		GeoSalesTurnovers.ExtraBedRevenueTurnover AS ДоходДопМеста,
//	|		GeoSalesTurnovers.RoomRevenueTurnover - GeoSalesTurnovers.ExtraBedRevenueTurnover AS MainBedsRevenue,
//	|		GeoSalesTurnovers.SalesWithoutVATTurnover AS ПродажиБезНДС,
//	|		GeoSalesTurnovers.RoomRevenueWithoutVATTurnover AS ДоходПродажиБезНДС,
//	|		GeoSalesTurnovers.ExtraBedRevenueWithoutVATTurnover AS ДоходДопМестаБезНДС,
//	|		GeoSalesTurnovers.RoomRevenueWithoutVATTurnover - GeoSalesTurnovers.ExtraBedRevenueWithoutVATTurnover AS MainBedsRevenueWithoutVAT,
//	|		GeoSalesTurnovers.CommissionSumTurnover AS СуммаКомиссии,
//	|		GeoSalesTurnovers.CommissionSumWithoutVATTurnover AS КомиссияБезНДС,
//	|		GeoSalesTurnovers.DiscountSumTurnover AS СуммаСкидки,
//	|		GeoSalesTurnovers.DiscountSumWithoutVATTurnover AS СуммаСкидкиБезНДС,
//	|		GeoSalesTurnovers.RoomsRentedTurnover AS ПроданоНомеров,
//	|		GeoSalesTurnovers.BedsRentedTurnover AS ПроданоМест,
//	|		GeoSalesTurnovers.AdditionalBedsRentedTurnover AS ПроданоДопМест,
//	|		GeoSalesTurnovers.GuestDaysTurnover AS ЧеловекаДни,
//	|		GeoSalesTurnovers.GuestsCheckedInTurnover AS ЗаездГостей,
//	|		GeoSalesTurnovers.RoomsCheckedInTurnover AS ЗаездНомеров,
//	|		GeoSalesTurnovers.BedsCheckedInTurnover AS ЗаездМест,
//	|		GeoSalesTurnovers.AdditionalBedsCheckedInTurnover AS ЗаездДополнительныхМест,
//	|		GeoSalesTurnovers.QuantityTurnover AS Количество,
//	|		ISNULL(InventoryTotals.ВсегоНомеров, 0) AS RoomsPerPeriod,
//	|		ISNULL(InventoryTotals.ВсегоМест, 0) AS BedsPerPeriod,
//	|		ISNULL(InventoryTotals.TotalRoomsBlocked, 0) AS RoomsBlockedPerPeriod,
//	|		ISNULL(InventoryTotals.TotalBedsBlocked, 0) AS BedsBlockedPerPeriod,
//	|		ISNULL(GeoSalesTotals.TotalSalesAmount, 0) AS TotalSalesAmount
//	|	FROM
//	|		AccumulationRegister.Продажи.Turnovers(
//	|				&qPeriodFrom,
//	|				&qPeriodTo,
//	|				Day,
//	|				Гостиница IN HIERARCHY (&qHotel)
//	|					AND (Клиент.Гражданство IN HIERARCHY (&qClientCitizenship)
//	|						OR &qIsEmptyClientCitizenship)
//	|					AND (TripPurpose IN HIERARCHY (&qTripPurpose)
//	|						OR &qIsEmptyTripPurpose)
//	|					AND (ИсточИнфоГостиница IN HIERARCHY (&qSourceOfBusiness)
//	|						OR &qIsEmptySourceOfBusiness)
//	|					AND (Услуга IN HIERARCHY (&qServicesList)
//	|						OR NOT &qUseServicesList)) AS GeoSalesTurnovers
//	|			LEFT JOIN (SELECT
//	|				HotelInventoryTotals.Гостиница AS Гостиница,
//	|				HotelInventoryTotals.CounterClosingBalance AS CounterClosingBalance,
//	|				HotelInventoryTotals.ВсегоНомеров AS ВсегоНомеров,
//	|				HotelInventoryTotals.ВсегоМест AS ВсегоМест,
//	|				HotelInventoryTotals.TotalRoomsBlocked AS TotalRoomsBlocked,
//	|				HotelInventoryTotals.TotalBedsBlocked AS TotalBedsBlocked,
//	|				HotelInventoryTotals.TotalGuestsReservedReceipt AS TotalGuestsReservedReceipt,
//	|				HotelInventoryTotals.TotalGuestsReservedExpense AS TotalGuestsReservedExpense,
//	|				HotelInventoryTotals.TotalInHouseGuestsReceipt AS TotalInHouseGuestsReceipt,
//	|				HotelInventoryTotals.TotalInHouseGuestsExpense AS TotalInHouseGuestsExpense
//	|			FROM
//	|				HotelInventoryTotals AS HotelInventoryTotals) AS InventoryTotals
//	|			ON GeoSalesTurnovers.Гостиница = InventoryTotals.Гостиница
//	|			LEFT JOIN (SELECT
//	|				GeoSalesTotalTurnovers.Гостиница AS Гостиница,
//	|				GeoSalesTotalTurnovers.SalesTurnover AS TotalSalesAmount
//	|			FROM
//	|				AccumulationRegister.Продажи.Turnovers(
//	|						&qPeriodFrom,
//	|						&qPeriodTo,
//	|						Period,
//	|						Гостиница IN HIERARCHY (&qHotel)
//	|							AND (Клиент.Гражданство IN HIERARCHY (&qClientCitizenship)
//	|								OR &qIsEmptyClientCitizenship)
//	|							AND (TripPurpose IN HIERARCHY (&qTripPurpose)
//	|								OR &qIsEmptyTripPurpose)
//	|							AND (ИсточИнфоГостиница IN HIERARCHY (&qSourceOfBusiness)
//	|								OR &qIsEmptySourceOfBusiness)
//	|							AND (Услуга IN HIERARCHY (&qServicesList)
//	|								OR NOT &qUseServicesList)) AS GeoSalesTotalTurnovers) AS GeoSalesTotals
//	|			ON GeoSalesTurnovers.Гостиница = GeoSalesTotals.Гостиница) AS GeoSales
//	|{WHERE
//	|	GeoSales.Валюта.*,
//	|	GeoSales.Гостиница.*,
//	|	GeoSales.ClientCitizenship.*,
//	|	GeoSales.ClientRegion,
//	|	GeoSales.ClientCity,
//	|	GeoSales.ClientAge,
//	|	GeoSales.МаретингНапрвл.*,
//	|	GeoSales.ИсточИнфоГостиница.*,
//	|	GeoSales.TripPurpose.*,
//	|	GeoSales.ДокОснование.*,
//	|	GeoSales.Услуга.*,
//	|	GeoSales.Продажи AS Продажи,
//	|	GeoSales.ДоходНомеров AS ДоходНомеров,
//	|	GeoSales.ДоходДопМеста AS ДоходДопМеста,
//	|	GeoSales.MainBedsRevenue AS MainBedsRevenue,
//	|	GeoSales.ПродажиБезНДС AS ПродажиБезНДС,
//	|	GeoSales.ДоходПродажиБезНДС AS ДоходПродажиБезНДС,
//	|	GeoSales.ДоходДопМестаБезНДС AS ДоходДопМестаБезНДС,
//	|	GeoSales.MainBedsRevenueWithoutVAT AS MainBedsRevenueWithoutVAT,
//	|	GeoSales.СуммаКомиссии AS СуммаКомиссии,
//	|	GeoSales.КомиссияБезНДС AS КомиссияБезНДС,
//	|	GeoSales.СуммаСкидки AS СуммаСкидки,
//	|	GeoSales.СуммаСкидкиБезНДС AS СуммаСкидкиБезНДС,
//	|	GeoSales.ПроданоНомеров AS ПроданоНомеров,
//	|	GeoSales.ПроданоМест AS ПроданоМест,
//	|	GeoSales.ПроданоДопМест AS ПроданоДопМест,
//	|	GeoSales.ЧеловекаДни AS ЧеловекаДни,
//	|	GeoSales.ЗаездГостей AS ЗаездГостей,
//	|	GeoSales.ЗаездНомеров AS ЗаездНомеров,
//	|	GeoSales.ЗаездМест AS ЗаездМест,
//	|	GeoSales.ЗаездДополнительныхМест AS ЗаездДополнительныхМест,
//	|	GeoSales.Количество AS Количество,
//	|	(CASE
//	|			WHEN GeoSales.ClientAge IS NULL 
//	|				THEN &qUndefinedAge
//	|			WHEN ISNULL(GeoSales.ClientDateOfBirth, &qEmptyDate) = &qEmptyDate
//	|				THEN &qUndefinedAge
//	|			WHEN GeoSales.ClientAge < 15
//	|				THEN &qChild
//	|			WHEN GeoSales.ClientAge < 22
//	|				THEN &qTeenager
//	|			WHEN GeoSales.ClientAge < 30
//	|				THEN &q2229
//	|			WHEN GeoSales.ClientAge < 40
//	|				THEN &q3039
//	|			WHEN GeoSales.ClientAge < 50
//	|				THEN &q4049
//	|			WHEN GeoSales.ClientAge < 60
//	|				THEN &q5059
//	|			ELSE &qGreater60
//	|		END) AS AgeRange,
//	|	GeoSales.УчетнаяДата,
//	|	(WEEK(GeoSales.УчетнаяДата)) AS AccountingWeek,
//	|	(MONTH(GeoSales.УчетнаяДата)) AS AccountingMonth,
//	|	(QUARTER(GeoSales.УчетнаяДата)) AS AccountingQuarter,
//	|	(YEAR(GeoSales.УчетнаяДата)) AS AccountingYear}
//	|
//	|ORDER BY
//	|	Валюта,
//	|	ClientCitizenship,
//	|	ClientRegion
//	|{ORDER BY
//	|	Валюта.*,
//	|	Гостиница.*,
//	|	ClientCitizenship.*,
//	|	ClientRegion,
//	|	ClientCity,
//	|	ClientAge,
//	|	МаретингНапрвл.*,
//	|	ИсточИнфоГостиница.*,
//	|	TripPurpose.*,
//	|	Фирма.*,
//	|	Услуга.*,
//	|	ДокОснование.*,
//	|	TotalSalesAmount,
//	|	TotalSalesPercent,
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
//	|	(CASE
//	|			WHEN GeoSales.ClientAge IS NULL 
//	|				THEN &qUndefinedAge
//	|			WHEN ISNULL(GeoSales.ClientDateOfBirth, &qEmptyDate) = &qEmptyDate
//	|				THEN &qUndefinedAge
//	|			WHEN GeoSales.ClientAge < 15
//	|				THEN &qChild
//	|			WHEN GeoSales.ClientAge < 22
//	|				THEN &qTeenager
//	|			WHEN GeoSales.ClientAge < 30
//	|				THEN &q2229
//	|			WHEN GeoSales.ClientAge < 40
//	|				THEN &q3039
//	|			WHEN GeoSales.ClientAge < 50
//	|				THEN &q4049
//	|			WHEN GeoSales.ClientAge < 60
//	|				THEN &q5059
//	|			ELSE &qGreater60
//	|		END) AS AgeRange,
//	|	УчетнаяДата,
//	|	(WEEK(GeoSales.УчетнаяДата)) AS AccountingWeek,
//	|	(MONTH(GeoSales.УчетнаяДата)) AS AccountingMonth,
//	|	(QUARTER(GeoSales.УчетнаяДата)) AS AccountingQuarter,
//	|	(YEAR(GeoSales.УчетнаяДата)) AS AccountingYear}
//	|TOTALS
//	|	MAX(RoomsPerPeriod),
//	|	MAX(BedsPerPeriod),
//	|	MAX(RoomsBlockedPerPeriod),
//	|	MAX(BedsBlockedPerPeriod),
//	|	CASE
//	|		WHEN SUM(ПроданоНомеров) = 0
//	|			THEN 0
//	|		ELSE SUM(ДоходНомеров) / SUM(ПроданоНомеров)
//	|	END AS AverageRoomPrice,
//	|	CASE
//	|		WHEN SUM(ПроданоМест) = 0
//	|			THEN 0
//	|		ELSE SUM(ДоходНомеров) / SUM(ПроданоМест)
//	|	END AS AverageBedPrice,
//	|	CASE
//	|		WHEN MAX(RoomsPerPeriod) = 0
//	|			THEN 0
//	|		ELSE SUM(ДоходНомеров) / MAX(RoomsPerPeriod)
//	|	END AS RevPAR,
//	|	CASE
//	|		WHEN MAX(BedsPerPeriod) = 0
//	|			THEN 0
//	|		ELSE SUM(ДоходНомеров) / MAX(BedsPerPeriod)
//	|	END AS RevPAB,
//	|	CASE
//	|		WHEN SUM(ПроданоНомеров) = 0
//	|			THEN 0
//	|		ELSE SUM(ДоходПродажиБезНДС) / SUM(ПроданоНомеров)
//	|	END AS AverageRoomPriceWithoutVAT,
//	|	CASE
//	|		WHEN SUM(ПроданоМест) = 0
//	|			THEN 0
//	|		ELSE SUM(ДоходПродажиБезНДС) / SUM(ПроданоМест)
//	|	END AS AverageBedPriceWithoutVAT,
//	|	CASE
//	|		WHEN MAX(RoomsPerPeriod) = 0
//	|			THEN 0
//	|		ELSE SUM(ДоходПродажиБезНДС) / MAX(RoomsPerPeriod)
//	|	END AS RevPARWithoutVAT,
//	|	CASE
//	|		WHEN MAX(BedsPerPeriod) = 0
//	|			THEN 0
//	|		ELSE SUM(ДоходПродажиБезНДС) / MAX(BedsPerPeriod)
//	|	END AS RevPABWithoutVAT,
//	|	CASE
//	|		WHEN MAX(RoomsPerPeriod) = 0
//	|			THEN 0
//	|		ELSE SUM(ПроданоНомеров) * 100 / MAX(RoomsPerPeriod)
//	|	END AS RoomsRentedPercent,
//	|	CASE
//	|		WHEN MAX(BedsPerPeriod) = 0
//	|			THEN 0
//	|		ELSE SUM(ПроданоМест) * 100 / MAX(BedsPerPeriod)
//	|	END AS BedsRentedPercent,
//	|	CASE
//	|		WHEN MAX(RoomsPerPeriod) - MAX(RoomsBlockedPerPeriod) = 0
//	|			THEN 0
//	|		ELSE SUM(ПроданоНомеров) * 100 / (MAX(RoomsPerPeriod) - MAX(RoomsBlockedPerPeriod))
//	|	END AS RoomsRentedPercentWithRoomBlocks,
//	|	CASE
//	|		WHEN MAX(BedsPerPeriod) - MAX(BedsBlockedPerPeriod) = 0
//	|			THEN 0
//	|		ELSE SUM(ПроданоМест) * 100 / (MAX(BedsPerPeriod) - MAX(BedsBlockedPerPeriod))
//	|	END AS BedsRentedPercentWithRoomBlocks,
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
//	|	MAX(TotalSalesAmount),
//	|	CASE
//	|		WHEN MAX(TotalSalesAmount) = 0
//	|			THEN 0
//	|		ELSE SUM(Продажи) * 100 / MAX(TotalSalesAmount)
//	|	END AS TotalSalesPercent
//	|BY
//	|	OVERALL,
//	|	Валюта,
//	|	ClientCitizenship HIERARCHY,
//	|	ClientRegion
//	|{TOTALS BY
//	|	GeoSales.Валюта.*,
//	|	GeoSales.Гостиница.*,
//	|	GeoSales.ClientCitizenship.*,
//	|	GeoSales.ClientRegion,
//	|	GeoSales.ClientCity,
//	|	GeoSales.ClientAge,
//	|	GeoSales.МаретингНапрвл.*,
//	|	GeoSales.ИсточИнфоГостиница.*,
//	|	GeoSales.TripPurpose.*,
//	|	GeoSales.Фирма.*,
//	|	GeoSales.ДокОснование.*,
//	|	GeoSales.Услуга.*,
//	|	(CASE
//	|			WHEN GeoSales.ClientAge IS NULL 
//	|				THEN &qUndefinedAge
//	|			WHEN ISNULL(GeoSales.ClientDateOfBirth, &qEmptyDate) = &qEmptyDate
//	|				THEN &qUndefinedAge
//	|			WHEN GeoSales.ClientAge < 15
//	|				THEN &qChild
//	|			WHEN GeoSales.ClientAge < 22
//	|				THEN &qTeenager
//	|			WHEN GeoSales.ClientAge < 30
//	|				THEN &q2229
//	|			WHEN GeoSales.ClientAge < 40
//	|				THEN &q3039
//	|			WHEN GeoSales.ClientAge < 50
//	|				THEN &q4049
//	|			WHEN GeoSales.ClientAge < 60
//	|				THEN &q5059
//	|			ELSE &qGreater60
//	|		END) AS AgeRange,
//	|	GeoSales.УчетнаяДата,
//	|	(WEEK(GeoSales.УчетнаяДата)) AS AccountingWeek,
//	|	(MONTH(GeoSales.УчетнаяДата)) AS AccountingMonth,
//	|	(QUARTER(GeoSales.УчетнаяДата)) AS AccountingQuarter,
//	|	(YEAR(GeoSales.УчетнаяДата)) AS AccountingYear}";
//	ReportBuilder.Text = QueryText;
//	ReportBuilder.FillSettings();
//	
//	// Initialize report builder with default query
//	vRB = New ReportBuilder(QueryText);
//	vRBSettings = vRB.GetSettings(True, True, True, True, True);
//	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
//	
//	// Set default report builder header text
//	ReportBuilder.HeaderText = NStr("EN='Geo sales turnovers';RU='Обороты продаж по регионам';de='Verkaufsumsätze nach Regionen'");
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
//	   Or pName = "RoomsPerPeriod" 
//	   Or pName = "BedsPerPeriod" 
//	   Or pName = "RoomsBlockedPerPeriod" 
//	   Or pName = "BedsBlockedPerPeriod" 
//	   Or pName = "AverageRoomPrice" 
//	   Or pName = "AverageBedPrice" 
//	   Or pName = "RevPAR" 
//	   Or pName = "RevPAB" 
//	   Or pName = "AverageBedPriceWithoutVAT" 
//	   Or pName = "RevPARWithoutVAT" 
//	   Or pName = "RevPABWithoutVAT" 
//	   Or pName = "RoomsRentedPercent" 
//	   Or pName = "BedsRentedPercent" 
//	   Or pName = "RoomsRentedPercentWithRoomBlocks" 
//	   Or pName = "BedsRentedPercentWithRoomBlocks" 
//	   Or pName = "TotalSalesAmount" 
//	   Or pName = "TotalSalesPercent" Тогда
//		Return True;
//	Else
//		Return False;
//	EndIf;
//EndFunction //pmIsResource
//
////-----------------------------------------------------------------------------
//// Reports framework end
////-----------------------------------------------------------------------------
