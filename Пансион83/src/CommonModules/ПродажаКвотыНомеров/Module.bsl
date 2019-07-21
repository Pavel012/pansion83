//-----------------------------------------------------------------------------
// Description: Returns value table with all ГруппаНомеров quotas
// Parameters: ГруппаНомеров quotas folder where to search, Maximum number of rows to return
// Return value: Value table with ГруппаНомеров quotas
//-----------------------------------------------------------------------------
Function cmGetAllRoomQuotas(pRoomQuotaFolder = Неопределено, pTop = 0) Экспорт
	// Build and run query
	vQry = New Query;
	vQry.Text = 
	"SELECT " + ?(pTop = 0, "", "TOP " + pTop) + "
	|	КвотаНомеров.Ref AS КвотаНомеров
	|FROM
	|	Catalog.КвотаНомеров AS КвотаНомеров
	|WHERE 
	|	КвотаНомеров.IsFolder = FALSE AND " +
		?(ЗначениеЗаполнено(pRoomQuotaFolder), "КвотаНомеров.Ref IN HIERARCHY(&qRoomQuotaFolder) AND ", "") + "
	|	КвотаНомеров.DeletionMark = FALSE
	|ORDER BY КвотаНомеров.ПорядокСортировки";
	vQry.SetParameter("qRoomQuotaFolder", pRoomQuotaFolder);
	vList = vQry.Execute().Unload();
	Return vList;
EndFunction //cmGetAllRoomQuotas

//-----------------------------------------------------------------------------
// Description: Returns value table with all ГруппаНомеров quotas for rooms
// Parameters: ГруппаНомеров quotas folder where to search, Maximum number of rows to return
// Return value: Value table with ГруппаНомеров quotas
//-----------------------------------------------------------------------------
Function cmGetAllRoomQuotasForRooms(pRoomQuotaFolder = Неопределено, pTop = 0) Экспорт
	// Build and run query
	vQry = New Query;
	vQry.Text = 
	"SELECT " + ?(pTop = 0, "", "TOP " + pTop) + "
	|	КвотаНомеров.Ref AS КвотаНомеров
	|FROM
	|	Catalog.КвотаНомеров AS КвотаНомеров
	|WHERE 
	|	КвотаНомеров.IsFolder = FALSE AND 
	|	КвотаНомеров.IsQuotaForRooms = TRUE AND " +
		?(ЗначениеЗаполнено(pRoomQuotaFolder), "КвотаНомеров.Ref IN HIERARCHY(&qRoomQuotaFolder) AND ", "") + "
	|	КвотаНомеров.DeletionMark = FALSE
	|ORDER BY КвотаНомеров.ПорядокСортировки";
	vQry.SetParameter("qRoomQuotaFolder", pRoomQuotaFolder);
	vList = vQry.Execute().Unload();
	Return vList;
EndFunction //cmGetAllRoomQuotasForRooms

