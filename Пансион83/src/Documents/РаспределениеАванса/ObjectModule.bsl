//-----------------------------------------------------------------------------
Процедура PostToInvoiceAccounts()
	For Each vRow In GuestGroups Do
		If НЕ ЗначениеЗаполнено(vRow.Invoice) Тогда
			Continue;
		ElsIf vRow.Сумма = 0 Тогда
			Continue;
		EndIf;
		
		Movement = RegisterRecords.ВзаиморасчетыПоСчетам.Add();
		
		Movement.RecordType = AccumulationRecordType.Expense;
		Movement.Period = Date;
		
		FillPropertyValues(Movement, ThisObject);
		FillPropertyValues(Movement, vRow.Invoice);
		FillPropertyValues(Movement, vRow);
		
		// Attributes
		Movement.УчетнаяДата = BegOfDay(Date);
	EndDo;

	RegisterRecords.ВзаиморасчетыПоСчетам.Write();
КонецПроцедуры //PostToInvoiceAccounts

//-----------------------------------------------------------------------------
Процедура PostToCustomerAccounts() 
	For Each vRow In GuestGroups Do
		If НЕ ЗначениеЗаполнено(vRow.Invoice) And НЕ ЗначениеЗаполнено(vRow.GuestGroup) Тогда
			Continue;
		ElsIf vRow.Сумма = 0 Тогда
			Continue;
		EndIf;
		
		// Add movement to write off sum from Контрагент advance
		Movement = RegisterRecords.ВзаиморасчетыКонтрагенты.Add();
		Movement.RecordType = AccumulationRecordType.Expense;
		Movement.Period = Date;
		// Dimensions
		FillPropertyValues(Movement, ThisObject);
		If ЗначениеЗаполнено(vRow.Invoice) Тогда
			FillPropertyValues(Movement, vRow.Invoice);
		Else
			FillPropertyValues(Movement, vRow);
		EndIf;
		Movement.Договор = AccountingContract;
		Movement.ГруппаГостей = Справочники.ГруппыГостей.EmptyRef();
		Movement.Гостиница = Гостиница;
		// Resources
		Movement.Сумма = -vRow.Сумма;
		// Attributes
		Movement.УчетнаяДата = BegOfDay(Date);
		
		// Add movement to move sum to the guest group
		Movement = RegisterRecords.ВзаиморасчетыКонтрагенты.Add();
		Movement.RecordType = AccumulationRecordType.Expense;
		Movement.Period = Date;
		// Dimensions
		FillPropertyValues(Movement, ThisObject);
		If ЗначениеЗаполнено(vRow.Invoice) Тогда
			FillPropertyValues(Movement, vRow.Invoice);
			If ЗначениеЗаполнено(vRow.AccountingContract) Тогда
				Movement.Договор = vRow.AccountingContract;
			EndIf;
			If ЗначениеЗаполнено(vRow.GuestGroup) Тогда
				Movement.ГруппаГостей = vRow.GuestGroup;
			EndIf;
		Else
			FillPropertyValues(Movement, vRow);
			If ЗначениеЗаполнено(vRow.GuestGroup) Тогда
				Movement.Гостиница = vRow.GuestGroup.Owner;
			EndIf;
		EndIf;
		// Resources
		Movement.Сумма = vRow.Сумма;
		// Attributes
		Movement.УчетнаяДата = BegOfDay(Date);
	EndDo;

	RegisterRecords.ВзаиморасчетыКонтрагенты.Write();
КонецПроцедуры //PostToCustomerAccounts

//-----------------------------------------------------------------------------
Процедура Posting(pCancel, pMode)
	If ThisObject.DataExchange.Load Тогда
		Return;
	EndIf;
	
	// 1. Post to Invoice accounts
	PostToInvoiceAccounts();
	
	// 2. Post to Контрагент accounts
	PostToCustomerAccounts();
КонецПроцедуры //Posting

