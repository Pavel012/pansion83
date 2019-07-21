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
//		PeriodFrom = BegOfDay(CurrentDate()); // For beg of current date
//		PeriodTo = EndOfDay(AddMonth(CurrentDate(), 1)); // Same date of the next month
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
//	ReportBuilder.Parameters.Вставить("qPeriodFrom", PeriodFrom);
//	ReportBuilder.Parameters.Вставить("qForecastPeriodFrom", Max(BegOfDay(CurrentDate()), PeriodFrom));
//	ReportBuilder.Parameters.Вставить("qPeriodTo", PeriodTo);
//	ReportBuilder.Parameters.Вставить("qRoom", ГруппаНомеров);
//	ReportBuilder.Parameters.Вставить("qIsEmptyRoom", НЕ ЗначениеЗаполнено(ГруппаНомеров));
//	ReportBuilder.Parameters.Вставить("qRoomType", RoomType);
//	ReportBuilder.Parameters.Вставить("qIsEmptyRoomType", НЕ ЗначениеЗаполнено(RoomType));
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
//	|	ПродажиКвот.Period AS Period,
//	|	ПродажиКвот.ТипНомера AS ТипНомера,
//	|	ПродажиКвот.CounterClosingBalance AS CounterClosingBalance,
//	|	-ПродажиКвот.RoomsRemainsClosingBalance AS RoomsRemainsClosingBalance,
//	|	-ПродажиКвот.BedsRemainsClosingBalance AS BedsRemainsClosingBalance,
//	|	-ПродажиКвот.RoomsRemainsOpeningBalance AS RoomsRemainsOpeningBalance,
//	|	-ПродажиКвот.BedsRemainsOpeningBalance AS BedsRemainsOpeningBalance
//	|INTO ПродажиКвот
//	|FROM
//	|	AccumulationRegister.ПродажиКвот.BalanceAndTurnovers(
//	|			&qPeriodFrom,
//	|			&qPeriodTo,
//	|			Day,
//	|			RegisterRecordsAndPeriodBoundaries,
//	|			Гостиница IN HIERARCHY (&qHotel)
//	|				AND (НомерРазмещения IN HIERARCHY (&qRoom)
//	|					OR &qIsEmptyRoom)
//	|				AND (ТипНомера IN HIERARCHY (&qRoomType)
//	|					OR &qIsEmptyRoomType)
//	|				AND КвотаНомеров.IsConfirmedBlock
//	|				AND КвотаНомеров.DoWriteOff) AS ПродажиКвот
//	|;
//	|
//	|////////////////////////////////////////////////////////////////////////////////
//	|SELECT
//	|	OccupancyForecast.УчетнаяДата AS УчетнаяДата,
//	|	OccupancyForecast.ТипНомера,
//	|	OccupancyForecast.ВсегоНомеров AS ВсегоНомеров,
//	|	OccupancyForecast.ВсегоМест AS ВсегоМест,
//	|	OccupancyForecast.RoomsAvailable AS RoomsAvailable,
//	|	OccupancyForecast.BedsAvailable AS BedsAvailable,
//	|	OccupancyForecast.ЗабронНомеров AS ЗабронНомеров,
//	|	OccupancyForecast.ЗабронированоМест AS ЗабронированоМест,
//	|	OccupancyForecast.ГарантБроньНомеров AS ГарантБроньНомеров,
//	|	OccupancyForecast.ГарантБроньМест AS ГарантБроньМест,
//	|	OccupancyForecast.NonGuaranteedRoomsReserved AS NonGuaranteedRoomsReserved,
//	|	OccupancyForecast.NonGuaranteedBedsReserved AS NonGuaranteedBedsReserved,
//	|	OccupancyForecast.ИспользованоНомеров AS ИспользованоНомеров,
//	|	OccupancyForecast.ИспользованоМест AS ИспользованоМест,
//	|	OccupancyForecast.RoomsCheckedOut AS RoomsCheckedOut,
//	|	OccupancyForecast.BedsCheckedOut AS BedsCheckedOut,
//	|	OccupancyForecast.НомеровКвота AS НомеровКвота,
//	|	OccupancyForecast.МестКвота AS МестКвота,
//	|	OccupancyForecast.RoomsSold AS RoomsSold,
//	|	OccupancyForecast.BedsSold AS BedsSold,
//	|	OccupancyForecast.RoomsSoldAtMorning AS RoomsSoldAtMorning,
//	|	OccupancyForecast.BedsSoldAtMorning AS BedsSoldAtMorning,
//	|	OccupancyForecast.RoomsRentedPercent AS RoomsRentedPercent,
//	|	OccupancyForecast.BedsRentedPercent AS BedsRentedPercent,
//	|	OccupancyForecast.RoomsOccupancyPercent AS RoomsOccupancyPercent,
//	|	OccupancyForecast.BedsOccupancyPercent AS BedsOccupancyPercent,
//	|	OccupancyForecast.ЗаблокНомеров AS ЗаблокНомеров,
//	|	OccupancyForecast.ЗаблокМест AS ЗаблокМест,
//	|	OccupancyForecast.RoomsVacant AS RoomsVacant,
//	|	OccupancyForecast.BedsVacant AS BedsVacant,
//	|	OccupancyForecast.RoomsVacantWithAllotments AS RoomsVacantWithAllotments,
//	|	OccupancyForecast.BedsVacantWithAllotments AS BedsVacantWithAllotments,
//	|	OccupancyForecast.ЗаездНомеров AS ЗаездНомеров,
//	|	OccupancyForecast.ЗаездМест AS ЗаездМест,
//	|	OccupancyForecast.ЗаездГостей AS ЗаездГостей,
//	|	OccupancyForecast.ExpectedRoomsCheckedIn AS ExpectedRoomsCheckedIn,
//	|	OccupancyForecast.ПланЗаездМест AS ПланЗаездМест,
//	|	OccupancyForecast.ExpectedGuestsCheckedIn AS ExpectedGuestsCheckedIn,
//	|	OccupancyForecast.GuaranteedExpectedRoomsCheckedIn AS GuaranteedExpectedRoomsCheckedIn,
//	|	OccupancyForecast.GuaranteedExpectedBedsCheckedIn AS GuaranteedExpectedBedsCheckedIn,
//	|	OccupancyForecast.GuaranteedExpectedGuestsCheckedIn AS GuaranteedExpectedGuestsCheckedIn,
//	|	OccupancyForecast.NonGuaranteedExpectedRoomsCheckedIn AS NonGuaranteedExpectedRoomsCheckedIn,
//	|	OccupancyForecast.NonGuaranteedExpectedBedsCheckedIn AS NonGuaranteedExpectedBedsCheckedIn,
//	|	OccupancyForecast.NonGuaranteedExpectedGuestsCheckedIn AS NonGuaranteedExpectedGuestsCheckedIn,
//	|	OccupancyForecast.ExpectedRoomsCheckedOut AS ExpectedRoomsCheckedOut,
//	|	OccupancyForecast.ExpectedBedsCheckedOut AS ExpectedBedsCheckedOut,
//	|	OccupancyForecast.ExpectedGuestsCheckedOut AS ExpectedGuestsCheckedOut,
//	|	OccupancyForecast.ЗабронГостей AS ЗабронГостей,
//	|	OccupancyForecast.GuaranteedGuestsReserved AS GuaranteedGuestsReserved,
//	|	OccupancyForecast.NonGuaranteedGuestsReserved AS NonGuaranteedGuestsReserved,
//	|	OccupancyForecast.InHouseGuests AS InHouseGuests,
//	|	OccupancyForecast.GuestsCheckedOut AS GuestsCheckedOut,
//	|	OccupancyForecast.ВсегоГостей AS ВсегоГостей,
//	|	OccupancyForecast.TotalGuestsAtMorning AS TotalGuestsAtMorning,
//	|	OccupancyForecast.RevPAR AS RevPAR,
//	|	OccupancyForecast.RevPAB AS RevPAB,
//	|	OccupancyForecast.RevPARWithoutVAT AS RevPARWithoutVAT,
//	|	OccupancyForecast.RevPABWithoutVAT AS RevPABWithoutVAT,
//	|	OccupancyForecast.AvgRoomPrice AS AvgRoomPrice,
//	|	OccupancyForecast.AvgBedPrice AS AvgBedPrice,
//	|	OccupancyForecast.AvgRoomPriceWithoutVAT AS AvgRoomPriceWithoutVAT,
//	|	OccupancyForecast.AvgBedPriceWithoutVAT AS AvgBedPriceWithoutVAT,
//	|	OccupancyForecast.ПроданоНомеров AS ПроданоНомеров,
//	|	OccupancyForecast.ПроданоМест AS ПроданоМест,
//	|	OccupancyForecast.Продажи AS Продажи,
//	|	OccupancyForecast.ДоходНомеров AS ДоходНомеров,
//	|	OccupancyForecast.ПродажиБезНДС AS ПродажиБезНДС,
//	|	OccupancyForecast.ДоходПродажиБезНДС AS ДоходПродажиБезНДС,
//	|	OccupancyForecast.ForecastSales AS ForecastSales,
//	|	OccupancyForecast.ForecastRoomRevenue AS ForecastRoomRevenue,
//	|	OccupancyForecast.ForecastSalesWithoutVAT AS ForecastSalesWithoutVAT,
//	|	OccupancyForecast.ForecastRoomRevenueWithoutVAT AS ForecastRoomRevenueWithoutVAT,
//	|	OccupancyForecast.InHouseSales AS InHouseSales,
//	|	OccupancyForecast.InHouseRoomRevenue AS InHouseRoomRevenue,
//	|	OccupancyForecast.InHouseSalesWithoutVAT AS InHouseSalesWithoutVAT,
//	|	OccupancyForecast.InHouseRoomRevenueWithoutVAT AS InHouseRoomRevenueWithoutVAT,
//	|	OccupancyForecast.СуммаКомиссии AS СуммаКомиссии,
//	|	OccupancyForecast.КомиссияБезНДС AS КомиссияБезНДС,
//	|	OccupancyForecast.ForecastCommissionSum AS ForecastCommissionSum,
//	|	OccupancyForecast.ForecastCommissionSumWithoutVAT AS ForecastCommissionSumWithoutVAT,
//	|	OccupancyForecast.InHouseCommissionSum AS InHouseCommissionSum,
//	|	OccupancyForecast.InHouseCommissionSumWithoutVAT AS InHouseCommissionSumWithoutVAT,
//	|	OccupancyForecast.СуммаСкидки AS СуммаСкидки,
//	|	OccupancyForecast.СуммаСкидкиБезНДС AS СуммаСкидкиБезНДС,
//	|	OccupancyForecast.ForecastDiscountSum AS ForecastDiscountSum,
//	|	OccupancyForecast.ForecastDiscountSumWithoutVAT AS ForecastDiscountSumWithoutVAT,
//	|	OccupancyForecast.InHouseDiscountSum AS InHouseDiscountSum,
//	|	OccupancyForecast.InHouseDiscountSumWithoutVAT AS InHouseDiscountSumWithoutVAT
//	|{SELECT
//	|	УчетнаяДата,
//	|	ТипНомера.*,
//	|	ВсегоНомеров,
//	|	ВсегоМест,
//	|	RoomsAvailable,
//	|	BedsAvailable,
//	|	ЗабронНомеров,
//	|	ЗабронированоМест,
//	|	ГарантБроньНомеров,
//	|	ГарантБроньМест,
//	|	NonGuaranteedRoomsReserved,
//	|	NonGuaranteedBedsReserved,
//	|	ИспользованоНомеров,
//	|	ИспользованоМест,
//	|	RoomsCheckedOut,
//	|	BedsCheckedOut,
//	|	НомеровКвота,
//	|	МестКвота,
//	|	RoomsSold,
//	|	BedsSold,
//	|	RoomsSoldAtMorning,
//	|	BedsSoldAtMorning,
//	|	RoomsRentedPercent,
//	|	BedsRentedPercent,
//	|	RoomsOccupancyPercent,
//	|	BedsOccupancyPercent,
//	|	ЗаблокНомеров,
//	|	ЗаблокМест,
//	|	RoomsVacant,
//	|	BedsVacant,
//	|	RoomsVacantWithAllotments,
//	|	BedsVacantWithAllotments,
//	|	ЗаездНомеров,
//	|	ЗаездМест,
//	|	ЗаездГостей,
//	|	ExpectedRoomsCheckedIn,
//	|	ПланЗаездМест,
//	|	ExpectedGuestsCheckedIn,
//	|	GuaranteedExpectedRoomsCheckedIn,
//	|	GuaranteedExpectedBedsCheckedIn,
//	|	GuaranteedExpectedGuestsCheckedIn,
//	|	NonGuaranteedExpectedRoomsCheckedIn,
//	|	NonGuaranteedExpectedBedsCheckedIn,
//	|	NonGuaranteedExpectedGuestsCheckedIn,
//	|	ExpectedRoomsCheckedOut,
//	|	ExpectedBedsCheckedOut,
//	|	ExpectedGuestsCheckedOut,
//	|	ЗабронГостей,
//	|	GuaranteedGuestsReserved,
//	|	NonGuaranteedGuestsReserved,
//	|	InHouseGuests,
//	|	GuestsCheckedOut,
//	|	ВсегоГостей,
//	|	TotalGuestsAtMorning,
//	|	ПроданоНомеров,
//	|	ПроданоМест,
//	|	Продажи,
//	|	ДоходНомеров,
//	|	ПродажиБезНДС,
//	|	ДоходПродажиБезНДС,
//	|	RevPAR,
//	|	RevPAB,
//	|	RevPARWithoutVAT,
//	|	RevPABWithoutVAT,
//	|	AvgRoomPrice,
//	|	AvgBedPrice,
//	|	AvgRoomPriceWithoutVAT,
//	|	AvgBedPriceWithoutVAT,
//	|	ForecastSales,
//	|	ForecastRoomRevenue,
//	|	ForecastSalesWithoutVAT,
//	|	ForecastRoomRevenueWithoutVAT,
//	|	InHouseSales,
//	|	InHouseRoomRevenue,
//	|	InHouseSalesWithoutVAT,
//	|	InHouseRoomRevenueWithoutVAT,
//	|	СуммаКомиссии,
//	|	КомиссияБезНДС,
//	|	ForecastCommissionSum,
//	|	ForecastCommissionSumWithoutVAT,
//	|	InHouseCommissionSum,
//	|	InHouseCommissionSumWithoutVAT,
//	|	СуммаСкидки,
//	|	СуммаСкидкиБезНДС,
//	|	ForecastDiscountSum,
//	|	ForecastDiscountSumWithoutVAT,
//	|	InHouseDiscountSum,
//	|	InHouseDiscountSumWithoutVAT,
//	|	(WEEK(OccupancyForecast.УчетнаяДата)) AS AccountingWeek,
//	|	(MONTH(OccupancyForecast.УчетнаяДата)) AS AccountingMonth,
//	|	(QUARTER(OccupancyForecast.УчетнаяДата)) AS AccountingQuarter,
//	|	(YEAR(OccupancyForecast.УчетнаяДата)) AS AccountingYear}
//	|FROM
//	|	(SELECT
//	|		ЗагрузкаНомеров.Period AS УчетнаяДата,
//	|		ЗагрузкаНомеров.ТипНомера AS ТипНомера,
//	|		ЗагрузкаНомеров.CounterClosingBalance AS СчетчикДокКвота,
//	|		ЗагрузкаНомеров.TotalRoomsClosingBalance AS ВсегоНомеров,
//	|		ЗагрузкаНомеров.TotalBedsClosingBalance AS ВсегоМест,
//	|		ЗагрузкаНомеров.TotalRoomsClosingBalance + RoomInventory.RoomsBlockedClosingBalance AS RoomsAvailable,
//	|		ЗагрузкаНомеров.TotalBedsClosingBalance + RoomInventory.BedsBlockedClosingBalance AS BedsAvailable,
//	|		-ЗагрузкаНомеров.RoomsBlockedClosingBalance AS ЗаблокНомеров,
//	|		-ЗагрузкаНомеров.BedsBlockedClosingBalance AS ЗаблокМест,
//	|		-ЗагрузкаНомеров.RoomsReservedClosingBalance AS ЗабронНомеров,
//	|		-ЗагрузкаНомеров.BedsReservedClosingBalance AS ЗабронированоМест,
//	|		-ЗагрузкаНомеров.GuestsReservedClosingBalance AS ЗабронГостей,
//	|		-ЗагрузкаНомеров.GuaranteedRoomsReservedClosingBalance AS ГарантБроньНомеров,
//	|		-ЗагрузкаНомеров.GuaranteedBedsReservedClosingBalance AS ГарантБроньМест,
//	|		-ЗагрузкаНомеров.GuaranteedGuestsReservedClosingBalance AS GuaranteedGuestsReserved,
//	|		-ISNULL(ЗагрузкаНомеров.RoomsReservedClosingBalance, 0) + ISNULL(RoomInventory.GuaranteedRoomsReservedClosingBalance, 0) AS NonGuaranteedRoomsReserved,
//	|		-ISNULL(ЗагрузкаНомеров.BedsReservedClosingBalance, 0) + ISNULL(RoomInventory.GuaranteedBedsReservedClosingBalance, 0) AS NonGuaranteedBedsReserved,
//	|		-ISNULL(ЗагрузкаНомеров.GuestsReservedClosingBalance, 0) + ISNULL(RoomInventory.GuaranteedGuestsReservedClosingBalance, 0) AS NonGuaranteedGuestsReserved,
//	|		-ISNULL(ЗагрузкаНомеров.ExpectedRoomsCheckedInTurnover, 0) AS ExpectedRoomsCheckedIn,
//	|		-ISNULL(ЗагрузкаНомеров.ExpectedBedsCheckedInTurnover, 0) AS ПланЗаездМест,
//	|		-ISNULL(ЗагрузкаНомеров.ExpectedGuestsCheckedInTurnover, 0) AS ExpectedGuestsCheckedIn,
//	|		-ЗагрузкаНомеров.GuaranteedExpectedRoomsCheckedInTurnover AS GuaranteedExpectedRoomsCheckedIn,
//	|		-ЗагрузкаНомеров.GuaranteedExpectedBedsCheckedInTurnover AS GuaranteedExpectedBedsCheckedIn,
//	|		-ЗагрузкаНомеров.GuaranteedExpectedGuestsCheckedInTurnover AS GuaranteedExpectedGuestsCheckedIn,
//	|		-ISNULL(ЗагрузкаНомеров.ExpectedRoomsCheckedInTurnover, 0) + ISNULL(RoomInventory.GuaranteedExpectedRoomsCheckedInTurnover, 0) AS NonGuaranteedExpectedRoomsCheckedIn,
//	|		-ISNULL(ЗагрузкаНомеров.ExpectedBedsCheckedInTurnover, 0) + ISNULL(RoomInventory.GuaranteedExpectedBedsCheckedInTurnover, 0) AS NonGuaranteedExpectedBedsCheckedIn,
//	|		-ISNULL(ЗагрузкаНомеров.ExpectedGuestsCheckedInTurnover, 0) + ISNULL(RoomInventory.GuaranteedExpectedGuestsCheckedInTurnover, 0) AS NonGuaranteedExpectedGuestsCheckedIn,
//	|		-ISNULL(ЗагрузкаНомеров.RoomsCheckedInTurnover, 0) - ISNULL(RoomInventory.ExpectedRoomsCheckedInTurnover, 0) AS ЗаездНомеров,
//	|		-ISNULL(ЗагрузкаНомеров.BedsCheckedInTurnover, 0) - ISNULL(RoomInventory.ExpectedBedsCheckedInTurnover, 0) AS ЗаездМест,
//	|		-ISNULL(ЗагрузкаНомеров.GuestsCheckedInTurnover, 0) - ISNULL(RoomInventory.ExpectedGuestsCheckedInTurnover, 0) AS ЗаездГостей,
//	|		-ISNULL(ЗагрузкаНомеров.InHouseRoomsClosingBalance, 0) - ISNULL(RoomInventory.RoomsReservedClosingBalance, 0) AS ИспользованоНомеров,
//	|		-ISNULL(ЗагрузкаНомеров.InHouseBedsClosingBalance, 0) - ISNULL(RoomInventory.BedsReservedClosingBalance, 0) AS ИспользованоМест,
//	|		-ISNULL(ЗагрузкаНомеров.InHouseGuestsClosingBalance, 0) - ISNULL(RoomInventory.GuestsReservedClosingBalance, 0) AS InHouseGuests,
//	|		CASE
//	|			WHEN ISNULL(ЗагрузкаНомеров.ExpectedGuestsCheckedOutTurnover, 0) <> 0
//	|					AND ISNULL(ЗагрузкаНомеров.GuestsCheckedOutTurnover, 0) = 0
//	|				THEN ISNULL(ЗагрузкаНомеров.ExpectedRoomsCheckedOutTurnover, 0)
//	|			ELSE ISNULL(ЗагрузкаНомеров.RoomsCheckedOutTurnover, 0)
//	|		END AS RoomsCheckedOut,
//	|		CASE
//	|			WHEN ISNULL(ЗагрузкаНомеров.ExpectedGuestsCheckedOutTurnover, 0) <> 0
//	|					AND ISNULL(ЗагрузкаНомеров.GuestsCheckedOutTurnover, 0) = 0
//	|				THEN ISNULL(ЗагрузкаНомеров.ExpectedBedsCheckedOutTurnover, 0)
//	|			ELSE ISNULL(ЗагрузкаНомеров.BedsCheckedOutTurnover, 0)
//	|		END AS BedsCheckedOut,
//	|		CASE
//	|			WHEN ISNULL(ЗагрузкаНомеров.ExpectedGuestsCheckedOutTurnover, 0) <> 0
//	|					AND ISNULL(ЗагрузкаНомеров.GuestsCheckedOutTurnover, 0) = 0
//	|				THEN ISNULL(ЗагрузкаНомеров.ExpectedGuestsCheckedOutTurnover, 0)
//	|			ELSE ISNULL(ЗагрузкаНомеров.GuestsCheckedOutTurnover, 0)
//	|		END AS GuestsCheckedOut,
//	|		ISNULL(ЗагрузкаНомеров.ExpectedRoomsCheckedOutTurnover, 0) AS ExpectedRoomsCheckedOut,
//	|		ISNULL(ЗагрузкаНомеров.ExpectedBedsCheckedOutTurnover, 0) AS ExpectedBedsCheckedOut,
//	|		ISNULL(ЗагрузкаНомеров.ExpectedGuestsCheckedOutTurnover, 0) AS ExpectedGuestsCheckedOut,
//	|		ЗагрузкаНомеров.RoomsVacantClosingBalance AS RoomsVacant,
//	|		ЗагрузкаНомеров.BedsVacantClosingBalance AS BedsVacant,
//	|		ЗагрузкаНомеров.RoomsVacantClosingBalance - ISNULL(ПродажиКвот.RoomsRemainsClosingBalance, 0) AS RoomsVacantWithAllotments,
//	|		ЗагрузкаНомеров.BedsVacantClosingBalance - ISNULL(ПродажиКвот.BedsRemainsClosingBalance, 0) AS BedsVacantWithAllotments,
//	|		ISNULL(ПродажиКвот.CounterClosingBalance, 0) AS RoomsInQuotaCounter,
//	|		-ISNULL(ПродажиКвот.RoomsRemainsClosingBalance, 0) AS НомеровКвота,
//	|		-ISNULL(ПродажиКвот.BedsRemainsClosingBalance, 0) AS МестКвота,
//	|		-ISNULL(ЗагрузкаНомеров.InHouseRoomsClosingBalance, 0) - ISNULL(RoomInventory.RoomsReservedClosingBalance, 0) - ISNULL(ПродажиКвот.RoomsRemainsClosingBalance, 0) AS RoomsSold,
//	|		-ISNULL(ЗагрузкаНомеров.InHouseBedsClosingBalance, 0) - ISNULL(RoomInventory.BedsReservedClosingBalance, 0) - ISNULL(ПродажиКвот.BedsRemainsClosingBalance, 0) AS BedsSold,
//	|		-ISNULL(ЗагрузкаНомеров.InHouseGuestsClosingBalance, 0) - ISNULL(RoomInventory.GuestsReservedClosingBalance, 0) AS ВсегоГостей,
//	|		-ISNULL(ЗагрузкаНомеров.InHouseRoomsOpeningBalance, 0) - ISNULL(RoomInventory.RoomsReservedOpeningBalance, 0) - ISNULL(ПродажиКвот.RoomsRemainsOpeningBalance, 0) AS RoomsSoldAtMorning,
//	|		-ISNULL(ЗагрузкаНомеров.InHouseBedsOpeningBalance, 0) - ISNULL(RoomInventory.BedsReservedOpeningBalance, 0) - ISNULL(ПродажиКвот.BedsRemainsOpeningBalance, 0) AS BedsSoldAtMorning,
//	|		-ISNULL(ЗагрузкаНомеров.InHouseGuestsOpeningBalance, 0) - ISNULL(RoomInventory.GuestsReservedOpeningBalance, 0) AS TotalGuestsAtMorning,
//	|		CASE
//	|			WHEN ISNULL(ЗагрузкаНомеров.TotalRoomsClosingBalance, 0) + ISNULL(RoomInventory.RoomsBlockedClosingBalance, 0) = 0
//	|				THEN 0
//	|			ELSE ISNULL(ОборотыПродажиНомеров.ПроданоНомеров, 0) * 100 / (ISNULL(ЗагрузкаНомеров.TotalRoomsClosingBalance, 0) + ISNULL(RoomInventory.RoomsBlockedClosingBalance, 0))
//	|		END AS RoomsRentedPercent,
//	|		CASE
//	|			WHEN ISNULL(ЗагрузкаНомеров.TotalBedsClosingBalance, 0) + ISNULL(ЗагрузкаНомеров.BedsBlockedClosingBalance, 0) = 0
//	|				THEN 0
//	|			ELSE ISNULL(ОборотыПродажиНомеров.ПроданоМест, 0) * 100 / (ISNULL(ЗагрузкаНомеров.TotalBedsClosingBalance, 0) + ISNULL(RoomInventory.BedsBlockedClosingBalance, 0))
//	|		END AS BedsRentedPercent,
//	|		CASE
//	|			WHEN ISNULL(ЗагрузкаНомеров.TotalRoomsClosingBalance, 0) + ISNULL(RoomInventory.RoomsBlockedClosingBalance, 0) = 0
//	|				THEN 0
//	|			ELSE (-ISNULL(ЗагрузкаНомеров.InHouseRoomsClosingBalance, 0) - ISNULL(RoomInventory.RoomsReservedClosingBalance, 0) - ISNULL(ПродажиКвот.RoomsRemainsClosingBalance, 0)) * 100 / (ISNULL(RoomInventory.TotalRoomsClosingBalance, 0) + ISNULL(RoomInventory.RoomsBlockedClosingBalance, 0))
//	|		END AS RoomsOccupancyPercent,
//	|		CASE
//	|			WHEN ISNULL(ЗагрузкаНомеров.TotalBedsClosingBalance, 0) + ISNULL(RoomInventory.BedsBlockedClosingBalance, 0) = 0
//	|				THEN 0
//	|			ELSE (-ISNULL(ЗагрузкаНомеров.InHouseBedsClosingBalance, 0) - ISNULL(RoomInventory.BedsReservedClosingBalance, 0) - ISNULL(ПродажиКвот.BedsRemainsClosingBalance, 0)) * 100 / (ISNULL(RoomInventory.TotalBedsClosingBalance, 0) + ISNULL(RoomInventory.BedsBlockedClosingBalance, 0))
//	|		END AS BedsOccupancyPercent,
//	|		CASE
//	|			WHEN ISNULL(ЗагрузкаНомеров.TotalRoomsClosingBalance, 0) + ISNULL(RoomInventory.RoomsBlockedClosingBalance, 0) = 0
//	|				THEN 0
//	|			ELSE ISNULL(ОборотыПродажиНомеров.ДоходНомеров, 0) / (ISNULL(ЗагрузкаНомеров.TotalRoomsClosingBalance, 0) + ISNULL(RoomInventory.RoomsBlockedClosingBalance, 0))
//	|		END AS RevPAR,
//	|		CASE
//	|			WHEN ISNULL(ЗагрузкаНомеров.TotalBedsClosingBalance, 0) + ISNULL(RoomInventory.BedsBlockedClosingBalance, 0) = 0
//	|				THEN 0
//	|			ELSE ISNULL(ОборотыПродажиНомеров.ДоходНомеров, 0) / (ISNULL(ЗагрузкаНомеров.TotalBedsClosingBalance, 0) + ISNULL(RoomInventory.BedsBlockedClosingBalance, 0))
//	|		END AS RevPAB,
//	|		CASE
//	|			WHEN ISNULL(ЗагрузкаНомеров.TotalRoomsClosingBalance, 0) + ISNULL(RoomInventory.RoomsBlockedClosingBalance, 0) = 0
//	|				THEN 0
//	|			ELSE ISNULL(ОборотыПродажиНомеров.ДоходПродажиБезНДС, 0) / (ISNULL(ЗагрузкаНомеров.TotalRoomsClosingBalance, 0) + ISNULL(RoomInventory.RoomsBlockedClosingBalance, 0))
//	|		END AS RevPARWithoutVAT,
//	|		CASE
//	|			WHEN ISNULL(ЗагрузкаНомеров.TotalBedsClosingBalance, 0) + ISNULL(RoomInventory.BedsBlockedClosingBalance, 0) = 0
//	|				THEN 0
//	|			ELSE ISNULL(ОборотыПродажиНомеров.ДоходПродажиБезНДС, 0) / (ISNULL(ЗагрузкаНомеров.TotalBedsClosingBalance, 0) + ISNULL(RoomInventory.BedsBlockedClosingBalance, 0))
//	|		END AS RevPABWithoutVAT,
//	|		CASE
//	|			WHEN ISNULL(ЗагрузкаНомеров.TotalRoomsClosingBalance, 0) - ISNULL(RoomInventory.RoomsVacantClosingBalance, 0) = 0
//	|				THEN 0
//	|			ELSE ISNULL(ОборотыПродажиНомеров.ДоходНомеров, 0) / (ISNULL(ЗагрузкаНомеров.TotalRoomsClosingBalance, 0) - ISNULL(RoomInventory.RoomsVacantClosingBalance, 0))
//	|		END AS AvgRoomPrice,
//	|		CASE
//	|			WHEN ISNULL(ЗагрузкаНомеров.TotalBedsClosingBalance, 0) - ISNULL(RoomInventory.BedsVacantClosingBalance, 0) = 0
//	|				THEN 0
//	|			ELSE ISNULL(ОборотыПродажиНомеров.ДоходНомеров, 0) / (ISNULL(ЗагрузкаНомеров.TotalBedsClosingBalance, 0) - ISNULL(RoomInventory.BedsVacantClosingBalance, 0))
//	|		END AS AvgBedPrice,
//	|		CASE
//	|			WHEN ISNULL(ЗагрузкаНомеров.TotalRoomsClosingBalance, 0) - ISNULL(RoomInventory.RoomsVacantClosingBalance, 0) = 0
//	|				THEN 0
//	|			ELSE ISNULL(ОборотыПродажиНомеров.ДоходПродажиБезНДС, 0) / (ISNULL(ЗагрузкаНомеров.TotalRoomsClosingBalance, 0) - ISNULL(RoomInventory.RoomsVacantClosingBalance, 0))
//	|		END AS AvgRoomPriceWithoutVAT,
//	|		CASE
//	|			WHEN ISNULL(ЗагрузкаНомеров.TotalBedsClosingBalance, 0) - ISNULL(RoomInventory.BedsVacantClosingBalance, 0) = 0
//	|				THEN 0
//	|			ELSE ISNULL(ОборотыПродажиНомеров.ДоходПродажиБезНДС, 0) / (ISNULL(ЗагрузкаНомеров.TotalBedsClosingBalance, 0) - ISNULL(RoomInventory.BedsVacantClosingBalance, 0))
//	|		END AS AvgBedPriceWithoutVAT,
//	|		ОборотыПродажиНомеров.ПроданоНомеров AS ПроданоНомеров,
//	|		ОборотыПродажиНомеров.ПроданоМест AS ПроданоМест,
//	|		ОборотыПродажиНомеров.Продажи AS Продажи,
//	|		ОборотыПродажиНомеров.ДоходНомеров AS ДоходНомеров,
//	|		ОборотыПродажиНомеров.ПродажиБезНДС AS ПродажиБезНДС,
//	|		ОборотыПродажиНомеров.ДоходПродажиБезНДС AS ДоходПродажиБезНДС,
//	|		ОборотыПродажиНомеров.ForecastSales AS ForecastSales,
//	|		ОборотыПродажиНомеров.ForecastRoomRevenue AS ForecastRoomRevenue,
//	|		ОборотыПродажиНомеров.ForecastSalesWithoutVAT AS ForecastSalesWithoutVAT,
//	|		ОборотыПродажиНомеров.ForecastRoomRevenueWithoutVAT AS ForecastRoomRevenueWithoutVAT,
//	|		ОборотыПродажиНомеров.InHouseSales AS InHouseSales,
//	|		ОборотыПродажиНомеров.InHouseRoomRevenue AS InHouseRoomRevenue,
//	|		ОборотыПродажиНомеров.InHouseSalesWithoutVAT AS InHouseSalesWithoutVAT,
//	|		ОборотыПродажиНомеров.InHouseRoomRevenueWithoutVAT AS InHouseRoomRevenueWithoutVAT,
//	|		ОборотыПродажиНомеров.СуммаКомиссии AS СуммаКомиссии,
//	|		ОборотыПродажиНомеров.КомиссияБезНДС AS КомиссияБезНДС,
//	|		ОборотыПродажиНомеров.ForecastCommissionSum AS ForecastCommissionSum,
//	|		ОборотыПродажиНомеров.ForecastCommissionSumWithoutVAT AS ForecastCommissionSumWithoutVAT,
//	|		ОборотыПродажиНомеров.InHouseCommissionSum AS InHouseCommissionSum,
//	|		ОборотыПродажиНомеров.InHouseCommissionSumWithoutVAT AS InHouseCommissionSumWithoutVAT,
//	|		ОборотыПродажиНомеров.СуммаСкидки AS СуммаСкидки,
//	|		ОборотыПродажиНомеров.СуммаСкидкиБезНДС AS СуммаСкидкиБезНДС,
//	|		ОборотыПродажиНомеров.ForecastDiscountSum AS ForecastDiscountSum,
//	|		ОборотыПродажиНомеров.ForecastDiscountSumWithoutVAT AS ForecastDiscountSumWithoutVAT,
//	|		ОборотыПродажиНомеров.InHouseDiscountSum AS InHouseDiscountSum,
//	|		ОборотыПродажиНомеров.InHouseDiscountSumWithoutVAT AS InHouseDiscountSumWithoutVAT
//	|	FROM
//	|		AccumulationRegister.ЗагрузкаНомеров.BalanceAndTurnovers(
//	|				&qPeriodFrom,
//	|				&qPeriodTo,
//	|				Day,
//	|				RegisterRecordsAndPeriodBoundaries,
//	|				Гостиница IN HIERARCHY (&qHotel)
//	|					AND (НомерРазмещения IN HIERARCHY (&qRoom)
//	|						OR &qIsEmptyRoom)
//	|					AND (ТипНомера IN HIERARCHY (&qRoomType)
//	|						OR &qIsEmptyRoomType)) AS ЗагрузкаНомеров
//	|			LEFT JOIN ПродажиКвот AS ПродажиКвот
//	|			ON ЗагрузкаНомеров.ТипНомера = ПродажиКвот.ТипНомера
//	|				AND ЗагрузкаНомеров.Period = ПродажиКвот.Period
//	|			LEFT JOIN (SELECT
//	|				RoomPlanFactSales.Period AS Period,
//	|				RoomPlanFactSales.ТипНомера AS ТипНомера,
//	|				SUM(RoomPlanFactSales.ПроданоНомеров) AS ПроданоНомеров,
//	|				SUM(RoomPlanFactSales.ПроданоМест) AS ПроданоМест,
//	|				SUM(RoomPlanFactSales.Продажи) AS Продажи,
//	|				SUM(RoomPlanFactSales.ДоходНомеров) AS ДоходНомеров,
//	|				SUM(RoomPlanFactSales.ПродажиБезНДС) AS ПродажиБезНДС,
//	|				SUM(RoomPlanFactSales.ДоходПродажиБезНДС) AS ДоходПродажиБезНДС,
//	|				SUM(RoomPlanFactSales.InHouseSales) AS InHouseSales,
//	|				SUM(RoomPlanFactSales.InHouseRoomRevenue) AS InHouseRoomRevenue,
//	|				SUM(RoomPlanFactSales.InHouseSalesWithoutVAT) AS InHouseSalesWithoutVAT,
//	|				SUM(RoomPlanFactSales.InHouseRoomRevenueWithoutVAT) AS InHouseRoomRevenueWithoutVAT,
//	|				SUM(RoomPlanFactSales.ForecastSales) AS ForecastSales,
//	|				SUM(RoomPlanFactSales.ForecastRoomRevenue) AS ForecastRoomRevenue,
//	|				SUM(RoomPlanFactSales.ForecastSalesWithoutVAT) AS ForecastSalesWithoutVAT,
//	|				SUM(RoomPlanFactSales.ForecastRoomRevenueWithoutVAT) AS ForecastRoomRevenueWithoutVAT,
//	|				SUM(RoomPlanFactSales.СуммаКомиссии) AS СуммаКомиссии,
//	|				SUM(RoomPlanFactSales.КомиссияБезНДС) AS КомиссияБезНДС,
//	|				SUM(RoomPlanFactSales.InHouseCommissionSum) AS InHouseCommissionSum,
//	|				SUM(RoomPlanFactSales.InHouseCommissionSumWithoutVAT) AS InHouseCommissionSumWithoutVAT,
//	|				SUM(RoomPlanFactSales.ForecastCommissionSum) AS ForecastCommissionSum,
//	|				SUM(RoomPlanFactSales.ForecastCommissionSumWithoutVAT) AS ForecastCommissionSumWithoutVAT,
//	|				SUM(RoomPlanFactSales.СуммаСкидки) AS СуммаСкидки,
//	|				SUM(RoomPlanFactSales.СуммаСкидкиБезНДС) AS СуммаСкидкиБезНДС,
//	|				SUM(RoomPlanFactSales.InHouseDiscountSum) AS InHouseDiscountSum,
//	|				SUM(RoomPlanFactSales.InHouseDiscountSumWithoutVAT) AS InHouseDiscountSumWithoutVAT,
//	|				SUM(RoomPlanFactSales.ForecastDiscountSum) AS ForecastDiscountSum,
//	|				SUM(RoomPlanFactSales.ForecastDiscountSumWithoutVAT) AS ForecastDiscountSumWithoutVAT
//	|			FROM
//	|				(SELECT
//	|					RoomSales.Period AS Period,
//	|					RoomSales.ТипНомера AS ТипНомера,
//	|					RoomSales.RoomsRentedTurnover AS ПроданоНомеров,
//	|					RoomSales.BedsRentedTurnover AS ПроданоМест,
//	|					RoomSales.SalesTurnover AS Продажи,
//	|					RoomSales.RoomRevenueTurnover AS ДоходНомеров,
//	|					RoomSales.SalesWithoutVATTurnover AS ПродажиБезНДС,
//	|					RoomSales.RoomRevenueWithoutVATTurnover AS ДоходПродажиБезНДС,
//	|					RoomSales.SalesTurnover AS InHouseSales,
//	|					RoomSales.RoomRevenueTurnover AS InHouseRoomRevenue,
//	|					RoomSales.SalesWithoutVATTurnover AS InHouseSalesWithoutVAT,
//	|					RoomSales.RoomRevenueWithoutVATTurnover AS InHouseRoomRevenueWithoutVAT,
//	|					0 AS ForecastSales,
//	|					0 AS ForecastRoomRevenue,
//	|					0 AS ForecastSalesWithoutVAT,
//	|					0 AS ForecastRoomRevenueWithoutVAT,
//	|					RoomSales.CommissionSumTurnover AS СуммаКомиссии,
//	|					RoomSales.CommissionSumWithoutVATTurnover AS КомиссияБезНДС,
//	|					RoomSales.CommissionSumTurnover AS InHouseCommissionSum,
//	|					RoomSales.CommissionSumWithoutVATTurnover AS InHouseCommissionSumWithoutVAT,
//	|					0 AS ForecastCommissionSum,
//	|					0 AS ForecastCommissionSumWithoutVAT,
//	|					RoomSales.DiscountSumTurnover AS СуммаСкидки,
//	|					RoomSales.DiscountSumWithoutVATTurnover AS СуммаСкидкиБезНДС,
//	|					RoomSales.DiscountSumTurnover AS InHouseDiscountSum,
//	|					RoomSales.DiscountSumWithoutVATTurnover AS InHouseDiscountSumWithoutVAT,
//	|					0 AS ForecastDiscountSum,
//	|					0 AS ForecastDiscountSumWithoutVAT
//	|				FROM
//	|					AccumulationRegister.Продажи.Turnovers(
//	|							&qPeriodFrom,
//	|							&qPeriodTo,
//	|							Day,
//	|							Гостиница IN HIERARCHY (&qHotel)
//	|								AND (НомерРазмещения IN HIERARCHY (&qRoom)
//	|									OR &qIsEmptyRoom)
//	|								AND (ТипНомера IN HIERARCHY (&qRoomType)
//	|									OR &qIsEmptyRoomType)
//	|								AND (Услуга IN HIERARCHY (&qService)
//	|									OR &qIsEmptyService)
//	|								AND (Услуга IN HIERARCHY (&qServicesList)
//	|									OR NOT &qUseServicesList)) AS RoomSales
//	|				
//	|				UNION ALL
//	|				
//	|				SELECT
//	|					RoomSalesForecast.Period,
//	|					RoomSalesForecast.ТипНомера,
//	|					RoomSalesForecast.RoomsRentedTurnover,
//	|					RoomSalesForecast.BedsRentedTurnover,
//	|					RoomSalesForecast.SalesTurnover,
//	|					RoomSalesForecast.RoomRevenueTurnover,
//	|					RoomSalesForecast.SalesWithoutVATTurnover,
//	|					RoomSalesForecast.RoomRevenueWithoutVATTurnover,
//	|					0,
//	|					0,
//	|					0,
//	|					0,
//	|					RoomSalesForecast.SalesTurnover,
//	|					RoomSalesForecast.RoomRevenueTurnover,
//	|					RoomSalesForecast.SalesWithoutVATTurnover,
//	|					RoomSalesForecast.RoomRevenueWithoutVATTurnover,
//	|					RoomSalesForecast.CommissionSumTurnover,
//	|					RoomSalesForecast.CommissionSumWithoutVATTurnover,
//	|					0,
//	|					0,
//	|					RoomSalesForecast.CommissionSumTurnover,
//	|					RoomSalesForecast.CommissionSumWithoutVATTurnover,
//	|					RoomSalesForecast.DiscountSumTurnover,
//	|					RoomSalesForecast.DiscountSumWithoutVATTurnover,
//	|					0,
//	|					0,
//	|					RoomSalesForecast.DiscountSumTurnover,
//	|					RoomSalesForecast.DiscountSumWithoutVATTurnover
//	|				FROM
//	|					AccumulationRegister.ПрогнозПродаж.Turnovers(
//	|							&qForecastPeriodFrom,
//	|							&qPeriodTo,
//	|							Day,
//	|							Гостиница IN HIERARCHY (&qHotel)
//	|								AND (НомерРазмещения IN HIERARCHY (&qRoom)
//	|									OR &qIsEmptyRoom)
//	|								AND (ТипНомера IN HIERARCHY (&qRoomType)
//	|									OR &qIsEmptyRoomType)
//	|								AND (Услуга IN HIERARCHY (&qService)
//	|									OR &qIsEmptyService)
//	|								AND (Услуга IN HIERARCHY (&qServicesList)
//	|									OR NOT &qUseServicesList)) AS RoomSalesForecast) AS RoomPlanFactSales
//	|			
//	|			GROUP BY
//	|				RoomPlanFactSales.Period,
//	|				RoomPlanFactSales.ТипНомера) AS ОборотыПродажиНомеров
//	|			ON ЗагрузкаНомеров.ТипНомера = ОборотыПродажиНомеров.ТипНомера
//	|				AND ЗагрузкаНомеров.Period = ОборотыПродажиНомеров.Period) AS OccupancyForecast
//	|{WHERE
//	|	OccupancyForecast.ТипНомера.*,
//	|	OccupancyForecast.AccountingDate}
//	|
//	|ORDER BY
//	|	УчетнаяДата,
//	|	OccupancyForecast.ТипНомера.ПорядокСортировки
//	|{ORDER BY
//	|	ТипНомера.*,
//	|	AccountingDate}
//	|TOTALS
//	|	SUM(ВсегоНомеров),
//	|	SUM(ВсегоМест),
//	|	SUM(RoomsAvailable),
//	|	SUM(BedsAvailable),
//	|	SUM(ЗабронНомеров),
//	|	SUM(ЗабронированоМест),
//	|	SUM(ГарантБроньНомеров),
//	|	SUM(ГарантБроньМест),
//	|	SUM(NonGuaranteedRoomsReserved),
//	|	SUM(NonGuaranteedBedsReserved),
//	|	SUM(ИспользованоНомеров),
//	|	SUM(ИспользованоМест),
//	|	SUM(RoomsCheckedOut),
//	|	SUM(BedsCheckedOut),
//	|	SUM(НомеровКвота),
//	|	SUM(МестКвота),
//	|	SUM(RoomsSold),
//	|	SUM(BedsSold),
//	|	SUM(RoomsSoldAtMorning),
//	|	SUM(BedsSoldAtMorning),
//	|	CASE
//	|		WHEN SUM(RoomsAvailable) = 0
//	|			THEN 0
//	|		ELSE SUM(ПроданоНомеров) * 100 / SUM(RoomsAvailable)
//	|	END AS RoomsRentedPercent,
//	|	CASE
//	|		WHEN SUM(BedsAvailable) = 0
//	|			THEN 0
//	|		ELSE SUM(ПроданоМест) * 100 / SUM(BedsAvailable)
//	|	END AS BedsRentedPercent,
//	|	CASE
//	|		WHEN SUM(RoomsAvailable) = 0
//	|			THEN 0
//	|		ELSE SUM(RoomsSold) * 100 / SUM(RoomsAvailable)
//	|	END AS RoomsOccupancyPercent,
//	|	CASE
//	|		WHEN SUM(BedsAvailable) = 0
//	|			THEN 0
//	|		ELSE SUM(BedsSold) * 100 / SUM(BedsAvailable)
//	|	END AS BedsOccupancyPercent,
//	|	SUM(ЗаблокНомеров),
//	|	SUM(ЗаблокМест),
//	|	SUM(RoomsVacant),
//	|	SUM(BedsVacant),
//	|	SUM(RoomsVacantWithAllotments),
//	|	SUM(BedsVacantWithAllotments),
//	|	SUM(ЗаездНомеров),
//	|	SUM(ЗаездМест),
//	|	SUM(ЗаездГостей),
//	|	SUM(ExpectedRoomsCheckedIn),
//	|	SUM(ПланЗаездМест),
//	|	SUM(ExpectedGuestsCheckedIn),
//	|	SUM(GuaranteedExpectedRoomsCheckedIn),
//	|	SUM(GuaranteedExpectedBedsCheckedIn),
//	|	SUM(GuaranteedExpectedGuestsCheckedIn),
//	|	SUM(NonGuaranteedExpectedRoomsCheckedIn),
//	|	SUM(NonGuaranteedExpectedBedsCheckedIn),
//	|	SUM(NonGuaranteedExpectedGuestsCheckedIn),
//	|	SUM(ExpectedRoomsCheckedOut),
//	|	SUM(ExpectedBedsCheckedOut),
//	|	SUM(ExpectedGuestsCheckedOut),
//	|	SUM(ЗабронГостей),
//	|	SUM(GuaranteedGuestsReserved),
//	|	SUM(NonGuaranteedGuestsReserved),
//	|	SUM(InHouseGuests),
//	|	SUM(GuestsCheckedOut),
//	|	SUM(ВсегоГостей),
//	|	SUM(TotalGuestsAtMorning),
//	|	CASE
//	|		WHEN SUM(RoomsAvailable) = 0
//	|			THEN 0
//	|		ELSE SUM(ДоходНомеров) / SUM(RoomsAvailable)
//	|	END AS RevPAR,
//	|	CASE
//	|		WHEN SUM(BedsAvailable) = 0
//	|			THEN 0
//	|		ELSE SUM(ДоходНомеров) / SUM(BedsAvailable)
//	|	END AS RevPAB,
//	|	CASE
//	|		WHEN SUM(RoomsAvailable) = 0
//	|			THEN 0
//	|		ELSE SUM(ДоходПродажиБезНДС) / SUM(RoomsAvailable)
//	|	END AS RevPARWithoutVAT,
//	|	CASE
//	|		WHEN SUM(BedsAvailable) = 0
//	|			THEN 0
//	|		ELSE SUM(ДоходПродажиБезНДС) / SUM(BedsAvailable)
//	|	END AS RevPABWithoutVAT,
//	|	CASE
//	|		WHEN SUM(RoomsSold) = 0
//	|			THEN 0
//	|		ELSE SUM(ДоходНомеров) / SUM(RoomsSold)
//	|	END AS AvgRoomPrice,
//	|	CASE
//	|		WHEN SUM(BedsSold) = 0
//	|			THEN 0
//	|		ELSE SUM(ДоходНомеров) / SUM(BedsSold)
//	|	END AS AvgBedPrice,
//	|	CASE
//	|		WHEN SUM(RoomsSold) = 0
//	|			THEN 0
//	|		ELSE SUM(ДоходПродажиБезНДС) / SUM(RoomsSold)
//	|	END AS AvgRoomPriceWithoutVAT,
//	|	CASE
//	|		WHEN SUM(BedsSold) = 0
//	|			THEN 0
//	|		ELSE SUM(ДоходПродажиБезНДС) / SUM(BedsSold)
//	|	END AS AvgBedPriceWithoutVAT,
//	|	SUM(ПроданоНомеров),
//	|	SUM(ПроданоМест),
//	|	SUM(Продажи),
//	|	SUM(ДоходНомеров),
//	|	SUM(ПродажиБезНДС),
//	|	SUM(ДоходПродажиБезНДС),
//	|	SUM(ForecastSales),
//	|	SUM(ForecastRoomRevenue),
//	|	SUM(ForecastSalesWithoutVAT),
//	|	SUM(ForecastRoomRevenueWithoutVAT),
//	|	SUM(InHouseSales),
//	|	SUM(InHouseRoomRevenue),
//	|	SUM(InHouseSalesWithoutVAT),
//	|	SUM(InHouseRoomRevenueWithoutVAT),
//	|	SUM(СуммаКомиссии),
//	|	SUM(КомиссияБезНДС),
//	|	SUM(ForecastCommissionSum),
//	|	SUM(ForecastCommissionSumWithoutVAT),
//	|	SUM(InHouseCommissionSum),
//	|	SUM(InHouseCommissionSumWithoutVAT),
//	|	SUM(СуммаСкидки),
//	|	SUM(СуммаСкидкиБезНДС),
//	|	SUM(ForecastDiscountSum),
//	|	SUM(ForecastDiscountSumWithoutVAT),
//	|	SUM(InHouseDiscountSum),
//	|	SUM(InHouseDiscountSumWithoutVAT)
//	|BY
//	|	OVERALL,
//	|	УчетнаяДата
//	|{TOTALS BY
//	|	ТипНомера.*,
//	|	УчетнаяДата,
//	|	(WEEK(OccupancyForecast.УчетнаяДата)) AS AccountingWeek,
//	|	(MONTH(OccupancyForecast.УчетнаяДата)) AS AccountingMonth,
//	|	(QUARTER(OccupancyForecast.УчетнаяДата)) AS AccountingQuarter,
//	|	(YEAR(OccupancyForecast.УчетнаяДата)) AS AccountingYear}";
//	ReportBuilder.Text = QueryText;
//	ReportBuilder.FillSettings();
//	
//	// Initialize report builder with default query
//	vRB = New ReportBuilder(QueryText);
//	vRBSettings = vRB.GetSettings(True, True, True, True, True);
//	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
//	
//	// Set default report builder header text
//	ReportBuilder.HeaderText = NStr("EN='ГруппаНомеров inventory occupancy forecast';RU='Прогноз загрузки номерного фонда';de='Prognose zur Zimmerbestandauslastung'");
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
//	   Or pName = "ПродажиБезНДС" 
//	   Or pName = "ДоходПродажиБезНДС" 
//	   Or pName = "ForecastSales" 
//	   Or pName = "ForecastRoomRevenue" 
//	   Or pName = "ForecastSalesWithoutVAT" 
//	   Or pName = "ForecastRoomRevenueWithoutVAT" 
//	   Or pName = "InHouseSales" 
//	   Or pName = "InHouseRoomRevenue" 
//	   Or pName = "InHouseSalesWithoutVAT" 
//	   Or pName = "InHouseRoomRevenueWithoutVAT" 
//	   Or pName = "СуммаКомиссии" 
//	   Or pName = "КомиссияБезНДС" 
//	   Or pName = "ForecastCommissionSum" 
//	   Or pName = "ForecastCommissionSumWithoutVAT" 
//	   Or pName = "InHouseCommissionSum" 
//	   Or pName = "InHouseCommissionSumWithoutVAT" 
//	   Or pName = "СуммаСкидки" 
//	   Or pName = "СуммаСкидкиБезНДС" 
//	   Or pName = "ForecastDiscountSum" 
//	   Or pName = "ForecastDiscountSumWithoutVAT" 
//	   Or pName = "InHouseDiscountSum" 
//	   Or pName = "InHouseDiscountSumWithoutVAT" 
//	   Or pName = "RevPAR" 
//	   Or pName = "RevPAB" 
//	   Or pName = "RevPARWithoutVAT" 
//	   Or pName = "RevPABWithoutVAT" 
//	   Or pName = "AvgRoomPrice" 
//	   Or pName = "AvgBedPrice" 
//	   Or pName = "AvgRoomPriceWithoutVAT" 
//	   Or pName = "AvgBedPriceWithoutVAT" 
//	   Or pName = "ВсегоНомеров"
//	   Or pName = "ВсегоМест"
//	   Or pName = "ВсегоГостей"
//	   Or pName = "TotalGuestsAtMorning"
//	   Or pName = "RoomsRentedPercent"
//	   Or pName = "BedsRentedPercent"
//	   Or pName = "RoomsOccupancyPercent"
//	   Or pName = "BedsOccupancyPercent"
//	   Or pName = "ПроданоНомеров"
//	   Or pName = "ПроданоМест"
//	   Or pName = "ЗаблокНомеров"
//	   Or pName = "ЗаблокМест"
//	   Or pName = "ЗабронНомеров"
//	   Or pName = "ЗабронированоМест"
//	   Or pName = "ЗабронГостей"
//	   Or pName = "ГарантБроньНомеров"
//	   Or pName = "ГарантБроньМест"
//	   Or pName = "GuaranteedGuestsReserved"
//	   Or pName = "NonGuaranteedRoomsReserved"
//	   Or pName = "NonGuaranteedBedsReserved"
//	   Or pName = "NonGuaranteedGuestsReserved"
//	   Or pName = "ЗаездНомеров"
//	   Or pName = "ЗаездМест"
//	   Or pName = "ЗаездГостей"
//	   Or pName = "ИспользованоНомеров"
//	   Or pName = "ИспользованоМест"
//	   Or pName = "InHouseGuests"
//	   Or pName = "RoomsCheckedOut"
//	   Or pName = "BedsCheckedOut"
//	   Or pName = "GuestsCheckedOut"
//	   Or pName = "RoomsVacant"
//	   Or pName = "BedsVacant"
//	   Or pName = "RoomsVacantWithAllotments"
//	   Or pName = "BedsVacantWithAllotments"
//	   Or pName = "RoomsSold"
//	   Or pName = "BedsSold"
//	   Or pName = "RoomsSoldAtMorning"
//	   Or pName = "BedsSoldAtMorning"
//	   Or pName = "ExpectedRoomsCheckedIn"
//	   Or pName = "ПланЗаездМест"
//	   Or pName = "ExpectedGuestsCheckedIn"
//	   Or pName = "GuaranteedExpectedRoomsCheckedIn"
//	   Or pName = "GuaranteedExpectedBedsCheckedIn"
//	   Or pName = "GuaranteedExpectedGuestsCheckedIn"
//	   Or pName = "NonGuaranteedExpectedRoomsCheckedIn"
//	   Or pName = "NonGuaranteedExpectedBedsCheckedIn"
//	   Or pName = "NonGuaranteedExpectedGuestsCheckedIn"
//	   Or pName = "ExpectedRoomsCheckedOut"
//	   Or pName = "ExpectedBedsCheckedOut"
//	   Or pName = "ExpectedGuestsCheckedOut"
//	   Or pName = "НомеровКвота"
//	   Or pName = "МестКвота" Тогда
//		Return True;
//	Else
//		Return False;
//	EndIf;
//EndFunction //pmIsResource
//
////-----------------------------------------------------------------------------
//// Reports framework end
////-----------------------------------------------------------------------------
