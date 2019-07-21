Перем TotalPerDay;
Перем ExpTotalGuests;
Перем MoreThanOneRecord;
Перем Tabulation;

//-------------------------------------------------------------------------------------------------
&AtServer
Процедура GetQResultTableTotals(pPeriod, pTbl, pTemplate, pResources, pConvertToTurnover = True)
	// Convert pTbl to the value table if necessary
	vTbl = pTbl;
	If TypeOf(pTbl) = Type("Array") Тогда                 
		vTbl = pTemplate.CopyColumns();
		For Each vRow In pTbl Do
			vTblRow = vTbl.Add();
			FillPropertyValues(vTblRow, vRow);
		EndDo;
	EndIf;
	
	If vTbl.Count() = 0 Тогда
		vTbl.Add();
	EndIf;
	
	vTbl.GroupBy(, pResources);
	TotalPerDay = vTbl.Get(0);
КонецПроцедуры //GetQResultTableTotals

//-------------------------------------------------------------------------------------------------
&AtServer
Процедура GetHotelAndPeriod()
	Гостиница = ПараметрыСеанса.ТекущаяГостиница;
	PeriodTo = CurrentDate();
	
	ChoosePeriod = Items.ChoosePeriod.ChoiceList.FindByValue("0").Presentation;
	SelYear = Format(Year(CurrentDate()), "ND=4; NFD=0; NG=");
	CompareYear = Format(Year(CurrentDate()), "ND=4; NFD=0; NG=");
	Items.SelYear.ChoiceList.Add("-//-", "-//-");
	Items.CompareYear.ChoiceList.Add("-//-", "-//-");
	For vInd = -1 To 9 Do
		Items.SelYear.ChoiceList.Add(Format(Year(CurrentDate())-vInd, "ND=4; NFD=0; NG="), Format(Year(CurrentDate())-vInd, "ND=4; NFD=0; NG="));
		Items.CompareYear.ChoiceList.Add(Format(Year(CurrentDate())-vInd, "ND=4; NFD=0; NG="), Format(Year(CurrentDate())-vInd, "ND=4; NFD=0; NG="));
	EndDo;
	vQuarterNumber = String(Int(Month(EndOfQuarter(CurrentDate()))/3));
	SelQuarter = Items.SelQuarter.ChoiceList.FindByValue(vQuarterNumber).Presentation;
	CompareQuarter = NStr("en='-НЕ selected-';ru='-Не выбран-';de='-Nicht ausgewählt-'");
	SelMonth = Items.SelMonth.ChoiceList.FindByValue(String(Month(CurrentDate()))).Presentation;
	CompareMonth = NStr("en='-НЕ selected-';ru='-Не выбран-';de='-Nicht ausgewählt-'");
	MonthNumber = String(Month(CurrentDate()));
	CompareMonthNumber = String(Month(CurrentDate()));
	CompositionDate = CurrentDate();
	CompareCompositionDate = CurrentDate();
КонецПроцедуры //GetHotelAndPeriod

