//Перем ProgressForm;
//
////-----------------------------------------------------------------------------
//Function GetPeriodHash(pHotel, pRoomType, pDate)
//	Return pHotel.Code + pRoomType.Code + Year(pDate) + Format(DayOfYear(pDate), "ND=3; NLZ=");
//EndFunction //GetPeriodHash
//
////-----------------------------------------------------------------------------
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
//Function GetRoomsQueryResource(pQry, pShowReportsInBeds, pRoomType = Неопределено)
//	vVacant = 0;
//	If pRoomType = Неопределено Тогда
//		If pShowReportsInBeds Тогда
//			vVacant = pQry.Total("BedsVacant");
//		Else
//			vVacant = pQry.Total("RoomsVacant");
//		EndIf;
//	Else
//		If pRoomType.IsFolder Тогда
//			For Each vRow In pQry Do
//				If vRow.ТипНомера.BelongsToItem(pRoomType) Тогда
//					If pShowReportsInBeds Тогда
//						vVacant = vVacant + vRow.BedsVacant;
//					Else
//						vVacant = vVacant + vRow.RoomsVacant;
//					EndIf;
//				EndIf;
//			EndDo;
//		Else
//			For Each vRow In pQry Do
//				If pRoomType = vRow.ТипНомера Тогда
//					If pShowReportsInBeds Тогда
//						vVacant = vVacant + vRow.BedsVacant;
//					Else
//						vVacant = vVacant + vRow.RoomsVacant;
//					EndIf;
//					Break;
//				EndIf;
//			EndDo;
//		EndIf;
//	EndIf;
//	Return vVacant;
//EndFunction //GetRoomsQueryResource
//
////-----------------------------------------------------------------------------
//Процедура pmGenerate(pSpreadsheet, pHeader) Экспорт
//	// Initialize number of days to output and period
//	NumberOfDays = ?(NumberOfDays <= 0, 28, NumberOfDays);
//	vNumberOfDays = NumberOfDays;
//	vDateFrom = BegOfDay(DateFrom);
//	vCurrentDateTime = ?(vDateFrom = BegOfDay(CurrentDate()), CurrentDate(), vDateFrom);
//	vCurrentDate = BegOfDay(vCurrentDateTime);
//	vDateTimeFrom = ?(vDateFrom = vCurrentDate, vCurrentDateTime, vDateFrom);
//	vDateTo = vDateFrom + 24*3600*(vNumberOfDays - 1);
//	vDateTimeTo = EndOfDay(vDateTo);
//	vShowReportsInBeds = ShowInBeds;
//	
//	// Show progress bar
//	ProgressForm = GetCommonForm("Индикатор");
//	ProgressForm.Open();
//	ProgressForm.Value = 0;
//	ProgressForm.MaxValue = 0;
//	If vShowReportsInBeds Тогда
//		ProgressForm.ActionRemarks = NStr("en='Vacant beds';ru='Свободные места';de='Freie Betten'");
//	Else
//		ProgressForm.ActionRemarks = NStr("en='Vacant rooms';ru='Свободные номера';de='Freie Zimmer'");
//	EndIf;
//	ProgressForm.ValueRemarks = NStr("en='Run query';ru='Выполнение запроса';de='Ausführung einer Nachfrage'");
//	
//	// Get active events
//	//vEvents = cmGetEvents(vDateTimeFrom, vDateTimeTo, Гостиница);
//	
//	// Build and run query with ГруппаНомеров inventory balances
//	vQry = New Query();
//	vQry.Text = 
//	"SELECT
//	|	RoomInventoryBalance.Period AS Period,
//	|	RoomInventoryBalance.Гостиница AS Гостиница,
//	|	RoomInventoryBalance.ТипНомера AS ТипНомера,
//	|	RoomInventoryBalance.CounterClosingBalance AS CounterClosingBalance,
//	|	RoomInventoryBalance.RoomsVacantClosingBalance AS RoomsVacant,
//	|	RoomInventoryBalance.BedsVacantClosingBalance AS BedsVacant,
//	|	RoomInventoryBalance.Гостиница.ПорядокСортировки AS HotelSortCode,
//	|	RoomInventoryBalance.ТипНомера.ПорядокСортировки AS RoomTypeSortCode
//	|FROM
//	|	РегистрНакопления.ЗагрузкаНомеров.BalanceAndTurnovers(
//	|			&qDateTimeFrom,
//	|			&qDateTimeTo,
//	|			Hour,
//	|			RegisterRecordsAndPeriodBoundaries,
//	|			&qHotelIsEmpty
//	|				OR NOT &qHotelIsEmpty
//	|					AND Гостиница IN HIERARCHY (&qHotel)) AS RoomInventoryBalance
//	|
//	|ORDER BY
//	|	HotelSortCode,
//	|	RoomTypeSortCode,
//	|	Period
//	|TOTALS
//	|	SUM(CounterClosingBalance),
//	|	SUM(RoomsVacant),
//	|	SUM(BedsVacant)
//	|BY
//	|	Гостиница HIERARCHY,
//	|	ТипНомера HIERARCHY,
//	|	Period PERIODS(HOUR, &qDateTimeFrom, &qDateTimeTo)";
//	vQry.SetParameter("qHotel", Гостиница);
//	vQry.SetParameter("qHotelIsEmpty", НЕ ЗначениеЗаполнено(Гостиница));
//	vQry.SetParameter("qDateTimeFrom", vDateTimeFrom);
//	vQry.SetParameter("qDateTimeTo", vDateTimeTo);
//	vQryRes = vQry.Execute();
//	
//	// Fill end of day balances and periods
//	vPeriods = New СписокЗначений();
//	vEndOfDayBalances = New Map();
//	vQryHotels = vQryRes.Choose(QueryResultIteration.ByGroups, "Гостиница");
//	While vQryHotels.Next() Do
//		// Save all periods where vacant resource is changed
//		vLastVacant = Неопределено;
//		vQryHours = vQryHotels.Choose(QueryResultIteration.ByGroups, "Period", "ALL");
//		While vQryHours.Next() Do
//			vPeriod = vQryHours.Period;
//			If (vPeriod < vDateTimeFrom) Or (vPeriod > vDateTimeTo) Тогда
//				Continue;
//			EndIf;
//			vBegOfDay = BegOfDay(vPeriod);
//			vVacant = GetQueryResource(vQryHours, vShowReportsInBeds, vLastVacant);
//			If vLastVacant = Неопределено Or 
//			   vLastVacant <> vVacant Or
//			   vPeriod = (vBegOfDay + 23*3600) Тогда
//				vLastVacant = vVacant;
//				If vPeriods.FindByValue(vPeriod) = Неопределено Тогда
//					vPeriods.Add(vPeriod); 
//				EndIf;
//			EndIf;
//		EndDo;
//		// Process ГруппаНомеров types
//		vQryRoomTypes = vQryHotels.Choose(QueryResultIteration.ByGroups, "ТипНомера");
//		While vQryRoomTypes.Next() Do
//			// Save all periods where vacant resource is changed and save periods where last change per day took place
//			vLastVacant = Неопределено;
//			vQryHours = vQryRoomTypes.Choose(QueryResultIteration.ByGroups, "Period", "ALL");
//			While vQryHours.Next() Do
//				vPeriod = vQryHours.Period;
//				If (vPeriod < vDateTimeFrom) Or (vPeriod > vDateTimeTo) Тогда
//					Continue;
//				EndIf;
//				vBegOfDay = BegOfDay(vPeriod);
//				vVacant = GetQueryResource(vQryHours, vShowReportsInBeds, vLastVacant);
//				If vLastVacant = Неопределено Or 
//				   vLastVacant <> vVacant Or
//				   vPeriod = (vBegOfDay + 23*3600) Тогда
//					vLastVacant = vVacant;
//					If vPeriods.FindByValue(vPeriod) = Неопределено Тогда
//						vPeriods.Add(vPeriod); 
//					EndIf;
//				EndIf;
//				If vPeriod = (vBegOfDay + 23*3600) Тогда
//					vKey = GetPeriodHash(vQryHotels.Гостиница, vQryRoomTypes.ТипНомера, vBegOfDay);
//					If vShowReportsInBeds Тогда
//						vEndOfDayBalances.Вставить(vKey, vQryHours.BedsVacant);
//					Else
//						vEndOfDayBalances.Вставить(vKey, vQryHours.RoomsVacant);
//					EndIf;
//				EndIf;
//			EndDo;
//		EndDo;
//	EndDo;
//	// Sort periods chronologically
//	vPeriods.SortByValue();	
//	
//	// Fill table of first periods per day
//	vFirstPeriodsPerDays = New ValueTable();
//	vFirstPeriodsPerDays.Columns.Add("BegOfDay", cmGetDateTimeTypeDescription());
//	vFirstPeriodsPerDays.Columns.Add("Period", cmGetDateTimeTypeDescription());
//	vHourOnTime = Hour(OnTime);
//	For Each vPeriodItem In vPeriods Do
//		vPeriod = vPeriodItem.Value;
//		vBegOfDay = BegOfDay(vPeriod);
//		vRow = vFirstPeriodsPerDays.Find(vBegOfDay, "BegOfDay");
//		If vHourOnTime <> 23 Тогда
//			If Hour(vPeriod) <= vHourOnTime Тогда
//				If vRow = Неопределено Тогда
//					vRow = vFirstPeriodsPerDays.Add();
//					vRow.BegOfDay = vBegOfDay;
//				EndIf;
//				vRow.Period = vPeriod;
//			Else
//				If vRow = Неопределено Тогда
//					vRow = vFirstPeriodsPerDays.Add();
//					vRow.BegOfDay = vBegOfDay;
//					vRow.Period = vPeriod;
//				EndIf;
//			EndIf;
//		Else
//			If vRow = Неопределено Тогда
//				vRow = vFirstPeriodsPerDays.Add();
//				vRow.BegOfDay = vBegOfDay;
//				vRow.Period = vPeriod;
//			EndIf;
//		EndIf;
//	EndDo;
//	
//	// Show progress status
//	ProgressForm.ValueRemarks  = NStr("en='Draw header';ru='Построение заголовка отчета';de='Konstruktion der Überschrift des Berichts'");
//
//	// Draw header
//	vSpreadsheet = pSpreadsheet;
//	vSpreadsheet.Clear();
//	vSpreadsheet.ShowGroups = True;
//	
//	vTemplate = GetTemplate("Report");
//	vArea = vTemplate.GetArea("Header|NamesColumn");
//	If vShowReportsInBeds Тогда
//		pHeader.Caption = NStr("en='Vacant beds &on:';ru='Свободные места &на:';de='Freie Betten &für:'");
//	Else
//		pHeader.Caption = NStr("en='Vacant rooms &on:';ru='Свободные номера &на:';de='Freie Zimmer &für:'");
//	EndIf;
//	vSpreadsheet.Put(vArea);
//
//	vEndOfPrevDay = False;
//	vDayGroup = False;
//	vLastDate = Неопределено;
//	For Each vPeriodItem In vPeriods Do
//		vPeriod = vPeriodItem.Value;
//		vCurDate = BegOfDay(vPeriod);
//		vCurHour = Hour(vPeriod);
//		If vLastDate = Неопределено Or vCurDate <> vLastDate Тогда
//			vLastDate = vCurDate;
//			vEndOfPrevDay = True;
//		EndIf;
//		mDay = Day(vCurDate);
//		mDayOfWeek = cmGetDayOfWeekName(WeekDay(vCurDate), True);
//		mMonth = Format(vPeriod, "DF=MMMM");
//		vGroupName = Format(vCurDate, NStr("ru = 'L=ru; DLF=DD'; en = 'L=en; DLF=DD'"));
//		
//		// Check should we print this period
//		vFirstHourPerDay = 23;
//		If vHourOnTime <> 23 Тогда
//			vRow = vFirstPeriodsPerDays.Find(vCurDate, "BegOfDay");
//			If vRow <> Неопределено Тогда
//				If vRow.Period > vPeriod Тогда
//					Continue;
//				EndIf;
//			Else
//				Continue;
//			EndIf;
//			vFirstHourPerDay = Hour(vRow.Period);
//		EndIf;
//		
//		vCloseColumnGroup = False;
//		If vEndOfPrevDay Тогда
//			vEndOfPrevDay = False;
//			If НЕ vDayGroup Тогда
//				If vHourOnTime = 23 Тогда
//					If vCurHour <> 23 Тогда
//						vSpreadsheet.StartColumnGroup(vGroupName, False);
//						vDayGroup = True;
//					EndIf;
//				Else
//					If vCurHour > vHourOnTime And vCurHour > vFirstHourPerDay Тогда
//						vSpreadsheet.StartColumnGroup(vGroupName, False);
//						vDayGroup = True;
//					EndIf;
//				EndIf;
//			EndIf;
//			If vCurDate = BegOfMonth(vCurDate) Or vCurDate = vDateFrom Тогда
//				If vCurHour = 23 Тогда
//					vArea = vTemplate.GetArea("Header|LastFirstDayOfMonth");
//				Else
//					vArea = vTemplate.GetArea("Header|FirstDayOfMonth");
//				EndIf;
//				vArea.Parameters.mMonth = mMonth;
//			ElsIf WeekDay(vCurDate) = 1 Тогда
//				If vCurHour = 23 Тогда
//					vArea = vTemplate.GetArea("Header|LastFirstDayOfWeek");
//				Else
//					vArea = vTemplate.GetArea("Header|FirstDayOfWeek");
//				EndIf;
//			Else
//				If vCurHour = 23 Тогда
//					vArea = vTemplate.GetArea("Header|LastFirstHourOfDay");
//				Else
//					vArea = vTemplate.GetArea("Header|FirstHourOfDay");
//				EndIf;
//			EndIf;
//			vArea.Parameters.mDay = mDay;
//			vArea.Parameters.mDayOfWeek = mDayOfWeek;
//		Else
//			If vCurHour = 23 Тогда
//				If vHourOnTime <> 23 Тогда
//					If НЕ vDayGroup And vFirstHourPerDay <> 23 Тогда
//						vSpreadsheet.StartColumnGroup(vGroupName, False);
//						vDayGroup = True;
//					EndIf;
//					vCloseColumnGroup = True;
//				Else
//					If vDayGroup Тогда
//						vSpreadsheet.EndColumnGroup();
//						vDayGroup = False;
//					EndIf;
//				EndIf;
//				If vCurDate = BegOfDay(EndOfMonth(vCurDate)) Тогда
//					vArea = vTemplate.GetArea("Header|LastDayOfMonth");
//				ElsIf WeekDay(vCurDate) = 7 Тогда
//					vArea = vTemplate.GetArea("Header|LastDayOfWeek");
//				Else
//					vArea = vTemplate.GetArea("Header|LastHourOfDay");
//				EndIf;
//			Else
//				If НЕ vDayGroup Тогда
//					If vHourOnTime <> 23 Тогда
//						If vCurHour > vHourOnTime And vCurHour > vFirstHourPerDay Тогда
//							vSpreadsheet.StartColumnGroup(vGroupName, False);
//							vDayGroup = True;
//						EndIf;
//					EndIf;
//				EndIf;
//				vArea = vTemplate.GetArea("Header|Day");
//			EndIf;
//		EndIf;
//		vArea.Parameters.mHour = ?(vCurHour=23, "", Format(vCurHour+1, "ND=2; NZ=; NLZ=")+":00");
//		vSpreadsheet.Join(vArea);
//		If vCloseColumnGroup Тогда
//			If vDayGroup Тогда
//				vSpreadsheet.EndColumnGroup();
//				vDayGroup = False;
//			EndIf;
//		EndIf;
//	EndDo;
//	
//	// Show progress status
//	ProgressForm.ValueRemarks = NStr("en='Draw report data. Events.';ru='Вывод данных. Мероприятия.';de='Output von Daten. Veranstaltungen.'");
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
//	//		vCurHour = Hour(vPeriod);
//	//		If vLastDate = Неопределено Or vCurDate <> vLastDate Тогда
//	//			vLastDate = vCurDate;
//	//			vEndOfPrevDay = True;
//	//		EndIf;
//	//		
//	//		// Check should we print this period
//	//		vFirstHourPerDay = 23;
//	//		If vHourOnTime <> 23 Тогда
//	//			vRow = vFirstPeriodsPerDays.Find(vCurDate, "BegOfDay");
//	//			If vRow <> Неопределено Тогда
//	//				If vRow.Period > vPeriod Тогда
//	//					Continue;
//	//				EndIf;
//	//			Else
//	//				Continue;
//	//			EndIf;
//	//			vFirstHourPerDay = Hour(vRow.Period);
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
//	//				If vCurHour = 23 Тогда
//	//					vArea = vTemplate.GetArea(vAreaRowName + "|LastFirstDayOfMonth");
//	//				Else
//	//					vArea = vTemplate.GetArea(vAreaRowName + "|FirstDayOfMonth");
//	//				EndIf;
//	//			ElsIf WeekDay(vCurDate) = 1 Тогда
//	//				If vCurHour = 23 Тогда
//	//					vArea = vTemplate.GetArea(vAreaRowName + "|LastFirstDayOfWeek");
//	//				Else
//	//					vArea = vTemplate.GetArea(vAreaRowName + "|FirstDayOfWeek");
//	//				EndIf;
//	//			Else
//	//				If vCurHour = 23 Тогда
//	//					vArea = vTemplate.GetArea(vAreaRowName + "|LastFirstHourOfDay");
//	//				Else
//	//					vArea = vTemplate.GetArea(vAreaRowName + "|FirstHourOfDay");
//	//				EndIf;
//	//			EndIf;
//	//		Else
//	//			If vCurHour = 23 Тогда
//	//				If vCurDate = BegOfDay(EndOfMonth(vCurDate)) Тогда
//	//					vArea = vTemplate.GetArea(vAreaRowName + "|LastDayOfMonth");
//	//				ElsIf WeekDay(vCurDate) = 7 Тогда
//	//					vArea = vTemplate.GetArea(vAreaRowName + "|LastDayOfWeek");
//	//				Else
//	//					vArea = vTemplate.GetArea(vAreaRowName + "|LastHourOfDay");
//	//				EndIf;
//	//			Else
//	//				vArea = vTemplate.GetArea(vAreaRowName + "|Day");
//	//			EndIf;
//	//		EndIf;
//	//		If vEventsRow <> Неопределено And vAreaRowName = "EventRow" Тогда
//	//			If vThisIsFirstPeriodOfEvent Тогда
//	//				vArea.Parameters.mEventDescription = TrimAll(vEventsRow.Description);
//	//			Else
//	//				vArea.Parameters.mEventDescription = "";
//	//			EndIf;
//	//			vArea.Parameters.mEvent = vEventsRow.Ref;
//	//		ElsIf vAreaRowName = "NoEventRow" Тогда
//	//			vArea.Parameters.mEvent = Справочники.Events.EmptyRef();
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
//	//				vOutputArea.Comment.Text = Chars.LF + Chars.LF + TrimAll(Format(vEventsRow.DateFrom, "DF=dd.MM.yyyy") + " - " + Format(vEventsRow.DateTo, "DF=dd.MM.yyyy") + Chars.LF +
//	//										   TrimAll(vEventsRow.Remarks));
//	//			EndIf;
//	//		EndIf;
//	//	EndDo;
//	//EndIf;
//	//
//	// Show progress status
//	ProgressForm.ValueRemarks = NStr("en='Draw report data. Гостиница totals.';ru='Вывод данных. Итог по гостинице.';de='Output von Daten. Ergebnis nach Гостиница.'");
//	
//	// Count maximum value for progress bar
//	vNHotels = vQryRes.Choose(QueryResultIteration.ByGroups, "Гостиница").Count();
//	vNRoomTypes = vQryRes.Choose(QueryResultIteration.ByGroups, "ТипНомера").Count();
//	vNHours = 1;
//	If vQryRoomTypes <> Неопределено Тогда
//		vNHours = vQryRoomTypes.Choose(QueryResultIteration.ByGroups, "Period", "ALL").Count();
//	EndIf;
//	ProgressForm.MaxValue = vNHotels*vNRoomTypes;
//	vProgressValue = 1;
//	
//	// Build report form
//	vQryHotels = vQryRes.Choose(QueryResultIteration.ByGroups, "Гостиница");
//	While vQryHotels.Next() Do
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
//			vPeriod = vQryHours.Period;
//			If (vPeriod < vDateTimeFrom) Or (vPeriod > vDateTimeTo) Тогда
//				Continue;
//			EndIf;
//			If vPeriods.FindByValue(vPeriod) = Неопределено Тогда
//				Continue;
//			EndIf;
//			
//			vCurDate = BegOfDay(vPeriod);
//			vCurHour = Hour(vPeriod);
//			If vLastDate = Неопределено Or vCurDate <> vLastDate Тогда
//				vLastDate = vCurDate;
//				vEndOfPrevDay = True;
//			EndIf;
//			
//			// Check should we print this period
//			If vHourOnTime <> 23 Тогда
//				vRow = vFirstPeriodsPerDays.Find(vCurDate, "BegOfDay");
//				If vRow <> Неопределено Тогда
//					If vRow.Period > vPeriod Тогда
//						Continue;
//					EndIf;
//				Else
//					Continue;
//				EndIf;
//			EndIf;
//			
//			// Get necessary report template area
//			If vEndOfPrevDay Тогда
//				vEndOfPrevDay = False;
//				If vCurDate = BegOfMonth(vCurDate) Or vCurDate = vDateFrom Тогда
//					If vCurHour = 23 Тогда
//						vArea = vTemplate.GetArea("HotelRow|LastFirstDayOfMonth");
//					Else
//						vArea = vTemplate.GetArea("HotelRow|FirstDayOfMonth");
//					EndIf;
//				ElsIf WeekDay(vCurDate) = 1 Тогда
//					If vCurHour = 23 Тогда
//						vArea = vTemplate.GetArea("HotelRow|LastFirstDayOfWeek");
//					Else
//						vArea = vTemplate.GetArea("HotelRow|FirstDayOfWeek");
//					EndIf;
//				Else
//					If vCurHour = 23 Тогда
//						vArea = vTemplate.GetArea("HotelRow|LastFirstHourOfDay");
//					Else
//						vArea = vTemplate.GetArea("HotelRow|FirstHourOfDay");
//					EndIf;
//				EndIf;
//			Else
//				If vCurHour = 23 Тогда
//					If vCurDate = BegOfDay(EndOfMonth(vCurDate)) Тогда
//						vArea = vTemplate.GetArea("HotelRow|LastDayOfMonth");
//					ElsIf WeekDay(vCurDate) = 7 Тогда
//						vArea = vTemplate.GetArea("HotelRow|LastDayOfWeek");
//					Else
//						vArea = vTemplate.GetArea("HotelRow|LastHourOfDay");
//					EndIf;
//				Else
//					vArea = vTemplate.GetArea("HotelRow|Day");
//				EndIf;
//			EndIf;
//			
//			// Fill parameters and join area
//			vArea.Parameters.mVacant = GetQueryResource(vQryHours, vShowReportsInBeds, vLastVacant);
//			vArea.Parameters.mDetails = New Structure("Гостиница, ТипНомера, ПериодПо", 
//			                                           vQryHotels.Гостиница, 
//			                                           Справочники.ТипыНомеров.EmptyRef(), 
//			                                           vPeriod);
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
//		vQryRoomTypes = vQryHotels.Choose(QueryResultIteration.ByGroups, "ТипНомера");
//		While vQryRoomTypes.Next() Do
//			// Show progress status
//			ProgressForm.ValueRemarks  = NStr("ru = 'Вывод данных по типу номера: '; en = 'Draw report data. ГруппаНомеров type: '") + TrimR(vQryRoomTypes.ТипНомера.Description);
//			ProgressForm.Value = vProgressValue;
//			vProgressValue = vProgressValue + 1;
//			
//			// Show ГруппаНомеров type
//			vAreaCol = "RoomTypeRow";
//			If vQryRoomTypes.ТипНомера.IsFolder Тогда
//				vAreaCol = "RoomTypeFolderRow";
//			EndIf;
//			vArea = vTemplate.GetArea(vAreaCol + "|NamesColumn");
//			If vQryRoomTypes.ТипНомера.IsFolder Тогда
//				vArea.Parameters.mRoomType = cmGetIndent(vQryRoomTypes.ТипНомера, +1) + TrimR(vQryRoomTypes.ТипНомера.Description);
//			Else
//				vArea.Parameters.mRoomType = cmGetIndent(vQryRoomTypes.ТипНомера, +1) + TrimR(vQryRoomTypes.ТипНомера.Code);
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
//				vPeriod = vQryHours.Period;
//				If (vPeriod < vDateTimeFrom) Or (vPeriod > vDateTimeTo) Тогда
//					Continue;
//				EndIf;
//				If vPeriods.FindByValue(vPeriod) = Неопределено Тогда
//					Continue;
//				EndIf;
//				
//				vCurDate = BegOfDay(vPeriod);
//				vCurHour = Hour(vPeriod);
//				If vLastDate = Неопределено Or vCurDate <> vLastDate Тогда
//					vLastDate = vCurDate;
//					vEndOfPrevDay = True;
//				EndIf;
//				
//				// Check should we print this period
//				If vHourOnTime <> 23 Тогда
//					vRow = vFirstPeriodsPerDays.Find(vCurDate, "BegOfDay");
//					If vRow <> Неопределено Тогда
//						If vRow.Period > vPeriod Тогда
//							Continue;
//						EndIf;
//					Else
//						Continue;
//					EndIf;
//				EndIf;
//				
//				// Check ГруппаНомеров type stop sale
//				vStopSaleRemarks = "";
//				vAreaCol = "RoomTypeRow";
//				If vQryRoomTypes.ТипНомера.IsFolder Тогда
//					vAreaCol = "RoomTypeFolderRow";
//				Else
//					If vQryRoomTypes.ТипНомера.СнятСПродажи Тогда
//						If cmIsStopSalePeriod(vQryRoomTypes.ТипНомера, vPeriod, vPeriod, vStopSaleRemarks) Тогда
//							vAreaCol = "RoomTypeStopSaleRow";
//						EndIf;
//					EndIf;
//				EndIf;
//				
//				// Get necessary report template area
//				If vEndOfPrevDay Тогда
//					vEndOfPrevDay = False;
//					If vCurDate = BegOfMonth(vCurDate) Or vCurDate = vDateFrom Тогда
//						If vCurHour = 23 Тогда
//							vArea = vTemplate.GetArea(vAreaCol + "|LastFirstDayOfMonth");
//						Else
//							vArea = vTemplate.GetArea(vAreaCol + "|FirstDayOfMonth");
//						EndIf;
//					ElsIf WeekDay(vCurDate) = 1 Тогда
//						If vCurHour = 23 Тогда
//							vArea = vTemplate.GetArea(vAreaCol + "|LastFirstDayOfWeek");
//						Else
//							vArea = vTemplate.GetArea(vAreaCol + "|FirstDayOfWeek");
//						EndIf;
//					Else
//						If vCurHour = 23 Тогда
//							vArea = vTemplate.GetArea(vAreaCol + "|LastFirstHourOfDay");
//						Else
//							vArea = vTemplate.GetArea(vAreaCol + "|FirstHourOfDay");
//						EndIf;
//					EndIf;
//					// Reset comment on first period of a day
//					vCommentHour = 0;
//				Else
//					If vCurHour = 23 Тогда
//						If vCurDate = BegOfDay(EndOfMonth(vCurDate)) Тогда
//							vArea = vTemplate.GetArea(vAreaCol + "|LastDayOfMonth");
//						ElsIf WeekDay(vCurDate) = 7 Тогда
//							vArea = vTemplate.GetArea(vAreaCol + "|LastDayOfWeek");
//						Else
//							vArea = vTemplate.GetArea(vAreaCol + "|LastHourOfDay");
//						EndIf;
//					Else
//						vArea = vTemplate.GetArea(vAreaCol + "|Day");
//					EndIf;
//				EndIf;
//				//Set weekend backgroud color
//				If WeekDay(vCurDate) = 7 OR WeekDay(vCurDate) = 6 Тогда
//					vArea = vTemplate.GetArea(vAreaCol + "|LastDayOfWeek");
//				EndIf;
//
//				// Set area parameters
//				vVacant = GetQueryResource(vQryHours, vShowReportsInBeds, vLastVacant);
//				vArea.Parameters.mVacant = vVacant;
//				vArea.Parameters.mDetails = New Structure("Гостиница, ТипНомера, ПериодПо", 
//				                                           vQryHotels.Гостиница, 
//				                                           vQryRoomTypes.ТипНомера, 
//				                                           vPeriod);
//				If vArea.Parameters.mVacant < 0 Тогда
//					vCell = vArea.Area(1,1,1,1);
//					vCell.TextColor = WebColors.Red;
//				EndIf;
//				
//				// Check should we add comment with time when vacant rooms became available
//				If vCurHour >= 11 And vCurHour <= 23 Тогда
//					vKey = GetPeriodHash(vQryHotels.Гостиница, vQryRoomTypes.ТипНомера, vCurDate);
//					vEndOfDayBalance = vEndOfDayBalances.Get(vKey);
//					If vEndOfDayBalance <> Неопределено Тогда
//						If vVacant < vEndOfDayBalance Тогда
//							vCommentHour = -1;
//						ElsIf vVacant = vEndOfDayBalance Тогда
//							If vCurHour > 12 Тогда
//								If vCommentHour = -1 Тогда
//									vCommentHour = vCurHour;
//								EndIf;
//							EndIf;
//						EndIf;
//					EndIf;
//				EndIf;
//				If vCurHour = 23 Тогда
//					If vCommentHour > 0 Тогда
//						vComment = Format(vCommentHour+1, "ND=2; NLZ=") + ":00";
//						vArea.Area("T").Comment.Text = vComment;
//					EndIf;
//				EndIf;
//				If НЕ IsBlankString(vStopSaleRemarks) Тогда
//					vArea.Area("T").Comment.Text = TrimAll(vArea.Area("T").Comment.Text) + ?(IsBlankString(vArea.Area("T").Comment.Text), "", Chars.LF) + vStopSaleRemarks;
//				EndIf;
//				
//				// Join template area to the report
//				vSpreadsheet.Join(vArea);
//				
//				vLastVacant = vVacant;
//			EndDo;
//		EndDo;
//	EndDo;
//	If ProgressForm.IsOpen() Тогда
//		ProgressForm.Close();
//	EndIf;
//	
//	// Setup default attributes
//	cmSetDefaultPrintFormSettings(vSpreadsheet, PageOrientation.Landscape);
//	
//	// Set report protection
//	cmSetSpreadsheetProtection(vSpreadsheet);
//	
//	// Set report header
//	cmApplyReportHeader(vSpreadsheet);
//	// Add configuration name to the right report header
//	pSpreadsheet.Header.LeftText = ?(ЗначениеЗаполнено(ПараметрыСеанса.ТекущаяГостиница), 
//									 ПараметрыСеанса.ТекущаяГостиница.GetObject().pmGetHotelPrintName(ПараметрыСеанса.ТекЛокализация), "") + " - " + 
//									TrimAll(ПараметрыСеанса.ПредставлениеКонфигурации);
//	vSpreadsheet.Header.RightText = TrimAll(ПараметрыСеанса.ТекПользователь) + " - " + Format(CurrentDate(), "DF='dd.MM.yyyy HH:mm'");
//	// Set footer
//	cmApplyReportFooter(vSpreadsheet);
//	
//	// Fix report header and ГруппаНомеров type codes
//	vSpreadsheet.FixedTop = 4;
//	//vSpreadsheet.FixedLeft = 2;
//КонецПроцедуры //pmGenerate
//
////-----------------------------------------------------------------------------
//Процедура pmGenerateByDuration(pSpreadsheet, pHeader) Экспорт
//	// Initialize number of days to output and period
//	NumberOfDays = ?(NumberOfDays <= 0, 28, NumberOfDays);
//	vNumberOfDays = NumberOfDays;
//	vDateFrom = BegOfDay(DateFrom);
//	vCurrentDate = BegOfDay(CurrentDate());
//	vCurrentDateTime = ?(vDateFrom = BegOfDay(CurrentDate()), CurrentDate(), vDateFrom);
//	vDateTimeFrom = ?(vDateFrom = vCurrentDate, vCurrentDateTime, vDateFrom);
//	vDateTo = vDateFrom + 24*3600*(vNumberOfDays - 1);
//	vDateTimeTo = EndOfDay(vDateTo);
//	vShowReportsInBeds = ShowInBeds;
//	
//	// Show progress bar
//	ProgressForm = GetCommonForm("Индикатор");
//	ProgressForm.Open();
//	ProgressForm.Value = 0;
//	ProgressForm.MaxValue = 0;
//	If vShowReportsInBeds Тогда
//		ProgressForm.ActionRemarks = NStr("en='Vacant beds';ru='Свободные места';de='Freie Betten'");
//	Else
//		ProgressForm.ActionRemarks = NStr("en='Vacant rooms';ru='Свободные номера';de='Freie Zimmer'");
//	EndIf;
//	ProgressForm.ValueRemarks = NStr("en='Run query';ru='Выполнение запроса';de='Ausführung einer Nachfrage'");
//	
//	// Get active events
//	//vEvents = cmGetEvents(vDateTimeFrom, vDateTimeTo, Гостиница);
//	
//	// Build and run query with ГруппаНомеров inventory balances
//	vQry = New Query();
//	vQry.Text = 
//	"SELECT
//	|	RoomInventoryBalance.Гостиница AS Гостиница,
//	|	RoomInventoryBalance.ТипНомера AS ТипНомера,
//	|	BEGINOFPERIOD(DATEADD(RoomInventoryBalance.Period, SECOND, &qShiftInSeconds), DAY) AS Period,
//	|	MIN(ISNULL(RoomInventoryBalance.CounterClosingBalance, 0)) AS CounterClosingBalance,
//	|	MIN(ISNULL(RoomInventoryBalance.RoomsVacantClosingBalance, 0)) AS RoomsVacant,
//	|	MIN(ISNULL(RoomInventoryBalance.BedsVacantClosingBalance, 0)) AS BedsVacant
//	|INTO RoomInventoryDailyBalance
//	|FROM
//	|	РегистрНакопления.ЗагрузкаНомеров.ОстаткиИОбороты(
//	|			&qDateTimeFrom,
//	|			&qDateTimeTo,
//	|			Second,
//	|			RegisterRecordsAndPeriodBoundaries,
//	|			&qHotelIsEmpty
//	|				OR NOT &qHotelIsEmpty
//	|					AND Гостиница IN HIERARCHY (&qHotel)) AS RoomInventoryBalance
//	|
//	|GROUP BY
//	|	RoomInventoryBalance.Гостиница,
//	|	RoomInventoryBalance.ТипНомера,
//	|	BEGINOFPERIOD(DATEADD(RoomInventoryBalance.Period, SECOND, &qShiftInSeconds), DAY)
//	|;
//	|
//	|////////////////////////////////////////////////////////////////////////////////
//	|SELECT
//	|	RoomInventoryDailyBalance.Гостиница AS Гостиница,
//	|	RoomInventoryDailyBalance.ТипНомера AS ТипНомера,
//	|	RoomInventoryDailyBalance.Period AS Period,
//	|	RoomInventoryDailyBalance.RoomsVacant AS RoomsVacant,
//	|	RoomInventoryDailyBalance.BedsVacant AS BedsVacant
//	|FROM
//	|	RoomInventoryDailyBalance AS RoomInventoryDailyBalance
//	|
//	|ORDER BY
//	|	Period
//	|TOTALS
//	|	SUM(RoomsVacant),
//	|	SUM(BedsVacant)
//	|BY
//	|	Гостиница HIERARCHY,
//	|	ТипНомера HIERARCHY,
//	|	Period PERIODS(DAY, &qDateTimeFrom, &qDateTimeTo)";
//	vQry.SetParameter("qHotel", Гостиница);
//	vQry.SetParameter("qHotelIsEmpty", НЕ ЗначениеЗаполнено(Гостиница));
//	vQry.SetParameter("qShiftInSeconds", ?(ЗначениеЗаполнено(Гостиница) And ЗначениеЗаполнено(Гостиница.Тариф) And ЗначениеЗаполнено(Гостиница.Тариф.ReferenceHour), -(Гостиница.Тариф.ReferenceHour - BegOfDay(Гостиница.Тариф.ReferenceHour)), -43200));
//	vQry.SetParameter("qDateTimeFrom", vDateTimeFrom);
//	vQry.SetParameter("qDateTimeTo", vDateTimeTo);
//	vQryRes = vQry.Execute();
//	
//	// Initialize query by rooms
//	vQryByRooms = New Query();
//	vQryByRooms.Text = 
//	"SELECT
//	|	RoomsBalance.Гостиница AS Гостиница,
//	|	RoomsBalance.ТипНомера AS ТипНомера,
//	|	RoomsBalance.RoomsVacant AS RoomsVacant,
//	|	RoomsBalance.BedsVacant AS BedsVacant
//	|FROM
//	|	(SELECT
//	|		RoomsBalanceByRooms.Гостиница AS Гостиница,
//	|		RoomsBalanceByRooms.ТипНомера AS ТипНомера,
//	|		SUM(RoomsBalanceByRooms.RoomsVacant) AS RoomsVacant,
//	|		SUM(RoomsBalanceByRooms.BedsVacant) AS BedsVacant
//	|	FROM
//	|		(SELECT
//	|			RoomInventoryRoomsBalance.Гостиница AS Гостиница,
//	|			RoomInventoryRoomsBalance.ТипНомера AS ТипНомера,
//	|			RoomInventoryRoomsBalance.НомерРазмещения AS НомерРазмещения,
//	|			MIN(RoomInventoryRoomsBalance.RoomsVacantClosingBalance) AS RoomsVacant,
//	|			MIN(RoomInventoryRoomsBalance.BedsVacantClosingBalance) AS BedsVacant
//	|		FROM
//	|			(SELECT
//	|				RoomInventoryRoomsBalanceAndTurnovers.Гостиница AS Гостиница,
//	|				RoomInventoryRoomsBalanceAndTurnovers.ТипНомера AS ТипНомера,
//	|				RoomInventoryRoomsBalanceAndTurnovers.НомерРазмещения AS НомерРазмещения,
//	|				RoomInventoryRoomsBalanceAndTurnovers.Period AS Period,
//	|				ISNULL(RoomInventoryRoomsBalanceAndTurnovers.TotalRoomsClosingBalance, 0) AS TotalRoomsClosingBalance,
//	|				ISNULL(RoomInventoryRoomsBalanceAndTurnovers.RoomsVacantClosingBalance, 0) AS RoomsVacantClosingBalance,
//	|				ISNULL(RoomInventoryRoomsBalanceAndTurnovers.BedsVacantClosingBalance, 0) AS BedsVacantClosingBalance
//	|			FROM
//	|				РегистрНакопления.ЗагрузкаНомеров.BalanceAndTurnovers(
//	|						&qDateTimeFrom,
//	|						&qDateTimeTo,
//	|						Second,
//	|						RegisterRecordsAndPeriodBoundaries,
//	|						Гостиница IN HIERARCHY (&qHotel)
//	|							AND (&qRoomTypeIsEmpty
//	|								OR NOT &qRoomTypeIsEmpty
//	|									AND ТипНомера IN HIERARCHY (&qRoomType))) AS RoomInventoryRoomsBalanceAndTurnovers) AS RoomInventoryRoomsBalance
//	|		
//	|		GROUP BY
//	|			RoomInventoryRoomsBalance.Гостиница,
//	|			RoomInventoryRoomsBalance.ТипНомера,
//	|			RoomInventoryRoomsBalance.НомерРазмещения) AS RoomsBalanceByRooms
//	|	
//	|	GROUP BY
//	|		RoomsBalanceByRooms.Гостиница,
//	|		RoomsBalanceByRooms.ТипНомера) AS RoomsBalance
//	|
//	|ORDER BY
//	|	RoomsBalance.Гостиница.ПорядокСортировки,
//	|	RoomsBalance.Гостиница.Description,
//	|	RoomsBalance.ТипНомера.ПорядокСортировки,
//	|	RoomsBalance.ТипНомера.Description";
//	
//	// Show progress status
//	ProgressForm.ValueRemarks  = "Построение заголовка отчета";
//
//	// Draw header
//	vSpreadsheet = pSpreadsheet;
//	vSpreadsheet.Clear();
//	vSpreadsheet.ShowGroups = True;
//	
//	vTemplate = GetTemplate("Report");
//	vArea = vTemplate.GetArea("Header|NamesColumn");
//	If vShowReportsInBeds Тогда
//		pHeader.Caption = "Своб. места по р/ч:";
//	Else
//		pHeader.Caption = "Своб. номера по р/ч:";
//	EndIf;
//	vSpreadsheet.Put(vArea);
//
//	vQryDays = vQryRes.Choose(QueryResultIteration.ByGroups, "Period", "ALL");
//	
//	While vQryDays.Next() Do
//		vPeriod = vQryDays.Period;
//		vCurDate = BegOfDay(vPeriod);
//		If (?(vDateFrom = vCurrentDate, (vPeriod + 24*3600), vPeriod) < vDateTimeFrom) Or (vPeriod > vDateTimeTo) Тогда
//			Continue;
//		EndIf;
//	
//		mDay = Day(vCurDate);
//		mDayOfWeek = cmGetDayOfWeekName(WeekDay(vCurDate), True);
//		mMonth = Format(vPeriod, "DF=MMMM");
//		
//		If vCurDate = BegOfMonth(vCurDate) Or vCurDate = vDateFrom Тогда
//			vArea = vTemplate.GetArea("Header|LastFirstDayOfMonth");
//			vArea.Parameters.mMonth = mMonth;
//		ElsIf WeekDay(vCurDate) = 1 Тогда
//			vArea = vTemplate.GetArea("Header|LastFirstDayOfWeek");
//		Else
//			vArea = vTemplate.GetArea("Header|LastFirstHourOfDay");
//		EndIf;
//		vArea.Parameters.mDay = mDay;
//		vArea.Parameters.mDayOfWeek = mDayOfWeek;
//		vArea.Parameters.mHour = "";
//		vSpreadsheet.Join(vArea);
//	EndDo;
//	
//	// Show progress status
//	ProgressForm.ValueRemarks = NStr("en='Draw report data. Events.';ru='Вывод данных. Мероприятия.';de='Output von Daten. Veranstaltungen.'");
//
//	// Output events
//	//If vEvents.Count() > 0 Тогда
//	//	vArea = vTemplate.GetArea("EventRow|NamesColumn");
//	//	vSpreadsheet.Put(vArea);
//	//	
//	//	vEventsRow = Неопределено;
//	//	vCommentIsPlaced = False;
//	//	
//	//	vQryDays = vQryRes.Choose(QueryResultIteration.ByGroups, "Period", "ALL");
//	//	While vQryDays.Next() Do
//	//		vPeriod = vQryDays.Period;
//	//		If (?(vDateFrom = vCurrentDate, (vPeriod + 24*3600), vPeriod) < vDateTimeFrom) Or (vPeriod > vDateTimeTo) Тогда
//	//			Continue;
//	//		EndIf;
//	//		vCurDate = BegOfDay(vPeriod);
//	//		
//	//		// Try to find event starting from this date
//	//		vThisIsFirstPeriodOfEvent = False;
//	//		//vProbeEventsRow = vEvents.Find(vCurDate, "DateFrom");
//	//		//If vProbeEventsRow <> Неопределено Тогда
//	//		//	If vEventsRow = Неопределено Тогда
//	//		//		vEventsRow = vProbeEventsRow;
//	//		//		vThisIsFirstPeriodOfEvent = True;
//	//		//		vCommentIsPlaced = False;
//	//		//	Else
//	//		//		If vEventsRow <> vProbeEventsRow Тогда
//	//		//			vEventsRow = vProbeEventsRow;
//	//		//			vThisIsFirstPeriodOfEvent = True;
//	//		//			vCommentIsPlaced = False;
//	//		//		EndIf;
//	//		//	EndIf;
//	//		//EndIf;
//	//		
//	//		vAreaRowName = "NoEventRow";
//	//		//If vEventsRow <> Неопределено Тогда
//	//		//	If vCurDate > vEventsRow.DateTo Or vCurDate < vEventsRow.DateFrom Тогда
//	//		//		vEventsRow = Неопределено;
//	//		//	Else
//	//		//		vAreaRowName = "EventRow";
//	//		//	EndIf;
//	//		//EndIf;
//	//		
//	//		If vCurDate = BegOfMonth(vCurDate) Or vCurDate = vDateFrom Тогда
//	//			vArea = vTemplate.GetArea(vAreaRowName + "|LastFirstDayOfMonth");
//	//		ElsIf WeekDay(vCurDate) = 1 Тогда
//	//			vArea = vTemplate.GetArea(vAreaRowName + "|LastFirstDayOfWeek");
//	//		Else
//	//			vArea = vTemplate.GetArea(vAreaRowName + "|LastFirstHourOfDay");
//	//		EndIf;
//	//		If vEventsRow <> Неопределено And vAreaRowName = "EventRow" Тогда
//	//			If vThisIsFirstPeriodOfEvent Тогда
//	//				vArea.Parameters.mEventDescription = TrimAll(vEventsRow.Description);
//	//			Else
//	//				vArea.Parameters.mEventDescription = "";
//	//			EndIf;
//	//			vArea.Parameters.mEvent = vEventsRow.Ref;
//	//		ElsIf vAreaRowName = "NoEventRow" Тогда
//	//			vArea.Parameters.mEvent = Справочники.Events.EmptyRef();
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
//	//				vOutputArea.Comment.Text = Chars.LF + Chars.LF + TrimAll(Format(vEventsRow.DateFrom, "DF=dd.MM.yyyy") + " - " + Format(vEventsRow.DateTo, "DF=dd.MM.yyyy") + Chars.LF +
//	//										   TrimAll(vEventsRow.Remarks));
//	//			EndIf;
//	//		EndIf;
//	//	EndDo;
//	//EndIf;
//	
//	// Show progress status
//	ProgressForm.ValueRemarks = NStr("en='Draw report data. Гостиница totals.';ru='Вывод данных. Итог по гостинице.';de='Output von Daten. Ergebnis nach Гостиница.'");
//	
//	// Count maximum value for progress bar
//	vNHotels = vQryRes.Choose(QueryResultIteration.ByGroups, "Гостиница").Count();
//	vNRoomTypes = vQryRes.Choose(QueryResultIteration.ByGroups, "ТипНомера").Count();
//	ProgressForm.MaxValue = vNHotels*NumberOfDays;
//	vProgressValue = 1;
//	
//	// Build report form
//	vQryHotels = vQryRes.Choose(QueryResultIteration.ByGroups, "Гостиница");
//	While vQryHotels.Next() Do
//		// Show hotel
//		vHotel = vQryHotels.Гостиница; 
//		vArea = vTemplate.GetArea("HotelRow|NamesColumn");
//		vArea.Parameters.mHotel = vHotel;
//		vSpreadsheet.Put(vArea);
//		vShiftInSeconds = 43200;
//		If ЗначениеЗаполнено(vHotel) And ЗначениеЗаполнено(vHotel.Тариф) And ЗначениеЗаполнено(vHotel.Тариф.ReferenceHour) Тогда
//			vShiftInSeconds = vHotel.Тариф.ReferenceHour - BegOfDay(vHotel.Тариф.ReferenceHour);
//		EndIf;
//		
//		// Show hotel totals by days and hours
//		vLastVacant = 0;
//		vQryDays = vQryHotels.Choose(QueryResultIteration.ByGroups, "Period", "ALL");
//		While vQryDays.Next() Do
//			vPeriod = vQryDays.Period;
//			vCurDate = BegOfDay(vPeriod);
//			If (?(vDateFrom = vCurrentDate, (vPeriod + 24*3600), vPeriod) < vDateTimeFrom) Or (vPeriod > vDateTimeTo) Тогда
//				Continue;
//			EndIf;
//			
//			// Get necessary report template area
//			If vCurDate = BegOfMonth(vCurDate) Or vCurDate = vDateFrom Тогда
//				vArea = vTemplate.GetArea("HotelRow|LastFirstDayOfMonth");
//			ElsIf WeekDay(vCurDate) = 1 Тогда
//				vArea = vTemplate.GetArea("HotelRow|LastFirstDayOfWeek");
//			Else
//				vArea = vTemplate.GetArea("HotelRow|LastFirstHourOfDay");
//			EndIf;
//			
//			// Get vacant rooms/beds for one date
//			vVacant = GetQueryResource(vQryDays, vShowReportsInBeds, vLastVacant);
//			
//			// Show progress status
//			ProgressForm.ValueRemarks  = NStr("ru = 'Вывод данных по дате: '; en = 'Draw report data. Date: '; de = 'Zeichnen Sie Berichtsdaten. Datum: '") + Format(vCurDate, "DF=dd.MM.yyyy");
//			ProgressForm.Value = vProgressValue;
//			vProgressValue = vProgressValue + 1;
//			
//			// Get number of vacant rooms per several days
//			vQryByRoomsRes = Неопределено;
//			If Duration > 1 Тогда
//				vQryByRooms.SetParameter("qHotel", vHotel);
//				vQryByRooms.SetParameter("qRoomType", Справочники.ТипыНомеров.EmptyRef());
//				vQryByRooms.SetParameter("qRoomTypeIsEmpty", True);
//				vQryByRooms.SetParameter("qDateTimeFrom", cm1SecondShift(vCurDate + vShiftInSeconds));
//				vQryByRooms.SetParameter("qDateTimeTo", cm0SecondShift(vCurDate + vShiftInSeconds + Duration * 24 * 3600));
//				vQryByRoomsRes = vQryByRooms.Execute().Unload();
//				vVacantByRooms = GetRoomsQueryResource(vQryByRoomsRes, vShowReportsInBeds);
//				If vVacantByRooms <> Null Тогда
//					If vVacant > vVacantByRooms Тогда
//						vVacant = vVacantByRooms;
//					EndIf;
//				EndIf;
//				If vVacant < 0 Тогда
//					vVacant = 0;
//				EndIf;
//			EndIf;
//			
//			// Fill report area parameters
//			vArea.Parameters.mVacant = vVacant;
//			vArea.Parameters.mDetails = New Structure("Гостиница, ТипНомера, ПериодПо", 
//			                                           vHotel, 
//			                                           Справочники.ТипыНомеров.EmptyRef(), 
//			                                           EndOfDay(vPeriod));
//			If vVacant < 0 Тогда
//				vCell = vArea.Area(1,1,1,1);
//				vCell.TextColor = WebColors.Red;
//			EndIf;
//			vSpreadsheet.Join(vArea);
//			
//			vLastVacant = vVacant;
//		EndDo;
//		
//		// Show ГруппаНомеров types for this hotel
//		vQryRoomTypes = vQryHotels.Choose(QueryResultIteration.ByGroups, "ТипНомера");
//		While vQryRoomTypes.Next() Do
//			// Show ГруппаНомеров type
//			vAreaCol = "RoomTypeRow";
//			If vQryRoomTypes.ТипНомера.IsFolder Тогда
//				vAreaCol = "RoomTypeFolderRow";
//			EndIf;
//			vArea = vTemplate.GetArea(vAreaCol + "|NamesColumn");
//			If vQryRoomTypes.ТипНомера.IsFolder Тогда
//				vArea.Parameters.mRoomType = cmGetIndent(vQryRoomTypes.ТипНомера, +1) + TrimR(vQryRoomTypes.ТипНомера.Description);
//			Else
//				vArea.Parameters.mRoomType = cmGetIndent(vQryRoomTypes.ТипНомера, +1) + TrimR(vQryRoomTypes.ТипНомера.Code);
//			EndIf;
//			vSpreadsheet.Put(vArea);
//			
//			// Show ГруппаНомеров type totals by days
//			vLastVacant = 0;
//			vQryDays = vQryRoomTypes.Choose(QueryResultIteration.ByGroups, "Period", "ALL");
//			While vQryDays.Next() Do
//				vPeriod = vQryDays.Period;
//				vCurDate = BegOfDay(vPeriod);
//				If (?(vDateFrom = vCurrentDate, (vPeriod + 24*3600), vPeriod) < vDateTimeFrom) Or (vPeriod > vDateTimeTo) Тогда
//					Continue;
//				EndIf;
//				
//				// Check ГруппаНомеров type stop sale
//				vStopSaleRemarks = "";
//				vAreaCol = "RoomTypeRow";
//				If vQryRoomTypes.ТипНомера.IsFolder Тогда
//					vAreaCol = "RoomTypeFolderRow";
//				Else
//					If vQryRoomTypes.ТипНомера.СнятСПродажи Тогда
//						If cmIsStopSalePeriod(vQryRoomTypes.ТипНомера, vPeriod, vPeriod, vStopSaleRemarks) Тогда
//							vAreaCol = "RoomTypeStopSaleRow";
//						EndIf;
//					EndIf;
//				EndIf;
//				
//				// Get necessary report template area
//				If vCurDate = BegOfMonth(vCurDate) Or vCurDate = vDateFrom Тогда
//					vArea = vTemplate.GetArea(vAreaCol + "|LastFirstDayOfMonth");
//				ElsIf WeekDay(vCurDate) = 1 Тогда
//					vArea = vTemplate.GetArea(vAreaCol + "|LastFirstDayOfWeek");
//				Else
//					vArea = vTemplate.GetArea(vAreaCol + "|LastFirstHourOfDay");
//				EndIf;
//				// Set weekend backgroud color
//				If WeekDay(vCurDate) = 7 OR WeekDay(vCurDate) = 6 Тогда
//					vArea = vTemplate.GetArea(vAreaCol + "|LastDayOfWeek");
//				EndIf;
//
//				// Get number of vacant rooms/beds
//				vVacant = GetQueryResource(vQryDays, vShowReportsInBeds, vLastVacant);
//				
//				// Get number of vacant rooms per several days
//				If Duration > 1 Тогда
//					vVacantByRooms = GetRoomsQueryResource(vQryByRoomsRes, vShowReportsInBeds, vQryRoomTypes.ТипНомера);
//					If vVacantByRooms <> Null Тогда
//						If vVacant > vVacantByRooms Тогда
//							vVacant = vVacantByRooms;
//						EndIf;
//					EndIf;
//					If vVacant < 0 Тогда
//						vVacant = 0;
//					EndIf;
//				EndIf;
//				
//				// Set area parameters
//				vArea.Parameters.mVacant = vVacant;
//				vArea.Parameters.mDetails = New Structure("Гостиница, ТипНомера, ПериодПо", 
//				                                           vQryHotels.Гостиница, 
//				                                           vQryRoomTypes.ТипНомера, 
//				                                           EndOfDay(vPeriod));
//				If vVacant < 0 Тогда
//					vCell = vArea.Area(1,1,1,1);
//					vCell.TextColor = WebColors.Red;
//				EndIf;
//				
//				// Join template area to the report
//				vSpreadsheet.Join(vArea);
//				
//				vLastVacant = vVacant;
//			EndDo;
//		EndDo;
//	EndDo;
//	If ProgressForm.IsOpen() Тогда
//		ProgressForm.Close();
//	EndIf;
//	
//	// Setup default attributes
//	cmSetDefaultPrintFormSettings(vSpreadsheet, PageOrientation.Landscape);
//	
//	// Set report protection
//	cmSetSpreadsheetProtection(vSpreadsheet);
//	
//	// Set report header
//	cmApplyReportHeader(vSpreadsheet);
//	// Add configuration name to the right report header
//	pSpreadsheet.Header.LeftText = ?(ЗначениеЗаполнено(ПараметрыСеанса.ТекущаяГостиница), 
//									 ПараметрыСеанса.ТекущаяГостиница.GetObject().pmGetHotelPrintName(ПараметрыСеанса.ТекЛокализация), "") + " - " + 
//									TrimAll(ПараметрыСеанса.ПредставлениеКонфигурации);
//	vSpreadsheet.Header.RightText = TrimAll(ПараметрыСеанса.ТекПользователь) + " - " + Format(CurrentDate(), "DF='dd.MM.yyyy HH:mm'");
//	// Set footer
//	cmApplyReportFooter(vSpreadsheet);
//	
//	// Fix report header and ГруппаНомеров type codes
//	vSpreadsheet.FixedTop = 4;
//	//vSpreadsheet.FixedLeft = 2;
//КонецПроцедуры //pmGenerateByDuration
