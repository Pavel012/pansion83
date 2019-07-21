//Перем WasPosted;

////-----------------------------------------------------------------------------
//Процедура PostToDeposits()
//	If PaymentSections.Count() > 0 Тогда
//		For Each vPSRow In PaymentSections Do
//			If vPSRow.Sum = 0 Тогда
//				Continue;
//			EndIf;
//				
//			Movement = RegisterRecords.Депозиты.Add();
//			
//			Movement.Period = Date;
//			Movement.Платеж = ThisObject.Ref;
//			
//			FillPropertyValues(Movement, ThisObject);
//			FillPropertyValues(Movement, vPSRow);
//			Movement.ВалютаЛицСчета = FolioCurrency;
//			Movement.СчетПроживания = ЛицевойСчет;
//			
//			// Resources
//			Movement.Сумма = -vPSRow.SumInFolioCurrency;
//			
//			// Attributes
//			Movement.SumInPaymentCurrency = -vPSRow.Sum;
//		EndDo;			
//	Else
//		Movement = RegisterRecords.Депозиты.Add();
//		
//		Movement.Period = Date;
//		Movement.Платеж = ThisObject.Ref;
//		
//		FillPropertyValues(Movement, ThisObject);
//		Movement.ВалютаЛицСчета = FolioCurrency;
//		Movement.СчетПроживания = ЛицевойСчет;
//		
//		// Resources
//		Movement.Сумма = -SumInFolioCurrency;
//		
//		// Attributes
//		Movement.SumInPaymentCurrency = -Sum;
//	EndIf;
//	
//	RegisterRecords.Депозиты.Write();
//КонецПроцедуры //PostToDeposits

////-----------------------------------------------------------------------------
//Процедура PostToAccounts()
//	If PaymentSections.Count() > 0 Тогда
//		For Each vPSRow In PaymentSections Do
//			If vPSRow.Sum = 0 Тогда
//				Continue;
//			EndIf;
//			
//			Movement = RegisterRecords.Взаиморасчеты.Add();
//			
//			Movement.RecordType = AccumulationRecordType.Expense;
//			Movement.Period = Date;
//			
//			FillPropertyValues(Movement, ЛицевойСчет);
//			If ЗначениеЗаполнено(ParentDoc) Тогда
//				FillPropertyValues(Movement, ParentDoc);
//			EndIf;
//			FillPropertyValues(Movement, ThisObject);
//			FillPropertyValues(Movement, vPSRow);
//			
//			// Resources
//			Movement.Сумма = -vPSRow.SumInFolioCurrency;
//			
//			// Attributes
//			Movement.СуммаНДС = -vPSRow.VATSumInFolioCurrency;
//		EndDo;
//	Else
//		Movement = RegisterRecords.Взаиморасчеты.Add();
//		
//		Movement.RecordType = AccumulationRecordType.Expense;
//		Movement.Period = Date;
//		
//		FillPropertyValues(Movement, ЛицевойСчет);
//		If ЗначениеЗаполнено(ParentDoc) Тогда
//			FillPropertyValues(Movement, ParentDoc);
//		EndIf;
//		FillPropertyValues(Movement, ThisObject);
//		
//		// Resources
//		Movement.Сумма = -SumInFolioCurrency;
//		
//		// Attributes
//		Movement.СуммаНДС = -VATSumInFolioCurrency;
//		
//		// Payment section
//		If ЗначениеЗаполнено(Гостиница) And НЕ Гостиница.SplitFolioBalanceByPaymentSections Тогда
//			Movement.PaymentSection = Справочники.ОтделОплаты.EmptyRef();
//		EndIf;
//	EndIf;

//	RegisterRecords.Взаиморасчеты.Write();
//КонецПроцедуры //PostToAccounts

////-----------------------------------------------------------------------------
//Процедура PostToPayments()
//	If PaymentSections.Count() > 0 Тогда
//		For Each vPSRow In PaymentSections Do
//			If vPSRow.Sum = 0 Тогда
//				Continue;
//			EndIf;
//			
//			Movement = RegisterRecords.Платежи.Add();
//			
//			Movement.Period = Date;
//			
//			FillPropertyValues(Movement, ThisObject);
//			FillPropertyValues(Movement, vPSRow);
//			
//			// Dimensions
//			Movement.УчетнаяДата = BegOfDay(Date);
//			
//			// Resources
//			Movement.Сумма = -vPSRow.Sum;
//			Movement.СуммаНДС = -vPSRow.VATSum;
//			Movement.SumReceipt = 0;
//			Movement.VATSumReceipt = 0;
//			Movement.SumExpense = vPSRow.Sum;
//			Movement.VATSumExpense = vPSRow.VATSum;
//		EndDo;
//	Else
//		Movement = RegisterRecords.Платежи.Add();
//		
//		Movement.Period = Date;
//		
//		FillPropertyValues(Movement, ThisObject);
//		
//		// Dimensions
//		Movement.УчетнаяДата = BegOfDay(Date);
//		
//		// Resources
//		Movement.Сумма = -Sum;
//		Movement.СуммаНДС = -VATSum;
//		Movement.SumReceipt = 0;
//		Movement.VATSumReceipt = 0;
//		Movement.SumExpense = Sum;
//		Movement.VATSumExpense = VATSum;
//	EndIf;
//	
//	RegisterRecords.Платежи.Write();
//КонецПроцедуры //PostToPayments