//-------------------------------------------------------------------------------------------------
&AtServer
Процедура GetRooms()
	// Clear pages
	If IndexesTable.Count() > 0 Тогда
		IndexesTable.Clear();
	EndIf;
	
	// Check period choosen
	If Items.PeriodDay.Visible Тогда
		vBegOfPeriod = BegOfDay(PeriodTo);
		vEndOfPeriod = EndOfDay(PeriodTo);
	ElsIf Items.SelQuarter.Visible Тогда
		vBegOfPeriod = BegOfQuarter(CompositionDate);
		vEndOfPeriod = EndOfQuarter(CompositionDate);
	ElsIf Items.SelMonth.Visible Тогда
		vBegOfPeriod = BegOfMonth(CompositionDate);
		vEndOfPeriod = EndOfMonth(CompositionDate);
	Else
		vBegOfPeriod = BegOfYear(CompositionDate);
		vEndOfPeriod = EndOfYear(CompositionDate);
	EndIf;
	// Initialize typesof data to show
	vInRooms = True;
	vWithVAT = True;
	If ЗначениеЗаполнено(Гостиница) Тогда
		vInRooms = НЕ Гостиница.ShowReportsInBeds;
		vWithVAT = Гостиница.ShowSalesInReportsWithVAT;
	EndIf;
	
	// Initialize reporting currency
	vReportingCurrency = Гостиница.Валюта;
	If НЕ ЗначениеЗаполнено(Гостиница) Тогда
		Return;
	EndIf;
	
	// Add header
	vNewStr = IndexesTable.Add();
	vNewStr.IndexPicture = PictureLib.НомернойФонд;
	vNewStr.IndexName = NStr("en='ROOMS OCCUPATION';ru='СТАТИСТИКА ПО ЗАГРУЗКЕ';de='STATISTIK NACH AUSLASTUNG'");
	vNewStr.IndexKey = vNewStr.IndexName;
	
	// Run query to get total number of rooms, rooms blocked, vacant number of rooms
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	RoomInventoryBalanceAndTurnovers.Period AS Period,
	|	SUM(RoomInventoryBalanceAndTurnovers.CounterClosingBalance) AS CounterClosingBalance,
	|	SUM(RoomInventoryBalanceAndTurnovers.TotalRoomsClosingBalance) AS TotalRoomsClosingBalance,
	|	SUM(RoomInventoryBalanceAndTurnovers.TotalBedsClosingBalance) AS TotalBedsClosingBalance,
	|	-SUM(RoomInventoryBalanceAndTurnovers.RoomsBlockedClosingBalance) AS RoomsBlockedClosingBalance,
	|	-SUM(RoomInventoryBalanceAndTurnovers.BedsBlockedClosingBalance) AS BedsBlockedClosingBalance
	|FROM
	|	AccumulationRegister.ЗагрузкаНомеров.BalanceAndTurnovers(&qPeriodFrom, &qPeriodTo, Day, RegisterRecordsAndPeriodBoundaries, Гостиница IN HIERARCHY (&qHotel)) AS RoomInventoryBalanceAndTurnovers
	|GROUP BY
	|	RoomInventoryBalanceAndTurnovers.Period
	|ORDER BY
	|	Period";
	vQry.SetParameter("qPeriodFrom", vBegOfPeriod);
	vQry.SetParameter("qPeriodTo", vEndOfPeriod);
	vQry.SetParameter("qHotel", Гостиница);
	vQryResult = vQry.Execute().Unload();
	
	vResources = "TotalRoomsClosingBalance, TotalBedsClosingBalance, RoomsBlockedClosingBalance, BedsBlockedClosingBalance";
	GetQResultTableTotals(PeriodTo, vQryResult, vQryResult, vResources);
	vTotalRooms = cmCastToNumber(TotalPerDay.TotalRoomsClosingBalance);
	vTotalBeds = cmCastToNumber(TotalPerDay.TotalBedsClosingBalance);
	
	If vInRooms then
		vNewStr = IndexesTable.Add();
		vNewStr.IndexName = Tabulation + NStr("en='Total Rooms';ru='Всего номеров';de='Gesamt Zimmer'");
		vNewStr.IndexKey = vNewStr.IndexName;
		vNewStr.IndexValue = vTotalRooms;
		vNewStr.IndexPresentation = vTotalRooms;
	Else
		vNewStr = IndexesTable.Add();
		vNewStr.IndexName = Tabulation + NStr("en='Total Beds';ru='Всего мест';de='Gesamt Betten'");
		vNewStr.IndexKey = vNewStr.IndexName;
		vNewStr.IndexValue = vTotalBeds;
		vNewStr.IndexPresentation = vTotalBeds;
	EndIf;
	
	vBlockedRooms = cmCastToNumber(TotalPerDay.RoomsBlockedClosingBalance);
	vBlockedBeds = cmCastToNumber(TotalPerDay.BedsBlockedClosingBalance);
	vRoomsForSale = vTotalRooms - vBlockedRooms;
	vBedsForSale = vTotalBeds - vBlockedBeds;
	
	// Run query to get number of blocked rooms per ГруппаНомеров block types
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	RoomBlocksBalanceAndTurnovers.RoomBlockType AS RoomBlockType,
	|	RoomBlocksBalanceAndTurnovers.Period AS Period,
	|	SUM(RoomBlocksBalanceAndTurnovers.RoomsBlockedClosingBalance) AS RoomsBlockedClosingBalance,
	|	SUM(RoomBlocksBalanceAndTurnovers.BedsBlockedClosingBalance) AS BedsBlockedClosingBalance
	|FROM
	|	AccumulationRegister.БлокирНомеров.BalanceAndTurnovers(&qPeriodFrom, &qPeriodTo, Day, RegisterRecordsAndPeriodBoundaries, Гостиница IN HIERARCHY (&qHotel)) AS RoomBlocksBalanceAndTurnovers
	|
	|GROUP BY
	|	RoomBlocksBalanceAndTurnovers.RoomBlockType,
	|	RoomBlocksBalanceAndTurnovers.Period
	|
	|ORDER BY
	|	RoomBlocksBalanceAndTurnovers.RoomBlockType.ПорядокСортировки,
	|	Period";
	vQry.SetParameter("qPeriodFrom", vBegOfPeriod);
	vQry.SetParameter("qPeriodTo", vEndOfPeriod);
	vQry.SetParameter("qHotel", Гостиница);
	vQryResult = vQry.Execute().Unload();
	
	// Get list of ГруппаНомеров block types
	vSpecRoomsBlocked = 0;
	vSpecBedsBlocked = 0;
	vRoomBlockTypes = vQryResult.Copy();
	vRoomBlockTypes.GroupBy("RoomBlockType", );
	If vQryResult.Count()>0 Тогда
		
		// Put ГруппаНомеров blocks per ГруппаНомеров block type
		For Each vRow In vRoomBlockTypes Do
			vRoomBlockType = vRow.RoomBlockType;
			
			// Get records for the current ГруппаНомеров block type only
			vQrySubresult = vQryResult.FindRows(New Structure("RoomBlockType", vRoomBlockType));
			GetQResultTableTotals(PeriodTo, vQrySubresult, vQryResult, "RoomsBlockedClosingBalance, BedsBlockedClosingBalance");
			
			If vInRooms Тогда
				vBlockedRooms = cmCastToNumber(TotalPerDay.RoomsBlockedClosingBalance);		
				
				vNewStr = IndexesTable.Add();
				vNewStr.IndexName = Tabulation + vRoomBlockType;
				vNewStr.IndexKey = vRoomBlockType;
				vNewStr.IndexValue = vBlockedRooms;
				vNewStr.IndexPresentation = vBlockedRooms;
				
				If vRoomBlockType.AddToRoomsRentedInSummaryIndexes Тогда
					vSpecRoomsBlocked = vSpecRoomsBlocked + cmCastToNumber(TotalPerDay.RoomsBlockedClosingBalance);
				EndIf;
			Else
				vBlockedBeds = cmCastToNumber(TotalPerDay.BedsBlockedClosingBalance);
				
				vNewStr = IndexesTable.Add();
				vNewStr.IndexName = Tabulation + vRoomBlockType;
				vNewStr.IndexKey = vRoomBlockType;
				vNewStr.IndexValue = vBlockedBeds;
				vNewStr.IndexPresentation = vBlockedBeds;
				
				If vRoomBlockType.AddToRoomsRentedInSummaryIndexes Тогда
					vSpecBedsBlocked = vSpecBedsBlocked + cmCastToNumber(TotalPerDay.BedsBlockedClosingBalance);
				EndIf;
			EndIf;
		EndDo;
	Else 
		vNewStr = IndexesTable.Add();
		vNewStr.IndexName = Tabulation + NStr("en='Repaired';ru='Ремонт';de='Reparatur'");
		vNewStr.IndexKey = NStr("en='Repaired';ru='Ремонт';de='Reparatur'");
		vNewStr.IndexValue = 0;
		vNewStr.IndexPresentation = 0;
	EndIf;
	
	// Put rooms for sale
	If vInRooms Тогда
		vNewStr = IndexesTable.Add();
		vNewStr.IndexName = Tabulation + NStr("en='Rooms For Sale';ru='Номеров к продаже';de='Zimmer im Verkauf'");
		vNewStr.IndexKey = vNewStr.IndexName;
		vNewStr.IndexValue = vRoomsForSale + vSpecRoomsBlocked;
		vNewStr.IndexPresentation = vRoomsForSale + vSpecRoomsBlocked;
	Else
		vNewStr = IndexesTable.Add();
		vNewStr.IndexName = Tabulation + NStr("en='Beds For Sale';ru='Мест к продаже';de='Betten für den Verkauf'");
		vNewStr.IndexKey = vNewStr.IndexName;
		vNewStr.IndexValue = vBedsForSale + vSpecBedsBlocked;
		vNewStr.IndexPresentation = vBedsForSale + vSpecBedsBlocked;
	EndIf;
	
	// Run query to get ГруппаНомеров sales
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	ОборотыПродажиНомеров.Period AS Period,
	|	ОборотыПродажиНомеров.Тариф.IsComplimentary AS RoomRateIsComplimentary,
	|	SUM(ОборотыПродажиНомеров.SalesTurnover) AS SalesTurnover,
	|	SUM(ОборотыПродажиНомеров.SalesWithoutVATTurnover) AS SalesWithoutVATTurnover,
	|	SUM(ОборотыПродажиНомеров.RoomRevenueTurnover) AS RoomRevenueTurnover,
	|	SUM(ОборотыПродажиНомеров.RoomRevenueWithoutVATTurnover) AS RoomRevenueWithoutVATTurnover,
	|	SUM(ОборотыПродажиНомеров.RoomsRentedTurnover) AS RoomsRentedTurnover,
	|	SUM(ОборотыПродажиНомеров.BedsRentedTurnover) AS BedsRentedTurnover
	|FROM
	|	AccumulationRegister.Продажи.Turnovers(&qPeriodFrom, &qPeriodTo, Day, Гостиница IN HIERARCHY (&qHotel)) AS ОборотыПродажиНомеров
	|GROUP BY
	|	ОборотыПродажиНомеров.Period,
	|	ОборотыПродажиНомеров.Тариф.IsComplimentary
	|ORDER BY
	|	Period,
	|	RoomRateIsComplimentary";
	vQry.SetParameter("qPeriodFrom", vBegOfPeriod);
	vQry.SetParameter("qPeriodTo", vEndOfPeriod);
	vQry.SetParameter("qHotel", Гостиница);
	vQryResult = vQry.Execute().Unload();
	
	// Add forecast sales
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	RoomSalesForecastTurnovers.Period AS Period,
	|	RoomSalesForecastTurnovers.Тариф.IsComplimentary AS RoomRateIsComplimentary,
	|	SUM(RoomSalesForecastTurnovers.SalesTurnover) AS SalesTurnover,
	|	SUM(RoomSalesForecastTurnovers.SalesWithoutVATTurnover) AS SalesWithoutVATTurnover,
	|	SUM(RoomSalesForecastTurnovers.RoomRevenueTurnover) AS RoomRevenueTurnover,
	|	SUM(RoomSalesForecastTurnovers.RoomRevenueWithoutVATTurnover) AS RoomRevenueWithoutVATTurnover,
	|	SUM(RoomSalesForecastTurnovers.RoomsRentedTurnover) AS RoomsRentedTurnover,
	|	SUM(RoomSalesForecastTurnovers.BedsRentedTurnover) AS BedsRentedTurnover
	|FROM
	|	AccumulationRegister.ПрогнозПродаж.Turnovers(&qPeriodFrom, &qPeriodTo, Day, Гостиница IN HIERARCHY (&qHotel)) AS RoomSalesForecastTurnovers
	|GROUP BY
	|	RoomSalesForecastTurnovers.Period,
	|	RoomSalesForecastTurnovers.Тариф.IsComplimentary
	|ORDER BY
	|	Period,
	|	RoomRateIsComplimentary";
	vQry.SetParameter("qPeriodFrom", vBegOfPeriod);
	vQry.SetParameter("qPeriodTo", vEndOfPeriod);
	vQry.SetParameter("qHotel", Гостиница);
	vForecastQryResult = vQry.Execute().Unload();
	
	// Merge forecast sales with real ones
	For Each vForecastRow In vForecastQryResult Do
		vFound = False;
		For Each vRow In vQryResult Do
			If vRow.Period = vForecastRow.Period And
				vRow.RoomRateIsComplimentary = vForecastRow.RoomRateIsComplimentary Тогда
				vFound = True;
				Break;
			EndIf;
		EndDo;
		If НЕ vFound Тогда
			vRow = vQryResult.Add();
			vRow.Period = vForecastRow.Period;
			vRow.RoomRateIsComplimentary = vForecastRow.RoomRateIsComplimentary;
			vRow.SalesTurnover = 0;
			vRow.SalesWithoutVATTurnover = 0;
			vRow.RoomRevenueTurnover = 0;
			vRow.RoomRevenueWithoutVATTurnover = 0;
			vRow.RoomsRentedTurnover = 0;
			vRow.BedsRentedTurnover = 0;
		EndIf;
		vRow.SalesTurnover = vRow.SalesTurnover + vForecastRow.SalesTurnover;
		vRow.SalesWithoutVATTurnover = vRow.SalesWithoutVATTurnover + vForecastRow.SalesWithoutVATTurnover;
		vRow.RoomRevenueTurnover = vRow.RoomRevenueTurnover + vForecastRow.RoomRevenueTurnover;
		vRow.RoomRevenueWithoutVATTurnover = vRow.RoomRevenueWithoutVATTurnover + vForecastRow.RoomRevenueWithoutVATTurnover;
		vRow.RoomsRentedTurnover = vRow.RoomsRentedTurnover + vForecastRow.RoomsRentedTurnover;
		vRow.BedsRentedTurnover = vRow.BedsRentedTurnover + vForecastRow.BedsRentedTurnover;
	EndDo;
	
	vResources = "SalesTurnover, SalesWithoutVATTurnover, RoomRevenueTurnover, RoomRevenueWithoutVATTurnover, RoomsRentedTurnover, BedsRentedTurnover";
	
	// Split table to total and complimentary only
	vQryResultComplArray = vQryResult.Copy().FindRows(New Structure("RoomRateIsComplimentary", True));
	vQryResult.GroupBy("Period", vResources);
	vQryResultCompl = vQryResult.CopyColumns();
	For Each vRow In vQryResultComplArray Do
		vTabRow = vQryResultCompl.Add();
		FillPropertyValues(vTabRow, vRow);
	EndDo;
	vQryResultCompl.GroupBy("Period", vResources);
	
	// Put rooms rented
	GetQResultTableTotals(PeriodTo, vQryResult, vQryResult, vResources, False);
	If vInRooms Тогда
		vRoomsRented = cmCastToNumber(TotalPerDay.RoomsRentedTurnover);
		vNewStr = IndexesTable.Add();
		vNewStr.IndexName = Tabulation + NStr("en='Rooms Rented';ru='Продано номеров';de='Verkaufte Zimmer'");
		vNewStr.IndexKey = vNewStr.IndexName;
		vNewStr.IndexValue = vRoomsRented;
		vNewStr.IndexPresentation = Round(vRoomsRented);
	Else
		vBedsRented = cmCastToNumber(TotalPerDay.BedsRentedTurnover);
		vNewStr = IndexesTable.Add();
		vNewStr.IndexName = Tabulation + NStr("en='Beds Rented';ru='Продано мест';de='Verkaufte Betten'");
		vNewStr.IndexKey = vNewStr.IndexName;
		vNewStr.IndexValue = vBedsRented;
		vNewStr.IndexPresentation = Round(vBedsRented);
	EndIf;
	
	// Save total sale amounts
	If vWithVAT Тогда
		vRoomsIncome = cmCastToNumber(TotalPerDay.RoomRevenueTurnover);		
		vTotalIncome = cmCastToNumber(TotalPerDay.SalesTurnover);
	Else
		vRoomsIncome = cmCastToNumber(TotalPerDay.RoomRevenueWithoutVATTurnover);		
		vTotalIncome = cmCastToNumber(TotalPerDay.SalesWithoutVATTurnover);
	EndIf;
	vOtherIncome = vTotalIncome - vRoomsIncome;
	
	// Put occupation percents	
	If vInRooms Тогда
		vOccupationRooms = Round(?((vRoomsForSale + vSpecRoomsBlocked) <> 0, 100*(vRoomsRented + vSpecRoomsBlocked)/(vRoomsForSale + vSpecRoomsBlocked), 0), 2);
		
		vNewStr = IndexesTable.Add();
		vNewStr.IndexName = Tabulation + NStr("ru = '% Загрузки по проданным номерам'; en = 'Occupation % by rooms rented'; de = 'Occupation % by rooms rented'");
		vNewStr.IndexKey = vNewStr.IndexName;
		vNewStr.IndexValue = vOccupationRooms;
		vNewStr.IndexPresentation = String(vOccupationRooms)+"%";
		
		vAvgRoomPrice = Round(?(vRoomsRented <> 0, vRoomsIncome/vRoomsRented, 0), 2);
		vAvgRoomPriceInclAddSrv = Round(?(vRoomsRented <> 0, vTotalIncome/vRoomsRented, 0), 2);
		vAvgRoomIncome = Round(?((vRoomsForSale + vSpecRoomsBlocked) <> 0, vRoomsIncome/(vRoomsForSale + vSpecRoomsBlocked), 0), 2);
		
		vNewStr = IndexesTable.Add();
		vNewStr.IndexName = Tabulation + NStr("en='Average ГруппаНомеров price';ru='Средняя цена номера';de='Durchschnittspreis eines Zimmers'");
		vNewStr.IndexKey = vNewStr.IndexName;
		vNewStr.IndexValue = vAvgRoomPrice;
		vNewStr.IndexPresentation = ?(vAvgRoomPrice = 0, vAvgRoomPrice, cmFormatSum(vAvgRoomPrice, vReportingCurrency));			
		
		vNewStr = IndexesTable.Add();
		vNewStr.IndexName = Tabulation + NStr("en='Avg. price incl. add. services';ru='Ср. цена с доп. услугами';de='Durchschnittspreis mit zusätzlichen Dienstleistungen'");
		vNewStr.IndexKey = vNewStr.IndexName;
		vNewStr.IndexValue = vAvgRoomPriceInclAddSrv;
		vNewStr.IndexPresentation = ?(vAvgRoomPriceInclAddSrv = 0, vAvgRoomPriceInclAddSrv, cmFormatSum(vAvgRoomPriceInclAddSrv, vReportingCurrency));
		
		vNewStr = IndexesTable.Add();
		vNewStr.IndexName = Tabulation + NStr("en='Revenue per available ГруппаНомеров';ru='Средняя доходность номера';de='Durchschnittliche Rentabilität des Zimmers'");
		vNewStr.IndexKey = vNewStr.IndexName;
		vNewStr.IndexValue = vAvgRoomIncome;
		vNewStr.IndexPresentation = ?(vAvgRoomIncome = 0, vAvgRoomIncome, cmFormatSum(vAvgRoomIncome, vReportingCurrency));
	Else
		vOccupationBeds = Round(?((vBedsForSale + vSpecBedsBlocked) <> 0, 100*(vBedsRented + vSpecBedsBlocked)/(vBedsForSale + vSpecBedsBlocked), 0), 2);
		
		vNewStr = IndexesTable.Add();
		vNewStr.IndexName = Tabulation + NStr("ru = '% Загрузки по проданным местам'; en = 'Occupation % by beds rented'; de = 'Occupation % by beds rented'");
		vNewStr.IndexKey = vNewStr.IndexName;
		vNewStr.IndexValue = vOccupationBeds;
		vNewStr.IndexPresentation = String(vOccupationBeds)+"%";		
		
		vAvgBedPrice = Round(?(vBedsRented <> 0, vRoomsIncome/vBedsRented, 0), 2);	
		vAvgBedPriceInclAddSrv = Round(?(vBedsRented <> 0, vTotalIncome/vBedsRented, 0), 2);		
		vAvgBedIncome = Round(?((vBedsForSale + vSpecBedsBlocked) <> 0, vRoomsIncome/(vBedsForSale + vSpecBedsBlocked), 0), 2);	
		
		vNewStr = IndexesTable.Add();
		vNewStr.IndexName = Tabulation + NStr("en='Average bed price';ru='Средняя цена места';de='Durchschnittspreis eines Platzes'");
		vNewStr.IndexKey = vNewStr.IndexName;
		vNewStr.IndexValue = vAvgBedPrice;
		vNewStr.IndexPresentation = ?(vAvgBedPrice = 0, vAvgBedPrice, cmFormatSum(vAvgBedPrice, vReportingCurrency));
		
		vNewStr = IndexesTable.Add();
		vNewStr.IndexName = Tabulation + NStr("en='Avg. price incl. add. services';ru='Ср. цена с доп. услугами';de='Durchschnittspreis mit zusätzlichen Dienstleistungen'");
		vNewStr.IndexKey = vNewStr.IndexName;
		vNewStr.IndexValue = vAvgBedPriceInclAddSrv;
		vNewStr.IndexPresentation = ?(vAvgBedPriceInclAddSrv = 0, vAvgBedPriceInclAddSrv, cmFormatSum(vAvgBedPriceInclAddSrv, vReportingCurrency));
		
		vNewStr = IndexesTable.Add();
		vNewStr.IndexName = Tabulation + NStr("en='Revenue per available bed';ru='Средняя доходность места';de='Durchschnittliche Rentabilität des Platzes'");
		vNewStr.IndexKey = vNewStr.IndexName;
		vNewStr.IndexValue = vAvgBedIncome;
		vNewStr.IndexPresentation = ?(vAvgBedIncome = 0, vAvgBedIncome, cmFormatSum(vAvgBedIncome, vReportingCurrency));
	EndIf;
	
	// 2. Guests summary indexes
	
	vNewStr = IndexesTable.Add();
	vNewStr.IndexPicture = PictureLib.Клиенты;
	vNewStr.IndexName = NStr("en='GUESTS SUMMARY INDEXES';ru='СТАТИСТИКА ПО ГОСТЯМ';de='STATISTIK NACH GÄSTEN'");
	vNewStr.IndexKey = vNewStr.IndexName;
	
	// Run query to get number of guest days
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	ОборотыПродажиНомеров.Period AS Period,
	|	ОборотыПродажиНомеров.ТипКлиента AS ТипКлиента,
	|	SUM(ОборотыПродажиНомеров.GuestDaysTurnover) AS GuestDaysTurnover,
	|	SUM(ОборотыПродажиНомеров.GuestsCheckedInTurnover) AS GuestsCheckedInTurnover
	|FROM
	|	AccumulationRegister.Продажи.Turnovers(&qPeriodFrom, &qPeriodTo, Day, Гостиница IN HIERARCHY (&qHotel)) AS ОборотыПродажиНомеров
	|GROUP BY
	|	ОборотыПродажиНомеров.Period,
	|	ОборотыПродажиНомеров.ТипКлиента
	|ORDER BY
	|	Period,
	|	ТипКлиента";
	vQry.SetParameter("qPeriodFrom", vBegOfPeriod);
	vQry.SetParameter("qPeriodTo", vEndOfPeriod);
	vQry.SetParameter("qHotel", Гостиница);
	vQryResult = vQry.Execute().Unload();
	
	// Add forecast guests if period is set in the future
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	RoomSalesForecastTurnovers.Period AS Period,
	|	RoomSalesForecastTurnovers.ТипКлиента AS ТипКлиента,
	|	SUM(RoomSalesForecastTurnovers.GuestDaysTurnover) AS GuestDaysTurnover,
	|	SUM(RoomSalesForecastTurnovers.GuestsCheckedInTurnover) AS GuestsCheckedInTurnover
	|FROM
	|	AccumulationRegister.ПрогнозПродаж.Turnovers(&qPeriodFrom, &qPeriodTo, Day, Гостиница IN HIERARCHY (&qHotel)) AS RoomSalesForecastTurnovers
	|GROUP BY
	|	RoomSalesForecastTurnovers.Period,
	|	RoomSalesForecastTurnovers.ТипКлиента
	|ORDER BY
	|	Period,
	|	ТипКлиента";
	vQry.SetParameter("qPeriodFrom", vBegOfPeriod);
	vQry.SetParameter("qPeriodTo", vEndOfPeriod);
	vQry.SetParameter("qHotel", Гостиница);
	vForecastQryResult = vQry.Execute().Unload();
	
	// Merge forecast guests with real ones
	For Each vForecastRow In vForecastQryResult Do
		vFound = False;
		For Each vRow In vQryResult Do
			If vRow.Period = vForecastRow.Period And
				vRow.ClientType = vForecastRow.ClientType Тогда
				vFound = True;
				Break;
			EndIf;
		EndDo;
		If НЕ vFound Тогда
			vRow = vQryResult.Add();
			vRow.Period = vForecastRow.Period;
			vRow.ТипКлиента = vForecastRow.ClientType;
			vRow.GuestDaysTurnover = 0;
			vRow.GuestsCheckedInTurnover = 0;
		EndIf;
		vRow.GuestDaysTurnover = vRow.GuestDaysTurnover + vForecastRow.GuestDaysTurnover;
		vRow.GuestsCheckedInTurnover = vRow.GuestsCheckedInTurnover + vForecastRow.GuestsCheckedInTurnover;
	EndDo;
	
	vNewStr = IndexesTable.Add();
	vNewStr.IndexName = Tabulation + NStr("en='Guest days';ru='Человеко-дни';de='Personentage'");
	vNewStr.IndexKey = vNewStr.IndexName;
	
	// Put client types
	vClientTypes = vQryResult.Copy();
	vClientTypes.GroupBy("ТипКлиента", );
	vTotalCheckedInGuests = 0;
	vTotalGuests = 0;
	ExpTotalGuests = 0;
	MoreThanOneRecord = False;
	For Each vRow In vClientTypes Do
		vClientType = vRow.ClientType;
		
		// Get records for the current client type only
		vQrySubresult = vQryResult.FindRows(New Structure("ТипКлиента", vClientType));
		GetQResultTableTotals(PeriodTo, vQrySubresult, vQryResult, "GuestDaysTurnover, GuestsCheckedInTurnover", False);
		vGuests = cmCastToNumber(TotalPerDay.GuestDaysTurnover);
		vTotalCheckedInGuests = vTotalCheckedInGuests + cmCastToNumber(TotalPerDay.GuestsCheckedInTurnover);
		vTotalGuests = vTotalGuests + cmCastToNumber(TotalPerDay.GuestDaysTurnover);
		
		vNewStr = IndexesTable.Add();
		vNewStr.IndexName = Tabulation + "   " + vClientType;
		vNewStr.IndexKey = vClientType;
		vNewStr.IndexValue = vGuests;
		vNewStr.IndexPresentation = Round(vGuests);
		vNewStr.SecondDateIndexValue = 0;
		vNewStr.SecondDateIndexPresentation = 0;
	EndDo;
	ExpTotalGuests = Round(vTotalGuests);
	// Put client type totals
	If vClientTypes.Count() > 1 Тогда
		MoreThanOneRecord = True;
		vNewStr = IndexesTable.Add();
		vNewStr.IndexName = Tabulation + NStr("en='TOTAL';ru='ВСЕГО';de='GESAMT'");
		vNewStr.IndexKey = NStr("en='Total guest days';ru='Всего человеко-дней';de='Gesamt Manntage'");
		vNewStr.IndexValue = vTotalGuests;
		vNewStr.IndexPresentation = Round(vTotalGuests);
	EndIf;
	
	// Put guests statistics
	If vInRooms Тогда
		vAvgNumberOfGuests = Round(?(vRoomsRented <> 0, vTotalGuests/vRoomsRented, 0), 2);
	Else
		vAvgNumberOfGuests = Round(?(vBedsRented <> 0, vTotalGuests/vBedsRented, 0), 2);
	EndIf;
	vAvgGuestLengthOfStay = Round(?(vTotalCheckedInGuests <> 0, vTotalGuests/vTotalCheckedInGuests, 0), 2);
	vAvgGuestPrice = Round(?(vTotalGuests <> 0, vRoomsIncome/vTotalGuests, 0), 2);
	vAvgGuestIncome = Round(?(vTotalGuests <> 0, vTotalIncome/vTotalGuests, 0), 2);
	
	vNewStr = IndexesTable.Add();
	vNewStr.IndexName = Tabulation + NStr("en='Average number of guests per ГруппаНомеров';ru='Среднее число гостей в номере';de='Durchschnittliche Gästezahl im Zimmer'");
	vNewStr.IndexKey = vNewStr.IndexName;
	vNewStr.IndexValue = vAvgNumberOfGuests;
	vNewStr.IndexPresentation = vAvgNumberOfGuests;
	
	vNewStr = IndexesTable.Add();
	vNewStr.IndexName = Tabulation + NStr("en='Average guest length of stay in days';ru='Средняя прод. прож. в днях';de='Durchschnittliche Aufenthaltsdauer in Tagen'");
	vNewStr.IndexKey = vNewStr.IndexName;
	vNewStr.IndexValue = vAvgGuestLengthOfStay;
	vNewStr.IndexPresentation = vAvgGuestLengthOfStay;
	
	vNewStr = IndexesTable.Add();
	vNewStr.IndexName = Tabulation + NStr("en='Average guest price';ru='Средняя цена на гостя';de='Durchschnittspreis pro Gast'");
	vNewStr.IndexKey = vNewStr.IndexName;
	vNewStr.IndexValue = vAvgGuestPrice;
	vNewStr.IndexPresentation = ?(vAvgGuestPrice = 0, vAvgGuestPrice, cmFormatSum(vAvgGuestPrice, vReportingCurrency));
	
	vNewStr = IndexesTable.Add();
	vNewStr.IndexName = Tabulation + NStr("en='Average guest income';ru='Средний доход с гостя';de='Durchschnittliche Einnahmen pro Gast'");
	vNewStr.IndexKey = vNewStr.IndexName;
	vNewStr.IndexValue = vAvgGuestIncome;
	vNewStr.IndexPresentation = ?(vAvgGuestIncome = 0, vAvgGuestIncome, cmFormatSum(vAvgGuestIncome, vReportingCurrency));
	
	// 3. Check-in summary indexes
	
	vNewStr = IndexesTable.Add();
	vNewStr.IndexPicture = PictureLib.Empty;
	vNewStr.IndexName = NStr("en='CHECK-IN SUMMARY INDEXES';ru='СТАТИСТИКА ПО ЗАЕЗДУ';de='STATISTIK NACH ANREISE'");
	vNewStr.IndexKey = vNewStr.IndexName;
	// Run query to get number of checked-in guests
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	ОборотыПродажиНомеров.Period AS Period,
	|	ОборотыПродажиНомеров.ДокОснование.РазмПоБрони AS ParentDocIsByReservation,
	|	SUM(ОборотыПродажиНомеров.GuestsCheckedInTurnover) AS GuestsCheckedInTurnover
	|FROM
	|	AccumulationRegister.Продажи.Turnovers(&qPeriodFrom, &qPeriodTo, Day, Гостиница IN HIERARCHY (&qHotel)) AS ОборотыПродажиНомеров
	|GROUP BY
	|	ОборотыПродажиНомеров.Period,
	|	ОборотыПродажиНомеров.ДокОснование.РазмПоБрони
	|ORDER BY
	|	Period,
	|	ParentDocIsByReservation";
	vQry.SetParameter("qPeriodFrom", vBegOfPeriod);
	vQry.SetParameter("qPeriodTo", vEndOfPeriod);
	vQry.SetParameter("qHotel", Гостиница);
	vQryResult = vQry.Execute().Unload();
	
	// Add forecast guests if period is set in the future
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	RoomSalesForecastTurnovers.Period AS Period,
	|	TRUE AS ParentDocIsByReservation,
	|	SUM(RoomSalesForecastTurnovers.GuestsCheckedInTurnover) AS GuestsCheckedInTurnover
	|FROM
	|	AccumulationRegister.ПрогнозПродаж.Turnovers(&qPeriodFrom, &qPeriodTo, Day, Гостиница IN HIERARCHY (&qHotel)) AS RoomSalesForecastTurnovers
	|GROUP BY
	|	RoomSalesForecastTurnovers.Period
	|ORDER BY
	|	Period,
	|	ParentDocIsByReservation";
	vQry.SetParameter("qPeriodFrom", vBegOfPeriod);
	vQry.SetParameter("qPeriodTo", vEndOfPeriod);
	vQry.SetParameter("qHotel", Гостиница);
	vForecastQryResult = vQry.Execute().Unload();
	
	// Merge forecast guests with real ones
	For Each vForecastRow In vForecastQryResult Do
		vFound = False;
		For Each vRow In vQryResult Do
			If vRow.Period = vForecastRow.Period And
				vRow.ParentDocIsByReservation = vForecastRow.ParentDocIsByReservation Тогда
				vFound = True;
				Break;
			EndIf;
		EndDo;
		If НЕ vFound Тогда
			vRow = vQryResult.Add();
			vRow.Period = vForecastRow.Period;
			vRow.ParentDocIsByReservation = vForecastRow.ParentDocIsByReservation;
			vRow.GuestsCheckedInTurnover = 0;
		EndIf;
		vRow.GuestsCheckedInTurnover = vRow.GuestsCheckedInTurnover + vForecastRow.GuestsCheckedInTurnover;
	EndDo;
	
	// Split table to walk-in and check-in by reservation
	vQryResultWalkInArray = vQryResult.Copy().FindRows(New Structure("ParentDocIsByReservation", False));
	vQryResultResArray = vQryResult.Copy().FindRows(New Structure("ParentDocIsByReservation", True));
	vQryResultWalkIn = vQryResult.CopyColumns();
	For Each vRow In vQryResultWalkInArray Do
		vTabRow = vQryResultWalkIn.Add();
		FillPropertyValues(vTabRow, vRow);
	EndDo;
	vQryResultWalkIn.GroupBy("Period", "GuestsCheckedInTurnover");
	vQryResultRes = vQryResult.CopyColumns();
	For Each vRow In vQryResultResArray Do
		vTabRow = vQryResultRes.Add();
		FillPropertyValues(vTabRow, vRow);
	EndDo;
	vQryResultRes.GroupBy("Period", "GuestsCheckedInTurnover");
	GetQResultTableTotals(PeriodTo, vQryResultRes, vQryResultRes, "GuestsCheckedInTurnover", False);
	vGuestsReserved = cmCastToNumber(TotalPerDay.GuestsCheckedInTurnover);
	
	vNewStr = IndexesTable.Add();
	vNewStr.IndexName = Tabulation + NStr("en='Guests reserved and checked-in';ru='Заезд гостей по брони';de='Anreise der Gäste nach der Reservierung'");
	vNewStr.IndexKey = vNewStr.IndexName;
	vNewStr.IndexValue = vGuestsReserved;
	vNewStr.IndexPresentation = vGuestsReserved;
	
	// Put walk-in
	GetQResultTableTotals(PeriodTo, vQryResultWalkIn, vQryResultWalkIn, "GuestsCheckedInTurnover", False);
	vGuestsWalkIn = cmCastToNumber(TotalPerDay.GuestsCheckedInTurnover);
	
	vNewStr = IndexesTable.Add();
	vNewStr.IndexName = Tabulation + NStr("en='Guests walk-in';ru='Заезд без брони';de='Anreise ohne Reservierung'");
	vNewStr.IndexKey = vNewStr.IndexName;
	vNewStr.IndexValue = vGuestsWalkIn;
	vNewStr.IndexPresentation = vGuestsWalkIn;
	
	// 4. Income summary indexes
	
	vNewStr = IndexesTable.Add();
	vNewStr.IndexPicture = PictureLib.Totals;
	vNewStr.IndexName = NStr("en='INCOME SUMMARY INDEXES';ru='СТАТИСТИКА ПО ДОХОДАМ';de='STATISTIK NACH EINNAHMEN'");
	vNewStr.IndexKey = vNewStr.IndexName;
	
	// Put total sales
	vNewStr = IndexesTable.Add();
	vNewStr.IndexName = Tabulation + NStr("en='Rooms Revenue';ru='Доход от продажи номеров';de='Erlös aus den Zimmerverkauf'");
	vNewStr.IndexKey = vNewStr.IndexName;
	vNewStr.IndexValue = vRoomsIncome;
	vNewStr.IndexPresentation = ?(vRoomsIncome = 0, vRoomsIncome, cmFormatSum(vRoomsIncome, vReportingCurrency));
	
	vNewStr = IndexesTable.Add();
	vNewStr.IndexName = Tabulation + NStr("en='Other Income';ru='Прочий доход';de='Sonstige Einnahmen'");
	vNewStr.IndexKey = vNewStr.IndexName;
	vNewStr.IndexValue = vOtherIncome;	
	vNewStr.IndexPresentation = ?(vOtherIncome = 0, vOtherIncome, cmFormatSum(vOtherIncome, vReportingCurrency));
	
	vNewStr = IndexesTable.Add();
	vNewStr.IndexPicture = PictureLib.Empty;
	vNewStr.IndexName = NStr("en='SERVICE TYPES SUMMARY INDEXES';ru='СТАТИСТИКА ПО ТИПАМ УСЛУГ';de='STATISTIK NACH DIENSTLEISTUNGSSTYPEN'");
	vNewStr.IndexKey = vNewStr.IndexName;
	
	// Put sales by service types
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	ServiceSales.Period AS Period,
	|	ServiceSales.ServiceType AS ServiceType,
	|	SUM(ServiceSales.SumTurnover) AS SumTurnover,
	|	SUM(ServiceSales.SumWithoutVATTurnover) AS SumWithoutVATTurnover
	|FROM
	|	(SELECT
	|		ServiceSalesTurnovers.Period AS Period,
	|		ServiceSalesTurnovers.Услуга.ServiceType AS ServiceType,
	|		ServiceSalesTurnovers.SalesTurnover AS SumTurnover,
	|		ServiceSalesTurnovers.SalesWithoutVATTurnover AS SumWithoutVATTurnover
	|	FROM
	|		AccumulationRegister.Продажи.Turnovers(&qPeriodFrom, &qPeriodTo, Day, Гостиница IN HIERARCHY (&qHotel)) AS ServiceSalesTurnovers
	|	
	|	UNION ALL
	|	
	|	SELECT
	|		ServiceSalesForecastTurnovers.Period,
	|		ServiceSalesForecastTurnovers.Услуга.ServiceType,
	|		ServiceSalesForecastTurnovers.SalesTurnover,
	|		ServiceSalesForecastTurnovers.SalesWithoutVATTurnover
	|	FROM
	|		AccumulationRegister.ПрогнозПродаж.Turnovers(&qForecastPeriodFrom, &qForecastPeriodTo, Day, Гостиница IN HIERARCHY (&qHotel)) AS ServiceSalesForecastTurnovers) AS ServiceSales
	|
	|GROUP BY
	|	ServiceSales.Period,
	|	ServiceSales.ServiceType
	|
	|ORDER BY
	|	Period,
	|	ServiceSales.ServiceType.ПорядокСортировки";
	vQry.SetParameter("qPeriodFrom", vBegOfPeriod);
	vQry.SetParameter("qPeriodTo", vEndOfPeriod);
	vQry.SetParameter("qForecastPeriodFrom", vBegOfPeriod);
	vQry.SetParameter("qForecastPeriodTo", vEndOfPeriod);
	vQry.SetParameter("qHotel", Гостиница);
	vQryResult = vQry.Execute().Unload();
	
	// Get list of service types
	vServiceTypes = vQryResult.Copy();
	vServiceTypes.GroupBy("ServiceType", );
	
	If vServiceTypes.Count() > 1 Тогда
		// Put service types summary
		For Each vRow In vServiceTypes Do
			vServiceType = vRow.ServiceType;
			
			vNewStr = IndexesTable.Add();
			vNewStr.IndexName = Tabulation + "   "+vServiceType;
			vNewStr.IndexKey = vNewStr.IndexName;
			// Get records for the current service type only
			vQrySubresult = vQryResult.FindRows(New Structure("ServiceType", vServiceType));
			GetQResultTableTotals(PeriodTo, vQrySubresult, vQryResult, "SumTurnover, SumWithoutVATTurnover", False);
			If vWithVAT Тогда
				vServiceTypeIncome = cmCastToNumber(TotalPerDay.SumTurnover);
			Else
				vServiceTypeIncome = cmCastToNumber(TotalPerDay.SumWithoutVATTurnover);
			EndIf;
			vNewStr.IndexValue = vServiceTypeIncome;
			vNewStr.IndexPresentation = ?(vServiceTypeIncome = 0, vServiceTypeIncome, cmFormatSum(vServiceTypeIncome, vReportingCurrency));
			vNewStr.SecondDateIndexValue = 0;
			vNewStr.SecondDateIndexPresentation = 0;
		EndDo;
	EndIf;
	vNewStr = IndexesTable.Add();
	vNewStr.IndexName = Tabulation + NStr("en='Total Income';ru='Общий доход';de='Gesamteinkommen'");
	vNewStr.IndexKey = NStr("en='SEVICE TYPE TOTALS';ru='ИТОГИ ПО ТИПАМ УСЛУГ';de='ERGEBNISSE NACH DIENSTLEISTUNGSTYPEN'");
	vNewStr.IndexValue = vTotalIncome;
	vNewStr.IndexPresentation = ?(vTotalIncome = 0, vTotalIncome, cmFormatSum(vTotalIncome, vReportingCurrency));
	
	// 5. Payments summary indexes
	
	vNewStr = IndexesTable.Add();
	vNewStr.IndexPicture = PictureLib.ToBePaid;
	vNewStr.IndexName = NStr("en='PAYMENTS SUMMARY INDEXES';ru='СТАТИСТИКА ПО ПЛАТЕЖАМ';de='STATISTIK NACH ZAHLUNGEN'");
	vNewStr.IndexKey = vNewStr.IndexName;
	
	// Run query to get payments by payment method
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	PaymentsTurnovers.СпособОплаты AS СпособОплаты,
	|	PaymentsTurnovers.Period AS Period,
	|	SUM(PaymentsTurnovers.SumTurnover) AS SumTurnover,
	|	SUM(PaymentsTurnovers.VATSumTurnover) AS VATSumTurnover
	|FROM
	|	AccumulationRegister.Платежи.Turnovers(&qPeriodFrom, &qPeriodTo, Day, Гостиница IN HIERARCHY (&qHotel)) AS PaymentsTurnovers
	|GROUP BY
	|	PaymentsTurnovers.Period,
	|	PaymentsTurnovers.СпособОплаты
	|ORDER BY
	|	СпособОплаты,
	|	Period";
	vQry.SetParameter("qPeriodFrom", vBegOfPeriod);
	vQry.SetParameter("qPeriodTo", vEndOfPeriod);
	vQry.SetParameter("qHotel", Гостиница);
	vQryResult = vQry.Execute().Unload();
	
	// Get list of payment methods
	vPaymentMethods = vQryResult.Copy();
	vPaymentMethods.GroupBy("СпособОплаты", );
	
	// Put payment methods summary
	vTotalPaymentsPerDay = 0;
	For Each vRow In vPaymentMethods Do
		vPaymentMethod = vRow.PaymentMethod;
		If vPaymentMethod = Справочники.СпособОплаты.Акт Тогда
			Continue;
		EndIf;
		
		// Get records for the current payment method only
		vQrySubresult = vQryResult.FindRows(New Structure("СпособОплаты", vPaymentMethod));
		GetQResultTableTotals(PeriodTo, vQrySubresult, vQryResult, "SumTurnover, VATSumTurnover", False);
		vSumTurnover = cmCastToNumber(TotalPerDay.SumTurnover);
		
		vNewStr = IndexesTable.Add();
		vNewStr.IndexName = Tabulation+vPaymentMethod;
		vNewStr.IndexKey = vPaymentMethod;
		vNewStr.IndexValue = vSumTurnover;
		vNewStr.IndexPresentation = ?(vSumTurnover = 0, vSumTurnover, cmFormatSum(vSumTurnover, vReportingCurrency));
		vNewStr.SecondDateIndexValue = 0;
		vNewStr.SecondDateIndexPresentation = 0;
		
		vTotalPaymentsPerDay = vTotalPaymentsPerDay + cmCastToNumber(TotalPerDay.SumTurnover);
	EndDo;
	
	// Payments footer
	vNewStr = IndexesTable.Add();
	vNewStr.IndexName = Tabulation + NStr("en='Total payments';ru='Всего платежей';de='Gesamt Zahlungen'");
	vNewStr.IndexKey = vNewStr.IndexName;
	vNewStr.IndexValue = vTotalPaymentsPerDay;
	vNewStr.IndexPresentation = ?(vTotalPaymentsPerDay = 0, vTotalPaymentsPerDay, cmFormatSum(vTotalPaymentsPerDay, vReportingCurrency));
