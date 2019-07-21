////-----------------------------------------------------------------------------
//Процедура pmGenerate(pSpreadsheet, pTemplate = Неопределено) Экспорт
//	vParameters = New Structure;
//	vParameters.Вставить("mHotelName");
//	
//	vParameters.Вставить("mCompanyName");
//	vParameters.Вставить("mCompanyTIN");
//	vParameters.Вставить("mCompanyKPP");
//	vParameters.Вставить("mCompanyOKPOCode");
//	vParameters.Вставить("mCompanyOKDP");
//	vParameters.Вставить("mCompanyDepartment");
//	vParameters.Вставить("mCompanyAddress");
//	vParameters.Вставить("mDebetAccount");
//	vParameters.Вставить("mCreditAccount");
//	vParameters.Вставить("mReason");
//	vParameters.Вставить("mSupplement");
//	vParameters.Вставить("mDirectorPosition");
//	
//	vParameters.Вставить("mDirectorName");
//	vParameters.Вставить("mCashierName");
//	vParameters.Вставить("mAccountantGeneralName");
//	
//	vParameters.Вставить("mCashRegisterName");
//	vParameters.Вставить("mKKMManufactureNumber");
//	vParameters.Вставить("mKKMRegistrationNumber");
//
//	vParameters.Вставить("mGuestName");
//	vParameters.Вставить("mGuestAddress1");
//	vParameters.Вставить("mGuestAddress2");
//	vParameters.Вставить("mGuestIDType");
//	vParameters.Вставить("mGuestIDSeries");
//	vParameters.Вставить("mGuestIDNumber");
//	vParameters.Вставить("mGuestIDIssued");
//	vParameters.Вставить("mRoom");
//	vParameters.Вставить("mCheckInDate");
//	vParameters.Вставить("mCheckOutDate");
//	
//	vParameters.Вставить("mSum");
//	vParameters.Вставить("mSumInWords");
//	vParameters.Вставить("mReturnRemarks");
//	vParameters.Вставить("mReturnNumber");
//	vParameters.Вставить("mPaymentNumber");
//	vParameters.Вставить("mDate");
//	vParameters.Вставить("mAuthor");
//	vParameters.Вставить("mCurrency");
//	
//	vParameters.Вставить("mQuantity");
//	
//	// Clear output spreadsheet
//	pSpreadsheet.Clear();
//	
//	// Fill parameters
//	vHotel = Неопределено;
//	If ЗначениеЗаполнено(Document) Тогда
//		If ЗначениеЗаполнено(Document.Гостиница) Тогда
//			vHotel = Document.Гостиница;
//		EndIf;
//	ElsIf ЗначениеЗаполнено(ПараметрыСеанса.ТекущаяГостиница) Тогда
//		vHotel = ПараметрыСеанса.ТекущаяГостиница;
//	EndIf;
//	vCompany = Неопределено;
//	If ЗначениеЗаполнено(Document) Тогда
//		If ЗначениеЗаполнено(Document.Фирма) Тогда
//			vCompany = Document.Фирма;
//		EndIf;
//	ElsIf ЗначениеЗаполнено(vHotel) Тогда
//		vCompany = vHotel.Фирма;
//	EndIf;
//	If ЗначениеЗаполнено(vCompany) Тогда
//		// Гостиница name
//		vHotelName = TrimAll(vHotel.LegacyName);
//		If IsBlankString(vHotelName) Тогда
//			vHotelName = TrimAll(vHotel.Description);
//		EndIf;
//		vParameters.mHotelName = vHotelName;
//		
//		// Фирма name
//		vCompanyName = TrimAll(vCompany.LegacyName);
//		If IsBlankString(vCompanyName) Тогда
//			vCompanyName = TrimAll(vCompany.Description);
//		EndIf;
//		vParameters.mCompanyName = vCompanyName;
//		
//		// Фирма parameters
//		vParameters.mDirectorName = vCompany.Director;
//		vParameters.mCompanyTIN = TrimAll(vCompany.ИНН);
//		vParameters.mCompanyKPP = TrimAll(vCompany.KPP);
//		vParameters.mCompanyOKPOCode = TrimAll(vCompany.OKPO);
//		vParameters.mCompanyOKDP = TrimAll(vCompany.OKDP);
//		vParameters.mCompanyAddress = cmGetAddressPresentation(vCompany.LegacyAddress);
//		vParameters.mCashierName = vCompany.CashierGeneral;
//		If ЗначениеЗаполнено(ПараметрыСеанса.ТекПользователь) And vCompany.RKOShowCurrentManagerAsCashier Тогда
//			vParameters.mCashierName = ПараметрыСеанса.ТекПользователь.GetObject().pmGetEmployeeDescription(Справочники.Локализация.RU);
//		EndIf;
//		vParameters.mAccountantGeneralName = vCompany.AccountantGeneral;
//		
//		// Debet/credit account
//		If IsBlankString(vCompany.RKODebetAccount) Тогда
//			vParameters.mDebetAccount = "62.02";
//		Else			
//			vParameters.mDebetAccount = TrimAll(vCompany.RKODebetAccount);
//		EndIf;
//		If IsBlankString(vCompany.RKOCreditAccount) Тогда
//			vParameters.mCreditAccount = "50.01";
//		Else			
//			vParameters.mCreditAccount = TrimAll(vCompany.RKOCreditAccount);
//		EndIf;
//		
//		// Reason
//		If IsBlankString(vCompany.RKOReason) Тогда
//			vParameters.mReason = "";
//		Else
//			vParameters.mReason = TrimAll(vCompany.RKOReason);
//		EndIf;
//		
//		// Supplement
//		If IsBlankString(vCompany.RKOSupplement) Тогда
//			vParameters.mSupplement = "";
//		Else
//			vParameters.mSupplement = TrimAll(vCompany.RKOSupplement);
//		EndIf;
//		
//		// Director Должность
//		If IsBlankString(vCompany.RKODirectorPosition) Тогда
//			vParameters.mDirectorPosition = "Генеральный директор";
//		Else
//			vParameters.mDirectorPosition = vCompany.RKODirectorPosition;
//		EndIf;
//		
//		// Forms date
//		If vCompany.RKODoNotFillDate Тогда
//			vParameters.mDate = "";
//		Else
//			vParameters.mDate = Format(Document.ДатаДок, "L=ru; DLF=DD");
//		EndIf;
//	Else
//		// Гостиница name
//		vParameters.mHotelName = "";
//		// Фирма name
//		vParameters.mCompanyName = "";
//	
//		// Фирма parameters
//		vParameters.mDirectorName = "";
//		vParameters.mCompanyTIN = "";
//		vParameters.mCompanyKPP = "";
//		vParameters.mCompanyOKPOCode = "";
//		vParameters.mCompanyAddress = "";
//		vParameters.mCashierName = "";
//		vParameters.mAccountantGeneralName = "";
//		
//		// Debet account, reason, supplement and director Должность
//		vParameters.mDebetAccount = "62.02";
//		vParameters.mReason = "";
//		vParameters.mSupplement = "Заявление";
//		vParameters.mDirectorPosition = "Генеральный директор";
//		
//		// Forms date
//		vParameters.mDate = Format(Document.ДатаДок, "L=ru; DLF=DD");
//	EndIf;
//	If ЗначениеЗаполнено(Document.Касса) Тогда
//		vParameters.mCashRegisterName = Document.Касса.Description;
//		vParameters.mKKMManufactureNumber = Document.Касса.ManufactureNumber;
//		vParameters.mKKMRegistrationNumber = Document.Касса.ТабельныйНомер;
//	Else
//		vParameters.mCashRegisterName = "";
//		vParameters.mKKMManufactureNumber= "";
//		vParameters.mKKMRegistrationNumber= "";
//	EndIf;
//	
//	// Guest name
//	vParameters.mGuestName = "                                                            "; // 60 blanks
//	
//	// Guest address
//	vParameters.mGuestAddress1 = "";
//	vParameters.mGuestAddress2 = "";
//	
//	// Guest identity document data
//	vParameters.mGuestIDType = "";
//	vParameters.mGuestIDSeries = "";
//	vParameters.mGuestIDNumber = "";
//	vParameters.mGuestIDIssued = "";
//	
//	// For the folio based payment and return
//	vGuest = Справочники.Клиенты.EmptyRef();
//	vHotelProduct = Справочники.ПутевкиКурсовки.EmptyRef();
//	If TypeOf(Document) <> Type("DocumentRef.ПлатежКонтрагента") Тогда
//		// Guest
//		If ЗначениеЗаполнено(Document.Payer) And TypeOf(Document.Payer) = Type("CatalogRef.Клиенты") Тогда
//			vGuest = Document.Payer;
//		EndIf;
//		If ЗначениеЗаполнено(Document.ДокОснование) Тогда
//			If TypeOf(Document.ДокОснование) = Type("DocumentRef.Размещение") Or 
//			   TypeOf(Document.ДокОснование) = Type("DocumentRef.Reservation") Тогда
//				If НЕ ЗначениеЗаполнено(vGuest) Тогда
//					vGuest = Document.ДокОснование.Клиент;
//				EndIf;
//				vHotelProduct = Document.ДокОснование.ПутевкаКурсовка;
//			ElsIf TypeOf(Document.ДокОснование) = Type("DocumentRef.БроньУслуг") Тогда
//				If НЕ ЗначениеЗаполнено(vGuest) Тогда
//					vGuest = Document.ДокОснование.Клиент;
//				EndIf;
//			EndIf;
//		EndIf;
//			
//		If ЗначениеЗаполнено(vGuest) Тогда
//			// Guest name
//			vParameters.mGuestName = TrimAll(vGuest.Фамилия) + " " + 
//											TrimAll(vGuest.Имя) + " " + 
//											TrimAll(vGuest.Отчество);
//											
//			If ЗначениеЗаполнено(vHotelProduct) Тогда
//				vParameters.mGuestName = TrimAll(vParameters.mGuestName) + ", " + 
//										 TrimAll(vHotelProduct.Description);
//			EndIf;
//			
//			// Guest address
//			vGuestAddress = cmParseAddress(vGuest.Address);
//			
//			vParameters.mGuestAddress1 = cmGetAddressPresentation(" " + vGuestAddress.PostCode + ", " + vGuestAddress.Region);
//			vParameters.mGuestAddress2 = cmGetAddressPresentation(" " + vGuestAddress.Area + ", " + vGuestAddress.City + ", " + 
//																		 vGuestAddress.Street + ", " + vGuestAddress.House + ", " + vGuestAddress.Flat);
//			
//			// Guest identity document data
//			vParameters.mGuestIDType = TrimAll(vGuest.IdentityDocumentType);
//			vParameters.mGuestIDSeries = TrimAll(vGuest.IdentityDocumentSeries);
//			vParameters.mGuestIDNumber = TrimAll(vGuest.IdentityDocumentNumber);
//			vParameters.mGuestIDIssued = Format(vGuest.IdentityDocumentIssueDate, "DF=dd.MM.yyyy") + " " + 
//			                                    TrimAll(vGuest.IdentityDocumentIssuedBy);
//		EndIf;
//	
//		// ГруппаНомеров
//		vParameters.mRoom = Document.СчетПроживания.НомерРазмещения;
//			
//		// Guest check in and check out dates
//		vParameters.mCheckInDate = Format(Document.СчетПроживания.DateTimeFrom, "DF='dd.MM.yyyy HH:mm'");
//		vParameters.mCheckOutDate = Format(Document.СчетПроживания.DateTimeTo, "DF='dd.MM.yyyy HH:mm'");
//	EndIf;
//	
//	// Return sum
//	vSum = Document.Сумма;
//	If vSum < 0 Тогда
//		vSum = -vSum;
//	EndIf;
//	
//	vParameters.mSum = Format(vSum, "ND=17; NFD=2");
//	vParameters.mSumInWords = cmSumInWords(vSum, Document.PaymentCurrency, Справочники.Локализация.RU);
//	vParameters.mCurrency = TrimAll(Document.PaymentCurrency);
//	vParameters.mAuthor = Document.Автор;
//	vParameters.mReturnNumber = cmGetDocumentNumberPresentation(Document.НомерДока);
//	vParameters.mReturnRemarks = TrimAll(Document.Примечания);
//	vParameters.mPaymentNumber = "";
//	If TypeOf(Document) = Type("DocumentRef.Возврат") And ЗначениеЗаполнено(Document.Платеж) Тогда
//		vParameters.mPaymentNumber = cmGetDocumentNumberPresentation(Document.Платеж.НомерДока);
//	EndIf;
//	
//	vParameters.mQuantity = "";
//	
//	// 1. Application
//	vTemplate = ThisObject.GetTemplate("Application");
//	If pTemplate <> Неопределено Тогда
//		vTemplate = pTemplate;
//	EndIf;
//	vHeader = vTemplate.GetArea("Application");
//	FillPropertyValues(vHeader.Parameters, vParameters);
//	pSpreadsheet.Put(vHeader);
//	vApplicationHeight = pSpreadsheet.TableHeight;
//	vApplicationWidth = pSpreadsheet.TableWidth;
//	
//	// Create new rows format and set columns width
//	vArea = pSpreadsheet.Area(1, , vApplicationHeight);
//	vArea.CreateFormatOfRows();
//	For i = 1 To vTemplate.TableWidth Do
//		pSpreadsheet.Area(1, i).ColumnWidth = vTemplate.Area(1, i).ColumnWidth;
//	EndDo;
//	
//	// 2. KM3
//	pSpreadsheet.PutHorizontalPageBreak();
//	vTemplate = ThisObject.GetTemplate("KM3");
//	If pTemplate <> Неопределено Тогда
//		vTemplate = pTemplate;
//	EndIf;
//	vHeader = vTemplate.GetArea("KM3");
//	FillPropertyValues(vHeader.Parameters, vParameters);
//	pSpreadsheet.Put(vHeader);
//	vKM3Height = pSpreadsheet.TableHeight;
//	
//	// Create new rows format and set columns width
//	vArea = pSpreadsheet.Area(vApplicationHeight+1, , vKM3Height);
//	vArea.CreateFormatOfRows();
//	For i = 1 To vTemplate.TableWidth Do
//		pSpreadsheet.Area(vApplicationHeight+1, i).ColumnWidth = vTemplate.Area(1, i).ColumnWidth;
//	EndDo;
//	
//	// 3. RKO - if doc type is "Return"
//	If TypeOf(Document) = Type("DocumentRef.Возврат") Or TypeOf(Document) = Type("DocumentRef.ПлатежКонтрагента") Тогда
//		pSpreadsheet.PutHorizontalPageBreak();
//		vTemplate = ThisObject.GetTemplate("RKO");
//		If pTemplate <> Неопределено Тогда
//			vTemplate = pTemplate;
//		EndIf;
//		vHeader = vTemplate.GetArea("RKO");
//		FillPropertyValues(vHeader.Parameters, vParameters);
//		pSpreadsheet.Put(vHeader);
//		vRKOHeight = pSpreadsheet.TableHeight;
//		
//		// Create new rows format and set columns width
//		vArea = pSpreadsheet.Area(vKM3Height+1, , vRKOHeight);
//		vArea.CreateFormatOfRows();
//		For i = 1 To vTemplate.TableWidth Do
//			pSpreadsheet.Area(vKM3Height+1, i).ColumnWidth = vTemplate.Area(1, i).ColumnWidth;
//		EndDo;
//	EndIf;
//	
//	// 4. 8-Г - if doc type is "Return" and Cash register has Print8G flag is on
//	If ЗначениеЗаполнено(Document.Касса) And Document.Касса.Print8G And ЗначениеЗаполнено(Document.СпособОплаты) And Document.СпособОплаты.BookByCashRegister And НЕ Document.СпособОплаты.PrintCheque And 
//	   (TypeOf(Document) = Type("DocumentRef.Возврат") Or TypeOf(Document) = Type("DocumentRef.ПлатежКонтрагента")) Тогда
//		pSpreadsheet.PutHorizontalPageBreak();
//		vTemplate = ThisObject.GetTemplate("G8");
//		If pTemplate <> Неопределено Тогда
//			vTemplate = pTemplate;
//		EndIf;
//		vHeader = vTemplate.GetArea("G8");
//		FillPropertyValues(vHeader.Parameters, vParameters);
//		pSpreadsheet.Put(vHeader);
//		vG8Height = pSpreadsheet.TableHeight;
//		
//		// Create new rows format and set columns width
//		vArea = pSpreadsheet.Area(vRKOHeight+1, , vG8Height);
//		vArea.CreateFormatOfRows();
//		For i = 1 To vTemplate.TableWidth Do
//			pSpreadsheet.Area(vRKOHeight+1, i).ColumnWidth = vTemplate.Area(1, i).ColumnWidth;
//		EndDo;
//	EndIf;
//	
//	// Set print area
//	pSpreadsheet.PrintArea = pSpreadsheet.Area(, 1, , vApplicationWidth);
//КонецПроцедуры //pmGenerate