////-----------------------------------------------------------------------------
//Процедура PostToCustomerAccounts()
//	If PaymentSections.Count() > 0 Тогда
//		For Each vPSRow In PaymentSections Do
//			If vPSRow.Sum = 0 Тогда
//				Continue;
//			EndIf;
//			
//			Movement = RegisterRecords.ВзаиморасчетыКонтрагенты.Add();
//			
//			Movement.RecordType = AccumulationRecordType.Expense;
//			Movement.Period = Date;
//			
//			FillPropertyValues(Movement, ЛицевойСчет);
//			If ЗначениеЗаполнено(ParentDoc) Тогда
//				FillPropertyValues(Movement, ParentDoc);
//			EndIf;
//			FillPropertyValues(Movement, ThisObject);
//			FillPropertyValues(Movement, vPSRow);
//			
//			// Dimensions
//			Movement.ВалютаРасчетов = FolioCurrency;
//			
//			// Resources
//			Movement.Сумма = -vPSRow.SumInFolioCurrency;
//			
//			// Attributes
//			Movement.СуммаНДС = -vPSRow.VATSumInFolioCurrency;
//			Movement.УчетнаяДата = BegOfDay(Date);

//			RegisterRecords.ВзаиморасчетыКонтрагенты.Write();
//		EndDo;
//	Else
//		Movement = RegisterRecords.ВзаиморасчетыКонтрагенты.Add();
//		
//		Movement.RecordType = AccumulationRecordType.Expense;
//		Movement.Period = Date;
//		
//		FillPropertyValues(Movement, ЛицевойСчет);
//		If ЗначениеЗаполнено(ParentDoc) Тогда
//			FillPropertyValues(Movement, ParentDoc);
//		EndIf;
//		FillPropertyValues(Movement, ThisObject);
//		
//		// Dimensions
//		Movement.ВалютаРасчетов = FolioCurrency;
//		
//		// Resources
//		Movement.Сумма = -SumInFolioCurrency;
//		
//		// Attributes
//		Movement.СуммаНДС = -VATSumInFolioCurrency;
//		Movement.УчетнаяДата = BegOfDay(Date);

//		RegisterRecords.ВзаиморасчетыКонтрагенты.Write();
//	EndIf;
//КонецПроцедуры //PostToCustomerAccounts

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
//		Movement.Сумма = -cmConvertCurrencies(Sum, PaymentCurrency, PaymentCurrencyExchangeRate, Movement.ВалютаРасчетов, , ExchangeRateDate, Гостиница);
//		
//		// Attributes
//		Movement.СуммаНДС = cmCalculateVATSum(VATRate, Movement.Сумма);
//		Movement.СтавкаНДС = VATRate;
//		Movement.УчетнаяДата = BegOfDay(Date);
//		If ЗначениеЗаполнено(ЛицевойСчет) Тогда
//			Movement.Клиент = ЛицевойСчет.Client;
//			Movement.НомерРазмещения = ЛицевойСчет.ГруппаНомеров;
//		EndIf;

//		RegisterRecords.ВзаиморасчетыПоСчетам.Write();
//	EndIf;
//КонецПроцедуры //PostToInvoiceAccounts

////-----------------------------------------------------------------------------
//Процедура PostToCashRegisterDailyReceipts()
//	If PaymentSections.Count() > 0 Тогда
//		For Each vPSRow In PaymentSections Do
//			If vPSRow.Sum = 0 Тогда
//				Continue;
//			EndIf;
//			
//			Movement = RegisterRecords.ВыручкаПоСменам.AddReceipt();
//			
//			Movement.Period = Date;
//			Movement.Валюта = PaymentCurrency;
//			
//			FillPropertyValues(Movement, ЛицевойСчет);
//			If ЗначениеЗаполнено(ParentDoc) Тогда
//				FillPropertyValues(Movement, ParentDoc);
//			EndIf;
//			FillPropertyValues(Movement, ThisObject);
//			FillPropertyValues(Movement, vPSRow);
//			
//			// Dimensions
//			Movement.Контрагент = AccountingCustomer;
//			Movement.Договор = AccountingContract;
//			Movement.Платеж = Ref;
//			
//			// Resources
//			Movement.Сумма = -vPSRow.Sum;
//			Movement.СуммаНДС = -vPSRow.VATSum;
//			Movement.PaymentSum = 0;
//			Movement.VATPaymentSum = 0;
//			Movement.ReturnSum = vPSRow.Sum;
//			Movement.VATReturnSum = vPSRow.VATSum;
//		EndDo;
//	Else
//		Movement = RegisterRecords.ВыручкаПоСменам.AddReceipt();
//		
//		Movement.Period = Date;
//		Movement.Валюта = PaymentCurrency;
//		
//		FillPropertyValues(Movement, ЛицевойСчет);
//		If ЗначениеЗаполнено(ParentDoc) Тогда
//			FillPropertyValues(Movement, ParentDoc);
//		EndIf;
//		FillPropertyValues(Movement, ThisObject);
//		
//		// Dimensions
//		Movement.Контрагент = AccountingCustomer;
//		Movement.Договор = AccountingContract;
//		Movement.Платеж = Ref;
//		
//		// Resources
//		Movement.Сумма = -Sum;
//		Movement.СуммаНДС = -VATSum;
//		Movement.PaymentSum = 0;
//		Movement.VATPaymentSum = 0;
//		Movement.ReturnSum = Sum;
//		Movement.VATReturnSum = VATSum;
//	EndIf;

//	RegisterRecords.ВыручкаПоСменам.Write();
//КонецПроцедуры //PostToCashRegisterDailyReceipts

////-----------------------------------------------------------------------------
//Процедура PostToCashInCashRegisters()
//	Movement = RegisterRecords.НаличныеКасса.Add();
//	
//	Movement.Period = Date;
//	Movement.RecordType = AccumulationRecordType.Expense;
//	Movement.Валюта = PaymentCurrency;
//	
//	FillPropertyValues(Movement, ThisObject);

//	RegisterRecords.НаличныеКасса.Write();
//КонецПроцедуры //PostToCashInCashRegisters

////-----------------------------------------------------------------------------
//Процедура PostToPaymentServices()
//	Movement = RegisterRecords.ПлатежиУслуги.Add();
//	
//	Movement.RecordType = AccumulationRecordType.Expense;
//	Movement.Period = Date;
//	
//	// Dimensions
//	Movement.СчетПроживания = ЛицевойСчет;
//	Movement.Услуга = Справочники.Услуги.EmptyRef();
//	Movement.Платеж = Ref;
//	
//	// Resources
//	Movement.Сумма = -SumInFolioCurrency;
//	
//	RegisterRecords.ПлатежиУслуги.Write();
//КонецПроцедуры //PostToPaymentServices