КонецПроцедуры //GetRooms

//-------------------------------------------------------------------------------------------------
&AtServer
Процедура GetCompareRooms()
	GetRooms();
	
	// Check period choosen now
	If Items.PeriodDay.Visible Тогда
		vBegOfPeriodNow = BegOfDay(PeriodTo);
		vEndOfPeriodNow = EndOfDay(PeriodTo);
	ElsIf Items.SelQuarter.Visible Тогда
		vBegOfPeriodNow = BegOfQuarter(CompositionDate);
		vEndOfPeriodNow = EndOfQuarter(CompositionDate);
	ElsIf Items.SelMonth.Visible Тогда
		vBegOfPeriodNow = BegOfMonth(CompositionDate);
		vEndOfPeriodNow = EndOfMonth(CompositionDate);
	Else
		vBegOfPeriodNow = BegOfYear(CompositionDate);
		vEndOfPeriodNow = EndOfYear(CompositionDate);
	EndIf;
	
	// Check period choosen
	If Items.PeriodDay.Visible Тогда
		vBegOfPeriod = BegOfDay(CompareDate);
		vEndOfPeriod = EndOfDay(CompareDate);
	ElsIf Items.CompareQuarter.Visible Тогда
		vBegOfPeriod = BegOfQuarter(CompareCompositionDate);
		vEndOfPeriod = EndOfQuarter(CompareCompositionDate);
	ElsIf Items.CompareMonth.Visible Тогда
		vBegOfPeriod = BegOfMonth(CompareCompositionDate);
		vEndOfPeriod = EndOfMonth(CompareCompositionDate);
	Else
		vBegOfPeriod = BegOfYear(CompareCompositionDate);
		vEndOfPeriod = EndOfYear(CompareCompositionDate);
	EndIf;
	
	// Initialize reporting currency
	vReportingCurrency = Гостиница.Валюта;
	If НЕ ЗначениеЗаполнено(Гостиница) Тогда
		Return;
	EndIf;
	
	vInRooms = True;
	vWithVAT = True;
	If ЗначениеЗаполнено(Гостиница) Тогда
		vInRooms = НЕ Гостиница.ShowReportsInBeds;
		vWithVAT = Гостиница.ShowSalesInReportsWithVAT;
	EndIf;
	
	// Run query to get total number of rooms, rooms blocked, vacant number of rooms
	vTempInd = 0;
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	RoomInventoryBalanceAndTurnovers.Period AS Period,
	|	SUM(RoomInventoryBalanceAndTurnovers.CounterClosingBalance) AS CounterClosingBalance,
	|	SUM(RoomInventoryBalanceAndTurnovers.TotalRoomsClosingBalance) AS TotalRoomsClosingBalance,
	|	SUM(RoomInventoryBalanceAndTurnovers.TotalBedsClosingBalance) AS TotalBedsClosingBalance,
	|	-SUM(RoomInventoryBalanceAndTurnovers.RoomsBlockedClosingBalance) AS RoomsBlockedClosingBalance,
	|	-SUM(RoomInventoryBalanceAndTurnovers.BedsBlockedClosingBalance) AS BedsBlockedClosingBalance
	|FROM
	|	AccumulationRegister.ЗагрузкаНомеров.BalanceAndTurnovers(&qPeriodFrom, &qPeriodTo, Day, RegisterRecordsAndPeriodBoundaries, Гостиница IN HIERARCHY (&qHotel)) AS RoomInventoryBalanceAndTurnovers
	|GROUP BY
	|	RoomInventoryBalanceAndTurnovers.Period
	|ORDER BY
	|	Period";
	vQry.SetParameter("qPeriodFrom", vBegOfPeriod);
	vQry.SetParameter("qPeriodTo", vEndOfPeriod);
	vQry.SetParameter("qHotel", Гостиница);
	vQryResult = vQry.Execute().Unload();
	
	vResources = "TotalRoomsClosingBalance, TotalBedsClosingBalance, RoomsBlockedClosingBalance, BedsBlockedClosingBalance";
	GetQResultTableTotals(CompareDate, vQryResult, vQryResult, vResources);
	vTotalRooms = cmCastToNumber(TotalPerDay.TotalRoomsClosingBalance);
	vTotalBeds = cmCastToNumber(TotalPerDay.TotalBedsClosingBalance);
	
	// Put total rooms/beds
	vTempInd = 1;
	vStr = IndexesTable.Get(vTempInd);
	If vInRooms Тогда
		vStr.SecondDateIndexValue = vTotalRooms;
		vStr.SecondDateIndexPresentation = vTotalRooms;
	Else
		vStr.SecondDateIndexValue = vTotalBeds;
		vStr.SecondDateIndexPresentation = vTotalBeds;
	EndIf;
	vBlockedRooms = cmCastToNumber(TotalPerDay.RoomsBlockedClosingBalance);
	vBlockedBeds = cmCastToNumber(TotalPerDay.BedsBlockedClosingBalance);
	vRoomsForSale = vTotalRooms - vBlockedRooms;
	vBedsForSale = vTotalBeds - vBlockedBeds;
	
	// Run query to get number of blocked rooms per ГруппаНомеров block types
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	RoomBlocksBalanceAndTurnovers.RoomBlockType AS RoomBlockType,
	|	RoomBlocksBalanceAndTurnovers.Period AS Period,
	|	SUM(RoomBlocksBalanceAndTurnovers.RoomsBlockedClosingBalance) AS RoomsBlockedClosingBalance,
	|	SUM(RoomBlocksBalanceAndTurnovers.BedsBlockedClosingBalance) AS BedsBlockedClosingBalance
	|FROM
	|	AccumulationRegister.БлокирНомеров.BalanceAndTurnovers(&qPeriodFrom, &qPeriodTo, Day, RegisterRecordsAndPeriodBoundaries, Гостиница IN HIERARCHY (&qHotel)) AS RoomBlocksBalanceAndTurnovers
	|
	|GROUP BY
	|	RoomBlocksBalanceAndTurnovers.RoomBlockType,
	|	RoomBlocksBalanceAndTurnovers.Period
	|
	|ORDER BY
	|	RoomBlocksBalanceAndTurnovers.RoomBlockType.ПорядокСортировки,
	|	Period";
	vQry.SetParameter("qPeriodFrom", vBegOfPeriod);
	vQry.SetParameter("qPeriodTo", vEndOfPeriod);
	vQry.SetParameter("qHotel", Гостиница);
	vQryResult = vQry.Execute().Unload();
	
	// Get list of ГруппаНомеров block types
	vRoomBlockTypes = vQryResult.Copy();
	vRoomBlockTypes.GroupBy("RoomBlockType", );
	
	// Do for each ГруппаНомеров block type
	vSpecRoomsBlocked = 0;
	vSpecBedsBlocked = 0;
	If vQryResult.Count() > 0 Тогда
		// Put ГруппаНомеров blocks per ГруппаНомеров block type
		For Each vRow In vRoomBlockTypes Do
			vRoomBlockType = vRow.RoomBlockType;
			
			vExistingStr = Неопределено;
			vExistingRows = IndexesTable.FindRows(New Structure("IndexKey", vRoomBlockType.Description));
			If vExistingRows.Count() > 0 Тогда
				vExistingStr = vExistingRows.Get(0);
			EndIf;
			
			// Get records for the current ГруппаНомеров block type only
			vQrySubresult = vQryResult.FindRows(New Structure("RoomBlockType", vRoomBlockType));
			GetQResultTableTotals(CompareDate, vQrySubresult, vQryResult, "RoomsBlockedClosingBalance, BedsBlockedClosingBalance");
			If vExistingStr = Неопределено Тогда
				vTempInd = vTempInd + 1;
				
				vNewStr = IndexesTable.Вставить(vTempInd);
				vNewStr.IndexName = Tabulation + vRoomBlockType;
				vNewStr.IndexKey = vRoomBlockType;
				vNewStr.IndexValue = 0;
				vNewStr.IndexPresentation = 0;
				
				If vInRooms Тогда
					vBlockedRooms = cmCastToNumber(TotalPerDay.RoomsBlockedClosingBalance);
					vNewStr.SecondDateIndexValue = vBlockedRooms;
					vNewStr.SecondDateIndexPresentation = vBlockedRooms;
					If vRoomBlockType.AddToRoomsRentedInSummaryIndexes Тогда
						vSpecRoomsBlocked = vSpecRoomsBlocked + cmCastToNumber(TotalPerDay.RoomsBlockedClosingBalance);
					EndIf;
				Else
					vBlockedBeds = cmCastToNumber(TotalPerDay.BedsBlockedClosingBalance);
					vNewStr.SecondDateIndexValue = vBlockedBeds;
					vNewStr.SecondDateIndexPresentation = vBlockedBeds;
					If vRoomBlockType.AddToRoomsRentedInSummaryIndexes Тогда
						vSpecBedsBlocked = vSpecBedsBlocked + cmCastToNumber(TotalPerDay.BedsBlockedClosingBalance);
					EndIf;
				EndIf;
			Else
				vTempInd = IndexesTable.IndexOf(vExistingStr);
				
				If vInRooms Тогда
					vBlockedRooms = cmCastToNumber(TotalPerDay.RoomsBlockedClosingBalance);
					vExistingStr.SecondDateIndexValue = vBlockedRooms;
					vExistingStr.SecondDateIndexPresentation = vBlockedRooms;
					If vRoomBlockType.AddToRoomsRentedInSummaryIndexes Тогда
						vSpecRoomsBlocked = vSpecRoomsBlocked + cmCastToNumber(TotalPerDay.RoomsBlockedClosingBalance);
					EndIf;
				Else
					vBlockedBeds = cmCastToNumber(TotalPerDay.BedsBlockedClosingBalance);
					vExistingStr.SecondDateIndexValue = vBlockedBeds;
					vExistingStr.SecondDateIndexPresentation = vBlockedBeds;
					If vRoomBlockType.AddToRoomsRentedInSummaryIndexes Тогда
						vSpecBedsBlocked = vSpecBedsBlocked + cmCastToNumber(TotalPerDay.BedsBlockedClosingBalance);
					EndIf;
				EndIf;
			EndIf;
		EndDo;
	Else
		vExistingStr = Неопределено;
		vExistingRows = IndexesTable.FindRows(New Structure("IndexKey", NStr("en='Repaired';ru='Ремонт';de='Reparatur'")));
		If vExistingRows.Count() > 0 Тогда
			vExistingStr = vExistingRows.Get(0);
		EndIf;
		If vExistingStr = Неопределено Тогда
			vTempInd = 2;
			vNewStr = IndexesTable.Вставить(vTempInd);
			vNewStr.IndexName = Tabulation + NStr("en='Repaired';ru='Ремонт';de='Reparatur'");
			vNewStr.IndexKey = NStr("en='Repaired';ru='Ремонт';de='Reparatur'");
			vNewStr.IndexValue = 0;
			vNewStr.IndexPresentation = 0;
			vNewStr.SecondDateIndexValue = 0;
			vNewStr.SecondDateIndexPresentation = 0;
		Else
			vTempInd = IndexesTable.IndexOf(vExistingStr);
			
			vExistingStr.SecondDateIndexValue = 0;
			vExistingStr.SecondDateIndexPresentation = 0;
		EndIf;
	EndIf;
	
	// Put rooms for sale
	vIndexKey = ?(vInRooms, Tabulation + NStr("en='Rooms For Sale';ru='Номеров к продаже';de='Zimmer im Verkauf'"), Tabulation + NStr("en='Beds For Sale';ru='Мест к продаже';de='Betten für den Verkauf'"));
	vIndexValue = ?(vInRooms, vRoomsForSale + vSpecRoomsBlocked, vBedsForSale + vSpecBedsBlocked);
	vExistingStr = Неопределено;
	vExistingRows = IndexesTable.FindRows(New Structure("IndexKey", vIndexKey));
	If vExistingRows.Count() > 0 Тогда
		vExistingStr = vExistingRows.Get(0);
	EndIf;
	If vExistingStr = Неопределено Тогда
		vTempInd = vTempInd + 1;
		
		vNewStr = IndexesTable.Вставить(vTempInd);
		vNewStr.IndexName = vIndexKey;
		vNewStr.IndexKey = vIndexKey;
		vNewStr.IndexValue = 0;
		vNewStr.IndexPresentation = 0;
		vNewStr.SecondDateIndexValue = vIndexValue;
		vNewStr.SecondDateIndexPresentation = vIndexValue;
	Else
		vTempInd = IndexesTable.IndexOf(vExistingStr);
		
		vExistingStr.SecondDateIndexValue = vIndexValue;
		vExistingStr.SecondDateIndexPresentation = vIndexValue;
	EndIf;
	
	// Run query to get ГруппаНомеров sales
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	ОборотыПродажиНомеров.Period AS Period,
	|	ОборотыПродажиНомеров.Тариф.IsComplimentary AS RoomRateIsComplimentary,
	|	SUM(ОборотыПродажиНомеров.SalesTurnover) AS SalesTurnover,
	|	SUM(ОборотыПродажиНомеров.SalesWithoutVATTurnover) AS SalesWithoutVATTurnover,
	|	SUM(ОборотыПродажиНомеров.RoomRevenueTurnover) AS RoomRevenueTurnover,
	|	SUM(ОборотыПродажиНомеров.RoomRevenueWithoutVATTurnover) AS RoomRevenueWithoutVATTurnover,
	|	SUM(ОборотыПродажиНомеров.RoomsRentedTurnover) AS RoomsRentedTurnover,
	|	SUM(ОборотыПродажиНомеров.BedsRentedTurnover) AS BedsRentedTurnover
	|FROM
	|	AccumulationRegister.Продажи.Turnovers(&qPeriodFrom, &qPeriodTo, Day, Гостиница IN HIERARCHY (&qHotel)) AS ОборотыПродажиНомеров
	|GROUP BY
	|	ОборотыПродажиНомеров.Period,
	|	ОборотыПродажиНомеров.Тариф.IsComplimentary
	|ORDER BY
	|	Period,
	|	RoomRateIsComplimentary";
	vQry.SetParameter("qPeriodFrom", vBegOfPeriod);
	vQry.SetParameter("qPeriodTo", vEndOfPeriod);
	vQry.SetParameter("qHotel", Гостиница);
	vQryResult = vQry.Execute().Unload();
	
	// Add forecast sales if period is set in the future
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	RoomSalesForecastTurnovers.Period AS Period,
	|	RoomSalesForecastTurnovers.Тариф.IsComplimentary AS RoomRateIsComplimentary,
	|	SUM(RoomSalesForecastTurnovers.SalesTurnover) AS SalesTurnover,
	|	SUM(RoomSalesForecastTurnovers.SalesWithoutVATTurnover) AS SalesWithoutVATTurnover,
	|	SUM(RoomSalesForecastTurnovers.RoomRevenueTurnover) AS RoomRevenueTurnover,
	|	SUM(RoomSalesForecastTurnovers.RoomRevenueWithoutVATTurnover) AS RoomRevenueWithoutVATTurnover,
	|	SUM(RoomSalesForecastTurnovers.RoomsRentedTurnover) AS RoomsRentedTurnover,
	|	SUM(RoomSalesForecastTurnovers.BedsRentedTurnover) AS BedsRentedTurnover
	|FROM
	|	AccumulationRegister.ПрогнозПродаж.Turnovers(&qPeriodFrom, &qPeriodTo, Day, Гостиница IN HIERARCHY (&qHotel)) AS RoomSalesForecastTurnovers
	|GROUP BY
	|	RoomSalesForecastTurnovers.Period,
	|	RoomSalesForecastTurnovers.Тариф.IsComplimentary
	|ORDER BY
	|	Period,
	|	RoomRateIsComplimentary";
	vQry.SetParameter("qPeriodFrom", vBegOfPeriod);
	vQry.SetParameter("qPeriodTo", vEndOfPeriod);
	vQry.SetParameter("qHotel", Гостиница);
	vForecastQryResult = vQry.Execute().Unload();
	
	// Merge forecast sales with real ones
	For Each vForecastRow In vForecastQryResult Do
		vFound = False;
		For Each vRow In vQryResult Do
			If vRow.Period = vForecastRow.Period And
				vRow.RoomRateIsComplimentary = vForecastRow.RoomRateIsComplimentary Тогда
				vFound = True;
				Break;
			EndIf;
		EndDo;
		If НЕ vFound Тогда
			vRow = vQryResult.Add();
			vRow.Period = vForecastRow.Period;
			vRow.RoomRateIsComplimentary = vForecastRow.RoomRateIsComplimentary;
			vRow.SalesTurnover = 0;
			vRow.SalesWithoutVATTurnover = 0;
			vRow.RoomRevenueTurnover = 0;
			vRow.RoomRevenueWithoutVATTurnover = 0;
			vRow.RoomsRentedTurnover = 0;
			vRow.BedsRentedTurnover = 0;
		EndIf;
		vRow.SalesTurnover = vRow.SalesTurnover + vForecastRow.SalesTurnover;
		vRow.SalesWithoutVATTurnover = vRow.SalesWithoutVATTurnover + vForecastRow.SalesWithoutVATTurnover;
		vRow.RoomRevenueTurnover = vRow.RoomRevenueTurnover + vForecastRow.RoomRevenueTurnover;
		vRow.RoomRevenueWithoutVATTurnover = vRow.RoomRevenueWithoutVATTurnover + vForecastRow.RoomRevenueWithoutVATTurnover;
		vRow.RoomsRentedTurnover = vRow.RoomsRentedTurnover + vForecastRow.RoomsRentedTurnover;
		vRow.BedsRentedTurnover = vRow.BedsRentedTurnover + vForecastRow.BedsRentedTurnover;
	EndDo;
	
	vResources = "SalesTurnover, SalesWithoutVATTurnover, RoomRevenueTurnover, RoomRevenueWithoutVATTurnover, RoomsRentedTurnover, BedsRentedTurnover";
	
	// Split table to total and complimentary only
	vQryResultComplArray = vQryResult.Copy().FindRows(New Structure("RoomRateIsComplimentary", True));
	vQryResult.GroupBy("Period", vResources);
	vQryResultCompl = vQryResult.CopyColumns();
	For Each vRow In vQryResultComplArray Do
		vTabRow = vQryResultCompl.Add();
		FillPropertyValues(vTabRow, vRow);
	EndDo;
	vQryResultCompl.GroupBy("Period", vResources);
	
	// Get rooms rented
	GetQResultTableTotals(CompareDate, vQryResult, vQryResult, vResources, False);
	vRoomsRented = cmCastToNumber(TotalPerDay.RoomsRentedTurnover);
	vBedsRented = cmCastToNumber(TotalPerDay.BedsRentedTurnover);
	vIndexKey = ?(vInRooms, Tabulation + NStr("en='Rooms Rented';ru='Продано номеров';de='Verkaufte Zimmer'"), Tabulation + NStr("en='Beds Rented';ru='Продано мест';de='Verkaufte Betten'"));
	vIndexValue = ?(vInRooms, vRoomsRented, vBedsRented);
	
	vExistingStr = Неопределено;
	vExistingRows = IndexesTable.FindRows(New Structure("IndexKey", vIndexKey));
	If vExistingRows.Count() > 0 Тогда
		vExistingStr = vExistingRows.Get(0);
	EndIf;
	If vExistingStr = Неопределено Тогда
		vTempInd = vTempInd + 1;
		
		vNewStr = IndexesTable.Вставить(vTempInd);
		vNewStr.IndexName = vIndexKey;
		vNewStr.IndexKey = vIndexKey;
		vNewStr.IndexValue = 0;
		vNewStr.IndexPresentation = 0;
		vNewStr.SecondDateIndexValue = vIndexValue;
		vNewStr.SecondDateIndexPresentation = Round(vIndexValue);
	Else
		vTempInd = IndexesTable.IndexOf(vExistingStr);
		
		vExistingStr.SecondDateIndexValue = vIndexValue;
		vExistingStr.SecondDateIndexPresentation = Round(vIndexValue);
	EndIf;
	
	
	// Save total sale amounts
	If vWithVAT Тогда
		vRoomsIncome = cmCastToNumber(TotalPerDay.RoomRevenueTurnover);		
		vTotalIncome = cmCastToNumber(TotalPerDay.SalesTurnover);
	Else
		vRoomsIncome = cmCastToNumber(TotalPerDay.RoomRevenueWithoutVATTurnover);		
		vTotalIncome = cmCastToNumber(TotalPerDay.SalesWithoutVATTurnover);
	EndIf;
	vOtherIncome = vTotalIncome - vRoomsIncome;
	
	// Put occupation percent
	vIndexKey = Tabulation + NStr("ru = '% Загрузки по проданным номерам'; en = 'Occupation % by rooms rented'; de = 'Occupation % by rooms rented'");
	vExistingStr = Неопределено;
	vExistingRows = IndexesTable.FindRows(New Structure("IndexKey", vIndexKey));
	If vExistingRows.Count() > 0 Тогда
		vExistingStr = vExistingRows.Get(0);
		vTempInd = IndexesTable.IndexOf(vExistingStr);
	EndIf;
	If vExistingStr <> Неопределено Тогда
		If vInRooms Тогда
			vOccupationRooms = Round(?((vRoomsForSale + vSpecRoomsBlocked) <> 0, 100*(vRoomsRented + vSpecRoomsBlocked)/(vRoomsForSale + vSpecRoomsBlocked), 0), 2);
			vExistingStr.SecondDateIndexValue = vOccupationRooms;
			vExistingStr.SecondDateIndexPresentation = String(vOccupationRooms)+"%";
			
			vAvgRoomPrice = Round(?(vRoomsRented <> 0, vRoomsIncome/vRoomsRented, 0), 2);
			vAvgRoomPriceInclAddSrv = Round(?(vRoomsRented <> 0, vTotalIncome/vRoomsRented, 0), 2);
			vAvgRoomIncome = Round(?((vRoomsForSale + vSpecRoomsBlocked) <> 0, vRoomsIncome/(vRoomsForSale + vSpecRoomsBlocked), 0), 2);
			
			vTempInd = vTempInd + 1;
			vExistingStr = IndexesTable.Get(vTempInd);
			vExistingStr.SecondDateIndexValue = vAvgRoomPrice;
			vExistingStr.SecondDateIndexPresentation = ?(vAvgRoomPrice = 0, vAvgRoomPrice, cmFormatSum(vAvgRoomPrice, vReportingCurrency));
			
			vTempInd = vTempInd + 1;
			vExistingStr = IndexesTable.Get(vTempInd);
			vExistingStr.SecondDateIndexValue = vAvgRoomPriceInclAddSrv;
			vExistingStr.SecondDateIndexPresentation = ?(vAvgRoomPriceInclAddSrv = 0, vAvgRoomPriceInclAddSrv, cmFormatSum(vAvgRoomPriceInclAddSrv, vReportingCurrency));
			
			vTempInd = vTempInd + 1;
			vExistingStr = IndexesTable.Get(vTempInd);
			vExistingStr.SecondDateIndexValue = vAvgRoomIncome;
			vExistingStr.SecondDateIndexPresentation = ?(vAvgRoomIncome = 0, vAvgRoomIncome, cmFormatSum(vAvgRoomIncome, vReportingCurrency));
		Else
			vOccupationBeds = Round(?((vBedsForSale + vSpecBedsBlocked) <> 0, 100*(vBedsRented + vSpecBedsBlocked)/(vBedsForSale + vSpecBedsBlocked), 0), 2);
			vExistingStr.SecondDateIndexValue = vOccupationBeds;
			vExistingStr.SecondDateIndexPresentation = String(vOccupationBeds)+"%";
			
			vAvgBedPrice = Round(?(vBedsRented <> 0, vRoomsIncome/vBedsRented, 0), 2);	
			vAvgBedPriceInclAddSrv = Round(?(vBedsRented <> 0, vTotalIncome/vBedsRented, 0), 2);		
			vAvgBedIncome = Round(?((vBedsForSale + vSpecBedsBlocked) <> 0, vRoomsIncome/(vBedsForSale + vSpecBedsBlocked), 0), 2);	
			
			vTempInd = vTempInd + 1;
			vExistingStr = IndexesTable.Get(vTempInd);
			vExistingStr.SecondDateIndexValue = vAvgBedPrice;
			vExistingStr.SecondDateIndexPresentation = ?(vAvgBedPrice = 0, vAvgBedPrice, cmFormatSum(vAvgBedPrice, vReportingCurrency));
			
			vTempInd = vTempInd + 1;
			vExistingStr = IndexesTable.Get(vTempInd);
			vExistingStr.SecondDateIndexValue = vAvgBedPriceInclAddSrv;
			vExistingStr.SecondDateIndexPresentation = ?(vAvgBedPriceInclAddSrv = 0, vAvgBedPriceInclAddSrv, cmFormatSum(vAvgBedPriceInclAddSrv, vReportingCurrency));
			
			vTempInd = vTempInd + 1;
			vExistingStr = IndexesTable.Get(vTempInd);
			vExistingStr.SecondDateIndexValue = vAvgBedIncome;
			vExistingStr.SecondDateIndexPresentation = ?(vAvgBedIncome = 0, vAvgBedIncome, cmFormatSum(vAvgBedIncome, vReportingCurrency));
		EndIf;
	EndIf;
	
	// 2. Guests summary indexes
	
	// Run query to get number of guest days
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	ОборотыПродажиНомеров.Period AS Period,
	|	ОборотыПродажиНомеров.ТипКлиента AS ТипКлиента,
	|	SUM(ОборотыПродажиНомеров.GuestDaysTurnover) AS GuestDaysTurnover,
	|	SUM(ОборотыПродажиНомеров.GuestsCheckedInTurnover) AS GuestsCheckedInTurnover
	|FROM
	|	AccumulationRegister.Продажи.Turnovers(&qPeriodFrom, &qPeriodTo, Day, Гостиница IN HIERARCHY (&qHotel)) AS ОборотыПродажиНомеров
	|GROUP BY
	|	ОборотыПродажиНомеров.Period,
	|	ОборотыПродажиНомеров.ТипКлиента
	|ORDER BY
	|	Period,
	|	ТипКлиента";
	vQry.SetParameter("qPeriodFrom", vBegOfPeriod);
	vQry.SetParameter("qPeriodTo", vEndOfPeriod);
	vQry.SetParameter("qHotel", Гостиница);
	vQryResult = vQry.Execute().Unload();
	
	// Add forecast guests if period is set in the future
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	RoomSalesForecastTurnovers.Period AS Period,
	|	RoomSalesForecastTurnovers.ТипКлиента AS ТипКлиента,
	|	SUM(RoomSalesForecastTurnovers.GuestDaysTurnover) AS GuestDaysTurnover,
	|	SUM(RoomSalesForecastTurnovers.GuestsCheckedInTurnover) AS GuestsCheckedInTurnover
	|FROM
	|	AccumulationRegister.ПрогнозПродаж.Turnovers(&qPeriodFrom, &qPeriodTo, Day, Гостиница IN HIERARCHY (&qHotel)) AS RoomSalesForecastTurnovers
	|GROUP BY
	|	RoomSalesForecastTurnovers.Period,
	|	RoomSalesForecastTurnovers.ТипКлиента
	|ORDER BY
	|	Period,
	|	ТипКлиента";
	vQry.SetParameter("qPeriodFrom", vBegOfPeriod);
	vQry.SetParameter("qPeriodTo", vEndOfPeriod);
	vQry.SetParameter("qHotel", Гостиница);
	vForecastQryResult = vQry.Execute().Unload();
	
	// Merge forecast guests with real ones
	For Each vForecastRow In vForecastQryResult Do
		vFound = False;
		For Each vRow In vQryResult Do
			If vRow.Period = vForecastRow.Period And
				vRow.ClientType = vForecastRow.ClientType Тогда
				vFound = True;
				Break;
			EndIf;
		EndDo;
		If НЕ vFound Тогда
			vRow = vQryResult.Add();
			vRow.Period = vForecastRow.Period;
			vRow.ТипКлиента = vForecastRow.ClientType;
			vRow.GuestDaysTurnover = 0;
			vRow.GuestsCheckedInTurnover = 0;
		EndIf;
		vRow.GuestDaysTurnover = vRow.GuestDaysTurnover + vForecastRow.GuestDaysTurnover;
		vRow.GuestsCheckedInTurnover = vRow.GuestsCheckedInTurnover + vForecastRow.GuestsCheckedInTurnover;
	EndDo;
	
	// Get list of client types
	vClientTypes = vQryResult.Copy();
	vClientTypes.GroupBy("ТипКлиента", );
	
	
	vExistingStrTitle = Неопределено;
	vExistingRows = IndexesTable.FindRows(New Structure("IndexKey", Tabulation + NStr("en='Guest days';ru='Человеко-дни';de='Personentage'")));
	If vExistingRows.Count() > 0 Тогда
		vExistingStrTitle = vExistingRows.Get(0);
	EndIf;	
	If vExistingStrTitle = Неопределено Тогда
		vTempInd = vTempInd + 1;
		vNewStr = IndexesTable.Вставить(vTempInd);
		vNewStr.IndexName = Tabulation + NStr("en='Guest days';ru='Человеко-дни';de='Personentage'");
	Else
		vTempInd = IndexesTable.IndexOf(vExistingStrTitle);
	EndIf;
	
	// Put client types
	vCheckedInGuests = 0;
	For Each vRow In vClientTypes Do
		vClientType = vRow.ClientType;
		// Get records for the current client type only
		vQrySubresult = vQryResult.FindRows(New Structure("ТипКлиента", vClientType));
		GetQResultTableTotals(CompareDate, vQrySubresult, vQryResult, "GuestDaysTurnover, GuestsCheckedInTurnover", False);
		vGuests = cmCastToNumber(TotalPerDay.GuestDaysTurnover);
		
		// Initialize number of checked in guests
		vCheckedInGuests = vCheckedInGuests + cmCastToNumber(TotalPerDay.GuestsCheckedInTurnover);
		
		If vExistingStrTitle = Неопределено Тогда
			vTempInd = vTempInd + 1;
			vNewStr = IndexesTable.Вставить(vTempInd);
			vNewStr.IndexName = Tabulation + "   "+vClientType;
			vNewStr.IndexKey = Tabulation + "   "+vClientType;
			vNewStr.IndexValue = 0;
			vNewStr.IndexPresentation = 0;
			vNewStr.SecondDateIndexValue = vGuests;
			vNewStr.SecondDateIndexPresentation = Round(vGuests);
		Else
			vExistingStr = Неопределено;
			vExistingRows = IndexesTable.FindRows(New Structure("IndexKey", vClientType.Description));
			If vExistingRows.Count() > 0 Тогда
				vExistingStr = vExistingRows.Get(0);
			EndIf;
			If vExistingStr = Неопределено Тогда
				vTempInd = vTempInd + 1;
				vNewStr = IndexesTable.Вставить(vTempInd);
				vNewStr.IndexName = Tabulation + "   " + vClientType;
				vNewStr.IndexKey = vClientType;
				vNewStr.IndexValue = 0;	
				vNewStr.IndexPresentation = 0;
				vNewStr.SecondDateIndexValue = vGuests;
				vNewStr.SecondDateIndexPresentation = Round(vGuests);
			Else
				vTempInd = IndexesTable.IndexOf(vExistingStr);
				
				vExistingStr.SecondDateIndexValue = vGuests;
				vExistingStr.SecondDateIndexPresentation = Round(vGuests);
			EndIf;
		EndIf;
		
	EndDo;	
	
	vClientTypesTotals = vQryResult.Copy();
	vClientTypesTotals.GroupBy("Period", "GuestDaysTurnover, GuestsCheckedInTurnover");
	GetQResultTableTotals(CompareDate, vClientTypesTotals, vClientTypesTotals, "GuestDaysTurnover, GuestsCheckedInTurnover", False);
	vGuests = cmCastToNumber(TotalPerDay.GuestDaysTurnover);
	If vClientTypes.Count() > 1 or MoreThanOneRecord Тогда
		vExistingStr = Неопределено;
		vExistingRows = IndexesTable.FindRows(New Structure("IndexKey", NStr("en='Total guest days';ru='Всего человеко-дней';de='Gesamt Manntage'")));
		If vExistingRows.Count() > 0 Тогда
			vExistingStr = vExistingRows.Get(0);
		EndIf;
		If vExistingStr = Неопределено Тогда
			vTempInd = vTempInd + 1;
			vNewStr = IndexesTable.Вставить(vTempInd);
			vNewStr.IndexName = Tabulation + NStr("en='TOTAL';ru='ВСЕГО';de='GESAMT'");
			vNewStr.IndexKey = NStr("en='Total guest days';ru='Всего человеко-дней';de='Gesamt Manntage'");
			vNewStr.IndexValue = ExpTotalGuests;	
			vNewStr.IndexPresentation = ExpTotalGuests;
			vNewStr.SecondDateIndexValue = vGuests;
			vNewStr.SecondDateIndexPresentation = Round(vGuests);
		Else
			vTempInd = IndexesTable.IndexOf(vExistingStr);
			
			vExistingStr.SecondDateIndexValue = vGuests;
			vExistingStr.SecondDateIndexPresentation = Round(vGuests);
		EndIf;
	EndIf;	
	
	// Put guests statistics
	If vInRooms Тогда
		vAvgNumberOfGuests = Round(?(vRoomsRented <> 0, vGuests/vRoomsRented, 0), 2);
	Else
		vAvgNumberOfGuests = Round(?(vBedsRented <> 0, vGuests/vBedsRented, 0), 2);
	EndIf;
	vAvgGuestLengthOfStay = Round(?(vCheckedInGuests <> 0, vGuests/vCheckedInGuests, 0), 2);
	vAvgGuestPrice = Round(?(vGuests <> 0, vRoomsIncome/vGuests, 0), 2);
	vAvgGuestIncome = Round(?(vGuests <> 0, vTotalIncome/vGuests, 0), 2);
	vExistingStr = Неопределено;
	vExistingRows = IndexesTable.FindRows(New Structure("IndexKey", Tabulation + NStr("en='Average number of guests per ГруппаНомеров';ru='Среднее число гостей в номере';de='Durchschnittliche Gästezahl im Zimmer'")));
	If vExistingRows.Count() > 0 Тогда
		vExistingStr = vExistingRows.Get(0);
	EndIf;
	If vExistingStr <> Неопределено Тогда
		vTempInd = IndexesTable.IndexOf(vExistingStr);
		IndexesTable.Get(vTempInd).SecondDateIndexValue = vAvgNumberOfGuests;
		IndexesTable.Get(vTempInd).SecondDateIndexPresentation = vAvgNumberOfGuests;
		IndexesTable.Get(vTempInd + 1).SecondDateIndexValue = vAvgGuestLengthOfStay;
		IndexesTable.Get(vTempInd + 1).SecondDateIndexPresentation = vAvgGuestLengthOfStay;
		IndexesTable.Get(vTempInd + 2).SecondDateIndexValue = vAvgGuestPrice;
		IndexesTable.Get(vTempInd + 2).SecondDateIndexPresentation = ?(vAvgGuestPrice = 0, vAvgGuestPrice, cmFormatSum(vAvgGuestPrice, vReportingCurrency));
		IndexesTable.Get(vTempInd + 3).SecondDateIndexValue = vAvgGuestIncome;
		IndexesTable.Get(vTempInd + 3).SecondDateIndexPresentation = ?(vAvgGuestIncome = 0, vAvgGuestIncome, cmFormatSum(vAvgGuestIncome, vReportingCurrency));
		vTempInd = vTempInd + 3;
	EndIf;
	
	// 3. Check-in summary indexes
	
	// Run query to get number of checked-in guests
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	ОборотыПродажиНомеров.Period AS Period,
	|	ОборотыПродажиНомеров.ДокОснование.РазмПоБрони AS ParentDocIsByReservation,
	|	SUM(ОборотыПродажиНомеров.GuestsCheckedInTurnover) AS GuestsCheckedInTurnover
	|FROM
	|	AccumulationRegister.Продажи.Turnovers(&qPeriodFrom, &qPeriodTo, Day, Гостиница IN HIERARCHY (&qHotel)) AS ОборотыПродажиНомеров
	|GROUP BY
	|	ОборотыПродажиНомеров.Period,
	|	ОборотыПродажиНомеров.ДокОснование.РазмПоБрони
	|ORDER BY
	|	Period,
	|	ParentDocIsByReservation";
	vQry.SetParameter("qPeriodFrom", vBegOfPeriod);
	vQry.SetParameter("qPeriodTo", vEndOfPeriod);
	vQry.SetParameter("qHotel", Гостиница);
	vQryResult = vQry.Execute().Unload();
	
	// Add forecast guests if period is set in the future
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	RoomSalesForecastTurnovers.Period AS Period,
	|	TRUE AS ParentDocIsByReservation,
	|	SUM(RoomSalesForecastTurnovers.GuestsCheckedInTurnover) AS GuestsCheckedInTurnover
	|FROM
	|	AccumulationRegister.ПрогнозПродаж.Turnovers(&qPeriodFrom, &qPeriodTo, Day, Гостиница IN HIERARCHY (&qHotel)) AS RoomSalesForecastTurnovers
	|GROUP BY
	|	RoomSalesForecastTurnovers.Period
	|ORDER BY
	|	Period,
	|	ParentDocIsByReservation";
	vQry.SetParameter("qPeriodFrom", vBegOfPeriod);
	vQry.SetParameter("qPeriodTo", vEndOfPeriod);
	vQry.SetParameter("qHotel", Гостиница);
	vForecastQryResult = vQry.Execute().Unload();
	
	// Merge forecast guests with real ones
	For Each vForecastRow In vForecastQryResult Do
		vFound = False;
		For Each vRow In vQryResult Do
			If vRow.Period = vForecastRow.Period And
				vRow.ParentDocIsByReservation = vForecastRow.ParentDocIsByReservation Тогда
				vFound = True;
				Break;
			EndIf;
		EndDo;
		If НЕ vFound Тогда
			vRow = vQryResult.Add();
			vRow.Period = vForecastRow.Period;
			vRow.ParentDocIsByReservation = vForecastRow.ParentDocIsByReservation;
			vRow.GuestsCheckedInTurnover = 0;
		EndIf;
		vRow.GuestsCheckedInTurnover = vRow.GuestsCheckedInTurnover + vForecastRow.GuestsCheckedInTurnover;
	EndDo;
	
	// Split table to walk-in and check-in by reservation
	vQryResultWalkInArray = vQryResult.Copy().FindRows(New Structure("ParentDocIsByReservation", False));
	vQryResultResArray = vQryResult.Copy().FindRows(New Structure("ParentDocIsByReservation", True));
	vQryResultWalkIn = vQryResult.CopyColumns();
	For Each vRow In vQryResultWalkInArray Do
		vTabRow = vQryResultWalkIn.Add();
		FillPropertyValues(vTabRow, vRow);
	EndDo;
	vQryResultWalkIn.GroupBy("Period", "GuestsCheckedInTurnover");
	vQryResultRes = vQryResult.CopyColumns();
	For Each vRow In vQryResultResArray Do
		vTabRow = vQryResultRes.Add();
		FillPropertyValues(vTabRow, vRow);
	EndDo;
	vQryResultRes.GroupBy("Period", "GuestsCheckedInTurnover");
	GetQResultTableTotals(CompareDate, vQryResultRes, vQryResultRes, "GuestsCheckedInTurnover", False);
	vExistingStr = Неопределено;
	vExistingRows = IndexesTable.FindRows(New Structure("IndexKey", Tabulation + NStr("en='Guests reserved and checked-in';ru='Заезд гостей по брони';de='Anreise der Gäste nach der Reservierung'")));
	If vExistingRows.Count() > 0 Тогда
		vExistingStr = vExistingRows.Get(0);
	EndIf;
	If vExistingStr<>Неопределено Тогда
		vGuestsReserved = cmCastToNumber(TotalPerDay.GuestsCheckedInTurnover);
		vExistingStr.SecondDateIndexValue = vGuestsReserved;
		vExistingStr.SecondDateIndexPresentation = vGuestsReserved;
		vTempInd = IndexesTable.IndexOf(vExistingStr)
	EndIf;
	
	// Put walk-in
	GetQResultTableTotals(CompareDate, vQryResultWalkIn, vQryResultWalkIn, "GuestsCheckedInTurnover", False);
	vGuestsWalkIn = cmCastToNumber(TotalPerDay.GuestsCheckedInTurnover);
	IndexesTable.Get(vTempInd+1).SecondDateIndexValue = vGuestsWalkIn;
	IndexesTable.Get(vTempInd+1).SecondDateIndexPresentation = vGuestsWalkIn;
	
	// 4. Income summary indexes
	vExistingStr = Неопределено;
	vExistingRows = IndexesTable.FindRows(New Structure("IndexKey", Tabulation + NStr("en='Rooms Revenue';ru='Доход от продажи номеров';de='Erlös aus den Zimmerverkauf'")));
	If vExistingRows.Count() > 0 Тогда
		vExistingStr = vExistingRows.Get(0);
	EndIf;
	// Put total sales
	If vExistingStr <> Неопределено Тогда
		vExistingStr.SecondDateIndexValue = vRoomsIncome;
		vExistingStr.SecondDateIndexPresentation = ?(vRoomsIncome = 0, vRoomsIncome, cmFormatSum(vRoomsIncome, vReportingCurrency));
		vTempInd = IndexesTable.IndexOf(vExistingStr);
		IndexesTable.Get(vTempInd+1).SecondDateIndexValue = vOtherIncome;
		IndexesTable.Get(vTempInd+1).SecondDateIndexPresentation = ?(vOtherIncome = 0, vOtherIncome, cmFormatSum(vOtherIncome, vReportingCurrency));
		vTempInd = vTempInd + 1;
	EndIf;
	// Put sales by service types
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	ServiceSales.Period AS Period,
	|	ServiceSales.ServiceType AS ServiceType,
	|	SUM(ServiceSales.SumTurnover) AS SumTurnover,
	|	SUM(ServiceSales.SumWithoutVATTurnover) AS SumWithoutVATTurnover
	|FROM
	|	(SELECT
	|		ServiceSalesTurnovers.Period AS Period,
	|		ServiceSalesTurnovers.Услуга.ServiceType AS ServiceType,
	|		ServiceSalesTurnovers.SalesTurnover AS SumTurnover,
	|		ServiceSalesTurnovers.SalesWithoutVATTurnover AS SumWithoutVATTurnover
	|	FROM
	|		AccumulationRegister.Продажи.Turnovers(&qPeriodFrom, &qPeriodTo, Day, Гостиница IN HIERARCHY (&qHotel)) AS ServiceSalesTurnovers
	|	
	|	UNION ALL
	|	
	|	SELECT
	|		ServiceSalesForecastTurnovers.Period,
	|		ServiceSalesForecastTurnovers.Услуга.ServiceType,
	|		ServiceSalesForecastTurnovers.SalesTurnover,
	|		ServiceSalesForecastTurnovers.SalesWithoutVATTurnover
	|	FROM
	|		AccumulationRegister.ПрогнозПродаж.Turnovers(&qForecastPeriodFrom, &qForecastPeriodTo, Day, Гостиница IN HIERARCHY (&qHotel)) AS ServiceSalesForecastTurnovers) AS ServiceSales
	|
	|GROUP BY
	|	ServiceSales.Period,
	|	ServiceSales.ServiceType
	|
	|ORDER BY
	|	Period,
	|	ServiceSales.ServiceType.ПорядокСортировки";
	vQry.SetParameter("qPeriodFrom", vBegOfPeriod);
	vQry.SetParameter("qPeriodTo", vEndOfPeriod);
	vQry.SetParameter("qForecastPeriodFrom", vBegOfPeriod);
	vQry.SetParameter("qForecastPeriodTo", vEndOfPeriod);
	vQry.SetParameter("qHotel", Гостиница);
	vQryResult = vQry.Execute().Unload();
	
	vQry.SetParameter("qPeriodFrom", vBegOfPeriodNow);
	vQry.SetParameter("qPeriodTo", vEndOfPeriodNow);
	vQry.SetParameter("qForecastPeriodFrom", vBegOfPeriodNow);
	vQry.SetParameter("qForecastPeriodTo", vEndOfPeriodNow);
	vQry.SetParameter("qHotel", Гостиница);
	vQryResultNow = vQry.Execute().Unload();
	
	// Get list of service types
	vServiceTypes = vQryResult.Copy();
	vServiceTypes.GroupBy("ServiceType", );
	
	vServiceTypesNow = vQryResultNow.Copy();
	vServiceTypesNow.GroupBy("ServiceType", );	
	If vServiceTypes.Count() > 1 Тогда	
		// Put service types summary
		For Each vRow In vServiceTypes Do
			vServiceType = vRow.ServiceType;
			
			vExistingStr = Неопределено;
			vExistingRows = IndexesTable.FindRows(New Structure("IndexKey", Tabulation + "   "+vServiceType));
			If vExistingRows.Count() > 0 Тогда
				vExistingStr = vExistingRows.Get(0);
			EndIf;
			
			If vExistingStr = Неопределено Тогда
				vTempInd = vTempInd + 1;
				vNewStr = IndexesTable.Вставить(vTempInd);
				vNewStr.IndexName = Tabulation + "   " + vServiceType;
				vNewStr.IndexKey = vNewStr.IndexName;
				vNewStr.IndexValue = 0;
				vNewStr.IndexPresentation = 0;
				
				// Get records for the current payment method only
				vQrySubresult = vQryResult.FindRows(New Structure("ServiceType", vServiceType));
				GetQResultTableTotals(CompareDate, vQrySubresult, vQryResult, "SumTurnover, SumWithoutVATTurnover", False);
				If vWithVAT Тогда
					vServiceTypeIncome = cmCastToNumber(TotalPerDay.SumTurnover);
				Else
					vServiceTypeIncome = cmCastToNumber(TotalPerDay.SumWithoutVATTurnover);
				EndIf;
				vNewStr.SecondDateIndexValue = vServiceTypeIncome;
				vNewStr.SecondDateIndexPresentation = ?(vServiceTypeIncome = 0, vServiceTypeIncome, cmFormatSum(vServiceTypeIncome, vReportingCurrency));
			Else
				vQrySubresult = vQryResult.FindRows(New Structure("ServiceType", vServiceType));
				GetQResultTableTotals(CompareDate, vQrySubresult, vQryResult, "SumTurnover, SumWithoutVATTurnover", False);
				If vWithVAT Тогда
					vServiceTypeIncome = cmCastToNumber(TotalPerDay.SumTurnover);
				Else
					vServiceTypeIncome = cmCastToNumber(TotalPerDay.SumWithoutVATTurnover);
				EndIf;
				vExistingStr.SecondDateIndexValue = vServiceTypeIncome;
				vExistingStr.SecondDateIndexPresentation = ?(vServiceTypeIncome = 0, vServiceTypeIncome, cmFormatSum(vServiceTypeIncome, vReportingCurrency));
				vTempInd = IndexesTable.IndexOf(vExistingStr);
			EndIf;
		EndDo;
	EndIf; 
	vExistingStr = Неопределено;
	vExistingRows = IndexesTable.FindRows(New Structure("IndexKey", NStr("en='SEVICE TYPE TOTALS';ru='ИТОГИ ПО ТИПАМ УСЛУГ';de='ERGEBNISSE NACH DIENSTLEISTUNGSTYPEN'")));
	If vExistingRows.Count() > 0 Тогда
		vExistingStr = vExistingRows.Get(0);
	EndIf;
	
	If vExistingStr <> Неопределено Тогда
		vExistingStr.SecondDateIndexValue = vTotalIncome;
		vExistingStr.SecondDateIndexPresentation = ?(vTotalIncome = 0, vTotalIncome, cmFormatSum(vTotalIncome, vReportingCurrency));
		vTempInd = IndexesTable.IndexOf(vExistingStr);
	EndIf;
	
	// 5. Payments summary indexes
	
	// Run query to get payments by payment method
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	PaymentsTurnovers.СпособОплаты AS СпособОплаты,
	|	PaymentsTurnovers.Period AS Period,
	|	SUM(PaymentsTurnovers.SumTurnover) AS SumTurnover,
	|	SUM(PaymentsTurnovers.VATSumTurnover) AS VATSumTurnover
	|FROM
	|	AccumulationRegister.Платежи.Turnovers(&qPeriodFrom, &qPeriodTo, Day, Гостиница IN HIERARCHY (&qHotel)) AS PaymentsTurnovers
	|GROUP BY
	|	PaymentsTurnovers.Period,
	|	PaymentsTurnovers.СпособОплаты
	|ORDER BY
	|	СпособОплаты,
	|	Period";
	vQry.SetParameter("qPeriodFrom", vBegOfPeriod);
	vQry.SetParameter("qPeriodTo", vEndOfPeriod);
	vQry.SetParameter("qHotel", Гостиница);
	vQryResult = vQry.Execute().Unload();
	
	// Get list of payment methods
	vPaymentMethods = vQryResult.Copy();
	vPaymentMethods.GroupBy("СпособОплаты", );
	
	vExistingStr = Неопределено;
	vExistingRows = IndexesTable.FindRows(New Structure("IndexKey", NStr("en='PAYMENTS SUMMARY INDEXES';ru='СТАТИСТИКА ПО ПЛАТЕЖАМ';de='STATISTIK NACH ZAHLUNGEN'")));
	If vExistingRows.Count() > 0 Тогда
		vExistingStr = vExistingRows.Get(0);
		vTempInd = IndexesTable.IndexOf(vExistingStr);
	EndIf;
	
	// Put payment methods summary
	vTotalPaymentsPerDay = 0;
	For Each vRow In vPaymentMethods Do
		vPaymentMethod = vRow.PaymentMethod;
		If vPaymentMethod = Справочники.СпособОплаты.Акт Тогда
			Continue;
		EndIf;
		
		// Get records for the current payment method only
		vQrySubresult = vQryResult.FindRows(New Structure("СпособОплаты", vPaymentMethod));
		GetQResultTableTotals(CompareDate, vQrySubresult, vQryResult, "SumTurnover, VATSumTurnover", False);
		vSumTurnover = cmCastToNumber(TotalPerDay.SumTurnover);
		
		vExistingStr = Неопределено;
		vExistingRows = IndexesTable.FindRows(New Structure("IndexKey", vPaymentMethod.Description));
		If vExistingRows.Count() > 0 Тогда
			vExistingStr = vExistingRows.Get(0);
		EndIf;
		If vExistingStr = Неопределено Тогда
			vTempInd = vTempInd + 1;
			vNewStr = IndexesTable.Вставить(vTempInd);
			vNewStr.IndexName = Tabulation+vPaymentMethod;
			vNewStr.IndexKey = vPaymentMethod;
			vNewStr.IndexValue = 0;
			vNewStr.IndexPresentation = 0;
			vNewStr.SecondDateIndexValue = vSumTurnover;
			vNewStr.SecondDateIndexPresentation = ?(vSumTurnover = 0, vSumTurnover, cmFormatSum(vSumTurnover, vReportingCurrency));
		Else
			vExistingStr.SecondDateIndexValue = vSumTurnOver;
			vExistingStr.SecondDateIndexPresentation = ?(vSumTurnOver = 0, vSumTurnOver, cmFormatSum(vSumTurnOver, vReportingCurrency));
			IndexesTable.IndexOf(vExistingStr);
		EndIf;
		vTotalPaymentsPerDay = vTotalPaymentsPerDay + cmCastToNumber(TotalPerDay.SumTurnover);
	EndDo;
	
	// Payments footer
	vExistingStr = Неопределено;
	vExistingRows = IndexesTable.FindRows(New Structure("IndexKey", Tabulation + NStr("en='Total payments';ru='Всего платежей';de='Gesamt Zahlungen'")));
	If vExistingRows.Count() > 0 Тогда
		vExistingStr = vExistingRows.Get(0);
	EndIf;
	If vExistingStr <> Неопределено Тогда
		vExistingStr.SecondDateIndexValue = vTotalPaymentsPerDay;
		vExistingStr.SecondDateIndexPresentation = ?(vTotalPaymentsPerDay = 0, vTotalPaymentsPerDay, cmFormatSum(vTotalPaymentsPerDay, vReportingCurrency));
	EndIf;
	For vInd=1 to IndexesTable.Count()-1 Do
		If (IndexesTable.Get(vInd).IndexPresentation = "") or (IndexesTable.Get(vInd).SecondDateIndexPresentation = "") Тогда
			Continue;
		Else
			If IndexesTable.Get(vInd).IndexValue < IndexesTable.Get(vInd).SecondDateIndexValue Тогда
				IndexesTable.Get(vInd).SecondDateIcon = PictureLib.ArrowRedDown;
			ElsIf IndexesTable.Get(vInd).IndexValue > IndexesTable.Get(vInd).SecondDateIndexValue Тогда
				IndexesTable.Get(vInd).SecondDateIcon = PictureLib.ArrowGreenUp;
			EndIf;
		EndIf;
	EndDo;
