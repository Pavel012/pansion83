////-----------------------------------------------------------------------------
//// Document will change folio in the parent charge/storno document and do posting for it
////-----------------------------------------------------------------------------
//Процедура Posting(pCancel, pPostingMode)
//	If ThisObject.DataExchange.Load Тогда
//		Return;
//	EndIf;
//	// Change folio in the parent charge document
//	vParentChargeObj = ParentCharge.GetObject();
//	vParentChargeObj.СчетПроживания = FolioTo;
//	vParentChargeObj.Гостиница = vParentChargeObj.СчетПроживания.Гостиница;
//	If ЗначениеЗаполнено(vParentChargeObj.СчетПроживания.Фирмы) Тогда
//		vParentChargeObj.Фирма = vParentChargeObj.СчетПроживания.Фирмы;
//	EndIf;
//	If ЗначениеЗаполнено(vParentChargeObj.СчетПроживания.ПутевкаКурсовка) Тогда
//		vParentChargeObj.ПутевкаКурсовка = vParentChargeObj.СчетПроживания.ПутевкаКурсовка;
//	EndIf;
//	vParentChargeObj.ВалютаЛицСчета = vParentChargeObj.СчетПроживания.ВалютаЛицСчета;
//	vParentChargeObj.FolioCurrencyExchangeRate = cmGetCurrencyExchangeRate(vParentChargeObj.Гостиница, vParentChargeObj.ВалютаЛицСчета, vParentChargeObj.ExchangeRateDate);
//	vParentChargeObj.СуммаНДС = cmCalculateVATSum(vParentChargeObj.СтавкаНДС, vParentChargeObj.Сумма);
//	vParentChargeObj.НДСскидка = cmCalculateVATSum(vParentChargeObj.СтавкаНДС, vParentChargeObj.СуммаСкидки);
//	vParentChargeObj.СуммаКомиссииНДС = cmCalculateVATSum(vParentChargeObj.СтавкаНДС, vParentChargeObj.СуммаКомиссии);
//	vParentChargeObj.ПеремещениеНачисления = Ref;
//	// Post this changed charge
//	vParentChargeObj.Write(DocumentWriteMode.Posting);
//	// Repost folio from charges
//	vFolioObj = FolioFrom.GetObject();
//	vFolioObj.pmRepostAdditionalCharges(ParentCharge);
//КонецПроцедуры //Posting
//
////-----------------------------------------------------------------------------
//Function pmCheckDocumentAttributes(pMessage, pAttributeInErr) Экспорт
//	vHasErrors = False;
//	pMessage = "";
//	pAttributeInErr = "";
//	vMsgTextRu = "";
//	vMsgTextEn = "";
//	vMsgTextDe = "";
//	If НЕ ЗначениеЗаполнено(ParentCharge) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Начисление> должен быть заполнен!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "<Parent Начисление> attribute should be filled!" + Chars.LF;
//		vMsgTextDe = vMsgTextDe + "<Parent Начисление> attribute should be filled!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "ParentCharge", pAttributeInErr);
//	EndIf;
//	If НЕ ЗначениеЗаполнено(FolioFrom) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Лицевой счет источник> должен быть заполнен!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "<СчетПроживания from> attribute should be filled!" + Chars.LF;
//		vMsgTextDe = vMsgTextDe + "<СчетПроживания from> attribute should be filled!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "FolioFrom", pAttributeInErr);
//	Else
//		If FolioFrom.DeletionMark Тогда
//			vHasErrors = True; 
//			vMsgTextRu = vMsgTextRu + "<Лицевой счет источник> помечен на удаление!" + Chars.LF;
//			vMsgTextEn = vMsgTextEn + "<СчетПроживания from> is marked for deletion!" + Chars.LF;
//			vMsgTextDe = vMsgTextDe + "<СчетПроживания from> is marked for deletion!" + Chars.LF;
//			pAttributeInErr = ?(pAttributeInErr = "", "FolioFrom", pAttributeInErr);
//		EndIf;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(FolioTo) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Лицевой счет получатель> должен быть заполнен!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "<СчетПроживания to> attribute should be filled!" + Chars.LF;
//		vMsgTextDe = vMsgTextDe + "<СчетПроживания to> attribute should be filled!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "FolioTo", pAttributeInErr);
//	Else
//		If FolioTo.DeletionMark Тогда
//			vHasErrors = True; 
//			vMsgTextRu = vMsgTextRu + "<Лицевой счет получатель> помечен на удаление!" + Chars.LF;
//			vMsgTextEn = vMsgTextEn + "<СчетПроживания to> is marked for deletion!" + Chars.LF;
//			vMsgTextDe = vMsgTextDe + "<СчетПроживания to> is marked for deletion!" + Chars.LF;
//			pAttributeInErr = ?(pAttributeInErr = "", "FolioTo", pAttributeInErr);
//		EndIf;
//	EndIf;
//	If ЗначениеЗаполнено(FolioFrom) And ЗначениеЗаполнено(FolioTo) Тогда
//		If FolioFrom = FolioTo Тогда
//			vHasErrors = True; 
//			vMsgTextRu = vMsgTextRu + "Лицевые счета должны быть разными!" + Chars.LF;
//			vMsgTextEn = vMsgTextEn + "Folios should not be the same!" + Chars.LF;
//			vMsgTextDe = vMsgTextDe + "Folios should not be the same!" + Chars.LF;
//			pAttributeInErr = ?(pAttributeInErr = "", "FolioTo", pAttributeInErr);
//		EndIf;
//	EndIf;
//	If ЗначениеЗаполнено(FolioFrom) And ЗначениеЗаполнено(FolioTo) Тогда
//		If FolioFrom.FolioCurrency <> FolioTo.FolioCurrency Тогда
//			vHasErrors = True; 
//			vMsgTextRu = vMsgTextRu + "Перемещать начисление можно только между лицевыми счетами в одной валюте!" + Chars.LF;
//			vMsgTextEn = vMsgTextEn + "You can transfer НачислениеУслуг between folios with the same СчетПроживания Валюта only!" + Chars.LF;
//			vMsgTextDe = vMsgTextDe + "You can transfer НачислениеУслуг between folios with the same СчетПроживания Валюта only!" + Chars.LF;
//			pAttributeInErr = ?(pAttributeInErr = "", "FolioTo", pAttributeInErr);
//		EndIf;
//	EndIf;
//	If vHasErrors Тогда
//		pMessage = "ru='" + TrimAll(vMsgTextRu) + "';" + "en='" + TrimAll(vMsgTextEn) + "';" + "de='" + TrimAll(vMsgTextDe) + "';";
//	EndIf;
//	Return vHasErrors;
//EndFunction //CheckDocumentAttributes
//
////-----------------------------------------------------------------------------
//Процедура pmFillAuthorAndDate() Экспорт
//	Date = CurrentDate();
//	Author = ПараметрыСеанса.ТекПользователь;
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
//Процедура Filling(pBase)
//	// Fill attributes with default values
//	pmFillAttributesWithDefaultValues();
//	// Fill from the base
//	If ЗначениеЗаполнено(pBase) Тогда
//		If TypeOf(pBase) = Type("DocumentRef.Начисление") Тогда
//			ParentDoc = pBase.ДокОснование;
//			FolioFrom = pBase.СчетПроживания;
//			ParentCharge = pBase;
//			If ЗначениеЗаполнено(ParentCharge.Гостиница) Тогда
//				If Гостиница <> ParentCharge.Гостиница Тогда
//					Гостиница = ParentCharge.Гостиница;
//					SetNewNumber(TrimAll(Гостиница.GetObject().pmGetPrefix()));
//				EndIf;
//			EndIf;
//		EndIf;
//	EndIf;
//КонецПроцедуры //Filling
//
////-----------------------------------------------------------------------------
//Процедура BeforeWrite(pCancel, pWriteMode, pPostingMode)
//	Перем vMessage, vAttributeInErr;
//	If ThisObject.DataExchange.Load Тогда
//		Return;
//	EndIf;
//	If pWriteMode = DocumentWriteMode.Posting Тогда
//		pCancel	= pmCheckDocumentAttributes(vMessage, vAttributeInErr);
//		If pCancel Тогда
//			WriteLogEvent(NStr("en='Document.DataValidation';ru='Документ.КонтрольДанных';de='Document.DataValidation'"), EventLogLevel.Warning, ThisObject.Metadata(), ThisObject.Ref, NStr(vMessage));
//			Message(NStr(vMessage), MessageStatus.Attention);
//			ВызватьИсключение NStr(vMessage);
//		EndIf;
//	Else
//		// Check if this charge is closed by settlement
//		If ЗначениеЗаполнено(Гостиница) And Гостиница.DoNotEditSettledDocs And ЗначениеЗаполнено(ParentCharge) And 
//		   pWriteMode = DocumentWriteMode.UndoPosting And 
//		  (ParentCharge.Sum <> 0 Or ParentCharge.Quantity <> 0) And 
//		   ЗначениеЗаполнено(FolioFrom) And FolioFrom.IsClosed Тогда
//			vChargeBalanceIsZero = False;
//			vChargeBalancesRow = cmGetChargeCurrentAccountsReceivableBalance(ParentCharge);
//			If vChargeBalancesRow <> Неопределено Тогда
//				If vChargeBalancesRow.SumBalance = 0 And vChargeBalancesRow.QuantityBalance = 0 Тогда
//					vChargeBalanceIsZero = True;
//				EndIf;
//			Else
//				vChargeBalanceIsZero = True;
//			EndIf;
//			If vChargeBalanceIsZero Тогда
//				pCancel = True;
//				Message(NStr("en='This charge is closed by settlement! Charge is read only.';
//				             |ru='Начисление уже закрыто актом об оказании услуг! Редактирование такого начисления запрещено.';
//							 |de='Die Anrechnung wurde bereits über ein Übergabeprotokoll über die Erbringung von Dienstleistungen geschlossen! Die Bearbeitung einer solchen Anrechnung ist verboten.'"), MessageStatus.Attention);
//				Return;
//			EndIf;
//		EndIf;
//	EndIf;
//	// Check if this transfer is in closed day
//	If ЗначениеЗаполнено(Гостиница) And Гостиница.DoNotEditClosedDateDocs And 
//	  (pWriteMode = DocumentWriteMode.Posting Or pWriteMode = DocumentWriteMode.UndoPosting) And 
//	  ЗначениеЗаполнено(FolioFrom) And ЗначениеЗаполнено(FolioTo) And 
//	  (FolioFrom.GuestGroup <> FolioTo.GuestGroup Or FolioFrom.Контрагент <> FolioTo.Контрагент Or FolioFrom.Contract <> FolioTo.Contract Or FolioFrom.Agent <> FolioTo.Agent) Тогда
//		vTransferIsInClosedDay = cmIfChargeIsInClosedDay(ThisObject);
//		vChargeIsInClosedDay = cmIfChargeIsInClosedDay(ParentCharge);
//		If vTransferIsInClosedDay Or vChargeIsInClosedDay Тогда
//			pCancel = True;
//			If ЭтоНовый() Тогда
//				Message(NStr("en='Day is closed! Charge transfer could not be posted on this day.';
//				             |ru='День закрыт! Проводить перемещение начисления этой датой запрещено.';
//							 |de='Der Tag ist geschlossen! Es ist verboten, eine Verschiebung der Anrechnung zu diesem Datum durchzuführen.'"), MessageStatus.Attention);
//			Else
//				Message(NStr("en='This transfer is in closed day! Charge transfer is read only.';
//				             |ru='Перемещение в закрытом дне! Редактирование такого перемещения запрещено.';
//							 |de='Verschiebung im geschlossenen Tag! Die Editierung einer solchen Verschiebung ist verboten.'"), MessageStatus.Attention);
//			EndIf;
//			Return;
//		EndIf;
//	EndIf;
//КонецПроцедуры //BeforeWrite
//
////-----------------------------------------------------------------------------
//Процедура OnSetNewNumber(pStandardProcessing, pPrefix)
//	vPrefix = "";
//	If ЗначениеЗаполнено(ПараметрыСеанса.ТекущаяГостиница) Тогда
//		vPrefix = TrimAll(ПараметрыСеанса.ТекущаяГостиница.GetObject().pmGetPrefix());
//	EndIf;
//	If vPrefix <> "" Тогда
//		pPrefix = vPrefix;
//	EndIf;
//КонецПроцедуры //OnSetNewNumber
//
////-----------------------------------------------------------------------------
//Процедура pmUndoPosting(pCancel)
//	// Change folio in the parent charge document back to it's initial value
//	If ЗначениеЗаполнено(FolioFrom) And ЗначениеЗаполнено(ParentCharge) Тогда
//		vParentChargeObj = ParentCharge.GetObject();
//		vParentChargeObj.СчетПроживания = FolioFrom;
//		vParentChargeObj.Гостиница = vParentChargeObj.СчетПроживания.Гостиница;
//		If ЗначениеЗаполнено(vParentChargeObj.СчетПроживания.Фирмы) Тогда
//			vParentChargeObj.Фирма = vParentChargeObj.СчетПроживания.Фирмы;
//			vParentChargeObj.СтавкаНДС = vParentChargeObj.Фирма.СтавкаНДС;
//		EndIf;
//		vParentChargeObj.ВалютаЛицСчета = vParentChargeObj.СчетПроживания.ВалютаЛицСчета;
//		vParentChargeObj.FolioCurrencyExchangeRate = cmGetCurrencyExchangeRate(vParentChargeObj.Гостиница, vParentChargeObj.ВалютаЛицСчета, vParentChargeObj.ExchangeRateDate);
//		vParentChargeObj.СуммаНДС = cmCalculateVATSum(vParentChargeObj.СтавкаНДС, vParentChargeObj.Сумма);
//		vParentChargeObj.НДСскидка = cmCalculateVATSum(vParentChargeObj.СтавкаНДС, vParentChargeObj.СуммаСкидки);
//		vParentChargeObj.СуммаКомиссииНДС = cmCalculateVATSum(vParentChargeObj.СтавкаНДС, vParentChargeObj.СуммаКомиссии);
//		vParentChargeObj.ПеремещениеНачисления = Неопределено;
//		// Post this changed charge
//		If НЕ vParentChargeObj.Posted Тогда
//			vParentChargeObj.Write(DocumentWriteMode.Write);
//		Else
//			vParentChargeObj.Write(DocumentWriteMode.Posting);
//		EndIf;
//		// Repost folio to charges
//		vFolioObj = FolioTo.GetObject();
//		vFolioObj.pmRepostAdditionalCharges(ParentCharge);
//	EndIf;
//КонецПроцедуры //pmUndoPosting
//
////-----------------------------------------------------------------------------
//Процедура UndoPosting(pCancel)
//	If ThisObject.DataExchange.Load Тогда
//		Return;
//	EndIf;
//	pmUndoPosting(pCancel);
//КонецПроцедуры //UndoPosting
//
////-----------------------------------------------------------------------------
//Процедура BeforeDelete(pCancel)
//	If ThisObject.DataExchange.Load Тогда
//		Return;
//	EndIf;
//	If Posted Тогда
//		// Check if this charge is closed by settlement
//		If ЗначениеЗаполнено(Гостиница) And Гостиница.DoNotEditSettledDocs And ЗначениеЗаполнено(ParentCharge) And 
//		  (ParentCharge.Sum <> 0 Or ParentCharge.Quantity <> 0) And 
//		   ЗначениеЗаполнено(FolioFrom) And FolioFrom.IsClosed Тогда
//			vChargeBalanceIsZero = False;
//			vChargeBalancesRow = cmGetChargeCurrentAccountsReceivableBalance(ParentCharge);
//			If vChargeBalancesRow <> Неопределено Тогда
//				If vChargeBalancesRow.SumBalance = 0 And vChargeBalancesRow.QuantityBalance = 0 Тогда
//					vChargeBalanceIsZero = True;
//				EndIf;
//			Else
//				vChargeBalanceIsZero = True;
//			EndIf;
//			If vChargeBalanceIsZero Тогда
//				pCancel = True;
//				Message(NStr("en='This charge is closed by settlement! Charge is read only.';
//				             |ru='Начисление уже закрыто актом об оказании услуг! Редактирование такого начисления запрещено.';
//							 |de='Die Anrechnung wurde bereits über ein Übergabeprotokoll über die Erbringung von Dienstleistungen geschlossen! Die Bearbeitung einer solchen Anrechnung ist verboten.'"), MessageStatus.Attention);
//				Return;
//			EndIf;
//		EndIf;
//		// Check if this transfer is in closed day
//		If ЗначениеЗаполнено(Гостиница) And Гостиница.DoNotEditClosedDateDocs Тогда
//			vChargeIsInClosedDay = cmIfChargeIsInClosedDay(Ref);
//			If vChargeIsInClosedDay Тогда
//				pCancel = True;
//				Message(NStr("en='This transfer is in closed day! Charge transfer is read only.';
//				             |ru='Перемещение в закрытом дне! Редактирование такого перемещения запрещено.';
//							 |de='Verschiebung im geschlossenen Tag! Die Editierung einer solchen Verschiebung ist verboten.'"), MessageStatus.Attention);
//				Return;
//			EndIf;
//		EndIf;
//		pmUndoPosting(pCancel);
//	EndIf;
//КонецПроцедуры //BeforeDelete