//-----------------------------------------------------------------------------
// Description: Checks if reservation or accommodation could be done in the given 
//              ГруппаНомеров quota
// Parameters: Agent, Контрагент, Contract, ГруппаНомеров quota, Гостиница, ГруппаНомеров type, ГруппаНомеров, 
//             Reservation or accommodation document, Whether current document is
//             posted or not, Whether current document is reservation or not, 
//             Resources to check, Period to check, Error text in russian language,
//             Error text in english language, Whether current user has permission 
//             to do ГруппаНомеров quota overbooking or not
// Return value: True if there are vacant rooms in ГруппаНомеров quota, False if not
//-----------------------------------------------------------------------------
Function cmCheckRoomQuotaAvailability(pAgent, pCustomer, pContract, pRoomQuota, pHotel, pRoomType, pRoom, pDoc, pIsPosted, pIsReservation, 
                                      pNumberOfRooms, pNumberOfBeds, pDateFrom, pDateTo, rMsgTextRu, rMsgTextEn, rMsgTextDe, 
									  pHavePermissionToDoRoomQuotaOverbooking = Неопределено) Экспорт
	// Initialize working variables
	vOK = True;
	vRoomsRemains = 0;
	vBedsRemains = 0;
	
	vRoomsInQuota = 0;
	vBedsInQuota = 0;
	
	// Check period
	If pDateFrom >= pDateTo Тогда
		Return vOK;
	EndIf;
	
	// Retrieve all necessary permissions
	vHavePermissionToDoRoomQuotaOverbooking = cmCheckUserPermissions("HavePermissionToDoRoomQuotaOverbooking");
	vHavePermissionToDoRoomQuotaOversales = cmCheckUserPermissions("HavePermissionToDoRoomQuotaOversales");
	
	// Take permissions from parameters
	If pHavePermissionToDoRoomQuotaOverbooking <> Неопределено Тогда
		vHavePermissionToDoRoomQuotaOverbooking = pHavePermissionToDoRoomQuotaOverbooking;
	EndIf;
	
	// Build and run query to check ГруппаНомеров quota sales
	vQry = New Query;
	vQry.Text = 
	"SELECT
	|	ПродажиКвот.КвотаНомеров.Агент AS Агент,
	|	ПродажиКвот.КвотаНомеров.Контрагент AS Контрагент,
	|	ПродажиКвот.КвотаНомеров.Договор AS Договор,
	|	ПродажиКвот.КвотаНомеров AS КвотаНомеров,
	|	ПродажиКвот.Гостиница AS Гостиница,
	|	ПродажиКвот.ТипНомера AS ТипНомера,
	|	ПродажиКвот.НомерРазмещения AS НомерРазмещения,
	|	MIN(ПродажиКвот.Period) AS Period,
	|	MIN(ПродажиКвот.CounterClosingBalance) AS CounterClosingBalance,
	|	MIN(ПродажиКвот.RoomsInQuotaClosingBalance) AS НомеровКвота,
	|	MIN(ПродажиКвот.BedsInQuotaClosingBalance) AS МестКвота,
	|	MIN(ПродажиКвот.RoomsRemainsClosingBalance) AS ОстаетсяНомеров,
	|	MIN(ПродажиКвот.BedsRemainsClosingBalance) AS ОстаетсяМест
	|FROM
	|	AccumulationRegister.ПродажиКвот.BalanceAndTurnovers(&qDateFrom, &qDateTo, 
	|	                                                        Second, 
	|	                                                        RegisterRecordsAndPeriodBoundaries, 
	|	                                                        КвотаНомеров.Агент = &qAgent AND 
	|	                                                        КвотаНомеров.Контрагент = &qCustomer AND 
	|	                                                        КвотаНомеров.Договор = &qContract AND 
	|	                                                        КвотаНомеров = &qRoomQuota AND 
	|	                                                        Гостиница = &qHotel AND 
	|	                                                        ТипНомера = &qRoomType" + 
																?((pRoomQuota.IsQuotaForRooms And ЗначениеЗаполнено(pRoom)), " AND НомерРазмещения = &qRoom", "") + "
	|) AS ПродажиКвот
	|
	|GROUP BY
	|	ПродажиКвот.КвотаНомеров,
	|	ПродажиКвот.КвотаНомеров.Агент,
	|	ПродажиКвот.КвотаНомеров.Контрагент,
	|	ПродажиКвот.КвотаНомеров.Договор,
	|	ПродажиКвот.Гостиница,
	|	ПродажиКвот.ТипНомера,
	|	ПродажиКвот.НомерРазмещения";
	
	vQry.SetParameter("qRoomQuota", pRoomQuota);
	vQry.SetParameter("qAgent", pAgent);
	vQry.SetParameter("qCustomer", pCustomer);
	vQry.SetParameter("qContract", pContract);
	vQry.SetParameter("qHotel", pHotel);
	vQry.SetParameter("qRoomType", pRoomType);
	vQry.SetParameter("qRoom", pRoom);
	vQry.SetParameter("qDateFrom", pDateFrom);
	vQry.SetParameter("qDateTo", New Boundary(pDateTo, BoundaryType.Excluding));
	
	vQryTab = vQry.Execute().Unload();
	
	vErrorPeriod = '00010101';
	For Each vQryTabRow In vQryTab Do
		If НЕ ЗначениеЗаполнено(vErrorPeriod) Тогда
			vErrorPeriod = vQryTabRow.Period;
		EndIf;
		
		vRoomsInQuota = vRoomsInQuota + vQryTabRow.RoomsInQuota;
		vBedsInQuota = vBedsInQuota + vQryTabRow.BedsInQuota;
		
		vRoomsRemains = vRoomsRemains + vQryTabRow.RoomsRemains;
		vBedsRemains = vBedsRemains + vQryTabRow.BedsRemains;
	EndDo;
	If ЗначениеЗаполнено(vErrorPeriod) Тогда
		vErrorPeriod = Max(vErrorPeriod, pDateFrom);
		vErrorPeriod = Min(vErrorPeriod, pDateTo);
	EndIf;
	
	// Check ГруппаНомеров quota rests
	vNotEnoughRooms = 0;
	vNotEnoughBeds = 0;
	If pIsPosted Тогда
		vNotEnoughRooms = -vRoomsRemains;
		vNotEnoughBeds = -vBedsRemains;
	Else
		vNotEnoughRooms = pNumberOfRooms - vRoomsRemains;
		vNotEnoughBeds = pNumberOfBeds - vBedsRemains;
	EndIf;
	
	If pNumberOfRooms > 0 Тогда
		If vNotEnoughRooms > 0 Тогда
			vMsgTextRu = "На " + Format(vErrorPeriod, "DF='dd.MM.yyyy HH:mm'") + " по выбранной квоте не хватает " + vNotEnoughRooms + " свободных номеров!";
			vMsgTextEn = "" + vNotEnoughRooms + " vacant НомернойФонд are not available for allotment choosen at " + Format(vErrorPeriod, "DF='dd.MM.yyyy HH:mm'") + "!";
			vMsgTextDe = "" + vNotEnoughRooms + " vacant НомернойФонд are not available for allotment choosen at " + Format(vErrorPeriod, "DF='dd.MM.yyyy HH:mm'") + "!";
			vMessage = NStr("ru = '" + СокрЛП(vMsgTextRu) + "';" + "en = '" + СокрЛП(vMsgTextEn) + "';" + "de = '" + СокрЛП(vMsgTextDe) + "';");
			If НЕ vHavePermissionToDoRoomQuotaOversales And НЕ pIsReservation Тогда
				WriteLogEvent(NStr("en='Allotments.NoVacantRooms';ru='Квоты.НетСвободныхНомеров';de='Quote.KeineFreienZimmer'"), EventLogLevel.Warning, pDoc.Metadata(), pDoc, vMessage);
				vOK = False;
				rMsgTextRu = rMsgTextRu + vMsgTextRu + Chars.LF;
				rMsgTextEn = rMsgTextEn + vMsgTextEn + Chars.LF;
				rMsgTextDe = rMsgTextDe + vMsgTextDe + Chars.LF;
			ElsIf НЕ vHavePermissionToDoRoomQuotaOverbooking And pIsReservation Тогда
				WriteLogEvent(NStr("en='Allotments.NoVacantRooms';ru='Квоты.НетСвободныхНомеров';de='Quote.KeineFreienZimmer'"), EventLogLevel.Warning, pDoc.Metadata(), pDoc, vMessage);
				vOK = False;
				rMsgTextRu = rMsgTextRu + vMsgTextRu + Chars.LF;
				rMsgTextEn = rMsgTextEn + vMsgTextEn + Chars.LF;
				rMsgTextDe = rMsgTextDe + vMsgTextDe + Chars.LF;
			ElsIf pRoomQuota.OverbookingIsNotAllowed Тогда
				WriteLogEvent(NStr("en='Allotments.NoVacantRooms';ru='Квоты.НетСвободныхНомеров';de='Quote.KeineFreienZimmer'"), EventLogLevel.Warning, pDoc.Metadata(), pDoc, vMessage);
				vOK = False;
				rMsgTextRu = rMsgTextRu + vMsgTextRu + Chars.LF;
				rMsgTextEn = rMsgTextEn + vMsgTextEn + Chars.LF;
				rMsgTextDe = rMsgTextDe + vMsgTextDe + Chars.LF;
			Else
				WriteLogEvent(NStr("en='Allotments.NoVacantRooms';ru='Квоты.НетСвободныхНомеров';de='Quote.KeineFreienZimmer'"), EventLogLevel.Warning, pDoc.Metadata(), pDoc, vMessage);
				If cmShowNotEnoughRoomsMessages() Тогда
					Message(cmGetMessageHeader(pDoc) + vMessage, MessageStatus.Attention);
				EndIf;
			EndIf;
		ElsIf vNotEnoughBeds > 0 Тогда
			vMsgTextRu = "На " + Format(vErrorPeriod, "DF='dd.MM.yyyy HH:mm'") + " по выбранной квоте не хватает " + vNotEnoughBeds + " свободных мест!";
			vMsgTextEn = "" + vNotEnoughBeds + " vacant beds are not available for allotment choosen at " + Format(vErrorPeriod, "DF='dd.MM.yyyy HH:mm'") + "!";
			vMsgTextDe = "" + vNotEnoughBeds + " vacant beds are not available for allotment choosen at " + Format(vErrorPeriod, "DF='dd.MM.yyyy HH:mm'") + "!";
			vMessage = NStr("ru = '" + СокрЛП(vMsgTextRu) + "';" + "en = '" + СокрЛП(vMsgTextEn) + "';" + "de = '" + СокрЛП(vMsgTextDe) + "';");
			If НЕ vHavePermissionToDoRoomQuotaOversales And НЕ pIsReservation Тогда
				WriteLogEvent(NStr("en='Allotments.NoVacantRooms';ru='Квоты.НетСвободныхНомеров';de='Quote.KeineFreienZimmer'"), EventLogLevel.Warning, pDoc.Metadata(), pDoc, vMessage);
				vOK = False;
				rMsgTextRu = rMsgTextRu + vMsgTextRu + Chars.LF;
				rMsgTextEn = rMsgTextEn + vMsgTextEn + Chars.LF;
				rMsgTextDe = rMsgTextDe + vMsgTextDe + Chars.LF;
			ElsIf НЕ vHavePermissionToDoRoomQuotaOverbooking And pIsReservation Тогда
				WriteLogEvent(NStr("en='Allotments.NoVacantRooms';ru='Квоты.НетСвободныхНомеров';de='Quote.KeineFreienZimmer'"), EventLogLevel.Warning, pDoc.Metadata(), pDoc, vMessage);
				vOK = False;
				rMsgTextRu = rMsgTextRu + vMsgTextRu + Chars.LF;
				rMsgTextEn = rMsgTextEn + vMsgTextEn + Chars.LF;
				rMsgTextDe = rMsgTextDe + vMsgTextDe + Chars.LF;
			ElsIf pRoomQuota.OverbookingIsNotAllowed Тогда
				WriteLogEvent(NStr("en='Allotments.NoVacantRooms';ru='Квоты.НетСвободныхНомеров';de='Quote.KeineFreienZimmer'"), EventLogLevel.Warning, pDoc.Metadata(), pDoc, vMessage);
				vOK = False;
				rMsgTextRu = rMsgTextRu + vMsgTextRu + Chars.LF;
				rMsgTextEn = rMsgTextEn + vMsgTextEn + Chars.LF;
				rMsgTextDe = rMsgTextDe + vMsgTextDe + Chars.LF;
			Else
				WriteLogEvent(NStr("en='Allotments.NoVacantRooms';ru='Квоты.НетСвободныхНомеров';de='Quote.KeineFreienZimmer'"), EventLogLevel.Warning, pDoc.Metadata(), pDoc, vMessage);
				If cmShowNotEnoughRoomsMessages() Тогда
					Message(cmGetMessageHeader(pDoc) + vMessage, MessageStatus.Attention);
				EndIf;
			EndIf;
		EndIf;
	ElsIf vNotEnoughBeds > 0 Тогда
		vMsgTextRu = "На " + Format(vErrorPeriod, "DF='dd.MM.yyyy HH:mm'") + " по выбранной квоте не хватает " + vNotEnoughBeds + " свободных мест!";
		vMsgTextEn = "" + vNotEnoughBeds + " vacant beds are not available for allotment choosen at " + Format(vErrorPeriod, "DF='dd.MM.yyyy HH:mm'") + "!";
		vMsgTextDe = "" + vNotEnoughBeds + " vacant beds are not available for allotment choosen at " + Format(vErrorPeriod, "DF='dd.MM.yyyy HH:mm'") + "!";
		vMessage = NStr("ru = '" + СокрЛП(vMsgTextRu) + "';" + "en = '" + СокрЛП(vMsgTextEn) + "';" + "de = '" + СокрЛП(vMsgTextDe) + "';");
		If НЕ vHavePermissionToDoRoomQuotaOversales And НЕ pIsReservation Тогда
			WriteLogEvent(NStr("en='Allotments.NoVacantRooms';ru='Квоты.НетСвободныхНомеров';de='Quote.KeineFreienZimmer'"), EventLogLevel.Warning, pDoc.Metadata(), pDoc, vMessage);
			vOK = False;
			rMsgTextRu = rMsgTextRu + vMsgTextRu + Chars.LF;
			rMsgTextEn = rMsgTextEn + vMsgTextEn + Chars.LF;
			rMsgTextDe = rMsgTextDe + vMsgTextDe + Chars.LF;
		ElsIf НЕ vHavePermissionToDoRoomQuotaOverbooking And pIsReservation Тогда
			WriteLogEvent(NStr("en='Allotments.NoVacantRooms';ru='Квоты.НетСвободныхНомеров';de='Quote.KeineFreienZimmer'"), EventLogLevel.Warning, pDoc.Metadata(), pDoc, vMessage);
			vOK = False;
			rMsgTextRu = rMsgTextRu + vMsgTextRu + Chars.LF;
			rMsgTextEn = rMsgTextEn + vMsgTextEn + Chars.LF;
			rMsgTextDe = rMsgTextDe + vMsgTextDe + Chars.LF;
		ElsIf pRoomQuota.OverbookingIsNotAllowed Тогда
			WriteLogEvent(NStr("en='Allotments.NoVacantRooms';ru='Квоты.НетСвободныхНомеров';de='Quote.KeineFreienZimmer'"), EventLogLevel.Warning, pDoc.Metadata(), pDoc, vMessage);
			vOK = False;
			rMsgTextRu = rMsgTextRu + vMsgTextRu + Chars.LF;
			rMsgTextEn = rMsgTextEn + vMsgTextEn + Chars.LF;
			rMsgTextDe = rMsgTextDe + vMsgTextDe + Chars.LF;
		Else
			WriteLogEvent(NStr("en='Allotments.NoVacantRooms';ru='Квоты.НетСвободныхНомеров';de='Quote.KeineFreienZimmer'"), EventLogLevel.Warning, pDoc.Metadata(), pDoc, vMessage);
			If cmShowNotEnoughRoomsMessages() Тогда
				Message(cmGetMessageHeader(pDoc) + vMessage, MessageStatus.Attention);
			EndIf;
		EndIf;
	EndIf;
	
	// OK
	Return vOK;