КонецПроцедуры //GetCompareRooms

//-------------------------------------------------------------------------------------------------
&AtServer
Процедура ChartBuild()
	
	vQryRoomsForSaleArray = New Array;
	vQryRoomsIncomeArray = New Array;
	vQryRoomsRentedArray = New Array;
	
	vWithVAT = True;
	If ЗначениеЗаполнено(Гостиница) Тогда
		
		vWithVAT = Гостиница.ShowSalesInReportsWithVAT;
	EndIf;
	
	// Check period choosen
	If Items.PeriodDay.Visible Тогда
		vBegOfPeriod = BegOfMonth(PeriodTo);
		vEndOfPeriod = EndOfMonth(PeriodTo);
		vPeriodicity = "Day";
	ElsIf Items.SelQuarter.Visible Тогда
		vBegOfPeriod = BegOfQuarter(CompositionDate);
		vEndOfPeriod = EndOfQuarter(CompositionDate);
		vPeriodicity = "Month";
		vFormat = SelQuarter;
	ElsIf Items.SelMonth.Visible Тогда
		vBegOfPeriod = BegOfMonth(CompositionDate);
		vEndOfPeriod = EndOfMonth(CompositionDate);
		vPeriodicity = "Day";
	Else
		vBegOfPeriod = BegOfYear(CompositionDate);
		vEndOfPeriod = EndOfYear(CompositionDate);
		vPeriodicity = "Month";
		vFormat = SelYear + NStr("en=' year';ru=' год';de=' Jahr'");
	EndIf;
	
	// Clear charts
	If vPeriodicity = "Day" Тогда
		Items.ChartGist.Title = NStr("en='Rented rooms';ru='Продажи номеров';de='Zimmerverkäufe'") + " ("+Format(CompositionDate, NStr("en = 'L = en; '; de = 'L = de; '; ru = 'L = ru; '")+ "DF = 'MMMM yyyy'")+NStr("ru=' год';de=' Jahr';en=' year'")+")";
		Items.ChartForSale.Title = NStr("en='ГруппаНомеров Revenue';ru='Доход';de='Erlös'") + " ("+Format(CompositionDate, NStr("en = 'L = en; '; de = 'L = de; '; ru = 'L = ru; '")+ "DF = 'MMMM yyyy'")+NStr("ru=' год';de=' Jahr';en = ' year'")+")";
	ElsIf vPeriodicity = "Month" Тогда
		Items.ChartGist.Title = NStr("en='Rented rooms';ru='Продажи номеров';de='Zimmerverkäufe'") + " ("+vFormat+")";
		Items.ChartForSale.Title = NStr("en='ГруппаНомеров Revenue';ru='Доход';de='Erlös'") + " ("+vFormat+")";
	EndIf;
	ChartForSale.Clear();
	ChartForSale.ChartType = ChartType.Column;
	ChartForSale.RefreshEnabled = True;
	ChartForSale.Series.Add();
	ChartForSale.Series[0].Marker = ChartMarkerType.None;
	ChartForSale.Series[0].Text = NStr("en='ГруппаНомеров Revenue';ru='Доход';de='Erlös'");
	ChartGist.Clear();
	ChartGist.ChartType = ChartType.Column;
	ChartGist.Series.Add();
	ChartGist.Series[0].Text = NStr("en='Rented rooms';ru='Продано номеров';de='Verkaufte Zimmer'");
	ChartGist.Series.Add();
	ChartGist.Series[1].Indicator=True;
	ChartGist.Series[1].Marker = ChartMarkerType.None;
	ChartGist.Series[1].Text = NStr("en='Rooms for sale';ru='Номера к продаже';de='Zimmer für den Verkauf'");
	vColor = New Color(0,0,0);
	vColor2 = New Color(255,255,225);
	vSerColor = New Color(29,0,181);
	vSerColor2 = New Color(120,120,90);
	vSerColor3 = New Color(255,169,108);
	ChartGist.PlotArea.ScaleColor = vColor;
	ChartForSale.PlotArea.ScaleColor = vColor;
	ChartGist.PlotArea.BackColor = vColor2;
	ChartForSale.PlotArea.BackColor = vColor2;
	ChartGist.LegendArea.BackColor = vColor2;
	ChartForSale.LegendArea.BackColor = vColor2;
	ChartGist.TitleArea.BackColor = vColor2;
	ChartForSale.TitleArea.BackColor = vColor2;
	ChartGist.Series[0].Color = vSerColor;
	ChartGist.Series[1].Color = vSerColor3;
	ChartForSale.Series[0].Color = vSerColor2;
	
	// Run query to get ГруппаНомеров sales
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	RoomSales.Period AS Period,
	|	SUM(ISNULL(RoomSales.SalesTurnover, 0)) AS SalesTurnover,
	|	SUM(ISNULL(RoomSales.SalesWithoutVATTurnover, 0)) AS SalesWithoutVATTurnover,
	|	SUM(ISNULL(RoomSales.RoomRevenueTurnover, 0)) AS RoomRevenueTurnover,
	|	SUM(ISNULL(RoomSales.RoomRevenueWithoutVATTurnover, 0)) AS RoomRevenueWithoutVATTurnover,
	|	SUM(ISNULL(RoomSales.RoomsRentedTurnover, 0)) AS RoomsRentedTurnover,
	|	SUM(ISNULL(RoomSales.BedsRentedTurnover, 0)) AS BedsRentedTurnover
	|FROM (
	|SELECT
	|	ОборотыПродажиНомеров.Period AS Period,
	|	ISNULL(ОборотыПродажиНомеров.SalesTurnover, 0) AS SalesTurnover,
	|	ISNULL(ОборотыПродажиНомеров.SalesWithoutVATTurnover, 0) AS SalesWithoutVATTurnover,
	|	ISNULL(ОборотыПродажиНомеров.RoomRevenueTurnover, 0) AS RoomRevenueTurnover,
	|	ISNULL(ОборотыПродажиНомеров.RoomRevenueWithoutVATTurnover, 0) AS RoomRevenueWithoutVATTurnover,
	|	ISNULL(ОборотыПродажиНомеров.RoomsRentedTurnover, 0) AS RoomsRentedTurnover,
	|	ISNULL(ОборотыПродажиНомеров.BedsRentedTurnover, 0) AS BedsRentedTurnover
	|FROM
	|	AccumulationRegister.Продажи.Turnovers(&qPeriodFrom, &qPeriodTo, "+vPeriodicity+", Гостиница IN HIERARCHY (&qHotel)) AS ОборотыПродажиНомеров
	|UNION ALL
	|SELECT
	|	RoomSalesTurnoversForecast.Period,
	|	ISNULL(RoomSalesTurnoversForecast.SalesTurnover, 0),
	|	ISNULL(RoomSalesTurnoversForecast.SalesWithoutVATTurnover, 0),
	|	ISNULL(RoomSalesTurnoversForecast.RoomRevenueTurnover, 0),
	|	ISNULL(RoomSalesTurnoversForecast.RoomRevenueWithoutVATTurnover, 0),
	|	ISNULL(RoomSalesTurnoversForecast.RoomsRentedTurnover, 0),
	|	ISNULL(RoomSalesTurnoversForecast.BedsRentedTurnover, 0)
	|FROM
	|	AccumulationRegister.ПрогнозПродаж.Turnovers(&qForecastPeriodFrom, &qForecastPeriodTo, "+vPeriodicity+", Гостиница IN HIERARCHY (&qHotel)) AS RoomSalesTurnoversForecast) AS RoomSales
	|GROUP BY
	|	RoomSales.Period
	|ORDER BY
	|	Period";
	vQry.SetParameter("qPeriodFrom", vBegOfPeriod);
	vQry.SetParameter("qPeriodTo", vEndOfPeriod);
	vQry.SetParameter("qForecastPeriodFrom", vBegOfPeriod);
	vQry.SetParameter("qForecastPeriodTo", vEndOfPeriod);
	vQry.SetParameter("qHotel", Гостиница);
	vQryResult = vQry.Execute().Unload();
	
	// <Counter>
	vDateNow = vBegOfPeriod;
	vQryCount = vQryResult.Count();
	vIndCount = 0;
	For Each vQryResultRow In vQryResult Do
		vIndCount = vIndCount + 1;
		If vPeriodicity = "Day" Тогда
			If vQryResultRow.Period>vDateNow Тогда
				vDaysCount = (vQryResultRow.Period - vDateNow)/86400;
				For vDays = 0 To vDaysCount-1 Do
					vQryRoomsRentedArray.Add(0);
					vQryRoomsRentedArray.Add(vDateNow+vDays*86400);
					vQryRoomsIncomeArray.Add(0);
					vQryRoomsIncomeArray.Add(vDateNow+vDays*86400);
				EndDo;
			EndIf;
		ElsIf vPeriodicity = "Month" Тогда
			If Month(vQryResultRow.Period)>Month(vDateNow) Тогда
				vMonthsCount = Month(vQryResultRow.Period) - Month(vDateNow);
				For vMonths = 0 To vMonthsCount-1 Do
					vQryRoomsRentedArray.Add(0);
					vQryRoomsRentedArray.Add(AddMonth(vDateNow, vMonths));
					vQryRoomsIncomeArray.Add(0);
					vQryRoomsIncomeArray.Add(AddMonth(vDateNow, vMonths));
				EndDo;
			EndIf;
		EndIf;
		vQryRoomsRentedArray.Add(cmCastToNumber(vQryResultRow.RoomsRentedTurnover));
		vQryRoomsRentedArray.Add(vQryResultRow.Period);
		If vWithVAT Тогда
			vRoomsIncome = cmCastToNumber(vQryResultRow.RoomRevenueTurnover);
			vQryRoomsIncomeArray.Add(vRoomsIncome);
			vQryRoomsIncomeArray.Add(vQryResultRow.Period);
		Else
			vRoomsIncome = cmCastToNumber(vQryResultRow.RoomRevenueWithoutVATTurnover);
			vQryRoomsIncomeArray.Add(vRoomsIncome);
			vQryRoomsIncomeArray.Add(vQryResultRow.Period);
		EndIf;
		If vPeriodicity = "Day" Тогда
			If (vQryResultRow.Period<(vEndOfPeriod)) and (vQryCount=vIndCount) Тогда
				vDaysCount = (vEndOfPeriod - vQryResultRow.Period)/86400;
				For vDays = 1 To vDaysCount Do
					vQryRoomsRentedArray.Add(0);
					vQryRoomsRentedArray.Add(vDateNow+vDays*86400);
					vQryRoomsIncomeArray.Add(0);
					vQryRoomsIncomeArray.Add(vDateNow+vDays*86400);
				EndDo;
			EndIf;  
		ElsIf vPeriodicity = "Month" Тогда
			If (Month(vQryResultRow.Period)<Month(vEndOfPeriod)) and (vQryCount=vIndCount) Тогда
				vMonthsCount = Month(vQryResultRow.Period) - Month(vDateNow);
				For vMonths = 1 To vMonthsCount Do
					vQryRoomsRentedArray.Add(0);
					vQryRoomsRentedArray.Add(AddMonth(vDateNow, vMonths));
					vQryRoomsIncomeArray.Add(0);
					vQryRoomsIncomeArray.Add(AddMonth(vDateNow, vMonths));
				EndDo;
			EndIf; 
		EndIf;
		If vPeriodicity = "Day" Тогда
			vDateNow = vQryResultRow.Period+86400;
		ElsIf vPeriodicity = "Month" Тогда
			vDateNow = AddMonth(vQryResultRow.Period, 1);
		EndIf;
	EndDo;	
	// </Counter>
	
	// Run query to get rooms available
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	CASE
	|		WHEN &qByMonth
	|			THEN BEGINOFPERIOD(RoomInventoryBalanceAndTurnovers.Period, MONTH)
	|		ELSE RoomInventoryBalanceAndTurnovers.Period
	|	END AS Period,
	|	SUM(RoomInventoryBalanceAndTurnovers.CounterClosingBalance) AS CounterClosingBalance,
	|	SUM(RoomInventoryBalanceAndTurnovers.TotalRoomsClosingBalance) AS TotalRoomsClosingBalance,
	|	SUM(RoomInventoryBalanceAndTurnovers.TotalBedsClosingBalance) AS TotalBedsClosingBalance,
	|	-SUM(RoomInventoryBalanceAndTurnovers.RoomsBlockedClosingBalance) AS RoomsBlockedClosingBalance,
	|	-SUM(RoomInventoryBalanceAndTurnovers.BedsBlockedClosingBalance) AS BedsBlockedClosingBalance
	|FROM
	|	AccumulationRegister.ЗагрузкаНомеров.BalanceAndTurnovers(&qPeriodFrom, &qPeriodTo, Day, RegisterRecordsAndPeriodBoundaries, Гостиница IN HIERARCHY (&qHotel)) AS RoomInventoryBalanceAndTurnovers
	|
	|GROUP BY
	|	CASE
	|		WHEN &qByMonth
	|			THEN BEGINOFPERIOD(RoomInventoryBalanceAndTurnovers.Period, MONTH)
	|		ELSE RoomInventoryBalanceAndTurnovers.Period
	|	END
	|
	|ORDER BY
	|	Period";
	vQry.SetParameter("qPeriodFrom", vBegOfPeriod);
	vQry.SetParameter("qPeriodTo", vEndOfPeriod);
	vQry.SetParameter("qByMonth", ?(vPeriodicity = "Month", True, False));
	vQry.SetParameter("qHotel", Гостиница);
	vQryResult = vQry.Execute().Unload();
	
	vDateNow = vBegOfPeriod;
	vQryCount = vQryResult.Count();
	vIndCount = 0;
	For Each vQryResultRow in vQryResult Do
		vTotalRooms = cmCastToNumber(vQryResultRow.TotalRoomsClosingBalance);		
		vBlockedRooms = cmCastToNumber(vQryResultRow.RoomsBlockedClosingBalance);
		vRoomsForSale=vTotalRooms-vBlockedRooms;
		vIndCount = vIndCount + 1;
		If vPeriodicity = "Day" Тогда
			If vQryResultRow.Period>vDateNow Тогда
				vDaysCount = (vQryResultRow.Period - vDateNow)/86400;
				For vDays = 0 To vDaysCount-1 Do
					vQryRoomsForSaleArray.Add(0);
					vQryRoomsForSaleArray.Add(vDateNow+vDays*86400);
				EndDo;
			EndIf;
		ElsIf vPeriodicity = "Month" Тогда
			If Month(vQryResultRow.Period)>Month(vDateNow) Тогда
				vMonthsCount = Month(vQryResultRow.Period) - Month(vDateNow);
				For vMonths = 0 To vMonthsCount-1 Do
					vQryRoomsForSaleArray.Add(0);
					vQryRoomsForSaleArray.Add(AddMonth(vDateNow, vMonths));
				EndDo;
			EndIf;
		EndIf;
		vQryRoomsForSaleArray.Add(vRoomsForSale);
		vQryRoomsForSaleArray.Add(vQryResultRow.Period);
		If vPeriodicity = "Day" Тогда
			If (vQryResultRow.Period<(vEndOfPeriod)) and (vQryCount=vIndCount) Тогда
				vDaysCount = (vEndOfPeriod - vQryResultRow.Period)/86400;
				For vDays = 1 To vDaysCount Do
					vQryRoomsForSaleArray.Add(0);
					vQryRoomsForSaleArray.Add(vDateNow+vDays*86400);
				EndDo;
			EndIf;
		ElsIf vPeriodicity = "Month" Тогда
			If (Month(vQryResultRow.Period)<Month(vEndOfPeriod)) and (vQryCount=vIndCount) Тогда
				vMonthsCount = Month(vQryResultRow.Period) - Month(vDateNow);
				For vMonths = 0 To vMonthsCount-1 Do
					vQryRoomsForSaleArray.Add(0);
					vQryRoomsForSaleArray.Add(AddMonth(vDateNow, vMonths));
				EndDo;
			EndIf;
		EndIf;
		If vPeriodicity = "Day" Тогда
			vDateNow = vQryResultRow.Period+86400;
		ElsIf vPeriodicity = "Month" Тогда
			vDateNow = AddMonth(vQryResultRow.Period, 1);
		EndIf;	
	EndDo;
	
	If (vQryRoomsRentedArray.Count()=0) or (vQryRoomsIncomeArray.Count()=0) Тогда
		ChartGist.Clear();
	Else
		If vQryRoomsRentedArray.Count()<vQryRoomsIncomeArray.Count() Тогда
			vMinCount = vQryRoomsRentedArray.Count();
		Else
			vMinCount = vQryRoomsIncomeArray.Count();
		EndIf;
		For vInd=0 To (vMinCount/2-1) Do
			vNewPoint = ChartGist.Points.Add(String(Format(vQryRoomsIncomeArray.Get(vInd*2+1), ?(vPeriodicity = "Day", "DF = 'dd'", "DF = 'MMMM'"))));
			ChartGist.SetValue(vNewPoint,0,vQryRoomsRentedArray.Get(vInd*2));
			ChartGist.SetValue(vNewPoint,1,vQryRoomsForSaleArray.Get(vInd*2));
			vNewPoint = ChartForSale.Points.Add(String(Format(vQryRoomsIncomeArray.Get(vInd*2+1), ?(vPeriodicity = "Day", "DF = 'dd'", "DF = 'MMMM'"))));
			ChartForSale.SetValue(vNewPoint,0,vQryRoomsIncomeArray.Get(vInd*2));
		EndDo;
	EndIf;
