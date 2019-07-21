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
//	vOccupiedRoomStatus = Справочники.СтатусыНомеров.EmptyRef();
//	If НЕ ЗначениеЗаполнено(Гостиница) Тогда
//		Гостиница = ПараметрыСеанса.ТекущаяГостиница;
//	EndIf;
//	If ЗначениеЗаполнено(Гостиница) Тогда
//		vOccupiedRoomStatus = Гостиница.OccupiedRoomStatus;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(PeriodTo) Тогда
//		PeriodTo = CurrentDate();
//	EndIf;
//	#IF CLIENT THEN
//		If RoomStatuses.Count() = 0 Тогда
//			vAllStatuses = cmGetAllRoomStatuses();
//			For Each vStatusRow In vAllStatuses Do
//				If ЗначениеЗаполнено(vOccupiedRoomStatus) And 
//				   vOccupiedRoomStatus = vStatusRow.СтатусНомера Тогда
//					RoomStatuses.Add(vStatusRow.СтатусНомера, TrimAll(vStatusRow.СтатусНомера), False, cmGetRoomStatusIcon(vStatusRow.СтатусНомера));
//				Else
//					RoomStatuses.Add(vStatusRow.СтатусНомера, TrimAll(vStatusRow.СтатусНомера), True, cmGetRoomStatusIcon(vStatusRow.СтатусНомера));
//				EndIf;
//			EndDo;
//			RoomStatuses.Add(Справочники.СтатусыНомеров.EmptyRef(), NStr("en='<Empty status>';ru='<Пустой статус>';de='<Leerer Status>'"), True, cmGetRoomStatusIcon(Справочники.СтатусыНомеров.EmptyRef()));
//		EndIf;
//	#ENDIF
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
//	If НЕ ЗначениеЗаполнено(PeriodTo) Тогда
//		vParamPresentation = vParamPresentation + NStr("en='Report period is not set';ru='Период отчета не установлен';de='Berichtszeitraum nicht festgelegt'") + 
//		                     ";" + Chars.LF;
//	Else
//		vParamPresentation = vParamPresentation + NStr("ru = 'Период '; en = 'Period '") + 
//		                     Format(PeriodTo, "DF='dd.MM.yyyy HH:mm:ss'") + 
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
//	If ShowReservedRooms Тогда
//		vParamPresentation = vParamPresentation + NStr("en='Show reserved rooms';ru='Показываются зарезервированные номера';de='Reservierte Zimmer werden angezeigt'") + 
//							 ";" + Chars.LF;
//	EndIf;
//	Return vParamPresentation;
//EndFunction //pmGetReportParametersPresentation
//
////-----------------------------------------------------------------------------
//// Runs report
////-----------------------------------------------------------------------------
//Процедура pmGenerate(pSpreadsheet) Экспорт
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
//	ReportBuilder.Parameters.Вставить("qPeriodTo", PeriodTo);
//	ReportBuilder.Parameters.Вставить("qPeriodToMinusDay", PeriodTo - 24*3600);
//	ReportBuilder.Parameters.Вставить("qRoom", ГруппаНомеров);
//	ReportBuilder.Parameters.Вставить("qRoomType", RoomType);
//	ReportBuilder.Parameters.Вставить("qIsEmptyRoomStatuses", ?(RoomStatuses.Count() = 0, True, False));
//	vRoomStatuses = New СписокЗначений();
//	For Each vItem In RoomStatuses Do
//		If vItem.Check Тогда
//			vRoomStatuses.Add(vItem.Value);
//		EndIf;
//	EndDo;
//	ReportBuilder.Parameters.Вставить("qRoomStatuses", vRoomStatuses);
//	ReportBuilder.Parameters.Вставить("qShowReservedRooms", ShowReservedRooms);
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
//	// Add guests from occupied rooms to ГруппаНомеров folders
//	vQryGuests = New Query();
//	vQryGuests.Text = 
//	"SELECT
//	|	ЗагрузкаНомеров.НомерРазмещения AS НомерРазмещения,
//	|	ЗагрузкаНомеров.IsReservation AS IsReservation,
//	|	ЗагрузкаНомеров.Клиент.Гражданство.ISOCode AS GuestCitizenship,
//	|	ЗагрузкаНомеров.Клиент.Sex AS GuestSex,
//	|	COUNT(*) AS GuestCount,
//	|	ЗагрузкаНомеров.НомерРазмещения.ПорядокСортировки AS ПорядокСортировки
//	|FROM (
//	|	SELECT
//	|		RoomInventoryRecorders.НомерРазмещения AS НомерРазмещения,
//	|		RoomInventoryRecorders.IsReservation AS IsReservation,
//	|		RoomInventoryRecorders.Клиент AS Клиент,
//	|		RoomInventoryRecorders.Recorder AS Recorder
//	|	FROM
//	|		AccumulationRegister.ЗагрузкаНомеров AS RoomInventoryRecorders
//	|	WHERE " +
//			?(ЗначениеЗаполнено(Гостиница), "RoomInventoryRecorders.Гостиница IN HIERARCHY(&qHotel)", "TRUE") + "
//	|		AND RoomInventoryRecorders.RecordType = &qExpense
//	|		AND RoomInventoryRecorders.ПериодС <= &qDateTo
//	|		AND RoomInventoryRecorders.ПериодПо > &qDateTo
//	|		AND (RoomInventoryRecorders.IsReservation OR RoomInventoryRecorders.IsAccommodation)
//	|	GROUP BY
//	|		RoomInventoryRecorders.НомерРазмещения,
//	|		RoomInventoryRecorders.IsReservation,
//	|		RoomInventoryRecorders.Клиент,
//	|		RoomInventoryRecorders.Recorder) AS ЗагрузкаНомеров
//	|GROUP BY
//	|	ЗагрузкаНомеров.НомерРазмещения,
//	|	ЗагрузкаНомеров.IsReservation,
//	|	ЗагрузкаНомеров.Клиент.Гражданство.ISOCode,
//	|	ЗагрузкаНомеров.Клиент.Sex
//	|ORDER BY
//	|	ПорядокСортировки
//	|TOTALS
//	|	SUM(GuestCount)
//	|BY
//	|	IsReservation, GuestCitizenship, GuestSex, НомерРазмещения HIERARCHY";
//	vQryGuests.SetParameter("qHotel", Гостиница);
//	vQryGuests.SetParameter("qExpense", AccumulationRecordType.Expense);
//	vQryGuests.SetParameter("qDateTo", PeriodTo);
//	vGuests = vQryGuests.Execute().Unload();
//	// Group by all dimensions to get ГруппаНомеров folders totals
//	vGuests.GroupBy("IsReservation, GuestCitizenship, GuestSex, НомерРазмещения", "GuestCount");
//	vRoomFolders = vGuests.Copy();
//	vRoomFolders.GroupBy("НомерРазмещения", );
//	// Fill guests
//	For Each vRoomFoldersRow In vRoomFolders Do
//		vCurRoom = vRoomFoldersRow.ГруппаНомеров;
//		If НЕ ЗначениеЗаполнено(vCurRoom) Тогда
//			Continue;
//		EndIf;
//		vGuestsStr = "";
//		If vCurRoom.IsFolder Тогда
//			If НЕ vCurRoom.DoNotShowRoomGuestTotals Тогда
//				vRowsArray = vGuests.FindRows(New Structure("НомерРазмещения", vCurRoom));
//				For Each vRow In vRowsArray Do
//					If НЕ IsBlankString(vGuestsStr) Тогда
//						vGuestsStr = vGuestsStr + ", ";
//					EndIf;
//					vGuestCount = vRow.GuestCount;
//					If НЕ vCurRoom.IsFolder Тогда
//						vGuestCount = vGuestCount/2;
//					EndIf;
//					vGuestSex = TrimAll(String(vRow.GuestSex));
//					vGuestCitizenship = TrimAll(vRow.GuestCitizenship);
//					vGuestsStr = vGuestsStr + ?(vRow.IsReservation, NStr("en='r';ru='р';de='r'"), "") + 
//											  String(vGuestCount) + 
//											  Left(?(vGuestSex="", "?", vGuestSex), 1) + 
//											  "(" + ?(vGuestCitizenship="", "?", vGuestCitizenship) + ")";
//				EndDo;
//				If НЕ IsBlankString(vGuestsStr) Тогда
//					vCurRoomText = TrimAll(vCurRoom);
//					// Try to find ГруппаНомеров folder description in the spreadsheet 
//					vRoomFolderArea = pSpreadsheet.FindText(vCurRoomText, , , False, False, , True);
//					If vRoomFolderArea <> Неопределено Тогда
//						vRoomFolderArea.Text = vRoomFolderArea.Text + " " + vGuestsStr;
//					EndIf;
//				EndIf;
//			EndIf;
//		EndIf;
//	EndDo;
//		
//	// Apply number of pages to be printed on the one paper sheet
//	cmApplyReportMultiplePages(ThisObject, pSpreadsheet)
//КонецПроцедуры //pmGenerate
//
////-----------------------------------------------------------------------------
//Процедура pmInitializeReportBuilder() Экспорт
//	ReportBuilder = New ReportBuilder();
//	
//	// Initialize default query text
//	QueryText = 
//	"SELECT
//	|	СвободныеНомера.Гостиница AS Гостиница,
//	|	СвободныеНомера.НомерРазмещения AS НомерРазмещения,
//	|	СвободныеНомера.ТипНомера.Code AS RoomTypeCode,
//	|	СвободныеНомера.СтатусНомера AS СтатусНомера,
//	|	СвободныеНомера.ГруппаГостей AS ГруппаГостей,
//	|	СвободныеНомера.Клиент AS Клиент,
//	|	СвободныеНомера.GuestSex AS GuestSex,
//	|	СвободныеНомера.GuestCitizenship AS GuestCitizenship,
//	|	СвободныеНомера.CheckOutDate AS CheckOutDate,
//	|	СвободныеНомера.CheckInDate AS CheckInDate,
//	|	СвободныеНомера.RoomsVacantBalance AS RoomsVacantBalance,
//	|	СвободныеНомера.BedsVacantBalance AS BedsVacantBalance,
//	|	СвободныеНомера.GuestsVacantBalance AS GuestsVacantBalance,
//	|	СвободныеНомера.InHouseRoomsBalance AS InHouseRoomsBalance,
//	|	СвободныеНомера.InHouseBedsBalance AS InHouseBedsBalance,
//	|	СвободныеНомера.InHouseAdditionalBedsBalance AS InHouseAdditionalBedsBalance,
//	|	СвободныеНомера.InHouseGuestsBalance AS InHouseGuestsBalance
//	|{SELECT
//	|	Гостиница.* AS Гостиница,
//	|	НомерРазмещения.* AS НомерРазмещения,
//	|	СвободныеНомера.ТипНомера.* AS ТипНомера,
//	|	СтатусНомера.* AS СтатусНомера,
//	|	ГруппаГостей.* AS ГруппаГостей,
//	|	Клиент.* AS Клиент,
//	|	GuestSex AS GuestSex,
//	|	GuestCitizenship.* AS GuestCitizenship,
//	|	СвободныеНомера.Recorder.* AS Recorder,
//	|	СвободныеНомера.ДокОснование.* AS ДокОснование,
//	|	CheckOutDate AS CheckOutDate,
//	|	CheckInDate AS CheckInDate,
//	|	RoomsVacantBalance AS RoomsVacantBalance,
//	|	BedsVacantBalance AS BedsVacantBalance,
//	|	GuestsVacantBalance AS GuestsVacantBalance,
//	|	InHouseRoomsBalance AS InHouseRoomsBalance,
//	|	InHouseBedsBalance AS InHouseBedsBalance,
//	|	InHouseAdditionalBedsBalance AS InHouseAdditionalBedsBalance,
//	|	InHouseGuestsBalance AS InHouseGuestsBalance}
//	|FROM
//	|	(SELECT
//	|		RoomInventoryBalance.Гостиница AS Гостиница,
//	|		RoomInventoryBalance.НомерРазмещения AS НомерРазмещения,
//	|		RoomInventoryBalance.ТипНомера AS ТипНомера,
//	|		RoomInventoryBalance.НомерРазмещения.СтатусНомера AS СтатусНомера,
//	|		InHouseGuests.ГруппаГостей AS ГруппаГостей,
//	|		InHouseGuests.Клиент AS Клиент,
//	|		InHouseGuests.Клиент.Sex AS GuestSex,
//	|		InHouseGuests.Клиент.Гражданство AS GuestCitizenship,
//	|		InHouseGuests.Recorder AS Recorder,
//	|		InHouseGuests.ДокОснование AS ДокОснование,
//	|		CheckedOutGuests.CheckOutDate AS CheckOutDate,
//	|		FutureReservations.CheckInDate AS CheckInDate,
//	|		RoomInventoryBalance.RoomsVacantBalance AS RoomsVacantBalance,
//	|		RoomInventoryBalance.BedsVacantBalance AS BedsVacantBalance,
//	|		RoomInventoryBalance.GuestsVacantBalance AS GuestsVacantBalance,
//	|		-RoomInventoryBalance.InHouseRoomsBalance AS InHouseRoomsBalance,
//	|		-RoomInventoryBalance.InHouseBedsBalance AS InHouseBedsBalance,
//	|		-RoomInventoryBalance.InHouseAdditionalBedsBalance AS InHouseAdditionalBedsBalance,
//	|		-RoomInventoryBalance.InHouseGuestsBalance AS InHouseGuestsBalance
//	|	FROM
//	|		AccumulationRegister.ЗагрузкаНомеров.Balance(
//	|				&qPeriodTo,
//	|				Гостиница IN HIERARCHY (&qHotel)
//	|					AND ТипНомера IN HIERARCHY (&qRoomType)
//	|					AND НомерРазмещения IN HIERARCHY (&qRoom)) AS RoomInventoryBalance
//	|			LEFT JOIN (SELECT
//	|				ЗагрузкаНомеров.Гостиница AS Гостиница,
//	|				ЗагрузкаНомеров.НомерРазмещения AS НомерРазмещения,
//	|				ЗагрузкаНомеров.ГруппаГостей AS ГруппаГостей,
//	|				ЗагрузкаНомеров.Клиент AS Клиент,
//	|				ЗагрузкаНомеров.Клиент.Sex AS GuestSex,
//	|				ЗагрузкаНомеров.Клиент.Гражданство AS GuestCitizenship,
//	|				ЗагрузкаНомеров.Recorder AS Recorder,
//	|				ЗагрузкаНомеров.ДокОснование AS ДокОснование
//	|			FROM
//	|				AccumulationRegister.ЗагрузкаНомеров AS RoomInventory
//	|			WHERE
//	|				ЗагрузкаНомеров.RecordType = VALUE(AccumulationRecordType.Expense)
//	|				AND ЗагрузкаНомеров.IsAccommodation
//	|				AND ЗагрузкаНомеров.ПериодС <= &qPeriodTo
//	|				AND ЗагрузкаНомеров.ПериодПо > &qPeriodTo
//	|			
//	|			GROUP BY
//	|				ЗагрузкаНомеров.Гостиница,
//	|				ЗагрузкаНомеров.НомерРазмещения,
//	|				ЗагрузкаНомеров.ГруппаГостей,
//	|				ЗагрузкаНомеров.Клиент,
//	|				ЗагрузкаНомеров.Клиент.Sex,
//	|				ЗагрузкаНомеров.Клиент.Гражданство,
//	|				ЗагрузкаНомеров.Recorder,
//	|				ЗагрузкаНомеров.ДокОснование) AS InHouseGuests
//	|			ON RoomInventoryBalance.Гостиница = InHouseGuests.Гостиница
//	|				AND RoomInventoryBalance.НомерРазмещения = InHouseGuests.НомерРазмещения
//	|			LEFT JOIN (SELECT
//	|				RoomCheckOut.Гостиница AS Гостиница,
//	|				RoomCheckOut.НомерРазмещения AS НомерРазмещения,
//	|				MAX(RoomCheckOut.CheckOutDate) AS CheckOutDate
//	|			FROM
//	|				AccumulationRegister.ЗагрузкаНомеров AS RoomCheckOut
//	|			WHERE
//	|				RoomCheckOut.RecordType = VALUE(AccumulationRecordType.Expense)
//	|				AND RoomCheckOut.IsAccommodation
//	|				AND RoomCheckOut.CheckOutDate = RoomCheckOut.ПериодПо
//	|				AND RoomCheckOut.CheckOutDate <= &qPeriodTo
//	|				AND RoomCheckOut.CheckOutDate > &qPeriodToMinusDay
//	|			
//	|			GROUP BY
//	|				RoomCheckOut.Гостиница,
//	|				RoomCheckOut.НомерРазмещения) AS CheckedOutGuests
//	|			ON RoomInventoryBalance.Гостиница = CheckedOutGuests.Гостиница
//	|				AND RoomInventoryBalance.НомерРазмещения = CheckedOutGuests.НомерРазмещения
//	|			LEFT JOIN (SELECT
//	|				Reservations.Гостиница AS Гостиница,
//	|				Reservations.НомерРазмещения AS НомерРазмещения,
//	|				MIN(Reservations.CheckInDate) AS CheckInDate
//	|			FROM
//	|				AccumulationRegister.ЗагрузкаНомеров AS Reservations
//	|			WHERE
//	|				Reservations.RecordType = VALUE(AccumulationRecordType.Expense)
//	|				AND Reservations.IsReservation
//	|				AND Reservations.CheckInDate >= &qPeriodTo
//	|			
//	|			GROUP BY
//	|				Reservations.Гостиница,
//	|				Reservations.НомерРазмещения) AS FutureReservations
//	|			ON RoomInventoryBalance.Гостиница = FutureReservations.Гостиница
//	|				AND RoomInventoryBalance.НомерРазмещения = FutureReservations.НомерРазмещения
//	|	WHERE
//	|		(RoomInventoryBalance.BedsVacantBalance > 0
//	|					AND (NOT &qShowReservedRooms)
//	|				OR (RoomInventoryBalance.BedsVacantBalance > 0
//	|					OR RoomInventoryBalance.BedsReservedBalance < 0)
//	|					AND &qShowReservedRooms)
//	|		AND (RoomInventoryBalance.НомерРазмещения.СтатусНомера IN (&qRoomStatuses)
//	|				OR &qIsEmptyRoomStatuses)) AS СвободныеНомера
//	|{WHERE
//	|	СвободныеНомера.Гостиница.* AS Гостиница,
//	|	СвободныеНомера.НомерРазмещения.* AS НомерРазмещения,
//	|	СвободныеНомера.ТипНомера.* AS ТипНомера,
//	|	СвободныеНомера.СтатусНомера.* AS СтатусНомера,
//	|	СвободныеНомера.ГруппаГостей.* AS ГруппаГостей,
//	|	СвободныеНомера.Клиент.* AS Клиент,
//	|	СвободныеНомера.GuestSex AS GuestSex,
//	|	СвободныеНомера.GuestCitizenship.* AS GuestCitizenship,
//	|	СвободныеНомера.Recorder.* AS Recorder,
//	|	СвободныеНомера.ДокОснование.* AS ДокОснование,
//	|	СвободныеНомера.CheckOutDate AS CheckOutDate,
//	|	СвободныеНомера.CheckInDate AS CheckInDate,
//	|	СвободныеНомера.RoomsVacantBalance AS RoomsVacantBalance,
//	|	СвободныеНомера.BedsVacantBalance AS BedsVacantBalance,
//	|	СвободныеНомера.GuestsVacantBalance AS GuestsVacantBalance,
//	|	СвободныеНомера.InHouseRoomsBalance AS InHouseRoomsBalance,
//	|	СвободныеНомера.InHouseBedsBalance AS InHouseBedsBalance,
//	|	СвободныеНомера.InHouseAdditionalBedsBalance AS InHouseAdditionalBedsBalance,
//	|	СвободныеНомера.InHouseGuestsBalance AS InHouseGuestsBalance}
//	|
//	|ORDER BY
//	|	Гостиница,
//	|	НомерРазмещения
//	|{ORDER BY
//	|	Гостиница.*,
//	|	НомерРазмещения.*,
//	|	СвободныеНомера.ТипНомера.*,
//	|	СтатусНомера.*,
//	|	ГруппаГостей.*,
//	|	Клиент.*,
//	|	GuestSex.*,
//	|	GuestCitizenship.*,
//	|	СвободныеНомера.Recorder.*,
//	|	СвободныеНомера.ДокОснование.*,
//	|	CheckOutDate,
//	|	CheckInDate,
//	|	RoomsVacantBalance,
//	|	BedsVacantBalance,
//	|	GuestsVacantBalance,
//	|	InHouseRoomsBalance,
//	|	InHouseBedsBalance,
//	|	InHouseAdditionalBedsBalance,
//	|	InHouseGuestsBalance}
//	|TOTALS
//	|	SUM(RoomsVacantBalance),
//	|	SUM(BedsVacantBalance),
//	|	SUM(GuestsVacantBalance),
//	|	SUM(InHouseRoomsBalance),
//	|	SUM(InHouseBedsBalance),
//	|	SUM(InHouseAdditionalBedsBalance),
//	|	SUM(InHouseGuestsBalance)
//	|BY
//	|	OVERALL,
//	|	Гостиница
//	|{TOTALS BY
//	|	Гостиница.*,
//	|	НомерРазмещения.*,
//	|	СвободныеНомера.ТипНомера.*,
//	|	СтатусНомера.*}";
//	ReportBuilder.Text = QueryText;
//	ReportBuilder.FillSettings();
//	
//	// Initialize report builder with default query
//	vRB = New ReportBuilder(QueryText);
//	vRBSettings = vRB.GetSettings(True, True, True, True, True);
//	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
//	
//	// Set default report builder header text
//	ReportBuilder.HeaderText = NStr("en='Vacant rooms';ru='Свободные номера';de='Freie Zimmer'");
//	
//	// Fill report builder fields presentations from the report template
//	cmFillReportAttributesPresentations(ThisObject);
//	
//	// Reset report builder template
//	ReportBuilder.Template = Неопределено;
//КонецПроцедуры //pmInitializeReportBuilder
//
////-----------------------------------------------------------------------------
//// Reports framework end
////-----------------------------------------------------------------------------
