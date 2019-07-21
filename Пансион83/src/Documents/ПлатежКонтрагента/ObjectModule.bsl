//Перем WasPosted;

////-----------------------------------------------------------------------------
//Процедура PostToCustomerAccounts()
//	If Contracts.Count() > 0 Тогда
//		For Each vRow In Contracts Do
//			Movement = RegisterRecords.ВзаиморасчетыКонтрагенты.Add();
//			
//			Movement.RecordType = AccumulationRecordType.Expense;
//			Movement.Period = Date;
//			
//			If ЗначениеЗаполнено(ParentDoc) Тогда
//				FillPropertyValues(Movement, ParentDoc);
//			EndIf;
//			FillPropertyValues(Movement, ThisObject);
//			FillPropertyValues(Movement, vRow);
//			
//			// Resources
//			Movement.Сумма = vRow.SumInAccountingCurrency;
//			
//			// Attributes
//			Movement.СуммаНДС = cmCalculateVATSum(VATRate, Movement.Сумма);
//			Movement.УчетнаяДата = BegOfDay(Date);
//		EndDo;
//	Else
//		Movement = RegisterRecords.ВзаиморасчетыКонтрагенты.Add();
//		
//		Movement.RecordType = AccumulationRecordType.Expense;
//		Movement.Period = Date;
//		
//		If ЗначениеЗаполнено(ParentDoc) Тогда
//			FillPropertyValues(Movement, ParentDoc);
//		EndIf;
//		FillPropertyValues(Movement, ThisObject);
//		
//		// Resources
//		Movement.Сумма = SumInAccountingCurrency;
//		
//		// Attributes
//		Movement.СуммаНДС = cmCalculateVATSum(VATRate, Movement.Сумма);
//		Movement.УчетнаяДата = BegOfDay(Date);
//	EndIf;

//	RegisterRecords.ВзаиморасчетыКонтрагенты.Write();
//КонецПроцедуры //PostToCustomerAccounts

////-----------------------------------------------------------------------------
//Процедура PostToInvoiceAccounts()
//	If Invoices.Count() > 0 Тогда
//		For Each vRow In Invoices Do
//			Movement = RegisterRecords.ВзаиморасчетыПоСчетам.Add();
//			
//			Movement.RecordType = AccumulationRecordType.Expense;
//			Movement.Period = Date;
//			
//			If ЗначениеЗаполнено(ParentDoc) Тогда
//				FillPropertyValues(Movement, ParentDoc);
//			EndIf;
//			If ЗначениеЗаполнено(vRow.Invoice) Тогда
//				FillPropertyValues(Movement, vRow.Invoice);
//			EndIf;
//			FillPropertyValues(Movement, ThisObject, , "Договор, ГруппаГостей, СчетНаОплату");
//			FillPropertyValues(Movement, vRow);
//			
//			Movement.Договор = vRow.Invoice.AccountingContract;
//			
//			// Resources
//			Movement.Сумма = vRow.SumInAccountingCurrency;
//			
//			// Attributes
//			Movement.СуммаНДС = cmCalculateVATSum(VATRate, Movement.Сумма);
//			Movement.УчетнаяДата = BegOfDay(Date);
//		EndDo;
//		RegisterRecords.ВзаиморасчетыПоСчетам.Write();
//	Else
//		If ЗначениеЗаполнено(Invoice) Тогда
//			Movement = RegisterRecords.ВзаиморасчетыПоСчетам.Add();
//			
//			Movement.RecordType = AccumulationRecordType.Expense;
//			Movement.Period = Date;
//			
//			If ЗначениеЗаполнено(ParentDoc) Тогда
//				FillPropertyValues(Movement, ParentDoc);
//			EndIf;
//			If ЗначениеЗаполнено(Invoice) Тогда
//				FillPropertyValues(Movement, Invoice);
//			EndIf;
//			FillPropertyValues(Movement, ThisObject);
//			
//			Movement.Договор = Invoice.AccountingContract;
//			
//			// Resources
//			Movement.Сумма = SumInAccountingCurrency;
//			
//			// Attributes
//			Movement.СуммаНДС = cmCalculateVATSum(VATRate, Movement.Сумма);
//			Movement.УчетнаяДата = BegOfDay(Date);
//			
//			RegisterRecords.ВзаиморасчетыПоСчетам.Write();
//		EndIf;
//	EndIf;
//КонецПроцедуры //PostToInvoiceAccounts

////-----------------------------------------------------------------------------
//Процедура PostToPayments()
//	Movement = RegisterRecords.Платежи.Add();
//	
//	Movement.Period = Date;
//	
//	FillPropertyValues(Movement, ThisObject);
//	
//	// Dimensions
//	Movement.Payer = AccountingCustomer;
//	Movement.УчетнаяДата = BegOfDay(Date);
//	
//	// Resources
//	If Sum >= 0 Тогда
//		Movement.SumReceipt = Sum;
//		Movement.VATSumReceipt = VATSum;
//		Movement.SumExpense = 0;
//		Movement.VATSumExpense = 0;
//	Else
//		Movement.SumReceipt = 0;
//		Movement.VATSumReceipt = 0;
//		Movement.SumExpense = -Sum;
//		Movement.VATSumExpense = -VATSum;
//	EndIf;
//	
//	RegisterRecords.Платежи.Write();
//КонецПроцедуры //PostToPayments

////-----------------------------------------------------------------------------
//Процедура PostToCashRegisterDailyReceipts()
//	If Contracts.Count() > 0 Тогда
//		For Each vRow In Contracts Do
//			Movement = RegisterRecords.ВыручкаПоСменам.AddReceipt();
//			
//			Movement.Period = Date;
//			Movement.Валюта = PaymentCurrency;
//			
//			If ЗначениеЗаполнено(ParentDoc) Тогда
//				FillPropertyValues(Movement, ParentDoc);
//			EndIf;
//			FillPropertyValues(Movement, ThisObject);
//			
//			// Dimensions
//			Movement.Контрагент = AccountingCustomer;
//			Movement.Договор = vRow.AccountingContract;
//			Movement.ГруппаГостей = vRow.GuestGroup;
//			Movement.Платеж = Ref;
//			
//			// Resources
//			Movement.Сумма = vRow.Sum;
//			Movement.СуммаНДС = cmCalculateVATSum(VATRate, Movement.Сумма);
//			If Movement.Сумма < 0 Тогда
//				Movement.PaymentSum = 0;
//				Movement.VATPaymentSum = 0;
//				Movement.ReturnSum = -Movement.Сумма;
//				Movement.VATReturnSum = -Movement.СуммаНДС;
//			Else
//				Movement.PaymentSum = Movement.Сумма;
//				Movement.VATPaymentSum = Movement.СуммаНДС;
//				Movement.ReturnSum = 0;
//				Movement.VATReturnSum = 0;
//			EndIf;
//			
//			// Attributes
//			Movement.Payer = AccountingCustomer;
//		EndDo;
//	Else
//		Movement = RegisterRecords.ВыручкаПоСменам.AddReceipt();
//		
//		Movement.Period = Date;
//		Movement.Валюта = PaymentCurrency;
//		
//		If ЗначениеЗаполнено(ParentDoc) Тогда
//			FillPropertyValues(Movement, ParentDoc);
//		EndIf;
//		FillPropertyValues(Movement, ThisObject);
//		
//		// Dimensions
//		Movement.Контрагент = AccountingCustomer;
//		Movement.Договор = AccountingContract;
//		Movement.ГруппаГостей = GuestGroup;
//		Movement.Платеж = Ref;
//		
//		// Resources
//		Movement.Сумма = Sum;
//		Movement.СуммаНДС = cmCalculateVATSum(VATRate, Movement.Сумма);
//		If Movement.Сумма < 0 Тогда
//			Movement.PaymentSum = 0;
//			Movement.VATPaymentSum = 0;
//			Movement.ReturnSum = -Movement.Сумма;
//			Movement.VATReturnSum = -Movement.СуммаНДС;
//		Else
//			Movement.PaymentSum = Movement.Сумма;
//			Movement.VATPaymentSum = Movement.СуммаНДС;
//			Movement.ReturnSum = 0;
//			Movement.VATReturnSum = 0;
//		EndIf;
//		
//		// Attributes
//		Movement.Payer = AccountingCustomer;
//	EndIf;

