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
//	// Run query to get available rooms
//	vQry = New Query();
//	vQry.Text = 
//	"SELECT
//	|	TotalRoomInventoryBalanceAndTurnovers.Period AS Period,
//	|	SUM(TotalRoomInventoryBalanceAndTurnovers.CounterClosingBalance) AS CounterClosingBalance,
//	|	SUM(TotalRoomInventoryBalanceAndTurnovers.TotalRoomsClosingBalance) AS ВсегоНомеров,
//	|	SUM(TotalRoomInventoryBalanceAndTurnovers.TotalBedsClosingBalance) AS ВсегоМест,
//	|	-SUM(TotalRoomInventoryBalanceAndTurnovers.RoomsBlockedClosingBalance) AS TotalRoomsBlocked,
//	|	-SUM(TotalRoomInventoryBalanceAndTurnovers.BedsBlockedClosingBalance) AS TotalBedsBlocked,
//	|	SUM(TotalRoomInventoryBalanceAndTurnovers.GuestsReservedReceipt) AS TotalGuestsReservedReceipt,
//	|	SUM(TotalRoomInventoryBalanceAndTurnovers.GuestsReservedExpense) AS TotalGuestsReservedExpense,
//	|	SUM(TotalRoomInventoryBalanceAndTurnovers.InHouseGuestsReceipt) AS TotalInHouseGuestsReceipt,
//	|	SUM(TotalRoomInventoryBalanceAndTurnovers.InHouseGuestsExpense) AS TotalInHouseGuestsExpense
//	|FROM
//	|	AccumulationRegister.ЗагрузкаНомеров.BalanceAndTurnovers(
//	|			&qPeriodFrom,
//	|			&qPeriodTo,
//	|			Day,
//	|			RegisterRecordsAndPeriodBoundaries,
//	|			Гостиница IN HIERARCHY (&qHotel)
//	|				AND (НомерРазмещения IN HIERARCHY (&qRoom)
//	|					OR &qIsEmptyRoom)
//	|				AND (ТипНомера IN HIERARCHY (&qRoomType)
//	|					OR &qIsEmptyRoomType)) AS TotalRoomInventoryBalanceAndTurnovers
//	|
//	|GROUP BY
//	|	TotalRoomInventoryBalanceAndTurnovers.Period
//	|
//	|ORDER BY
//	|	Period";
//	vQry.SetParameter("qHotel", Гостиница);
//	vQry.SetParameter("qPeriodFrom", PeriodFrom);
//	vQry.SetParameter("qPeriodTo", PeriodTo);
//	vQry.SetParameter("qRoom", ГруппаНомеров);
//	vQry.SetParameter("qIsEmptyRoom", НЕ ЗначениеЗаполнено(ГруппаНомеров));
//	vQry.SetParameter("qRoomType", RoomType);
//	vQry.SetParameter("qIsEmptyRoomType", НЕ ЗначениеЗаполнено(RoomType));
//	vTotals = vQry.Execute().Unload();
//	
//	AddMissingPeriods(vTotals);
//	
//	vTotalRooms = vTotals.Total("ВсегоНомеров");
//	vTotalBeds = vTotals.Total("ВсегоМест");
//	vTotalRoomsBlocked = vTotals.Total("TotalRoomsBlocked");
//	vTotalBedsBlocked = vTotals.Total("TotalBedsBlocked");
//	vTotalRoomsAvailable = vTotalRooms - vTotalRoomsBlocked;
//	vTotalBedsAvailable = vTotalBeds - vTotalBedsBlocked;
//	
//	// Run query to get total ГруппаНомеров blocks that should be added to the number of total rooms rented
//	vQry = New Query();
//	vQry.Text = 
//	"SELECT
//	|	RoomBlocksBalanceAndTurnovers.Period AS Period,
//	|	SUM(RoomBlocksBalanceAndTurnovers.RoomsBlockedClosingBalance) AS SpecRoomsBlocked,
//	|	SUM(RoomBlocksBalanceAndTurnovers.BedsBlockedClosingBalance) AS SpecBedsBlocked
//	|FROM
//	|	AccumulationRegister.БлокирНомеров.BalanceAndTurnovers(
//	|			&qPeriodFrom,
//	|			&qPeriodTo,
//	|			Day,
//	|			RegisterRecordsAndPeriodBoundaries,
//	|			Гостиница IN HIERARCHY (&qHotel)
//	|				AND (НомерРазмещения IN HIERARCHY (&qRoom)
//	|					OR &qIsEmptyRoom)
//	|				AND (ТипНомера IN HIERARCHY (&qRoomType)
//	|					OR &qIsEmptyRoomType)
//	|				AND RoomBlockType.AddToRoomsRentedInSummaryIndexes) AS RoomBlocksBalanceAndTurnovers
//	|
//	|GROUP BY
//	|	RoomBlocksBalanceAndTurnovers.Period
//	|
//	|ORDER BY
//	|	Period";
//	vQry.SetParameter("qHotel", Гостиница);
//	vQry.SetParameter("qPeriodFrom", PeriodFrom);
//	vQry.SetParameter("qPeriodTo", PeriodTo);
//	vQry.SetParameter("qRoom", ГруппаНомеров);
//	vQry.SetParameter("qIsEmptyRoom", НЕ ЗначениеЗаполнено(ГруппаНомеров));
//	vQry.SetParameter("qRoomType", RoomType);
//	vQry.SetParameter("qIsEmptyRoomType", НЕ ЗначениеЗаполнено(RoomType));
//	vTotalSpecBlocks = vQry.Execute().Unload();
//	
//	AddMissingPeriods(vTotalSpecBlocks);
//	
//	vTotalSpecRoomsBlocked = vTotalSpecBlocks.Total("SpecRoomsBlocked");
//	vTotalSpecBedsBlocked = vTotalSpecBlocks.Total("SpecBedsBlocked");
//	
//	vTotalRoomsAvailable = vTotalRoomsAvailable + vTotalSpecRoomsBlocked;
//	vTotalBedsAvailable = vTotalBedsAvailable + vTotalSpecBedsBlocked;
//	
//	// Run main query to get data
//	vQry = New Query();
//	vQry.Text = TrimAll(QueryText);
//	If ShowHierarchy Тогда
//		vQry.Text = vQry.Text + ", ТипНомера ONLY HIERARCHY";
//	EndIf;
//	vQry.SetParameter("qHotel", Гостиница);
//	vQry.SetParameter("qPeriodFrom", PeriodFrom);
//	vQry.SetParameter("qPeriodTo", PeriodTo);
//	vQry.SetParameter("qForecastPeriodFrom", Max(BegOfDay(PeriodFrom), BegOfDay(CurrentDate())));
//	vQry.SetParameter("qForecastPeriodTo", ?(ЗначениеЗаполнено(PeriodTo), Max(PeriodTo, EndOfDay(CurrentDate()-24*3600)), '00010101'));
//	vQry.SetParameter("qRoom", ГруппаНомеров);
//	vQry.SetParameter("qIsEmptyRoom", НЕ ЗначениеЗаполнено(ГруппаНомеров));
//	vQry.SetParameter("qRoomType", RoomType);
//	vQry.SetParameter("qIsEmptyRoomType", НЕ ЗначениеЗаполнено(RoomType));
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
//	// For each row in resulting table run query to get rooms available for the ГруппаНомеров type
//	i = 0;
//	For Each vRow In vResults Do
//		// Initialize totals
//		vRooms = 0;
//		vBeds = 0;
//		vRoomsBlocked = 0;
//		vBedsBlocked = 0;
//		vRoomsAvailable = 0;
//		vBedsAvailable = 0;
//		vSpecRoomsBlocked = 0;
//		vSpecBedsBlocked = 0;
//		
//		If i > 0 Or ЗначениеЗаполнено(vRow.RoomType) Тогда
//			vQry = New Query();
//			vQry.Text = 
//			"SELECT
//			|	RoomInventoryBalanceAndTurnovers.Period AS Period,
//			|	SUM(RoomInventoryBalanceAndTurnovers.CounterClosingBalance) AS CounterClosingBalance,
//			|	SUM(RoomInventoryBalanceAndTurnovers.TotalRoomsClosingBalance) AS RoomsPerRoomType,
//			|	SUM(RoomInventoryBalanceAndTurnovers.TotalBedsClosingBalance) AS BedsPerRoomType,
//			|	-SUM(RoomInventoryBalanceAndTurnovers.RoomsBlockedClosingBalance) AS RoomsBlockedPerRoomType,
//			|	-SUM(RoomInventoryBalanceAndTurnovers.BedsBlockedClosingBalance) AS BedsBlockedPerRoomType,
//			|	SUM(RoomInventoryBalanceAndTurnovers.GuestsReservedReceipt) AS GuestsReservedReceipt,
//			|	SUM(RoomInventoryBalanceAndTurnovers.GuestsReservedExpense) AS GuestsReservedExpense,
//			|	SUM(RoomInventoryBalanceAndTurnovers.InHouseGuestsReceipt) AS InHouseGuestsReceipt,
//			|	SUM(RoomInventoryBalanceAndTurnovers.InHouseGuestsExpense) AS InHouseGuestsExpense
//			|FROM
//			|	AccumulationRegister.ЗагрузкаНомеров.BalanceAndTurnovers(
//			|			&qPeriodFrom,
//			|			&qPeriodTo,
//			|			Day,
//			|			RegisterRecordsAndPeriodBoundaries,
//			|			Гостиница IN HIERARCHY (&qHotel)
//			|				AND (НомерРазмещения IN HIERARCHY (&qRoom)
//			|					OR &qIsEmptyRoom)
//			|				AND (ТипНомера IN HIERARCHY (&qRoomType)
//			|					OR &qIsEmptyRoomType)) AS RoomInventoryBalanceAndTurnovers
//			|
//			|GROUP BY
//			|	RoomInventoryBalanceAndTurnovers.Period
//			|
//			|ORDER BY
//			|	Period";
//			vQry.SetParameter("qHotel", Гостиница);
//			vQry.SetParameter("qPeriodFrom", PeriodFrom);
//			vQry.SetParameter("qPeriodTo", PeriodTo);
//			vQry.SetParameter("qRoom", ГруппаНомеров);
//			vQry.SetParameter("qIsEmptyRoom", НЕ ЗначениеЗаполнено(ГруппаНомеров));
//			vQry.SetParameter("qRoomType", vRow.RoomType);
//			vQry.SetParameter("qIsEmptyRoomType", НЕ ЗначениеЗаполнено(vRow.RoomType));
//			vPerRoomTypeTotals = vQry.Execute().Unload();
//			
//			AddMissingPeriods(vPerRoomTypeTotals);
//			
//			vRooms = vPerRoomTypeTotals.Total("RoomsPerRoomType");
//			vBeds = vPerRoomTypeTotals.Total("BedsPerRoomType");
//			vRoomsBlocked = vPerRoomTypeTotals.Total("RoomsBlockedPerRoomType");
//			vBedsBlocked = vPerRoomTypeTotals.Total("BedsBlockedPerRoomType");
//			vRoomsAvailable = vRooms - vRoomsBlocked;
//			vBedsAvailable = vBeds - vBedsBlocked;
//			
//			// Run query to get ГруппаНомеров blocks that should be added to the number of rooms rented
//			vQry = New Query();
//			vQry.Text = 
//			"SELECT
//			|	RoomBlocksBalanceAndTurnovers.Period AS Period,
//			|	SUM(RoomBlocksBalanceAndTurnovers.RoomsBlockedClosingBalance) AS SpecRoomsBlocked,
//			|	SUM(RoomBlocksBalanceAndTurnovers.BedsBlockedClosingBalance) AS SpecBedsBlocked
//			|FROM
//			|	AccumulationRegister.БлокирНомеров.BalanceAndTurnovers(
//			|			&qPeriodFrom,
//			|			&qPeriodTo,
//			|			Day,
//			|			RegisterRecordsAndPeriodBoundaries,
//			|			Гостиница IN HIERARCHY (&qHotel)
//			|				AND (НомерРазмещения IN HIERARCHY (&qRoom)
//			|					OR &qIsEmptyRoom)
//			|				AND (ТипНомера IN HIERARCHY (&qRoomType)
//			|					OR &qIsEmptyRoomType)
//			|				AND RoomBlockType.AddToRoomsRentedInSummaryIndexes) AS RoomBlocksBalanceAndTurnovers
//			|
//			|GROUP BY
//			|	RoomBlocksBalanceAndTurnovers.Period
//			|
//			|ORDER BY
//			|	Period";
//			vQry.SetParameter("qHotel", Гостиница);
//			vQry.SetParameter("qPeriodFrom", PeriodFrom);
//			vQry.SetParameter("qPeriodTo", PeriodTo);
//			vQry.SetParameter("qRoom", ГруппаНомеров);
//			vQry.SetParameter("qIsEmptyRoom", НЕ ЗначениеЗаполнено(ГруппаНомеров));
//			vQry.SetParameter("qRoomType", vRow.RoomType);
//			vQry.SetParameter("qIsEmptyRoomType", НЕ ЗначениеЗаполнено(vRow.RoomType));
//			vPerRoomTypeSpecBlocks = vQry.Execute().Unload();
//			
//			AddMissingPeriods(vPerRoomTypeSpecBlocks);
//			
//			vSpecRoomsBlocked = vPerRoomTypeSpecBlocks.Total("SpecRoomsBlocked");
//			vSpecBedsBlocked = vPerRoomTypeSpecBlocks.Total("SpecBedsBlocked");
//			
//			vRoomsAvailable = vRoomsAvailable + vSpecRoomsBlocked;
//			vBedsAvailable = vBedsAvailable + vSpecBedsBlocked;
//			
//			// Fill ГруппаНомеров parent resources
//			vRow.TotalRooms = vTotalRooms;
//			vRow.TotalBeds = vTotalBeds;
//			vRow.TotalRoomsBlocked = vTotalRoomsBlocked;
//			vRow.TotalBedsBlocked = vTotalBedsBlocked;
//			vRow.TotalRoomsAvailable = vTotalRooms - vTotalRoomsBlocked;
//			vRow.TotalBedsAvailable = vTotalBeds - vTotalBedsBlocked;
//	
//			vRow.TotalRoomsRentedPercent = ?(vTotalRooms = 0, 0, 100 * (vRow.RoomsRented + vSpecRoomsBlocked)/vTotalRooms);
//			vRow.TotalBedsRentedPercent = ?(vTotalBeds = 0, 0, 100 * (vRow.BedsRented + vSpecBedsBlocked)/vTotalBeds);
//			vRow.TotalRoomsRentedWithBlocksPercent = ?(vTotalRoomsAvailable = 0, 0, 100 * (vRow.RoomsRented + vSpecRoomsBlocked)/vTotalRoomsAvailable);
//			vRow.TotalBedsRentedWithBlocksPercent = ?(vTotalBedsAvailable = 0, 0, 100 * (vRow.BedsRented + vSpecBedsBlocked)/vTotalBedsAvailable);
//			
//			vRow.RoomsPerRoomType = vRooms;
//			vRow.BedsPerRoomType = vBeds;
//			vRow.RoomsBlockedPerRoomType = vRoomsBlocked;
//			vRow.BedsBlockedPerRoomType = vBedsBlocked;
//			vRow.RoomsAvailablePerRoomType = vRooms - vRoomsBlocked;
//			vRow.BedsAvailablePerRoomType = vBeds - vBedsBlocked;
//			
//			vRow.RoomsRentedPercent = ?(vRooms = 0, 0, 100 * (vRow.RoomsRented + vSpecRoomsBlocked)/vRooms);
//			vRow.BedsRentedPercent = ?(vBeds = 0, 0, 100 * (vRow.BedsRented + vSpecBedsBlocked)/vBeds);
//			vRow.RoomsRentedWithBlocksPercent = ?(vRoomsAvailable = 0, 0, 100 * (vRow.RoomsRented + vSpecRoomsBlocked)/vRoomsAvailable);
//			vRow.BedsRentedWithBlocksPercent = ?(vBedsAvailable = 0, 0, 100 * (vRow.BedsRented + vSpecBedsBlocked)/vBedsAvailable);
//			
//			vRow.RoomsRented = vRow.RoomsRented + vSpecRoomsBlocked;
//			vRow.BedsRented = vRow.BedsRented + vSpecBedsBlocked;
//			vRow.RoomsBlockedPerRoomType = vRow.RoomsBlockedPerRoomType - vSpecRoomsBlocked;
//			vRow.BedsBlockedPerRoomType = vRow.BedsBlockedPerRoomType - vSpecBedsBlocked;
//			vRow.TotalRoomsBlocked = vRow.TotalRoomsBlocked - vTotalSpecRoomsBlocked;
//			vRow.TotalBedsBlocked = vRow.TotalBedsBlocked - vTotalSpecBedsBlocked;
//
//			vRow.ADR = ?(vRow.RoomsRented = 0, 0, Round(vRow.RoomRevenue/vRow.RoomsRented, 2));
//			vRow.ADRWithoutVAT = ?(vRow.RoomsRented = 0, 0, Round(vRow.RoomRevenueWithoutVAT/vRow.RoomsRented, 2));
//			vRow.ADBR = ?(vRow.BedsRented = 0, 0, Round(vRow.RoomRevenue/vRow.BedsRented, 2));
//			vRow.ADBRWithoutVAT = ?(vRow.BedsRented = 0, 0, Round(vRow.RoomRevenueWithoutVAT/vRow.BedsRented, 2));
//			vRow.RevPAR = ?(vRoomsAvailable = 0, 0, Round(vRow.RoomRevenue/vRoomsAvailable, 2));
//			vRow.RevPARWithoutVAT = ?(vRoomsAvailable = 0, 0, Round(vRow.RoomRevenueWithoutVAT/vRoomsAvailable, 2));
//			vRow.RevPAB = ?(vBedsAvailable = 0, 0, Round(vRow.RoomRevenue/vBedsAvailable, 2));
//			vRow.RevPABWithoutVAT = ?(vBedsAvailable = 0, 0, Round(vRow.RoomRevenueWithoutVAT/vBedsAvailable, 2));
//			vRow.RevPAC = ?(vRow.GuestDays = 0, 0, Round(vRow.RoomRevenue/vRow.GuestDays, 2));
//			vRow.RevPACWithoutVAT = ?(vRow.GuestDays = 0, 0, Round(vRow.RoomRevenueWithoutVAT/vRow.GuestDays, 2));
//			vRow.ALS = ?(vRow.GuestsCheckedIn = 0, 0, Round(vRow.GuestDays/vRow.GuestsCheckedIn, 3));
//		EndIf;
//		
//		i = i + 1;
//	EndDo;
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
//	|	RoomSales.Валюта AS Валюта,
//	|	RoomSales.Гостиница AS Гостиница,
//	|	RoomSales.ТипНомера AS ТипНомера,
//	|	SUM(RoomSales.SalesTurnover) AS Продажи,
//	|	SUM(RoomSales.RoomRevenueTurnover) AS ДоходНомеров,
//	|	SUM(RoomSales.SalesWithoutVATTurnover) AS ПродажиБезНДС,
//	|	SUM(RoomSales.RoomRevenueWithoutVATTurnover) AS ДоходПродажиБезНДС,
//	|	SUM(RoomSales.CommissionSumTurnover) AS СуммаКомиссии,
//	|	SUM(RoomSales.CommissionSumWithoutVATTurnover) AS КомиссияБезНДС,
//	|	SUM(RoomSales.DiscountSumTurnover) AS СуммаСкидки,
//	|	SUM(RoomSales.DiscountSumWithoutVATTurnover) AS СуммаСкидкиБезНДС,
//	|	SUM(RoomSales.RoomsRentedTurnover) AS ПроданоНомеров,
//	|	SUM(RoomSales.BedsRentedTurnover) AS ПроданоМест,
//	|	SUM(RoomSales.AdditionalBedsRentedTurnover) AS ПроданоДопМест,
//	|	SUM(RoomSales.GuestDaysTurnover) AS ЧеловекаДни,
//	|	SUM(RoomSales.GuestsCheckedInTurnover) AS ЗаездГостей,
//	|	SUM(RoomSales.RoomsCheckedInTurnover) AS ЗаездНомеров,
//	|	SUM(RoomSales.BedsCheckedInTurnover) AS ЗаездМест,
//	|	SUM(RoomSales.AdditionalBedsCheckedInTurnover) AS ЗаездДополнительныхМест,
//	|	SUM(RoomSales.QuantityTurnover) AS Количество,
//	|	0 AS ADR,
//	|	0 AS ADRWithoutVAT,
//	|	0 AS ADBR,
//	|	0 AS ADBRWithoutVAT,
//	|	0 AS RevPAR,
//	|	0 AS RevPARWithoutVAT,
//	|	0 AS RevPAB,
//	|	0 AS RevPABWithoutVAT,
//	|	0 AS RevPAC,
//	|	0 AS RevPACWithoutVAT,
//	|	0 AS ALS,
//	|	0 AS ВсегоНомеров,
//	|	0 AS ВсегоМест,
//	|	0 AS TotalRoomsBlocked,
//	|	0 AS TotalBedsBlocked,
//	|	0 AS TotalRoomsAvailable,
//	|	0 AS TotalBedsAvailable,
//	|	0 AS RoomsPerRoomType,
//	|	0 AS BedsPerRoomType,
//	|	0 AS RoomsBlockedPerRoomType,
//	|	0 AS BedsBlockedPerRoomType,
//	|	0 AS RoomsAvailablePerRoomType,
//	|	0 AS BedsAvailablePerRoomType,
//	|	0 AS TotalRoomsRentedPercent,
//	|	0 AS TotalBedsRentedPercent,
//	|	0 AS TotalRoomsRentedWithBlocksPercent,
//	|	0 AS TotalBedsRentedWithBlocksPercent,
//	|	0 AS RoomsRentedPercent,
//	|	0 AS BedsRentedPercent,
//	|	0 AS RoomsRentedWithBlocksPercent,
//	|	0 AS BedsRentedWithBlocksPercent
//	|{SELECT
//	|	Валюта.*,
//	|	Гостиница.*,
//	|	ТипНомера.*,
//	|	Продажи,
//	|	ДоходНомеров,
//	|	ПродажиБезНДС,
//	|	ДоходПродажиБезНДС,
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
//	|	ADR,
//	|	ADRWithoutVAT,
//	|	ADBR,
//	|	ADBRWithoutVAT,
//	|	RevPAR,
//	|	RevPARWithoutVAT,
//	|	RevPAB,
//	|	RevPABWithoutVAT,
//	|	RevPAC,
//	|	RevPACWithoutVAT,
//	|	ALS,
//	|	ВсегоНомеров,
//	|	ВсегоМест,
//	|	TotalRoomsBlocked,
//	|	TotalBedsBlocked,
//	|	TotalRoomsAvailable,
//	|	TotalBedsAvailable,
//	|	RoomsPerRoomType,
//	|	BedsPerRoomType,
//	|	RoomsBlockedPerRoomType,
//	|	BedsBlockedPerRoomType,
//	|	RoomsAvailablePerRoomType,
//	|	BedsAvailablePerRoomType,
//	|	TotalRoomsRentedPercent,
//	|	TotalBedsRentedPercent,
//	|	TotalRoomsRentedWithBlocksPercent,
//	|	TotalBedsRentedWithBlocksPercent,
//	|	RoomsRentedPercent,
//	|	BedsRentedPercent,
//	|	RoomsRentedWithBlocksPercent,
//	|	BedsRentedWithBlocksPercent}
//	|FROM
//	|	(SELECT
//	|		ОборотыПродажиНомеров.Валюта AS Валюта,
//	|		ОборотыПродажиНомеров.Гостиница AS Гостиница,
//	|		ОборотыПродажиНомеров.ТипНомера AS ТипНомера,
//	|		ОборотыПродажиНомеров.SalesTurnover AS SalesTurnover,
//	|		ОборотыПродажиНомеров.RoomRevenueTurnover AS RoomRevenueTurnover,
//	|		ОборотыПродажиНомеров.SalesWithoutVATTurnover AS SalesWithoutVATTurnover,
//	|		ОборотыПродажиНомеров.RoomRevenueWithoutVATTurnover AS RoomRevenueWithoutVATTurnover,
//	|		ОборотыПродажиНомеров.CommissionSumTurnover AS CommissionSumTurnover,
//	|		ОборотыПродажиНомеров.CommissionSumWithoutVATTurnover AS CommissionSumWithoutVATTurnover,
//	|		ОборотыПродажиНомеров.DiscountSumTurnover AS DiscountSumTurnover,
//	|		ОборотыПродажиНомеров.DiscountSumWithoutVATTurnover AS DiscountSumWithoutVATTurnover,
//	|		ОборотыПродажиНомеров.RoomsRentedTurnover AS RoomsRentedTurnover,
//	|		ОборотыПродажиНомеров.BedsRentedTurnover AS BedsRentedTurnover,
//	|		ОборотыПродажиНомеров.AdditionalBedsRentedTurnover AS AdditionalBedsRentedTurnover,
//	|		ОборотыПродажиНомеров.GuestDaysTurnover AS GuestDaysTurnover,
//	|		ОборотыПродажиНомеров.GuestsCheckedInTurnover AS GuestsCheckedInTurnover,
//	|		ОборотыПродажиНомеров.RoomsCheckedInTurnover AS RoomsCheckedInTurnover,
//	|		ОборотыПродажиНомеров.BedsCheckedInTurnover AS BedsCheckedInTurnover,
//	|		ОборотыПродажиНомеров.AdditionalBedsCheckedInTurnover AS AdditionalBedsCheckedInTurnover,
//	|		ОборотыПродажиНомеров.QuantityTurnover AS QuantityTurnover
//	|	FROM
//	|		AccumulationRegister.Продажи.Turnovers(
//	|				&qPeriodFrom,
//	|				&qPeriodTo,
//	|				Period,
//	|				Гостиница IN HIERARCHY (&qHotel)
//	|					AND (НомерРазмещения IN HIERARCHY (&qRoom)
//	|						OR &qIsEmptyRoom)
//	|					AND (ТипНомера IN HIERARCHY (&qRoomType)
//	|						OR &qIsEmptyRoomType)
//	|					AND (Услуга IN HIERARCHY (&qService)
//	|						OR &qIsEmptyService)
//	|					AND (Услуга IN HIERARCHY (&qServicesList)
//	|						OR (NOT &qUseServicesList))) AS ОборотыПродажиНомеров
//	|	
//	|	UNION ALL
//	|	
//	|	SELECT
//	|		RoomSalesForecastTurnovers.Валюта,
//	|		RoomSalesForecastTurnovers.Гостиница,
//	|		RoomSalesForecastTurnovers.ТипНомера,
//	|		RoomSalesForecastTurnovers.SalesTurnover,
//	|		RoomSalesForecastTurnovers.RoomRevenueTurnover,
//	|		RoomSalesForecastTurnovers.SalesWithoutVATTurnover,
//	|		RoomSalesForecastTurnovers.RoomRevenueWithoutVATTurnover,
//	|		RoomSalesForecastTurnovers.CommissionSumTurnover,
//	|		RoomSalesForecastTurnovers.CommissionSumWithoutVATTurnover,
//	|		RoomSalesForecastTurnovers.DiscountSumTurnover,
//	|		RoomSalesForecastTurnovers.DiscountSumWithoutVATTurnover,
//	|		RoomSalesForecastTurnovers.RoomsRentedTurnover,
//	|		RoomSalesForecastTurnovers.BedsRentedTurnover,
//	|		RoomSalesForecastTurnovers.AdditionalBedsRentedTurnover,
//	|		RoomSalesForecastTurnovers.GuestDaysTurnover,
//	|		RoomSalesForecastTurnovers.GuestsCheckedInTurnover,
//	|		RoomSalesForecastTurnovers.RoomsCheckedInTurnover,
//	|		RoomSalesForecastTurnovers.BedsCheckedInTurnover,
//	|		RoomSalesForecastTurnovers.AdditionalBedsCheckedInTurnover,
//	|		RoomSalesForecastTurnovers.QuantityTurnover
//	|	FROM
//	|		AccumulationRegister.ПрогнозПродаж.Turnovers(
//	|				&qForecastPeriodFrom,
//	|				&qForecastPeriodTo,
//	|				Period,
//	|				Гостиница IN HIERARCHY (&qHotel)
//	|					AND (НомерРазмещения IN HIERARCHY (&qRoom)
//	|						OR &qIsEmptyRoom)
//	|					AND (ТипНомера IN HIERARCHY (&qRoomType)
//	|						OR &qIsEmptyRoomType)
//	|					AND (Услуга IN HIERARCHY (&qService)
//	|						OR &qIsEmptyService)
//	|					AND (Услуга IN HIERARCHY (&qServicesList)
//	|						OR (NOT &qUseServicesList))) AS RoomSalesForecastTurnovers) AS RoomSales
//	|{WHERE
//	|	RoomSales.Валюта.*,
//	|	RoomSales.Гостиница.*,
//	|	RoomSales.ТипНомера.* AS ТипНомера,
//	|	(SUM(RoomSales.SalesTurnover)) AS Продажи,
//	|	(SUM(RoomSales.RoomRevenueTurnover)) AS ДоходНомеров,
//	|	(SUM(RoomSales.SalesWithoutVATTurnover)) AS ПродажиБезНДС,
//	|	(SUM(RoomSales.RoomRevenueWithoutVATTurnover)) AS ДоходПродажиБезНДС,
//	|	(SUM(RoomSales.CommissionSumTurnover)) AS СуммаКомиссии,
//	|	(SUM(RoomSales.CommissionSumWithoutVATTurnover)) AS КомиссияБезНДС,
//	|	(SUM(RoomSales.DiscountSumTurnover)) AS СуммаСкидки,
//	|	(SUM(RoomSales.DiscountSumWithoutVATTurnover)) AS СуммаСкидкиБезНДС,
//	|	(SUM(RoomSales.RoomsRentedTurnover)) AS ПроданоНомеров,
//	|	(SUM(RoomSales.BedsRentedTurnover)) AS ПроданоМест,
//	|	(SUM(RoomSales.AdditionalBedsRentedTurnover)) AS ПроданоДопМест,
//	|	(SUM(RoomSales.GuestDaysTurnover)) AS ЧеловекаДни,
//	|	(SUM(RoomSales.GuestsCheckedInTurnover)) AS ЗаездГостей,
//	|	(SUM(RoomSales.RoomsCheckedInTurnover)) AS ЗаездНомеров,
//	|	(SUM(RoomSales.BedsCheckedInTurnover)) AS ЗаездМест,
//	|	(SUM(RoomSales.AdditionalBedsCheckedInTurnover)) AS ЗаездДополнительныхМест,
//	|	(SUM(RoomSales.QuantityTurnover)) AS Количество,
//	|	(0) AS ADR,
//	|	(0) AS ADRWithoutVAT,
//	|	(0) AS ADBR,
//	|	(0) AS ADBRWithoutVAT,
//	|	(0) AS RevPAR,
//	|	(0) AS RevPARWithoutVAT,
//	|	(0) AS RevPAB,
//	|	(0) AS RevPABWithoutVAT,
//	|	(0) AS RevPAC,
//	|	(0) AS RevPACWithoutVAT,
//	|	(0) AS ALS,
//	|	(0) AS ВсегоНомеров,
//	|	(0) AS ВсегоМест,
//	|	(0) AS TotalRoomsBlocked,
//	|	(0) AS TotalBedsBlocked,
//	|	(0) AS TotalRoomsAvailable,
//	|	(0) AS TotalBedsAvailable,
//	|	(0) AS RoomsPerRoomType,
//	|	(0) AS BedsPerRoomType,
//	|	(0) AS RoomsBlockedPerRoomType,
//	|	(0) AS BedsBlockedPerRoomType,
//	|	(0) AS RoomsAvailablePerRoomType,
//	|	(0) AS BedsAvailablePerRoomType,
//	|	(0) AS TotalRoomsRentedPercent,
//	|	(0) AS TotalBedsRentedPercent,
//	|	(0) AS TotalRoomsRentedWithBlocksPercent,
//	|	(0) AS TotalBedsRentedWithBlocksPercent,
//	|	(0) AS RoomsRentedPercent,
//	|	(0) AS BedsRentedPercent,
//	|	(0) AS RoomsRentedWithBlocksPercent,
//	|	(0) AS BedsRentedWithBlocksPercent}
//	|
//	|GROUP BY
//	|	RoomSales.Валюта,
//	|	RoomSales.Гостиница,
//	|	RoomSales.ТипНомера
//	|
//	|ORDER BY
//	|	RoomSales.Валюта.ПорядокСортировки,
//	|	RoomSales.Гостиница.ПорядокСортировки,
//	|	RoomSales.ТипНомера.ПорядокСортировки
//	|{ORDER BY
//	|	Валюта.*,
//	|	Гостиница.*,
//	|	ТипНомера.*,
//	|	Продажи,
//	|	ДоходНомеров,
//	|	ПродажиБезНДС,
//	|	ДоходПродажиБезНДС,
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
//	|	ADR,
//	|	ADRWithoutVAT,
//	|	ADBR,
//	|	ADBRWithoutVAT,
//	|	RevPAR,
//	|	RevPARWithoutVAT,
//	|	RevPAB,
//	|	RevPABWithoutVAT,
//	|	RevPAC,
//	|	RevPACWithoutVAT,
//	|	ALS,
//	|	ВсегоНомеров,
//	|	ВсегоМест,
//	|	TotalRoomsBlocked,
//	|	TotalBedsBlocked,
//	|	TotalRoomsAvailable,
//	|	TotalBedsAvailable,
//	|	RoomsPerRoomType,
//	|	BedsPerRoomType,
//	|	RoomsBlockedPerRoomType,
//	|	BedsBlockedPerRoomType,
//	|	RoomsAvailablePerRoomType,
//	|	BedsAvailablePerRoomType,
//	|	TotalRoomsRentedPercent,
//	|	TotalBedsRentedPercent,
//	|	TotalRoomsRentedWithBlocksPercent,
//	|	TotalBedsRentedWithBlocksPercent,
//	|	RoomsRentedPercent,
//	|	BedsRentedPercent,
//	|	RoomsRentedWithBlocksPercent,
//	|	BedsRentedWithBlocksPercent}
//	|TOTALS
//	|	SUM(Продажи),
//	|	SUM(ДоходНомеров),
//	|	SUM(ПродажиБезНДС),
//	|	SUM(ДоходПродажиБезНДС),
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
//	|	SUM(RoomsPerRoomType),
//	|	SUM(BedsPerRoomType),
//	|	SUM(RoomsBlockedPerRoomType),
//	|	SUM(BedsBlockedPerRoomType)
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
//	ReportBuilder.HeaderText = NStr("en='ГруппаНомеров types sales turnovers';ru='Обороты по продажам типов номеров';de='Umsätze aus Zimmertypverkäufen'");
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
//	   Or pName = "ADR"
//	   Or pName = "ADRWithoutVAT"
//	   Or pName = "ADBR"
//	   Or pName = "ADBRWithoutVAT"
//	   Or pName = "RevPAR"
//	   Or pName = "RevPARWithoutVAT"
//	   Or pName = "RevPAB"
//	   Or pName = "RevPABWithoutVAT"
//	   Or pName = "RevPAC"
//	   Or pName = "RevPACWithoutVAT"
//	   Or pName = "ALS"
//	   Or pName = "ВсегоНомеров"
//	   Or pName = "ВсегоМест"
//	   Or pName = "TotalRoomsBlocked"
//	   Or pName = "TotalBedsBlocked"
//	   Or pName = "TotalRoomsAvailable"
//	   Or pName = "TotalBedsAvailable"
//	   Or pName = "RoomsPerRoomType"
//	   Or pName = "BedsPerRoomType"
//	   Or pName = "RoomsBlockedPerRoomType"
//	   Or pName = "BedsBlockedPerRoomType"
//	   Or pName = "RoomsAvailablePerRoomType"
//	   Or pName = "BedsAvailablePerRoomType"
//	   Or pName = "TotalRoomsRentedPercent"
//	   Or pName = "TotalBedsRentedPercent"
//	   Or pName = "TotalRoomsRentedWithBlocksPercent"
//	   Or pName = "TotalBedsRentedWithBlocksPercent" 
//	   Or pName = "RoomsRentedPercent"
//	   Or pName = "BedsRentedPercent"
//	   Or pName = "RoomsRentedWithBlocksPercent"
//	   Or pName = "BedsRentedWithBlocksPercent" Тогда
//		Return True;
//	Else
//		Return False;
//	EndIf;
//EndFunction //pmIsResource
//
////-----------------------------------------------------------------------------
//// Reports framework end
////-----------------------------------------------------------------------------
//
////-----------------------------------------------------------------------------
//Процедура AddMissingPeriods(pTbl)
//	If pTbl.Count() > 0 Тогда
//		vLastDayRow = pTbl.Get(0);
//		
//		vDay = BegOfDay(vLastDayRow.Period);
//		While vDay <= BegOfDay(PeriodTo) Do
//			vRow = pTbl.Find(vDay, "Period");
//			If vRow = Неопределено Тогда
//				vRow = pTbl.Add();
//				FillPropertyValues(vRow, vLastDayRow);
//				vRow.Period = vDay;
//			Else
//				vLastDayRow = vRow;
//			EndIf;
//			
//			vDay = vDay + 24*3600;
//		EndDo;
//	EndIf;
//КонецПроцедуры //AddMissingPeriods