КонецПроцедуры //ChartBuild

//-------------------------------------------------------------------------------------------------
&НаКлиенте
Процедура GetReport()
	vParameters = New Structure("Гостиница, BegOfPeriod, EndOfPeriod");
	If ChoosePeriod = Items.ChoosePeriod.ChoiceList.FindByValue("0").Presentation Тогда
		vParameters.BegOfPeriod = BegOfDay(PeriodTo);
		vParameters.EndOfPeriod = EndOfDay(PeriodTo);
	ElsIf ChoosePeriod = Items.ChoosePeriod.ChoiceList.FindByValue("1").Presentation Тогда
		vParameters.BegOfPeriod = BegOfMonth(CompositionDate);
		vParameters.EndOfPeriod = EndOfMonth(CompositionDate);
	ElsIf ChoosePeriod = Items.ChoosePeriod.ChoiceList.FindByValue("2").Presentation Тогда
		vParameters.BegOfPeriod = BegOfQuarter(CompositionDate);
		vParameters.EndOfPeriod = EndOfQuarter(CompositionDate);
	Else 
		vParameters.BegOfPeriod = BegOfYear(CompositionDate);
		vParameters.EndOfPeriod = EndOfYear(CompositionDate);
	EndIf;
	#If НЕ WebClient Тогда
		Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 50, NStr("en='Print...';ru='Открытие печатной формы...';de='Öffnen des Druckformulars...'"), PictureLib.LongOperation); 
	#EndIf
	
	vParameters.Гостиница = Гостиница;
	ПолучитьФорму("Report.MainMenuSummaryIndexesReport.Form.ReportForm", vParameters).Open();