//	RegisterRecords.ВыручкаПоСменам.Write();
//КонецПроцедуры //PostToCashRegisterDailyReceipts

////-----------------------------------------------------------------------------
//Процедура PostToCashInCashRegisters()
//	Movement = RegisterRecords.НаличныеКасса.Add();
//	
//	Movement.Period = Date;
//	Movement.Валюта = PaymentCurrency;
//	
//	FillPropertyValues(Movement, ThisObject);
//	
//	If Sum < 0 Тогда
//		Movement.RecordType = AccumulationRecordType.Expense;
//		Movement.Сумма = -Sum;
//	Else
//		Movement.RecordType = AccumulationRecordType.Receipt;
//		Movement.Сумма = Sum;
//	EndIf;
//		
//	RegisterRecords.НаличныеКасса.Write();
//КонецПроцедуры //PostToCashInCashRegisters

////-----------------------------------------------------------------------------
//Процедура Posting(pCancel, pMode)
//	If ThisObject.DataExchange.Load Тогда
//		Return;
//	EndIf;
//	
//	// 1. Post to Контрагент accounts
//	PostToCustomerAccounts();
//	
//	// 2. Post to Invoice accounts
//	PostToInvoiceAccounts();
//	
//	// 3. Post to Payments
//	PostToPayments();
//	
//	// 4. Post to Close of cash register day debits
//	If ЗначениеЗаполнено(CashRegister) And ЗначениеЗаполнено(PaymentMethod) Тогда
//		If PaymentMethod.BookByCashRegister Тогда
//			PostToCashRegisterDailyReceipts();
//			// 3. Post to cash in cash registers
//			If PaymentMethod.IsByCash Тогда
//				PostToCashInCashRegisters();
//			EndIf;
//		EndIf;
//	EndIf;
//	
//	// 5. Send payment SMS
//	If НЕ WasPosted Тогда
//		vMessageDeliveryError = "";
//		//If НЕ SMS.SendPaymentMessage(AccountingCustomer, GuestGroup, ?(ЗначениеЗаполнено(GuestGroup), GuestGroup.ClientDoc, Неопределено), cmFormatSum(Sum, PaymentCurrency), PaymentMethod, Ref, vMessageDeliveryError) Тогда
//		//	WriteLogEvent(NStr("en='Document.MessageDelivery';ru='Документ.РассылкаСообщений';de='Document.MessageDelivery'"), EventLogLevel.Warning, ThisObject.Metadata(), Ref, vMessageDeliveryError);
//		//	Message(vMessageDeliveryError, MessageStatus.Attention);
//		//EndIf;
//	EndIf;
//КонецПроцедуры //Posting

////-----------------------------------------------------------------------------
//Function pmCheckDocumentAttributes(pMessage, pAttributeInErr) Экспорт
//	vHasErrors = False;
//	pMessage = "";
//	pAttributeInErr = "";
//	vMsgTextRu = "";
//	vMsgTextEn = "";
//	vMsgTextDe = "";
//	If НЕ ЗначениеЗаполнено(Фирма) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Фирма> должен быть заполнен!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "<Фирма> attribute should be filled!" + Chars.LF;
//		vMsgTextDe = vMsgTextDe + "<Фирма> attribute should be filled!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "Фирма", pAttributeInErr);
//	EndIf;
//	If НЕ ЗначениеЗаполнено(AccountingCustomer) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Контрагент> должен быть заполнен!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "<Контрагент> attribute should be filled!" + Chars.LF;
//		vMsgTextDe = vMsgTextDe + "<Контрагент> attribute should be filled!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "Контрагент", pAttributeInErr);
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
//	If НЕ ЗначениеЗаполнено(PaymentSection) And ЗначениеЗаполнено(PaymentMethod) And PaymentMethod.BookByCashRegister Тогда
//		If НЕ cmCheckUserPermissions("HavePermissionToPostPaymentsWithEmptyPaymentSections") Тогда
//			vHasErrors = True; 
//			vMsgTextRu = vMsgTextRu + "Не указана кассовая секция (отдел)!" + Chars.LF;
//			vMsgTextEn = vMsgTextEn + "<Платеж section> attribute should be filled!" + Chars.LF;
//			vMsgTextDe = vMsgTextDe + "<Платеж section> attribute should be filled!" + Chars.LF;
//			pAttributeInErr = ?(pAttributeInErr = "", "PaymentSection", pAttributeInErr);
//		EndIf;
//	EndIf;
//	If Sum < 0 Тогда
//		If НЕ cmCheckUserPermissions("HavePermissionToReturnPayments") Тогда
//			vHasErrors = True; 
//			vMsgTextRu = vMsgTextRu + "У вас нет прав на оформление возвратов!" + Chars.LF;
//			vMsgTextEn = vMsgTextEn + "You do not have rights to return payments!" + Chars.LF;
//			vMsgTextDe = vMsgTextDe + "You do not have rights to return payments!" + Chars.LF;
//			pAttributeInErr = ?(pAttributeInErr = "", "СпособОплаты", pAttributeInErr);
//		EndIf;
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
//		If НЕ cmCheckUserPermissions("HavePermissionToDoCashAndCreditCardPaymentsWithoutCashRegister") Тогда
//			If PaymentMethod.BookByCashRegister Тогда
//				If НЕ ЗначениеЗаполнено(CashRegister) Тогда
//					vHasErrors = True; 
//					vMsgTextRu = vMsgTextRu + "Реквизит <ККМ> должен быть заполнен!" + Chars.LF;
//					vMsgTextEn = vMsgTextEn + "<Cash register> attribute should be filled!" + Chars.LF;
//					vMsgTextDe = vMsgTextDe + "<Cash register> attribute should be filled!" + Chars.LF;
//					pAttributeInErr = ?(pAttributeInErr = "", "Касса", pAttributeInErr);
//				EndIf;
//			EndIf;
//		EndIf;
//	EndIf;
//	If ЗначениеЗаполнено(CustomerPayment) Тогда
//		If НЕ cmCheckUserPermissions("HavePermissionToReturnBasedOnFolio") Тогда
//			If ЗначениеЗаполнено(PaymentMethod) And ЗначениеЗаполнено(CustomerPayment.PaymentMethod) Тогда
//				If CustomerPayment.PaymentMethod.IsByCash And НЕ PaymentMethod.IsByCash Тогда
//					vHasErrors = True; 
//					vMsgTextRu = vMsgTextRu + "Возврат можно оформить только наличными!" + Chars.LF;
//					vMsgTextEn = vMsgTextEn + "Return could be done by cash only!" + Chars.LF;
//					vMsgTextDe = vMsgTextDe + "Return could be done by cash only!" + Chars.LF;
//					pAttributeInErr = ?(pAttributeInErr = "", "СпособОплаты", pAttributeInErr);
//				ElsIf CustomerPayment.PaymentMethod.IsByCreditCard And НЕ PaymentMethod.IsByCreditCard Тогда
//					vHasErrors = True; 
//					vMsgTextRu = vMsgTextRu + "Возврат можно оформить только на кредитную карту!" + Chars.LF;
//					vMsgTextEn = vMsgTextEn + "Return could be done by credit card only!" + Chars.LF;
//					vMsgTextDe = vMsgTextDe + "Return could be done by credit card only!" + Chars.LF;
//					pAttributeInErr = ?(pAttributeInErr = "", "СпособОплаты", pAttributeInErr);
//				ElsIf CustomerPayment.PaymentMethod.IsByBankTransfer And НЕ PaymentMethod.IsByBankTransfer Тогда
//					vHasErrors = True; 
//					vMsgTextRu = vMsgTextRu + "Возврат можно оформить только банковским платежом!" + Chars.LF;
//					vMsgTextEn = vMsgTextEn + "Return could be done by bank transfer only!" + Chars.LF;
//					vMsgTextDe = vMsgTextDe + "Return could be done by bank transfer only!" + Chars.LF;
//					pAttributeInErr = ?(pAttributeInErr = "", "СпособОплаты", pAttributeInErr);
//				EndIf;
//			EndIf;
//		EndIf;
//	EndIf;
//	If ЗначениеЗаполнено(AccountingCustomer) And AccountingCustomer.NonResident Тогда
//		If ЗначениеЗаполнено(PaymentMethod) And PaymentMethod.PrintCheque And 
//		  (PaymentMethod.IsByCash Or PaymentMethod.IsByCreditCard) Тогда
//			vHasErrors = True; 
//			vMsgTextRu = vMsgTextRu + "Принимать платежи наличными от контрагентов нерезидентов запрещено!" + Chars.LF;
//			vMsgTextEn = vMsgTextEn + "Cash Платежи are forbidden from non-resident customers!" + Chars.LF;
//			vMsgTextDe = vMsgTextDe + "Cash Платежи are forbidden from non-resident customers!" + Chars.LF;
//			pAttributeInErr = ?(pAttributeInErr = "", "СпособОплаты", pAttributeInErr);
//		EndIf;
//	EndIf;
//	If vHasErrors Тогда
//		pMessage = "ru='" + TrimAll(vMsgTextRu) + "';" + "en='" + TrimAll(vMsgTextEn) + "';" + "de='" + TrimAll(vMsgTextDe) + "';";
//	EndIf;
//	Return vHasErrors;
//EndFunction //CheckDocumentAttributes

