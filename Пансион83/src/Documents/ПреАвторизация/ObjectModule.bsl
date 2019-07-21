////-----------------------------------------------------------------------------
//Процедура PostToDeposits()
//	Movement = RegisterRecords.Депозиты.Add();
//	
//	Movement.Period = Date;
//	
//	FillPropertyValues(Movement, ThisObject);
//	Movement.ВалютаЛицСчета = FolioCurrency;
//	Movement.СчетПроживания = ЛицевойСчет;
//	
//	// Resources
//	Movement.Сумма = 0;
//	Movement.Limit = SumInFolioCurrency;
//	
//	// Attributes
//	Movement.SumInPaymentCurrency = Sum;
//	Movement.IsPreauthorisation = True;
//	
//	RegisterRecords.Депозиты.Write();
//КонецПроцедуры //PostToDeposits
//
////-----------------------------------------------------------------------------
//Процедура PostToAccounts()
//	Movement = RegisterRecords.Взаиморасчеты.Add();
//	
//	Movement.RecordType = AccumulationRecordType.Expense;
//	Movement.Period = Date;
//	
//	FillPropertyValues(Movement, ЛицевойСчет);
//	If ЗначениеЗаполнено(ParentDoc) Тогда
//		FillPropertyValues(Movement, ParentDoc);
//	EndIf;
//	FillPropertyValues(Movement, ThisObject);
//	
//	// Resources
//	Movement.Сумма = 0;
//	Movement.Limit = SumInFolioCurrency;
//	
//	// Attributes
//	Movement.IsPreauthorisation = True;
//
//	RegisterRecords.Взаиморасчеты.Write();
//КонецПроцедуры //PostToAccounts
//
////-----------------------------------------------------------------------------
//Процедура PostToInvoiceAccounts()
//	If ЗначениеЗаполнено(Invoice) Тогда
//		Movement = RegisterRecords.ВзаиморасчетыПоСчетам.Add();
//		
//		Movement.RecordType = AccumulationRecordType.Expense;
//		Movement.Period = Date;
//		
//		// Dimensions
//		Movement.Гостиница = Гостиница;
//		Movement.Фирма = Фирма;
//		Movement.СчетНаОплату = Invoice;
//		Movement.Контрагент = Invoice.AccountingCustomer;
//		Movement.Договор = Invoice.AccountingContract;
//		Movement.ВалютаРасчетов = Invoice.AccountingCurrency;
//		Movement.ГруппаГостей = Invoice.GuestGroup;
//		
//		// Resources
//		Movement.Сумма = cmConvertCurrencies(Sum, PaymentCurrency, PaymentCurrencyExchangeRate, Movement.ВалютаРасчетов, , ExchangeRateDate, Гостиница);
//		
//		// Attributes
//		Movement.УчетнаяДата = BegOfDay(Date);
//		If ЗначениеЗаполнено(ЛицевойСчет) Тогда
//			Movement.Клиент = ЛицевойСчет.Client;
//			Movement.НомерРазмещения = ЛицевойСчет.ГруппаНомеров;
//		EndIf;
//		Movement.IsPreauthorisation = True;
//
//		RegisterRecords.ВзаиморасчетыПоСчетам.Write();
//	EndIf;
//КонецПроцедуры //PostToInvoiceAccounts
//
////-----------------------------------------------------------------------------
//Процедура Posting(pCancel, pMode)
//	If ThisObject.DataExchange.Load Тогда
//		Return;
//	EndIf;
//	
//	// 1. Post to Deposits
//	PostToDeposits();
//		
//	If Status = Перечисления.PreauthorisationStatuses.Authorised Тогда
//		// 2. Post to Accounts
//		PostToAccounts();
//		
//		// 5. Post to Invoice accounts
//		PostToInvoiceAccounts();
//	EndIf;
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
//	If НЕ ЗначениеЗаполнено(Гостиница) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Гостиница> должен быть заполнен!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "<Гостиница> attribute should be filled!" + Chars.LF;
//		vMsgTextDe = vMsgTextDe + "<Гостиница> attribute should be filled!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "Гостиница", pAttributeInErr);
//	EndIf;
//	If НЕ ЗначениеЗаполнено(Фирма) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Фирма> должен быть заполнен!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "<Фирма> attribute should be filled!" + Chars.LF;
//		vMsgTextDe = vMsgTextDe + "<Фирма> attribute should be filled!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "Фирма", pAttributeInErr);
//	EndIf;
//	If НЕ ЗначениеЗаполнено(ЛицевойСчет) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Лицевой счет> должен быть заполнен!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "<СчетПроживания> attribute should be filled!" + Chars.LF;
//		vMsgTextDe = vMsgTextDe + "<СчетПроживания> attribute should be filled!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "СчетПроживания", pAttributeInErr);
//	Else
//		If ЛицевойСчет.DeletionMark Тогда
//			vHasErrors = True; 
//			vMsgTextRu = vMsgTextRu + "<Лицевой счет> помечен на удаление!" + Chars.LF;
//			vMsgTextEn = vMsgTextEn + "<СчетПроживания> is marked for deletion!" + Chars.LF;
//			vMsgTextDe = vMsgTextDe + "<СчетПроживания> is marked for deletion!" + Chars.LF;
//			pAttributeInErr = ?(pAttributeInErr = "", "СчетПроживания", pAttributeInErr);
//		EndIf;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(PaymentMethod) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Способ оплаты> должен быть заполнен!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "<Платеж method> attribute should be filled!" + Chars.LF;
//		vMsgTextDe = vMsgTextDe + "<Платеж method> attribute should be filled!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "СпособОплаты", pAttributeInErr);
//	EndIf;
//	If НЕ ЗначениеЗаполнено(PaymentCurrency) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Валюта платежа> должен быть заполнен!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "<Платеж Валюта> attribute should be filled!" + Chars.LF;
//		vMsgTextDe = vMsgTextDe + "<Платеж Валюта> attribute should be filled!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "PaymentCurrency", pAttributeInErr);
//	EndIf;
//	If НЕ ЗначениеЗаполнено(ExchangeRateDate) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Дата курса> должен быть заполнен!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "<Exchange rate date> attribute should be filled!" + Chars.LF;
//		vMsgTextDe = vMsgTextDe + "<Exchange rate date> attribute should be filled!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "ExchangeRateDate", pAttributeInErr);
//	EndIf;
//	If ЗначениеЗаполнено(PaymentMethod) Тогда
//		If ЗначениеЗаполнено(ПараметрыСеанса.РабочееМесто) Тогда
//			If НЕ ПараметрыСеанса.РабочееМесто.HasConnectionToCreditCardsProcessingSystem Or 
//			   PaymentMethod.ExternalBankTerminalIsUsed Тогда
//				If PaymentMethod.AuthorizationCodeIsRequired And IsBlankString(AuthorizationCode) Тогда
//					vHasErrors = True; 
//					vMsgTextRu = vMsgTextRu + "При оплате кредитной картой должен быть введен реквизит <Код авторизации>!" + Chars.LF;
//					vMsgTextEn = vMsgTextEn + "<Authorization code> attribute should be filled for credit card payment!" + Chars.LF;
//					vMsgTextDe = vMsgTextDe + "<Authorization code> attribute should be filled for credit card payment!" + Chars.LF;
//					pAttributeInErr = ?(pAttributeInErr = "", "AuthorizationCode", pAttributeInErr);
//				EndIf;
//				If PaymentMethod.ReferenceCodeIsRequired And IsBlankString(ReferenceNumber) Тогда
//					vHasErrors = True; 
//					vMsgTextRu = vMsgTextRu + "При оплате кредитной картой должен быть введен реквизит <Референс НомерРазмещения>!" + Chars.LF;
//					vMsgTextEn = vMsgTextEn + "<Reference number> attribute should be filled for credit card payment!" + Chars.LF;
//					vMsgTextDe = vMsgTextDe + "<Reference number> attribute should be filled for credit card payment!" + Chars.LF;
//					pAttributeInErr = ?(pAttributeInErr = "", "ReferenceNumber", pAttributeInErr);
//				EndIf;
//			EndIf;
//		EndIf;
//	EndIf;
//	If Sum < 0 Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Для оформления возврата необходимо использовать документ ""Возврат""!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "Use ""Return"" document to return money!" + Chars.LF;
//		vMsgTextDe = vMsgTextDe + "Use ""Return"" document to return money!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "Сумма", pAttributeInErr);
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
//	ExchangeRateDate = BegOfDay(CurrentDate());
//	If НЕ ЗначениеЗаполнено(Гостиница) Тогда
//		Гостиница = ПараметрыСеанса.ТекущаяГостиница;
//	EndIf;
//	If ЗначениеЗаполнено(Гостиница) Тогда
//		FolioCurrency = Гостиница.FolioCurrency;
//		FolioCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, FolioCurrency, ExchangeRateDate);
//		If НЕ ЗначениеЗаполнено(PaymentCurrency) Тогда
//			PaymentCurrency = Гостиница.BaseCurrency;
//			If ЗначениеЗаполнено(ПараметрыСеанса.РабочееМесто) And ЗначениеЗаполнено(ПараметрыСеанса.РабочееМесто.ВалютаПлатежейПоУмолчанию) Тогда
//				PaymentCurrency = ПараметрыСеанса.РабочееМесто.ВалютаПлатежейПоУмолчанию;
//			EndIf;
//		EndIf;
//		PaymentCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, PaymentCurrency, ExchangeRateDate);
//		Фирма = Гостиница.Фирма;
//		If ЗначениеЗаполнено(Фирма) Тогда
//			VATRate = Фирма.VATRate;
//		EndIf;
//	EndIf;
//КонецПроцедуры //pmFillAttributesWithDefaultValues
//
////-----------------------------------------------------------------------------
//Процедура pmFillGuestGroup() Экспорт
//	If ЛицевойСчет.GuestGroup <> GuestGroup Тогда
//		GuestGroup = ЛицевойСчет.GuestGroup;
//	EndIf;
//КонецПроцедуры //pmFillGuestGroup
//
////-----------------------------------------------------------------------------
//Процедура pmRecalculateSums() Экспорт
//	SumInFolioCurrency = Round(cmConvertCurrencies(Sum, PaymentCurrency, PaymentCurrencyExchangeRate, 
//												   FolioCurrency, FolioCurrencyExchangeRate, 
//												   ExchangeRateDate, Гостиница), 2);
//КонецПроцедуры //pmRecalculateSums
//
////-----------------------------------------------------------------------------
//Процедура FillByFolio(pFolio)
//	If НЕ ЗначениеЗаполнено(pFolio) Тогда
//		Return;
//	EndIf;
//	ЛицевойСчет = pFolio;
//	
//	If ЗначениеЗаполнено(ЛицевойСчет.Гостиница) Тогда
//		If Гостиница <> ЛицевойСчет.Гостиница Тогда
//			Гостиница = ЛицевойСчет.Гостиница;
//		EndIf;
//	EndIf;
//	
//	ParentDoc = ЛицевойСчет.ParentDoc;
//	
//	FolioCurrency = ЛицевойСчет.FolioCurrency;
//	FolioCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, FolioCurrency, ExchangeRateDate);
//	
//	// Fill payment method
//	PaymentMethod = Справочники.СпособОплаты.EmptyRef();
//	If ЗначениеЗаполнено(Гостиница) Тогда
//		If ЗначениеЗаполнено(Гостиница.PlannedPaymentMethod) Тогда
//			PaymentMethod = Гостиница.PlannedPaymentMethod;
//		EndIf;
//	EndIf;
//	If ЗначениеЗаполнено(ParentDoc) Тогда
//		If ЗначениеЗаполнено(ParentDoc.PlannedPaymentMethod) Тогда
//			PaymentMethod = ParentDoc.PlannedPaymentMethod;
//		EndIf;
//	EndIf;
//	If ЗначениеЗаполнено(ЛицевойСчет) Тогда
//		If ЗначениеЗаполнено(ЛицевойСчет.PaymentMethod) Тогда
//			PaymentMethod = ЛицевойСчет.PaymentMethod;
//		EndIf;
//	EndIf;
//	
//	// Fill Фирма
//	If ЗначениеЗаполнено(ЛицевойСчет.Фирма) Тогда
//		Фирма = ЛицевойСчет.Фирма;
//	EndIf;
//	
//	// Fill default payer	
//	If ЗначениеЗаполнено(ЛицевойСчет.Client) Тогда
//		Payer = ЛицевойСчет.Client;
//	ElsIf ЗначениеЗаполнено(ParentDoc) Тогда
//		If TypeOf(ParentDoc) = Type("DocumentRef.Reservation") Or
//		   TypeOf(ParentDoc) = Type("DocumentRef.Размещение") Тогда
//			If ЗначениеЗаполнено(ParentDoc.Клиент) Тогда
//				Payer = ParentDoc.Клиент;
//			EndIf;
//		ElsIf TypeOf(ParentDoc) = Type("DocumentRef.БроньУслуг") Тогда
//			If ЗначениеЗаполнено(ParentDoc.Клиент) Тогда
//				Payer = ParentDoc.Клиент;
//			EndIf;
//		EndIf;
//	EndIf;
//	
//	// Fill Контрагент, contract and guest group
//	pmFillGuestGroup();
//	
//	// Get folio balance
//	vFolioObj = ЛицевойСчет.GetObject();
//	vFolioBalance = vFolioObj.pmGetBalance('39991231235959');
//	SumInFolioCurrency = 0;
//	If vFolioBalance > 0 Тогда
//		SumInFolioCurrency = vFolioBalance;
//	EndIf;
//	
//	// Recalculate sum
//	Sum = Round(cmConvertCurrencies(SumInFolioCurrency, FolioCurrency, FolioCurrencyExchangeRate, PaymentCurrency, PaymentCurrencyExchangeRate, ExchangeRateDate, Гостиница), 2);
//КонецПроцедуры //FillByFolio
//
////-----------------------------------------------------------------------------
//Процедура Filling(pBase)
//	// Fill attributes with default values
//	pmFillAttributesWithDefaultValues();
//	// Fill from the base
//	If ЗначениеЗаполнено(pBase) Тогда
//		If TypeOf(pBase) = Type("DocumentRef.СчетПроживания") Тогда
//			FillByFolio(pBase);
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
//	If IsBlankString(Number) Тогда
//		SetNewNumber();
//	EndIf;
//	If pWriteMode = DocumentWriteMode.Posting Тогда
//		pCancel	= pmCheckDocumentAttributes(vMessage, vAttributeInErr);
//		If pCancel Тогда
//			WriteLogEvent(NStr("en='Document.DataValidation';ru='Документ.КонтрольДанных';de='Document.DataValidation'"), EventLogLevel.Warning, ThisObject.Metadata(), ThisObject.Ref, NStr(vMessage));
//			Message(NStr(vMessage), MessageStatus.Attention);
//			ВызватьИсключение NStr(vMessage);
//		EndIf;
//		If ЗначениеЗаполнено(ЛицевойСчет) And ЗначениеЗаполнено(ЛицевойСчет.GuestGroup) And
//		   ЛицевойСчет.GuestGroup <> GuestGroup Тогда
//			WriteLogEvent(NStr("en='AccountingAttentionEvents.PaymentAndFolioGuestGroupsAreDifferent';de='AccountingAttentionEvents.PaymentAndFolioGuestGroupsAreDifferent';ru='СигналыДляБухгалтерии.ГруппаПлатежаИФолиоОтличаются'"), EventLogLevel.Warning, Metadata(), Ref, TrimAll(GuestGroup) + " <> " + TrimAll(ЛицевойСчет.GuestGroup) + ", " + cmFormatSum(Sum, PaymentCurrency));
//		EndIf;
//	Else
//		If DeletionMark Тогда
//			WriteLogEvent(NStr("en='SuspiciousEvents.PreauthorisationSetDeletionMark';de='SuspiciousEvents.PreauthorisationSetDeletionMark';ru='СигналыОПодозрительныхДействиях.УстановкаПометкиНаУдалениеВПреавторизации'"), EventLogLevel.Warning, Metadata(), Ref, NStr("en='Set document deletion mark';ru='Установка отметки удаления';de='Erstellung der Löschmarkierung'") + Chars.LF + TrimAll(Payer) + ", " + TrimAll(ЛицевойСчет) + Chars.LF + cmFormatSum(Sum, PaymentCurrency));
//			AuthorOfCancellation = ПараметрыСеанса.ТекПользователь;
//			DateOfCancellation = CurrentDate();
//		EndIf;
//	EndIf;
//КонецПроцедуры //BeforeWrite
//
////-----------------------------------------------------------------------------
//Процедура BeforeDelete(pCancel)
//	If ThisObject.DataExchange.Load Тогда
//		Return;
//	EndIf;
//	// Write log event
//	WriteLogEvent(NStr("en='SuspiciousEvents.PaymentDeletion';de='SuspiciousEvents.PaymentDeletion';ru='СигналыОПодозрительныхДействиях.УдалениеПлатежа'"), EventLogLevel.Warning, Metadata(), Ref, NStr("en='Document deletion';ru='Непосредственное удаление';de='Unmittelbare Löschung'") + Chars.LF + TrimAll(Payer) + ", " + TrimAll(ЛицевойСчет) + Chars.LF + cmFormatSum(Sum, PaymentCurrency));
//КонецПроцедуры //BeforeDelete
//
////-----------------------------------------------------------------------------
//Процедура OnSetNewNumber(pStandardProcessing, pPrefix)
//	vPrefix = "";
//	If ЗначениеЗаполнено(Фирма) And Фирма.UsePrefixForPayments Тогда
//		vPrefix = TrimAll(Фирма.Prefix);
//	ElsIf ЗначениеЗаполнено(Гостиница) Тогда
//		vPrefix = TrimAll(Гостиница.GetObject().pmGetPrefix());
//	ElsIf ЗначениеЗаполнено(ПараметрыСеанса.ТекущаяГостиница) Тогда
//		If ЗначениеЗаполнено(ПараметрыСеанса.ТекущаяГостиница.Фирма) And ПараметрыСеанса.ТекущаяГостиница.Фирма.UsePrefixForPayments Тогда
//			vPrefix = TrimAll(ПараметрыСеанса.ТекущаяГостиница.Фирма.Prefix);
//		Else
//			vPrefix = TrimAll(ПараметрыСеанса.ТекущаяГостиница.GetObject().pmGetPrefix());
//		EndIf;
//	EndIf;
//	If vPrefix <> "" Тогда
//		pPrefix = vPrefix;
//	EndIf;
//КонецПроцедуры //OnSetNewNumber
//
////-----------------------------------------------------------------------------
//Процедура OnCopy(pCopiedObject)
//	Status = Перечисления.PreauthorisationStatuses.Authorised;
//	ExternalCode = "";
//КонецПроцедуры //OnCopy