////-----------------------------------------------------------------------------
//Процедура WriteOffBonuses()
//	If ЗначениеЗаполнено(PaymentMethod) And PaymentMethod.IsByBonuses And 
//	   ЗначениеЗаполнено(PaymentMethod.DiscountType) And 
//	   PaymentMethod.DiscountType.BonusCalculationFactor <> 0 Тогда
//		vDiscountTypeObj = PaymentMethod.DiscountType.GetObject();
//		vDimension = Неопределено;
//		If PaymentMethod.DiscountType.AccumulatingDiscountDimension = Перечисления.AccumulatingDiscountDimensions.DiscountCard Тогда
//			If ЗначениеЗаполнено(ParentDoc) And ЗначениеЗаполнено(ParentDoc.DiscountCard) Тогда
//				vDimension = ParentDoc.DiscountCard;
//				vBonuses = vDiscountTypeObj.pmGetAccumulatingDiscountResources(Date, , , , ParentDoc.DiscountCard);
//			EndIf;
//		ElsIf PaymentMethod.DiscountType.AccumulatingDiscountDimension = Перечисления.AccumulatingDiscountDimensions.Клиент Тогда
//			If ЗначениеЗаполнено(Payer) And TypeOf(Payer) = Type("CatalogRef.Клиенты") Тогда
//				vDimension = Payer;
//				vBonuses = vDiscountTypeObj.pmGetAccumulatingDiscountResources(Date, , , Payer);
//			EndIf;
//		EndIf;
//		If vDimension <> Неопределено Тогда
//			If vBonuses.Count() > 0 Тогда
//				vBonusesRow = vBonuses.Get(0);
//				// Get payment currency bonus calculation rate
//				vRates = InformationRegisters.КурсВалют.SliceLast(Date, New Structure("Гостиница, Валюта", Гостиница, PaymentCurrency));
//				If vRates.Count() > 0 Тогда
//					vRatesRow = vRates.Get(0);
//					vBonusRate = vRatesRow.BonusRate;
//					vBonus2WriteOff = Sum * vBonusRate;
//					If vBonus2WriteOff <> 0 Тогда
//						Movement = RegisterRecords.НакопитСкидки.Add();
//						If vBonus2WriteOff > 0 Тогда
//							Movement.RecordType = AccumulationRecordType.Receipt;
//						Else
//							Movement.RecordType = AccumulationRecordType.Expense;
//						EndIf;
//						Movement.Period = Date;
//						Movement.ТипСкидки = PaymentMethod.DiscountType;
//						Movement.ИзмерениеСкидки = vDimension;
//						Movement.ГруппаГостей = Справочники.ГруппыГостей.EmptyRef();
//						Movement.Ресурс = 0;
//						Movement.Бонус = vBonus2WriteOff;
//					EndIf;
//				EndIf;
//			EndIf;
//		EndIf;
//	EndIf;
//КонецПроцедуры //WriteOffBonuses

////-----------------------------------------------------------------------------
//Процедура PostToGiftCertificates()
//	vGiftCertificatesArePerHotel = Constants.GiftCertificatesArePerHotel.Get();
//	
//	Movement = RegisterRecords.ПодарочСертификатСведения.Add();
//	Movement.Period = Date;
//	
//	// Fill dimensions
//	Movement.Гостиница = ?(vGiftCertificatesArePerHotel, Гостиница, Справочники.Гостиницы.EmptyRef());
//	Movement.GiftCertificate = GiftCertificate;
//	
//	// Fill resource
//	Movement.Amount = -Round(cmConvertCurrencies(Sum, PaymentCurrency, PaymentCurrencyExchangeRate, Гостиница.ReportingCurrency, , ExchangeRateDate, Гостиница), 2);
//	
//	// Fill attributes and movement type
//	If НЕ PaymentMethod.IsByGiftCertificate Тогда
//		Movement.RecordType = AccumulationRecordType.Receipt;
//		
//		Movement.Buyer = ЛицевойСчет.Client;
//	Else
//		Movement.RecordType = AccumulationRecordType.Expense;
//		
//		Movement.Payer = ЛицевойСчет.Client;
//	EndIf;
//	
//	// Write movements
//	RegisterRecords.ПодарочСертификатСведения.Write();
//КонецПроцедуры //PostToGiftCertificates