////-----------------------------------------------------------------------------
//Процедура pmFillAuthorAndDate() Экспорт
//	Date = CurrentDate();
//	Author = ПараметрыСеанса.ТекПользователь;
//КонецПроцедуры //pmFillAuthorAndDate

////-----------------------------------------------------------------------------
//Процедура pmFillAttributesWithDefaultValues() Экспорт
//	// Fill author and document date
//	pmFillAuthorAndDate();
//	// Fill from session parameters
//	ExchangeRateDate = BegOfDay(CurrentDate());
//	If НЕ ЗначениеЗаполнено(Гостиница) Тогда
//		Гостиница = ПараметрыСеанса.ТекущаяГостиница;
//	EndIf;
//	vHotel = Гостиница;
//	If НЕ ЗначениеЗаполнено(vHotel) Тогда
//		vHotels = cmGetAllHotels();
//		vHotel = vHotels.Get(0).Гостиница;
//	EndIf;
//	If ЗначениеЗаполнено(vHotel) Тогда
//		If НЕ ЗначениеЗаполнено(PaymentCurrency) Тогда
//			PaymentCurrency = vHotel.BaseCurrency;
//			If ЗначениеЗаполнено(ПараметрыСеанса.РабочееМесто) And ЗначениеЗаполнено(ПараметрыСеанса.РабочееМесто.ВалютаПлатежейПоУмолчанию) Тогда
//				PaymentCurrency = ПараметрыСеанса.РабочееМесто.ВалютаПлатежейПоУмолчанию;
//			EndIf;
//		EndIf;
//		PaymentCurrencyExchangeRate = cmGetCurrencyExchangeRate(vHotel, PaymentCurrency, ExchangeRateDate);
//		If НЕ ЗначениеЗаполнено(Фирма) Тогда
//			Фирма = vHotel.Фирма;
//		EndIf;
//		If ЗначениеЗаполнено(Фирма) Тогда
//			VATRate = Фирма.VATRate;
//		EndIf;
//		If НЕ ЗначениеЗаполнено(PaymentMethod) Тогда
//			PaymentMethod = vHotel.PaymentMethodForCustomerPayments;
//		EndIf;
//	EndIf;
//	If ЗначениеЗаполнено(Author) And ЗначениеЗаполнено(Author.Фирма) Тогда
//		Фирма = Author.Фирма;
//	EndIf;
//КонецПроцедуры //pmFillAttributesWithDefaultValues

////-----------------------------------------------------------------------------
//Процедура pmFillInvoiceRow(pInvoiceRow, pInvoice) Экспорт
//	If ЗначениеЗаполнено(Гостиница) Тогда
//		pInvoiceRow.СчетНаОплату = pInvoice;
//		vBalance = pInvoice.GetObject().pmGetInvoiceBalance(?(ЭтоНовый(), Неопределено, New Boundary(Date, BoundaryType.Excluding)));
//		pInvoiceRow.SumInAccountingCurrency = vBalance;
//		pInvoiceRow.ВалютаРасчетов = pInvoice.ВалютаРасчетов;
//		pInvoiceRow.AccountingCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, pInvoiceRow.ВалютаРасчетов, ExchangeRateDate);
//		pInvoiceRow.Сумма = Round(cmConvertCurrencies(pInvoiceRow.SumInAccountingCurrency, pInvoiceRow.ВалютаРасчетов, pInvoiceRow.AccountingCurrencyExchangeRate, PaymentCurrency, PaymentCurrencyExchangeRate, ExchangeRateDate, Гостиница), 2);
//		pInvoiceRow.Balance = Round(cmConvertCurrencies(vBalance, pInvoiceRow.ВалютаРасчетов, pInvoiceRow.AccountingCurrencyExchangeRate, PaymentCurrency, PaymentCurrencyExchangeRate, ExchangeRateDate, Гостиница), 2);
//	EndIf;
//КонецПроцедуры //pmFillInvoiceRow