КонецПроцедуры //GetReport

//-------------------------------------------------------------------------------------------------
&НаКлиенте
Процедура OnOpen(Cancel)
	ЭтаФорма.AutoSaveDataInSettings = AutoSaveFormDataInSettings.Use;
	ЭтаФорма.SaveDataInSettings = SaveFormDataInSettings.UseList;
	ЭтаФорма.SavedInSettingsDataModified = True;
	#If НЕ WebClient Тогда
		Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 0, NStr("en='Opening...';ru='Открытие формы...';de='Öffnen des Formulars...'"), PictureLib.LongOperation); 
	#EndIf
	// Read default parameters
	GetHotelAndPeriod();
	#If НЕ WebClient Тогда
		Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 30, NStr("en='Opening...';ru='Открытие формы...';de='Öffnen des Formulars...'"), PictureLib.LongOperation); 
	#EndIf
	// Set first date column caption
	Items.ColumnIndexPresentation.Title = Format(PeriodTo, "DLF=D");
	Items.ColumnSecondDateIndexPresentation.Title = Format(PeriodTo, "DLF=D");
	
	// Read data
	GetRooms();
	#If НЕ WebClient Тогда
		Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 70, NStr("en='Opening...';ru='Открытие формы...';de='Öffnen des Formulars...'"), PictureLib.LongOperation); 
	#EndIf
	// Build chart
	ChartBuild();
	#If НЕ WebClient Тогда
		Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 90, NStr("en='Opening...';ru='Открытие формы...';de='Öffnen des Formulars...'"), PictureLib.LongOperation); 
	#EndIf
	// Set columns visibility
	If ЗначениеЗаполнено(CompareDate) Тогда
		Items.ColumnSecondDateIndexPresentation.Visible = True;
		Items.ColumnIcon.Visible = True;
	Else
		Items.ColumnSecondDateIndexPresentation.Visible = False;
		Items.ColumnIcon.Visible = False;
	EndIf;
	#If НЕ WebClient Тогда
		Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 100, NStr("en='Opening...';ru='Открытие формы...';de='Öffnen des Formulars...'"), PictureLib.LongOperation); 
	#EndIf
