////-----------------------------------------------------------------------------
//Процедура PostToInvoiceAccounts()
//	For Each vServicesRow In Services Do
//		Movement = RegisterRecords.ВзаиморасчетыПоСчетам.Add();
//		
//		Movement.RecordType = AccumulationRecordType.Receipt;
//		Movement.Period = Date;
//		Movement.СчетНаОплату = Ref;
//		
//		FillPropertyValues(Movement, Ref);
//		FillPropertyValues(Movement, vServicesRow);
//		If ЗначениеЗаполнено(GuestGroup) Тогда
//			Movement.ГруппаГостей = GuestGroup;
//		EndIf;
//		
//		If ЗначениеЗаполнено(AccountingCustomer) And AccountingCustomer.DoNotPostCommission Тогда
//			Movement.Сумма = vServicesRow.Sum;
//			Movement.СуммаНДС = vServicesRow.VATSum;
//		Else
//			Movement.Сумма = vServicesRow.Sum - vServicesRow.CommissionSum;
//			Movement.СуммаНДС = vServicesRow.VATSum - vServicesRow.VATCommissionSum;
//		EndIf;
//	EndDo;
//
//	RegisterRecords.ВзаиморасчетыПоСчетам.Write();
//КонецПроцедуры //PostToInvoiceAccounts
//
////-----------------------------------------------------------------------------
//Процедура Posting(pCancel, pMode)
//	If ThisObject.DataExchange.Load Тогда
//		Return;
//	EndIf;
//	
//	// Recalculate settlement totals
//	vSum = 0;
//	vVATSum = 0;
//	If ЗначениеЗаполнено(AccountingCustomer) And AccountingCustomer.DoNotPostCommission Тогда
//		vSum = Services.Total("Сумма");
//		vVATSum = Services.Total("СуммаНДС");
//	Else
//		vSum = Services.Total("Сумма") - Services.Total("СуммаКомиссии");
//		vVATSum = Services.Total("СуммаНДС") - Services.Total("VATCommissionSum");
//	EndIf;
//	If vSum <> Сумма Тогда
//		Сумма = vSum;
//	EndIf;
//	If vVATSum <> VATSum Тогда
//		VATSum = vVATSum;
//	EndIf;
//	If Modified() Тогда
//		Write(DocumentWriteMode.Write);
//	EndIf;
//	
//	// 1. Invoice accounts
//	PostToInvoiceAccounts();
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
//		pAttributeInErr = ?(pAttributeInErr = "", "Гостиница", pAttributeInErr);
//	EndIf;
//	If НЕ ЗначениеЗаполнено(Фирма) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Фирма> должен быть заполнен!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "Фирма", pAttributeInErr);
//	EndIf;
//	If НЕ ЗначениеЗаполнено(AccountingCustomer) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Контрагент> должен быть заполнен!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "Контрагент", pAttributeInErr);
//	EndIf;
//	If НЕ ЗначениеЗаполнено(AccountingCurrency) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Валюта счета> должен быть заполнен!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "ВалютаРасчетов", pAttributeInErr);
//	EndIf;
//	If vHasErrors Тогда
//		pMessage = "ru='" + TrimAll(vMsgTextRu) + "';";
//	EndIf;
//	Return vHasErrors;
//EndFunction //pmCheckDocumentAttributes
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
//	ExchangeRateDate = Date;
//	If НЕ ЗначениеЗаполнено(Гостиница) Тогда
//		Гостиница = ПараметрыСеанса.ТекущаяГостиница;
//	EndIf;
//	If ЗначениеЗаполнено(Гостиница) Тогда
//		If НЕ ЗначениеЗаполнено(AccountingCurrency) Тогда
//			AccountingCurrency = Гостиница.FolioCurrency;
//			AccountingCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, AccountingCurrency, ExchangeRateDate);
//		EndIf;
//		If НЕ ЗначениеЗаполнено(Фирма) Тогда
//			Фирма = Гостиница.Фирма;
//		EndIf;
//		If ЗначениеЗаполнено(Фирма) Тогда
//			If НЕ ЗначениеЗаполнено(BankAccount) Тогда
//				BankAccount = Фирма.BankAccount;
//			EndIf;
//		EndIf;
//	EndIf;
//	vStamp = New Picture;
//	If ЗначениеЗаполнено(Фирма) Тогда
//		If Фирма.Stamp <> Неопределено Тогда
//			vStamp = Фирма.Stamp.Get();
//			If vStamp <> Неопределено And TypeOf(vStamp) = Type("Picture") Тогда
//				PrintWithCompanyStamp = True;
//			EndIf;
//		EndIf;
//	EndIf;
//КонецПроцедуры //pmFillAttributesWithDefaultValues
//
////-----------------------------------------------------------------------------
//Процедура pmFillServices(pCharges, pLanguage = Неопределено) Экспорт
//	For Each vFolioChargesRow In pCharges Do
//		If ЗначениеЗаполнено(vFolioChargesRow.Начисление) Тогда
//			vServicesRow = Services.Add();
//			If ЗначениеЗаполнено(vFolioChargesRow.СчетПроживания) Тогда
//				FillPropertyValues(vServicesRow, vFolioChargesRow.СчетПроживания);
//			EndIf;
//			vParentDoc = vFolioChargesRow.Начисление.ДокОснование;
//			If ЗначениеЗаполнено(vParentDoc) Тогда
//				FillPropertyValues(vServicesRow, vParentDoc);
//				If TypeOf(vParentDoc) = Type("DocumentRef.Размещение") Or TypeOf(vParentDoc) = Type("DocumentRef.Бронирование") Тогда
//					vServicesRow.Клиент = vParentDoc.Клиент;
//				EndIf;
//			EndIf;
//			FillPropertyValues(vServicesRow, vFolioChargesRow.Начисление);
//			vServicesRow.УчетнаяДата = BegOfDay(vFolioChargesRow.Начисление.ДатаДок);
//			vServicesRow.Сумма = vFolioChargesRow.SumBalance;
//			vServicesRow.СуммаНДС = vFolioChargesRow.VATSumBalance;
//			vServicesRow.Количество = vFolioChargesRow.QuantityBalance;
//			vServicesRow.Цена = cmRecalculatePrice(vServicesRow.Сумма, vServicesRow.Количество);
//			vServicesRow.СуммаСкидки = vFolioChargesRow.СуммаСкидки;
//			vServicesRow.Скидка = vFolioChargesRow.Скидка;
//			// Commission
//			vServicesRow.СуммаКомиссии = 0;
//			vServicesRow.СуммаКомиссииНДС = 0;
//			vServicesRow.Агент = Неопределено;
//			If ЗначениеЗаполнено(vFolioChargesRow.СчетПроживания) Тогда
//				vServicesRow.Агент = vFolioChargesRow.СчетПроживания.Агент;
//			EndIf;
//			vServicesRow.ВидКомиссииАгента = vFolioChargesRow.Начисление.ВидКомиссииАгента;
//			vServicesRow.КомиссияАгента = vFolioChargesRow.Начисление.КомиссияАгента;
//			If НЕ ЗначениеЗаполнено(vServicesRow.Агент) Or 
//			   ЗначениеЗаполнено(vServicesRow.Агент) And vServicesRow.Агент <> AccountingCustomer Тогда
//				vServicesRow.Агент = Неопределено;
//				vServicesRow.ВидКомиссииАгента = Неопределено;
//				vServicesRow.КомиссияАгента = 0;
//			EndIf;
//			If vServicesRow.ВидКомиссииАгента = Перечисления.AgentCommissionTypes.Percent Тогда
//				If vServicesRow.КомиссияАгента <> 0 Тогда
//					vServicesRow.СуммаКомиссии = Round(vServicesRow.Сумма * vServicesRow.КомиссияАгента / 100, 2);
//					vServicesRow.СуммаКомиссииНДС = cmCalculateVATSum(vServicesRow.СтавкаНДС, vServicesRow.СуммаКомиссии);
//				EndIf;
//			ElsIf vServicesRow.ВидКомиссииАгента = Перечисления.AgentCommissionTypes.FirstDayPercent Тогда
//				If ЗначениеЗаполнено(vParentDoc) Тогда
//					If (TypeOf(vParentDoc) = Type("DocumentRef.Бронирование") Or TypeOf(vParentDoc) = Type("DocumentRef.Размещение")) And 
//					   BegOfDay(vParentDoc.CheckInDate) = BegOfDay(vFolioChargesRow.Начисление.ДатаДок) Тогда
//						vServicesRow.СуммаКомиссии = Round(vServicesRow.Сумма * vServicesRow.КомиссияАгента / 100, 2);
//						vServicesRow.СуммаКомиссииНДС = cmCalculateVATSum(vServicesRow.СтавкаНДС, vServicesRow.СуммаКомиссии);
//					ElsIf TypeOf(vParentDoc) = Type("DocumentRef.БроньУслуг") And BegOfDay(vParentDoc.DateTimeFrom) = BegOfDay(vFolioChargesRow.Начисление.ДатаДок) Тогда
//						vServicesRow.СуммаКомиссии = Round(vServicesRow.Сумма * vServicesRow.КомиссияАгента / 100, 2);
//						vServicesRow.СуммаКомиссииНДС = cmCalculateVATSum(vServicesRow.СтавкаНДС, vServicesRow.СуммаКомиссии);
//					EndIf;
//				EndIf;
//			EndIf;
//			// Check base ГруппаНомеров type
//			If ЗначениеЗаполнено(vParentDoc) And (TypeOf(vParentDoc) = Type("DocumentRef.Размещение") Or TypeOf(vParentDoc) = Type("DocumentRef.Бронирование")) Тогда
//				If ЗначениеЗаполнено(vServicesRow.ТипНомера) And ЗначениеЗаполнено(vParentDoc.ТипНомераРасчет) And vParentDoc.ТипНомераРасчет.BaseRoomType = vServicesRow.ТипНомера Тогда
//					vServicesRow.ТипНомера = vParentDoc.ТипНомераРасчет;
//				EndIf;
//			EndIf;
//			// Recalculate service according to the accounting currency
//			pmRecalculateService(vServicesRow, vFolioChargesRow.Начисление.ВалютаЛицСчета, vFolioChargesRow.Начисление.FolioCurrencyExchangeRate);
//			// Fill remarks by service description by default
//			vServiceDescription = TrimAll(vServicesRow.Услуга);
//			If ЗначениеЗаполнено(vServicesRow.Услуга) Тогда
//				vServiceObj = vServicesRow.Услуга.GetObject();
//				vServiceDescription = vServiceObj.pmGetServiceDescription(pLanguage);
//			EndIf;
//			vServicesRow.Примечания = vServiceDescription + 
//			                       ?(IsBlankString(vServicesRow.Примечания), "", " - " + TrimAll(vServicesRow.Примечания));
//		EndIf;
//	EndDo;
//КонецПроцедуры //pmFillServices	
//
////-----------------------------------------------------------------------------
//// Fill invoice check date
////-----------------------------------------------------------------------------
//Процедура pmFillCheckDate() Экспорт
//	vCheckDate = '00010101';
//	vUpdateCheckDate = False;
//	If НЕ ЗначениеЗаполнено(CheckDate) And ЗначениеЗаполнено(GuestGroup) Тогда
//		If ЗначениеЗаполнено(AccountingContract) And (AccountingContract.DaysBeforeCheckIn <> 0 Or AccountingContract.DaysAfterReservation <> 0) Тогда
//			vUpdateCheckDate = True;
//			If AccountingContract.DaysBeforeCheckIn <> 0 And ЗначениеЗаполнено(GuestGroup.CheckInDate) Тогда
//				vCheckDate = BegOfDay(GuestGroup.CheckInDate) - 24*3600*AccountingContract.DaysBeforeCheckIn;
//			ElsIf AccountingContract.DaysAfterReservation <> 0 And ЗначениеЗаполнено(Date) Тогда
//				vCheckDate = cmAddWorkingDays(BegOfDay(Date), (AccountingContract.DaysAfterReservation + 1));
//			EndIf;
//		ElsIf ЗначениеЗаполнено(AccountingCustomer) And (AccountingCustomer.DaysBeforeCheckIn <> 0 Or AccountingCustomer.DaysAfterReservation <> 0) Тогда
//			vUpdateCheckDate = True;
//			If AccountingCustomer.DaysBeforeCheckIn <> 0 And ЗначениеЗаполнено(GuestGroup.CheckInDate) Тогда
//				vCheckDate = BegOfDay(GuestGroup.CheckInDate) - 24*3600*AccountingCustomer.DaysBeforeCheckIn;
//			ElsIf AccountingCustomer.DaysAfterReservation <> 0 And ЗначениеЗаполнено(Date) Тогда
//				vCheckDate = cmAddWorkingDays(BegOfDay(Date), (AccountingCustomer.DaysAfterReservation + 1));
//			EndIf;
//		ElsIf ЗначениеЗаполнено(Гостиница) And (Гостиница.DaysBeforeCheckIn <> 0 Or Гостиница.DaysAfterReservation <> 0) Тогда
//			vUpdateCheckDate = True;
//			If Гостиница.DaysBeforeCheckIn <> 0 And ЗначениеЗаполнено(GuestGroup.CheckInDate) Тогда
//				vCheckDate = BegOfDay(GuestGroup.CheckInDate) - 24*3600*Гостиница.DaysBeforeCheckIn;
//			ElsIf Гостиница.DaysAfterReservation <> 0 And ЗначениеЗаполнено(Date) Тогда
//				vCheckDate = cmAddWorkingDays(BegOfDay(Date), (Гостиница.DaysAfterReservation + 1));
//			EndIf;
//		EndIf;
//	EndIf;
//	If vUpdateCheckDate And ЗначениеЗаполнено(vCheckDate) And CheckDate <> vCheckDate Тогда
//		CheckDate = vCheckDate;
//	EndIf;
//КонецПроцедуры //pmFillCheckDate
//
////-----------------------------------------------------------------------------
//Процедура pmFillByFolio(pFolio) Экспорт
//	If НЕ ЗначениеЗаполнено(pFolio) Тогда
//		Return;
//	EndIf;
//	
//	If ЗначениеЗаполнено(pFolio.Гостиница) Тогда
//		If Гостиница <> pFolio.Гостиница Тогда
//			Гостиница = pFolio.Гостиница;
//			SetNewNumber(TrimAll(Гостиница.GetObject().pmGetPrefix()));
//		EndIf;
//	EndIf;
//	
//	ParentDoc = pFolio;
//	
//	// Fill currency
//	AccountingCurrency = pFolio.ВалютаЛицСчета;
//	AccountingCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, AccountingCurrency, ExchangeRateDate);
//	
//	// Fill Фирма
//	If ЗначениеЗаполнено(pFolio.Фирма) Тогда
//		Фирма = pFolio.Фирма;
//	Else
//		If ЗначениеЗаполнено(Гостиница) Тогда
//			If ЗначениеЗаполнено(Гостиница.Фирма) Тогда
//				Фирма = Гостиница.Фирма;
//			EndIf;
//		EndIf;
//	EndIf;
//	If ЗначениеЗаполнено(Фирма) Тогда
//		BankAccount = Фирма.BankAccount;
//		If НЕ ЗначениеЗаполнено(BankAccount) Or ЗначениеЗаполнено(BankAccount) And AccountingCurrency <> BankAccount.ВалютаСчета Тогда
//			vBankAccounts = Фирма.GetObject().pmGetCompanyBankAccounts(AccountingCurrency);
//			If vBankAccounts.Count() > 0 Тогда
//				vBankAccountsRow = vBankAccounts.Get(0);
//				BankAccount = vBankAccountsRow.BankAccount;
//			EndIf;
//		EndIf;
//	EndIf;
//	
//	// Fill accounting Контрагент, contract and guest group
//	AccountingCustomer = pFolio.Контрагент;
//	AccountingContract = pFolio.Договор;
//	GuestGroup = pFolio.ГруппаГостей;
//	
//	// Fill default Контрагент
//	If НЕ ЗначениеЗаполнено(AccountingCustomer) Тогда
//		If ЗначениеЗаполнено(Гостиница) Тогда
//			AccountingCustomer = Гостиница.IndividualsCustomer;
//			AccountingContract = Гостиница.IndividualsContract;
//		EndIf;
//	EndIf;
//	
//	// Get Контрагент language
//	vLanguage = Неопределено;
//	If ЗначениеЗаполнено(AccountingCustomer) Тогда
//		vLanguage = AccountingCustomer.Language;
//	EndIf;
//	
//	// Reset totals
//	Сумма = 0;
//	VATSum = 0;
//	
//	// Clear tabular part Services
//	Services.Clear();
//	
//	// Get all folio current accounts receivable services with balances per end of date
//	vFolioCharges = pFolio.GetObject().pmGetCurrentAccountsReceivableChargesWithBalances('39991231235959');
//	
//	// Fill services tabular part
//	pmFillServices(vFolioCharges, vLanguage);
//	
//	// Fill totals
//	Сумма = Services.Total("Сумма");
//	VATSum = Services.Total("СуммаНДС");
//	
//	// Fill check date
//	pmFillCheckDate();
//КонецПроцедуры //pmFillByFolio
//
////-----------------------------------------------------------------------------
//Процедура pmRecalculateService(pSrvRow, pCurrencyFrom, Val pCurrencyFromExchangeRate = 0) Экспорт
//	If pCurrencyFromExchangeRate = 0 Тогда
//		pCurrencyFromExchangeRate = cmGetCurrencyExchangeRate(Гостиница, pCurrencyFrom, ExchangeRateDate);
//	EndIf;
//	If pCurrencyFrom <> AccountingCurrency Тогда
//		pSrvRow.Цена = Round(pSrvRow.Цена * pCurrencyFromExchangeRate / AccountingCurrencyExchangeRate, 2);
//		cmPriceOnChange(pSrvRow.Цена, pSrvRow.Количество, pSrvRow.Сумма, pSrvRow.СтавкаНДС, pSrvRow.СуммаНДС);
//		pSrvRow.СуммаСкидки = Round(pSrvRow.СуммаСкидки * pCurrencyFromExchangeRate / AccountingCurrencyExchangeRate, 2);
//		If pSrvRow.КомиссияАгента <> 0 Тогда
//			pSrvRow.СуммаКомиссии = Round(pSrvRow.Сумма * pSrvRow.КомиссияАгента / 100, 2);
//			pSrvRow.СуммаКомиссииНДС = cmCalculateVATSum(pSrvRow.СтавкаНДС, pSrvRow.СуммаКомиссии);
//		Else
//			pSrvRow.СуммаКомиссии = 0;
//			pSrvRow.СуммаКомиссииНДС = 0;
//		EndIf;
//	EndIf;
//КонецПроцедуры //pmRecalculateService
//
////-----------------------------------------------------------------------------
//Процедура pmFillByReservation(pDoc, pDoNotClearServices = False) Экспорт
//	If НЕ ЗначениеЗаполнено(pDoc) Тогда
//		Return;
//	EndIf;
//	
//	vSetNewNumber = False;
//	If ЗначениеЗаполнено(pDoc.Гостиница) Тогда
//		If Гостиница <> pDoc.Гостиница Тогда
//			Гостиница = pDoc.Гостиница;
//			vSetNewNumber = True;
//		EndIf;
//	EndIf;
//	
//	ParentDoc = pDoc;
//	
//	// Fill accounting Контрагент, contract and guest group
//	AccountingCustomer = pDoc.Контрагент;
//	AccountingContract = pDoc.Договор;
//	GuestGroup = pDoc.ГруппаГостей;
//	
//	// Fill default Контрагент
//	If НЕ ЗначениеЗаполнено(AccountingCustomer) Тогда
//		If ЗначениеЗаполнено(Гостиница) Тогда
//			AccountingCustomer = Гостиница.IndividualsCustomer;
//			AccountingContract = Гостиница.IndividualsContract;
//		EndIf;
//	EndIf;
//	
//	// Fill currency
//	If ЗначениеЗаполнено(AccountingContract) Тогда
//		AccountingCurrency = AccountingContract.AccountingCurrency;
//		AccountingCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, AccountingCurrency, ExchangeRateDate);
//	Else
//		If ЗначениеЗаполнено(AccountingCustomer) Тогда
//			AccountingCurrency = AccountingCustomer.AccountingCurrency;
//			AccountingCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, AccountingCurrency, ExchangeRateDate);
//		EndIf;
//	EndIf;
//	
//	// Fill Фирма
//	If ЗначениеЗаполнено(pDoc.Фирма) Тогда
//		If Фирма <> pDoc.Фирма Тогда
//			Фирма = pDoc.Фирма;
//			vSetNewNumber = True;
//		EndIf;
//	Else
//		If ЗначениеЗаполнено(Гостиница) Тогда
//			If ЗначениеЗаполнено(Гостиница.Фирма) Тогда
//				If Фирма <> Гостиница.Фирма Тогда
//					Фирма = Гостиница.Фирма;
//					vSetNewNumber = True;
//				EndIf;
//			EndIf;
//		EndIf;
//	EndIf;
//	If ЗначениеЗаполнено(Фирма) Тогда
//		BankAccount = Фирма.BankAccount;
//		If НЕ ЗначениеЗаполнено(BankAccount) Or ЗначениеЗаполнено(BankAccount) And AccountingCurrency <> BankAccount.ВалютаСчета Тогда
//			vBankAccounts = Фирма.GetObject().pmGetCompanyBankAccounts(AccountingCurrency);
//			If vBankAccounts.Count() > 0 Тогда
//				vBankAccountsRow = vBankAccounts.Get(0);
//				BankAccount = vBankAccountsRow.BankAccount;
//			EndIf;
//		EndIf;
//	EndIf;
//	
//	// Set new number
//	If vSetNewNumber Тогда
//		SetNewNumber(TrimAll(Гостиница.GetObject().pmGetPrefix()));
//	EndIf;
//	
//	// Get Контрагент language
//	vLanguage = Неопределено;
//	
//	// Fill contact information
//	ContactPerson = pDoc.КонтактноеЛицо;
//	Phone = pDoc.Телефон;
//	Fax = pDoc.Fax;
//	EMail = pDoc.EMail;
//	If ЗначениеЗаполнено(GuestGroup) And ЗначениеЗаполнено(GuestGroup.Client) Тогда
//		If IsBlankString(EMail) Тогда
//			If НЕ IsBlankString(GuestGroup.Client.EMail) Тогда
//				EMail = GuestGroup.Client.EMail;
//			EndIf;
//		EndIf;
//		If IsBlankString(Phone) Тогда
//			If НЕ IsBlankString(GuestGroup.Client.Телефон) Тогда
//				Phone = GuestGroup.Client.Телефон;
//			EndIf;
//		EndIf;
//		If IsBlankString(Fax) Тогда
//			If НЕ IsBlankString(GuestGroup.Client.Fax) Тогда
//				Fax = GuestGroup.Client.Fax;
//			EndIf;
//		EndIf;
//	EndIf;
//	
//	// Reset totals
//	Сумма = 0;
//	VATSum = 0;
//	
//	// Clear tabular part Services
//	If НЕ pDoNotClearServices Тогда
//		Services.Clear();
//	EndIf;
//	
//	// Get all services
//	vIsClosed = False;
//	If ЗначениеЗаполнено(pDoc.ReservationStatus) Тогда
//		vIsClosed = НЕ pDoc.ReservationStatus.IsActive;
//		If pDoc.ReservationStatus.IsPreliminary Тогда
//			vIsClosed = False;
//		EndIf;
//	EndIf;
//	If НЕ pDoc.DoCharging And НЕ vIsClosed Тогда
//		For Each vDocRow In pDoc.Услуги Do
//			vSrvRow = Services.Add();
//			
//			FillPropertyValues(vSrvRow, pDoc);
//			FillPropertyValues(vSrvRow, vDocRow);
//			
//			vSrvRow.Клиент = pDoc.Клиент;
//			vSrvRow.DateTimeFrom = pDoc.CheckInDate;
//			vSrvRow.DateTimeTo = pDoc.ДатаВыезда;
//			If НЕ ЗначениеЗаполнено(pDoc.НомерРазмещения) Тогда
//				vSrvRow.НомерРазмещения = pDoc.НомерДока;
//			EndIf;
//			
//			vSrvRow.Сумма = vDocRow.Сумма - vDocRow.СуммаСкидки;
//			vSrvRow.СуммаНДС = vDocRow.СуммаНДС - vDocRow.НДСскидка;
//			vSrvRow.Цена = cmRecalculatePrice(vSrvRow.Сумма, vSrvRow.Количество);
//			
//			// Discounts
//			vSrvRow.Скидка = vDocRow.Скидка;
//			vSrvRow.СуммаСкидки = vDocRow.СуммаСкидки;
//			
//			// Commission
//			vSrvRow.СуммаКомиссии = 0;
//			vSrvRow.СуммаКомиссииНДС = 0;
//			vSrvRow.Агент = Неопределено;
//			If ЗначениеЗаполнено(vDocRow.СчетПроживания) Тогда
//				vSrvRow.Агент = vDocRow.СчетПроживания.Агент;
//			EndIf;
//			vSrvRow.ВидКомиссииАгента = pDoc.ВидКомиссииАгента;
//			vSrvRow.КомиссияАгента = pDoc.КомиссияАгента;
//			If НЕ ЗначениеЗаполнено(vSrvRow.Агент) Or 
//			   ЗначениеЗаполнено(vSrvRow.Агент) And vSrvRow.Агент <> AccountingCustomer Тогда
//				vSrvRow.Агент = Неопределено;
//				vSrvRow.ВидКомиссииАгента = Неопределено;
//				vSrvRow.КомиссияАгента = 0;
//			EndIf;
//			If vSrvRow.КомиссияАгента <> 0 Тогда
//				// Check that current service fit to the commission service group
//				If cmIsServiceInServiceGroup(vSrvRow.Услуга, pDoc.КомиссияАгентУслуги) Тогда
//					If vSrvRow.ВидКомиссииАгента = Перечисления.AgentCommissionTypes.Percent Тогда
//						vSrvRow.СуммаКомиссии = Round(vSrvRow.Сумма * vSrvRow.КомиссияАгента / 100, 2);
//						vSrvRow.СуммаКомиссииНДС = cmCalculateVATSum(vSrvRow.СтавкаНДС, vSrvRow.СуммаКомиссии);
//					ElsIf vSrvRow.ВидКомиссииАгента = Перечисления.AgentCommissionTypes.FirstDayPercent Тогда
//						If BegOfDay(pDoc.CheckInDate) = BegOfDay(vSrvRow.УчетнаяДата) Тогда
//							vSrvRow.СуммаКомиссии = Round(vSrvRow.Сумма * vSrvRow.КомиссияАгента / 100, 2);
//							vSrvRow.СуммаКомиссииНДС = cmCalculateVATSum(vSrvRow.СтавкаНДС, vSrvRow.СуммаКомиссии);
//						EndIf;
//					EndIf;
//				Else
//					vSrvRow.Агент = Неопределено;
//					vSrvRow.ВидКомиссииАгента = Неопределено;
//					vSrvRow.КомиссияАгента = 0;
//				EndIf;
//			EndIf;
//			
//			// Check base ГруппаНомеров type
//			If ЗначениеЗаполнено(vSrvRow.ТипНомера) And ЗначениеЗаполнено(pDoc.ТипНомераРасчет) And pDoc.ТипНомераРасчет.BaseRoomType = vSrvRow.ТипНомера Тогда
//				vSrvRow.ТипНомера = pDoc.ТипНомераРасчет;
//			EndIf;
//			
//			// Recalculate service according to the accounting currency
//			pmRecalculateService(vSrvRow, vDocRow.ВалютаЛицСчета, vDocRow.FolioCurrencyExchangeRate);
//			
//			// Fill remarks by service description by default
//			vServiceDescription = TrimAll(vSrvRow.Услуга);
//			If ЗначениеЗаполнено(vSrvRow.Услуга) Тогда
//				vServiceObj = vSrvRow.Услуга.GetObject();
//				vServiceDescription = vServiceObj.pmGetServiceDescription(vLanguage);
//			EndIf;
//			vSrvRow.Примечания = vServiceDescription + 
//							  ?(IsBlankString(vSrvRow.Примечания), "", " - " + TrimAll(vSrvRow.Примечания));
//		EndDo;
//	EndIf;
//	
//	// Get reservation charges for the folios
//	vCharges = cmGetDocumentCharges(pDoc, AccountingCustomer, AccountingContract, Гостиница, Неопределено, True);
//	For Each vDocRow In vCharges Do
//		vSrvRow = Services.Add();
//		
//		vParentDoc = Неопределено;
//		If ЗначениеЗаполнено(vDocRow.Recorder.ДокОснование) And TypeOf(vDocRow.Recorder.ДокОснование) = Type("DocumentRef.Бронирование") Тогда
//			vParentDoc = vDocRow.Recorder.ДокОснование;
//		EndIf;
//		
//		FillPropertyValues(vSrvRow, pDoc);
//		FillPropertyValues(vSrvRow, vDocRow);
//		
//		If ЗначениеЗаполнено(vParentDoc) Тогда
//			vSrvRow.Клиент = vParentDoc.Клиент;
//			vSrvRow.DateTimeFrom = vParentDoc.CheckInDate;
//			vSrvRow.DateTimeTo = vParentDoc.ДатаВыезда;
//			If НЕ ЗначениеЗаполнено(vParentDoc.НомерРазмещения) Тогда
//				vSrvRow.НомерРазмещения = vParentDoc.НомерДока;
//			Else
//				vSrvRow.НомерРазмещения = vParentDoc.НомерРазмещения;
//			EndIf;
//		Else
//			vSrvRow.Клиент = pDoc.Клиент;
//			vSrvRow.DateTimeFrom = pDoc.CheckInDate;
//			vSrvRow.DateTimeTo = pDoc.ДатаВыезда;
//			If НЕ ЗначениеЗаполнено(pDoc.НомерРазмещения) Тогда
//				vSrvRow.НомерРазмещения = pDoc.НомерДока;
//			Else
//				vSrvRow.НомерРазмещения = pDoc.НомерРазмещения;
//			EndIf;
//		EndIf;
//		
//		// Discounts
//		vSrvRow.Скидка = vDocRow.Скидка;
//		vSrvRow.СуммаСкидки = vDocRow.СуммаСкидки;
//		
//		// Commission
//		vSrvRow.СуммаКомиссии = 0;
//		vSrvRow.СуммаКомиссииНДС = 0;
//		vSrvRow.Агент = Неопределено;
//		If ЗначениеЗаполнено(vDocRow.СчетПроживания) Тогда
//			vSrvRow.Агент = vDocRow.СчетПроживания.Агент;
//		EndIf;
//		vSrvRow.ВидКомиссииАгента = vDocRow.ВидКомиссииАгента;
//		vSrvRow.КомиссияАгента = vDocRow.КомиссияАгента;
//		If НЕ ЗначениеЗаполнено(vSrvRow.Агент) Or 
//		   ЗначениеЗаполнено(vSrvRow.Агент) And vSrvRow.Агент <> AccountingCustomer Тогда
//			vSrvRow.Агент = Неопределено;
//			vSrvRow.ВидКомиссииАгента = Неопределено;
//			vSrvRow.КомиссияАгента = 0;
//		EndIf;
//		If vSrvRow.КомиссияАгента <> 0 Тогда
//			vSrvRow.СуммаКомиссии = vDocRow.СуммаКомиссии;
//			vSrvRow.СуммаКомиссииНДС = vDocRow.СуммаКомиссииНДС;
//		EndIf;
//		
//		// Check base ГруппаНомеров type
//		If ЗначениеЗаполнено(vSrvRow.ТипНомера) And ЗначениеЗаполнено(pDoc.ТипНомераРасчет) And pDoc.ТипНомераРасчет.BaseRoomType = vSrvRow.ТипНомера Тогда
//			vSrvRow.ТипНомера = pDoc.ТипНомераРасчет;
//		EndIf;
//		
//		// Recalculate service according to the accounting currency
//		pmRecalculateService(vSrvRow, vDocRow.ВалютаЛицСчета, vDocRow.FolioCurrencyExchangeRate);
//		
//		// Fill remarks by service description by default
//		vServiceDescription = TrimAll(vSrvRow.Услуга);
//		If ЗначениеЗаполнено(vSrvRow.Услуга) Тогда
//			vServiceObj = vSrvRow.Услуга.GetObject();
//			vServiceDescription = vServiceObj.pmGetServiceDescription(vLanguage);
//		EndIf;
//		vSrvRow.Примечания = vServiceDescription + 
//						  ?(IsBlankString(vSrvRow.Примечания), "", " - " + TrimAll(vSrvRow.Примечания));
//	EndDo;
//	
//	// Fill totals
//	If ЗначениеЗаполнено(AccountingCustomer) And AccountingCustomer.DoNotPostCommission Тогда
//		Сумма = Services.Total("Сумма");
//		VATSum = Services.Total("СуммаНДС");
//	Else
//		Сумма = Services.Total("Сумма") - Services.Total("СуммаКомиссии");
//		VATSum = Services.Total("СуммаНДС") - Services.Total("VATCommissionSum");
//	EndIf;
//	
//	// Fill check date
//	pmFillCheckDate();
//КонецПроцедуры //pmFillByReservation
//
////-----------------------------------------------------------------------------
//Процедура pmFillByResourceReservation(pDoc) Экспорт
//	If НЕ ЗначениеЗаполнено(pDoc) Тогда
//		Return;
//	EndIf;
//	
//	vSetNewNumber = False;
//	If ЗначениеЗаполнено(pDoc.Гостиница) Тогда
//		If Гостиница <> pDoc.Гостиница Тогда
//			Гостиница = pDoc.Гостиница;
//			vSetNewNumber = True;
//		EndIf;
//	EndIf;
//	
//	ParentDoc = pDoc;
//	
//	// Fill accounting Контрагент, contract and guest group
//	AccountingCustomer = pDoc.Контрагент;
//	AccountingContract = pDoc.Договор;
//	GuestGroup = pDoc.ГруппаГостей;
//	
//	// Fill default Контрагент
//	If НЕ ЗначениеЗаполнено(AccountingCustomer) Тогда
//		If ЗначениеЗаполнено(Гостиница) Тогда
//			AccountingCustomer = Гостиница.IndividualsCustomer;
//			AccountingContract = Гостиница.IndividualsContract;
//		EndIf;
//	EndIf;
//	
//	// Fill currency
//	If ЗначениеЗаполнено(AccountingContract) Тогда
//		AccountingCurrency = AccountingContract.AccountingCurrency;
//		AccountingCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, AccountingCurrency, ExchangeRateDate);
//	Else
//		If ЗначениеЗаполнено(AccountingCustomer) Тогда
//			AccountingCurrency = AccountingCustomer.AccountingCurrency;
//			AccountingCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, AccountingCurrency, ExchangeRateDate);
//		EndIf;
//	EndIf;
//	
//	// Fill Фирма
//	If ЗначениеЗаполнено(pDoc.Фирма) Тогда
//		If Фирма <> pDoc.Фирма Тогда
//			Фирма = pDoc.Фирма;
//			vSetNewNumber = True;
//		EndIf;
//	Else
//		If ЗначениеЗаполнено(Гостиница) Тогда
//			If ЗначениеЗаполнено(Гостиница.Фирма) Тогда
//				If Фирма <> Гостиница.Фирма Тогда
//					Фирма = Гостиница.Фирма;
//					vSetNewNumber = True;
//				EndIf;
//			EndIf;
//		EndIf;
//	EndIf;
//	If ЗначениеЗаполнено(Фирма) Тогда
//		BankAccount = Фирма.BankAccount;
//		If НЕ ЗначениеЗаполнено(BankAccount) Or ЗначениеЗаполнено(BankAccount) And AccountingCurrency <> BankAccount.ВалютаСчета Тогда
//			vBankAccounts = Фирма.GetObject().pmGetCompanyBankAccounts(AccountingCurrency);
//			If vBankAccounts.Count() > 0 Тогда
//				vBankAccountsRow = vBankAccounts.Get(0);
//				BankAccount = vBankAccountsRow.BankAccount;
//			EndIf;
//		EndIf;
//	EndIf;
//	
//	// Set new number
//	If vSetNewNumber Тогда
//		SetNewNumber(TrimAll(Гостиница.GetObject().pmGetPrefix()));
//	EndIf;
//	
//	// Get Контрагент language
//	vLanguage = Неопределено;
//	If ЗначениеЗаполнено(AccountingCustomer) Тогда
//		vLanguage = AccountingCustomer.Language;
//	EndIf;
//	
//	// Fill contact information
//	ContactPerson = pDoc.КонтактноеЛицо;
//	Phone = pDoc.Телефон;
//	Fax = pDoc.Fax;
//	EMail = pDoc.EMail;
//	If ЗначениеЗаполнено(GuestGroup) And ЗначениеЗаполнено(GuestGroup.Client) Тогда
//		If IsBlankString(EMail) Тогда
//			If НЕ IsBlankString(GuestGroup.Client.EMail) Тогда
//				EMail = GuestGroup.Client.EMail;
//			EndIf;
//		EndIf;
//		If IsBlankString(Phone) Тогда
//			If НЕ IsBlankString(GuestGroup.Client.Телефон) Тогда
//				Phone = GuestGroup.Client.Телефон;
//			EndIf;
//		EndIf;
//		If IsBlankString(Fax) Тогда
//			If НЕ IsBlankString(GuestGroup.Client.Fax) Тогда
//				Fax = GuestGroup.Client.Fax;
//			EndIf;
//		EndIf;
//	EndIf;
//	
//	// Reset totals
//	Сумма = 0;
//	VATSum = 0;
//	
//	// Clear tabular part Services
//	Services.Clear();
//	
//	// Get all services
//	vIsClosed = False;
//	If ЗначениеЗаполнено(pDoc.ResourceReservationStatus) Тогда
//		vIsClosed = НЕ pDoc.ResourceReservationStatus.IsActive;
//	EndIf;
//	If НЕ vIsClosed Тогда
//		If НЕ pDoc.DoCharging Тогда
//			For Each vDocRow In pDoc.Услуги Do
//				vSrvRow = Services.Add();
//				
//				FillPropertyValues(vSrvRow, pDoc);
//				FillPropertyValues(vSrvRow, vDocRow);
//				
//				vSrvRow.Сумма = vDocRow.Сумма - vDocRow.СуммаСкидки;
//				vSrvRow.СуммаНДС = vDocRow.СуммаНДС - vDocRow.НДСскидка;
//				vSrvRow.Цена = cmRecalculatePrice(vSrvRow.Сумма, vSrvRow.Количество);
//				
//				// Discounts
//				vSrvRow.Скидка = vDocRow.Скидка;
//				vSrvRow.СуммаСкидки = vDocRow.СуммаСкидки;
//				
//				// Commission
//				vSrvRow.СуммаКомиссии = 0;
//				vSrvRow.СуммаКомиссииНДС = 0;
//				vSrvRow.Агент = Неопределено;
//				If ЗначениеЗаполнено(pDoc.ChargingFolio) Тогда
//					vSrvRow.Агент = pDoc.ChargingFolio.Агент;
//				EndIf;
//				vSrvRow.ВидКомиссииАгента = pDoc.ВидКомиссииАгента;
//				vSrvRow.КомиссияАгента = pDoc.КомиссияАгента;
//				If НЕ ЗначениеЗаполнено(vSrvRow.Агент) Or 
//				   ЗначениеЗаполнено(vSrvRow.Агент) And vSrvRow.Агент <> AccountingCustomer Тогда
//					vSrvRow.Агент = Неопределено;
//					vSrvRow.ВидКомиссииАгента = Неопределено;
//					vSrvRow.КомиссияАгента = 0;
//				EndIf;
//				If vSrvRow.КомиссияАгента <> 0 Тогда
//					// Check that current service fit to the commission service group
//					If cmIsServiceInServiceGroup(vSrvRow.Услуга, pDoc.КомиссияАгентУслуги) Тогда
//						If vSrvRow.ВидКомиссииАгента = Перечисления.AgentCommissionTypes.Percent Тогда
//							vSrvRow.СуммаКомиссии = Round(vSrvRow.Сумма * vSrvRow.КомиссияАгента / 100, 2);
//							vSrvRow.СуммаКомиссииНДС = cmCalculateVATSum(vSrvRow.СтавкаНДС, vSrvRow.СуммаКомиссии);
//						ElsIf vSrvRow.ВидКомиссииАгента = Перечисления.AgentCommissionTypes.FirstDayPercent Тогда
//							If BegOfDay(pDoc.DateTimeFrom) = BegOfDay(vSrvRow.УчетнаяДата) Тогда
//								vSrvRow.СуммаКомиссии = Round(vSrvRow.Сумма * vSrvRow.КомиссияАгента / 100, 2);
//								vSrvRow.СуммаКомиссииНДС = cmCalculateVATSum(vSrvRow.СтавкаНДС, vSrvRow.СуммаКомиссии);
//							EndIf;
//						EndIf;
//					Else
//						vSrvRow.Агент = Неопределено;
//						vSrvRow.ВидКомиссииАгента = Неопределено;
//						vSrvRow.КомиссияАгента = 0;
//					EndIf;
//				EndIf;
//				
//				// Recalculate service according to the accounting currency
//				pmRecalculateService(vSrvRow, pDoc.ВалютаЛицСчета, pDoc.FolioCurrencyExchangeRate);
//				
//				// Fill remarks by service description by default
//				vServiceDescription = TrimAll(vSrvRow.Услуга);
//				If ЗначениеЗаполнено(vSrvRow.Услуга) Тогда
//					vServiceObj = vSrvRow.Услуга.GetObject();
//					vServiceDescription = vServiceObj.pmGetServiceDescription(vLanguage);
//				EndIf;
//				vSrvRow.Примечания = vServiceDescription + 
//								  ?(IsBlankString(vSrvRow.Примечания), "", " - " +TrimAll(vSrvRow.Примечания));
//			EndDo;
//		Else
//			For Each vDocRow In pDoc.Услуги Do
//				If ЗначениеЗаполнено(vDocRow.Услуга) And ЗначениеЗаполнено(vDocRow.Услуга.ServiceType) And vDocRow.Услуга.ServiceType.ActualAmountIsChargedExternally Тогда
//					vSrvRow = Services.Add();
//					
//					FillPropertyValues(vSrvRow, pDoc);
//					FillPropertyValues(vSrvRow, vDocRow);
//					
//					vSrvRow.Сумма = vDocRow.Сумма - vDocRow.СуммаСкидки;
//					vSrvRow.СуммаНДС = vDocRow.СуммаНДС - vDocRow.НДСскидка;
//					vSrvRow.Цена = cmRecalculatePrice(vSrvRow.Сумма, vSrvRow.Количество);
//					
//					// Discounts
//					vSrvRow.Скидка = vDocRow.Скидка;
//					vSrvRow.СуммаСкидки = vDocRow.СуммаСкидки;
//					
//					// Commission
//					vSrvRow.СуммаКомиссии = 0;
//					vSrvRow.СуммаКомиссииНДС = 0;
//					vSrvRow.Агент = Неопределено;
//					If ЗначениеЗаполнено(pDoc.ChargingFolio) Тогда
//						vSrvRow.Агент = pDoc.ChargingFolio.Агент;
//					EndIf;
//					vSrvRow.ВидКомиссииАгента = pDoc.ВидКомиссииАгента;
//					vSrvRow.КомиссияАгента = pDoc.КомиссияАгента;
//					If НЕ ЗначениеЗаполнено(vSrvRow.Агент) Or 
//					   ЗначениеЗаполнено(vSrvRow.Агент) And vSrvRow.Агент <> AccountingCustomer Тогда
//						vSrvRow.Агент = Неопределено;
//						vSrvRow.ВидКомиссииАгента = Неопределено;
//						vSrvRow.КомиссияАгента = 0;
//					EndIf;
//					If vSrvRow.КомиссияАгента <> 0 Тогда
//						// Check that current service fit to the commission service group
//						If cmIsServiceInServiceGroup(vSrvRow.Услуга, pDoc.КомиссияАгентУслуги) Тогда
//							If vSrvRow.ВидКомиссииАгента = Перечисления.AgentCommissionTypes.Percent Тогда
//								vSrvRow.СуммаКомиссии = Round(vSrvRow.Сумма * vSrvRow.КомиссияАгента / 100, 2);
//								vSrvRow.СуммаКомиссииНДС = cmCalculateVATSum(vSrvRow.СтавкаНДС, vSrvRow.СуммаКомиссии);
//							ElsIf vSrvRow.ВидКомиссииАгента = Перечисления.AgentCommissionTypes.FirstDayPercent Тогда
//								If BegOfDay(pDoc.DateTimeFrom) = BegOfDay(vSrvRow.УчетнаяДата) Тогда
//									vSrvRow.СуммаКомиссии = Round(vSrvRow.Сумма * vSrvRow.КомиссияАгента / 100, 2);
//									vSrvRow.СуммаКомиссииНДС = cmCalculateVATSum(vSrvRow.СтавкаНДС, vSrvRow.СуммаКомиссии);
//								EndIf;
//							EndIf;
//						Else
//							vSrvRow.Агент = Неопределено;
//							vSrvRow.ВидКомиссииАгента = Неопределено;
//							vSrvRow.КомиссияАгента = 0;
//						EndIf;
//					EndIf;
//					
//					// Recalculate service according to the accounting currency
//					pmRecalculateService(vSrvRow, pDoc.ВалютаЛицСчета, pDoc.FolioCurrencyExchangeRate);
//					
//					// Fill remarks by service description by default
//					vServiceDescription = TrimAll(vSrvRow.Услуга);
//					If ЗначениеЗаполнено(vSrvRow.Услуга) Тогда
//						vServiceObj = vSrvRow.Услуга.GetObject();
//						vServiceDescription = vServiceObj.pmGetServiceDescription(vLanguage);
//					EndIf;
//					vSrvRow.Примечания = vServiceDescription + 
//									  ?(IsBlankString(vSrvRow.Примечания), "", " - " + TrimAll(vSrvRow.Примечания));
//				EndIf;
//			EndDo;
//		EndIf;
//	EndIf;
//	
//	// Get reservation charges for the folios
//	vCharges = cmGetDocumentCharges(pDoc, AccountingCustomer, AccountingContract, Гостиница, Неопределено, True);
//	For Each vDocRow In vCharges Do
//		vSrvRow = Services.Add();
//		
//		FillPropertyValues(vSrvRow, pDoc);
//		FillPropertyValues(vSrvRow, vDocRow);
//		
//		// Discounts
//		vSrvRow.Скидка = vDocRow.Скидка;
//		vSrvRow.СуммаСкидки = vDocRow.СуммаСкидки;
//		
//		// Commission
//		vSrvRow.СуммаКомиссии = 0;
//		vSrvRow.СуммаКомиссииНДС = 0;
//		vSrvRow.Агент = Неопределено;
//		If ЗначениеЗаполнено(vDocRow.СчетПроживания) Тогда
//			vSrvRow.Агент = vDocRow.СчетПроживания.Агент;
//		EndIf;
//		vSrvRow.ВидКомиссииАгента = vDocRow.ВидКомиссииАгента;
//		vSrvRow.КомиссияАгента = vDocRow.КомиссияАгента;
//		If НЕ ЗначениеЗаполнено(vSrvRow.Агент) Or 
//		   ЗначениеЗаполнено(vSrvRow.Агент) And vSrvRow.Агент <> AccountingCustomer Тогда
//			vSrvRow.Агент = Неопределено;
//			vSrvRow.ВидКомиссииАгента = Неопределено;
//			vSrvRow.КомиссияАгента = 0;
//		EndIf;
//		If vSrvRow.КомиссияАгента <> 0 Тогда
//			vSrvRow.СуммаКомиссии = vDocRow.СуммаКомиссии;
//			vSrvRow.СуммаКомиссииНДС = vDocRow.СуммаКомиссииНДС;
//		EndIf;
//		
//		// Recalculate service according to the accounting currency
//		pmRecalculateService(vSrvRow, pDoc.ВалютаЛицСчета, pDoc.FolioCurrencyExchangeRate);
//		
//		// Fill remarks by service description by default
//		vServiceDescription = TrimAll(vSrvRow.Услуга);
//		If ЗначениеЗаполнено(vSrvRow.Услуга) Тогда
//			vServiceObj = vSrvRow.Услуга.GetObject();
//			vServiceDescription = vServiceObj.pmGetServiceDescription(vLanguage);
//		EndIf;
//		vSrvRow.Примечания = vServiceDescription + 
//						  ?(IsBlankString(vSrvRow.Примечания), "", " - " +TrimAll(vSrvRow.Примечания));
//	EndDo;
//	
//	// Fill totals
//	If ЗначениеЗаполнено(AccountingCustomer) And AccountingCustomer.DoNotPostCommission Тогда
//		Сумма = Services.Total("Сумма");
//		VATSum = Services.Total("СуммаНДС");
//	Else
//		Сумма = Services.Total("Сумма") - Services.Total("СуммаКомиссии");
//		VATSum = Services.Total("СуммаНДС") - Services.Total("VATCommissionSum");
//	EndIf;
//	
//	// Fill check date
//	pmFillCheckDate();
//КонецПроцедуры //pmFillByResourceReservation
//
////-----------------------------------------------------------------------------
//Процедура pmFillByAccommodation(pDoc, pDoNotClearServices = False) Экспорт
//	If НЕ ЗначениеЗаполнено(pDoc) Тогда
//		Return;
//	EndIf;
//	
//	vSetNewNumber = False;
//	If ЗначениеЗаполнено(pDoc.Гостиница) Тогда
//		If Гостиница <> pDoc.Гостиница Тогда
//			Гостиница = pDoc.Гостиница;
//			vSetNewNumber = True;
//		EndIf;
//	EndIf;
//	
//	ParentDoc = pDoc;
//	
//	// Fill accounting Контрагент, contract and guest group
//	AccountingCustomer = pDoc.Контрагент;
//	AccountingContract = pDoc.Договор;
//	GuestGroup = pDoc.ГруппаГостей;
//	
//	// Fill default Контрагент
//	If НЕ ЗначениеЗаполнено(AccountingCustomer) Тогда
//		If ЗначениеЗаполнено(Гостиница) Тогда
//			AccountingCustomer = Гостиница.IndividualsCustomer;
//			AccountingContract = Гостиница.IndividualsContract;
//		EndIf;
//	EndIf;
//	
//	// Fill currency
//	If ЗначениеЗаполнено(AccountingContract) Тогда
//		AccountingCurrency = AccountingContract.AccountingCurrency;
//		AccountingCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, AccountingCurrency, ExchangeRateDate);
//	Else
//		If ЗначениеЗаполнено(AccountingCustomer) Тогда
//			AccountingCurrency = AccountingCustomer.AccountingCurrency;
//			AccountingCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, AccountingCurrency, ExchangeRateDate);
//		EndIf;
//	EndIf;
//	
//	// Fill Фирма
//	If ЗначениеЗаполнено(pDoc.Фирма) Тогда
//		If Фирма <> pDoc.Фирма Тогда
//			Фирма = pDoc.Фирма;
//			vSetNewNumber = True;
//		EndIf;
//	Else
//		If ЗначениеЗаполнено(Гостиница) Тогда
//			If ЗначениеЗаполнено(Гостиница.Фирма) Тогда
//				If Фирма <> Гостиница.Фирма Тогда
//					Фирма = Гостиница.Фирма;
//					vSetNewNumber = True;
//				EndIf;
//			EndIf;
//		EndIf;
//	EndIf;
//	If ЗначениеЗаполнено(Фирма) Тогда
//		BankAccount = Фирма.BankAccount;
//		If НЕ ЗначениеЗаполнено(BankAccount) Or ЗначениеЗаполнено(BankAccount) And AccountingCurrency <> BankAccount.ВалютаСчета Тогда
//			vBankAccounts = Фирма.GetObject().pmGetCompanyBankAccounts(AccountingCurrency);
//			If vBankAccounts.Count() > 0 Тогда
//				vBankAccountsRow = vBankAccounts.Get(0);
//				BankAccount = vBankAccountsRow.BankAccount;
//			EndIf;
//		EndIf;
//	EndIf;
//	
//	// Set new number
//	If vSetNewNumber Тогда
//		SetNewNumber(TrimAll(Гостиница.GetObject().pmGetPrefix()));
//	EndIf;
//	
//	// Get Контрагент language
//	vLanguage = Неопределено;
//	If ЗначениеЗаполнено(AccountingCustomer) Тогда
//		vLanguage = AccountingCustomer.Language;
//	EndIf;
//	
//	// Fill contact information
//	ContactPerson = pDoc.КонтактноеЛицо;
//	Phone = pDoc.Телефон;
//	Fax = pDoc.Fax;
//	EMail = pDoc.EMail;
//	If ЗначениеЗаполнено(GuestGroup) And ЗначениеЗаполнено(GuestGroup.Client) Тогда
//		If IsBlankString(EMail) Тогда
//			If НЕ IsBlankString(GuestGroup.Client.EMail) Тогда
//				EMail = GuestGroup.Client.EMail;
//			EndIf;
//		EndIf;
//		If IsBlankString(Phone) Тогда
//			If НЕ IsBlankString(GuestGroup.Client.Телефон) Тогда
//				Phone = GuestGroup.Client.Телефон;
//			EndIf;
//		EndIf;
//		If IsBlankString(Fax) Тогда
//			If НЕ IsBlankString(GuestGroup.Client.Fax) Тогда
//				Fax = GuestGroup.Client.Fax;
//			EndIf;
//		EndIf;
//	EndIf;
//	
//	// Reset totals
//	Сумма = 0;
//	VATSum = 0;
//	
//	// Clear tabular part Services
//	If НЕ pDoNotClearServices Тогда
//		Services.Clear();
//	EndIf;
//	
//	// Get all folio current accounts receivable services with balances per end of time
//	vCharges = cmGetCurrentAccountsReceivableChargesWithBalances('39991231235959', , , ParentDoc, GuestGroup, AccountingCurrency, Гостиница);
//	
//	// Fill services tabular part
//	pmFillServices(vCharges, vLanguage);
//	
//	// Fill totals
//	If ЗначениеЗаполнено(AccountingCustomer) And AccountingCustomer.DoNotPostCommission Тогда
//		Сумма = Services.Total("Сумма");
//		VATSum = Services.Total("СуммаНДС");
//	Else
//		Сумма = Services.Total("Сумма") - Services.Total("СуммаКомиссии");
//		VATSum = Services.Total("СуммаНДС") - Services.Total("VATCommissionSum");
//	EndIf;
//	
//	// Fill check date
//	pmFillCheckDate();
//КонецПроцедуры //pmFillByAccommodation
//
////-----------------------------------------------------------------------------
//Процедура pmFillBySettlement(pDoc, pDoNotClearServices = False) Экспорт
//	If НЕ ЗначениеЗаполнено(pDoc) Тогда
//		Return;
//	EndIf;
//	
//	vSetNewNumber = False;
//	If ЗначениеЗаполнено(pDoc.Гостиница) Тогда
//		If Гостиница <> pDoc.Гостиница Тогда
//			Гостиница = pDoc.Гостиница;
//			vSetNewNumber = True;
//		EndIf;
//	EndIf;
//	
//	FillPropertyValues(ThisObject, pDoc, , "Number, Date, Автор, DeletionMark, Posted, ДокОснование, ExternalCode");
//	
//	ParentDoc = pDoc;
//	
//	// Fill Фирма
//	If НЕ ЗначениеЗаполнено(pDoc.Фирма) Тогда
//		If ЗначениеЗаполнено(Гостиница) Тогда
//			If ЗначениеЗаполнено(Гостиница.Фирма) Тогда
//				Фирма = Гостиница.Фирма;
//				vSetNewNumber = True;
//			EndIf;
//		EndIf;
//	EndIf;
//	If ЗначениеЗаполнено(Фирма) Тогда
//		BankAccount = Фирма.BankAccount;
//		If НЕ ЗначениеЗаполнено(BankAccount) Or ЗначениеЗаполнено(BankAccount) And AccountingCurrency <> BankAccount.ВалютаСчета Тогда
//			vBankAccounts = Фирма.GetObject().pmGetCompanyBankAccounts(AccountingCurrency);
//			If vBankAccounts.Count() > 0 Тогда
//				vBankAccountsRow = vBankAccounts.Get(0);
//				BankAccount = vBankAccountsRow.BankAccount;
//			EndIf;
//		EndIf;
//	EndIf;
//	
//	// Set new number
//	If vSetNewNumber Тогда
//		SetNewNumber(TrimAll(Гостиница.GetObject().pmGetPrefix()));
//	EndIf;
//	
//	// Reset totals
//	Сумма = 0;
//	VATSum = 0;
//	
//	// Clear tabular part Services
//	If НЕ pDoNotClearServices Тогда
//		Services.Clear();
//	EndIf;
//	
//	// Try get services posted by settlement to accounts
//	vServices = pDoc.GetObject().pmGetServicesPostedToAccounts();
//	If vServices.Count() = 0 Тогда
//		vServices = pDoc.Услуги;
//	EndIf;
//	
//	// Fill invoice services
//	For Each vDocRow In vServices Do
//		vSrvRow = Services.Add();
//		If ЗначениеЗаполнено(vDocRow.ДокОснование) Тогда
//			FillPropertyValues(vSrvRow, vDocRow.ДокОснование);
//		EndIf;
//		If ЗначениеЗаполнено(vDocRow.СчетПроживания) Тогда
//			FillPropertyValues(vSrvRow, vDocRow.СчетПроживания);
//		EndIf;
//		If ЗначениеЗаполнено(vDocRow.Начисление) Тогда
//			FillPropertyValues(vSrvRow, vDocRow.Начисление);
//		EndIf;
//		FillPropertyValues(vSrvRow, vDocRow);
//		
//		// Commission
//		If НЕ ЗначениеЗаполнено(vSrvRow.Агент) Or 
//		   ЗначениеЗаполнено(vSrvRow.Агент) And vSrvRow.Агент <> AccountingCustomer Тогда
//			vSrvRow.Агент = Неопределено;
//			vSrvRow.ВидКомиссииАгента = Неопределено;
//			vSrvRow.КомиссияАгента = 0;
//			vSrvRow.СуммаКомиссии = 0;
//			vSrvRow.СуммаКомиссииНДС = 0;
//		EndIf;
//	EndDo;
//	
//	// Fill totals
//	If ЗначениеЗаполнено(AccountingCustomer) And AccountingCustomer.DoNotPostCommission Тогда
//		Сумма = Services.Total("Сумма");
//		VATSum = Services.Total("СуммаНДС");
//	Else
//		Сумма = Services.Total("Сумма") - Services.Total("СуммаКомиссии");
//		VATSum = Services.Total("СуммаНДС") - Services.Total("VATCommissionSum");
//	EndIf;
//	
//	// Fill check date
//	If ЗначениеЗаполнено(GuestGroup) And НЕ ЗначениеЗаполнено(CheckDate) Тогда
//		vCheckDate = Неопределено;
//		If ЗначениеЗаполнено(AccountingContract) And AccountingContract.DaysAfterSettlement <> 0 And ЗначениеЗаполнено(Date) Тогда
//			vCheckDate = cmAddWorkingDays(BegOfDay(Date), (AccountingContract.DaysAfterSettlement + 1));
//		ElsIf ЗначениеЗаполнено(AccountingCustomer) And AccountingCustomer.DaysAfterSettlement <> 0 And ЗначениеЗаполнено(Date) Тогда
//			vCheckDate = cmAddWorkingDays(BegOfDay(Date), (AccountingCustomer.DaysAfterSettlement + 1));
//		EndIf;
//		If ЗначениеЗаполнено(vCheckDate) Тогда
//			CheckDate = vCheckDate;
//		EndIf;
//	EndIf;
//КонецПроцедуры //pmFillBySettlement
//
////-----------------------------------------------------------------------------
//Процедура pmFillByIssueHotelProducts(pDoc) Экспорт
//	If НЕ ЗначениеЗаполнено(pDoc) Тогда
//		Return;
//	EndIf;
//	
//	If ЗначениеЗаполнено(pDoc.Гостиница) Тогда
//		If Гостиница <> pDoc.Гостиница Тогда
//			Гостиница = pDoc.Гостиница;
//			SetNewNumber(TrimAll(Гостиница.GetObject().pmGetPrefix()));
//		EndIf;
//	EndIf;
//	
//	FillPropertyValues(ThisObject, pDoc, , "Number, Date, Автор, DeletionMark, Posted");
//	
//	// Fill accounting Контрагент and contract
//	AccountingCustomer = pDoc.Контрагент;
//	AccountingContract = pDoc.Договор;
//	
//	ParentDoc = pDoc;
//	
//	// Currency
//	AccountingCurrency = pDoc.Валюта;
//	AccountingCurrencyExchangeRate = pDoc.CurrencyExchangeRate;
//	
//	// Fill bank account
//	If ЗначениеЗаполнено(Фирма) Тогда
//		BankAccount = Фирма.BankAccount;
//		If НЕ ЗначениеЗаполнено(BankAccount) Or ЗначениеЗаполнено(BankAccount) And AccountingCurrency <> BankAccount.ВалютаСчета Тогда
//			vBankAccounts = Фирма.GetObject().pmGetCompanyBankAccounts(AccountingCurrency);
//			If vBankAccounts.Count() > 0 Тогда
//				vBankAccountsRow = vBankAccounts.Get(0);
//				BankAccount = vBankAccountsRow.BankAccount;
//			EndIf;
//		EndIf;
//	EndIf;
//	
//	// Reset totals
//	Сумма = 0;
//	VATSum = 0;
//	
//	// Clear tabular part Services
//	Services.Clear();
//	
//	// Get all services
//	For Each vDocRow In pDoc.ПутевкиКурсовки Do
//		If НЕ ЗначениеЗаполнено(vDocRow.Услуга) Тогда
//			Continue;
//		EndIf;
//		vServicesRow = Services.Add();
//		vServicesRow.УчетнаяДата = BegOfDay(pDoc.ДатаДок);
//		vServicesRow.Услуга = vDocRow.Услуга;
//		vServicesRow.Цена = vDocRow.Цена;
//		vServicesRow.Количество = vDocRow.Количество;
//		vServicesRow.ЕдИзмерения = NStr("en='pcs.';ru='шт.';de='Stück'");
//		vServicesRow.Сумма = vDocRow.Сумма;
//		vServicesRow.СтавкаНДС = pDoc.СтавкаНДС;
//		vServicesRow.СуммаНДС = vDocRow.СуммаНДС;
//		vServicesRow.ТипНомера = vDocRow.ТипНомера;
//		vServicesRow.DateTimeFrom = vDocRow.CheckInDate;
//		vServicesRow.DateTimeTo = vDocRow.ДатаВыезда;
//		vServiceRemarks = vDocRow.Услуга.Description;
//		If НЕ IsBlankString(vDocRow.ProductStartCode) Тогда
//			If TrimAll(vDocRow.ProductStartCode) = TrimAll(vDocRow.ProductEndCode) Тогда
//				vServiceRemarks = TrimAll(vDocRow.ProductStartCode);
//			Else
//				vServiceRemarks = TrimAll(vDocRow.ProductStartCode) + " - " + TrimAll(vDocRow.ProductEndCode);
//			EndIf;
//		EndIf;
//		vServicesRow.Примечания = vServiceRemarks;
//	EndDo;
//	
//	// Fill totals
//	If ЗначениеЗаполнено(AccountingCustomer) And AccountingCustomer.DoNotPostCommission Тогда
//		Сумма = Services.Total("Сумма");
//		VATSum = Services.Total("СуммаНДС");
//	Else
//		Сумма = Services.Total("Сумма") - Services.Total("СуммаКомиссии");
//		VATSum = Services.Total("СуммаНДС") - Services.Total("VATCommissionSum");
//	EndIf;
//	
//	// Fill check date
//	pmFillCheckDate();
//КонецПроцедуры //pmFillByIssueHotelProducts
//
////-----------------------------------------------------------------------------
//Процедура pmFillByGuestGroup(pGuestGroup) Экспорт
//	If НЕ ЗначениеЗаполнено(pGuestGroup) Тогда
//		Return;
//	EndIf;
//	
//	// Accounting Контрагент, contract, hotel, Фирма, currency should be filled before calling Fill() method
//	GuestGroup = pGuestGroup;
//	If ЗначениеЗаполнено(GuestGroup) And ЗначениеЗаполнено(GuestGroup.Client) Тогда
//		If IsBlankString(EMail) Тогда
//			If НЕ IsBlankString(GuestGroup.Client.EMail) Тогда
//				EMail = GuestGroup.Client.EMail;
//			EndIf;
//		EndIf;
//		If IsBlankString(Phone) Тогда
//			If НЕ IsBlankString(GuestGroup.Client.Телефон) Тогда
//				Phone = GuestGroup.Client.Телефон;
//			EndIf;
//		EndIf;
//		If IsBlankString(Fax) Тогда
//			If НЕ IsBlankString(GuestGroup.Client.Fax) Тогда
//				Fax = GuestGroup.Client.Fax;
//			EndIf;
//		EndIf;
//	EndIf;
//	
//	// Get Контрагент language
//	vLanguage = Неопределено;
//	If ЗначениеЗаполнено(AccountingCustomer) Тогда
//		vLanguage = AccountingCustomer.Language;
//	EndIf;
//	
//	// Reset totals
//	Сумма = 0;
//	VATSum = 0;
//	
//	// List of main charges
//	vChargesToSkip = New СписокЗначений();
//	
//	// Clear tabular part Services
//	Services.Clear();
//	
//	// Get list of reservations (or accommodations) in the group
//	vGroupObj = GuestGroup.GetObject();
//	vReservations = New ValueTable();
//	vAccommodations = New ValueTable();
//	//If ParentDoc = Неопределено Or TypeOf(ParentDoc) = Type("DocumentRef.Бронирование") Тогда
//	//	vReservations = vGroupObj.pmGetReservations(True, False);
//	//	vAccommodations = vGroupObj.pmGetAccommodations(True);
//	//EndIf;
//	//vResourceReservations = New ValueTable();
//	//If ParentDoc = Неопределено Or TypeOf(ParentDoc) = Type("DocumentRef.ResourceReservation") Тогда
//	//	vResourceReservations = vGroupObj.pmGetResourceReservations();
//	//EndIf;
//	
//	// Initialize working table with services
//	vServices = Services.Unload();
//	vServices.Columns.Add("Document");
//	
//	// Fill services for each reservation in the list
//	For Each vRow In vReservations Do
//		vDoc = vRow.Бронирование;
//		vDoCharging = vDoc.DoCharging;
//		vIsActive = False;
//		If ЗначениеЗаполнено(vRow.Status) Тогда
//			vIsActive = vRow.Status.IsActive;
//		EndIf;
//		
//		// Add services to the working table from the current document tabular part
//		If НЕ vDoCharging And vIsActive Тогда
//			For Each vDocRow In vDoc.Услуги Do
//				If ЗначениеЗаполнено(vDocRow.СчетПроживания) And
//				   (vDocRow.СчетПроживания.Контрагент = AccountingCustomer Or (vDocRow.СчетПроживания.Контрагент = Справочники.Контрагенты.EmptyRef() And AccountingCustomer = Гостиница.IndividualsCustomer)) And 
//				   (vDocRow.СчетПроживания.Договор = AccountingContract Or (vDocRow.СчетПроживания.Договор = Справочники.Договора.EmptyRef() And AccountingContract = Гостиница.IndividualsContract)) Тогда
//					vSrvRow = vServices.Add();
//					vSrvRow.Document = vDoc;
//					
//					FillPropertyValues(vSrvRow, vDoc);
//					FillPropertyValues(vSrvRow, vDocRow);
//					
//					vSrvRow.Клиент = vDoc.Клиент;
//					vSrvRow.DateTimeFrom = vDoc.CheckInDate;
//					vSrvRow.DateTimeTo = vDoc.ДатаВыезда;
//					If НЕ ЗначениеЗаполнено(vDoc.НомерРазмещения) Тогда
//						vSrvRow.НомерРазмещения = vDoc.НомерДока;
//					EndIf;
//					
//					vSrvRow.Сумма = vDocRow.Сумма - vDocRow.СуммаСкидки;
//					vSrvRow.СуммаНДС = vDocRow.СуммаНДС - vDocRow.НДСскидка;
//					vSrvRow.Цена = cmRecalculatePrice(vSrvRow.Сумма, vSrvRow.Количество);
//					
//					// Discounts
//					vSrvRow.Скидка = vDocRow.Скидка;
//					vSrvRow.СуммаСкидки = vDocRow.СуммаСкидки;
//					
//					// Commission
//					vSrvRow.СуммаКомиссии = 0;
//					vSrvRow.СуммаКомиссииНДС = 0;
//					vSrvRow.Агент = Неопределено;
//					If ЗначениеЗаполнено(vDocRow.СчетПроживания) Тогда
//						vSrvRow.Агент = vDocRow.СчетПроживания.Агент;
//					EndIf;
//					vSrvRow.ВидКомиссииАгента = vDoc.ВидКомиссииАгента;
//					vSrvRow.КомиссияАгента = vDoc.КомиссияАгента;
//					If НЕ ЗначениеЗаполнено(vSrvRow.Агент) Or 
//					   ЗначениеЗаполнено(vSrvRow.Агент) And vSrvRow.Агент <> AccountingCustomer Тогда
//						vSrvRow.Агент = Неопределено;
//						vSrvRow.ВидКомиссииАгента = Неопределено;
//						vSrvRow.КомиссияАгента = 0;
//					EndIf;
//					If vSrvRow.КомиссияАгента <> 0 Тогда
//						// Check that current service fit to the commission service group
//						If cmIsServiceInServiceGroup(vSrvRow.Услуга, vDoc.КомиссияАгентУслуги) Тогда
//							If vSrvRow.ВидКомиссииАгента = Перечисления.AgentCommissionTypes.Percent Тогда
//								vSrvRow.СуммаКомиссии = Round(vSrvRow.Сумма * vSrvRow.КомиссияАгента / 100, 2);
//								vSrvRow.СуммаКомиссииНДС = cmCalculateVATSum(vSrvRow.СтавкаНДС, vSrvRow.СуммаКомиссии);
//							ElsIf vSrvRow.ВидКомиссииАгента = Перечисления.AgentCommissionTypes.FirstDayPercent Тогда
//								If BegOfDay(vDoc.CheckInDate) = BegOfDay(vSrvRow.УчетнаяДата) Тогда
//									vSrvRow.СуммаКомиссии = Round(vSrvRow.Сумма * vSrvRow.КомиссияАгента / 100, 2);
//									vSrvRow.СуммаКомиссииНДС = cmCalculateVATSum(vSrvRow.СтавкаНДС, vSrvRow.СуммаКомиссии);
//								EndIf;
//							EndIf;
//						Else
//							vSrvRow.Агент = Неопределено;
//							vSrvRow.ВидКомиссииАгента = Неопределено;
//							vSrvRow.КомиссияАгента = 0;
//						EndIf;
//					EndIf;
//					
//					// Check base ГруппаНомеров type
//					If ЗначениеЗаполнено(vSrvRow.ТипНомера) And ЗначениеЗаполнено(vDoc.ТипНомераРасчет) And vDoc.ТипНомераРасчет.BaseRoomType = vSrvRow.ТипНомера Тогда
//						vSrvRow.ТипНомера = vDoc.ТипНомераРасчет;
//					EndIf;
//					
//					// Recalculate service according to the accounting currency
//					pmRecalculateService(vSrvRow, vDocRow.ВалютаЛицСчета, vDocRow.FolioCurrencyExchangeRate);
//					
//					// Fill remarks by service description by default
//					vServiceDescription = TrimAll(vSrvRow.Услуга);
//					If ЗначениеЗаполнено(vSrvRow.Услуга) Тогда
//						vServiceObj = vSrvRow.Услуга.GetObject();
//						vServiceDescription = vServiceObj.pmGetServiceDescription(vLanguage);
//					EndIf;
//					vSrvRow.Примечания = vServiceDescription;
//					
//					// Clear accounting date if this is ГруппаНомеров rate service
//					If НЕ vDocRow.IsManual Тогда
//						vSrvRow.УчетнаяДата = '00010101';
//					Else
//						vSrvRow.Примечания = TrimR(vSrvRow.Примечания) + ?(IsBlankString(vDocRow.Примечания), "", " - " + TrimAll(vDocRow.Примечания));
//					EndIf;
//				EndIf;
//			EndDo;
//		EndIf;
//		
//		// Get charges from current reservation folios
//		vCharges = cmGetDocumentCharges(vDoc, AccountingCustomer, AccountingContract, Гостиница, Неопределено);
//		For Each vDocRow In vCharges Do
//			vChargesToSkip.Add(vDocRow.Recorder);
//			
//			vParentDoc = Неопределено;
//			If ЗначениеЗаполнено(vDocRow.Recorder.ДокОснование) And TypeOf(vDocRow.Recorder.ДокОснование) = Type("DocumentRef.Бронирование") Тогда
//				vParentDoc = vDocRow.Recorder.ДокОснование;
//			EndIf;
//			
//			vSrvRow = vServices.Add();
//			
//			FillPropertyValues(vSrvRow, vDoc);
//			FillPropertyValues(vSrvRow, vDocRow);
//			
//			If ЗначениеЗаполнено(vParentDoc) Тогда
//				vSrvRow.Клиент = vParentDoc.Клиент;
//				vSrvRow.DateTimeFrom = vParentDoc.CheckInDate;
//				vSrvRow.DateTimeTo = vParentDoc.ДатаВыезда;
//				If НЕ ЗначениеЗаполнено(vParentDoc.НомерРазмещения) Тогда
//					vSrvRow.НомерРазмещения = vParentDoc.НомерДока;
//				Else
//					vSrvRow.НомерРазмещения = vParentDoc.НомерРазмещения;
//				EndIf;
//			Else
//				vSrvRow.Клиент = vDoc.Клиент;
//				vSrvRow.DateTimeFrom = vDoc.CheckInDate;
//				vSrvRow.DateTimeTo = vDoc.ДатаВыезда;
//				If НЕ ЗначениеЗаполнено(vDoc.НомерРазмещения) Тогда
//					vSrvRow.НомерРазмещения = vDoc.НомерДока;
//				Else
//					vSrvRow.НомерРазмещения = vDoc.НомерРазмещения;
//				EndIf;
//			EndIf;
//			
//			// Discounts
//			vSrvRow.Скидка = vDocRow.Скидка;
//			vSrvRow.СуммаСкидки = vDocRow.СуммаСкидки;
//			
//			// Commission
//			vSrvRow.СуммаКомиссии = 0;
//			vSrvRow.СуммаКомиссииНДС = 0;
//			vSrvRow.Агент = Неопределено;
//			If ЗначениеЗаполнено(vDocRow.СчетПроживания) Тогда
//				vSrvRow.Агент = vDocRow.СчетПроживания.Агент;
//			EndIf;
//			vSrvRow.ВидКомиссииАгента = vDocRow.ВидКомиссииАгента;
//			vSrvRow.КомиссияАгента = vDocRow.КомиссияАгента;
//			If НЕ ЗначениеЗаполнено(vSrvRow.Агент) Or 
//			   ЗначениеЗаполнено(vSrvRow.Агент) And vSrvRow.Агент <> AccountingCustomer Тогда
//				vSrvRow.Агент = Неопределено;
//				vSrvRow.ВидКомиссииАгента = Неопределено;
//				vSrvRow.КомиссияАгента = 0;
//			EndIf;
//			If vSrvRow.КомиссияАгента <> 0 Тогда
//				vSrvRow.СуммаКомиссии = vDocRow.СуммаКомиссии;
//				vSrvRow.СуммаКомиссииНДС = vDocRow.СуммаКомиссииНДС;
//			EndIf;
//			
//			// Check base ГруппаНомеров type
//			If ЗначениеЗаполнено(vSrvRow.ТипНомера) And ЗначениеЗаполнено(vDoc.ТипНомераРасчет) And vDoc.ТипНомераРасчет.BaseRoomType = vSrvRow.ТипНомера Тогда
//				vSrvRow.ТипНомера = vDoc.ТипНомераРасчет;
//			EndIf;
//			
//			// Recalculate service according to the accounting currency
//			pmRecalculateService(vSrvRow, vDocRow.ВалютаЛицСчета, vDocRow.FolioCurrencyExchangeRate);
//			
//			// Fill remarks by service description by default
//			vServiceDescription = TrimAll(vSrvRow.Услуга);
//			If ЗначениеЗаполнено(vSrvRow.Услуга) Тогда
//				vServiceObj = vSrvRow.Услуга.GetObject();
//				vServiceDescription = vServiceObj.pmGetServiceDescription(vLanguage);
//			EndIf;
//			vSrvRow.Примечания = vServiceDescription + 
//							  ?(IsBlankString(vSrvRow.Примечания), "", " - " + TrimAll(vSrvRow.Примечания));
//		EndDo;
//	EndDo;
//	
//	// Fill services for each accommodation in the list
//	For Each vRow In vAccommodations Do
//		vDoc = vRow.Размещение;
//		
//		// Get charges from current reservation folios
//		vCharges = cmGetDocumentCharges(vDoc, AccountingCustomer, AccountingContract, Гостиница, Неопределено);
//		For Each vDocRow In vCharges Do
//			vChargesToSkip.Add(vDocRow.Recorder);
//			
//			vParentDoc = Неопределено;
//			If ЗначениеЗаполнено(vDocRow.Recorder.ДокОснование) And TypeOf(vDocRow.Recorder.ДокОснование) = Type("DocumentRef.Размещение") Тогда
//				vParentDoc = vDocRow.Recorder.ДокОснование;
//			EndIf;
//			
//			vSrvRow = vServices.Add();
//			
//			FillPropertyValues(vSrvRow, vDoc);
//			FillPropertyValues(vSrvRow, vDocRow);
//			
//			If ЗначениеЗаполнено(vParentDoc) Тогда
//				vSrvRow.Клиент = vParentDoc.Клиент;
//				vSrvRow.DateTimeFrom = vParentDoc.CheckInDate;
//				vSrvRow.DateTimeTo = vParentDoc.ДатаВыезда;
//				vSrvRow.НомерРазмещения = vParentDoc.НомерРазмещения;
//			Else
//				vSrvRow.Клиент = vDoc.Клиент;
//				vSrvRow.DateTimeFrom = vDoc.CheckInDate;
//				vSrvRow.DateTimeTo = vDoc.ДатаВыезда;
//				vSrvRow.НомерРазмещения = vDoc.НомерРазмещения;
//			EndIf;
//			
//			// Discounts
//			vSrvRow.Скидка = vDocRow.Скидка;
//			vSrvRow.СуммаСкидки = vDocRow.СуммаСкидки;
//			
//			// Commission
//			vSrvRow.СуммаКомиссии = 0;
//			vSrvRow.СуммаКомиссииНДС = 0;
//			vSrvRow.Агент = Неопределено;
//			If ЗначениеЗаполнено(vDocRow.СчетПроживания) Тогда
//				vSrvRow.Агент = vDocRow.СчетПроживания.Агент;
//			EndIf;
//			vSrvRow.ВидКомиссииАгента = vDocRow.ВидКомиссииАгента;
//			vSrvRow.КомиссияАгента = vDocRow.КомиссияАгента;
//			If НЕ ЗначениеЗаполнено(vSrvRow.Агент) Or 
//			   ЗначениеЗаполнено(vSrvRow.Агент) And vSrvRow.Агент <> AccountingCustomer Тогда
//				vSrvRow.Агент = Неопределено;
//				vSrvRow.ВидКомиссииАгента = Неопределено;
//				vSrvRow.КомиссияАгента = 0;
//			EndIf;
//			If vSrvRow.КомиссияАгента <> 0 Тогда
//				vSrvRow.СуммаКомиссии = vDocRow.СуммаКомиссии;
//				vSrvRow.СуммаКомиссииНДС = vDocRow.СуммаКомиссииНДС;
//			EndIf;
//					
//			// Check base ГруппаНомеров type
//			If ЗначениеЗаполнено(vSrvRow.ТипНомера) And ЗначениеЗаполнено(vDoc.ТипНомераРасчет) And vDoc.ТипНомераРасчет.BaseRoomType = vSrvRow.ТипНомера Тогда
//				vSrvRow.ТипНомера = vDoc.ТипНомераРасчет;
//			EndIf;
//			
//			// Recalculate service according to the accounting currency
//			pmRecalculateService(vSrvRow, vDocRow.ВалютаЛицСчета, vDocRow.FolioCurrencyExchangeRate);
//			
//			// Fill remarks by service description by default
//			vServiceDescription = TrimAll(vSrvRow.Услуга);
//			If ЗначениеЗаполнено(vSrvRow.Услуга) Тогда
//				vServiceObj = vSrvRow.Услуга.GetObject();
//				vServiceDescription = vServiceObj.pmGetServiceDescription(vLanguage);
//			EndIf;
//			vSrvRow.Примечания = vServiceDescription + 
//							  ?(IsBlankString(vSrvRow.Примечания), "", " - " + TrimAll(vSrvRow.Примечания));
//		EndDo;
//	EndDo;
//	
//	// Fill services for each resource reservation in the list
//	//For Each vRow In vResourceReservations Do
//	//	vDoc = vRow.Бронирование;
//	//	
//	//	// Add services to the working table from the current document tabular part
//	//	If vDoc.Posted And ЗначениеЗаполнено(vRow.Status) And vRow.Status.IsActive Тогда
//	//		If НЕ vDoc.DoCharging Тогда
//	//			For Each vDocRow In vDoc.Услуги Do
//	//				If ЗначениеЗаполнено(vDoc.ChargingFolio) And
//	//				   (vDoc.ChargingFolio.Контрагент = AccountingCustomer Or (vDoc.ChargingFolio.Контрагент = Справочники.Контрагенты.EmptyRef() And AccountingCustomer = Гостиница.IndividualsCustomer)) And 
//	//				   (vDoc.ChargingFolio.Договор = AccountingContract Or (vDoc.ChargingFolio.Договор = Справочники.Договора.EmptyRef() And AccountingContract = Гостиница.IndividualsContract)) Тогда
//	//					vSrvRow = vServices.Add();
//	//					vSrvRow.Document = vDoc;
//	//					
//	//					FillPropertyValues(vSrvRow, vDoc);
//	//					FillPropertyValues(vSrvRow, vDocRow);
//	//					
//	//					vSrvRow.Сумма = vDocRow.Сумма - vDocRow.DiscountSum;
//	//					vSrvRow.VATSum = vDocRow.VATSum - vDocRow.НДСскидка;
//	//					vSrvRow.Цена = cmRecalculatePrice(vSrvRow.Сумма, vSrvRow.Quantity);
//	//					
//	//					// Discounts
//	//					vSrvRow.Discount = vDocRow.Discount;
//	//					vSrvRow.DiscountSum = vDocRow.DiscountSum;
//	//					
//	//					// Commission
//	//					vSrvRow.СуммаКомиссии = 0;
//	//					vSrvRow.VATCommissionSum = 0;
//	//					vSrvRow.Agent = Неопределено;
//	//					If ЗначениеЗаполнено(vDoc.ChargingFolio) Тогда
//	//						vSrvRow.Agent = vDoc.ChargingFolio.Agent;
//	//					EndIf;
//	//					vSrvRow.ВидКомиссииАгента = vDoc.ВидКомиссииАгента;
//	//					vSrvRow.КомиссияАгента = vDoc.КомиссияАгента;
//	//					If НЕ ЗначениеЗаполнено(vSrvRow.Agent) Or 
//	//					   ЗначениеЗаполнено(vSrvRow.Agent) And vSrvRow.Agent <> AccountingCustomer Тогда
//	//						vSrvRow.Agent = Неопределено;
//	//						vSrvRow.ВидКомиссииАгента = Неопределено;
//	//						vSrvRow.КомиссияАгента = 0;
//	//					EndIf;
//	//					If vSrvRow.КомиссияАгента <> 0 Тогда
//	//						// Check that current service fit to the commission service group
//	//						If cmIsServiceInServiceGroup(vSrvRow.Услуга, vDoc.AgentCommissionServiceGroup) Тогда
//	//							If vSrvRow.ВидКомиссииАгента = Перечисления.AgentCommissionTypes.Percent Тогда
//	//								vSrvRow.СуммаКомиссии = Round(vSrvRow.Сумма * vSrvRow.КомиссияАгента / 100, 2);
//	//								vSrvRow.VATCommissionSum = cmCalculateVATSum(vSrvRow.СтавкаНДС, vSrvRow.СуммаКомиссии);
//	//							ElsIf vSrvRow.ВидКомиссииАгента = Перечисления.AgentCommissionTypes.FirstDayPercent Тогда
//	//								If BegOfDay(vDoc.DateTimeFrom) = BegOfDay(vSrvRow.УчетнаяДата) Тогда
//	//									vSrvRow.СуммаКомиссии = Round(vSrvRow.Сумма * vSrvRow.КомиссияАгента / 100, 2);
//	//									vSrvRow.VATCommissionSum = cmCalculateVATSum(vSrvRow.СтавкаНДС, vSrvRow.СуммаКомиссии);
//	//								EndIf;
//	//							EndIf;
//	//						Else
//	//							vSrvRow.Agent = Неопределено;
//	//							vSrvRow.ВидКомиссииАгента = Неопределено;
//	//							vSrvRow.КомиссияАгента = 0;
//	//						EndIf;
//	//					EndIf;
//	//					
//	//					// Recalculate service according to the accounting currency
//	//					pmRecalculateService(vSrvRow, vDoc.FolioCurrency, vDoc.FolioCurrencyExchangeRate);
//	//					
//	//					// Fill remarks by service description by default
//	//					vServiceDescription = TrimAll(vSrvRow.Услуга);
//	//					If ЗначениеЗаполнено(vSrvRow.Услуга) Тогда
//	//						vServiceObj = vSrvRow.Услуга.GetObject();
//	//						vServiceDescription = vServiceObj.pmGetServiceDescription(vLanguage);
//	//					EndIf;
//	//					vSrvRow.Примечания = vServiceDescription;
//	//					
//	//					// Clear accounting date if this is ГруппаНомеров rate service
//	//					If НЕ vDocRow.IsManual Тогда
//	//						vSrvRow.УчетнаяДата = '00010101';
//	//					Else
//	//						vSrvRow.Примечания = TrimR(vSrvRow.Примечания) + ?(IsBlankString(vDocRow.Примечания), "", " - " +TrimAll(vDocRow.Примечания));
//	//					EndIf;
//	//				EndIf;
//	//			EndDo;
//	//		Else
//	//			For Each vDocRow In vDoc.Услуги Do
//	//				If ЗначениеЗаполнено(vDocRow.Услуга) And ЗначениеЗаполнено(vDocRow.Услуга.ServiceType) And vDocRow.Услуга.ServiceType.ActualAmountIsChargedExternally Тогда
//	//					If ЗначениеЗаполнено(vDoc.ChargingFolio) And
//	//					   (vDoc.ChargingFolio.Контрагент = AccountingCustomer Or (vDoc.ChargingFolio.Контрагент = Справочники.Контрагенты.EmptyRef() And AccountingCustomer = Гостиница.IndividualsCustomer)) And 
//	//					   (vDoc.ChargingFolio.Договор = AccountingContract Or (vDoc.ChargingFolio.Договор = Справочники.Договора.EmptyRef() And AccountingContract = Гостиница.IndividualsContract)) Тогда
//	//						vSrvRow = vServices.Add();
//	//						vSrvRow.Document = vDoc;
//	//						
//	//						FillPropertyValues(vSrvRow, vDoc);
//	//						FillPropertyValues(vSrvRow, vDocRow);
//	//						
//	//						vSrvRow.Сумма = vDocRow.Сумма - vDocRow.DiscountSum;
//	//						vSrvRow.VATSum = vDocRow.VATSum - vDocRow.НДСскидка;
//	//						vSrvRow.Цена = cmRecalculatePrice(vSrvRow.Сумма, vSrvRow.Quantity);
//	//						
//	//						// Discounts
//	//						vSrvRow.Discount = vDocRow.Discount;
//	//						vSrvRow.DiscountSum = vDocRow.DiscountSum;
//	//						
//	//						// Commission
//	//						vSrvRow.СуммаКомиссии = 0;
//	//						vSrvRow.VATCommissionSum = 0;
//	//						vSrvRow.Agent = Неопределено;
//	//						If ЗначениеЗаполнено(vDoc.ChargingFolio) Тогда
//	//							vSrvRow.Agent = vDoc.ChargingFolio.Agent;
//	//						EndIf;
//	//						vSrvRow.ВидКомиссииАгента = vDoc.ВидКомиссииАгента;
//	//						vSrvRow.КомиссияАгента = vDoc.КомиссияАгента;
//	//						If НЕ ЗначениеЗаполнено(vSrvRow.Agent) Or 
//	//						   ЗначениеЗаполнено(vSrvRow.Agent) And vSrvRow.Agent <> AccountingCustomer Тогда
//	//							vSrvRow.Agent = Неопределено;
//	//							vSrvRow.ВидКомиссииАгента = Неопределено;
//	//							vSrvRow.КомиссияАгента = 0;
//	//						EndIf;
//	//						If vSrvRow.КомиссияАгента <> 0 Тогда
//	//							// Check that current service fit to the commission service group
//	//							If cmIsServiceInServiceGroup(vSrvRow.Услуга, vDoc.AgentCommissionServiceGroup) Тогда
//	//								If vSrvRow.ВидКомиссииАгента = Перечисления.AgentCommissionTypes.Percent Тогда
//	//									vSrvRow.СуммаКомиссии = Round(vSrvRow.Сумма * vSrvRow.КомиссияАгента / 100, 2);
//	//									vSrvRow.VATCommissionSum = cmCalculateVATSum(vSrvRow.СтавкаНДС, vSrvRow.СуммаКомиссии);
//	//								ElsIf vSrvRow.ВидКомиссииАгента = Перечисления.AgentCommissionTypes.FirstDayPercent Тогда
//	//									If BegOfDay(vDoc.DateTimeFrom) = BegOfDay(vSrvRow.УчетнаяДата) Тогда
//	//										vSrvRow.СуммаКомиссии = Round(vSrvRow.Сумма * vSrvRow.КомиссияАгента / 100, 2);
//	//										vSrvRow.VATCommissionSum = cmCalculateVATSum(vSrvRow.СтавкаНДС, vSrvRow.СуммаКомиссии);
//	//									EndIf;
//	//								EndIf;
//	//							Else
//	//								vSrvRow.Agent = Неопределено;
//	//								vSrvRow.ВидКомиссииАгента = Неопределено;
//	//								vSrvRow.КомиссияАгента = 0;
//	//							EndIf;
//	//						EndIf;
//	//						
//	//						// Recalculate service according to the accounting currency
//	//						pmRecalculateService(vSrvRow, vDoc.FolioCurrency, vDoc.FolioCurrencyExchangeRate);
//	//						
//	//						// Fill remarks by service description by default
//	//						vServiceDescription = TrimAll(vSrvRow.Услуга);
//	//						If ЗначениеЗаполнено(vSrvRow.Услуга) Тогда
//	//							vServiceObj = vSrvRow.Услуга.GetObject();
//	//							vServiceDescription = vServiceObj.pmGetServiceDescription(vLanguage);
//	//						EndIf;
//	//						vSrvRow.Примечания = vServiceDescription;
//	//						
//	//						// Clear accounting date if this is ГруппаНомеров rate service
//	//						If НЕ vDocRow.IsManual Тогда
//	//							vSrvRow.УчетнаяДата = '00010101';
//	//						Else
//	//							vSrvRow.Примечания = TrimR(vSrvRow.Примечания) + ?(IsBlankString(vDocRow.Примечания), "", " - " + TrimAll(vDocRow.Примечания));
//	//						EndIf;
//	//					EndIf;
//	//				EndIf;
//	//			EndDo;
//	//		EndIf;
//	//		
//	//		// Get charges from current resource reservation folios
//	//		vCharges = cmGetDocumentCharges(vDoc, AccountingCustomer, AccountingContract, Гостиница, Неопределено);
//	//		For Each vDocRow In vCharges Do
//	//			vChargesToSkip.Add(vDocRow.Recorder);
//	//			
//	//			vSrvRow = vServices.Add();
//	//			
//	//			FillPropertyValues(vSrvRow, vDoc);
//	//			FillPropertyValues(vSrvRow, vDocRow);
//	//			
//	//			// Discounts
//	//			vSrvRow.Discount = vDocRow.Discount;
//	//			vSrvRow.DiscountSum = vDocRow.DiscountSum;
//	//			
//	//			// Commission
//	//			vSrvRow.СуммаКомиссии = 0;
//	//			vSrvRow.VATCommissionSum = 0;
//	//			vSrvRow.Agent = Неопределено;
//	//			If ЗначениеЗаполнено(vDocRow.СчетПроживания) Тогда
//	//				vSrvRow.Agent = vDocRow.СчетПроживания.Agent;
//	//			EndIf;
//	//			vSrvRow.ВидКомиссииАгента = vDocRow.ВидКомиссииАгента;
//	//			vSrvRow.КомиссияАгента = vDocRow.КомиссияАгента;
//	//			If НЕ ЗначениеЗаполнено(vSrvRow.Agent) Or 
//	//			   ЗначениеЗаполнено(vSrvRow.Agent) And vSrvRow.Agent <> AccountingCustomer Тогда
//	//				vSrvRow.Agent = Неопределено;
//	//				vSrvRow.ВидКомиссииАгента = Неопределено;
//	//				vSrvRow.КомиссияАгента = 0;
//	//			EndIf;
//	//			If vSrvRow.КомиссияАгента <> 0 Тогда
//	//				vSrvRow.СуммаКомиссии = vDocRow.СуммаКомиссии;
//	//				vSrvRow.VATCommissionSum = vDocRow.VATCommissionSum;
//	//			EndIf;
//	//			
//	//			// Recalculate service according to the accounting currency
//	//			pmRecalculateService(vSrvRow, vDoc.FolioCurrency, vDoc.FolioCurrencyExchangeRate);
//	//			
//	//			// Fill remarks by service description by default
//	//			vServiceDescription = TrimAll(vSrvRow.Услуга);
//	//			If ЗначениеЗаполнено(vSrvRow.Услуга) Тогда
//	//				vServiceObj = vSrvRow.Услуга.GetObject();
//	//				vServiceDescription = vServiceObj.pmGetServiceDescription(vLanguage);
//	//			EndIf;
//	//			vSrvRow.Примечания = vServiceDescription + 
//	//							  ?(IsBlankString(vSrvRow.Примечания), "", " - " + TrimAll(vSrvRow.Примечания));
//	//		EndDo;
//	//	EndIf;
//	//EndDo;
//
//	// Group all services
//	vServices.GroupBy("Document, УчетнаяДата, Услуга, Примечания, Цена, ЕдИзмерения, СтавкаНДС, ВидРазмещения, КоличествоЧеловек, RoomQuantity, Клиент, ТипНомера, НомерРазмещения, ПутевкаКурсовка, IsInPrice, IsRoomRevenue, Ресурс, IsResourceRevenue, DateTimeFrom, DateTimeTo, ТипДеньКалендарь, Агент, Скидка, ВидКомиссииАгента, КомиссияАгента", "Количество, Сумма, СуммаНДС, СуммаСкидки, СуммаКомиссии, VATCommissionSum");
//	
//	// Load resulting value table to the invoice services
//	Services.Load(vServices);
//	
//	// Get all Контрагент current accounts receivable services with balances per end of time
//	vOtherCharges = cmGetCurrentAccountsReceivableChargesWithBalances('39991231235959', AccountingCustomer, AccountingContract, Неопределено, GuestGroup, AccountingCurrency, Гостиница, vChargesToSkip);
//	// Fill services tabular part
//	pmFillServices(vOtherCharges, vLanguage);
//	
//	// Fill totals
//	If ЗначениеЗаполнено(AccountingCustomer) And AccountingCustomer.DoNotPostCommission Тогда
//		Сумма = Services.Total("Сумма");
//		VATSum = Services.Total("СуммаНДС");
//	Else
//		Сумма = Services.Total("Сумма") - Services.Total("СуммаКомиссии");
//		VATSum = Services.Total("СуммаНДС") - Services.Total("VATCommissionSum");
//	EndIf;
//	
//	// Fill check date
//	pmFillCheckDate();
//КонецПроцедуры //pmFillByGuestGroup
//
////-----------------------------------------------------------------------------
//Процедура pmFillByCustomer(pCustomer) Экспорт
//	If НЕ ЗначениеЗаполнено(pCustomer) Тогда
//		Return;
//	EndIf;
//	
//	// Accounting Контрагент
//	AccountingCustomer = pCustomer;
//	If ЗначениеЗаполнено(AccountingCustomer.Contract) Тогда
//		AccountingContract = AccountingCustomer.Contract;
//	EndIf;
//	
//	// Fill currency
//	If ЗначениеЗаполнено(AccountingContract) Тогда
//		AccountingCurrency = AccountingContract.AccountingCurrency;
//		AccountingCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, AccountingCurrency, ExchangeRateDate);
//	Else
//		If ЗначениеЗаполнено(AccountingCustomer) Тогда
//			AccountingCurrency = AccountingCustomer.AccountingCurrency;
//			AccountingCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, AccountingCurrency, ExchangeRateDate);
//		EndIf;
//	EndIf;
//	
//	// Get Контрагент language
//	vLanguage = Неопределено;
//	If ЗначениеЗаполнено(AccountingCustomer) Тогда
//		vLanguage = AccountingCustomer.Language;
//	EndIf;
//	
//	// Reset totals
//	Сумма = 0;
//	VATSum = 0;
//	
//	// Clear tabular part Services
//	Services.Clear();
//	
//	// Get all Контрагент current accounts receivable services with balances per end of time
//	//vCharges = cmGetCurrentAccountsReceivableChargesWithBalances('39991231235959', AccountingCustomer, , ParentDoc, GuestGroup, AccountingCurrency, Гостиница);
//	
//	// Fill services tabular part
//	//pmFillServices(vCharges, vLanguage);
//	
//	// Fill totals
//	If ЗначениеЗаполнено(AccountingCustomer) And AccountingCustomer.DoNotPostCommission Тогда
//		Сумма = Services.Total("Сумма");
//		VATSum = Services.Total("СуммаНДС");
//	Else
//		Сумма = Services.Total("Сумма") - Services.Total("СуммаКомиссии");
//		VATSum = Services.Total("СуммаНДС") - Services.Total("VATCommissionSum");
//	EndIf;
//	
//	// Fill check date
//	pmFillCheckDate();
//КонецПроцедуры //pmFillByCustomer
//
////-----------------------------------------------------------------------------
//Процедура pmFillByContract(pContract) Экспорт
//	If НЕ ЗначениеЗаполнено(pContract) Тогда
//		Return;
//	EndIf;
//	
//	// Accounting Контрагент and contract
//	AccountingContract = pContract;
//	AccountingCustomer = pContract.Owner;
//	
//	// Fill currency
//	If ЗначениеЗаполнено(AccountingContract) Тогда
//		AccountingCurrency = AccountingContract.AccountingCurrency;
//		AccountingCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, AccountingCurrency, ExchangeRateDate);
//	Else
//		If ЗначениеЗаполнено(AccountingCustomer) Тогда
//			AccountingCurrency = AccountingCustomer.AccountingCurrency;
//			AccountingCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, AccountingCurrency, ExchangeRateDate);
//		EndIf;
//	EndIf;
//	
//	// Get Контрагент language
//	vLanguage = Неопределено;
//	If ЗначениеЗаполнено(AccountingCustomer) Тогда
//		vLanguage = AccountingCustomer.Language;
//	EndIf;
//	
//	// Reset totals
//	Сумма = 0;
//	VATSum = 0;
//	
//	// Clear tabular part Services
//	Services.Clear();
//	
//	// Get all contract current accounts receivable services with balances per end of time
//	//vCharges = cmGetCurrentAccountsReceivableChargesWithBalances('39991231235959', AccountingCustomer, AccountingContract, ParentDoc, GuestGroup, AccountingCurrency, Гостиница);
//	
//	// Fill services tabular part
//	//pmFillServices(vCharges, vLanguage);
//	
//	// Fill totals
//	If ЗначениеЗаполнено(AccountingCustomer) And AccountingCustomer.DoNotPostCommission Тогда
//		Сумма = Services.Total("Сумма");
//		VATSum = Services.Total("СуммаНДС");
//	Else
//		Сумма = Services.Total("Сумма") - Services.Total("СуммаКомиссии");
//		VATSum = Services.Total("СуммаНДС") - Services.Total("VATCommissionSum");
//	EndIf;
//	
//	// Fill check date
//	pmFillCheckDate();
//КонецПроцедуры //pmFillByContract
//
////-----------------------------------------------------------------------------
//Процедура Filling(pBase)
//	// Fill attributes with default values
//	pmFillAttributesWithDefaultValues();
//	// Fill from the base
//	If ЗначениеЗаполнено(pBase) Тогда
//		If TypeOf(pBase) = Type("DocumentRef.СчетПроживания") Тогда
//			pmFillByFolio(pBase);
//		ElsIf TypeOf(pBase) = Type("DocumentRef.Бронирование") Тогда 
//			pmFillByReservation(pBase);
//		ElsIf TypeOf(pBase) = Type("DocumentRef.БроньУслуг") Тогда 
//			pmFillByResourceReservation(pBase);
//		ElsIf TypeOf(pBase) = Type("DocumentRef.Размещение") Тогда 
//			pmFillByAccommodation(pBase);
//		ElsIf TypeOf(pBase) = Type("DocumentRef.Акт") Тогда 
//			pmFillBySettlement(pBase);
//		ElsIf TypeOf(pBase) = Type("DocumentRef.IssueHotelProducts") Тогда 
//			pmFillByIssueHotelProducts(pBase);
//		ElsIf TypeOf(pBase) = Type("CatalogRef.ГруппыГостей") Тогда
//			pmFillByGuestGroup(pBase);
//		ElsIf TypeOf(pBase) = Type("CatalogRef.Контрагенты") Тогда
//			pmFillByCustomer(pBase);
//		ElsIf TypeOf(pBase) = Type("CatalogRef.Договора") Тогда
//			pmFillByContract(pBase);
//		EndIf;
//		// Fill invoice contact information
//		If ЗначениеЗаполнено(AccountingCustomer) Тогда
//			If AccountingCustomer.BelongsToItem(Справочники.Контрагенты.КонтрагентПоУмолчанию) Тогда
//				If НЕ ЗначениеЗаполнено(ContactPerson) Тогда
//					ContactPerson = Title(TrimAll(AccountingCustomer.Description));
//				EndIf;
//			EndIf;
//			If НЕ ЗначениеЗаполнено(Phone) Тогда
//				Phone = TrimAll(AccountingCustomer.Phone);
//			EndIf;
//			If НЕ ЗначениеЗаполнено(Fax) Тогда
//				Fax = TrimAll(AccountingCustomer.Fax);
//			EndIf;
//			If НЕ ЗначениеЗаполнено(EMail) Тогда
//				EMail = TrimAll(AccountingCustomer.EMail);
//			EndIf;
//		EndIf;
//		// Fill new document number
//		If IsBlankString(Number) Тогда
//			SetNewNumber();
//		EndIf;
//	EndIf;
//КонецПроцедуры //Filling
//
////-----------------------------------------------------------------------------
//Function ServicesHasChanged()
//	vOldServices = Ref.Услуги;
//	If Services.Count() <> vOldServices.Count() Тогда
//		Return True;
//	ElsIf Services.Total("Сумма") <> vOldServices.Total("Сумма") Or 
//		  Services.Total("СуммаНДС") <> vOldServices.Total("СуммаНДС") Or 
//		  Services.Total("СуммаКомиссии") <> vOldServices.Total("СуммаКомиссии") Or 
//		  Services.Total("СуммаСкидки") <> vOldServices.Total("СуммаСкидки") Or 
//		  Services.Total("Количество") <> vOldServices.Total("Количество") Тогда
//		Return True;
//	Else
//		vNewServices = Services.Unload();
//		vOldServices = vOldServices.Unload();
//		vNewServices.GroupBy("Услуга", "Сумма, СуммаНДС, СуммаКомиссии, СуммаСкидки, Количество");
//		vOldServices.GroupBy("Услуга", "Сумма, СуммаНДС, СуммаКомиссии, СуммаСкидки, Количество");
//		For Each vNewServicesRow In vNewServices Do
//			vOldServicesRow = vOldServices.Find(vNewServicesRow.Service, "Услуга");
//			If vOldServicesRow = Неопределено Тогда
//				Return True;
//			ElsIf vOldServicesRow.Сумма <> vNewServicesRow.Sum Or 
//				  vOldServicesRow.СуммаНДС <> vNewServicesRow.VATSum Or 
//				  vOldServicesRow.СуммаКомиссии <> vNewServicesRow.CommissionSum Or 
//				  vOldServicesRow.СуммаСкидки <> vNewServicesRow.DiscountSum Or 
//				  vOldServicesRow.Количество <> vNewServicesRow.Quantity Тогда
//				Return True;
//			EndIf;
//		EndDo;
//		For Each vOldServicesRow In vOldServices Do
//			vNewServicesRow = vNewServices.Find(vOldServicesRow.Услуга, "Услуга");
//			If vNewServicesRow = Неопределено Тогда
//				Return True;
//			ElsIf vOldServicesRow.Сумма <> vNewServicesRow.Сумма Or 
//				  vOldServicesRow.СуммаНДС <> vNewServicesRow.СуммаНДС Or 
//				  vOldServicesRow.СуммаКомиссии <> vNewServicesRow.СуммаКомиссии Or 
//				  vOldServicesRow.СуммаСкидки <> vNewServicesRow.СуммаСкидки Or 
//				  vOldServicesRow.Количество <> vNewServicesRow.Количество Тогда
//				Return True;
//			EndIf;
//		EndDo;
//	EndIf;
//	Return False;
//EndFunction //ServicesHasChanged
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
//			
//			Message(NStr(vMessage), MessageStatus.Attention);
//			ВызватьИсключение NStr(vMessage);
//		EndIf;
//		If НЕ Ref.Posted Or 
//		   Ref.Гостиница <> Гостиница Or 
//		   Ref.Фирма <> Фирма Or 
//		   Ref.Контрагент <> AccountingCustomer Or 
//		   Ref.Договор <> AccountingContract Or 
//		   Ref.ГруппаГостей <> GuestGroup Or 
//		   Ref.ВалютаРасчетов <> AccountingCurrency Or 
//		   ServicesHasChanged() Тогда
//			ChangeAuthor = ПараметрыСеанса.ТекПользователь;
//			ChangeDate = CurrentDate();
//		EndIf;
//	Else
//		If Ref.Posted And (pWriteMode = DocumentWriteMode.UndoPosting Or DeletionMark) Тогда
//			ChangeAuthor = ПараметрыСеанса.ТекПользователь;
//			ChangeDate = CurrentDate();
//		EndIf;
//	EndIf;
//КонецПроцедуры //BeforeWrite
//
////-----------------------------------------------------------------------------
//Процедура OnSetNewNumber(pStandardProcessing, pPrefix)
//	vPrefix = "";
//	If ЗначениеЗаполнено(Фирма) And (Фирма.UsePrefixForInvoices Or Фирма.UseGroupCodeAsInvoiceNumberPrefix) Тогда
//		vPrefixLen = 0;
//		If Фирма.UsePrefixForInvoices Тогда
//			vPrefix = TrimAll(Фирма.Prefix);
//			If НЕ IsBlankString(vPrefix) Тогда
//				vPrefixLen = StrLen(vPrefix) + 1;
//			EndIf;
//		EndIf;
//		If Фирма.UseGroupCodeAsInvoiceNumberPrefix And ЗначениеЗаполнено(GuestGroup) Тогда
//			vGroupCode = Format(GuestGroup.Code, "ND=12; NFD=0; NG=");
//			If StrLen(vGroupCode) < 10 Тогда
//				vGroupCode = Format(GuestGroup.Code, "ND=" + Format((12 - 3 - vPrefixLen), "ND=1; NFD=0; NZ=") + "; NFD=0; NLZ=; NG=");
//			EndIf;
//			If НЕ IsBlankString(vPrefix) Тогда
//				vPrefix = vPrefix + "/" + vGroupCode + "/";
//			Else
//				vPrefix = vGroupCode + "/";
//			EndIf;
//		EndIf;
//	ElsIf ЗначениеЗаполнено(Гостиница) Тогда
//		vPrefix = TrimAll(Гостиница.GetObject().pmGetPrefix());
//	ElsIf ЗначениеЗаполнено(ПараметрыСеанса.ТекущаяГостиница) Тогда
//		If ЗначениеЗаполнено(ПараметрыСеанса.ТекущаяГостиница.Фирма) And ПараметрыСеанса.ТекущаяГостиница.Фирма.UsePrefixForInvoices Тогда
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
//Function pmGetInvoiceBalance(Val pDate = Неопределено) Экспорт
//	vBalance = 0;
//	If НЕ ЗначениеЗаполнено(pDate) Тогда
//		pDate = '39991231235959';
//	EndIf;
//	vQry = New Query();
//	vQry.Text = 
//	"SELECT
//	|	InvoiceAccountsBalance.Фирма,
//	|	InvoiceAccountsBalance.СчетНаОплату,
//	|	InvoiceAccountsBalance.Гостиница,
//	|	InvoiceAccountsBalance.SumBalance AS Balance
//	|FROM
//	|	AccumulationRegister.ВзаиморасчетыПоСчетам.Balance(
//	|		&qPeriod,
//	|		СчетНаОплату = &qInvoice) AS InvoiceAccountsBalance";
//	vQry.SetParameter("qPeriod", pDate);
//	vQry.SetParameter("qInvoice", Ref);
//	vRes = vQry.Execute().Unload();
//	For Each vRow In vRes Do
//		vBalance = vBalance + vRow.Balance;
//	EndDo;
//	Return vBalance;
//EndFunction //pmGetInvoiceBalance
//
////-----------------------------------------------------------------------------
//Процедура pmPrintInvoice(vSpreadsheet, SelLanguage, SelGroupBy, SelObjectPrintForm, mInvoiceNumber) Экспорт
//	SelInvoice = ThisObject;
//	If ЗначениеЗаполнено(SelObjectPrintForm) AND NOT IsBlankString(SelObjectPrintForm.Parameter) Тогда
//		SelGroupBy = TrimAll(SelObjectPrintForm.Parameter);
//	EndIf;
//	// Basic checks
//	vHotel = SelInvoice.Гостиница;
//	If НЕ ЗначениеЗаполнено(vHotel) Тогда
//		ВызватьИсключение NStr("ru='Не задана гостиница!';de='Das Гостиница ist nicht angegeben!';en='Гостиница should be filled!'");
//		Return;
//	EndIf;
//	vCompany = SelInvoice.Фирма;
//	If НЕ ЗначениеЗаполнено(vCompany) Тогда
//		ВызватьИсключение NStr("ru='Не задана фирма!';de='Die Firma ist nicht angegeben!';en='Фирма should be filled!'");
//		Return;
//	EndIf;
//	vAccount = SelInvoice.BankAccount;
//	If НЕ ЗначениеЗаполнено(vAccount) Тогда
//		ВызватьИсключение NStr("ru='Не задан расчетный счет фирмы!';de='Das Verrechnungskonto der Firma ist nicht angegeben!';en='Фирма account should be filled!'");
//		Return;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(SelLanguage) Тогда
//		SelLanguage = ПараметрыСеанса.ТекЛокализация;
//	EndIf;
//	
//	// Choose template
//	vSpreadsheet.Clear();
//	If ЗначениеЗаполнено(SelLanguage) Тогда
//		If SelLanguage = Справочники.Локализация.EN Тогда
//			vTemplate = SelInvoice.GetTemplate("InvoiceDetailedEn");
//			If НЕ IsBlankString(SelGroupBy) Тогда
//				If SelGroupBy = "InPricePerClient" Or SelGroupBy = "InPrice" Or SelGroupBy = "AllPerClient" Or SelGroupBy = "All" Or SelGroupBy = "PerClient" Or SelGroupBy = "ByService" Тогда
//					vTemplate = SelInvoice.GetTemplate("InvoiceShortEn");
//				EndIf;
//			EndIf;
//		ElsIf SelLanguage = Справочники.Локализация.DE Тогда
//			vTemplate = SelInvoice.GetTemplate("InvoiceDetailedDe");
//			If НЕ IsBlankString(SelGroupBy) Тогда
//				If SelGroupBy = "InPricePerClient" Or SelGroupBy = "InPrice" Or SelGroupBy = "AllPerClient" Or SelGroupBy = "All" Or SelGroupBy = "PerClient" Or SelGroupBy = "ByService" Тогда
//					vTemplate = SelInvoice.GetTemplate("InvoiceShortDe");
//				EndIf;
//			EndIf;
//		ElsIf SelLanguage = Справочники.Локализация.RU Тогда
//			vTemplate = SelInvoice.GetTemplate("InvoiceDetailedRu");
//			If НЕ IsBlankString(SelGroupBy) Тогда
//				If SelGroupBy = "InPricePerClient" Or SelGroupBy = "InPrice" Or SelGroupBy = "AllPerClient" Or SelGroupBy = "All" Or SelGroupBy = "PerClient" Or SelGroupBy = "ByService" Тогда
//					vTemplate = SelInvoice.GetTemplate("InvoiceShortRu");
//				EndIf;
//			EndIf;
//		Else
//			ВызватьИсключение NStr("ru='Не найден шаблон печатной формы счета для языка " + SelLanguage.Code + "!'; 
//			           |de='No invoice print form template found for the " + SelLanguage.Code + " language!'; 
//			           |en='No invoice print form template found for the " + SelLanguage.Code + " language!'");
//			Return;
//		EndIf;
//	Else
//		vTemplate = SelInvoice.GetTemplate("InvoiceDetailedRu");
//		If НЕ IsBlankString(SelGroupBy) Тогда
//			If SelGroupBy = "InPricePerClient" Or SelGroupBy = "InPrice" Or SelGroupBy = "AllPerClient" Or SelGroupBy = "All" Or SelGroupBy = "PerClient" Or SelGroupBy = "ByService" Тогда
//				vTemplate = SelInvoice.GetTemplate("InvoiceShortRu");
//			EndIf;
//		EndIf;
//	EndIf;
//	// Load external template if any
//	vExtTemplate = cmReadExternalSpreadsheetDocumentTemplate(SelObjectPrintForm);
//	If vExtTemplate <> Неопределено Тогда
//		vTemplate = vExtTemplate;
//	EndIf;
//	
//	// Print form parameter
//	vParameter = Upper(TrimAll(SelObjectPrintForm.Parameter));
//	
//	// Load pictures
//	vLogoIsSet = False;
//	vLogo = New Picture;
//	If ЗначениеЗаполнено(SelInvoice.Гостиница) Тогда
//		If SelInvoice.Гостиница.Logo <> Неопределено Тогда
//			vLogo = SelInvoice.Гостиница.Logo.Get();
//			If vLogo = Неопределено Тогда
//				vLogo = New Picture;
//			Else
//				vLogoIsSet = True;
//			EndIf;
//		EndIf;
//	EndIf;
//	vStampIsSet = False;
//	vStamp = New Picture;
//	If ЗначениеЗаполнено(SelInvoice.Фирма) Тогда
//		If SelInvoice.Фирма.Stamp <> Неопределено Тогда
//			vStamp = SelInvoice.Фирма.Stamp.Get();
//			If vStamp = Неопределено Тогда
//				vStamp = New Picture;
//			Else
//				vStampIsSet = True;
//			EndIf;
//		EndIf;
//	EndIf;
//	vSignatureIsSet = False;
//	vSignature = New Picture;
//	If ЗначениеЗаполнено(ПараметрыСеанса.ТекПользователь) Тогда
//		If ПараметрыСеанса.ТекПользователь.Подпись <> Неопределено Тогда
//			vSignature = ПараметрыСеанса.ТекПользователь.Подпись.Get();
//			If vSignature = Неопределено Тогда
//				vSignature = New Picture;
//			Else
//				vSignatureIsSet = True;
//			EndIf;
//		EndIf;
//	EndIf;
//	vDirectorSignatureIsSet = False;
//	vDirectorSignature = New Picture;
//	If SelInvoice.Фирма.DirectorSignature <> Неопределено Тогда
//		vDirectorSignature = SelInvoice.Фирма.DirectorSignature.Get();
//		If vDirectorSignature = Неопределено Тогда
//			vDirectorSignature = New Picture;
//		Else
//			vDirectorSignatureIsSet = True;
//		EndIf;
//	EndIf;
//	vAccountantGeneralSignatureIsSet = False;
//	vAccountantGeneralSignature = New Picture;
//	If SelInvoice.Фирма.AccountantGeneralSignature <> Неопределено Тогда
//		vAccountantGeneralSignature = SelInvoice.Фирма.AccountantGeneralSignature.Get();
//		If vAccountantGeneralSignature = Неопределено Тогда
//			vAccountantGeneralSignature = New Picture;
//		Else
//			vAccountantGeneralSignatureIsSet = True;
//		EndIf;
//	EndIf;
//	
//	// Header
//	vRubHeader = False;
//	If SelInvoice.ВалютаРасчетов.Code = 643 And vHotel.Гражданство.Code = 643 Тогда
//		vRubHeader = True;
//	EndIf;
//	
//	// Гостиница
//	vHotelObj = vHotel.GetObject();
//	mHotelPrintName = vHotelObj.pmGetHotelPrintName(SelLanguage);
//	mHotelPostAddressPresentation = vHotelObj.pmGetHotelPostAddressPresentation(SelLanguage);
//	vHotelPhones = TrimAll(vHotel.Телефоны);
//	vHotelFax = TrimAll(vHotel.Fax);
//	mHotelPhones = vHotelPhones + ?(IsBlankString(vHotelFax), "",", факс " + vHotelFax);
//	mHotelEMail = TrimAll(vHotel.EMail);
//	
//	// Фирма
//	vCompanyObj = vCompany.GetObject();
//	vCompanyLegacyName = vCompanyObj.pmGetCompanyPrintName(SelLanguage);
//	vCompanyLegacyAddress = vCompanyObj.pmGetCompanyLegacyAddressPresentation(SelLanguage);
//	vCompanyPostAddress = vCompanyObj.pmGetCompanyPostAddressPresentation(SelLanguage);
//	If vCompanyPostAddress = vCompanyLegacyAddress Тогда
//		vCompanyPostAddress = "";
//	EndIf;
//	mCompanyTIN = TrimAll(vCompany.ИНН);
//	mCompanyKPP = TrimAll(vCompany.KPP);
//	vCompanyTIN = "ИНН '" + mCompanyTIN + ?(IsBlankString(mCompanyKPP), "", "/" + mCompanyKPP);
//	vCompanyPhones = TrimAll(vCompany.Телефоны) + ?(IsBlankString(vCompany.Fax), "",", факс '" + TrimAll(vCompany.Fax));
//	mCompany = TrimAll(vCompanyLegacyName + vCompanyTIN + Chars.LF + vCompanyLegacyAddress + Chars.LF + ?(IsBlankString(vCompanyPostAddress), "", vCompanyPostAddress + Chars.LF) + vCompanyPhones);
//	
//	// Invoice date and number
//	If vCompany.UseGroupCodeAsInvoiceNumberPrefix Тогда
//		If vCompany.PrintInvoiceAndSettlementNumbersWithPrefixes Тогда
//			vCompanyPrefix = TrimAll(vCompany.Prefix);
//			If НЕ IsBlankString(vCompanyPrefix) Тогда
//				mInvoiceNumber = vCompanyPrefix + cmRemoveLeadingZeroes(SelInvoice.НомерДока);
//			Else
//				mInvoiceNumber = cmRemoveLeadingZeroes(SelInvoice.НомерДока);
//			EndIf;
//		Else
//			vHotelPrefix = SelInvoice.Гостиница.GetObject().pmGetPrefix();
//			If НЕ IsBlankString(vHotelPrefix) And SelInvoice.Гостиница.ShowHotelPrefixBeforeGroupCode Тогда
//				mInvoiceNumber = vHotelPrefix + cmRemoveLeadingZeroes(SelInvoice.НомерДока);
//			Else
//				mInvoiceNumber = cmRemoveLeadingZeroes(SelInvoice.НомерДока);
//			EndIf;
//		EndIf;
//	Else
//		mInvoiceNumber = ?(vCompany.PrintInvoiceAndSettlementNumbersWithPrefixes, TrimAll(SelInvoice.НомерДока), cmGetDocumentNumberPresentation(SelInvoice.НомерДока));
//	EndIf;
//	mInvoiceDate = cmGetDocumentDatePresentation(SelInvoice.ДатаДок);
//	
//	vTableHeader = vTemplate.GetArea("TableHeader");
//	
//	// Print different invoice headers for invoices in RUR and Russia base country and other currencies/countries
//	If vRubHeader Тогда
//		vHeader = vTemplate.GetArea("Header");
//		
//		mCompanyPaymentAttributes = vCompanyLegacyName;
//		mCompanyBank = "";
//		mCompanyBankAcount = "";
//		mCompanyBankBIC = "";
//		mCompanyBankCorrAccount = "";
//		If vAccount.IsDirectPayments Тогда
//			mCompanyBank = TrimAll(vAccount.НазваниеБанка) + " " + TrimAll(vAccount.ГородБанка);
//			
//			mCompanyBankAccount = TrimAll(vAccount.НомерСчета);
//			mCompanyBankBIC = TrimAll(vAccount.БИКБанка);
//			mCompanyBankCorrAccount = TrimAll(vAccount.КорСчет);
//		Else
//			mCompanyPaymentAttributes = mCompanyPaymentAttributes + " р/с " + TrimAll(vAccount.НомерСчета);
//			mCompanyPaymentAttributes = mCompanyPaymentAttributes + " в " + TrimAll(vAccount.НазваниеБанка);
//			mCompanyPaymentAttributes = mCompanyPaymentAttributes + " " + TrimAll(vAccount.ГородБанка);
//		
//			mCompanyBank = TrimAll(vAccount.CorrBankName);
//			mCompanyBank = mCompanyBank + TrimAll(vAccount.CorrBankCity);
//			
//			mCompanyBankAccount = TrimAll(vAccount.КорСчет);
//			mCompanyBankBIC = TrimAll(vAccount.CorrBankBIC);
//			mCompanyBankCorrAccount = TrimAll(vAccount.CorrBankCorrAccountNumber);
//		EndIf;
//		If НЕ IsBlankString(vAccount.Получатель) Тогда
//			mCompanyPaymentAttributes = TrimAll(vAccount.Получатель);
//		EndIf;
//		// Контрагент
//		If SelInvoice.Контрагент = vHotel.IndividualsCustomer Тогда
//			// Use contact person as Контрагент
//			If НЕ IsBlankString(SelInvoice.КонтактноеЛицо) Тогда
//				mCustomer = TrimAll(SelInvoice.КонтактноеЛицо);
//			Else
//				vClientRef = Справочники.Клиенты.EmptyRef();
//				// Use guest group client as Контрагент
//				If ЗначениеЗаполнено(SelInvoice.ГруппаГостей) And ЗначениеЗаполнено(SelInvoice.ГруппаГостей.Клиент) Тогда
//					vClientRef = SelInvoice.ГруппаГостей.Клиент;
//				// Use first client as Контрагент
//				Else
//					For Each vRow In SelInvoice.Услуги Do
//						If ЗначениеЗаполнено(vRow.Клиент) Тогда
//							vClientRef = vRow.Клиент;
//							Break;
//						EndIf;
//					EndDo;
//				EndIf;
//				vCustomer = vClientRef;
//				vCustomerLegacyName = "";
//				vCustomerLegacyAddress = "";
//				vCustomerTIN = "";
//				vCustomerPhones = "";
//				If ЗначениеЗаполнено(vClientRef) Тогда
//					vCustomerLegacyName = TrimAll(vClientRef.FullName);
//					vCustomerLegacyAddress = cmGetAddressPresentation(vClientRef.Address);
//					vCustomerTIN = "";
//					vCustomerKPP = "";
//					// Fax and E-Mail
//					vCustomerPhones = TrimAll(vClientRef.Телефон);
//					vCustomerFax = TrimAll(vClientRef.Fax);
//					vCustomerPhones = vCustomerPhones + ?(IsBlankString(vCustomerFax), "",", факс '" + vCustomerFax);
//				EndIf;
//				mCustomer = TrimAll(vCustomerLegacyName + vCustomerTIN + Chars.LF + vCustomerLegacyAddress + Chars.LF + vCustomerPhones);
//			EndIf;
//			// Contract
//			mContract = "";
//		Else
//			vCustomer = SelInvoice.Контрагент;
//			vCustomerLegacyName = "";
//			vCustomerLegacyAddress = "";
//			vCustomerPostAddress = "";
//			vCustomerTIN = "";
//			vCustomerPhones = "";
//			If ЗначениеЗаполнено(vCustomer) Тогда
//				vCustomerLegacyName = TrimAll(vCustomer.ЮрИмя);
//				If IsBlankString(vCustomerLegacyName) Тогда
//					vCustomerLegacyName = TrimAll(vCustomer.Description);
//				EndIf;
//				vCustomerLegacyAddress = cmGetAddressPresentation(vCustomer.LegacyAddress);
//				vCustomerPostAddress = cmGetAddressPresentation(vCustomer.PostAddress);
//				If vCustomerPostAddress = vCustomerLegacyAddress Тогда
//					vCustomerPostAddress = "";
//				EndIf;
//				vCustomerTIN = TrimAll(vCustomer.ИНН);
//				vCustomerKPP = TrimAll(vCustomer.KPP);
//				vCustomerTIN = ", ИНН '" + vCustomerTIN + ?(IsBlankString(vCustomerKPP), "", "/" + vCustomerKPP);
//				// Fax and E-Mail
//				vCustomerPhones = TrimAll(vCustomer.Телефон);
//				vCustomerFax = TrimAll(vCustomer.Fax);
//				vCustomerPhones = vCustomerPhones + ?(IsBlankString(vCustomerFax), "", ", факс '" + vCustomerFax);
//			EndIf;
//			mCustomer = TrimAll(vCustomerLegacyName + vCustomerTIN + Chars.LF + vCustomerLegacyAddress + Chars.LF + ?(IsBlankString(vCustomerPostAddress), "", vCustomerPostAddress + Chars.LF) + vCustomerPhones);
//			// Contract
//			mContract = "";
//			If ЗначениеЗаполнено(SelInvoice.Договор) Тогда
//				mContract = TrimAll(SelInvoice.Договор.Description);
//			EndIf;
//		EndIf;
//		// Guest group code
//		mGuestGroup = "";
//		vHotelPrefix = SelInvoice.Гостиница.GetObject().pmGetPrefix();
//		If ЗначениеЗаполнено(SelInvoice.ГруппаГостей) Тогда
//			mGuestGroup = Format(SelInvoice.ГруппаГостей.Code, "ND=12; NFD=0; NG=");
//			If НЕ IsBlankString(SelInvoice.ГруппаГостей.Description) Тогда
//				mGuestGroup = mGuestGroup + " - " + TrimAll(SelInvoice.ГруппаГостей.Description);
//			EndIf;
//			If НЕ IsBlankString(vHotelPrefix) And SelInvoice.Гостиница.ShowHotelPrefixBeforeGroupCode Тогда
//				mGuestGroup = vHotelPrefix + mGuestGroup;
//			EndIf;
//		Else
//			vGroups = SelInvoice.Услуги.Unload(, "ГруппаГостей");
//			vGroups.GroupBy("ГруппаГостей", );
//			For Each vGroupsRow In vGroups Do
//				If ЗначениеЗаполнено(vGroupsRow.ГруппаГостей) Тогда
//					vGuestGroupCode = Format(vGroupsRow.ГруппаГостей.Code, "ND=12; NFD=0; NG=");
//					If НЕ IsBlankString(vHotelPrefix) And SelInvoice.Гостиница.ShowHotelPrefixBeforeGroupCode Тогда
//						vGuestGroupCode = vHotelPrefix + vGuestGroupCode;
//					EndIf;
//					If IsBlankString(mGuestGroup) Тогда
//						mGuestGroup = vGuestGroupCode;
//					Else
//						mGuestGroup = mGuestGroup + ", " + vGuestGroupCode;
//					EndIf;
//				EndIf;
//			EndDo;
//		EndIf;
//		// Currency
//		mAccountingCurrency = "";
//		If ЗначениеЗаполнено(SelInvoice.ВалютаРасчетов) Тогда
//			vCurrencyObj = SelInvoice.ВалютаРасчетов.GetObject();
//			mAccountingCurrency = vCurrencyObj.pmGetCurrencyDescription(SelLanguage);
//		EndIf;
//		// Parent document
//		mParentDoc = String(SelInvoice.ДокОснование);
//		mFullInvoiceNumber = Trimall(SelInvoice.НомерДока);
//		// Set parameters and put report section
//		vHeader.Parameters.mHotelPrintName = mHotelPrintName;
//		vHeader.Parameters.mHotelPostAddressPresentation = mHotelPostAddressPresentation;
//		vHeader.Parameters.mHotelPhones = mHotelPhones;
//		vHeader.Parameters.mHotelEMail = mHotelEMail;
//		vHeader.Parameters.mInvoiceNumber = mInvoiceNumber;
//		vHeader.Parameters.mFullInvoiceNumber = mFullInvoiceNumber;
//		vHeader.Parameters.mInvoiceDate = mInvoiceDate;
//		If SelInvoice.ВалютаРасчетов = vHotel.BaseCurrency Тогда
//			vHeader.Parameters.mCompany = mCompany;
//			vHeader.Parameters.mCompanyTIN = mCompanyTIN;
//			vHeader.Parameters.mCompanyKPP = mCompanyKPP;
//			vHeader.Parameters.mCompanyBankBIC = mCompanyBankBIC;
//			vHeader.Parameters.mCompanyBankCorrAccount = mCompanyBankCorrAccount;
//		EndIf;
//		vHeader.Parameters.mCompanyPaymentAttributes = mCompanyPaymentAttributes;
//		vHeader.Parameters.mCompanyBank = mCompanyBank;
//		vHeader.Parameters.mCompanyBankAccount = mCompanyBankAccount;
//		vHeader.Parameters.mCustomer = mCustomer;
//		vHeader.Parameters.mInvoiceEMail = TrimAll(SelInvoice.EMail);
//		vHeader.Parameters.mContract = mContract;
//		vHeader.Parameters.mGuestGroup = mGuestGroup;
//		vHeader.Parameters.mAccountingCurrency = mAccountingCurrency;
//		vHeader.Parameters.mParentDoc = mParentDoc;
//		// Logo
//		If vLogoIsSet Тогда
//			vHeader.Drawings.Logo.Print = True;
//			vHeader.Drawings.Logo.Picture = vLogo;
//		Else
//			vHeader.Drawings.Delete(vHeader.Drawings.Logo);
//		EndIf;
//		// Put header		
//		vSpreadsheet.Put(vHeader);
//		vSpreadsheet.Put(vTableHeader);
//	Else
//		vHeader1 = vTemplate.GetArea("HeaderCurrency1");
//		
//		If НЕ IsBlankString(vAccount.Получатель) Тогда
//			mCompany = TrimAll(vAccount.Получатель);
//		EndIf;
//		
//		mCompanyBank = TrimAll(TrimAll(vAccount.НазваниеБанка) + " " + TrimAll(vAccount.ГородБанка));
//		mCompanyBankAccount = TrimAll(vAccount.НомерСчета);
//		If НЕ IsBlankString(vAccount.БИКБанка) Тогда
//			mCompanyBank = mCompanyBank + Chars.LF + "БИК " + TrimAll(vAccount.БИКБанка);
//		EndIf;
//		If НЕ IsBlankString(vAccount.КорСчет) Тогда
//			mCompanyBank = mCompanyBank + Chars.LF + "Корр. сч. " + TrimAll(vAccount.КорСчет);
//		EndIf;
//		If НЕ IsBlankString(vAccount.ИННБанка) Тогда
//			mCompanyBank = mCompanyBank + Chars.LF + TrimAll(vAccount.ИННБанка);
//		EndIf;
//		If НЕ IsBlankString(vAccount.BankSWIFTCode) Тогда
//			mCompanyBank = mCompanyBank + Chars.LF +"SWIFT '"+ TrimAll(vAccount.BankSWIFTCode);
//		EndIf;
//		
//		// Set parameters and put report section
//		vHeader1.Parameters.mHotelPrintName = mHotelPrintName;
//		vHeader1.Parameters.mHotelPostAddressPresentation = mHotelPostAddressPresentation;
//		vHeader1.Parameters.mHotelPhones = mHotelPhones;
//		vHeader1.Parameters.mHotelEMail = mHotelEMail;
//		vHeader1.Parameters.mInvoiceNumber = mInvoiceNumber;
//		vHeader1.Parameters.mInvoiceDate = mInvoiceDate;
//		vHeader1.Parameters.mCompany = mCompany;
//		vHeader1.Parameters.mCompanyBankAccount = mCompanyBankAccount;
//		vHeader1.Parameters.mCompanyBank = mCompanyBank;
//		// Logo
//		If vLogoIsSet Тогда
//			vHeader1.Drawings.LogoCurrency.Print = True;
//			vHeader1.Drawings.LogoCurrency.Picture = vLogo;
//		Else
//			vHeader1.Drawings.Delete(vHeader1.Drawings.LogoCurrency);
//		EndIf;
//		// Put header1		
//		vSpreadsheet.Put(vHeader1);
//		
//		// Put correspondent bank header
//		If НЕ vAccount.IsDirectPayments Тогда
//			vCorrBankHeader = vTemplate.GetArea("CorrBank");
//			
//			mCompanyCorrBank = TrimAll(TrimAll(vAccount.CorrBankName) + " " + TrimAll(vAccount.CorrBankCity));
//			If НЕ IsBlankString(vAccount.CorrBankBIC) Тогда
//				mCompanyCorrBank = mCompanyCorrBank + Chars.LF + "БИК" + TrimAll(vAccount.CorrBankBIC);
//			EndIf;
//			If НЕ IsBlankString(vAccount.CorrBankCorrAccountNumber) Тогда
//				mCompanyCorrBank = mCompanyCorrBank + "Корр. сч. № " + TrimAll(vAccount.CorrBankCorrAccountNumber);
//			EndIf;
//			If НЕ IsBlankString(vAccount.CorrBankTINCode) Тогда
//				mCompanyCorrBank = mCompanyCorrBank + Chars.LF + TrimAll(vAccount.CorrBankTINCode);
//			EndIf;
//			If НЕ IsBlankString(vAccount.CorrBankSWIFTCode) Тогда
//				mCompanyCorrBank = mCompanyCorrBank + Chars.LF +"SWIFT ';RU='SWIFT '" + TrimAll(vAccount.CorrBankSWIFTCode);
//			EndIf;
//			
//			// Set parameters and put report section
//			vCorrBankHeader.Parameters.mCompanyCorrBank = mCompanyCorrBank;
//			
//			// Put corr. bank header
//			vSpreadsheet.Put(vCorrBankHeader);
//		EndIf;
//		
//		// Table header
//		vHeader2 = vTemplate.GetArea("HeaderCurrency2");
//		
//		// Контрагент
//		If SelInvoice.Контрагент = vHotel.IndividualsCustomer Тогда
//			// Use contact person as Контрагент
//			If НЕ IsBlankString(SelInvoice.КонтактноеЛицо) Тогда
//				mCustomer = TrimAll(SelInvoice.КонтактноеЛицо);
//			Else				
//				vClientRef = Справочники.Клиенты.EmptyRef();
//				// Use guest group client as Контрагент
//				If ЗначениеЗаполнено(SelInvoice.ГруппаГостей) And ЗначениеЗаполнено(SelInvoice.ГруппаГостей.Клиент) Тогда
//					vClientRef = SelInvoice.ГруппаГостей.Клиент;
//				// Use first client as Контрагент
//				Else
//					For Each vRow In SelInvoice.Услуги Do
//						If ЗначениеЗаполнено(vRow.Клиент) Тогда
//							vClientRef = vRow.Клиент;
//							Break;
//						EndIf;
//					EndDo;
//				EndIf;
//				vCustomer = vClientRef;
//				vCustomerLegacyName = "";
//				vCustomerLegacyAddress = "";
//				vCustomerTIN = "";
//				vCustomerPhones = "";
//				If ЗначениеЗаполнено(vClientRef) Тогда
//					vCustomerLegacyName = TrimAll(vClientRef.FullName);
//					vCustomerLegacyAddress = cmGetAddressPresentation(vClientRef.Address);
//					vCustomerTIN = "";
//					vCustomerKPP = "";
//					// Fax and E-Mail
//					vCustomerPhones = TrimAll(vClientRef.Телефон);
//					vCustomerFax = TrimAll(vClientRef.Fax);
//					vCustomerPhones = vCustomerPhones + ?(IsBlankString(vCustomerFax), "",", факс '" + vCustomerFax);
//				EndIf;
//				mCustomer = TrimAll(vCustomerLegacyName + vCustomerTIN + Chars.LF + vCustomerLegacyAddress + Chars.LF + vCustomerPhones);
//			EndIf;
//			// Contract
//			mContract = "";
//		Else
//			vCustomer = SelInvoice.Контрагент;
//			vCustomerLegacyName = "";
//			vCustomerLegacyAddress = "";
//			vCustomerPostAddress = "";
//			vCustomerTIN = "";
//			vCustomerPhones = "";
//			If ЗначениеЗаполнено(vCustomer) Тогда
//				vCustomerLegacyName = TrimAll(vCustomer.ЮрИмя);
//				If IsBlankString(vCustomerLegacyName) Тогда
//					vCustomerLegacyName = TrimAll(vCustomer.Description);
//				EndIf;
//				vCustomerLegacyAddress = cmGetAddressPresentation(vCustomer.LegacyAddress);
//				vCustomerPostAddress = cmGetAddressPresentation(vCustomer.PostAddress);
//				If vCustomerPostAddress = vCustomerLegacyAddress Тогда
//					vCustomerPostAddress = "";
//				EndIf;
//				vCustomerTIN = TrimAll(vCustomer.ИНН);
//				vCustomerKPP = TrimAll(vCustomer.KPP);
//				vCustomerTIN = "ИНН '" + vCustomerTIN + ?(IsBlankString(vCustomerKPP), "", "/" + vCustomerKPP);
//				// Fax and E-Mail
//				vCustomerPhones = TrimAll(vCustomer.Телефон);
//				vCustomerFax = TrimAll(vCustomer.Fax);
//				vCustomerPhones = vCustomerPhones + ?(IsBlankString(vCustomerFax), "", ", факс '" + vCustomerFax);
//			EndIf;
//			mCustomer = TrimAll(vCustomerLegacyName + vCustomerTIN + Chars.LF + vCustomerLegacyAddress + Chars.LF + ?(IsBlankString(vCustomerPostAddress), "", vCustomerPostAddress + Chars.LF) + vCustomerPhones);
//			// Contract
//			mContract = "";
//			If ЗначениеЗаполнено(SelInvoice.Договор) Тогда
//				mContract = TrimAll(SelInvoice.Договор.Description);
//			EndIf;
//		EndIf;
//		// Guest group code
//		mGuestGroup = "";
//		If ЗначениеЗаполнено(SelInvoice.ГруппаГостей) Тогда
//			mGuestGroup = Format(SelInvoice.ГруппаГостей.Code, "ND=12; NFD=0; NG=");
//			If НЕ IsBlankString(SelInvoice.ГруппаГостей.Description) Тогда
//				mGuestGroup = mGuestGroup + " - " + TrimAll(SelInvoice.ГруппаГостей.Description);
//			EndIf;
//		Else
//			vGroups = SelInvoice.Услуги.Unload(, "ГруппаГостей");
//			vGroups.GroupBy("ГруппаГостей", );
//			For Each vGroupsRow In vGroups Do
//				If ЗначениеЗаполнено(vGroupsRow.ГруппаГостей) Тогда
//					vGuestGroupCode = Format(vGroupsRow.ГруппаГостей.Code, "ND=12; NFD=0; NG=");
//					If IsBlankString(mGuestGroup) Тогда
//						mGuestGroup = vGuestGroupCode;
//					Else
//						mGuestGroup = mGuestGroup + ", " + vGuestGroupCode;
//					EndIf;
//				EndIf;
//			EndDo;
//		EndIf;
//		// Currency
//		mAccountingCurrency = "";
//		If ЗначениеЗаполнено(SelInvoice.ВалютаРасчетов) Тогда
//			vCurrencyObj = SelInvoice.ВалютаРасчетов.GetObject();
//			mAccountingCurrency = vCurrencyObj.pmGetCurrencyDescription(SelLanguage);
//		EndIf;
//		// Parent document
//		mParentDoc = String(SelInvoice.ДокОснование);
//		mFullInvoiceNumber = Trimall(SelInvoice.НомерДока);
//		// Set parameters and put report section
//		vHeader2.Parameters.mFullInvoiceNumber = mFullInvoiceNumber;
//		vHeader2.Parameters.mCustomer = mCustomer;
//		vHeader2.Parameters.mInvoiceEMail = TrimAll(SelInvoice.EMail);
//		vHeader2.Parameters.mContract = mContract;
//		vHeader2.Parameters.mGuestGroup = mGuestGroup;
//		vHeader2.Parameters.mAccountingCurrency = mAccountingCurrency;
//		vHeader2.Parameters.mParentDoc = mParentDoc;
//		// Put header		
//		vSpreadsheet.Put(vHeader2);
//		vSpreadsheet.Put(vTableHeader);
//	EndIf;
//	
//	// Get template areas
//	vClient = vTemplate.GetArea("Клиент");
//	vRow = vTemplate.GetArea("Row");
//	
//	// Get all services
//	vServices = SelInvoice.Услуги.Unload();
//	
//	// Calculate totals
//	vAgentCommission = 0;
//	vTotalSum = 0;
//	vTotalSumNoCommission = 0;
//	vTotalCommissionSum = 0;
//	vTotalVATSumNoCommission = 0;
//	vTotalVATSum = 0;
//	
//	vVATRateTransactions = vServices.Copy();
//	vVATRateTransactions.GroupBy("СтавкаНДС", "Сумма, СуммаНДС");
//	vVATRateTransactions.Clear();
//	
//	vUseSectionVAT = False;
//	For Each vSrvRow In vServices Do
//		If vAgentCommission = 0 Тогда
//			vAgentCommission = vSrvRow.КомиссияАгента;
//		EndIf;
//		vTotalSum = vTotalSum + vSrvRow.Сумма;
//		vTotalSumNoCommission = vTotalSumNoCommission + vSrvRow.Сумма - vSrvRow.СуммаКомиссии;
//		vTotalCommissionSum = vTotalCommissionSum + vSrvRow.СуммаКомиссии;
//		
//		// Get effective VAT rate
//		vVATRate = vSrvRow.СтавкаНДС;
//		If ЗначениеЗаполнено(vSrvRow.Услуга) And ЗначениеЗаполнено(vSrvRow.Услуга.PaymentSection) And ЗначениеЗаполнено(vSrvRow.Услуга.PaymentSection.СтавкаНДС) And 
//		   vSrvRow.СтавкаНДС <> vSrvRow.Услуга.PaymentSection.СтавкаНДС Тогда
//			vVATRate = vSrvRow.Услуга.PaymentSection.СтавкаНДС;
//			vUseSectionVAT = True;
//		EndIf;
//		
//		vTotalVATSumNoCommission = vTotalVATSumNoCommission + cmCalculateVATSum(vVATRate, (vSrvRow.Сумма - vSrvRow.СуммаКомиссии));
//		vTotalVATSum = vTotalVatSum + cmCalculateVATSum(vVATRate, vSrvRow.Сумма);
//		
//		vVATRateTransactionsRow = vVATRateTransactions.Add();
//		vVATRateTransactionsRow.СтавкаНДС = vVATRate;
//		vVATRateTransactionsRow.СуммаНДС = cmCalculateVATSum(vVATRate, vSrvRow.Сумма);
//		vVATRateTransactionsRow.Сумма = vSrvRow.Сумма;
//	EndDo;
//	
//	// Change accounting dates for breakfast
//	If НЕ IsBlankString(SelGroupBy) And SelGroupBy <> "ByService" Тогда
//		If vServices.Find(True, "IsRoomRevenue") <> Неопределено Тогда
//			For Each vSrvRow In vServices Do
//				If vSrvRow.IsInPrice And ЗначениеЗаполнено(vSrvRow.Услуга.QuantityCalculationRule) And
//				   vSrvRow.Услуга.QuantityCalculationRule.QuantityCalculationRuleType = Перечисления.QuantityCalculationRuleTypes.Breakfast Тогда
//					If BegOfDay(vSrvRow.УчетнаяДата) > BegOfDay(vSrvRow.DateTimeFrom) Тогда
//						vSrvRow.УчетнаяДата = vSrvRow.УчетнаяДата - 24*3600;
//					EndIf;
//				EndIf;
//			EndDo;
//		EndIf;
//	EndIf;
//	
//	// Join services according to service parameters
//	If НЕ IsBlankString(SelGroupBy) And SelGroupBy <> "ByService" Тогда
//		i = 0;
//		While i < vServices.Count() Do
//			vSrvRow = vServices.Get(i);
//			If НЕ vSrvRow.IsInPrice And ЗначениеЗаполнено(vSrvRow.Услуга.HideIntoServiceOnPrint) Тогда
//				// Try to find service to hide current one to
//				vHideToServices = vServices.FindRows(New Structure("Услуга, УчетнаяДата, Клиент, ТипНомера, НомерРазмещения, Ресурс", vSrvRow.Услуга.HideIntoServiceOnPrint, vSrvRow.УчетнаяДата, vSrvRow.Клиент, vSrvRow.ТипНомера, vSrvRow.НомерРазмещения, vSrvRow.Ресурс));
//				If vHideToServices.Count() = 1 Тогда
//					vSrv2Hide2 = vHideToServices.Get(0);
//					vSrv2Hide2.Сумма = vSrv2Hide2.Сумма + vSrvRow.Сумма;
//					vSrv2Hide2.СуммаНДС = vSrv2Hide2.СуммаНДС + vSrvRow.СуммаНДС;
//					vSrv2Hide2.СуммаСкидки = vSrv2Hide2.СуммаСкидки + vSrvRow.СуммаСкидки;
//					vSrv2Hide2.Цена = cmRecalculatePrice(vSrv2Hide2.Сумма, vSrv2Hide2.Количество);
//					// Delete current service
//					vServices.Delete(i);
//					Continue;
//				EndIf;
//			EndIf;
//			i = i + 1;
//		EndDo;
//	EndIf;
//	
//	// Get accommodation service name
//	vAccommodationService = Неопределено;	
//	vAccommodationRemarks = "";	
//	vAccommodationServiceVATRate = Неопределено;
//	i = 0;
//	While i < vServices.Count() Do
//		vSrvRow = vServices.Get(i);
//		If SelGroupBy = "InPricePerClientPerDay" Or SelGroupBy = "InPricePerDay" Or
//		   SelGroupBy = "AllPerClientPerDay" Or SelGroupBy = "AllPerDay" Or
//		   SelGroupBy = "InPricePerClient" Or SelGroupBy = "InPrice" Or
//		   SelGroupBy = "AllPerClient" Or SelGroupBy = "All" Тогда
//			If vSrvRow.Сумма = 0 Тогда
//				vServices.Delete(i);
//				Continue;
//			EndIf;
//		EndIf;
//		If vAccommodationService = Неопределено And vSrvRow.IsRoomRevenue And НЕ vSrvRow.Услуга.RoomRevenueAmountsOnly Тогда
//			vAccommodationService = vSrvRow.Услуга;
//			vAccommodationServiceVATRate = vSrvRow.СтавкаНДС;
//			vAccommodationRemarks = TrimAll(vSrvRow.Примечания);
//			If SelGroupBy = "InPricePerClientPerDay" Or SelGroupBy = "InPricePerDay" Or
//			   SelGroupBy = "AllPerClientPerDay" Or SelGroupBy = "AllPerDay" Or
//			   SelGroupBy = "InPricePerClient" Or SelGroupBy = "InPrice" Or
//			   SelGroupBy = "AllPerClient" Or SelGroupBy = "All" Тогда
//				If ЗначениеЗаполнено(vAccommodationService) Тогда
//					vSrvDescr = vAccommodationService.GetObject().pmGetServiceDescription(SelLanguage, False);
//					vSrvGrpDescr = vAccommodationService.GetObject().pmGetServiceDescription(SelLanguage, True);
//					vAccommodationRemarks = StrReplace(vAccommodationRemarks, vSrvDescr, vSrvGrpDescr);
//				EndIf;
//			EndIf;
//		EndIf;
//		i = i + 1;
//	EndDo;
//	
//	// Group by services according to the invoice print type
//	If НЕ IsBlankString(SelGroupBy) Тогда
//		If SelGroupBy = "InPricePerClientPerDay" Or SelGroupBy = "InPricePerDay" Тогда
//			For Each vSrvRow In vServices Do
//				// Reset "is in price" flag if necessary
//				If ЗначениеЗаполнено(vSrvRow.Услуга) And vSrvRow.Услуга.DoNotGroupIntoRoomRateOnPrint Тогда
//					vSrvRow.IsInPrice = False;
//				EndIf;
//				vSrvRow.УчетнаяДата = BegOfDay(vSrvRow.УчетнаяДата);
//				If SelGroupBy = "InPricePerDay" Тогда
//					vSrvRow.Клиент = Справочники.Клиенты.EmptyRef();
//					vSrvRow.КоличествоЧеловек = 0;
//					vSrvRow.ВидРазмещения = Справочники.ВидыРазмещения.EmptyRef();
//					vSrvRow.ТипНомера = Справочники.ТипыНомеров.EmptyRef();
//					vSrvRow.НомерРазмещения = Справочники.НомернойФонд.EmptyRef();
//					vSrvRow.ТипДняКалендаря = Справочники.ТипДневногоКалендаря.EmptyRef();
//					vSrvRow.DateTimeFrom = Неопределено;
//					vSrvRow.DateTimeTo = Неопределено;
//				EndIf;
//				If ЗначениеЗаполнено(vAccommodationService) And vAccommodationServiceVATRate = vSrvRow.СтавкаНДС Тогда
//					If НЕ vSrvRow.IsRoomRevenue And vSrvRow.IsInPrice Тогда
//						vSrvRow.Услуга = ?(ЗначениеЗаполнено(vAccommodationService), vAccommodationService, vSrvRow.Услуга);
//						vSrvRow.Примечания = ?(IsBlankString(vAccommodationRemarks), TrimAll(vSrvRow.Примечания), vAccommodationRemarks);
//						vSrvRow.Количество = ?(IsBlankString(vAccommodationRemarks), vSrvRow.Количество, 0);
//						vSrvRow.Цена = 0;
//						vSrvRow.RoomQuantity = 0;
//					ElsIf vSrvRow.IsRoomRevenue And vSrvRow.IsInPrice Тогда
//						If vSrvRow.Услуга.RoomRevenueAmountsOnly Тогда
//							vSrvRow.Количество = 0;
//							vSrvRow.RoomQuantity = 0;
//						EndIf;
//						vSrvRow.Услуга = ?(ЗначениеЗаполнено(vAccommodationService), vAccommodationService, vSrvRow.Услуга);
//						vSrvRow.Примечания = ?(IsBlankString(vAccommodationRemarks), TrimAll(vSrvRow.Примечания), vAccommodationRemarks);
//					EndIf;
//				EndIf;
//			EndDo;
//		ElsIf SelGroupBy = "AllPerClientPerDay" Or SelGroupBy = "AllPerDay" Тогда
//			For Each vSrvRow In vServices Do
//				vSrvRow.УчетнаяДата = BegOfDay(vSrvRow.УчетнаяДата);
//				If SelGroupBy = "AllPerDay" Тогда
//					vSrvRow.Клиент = Справочники.Клиенты.EmptyRef();
//					vSrvRow.КоличествоЧеловек = 0;
//					vSrvRow.ВидРазмещения = Справочники.ВидыРазмещения.EmptyRef();
//					vSrvRow.ТипНомера = Справочники.ТипыНомеров.EmptyRef();
//					vSrvRow.НомерРазмещения = Справочники.НомернойФонд.EmptyRef();
//					vSrvRow.ТипДняКалендаря = Справочники.ТипДневногоКалендаря.EmptyRef();
//					vSrvRow.DateTimeFrom = Неопределено;
//					vSrvRow.DateTimeTo = Неопределено;
//				EndIf;
//				If ЗначениеЗаполнено(vAccommodationService) And vAccommodationServiceVATRate = vSrvRow.СтавкаНДС Тогда
//					If НЕ vSrvRow.IsRoomRevenue Тогда
//						vSrvRow.Услуга = ?(ЗначениеЗаполнено(vAccommodationService), vAccommodationService, vSrvRow.Услуга);
//						vSrvRow.Примечания = ?(IsBlankString(vAccommodationRemarks), TrimAll(vSrvRow.Примечания), vAccommodationRemarks);
//						vSrvRow.Количество = ?(IsBlankString(vAccommodationRemarks), vSrvRow.Количество, 0);
//						vSrvRow.Цена = 0;
//						vSrvRow.RoomQuantity = 0;
//					Else
//						If vSrvRow.Услуга.RoomRevenueAmountsOnly Тогда
//							vSrvRow.Количество = 0;
//							vSrvRow.RoomQuantity = 0;
//						EndIf;
//						vSrvRow.Услуга = ?(ЗначениеЗаполнено(vAccommodationService), vAccommodationService, vSrvRow.Услуга);
//						vSrvRow.Примечания = ?(IsBlankString(vAccommodationRemarks), TrimAll(vSrvRow.Примечания), vAccommodationRemarks);
//					EndIf;
//				EndIf;
//			EndDo;
//		ElsIf SelGroupBy = "PerClient" Тогда
//			For Each vSrvRow In vServices Do
//				vSrvRow.УчетнаяДата = BegOfDay(SelInvoice.ДатаДок);
//				If НЕ vSrvRow.IsRoomRevenue Тогда
//					vSrvRow.RoomQuantity = 0;
//				Else
//					If vSrvRow.Услуга.RoomRevenueAmountsOnly Тогда
//						vSrvRow.RoomQuantity = 0;
//					EndIf;
//				EndIf;
//			EndDo;
//		ElsIf SelGroupBy = "ByService" Тогда
//			For Each vSrvRow In vServices Do
//				vSrvRow.УчетнаяДата = BegOfDay(SelInvoice.ДатаДок);
//				vSrvRow.Клиент = Справочники.Клиенты.EmptyRef();
//				vSrvRow.КоличествоЧеловек = 0;
//				vSrvRow.ВидРазмещения = Справочники.ВидыРазмещения.EmptyRef();
//				vSrvRow.ТипНомера = Справочники.ТипыНомеров.EmptyRef();
//				vSrvRow.НомерРазмещения = Справочники.НомернойФонд.EmptyRef();
//				vSrvRow.Ресурс = Справочники.Ресурсы.EmptyRef();
//				vSrvRow.ТипДняКалендаря = Справочники.ТипДневногоКалендаря.EmptyRef();
//				vSrvRow.DateTimeFrom = Неопределено;
//				vSrvRow.DateTimeTo = Неопределено;
//				If НЕ vSrvRow.IsRoomRevenue Тогда
//					vSrvRow.RoomQuantity = 0;
//				Else
//					If vSrvRow.Услуга.RoomRevenueAmountsOnly Тогда
//						vSrvRow.RoomQuantity = 0;
//					EndIf;
//				EndIf;
//			EndDo;
//		ElsIf SelGroupBy = "InPricePerClient" Or SelGroupBy = "InPrice" Тогда
//			For Each vSrvRow In vServices Do
//				// Reset "is in price" flag if necessary
//				If ЗначениеЗаполнено(vSrvRow.Услуга) And vSrvRow.Услуга.DoNotGroupIntoRoomRateOnPrint Тогда
//					vSrvRow.IsInPrice = False;
//				EndIf;
//				vSrvRow.УчетнаяДата = BegOfDay(SelInvoice.ДатаДок);
//				If SelGroupBy = "InPrice" Тогда
//					vSrvRow.Клиент = Справочники.Клиенты.EmptyRef();
//					vSrvRow.КоличествоЧеловек = 0;
//					//vSrvRow.AccommodationType = Справочники.AccommodationTypes.EmptyRef();
//					//vSrvRow.RoomType = Справочники.RoomTypes.EmptyRef();
//					vSrvRow.НомерРазмещения = Справочники.НомернойФонд.EmptyRef();
//					vSrvRow.DateTimeFrom = Неопределено;
//					vSrvRow.DateTimeTo = Неопределено;
//				EndIf;
//				If ЗначениеЗаполнено(vAccommodationService) And vAccommodationServiceVATRate = vSrvRow.СтавкаНДС Тогда
//					If НЕ vSrvRow.IsRoomRevenue And vSrvRow.IsInPrice Тогда
//						vSrvRow.Услуга = ?(ЗначениеЗаполнено(vAccommodationService), vAccommodationService, vSrvRow.Услуга);
//						vSrvRow.Примечания = ?(IsBlankString(vAccommodationRemarks), TrimAll(vSrvRow.Примечания), vAccommodationRemarks);
//						vSrvRow.Количество = ?(IsBlankString(vAccommodationRemarks), vSrvRow.Количество, 0);
//						vSrvRow.Цена = 0;
//						vSrvRow.RoomQuantity = 0;
//					ElsIf vSrvRow.IsRoomRevenue And vSrvRow.IsInPrice Тогда
//						If vSrvRow.Услуга.RoomRevenueAmountsOnly Тогда
//							vSrvRow.RoomQuantity = 0;
//							vSrvRow.Количество = 0;
//						EndIf;
//						vSrvRow.Услуга = ?(ЗначениеЗаполнено(vAccommodationService), vAccommodationService, vSrvRow.Услуга);
//						vSrvRow.Примечания = ?(IsBlankString(vAccommodationRemarks), TrimAll(vSrvRow.Примечания), vAccommodationRemarks);
//					EndIf;
//				EndIf;
//			EndDo;
//		ElsIf SelGroupBy = "AllPerClient" Or SelGroupBy = "All" Тогда
//			For Each vSrvRow In vServices Do
//				vSrvRow.УчетнаяДата = BegOfDay(SelInvoice.ДатаДок);
//				vSrvRow.ТипДняКалендаря = Справочники.ТипДневногоКалендаря.EmptyRef();
//				vSrvRow.ВидРазмещения = Справочники.ВидыРазмещения.EmptyRef();
//				vSrvRow.ТипНомера = Справочники.ТипыНомеров.EmptyRef();
//				If SelGroupBy = "All" Тогда
//					vSrvRow.Клиент = Справочники.Клиенты.EmptyRef();
//					vSrvRow.КоличествоЧеловек = 0;
//					vSrvRow.НомерРазмещения = Справочники.НомернойФонд.EmptyRef();
//					vSrvRow.DateTimeFrom = Неопределено;
//					vSrvRow.DateTimeTo = Неопределено;
//				EndIf;
//				If ЗначениеЗаполнено(vAccommodationService) And vAccommodationServiceVATRate = vSrvRow.СтавкаНДС Тогда
//					If НЕ vSrvRow.IsRoomRevenue Тогда
//						vSrvRow.Услуга = ?(ЗначениеЗаполнено(vAccommodationService), vAccommodationService, vSrvRow.Услуга);
//						vSrvRow.Примечания = ?(IsBlankString(vAccommodationRemarks), TrimAll(vSrvRow.Примечания), vAccommodationRemarks);
//						vSrvRow.Количество = ?(IsBlankString(vAccommodationRemarks), vSrvRow.Количество, 0);
//						vSrvRow.Цена = 0;
//						vSrvRow.RoomQuantity = 0;
//					Else
//						If vSrvRow.Услуга.RoomRevenueAmountsOnly Тогда
//							vSrvRow.RoomQuantity = 0;
//							vSrvRow.Количество = 0;
//						EndIf;
//						vSrvRow.Услуга = ?(ЗначениеЗаполнено(vAccommodationService), vAccommodationService, vSrvRow.Услуга);
//						vSrvRow.Примечания = ?(IsBlankString(vAccommodationRemarks), TrimAll(vSrvRow.Примечания), vAccommodationRemarks);
//					EndIf;
//				EndIf;
//			EndDo;
//		EndIf;
//		// Group by transactions
//		vServices.GroupBy("Клиент, ВидРазмещения, ТипНомера, НомерРазмещения, Ресурс, DateTimeFrom, DateTimeTo, ТипДеньКалендарь, УчетнаяДата, Услуга, Примечания, СтавкаНДС, КомиссияАгента, ВидКомиссииАгента", "Сумма, СуммаНДС, Цена, Количество, RoomQuantity, КоличествоЧеловек, СуммаКомиссии, VATCommissionSum");
//		// Recalculate price for all services and delete zero sum rows
//		i = 0;
//		While i < vServices.Count() Do
//			vSrvRow = vServices.Get(i);
//			If vSrvRow.Сумма = 0 And SelGroupBy <> "ByService" Тогда
//				vServices.Delete(i);
//			Else
//				vSrvRow.СуммаНДС = cmCalculateVATSum(vSrvRow.СтавкаНДС, vSrvRow.Сумма);
//				vSrvRow.Цена = cmRecalculatePrice(vSrvRow.Сумма, vSrvRow.Количество);
//				i = i + 1;
//			EndIf;
//		EndDo;
//	EndIf;
//	vServices.Sort("НомерРазмещения, ТипНомера, Ресурс, Клиент, DateTimeFrom, УчетнаяДата");
//	
//	// Calculate totals
//	If НЕ vUseSectionVAT Тогда
//		vTotalVATSumNoCommission = 0;
//		vTotalVATSum = 0;
//		vVATRateTransactions.Clear();
//		For Each vSrvRow In vServices Do
//			vTotalVATSumNoCommission = vTotalVATSumNoCommission + cmCalculateVATSum(vSrvRow.СтавкаНДС, (vSrvRow.Сумма - vSrvRow.СуммаКомиссии));
//			vTotalVATSum = vTotalVatSum + cmCalculateVATSum(vSrvRow.СтавкаНДС, vSrvRow.Сумма);
//			
//			vVATRateTransactionsRow = vVATRateTransactions.Add();
//			vVATRateTransactionsRow.СтавкаНДС = vSrvRow.СтавкаНДС;
//			vVATRateTransactionsRow.СуммаНДС = cmCalculateVATSum(vSrvRow.СтавкаНДС, vSrvRow.Сумма);
//			vVATRateTransactionsRow.Сумма = vSrvRow.Сумма;
//		EndDo;
//	EndIf;
//	
//	// Build footer
//	vFooterAreas = new Array();
//	vFooter1 = vTemplate.GetArea("Footer1");
//	vCommission = vTemplate.GetArea("Комиссия");
//	vFooter2 = vTemplate.GetArea("Footer2");
//	// Fill parameters
//	mTotalSum = Format(vTotalSum, "ND=17; NFD=2") + " " + mAccountingCurrency;
//	If ЗначениеЗаполнено(vCompany) And vCompany.DoNotPrintVAT Тогда
//		mTotalVATSum = "";
//	Else
//		If vTotalVATSumNoCommission <> 0 And
//		   ЗначениеЗаполнено(SelInvoice.Контрагент) And НЕ SelInvoice.Контрагент.DoNotPostCommission Тогда
//			mTotalVATSum = "В том числе НДС " + Format(vTotalVATSumNoCommission, "ND=17; NFD=2") + " " + mAccountingCurrency;
//		ElsIf vTotalVATSum <> 0 And
//		      ЗначениеЗаполнено(SelInvoice.Контрагент) And SelInvoice.Контрагент.DoNotPostCommission Тогда
//			mTotalVATSum = "В том числе НДС " + Format(vTotalVATSum, "ND=17; NFD=2") + " " + mAccountingCurrency;
//		Else
//			If ЗначениеЗаполнено(SelInvoice.Фирма) And SelInvoice.Фирма.IsUsingSimpleTaxSystem Тогда
//				mTotalVATSum = "НДС не облагается в связи с применением упрощенной системы налогообложения (п. 2 ст. 346.11 НК РФ)";
//			Else
//				mTotalVATSum = "НДС не облагается";
//			EndIf;
//		EndIf;
//	EndIf;
//	If SelLanguage = Справочники.Локализация.DE Тогда
//		mTotalVATSum = "";
//	EndIf;
//	mTotalSumInWords = cmSumInWords(vTotalSum, SelInvoice.ВалютаРасчетов, SelLanguage);
//	// Set parameters
//	vFooter1.Parameters.mTotalSum = mTotalSum;
//	vFooter2.Parameters.mTotalVATSum = mTotalVATSum;
//	vFooter2.Parameters.mTotalSumInWords = mTotalSumInWords;
//	// Put footer
//	vFooterAreas.Add(vFooter1);
//	If vTotalCommissionSum <> 0 And 
//	   ЗначениеЗаполнено(SelInvoice.Контрагент) And НЕ SelInvoice.Контрагент.DoNotPostCommission Тогда
//		mTotalSumInWords = cmSumInWords(vTotalSumNoCommission, SelInvoice.ВалютаРасчетов, SelLanguage);
//		vFooter2.Parameters.mTotalSumInWords = mTotalSumInWords;
//		mSumToBePaid = Format(vTotalSumNoCommission, "ND=17; NFD=2") + " " + mAccountingCurrency;
//		mAgentCommission = vAgentCommission;
//		mTotalCommissionSum = Format(vTotalCommissionSum, "ND=17; NFD=2") + " " + mAccountingCurrency;
//		vCommission.Parameters.mTotalCommissionSum = mTotalCommissionSum;
//		vCommission.Parameters.mAgentCommission = mAgentCommission;
//		vCommission.Parameters.mSumToBePaid = mSumToBePaid;
//		vFooterAreas.Add(vCommission);
//	EndIf;
//	vFooterAreas.Add(vFooter2);
//	
//	// VAT rates table
//	vVATHeaderArea = vTemplate.GetArea("VATHeader");
//	vFooterAreas.Add(vVATHeaderArea);
//	vVATRateTransactions.GroupBy("СтавкаНДС", "Сумма, СуммаНДС");
//	vVATRateTransactions.Sort("СтавкаНДС");
//	For Each vVATRateRow In vVATRateTransactions Do
//		vVATRateRowArea = vTemplate.GetArea("VATRateRow");
//		vVATRateRowArea.Parameters.mVATRate = TrimAll(vVATRateRow.СтавкаНДС);
//		vVATRateRowArea.Parameters.mSumWithoutVAT = Format(vVATRateRow.Сумма - vVATRateRow.СуммаНДС, "ND=17; NFD=2; NZ=");
//		vVATRateRowArea.Parameters.mVATSum = Format(vVATRateRow.СуммаНДС, "ND=17; NFD=2; NZ=");
//		vVATRateRowArea.Parameters.mSumWithVAT = Format(vVATRateRow.Сумма, "ND=17; NFD=2; NZ=");
//		vFooterAreas.Add(vVATRateRowArea);
//	EndDo;
//	
//	// Signatures
//	vSignedByManager = False;
//	If ЗначениеЗаполнено(SelInvoice.Фирма) And SelInvoice.Фирма.InvoiceIsSignedByManager Тогда
//		vSignedByManager = True;
//	EndIf;
//	If НЕ vSignedByManager Тогда
//		If SelInvoice.PrintWithCompanyStamp Тогда
//			vSignatures = vTemplate.GetArea("SignaturesWithStamp");
//		Else
//			vSignatures = vTemplate.GetArea("Signatures");
//		EndIf;
//		mCompanyDirector = TrimAll(vCompany.Director);
//		If НЕ IsBlankString(vCompany.DirectorPosition) Тогда
//			mCompanyDirectorPosition = TrimAll(vCompany.DirectorPosition);
//		Else
//			mCompanyDirectorPosition = "Руководитель";
//		EndIf;
//		mCompanyAccountantGeneral = TrimAll(vCompany.AccountantGeneral);
//		If НЕ IsBlankString(vCompany.AccountantGeneralPosition) Тогда
//			mCompanyAccountantGeneralPosition = TrimAll(vCompany.AccountantGeneralPosition);
//		Else
//			mCompanyAccountantGeneralPosition = "Бухгалтер";
//		EndIf;
//		vSignatures.Parameters.mRemarks = TrimAll(SelInvoice.Примечания);
//		vSignatures.Parameters.mCompanyDirector = mCompanyDirector;
//		vSignatures.Parameters.mCompanyDirectorPosition = mCompanyDirectorPosition;
//		vSignatures.Parameters.mCompanyAccountantGeneral = mCompanyAccountantGeneral;
//		vSignatures.Parameters.mCompanyAccountantGeneralPosition = mCompanyAccountantGeneralPosition;
//		// Фирма stamp
//		If SelInvoice.PrintWithCompanyStamp Тогда
//			If vStampIsSet Тогда
//				vSignatures.Drawings.Stamp.Print = True;
//				vSignatures.Drawings.Stamp.Picture = vStamp;
//			Else
//				vSignatures.Drawings.Delete(vSignatures.Drawings.Stamp);
//			EndIf;
//			If vDirectorSignatureIsSet Тогда
//				vSignatures.Drawings.DirectorSignature.Print = True;
//				vSignatures.Drawings.DirectorSignature.Picture = vDirectorSignature;
//			Else
//				vSignatures.Drawings.Delete(vSignatures.Drawings.DirectorSignature);
//			EndIf;
//			If vAccountantGeneralSignatureIsSet Тогда
//				vSignatures.Drawings.AccountantGeneralSignature.Print = True;
//				vSignatures.Drawings.AccountantGeneralSignature.Picture = vAccountantGeneralSignature;
//			Else
//				vSignatures.Drawings.Delete(vSignatures.Drawings.AccountantGeneralSignature);
//			EndIf;
//		EndIf;
//		// Form text
//		vSignatures.Parameters.mFormText = TrimR(SelObjectPrintForm.FormText);
//		// Put signatures	
//		vFooterAreas.Add(vSignatures);
//	Else
//		If SelInvoice.PrintWithCompanyStamp Тогда
//			vSignatures = vTemplate.GetArea("ManagerSignatureWithStamp");
//		Else
//			vSignatures = vTemplate.GetArea("ManagerSignature");
//		EndIf;
//		mPosition = "Менеджер";
//		mEmployee = "";
//		If ЗначениеЗаполнено(ПараметрыСеанса.ТекПользователь) Тогда
//			If НЕ IsBlankString(ПараметрыСеанса.ТекПользователь.Должность) Тогда
//				mPosition = ПараметрыСеанса.ТекПользователь.Должность;
//			EndIf;
//		EndIf;
//		vSignatures.Parameters.mRemarks = TrimAll(SelInvoice.Примечания);
//		vSignatures.Parameters.mPosition = mPosition;
//		vSignatures.Parameters.mEmployee = mEmployee;
//		// Фирма stamp and manager's Подпись
//		If SelInvoice.PrintWithCompanyStamp Тогда
//			If vSignatureIsSet Тогда
//				vSignatures.Drawings.Подпись.Print = True;
//				vSignatures.Drawings.Подпись.Picture = vSignature;
//			Else
//				vSignatures.Drawings.Delete(vSignatures.Drawings.Подпись);
//			EndIf;
//			If vStampIsSet Тогда
//				vSignatures.Drawings.ManagerStamp.Print = True;
//				vSignatures.Drawings.ManagerStamp.Picture = vStamp;
//			Else
//				vSignatures.Drawings.Delete(vSignatures.Drawings.ManagerStamp);
//			EndIf;
//		EndIf;
//		// Form text
//		vSignatures.Parameters.mFormText = TrimR(SelObjectPrintForm.FormText);
//		// Put signatures	
//		vFooterAreas.Add(vSignatures);
//	EndIf;
//	
//	// Print services
//	vCurClient = Неопределено;
//	vCurNumberOfPersons = 0;
//	vCurAccommodationType = Неопределено;
//	vCurRoomType = Неопределено;
//	vCurRoom = Неопределено;
//	vCurResource = Неопределено;
//	vCurDateTimeFrom = Неопределено;
//	vCurDateTimeTo = Неопределено;
//	For Each vSrvRow In vServices Do
//		// Print client header if necessary
//		If (vSrvRow.Клиент <> vCurClient Or vSrvRow.КоличествоЧеловек <> vCurNumberOfPersons Or 
//		    vSrvRow.ВидРазмещения <> vCurAccommodationType Or vSrvRow.ТипНомера <> vCurRoomType Or
//		    vSrvRow.НомерРазмещения <> vCurRoom Or vSrvRow.Ресурс <> vCurResource Or
//		    vSrvRow.DateTimeFrom <> vCurDateTimeFrom Or vSrvRow.DateTimeTo <> vCurDateTimeTo) 
//		   And (Find(SelGroupBy, "PerClient") > 0 Or IsBlankString(SelGroupBy)) Тогда
//			vCurClient = vSrvRow.Клиент;
//			vCurNumberOfPersons = vSrvRow.КоличествоЧеловек;
//			vCurAccommodationType = vSrvRow.ВидРазмещения;
//			vCurRoomType = vSrvRow.ТипНомера;
//			vCurRoom = vSrvRow.НомерРазмещения;
//			vCurResource = vSrvRow.Ресурс;
//			vCurDateTimeFrom = vSrvRow.DateTimeFrom;
//			vCurDateTimeTo = vSrvRow.DateTimeTo;
//			// Fill client area parameters
//			mClient = "";
//			If ЗначениеЗаполнено(vCurClient) Тогда
//				mClient = TrimAll(TrimAll(vCurClient.Фамилия) + " " + TrimAll(vCurClient.Имя) + " " + TrimAll(vCurClient.Отчество));
//			EndIf;
//			vPeriodStr = "";
//			If BegOfDay(vSrvRow.DateTimeFrom) = BegOfDay(vSrvRow.DateTimeTo) Тогда
//				vPeriodStr = Format(vSrvRow.DateTimeFrom, "DF='dd.MM.yy'") + ", " + Format(vSrvRow.DateTimeFrom, "DF='HH:mm'") + " - " + Format(vSrvRow.DateTimeTo, "DF='HH:mm'");
//			Else
//				If Find(vParameter, "NO_TIME") > 0 Тогда
//					vPeriodStr = Format(vSrvRow.DateTimeFrom, "DF='dd.MM.yy'") + " - " + Format(vSrvRow.DateTimeTo, "DF='dd.MM.yy'");
//				Else
//					vPeriodStr = Format(vSrvRow.DateTimeFrom, "DF='dd.MM.yy HH:mm'") + " - " + Format(vSrvRow.DateTimeTo, "DF='dd.MM.yy HH:mm'");
//				EndIf;
//			EndIf;
//			vRStr = "";
//			If ЗначениеЗаполнено(vSrvRow.НомерРазмещения) And ЗначениеЗаполнено(vSrvRow.ТипНомера) And TypeOf(vSrvRow.НомерРазмещения) = Type("CatalogRef.НомернойФонд") Тогда
//				If Find(vParameter, "NO_ROOM") = 0 Тогда
//					vRStr = vRStr + TrimAll(vSrvRow.НомерРазмещения.Description) + " ";
//				EndIf;
//				If Find(vParameter, "NO_RTYPE") = 0 Тогда
//					vRStr = vRStr + vSrvRow.ТипНомера.GetObject().pmGetRoomTypeDescription(SelLanguage);
//				EndIf;
//			ElsIf ЗначениеЗаполнено(vSrvRow.ТипНомера) Тогда
//				If Find(vParameter, "NO_RTYPE") = 0 Тогда
//					vRStr = vSrvRow.ТипНомера.GetObject().pmGetRoomTypeDescription(SelLanguage);
//				EndIf;
//			ElsIf ЗначениеЗаполнено(vSrvRow.Ресурс) Тогда
//				If Find(vParameter, "NO_RESOURCE") = 0 Тогда
//					vRStr = vSrvRow.Ресурс.GetObject().pmGetResourceDescription(SelLanguage);
//				EndIf;
//			EndIf;
//			mClient = mClient + 
//			          ?(ЗначениеЗаполнено(vSrvRow.DateTimeFrom), ?(IsBlankString(mClient), "", ", ") + vPeriodStr, "") + 
//			          ?(IsBlankString(vRStr), "" , ", " + TrimAll(vRStr));
//			If Left(mClient, 1) = "," Тогда
//				mClient = Mid(mClient, 3);
//			EndIf;
//			// Set client area parameters
//			vClient.Parameters.mClient = mClient;
//			// Put client area
//			vSpreadsheet.Put(vClient);
//		EndIf;
//		// Fill row parameters
//		mAccountingDate = Format(vSrvRow.УчетнаяДата, "DF=dd.MM.yy");
//		mPrice = vSrvRow.Цена;
//		mDescription = TrimAll(vSrvRow.Примечания);
//		mSum = vSrvRow.Сумма;
//		If vSrvRow.RoomQuantity <> 0 And 
//		   ЗначениеЗаполнено(vAccommodationService) And vSrvRow.Услуга = vAccommodationService And 
//		   vSrvRow.RoomQuantity > 1 Тогда
//			mQuantity = Format(vSrvRow.RoomQuantity, "ND=10; NFD=0; NG=") + "*" + vSrvRow.Услуга.GetObject().pmGetServiceQuantityPresentation(vSrvRow.Количество/vSrvRow.RoomQuantity, SelLanguage);
//		Else
//			If Round(vSrvRow.Количество, 3) <> vSrvRow.Количество Тогда
//				mQuantity = ?(vSrvRow.Количество = 0, "", Format(vSrvRow.Количество, "ND=17; NFD=3"));
//			Else
//				mQuantity = ?(vSrvRow.Количество = 0, "", String(vSrvRow.Количество));
//			EndIf;
//			If ЗначениеЗаполнено(vSrvRow.Услуга) Тогда
//				If vSrvRow.Количество <> 0 Тогда
//					vServiceObj = vSrvRow.Услуга.GetObject();
//					mQuantity = vServiceObj.pmGetServiceQuantityPresentation(vSrvRow.Количество, SelLanguage);
//				EndIf;
//			EndIf;
//		EndIf;
//		If ExtraInvoice Тогда
//			If Services.Count() = 1 Тогда
//				If vSrvRow.Количество = 1 Тогда
//					mQuantity = Format(vSrvRow.Количество, "ND=17; NFD=0");
//				EndIf;
//			EndIf;
//		EndIf;
//		
//		// Set parameters
//		If SelGroupBy <> "InPrice" And SelGroupBy <> "InPricePerClient" And SelGroupBy <> "All" And SelGroupBy <> "AllPerClient" And SelGroupBy <> "PerClient" And SelGroupBy <> "ByService" Тогда
//			vRow.Parameters.mAccountingDate = mAccountingDate;
//		EndIf;
//		vRow.Parameters.mPrice = Format(mPrice, "ND=17; NFD=2");
//		vRow.Parameters.mQuantity = mQuantity;
//		If SelGroupBy = "InPricePerClient" Or SelGroupBy = "AllPerClient" Or SelGroupBy = "PerClient" Тогда
//			vRow.Parameters.mDescription = Chars.Tab + StrReplace(mDescription, Chars.LF, Chars.LF + Chars.Tab + Chars.Tab);
//		Else
//			vRow.Parameters.mDescription = mDescription;
//		EndIf;
//		vRow.Parameters.mSum = Format(mSum, "ND=17; NFD=2");
//		// Put row
//		If НЕ IsBlankString(mSum) Тогда
//			// Check if we can print footer completely
//			If (vServices.IndexOf(vSrvRow) + 1) = vServices.Count() Тогда
//				vFooterAreas.Вставить(0, vRow);
//				If НЕ vSpreadsheet.CheckPut(vFooterAreas) Тогда
//					vSpreadsheet.PutHorizontalPageBreak();
//					vSpreadsheet.Put(vTableHeader);
//				EndIf;
//				vFooterAreas.Delete(0);
//			Else
//				If НЕ vSpreadsheet.CheckPut(vRow) Тогда
//					vSpreadsheet.PutHorizontalPageBreak();
//					vSpreadsheet.Put(vTableHeader);
//				EndIf;
//			EndIf;
//			vSpreadsheet.Put(vRow);
//		EndIf;
//	EndDo;
//	
//	// Put footer areas
//	For Each vFooterArea In vFooterAreas Do
//		vSpreadsheet.Put(vFooterArea);
//	EndDo;
//
//	// Setup default attributes
//	cmSetDefaultPrintFormSettings(vSpreadsheet, PageOrientation.Portrait, True, , True);
//	// Check authorities
//	cmSetSpreadsheetProtection(vSpreadsheet);
//КонецПроцедуры //pmPrintInvoice
//
////-----------------------------------------------------------------------------
//Процедура pmPrintInvoiceShort(vSpreadsheet, SelLanguage, SelGroupBy, SelObjectPrintForm, mInvoiceNumber) Экспорт
//	SelInvoice = ThisObject;
//	
//	// Basic checks
//	vHotel = SelInvoice.Гостиница;
//	If НЕ ЗначениеЗаполнено(vHotel) Тогда
//		ВызватьИсключение "Не задана гостиница!";
//		Return;
//	EndIf;
//	vCompany = SelInvoice.Фирма;
//	If НЕ ЗначениеЗаполнено(vCompany) Тогда
//		ВызватьИсключение "Не задана фирма!";
//		Return;
//	EndIf;
//	vAccount = SelInvoice.BankAccount;
//	If НЕ ЗначениеЗаполнено(vAccount) Тогда
//		ВызватьИсключение "Не задан расчетный счет фирмы!";
//		Return;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(SelLanguage) Тогда
//		SelLanguage = ПараметрыСеанса.ТекЛокализация;
//	EndIf;
//	
//	// Choose template
//	vSpreadsheet.Clear();
//	If ЗначениеЗаполнено(SelLanguage) Тогда
//		If SelLanguage = Справочники.Локализация.EN Тогда
//			vTemplate = SelInvoice.GetTemplate("InvoiceShortEn");
//		ElsIf SelLanguage = Справочники.Локализация.DE Тогда
//			vTemplate = SelInvoice.GetTemplate("InvoiceShortDe");
//		ElsIf SelLanguage = Справочники.Локализация.RU Тогда
//			vTemplate = SelInvoice.GetTemplate("InvoiceShortRu");
//		Else
//			ВызватьИсключение "ru='Не найден шаблон печатной формы счета для языка " + SelLanguage.Code   ;
//			Return;
//		EndIf;
//	Else
//		vTemplate = SelInvoice.GetTemplate("InvoiceShortRu");
//	EndIf;
//	// Load external template if any
//	vExtTemplate = cmReadExternalSpreadsheetDocumentTemplate(SelObjectPrintForm);
//	If vExtTemplate <> Неопределено Тогда
//		vTemplate = vExtTemplate;
//	EndIf;
//	
//	// Print form parameter
//	vParameter = Upper(TrimAll(SelObjectPrintForm.Parameter));
//	
//	// Load pictures
//	vLogoIsSet = False;
//	vLogo = New Picture;
//	If ЗначениеЗаполнено(SelInvoice.Гостиница) Тогда
//		If SelInvoice.Гостиница.Logo <> Неопределено Тогда
//			vLogo = SelInvoice.Гостиница.Logo.Get();
//			If vLogo = Неопределено Тогда
//				vLogo = New Picture;
//			Else
//				vLogoIsSet = True;
//			EndIf;
//		EndIf;
//	EndIf;
//	vStampIsSet = False;
//	vStamp = New Picture;
//	If ЗначениеЗаполнено(SelInvoice.Фирма) Тогда
//		If SelInvoice.Фирма.Stamp <> Неопределено Тогда
//			vStamp = SelInvoice.Фирма.Stamp.Get();
//			If vStamp = Неопределено Тогда
//				vStamp = New Picture;
//			Else
//				vStampIsSet = True;
//			EndIf;
//		EndIf;
//	EndIf;
//	vSignatureIsSet = False;
//	vSignature = New Picture;
//	If ЗначениеЗаполнено(ПараметрыСеанса.ТекПользователь) Тогда
//		If ПараметрыСеанса.ТекПользователь.Подпись <> Неопределено Тогда
//			vSignature = ПараметрыСеанса.ТекПользователь.Подпись.Get();
//			If vSignature = Неопределено Тогда
//				vSignature = New Picture;
//			Else
//				vSignatureIsSet = True;
//			EndIf;
//		EndIf;
//	EndIf;
//	vDirectorSignatureIsSet = False;
//	vDirectorSignature = New Picture;
//	If SelInvoice.Фирма.DirectorSignature <> Неопределено Тогда
//		vDirectorSignature = SelInvoice.Фирма.DirectorSignature.Get();
//		If vDirectorSignature = Неопределено Тогда
//			vDirectorSignature = New Picture;
//		Else
//			vDirectorSignatureIsSet = True;
//		EndIf;
//	EndIf;
//	vAccountantGeneralSignatureIsSet = False;
//	vAccountantGeneralSignature = New Picture;
//	If SelInvoice.Фирма.AccountantGeneralSignature <> Неопределено Тогда
//		vAccountantGeneralSignature = SelInvoice.Фирма.AccountantGeneralSignature.Get();
//		If vAccountantGeneralSignature = Неопределено Тогда
//			vAccountantGeneralSignature = New Picture;
//		Else
//			vAccountantGeneralSignatureIsSet = True;
//		EndIf;
//	EndIf;
//	
//	// Header
//	vRubHeader = False;
//	If SelInvoice.ВалютаРасчетов.Code = 643 And vHotel.Гражданство.Code = 643 Тогда
//		vRubHeader = True;
//	EndIf;
//	
//	// Гостиница
//	vHotelObj = vHotel.GetObject();
//	mHotelPrintName = vHotelObj.pmGetHotelPrintName(SelLanguage);
//	mHotelPostAddressPresentation = vHotelObj.pmGetHotelPostAddressPresentation(SelLanguage);
//	vHotelPhones = TrimAll(vHotel.Телефоны);
//	vHotelFax = TrimAll(vHotel.Fax);
//	mHotelPhones = vHotelPhones + ?(IsBlankString(vHotelFax), "", ", факс " + vHotelFax);
//	mHotelEMail = TrimAll(vHotel.EMail);
//	
//	// Фирма
//	vCompanyObj = vCompany.GetObject();
//	vCompanyLegacyName = vCompanyObj.pmGetCompanyPrintName(SelLanguage);
//	vCompanyLegacyAddress = vCompanyObj.pmGetCompanyLegacyAddressPresentation(SelLanguage);
//	vCompanyPostAddress = vCompanyObj.pmGetCompanyPostAddressPresentation(SelLanguage);
//	If vCompanyPostAddress = vCompanyLegacyAddress Тогда
//		vCompanyPostAddress = "";
//	EndIf;
//	mCompanyTIN = TrimAll(vCompany.ИНН);
//	mCompanyKPP = TrimAll(vCompany.KPP);
//	vCompanyTIN = " ИНН '" + mCompanyTIN + ?(IsBlankString(mCompanyKPP), "", "/" + mCompanyKPP);
//	vCompanyPhones = TrimAll(vCompany.Телефоны) + ?(IsBlankString(vCompany.Fax), "",", факс '" + TrimAll(vCompany.Fax));
//	mCompany = TrimAll(vCompanyLegacyName + vCompanyTIN + Chars.LF + vCompanyLegacyAddress + Chars.LF + ?(IsBlankString(vCompanyPostAddress), "", vCompanyPostAddress + Chars.LF) + vCompanyPhones);
//	
//	// Invoice date and number
//	If vCompany.UseGroupCodeAsInvoiceNumberPrefix Тогда
//		If vCompany.PrintInvoiceAndSettlementNumbersWithPrefixes Тогда
//			vCompanyPrefix = TrimAll(vCompany.Prefix);
//			If НЕ IsBlankString(vCompanyPrefix) Тогда
//				mInvoiceNumber = vCompanyPrefix + cmRemoveLeadingZeroes(SelInvoice.НомерДока);
//			Else
//				mInvoiceNumber = cmRemoveLeadingZeroes(SelInvoice.НомерДока);
//			EndIf;
//		Else
//			vHotelPrefix = SelInvoice.Гостиница.GetObject().pmGetPrefix();
//			If НЕ IsBlankString(vHotelPrefix) And SelInvoice.Гостиница.ShowHotelPrefixBeforeGroupCode Тогда
//				mInvoiceNumber = vHotelPrefix + cmRemoveLeadingZeroes(SelInvoice.НомерДока);
//			Else
//				mInvoiceNumber = cmRemoveLeadingZeroes(SelInvoice.НомерДока);
//			EndIf;
//		EndIf;
//	Else
//		mInvoiceNumber = ?(vCompany.PrintInvoiceAndSettlementNumbersWithPrefixes, TrimAll(SelInvoice.НомерДока), cmGetDocumentNumberPresentation(SelInvoice.НомерДока));
//	EndIf;
//	mInvoiceDate = cmGetDocumentDatePresentation(SelInvoice.ДатаДок);
//	
//	vTableHeader = vTemplate.GetArea("TableHeader");
//	
//	// Print different invoice headers for invoices in RUR and Russia base country and other currencies/countries
//	If vRubHeader Тогда
//		vHeader = vTemplate.GetArea("Header");
//		
//		mCompanyPaymentAttributes = vCompanyLegacyName;
//		mCompanyBank = "";
//		mCompanyBankAcount = "";
//		mCompanyBankBIC = "";
//		mCompanyBankCorrAccount = "";
//		If vAccount.IsDirectPayments Тогда
//			mCompanyBank = TrimAll(vAccount.НазваниеБанка) + " " + TrimAll(vAccount.ГородБанка);
//			
//			mCompanyBankAccount = TrimAll(vAccount.НомерСчета);
//			mCompanyBankBIC = TrimAll(vAccount.БИКБанка);
//			mCompanyBankCorrAccount = TrimAll(vAccount.КорСчет);
//		Else
//			mCompanyPaymentAttributes = mCompanyPaymentAttributes + " р/с " + TrimAll(vAccount.НомерСчета);
//			mCompanyPaymentAttributes = mCompanyPaymentAttributes + " в " + TrimAll(vAccount.НазваниеБанка);
//			mCompanyPaymentAttributes = mCompanyPaymentAttributes + " " + TrimAll(vAccount.ГородБанка);
//		
//			mCompanyBank = TrimAll(vAccount.CorrBankName);
//			mCompanyBank = mCompanyBank + TrimAll(vAccount.CorrBankCity);
//			
//			mCompanyBankAccount = TrimAll(vAccount.КорСчет);
//			mCompanyBankBIC = TrimAll(vAccount.CorrBankBIC);
//			mCompanyBankCorrAccount = TrimAll(vAccount.CorrBankCorrAccountNumber);
//		EndIf;
//		If НЕ IsBlankString(vAccount.Получатель) Тогда
//			mCompanyPaymentAttributes = TrimAll(vAccount.Получатель);
//		EndIf;
//		// Контрагент
//		If SelInvoice.Контрагент = vHotel.IndividualsCustomer Тогда
//			// Use contact person as Контрагент
//			If НЕ IsBlankString(SelInvoice.КонтактноеЛицо) Тогда
//				mCustomer = TrimAll(SelInvoice.КонтактноеЛицо);
//			Else
//				vClientRef = Справочники.Клиенты.EmptyRef();
//				// Use guest group client as Контрагент
//				If ЗначениеЗаполнено(SelInvoice.ГруппаГостей) And ЗначениеЗаполнено(SelInvoice.ГруппаГостей.Клиент) Тогда
//					vClientRef = SelInvoice.ГруппаГостей.Клиент;
//				// Use first client as Контрагент
//				Else
//					For Each vRow In SelInvoice.Услуги Do
//						If ЗначениеЗаполнено(vRow.Клиент) Тогда
//							vClientRef = vRow.Клиент;
//							Break;
//						EndIf;
//					EndDo;
//				EndIf;
//				vCustomer = vClientRef;
//				vCustomerLegacyName = "";
//				vCustomerLegacyAddress = "";
//				vCustomerTIN = "";
//				vCustomerPhones = "";
//				If ЗначениеЗаполнено(vClientRef) Тогда
//					vCustomerLegacyName = TrimAll(vClientRef.FullName);
//					vCustomerLegacyAddress = cmGetAddressPresentation(vClientRef.Address);
//					vCustomerTIN = "";
//					vCustomerKPP = "";
//					// Fax and E-Mail
//					vCustomerPhones = TrimAll(vClientRef.Телефон);
//					vCustomerFax = TrimAll(vClientRef.Fax);
//					vCustomerPhones = vCustomerPhones + ?(IsBlankString(vCustomerFax), "", ", факс '" + vCustomerFax);
//				EndIf;
//				mCustomer = TrimAll(vCustomerLegacyName + vCustomerTIN + Chars.LF + vCustomerLegacyAddress + Chars.LF + vCustomerPhones);
//			EndIf;
//			// Contract
//			mContract = "";
//		Else
//			vCustomer = SelInvoice.Контрагент;
//			vCustomerLegacyName = "";
//			vCustomerLegacyAddress = "";
//			vCustomerPostAddress = "";
//			vCustomerTIN = "";
//			vCustomerPhones = "";
//			If ЗначениеЗаполнено(vCustomer) Тогда
//				vCustomerLegacyName = TrimAll(vCustomer.ЮрИмя);
//				If IsBlankString(vCustomerLegacyName) Тогда
//					vCustomerLegacyName = TrimAll(vCustomer.Description);
//				EndIf;
//				vCustomerLegacyAddress = cmGetAddressPresentation(vCustomer.LegacyAddress);
//				vCustomerPostAddress = cmGetAddressPresentation(vCustomer.PostAddress);
//				If vCustomerPostAddress = vCustomerLegacyAddress Тогда
//					vCustomerPostAddress = "";
//				EndIf;
//				vCustomerTIN = TrimAll(vCustomer.ИНН);
//				vCustomerKPP = TrimAll(vCustomer.KPP);
//				vCustomerTIN = " ИНН '" + vCustomerTIN + ?(IsBlankString(vCustomerKPP), "", "/" + vCustomerKPP);
//				// Fax and E-Mail
//				vCustomerPhones = TrimAll(vCustomer.Телефон);
//				vCustomerFax = TrimAll(vCustomer.Fax);
//				vCustomerPhones = vCustomerPhones + ?(IsBlankString(vCustomerFax), "", ", факс '" + vCustomerFax);
//			EndIf;
//			mCustomer = TrimAll(vCustomerLegacyName + vCustomerTIN + Chars.LF + vCustomerLegacyAddress + Chars.LF + ?(IsBlankString(vCustomerPostAddress), "", vCustomerPostAddress + Chars.LF) + vCustomerPhones);
//			// Contract
//			mContract = "";
//			If ЗначениеЗаполнено(SelInvoice.Договор) Тогда
//				mContract = TrimAll(SelInvoice.Договор.Description);
//			EndIf;
//		EndIf;
//		// Guest group code
//		mGuestGroup = "";
//		vHotelPrefix = SelInvoice.Гостиница.GetObject().pmGetPrefix();
//		If ЗначениеЗаполнено(SelInvoice.ГруппаГостей) Тогда
//			mGuestGroup = Format(SelInvoice.ГруппаГостей.Code, "ND=12; NFD=0; NG=");
//			If НЕ IsBlankString(SelInvoice.ГруппаГостей.Description) Тогда
//				mGuestGroup = mGuestGroup + " - " + TrimAll(SelInvoice.ГруппаГостей.Description);
//			EndIf;
//			If НЕ IsBlankString(vHotelPrefix) And SelInvoice.Гостиница.ShowHotelPrefixBeforeGroupCode Тогда
//				mGuestGroup = vHotelPrefix + mGuestGroup;
//			EndIf;
//		Else
//			vGroups = SelInvoice.Услуги.Unload(, "ГруппаГостей");
//			vGroups.GroupBy("ГруппаГостей", );
//			For Each vGroupsRow In vGroups Do
//				If ЗначениеЗаполнено(vGroupsRow.ГруппаГостей) Тогда
//					vGuestGroupCode = Format(vGroupsRow.ГруппаГостей.Code, "ND=12; NFD=0; NG=");
//					If НЕ IsBlankString(vHotelPrefix) And SelInvoice.Гостиница.ShowHotelPrefixBeforeGroupCode Тогда
//						vGuestGroupCode = vHotelPrefix + vGuestGroupCode;
//					EndIf;
//					If IsBlankString(mGuestGroup) Тогда
//						mGuestGroup = vGuestGroupCode;
//					Else
//						mGuestGroup = mGuestGroup + ", " + vGuestGroupCode;
//					EndIf;
//				EndIf;
//			EndDo;
//		EndIf;
//		// Currency
//		mAccountingCurrency = "";
//		If ЗначениеЗаполнено(SelInvoice.ВалютаРасчетов) Тогда
//			vCurrencyObj = SelInvoice.ВалютаРасчетов.GetObject();
//			mAccountingCurrency = vCurrencyObj.pmGetCurrencyDescription(SelLanguage);
//		EndIf;
//		// Parent document
//		mParentDoc = String(SelInvoice.ДокОснование);
//		mFullInvoiceNumber = Trimall(SelInvoice.НомерДока);
//		// Set parameters and put report section
//		vHeader.Parameters.mHotelPrintName = mHotelPrintName;
//		vHeader.Parameters.mHotelPostAddressPresentation = mHotelPostAddressPresentation;
//		vHeader.Parameters.mHotelPhones = mHotelPhones;
//		vHeader.Parameters.mHotelEMail = mHotelEMail;
//		vHeader.Parameters.mInvoiceNumber = mInvoiceNumber;
//		vHeader.Parameters.mFullInvoiceNumber = mFullInvoiceNumber;
//		vHeader.Parameters.mInvoiceDate = mInvoiceDate;
//		If SelInvoice.ВалютаРасчетов = vHotel.BaseCurrency Тогда
//			vHeader.Parameters.mCompany = mCompany;
//			vHeader.Parameters.mCompanyTIN = mCompanyTIN;
//			vHeader.Parameters.mCompanyKPP = mCompanyKPP;
//			vHeader.Parameters.mCompanyBankBIC = mCompanyBankBIC;
//			vHeader.Parameters.mCompanyBankCorrAccount = mCompanyBankCorrAccount;
//		EndIf;
//		vHeader.Parameters.mCompanyPaymentAttributes = mCompanyPaymentAttributes;
//		vHeader.Parameters.mCompanyBank = mCompanyBank;
//		vHeader.Parameters.mCompanyBankAccount = mCompanyBankAccount;
//		vHeader.Parameters.mCustomer = mCustomer;
//		vHeader.Parameters.mInvoiceEMail = TrimAll(SelInvoice.EMail);
//		vHeader.Parameters.mContract = mContract;
//		vHeader.Parameters.mGuestGroup = mGuestGroup;
//		vHeader.Parameters.mAccountingCurrency = mAccountingCurrency;
//		vHeader.Parameters.mParentDoc = mParentDoc;
//		// Logo
//		If vLogoIsSet Тогда
//			vHeader.Drawings.Logo.Print = True;
//			vHeader.Drawings.Logo.Picture = vLogo;
//		Else
//			vHeader.Drawings.Delete(vHeader.Drawings.Logo);
//		EndIf;
//		// Put header		
//		vSpreadsheet.Put(vHeader);
//		vSpreadsheet.Put(vTableHeader);
//	Else
//		vHeader1 = vTemplate.GetArea("HeaderCurrency1");
//		
//		If НЕ IsBlankString(vAccount.Получатель) Тогда
//			mCompany = TrimAll(vAccount.Получатель);
//		EndIf;
//		
//		mCompanyBank = TrimAll(TrimAll(vAccount.НазваниеБанка) + " " + TrimAll(vAccount.ГородБанка));
//		mCompanyBankAccount = TrimAll(vAccount.НомерСчета);
//		If НЕ IsBlankString(vAccount.БИКБанка) Тогда
//			mCompanyBank = mCompanyBank + Chars.LF + "БИК " + TrimAll(vAccount.БИКБанка);
//		EndIf;
//		If НЕ IsBlankString(vAccount.КорСчет) Тогда
//			mCompanyBank = mCompanyBank + Chars.LF + "Корр. сч. № " + TrimAll(vAccount.КорСчет);
//		EndIf;
//		If НЕ IsBlankString(vAccount.ИННБанка) Тогда
//			mCompanyBank = mCompanyBank + Chars.LF + TrimAll(vAccount.ИННБанка);
//		EndIf;
//		If НЕ IsBlankString(vAccount.BankSWIFTCode) Тогда
//			mCompanyBank = mCompanyBank + Chars.LF +"SWIFT " + TrimAll(vAccount.BankSWIFTCode);
//		EndIf;
//		
//		// Set parameters and put report section
//		vHeader1.Parameters.mHotelPrintName = mHotelPrintName;
//		vHeader1.Parameters.mHotelPostAddressPresentation = mHotelPostAddressPresentation;
//		vHeader1.Parameters.mHotelPhones = mHotelPhones;
//		vHeader1.Parameters.mHotelEMail = mHotelEMail;
//		vHeader1.Parameters.mInvoiceNumber = mInvoiceNumber;
//		vHeader1.Parameters.mInvoiceDate = mInvoiceDate;
//		vHeader1.Parameters.mCompany = mCompany;
//		vHeader1.Parameters.mCompanyBankAccount = mCompanyBankAccount;
//		vHeader1.Parameters.mCompanyBank = mCompanyBank;
//		// Logo
//		If vLogoIsSet Тогда
//			vHeader1.Drawings.LogoCurrency.Print = True;
//			vHeader1.Drawings.LogoCurrency.Picture = vLogo;
//		Else
//			vHeader1.Drawings.Delete(vHeader1.Drawings.LogoCurrency);
//		EndIf;
//		// Put header1		
//		vSpreadsheet.Put(vHeader1);
//		
//		// Put correspondent bank header
//		If НЕ vAccount.IsDirectPayments Тогда
//			vCorrBankHeader = vTemplate.GetArea("CorrBank");
//			
//			mCompanyCorrBank = TrimAll(TrimAll(vAccount.CorrBankName) + " " + TrimAll(vAccount.CorrBankCity));
//			If НЕ IsBlankString(vAccount.CorrBankBIC) Тогда
//				mCompanyCorrBank = mCompanyCorrBank + Chars.LF + "БИК " + TrimAll(vAccount.CorrBankBIC);
//			EndIf;
//			If НЕ IsBlankString(vAccount.CorrBankCorrAccountNumber) Тогда
//				mCompanyCorrBank = mCompanyCorrBank + "Корр. сч. № " + TrimAll(vAccount.CorrBankCorrAccountNumber);
//			EndIf;
//			If НЕ IsBlankString(vAccount.CorrBankTINCode) Тогда
//				mCompanyCorrBank = mCompanyCorrBank + Chars.LF + TrimAll(vAccount.CorrBankTINCode);
//			EndIf;
//			If НЕ IsBlankString(vAccount.CorrBankSWIFTCode) Тогда
//				mCompanyCorrBank = mCompanyCorrBank + Chars.LF + "SWIFT '" + TrimAll(vAccount.CorrBankSWIFTCode);
//			EndIf;
//			
//			// Set parameters and put report section
//			vCorrBankHeader.Parameters.mCompanyCorrBank = mCompanyCorrBank;
//			
//			// Put corr. bank header
//			vSpreadsheet.Put(vCorrBankHeader);
//		EndIf;
//		
//		// Table header
//		vHeader2 = vTemplate.GetArea("HeaderCurrency2");
//		
//		// Контрагент
//		If SelInvoice.Контрагент = vHotel.IndividualsCustomer Тогда
//			// Use contact person as Контрагент
//			If НЕ IsBlankString(SelInvoice.КонтактноеЛицо) Тогда
//				mCustomer = TrimAll(SelInvoice.КонтактноеЛицо);
//			Else				
//				vClientRef = Справочники.Клиенты.EmptyRef();
//				// Use guest group client as Контрагент
//				If ЗначениеЗаполнено(SelInvoice.ГруппаГостей) And ЗначениеЗаполнено(SelInvoice.ГруппаГостей.Клиент) Тогда
//					vClientRef = SelInvoice.ГруппаГостей.Клиент;
//				// Use first client as Контрагент
//				Else
//					For Each vRow In SelInvoice.Услуги Do
//						If ЗначениеЗаполнено(vRow.Клиент) Тогда
//							vClientRef = vRow.Клиент;
//							Break;
//						EndIf;
//					EndDo;
//				EndIf;
//				vCustomer = vClientRef;
//				vCustomerLegacyName = "";
//				vCustomerLegacyAddress = "";
//				vCustomerTIN = "";
//				vCustomerPhones = "";
//				If ЗначениеЗаполнено(vClientRef) Тогда
//					vCustomerLegacyName = TrimAll(vClientRef.FullName);
//					vCustomerLegacyAddress = cmGetAddressPresentation(vClientRef.Address);
//					vCustomerTIN = "";
//					vCustomerKPP = "";
//					// Fax and E-Mail
//					vCustomerPhones = TrimAll(vClientRef.Телефон);
//					vCustomerFax = TrimAll(vClientRef.Fax);
//					vCustomerPhones = vCustomerPhones + ?(IsBlankString(vCustomerFax), "",", факс '" + vCustomerFax);
//				EndIf;
//				mCustomer = TrimAll(vCustomerLegacyName + vCustomerTIN + Chars.LF + vCustomerLegacyAddress + Chars.LF + vCustomerPhones);
//			EndIf;
//			// Contract
//			mContract = "";
//		Else
//			vCustomer = SelInvoice.Контрагент;
//			vCustomerLegacyName = "";
//			vCustomerLegacyAddress = "";
//			vCustomerPostAddress = "";
//			vCustomerTIN = "";
//			vCustomerPhones = "";
//			If ЗначениеЗаполнено(vCustomer) Тогда
//				vCustomerLegacyName = TrimAll(vCustomer.ЮрИмя);
//				If IsBlankString(vCustomerLegacyName) Тогда
//					vCustomerLegacyName = TrimAll(vCustomer.Description);
//				EndIf;
//				vCustomerLegacyAddress = cmGetAddressPresentation(vCustomer.LegacyAddress);
//				vCustomerPostAddress = cmGetAddressPresentation(vCustomer.PostAddress);
//				If vCustomerPostAddress = vCustomerLegacyAddress Тогда
//					vCustomerPostAddress = "";
//				EndIf;
//				vCustomerTIN = TrimAll(vCustomer.ИНН);
//				vCustomerKPP = TrimAll(vCustomer.KPP);
//				vCustomerTIN = " ИНН " + vCustomerTIN + ?(IsBlankString(vCustomerKPP), "", "/" + vCustomerKPP);
//				// Fax and E-Mail
//				vCustomerPhones = TrimAll(vCustomer.Телефон);
//				vCustomerFax = TrimAll(vCustomer.Fax);
//				vCustomerPhones = vCustomerPhones + ?(IsBlankString(vCustomerFax), "", ", факс " + vCustomerFax);
//			EndIf;
//			mCustomer = TrimAll(vCustomerLegacyName + vCustomerTIN + Chars.LF + vCustomerLegacyAddress + Chars.LF + ?(IsBlankString(vCustomerPostAddress), "", vCustomerPostAddress + Chars.LF) + vCustomerPhones);
//			// Contract
//			mContract = "";
//			If ЗначениеЗаполнено(SelInvoice.Договор) Тогда
//				mContract = TrimAll(SelInvoice.Договор.Description);
//			EndIf;
//		EndIf;
//		// Guest group code
//		mGuestGroup = "";
//		If ЗначениеЗаполнено(SelInvoice.ГруппаГостей) Тогда
//			mGuestGroup = Format(SelInvoice.ГруппаГостей.Code, "ND=12; NFD=0; NG=");
//			If НЕ IsBlankString(SelInvoice.ГруппаГостей.Description) Тогда
//				mGuestGroup = mGuestGroup + " - " + TrimAll(SelInvoice.ГруппаГостей.Description);
//			EndIf;
//		Else
//			vGroups = SelInvoice.Услуги.Unload(, "ГруппаГостей");
//			vGroups.GroupBy("ГруппаГостей", );
//			For Each vGroupsRow In vGroups Do
//				If ЗначениеЗаполнено(vGroupsRow.ГруппаГостей) Тогда
//					vGuestGroupCode = Format(vGroupsRow.ГруппаГостей.Code, "ND=12; NFD=0; NG=");
//					If IsBlankString(mGuestGroup) Тогда
//						mGuestGroup = vGuestGroupCode;
//					Else
//						mGuestGroup = mGuestGroup + ", " + vGuestGroupCode;
//					EndIf;
//				EndIf;
//			EndDo;
//		EndIf;
//		// Currency
//		mAccountingCurrency = "";
//		If ЗначениеЗаполнено(SelInvoice.ВалютаРасчетов) Тогда
//			vCurrencyObj = SelInvoice.ВалютаРасчетов.GetObject();
//			mAccountingCurrency = vCurrencyObj.pmGetCurrencyDescription(SelLanguage);
//		EndIf;
//		// Parent document
//		mParentDoc = String(SelInvoice.ДокОснование);
//		mFullInvoiceNumber = Trimall(SelInvoice.НомерДока);
//		// Set parameters and put report section
//		vHeader2.Parameters.mFullInvoiceNumber = mFullInvoiceNumber;
//		vHeader2.Parameters.mCustomer = mCustomer;
//		vHeader2.Parameters.mInvoiceEMail = TrimAll(SelInvoice.EMail);
//		vHeader2.Parameters.mContract = mContract;
//		vHeader2.Parameters.mGuestGroup = mGuestGroup;
//		vHeader2.Parameters.mAccountingCurrency = mAccountingCurrency;
//		vHeader2.Parameters.mParentDoc = mParentDoc;
//		// Put header		
//		vSpreadsheet.Put(vHeader2);
//		vSpreadsheet.Put(vTableHeader);
//	EndIf;
//	
//	// Get template areas
//	vClient = vTemplate.GetArea("Клиент");
//	vRow = vTemplate.GetArea("Row");
//	
//	// Get all services
//	vServices = SelInvoice.Услуги.Unload();
//	
//	// Calculate totals
//	vVATRateTransactions = vServices.Copy();
//	vVATRateTransactions.GroupBy("СтавкаНДС", "Сумма, СуммаНДС");
//	vVATRateTransactions.Clear();
//	
//	vAgentCommission = 0;
//	vTotalSum = 0;
//	vTotalSumNoCommission = 0;
//	vTotalCommissionSum = 0;
//	vTotalVATSumNoCommission = 0;
//	vTotalVATSum = 0;
//	vUseSectionVAT = False;
//	For Each vSrvRow In vServices Do
//		If vAgentCommission = 0 Тогда
//			vAgentCommission = vSrvRow.КомиссияАгента;
//		EndIf;
//		vTotalSum = vTotalSum + vSrvRow.Сумма;
//		vTotalSumNoCommission = vTotalSumNoCommission + vSrvRow.Сумма - vSrvRow.СуммаКомиссии;
//		vTotalCommissionSum = vTotalCommissionSum + vSrvRow.СуммаКомиссии;
//		
//		// Get effective VAT rate
//		vVATRate = vSrvRow.СтавкаНДС;
//		If ЗначениеЗаполнено(vSrvRow.Услуга) And ЗначениеЗаполнено(vSrvRow.Услуга.PaymentSection) And ЗначениеЗаполнено(vSrvRow.Услуга.PaymentSection.СтавкаНДС) And 
//		   vSrvRow.СтавкаНДС <> vSrvRow.Услуга.PaymentSection.СтавкаНДС Тогда
//			vVATRate = vSrvRow.Услуга.PaymentSection.СтавкаНДС;
//			vUseSectionVAT = True;
//		EndIf;
//		
//		vTotalVATSumNoCommission = vTotalVATSumNoCommission + cmCalculateVATSum(vVATRate, (vSrvRow.Сумма - vSrvRow.СуммаКомиссии));
//		vTotalVATSum = vTotalVatSum + cmCalculateVATSum(vVATRate, vSrvRow.Сумма);
//		
//		vVATRateTransactionsRow = vVATRateTransactions.Add();
//		vVATRateTransactionsRow.СтавкаНДС = vVATRate;
//		vVATRateTransactionsRow.СуммаНДС = cmCalculateVATSum(vVATRate, vSrvRow.Сумма);
//		vVATRateTransactionsRow.Сумма = vSrvRow.Сумма;
//	EndDo;
//	
//	// Change accounting dates for breakfast
//	If НЕ IsBlankString(SelGroupBy) And SelGroupBy <> "ByService" Тогда
//		If vServices.Find(True, "IsRoomRevenue") <> Неопределено Тогда
//			For Each vSrvRow In vServices Do
//				If vSrvRow.IsInPrice And ЗначениеЗаполнено(vSrvRow.Услуга.QuantityCalculationRule) And
//				   vSrvRow.Услуга.QuantityCalculationRule.QuantityCalculationRuleType = Перечисления.QuantityCalculationRuleTypes.Breakfast Тогда
//					If BegOfDay(vSrvRow.УчетнаяДата) > BegOfDay(vSrvRow.DateTimeFrom) Тогда
//						vSrvRow.УчетнаяДата = vSrvRow.УчетнаяДата - 24*3600;
//					EndIf;
//				EndIf;
//			EndDo;
//		EndIf;
//	EndIf;
//	
//	// Join services according to service parameters
//	If НЕ IsBlankString(SelGroupBy) And SelGroupBy <> "ByService" Тогда
//		i = 0;
//		While i < vServices.Count() Do
//			vSrvRow = vServices.Get(i);
//			If НЕ vSrvRow.IsInPrice And ЗначениеЗаполнено(vSrvRow.Услуга.HideIntoServiceOnPrint) Тогда
//				// Try to find service to hide current one to
//				vHideToServices = vServices.FindRows(New Structure("Услуга, УчетнаяДата, Клиент, ТипНомера, НомерРазмещения, Ресурс", vSrvRow.Услуга.HideIntoServiceOnPrint, vSrvRow.УчетнаяДата, vSrvRow.Клиент, vSrvRow.ТипНомера, vSrvRow.НомерРазмещения, vSrvRow.Ресурс));
//				If vHideToServices.Count() = 1 Тогда
//					vSrv2Hide2 = vHideToServices.Get(0);
//					vSrv2Hide2.Сумма = vSrv2Hide2.Сумма + vSrvRow.Сумма;
//					vSrv2Hide2.СуммаНДС = vSrv2Hide2.СуммаНДС + vSrvRow.СуммаНДС;
//					vSrv2Hide2.СуммаСкидки = vSrv2Hide2.СуммаСкидки + vSrvRow.СуммаСкидки;
//					vSrv2Hide2.Цена = cmRecalculatePrice(vSrv2Hide2.Сумма, vSrv2Hide2.Количество);
//					// Delete current service
//					vServices.Delete(i);
//					Continue;
//				EndIf;
//			EndIf;
//			i = i + 1;
//		EndDo;
//	EndIf;
//	
//	// Get accommodation service name
//	vAccommodationService = Неопределено;	
//	vAccommodationRemarks = "";	
//	vAccommodationServiceVATRate = Неопределено;
//	i = 0;
//	While i < vServices.Count() Do
//		vSrvRow = vServices.Get(i);
//		If SelGroupBy = "InPricePerClientPerDay" Or SelGroupBy = "InPricePerDay" Or
//		   SelGroupBy = "AllPerClientPerDay" Or SelGroupBy = "AllPerDay" Or
//		   SelGroupBy = "InPricePerClient" Or SelGroupBy = "InPrice" Or
//		   SelGroupBy = "AllPerClient" Or SelGroupBy = "All" Тогда
//			If vSrvRow.Сумма = 0 Тогда
//				vServices.Delete(i);
//				Continue;
//			EndIf;
//		EndIf;
//		If vAccommodationService = Неопределено And vSrvRow.IsRoomRevenue And НЕ vSrvRow.Услуга.RoomRevenueAmountsOnly Тогда
//			vAccommodationService = vSrvRow.Услуга;
//			vAccommodationServiceVATRate = vSrvRow.СтавкаНДС;
//			vAccommodationRemarks = TrimAll(vSrvRow.Примечания);
//			If SelGroupBy = "InPrice" Or SelGroupBy = "All" Тогда
//				If ЗначениеЗаполнено(vAccommodationService) Тогда
//					vSrvDescr = vAccommodationService.GetObject().pmGetServiceDescription(SelLanguage, False);
//					vSrvGrpDescr = vAccommodationService.GetObject().pmGetServiceDescription(SelLanguage, True);
//					vAccommodationRemarks = StrReplace(vAccommodationRemarks, vSrvDescr, vSrvGrpDescr);
//				EndIf;
//			EndIf;
//		EndIf;
//		i = i + 1;
//	EndDo;
//	
//	// Calculate totals
//	If НЕ vUseSectionVAT Тогда
//		vTotalVATSumNoCommission = 0;
//		vTotalVATSum = 0;
//		vVATRateTransactions.Clear();
//	EndIf;
//	
//	// Group by services by the accommodation conditions
//	vConditions = vServices.Copy();
//	vConditions.GroupBy("ВидРазмещения, ТипНомера, Ресурс, DateTimeFrom, DateTimeTo, Клиент, RoomQuantity", );
//	vConditions.GroupBy("ВидРазмещения, ТипНомера, Ресурс, DateTimeFrom, DateTimeTo", "RoomQuantity");
//	For Each vConditionsRow In vConditions Do
//		// Select services for the each condition
//		vRowsArray = vServices.FindRows(New Structure("ВидРазмещения, ТипНомера, Ресурс, DateTimeFrom, DateTimeTo", 
//		                                vConditionsRow.ВидРазмещения, vConditionsRow.ТипНомера, 
//		                                vConditionsRow.Ресурс, 
//		                                vConditionsRow.DateTimeFrom, vConditionsRow.DateTimeTo));
//		vCndServices = vServices.CopyColumns();
//		For Each vRowElement In vRowsArray Do
//			vCndServicesRow = vCndServices.Add();
//			FillPropertyValues(vCndServicesRow, vRowElement);
//		EndDo;
//	
//		For Each vSrvRow In vCndServices Do
//			vSrvRow.УчетнаяДата = BegOfDay(SelInvoice.ДатаДок);
//			vSrvRow.Клиент = Справочники.Клиенты.EmptyRef();
//			vSrvRow.КоличествоЧеловек = 0;
//			vSrvRow.ВидРазмещения = Справочники.ВидыРазмещения.EmptyRef();
//			vSrvRow.ТипНомера = Справочники.ТипыНомеров.EmptyRef();
//			vSrvRow.НомерРазмещения = Справочники.НомернойФонд.EmptyRef();
//			vSrvRow.Ресурс = Справочники.Ресурсы.EmptyRef();
//			vSrvRow.ТипДняКалендаря = Справочники.ТипДневногоКалендаря.EmptyRef();
//			vSrvRow.DateTimeFrom = Неопределено;
//			vSrvRow.DateTimeTo = Неопределено;
//			If SelGroupBy = "InPrice" Or SelGroupBy = "All" Тогда
//				If ЗначениеЗаполнено(vAccommodationService) And vAccommodationServiceVATRate = vSrvRow.СтавкаНДС Тогда
//					If SelGroupBy = "InPrice" Тогда
//						// Reset "is in price" flag if necessary
//						If ЗначениеЗаполнено(vSrvRow.Услуга) And vSrvRow.Услуга.DoNotGroupIntoRoomRateOnPrint Тогда
//							vSrvRow.IsInPrice = False;
//						EndIf;
//						If НЕ vSrvRow.IsRoomRevenue And vSrvRow.IsInPrice Тогда
//							vSrvRow.Услуга = vAccommodationService;
//							vSrvRow.Примечания = vAccommodationRemarks;
//							vSrvRow.Количество = 0;
//							vSrvRow.Цена = 0;
//						ElsIf vSrvRow.IsRoomRevenue And vSrvRow.IsInPrice Тогда
//							If vSrvRow.Услуга.RoomRevenueAmountsOnly Тогда
//								vSrvRow.Количество = 0;
//							EndIf;
//							vSrvRow.Услуга = vAccommodationService;
//							vSrvRow.Примечания = vAccommodationRemarks;
//							vSrvRow.Цена = 0;
//						EndIf;
//					ElsIf SelGroupBy = "All" Тогда
//						If НЕ vSrvRow.IsRoomRevenue Тогда
//							vSrvRow.Услуга = vAccommodationService;
//							vSrvRow.Примечания = vAccommodationRemarks;
//							vSrvRow.Количество = 0;
//							vSrvRow.Цена = 0;
//						Else
//							If vSrvRow.Услуга.RoomRevenueAmountsOnly Тогда
//								vSrvRow.Количество = 0;
//							EndIf;
//							vSrvRow.Услуга = vAccommodationService;
//							vSrvRow.Примечания = vAccommodationRemarks;
//							vSrvRow.Цена = 0;
//						EndIf;
//					EndIf;
//				EndIf;
//			EndIf;
//		EndDo;
//		vCndServices.GroupBy("Услуга, Примечания, СтавкаНДС, КомиссияАгента", "Сумма, СуммаНДС, Цена, Количество, СуммаКомиссии");
//		// Recalculate price for all services and delete zero sum rows
//		i = 0;
//		While i < vCndServices.Count() Do
//			vSrvRow = vCndServices.Get(i);
//			If vSrvRow.Сумма = 0 And (SelGroupBy = "InPrice" Or SelGroupBy = "All") Тогда
//				vCndServices.Delete(i);
//			Else
//				vSrvRow.СуммаНДС = cmCalculateVATSum(vSrvRow.СтавкаНДС, vSrvRow.Сумма);
//				vSrvRow.Цена = cmRecalculatePrice(vSrvRow.Сумма, vSrvRow.Количество);
//				
//				If НЕ vUseSectionVAT Тогда
//					vTotalVATSumNoCommission = vTotalVATSumNoCommission + cmCalculateVATSum(vSrvRow.СтавкаНДС, (vSrvRow.Сумма - vSrvRow.СуммаКомиссии));
//					vTotalVATSum = vTotalVatSum + vSrvRow.СуммаНДС;
//					
//					vVATRateTransactionsRow = vVATRateTransactions.Add();
//					vVATRateTransactionsRow.СтавкаНДС = vSrvRow.СтавкаНДС;
//					vVATRateTransactionsRow.СуммаНДС = vSrvRow.СуммаНДС;
//					vVATRateTransactionsRow.Сумма = vSrvRow.Сумма;
//				EndIf;
//				i = i + 1;
//			EndIf;
//		EndDo;
//	EndDo;
//	
//	// Build footer
//	vFooterAreas = new Array();
//	vFooter1 = vTemplate.GetArea("Footer1");
//	vCommission = vTemplate.GetArea("Комиссия");
//	vFooter2 = vTemplate.GetArea("Footer2");
//	// Fill parameters
//	mTotalSum = Format(vTotalSum, "ND=17; NFD=2") + " " + mAccountingCurrency;
//	If ЗначениеЗаполнено(vCompany) And vCompany.DoNotPrintVAT Тогда
//		mTotalVATSum = "";
//	Else
//		If vTotalVATSumNoCommission <> 0 And 
//		   ЗначениеЗаполнено(SelInvoice.Контрагент) And НЕ SelInvoice.Контрагент.DoNotPostCommission Тогда
//			mTotalVATSum = "В том числе НДС " + Format(vTotalVATSumNoCommission, "ND=17; NFD=2") + " " + mAccountingCurrency;
//		ElsIf vTotalVATSum <> 0 And
//		      ЗначениеЗаполнено(SelInvoice.Контрагент) And SelInvoice.Контрагент.DoNotPostCommission Тогда
//			mTotalVATSum = "В том числе НДС " + Format(vTotalVATSum, "ND=17; NFD=2") + " " + mAccountingCurrency;
//		Else
//			If ЗначениеЗаполнено(SelInvoice.Фирма) And SelInvoice.Фирма.IsUsingSimpleTaxSystem Тогда
//				mTotalVATSum = "НДС не облагается в связи с применением упрощенной системы налогообложения (п. 2 ст. 346.11 НК РФ)";
//			Else
//				mTotalVATSum = "НДС не облагается";
//			EndIf;
//		EndIf;
//	EndIf;
//	mTotalSumInWords = cmSumInWords(vTotalSum, SelInvoice.ВалютаРасчетов, SelLanguage);
//	// Set parameters
//	vFooter1.Parameters.mTotalSum = mTotalSum;
//	vFooter2.Parameters.mTotalVATSum = mTotalVATSum;
//	vFooter2.Parameters.mTotalSumInWords = mTotalSumInWords;
//	// Put footer
//	vFooterAreas.Add(vFooter1);
//	If vTotalCommissionSum <> 0 And 
//	   ЗначениеЗаполнено(SelInvoice.Контрагент) And НЕ SelInvoice.Контрагент.DoNotPostCommission Тогда
//		mTotalSumInWords = cmSumInWords(vTotalSumNoCommission, SelInvoice.ВалютаРасчетов, SelLanguage);
//		vFooter2.Parameters.mTotalSumInWords = mTotalSumInWords;
//		mSumToBePaid = Format(vTotalSumNoCommission, "ND=17; NFD=2") + " " + mAccountingCurrency;
//		mAgentCommission = vAgentCommission;
//		mTotalCommissionSum = Format(vTotalCommissionSum, "ND=17; NFD=2") + " " + mAccountingCurrency;
//		vCommission.Parameters.mTotalCommissionSum = mTotalCommissionSum;
//		vCommission.Parameters.mAgentCommission = mAgentCommission;
//		vCommission.Parameters.mSumToBePaid = mSumToBePaid;
//		vFooterAreas.Add(vCommission);
//	EndIf;
//	vFooterAreas.Add(vFooter2);
//	
//	// VAT rates table
//	vVATHeaderArea = vTemplate.GetArea("VATHeader");
//	vFooterAreas.Add(vVATHeaderArea);
//	vVATRateTransactions.GroupBy("СтавкаНДС", "Сумма, СуммаНДС");
//	vVATRateTransactions.Sort("СтавкаНДС");
//	For Each vVATRateRow In vVATRateTransactions Do
//		vVATRateRowArea = vTemplate.GetArea("VATRateRow");
//		vVATRateRowArea.Parameters.mVATRate = TrimAll(vVATRateRow.СтавкаНДС);
//		vVATRateRowArea.Parameters.mSumWithoutVAT = Format(vVATRateRow.Сумма - vVATRateRow.СуммаНДС, "ND=17; NFD=2; NZ=");
//		vVATRateRowArea.Parameters.mVATSum = Format(vVATRateRow.СуммаНДС, "ND=17; NFD=2; NZ=");
//		vVATRateRowArea.Parameters.mSumWithVAT = Format(vVATRateRow.Сумма, "ND=17; NFD=2; NZ=");
//		vFooterAreas.Add(vVATRateRowArea);
//	EndDo;
//	
//	// Signatures
//	vSignedByManager = False;
//	If ЗначениеЗаполнено(SelInvoice.Фирма) And SelInvoice.Фирма.InvoiceIsSignedByManager Тогда
//		vSignedByManager = True;
//	EndIf;
//	If НЕ vSignedByManager Тогда
//		If SelInvoice.PrintWithCompanyStamp Тогда
//			vSignatures = vTemplate.GetArea("SignaturesWithStamp");
//		Else
//			vSignatures = vTemplate.GetArea("Signatures");
//		EndIf;
//		mCompanyDirector = TrimAll(vCompany.Director);
//		If НЕ IsBlankString(vCompany.DirectorPosition) Тогда
//			mCompanyDirectorPosition = TrimAll(vCompany.DirectorPosition);
//		Else
//			mCompanyDirectorPosition = "Руководитель";
//		EndIf;
//		mCompanyAccountantGeneral = TrimAll(vCompany.AccountantGeneral);
//		If НЕ IsBlankString(vCompany.AccountantGeneralPosition) Тогда
//			mCompanyAccountantGeneralPosition = TrimAll(vCompany.AccountantGeneralPosition);
//		Else
//			mCompanyAccountantGeneralPosition = "Бухгалтер";
//		EndIf;
//		vSignatures.Parameters.mRemarks = TrimAll(SelInvoice.Примечания);
//		vSignatures.Parameters.mCompanyDirector = mCompanyDirector;
//		vSignatures.Parameters.mCompanyDirectorPosition = mCompanyDirectorPosition;
//		vSignatures.Parameters.mCompanyAccountantGeneral = mCompanyAccountantGeneral;
//		vSignatures.Parameters.mCompanyAccountantGeneralPosition = mCompanyAccountantGeneralPosition;
//		// Фирма stamp
//		If SelInvoice.PrintWithCompanyStamp Тогда
//			If vStampIsSet Тогда
//				vSignatures.Drawings.Stamp.Print = True;
//				vSignatures.Drawings.Stamp.Picture = vStamp;
//			Else
//				vSignatures.Drawings.Delete(vSignatures.Drawings.Stamp);
//			EndIf;
//			If vDirectorSignatureIsSet Тогда
//				vSignatures.Drawings.DirectorSignature.Print = True;
//				vSignatures.Drawings.DirectorSignature.Picture = vDirectorSignature;
//			Else
//				vSignatures.Drawings.Delete(vSignatures.Drawings.DirectorSignature);
//			EndIf;
//			If vAccountantGeneralSignatureIsSet Тогда
//				vSignatures.Drawings.AccountantGeneralSignature.Print = True;
//				vSignatures.Drawings.AccountantGeneralSignature.Picture = vAccountantGeneralSignature;
//			Else
//				vSignatures.Drawings.Delete(vSignatures.Drawings.AccountantGeneralSignature);
//			EndIf;
//		EndIf;
//		// Form text
//		vSignatures.Parameters.mFormText = TrimR(SelObjectPrintForm.FormText);
//		// Put signatures	
//		vFooterAreas.Add(vSignatures);
//	Else
//		If SelInvoice.PrintWithCompanyStamp Тогда
//			vSignatures = vTemplate.GetArea("ManagerSignatureWithStamp");
//		Else
//			vSignatures = vTemplate.GetArea("ManagerSignature");
//		EndIf;
//		mPosition = "Менеджер";
//		mEmployee = "";
//		If ЗначениеЗаполнено(ПараметрыСеанса.ТекПользователь) Тогда
//			If НЕ IsBlankString(ПараметрыСеанса.ТекПользователь.Должность) Тогда
//				mPosition = ПараметрыСеанса.ТекПользователь.Должность;
//			EndIf;
//					EndIf;
//		vSignatures.Parameters.mRemarks = TrimAll(SelInvoice.Примечания);
//		vSignatures.Parameters.mPosition = mPosition;
//		vSignatures.Parameters.mEmployee = mEmployee;
//		// Фирма stamp and manager's Подпись
//		If SelInvoice.PrintWithCompanyStamp Тогда
//			If vSignatureIsSet Тогда
//				vSignatures.Drawings.Подпись.Print = True;
//				vSignatures.Drawings.Подпись.Picture = vSignature;
//			Else
//				vSignatures.Drawings.Delete(vSignatures.Drawings.Подпись);
//			EndIf;
//			If vStampIsSet Тогда
//				vSignatures.Drawings.ManagerStamp.Print = True;
//				vSignatures.Drawings.ManagerStamp.Picture = vStamp;
//			Else
//				vSignatures.Drawings.Delete(vSignatures.Drawings.ManagerStamp);
//			EndIf;
//		EndIf;
//		// Form text
//		vSignatures.Parameters.mFormText = TrimR(SelObjectPrintForm.FormText);
//		// Put signatures	
//		vFooterAreas.Add(vSignatures);
//	EndIf;
//	
//	// Group by services by the accommodation conditions
//	vConditions = vServices.Copy();
//	vConditions.GroupBy("ВидРазмещения, ТипНомера, Ресурс, DateTimeFrom, DateTimeTo, Клиент, RoomQuantity", );
//	vConditions.GroupBy("ВидРазмещения, ТипНомера, Ресурс, DateTimeFrom, DateTimeTo", "RoomQuantity");
//	For Each vConditionsRow In vConditions Do
//		// Select services for the each condition
//		vRowsArray = vServices.FindRows(New Structure("ВидРазмещения, ТипНомера, Ресурс, DateTimeFrom, DateTimeTo", 
//		                                vConditionsRow.ВидРазмещения, vConditionsRow.ТипНомера, 
//		                                vConditionsRow.Ресурс, 
//		                                vConditionsRow.DateTimeFrom, vConditionsRow.DateTimeTo));
//		vCndServices = vServices.CopyColumns();
//		For Each vRowElement In vRowsArray Do
//			vCndServicesRow = vCndServices.Add();
//			FillPropertyValues(vCndServicesRow, vRowElement);
//		EndDo;
//		
//		vGuests = vCndServices.Copy();
//		vGuests.GroupBy("Клиент", );
//		vGuests.Sort("Клиент");
//		vGuestNames = "";
//		For Each vGuestsRow In vGuests Do
//			If ЗначениеЗаполнено(vGuestsRow.Клиент) Тогда
//				If IsBlankString(vGuestNames) Тогда
//					vGuestNames = TrimAll(vGuestsRow.Клиент);
//				Else
//					vGuestNames = vGuestNames + ", " + TrimAll(vGuestsRow.Клиент);
//				EndIf;
//			EndIf;
//		EndDo;
//	
//		For Each vSrvRow In vCndServices Do
//			vSrvRow.УчетнаяДата = BegOfDay(SelInvoice.ДатаДок);
//			vSrvRow.Клиент = Справочники.Клиенты.EmptyRef();
//			vSrvRow.КоличествоЧеловек = 0;
//			vSrvRow.ВидРазмещения = Справочники.ВидыРазмещения.EmptyRef();
//			vSrvRow.ТипНомера = Справочники.ТипыНомеров.EmptyRef();
//			vSrvRow.НомерРазмещения = Справочники.НомернойФонд.EmptyRef();
//			vSrvRow.Ресурс = Справочники.Ресурсы.EmptyRef();
//			vSrvRow.ТипДняКалендаря = Справочники.ТипДневногоКалендаря.EmptyRef();
//			vSrvRow.DateTimeFrom = Неопределено;
//			vSrvRow.DateTimeTo = Неопределено;
//			If SelGroupBy = "InPrice" Or SelGroupBy = "All" Тогда
//				If ЗначениеЗаполнено(vAccommodationService) And vAccommodationServiceVATRate = vSrvRow.СтавкаНДС Тогда
//					If SelGroupBy = "InPrice" Тогда
//						// Reset "is in price" flag if necessary
//						If ЗначениеЗаполнено(vSrvRow.Услуга) And vSrvRow.Услуга.DoNotGroupIntoRoomRateOnPrint Тогда
//							vSrvRow.IsInPrice = False;
//						EndIf;
//						If НЕ vSrvRow.IsRoomRevenue And vSrvRow.IsInPrice Тогда
//							vSrvRow.Услуга = vAccommodationService;
//							vSrvRow.Примечания = vAccommodationRemarks;
//							vSrvRow.Количество = 0;
//							vSrvRow.Цена = 0;
//						ElsIf vSrvRow.IsRoomRevenue And vSrvRow.IsInPrice Тогда
//							If vSrvRow.Услуга.RoomRevenueAmountsOnly Тогда
//								vSrvRow.Количество = 0;
//							EndIf;
//							vSrvRow.Услуга = vAccommodationService;
//							vSrvRow.Примечания = vAccommodationRemarks;
//							vSrvRow.Цена = 0;
//						EndIf;
//					ElsIf SelGroupBy = "All" Тогда
//						If НЕ vSrvRow.IsRoomRevenue Тогда
//							vSrvRow.Услуга = vAccommodationService;
//							vSrvRow.Примечания = vAccommodationRemarks;
//							vSrvRow.Количество = 0;
//							vSrvRow.Цена = 0;
//						Else
//							If vSrvRow.Услуга.RoomRevenueAmountsOnly Тогда
//								vSrvRow.Количество = 0;
//							EndIf;
//							vSrvRow.Услуга = vAccommodationService;
//							vSrvRow.Примечания = vAccommodationRemarks;
//							vSrvRow.Цена = 0;
//						EndIf;
//					EndIf;
//				EndIf;
//			EndIf;
//		EndDo;
//		vCndServices.GroupBy("Услуга, Примечания, СтавкаНДС", "Сумма, СуммаНДС, Цена, Количество, СуммаКомиссии");
//		// Recalculate price for all services and delete zero sum rows
//		i = 0;
//		While i < vCndServices.Count() Do
//			vSrvRow = vCndServices.Get(i);
//			If vSrvRow.Сумма = 0 And (SelGroupBy = "InPrice" Or SelGroupBy = "All") Тогда
//				vCndServices.Delete(i);
//			Else
//				vSrvRow.СуммаНДС = cmCalculateVATSum(vSrvRow.СтавкаНДС, vSrvRow.Сумма);
//				vSrvRow.Цена = cmRecalculatePrice(vSrvRow.Сумма, vSrvRow.Количество);
//				i = i + 1;
//			EndIf;
//		EndDo;
//	
//		// Print condition header
//		vPeriodStr = Format(vConditionsRow.DateTimeFrom, "DF=dd.MM.yy") + " - " + Format(vConditionsRow.DateTimeTo, "DF=dd.MM.yy");
//		If BegOfDay(vConditionsRow.DateTimeFrom) = BegOfday(vConditionsRow.DateTimeTo) Тогда
//			vPeriodStr = Format(vConditionsRow.DateTimeFrom, "DF='dd.MM.yy'") + ", " + Format(vConditionsRow.DateTimeFrom, "DF='HH:mm'") + " - " + Format(vConditionsRow.DateTimeTo, "DF='HH:mm'");
//		EndIf;
//		vRStr = "";
//		If ЗначениеЗаполнено(vConditionsRow.ТипНомера) Тогда
//			If Find(vParameter, "NO_RTYPE") = 0 Тогда
//				vRStr = vRStr + vConditionsRow.ТипНомера.GetObject().pmGetRoomTypeDescription(SelLanguage);
//			EndIf;
//		ElsIf ЗначениеЗаполнено(vConditionsRow.Ресурс) Тогда
//			If Find(vParameter, "NO_RESOURCE") = 0 Тогда
//				vRStr = vRStr + vConditionsRow.Ресурс.GetObject().pmGetResourceDescription(SelLanguage);
//			EndIf;
//		EndIf;
//		mCondition = ?(ЗначениеЗаполнено(vConditionsRow.DateTimeFrom), vPeriodStr, "") + 
//				     ?(IsBlankString(vRStr), "" , ?(ЗначениеЗаполнено(vConditionsRow.DateTimeFrom), ", " + vRStr, vRStr)) + 
//		             ?(IsBlankString(vGuestNames), "", ", " + vGuestNames);
//		If Left(mCondition, 1) = "," Тогда
//			mCondition = Mid(mCondition, 3);
//		EndIf;
//					 
//		// Set client area parameters
//		vClient.Parameters.mClient = mCondition;
//		// Put client area
//		vSpreadsheet.Put(vClient);
//		For Each vSrvRow In vCndServices Do
//			// Fill row parameters
//			mPrice = vSrvRow.Цена;
//			mSum = vSrvRow.Сумма;
//			If Round(vSrvRow.Количество, 3) <> vSrvRow.Количество Тогда
//				mQuantity = ?(vSrvRow.Количество = 0, "", Format(vSrvRow.Количество, "ND=17; NFD=3"));
//			Else
//				mQuantity = ?(vSrvRow.Количество = 0, "", String(vSrvRow.Количество));
//			EndIf;
//			If ЗначениеЗаполнено(vSrvRow.Услуга) Тогда
//				If vSrvRow.Количество <> 0 Тогда
//					vServiceObj = vSrvRow.Услуга.GetObject();
//					If vConditionsRow.RoomQuantity <> 0 And 
//					   ЗначениеЗаполнено(vAccommodationService) And vSrvRow.Услуга = vAccommodationService And 
//					   vConditionsRow.RoomQuantity > 1 Тогда
//						mQuantity = Format(vConditionsRow.RoomQuantity, "ND=10; NFD=0; NG=") + "*" + vServiceObj.pmGetServiceQuantityPresentation(vSrvRow.Количество/vConditionsRow.RoomQuantity, SelLanguage);
//					Else
//						mQuantity = vServiceObj.pmGetServiceQuantityPresentation(vSrvRow.Количество, SelLanguage);
//					EndIf;
//				EndIf;
//			EndIf;
//			If ExtraInvoice Тогда
//				If Services.Count() = 1 Тогда
//					If vSrvRow.Количество = 1 Тогда
//						mQuantity = Format(vSrvRow.Количество, "ND=17; NFD=0");
//					EndIf;
//				EndIf;
//			EndIf;
//			mDescription = Chars.Tab + StrReplace(TrimAll(vSrvRow.Примечания), Chars.LF, Chars.LF + Chars.Tab + Chars.Tab);
//			
//			vRow.Parameters.mPrice = Format(mPrice, "ND=17; NFD=2");
//			vRow.Parameters.mQuantity = mQuantity;
//			vRow.Parameters.mDescription = mDescription;
//			vRow.Parameters.mSum = Format(mSum, "ND=17; NFD=2");
//			// Put row
//			If НЕ IsBlankString(mSum) Тогда
//				// Check if we can print footer completely
//				If (vConditions.IndexOf(vConditionsRow) + 1) = vConditions.Count() And 
//				   (vCndServices.IndexOf(vSrvRow) + 1) = vCndServices.Count() Тогда
//					vFooterAreas.Вставить(0, vRow);
//					If НЕ vSpreadsheet.CheckPut(vFooterAreas) Тогда
//						vSpreadsheet.PutHorizontalPageBreak();
//						vSpreadsheet.Put(vTableHeader);
//					EndIf;
//					vFooterAreas.Delete(0);
//				Else
//					If НЕ vSpreadsheet.CheckPut(vRow) Тогда
//						vSpreadsheet.PutHorizontalPageBreak();
//						vSpreadsheet.Put(vTableHeader);
//					EndIf;
//				EndIf;
//				vSpreadsheet.Put(vRow);
//			EndIf;
//		EndDo;
//	EndDo;
//	
//	// Put footer areas
//	For Each vFooterArea In vFooterAreas Do
//		vSpreadsheet.Put(vFooterArea);
//	EndDo;
//
//	// Setup default attributes
//	cmSetDefaultPrintFormSettings(vSpreadsheet, PageOrientation.Portrait, True, , True);
//	// Check authorities
//	cmSetSpreadsheetProtection(vSpreadsheet);
//КонецПроцедуры //pmPrintInvoiceShort
//
////-----------------------------------------------------------------------------
//Процедура pmPrintInvoiceHotelProduct(vSpreadsheet, SelLanguage, SelGroupBy, SelObjectPrintForm, mInvoiceNumber) Экспорт
//	SelInvoice = ThisObject;
//	
//	// Basic checks
//	vHotel = SelInvoice.Гостиница;
//	If НЕ ЗначениеЗаполнено(vHotel) Тогда
//		ВызватьИсключение "Не задана гостиница!";
//		Return;
//	EndIf;
//	vCompany = SelInvoice.Фирма;
//	If НЕ ЗначениеЗаполнено(vCompany) Тогда
//		ВызватьИсключение "Не задана фирма!";
//		Return;
//	EndIf;
//	vAccount = SelInvoice.BankAccount;
//	If НЕ ЗначениеЗаполнено(vAccount) Тогда
//		ВызватьИсключение "Не задан расчетный счет фирмы!";
//		Return;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(SelLanguage) Тогда
//		SelLanguage = ПараметрыСеанса.ТекЛокализация;
//	EndIf;
//	
//	// Choose template
//	vSpreadsheet.Clear();
//	If ЗначениеЗаполнено(SelLanguage) Тогда
//		If SelLanguage = Справочники.Локализация.EN Тогда
//			vTemplate = SelInvoice.GetTemplate("InvoiceHotelProductsEn");
//		ElsIf SelLanguage = Справочники.Локализация.DE Тогда
//			vTemplate = SelInvoice.GetTemplate("InvoiceHotelProductsDe");
//		ElsIf SelLanguage = Справочники.Локализация.RU Тогда
//			vTemplate = SelInvoice.GetTemplate("InvoiceHotelProductsRu");
//		Else
//			ВызватьИсключение "ru='Не найден шаблон печатной формы акта для языка " + SelLanguage.Code  ;
//			Return;
//		EndIf;
//	Else
//		vTemplate = SelInvoice.GetTemplate("InvoiceHotelProductsRu");
//	EndIf;
//	// Load external template if any
//	vExtTemplate = cmReadExternalSpreadsheetDocumentTemplate(SelObjectPrintForm);
//	If vExtTemplate <> Неопределено Тогда
//		vTemplate = vExtTemplate;
//	EndIf;
//	
//	// Load pictures
//	vLogoIsSet = False;
//	vLogo = New Picture;
//	If ЗначениеЗаполнено(SelInvoice.Гостиница) Тогда
//		If SelInvoice.Гостиница.Logo <> Неопределено Тогда
//			vLogo = SelInvoice.Гостиница.Logo.Get();
//			If vLogo = Неопределено Тогда
//				vLogo = New Picture;
//			Else
//				vLogoIsSet = True;
//			EndIf;
//		EndIf;
//	EndIf;
//	vStampIsSet = False;
//	vStamp = New Picture;
//	If ЗначениеЗаполнено(SelInvoice.Фирма) Тогда
//		If SelInvoice.Фирма.Stamp <> Неопределено Тогда
//			vStamp = SelInvoice.Фирма.Stamp.Get();
//			If vStamp = Неопределено Тогда
//				vStamp = New Picture;
//			Else
//				vStampIsSet = True;
//			EndIf;
//		EndIf;
//	EndIf;
//	vSignatureIsSet = False;
//	vSignature = New Picture;
//	If ЗначениеЗаполнено(ПараметрыСеанса.ТекПользователь) Тогда
//		If ПараметрыСеанса.ТекПользователь.Подпись <> Неопределено Тогда
//			vSignature = ПараметрыСеанса.ТекПользователь.Подпись.Get();
//			If vSignature = Неопределено Тогда
//				vSignature = New Picture;
//			Else
//				vSignatureIsSet = True;
//			EndIf;
//		EndIf;
//	EndIf;
//	vDirectorSignatureIsSet = False;
//	vDirectorSignature = New Picture;
//	If SelInvoice.Фирма.DirectorSignature <> Неопределено Тогда
//		vDirectorSignature = SelInvoice.Фирма.DirectorSignature.Get();
//		If vDirectorSignature = Неопределено Тогда
//			vDirectorSignature = New Picture;
//		Else
//			vDirectorSignatureIsSet = True;
//		EndIf;
//	EndIf;
//	vAccountantGeneralSignatureIsSet = False;
//	vAccountantGeneralSignature = New Picture;
//	If SelInvoice.Фирма.AccountantGeneralSignature <> Неопределено Тогда
//		vAccountantGeneralSignature = SelInvoice.Фирма.AccountantGeneralSignature.Get();
//		If vAccountantGeneralSignature = Неопределено Тогда
//			vAccountantGeneralSignature = New Picture;
//		Else
//			vAccountantGeneralSignatureIsSet = True;
//		EndIf;
//	EndIf;
//	
//	// Header
//	vRubHeader = False;
//	If SelInvoice.ВалютаРасчетов.Code = 643 And vHotel.Гражданство.Code = 643 Тогда
//		vRubHeader = True;
//	EndIf;
//	
//	// Гостиница
//	vHotelObj = vHotel.GetObject();
//	mHotelPrintName = vHotelObj.pmGetHotelPrintName(SelLanguage);
//	mHotelPostAddressPresentation = vHotelObj.pmGetHotelPostAddressPresentation(SelLanguage);
//	vHotelPhones = TrimAll(vHotel.Телефоны);
//	vHotelFax = TrimAll(vHotel.Fax);
//	mHotelPhones = vHotelPhones + ?(IsBlankString(vHotelFax), "", ", факс " + vHotelFax);
//	mHotelEMail = TrimAll(vHotel.EMail);
//	
//	// Фирма
//	vCompanyObj = vCompany.GetObject();
//	vCompanyLegacyName = vCompanyObj.pmGetCompanyPrintName(SelLanguage);
//	vCompanyLegacyAddress = vCompanyObj.pmGetCompanyLegacyAddressPresentation(SelLanguage);
//	vCompanyPostAddress = vCompanyObj.pmGetCompanyPostAddressPresentation(SelLanguage);
//	If vCompanyPostAddress = vCompanyLegacyAddress Тогда
//		vCompanyPostAddress = "";
//	EndIf;
//	mCompanyTIN = TrimAll(vCompany.ИНН);
//	mCompanyKPP = TrimAll(vCompany.KPP);
//	vCompanyTIN = " ИНН " + mCompanyTIN + ?(IsBlankString(mCompanyKPP), "", "/" + mCompanyKPP);
//	vCompanyPhones = TrimAll(vCompany.Телефоны) + ?(IsBlankString(vCompany.Fax), "", " факс " + TrimAll(vCompany.Fax));
//	mCompany = TrimAll(vCompanyLegacyName + vCompanyTIN + Chars.LF + vCompanyLegacyAddress + Chars.LF + ?(IsBlankString(vCompanyPostAddress), "", vCompanyPostAddress + Chars.LF) + vCompanyPhones);
//	
//	// Invoice date and number
//	If vCompany.UseGroupCodeAsInvoiceNumberPrefix Тогда
//		If vCompany.PrintInvoiceAndSettlementNumbersWithPrefixes Тогда
//			vCompanyPrefix = TrimAll(vCompany.Prefix);
//			If НЕ IsBlankString(vCompanyPrefix) Тогда
//				mInvoiceNumber = vCompanyPrefix + cmRemoveLeadingZeroes(SelInvoice.НомерДока);
//			Else
//				mInvoiceNumber = cmRemoveLeadingZeroes(SelInvoice.НомерДока);
//			EndIf;
//		Else
//			vHotelPrefix = SelInvoice.Гостиница.GetObject().pmGetPrefix();
//			If НЕ IsBlankString(vHotelPrefix) And SelInvoice.Гостиница.ShowHotelPrefixBeforeGroupCode Тогда
//				mInvoiceNumber = vHotelPrefix + cmRemoveLeadingZeroes(SelInvoice.НомерДока);
//			Else
//				mInvoiceNumber = cmRemoveLeadingZeroes(SelInvoice.НомерДока);
//			EndIf;
//		EndIf;
//	Else
//		mInvoiceNumber = ?(vCompany.PrintInvoiceAndSettlementNumbersWithPrefixes, TrimAll(SelInvoice.НомерДока), cmGetDocumentNumberPresentation(SelInvoice.НомерДока));
//	EndIf;
//	mInvoiceDate = cmGetDocumentDatePresentation(SelInvoice.ДатаДок);
//	
//	vTableHeader = vTemplate.GetArea("TableHeader");
//	
//	// Print different invoice headers for invoices in RUR and Russia base country and other currencies/countries
//	If vRubHeader Тогда
//		vHeader = vTemplate.GetArea("Header");
//		
//		mCompanyPaymentAttributes = vCompanyLegacyName;
//		mCompanyBank = "";
//		mCompanyBankAcount = "";
//		mCompanyBankBIC = "";
//		mCompanyBankCorrAccount = "";
//		If vAccount.IsDirectPayments Тогда
//			mCompanyBank = TrimAll(vAccount.НазваниеБанка) + " " + TrimAll(vAccount.ГородБанка);
//			
//			mCompanyBankAccount = TrimAll(vAccount.НомерСчета);
//			mCompanyBankBIC = TrimAll(vAccount.БИКБанка);
//			mCompanyBankCorrAccount = TrimAll(vAccount.КорСчет);
//		Else
//			mCompanyPaymentAttributes = mCompanyPaymentAttributes + " р/с " + TrimAll(vAccount.НомерСчета);
//			mCompanyPaymentAttributes = mCompanyPaymentAttributes + " в " + TrimAll(vAccount.НазваниеБанка);
//			mCompanyPaymentAttributes = mCompanyPaymentAttributes + " " + TrimAll(vAccount.ГородБанка);
//		
//			mCompanyBank = TrimAll(vAccount.CorrBankName);
//			mCompanyBank = mCompanyBank + TrimAll(vAccount.CorrBankCity);
//			
//			mCompanyBankAccount = TrimAll(vAccount.КорСчет);
//			mCompanyBankBIC = TrimAll(vAccount.CorrBankBIC);
//			mCompanyBankCorrAccount = TrimAll(vAccount.CorrBankCorrAccountNumber);
//		EndIf;
//		If НЕ IsBlankString(vAccount.Получатель) Тогда
//			mCompanyPaymentAttributes = TrimAll(vAccount.Получатель);
//		EndIf;
//		// Контрагент
//		If SelInvoice.Контрагент = vHotel.IndividualsCustomer Тогда
//			// Use contact person as Контрагент
//			If НЕ IsBlankString(SelInvoice.КонтактноеЛицо) Тогда
//				mCustomer = TrimAll(SelInvoice.КонтактноеЛицо);
//			Else				
//				vClientRef = Справочники.Клиенты.EmptyRef();
//				// Use guest group client as Контрагент
//				If ЗначениеЗаполнено(SelInvoice.ГруппаГостей) And ЗначениеЗаполнено(SelInvoice.ГруппаГостей.Клиент) Тогда
//					vClientRef = SelInvoice.ГруппаГостей.Клиент;
//				// Use first client as Контрагент
//				Else
//					For Each vRow In SelInvoice.Услуги Do
//						If ЗначениеЗаполнено(vRow.Клиент) Тогда
//							vClientRef = vRow.Клиент;
//							Break;
//						EndIf;
//					EndDo;
//				EndIf;
//				vCustomer = vClientRef;
//				vCustomerLegacyName = "";
//				vCustomerLegacyAddress = "";
//				vCustomerTIN = "";
//				vCustomerPhones = "";
//				If ЗначениеЗаполнено(vClientRef) Тогда
//					vCustomerLegacyName = TrimAll(vClientRef.FullName);
//					vCustomerLegacyAddress = cmGetAddressPresentation(vClientRef.Address);
//					vCustomerTIN = "";
//					vCustomerKPP = "";
//					// Fax and E-Mail
//					vCustomerPhones = TrimAll(vClientRef.Телефон);
//					vCustomerFax = TrimAll(vClientRef.Fax);
//					vCustomerPhones = vCustomerPhones + ?(IsBlankString(vCustomerFax), "", " факс " + vCustomerFax);
//				EndIf;
//				mCustomer = TrimAll(vCustomerLegacyName + vCustomerTIN + Chars.LF + vCustomerLegacyAddress + Chars.LF + vCustomerPhones);
//			EndIf;
//			// Contract
//			mContract = "";
//		Else
//			vCustomer = SelInvoice.Контрагент;
//			vCustomerLegacyName = "";
//			vCustomerLegacyAddress = "";
//			vCustomerPostAddress = "";
//			vCustomerTIN = "";
//			vCustomerPhones = "";
//			If ЗначениеЗаполнено(vCustomer) Тогда
//				vCustomerLegacyName = TrimAll(vCustomer.ЮрИмя);
//				If IsBlankString(vCustomerLegacyName) Тогда
//					vCustomerLegacyName = TrimAll(vCustomer.Description);
//				EndIf;
//				vCustomerLegacyAddress = cmGetAddressPresentation(vCustomer.LegacyAddress);
//				vCustomerPostAddress = cmGetAddressPresentation(vCustomer.PostAddress);
//				If vCustomerPostAddress = vCustomerLegacyAddress Тогда
//					vCustomerPostAddress = "";
//				EndIf;
//				vCustomerTIN = TrimAll(vCustomer.ИНН);
//				vCustomerKPP = TrimAll(vCustomer.KPP);
//				vCustomerTIN = ", ИНН " + vCustomerTIN + ?(IsBlankString(vCustomerKPP), "", "/" + vCustomerKPP);
//				// Fax and E-Mail
//				vCustomerPhones = TrimAll(vCustomer.Телефон);
//				vCustomerFax = TrimAll(vCustomer.Fax);
//				vCustomerPhones = vCustomerPhones + ?(IsBlankString(vCustomerFax), "", ", факс " + vCustomerFax);
//			EndIf;
//			mCustomer = TrimAll(vCustomerLegacyName + vCustomerTIN + Chars.LF + vCustomerLegacyAddress + Chars.LF + ?(IsBlankString(vCustomerPostAddress), "", vCustomerPostAddress + Chars.LF) + vCustomerPhones);
//			// Contract
//			mContract = "";
//			If ЗначениеЗаполнено(SelInvoice.Договор) Тогда
//				mContract = TrimAll(SelInvoice.Договор.Description);
//			EndIf;
//		EndIf;
//		// Guest group code
//		mGuestGroup = "";
//		vHotelPrefix = SelInvoice.Гостиница.GetObject().pmGetPrefix();
//		If ЗначениеЗаполнено(SelInvoice.ГруппаГостей) Тогда
//			mGuestGroup = Format(SelInvoice.ГруппаГостей.Code, "ND=12; NFD=0; NG=");
//			If НЕ IsBlankString(SelInvoice.ГруппаГостей.Description) Тогда
//				mGuestGroup = mGuestGroup + " - " + TrimAll(SelInvoice.ГруппаГостей.Description);
//			EndIf;
//			If НЕ IsBlankString(vHotelPrefix) And SelInvoice.Гостиница.ShowHotelPrefixBeforeGroupCode Тогда
//				mGuestGroup = vHotelPrefix + mGuestGroup;
//			EndIf;
//		Else
//			vGroups = SelInvoice.Услуги.Unload(, "ГруппаГостей");
//			vGroups.GroupBy("ГруппаГостей", );
//			For Each vGroupsRow In vGroups Do
//				If ЗначениеЗаполнено(vGroupsRow.ГруппаГостей) Тогда
//					vGuestGroupCode = Format(vGroupsRow.ГруппаГостей.Code, "ND=12; NFD=0; NG=");
//					If НЕ IsBlankString(vHotelPrefix) And SelInvoice.Гостиница.ShowHotelPrefixBeforeGroupCode Тогда
//						vGuestGroupCode = vHotelPrefix + vGuestGroupCode;
//					EndIf;
//					If IsBlankString(mGuestGroup) Тогда
//						mGuestGroup = vGuestGroupCode;
//					Else
//						mGuestGroup = mGuestGroup + ", " + vGuestGroupCode;
//					EndIf;
//				EndIf;
//			EndDo;
//		EndIf;
//		// Currency
//		mAccountingCurrency = "";
//		If ЗначениеЗаполнено(SelInvoice.ВалютаРасчетов) Тогда
//			vCurrencyObj = SelInvoice.ВалютаРасчетов.GetObject();
//			mAccountingCurrency = vCurrencyObj.pmGetCurrencyDescription(SelLanguage);
//		EndIf;
//		// Parent document
//		mParentDoc = String(SelInvoice.ДокОснование);
//		mFullInvoiceNumber = Trimall(SelInvoice.НомерДока);
//		// Set parameters and put report section
//		vHeader.Parameters.mHotelPrintName = mHotelPrintName;
//		vHeader.Parameters.mHotelPostAddressPresentation = mHotelPostAddressPresentation;
//		vHeader.Parameters.mHotelPhones = mHotelPhones;
//		vHeader.Parameters.mHotelEMail = mHotelEMail;
//		vHeader.Parameters.mInvoiceNumber = mInvoiceNumber;
//		vHeader.Parameters.mFullInvoiceNumber = mFullInvoiceNumber;
//		vHeader.Parameters.mInvoiceDate = mInvoiceDate;
//		If SelInvoice.ВалютаРасчетов = vHotel.BaseCurrency Тогда
//			vHeader.Parameters.mCompany = mCompany;
//			vHeader.Parameters.mCompanyTIN = mCompanyTIN;
//			vHeader.Parameters.mCompanyKPP = mCompanyKPP;
//			vHeader.Parameters.mCompanyBankBIC = mCompanyBankBIC;
//			vHeader.Parameters.mCompanyBankCorrAccount = mCompanyBankCorrAccount;
//		EndIf;
//		vHeader.Parameters.mCompanyPaymentAttributes = mCompanyPaymentAttributes;
//		vHeader.Parameters.mCompanyBank = mCompanyBank;
//		vHeader.Parameters.mCompanyBankAccount = mCompanyBankAccount;
//		vHeader.Parameters.mCustomer = mCustomer;
//		vHeader.Parameters.mInvoiceEMail = TrimAll(SelInvoice.EMail);
//		vHeader.Parameters.mContract = mContract;
//		vHeader.Parameters.mGuestGroup = mGuestGroup;
//		vHeader.Parameters.mAccountingCurrency = mAccountingCurrency;
//		vHeader.Parameters.mParentDoc = mParentDoc;
//		// Logo
//		If vLogoIsSet Тогда
//			vHeader.Drawings.Logo.Print = True;
//			vHeader.Drawings.Logo.Picture = vLogo;
//		Else
//			vHeader.Drawings.Delete(vHeader.Drawings.Logo);
//		EndIf;
//		// Put header		
//		vSpreadsheet.Put(vHeader);
//		vSpreadsheet.Put(vTableHeader);
//	Else
//		vHeader1 = vTemplate.GetArea("HeaderCurrency1");
//		
//		If НЕ IsBlankString(vAccount.Получатель) Тогда
//			mCompany = TrimAll(vAccount.Получатель);
//		EndIf;
//		
//		mCompanyBank = TrimAll(TrimAll(vAccount.НазваниеБанка) + " " + TrimAll(vAccount.ГородБанка));
//		mCompanyBankAccount = TrimAll(vAccount.НомерСчета);
//		If НЕ IsBlankString(vAccount.БИКБанка) Тогда
//			mCompanyBank = mCompanyBank + Chars.LF + "БИК " + TrimAll(vAccount.БИКБанка);
//		EndIf;
//		If НЕ IsBlankString(vAccount.КорСчет) Тогда
//			mCompanyBank = mCompanyBank + Chars.LF + "Корр. сч. № " + TrimAll(vAccount.КорСчет);
//		EndIf;
//		If НЕ IsBlankString(vAccount.ИННБанка) Тогда
//			mCompanyBank = mCompanyBank + Chars.LF + TrimAll(vAccount.ИННБанка);
//		EndIf;
//		If НЕ IsBlankString(vAccount.BankSWIFTCode) Тогда
//			mCompanyBank = mCompanyBank + Chars.LF + "SWIFT " + TrimAll(vAccount.BankSWIFTCode);
//		EndIf;
//		
//		// Set parameters and put report section
//		vHeader1.Parameters.mHotelPrintName = mHotelPrintName;
//		vHeader1.Parameters.mHotelPostAddressPresentation = mHotelPostAddressPresentation;
//		vHeader1.Parameters.mHotelPhones = mHotelPhones;
//		vHeader1.Parameters.mHotelEMail = mHotelEMail;
//		vHeader1.Parameters.mInvoiceNumber = mInvoiceNumber;
//		vHeader1.Parameters.mInvoiceDate = mInvoiceDate;
//		vHeader1.Parameters.mCompany = mCompany;
//		vHeader1.Parameters.mCompanyBankAccount = mCompanyBankAccount;
//		vHeader1.Parameters.mCompanyBank = mCompanyBank;
//		// Logo
//		If vLogoIsSet Тогда
//			vHeader1.Drawings.LogoCurrency.Print = True;
//			vHeader1.Drawings.LogoCurrency.Picture = vLogo;
//		Else
//			vHeader1.Drawings.Delete(vHeader1.Drawings.LogoCurrency);
//		EndIf;
//		// Put header1		
//		vSpreadsheet.Put(vHeader1);
//		
//		// Put correspondent bank header
//		If НЕ vAccount.IsDirectPayments Тогда
//			vCorrBankHeader = vTemplate.GetArea("CorrBank");
//			
//			mCompanyCorrBank = TrimAll(TrimAll(vAccount.CorrBankName) + " " + TrimAll(vAccount.CorrBankCity));
//			If НЕ IsBlankString(vAccount.CorrBankBIC) Тогда
//				mCompanyCorrBank = mCompanyCorrBank + Chars.LF + "БИК " + TrimAll(vAccount.CorrBankBIC);
//			EndIf;
//			If НЕ IsBlankString(vAccount.CorrBankCorrAccountNumber) Тогда
//				mCompanyCorrBank = mCompanyCorrBank + "Корр. сч. № " + TrimAll(vAccount.CorrBankCorrAccountNumber);
//			EndIf;
//			If НЕ IsBlankString(vAccount.CorrBankTINCode) Тогда
//				mCompanyCorrBank = mCompanyCorrBank + Chars.LF + TrimAll(vAccount.CorrBankTINCode);
//			EndIf;
//			If НЕ IsBlankString(vAccount.CorrBankSWIFTCode) Тогда
//				mCompanyCorrBank = mCompanyCorrBank + Chars.LF + "'SWIFT " + TrimAll(vAccount.CorrBankSWIFTCode);
//			EndIf;
//			
//			// Set parameters and put report section
//			vCorrBankHeader.Parameters.mCompanyCorrBank = mCompanyCorrBank;
//			
//			// Put corr. bank header
//			vSpreadsheet.Put(vCorrBankHeader);
//		EndIf;
//		
//		// Table header
//		vHeader2 = vTemplate.GetArea("HeaderCurrency2");
//		
//		// Контрагент
//		If SelInvoice.Контрагент = vHotel.IndividualsCustomer Тогда
//			// Use contact person as Контрагент
//			If НЕ IsBlankString(SelInvoice.КонтактноеЛицо) Тогда
//				mCustomer = TrimAll(SelInvoice.КонтактноеЛицо);
//			Else				
//				vClientRef = Справочники.Клиенты.EmptyRef();
//				// Use guest group client as Контрагент
//				If ЗначениеЗаполнено(SelInvoice.ГруппаГостей) And ЗначениеЗаполнено(SelInvoice.ГруппаГостей.Клиент) Тогда
//					vClientRef = SelInvoice.ГруппаГостей.Клиент;
//				// Use first client as Контрагент
//				Else
//					For Each vRow In SelInvoice.Услуги Do
//						If ЗначениеЗаполнено(vRow.Клиент) Тогда
//							vClientRef = vRow.Клиент;
//							Break;
//						EndIf;
//					EndDo;
//				EndIf;
//				vCustomer = vClientRef;
//				vCustomerLegacyName = "";
//				vCustomerLegacyAddress = "";
//				vCustomerTIN = "";
//				vCustomerPhones = "";
//				If ЗначениеЗаполнено(vClientRef) Тогда
//					vCustomerLegacyName = TrimAll(vClientRef.FullName);
//					vCustomerLegacyAddress = cmGetAddressPresentation(vClientRef.Address);
//					vCustomerTIN = "";
//					vCustomerKPP = "";
//					// Fax and E-Mail
//					vCustomerPhones = TrimAll(vClientRef.Телефон);
//					vCustomerFax = TrimAll(vClientRef.Fax);
//					vCustomerPhones = vCustomerPhones + ?(IsBlankString(vCustomerFax), "", ", факс '" + vCustomerFax);
//				EndIf;
//				mCustomer = TrimAll(vCustomerLegacyName + vCustomerTIN + Chars.LF + vCustomerLegacyAddress + Chars.LF + vCustomerPhones);
//			EndIf;
//			// Contract
//			mContract = "";
//		Else
//			vCustomer = SelInvoice.Контрагент;
//			vCustomerLegacyName = "";
//			vCustomerLegacyAddress = "";
//			vCustomerPostAddress = "";
//			vCustomerTIN = "";
//			vCustomerPhones = "";
//			If ЗначениеЗаполнено(vCustomer) Тогда
//				vCustomerLegacyName = TrimAll(vCustomer.ЮрИмя);
//				If IsBlankString(vCustomerLegacyName) Тогда
//					vCustomerLegacyName = TrimAll(vCustomer.Description);
//				EndIf;
//				vCustomerLegacyAddress = cmGetAddressPresentation(vCustomer.LegacyAddress);
//				vCustomerPostAddress = cmGetAddressPresentation(vCustomer.PostAddress);
//				If vCustomerPostAddress = vCustomerLegacyAddress Тогда
//					vCustomerPostAddress = "";
//				EndIf;
//				vCustomerTIN = TrimAll(vCustomer.ИНН);
//				vCustomerKPP = TrimAll(vCustomer.KPP);
//				vCustomerTIN = " ИНН " + vCustomerTIN + ?(IsBlankString(vCustomerKPP), "", "/" + vCustomerKPP);
//				// Fax and E-Mail
//				vCustomerPhones = TrimAll(vCustomer.Телефон);
//				vCustomerFax = TrimAll(vCustomer.Fax);
//				vCustomerPhones = vCustomerPhones + ?(IsBlankString(vCustomerFax), "", ", факс '"+ vCustomerFax);
//			EndIf;
//			mCustomer = TrimAll(vCustomerLegacyName + vCustomerTIN + Chars.LF + vCustomerLegacyAddress + Chars.LF + ?(IsBlankString(vCustomerPostAddress), "", vCustomerPostAddress + Chars.LF) + vCustomerPhones);
//			// Contract
//			mContract = "";
//			If ЗначениеЗаполнено(SelInvoice.Договор) Тогда
//				mContract = TrimAll(SelInvoice.Договор.Description);
//			EndIf;
//		EndIf;
//		// Guest group code
//		mGuestGroup = "";
//		If ЗначениеЗаполнено(SelInvoice.ГруппаГостей) Тогда
//			mGuestGroup = Format(SelInvoice.ГруппаГостей.Code, "ND=12; NFD=0; NG=");
//			If НЕ IsBlankString(SelInvoice.ГруппаГостей.Description) Тогда
//				mGuestGroup = mGuestGroup + " - " + TrimAll(SelInvoice.ГруппаГостей.Description);
//			EndIf;
//		Else
//			vGroups = SelInvoice.Услуги.Unload(, "ГруппаГостей");
//			vGroups.GroupBy("ГруппаГостей", );
//			For Each vGroupsRow In vGroups Do
//				If ЗначениеЗаполнено(vGroupsRow.ГруппаГостей) Тогда
//					vGuestGroupCode = Format(vGroupsRow.ГруппаГостей.Code, "ND=12; NFD=0; NG=");
//					If IsBlankString(mGuestGroup) Тогда
//						mGuestGroup = vGuestGroupCode;
//					Else
//						mGuestGroup = mGuestGroup + ", " + vGuestGroupCode;
//					EndIf;
//				EndIf;
//			EndDo;
//		EndIf;
//		// Currency
//		mAccountingCurrency = "";
//		If ЗначениеЗаполнено(SelInvoice.ВалютаРасчетов) Тогда
//			vCurrencyObj = SelInvoice.ВалютаРасчетов.GetObject();
//			mAccountingCurrency = vCurrencyObj.pmGetCurrencyDescription(SelLanguage);
//		EndIf;
//		// Parent document
//		mParentDoc = String(SelInvoice.ДокОснование);
//		mFullInvoiceNumber = Trimall(SelInvoice.НомерДока);
//		// Set parameters and put report section
//		vHeader2.Parameters.mFullInvoiceNumber = mFullInvoiceNumber;
//		vHeader2.Parameters.mCustomer = mCustomer;
//		vHeader2.Parameters.mInvoiceEMail = TrimAll(SelInvoice.EMail);
//		vHeader2.Parameters.mContract = mContract;
//		vHeader2.Parameters.mGuestGroup = mGuestGroup;
//		vHeader2.Parameters.mAccountingCurrency = mAccountingCurrency;
//		vHeader2.Parameters.mParentDoc = mParentDoc;
//		// Put header		
//		vSpreadsheet.Put(vHeader2);
//		vSpreadsheet.Put(vTableHeader);
//	EndIf;
//	
//	// Get template areas
//	vClient = vTemplate.GetArea("Клиент");
//	vRow = vTemplate.GetArea("Row");
//	
//	// Get all services
//	vServices = SelInvoice.Услуги.Unload();
//	
//	// Change accounting dates for breakfast
//	If НЕ IsBlankString(SelGroupBy) And SelGroupBy <> "ByService" Тогда
//		If vServices.Find(True, "IsRoomRevenue") <> Неопределено Тогда
//			For Each vSrvRow In vServices Do
//				If vSrvRow.IsInPrice And ЗначениеЗаполнено(vSrvRow.Услуга.QuantityCalculationRule) And
//				   vSrvRow.Услуга.QuantityCalculationRule.QuantityCalculationRuleType = Перечисления.QuantityCalculationRuleTypes.Breakfast Тогда
//					If BegOfDay(vSrvRow.УчетнаяДата) > BegOfDay(vSrvRow.DateTimeFrom) Тогда
//						vSrvRow.УчетнаяДата = vSrvRow.УчетнаяДата - 24*3600;
//					EndIf;
//				EndIf;
//			EndDo;
//		EndIf;
//	EndIf;
//	
//	// Join services according to service parameters
//	If НЕ IsBlankString(SelGroupBy) And SelGroupBy <> "ByService" Тогда
//		i = 0;
//		While i < vServices.Count() Do
//			vSrvRow = vServices.Get(i);
//			If НЕ vSrvRow.IsInPrice And ЗначениеЗаполнено(vSrvRow.Услуга.HideIntoServiceOnPrint) Тогда
//				// Try to find service to hide current one to
//				vHideToServices = vServices.FindRows(New Structure("Услуга, УчетнаяДата, Клиент, ТипНомера, НомерРазмещения, Ресурс", vSrvRow.Услуга.HideIntoServiceOnPrint, vSrvRow.УчетнаяДата, vSrvRow.Клиент, vSrvRow.ТипНомера, vSrvRow.НомерРазмещения, vSrvRow.Ресурс));
//				If vHideToServices.Count() = 1 Тогда
//					vSrv2Hide2 = vHideToServices.Get(0);
//					vSrv2Hide2.Сумма = vSrv2Hide2.Сумма + vSrvRow.Сумма;
//					vSrv2Hide2.СуммаНДС = vSrv2Hide2.СуммаНДС + vSrvRow.СуммаНДС;
//					vSrv2Hide2.СуммаСкидки = vSrv2Hide2.СуммаСкидки + vSrvRow.СуммаСкидки;
//					vSrv2Hide2.Цена = cmRecalculatePrice(vSrv2Hide2.Сумма, vSrv2Hide2.Количество);
//					// Delete current service
//					vServices.Delete(i);
//					Continue;
//				EndIf;
//			EndIf;
//			i = i + 1;
//		EndDo;
//	EndIf;
//	
//	// Get accommodation service name
//	vAccommodationService = Неопределено;	
//	vAccommodationRemarks = "";	
//	vAccommodationServiceVATRate = Неопределено;
//	i = 0;
//	While i < vServices.Count() Do
//		vSrvRow = vServices.Get(i);
//		If SelGroupBy = "InPricePerClientPerDay" Or SelGroupBy = "InPricePerDay" Or
//		   SelGroupBy = "AllPerClientPerDay" Or SelGroupBy = "AllPerDay" Or
//		   SelGroupBy = "InPricePerClient" Or SelGroupBy = "InPrice" Or
//		   SelGroupBy = "AllPerClient" Or SelGroupBy = "All" Тогда
//			If vSrvRow.Сумма = 0 Тогда
//				vServices.Delete(i);
//				Continue;
//			EndIf;
//		EndIf;
//		If vAccommodationService = Неопределено And vSrvRow.IsRoomRevenue And НЕ vSrvRow.Услуга.RoomRevenueAmountsOnly Тогда
//			vAccommodationService = vSrvRow.Услуга;
//			vAccommodationServiceVATRate = vSrvRow.СтавкаНДС;
//			vAccommodationRemarks = TrimAll(vSrvRow.Примечания);
//			If SelGroupBy = "InPrice" Or SelGroupBy = "All" Тогда
//				If ЗначениеЗаполнено(vAccommodationService) Тогда
//					vSrvDescr = vAccommodationService.GetObject().pmGetServiceDescription(SelLanguage, False);
//					vSrvGrpDescr = vAccommodationService.GetObject().pmGetServiceDescription(SelLanguage, True);
//					vAccommodationRemarks = StrReplace(vAccommodationRemarks, vSrvDescr, vSrvGrpDescr);
//				EndIf;
//			EndIf;
//		EndIf;
//		i = i + 1;
//	EndDo;
//	
//	// Calculate totals
//	vVATRateTransactions = vServices.Copy();
//	vVATRateTransactions.GroupBy("СтавкаНДС", "Сумма, СуммаНДС");
//	vVATRateTransactions.Clear();
//	
//	vAgentCommission = 0;
//	vTotalSum = 0;
//	vTotalSumNoCommission = 0;
//	vTotalCommissionSum = 0;
//	vTotalVATSumNoCommission = 0;
//	vTotalVATSum = 0;
//	For Each vSrvRow In vServices Do
//		If vAgentCommission = 0 Тогда
//			vAgentCommission = vSrvRow.КомиссияАгента;
//		EndIf;
//		vTotalSum = vTotalSum + vSrvRow.Сумма;
//		vTotalSumNoCommission = vTotalSumNoCommission + vSrvRow.Сумма - vSrvRow.СуммаКомиссии;
//		vTotalCommissionSum = vTotalCommissionSum + vSrvRow.СуммаКомиссии;
//		vTotalVATSumNoCommission = vTotalVATSumNoCommission + cmCalculateVATSum(vSrvRow.СтавкаНДС, (vSrvRow.Сумма - vSrvRow.СуммаКомиссии));
//		vTotalVATSum = vTotalVatSum + cmCalculateVATSum(vSrvRow.СтавкаНДС, vSrvRow.Сумма);
//		
//		vVATRateTransactionsRow = vVATRateTransactions.Add();
//		vVATRateTransactionsRow.СтавкаНДС = vSrvRow.СтавкаНДС;
//		vVATRateTransactionsRow.СуммаНДС = cmCalculateVATSum(vSrvRow.СтавкаНДС, vSrvRow.Сумма);
//		vVATRateTransactionsRow.Сумма = vSrvRow.Сумма;
//	EndDo;
//	
//	// Build footer
//	vFooterAreas = new Array();
//	vFooter1 = vTemplate.GetArea("Footer1");
//	vCommission = vTemplate.GetArea("Комиссия");
//	vFooter2 = vTemplate.GetArea("Footer2");
//	// Fill parameters
//	mTotalSum = Format(vTotalSum, "ND=17; NFD=2") + " " + mAccountingCurrency;
//	If ЗначениеЗаполнено(vCompany) And vCompany.DoNotPrintVAT Тогда
//		mTotalVATSumNoCommission = "";
//	Else
//		If vTotalVATSumNoCommission <> 0 And 
//		   ЗначениеЗаполнено(SelInvoice.Контрагент) And НЕ SelInvoice.Контрагент.DoNotPostCommission Тогда
//			mTotalVATSum = "В том числе НДС " + Format(vTotalVATSumNoCommission, "ND=17; NFD=2") + " " + mAccountingCurrency;
//		ElsIf vTotalVATSum <> 0 And 
//		      ЗначениеЗаполнено(SelInvoice.Контрагент) And SelInvoice.Контрагент.DoNotPostCommission Тогда
//			mTotalVATSum = "В том числе НДС " + Format(vTotalVATSum, "ND=17; NFD=2") + " " + mAccountingCurrency;
//		Else
//			If ЗначениеЗаполнено(SelInvoice.Фирма) And SelInvoice.Фирма.IsUsingSimpleTaxSystem Тогда
//				mTotalVATSum = "НДС не облагается в связи с применением упрощенной системы налогообложения (п. 2 ст. 346.11 НК РФ)";
//			Else
//				mTotalVATSum = "НДС не облагается";
//			EndIf;
//		EndIf;
//	EndIf;
//	mTotalSumInWords = cmSumInWords(vTotalSum, SelInvoice.ВалютаРасчетов, SelLanguage);
//	// Set parameters
//	vFooter1.Parameters.mTotalSum = mTotalSum;
//	vFooter2.Parameters.mTotalVATSum = mTotalVATSum;
//	vFooter2.Parameters.mTotalSumInWords = mTotalSumInWords;
//	// Put footer
//	vFooterAreas.Add(vFooter1);
//	If vTotalCommissionSum <> 0 And 
//	   ЗначениеЗаполнено(SelInvoice.Контрагент) And НЕ SelInvoice.Контрагент.DoNotPostCommission Тогда
//		mTotalSumInWords = cmSumInWords(vTotalSumNoCommission, SelInvoice.ВалютаРасчетов, SelLanguage);
//		vFooter2.Parameters.mTotalSumInWords = mTotalSumInWords;
//		mSumToBePaid = Format(vTotalSumNoCommission, "ND=17; NFD=2") + " " + mAccountingCurrency;
//		mAgentCommission = vAgentCommission;
//		mTotalCommissionSum = Format(vTotalCommissionSum, "ND=17; NFD=2") + " " + mAccountingCurrency;
//		vCommission.Parameters.mTotalCommissionSum = mTotalCommissionSum;
//		vCommission.Parameters.mAgentCommission = mAgentCommission;
//		vCommission.Parameters.mSumToBePaid = mSumToBePaid;
//		vFooterAreas.Add(vCommission);
//	EndIf;
//	vFooterAreas.Add(vFooter2);
//	
//	// VAT rates table
//	vVATHeaderArea = vTemplate.GetArea("VATHeader");
//	vFooterAreas.Add(vVATHeaderArea);
//	vVATRateTransactions.GroupBy("СтавкаНДС", "Сумма, СуммаНДС");
//	vVATRateTransactions.Sort("СтавкаНДС");
//	For Each vVATRateRow In vVATRateTransactions Do
//		vVATRateRowArea = vTemplate.GetArea("VATRateRow");
//		vVATRateRowArea.Parameters.mVATRate = TrimAll(vVATRateRow.СтавкаНДС);
//		vVATRateRowArea.Parameters.mSumWithoutVAT = Format(vVATRateRow.Сумма - vVATRateRow.СуммаНДС, "ND=17; NFD=2; NZ=");
//		vVATRateRowArea.Parameters.mVATSum = Format(vVATRateRow.СуммаНДС, "ND=17; NFD=2; NZ=");
//		vVATRateRowArea.Parameters.mSumWithVAT = Format(vVATRateRow.Сумма, "ND=17; NFD=2; NZ=");
//		vFooterAreas.Add(vVATRateRowArea);
//	EndDo;
//	
//	// Signatures
//	vSignedByManager = False;
//	If ЗначениеЗаполнено(SelInvoice.Фирма) And SelInvoice.Фирма.InvoiceIsSignedByManager Тогда
//		vSignedByManager = True;
//	EndIf;
//	If НЕ vSignedByManager Тогда
//		If SelInvoice.PrintWithCompanyStamp Тогда
//			vSignatures = vTemplate.GetArea("SignaturesWithStamp");
//		Else
//			vSignatures = vTemplate.GetArea("Signatures");
//		EndIf;
//		mCompanyDirector = TrimAll(vCompany.Director);
//		If НЕ IsBlankString(vCompany.DirectorPosition) Тогда
//			mCompanyDirectorPosition = TrimAll(vCompany.DirectorPosition);
//		Else
//			mCompanyDirectorPosition = "Руководитель";
//		EndIf;
//		mCompanyAccountantGeneral = TrimAll(vCompany.AccountantGeneral);
//		If НЕ IsBlankString(vCompany.AccountantGeneralPosition) Тогда
//			mCompanyAccountantGeneralPosition = TrimAll(vCompany.AccountantGeneralPosition);
//		Else
//			mCompanyAccountantGeneralPosition = "Бухгалтер";
//		EndIf;
//		vSignatures.Parameters.mRemarks = TrimAll(SelInvoice.Примечания);
//		vSignatures.Parameters.mCompanyDirector = mCompanyDirector;
//		vSignatures.Parameters.mCompanyDirectorPosition = mCompanyDirectorPosition;
//		vSignatures.Parameters.mCompanyAccountantGeneral = mCompanyAccountantGeneral;
//		vSignatures.Parameters.mCompanyAccountantGeneralPosition = mCompanyAccountantGeneralPosition;
//		// Фирма stamp
//		If SelInvoice.PrintWithCompanyStamp Тогда
//			If vStampIsSet Тогда
//				vSignatures.Drawings.Stamp.Print = True;
//				vSignatures.Drawings.Stamp.Picture = vStamp;
//			Else
//				vSignatures.Drawings.Delete(vSignatures.Drawings.Stamp);
//			EndIf;
//			If vDirectorSignatureIsSet Тогда
//				vSignatures.Drawings.DirectorSignature.Print = True;
//				vSignatures.Drawings.DirectorSignature.Picture = vDirectorSignature;
//			Else
//				vSignatures.Drawings.Delete(vSignatures.Drawings.DirectorSignature);
//			EndIf;
//			If vAccountantGeneralSignatureIsSet Тогда
//				vSignatures.Drawings.AccountantGeneralSignature.Print = True;
//				vSignatures.Drawings.AccountantGeneralSignature.Picture = vAccountantGeneralSignature;
//			Else
//				vSignatures.Drawings.Delete(vSignatures.Drawings.AccountantGeneralSignature);
//			EndIf;
//		EndIf;
//		// Form text
//		vSignatures.Parameters.mFormText = TrimR(SelObjectPrintForm.FormText);
//		// Put signatures	
//		vFooterAreas.Add(vSignatures);
//	Else
//		If SelInvoice.PrintWithCompanyStamp Тогда
//			vSignatures = vTemplate.GetArea("ManagerSignatureWithStamp");
//		Else
//			vSignatures = vTemplate.GetArea("ManagerSignature");
//		EndIf;
//		mPosition ="Менеджер";
//		mEmployee = "";
//		If ЗначениеЗаполнено(ПараметрыСеанса.ТекПользователь) Тогда
//			If НЕ IsBlankString(ПараметрыСеанса.ТекПользователь.Должность) Тогда
//				mPosition = ПараметрыСеанса.ТекПользователь.Должность;
//			EndIf;
//			If НЕ IsBlankString(ПараметрыСеанса.ТекПользователь.DescriptionTranslations) Тогда
//				mEmployee = ПараметрыСеанса.ТекПользователь.DescriptionTranslations;
//			Else
//				mEmployee = TrimAll(ПараметрыСеанса.ТекПользователь.Description);
//			EndIf;
//		EndIf;
//		vSignatures.Parameters.mRemarks = TrimAll(SelInvoice.Примечания);
//		vSignatures.Parameters.mPosition = mPosition;
//		vSignatures.Parameters.mEmployee = mEmployee;
//		// Фирма stamp and manager's Подпись
//		If SelInvoice.PrintWithCompanyStamp Тогда
//			If vSignatureIsSet Тогда
//				vSignatures.Drawings.Подпись.Print = True;
//				vSignatures.Drawings.Подпись.Picture = vSignature;
//			Else
//				vSignatures.Drawings.Delete(vSignatures.Drawings.Подпись);
//			EndIf;
//			If vStampIsSet Тогда
//				vSignatures.Drawings.ManagerStamp.Print = True;
//				vSignatures.Drawings.ManagerStamp.Picture = vStamp;
//			Else
//				vSignatures.Drawings.Delete(vSignatures.Drawings.ManagerStamp);
//			EndIf;
//		EndIf;
//		// Form text
//		vSignatures.Parameters.mFormText = TrimR(SelObjectPrintForm.FormText);
//		// Put signatures	
//		vFooterAreas.Add(vSignatures);
//	EndIf;
//	
//	// Check if products are specified in services
//	vProductsAreSpecified = False;
//	For Each vServicesRow In vServices Do
//		If ЗначениеЗаполнено(vServicesRow.ПутевкаКурсовка) And НЕ vServicesRow.ПутевкаКурсовка.IsFolder Тогда
//			vProductsAreSpecified = True;
//			Break;
//		EndIf;
//	EndDo;	
//	
//	// Group by services by the accommodation conditions
//	vConditions = vServices.Copy();
//	vConditions.GroupBy("ВидРазмещения, ТипНомера, Ресурс, DateTimeFrom, DateTimeTo" + ?(vProductsAreSpecified, "", ", ПутевкаКурсовка"), );
//	For Each vConditionsRow In vConditions Do
//		// Select services for the each condition
//		vRowsArray = New Array();
//		If vProductsAreSpecified Тогда
//			vRowsArray = vServices.FindRows(New Structure("ВидРазмещения, ТипНомера, Ресурс, DateTimeFrom, DateTimeTo", 
//			                                vConditionsRow.ВидРазмещения, vConditionsRow.ТипНомера, 
//			                                vConditionsRow.Ресурс, 
//			                                vConditionsRow.DateTimeFrom, vConditionsRow.DateTimeTo));
//		Else
//			vRowsArray = vServices.FindRows(New Structure("ВидРазмещения, ТипНомера, Ресурс, DateTimeFrom, DateTimeTo, ПутевкаКурсовка", 
//			                                vConditionsRow.ВидРазмещения, vConditionsRow.ТипНомера, 
//			                                vConditionsRow.Ресурс, 
//			                                vConditionsRow.DateTimeFrom, vConditionsRow.DateTimeTo,
//			                                vConditionsRow.ПутевкаКурсовка));
//		EndIf;
//		vCndServices = vServices.CopyColumns();
//		For Each vRowElement In vRowsArray Do
//			vCndServicesRow = vCndServices.Add();
//			FillPropertyValues(vCndServicesRow, vRowElement);
//		EndDo;
//		
//		vThereAreHotelProducts = False;
//		vHotelProducts = vCndServices.Copy();
//		vHotelProducts.GroupBy("ПутевкаКурсовка", );
//		vHotelProducts.Sort("ПутевкаКурсовка");
//		vHotelProductsList = "";
//		vHotelProductsCount = 0;
//		For Each vHotelProductsRow In vHotelProducts Do
//			If ЗначениеЗаполнено(vHotelProductsRow.ПутевкаКурсовка) Тогда
//				If IsBlankString(vHotelProductsList) Тогда
//					vHotelProductsList = TrimAll(vHotelProductsRow.ПутевкаКурсовка.Description);
//				Else
//					vHotelProductsList = vHotelProductsList + ", " + TrimAll(vHotelProductsRow.ПутевкаКурсовка.Description);
//				EndIf;
//				If НЕ vHotelProductsRow.ПутевкаКурсовка.IsFolder Тогда
//					vThereAreHotelProducts = True;
//					vHotelProductsCount = vHotelProductsCount + 1;
//				EndIf;
//			EndIf;
//		EndDo;
//	
//		For Each vSrvRow In vCndServices Do
//			If vSrvRow.IsRoomRevenue And НЕ vThereAreHotelProducts And 
//			   ЗначениеЗаполнено(vAccommodationService) And vAccommodationService = vSrvRow.Услуга Тогда
//				vHotelProductsCount = vHotelProductsCount + ?(vSrvRow.RoomQuantity > 0, vSrvRow.RoomQuantity, 1);
//			EndIf;
//			If SelGroupBy = "InPrice" Or SelGroupBy = "All" Тогда
//				If ЗначениеЗаполнено(vAccommodationService) And vAccommodationServiceVATRate = vSrvRow.СтавкаНДС Тогда
//					If SelGroupBy = "InPrice" Тогда
//						// Reset "is in price" flag if necessary
//						If ЗначениеЗаполнено(vSrvRow.Услуга) And vSrvRow.Услуга.DoNotGroupIntoRoomRateOnPrint Тогда
//							vSrvRow.IsInPrice = False;
//						EndIf;
//						If НЕ vSrvRow.IsRoomRevenue And vSrvRow.IsInPrice Тогда
//							vSrvRow.Услуга = vAccommodationService;
//							vSrvRow.Примечания = vAccommodationRemarks;
//							vSrvRow.Количество = 0;
//							vSrvRow.Цена = 0;
//							vSrvRow.IsRoomRevenue = True;
//						ElsIf vSrvRow.IsRoomRevenue And vSrvRow.IsInPrice Тогда
//							If vSrvRow.Услуга.RoomRevenueAmountsOnly Тогда
//								vSrvRow.Количество = 0;
//							EndIf;
//							vSrvRow.Услуга = vAccommodationService;
//							vSrvRow.Примечания = vAccommodationRemarks;
//							vSrvRow.Цена = 0;
//						EndIf;
//					ElsIf SelGroupBy = "All" Тогда
//						If НЕ vSrvRow.IsRoomRevenue Тогда
//							vSrvRow.Услуга = vAccommodationService;
//							vSrvRow.Примечания = vAccommodationRemarks;
//							vSrvRow.Количество = 0;
//							vSrvRow.Цена = 0;
//							vSrvRow.IsRoomRevenue = True;
//						Else
//							If vSrvRow.Услуга.RoomRevenueAmountsOnly Тогда
//								vSrvRow.Количество = 0;
//							EndIf;
//							vSrvRow.Услуга = vAccommodationService;
//							vSrvRow.Примечания = vAccommodationRemarks;
//							vSrvRow.Цена = 0;
//						EndIf;
//					EndIf;
//				EndIf;
//			EndIf;
//		EndDo;
//		vCndServices.GroupBy("Услуга, Примечания, СтавкаНДС, IsRoomRevenue, ВидКомиссииАгента, КомиссияАгента", "Сумма, СуммаНДС, Цена, Количество, СуммаКомиссии, VATCommissionSum");
//		vCndServices.Columns.Add("Продолжительность", cmGetNumberTypeDescription(10, 0));
//		// Recalculate price for all services
//		For Each vSrvRow In vCndServices Do
//			// Set quantity to the number of hotel products
//			If vHotelProductsCount > 0 And vSrvRow.IsRoomRevenue Тогда
//				vSrvRow.Продолжительность = Round(vSrvRow.Количество/vHotelProductsCount);
//				vSrvRow.Количество = vHotelProductsCount;
//			Else
//				vSrvRow.Продолжительность = 0;
//			EndIf;
//			vSrvRow.Цена = cmRecalculatePrice(vSrvRow.Сумма, vSrvRow.Количество);
//		EndDo;
//	
//		// Print condition header
//		vPeriodStr = Format(vConditionsRow.DateTimeFrom, "DF='dd.MM.yyyy'") + " - " + Format(vConditionsRow.DateTimeTo, "DF='dd.MM.yyyy'");
//		If BegOfDay(vConditionsRow.DateTimeFrom) = BegOfday(vConditionsRow.DateTimeTo) Тогда
//			vPeriodStr = Format(vConditionsRow.DateTimeFrom, "DF='dd.MM.yyyy'");
//		EndIf;
//		vRStr = "";
//		vAStr = "";
//		If ЗначениеЗаполнено(vConditionsRow.ТипНомера) Тогда
//			vRStr = vConditionsRow.ТипНомера.GetObject().pmGetRoomTypeDescription(SelLanguage);
//			If ЗначениеЗаполнено(vConditionsRow.ВидРазмещения) Тогда
//				vAStr = vConditionsRow.ВидРазмещения.GetObject().pmGetAccommodationTypeDescription(SelLanguage);
//			EndIf;
//		ElsIf ЗначениеЗаполнено(vConditionsRow.Ресурс) Тогда
//			vRStr = vConditionsRow.Ресурс.GetObject().pmGetResourceDescription(SelLanguage);
//		EndIf;
//		mCondition = ?(ЗначениеЗаполнено(vConditionsRow.DateTimeFrom), vPeriodStr, "") + 
//				     ?(IsBlankString(vRStr), "" , ?(ЗначениеЗаполнено(vConditionsRow.DateTimeFrom), ", " + vRStr, vRStr)) + 
//				     ?(IsBlankString(vAStr), "" , ", " + vAStr);
//		If Left(mCondition, 1) = "," Тогда
//			mCondition = Mid(mCondition, 3);
//		EndIf;
//					 
//		// Set client area parameters
//		vClient.Parameters.mClient = mCondition;
//		// Put client area
//		vSpreadsheet.Put(vClient);
//		For Each vSrvRow In vCndServices Do
//			// Fill row parameters
//			mPrice = Format(vSrvRow.Цена, "ND=17; NFD=2");
//			If vSrvRow.IsRoomRevenue And vSrvRow.Сумма > 0 And vSrvRow.Продолжительность > 0 And vSrvRow.Количество > 0 Тогда
//				mPrice = cmFormatSum(Round(vSrvRow.Сумма/(vSrvRow.Продолжительность*vSrvRow.Количество), 2), SelInvoice.ВалютаРасчетов, "", SelLanguage) + " * " + 
//				         Format(vSrvRow.Продолжительность, "ND=10; NFD=0; NG=") + "дн" + " * " + 
//				         Format(vSrvRow.Количество, "ND=10; NFD=0; NG=") + "шт" + 
//				         cmFormatSum(vSrvRow.Сумма, SelInvoice.ВалютаРасчетов, "", SelLanguage);
//			EndIf;
//			mSum = vSrvRow.Сумма;
//			If vSrvRow.IsRoomRevenue And vSrvRow.Продолжительность > 0 Тогда
//				mQuantity = ?(vSrvRow.Количество=0, "", Format(vSrvRow.Количество, "ND=10; NFD=0; NG=") + " шт.");
//				mDescription = Chars.Tab + StrReplace(TrimAll(vSrvRow.Примечания), Chars.LF, Chars.LF + Chars.Tab) + 
//				               ?(vSrvRow.Продолжительность > 0, " (" + ?(IsBlankString(vHotelProductsList), "", vHotelProductsList + ", ") + 
//				                 Format(vSrvRow.Продолжительность, "ND=10; NFD=0; NG=") + " дней", "");
//			Else
//				If Round(vSrvRow.Количество, 3) <> vSrvRow.Количество Тогда
//					mQuantity = ?(vSrvRow.Количество = 0, "", Format(vSrvRow.Количество, "ND=17; NFD=3"));
//				Else
//					mQuantity = ?(vSrvRow.Количество = 0, "", String(vSrvRow.Количество));
//				EndIf;
//				If ЗначениеЗаполнено(vSrvRow.Услуга) Тогда
//					If vSrvRow.Количество <> 0 Тогда
//						vServiceObj = vSrvRow.Услуга.GetObject();
//						mQuantity = vServiceObj.pmGetServiceQuantityPresentation(vSrvRow.Количество, SelLanguage);
//					EndIf;
//				EndIf;
//				mDescription = Chars.Tab + StrReplace(TrimAll(vSrvRow.Примечания), Chars.LF, Chars.LF + Chars.Tab);
//			EndIf;
//			If ExtraInvoice Тогда
//				If Services.Count() = 1 Тогда
//					If vSrvRow.Количество = 1 Тогда
//						mQuantity = Format(vSrvRow.Количество, "ND=17; NFD=0");
//					EndIf;
//				EndIf;
//			EndIf;
//			
//			// Fill totals
//			vTotalSum = vTotalSum + vSrvRow.Сумма;
//			vTotalSumNoCommission = vTotalSumNoCommission + vSrvRow.Сумма - vSrvRow.СуммаКомиссии;
//			vTotalCommissionSum = vTotalCommissionSum + vSrvRow.СуммаКомиссии;
//			vTotalVATSumNoCommission = vTotalVATSumNoCommission + cmCalculateVATSum(vSrvRow.СтавкаНДС, (vSrvRow.Сумма - vSrvRow.СуммаКомиссии));
//			vTotalVATSum = vTotalVATSum + cmCalculateVATSum(vSrvRow.СтавкаНДС, vSrvRow.Сумма);
//			
//			vVATRateTransactionsRow = vVATRateTransactions.Add();
//			vVATRateTransactionsRow.СтавкаНДС = vSrvRow.СтавкаНДС;
//			vVATRateTransactionsRow.СуммаНДС = cmCalculateVATSum(vSrvRow.СтавкаНДС, vSrvRow.Сумма);
//			vVATRateTransactionsRow.Сумма = vSrvRow.Сумма;
//			
//			vRow.Parameters.mPrice = mPrice;
//			vRow.Parameters.mQuantity = mQuantity;
//			vRow.Parameters.mDescription = mDescription;
//			vRow.Parameters.mSum = Format(mSum, "ND=17; NFD=2");
//			// Put row
//			If НЕ IsBlankString(mSum) Тогда
//				// Check if we can print footer completely
//				If (vConditions.IndexOf(vConditionsRow) + 1) = vConditions.Count() And 
//				   (vCndServices.IndexOf(vSrvRow) + 1) = vCndServices.Count() Тогда
//					vFooterAreas.Вставить(0, vRow);
//					If НЕ vSpreadsheet.CheckPut(vFooterAreas) Тогда
//						vSpreadsheet.PutHorizontalPageBreak();
//						vSpreadsheet.Put(vTableHeader);
//					EndIf;
//					vFooterAreas.Delete(0);
//				Else
//					If НЕ vSpreadsheet.CheckPut(vRow) Тогда
//						vSpreadsheet.PutHorizontalPageBreak();
//						vSpreadsheet.Put(vTableHeader);
//					EndIf;
//				EndIf;
//				vSpreadsheet.Put(vRow);
//			EndIf;
//		EndDo;
//	EndDo;
//	
//	// Put footer areas
//	For Each vFooterArea In vFooterAreas Do
//		vSpreadsheet.Put(vFooterArea);
//	EndDo;
//	
//	// Setup default attributes
//	cmSetDefaultPrintFormSettings(vSpreadsheet, PageOrientation.Portrait, True, , True);
//	// Check authorities
//	cmSetSpreadsheetProtection(vSpreadsheet);
//КонецПроцедуры //pmPrintInvoiceHotelProduct
//
////-----------------------------------------------------------------------------
//Function pmSendInvoiceByEMail(vSpreadsheet, pEMails, pInvoiceNumber, SelLanguage, pMessageText = "") Экспорт
//	// Save current spreadsheet as HTML
//	vFileName = StrReplace(Metadata().Presentation() + " " + StrReplace(TrimAll(Number), "/", "-"), " ", "_");
//	vFilePath = cmGetFullFileName(vFileName, TempFilesDir()) + ".pdf";
//	vFileType = SpreadsheetDocumentFileType.PDF;
//	vSpreadsheet.Write(vFilePath, vFileType);
//	// Employee Подпись
//	vEmployeeSignature = TrimAll(ПараметрыСеанса.ТекПользователь.Должность) + " " + ПараметрыСеанса.ТекПользователь.GetObject().pmGetEmployeeDescription(SelLanguage);
//	// Sender name
//	vSenderName = ?(ЗначениеЗаполнено(Гостиница), Гостиница.GetObject().pmGetHotelPrintName(SelLanguage), "");
//	// Initialize message texts
//	vMessageSubject = ?(ЗначениеЗаполнено(Гостиница), Гостиница.GetObject().pmGetHotelPrintName(SelLanguage), "") + 
//	                  " Счет №" + TrimAll(pInvoiceNumber) + "'";
//	vMessageText = ?(IsBlankString(pMessageText), "", TrimAll(pMessageText) + Chars.LF + Chars.LF) + 
//	              "Автоматизированная система рассылки счетов-требований:'" + Chars.LF + Chars.LF +
//	              "НомерРазмещения счета " + TrimAll(pInvoiceNumber) + "'"+ Chars.LF +
//	              ?(ЗначениеЗаполнено(GuestGroup), 
//	              "НомерРазмещения подтверждения " + Format(GuestGroup.Code, "ND=12; NFD=0; NG=") + "'" + Chars.LF + Chars.LF, 
//	              Chars.LF) + 
//	              "С уважением,'" + Chars.LF + 
//	              vEmployeeSignature + Chars.LF + 
//	              ?(ЗначениеЗаполнено(Гостиница), Гостиница.GetObject().pmGetHotelPrintName(SelLanguage), "") + Chars.LF +   ПараметрыСеанса.ИмяКонфигурации;
//	// Call user exit procedure to give possibility to override message subject ans message text
//	vUserExitProc = Справочники.ВнешниеОбработки.SendInvoiceByEMail;
//	If ЗначениеЗаполнено(vUserExitProc) Тогда
//		If vUserExitProc.ExternalProcessingType = Перечисления.ExternalProcessingTypes.Algorithm Тогда
//			If НЕ IsBlankString(vUserExitProc.Algorithm) Тогда
//				Execute(TrimAll(vUserExitProc.Algorithm));
//			EndIf;
//		EndIf;
//	EndIf;
//	// Send file in modal mode
//	vResult = РегламентныеЗадания.cmSendFileByEMail(vMessageSubject, vMessageText, pEMails, vMessageSubject+".pdf", vFilePath, SelLanguage, , GuestGroup, vSenderName);
//	// Delete temp file
//	DeleteFiles(vFilePath);
//	// Return result
//	Return vResult;
//EndFunction //pmSendInvoiceByEMail
//
////-----------------------------------------------------------------------------
//Процедура OnCopy(pCopiedObject)
//	ExternalCode = "";
//КонецПроцедуры //OnCopy