//-----------------------------------------------------------------------------
Function pmCheckDocumentAttributes(pMessage, pAttributeInErr) Экспорт
	vHasErrors = False;
	pMessage = "";
	pAttributeInErr = "";
	vMsgTextRu = "";
	vMsgTextEn = "";
	vMsgTextDe = "";
	If НЕ ЗначениеЗаполнено(Фирма) Тогда
		vHasErrors = True; 
		vMsgTextRu = vMsgTextRu + "Реквизит <Фирма> должен быть заполнен!" + Chars.LF;
		vMsgTextEn = vMsgTextEn + "<Фирма> attribute should be filled!" + Chars.LF;
		vMsgTextDe = vMsgTextDe + "<Фирма> attribute should be filled!" + Chars.LF;
		pAttributeInErr = ?(pAttributeInErr = "", "Фирма", pAttributeInErr);
	EndIf;
	If НЕ ЗначениеЗаполнено(AccountingCustomer) Тогда
		vHasErrors = True; 
		vMsgTextRu = vMsgTextRu + "Реквизит <Контрагент> должен быть заполнен!" + Chars.LF;
		vMsgTextEn = vMsgTextEn + "<Контрагент> attribute should be filled!" + Chars.LF;
		vMsgTextDe = vMsgTextDe + "<Контрагент> attribute should be filled!" + Chars.LF;
		pAttributeInErr = ?(pAttributeInErr = "", "Контрагент", pAttributeInErr);
	EndIf;
	If НЕ ЗначениеЗаполнено(AccountingCurrency) Тогда
		vHasErrors = True; 
		vMsgTextRu = vMsgTextRu + "Реквизит <Валюта взаиморасчетов> должен быть заполнен!" + Chars.LF;
		vMsgTextEn = vMsgTextEn + "<Accounting Валюта> attribute should be filled!" + Chars.LF;
		vMsgTextDe = vMsgTextDe + "<Accounting Валюта> attribute should be filled!" + Chars.LF;
		pAttributeInErr = ?(pAttributeInErr = "", "ВалютаРасчетов", pAttributeInErr);
	EndIf;
	If SumAdvance < GuestGroups.Total("Сумма") Тогда
		vHasErrors = True; 
		vMsgTextRu = vMsgTextRu + "Распределена сумма больше чем сумма аванса у контрагента!" + Chars.LF;
		vMsgTextEn = vMsgTextEn + "You have distributed amount that greater then Контрагент advance amount!" + Chars.LF;
		vMsgTextDe = vMsgTextDe + "You have distributed amount that greater then Контрагент advance amount!" + Chars.LF;
		pAttributeInErr = ?(pAttributeInErr = "", "ГруппыГостей", pAttributeInErr);
	EndIf;
	If vHasErrors Тогда
		pMessage = "ru='" + TrimAll(vMsgTextRu) + "';" + "en='" + TrimAll(vMsgTextEn) + "';" + "de='" + TrimAll(vMsgTextDe) + "';";
	EndIf;
	Return vHasErrors;
EndFunction //CheckDocumentAttributes

//-----------------------------------------------------------------------------
Процедура pmFillAuthorAndDate() Экспорт
	Date = CurrentDate();
	Author = ПараметрыСеанса.ТекПользователь;
КонецПроцедуры //pmFillAuthorAndDate

//-----------------------------------------------------------------------------
Процедура pmFillAttributesWithDefaultValues() Экспорт
	// Fill author and document date
	pmFillAuthorAndDate();
	// Fill from session parameters
	If НЕ ЗначениеЗаполнено(Гостиница) Тогда
		Гостиница = ПараметрыСеанса.ТекущаяГостиница;
	EndIf;
	vHotel = Гостиница;
//	If НЕ ЗначениеЗаполнено(vHotel) Тогда
//		vHotels = cmGetAllHotels();
//		vHotel = vHotels.Get(0).Гостиница;
//	EndIf;
	If ЗначениеЗаполнено(vHotel) Тогда
		If НЕ ЗначениеЗаполнено(AccountingCurrency) Тогда
			AccountingCurrency = vHotel.BaseCurrency;
		EndIf;
		If НЕ ЗначениеЗаполнено(Фирма) Тогда
			Фирма = vHotel.Фирма;
		EndIf;
	EndIf;
	If ЗначениеЗаполнено(Author) And ЗначениеЗаполнено(Author.Company) Тогда
		Фирма = Author.Фирма;
	EndIf;
	If НЕ ЗначениеЗаполнено(OperationType) Тогда
		OperationType = Перечисления.AdvanceDistributionTypes.ByInvoices;
	EndIf;
