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
//Процедура pmWriteToSetPriceTagRangesChangeHistory(pPeriod, pUser) Экспорт
//	// Get channges description
//	vChanges = cmGetObjectChanges(ThisObject);
//	If НЕ IsBlankString(vChanges) Тогда
//		// Do movement on current date
//		vHistoryRec = InformationRegisters.ИзмПриказовЦена.CreateRecordManager();
//		
//		vHistoryRec.Period = pPeriod;
//		vHistoryRec.ИзмЦены = ThisObject.Ref;
//		
//		FillPropertyValues(vHistoryRec, ThisObject);
//		vHistoryRec.Changes = vChanges;
//		
//		vHistoryRec.User = pUser;
//		
//		// Store tabular parts
//		vPriceTagRanges = New ValueStorage(PriceTagRanges.Unload());
//		vHistoryRec.ДиапазонЦены = vPriceTagRanges;
//		
//		// Write record
//		vHistoryRec.Write(True);
//	EndIf;
//КонецПроцедуры //pmWriteToSetPriceTagRangesChangeHistory
//
////-----------------------------------------------------------------------------
//Function pmGetPreviousObjectState(pPeriod) Экспорт
//	vQry = New Query();
//	vQry.Text = 
//	"SELECT
//	|	*
//	|FROM
//	|	InformationRegister.SetPriceTagRangesChangeHistory.SliceLast(&qPeriod, ИзмЦены = &qDoc) AS SetPriceTagRangesChangeHistory";
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
//	vPriceTagRanges = pHistoryRec.ДиапазонЦены.Get();
//	If vPriceTagRanges <> Неопределено Тогда
//		PriceTagRanges.Load(vPriceTagRanges);
//	Else
//		PriceTagRanges.Clear();
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
//	If НЕ ЗначениеЗаполнено(PriceTagType) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Тип признака цены> должен быть заполнен!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "<Цена tag type> attribute should be filled!" + Chars.LF;
//		vMsgTextDe = vMsgTextDe + "<Цена tag type> attribute should be filled!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "PriceTagType", pAttributeInErr);
//	EndIf;
//	For Each vRow In PriceTagRanges Do
//		If НЕ ЗначениеЗаполнено(vRow.PriceTag) Тогда
//			vHasErrors = True; 
//			vMsgTextRu = vMsgTextRu + "В строке " + Format(vRow.LineNumber, "ND=5; NFD=0; NG=") + " реквизит <Признак цены> должен быть заполнен!" + Chars.LF;
//			vMsgTextEn = vMsgTextEn + "<Цена tag> attribute in line number " + Format(vRow.LineNumber, "ND=5; NFD=0; NG=") + " should be filled!" + Chars.LF;
//			vMsgTextDe = vMsgTextDe + "<Цена tag> attribute in line number " + Format(vRow.LineNumber, "ND=5; NFD=0; NG=") + " should be filled!" + Chars.LF;
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
//	// Sort ranges by start value
//	vPriceTagRanges = PriceTagRanges.Unload();
//	vPriceTagRanges.Sort("StartValue, EndValue");
//	
//	// Post document to the ГруппаНомеров rates information register
//	RegisterRecords.ПризнакЦены.Write = True;
//	RegisterRecords.ПризнакЦены.Clear();
//	vRec = RegisterRecords.ПризнакЦены.Add();
//	vRec.Period = BegOfDay(Date);
//	vRec.Гостиница = Гостиница;
//	vRec.PriceTagType = PriceTagType;
//	vRec.ИзмЦены = Ref;
//	
//	// Post document to the price tag ranges information register
//	RegisterRecords.ДиапазонЦены.Write = True;
//	RegisterRecords.ДиапазонЦены.Clear();
//	For Each vPriceTagRangesRow In vPriceTagRanges Do
//		vRecord = RegisterRecords.ДиапазонЦены.Add();
//		vRecord.Period = BegOfDay(Date);
//		vRecord.Гостиница = Гостиница;
//		vRecord.PriceTagType = PriceTagType;
//		vRecord.ПорядокСортировки = vPriceTagRanges.IndexOf(vPriceTagRangesRow) + 1;
//		vRecord.StartValue = vPriceTagRangesRow.StartValue;
//		vRecord.EndValue = vPriceTagRangesRow.EndValue;
//		vRecord.ПризнакЦены = vPriceTagRangesRow.PriceTag;
//		vRecord.ИзмЦены = Ref;
//	EndDo;
//КонецПроцедуры //Posting
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