////-----------------------------------------------------------------------------
//Процедура pmFillByInvoice(pInvoice) Экспорт
//	If НЕ ЗначениеЗаполнено(pInvoice) Тогда
//		Return;
//	EndIf;
//	
//	If НЕ ЗначениеЗаполнено(ParentDoc) Тогда
//		ParentDoc = pInvoice;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(Гостиница) Тогда
//		Гостиница = Invoice.Гостиница;
//	EndIf;
//	
//	FillPropertyValues(ThisObject, pInvoice, , "Number, Date, Автор, DeletionMark, Posted, ДокОснование, Примечания");
//	AccountingCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, AccountingCurrency, ExchangeRateDate);
//	
//	// Fill payment currency from the invoice Фирма bank account
//	If ЗначениеЗаполнено(pInvoice.BankAccount) Тогда
//		If ЗначениеЗаполнено(pInvoice.BankAccount.ВалютаСчета) Тогда
//			PaymentCurrency = pInvoice.BankAccount.ВалютаСчета;
//			PaymentCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, PaymentCurrency, ExchangeRateDate);
//		Endif;
//	EndIf;
//	
//	// Fill payment method
//	PaymentMethod = Справочники.СпособОплаты.EmptyRef();
//	If ЗначениеЗаполнено(Гостиница) Тогда
//		If ЗначениеЗаполнено(Гостиница.PaymentMethodForCustomerPayments) Тогда
//			PaymentMethod = Гостиница.PaymentMethodForCustomerPayments;
//		EndIf;
//	EndIf;
//	
//	// Fill VAT rate
//	If ЗначениеЗаполнено(Фирма) Тогда
//		If ЗначениеЗаполнено(Фирма.VATRate) Тогда
//			VATRate = Фирма.VATRate;
//		EndIf;
//	EndIf;
//	
//	If ЗначениеЗаполнено(pInvoice.ГруппаГостей) Тогда
//		Invoice = pInvoice;
//		vBalance = pInvoice.GetObject().pmGetInvoiceBalance(?(ЭтоНовый(), Неопределено, New Boundary(Date, BoundaryType.Excluding)));
//		SumInAccountingCurrency = vBalance;
//		Sum = Round(cmConvertCurrencies(SumInAccountingCurrency, AccountingCurrency, AccountingCurrencyExchangeRate, PaymentCurrency, PaymentCurrencyExchangeRate, ExchangeRateDate, Гостиница), 2);
//		VATSum = cmCalculateVATSum(VATRate, Sum);
//	Else
//		vInvoiceRow = Invoices.Add();
//		pmFillInvoiceRow(vInvoiceRow, pInvoice);
//		vInvoiceGuestGroups = pInvoice.Услуги.Unload();
//		vInvoiceGuestGroups.GroupBy("ГруппаГостей", "Сумма");
//		For Each vInvoiceGuestGroupsRow In vInvoiceGuestGroups Do
//			vContractRow = Contracts.Add();
//			vContractRow.Договор = pInvoice.Договор;
//			vContractRow.ГруппаГостей = vInvoiceGuestGroupsRow.ГруппаГостей;
//			vContractRow.ВалютаРасчетов = pInvoice.ВалютаРасчетов;
//			vContractRow.AccountingCurrencyExchangeRate = pInvoice.AccountingCurrencyExchangeRate;
//			vContractRow.Сумма = vInvoiceGuestGroupsRow.Сумма;
//			vContractRow.SumInAccountingCurrency = Round(cmConvertCurrencies(vContractRow.Сумма, PaymentCurrency, PaymentCurrencyExchangeRate, vContractRow.ВалютаРасчетов, vContractRow.AccountingCurrencyExchangeRate, ExchangeRateDate, Гостиница), 2);
//		EndDo;
//	EndIf;
//КонецПроцедуры //FillByInvoice

////-----------------------------------------------------------------------------
//Процедура pmFillBySettlement(pSettlement) Экспорт
//	If НЕ ЗначениеЗаполнено(pSettlement) Тогда
//		Return;
//	EndIf;
//	
//	ParentDoc = pSettlement;
//	
//	FillPropertyValues(ThisObject, pSettlement, , "Number, Date, Автор, DeletionMark, Posted, ДокОснование, Примечания");
//	
//	// Fill payment currency from the settlement Фирма bank account
//	If ЗначениеЗаполнено(pSettlement.Фирма) Тогда
//		If ЗначениеЗаполнено(pSettlement.Фирма.BankAccount) Тогда
//			If ЗначениеЗаполнено(pSettlement.Фирма.BankAccount.ВалютаСчета) Тогда
//				PaymentCurrency = pSettlement.Фирма.BankAccount.ВалютаСчета;
//				PaymentCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, PaymentCurrency, ExchangeRateDate);
//			Endif;
//		EndIf;
//	EndIf;
//	
//	// Fill payment method
//	PaymentMethod = Справочники.СпособОплаты.EmptyRef();
//	If ЗначениеЗаполнено(Гостиница) Тогда
//		If ЗначениеЗаполнено(Гостиница.PaymentMethodForCustomerPayments) Тогда
//			PaymentMethod = Гостиница.PaymentMethodForCustomerPayments;
//		EndIf;
//	EndIf;
//	
//	// Fill VAT rate
//	If ЗначениеЗаполнено(Фирма) Тогда
//		If ЗначениеЗаполнено(Фирма.VATRate) Тогда
//			VATRate = Фирма.VATRate;
//		EndIf;
//	EndIf;
//	
//	// Fill amounts
//	SumInAccountingCurrency = pSettlement.Сумма;
//	AccountingCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, AccountingCurrency, ExchangeRateDate);
//	Sum = Round(cmConvertCurrencies(SumInAccountingCurrency, AccountingCurrency, AccountingCurrencyExchangeRate, PaymentCurrency, PaymentCurrencyExchangeRate, ExchangeRateDate, Гостиница), 2);
//	VATSum = Round(cmConvertCurrencies(pSettlement.СуммаНДС, AccountingCurrency, AccountingCurrencyExchangeRate, PaymentCurrency, PaymentCurrencyExchangeRate, ExchangeRateDate, Гостиница), 2);
//	
//	// Get settlement balance
//	vBalanceInAccountingCurrency = cmGetCustomerAccountsBalance(, AccountingCustomer, AccountingContract, GuestGroup, AccountingCurrency, Фирма, Гостиница);
//	vBalance = Round(cmConvertCurrencies(vBalanceInAccountingCurrency, AccountingCurrency, AccountingCurrencyExchangeRate, PaymentCurrency, PaymentCurrencyExchangeRate, ExchangeRateDate, Гостиница), 2);
//	
//	// Clear tabular parts
//	Invoices.Clear();
//	Contracts.Clear();
//	
//	// Select all invoices with balances for given Контрагент, contract and guest group
//	vInvoices = cmGetInvoicesWithBalances(New Boundary(Date, BoundaryType.Excluding), 
//	                                      pSettlement.Контрагент, pSettlement.Договор, pSettlement.ГруппаГостей, 
//	                                      pSettlement.ВалютаРасчетов, Фирма, Гостиница);
//	If vInvoices.Count() > 1 Тогда
//		// Fill invoices tabular part. 
//		For Each vInvoicesRow In vInvoices Do
//			vInvoiceRow = Invoices.Add();
//			vInvoiceRow.СчетНаОплату = vInvoicesRow.СчетНаОплату;
//			vInvoiceRow.ВалютаРасчетов = vInvoicesRow.ВалютаРасчетов;
//			vInvoiceRow.AccountingCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, vInvoiceRow.ВалютаРасчетов, ExchangeRateDate);
//			vInvoiceRow.Balance = Round(cmConvertCurrencies(vInvoicesRow.Balance, vInvoiceRow.ВалютаРасчетов, vInvoiceRow.AccountingCurrencyExchangeRate, PaymentCurrency, PaymentCurrencyExchangeRate, ExchangeRateDate, Гостиница), 2);
//			// User have to map settlement sum manually
//			vInvoiceRow.SumInAccountingCurrency = 0;
//			vInvoiceRow.Сумма = 0;
//		EndDo;
//		// Fill contracts tabular part
//		vContractRow = Contracts.Add();
//		FillPropertyValues(vContractRow, ThisObject);
//		vContractRow.Balance = vBalance;
//	Else
//		If vInvoices.Count() = 1 Тогда
//			vInvoiceRow = vInvoices.Get(0);
//			Invoice = vInvoiceRow.СчетНаОплату;
//		EndIf;
//	EndIf;
//КонецПроцедуры //pmFillBySettlement