КонецПроцедуры //pmFillAttributesWithDefaultValues

//-----------------------------------------------------------------------------


//-----------------------------------------------------------------------------
Процедура pmFillInvoiceRow(pInvoiceRow, pInvoice, pSumAdvance, pInvoiceBalance, pGuestGroup = Неопределено) Экспорт
	pInvoiceRow.СчетНаОплату = pInvoice;
	pInvoiceRow.Договор = pInvoice.Договор;
	pInvoiceRow.ГруппаГостей = pInvoice.ГруппаГостей;
	If ЗначениеЗаполнено(pGuestGroup) Тогда
		pInvoiceRow.ГруппаГостей = pGuestGroup;
	EndIf;
	pInvoiceRow.Balance = pInvoiceBalance;
	If pInvoiceRow.Balance > 0 And pSumAdvance > 0 Тогда
		If pInvoiceRow.Balance > pSumAdvance Тогда
			pInvoiceRow.Сумма = pSumAdvance;
		Else
			pInvoiceRow.Сумма = pInvoiceRow.Balance;
		EndIf;
		pSumAdvance = pSumAdvance - pInvoiceRow.Balance;
	EndIf;
КонецПроцедуры //pmFillInvoiceRow

//-----------------------------------------------------------------------------
Процедура pmFillGroupRow(pGroupRow, pGuestGroup, pAccountingContract, pSumAdvance, pGroupBalance) Экспорт
	pGroupRow.СчетНаОплату = Documents.СчетНаОплату.EmptyRef();
	pGroupRow.Договор = pAccountingContract;
	pGroupRow.ГруппаГостей = pGuestGroup;
	pGroupRow.Balance = pGroupBalance;
	If pGroupRow.Balance > 0 And pSumAdvance > 0 Тогда
		If pGroupRow.Balance > pSumAdvance Тогда
			pGroupRow.Сумма = pSumAdvance;
		Else
			pGroupRow.Сумма = pGroupRow.Balance;
		EndIf;
		pSumAdvance = pSumAdvance - pGroupRow.Balance;
	EndIf;
КонецПроцедуры //pmFillGroupRow

//-----------------------------------------------------------------------------
Процедура pmFillByInvoice(pInvoice) Экспорт
	If НЕ ЗначениеЗаполнено(pInvoice) Тогда
		Return;
	EndIf;
	OperationType = Перечисления.AdvanceDistributionTypes.ByInvoices;
	
	// Fill document properties based on invoice ones
	FillPropertyValues(ThisObject, pInvoice, , "Number, Date, Автор, DeletionMark, Posted, Примечания");
	
	// Get Контрагент advance balance
	
	
	
КонецПроцедуры //pmFillByInvoice

//-----------------------------------------------------------------------------
Процедура pmFillByGuestGroup(pGuestGroup) Экспорт
	If НЕ ЗначениеЗаполнено(pGuestGroup) Тогда
		Return;
	EndIf;
	OperationType = Перечисления.AdvanceDistributionTypes.ByGroups;
	
	// Fill Контрагент and currency
	AccountingCustomer = pGuestGroup.Контрагент;
	AccountingContract = Справочники.Договора.EmptyRef();
	AccountingCurrency = AccountingCustomer.AccountingCurrency;
	GuestGroup = pGuestGroup;
	
	
	// Fill guest groups tabular part
	
	
КонецПроцедуры //pmFillByGuestGroup

//-----------------------------------------------------------------------------
Процедура pmFillByPayment(pPayment) Экспорт
	If НЕ ЗначениеЗаполнено(pPayment) Тогда
		Return;
	EndIf;
	OperationType = Перечисления.AdvanceDistributionTypes.ByGroups;
	
	// Fill Контрагент and currency
	Гостиница = pPayment.Гостиница;
	Фирма = pPayment.Фирма;
	AccountingCustomer = pPayment.Контрагент;
	AccountingContract = pPayment.Договор;
	AccountingCurrency = pPayment.PaymentCurrency;
	GuestGroup = pPayment.ГруппаГостей;
	Payment = pPayment;
	
	
	// Fill guest groups tabular part
	
КонецПроцедуры //pmFillByPayment

//-----------------------------------------------------------------------------


