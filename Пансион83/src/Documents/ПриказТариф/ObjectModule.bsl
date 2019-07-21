////-----------------------------------------------------------------------------
//Процедура pmFillAuthorAndDate() Экспорт
//	Date = BegOfDay(CurrentDate());
//	Автор = ПараметрыСеанса.ТекПользователь;
//КонецПроцедуры //pmFillAuthorAndDate
//
////-----------------------------------------------------------------------------
//Процедура pmFillAttributesWithDefaultValues() Экспорт
//	// Fill author and document date
//	pmFillAuthorAndDate();
//	// Fill from session parameters
//	If НЕ ЗначениеЗаполнено(Гостиница) Тогда
//		Гостиница = ПараметрыСеанса.ТекущаяГостиница;
//	EndIf;
//КонецПроцедуры //pmFillAttributesWithDefaultValues
//
////-----------------------------------------------------------------------------
//Процедура pmWriteToSetRoomRatePricesChangeHistory(pPeriod, pUser) Экспорт
//	// Get channges description
//	vChanges = cmGetObjectChanges(ThisObject);
//	If НЕ IsBlankString(vChanges) Тогда
//		// Do movement on current date
//		vHistoryRec = InformationRegisters.ИсторияИзмПриказовЦена.CreateRecordManager();
//		
//		vHistoryRec.Period = pPeriod;
//		vHistoryRec.ПриказТариф = ThisObject.Ref;
//		
//		FillPropertyValues(vHistoryRec, ThisObject);
//		vHistoryRec.Changes = vChanges;
//		
//		vHistoryRec.User = pUser;
//		
//		// Store tabular parts
//		vPrices = New ValueStorage(Prices.Unload());
//		vHistoryRec.Prices = vPrices;
//		vFormulas = New ValueStorage(Formulas.Unload());
//		vHistoryRec.Formulas = vFormulas;
//		
//		// Write record
//		vHistoryRec.Write(True);
//	EndIf;
//КонецПроцедуры //pmWriteToSetRoomRatePricesChangeHistory
//
////-----------------------------------------------------------------------------
//Function pmGetPreviousObjectState(pPeriod) Экспорт
//	vQry = New Query();
//	vQry.Text = 
//	"SELECT
//	|	*
//	|FROM
//	|	InformationRegister.SetRoomRatePricesChangeHistory.SliceLast(&qPeriod, ПриказТариф = &qDoc) AS SetRoomRatePricesChangeHistory";
//	vQry.SetParameter("qPeriod", pPeriod);
//	vQry.SetParameter("qDoc", Ref);
//	vStates = vQry.Execute().Unload();
//	If vStates.Count() > 0 Тогда
//		Return vStates.Get(0);
//	Else
//		Return Неопределено;
//	EndIf;
//EndFunction //pmGetPreviousObjectState
//
////-----------------------------------------------------------------------------
//Процедура pmRestoreAttributesFromHistory(pHistoryRec) Экспорт
//	FillPropertyValues(ThisObject, pHistoryRec, , "Number, Date, Автор");
//	If НЕ IsBlankString(pHistoryRec.НомерДока) Тогда
//		Number = pHistoryRec.НомерДока;
//	EndIf;
//	If ЗначениеЗаполнено(pHistoryRec.ДатаДок) Тогда
//		Date = pHistoryRec.ДатаДок;
//	EndIf;
//	If ЗначениеЗаполнено(pHistoryRec.Автор) Тогда
//		Автор = pHistoryRec.Автор;
//	EndIf;
//	// Restore tabular parts
//	vPrices = pHistoryRec.Prices.Get();
//	If vPrices <> Неопределено Тогда
//		Prices.Load(vPrices);
//	Else
//		Prices.Clear();
//	EndIf;
//	vFormulas = pHistoryRec.Formulas.Get();
//	If vFormulas <> Неопределено Тогда
//		Formulas.Load(vFormulas);
//	Else
//		Formulas.Clear();
//	EndIf;
//КонецПроцедуры //pmRestoreAttributesFromHistory
//
////-----------------------------------------------------------------------------
//Function pmCheckDocumentAttributes(pMessage, pAttributeInErr) Экспорт
//	vHasErrors = False;
//	pMessage = "";
//	pAttributeInErr = "";
//	vMsgTextRu = "";
//	vMsgTextEn = "";
//	vMsgTextDe = "";
//	If НЕ ЗначениеЗаполнено(Гостиница) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Гостиница> должен быть заполнен!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "<Гостиница> attribute should be filled!" + Chars.LF;
//		vMsgTextDe = vMsgTextDe + "<Гостиница> attribute should be filled!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "Гостиница", pAttributeInErr);
//	EndIf;
//	If НЕ ЗначениеЗаполнено(Тариф) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Тариф> должен быть заполнен!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "<НомерРазмещения rate> attribute should be filled!" + Chars.LF;
//		vMsgTextDe = vMsgTextDe + "<НомерРазмещения rate> attribute should be filled!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "Тариф", pAttributeInErr);
//	EndIf;
//	If НЕ ЗначениеЗаполнено(CalendarDayType) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Тип дня календаря> должен быть заполнен!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "<Calendar day type> attribute should be filled!" + Chars.LF;
//		vMsgTextDe = vMsgTextDe + "<Calendar day type> attribute should be filled!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "ТипДеньКалендарь", pAttributeInErr);
//	EndIf;
//	For Each vRow In Prices Do
//		If НЕ ЗначениеЗаполнено(vRow.Service) Тогда
//			vHasErrors = True; 
//			vMsgTextRu = vMsgTextRu + "В строке " + Format(vRow.LineNumber, "ND=5; NFD=0; NG=") + " реквизит <Услуга> должен быть заполнен!" + Chars.LF;
//			vMsgTextEn = vMsgTextEn + "<Услуга> attribute in line number " + Format(vRow.LineNumber, "ND=5; NFD=0; NG=") + " should be filled!" + Chars.LF;
//			vMsgTextDe = vMsgTextDe + "<Услуга> attribute in line number " + Format(vRow.LineNumber, "ND=5; NFD=0; NG=") + " should be filled!" + Chars.LF;
//			pAttributeInErr = ?(pAttributeInErr = "", "Prices", pAttributeInErr);
//		EndIf;
//		If НЕ ЗначениеЗаполнено(vRow.Currency) Тогда
//			vHasErrors = True; 
//			vMsgTextRu = vMsgTextRu + "В строке " + Format(vRow.LineNumber, "ND=5; NFD=0; NG=") + " реквизит <Валюта> должен быть заполнен!" + Chars.LF;
//			vMsgTextEn = vMsgTextEn + "<Валюта> attribute in line number " + Format(vRow.LineNumber, "ND=5; NFD=0; NG=") + " should be filled!" + Chars.LF;
//			vMsgTextDe = vMsgTextDe + "<Валюта> attribute in line number " + Format(vRow.LineNumber, "ND=5; NFD=0; NG=") + " should be filled!" + Chars.LF;
//			pAttributeInErr = ?(pAttributeInErr = "", "Prices", pAttributeInErr);
//		EndIf;
//		If НЕ ЗначениеЗаполнено(vRow.VATRate) Тогда
//			vHasErrors = True; 
//			vMsgTextRu = vMsgTextRu + "В строке " + Format(vRow.LineNumber, "ND=5; NFD=0; NG=") + " реквизит <Ставка НДС> должен быть заполнен!" + Chars.LF;
//			vMsgTextEn = vMsgTextEn + "<VAT rate> attribute in line number " + Format(vRow.LineNumber, "ND=5; NFD=0; NG=") + " should be filled!" + Chars.LF;
//			vMsgTextDe = vMsgTextDe + "<VAT rate> attribute in line number " + Format(vRow.LineNumber, "ND=5; NFD=0; NG=") + " should be filled!" + Chars.LF;
//			pAttributeInErr = ?(pAttributeInErr = "", "Prices", pAttributeInErr);
//		EndIf;
//	EndDo;
//	If vHasErrors Тогда
//		pMessage = "ru='" + TrimAll(vMsgTextRu) + "';" + "en='" + TrimAll(vMsgTextEn) + "';" + "de='" + TrimAll(vMsgTextDe) + "';";
//	EndIf;
//	Return vHasErrors;
//EndFunction //pmCheckDocumentAttributes
//
////-----------------------------------------------------------------------------
//Процедура Filling(pBase)
//	// Fill attributes with default values
//	pmFillAttributesWithDefaultValues();
//	// Fill from the base
//	If ЗначениеЗаполнено(pBase) Тогда
//		If TypeOf(pBase) = Type("CatalogRef.Тарифы") Тогда
//			If ЗначениеЗаполнено(pBase.Гостиница) Тогда
//				Гостиница = pBase.Гостиница;
//			EndIf;
//			Тариф = pBase;
//			If ЗначениеЗаполнено(Гостиница) Тогда
//				SetNewNumber(TrimAll(Гостиница.GetObject().pmGetPrefix()));
//			EndIf;
//		EndIf;
//	EndIf;
//КонецПроцедуры //Filling
//
////-----------------------------------------------------------------------------
//Процедура OnSetNewNumber(pStandardProcessing, pPrefix)
//	vPrefix = "";
//	If ЗначениеЗаполнено(Гостиница) Тогда
//		vPrefix = TrimAll(Гостиница.GetObject().pmGetPrefix());
//	ElsIf ЗначениеЗаполнено(ПараметрыСеанса.ТекущаяГостиница) Тогда
//		vPrefix = TrimAll(ПараметрыСеанса.ТекущаяГостиница.GetObject().pmGetPrefix());
//	EndIf;
//	If vPrefix <> "" Тогда
//		pPrefix = vPrefix;
//	EndIf;
//КонецПроцедуры //OnSetNewNumber
//
////-----------------------------------------------------------------------------
//Function GetListOfActiveRoomRates()
//	vRoomRates = New ValueTable();
//	If ЗначениеЗаполнено(Тариф) Тогда
//		If Тариф.IsFolder Тогда
//			vRoomRates = cmGetAllRoomRates(Гостиница, Тариф);
//		Else
//			vRoomRates.Columns.Add("Тариф", cmGetCatalogTypeDescription("Тарифы"));
//			vRow = vRoomRates.Add();
//			vRow.Тариф = Тариф;
//		EndIf;
//	Else
//		vRoomRates = cmGetAllRoomRates(Гостиница);
//	EndIf;
//	Return vRoomRates;
//EndFunction //GetListOfActiveRoomRates
//
////-----------------------------------------------------------------------------
//Function GetListOfActiveCalendarDayTypes()
//	vCalendarDayTypes = New ValueTable();
//	If ЗначениеЗаполнено(CalendarDayType) Тогда
//		If CalendarDayType.IsFolder Тогда
//			vCalendarDayTypes = cmGetAllCalendarDayTypes(CalendarDayType);
//		Else
//			vCalendarDayTypes.Columns.Add("ТипДеньКалендарь", cmGetCatalogTypeDescription("ТипДневногоКалендаря"));
//			vRow = vCalendarDayTypes.Add();
//			vRow.ТипДняКалендаря = CalendarDayType;
//		EndIf;
//	Else
//		vCalendarDayTypes = cmGetAllCalendarDayTypes();
//	EndIf;
//	Return vCalendarDayTypes;
//EndFunction //GetListOfActiveCalendarDayTypes
//
////-----------------------------------------------------------------------------
//Function GetListOfActiveRoomTypes(pRoomType)
//	vRoomTypes = New ValueTable();
//	If ЗначениеЗаполнено(pRoomType) Тогда
//		If pRoomType.IsFolder Тогда
//			vRoomTypes = cmGetAllRoomTypes(Гостиница, pRoomType);
//		Else
//			vRoomTypes.Columns.Add("ТипНомера", cmGetCatalogTypeDescription("ТипыНомеров"));
//			vRow = vRoomTypes.Add();
//			vRow.ТипНомера = pRoomType;
//		EndIf;
//	Else
//		vRoomTypes = cmGetAllRoomTypes(Гостиница);
//	EndIf;
//	Return vRoomTypes;
//EndFunction //GetListOfActiveRoomTypes
//
////-----------------------------------------------------------------------------
//Function GetListOfActiveAccommodationTypes(pAccommodationType)
//	vAccommodationTypes = New ValueTable();
//	If ЗначениеЗаполнено(pAccommodationType) Тогда
//		If pAccommodationType.IsFolder Тогда
//			vAccommodationTypes = cmGetAllAccommodationTypes(pAccommodationType);
//		Else
//			vAccommodationTypes.Columns.Add("ВидРазмещения", cmGetCatalogTypeDescription("ВидыРазмещения"));
//			vRow = vAccommodationTypes.Add();
//			vRow.ВидРазмещения = pAccommodationType;
//		EndIf;
//	Else
//		vAccommodationTypes = cmGetAllAccommodationTypes();
//	EndIf;
//	Return vAccommodationTypes;
//EndFunction //GetListOfActiveAccommodationTypes
//
////-----------------------------------------------------------------------------
//Процедура Posting(pCancel, pMode)
//	Перем vMessage, vAttributeInErr;
//	If ThisObject.DataExchange.Load Тогда
//		Return;
//	EndIf;
//	
//	// Check that posting is possible
//	If pmCheckDocumentAttributes(vMessage, vAttributeInErr) Тогда
//		ВызватьИсключение NStr(vMessage);
//	EndIf;
//	
//	// Get lists of active ГруппаНомеров rates and calendar day types
//	vRoomRates = GetListOfActiveRoomRates();
//	vCalendarDayTypes = GetListOfActiveCalendarDayTypes();
//	
//	// Get list of prices with valid sorting
//	vPrices = pmSortPrices(True);
//	
//	// Add row for each combination of parameters
//	i = 0;
//	For Each vRoomRatesRow In vRoomRates Do
//		vRoomRate = vRoomRatesRow.Тариф;
//		
//		// Do for each calendar day type
//		For Each vCalendarDayTypesRow In vCalendarDayTypes Do
//			vCalendarDayType = vCalendarDayTypesRow.ТипДняКалендаря;
//			
//			// Post document to the ГруппаНомеров rates information register
//			vRec = RegisterRecords.Тарифы.Add();
//			vRec.Period = Date;
//			
//			vRec.Гостиница = Гостиница;
//			vRec.Тариф = vRoomRate;
//			vRec.ТипДняКалендаря = vCalendarDayType;
//			vRec.ПризнакЦены = PriceTag;
//			
//			vRec.ПриказТариф = Ref;
//			
//			// Post document to the ГруппаНомеров rate prices information register
//			For Each vPricesRow In vPrices Do
//				// Get lists of active ГруппаНомеров types and accommodation types for this row
//				vRoomTypes = GetListOfActiveRoomTypes(vPricesRow.ТипНомера);
//				vAccommodationTypes = GetListOfActiveAccommodationTypes(vPricesRow.ВидРазмещения);
//				For Each vRoomTypesRow In vRoomTypes Do
//					For Each vAccommodationTypesRow In vAccommodationTypes Do
//						// Check that current service fits to the ГруппаНомеров rate service group
//						If ЗначениеЗаполнено(vPricesRow.Услуга) Тогда
//							If cmIsServiceInServiceGroup(vPricesRow.Услуга, vRoomRate.RoomRateServiceGroup) Тогда
//								// Check permitted accommodation types for the given ГруппаНомеров type
//								If ЗначениеЗаполнено(vRoomTypesRow.ТипНомера) Тогда
//									vCurRoomType = vRoomTypesRow.ТипНомера;
//									If vCurRoomType.AccommodationTypesAllowed.Count() > 0 Тогда
//										If vCurRoomType.AccommodationTypesAllowed.Find(vAccommodationTypesRow.ВидРазмещения) = Неопределено Тогда
//											Continue;
//										EndIf;
//									EndIf;
//								EndIf;
//								
//								// Add detailed record to the register
//								i = i + 1;
//								
//								vPriceRec = RegisterRecords.ИсторияТарифы.Add();
//								vPriceRec.ПорядокСортировки = i;
//								vPriceRec.ПриказТариф = Ref;
//								
//								FillPropertyValues(vPriceRec, ThisObject, , "Тариф, ТипДеньКалендарь");
//								vPriceRec.Тариф = vRoomRate;
//								vPriceRec.ТипДняКалендаря = vCalendarDayType;
//								
//								FillPropertyValues(vPriceRec, vPricesRow, , "ТипНомера, ВидРазмещения");
//								vPriceRec.ТипНомера = vRoomTypesRow.ТипНомера;
//								vPriceRec.ВидРазмещения = vAccommodationTypesRow.ВидРазмещения;
//								
//								// Apply calendar day type discounts
//								If vCalendarDayType.Скидка <> 0 Тогда
//									If cmIsServiceInServiceGroup(vPricesRow.Услуга, vRoomRate.DiscountServiceGroup) Тогда
//										vPriceRec.Цена = vPriceRec.Цена - Round(vPriceRec.Цена * vCalendarDayType.Скидка / 100, 2);
//									EndIf;
//								EndIf;
//								
//								// Apply ГруппаНомеров rate discounts
//								If vRoomRate.Скидка <> 0 Тогда
//									If cmIsServiceInServiceGroup(vPricesRow.Услуга, vRoomRate.DiscountServiceGroup) Тогда
//										vPriceRec.Цена = vPriceRec.Цена - Round(vPriceRec.Цена * vRoomRate.Скидка / 100, 2);
//									EndIf;
//								EndIf;
//								
//								// Apply ГруппаНомеров rate price rounding rule
//								If vRoomRate.RoundPrice Тогда
//									vPriceRec.Цена = Round(vPriceRec.Цена, vRoomRate.RoundPriceDigits);
//								EndIf;
//							EndIf;
//						EndIf;
//					EndDo; // by accommodation types
//				EndDo; // by ГруппаНомеров types
//			EndDo; // by price rows
//		EndDo; // by calendar day types
//	EndDo; // by ГруппаНомеров rates
//	
//	// Write register records if necessary
//	RegisterRecords.Тарифы.Write();
//	If i > 0 Тогда
//		RegisterRecords.ИсторияТарифы.Write();
//	EndIf;
//КонецПроцедуры //Posting
//
////-----------------------------------------------------------------------------
//Function pmSortPrices(pPosting = False) Экспорт
//	// Create working value table and add sort columns to it
//	vPrices = Prices.Unload();
//	// Process formulas
//	If pPosting Тогда
//		If Formulas.Count() > 0 Тогда
//			For Each vRow In Prices Do
//				If ЗначениеЗаполнено(vRow.AccommodationType) And НЕ vRow.AccommodationType.IsFolder Тогда
//					For Each vFormulaRow In Formulas Do
//						If vRow.AccommodationType = vFormulaRow.MasterAccType And 
//						  (НЕ ЗначениеЗаполнено(vFormulaRow.Service) And vRow.IsRoomRevenue Or 
//						   ЗначениеЗаполнено(vFormulaRow.Service) And vFormulaRow.Service = vRow.Service) Тогда
//							vSkipRow = False;
//							vPricesRows = vPrices.FindRows(New Structure("Услуга, ТипНомера, ВидРазмещения, ТипКлиента", vRow.Service, vRow.RoomType, vFormulaRow.AccommodationType, vRow.ClientType));
//							If vPricesRows.Count() > 0 Тогда
//								vSkipRow = True;
//							EndIf;
//							If НЕ vSkipRow Тогда
//								vPricesRow = vPrices.Add();
//								FillPropertyValues(vPricesRow, vRow, , "LineNumber");
//								vPricesRow.Цена = Round((vPricesRow.Цена + vFormulaRow.BracketsConstant) * vFormulaRow.Multiplier + vFormulaRow.Constant, 2);
//								vPricesRow.ВидРазмещения = vFormulaRow.AccommodationType;
//							EndIf;
//						EndIf;
//					EndDo;
//				EndIf;
//			EndDo;			
//		EndIf;
//	EndIf;
//	// Add sorting columns
//	vPrices.Columns.Add("RoomTypeSortCode", cmGetSortCodeTypeDescription(), "НомерРазмещения type sort code", 10);
//	vPrices.Columns.Add("AccommodationTypeSortCode", cmGetSortCodeTypeDescription(), "Размещение type sort code", 10);
//	vPrices.Columns.Add("ServiceSortCode", cmGetSortCodeTypeDescription(), "Услуга sort code", 10);
//	// Fill new columns
//	For Each vRow In vPrices Do
//		If ЗначениеЗаполнено(vRow.RoomType) Тогда 
//			vRow.RoomTypeSortCode = vRow.RoomType.ПорядокСортировки;
//		Else
//			vRow.RoomTypeSortCode = cmGetMaxSortCodeValue();
//		EndIf;
//		If ЗначениеЗаполнено(vRow.AccommodationType) Тогда 
//			vRow.AccommodationTypeSortCode = vRow.AccommodationType.ПорядокСортировки;
//		Else
//			vRow.AccommodationTypeSortCode = cmGetMaxSortCodeValue();
//		EndIf;
//		If ЗначениеЗаполнено(vRow.Service) Тогда 
//			vRow.ServiceSortCode = vRow.Service.ПорядокСортировки;
//		Else
//			vRow.ServiceSortCode = cmGetMaxSortCodeValue();
//		EndIf;
//	EndDo;
//	// Sort by sort columns
//	If pPosting Тогда
//		vPrices.Sort("IsRoomRevenue Desc, IsInPrice Desc, ServiceSortCode, RoomTypeSortCode, AccommodationTypeSortCode");
//	Else
//		vPrices.Sort("RoomTypeSortCode, AccommodationTypeSortCode, IsRoomRevenue Desc, IsInPrice Desc, ServiceSortCode");
//	EndIf;
//	// Return resulting table
//	Return vPrices;
//EndFunction //pmSortPrices
//
////-----------------------------------------------------------------------------
//Процедура BeforeWrite(pCancel, pWriteMode, pPostingMode)
//	If ThisObject.DataExchange.Load Тогда
//		Return;
//	EndIf;
//	If НЕ cmCheckUserPermissions("HavePermissionToManagePrices") Тогда
//		pCancel = True;
//		vMessage = "en='You do not have rights to manage prices!'; ru='У вас нет прав на управление услугами и ценами!'";
//		WriteLogEvent(NStr("en='Document.DataValidation';ru='Документ.КонтрольДанных';de='Document.DataValidation'"), EventLogLevel.Warning, ThisObject.Metadata(), ThisObject.Ref, NStr(vMessage));
//		Message(NStr(vMessage), MessageStatus.Attention);
//		Return;
//	EndIf;
//КонецПроцедуры //BeforeWrite
//
////-----------------------------------------------------------------------------
//Процедура BeforeDelete(pCancel)
//	If ThisObject.DataExchange.Load Тогда
//		Return;
//	EndIf;
//	If НЕ cmCheckUserPermissions("HavePermissionToManagePrices") Тогда
//		pCancel = True;
//		vMessage = "en='You do not have rights to manage prices!'; ru='У вас нет прав на управление услугами и ценами!'";
//		WriteLogEvent(NStr("en='Document.DataValidation';ru='Документ.КонтрольДанных';de='Document.DataValidation'"), EventLogLevel.Warning, ThisObject.Metadata(), ThisObject.Ref, NStr(vMessage));
//		Message(NStr(vMessage), MessageStatus.Attention);
//		Return;
//	EndIf;
//КонецПроцедуры //BeforeDelete