КонецПроцедуры //OnOpen

//-------------------------------------------------------------------------------------------------
&НаКлиенте
Процедура PeriodToOnChange(Item)
	#If НЕ WebClient Тогда
		Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 0, NStr("en='Refreshing...';ru='Обновление данных...';de='Die Daten werden aktualisiert…'"), PictureLib.LongOperation); 
	#EndIf
	// Set column title
	Items.ColumnIndexPresentation.Title = Format(PeriodTo, "DLF=D");
	
	CompositionDate = PeriodTo;
	
	// Rebuild charts and tables
	vDoCompareColumn = False;
	If ChoosePeriod = Items.ChoosePeriod.ChoiceList.FindByValue("0").Presentation Тогда
		If ЗначениеЗаполнено(CompareDate) Тогда
			vDoCompareColumn = True;
		EndIf;
	ElsIf ChoosePeriod = Items.ChoosePeriod.ChoiceList.FindByValue("1").Presentation Тогда
		If ЗначениеЗаполнено(CompareYear) And CompareYear <> "-//-" And CompareMonth <> NStr("en='-НЕ selected-';ru='-Не выбран-';de='-Nicht ausgewählt-'") Тогда
			vDoCompareColumn = True;
		EndIf;
	ElsIf ChoosePeriod = Items.ChoosePeriod.ChoiceList.FindByValue("2").Presentation Тогда
		If ЗначениеЗаполнено(CompareYear) And CompareYear <> "-//-" And CompareQuarter <> NStr("en='-НЕ selected-';ru='-Не выбран-';de='-Nicht ausgewählt-'") Тогда
			vDoCompareColumn = True;
		EndIf;
	Else 
		If ЗначениеЗаполнено(CompareYear) And CompareYear <> "-//-" Тогда
			vDoCompareColumn = True;
		EndIf;
	EndIf;
	#If НЕ WebClient Тогда
		Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 30, NStr("en='Refreshing...';ru='Обновление данных...';de='Die Daten werden aktualisiert…'"), PictureLib.LongOperation); 
	#EndIf
	If vDoCompareColumn Тогда
		GetCompareRooms();
		Items.GroupCharts.Visible = False;
	Else
		GetRooms();
		Items.GroupCharts.Visible = True;
	EndIf;
	#If НЕ WebClient Тогда
		Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 60, NStr("en='Refreshing...';ru='Обновление данных...';de='Die Daten werden aktualisiert…'"), PictureLib.LongOperation); 
	#EndIf
	ChartBuild();
	
	// Set columns visibility
	If ЗначениеЗаполнено(CompareDate) Тогда
		Items.ColumnSecondDateIndexPresentation.Visible = True;
		Items.ColumnIcon.Visible = True;
	Else
		Items.ColumnSecondDateIndexPresentation.Visible = False;
		Items.ColumnIcon.Visible = False;
	EndIf;
	#If НЕ WebClient Тогда
		Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 100, NStr("en='Refreshing...';ru='Обновление данных...';de='Die Daten werden aktualisiert…'"), PictureLib.LongOperation); 
	#EndIf
КонецПроцедуры //PeriodToOnChange

//-------------------------------------------------------------------------------------------------
&НаКлиенте
Процедура HotelOnChange(Item)
	#If НЕ WebClient Тогда
		Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 10, NStr("en='Refreshing...';ru='Обновление данных...';de='Die Daten werden aktualisiert…'"), PictureLib.LongOperation); 
	#EndIf
	// Rebuild charts and tables
	vDoCompareColumn = False;
	If ChoosePeriod = Items.ChoosePeriod.ChoiceList.FindByValue("0").Presentation Тогда
		If ЗначениеЗаполнено(CompareDate) Тогда
			vDoCompareColumn = True;
		EndIf;
	ElsIf ChoosePeriod = Items.ChoosePeriod.ChoiceList.FindByValue("1").Presentation Тогда
		If ЗначениеЗаполнено(CompareYear) And CompareYear <> "-//-" And CompareMonth <> NStr("en='-НЕ selected-';ru='-Не выбран-';de='-Nicht ausgewählt-'") Тогда
			vDoCompareColumn = True;
		EndIf;
	ElsIf ChoosePeriod = Items.ChoosePeriod.ChoiceList.FindByValue("2").Presentation Тогда
		If ЗначениеЗаполнено(CompareYear) And CompareYear <> "-//-" And CompareQuarter <> NStr("en='-НЕ selected-';ru='-Не выбран-';de='-Nicht ausgewählt-'") Тогда
			vDoCompareColumn = True;
		EndIf;
	Else 
		If ЗначениеЗаполнено(CompareYear) And CompareYear <> "-//-" Тогда
			vDoCompareColumn = True;
		EndIf;
	EndIf;
	#If НЕ WebClient Тогда
		Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 30, NStr("en='Refreshing...';ru='Обновление данных...';de='Die Daten werden aktualisiert…'"), PictureLib.LongOperation); 
	#EndIf
	If vDoCompareColumn Тогда
		GetCompareRooms();
	Else
		GetRooms();
	EndIf;
	#If НЕ WebClient Тогда
		Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 60, NStr("en='Refreshing...';ru='Обновление данных...';de='Die Daten werden aktualisiert…'"), PictureLib.LongOperation); 
	#EndIf
	ChartBuild();
	#If НЕ WebClient Тогда
		Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 100, NStr("en='Refreshing...';ru='Обновление данных...';de='Die Daten werden aktualisiert…'"), PictureLib.LongOperation); 
	#EndIf
КонецПроцедуры //HotelOnChange

//-------------------------------------------------------------------------------------------------
&НаКлиенте
Процедура CommandGenerateReports(Command)
	#If НЕ WebClient Тогда
		Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 10, NStr("en='Print...';ru='Открытие печатной формы...';de='Öffnen des Druckformulars...'"), PictureLib.LongOperation); 
	#EndIf
	// Open report form
	GetReport();
	#If НЕ WebClient Тогда
		Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 100, NStr("en='Print...';ru='Открытие печатной формы...';de='Öffnen des Druckformulars...'"), PictureLib.LongOperation); 
	#EndIf
КонецПроцедуры //CommandGenerateReports

//-------------------------------------------------------------------------------------------------
&НаКлиенте
Процедура CompareDateOnChange(Item)
	#If НЕ WebClient Тогда
		Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 0, NStr("en='Refreshing...';ru='Обновление данных...';de='Die Daten werden aktualisiert…'"), PictureLib.LongOperation); 
	#EndIf
	// Fill indexes for second date
	If ЗначениеЗаполнено(CompareDate) Тогда
		Items.ColumnSecondDateIndexPresentation.Title = Format(CompareDate, "DF=dd.MM.yyyy");
		GetCompareRooms();
	EndIf;
	#If НЕ WebClient Тогда
		Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 80, NStr("en='Refreshing...';ru='Обновление данных...';de='Die Daten werden aktualisiert…'"), PictureLib.LongOperation); 
	#EndIf
	ChartBuild();
	// Set columns visibility
	If ЗначениеЗаполнено(CompareDate) Тогда
		Items.ColumnSecondDateIndexPresentation.Visible = True;
		Items.ColumnIcon.Visible = True;
		Items.GroupCharts.Visible = False;
	Else
		Items.ColumnSecondDateIndexPresentation.Visible = False;
		Items.ColumnIcon.Visible = False;
		Items.GroupCharts.Visible = True;
	EndIf;
	#If НЕ WebClient Тогда
		Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 100, NStr("en='Refreshing...';ru='Обновление данных...';de='Die Daten werden aktualisiert…'"), PictureLib.LongOperation); 
	#EndIf
КонецПроцедуры //CompareDateOnChange

//-------------------------------------------------------------------------------------------------
&НаКлиенте
Процедура ChoosePeriodChoiceProcessing(pItem, pSelectedValue, pStandardProcessing)
	pStandardProcessing = False;
	vSelectedValue = pItem.ChoiceList.FindByValue(pSelectedValue).Presentation;
	If ChoosePeriod <> vSelectedValue Тогда
		Items.ColumnSecondDateIndexPresentation.Visible = False;
		Items.ColumnIcon.Visible = False;
		ChoosePeriod = vSelectedValue;
		If pSelectedValue = "0" Тогда
			Items.PeriodDay.Visible = True;
			Items.SelYear.Visible = False;
			Items.SelQuarter.Visible = False;
			Items.SelMonth.Visible = False;
			Items.CompareYear.Visible = False;
			Items.CompareYear.TitleLocation = FormItemTitleLocation.None;
			Items.CompareQuarter.Visible = False;
			Items.CompareMonth.Visible = False;
			Items.GroupCharts.Visible = True;
			PeriodToOnChange(Items.ПериодПо);
		ElsIf pSelectedValue = "1" Тогда
			Items.PeriodDay.Visible = False;
			Items.SelYear.Visible = True;
			Items.SelQuarter.Visible = False;
			Items.SelMonth.Visible = True;
			CompareYear = "-//-";
			Items.CompareYear.Visible = True;
			Items.CompareYear.TitleLocation = FormItemTitleLocation.None;
			Items.CompareQuarter.Visible = False;
			CompareMonth = NStr("en='-НЕ selected-';ru='-Не выбран-';de='-Nicht ausgewählt-'");
			Items.CompareMonth.Visible = True;
			Items.GroupCharts.Visible = True;
			SelMonthOnChange(Items.SelMonth);
		ElsIf pSelectedValue = "2" Тогда
			Items.PeriodDay.Visible = False;
			Items.SelYear.Visible = True;
			Items.SelQuarter.Visible = True;
			Items.SelMonth.Visible = False;
			CompareYear = "-//-";
			Items.CompareYear.Visible = True;
			Items.CompareYear.TitleLocation = FormItemTitleLocation.None;
			CompareQuarter = NStr("en='-НЕ selected-';ru='-Не выбран-';de='-Nicht ausgewählt-'");
			Items.CompareQuarter.Visible = True;
			Items.CompareMonth.Visible = False;
			Items.GroupCharts.Visible = True;
			SelQuarterOnChange(Items.SelQuarter);
		Else
			Items.PeriodDay.Visible = False;
			Items.SelYear.Visible = True;
			Items.SelQuarter.Visible = False;
			Items.SelMonth.Visible = False;
			CompareYear = "-//-";
			Items.CompareYear.Visible = True;
			Items.CompareYear.TitleLocation = FormItemTitleLocation.Auto;
			Items.CompareQuarter.Visible = False;
			Items.CompareMonth.Visible = False;
			Items.GroupCharts.Visible = True;
			SelYearOnChange(Items.SelYear, True);
		EndIf;
	EndIf;
КонецПроцедуры //ChoosePeriodChoiceProcessing

//-------------------------------------------------------------------------------------------------
&НаКлиенте
Процедура SelYearChoiceProcessing(pItem, pSelectedValue, pStandardProcessing)
	pStandardProcessing = False;
	SelYear = pItem.ChoiceList.FindByValue(pSelectedValue).Presentation;
	CompositionDate = Date(Number(SelYear), Month(CompositionDate), 1,1,1,1);
	SelYearOnChange(pItem);
КонецПроцедуры //SelYearChoiceProcessing

//-------------------------------------------------------------------------------------------------
&НаКлиенте
Процедура SelQuarterChoiceProcessing(pItem, pSelectedValue, pStandardProcessing)
	pStandardProcessing = False;
	SelQuarter = pItem.ChoiceList.FindByValue(pSelectedValue).Presentation;
	CompositionDate = Date(Number(SelYear), Number(pSelectedValue)*3, 1,1,1,1);
	SelQuarterOnChange(pItem);
КонецПроцедуры //SelQuarterChoiceProcessing

//-------------------------------------------------------------------------------------------------
&НаКлиенте
Процедура SelMonthChoiceProcessing(pItem, pSelectedValue, pStandardProcessing)
	pStandardProcessing = False;
	SelMonth = pItem.ChoiceList.FindByValue(pSelectedValue).Presentation;
	MonthNumber = pSelectedValue;
	CompositionDate = Date(Number(SelYear), Number(pSelectedValue), 1,1,1,1);
	SelMonthOnChange(pItem);
КонецПроцедуры //SelMonthChoiceProcessing

//-------------------------------------------------------------------------------------------------
&НаКлиенте
Процедура SelYearOnChange(pItem, pOnChoose = False)
	#If НЕ WebClient Тогда
		Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 10, NStr("en='Refreshing...';ru='Обновление данных...';de='Die Daten werden aktualisiert…'"), PictureLib.LongOperation); 
	#EndIf
	If pOnChoose = Неопределено Тогда
		pOnChoose = False;
	EndIf;
	If НЕ ЗначениеЗаполнено(SelYear) Тогда
		SelYear = Format(Year(CurrentDate()), "ND=4; NFD=0; NG=");
	EndIf;
	If Number(SelYear) < 1950 Тогда
		SelYear = "1950";
	EndIf;
	CompositionDate = Date(Number(SelYear), Month(CompositionDate), 1,1,1,1);
	If НЕ Items.SelMonth.Visible AND НЕ Items.SelQuarter.Visible Тогда
		// Set column title
		Items.ColumnIndexPresentation.Title = Format(SelYear, "ND=4; NFD=0; NG=");
	ElsIf Items.SelMonth.Visible Тогда
		// Set column title
		Items.ColumnIndexPresentation.Title = SelMonth+" "+Format(SelYear, "ND=4; NFD=0; NG=");
	ElsIf Items.SelQuarter.Visible Тогда
		// Set column title
		Items.ColumnIndexPresentation.Title = SelQuarter+" "+Format(SelYear, "ND=4; NFD=0; NG=");
	EndIf;
	#If НЕ WebClient Тогда
		Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 30, NStr("en='Refreshing...';ru='Обновление данных...';de='Die Daten werden aktualisiert…'"), PictureLib.LongOperation); 
	#EndIf
	If pItem.EditText <> Format(SelYear, "ND=4; NFD=0; NG=") Or pOnChoose Тогда
		// Rebuild charts and tables
		vDoCompareColumn = False;
		If ChoosePeriod = Items.ChoosePeriod.ChoiceList.FindByValue("0").Presentation Тогда
			If ЗначениеЗаполнено(CompareDate) Тогда
				vDoCompareColumn = True;
			EndIf;
		ElsIf ChoosePeriod = Items.ChoosePeriod.ChoiceList.FindByValue("1").Presentation Тогда
			If ЗначениеЗаполнено(CompareYear) And CompareYear <> "-//-" And CompareMonth <> NStr("en='-НЕ selected-';ru='-Не выбран-';de='-Nicht ausgewählt-'") Тогда
				vDoCompareColumn = True;
			EndIf;
		ElsIf ChoosePeriod = Items.ChoosePeriod.ChoiceList.FindByValue("2").Presentation Тогда
			If ЗначениеЗаполнено(CompareYear) And CompareYear <> "-//-" And CompareQuarter <> NStr("en='-НЕ selected-';ru='-Не выбран-';de='-Nicht ausgewählt-'") Тогда
				vDoCompareColumn = True;
			EndIf;
		Else 
			If ЗначениеЗаполнено(CompareYear) And CompareYear <> "-//-" Тогда
				vDoCompareColumn = True;
			EndIf;
		EndIf;
		#If НЕ WebClient Тогда
			Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 50, NStr("en='Refreshing...';ru='Обновление данных...';de='Die Daten werden aktualisiert…'"), PictureLib.LongOperation); 
		#EndIf
		If vDoCompareColumn Тогда
			GetCompareRooms();
		Else
			GetRooms();
		EndIf;
		#If НЕ WebClient Тогда
			Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 70, NStr("en='Refreshing...';ru='Обновление данных...';de='Die Daten werden aktualisiert…'"), PictureLib.LongOperation); 
		#EndIf
		ChartBuild();
	EndIf;
	#If НЕ WebClient Тогда
		Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 100, NStr("en='Refreshing...';ru='Обновление данных...';de='Die Daten werden aktualisiert…'"), PictureLib.LongOperation); 
	#EndIf