EndFunction //cmCheckRoomQuotaAvailability

//-----------------------------------------------------------------------------
// Description: Returns value table with ГруппаНомеров quota available resources 
// Parameters: ГруппаНомеров quota, Agent, Контрагент, Contract, Гостиница, ГруппаНомеров type, ГруппаНомеров, 
//             Period from, Period to
// Return value: Value table with vacant ГруппаНомеров quota rooms by ГруппаНомеров types
//-----------------------------------------------------------------------------
Function cmCalculateRoomQuotaResources(pRoomQuota, pAgent, pCustomer, pContract, pHotel, pRoomType, pRoom, pDateFrom, pDateTo) Экспорт
	
	// Build and run query to check ГруппаНомеров quota sales
	vQry = New Query;
	vQry.Text = 
	"SELECT
	|	ПродажиКвот.КвотаНомеров.Агент AS Агент,
	|	ПродажиКвот.КвотаНомеров.Контрагент AS Контрагент,
	|	ПродажиКвот.КвотаНомеров.Договор AS Договор,
	|	ПродажиКвот.КвотаНомеров AS КвотаНомеров,
	|	ПродажиКвот.Гостиница AS Гостиница,
	|	ПродажиКвот.ТипНомера AS ТипНомера, " + ?((pRoomQuota.IsQuotaForRooms And ЗначениеЗаполнено(pRoom)), "ПродажиКвот.НомерРазмещения AS НомерРазмещения, ", "") + "
	|	MIN(ПродажиКвот.CounterClosingBalance) AS CounterClosingBalance,
	|	MIN(ПродажиКвот.RoomsInQuotaClosingBalance) AS НомеровКвота,
	|	MIN(ПродажиКвот.BedsInQuotaClosingBalance) AS МестКвота,
	|	MIN(ПродажиКвот.RoomsReservedClosingBalance) AS ЗабронНомеров,
	|	MIN(ПродажиКвот.BedsReservedClosingBalance) AS ЗабронированоМест,
	|	MIN(ПродажиКвот.InHouseRoomsClosingBalance) AS ИспользованоНомеров,
	|	MIN(ПродажиКвот.InHouseBedsClosingBalance) AS ИспользованоМест,
	|	MIN(ПродажиКвот.RoomsRemainsClosingBalance) AS ОстаетсяНомеров,
	|	MIN(ПродажиКвот.BedsRemainsClosingBalance) AS ОстаетсяМест
	|
	|FROM
	|	AccumulationRegister.ПродажиКвот.BalanceAndTurnovers(&qDateFrom, &qDateTo, 
	|	                                                        Second, 
	|	                                                        RegisterRecordsAndPeriodBoundaries, 
	|	                                                        КвотаНомеров.Агент = &qAgent AND 
	|	                                                        КвотаНомеров.Контрагент = &qCustomer AND 
	|	                                                        КвотаНомеров.Договор = &qContract AND 
	|	                                                        КвотаНомеров = &qRoomQuota AND 
	|	                                                        Гостиница = &qHotel AND 
	|	                                                        ТипНомера = &qRoomType" +
																?((pRoomQuota.IsQuotaForRooms And ЗначениеЗаполнено(pRoom)), " AND НомерРазмещения = &qRoom", "") + "
	|) AS ПродажиКвот
	|
	|GROUP BY
	|	ПродажиКвот.КвотаНомеров,
	|	ПродажиКвот.КвотаНомеров.Агент,
	|	ПродажиКвот.КвотаНомеров.Контрагент,
	|	ПродажиКвот.КвотаНомеров.Договор,
	|	ПродажиКвот.Гостиница,
	|	ПродажиКвот.ТипНомера" + ?((pRoomQuota.IsQuotaForRooms And ЗначениеЗаполнено(pRoom)), ", ПродажиКвот.НомерРазмещения", "");
	
	vQry.SetParameter("qRoomQuota", pRoomQuota);
	vQry.SetParameter("qAgent", pAgent);
	vQry.SetParameter("qCustomer", pCustomer);
	vQry.SetParameter("qContract", pContract);
	vQry.SetParameter("qHotel", pHotel);
	vQry.SetParameter("qRoomType", pRoomType);
	vQry.SetParameter("qRoom", pRoom);
	vQry.SetParameter("qDateFrom", pDateFrom);
	vQry.SetParameter("qDateTo", New Boundary(pDateTo, BoundaryType.Excluding));
	
	vQryTab = vQry.Execute().Unload();
	
	Return vQryTab;