////-----------------------------------------------------------------------------
//Процедура Posting(pCancel, pMode)
//	If ThisObject.DataExchange.Load Тогда
//		Return;
//	EndIf;
//	
//	// 1. Post to Deposits
//	PostToDeposits();
//	
//	// 2. Post to Accounts
//	If НЕ IsBlankString(GiftCertificate) And ЗначениеЗаполнено(PaymentMethod) And PaymentMethod.IsByGiftCertificate Or 
//	   IsBlankString(GiftCertificate) Тогда
//		PostToAccounts();
//	EndIf;
//	
//	// 3. Post to Payments
//	PostToPayments();
//	
//	If НЕ IsBlankString(GiftCertificate) And ЗначениеЗаполнено(PaymentMethod) And PaymentMethod.IsByGiftCertificate Or 
//	   IsBlankString(GiftCertificate) Тогда
//		// 4. Post to Контрагент accounts
//		PostToCustomerAccounts();
//		
//		// 5. Post to Invoice accounts
//		PostToInvoiceAccounts();
//	EndIf;
//	
//	// 6. Post to Close of cash register day debits
//	If ЗначениеЗаполнено(CashRegister) And ЗначениеЗаполнено(PaymentMethod) Тогда
//		If PaymentMethod.BookByCashRegister Тогда
//			PostToCashRegisterDailyReceipts();
//			// Post to cash in cash registers
//			If PaymentMethod.IsByCash Тогда
//				PostToCashInCashRegisters();
//			EndIf;
//		EndIf;
//	EndIf;
//	
//	If НЕ IsBlankString(GiftCertificate) And ЗначениеЗаполнено(PaymentMethod) And PaymentMethod.IsByGiftCertificate Or 
//	   IsBlankString(GiftCertificate) Тогда
//		// 7. Post to Payment services
//		If Гостиница.DoPaymentsDistributionToServices Тогда
//			PostToPaymentServices();
//		EndIf;
//		
//		// 8. Repost settlements if any
//		pmRepostSettlements();
//	EndIf;
//	
//	// 9. Write off bonuses
//	WriteOffBonuses();
//	
//	// 10. Post to gift certificates
//	If ЗначениеЗаполнено(Гостиница) And ЗначениеЗаполнено(Гостиница.ReportingCurrency) And 
//	   ЗначениеЗаполнено(PaymentMethod) And НЕ IsBlankString(GiftCertificate) Тогда
//		PostToGiftCertificates();
//	EndIf;
//	
//	// 11. Update folio accounting number
//	If НЕ IsBlankString(GiftCertificate) And ЗначениеЗаполнено(PaymentMethod) And PaymentMethod.IsByGiftCertificate Or 
//	   IsBlankString(GiftCertificate) Тогда
//		If ЗначениеЗаполнено(ЛицевойСчет) And ЗначениеЗаполнено(Гостиница) And Гостиница.UseFolioAccountingNumberPrefix Тогда
//			vHotelObj = Гостиница.GetObject();
//			vFolioAccountingNumberPrefix = vHotelObj.pmGetFolioAccountingNumberPrefix();
//			If НЕ IsBlankString(vFolioAccountingNumberPrefix) And Upper(Left(TrimR(ЛицевойСчет.Number), StrLen(vFolioAccountingNumberPrefix))) <> Upper(vFolioAccountingNumberPrefix) Or
//			   IsBlankString(vFolioAccountingNumberPrefix) And НЕ cmIsNumber(TrimAll(ЛицевойСчет.Number)) Тогда
//				vFolioObj = ЛицевойСчет.GetObject();
//				vFolioObj.SetNewNumber(vFolioAccountingNumberPrefix);
//				vFolioObj.Write(DocumentWriteMode.Write);
//			EndIf;
//		EndIf;
//	EndIf;
//	
//	// 12. Send return SMS
//	If НЕ IsBlankString(GiftCertificate) And ЗначениеЗаполнено(PaymentMethod) And PaymentMethod.IsByGiftCertificate Or 
//	   IsBlankString(GiftCertificate) Тогда
//		If НЕ WasPosted Тогда
//			vMessageDeliveryError = "";
//			//If НЕ SMS.SendPaymentMessage(Payer, GuestGroup, ParentDoc, cmFormatSum(Sum, PaymentCurrency), PaymentMethod, Ref, vMessageDeliveryError) Тогда
//			//	WriteLogEvent(NStr("en='Document.MessageDelivery';ru='Документ.РассылкаСообщений';de='Document.MessageDelivery'"), EventLogLevel.Warning, ThisObject.Metadata(), Ref, vMessageDeliveryError);
//			//	Message(vMessageDeliveryError, MessageStatus.Attention);
//			//EndIf;
//		EndIf;
//	EndIf;
//КонецПроцедуры //Posting