//-----------------------------------------------------------------------------
Процедура pmFillByCustomer(pCustomer) Экспорт
	If НЕ ЗначениеЗаполнено(pCustomer) Тогда
		Return;
	EndIf;
	
	// Fill Контрагент and currency
	AccountingCustomer = pCustomer;
	AccountingContract = Справочники.Договора.EmptyRef();
	AccountingCurrency = AccountingCustomer.AccountingCurrency;
	
	// Fill Контрагент group balances
	
КонецПроцедуры //pmFillByCustomer

//-----------------------------------------------------------------------------
Процедура pmFillByContract(pContract) Экспорт
	If НЕ ЗначениеЗаполнено(pContract) Тогда
		Return;
	EndIf;
	
	// Fill Контрагент contract and currency
	AccountingCustomer = pContract.Owner;
	AccountingContract = pContract;
	AccountingCurrency = AccountingContract.AccountingCurrency;
	
	// Fill Контрагент group balances
	
КонецПроцедуры //pmFillByContract

//-----------------------------------------------------------------------------
Процедура Filling(pBase)
	// Fill attributes with default values
	pmFillAttributesWithDefaultValues();
	// Fill from the base
	If ЗначениеЗаполнено(pBase) Тогда
		If TypeOf(pBase) = Type("DocumentRef.СчетНаОплату") Тогда
			pmFillByInvoice(pBase);
		ElsIf TypeOf(pBase) = Type("CatalogRef.Контрагенты") Тогда
			pmFillByCustomer(pBase);
		ElsIf TypeOf(pBase) = Type("CatalogRef.Договора") Тогда
			pmFillByContract(pBase);
		ElsIf TypeOf(pBase) = Type("CatalogRef.ГруппыГостей") Тогда
			pmFillByGuestGroup(pBase);
		ElsIf TypeOf(pBase) = Type("DocumentRef.Платеж") Or TypeOf(pBase) = Type("DocumentRef.ПлатежКонтрагента") Тогда
			pmFillByPayment(pBase);
		EndIf;
		SetNewNumber();
	EndIf;
КонецПроцедуры //Filling

//-----------------------------------------------------------------------------
Процедура BeforeWrite(pCancel, pWriteMode, pPostingMode)
	Перем vMessage, vAttributeInErr;
	If ThisObject.DataExchange.Load Тогда
		Return;
	EndIf;
	If pWriteMode = DocumentWriteMode.Posting Тогда
		pCancel	= pmCheckDocumentAttributes(vMessage, vAttributeInErr);
		If pCancel Тогда
			WriteLogEvent(NStr("en='Document.DataValidation';ru='Документ.КонтрольДанных';de='Document.DataValidation'"), EventLogLevel.Warning, ThisObject.Metadata(), ThisObject.Ref, NStr(vMessage));
			Message(NStr(vMessage), MessageStatus.Attention);
			ВызватьИсключение NStr(vMessage);
		EndIf;
	EndIf;
КонецПроцедуры //BeforeWrite

//-----------------------------------------------------------------------------
Процедура OnSetNewNumber(pStandardProcessing, pPrefix)
	vPrefix = "";
	If ЗначениеЗаполнено(Фирма) And Фирма.UsePrefixForPayments Тогда
		vPrefix = TrimAll(Фирма.Prefix);
	ElsIf ЗначениеЗаполнено(Гостиница) Тогда
		vPrefix = TrimAll(Гостиница.GetObject().pmGetPrefix());
	ElsIf ЗначениеЗаполнено(ПараметрыСеанса.ТекущаяГостиница) Тогда
		If ЗначениеЗаполнено(ПараметрыСеанса.ТекущаяГостиница.Фирма) And ПараметрыСеанса.ТекущаяГостиница.Фирма.UsePrefixForPayments Тогда
			vPrefix = TrimAll(ПараметрыСеанса.ТекущаяГостиница.Фирма.Prefix);
		Else
			vPrefix = TrimAll(ПараметрыСеанса.ТекущаяГостиница.GetObject().pmGetPrefix());
		EndIf;
	EndIf;
	If vPrefix <> "" Тогда
		pPrefix = vPrefix;
	EndIf;
КонецПроцедуры //OnSetNewNumber