////-----------------------------------------------------------------------------
//Процедура pmFillByCustomer(pCustomer, pFillInvoices = True, pFillCurrencies = True) Экспорт
//	If НЕ ЗначениеЗаполнено(pCustomer) Тогда
//		Return;
//	EndIf;
//	
//	AccountingCustomer = pCustomer;
//	
//	ParentDoc = Неопределено;
//	
//	// Fill payment currency from the Фирма bank account
//	If ЗначениеЗаполнено(Фирма) Тогда
//		If ЗначениеЗаполнено(Фирма.BankAccount) Тогда
//			If ЗначениеЗаполнено(Фирма.BankAccount.ВалютаСчета) Тогда
//				If pFillCurrencies And ЗначениеЗаполнено(Гостиница) Тогда
//					PaymentCurrency = Фирма.BankAccount.ВалютаСчета;
//					PaymentCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, PaymentCurrency, ExchangeRateDate);
//				EndIf;
//			Endif;
//		EndIf;
//	EndIf;
//	
//	// Fill payment method
//	If pFillCurrencies Тогда
//		If ЗначениеЗаполнено(Гостиница) Тогда
//			PaymentMethod = Справочники.СпособОплаты.EmptyRef();
//			If ЗначениеЗаполнено(Гостиница.PaymentMethodForCustomerPayments) Тогда
//				PaymentMethod = Гостиница.PaymentMethodForCustomerPayments;
//			EndIf;
//		EndIf;
//	EndIf;
//	
//	// Fill VAT rate
//	If ЗначениеЗаполнено(Фирма) Тогда
//		If ЗначениеЗаполнено(Фирма.VATRate) Тогда
//			VATRate = Фирма.VATRate;
//		EndIf;
//	EndIf;
//	
//	If НЕ ЗначениеЗаполнено(Гостиница) Тогда
//		Return;
//	EndIf;
//	
//	// Fill contracts tabular part
//	// Select all Контрагент accounts balances for given Контрагент, Фирма and hotel
//	vCustomerAccounts = cmGetCustomerAccountsBalances(?(ЭтоНовый(), Неопределено, New Boundary(Date, BoundaryType.Excluding)), 
//	                                                  AccountingCustomer, , , 
//	                                                  ?(pFillCurrencies, AccountingCustomer.AccountingCurrency, AccountingCurrency), Фирма, Гостиница, False);
//	// Group balances by Контрагент and contract if necessary
//	If vCustomerAccounts.Count() > 0 Тогда
//		If vCustomerAccounts.Count() > 1 Тогда
//			If pFillCurrencies Тогда
//				AccountingCurrency = AccountingCustomer.AccountingCurrency;
//				AccountingCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, AccountingCurrency, ExchangeRateDate);
//			EndIf;
//			For Each vCustomerAccountsRow In vCustomerAccounts Do
//				vContractRow = Contracts.Add();
//				vContractRow.Договор = vCustomerAccountsRow.Договор;
//				vContractRow.ГруппаГостей = vCustomerAccountsRow.ГруппаГостей;
//				vContractRow.ВалютаРасчетов = vCustomerAccountsRow.ВалютаРасчетов;
//				vContractRow.AccountingCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, vContractRow.ВалютаРасчетов, ExchangeRateDate);
//				vContractRow.Balance = Round(cmConvertCurrencies(vCustomerAccountsRow.Balance, vContractRow.ВалютаРасчетов, vContractRow.AccountingCurrencyExchangeRate, PaymentCurrency, PaymentCurrencyExchangeRate, ExchangeRateDate, Гостиница), 2);
//				// User have to map payment manually
//				vContractRow.SumInAccountingCurrency = 0;
//				vContractRow.Сумма = 0;
//			EndDo;
//		Else
//			vCustomerAccountsRow = vCustomerAccounts.Get(0);
//			AccountingContract = vCustomerAccountsRow.Договор;
//			GuestGroup = vCustomerAccountsRow.ГруппаГостей;
//			If pFillCurrencies Тогда
//				AccountingCurrency = vCustomerAccountsRow.ВалютаРасчетов;
//				AccountingCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, AccountingCurrency, ExchangeRateDate);
//			EndIf;
//			// User have to map payment manually
//			SumInAccountingCurrency = vCustomerAccountsRow.Balance;
//			Sum = Round(cmConvertCurrencies(vCustomerAccountsRow.Balance, AccountingCurrency, AccountingCurrencyExchangeRate, PaymentCurrency, PaymentCurrencyExchangeRate, ExchangeRateDate, Гостиница), 2);
//		EndIf;		
//	Else
//		AccountingContract = Справочники.Договора.EmptyRef();
//		GuestGroup = Справочники.ГруппыГостей.EmptyRef();
//		If pFillCurrencies Тогда
//			AccountingCurrency = AccountingCustomer.AccountingCurrency;
//			AccountingCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, AccountingCurrency, ExchangeRateDate);
//		EndIf;
//		SumInAccountingCurrency = 0;
//		Sum = 0;
//	EndIf;
//	
//	// Fill invoices tabular part
//	If pFillInvoices Тогда
//		// Select all invoices with balances for given Контрагент, Фирма and hotel
//		vInvoices = cmGetInvoicesWithBalances(?(ЭтоНовый(), Неопределено, New Boundary(Date, BoundaryType.Excluding)), 
//		                                      AccountingCustomer, , , 
//		                                      ?(pFillCurrencies, AccountingCustomer.AccountingCurrency, AccountingCurrency), Фирма, Гостиница);
//		If vInvoices.Count() > 0 Тогда									  
//			If vInvoices.Count() > 1 Тогда
//				For Each vInvoicesRow In vInvoices Do
//					vInvoiceRow = Invoices.Add();
//					vInvoiceRow.СчетНаОплату = vInvoicesRow.СчетНаОплату;
//					vInvoiceRow.ВалютаРасчетов = vInvoicesRow.ВалютаРасчетов;
//					vInvoiceRow.AccountingCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, vInvoiceRow.ВалютаРасчетов, ExchangeRateDate);
//					vInvoiceRow.Balance = Round(cmConvertCurrencies(vInvoicesRow.Balance, vInvoiceRow.ВалютаРасчетов, vInvoiceRow.AccountingCurrencyExchangeRate, PaymentCurrency, PaymentCurrencyExchangeRate, ExchangeRateDate, Гостиница), 2);
//					
//					// User have to map payment manually
//					vInvoiceRow.SumInAccountingCurrency = 0;
//					vInvoiceRow.Сумма = 0;
//					
//					// Fill appropriate contract row
//					pmCalculateCustomerAccountsMapForInvoice(vInvoiceRow);
//				EndDo;
//			Else
//				vInvoicesRow = vInvoices.Get(0);
//				AccountingContract = vInvoicesRow.Договор;
//				GuestGroup = vInvoicesRow.ГруппаГостей;
//				Invoice = vInvoicesRow.СчетНаОплату;
//				If pFillCurrencies Тогда
//					AccountingCurrency = vInvoicesRow.ВалютаРасчетов;
//					AccountingCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, AccountingCurrency, ExchangeRateDate);
//				EndIf;
//				vBalanceInAccountingCurrency = vInvoicesRow.Balance;
//				vBalance = Round(cmConvertCurrencies(vBalanceInAccountingCurrency, AccountingCurrency, AccountingCurrencyExchangeRate, PaymentCurrency, PaymentCurrencyExchangeRate, ExchangeRateDate, Гостиница), 2);
//				SumInAccountingCurrency = vBalanceInAccountingCurrency;
//				Sum = vBalance;
//			EndIf;
//		EndIf;
//	EndIf;
//КонецПроцедуры //pmFillByCustomer