КонецПроцедуры //SelYearOnChange

//-------------------------------------------------------------------------------------------------
&НаКлиенте
Процедура SelMonthOnChange(pItem)
	#If НЕ WebClient Тогда
		Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 10, NStr("en='Refreshing...';ru='Обновление данных...';de='Die Daten werden aktualisiert…'"), PictureLib.LongOperation); 
	#EndIf
	If НЕ ЗначениеЗаполнено(SelYear) Тогда
		SelYear = Format(Year(CurrentDate()), "ND=4; NFD=0; NG=");
	EndIf;
	// Set column title
	Items.ColumnIndexPresentation.Title = SelMonth+" "+Format(SelYear, "ND=4; NFD=0; NG=");
	CompositionDate = Date(Number(SelYear), Number(MonthNumber), 1,1,1,1);
	If pItem.EditText <> SelMonth Тогда
		// Rebuild charts and tables
		vDoCompareColumn = False;
		If ChoosePeriod = Items.ChoosePeriod.ChoiceList.FindByValue("0").Presentation Тогда
			If ЗначениеЗаполнено(CompareDate) Тогда
				vDoCompareColumn = True;
			EndIf;
		ElsIf ChoosePeriod = Items.ChoosePeriod.ChoiceList.FindByValue("1").Presentation Тогда
			If ЗначениеЗаполнено(CompareYear) And CompareYear <> "-//-" And CompareMonth <> NStr("en='-НЕ selected-';ru='-Не выбран-';de='-Nicht ausgewählt-'") Тогда
				vDoCompareColumn = True;
			EndIf;
		ElsIf ChoosePeriod = Items.ChoosePeriod.ChoiceList.FindByValue("2").Presentation Тогда
			If ЗначениеЗаполнено(CompareYear) And CompareYear <> "-//-" And CompareQuarter <> NStr("en='-НЕ selected-';ru='-Не выбран-';de='-Nicht ausgewählt-'") Тогда
				vDoCompareColumn = True;
			EndIf;
		Else 
			If ЗначениеЗаполнено(CompareYear) And CompareYear <> "-//-" Тогда
				vDoCompareColumn = True;
			EndIf;
		EndIf;
		#If НЕ WebClient Тогда
			Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 30, NStr("en='Refreshing...';ru='Обновление данных...';de='Die Daten werden aktualisiert…'"), PictureLib.LongOperation); 
		#EndIf
		If vDoCompareColumn Тогда
			GetCompareRooms();
		Else
			GetRooms();
		EndIf;
		#If НЕ WebClient Тогда
			Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 60, NStr("en='Refreshing...';ru='Обновление данных...';de='Die Daten werden aktualisiert…'"), PictureLib.LongOperation); 
		#EndIf
		ChartBuild();
	EndIf;  
	#If НЕ WebClient Тогда
		Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 100, NStr("en='Refreshing...';ru='Обновление данных...';de='Die Daten werden aktualisiert…'"), PictureLib.LongOperation); 
	#EndIf
КонецПроцедуры //SelMonthOnChange

//-------------------------------------------------------------------------------------------------
&НаКлиенте
Процедура SelQuarterOnChange(pItem)
	#If НЕ WebClient Тогда
		Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 10, NStr("en='Refreshing...';ru='Обновление данных...';de='Die Daten werden aktualisiert…'"), PictureLib.LongOperation); 
	#EndIf
	If НЕ ЗначениеЗаполнено(SelYear) Тогда
		SelYear = Format(Year(CurrentDate()), "ND=4; NFD=0; NG=");
	EndIf;
	// Set column title
	Items.ColumnIndexPresentation.Title = SelQuarter+" "+Format(SelYear, "ND=4; NFD=0; NG=");
	If pItem.EditText <> SelQuarter Тогда
		// Rebuild charts and tables
		vDoCompareColumn = False;
		If ChoosePeriod = Items.ChoosePeriod.ChoiceList.FindByValue("0").Presentation Тогда
			If ЗначениеЗаполнено(CompareDate) Тогда
				vDoCompareColumn = True;
			EndIf;
		ElsIf ChoosePeriod = Items.ChoosePeriod.ChoiceList.FindByValue("1").Presentation Тогда
			If ЗначениеЗаполнено(CompareYear) And CompareYear <> "-//-" And CompareMonth <> NStr("en='-НЕ selected-';ru='-Не выбран-';de='-Nicht ausgewählt-'") Тогда
				vDoCompareColumn = True;
			EndIf;
		ElsIf ChoosePeriod = Items.ChoosePeriod.ChoiceList.FindByValue("2").Presentation Тогда
			If ЗначениеЗаполнено(CompareYear) And CompareYear <> "-//-" And CompareQuarter <> NStr("en='-НЕ selected-';ru='-Не выбран-';de='-Nicht ausgewählt-'") Тогда
				vDoCompareColumn = True;
			EndIf;
		Else 
			If ЗначениеЗаполнено(CompareYear) And CompareYear <> "-//-" Тогда
				vDoCompareColumn = True;
			EndIf;
		EndIf;
		#If НЕ WebClient Тогда
			Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 30, NStr("en='Refreshing...';ru='Обновление данных...';de='Die Daten werden aktualisiert…'"), PictureLib.LongOperation); 
		#EndIf
		If vDoCompareColumn Тогда
			GetCompareRooms();
		Else
			GetRooms();
		EndIf;
		#If НЕ WebClient Тогда
			Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 60, NStr("en='Refreshing...';ru='Обновление данных...';de='Die Daten werden aktualisiert…'"), PictureLib.LongOperation); 
		#EndIf
		ChartBuild();
	EndIf;
	#If НЕ WebClient Тогда
		Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 100, NStr("en='Refreshing...';ru='Обновление данных...';de='Die Daten werden aktualisiert…'"), PictureLib.LongOperation); 
	#EndIf
КонецПроцедуры //SelQuarterOnChange

//-------------------------------------------------------------------------------------------------
&НаКлиенте
Процедура CompareYearChoiceProcessing(pItem, pSelectedValue, pStandardProcessing)
	pStandardProcessing = False;
	CompareYear = pItem.ChoiceList.FindByValue(pSelectedValue).Presentation;
	If pSelectedValue <> "-//-" Тогда
		CompareCompositionDate = Date(Number(CompareYear), Month(CompareCompositionDate), 1,1,1,1);
		CompareYearOnChange(pItem);
	Else
		Items.ColumnSecondDateIndexPresentation.Visible = False;
		Items.ColumnIcon.Visible = False;
		Items.GroupCharts.Visible = True;
	EndIf;
КонецПроцедуры //CompareYearChoiceProcessing

//-------------------------------------------------------------------------------------------------
&НаКлиенте
Процедура CompareQuarterChoiceProcessing(pItem, pSelectedValue, pStandardProcessing)
	pStandardProcessing = False;
	CompareQuarter = pItem.ChoiceList.FindByValue(pSelectedValue).Presentation;
	If pSelectedValue <> "0" Тогда
		If CompareYear = "-//-" Тогда
			vCompareYear = Format(Year(CurrentDate()), "ND=4; NFD=0; NG=");
			If StrLen(vCompareYear) > 4 Тогда
				CompareYear = StrReplace(vCompareYear, Mid(vCompareYear, 2, 1), "");
			Else
				CompareYear = vCompareYear;
			EndIf;
		EndIf;
		CompareCompositionDate = Date(Number(CompareYear), Number(pSelectedValue)*3, 1,1,1,1);
		CompareQuarterOnChange(pItem);
	Else
		Items.ColumnSecondDateIndexPresentation.Visible = False;
		Items.ColumnIcon.Visible = False;
		Items.GroupCharts.Visible = True;
	EndIf;
КонецПроцедуры //CompareQuarterChoiceProcessing

//-------------------------------------------------------------------------------------------------
&НаКлиенте
Процедура CompareMonthChoiceProcessing(pItem, pSelectedValue, pStandardProcessing)
	pStandardProcessing = False;
	CompareMonth = pItem.ChoiceList.FindByValue(pSelectedValue).Presentation;
	If pSelectedValue <> "0" Тогда
		CompareMonthNumber = pSelectedValue;
		If CompareYear = "-//-" Тогда
			vCompareYear = Format(Year(CurrentDate()), "ND=4; NFD=0; NG=");
			If StrLen(vCompareYear) > 4 Тогда
				CompareYear = StrReplace(vCompareYear, Mid(vCompareYear, 2, 1), "");
			Else
				CompareYear = vCompareYear;
			EndIf;
		EndIf;
		CompareCompositionDate = Date(Number(CompareYear), Number(pSelectedValue), 1,1,1,1);
		CompareMonthOnChange(pItem);
	Else
		Items.ColumnSecondDateIndexPresentation.Visible = False;
		Items.ColumnIcon.Visible = False;
		Items.GroupCharts.Visible = True;
	EndIf;
КонецПроцедуры //CompareMonthChoiceProcessing

//-------------------------------------------------------------------------------------------------
&НаКлиенте
Процедура CompareYearOnChange(pItem)
	#If НЕ WebClient Тогда
		Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 10, NStr("en='Refreshing...';ru='Обновление данных...';de='Die Daten werden aktualisiert…'"), PictureLib.LongOperation); 
	#EndIf
	If Number(CompareYear) < 1950 Тогда
		CompareYear = "1950";
	EndIf;
	CompareCompositionDate = Date(Number(CompareYear), Month(CompareCompositionDate), 1,1,1,1);
	// Fill indexes for second date
	If Items.SelMonth.Visible Тогда
		#If НЕ WebClient Тогда
			Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 50, NStr("en='Refreshing...';ru='Обновление данных...';de='Die Daten werden aktualisiert…'"), PictureLib.LongOperation); 
		#EndIf
		If CompareMonth <> NStr("en='-НЕ selected-';ru='-Не выбран-';de='-Nicht ausgewählt-'") And CompareYear <> "-//-" Тогда
			GetCompareRooms();
			Items.ColumnSecondDateIndexPresentation.Visible = True;
			Items.ColumnIcon.Visible = True;
			Items.ColumnSecondDateIndexPresentation.Title = CompareMonth+" "+CompareYear;
			Items.GroupCharts.Visible = False;
		Else
			Items.ColumnSecondDateIndexPresentation.Visible = False;
			Items.ColumnIcon.Visible = False;
			Items.GroupCharts.Visible = True;
		EndIf;
	ElsIf Items.SelQuarter.Visible Тогда
		#If НЕ WebClient Тогда
			Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 50, NStr("en='Refreshing...';ru='Обновление данных...';de='Die Daten werden aktualisiert…'"), PictureLib.LongOperation); 
		#EndIf
		If CompareQuarter <> NStr("en='-НЕ selected-';ru='-Не выбран-';de='-Nicht ausgewählt-'") And CompareYear <> "-//-" Тогда
			GetCompareRooms();
			Items.ColumnSecondDateIndexPresentation.Visible = True;
			Items.ColumnIcon.Visible = True;
			Items.ColumnSecondDateIndexPresentation.Title = CompareQuarter+" "+CompareYear;
			Items.GroupCharts.Visible = False;
		Else
			Items.ColumnSecondDateIndexPresentation.Visible = False;
			Items.ColumnIcon.Visible = False;
			Items.GroupCharts.Visible = True;
		EndIf;
	Else
		#If НЕ WebClient Тогда
			Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 50, NStr("en='Refreshing...';ru='Обновление данных...';de='Die Daten werden aktualisiert…'"), PictureLib.LongOperation); 
		#EndIf
		If CompareYear <> "-//-" Тогда
			GetCompareRooms();
			Items.ColumnSecondDateIndexPresentation.Visible = True;
			Items.ColumnIcon.Visible = True;
			Items.ColumnSecondDateIndexPresentation.Title = CompareYear;
			Items.GroupCharts.Visible = False;
		Else
			Items.ColumnSecondDateIndexPresentation.Visible = False;
			Items.ColumnIcon.Visible = False;
			Items.GroupCharts.Visible = True;
		EndIf;
	EndIf;
	#If НЕ WebClient Тогда
		Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 100, NStr("en='Refreshing...';ru='Обновление данных...';de='Die Daten werden aktualisiert…'"), PictureLib.LongOperation); 
	#EndIf
КонецПроцедуры //CompareYearOnChange

//-------------------------------------------------------------------------------------------------
&НаКлиенте
Процедура CompareMonthOnChange(pItem)
	#If НЕ WebClient Тогда
		Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 10, NStr("en='Refreshing...';ru='Обновление данных...';de='Die Daten werden aktualisiert…'"), PictureLib.LongOperation); 
	#EndIf
	If НЕ ЗначениеЗаполнено(CompareYear) Тогда
		CompareYear = Format(Year(CurrentDate()), "ND=4; NFD=0; NG=");
	EndIf;
	CompareCompositionDate = Date(Number(CompareYear), Number(CompareMonthNumber), 1,1,1,1);
	#If НЕ WebClient Тогда
		Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 50, NStr("en='Refreshing...';ru='Обновление данных...';de='Die Daten werden aktualisiert…'"), PictureLib.LongOperation); 
	#EndIf
	If CompareMonth <> NStr("en='-НЕ selected-';ru='-Не выбран-';de='-Nicht ausgewählt-'") And CompareYear <> "-//-" Тогда
		GetCompareRooms();
		Items.ColumnSecondDateIndexPresentation.Visible = True;
		Items.ColumnIcon.Visible = True;
		Items.ColumnSecondDateIndexPresentation.Title = CompareMonth+" "+CompareYear;
		Items.GroupCharts.Visible = False;
	Else
		Items.ColumnSecondDateIndexPresentation.Visible = False;
		Items.ColumnIcon.Visible = False;
		Items.GroupCharts.Visible = True;
	EndIf;
	#If НЕ WebClient Тогда
		Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 100, NStr("en='Refreshing...';ru='Обновление данных...';de='Die Daten werden aktualisiert…'"), PictureLib.LongOperation); 
	#EndIf
КонецПроцедуры //CompareMonthOnChange

//-------------------------------------------------------------------------------------------------
&НаКлиенте
Процедура CompareQuarterOnChange(pItem)
	#If НЕ WebClient Тогда
		Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 10, NStr("en='Refreshing...';ru='Обновление данных...';de='Die Daten werden aktualisiert…'"), PictureLib.LongOperation); 
	#EndIf
	If НЕ ЗначениеЗаполнено(CompareYear) Тогда
		CompareYear = Format(Year(CurrentDate()), "ND=4; NFD=0; NG=");
	EndIf;
	#If НЕ WebClient Тогда
		Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 50, NStr("en='Refreshing...';ru='Обновление данных...';de='Die Daten werden aktualisiert…'"), PictureLib.LongOperation); 
	#EndIf
	If CompareQuarter <> NStr("en='-НЕ selected-';ru='-Не выбран-';de='-Nicht ausgewählt-'") And CompareYear <> "-//-" Тогда
		GetCompareRooms();
		Items.ColumnSecondDateIndexPresentation.Visible = True;
		Items.ColumnIcon.Visible = True;
		Items.ColumnSecondDateIndexPresentation.Title = CompareQuarter+" "+CompareYear;
		Items.GroupCharts.Visible = False;
	Else
		Items.ColumnSecondDateIndexPresentation.Visible = False;
		Items.ColumnIcon.Visible = False;
		Items.GroupCharts.Visible = True;
	EndIf;
	#If НЕ WebClient Тогда
		Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 100, NStr("en='Refreshing...';ru='Обновление данных...';de='Die Daten werden aktualisiert…'"), PictureLib.LongOperation); 
	#EndIf
КонецПроцедуры //CompareQuarterOnChange

//-------------------------------------------------------------------------------------------------
&НаКлиенте
Процедура CommandRefresh(pCommand)
	// Rebuild charts and tables
	vDoCompareColumn = False;
	If ChoosePeriod = Items.ChoosePeriod.ChoiceList.FindByValue("0").Presentation Тогда
		If ЗначениеЗаполнено(CompareDate) Тогда
			vDoCompareColumn = True;
		EndIf;
	ElsIf ChoosePeriod = Items.ChoosePeriod.ChoiceList.FindByValue("1").Presentation Тогда
		If ЗначениеЗаполнено(CompareYear) And CompareYear <> "-//-" And CompareMonth <> NStr("en='-НЕ selected-';ru='-Не выбран-';de='-Nicht ausgewählt-'") Тогда
			vDoCompareColumn = True;
		EndIf;
	ElsIf ChoosePeriod = Items.ChoosePeriod.ChoiceList.FindByValue("2").Presentation Тогда
		If ЗначениеЗаполнено(CompareYear) And CompareYear <> "-//-" And CompareQuarter <> NStr("en='-НЕ selected-';ru='-Не выбран-';de='-Nicht ausgewählt-'") Тогда
			vDoCompareColumn = True;
		EndIf;
	Else 
		If ЗначениеЗаполнено(CompareYear) And CompareYear <> "-//-" Тогда
			vDoCompareColumn = True;
		EndIf;
	EndIf;
	#If НЕ WebClient Тогда
		Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 30, NStr("en='Refreshing...';ru='Обновление данных...';de='Die Daten werden aktualisiert…'"), PictureLib.LongOperation); 
	#EndIf
	If vDoCompareColumn Тогда
		GetCompareRooms();
	Else
		GetRooms();
	EndIf;
	#If НЕ WebClient Тогда
		Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 60, NStr("en='Refreshing...';ru='Обновление данных...';de='Die Daten werden aktualisiert…'"), PictureLib.LongOperation); 
	#EndIf
	ChartBuild();
	#If НЕ WebClient Тогда
		Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 100, NStr("en='Refreshing...';ru='Обновление данных...';de='Die Daten werden aktualisiert…'"), PictureLib.LongOperation); 
	#EndIf
КонецПроцедуры //CommandRefresh

//-------------------------------------------------------------------------------------------------
&НаКлиенте
Процедура HotelClearing(pItem, pStandardProcessing)
	pStandardProcessing = False;
КонецПроцедуры //HotelClearing

//-------------------------------------------------------------------------------------------------
&НаКлиенте
Процедура HotelStartChoice(pItem, pChoiceData, pStandardProcessing)
	pStandardProcessing = False;
КонецПроцедуры //HotelStartChoice

//-------------------------------------------------------------------------------------------------
&НаКлиенте
Процедура HotelOpening(pItem, pStandardProcessing)
	pStandardProcessing = False;
КонецПроцедуры //HotelOpening

//-------------------------------------------------------------------------------------------------
Tabulation = "       ";