////-----------------------------------------------------------------------------
//Процедура pmRepostSettlements() Экспорт
//	If ЗначениеЗаполнено(Гостиница) And Гостиница.SwitchOffRepostingOfSettlements Тогда
//		Return;
//	EndIf;
//	If ЗначениеЗаполнено(ЛицевойСчет) And ЗначениеЗаполнено(ЛицевойСчет.PaymentMethod) And 
//	   ЛицевойСчет.PaymentMethod.IsByBankTransfer Тогда
//		vSettlements = ЛицевойСчет.GetObject().pmGetAllFolioSettlements();
//		For Each vSettlementsRow In vSettlements Do
//			vSettlementObj = vSettlementsRow.Document.GetObject();
//			vSettlementObj.pmPostToAccountsAndPayments();
//		EndDo;
//	EndIf;
//КонецПроцедуры //pmRepostSettlements

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
//	If ЗначениеЗаполнено(Гостиница) And ЗначениеЗаполнено(PaymentMethod) And PaymentMethod.BookByCashRegister Тогда
//		If НЕ cmCheckUserPermissions("HavePermissionToPostPaymentsWithEmptyPaymentSections") Тогда
//			If НЕ Гостиница.SplitFolioBalanceByPaymentSections Тогда
//				If НЕ ЗначениеЗаполнено(PaymentSection) Тогда
//					vHasErrors = True; 
//					vMsgTextRu = vMsgTextRu + "Не указана кассовая секция (отдел)!" + Chars.LF;
//					vMsgTextEn = vMsgTextEn + "<Платеж section> attribute should be filled!" + Chars.LF;
//					vMsgTextDe = vMsgTextDe + "<Платеж section> attribute should be filled!" + Chars.LF;
//					pAttributeInErr = ?(pAttributeInErr = "", "PaymentSection", pAttributeInErr);
//				EndIf;
//			Else
//				For Each vPSRow In PaymentSections Do
//					If vPSRow.Sum > 0 And НЕ ЗначениеЗаполнено(vPSRow.PaymentSection) Тогда
//						vHasErrors = True; 
//						vMsgTextRu = vMsgTextRu + "В строке " + Format(vPSRow.LineNumber, "ND=4; NFD=0; NG=") + " не указана кассовая секция (отдел)!" + Chars.LF;
//						vMsgTextEn = vMsgTextEn + "<Платеж section> attribute should be filled in row " + Format(vPSRow.LineNumber, "ND=4; NFD=0; NG=") + "!" + Chars.LF;
//						vMsgTextDe = vMsgTextDe + "<Платеж section> attribute should be filled in row " + Format(vPSRow.LineNumber, "ND=4; NFD=0; NG=") + "!" + Chars.LF;
//						pAttributeInErr = ?(pAttributeInErr = "", "PaymentSection", pAttributeInErr);
//					EndIf;
//				EndDo;
//			EndIf;
//		EndIf;
//	EndIf;
//	If ЗначениеЗаполнено(PaymentMethod) Тогда
//		If ЗначениеЗаполнено(ПараметрыСеанса.РабочееМесто) Тогда
//			If НЕ ПараметрыСеанса.РабочееМесто.HasConnectionToCreditCardsProcessingSystem Or 
//			   PaymentMethod.ExternalBankTerminalIsUsed Тогда
//				If PaymentMethod.AuthorizationCodeIsRequired And IsBlankString(AuthorizationCode) Тогда
//					vHasErrors = True; 
//					vMsgTextRu = vMsgTextRu + "При возврате на кредитную карту должен быть введен реквизит <Код авторизации>!" + Chars.LF;
//					vMsgTextEn = vMsgTextEn + "<Authorization code> attribute should be filled for credit card return!" + Chars.LF;
//					vMsgTextDe = vMsgTextDe + "<Authorization code> attribute should be filled for credit card return!" + Chars.LF;
//					pAttributeInErr = ?(pAttributeInErr = "", "AuthorizationCode", pAttributeInErr);
//				EndIf;
//				If PaymentMethod.ReferenceCodeIsRequired And IsBlankString(ReferenceNumber) Тогда
//					vHasErrors = True; 
//					vMsgTextRu = vMsgTextRu + "При возврате на кредитную карту должен быть введен реквизит <Референс НомерРазмещения>!" + Chars.LF;
//					vMsgTextEn = vMsgTextEn + "<Reference number> attribute should be filled for credit card return!" + Chars.LF;
//					vMsgTextDe = vMsgTextDe + "<Reference number> attribute should be filled for credit card return!" + Chars.LF;
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
//	If Sum < 0 Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Для оформления оплаты необходимо использовать документ ""Платеж""!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "Use ""Payment"" document to get money!" + Chars.LF;
//		vMsgTextDe = vMsgTextDe + "Use ""Payment"" document to get money!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "Сумма", pAttributeInErr);
//	Else
//		For Each vPSRow In PaymentSections Do
//			If vPSRow.Sum < 0 Тогда
//				vHasErrors = True; 
//				vMsgTextRu = vMsgTextRu + "Для оформления оплаты необходимо использовать документ ""Платеж""!" + Chars.LF;
//				vMsgTextEn = vMsgTextEn + "Use ""Payment"" document to get money!" + Chars.LF;
//				vMsgTextDe = vMsgTextDe + "Use ""Payment"" document to get money!" + Chars.LF;
//				pAttributeInErr = ?(pAttributeInErr = "", "ОтделОплаты", pAttributeInErr);
//			EndIf;
//		EndDo;
//	EndIf;
//	If НЕ cmCheckUserPermissions("HavePermissionToReturnPayments") Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "У вас нет прав на оформление возвратов!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "You do not have rights to return payments!" + Chars.LF;
//		vMsgTextDe = vMsgTextDe + "You do not have rights to return payments!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "СпособОплаты", pAttributeInErr);
//	EndIf;
//	If ЗначениеЗаполнено(Payment) Тогда
//		If НЕ cmCheckUserPermissions("HavePermissionToReturnBasedOnFolio") Тогда
//			If ЗначениеЗаполнено(PaymentMethod) And ЗначениеЗаполнено(Payment.PaymentMethod) Тогда
//				If Payment.PaymentMethod.IsByCash And НЕ PaymentMethod.IsByCash Тогда
//					vHasErrors = True; 
//					vMsgTextRu = vMsgTextRu + "Возврат можно оформить только наличными!" + Chars.LF;
//					vMsgTextEn = vMsgTextEn + "Return could be done by cash only!" + Chars.LF;
//					vMsgTextDe = vMsgTextDe + "Return could be done by cash only!" + Chars.LF;
//					pAttributeInErr = ?(pAttributeInErr = "", "СпособОплаты", pAttributeInErr);
//				ElsIf Payment.PaymentMethod.IsByCreditCard And НЕ PaymentMethod.IsByCreditCard Тогда
//					vHasErrors = True; 
//					vMsgTextRu = vMsgTextRu + "Возврат можно оформить только на кредитную карту!" + Chars.LF;
//					vMsgTextEn = vMsgTextEn + "Return could be done by credit card only!" + Chars.LF;
//					vMsgTextDe = vMsgTextDe + "Return could be done by credit card only!" + Chars.LF;
//					pAttributeInErr = ?(pAttributeInErr = "", "СпособОплаты", pAttributeInErr);
//				ElsIf Payment.PaymentMethod.IsByBankTransfer And НЕ PaymentMethod.IsByBankTransfer Тогда
//					vHasErrors = True; 
//					vMsgTextRu = vMsgTextRu + "Возврат можно оформить только банковским платежом!" + Chars.LF;
//					vMsgTextEn = vMsgTextEn + "Return could be done by bank transfer only!" + Chars.LF;
//					vMsgTextDe = vMsgTextDe + "Return could be done by bank transfer only!" + Chars.LF;
//					pAttributeInErr = ?(pAttributeInErr = "", "СпособОплаты", pAttributeInErr);
//				EndIf;
//			EndIf;
//		EndIf;
//	EndIf;
//	vGiftCertificateNotFound = False;
//	If ЗначениеЗаполнено(PaymentMethod) And PaymentMethod.IsByGiftCertificate Тогда
//		If IsBlankString(GiftCertificate) Тогда
//			vHasErrors = True; 
//			vMsgTextRu = vMsgTextRu + "Подарочный сертификат не указан!" + Chars.LF;
//			vMsgTextEn = vMsgTextEn + "Gift certificate is not filled!" + Chars.LF;
//			vMsgTextDe = vMsgTextDe + "Gift certificate is not filled!" + Chars.LF;
//			pAttributeInErr = ?(pAttributeInErr = "", "GiftCertificate", pAttributeInErr);
//		Else
//			// Try to find gift certificate
//			If НЕ cmGiftCertificateExists(Гостиница, GiftCertificate) Тогда
//				vGiftCertificateNotFound = True;
//				vHasErrors = True; 
//				vMsgTextRu = vMsgTextRu + "Подарочный сертификат не найден!" + Chars.LF;
//				vMsgTextEn = vMsgTextEn + "Gift certificate is not found!" + Chars.LF;
//				vMsgTextDe = vMsgTextDe + "Gift certificate is not found!" + Chars.LF;
//				pAttributeInErr = ?(pAttributeInErr = "", "GiftCertificate", pAttributeInErr);
//			EndIf;
//		EndIf;
//	EndIf;
//	If НЕ Posted And ЗначениеЗаполнено(Гостиница) And ЗначениеЗаполнено(Гостиница.ReportingCurrency) And 
//	   ЗначениеЗаполнено(PaymentMethod) And НЕ PaymentMethod.IsByGiftCertificate And 
//	   НЕ IsBlankString(GiftCertificate) And НЕ vGiftCertificateNotFound Тогда
//		vReturnAmount = Round(cmConvertCurrencies(Sum, PaymentCurrency, PaymentCurrencyExchangeRate, Гостиница.ReportingCurrency, , ExchangeRateDate, Гостиница), 2);
//		vGiftCertificateBalance = cmGetGiftCertificateBalance(Гостиница, GiftCertificate, Date);
//		If vGiftCertificateBalance <= 0 Тогда
//			vHasErrors = True; 
//			vMsgTextRu = vMsgTextRu + "Подарочный сертификат уже использован!" + Chars.LF;
//			vMsgTextEn = vMsgTextEn + "Gift certificate is already being used!" + Chars.LF;
//			vMsgTextDe = vMsgTextDe + "Gift certificate is already being used!" + Chars.LF;
//			pAttributeInErr = ?(pAttributeInErr = "", "GiftCertificate", pAttributeInErr);
//		ElsIf vReturnAmount > vGiftCertificateBalance Тогда
//			vHasErrors = True; 
//			vMsgTextRu = vMsgTextRu + "Сумма возврата превышает остаток по подарочному сертификату (" + cmFormatSum(vGiftCertificateBalance, Гостиница.ReportingCurrency) + ")!" + Chars.LF;
//			vMsgTextEn = vMsgTextEn + "Return amount is greater then gift certificate balance (" + cmFormatSum(vGiftCertificateBalance, Гостиница.ReportingCurrency) + ")!" + Chars.LF;
//			vMsgTextDe = vMsgTextDe + "Return amount is greater then gift certificate balance (" + cmFormatSum(vGiftCertificateBalance, Гостиница.ReportingCurrency) + ")!" + Chars.LF;
//			pAttributeInErr = ?(pAttributeInErr = "", "Сумма", pAttributeInErr);
//		EndIf;
//	EndIf;
//	If vHasErrors Тогда
//		pMessage = "ru='" + TrimAll(vMsgTextRu) + "';" + "en='" + TrimAll(vMsgTextEn) + "';" + "de='" + TrimAll(vMsgTextDe) + "';";
//	Else
//		If НЕ ЗначениеЗаполнено(AccountingCustomer) And ЗначениеЗаполнено(Гостиница) And ЗначениеЗаполнено(Гостиница.IndividualsCustomer) Тогда
//			AccountingCustomer = Гостиница.IndividualsCustomer;
//			AccountingContract = Гостиница.IndividualsContract;
//		EndIf;
//	EndIf;
//	Return vHasErrors;
//EndFunction //CheckDocumentAttributes

