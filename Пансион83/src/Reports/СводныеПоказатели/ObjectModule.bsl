//Перем TotalPerDay;
//Перем TotalPerMonth;
//Перем TotalPerYear;
//Перем TotalPerDayLY;
//Перем TotalPerMonthLY;
//Перем TotalPerYearLY;
//
////-----------------------------------------------------------------------------
//// Reports framework start
////-----------------------------------------------------------------------------
//
////-----------------------------------------------------------------------------
//
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
//	If НЕ ЗначениеЗаполнено(PeriodTo) Тогда
//		PeriodTo = BegOfDay(CurrentDate());
//	EndIf;
//КонецПроцедуры //pmFillAttributesWithDefaultValues
//
////-----------------------------------------------------------------------------
//// Reports framework end
////-----------------------------------------------------------------------------
//
////-----------------------------------------------------------------------------
//Function pmBegOfYear(pDate) Экспорт
//	If UseSlidingPeriod Тогда
//		Return BegOfDay(pDate) - 365*24*3600;
//	Else
//		Return BegOfYear(pDate);
//	EndIf;
//EndFunction //pmBegOfYear
//
////-----------------------------------------------------------------------------
//Function pmBegOfMonth(pDate) Экспорт
//	If UseSlidingPeriod Тогда
//		Return BegOfDay(pDate) - 30*24*3600;
//	Else
//		Return BegOfMonth(pDate);
//	EndIf;
//EndFunction //pmBegOfYear
//
////-----------------------------------------------------------------------------
//Процедура GetQryResultTableTotals(pTbl, pTemplate, pResources, pConvertToTurnover = True)
//	// Convert pTbl to the value table if necessary
//	vTbl = pTbl;
//	If TypeOf(pTbl) = Type("Array") Тогда
//		vTbl = pTemplate.CopyColumns();
//		For Each vRow In pTbl Do
//			vTblRow = vTbl.Add();
//			FillPropertyValues(vTblRow, vRow);
//		EndDo;
//	EndIf;
//	
//	// Group all resources to the 3 rows - day, month, year
//	vBegOfYear = pmBegOfYear(PeriodTo);
//	vBegOfMonth = pmBegOfMonth(PeriodTo);
//	vBegOfDay = BegOfDay(PeriodTo);
//	
//	vTblPerDay = pTemplate.CopyColumns();
//	TotalPerDay = vTblPerDay.Add();
//	vTblPerMonth = pTemplate.CopyColumns();
//	TotalPerMonth = vTblPerMonth.Add();
//	vTblPerYear = pTemplate.CopyColumns();
//	TotalPerYear = vTblPerYear.Add();
//	
//	vLastDayRow = TotalPerYear;
//	vLastDayRow.Period = vBegOfYear;
//	
//	If vTbl.Count() > 0 Тогда
//		vDay = vBegOfYear;
//		
//		While vDay <= vBegOfDay Do
//			vDayRow = vTbl.Find(vDay, "Period");
//			If pConvertToTurnover Тогда
//				If vDayRow = Неопределено Тогда
//					vDayRow = vLastDayRow;
//				Else
//					vLastDayRow = vDayRow;
//				EndIf;
//			Else
//				If vDayRow = Неопределено Тогда
//					vDayRow = vLastDayRow;
//				EndIf;
//			EndIf;
//			vDayRow.Period = vDay;
//			
//			vRowPerYear = vTblPerYear.Add();
//			FillPropertyValues(vRowPerYear, vDayRow);
//			
//			If BegOfDay(vDayRow.Period) >= vBegOfMonth Тогда
//				vRowPerMonth = vTblPerMonth.Add();
//				FillPropertyValues(vRowPerMonth, vDayRow);
//			EndIf;
//			
//			If BegOfDay(vDayRow.Period) = vBegOfDay Тогда
//				vRowPerDay = vTblPerDay.Add();
//				FillPropertyValues(vRowPerDay, vDayRow);
//			EndIf;
//			
//			vDay = vDay + 24*3600;
//		EndDo;
//		
//		vTblPerYear.GroupBy(, pResources);
//		TotalPerYear = vTblPerYear.Get(0);
//		
//		vTblPerMonth.GroupBy(, pResources);
//		TotalPerMonth = vTblPerMonth.Get(0);
//		
//		vTblPerDay.GroupBy(, pResources);
//		TotalPerDay = vTblPerDay.Get(0);
//	EndIf;
//КонецПроцедуры //GetQryResultTableTotals
//
////-----------------------------------------------------------------------------
//Процедура GetQryResultTableTotalsLY(pTbl, pTemplate, pResources, pConvertToTurnover = True)
//	// Convert pTbl to the value table if necessary
//	vTbl = pTbl;
//	If TypeOf(pTbl) = Type("Array") Тогда
//		vTbl = pTemplate.CopyColumns();
//		For Each vRow In pTbl Do
//			vTblRow = vTbl.Add();
//			FillPropertyValues(vTblRow, vRow);
//		EndDo;
//	EndIf;
//	
//	// Group all resources to the 3 rows - day, month, year
//	vPeriodToLY = AddMonth(PeriodTo, -12);
//	vBegOfYear = pmBegOfYear(vPeriodToLY);
//	vBegOfMonth = pmBegOfMonth(vPeriodToLY);
//	vBegOfDay = BegOfDay(vPeriodToLY);
//	
//	vTblPerDay = pTemplate.CopyColumns();
//	TotalPerDayLY = vTblPerDay.Add();
//	vTblPerMonth = pTemplate.CopyColumns();
//	TotalPerMonthLY = vTblPerMonth.Add();
//	vTblPerYear = pTemplate.CopyColumns();
//	TotalPerYearLY = vTblPerYear.Add();
//	
//	vLastDayRow = TotalPerYearLY;
//	vLastDayRow.Period = vBegOfYear;
//	
//	If vTbl.Count() > 0 Тогда
//		vDay = vBegOfYear;
//		
//		While vDay <= vBegOfDay Do
//			vDayRow = vTbl.Find(vDay, "Period");
//			If pConvertToTurnover Тогда
//				If vDayRow = Неопределено Тогда
//					vDayRow = vLastDayRow;
//				Else
//					vLastDayRow = vDayRow;
//				EndIf;
//			Else
//				If vDayRow = Неопределено Тогда
//					vDayRow = vLastDayRow;
//				EndIf;
//			EndIf;
//			vDayRow.Period = vDay;
//			
//			vRowPerYear = vTblPerYear.Add();
//			FillPropertyValues(vRowPerYear, vDayRow);
//			
//			If BegOfDay(vDayRow.Period) >= vBegOfMonth Тогда
//				vRowPerMonth = vTblPerMonth.Add();
//				FillPropertyValues(vRowPerMonth, vDayRow);
//			EndIf;
//			
//			If BegOfDay(vDayRow.Period) = vBegOfDay Тогда
//				vRowPerDay = vTblPerDay.Add();
//				FillPropertyValues(vRowPerDay, vDayRow);
//			EndIf;
//			
//			vDay = vDay + 24*3600;
//		EndDo;
//		
//		vTblPerYear.GroupBy(, pResources);
//		TotalPerYearLY = vTblPerYear.Get(0);
//		
//		vTblPerMonth.GroupBy(, pResources);
//		TotalPerMonthLY = vTblPerMonth.Get(0);
//		
//		vTblPerDay.GroupBy(, pResources);
//		TotalPerDayLY = vTblPerDay.Get(0);
//	EndIf;
//КонецПроцедуры //GetQryResultTableTotalsLY
//
////-----------------------------------------------------------------------------
//Процедура pmGenerate(pSpreadsheet) Экспорт
//	// Choose template
//	If ShowPreviousYearData Тогда
//		vTemplate = ThisObject.GetTemplate("ReportWithPreviousYear");
//	Else
//		vTemplate = ThisObject.GetTemplate("Report");
//	EndIf;
//	
//	// Report header
//	vHeader = vTemplate.GetArea("Header");
//	
//	// Fill header parameters
//	vHeader.Parameters.mReportName = NStr("en='Summary indexes';ru='Сводные показатели';de='Gesamtindikatoren'") + " - " + CurrentDate() + ", " + TrimAll(ПараметрыСеанса.РабочееМесто) + ", " + TrimAll(ПараметрыСеанса.ТекПользователь);
//	vHeader.Parameters.mFilter = NStr("en='Filter:';ru='Отбор:';de='Auswahl:'") + Chars.LF + 
//	                             NStr("ru = 'Период '; en = 'Period '") + Format(PeriodTo, "DF='dd.MM.yyyy'") + ";" + Chars.LF + 
//	                             NStr("en='Гостиница ';ru='Гостиница ';de='Гостиница'") + TrimAll(Гостиница) + ";";
//	// Put header
//	pSpreadsheet.Put(vHeader);
//	
//	// Put table header
//	If UseSlidingPeriod Тогда
//		vArea = vTemplate.GetArea("TableSlidingHeader");
//	Else
//		vArea = vTemplate.GetArea("TableHeader");
//	EndIf;
//	vArea.Parameters.mDate = Format(PeriodTo, "DF=dd.MM.yy");
//	vArea.Parameters.mMonthPeriod = Format(pmBegOfMonth(PeriodTo), "DF=dd.MM.yy") + " - " + Format(PeriodTo, "DF=dd.MM.yy");
//	vArea.Parameters.mYearPeriod = Format(pmBegOfYear(PeriodTo), "DF=dd.MM.yy") + " - " + Format(PeriodTo, "DF=dd.MM.yy");
//	If ShowPreviousYearData Тогда
//		vPeriodToLY = AddMonth(PeriodTo, -12);
//		vArea.Parameters.mDateLY = Format(vPeriodToLY, "DF=dd.MM.yy");
//		vArea.Parameters.mMonthPeriodLY = Format(pmBegOfMonth(vPeriodToLY), "DF=dd.MM.yy") + " - " + Format(vPeriodToLY, "DF=dd.MM.yy");
//		vArea.Parameters.mYearPeriodLY = Format(pmBegOfYear(vPeriodToLY), "DF=dd.MM.yy") + " - " + Format(vPeriodToLY, "DF=dd.MM.yy");
//	EndIf;
//	pSpreadsheet.Put(vArea);
//	
//	// Set type of output - in rooms or in beds and with VAT or without
//	vInRooms = True;
//	vWithVAT = True;
//	If ЗначениеЗаполнено(Гостиница) Тогда
//		vInRooms = НЕ Гостиница.ShowReportsInBeds;
//		vWithVAT = Гостиница.ShowSalesInReportsWithVAT;
//	EndIf;
//	
//	// 1. Occupation summary indexes
//	
//	// Put section header
//	vArea = vTemplate.GetArea("OccupationHeader");
//	pSpreadsheet.Put(vArea);
//	
//	// Run query to get total number of rooms, rooms blocked, vacant number of rooms
//	vQry = New Query();
//	vQry.Text = 
//	"SELECT
//	|	RoomInventoryBalanceAndTurnovers.Period AS Period,
//	|	SUM(RoomInventoryBalanceAndTurnovers.CounterClosingBalance) AS CounterClosingBalance,
//	|	SUM(RoomInventoryBalanceAndTurnovers.TotalRoomsClosingBalance) AS TotalRoomsClosingBalance,
//	|	SUM(RoomInventoryBalanceAndTurnovers.TotalBedsClosingBalance) AS TotalBedsClosingBalance,
//	|	-SUM(RoomInventoryBalanceAndTurnovers.RoomsBlockedClosingBalance) AS RoomsBlockedClosingBalance,
//	|	-SUM(RoomInventoryBalanceAndTurnovers.BedsBlockedClosingBalance) AS BedsBlockedClosingBalance
//	|FROM
//	|	AccumulationRegister.ЗагрузкаНомеров.BalanceAndTurnovers(&qPeriodFrom, &qPeriodTo, Day, RegisterRecordsAndPeriodBoundaries, Гостиница IN HIERARCHY (&qHotel)) AS RoomInventoryBalanceAndTurnovers
//	|GROUP BY
//	|	RoomInventoryBalanceAndTurnovers.Period
//	|ORDER BY
//	|	Period";
//	vQry.SetParameter("qPeriodFrom", pmBegOfYear(PeriodTo));
//	vQry.SetParameter("qPeriodTo", EndOfDay(PeriodTo));
//	vQry.SetParameter("qHotel", Гостиница);
//	vQryResult = vQry.Execute().Unload();
//	
//	vResources = "TotalRoomsClosingBalance, TotalBedsClosingBalance, RoomsBlockedClosingBalance, BedsBlockedClosingBalance";
//	GetQryResultTableTotals(vQryResult, vQryResult, vResources);
//	
//	PeriodToLY = AddMonth(PeriodTo, -12);
//	
//	If ShowPreviousYearData Тогда
//		// Run query to get total number of rooms, rooms blocked, vacant number of rooms
//		vQryLY = New Query();
//		vQryLY.Text = 
//		"SELECT
//		|	RoomInventoryBalanceAndTurnovers.Period AS Period,
//		|	SUM(RoomInventoryBalanceAndTurnovers.CounterClosingBalance) AS CounterClosingBalance,
//		|	SUM(RoomInventoryBalanceAndTurnovers.TotalRoomsClosingBalance) AS TotalRoomsClosingBalance,
//		|	SUM(RoomInventoryBalanceAndTurnovers.TotalBedsClosingBalance) AS TotalBedsClosingBalance,
//		|	-SUM(RoomInventoryBalanceAndTurnovers.RoomsBlockedClosingBalance) AS RoomsBlockedClosingBalance,
//		|	-SUM(RoomInventoryBalanceAndTurnovers.BedsBlockedClosingBalance) AS BedsBlockedClosingBalance
//		|FROM
//		|	AccumulationRegister.ЗагрузкаНомеров.BalanceAndTurnovers(&qPeriodFrom, &qPeriodTo, Day, RegisterRecordsAndPeriodBoundaries, Гостиница IN HIERARCHY (&qHotel)) AS RoomInventoryBalanceAndTurnovers
//		|GROUP BY
//		|	RoomInventoryBalanceAndTurnovers.Period
//		|ORDER BY
//		|	Period";
//		vQryLY.SetParameter("qPeriodFrom", pmBegOfYear(PeriodToLY));
//		vQryLY.SetParameter("qPeriodTo", EndOfDay(PeriodToLY));
//		vQryLY.SetParameter("qHotel", Гостиница);
//		vQryResultLY = vQryLY.Execute().Unload();
//		
//		GetQryResultTableTotalsLY(vQryResultLY, vQryResultLY, vResources);
//	EndIf;
//	
//	// Put total rooms
//	If vInRooms Тогда
//		vArea = vTemplate.GetArea("ВсегоНомеров");
//		vArea.Parameters.mTotalRooms = cmCastToNumber(TotalPerDay.TotalRoomsClosingBalance);
//		vArea.Parameters.mTotalRoomsPerMonth = cmCastToNumber(TotalPerMonth.TotalRoomsClosingBalance);
//		vArea.Parameters.mTotalRoomsPerYear = cmCastToNumber(TotalPerYear.TotalRoomsClosingBalance);
//		If ShowPreviousYearData Тогда
//			vArea.Parameters.mTotalRoomsLY = cmCastToNumber(TotalPerDayLY.TotalRoomsClosingBalance);
//			vArea.Parameters.mTotalRoomsPerMonthLY = cmCastToNumber(TotalPerMonthLY.TotalRoomsClosingBalance);
//			vArea.Parameters.mTotalRoomsPerYearLY = cmCastToNumber(TotalPerYearLY.TotalRoomsClosingBalance);
//		EndIf;
//		pSpreadsheet.Put(vArea);
//	Else
//		vArea = vTemplate.GetArea("ВсегоМест");
//		vArea.Parameters.mTotalBeds = cmCastToNumber(TotalPerDay.TotalBedsClosingBalance);
//		vArea.Parameters.mTotalBedsPerMonth = cmCastToNumber(TotalPerMonth.TotalBedsClosingBalance);
//		vArea.Parameters.mTotalBedsPerYear = cmCastToNumber(TotalPerYear.TotalBedsClosingBalance);
//		If ShowPreviousYearData Тогда
//			vArea.Parameters.mTotalBedsLY = cmCastToNumber(TotalPerDayLY.TotalBedsClosingBalance);
//			vArea.Parameters.mTotalBedsPerMonthLY = cmCastToNumber(TotalPerMonthLY.TotalBedsClosingBalance);
//			vArea.Parameters.mTotalBedsPerYearLY = cmCastToNumber(TotalPerYearLY.TotalBedsClosingBalance);
//		EndIf;
//		pSpreadsheet.Put(vArea);
//	EndIf;
//	
//	vTotalRooms = cmCastToNumber(TotalPerDay.TotalRoomsClosingBalance);
//	vRoomsBlocked =  cmCastToNumber(TotalPerDay.RoomsBlockedClosingBalance);
//	vRoomsForSale = vTotalRooms - vRoomsBlocked;
//	vTotalBeds = cmCastToNumber(TotalPerDay.TotalBedsClosingBalance);
//	vBedsBlocked = cmCastToNumber(TotalPerDay.BedsBlockedClosingBalance);
//	vBedsForSale = vTotalBeds - vBedsBlocked;
//	
//	vTotalRoomsPerMonth = cmCastToNumber(TotalPerMonth.TotalRoomsClosingBalance);
//	vRoomsBlockedPerMonth = cmCastToNumber(TotalPerMonth.RoomsBlockedClosingBalance);
//	vRoomsForSalePerMonth = vTotalRoomsPerMonth - vRoomsBlockedPerMonth;
//	vTotalBedsPerMonth = cmCastToNumber(TotalPerMonth.TotalBedsClosingBalance);
//	vBedsBlockedPerMonth = cmCastToNumber(TotalPerMonth.BedsBlockedClosingBalance);
//	vBedsForSalePerMonth = vTotalBedsPerMonth - vBedsBlockedPerMonth;
//	
//	vTotalRoomsPerYear = cmCastToNumber(TotalPerYear.TotalRoomsClosingBalance);
//	vRoomsBlockedPerYear = cmCastToNumber(TotalPerYear.RoomsBlockedClosingBalance);
//	vRoomsForSalePerYear = vTotalRoomsPerYear - vRoomsBlockedPerYear;
//	vTotalBedsPerYear = cmCastToNumber(TotalPerYear.TotalBedsClosingBalance);
//	vBedsBlockedPerYear = cmCastToNumber(TotalPerYear.BedsBlockedClosingBalance);
//	vBedsForSalePerYear = vTotalBedsPerYear - vBedsBlockedPerYear;
//	
//	vSpecRoomsBlocked = 0;
//	vSpecBedsBlocked = 0;
//	vSpecRoomsBlockedPerMonth = 0;
//	vSpecBedsBlockedPerMonth = 0;
//	vSpecRoomsBlockedPerYear = 0;
//	vSpecBedsBlockedPerYear = 0;
//	
//	If ShowPreviousYearData Тогда
//		vTotalRoomsLY = cmCastToNumber(TotalPerDayLY.TotalRoomsClosingBalance);
//		vRoomsBlockedLY =  cmCastToNumber(TotalPerDayLY.RoomsBlockedClosingBalance);
//		vRoomsForSaleLY = vTotalRoomsLY - vRoomsBlockedLY;
//		vTotalBedsLY = cmCastToNumber(TotalPerDayLY.TotalBedsClosingBalance);
//		vBedsBlockedLY = cmCastToNumber(TotalPerDayLY.BedsBlockedClosingBalance);
//		vBedsForSaleLY = vTotalBedsLY - vBedsBlockedLY;
//		
//		vTotalRoomsPerMonthLY = cmCastToNumber(TotalPerMonthLY.TotalRoomsClosingBalance);
//		vRoomsBlockedPerMonthLY = cmCastToNumber(TotalPerMonthLY.RoomsBlockedClosingBalance);
//		vRoomsForSalePerMonthLY = vTotalRoomsPerMonthLY - vRoomsBlockedPerMonthLY;
//		vTotalBedsPerMonthLY = cmCastToNumber(TotalPerMonthLY.TotalBedsClosingBalance);
//		vBedsBlockedPerMonthLY = cmCastToNumber(TotalPerMonthLY.BedsBlockedClosingBalance);
//		vBedsForSalePerMonthLY = vTotalBedsPerMonthLY - vBedsBlockedPerMonthLY;
//		
//		vTotalRoomsPerYearLY = cmCastToNumber(TotalPerYearLY.TotalRoomsClosingBalance);
//		vRoomsBlockedPerYearLY = cmCastToNumber(TotalPerYearLY.RoomsBlockedClosingBalance);
//		vRoomsForSalePerYearLY = vTotalRoomsPerYearLY - vRoomsBlockedPerYearLY;
//		vTotalBedsPerYearLY = cmCastToNumber(TotalPerYearLY.TotalBedsClosingBalance);
//		vBedsBlockedPerYearLY = cmCastToNumber(TotalPerYearLY.BedsBlockedClosingBalance);
//		vBedsForSalePerYearLY = vTotalBedsPerYearLY - vBedsBlockedPerYearLY;
//		
//		vSpecRoomsBlockedLY = 0;
//		vSpecBedsBlockedLY = 0;
//		vSpecRoomsBlockedPerMonthLY = 0;
//		vSpecBedsBlockedPerMonthLY = 0;
//		vSpecRoomsBlockedPerYearLY = 0;
//		vSpecBedsBlockedPerYearLY = 0;
//	EndIf;
//	
//	// Run query to get number of blocked rooms per ГруппаНомеров block types
//	vQry = New Query();
//	vQry.Text = 
//	"SELECT
//	|	RoomBlocksBalanceAndTurnovers.RoomBlockType AS RoomBlockType,
//	|	RoomBlocksBalanceAndTurnovers.Period AS Period,
//	|	SUM(RoomBlocksBalanceAndTurnovers.RoomsBlockedClosingBalance) AS RoomsBlockedClosingBalance,
//	|	SUM(RoomBlocksBalanceAndTurnovers.BedsBlockedClosingBalance) AS BedsBlockedClosingBalance
//	|FROM
//	|	AccumulationRegister.БлокирНомеров.BalanceAndTurnovers(&qPeriodFrom, &qPeriodTo, Day, RegisterRecordsAndPeriodBoundaries, Гостиница IN HIERARCHY (&qHotel)) AS RoomBlocksBalanceAndTurnovers
//	|
//	|GROUP BY
//	|	RoomBlocksBalanceAndTurnovers.RoomBlockType,
//	|	RoomBlocksBalanceAndTurnovers.Period
//	|
//	|ORDER BY
//	|	RoomBlocksBalanceAndTurnovers.RoomBlockType.ПорядокСортировки,
//	|	Period";
//	vQry.SetParameter("qPeriodFrom", pmBegOfYear(PeriodTo));
//	vQry.SetParameter("qPeriodTo", EndOfDay(PeriodTo));
//	vQry.SetParameter("qHotel", Гостиница);
//	vQryResult = vQry.Execute().Unload();
//	
//	// Get list of ГруппаНомеров block types
//	vRoomBlockTypes = vQryResult.Copy();
//	vRoomBlockTypes.GroupBy("RoomBlockType", );
//	
//	If ShowPreviousYearData Тогда
//		// Run query to get number of blocked rooms per ГруппаНомеров block types
//		vQryLY = New Query();
//		vQryLY.Text = 
//		"SELECT
//		|	RoomBlocksBalanceAndTurnovers.RoomBlockType AS RoomBlockType,
//		|	RoomBlocksBalanceAndTurnovers.Period AS Period,
//		|	SUM(RoomBlocksBalanceAndTurnovers.RoomsBlockedClosingBalance) AS RoomsBlockedClosingBalance,
//		|	SUM(RoomBlocksBalanceAndTurnovers.BedsBlockedClosingBalance) AS BedsBlockedClosingBalance
//		|FROM
//		|	AccumulationRegister.БлокирНомеров.BalanceAndTurnovers(&qPeriodFrom, &qPeriodTo, Day, RegisterRecordsAndPeriodBoundaries, Гостиница IN HIERARCHY (&qHotel)) AS RoomBlocksBalanceAndTurnovers
//		|
//		|GROUP BY
//		|	RoomBlocksBalanceAndTurnovers.RoomBlockType,
//		|	RoomBlocksBalanceAndTurnovers.Period
//		|
//		|ORDER BY
//		|	RoomBlocksBalanceAndTurnovers.RoomBlockType.ПорядокСортировки,
//		|	Period";
//		vQryLY.SetParameter("qPeriodFrom", pmBegOfYear(PeriodToLY));
//		vQryLY.SetParameter("qPeriodTo", EndOfDay(PeriodToLY));
//		vQryLY.SetParameter("qHotel", Гостиница);
//		vQryResultLY = vQryLY.Execute().Unload();
//		
//		// Get list of ГруппаНомеров block types
//		vRoomBlockTypesLY = vQryResultLY.Copy();
//		vRoomBlockTypesLY.GroupBy("RoomBlockType", );
//		
//		// Add last year ГруппаНомеров block types to the current year ones
//		For Each vRBTRowLY In vRoomBlockTypesLY Do
//			If vRoomBlockTypes.Find(vRBTRowLY.RoomBlockType, "RoomBlockType") = Неопределено Тогда
//				vRBTRow = vRoomBlockTypes.Add();
//				vRBTRow.RoomBlockType = vRBTRowLY.RoomBlockType;
//				vQRRow = vQryResult.Add();
//				vQRRow.RoomBlockType = vRBTRowLY.RoomBlockType;
//			EndIf;
//		EndDo;
//		For Each vRBTRow In vRoomBlockTypes Do
//			If vRoomBlockTypesLY.Find(vRBTRow.RoomBlockType, "RoomBlockType") = Неопределено Тогда
//				vRBTRowLY = vRoomBlockTypesLY.Add();
//				vRBTRowLY.RoomBlockType = vRBTRow.RoomBlockType;
//				vQRRowLY = vQryResultLY.Add();
//				vQRRowLY.RoomBlockType = vRBTRow.RoomBlockType;
//			EndIf;
//		EndDo;
//	EndIf;
//	
//	// Put ГруппаНомеров blocks per ГруппаНомеров block type
//	For Each vRow In vRoomBlockTypes Do
//		vRoomBlockType = vRow.RoomBlockType;
//			
//		// Get records for the current ГруппаНомеров block type only
//		vQrySubresult = vQryResult.FindRows(New Structure("RoomBlockType", vRoomBlockType));
//		GetQryResultTableTotals(vQrySubresult, vQryResult, "RoomsBlockedClosingBalance, BedsBlockedClosingBalance");
//		
//		If ShowPreviousYearData Тогда
//			// Try to find row for the same block type in the previous year data
//			vRowLY = vRoomBlockTypesLY.Find(vRoomBlockType, "RoomBlockType");
//			
//			// Get records for the current ГруппаНомеров block type only
//			vQrySubresultLY = vQryResultLY.FindRows(New Structure("RoomBlockType", vRoomBlockType));
//			GetQryResultTableTotalsLY(vQrySubresultLY, vQryResultLY, "RoomsBlockedClosingBalance, BedsBlockedClosingBalance");
//		EndIf;
//		
//		If vInRooms Тогда
//			vArea = vTemplate.GetArea("RoomBlockTypeRooms");
//			vArea.Parameters.mRoomBlockType = vRoomBlockType;
//			vArea.Parameters.mRoomsBlocked = cmCastToNumber(TotalPerDay.RoomsBlockedClosingBalance);
//			vArea.Parameters.mRoomsBlockedPerMonth = cmCastToNumber(TotalPerMonth.RoomsBlockedClosingBalance);
//			vArea.Parameters.mRoomsBlockedPerYear = cmCastToNumber(TotalPerYear.RoomsBlockedClosingBalance);
//			If ShowPreviousYearData Тогда
//				vArea.Parameters.mRoomsBlockedLY = cmCastToNumber(TotalPerDayLY.RoomsBlockedClosingBalance);
//				vArea.Parameters.mRoomsBlockedPerMonthLY = cmCastToNumber(TotalPerMonthLY.RoomsBlockedClosingBalance);
//				vArea.Parameters.mRoomsBlockedPerYearLY = cmCastToNumber(TotalPerYearLY.RoomsBlockedClosingBalance);
//			EndIf;
//			
//			If ShowPreviousYearData Тогда
//				If vArea.Parameters.mRoomsBlocked <> 0 Or
//				   vArea.Parameters.mRoomsBlockedPerMonth <> 0 Or
//				   vArea.Parameters.mRoomsBlockedPerYear Or 
//				   vArea.Parameters.mRoomsBlockedLY <> 0 Or
//				   vArea.Parameters.mRoomsBlockedPerMonthLY <> 0 Or
//				   vArea.Parameters.mRoomsBlockedPerYearLY Тогда 
//					pSpreadsheet.Put(vArea);
//				EndIf;
//			Else
//				If vArea.Parameters.mRoomsBlocked <> 0 Or
//				   vArea.Parameters.mRoomsBlockedPerMonth <> 0 Or
//				   vArea.Parameters.mRoomsBlockedPerYear Тогда
//					pSpreadsheet.Put(vArea);
//				EndIf;
//			EndIf;
//			
//			If vRoomBlockType.AddToRoomsRentedInSummaryIndexes Тогда
//				vSpecRoomsBlocked = vSpecRoomsBlocked + cmCastToNumber(TotalPerDay.RoomsBlockedClosingBalance);
//				vSpecRoomsBlockedPerMonth = vSpecRoomsBlockedPerMonth + cmCastToNumber(TotalPerMonth.RoomsBlockedClosingBalance);
//				vSpecRoomsBlockedPerYear = vSpecRoomsBlockedPerYear + cmCastToNumber(TotalPerYear.RoomsBlockedClosingBalance);
//				If ShowPreviousYearData Тогда
//					vSpecRoomsBlockedLY = vSpecRoomsBlockedLY + cmCastToNumber(TotalPerDayLY.RoomsBlockedClosingBalance);
//					vSpecRoomsBlockedPerMonthLY = vSpecRoomsBlockedPerMonthLY + cmCastToNumber(TotalPerMonthLY.RoomsBlockedClosingBalance);
//					vSpecRoomsBlockedPerYearLY = vSpecRoomsBlockedPerYearLY + cmCastToNumber(TotalPerYearLY.RoomsBlockedClosingBalance);
//				EndIf;
//			EndIf;
//		Else
//			vArea = vTemplate.GetArea("RoomBlockTypeBeds");
//			vArea.Parameters.mRoomBlockType = vRoomBlockType;
//			vArea.Parameters.mBedsBlocked = cmCastToNumber(TotalPerDay.BedsBlockedClosingBalance);
//			vArea.Parameters.mBedsBlockedPerMonth = cmCastToNumber(TotalPerMonth.BedsBlockedClosingBalance);
//			vArea.Parameters.mBedsBlockedPerYear = cmCastToNumber(TotalPerYear.BedsBlockedClosingBalance);
//			If ShowPreviousYearData Тогда
//				vArea.Parameters.mBedsBlockedLY = cmCastToNumber(TotalPerDayLY.BedsBlockedClosingBalance);
//				vArea.Parameters.mBedsBlockedPerMonthLY = cmCastToNumber(TotalPerMonthLY.BedsBlockedClosingBalance);
//				vArea.Parameters.mBedsBlockedPerYearLY = cmCastToNumber(TotalPerYearLY.BedsBlockedClosingBalance);
//			EndIf;
//			
//			If ShowPreviousYearData Тогда
//				If vArea.Parameters.mBedsBlocked <> 0 Or
//				   vArea.Parameters.mBedsBlockedPerMonth <> 0 Or
//				   vArea.Parameters.mBedsBlockedPerYear Or
//				   vArea.Parameters.mBedsBlockedLY <> 0 Or
//				   vArea.Parameters.mBedsBlockedPerMonthLY <> 0 Or
//				   vArea.Parameters.mBedsBlockedPerYearLY Тогда
//					pSpreadsheet.Put(vArea);
//				EndIf;
//			Else
//				If vArea.Parameters.mBedsBlocked <> 0 Or
//				   vArea.Parameters.mBedsBlockedPerMonth <> 0 Or
//				   vArea.Parameters.mBedsBlockedPerYear Тогда
//					pSpreadsheet.Put(vArea);
//				EndIf;
//			EndIf;
//			
//			If vRoomBlockType.AddToRoomsRentedInSummaryIndexes Тогда
//				vSpecBedsBlocked = vSpecBedsBlocked + cmCastToNumber(TotalPerDay.BedsBlockedClosingBalance);
//				vSpecBedsBlockedPerMonth = vSpecBedsBlockedPerMonth + cmCastToNumber(TotalPerMonth.BedsBlockedClosingBalance);
//				vSpecBedsBlockedPerYear = vSpecBedsBlockedPerYear + cmCastToNumber(TotalPerYear.BedsBlockedClosingBalance);
//				If ShowPreviousYearData Тогда
//					vSpecBedsBlockedLY = vSpecBedsBlockedLY + cmCastToNumber(TotalPerDayLY.BedsBlockedClosingBalance);
//					vSpecBedsBlockedPerMonthLY = vSpecBedsBlockedPerMonthLY + cmCastToNumber(TotalPerMonthLY.BedsBlockedClosingBalance);
//					vSpecBedsBlockedPerYearLY = vSpecBedsBlockedPerYearLY + cmCastToNumber(TotalPerYearLY.BedsBlockedClosingBalance);
//				EndIf;
//			EndIf;
//		EndIf;
//	EndDo;
//	
//	// Put rooms for sale
//	If vInRooms Тогда
//		vArea = vTemplate.GetArea("RoomsForSale");
//		vArea.Parameters.mRoomsForSale = vRoomsForSale + vSpecRoomsBlocked;
//		vArea.Parameters.mRoomsForSalePerMonth = vRoomsForSalePerMonth + vSpecRoomsBlockedPerMonth;
//		vArea.Parameters.mRoomsForSalePerYear = vRoomsForSalePerYear + vSpecRoomsBlockedPerYear;
//		If ShowPreviousYearData Тогда
//			vArea.Parameters.mRoomsForSaleLY = vRoomsForSaleLY + vSpecRoomsBlockedLY;
//			vArea.Parameters.mRoomsForSalePerMonthLY = vRoomsForSalePerMonthLY + vSpecRoomsBlockedPerMonthLY;
//			vArea.Parameters.mRoomsForSalePerYearLY = vRoomsForSalePerYearLY + vSpecRoomsBlockedPerYearLY;
//		EndIf;
//		pSpreadsheet.Put(vArea);
//	Else
//		vArea = vTemplate.GetArea("BedsForSale");
//		vArea.Parameters.mBedsForSale = vBedsForSale + vSpecBedsBlocked;
//		vArea.Parameters.mBedsForSalePerMonth = vBedsForSalePerMonth + vSpecBedsBlockedPerMonth;
//		vArea.Parameters.mBedsForSalePerYear = vBedsForSalePerYear + vSpecBedsBlockedPerYear;
//		If ShowPreviousYearData Тогда
//			vArea.Parameters.mBedsForSaleLY = vBedsForSaleLY + vSpecBedsBlockedLY;
//			vArea.Parameters.mBedsForSalePerMonthLY = vBedsForSalePerMonthLY + vSpecBedsBlockedPerMonthLY;
//			vArea.Parameters.mBedsForSalePerYearLY = vBedsForSalePerYearLY + vSpecBedsBlockedPerYearLY;
//		EndIf;
//		pSpreadsheet.Put(vArea);
//	EndIf;
//	
//	// Run query to get ГруппаНомеров sales
//	vQry = New Query();
//	vQry.Text = 
//	"SELECT
//	|	ОборотыПродажиНомеров.Period AS Period,
//	|	ОборотыПродажиНомеров.Тариф.IsComplimentary AS RoomRateIsComplimentary,
//	|	SUM(ОборотыПродажиНомеров.SalesTurnover) AS SalesTurnover,
//	|	SUM(ОборотыПродажиНомеров.SalesWithoutVATTurnover) AS SalesWithoutVATTurnover,
//	|	SUM(ОборотыПродажиНомеров.RoomRevenueTurnover) AS RoomRevenueTurnover,
//	|	SUM(ОборотыПродажиНомеров.RoomRevenueWithoutVATTurnover) AS RoomRevenueWithoutVATTurnover,
//	|	SUM(ОборотыПродажиНомеров.RoomsRentedTurnover) AS RoomsRentedTurnover,
//	|	SUM(ОборотыПродажиНомеров.BedsRentedTurnover) AS BedsRentedTurnover
//	|FROM
//	|	AccumulationRegister.Продажи.Turnovers(&qPeriodFrom, &qPeriodTo, Day, Гостиница IN HIERARCHY (&qHotel)) AS ОборотыПродажиНомеров
//	|GROUP BY
//	|	ОборотыПродажиНомеров.Period,
//	|	ОборотыПродажиНомеров.Тариф.IsComplimentary
//	|ORDER BY
//	|	Period,
//	|	RoomRateIsComplimentary";
//	vQry.SetParameter("qPeriodFrom", pmBegOfYear(PeriodTo));
//	vQry.SetParameter("qPeriodTo", EndOfDay(PeriodTo));
//	vQry.SetParameter("qHotel", Гостиница);
//	vQryResult = vQry.Execute().Unload();
//	
//	If ShowPreviousYearData Тогда
//		vQryLY = New Query();
//		vQryLY.Text = 
//		"SELECT
//		|	ОборотыПродажиНомеров.Period AS Period,
//		|	ОборотыПродажиНомеров.Тариф.IsComplimentary AS RoomRateIsComplimentary,
//		|	SUM(ОборотыПродажиНомеров.SalesTurnover) AS SalesTurnover,
//		|	SUM(ОборотыПродажиНомеров.SalesWithoutVATTurnover) AS SalesWithoutVATTurnover,
//		|	SUM(ОборотыПродажиНомеров.RoomRevenueTurnover) AS RoomRevenueTurnover,
//		|	SUM(ОборотыПродажиНомеров.RoomRevenueWithoutVATTurnover) AS RoomRevenueWithoutVATTurnover,
//		|	SUM(ОборотыПродажиНомеров.RoomsRentedTurnover) AS RoomsRentedTurnover,
//		|	SUM(ОборотыПродажиНомеров.BedsRentedTurnover) AS BedsRentedTurnover
//		|FROM
//		|	AccumulationRegister.Продажи.Turnovers(&qPeriodFrom, &qPeriodTo, Day, Гостиница IN HIERARCHY (&qHotel)) AS ОборотыПродажиНомеров
//		|GROUP BY
//		|	ОборотыПродажиНомеров.Period,
//		|	ОборотыПродажиНомеров.Тариф.IsComplimentary
//		|ORDER BY
//		|	Period,
//		|	RoomRateIsComplimentary";
//		vQryLY.SetParameter("qPeriodFrom", pmBegOfYear(PeriodToLY));
//		vQryLY.SetParameter("qPeriodTo", EndOfDay(PeriodToLY));
//		vQryLY.SetParameter("qHotel", Гостиница);
//		vQryResultLY = vQryLY.Execute().Unload();
//	EndIf;
//	
//	// Add forecast sales if period is set in the future
//	If BegOfDay(PeriodTo) >= BegOfDay(CurrentDate()) Тогда
//		vQry = New Query();
//		vQry.Text = 
//		"SELECT
//		|	RoomSalesForecastTurnovers.Period AS Period,
//		|	RoomSalesForecastTurnovers.Тариф.IsComplimentary AS RoomRateIsComplimentary,
//		|	SUM(RoomSalesForecastTurnovers.SalesTurnover) AS SalesTurnover,
//		|	SUM(RoomSalesForecastTurnovers.SalesWithoutVATTurnover) AS SalesWithoutVATTurnover,
//		|	SUM(RoomSalesForecastTurnovers.RoomRevenueTurnover) AS RoomRevenueTurnover,
//		|	SUM(RoomSalesForecastTurnovers.RoomRevenueWithoutVATTurnover) AS RoomRevenueWithoutVATTurnover,
//		|	SUM(RoomSalesForecastTurnovers.RoomsRentedTurnover) AS RoomsRentedTurnover,
//		|	SUM(RoomSalesForecastTurnovers.BedsRentedTurnover) AS BedsRentedTurnover
//		|FROM
//		|	AccumulationRegister.ПрогнозПродаж.Turnovers(&qPeriodFrom, &qPeriodTo, Day, Гостиница IN HIERARCHY (&qHotel)) AS RoomSalesForecastTurnovers
//		|GROUP BY
//		|	RoomSalesForecastTurnovers.Period,
//		|	RoomSalesForecastTurnovers.Тариф.IsComplimentary
//		|ORDER BY
//		|	Period,
//		|	RoomRateIsComplimentary";
//		vQry.SetParameter("qPeriodFrom", BegOfDay(CurrentDate()));
//		vQry.SetParameter("qPeriodTo", EndOfDay(PeriodTo));
//		vQry.SetParameter("qHotel", Гостиница);
//		vForecastQryResult = vQry.Execute().Unload();
//		
//		// Merge forecast sales with real ones
//		For Each vForecastRow In vForecastQryResult Do
//			vFound = False;
//			For Each vRow In vQryResult Do
//				If vRow.Period = vForecastRow.Period And
//				   vRow.RoomRateIsComplimentary = vForecastRow.RoomRateIsComplimentary Тогда
//					vFound = True;
//				    Break;
//				EndIf;
//			EndDo;
//			If НЕ vFound Тогда
//				vRow = vQryResult.Add();
//				vRow.Period = vForecastRow.Period;
//				vRow.RoomRateIsComplimentary = vForecastRow.RoomRateIsComplimentary;
//				vRow.SalesTurnover = 0;
//				vRow.SalesWithoutVATTurnover = 0;
//				vRow.RoomRevenueTurnover = 0;
//				vRow.RoomRevenueWithoutVATTurnover = 0;
//				vRow.RoomsRentedTurnover = 0;
//				vRow.BedsRentedTurnover = 0;
//			EndIf;
//			vRow.SalesTurnover = vRow.SalesTurnover + vForecastRow.SalesTurnover;
//			vRow.SalesWithoutVATTurnover = vRow.SalesWithoutVATTurnover + vForecastRow.SalesWithoutVATTurnover;
//			vRow.RoomRevenueTurnover = vRow.RoomRevenueTurnover + vForecastRow.RoomRevenueTurnover;
//			vRow.RoomRevenueWithoutVATTurnover = vRow.RoomRevenueWithoutVATTurnover + vForecastRow.RoomRevenueWithoutVATTurnover;
//			vRow.RoomsRentedTurnover = vRow.RoomsRentedTurnover + vForecastRow.RoomsRentedTurnover;
//			vRow.BedsRentedTurnover = vRow.BedsRentedTurnover + vForecastRow.BedsRentedTurnover;
//		EndDo;
//	EndIf;	
//	
//	vResources = "SalesTurnover, SalesWithoutVATTurnover, RoomRevenueTurnover, RoomRevenueWithoutVATTurnover, RoomsRentedTurnover, BedsRentedTurnover";
//	
//	// Split table to total and complimentary only
//	vQryResultComplArray = vQryResult.Copy().FindRows(New Structure("RoomRateIsComplimentary", True));
//	vQryResult.GroupBy("Period", vResources);
//	vQryResultCompl = vQryResult.CopyColumns();
//	For Each vRow In vQryResultComplArray Do
//		vTabRow = vQryResultCompl.Add();
//		FillPropertyValues(vTabRow, vRow);
//	EndDo;
//	vQryResultCompl.GroupBy("Period", vResources);
//	
//	If ShowPreviousYearData Тогда
//		vQryResultComplArrayLY = vQryResultLY.Copy().FindRows(New Structure("RoomRateIsComplimentary", True));
//		vQryResultLY.GroupBy("Period", vResources);
//		vQryResultComplLY = vQryResultLY.CopyColumns();
//		For Each vRow In vQryResultComplArrayLY Do
//			vTabRow = vQryResultComplLY.Add();
//			FillPropertyValues(vTabRow, vRow);
//		EndDo;
//		vQryResultComplLY.GroupBy("Period", vResources);
//	EndIf;
//	
//	// Put rooms rented
//	GetQryResultTableTotals(vQryResult, vQryResult, vResources, False);
//	vRoomsRented = cmCastToNumber(TotalPerDay.RoomsRentedTurnover);
//	vRoomsRentedPerMonth = cmCastToNumber(TotalPerMonth.RoomsRentedTurnover);
//	vRoomsRentedPerYear = cmCastToNumber(TotalPerYear.RoomsRentedTurnover);
//	If ShowPreviousYearData Тогда
//		GetQryResultTableTotalsLY(vQryResultLY, vQryResultLY, vResources, False);
//		vRoomsRentedLY = cmCastToNumber(TotalPerDayLY.RoomsRentedTurnover);
//		vRoomsRentedPerMonthLY = cmCastToNumber(TotalPerMonthLY.RoomsRentedTurnover);
//		vRoomsRentedPerYearLY = cmCastToNumber(TotalPerYearLY.RoomsRentedTurnover);
//	EndIf;
//	If vInRooms Тогда
//		vArea = vTemplate.GetArea("ПроданоНомеров");
//		vArea.Parameters.mRoomsRented = vRoomsRented;
//		vArea.Parameters.mRoomsRentedPerMonth = vRoomsRentedPerMonth;
//		vArea.Parameters.mRoomsRentedPerYear = vRoomsRentedPerYear;
//		If ShowPreviousYearData Тогда
//			vArea.Parameters.mRoomsRentedLY = vRoomsRentedLY;
//			vArea.Parameters.mRoomsRentedPerMonthLY = vRoomsRentedPerMonthLY;
//			vArea.Parameters.mRoomsRentedPerYearLY = vRoomsRentedPerYearLY;
//		EndIf;
//		pSpreadsheet.Put(vArea);
//	Else
//		vArea = vTemplate.GetArea("ПроданоМест");
//		vBedsRented = cmCastToNumber(TotalPerDay.BedsRentedTurnover);
//		vArea.Parameters.mBedsRented = vBedsRented;
//		vBedsRentedPerMonth = cmCastToNumber(TotalPerMonth.BedsRentedTurnover);
//		vArea.Parameters.mBedsRentedPerMonth = vBedsRentedPerMonth;
//		vBedsRentedPerYear = cmCastToNumber(TotalPerYear.BedsRentedTurnover);
//		vArea.Parameters.mBedsRentedPerYear = vBedsRentedPerYear;
//		If ShowPreviousYearData Тогда
//			vBedsRentedLY = cmCastToNumber(TotalPerDayLY.BedsRentedTurnover);
//			vArea.Parameters.mBedsRentedLY = vBedsRentedLY;
//			vBedsRentedPerMonthLY = cmCastToNumber(TotalPerMonthLY.BedsRentedTurnover);
//			vArea.Parameters.mBedsRentedPerMonthLY = vBedsRentedPerMonthLY;
//			vBedsRentedPerYearLY = cmCastToNumber(TotalPerYearLY.BedsRentedTurnover);
//			vArea.Parameters.mBedsRentedPerYearLY = vBedsRentedPerYearLY;
//		EndIf;
//		pSpreadsheet.Put(vArea);
//	EndIf;
//	
//	// Save total sales sums
//	If vWithVAT Тогда
//		vRoomsIncome = cmCastToNumber(TotalPerDay.RoomRevenueTurnover);
//		vRoomsIncomePerMonth = cmCastToNumber(TotalPerMonth.RoomRevenueTurnover);
//		vRoomsIncomePerYear = cmCastToNumber(TotalPerYear.RoomRevenueTurnover);
//		
//		vTotalIncome = cmCastToNumber(TotalPerDay.SalesTurnover);
//		vTotalIncomePerMonth = cmCastToNumber(TotalPerMonth.SalesTurnover);
//		vTotalIncomePerYear = cmCastToNumber(TotalPerYear.SalesTurnover);
//	Else
//		vRoomsIncome = cmCastToNumber(TotalPerDay.RoomRevenueWithoutVATTurnover);
//		vRoomsIncomePerMonth = cmCastToNumber(TotalPerMonth.RoomRevenueWithoutVATTurnover);
//		vRoomsIncomePerYear = cmCastToNumber(TotalPerYear.RoomRevenueWithoutVATTurnover);
//		
//		vTotalIncome = cmCastToNumber(TotalPerDay.SalesWithoutVATTurnover);
//		vTotalIncomePerMonth = cmCastToNumber(TotalPerMonth.SalesWithoutVATTurnover);
//		vTotalIncomePerYear = cmCastToNumber(TotalPerYear.SalesWithoutVATTurnover);
//	EndIf;
//	
//	vOtherIncome = vTotalIncome - vRoomsIncome;
//	vOtherIncomePerMonth = vTotalIncomePerMonth - vRoomsIncomePerMonth;
//	vOtherIncomePerYear = vTotalIncomePerYear - vRoomsIncomePerYear;
//	
//	If ShowPreviousYearData Тогда
//		If vWithVAT Тогда
//			vRoomsIncomeLY = cmCastToNumber(TotalPerDayLY.RoomRevenueTurnover);
//			vRoomsIncomePerMonthLY = cmCastToNumber(TotalPerMonthLY.RoomRevenueTurnover);
//			vRoomsIncomePerYearLY = cmCastToNumber(TotalPerYearLY.RoomRevenueTurnover);
//			
//			vTotalIncomeLY = cmCastToNumber(TotalPerDayLY.SalesTurnover);
//			vTotalIncomePerMonthLY = cmCastToNumber(TotalPerMonthLY.SalesTurnover);
//			vTotalIncomePerYearLY = cmCastToNumber(TotalPerYearLY.SalesTurnover);
//		Else
//			vRoomsIncomeLY = cmCastToNumber(TotalPerDayLY.RoomRevenueWithoutVATTurnover);
//			vRoomsIncomePerMonthLY = cmCastToNumber(TotalPerMonthLY.RoomRevenueWithoutVATTurnover);
//			vRoomsIncomePerYearLY = cmCastToNumber(TotalPerYearLY.RoomRevenueWithoutVATTurnover);
//			
//			vTotalIncomeLY = cmCastToNumber(TotalPerDayLY.SalesWithoutVATTurnover);
//			vTotalIncomePerMonthLY = cmCastToNumber(TotalPerMonthLY.SalesWithoutVATTurnover);
//			vTotalIncomePerYearLY = cmCastToNumber(TotalPerYearLY.SalesWithoutVATTurnover);
//		EndIf;
//		
//		vOtherIncomeLY = vTotalIncomeLY - vRoomsIncomeLY;
//		vOtherIncomePerMonthLY = vTotalIncomePerMonthLY - vRoomsIncomePerMonthLY;
//		vOtherIncomePerYearLY = vTotalIncomePerYearLY - vRoomsIncomePerYearLY;
//	EndIf;
//	
//	// Put complimentary rooms rented
//	GetQryResultTableTotals(vQryResultCompl, vQryResultCompl, vResources, False);
//	If ShowPreviousYearData Тогда
//		GetQryResultTableTotalsLY(vQryResultComplLY, vQryResultComplLY, vResources, False);
//	EndIf;
//	If vInRooms Тогда
//		vArea = vTemplate.GetArea("ComplimentaryRooms");
//		
//		vComplimentaryRooms = cmCastToNumber(TotalPerDay.RoomsRentedTurnover);
//		vArea.Parameters.mComplimentaryRooms = vComplimentaryRooms;
//		vComplimentaryRoomsPerMonth = cmCastToNumber(TotalPerMonth.RoomsRentedTurnover);
//		vArea.Parameters.mComplimentaryRoomsPerMonth = vComplimentaryRoomsPerMonth;
//		vComplimentaryRoomsPerYear = cmCastToNumber(TotalPerYear.RoomsRentedTurnover);
//		vArea.Parameters.mComplimentaryRoomsPerYear = vComplimentaryRoomsPerYear;
//		
//		If ShowPreviousYearData Тогда
//			vComplimentaryRoomsLY = cmCastToNumber(TotalPerDayLY.RoomsRentedTurnover);
//			vArea.Parameters.mComplimentaryRoomsLY = vComplimentaryRoomsLY;
//			vComplimentaryRoomsPerMonthLY = cmCastToNumber(TotalPerMonthLY.RoomsRentedTurnover);
//			vArea.Parameters.mComplimentaryRoomsPerMonthLY = vComplimentaryRoomsPerMonthLY;
//			vComplimentaryRoomsPerYearLY = cmCastToNumber(TotalPerYearLY.RoomsRentedTurnover);
//			vArea.Parameters.mComplimentaryRoomsPerYearLY = vComplimentaryRoomsPerYearLY;
//		EndIf;
//		
//		If НЕ DoNotShowComplimentaryRoomsRentedPercent Тогда
//			pSpreadsheet.Put(vArea);
//		EndIf;
//	Else
//		vArea = vTemplate.GetArea("ComplimentaryBeds");
//		
//		vComplimentaryBeds = cmCastToNumber(TotalPerDay.BedsRentedTurnover);
//		vArea.Parameters.mComplimentaryBeds = vComplimentaryBeds;
//		vComplimentaryBedsPerMonth = cmCastToNumber(TotalPerMonth.BedsRentedTurnover);
//		vArea.Parameters.mComplimentaryBedsPerMonth = vComplimentaryBedsPerMonth;
//		vComplimentaryBedsPerYear = cmCastToNumber(TotalPerYear.BedsRentedTurnover);
//		vArea.Parameters.mComplimentaryBedsPerYear = vComplimentaryBedsPerYear;
//		
//		If ShowPreviousYearData Тогда
//			vComplimentaryBedsLY = cmCastToNumber(TotalPerDayLY.BedsRentedTurnover);
//			vArea.Parameters.mComplimentaryBedsLY = vComplimentaryBedsLY;
//			vComplimentaryBedsPerMonthLY = cmCastToNumber(TotalPerMonthLY.BedsRentedTurnover);
//			vArea.Parameters.mComplimentaryBedsPerMonthLY = vComplimentaryBedsPerMonthLY;
//			vComplimentaryBedsPerYearLY = cmCastToNumber(TotalPerYearLY.BedsRentedTurnover);
//			vArea.Parameters.mComplimentaryBedsPerYearLY = vComplimentaryBedsPerYearLY;
//		EndIf;
//		
//		If НЕ DoNotShowComplimentaryRoomsRentedPercent Тогда
//			pSpreadsheet.Put(vArea);
//		EndIf;
//	EndIf;
//	
//	// Put occupation percent header
//	vArea = vTemplate.GetArea("OccupationPercentHeader");
//	pSpreadsheet.Put(vArea);
//	
//	If vInRooms Тогда
//		vArea = vTemplate.GetArea("OccupationPercentRooms");
//		vArea.Parameters.mOccupationRooms = Round(?((vRoomsForSale + vSpecRoomsBlocked) <> 0, 100*(vRoomsRented + vSpecRoomsBlocked)/(vRoomsForSale + vSpecRoomsBlocked), 0), 2);
//		vArea.Parameters.mOccupationRoomsPerMonth = Round(?((vRoomsForSalePerMonth + vSpecRoomsBlockedPerMonth) <> 0, 100*(vRoomsRentedPerMonth + vSpecRoomsBlockedPerMonth)/(vRoomsForSalePerMonth + vSpecRoomsBlockedPerMonth), 0), 2);
//		vArea.Parameters.mOccupationRoomsPerYear = Round(?((vRoomsForSalePerYear + vSpecRoomsBlockedPerYear) <> 0, 100*(vRoomsRentedPerYear + vSpecRoomsBlockedPerYear)/(vRoomsForSalePerYear + vSpecRoomsBlockedPerYear), 0), 2);
//		If ShowPreviousYearData Тогда
//			vArea.Parameters.mOccupationRoomsLY = Round(?((vRoomsForSaleLY + vSpecRoomsBlockedLY) <> 0, 100*(vRoomsRentedLY + vSpecRoomsBlockedLY)/(vRoomsForSaleLY + vSpecRoomsBlockedLY), 0), 2);
//			vArea.Parameters.mOccupationRoomsPerMonthLY = Round(?((vRoomsForSalePerMonthLY + vSpecRoomsBlockedPerMonthLY) <> 0, 100*(vRoomsRentedPerMonthLY + vSpecRoomsBlockedPerMonthLY)/(vRoomsForSalePerMonthLY + vSpecRoomsBlockedPerMonthLY), 0), 2);
//			vArea.Parameters.mOccupationRoomsPerYearLY = Round(?((vRoomsForSalePerYearLY + vSpecRoomsBlockedPerYearLY) <> 0, 100*(vRoomsRentedPerYearLY + vSpecRoomsBlockedPerYearLY)/(vRoomsForSalePerYearLY + vSpecRoomsBlockedPerYearLY), 0), 2);
//		EndIf;
//		pSpreadsheet.Put(vArea);
//		
//		If НЕ DoNotShowComplimentaryRoomsRentedPercent Тогда
//			vArea = vTemplate.GetArea("OccupationComplPercentRooms");
//			vArea.Parameters.mOccupationComplRooms = Round(?((vRoomsForSale + vSpecRoomsBlocked) <> 0, 100*(vRoomsRented + vSpecRoomsBlocked - vComplimentaryRooms)/(vRoomsForSale + vSpecRoomsBlocked), 0), 2);
//			vArea.Parameters.mOccupationComplRoomsPerMonth = Round(?((vRoomsForSalePerMonth + vSpecRoomsBlockedPerMonth) <> 0, 100*(vRoomsRentedPerMonth + vSpecRoomsBlockedPerMonth - vComplimentaryRoomsPerMonth)/(vRoomsForSalePerMonth + vSpecRoomsBlockedPerMonth), 0), 2);
//			vArea.Parameters.mOccupationComplRoomsPerYear = Round(?((vRoomsForSalePerYear + vSpecRoomsBlockedPerYear) <> 0, 100*(vRoomsRentedPerYear + vSpecRoomsBlockedPerYear - vComplimentaryRoomsPerYear)/(vRoomsForSalePerYear + vSpecRoomsBlockedPerYear), 0), 2);
//			If ShowPreviousYearData Тогда
//				vArea.Parameters.mOccupationComplRoomsLY = Round(?((vRoomsForSaleLY + vSpecRoomsBlockedLY) <> 0, 100*(vRoomsRentedLY + vSpecRoomsBlockedLY - vComplimentaryRoomsLY)/(vRoomsForSaleLY + vSpecRoomsBlockedLY), 0), 2);
//				vArea.Parameters.mOccupationComplRoomsPerMonthLY = Round(?((vRoomsForSalePerMonthLY + vSpecRoomsBlockedPerMonthLY) <> 0, 100*(vRoomsRentedPerMonthLY + vSpecRoomsBlockedPerMonthLY - vComplimentaryRoomsPerMonthLY)/(vRoomsForSalePerMonthLY + vSpecRoomsBlockedPerMonthLY), 0), 2);
//				vArea.Parameters.mOccupationComplRoomsPerYearLY = Round(?((vRoomsForSalePerYearLY + vSpecRoomsBlockedPerYearLY) <> 0, 100*(vRoomsRentedPerYearLY + vSpecRoomsBlockedPerYearLY - vComplimentaryRoomsPerYearLY)/(vRoomsForSalePerYearLY + vSpecRoomsBlockedPerYearLY), 0), 2);
//			EndIf;
//			pSpreadsheet.Put(vArea);
//		EndIf;
//		
//		If НЕ DoNotShowTotalRoomsRentedPercent Тогда
//			vArea = vTemplate.GetArea("OccupationPercentRoomsWithoutBlocks");
//			vArea.Parameters.mOccupationRoomsNoBlocks = Round(?(vTotalRooms <> 0, 100*(vRoomsRented + vSpecRoomsBlocked)/vTotalRooms, 0), 2);
//			vArea.Parameters.mOccupationRoomsNoBlocksPerMonth = Round(?(vTotalRoomsPerMonth <> 0, 100*(vRoomsRentedPerMonth + vSpecRoomsBlockedPerMonth)/vTotalRoomsPerMonth, 0), 2);
//			vArea.Parameters.mOccupationRoomsNoBlocksPerYear = Round(?(vTotalRoomsPerYear <> 0, 100*(vRoomsRentedPerYear + vSpecRoomsBlockedPerYear)/vTotalRoomsPerYear, 0), 2);
//			If ShowPreviousYearData Тогда
//				vArea.Parameters.mOccupationRoomsNoBlocksLY = Round(?(vTotalRoomsLY <> 0, 100*(vRoomsRentedLY + vSpecRoomsBlockedLY)/vTotalRoomsLY, 0), 2);
//				vArea.Parameters.mOccupationRoomsNoBlocksPerMonthLY = Round(?(vTotalRoomsPerMonthLY <> 0, 100*(vRoomsRentedPerMonthLY + vSpecRoomsBlockedPerMonthLY)/vTotalRoomsPerMonthLY, 0), 2);
//				vArea.Parameters.mOccupationRoomsNoBlocksPerYearLY = Round(?(vTotalRoomsPerYearLY <> 0, 100*(vRoomsRentedPerYearLY + vSpecRoomsBlockedPerYearLY)/vTotalRoomsPerYearLY, 0), 2);
//			EndIf;
//			pSpreadsheet.Put(vArea);
//		EndIf;
//		
//		vArea = vTemplate.GetArea("AverageRoomPrice");
//		vArea.Parameters.mAvgRoomPrice = Round(?(vRoomsRented <> 0, vRoomsIncome/vRoomsRented, 0), 2);
//		vArea.Parameters.mAvgRoomPricePerMonth = Round(?(vRoomsRentedPerMonth <> 0, vRoomsIncomePerMonth/vRoomsRentedPerMonth, 0), 2);
//		vArea.Parameters.mAvgRoomPricePerYear = Round(?(vRoomsRentedPerYear <> 0, vRoomsIncomePerYear/vRoomsRentedPerYear, 0), 2);
//		If ShowPreviousYearData Тогда
//			vArea.Parameters.mAvgRoomPriceLY = Round(?(vRoomsRentedLY <> 0, vRoomsIncomeLY/vRoomsRentedLY, 0), 2);
//			vArea.Parameters.mAvgRoomPricePerMonthLY = Round(?(vRoomsRentedPerMonthLY <> 0, vRoomsIncomePerMonthLY/vRoomsRentedPerMonthLY, 0), 2);
//			vArea.Parameters.mAvgRoomPricePerYearLY = Round(?(vRoomsRentedPerYearLY <> 0, vRoomsIncomePerYearLY/vRoomsRentedPerYearLY, 0), 2);
//		EndIf;
//		pSpreadsheet.Put(vArea);
//		
//		vArea = vTemplate.GetArea("AverageRoomPriceInclAddSrv");
//		vArea.Parameters.mAvgRoomPriceInclAddSrv = Round(?(vRoomsRented <> 0, vTotalIncome/vRoomsRented, 0), 2);
//		vArea.Parameters.mAvgRoomPriceInclAddSrvPerMonth = Round(?(vRoomsRentedPerMonth <> 0, vTotalIncomePerMonth/vRoomsRentedPerMonth, 0), 2);
//		vArea.Parameters.mAvgRoomPriceInclAddSrvPerYear = Round(?(vRoomsRentedPerYear <> 0, vTotalIncomePerYear/vRoomsRentedPerYear, 0), 2);
//		If ShowPreviousYearData Тогда
//			vArea.Parameters.mAvgRoomPriceInclAddSrvLY = Round(?(vRoomsRentedLY <> 0, vTotalIncomeLY/vRoomsRentedLY, 0), 2);
//			vArea.Parameters.mAvgRoomPriceInclAddSrvPerMonthLY = Round(?(vRoomsRentedPerMonthLY <> 0, vTotalIncomePerMonthLY/vRoomsRentedPerMonthLY, 0), 2);
//			vArea.Parameters.mAvgRoomPriceInclAddSrvPerYearLY = Round(?(vRoomsRentedPerYearLY <> 0, vTotalIncomePerYearLY/vRoomsRentedPerYearLY, 0), 2);
//		EndIf;
//		pSpreadsheet.Put(vArea);
//		
//		vArea = vTemplate.GetArea("AverageRoomIncome");
//		vArea.Parameters.mAvgRoomIncome = Round(?((vRoomsForSale + vSpecRoomsBlocked) <> 0, vRoomsIncome/(vRoomsForSale + vSpecRoomsBlocked), 0), 2);
//		vArea.Parameters.mAvgRoomIncomePerMonth = Round(?((vRoomsForSalePerMonth + vSpecRoomsBlockedPerMonth) <> 0, vRoomsIncomePerMonth/(vRoomsForSalePerMonth + vSpecRoomsBlockedPerMonth), 0), 2);
//		vArea.Parameters.mAvgRoomIncomePerYear = Round(?((vRoomsForSalePerYear + vSpecRoomsBlockedPerYear) <> 0, vRoomsIncomePerYear/(vRoomsForSalePerYear + vSpecRoomsBlockedPerYear), 0), 2);
//		If ShowPreviousYearData Тогда
//			vArea.Parameters.mAvgRoomIncomeLY = Round(?((vRoomsForSaleLY + vSpecRoomsBlockedLY) <> 0, vRoomsIncomeLY/(vRoomsForSaleLY + vSpecRoomsBlockedLY), 0), 2);
//			vArea.Parameters.mAvgRoomIncomePerMonthLY = Round(?((vRoomsForSalePerMonthLY + vSpecRoomsBlockedPerMonthLY) <> 0, vRoomsIncomePerMonthLY/(vRoomsForSalePerMonthLY + vSpecRoomsBlockedPerMonthLY), 0), 2);
//			vArea.Parameters.mAvgRoomIncomePerYearLY = Round(?((vRoomsForSalePerYearLY + vSpecRoomsBlockedPerYearLY) <> 0, vRoomsIncomePerYearLY/(vRoomsForSalePerYearLY + vSpecRoomsBlockedPerYearLY), 0), 2);
//		EndIf;
//		pSpreadsheet.Put(vArea);
//	Else
//		vArea = vTemplate.GetArea("OccupationPercentBeds");
//		vArea.Parameters.mOccupationBeds = Round(?((vBedsForSale + vSpecBedsBlocked) <> 0, 100*(vBedsRented + vSpecBedsBlocked)/(vBedsForSale + vSpecBedsBlocked), 0), 2);
//		vArea.Parameters.mOccupationBedsPerMonth = Round(?((vBedsForSalePerMonth + vSpecBedsBlockedPerMonth) <> 0, 100*(vBedsRentedPerMonth + vSpecBedsBlockedPerMonth)/(vBedsForSalePerMonth + vSpecBedsBlockedPerMonth), 0), 2);
//		vArea.Parameters.mOccupationBedsPerYear = Round(?((vBedsForSalePerYear + vSpecBedsBlockedPerYear) <> 0, 100*(vBedsRentedPerYear + vSpecBedsBlockedPerYear)/(vBedsForSalePerYear + vSpecBedsBlockedPerYear), 0), 2);
//		If ShowPreviousYearData Тогда
//			vArea.Parameters.mOccupationBedsLY = Round(?((vBedsForSaleLY + vSpecBedsBlockedLY) <> 0, 100*(vBedsRentedLY + vSpecBedsBlockedLY)/(vBedsForSaleLY + vSpecBedsBlockedLY), 0), 2);
//			vArea.Parameters.mOccupationBedsPerMonthLY = Round(?((vBedsForSalePerMonthLY + vSpecBedsBlockedPerMonthLY) <> 0, 100*(vBedsRentedPerMonthLY + vSpecBedsBlockedPerMonthLY)/(vBedsForSalePerMonthLY + vSpecBedsBlockedPerMonthLY), 0), 2);
//			vArea.Parameters.mOccupationBedsPerYearLY = Round(?((vBedsForSalePerYearLY + vSpecBedsBlockedPerYearLY) <> 0, 100*(vBedsRentedPerYearLY + vSpecBedsBlockedPerYearLY)/(vBedsForSalePerYearLY + vSpecBedsBlockedPerYearLY), 0), 2);
//		EndIf;
//		pSpreadsheet.Put(vArea);
//		
//		If НЕ DoNotShowComplimentaryRoomsRentedPercent Тогда
//			vArea = vTemplate.GetArea("OccupationComplPercentBeds");
//			vArea.Parameters.mOccupationComplBeds = Round(?((vBedsForSale + vSpecBedsBlocked) <> 0, 100*(vBedsRented + vSpecBedsBlocked - vComplimentaryBeds)/(vBedsForSale + vSpecBedsBlocked), 0), 2);
//			vArea.Parameters.mOccupationComplBedsPerMonth = Round(?((vBedsForSalePerMonth + vSpecBedsBlockedPerMonth) <> 0, 100*(vBedsRentedPerMonth + vSpecBedsBlockedPerMonth - vComplimentaryBedsPerMonth)/(vBedsForSalePerMonth + vSpecBedsBlockedPerMonth), 0), 2);
//			vArea.Parameters.mOccupationComplBedsPerYear = Round(?((vBedsForSalePerYear + vSpecBedsBlockedPerYear) <> 0, 100*(vBedsRentedPerYear + vSpecBedsBlockedPerYear - vComplimentaryBedsPerYear)/(vBedsForSalePerYear + vSpecBedsBlockedPerYear), 0), 2);
//			If ShowPreviousYearData Тогда
//				vArea.Parameters.mOccupationComplBedsLY = Round(?((vBedsForSaleLY + vSpecBedsBlockedLY) <> 0, 100*(vBedsRentedLY + vSpecBedsBlockedLY - vComplimentaryBedsLY)/(vBedsForSaleLY + vSpecBedsBlockedLY), 0), 2);
//				vArea.Parameters.mOccupationComplBedsPerMonthLY = Round(?((vBedsForSalePerMonthLY + vSpecBedsBlockedPerMonthLY) <> 0, 100*(vBedsRentedPerMonthLY + vSpecBedsBlockedPerMonthLY - vComplimentaryBedsPerMonthLY)/(vBedsForSalePerMonthLY + vSpecBedsBlockedPerMonthLY), 0), 2);
//				vArea.Parameters.mOccupationComplBedsPerYearLY = Round(?((vBedsForSalePerYearLY + vSpecBedsBlockedPerYearLY) <> 0, 100*(vBedsRentedPerYearLY + vSpecBedsBlockedPerYearLY - vComplimentaryBedsPerYearLY)/(vBedsForSalePerYearLY + vSpecBedsBlockedPerYearLY), 0), 2);
//			EndIf;
//			pSpreadsheet.Put(vArea);
//		EndIf;
//		
//		If НЕ DoNotShowTotalRoomsRentedPercent Тогда
//			vArea = vTemplate.GetArea("OccupationPercentBedsWithoutBlocks");
//			vArea.Parameters.mOccupationBedsNoBlocks = Round(?(vTotalBeds <> 0, 100*(vBedsRented + vSpecBedsBlocked)/vTotalBeds, 0), 2);
//			vArea.Parameters.mOccupationBedsNoBlocksPerMonth = Round(?(vTotalBedsPerMonth <> 0, 100*(vBedsRentedPerMonth + vSpecBedsBlockedPerMonth)/vTotalBedsPerMonth, 0), 2);
//			vArea.Parameters.mOccupationBedsNoBlocksPerYear = Round(?(vTotalBedsPerYear <> 0, 100*(vBedsRentedPerYear + vSpecRoomsBlockedPerYear)/vTotalBedsPerYear, 0), 2);
//			If ShowPreviousYearData Тогда
//				vArea.Parameters.mOccupationBedsNoBlocksLY = Round(?(vTotalBedsLY <> 0, 100*(vBedsRentedLY + vSpecBedsBlockedLY)/vTotalBedsLY, 0), 2);
//				vArea.Parameters.mOccupationBedsNoBlocksPerMonthLY = Round(?(vTotalBedsPerMonthLY <> 0, 100*(vBedsRentedPerMonthLY + vSpecBedsBlockedPerMonthLY)/vTotalBedsPerMonthLY, 0), 2);
//				vArea.Parameters.mOccupationBedsNoBlocksPerYearLY = Round(?(vTotalBedsPerYearLY <> 0, 100*(vBedsRentedPerYearLY + vSpecRoomsBlockedPerYearLY)/vTotalBedsPerYearLY, 0), 2);
//			EndIf;
//			pSpreadsheet.Put(vArea);
//		EndIf;
//		
//		vArea = vTemplate.GetArea("AverageBedPrice");
//		vArea.Parameters.mAvgBedPrice = Round(?(vBedsRented <> 0, vRoomsIncome/vBedsRented, 0), 2);
//		vArea.Parameters.mAvgBedPricePerMonth = Round(?(vBedsRentedPerMonth <> 0, vRoomsIncomePerMonth/vBedsRentedPerMonth, 0), 2);
//		vArea.Parameters.mAvgBedPricePerYear = Round(?(vBedsRentedPerYear <> 0, vRoomsIncomePerYear/vBedsRentedPerYear, 0), 2);
//		If ShowPreviousYearData Тогда
//			vArea.Parameters.mAvgBedPriceLY = Round(?(vBedsRentedLY <> 0, vRoomsIncomeLY/vBedsRentedLY, 0), 2);
//			vArea.Parameters.mAvgBedPricePerMonthLY = Round(?(vBedsRentedPerMonthLY <> 0, vRoomsIncomePerMonthLY/vBedsRentedPerMonthLY, 0), 2);
//			vArea.Parameters.mAvgBedPricePerYearLY = Round(?(vBedsRentedPerYearLY <> 0, vRoomsIncomePerYearLY/vBedsRentedPerYearLY, 0), 2);
//		EndIf;
//		pSpreadsheet.Put(vArea);
//		
//		vArea = vTemplate.GetArea("AverageBedPriceInclAddSrv");
//		vArea.Parameters.mAvgBedPriceInclAddSrv = Round(?(vBedsRented <> 0, vTotalIncome/vBedsRented, 0), 2);
//		vArea.Parameters.mAvgBedPriceInclAddSrvPerMonth = Round(?(vBedsRentedPerMonth <> 0, vTotalIncomePerMonth/vBedsRentedPerMonth, 0), 2);
//		vArea.Parameters.mAvgBedPriceInclAddSrvPerYear = Round(?(vBedsRentedPerYear <> 0, vTotalIncomePerYear/vBedsRentedPerYear, 0), 2);
//		If ShowPreviousYearData Тогда
//			vArea.Parameters.mAvgBedPriceInclAddSrvLY = Round(?(vBedsRentedLY <> 0, vTotalIncomeLY/vBedsRentedLY, 0), 2);
//			vArea.Parameters.mAvgBedPriceInclAddSrvPerMonthLY = Round(?(vBedsRentedPerMonthLY <> 0, vTotalIncomePerMonthLY/vBedsRentedPerMonthLY, 0), 2);
//			vArea.Parameters.mAvgBedPriceInclAddSrvPerYearLY = Round(?(vBedsRentedPerYearLY <> 0, vTotalIncomePerYearLY/vBedsRentedPerYearLY, 0), 2);
//		EndIf;
//		pSpreadsheet.Put(vArea);
//		
//		vArea = vTemplate.GetArea("AverageBedIncome");
//		vArea.Parameters.mAvgBedIncome = Round(?((vBedsForSale + vSpecBedsBlocked) <> 0, vRoomsIncome/(vBedsForSale + vSpecBedsBlocked), 0), 2);
//		vArea.Parameters.mAvgBedIncomePerMonth = Round(?((vBedsForSalePerMonth + vSpecBedsBlockedPerMonth) <> 0, vRoomsIncomePerMonth/(vBedsForSalePerMonth + vSpecBedsBlockedPerMonth), 0), 2);
//		vArea.Parameters.mAvgBedIncomePerYear = Round(?((vBedsForSalePerYear + vSpecBedsBlockedPerYear) <> 0, vRoomsIncomePerYear/(vBedsForSalePerYear + vSpecBedsBlockedPerYear), 0), 2);
//		If ShowPreviousYearData Тогда
//			vArea.Parameters.mAvgBedIncomeLY = Round(?((vBedsForSaleLY + vSpecBedsBlockedLY) <> 0, vRoomsIncomeLY/(vBedsForSaleLY + vSpecBedsBlockedLY), 0), 2);
//			vArea.Parameters.mAvgBedIncomePerMonthLY = Round(?((vBedsForSalePerMonthLY + vSpecBedsBlockedPerMonthLY) <> 0, vRoomsIncomePerMonthLY/(vBedsForSalePerMonthLY + vSpecBedsBlockedPerMonthLY), 0), 2);
//			vArea.Parameters.mAvgBedIncomePerYearLY = Round(?((vBedsForSalePerYearLY + vSpecBedsBlockedPerYearLY) <> 0, vRoomsIncomePerYearLY/(vBedsForSalePerYearLY + vSpecBedsBlockedPerYearLY), 0), 2);
//		EndIf;
//		pSpreadsheet.Put(vArea);
//	EndIf;
//	
//	// 2. Guests summary indexes
//	
//	// Put section header
//	vArea = vTemplate.GetArea("GuestsSummaryHeader");
//	pSpreadsheet.Put(vArea);
//	
//	vArea = vTemplate.GetArea("GuestsHeader");
//	pSpreadsheet.Put(vArea);
//	
//	// Run query to get number of guest days
//	vQry = New Query();
//	vQry.Text = 
//	"SELECT
//	|	ОборотыПродажиНомеров.Period AS Period,
//	|	ОборотыПродажиНомеров.ТипКлиента AS ТипКлиента,
//	|	SUM(ОборотыПродажиНомеров.GuestDaysTurnover) AS GuestDaysTurnover,
//	|	SUM(ОборотыПродажиНомеров.GuestsCheckedInTurnover) AS GuestsCheckedInTurnover
//	|FROM
//	|	AccumulationRegister.Продажи.Turnovers(&qPeriodFrom, &qPeriodTo, Day, Гостиница IN HIERARCHY (&qHotel)) AS ОборотыПродажиНомеров
//	|GROUP BY
//	|	ОборотыПродажиНомеров.Period,
//	|	ОборотыПродажиНомеров.ТипКлиента
//	|ORDER BY
//	|	Period,
//	|	ТипКлиента";
//	vQry.SetParameter("qPeriodFrom", pmBegOfYear(PeriodTo));
//	vQry.SetParameter("qPeriodTo", EndOfDay(PeriodTo));
//	vQry.SetParameter("qHotel", Гостиница);
//	vQryResult = vQry.Execute().Unload();
//	
//	If ShowPreviousYearData Тогда
//		// Run query to get number of guest days
//		vQryLY = New Query();
//		vQryLY.Text = 
//		"SELECT
//		|	ОборотыПродажиНомеров.Period AS Period,
//		|	ОборотыПродажиНомеров.ТипКлиента AS ТипКлиента,
//		|	SUM(ОборотыПродажиНомеров.GuestDaysTurnover) AS GuestDaysTurnover,
//		|	SUM(ОборотыПродажиНомеров.GuestsCheckedInTurnover) AS GuestsCheckedInTurnover
//		|FROM
//		|	AccumulationRegister.Продажи.Turnovers(&qPeriodFrom, &qPeriodTo, Day, Гостиница IN HIERARCHY (&qHotel)) AS ОборотыПродажиНомеров
//		|GROUP BY
//		|	ОборотыПродажиНомеров.Period,
//		|	ОборотыПродажиНомеров.ТипКлиента
//		|ORDER BY
//		|	Period,
//		|	ТипКлиента";
//		vQryLY.SetParameter("qPeriodFrom", pmBegOfYear(PeriodToLY));
//		vQryLY.SetParameter("qPeriodTo", EndOfDay(PeriodToLY));
//		vQryLY.SetParameter("qHotel", Гостиница);
//		vQryResultLY = vQryLY.Execute().Unload();
//	EndIf;
//	
//	// Add forecast guests if period is set in the future
//	If BegOfDay(PeriodTo) >= BegOfDay(CurrentDate()) Тогда
//		vQry = New Query();
//		vQry.Text = 
//		"SELECT
//		|	RoomSalesForecastTurnovers.Period AS Period,
//		|	RoomSalesForecastTurnovers.ТипКлиента AS ТипКлиента,
//		|	SUM(RoomSalesForecastTurnovers.GuestDaysTurnover) AS GuestDaysTurnover,
//		|	SUM(RoomSalesForecastTurnovers.GuestsCheckedInTurnover) AS GuestsCheckedInTurnover
//		|FROM
//		|	AccumulationRegister.ПрогнозПродаж.Turnovers(&qPeriodFrom, &qPeriodTo, Day, Гостиница IN HIERARCHY (&qHotel)) AS RoomSalesForecastTurnovers
//		|GROUP BY
//		|	RoomSalesForecastTurnovers.Period,
//		|	RoomSalesForecastTurnovers.ТипКлиента
//		|ORDER BY
//		|	Period,
//		|	ТипКлиента";
//		vQry.SetParameter("qPeriodFrom", BegOfDay(CurrentDate()));
//		vQry.SetParameter("qPeriodTo", EndOfDay(PeriodTo));
//		vQry.SetParameter("qHotel", Гостиница);
//		vForecastQryResult = vQry.Execute().Unload();
//		
//		// Merge forecast guests with real ones
//		For Each vForecastRow In vForecastQryResult Do
//			vFound = False;
//			For Each vRow In vQryResult Do
//				If vRow.Period = vForecastRow.Period And
//				   vRow.ClientType = vForecastRow.ClientType Тогда
//					vFound = True;
//				    Break;
//				EndIf;
//			EndDo;
//			If НЕ vFound Тогда
//				vRow = vQryResult.Add();
//				vRow.Period = vForecastRow.Period;
//				vRow.ТипКлиента = vForecastRow.ClientType;
//				vRow.GuestDaysTurnover = 0;
//				vRow.GuestsCheckedInTurnover = 0;
//			EndIf;
//			vRow.GuestDaysTurnover = vRow.GuestDaysTurnover + vForecastRow.GuestDaysTurnover;
//			vRow.GuestsCheckedInTurnover = vRow.GuestsCheckedInTurnover + vForecastRow.GuestsCheckedInTurnover;
//		EndDo;
//	EndIf;
//	
//	// Get list of client types
//	vClientTypes = vQryResult.Copy();
//	vClientTypes.GroupBy("ТипКлиента", );
//	
//	// Put client types
//	For Each vRow In vClientTypes Do
//		vClientType = vRow.ClientType;
//		
//		// Get records for the current client type only
//		vQrySubresult = vQryResult.FindRows(New Structure("ТипКлиента", vClientType));
//		GetQryResultTableTotals(vQrySubresult, vQryResult, "GuestDaysTurnover", False);
//		If ShowPreviousYearData Тогда
//			vQrySubresultLY = vQryResultLY.FindRows(New Structure("ТипКлиента", vClientType));
//			GetQryResultTableTotalsLY(vQrySubresultLY, vQryResultLY, "GuestDaysTurnover", False);
//		EndIf;
//		
//		vArea = vTemplate.GetArea("GuestsByClientType");
//		vArea.Parameters.mClientType = vClientType;
//		vArea.Parameters.mGuests = cmCastToNumber(TotalPerDay.GuestDaysTurnover);
//		vArea.Parameters.mGuestsPerMonth = cmCastToNumber(TotalPerMonth.GuestDaysTurnover);
//		vArea.Parameters.mGuestsPerYear = cmCastToNumber(TotalPerYear.GuestDaysTurnover);
//		If ShowPreviousYearData Тогда
//			vArea.Parameters.mGuestsLY = cmCastToNumber(TotalPerDayLY.GuestDaysTurnover);
//			vArea.Parameters.mGuestsPerMonthLY = cmCastToNumber(TotalPerMonthLY.GuestDaysTurnover);
//			vArea.Parameters.mGuestsPerYearLY = cmCastToNumber(TotalPerYearLY.GuestDaysTurnover);
//		EndIf;
//		pSpreadsheet.Put(vArea);
//	EndDo;
//	
//	vClientTypesTotals = vQryResult.Copy();
//	vClientTypesTotals.GroupBy("Period", "GuestDaysTurnover, GuestsCheckedInTurnover");
//	GetQryResultTableTotals(vClientTypesTotals, vClientTypesTotals, "GuestDaysTurnover, GuestsCheckedInTurnover", False);
//	If ShowPreviousYearData Тогда
//		vClientTypesTotalsLY = vQryResultLY.Copy();
//		vClientTypesTotalsLY.GroupBy("Period", "GuestDaysTurnover, GuestsCheckedInTurnover");
//		GetQryResultTableTotalsLY(vClientTypesTotalsLY, vClientTypesTotalsLY, "GuestDaysTurnover, GuestsCheckedInTurnover", False);
//	EndIf;
//	
//	vArea = vTemplate.GetArea("GuestsFooter");
//	vGuests = cmCastToNumber(TotalPerDay.GuestDaysTurnover);
//	vArea.Parameters.mGuests = vGuests;
//	vGuestsPerMonth = cmCastToNumber(TotalPerMonth.GuestDaysTurnover);
//	vArea.Parameters.mGuestsPerMonth = vGuestsPerMonth;
//	vGuestsPerYear = cmCastToNumber(TotalPerYear.GuestDaysTurnover);
//	vArea.Parameters.mGuestsPerYear = vGuestsPerYear;
//	If ShowPreviousYearData Тогда
//		vGuestsLY = cmCastToNumber(TotalPerDayLY.GuestDaysTurnover);
//		vArea.Parameters.mGuestsLY = vGuestsLY;
//		vGuestsPerMonthLY = cmCastToNumber(TotalPerMonthLY.GuestDaysTurnover);
//		vArea.Parameters.mGuestsPerMonthLY = vGuestsPerMonthLY;
//		vGuestsPerYearLY = cmCastToNumber(TotalPerYearLY.GuestDaysTurnover);
//		vArea.Parameters.mGuestsPerYearLY = vGuestsPerYearLY;
//	EndIf;
//	If vClientTypes.Count() > 1 Тогда
//		pSpreadsheet.Put(vArea);
//	EndIf;
//
//	// Initialize number of checked in guests
//	vCheckedInGuests = cmCastToNumber(TotalPerDay.GuestsCheckedInTurnover);
//	vCheckedInGuestsPerMonth = cmCastToNumber(TotalPerMonth.GuestsCheckedInTurnover);
//	vCheckedInGuestsPerYear = cmCastToNumber(TotalPerYear.GuestsCheckedInTurnover);
//	If ShowPreviousYearData Тогда
//		vCheckedInGuestsLY = cmCastToNumber(TotalPerDayLY.GuestsCheckedInTurnover);
//		vCheckedInGuestsPerMonthLY = cmCastToNumber(TotalPerMonthLY.GuestsCheckedInTurnover);
//		vCheckedInGuestsPerYearLY = cmCastToNumber(TotalPerYearLY.GuestsCheckedInTurnover);
//	EndIf;
//	
//	// Put guests statistics
//	vArea = vTemplate.GetArea("AverageNumberOfGuestsPerRoom");
//	vArea.Parameters.mAvgNumberOfGuests = Round(?(vRoomsRented <> 0, vGuests/vRoomsRented, 0), 2);
//	vArea.Parameters.mAvgNumberOfGuestsPerMonth = Round(?(vRoomsRentedPerMonth <> 0, vGuestsPerMonth/vRoomsRentedPerMonth, 0), 2);
//	vArea.Parameters.mAvgNumberOfGuestsPerYear = Round(?(vRoomsRentedPerYear <> 0, vGuestsPerYear/vRoomsRentedPerYear, 0), 2);
//	If ShowPreviousYearData Тогда
//		vArea.Parameters.mAvgNumberOfGuestsLY = Round(?(vRoomsRentedLY <> 0, vGuestsLY/vRoomsRentedLY, 0), 2);
//		vArea.Parameters.mAvgNumberOfGuestsPerMonthLY = Round(?(vRoomsRentedPerMonthLY <> 0, vGuestsPerMonthLY/vRoomsRentedPerMonthLY, 0), 2);
//		vArea.Parameters.mAvgNumberOfGuestsPerYearLY = Round(?(vRoomsRentedPerYearLY <> 0, vGuestsPerYearLY/vRoomsRentedPerYearLY, 0), 2);
//	EndIf;
//	pSpreadsheet.Put(vArea);
//	
//	vArea = vTemplate.GetArea("AverageGuestLengthOfStay");
//	vArea.Parameters.mAvgGuestLengthOfStay = Round(?(vCheckedInGuests <> 0, vGuests/vCheckedInGuests, 0), 2);
//	vArea.Parameters.mAvgGuestLengthOfStayPerMonth = Round(?(vCheckedInGuestsPerMonth <> 0, vGuestsPerMonth/vCheckedInGuestsPerMonth, 0), 2);
//	vArea.Parameters.mAvgGuestLengthOfStayPerYear = Round(?(vCheckedInGuestsPerYear <> 0, vGuestsPerYear/vCheckedInGuestsPerYear, 0), 2);
//	If ShowPreviousYearData Тогда
//		vArea.Parameters.mAvgGuestLengthOfStayLY = Round(?(vCheckedInGuestsLY <> 0, vGuestsLY/vCheckedInGuestsLY, 0), 2);
//		vArea.Parameters.mAvgGuestLengthOfStayPerMonthLY = Round(?(vCheckedInGuestsPerMonthLY <> 0, vGuestsPerMonthLY/vCheckedInGuestsPerMonthLY, 0), 2);
//		vArea.Parameters.mAvgGuestLengthOfStayPerYearLY = Round(?(vCheckedInGuestsPerYearLY <> 0, vGuestsPerYearLY/vCheckedInGuestsPerYearLY, 0), 2);
//	EndIf;
//	pSpreadsheet.Put(vArea);
//	
//	vArea = vTemplate.GetArea("AverageGuestPrice");
//	vArea.Parameters.mAvgGuestPrice = Round(?(vGuests <> 0, vRoomsIncome/vGuests, 0), 2);
//	vArea.Parameters.mAvgGuestPricePerMonth = Round(?(vGuestsPerMonth <> 0, vRoomsIncomePerMonth/vGuestsPerMonth, 0), 2);
//	vArea.Parameters.mAvgGuestPricePerYear = Round(?(vGuestsPerYear <> 0, vRoomsIncomePerYear/vGuestsPerYear, 0), 2);
//	If ShowPreviousYearData Тогда
//		vArea.Parameters.mAvgGuestPriceLY = Round(?(vGuestsLY <> 0, vRoomsIncomeLY/vGuestsLY, 0), 2);
//		vArea.Parameters.mAvgGuestPricePerMonthLY = Round(?(vGuestsPerMonthLY <> 0, vRoomsIncomePerMonthLY/vGuestsPerMonthLY, 0), 2);
//		vArea.Parameters.mAvgGuestPricePerYearLY = Round(?(vGuestsPerYearLY <> 0, vRoomsIncomePerYearLY/vGuestsPerYearLY, 0), 2);
//	EndIf;
//	pSpreadsheet.Put(vArea);
//	
//	vArea = vTemplate.GetArea("AverageGuestIncome");
//	vArea.Parameters.mAvgGuestIncome = Round(?(vGuests <> 0, vTotalIncome/vGuests, 0), 2);
//	vArea.Parameters.mAvgGuestIncomePerMonth = Round(?(vGuestsPerMonth <> 0, vTotalIncomePerMonth/vGuestsPerMonth, 0), 2);
//	vArea.Parameters.mAvgGuestIncomePerYear = Round(?(vGuestsPerYear <> 0, vTotalIncomePerYear/vGuestsPerYear, 0), 2);
//	If ShowPreviousYearData Тогда
//		vArea.Parameters.mAvgGuestIncomeLY = Round(?(vGuestsLY <> 0, vTotalIncomeLY/vGuestsLY, 0), 2);
//		vArea.Parameters.mAvgGuestIncomePerMonthLY = Round(?(vGuestsPerMonthLY <> 0, vTotalIncomePerMonthLY/vGuestsPerMonthLY, 0), 2);
//		vArea.Parameters.mAvgGuestIncomePerYearLY = Round(?(vGuestsPerYearLY <> 0, vTotalIncomePerYearLY/vGuestsPerYearLY, 0), 2);
//	EndIf;
//	pSpreadsheet.Put(vArea);
//	
//	// 3. Check-in summary indexes
//	
//	// Put section header
//	vArea = vTemplate.GetArea("CheckInSummaryHeader");
//	pSpreadsheet.Put(vArea);
//	
//	// Run query to get number of checked-in guests
//	vQry = New Query();
//	vQry.Text = 
//	"SELECT
//	|	ОборотыПродажиНомеров.Period AS Period,
//	|	ОборотыПродажиНомеров.ДокОснование.РазмПоБрони AS ParentDocIsByReservation,
//	|	SUM(ОборотыПродажиНомеров.GuestsCheckedInTurnover) AS GuestsCheckedInTurnover
//	|FROM
//	|	AccumulationRegister.Продажи.Turnovers(&qPeriodFrom, &qPeriodTo, Day, Гостиница IN HIERARCHY (&qHotel)) AS ОборотыПродажиНомеров
//	|GROUP BY
//	|	ОборотыПродажиНомеров.Period,
//	|	ОборотыПродажиНомеров.ДокОснование.РазмПоБрони
//	|ORDER BY
//	|	Period,
//	|	ParentDocIsByReservation";
//	vQry.SetParameter("qPeriodFrom", pmBegOfYear(PeriodTo));
//	vQry.SetParameter("qPeriodTo", EndOfDay(PeriodTo));
//	vQry.SetParameter("qHotel", Гостиница);
//	vQryResult = vQry.Execute().Unload();
//	
//	If ShowPreviousYearData Тогда
//		vQryLY = New Query();
//		vQryLY.Text = 
//		"SELECT
//		|	ОборотыПродажиНомеров.Period AS Period,
//		|	ОборотыПродажиНомеров.ДокОснование.РазмПоБрони AS ParentDocIsByReservation,
//		|	SUM(ОборотыПродажиНомеров.GuestsCheckedInTurnover) AS GuestsCheckedInTurnover
//		|FROM
//		|	AccumulationRegister.Продажи.Turnovers(&qPeriodFrom, &qPeriodTo, Day, Гостиница IN HIERARCHY (&qHotel)) AS ОборотыПродажиНомеров
//		|GROUP BY
//		|	ОборотыПродажиНомеров.Period,
//		|	ОборотыПродажиНомеров.ДокОснование.РазмПоБрони
//		|ORDER BY
//		|	Period,
//		|	ParentDocIsByReservation";
//		vQryLY.SetParameter("qPeriodFrom", pmBegOfYear(PeriodToLY));
//		vQryLY.SetParameter("qPeriodTo", EndOfDay(PeriodToLY));
//		vQryLY.SetParameter("qHotel", Гостиница);
//		vQryResultLY = vQryLY.Execute().Unload();
//	EndIf;
//	
//	// Add forecast guests if period is set in the future
//	If BegOfDay(PeriodTo) >= BegOfDay(CurrentDate()) Тогда
//		vQry = New Query();
//		vQry.Text = 
//		"SELECT
//		|	RoomSalesForecastTurnovers.Period AS Period,
//		|	TRUE AS ParentDocIsByReservation,
//		|	SUM(RoomSalesForecastTurnovers.GuestsCheckedInTurnover) AS GuestsCheckedInTurnover
//		|FROM
//		|	AccumulationRegister.ПрогнозПродаж.Turnovers(&qPeriodFrom, &qPeriodTo, Day, Гостиница IN HIERARCHY (&qHotel)) AS RoomSalesForecastTurnovers
//		|GROUP BY
//		|	RoomSalesForecastTurnovers.Period
//		|ORDER BY
//		|	Period,
//		|	ParentDocIsByReservation";
//		vQry.SetParameter("qPeriodFrom", BegOfDay(CurrentDate()));
//		vQry.SetParameter("qPeriodTo", EndOfDay(PeriodTo));
//		vQry.SetParameter("qHotel", Гостиница);
//		vForecastQryResult = vQry.Execute().Unload();
//		
//		// Merge forecast guests with real ones
//		For Each vForecastRow In vForecastQryResult Do
//			vFound = False;
//			For Each vRow In vQryResult Do
//				If vRow.Period = vForecastRow.Period And
//				   vRow.ParentDocIsByReservation = vForecastRow.ParentDocIsByReservation Тогда
//					vFound = True;
//				    Break;
//				EndIf;
//			EndDo;
//			If НЕ vFound Тогда
//				vRow = vQryResult.Add();
//				vRow.Period = vForecastRow.Period;
//				vRow.ParentDocIsByReservation = vForecastRow.ParentDocIsByReservation;
//				vRow.GuestsCheckedInTurnover = 0;
//			EndIf;
//			vRow.GuestsCheckedInTurnover = vRow.GuestsCheckedInTurnover + vForecastRow.GuestsCheckedInTurnover;
//		EndDo;
//	EndIf;	
//	
//	// Split table to walk-in and check-in by reservation
//	vQryResultWalkInArray = vQryResult.Copy().FindRows(New Structure("ParentDocIsByReservation", False));
//	vQryResultResArray = vQryResult.Copy().FindRows(New Structure("ParentDocIsByReservation", True));
//	
//	vQryResultWalkIn = vQryResult.CopyColumns();
//	For Each vRow In vQryResultWalkInArray Do
//		vTabRow = vQryResultWalkIn.Add();
//		FillPropertyValues(vTabRow, vRow);
//	EndDo;
//	vQryResultWalkIn.GroupBy("Period", "GuestsCheckedInTurnover");
//	
//	vQryResultRes = vQryResult.CopyColumns();
//	For Each vRow In vQryResultResArray Do
//		vTabRow = vQryResultRes.Add();
//		FillPropertyValues(vTabRow, vRow);
//	EndDo;
//	vQryResultRes.GroupBy("Period", "GuestsCheckedInTurnover");
//	
//	GetQryResultTableTotals(vQryResultRes, vQryResultRes, "GuestsCheckedInTurnover", False);
//	
//	If ShowPreviousYearData Тогда
//		vQryResultWalkInArrayLY = vQryResultLY.Copy().FindRows(New Structure("ParentDocIsByReservation", False));
//		vQryResultResArrayLY = vQryResultLY.Copy().FindRows(New Structure("ParentDocIsByReservation", True));
//		
//		vQryResultWalkInLY = vQryResultLY.CopyColumns();
//		For Each vRowLY In vQryResultWalkInArrayLY Do
//			vTabRowLY = vQryResultWalkInLY.Add();
//			FillPropertyValues(vTabRowLY, vRowLY);
//		EndDo;
//		vQryResultWalkInLY.GroupBy("Period", "GuestsCheckedInTurnover");
//		
//		vQryResultResLY = vQryResultLY.CopyColumns();
//		For Each vRowLY In vQryResultResArrayLY Do
//			vTabRowLY = vQryResultResLY.Add();
//			FillPropertyValues(vTabRowLY, vRowLY);
//		EndDo;
//		vQryResultResLY.GroupBy("Period", "GuestsCheckedInTurnover");
//		
//		GetQryResultTableTotalsLY(vQryResultResLY, vQryResultResLY, "GuestsCheckedInTurnover", False);
//	EndIf;
//	
//	vArea = vTemplate.GetArea("ЗабронГостей");
//	vArea.Parameters.mGuestsReserved = cmCastToNumber(TotalPerDay.GuestsCheckedInTurnover);
//	vArea.Parameters.mGuestsReservedPerMonth = cmCastToNumber(TotalPerMonth.GuestsCheckedInTurnover);
//	vArea.Parameters.mGuestsReservedPerYear = cmCastToNumber(TotalPerYear.GuestsCheckedInTurnover);
//	If ShowPreviousYearData Тогда
//		vArea.Parameters.mGuestsReservedLY = cmCastToNumber(TotalPerDayLY.GuestsCheckedInTurnover);
//		vArea.Parameters.mGuestsReservedPerMonthLY = cmCastToNumber(TotalPerMonthLY.GuestsCheckedInTurnover);
//		vArea.Parameters.mGuestsReservedPerYearLY = cmCastToNumber(TotalPerYearLY.GuestsCheckedInTurnover);
//	EndIf;
//	pSpreadsheet.Put(vArea);
//	
//	// Put walk-in
//	GetQryResultTableTotals(vQryResultWalkIn, vQryResultWalkIn, "GuestsCheckedInTurnover", False);
//	If ShowPreviousYearData Тогда
//		GetQryResultTableTotalsLY(vQryResultWalkInLY, vQryResultWalkInLY, "GuestsCheckedInTurnover", False);
//	EndIf;
//	
//	vArea = vTemplate.GetArea("GuestsWalkIn");
//	vArea.Parameters.mGuestsWalkIn = cmCastToNumber(TotalPerDay.GuestsCheckedInTurnover);
//	vArea.Parameters.mGuestsWalkInPerMonth = cmCastToNumber(TotalPerMonth.GuestsCheckedInTurnover);
//	vArea.Parameters.mGuestsWalkInPerYear = cmCastToNumber(TotalPerYear.GuestsCheckedInTurnover);
//	If ShowPreviousYearData Тогда
//		vArea.Parameters.mGuestsWalkInLY = cmCastToNumber(TotalPerDayLY.GuestsCheckedInTurnover);
//		vArea.Parameters.mGuestsWalkInPerMonthLY = cmCastToNumber(TotalPerMonthLY.GuestsCheckedInTurnover);
//		vArea.Parameters.mGuestsWalkInPerYearLY = cmCastToNumber(TotalPerYearLY.GuestsCheckedInTurnover);
//	EndIf;
//	pSpreadsheet.Put(vArea);
//	
//	// 4. Income summary indexes
//	
//	// Put section header
//	vArea = vTemplate.GetArea("IncomeSummaryHeader");
//	pSpreadsheet.Put(vArea);
//	
//	// Put total sales
//	vArea = vTemplate.GetArea("RoomsIncome");
//	vArea.Parameters.mRoomsIncome = vRoomsIncome;
//	vArea.Parameters.mRoomsIncomePerMonth = vRoomsIncomePerMonth;
//	vArea.Parameters.mRoomsIncomePerYear = vRoomsIncomePerYear;
//	If ShowPreviousYearData Тогда
//		vArea.Parameters.mRoomsIncomeLY = vRoomsIncomeLY;
//		vArea.Parameters.mRoomsIncomePerMonthLY = vRoomsIncomePerMonthLY;
//		vArea.Parameters.mRoomsIncomePerYearLY = vRoomsIncomePerYearLY;
//	EndIf;
//	pSpreadsheet.Put(vArea);
//	
//	vArea = vTemplate.GetArea("OtherIncome");
//	vArea.Parameters.mOtherIncome = vOtherIncome;
//	vArea.Parameters.mOtherIncomePerMonth = vOtherIncomePerMonth;
//	vArea.Parameters.mOtherIncomePerYear = vOtherIncomePerYear;
//	If ShowPreviousYearData Тогда
//		vArea.Parameters.mOtherIncomeLY = vOtherIncomeLY;
//		vArea.Parameters.mOtherIncomePerMonthLY = vOtherIncomePerMonthLY;
//		vArea.Parameters.mOtherIncomePerYearLY = vOtherIncomePerYearLY;
//	EndIf;
//	pSpreadsheet.Put(vArea);
//	
//	vArea = vTemplate.GetArea("TotalIncome");
//	vArea.Parameters.mTotalIncome = vTotalIncome;
//	vArea.Parameters.mTotalIncomePerMonth = vTotalIncomePerMonth;
//	vArea.Parameters.mTotalIncomePerYear = vTotalIncomePerYear;
//	If ShowPreviousYearData Тогда
//		vArea.Parameters.mTotalIncomeLY = vTotalIncomeLY;
//		vArea.Parameters.mTotalIncomePerMonthLY = vTotalIncomePerMonthLY;
//		vArea.Parameters.mTotalIncomePerYearLY = vTotalIncomePerYearLY;
//	EndIf;
//	pSpreadsheet.Put(vArea);
//	
//	// Put sales by service types
//	vQry = New Query();
//	vQry.Text = 
//	"SELECT
//	|	ServiceSales.Period AS Period,
//	|	ServiceSales.ServiceType AS ServiceType,
//	|	SUM(ServiceSales.SumTurnover) AS SumTurnover,
//	|	SUM(ServiceSales.SumWithoutVATTurnover) AS SumWithoutVATTurnover
//	|FROM
//	|	(SELECT
//	|		ServiceSalesTurnovers.Period AS Period,
//	|		ISNULL(ServiceSalesTurnovers.Услуга.ServiceType, &qEmptyServiceType) AS ServiceType,
//	|		ServiceSalesTurnovers.SalesTurnover AS SumTurnover,
//	|		ServiceSalesTurnovers.SalesWithoutVATTurnover AS SumWithoutVATTurnover
//	|	FROM
//	|		AccumulationRegister.Продажи.Turnovers(&qPeriodFrom, &qPeriodTo, Day, Гостиница IN HIERARCHY (&qHotel)) AS ServiceSalesTurnovers
//	|	
//	|	UNION ALL
//	|	
//	|	SELECT
//	|		ServiceSalesForecastTurnovers.Period,
//	|		ISNULL(ServiceSalesForecastTurnovers.Услуга.ServiceType, &qEmptyServiceType),
//	|		ServiceSalesForecastTurnovers.SalesTurnover,
//	|		ServiceSalesForecastTurnovers.SalesWithoutVATTurnover
//	|	FROM
//	|		AccumulationRegister.ПрогнозПродаж.Turnovers(&qForecastPeriodFrom, &qForecastPeriodTo, Day, Гостиница IN HIERARCHY (&qHotel)) AS ServiceSalesForecastTurnovers) AS ServiceSales
//	|
//	|GROUP BY
//	|	ServiceSales.Period,
//	|	ServiceSales.ServiceType
//	|
//	|ORDER BY
//	|	Period,
//	|	ServiceSales.ServiceType.ПорядокСортировки";
//	vQry.SetParameter("qPeriodFrom", pmBegOfYear(PeriodTo));
//	vQry.SetParameter("qPeriodTo", EndOfDay(PeriodTo));
//	vQry.SetParameter("qForecastPeriodFrom", BegOfDay(CurrentDate()));
//	vQry.SetParameter("qForecastPeriodTo", EndOfDay(PeriodTo));
//	vQry.SetParameter("qHotel", Гостиница);
//	vQry.SetParameter("qEmptyServiceType", Справочники.ТипыУслуг.EmptyRef());
//	vQryResult = vQry.Execute().Unload();
//	
//	// Get list of service types
//	vServiceTypes = vQryResult.Copy();
//	vServiceTypes.GroupBy("ServiceType", );
//	
//	If ShowPreviousYearData Тогда
//		vQryLY = New Query();
//		vQryLY.Text = 
//		"SELECT
//		|	ServiceSales.Period AS Period,
//		|	ServiceSales.ServiceType AS ServiceType,
//		|	SUM(ServiceSales.SumTurnover) AS SumTurnover,
//		|	SUM(ServiceSales.SumWithoutVATTurnover) AS SumWithoutVATTurnover
//		|FROM
//		|	(SELECT
//		|		ServiceSalesTurnovers.Period AS Period,
//		|		ISNULL(ServiceSalesTurnovers.Услуга.ServiceType, &qEmptyServiceType)  AS ServiceType,
//		|		ServiceSalesTurnovers.SalesTurnover AS SumTurnover,
//		|		ServiceSalesTurnovers.SalesWithoutVATTurnover AS SumWithoutVATTurnover
//		|	FROM
//		|		AccumulationRegister.Продажи.Turnovers(&qPeriodFrom, &qPeriodTo, Day, Гостиница IN HIERARCHY (&qHotel)) AS ServiceSalesTurnovers) AS ServiceSales
//		|
//		|GROUP BY
//		|	ServiceSales.Period,
//		|	ServiceSales.ServiceType
//		|
//		|ORDER BY
//		|	Period,
//		|	ServiceSales.ServiceType.ПорядокСортировки";
//		vQryLY.SetParameter("qPeriodFrom", pmBegOfYear(PeriodToLY));
//		vQryLY.SetParameter("qPeriodTo", EndOfDay(PeriodToLY));
//		vQryLY.SetParameter("qHotel", Гостиница);
//		vQryLY.SetParameter("qEmptyServiceType", Справочники.ТипыУслуг.EmptyRef());
//		vQryResultLY = vQryLY.Execute().Unload();
//		
//		// Get list of service types
//		vServiceTypesLY = vQryResultLY.Copy();
//		vServiceTypesLY.GroupBy("ServiceType", );
//		
//		// Add rows of last year service types to the list of current ones
//		For Each vSTRowLY In vServiceTypesLY Do
//			If vServiceTypes.Find(vSTRowLY.ServiceType, "ServiceType") = Неопределено Тогда
//				vSTRow = vServiceTypes.Add();
//				vSTRow.ServiceType = vSTRowLY.ServiceType;
//				vQRRow = vQryResult.Add();
//				vQRRow.ServiceType = vSTRowLY.ServiceType;
//			EndIf;
//		EndDo;
//		For Each vSTRow In vServiceTypes Do
//			If vServiceTypesLY.Find(vSTRow.ServiceType, "ServiceType") = Неопределено Тогда
//				vSTRowLY = vServiceTypesLY.Add();
//				vSTRowLY.ServiceType = vSTRow.ServiceType;
//				vQRRowLY = vQryResultLY.Add();
//				vQRRowLY.ServiceType = vSTRow.ServiceType;
//			EndIf;
//		EndDo;
//	EndIf;
//	
//	If vServiceTypes.Count() > 1 Тогда
//		vArea = vTemplate.GetArea("ServiceTypeHeader");
//		pSpreadsheet.Put(vArea);
//		
//		vArea = vTemplate.GetArea("ServiceTypeIncome");
//		
//		// Put service types summary
//		For Each vRow In vServiceTypes Do
//			vServiceType = vRow.ServiceType;
//			vArea.Parameters.mServiceType = ?(ЗначениеЗаполнено(vServiceType), vServiceType, NStr("en='<UNDEFINED>';ru='<ПУСТОЙ>';de='<LEER>'"));
//			
//			// Get records for the current payment method only
//			vQrySubresult = vQryResult.FindRows(New Structure("ServiceType", vServiceType));
//			GetQryResultTableTotals(vQrySubresult, vQryResult, "SumTurnover, SumWithoutVATTurnover", False);
//			If ShowPreviousYearData Тогда
//				vRowLY = vServiceTypesLY.Find(vServiceType, "ServiceType");
//				vQrySubresultLY = vQryResultLY.FindRows(New Structure("ServiceType", vServiceType));
//				GetQryResultTableTotalsLY(vQrySubresultLY, vQryResultLY, "SumTurnover, SumWithoutVATTurnover", False);
//			EndIf;
//			
//			If vWithVAT Тогда
//				vArea.Parameters.mServiceTypeIncome = cmCastToNumber(TotalPerDay.SumTurnover);
//				vArea.Parameters.mServiceTypeIncomePerMonth = cmCastToNumber(TotalPerMonth.SumTurnover);
//				vArea.Parameters.mServiceTypeIncomePerYear = cmCastToNumber(TotalPerYear.SumTurnover);
//				If ShowPreviousYearData Тогда
//					vArea.Parameters.mServiceTypeIncomeLY = cmCastToNumber(TotalPerDayLY.SumTurnover);
//					vArea.Parameters.mServiceTypeIncomePerMonthLY = cmCastToNumber(TotalPerMonthLY.SumTurnover);
//					vArea.Parameters.mServiceTypeIncomePerYearLY = cmCastToNumber(TotalPerYearLY.SumTurnover);
//				EndIf;
//			Else
//				vArea.Parameters.mServiceTypeIncome = cmCastToNumber(TotalPerDay.SumWithoutVATTurnover);
//				vArea.Parameters.mServiceTypeIncomePerMonth = cmCastToNumber(TotalPerMonth.SumWithoutVATTurnover);
//				vArea.Parameters.mServiceTypeIncomePerYear = cmCastToNumber(TotalPerYear.SumWithoutVATTurnover);
//				If ShowPreviousYearData Тогда
//					vArea.Parameters.mServiceTypeIncomeLY = cmCastToNumber(TotalPerDayLY.SumWithoutVATTurnover);
//					vArea.Parameters.mServiceTypeIncomePerMonthLY = cmCastToNumber(TotalPerMonthLY.SumWithoutVATTurnover);
//					vArea.Parameters.mServiceTypeIncomePerYearLY = cmCastToNumber(TotalPerYearLY.SumWithoutVATTurnover);
//				EndIf;
//			EndIf;
//			
//			pSpreadsheet.Put(vArea);
//		EndDo;
//	EndIf;
//	
//	// 5. Payments summary indexes
//	
//	// Put section header
//	vArea = vTemplate.GetArea("PaymentsHeader");
//	pSpreadsheet.Put(vArea);
//	
//	// Run query to get payments by payment method
//	vQry = New Query();
//	vQry.Text = 
//	"SELECT
//	|	PaymentsTurnovers.СпособОплаты AS СпособОплаты,
//	|	PaymentsTurnovers.Period AS Period,
//	|	SUM(PaymentsTurnovers.SumTurnover) AS SumTurnover,
//	|	SUM(PaymentsTurnovers.VATSumTurnover) AS VATSumTurnover
//	|FROM
//	|	AccumulationRegister.Платежи.Turnovers(&qPeriodFrom, &qPeriodTo, Day, Гостиница IN HIERARCHY (&qHotel)) AS PaymentsTurnovers
//	|GROUP BY
//	|	PaymentsTurnovers.Period,
//	|	PaymentsTurnovers.СпособОплаты
//	|ORDER BY
//	|	СпособОплаты,
//	|	Period";
//	vQry.SetParameter("qPeriodFrom", pmBegOfYear(PeriodTo));
//	vQry.SetParameter("qPeriodTo", EndOfDay(PeriodTo));
//	vQry.SetParameter("qHotel", Гостиница);
//	vQryResult = vQry.Execute().Unload();
//	
//	// Get list of payment methods
//	vPaymentMethods = vQryResult.Copy();
//	vPaymentMethods.GroupBy("СпособОплаты", );
//	
//	If ShowPreviousYearData Тогда
//		vQryLY = New Query();
//		vQryLY.Text = 
//		"SELECT
//		|	PaymentsTurnovers.СпособОплаты AS СпособОплаты,
//		|	PaymentsTurnovers.Period AS Period,
//		|	SUM(PaymentsTurnovers.SumTurnover) AS SumTurnover,
//		|	SUM(PaymentsTurnovers.VATSumTurnover) AS VATSumTurnover
//		|FROM
//		|	AccumulationRegister.Платежи.Turnovers(&qPeriodFrom, &qPeriodTo, Day, Гостиница IN HIERARCHY (&qHotel)) AS PaymentsTurnovers
//		|GROUP BY
//		|	PaymentsTurnovers.Period,
//		|	PaymentsTurnovers.СпособОплаты
//		|ORDER BY
//		|	СпособОплаты,
//		|	Period";
//		vQryLY.SetParameter("qPeriodFrom", pmBegOfYear(PeriodToLY));
//		vQryLY.SetParameter("qPeriodTo", EndOfDay(PeriodToLY));
//		vQryLY.SetParameter("qHotel", Гостиница);
//		vQryResultLY = vQryLY.Execute().Unload();
//		
//		// Get list of payment methods
//		vPaymentMethodsLY = vQryResultLY.Copy();
//		vPaymentMethodsLY.GroupBy("СпособОплаты", );
//		
//		For Each vPMRowLY In vPaymentMethodsLY Do
//			If vPaymentMethods.Find(vPMRowLY.PaymentMethod, "СпособОплаты") = Неопределено Тогда
//				vPMRow = vPaymentMethods.Add();
//				vPMRow.СпособОплаты = vPMRowLY.PaymentMethod;
//				vQRRow = vQryResult.Add();
//				vQRRow.СпособОплаты = vPMRowLY.PaymentMethod;
//			EndIf;
//		EndDo;
//		For Each vPMRow In vPaymentMethods Do
//			If vPaymentMethodsLY.Find(vPMRow.PaymentMethod, "СпособОплаты") = Неопределено Тогда
//				vPMRowLY = vPaymentMethodsLY.Add();
//				vPMRowLY.СпособОплаты = vPMRow.PaymentMethod;
//				vQRRowLY = vQryResultLY.Add();
//				vQRRowLY.СпособОплаты = vPMRow.PaymentMethod;
//			EndIf;
//		EndDo;
//	EndIf;
//	
//	// Put payment methods summary
//	vTotalPaymentsPerDay = 0;
//	vTotalPaymentsPerMonth = 0;
//	vTotalPaymentsPerYear = 0;
//	If ShowPreviousYearData Тогда
//		vTotalPaymentsPerDayLY = 0;
//		vTotalPaymentsPerMonthLY = 0;
//		vTotalPaymentsPerYearLY = 0;
//	EndIf;
//	For Each vRow In vPaymentMethods Do
//		vPaymentMethod = vRow.PaymentMethod;
//		If vPaymentMethod = Справочники.СпособОплаты.Акт Тогда
//			Continue;
//		EndIf;
//		
//		// Get records for the current payment method only
//		vQrySubresult = vQryResult.FindRows(New Structure("СпособОплаты", vPaymentMethod));
//		GetQryResultTableTotals(vQrySubresult, vQryResult, "SumTurnover, VATSumTurnover", False);
//		If ShowPreviousYearData Тогда
//			vRowLY = vPaymentMethods.Find(vPaymentMethod, "СпособОплаты");
//			vQrySubresultLY = vQryResultLY.FindRows(New Structure("СпособОплаты", vPaymentMethod));
//			GetQryResultTableTotalsLY(vQrySubresultLY, vQryResultLY, "SumTurnover, VATSumTurnover", False);
//		EndIf;
//		
//		vArea = vTemplate.GetArea("СпособОплаты");
//		vArea.Parameters.mPaymentMethod = vPaymentMethod;
//		vArea.Parameters.mSumTurnover = cmCastToNumber(TotalPerDay.SumTurnover);
//		vArea.Parameters.mSumTurnoverPerMonth = cmCastToNumber(TotalPerMonth.SumTurnover);
//		vArea.Parameters.mSumTurnoverPerYear = cmCastToNumber(TotalPerYear.SumTurnover);
//		If ShowPreviousYearData Тогда
//			vArea.Parameters.mSumTurnoverLY = cmCastToNumber(TotalPerDayLY.SumTurnover);
//			vArea.Parameters.mSumTurnoverPerMonthLY = cmCastToNumber(TotalPerMonthLY.SumTurnover);
//			vArea.Parameters.mSumTurnoverPerYearLY = cmCastToNumber(TotalPerYearLY.SumTurnover);
//		EndIf;
//		pSpreadsheet.Put(vArea);
//		
//		vTotalPaymentsPerDay = vTotalPaymentsPerDay + cmCastToNumber(TotalPerDay.SumTurnover);
//		vTotalPaymentsPerMonth = vTotalPaymentsPerMonth + cmCastToNumber(TotalPerMonth.SumTurnover);
//		vTotalPaymentsPerYear = vTotalPaymentsPerYear + cmCastToNumber(TotalPerYear.SumTurnover);
//		If ShowPreviousYearData Тогда
//			vTotalPaymentsPerDayLY = vTotalPaymentsPerDayLY + cmCastToNumber(TotalPerDayLY.SumTurnover);
//			vTotalPaymentsPerMonthLY = vTotalPaymentsPerMonthLY + cmCastToNumber(TotalPerMonthLY.SumTurnover);
//			vTotalPaymentsPerYearLY = vTotalPaymentsPerYearLY + cmCastToNumber(TotalPerYearLY.SumTurnover);
//		EndIf;
//	EndDo;
//		
//	// Payments footer
//	vArea = vTemplate.GetArea("PaymentsFooter");
//	vArea.Parameters.mSumTurnover = vTotalPaymentsPerDay;
//	vArea.Parameters.mSumTurnoverPerMonth = vTotalPaymentsPerMonth;
//	vArea.Parameters.mSumTurnoverPerYear = vTotalPaymentsPerYear;
//	If ShowPreviousYearData Тогда
//		vArea.Parameters.mSumTurnoverLY = vTotalPaymentsPerDayLY;
//		vArea.Parameters.mSumTurnoverPerMonthLY = vTotalPaymentsPerMonthLY;
//		vArea.Parameters.mSumTurnoverPerYearLY = vTotalPaymentsPerYearLY;
//	EndIf;
//	pSpreadsheet.Put(vArea);
//	
//	// Report footer
//	vFooter = vTemplate.GetArea("Footer");
//	pSpreadsheet.Put(vFooter);
//	
//	// Create new rows format and set columns width
//	vSpreadsheetEndHeight = pSpreadsheet.TableHeight;
//	vArea = pSpreadsheet.Area(vSpreadsheetEndHeight, , vSpreadsheetEndHeight);
//	vArea.CreateFormatOfRows();
//	For i = 1 To vTemplate.TableWidth Do
//		pSpreadsheet.Area(1, i).ColumnWidth = vTemplate.Area(1, i).ColumnWidth;
//	EndDo;
//КонецПроцедуры //pmGenerate
