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
//	If НЕ ЗначениеЗаполнено(DateFrom) And ЗначениеЗаполнено(DateTo) Тогда
//		vParamPresentation = vParamPresentation + NStr("ru = 'Отбор брони созданной c '; en = 'Reservation date from '") + 
//		                     Format(DateFrom, "DF='dd.MM.yyyy HH:mm:ss'") + 
//		                     ";" + Chars.LF;
//	ElsIf ЗначениеЗаполнено(DateFrom) And НЕ ЗначениеЗаполнено(DateTo) Тогда
//		vParamPresentation = vParamPresentation + NStr("ru = 'Отбор брони созданной по '; en = 'Reservation date to '") + 
//		                     Format(DateTo, "DF='dd.MM.yyyy HH:mm:ss'") + 
//		                     ";" + Chars.LF;
//	ElsIf DateFrom = DateTo And (ЗначениеЗаполнено(DateFrom) Or ЗначениеЗаполнено(DateTo)) Тогда
//		vParamPresentation = vParamPresentation + NStr("ru = 'Отбор брони созданной на '; en = 'Reservation date on '") + 
//		                     Format(DateFrom, "DF='dd.MM.yyyy HH:mm:ss'") + 
//		                     ";" + Chars.LF;
//	ElsIf DateFrom < DateTo And (ЗначениеЗаполнено(DateFrom) Or ЗначениеЗаполнено(DateTo)) Тогда
//		vParamPresentation = vParamPresentation + NStr("ru = 'Отбор брони созданной '; en = 'Reservation date '") + PeriodPresentation(DateFrom, DateTo, cmLocalizationCode()) + 
//		                     ";" + Chars.LF;
//	ElsIf ЗначениеЗаполнено(DateFrom) Or ЗначениеЗаполнено(DateTo) Тогда
//		vParamPresentation = vParamPresentation + NStr("en='Reservation period is wrong!';ru='Неправильно задан период создания брони!';de='Zeitraum der Buchungserstellung ist falsch angegeben!'") + 
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
//	If Rooms2IgnoreList.Count() > 0 Тогда
//		vParamPresentation = vParamPresentation + NStr("ru = 'Исключая номера '; en = 'Ignoring rooms '") + 
//		                     TrimAll(Rooms2IgnoreList) + 
//		                     ";" + Chars.LF;
//	EndIf;
//	If TakeAllotmentsIntoAccount Тогда
//		vParamPresentation = vParamPresentation + NStr("en='Taking allotments into account';ru='С учетом <жестких> блоков';de='Unter Berücksichtigung <fester> Blöcke'") + 
//		                     ";" + Chars.LF;
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
//	ReportBuilder.Parameters.Вставить("qUseForecast", ?(ЗначениеЗаполнено(PeriodTo), ?(PeriodTo > EndOfDay(CurrentDate()-24*3600), True, False), True));
//	ReportBuilder.Parameters.Вставить("qForecastPeriodFrom", Max(BegOfDay(PeriodFrom), BegOfDay(CurrentDate())));
//	ReportBuilder.Parameters.Вставить("qForecastPeriodTo", ?(ЗначениеЗаполнено(PeriodTo), Max(PeriodTo, EndOfDay(CurrentDate()-24*3600)), '00010101'));
//	ReportBuilder.Parameters.Вставить("qDateFrom", DateFrom);
//	ReportBuilder.Parameters.Вставить("qDateTo", DateTo);
//	ReportBuilder.Parameters.Вставить("qDateToIsEmpty", НЕ ЗначениеЗаполнено(DateTo));
//	ReportBuilder.Parameters.Вставить("qFilterByReservationCreationDate", ?(ЗначениеЗаполнено(DateFrom), True, ?(ЗначениеЗаполнено(DateTo), True, False)));
//	ReportBuilder.Parameters.Вставить("qRoom", ГруппаНомеров);
//	ReportBuilder.Parameters.Вставить("qIsEmptyRoom", НЕ ЗначениеЗаполнено(ГруппаНомеров));
//	ReportBuilder.Parameters.Вставить("qRooms2IgnoreList", Rooms2IgnoreList);
//	ReportBuilder.Parameters.Вставить("qRooms2IgnoreListIsEmpty", ?(Rooms2IgnoreList.Count() = 0, True, False));
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
//	ReportBuilder.Parameters.Вставить("qCalendar", Calendar);
//	ReportBuilder.Parameters.Вставить("qUseServicesList", vUseServicesList);
//	ReportBuilder.Parameters.Вставить("qServicesList", vServicesList);
//	ReportBuilder.Parameters.Вставить("qMonday", NStr("en='1. Monday';ru='1. Понедельник';de='1. Montag'"));
//	ReportBuilder.Parameters.Вставить("qTuesday", NStr("en='2. Tuesday';ru='2. Вторник';de='2. Dienstag'"));
//	ReportBuilder.Parameters.Вставить("qWednesday", NStr("en='3. Wednesday';ru='3. Среда';de='3 Mittwoch'"));
//	ReportBuilder.Parameters.Вставить("qThursday", NStr("en='4. Thursday';ru='4. Четверг';de='4. Donnerstag'"));
//	ReportBuilder.Parameters.Вставить("qFriday", NStr("en='5. Friday';ru='5. Пятница';de='5. Freitag'"));
//	ReportBuilder.Parameters.Вставить("qSaturday", NStr("en='6. Saturday';ru='6. Суббота';de='6. Sonnabend'"));
//	ReportBuilder.Parameters.Вставить("qSunday", NStr("en='7. Sunday';ru='7. Воскресенье';de='7. Sonntag'"));
//	
//	vUsePerDayStats = False;
//	vUsePerMonthStats = False;
//	vUsePerPeriodStats = False;
//	vUsePerRoomTypeStats = False;
//	vUseCalendarStats = False;
//	vUseChoosenCalendarStats = False;
//	For Each vReportField In ReportBuilder.SelectedFields Do
//		If Find(vReportField.Name, "PerDay") > 0 Тогда
//			vUsePerDayStats = True;
//		EndIf;			
//		If Find(vReportField.Name, "PerMonth") > 0 Тогда
//			vUsePerMonthStats = True;
//		EndIf;
//		If Find(vReportField.Name, "PerPeriod") > 0 Тогда
//			vUsePerPeriodStats = True;
//		EndIf;
//		If Find(vReportField.Name, "PerRoomType") > 0 Тогда
//			vUsePerRoomTypeStats = True;
//		EndIf;
//		If Find(vReportField.Name, "AndCalendarDayType") > 0 Тогда
//			vUseCalendarStats = True;
//		EndIf;
//		If Find(vReportField.Name, "AndChoosenCalendarDayType") > 0 Тогда
//			vUseChoosenCalendarStats = True;
//		EndIf;
//	EndDo;
//	ReportBuilder.Parameters.Вставить("qUsePerDayStats", vUsePerDayStats);
//	ReportBuilder.Parameters.Вставить("qUsePerMonthStats", vUsePerMonthStats);
//	ReportBuilder.Parameters.Вставить("qUsePerPeriodStats", vUsePerPeriodStats);
//	ReportBuilder.Parameters.Вставить("qUsePerRoomTypeStats", vUsePerRoomTypeStats);
//	ReportBuilder.Parameters.Вставить("qUseCalendarStats", vUseCalendarStats);
//	ReportBuilder.Parameters.Вставить("qUseChoosenCalendarStats", vUseChoosenCalendarStats);
//	ReportBuilder.Parameters.Вставить("qWithAllotments", TakeAllotmentsIntoAccount);
//	ReportBuilder.Parameters.Вставить("qEmptyPriceTag", Справочники.ПризнакЦены.EmptyRef());
//	ReportBuilder.Parameters.Вставить("qBedAccommodationType", cmGetAccommodationTypeBed(Гостиница));
//	ReportBuilder.Parameters.Вставить("qEmptyClientType", Справочники.ClientTypes.EmptyRef());
//	ReportBuilder.Parameters.Вставить("qReportingCurrency", ?(ЗначениеЗаполнено(Гостиница), Гостиница.ReportingCurrency, Справочники.Currencies.FindByCode(643)));
//	ReportBuilder.Parameters.Вставить("qEmptyDate", '00010101');
//	ReportBuilder.Parameters.Вставить("qByGroupCreationDate", ByGroupCreationDate);
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
//	|	ПродажиКвот.Гостиница AS Гостиница,
//	|	ПродажиКвот.Period AS Period,
//	|	ПродажиКвот.КвотаНомеров AS КвотаНомеров,
//	|	ПродажиКвот.ТипНомера AS ТипНомера,
//	|	RoomRatePrices.Услуга AS Услуга,
//	|	RoomRatePrices.СтавкаНДС AS СтавкаНДС,
//	|	КалендарьДень.ТипДеньКалендарь AS ТипДеньКалендарь,
//	|	ПродажиКвот.CounterClosingBalance AS СчетчикДокКвота,
//	|	ПродажиКвот.RoomsInQuotaClosingBalance AS RoomsInQuotaClosingBalance,
//	|	ПродажиКвот.BedsInQuotaClosingBalance AS BedsInQuotaClosingBalance,
//	|	RoomRatePrices.Цена AS AllotmentPrice,
//	|	ПродажиКвот.BedsInQuotaClosingBalance * RoomRatePrices.Цена AS AllotmentAmount
//	|INTO ПродажиКвот
//	|FROM
//	|	AccumulationRegister.ПродажиКвот.BalanceAndTurnovers(
//	|			&qPeriodFrom,
//	|			&qPeriodTo,
//	|			Day,
//	|			RegisterRecordsAndPeriodBoundaries,
//	|			&qWithAllotments
//	|				AND Гостиница IN HIERARCHY (&qHotel)
//	|				AND (НомерРазмещения IN HIERARCHY (&qRoom)
//	|					OR &qIsEmptyRoom)
//	|				AND (ТипНомера IN HIERARCHY (&qRoomType)
//	|					OR &qIsEmptyRoomType)
//	|				AND КвотаНомеров.IsConfirmedBlock
//	|				AND КвотаНомеров.DoWriteOff) AS ПродажиКвот
//	|		LEFT JOIN InformationRegister.КалендарьДень AS КалендарьДень
//	|		ON ПродажиКвот.КвотаНомеров.Тариф.Calendar = КалендарьДень.Calendar
//	|			AND ПродажиКвот.Period = КалендарьДень.Period
//	|		LEFT JOIN InformationRegister.Тарифы.SliceLast(
//	|				&qPeriodTo,
//	|				Гостиница = &qHotel
//	|					AND ПризнакЦены = &qEmptyPriceTag) AS ActiveSetRoomRatePrices
//	|		ON ПродажиКвот.КвотаНомеров.Тариф = ActiveSetRoomRatePrices.Тариф
//	|			AND (КалендарьДень.ТипДеньКалендарь = ActiveSetRoomRatePrices.ТипДеньКалендарь)
//	|		LEFT JOIN InformationRegister.RoomRatePrices AS RoomRatePrices
//	|		ON ПродажиКвот.Гостиница = RoomRatePrices.Гостиница
//	|			AND ПродажиКвот.КвотаНомеров.Тариф = RoomRatePrices.Тариф
//	|			AND (КалендарьДень.ТипДеньКалендарь = RoomRatePrices.ТипДеньКалендарь)
//	|			AND (RoomRatePrices.ПризнакЦены = &qEmptyPriceTag)
//	|			AND (RoomRatePrices.ТипКлиента = &qEmptyClientType)
//	|			AND ПродажиКвот.ТипНомера = RoomRatePrices.ТипНомера
//	|			AND (RoomRatePrices.ВидРазмещения = &qBedAccommodationType)
//	|			AND (RoomRatePrices.ПриказТариф = ActiveSetRoomRatePrices.ПриказТариф)
//	|			AND (RoomRatePrices.Валюта = &qReportingCurrency)
//	|			AND (RoomRatePrices.IsRoomRevenue)
//	|			AND (RoomRatePrices.IsInPrice)
//	|;
//	|
//	|////////////////////////////////////////////////////////////////////////////////
//	|SELECT
//	|	RoomQuotaTotalSales.Гостиница AS Гостиница,
//	|	SUM(RoomQuotaTotalSales.RoomsInQuotaClosingBalance) AS RoomsInQuotaClosingBalance,
//	|	SUM(RoomQuotaTotalSales.BedsInQuotaClosingBalance) AS BedsInQuotaClosingBalance,
//	|	SUM(RoomQuotaTotalSales.AllotmentAmount) AS AllotmentAmount
//	|INTO RoomQuotaTotalSales
//	|FROM
//	|	ПродажиКвот AS RoomQuotaTotalSales
//	|
//	|GROUP BY
//	|	RoomQuotaTotalSales.Гостиница
//	|;
//	|
//	|////////////////////////////////////////////////////////////////////////////////
//	|SELECT
//	|	TotalInventoryBalanceAndTurnovers.Гостиница AS Гостиница,
//	|	SUM(TotalInventoryBalanceAndTurnovers.CounterClosingBalance) AS CounterClosingBalance,
//	|	SUM(TotalInventoryBalanceAndTurnovers.TotalRoomsClosingBalance) AS ВсегоНомеров,
//	|	SUM(TotalInventoryBalanceAndTurnovers.TotalBedsClosingBalance) AS ВсегоМест,
//	|	-SUM(TotalInventoryBalanceAndTurnovers.RoomsBlockedClosingBalance) AS TotalRoomsBlocked,
//	|	-SUM(TotalInventoryBalanceAndTurnovers.BedsBlockedClosingBalance) AS TotalBedsBlocked,
//	|	SUM(TotalInventoryBalanceAndTurnovers.GuestsReservedReceipt) AS TotalGuestsReservedReceipt,
//	|	SUM(TotalInventoryBalanceAndTurnovers.GuestsReservedExpense) AS TotalGuestsReservedExpense,
//	|	SUM(TotalInventoryBalanceAndTurnovers.InHouseGuestsReceipt) AS TotalInHouseGuestsReceipt,
//	|	SUM(TotalInventoryBalanceAndTurnovers.InHouseGuestsExpense) AS TotalInHouseGuestsExpense
//	|INTO HotelInventoryTotals
//	|FROM
//	|	AccumulationRegister.ЗагрузкаНомеров.BalanceAndTurnovers(
//	|			&qPeriodFrom,
//	|			&qPeriodTo,
//	|			Day,
//	|			RegisterRecordsAndPeriodBoundaries,
//	|			Гостиница IN HIERARCHY (&qHotel)
//	|				AND (НомерРазмещения IN HIERARCHY (&qRoom)
//	|					OR &qIsEmptyRoom)
//	|				AND (NOT НомерРазмещения IN (&qRooms2IgnoreList)
//	|					OR &qRooms2IgnoreListIsEmpty)
//	|				AND (ТипНомера IN HIERARCHY (&qRoomType)
//	|					OR &qIsEmptyRoomType)) AS TotalInventoryBalanceAndTurnovers
//	|
//	|GROUP BY
//	|	TotalInventoryBalanceAndTurnovers.Гостиница
//	|;
//	|
//	|////////////////////////////////////////////////////////////////////////////////
//	|SELECT
//	|	RoomInventoryBlocks.Гостиница AS Гостиница,
//	|	RoomInventoryBlocks.НомерРазмещения AS НомерРазмещения,
//	|	SUM(CASE
//	|			WHEN &qPeriodFrom < RoomInventoryBlocks.CheckInDate
//	|					AND (&qPeriodTo < RoomInventoryBlocks.CheckOutDate
//	|						OR RoomInventoryBlocks.CheckOutDate = &qEmptyDate)
//	|				THEN DATEDIFF(RoomInventoryBlocks.CheckInDate, &qPeriodTo, DAY)
//	|			WHEN &qPeriodFrom < RoomInventoryBlocks.CheckInDate
//	|					AND (&qPeriodTo >= RoomInventoryBlocks.CheckOutDate
//	|						AND RoomInventoryBlocks.CheckOutDate <> &qEmptyDate)
//	|				THEN DATEDIFF(RoomInventoryBlocks.CheckInDate, RoomInventoryBlocks.CheckOutDate, DAY)
//	|			WHEN &qPeriodFrom >= RoomInventoryBlocks.CheckInDate
//	|					AND (&qPeriodTo < RoomInventoryBlocks.CheckOutDate
//	|						OR RoomInventoryBlocks.CheckOutDate = &qEmptyDate)
//	|				THEN DATEDIFF(&qPeriodFrom, &qPeriodTo, DAY)
//	|			WHEN &qPeriodFrom >= RoomInventoryBlocks.CheckInDate
//	|					AND (&qPeriodTo >= RoomInventoryBlocks.CheckOutDate
//	|						AND RoomInventoryBlocks.CheckOutDate <> &qEmptyDate)
//	|				THEN DATEDIFF(&qPeriodFrom, RoomInventoryBlocks.CheckOutDate, DAY)
//	|		END) AS ЗаблокНомеров,
//	|	SUM(CASE
//	|			WHEN &qPeriodFrom < RoomInventoryBlocks.CheckInDate
//	|					AND (&qPeriodTo < RoomInventoryBlocks.CheckOutDate
//	|						OR RoomInventoryBlocks.CheckOutDate = &qEmptyDate)
//	|				THEN DATEDIFF(RoomInventoryBlocks.CheckInDate, &qPeriodTo, DAY) * RoomInventoryBlocks.НомерРазмещения.КоличествоМестНомер
//	|			WHEN &qPeriodFrom < RoomInventoryBlocks.CheckInDate
//	|					AND (&qPeriodTo >= RoomInventoryBlocks.CheckOutDate
//	|						AND RoomInventoryBlocks.CheckOutDate <> &qEmptyDate)
//	|				THEN DATEDIFF(RoomInventoryBlocks.CheckInDate, RoomInventoryBlocks.CheckOutDate, DAY) * RoomInventoryBlocks.НомерРазмещения.КоличествоМестНомер
//	|			WHEN &qPeriodFrom >= RoomInventoryBlocks.CheckInDate
//	|					AND (&qPeriodTo < RoomInventoryBlocks.CheckOutDate
//	|						OR RoomInventoryBlocks.CheckOutDate = &qEmptyDate)
//	|				THEN DATEDIFF(&qPeriodFrom, &qPeriodTo, DAY) * RoomInventoryBlocks.НомерРазмещения.КоличествоМестНомер
//	|			WHEN &qPeriodFrom >= RoomInventoryBlocks.CheckInDate
//	|					AND (&qPeriodTo >= RoomInventoryBlocks.CheckOutDate
//	|						AND RoomInventoryBlocks.CheckOutDate <> &qEmptyDate)
//	|				THEN DATEDIFF(&qPeriodFrom, RoomInventoryBlocks.CheckOutDate, DAY) * RoomInventoryBlocks.НомерРазмещения.КоличествоМестНомер
//	|		END) AS ЗаблокМест
//	|INTO RoomInventoryBlocks
//	|FROM
//	|	AccumulationRegister.ЗагрузкаНомеров AS RoomInventoryBlocks
//	|WHERE
//	|	RoomInventoryBlocks.RecordType = VALUE(AccumulationRecordType.Expense)
//	|	AND RoomInventoryBlocks.IsBlocking
//	|	AND (RoomInventoryBlocks.CheckOutDate > &qPeriodFrom
//	|			OR RoomInventoryBlocks.CheckOutDate = &qEmptyDate)
//	|	AND RoomInventoryBlocks.CheckInDate < &qPeriodTo
//	|	AND RoomInventoryBlocks.Гостиница IN HIERARCHY(&qHotel)
//	|	AND (RoomInventoryBlocks.НомерРазмещения IN HIERARCHY (&qRoom)
//	|			OR &qIsEmptyRoom)
//	|	AND (NOT RoomInventoryBlocks.НомерРазмещения IN (&qRooms2IgnoreList)
//	|			OR &qRooms2IgnoreListIsEmpty)
//	|	AND (RoomInventoryBlocks.ТипНомера IN HIERARCHY (&qRoomType)
//	|			OR &qIsEmptyRoomType)
//	|
//	|GROUP BY
//	|	RoomInventoryBlocks.Гостиница,
//	|	RoomInventoryBlocks.НомерРазмещения
//	|;
//	|
//	|////////////////////////////////////////////////////////////////////////////////
//	|SELECT
//	|	TotalRoomInventoryBalanceAndTurnovers.Гостиница AS Гостиница,
//	|	TotalRoomInventoryBalanceAndTurnovers.НомерРазмещения AS НомерРазмещения,
//	|	ISNULL(TotalRoomInventoryBalanceAndTurnovers.TotalRoomsBalance, 0) * (DATEDIFF(&qPeriodFrom, &qPeriodTo, DAY) + 1) AS ВсегоНомеров,
//	|	ISNULL(TotalRoomInventoryBalanceAndTurnovers.TotalRoomsBalance, 0) * (DATEDIFF(&qPeriodFrom, &qPeriodTo, DAY) + 1) * TotalRoomInventoryBalanceAndTurnovers.НомерРазмещения.КоличествоМестНомер AS ВсегоМест,
//	|	ISNULL(RoomInventoryBlocks.ЗаблокНомеров, 0) AS TotalRoomsBlocked,
//	|	ISNULL(RoomInventoryBlocks.ЗаблокМест, 0) AS TotalBedsBlocked
//	|INTO RoomInventoryTotals
//	|FROM
//	|	AccumulationRegister.ЗагрузкаНомеров.Balance(
//	|			&qPeriodFrom,
//	|			Гостиница IN HIERARCHY (&qHotel)
//	|				AND (НомерРазмещения IN HIERARCHY (&qRoom)
//	|					OR &qIsEmptyRoom)
//	|				AND (NOT НомерРазмещения IN (&qRooms2IgnoreList)
//	|					OR &qRooms2IgnoreListIsEmpty)
//	|				AND (ТипНомера IN HIERARCHY (&qRoomType)
//	|					OR &qIsEmptyRoomType)) AS TotalRoomInventoryBalanceAndTurnovers
//	|		LEFT JOIN RoomInventoryBlocks AS RoomInventoryBlocks
//	|		ON TotalRoomInventoryBalanceAndTurnovers.Гостиница = RoomInventoryBlocks.Гостиница
//	|			AND TotalRoomInventoryBalanceAndTurnovers.НомерРазмещения = RoomInventoryBlocks.НомерРазмещения
//	|;
//	|
//	|////////////////////////////////////////////////////////////////////////////////
//	|SELECT
//	|	TotalRoomTypeInventoryBalanceAndTurnoversPerDay.Гостиница AS Гостиница,
//	|	TotalRoomTypeInventoryBalanceAndTurnoversPerDay.ТипНомера AS ТипНомера,
//	|	TotalRoomTypeInventoryBalanceAndTurnoversPerDay.Period AS Period,
//	|	TotalRoomTypeInventoryBalanceAndTurnoversPerDay.CounterClosingBalance AS CounterClosingBalance,
//	|	TotalRoomTypeInventoryBalanceAndTurnoversPerDay.TotalRoomsClosingBalance AS ВсегоНомеров,
//	|	TotalRoomTypeInventoryBalanceAndTurnoversPerDay.TotalBedsClosingBalance AS ВсегоМест,
//	|	-TotalRoomTypeInventoryBalanceAndTurnoversPerDay.RoomsBlockedClosingBalance AS TotalRoomsBlocked,
//	|	-TotalRoomTypeInventoryBalanceAndTurnoversPerDay.BedsBlockedClosingBalance AS TotalBedsBlocked,
//	|	TotalRoomTypeInventoryBalanceAndTurnoversPerDay.GuestsReservedReceipt AS TotalGuestsReservedReceipt,
//	|	TotalRoomTypeInventoryBalanceAndTurnoversPerDay.GuestsReservedExpense AS TotalGuestsReservedExpense,
//	|	TotalRoomTypeInventoryBalanceAndTurnoversPerDay.InHouseGuestsReceipt AS TotalInHouseGuestsReceipt,
//	|	TotalRoomTypeInventoryBalanceAndTurnoversPerDay.InHouseGuestsExpense AS TotalInHouseGuestsExpense
//	|INTO HotelInventoryTotalsPerDay
//	|FROM
//	|	AccumulationRegister.ЗагрузкаНомеров.BalanceAndTurnovers(
//	|			&qPeriodFrom,
//	|			&qPeriodTo,
//	|			Day,
//	|			RegisterRecordsAndPeriodBoundaries,
//	|			&qUsePerDayStats
//	|				AND Гостиница IN HIERARCHY (&qHotel)
//	|				AND (НомерРазмещения IN HIERARCHY (&qRoom)
//	|					OR &qIsEmptyRoom)
//	|				AND (NOT НомерРазмещения IN (&qRooms2IgnoreList)
//	|					OR &qRooms2IgnoreListIsEmpty)
//	|				AND (ТипНомера IN HIERARCHY (&qRoomType)
//	|					OR &qIsEmptyRoomType)) AS TotalRoomTypeInventoryBalanceAndTurnoversPerDay
//	|;
//	|
//	|////////////////////////////////////////////////////////////////////////////////
//	|SELECT
//	|	TotalRoomTypeInventoryBalanceAndTurnoversPerMonth.Гостиница AS Гостиница,
//	|	TotalRoomTypeInventoryBalanceAndTurnoversPerMonth.ТипНомера AS ТипНомера,
//	|	BEGINOFPERIOD(TotalRoomTypeInventoryBalanceAndTurnoversPerMonth.Period, MONTH) AS Period,
//	|	SUM(TotalRoomTypeInventoryBalanceAndTurnoversPerMonth.CounterClosingBalance) AS CounterClosingBalance,
//	|	SUM(TotalRoomTypeInventoryBalanceAndTurnoversPerMonth.TotalRoomsClosingBalance) AS ВсегоНомеров,
//	|	SUM(TotalRoomTypeInventoryBalanceAndTurnoversPerMonth.TotalBedsClosingBalance) AS ВсегоМест,
//	|	-SUM(TotalRoomTypeInventoryBalanceAndTurnoversPerMonth.RoomsBlockedClosingBalance) AS TotalRoomsBlocked,
//	|	-SUM(TotalRoomTypeInventoryBalanceAndTurnoversPerMonth.BedsBlockedClosingBalance) AS TotalBedsBlocked,
//	|	SUM(TotalRoomTypeInventoryBalanceAndTurnoversPerMonth.GuestsReservedReceipt) AS TotalGuestsReservedReceipt,
//	|	SUM(TotalRoomTypeInventoryBalanceAndTurnoversPerMonth.GuestsReservedExpense) AS TotalGuestsReservedExpense,
//	|	SUM(TotalRoomTypeInventoryBalanceAndTurnoversPerMonth.InHouseGuestsReceipt) AS TotalInHouseGuestsReceipt,
//	|	SUM(TotalRoomTypeInventoryBalanceAndTurnoversPerMonth.InHouseGuestsExpense) AS TotalInHouseGuestsExpense
//	|INTO HotelInventoryTotalsPerMonth
//	|FROM
//	|	AccumulationRegister.ЗагрузкаНомеров.BalanceAndTurnovers(
//	|			&qPeriodFrom,
//	|			&qPeriodTo,
//	|			Day,
//	|			RegisterRecordsAndPeriodBoundaries,
//	|			&qUsePerMonthStats
//	|				AND Гостиница IN HIERARCHY (&qHotel)
//	|				AND (НомерРазмещения IN HIERARCHY (&qRoom)
//	|					OR &qIsEmptyRoom)
//	|				AND (NOT НомерРазмещения IN (&qRooms2IgnoreList)
//	|					OR &qRooms2IgnoreListIsEmpty)
//	|				AND (ТипНомера IN HIERARCHY (&qRoomType)
//	|					OR &qIsEmptyRoomType)) AS TotalRoomTypeInventoryBalanceAndTurnoversPerMonth
//	|
//	|GROUP BY
//	|	TotalRoomTypeInventoryBalanceAndTurnoversPerMonth.Гостиница,
//	|	TotalRoomTypeInventoryBalanceAndTurnoversPerMonth.ТипНомера,
//	|	BEGINOFPERIOD(TotalRoomTypeInventoryBalanceAndTurnoversPerMonth.Period, MONTH)
//	|;
//	|
//	|////////////////////////////////////////////////////////////////////////////////
//	|SELECT
//	|	TotalRoomTypeInventoryBalanceAndTurnoversPerPeriod.Гостиница AS Гостиница,
//	|	TotalRoomTypeInventoryBalanceAndTurnoversPerPeriod.ТипНомера AS ТипНомера,
//	|	SUM(TotalRoomTypeInventoryBalanceAndTurnoversPerPeriod.CounterClosingBalance) AS CounterClosingBalance,
//	|	SUM(TotalRoomTypeInventoryBalanceAndTurnoversPerPeriod.TotalRoomsClosingBalance) AS ВсегоНомеров,
//	|	SUM(TotalRoomTypeInventoryBalanceAndTurnoversPerPeriod.TotalBedsClosingBalance) AS ВсегоМест,
//	|	-SUM(TotalRoomTypeInventoryBalanceAndTurnoversPerPeriod.RoomsBlockedClosingBalance) AS TotalRoomsBlocked,
//	|	-SUM(TotalRoomTypeInventoryBalanceAndTurnoversPerPeriod.BedsBlockedClosingBalance) AS TotalBedsBlocked,
//	|	SUM(TotalRoomTypeInventoryBalanceAndTurnoversPerPeriod.GuestsReservedReceipt) AS TotalGuestsReservedReceipt,
//	|	SUM(TotalRoomTypeInventoryBalanceAndTurnoversPerPeriod.GuestsReservedExpense) AS TotalGuestsReservedExpense,
//	|	SUM(TotalRoomTypeInventoryBalanceAndTurnoversPerPeriod.InHouseGuestsReceipt) AS TotalInHouseGuestsReceipt,
//	|	SUM(TotalRoomTypeInventoryBalanceAndTurnoversPerPeriod.InHouseGuestsExpense) AS TotalInHouseGuestsExpense
//	|INTO HotelInventoryTotalsPerPeriod
//	|FROM
//	|	AccumulationRegister.ЗагрузкаНомеров.BalanceAndTurnovers(
//	|			&qPeriodFrom,
//	|			&qPeriodTo,
//	|			Day,
//	|			RegisterRecordsAndPeriodBoundaries,
//	|			&qUsePerPeriodStats
//	|				AND Гостиница IN HIERARCHY (&qHotel)
//	|				AND (НомерРазмещения IN HIERARCHY (&qRoom)
//	|					OR &qIsEmptyRoom)
//	|				AND (NOT НомерРазмещения IN (&qRooms2IgnoreList)
//	|					OR &qRooms2IgnoreListIsEmpty)
//	|				AND (ТипНомера IN HIERARCHY (&qRoomType)
//	|					OR &qIsEmptyRoomType)) AS TotalRoomTypeInventoryBalanceAndTurnoversPerPeriod
//	|
//	|GROUP BY
//	|	TotalRoomTypeInventoryBalanceAndTurnoversPerPeriod.Гостиница,
//	|	TotalRoomTypeInventoryBalanceAndTurnoversPerPeriod.ТипНомера
//	|;
//	|
//	|////////////////////////////////////////////////////////////////////////////////
//	|SELECT
//	|	RoomSalesPerRoomTypePerDay.Гостиница AS Гостиница,
//	|	RoomSalesPerRoomTypePerDay.ТипНомера AS ТипНомера,
//	|	RoomSalesPerRoomTypePerDay.Period AS Period,
//	|	SUM(RoomSalesPerRoomTypePerDay.NumberOfDetailedRows) AS NumberOfDetailedRows
//	|INTO RoomSalesPerRoomTypePerDay
//	|FROM
//	|	(SELECT
//	|		RoomSales.Period AS Period,
//	|		RoomSales.Гостиница AS Гостиница,
//	|		RoomSales.ТипНомера AS ТипНомера,
//	|		RoomSales.NumberOfDetailedRows AS NumberOfDetailedRows
//	|	FROM
//	|		(SELECT
//	|			RoomSalesTotals.Period AS Period,
//	|			RoomSalesTotals.Фирма AS Фирма,
//	|			RoomSalesTotals.Гостиница AS Гостиница,
//	|			RoomSalesTotals.Валюта AS Валюта,
//	|			RoomSalesTotals.НомерРазмещения AS НомерРазмещения,
//	|			RoomSalesTotals.ТипНомера AS ТипНомера,
//	|			RoomSalesTotals.Тариф AS Тариф,
//	|			RoomSalesTotals.ВидРазмещения AS ВидРазмещения,
//	|			RoomSalesTotals.ТипКлиента AS ТипКлиента,
//	|			RoomSalesTotals.МаретингНапрвл AS МаретингНапрвл,
//	|			RoomSalesTotals.ИсточИнфоГостиница AS ИсточИнфоГостиница,
//	|			RoomSalesTotals.Услуга AS Услуга,
//	|			RoomSalesTotals.ТипДеньКалендарь AS ТипДеньКалендарь,
//	|			RoomSalesTotals.ПризнакЦены AS ПризнакЦены,
//	|			RoomSalesTotals.УчетнаяДата AS УчетнаяДата,
//	|			RoomSalesTotals.ДокОснование AS ДокОснование,
//	|			RoomSalesTotals.ДокОснование.КвотаНомеров AS КвотаНомеров,
//	|			RoomSalesTotals.ГруппаГостей AS ГруппаГостей,
//	|			RoomSalesTotals.Контрагент AS Контрагент,
//	|			RoomSalesTotals.Договор AS Договор,
//	|			RoomSalesTotals.Агент AS Агент,
//	|			RoomSalesTotals.Клиент AS Клиент,
//	|			RoomSalesTotals.Ресурс AS Ресурс,
//	|			RoomSalesTotals.СчетПроживания AS СчетПроживания,
//	|			RoomSalesTotals.Цена AS Цена,
//	|			RoomSalesTotals.ТипРесурса AS ТипРесурса,
//	|			RoomSalesTotals.TripPurpose AS TripPurpose,
//	|			RoomSalesTotals.ПутевкаКурсовка AS ПутевкаКурсовка,
//	|			RoomSalesTotals.Автор AS Автор,
//	|			RoomSalesTotals.Скидка AS Скидка,
//	|			RoomSalesTotals.ТипСкидки AS ТипСкидки,
//	|			RoomSalesTotals.ДисконтКарт AS ДисконтКарт,
//	|			RoomSalesTotals.КомиссияАгента AS КомиссияАгента,
//	|			RoomSalesTotals.ВидКомиссииАгента AS ВидКомиссииАгента,
//	|			RoomSalesTotals.СпособОплаты AS СпособОплаты,
//	|			RoomSalesTotals.СтавкаНДС AS СтавкаНДС,
//	|			0 AS СчетчикДокКвота,
//	|			1 AS NumberOfDetailedRows
//	|		FROM
//	|			AccumulationRegister.Продажи.Turnovers(
//	|					&qPeriodFrom,
//	|					&qPeriodTo,
//	|					Day,
//	|					&qUsePerDayStats
//	|						AND &qUsePerRoomTypeStats
//	|						AND Гостиница IN HIERARCHY (&qHotel)
//	|						AND (НомерРазмещения IN HIERARCHY (&qRoom)
//	|							OR &qIsEmptyRoom)
//	|						AND (NOT НомерРазмещения IN (&qRooms2IgnoreList)
//	|							OR &qRooms2IgnoreListIsEmpty)
//	|						AND (ТипНомера IN HIERARCHY (&qRoomType)
//	|							OR &qIsEmptyRoomType)
//	|						AND (Услуга IN HIERARCHY (&qService)
//	|							OR &qIsEmptyService)
//	|						AND (Услуга IN HIERARCHY (&qServicesList)
//	|							OR NOT &qUseServicesList)
//	|						AND (NOT &qWithAllotments
//	|							OR &qWithAllotments
//	|								AND NOT ISNULL(ДокОснование.КвотаНомеров.IsConfirmedBlock, FALSE))
//	|						AND (NOT &qFilterByReservationCreationDate
//	|							OR &qFilterByReservationCreationDate
//	|								AND NOT &qByGroupCreationDate
//	|								AND (ДокОснование.Reservation.ДатаДок IS NULL 
//	|										AND ДокОснование.ДатаДок >= &qDateFrom
//	|									OR NOT ДокОснование.Reservation.ДатаДок IS NULL 
//	|										AND ДокОснование.Reservation.ДатаДок >= &qDateFrom)
//	|								AND (&qDateToIsEmpty
//	|									OR ДокОснование.Reservation.ДатаДок IS NULL 
//	|										AND ДокОснование.ДатаДок <= &qDateTo
//	|									OR NOT ДокОснование.Reservation.ДатаДок IS NULL 
//	|										AND ДокОснование.Reservation.ДатаДок <= &qDateTo)
//	|							OR &qFilterByReservationCreationDate
//	|								AND &qByGroupCreationDate
//	|								AND NOT ГруппаГостей.CreateDate IS NULL 
//	|								AND ГруппаГостей.CreateDate >= &qDateFrom
//	|								AND (&qDateToIsEmpty
//	|									OR ГруппаГостей.CreateDate <= &qDateTo))) AS RoomSalesTotals
//	|		
//	|		UNION ALL
//	|		
//	|		SELECT
//	|			RoomSalesForecastTotals.Period,
//	|			RoomSalesForecastTotals.Фирма,
//	|			RoomSalesForecastTotals.Гостиница,
//	|			RoomSalesForecastTotals.Валюта,
//	|			RoomSalesForecastTotals.НомерРазмещения,
//	|			RoomSalesForecastTotals.ТипНомера,
//	|			RoomSalesForecastTotals.Тариф,
//	|			RoomSalesForecastTotals.ВидРазмещения,
//	|			RoomSalesForecastTotals.ТипКлиента,
//	|			RoomSalesForecastTotals.МаретингНапрвл,
//	|			RoomSalesForecastTotals.ИсточИнфоГостиница,
//	|			RoomSalesForecastTotals.Услуга,
//	|			RoomSalesForecastTotals.ТипДеньКалендарь,
//	|			RoomSalesForecastTotals.ПризнакЦены,
//	|			RoomSalesForecastTotals.УчетнаяДата,
//	|			RoomSalesForecastTotals.ДокОснование,
//	|			RoomSalesForecastTotals.ДокОснование.КвотаНомеров,
//	|			RoomSalesForecastTotals.ГруппаГостей,
//	|			RoomSalesForecastTotals.Контрагент,
//	|			RoomSalesForecastTotals.Договор,
//	|			RoomSalesForecastTotals.Агент,
//	|			RoomSalesForecastTotals.Клиент,
//	|			RoomSalesForecastTotals.Ресурс,
//	|			RoomSalesForecastTotals.СчетПроживания,
//	|			RoomSalesForecastTotals.Цена,
//	|			RoomSalesForecastTotals.ТипРесурса,
//	|			RoomSalesForecastTotals.TripPurpose,
//	|			RoomSalesForecastTotals.ПутевкаКурсовка,
//	|			RoomSalesForecastTotals.Автор,
//	|			RoomSalesForecastTotals.Скидка,
//	|			RoomSalesForecastTotals.ТипСкидки,
//	|			RoomSalesForecastTotals.ДисконтКарт,
//	|			RoomSalesForecastTotals.КомиссияАгента,
//	|			RoomSalesForecastTotals.ВидКомиссииАгента,
//	|			RoomSalesForecastTotals.СпособОплаты,
//	|			RoomSalesForecastTotals.СтавкаНДС,
//	|			0,
//	|			1
//	|		FROM
//	|			AccumulationRegister.ПрогнозПродаж.Turnovers(
//	|					&qForecastPeriodFrom,
//	|					&qForecastPeriodTo,
//	|					Day,
//	|					&qUsePerDayStats
//	|						AND &qUsePerRoomTypeStats
//	|						AND &qUseForecast
//	|						AND Гостиница IN HIERARCHY (&qHotel)
//	|						AND (НомерРазмещения IN HIERARCHY (&qRoom)
//	|							OR &qIsEmptyRoom)
//	|						AND (NOT НомерРазмещения IN (&qRooms2IgnoreList)
//	|							OR &qRooms2IgnoreListIsEmpty)
//	|						AND (ТипНомера IN HIERARCHY (&qRoomType)
//	|							OR &qIsEmptyRoomType)
//	|						AND (Услуга IN HIERARCHY (&qService)
//	|							OR &qIsEmptyService)
//	|						AND (Услуга IN HIERARCHY (&qServicesList)
//	|							OR NOT &qUseServicesList)
//	|						AND (NOT &qWithAllotments
//	|							OR &qWithAllotments
//	|								AND NOT ISNULL(ДокОснование.КвотаНомеров.IsConfirmedBlock, FALSE))
//	|						AND (NOT &qFilterByReservationCreationDate
//	|							OR &qFilterByReservationCreationDate
//	|								AND NOT &qByGroupCreationDate
//	|								AND ДокОснование.ДатаДок >= &qDateFrom
//	|								AND (ДокОснование.ДатаДок <= &qDateTo
//	|									OR &qDateToIsEmpty)
//	|							OR &qFilterByReservationCreationDate
//	|								AND &qByGroupCreationDate
//	|								AND NOT ГруппаГостей.CreateDate IS NULL 
//	|								AND ГруппаГостей.CreateDate >= &qDateFrom
//	|								AND (&qDateToIsEmpty
//	|									OR ГруппаГостей.CreateDate <= &qDateTo))) AS RoomSalesForecastTotals
//	|		
//	|		UNION ALL
//	|		
//	|		SELECT
//	|			RoomTypesListPerDay.Period,
//	|			NULL,
//	|			RoomTypesListPerDay.Гостиница,
//	|			RoomTypesListPerDay.Гостиница.Валюта,
//	|			NULL,
//	|			RoomTypesListPerDay.ТипНомера,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			RoomTypesListPerDay.Period,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			0,
//	|			1
//	|		FROM
//	|			HotelInventoryTotalsPerDay AS RoomTypesListPerDay
//	|		WHERE
//	|			&qUsePerDayStats
//	|			AND &qUsePerRoomTypeStats
//	|		
//	|		UNION ALL
//	|		
//	|		SELECT
//	|			ПродажиКвот.Period,
//	|			ПродажиКвот.Гостиница.Фирма,
//	|			ПродажиКвот.Гостиница,
//	|			ПродажиКвот.Гостиница.Валюта,
//	|			NULL,
//	|			ПродажиКвот.ТипНомера,
//	|			ПродажиКвот.КвотаНомеров.Тариф,
//	|			NULL,
//	|			ПродажиКвот.КвотаНомеров.Контрагент.ТипКлиента,
//	|			ПродажиКвот.КвотаНомеров.Контрагент.МаретингНапрвл,
//	|			ПродажиКвот.КвотаНомеров.Контрагент.ИсточИнфоГостиница,
//	|			ПродажиКвот.Услуга,
//	|			ПродажиКвот.ТипДеньКалендарь,
//	|			NULL,
//	|			ПродажиКвот.Period,
//	|			NULL,
//	|			ПродажиКвот.КвотаНомеров,
//	|			NULL,
//	|			ПродажиКвот.КвотаНомеров.Контрагент,
//	|			ПродажиКвот.КвотаНомеров.Договор,
//	|			ПродажиКвот.КвотаНомеров.Агент,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			ПродажиКвот.AllotmentPrice,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			ПродажиКвот.КвотаНомеров.Тариф.Скидка,
//	|			ПродажиКвот.КвотаНомеров.Тариф.ТипСкидки,
//	|			NULL,
//	|			ПродажиКвот.КвотаНомеров.Агент.КомиссияАгента,
//	|			ПродажиКвот.КвотаНомеров.Агент.ВидКомиссииАгента,
//	|			ПродажиКвот.КвотаНомеров.Контрагент.PlannedPaymentMethod,
//	|			ПродажиКвот.СтавкаНДС,
//	|			ПродажиКвот.СчетчикДокКвота,
//	|			1
//	|		FROM
//	|			ПродажиКвот AS ПродажиКвот
//	|		WHERE
//	|			&qWithAllotments) AS RoomSales) AS RoomSalesPerRoomTypePerDay
//	|
//	|GROUP BY
//	|	RoomSalesPerRoomTypePerDay.Гостиница,
//	|	RoomSalesPerRoomTypePerDay.ТипНомера,
//	|	RoomSalesPerRoomTypePerDay.Period
//	|;
//	|
//	|////////////////////////////////////////////////////////////////////////////////
//	|SELECT
//	|	RoomSalesPerRoomTypePerMonth.Гостиница AS Гостиница,
//	|	RoomSalesPerRoomTypePerMonth.ТипНомера AS ТипНомера,
//	|	BEGINOFPERIOD(RoomSalesPerRoomTypePerMonth.Period, MONTH) AS Period,
//	|	SUM(RoomSalesPerRoomTypePerMonth.NumberOfDetailedRows) AS NumberOfDetailedRows
//	|INTO RoomSalesPerRoomTypePerMonth
//	|FROM
//	|	(SELECT
//	|		RoomSales.Period AS Period,
//	|		RoomSales.Гостиница AS Гостиница,
//	|		RoomSales.ТипНомера AS ТипНомера,
//	|		RoomSales.NumberOfDetailedRows AS NumberOfDetailedRows
//	|	FROM
//	|		(SELECT
//	|			RoomSalesTotals.Period AS Period,
//	|			RoomSalesTotals.Фирма AS Фирма,
//	|			RoomSalesTotals.Гостиница AS Гостиница,
//	|			RoomSalesTotals.Валюта AS Валюта,
//	|			RoomSalesTotals.НомерРазмещения AS НомерРазмещения,
//	|			RoomSalesTotals.ТипНомера AS ТипНомера,
//	|			RoomSalesTotals.Тариф AS Тариф,
//	|			RoomSalesTotals.ВидРазмещения AS ВидРазмещения,
//	|			RoomSalesTotals.ТипКлиента AS ТипКлиента,
//	|			RoomSalesTotals.МаретингНапрвл AS МаретингНапрвл,
//	|			RoomSalesTotals.ИсточИнфоГостиница AS ИсточИнфоГостиница,
//	|			RoomSalesTotals.Услуга AS Услуга,
//	|			RoomSalesTotals.ТипДеньКалендарь AS ТипДеньКалендарь,
//	|			RoomSalesTotals.ПризнакЦены AS ПризнакЦены,
//	|			RoomSalesTotals.УчетнаяДата AS УчетнаяДата,
//	|			RoomSalesTotals.ДокОснование AS ДокОснование,
//	|			RoomSalesTotals.ДокОснование.КвотаНомеров AS КвотаНомеров,
//	|			RoomSalesTotals.ГруппаГостей AS ГруппаГостей,
//	|			RoomSalesTotals.Контрагент AS Контрагент,
//	|			RoomSalesTotals.Договор AS Договор,
//	|			RoomSalesTotals.Агент AS Агент,
//	|			RoomSalesTotals.Клиент AS Клиент,
//	|			RoomSalesTotals.Ресурс AS Ресурс,
//	|			RoomSalesTotals.СчетПроживания AS СчетПроживания,
//	|			RoomSalesTotals.Цена AS Цена,
//	|			RoomSalesTotals.ТипРесурса AS ТипРесурса,
//	|			RoomSalesTotals.TripPurpose AS TripPurpose,
//	|			RoomSalesTotals.ПутевкаКурсовка AS ПутевкаКурсовка,
//	|			RoomSalesTotals.Автор AS Автор,
//	|			RoomSalesTotals.Скидка AS Скидка,
//	|			RoomSalesTotals.ТипСкидки AS ТипСкидки,
//	|			RoomSalesTotals.ДисконтКарт AS ДисконтКарт,
//	|			RoomSalesTotals.КомиссияАгента AS КомиссияАгента,
//	|			RoomSalesTotals.ВидКомиссииАгента AS ВидКомиссииАгента,
//	|			RoomSalesTotals.СпособОплаты AS СпособОплаты,
//	|			RoomSalesTotals.СтавкаНДС AS СтавкаНДС,
//	|			0 AS СчетчикДокКвота,
//	|			1 AS NumberOfDetailedRows
//	|		FROM
//	|			AccumulationRegister.Продажи.Turnovers(
//	|					&qPeriodFrom,
//	|					&qPeriodTo,
//	|					Day,
//	|					&qUsePerMonthStats
//	|						AND &qUsePerRoomTypeStats
//	|						AND Гостиница IN HIERARCHY (&qHotel)
//	|						AND (НомерРазмещения IN HIERARCHY (&qRoom)
//	|							OR &qIsEmptyRoom)
//	|						AND (NOT НомерРазмещения IN (&qRooms2IgnoreList)
//	|							OR &qRooms2IgnoreListIsEmpty)
//	|						AND (ТипНомера IN HIERARCHY (&qRoomType)
//	|							OR &qIsEmptyRoomType)
//	|						AND (Услуга IN HIERARCHY (&qService)
//	|							OR &qIsEmptyService)
//	|						AND (Услуга IN HIERARCHY (&qServicesList)
//	|							OR NOT &qUseServicesList)
//	|						AND (NOT &qWithAllotments
//	|							OR &qWithAllotments
//	|								AND NOT ISNULL(ДокОснование.КвотаНомеров.IsConfirmedBlock, FALSE))
//	|						AND (NOT &qFilterByReservationCreationDate
//	|							OR &qFilterByReservationCreationDate
//	|								AND NOT &qByGroupCreationDate
//	|								AND (ДокОснование.Reservation.ДатаДок IS NULL 
//	|										AND ДокОснование.ДатаДок >= &qDateFrom
//	|									OR NOT ДокОснование.Reservation.ДатаДок IS NULL 
//	|										AND ДокОснование.Reservation.ДатаДок >= &qDateFrom)
//	|								AND (&qDateToIsEmpty
//	|									OR ДокОснование.Reservation.ДатаДок IS NULL 
//	|										AND ДокОснование.ДатаДок <= &qDateTo
//	|									OR NOT ДокОснование.Reservation.ДатаДок IS NULL 
//	|										AND ДокОснование.Reservation.ДатаДок <= &qDateTo)
//	|							OR &qFilterByReservationCreationDate
//	|								AND &qByGroupCreationDate
//	|								AND NOT ГруппаГостей.CreateDate IS NULL 
//	|								AND ГруппаГостей.CreateDate >= &qDateFrom
//	|								AND (&qDateToIsEmpty
//	|									OR ГруппаГостей.CreateDate <= &qDateTo))) AS RoomSalesTotals
//	|		
//	|		UNION ALL
//	|		
//	|		SELECT
//	|			RoomSalesForecastTotals.Period,
//	|			RoomSalesForecastTotals.Фирма,
//	|			RoomSalesForecastTotals.Гостиница,
//	|			RoomSalesForecastTotals.Валюта,
//	|			RoomSalesForecastTotals.НомерРазмещения,
//	|			RoomSalesForecastTotals.ТипНомера,
//	|			RoomSalesForecastTotals.Тариф,
//	|			RoomSalesForecastTotals.ВидРазмещения,
//	|			RoomSalesForecastTotals.ТипКлиента,
//	|			RoomSalesForecastTotals.МаретингНапрвл,
//	|			RoomSalesForecastTotals.ИсточИнфоГостиница,
//	|			RoomSalesForecastTotals.Услуга,
//	|			RoomSalesForecastTotals.ТипДеньКалендарь,
//	|			RoomSalesForecastTotals.ПризнакЦены,
//	|			RoomSalesForecastTotals.УчетнаяДата,
//	|			RoomSalesForecastTotals.ДокОснование,
//	|			RoomSalesForecastTotals.ДокОснование.КвотаНомеров,
//	|			RoomSalesForecastTotals.ГруппаГостей,
//	|			RoomSalesForecastTotals.Контрагент,
//	|			RoomSalesForecastTotals.Договор,
//	|			RoomSalesForecastTotals.Агент,
//	|			RoomSalesForecastTotals.Клиент,
//	|			RoomSalesForecastTotals.Ресурс,
//	|			RoomSalesForecastTotals.СчетПроживания,
//	|			RoomSalesForecastTotals.Цена,
//	|			RoomSalesForecastTotals.ТипРесурса,
//	|			RoomSalesForecastTotals.TripPurpose,
//	|			RoomSalesForecastTotals.ПутевкаКурсовка,
//	|			RoomSalesForecastTotals.Автор,
//	|			RoomSalesForecastTotals.Скидка,
//	|			RoomSalesForecastTotals.ТипСкидки,
//	|			RoomSalesForecastTotals.ДисконтКарт,
//	|			RoomSalesForecastTotals.КомиссияАгента,
//	|			RoomSalesForecastTotals.ВидКомиссииАгента,
//	|			RoomSalesForecastTotals.СпособОплаты,
//	|			RoomSalesForecastTotals.СтавкаНДС,
//	|			0,
//	|			1
//	|		FROM
//	|			AccumulationRegister.ПрогнозПродаж.Turnovers(
//	|					&qForecastPeriodFrom,
//	|					&qForecastPeriodTo,
//	|					Day,
//	|					&qUsePerMonthStats
//	|						AND &qUsePerRoomTypeStats
//	|						AND &qUseForecast
//	|						AND Гостиница IN HIERARCHY (&qHotel)
//	|						AND (НомерРазмещения IN HIERARCHY (&qRoom)
//	|							OR &qIsEmptyRoom)
//	|						AND (NOT НомерРазмещения IN (&qRooms2IgnoreList)
//	|							OR &qRooms2IgnoreListIsEmpty)
//	|						AND (ТипНомера IN HIERARCHY (&qRoomType)
//	|							OR &qIsEmptyRoomType)
//	|						AND (Услуга IN HIERARCHY (&qService)
//	|							OR &qIsEmptyService)
//	|						AND (Услуга IN HIERARCHY (&qServicesList)
//	|							OR NOT &qUseServicesList)
//	|						AND (NOT &qWithAllotments
//	|							OR &qWithAllotments
//	|								AND NOT ISNULL(ДокОснование.КвотаНомеров.IsConfirmedBlock, FALSE))
//	|						AND (NOT &qFilterByReservationCreationDate
//	|							OR &qFilterByReservationCreationDate
//	|								AND NOT &qByGroupCreationDate
//	|								AND ДокОснование.ДатаДок >= &qDateFrom
//	|								AND (ДокОснование.ДатаДок <= &qDateTo
//	|									OR &qDateToIsEmpty)
//	|							OR &qFilterByReservationCreationDate
//	|								AND &qByGroupCreationDate
//	|								AND NOT ГруппаГостей.CreateDate IS NULL 
//	|								AND ГруппаГостей.CreateDate >= &qDateFrom
//	|								AND (&qDateToIsEmpty
//	|									OR ГруппаГостей.CreateDate <= &qDateTo))) AS RoomSalesForecastTotals
//	|		
//	|		UNION ALL
//	|		
//	|		SELECT
//	|			RoomTypesListPerDay.Period,
//	|			NULL,
//	|			RoomTypesListPerDay.Гостиница,
//	|			RoomTypesListPerDay.Гостиница.Валюта,
//	|			NULL,
//	|			RoomTypesListPerDay.ТипНомера,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			RoomTypesListPerDay.Period,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			0,
//	|			1
//	|		FROM
//	|			HotelInventoryTotalsPerDay AS RoomTypesListPerDay
//	|		WHERE
//	|			&qUsePerMonthStats
//	|			AND &qUsePerRoomTypeStats
//	|		
//	|		UNION ALL
//	|		
//	|		SELECT
//	|			ПродажиКвот.Period,
//	|			ПродажиКвот.Гостиница.Фирма,
//	|			ПродажиКвот.Гостиница,
//	|			ПродажиКвот.Гостиница.Валюта,
//	|			NULL,
//	|			ПродажиКвот.ТипНомера,
//	|			ПродажиКвот.КвотаНомеров.Тариф,
//	|			NULL,
//	|			ПродажиКвот.КвотаНомеров.Контрагент.ТипКлиента,
//	|			ПродажиКвот.КвотаНомеров.Контрагент.МаретингНапрвл,
//	|			ПродажиКвот.КвотаНомеров.Контрагент.ИсточИнфоГостиница,
//	|			ПродажиКвот.Услуга,
//	|			ПродажиКвот.ТипДеньКалендарь,
//	|			NULL,
//	|			ПродажиКвот.Period,
//	|			NULL,
//	|			ПродажиКвот.КвотаНомеров,
//	|			NULL,
//	|			ПродажиКвот.КвотаНомеров.Контрагент,
//	|			ПродажиКвот.КвотаНомеров.Договор,
//	|			ПродажиКвот.КвотаНомеров.Агент,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			ПродажиКвот.AllotmentPrice,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			ПродажиКвот.КвотаНомеров.Тариф.Скидка,
//	|			ПродажиКвот.КвотаНомеров.Тариф.ТипСкидки,
//	|			NULL,
//	|			ПродажиКвот.КвотаНомеров.Агент.КомиссияАгента,
//	|			ПродажиКвот.КвотаНомеров.Агент.ВидКомиссииАгента,
//	|			ПродажиКвот.КвотаНомеров.Контрагент.PlannedPaymentMethod,
//	|			ПродажиКвот.СтавкаНДС,
//	|			ПродажиКвот.СчетчикДокКвота,
//	|			1
//	|		FROM
//	|			ПродажиКвот AS ПродажиКвот
//	|		WHERE
//	|			&qWithAllotments) AS RoomSales) AS RoomSalesPerRoomTypePerMonth
//	|
//	|GROUP BY
//	|	RoomSalesPerRoomTypePerMonth.Гостиница,
//	|	RoomSalesPerRoomTypePerMonth.ТипНомера,
//	|	BEGINOFPERIOD(RoomSalesPerRoomTypePerMonth.Period, MONTH)
//	|;
//	|
//	|////////////////////////////////////////////////////////////////////////////////
//	|SELECT
//	|	RoomSalesPerRoomTypePerPeriod.Гостиница AS Гостиница,
//	|	RoomSalesPerRoomTypePerPeriod.ТипНомера AS ТипНомера,
//	|	SUM(RoomSalesPerRoomTypePerPeriod.NumberOfDetailedRows) AS NumberOfDetailedRows
//	|INTO RoomSalesPerRoomTypePerPeriod
//	|FROM
//	|	(SELECT
//	|		RoomSales.Гостиница AS Гостиница,
//	|		RoomSales.ТипНомера AS ТипНомера,
//	|		RoomSales.NumberOfDetailedRows AS NumberOfDetailedRows
//	|	FROM
//	|		(SELECT
//	|			RoomSalesTotals.Period AS Period,
//	|			RoomSalesTotals.Фирма AS Фирма,
//	|			RoomSalesTotals.Гостиница AS Гостиница,
//	|			RoomSalesTotals.Валюта AS Валюта,
//	|			RoomSalesTotals.НомерРазмещения AS НомерРазмещения,
//	|			RoomSalesTotals.ТипНомера AS ТипНомера,
//	|			RoomSalesTotals.Тариф AS Тариф,
//	|			RoomSalesTotals.ВидРазмещения AS ВидРазмещения,
//	|			RoomSalesTotals.ТипКлиента AS ТипКлиента,
//	|			RoomSalesTotals.МаретингНапрвл AS МаретингНапрвл,
//	|			RoomSalesTotals.ИсточИнфоГостиница AS ИсточИнфоГостиница,
//	|			RoomSalesTotals.Услуга AS Услуга,
//	|			RoomSalesTotals.ТипДеньКалендарь AS ТипДеньКалендарь,
//	|			RoomSalesTotals.ПризнакЦены AS ПризнакЦены,
//	|			RoomSalesTotals.УчетнаяДата AS УчетнаяДата,
//	|			RoomSalesTotals.ДокОснование AS ДокОснование,
//	|			RoomSalesTotals.ДокОснование.КвотаНомеров AS КвотаНомеров,
//	|			RoomSalesTotals.ГруппаГостей AS ГруппаГостей,
//	|			RoomSalesTotals.Контрагент AS Контрагент,
//	|			RoomSalesTotals.Договор AS Договор,
//	|			RoomSalesTotals.Агент AS Агент,
//	|			RoomSalesTotals.Клиент AS Клиент,
//	|			RoomSalesTotals.Ресурс AS Ресурс,
//	|			RoomSalesTotals.СчетПроживания AS СчетПроживания,
//	|			RoomSalesTotals.Цена AS Цена,
//	|			RoomSalesTotals.ТипРесурса AS ТипРесурса,
//	|			RoomSalesTotals.TripPurpose AS TripPurpose,
//	|			RoomSalesTotals.ПутевкаКурсовка AS ПутевкаКурсовка,
//	|			RoomSalesTotals.Автор AS Автор,
//	|			RoomSalesTotals.Скидка AS Скидка,
//	|			RoomSalesTotals.ТипСкидки AS ТипСкидки,
//	|			RoomSalesTotals.ДисконтКарт AS ДисконтКарт,
//	|			RoomSalesTotals.КомиссияАгента AS КомиссияАгента,
//	|			RoomSalesTotals.ВидКомиссииАгента AS ВидКомиссииАгента,
//	|			RoomSalesTotals.СпособОплаты AS СпособОплаты,
//	|			RoomSalesTotals.СтавкаНДС AS СтавкаНДС,
//	|			0 AS СчетчикДокКвота,
//	|			1 AS NumberOfDetailedRows
//	|		FROM
//	|			AccumulationRegister.Продажи.Turnovers(
//	|					&qPeriodFrom,
//	|					&qPeriodTo,
//	|					Day,
//	|					&qUsePerPeriodStats
//	|						AND &qUsePerRoomTypeStats
//	|						AND Гостиница IN HIERARCHY (&qHotel)
//	|						AND (НомерРазмещения IN HIERARCHY (&qRoom)
//	|							OR &qIsEmptyRoom)
//	|						AND (NOT НомерРазмещения IN (&qRooms2IgnoreList)
//	|							OR &qRooms2IgnoreListIsEmpty)
//	|						AND (ТипНомера IN HIERARCHY (&qRoomType)
//	|							OR &qIsEmptyRoomType)
//	|						AND (Услуга IN HIERARCHY (&qService)
//	|							OR &qIsEmptyService)
//	|						AND (Услуга IN HIERARCHY (&qServicesList)
//	|							OR NOT &qUseServicesList)
//	|						AND (NOT &qWithAllotments
//	|							OR &qWithAllotments
//	|								AND NOT ISNULL(ДокОснование.КвотаНомеров.IsConfirmedBlock, FALSE))
//	|						AND (NOT &qFilterByReservationCreationDate
//	|							OR &qFilterByReservationCreationDate
//	|								AND NOT &qByGroupCreationDate
//	|								AND (ДокОснование.Reservation.ДатаДок IS NULL 
//	|										AND ДокОснование.ДатаДок >= &qDateFrom
//	|									OR NOT ДокОснование.Reservation.ДатаДок IS NULL 
//	|										AND ДокОснование.Reservation.ДатаДок >= &qDateFrom)
//	|								AND (&qDateToIsEmpty
//	|									OR ДокОснование.Reservation.ДатаДок IS NULL 
//	|										AND ДокОснование.ДатаДок <= &qDateTo
//	|									OR NOT ДокОснование.Reservation.ДатаДок IS NULL 
//	|										AND ДокОснование.Reservation.ДатаДок <= &qDateTo)
//	|							OR &qFilterByReservationCreationDate
//	|								AND &qByGroupCreationDate
//	|								AND NOT ГруппаГостей.CreateDate IS NULL 
//	|								AND ГруппаГостей.CreateDate >= &qDateFrom
//	|								AND (&qDateToIsEmpty
//	|									OR ГруппаГостей.CreateDate <= &qDateTo))) AS RoomSalesTotals
//	|		
//	|		UNION ALL
//	|		
//	|		SELECT
//	|			RoomSalesForecastTotals.Period,
//	|			RoomSalesForecastTotals.Фирма,
//	|			RoomSalesForecastTotals.Гостиница,
//	|			RoomSalesForecastTotals.Валюта,
//	|			RoomSalesForecastTotals.НомерРазмещения,
//	|			RoomSalesForecastTotals.ТипНомера,
//	|			RoomSalesForecastTotals.Тариф,
//	|			RoomSalesForecastTotals.ВидРазмещения,
//	|			RoomSalesForecastTotals.ТипКлиента,
//	|			RoomSalesForecastTotals.МаретингНапрвл,
//	|			RoomSalesForecastTotals.ИсточИнфоГостиница,
//	|			RoomSalesForecastTotals.Услуга,
//	|			RoomSalesForecastTotals.ТипДеньКалендарь,
//	|			RoomSalesForecastTotals.ПризнакЦены,
//	|			RoomSalesForecastTotals.УчетнаяДата,
//	|			RoomSalesForecastTotals.ДокОснование,
//	|			RoomSalesForecastTotals.ДокОснование.КвотаНомеров,
//	|			RoomSalesForecastTotals.ГруппаГостей,
//	|			RoomSalesForecastTotals.Контрагент,
//	|			RoomSalesForecastTotals.Договор,
//	|			RoomSalesForecastTotals.Агент,
//	|			RoomSalesForecastTotals.Клиент,
//	|			RoomSalesForecastTotals.Ресурс,
//	|			RoomSalesForecastTotals.СчетПроживания,
//	|			RoomSalesForecastTotals.Цена,
//	|			RoomSalesForecastTotals.ТипРесурса,
//	|			RoomSalesForecastTotals.TripPurpose,
//	|			RoomSalesForecastTotals.ПутевкаКурсовка,
//	|			RoomSalesForecastTotals.Автор,
//	|			RoomSalesForecastTotals.Скидка,
//	|			RoomSalesForecastTotals.ТипСкидки,
//	|			RoomSalesForecastTotals.ДисконтКарт,
//	|			RoomSalesForecastTotals.КомиссияАгента,
//	|			RoomSalesForecastTotals.ВидКомиссииАгента,
//	|			RoomSalesForecastTotals.СпособОплаты,
//	|			RoomSalesForecastTotals.СтавкаНДС,
//	|			0,
//	|			1
//	|		FROM
//	|			AccumulationRegister.ПрогнозПродаж.Turnovers(
//	|					&qForecastPeriodFrom,
//	|					&qForecastPeriodTo,
//	|					Day,
//	|					&qUsePerPeriodStats
//	|						AND &qUsePerRoomTypeStats
//	|						AND &qUseForecast
//	|						AND Гостиница IN HIERARCHY (&qHotel)
//	|						AND (НомерРазмещения IN HIERARCHY (&qRoom)
//	|							OR &qIsEmptyRoom)
//	|						AND (NOT НомерРазмещения IN (&qRooms2IgnoreList)
//	|							OR &qRooms2IgnoreListIsEmpty)
//	|						AND (ТипНомера IN HIERARCHY (&qRoomType)
//	|							OR &qIsEmptyRoomType)
//	|						AND (Услуга IN HIERARCHY (&qService)
//	|							OR &qIsEmptyService)
//	|						AND (Услуга IN HIERARCHY (&qServicesList)
//	|							OR NOT &qUseServicesList)
//	|						AND (NOT &qWithAllotments
//	|							OR &qWithAllotments
//	|								AND NOT ISNULL(ДокОснование.КвотаНомеров.IsConfirmedBlock, FALSE))
//	|						AND (NOT &qFilterByReservationCreationDate
//	|							OR &qFilterByReservationCreationDate
//	|								AND NOT &qByGroupCreationDate
//	|								AND ДокОснование.ДатаДок >= &qDateFrom
//	|								AND (ДокОснование.ДатаДок <= &qDateTo
//	|									OR &qDateToIsEmpty)
//	|							OR &qFilterByReservationCreationDate
//	|								AND &qByGroupCreationDate
//	|								AND NOT ГруппаГостей.CreateDate IS NULL 
//	|								AND ГруппаГостей.CreateDate >= &qDateFrom
//	|								AND (&qDateToIsEmpty
//	|									OR ГруппаГостей.CreateDate <= &qDateTo))) AS RoomSalesForecastTotals
//	|		
//	|		UNION ALL
//	|		
//	|		SELECT
//	|			RoomTypesListPerDay.Period,
//	|			NULL,
//	|			RoomTypesListPerDay.Гостиница,
//	|			RoomTypesListPerDay.Гостиница.Валюта,
//	|			NULL,
//	|			RoomTypesListPerDay.ТипНомера,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			RoomTypesListPerDay.Period,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			0,
//	|			1
//	|		FROM
//	|			HotelInventoryTotalsPerDay AS RoomTypesListPerDay
//	|		WHERE
//	|			&qUsePerPeriodStats
//	|			AND &qUsePerRoomTypeStats
//	|		
//	|		UNION ALL
//	|		
//	|		SELECT
//	|			ПродажиКвот.Period,
//	|			ПродажиКвот.Гостиница.Фирма,
//	|			ПродажиКвот.Гостиница,
//	|			ПродажиКвот.Гостиница.Валюта,
//	|			NULL,
//	|			ПродажиКвот.ТипНомера,
//	|			ПродажиКвот.КвотаНомеров.Тариф,
//	|			NULL,
//	|			ПродажиКвот.КвотаНомеров.Контрагент.ТипКлиента,
//	|			ПродажиКвот.КвотаНомеров.Контрагент.МаретингНапрвл,
//	|			ПродажиКвот.КвотаНомеров.Контрагент.ИсточИнфоГостиница,
//	|			ПродажиКвот.Услуга,
//	|			ПродажиКвот.ТипДеньКалендарь,
//	|			NULL,
//	|			ПродажиКвот.Period,
//	|			NULL,
//	|			ПродажиКвот.КвотаНомеров,
//	|			NULL,
//	|			ПродажиКвот.КвотаНомеров.Контрагент,
//	|			ПродажиКвот.КвотаНомеров.Договор,
//	|			ПродажиКвот.КвотаНомеров.Агент,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			ПродажиКвот.AllotmentPrice,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			ПродажиКвот.КвотаНомеров.Тариф.Скидка,
//	|			ПродажиКвот.КвотаНомеров.Тариф.ТипСкидки,
//	|			NULL,
//	|			ПродажиКвот.КвотаНомеров.Агент.КомиссияАгента,
//	|			ПродажиКвот.КвотаНомеров.Агент.ВидКомиссииАгента,
//	|			ПродажиКвот.КвотаНомеров.Контрагент.PlannedPaymentMethod,
//	|			ПродажиКвот.СтавкаНДС,
//	|			ПродажиКвот.СчетчикДокКвота,
//	|			1
//	|		FROM
//	|			ПродажиКвот AS ПродажиКвот
//	|		WHERE
//	|			&qWithAllotments) AS RoomSales) AS RoomSalesPerRoomTypePerPeriod
//	|
//	|GROUP BY
//	|	RoomSalesPerRoomTypePerPeriod.Гостиница,
//	|	RoomSalesPerRoomTypePerPeriod.ТипНомера
//	|;
//	|
//	|////////////////////////////////////////////////////////////////////////////////
//	|SELECT
//	|	RoomSalesPerRoomTypeAndCalendarDayTypePerDay.Гостиница AS Гостиница,
//	|	RoomSalesPerRoomTypeAndCalendarDayTypePerDay.ТипНомера AS ТипНомера,
//	|	RoomSalesPerRoomTypeAndCalendarDayTypePerDay.ТипДеньКалендарь AS ТипДеньКалендарь,
//	|	RoomSalesPerRoomTypeAndCalendarDayTypePerDay.Period AS Period,
//	|	SUM(RoomSalesPerRoomTypeAndCalendarDayTypePerDay.NumberOfDetailedRows) AS NumberOfDetailedRows
//	|INTO RoomSalesPerRoomTypeAndCalendarDayTypePerDay
//	|FROM
//	|	(SELECT
//	|		RoomSales.Period AS Period,
//	|		RoomSales.Гостиница AS Гостиница,
//	|		RoomSales.ТипНомера AS ТипНомера,
//	|		RoomSales.Тариф AS Тариф,
//	|		RoomSales.ТипДеньКалендарь AS ТипДеньКалендарь,
//	|		RoomSales.NumberOfDetailedRows AS NumberOfDetailedRows
//	|	FROM
//	|		(SELECT
//	|			RoomSalesTotals.Period AS Period,
//	|			RoomSalesTotals.Фирма AS Фирма,
//	|			RoomSalesTotals.Гостиница AS Гостиница,
//	|			RoomSalesTotals.Валюта AS Валюта,
//	|			RoomSalesTotals.НомерРазмещения AS НомерРазмещения,
//	|			RoomSalesTotals.ТипНомера AS ТипНомера,
//	|			RoomSalesTotals.Тариф AS Тариф,
//	|			RoomSalesTotals.ВидРазмещения AS ВидРазмещения,
//	|			RoomSalesTotals.ТипКлиента AS ТипКлиента,
//	|			RoomSalesTotals.МаретингНапрвл AS МаретингНапрвл,
//	|			RoomSalesTotals.ИсточИнфоГостиница AS ИсточИнфоГостиница,
//	|			RoomSalesTotals.Услуга AS Услуга,
//	|			RoomSalesTotals.ТипДеньКалендарь AS ТипДеньКалендарь,
//	|			RoomSalesTotals.ПризнакЦены AS ПризнакЦены,
//	|			RoomSalesTotals.УчетнаяДата AS УчетнаяДата,
//	|			RoomSalesTotals.ДокОснование AS ДокОснование,
//	|			RoomSalesTotals.ДокОснование.КвотаНомеров AS КвотаНомеров,
//	|			RoomSalesTotals.ГруппаГостей AS ГруппаГостей,
//	|			RoomSalesTotals.Контрагент AS Контрагент,
//	|			RoomSalesTotals.Договор AS Договор,
//	|			RoomSalesTotals.Агент AS Агент,
//	|			RoomSalesTotals.Клиент AS Клиент,
//	|			RoomSalesTotals.Ресурс AS Ресурс,
//	|			RoomSalesTotals.СчетПроживания AS СчетПроживания,
//	|			RoomSalesTotals.Цена AS Цена,
//	|			RoomSalesTotals.ТипРесурса AS ТипРесурса,
//	|			RoomSalesTotals.TripPurpose AS TripPurpose,
//	|			RoomSalesTotals.ПутевкаКурсовка AS ПутевкаКурсовка,
//	|			RoomSalesTotals.Автор AS Автор,
//	|			RoomSalesTotals.Скидка AS Скидка,
//	|			RoomSalesTotals.ТипСкидки AS ТипСкидки,
//	|			RoomSalesTotals.ДисконтКарт AS ДисконтКарт,
//	|			RoomSalesTotals.КомиссияАгента AS КомиссияАгента,
//	|			RoomSalesTotals.ВидКомиссииАгента AS ВидКомиссииАгента,
//	|			RoomSalesTotals.СпособОплаты AS СпособОплаты,
//	|			RoomSalesTotals.СтавкаНДС AS СтавкаНДС,
//	|			0 AS СчетчикДокКвота,
//	|			1 AS NumberOfDetailedRows
//	|		FROM
//	|			AccumulationRegister.Продажи.Turnovers(
//	|					&qPeriodFrom,
//	|					&qPeriodTo,
//	|					Day,
//	|					&qUsePerDayStats
//	|						AND &qUsePerRoomTypeStats
//	|						AND &qUseCalendarStats
//	|						AND Гостиница IN HIERARCHY (&qHotel)
//	|						AND (НомерРазмещения IN HIERARCHY (&qRoom)
//	|							OR &qIsEmptyRoom)
//	|						AND (NOT НомерРазмещения IN (&qRooms2IgnoreList)
//	|							OR &qRooms2IgnoreListIsEmpty)
//	|						AND (ТипНомера IN HIERARCHY (&qRoomType)
//	|							OR &qIsEmptyRoomType)
//	|						AND (Услуга IN HIERARCHY (&qService)
//	|							OR &qIsEmptyService)
//	|						AND (Услуга IN HIERARCHY (&qServicesList)
//	|							OR NOT &qUseServicesList)
//	|						AND (NOT &qWithAllotments
//	|							OR &qWithAllotments
//	|								AND NOT ISNULL(ДокОснование.КвотаНомеров.IsConfirmedBlock, FALSE))
//	|						AND (NOT &qFilterByReservationCreationDate
//	|							OR &qFilterByReservationCreationDate
//	|								AND &qByGroupCreationDate
//	|								AND (ДокОснование.Reservation.ДатаДок IS NULL 
//	|										AND ДокОснование.ДатаДок >= &qDateFrom
//	|									OR NOT ДокОснование.Reservation.ДатаДок IS NULL 
//	|										AND ДокОснование.Reservation.ДатаДок >= &qDateFrom)
//	|								AND (&qDateToIsEmpty
//	|									OR ДокОснование.Reservation.ДатаДок IS NULL 
//	|										AND ДокОснование.ДатаДок <= &qDateTo
//	|									OR NOT ДокОснование.Reservation.ДатаДок IS NULL 
//	|										AND ДокОснование.Reservation.ДатаДок <= &qDateTo)
//	|							OR &qFilterByReservationCreationDate
//	|								AND &qByGroupCreationDate
//	|								AND NOT ГруппаГостей.CreateDate IS NULL 
//	|								AND ГруппаГостей.CreateDate >= &qDateFrom
//	|								AND (&qDateToIsEmpty
//	|									OR ГруппаГостей.CreateDate <= &qDateTo))) AS RoomSalesTotals
//	|		
//	|		UNION ALL
//	|		
//	|		SELECT
//	|			RoomSalesForecastTotals.Period,
//	|			RoomSalesForecastTotals.Фирма,
//	|			RoomSalesForecastTotals.Гостиница,
//	|			RoomSalesForecastTotals.Валюта,
//	|			RoomSalesForecastTotals.НомерРазмещения,
//	|			RoomSalesForecastTotals.ТипНомера,
//	|			RoomSalesForecastTotals.Тариф,
//	|			RoomSalesForecastTotals.ВидРазмещения,
//	|			RoomSalesForecastTotals.ТипКлиента,
//	|			RoomSalesForecastTotals.МаретингНапрвл,
//	|			RoomSalesForecastTotals.ИсточИнфоГостиница,
//	|			RoomSalesForecastTotals.Услуга,
//	|			RoomSalesForecastTotals.ТипДеньКалендарь,
//	|			RoomSalesForecastTotals.ПризнакЦены,
//	|			RoomSalesForecastTotals.УчетнаяДата,
//	|			RoomSalesForecastTotals.ДокОснование,
//	|			RoomSalesForecastTotals.ДокОснование.КвотаНомеров,
//	|			RoomSalesForecastTotals.ГруппаГостей,
//	|			RoomSalesForecastTotals.Контрагент,
//	|			RoomSalesForecastTotals.Договор,
//	|			RoomSalesForecastTotals.Агент,
//	|			RoomSalesForecastTotals.Клиент,
//	|			RoomSalesForecastTotals.Ресурс,
//	|			RoomSalesForecastTotals.СчетПроживания,
//	|			RoomSalesForecastTotals.Цена,
//	|			RoomSalesForecastTotals.ТипРесурса,
//	|			RoomSalesForecastTotals.TripPurpose,
//	|			RoomSalesForecastTotals.ПутевкаКурсовка,
//	|			RoomSalesForecastTotals.Автор,
//	|			RoomSalesForecastTotals.Скидка,
//	|			RoomSalesForecastTotals.ТипСкидки,
//	|			RoomSalesForecastTotals.ДисконтКарт,
//	|			RoomSalesForecastTotals.КомиссияАгента,
//	|			RoomSalesForecastTotals.ВидКомиссииАгента,
//	|			RoomSalesForecastTotals.СпособОплаты,
//	|			RoomSalesForecastTotals.СтавкаНДС,
//	|			0,
//	|			1
//	|		FROM
//	|			AccumulationRegister.ПрогнозПродаж.Turnovers(
//	|					&qForecastPeriodFrom,
//	|					&qForecastPeriodTo,
//	|					Day,
//	|					&qUsePerDayStats
//	|						AND &qUsePerRoomTypeStats
//	|						AND &qUseCalendarStats
//	|						AND &qUseForecast
//	|						AND Гостиница IN HIERARCHY (&qHotel)
//	|						AND (НомерРазмещения IN HIERARCHY (&qRoom)
//	|							OR &qIsEmptyRoom)
//	|						AND (NOT НомерРазмещения IN (&qRooms2IgnoreList)
//	|							OR &qRooms2IgnoreListIsEmpty)
//	|						AND (ТипНомера IN HIERARCHY (&qRoomType)
//	|							OR &qIsEmptyRoomType)
//	|						AND (Услуга IN HIERARCHY (&qService)
//	|							OR &qIsEmptyService)
//	|						AND (Услуга IN HIERARCHY (&qServicesList)
//	|							OR NOT &qUseServicesList)
//	|						AND (NOT &qWithAllotments
//	|							OR &qWithAllotments
//	|								AND NOT ISNULL(ДокОснование.КвотаНомеров.IsConfirmedBlock, FALSE))
//	|						AND (NOT &qFilterByReservationCreationDate
//	|								AND NOT &qByGroupCreationDate
//	|							OR &qFilterByReservationCreationDate
//	|								AND ДокОснование.ДатаДок >= &qDateFrom
//	|								AND (ДокОснование.ДатаДок <= &qDateTo
//	|									OR &qDateToIsEmpty)
//	|							OR &qFilterByReservationCreationDate
//	|								AND &qByGroupCreationDate
//	|								AND NOT ГруппаГостей.CreateDate IS NULL 
//	|								AND ГруппаГостей.CreateDate >= &qDateFrom
//	|								AND (&qDateToIsEmpty
//	|									OR ГруппаГостей.CreateDate <= &qDateTo))) AS RoomSalesForecastTotals
//	|		
//	|		UNION ALL
//	|		
//	|		SELECT
//	|			RoomTypesListPerDay.Period,
//	|			NULL,
//	|			RoomTypesListPerDay.Гостиница,
//	|			RoomTypesListPerDay.Гостиница.Валюта,
//	|			NULL,
//	|			RoomTypesListPerDay.ТипНомера,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			RoomTypesListPerDay.Period,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			0,
//	|			1
//	|		FROM
//	|			HotelInventoryTotalsPerDay AS RoomTypesListPerDay
//	|		WHERE
//	|			&qUsePerDayStats
//	|			AND &qUsePerRoomTypeStats
//	|			AND &qUseCalendarStats
//	|		
//	|		UNION ALL
//	|		
//	|		SELECT
//	|			ПродажиКвот.Period,
//	|			ПродажиКвот.Гостиница.Фирма,
//	|			ПродажиКвот.Гостиница,
//	|			ПродажиКвот.Гостиница.Валюта,
//	|			NULL,
//	|			ПродажиКвот.ТипНомера,
//	|			ПродажиКвот.КвотаНомеров.Тариф,
//	|			NULL,
//	|			ПродажиКвот.КвотаНомеров.Контрагент.ТипКлиента,
//	|			ПродажиКвот.КвотаНомеров.Контрагент.МаретингНапрвл,
//	|			ПродажиКвот.КвотаНомеров.Контрагент.ИсточИнфоГостиница,
//	|			ПродажиКвот.Услуга,
//	|			ПродажиКвот.ТипДеньКалендарь,
//	|			NULL,
//	|			ПродажиКвот.Period,
//	|			NULL,
//	|			ПродажиКвот.КвотаНомеров,
//	|			NULL,
//	|			ПродажиКвот.КвотаНомеров.Контрагент,
//	|			ПродажиКвот.КвотаНомеров.Договор,
//	|			ПродажиКвот.КвотаНомеров.Агент,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			ПродажиКвот.AllotmentPrice,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			ПродажиКвот.КвотаНомеров.Тариф.Скидка,
//	|			ПродажиКвот.КвотаНомеров.Тариф.ТипСкидки,
//	|			NULL,
//	|			ПродажиКвот.КвотаНомеров.Агент.КомиссияАгента,
//	|			ПродажиКвот.КвотаНомеров.Агент.ВидКомиссииАгента,
//	|			ПродажиКвот.КвотаНомеров.Контрагент.PlannedPaymentMethod,
//	|			ПродажиКвот.СтавкаНДС,
//	|			ПродажиКвот.СчетчикДокКвота,
//	|			1
//	|		FROM
//	|			ПродажиКвот AS ПродажиКвот
//	|		WHERE
//	|			&qWithAllotments) AS RoomSales) AS RoomSalesPerRoomTypeAndCalendarDayTypePerDay
//	|
//	|GROUP BY
//	|	RoomSalesPerRoomTypeAndCalendarDayTypePerDay.Гостиница,
//	|	RoomSalesPerRoomTypeAndCalendarDayTypePerDay.ТипНомера,
//	|	RoomSalesPerRoomTypeAndCalendarDayTypePerDay.ТипДеньКалендарь,
//	|	RoomSalesPerRoomTypeAndCalendarDayTypePerDay.Period
//	|;
//	|
//	|////////////////////////////////////////////////////////////////////////////////
//	|SELECT
//	|	RoomSalesPerRoomTypeAndChoosenCalendarDayTypePerDay.Гостиница AS Гостиница,
//	|	RoomSalesPerRoomTypeAndChoosenCalendarDayTypePerDay.ТипНомера AS ТипНомера,
//	|	RoomSalesPerRoomTypeAndChoosenCalendarDayTypePerDay.ТипДеньКалендарь AS ТипДеньКалендарь,
//	|	RoomSalesPerRoomTypeAndChoosenCalendarDayTypePerDay.Period AS Period,
//	|	SUM(RoomSalesPerRoomTypeAndChoosenCalendarDayTypePerDay.NumberOfDetailedRows) AS NumberOfDetailedRows
//	|INTO RoomSalesPerRoomTypeAndChoosenCalendarDayTypePerDay
//	|FROM
//	|	(SELECT
//	|		RoomSales.Period AS Period,
//	|		RoomSales.Гостиница AS Гостиница,
//	|		RoomSales.ТипНомера AS ТипНомера,
//	|		CalendarDayTypesByChoosenCalendar.ТипДеньКалендарь AS ТипДеньКалендарь,
//	|		RoomSales.NumberOfDetailedRows AS NumberOfDetailedRows
//	|	FROM
//	|		(SELECT
//	|			RoomSalesTotals.Period AS Period,
//	|			RoomSalesTotals.Фирма AS Фирма,
//	|			RoomSalesTotals.Гостиница AS Гостиница,
//	|			RoomSalesTotals.Валюта AS Валюта,
//	|			RoomSalesTotals.НомерРазмещения AS НомерРазмещения,
//	|			RoomSalesTotals.ТипНомера AS ТипНомера,
//	|			RoomSalesTotals.Тариф AS Тариф,
//	|			RoomSalesTotals.ВидРазмещения AS ВидРазмещения,
//	|			RoomSalesTotals.ТипКлиента AS ТипКлиента,
//	|			RoomSalesTotals.МаретингНапрвл AS МаретингНапрвл,
//	|			RoomSalesTotals.ИсточИнфоГостиница AS ИсточИнфоГостиница,
//	|			RoomSalesTotals.Услуга AS Услуга,
//	|			RoomSalesTotals.ТипДеньКалендарь AS ТипДеньКалендарь,
//	|			RoomSalesTotals.ПризнакЦены AS ПризнакЦены,
//	|			RoomSalesTotals.УчетнаяДата AS УчетнаяДата,
//	|			RoomSalesTotals.ДокОснование AS ДокОснование,
//	|			RoomSalesTotals.ДокОснование.КвотаНомеров AS КвотаНомеров,
//	|			RoomSalesTotals.ГруппаГостей AS ГруппаГостей,
//	|			RoomSalesTotals.Контрагент AS Контрагент,
//	|			RoomSalesTotals.Договор AS Договор,
//	|			RoomSalesTotals.Агент AS Агент,
//	|			RoomSalesTotals.Клиент AS Клиент,
//	|			RoomSalesTotals.Ресурс AS Ресурс,
//	|			RoomSalesTotals.СчетПроживания AS СчетПроживания,
//	|			RoomSalesTotals.Цена AS Цена,
//	|			RoomSalesTotals.ТипРесурса AS ТипРесурса,
//	|			RoomSalesTotals.TripPurpose AS TripPurpose,
//	|			RoomSalesTotals.ПутевкаКурсовка AS ПутевкаКурсовка,
//	|			RoomSalesTotals.Автор AS Автор,
//	|			RoomSalesTotals.Скидка AS Скидка,
//	|			RoomSalesTotals.ТипСкидки AS ТипСкидки,
//	|			RoomSalesTotals.ДисконтКарт AS ДисконтКарт,
//	|			RoomSalesTotals.КомиссияАгента AS КомиссияАгента,
//	|			RoomSalesTotals.ВидКомиссииАгента AS ВидКомиссииАгента,
//	|			RoomSalesTotals.СпособОплаты AS СпособОплаты,
//	|			RoomSalesTotals.СтавкаНДС AS СтавкаНДС,
//	|			0 AS СчетчикДокКвота,
//	|			1 AS NumberOfDetailedRows
//	|		FROM
//	|			AccumulationRegister.Продажи.Turnovers(
//	|					&qPeriodFrom,
//	|					&qPeriodTo,
//	|					Day,
//	|					&qUsePerDayStats
//	|						AND &qUsePerRoomTypeStats
//	|						AND &qUseChoosenCalendarStats
//	|						AND Гостиница IN HIERARCHY (&qHotel)
//	|						AND (НомерРазмещения IN HIERARCHY (&qRoom)
//	|							OR &qIsEmptyRoom)
//	|						AND (NOT НомерРазмещения IN (&qRooms2IgnoreList)
//	|							OR &qRooms2IgnoreListIsEmpty)
//	|						AND (ТипНомера IN HIERARCHY (&qRoomType)
//	|							OR &qIsEmptyRoomType)
//	|						AND (Услуга IN HIERARCHY (&qService)
//	|							OR &qIsEmptyService)
//	|						AND (Услуга IN HIERARCHY (&qServicesList)
//	|							OR NOT &qUseServicesList)
//	|						AND (NOT &qWithAllotments
//	|							OR &qWithAllotments
//	|								AND NOT ISNULL(ДокОснование.КвотаНомеров.IsConfirmedBlock, FALSE))
//	|						AND (NOT &qFilterByReservationCreationDate
//	|							OR &qFilterByReservationCreationDate
//	|								AND NOT &qByGroupCreationDate
//	|								AND (ДокОснование.Reservation.ДатаДок IS NULL 
//	|										AND ДокОснование.ДатаДок >= &qDateFrom
//	|									OR NOT ДокОснование.Reservation.ДатаДок IS NULL 
//	|										AND ДокОснование.Reservation.ДатаДок >= &qDateFrom)
//	|								AND (&qDateToIsEmpty
//	|									OR ДокОснование.Reservation.ДатаДок IS NULL 
//	|										AND ДокОснование.ДатаДок <= &qDateTo
//	|									OR NOT ДокОснование.Reservation.ДатаДок IS NULL 
//	|										AND ДокОснование.Reservation.ДатаДок <= &qDateTo)
//	|							OR &qFilterByReservationCreationDate
//	|								AND &qByGroupCreationDate
//	|								AND NOT ГруппаГостей.CreateDate IS NULL 
//	|								AND ГруппаГостей.CreateDate >= &qDateFrom
//	|								AND (&qDateToIsEmpty
//	|									OR ГруппаГостей.CreateDate <= &qDateTo))) AS RoomSalesTotals
//	|		
//	|		UNION ALL
//	|		
//	|		SELECT
//	|			RoomSalesForecastTotals.Period,
//	|			RoomSalesForecastTotals.Фирма,
//	|			RoomSalesForecastTotals.Гостиница,
//	|			RoomSalesForecastTotals.Валюта,
//	|			RoomSalesForecastTotals.НомерРазмещения,
//	|			RoomSalesForecastTotals.ТипНомера,
//	|			RoomSalesForecastTotals.Тариф,
//	|			RoomSalesForecastTotals.ВидРазмещения,
//	|			RoomSalesForecastTotals.ТипКлиента,
//	|			RoomSalesForecastTotals.МаретингНапрвл,
//	|			RoomSalesForecastTotals.ИсточИнфоГостиница,
//	|			RoomSalesForecastTotals.Услуга,
//	|			RoomSalesForecastTotals.ТипДеньКалендарь,
//	|			RoomSalesForecastTotals.ПризнакЦены,
//	|			RoomSalesForecastTotals.УчетнаяДата,
//	|			RoomSalesForecastTotals.ДокОснование,
//	|			RoomSalesForecastTotals.ДокОснование.КвотаНомеров,
//	|			RoomSalesForecastTotals.ГруппаГостей,
//	|			RoomSalesForecastTotals.Контрагент,
//	|			RoomSalesForecastTotals.Договор,
//	|			RoomSalesForecastTotals.Агент,
//	|			RoomSalesForecastTotals.Клиент,
//	|			RoomSalesForecastTotals.Ресурс,
//	|			RoomSalesForecastTotals.СчетПроживания,
//	|			RoomSalesForecastTotals.Цена,
//	|			RoomSalesForecastTotals.ТипРесурса,
//	|			RoomSalesForecastTotals.TripPurpose,
//	|			RoomSalesForecastTotals.ПутевкаКурсовка,
//	|			RoomSalesForecastTotals.Автор,
//	|			RoomSalesForecastTotals.Скидка,
//	|			RoomSalesForecastTotals.ТипСкидки,
//	|			RoomSalesForecastTotals.ДисконтКарт,
//	|			RoomSalesForecastTotals.КомиссияАгента,
//	|			RoomSalesForecastTotals.ВидКомиссииАгента,
//	|			RoomSalesForecastTotals.СпособОплаты,
//	|			RoomSalesForecastTotals.СтавкаНДС,
//	|			0,
//	|			1
//	|		FROM
//	|			AccumulationRegister.ПрогнозПродаж.Turnovers(
//	|					&qForecastPeriodFrom,
//	|					&qForecastPeriodTo,
//	|					Day,
//	|					&qUsePerDayStats
//	|						AND &qUsePerRoomTypeStats
//	|						AND &qUseChoosenCalendarStats
//	|						AND &qUseForecast
//	|						AND Гостиница IN HIERARCHY (&qHotel)
//	|						AND (НомерРазмещения IN HIERARCHY (&qRoom)
//	|							OR &qIsEmptyRoom)
//	|						AND (NOT НомерРазмещения IN (&qRooms2IgnoreList)
//	|							OR &qRooms2IgnoreListIsEmpty)
//	|						AND (ТипНомера IN HIERARCHY (&qRoomType)
//	|							OR &qIsEmptyRoomType)
//	|						AND (Услуга IN HIERARCHY (&qService)
//	|							OR &qIsEmptyService)
//	|						AND (Услуга IN HIERARCHY (&qServicesList)
//	|							OR NOT &qUseServicesList)
//	|						AND (NOT &qWithAllotments
//	|							OR &qWithAllotments
//	|								AND NOT ISNULL(ДокОснование.КвотаНомеров.IsConfirmedBlock, FALSE))
//	|						AND (NOT &qFilterByReservationCreationDate
//	|							OR &qFilterByReservationCreationDate
//	|								AND NOT &qByGroupCreationDate
//	|								AND ДокОснование.ДатаДок >= &qDateFrom
//	|								AND (ДокОснование.ДатаДок <= &qDateTo
//	|									OR &qDateToIsEmpty)
//	|							OR &qFilterByReservationCreationDate
//	|								AND &qByGroupCreationDate
//	|								AND NOT ГруппаГостей.CreateDate IS NULL 
//	|								AND ГруппаГостей.CreateDate >= &qDateFrom
//	|								AND (&qDateToIsEmpty
//	|									OR ГруппаГостей.CreateDate <= &qDateTo))) AS RoomSalesForecastTotals
//	|		
//	|		UNION ALL
//	|		
//	|		SELECT
//	|			RoomTypesListPerDay.Period,
//	|			NULL,
//	|			RoomTypesListPerDay.Гостиница,
//	|			RoomTypesListPerDay.Гостиница.Валюта,
//	|			NULL,
//	|			RoomTypesListPerDay.ТипНомера,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			RoomTypesListPerDay.Period,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			0,
//	|			1
//	|		FROM
//	|			HotelInventoryTotalsPerDay AS RoomTypesListPerDay
//	|		WHERE
//	|			&qUsePerDayStats
//	|			AND &qUsePerRoomTypeStats
//	|			AND &qUseChoosenCalendarStats
//	|		
//	|		UNION ALL
//	|		
//	|		SELECT
//	|			ПродажиКвот.Period,
//	|			ПродажиКвот.Гостиница.Фирма,
//	|			ПродажиКвот.Гостиница,
//	|			ПродажиКвот.Гостиница.Валюта,
//	|			NULL,
//	|			ПродажиКвот.ТипНомера,
//	|			ПродажиКвот.КвотаНомеров.Тариф,
//	|			NULL,
//	|			ПродажиКвот.КвотаНомеров.Контрагент.ТипКлиента,
//	|			ПродажиКвот.КвотаНомеров.Контрагент.МаретингНапрвл,
//	|			ПродажиКвот.КвотаНомеров.Контрагент.ИсточИнфоГостиница,
//	|			ПродажиКвот.Услуга,
//	|			ПродажиКвот.ТипДеньКалендарь,
//	|			NULL,
//	|			ПродажиКвот.Period,
//	|			NULL,
//	|			ПродажиКвот.КвотаНомеров,
//	|			NULL,
//	|			ПродажиКвот.КвотаНомеров.Контрагент,
//	|			ПродажиКвот.КвотаНомеров.Договор,
//	|			ПродажиКвот.КвотаНомеров.Агент,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			ПродажиКвот.AllotmentPrice,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			ПродажиКвот.КвотаНомеров.Тариф.Скидка,
//	|			ПродажиКвот.КвотаНомеров.Тариф.ТипСкидки,
//	|			NULL,
//	|			ПродажиКвот.КвотаНомеров.Агент.КомиссияАгента,
//	|			ПродажиКвот.КвотаНомеров.Агент.ВидКомиссииАгента,
//	|			ПродажиКвот.КвотаНомеров.Контрагент.PlannedPaymentMethod,
//	|			ПродажиКвот.СтавкаНДС,
//	|			ПродажиКвот.СчетчикДокКвота,
//	|			1
//	|		FROM
//	|			ПродажиКвот AS ПродажиКвот
//	|		WHERE
//	|			&qWithAllotments) AS RoomSales
//	|			LEFT JOIN (SELECT
//	|				КалендарьДень.ТипДеньКалендарь AS ТипДеньКалендарь,
//	|				КалендарьДень.Period AS Period
//	|			FROM
//	|				InformationRegister.КалендарьДень AS КалендарьДень
//	|			WHERE
//	|				КалендарьДень.Calendar = &qCalendar) AS CalendarDayTypesByChoosenCalendar
//	|			ON RoomSales.Period = CalendarDayTypesByChoosenCalendar.Period) AS RoomSalesPerRoomTypeAndChoosenCalendarDayTypePerDay
//	|
//	|GROUP BY
//	|	RoomSalesPerRoomTypeAndChoosenCalendarDayTypePerDay.Гостиница,
//	|	RoomSalesPerRoomTypeAndChoosenCalendarDayTypePerDay.ТипНомера,
//	|	RoomSalesPerRoomTypeAndChoosenCalendarDayTypePerDay.ТипДеньКалендарь,
//	|	RoomSalesPerRoomTypeAndChoosenCalendarDayTypePerDay.Period
//	|;
//	|
//	|////////////////////////////////////////////////////////////////////////////////
//	|SELECT
//	|	RoomTotalSales.Гостиница AS Гостиница,
//	|	CASE
//	|		WHEN &qWithAllotments
//	|			THEN ISNULL(RoomTotalSales.TotalSalesAmount, 0) + ISNULL(RoomQuotaTotalSales.AllotmentAmount, 0)
//	|		ELSE ISNULL(RoomTotalSales.TotalSalesAmount, 0)
//	|	END AS TotalSalesAmount,
//	|	CASE
//	|		WHEN &qWithAllotments
//	|			THEN ISNULL(RoomTotalSales.TotalBedsRented, 0) + ISNULL(RoomQuotaTotalSales.BedsInQuotaClosingBalance, 0)
//	|		ELSE ISNULL(RoomTotalSales.TotalBedsRented, 0)
//	|	END AS TotalBedsRented,
//	|	CASE
//	|		WHEN &qWithAllotments
//	|			THEN ISNULL(RoomTotalSales.TotalRoomsRented, 0) + ISNULL(RoomQuotaTotalSales.RoomsInQuotaClosingBalance, 0)
//	|		ELSE ISNULL(RoomTotalSales.TotalRoomsRented, 0)
//	|	END AS TotalRoomsRented
//	|INTO RoomTotalSales
//	|FROM
//	|	(SELECT
//	|		TotalSales.Гостиница AS Гостиница,
//	|		SUM(TotalSales.SalesTurnover) AS TotalSalesAmount,
//	|		SUM(TotalSales.BedsRentedTurnover) AS TotalBedsRented,
//	|		SUM(TotalSales.RoomsRentedTurnover) AS TotalRoomsRented
//	|	FROM
//	|		(SELECT
//	|			RoomTotalSales.Гостиница AS Гостиница,
//	|			RoomTotalSales.SalesTurnover AS SalesTurnover,
//	|			RoomTotalSales.BedsRentedTurnover AS BedsRentedTurnover,
//	|			RoomTotalSales.RoomsRentedTurnover AS RoomsRentedTurnover
//	|		FROM
//	|			AccumulationRegister.Продажи.Turnovers(
//	|					&qPeriodFrom,
//	|					&qPeriodTo,
//	|					Period,
//	|					Гостиница IN HIERARCHY (&qHotel)
//	|						AND (НомерРазмещения IN HIERARCHY (&qRoom)
//	|							OR &qIsEmptyRoom)
//	|						AND (NOT НомерРазмещения IN (&qRooms2IgnoreList)
//	|							OR &qRooms2IgnoreListIsEmpty)
//	|						AND (ТипНомера IN HIERARCHY (&qRoomType)
//	|							OR &qIsEmptyRoomType)
//	|						AND (Услуга IN HIERARCHY (&qService)
//	|							OR &qIsEmptyService)
//	|						AND (Услуга IN HIERARCHY (&qServicesList)
//	|							OR NOT &qUseServicesList)
//	|						AND (NOT &qWithAllotments
//	|							OR &qWithAllotments
//	|								AND NOT ISNULL(ДокОснование.КвотаНомеров.IsConfirmedBlock, FALSE))
//	|						AND (NOT &qFilterByReservationCreationDate
//	|							OR &qFilterByReservationCreationDate
//	|								AND NOT &qByGroupCreationDate
//	|								AND (ДокОснование.Reservation.ДатаДок IS NULL 
//	|										AND ДокОснование.ДатаДок >= &qDateFrom
//	|									OR NOT ДокОснование.Reservation.ДатаДок IS NULL 
//	|										AND ДокОснование.Reservation.ДатаДок >= &qDateFrom)
//	|								AND (&qDateToIsEmpty
//	|									OR ДокОснование.Reservation.ДатаДок IS NULL 
//	|										AND ДокОснование.ДатаДок <= &qDateTo
//	|									OR NOT ДокОснование.Reservation.ДатаДок IS NULL 
//	|										AND ДокОснование.Reservation.ДатаДок <= &qDateTo)
//	|							OR &qFilterByReservationCreationDate
//	|								AND &qByGroupCreationDate
//	|								AND NOT ГруппаГостей.CreateDate IS NULL 
//	|								AND ГруппаГостей.CreateDate >= &qDateFrom
//	|								AND (&qDateToIsEmpty
//	|									OR ГруппаГостей.CreateDate <= &qDateTo))) AS RoomTotalSales
//	|		
//	|		UNION ALL
//	|		
//	|		SELECT
//	|			RoomTotalSalesForecast.Гостиница,
//	|			RoomTotalSalesForecast.SalesTurnover,
//	|			RoomTotalSalesForecast.BedsRentedTurnover,
//	|			RoomTotalSalesForecast.RoomsRentedTurnover
//	|		FROM
//	|			AccumulationRegister.ПрогнозПродаж.Turnovers(
//	|					&qForecastPeriodFrom,
//	|					&qForecastPeriodTo,
//	|					Period,
//	|					Гостиница IN HIERARCHY (&qHotel)
//	|						AND &qUseForecast
//	|						AND (НомерРазмещения IN HIERARCHY (&qRoom)
//	|							OR &qIsEmptyRoom)
//	|						AND (NOT НомерРазмещения IN (&qRooms2IgnoreList)
//	|							OR &qRooms2IgnoreListIsEmpty)
//	|						AND (ТипНомера IN HIERARCHY (&qRoomType)
//	|							OR &qIsEmptyRoomType)
//	|						AND (Услуга IN HIERARCHY (&qService)
//	|							OR &qIsEmptyService)
//	|						AND (Услуга IN HIERARCHY (&qServicesList)
//	|							OR NOT &qUseServicesList)
//	|						AND (NOT &qWithAllotments
//	|							OR &qWithAllotments
//	|								AND NOT ISNULL(ДокОснование.КвотаНомеров.IsConfirmedBlock, FALSE))
//	|						AND (NOT &qFilterByReservationCreationDate
//	|							OR &qFilterByReservationCreationDate
//	|								AND NOT &qByGroupCreationDate
//	|								AND ДокОснование.ДатаДок >= &qDateFrom
//	|								AND (ДокОснование.ДатаДок <= &qDateTo
//	|									OR &qDateToIsEmpty)
//	|							OR &qFilterByReservationCreationDate
//	|								AND &qByGroupCreationDate
//	|								AND NOT ГруппаГостей.CreateDate IS NULL 
//	|								AND ГруппаГостей.CreateDate >= &qDateFrom
//	|								AND (&qDateToIsEmpty
//	|									OR ГруппаГостей.CreateDate <= &qDateTo))) AS RoomTotalSalesForecast) AS TotalSales
//	|	
//	|	GROUP BY
//	|		TotalSales.Гостиница) AS RoomTotalSales
//	|		LEFT JOIN RoomQuotaTotalSales AS RoomQuotaTotalSales
//	|		ON RoomTotalSales.Гостиница = RoomQuotaTotalSales.Гостиница
//	|;
//	|
//	|////////////////////////////////////////////////////////////////////////////////
//	|SELECT
//	|	ОборотыПродажиНомеров.Фирма AS Фирма,
//	|	ОборотыПродажиНомеров.Гостиница AS Гостиница,
//	|	ОборотыПродажиНомеров.Валюта AS Валюта,
//	|	ОборотыПродажиНомеров.КвотаНомеров AS КвотаНомеров,
//	|	ОборотыПродажиНомеров.НомерРазмещения AS НомерРазмещения,
//	|	ОборотыПродажиНомеров.ТипНомера AS ТипНомера,
//	|	ОборотыПродажиНомеров.Тариф AS Тариф,
//	|	ОборотыПродажиНомеров.ТипДеньКалендарь AS ТипДеньКалендарь,
//	|	ОборотыПродажиНомеров.ПризнакЦены AS ПризнакЦены,
//	|	ОборотыПродажиНомеров.ВидРазмещения AS ВидРазмещения,
//	|	ОборотыПродажиНомеров.ТипКлиента AS ТипКлиента,
//	|	ОборотыПродажиНомеров.МаретингНапрвл AS МаретингНапрвл,
//	|	ОборотыПродажиНомеров.ИсточИнфоГостиница AS ИсточИнфоГостиница,
//	|	ОборотыПродажиНомеров.Услуга AS Услуга,
//	|	ОборотыПродажиНомеров.УчетнаяДата AS УчетнаяДата,
//	|	ОборотыПродажиНомеров.ДокОснование AS ДокОснование,
//	|	ОборотыПродажиНомеров.RoomPrice AS RoomPrice,
//	|	ОборотыПродажиНомеров.Продажи AS Продажи,
//	|	ОборотыПродажиНомеров.SalesWithoutCommission AS SalesWithoutCommission,
//	|	ОборотыПродажиНомеров.ДоходНомеров AS ДоходНомеров,
//	|	ОборотыПродажиНомеров.RoomRevenueWithoutCommission AS RoomRevenueWithoutCommission,
//	|	ОборотыПродажиНомеров.InPriceRevenue AS InPriceRevenue,
//	|	ОборотыПродажиНомеров.InPriceRevenueWithoutCommission AS InPriceRevenueWithoutCommission,
//	|	ОборотыПродажиНомеров.ДоходДопМеста AS ДоходДопМеста,
//	|	ОборотыПродажиНомеров.RoomRevenueWithoutExtraBed AS RoomRevenueWithoutExtraBed,
//	|	ОборотыПродажиНомеров.ПродажиБезНДС AS ПродажиБезНДС,
//	|	ОборотыПродажиНомеров.SalesWithoutVATWithoutCommission AS SalesWithoutVATWithoutCommission,
//	|	ОборотыПродажиНомеров.ДоходПродажиБезНДС AS ДоходПродажиБезНДС,
//	|	ОборотыПродажиНомеров.RoomRevenueWithoutVATWithoutCommission AS RoomRevenueWithoutVATWithoutCommission,
//	|	ОборотыПродажиНомеров.InPriceRevenueWithoutVAT AS InPriceRevenueWithoutVAT,
//	|	ОборотыПродажиНомеров.InPriceRevenueWithoutVATWithoutCommission AS InPriceRevenueWithoutVATWithoutCommission,
//	|	ОборотыПродажиНомеров.ДоходДопМестаБезНДС AS ДоходДопМестаБезНДС,
//	|	ОборотыПродажиНомеров.RoomRevenueWithoutExtraBedWithoutVAT AS RoomRevenueWithoutExtraBedWithoutVAT,
//	|	ОборотыПродажиНомеров.СуммаКомиссии AS СуммаКомиссии,
//	|	ОборотыПродажиНомеров.КомиссияБезНДС AS КомиссияБезНДС,
//	|	ОборотыПродажиНомеров.СуммаСкидки AS СуммаСкидки,
//	|	ОборотыПродажиНомеров.СуммаСкидкиБезНДС AS СуммаСкидкиБезНДС,
//	|	ОборотыПродажиНомеров.ExtraBedDiscountSum AS ExtraBedDiscountSum,
//	|	ОборотыПродажиНомеров.DiscountSumWithoutExtraBed AS DiscountSumWithoutExtraBed,
//	|	ОборотыПродажиНомеров.ПроданоНомеров AS ПроданоНомеров,
//	|	ОборотыПродажиНомеров.ПроданоМест AS ПроданоМест,
//	|	ОборотыПродажиНомеров.ПроданоДопМест AS ПроданоДопМест,
//	|	ОборотыПродажиНомеров.ЧеловекаДни AS ЧеловекаДни,
//	|	ОборотыПродажиНомеров.GuestDaysWithoutExtraBed AS GuestDaysWithoutExtraBed,
//	|	ОборотыПродажиНомеров.ExtraBedGuestDays AS ExtraBedGuestDays,
//	|	ОборотыПродажиНомеров.ЗаездГостей AS ЗаездГостей,
//	|	ОборотыПродажиНомеров.ЗаездНомеров AS ЗаездНомеров,
//	|	ОборотыПродажиНомеров.ЗаездМест AS ЗаездМест,
//	|	ОборотыПродажиНомеров.ЗаездДополнительныхМест AS ЗаездДополнительныхМест,
//	|	ОборотыПродажиНомеров.Количество AS Количество,
//	|	ОборотыПродажиНомеров.RoomsPerPeriod AS RoomsPerPeriod,
//	|	ОборотыПродажиНомеров.BedsPerPeriod AS BedsPerPeriod,
//	|	ОборотыПродажиНомеров.RoomsBlockedPerPeriod AS RoomsBlockedPerPeriod,
//	|	ОборотыПродажиНомеров.BedsBlockedPerPeriod AS BedsBlockedPerPeriod,
//	|	ОборотыПродажиНомеров.RoomsPerRoomTypePerDay AS RoomsPerRoomTypePerDay,
//	|	ОборотыПродажиНомеров.BedsPerRoomTypePerDay AS BedsPerRoomTypePerDay,
//	|	ОборотыПродажиНомеров.RoomsBlockedPerRoomTypePerDay AS RoomsBlockedPerRoomTypePerDay,
//	|	ОборотыПродажиНомеров.BedsBlockedPerRoomTypePerDay AS BedsBlockedPerRoomTypePerDay,
//	|	ОборотыПродажиНомеров.RoomsPerRoomTypePerMonth AS RoomsPerRoomTypePerMonth,
//	|	ОборотыПродажиНомеров.BedsPerRoomTypePerMonth AS BedsPerRoomTypePerMonth,
//	|	ОборотыПродажиНомеров.RoomsBlockedPerRoomTypePerMonth AS RoomsBlockedPerRoomTypePerMonth,
//	|	ОборотыПродажиНомеров.BedsBlockedPerRoomTypePerMonth AS BedsBlockedPerRoomTypePerMonth,
//	|	ОборотыПродажиНомеров.RoomsPerRoomTypePerPeriod AS RoomsPerRoomTypePerPeriod,
//	|	ОборотыПродажиНомеров.BedsPerRoomTypePerPeriod AS BedsPerRoomTypePerPeriod,
//	|	ОборотыПродажиНомеров.RoomsBlockedPerRoomTypePerPeriod AS RoomsBlockedPerRoomTypePerPeriod,
//	|	ОборотыПродажиНомеров.BedsBlockedPerRoomTypePerPeriod AS BedsBlockedPerRoomTypePerPeriod,
//	|	ОборотыПродажиНомеров.RoomsPerRoomTypeAndCalendarDayTypePerDay AS RoomsPerRoomTypeAndCalendarDayTypePerDay,
//	|	ОборотыПродажиНомеров.BedsPerRoomTypeAndCalendarDayTypePerDay AS BedsPerRoomTypeAndCalendarDayTypePerDay,
//	|	ОборотыПродажиНомеров.RoomsBlockedPerRoomTypeAndCalendarDayTypePerDay AS RoomsBlockedPerRoomTypeAndCalendarDayTypePerDay,
//	|	ОборотыПродажиНомеров.BedsBlockedPerRoomTypeAndCalendarDayTypePerDay AS BedsBlockedPerRoomTypeAndCalendarDayTypePerDay,
//	|	ОборотыПродажиНомеров.RoomsPerRoomTypeAndChoosenCalendarDayTypePerDay AS RoomsPerRoomTypeAndChoosenCalendarDayTypePerDay,
//	|	ОборотыПродажиНомеров.BedsPerRoomTypeAndChoosenCalendarDayTypePerDay AS BedsPerRoomTypeAndChoosenCalendarDayTypePerDay,
//	|	ОборотыПродажиНомеров.RoomsBlockedPerRoomTypeAndChoosenCalendarDayTypePerDay AS RoomsBlockedPerRoomTypeAndChoosenCalendarDayTypePerDay,
//	|	ОборотыПродажиНомеров.BedsBlockedPerRoomTypeAndChoosenCalendarDayTypePerDay AS BedsBlockedPerRoomTypeAndChoosenCalendarDayTypePerDay,
//	|	CASE
//	|		WHEN ОборотыПродажиНомеров.ПроданоНомеров = 0
//	|			THEN 0
//	|		ELSE ОборотыПродажиНомеров.ДоходНомеров / ОборотыПродажиНомеров.ПроданоНомеров
//	|	END AS AverageRoomPrice,
//	|	CASE
//	|		WHEN ОборотыПродажиНомеров.ПроданоМест = 0
//	|			THEN 0
//	|		ELSE ОборотыПродажиНомеров.ДоходНомеров / ОборотыПродажиНомеров.ПроданоМест
//	|	END AS AverageBedPrice,
//	|	CASE
//	|		WHEN ОборотыПродажиНомеров.ПроданоНомеров = 0
//	|			THEN 0
//	|		ELSE ОборотыПродажиНомеров.ДоходПродажиБезНДС / ОборотыПродажиНомеров.ПроданоНомеров
//	|	END AS AverageRoomPriceWithoutVAT,
//	|	CASE
//	|		WHEN ОборотыПродажиНомеров.ПроданоМест = 0
//	|			THEN 0
//	|		ELSE ОборотыПродажиНомеров.ДоходПродажиБезНДС / ОборотыПродажиНомеров.ПроданоМест
//	|	END AS AverageBedPriceWithoutVAT,
//	|	CASE
//	|		WHEN ОборотыПродажиНомеров.RoomsPerPeriod = 0
//	|			THEN 0
//	|		ELSE ОборотыПродажиНомеров.ДоходНомеров / ОборотыПродажиНомеров.RoomsPerPeriod
//	|	END AS RevPAR,
//	|	CASE
//	|		WHEN ОборотыПродажиНомеров.BedsPerPeriod = 0
//	|			THEN 0
//	|		ELSE ОборотыПродажиНомеров.ДоходНомеров / ОборотыПродажиНомеров.BedsPerPeriod
//	|	END AS RevPAB,
//	|	CASE
//	|		WHEN ОборотыПродажиНомеров.RoomsPerPeriod = 0
//	|			THEN 0
//	|		ELSE ОборотыПродажиНомеров.ДоходПродажиБезНДС / ОборотыПродажиНомеров.RoomsPerPeriod
//	|	END AS RevPARWithoutVAT,
//	|	CASE
//	|		WHEN ОборотыПродажиНомеров.BedsPerPeriod = 0
//	|			THEN 0
//	|		ELSE ОборотыПродажиНомеров.ДоходПродажиБезНДС / ОборотыПродажиНомеров.BedsPerPeriod
//	|	END AS RevPABWithoutVAT,
//	|	CASE
//	|		WHEN ОборотыПродажиНомеров.RoomsPerRoomTypePerDay = 0
//	|			THEN 0
//	|		ELSE ОборотыПродажиНомеров.ДоходНомеров / ОборотыПродажиНомеров.RoomsPerRoomTypePerDay
//	|	END AS RevPARPerRoomTypePerDay,
//	|	CASE
//	|		WHEN ОборотыПродажиНомеров.BedsPerRoomTypePerDay = 0
//	|			THEN 0
//	|		ELSE ОборотыПродажиНомеров.ДоходНомеров / ОборотыПродажиНомеров.RoomsPerRoomTypePerDay
//	|	END AS RevPABPerRoomTypePerDay,
//	|	CASE
//	|		WHEN ОборотыПродажиНомеров.RoomsPerRoomTypePerDay = 0
//	|			THEN 0
//	|		ELSE ОборотыПродажиНомеров.ДоходПродажиБезНДС / ОборотыПродажиНомеров.RoomsPerRoomTypePerDay
//	|	END AS RevPARWithoutVATPerRoomTypePerDay,
//	|	CASE
//	|		WHEN ОборотыПродажиНомеров.BedsPerRoomTypePerDay = 0
//	|			THEN 0
//	|		ELSE ОборотыПродажиНомеров.ДоходПродажиБезНДС / ОборотыПродажиНомеров.BedsPerRoomTypePerDay
//	|	END AS RevPABWithoutVATPerRoomTypePerDay,
//	|	CASE
//	|		WHEN ОборотыПродажиНомеров.RoomsPerRoomTypePerMonth = 0
//	|			THEN 0
//	|		ELSE ОборотыПродажиНомеров.ДоходНомеров / ОборотыПродажиНомеров.RoomsPerRoomTypePerMonth
//	|	END AS RevPARPerRoomTypePerMonth,
//	|	CASE
//	|		WHEN ОборотыПродажиНомеров.BedsPerRoomTypePerMonth = 0
//	|			THEN 0
//	|		ELSE ОборотыПродажиНомеров.ДоходНомеров / ОборотыПродажиНомеров.RoomsPerRoomTypePerMonth
//	|	END AS RevPABPerRoomTypePerMonth,
//	|	CASE
//	|		WHEN ОборотыПродажиНомеров.RoomsPerRoomTypePerMonth = 0
//	|			THEN 0
//	|		ELSE ОборотыПродажиНомеров.ДоходПродажиБезНДС / ОборотыПродажиНомеров.RoomsPerRoomTypePerMonth
//	|	END AS RevPARWithoutVATPerRoomTypePerMonth,
//	|	CASE
//	|		WHEN ОборотыПродажиНомеров.BedsPerRoomTypePerMonth = 0
//	|			THEN 0
//	|		ELSE ОборотыПродажиНомеров.ДоходПродажиБезНДС / ОборотыПродажиНомеров.BedsPerRoomTypePerMonth
//	|	END AS RevPABWithoutVATPerRoomTypePerMonth,
//	|	CASE
//	|		WHEN ОборотыПродажиНомеров.RoomsPerRoomTypePerPeriod = 0
//	|			THEN 0
//	|		ELSE ОборотыПродажиНомеров.ДоходНомеров / ОборотыПродажиНомеров.RoomsPerRoomTypePerPeriod
//	|	END AS RevPARPerRoomTypePerPeriod,
//	|	CASE
//	|		WHEN ОборотыПродажиНомеров.BedsPerRoomTypePerPeriod = 0
//	|			THEN 0
//	|		ELSE ОборотыПродажиНомеров.ДоходНомеров / ОборотыПродажиНомеров.RoomsPerRoomTypePerPeriod
//	|	END AS RevPABPerRoomTypePerPeriod,
//	|	CASE
//	|		WHEN ОборотыПродажиНомеров.RoomsPerRoomTypePerPeriod = 0
//	|			THEN 0
//	|		ELSE ОборотыПродажиНомеров.ДоходПродажиБезНДС / ОборотыПродажиНомеров.RoomsPerRoomTypePerPeriod
//	|	END AS RevPARWithoutVATPerRoomTypePerPeriod,
//	|	CASE
//	|		WHEN ОборотыПродажиНомеров.BedsPerRoomTypePerMonth = 0
//	|			THEN 0
//	|		ELSE ОборотыПродажиНомеров.ДоходПродажиБезНДС / ОборотыПродажиНомеров.BedsPerRoomTypePerPeriod
//	|	END AS RevPABWithoutVATPerRoomTypePerPeriod,
//	|	CASE
//	|		WHEN ОборотыПродажиНомеров.RoomsPerPeriod = 0
//	|			THEN 0
//	|		ELSE ОборотыПродажиНомеров.ПроданоНомеров * 100 / ОборотыПродажиНомеров.RoomsPerPeriod
//	|	END AS RoomsRentedPercent,
//	|	CASE
//	|		WHEN ОборотыПродажиНомеров.BedsPerPeriod = 0
//	|			THEN 0
//	|		ELSE ОборотыПродажиНомеров.ПроданоМест * 100 / ОборотыПродажиНомеров.BedsPerPeriod
//	|	END AS BedsRentedPercent,
//	|	CASE
//	|		WHEN ОборотыПродажиНомеров.RoomsPerPeriod - ОборотыПродажиНомеров.RoomsBlockedPerPeriod = 0
//	|			THEN 0
//	|		ELSE ОборотыПродажиНомеров.ПроданоНомеров * 100 / (ОборотыПродажиНомеров.RoomsPerPeriod - ОборотыПродажиНомеров.RoomsBlockedPerPeriod)
//	|	END AS RoomsRentedPercentWithRoomBlocks,
//	|	CASE
//	|		WHEN ОборотыПродажиНомеров.BedsPerPeriod - ОборотыПродажиНомеров.BedsBlockedPerPeriod = 0
//	|			THEN 0
//	|		ELSE ОборотыПродажиНомеров.ПроданоМест * 100 / (ОборотыПродажиНомеров.BedsPerPeriod - ОборотыПродажиНомеров.BedsBlockedPerPeriod)
//	|	END AS BedsRentedPercentWithRoomBlocks,
//	|	CASE
//	|		WHEN ОборотыПродажиНомеров.RoomsPerRoomTypePerDay = 0
//	|			THEN 0
//	|		ELSE ОборотыПродажиНомеров.ПроданоНомеров * 100 / ОборотыПродажиНомеров.RoomsPerRoomTypePerDay
//	|	END AS RoomsRentedPercentPerRoomTypePerDay,
//	|	CASE
//	|		WHEN ОборотыПродажиНомеров.BedsPerRoomTypePerDay = 0
//	|			THEN 0
//	|		ELSE ОборотыПродажиНомеров.ПроданоМест * 100 / ОборотыПродажиНомеров.BedsPerRoomTypePerDay
//	|	END AS BedsRentedPercentPerRoomTypePerDay,
//	|	CASE
//	|		WHEN ОборотыПродажиНомеров.RoomsPerRoomTypePerDay - ОборотыПродажиНомеров.RoomsBlockedPerRoomTypePerDay = 0
//	|			THEN 0
//	|		ELSE ОборотыПродажиНомеров.ПроданоНомеров * 100 / (ОборотыПродажиНомеров.RoomsPerRoomTypePerDay - ОборотыПродажиНомеров.RoomsBlockedPerRoomTypePerDay)
//	|	END AS RoomsRentedPercentWithRoomBlocksPerRoomTypePerDay,
//	|	CASE
//	|		WHEN ОборотыПродажиНомеров.BedsPerRoomTypePerDay - ОборотыПродажиНомеров.BedsBlockedPerRoomTypePerDay = 0
//	|			THEN 0
//	|		ELSE ОборотыПродажиНомеров.ПроданоМест * 100 / (ОборотыПродажиНомеров.BedsPerRoomTypePerDay - ОборотыПродажиНомеров.BedsBlockedPerRoomTypePerDay)
//	|	END AS BedsRentedPercentWithRoomBlocksPerRoomTypePerDay,
//	|	CASE
//	|		WHEN ОборотыПродажиНомеров.RoomsPerRoomTypePerMonth = 0
//	|			THEN 0
//	|		ELSE ОборотыПродажиНомеров.ПроданоНомеров * 100 / ОборотыПродажиНомеров.RoomsPerRoomTypePerMonth
//	|	END AS RoomsRentedPercentPerRoomTypePerMonth,
//	|	CASE
//	|		WHEN ОборотыПродажиНомеров.BedsPerRoomTypePerMonth = 0
//	|			THEN 0
//	|		ELSE ОборотыПродажиНомеров.ПроданоМест * 100 / ОборотыПродажиНомеров.BedsPerRoomTypePerMonth
//	|	END AS BedsRentedPercentPerRoomTypePerMonth,
//	|	CASE
//	|		WHEN ОборотыПродажиНомеров.RoomsPerRoomTypePerMonth - ОборотыПродажиНомеров.RoomsBlockedPerRoomTypePerMonth = 0
//	|			THEN 0
//	|		ELSE ОборотыПродажиНомеров.ПроданоНомеров * 100 / (ОборотыПродажиНомеров.RoomsPerRoomTypePerMonth - ОборотыПродажиНомеров.RoomsBlockedPerRoomTypePerMonth)
//	|	END AS RoomsRentedPercentWithRoomBlocksPerRoomTypePerMonth,
//	|	CASE
//	|		WHEN ОборотыПродажиНомеров.BedsPerRoomTypePerMonth - ОборотыПродажиНомеров.BedsBlockedPerRoomTypePerMonth = 0
//	|			THEN 0
//	|		ELSE ОборотыПродажиНомеров.ПроданоМест * 100 / (ОборотыПродажиНомеров.BedsPerRoomTypePerMonth - ОборотыПродажиНомеров.BedsBlockedPerRoomTypePerMonth)
//	|	END AS BedsRentedPercentWithRoomBlocksPerRoomTypePerMonth,
//	|	CASE
//	|		WHEN ОборотыПродажиНомеров.RoomsPerRoomTypePerPeriod = 0
//	|			THEN 0
//	|		ELSE ОборотыПродажиНомеров.ПроданоНомеров * 100 / ОборотыПродажиНомеров.RoomsPerRoomTypePerPeriod
//	|	END AS RoomsRentedPercentPerRoomTypePerPeriod,
//	|	CASE
//	|		WHEN ОборотыПродажиНомеров.BedsPerRoomTypePerPeriod = 0
//	|			THEN 0
//	|		ELSE ОборотыПродажиНомеров.ПроданоМест * 100 / ОборотыПродажиНомеров.BedsPerRoomTypePerPeriod
//	|	END AS BedsRentedPercentPerRoomTypePerPeriod,
//	|	CASE
//	|		WHEN ОборотыПродажиНомеров.RoomsPerRoomTypePerPeriod - ОборотыПродажиНомеров.RoomsBlockedPerRoomTypePerPeriod = 0
//	|			THEN 0
//	|		ELSE ОборотыПродажиНомеров.ПроданоНомеров * 100 / (ОборотыПродажиНомеров.RoomsPerRoomTypePerPeriod - ОборотыПродажиНомеров.RoomsBlockedPerRoomTypePerPeriod)
//	|	END AS RoomsRentedPercentWithRoomBlocksPerRoomTypePerPeriod,
//	|	CASE
//	|		WHEN ОборотыПродажиНомеров.BedsPerRoomTypePerPeriod - ОборотыПродажиНомеров.BedsBlockedPerRoomTypePerPeriod = 0
//	|			THEN 0
//	|		ELSE ОборотыПродажиНомеров.ПроданоМест * 100 / (ОборотыПродажиНомеров.BedsPerRoomTypePerPeriod - ОборотыПродажиНомеров.BedsBlockedPerRoomTypePerPeriod)
//	|	END AS BedsRentedPercentWithRoomBlocksPerRoomTypePerPeriod,
//	|	CASE
//	|		WHEN ОборотыПродажиНомеров.RoomsPerRoomTypeAndCalendarDayTypePerDay = 0
//	|			THEN 0
//	|		ELSE ОборотыПродажиНомеров.ПроданоНомеров * 100 / ОборотыПродажиНомеров.RoomsPerRoomTypeAndCalendarDayTypePerDay
//	|	END AS RoomsRentedPercentPerRoomTypeAndCalendarDayTypePerDay,
//	|	CASE
//	|		WHEN ОборотыПродажиНомеров.BedsPerRoomTypeAndCalendarDayTypePerDay = 0
//	|			THEN 0
//	|		ELSE ОборотыПродажиНомеров.ПроданоМест * 100 / ОборотыПродажиНомеров.BedsPerRoomTypeAndCalendarDayTypePerDay
//	|	END AS BedsRentedPercentPerRoomTypeAndCalendarDayTypePerDay,
//	|	CASE
//	|		WHEN ОборотыПродажиНомеров.RoomsPerRoomTypeAndCalendarDayTypePerDay - ОборотыПродажиНомеров.RoomsBlockedPerRoomTypeAndCalendarDayTypePerDay = 0
//	|			THEN 0
//	|		ELSE ОборотыПродажиНомеров.ПроданоНомеров * 100 / (ОборотыПродажиНомеров.RoomsPerRoomTypeAndCalendarDayTypePerDay - ОборотыПродажиНомеров.RoomsBlockedPerRoomTypeAndCalendarDayTypePerDay)
//	|	END AS RoomsRentedPercentWithRoomBlocksPerRoomTypeAndCalendarDayTypePerDay,
//	|	CASE
//	|		WHEN ОборотыПродажиНомеров.BedsPerRoomTypeAndCalendarDayTypePerDay - ОборотыПродажиНомеров.BedsBlockedPerRoomTypeAndCalendarDayTypePerDay = 0
//	|			THEN 0
//	|		ELSE ОборотыПродажиНомеров.ПроданоМест * 100 / (ОборотыПродажиНомеров.BedsPerRoomTypeAndCalendarDayTypePerDay - ОборотыПродажиНомеров.BedsBlockedPerRoomTypeAndCalendarDayTypePerDay)
//	|	END AS BedsRentedPercentWithRoomBlocksPerRoomTypeAndCalendarDayTypePerDay,
//	|	CASE
//	|		WHEN ОборотыПродажиНомеров.RoomsPerRoomTypeAndChoosenCalendarDayTypePerDay = 0
//	|			THEN 0
//	|		ELSE ОборотыПродажиНомеров.ПроданоНомеров * 100 / ОборотыПродажиНомеров.RoomsPerRoomTypeAndChoosenCalendarDayTypePerDay
//	|	END AS RoomsRentedPercentPerRoomTypeAndChoosenCalendarDayTypePerDay,
//	|	CASE
//	|		WHEN ОборотыПродажиНомеров.BedsPerRoomTypeAndChoosenCalendarDayTypePerDay = 0
//	|			THEN 0
//	|		ELSE ОборотыПродажиНомеров.ПроданоМест * 100 / ОборотыПродажиНомеров.BedsPerRoomTypeAndChoosenCalendarDayTypePerDay
//	|	END AS BedsRentedPercentPerRoomTypeAndChoosenCalendarDayTypePerDay,
//	|	CASE
//	|		WHEN ОборотыПродажиНомеров.RoomsPerRoomTypeAndChoosenCalendarDayTypePerDay - ОборотыПродажиНомеров.RoomsBlockedPerRoomTypeAndChoosenCalendarDayTypePerDay = 0
//	|			THEN 0
//	|		ELSE ОборотыПродажиНомеров.ПроданоНомеров * 100 / (ОборотыПродажиНомеров.RoomsPerRoomTypeAndChoosenCalendarDayTypePerDay - ОборотыПродажиНомеров.RoomsBlockedPerRoomTypeAndChoosenCalendarDayTypePerDay)
//	|	END AS RoomsRentedPercentWithRoomBlocksPerRoomTypeAndChoosenCalendarDayTypePerDay,
//	|	CASE
//	|		WHEN ОборотыПродажиНомеров.BedsPerRoomTypeAndChoosenCalendarDayTypePerDay - ОборотыПродажиНомеров.BedsBlockedPerRoomTypeAndChoosenCalendarDayTypePerDay = 0
//	|			THEN 0
//	|		ELSE ОборотыПродажиНомеров.ПроданоМест * 100 / (ОборотыПродажиНомеров.BedsPerRoomTypeAndChoosenCalendarDayTypePerDay - ОборотыПродажиНомеров.BedsBlockedPerRoomTypeAndChoosenCalendarDayTypePerDay)
//	|	END AS BedsRentedPercentWithRoomBlocksPerRoomTypeAndChoosenCalendarDayTypePerDay,
//	|	ОборотыПродажиНомеров.TotalSalesAmount AS TotalSalesAmount,
//	|	ОборотыПродажиНомеров.TotalRoomsRented AS TotalRoomsRented,
//	|	ОборотыПродажиНомеров.TotalBedsRented AS TotalBedsRented,
//	|	CASE
//	|		WHEN ОборотыПродажиНомеров.TotalSalesAmount = 0
//	|			THEN 0
//	|		ELSE ОборотыПродажиНомеров.Продажи * 100 / ОборотыПродажиНомеров.TotalSalesAmount
//	|	END AS TotalSalesPercent,
//	|	CASE
//	|		WHEN ОборотыПродажиНомеров.TotalBedsRented = 0
//	|			THEN 0
//	|		ELSE ОборотыПродажиНомеров.ПроданоМест * 100 / ОборотыПродажиНомеров.TotalBedsRented
//	|	END AS TotalBedsRentedPercent,
//	|	CASE
//	|		WHEN ОборотыПродажиНомеров.TotalRoomsRented = 0
//	|			THEN 0
//	|		ELSE ОборотыПродажиНомеров.ПроданоНомеров * 100 / ОборотыПродажиНомеров.TotalRoomsRented
//	|	END AS TotalRoomsRentedPercent,
//	|	ОборотыПродажиНомеров.RoomsPerRoomPerPeriod AS RoomsPerRoomPerPeriod,
//	|	ОборотыПродажиНомеров.BedsPerRoomPerPeriod AS BedsPerRoomPerPeriod,
//	|	ОборотыПродажиНомеров.RoomsBlockedPerRoomPerPeriod AS RoomsBlockedPerRoomPerPeriod,
//	|	ОборотыПродажиНомеров.BedsBlockedPerRoomPerPeriod AS BedsBlockedPerRoomPerPeriod,
//	|	CASE
//	|		WHEN ОборотыПродажиНомеров.RoomsPerRoomPerPeriod - ОборотыПродажиНомеров.RoomsBlockedPerRoomPerPeriod = 0
//	|			THEN 0
//	|		ELSE ОборотыПродажиНомеров.ПроданоНомеров * 100 / (ОборотыПродажиНомеров.RoomsPerRoomPerPeriod - ОборотыПродажиНомеров.RoomsBlockedPerRoomPerPeriod)
//	|	END AS RoomsRentedPercentPerRoom,
//	|	CASE
//	|		WHEN ОборотыПродажиНомеров.BedsPerRoomPerPeriod - ОборотыПродажиНомеров.BedsBlockedPerRoomPerPeriod = 0
//	|			THEN 0
//	|		ELSE ОборотыПродажиНомеров.ПроданоМест * 100 / (ОборотыПродажиНомеров.BedsPerRoomPerPeriod - ОборотыПродажиНомеров.BedsBlockedPerRoomPerPeriod)
//	|	END AS BedsRentedPercentPerRoom
//	|{SELECT
//	|	Фирма.*,
//	|	Гостиница.*,
//	|	Валюта.*,
//	|	НомерРазмещения.*,
//	|	ТипНомера.*,
//	|	Тариф.*,
//	|	ТипДеньКалендарь.*,
//	|	ПризнакЦены.*,
//	|	ОборотыПродажиНомеров.ExtCalendarDayType.* AS ExtCalendarDayType,
//	|	ВидРазмещения.*,
//	|	ТипКлиента.*,
//	|	МаретингНапрвл.*,
//	|	ИсточИнфоГостиница.*,
//	|	Услуга.*,
//	|	ДокОснование.*,
//	|	ОборотыПродажиНомеров.Reservation.* AS Reservation,
//	|	ОборотыПродажиНомеров.ReservationDate AS ReservationDate,
//	|	ОборотыПродажиНомеров.ReservationWeek AS ReservationWeek,
//	|	ОборотыПродажиНомеров.ReservationMonth AS ReservationMonth,
//	|	ОборотыПродажиНомеров.ReservationYear AS ReservationYear,
//	|	ОборотыПродажиНомеров.DaysBeforeCheckIn AS DaysBeforeCheckIn,
//	|	ОборотыПродажиНомеров.WeeksBeforeCheckIn AS WeeksBeforeCheckIn,
//	|	ОборотыПродажиНомеров.MonthsBeforeCheckIn AS MonthsBeforeCheckIn,
//	|	КвотаНомеров.*,
//	|	ОборотыПродажиНомеров.ГруппаГостей.* AS ГруппаГостей,
//	|	ОборотыПродажиНомеров.Контрагент.* AS Контрагент,
//	|	ОборотыПродажиНомеров.Договор.* AS Договор,
//	|	ОборотыПродажиНомеров.Агент.* AS Агент,
//	|	ОборотыПродажиНомеров.Клиент.* AS Клиент,
//	|	ОборотыПродажиНомеров.Ресурс.* AS Ресурс,
//	|	ОборотыПродажиНомеров.СчетПроживания.* AS СчетПроживания,
//	|	ОборотыПродажиНомеров.Цена AS Цена,
//	|	ОборотыПродажиНомеров.ТипРесурса.* AS ТипРесурса,
//	|	ОборотыПродажиНомеров.TripPurpose.* AS TripPurpose,
//	|	ОборотыПродажиНомеров.ПутевкаКурсовка.* AS ПутевкаКурсовка,
//	|	ОборотыПродажиНомеров.Автор.* AS Автор,
//	|	ОборотыПродажиНомеров.Скидка AS Скидка,
//	|	ОборотыПродажиНомеров.ТипСкидки.* AS ТипСкидки,
//	|	ОборотыПродажиНомеров.ДисконтКарт.* AS ДисконтКарт,
//	|	ОборотыПродажиНомеров.КомиссияАгента AS КомиссияАгента,
//	|	ОборотыПродажиНомеров.ВидКомиссииАгента.* AS ВидКомиссииАгента,
//	|	ОборотыПродажиНомеров.СпособОплаты.* AS СпособОплаты,
//	|	ОборотыПродажиНомеров.СтавкаНДС.* AS СтавкаНДС,
//	|	RoomPrice,
//	|	Продажи,
//	|	SalesWithoutCommission,
//	|	ДоходНомеров,
//	|	RoomRevenueWithoutCommission,
//	|	InPriceRevenue,
//	|	InPriceRevenueWithoutCommission,
//	|	ДоходДопМеста,
//	|	RoomRevenueWithoutExtraBed,
//	|	ПродажиБезНДС,
//	|	SalesWithoutVATWithoutCommission,
//	|	ДоходПродажиБезНДС,
//	|	RoomRevenueWithoutVATWithoutCommission,
//	|	InPriceRevenueWithoutVAT,
//	|	InPriceRevenueWithoutVATWithoutCommission,
//	|	ДоходДопМестаБезНДС,
//	|	RoomRevenueWithoutExtraBedWithoutVAT,
//	|	СуммаКомиссии,
//	|	КомиссияБезНДС,
//	|	СуммаСкидки,
//	|	СуммаСкидкиБезНДС,
//	|	ExtraBedDiscountSum,
//	|	DiscountSumWithoutExtraBed,
//	|	ПроданоНомеров,
//	|	ПроданоМест,
//	|	ПроданоДопМест,
//	|	ЧеловекаДни,
//	|	GuestDaysWithoutExtraBed,
//	|	ExtraBedGuestDays,
//	|	ЗаездГостей,
//	|	ЗаездНомеров,
//	|	ЗаездМест,
//	|	ЗаездДополнительныхМест,
//	|	Количество,
//	|	RoomsPerPeriod,
//	|	BedsPerPeriod,
//	|	RoomsBlockedPerPeriod,
//	|	BedsBlockedPerPeriod,
//	|	RoomsPerRoomTypePerDay,
//	|	BedsPerRoomTypePerDay,
//	|	RoomsBlockedPerRoomTypePerDay,
//	|	BedsBlockedPerRoomTypePerDay,
//	|	RoomsPerRoomTypePerMonth,
//	|	BedsPerRoomTypePerMonth,
//	|	RoomsBlockedPerRoomTypePerMonth,
//	|	BedsBlockedPerRoomTypePerMonth,
//	|	RoomsPerRoomTypePerPeriod,
//	|	BedsPerRoomTypePerPeriod,
//	|	RoomsBlockedPerRoomTypePerPeriod,
//	|	BedsBlockedPerRoomTypePerPeriod,
//	|	AverageRoomPrice,
//	|	AverageBedPrice,
//	|	AverageRoomPriceWithoutVAT,
//	|	AverageBedPriceWithoutVAT,
//	|	RevPAR,
//	|	RevPAB,
//	|	RevPARWithoutVAT,
//	|	RevPABWithoutVAT,
//	|	RevPARPerRoomTypePerDay,
//	|	RevPABPerRoomTypePerDay,
//	|	RevPARWithoutVATPerRoomTypePerDay,
//	|	RevPABWithoutVATPerRoomTypePerDay,
//	|	RevPARPerRoomTypePerMonth,
//	|	RevPABPerRoomTypePerMonth,
//	|	RevPARWithoutVATPerRoomTypePerMonth,
//	|	RevPABWithoutVATPerRoomTypePerMonth,
//	|	RevPARPerRoomTypePerPeriod,
//	|	RevPABPerRoomTypePerPeriod,
//	|	RevPARWithoutVATPerRoomTypePerPeriod,
//	|	RevPABWithoutVATPerRoomTypePerPeriod,
//	|	RoomsRentedPercent,
//	|	BedsRentedPercent,
//	|	RoomsRentedPercentWithRoomBlocks,
//	|	BedsRentedPercentWithRoomBlocks,
//	|	RoomsRentedPercentPerRoomTypePerDay,
//	|	BedsRentedPercentPerRoomTypePerDay,
//	|	RoomsRentedPercentWithRoomBlocksPerRoomTypePerDay,
//	|	BedsRentedPercentWithRoomBlocksPerRoomTypePerDay,
//	|	RoomsRentedPercentPerRoomTypePerMonth,
//	|	BedsRentedPercentPerRoomTypePerMonth,
//	|	RoomsRentedPercentWithRoomBlocksPerRoomTypePerMonth,
//	|	BedsRentedPercentWithRoomBlocksPerRoomTypePerMonth,
//	|	RoomsRentedPercentPerRoomTypePerPeriod,
//	|	BedsRentedPercentPerRoomTypePerPeriod,
//	|	RoomsRentedPercentWithRoomBlocksPerRoomTypePerPeriod,
//	|	BedsRentedPercentWithRoomBlocksPerRoomTypePerPeriod,
//	|	RoomsRentedPercentWithRoomBlocksPerRoomTypeAndCalendarDayTypePerDay,
//	|	BedsRentedPercentWithRoomBlocksPerRoomTypeAndCalendarDayTypePerDay,
//	|	RoomsRentedPercentWithRoomBlocksPerRoomTypeAndChoosenCalendarDayTypePerDay,
//	|	BedsRentedPercentWithRoomBlocksPerRoomTypeAndChoosenCalendarDayTypePerDay,
//	|	TotalSalesAmount,
//	|	TotalBedsRented,
//	|	TotalRoomsRented,
//	|	TotalSalesPercent,
//	|	TotalBedsRentedPercent,
//	|	TotalRoomsRentedPercent,
//	|	УчетнаяДата,
//	|	(DAY(ОборотыПродажиНомеров.УчетнаяДата)) AS AccountingDay,
//	|	(WEEKDAY(ОборотыПродажиНомеров.УчетнаяДата)) AS AccountingWeekday,
//	|	(CASE
//	|			WHEN WEEKDAY(ОборотыПродажиНомеров.УчетнаяДата) = 1
//	|				THEN &qMonday
//	|			WHEN WEEKDAY(ОборотыПродажиНомеров.УчетнаяДата) = 2
//	|				THEN &qTuesday
//	|			WHEN WEEKDAY(ОборотыПродажиНомеров.УчетнаяДата) = 3
//	|				THEN &qWednesday
//	|			WHEN WEEKDAY(ОборотыПродажиНомеров.УчетнаяДата) = 4
//	|				THEN &qThursday
//	|			WHEN WEEKDAY(ОборотыПродажиНомеров.УчетнаяДата) = 5
//	|				THEN &qFriday
//	|			WHEN WEEKDAY(ОборотыПродажиНомеров.УчетнаяДата) = 6
//	|				THEN &qSaturday
//	|			WHEN WEEKDAY(ОборотыПродажиНомеров.УчетнаяДата) = 7
//	|				THEN &qSunday
//	|			ELSE NULL
//	|		END) AS AccountingWeekdayName,
//	|	(WEEK(ОборотыПродажиНомеров.УчетнаяДата)) AS AccountingWeek,
//	|	(MONTH(ОборотыПродажиНомеров.УчетнаяДата)) AS AccountingMonth,
//	|	(QUARTER(ОборотыПродажиНомеров.УчетнаяДата)) AS AccountingQuarter,
//	|	(YEAR(ОборотыПродажиНомеров.УчетнаяДата)) AS AccountingYear,
//	|	RoomsPerRoomPerPeriod,
//	|	BedsPerRoomPerPeriod,
//	|	RoomsBlockedPerRoomPerPeriod,
//	|	BedsBlockedPerRoomPerPeriod,
//	|	RoomsRentedPercentPerRoom,
//	|	BedsRentedPercentPerRoom}
//	|FROM
//	|	(SELECT
//	|		RoomSales.Period AS Period,
//	|		RoomSales.Фирма AS Фирма,
//	|		RoomSales.Гостиница AS Гостиница,
//	|		RoomSales.Валюта AS Валюта,
//	|		RoomSales.НомерРазмещения AS НомерРазмещения,
//	|		RoomSales.ТипНомера AS ТипНомера,
//	|		RoomSales.Тариф AS Тариф,
//	|		RoomSales.ВидРазмещения AS ВидРазмещения,
//	|		RoomSales.ТипКлиента AS ТипКлиента,
//	|		RoomSales.МаретингНапрвл AS МаретингНапрвл,
//	|		RoomSales.ИсточИнфоГостиница AS ИсточИнфоГостиница,
//	|		RoomSales.Услуга AS Услуга,
//	|		RoomSales.УчетнаяДата AS УчетнаяДата,
//	|		RoomSales.ДокОснование AS ДокОснование,
//	|		ISNULL(RoomSales.ДокОснование.Reservation, RoomSales.ДокОснование) AS Reservation,
//	|		CASE
//	|			WHEN &qByGroupCreationDate
//	|				THEN BEGINOFPERIOD(ISNULL(RoomSales.ГруппаГостей.CreateDate, &qEmptyDate), DAY)
//	|			ELSE BEGINOFPERIOD(ISNULL(ISNULL(RoomSales.ДокОснование.Reservation.ДатаДок, RoomSales.ДокОснование.ДатаДок), &qEmptyDate), DAY)
//	|		END AS ReservationDate,
//	|		CASE
//	|			WHEN &qByGroupCreationDate
//	|				THEN WEEK(ISNULL(RoomSales.ГруппаГостей.CreateDate, &qEmptyDate))
//	|			ELSE WEEK(ISNULL(RoomSales.ДокОснование.Reservation.ДатаДок, RoomSales.ДокОснование.ДатаДок))
//	|		END AS ReservationWeek,
//	|		CASE
//	|			WHEN &qByGroupCreationDate
//	|				THEN MONTH(ISNULL(RoomSales.ГруппаГостей.CreateDate, &qEmptyDate))
//	|			ELSE MONTH(ISNULL(RoomSales.ДокОснование.Reservation.ДатаДок, RoomSales.ДокОснование.ДатаДок))
//	|		END AS ReservationMonth,
//	|		CASE
//	|			WHEN &qByGroupCreationDate
//	|				THEN YEAR(ISNULL(RoomSales.ГруппаГостей.CreateDate, &qEmptyDate))
//	|			ELSE YEAR(ISNULL(RoomSales.ДокОснование.Reservation.ДатаДок, RoomSales.ДокОснование.ДатаДок))
//	|		END AS ReservationYear,
//	|		ISNULL(DATEDIFF(RoomSales.ДокОснование.Reservation.ДатаДок, RoomSales.ДокОснование.CheckInDate, DAY), 0) AS DaysBeforeCheckIn,
//	|		CAST(ISNULL(DATEDIFF(RoomSales.ДокОснование.Reservation.ДатаДок, RoomSales.ДокОснование.CheckInDate, DAY), 0) / 7 AS NUMBER(10, 0)) AS WeeksBeforeCheckIn,
//	|		ISNULL(DATEDIFF(RoomSales.ДокОснование.Reservation.ДатаДок, RoomSales.ДокОснование.CheckInDate, MONTH), 0) AS MonthsBeforeCheckIn,
//	|		RoomSales.КвотаНомеров AS КвотаНомеров,
//	|		RoomSales.ТипДеньКалендарь AS ТипДеньКалендарь,
//	|		RoomSales.ПризнакЦены AS ПризнакЦены,
//	|		CalendarDayTypes.ТипДеньКалендарь AS ExtCalendarDayType,
//	|		CASE
//	|			WHEN ISNULL(RoomSales.RoomsRentedTurnover, 0) = 0
//	|				THEN 0
//	|			ELSE ISNULL(RoomSales.RoomRevenueTurnover, 0) / ISNULL(RoomSales.RoomsRentedTurnover, 0)
//	|		END AS RoomPrice,
//	|		RoomSales.ГруппаГостей AS ГруппаГостей,
//	|		RoomSales.Контрагент AS Контрагент,
//	|		RoomSales.Договор AS Договор,
//	|		RoomSales.Агент AS Агент,
//	|		RoomSales.Клиент AS Клиент,
//	|		RoomSales.Ресурс AS Ресурс,
//	|		RoomSales.СчетПроживания AS СчетПроживания,
//	|		RoomSales.Цена AS Цена,
//	|		RoomSales.ТипРесурса AS ТипРесурса,
//	|		RoomSales.TripPurpose AS TripPurpose,
//	|		RoomSales.ПутевкаКурсовка AS ПутевкаКурсовка,
//	|		RoomSales.Автор AS Автор,
//	|		RoomSales.Скидка AS Скидка,
//	|		RoomSales.ТипСкидки AS ТипСкидки,
//	|		RoomSales.ДисконтКарт AS ДисконтКарт,
//	|		RoomSales.КомиссияАгента AS КомиссияАгента,
//	|		RoomSales.ВидКомиссииАгента AS ВидКомиссииАгента,
//	|		RoomSales.СпособОплаты AS СпособОплаты,
//	|		RoomSales.СтавкаНДС AS СтавкаНДС,
//	|		ISNULL(RoomSales.SalesTurnover, 0) AS Продажи,
//	|		ISNULL(RoomSales.SalesTurnover, 0) - ISNULL(RoomSales.CommissionSumTurnover, 0) AS SalesWithoutCommission,
//	|		ISNULL(RoomSales.RoomRevenueTurnover, 0) AS ДоходНомеров,
//	|		ISNULL(RoomSales.RoomRevenueTurnover, 0) - ISNULL(RoomSales.CommissionSumTurnover, 0) AS RoomRevenueWithoutCommission,
//	|		CASE
//	|			WHEN ISNULL(RoomSales.Услуга.IsInPrice, FALSE)
//	|				THEN ISNULL(RoomSales.SalesTurnover, 0)
//	|			ELSE 0
//	|		END AS InPriceRevenue,
//	|		CASE
//	|			WHEN ISNULL(RoomSales.Услуга.IsInPrice, FALSE)
//	|				THEN ISNULL(RoomSales.SalesTurnover, 0) - ISNULL(RoomSales.CommissionSumTurnover, 0)
//	|			ELSE 0
//	|		END AS InPriceRevenueWithoutCommission,
//	|		ISNULL(RoomSales.RoomRevenueTurnover, 0) - ISNULL(RoomSales.ExtraBedRevenueTurnover, 0) AS RoomRevenueWithoutExtraBed,
//	|		ISNULL(RoomSales.ExtraBedRevenueTurnover, 0) AS ДоходДопМеста,
//	|		ISNULL(RoomSales.SalesWithoutVATTurnover, 0) AS ПродажиБезНДС,
//	|		ISNULL(RoomSales.SalesWithoutVATTurnover, 0) - ISNULL(RoomSales.CommissionSumWithoutVATTurnover, 0) AS SalesWithoutVATWithoutCommission,
//	|		ISNULL(RoomSales.RoomRevenueWithoutVATTurnover, 0) AS ДоходПродажиБезНДС,
//	|		ISNULL(RoomSales.RoomRevenueWithoutVATTurnover, 0) - ISNULL(RoomSales.CommissionSumWithoutVATTurnover, 0) AS RoomRevenueWithoutVATWithoutCommission,
//	|		CASE
//	|			WHEN ISNULL(RoomSales.Услуга.IsInPrice, FALSE)
//	|				THEN ISNULL(RoomSales.SalesWithoutVATTurnover, 0)
//	|			ELSE 0
//	|		END AS InPriceRevenueWithoutVAT,
//	|		CASE
//	|			WHEN ISNULL(RoomSales.Услуга.IsInPrice, FALSE)
//	|				THEN ISNULL(RoomSales.SalesWithoutVATTurnover, 0) - ISNULL(RoomSales.CommissionSumWithoutVATTurnover, 0)
//	|			ELSE 0
//	|		END AS InPriceRevenueWithoutVATWithoutCommission,
//	|		ISNULL(RoomSales.RoomRevenueWithoutVATTurnover, 0) - ISNULL(RoomSales.ExtraBedRevenueWithoutVATTurnover, 0) AS RoomRevenueWithoutExtraBedWithoutVAT,
//	|		ISNULL(RoomSales.ExtraBedRevenueWithoutVATTurnover, 0) AS ДоходДопМестаБезНДС,
//	|		ISNULL(RoomSales.CommissionSumTurnover, 0) AS СуммаКомиссии,
//	|		ISNULL(RoomSales.CommissionSumWithoutVATTurnover, 0) AS КомиссияБезНДС,
//	|		ISNULL(RoomSales.DiscountSumTurnover, 0) AS СуммаСкидки,
//	|		ISNULL(RoomSales.DiscountSumWithoutVATTurnover, 0) AS СуммаСкидкиБезНДС,
//	|		CASE
//	|			WHEN ISNULL(RoomSales.ExtraBedRevenueTurnover, 0) = 0
//	|				THEN 0
//	|			ELSE ISNULL(RoomSales.DiscountSumTurnover, 0)
//	|		END AS ExtraBedDiscountSum,
//	|		CASE
//	|			WHEN ISNULL(RoomSales.ExtraBedRevenueTurnover, 0) = 0
//	|				THEN ISNULL(RoomSales.DiscountSumTurnover, 0)
//	|			ELSE 0
//	|		END AS DiscountSumWithoutExtraBed,
//	|		ISNULL(RoomSales.RoomsRentedTurnover, 0) AS ПроданоНомеров,
//	|		ISNULL(RoomSales.BedsRentedTurnover, 0) AS ПроданоМест,
//	|		ISNULL(RoomSales.AdditionalBedsRentedTurnover, 0) AS ПроданоДопМест,
//	|		ISNULL(RoomSales.GuestDaysTurnover, 0) AS ЧеловекаДни,
//	|		ISNULL(RoomSales.GuestDaysTurnover, 0) - ISNULL(RoomSales.AdditionalGuestDaysTurnover, 0) AS GuestDaysWithoutExtraBed,
//	|		ISNULL(RoomSales.AdditionalGuestDaysTurnover, 0) AS ExtraBedGuestDays,
//	|		ISNULL(RoomSales.GuestsCheckedInTurnover, 0) AS ЗаездГостей,
//	|		ISNULL(RoomSales.RoomsCheckedInTurnover, 0) AS ЗаездНомеров,
//	|		ISNULL(RoomSales.BedsCheckedInTurnover, 0) AS ЗаездМест,
//	|		ISNULL(RoomSales.AdditionalBedsCheckedInTurnover, 0) AS ЗаездДополнительныхМест,
//	|		ISNULL(RoomSales.QuantityTurnover, 0) AS Количество,
//	|		ISNULL(RoomTypeInventoryTotalsPerDay.ВсегоНомеров, 0) / ISNULL(RoomSalesPerRoomTypePerDay.NumberOfDetailedRows, 1) AS RoomsPerRoomTypePerDay,
//	|		ISNULL(RoomTypeInventoryTotalsPerDay.ВсегоМест, 0) / ISNULL(RoomSalesPerRoomTypePerDay.NumberOfDetailedRows, 1) AS BedsPerRoomTypePerDay,
//	|		ISNULL(RoomTypeInventoryTotalsPerDay.TotalRoomsBlocked, 0) / ISNULL(RoomSalesPerRoomTypePerDay.NumberOfDetailedRows, 1) AS RoomsBlockedPerRoomTypePerDay,
//	|		ISNULL(RoomTypeInventoryTotalsPerDay.TotalBedsBlocked, 0) / ISNULL(RoomSalesPerRoomTypePerDay.NumberOfDetailedRows, 1) AS BedsBlockedPerRoomTypePerDay,
//	|		ISNULL(RoomTypeInventoryTotalsPerMonth.ВсегоНомеров, 0) / ISNULL(RoomSalesPerRoomTypePerMonth.NumberOfDetailedRows, 1) AS RoomsPerRoomTypePerMonth,
//	|		ISNULL(RoomTypeInventoryTotalsPerMonth.ВсегоМест, 0) / ISNULL(RoomSalesPerRoomTypePerMonth.NumberOfDetailedRows, 1) AS BedsPerRoomTypePerMonth,
//	|		ISNULL(RoomTypeInventoryTotalsPerMonth.TotalRoomsBlocked, 0) / ISNULL(RoomSalesPerRoomTypePerMonth.NumberOfDetailedRows, 1) AS RoomsBlockedPerRoomTypePerMonth,
//	|		ISNULL(RoomTypeInventoryTotalsPerMonth.TotalBedsBlocked, 0) / ISNULL(RoomSalesPerRoomTypePerMonth.NumberOfDetailedRows, 1) AS BedsBlockedPerRoomTypePerMonth,
//	|		ISNULL(RoomTypeInventoryTotalsPerPeriod.ВсегоНомеров, 0) / ISNULL(RoomSalesPerRoomTypePerPeriod.NumberOfDetailedRows, 1) AS RoomsPerRoomTypePerPeriod,
//	|		ISNULL(RoomTypeInventoryTotalsPerPeriod.ВсегоМест, 0) / ISNULL(RoomSalesPerRoomTypePerPeriod.NumberOfDetailedRows, 1) AS BedsPerRoomTypePerPeriod,
//	|		ISNULL(RoomTypeInventoryTotalsPerPeriod.TotalRoomsBlocked, 0) / ISNULL(RoomSalesPerRoomTypePerPeriod.NumberOfDetailedRows, 1) AS RoomsBlockedPerRoomTypePerPeriod,
//	|		ISNULL(RoomTypeInventoryTotalsPerPeriod.TotalBedsBlocked, 0) / ISNULL(RoomSalesPerRoomTypePerPeriod.NumberOfDetailedRows, 1) AS BedsBlockedPerRoomTypePerPeriod,
//	|		ISNULL(RoomTypeInventoryTotalsPerDay.ВсегоНомеров, 0) / ISNULL(RoomSalesPerRoomTypeAndCalendarDayTypePerDay.NumberOfDetailedRows, 1) AS RoomsPerRoomTypeAndCalendarDayTypePerDay,
//	|		ISNULL(RoomTypeInventoryTotalsPerDay.ВсегоМест, 0) / ISNULL(RoomSalesPerRoomTypeAndCalendarDayTypePerDay.NumberOfDetailedRows, 1) AS BedsPerRoomTypeAndCalendarDayTypePerDay,
//	|		ISNULL(RoomTypeInventoryTotalsPerDay.TotalRoomsBlocked, 0) / ISNULL(RoomSalesPerRoomTypeAndCalendarDayTypePerDay.NumberOfDetailedRows, 1) AS RoomsBlockedPerRoomTypeAndCalendarDayTypePerDay,
//	|		ISNULL(RoomTypeInventoryTotalsPerDay.TotalBedsBlocked, 0) / ISNULL(RoomSalesPerRoomTypeAndCalendarDayTypePerDay.NumberOfDetailedRows, 1) AS BedsBlockedPerRoomTypeAndCalendarDayTypePerDay,
//	|		ISNULL(RoomTypeInventoryTotalsPerDay.ВсегоНомеров, 0) / ISNULL(RoomSalesPerRoomTypeAndChoosenCalendarDayTypePerDay.NumberOfDetailedRows, 1) AS RoomsPerRoomTypeAndChoosenCalendarDayTypePerDay,
//	|		ISNULL(RoomTypeInventoryTotalsPerDay.ВсегоМест, 0) / ISNULL(RoomSalesPerRoomTypeAndChoosenCalendarDayTypePerDay.NumberOfDetailedRows, 1) AS BedsPerRoomTypeAndChoosenCalendarDayTypePerDay,
//	|		ISNULL(RoomTypeInventoryTotalsPerDay.TotalRoomsBlocked, 0) / ISNULL(RoomSalesPerRoomTypeAndChoosenCalendarDayTypePerDay.NumberOfDetailedRows, 1) AS RoomsBlockedPerRoomTypeAndChoosenCalendarDayTypePerDay,
//	|		ISNULL(RoomTypeInventoryTotalsPerDay.TotalBedsBlocked, 0) / ISNULL(RoomSalesPerRoomTypeAndChoosenCalendarDayTypePerDay.NumberOfDetailedRows, 1) AS BedsBlockedPerRoomTypeAndChoosenCalendarDayTypePerDay,
//	|		ISNULL(InventoryTotals.ВсегоНомеров, 0) AS RoomsPerPeriod,
//	|		ISNULL(InventoryTotals.ВсегоМест, 0) AS BedsPerPeriod,
//	|		ISNULL(InventoryTotals.TotalRoomsBlocked, 0) AS RoomsBlockedPerPeriod,
//	|		ISNULL(InventoryTotals.TotalBedsBlocked, 0) AS BedsBlockedPerPeriod,
//	|		ISNULL(TotalSales.TotalSalesAmount, 0) AS TotalSalesAmount,
//	|		ISNULL(TotalSales.TotalBedsRented, 0) AS TotalBedsRented,
//	|		ISNULL(TotalSales.TotalRoomsRented, 0) AS TotalRoomsRented,
//	|		ISNULL(RoomInventoryTotals.ВсегоНомеров, 0) AS RoomsPerRoomPerPeriod,
//	|		ISNULL(RoomInventoryTotals.ВсегоМест, 0) AS BedsPerRoomPerPeriod,
//	|		ISNULL(RoomInventoryTotals.TotalRoomsBlocked, 0) AS RoomsBlockedPerRoomPerPeriod,
//	|		ISNULL(RoomInventoryTotals.TotalBedsBlocked, 0) AS BedsBlockedPerRoomPerPeriod
//	|	FROM
//	|		(SELECT
//	|			RoomSalesTotals.Period AS Period,
//	|			RoomSalesTotals.Фирма AS Фирма,
//	|			RoomSalesTotals.Гостиница AS Гостиница,
//	|			RoomSalesTotals.Валюта AS Валюта,
//	|			RoomSalesTotals.НомерРазмещения AS НомерРазмещения,
//	|			RoomSalesTotals.ТипНомера AS ТипНомера,
//	|			RoomSalesTotals.Тариф AS Тариф,
//	|			RoomSalesTotals.ВидРазмещения AS ВидРазмещения,
//	|			RoomSalesTotals.ТипКлиента AS ТипКлиента,
//	|			RoomSalesTotals.МаретингНапрвл AS МаретингНапрвл,
//	|			RoomSalesTotals.ИсточИнфоГостиница AS ИсточИнфоГостиница,
//	|			RoomSalesTotals.Услуга AS Услуга,
//	|			RoomSalesTotals.ТипДеньКалендарь AS ТипДеньКалендарь,
//	|			RoomSalesTotals.ПризнакЦены AS ПризнакЦены,
//	|			RoomSalesTotals.УчетнаяДата AS УчетнаяДата,
//	|			RoomSalesTotals.ДокОснование AS ДокОснование,
//	|			RoomSalesTotals.ДокОснование.КвотаНомеров AS КвотаНомеров,
//	|			RoomSalesTotals.ГруппаГостей AS ГруппаГостей,
//	|			RoomSalesTotals.Контрагент AS Контрагент,
//	|			RoomSalesTotals.Договор AS Договор,
//	|			RoomSalesTotals.Агент AS Агент,
//	|			RoomSalesTotals.Клиент AS Клиент,
//	|			RoomSalesTotals.Ресурс AS Ресурс,
//	|			RoomSalesTotals.СчетПроживания AS СчетПроживания,
//	|			RoomSalesTotals.Цена AS Цена,
//	|			RoomSalesTotals.ТипРесурса AS ТипРесурса,
//	|			RoomSalesTotals.TripPurpose AS TripPurpose,
//	|			RoomSalesTotals.ПутевкаКурсовка AS ПутевкаКурсовка,
//	|			RoomSalesTotals.Автор AS Автор,
//	|			RoomSalesTotals.Скидка AS Скидка,
//	|			RoomSalesTotals.ТипСкидки AS ТипСкидки,
//	|			RoomSalesTotals.ДисконтКарт AS ДисконтКарт,
//	|			RoomSalesTotals.КомиссияАгента AS КомиссияАгента,
//	|			RoomSalesTotals.ВидКомиссииАгента AS ВидКомиссииАгента,
//	|			RoomSalesTotals.СпособОплаты AS СпособОплаты,
//	|			RoomSalesTotals.СтавкаНДС AS СтавкаНДС,
//	|			RoomSalesTotals.SalesTurnover AS SalesTurnover,
//	|			RoomSalesTotals.RoomRevenueTurnover AS RoomRevenueTurnover,
//	|			RoomSalesTotals.ExtraBedRevenueTurnover AS ExtraBedRevenueTurnover,
//	|			RoomSalesTotals.SalesWithoutVATTurnover AS SalesWithoutVATTurnover,
//	|			RoomSalesTotals.RoomRevenueWithoutVATTurnover AS RoomRevenueWithoutVATTurnover,
//	|			RoomSalesTotals.ExtraBedRevenueWithoutVATTurnover AS ExtraBedRevenueWithoutVATTurnover,
//	|			RoomSalesTotals.CommissionSumTurnover AS CommissionSumTurnover,
//	|			RoomSalesTotals.CommissionSumWithoutVATTurnover AS CommissionSumWithoutVATTurnover,
//	|			RoomSalesTotals.DiscountSumTurnover AS DiscountSumTurnover,
//	|			RoomSalesTotals.DiscountSumWithoutVATTurnover AS DiscountSumWithoutVATTurnover,
//	|			RoomSalesTotals.RoomsRentedTurnover AS RoomsRentedTurnover,
//	|			RoomSalesTotals.BedsRentedTurnover AS BedsRentedTurnover,
//	|			RoomSalesTotals.AdditionalBedsRentedTurnover AS AdditionalBedsRentedTurnover,
//	|			RoomSalesTotals.GuestDaysTurnover AS GuestDaysTurnover,
//	|			CASE
//	|				WHEN RoomSalesTotals.AdditionalBedsRentedTurnover <> 0
//	|					THEN RoomSalesTotals.GuestDaysTurnover
//	|				ELSE 0
//	|			END AS AdditionalGuestDaysTurnover,
//	|			RoomSalesTotals.GuestsCheckedInTurnover AS GuestsCheckedInTurnover,
//	|			RoomSalesTotals.RoomsCheckedInTurnover AS RoomsCheckedInTurnover,
//	|			RoomSalesTotals.BedsCheckedInTurnover AS BedsCheckedInTurnover,
//	|			RoomSalesTotals.AdditionalBedsCheckedInTurnover AS AdditionalBedsCheckedInTurnover,
//	|			0 AS СчетчикДокКвота,
//	|			RoomSalesTotals.QuantityTurnover AS QuantityTurnover
//	|		FROM
//	|			AccumulationRegister.Продажи.Turnovers(
//	|					&qPeriodFrom,
//	|					&qPeriodTo,
//	|					Day,
//	|					Гостиница IN HIERARCHY (&qHotel)
//	|						AND (НомерРазмещения IN HIERARCHY (&qRoom)
//	|							OR &qIsEmptyRoom)
//	|						AND (NOT НомерРазмещения IN (&qRooms2IgnoreList)
//	|							OR &qRooms2IgnoreListIsEmpty)
//	|						AND (ТипНомера IN HIERARCHY (&qRoomType)
//	|							OR &qIsEmptyRoomType)
//	|						AND (Услуга IN HIERARCHY (&qService)
//	|							OR &qIsEmptyService)
//	|						AND (Услуга IN HIERARCHY (&qServicesList)
//	|							OR NOT &qUseServicesList)
//	|						AND (NOT &qWithAllotments
//	|							OR &qWithAllotments
//	|								AND NOT ISNULL(ДокОснование.КвотаНомеров.IsConfirmedBlock, FALSE))
//	|						AND (NOT &qFilterByReservationCreationDate
//	|							OR &qFilterByReservationCreationDate
//	|								AND NOT &qByGroupCreationDate
//	|								AND (ДокОснование.Reservation.ДатаДок IS NULL 
//	|										AND ДокОснование.ДатаДок >= &qDateFrom
//	|									OR NOT ДокОснование.Reservation.ДатаДок IS NULL 
//	|										AND ДокОснование.Reservation.ДатаДок >= &qDateFrom)
//	|								AND (&qDateToIsEmpty
//	|									OR ДокОснование.Reservation.ДатаДок IS NULL 
//	|										AND ДокОснование.ДатаДок <= &qDateTo
//	|									OR NOT ДокОснование.Reservation.ДатаДок IS NULL 
//	|										AND ДокОснование.Reservation.ДатаДок <= &qDateTo)
//	|							OR &qFilterByReservationCreationDate
//	|								AND &qByGroupCreationDate
//	|								AND NOT ГруппаГостей.CreateDate IS NULL 
//	|								AND ГруппаГостей.CreateDate >= &qDateFrom
//	|								AND (&qDateToIsEmpty
//	|									OR ГруппаГостей.CreateDate <= &qDateTo))) AS RoomSalesTotals
//	|		
//	|		UNION ALL
//	|		
//	|		SELECT
//	|			RoomSalesForecastTotals.Period,
//	|			RoomSalesForecastTotals.Фирма,
//	|			RoomSalesForecastTotals.Гостиница,
//	|			RoomSalesForecastTotals.Валюта,
//	|			RoomSalesForecastTotals.НомерРазмещения,
//	|			RoomSalesForecastTotals.ТипНомера,
//	|			RoomSalesForecastTotals.Тариф,
//	|			RoomSalesForecastTotals.ВидРазмещения,
//	|			RoomSalesForecastTotals.ТипКлиента,
//	|			RoomSalesForecastTotals.МаретингНапрвл,
//	|			RoomSalesForecastTotals.ИсточИнфоГостиница,
//	|			RoomSalesForecastTotals.Услуга,
//	|			RoomSalesForecastTotals.ТипДеньКалендарь,
//	|			RoomSalesForecastTotals.ПризнакЦены,
//	|			RoomSalesForecastTotals.УчетнаяДата,
//	|			RoomSalesForecastTotals.ДокОснование,
//	|			RoomSalesForecastTotals.ДокОснование.КвотаНомеров,
//	|			RoomSalesForecastTotals.ГруппаГостей,
//	|			RoomSalesForecastTotals.Контрагент,
//	|			RoomSalesForecastTotals.Договор,
//	|			RoomSalesForecastTotals.Агент,
//	|			RoomSalesForecastTotals.Клиент,
//	|			RoomSalesForecastTotals.Ресурс,
//	|			RoomSalesForecastTotals.СчетПроживания,
//	|			RoomSalesForecastTotals.Цена,
//	|			RoomSalesForecastTotals.ТипРесурса,
//	|			RoomSalesForecastTotals.TripPurpose,
//	|			RoomSalesForecastTotals.ПутевкаКурсовка,
//	|			RoomSalesForecastTotals.Автор,
//	|			RoomSalesForecastTotals.Скидка,
//	|			RoomSalesForecastTotals.ТипСкидки,
//	|			RoomSalesForecastTotals.ДисконтКарт,
//	|			RoomSalesForecastTotals.КомиссияАгента,
//	|			RoomSalesForecastTotals.ВидКомиссииАгента,
//	|			RoomSalesForecastTotals.СпособОплаты,
//	|			RoomSalesForecastTotals.СтавкаНДС,
//	|			RoomSalesForecastTotals.SalesTurnover,
//	|			RoomSalesForecastTotals.RoomRevenueTurnover,
//	|			RoomSalesForecastTotals.ExtraBedRevenueTurnover,
//	|			RoomSalesForecastTotals.SalesWithoutVATTurnover,
//	|			RoomSalesForecastTotals.RoomRevenueWithoutVATTurnover,
//	|			RoomSalesForecastTotals.ExtraBedRevenueWithoutVATTurnover,
//	|			RoomSalesForecastTotals.CommissionSumTurnover,
//	|			RoomSalesForecastTotals.CommissionSumWithoutVATTurnover,
//	|			RoomSalesForecastTotals.DiscountSumTurnover,
//	|			RoomSalesForecastTotals.DiscountSumWithoutVATTurnover,
//	|			RoomSalesForecastTotals.RoomsRentedTurnover,
//	|			RoomSalesForecastTotals.BedsRentedTurnover,
//	|			RoomSalesForecastTotals.AdditionalBedsRentedTurnover,
//	|			RoomSalesForecastTotals.GuestDaysTurnover,
//	|			CASE
//	|				WHEN RoomSalesForecastTotals.AdditionalBedsRentedTurnover <> 0
//	|					THEN RoomSalesForecastTotals.GuestDaysTurnover
//	|				ELSE 0
//	|			END,
//	|			RoomSalesForecastTotals.GuestsCheckedInTurnover,
//	|			RoomSalesForecastTotals.RoomsCheckedInTurnover,
//	|			RoomSalesForecastTotals.BedsCheckedInTurnover,
//	|			RoomSalesForecastTotals.AdditionalBedsCheckedInTurnover,
//	|			0,
//	|			RoomSalesForecastTotals.QuantityTurnover
//	|		FROM
//	|			AccumulationRegister.ПрогнозПродаж.Turnovers(
//	|					&qForecastPeriodFrom,
//	|					&qForecastPeriodTo,
//	|					Day,
//	|					Гостиница IN HIERARCHY (&qHotel)
//	|						AND &qUseForecast
//	|						AND (НомерРазмещения IN HIERARCHY (&qRoom)
//	|							OR &qIsEmptyRoom)
//	|						AND (NOT НомерРазмещения IN (&qRooms2IgnoreList)
//	|							OR &qRooms2IgnoreListIsEmpty)
//	|						AND (ТипНомера IN HIERARCHY (&qRoomType)
//	|							OR &qIsEmptyRoomType)
//	|						AND (Услуга IN HIERARCHY (&qService)
//	|							OR &qIsEmptyService)
//	|						AND (Услуга IN HIERARCHY (&qServicesList)
//	|							OR NOT &qUseServicesList)
//	|						AND (NOT &qWithAllotments
//	|							OR &qWithAllotments
//	|								AND NOT ISNULL(ДокОснование.КвотаНомеров.IsConfirmedBlock, FALSE))
//	|						AND (NOT &qFilterByReservationCreationDate
//	|							OR &qFilterByReservationCreationDate
//	|								AND NOT &qByGroupCreationDate
//	|								AND NOT ДокОснование.ДатаДок IS NULL 
//	|								AND ДокОснование.ДатаДок >= &qDateFrom
//	|								AND (&qDateToIsEmpty
//	|									OR ДокОснование.ДатаДок <= &qDateTo)
//	|							OR &qFilterByReservationCreationDate
//	|								AND &qByGroupCreationDate
//	|								AND NOT ГруппаГостей.CreateDate IS NULL 
//	|								AND ГруппаГостей.CreateDate >= &qDateFrom
//	|								AND (&qDateToIsEmpty
//	|									OR ГруппаГостей.CreateDate <= &qDateTo))) AS RoomSalesForecastTotals
//	|		
//	|		UNION ALL
//	|		
//	|		SELECT
//	|			RoomTypesListPerDay.Period,
//	|			NULL,
//	|			RoomTypesListPerDay.Гостиница,
//	|			RoomTypesListPerDay.Гостиница.Валюта,
//	|			NULL,
//	|			RoomTypesListPerDay.ТипНомера,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			RoomTypesListPerDay.Period,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0
//	|		FROM
//	|			HotelInventoryTotalsPerDay AS RoomTypesListPerDay
//	|		
//	|		UNION ALL
//	|		
//	|		SELECT
//	|			ПродажиКвот.Period,
//	|			ПродажиКвот.Гостиница.Фирма,
//	|			ПродажиКвот.Гостиница,
//	|			ПродажиКвот.Гостиница.Валюта,
//	|			NULL,
//	|			ПродажиКвот.ТипНомера,
//	|			ПродажиКвот.КвотаНомеров.Тариф,
//	|			&qBedAccommodationType,
//	|			ПродажиКвот.КвотаНомеров.Контрагент.ТипКлиента,
//	|			ПродажиКвот.КвотаНомеров.Контрагент.МаретингНапрвл,
//	|			ПродажиКвот.КвотаНомеров.Контрагент.ИсточИнфоГостиница,
//	|			ПродажиКвот.Услуга,
//	|			ПродажиКвот.ТипДеньКалендарь,
//	|			NULL,
//	|			ПродажиКвот.Period,
//	|			NULL,
//	|			ПродажиКвот.КвотаНомеров,
//	|			NULL,
//	|			ПродажиКвот.КвотаНомеров.Контрагент,
//	|			ПродажиКвот.КвотаНомеров.Договор,
//	|			ПродажиКвот.КвотаНомеров.Агент,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			ПродажиКвот.AllotmentPrice,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			ПродажиКвот.КвотаНомеров.Тариф.Скидка,
//	|			ПродажиКвот.КвотаНомеров.Тариф.ТипСкидки,
//	|			NULL,
//	|			ПродажиКвот.КвотаНомеров.Агент.КомиссияАгента,
//	|			ПродажиКвот.КвотаНомеров.Агент.ВидКомиссииАгента,
//	|			ПродажиКвот.КвотаНомеров.Контрагент.PlannedPaymentMethod,
//	|			ПродажиКвот.СтавкаНДС,
//	|			ПродажиКвот.AllotmentAmount,
//	|			ПродажиКвот.AllotmentAmount,
//	|			0,
//	|			CASE
//	|				WHEN ISNULL(ПродажиКвот.СтавкаНДС.Ставка, 0) <> 0
//	|					THEN ПродажиКвот.AllotmentAmount * 100 / (100 + ISNULL(ПродажиКвот.СтавкаНДС.Ставка, 0))
//	|				ELSE ПродажиКвот.AllotmentAmount
//	|			END,
//	|			CASE
//	|				WHEN ISNULL(ПродажиКвот.СтавкаНДС.Ставка, 0) <> 0
//	|					THEN ПродажиКвот.AllotmentAmount * 100 / (100 + ISNULL(ПродажиКвот.СтавкаНДС.Ставка, 0))
//	|				ELSE ПродажиКвот.AllotmentAmount
//	|			END,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			ПродажиКвот.RoomsInQuotaClosingBalance,
//	|			ПродажиКвот.BedsInQuotaClosingBalance,
//	|			0,
//	|			ПродажиКвот.BedsInQuotaClosingBalance,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			0,
//	|			ПродажиКвот.СчетчикДокКвота,
//	|			0
//	|		FROM
//	|			ПродажиКвот AS ПродажиКвот
//	|		WHERE
//	|			&qWithAllotments) AS RoomSales
//	|			LEFT JOIN (SELECT
//	|				HotelInventoryTotalsPerDay.Гостиница AS Гостиница,
//	|				HotelInventoryTotalsPerDay.ТипНомера AS ТипНомера,
//	|				HotelInventoryTotalsPerDay.Period AS Period,
//	|				HotelInventoryTotalsPerDay.CounterClosingBalance AS CounterClosingBalance,
//	|				HotelInventoryTotalsPerDay.ВсегоНомеров AS ВсегоНомеров,
//	|				HotelInventoryTotalsPerDay.ВсегоМест AS ВсегоМест,
//	|				HotelInventoryTotalsPerDay.TotalRoomsBlocked AS TotalRoomsBlocked,
//	|				HotelInventoryTotalsPerDay.TotalBedsBlocked AS TotalBedsBlocked,
//	|				HotelInventoryTotalsPerDay.TotalGuestsReservedReceipt AS TotalGuestsReservedReceipt,
//	|				HotelInventoryTotalsPerDay.TotalGuestsReservedExpense AS TotalGuestsReservedExpense,
//	|				HotelInventoryTotalsPerDay.TotalInHouseGuestsReceipt AS TotalInHouseGuestsReceipt,
//	|				HotelInventoryTotalsPerDay.TotalInHouseGuestsExpense AS TotalInHouseGuestsExpense
//	|			FROM
//	|				HotelInventoryTotalsPerDay AS HotelInventoryTotalsPerDay) AS RoomTypeInventoryTotalsPerDay
//	|			ON RoomSales.Period = RoomTypeInventoryTotalsPerDay.Period
//	|				AND RoomSales.Гостиница = RoomTypeInventoryTotalsPerDay.Гостиница
//	|				AND RoomSales.ТипНомера = RoomTypeInventoryTotalsPerDay.ТипНомера
//	|			LEFT JOIN (SELECT
//	|				RoomSalesPerRoomTypePerDay.Гостиница AS Гостиница,
//	|				RoomSalesPerRoomTypePerDay.ТипНомера AS ТипНомера,
//	|				RoomSalesPerRoomTypePerDay.Period AS Period,
//	|				RoomSalesPerRoomTypePerDay.NumberOfDetailedRows AS NumberOfDetailedRows
//	|			FROM
//	|				RoomSalesPerRoomTypePerDay AS RoomSalesPerRoomTypePerDay) AS RoomSalesPerRoomTypePerDay
//	|			ON RoomSales.Period = RoomSalesPerRoomTypePerDay.Period
//	|				AND RoomSales.Гостиница = RoomSalesPerRoomTypePerDay.Гостиница
//	|				AND RoomSales.ТипНомера = RoomSalesPerRoomTypePerDay.ТипНомера
//	|			LEFT JOIN (SELECT
//	|				HotelInventoryTotalsPerMonth.Гостиница AS Гостиница,
//	|				HotelInventoryTotalsPerMonth.ТипНомера AS ТипНомера,
//	|				HotelInventoryTotalsPerMonth.Period AS Period,
//	|				HotelInventoryTotalsPerMonth.CounterClosingBalance AS CounterClosingBalance,
//	|				HotelInventoryTotalsPerMonth.ВсегоНомеров AS ВсегоНомеров,
//	|				HotelInventoryTotalsPerMonth.ВсегоМест AS ВсегоМест,
//	|				HotelInventoryTotalsPerMonth.TotalRoomsBlocked AS TotalRoomsBlocked,
//	|				HotelInventoryTotalsPerMonth.TotalBedsBlocked AS TotalBedsBlocked,
//	|				HotelInventoryTotalsPerMonth.TotalGuestsReservedReceipt AS TotalGuestsReservedReceipt,
//	|				HotelInventoryTotalsPerMonth.TotalGuestsReservedExpense AS TotalGuestsReservedExpense,
//	|				HotelInventoryTotalsPerMonth.TotalInHouseGuestsReceipt AS TotalInHouseGuestsReceipt,
//	|				HotelInventoryTotalsPerMonth.TotalInHouseGuestsExpense AS TotalInHouseGuestsExpense
//	|			FROM
//	|				HotelInventoryTotalsPerMonth AS HotelInventoryTotalsPerMonth) AS RoomTypeInventoryTotalsPerMonth
//	|			ON (BEGINOFPERIOD(RoomSales.Period, MONTH) = RoomTypeInventoryTotalsPerMonth.Period)
//	|				AND RoomSales.Гостиница = RoomTypeInventoryTotalsPerMonth.Гостиница
//	|				AND RoomSales.ТипНомера = RoomTypeInventoryTotalsPerMonth.ТипНомера
//	|			LEFT JOIN (SELECT
//	|				RoomSalesPerRoomTypePerMonth.Гостиница AS Гостиница,
//	|				RoomSalesPerRoomTypePerMonth.ТипНомера AS ТипНомера,
//	|				RoomSalesPerRoomTypePerMonth.Period AS Period,
//	|				RoomSalesPerRoomTypePerMonth.NumberOfDetailedRows AS NumberOfDetailedRows
//	|			FROM
//	|				RoomSalesPerRoomTypePerMonth AS RoomSalesPerRoomTypePerMonth) AS RoomSalesPerRoomTypePerMonth
//	|			ON (BEGINOFPERIOD(RoomSales.Period, MONTH) = RoomSalesPerRoomTypePerMonth.Period)
//	|				AND RoomSales.Гостиница = RoomSalesPerRoomTypePerMonth.Гостиница
//	|				AND RoomSales.ТипНомера = RoomSalesPerRoomTypePerMonth.ТипНомера
//	|			LEFT JOIN (SELECT
//	|				HotelInventoryTotalsPerPeriod.Гостиница AS Гостиница,
//	|				HotelInventoryTotalsPerPeriod.ТипНомера AS ТипНомера,
//	|				HotelInventoryTotalsPerPeriod.CounterClosingBalance AS CounterClosingBalance,
//	|				HotelInventoryTotalsPerPeriod.ВсегоНомеров AS ВсегоНомеров,
//	|				HotelInventoryTotalsPerPeriod.ВсегоМест AS ВсегоМест,
//	|				HotelInventoryTotalsPerPeriod.TotalRoomsBlocked AS TotalRoomsBlocked,
//	|				HotelInventoryTotalsPerPeriod.TotalBedsBlocked AS TotalBedsBlocked,
//	|				HotelInventoryTotalsPerPeriod.TotalGuestsReservedReceipt AS TotalGuestsReservedReceipt,
//	|				HotelInventoryTotalsPerPeriod.TotalGuestsReservedExpense AS TotalGuestsReservedExpense,
//	|				HotelInventoryTotalsPerPeriod.TotalInHouseGuestsReceipt AS TotalInHouseGuestsReceipt,
//	|				HotelInventoryTotalsPerPeriod.TotalInHouseGuestsExpense AS TotalInHouseGuestsExpense
//	|			FROM
//	|				HotelInventoryTotalsPerPeriod AS HotelInventoryTotalsPerPeriod) AS RoomTypeInventoryTotalsPerPeriod
//	|			ON RoomSales.Гостиница = RoomTypeInventoryTotalsPerPeriod.Гостиница
//	|				AND RoomSales.ТипНомера = RoomTypeInventoryTotalsPerPeriod.ТипНомера
//	|			LEFT JOIN (SELECT
//	|				RoomSalesPerRoomTypePerPeriod.Гостиница AS Гостиница,
//	|				RoomSalesPerRoomTypePerPeriod.ТипНомера AS ТипНомера,
//	|				RoomSalesPerRoomTypePerPeriod.NumberOfDetailedRows AS NumberOfDetailedRows
//	|			FROM
//	|				RoomSalesPerRoomTypePerPeriod AS RoomSalesPerRoomTypePerPeriod) AS RoomSalesPerRoomTypePerPeriod
//	|			ON RoomSales.Гостиница = RoomSalesPerRoomTypePerPeriod.Гостиница
//	|				AND RoomSales.ТипНомера = RoomSalesPerRoomTypePerPeriod.ТипНомера
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
//	|			ON RoomSales.Гостиница = InventoryTotals.Гостиница
//	|			LEFT JOIN (SELECT
//	|				RoomInventoryTotals.Гостиница AS Гостиница,
//	|				RoomInventoryTotals.НомерРазмещения AS НомерРазмещения,
//	|				RoomInventoryTotals.ВсегоНомеров AS ВсегоНомеров,
//	|				RoomInventoryTotals.ВсегоМест AS ВсегоМест,
//	|				RoomInventoryTotals.TotalRoomsBlocked AS TotalRoomsBlocked,
//	|				RoomInventoryTotals.TotalBedsBlocked AS TotalBedsBlocked
//	|			FROM
//	|				RoomInventoryTotals AS RoomInventoryTotals) AS RoomInventoryTotals
//	|			ON RoomSales.Гостиница = RoomInventoryTotals.Гостиница
//	|				AND RoomSales.НомерРазмещения = RoomInventoryTotals.НомерРазмещения
//	|			LEFT JOIN (SELECT
//	|				RoomTotalSales.Гостиница AS Гостиница,
//	|				RoomTotalSales.TotalBedsRented AS TotalBedsRented,
//	|				RoomTotalSales.TotalRoomsRented AS TotalRoomsRented,
//	|				RoomTotalSales.TotalSalesAmount AS TotalSalesAmount
//	|			FROM
//	|				RoomTotalSales AS RoomTotalSales) AS TotalSales
//	|			ON RoomSales.Гостиница = TotalSales.Гостиница
//	|			LEFT JOIN (SELECT
//	|				КалендарьДень.ТипДеньКалендарь AS ТипДеньКалендарь,
//	|				КалендарьДень.Period AS Period
//	|			FROM
//	|				InformationRegister.КалендарьДень AS КалендарьДень
//	|			WHERE
//	|				КалендарьДень.Calendar = &qCalendar) AS CalendarDayTypes
//	|			ON RoomSales.Period = CalendarDayTypes.Period
//	|			LEFT JOIN (SELECT
//	|				RoomSalesPerRoomTypeAndCalendarDayTypePerDay.Гостиница AS Гостиница,
//	|				RoomSalesPerRoomTypeAndCalendarDayTypePerDay.ТипНомера AS ТипНомера,
//	|				RoomSalesPerRoomTypeAndCalendarDayTypePerDay.ТипДеньКалендарь AS ТипДеньКалендарь,
//	|				RoomSalesPerRoomTypeAndCalendarDayTypePerDay.Period AS Period,
//	|				RoomSalesPerRoomTypeAndCalendarDayTypePerDay.NumberOfDetailedRows AS NumberOfDetailedRows
//	|			FROM
//	|				RoomSalesPerRoomTypeAndCalendarDayTypePerDay AS RoomSalesPerRoomTypeAndCalendarDayTypePerDay) AS RoomSalesPerRoomTypeAndCalendarDayTypePerDay
//	|			ON RoomSales.Period = RoomSalesPerRoomTypeAndCalendarDayTypePerDay.Period
//	|				AND RoomSales.Гостиница = RoomSalesPerRoomTypeAndCalendarDayTypePerDay.Гостиница
//	|				AND RoomSales.ТипНомера = RoomSalesPerRoomTypeAndCalendarDayTypePerDay.ТипНомера
//	|				AND RoomSales.ТипДеньКалендарь = RoomSalesPerRoomTypeAndCalendarDayTypePerDay.ТипДеньКалендарь
//	|			LEFT JOIN (SELECT
//	|				RoomSalesPerRoomTypeAndChoosenCalendarDayTypePerDay.Гостиница AS Гостиница,
//	|				RoomSalesPerRoomTypeAndChoosenCalendarDayTypePerDay.ТипНомера AS ТипНомера,
//	|				RoomSalesPerRoomTypeAndChoosenCalendarDayTypePerDay.ТипДеньКалендарь AS ТипДеньКалендарь,
//	|				RoomSalesPerRoomTypeAndChoosenCalendarDayTypePerDay.Period AS Period,
//	|				RoomSalesPerRoomTypeAndChoosenCalendarDayTypePerDay.NumberOfDetailedRows AS NumberOfDetailedRows
//	|			FROM
//	|				RoomSalesPerRoomTypeAndChoosenCalendarDayTypePerDay AS RoomSalesPerRoomTypeAndChoosenCalendarDayTypePerDay) AS RoomSalesPerRoomTypeAndChoosenCalendarDayTypePerDay
//	|			ON RoomSales.Period = RoomSalesPerRoomTypeAndChoosenCalendarDayTypePerDay.Period
//	|				AND RoomSales.Гостиница = RoomSalesPerRoomTypeAndChoosenCalendarDayTypePerDay.Гостиница
//	|				AND RoomSales.ТипНомера = RoomSalesPerRoomTypeAndChoosenCalendarDayTypePerDay.ТипНомера
//	|				AND (CalendarDayTypes.ТипДеньКалендарь = RoomSalesPerRoomTypeAndChoosenCalendarDayTypePerDay.ТипДеньКалендарь)) AS ОборотыПродажиНомеров
//	|{WHERE
//	|	ОборотыПродажиНомеров.Фирма.*,
//	|	ОборотыПродажиНомеров.Гостиница.*,
//	|	ОборотыПродажиНомеров.Валюта.*,
//	|	ОборотыПродажиНомеров.НомерРазмещения.*,
//	|	ОборотыПродажиНомеров.ТипНомера.*,
//	|	ОборотыПродажиНомеров.Тариф.*,
//	|	ОборотыПродажиНомеров.ТипДеньКалендарь.*,
//	|	ОборотыПродажиНомеров.ПризнакЦены.*,
//	|	ОборотыПродажиНомеров.ExtCalendarDayType.*,
//	|	ОборотыПродажиНомеров.ВидРазмещения.*,
//	|	ОборотыПродажиНомеров.ТипКлиента.*,
//	|	ОборотыПродажиНомеров.МаретингНапрвл.*,
//	|	ОборотыПродажиНомеров.ИсточИнфоГостиница.*,
//	|	ОборотыПродажиНомеров.ДокОснование.*,
//	|	ОборотыПродажиНомеров.Reservation.* AS Reservation,
//	|	ОборотыПродажиНомеров.ReservationDate AS ReservationDate,
//	|	ОборотыПродажиНомеров.ReservationWeek AS ReservationWeek,
//	|	ОборотыПродажиНомеров.ReservationMonth AS ReservationMonth,
//	|	ОборотыПродажиНомеров.ReservationYear AS ReservationYear,
//	|	ОборотыПродажиНомеров.DaysBeforeCheckIn AS DaysBeforeCheckIn,
//	|	ОборотыПродажиНомеров.WeeksBeforeCheckIn AS WeeksBeforeCheckIn,
//	|	ОборотыПродажиНомеров.MonthsBeforeCheckIn AS MonthsBeforeCheckIn,
//	|	ОборотыПродажиНомеров.КвотаНомеров.*,
//	|	ОборотыПродажиНомеров.Услуга.*,
//	|	ОборотыПродажиНомеров.RoomPrice AS RoomPrice,
//	|	ОборотыПродажиНомеров.ГруппаГостей.* AS ГруппаГостей,
//	|	ОборотыПродажиНомеров.Контрагент.* AS Контрагент,
//	|	ОборотыПродажиНомеров.Договор.* AS Договор,
//	|	ОборотыПродажиНомеров.Агент.* AS Агент,
//	|	ОборотыПродажиНомеров.Клиент.* AS Клиент,
//	|	ОборотыПродажиНомеров.Ресурс.* AS Ресурс,
//	|	ОборотыПродажиНомеров.СчетПроживания.* AS СчетПроживания,
//	|	ОборотыПродажиНомеров.Цена AS Цена,
//	|	ОборотыПродажиНомеров.ТипРесурса.* AS ТипРесурса,
//	|	ОборотыПродажиНомеров.TripPurpose.* AS TripPurpose,
//	|	ОборотыПродажиНомеров.ПутевкаКурсовка.* AS ПутевкаКурсовка,
//	|	ОборотыПродажиНомеров.Автор.* AS Автор,
//	|	ОборотыПродажиНомеров.Скидка AS Скидка,
//	|	ОборотыПродажиНомеров.ТипСкидки.* AS ТипСкидки,
//	|	ОборотыПродажиНомеров.ДисконтКарт.* AS ДисконтКарт,
//	|	ОборотыПродажиНомеров.КомиссияАгента AS КомиссияАгента,
//	|	ОборотыПродажиНомеров.ВидКомиссииАгента.* AS ВидКомиссииАгента,
//	|	ОборотыПродажиНомеров.СпособОплаты.* AS СпособОплаты,
//	|	ОборотыПродажиНомеров.СтавкаНДС.* AS СтавкаНДС,
//	|	ОборотыПродажиНомеров.Продажи AS Продажи,
//	|	ОборотыПродажиНомеров.SalesWithoutCommission AS SalesWithoutCommission,
//	|	ОборотыПродажиНомеров.ДоходНомеров AS ДоходНомеров,
//	|	ОборотыПродажиНомеров.RoomRevenueWithoutCommission AS RoomRevenueWithoutCommission,
//	|	ОборотыПродажиНомеров.InPriceRevenue AS InPriceRevenue,
//	|	ОборотыПродажиНомеров.InPriceRevenueWithoutCommission AS InPriceRevenueWithoutCommission,
//	|	ОборотыПродажиНомеров.ДоходДопМеста AS ДоходДопМеста,
//	|	ОборотыПродажиНомеров.RoomRevenueWithoutExtraBed AS RoomRevenueWithoutExtraBed,
//	|	ОборотыПродажиНомеров.ПродажиБезНДС AS ПродажиБезНДС,
//	|	ОборотыПродажиНомеров.SalesWithoutVATWithoutCommission AS SalesWithoutVATWithoutCommission,
//	|	ОборотыПродажиНомеров.ДоходПродажиБезНДС AS ДоходПродажиБезНДС,
//	|	ОборотыПродажиНомеров.RoomRevenueWithoutVATWithoutCommission AS RoomRevenueWithoutVATWithoutCommission,
//	|	ОборотыПродажиНомеров.InPriceRevenueWithoutVAT AS InPriceRevenueWithoutVAT,
//	|	ОборотыПродажиНомеров.InPriceRevenueWithoutVATWithoutCommission AS InPriceRevenueWithoutVATWithoutCommission,
//	|	ОборотыПродажиНомеров.ДоходДопМестаБезНДС AS ДоходДопМестаБезНДС,
//	|	ОборотыПродажиНомеров.RoomRevenueWithoutExtraBedWithoutVAT AS RoomRevenueWithoutExtraBedWithoutVAT,
//	|	ОборотыПродажиНомеров.СуммаКомиссии AS СуммаКомиссии,
//	|	ОборотыПродажиНомеров.КомиссияБезНДС AS КомиссияБезНДС,
//	|	ОборотыПродажиНомеров.СуммаСкидки AS СуммаСкидки,
//	|	ОборотыПродажиНомеров.СуммаСкидкиБезНДС AS СуммаСкидкиБезНДС,
//	|	ОборотыПродажиНомеров.ExtraBedDiscountSum AS ExtraBedDiscountSum,
//	|	ОборотыПродажиНомеров.DiscountSumWithoutExtraBed AS DiscountSumWithoutExtraBed,
//	|	ОборотыПродажиНомеров.ПроданоНомеров AS ПроданоНомеров,
//	|	ОборотыПродажиНомеров.ПроданоМест AS ПроданоМест,
//	|	ОборотыПродажиНомеров.ПроданоДопМест AS ПроданоДопМест,
//	|	ОборотыПродажиНомеров.ЧеловекаДни AS ЧеловекаДни,
//	|	ОборотыПродажиНомеров.GuestDaysWithoutExtraBed AS GuestDaysWithoutExtraBed,
//	|	ОборотыПродажиНомеров.ExtraBedGuestDays AS ExtraBedGuestDays,
//	|	ОборотыПродажиНомеров.ЗаездГостей AS ЗаездГостей,
//	|	ОборотыПродажиНомеров.ЗаездНомеров AS ЗаездНомеров,
//	|	ОборотыПродажиНомеров.ЗаездМест AS ЗаездМест,
//	|	ОборотыПродажиНомеров.ЗаездДополнительныхМест AS ЗаездДополнительныхМест,
//	|	ОборотыПродажиНомеров.Количество AS Количество,
//	|	ОборотыПродажиНомеров.УчетнаяДата,
//	|	(DAY(ОборотыПродажиНомеров.УчетнаяДата)) AS AccountingDay,
//	|	(WEEKDAY(ОборотыПродажиНомеров.УчетнаяДата)) AS AccountingWeekday,
//	|	(WEEK(ОборотыПродажиНомеров.УчетнаяДата)) AS AccountingWeek,
//	|	(MONTH(ОборотыПродажиНомеров.УчетнаяДата)) AS AccountingMonth,
//	|	(QUARTER(ОборотыПродажиНомеров.УчетнаяДата)) AS AccountingQuarter,
//	|	(YEAR(ОборотыПродажиНомеров.УчетнаяДата)) AS AccountingYear}
//	|
//	|ORDER BY
//	|	Валюта,
//	|	НомерРазмещения
//	|{ORDER BY
//	|	Фирма.*,
//	|	Гостиница.*,
//	|	Валюта.*,
//	|	НомерРазмещения.*,
//	|	ТипНомера.*,
//	|	Тариф.*,
//	|	ТипДеньКалендарь.*,
//	|	ПризнакЦены.*,
//	|	ОборотыПродажиНомеров.ExtCalendarDayType.*,
//	|	ВидРазмещения.*,
//	|	ТипКлиента.*,
//	|	МаретингНапрвл.*,
//	|	ИсточИнфоГостиница.*,
//	|	Услуга.*,
//	|	ДокОснование.*,
//	|	ОборотыПродажиНомеров.Reservation.* AS Reservation,
//	|	ОборотыПродажиНомеров.ReservationDate AS ReservationDate,
//	|	ОборотыПродажиНомеров.ReservationWeek AS ReservationWeek,
//	|	ОборотыПродажиНомеров.ReservationMonth AS ReservationMonth,
//	|	ОборотыПродажиНомеров.ReservationYear AS ReservationYear,
//	|	ОборотыПродажиНомеров.DaysBeforeCheckIn AS DaysBeforeCheckIn,
//	|	ОборотыПродажиНомеров.WeeksBeforeCheckIn AS WeeksBeforeCheckIn,
//	|	ОборотыПродажиНомеров.MonthsBeforeCheckIn AS MonthsBeforeCheckIn,
//	|	КвотаНомеров.*,
//	|	RoomPrice,
//	|	ОборотыПродажиНомеров.ГруппаГостей.* AS ГруппаГостей,
//	|	ОборотыПродажиНомеров.Контрагент.* AS Контрагент,
//	|	ОборотыПродажиНомеров.Договор.* AS Договор,
//	|	ОборотыПродажиНомеров.Агент.* AS Агент,
//	|	ОборотыПродажиНомеров.Клиент.* AS Клиент,
//	|	ОборотыПродажиНомеров.Ресурс.* AS Ресурс,
//	|	ОборотыПродажиНомеров.СчетПроживания.* AS СчетПроживания,
//	|	ОборотыПродажиНомеров.Цена AS Цена,
//	|	ОборотыПродажиНомеров.ТипРесурса.* AS ТипРесурса,
//	|	ОборотыПродажиНомеров.TripPurpose.* AS TripPurpose,
//	|	ОборотыПродажиНомеров.ПутевкаКурсовка.* AS ПутевкаКурсовка,
//	|	ОборотыПродажиНомеров.Автор.* AS Автор,
//	|	ОборотыПродажиНомеров.Скидка AS Скидка,
//	|	ОборотыПродажиНомеров.ТипСкидки.* AS ТипСкидки,
//	|	ОборотыПродажиНомеров.ДисконтКарт.* AS ДисконтКарт,
//	|	ОборотыПродажиНомеров.КомиссияАгента AS КомиссияАгента,
//	|	ОборотыПродажиНомеров.ВидКомиссииАгента.* AS ВидКомиссииАгента,
//	|	ОборотыПродажиНомеров.СпособОплаты.* AS СпособОплаты,
//	|	ОборотыПродажиНомеров.СтавкаНДС.* AS СтавкаНДС,
//	|	Продажи,
//	|	SalesWithoutCommission,
//	|	ДоходНомеров,
//	|	RoomRevenueWithoutCommission,
//	|	InPriceRevenue,
//	|	InPriceRevenueWithoutCommission,
//	|	ДоходДопМеста,
//	|	RoomRevenueWithoutExtraBed,
//	|	ПродажиБезНДС,
//	|	SalesWithoutVATWithoutCommission,
//	|	ДоходПродажиБезНДС,
//	|	RoomRevenueWithoutVATWithoutCommission,
//	|	InPriceRevenueWithoutVAT,
//	|	InPriceRevenueWithoutVATWithoutCommission,
//	|	ДоходДопМестаБезНДС,
//	|	RoomRevenueWithoutExtraBedWithoutVAT,
//	|	СуммаКомиссии,
//	|	КомиссияБезНДС,
//	|	СуммаСкидки,
//	|	СуммаСкидкиБезНДС,
//	|	ExtraBedDiscountSum,
//	|	DiscountSumWithoutExtraBed,
//	|	ПроданоНомеров,
//	|	ПроданоМест,
//	|	ПроданоДопМест,
//	|	ЧеловекаДни,
//	|	ExtraBedGuestDays,
//	|	GuestDaysWithoutExtraBed,
//	|	ЗаездГостей,
//	|	ЗаездНомеров,
//	|	ЗаездМест,
//	|	ЗаездДополнительныхМест,
//	|	Количество,
//	|	TotalSalesAmount,
//	|	TotalSalesPercent,
//	|	TotalBedsRentedPercent,
//	|	TotalRoomsRentedPercent,
//	|	УчетнаяДата,
//	|	(DAY(ОборотыПродажиНомеров.УчетнаяДата)) AS AccountingDay,
//	|	(WEEKDAY(ОборотыПродажиНомеров.УчетнаяДата)) AS AccountingWeekday,
//	|	(CASE
//	|			WHEN WEEKDAY(ОборотыПродажиНомеров.УчетнаяДата) = 1
//	|				THEN &qMonday
//	|			WHEN WEEKDAY(ОборотыПродажиНомеров.УчетнаяДата) = 2
//	|				THEN &qTuesday
//	|			WHEN WEEKDAY(ОборотыПродажиНомеров.УчетнаяДата) = 3
//	|				THEN &qWednesday
//	|			WHEN WEEKDAY(ОборотыПродажиНомеров.УчетнаяДата) = 4
//	|				THEN &qThursday
//	|			WHEN WEEKDAY(ОборотыПродажиНомеров.УчетнаяДата) = 5
//	|				THEN &qFriday
//	|			WHEN WEEKDAY(ОборотыПродажиНомеров.УчетнаяДата) = 6
//	|				THEN &qSaturday
//	|			WHEN WEEKDAY(ОборотыПродажиНомеров.УчетнаяДата) = 7
//	|				THEN &qSunday
//	|			ELSE NULL
//	|		END) AS AccountingWeekdayName,
//	|	(WEEK(ОборотыПродажиНомеров.УчетнаяДата)) AS AccountingWeek,
//	|	(MONTH(ОборотыПродажиНомеров.УчетнаяДата)) AS AccountingMonth,
//	|	(QUARTER(ОборотыПродажиНомеров.УчетнаяДата)) AS AccountingQuarter,
//	|	(YEAR(ОборотыПродажиНомеров.УчетнаяДата)) AS AccountingYear}
//	|TOTALS
//	|	SUM(Продажи),
//	|	SUM(SalesWithoutCommission),
//	|	SUM(ДоходНомеров),
//	|	SUM(RoomRevenueWithoutCommission),
//	|	SUM(InPriceRevenue),
//	|	SUM(InPriceRevenueWithoutCommission),
//	|	SUM(ДоходДопМеста),
//	|	SUM(RoomRevenueWithoutExtraBed),
//	|	SUM(ПродажиБезНДС),
//	|	SUM(SalesWithoutVATWithoutCommission),
//	|	SUM(ДоходПродажиБезНДС),
//	|	SUM(RoomRevenueWithoutVATWithoutCommission),
//	|	SUM(InPriceRevenueWithoutVAT),
//	|	SUM(InPriceRevenueWithoutVATWithoutCommission),
//	|	SUM(ДоходДопМестаБезНДС),
//	|	SUM(RoomRevenueWithoutExtraBedWithoutVAT),
//	|	SUM(СуммаКомиссии),
//	|	SUM(КомиссияБезНДС),
//	|	SUM(СуммаСкидки),
//	|	SUM(СуммаСкидкиБезНДС),
//	|	SUM(ExtraBedDiscountSum),
//	|	SUM(DiscountSumWithoutExtraBed),
//	|	CAST(SUM(ПроданоНомеров) AS NUMBER(17, 3)) AS ПроданоНомеров,
//	|	CAST(SUM(ПроданоМест) AS NUMBER(17, 3)) AS ПроданоМест,
//	|	CAST(SUM(ПроданоДопМест) AS NUMBER(17, 3)) AS ПроданоДопМест,
//	|	CAST(SUM(ЧеловекаДни) AS NUMBER(17, 3)) AS ЧеловекаДни,
//	|	CAST(SUM(GuestDaysWithoutExtraBed) AS NUMBER(17, 3)) AS GuestDaysWithoutExtraBed,
//	|	CAST(SUM(ExtraBedGuestDays) AS NUMBER(17, 3)) AS ExtraBedGuestDays,
//	|	CAST(SUM(ЗаездГостей) AS NUMBER(17, 3)) AS ЗаездГостей,
//	|	CAST(SUM(ЗаездНомеров) AS NUMBER(17, 3)) AS ЗаездНомеров,
//	|	CAST(SUM(ЗаездМест) AS NUMBER(17, 3)) AS ЗаездМест,
//	|	CAST(SUM(ЗаездДополнительныхМест) AS NUMBER(17, 3)) AS ЗаездДополнительныхМест,
//	|	CAST(SUM(Количество) AS NUMBER(17, 3)) AS Количество,
//	|	CAST(MAX(RoomsPerPeriod) AS NUMBER(17, 0)) AS RoomsPerPeriod,
//	|	CAST(MAX(BedsPerPeriod) AS NUMBER(17, 0)) AS BedsPerPeriod,
//	|	CAST(MAX(RoomsBlockedPerPeriod) AS NUMBER(17, 3)) AS RoomsBlockedPerPeriod,
//	|	CAST(MAX(BedsBlockedPerPeriod) AS NUMBER(17, 3)) AS BedsBlockedPerPeriod,
//	|	CAST(SUM(RoomsPerRoomTypePerDay) AS NUMBER(17, 0)) AS RoomsPerRoomTypePerDay,
//	|	CAST(SUM(BedsPerRoomTypePerDay) AS NUMBER(17, 0)) AS BedsPerRoomTypePerDay,
//	|	CAST(SUM(RoomsBlockedPerRoomTypePerDay) AS NUMBER(17, 3)) AS RoomsBlockedPerRoomTypePerDay,
//	|	CAST(SUM(BedsBlockedPerRoomTypePerDay) AS NUMBER(17, 3)) AS BedsBlockedPerRoomTypePerDay,
//	|	CAST(SUM(RoomsPerRoomTypePerMonth) AS NUMBER(17, 0)) AS RoomsPerRoomTypePerMonth,
//	|	CAST(SUM(BedsPerRoomTypePerMonth) AS NUMBER(17, 0)) AS BedsPerRoomTypePerMonth,
//	|	CAST(SUM(RoomsBlockedPerRoomTypePerMonth) AS NUMBER(17, 3)) AS RoomsBlockedPerRoomTypePerMonth,
//	|	CAST(SUM(BedsBlockedPerRoomTypePerMonth) AS NUMBER(17, 3)) AS BedsBlockedPerRoomTypePerMonth,
//	|	CAST(SUM(RoomsPerRoomTypePerPeriod) AS NUMBER(17, 0)) AS RoomsPerRoomTypePerPeriod,
//	|	CAST(SUM(BedsPerRoomTypePerPeriod) AS NUMBER(17, 0)) AS BedsPerRoomTypePerPeriod,
//	|	CAST(SUM(RoomsBlockedPerRoomTypePerPeriod) AS NUMBER(17, 3)) AS RoomsBlockedPerRoomTypePerPeriod,
//	|	CAST(SUM(BedsBlockedPerRoomTypePerPeriod) AS NUMBER(17, 3)) AS BedsBlockedPerRoomTypePerPeriod,
//	|	CAST(SUM(RoomsPerRoomTypeAndCalendarDayTypePerDay) AS NUMBER(17, 0)) AS RoomsPerRoomTypeAndCalendarDayTypePerDay,
//	|	CAST(SUM(BedsPerRoomTypeAndCalendarDayTypePerDay) AS NUMBER(17, 0)) AS BedsPerRoomTypeAndCalendarDayTypePerDay,
//	|	CAST(SUM(RoomsBlockedPerRoomTypeAndCalendarDayTypePerDay) AS NUMBER(17, 3)) AS RoomsBlockedPerRoomTypeAndCalendarDayTypePerDay,
//	|	CAST(SUM(BedsBlockedPerRoomTypeAndCalendarDayTypePerDay) AS NUMBER(17, 3)) AS BedsBlockedPerRoomTypeAndCalendarDayTypePerDay,
//	|	CAST(SUM(RoomsPerRoomTypeAndChoosenCalendarDayTypePerDay) AS NUMBER(17, 0)) AS RoomsPerRoomTypeAndChoosenCalendarDayTypePerDay,
//	|	CAST(SUM(BedsPerRoomTypeAndChoosenCalendarDayTypePerDay) AS NUMBER(17, 0)) AS BedsPerRoomTypeAndChoosenCalendarDayTypePerDay,
//	|	CAST(SUM(RoomsBlockedPerRoomTypeAndChoosenCalendarDayTypePerDay) AS NUMBER(17, 3)) AS RoomsBlockedPerRoomTypeAndChoosenCalendarDayTypePerDay,
//	|	CAST(SUM(BedsBlockedPerRoomTypeAndChoosenCalendarDayTypePerDay) AS NUMBER(17, 3)) AS BedsBlockedPerRoomTypeAndChoosenCalendarDayTypePerDay,
//	|	CASE
//	|		WHEN SUM(ПроданоНомеров) = 0
//	|			THEN 0
//	|		ELSE CAST(SUM(ДоходНомеров) / SUM(ПроданоНомеров) AS NUMBER(17, 2))
//	|	END AS AverageRoomPrice,
//	|	CASE
//	|		WHEN SUM(ПроданоМест) = 0
//	|			THEN 0
//	|		ELSE CAST(SUM(ДоходНомеров) / SUM(ПроданоМест) AS NUMBER(17, 2))
//	|	END AS AverageBedPrice,
//	|	CASE
//	|		WHEN SUM(ПроданоНомеров) = 0
//	|			THEN 0
//	|		ELSE CAST(SUM(ДоходПродажиБезНДС) / SUM(ПроданоНомеров) AS NUMBER(17, 2))
//	|	END AS AverageRoomPriceWithoutVAT,
//	|	CASE
//	|		WHEN SUM(ПроданоМест) = 0
//	|			THEN 0
//	|		ELSE CAST(SUM(ДоходПродажиБезНДС) / SUM(ПроданоМест) AS NUMBER(17, 2))
//	|	END AS AverageBedPriceWithoutVAT,
//	|	CASE
//	|		WHEN MAX(RoomsPerPeriod) = 0
//	|			THEN 0
//	|		ELSE CAST(SUM(ДоходНомеров) / MAX(RoomsPerPeriod) AS NUMBER(17, 2))
//	|	END AS RevPAR,
//	|	CASE
//	|		WHEN MAX(BedsPerPeriod) = 0
//	|			THEN 0
//	|		ELSE CAST(SUM(ДоходНомеров) / MAX(BedsPerPeriod) AS NUMBER(17, 2))
//	|	END AS RevPAB,
//	|	CASE
//	|		WHEN MAX(RoomsPerPeriod) = 0
//	|			THEN 0
//	|		ELSE CAST(SUM(ДоходПродажиБезНДС) / MAX(RoomsPerPeriod) AS NUMBER(17, 2))
//	|	END AS RevPARWithoutVAT,
//	|	CASE
//	|		WHEN MAX(BedsPerPeriod) = 0
//	|			THEN 0
//	|		ELSE CAST(SUM(ДоходПродажиБезНДС) / MAX(BedsPerPeriod) AS NUMBER(17, 2))
//	|	END AS RevPABWithoutVAT,
//	|	CASE
//	|		WHEN SUM(RoomsPerRoomTypePerDay) = 0
//	|			THEN 0
//	|		ELSE CAST(SUM(ДоходНомеров) / SUM(RoomsPerRoomTypePerDay) AS NUMBER(17, 2))
//	|	END AS RevPARPerRoomTypePerDay,
//	|	CASE
//	|		WHEN SUM(BedsPerRoomTypePerDay) = 0
//	|			THEN 0
//	|		ELSE CAST(SUM(ДоходНомеров) / SUM(BedsPerRoomTypePerDay) AS NUMBER(17, 2))
//	|	END AS RevPABPerRoomTypePerDay,
//	|	CASE
//	|		WHEN SUM(RoomsPerRoomTypePerDay) = 0
//	|			THEN 0
//	|		ELSE CAST(SUM(ДоходПродажиБезНДС) / SUM(RoomsPerRoomTypePerDay) AS NUMBER(17, 2))
//	|	END AS RevPARWithoutVATPerRoomTypePerDay,
//	|	CASE
//	|		WHEN SUM(BedsPerRoomTypePerDay) = 0
//	|			THEN 0
//	|		ELSE CAST(SUM(ДоходПродажиБезНДС) / SUM(BedsPerRoomTypePerDay) AS NUMBER(17, 2))
//	|	END AS RevPABWithoutVATPerRoomTypePerDay,
//	|	CASE
//	|		WHEN SUM(RoomsPerRoomTypePerMonth) = 0
//	|			THEN 0
//	|		ELSE CAST(SUM(ДоходНомеров) / SUM(RoomsPerRoomTypePerMonth) AS NUMBER(17, 2))
//	|	END AS RevPARPerRoomTypePerMonth,
//	|	CASE
//	|		WHEN SUM(BedsPerRoomTypePerMonth) = 0
//	|			THEN 0
//	|		ELSE CAST(SUM(ДоходНомеров) / SUM(BedsPerRoomTypePerMonth) AS NUMBER(17, 2))
//	|	END AS RevPABPerRoomTypePerMonth,
//	|	CASE
//	|		WHEN SUM(RoomsPerRoomTypePerMonth) = 0
//	|			THEN 0
//	|		ELSE CAST(SUM(ДоходПродажиБезНДС) / SUM(RoomsPerRoomTypePerMonth) AS NUMBER(17, 2))
//	|	END AS RevPARWithoutVATPerRoomTypePerMonth,
//	|	CASE
//	|		WHEN SUM(BedsPerRoomTypePerMonth) = 0
//	|			THEN 0
//	|		ELSE CAST(SUM(ДоходПродажиБезНДС) / SUM(BedsPerRoomTypePerMonth) AS NUMBER(17, 2))
//	|	END AS RevPABWithoutVATPerRoomTypePerMonth,
//	|	CASE
//	|		WHEN SUM(RoomsPerRoomTypePerPeriod) = 0
//	|			THEN 0
//	|		ELSE CAST(SUM(ДоходНомеров) / SUM(RoomsPerRoomTypePerPeriod) AS NUMBER(17, 2))
//	|	END AS RevPARPerRoomTypePerPeriod,
//	|	CASE
//	|		WHEN SUM(BedsPerRoomTypePerPeriod) = 0
//	|			THEN 0
//	|		ELSE CAST(SUM(ДоходНомеров) / SUM(BedsPerRoomTypePerPeriod) AS NUMBER(17, 2))
//	|	END AS RevPABPerRoomTypePerPeriod,
//	|	CASE
//	|		WHEN SUM(RoomsPerRoomTypePerPeriod) = 0
//	|			THEN 0
//	|		ELSE CAST(SUM(ДоходПродажиБезНДС) / SUM(RoomsPerRoomTypePerPeriod) AS NUMBER(17, 2))
//	|	END AS RevPARWithoutVATPerRoomTypePerPeriod,
//	|	CASE
//	|		WHEN SUM(BedsPerRoomTypePerPeriod) = 0
//	|			THEN 0
//	|		ELSE CAST(SUM(ДоходПродажиБезНДС) / SUM(BedsPerRoomTypePerPeriod) AS NUMBER(17, 2))
//	|	END AS RevPABWithoutVATPerRoomTypePerPeriod,
//	|	CASE
//	|		WHEN MAX(RoomsPerPeriod) = 0
//	|			THEN 0
//	|		ELSE CAST(SUM(ПроданоНомеров) * 100 / MAX(RoomsPerPeriod) AS NUMBER(17, 3))
//	|	END AS RoomsRentedPercent,
//	|	CASE
//	|		WHEN MAX(BedsPerPeriod) = 0
//	|			THEN 0
//	|		ELSE CAST(SUM(ПроданоМест) * 100 / MAX(BedsPerPeriod) AS NUMBER(17, 3))
//	|	END AS BedsRentedPercent,
//	|	CASE
//	|		WHEN MAX(RoomsPerPeriod) - MAX(RoomsBlockedPerPeriod) = 0
//	|			THEN 0
//	|		ELSE CAST(SUM(ПроданоНомеров) * 100 / (MAX(RoomsPerPeriod) - MAX(RoomsBlockedPerPeriod)) AS NUMBER(17, 3))
//	|	END AS RoomsRentedPercentWithRoomBlocks,
//	|	CASE
//	|		WHEN MAX(BedsPerPeriod) - MAX(BedsBlockedPerPeriod) = 0
//	|			THEN 0
//	|		ELSE CAST(SUM(ПроданоМест) * 100 / (MAX(BedsPerPeriod) - MAX(BedsBlockedPerPeriod)) AS NUMBER(17, 3))
//	|	END AS BedsRentedPercentWithRoomBlocks,
//	|	CASE
//	|		WHEN SUM(RoomsPerRoomTypePerDay) = 0
//	|			THEN 0
//	|		ELSE CAST(SUM(ПроданоНомеров) * 100 / SUM(RoomsPerRoomTypePerDay) AS NUMBER(17, 3))
//	|	END AS RoomsRentedPercentPerRoomTypePerDay,
//	|	CASE
//	|		WHEN SUM(BedsPerRoomTypePerDay) = 0
//	|			THEN 0
//	|		ELSE CAST(SUM(ПроданоМест) * 100 / SUM(BedsPerRoomTypePerDay) AS NUMBER(17, 3))
//	|	END AS BedsRentedPercentPerRoomTypePerDay,
//	|	CASE
//	|		WHEN SUM(RoomsPerRoomTypePerDay) - SUM(RoomsBlockedPerRoomTypePerDay) = 0
//	|			THEN 0
//	|		ELSE CAST(SUM(ПроданоНомеров) * 100 / (SUM(RoomsPerRoomTypePerDay) - SUM(RoomsBlockedPerRoomTypePerDay)) AS NUMBER(17, 3))
//	|	END AS RoomsRentedPercentWithRoomBlocksPerRoomTypePerDay,
//	|	CASE
//	|		WHEN SUM(BedsPerRoomTypePerDay) - SUM(BedsBlockedPerRoomTypePerDay) = 0
//	|			THEN 0
//	|		ELSE CAST(SUM(ПроданоМест) * 100 / (SUM(BedsPerRoomTypePerDay) - SUM(BedsBlockedPerRoomTypePerDay)) AS NUMBER(17, 3))
//	|	END AS BedsRentedPercentWithRoomBlocksPerRoomTypePerDay,
//	|	CASE
//	|		WHEN SUM(RoomsPerRoomTypePerMonth) = 0
//	|			THEN 0
//	|		ELSE CAST(SUM(ПроданоНомеров) * 100 / SUM(RoomsPerRoomTypePerMonth) AS NUMBER(17, 3))
//	|	END AS RoomsRentedPercentPerRoomTypePerMonth,
//	|	CASE
//	|		WHEN SUM(BedsPerRoomTypePerMonth) = 0
//	|			THEN 0
//	|		ELSE CAST(SUM(ПроданоМест) * 100 / SUM(BedsPerRoomTypePerMonth) AS NUMBER(17, 2))
//	|	END AS BedsRentedPercentPerRoomTypePerMonth,
//	|	CASE
//	|		WHEN SUM(RoomsPerRoomTypePerMonth) - SUM(RoomsBlockedPerRoomTypePerMonth) = 0
//	|			THEN 0
//	|		ELSE CAST(SUM(ПроданоНомеров) * 100 / (SUM(RoomsPerRoomTypePerMonth) - SUM(RoomsBlockedPerRoomTypePerMonth)) AS NUMBER(17, 3))
//	|	END AS RoomsRentedPercentWithRoomBlocksPerRoomTypePerMonth,
//	|	CASE
//	|		WHEN SUM(BedsPerRoomTypePerMonth) - SUM(BedsBlockedPerRoomTypePerMonth) = 0
//	|			THEN 0
//	|		ELSE CAST(SUM(ПроданоМест) * 100 / (SUM(BedsPerRoomTypePerMonth) - SUM(BedsBlockedPerRoomTypePerMonth)) AS NUMBER(17, 3))
//	|	END AS BedsRentedPercentWithRoomBlocksPerRoomTypePerMonth,
//	|	CASE
//	|		WHEN SUM(RoomsPerRoomTypePerPeriod) = 0
//	|			THEN 0
//	|		ELSE CAST(SUM(ПроданоНомеров) * 100 / SUM(RoomsPerRoomTypePerPeriod) AS NUMBER(17, 3))
//	|	END AS RoomsRentedPercentPerRoomTypePerPeriod,
//	|	CASE
//	|		WHEN SUM(BedsPerRoomTypePerPeriod) = 0
//	|			THEN 0
//	|		ELSE CAST(SUM(ПроданоМест) * 100 / SUM(BedsPerRoomTypePerPeriod) AS NUMBER(17, 3))
//	|	END AS BedsRentedPercentPerRoomTypePerPeriod,
//	|	CASE
//	|		WHEN SUM(RoomsPerRoomTypePerPeriod) - SUM(RoomsBlockedPerRoomTypePerPeriod) = 0
//	|			THEN 0
//	|		ELSE CAST(SUM(ПроданоНомеров) * 100 / (SUM(RoomsPerRoomTypePerPeriod) - SUM(RoomsBlockedPerRoomTypePerPeriod)) AS NUMBER(17, 3))
//	|	END AS RoomsRentedPercentWithRoomBlocksPerRoomTypePerPeriod,
//	|	CASE
//	|		WHEN SUM(BedsPerRoomTypePerPeriod) - SUM(BedsBlockedPerRoomTypePerPeriod) = 0
//	|			THEN 0
//	|		ELSE CAST(SUM(ПроданоМест) * 100 / (SUM(BedsPerRoomTypePerPeriod) - SUM(BedsBlockedPerRoomTypePerPeriod)) AS NUMBER(17, 3))
//	|	END AS BedsRentedPercentWithRoomBlocksPerRoomTypePerPeriod,
//	|	CASE
//	|		WHEN SUM(RoomsPerRoomTypeAndCalendarDayTypePerDay) = 0
//	|			THEN 0
//	|		ELSE CAST(SUM(ПроданоНомеров) * 100 / SUM(RoomsPerRoomTypeAndCalendarDayTypePerDay) AS NUMBER(17, 3))
//	|	END AS RoomsRentedPercentPerRoomTypeAndCalendarDayTypePerDay,
//	|	CASE
//	|		WHEN SUM(BedsPerRoomTypeAndCalendarDayTypePerDay) = 0
//	|			THEN 0
//	|		ELSE CAST(SUM(ПроданоМест) * 100 / SUM(BedsPerRoomTypeAndCalendarDayTypePerDay) AS NUMBER(17, 3))
//	|	END AS BedsRentedPercentPerRoomTypeAndCalendarDayTypePerDay,
//	|	CASE
//	|		WHEN SUM(RoomsPerRoomTypeAndCalendarDayTypePerDay) - SUM(RoomsBlockedPerRoomTypeAndCalendarDayTypePerDay) = 0
//	|			THEN 0
//	|		ELSE CAST(SUM(ПроданоНомеров) * 100 / (SUM(RoomsPerRoomTypeAndCalendarDayTypePerDay) - SUM(RoomsBlockedPerRoomTypeAndCalendarDayTypePerDay)) AS NUMBER(17, 3))
//	|	END AS RoomsRentedPercentWithRoomBlocksPerRoomTypeAndCalendarDayTypePerDay,
//	|	CASE
//	|		WHEN SUM(BedsPerRoomTypeAndCalendarDayTypePerDay) - SUM(BedsBlockedPerRoomTypeAndCalendarDayTypePerDay) = 0
//	|			THEN 0
//	|		ELSE CAST(SUM(ПроданоМест) * 100 / (SUM(BedsPerRoomTypeAndCalendarDayTypePerDay) - SUM(BedsBlockedPerRoomTypeAndCalendarDayTypePerDay)) AS NUMBER(17, 3))
//	|	END AS BedsRentedPercentWithRoomBlocksPerRoomTypeAndCalendarDayTypePerDay,
//	|	CASE
//	|		WHEN SUM(RoomsPerRoomTypeAndChoosenCalendarDayTypePerDay) = 0
//	|			THEN 0
//	|		ELSE CAST(SUM(ПроданоНомеров) * 100 / SUM(RoomsPerRoomTypeAndChoosenCalendarDayTypePerDay) AS NUMBER(17, 3))
//	|	END AS RoomsRentedPercentPerRoomTypeAndChoosenCalendarDayTypePerDay,
//	|	CASE
//	|		WHEN SUM(BedsPerRoomTypeAndChoosenCalendarDayTypePerDay) = 0
//	|			THEN 0
//	|		ELSE CAST(SUM(ПроданоМест) * 100 / SUM(BedsPerRoomTypeAndChoosenCalendarDayTypePerDay) AS NUMBER(17, 3))
//	|	END AS BedsRentedPercentPerRoomTypeAndChoosenCalendarDayTypePerDay,
//	|	CASE
//	|		WHEN SUM(RoomsPerRoomTypeAndChoosenCalendarDayTypePerDay) - SUM(RoomsBlockedPerRoomTypeAndChoosenCalendarDayTypePerDay) = 0
//	|			THEN 0
//	|		ELSE CAST(SUM(ПроданоНомеров) * 100 / (SUM(RoomsPerRoomTypeAndChoosenCalendarDayTypePerDay) - SUM(RoomsBlockedPerRoomTypeAndChoosenCalendarDayTypePerDay)) AS NUMBER(17, 3))
//	|	END AS RoomsRentedPercentWithRoomBlocksPerRoomTypeAndChoosenCalendarDayTypePerDay,
//	|	CASE
//	|		WHEN SUM(BedsPerRoomTypeAndChoosenCalendarDayTypePerDay) - SUM(BedsBlockedPerRoomTypeAndChoosenCalendarDayTypePerDay) = 0
//	|			THEN 0
//	|		ELSE CAST(SUM(ПроданоМест) * 100 / (SUM(BedsPerRoomTypeAndChoosenCalendarDayTypePerDay) - SUM(BedsBlockedPerRoomTypeAndChoosenCalendarDayTypePerDay)) AS NUMBER(17, 3))
//	|	END AS BedsRentedPercentWithRoomBlocksPerRoomTypeAndChoosenCalendarDayTypePerDay,
//	|	MAX(TotalSalesAmount),
//	|	MAX(TotalRoomsRented),
//	|	MAX(TotalBedsRented),
//	|	CASE
//	|		WHEN MAX(TotalSalesAmount) = 0
//	|			THEN 0
//	|		ELSE CAST(SUM(Продажи) * 100 / MAX(TotalSalesAmount) AS NUMBER(17, 3))
//	|	END AS TotalSalesPercent,
//	|	CASE
//	|		WHEN MAX(TotalBedsRented) = 0
//	|			THEN 0
//	|		ELSE CAST(SUM(ПроданоМест) * 100 / MAX(TotalBedsRented) AS NUMBER(17, 3))
//	|	END AS TotalBedsRentedPercent,
//	|	CASE
//	|		WHEN MAX(TotalRoomsRented) = 0
//	|			THEN 0
//	|		ELSE CAST(SUM(ПроданоНомеров) * 100 / MAX(TotalRoomsRented) AS NUMBER(17, 3))
//	|	END AS TotalRoomsRentedPercent,
//	|	CASE
//	|		WHEN НомерРазмещения IS NULL 
//	|				AND ТипНомера IS NULL 
//	|			THEN CAST(MAX(RoomsPerPeriod) AS NUMBER(17, 0))
//	|		WHEN НомерРазмещения IS NULL 
//	|				AND NOT ТипНомера IS NULL 
//	|			THEN CAST(MAX(RoomsPerRoomTypePerPeriod) AS NUMBER(17, 0))
//	|		ELSE MAX(RoomsPerRoomPerPeriod)
//	|	END AS RoomsPerRoomPerPeriod,
//	|	CASE
//	|		WHEN НомерРазмещения IS NULL 
//	|				AND ТипНомера IS NULL 
//	|			THEN CAST(MAX(BedsPerPeriod) AS NUMBER(17, 0))
//	|		WHEN НомерРазмещения IS NULL 
//	|				AND NOT ТипНомера IS NULL 
//	|			THEN CAST(MAX(BedsPerRoomTypePerPeriod) AS NUMBER(17, 0))
//	|		ELSE MAX(BedsPerRoomPerPeriod)
//	|	END AS BedsPerRoomPerPeriod,
//	|	CASE
//	|		WHEN НомерРазмещения IS NULL 
//	|				AND ТипНомера IS NULL 
//	|			THEN CAST(MAX(RoomsBlockedPerPeriod) AS NUMBER(17, 0))
//	|		WHEN НомерРазмещения IS NULL 
//	|				AND NOT ТипНомера IS NULL 
//	|			THEN CAST(MAX(RoomsBlockedPerRoomTypePerPeriod) AS NUMBER(17, 0))
//	|		ELSE MAX(RoomsBlockedPerRoomPerPeriod)
//	|	END AS RoomsBlockedPerRoomPerPeriod,
//	|	CASE
//	|		WHEN НомерРазмещения IS NULL 
//	|				AND ТипНомера IS NULL 
//	|			THEN CAST(MAX(BedsBlockedPerPeriod) AS NUMBER(17, 0))
//	|		WHEN НомерРазмещения IS NULL 
//	|				AND NOT ТипНомера IS NULL 
//	|			THEN CAST(MAX(BedsBlockedPerRoomTypePerPeriod) AS NUMBER(17, 0))
//	|		ELSE MAX(BedsBlockedPerRoomPerPeriod)
//	|	END AS BedsBlockedPerRoomPerPeriod,
//	|	CASE
//	|		WHEN НомерРазмещения IS NULL 
//	|				AND ТипНомера IS NULL 
//	|				AND (CAST(MAX(RoomsPerPeriod) AS NUMBER(17, 0))) - (CAST(MAX(RoomsBlockedPerPeriod) AS NUMBER(17, 0))) = 0
//	|			THEN 0
//	|		WHEN НомерРазмещения IS NULL 
//	|				AND ТипНомера IS NULL 
//	|				AND (CAST(MAX(RoomsPerPeriod) AS NUMBER(17, 0))) - (CAST(MAX(RoomsBlockedPerPeriod) AS NUMBER(17, 0))) <> 0
//	|			THEN CAST(SUM(ПроданоНомеров) * 100 / (MAX(RoomsPerPeriod) - MAX(RoomsBlockedPerPeriod)) AS NUMBER(17, 3))
//	|		WHEN НомерРазмещения IS NULL 
//	|				AND NOT ТипНомера IS NULL 
//	|				AND (CAST(MAX(RoomsPerRoomTypePerPeriod) AS NUMBER(17, 0))) - (CAST(MAX(RoomsBlockedPerRoomTypePerPeriod) AS NUMBER(17, 0))) = 0
//	|			THEN 0
//	|		WHEN НомерРазмещения IS NULL 
//	|				AND NOT ТипНомера IS NULL 
//	|				AND (CAST(MAX(RoomsPerRoomTypePerPeriod) AS NUMBER(17, 0))) - (CAST(MAX(RoomsBlockedPerRoomTypePerPeriod) AS NUMBER(17, 0))) <> 0
//	|			THEN CAST(SUM(ПроданоНомеров) * 100 / (MAX(RoomsPerRoomTypePerPeriod) - MAX(RoomsBlockedPerRoomTypePerPeriod)) AS NUMBER(17, 3))
//	|		WHEN NOT НомерРазмещения IS NULL 
//	|				AND MAX(RoomsPerRoomPerPeriod) - MAX(RoomsBlockedPerRoomPerPeriod) = 0
//	|			THEN 0
//	|		ELSE CAST(SUM(ПроданоНомеров) * 100 / (MAX(RoomsPerRoomPerPeriod) - MAX(RoomsBlockedPerRoomPerPeriod)) AS NUMBER(17, 3))
//	|	END AS RoomsRentedPercentPerRoom,
//	|	CASE
//	|		WHEN НомерРазмещения IS NULL 
//	|				AND ТипНомера IS NULL 
//	|				AND MAX(BedsPerPeriod) - MAX(BedsBlockedPerPeriod) = 0
//	|			THEN 0
//	|		WHEN НомерРазмещения IS NULL 
//	|				AND ТипНомера IS NULL 
//	|				AND MAX(BedsPerPeriod) - MAX(BedsBlockedPerPeriod) <> 0
//	|			THEN CAST(SUM(ПроданоМест) * 100 / (MAX(BedsPerPeriod) - MAX(BedsBlockedPerPeriod)) AS NUMBER(17, 3))
//	|		WHEN НомерРазмещения IS NULL 
//	|				AND NOT ТипНомера IS NULL 
//	|				AND MAX(BedsPerRoomTypePerPeriod) - MAX(BedsBlockedPerRoomTypePerPeriod) = 0
//	|			THEN 0
//	|		WHEN НомерРазмещения IS NULL 
//	|				AND NOT ТипНомера IS NULL 
//	|				AND MAX(BedsPerRoomTypePerPeriod) - MAX(BedsBlockedPerRoomTypePerPeriod) <> 0
//	|			THEN CAST(SUM(ПроданоМест) * 100 / (MAX(BedsPerRoomTypePerPeriod) - MAX(BedsBlockedPerRoomTypePerPeriod)) AS NUMBER(17, 0))
//	|		WHEN NOT НомерРазмещения IS NULL 
//	|				AND MAX(BedsPerRoomPerPeriod) - MAX(BedsBlockedPerRoomPerPeriod) = 0
//	|			THEN 0
//	|		ELSE CAST(SUM(ПроданоМест) * 100 / (MAX(BedsPerRoomPerPeriod) - MAX(BedsBlockedPerRoomPerPeriod)) AS NUMBER(17, 3))
//	|	END AS BedsRentedPercentPerRoom
//	|BY
//	|	OVERALL,
//	|	Валюта,
//	|	ТипНомера HIERARCHY,
//	|	НомерРазмещения HIERARCHY
//	|{TOTALS BY
//	|	Фирма.*,
//	|	Гостиница.*,
//	|	Валюта.*,
//	|	НомерРазмещения.*,
//	|	ТипНомера.*,
//	|	Тариф.*,
//	|	ТипДеньКалендарь.*,
//	|	ПризнакЦены.*,
//	|	ОборотыПродажиНомеров.ExtCalendarDayType.*,
//	|	ВидРазмещения.*,
//	|	ТипКлиента.*,
//	|	МаретингНапрвл.*,
//	|	ИсточИнфоГостиница.*,
//	|	ДокОснование.*,
//	|	ОборотыПродажиНомеров.Reservation.* AS Reservation,
//	|	ОборотыПродажиНомеров.ReservationDate AS ReservationDate,
//	|	ОборотыПродажиНомеров.ReservationWeek AS ReservationWeek,
//	|	ОборотыПродажиНомеров.ReservationMonth AS ReservationMonth,
//	|	ОборотыПродажиНомеров.ReservationYear AS ReservationYear,
//	|	ОборотыПродажиНомеров.DaysBeforeCheckIn AS DaysBeforeCheckIn,
//	|	ОборотыПродажиНомеров.WeeksBeforeCheckIn AS WeeksBeforeCheckIn,
//	|	ОборотыПродажиНомеров.MonthsBeforeCheckIn AS MonthsBeforeCheckIn,
//	|	ОборотыПродажиНомеров.КвотаНомеров.* AS КвотаНомеров,
//	|	Услуга.*,
//	|	RoomPrice,
//	|	ОборотыПродажиНомеров.ГруппаГостей.* AS ГруппаГостей,
//	|	ОборотыПродажиНомеров.Контрагент.* AS Контрагент,
//	|	ОборотыПродажиНомеров.Договор.* AS Договор,
//	|	ОборотыПродажиНомеров.Агент.* AS Агент,
//	|	ОборотыПродажиНомеров.Клиент.* AS Клиент,
//	|	ОборотыПродажиНомеров.Ресурс.* AS Ресурс,
//	|	ОборотыПродажиНомеров.СчетПроживания.* AS СчетПроживания,
//	|	ОборотыПродажиНомеров.Цена AS Цена,
//	|	ОборотыПродажиНомеров.ТипРесурса.* AS ТипРесурса,
//	|	ОборотыПродажиНомеров.TripPurpose.* AS TripPurpose,
//	|	ОборотыПродажиНомеров.ПутевкаКурсовка.* AS ПутевкаКурсовка,
//	|	ОборотыПродажиНомеров.Автор.* AS Автор,
//	|	ОборотыПродажиНомеров.Скидка AS Скидка,
//	|	ОборотыПродажиНомеров.ТипСкидки.* AS ТипСкидки,
//	|	ОборотыПродажиНомеров.ДисконтКарт.* AS ДисконтКарт,
//	|	ОборотыПродажиНомеров.КомиссияАгента AS КомиссияАгента,
//	|	ОборотыПродажиНомеров.ВидКомиссииАгента.* AS ВидКомиссииАгента,
//	|	ОборотыПродажиНомеров.СпособОплаты.* AS СпособОплаты,
//	|	ОборотыПродажиНомеров.СтавкаНДС.* AS СтавкаНДС,
//	|	УчетнаяДата,
//	|	(DAY(ОборотыПродажиНомеров.УчетнаяДата)) AS AccountingDay,
//	|	(WEEKDAY(ОборотыПродажиНомеров.УчетнаяДата)) AS AccountingWeekday,
//	|	(CASE
//	|			WHEN WEEKDAY(ОборотыПродажиНомеров.УчетнаяДата) = 1
//	|				THEN &qMonday
//	|			WHEN WEEKDAY(ОборотыПродажиНомеров.УчетнаяДата) = 2
//	|				THEN &qTuesday
//	|			WHEN WEEKDAY(ОборотыПродажиНомеров.УчетнаяДата) = 3
//	|				THEN &qWednesday
//	|			WHEN WEEKDAY(ОборотыПродажиНомеров.УчетнаяДата) = 4
//	|				THEN &qThursday
//	|			WHEN WEEKDAY(ОборотыПродажиНомеров.УчетнаяДата) = 5
//	|				THEN &qFriday
//	|			WHEN WEEKDAY(ОборотыПродажиНомеров.УчетнаяДата) = 6
//	|				THEN &qSaturday
//	|			WHEN WEEKDAY(ОборотыПродажиНомеров.УчетнаяДата) = 7
//	|				THEN &qSunday
//	|			ELSE NULL
//	|		END) AS AccountingWeekdayName,
//	|	(WEEK(ОборотыПродажиНомеров.УчетнаяДата)) AS AccountingWeek,
//	|	(MONTH(ОборотыПродажиНомеров.УчетнаяДата)) AS AccountingMonth,
//	|	(QUARTER(ОборотыПродажиНомеров.УчетнаяДата)) AS AccountingQuarter,
//	|	(YEAR(ОборотыПродажиНомеров.УчетнаяДата)) AS AccountingYear}";
//	ReportBuilder.Text = QueryText;
//	ReportBuilder.FillSettings();
//	
//	// Initialize report builder with default query
//	vRB = New ReportBuilder(QueryText);
//	vRBSettings = vRB.GetSettings(True, True, True, True, True);
//	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
//	
//	// Set default report builder header text
//	ReportBuilder.HeaderText = NStr("EN='ГруппаНомеров sales turnovers';RU='Обороты по продажам номеров';de='Umsätze aus Zimmerverkäufen'");
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
//	   Or pName = "SalesWithoutCommission" 
//	   Or pName = "ДоходНомеров" 
//	   Or pName = "RoomRevenueWithoutCommission" 
//	   Or pName = "InPriceRevenue" 
//	   Or pName = "InPriceRevenueWithoutCommission" 
//	   Or pName = "ДоходДопМеста" 
//	   Or pName = "RoomRevenueWithoutExtraBed" 
//	   Or pName = "ПродажиБезНДС" 
//	   Or pName = "SalesWithoutVATWithoutCommission" 
//	   Or pName = "ДоходПродажиБезНДС" 
//	   Or pName = "RoomRevenueWithoutVATWithoutCommission" 
//	   Or pName = "InPriceRevenueWithoutVAT" 
//	   Or pName = "InPriceRevenueWithoutVATWithoutCommission" 
//	   Or pName = "ДоходДопМестаБезНДС" 
//	   Or pName = "RoomRevenueWithoutExtraBedWithoutVAT" 
//	   Or pName = "СуммаКомиссии" 
//	   Or pName = "КомиссияБезНДС" 
//	   Or pName = "СуммаСкидки" 
//	   Or pName = "СуммаСкидкиБезНДС" 
//	   Or pName = "ExtraBedDiscountSum" 
//	   Or pName = "DiscountSumWithoutExtraBed" 
//	   Or pName = "ПроданоНомеров" 
//	   Or pName = "ПроданоМест" 
//	   Or pName = "ПроданоДопМест" 
//	   Or pName = "ЧеловекаДни" 
//	   Or pName = "ExtraBedGuestDays" 
//	   Or pName = "GuestDaysWithoutExtraBed" 
//	   Or pName = "ЗаездГостей"
//	   Or pName = "ЗаездНомеров" 
//	   Or pName = "ЗаездМест" 
//	   Or pName = "ЗаездДополнительныхМест" 
//	   Or pName = "Количество" 
//	   Or pName = "RoomsPerPeriod"
//	   Or pName = "BedsPerPeriod"
//	   Or pName = "RoomsBlockedPerPeriod"
//	   Or pName = "BedsBlockedPerPeriod"
//	   Or pName = "RoomsPerRoomTypePerDay"
//	   Or pName = "BedsPerRoomTypePerDay"
//	   Or pName = "RoomsBlockedPerRoomTypePerDay"
//	   Or pName = "BedsBlockedPerRoomTypePerDay"
//	   Or pName = "RoomsPerRoomTypePerMonth"
//	   Or pName = "BedsPerRoomTypePerMonth"
//	   Or pName = "RoomsBlockedPerRoomTypePerMonth"
//	   Or pName = "BedsBlockedPerRoomTypePerMonth"
//	   Or pName = "RoomsPerRoomTypePerPeriod"
//	   Or pName = "BedsPerRoomTypePerPeriod"
//	   Or pName = "RoomsBlockedPerRoomTypePerPeriod"
//	   Or pName = "BedsBlockedPerRoomTypePerPeriod"
//	   Or pName = "AverageRoomPrice"
//	   Or pName = "AverageBedPrice"
//	   Or pName = "AverageRoomPriceWithoutVAT"
//	   Or pName = "AverageBedPriceWithoutVAT"
//	   Or pName = "RevPAR"
//	   Or pName = "RevPAB"
//	   Or pName = "RevPARWithoutVAT"
//	   Or pName = "RevPABWithoutVAT"
//	   Or pName = "RevPARPerRoomTypePerDay"
//	   Or pName = "RevPABPerRoomTypePerDay"
//	   Or pName = "RevPARWithoutVATPerRoomTypePerDay"
//	   Or pName = "RevPABWithoutVATPerRoomTypePerDay"
//	   Or pName = "RevPARPerRoomTypePerMonth"
//	   Or pName = "RevPABPerRoomTypePerMonth"
//	   Or pName = "RevPARWithoutVATPerRoomTypePerMonth"
//	   Or pName = "RevPABWithoutVATPerRoomTypePerMonth"
//	   Or pName = "RevPARPerRoomTypePerPeriod"
//	   Or pName = "RevPABPerRoomTypePerPeriod"
//	   Or pName = "RevPARWithoutVATPerRoomTypePerPeriod"
//	   Or pName = "RevPABWithoutVATPerRoomTypePerPeriod"
//	   Or pName = "RoomsRentedPercent"
//	   Or pName = "BedsRentedPercent"
//	   Or pName = "RoomsRentedPercentWithRoomBlocks"
//	   Or pName = "BedsRentedPercentWithRoomBlocks"
//	   Or pName = "RoomsRentedPercentPerRoomTypePerDay"
//	   Or pName = "BedsRentedPercentPerRoomTypePerDay"
//	   Or pName = "RoomsRentedPercentWithRoomBlocksPerRoomTypePerDay"
//	   Or pName = "BedsRentedPercentWithRoomBlocksPerRoomTypePerDay"
//	   Or pName = "RoomsRentedPercentPerRoomTypePerMonth"
//	   Or pName = "BedsRentedPercentPerRoomTypePerMonth"
//	   Or pName = "RoomsRentedPercentWithRoomBlocksPerRoomTypePerMonth"
//	   Or pName = "BedsRentedPercentWithRoomBlocksPerRoomTypePerMonth"
//	   Or pName = "RoomsRentedPercentPerRoomTypePerPeriod"
//	   Or pName = "BedsRentedPercentPerRoomTypePerPeriod"
//	   Or pName = "RoomsRentedPercentWithRoomBlocksPerRoomTypePerPeriod"
//	   Or pName = "BedsRentedPercentWithRoomBlocksPerRoomTypePerPeriod"
//	   Or pName = "TotalSalesAmount"
//	   Or pName = "TotalBedsRented"
//	   Or pName = "TotalRoomsRented"
//	   Or pName = "TotalBedsRentedPercent"
//	   Or pName = "TotalRoomsRentedPercent"
//	   Or pName = "TotalSalesPercent" 
//	   Or pName = "RoomsPerRoomPerPeriod" 
//	   Or pName = "BedsPerRoomPerPeriod" 
//	   Or pName = "RoomsBlockedPerRoomPerPeriod" 
//	   Or pName = "BedsBlockedPerRoomPerPeriod" 
//	   Or pName = "RoomsRentedPercentPerRoom" 
//	   Or pName = "BedsRentedPercentPerRoom" Тогда
//		Return True;
//	Else
//		Return False;
//	EndIf;
//EndFunction //pmIsResource
//
////-----------------------------------------------------------------------------
//// Reports framework end
////-----------------------------------------------------------------------------
