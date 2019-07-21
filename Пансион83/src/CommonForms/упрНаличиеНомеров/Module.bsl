//&НаКлиенте
//Перем LastKidsNumber;
//
//&НаКлиенте
//Перем PeriodFromChangeMode;
//
////-----------------------------------------------------------------------------
//&AtServer
//Function GetQueryResource(pQryHours, pShowReportsInBeds, pLastVacant)
//	vVacant = 0;	
//	If pShowReportsInBeds Тогда
//		If pQryHours.BedsVacant = Null Тогда
//			vVacant = pLastVacant;
//		Else
//			vVacant = pQryHours.BedsVacant;
//		EndIf;
//	Else
//		If pQryHours.RoomsVacant = Null Тогда
//			vVacant = pLastVacant;
//		Else
//			vVacant = pQryHours.RoomsVacant;
//		EndIf;
//	EndIf;
//	Return vVacant;
//EndFunction //GetQueryResource
//
////-----------------------------------------------------------------------------
//&AtServer
//Процедура BuildReport(pTotalPriceTable = Неопределено) Экспорт
//	// Initialize number of days to output and period
//	If NumberOfDays <= 0 Тогда
//		If ShowPrices Тогда
//			NumberOfDays = 10;
//		Else
//			NumberOfDays = 28;
//		EndIf;
//	EndIf;
//	vNumberOfDays = NumberOfDays;
//	vDateFrom = BegOfDay(DateFrom);
//	vCurrentDateTime = ?(vDateFrom = BegOfDay(CurrentDate()), CurrentDate(), vDateFrom);
//	vCurrentDate = BegOfDay(vCurrentDateTime);
//	vDateTimeFrom = ?(vDateFrom = vCurrentDate, vCurrentDateTime, vDateFrom);
//	vDateTo = vDateFrom + 24*3600*(vNumberOfDays - 1);
//	vDateTimeTo = EndOfDay(vDateTo);
//	vShowReportsInBeds = ShowInBeds;
//	
//	vNextPeriod = DateFrom + (NumberOfDays-1)*86400;
//	vPrevPeriod = DateFrom - (NumberOfDays-1)*86400;
//	
//	Items.FormPrevPeriodButton.Title = Format(vPrevPeriod, "DF=dd.MM.yyyy");
//	Items.FormNextPeriodButton.Title = Format(vNextPeriod, "DF=dd.MM.yyyy");
//
//	// Get active events
//	//vEvents = cmGetEvents(vDateTimeFrom, vDateTimeTo, Гостиница);
//	
//	// Build and run query with ГруппаНомеров inventory balances
//	vQry = New Query();
//	vQry.Text =	
//	"SELECT
//	|	ЗагрузкаНомеров.Period AS Period,
//	|	ЗагрузкаНомеров.Гостиница AS Гостиница,
//	|	ЗагрузкаНомеров.Гостиница.ПорядокСортировки AS HotelSortCode,
//	|	ЗагрузкаНомеров.ТипНомера AS ТипНомера,
//	|	ЗагрузкаНомеров.ТипНомера.ПорядокСортировки AS RoomTypeSortCode,
//	|	ЗагрузкаНомеров.RoomsVacant AS RoomsVacant,
//	|	ЗагрузкаНомеров.BedsVacant AS BedsVacant
//	|FROM
//	|	(SELECT
//	|		BEGINOFPERIOD(RoomInventoryBalance.Period, DAY) AS Period,
//	|		RoomInventoryBalance.Гостиница AS Гостиница,
//	|		RoomInventoryBalance.ТипНомера AS ТипНомера,
//	|		MIN(CASE
//	|			WHEN &qRoomQuotaIsSet
//	|					AND &qDoWriteOff
//	|				THEN ISNULL(RoomQuotaBalances.ОстаетсяНомеров, 0)
//	|			WHEN &qRoomQuotaIsSet
//	|					AND NOT &qDoWriteOff
//	|					AND ISNULL(RoomInventoryBalance.RoomsVacantClosingBalance, 0) < ISNULL(RoomQuotaBalances.ОстаетсяНомеров, 0)
//	|				THEN ISNULL(RoomInventoryBalance.RoomsVacantClosingBalance, 0)
//	|			WHEN &qRoomQuotaIsSet
//	|					AND NOT &qDoWriteOff
//	|					AND ISNULL(RoomInventoryBalance.RoomsVacantClosingBalance, 0) >= ISNULL(RoomQuotaBalances.ОстаетсяНомеров, 0)
//	|				THEN ISNULL(RoomQuotaBalances.ОстаетсяНомеров, 0)
//	|			ELSE ISNULL(RoomInventoryBalance.RoomsVacantClosingBalance, 0)
//	|		END) AS RoomsVacant,
//	|		MIN(CASE
//	|			WHEN &qRoomQuotaIsSet
//	|					AND &qDoWriteOff
//	|				THEN ISNULL(RoomQuotaBalances.ОстаетсяМест, 0)
//	|			WHEN &qRoomQuotaIsSet
//	|					AND NOT &qDoWriteOff
//	|					AND ISNULL(RoomInventoryBalance.BedsVacantClosingBalance, 0) < ISNULL(RoomQuotaBalances.ОстаетсяМест, 0)
//	|				THEN ISNULL(RoomInventoryBalance.BedsVacantClosingBalance, 0)
//	|			WHEN &qRoomQuotaIsSet
//	|					AND NOT &qDoWriteOff
//	|					AND ISNULL(RoomInventoryBalance.BedsVacantClosingBalance, 0) >= ISNULL(RoomQuotaBalances.ОстаетсяМест, 0)
//	|				THEN ISNULL(RoomQuotaBalances.ОстаетсяМест, 0)
//	|			ELSE ISNULL(RoomInventoryBalance.BedsVacantClosingBalance, 0)
//	|		END) AS BedsVacant
//	|	FROM (
//	|		SELECT
//	|			BEGINOFPERIOD(DATEADD(RoomInventoryBalanceAndTurnovers.Period, SECOND, &qShiftInSeconds), DAY) AS Period,
//	|			RoomInventoryBalanceAndTurnovers.Гостиница AS Гостиница,
//	|			RoomInventoryBalanceAndTurnovers.ТипНомера AS ТипНомера,
//	|			MAX(RoomInventoryBalanceAndTurnovers.CounterClosingBalance) AS CounterClosingBalance,
//	|			MIN(ISNULL(RoomInventoryBalanceAndTurnovers.RoomsVacantClosingBalance, 0)) AS RoomsVacantClosingBalance,
//	|			MIN(ISNULL(RoomInventoryBalanceAndTurnovers.BedsVacantClosingBalance, 0)) AS BedsVacantClosingBalance
//	|		FROM
//	|			AccumulationRegister.ЗагрузкаНомеров.BalanceAndTurnovers(
//	|				&qDateTimeFrom,
//	|				&qDateTimeTo,
//	|				SECOND,
//	|				RegisterRecordsAndPeriodBoundaries,
//	|				&qHotelIsEmpty
//	|					OR Гостиница IN HIERARCHY (&qHotel)) AS RoomInventoryBalanceAndTurnovers
//	|		GROUP BY
//	|			BEGINOFPERIOD(DATEADD(RoomInventoryBalanceAndTurnovers.Period, SECOND, &qShiftInSeconds), DAY),
//	|			RoomInventoryBalanceAndTurnovers.Гостиница,
//	|			RoomInventoryBalanceAndTurnovers.ТипНомера
//	|		) AS RoomInventoryBalance
//	|			LEFT JOIN (SELECT
//	|				BEGINOFPERIOD(RoomQuotaSalesBalanceAndTurnovers.Period, DAY) AS Period,
//	|				RoomQuotaSalesBalanceAndTurnovers.Гостиница AS Гостиница,
//	|				RoomQuotaSalesBalanceAndTurnovers.ТипНомера AS ТипНомера,
//	|				RoomQuotaSalesBalanceAndTurnovers.CounterClosingBalance AS CounterClosingBalance,
//	|				RoomQuotaSalesBalanceAndTurnovers.RoomsInQuotaClosingBalance AS НомеровКвота,
//	|				RoomQuotaSalesBalanceAndTurnovers.BedsInQuotaClosingBalance AS МестКвота,
//	|				RoomQuotaSalesBalanceAndTurnovers.RoomsRemainsClosingBalance AS ОстаетсяНомеров,
//	|				RoomQuotaSalesBalanceAndTurnovers.BedsRemainsClosingBalance AS ОстаетсяМест
//	|			FROM
//	|				AccumulationRegister.ПродажиКвот.BalanceAndTurnovers(
//	|						&qDateTimeFrom,
//	|						&qDateTimeTo,
//	|						Day,
//	|						RegisterRecordsAndPeriodBoundaries,
//	|						(&qHotelIsEmpty
//	|							OR Гостиница = &qHotel)
//	|							AND &qRoomQuotaIsSet
//	|							AND КвотаНомеров = &qRoomQuota) AS RoomQuotaSalesBalanceAndTurnovers) AS RoomQuotaBalances
//	|			ON RoomInventoryBalance.Гостиница = RoomQuotaBalances.Гостиница
//	|				AND RoomInventoryBalance.ТипНомера = RoomQuotaBalances.ТипНомера
//	|				AND BEGINOFPERIOD(RoomInventoryBalance.Period, DAY) = BEGINOFPERIOD(RoomQuotaBalances.Period, DAY)
//	|	GROUP BY
//	|		BEGINOFPERIOD(RoomInventoryBalance.Period, DAY),
//	|		RoomInventoryBalance.Гостиница,
//	|		RoomInventoryBalance.ТипНомера
//	|	) AS ЗагрузкаНомеров " +
//	?(ЗначениеЗаполнено(ПараметрыСеанса.ТекПользователь.Контрагент)," WHERE	ЗагрузкаНомеров.RoomsVacant <> 0	AND ЗагрузкаНомеров.BedsVacant <> 0", "")+
//	" ORDER BY
//	|	HotelSortCode,
//	|	RoomTypeSortCode,
//	|	Period
//	|TOTALS
//	|	SUM(RoomsVacant),
//	|	SUM(BedsVacant)
//	|BY
//	|	Гостиница HIERARCHY,
//	|	ТипНомера HIERARCHY,
//	|	Period";
//
//	vQry.SetParameter("qHotel", Гостиница);
//	vQry.SetParameter("qHotelIsEmpty", НЕ ЗначениеЗаполнено(Гостиница));
//	vQry.SetParameter("qRoomQuota", RoomQuota);
//	vQry.SetParameter("qRoomQuotaIsSet", ЗначениеЗаполнено(RoomQuota));
//	vQry.SetParameter("qDoWriteOff", ?(ЗначениеЗаполнено(RoomQuota), RoomQuota.DoWriteOff, False));
//	vQry.SetParameter("qDateTimeFrom", vDateTimeFrom);
//	vQry.SetParameter("qDateTimeTo", vDateTimeTo);
//	vQry.SetParameter("qShiftInSeconds", ?(ЗначениеЗаполнено(Тариф), -(Тариф.ReferenceHour - BegOfDay(Тариф.ReferenceHour)), -43200));
//	vQryRes = vQry.Execute();
//	
//	// Fill end of day balances and periods
//	vPeriods = New СписокЗначений();
//	vQryHotels = vQryRes.Choose(QueryResultIteration.ByGroups, "Гостиница");
//	While vQryHotels.Next() Do
//		// Save all periods where vacant resource is changed
//		vQryHours = vQryHotels.Choose(QueryResultIteration.ByGroups, "Period", "ALL");
//		While vQryHours.Next() Do
//			vPeriod = BegOfDay(vQryHours.Period);
//			If (vPeriod < BegOfDay(vDateTimeFrom)) Or (vPeriod > EndOfDay(vDateTimeTo)) Тогда
//				Continue;
//			EndIf;
//			If vPeriods.FindByValue(vPeriod) = Неопределено Тогда
//				vPeriods.Add(vPeriod); 
//			EndIf;
//		EndDo;
//	EndDo;
//	// Sort periods chronologically
//	vPeriods.SortByValue();
//	NumberOfPeriods = vPeriods.Count();
//	
//	// Draw header
//	vSpreadsheet = Report;
//	vSpreadsheet.Clear();
//	vSpreadsheet.ShowGroups = True;
//	If ShowPrices Тогда 
//		vTemplate = GetCommonTemplate("AvailableRoomsReportTemplateWithPrices");
//	Else
//		vTemplate = GetCommonTemplate("ШаблонСправкиНаличииНомеров");
//	EndIf;
//	vArea = vTemplate.GetArea("Header|NamesColumn");
//	If vShowReportsInBeds Тогда
//		vArea.Parameters.mReportHeaderText = NStr("en='Vacant beds';ru='Свободные места';de='Freie Betten'");
//	Else
//		vArea.Parameters.mReportHeaderText = NStr("en='Vacant rooms';ru='Свободные номера';de='Freie Zimmer'");
//	EndIf;
//	vSpreadsheet.Put(vArea);
//	
//	// Draw occupation percent
//	vEndOfPrevDay = False;
//	vDayGroup = False;
//	vLastDate = Неопределено;
//	
//	vOccupationPercentList = GetOccupationPercent(Гостиница,vDateTimeFrom,vDateTimeTo);
//	For Each vPeriodItem In vPeriods Do
//		vPeriod = vPeriodItem.Value;
//		vCurDate = BegOfDay(vPeriod);
//		If vLastDate = Неопределено Or vCurDate <> vLastDate Тогда
//			vLastDate = vCurDate;
//			vEndOfPrevDay = True;
//		EndIf;
//		mDay = Day(vCurDate);
//		mDayOfWeek = cmGetDayOfWeekName(WeekDay(vCurDate), True);
//		mMonth = Format(vPeriod, "DF=MMMM");		
//		
//		If vEndOfPrevDay Тогда
//			vEndOfPrevDay = False;
//			If vCurDate = BegOfMonth(vCurDate) Or vCurDate = vDateFrom Тогда
//				vArea = vTemplate.GetArea("Header|FirstDayOfMonth");
//				vArea.Parameters.mMonth = mMonth;
//			ElsIf WeekDay(vCurDate) = 1 Тогда
//				vArea = vTemplate.GetArea("Header|FirstDayOfWeek");
//			Else
//				vArea = vTemplate.GetArea("Header|FirstHourOfDay");
//			EndIf;
//			vArea.Parameters.mDay = mDay;
//			vArea.Parameters.mDayOfWeek = mDayOfWeek;
//			
//			If ShowPrices Тогда
//				vFilter = vOccupationPercentList.FindRows(New Structure("Period",vCurDate));
//				If vFilter.Count()>0 Тогда
//					
//					vRow = vFilter[0];
//					vTotalRooms		= vRow.ВсегоНомеров;
//					vRoomsBlocked 	= -vRow.ЗаблокНомеров;
//					vRoomsRented 	= vRow.ПроданоНомеров;
//					
//					vArea.Parameters.mPercent = String(Round(?(vTotalRooms=0,0,100*vRoomsRented/(vTotalRooms-vRoomsBlocked)),2))+"%";
//				Else
//					vArea.Parameters.mPercent = "0%";
//				EndIf;	
//			EndIf;
//		Else
//			vArea = vTemplate.GetArea("Header|Day");
//		EndIf;
//		vSpreadsheet.Join(vArea);
//	EndDo;
//	
//	// Output events
//	//If vEvents.Count() > 0 Тогда
//	//	vArea = vTemplate.GetArea("EventRow|NamesColumn");
//	//	vSpreadsheet.Put(vArea);
//	//	
//	//	vEventsRow = Неопределено;
//	//	vEndOfPrevDay = False;
//	//	vLastDate = Неопределено;
//	//	vCommentIsPlaced = False;
//	//	For Each vPeriodItem In vPeriods Do
//	//		vPeriod = vPeriodItem.Value;
//	//		vCurDate = BegOfDay(vPeriod);
//	//		If vLastDate = Неопределено Or vCurDate <> vLastDate Тогда
//	//			vLastDate = vCurDate;
//	//			vEndOfPrevDay = True;
//	//		EndIf;
//	//					
//	//		// Try to find event starting from this date
//	//		vThisIsFirstPeriodOfEvent = False;
//	//		vProbeEventsRow = vEvents.Find(vCurDate, "DateFrom");
//	//		If vProbeEventsRow <> Неопределено Тогда
//	//			If vEventsRow = Неопределено Тогда
//	//				vEventsRow = vProbeEventsRow;
//	//				vThisIsFirstPeriodOfEvent = True;
//	//				vCommentIsPlaced = False;
//	//			Else
//	//				If vEventsRow <> vProbeEventsRow Тогда
//	//					vEventsRow = vProbeEventsRow;
//	//					vThisIsFirstPeriodOfEvent = True;
//	//					vCommentIsPlaced = False;
//	//				EndIf;
//	//			EndIf;
//	//		EndIf;
//	//		
//	//		vAreaRowName = "NoEventRow";
//	//		If vEventsRow <> Неопределено Тогда
//	//			If vCurDate > vEventsRow.DateTo Or vCurDate < vEventsRow.DateFrom Тогда
//	//				vEventsRow = Неопределено;
//	//			Else
//	//				vAreaRowName = "EventRow";
//	//			EndIf;
//	//		EndIf;
//	//		
//	//		If vEndOfPrevDay Тогда
//	//			vEndOfPrevDay = False;
//	//			If vCurDate = BegOfMonth(vCurDate) Or vCurDate = vDateFrom Тогда
//	//				vArea = vTemplate.GetArea(vAreaRowName + "|FirstDayOfMonth");
//	//			ElsIf WeekDay(vCurDate) = 1 Тогда
//	//				vArea = vTemplate.GetArea(vAreaRowName + "|FirstDayOfWeek");
//	//			Else
//	//				vArea = vTemplate.GetArea(vAreaRowName + "|FirstHourOfDay");
//	//			EndIf;
//	//		Else
//	//			vArea = vTemplate.GetArea(vAreaRowName + "|Day");
//	//		EndIf;
//	//		If vEventsRow <> Неопределено And vAreaRowName = "EventRow" Тогда
//	//			If vThisIsFirstPeriodOfEvent Тогда
//	//				vArea.Parameters.mEventDescription = СокрЛП(vEventsRow.Description);
//	//			Else
//	//				vArea.Parameters.mEventDescription = "";
//	//			EndIf;
//	//			vArea.Parameters.mEvent = vEventsRow.Ref;
//	//		ElsIf vAreaRowName = "NoEventRow" Тогда
//	//			vArea.Parameters.mEvent = Справочники.Мероприятия.EmptyRef();
//	//		EndIf;
//	//		vOutputArea = vSpreadsheet.Join(vArea);
//	//		If vEventsRow <> Неопределено And vAreaRowName = "EventRow" Тогда
//	//			vEventColor = Неопределено;
//	//			If vEventsRow.Color <> Неопределено Тогда
//	//				vEventColor = vEventsRow.Color.Get();
//	//			EndIf;
//	//			If vEventColor <> Неопределено Тогда
//	//				vOutputArea.BackColor = vEventColor;
//	//			EndIf;
//	//			vOutputArea.RightBorder = New Line(SpreadsheetDocumentCellLineType.None, 1);
//	//			If НЕ vThisIsFirstPeriodOfEvent Тогда
//	//				vOutputArea.LeftBorder = New Line(SpreadsheetDocumentCellLineType.None, 1);
//	//				vOutputArea.Clear(True);
//	//			EndIf;
//	//			If vEventsRow.DateTo = BegOfDay(vCurDate) And НЕ vCommentIsPlaced Тогда
//	//				vCommentIsPlaced = True;
//	//				vOutputArea.Comment.Text = Chars.LF + Chars.LF + СокрЛП(Format(vEventsRow.DateFrom, "DF=dd.MM.yyyy") + " - " + Format(vEventsRow.DateTo, "DF=dd.MM.yyyy") + Chars.LF +
//	//										   СокрЛП(vEventsRow.Remarks));
//	//			EndIf;
//	//		EndIf;
//	//	EndDo;
//	//EndIf;
//	
//	// Count maximum value for progress bar
//	vNHotels = vQryRes.Choose(QueryResultIteration.ByGroups, "Гостиница").Count();
//	vNRoomTypes = vQryRes.Choose(QueryResultIteration.ByGroups, "ТипНомера").Count();
//	vNHours = 1;
//	vQryRoomTypes = vQryHotels.Choose(QueryResultIteration.ByGroups, "ТипНомера");
//	If vQryRoomTypes <> Неопределено Тогда
//		vNHours = vQryRoomTypes.Choose(QueryResultIteration.ByGroups, "Period", "ALL").Count();
//	EndIf;
//	
//	// Build report form
//	vQryHotels = vQryRes.Choose(QueryResultIteration.ByGroups, "Гостиница");
//	While vQryHotels.Next() Do
//		If vNHotels > 1 Тогда
//			vHotelRow = RoomTypesTree.GetItems().Add();
//			vHotelRow.Гостиница = vQryHotels.Гостиница;
//			Items.RoomTypesTreeHotel.Visible = True;
//		EndIf;
//		// Show hotel
//		vArea = vTemplate.GetArea("HotelRow|NamesColumn");
//		vArea.Parameters.mHotel = vQryHotels.Гостиница;
//		vSpreadsheet.Put(vArea);
//		
//		// Show hotel totals by days and hours
//		vEndOfPrevDay = False;
//		vLastDate = Неопределено;
//		vLastVacant = 0;
//		vCommentHour = 0;
//		vQryHours = vQryHotels.Choose(QueryResultIteration.ByGroups, "Period", "ALL");
//		While vQryHours.Next() Do
//			vPeriod = BegOfDay(vQryHours.Period);
//			If (vPeriod < BegOfDay(vDateTimeFrom)) Or (vPeriod > EndOfDay(vDateTimeTo)) Тогда
//				Continue;
//			EndIf;
//			If vPeriods.FindByValue(vPeriod) = Неопределено Тогда
//				Continue;
//			EndIf;
//			
//			vCurDate = BegOfDay(vPeriod);
//			If vLastDate = Неопределено Or vCurDate <> vLastDate Тогда
//				vLastDate = vCurDate;
//				vEndOfPrevDay = True;
//			EndIf;
//			
//			// Get necessary report template area
//			If vEndOfPrevDay Тогда
//				vEndOfPrevDay = False;
//				If vCurDate = BegOfMonth(vCurDate) Or vCurDate = vDateFrom Тогда
//					vArea = vTemplate.GetArea("HotelRow|FirstDayOfMonth");
//				ElsIf WeekDay(vCurDate) = 1 Тогда
//					vArea = vTemplate.GetArea("HotelRow|FirstDayOfWeek");
//				Else
//					vArea = vTemplate.GetArea("HotelRow|FirstHourOfDay");
//				EndIf;
//			Else
//				vArea = vTemplate.GetArea("HotelRow|Day");
//			EndIf;
//			
//			// Fill parameters and join area
//			vArea.Parameters.mVacant = GetQueryResource(vQryHours, vShowReportsInBeds, vLastVacant);
//			vArea.Parameters.mDetails = New Structure("Гостиница, ТипНомера, ПериодПо", 
//													   vQryHotels.Гостиница, 
//													   Справочники.ТипыНомеров.EmptyRef(), 
//													   vPeriod);
//			
//			If vArea.Parameters.mVacant < 0 Тогда
//				vCell = vArea.Area(1,1,1,1);
//				vCell.TextColor = WebColors.Red;
//			EndIf;
//			vSpreadsheet.Join(vArea);
//			
//			vLastVacant = vArea.Parameters.mVacant;
//		EndDo;
//		
//		// Show ГруппаНомеров types for this hotel
//		vBaseRTTotal = 0;
//		vQryRoomTypes = vQryHotels.Choose(QueryResultIteration.ByGroups, "ТипНомера");
//		While vQryRoomTypes.Next() Do
//			// Show ГруппаНомеров type
//			vAreaCol = "RoomTypeRow";
//			If vQryRoomTypes.ТипНомера.IsFolder Тогда
//				vAreaCol = "RoomTypeFolderRow";
//			EndIf;
//			vArea = vTemplate.GetArea(vAreaCol + "|NamesColumn");
//			If vAreaCol = "RoomTypeRow" Тогда
//				If ShowPrices Тогда
//					vTablePrices = GetPriceByPeriod(vDateTimeFrom,vDateTimeTo+24*60*60,vQryRoomTypes.ТипНомера);
//				EndIf;
//					
//					//vArea.CurrentArea.Comment.Text = vQryRoomTypes.ТипНомера.DescriptionTranslations;
//			
//				If НЕ IsBlankString(vQryRoomTypes.ТипНомера.Примечания) Тогда
//					vArea.CurrentArea.Comment.Text = vArea.CurrentArea.Comment.Text + Chars.LF + vQryRoomTypes.ТипНомера.Примечания;
//				EndIf;
//			EndIf;
//			If vQryRoomTypes.ТипНомера.IsFolder Тогда
//				vArea.Parameters.mRoomType = cmGetIndent(vQryRoomTypes.ТипНомера, +1) + TrimR(vQryRoomTypes.ТипНомера.Description);
//			Else
//				vArea.Parameters.mRoomType = cmGetIndent(vQryRoomTypes.ТипНомера, +1) + TrimR(vQryRoomTypes.ТипНомера.Description);
//				If vAreaCol = "RoomTypeRow" Тогда
//					If pTotalPriceTable <> Неопределено Тогда
//						vRT = pTotalPriceTable.Find(vQryRoomTypes.ТипНомера, "ТипНомера");
//						vTotal = 0;
//						If vRT <> Неопределено Тогда
//							vTotal = vRT.Total;
//							vArea.Parameters.mTotal = cmFormatSum(vTotal, vRT.Валюта, "NZ =0,00");
//						Else
//							If vQryRoomTypes.ТипНомера = SelRoomType Тогда
//								vArea.Parameters.mTotal = cmFormatSum(0, vQryRoomTypes.Гостиница.BaseCurrency, "NZ =0,00");
//							EndIf;
//						EndIf;						
//					EndIf;
//					vArea.Parameters.mDetails = New Structure("Гостиница, ТипНомера, ПериодПо", 
//														   vQryRoomTypes.Гостиница, 
//														   ?(vQryRoomTypes.ТипНомера.IsFolder, Справочники.ТипыНомеров.EmptyRef(), vQryRoomTypes.ТипНомера), 
//														   "");
//														   
//				EndIf;
//				If vNHotels > 1 Тогда
//					vRoomTypeRow = vHotelRow.GetItems().Add();
//				Else
//					vRoomTypeRow = RoomTypesTree.GetItems().Add();
//				EndIf;
//				vRoomTypeRow.ТипНомера = vQryRoomTypes.ТипНомера;	
//			EndIf;
//			vSpreadsheet.Put(vArea);
//			
//			// Show ГруппаНомеров type totals by days
//			vLastVacant = 0;
//			vCommentHour = 0;
//			vEndOfPrevDay = False;
//			vLastDate = Неопределено;
//			vQryHours = vQryRoomTypes.Choose(QueryResultIteration.ByGroups, "Period", "ALL");
//			While vQryHours.Next() Do
//				vPeriod = BegOfDay(vQryHours.Period);
//				If (vPeriod < BegOfDay(vDateTimeFrom)) Or (vPeriod > EndOfDay(vDateTimeTo)) Тогда
//					Continue;
//				EndIf;
//				If vPeriods.FindByValue(vPeriod) = Неопределено Тогда
//					Continue;
//				EndIf;
//				
//				vCurDate = BegOfDay(vPeriod);
//				If vLastDate = Неопределено Or vCurDate <> vLastDate Тогда
//					vLastDate = vCurDate;
//					vEndOfPrevDay = True;
//				EndIf;
//				
//				// Check ГруппаНомеров type stop sale
//				vStopSaleRemarks = "";
//				vAreaCol = "RoomTypeRow";
//				If vQryRoomTypes.ТипНомера.IsFolder Тогда
//					vAreaCol = "RoomTypeFolderRow";
//				Else
//					If vQryRoomTypes.ТипНомера.СнятСПродажи Тогда
//						If cmIsStopSalePeriod(vQryRoomTypes.ТипНомера, vPeriod, vPeriod, vStopSaleRemarks, True) Тогда
//							vAreaCol = "RoomTypeStopSaleRow";
//						EndIf;
//					EndIf;
//				EndIf;
//				
//				// Get necessary report template area
//				If vEndOfPrevDay Тогда
//					vEndOfPrevDay = False;
//					If vCurDate = BegOfMonth(vCurDate) Or vCurDate = vDateFrom Тогда
//						vArea = vTemplate.GetArea(vAreaCol + "|FirstDayOfMonth");
//					ElsIf WeekDay(vCurDate) = 1 Тогда
//						vArea = vTemplate.GetArea(vAreaCol + "|FirstDayOfWeek");
//					Else
//						vArea = vTemplate.GetArea(vAreaCol + "|FirstHourOfDay");
//					EndIf;
//					// Reset comment on first period of a day
//					vCommentHour = 0;
//				Else
//					vArea = vTemplate.GetArea(vAreaCol + "|Day");
//				EndIf;
//				
//				// Set area parameters
//				vVacant = GetQueryResource(vQryHours, vShowReportsInBeds, vLastVacant);
//				vArea.Parameters.mVacant = vVacant;
//				
//				If НЕ vAreaCol="RoomTypeFolderRow" And ShowPrices Тогда
//					Try
//						vFilter = vTablePrices.FindRows(New Structure("Period",vCurDate));
//						If vFilter.Count()>0 Тогда
//							vArea.Parameters.mPrice	= cmFormatSum(vFilter[0].Сумма,Гостиница.Валюта);
//						Else	
//							vArea.Parameters.mPrice = cmFormatSum(0,Гостиница.Валюта);
//						EndIf;
//					Except
//					EndTry;
//				EndIf;		
//				
//				vArea.Parameters.mDetails = New Structure("Гостиница, ТипНомера, ПериодПо", 
//														   vQryHotels.Гостиница, 
//														   ?(vQryRoomTypes.ТипНомера.IsFolder, Справочники.ТипыНомеров.EmptyRef(), vQryRoomTypes.ТипНомера), 
//														   vPeriod);
//
//				// Set red color to the overbooking										   
//				If vArea.Parameters.mVacant < 0 Тогда
//					vCell = vArea.Area(1,1,1,1);
//					vCell.TextColor = WebColors.Red;
//				EndIf;
//				
//				// Add stop sale comment
//				If НЕ IsBlankString(vStopSaleRemarks) Тогда
//					vArea.Area("T").Comment.Text = СокрЛП(vArea.Area("T").Comment.Text) + ?(IsBlankString(vArea.Area("T").Comment.Text), "", Chars.LF + Chars.LF) + vStopSaleRemarks;
//				EndIf;
//				
//				// Join template area to the report
//				vSpreadsheet.Join(vArea);
//				
//				vLastVacant = vVacant;
//			EndDo;
//		EndDo;
//	EndDo;
//	
//	// Setup default attributes
//	cmSetDefaultPrintFormSettings(vSpreadsheet, PageOrientation.Landscape);
//	vSpreadsheet.FixedTop = 3;
//	vSpreadsheet.FixedLeft = 2;
//	
//	// Set report protection
//	cmSetSpreadsheetProtection(vSpreadsheet);
//	
//	// Set report header
//	cmApplyReportHeader(vSpreadsheet);
//	// Add configuration name to the right report header
//	vSpreadsheet.Header.LeftText = ?(ЗначениеЗаполнено(ПараметрыСеанса.ТекущаяГостиница), 
//									 ПараметрыСеанса.ТекущаяГостиница.GetObject().pmGetHotelPrintName(ПараметрыСеанса.ТекЛокализация), "") + " - " + 
//									СокрЛП(ПараметрыСеанса.ПредставлениеКонфигурации);
//	vSpreadsheet.Header.RightText = СокрЛП(ПараметрыСеанса.ТекПользователь) + " - " + Format(CurrentDate(), "DF='dd.MM.yyyy HH:mm'");
//	// Set footer
//	cmApplyReportFooter(vSpreadsheet);
//КонецПроцедуры //BuildReport
//
////-----------------------------------------------------------------------------
//&AtServer
//Процедура OnCreateAtServer(pCancel, pStandardProcessing)
//	SkipOnActivateAreaFromCalculate = 0;
//	SkipOnActivateCell = False;
//	LastRowIndex = 0;
//	
//	// Attach mouse right button context menu
//	AttachSelectionContextMenu();
//	
//	// Use current hotel by default
//	Гостиница = ПараметрыСеанса.ТекущаяГостиница;
//	If ЗначениеЗаполнено(Гостиница) Тогда
//		ShowInBeds = Гостиница.ShowReportsInBeds;
//		Тариф = Гостиница.Тариф;
//	EndIf;
//	
//	// Use current date by default
//	DateFrom = CurrentDate();
//	
//	// Restore number of days to show
//	vShowPrices = SystemSettingsStorage.Load("ShowPrices", "упрНаличиеНомеров");
//	If vShowPrices = Неопределено Тогда
//		vShowPrices = False;
//	EndIf;
//	ShowPrices = vShowPrices;
//	If ShowPrices Тогда
//		vNumberOfDays = SystemSettingsStorage.Load("NumberOfDaysShowPrices", "упрНаличиеНомеров");
//	Else
//		vNumberOfDays = SystemSettingsStorage.Load("NumberOfDays", "упрНаличиеНомеров");
//	EndIf;
//	If vNumberOfDays = Неопределено Тогда
//		If ShowPrices Тогда
//			NumberOfDays = 10;
//		Else
//			NumberOfDays = 28;
//		EndIf;
//	Else
//		NumberOfDays = Number(vNumberOfDays);
//	EndIf;
//	If NumberOfAdults = 0 Тогда
//		NumberOfAdults = 1;
//	EndIf;
//	
//	// Fill parameters from current user settings
//	vCurEmployee = ПараметрыСеанса.ТекПользователь;
//	If ЗначениеЗаполнено(vCurEmployee) Тогда
//		If ЗначениеЗаполнено(vCurEmployee.Контрагент) Тогда
//			If ЗначениеЗаполнено(vCurEmployee.Контрагент.Тариф) Тогда
//				Тариф = vCurEmployee.Контрагент.Тариф;
//			Else
//				If ЗначениеЗаполнено(vCurEmployee.Контрагент.Договор) Тогда
//					If ЗначениеЗаполнено(vCurEmployee.Контрагент.Договор.Тариф) Тогда
//						Тариф = vCurEmployee.Контрагент.Договор.Тариф;
//					EndIf;
//				EndIf;
//			EndIf;
//			If ЗначениеЗаполнено(vCurEmployee.Контрагент.ТипКлиента) Тогда
//				ClientType = vCurEmployee.Контрагент.ТипКлиента;
//			Else
//				If ЗначениеЗаполнено(vCurEmployee.Контрагент.Договор) Тогда
//					If ЗначениеЗаполнено(vCurEmployee.Контрагент.Договор.ТипКлиента) Тогда
//						ClientType = vCurEmployee.Контрагент.Договор.ТипКлиента;
//					EndIf;
//				EndIf;
//			EndIf;
//			Items.КвотаНомеров.ReadOnly = True;
//			Items.КвотаНомеров.ClearButton = False;
//			Items.КвотаНомеров.ChoiceButton = False;
//			Items.КвотаНомеров.OpenButton = False;
//		EndIf;
//		If ЗначениеЗаполнено(vCurEmployee.КвотаНомеров) Тогда
//			RoomQuota = ПараметрыСеанса.ТекПользователь.КвотаНомеров;
//			Items.КвотаНомеров.ReadOnly = True;
//			Items.КвотаНомеров.ClearButton = False;
//			Items.КвотаНомеров.ChoiceButton = False;
//			Items.КвотаНомеров.OpenButton = False;
//			If ЗначениеЗаполнено(RoomQuota.Тариф) Тогда
//				Тариф = RoomQuota.Тариф;
//				Items.Тариф.ReadOnly = True;
//				Items.Тариф.ClearButton = False;
//				Items.Тариф.ChoiceButton = False;
//				Items.Тариф.OpenButton = False;
//			EndIf;
//		EndIf;
//	EndIf;
//	SelectionTopRow = 0;
//	
//	// Build report spreadsheet
//	BuildReport();
//КонецПроцедуры //OnCreateAtServer
//
////-----------------------------------------------------------------------------
//&AtServer
//Процедура NumberOfDaysOnChangeAtServer()
//	If ShowPrices Тогда
//		SystemSettingsStorage.Save("NumberOfDaysShowPrices", "упрНаличиеНомеров", NumberOfDays);
//	Else
//		SystemSettingsStorage.Save("NumberOfDays", "упрНаличиеНомеров", NumberOfDays);
//	EndIf;
//	BuildReport();
//КонецПроцедуры
//
////-----------------------------------------------------------------------------
//&НаКлиенте
//Процедура PrevPeriodButton(pCommand)
//	DateFrom = BegOfDay(DateFrom - (NumberOfDays - 1) * 24*3600);
//	// Change monthes page
//	PeriodFromChangeMode = True;
//	vIndex = Month(DateFrom) - Month(CurrentDate());
//	If vIndex < 0 Тогда
//		vIndex = vIndex + 12;
//	EndIf;
//	vIndex = vIndex + 1;
//	Items.GroupMonths.CurrentPage = Items.GroupMonths.ChildItems.Get(vIndex);
//	vDecorationName = "Decoration" + String(vIndex);
//	Items[vDecorationName].Title = NStr("en='Period on screen: '; ru='Период на экране: '; de='Zeitraum auf dem Bildschirm: '") + Format(DateFrom, "DF=dd.MM.yyyy") + " - " + Format(DateFrom + (NumberOfDays - 1)*24*3600, "DF=dd.MM.yyyy");
//	PeriodFromChangeMode = False;
//	// Build report	
//	BuildReport();
//КонецПроцедуры
//
////-----------------------------------------------------------------------------
//&НаКлиенте
//Процедура NextPeriodButton(pCommand)
//	DateFrom = BegOfDay(DateFrom + (NumberOfDays - 1) * 24*3600);
//	// Change monthes page
//	PeriodFromChangeMode = True;
//	vIndex = Month(DateFrom) - Month(CurrentDate());
//	If vIndex < 0 Тогда
//		vIndex = vIndex + 12;
//	EndIf;
//	vIndex = vIndex + 1;
//	Items.GroupMonths.CurrentPage = Items.GroupMonths.ChildItems.Get(vIndex);
//	vDecorationName = "Decoration" + String(vIndex);
//	Items[vDecorationName].Title = NStr("en='Period on screen: '; ru='Период на экране: '; de='Zeitraum auf dem Bildschirm: '") + Format(DateFrom, "DF=dd.MM.yyyy") + " - " + Format(DateFrom + (NumberOfDays - 1)*24*3600, "DF=dd.MM.yyyy");
//	PeriodFromChangeMode = False;
//	// Build report	
//	BuildReport();
//КонецПроцедуры
//
////-----------------------------------------------------------------------------
//&НаКлиенте
//Процедура ReportOnActivateArea(pItem)
//	If SkipOnActivateAreaFromCalculate > 0 Тогда
//		SkipOnActivateAreaFromCalculate = SkipOnActivateAreaFromCalculate - 1;
//		Return;
//	EndIf;
//	Try     
//		vSelAreas = Report.SelectedAreas;
//		If vSelAreas.Count() > 1 Тогда
//			vSelAreasArray = New Array;
//			For Each vSelArea In vSelAreas Do
//				vSelAreasArray.Add(vSelArea);
//				Break;
//			EndDo;
//			SkipOnActivateAreaFromCalculate = 0;
//			Items.Report.SetSelectedAreas(vSelAreasArray);
//			Return;
//		EndIf;
//		If vSelAreas.Count() > 0 Тогда
//			vSelAreasArray = New Array;
//			For Each vSelArea In vSelAreas Do
//				// Currently only one row could be selected
//				If vSelArea.Left > 2 Тогда
//					If (vSelArea.Bottom - vSelArea.Top) > 0 Тогда
//						If SelectionTopRow <> 0 Тогда
//							vNewSelArea = Report.Area(SelectionTopRow, vSelArea.Left, SelectionTopRow, vSelArea.Right);
//						Else
//							vNewSelArea = Report.Area(vSelArea.Top, vSelArea.Left, vSelArea.Top, vSelArea.Right);
//						EndIf;
//						vSelAreasArray.Add(vNewSelArea);
//						vSelArea = vNewSelArea;
//					Else
//						SelectionTopRow = vSelArea.Top;
//					EndIf;
//				EndIf;
//				Break; // No multiple selection
//			EndDo;    
//			If vSelAreasArray.Count() > 0 Тогда
//				SkipOnActivateAreaFromCalculate = 0;
//				Items.Report.SetSelectedAreas(vSelAreasArray);
//				Return;
//			EndIf;
//			If vSelAreas.Count() > 0 Тогда
//				Try
//					vSelArea = vSelAreas.Get(0);
//					vDetailsLeftTop = Report.Area(vSelArea.Top, vSelArea.Left).Details;
//					vDetailsRightBottom = Report.Area(vSelArea.Bottom, vSelArea.Right).Details;
//					If vDetailsLeftTop <> Неопределено And 
//						vDetailsRightBottom <> Неопределено Тогда
//						If TypeOf(vDetailsLeftTop) = Type("Structure") And TypeOf(vDetailsRightBottom) = Type("Structure") Тогда
//							#If WebClient Тогда
//								SkipOnActivateAreaFromCalculate = 2;
//							#Else
//								SkipOnActivateAreaFromCalculate = 0;
//							#EndIf
//							If ЗначениеЗаполнено(vDetailsLeftTop.ПериодПо) AND ЗначениеЗаполнено(vDetailsRightBottom.ПериодПо) Тогда
//								vPeriodFrom = vDetailsLeftTop.ПериодПо;
//								vPeriodTo = vDetailsRightBottom.ПериодПо;
//							EndIf;
//							vRoomTypeFrom = vDetailsLeftTop.ТипНомера;
//							If ЗначениеЗаполнено(vRoomTypeFrom) Тогда
//								If SelRoomType <> vRoomTypeFrom Тогда
//									vClearPreviousPrices = True;
//								EndIf;
//								SelRoomType = vRoomTypeFrom;
//							EndIf;									
//							If ЗначениеЗаполнено(vPeriodFrom) And ЗначениеЗаполнено(vPeriodTo) Тогда
//								// Set period selected
//								vPeriodTo = ?(vPeriodFrom = vPeriodTo, vPeriodTo + 24*60*60, vPeriodTo);
//								If CheckInDate <> BegOfDay(vPeriodFrom) Or CheckOutDate <> BegOfDay(vPeriodTo) Тогда
//									vClearPreviousPrices = True;
//								EndIf;
//								CheckInDate = BegOfDay(vPeriodFrom);
//								CheckOutDate = BegOfDay(vPeriodTo);
//								Duration = CalculateDurationAtServer(Тариф, CheckInDate, CheckOutDate);
//								If НЕ ЗначениеЗаполнено(NumberOfAdults) Тогда
//									NumberOfAdults = 1;
//								EndIf;
//								If vClearPreviousPrices Тогда
//									// Clear prices calculated for the previous selection
//									If AccommodationTypesTable.Count() > 0 Тогда
//										For Each vATTRow In AccommodationTypesTable Do
//											If НЕ IsBlankString(vATTRow.Цена) Тогда
//												vATTRow.Цена = "";
//											Else
//												If AccommodationTypesTable.IndexOf(vATTRow) = 0 Тогда
//													Break;
//												EndIf;
//											EndIf;
//										EndDo;
//										// Clear totals
//										Items.AccommodationTypesTablePrice.FooterText = "";
//									EndIf;
//								EndIf;
//							EndIf;
//						EndIf;
//					EndIf;
//				Except
//				EndTry;
//			EndIf;
//		EndIf;
//	Except
//		Message(ErrorDescription());
//	EndTry;
//КонецПроцедуры //ReportOnActivateArea
//
////-----------------------------------------------------------------------------
//&AtServer
//Процедура AttachSelectionContextMenu()
//	vContextMenu = Items.ReportContextMenu;
//	vActionNext = ЭтаФорма.Items.Add("ActionNext", Type("FormButton"), Items.Report.ContextMenu);
//	vActionNext.CommandName = "NextPeriodButton";
//	ActionPrev = ЭтаФорма.Items.Add("ActionPrev", Type("FormButton"), Items.Report.ContextMenu);
//	ActionPrev.CommandName = "PrevPeriodButton";
//КонецПроцедуры //AttachSelectionContextMenu
//
////-----------------------------------------------------------------------------
//&AtServer
//Function CheckFields()
//	vIsError = False;
//	If НЕ ЗначениеЗаполнено(SelRoomType) Тогда
//		vMessage = New UserMessage;
//		vMessage.Text = NStr("en='Fill the field (ГруппаНомеров type)';ru='Заполните поле (Тип номера)';de='Feld ausfüllen (Zimmertyp)'");
//		vMessage.TargetID = ЭтаФорма.UUID;
//		vMessage.Field = "SelRoomType";
//		vMessage.DataKey = DataKey.Ref;
//		vMessage.Message();
//		vIsError = True;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(CheckInDate) Тогда
//		vMessage = New UserMessage;
//		vMessage.Field = "CheckInDate";
//		vMessage.TargetID = ЭтаФорма.UUID;
//		vMessage.Text = NStr("en='Fill the field (Check-in date)';ru='Заполните поле (Дата заезда)';de='Feld ausfüllen (Anreisedatum)'");
//		vMessage.DataKey = DataKey.Ref;
//		vMessage.Message();
//		vIsError = True;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(CheckOutDate) Тогда
//		vMessage = New UserMessage;
//		vMessage.Field = "ДатаВыезда";
//		vMessage.TargetID = ЭтаФорма.UUID;
//		vMessage.Text = NStr("en='Fill the field (Check-out date)';ru='Заполните поле (Дата выезда)';de='Feld ausfüllen (Abreisedatum)'");
//		vMessage.DataKey = DataKey.Ref;
//		vMessage.Message();
//		vIsError = True;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(NumberOfAdults) Тогда
//		NumberOfAdults = 1;
//	EndIf;
//	If ЗначениеЗаполнено(NumberOfKids) Тогда
//		Try
//			For vInd = 1 To NumberOfKids Do
//				If НЕ ЗначениеЗаполнено(ЭтаФорма["KidAge"+String(vInd)]) Тогда
//					vMessage = New UserMessage;
//					vMessage.Field = "KidAge"+String(vInd);
//					vMessage.TargetID = ЭтаФорма.UUID;
//					vMessage.Text = NStr("en='Enter age of kid';ru='Введите возраст ребенка';de='Geben Sie das Alter des Kindes ein'");
//					vMessage.DataKey = DataKey.Ref;
//					vMessage.Message();
//					vIsError = True;
//				EndIf;
//			EndDo;
//		Except
//		EndTry;
//	EndIf;
//	If vIsError Тогда
//		Return False;
//	Else
//		Return True;
//	EndIf;
//EndFunction //CheckFields
//
////-----------------------------------------------------------------------------
//&НаКлиенте
//Процедура Calculate(pCommand)
//	#If НЕ  WebClient Тогда
//		Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 20, NStr("en='Calculating...';ru='Расчёт...';de='Errechnung...'"), PictureLib.LongOperation); 	
//	#EndIf
//	
//	#If WebClient Тогда
//		SkipOnActivateAreaFromCalculate = 2;
//	#EndIf
//	
//	If CheckFields() Тогда
//		#If НЕ  WebClient Тогда
//			Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 40, NStr("en='Calculating...';ru='Расчёт...';de='Errechnung...'"), PictureLib.LongOperation); 
//		#EndIf
//		
//		GetPrice();
//		
//		#If НЕ  WebClient Тогда
//			Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 70, NStr("en='Calculating...';ru='Расчёт...';de='Errechnung...'"), PictureLib.LongOperation); 
//		#EndIf
//	EndIf;
//	#If НЕ  WebClient Тогда
//		Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 100, NStr("en='Calculating...';ru='Расчёт...';de='Errechnung...'"), PictureLib.LongOperation); 
//	#EndIf
//КонецПроцедуры
//
////-----------------------------------------------------------------------------
//&НаКлиенте
//Процедура NumberOfKidsOnChange(pItem)
//	If NumberOfKids = 0 Тогда
//		Items.AgeDecoration.Visible = False;
//		If LastKidsNumber > 0 Тогда
//			For vInd = 1 To LastKidsNumber Do
//				Try
//					Items["KidAge"+String(vInd)].Visible = False;
//					ЭтаФорма["KidAge"+String(vInd)] = 0;
//				Except
//				EndTry;
//			EndDo;
//		EndIf;
//	Else
//		If NumberOfKids > NumberOfKidAgeFields Тогда
//			NumberOfKids = NumberOfKidAgeFields;
//			Message(NStr("en='Maximum number of children allowed is " + NumberOfKidAgeFields + "!'; de='Maximum number of children allowed is " + NumberOfKidAgeFields + "!'; ru='Максимально возможное число детей равно " + NumberOfKidAgeFields + "!'"));
//		EndIf;
//		Items.AgeDecoration.Visible = True;
//		If NumberOfKids < LastKidsNumber Тогда
//			For vInd = NumberOfKids + 1 To LastKidsNumber Do
//				Try
//					Items["KidAge"+String(vInd)].Visible = False;
//					ЭтаФорма["KidAge"+String(vInd)] = 0;
//				Except
//				EndTry;
//			EndDo;
//		ElsIf NumberOfKids > LastKidsNumber Тогда
//			vNumberOfFieldsToAdd = 0;
//			If NumberOfKids > NumberOfKidAgeFields Тогда
//				Try
//					For vInd = LastKidsNumber + 1 To NumberOfKidAgeFields Do
//						Items["KidAge"+String(vInd)].Visible = True;
//						ЭтаФорма["KidAge"+String(vInd)] = 0;
//					EndDo;
//				Except
//				EndTry;
//				vNumberOfFieldsToAdd = NumberOfKids - NumberOfKidAgeFields;
//				If LastKidsNumber > NumberOfKidAgeFields Тогда
//					vNumberOfFieldsToAdd = vNumberOfFieldsToAdd - (LastKidsNumber - NumberOfKidAgeFields);
//				EndIf;
//				AddKidAgeAttributes(vNumberOfFieldsToAdd);
//			Else
//				Try
//					For vInd = LastKidsNumber + 1 To NumberOfKids Do
//						Items["KidAge"+String(vInd)].Visible = True;
//						ЭтаФорма["KidAge"+String(vInd)] = 0;
//					EndDo;
//				Except
//				EndTry;
//			EndIf;
//		EndIf;
//	EndIf;
//	LastKidsNumber = NumberOfKids;
//КонецПроцедуры
//
////-----------------------------------------------------------------------------
//&AtServer
//Процедура AddKidAgeAttributes(pNumberOfFields)
//	vTempArray = New Array;
//	For vInd = 1 To pNumberOfFields Do
//		vTempArray.Add(New FormAttribute("KidAge"+String(NumberOfKidAgeFields+vInd), New TypeDescription("Number")));
//	EndDo;
//	ChangeAttributes(vTempArray);	
//	For vInd = 1 To pNumberOfFields Do
//		vNewField = Items.Add("KidAge"+String(NumberOfKidAgeFields+vInd), Type("FormField"), Items.KidsGroup);
//		vNewField.ТипРазмещения = FormFieldType.InputField;
//		vNewField.HorizontalAlign = ItemHorizontalLocation.Center;
//		vNewField.Width = 2;
//		vNewField.TitleLocation = FormItemTitleLocation.None;
//		vNewField.DataPath = "KidAge"+String(NumberOfKidAgeFields+vInd);
//	EndDo;
//	NumberOfKidAgeFields = NumberOfKidAgeFields + pNumberOfFields;
//КонецПроцедуры //AddKidAgeAttributes
//
////-----------------------------------------------------------------------------
//&AtServer
//Function GetMonthNameAtServer(pMonth)
//	Return cmGetMonthName(pMonth);
//EndFunction //GetMonthNameAtServer
//
////-----------------------------------------------------------------------------
//&НаКлиенте
//Процедура OnOpen(pCancel)
//	LastKidsNumber = 0;
//	NumberOfKidAgeFields = 4;
//	Items["Decoration0"].Title = NStr("en='Period on screen: '; ru='Период на экране: '; de='Zeitraum auf dem Bildschirm: '") + Format(DateFrom, "DF=dd.MM.yyyy") + " - " + Format(DateFrom + (NumberOfDays - 1)*24*3600, "DF=dd.MM.yyyy");
//	// Add monthes pages
//	vBegOfCurMonth = BegOfMonth(CurrentDate());
//	For i = 1 To 12 Do
//		vCurPage = Items.GroupMonths.ChildItems[i];
//		vPageDate = AddMonth(vBegOfCurMonth, i - 1);
//		If Year(vPageDate) > Year(CurrentDate()) And Month(vPageDate) = 1 Тогда
//			vCurPage.Title = GetMonthNameAtServer(Month(vPageDate)) + " " + Format(vPageDate, "DF=yyyy");
//		Else
//			vCurPage.Title = GetMonthNameAtServer(Month(vPageDate));
//		EndIf;
//		vDecorationName = "Decoration" + String(i);
//		Items[vDecorationName].Title = NStr("en='Period on screen: '; ru='Период на экране: '; de='Zeitraum auf dem Bildschirm: '") + Format(vPageDate, "DF=dd.MM.yyyy") + " - " + Format(vPageDate + (NumberOfDays - 1)*24*3600, "DF=dd.MM.yyyy");
//	EndDo;
//	// Change monthes page
//	PeriodFromChangeMode = True;
//	If BegOfDay(DateFrom) = BegOfDay(CurrentDate()) Тогда
//		Items.GroupMonths.CurrentPage = Items.GroupMonths.ChildItems.Get(0);
//	Else
//		vIndex = Month(DateFrom) - Month(CurrentDate());
//		If vIndex < 0 Тогда
//			vIndex = vIndex + 12;
//		EndIf;
//		vIndex = vIndex + 1;
//		Items.GroupMonths.CurrentPage = Items.GroupMonths.ChildItems.Get(vIndex);
//	EndIf;
//	PeriodFromChangeMode = False;
//	// Build report in web client mode
//	#If WebClient Тогда
//		If ShowPrices Тогда
//			ShowPrices = False;
//			BuildReport();
//		EndIf;
//	#EndIf
//КонецПроцедуры //OnOpen
//
////-----------------------------------------------------------------------------
//&AtServer
//Процедура GetPrice(pAccommodationTypes = Неопределено, pIsReservation = False)
//	// Build array of kid ages
//	vAgeArray = New Array;
//	For vInd = 1 To NumberOfKids Do
//		Try
//			vAge = ЭтаФорма["KidAge"+String(vInd)];
//			vAgeArray.Add(vAge);
//		Except
//		EndTry;
//	EndDo;
//	
//	vGuestsQuantity = NumberOfAdults + NumberOfKids;
//	
//	// Get available ГруппаНомеров types
//	vRoomTypes = cmGetRoomTypesByGuestQuantity(vGuestsQuantity, Справочники.ТипыНомеров.EmptyRef(), Гостиница);
//	
//	// Get default Контрагент
//	vCustomer = Неопределено;
//	vCurUser = ПараметрыСеанса.ТекПользователь;
//	If ЗначениеЗаполнено(vCurUser.Контрагент) Тогда
//		vCustomer = vCurUser.Контрагент;
//	EndIf;
//	
//	// Get ГруппаНомеров type prices
//	vCurRoomTypeAccTypes = Неопределено;
//	
//	// Probe document object to calculate prices
//	vProbeResObj = Documents.Бронирование.CreateDocument();
//	vProbeResObj.Гостиница = Гостиница;
//	vProbeResObj.pmFillAttributesWithDefaultValues(True);
//	
//
//	vRoomTypeBalances = cmGetRoomTypeBalancesTable(vRoomTypes, False, Гостиница, CheckInDate, CheckOutDate, ClientType, vCustomer, , , , , , SelRoomType, Тариф, pAccommodationTypes, NumberOfAdults, NumberOfKids, vAgeArray,vProbeResObj);
//	If vRoomTypeBalances <> Неопределено Тогда
//		vCurRoomTypeAccTypes = vRoomTypeBalances.FindRows(New Structure("ТипНомера", SelRoomType));
//		If vCurRoomTypeAccTypes.Count() = 0 Тогда
//			vCurRoomTypeAccTypes = vRoomTypeBalances.FindRows(New Structure("ТипНомера", Справочники.ТипыНомеров.EmptyRef()));
//		EndIf;
//		GuestTable.Clear();
//		vInd = 0;
//		For Each vRow In AccommodationTypesTable Do
//			If ЗначениеЗаполнено(vRow.GuestName) Тогда
//				vNewGuest = GuestTable.Add();
//				vNewGuest.RowNumber = vInd;
//				vNewGuest.GuestName = vRow.GuestName;
//				vNewGuest.GuestRef = vRow.GuestRef;
//				vNewGuest.ДатаРождения = vRow.ДатаРождения;
//				If vInd = 0 Тогда
//					vNewGuest.Телефон = Phone;
//					vNewGuest.EMail = EMail;
//				EndIf;
//			EndIf;
//			vInd = vInd + 1;
//		EndDo;
//	EndIf;
//	
//	// Build table with accommodation types received
//	AccommodationTypesTable.Clear();
//	
//	vAmount = 0;
//	vCurrency = Справочники.Валюты.EmptyRef();
//	vRU = Справочники.Валюты.FindByCode(643);
//	vIndex = 0;
//	If vCurRoomTypeAccTypes <> Неопределено Тогда
//		For Each vCurRoomTypeAccTypesRow In vCurRoomTypeAccTypes Do
//			vNewStr = AccommodationTypesTable.Add();
//			vNewStr.ВидРазмещения = vCurRoomTypeAccTypesRow.ВидРазмещения;
//			vNewStr.Цена = cmFormatSum(vCurRoomTypeAccTypesRow.Amount, ?(ЗначениеЗаполнено(vCurRoomTypeAccTypesRow.Валюта), vCurRoomTypeAccTypesRow.Валюта, vRU));
//			vNewStr.Icon = ?(ЗначениеЗаполнено(vCurRoomTypeAccTypesRow.ВидРазмещения.AllowedClientAgeTo), PictureLib.Child, PictureLib.Adult);
//			vNewStr.RowIndex = vIndex;
//			vIndex = vIndex + 1;
//			vAmount = vAmount + vCurRoomTypeAccTypesRow.Amount;
//			vCurrency = vCurRoomTypeAccTypesRow.Валюта;
//		EndDo;
//	EndIf;
//	
//	vAccommodationTypesTableRowsCount = AccommodationTypesTable.Count();
//	If vAccommodationTypesTableRowsCount > 0 Тогда
//		For Each vGuestTableRow In GuestTable Do
//			If vGuestTableRow.RowNumber < vAccommodationTypesTableRowsCount Тогда
//				vAccTypesTableRow = AccommodationTypesTable.Get(vGuestTableRow.RowNumber);
//				vAccTypesTableRow.GuestName = vGuestTableRow.GuestName;
//				vAccTypesTableRow.GuestRef = vGuestTableRow.GuestRef;
//				vAccTypesTableRow.ДатаРождения = vGuestTableRow.ДатаРождения;
//				If vGuestTableRow.RowNumber = 0 Тогда
//					Phone = vGuestTableRow.Телефон;
//					EMail = vGuestTableRow.EMail;
//				EndIf;
//			EndIf;
//		EndDo;
//	EndIf;
//	Items.AccommodationTypesTablePrice.FooterText = cmFormatSum(vAmount, ?(ЗначениеЗаполнено(vCurrency), vCurrency, vRU));
//	
//	// Fill footer
//	If НЕ pIsReservation Тогда
//		vTotalPriceTable = New ValueTable;
//		vTotalPriceTable.Columns.Add("ТипНомера", cmGetCatalogTypeDescription("ТипыНомеров"));
//		vTotalPriceTable.Columns.Add("Total", cmGetNumberTypeDescription(10, 0));
//		vTotalPriceTable.Columns.Add("Валюта", cmGetCatalogTypeDescription("Валюты"));
//		vTotal = 0;
//		vLastRT = Неопределено;
//		If vRoomTypeBalances <> Неопределено Тогда
//			For Each vRow In vRoomTypeBalances Do
//				// Add total row
//				If vLastRT <> vRow.ТипНомера Тогда
//					vNewTotal = vTotalPriceTable.Add();
//					If НЕ ЗначениеЗаполнено(vRow.ТипНомера) Тогда
//						vNewTotal.ТипНомера = SelRoomType;
//					Else
//						vNewTotal.ТипНомера = vRow.ТипНомера;
//					EndIf;
//					vNewTotal.Валюта = vRow.Валюта;
//					vLastRT = vRow.ТипНомера;
//					vTotal = 0;
//				EndIf;
//				vTotal = vTotal + vRow.Amount;
//				vNewTotal.Total = vTotal;
//			EndDo;
//		EndIf;
//		SkipOnActivateAreaFromCalculate = 1;
//		BuildReport(vTotalPriceTable);
//	EndIf;
//	
//	// Remove folios created by documents
//	If vProbeResObj <> Неопределено Тогда
//		For Each vCRRow In vProbeResObj.ChargingRules Do
//			vFolioObj = vCRRow.ChargingFolio.GetObject();
//			vFolioObj.Delete();
//		EndDo;
//		vProbeResObj = Неопределено;
//	EndIf;
//КонецПроцедуры //GetPrice
//
////-----------------------------------------------------------------------------
//&AtServer
//Function GetPriceByPeriod(pPeriodFrom = Неопределено, pPeriodTo = Неопределено,pRoomType = Неопределено)
//	pProbeResObj = Неопределено;
//	// Build array of kid ages
//	vAgeArray = New Array;
//	For vInd = 1 To NumberOfKids Do
//		Try
//			vAge = ЭтаФорма["KidAge"+String(vInd)];
//			vAgeArray.Add(vAge);
//		Except
//		EndTry;
//	EndDo;
//	
//	vGuestsQuantity = NumberOfAdults + NumberOfKids;
//	
//	// Get available ГруппаНомеров types
//	pRoomTypes = cmGetRoomTypesByGuestQuantity(vGuestsQuantity, Справочники.ТипыНомеров.EmptyRef(), Гостиница);
//	
//	// Get default Контрагент
//	vCustomer = Неопределено;
//	vCurUser = ПараметрыСеанса.ТекПользователь;
//	If ЗначениеЗаполнено(vCurUser.Контрагент) Тогда
//		vCustomer = vCurUser.Контрагент;
//	EndIf;
//	
//	// Get ГруппаНомеров type prices
//	vCurRoomTypeAccTypes = Неопределено;
//	vLanguage = cmGetLanguageByCode("");
//	
//	vAdultsQuantity = NumberOfAdults; 
//	vKidsQuantity = NumberOfKids; 
//	vGuestsQuantity = vAdultsQuantity + vKidsQuantity;
//	// Retrieve parameter references based on codes
//	vExtHotelCode = "";
//	vExternalSystemCode = "";
//	vClientType = ClientType;
//	If vClientType = Неопределено Тогда
//		vClientType = Справочники.ClientTypes.EmptyRef();
//	EndIf;
//	vRoomRate = Тариф;
//	If vRoomRate = Неопределено Тогда
//		vRoomRate = Справочники.Тарифы.EmptyRef();
//	EndIf;
//	
//	vDiscountType = Справочники.ТипыСкидок.EmptyRef();
//	vCustomer = Справочники.Контрагенты.EmptyRef();
//	vContract = Справочники.Договора.EmptyRef();
//	
//	// Build probe reservation object to calaculate services
//	If pProbeResObj <> Неопределено Тогда
//		vProbeResObj = pProbeResObj;
//		vProbeResObj.OccupationPercents.Clear();
//	Else
//		vProbeResObj = Documents.Бронирование.CreateDocument();
//		vProbeResObj.Гостиница = Гостиница;
//		vProbeResObj.pmFillAttributesWithDefaultValues(True);
//	EndIf;
//	vProbeResObj.ДатаЦены = Неопределено;
//	vProbeResObj.Продолжительность = vProbeResObj.pmCalculateDuration();
//	vProbeResObj.ТипКлиента = vClientType;
//	vProbeResObj.Контрагент = vCustomer;
//	vProbeResObj.Договор = vContract;
//
//	If vRoomRate <> Неопределено Тогда
//		vProbeResObj.Тариф = vRoomRate;
//	EndIf;
//
//	If ЗначениеЗаполнено(vProbeResObj.Договор) And ЗначениеЗаполнено(vProbeResObj.Договор.ВидКомиссииАгента) Тогда
//		// Agent commission
//		vProbeResObj.Агент = vProbeResObj.Договор.Агент;
//		If ЗначениеЗаполнено(vProbeResObj.Контрагент) And ЗначениеЗаполнено(vProbeResObj.Договор.ВидКомиссииАгента) Тогда
//			If НЕ ЗначениеЗаполнено(vProbeResObj.Агент) Тогда
//				vProbeResObj.Агент = vProbeResObj.Контрагент;
//			EndIf;
//			vProbeResObj.КомиссияАгента = vProbeResObj.Договор.КомиссияАгента;
//			vProbeResObj.ВидКомиссииАгента = vProbeResObj.Договор.ВидКомиссииАгента;
//			vProbeResObj.КомиссияАгентУслуги = vProbeResObj.Договор.КомиссияАгентУслуги;
//		EndIf;
//		If НЕ ЗначениеЗаполнено(vProbeResObj.Агент) Тогда
//			vProbeResObj.КомиссияАгента = 0;
//			vProbeResObj.ВидКомиссииАгента = Неопределено;
//			vProbeResObj.КомиссияАгентУслуги = Справочники.НаборыУслуг.EmptyRef();
//		EndIf;
//		// ГруппаНомеров rate
//		vChangeRR = False;
//		If ЗначениеЗаполнено(vProbeResObj.Тариф) Тогда
//			vFindedRR = vProbeResObj.Договор.Тарифы.Find(vProbeResObj.Тариф, "Тариф");
//			If vFindedRR = Неопределено And vProbeResObj.Тариф <> vProbeResObj.Договор.Тариф Тогда
//				vChangeRR = True;
//			EndIf;
//		Else
//			vChangeRR = True;
//		EndIf;
//		If vChangeRR Тогда
//			If ЗначениеЗаполнено(vProbeResObj.Договор.Тариф) Тогда
//				vProbeResObj.Тариф = vProbeResObj.Договор.Тариф;
//				vProbeResObj.RoomRateServiceGroup = vProbeResObj.Договор.RoomRateServiceGroup;
//			ElsIf ЗначениеЗаполнено(vProbeResObj.Контрагент) And ЗначениеЗаполнено(vProbeResObj.Контрагент.Тариф) Тогда
//				vProbeResObj.Тариф = vProbeResObj.Контрагент.Тариф;
//				vProbeResObj.RoomRateServiceGroup = vProbeResObj.Контрагент.RoomRateServiceGroup;
//			ElsIf ЗначениеЗаполнено(vProbeResObj.Гостиница) And ЗначениеЗаполнено(vProbeResObj.Гостиница.Тариф) Тогда
//				vProbeResObj.Тариф = vProbeResObj.Гостиница.Тариф;
//				vProbeResObj.RoomRateServiceGroup = vProbeResObj.Гостиница.RoomRateServiceGroup;
//			EndIf;
//			// Client type
//			If ЗначениеЗаполнено(vProbeResObj.Тариф) And ЗначениеЗаполнено(vProbeResObj.Тариф.ТипКлиента) Тогда
//				vProbeResObj.ТипКлиента = vProbeResObj.Тариф.ТипКлиента;
//				vProbeResObj.СтрокаПодтверждения = vProbeResObj.Тариф.СтрокаПодтверждения;
//			EndIf;
//		EndIf;
//		// Client type
//		If ЗначениеЗаполнено(vProbeResObj.Договор.ТипКлиента) Тогда
//			vProbeResObj.ТипКлиента = vProbeResObj.Договор.ТипКлиента;
//			vProbeResObj.СтрокаПодтверждения = vProbeResObj.Договор.СтрокаПодтверждения;
//		EndIf;
//		// Charging rules
//		vProbeResObj.pmLoadChargingRules(vProbeResObj.Договор);
//	EndIf;
//	vProbeResObj.pmSetDiscounts();
//	If ЗначениеЗаполнено(vDiscountType) Тогда
//		vProbeResObj.ТипСкидки = vDiscountType;
//		vProbeResObj.DiscountServiceGroup = vDiscountType.DiscountServiceGroup;
//		vProbeResObj.Скидка = vProbeResObj.ТипСкидки.GetObject().pmGetDiscount(vProbeResObj.CheckInDate, , vProbeResObj.Гостиница);
//	EndIf;
//	vReferenceHour = cmGetReferenceHour(vProbeResObj.Тариф);
//	vCheckInTime = cmGetDefaultCheckInTime(vProbeResObj.Тариф);
//	vPeriodFrom = BegOfDay(pPeriodFrom-24*3600)+(vCheckInTime-BegOfDay(vCheckInTime));
//	vPeriodTo = BegOfDay(pPeriodTo)+(vReferenceHour-BegOfDay(vReferenceHour));
//	If pPeriodFrom = pPeriodTo Тогда
//		vPeriodTo = EndOfDay(pPeriodTo);
//	EndIf;
//	vProbeResObj.CheckInDate = cm1SecondShift(vPeriodFrom);
//	vProbeResObj.ДатаВыезда = cm0SecondShift(vPeriodTo);
//	vProbeResObj.Продолжительность = vProbeResObj.pmCalculateDuration();
//	// Do for each ГруппаНомеров type in balances
//	vCurrency = Гостиница.Валюта;
//	vFoundRow = pRoomTypes.Find(pRoomType, "ТипНомера");
//	If vFoundRow = Неопределено And ЗначениеЗаполнено(pRoomType) Тогда
//		//vMessage = New UserMessage;
//		//vMessage.Text = NStr("en='The number of guests in current ГруппаНомеров type can not accommodate';ru='В выбранный тип номера указанное число гостей разместить нельзя';de='Im Zimmer des gewählten Typs kann die genannten Anzahl von Gästen nicht untergebracht werden'");
//		//vMessage.Field = "SelRoomType";
//		//vMessage.Message();
//	Else
//		vRoomTypeBalances = New ValueTable;
//		vRoomTypeBalances.Columns.Add("ТипНомера", cmGetCatalogTypeDescription("ТипыНомеров"));
//		vRoomTypeBalances.Columns.Add("AccommodationTemplate", cmGetCatalogTypeDescription("ШаблоныРазмещения"));
//		vRoomTypeBalances.Columns.Add("ВидРазмещения", cmGetCatalogTypeDescription("ВидыРазмещения"));
//		vRoomTypeBalances.Columns.Add("Amount", cmGetNumberTypeDescription(17, 2));
//		vRoomTypeBalances.Columns.Add("AmountPresentation", cmGetStringTypeDescription());
//		vRoomTypeBalances.Columns.Add("Валюта", cmGetCatalogTypeDescription("Валюты"));
//		vRoomTypesList = New СписокЗначений;
//		vRowsToDeleteArray = New Array;
//		If ЗначениеЗаполнено(pRoomType) Тогда
//			vFoundRowIndex = pRoomTypes.IndexOf(vFoundRow);
//			vRoomTypesList.Add(vFoundRow.ТипНомера);
//			If vFoundRowIndex > 0 Тогда
//				vPrevIndex = vFoundRowIndex - 1;
//				vRoomTypesList.Add(pRoomTypes.Get(vPrevIndex).ТипНомера);
//			EndIf;
//			If vFoundRowIndex < (pRoomTypes.Count() - 1) Тогда
//				vNextIndex = vFoundRowIndex + 1;
//				vRoomTypesList.Add(pRoomTypes.Get(vNextIndex).ТипНомера);
//			EndIf;
//		Else
//			For Each vRow In pRoomTypes Do
//				vRoomTypesList.Add(vRow.ТипНомера);
//			EndDo;
//		EndIf;
//		vLastRoomType = Справочники.ТипыНомеров.EmptyRef();
//		
//		vServicesList = New ValueTable;
//		vServicesList.Columns.Add("Period");
//		vServicesList.Columns.Add("Сумма");
//		For Each vRTItem In vRoomTypesList Do
//			If vRTItem.Value <> pRoomType Тогда
//				Continue;
//			EndIf;	
//			// Get accommodation types table with ages
//			vAccTypesWithAgeList = cmGetAvailableAccommodationTypesWithKidsAges(vAdultsQuantity, vKidsQuantity, vAgeArray, vExternalSystemCode, Гостиница, vRTItem.Value);
//			If vAccTypesWithAgeList.Count() = 0 Тогда
//				Continue;
//			EndIf;
//			If vRTItem.Value <> vLastRoomType Тогда
//				vProbeResObj.ТипНомера = vRTItem.Value;
//				vLastRoomType = vRTItem.Value;
//			EndIf;
//			vLastAT = Неопределено;
//			vATError = Неопределено;
//			vFindedAT = Неопределено;
//			vArrayOfRowsToDelete = New Array;
//			For Each vATRow In vAccTypesWithAgeList Do
//				If vLastAT <> vATRow.AccTemplate Тогда
//					If vATError<>Неопределено And vATError Тогда
//						vFindedRowsToDelete = vRoomTypeBalances.FindRows(New Structure("AccommodationTemplate, ТипНомера", vLastAT, vRTItem.Value));
//						For Each vItem In vFindedRowsToDelete Do
//							vArrayOfRowsToDelete.Add(vItem);
//						EndDo;
//						vLastAT = Неопределено;
//						vFindedAT = Неопределено;
//						vATError = False;
//					EndIf;
//					If (vATError = Неопределено Or НЕ vATError) And vLastAT<>Неопределено Тогда
//						vFindedAT = vLastAT;
//						break;
//					EndIf;
//					vLastAT = vATRow.AccTemplate;
//				EndIf;
//				If vATError<>Неопределено And vATError Тогда
//					Continue;
//				EndIf;
//				vProbeResObj.ВидРазмещения = vATRow.ВидРазмещения;
//				// Calculate resources
//				vProbeResObj.pmCalculateResources(True);
//				// Automatic services list calculation
//				vProbeResObj.pmCalculateServices();
//				
//				// Check if there are any services for this accommodation type
//				vRoomRevenueServices = vProbeResObj.Услуги.FindRows(New Structure("IsRoomRevenue", True));
//				
//				If vRoomRevenueServices.Count() = 0 Тогда	
//					vATError = True;
//					Continue;
//				EndIf;
//				// Calculate accommodation type amount
//				vAccTypeAmount = vProbeResObj.Услуги.Total("Сумма") - vProbeResObj.Услуги.Total("СуммаСкидки");
//				
//				For Each Str In vProbeResObj.Услуги Do
//					
//					vnewRow = vServicesList.Add();
//					vnewRow.Period = Str.УчетнаяДата;
//					vnewRow.Сумма = Str.Сумма-Str.СуммаСкидки;
//					
//				EndDo; 
//								// Get currency
//				For Each vSrvRow In vProbeResObj.Услуги Do
//					If vSrvRow.IsRoomRevenue Тогда
//						vCurrency = vSrvRow.ВалютаЛицСчета;
//						Break;
//					EndIf;
//				EndDo;
//				
//				// Save amount to the accommodation types value table
//				vNewBalanceRow = vRoomTypeBalances.Add();
//				vNewBalanceRow.ТипНомера = vRTItem.Value;
//				vNewBalanceRow.AccommodationTemplate = vATRow.AccTemplate;
//				vNewBalanceRow.ВидРазмещения = vATRow.ВидРазмещения;
//				vNewBalanceRow.Amount = vAccTypeAmount;
//				vNewBalanceRow.AmountPresentation = cmFormatSum(vAccTypeAmount, vCurrency, "NZ=");
//				vNewBalanceRow.Валюта = vCurrency;
//			EndDo;
//			If (vATError = Неопределено Or НЕ vATError) And vLastAT<>Неопределено Тогда
//				vFindedAT = vLastAT;
//			EndIf;
//			For Each vArrayItem In vArrayOfRowsToDelete Do
//				vRoomTypeBalances.Delete(vArrayItem);
//			EndDo;
//			If НЕ ЗначениеЗаполнено(vFindedAT) And vATError = True Тогда
//				vFindedRowsToDelete = vRoomTypeBalances.FindRows(New Structure("ТипНомера", vRTItem.Value));
//				For Each vItem In vFindedRowsToDelete Do
//					vRoomTypeBalances.Delete(vItem);
//				EndDo;
//				Continue;
//			EndIf;
//		EndDo;
//	EndIf;
//	// Remove folios created by documents
//	If pProbeResObj = Неопределено Тогда
//		For Each vCRRow In vProbeResObj.ChargingRules Do
//			vFolioObj = vCRRow.ChargingFolio.GetObject();
//			vFolioObj.Delete();
//		EndDo;
//		vProbeResObj = Неопределено;
//	EndIf;
//
//	If vServicesList <> Неопределено Тогда
//		vServicesList.GroupBy("Period","Сумма");
//	Else
//		vServicesList = New ValueTable();
//	EndIf;
//	Return vServicesList;
//EndFunction // GetPriceByPeriod()
//
////-----------------------------------------------------------------------------
//&AtServer
//Function CreateGuestGroup() 
//	If ЗначениеЗаполнено(Гостиница) Тогда
//		If НЕ Гостиница.AssignReservationGuestGroupsManually Тогда
//			vGuestGroupObj = Справочники.ГруппыГостей.CreateItem();
//			vGuestGroupObj.Owner = Гостиница;
//			vGuestGroupFolder = Гостиница.GetObject().pmGetGuestGroupFolder();
//			If ЗначениеЗаполнено(vGuestGroupFolder) Тогда
//				vGuestGroupObj.Parent = vGuestGroupFolder;
//				vGuestGroupObj.SetNewCode();
//			EndIf;
//			vGuestGroupObj.OneCustomerPerGuestGroup = Гостиница.OneCustomerPerGuestGroup;
//			vGuestGroupObj.Write();
//			GuestGroup = vGuestGroupObj.Ref;
//			Return True;
//		EndIf;
//	Else
//		Return False;
//	EndIf;
//EndFunction //CreateGuestGroup
//
////-----------------------------------------------------------------------------
//&AtServer
//Процедура FillAccommodationTypesChoiceList(IsRoom = True)
//	vQry = New Query;
//	vQry.Text =
//	"SELECT
//	|	ВидыРазмещений.Ref
//	|FROM
//	|	Catalog.ВидыРазмещений AS ВидыРазмещений
//	|WHERE
//	|	NOT ВидыРазмещений.DeletionMark
//	|	AND NOT ВидыРазмещений.IsFolder
//	|	"+?(IsRoom, "", "AND ВидыРазмещений.КоличествоНомеров = &qNumberOfRooms ")+
//	" ORDER BY
//	|	ВидыРазмещений.ПорядокСортировки";
//	If НЕ IsRoom Тогда
//		vQry.SetParameter("qNumberOfRooms", 0);
//	EndIf;
//	vResult = vQry.Execute().Choose();
//	vAccTypesArray = New Array;
//	While vResult.Next() Do
//		vAccTypesArray.Add(vResult.Ref);
//	EndDo;
//	SkipOnActivateCell = True;
//	Items.AccommodationTypesTableAccommodationType.ChoiceList.LoadValues(vAccTypesArray);
//КонецПроцедуры //FillAccommodationTypesChoiceList
//
////-----------------------------------------------------------------------------
//&НаКлиенте
//Процедура AccommodationTypesTableAccommodationTypeOnChange(pItem)
//	AccommodationTypeOnChangeAtServer();
//КонецПроцедуры //AccommodationTypesTableAccommodationTypeOnChange
//
////-----------------------------------------------------------------------------
//&AtServer
//Процедура AccommodationTypeOnChangeAtServer()
//	If CheckFields() Тогда
//		vIndex = 0;
//		For Each vRow In AccommodationTypesTable Do
//			If НЕ ЗначениеЗаполнено(vRow.ВидРазмещения) Тогда
//				AccommodationTypesTable.Delete(vRow);
//			Else
//				vRow.RowIndex = vIndex;
//				vIndex = vIndex + 1;
//			EndIf;
//		EndDo;
//		If AccommodationTypesTable.Count() > 0 Тогда
//			vAccTypetable = AccommodationTypesTable.Unload(,"ВидРазмещения");
//			GetPrice(vAccTypetable);
//		EndIf;
//	EndIf;
//КонецПроцедуры //AccommodationTypeOnChangeAtServer
//
////-----------------------------------------------------------------------------
//&НаКлиенте
//Процедура NewReserv(pCommand)
//	#If WebClient Тогда
//		SkipOnActivateAreaFromCalculate = 2;
//	#EndIf
//	If CheckFields() Тогда
//		vError = "";
//		If AccommodationTypesTable.Count() = 0 Тогда
//			GetPrice(,True);
//		ElsIf НЕ CheckRoomsBedsAndPersonsPerRoom(vError) Тогда
//			Message(vError);
//			Return;
//		EndIf;
//		If AccommodationTypesTable.Count() > 0 Тогда
//			CreateNewReservationObject(vError);
//			If НЕ IsBlankString(vError) Тогда
//				Message(vError);
//			Else
//				vFrm = ПолучитьФорму("Document.Бронирование.Form.tcDocumentForm",, ЭтаФорма);
//				CopyFormData(ResObject, vFrm.Object);
//				vFrm.DocsList = DocsList.Copy();
//				vFrm.Open();
//			EndIf;
//		Else
//			Message(NStr("en='Accommodation types table is empty';ru='Заполните таблицу видов размещения';de='Tabelle der Unterbringungstypen ausfüllen'"));
//		EndIf;
//	EndIf;
//КонецПроцедуры //NewReserv
//
////-----------------------------------------------------------------------------
//&AtServer
//Процедура CreateNewReservationObject(rError = "")
//	DocsList.Clear();
//	// Check rights to use allotment
//	If ЗначениеЗаполнено(RoomQuota) And ЗначениеЗаполнено(RoomQuota.Фирма) And ЗначениеЗаполнено(ПараметрыСеанса.ТекПользователь) And ЗначениеЗаполнено(ПараметрыСеанса.ТекПользователь.Фирма) And 
//	   RoomQuota.Фирма <> ПараметрыСеанса.ТекПользователь.Фирма Тогда
//		rError = NStr("en='You do not have rights to use " + СокрЛП(RoomQuota.Фирма) + " Фирма allotment!'; ru='У вас нет прав использовать квоту компании " + СокрЛП(RoomQuota.Фирма) + "!'; de='Sie sind nicht berechtigt, die Zimmerquote der Firma " + СокрЛП(RoomQuota.Фирма) + " verwenden!'");
//		Return;
//	EndIf;
//	If CheckRoomsBedsAndPersonsPerRoom(rError) Тогда
//		vRowStruct = GetParameters();
//		// Create reservation document
//		vDocObj = Documents.Бронирование.CreateDocument();
//		vDocObj.pmFillAttributesWithDefaultValues();
//		FillPropertyValues(vDocObj, vRowStruct);
//		vDocObj.ДатаЦены = '00010101';
//		If SelRoomType.StopSale Тогда
//			vRemarks = "";
//			If cmIsStopSalePeriod(SelRoomType, cm1SecondShift(CheckInDate), cm0SecondShift(CheckOutDate), vRemarks) Тогда
//				rError = NStr("en='You choose ГруппаНомеров type with stop sale flag turned on! Rechoose ГруппаНомеров type!';ru='Вы выбрали тип номера снятый с продажи! Перевыберите тип номера!';de='Sie haben einen Zimmertyp gewählt, der aus dem Angebot genommen wurde! Wählen Sie einen anderen Zimmertyp!'") + Chars.LF + vRemarks;
//				Return;
//			EndIf;
//		EndIf;      
//		If ЗначениеЗаполнено(vDocObj.Тариф) Тогда
//			If ЗначениеЗаполнено(vDocObj.Тариф.ИсточникИнфоГостиница) Тогда
//				vDocObj.ИсточникИнфоГостиница = vDocObj.Тариф.ИсточникИнфоГостиница;
//			EndIf;
//			If ЗначениеЗаполнено(vDocObj.Тариф.МаркетингКод) Тогда
//				vDocObj.МаркетингКод = vDocObj.Тариф.МаркетингКод;
//			EndIf;
//			If ЗначениеЗаполнено(vDocObj.Тариф.ТипКлиента) Тогда
//				vDocObj.ТипКлиента = vDocObj.Тариф.ТипКлиента;
//				vDocObj.СтрокаПодтверждения = vDocObj.Тариф.СтрокаПодтверждения;
//			EndIf;
//		EndIf;
//		If ЗначениеЗаполнено(vDocObj.КвотаНомеров) And ЗначениеЗаполнено(vDocObj.КвотаНомеров.Фирма) Тогда
//			vDocObj.Фирма = vDocObj.КвотаНомеров.Фирма;
//		EndIf;
//		vDocObj.pmCalculateResources();
//		vDocObj.pmSetDiscounts();
//		vDocObj.pmCalculateServices();
//		vDocObj.pmSetPlannedPaymentMethod();
//		ValueToFormAttribute(vDocObj, "ResObject");
//	EndIf;
//КонецПроцедуры //CreateNewReservationObject
//
////-----------------------------------------------------------------------------
//&AtServer
//Function GetParameters()
//	vRowStruct = Неопределено;
//	vCompany = Справочники.Companies.EmptyRef();
//	vCurHotel = ПараметрыСеанса.ТекущаяГостиница;
//	If ЗначениеЗаполнено(vCurHotel.Тариф) And ЗначениеЗаполнено(vCurHotel.Тариф.Фирма) Тогда
//		vCompany = vCurHotel.Тариф.Фирма;
//	ElsIf ЗначениеЗаполнено(SelRoomType) And ЗначениеЗаполнено(SelRoomType.Фирма) Тогда
//		vCompany = SelRoomType.Фирма;
//	ElsIf ЗначениеЗаполнено(vCurHotel.Фирма) Тогда
//		vCompany = vCurHotel.Фирма;
//	EndIf;
//	vCheckInDate = BegOfDay(CheckInDate);
//	vCheckOutDate = BegOfDay(CheckOutDate);
//	vCheckInTime = 9 * 3600;
//	vCheckOutTime = 22 * 3600;
//	If ЗначениеЗаполнено(Тариф) And Тариф.DurationCalculationRuleType = Перечисления.DurationCalculationRuleTypes.ByReferenceHour Тогда
//		If ЗначениеЗаполнено(Тариф.DefaultCheckInTime) Тогда
//			vCheckInTime = Тариф.DefaultCheckInTime - BegOfDay(Тариф.DefaultCheckInTime);
//		Else
//			vCheckInTime = Тариф.ReferenceHour - BegOfDay(Тариф.ReferenceHour);
//		EndIf;
//		vCheckOutTime = Тариф.ReferenceHour - BegOfDay(Тариф.ReferenceHour);
//	EndIf;
//	vCheckInDate = cm1SecondShift(vCheckInDate + vCheckInTime);
//	vCheckOutDate = cm0SecondShift(vCheckOutDate + vCheckOutTime);
//	If BegOfDay(vCheckOutDate) <= BegOfDay(vCheckInDate) Тогда
//		vCheckOutDate = vCheckOutDate + 24*3600;
//	EndIf;
//	vDuration = cmCalculateDuration(Тариф, vCheckInDate, vCheckOutDate);
//	If AccommodationTypesTable.Count() > 0 Тогда
//		vNumberOfPersons = 1;
//		vRowStruct = New Structure("Гостиница, КвотаНомеров, ТипНомера, ВидРазмещения, КоличествоЧеловек, RoomQuantity, CheckInDate, Продолжительность, ДатаВыезда, Тариф, ТипКлиента, Фирма, Posted, DeletionMark", 
//		                           vCurHotel, RoomQuota, SelRoomType, AccommodationTypesTable.Get(0).ВидРазмещения, vNumberOfPersons, 1, vCheckInDate, vDuration, vCheckOutDate, Тариф, ClientType, vCompany, False, False);
//	Else
//		vRowStruct = New Structure("Гостиница, КвотаНомеров, ТипНомера, CheckInDate, Продолжительность, ДатаВыезда, Тариф, ТипКлиента, Фирма", 
//		                           vCurHotel, RoomQuota, SelRoomType, vCheckInDate, vDuration, vCheckOutDate, Тариф, ClientType, vCompany);
//	EndIf;
//	Return vRowStruct;
//EndFunction //GetParameters
//
////-----------------------------------------------------------------------------
//&AtServer
//Function CheckRoomsBedsAndPersonsPerRoom(rError)
//	rError = "";
//	vKidError = False;
//	vRooms = 0;
//	vBeds = 0;
//	vAddBeds = 0;
//	vPersons = 0;
//	vInd = 0;
//	vKidError = False;
//	If NumberOfKids > 0 Тогда
//		vKidsArray = New Array;
//		For vI = 1 To NumberOfKids Do
//			Try
//				If vI = 1 Тогда
//					vKidsArray.Add(KidAge1);
//				Else
//					If vKidsArray.Get(vI-1) > ЭтаФорма["KidAge"+String(vI)] Тогда
//						vKidsArray.Add(ЭтаФорма["KidAge"+String(vI)]);
//					Else
//						vKidsArray.Вставить(vI-1, ЭтаФорма["KidAge"+String(vI)]);
//					EndIf;
//				EndIf;
//			Except
//			EndTry;
//		EndDo;
//	EndIf;
//	For Each vRow In AccommodationTypesTable Do
//		If ЗначениеЗаполнено(vRow.ДатаРождения) And НЕ ЗначениеЗаполнено(vRow.GuestName) Тогда
//			rError = NStr("en='Fill guests name in rows with filled';ru='Заполните ФИО гостей в строках, где указана дата рождения';de='Namen und Vornamen der Gäste in Zeile mit dem Geburtsdatum ausfüllen'");
//			Return False;
//		EndIf;
//		If ЗначениеЗаполнено(vRow.ВидРазмещения) Тогда
//			If vRow.ВидРазмещения.AllowedClientAgeTo > 0 Тогда
//				If NumberOfKids > 0 Тогда
//					If НЕ ЗначениеЗаполнено(vRow.ДатаРождения) Тогда
//						If IsBlankString(rError) Тогда
//							rError = СокрЛП(vRow.ВидРазмещения);
//						Else
//							rError = rError + ", " + СокрЛП(vRow.ВидРазмещения);
//						EndIf;
//					Else
//						If Month(CheckInDate) > Month(vRow.ДатаРождения) Тогда
//							vKidYear = Year(CheckInDate) - Year(vRow.ДатаРождения);
//						ElsIf Month(CheckInDate) < Month(vRow.ДатаРождения) Тогда
//							vKidYear = Year(CheckInDate) - Year(vRow.ДатаРождения) - 1;
//						ElsIf Day(CheckInDate) <= Day(vRow.ДатаРождения) Тогда
//							vKidYear = Year(CheckInDate) - Year(vRow.ДатаРождения) - 1;
//						Else
//							vKidYear = Year(CheckInDate) - Year(vRow.ДатаРождения);
//						EndIf;
//						vArInd = 0;
//						vKidError = False;
//						For Each vKidItem In vKidsArray Do
//							If vKidItem = vKidYear Тогда
//								vKidsArray.Delete(vArInd);
//								vKidError = False;
//								Break;
//							Else
//								vKidError = True;
//							EndIf;
//							vArInd = vArInd + 1;
//						EndDo;
//					EndIf;
//				EndIf;
//			EndIf;
//			vRooms = vRooms + vRow.ВидРазмещения.КоличествоНомеров;
//			vBeds = vBeds + vRow.ВидРазмещения.КоличествоМест;
//			vAddBeds = vAddBeds + vRow.ВидРазмещения.КолДопМест;
//			vPersons = vPersons + vRow.ВидРазмещения.КоличествоЧеловек;
//			vRowStruc = GetRowStructure(vRow, vInd);
//			DocsList.Add(vRowStruc, String(vRow.ВидРазмещения.ПорядокСортировки));
//			If НЕ ChangeClientObject(vRow.GuestRef, vRow.GuestName, vRow.ДатаРождения, vInd) Тогда
//				Message(NStr("en='Failed to write client (!';ru='Не удалось записать клиента (!';de='Der Kunde konnte nicht geschrieben werden (!'")+vRow.GuestName+")");
//			EndIf;
//			vIsFirstRow = False;
//			vInd = vInd + 1;
//		EndIf;
//	EndDo;
//	If ЗначениеЗаполнено(rError) Тогда
//		rError = NStr("en='Fill birth dates in rows with accommodation types: ';ru='Заполните даты рождения детей в строках с видами размещения: ';de='Geburtsdaten der Kinder in den Zeilen mit Unterbringungsarten eintragen: '") + rError;
//	EndIf;
//	If vRooms > 1 Тогда
//		rError = NStr("ru='Вы не можете забронировать сразу больше одного номера.'; en='You can't reserve more than one НомерРазмещения.'; de='You can't reserve more than one НомерРазмещения.'");
//	ElsIf vBeds > SelRoomType.КоличествоМестНомер Тогда
//		rError = NStr("en='НЕ enough free beds!';ru='Не хватает свободных мест!';de='Es gibt nicht ausreichend freie Betten!'");
//	ElsIf vPersons > SelRoomType.КоличествоГостейНомер Тогда
//		rError = NStr("en='You can not reserve ';ru='Невозможно забронировать ';de='Reservierung unmöglich '")+String(vPersons-SelRoomType.КоличествоГостейНомер)+NStr("en=' persons in the ГруппаНомеров';ru=' человек в номер';de=' Personen im Zimmer'");
//	ElsIf vKidError Тогда
//		rError = NStr("en='Please check kids ages and dates of birth';ru='Проверьте указанные возраст и даты рождения детей';de='Überprüfen Sie das genannte Alter und Geburtsdatum von Kindern'");
//	EndIf;
//	If IsBlankString(rError) Тогда 
//		Return True;
//	EndIf;
//	Return False;
//EndFunction //CheckRoomsBedsAndPersonsPerRoom
//
////-----------------------------------------------------------------------------
//&AtServer
//Function GetRowStructure(pRow, pIndex)
//	If pIndex = 0 Тогда
//		vStructure = New Structure("ВидРазмещения, Amount, GuestName, GuestRef, ДатаРождения, Телефон, Email", pRow.ВидРазмещения, pRow.Цена, pRow.GuestName, pRow.GuestRef, pRow.ДатаРождения, Phone, EMail); 
//	Else
//		vStructure = New Structure("ВидРазмещения, Amount, GuestName, GuestRef, ДатаРождения, Телефон, Email", pRow.ВидРазмещения, pRow.Цена, pRow.GuestName, pRow.GuestRef, pRow.ДатаРождения, "", ""); 
//	EndIf;
//	Return vStructure;
//EndFunction //GetRowStructure
//
////-----------------------------------------------------------------------------
//&НаКлиенте
//Процедура AccommodationTypesTableGuestNameAutoComplete(pItem, pText, pChoiceData, pWait, pStandardProcessing)
//	pStandardProcessing = False;
//	vCurData = pItem.Parent.CurrentData;
//	If ЗначениеЗаполнено(vCurData.GuestRef) And НЕ IsBlankString(pText) Тогда
//		vCurData.GuestName = TrimR(LastGuestFullName);
//		vMessage = New UserMessage;
//		vMessage.Field = "AccommodationTypesTable["+String(vCurData.RowIndex)+"].GuestName";
//		vMessage.Text = NStr("en='The data can be changed in the guest card only! (To open the guest card, click the magnifying glass; To write a new guest, click the delete icon and type guest name in the field)';ru='Данные могут быть изменены только в карточке гостя! (Для того, чтобы открыть карточку гостя, нажмите кнопку с изображением лупы; Для того, чтобы создать нового гостя, нажмите кнопку с крестиком и введите ФИО гостя в поле)';de='Die Daten können nur in der Karte des Gastes geändert werden! (Um die Karte des Gastes zu öffnen, drücken Sie die Taste mit der Lupe; um einen neuen Gast zu erstellen, drücken Sie die Taste mit dem Kreuz und geben Sie den Namen und den Vornamen des Gastes ins Feld ein)'");
//		vMessage.Message();
//	Else
//		If StrLen(pText) > 2 Тогда
//			vChoiceDataUID = УпрСерверныеФункции.cmGetGuestsChoiceDataList(pText);
//			pChoiceData = GetFromTempStorage(vChoiceDataUID);
//			If pChoiceData.Count() = 0 Тогда
//				pChoiceData.Add(pText, NStr("en='--Guest not found--';ru='--Гость не найден--';de='--Gast nicht gefunden--'"));
//			EndIf;
//		EndIf;
//	EndIf;
//КонецПроцедуры //AccommodationTypesTableGuestNameAutoComplete
//
////-----------------------------------------------------------------------------
//&НаКлиенте
//Процедура AccommodationTypesTableGuestNameTextEditEnd(pItem, pText, pChoiceData, pStandardProcessing)
//	pStandardProcessing = False;
//	vCurData = pItem.Parent.CurrentData;
//	If ЗначениеЗаполнено(vCurData.GuestRef) Тогда
//		If IsBlankString(pText) Тогда
//			vCurData.GuestRef = Неопределено;
//			LastGuestFullName = "";
//		Else
//			vCurData.GuestName = LastGuestFullName;
//			vMessage = New UserMessage;
//			vMessage.Field = "AccommodationTypesTable["+String(vCurData.RowIndex)+"].GuestName";
//			vMessage.Text = NStr("en='The data can be changed in the guest card only! (To open the guest card, click the magnifying glass; To write a new guest, click the delete icon and type guest name in the field)';ru='Данные могут быть изменены только в карточке гостя! (Для того, чтобы открыть карточку гостя, нажмите кнопку с изображением лупы; Для того, чтобы создать нового гостя, нажмите кнопку с крестиком и введите ФИО гостя в поле)';de='Die Daten können nur in der Karte des Gastes geändert werden! (Um die Karte des Gastes zu öffnen, drücken Sie die Taste mit der Lupe; um einen neuen Gast zu erstellen, drücken Sie die Taste mit dem Kreuz und geben Sie den Namen und den Vornamen des Gastes ins Feld ein)'");
//			vMessage.Message();
//		EndIf;
//	Else
//		pChoiceData = New СписокЗначений();
//		pChoiceData.Add(TrimR(pText));
//	EndIf;
//КонецПроцедуры //AccommodationTypesTableGuestNameTextEditEnd
//
////-----------------------------------------------------------------------------
//&НаКлиенте
//Процедура AccommodationTypesTableGuestNameChoiceProcessing(pItem, pSelectedValue, pStandardProcessing)
//	pStandardProcessing = False;
//	vCurData = pItem.Parent.CurrentData;
//	If ЗначениеЗаполнено(pSelectedValue) Тогда
//		If TypeOf(pSelectedValue) = Type("CatalogRef.Clients") Тогда
//			vCurData.GuestRef = pSelectedValue;
//			vCurData.GuestName = УпрСерверныеФункции.cmGetAttributeByRef(pSelectedValue, "FullName");
//			LastGuestFullName = vCurData.GuestName;
//			vCurData.ДатаРождения = УпрСерверныеФункции.cmGetAttributeByRef(pSelectedValue, "ДатаРождения");
//			If ЗначениеЗаполнено(vCurData.ВидРазмещения) And vCurData.RowIndex = 0 Тогда
//				//vPhone = SMS.GetValidPhoneNumber(УпрСерверныеФункции.cmGetAttributeByRef(pSelectedValue, "Phone"));
//				vEMail = УпрСерверныеФункции.cmGetAttributeByRef(pSelectedValue, "EMail");
//				//If ЗначениеЗаполнено(vPhone) Тогда
//				//	Phone = vPhone;
//				//EndIf;
//				If ЗначениеЗаполнено(vEMail) Тогда
//					EMail = vEMail;
//				EndIf;
//			EndIf;
//		ElsIf TypeOf(pSelectedValue) = Type("String") Тогда
//			vCurData.GuestName = pSelectedValue;
//			If ЗначениеЗаполнено(vCurData.GuestRef) Тогда
//				vCurData.ДатаРождения = '00010101';
//			EndIf;
//			vCurData.GuestRef = УпрСерверныеФункции.cmGetCatalogItemRefByCode("Clients", "", True);
//		EndIf;
//	Else
//		vCurData.GuestRef = УпрСерверныеФункции.cmGetCatalogItemRefByCode("Clients",, True);
//		vCurData.ДатаРождения = '00010101';
//	EndIf;
//КонецПроцедуры //AccommodationTypesTableGuestNameChoiceProcessing
//
////-----------------------------------------------------------------------------
//&НаКлиенте
//Процедура AccommodationTypesTableGuestNameOpening(pItem, pStandardProcessing)
//	pStandardProcessing = False;
//	vCurData = pItem.Parent.CurrentData;
//	// Get client form
//	If ЗначениеЗаполнено(vCurData.GuestRef) And (УпрСерверныеФункции.cmGetAttributeByRef(vCurData.GuestRef, "FullName") = pItem.EditText) Тогда
//		vFrm = ПолучитьФорму("Catalog.Clients.Form.tcItemForm", New Structure("Key", vCurData.GuestRef), ЭтаФорма);
//		vFrm.Open();
//	Else
//		vFrm = ПолучитьФорму("Catalog.Clients.Form.tcItemForm",,ЭтаФорма, New UUID());
//		vSelGuest = pItem.EditText;
//		// Get guest last name, first name and second name
//		vFindedCharNumber = Find(СокрЛП(vSelGuest), " ");
//		vLastNameLastCharNumber = ?(vFindedCharNumber = 0, StrLen(vSelGuest), vFindedCharNumber - 1);
//		vFrm.Object.Фамилия = Title(Left(СокрЛП(vSelGuest), vLastNameLastCharNumber));
//		If vLastNameLastCharNumber<>StrLen(vSelGuest) Тогда
//			vSelGuest = Mid(СокрЛП(vSelGuest), vLastNameLastCharNumber+2, StrLen(vSelGuest));
//			vFindedCharNumber = Find(СокрЛП(vSelGuest), " ");
//			vFirstNameLastCharNumber = ?(vFindedCharNumber = 0, StrLen(vSelGuest), vFindedCharNumber - 1);
//			vFrm.Object.Имя = Title(Left(СокрЛП(vSelGuest), vFirstNameLastCharNumber));
//			If vFirstNameLastCharNumber<>StrLen(vSelGuest) Тогда
//				vSelGuest = Mid(СокрЛП(vSelGuest), vFirstNameLastCharNumber+2, StrLen(vSelGuest));
//				vFindedCharNumber = Find(СокрЛП(vSelGuest), " ");
//				vSecondNameLastCharNumber = ?(vFindedCharNumber = 0, StrLen(vSelGuest), vFindedCharNumber - 1);
//				vFrm.Object.Отчество = Title(Left(СокрЛП(vSelGuest), vSecondNameLastCharNumber));
//			EndIf;
//		EndIf;
//		If vCurData.RowIndex = 0 Тогда
//			vFrm.Object.EMail = EMail;
//			vFrm.Object.Телефон = Phone;
//		EndIf;
//		vFrm.Open();
//	EndIf;
//КонецПроцедуры //AccommodationTypesTableGuestNameOpening
//
////-----------------------------------------------------------------------------
//&НаКлиенте
//Процедура AccommodationTypesTableGuestNameClearing(pItem, pStandardProcessing)
//	vCurData = pItem.Parent.CurrentData;
//	vCurData.GuestRef = "";
//	vCurData.ДатаРождения = '00010101';
//КонецПроцедуры //AccommodationTypesTableGuestNameClearing
//
////-----------------------------------------------------------------------------
//&НаКлиенте
//Процедура AccommodationTypesTableGuestNameStartChoice(pItem, pChoiceData, pStandardProcessing)
//	pStandardProcessing = False;
//	vCurData = pItem.Parent.CurrentData;
//	// Get clients search form
//	vFrm = ПолучитьФорму("Catalog.Clients.Form.ФормаУпрСписка",, pItem);
//	If ЗначениеЗаполнено(vCurData.GuestRef) Тогда
//		vFrm.SelLastName = УпрСерверныеФункции.cmGetAttributeByRef(vCurData.GuestRef, "Фамилия");
//		vFrm.SelFirstName = УпрСерверныеФункции.cmGetAttributeByRef(vCurData.GuestRef, "Имя");
//		vFrm.SelSecondName = УпрСерверныеФункции.cmGetAttributeByRef(vCurData.GuestRef, "Отчество");
//	Else
//		//Get guest last name, first name and second name
//		vSelGuest = pItem.EditText;
//		vFindedCharNumber = Find(СокрЛП(vSelGuest), " ");
//		vLastNameLastCharNumber = ?(vFindedCharNumber = 0, StrLen(vSelGuest), vFindedCharNumber - 1);
//		vFrm.SelLastName = Title(Left(СокрЛП(vSelGuest), vLastNameLastCharNumber));
//		If vLastNameLastCharNumber<>StrLen(vSelGuest) Тогда
//			vSelGuest = Mid(СокрЛП(vSelGuest), vLastNameLastCharNumber+2, StrLen(vSelGuest));
//			vFindedCharNumber = Find(СокрЛП(vSelGuest), " ");
//			vFirstNameLastCharNumber = ?(vFindedCharNumber = 0, StrLen(vSelGuest), vFindedCharNumber - 1);
//			vFrm.SelFirstName = Title(Left(СокрЛП(vSelGuest), vFirstNameLastCharNumber));
//			If vFirstNameLastCharNumber<>StrLen(vSelGuest) Тогда
//				vSelGuest = Mid(СокрЛП(vSelGuest), vFirstNameLastCharNumber+2, StrLen(vSelGuest));
//				vFindedCharNumber = Find(СокрЛП(vSelGuest), " ");
//				vSecondNameLastCharNumber = ?(vFindedCharNumber = 0, StrLen(vSelGuest), vFindedCharNumber - 1);
//				vFrm.SelSecondName = Title(Left(СокрЛП(vSelGuest), vSecondNameLastCharNumber));
//			EndIf;
//		EndIf; 
//	EndIf;
//	vFrm.Items.List.MultipleChoice = False;
//	vFrm.Open();
//КонецПроцедуры //AccommodationTypesTableGuestNameStartChoice
//
////-----------------------------------------------------------------------------
//&НаКлиенте
//Процедура AccommodationTypesTableBeforeAddRow(pItem, pCancel, pClone, pParent, pFolder)
//	If НЕ CheckFields() Тогда
//		pCancel = True;			
//	EndIf;
//КонецПроцедуры //AccommodationTypesTableBeforeAddRow
//
////-----------------------------------------------------------------------------
//&НаКлиенте
//Процедура RoomQuotaOnChange(pItem)
//	BuildReport();
//КонецПроцедуры //RoomQuotaOnChange
//
////-----------------------------------------------------------------------------
//&НаКлиенте
//Процедура Refresh(pCommand)
//	#If НЕ WebClient Тогда
//		Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 60, NStr("en='Refreshing...';ru='Обновление...';de='Aktualisierung…'"), PictureLib.LongOperation); 	
//	#EndIf
//	
//	BuildReport();
//	
//	#If НЕ WebClient Тогда
//		Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 100, NStr("en='Refreshing...';ru='Обновление...';de='Aktualisierung…'"), PictureLib.LongOperation); 
//	#EndIf
//КонецПроцедуры //Refresh
//
////-----------------------------------------------------------------------------
//&НаКлиенте
//Процедура ReportDetailProcessing(pItem, pDetails, pStandardProcessing)
//	If TypeOf(pDetails) = Type("Structure") Тогда
//		pStandardProcessing = False;
//		If НЕ ЗначениеЗаполнено(pDetails.ПериодПо) And ЗначениеЗаполнено(pDetails.ТипНомера) Тогда
//			vRoomTypePictureLink = УпрСерверныеФункции.cmGetAttributeByRef(pDetails.ТипНомера, "RoomTypePictureLink");
//			vRoomTypeInfoLink = УпрСерверныеФункции.cmGetAttributeByRef(pDetails.ТипНомера, "RoomTypeInfoLink");
//			OpenForm("CommonForm.упрИнфо", New Structure("InfoLink, PictureLink, ТипНомера", vRoomTypeInfoLink, vRoomTypePictureLink, pDetails.ТипНомера));
//		Else
//			#IF ThickClientOrdinaryApplication THEN
//				// Open ГруппаНомеров inventory report
//				If НЕ cmCheckUserRightsToOpenReport(Справочники.Отчеты.ЗагрузкаНомеров) Тогда
//					ВызватьИсключение "У вас нет прав на формирование отчета: " + Справочники.Отчеты.ЗагрузкаНомеров.Description + "!";
//				EndIf;
//				vRepObj = cmBuildReportObject(Справочники.Отчеты.ЗагрузкаНомеров);
//				If vRepObj <> Неопределено Тогда
//					// Load report catalog item attributes
//					vRepObj.Report = Справочники.Отчеты.ЗагрузкаНомеров;
//					// Open report's default form
//					vRepFrm = vRepObj.ПолучитьФорму();
//					vRepFrm.GenerateOnFormOpen = False;
//					vRepFrm.Open();
//					// Set report attributes from parameters
//					vRepObj.Гостиница = pDetails.Гостиница;
//					vRepObj.ТипНомера = pDetails.ТипНомера;
//					vRepObj.ПериодПо = EndOfDay(pDetails.ПериодПо);
//					// Generate report
//					vRepFrm.fmGenerateReport();
//				EndIf;
//			#ENDIF
//		EndIf;
//	ElsIf TypeOf(pDetails) <> Type("CatalogRef.Мероприятия") Тогда
//		pStandardProcessing = False;
//	EndIf;
//КонецПроцедуры //ReportDetailProcessing
//
////-----------------------------------------------------------------------------
//&НаКлиенте
//Процедура NotificationProcessing(pEventName, pParameter, pSource)
//	If pEventName = "Клиент.Change" Тогда
//		Try
//			vCurData = ЭтаФорма.CurrentItem.CurrentData;
//			vCurData.GuestRef = pParameter;
//			vCurData.GuestName = УпрСерверныеФункции.cmGetAttributeByRef(pParameter, "FullName");
//			LastGuestFullName = vCurData.GuestName;
//			vCurData.ДатаРождения = УпрСерверныеФункции.cmGetAttributeByRef(pParameter, "ДатаРождения");
//			If ЗначениеЗаполнено(vCurData.ВидРазмещения) And vCurData.RowIndex = 0 Тогда
//				//vPhone = SMS.GetValidPhoneNumber(УпрСерверныеФункции.cmGetAttributeByRef(pParameter, "Phone"));
//				vEMail = УпрСерверныеФункции.cmGetAttributeByRef(pParameter, "EMail");
//				//If ЗначениеЗаполнено(vPhone) Тогда
//				//	Phone = vPhone;
//				//EndIf;
//				If ЗначениеЗаполнено(vEMail) Тогда
//					EMail = vEMail;
//				EndIf;
//			EndIf;
//		Except
//		EndTry;
//	ElsIf pEventName = "Document.Бронирование.Write" Or pEventName = "Document.Бронирование.WriteNew" Тогда
//		AccommodationTypesTable.Clear();
//		Items.AccommodationTypesTablePrice.FooterText = "";
//		EMail = "";
//		Phone = "";
//		If НЕ ShowPrices Тогда
//			BuildReport();
//		EndIf;
//	ElsIf pEventName = "Document.Размещение.Write" Or pEventName = "Document.Размещение.WriteNew" Тогда
//		If НЕ ShowPrices Тогда
//			BuildReport();
//		EndIf;
//	EndIf;
//КонецПроцедуры //NotificationProcessing
//
////-----------------------------------------------------------------------------
//&НаКлиенте
//Процедура AccommodationTypesTableDateOfBirthOnChange(pItem)
//	vCurData = pItem.Parent.CurrentData;
//	If ЗначениеЗаполнено(vCurData.GuestRef) Тогда
//		vDateOfBirth = vCurData.ДатаРождения;
//		If НЕ ChangeClientObject(vCurData.GuestRef, vCurData.GuestName, vDateOfBirth, vCurData.RowIndex) Тогда
//			Message(NStr("en='Failed to write object!';ru='Не удалось записать объект!';de='Das Objekt konnte nicht geschrieben werden!'"));
//		EndIf;
//	EndIf;
//КонецПроцедуры //AccommodationTypesTableDateOfBirthOnChange
//
////-----------------------------------------------------------------------------
//&AtServer
//Function ChangeClientObject(rClientRef, pFullName = "", pDateOfBirth, pRow)
//	If ЗначениеЗаполнено(pFullName) Тогда
//		Try
//			If НЕ ЗначениеЗаполнено(rClientRef) Тогда
//				vClientObj = Справочники.Clients.CreateItem();
//				vClientObj.pmFillAttributesWithDefaultValues();
//				//Get guest last name, first name and second name
//				GetClientDetailedNameByFullName(vClientObj, pFullName);
//			Else
//				vClientObj = rClientRef.GetObject();
//				vClientObj.ДатаРождения = pDateOfBirth;
//			EndIf;
//			If pRow = 0 Тогда
//				If ЗначениеЗаполнено(Phone) Тогда
//					vClientObj.Телефон = Phone;
//				EndIf;
//				If ЗначениеЗаполнено(EMail) Тогда
//					vClientObj.EMail = EMail;
//				EndIf;
//			EndIf;
//			vClientObj.Write();
//			vClientObj.pmWriteToClientChangeHistory(CurrentDate(), ПараметрыСеанса.ТекПользователь);
//			rClientRef = vClientObj.Ref;
//			UserWorkHistory.Add(rClientRef);
//		Except
//			Return False;
//		EndTry;
//	EndIf;
//	Return True;
//EndFunction //ChangeClientObject
//
////-----------------------------------------------------------------------------
//&AtServer
//Процедура GetClientDetailedNameByFullName(pClientObj, pFullName)
//	vFullName = pFullName;
//	//Get guest last name, first name and second name
//	vFindedCharNumber = Find(СокрЛП(vFullName), " ");
//	vLastNameLastCharNumber = ?(vFindedCharNumber = 0, StrLen(vFullName), vFindedCharNumber - 1);
//	pClientObj.Фамилия = Title(Left(СокрЛП(vFullName), vLastNameLastCharNumber));
//	If vLastNameLastCharNumber<>StrLen(vFullName) Тогда
//		vFullName = Mid(СокрЛП(vFullName), vLastNameLastCharNumber+2, StrLen(vFullName));
//		vFindedCharNumber = Find(СокрЛП(vFullName), " ");
//		vFirstNameLastCharNumber = ?(vFindedCharNumber = 0, StrLen(vFullName), vFindedCharNumber - 1);
//		pClientObj.Имя = Title(Left(СокрЛП(vFullName), vFirstNameLastCharNumber));
//		If vFirstNameLastCharNumber<>StrLen(vFullName) Тогда
//			vFullName = Mid(СокрЛП(vFullName), vFirstNameLastCharNumber+2, StrLen(vFullName));
//			vFindedCharNumber = Find(СокрЛП(vFullName), " ");
//			vSecondNameLastCharNumber = ?(vFindedCharNumber = 0, StrLen(vFullName), vFindedCharNumber - 1);
//			pClientObj.Отчество = Title(Left(СокрЛП(vFullName), vSecondNameLastCharNumber));
//		EndIf;
//	EndIf; 
//	pClientObj.Пол = fmGetSexByName(pClientObj);
//КонецПроцедуры //GetClientDetailedNameByFullName
//
////-----------------------------------------------------------------------------
//&AtServer
//Function fmGetSexByName(pGuestObj)
//	If ЗначениеЗаполнено(pGuestObj.Гражданство) Тогда
//		If НЕ pGuestObj.Гражданство.IsVisaNecessaryForEntrance Тогда
//			If StrLen(СокрЛП(pGuestObj.Отчество)) < 2 Тогда
//				vLastCharLastName = Upper(Right(СокрЛП(pGuestObj.Фамилия), 1));
//				vLastCharFirstName = Upper(Right(СокрЛП(pGuestObj.Имя), 1));
//				If (vLastCharLastName = "А") Or (vLastCharLastName = "Я") Or
//					(vLastCharFirstName = "А") Or (vLastCharFirstName = "Я") Тогда
//					Return Перечисления.Пол.Female;
//				Else
//					Return Перечисления.Пол.Male;
//				EndIf;
//			Else
//				vLastCharSecondName = Upper(Right(СокрЛП(pGuestObj.Отчество), 1));
//				If vLastCharSecondName = "А" Тогда
//					Return Перечисления.Пол.Female;
//				Else
//					Return Перечисления.Пол.Male;
//				EndIf;
//			EndIf;
//		EndIf;
//	EndIf;
//EndFunction //fmGetSexByName
//
////-----------------------------------------------------------------------------
//&НаКлиенте
//Процедура PhoneOnChange(pItem)
//	#If WebClient Тогда
//		SkipOnActivateAreaFromCalculate = 2;
//	#EndIf
//	vStructure = PhoneOnChangeAtServer(Phone, "");
//	If IsBlankString(Phone) Тогда
//		Phone = vStructure.Телефон;
//	EndIf;
//	If IsBlankString(EMail) Тогда
//		EMail = vStructure.Email;
//	EndIf;
//	If vStructure.Клиент <> Неопределено Тогда
//		If AccommodationTypesTable.Count() > 0 Тогда
//			vFirstRow = AccommodationTypesTable.Get(0);
//		Else
//			vFirstRow = AccommodationTypesTable.Add();
//			vFirstRow.RowIndex = 0;
//			vFirstRow.ВидРазмещения = GetMainAccType();
//			If НЕ ЗначениеЗаполнено(NumberOfAdults) Тогда
//				NumberOfAdults = 1;
//			EndIf;
//			AccommodationTypeOnChangeAtServer();
//		EndIf;
//		If ЗначениеЗаполнено(vFirstRow.GuestRef) Тогда
//			If НЕ ChangeClientObject(vFirstRow.GuestRef, vFirstRow.GuestName, vFirstRow.ДатаРождения, 0) Тогда
//				Message(NStr("en='Failed to write object!';ru='Не удалось записать объект!';de='Das Objekt konnte nicht geschrieben werden!'"));
//			EndIf;
//		Else
//			vFirstRow.GuestRef = vStructure.Клиент;
//			vFirstRow.GuestName = vStructure.ClientFullName;
//			vFirstRow.ДатаРождения = vStructure.ДатаРождения;
//		EndIf;
//	EndIf;
//КонецПроцедуры //PhoneOnChange
//
////-----------------------------------------------------------------------------
//&AtServer
//Function GetMainAccType()
//	vQry = New Query;
//	vQry.Text =
//	"SELECT TOP 1
//	|	ВидыРазмещений.Ref
//	|FROM
//	|	Catalog.ВидыРазмещений AS ВидыРазмещений
//	|WHERE
//	|	ВидыРазмещений.КоличествоНомеров > 0
//	|	AND NOT ВидыРазмещений.IsFolder
//	|	AND NOT ВидыРазмещений.DeletionMark
//	|
//	|ORDER BY
//	|	ВидыРазмещений.ПорядокСортировки";
//	vQry.SetParameter("qHotel", Гостиница);
//	vQryChoose = vQry.Execute().Choose();
//	vAccType = Справочники.ВидыРазмещений.EmptyRef();
//	While vQryChoose.Next() Do
//		Return vQryChoose.Ref;
//	EndDo;
//EndFunction //GetMainAccType
//
////-----------------------------------------------------------------------------
//&AtServer
//Function PhoneOnChangeAtServer(pPhone = "", pEmail = "")
//	vResultStructure = New Structure("Клиент, ClientFullName, Телефон, EMail, ДатаРождения");
//	If IsBlankString(pPhone) And IsBlankString(pEmail) Тогда
//		Return vResultStructure;
//	EndIf;
//	//If ЗначениеЗаполнено(pPhone) Тогда
//	//	vPhone = SMS.GetValidPhoneNumber(pPhone);
//	//	vQry = New Query;
//	//	vQry.Text =
//	//	"SELECT
//	//	|	Clients.Ref,
//	//	|	Clients.Phone,
//	//	|	Clients.FullName,
//	//	|	Clients.EMail,
//	//	|	Clients.DateOfBirth
//	//	|FROM
//	//	|	Catalog.Clients AS Clients
//	//	|WHERE
//	//	|	NOT Clients.IsFolder
//	//	|	AND NOT Clients.DeletionMark
//	//	|	AND Clients.Phone = &qPhone";
//	//	vQry.SetParameter("qPhone", vPhone);
//	//Else
//	//	vQry = New Query;
//	//	vQry.Text =
//	//	"SELECT
//	//	|	Clients.Ref,
//	//	|	Clients.Phone,
//	//	|	Clients.FullName,
//	//	|	Clients.EMail,
//	//	|	Clients.DateOfBirth
//	//	|FROM
//	//	|	Catalog.Clients AS Clients
//	//	|WHERE
//	//	|	NOT Clients.IsFolder
//	//	|	AND NOT Clients.DeletionMark
//	//	|	AND Clients.Email = &qEmail";
//	//	vQry.SetParameter("qEmail", pEmail);
//	//EndIf;
//	//vQryResult = vQry.Execute().Unload();
//	//If vQryResult.Count() = 1 Тогда
//	//	vResultStructure.Client = vQryResult.Get(0).Ref;
//	//	vResultStructure.ClientFullName = vQryResult.Get(0).FullName;
//	//	vResultStructure.Phone = vQryResult.Get(0).Phone;
//	//	vResultStructure.EMail = vQryResult.Get(0).Email;;
//	//	vResultStructure.DateOfBirth = vQryResult.Get(0).DateOfBirth;;
//	//Else
//	//	vResultStructure.Client = Неопределено;
//	//	vResultStructure.ClientFullName = Неопределено;
//	//	vResultStructure.Phone = vPhone;
//	//	vResultStructure.EMail = pEmail;
//	//	vResultStructure.DateOfBirth = '00010101';
//	//EndIf;
//	////Return
//	Return vResultStructure;
//EndFunction //PhoneOnChangeAtServer
//
////-----------------------------------------------------------------------------
//&НаКлиенте
//Процедура EMailOnChange(pItem)
//	#If WebClient Тогда
//		SkipOnActivateAreaFromCalculate = 2;
//	#EndIf
//	vStructure = PhoneOnChangeAtServer("", Email);
//	If IsBlankString(Phone) Тогда
//		Phone = vStructure.Телефон;
//	EndIf;
//	If IsBlankString(EMail) Тогда
//		EMail = vStructure.Email;
//	EndIf;
//	If vStructure.Клиент <> Неопределено Тогда
//		If AccommodationTypesTable.Count() > 0 Тогда
//			vFirstRow = AccommodationTypesTable.Get(0);
//		Else
//			#If НЕ WebClient Тогда
//				Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 20, NStr("en='Calculating...';ru='Расчёт...';de='Errechnung...'"), PictureLib.LongOperation); 	
//			#EndIf
//			
//			If CheckFields() Тогда
//				#If НЕ WebClient Тогда
//					Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 40, NStr("en='Calculating...';ru='Расчёт...';de='Errechnung...'"), PictureLib.LongOperation); 
//				#EndIf
//				GetPrice();
//				#If НЕ WebClient Тогда
//					Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 70, NStr("en='Calculating...';ru='Расчёт...';de='Errechnung...'"), PictureLib.LongOperation); 
//				#EndIf
//			EndIf;
//			#If НЕ WebClient Тогда
//				Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 100, NStr("en='Calculating...';ru='Расчёт...';de='Errechnung...'"), PictureLib.LongOperation); 
//			#EndIf
//			If AccommodationTypesTable.Count() > 0 Тогда
//				vFirstRow = AccommodationTypesTable.Get(0);
//			EndIf;
//		EndIf;
//		If ЗначениеЗаполнено(vFirstRow.GuestRef) Тогда
//			If НЕ ChangeClientObject(vFirstRow.GuestRef, vFirstRow.GuestName, vFirstRow.ДатаРождения, 0) Тогда
//				Message(NStr("en='Failed to write object!';ru='Не удалось записать объект!';de='Das Objekt konnte nicht geschrieben werden!'"));
//			EndIf;
//		Else
//			vFirstRow.GuestRef = vStructure.Клиент;
//			vFirstRow.GuestName = vStructure.ClientFullName;
//			vFirstRow.ДатаРождения = vStructure.ДатаРождения;
//		EndIf;
//	EndIf;
//КонецПроцедуры //EMailOnChange
//
////-----------------------------------------------------------------------------
//&НаКлиенте
//Процедура Clear(pCommand)
//	#If WebClient Тогда
//		SkipOnActivateAreaFromCalculate = 2;
//	#EndIf
//	AccommodationTypesTable.Clear();
//	Items.AccommodationTypesTablePrice.FooterText = "";
//	EMail = "";
//	Phone = "";
//	BuildReport();
//КонецПроцедуры //Clear
//
////-----------------------------------------------------------------------------
//&НаКлиенте
//Процедура NewGroup(pCommand)
//	If CreateGuestGroup() Тогда
//		vNewGroupParams = GetParameters();
//		vFrm = ПолучитьФорму("Catalog.ГруппыГостей.Form.tcItemForm", New Structure("Key", GuestGroup), ЭтаФорма);
//		vFrm.CurrentItem = vFrm.Items.GroupGuests;
//		vFrm.Object.CheckInDate = vNewGroupParams.CheckInDate;
//		vFrm.Object.ДатаВыезда = vNewGroupParams.ДатаВыезда;
//		vFrm.Object.Продолжительность = vNewGroupParams.Продолжительность;
//		If AccommodationTypesTable.Count() > 0 Тогда
//			If ЗначениеЗаполнено(AccommodationTypesTable.Get(0).GuestRef) Тогда
//				vFrm.Object.Клиент = AccommodationTypesTable.Get(0).GuestRef;
//			ElsIf ЗначениеЗаполнено(AccommodationTypesTable.Get(0).GuestName) Тогда
//				vClientRef = Неопределено;
//				If НЕ ChangeClientObject(vClientRef, AccommodationTypesTable.Get(0).GuestName, AccommodationTypesTable.Get(0).ДатаРождения, 0) Тогда
//					Message(NStr("en='Failed to write object!';ru='Не удалось записать объект!';de='Das Objekt konnte nicht geschrieben werden!'"));
//				EndIf;
//				vFrm.Object.Клиент = vClientRef;
//			EndIf;
//		EndIf;
//		vFrm.Open();
//	Else
//		Message(NStr("en='Гостиница is empty';ru='Отель не заполнен';de='Das Гостиница ist nicht ausgefüllt'"));
//	EndIf;
//КонецПроцедуры //NewGroup
//
////-----------------------------------------------------------------------------
//&НаКлиенте
//Процедура NumberOfDaysOnChange(pItem)
//	NumberOfDaysOnChangeAtServer();
//	// Change period title
//	vIndex = Month(DateFrom) - Month(CurrentDate());
//	If vIndex < 0 Тогда
//		vIndex = vIndex + 12;
//	EndIf;
//	vIndex = vIndex + 1;
//	vDecorationName = "Decoration" + String(vIndex);
//	Items[vDecorationName].Title = NStr("en='Period on screen: '; ru='Период на экране: '; de='Zeitraum auf dem Bildschirm: '") + Format(DateFrom, "DF=dd.MM.yyyy") + " - " + Format(DateFrom + (NumberOfDays - 1)*24*3600, "DF=dd.MM.yyyy");
//КонецПроцедуры //NumberOfDaysOnChange
//
////-----------------------------------------------------------------------------
//&НаКлиенте
//Процедура DateFromOnChange(pItem)
//	NumberOfDaysOnChangeAtServer();
//	// Change monthes page
//	PeriodFromChangeMode = True;
//	vIndex = Month(DateFrom) - Month(CurrentDate());
//	If vIndex < 0 Тогда
//		vIndex = vIndex + 12;
//	EndIf;
//	vIndex = vIndex + 1;
//	Items.GroupMonths.CurrentPage = Items.GroupMonths.ChildItems.Get(vIndex);
//	vDecorationName = "Decoration" + String(vIndex);
//	Items[vDecorationName].Title = NStr("en='Period on screen: '; ru='Период на экране: '; de='Zeitraum auf dem Bildschirm: '") + Format(DateFrom, "DF=dd.MM.yyyy") + " - " + Format(DateFrom + (NumberOfDays - 1)*24*3600, "DF=dd.MM.yyyy");
//	PeriodFromChangeMode = False;
//КонецПроцедуры //DateFromOnChange
//
////-----------------------------------------------------------------------------
//&НаКлиенте
//Процедура AccommodationTypesTableSelection(pItem, pSelectedRow, pField, pStandardProcessing)
//	If SkipOnActivateCell Тогда
//		SkipOnActivateCell = False;
//		Return;
//	EndIf;
//	If pField.Name = "AccommodationTypesTableAccommodationType" Or pField.Name = "AccommodationTypesTableIcon" Тогда
//		If pItem.CurrentData <> Неопределено Тогда
//			If pItem.CurrentData.RowIndex = 0 Тогда
//				FillAccommodationTypesChoiceList();
//				LastRowIndex = 0;
//			Else
//				If LastRowIndex = 0 Тогда
//					FillAccommodationTypesChoiceList(False);
//					LastRowIndex = pItem.CurrentData.RowIndex;
//				EndIf;
//			EndIf;
//		EndIf;
//	EndIf;
//КонецПроцедуры //AccommodationTypesTableSelection
//
////-----------------------------------------------------------------------------
//&AtServer
//Function GetOccupationPercent(pHotel=Неопределено,qPeriodFrom=Неопределено,qPeriodTo=Неопределено)
//	vHotel = pHotel; 
//	If  vHotel=Неопределено Тогда 
//		vHotel = ПараметрыСеанса.ТекущаяГостиница;
//	EndIf;
//	
//	vPeriodFrom = qPeriodFrom; 
//	If  vPeriodFrom=Неопределено Тогда 
//		vPeriodFrom = BegOfDay(CurrentDate());
//	EndIf;
//
//	vPeriodTo = qPeriodTo; 
//	If  vPeriodTo=Неопределено Тогда 
//		vPeriodTo = EndOfDay(CurrentDate());
//	EndIf;
//	
//	// Run query to get ГруппаНомеров inventory
//	vQry = New Query();
//	vQry.Text = 
//	"SELECT
//	|	ОборотыПродажиНомеров.Period AS Period,
//	|	SUM(ОборотыПродажиНомеров.RoomsRentedTurnover) AS ПроданоНомеров,
//	|	SUM(RoomInventoryBalance.TotalRoomsBalance) AS ВсегоНомеров,
//	|	SUM(RoomInventoryBalance.RoomsBlockedBalance) AS ЗаблокНомеров
//	|FROM
//	|	AccumulationRegister.Продажи.Turnovers(&qPeriodFrom, &qPeriodTo, Day, Гостиница IN HIERARCHY (&qHotel)) AS ОборотыПродажиНомеров,
//	|	AccumulationRegister.ЗагрузкаНомеров.Balance(&qPeriodTo, Гостиница IN HIERARCHY (&qHotel)) AS RoomInventoryBalance
//	|
//	|GROUP BY
//	|	RoomInventoryBalance.TotalRoomsBalance,
//	|	ОборотыПродажиНомеров.Period
//	|
//	|ORDER BY
//	|	Period";
//
//	vQry.SetParameter("qPeriodFrom", vPeriodFrom);
//	vQry.SetParameter("qPeriodTo", vPeriodTo);
//	vQry.SetParameter("qHotel", vHotel);
//	vInvResult = vQry.Execute().Unload();
//	
//	Return vInvResult;
//EndFunction	
//
////-----------------------------------------------------------------------------
//&AtServer
//Процедура ShowPricesOnChangeAtServer(pShowPrices)
//	SystemSettingsStorage.Save("ShowPrices", "упрНаличиеНомеров", pShowPrices);
//	vNumberOfDays = 0;
//	If pShowPrices Тогда
//		vNumberOfDays = SystemSettingsStorage.Load("NumberOfDaysShowPrices", "упрНаличиеНомеров");
//		If vNumberOfDays = Неопределено Тогда
//			vNumberOfDays = 10;
//		EndIf;
//	Else 
//		vNumberOfDays = SystemSettingsStorage.Load("NumberOfDays", "упрНаличиеНомеров");
//		If vNumberOfDays = Неопределено Тогда
//			vNumberOfDays = 28;
//		EndIf;
//	EndIf;
//	If Число(vNumberOfDays) And vNumberOfDays <> 0 Тогда
//		NumberOfDays = vNumberOfDays;
//	EndIf;
//	If NumberOfAdults = 0 Тогда
//		NumberOfAdults = 1;
//	EndIf;	
//КонецПроцедуры //ShowPricesOnChangeAtServer
//
////-----------------------------------------------------------------------------
//&НаКлиенте
//Процедура ShowPricesOnChange(Item)
//	#If НЕ WebClient Тогда
//		Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 60, NStr("en='Refreshing...';ru='Обновление...';de='Aktualisierung…'"), PictureLib.LongOperation); 	
//	#Else
//		If ShowPrices Тогда
//			ShowPrices = False;
//		EndIf;
//		Message(NStr("en='НЕ supported in web client mode!'; ru='Не поддерживается в режиме Web-клиента!'; de='Nicht im Web-Client-Modus unterstützt!'"), MessageStatus.Attention);
//		Return;
//	#EndIf
//	
//	ShowPricesOnChangeAtServer(ShowPrices);
//	BuildReport();
//	
//	// Change period title
//	vIndex = Month(DateFrom) - Month(CurrentDate());
//	If vIndex < 0 Тогда
//		vIndex = vIndex + 12;
//	EndIf;
//	vIndex = vIndex + 1;
//	vDecorationName = "Decoration" + String(vIndex);
//	Items[vDecorationName].Title = NStr("en='Period on screen: '; ru='Период на экране: '; de='Zeitraum auf dem Bildschirm: '") + Format(DateFrom, "DF=dd.MM.yyyy") + " - " + Format(DateFrom + (NumberOfDays - 1)*24*3600, "DF=dd.MM.yyyy");
//	
//	#If НЕ WebClient Тогда
//		Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 100, NStr("en='Refreshing...';ru='Обновление...';de='Aktualisierung…'"), PictureLib.LongOperation); 
//	#EndIf
//КонецПроцедуры
//
////-----------------------------------------------------------------------------
//&НаКлиенте
//Процедура OpenOrdinaryApplicationForm(pCommand)
//	#IF ThickClientOrdinaryApplication THEN
//		vParams = GetParameters();
//		vFrm = GetCommonForm("НаличиеНомеров");
//		vFrm.SelHotel = vParams.Гостиница;
//		vFrm.SelClientType = vParams.ТипКлиента;
//		vFrm.SelRoomRate = vParams.Тариф;
//		vFrm.SelRoomQuota = vParams.КвотаНомеров;
//		vFrm.SelRoomType = vParams.ТипНомера;
//		vFrm.SelCheckInDate = vParams.CheckInDate;
//		vFrm.SelCheckOutDate = vParams.ДатаВыезда;
//		vFrm.SelDuration = vParams.Продолжительность;
//		vAccommodationTemplates = cmGetAccommodationTemplatesValidForRoomType(vParams.ТипНомера, (NumberOfAdults + NumberOfKids));
//		If vAccommodationTemplates.Count() > 0 Тогда
//			vFrm.SelAccommodationTemplate = vAccommodationTemplates.Get(0).Value;
//		EndIf;
//		If НЕ vFrm.IsOpen() Тогда
//			vFrm.WindowAppearanceMode = WindowAppearanceModeVariant.Maximized;
//		EndIf;
//		vFrm.Open();
//	#ELSE
//		Предупреждение(NStr("en='НЕ supported in thin or web client mode!'; ru='Не поддерживается в режиме тонкого и WEB клиента!'; de='Nicht in Dünnen-Client-Modus oder Web-Client-Modus unterstützt!'"));
//	#ENDIF
//КонецПроцедуры //OpenOrdinaryApplicationForm
//
////-----------------------------------------------------------------------------
//&НаКлиенте
//Процедура GroupMonthsOnCurrentPageChange(pItem, pCurrentPage)
//	If PeriodFromChangeMode Тогда
//		Return;
//	EndIf;
//	vPageIndex = Number(StrReplace(pCurrentPage.Name, "Page", ""));
//	// Fill period from date according to the month
//	If vPageIndex = 0 Тогда
//		DateFrom = BegOfDay(CurrentDate());
//	Else
//		DateFrom = AddMonth(BegOfMonth(CurrentDate()), vPageIndex - 1);
//	EndIf;
//	vDecorationName = "Decoration" + String(vPageIndex);
//	Items[vDecorationName].Title = NStr("en='Period on screen: '; ru='Период на экране: '; de='Zeitraum auf dem Bildschirm: '") + Format(DateFrom, "DF=dd.MM.yyyy") + " - " + Format(DateFrom + (NumberOfDays - 1)*24*3600, "DF=dd.MM.yyyy");
//	// Build report	
//	BuildReport();
//	// Reset variable
//	PeriodFromChangeMode = False;
//КонецПроцедуры
//
////-----------------------------------------------------------------------------
//&AtServer
//Function CalculateDurationAtServer(pRoomRate, pCheckInDate, pCheckOutDate)
//	Return cmCalculateDuration(pRoomRate, pCheckInDate, pCheckOutDate);
//EndFunction //CalculateDurationAtServer
//
////-----------------------------------------------------------------------------
//&НаКлиенте
//Процедура CheckOutDateOnChange(pItem)
//	#If WebClient Тогда
//		SkipOnActivateAreaFromCalculate = 2;
//	#EndIf
//	Duration = CalculateDurationAtServer(Тариф, CheckInDate, CheckOutDate);
//КонецПроцедуры //CheckOutDateOnChange
//
////-----------------------------------------------------------------------------
//&НаКлиенте
//Процедура CheckInDateOnChange(pItem)
//	#If WebClient Тогда
//		SkipOnActivateAreaFromCalculate = 2;
//	#EndIf
//	Duration = CalculateDurationAtServer(Тариф, CheckInDate, CheckOutDate);
//КонецПроцедуры //CheckInDateOnChange
//
////-----------------------------------------------------------------------------
//&AtServer
//Function CalculateCheckOutDateAtServer(pRoomRate, pCheckInDate, pDuration)
//	Return cmCalculateCheckOutDate(pRoomRate, pCheckInDate, pDuration);
//EndFunction //CalculateCheckOutDateAtServer
//
////-----------------------------------------------------------------------------
//&НаКлиенте
//Процедура DurationOnChange(pItem)
//	#If WebClient Тогда
//		SkipOnActivateAreaFromCalculate = 2;
//	#EndIf
//	CheckOutDate = CalculateCheckOutDateAtServer(Тариф, CheckInDate, Duration);
//КонецПроцедуры //DurationOnChange
