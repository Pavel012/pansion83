////-----------------------------------------------------------------------------
//Процедура SetParameters(pArea, pHotelProduct, pGuest, pAddGuests, pRoom, pRoomType, pPaymentMethod, 
//                               pCheckInDate, pCheckOutDate, pCompany, pAmount, pHotelProductSum, pSeller)
//	// Guest
//	If ЗначениеЗаполнено(pGuest) Тогда
//		vGuestFullName = TrimAll(pGuest.FullName);
//		pArea.Parameters.mGuestFullName = vGuestFullName;
//		pArea.Parameters.mGuestName1 = vGuestFullName;
//		pArea.Parameters.mGuestName2 = "";
//		// Split guest name to 2 parts
//		vBlankPos = Find(vGuestFullName, " ");
//		If vBlankPos > 0 Тогда
//			pArea.Parameters.mGuestName1 = TrimAll(Left(vGuestFullName, vBlankPos - 1));
//			pArea.Parameters.mGuestName2 = TrimAll(Mid(vGuestFullName, vBlankPos + 1));
//		EndIf;
//	Else
//		pArea.Parameters.mGuestFullName = "";
//		pArea.Parameters.mGuestName1 = "";
//		pArea.Parameters.mGuestName2 = "";
//	EndIf;
//	
//	// ГруппаНомеров and ГруппаНомеров parent
//	If ЗначениеЗаполнено(pRoom) Тогда
//		pArea.Parameters.mRoom = TrimAll(pRoom);
//		vRoomParent = pRoom.Parent;
//		While ЗначениеЗаполнено(vRoomParent) Do
//			If НЕ ЗначениеЗаполнено(vRoomParent.Parent) Тогда
//				Break;
//			EndIf;
//			vRoomParent = vRoomParent.Parent;
//		EndDo;
//		If ЗначениеЗаполнено(vRoomParent) Тогда
//			pArea.Parameters.mRoomParent = TrimAll(vRoomParent);
//		Else
//			pArea.Parameters.mRoomParent = "";
//		EndIf;
//	Else
//		pArea.Parameters.mRoom = "";
//		pArea.Parameters.mRoomParent = "";
//	EndIf;
//	
//	// ГруппаНомеров type
//	pArea.Parameters.mRoomType = TrimAll(pRoomType);
//	
//	// Additional guests
//	vNumberOfAdditionalGuests = 0;
//	vNamesOfAdditionalGuests = "";
//	If TypeOf(pAddGuests) = Type("СписокЗначений") Тогда
//		If pAddGuests.Count() > 0 Тогда
//			For Each pAddGuestsItem In pAddGuests Do
//				vAddGuest = pAddGuestsItem.Value;
//				If ЗначениеЗаполнено(vAddGuest) And vAddGuest <> pGuest Тогда
//					If IsBlankString(vNamesOfAdditionalGuests) Тогда
//						vNamesOfAdditionalGuests = TrimAll(vAddGuest.FullName);
//					Else
//						vNamesOfAdditionalGuests = vNamesOfAdditionalGuests + ", " + TrimAll(vAddGuest.FullName);
//					EndIf;
//					vNumberOfAdditionalGuests = vNumberOfAdditionalGuests + 1;
//				EndIf;
//			EndDo;
//		EndIf;
//	EndIf;
//	pArea.Parameters.mAdditionalGuests = vNamesOfAdditionalGuests;
//	pArea.Parameters.mAdditionalGuests1 = "";
//	pArea.Parameters.mAdditionalGuests2 = "";
//	If НЕ IsBlankString(vNamesOfAdditionalGuests) Тогда
//		// Split additional guest names to 2 parts
//		vBlankPos = Find(vNamesOfAdditionalGuests, " ");
//		If vBlankPos > 0 Тогда
//			pArea.Parameters.mAdditionalGuests1 = TrimAll(Left(vNamesOfAdditionalGuests, vBlankPos - 1));
//			pArea.Parameters.mAdditionalGuests2 = TrimAll(Mid(vNamesOfAdditionalGuests, vBlankPos + 1));
//		EndIf;
//	EndIf;
//	
//	// Accommodation period
//	If ЗначениеЗаполнено(pCheckInDate) Тогда
//		pArea.Parameters.mCheckInDate = Format(pCheckInDate, "DF=dd.MM.yyyy");
//	Else
//		pArea.Parameters.mCheckInDate = "";
//	EndIf;
//	If ЗначениеЗаполнено(pCheckOutDate) Тогда
//		pArea.Parameters.mCheckOutDate = Format(pCheckOutDate, "DF=dd.MM.yyyy");
//	Else
//		pArea.Parameters.mCheckOutDate = "";
//	EndIf;
//	
//	// Number of guests
//	pArea.Parameters.mNumberOfGuests = Format(1 + vNumberOfAdditionalGuests, "ND=6; NFD=0; NG=");
//	
//	// Sum in words
//	vSumInWords = pAmount;
//	vSumInWords = cmSumInWords(pAmount, pHotelProduct.Валюта, ПараметрыСеанса.ТекЛокализация);
//	// Split sum in words by first blank after 40 symbol
//	pArea.Parameters.mProductSumInWords1 = vSumInWords;
//	pArea.Parameters.mProductSumInWords2 = "";
//	If StrLen(vSumInWords) > 40 Тогда
//		vBlankPos = Find(Mid(vSumInWords, 41), " ");
//		If vBlankPos > 0 Тогда
//			pArea.Parameters.mProductSumInWords1 = TrimAll(Left(vSumInWords, 40 + vBlankPos - 1));
//			pArea.Parameters.mProductSumInWords2 = TrimAll(Mid(vSumInWords, 40 + vBlankPos + 1));
//		EndIf;
//	EndIf;
//	
//	// Sell date
//	pArea.Parameters.mSellDate = Format(CurrentDate(), "DF=dd.MM.yyyy");
//	
//	// Manager name
//	pArea.Parameters.mManagerName = TrimAll(pSeller);
//КонецПроцедуры //SetParameters
//	
////-----------------------------------------------------------------------------
//Процедура PrintProduct(pSpreadsheet, pArea, pHotelProduct, pPutPageBreak = False, pHotelProducts)
//	If НЕ ЗначениеЗаполнено(pHotelProduct) Тогда
//		Return;
//	EndIf;
//	
//	// New page
//	If pPutPageBreak Тогда
//		pSpreadsheet.PutHorizontalPageBreak();
//	EndIf;
//	
//	// Find main document for the hotel product
//	vDocument = Неопределено;
//	// Fill list of additional guests (children e.t.c.) 
//	vAdditionalGuests = New СписокЗначений();
//	// Get list of documents for the product
//	vHPDocs = pHotelProduct.GetObject().pmGetHotelProductDocuments();
//	If vHPDocs.Count() > 0 Тогда
//		vDocument = vHPDocs.Get(0).Document;
//		vHPDocs.GroupBy("Клиент",);
//		vAdditionalGuests.LoadValues(vHPDocs.UnloadColumn("Клиент"));
//	EndIf;
//	
//	// Calculate and set parameters
//	vAmount = pHotelProduct.GetObject().pmGetHotelProductAmount();
//	vClient = Справочники.Клиенты.EmptyRef();
//	vRoom = Справочники.НомернойФонд.EmptyRef();
//	vRoomType = Справочники.ТипыНомеров.EmptyRef();
//	vPaymentMethod = Неопределено;
//	If ЗначениеЗаполнено(vDocument) Тогда
//		If TypeOf(vDocument) = Type("DocumentRef.СчетПроживания") Тогда
//			vClient = vDocument.Клиент;
//			vRoom = vDocument.НомерРазмещения;
//			If ЗначениеЗаполнено(vDocument.НомерРазмещения) Тогда
//				vRoomType = vDocument.НомерРазмещения.ТипНомера;
//			EndIf;
//			vPaymentMethod = vDocument.СпособОплаты;
//		Else
//			vClient = vDocument.Клиент;
//			vRoom = vDocument.НомерРазмещения;
//			vRoomType = vDocument.ТипНомера;
//			vPaymentMethod = vDocument.PlannedPaymentMethod;
//		EndIf;
//	EndIf;
//	SetParameters(pArea, pHotelProduct, vClient, vAdditionalGuests, vRoom, vRoomType, vPaymentMethod, 
//                         pHotelProduct.CheckInDate, pHotelProduct.CheckOutDate, vDocument.Фирма, 
//						 vAmount, pHotelProduct.Сумма, vDocument.Автор);
//	
//	// Put hotel product
//	pSpreadsheet.Put(pArea);
//	
//	// Add row to the hotel products value table
//	vHPRow = pHotelProducts.Add();
//	vHPRow.ПутевкаКурсовка = pHotelProduct;
//	vHPRow.Клиент = vClient;
//	vHPRow.НомерРазмещения = vRoom;
//КонецПроцедуры //PrintProduct
//
////-----------------------------------------------------------------------------
//Процедура PrintProducts(pSpreadsheet, pArea, pHotelProducts)
//	vQry = New Query();
//	vQry.Text = 
//	"SELECT
//	|	Docs.ПутевкаКурсовка
//	|FROM
//	|	(SELECT
//	|		Accommodations.ПутевкаКурсовка AS ПутевкаКурсовка
//	|	FROM
//	|		Document.Размещение AS Accommodations
//	|	WHERE
//	|		Accommodations.Posted
//	|		AND Accommodations.ПутевкаКурсовка <> &qEmptyHotelProduct
//	|		AND (Accommodations.ГруппаГостей = &qGuestGroup OR &qGuestGroupIsEmpty)
//	|		AND (Accommodations.НомерРазмещения = &qRoom OR &qRoomIsEmpty)
//	|		AND (BEGINOFPERIOD(Accommodations.CheckInDate, DAY) >= &qBegOfCheckInDate
//	|				OR &qCheckInDateIsEmpty)
//	|		AND (ENDOFPERIOD(Accommodations.CheckInDate, DAY) <= &qEndOfCheckInDate
//	|				OR &qCheckInDateIsEmpty)
//	|	
//	|	UNION ALL
//	|	
//	|	SELECT
//	|		Reservations.ПутевкаКурсовка
//	|	FROM
//	|		Document.Reservation AS Reservations
//	|	WHERE
//	|		Reservations.Posted
//	|		AND Reservations.ПутевкаКурсовка <> &qEmptyHotelProduct
//	|		AND (Reservations.ГруппаГостей = &qGuestGroup OR &qGuestGroupIsEmpty)
//	|		AND (Reservations.НомерРазмещения = &qRoom OR &qRoomIsEmpty)
//	|		AND (BEGINOFPERIOD(Reservations.CheckInDate, DAY) >= &qBegOfCheckInDate
//	|				OR &qCheckInDateIsEmpty)
//	|		AND (ENDOFPERIOD(Reservations.CheckInDate, DAY) <= &qEndOfCheckInDate
//	|				OR &qCheckInDateIsEmpty)
//	|	
//	|	UNION ALL
//	|	
//	|	SELECT
//	|		НачислениеУслуг.ПутевкаКурсовка
//	|	FROM
//	|		Document.Начисление AS НачислениеУслуг
//	|	WHERE
//	|		НачислениеУслуг.Posted
//	|		AND НачислениеУслуг.ПутевкаКурсовка <> &qEmptyHotelProduct
//	|		AND (НачислениеУслуг.СчетПроживания.ГруппаГостей = &qGuestGroup OR &qGuestGroupIsEmpty)
//	|		AND (НачислениеУслуг.СчетПроживания.НомерРазмещения = &qRoom OR &qRoomIsEmpty)
//	|		AND (BEGINOFPERIOD(НачислениеУслуг.СчетПроживания.DateTimeFrom, DAY) >= &qBegOfCheckInDate
//	|				OR &qCheckInDateIsEmpty)
//	|		AND (ENDOFPERIOD(НачислениеУслуг.СчетПроживания.DateTimeFrom, DAY) <= &qEndOfCheckInDate
//	|				OR &qCheckInDateIsEmpty)) AS Docs
//	|
//	|GROUP BY
//	|	Docs.ПутевкаКурсовка
//	|
//	|ORDER BY
//	|	Docs.ПутевкаКурсовка.Code";
//	vQry.SetParameter("qEmptyHotelProduct", Справочники.ПутевкиКурсовки.EmptyRef());
//	vQry.SetParameter("qGuestGroup", GuestGroup);
//	vQry.SetParameter("qGuestGroupIsEmpty", НЕ ЗначениеЗаполнено(GuestGroup));
//	vQry.SetParameter("qRoom", ГруппаНомеров);
//	vQry.SetParameter("qRoomIsEmpty", НЕ ЗначениеЗаполнено(ГруппаНомеров));
//	vQry.SetParameter("qBegOfCheckInDate", BegOfDay(CheckInDate));
//	vQry.SetParameter("qEndOfCheckInDate", EndOfDay(CheckInDate));
//	vQry.SetParameter("qCheckInDateIsEmpty", НЕ ЗначениеЗаполнено(CheckInDate));
//	vHotelProducts = vQry.Execute().Unload();
//	vIsFirstDoc = True;
//	For Each vRow In vHotelProducts Do
//		PrintProduct(pSpreadsheet, pArea, vRow.HotelProduct, НЕ vIsFirstDoc, pHotelProducts);
//		If vIsFirstDoc Тогда
//			vIsFirstDoc = False;
//		EndIf;
//	EndDo;
//КонецПроцедуры //PrintProducts
//
////-----------------------------------------------------------------------------
//Процедура pmGenerate(pSpreadsheet, pTemplate = Неопределено, pHotelProducts) Экспорт
//	// Initialize value table with hotel products to print
//	pHotelProducts = New ValueTable();
//	pHotelProducts.Columns.Add("ПутевкаКурсовка", cmGetCatalogTypeDescription("ПутевкиКурсовки"));
//	pHotelProducts.Columns.Add("Клиент", cmGetCatalogTypeDescription("Клиенты"));
//	pHotelProducts.Columns.Add("НомерРазмещения", cmGetCatalogTypeDescription("НомернойФонд"));
//	
//	// Clear output spreadsheet
//	pSpreadsheet.Clear();
//	
//	// Choose template
//	vTemplate = ThisObject.GetTemplate("Product");
//	If pTemplate <> Неопределено Тогда
//		vTemplate = pTemplate;
//	EndIf;
//	
//	// Guest card area
//	vArea = vTemplate.GetArea("Product");
//	
//	// Call processings	
//	If НЕ ЗначениеЗаполнено(Document) Тогда
//		PrintProducts(pSpreadsheet, vArea, pHotelProducts);
//	Else
//		PrintProduct(pSpreadsheet, vArea, Document.ПутевкаКурсовка, False, pHotelProducts);
//	EndIf;
//КонецПроцедуры //pmGenerate