////-----------------------------------------------------------------------------
//Процедура pmFillByContract(pContract, pFillInvoices = True, pFillCurrencies = True) Экспорт
//	If НЕ ЗначениеЗаполнено(pContract) Тогда
//		Return;
//	EndIf;
//	
//	AccountingCustomer = pContract.Owner;
//	AccountingContract = pContract;
//	
//	ParentDoc = Неопределено;
//	
//	// Fill payment currency from the Фирма bank account
//	If ЗначениеЗаполнено(Фирма) Тогда
//		If ЗначениеЗаполнено(Фирма.BankAccount) Тогда
//			If ЗначениеЗаполнено(Фирма.BankAccount.ВалютаСчета) Тогда
//				If pFillCurrencies And ЗначениеЗаполнено(Гостиница) Тогда
//					PaymentCurrency = Фирма.BankAccount.ВалютаСчета;
//					PaymentCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, PaymentCurrency, ExchangeRateDate);
//				EndIf;
//			Endif;
//		EndIf;
//	EndIf;
//	
//	// Fill payment method
//	If pFillCurrencies Тогда
//		If ЗначениеЗаполнено(Гостиница) Тогда
//			PaymentMethod = Справочники.СпособОплаты.EmptyRef();
//			If ЗначениеЗаполнено(Гостиница.PaymentMethodForCustomerPayments) Тогда
//				PaymentMethod = Гостиница.PaymentMethodForCustomerPayments;
//			EndIf;
//		EndIf;
//	EndIf;
//	
//	// Fill VAT rate
//	If ЗначениеЗаполнено(Фирма) Тогда
//		If ЗначениеЗаполнено(Фирма.VATRate) Тогда
//			VATRate = Фирма.VATRate;
//		EndIf;
//	EndIf;
//	
//	If НЕ ЗначениеЗаполнено(Гостиница) Тогда
//		Return;
//	EndIf;
//	
//	// Fill contracts tabular part
//	// Select all Контрагент accounts balances for given Контрагент, contract, Фирма and hotel
//	vCustomerAccounts = cmGetCustomerAccountsBalances(?(ЭтоНовый(), Неопределено, New Boundary(Date, BoundaryType.Excluding)), 
//	                                                  AccountingCustomer, pContract, , 
//	                                                  ?(pFillCurrencies, pContract.ВалютаРасчетов, AccountingCurrency), Фирма, Гостиница, False);
//	// Group balances by Контрагент and contract if necessary
//	If vCustomerAccounts.Count() > 0 Тогда
//		If vCustomerAccounts.Count() > 1 Тогда
//			If pFillCurrencies Тогда
//				AccountingCurrency = pContract.ВалютаРасчетов;
//				AccountingCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, AccountingCurrency, ExchangeRateDate);
//			EndIf;
//			For Each vCustomerAccountsRow In vCustomerAccounts Do
//				vContractRow = Contracts.Add();
//				vContractRow.Договор = vCustomerAccountsRow.Договор;
//				vContractRow.ГруппаГостей = vCustomerAccountsRow.ГруппаГостей;
//				vContractRow.ВалютаРасчетов = vCustomerAccountsRow.ВалютаРасчетов;
//				vContractRow.AccountingCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, vContractRow.ВалютаРасчетов, ExchangeRateDate);
//				vContractRow.Balance = Round(cmConvertCurrencies(vCustomerAccountsRow.Balance, vContractRow.ВалютаРасчетов, vContractRow.AccountingCurrencyExchangeRate, PaymentCurrency, PaymentCurrencyExchangeRate, ExchangeRateDate, Гостиница), 2);
//			
//				// User have to map payment manually
//				vContractRow.SumInAccountingCurrency = 0;
//				vContractRow.Сумма = 0;
//			EndDo;
//		Else
//			vCustomerAccountsRow = vCustomerAccounts.Get(0);
//			GuestGroup = vCustomerAccountsRow.ГруппаГостей;
//			If pFillCurrencies Тогда
//				AccountingCurrency = vCustomerAccountsRow.ВалютаРасчетов;
//				AccountingCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, AccountingCurrency, ExchangeRateDate);
//			EndIf;
//			vBalanceInAccountingCurrency = vCustomerAccountsRow.Balance;
//			vBalance = Round(cmConvertCurrencies(vBalanceInAccountingCurrency, AccountingCurrency, AccountingCurrencyExchangeRate, PaymentCurrency, PaymentCurrencyExchangeRate, ExchangeRateDate, Гостиница), 2);
//			
//			// User have to map payment manually
//			SumInAccountingCurrency = vBalanceInAccountingCurrency;
//			Sum = vBalance;
//		EndIf;
//	Else
//		GuestGroup = Справочники.ГруппыГостей.EmptyRef();
//		If pFillCurrencies Тогда
//			AccountingCurrency = pContract.ВалютаРасчетов;
//			AccountingCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, AccountingCurrency, ExchangeRateDate);
//		EndIf;
//		SumInAccountingCurrency = 0;
//		Sum = 0;
//	EndIf;
//	
//	// Fill invoices tabular part
//	If pFillInvoices Тогда
//		// Select all invoices with balances for given Контрагент, contract, Фирма and hotel
//		vInvoices = cmGetInvoicesWithBalances(?(ЭтоНовый(), Неопределено, New Boundary(Date, BoundaryType.Excluding)), 
//		                                      AccountingCustomer, pContract, , 
//		                                      ?(pFillCurrencies, pContract.ВалютаРасчетов, AccountingCurrency), Фирма, Гостиница);
//		If vInvoices.Count() > 0 Тогда									  
//			If vInvoices.Count() > 1 Тогда
//				For Each vInvoicesRow In vInvoices Do
//					vInvoiceRow = Invoices.Add();
//					vInvoiceRow.СчетНаОплату = vInvoicesRow.СчетНаОплату;
//					vInvoiceRow.ВалютаРасчетов = vInvoicesRow.ВалютаРасчетов;
//					vInvoiceRow.AccountingCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, vInvoiceRow.ВалютаРасчетов, ExchangeRateDate);
//					vInvoiceRow.Balance = Round(cmConvertCurrencies(vInvoicesRow.Balance, vInvoiceRow.ВалютаРасчетов, vInvoiceRow.AccountingCurrencyExchangeRate, PaymentCurrency, PaymentCurrencyExchangeRate, ExchangeRateDate, Гостиница), 2);
//					
//					// User have to map payment manually
//					vInvoiceRow.SumInAccountingCurrency = 0;
//					vInvoiceRow.Сумма = 0;
//					
//					// Fill appropriate contract row
//					pmCalculateCustomerAccountsMapForInvoice(vInvoiceRow);
//				EndDo;
//			Else
//				vInvoicesRow = vInvoices.Get(0);
//				GuestGroup = vInvoicesRow.ГруппаГостей;
//				Invoice = vInvoicesRow.СчетНаОплату;
//				If pFillCurrencies Тогда
//					AccountingCurrency = vInvoicesRow.ВалютаРасчетов;
//					AccountingCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, AccountingCurrency, ExchangeRateDate);
//				EndIf;
//				vBalanceInAccountingCurrency = vInvoicesRow.Balance;
//				vBalance = Round(cmConvertCurrencies(vBalanceInAccountingCurrency, AccountingCurrency, AccountingCurrencyExchangeRate, PaymentCurrency, PaymentCurrencyExchangeRate, ExchangeRateDate, Гостиница), 2);
//				SumInAccountingCurrency = vBalanceInAccountingCurrency;
//				Sum = vBalance;
//			EndIf;
//		EndIf;
//	EndIf;
//КонецПроцедуры //pmFillByContract