////-----------------------------------------------------------------------------
//Процедура pmFillAuthorAndDate() Экспорт
//	Date = CurrentDate();
//	Автор = ПараметрыСеанса.ТекПользователь;
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
//	If ЗначениеЗаполнено(Гостиница) Тогда
//		FolioCurrency = Гостиница.FolioCurrency;
//		FolioCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, FolioCurrency, ExchangeRateDate);
//		PaymentCurrency = Гостиница.BaseCurrency;
//		PaymentCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, PaymentCurrency, ExchangeRateDate);
//		Фирма = Гостиница.Фирма;
//		If ЗначениеЗаполнено(Фирма) Тогда
//			VATRate = Фирма.VATRate;
//		EndIf;
//	EndIf;
//КонецПроцедуры //pmFillAttributesWithDefaultValues

////-----------------------------------------------------------------------------
//Процедура pmFillCustomerContractAndGuestGroup() Экспорт
//	If ЗначениеЗаполнено(Payer) Тогда
//		If TypeOf(Payer) = Type("CatalogRef.Контрагенты") Тогда
//			If AccountingCustomer <> Payer Тогда
//				AccountingCustomer = Payer;
//				If AccountingCustomer = ЛицевойСчет.Контрагент Тогда
//					AccountingContract = ЛицевойСчет.Contract;
//				Else
//					AccountingContract = Payer.Договор;
//				EndIf;
//			EndIf;
//		Else
//			If ЗначениеЗаполнено(ЛицевойСчет.Контрагент) Тогда
//				If AccountingCustomer <> ЛицевойСчет.Контрагент Тогда
//					AccountingCustomer = ЛицевойСчет.Контрагент;
//					AccountingContract = ЛицевойСчет.Contract;
//				EndIf;
//			Else
//				If ЗначениеЗаполнено(Гостиница) Тогда
//					If AccountingCustomer <> Гостиница.IndividualsCustomer Тогда
//						AccountingCustomer = Гостиница.IndividualsCustomer;
//						AccountingContract = Гостиница.IndividualsContract;
//					EndIf;
//				Else
//					AccountingCustomer = Справочники.Контрагенты.EmptyRef();
//					AccountingContract = Справочники.Договора.EmptyRef();
//				EndIf;
//			EndIf;
//		EndIf;
//	Else
//		If ЗначениеЗаполнено(ЛицевойСчет.Контрагент) Тогда
//			If AccountingCustomer <> ЛицевойСчет.Контрагент Тогда
//				AccountingCustomer = ЛицевойСчет.Контрагент;
//				AccountingContract = ЛицевойСчет.Contract;
//			EndIf;
//		Else
//			If ЗначениеЗаполнено(Гостиница) Тогда
//				If AccountingCustomer <> Гостиница.IndividualsCustomer Тогда
//					AccountingCustomer = Гостиница.IndividualsCustomer;
//					AccountingContract = Гостиница.IndividualsContract;
//				EndIf;
//			Else
//				AccountingCustomer = Справочники.Контрагенты.EmptyRef();
//				AccountingContract = Справочники.Договора.EmptyRef();
//			EndIf;
//		EndIf;
//	EndIf;
//	If ЛицевойСчет.GuestGroup <> GuestGroup Тогда
//		GuestGroup = ЛицевойСчет.GuestGroup;
//	EndIf;
//КонецПроцедуры //pmFillCustomerContractAndGuestGroup

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
//		|	AND (СпособОплаты.CardType = &qCardType
//		|			OR &qIgnoreCardType)
//		|
//		|ORDER BY
//		|	СпособОплаты.ПорядокСортировки";
//		vQry.SetParameter("qIsByCash", PaymentMethod.IsByCash);
//		vQry.SetParameter("qIsByCreditCard", PaymentMethod.IsByCreditCard);
//		vQry.SetParameter("qIsByBankTransfer", PaymentMethod.IsByBankTransfer);
//		vQry.SetParameter("qIgnoreForReturnOnly", ?(ЗначениеЗаполнено(CashRegister), CashRegister.CashReturnDirectlyFromCashBoxIsAllowed, False));
//		vQry.SetParameter("qCardType", PaymentMethod.CardType);
//		vQry.SetParameter("qIgnoreCardType", НЕ ЗначениеЗаполнено(PaymentMethod.CardType));
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
//Процедура pmCalculateTotalsByPaymentSections() Экспорт
//	SumInFolioCurrency = PaymentSections.Total("SumInFolioCurrency");
//	VATSumInFolioCurrency = PaymentSections.Total("VATSumInFolioCurrency");
//	Sum = PaymentSections.Total("Сумма");
//	VATSum = PaymentSections.Total("СуммаНДС");
//КонецПроцедуры //pmCalculateTotalsByPaymentSections

