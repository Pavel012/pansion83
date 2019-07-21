////-----------------------------------------------------------------------------
//Процедура SetParameters(pGuestForm, pDocument)
//	// Document
//	pGuestForm.Parameters.mDocument = pDocument;
//	If TypeOfPrintForm <> 3 Тогда
//		pGuestForm.Parameters.mDocumentNumber = TrimAll(pDocument.НомерДока);
//	EndIf;
//	
//	// Guest
//	pGuestForm.Parameters.mGuest = pDocument.Клиент;
//	
//	If ЗначениеЗаполнено(pDocument.Клиент) Тогда
//		vGuest = pDocument.Клиент;
//		
//		// Guest names
//		pGuestForm.Parameters.mGuestLastName = Upper(TrimAll(vGuest.Фамилия));
//		pGuestForm.Parameters.mGuestFirstName = Upper(TrimAll(vGuest.Имя));
//		pGuestForm.Parameters.mGuestSecondName = Upper(TrimAll(vGuest.Отчество));
//		
//		// Guest birth date
//		If TypeOfPrintForm = 3 Тогда
//			vGuestDateOfBirth = Upper(Format(vGuest.ДатаРождения, "L=ru_RU; DLF=DD"));
//			If vGuestDateOfBirth <> "" Тогда
//				vGuestDateOfBirth = Left(vGuestDateOfBirth, StrLen(vGuestDateOfBirth) - 3);
//			EndIf;
//			pGuestForm.Parameters.mGuestDateOfBirth = vGuestDateOfBirth;
//		Else
//			pGuestForm.Parameters.mGuestDateOfBirth = Format(vGuest.ДатаРождения, "DF=dd.MM.yyyy");
//		EndIf;
//		
//		// Guest place of birth
//		vPlaceOfBirth = cmParseAddress(vGuest.PlaceOfBirth);
//		If TypeOfPrintForm = 1 Тогда
//			// Guest address
//			vGuestAddress = cmParseAddress(vGuest.Address);
//			pGuestForm.Parameters.mGuestCountry = Upper(String(vGuestAddress.Country));
//			pGuestForm.Parameters.mGuestAddress = cmGetAddressPresentation(vGuest.Address);
//			pGuestForm.Parameters.mGuestAddress = TrimAll(StrReplace(pGuestForm.Parameters.mGuestAddress, String(vGuestAddress.Country) + ",", ""));
//		ElsIf TypeOfPrintForm = 2 Тогда
//			// Guest birth place
//			pGuestForm.Parameters.mGuestBirthPlaceRegion = Upper(TrimAll(vPlaceOfBirth.Region));
//			pGuestForm.Parameters.mGuestBirthPlaceArea = Upper(TrimAll(vPlaceOfBirth.Area));
//			pGuestForm.Parameters.mGuestBirthPlaceCity = Upper(TrimAll(vPlaceOfBirth.City));
//			
//			// Guest address
//			vGuestAddress = cmParseAddress(vGuest.Address);
//			pGuestForm.Parameters.mGuestCountry = Upper(String(vGuestAddress.Country));
//			pGuestForm.Parameters.mGuestAddress = cmGetAddressPresentation(vGuest.Address);
//			pGuestForm.Parameters.mGuestAddress = TrimAll(StrReplace(pGuestForm.Parameters.mGuestAddress, String(vGuestAddress.Country) + ",", ""));
//			
//			// Trip purpose
//			pGuestForm.Parameters.mTripPurpose = Upper(String(pDocument.TripPurpose));
//		ElsIf TypeOfPrintForm = 3 Тогда
//			// Guest birth place
//			pGuestForm.Parameters.mGuestBirthPlaceCountry = Upper(TrimAll(vPlaceOfBirth.Country));
//			pGuestForm.Parameters.mGuestBirthPlaceRegion = Upper(TrimAll(vPlaceOfBirth.Region));
//			pGuestForm.Parameters.mGuestBirthPlaceArea = Upper(TrimAll(vPlaceOfBirth.Area));
//			vCity = Upper(TrimAll(vPlaceOfBirth.City));
//			If Find(vCity, "Г.") > 0 Тогда
//				pGuestForm.Parameters.mGuestBirthPlaceCity = vCity;
//				pGuestForm.Parameters.mGuestBirthPlaceTown = "";
//			ElsIf Right(vCity, 2) = " Г" Тогда
//				pGuestForm.Parameters.mGuestBirthPlaceCity = vCity;
//				pGuestForm.Parameters.mGuestBirthPlaceTown = "";
//			ElsIf Left(vCity, 2) = "Г " Тогда
//				pGuestForm.Parameters.mGuestBirthPlaceCity = vCity;
//				pGuestForm.Parameters.mGuestBirthPlaceTown = "";
//			Else
//				pGuestForm.Parameters.mGuestBirthPlaceCity = "";
//				pGuestForm.Parameters.mGuestBirthPlaceTown = vCity;
//			EndIf;
//			
//			// Guest address
//			vGuestAddress = cmParseAddress(vGuest.Address);
//			vGuestAddress.Street = StrReplace(vGuestAddress.Street, " ул.", "");
//			vGuestAddress.Street = StrReplace(vGuestAddress.Street, " ул", "");
//			pGuestForm.Parameters.mGuestCitizenship = Upper(String(vGuest.Гражданство));
//			pGuestForm.Parameters.mGuestCountry = Upper(String(vGuestAddress.Country));
//			pGuestForm.Parameters.mGuestRegion  = Upper(String(vGuestAddress.Region));
//			pGuestForm.Parameters.mGuestArea = Upper(String(vGuestAddress.Area));
//			vCity = Upper(TrimAll(vGuestAddress.City)); 
//			If Find(vCity, "Г.") > 0 Тогда
//				pGuestForm.Parameters.mGuestCity = vCity;
//				pGuestForm.Parameters.mGuestTown = "";
//			ElsIf Right(vCity, 2) = " Г" Тогда
//				pGuestForm.Parameters.mGuestCity = vCity;
//				pGuestForm.Parameters.mGuestTown = "";
//			ElsIf Left(vCity, 2) = "Г " Тогда
//				pGuestForm.Parameters.mGuestCity = vCity;
//				pGuestForm.Parameters.mGuestTown = "";
//			Else
//				pGuestForm.Parameters.mGuestCity = "";
//				pGuestForm.Parameters.mGuestTown = vCity;
//			EndIf;
//			pGuestForm.Parameters.mGuestStreet = Upper(String(vGuestAddress.Street));
//			pGuestForm.Parameters.mGuestHouse = Upper(vGuestAddress.House);
//			pGuestForm.Parameters.mGuestApt = Upper(vGuestAddress.Flat);
//		    pGuestForm.Parameters.mGuestSex = Left(vGuest.Пол,3);
//		EndIf;
//		
//		// Guest identity document data
//		If TypeOfPrintForm = 3 Тогда
//			pGuestForm.Parameters.mGuestIDType = Upper(TrimAll(vGuest.IdentityDocumentType));
//			pGuestForm.Parameters.mGuestIDIssueDate = StrReplace(Upper(Format(vGuest.IdentityDocumentIssueDate, "L=ru_RU; DLF=DD")), "Г.", "г.");
//		Else
//			pGuestForm.Parameters.mGuestIDIssueDate = Format(vGuest.IdentityDocumentIssueDate, "DF=dd.MM.yyyy");
//		EndIf;
//		pGuestForm.Parameters.mGuestIDSeries = TrimAll(vGuest.IdentityDocumentSeries);
//		pGuestForm.Parameters.mGuestIDNumber = TrimAll(vGuest.IdentityDocumentNumber);
//		If TypeOfPrintForm = 3 Тогда
//			pGuestForm.Parameters.mGuestIDUnitCode = TrimAll(vGuest.IdentityDocumentUnitCode);
//			vPos = 35;
//			If StrLen(TrimAll(vGuest.IdentityDocumentIssuedBy)) > 35 Тогда
//				While vPos > 1 Do
//					If Mid(TrimAll(vGuest.IdentityDocumentIssuedBy), vPos, 1) = " " Тогда
//						Break;
//					Else
//						vPos = vPos - 1;
//					EndIf;
//				EndDo;
//			EndIf;
//			pGuestForm.Parameters.mGuestIDIssuedBy = TrimAll(Left(TrimAll(vGuest.IdentityDocumentIssuedBy), vPos));
//			pGuestForm.Parameters.mGuestIDIssuedBy2 = TrimAll(Mid(TrimAll(vGuest.IdentityDocumentIssuedBy), vPos + 1));
//		Else
//			pGuestForm.Parameters.mGuestIDIssuedBy = TrimAll(?(IsBlankString(TrimAll(vGuest.IdentityDocumentUnitCode)), "", TrimAll(vGuest.IdentityDocumentUnitCode) + " ") + TrimAll(vGuest.IdentityDocumentIssuedBy));
//		EndIf;
//		
//		// Guest identification cards
//		If TypeOfPrintForm = 1 Тогда
//			vClientCards = cmGetClientIdentificationCardsByParentDoc(pDocument);
//			If vClientCards.Count() > 0 Тогда
//				pGuestForm.Parameters.mClientIdentificationCardsLabel = "Карты гостя/Клиент cards:";
//				For Each vClientCardsRow In vClientCards Do
//					If vClientCards.Indexof(vClientCardsRow) = 0 Тогда
//						pGuestForm.Parameters.mClientIdentificationCards = TrimAll(vClientCardsRow.Ref.Identifier);
//					Else
//						pGuestForm.Parameters.mClientIdentificationCards = pGuestForm.Parameters.mClientIdentificationCards + ", " + TrimAll(vClientCardsRow.Ref.Identifier);
//					EndIf;
//				EndDo;
//			Else
//				pGuestForm.Parameters.mClientIdentificationCardsLabel = "";
//				pGuestForm.Parameters.mClientIdentificationCards = "";
//			EndIf;
//		EndIf;
//	Else
//		// Guest names
//		pGuestForm.Parameters.mGuestLastName = "";
//		pGuestForm.Parameters.mGuestFirstName = "";
//		pGuestForm.Parameters.mGuestSecondName = "";
//		
//		// Guest birth date
//		pGuestForm.Parameters.mGuestDateOfBirth = "";
//		
//		If TypeOfPrintForm = 1 Тогда
//			// Guest address
//			pGuestForm.Parameters.mGuestCountry = "";
//			pGuestForm.Parameters.mGuestAddress = "";
//		ElsIf TypeOfPrintForm = 2 Тогда
//			// Guest address
//			pGuestForm.Parameters.mGuestCountry = "";
//			pGuestForm.Parameters.mGuestAddress = "";
//			
//			// Guest place of birth
//			pGuestForm.Parameters.mGuestBirthPlaceRegion = "";
//			pGuestForm.Parameters.mGuestBirthPlaceArea = "";
//			pGuestForm.Parameters.mGuestBirthPlaceCity = "";
//			
//			// Trip purpose
//			pGuestForm.Parameters.mTripPurpose = "";
//		ElsIf TypeOfPrintForm = 3 Тогда
//			// Guest address
//			pGuestForm.Parameters.mGuestCitizenship = "";
//			pGuestForm.Parameters.mGuestCountry = "";
//			
//			// Guest place of birth
//			pGuestForm.Parameters.mGuestBirthPlaceCountry = "";
//			pGuestForm.Parameters.mGuestBirthPlaceRegion = "";
//			pGuestForm.Parameters.mGuestBirthPlaceArea = "";
//			pGuestForm.Parameters.mGuestBirthPlaceCity = "";
//		EndIf;
//		
//		// Guest identity document data
//		If TypeOfPrintForm = 3 Тогда
//			pGuestForm.Parameters.mGuestIDType = "";
//		EndIf;
//		pGuestForm.Parameters.mGuestIDSeries = "";
//		pGuestForm.Parameters.mGuestIDNumber = "";
//		pGuestForm.Parameters.mGuestIDIssuedBy = "";
//		If TypeOfPrintForm = 3 Тогда
//			pGuestForm.Parameters.mGuestIDIssuedBy2 = "";
//			pGuestForm.Parameters.mGuestIDUnitCode = "";
//		EndIf;
//		pGuestForm.Parameters.mGuestIDIssueDate = "";
//		
//		// Guest identification cards
//		If TypeOfPrintForm = 1 Тогда
//			pGuestForm.Parameters.mClientIdentificationCardsLabel = "";
//			pGuestForm.Parameters.mClientIdentificationCards = "";
//		EndIf;
//	EndIf;
//		
//	// ГруппаНомеров
//	pGuestForm.Parameters.mRoom = pDocument.НомерРазмещения;
//	
//	// Guest check in and check out dates
//	pGuestForm.Parameters.mCheckInDate = Format(pDocument.CheckInDate, "DF=dd.MM.yyyy");
//	pGuestForm.Parameters.mCheckOutDate = Format(pDocument.CheckOutDate, "DF=dd.MM.yyyy");
//	If TypeOfPrintForm = 3 Тогда
//		pGuestForm.Parameters.mCheckInDateStr = Format(pDocument.CheckInDate, "DF=dd.MM.yyyy");
//		pGuestForm.Parameters.mEmployee = ПараметрыСеанса.ТекПользователь;
//	EndIf;
//	
//	If TypeOfPrintForm = 1 Тогда
//		// Employee
//		pGuestForm.Parameters.mEmployee = ПараметрыСеанса.ТекПользователь;
//	EndIf;
//КонецПроцедуры //SetParameters
//	
////-----------------------------------------------------------------------------
//Процедура PrintGuestForm(pSpreadsheet, pGuestForm, pDocument, pPutPageBreak = False)
//	// New page
//	If pPutPageBreak Тогда
//		pSpreadsheet.PutHorizontalPageBreak();
//	EndIf;
//	
//	// Calculate and set parameters
//	SetParameters(pGuestForm, pDocument);
//	
//	// Put guest card
//	pSpreadsheet.Put(pGuestForm);
//КонецПроцедуры //PrintGuestForm
//
////-----------------------------------------------------------------------------
//Процедура PrintGuestFormsForGuestGroup(pSpreadsheet, pGuestForm)
//	If ЗначениеЗаполнено(GuestGroup) Тогда 
//		If TypeOf(Document) = Type("DocumentRef.Reservation") Тогда
//			vAccommodations = GuestGroup.GetObject().pmGetReservations(True, True);
//		Else
//			vAccommodations = GuestGroup.GetObject().pmGetAccommodations();
//		EndIf;
//		vPutPageBreak = False;
//		For Each vRow In vAccommodations Do
//			vCurDocument = Неопределено;
//			If TypeOf(Document) = Type("DocumentRef.Reservation") Тогда
//				vCurDocument = vRow.Reservation;
//			Else
//				vCurDocument = vRow.Размещение;
//			EndIf;
//			If ЗначениеЗаполнено(vCurDocument) And ЗначениеЗаполнено(vCurDocument.ВидРазмещения) And 
//			   НЕ vCurDocument.ВидРазмещения.DoNotIssueKeyCards Тогда
//				If TypeOfPrintForm = 3 And Print2On1Page Тогда
//					vPutPageBreak = False;
//					If (vAccommodations.IndexOf(vRow) + 1)/2 <> Int((vAccommodations.IndexOf(vRow) + 1)/2) Тогда
//						vPutPageBreak = True;
//					EndIf;
//				EndIf;
//				PrintGuestForm(pSpreadsheet, pGuestForm, vCurDocument, vPutPageBreak);
//				If НЕ (TypeOfPrintForm = 3 And Print2On1Page) Тогда
//					If НЕ vPutPageBreak Тогда
//						vPutPageBreak = True;
//					EndIf;
//				EndIf;
//			EndIf;
//		EndDo;
//	EndIf;
//КонецПроцедуры //PrintGuestFormsForGuestGroup
//
////-----------------------------------------------------------------------------
//Процедура PrintGuestFormsForRoom(pSpreadsheet, pGuestForm)
//	vAccommodations = New СписокЗначений();
//	vAccommodations.Add(Document);
//	If TypeOf(Document) = Type("DocumentRef.Reservation") Тогда
//		AddOneRoomReservations(vAccommodations);
//	Else		
//		AddOneRoomAccommodations(vAccommodations);
//	EndIf;
//	vPutPageBreak = False;
//	For Each vDocItem In vAccommodations Do
//		If ЗначениеЗаполнено(vDocItem.Value) And ЗначениеЗаполнено(vDocItem.Value.ВидРазмещения) And 
//		   НЕ vDocItem.Value.ВидРазмещения.DoNotIssueKeyCards Тогда
//			If TypeOfPrintForm = 3 And Print2On1Page Тогда
//				vPutPageBreak = False;
//				If (vAccommodations.IndexOf(vDocItem) + 1)/2 <> Int((vAccommodations.IndexOf(vDocItem) + 1)/2) Тогда
//					vPutPageBreak = True;
//				EndIf;
//			EndIf;
//			PrintGuestForm(pSpreadsheet, pGuestForm, vDocItem.Value, vPutPageBreak);
//			If НЕ (TypeOfPrintForm = 3 And Print2On1Page) Тогда
//				If НЕ vPutPageBreak Тогда
//					vPutPageBreak = True;
//				EndIf;
//			EndIf;
//		EndIf;
//	EndDo;
//КонецПроцедуры //PrintGuestFormsForRoom
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
//	|	Reservation.Ref
//	|FROM
//	|	Document.Reservation AS Reservation
//	|WHERE
//	|	Reservation.Ref <> &qDoc
//	|	AND (Reservation.НомерРазмещения = &qRoom
//	|			OR Reservation.НомерДока = &qNumber)
//	|	AND Reservation.ГруппаГостей = &qGuestGroup
//	|	AND Reservation.CheckOutDate > &qCheckInDate
//	|	AND Reservation.Posted
//	|	AND Reservation.ReservationStatus.IsActive
//	|
//	|ORDER BY
//	|	Reservation.PointInTime";
//	vQry.SetParameter("qDoc", Document);
//	vQry.SetParameter("qRoom", Document.НомерРазмещения);
//	vQry.SetParameter("qNumber", Document.НомерДока);
//	vQry.SetParameter("qGuestGroup", Document.ГруппаГостей);
//	vQry.SetParameter("qCheckInDate", Document.CheckInDate);
//	vQryRes = vQry.Execute().Unload();
//	For Each vQryResRow In vQryRes Do
//		pDocsList.Add(vQryResRow.Ref);
//	EndDo;
//КонецПроцедуры //AddOneRoomReservations
//
////-----------------------------------------------------------------------------
//Процедура FillHotelParameters(pGuestForm)
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
//		If TypeOfPrintForm = 1 Тогда
//			pGuestForm.Parameters.mHotelNameRU = Upper(vHotelNameRU);
//			pGuestForm.Parameters.mHotelNameEN = Upper(vHotel.PrintNameTranslations);
//		ElsIf TypeOfPrintForm = 3 Тогда
//			pGuestForm.Parameters.mHotelNameRU = Upper(vHotelNameRU);
//			pGuestForm.Parameters.mHotelAddress = cmGetAddressPresentation(vHotel.PostAddress);
//		EndIf;
//	Else
//		// Гостиница name
//		If TypeOfPrintForm = 1 Тогда
//			pGuestForm.Parameters.mHotelNameRU = "";
//			pGuestForm.Parameters.mHotelNameEN = "";
//		ElsIf TypeOfPrintForm = 3 Тогда
//			pGuestForm.Parameters.mHotelNameRU = "";
//		EndIf;
//	EndIf;
//КонецПроцедуры //FillHotelParameters
//
////-----------------------------------------------------------------------------
//Процедура pmGenerate(pSpreadsheet, pTemplate = Неопределено, pIsPersonal = False) Экспорт
//	// Clear output spreadsheet
//	pSpreadsheet.Clear();
//	
//	// Choose template
//	If TypeOfPrintForm = 1 Тогда
//		vTemplate = ThisObject.GetTemplate("FreeForm");
//	ElsIf TypeOfPrintForm = 2 Тогда
//		vTemplate = ThisObject.GetTemplate("Form1G");
//	ElsIf TypeOfPrintForm = 3 Тогда
//		vTemplate = ThisObject.GetTemplate("Form5");
//	EndIf;
//	If pTemplate <> Неопределено Тогда
//		vTemplate = pTemplate;
//	EndIf;
//	
//	// Guest form area
//	If TypeOfPrintForm = 3 Тогда
//		If Print2On1Page Тогда
//			vGuestForm = vTemplate.GetArea("GuestForm");
//		Else
//			vGuestForm = vTemplate.GetArea("GuestForm|Left");
//		EndIf;
//	Else
//		vGuestForm = vTemplate.GetArea("GuestForm");
//	EndIf;
//	
//	// Fill static parameters
//	FillHotelParameters(vGuestForm);
//	
//	// Print guest form
//	If НЕ ЗначениеЗаполнено(GuestGroup) Тогда
//		If pIsPersonal Тогда
//			PrintGuestForm(pSpreadsheet, vGuestForm, Document);
//		Else
//			PrintGuestFormsForRoom(pSpreadsheet, vGuestForm);
//		EndIf;
//	Else
//		PrintGuestFormsForGuestGroup(pSpreadsheet, vGuestForm);
//	EndIf;
//КонецПроцедуры //pmGenerate
