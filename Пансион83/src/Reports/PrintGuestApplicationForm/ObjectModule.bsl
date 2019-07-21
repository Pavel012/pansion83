////-----------------------------------------------------------------------------
//Процедура pmGenerate(pSpreadsheet, pTemplate = Неопределено) Экспорт
//	// Get list of all accommodations in the group
//	vAccommodations = GuestGroup.GetObject().pmGetAccommodations();
//	
//	// Clear output spreadsheet
//	pSpreadsheet.Clear();
//	
//	// Choose template
//	vTemplate = ThisObject.GetTemplate("ApplicationForm");
//	If pTemplate <> Неопределено Тогда
//		vTemplate = pTemplate;
//	EndIf;
//	
//	// Header form area
//	vHeader = vTemplate.GetArea("Header");
//	
//	// Fill header parameters
//	vCompany = Неопределено;
//	If ЗначениеЗаполнено(Document) Тогда
//		If ЗначениеЗаполнено(Document.Фирма) Тогда
//			vCompany = Document.Фирма;
//		EndIf;
//	ElsIf ЗначениеЗаполнено(ПараметрыСеанса.ТекущаяГостиница) Тогда
//		vCompany = ПараметрыСеанса.ТекущаяГостиница.Фирма;
//	EndIf;
//	If ЗначениеЗаполнено(vCompany) Тогда
//		// Фирма name
//		vCompanyName = TrimAll(vCompany.LegacyName);
//		If IsBlankString(vCompanyName) Тогда
//			vCompanyName = TrimAll(vCompany.Description);
//		EndIf;
//		vHeader.Parameters.mCompanyName = vCompanyName;
//	
//		// Фирма director
//		vHeader.Parameters.mCompanyDirector = TrimAll(vCompany.Director);
//	Else
//		// Фирма name
//		vHeader.Parameters.mCompanyName = "";
//	
//		// Фирма director
//		vHeader.Parameters.mCompanyDirector = "";
//	EndIf;
//	
//	// Today
//	vHeader.Parameters.mToday = Format(CurrentDate(), "DF='dd MMMM yyyy'");
//	
//	// Guest
//	vHeader.Parameters.mGuest = Document.Гость;
//	
//	// Document
//	vHeader.Parameters.mDocument = Document;
//	
//	If ЗначениеЗаполнено(Document.Гость) Тогда
//		// Guest name
//		vHeader.Parameters.mGuestName = TrimAll(Document.Гость.Фамилия) + " " + 
//		                                TrimAll(Document.Гость.Имя) + " " + 
//		                                TrimAll(Document.Гость.Отчество);
//		
//		// Guest date of birth
//		vHeader.Parameters.mGuestDateOfBirth = Format(Document.Гость.ДатаРождения, "DF=dd.MM.yyyy");
//		
//		// Guest place of birth
//		vHeader.Parameters.mGuestPlaceOfBirth = cmGetAddressPresentation(Document.Гость.PlaceOfBirth);
//			
//		// Guest address
//		vGuestAddress = cmParseAddress(Document.Гость.Address);
//		
//		vHeader.Parameters.mGuestAddress1 = cmGetAddressPresentation(" " + vGuestAddress.PostCode + ", " + vGuestAddress.Region);
//		vHeader.Parameters.mGuestAddress2 = cmGetAddressPresentation(" " + vGuestAddress.Area + ", " + vGuestAddress.City + ", " + 
//		                                                             vGuestAddress.Street + ", " + vGuestAddress.House + ", " + vGuestAddress.Flat);
//		
//		// Guest identity document data
//		vHeader.Parameters.mGuestIDSeries = TrimAll(Document.Гость.IdentityDocumentSeries);
//		vHeader.Parameters.mGuestIDNumber = TrimAll(Document.Гость.IdentityDocumentNumber);
//		vHeader.Parameters.mGuestIDIssued = Format(Document.Гость.IdentityDocumentIssueDate, "DF=dd.MM.yyyy") + " " + 
//		                                    TrimAll(Document.Гость.IdentityDocumentIssuedBy);
//	Else
//		// Guest name
//		vHeader.Parameters.mGuestName = "";
//		
//		// Guest date of birth
//		vHeader.Parameters.mGuestDateOfBirth = "";
//		
//		// Guest place of birth
//		vHeader.Parameters.mGuestPlaceOfBirth = "";
//			
//		// Guest address
//		vHeader.Parameters.mGuestAddress1 = "";
//		vHeader.Parameters.mGuestAddress2 = "";
//		
//		// Guest identity document data
//		vHeader.Parameters.mGuestIDSeries = "";
//		vHeader.Parameters.mGuestIDNumber = "";
//		vHeader.Parameters.mGuestIDIssued = "";
//	EndIf;
//		
//	// ГруппаНомеров type
//	vHeader.Parameters.mRoomType = Document.ТипНомера;
//		
//	// Number of persons
//	vNumberOfPersons = 0;
//	For Each vRow In vAccommodations Do
//		vNumberOfPersons = vNumberOfPersons + vRow.Размещение.КоличествоЧеловек;
//	EndDo;
//	vHeader.Parameters.mNumberOfPersons = vNumberOfPersons;
//	
//	// Guest check in and check out dates
//	vHeader.Parameters.mCheckInDate = Format(Document.ДатаЗаезда, "DF=dd.MM.yyyy");
//	vHeader.Parameters.mCheckOutDate = Format(Document.ДатаВыезда, "DF=dd.MM.yyyy");
//	
//	// Duration
//	vHeader.Parameters.mDuration = Format(Document.Продолжительность, "ND=4; NZ=");
//	
//	// Put header
//	pSpreadsheet.Put(vHeader);
//	
//	// Process all other documents in the group	
//	If vAccommodations.Count() > 1 Тогда
//		// Guest group header
//		vGuestGroup = vTemplate.GetArea("ГруппаГостей");
//		
//		// Put guest group header
//		pSpreadsheet.Put(vGuestGroup);
//		
//		// Guest in group
//		vGuest = vTemplate.GetArea("Клиент");
//		
//		// Process documents in guest group
//		vLineNumber = 0;
//		For Each vRow In vAccommodations Do
//			vDocument = vRow.Размещение;
//			// Skip document on a form
//			If vDocument <> Document Тогда
//				// Line number
//				vLineNumber = vLineNumber + 1;
//				vGuest.Parameters.mLineNumber = vLineNumber;
//				
//				// Document
//				vGuest.Parameters.mDocument = vDocument;
//				
//				// Guest
//				vGuest.Parameters.mGuest = vDocument.Клиент;
//				
//				If ЗначениеЗаполнено(vDocument.Клиент) Тогда
//					vGuest.Parameters.mGuestName = TrimAll(vDocument.Клиент.Фамилия) + " " + 
//												   TrimAll(vDocument.Клиент.Имя) + " " + 
//												   TrimAll(vDocument.Клиент.Отчество);
//				Else
//					vGuest.Parameters.mGuestName = "";
//				EndIf;
//				
//				// Put guest in guest group
//				pSpreadsheet.Put(vGuest);
//			EndIf;
//		EndDo;
//	EndIf;
//	
//	// Header form area
//	vFooter = vTemplate.GetArea("Footer");
//	
//	// Today
//	vFooter.Parameters.mToday = Format(CurrentDate(), "DF=dd.MM.yyyy");
//	
//	// Put footer
//	pSpreadsheet.Put(vFooter);
//КонецПроцедуры //pmGenerate