////-----------------------------------------------------------------------------
//Процедура pmRecalculateSums() Экспорт
//	If PaymentSections.Count() > 0 Тогда
//		For Each vPSRow In PaymentSections Do
//			vPSRow.VATSum = cmCalculateVATSum(vPSRow.VATRate, vPSRow.Sum);

//			vPSRow.SumInFolioCurrency = Round(cmConvertCurrencies(vPSRow.Sum, PaymentCurrency, PaymentCurrencyExchangeRate, 
//			                                                      FolioCurrency, FolioCurrencyExchangeRate, 
//			                                                      ExchangeRateDate, Гостиница), 2);
//			vPSRow.VATSumInFolioCurrency = cmCalculateVATSum(vPSRow.VATRate, vPSRow.SumInFolioCurrency);
//		EndDo;
//		pmCalculateTotalsByPaymentSections();
//	Else
//		VATSum = cmCalculateVATSum(VATRate, Sum);
//		SumInFolioCurrency = Round(cmConvertCurrencies(Sum, PaymentCurrency, PaymentCurrencyExchangeRate, 
//		                                               FolioCurrency, FolioCurrencyExchangeRate, 
//		                                               ExchangeRateDate, Гостиница), 2);
//		VATSumInFolioCurrency = cmCalculateVATSum(VATRate, SumInFolioCurrency);
//	EndIf;
//КонецПроцедуры //pmRecalculateSums

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
//	FolioCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, FolioCurrency, Date);
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
//		If ЗначениеЗаполнено(Фирма.VATRate) Тогда
//			VATRate = Фирма.VATRate;
//		EndIf;
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
//	pmFillCustomerContractAndGuestGroup();
//	
//	// Fill payment section
//	PaymentSection = ЛицевойСчет.PaymentSection;
//	// Fill VAT rate from the section
//	If ЗначениеЗаполнено(PaymentSection) Тогда
//		If ЗначениеЗаполнено(PaymentSection.VATRate) Тогда
//			VATRate = PaymentSection.VATRate;
//		EndIf;
//	EndIf;
//	
//	// Set default payment method for return
//	pmSetDefaultPaymentMethodForReturn();