////-----------------------------------------------------------------------------
//// This is return based on previous payment
////-----------------------------------------------------------------------------
//Процедура pmFillByCustomerPayment(pPayment) Экспорт
//	If НЕ ЗначениеЗаполнено(pPayment) Тогда
//		Return;
//	EndIf;
//	If НЕ cmCheckUserPermissions("HavePermissionToReturnPayments") Тогда
//		ВызватьИсключение NStr("en='You do not have rights to return payments!';
//		           |ru='У вас нет прав на оформление возвратов!';
//				   |de='Sie haben keine Rechte, eine Rückvergütung zu realisieren!'");
//	EndIf;
//	
//	FillPropertyValues(ThisObject, pPayment, , "Number, Date, Автор, DeletionMark, Posted, Примечания, AuthorizationCode, ReferenceNumber, SlipText, AnnulationSlipText, TypeOfAnnulation, AuthorOfAnnulation, DateOfAnnulation, ExternalCode");
//	
//	CustomerPayment = pPayment;
//	
//	// Fill tabular parts and invert sums in there
//	For Each vInvoiceRow In pPayment.Invoices Do
//		vRow = Invoices.Add();
//		FillPropertyValues(vRow, vInvoiceRow);
//		vRow.Сумма = -vRow.Сумма;
//		vRow.SumInAccountingCurrency = -vRow.SumInAccountingCurrency;
//		If ЗначениеЗаполнено(vRow.СчетНаОплату) And ЗначениеЗаполнено(Гостиница) Тогда
//			vBalance = vRow.СчетНаОплату.GetObject().pmGetInvoiceBalance();
//			vRow.Balance = Round(cmConvertCurrencies(vBalance, vRow.ВалютаРасчетов, vRow.AccountingCurrencyExchangeRate, PaymentCurrency, PaymentCurrencyExchangeRate, ExchangeRateDate, Гостиница), 2);
//		Else
//			vRow.Balance = 0;
//		EndIf;
//	EndDo;
//	For Each vContractRow In pPayment.Договора Do
//		vRow = Contracts.Add();
//		FillPropertyValues(vRow, vContractRow);
//		vRow.Сумма = -vRow.Сумма;
//		vRow.SumInAccountingCurrency = -vRow.SumInAccountingCurrency;
//		If ЗначениеЗаполнено(Гостиница) Тогда
//			vBalance = cmGetCustomerAccountsBalance(, AccountingCustomer, vRow.Договор, vRow.ГруппаГостей, vRow.ВалютаРасчетов, Фирма, Гостиница);
//			vRow.Balance = Round(cmConvertCurrencies(vBalance, vRow.ВалютаРасчетов, vRow.AccountingCurrencyExchangeRate, PaymentCurrency, PaymentCurrencyExchangeRate, ExchangeRateDate, Гостиница), 2);
//		Else
//			vRow.Balance = 0;
//		EndIf;
//	EndDo;
//	
//	// Invert amounts
//	Sum = -Sum;
//	VATSum = -VATSum;
//	SumInAccountingCurrency = -SumInAccountingCurrency;
//КонецПроцедуры //pmFillByCustomerPayment

////-----------------------------------------------------------------------------
//Процедура pmFillTabularParts(pFillInvoices = True) Экспорт
//	// Clear tabular parts
//	Invoices.Clear();
//	Contracts.Clear();
//	// Refill tabular parts
//	If ЗначениеЗаполнено(CustomerPayment) Тогда
//		// This is return based on previous payment
//		pmFillByCustomerPayment(CustomerPayment);
//	Else
//		If ЗначениеЗаполнено(ParentDoc) Тогда
//			If TypeOf(ParentDoc) = Type("DocumentRef.СчетНаОплату") Тогда
//				pmFillByInvoice(ParentDoc);
//			ElsIf TypeOf(ParentDoc) = Type("DocumentRef.Акт") Тогда
//				pmFillBySettlement(ParentDoc);
//			EndIf
//		Else
//			If ЗначениеЗаполнено(AccountingCustomer) Тогда
//				pmFillByCustomer(AccountingCustomer, pFillInvoices);
//			EndIf;
//		EndIf;
//	EndIf;
//	// Recalculate totals
//	pmCalculateSums();
//КонецПроцедуры //pmFillTabularParts

////-----------------------------------------------------------------------------
//// Set default payment method for return
////-----------------------------------------------------------------------------
//Процедура pmSetDefaultPaymentMethodForReturn() Экспорт
//	If ЗначениеЗаполнено(PaymentMethod) Тогда
//		vQry = New Query();
//		vQry.Text = 
//		"SELECT
//		|	СпособОплаты.Ref
//		|FROM
//		|	Catalog.СпособОплаты AS СпособОплаты
//		|WHERE
//		|	(NOT СпособОплаты.DeletionMark)
//		|	AND (СпособОплаты.IsForReturnOnly
//		|			OR &qIgnoreForReturnOnly)
//		|	AND СпособОплаты.IsByCash = &qIsByCash
//		|	AND СпособОплаты.IsByCreditCard = &qIsByCreditCard
//		|	AND СпособОплаты.IsByBankTransfer = &qIsByBankTransfer
//		|ORDER BY
//		|	СпособОплаты.ПорядокСортировки";
//		vQry.SetParameter("qIsByCash", PaymentMethod.IsByCash);
//		vQry.SetParameter("qIsByCreditCard", PaymentMethod.IsByCreditCard);
//		vQry.SetParameter("qIsByBankTransfer", PaymentMethod.IsByBankTransfer);
//		vQry.SetParameter("qIgnoreForReturnOnly", ?(ЗначениеЗаполнено(CashRegister), CashRegister.CashReturnDirectlyFromCashBoxIsAllowed, False));
//		vPMs = vQry.Execute().Unload();
//		If vPMs.Count() > 0 Тогда
//			PaymentMethod = vPMs.Get(0).Ref;
//		EndIf;
//	Else
//		vQry = New Query();
//		vQry.Text = 
//		"SELECT
//		|	СпособОплаты.Ref
//		|FROM
//		|	Catalog.СпособОплаты AS СпособОплаты
//		|WHERE
//		|	(NOT СпособОплаты.DeletionMark)
//		|	AND (СпособОплаты.IsForReturnOnly
//		|			OR &qIgnoreForReturnOnly)
//		|ORDER BY
//		|	СпособОплаты.ПорядокСортировки";
//		vQry.SetParameter("qIgnoreForReturnOnly", ?(ЗначениеЗаполнено(CashRegister), CashRegister.CashReturnDirectlyFromCashBoxIsAllowed, False));
//		vPMs = vQry.Execute().Unload();
//		If vPMs.Count() > 0 Тогда
//			PaymentMethod = vPMs.Get(0).Ref;
//		EndIf;
//	EndIf;
//КонецПроцедуры //pmSetDefaultPaymentMethodForReturn