EndFunction //cmCalculateRoomQuotaResources

//-----------------------------------------------------------------------------
// Description: Returns value table with set ГруппаНомеров quota documents active for the
//              given filters and period
// Parameters: Гостиница, Period from, Period to, ГруппаНомеров type, Agent, Контрагент, Contract, 
//             Whether to return documents with empty contract or not
// Return value: Value table with documents
//-----------------------------------------------------------------------------
Function cmGetRoomQuotaDocuments(pHotel, pCheckInDate, pCheckOutDate, pRoomType, 
                                 pAgent, pCustomer, pContract, pShowNoContract = False) Экспорт
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	СоставКвоты.Ref AS СоставКвоты
	|FROM
	|	Document.СоставКвоты AS СоставКвоты
	|WHERE СоставКвоты.Posted" + 
		?(ЗначениеЗаполнено(pHotel), " AND СоставКвоты.Гостиница = &qHotel ", "") + 
		?(ЗначениеЗаполнено(pCheckOutDate), " AND СоставКвоты.ДатаНачКвоты < &qCheckOutDate ", "") + 
		?(ЗначениеЗаполнено(pCheckInDate), " AND СоставКвоты.ДатаКонКвоты > &qCheckInDate ", "") + 
		?(ЗначениеЗаполнено(pRoomType), " AND СоставКвоты.ТипНомера = &qRoomType ", "") + 
		?(ЗначениеЗаполнено(pAgent), " AND СоставКвоты.КвотаНомеров.Агент = &qAgent ", "") + 
		?(ЗначениеЗаполнено(pCustomer), " AND СоставКвоты.КвотаНомеров.Контрагент = &qCustomer ", "") + 
		?(pShowNoContract, ?(ЗначениеЗаполнено(pContract), " AND (СоставКвоты.КвотаНомеров.Договор = &qContract OR СоставКвоты.КвотаНомеров.Договор = &qEmptyContract) ", ""), 
		                   ?(ЗначениеЗаполнено(pContract), " AND СоставКвоты.КвотаНомеров.Договор = &qContract ", "")) + "
	|ORDER BY
	|	СоставКвоты.PointInTime";
	vQry.SetParameter("qHotel", pHotel);
	vQry.SetParameter("qCheckInDate", pCheckInDate);
	vQry.SetParameter("qCheckOutDate", pCheckOutDate);
	vQry.SetParameter("qRoomType", pRoomType);
	vQry.SetParameter("qAgent", pAgent);
	vQry.SetParameter("qCustomer", pCustomer);
	vQry.SetParameter("qContract", pContract);
	If pShowNoContract Тогда
		vQry.SetParameter("qEmptyContract", Справочники.Contracts.EmptyRef());
	EndIf;
	vDocs = vQry.Execute().Unload();
	
	Return vDocs;