//	// The return could be done only if the folio balance is negative
//	// otherwise use document Payment
//	vFolioObj = ЛицевойСчет.GetObject();
//	vFolioBalance = vFolioObj.pmGetBalance('39991231235959');
//	SumInFolioCurrency = 0;
//	If vFolioBalance < 0 Тогда
//		SumInFolioCurrency = -vFolioBalance;
//	EndIf;
//	VATSumInFolioCurrency = cmCalculateVATSum(VATRate, SumInFolioCurrency);
//	
//	Sum = Round(cmConvertCurrencies(SumInFolioCurrency, FolioCurrency, FolioCurrencyExchangeRate, PaymentCurrency, PaymentCurrencyExchangeRate, ExchangeRateDate, Гостиница), 2);
//	VATSum = cmCalculateVATSum(VATRate, Sum);
//	
//	// Try to get per payment section balances
//	If ЗначениеЗаполнено(Гостиница) And Гостиница.SplitFolioBalanceByPaymentSections Тогда
//		vPaymentSectionBalances = vFolioObj.pmGetPaymentSectionBalances('39991231235959');
//		For Each vPSBalancesRow In vPaymentSectionBalances Do
//			If vPSBalancesRow.SumBalance < 0 Тогда
//				vPSRow = PaymentSections.Add();
//				vPSRow.PaymentSection = vPSBalancesRow.PaymentSection;
//				vPSRow.СтавкаНДС = ?(ЗначениеЗаполнено(vPSBalancesRow.PaymentSection), ?(ЗначениеЗаполнено(vPSBalancesRow.PaymentSection.СтавкаНДС), vPSBalancesRow.PaymentSection.СтавкаНДС, VATRate), VATRate);
//				vPSRow.SumInFolioCurrency = -vPSBalancesRow.SumBalance;
//				vPSRow.VATSumInFolioCurrency = cmCalculateVATSum(vPSRow.СтавкаНДС, vPSRow.SumInFolioCurrency);
//				vPSRow.Сумма = Round(cmConvertCurrencies(vPSRow.SumInFolioCurrency, FolioCurrency, FolioCurrencyExchangeRate, PaymentCurrency, PaymentCurrencyExchangeRate, ExchangeRateDate, Гостиница), 2);
//				vPSRow.СуммаНДС = cmCalculateVATSum(vPSRow.СтавкаНДС, vPSRow.Сумма);
//			EndIf;
//		EndDo;
//		If PaymentSections.Count() = 0 Тогда
//			vPSRow = PaymentSections.Add();
//		EndIf;
//		pmCalculateTotalsByPaymentSections();
//	EndIf;
//КонецПроцедуры //FillByFolio

////-----------------------------------------------------------------------------
//Процедура FillByPayment(pPayment)
//	If НЕ ЗначениеЗаполнено(pPayment) Тогда
//		Return;
//	EndIf;
//	If НЕ cmCheckUserPermissions("HavePermissionToReturnPayments") Тогда
//		ВызватьИсключение NStr("en='You do not have rights to return payments!';ru='У вас нет прав на оформление возвратов!';de='Sie haben keine Rechte, eine Rückvergütung zu realisieren!'");
//	EndIf;
//	
//	If ЗначениеЗаполнено(pPayment.Гостиница) Тогда
//		If Гостиница <> pPayment.Гостиница Тогда
//			Гостиница = pPayment.Гостиница;
//		EndIf;
//	EndIf;
//	
//	FillPropertyValues(ThisObject, pPayment, , "Number, Date, Автор, DeletionMark, Posted, Гостиница, ReferenceNumber, AuthorizationCode, Примечания, SlipText");
//	Payment = pPayment;
//	
//	If pPayment.ОтделОплаты.Count() > 0 Тогда
//		For Each vPaymentPSRow In pPayment.ОтделОплаты Do
//			vReturnPSRow = PaymentSections.Add();
//			FillPropertyValues(vReturnPSRow, vPaymentPSRow);
//		EndDo;
//	EndIf;
//	
//	// Set default payment method for return
//	pmSetDefaultPaymentMethodForReturn();
//	
//	// Set return sum to zero if this is return by credit card
//	If ЗначениеЗаполнено(Payment) And ЗначениеЗаполнено(PaymentMethod) And PaymentMethod.IsByCreditCard And 
//	   PaymentMethod.BookByCashRegister And PaymentMethod.PrintCheque Тогда
//		Sum = 0;
//		SumInFolioCurrency = 0;
//		VATSum = 0;
//		VATSumInFolioCurrency = 0;
//	
//		For Each vReturnPSRow In PaymentSections Do
//			vReturnPSRow.Sum = 0;
//			vReturnPSRow.SumInFolioCurrency = 0;
//			vReturnPSRow.VATSum = 0;
//			vReturnPSRow.VATSumInFolioCurrency = 0;
//		EndDo;
//	EndIf;
//КонецПроцедуры //FillByPayment

////-----------------------------------------------------------------------------
//Процедура Filling(pBase)
//	// Fill attributes with default values
//	pmFillAttributesWithDefaultValues();
//	// Fill from the base
//	If ЗначениеЗаполнено(pBase) Тогда
//		If TypeOf(pBase) = Type("DocumentRef.СчетПроживания") Тогда
//			FillByFolio(pBase);
//		ElsIf TypeOf(pBase) = Type("DocumentRef.Платеж") Тогда
//			FillByPayment(pBase);
//		EndIf;
//	EndIf;
//КонецПроцедуры //Filling

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
//			WriteLogEvent(NStr("en='SuspiciousEvents.ReturnSetDeletionMark';de='SuspiciousEvents.ReturnSetDeletionMark';ru='СигналыОПодозрительныхДействиях.УстановкаПометкиНаУдалениеВВозврате'"), EventLogLevel.Warning, Metadata(), Ref, NStr("en='Set document deletion mark';ru='Установка отметки удаления';de='Erstellung der Löschmarkierung'"));
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
//	WriteLogEvent(NStr("en='SuspiciousEvents.ReturnDeletion';de='SuspiciousEvents.ReturnDeletion';ru='СигналыОПодозрительныхДействиях.УдалениеВозврата'"), EventLogLevel.Warning, Metadata(), Ref, NStr("en='Document deletion';ru='Непосредственное удаление';de='Unmittelbare Löschung'"));
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
//	GiftCertificate = "";
//КонецПроцедуры //OnCopy

////-----------------------------------------------------------------------------
//Процедура UndoPosting(pCancel)
//	If ThisObject.DataExchange.Load Тогда
//		Return;
//	EndIf;
//	// Accounts
//	vAccSet = AccumulationRegisters.Взаиморасчеты.CreateRecordSet();
//	vAccSet.Filter.Recorder.Set(Ref);
//	vAccSet.Read();
//	vAccSet.Clear();
//	vAccSet.Write(True);
//	// Repost settlements
//	pmRepostSettlements();
//КонецПроцедуры //UndoPosting

////-----------------------------------------------------------------------------
//WasPosted = True;
