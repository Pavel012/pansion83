//Перем WasPosted;
//
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
//			Movement.Сумма = vPSRow.SumInFolioCurrency;
//			
//			// Attributes
//			Movement.SumInPaymentCurrency = vPSRow.Sum;
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
//		Movement.Сумма = SumInFolioCurrency;
//		
//		// Attributes
//		Movement.SumInPaymentCurrency = Sum;
//	EndIf;
//	
//	RegisterRecords.Депозиты.Write();
//КонецПроцедуры //PostToDeposits
//
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
//			Movement.Сумма = vPSRow.SumInFolioCurrency;
//			
//			// Attributes
//			Movement.СуммаНДС = vPSRow.VATSumInFolioCurrency;
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
//		Movement.Сумма = SumInFolioCurrency;
//		
//		// Attributes
//		Movement.СуммаНДС = VATSumInFolioCurrency;
//		
//		// Payment section
//		If ЗначениеЗаполнено(Гостиница) And НЕ Гостиница.SplitFolioBalanceByPaymentSections Тогда
//			Movement.PaymentSection = Справочники.ОтделОплаты.EmptyRef();
//		EndIf;
//	EndIf;
//
//	RegisterRecords.Взаиморасчеты.Write();
//КонецПроцедуры //PostToAccounts
//
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
//			Movement.SumReceipt = vPSRow.Sum;
//			Movement.VATSumReceipt = vPSRow.VATSum;
//			Movement.SumExpense = 0;
//			Movement.VATSumExpense = 0;
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
//		Movement.SumReceipt = Sum;
//		Movement.VATSumReceipt = VATSum;
//		Movement.SumExpense = 0;
//		Movement.VATSumExpense = 0;
//	EndIf;
//	
//	RegisterRecords.Платежи.Write();
//КонецПроцедуры //PostToPayments
//
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
//			Movement.Сумма = vPSRow.SumInFolioCurrency;
//			
//			// Attributes
//			Movement.СуммаНДС = vPSRow.VATSumInFolioCurrency;
//			Movement.УчетнаяДата = BegOfDay(Date);
//
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
//		Movement.Сумма = SumInFolioCurrency;
//		
//		// Attributes
//		Movement.СуммаНДС = VATSumInFolioCurrency;
//		Movement.УчетнаяДата = BegOfDay(Date);
//
//		RegisterRecords.ВзаиморасчетыКонтрагенты.Write();
//	EndIf;
//КонецПроцедуры //PostToCustomerAccounts
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
//		Movement.СуммаНДС = cmCalculateVATSum(VATRate, Movement.Сумма);
//		Movement.СтавкаНДС = VATRate;
//		Movement.УчетнаяДата = BegOfDay(Date);
//		If ЗначениеЗаполнено(ЛицевойСчет) Тогда
//			Movement.Клиент = ЛицевойСчет.Client;
//			Movement.НомерРазмещения = ЛицевойСчет.ГруппаНомеров;
//		EndIf;
//
//		RegisterRecords.ВзаиморасчетыПоСчетам.Write();
//	EndIf;
//КонецПроцедуры //PostToInvoiceAccounts
//
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
//			Movement.Сумма = vPSRow.Sum;
//			Movement.СуммаНДС = vPSRow.VATSum;
//			Movement.PaymentSum = vPSRow.Sum;
//			Movement.VATPaymentSum = vPSRow.VATSum;
//			Movement.ReturnSum = 0;
//			Movement.VATReturnSum = 0;
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
//		Movement.Сумма = Sum;
//		Movement.СуммаНДС = VATSum;
//		Movement.PaymentSum = Sum;
//		Movement.VATPaymentSum = VATSum;
//		Movement.ReturnSum = 0;
//		Movement.VATReturnSum = 0;
//	EndIf;			
//	
//	RegisterRecords.ВыручкаПоСменам.Write();
//КонецПроцедуры //PostToCashRegisterDailyReceipts
//
////-----------------------------------------------------------------------------
//Процедура PostToCashInCashRegisters()
//	Movement = RegisterRecords.НаличныеКасса.Add();
//	
//	Movement.Period = Date;
//	Movement.RecordType = AccumulationRecordType.Receipt;
//	Movement.Валюта = PaymentCurrency;
//	
//	FillPropertyValues(Movement, ThisObject);
//
//	RegisterRecords.НаличныеКасса.Write();
//КонецПроцедуры //PostToCashInCashRegisters
//
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
//	Movement.Сумма = SumInFolioCurrency;
//	
//	RegisterRecords.ПлатежиУслуги.Write();
//КонецПроцедуры //PostToPaymentServices
//
////-----------------------------------------------------------------------------
//Процедура ClosePreauthorisation()
//	If ЗначениеЗаполнено(Preauthorisation) And Preauthorisation.Posted And 
//	   ЗначениеЗаполнено(Preauthorisation.Status) And 
//	   (Preauthorisation.Status = Перечисления.PreauthorisationStatuses.Authorised Or Preauthorisation.Status = Перечисления.PreauthorisationStatuses.Archived) And 
//	   ЗначениеЗаполнено(PaymentMethod) And PaymentMethod.IsByCreditCard And 
//	   PaymentMethod = Preauthorisation.PaymentMethod Тогда
//		// Initialize amount of preauthorizations being completed
//		vAmountCompleted = 0;
//		// Build list of preauthorisations to complete
//		vQry = New Query();
//		vQry.Text = 
//		"SELECT
//		|	ПреАвторизация.Ref,
//		|	ПреАвторизация.SumInFolioCurrency
//		|FROM
//		|	Document.ПреАвторизация AS ПреАвторизация
//		|WHERE
//		|	ПреАвторизация.Posted
//		|	AND ПреАвторизация.PointInTime >= &qPeriodFrom
//		|	AND ПреАвторизация.СчетПроживания = &qFolio
//		|	AND ПреАвторизация.СпособОплаты = &qPaymentMethod
//		|	AND ПреАвторизация.Status = &qStatus
//		|
//		|ORDER BY
//		|	ПреАвторизация.PointInTime";
//		vQry.SetParameter("qPeriodFrom", Preauthorisation.PointInTime());
//		vQry.SetParameter("qFolio", ЛицевойСчет);
//		vQry.SetParameter("qPaymentMethod", PaymentMethod);
//		vQry.SetParameter("qStatus", Перечисления.PreauthorisationStatuses.Authorised);
//		vDocs = vQry.Execute().Unload();
//		// Check if current preauthorization is in the resulting table
//		If vDocs.Find(Preauthorisation, "Ref") = Неопределено Тогда
//			vDocsRow = vDocs.Add();
//			vDocsRow.Ref = Preauthorisation;
//			vDocsRow.SumInFolioCurrency = Preauthorisation.SumInFolioCurrency;
//		EndIf;
//		For Each vDocsRow In vDocs Do
//			If vAmountCompleted < SumInFolioCurrency Тогда
//				vDocObj = vDocsRow.Ref.GetObject();
//				vDocObj.Status = Перечисления.PreauthorisationStatuses.Completed;
//				vDocObj.Write(DocumentWriteMode.Posting);
//				vAmountCompleted = vAmountCompleted + vDocObj.SumInFolioCurrency;
//			Else
//				Break;
//			EndIf;
//		EndDo;
//	Else
//		If ЗначениеЗаполнено(Preauthorisation) Тогда
//			Preauthorisation = Неопределено;
//		EndIf;
//	EndIf;
//КонецПроцедуры //ClosePreauthorisation
//
////-----------------------------------------------------------------------------
//Процедура FillHotelProductPaymentDate()
//	If ЗначениеЗаполнено(ЛицевойСчет) Тогда
//		If ЗначениеЗаполнено(ЛицевойСчет.HotelProduct) Тогда
//			If НЕ ЗначениеЗаполнено(ЛицевойСчет.HotelProduct.PaymentDate) Тогда
//				vHPObj = ЛицевойСчет.HotelProduct.GetObject();
//				vPaymentMethod = Неопределено;
//				vHPObj.PaymentDate = vHPObj.pmGetHotelProductPaymentDate(vPaymentMethod);
//				If ЗначениеЗаполнено(vPaymentMethod) Тогда
//					vHPObj.СпособОплаты = vPaymentMethod;
//				EndIf;
//				vHPObj.Write();
//			EndIf;
//		EndIf;
//		If ЗначениеЗаполнено(ЛицевойСчет.ParentDoc) And 
//		   (TypeOf(ЛицевойСчет.ParentDoc) = Type("DocumentRef.Размещение") Or TypeOf(ЛицевойСчет.ParentDoc) = Type("DocumentRef.Reservation")) Тогда
//			If ЗначениеЗаполнено(ЛицевойСчет.ParentDoc.ПутевкаКурсовка) Тогда
//				If НЕ ЗначениеЗаполнено(ЛицевойСчет.ParentDoc.ПутевкаКурсовка.PaymentDate) Тогда
//					vHPObj = ЛицевойСчет.ParentDoc.ПутевкаКурсовка.GetObject();
//					vPaymentMethod = Неопределено;
//					vHPObj.PaymentDate = vHPObj.pmGetHotelProductPaymentDate(vPaymentMethod);
//					If ЗначениеЗаполнено(vPaymentMethod) Тогда
//						vHPObj.СпособОплаты = vPaymentMethod;
//					EndIf;
//					If НЕ ЗначениеЗаполнено(vHPObj.PaymentDate) Тогда
//						vHPObj.PaymentDate = Date;
//					EndIf;
//					vHPObj.Write();
//				EndIf;
//			EndIf;
//		EndIf;
//	EndIf;
//КонецПроцедуры //FillHotelProductPaymentDate
//
////-----------------------------------------------------------------------------
//Процедура WriteOffBonuses()
//	If ЗначениеЗаполнено(PaymentMethod) And PaymentMethod.IsByBonuses And 
//	   ЗначениеЗаполнено(PaymentMethod.DiscountType) And 
//	   PaymentMethod.DiscountType.BonusCalculationFactor <> 0 Тогда
//		vDimension = Неопределено;
//		If PaymentMethod.DiscountType.AccumulatingDiscountDimension = Перечисления.AccumulatingDiscountDimensions.ДисконтКарт Тогда
//			If ЗначениеЗаполнено(ParentDoc) And ЗначениеЗаполнено(ParentDoc.ДисконтКарт) Тогда
//				vDimension = ParentDoc.ДисконтКарт;
//			EndIf;
//		ElsIf PaymentMethod.DiscountType.AccumulatingDiscountDimension = Перечисления.AccumulatingDiscountDimensions.Клиент Тогда
//			If ЗначениеЗаполнено(Payer) And TypeOf(Payer) = Type("CatalogRef.Клиенты") Тогда
//				vDimension = Payer;
//			EndIf;
//		EndIf;
//		If vDimension <> Неопределено Тогда
//			// Get payment currency bonus calculation rate
//			vRates = InformationRegisters.КурсВалют.SliceLast(Date, New Structure("Гостиница, Валюта", Гостиница, PaymentCurrency));
//			If vRates.Count() > 0 Тогда
//				vRatesRow = vRates.Get(0);
//				vBonusRate = vRatesRow.BonusRate;
//				vBonus2WriteOff = Sum * vBonusRate;
//				If vBonus2WriteOff <> 0 Тогда
//					Movement = RegisterRecords.НакопитСкидки.Add();
//					If vBonus2WriteOff > 0 Тогда
//						Movement.RecordType = AccumulationRecordType.Expense;
//					Else
//						Movement.RecordType = AccumulationRecordType.Receipt;
//					EndIf;
//					Movement.Period = Date;
//					Movement.ТипСкидки = PaymentMethod.DiscountType;
//					Movement.ИзмерениеСкидки = vDimension;
//					Movement.ГруппаГостей = Справочники.ГруппыГостей.EmptyRef();
//					Movement.Ресурс = 0;
//					Movement.Бонус = vBonus2WriteOff;
//				EndIf;
//			EndIf;
//		EndIf;
//	EndIf;
//КонецПроцедуры //WriteOffBonuses
//
////-----------------------------------------------------------------------------
//Процедура PostToGiftCertificates()
//	vGiftCertificatesArePerHotel = Constants.GiftCertificatesArePerHotel.Get();
//	
//	// Write gift certificate information record
//	If НЕ cmGiftCertificateExists(Гостиница, GiftCertificate) Тогда
//		vGiftCertificatesRM = InformationRegisters.ПодарочСертификатСведения.CreateRecordManager();
//		vGiftCertificatesRM.Period = Date;
//		vGiftCertificatesRM.Гостиница = ?(vGiftCertificatesArePerHotel, Гостиница, Справочники.Гостиницы.EmptyRef());
//		vGiftCertificatesRM.GiftCertificate = TrimAll(GiftCertificate);
//		vNumMonth = Constants.СрокДействияСертификатов.Get();
//		If vNumMonth > 0 Тогда
//			vGiftCertificatesRM.BlockAuthor = Автор;
//			vGiftCertificatesRM.BlockDate = AddMonth(BegOfDay(Date), vNumMonth);
//			vGiftCertificatesRM.BlockReason = "en='Is expired on " + Format(vGiftCertificatesRM.BlockDate, "DF=dd.MM.yyyy") + ", was payed on " + Format(vGiftCertificatesRM.Period, "DF=dd.MM.yyyy") + "!'; 
//			                                  |ru='Срок действия истек " + Format(vGiftCertificatesRM.BlockDate, "DF=dd.MM.yyyy") + ", был оплачен " + Format(vGiftCertificatesRM.Period, "DF=dd.MM.yyyy") + "!'";
//		EndIf;
//		vGiftCertificatesRM.Write(True);
//	EndIf;
//	
//	// Write to gift certificate balances
//	Movement = RegisterRecords.ПодарочСертификатСведения.Add();
//	Movement.Period = Date;
//	
//	// Fill dimensions
//	Movement.Гостиница = ?(vGiftCertificatesArePerHotel, Гостиница, Справочники.Гостиницы.EmptyRef());
//	Movement.GiftCertificate = TrimAll(GiftCertificate);
//	
//	// Fill resource
//	Movement.Amount = Round(cmConvertCurrencies(Sum, PaymentCurrency, PaymentCurrencyExchangeRate, Гостиница.ReportingCurrency, , ExchangeRateDate, Гостиница), 2);
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
//	If  ЗначениеЗаполнено(PaymentMethod) Тогда
//		If PaymentMethod.BookByCashRegister Тогда
//			PostToCashRegisterDailyReceipts();
//			// Post to cash in cash registers
//			If PaymentMethod.IsByCash Тогда
//				PostToCashInCashRegisters();
//			EndIf;
//		EndIf;
//	EndIf;
//	
//	// 7. Post to Payment services
//	If НЕ IsBlankString(GiftCertificate) And ЗначениеЗаполнено(PaymentMethod) And PaymentMethod.IsByGiftCertificate Or 
//	   IsBlankString(GiftCertificate) Тогда
//		If Гостиница.DoPaymentsDistributionToServices Тогда
//			PostToPaymentServices();
//		EndIf;
//	EndIf;
//	
//	// 8. Close preauthorisation
//	If ЗначениеЗаполнено(Preauthorisation) Тогда
//		ClosePreauthorisation();
//	EndIf;
//	
//	If НЕ IsBlankString(GiftCertificate) And ЗначениеЗаполнено(PaymentMethod) And PaymentMethod.IsByGiftCertificate Or 
//	   IsBlankString(GiftCertificate) Тогда
//		// 9. Repost settlements if any
//		pmRepostSettlements();
//	
//		// 10. Set hotel product payment date
//		FillHotelProductPaymentDate();
//	EndIf;
//	
//	// 11. Write off bonuses
//	WriteOffBonuses();
//	
//	// 12. Post to gift certificates
//	If ЗначениеЗаполнено(Гостиница) And ЗначениеЗаполнено(Гостиница.ReportingCurrency) And 
//	   ЗначениеЗаполнено(PaymentMethod) And НЕ IsBlankString(GiftCertificate) Тогда
//		PostToGiftCertificates();
//	EndIf;
//	
//	// 13. Update folio accounting number
//	If НЕ IsBlankString(GiftCertificate) And ЗначениеЗаполнено(PaymentMethod) And PaymentMethod.IsByGiftCertificate Or 
//	   IsBlankString(GiftCertificate) Тогда
//		If ЗначениеЗаполнено(ЛицевойСчет) And ЗначениеЗаполнено(Гостиница) And Гостиница.UseFolioAccountingNumberPrefix Тогда
//			vHotelObj = Гостиница.GetObject();
//			vFolioAccountingNumberPrefix = vHotelObj.pmGetFolioAccountingNumberPrefix();
//			If НЕ IsBlankString(vFolioAccountingNumberPrefix) And 
//			   (Upper(Left(TrimR(ЛицевойСчет.Number), StrLen(vFolioAccountingNumberPrefix))) <> Upper(vFolioAccountingNumberPrefix) Or
//			   IsBlankString(vFolioAccountingNumberPrefix) And НЕ cmIsNumber(TrimAll(ЛицевойСчет.Number)))  Тогда
//				vFolioObj = ЛицевойСчет.GetObject();
//				vFolioObj.SetNewNumber(vFolioAccountingNumberPrefix);
//				vFolioObj.Write(DocumentWriteMode.Write);
//			EndIf;
//		EndIf;
//	EndIf;
//	
//	// 14. Send payment SMS
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
//
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
//
////-----------------------------------------------------------------------------
//Function pmCheckDocumentAttributes(pMessage, pAttributeInErr) Экспорт
//	vHasErrors = False;
//	pMessage = "";
//	pAttributeInErr = "";
//	vMsgTextRu = "";
//		If НЕ ЗначениеЗаполнено(Гостиница) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Гостиница> должен быть заполнен!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "Гостиница", pAttributeInErr);
//	EndIf;
//	If НЕ ЗначениеЗаполнено(Фирма) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Фирма> должен быть заполнен!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "Фирма", pAttributeInErr);
//	EndIf;
//	If НЕ ЗначениеЗаполнено(ЛицевойСчет) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Лицевой счет> должен быть заполнен!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "СчетПроживания", pAttributeInErr);
//	Else
//		If ЛицевойСчет.DeletionMark Тогда
//			vHasErrors = True; 
//			vMsgTextRu = vMsgTextRu + "<Лицевой счет> помечен на удаление!" + Chars.LF;
//			pAttributeInErr = ?(pAttributeInErr = "", "СчетПроживания", pAttributeInErr);
//		EndIf;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(PaymentMethod) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Способ оплаты> должен быть заполнен!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "СпособОплаты", pAttributeInErr);
//	EndIf;
//	If НЕ ЗначениеЗаполнено(PaymentCurrency) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Валюта платежа> должен быть заполнен!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "PaymentCurrency", pAttributeInErr);
//	EndIf;
//	If НЕ ЗначениеЗаполнено(ExchangeRateDate) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Дата курса> должен быть заполнен!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "ExchangeRateDate", pAttributeInErr);
//	EndIf;
//	If ЗначениеЗаполнено(PaymentMethod) Тогда
//		If ЗначениеЗаполнено(ПараметрыСеанса.РабочееМесто) Тогда
//			If НЕ ПараметрыСеанса.РабочееМесто.HasConnectionToCreditCardsProcessingSystem Or 
//			   PaymentMethod.ExternalBankTerminalIsUsed Тогда
//				If PaymentMethod.AuthorizationCodeIsRequired And IsBlankString(AuthorizationCode) Тогда
//					vHasErrors = True; 
//					vMsgTextRu = vMsgTextRu + "При оплате кредитной картой должен быть введен реквизит <Код авторизации>!" + Chars.LF;
//					pAttributeInErr = ?(pAttributeInErr = "", "AuthorizationCode", pAttributeInErr);
//				EndIf;
//				If PaymentMethod.ReferenceCodeIsRequired And IsBlankString(ReferenceNumber) Тогда
//					vHasErrors = True; 
//					vMsgTextRu = vMsgTextRu + "При оплате кредитной картой должен быть введен реквизит <Референс НомерРазмещения>!" + Chars.LF;
//					pAttributeInErr = ?(pAttributeInErr = "", "ReferenceNumber", pAttributeInErr);
//				EndIf;
//			EndIf;
//		EndIf;
//		If НЕ cmCheckUserPermissions("HavePermissionToDoCashAndCreditCardPaymentsWithoutCashRegister") Тогда
//			If PaymentMethod.BookByCashRegister Тогда
//							EndIf;
//		EndIf;
//	EndIf;
//	If ЗначениеЗаполнено(Гостиница) And ЗначениеЗаполнено(PaymentMethod) And PaymentMethod.BookByCashRegister Тогда
//		If НЕ cmCheckUserPermissions("HavePermissionToPostPaymentsWithEmptyPaymentSections") Тогда
//			If НЕ Гостиница.SplitFolioBalanceByPaymentSections Тогда
//				If НЕ ЗначениеЗаполнено(PaymentSection) Тогда
//					vHasErrors = True; 
//					vMsgTextRu = vMsgTextRu + "Не указана кассовая секция (отдел)!" + Chars.LF;
//					pAttributeInErr = ?(pAttributeInErr = "", "PaymentSection", pAttributeInErr);
//				EndIf;
//			Else
//				For Each vPSRow In PaymentSections Do
//					If vPSRow.Sum > 0 And НЕ ЗначениеЗаполнено(vPSRow.PaymentSection) Тогда
//						vHasErrors = True; 
//						vMsgTextRu = vMsgTextRu + "В строке " + Format(vPSRow.LineNumber, "ND=4; NFD=0; NG=") + " не указана кассовая секция (отдел)!" + Chars.LF;
//						pAttributeInErr = ?(pAttributeInErr = "", "PaymentSection", pAttributeInErr);
//					EndIf;
//				EndDo;
//			EndIf;
//		EndIf;
//	EndIf;
//	If IsBlankString(ExternalCode) Тогда
//		If Sum < 0 Тогда
//			vHasErrors = True; 
//			vMsgTextRu = vMsgTextRu + "Для оформления возврата необходимо использовать документ ""Возврат""!" + Chars.LF;
//			pAttributeInErr = ?(pAttributeInErr = "", "Сумма", pAttributeInErr);
//		Else
//			For Each vPSRow In PaymentSections Do
//				If vPSRow.Sum < 0 Тогда
//					vHasErrors = True; 
//					vMsgTextRu = vMsgTextRu + "Для оформления возврата необходимо использовать документ ""Возврат""!" + Chars.LF;
//					pAttributeInErr = ?(pAttributeInErr = "", "ОтделОплаты", pAttributeInErr);
//				EndIf;
//			EndDo;
//		EndIf;
//	EndIf;
//	If ЗначениеЗаполнено(AccountingCustomer) And AccountingCustomer.NonResident Тогда
//		If ЗначениеЗаполнено(PaymentMethod) And PaymentMethod.PrintCheque And  
//		  (PaymentMethod.IsByCash Or PaymentMethod.IsByCreditCard) Тогда
//			vHasErrors = True; 
//			vMsgTextRu = vMsgTextRu + "Принимать платежи наличными от контрагентов нерезидентов запрещено!" + Chars.LF;
//			pAttributeInErr = ?(pAttributeInErr = "", "СпособОплаты", pAttributeInErr);
//		EndIf;
//	EndIf;
//	vGiftCertificateNotFound = False;
//	If ЗначениеЗаполнено(PaymentMethod) And PaymentMethod.IsByGiftCertificate Тогда
//		If IsBlankString(GiftCertificate) Тогда
//			vHasErrors = True; 
//			vMsgTextRu = vMsgTextRu + "Подарочный сертификат не указан!" + Chars.LF;
//            pAttributeInErr = ?(pAttributeInErr = "", "GiftCertificate", pAttributeInErr);
//		Else
//			// Try to find gift certificate
//			If НЕ cmGiftCertificateExists(Гостиница, GiftCertificate) Тогда
//				vGiftCertificateNotFound = True;
//				vHasErrors = True; 
//				vMsgTextRu = vMsgTextRu + "Подарочный сертификат не найден!" + Chars.LF;
//				pAttributeInErr = ?(pAttributeInErr = "", "GiftCertificate", pAttributeInErr);
//			EndIf;
//		EndIf;
//	EndIf;
//	If ЗначениеЗаполнено(Гостиница) And ЗначениеЗаполнено(Гостиница.ReportingCurrency) And ЗначениеЗаполнено(PaymentMethod) And 
//	   НЕ IsBlankString(GiftCertificate) And НЕ vGiftCertificateNotFound Тогда
//		If НЕ Posted And PaymentMethod.IsByGiftCertificate Тогда
//			// Check if certificate is blocked
//			vBlockReason = "";
//			If cmGiftCertificateIsBlocked(Гостиница, GiftCertificate, Date, vBlockReason) Тогда
//				vHasErrors = True; 
//				vMsgTextRu = vMsgTextRu + "Выбранный сертификат заблокирован (" + vBlockReason + ")" + Chars.LF;
//				pAttributeInErr = ?(pAttributeInErr = "", "GiftCertificate", pAttributeInErr);
//			EndIf;
//			// Check payment amount
//			vPaymentAmount = Round(cmConvertCurrencies(Sum, PaymentCurrency, PaymentCurrencyExchangeRate, Гостиница.ReportingCurrency, , ExchangeRateDate, Гостиница), 2);
//			vGiftCertificateBalance = cmGetGiftCertificateBalance(Гостиница, GiftCertificate, Date);
//			If vGiftCertificateBalance <= 0 Тогда
//				vHasErrors = True; 
//				vMsgTextRu = vMsgTextRu + "Подарочный сертификат уже использован!" + Chars.LF;
//				pAttributeInErr = ?(pAttributeInErr = "", "GiftCertificate", pAttributeInErr);
//			ElsIf vPaymentAmount > vGiftCertificateBalance Тогда
//				vHasErrors = True; 
//				vMsgTextRu = vMsgTextRu + "Сумма оплаты превышает остаток по подарочному сертификату (" + cmFormatSum(vGiftCertificateBalance, Гостиница.ReportingCurrency) + ")!" + Chars.LF;
//				pAttributeInErr = ?(pAttributeInErr = "", "Сумма", pAttributeInErr);
//			EndIf;
//		EndIf;
//	EndIf;
//	If vHasErrors Тогда
//		pMessage = "ru='" + TrimAll(vMsgTextRu) +  "';";
//	Else
//		If НЕ ЗначениеЗаполнено(AccountingCustomer) And ЗначениеЗаполнено(Гостиница) And ЗначениеЗаполнено(Гостиница.IndividualsCustomer) Тогда
//			AccountingCustomer = Гостиница.IndividualsCustomer;
//			AccountingContract = Гостиница.IndividualsContract;
//		EndIf;
//	EndIf;
//	Return vHasErrors;
//EndFunction //CheckDocumentAttributes
//
////-----------------------------------------------------------------------------
//Процедура pmFillAuthorAndDate() Экспорт
//	Date = CurrentDate();
//	Автор = ПараметрыСеанса.ТекПользователь;
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
//
////-----------------------------------------------------------------------------
//Процедура pmCalculateTotalsByPaymentSections() Экспорт
//	SumInFolioCurrency = PaymentSections.Total("SumInFolioCurrency");
//	VATSumInFolioCurrency = PaymentSections.Total("VATSumInFolioCurrency");
//	Sum = PaymentSections.Total("Сумма");
//	VATSum = PaymentSections.Total("СуммаНДС");
//КонецПроцедуры //pmCalculateTotalsByPaymentSections
//
////-----------------------------------------------------------------------------
//Процедура pmRecalculateSums() Экспорт
//	If PaymentSections.Count() > 0 Тогда
//		For Each vPSRow In PaymentSections Do
//			vPSRow.VATSum = cmCalculateVATSum(vPSRow.VATRate, vPSRow.Sum);
//
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
//	// The payment could be done only if the folio balance is positive
//	// otherwise use document Return
//	vFolioObj = ЛицевойСчет.GetObject();
//	vFolioBalance = vFolioObj.pmGetBalance('39991231235959');
//	SumInFolioCurrency = 0;
//	If vFolioBalance > 0 Тогда
//		SumInFolioCurrency = vFolioBalance;
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
//			If vPSBalancesRow.SumBalance > 0 Тогда
//				vPSRow = PaymentSections.Add();
//				vPSRow.PaymentSection = vPSBalancesRow.PaymentSection;
//				vPSRow.СтавкаНДС = ?(ЗначениеЗаполнено(vPSBalancesRow.PaymentSection), ?(ЗначениеЗаполнено(vPSBalancesRow.PaymentSection.СтавкаНДС), vPSBalancesRow.PaymentSection.СтавкаНДС, VATRate), VATRate);
//				vPSRow.SumInFolioCurrency = vPSBalancesRow.SumBalance;
//				vPSRow.VATSumInFolioCurrency = cmCalculateVATSum(vPSRow.СтавкаНДС, vPSRow.SumInFolioCurrency);
//				vPSRow.Сумма = Round(cmConvertCurrencies(vPSRow.SumInFolioCurrency, FolioCurrency, FolioCurrencyExchangeRate, PaymentCurrency, PaymentCurrencyExchangeRate, ExchangeRateDate, Гостиница), 2);
//				vPSRow.СуммаНДС = cmCalculateVATSum(vPSRow.СтавкаНДС, vPSRow.Сумма);
//			EndIf;
//		EndDo;
//	EndIf;
//	
//	// Try to get forecast balance if this is payment by reservation
//	If Sum = 0 And ЗначениеЗаполнено(ParentDoc) And TypeOf(ParentDoc) = Type("DocumentRef.Reservation") Тогда
//		vQry = New Query();
//		vQry.Text = 
//		"SELECT
//		|	SalesForecastTurnovers.Валюта,
//		|	SalesForecastTurnovers.Услуга.PaymentSection AS PaymentSection,
//		|	SalesForecastTurnovers.СтавкаНДС,
//		|	SalesForecastTurnovers.Агент,
//		|	CASE
//		|		WHEN NOT ISNULL(SalesForecastTurnovers.Агент.DoNotPostCommission, TRUE)
//		|			THEN SUM(SalesForecastTurnovers.SalesTurnover - SalesForecastTurnovers.CommissionSumTurnover)
//		|		ELSE SUM(SalesForecastTurnovers.SalesTurnover)
//		|	END AS SalesTurnover
//		|FROM
//		|	AccumulationRegister.ПрогнозПродаж.Turnovers(, , Period, СчетПроживания = &qFolio) AS SalesForecastTurnovers
//		|
//		|GROUP BY
//		|	SalesForecastTurnovers.Валюта,
//		|	SalesForecastTurnovers.Услуга.PaymentSection,
//		|	SalesForecastTurnovers.СтавкаНДС,
//		|	SalesForecastTurnovers.Агент,
//		|	SalesForecastTurnovers.Агент.DoNotPostCommission
//		|
//		|ORDER BY
//		|	SalesForecastTurnovers.Услуга.PaymentSection.Code";
//		vQry.SetParameter("qFolio", ЛицевойСчет);
//		vForecast = vQry.Execute().Unload();
//		
//		SumInFolioCurrency = 0;
//		If vForecast.Count() > 0 Тогда
//			vForecastSalesTurnover = vForecast.Total("SalesTurnover");
//			If vForecastSalesTurnover > 0 Тогда
//				vFolioBalance = vForecastSalesTurnover + vFolioBalance;
//				If vFolioBalance > 0 Тогда
//					vReportingCurrency = vForecast.Get(0).Валюта;
//					SumInFolioCurrency = Round(cmConvertCurrencies(vFolioBalance, vReportingCurrency, , FolioCurrency, , ExchangeRateDate, Гостиница), 2);
//				EndIf;
//			EndIf;
//		EndIf;
//		VATSumInFolioCurrency = cmCalculateVATSum(VATRate, SumInFolioCurrency);
//		
//		Sum = Round(cmConvertCurrencies(SumInFolioCurrency, FolioCurrency, FolioCurrencyExchangeRate, PaymentCurrency, PaymentCurrencyExchangeRate, ExchangeRateDate, Гостиница), 2);
//		VATSum = cmCalculateVATSum(VATRate, Sum);
//		
//		If ЗначениеЗаполнено(Гостиница) And Гостиница.SplitFolioBalanceByPaymentSections Тогда
//			For Each vForecastRow In vForecast Do
//				If vForecastRow.SalesTurnover > 0 Тогда
//					vPSRow = PaymentSections.Add();
//					vPSRow.PaymentSection = vForecastRow.PaymentSection;
//					vPSRow.СтавкаНДС = ?(ЗначениеЗаполнено(vForecastRow.PaymentSection), ?(ЗначениеЗаполнено(vForecastRow.PaymentSection.СтавкаНДС), vForecastRow.PaymentSection.СтавкаНДС, vForecastRow.VATRate), vForecastRow.VATRate);
//					
//					vSectionBalance = 0;
//					vPSBalancesRow = vPaymentSectionBalances.Find(vPSRow.PaymentSection, "PaymentSection");
//					If vPSBalancesRow <> Неопределено Тогда
//						vSectionBalance = vPSBalancesRow.SumBalance;
//					EndIf;
//					
//					vPSRow.SumInFolioCurrency = Round(cmConvertCurrencies(vForecastRow.SalesTurnover, vForecastRow.ReportingCurrency, , FolioCurrency, , ExchangeRateDate, Гостиница), 2) + vSectionBalance;
//					vPSRow.VATSumInFolioCurrency = cmCalculateVATSum(vPSRow.СтавкаНДС, vPSRow.SumInFolioCurrency);
//					vPSRow.Сумма = Round(cmConvertCurrencies(vPSRow.SumInFolioCurrency, FolioCurrency, FolioCurrencyExchangeRate, PaymentCurrency, PaymentCurrencyExchangeRate, ExchangeRateDate, Гостиница), 2);
//					vPSRow.СуммаНДС = cmCalculateVATSum(vPSRow.СтавкаНДС, vPSRow.Сумма);
//				EndIf;
//			EndDo;
//		EndIf;
//	EndIf;
//	
//	// Totals and defaults
//	If ЗначениеЗаполнено(Гостиница) And Гостиница.SplitFolioBalanceByPaymentSections Тогда
//		If PaymentSections.Count() = 0 Тогда
//			vPSRow = PaymentSections.Add();
//		EndIf;
//		pmCalculateTotalsByPaymentSections();
//	EndIf;
//КонецПроцедуры //FillByFolio
//
////-----------------------------------------------------------------------------
//Процедура FillByPreauthorisation(pPreauth)
//	If НЕ ЗначениеЗаполнено(pPreauth) Тогда
//		Return;
//	EndIf;
//	
//	If ЗначениеЗаполнено(pPreauth.Гостиница) Тогда
//		If Гостиница <> pPreauth.Гостиница Тогда
//			Гостиница = pPreauth.Гостиница;
//		EndIf;
//	EndIf;
//	
//	FillPropertyValues(ThisObject, pPreauth, , "Number, Date, Автор, DeletionMark, Posted, Гостиница, ReferenceNumber, AuthorizationCode, Примечания, SlipText");
//	Preauthorisation = pPreauth;
//	
//	FolioCurrency = ЛицевойСчет.FolioCurrency;
//	FolioCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, FolioCurrency, ExchangeRateDate);
//	
//	// Fill Фирма
//	If ЗначениеЗаполнено(ЛицевойСчет.Фирма) Тогда
//		Фирма = ЛицевойСчет.Фирма;
//		If ЗначениеЗаполнено(Фирма.VATRate) Тогда
//			VATRate = Фирма.VATRate;
//		EndIf;
//	EndIf;
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
//	// The payment could be done only if the folio balance is positive
//	// otherwise use document Return
//	vFolioObj = ЛицевойСчет.GetObject();
//	vFolioBalance = vFolioObj.pmGetBalance('39991231235959');
//	If ЗначениеЗаполнено(ЛицевойСчет.DateTimeTo) And BegOfDay(CurrentDate()) < BegOfDay(ЛицевойСчет.DateTimeTo) Тогда
//		vFolioBalance = vFolioBalance - vFolioObj.pmGetRoomRateServicesTurnover(BegOfDay(CurrentDate()));
//	EndIf;
//	SumInFolioCurrency = 0;
//	If vFolioBalance > 0 Тогда
//		SumInFolioCurrency = vFolioBalance;
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
//			If vPSBalancesRow.SumBalance > 0 Тогда
//				If ЗначениеЗаполнено(ЛицевойСчет.DateTimeTo) And BegOfDay(CurrentDate()) < BegOfDay(ЛицевойСчет.DateTimeTo) Тогда
//					vPSBalancesRow.SumBalance = vPSBalancesRow.SumBalance - vFolioObj.pmGetRoomRateServicesTurnover(BegOfDay(CurrentDate()), , vPSBalancesRow.PaymentSection);
//				EndIf;
//				vPSRow = PaymentSections.Add();
//				vPSRow.PaymentSection = vPSBalancesRow.PaymentSection;
//				vPSRow.СтавкаНДС = ?(ЗначениеЗаполнено(vPSBalancesRow.PaymentSection), ?(ЗначениеЗаполнено(vPSBalancesRow.PaymentSection.СтавкаНДС), vPSBalancesRow.PaymentSection.СтавкаНДС, VATRate), VATRate);
//				vPSRow.SumInFolioCurrency = vPSBalancesRow.SumBalance;
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
//КонецПроцедуры //FillByPreauthorisation
//
////-----------------------------------------------------------------------------
//Процедура Filling(pBase)
//	// Fill attributes with default values
//	pmFillAttributesWithDefaultValues();
//	// Fill from the base
//	If ЗначениеЗаполнено(pBase) Тогда
//		If TypeOf(pBase) = Type("DocumentRef.СчетПроживания") Тогда
//			FillByFolio(pBase);
//		ElsIf TypeOf(pBase) = Type("DocumentRef.ПреАвторизация") Тогда
//			FillByPreauthorisation(pBase);
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
//		If ЗначениеЗаполнено(ЛицевойСчет) And (ЗначениеЗаполнено(ЛицевойСчет.Контрагент) And
//		   ЛицевойСчет.Контрагент <> AccountingCustomer Or НЕ ЗначениеЗаполнено(ЛицевойСчет.Контрагент) And ЗначениеЗаполнено(AccountingCustomer) And ЗначениеЗаполнено(Гостиница) And Гостиница.IndividualsCustomer <> AccountingCustomer) Тогда
//			WriteLogEvent(NStr("en='AccountingAttentionEvents.PaymentAndFolioCustomersAreDifferent';ru='СигналыДляБухгалтерии.КонтрагентПлатежаИФолиоОтличаются';de='AccountingAttentionEvents.PaymentAndFolioCustomersAreDifferent'"), EventLogLevel.Warning, Metadata(), Ref, TrimAll(AccountingCustomer) + " <> " + TrimAll(ЛицевойСчет.Контрагент) + ", " + cmFormatSum(Sum, PaymentCurrency));
//		EndIf;
//		If ЗначениеЗаполнено(ЛицевойСчет) And ЗначениеЗаполнено(ЛицевойСчет.Contract) And
//		   ЛицевойСчет.Contract <> AccountingContract Тогда
//			WriteLogEvent(NStr("en='AccountingAttentionEvents.PaymentAndFolioContractsAreDifferent';ru='СигналыДляБухгалтерии.ДоговорПлатежаИФолиоОтличаются';de='AccountingAttentionEvents.PaymentAndFolioContractsAreDifferent'"), EventLogLevel.Warning, Metadata(), Ref, TrimAll(AccountingContract) + " <> " + TrimAll(ЛицевойСчет.Contract) + ", " + cmFormatSum(Sum, PaymentCurrency));
//		EndIf;
//		If ЗначениеЗаполнено(ЛицевойСчет) And ЗначениеЗаполнено(ЛицевойСчет.GuestGroup) And
//		   ЛицевойСчет.GuestGroup <> GuestGroup Тогда
//			WriteLogEvent(NStr("en='AccountingAttentionEvents.PaymentAndFolioGuestGroupsAreDifferent';ru='СигналыДляБухгалтерии.ГруппаПлатежаИФолиоОтличаются';de='AccountingAttentionEvents.PaymentAndFolioGuestGroupsAreDifferent'"), EventLogLevel.Warning, Metadata(), Ref, TrimAll(GuestGroup) + " <> " + TrimAll(ЛицевойСчет.GuestGroup) + ", " + cmFormatSum(Sum, PaymentCurrency));
//		EndIf;
//	Else
//		If DeletionMark Тогда
//			WriteLogEvent(NStr("en='SuspiciousEvents.PaymentSetDeletionMark';ru='СигналыОПодозрительныхДействиях.УстановкаПометкиНаУдалениеВПлатеже';de='SuspiciousEvents.PaymentSetDeletionMark'"), EventLogLevel.Warning, Metadata(), Ref, NStr("en='Set document deletion mark';ru='Установка отметки удаления';de='Erstellung der Löschmarkierung'") + Chars.LF + TrimAll(Payer) + ", " + TrimAll(ЛицевойСчет) + Chars.LF + cmFormatSum(Sum, PaymentCurrency));
//			AuthorOfAnnulation = ПараметрыСеанса.ТекПользователь;
//			DateOfAnnulation = CurrentDate();
//		EndIf;
//	EndIf;
//	WasPosted = Posted;
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
//	ExternalCode = "";
//	GiftCertificate = "";
//КонецПроцедуры //OnCopy
//
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
//
////-----------------------------------------------------------------------------
//WasPosted = True;