EndFunction //cmGetRoomQuotaDocuments

//-----------------------------------------------------------------------------
// Description: Calculates resources to write off from the ГруппаНомеров quota vacat rooms 
//              for the given reservation document based on number of guets being 
//              checked-in already
// Parameters: Reservation document, ГруппаНомеров quota, Гостиница, ГруппаНомеров type, ГруппаНомеров, 
//             Period from, Period to
// Return value: Value table with resources to write off
//-----------------------------------------------------------------------------
Function cmGetDocumentRoomQuotaWriteOffs(pDoc, pRoomQuota, pHotel, pRoomType, pRoom, pDateFrom, pDateTo) Экспорт
	
	// Build and run query to check ГруппаНомеров quota sales
	vQry = New Query;
	vQry.Text = 
	"SELECT
	|	ЗагрузкаНомеров.Recorder,
	|	-SUM(ЗагрузкаНомеров.НомеровКвота) AS RoomsWrittenOff,
	|	-SUM(ЗагрузкаНомеров.МестКвота) AS BedsWrittenOff
	|FROM
	|	AccumulationRegister.ЗагрузкаНомеров AS ЗагрузкаНомеров
	|WHERE
	|	ЗагрузкаНомеров.IsRoomQuota
	|	AND ЗагрузкаНомеров.CheckInDate < &qDateTo
	|	AND ЗагрузкаНомеров.ДатаВыезда > &qDateFrom
	|	AND ЗагрузкаНомеров.RecordType = &qExpense
	|	AND ЗагрузкаНомеров.Recorder = &qDoc
	|	AND ЗагрузкаНомеров.КвотаНомеров = &qRoomQuota
	|	AND ЗагрузкаНомеров.Гостиница = &qHotel
	|	AND ЗагрузкаНомеров.ТипНомера = &qRoomType" + 
		?(pRoomQuota.IsQuotaForRooms, " AND ЗагрузкаНомеров.НомерРазмещения = &qRoom", "") + "
	|GROUP BY
	|	ЗагрузкаНомеров.Recorder";
	
	vQry.SetParameter("qRoomQuota", pRoomQuota);
	vQry.SetParameter("qHotel", pHotel);
	vQry.SetParameter("qRoomType", pRoomType);
	vQry.SetParameter("qRoom", pRoom);
	vQry.SetParameter("qDateFrom", pDateFrom);
	vQry.SetParameter("qDateTo", pDateTo);
	vQry.SetParameter("qDoc", pDoc);
	vQry.SetParameter("qExpense", AccumulationRecordType.Expense);
	
	vQryTab = vQry.Execute().Unload();
	
	Return vQryTab;
