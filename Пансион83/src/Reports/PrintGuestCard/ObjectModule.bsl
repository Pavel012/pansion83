////-----------------------------------------------------------------------------
//Процедура SetParameters(pGuestCard, pDocument)
//	// Document
//	pGuestCard.Parameters.mDocument = pDocument;
//	
//	// Guest
//	pGuestCard.Parameters.mGuest = pDocument.Клиент;
//	
//	// ГруппаНомеров
//	pGuestCard.Parameters.mRoom = pDocument.НомерРазмещения;
//	
//	If TypeOfPrintForm = 1 Тогда
//		// Guest group
//		If ЗначениеЗаполнено(pDocument.ГруппаГостей) Тогда
//			pGuestCard.Parameters.mGuestGroupCode = TrimAll(pDocument.ГруппаГостей.Code);
//		Else
//			pGuestCard.Parameters.mGuestGroupCode = "";
//		EndIf;
//		
//		// Guest check in and check out dates
//		pGuestCard.Parameters.mCheckInDate = Format(pDocument.CheckInDate, "DF=dd.MM.yyyy");
//		pGuestCard.Parameters.mCheckOutDate = Format(pDocument.CheckOutDate, "DF=dd.MM.yyyy");
//		pGuestCard.Parameters.mCheckInTime = Format(pDocument.CheckInDate, "DF=HH:mm; DE=00:00");
//		pGuestCard.Parameters.mFinalCheckOutDate = "";
//		
//		// ГруппаНомеров type
//		pGuestCard.Parameters.mRoomType = pDocument.ТипНомера;
//		
//		// ГруппаНомеров rate
//		pGuestCard.Parameters.mRoomRate = pDocument.Тариф;
//		
//		// Number of persons
//		pGuestCard.Parameters.mNumberOfPersons = pDocument.КоличествоЧеловек;
//		
//		// Rates
//		vRates = "";
//		If pDocument.НеПечататьТариф Тогда
//			If ЗначениеЗаполнено(pDocument.Тариф) Тогда
//				vRates = TrimAll(pDocument.Тариф.Code);
//			EndIf;
//		Else
//			vRates = pDocument.GetObject().pmCalculatePricePresentation();
//		EndIf;
//		pGuestCard.Parameters.mRates = vRates;
//		
//		// Deposit
//		pGuestCard.Parameters.mDeposit = "";
//		vDocList = New СписокЗначений();
//		vDocList.Add(pDocument);
//		vBalances = cmGetDocumentListBalances(vDocList, pDocument.Гостиница);
//		For Each vBalancesRow In vBalances Do
//			vDeposit = -vBalancesRow.ClientSumBalance + vBalancesRow.ClientLimitBalance;
//			pGuestCard.Parameters.mDeposit = pGuestCard.Parameters.mDeposit + cmFormatSum(vDeposit, vBalancesRow.ВалютаЛицСчета) + Chars.LF;
//		EndDo;
//		pGuestCard.Parameters.mDeposit = TrimAll(pGuestCard.Parameters.mDeposit);
//		
//		// Guest info
//		vGuestInfo = "";
//		If ЗначениеЗаполнено(pDocument.Клиент) Тогда
//			vGuestInfo = vGuestInfo + Upper(TrimAll(pDocument.Клиент.Фамилия) + " " + 
//			                                TrimAll(pDocument.Клиент.Имя) + " " + 
//			                                TrimAll(pDocument.Клиент.Отчество)) + Chars.LF;
//			vGuestInfo = vGuestInfo + "Адрес: '" +  cmGetAddressPresentation(pDocument.Клиент.Address) + Chars.LF;
//			vGuestInfo = vGuestInfo + "Паспорт: '" + 
//			                          TrimAll(pDocument.Клиент.IdentityDocumentSeries) + " " +
//			                          TrimAll(pDocument.Клиент.IdentityDocumentNumber);
//			If ЗначениеЗаполнено(pDocument.Клиент.IdentityDocumentIssueDate) Тогда
//				vGuestInfo = vGuestInfo + " выдан '" + Format(pDocument.Клиент.IdentityDocumentIssueDate, "DF=dd.MM.yy");
//			EndIf;
//			If НЕ IsBlankString(pDocument.Клиент.IdentityDocumentIssuedBy) Тогда
//				vGuestInfo = vGuestInfo + " " + TrimAll(pDocument.Клиент.IdentityDocumentIssuedBy);
//			EndIf;
//			vGuestInfo = vGuestInfo + Chars.LF;
//			If ЗначениеЗаполнено(pDocument.Контрагент) Тогда
//				vGuestInfo = vGuestInfo + "Компания: " + TrimAll(pDocument.Контрагент);
//			EndIf;
//		EndIf;
//		pGuestCard.Parameters.mGuestInfo = vGuestInfo;
//	EndIf;
//КонецПроцедуры //SetParameters
//	
////-----------------------------------------------------------------------------
//Процедура PrintGuestCard(pSpreadsheet, pGuestCard, pDocument, pPutPageBreak = False)
//	// New page
//	If pPutPageBreak Тогда
//		pSpreadsheet.PutHorizontalPageBreak();
//	EndIf;
//	
//	// Calculate and set parameters
//	SetParameters(pGuestCard, pDocument);
//	
//	// Put guest card
//	pSpreadsheet.Put(pGuestCard);
//КонецПроцедуры //PrintGuestCard
//
////-----------------------------------------------------------------------------
//Процедура PrintGuestCardsForCheckInDate(pSpreadsheet, pGuestCard)
//	vQry = New Query();
//	vQry.Text = 
//	"SELECT
//	|	Reservation.Ref AS Reservation
//	|FROM
//	|	Document.Reservation AS Reservation
//	|WHERE
//	|	Reservation.Posted
//	|	AND Reservation.ReservationStatus.IsActive
//	|	AND Reservation.CheckInDate >= &qBegOfDate
//	|	AND Reservation.CheckInDate <= &qEndOfDate
//	|
//	|ORDER BY
//	|	Reservation.CheckInDate,
//	|	Reservation.ГруппаГостей.Code,
//	|	Reservation.НомерРазмещения.ПорядокСортировки";
//	vQry.SetParameter("qBegOfDate", BegOfDay(CheckInDate));
//	vQry.SetParameter("qEndOfDate", EndOfDay(CheckInDate));
//	vReservations = vQry.Execute().Unload();
//	vIsFirstDoc = True;
//	For Each vRow In vReservations Do
//		If ЗначениеЗаполнено(vRow.Reservation) And ЗначениеЗаполнено(vRow.Reservation.ВидРазмещения) And 
//		   НЕ vRow.Reservation.ВидРазмещения.DoNotIssueKeyCards Тогда
//			PrintGuestCard(pSpreadsheet, pGuestCard, vRow.Reservation, НЕ vIsFirstDoc);
//			If vIsFirstDoc Тогда
//				vIsFirstDoc = False;
//			EndIf;
//		EndIf;
//	EndDo;
//КонецПроцедуры //PrintGuestCardsForCheckInDate
//
////-----------------------------------------------------------------------------
//Процедура PrintGuestCardsForGuestGroup(pSpreadsheet, pGuestCard)
//	If TypeOf(Document) = Type("DocumentRef.Reservation") Тогда
//		vReservations = GuestGroup.GetObject().pmGetReservations();
//		vIsFirstDoc = True;
//		For Each vRow In vReservations Do
//			If ЗначениеЗаполнено(vRow.Reservation) And ЗначениеЗаполнено(vRow.Reservation.ВидРазмещения) And 
//			   НЕ vRow.Reservation.ВидРазмещения.DoNotIssueKeyCards Тогда
//				PrintGuestCard(pSpreadsheet, pGuestCard, vRow.Reservation, НЕ vIsFirstDoc);
//				If vIsFirstDoc Тогда
//					vIsFirstDoc = False;
//				EndIf;
//			EndIf;
//		EndDo;
//	Else
//		vAccommodations = GuestGroup.GetObject().pmGetAccommodations();
//		vIsFirstDoc = True;
//		For Each vRow In vAccommodations Do
//			If ЗначениеЗаполнено(vRow.Размещение) And ЗначениеЗаполнено(vRow.Размещение.ВидРазмещения) And 
//			   НЕ vRow.Размещение.ВидРазмещения.DoNotIssueKeyCards Тогда
//				PrintGuestCard(pSpreadsheet, pGuestCard, vRow.Размещение, НЕ vIsFirstDoc);
//				If vIsFirstDoc Тогда
//					vIsFirstDoc = False;
//				EndIf;
//			EndIf;
//		EndDo;
//	EndIf;
//КонецПроцедуры //PrintGuestCardsForGuestGroup
//
////-----------------------------------------------------------------------------
//Процедура PrintGuestCardsForRoom(pSpreadsheet, pGuestCard)
//	If TypeOf(Document) = Type("DocumentRef.Reservation") Тогда
//		vReservations = New СписокЗначений();
//		vReservations.Add(Document);
//		AddOneRoomReservations(vReservations);
//		vIsFirstDoc = True;
//		For Each vDocItem In vReservations Do
//			If ЗначениеЗаполнено(vDocItem.Value) And ЗначениеЗаполнено(vDocItem.Value.ВидРазмещения) And 
//			   НЕ vDocItem.Value.ВидРазмещения.DoNotIssueKeyCards Тогда
//				PrintGuestCard(pSpreadsheet, pGuestCard, vDocItem.Value, НЕ vIsFirstDoc);
//				If vIsFirstDoc Тогда
//					vIsFirstDoc = False;
//				EndIf;
//			EndIf;
//		EndDo;
//	Else
//		vAccommodations = New СписокЗначений();
//		vAccommodations.Add(Document);
//		AddOneRoomAccommodations(vAccommodations);
//		vIsFirstDoc = True;
//		For Each vDocItem In vAccommodations Do
//			If ЗначениеЗаполнено(vDocItem.Value) And ЗначениеЗаполнено(vDocItem.Value.ВидРазмещения) And 
//			   НЕ vDocItem.Value.ВидРазмещения.DoNotIssueKeyCards Тогда
//				PrintGuestCard(pSpreadsheet, pGuestCard, vDocItem.Value, НЕ vIsFirstDoc);
//				If vIsFirstDoc Тогда
//					vIsFirstDoc = False;
//				EndIf;
//			EndIf;
//		EndDo;
//	EndIf;
//КонецПроцедуры //PrintGuestCardsForRoom
//
////-----------------------------------------------------------------------------
//Процедура AddOneRoomAccommodations(pDocsList)
//	vQry = New Query();
//	vQry.Text = 
//	"SELECT
//	|	Размещение.Ref
//	|FROM
//	|	Document.Размещение AS Размещение
//	|WHERE
//	|	Размещение.Ref <> &qDoc
//	|	AND Размещение.НомерРазмещения = &qRoom
//	|	AND Размещение.ГруппаГостей = &qGuestGroup
//	|	AND Размещение.CheckOutDate > &qCheckInDate
//	|	AND Размещение.Posted
//	|	AND Размещение.СтатусРазмещения.IsActive
//	|ORDER BY
//	|	Размещение.PointInTime";
//	vQry.SetParameter("qDoc", Document);
//	vQry.SetParameter("qRoom", Document.НомерРазмещения);
//	vQry.SetParameter("qGuestGroup", Document.ГруппаГостей);
//	vQry.SetParameter("qCheckInDate", Document.CheckInDate);
//	vQryRes = vQry.Execute().Unload();
//	For Each vQryResRow In vQryRes Do
//		pDocsList.Add(vQryResRow.Ref);
//	EndDo;
//КонецПроцедуры //AddOneRoomAccommodations 
//
////-----------------------------------------------------------------------------
//Процедура AddOneRoomReservations(pDocsList)
//	vQry = New Query();
//	vQry.Text = 
//	"SELECT
//	|	Reservations.Ref
//	|FROM
//	|	Document.Reservation AS Reservations
//	|WHERE
//	|	Reservations.Ref <> &qDoc
//	|	AND Reservations.НомерДока = &qDocNumber
//	|	AND Reservations.Posted
//	|	AND Reservations.ReservationStatus.IsActive
//	|ORDER BY
//	|	Reservations.PointInTime";
//	vQry.SetParameter("qDoc", Document);
//	vQry.SetParameter("qDocNumber", Document.НомерДока);
//	vQryRes = vQry.Execute().Unload();
//	For Each vQryResRow In vQryRes Do
//		pDocsList.Add(vQryResRow.Ref);
//	EndDo;
//КонецПроцедуры //AddOneRoomReservations
//
////-----------------------------------------------------------------------------
//Процедура FillHotelParameters(pGuestCard)
//	vHotel = ПараметрыСеанса.ТекущаяГостиница;
//	If ЗначениеЗаполнено(Document) Тогда
//		If ЗначениеЗаполнено(Document.Гостиница) Тогда
//			vHotel = Document.Гостиница;
//		EndIf;
//	ElsIf ЗначениеЗаполнено(GuestGroup) Тогда
//		If ЗначениеЗаполнено(ПараметрыСеанса.ТекущаяГостиница) Тогда
//			vHotel = ПараметрыСеанса.ТекущаяГостиница;
//		EndIf;
//	EndIf;
//	If ЗначениеЗаполнено(vHotel) Тогда
//		// Гостиница name
//		vHotelNameRU = vHotel.PrintNameTranslations;
//		If IsBlankString(vHotelNameRU) Тогда
//			vHotelNameRU = TrimAll(vHotel.PrintName);
//		EndIf;
//		If IsBlankString(vHotelNameRU) Тогда
//			vHotelNameRU = TrimAll(vHotel.LegacyName);
//		EndIf;
//		If IsBlankString(vHotelNameRU) Тогда
//			vHotelNameRU = TrimAll(vHotel.Description);
//		EndIf;
//		pGuestCard.Parameters.mHotelNameRU = Upper(vHotelNameRU);
//		
//		If TypeOfPrintForm = 1 Тогда
//			pGuestCard.Parameters.mHotelNameEN = Upper(vHotel.PrintNameTranslations);
//		EndIf;
//		
//		If TypeOfPrintForm = 2 Тогда
//			// Гостиница address
//			vHotelAddressRU = cmGetAddressPresentation(vHotel.PostAddressTranslations);
//			If IsBlankString(vHotelAddressRU) Тогда
//				vHotelAddressRU = TrimAll(cmGetAddressPresentation(vHotel.PostAddress));
//			EndIf;
//			pGuestCard.Parameters.mHotelAddressRU = vHotelAddressRU;
//		
//			// How to drive to the hotel
//			vHotelHowToDriveRU = vHotel.HowToDriveToTheHotelTranslations;
//			If IsBlankString(vHotelHowToDriveRU) Тогда
//				vHotelHowToDriveRU = TrimAll(vHotel.HowToDriveToTheHotel);
//			EndIf;
//			pGuestCard.Parameters.mHotelHowToDriveRU = vHotelHowToDriveRU;
//		
//			// Гостиница Телефоны
//			pGuestCard.Parameters.mHotelPhones = TrimAll(vHotel.Телефоны);
//		EndIf;
//		
//		If TypeOfPrintForm = 1 Тогда
//			// Reference hour
//			vDefaultRoomRate = vHotel.Тариф;
//			If ЗначениеЗаполнено(vDefaultRoomRate) Тогда
//				If vDefaultRoomRate.DurationCalculationRuleType = Перечисления.DurationCalculationRuleTypes.ByReferenceHour Тогда
//					pGuestCard.Parameters.mReferenceHourRU = "РАСЧЕТНЫЙ ЧАС " + Format(vDefaultRoomRate.ReferenceHour, "DF=HH:mm; DE=00:00") + "/";
//					pGuestCard.Parameters.mReferenceHourEN = "CHECK-OUT TIME " + Format(vDefaultRoomRate.ReferenceHour, "DF=HH:mm; DE=00:00");
//				Else
//					pGuestCard.Parameters.mReferenceHourRU = "";
//					pGuestCard.Parameters.mReferenceHourEN = "";
//				EndIf;
//			Else
//				pGuestCard.Parameters.mReferenceHourRU = "РАСЧЕТНЫЙ ЧАС 12:00/";
//				pGuestCard.Parameters.mReferenceHourEN = "CHECK-OUT TIME 12:00";
//			EndIf;
//		EndIf;
//	Else
//		pGuestCard.Parameters.mHotelNameRU = "";
//		If TypeOfPrintForm = 1 Тогда
//			pGuestCard.Parameters.mHotelNameEN = "";
//		EndIf;
//		If TypeOfPrintForm = 2 Тогда
//			pGuestCard.Parameters.mHotelAddressRU = "";
//			pGuestCard.Parameters.mHotelHowToDriveRU = "";
//			pGuestCard.Parameters.mHotelPhones = "";
//		EndIf;
//		If TypeOfPrintForm = 1 Тогда
//			pGuestCard.Parameters.mReferenceHourRU = "";
//			pGuestCard.Parameters.mReferenceHourEN = "";
//		EndIf;
//	EndIf;
//КонецПроцедуры //FillHotelParameters
//
////-----------------------------------------------------------------------------
//Процедура pmGenerate(pSpreadsheet, pTemplate = Неопределено) Экспорт
//	// Clear output spreadsheet
//	pSpreadsheet.Clear();
//	
//	// Choose template
//	vTemplate = ThisObject.GetTemplate(?(TypeOfPrintForm = 1, "FreeForm", "Form4G"));
//	If pTemplate <> Неопределено Тогда
//		vTemplate = pTemplate;
//	EndIf;
//	
//	// Guest card area
//	vGuestCard = vTemplate.GetArea("GuestCard");
//	
//	// Fill static parameters
//	FillHotelParameters(vGuestCard);
//	
//	// Call processings	
//	If ЗначениеЗаполнено(CheckInDate) Тогда
//		PrintGuestCardsForCheckInDate(pSpreadsheet, vGuestCard);
//	ElsIf ЗначениеЗаполнено(GuestGroup) Тогда
//		PrintGuestCardsForGuestGroup(pSpreadsheet, vGuestCard);
//	Else
//		PrintGuestCardsForRoom(pSpreadsheet, vGuestCard);
//	EndIf;
//КонецПроцедуры //pmGenerate