////-----------------------------------------------------------------------------
//Процедура Filling(pBase)
//	vOldHotel = Гостиница;
//	vOldCompany = Фирма;
//	// Fill attributes with default values
//	If ЭтоНовый() Тогда
//		pmFillAttributesWithDefaultValues();
//	EndIf;
//	// Fill from the base
//	If ЗначениеЗаполнено(pBase) Тогда
//		If TypeOf(pBase) = Type("DocumentRef.СчетНаОплату") Тогда
//			pmFillByInvoice(pBase);
//		ElsIf TypeOf(pBase) = Type("DocumentRef.Акт") Тогда
//			pmFillBySettlement(pBase);
//		ElsIf TypeOf(pBase) = Type("CatalogRef.Контрагенты") Тогда
//			pmFillByCustomer(pBase, True);
//		ElsIf TypeOf(pBase) = Type("CatalogRef.Договора") Тогда
//			pmFillByContract(pBase, True);
//		ElsIf TypeOf(pBase) = Type("DocumentRef.ПлатежКонтрагента") Тогда
//			pmFillByCustomerPayment(pBase);
//		EndIf;
//	EndIf;
//	// If return, then try to set up special payment method for return
//	pmSetDefaultPaymentMethodForReturn();
//КонецПроцедуры //Filling

////-----------------------------------------------------------------------------
//Процедура pmCalculateCustomerAccountsMapForInvoice(pCurRow) Экспорт
//	If НЕ ЗначениеЗаполнено(pCurRow.СчетНаОплату) Тогда
//		Return;
//	EndIf;
//	// Fill guest group for invoices
//	vContractRowSum = 0;
//	vCurContract = pCurRow.СчетНаОплату.Договор;
//	vCurGuestGroup = pCurRow.СчетНаОплату.ГруппаГостей;
//	vInvoices = Invoices.Unload();
//	vInvoices.Columns.Add("Договор", cmGetCatalogTypeDescription("Договора"));
//	vInvoices.Columns.Add("ГруппаГостей", cmGetCatalogTypeDescription("ГруппыГостей"));
//	For Each vRow In vInvoices Do
//		If ЗначениеЗаполнено(vRow.Invoice) Тогда
//			vRow.AccountingContract = vRow.Invoice.Договор;
//			vRow.GuestGroup = vRow.Invoice.ГруппаГостей;
//		EndIf;
//	EndDo;
//	vInvoices.GroupBy("Договор, ГруппаГостей", "Сумма");
//	vRows = vInvoices.FindRows(New Structure("Договор, ГруппаГостей", vCurContract, vCurGuestGroup));
//	If vRows.Count() = 0 Тогда
//		vInvoices.GroupBy("Договор", "Сумма");
//		vRows = vInvoices.FindRows(New Structure("Договор", vCurContract));
//	EndIf;
//	If vRows.Count() > 0 Тогда
//		For Each vRow In vRows Do
//			vContractRowSum = vContractRowSum + vRow.Сумма;
//		EndDo;
//	EndIf;
//	// Check if there is suitable row in contracts. Create it if not
//	vContractRow = Неопределено;
//	For Each vRow In Contracts Do
//		If pCurRow.СчетНаОплату.Договор = vRow.AccountingContract And
//		   pCurRow.СчетНаОплату.ГруппаГостей = vRow.GuestGroup And
//		   pCurRow.ВалютаРасчетов = vRow.AccountingCurrency Тогда
//			vContractRow = vRow;
//			Break;
//		EndIf;
//	EndDo;
//	If vContractRow = Неопределено Тогда
//		vContractRow = Contracts.Add();
//	EndIf;
//	vContractRow.Договор = pCurRow.СчетНаОплату.Договор;
//	vContractRow.ГруппаГостей = pCurRow.СчетНаОплату.ГруппаГостей;
//	vContractRow.ВалютаРасчетов = pCurRow.ВалютаРасчетов;
//	vContractRow.Сумма = vContractRowSum;
//	If ЗначениеЗаполнено(Гостиница) Тогда
//		vContractRow.SumInAccountingCurrency = Round(cmConvertCurrencies(vContractRow.Сумма, PaymentCurrency, PaymentCurrencyExchangeRate, vContractRow.ВалютаРасчетов, vContractRow.AccountingCurrencyExchangeRate, ExchangeRateDate, Гостиница), 2);
//	Else
//		vContractRow.SumInAccountingCurrency = vContractRow.Сумма;
//	EndIf;
//КонецПроцедуры //pmCalculateCustomerAccountsMapForInvoice

////-----------------------------------------------------------------------------
//Процедура pmCalculateSums() Экспорт
//	If Contracts.Count() > 0 Тогда
//		vSum = Contracts.Total("Сумма");
//		If vSum <> Sum Тогда
//			Sum = vSum;
//		EndIf;
//		vSumInAccountingCurrency = Contracts.Total("SumInAccountingCurrency");
//		If SumInAccountingCurrency <> vSumInAccountingCurrency Тогда
//			SumInAccountingCurrency = vSumInAccountingCurrency;
//		EndIf;
//	EndIf;
//	vVATSum = cmCalculateVATSum(VATRate, Sum);
//	If vVATSum <> VATSum Тогда
//		VATSum = vVATSum;
//	EndIf;
//КонецПроцедуры //pmCalculateSums

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
//	Else
//		If DeletionMark Тогда
//			WriteLogEvent(NStr("en='SuspiciousEvents.CustomerPaymentSetDeletionMark';de='SuspiciousEvents.CustomerPaymentSetDeletionMark';ru='СигналыОПодозрительныхДействиях.УстановкаПометкиНаУдалениеВПлатежеКонтрагента'"), EventLogLevel.Warning, Metadata(), Ref, NStr("en='Set document deletion mark';ru='Установка отметки удаления';de='Erstellung der Löschmarkierung'"));
//			AuthorOfAnnulation = ПараметрыСеанса.ТекПользователь;
//			DateOfAnnulation = CurrentDate();
//		EndIf;
//	EndIf;
//	WasPosted = Posted;
//КонецПроцедуры //BeforeWrite

////-----------------------------------------------------------------------------
//Процедура BeforeDelete(pCancel)
//	If ThisObject.DataExchange.Load Тогда
//		Return;
//	EndIf;
//	// Write log event
//	WriteLogEvent(NStr("en='SuspiciousEvents.CustomerPaymentDeletion';de='SuspiciousEvents.CustomerPaymentDeletion';ru='СигналыОПодозрительныхДействиях.УдалениеПлатежаКонтрагента'"), EventLogLevel.Warning, Metadata(), Ref, NStr("en='Document deletion';ru='Непосредственное удаление';de='Unmittelbare Löschung'"));
//КонецПроцедуры //BeforeDelete

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

////-----------------------------------------------------------------------------
//Процедура OnCopy(pCopiedObject)
//	ExternalCode = "";
//КонецПроцедуры //OnCopy

////-----------------------------------------------------------------------------
//WasPosted = True;