EndFunction //cmGetDocumentRoomQuotaWriteOffs

//-----------------------------------------------------------------------------
// Description: Returns value table of ГруппаНомеров quotas for the given ГруппаНомеров type and
//              ГруппаНомеров
// Parameters: Гостиница, ГруппаНомеров type, ГруппаНомеров, Period from, Period to
// Return value: Value table with ГруппаНомеров quotas and vacant ГруппаНомеров resources
//-----------------------------------------------------------------------------
Function cmGetRoomQuotasForRoom(pHotel, pRoomType, pRoom, pDateFrom, pDateTo) Экспорт
	
	// Build and run query to find ГруппаНомеров quotas for the ГруппаНомеров given
	vQry = New Query;
	vQry.Text = 
	"SELECT
	|	ПродажиКвот.КвотаНомеров AS КвотаНомеров,
	|	ПродажиКвот.Гостиница AS Гостиница,
	|	ПродажиКвот.ТипНомера AS ТипНомера,
	|	ПродажиКвот.НомерРазмещения AS НомерРазмещения,
	|	MIN(ПродажиКвот.CounterClosingBalance) AS CounterClosingBalance,
	|	MIN(ПродажиКвот.RoomsInQuotaClosingBalance) AS НомеровКвота,
	|	MIN(ПродажиКвот.BedsInQuotaClosingBalance) AS МестКвота,
	|	MIN(ПродажиКвот.RoomsReservedClosingBalance) AS ЗабронНомеров,
	|	MIN(ПродажиКвот.BedsReservedClosingBalance) AS ЗабронированоМест,
	|	MIN(ПродажиКвот.InHouseRoomsClosingBalance) AS ИспользованоНомеров,
	|	MIN(ПродажиКвот.InHouseBedsClosingBalance) AS ИспользованоМест,
	|	MIN(ПродажиКвот.RoomsRemainsClosingBalance) AS ОстаетсяНомеров,
	|	MIN(ПродажиКвот.BedsRemainsClosingBalance) AS ОстаетсяМест
	|FROM
	|	AccumulationRegister.ПродажиКвот.BalanceAndTurnovers(
	|			&qDateFrom,
	|			&qDateTo,
	|			Second,
	|			RegisterRecordsAndPeriodBoundaries,
	|			Гостиница = &qHotel
	|				AND ТипНомера = &qRoomType
	|				AND КвотаНомеров.IsQuotaForRooms
	|				AND НомерРазмещения = &qRoom) AS ПродажиКвот
	|
	|GROUP BY
	|	ПродажиКвот.КвотаНомеров,
	|	ПродажиКвот.Гостиница,
	|	ПродажиКвот.ТипНомера,
	|	ПродажиКвот.НомерРазмещения";
	
	vQry.SetParameter("qHotel", pHotel);
	vQry.SetParameter("qRoomType", pRoomType);
	vQry.SetParameter("qRoom", pRoom);
	vQry.SetParameter("qDateFrom", pDateFrom);
	vQry.SetParameter("qDateTo", New Boundary(pDateTo, BoundaryType.Excluding));
	
	vQryTab = vQry.Execute().Unload();
	
	Return vQryTab;
EndFunction //cmGetRoomQuotasForRoom
