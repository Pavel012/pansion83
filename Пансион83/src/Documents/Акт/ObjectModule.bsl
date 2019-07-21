////-----------------------------------------------------------------------------
//Процедура pmPostToAccountsAndPayments(pFolioList = Неопределено) Экспорт
//	If pFolioList = Неопределено Тогда
//		pFolioList = New СписокЗначений();
//	EndIf;
//	
//	// Clear movements
//	RegisterRecords.Взаиморасчеты.Clear();
//	RegisterRecords.Взаиморасчеты.Write();
//	RegisterRecords.Платежи.Clear();
//	RegisterRecords.Платежи.Write();
//	RegisterRecords.ПлатежиУслуги.Clear();
//	RegisterRecords.ПлатежиУслуги.Write();
//	
//	// Check should we group services by payment sections
//	vUsePaymentSections = False;
//	If ЗначениеЗаполнено(Гостиница) And Гостиница.SplitFolioBalanceByPaymentSections Тогда
//		vUsePaymentSections = True;
//	EndIf;	
//	
//	// Check should we write to payment services
//	vUsePaymentServices = Гостиница.DoPaymentsDistributionToServices;
//	
//	// Group services by folio
//	vServices = New ValueTable();
//	If НЕ vUsePaymentSections Тогда
//		vQry = New Query();
//		vQry.Text = 
//		"SELECT
//		|	SettlementServices.СчетПроживания,
//		|	SettlementServices.СтавкаНДС,
//		|	&qEmptyPaymentSection AS PaymentSection,
//		|	SUM(SettlementServices.СуммаНДС) AS СуммаНДС,
//		|	SUM(SettlementServices.Сумма) AS Сумма
//		|FROM
//		|	Document.Акт.Услуги AS SettlementServices
//		|WHERE
//		|	SettlementServices.Ref = &qRef
//		|
//		|GROUP BY
//		|	SettlementServices.СчетПроживания,
//		|	SettlementServices.СтавкаНДС";
//		vQry.SetParameter("qRef", Ref);
//		vQry.SetParameter("qEmptyPaymentSection", Справочники.ОтделОплаты.EmptyRef());
//		vServices = vQry.Execute().Unload();
//	Else
//		vQry = New Query();
//		vQry.Text = 
//		"SELECT
//		|	SettlementServices.СчетПроживания,
//		|	SettlementServices.Начисление.PaymentSection AS PaymentSection,
//		|	SettlementServices.СтавкаНДС,
//		|	SUM(SettlementServices.СуммаНДС) AS СуммаНДС,
//		|	SUM(SettlementServices.Сумма) AS Сумма
//		|FROM
//		|	Document.Акт.Услуги AS SettlementServices
//		|WHERE
//		|	SettlementServices.Ref = &qRef
//		|
//		|GROUP BY
//		|	SettlementServices.СчетПроживания,
//		|	SettlementServices.Начисление.PaymentSection,
//		|	SettlementServices.СтавкаНДС";
//		vQry.SetParameter("qRef", Ref);
//		vServices = vQry.Execute().Unload();
//	EndIf;
//	
//	// Build value table with folio balances
//	vFolios = vServices.Copy();
//	vFolios.GroupBy("СчетПроживания", );
//	vFoliosArray = vFolios.UnloadColumn("СчетПроживания");
//	vFoliosList = New СписокЗначений();
//	vFoliosList.LoadValues(vFoliosArray);
//	If НЕ vUsePaymentSections Тогда
//		vBalances = cmGetFoliosBalance('39991231235959', Гостиница, Неопределено, vFoliosList);
//	Else
//		vBalances = cmGetFoliosBalanceByPaymentSections('39991231235959', Гостиница, Неопределено, vFoliosList);
//	EndIf;
//	
//	// Do expense movement for each folio
//	vDoWrite2Accounts = False;
//	For Each vServicesRow In vServices Do
//		// Check folio payment method 
//		If ЗначениеЗаполнено(vServicesRow.ЛицевойСчет.СпособОплаты) And vServicesRow.ЛицевойСчет.СпособОплаты.IsByBankTransfer And 
//		   ЗначениеЗаполнено(vServicesRow.ЛицевойСчет.Контрагент) And ЗначениеЗаполнено(vServicesRow.ЛицевойСчет.Гостиница) And 
//		   vServicesRow.ЛицевойСчет.Контрагент <> vServicesRow.ЛицевойСчет.Гостиница.IndividualsCustomer And 
//		   НЕ vServicesRow.ЛицевойСчет.Контрагент.BelongsToItem(Справочники.Контрагенты.КонтрагентПоУмолчанию) Тогда
//			// Find folio balances row
//			vBalancesRow = Неопределено;
//			If НЕ vUsePaymentSections Тогда
//				vBalancesRows = vBalances.FindRows(New Structure("СчетПроживания", vServicesRow.ЛицевойСчет));
//				If vBalancesRows.Count() > 0 Тогда
//					vBalancesRow = vBalancesRows.Get(0);
//				EndIf;
//			Else
//				vBalancesRows = vBalances.FindRows(New Structure("СчетПроживания, СтавкаНДС, PaymentSection", vServicesRow.ЛицевойСчет, vServicesRow.VATRate, vServicesRow.PaymentSection));
//				If vBalancesRows.Count() > 0 Тогда
//					vBalancesRow = vBalancesRows.Get(0);
//				EndIf;
//			EndIf;
//			
//			// Stop processing if folio balance is zero
//			If vBalancesRow <> Неопределено And vBalancesRow.SumBalance <> 0 Тогда
//				If vBalancesRow.SumBalance > 0 Тогда
//					If Сумма > 0 Тогда
//						If vServicesRow.Sum > vBalancesRow.SumBalance  Тогда
//							vServicesRow.Sum = vBalancesRow.SumBalance;
//							vServicesRow.VATSum = cmCalculateVATSum(vServicesRow.VATRate, vServicesRow.Sum);
//						EndIf;
//					Else
//						Continue;
//					EndIf;
//				Else
//					If Сумма < 0 Тогда
//						If vServicesRow.Sum < vBalancesRow.SumBalance Тогда
//							vServicesRow.Sum = vBalancesRow.SumBalance;
//							vServicesRow.VATSum = cmCalculateVATSum(vServicesRow.VATRate, vServicesRow.Sum);
//						EndIf;
//					Else
//						Continue;
//					EndIf;
//				EndIf;
//				vBalancesRow.SumBalance = vBalancesRow.SumBalance - vServicesRow.Sum;
//			Else
//				Continue;
//			EndIf;			
//
//			// Do movement
//			Movement = RegisterRecords.Взаиморасчеты.Add();
//			
//			Movement.RecordType = AccumulationRecordType.Expense;
//			Movement.Period = Date;
//			
//			FillPropertyValues(Movement, ThisObject);
//			FillPropertyValues(Movement, vServicesRow.ЛицевойСчет);
//			FillPropertyValues(Movement, vServicesRow);
//			
//			// Attributes
//			Movement.СпособОплаты = PaymentMethod;
//			Movement.ДокОснование = ParentDoc;
//			
//			// Save list of folios closed with settlement
//			If pFolioList.FindByValue(Movement.СчетПроживания) = Неопределено Тогда
//				pFolioList.Add(Movement.СчетПроживания);
//			EndIf;
//			
//			// Payment section
//			If НЕ vUsePaymentSections Тогда
//				Movement.PaymentSection = Справочники.ОтделОплаты.EmptyRef();
//			Else
//				Movement.PaymentSection = vServicesRow.PaymentSection;
//			EndIf;
//			
//			vDoWrite2Accounts = True;
//			
//			// Write to payments
//			Movement = RegisterRecords.Платежи.Add();
//			
//			Movement.Period = Date;
//			
//			FillPropertyValues(Movement, ThisObject);
//			FillPropertyValues(Movement, vServicesRow);
//			
//			// Dimensions
//			Movement.PaymentCurrency = AccountingCurrency;
//			Movement.Payer = AccountingCustomer;
//			Movement.УчетнаяДата = BegOfDay(Date);
//			
//			// Resources
//			If vServicesRow.Sum >= 0 Тогда
//				Movement.SumReceipt = vServicesRow.Sum;
//				Movement.VATSumReceipt = vServicesRow.VATSum;
//				Movement.SumExpense = 0;
//				Movement.VATSumExpense = 0;
//			Else
//				Movement.SumReceipt = 0;
//				Movement.VATSumReceipt = 0;
//				Movement.SumExpense = -vServicesRow.Sum;
//				Movement.VATSumExpense = -vServicesRow.VATSum;
//			EndIf;
//			
//			// Write to payment services
//			If vUsePaymentServices Тогда
//				Movement = RegisterRecords.ПлатежиУслуги.Add();
//				
//				Movement.RecordType = AccumulationRecordType.Expense;
//				Movement.Period = Date;
//				
//				Movement.СчетПроживания = vServicesRow.ЛицевойСчет;
//				Movement.Услуга = Справочники.Услуги.EmptyRef();
//				Movement.Платеж = Ref;
//				
//				// Fill resources
//				Movement.Сумма = vServicesRow.Sum;
//			EndIf;
//		EndIf;
//	EndDo;
//		
//	// Write records
//	If vDoWrite2Accounts Тогда
//		RegisterRecords.Взаиморасчеты.Write();
//		RegisterRecords.Платежи.Write();
//		If vUsePaymentServices Тогда
//			RegisterRecords.ПлатежиУслуги.Write();
//		EndIf;
//	EndIf;
//	RegisterRecords.Взаиморасчеты.Write = False;
//	RegisterRecords.Платежи.Write = False;
//	RegisterRecords.ПлатежиУслуги.Write = False;
//КонецПроцедуры //pmPostToAccountsAndPayments
//
////-----------------------------------------------------------------------------
//Процедура PostToCurrentAccountsReceivable()
//	RegisterRecords.РелизацияТекОтчетПериод.Clear();
//	RegisterRecords.РелизацияТекОтчетПериод.Write();
//	
//	// Write movement for each charge in the services tabular part
//	For Each vServicesRow In Services Do
//		Movement = RegisterRecords.РелизацияТекОтчетПериод.Add();
//		
//		Movement.RecordType = AccumulationRecordType.Expense;
//		Movement.Period = Date;
//		
//		If ЗначениеЗаполнено(vServicesRow.ЛицевойСчет) Тогда
//			FillPropertyValues(Movement, vServicesRow.ЛицевойСчет);
//		EndIf;
//		If ЗначениеЗаполнено(vServicesRow.Charge) Тогда
//			FillPropertyValues(Movement, vServicesRow.Charge);
//		EndIf;
//		FillPropertyValues(Movement, vServicesRow);
//		
//		Movement.Гостиница = Гостиница;
//		Movement.Фирма = Фирма;
//	EndDo;
//
//	RegisterRecords.РелизацияТекОтчетПериод.Write();
//	RegisterRecords.РелизацияТекОтчетПериод.Write = False;
//КонецПроцедуры //PostToCurrentAccountsReceivable
//
////-----------------------------------------------------------------------------
//Процедура PostToAccountsReceivable()
//	RegisterRecords.БухРеализацияУслуг.Clear();
//	RegisterRecords.БухРеализацияУслуг.Write();
//	
//	// Write movement for each charge in the services tabular part
//	For Each vServicesRow In Services Do
//		Movement = RegisterRecords.БухРеализацияУслуг.Add();
//		
//		Movement.Period = Date;
//		
//		FillPropertyValues(Movement, ThisObject);
//		FillPropertyValues(Movement, vServicesRow);
//		
//		Movement.Акт = Ref;
//	EndDo;
//
//	RegisterRecords.БухРеализацияУслуг.Write();
//	RegisterRecords.БухРеализацияУслуг.Write = False;
//КонецПроцедуры //PostToAccountsReceivable
//
////-----------------------------------------------------------------------------
//Процедура PostToCustomerAccounts()
//	RegisterRecords.ВзаиморасчетыКонтрагенты.Clear();
//	RegisterRecords.ВзаиморасчетыКонтрагенты.Write();
//	
//	For Each vServicesRow In Services Do
//		Movement = RegisterRecords.ВзаиморасчетыКонтрагенты.Add();
//		
//		Movement.RecordType = AccumulationRecordType.Receipt;
//		Movement.Period = Date;
//		
//		FillPropertyValues(Movement, ThisObject);
//		FillPropertyValues(Movement, vServicesRow);
//		
//		// Attributes
//		Movement.PaymentSection = vServicesRow.Service.PaymentSection; 
//		
//		// Take agent commission into account
//		If ЗначениеЗаполнено(vServicesRow.Agent) And vServicesRow.Agent = AccountingCustomer And НЕ vServicesRow.Agent.DoNotPostCommission Тогда
//			Movement.Сумма = Movement.Сумма - vServicesRow.CommissionSum;
//			Movement.СуммаНДС = Movement.СуммаНДС - vServicesRow.VATCommissionSum;
//		EndIf;
//		
//		// Add movement for agent that differs from the settlement Контрагент
//		If ЗначениеЗаполнено(vServicesRow.Agent) And vServicesRow.Agent <> AccountingCustomer And НЕ vServicesRow.Agent.DoNotPostCommission Тогда 
//			Movement = RegisterRecords.ВзаиморасчетыКонтрагенты.Add();
//			
//			Movement.RecordType = AccumulationRecordType.Receipt;
//			Movement.Period = Date;
//			
//			FillPropertyValues(Movement, ThisObject);
//			FillPropertyValues(Movement, vServicesRow);
//			
//			// Dimensions
//			Movement.Контрагент = vServicesRow.Agent;
//			Movement.Договор = vServicesRow.Agent.AgentCommissionContract;
//			Movement.ГруппаГостей = Справочники.ГруппыГостей.EmptyRef();
//			
//			// Resources
//			Movement.Сумма = -vServicesRow.CommissionSum;
//			Movement.СуммаНДС = -vServicesRow.VATCommissionSum;
//			
//			// Attributes
//			Movement.PaymentSection = vServicesRow.Service.PaymentSection; 
//		EndIf;		
//	EndDo;
//
//	RegisterRecords.ВзаиморасчетыКонтрагенты.Write();
//	RegisterRecords.ВзаиморасчетыКонтрагенты.Write = False;
//КонецПроцедуры //PostToCustomerAccounts
//
////-----------------------------------------------------------------------------
//Процедура Posting(pCancel, pMode)
//	If ThisObject.DataExchange.Load Тогда
//		Return;
//	EndIf;
//	// Recalculate settlement totals
//	vSum = Services.Total("Сумма");
//	If vSum <> Сумма Тогда
//		Сумма = vSum;
//	EndIf;
//	vVATSum = Services.Total("СуммаНДС");
//	If vVATSum <> VATSum Тогда
//		VATSum = vVATSum;
//	EndIf;
//	vCommissionSum = Services.Total("СуммаКомиссии");
//	If vCommissionSum <> CommissionSum Тогда
//		CommissionSum = vCommissionSum;
//	EndIf;
//	If Modified() Тогда
//		Write(DocumentWriteMode.Write);
//	EndIf;
//	
//	// 1. Post to Accounts and Payments
//	vFoliosList = New СписокЗначений();
//	pmPostToAccountsAndPayments(vFoliosList);
//	
//	// 2. Post to CurrentAccountsReceivable
//	PostToCurrentAccountsReceivable();
//	
//	// 3. Post to AccountsReceivable
//	PostToAccountsReceivable();
//	
//	// 4. Post to Контрагент accounts
//	PostToCustomerAccounts();
//	
//	// 5. Set wait for payment till date to guest group
//	If ЗначениеЗаполнено(GuestGroup) And НЕ ЗначениеЗаполнено(GuestGroup.CheckDate) Тогда
//		vCheckDate = Неопределено;
//		If ЗначениеЗаполнено(AccountingContract) And AccountingContract.DaysAfterSettlement <> 0 And ЗначениеЗаполнено(Date) Тогда
//			vCheckDate = cmAddWorkingDays(BegOfDay(Date), (AccountingContract.DaysAfterSettlement + 1));
//		ElsIf ЗначениеЗаполнено(AccountingCustomer) And AccountingCustomer.DaysAfterSettlement <> 0 And ЗначениеЗаполнено(Date) Тогда
//			vCheckDate = cmAddWorkingDays(BegOfDay(Date), (AccountingCustomer.DaysAfterSettlement + 1));
//		EndIf;
//		If ЗначениеЗаполнено(vCheckDate) Тогда
//			vGroupObj = GuestGroup.GetObject();
//			vGroupObj.CheckDate = vCheckDate;
//			vGroupObj.Write();
//		EndIf;
//	EndIf;
//	
//	// 6. Update folio accounting number
//	For Each vFolioItem In vFoliosList Do
//		vFolio = vFolioItem.Value;
//		If ЗначениеЗаполнено(vFolio) And ЗначениеЗаполнено(Гостиница) And Гостиница.UseFolioAccountingNumberPrefix And НЕ ЗначениеЗаполнено(CloseOfPeriod) Тогда
//			vHotelObj = Гостиница.GetObject();
//			vFolioAccountingNumberPrefix = vHotelObj.pmGetFolioAccountingNumberPrefix();
//			If НЕ IsBlankString(vFolioAccountingNumberPrefix) And Upper(Left(TrimR(vFolio.НомерДока), StrLen(vFolioAccountingNumberPrefix))) <> Upper(vFolioAccountingNumberPrefix) Or
//			   IsBlankString(vFolioAccountingNumberPrefix) And НЕ cmIsNumber(TrimAll(vFolio.НомерДока)) Тогда
//				vFolioObj = vFolio.GetObject();
//				vFolioObj.SetNewNumber(vFolioAccountingNumberPrefix);
//				vFolioObj.Write(DocumentWriteMode.Write);
//			EndIf;
//		EndIf;
//	EndDo;
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
//	If НЕ ЗначениеЗаполнено(AccountingCustomer) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Контрагент> должен быть заполнен!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "<Контрагент> attribute should be filled!" + Chars.LF;
//		vMsgTextDe = vMsgTextDe + "<Контрагент> attribute should be filled!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "Контрагент", pAttributeInErr);
//	EndIf;
//	If НЕ ЗначениеЗаполнено(AccountingCurrency) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Валюта акта> должен быть заполнен!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "<Accounting Валюта> attribute should be filled!" + Chars.LF;
//		vMsgTextDe = vMsgTextDe + "<Accounting Валюта> attribute should be filled!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "ВалютаРасчетов", pAttributeInErr);
//	EndIf;
//	If vHasErrors Тогда
//		pMessage = "ru='" + TrimAll(vMsgTextRu) + "';" + "en='" + TrimAll(vMsgTextEn) + "';" + "de='" + TrimAll(vMsgTextDe) + "';";
//	EndIf;
//	Return vHasErrors;
//EndFunction //pmCheckDocumentAttributes
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
//	PaymentMethod = Справочники.СпособОплаты.Акт;
//	If НЕ ЗначениеЗаполнено(Гостиница) Тогда
//		Гостиница = ПараметрыСеанса.ТекущаяГостиница;
//	EndIf;
//	If ЗначениеЗаполнено(Гостиница) Тогда
//		If НЕ ЗначениеЗаполнено(AccountingCurrency) Тогда
//			AccountingCurrency = Гостиница.FolioCurrency;
//		EndIf;
//		If НЕ ЗначениеЗаполнено(Фирма) Тогда
//			Фирма = Гостиница.Фирма;
//		EndIf;
//		If ЗначениеЗаполнено(Фирма) Тогда
//			If НЕ IsBlankString(Фирма.Consignor) Тогда
//				Consignor = TrimR(Фирма.Consignor);
//			EndIf;
//		EndIf;
//	EndIf;
//КонецПроцедуры //pmFillAttributesWithDefaultValues
//
////-----------------------------------------------------------------------------
//Процедура pmFillServices(pCharges, pLanguage = Неопределено) Экспорт
//	For Each vFolioChargesRow In pCharges Do
//		If ЗначениеЗаполнено(vFolioChargesRow.Начисление) Тогда
//			// Add service
//			vServicesRow = Services.Add();
//			If ЗначениеЗаполнено(vFolioChargesRow.СчетПроживания) Тогда
//				vServicesRow.Клиент = vFolioChargesRow.СчетПроживания.Клиент;
//				vServicesRow.НомерРазмещения = vFolioChargesRow.СчетПроживания.НомерРазмещения;
//			EndIf;
//			vParentDoc = vFolioChargesRow.ДокОснование;
//			If ЗначениеЗаполнено(vParentDoc) Тогда
//				If TypeOf(vParentDoc) = Type("DocumentRef.Размещение") Or 
//				   TypeOf(vParentDoc) = Type("DocumentRef.Reservation") Тогда
//					vServicesRow.Клиент = vParentDoc.Клиент;
//					vServicesRow.НомерРазмещения = vParentDoc.НомерРазмещения;
//					vServicesRow.ВидРазмещения = vParentDoc.ВидРазмещения;
//					vServicesRow.КоличествоЧеловек = vParentDoc.КоличествоЧеловек;
//				ElsIf TypeOf(vParentDoc) = Type("DocumentRef.БроньУслуг") Тогда
//					vServicesRow.Клиент = vParentDoc.Клиент;
//					vServicesRow.Ресурс = vParentDoc.Ресурс;
//					vServicesRow.КоличествоЧеловек = vParentDoc.КоличествоЧеловек;
//				EndIf;
//			EndIf;
//			FillPropertyValues(vServicesRow, vFolioChargesRow.Начисление);
//			FillPropertyValues(vServicesRow, vFolioChargesRow);
//			vServicesRow.УчетнаяДата = BegOfDay(vFolioChargesRow.Начисление.ДатаДок);
//			vServicesRow.Сумма = vFolioChargesRow.SumBalance;
//			vServicesRow.СуммаНДС = vFolioChargesRow.VATSumBalance;
//			vServicesRow.Количество = vFolioChargesRow.QuantityBalance;
//			vServicesRow.Цена = cmRecalculatePrice(vServicesRow.Сумма, vServicesRow.Количество);
//			// Commission
//			If ЗначениеЗаполнено(vFolioChargesRow.СчетПроживания) Тогда
//				vServicesRow.Агент = vFolioChargesRow.СчетПроживания.Агент;
//			EndIf;
//			If ЗначениеЗаполнено(vFolioChargesRow.Начисление) Тогда
//				vServicesRow.ВидКомиссииАгента = vFolioChargesRow.Начисление.ВидКомиссииАгента;
//				vServicesRow.КомиссияАгента = vFolioChargesRow.Начисление.КомиссияАгента;
//			EndIf;
//			vServicesRow.СуммаКомиссии = vFolioChargesRow.CommissionSumBalance;
//			vServicesRow.СуммаКомиссииНДС = cmCalculateVATSum(vServicesRow.СтавкаНДС, vServicesRow.СуммаКомиссии);
//			If vServicesRow.СуммаКомиссии = 0 And vServicesRow.СуммаКомиссииНДС = 0 And 
//			   ЗначениеЗаполнено(vServicesRow.ВидКомиссииАгента) Тогда
//				vServicesRow.ВидКомиссииАгента = Неопределено;
//				vServicesRow.КомиссияАгента = 0;
//			EndIf;				
//			// Fill remarks by service description by default
//			vServiceDescription = TrimAll(vServicesRow.Услуга);
//			If ЗначениеЗаполнено(vServicesRow.Услуга) Тогда
//				vServiceObj = vServicesRow.Услуга.GetObject();
//				vServiceDescription = vServiceObj.pmGetServiceDescription(pLanguage);
//			EndIf;
//			vServicesRow.Примечания = vServiceDescription + 
//			                       ?(IsBlankString(vServicesRow.Примечания), "", " - " + vServicesRow.Примечания);
//		EndIf;
//	EndDo;
//КонецПроцедуры //pmFillServices	
//
////-----------------------------------------------------------------------------
//// Fill list of payments
////-----------------------------------------------------------------------------
//Процедура pmFillListOfPayments() Экспорт
//	PaymentDocuments.Clear();
//	// Fill from folio payments
//	vFolios = Services.Unload(, "СчетПроживания");
//	vFolios.GroupBy("СчетПроживания", );
//	For Each vFoliosRow In vFolios Do
//		vPayments = vFoliosRow.ЛицевойСчет.GetObject().pmGetAllFolioDeposits();
//		For Each vPaymentsRow In vPayments Do
//			If ЗначениеЗаполнено(vPaymentsRow.Document) And TypeOf(vPaymentsRow.Document) <> Type("DocumentRef.ПреАвторизация") Тогда
//				vRow = PaymentDocuments.Add();
//				vRow.PaymentDocNumber = cmGetDocumentNumberPresentation(vPaymentsRow.НомерДока);
//				vRow.PaymentDocDate = vPaymentsRow.Document.ДатаДок;
//			EndIf;
//		EndDo;
//	EndDo;
//	// Fill from Контрагент payments if this is guest group settlment
//	If ЗначениеЗаполнено(GuestGroup) And НЕ ЗначениеЗаполнено(ParentDoc) Тогда
//		vQry = New Query();
//		vQry.Text = 
//		"SELECT
//		|	CustomerPayments.Ref,
//		|	CustomerPayments.PaymentDocNumber AS PaymentDocNumber,
//		|	CustomerPayments.PaymentDocDate AS PaymentDocDate
//		|FROM
//		|	Document.ПлатежКонтрагента AS CustomerPayments
//		|WHERE
//		|	CustomerPayments.Posted
//		|	AND CustomerPayments.PaymentDocNumber > &qEmptyString
//		|	AND CustomerPayments.ГруппаГостей = &qGuestGroup
//		|	AND CustomerPayments.Контрагент = &qAccountingCustomer
//		|
//		|ORDER BY
//		|	PaymentDocDate,
//		|	PaymentDocNumber";
//		vQry.SetParameter("qGuestGroup", GuestGroup);
//		vQry.SetParameter("qAccountingCustomer", AccountingCustomer);
//		vQry.SetParameter("qEmptyString", "                              ");
//		vPaymentDocs = vQry.Execute().Unload();
//		For Each vPaymentDocsRow In vPaymentDocs Do
//			vRow = PaymentDocuments.Add();
//			vRow.PaymentDocNumber = TrimAll(vPaymentDocsRow.PaymentDocNumber);
//			vRow.PaymentDocDate = vPaymentDocsRow.PaymentDocDate;
//		EndDo;
//	EndIf;
//КонецПроцедуры //pmFillListOfPayments
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
//		If НЕ IsBlankString(Фирма.Consignor) Тогда
//			Consignor = TrimR(Фирма.Consignor);
//		EndIf;
//	EndIf;
//	
//	// Fill accounting Контрагент, contract and guest group
//	AccountingCustomer = pFolio.Контрагент;
//	AccountingContract = pFolio.Договор;
//	GuestGroup = pFolio.ГруппаГостей;
//	If НЕ ЗначениеЗаполнено(AccountingCustomer) Тогда
//		If ЗначениеЗаполнено(Гостиница) Тогда
//			AccountingCustomer = Гостиница.IndividualsCustomer;
//			AccountingContract = Гостиница.IndividualsContract;
//		EndIf;
//	EndIf;
//	If ЗначениеЗаполнено(AccountingCustomer) Тогда
//		If НЕ IsBlankString(AccountingCustomer.Consignee) Тогда
//			Consignee = TrimR(AccountingCustomer.Consignee);
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
//	CommissionSum = 0;
//	
//	// Clear tabular part Services
//	Services.Clear();
//	
//	// Get all folio current accounts receivable services with balances per end of time
//	vFolioCharges = pFolio.GetObject().pmGetCurrentAccountsReceivableChargesWithBalances('39991231235959');
//	
//	// Fill services tabular part
//	pmFillServices(vFolioCharges, vLanguage);
//	
//	// Fill totals
//	Сумма = Services.Total("Сумма");
//	VATSum = Services.Total("СуммаНДС");
//	CommissionSum = Services.Total("СуммаКомиссии");
//	
//	// Fill list of payments
//	PaymentDocuments.Clear();
//	vPayments = pFolio.GetObject().pmGetAllFolioDeposits();
//	For Each vPaymentsRow In vPayments Do
//		vRow = PaymentDocuments.Add();
//		vRow.PaymentDocNumber = cmGetDocumentNumberPresentation(vPaymentsRow.НомерДока);
//		vRow.PaymentDocDate = vPaymentsRow.Document.ДатаДок;
//	EndDo;
//КонецПроцедуры //pmFillByFolio
//
////-----------------------------------------------------------------------------
//Процедура pmFillByDocument(pDoc, pFillCustomer = True) Экспорт
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
//	ParentDoc = pDoc;
//	
//	// Fill accounting Контрагент, contract and guest group
//	If pFillCustomer Тогда
//		If НЕ ЗначениеЗаполнено(pDoc.Контрагент) Тогда
//			AccountingCustomer = Гостиница.IndividualsCustomer;
//			AccountingContract = Гостиница.IndividualsContract;
//		Else
//			vChargingRules = pDoc.ChargingRules.Unload();
//			cmAddGuestGroupChargingRules(vChargingRules, pDoc.ГруппаГостей);
//			If ЗначениеЗаполнено(pDoc.Договор) And vChargingRules.Find(pDoc.Договор, "Owner") <> Неопределено Тогда
//				AccountingCustomer = pDoc.Контрагент;
//				AccountingContract = pDoc.Договор;
//			ElsIf ЗначениеЗаполнено(pDoc.Контрагент) And vChargingRules.Find(pDoc.Контрагент, "Owner") <> Неопределено Тогда
//				AccountingCustomer = pDoc.Контрагент;
//				AccountingContract = pDoc.Договор;
//			Else
//				AccountingCustomer = Гостиница.IndividualsCustomer;
//				AccountingContract = Гостиница.IndividualsContract;
//			EndIf;
//		EndIf;
//		GuestGroup = pDoc.ГруппаГостей;
//		If НЕ ЗначениеЗаполнено(AccountingCustomer) Тогда
//			If ЗначениеЗаполнено(Гостиница) Тогда
//				AccountingCustomer = Гостиница.IndividualsCustomer;
//				AccountingContract = Гостиница.IndividualsContract;
//			EndIf;
//		EndIf;
//		If ЗначениеЗаполнено(AccountingCustomer) Тогда
//			If НЕ IsBlankString(AccountingCustomer.Consignee) Тогда
//				Consignee = TrimR(AccountingCustomer.Consignee);
//			EndIf;
//		EndIf;
//		
//		// Fill currency
//		If ЗначениеЗаполнено(AccountingContract) Тогда
//			AccountingCurrency = AccountingContract.AccountingCurrency;
//		Else
//			If ЗначениеЗаполнено(AccountingCustomer) Тогда
//				AccountingCurrency = AccountingCustomer.AccountingCurrency;
//			EndIf;
//		EndIf;
//		
//		// Fill Фирма
//		If ЗначениеЗаполнено(pDoc.Фирма) Тогда
//			Фирма = pDoc.Фирма;
//		Else
//			If ЗначениеЗаполнено(Гостиница) Тогда
//				If ЗначениеЗаполнено(Гостиница.Фирма) Тогда
//					Фирма = Гостиница.Фирма;
//				EndIf;
//			EndIf;
//		EndIf;
//		If ЗначениеЗаполнено(Фирма) Тогда
//			If НЕ IsBlankString(Фирма.Consignor) Тогда
//				Consignor = TrimR(Фирма.Consignor);
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
//	CommissionSum = 0;
//	
//	// Clear tabular part Services
//	Services.Clear();
//	
//	// Get all folio current accounts receivable services with balances per end of time
//	vCharges = cmGetCurrentAccountsReceivableChargesWithBalances(?(ЗначениеЗаполнено(CloseOfPeriod), New Boundary(CloseOfPeriod.Date + 1, BoundaryType.Excluding), '39991231235959'), AccountingCustomer, AccountingContract, ParentDoc, GuestGroup, AccountingCurrency, Гостиница);
//	
//	// Fill services tabular part
//	pmFillServices(vCharges, vLanguage);
//	
//	// Fill totals
//	Сумма = Services.Total("Сумма");
//	VATSum = Services.Total("СуммаНДС");
//	CommissionSum = Services.Total("СуммаКомиссии");
//	
//	// Fill list of payments
//	pmFillListOfPayments();
//КонецПроцедуры //pmFillByDocument
//
////-----------------------------------------------------------------------------
//Процедура pmFillByResourceReservation(pDoc, pFillCustomer = True) Экспорт
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
//	ParentDoc = pDoc;
//	
//	// Fill accounting Контрагент, contract and guest group
//	If pFillCustomer Тогда
//		If ЗначениеЗаполнено(pDoc.Owner) Тогда
//			If TypeOf(pDoc.Owner) = Type("CatalogRef.Договора") Тогда
//				AccountingCustomer = pDoc.Owner.Owner;
//				AccountingContract = pDoc.Owner;
//			Else
//				AccountingCustomer = pDoc.Owner;
//				AccountingContract = Справочники.Договора.EmptyRef();
//			EndIf;
//		Else
//			If НЕ ЗначениеЗаполнено(pDoc.Контрагент) Тогда
//				AccountingCustomer = Гостиница.IndividualsCustomer;
//				AccountingContract = Гостиница.IndividualsContract;
//			Else
//				AccountingCustomer = pDoc.Контрагент;
//				AccountingContract = pDoc.Договор;
//			EndIf;
//		EndIf;
//		GuestGroup = pDoc.ГруппаГостей;
//		If НЕ ЗначениеЗаполнено(AccountingCustomer) Тогда
//			If ЗначениеЗаполнено(Гостиница) Тогда
//				AccountingCustomer = Гостиница.IndividualsCustomer;
//				AccountingContract = Гостиница.IndividualsContract;
//			EndIf;
//		EndIf;
//		If ЗначениеЗаполнено(AccountingCustomer) Тогда
//			If НЕ IsBlankString(AccountingCustomer.Consignee) Тогда
//				Consignee = TrimR(AccountingCustomer.Consignee);
//			EndIf;
//		EndIf;
//		
//		// Fill currency
//		If ЗначениеЗаполнено(AccountingContract) Тогда
//			AccountingCurrency = AccountingContract.AccountingCurrency;
//		Else
//			If ЗначениеЗаполнено(AccountingCustomer) Тогда
//				AccountingCurrency = AccountingCustomer.AccountingCurrency;
//			EndIf;
//		EndIf;
//		
//		// Fill Фирма
//		If ЗначениеЗаполнено(pDoc.Фирма) Тогда
//			Фирма = pDoc.Фирма;
//		Else
//			If ЗначениеЗаполнено(Гостиница) Тогда
//				If ЗначениеЗаполнено(Гостиница.Фирма) Тогда
//					Фирма = Гостиница.Фирма;
//				EndIf;
//			EndIf;
//		EndIf;
//		If ЗначениеЗаполнено(Фирма) Тогда
//			If НЕ IsBlankString(Фирма.Consignor) Тогда
//				Consignor = TrimR(Фирма.Consignor);
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
//	CommissionSum = 0;
//	
//	// Clear tabular part Services
//	Services.Clear();
//	
//	// Get all folio current accounts receivable services with balances per end of time
//	vCharges = cmGetCurrentAccountsReceivableChargesWithBalances(?(ЗначениеЗаполнено(CloseOfPeriod), New Boundary(CloseOfPeriod.Date + 1, BoundaryType.Excluding), '39991231235959'), AccountingCustomer, AccountingContract, ParentDoc, GuestGroup, AccountingCurrency, Гостиница);
//	
//	// Fill services tabular part
//	pmFillServices(vCharges, vLanguage);
//	
//	// Fill totals
//	Сумма = Services.Total("Сумма");
//	VATSum = Services.Total("СуммаНДС");
//	CommissionSum = Services.Total("СуммаКомиссии");
//	
//	// Fill list of payments
//	pmFillListOfPayments();
//КонецПроцедуры //pmFillByResourceReservation
//
////-----------------------------------------------------------------------------
//Процедура pmFillByGuestGroup(pGuestGroup) Экспорт
//	If НЕ ЗначениеЗаполнено(pGuestGroup) Тогда
//		Return;
//	EndIf;
//	
//	// Accounting Контрагент, contract, hotel, Фирма, currency should be filled before calling Fill() method
//	ParentDoc = Неопределено;
//	GuestGroup = pGuestGroup;
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
//	CommissionSum = 0;
//	
//	// Clear tabular part Services
//	Services.Clear();
//	
//	// Get all folio current accounts receivable services with balances per end of time
//	vCharges = cmGetCurrentAccountsReceivableChargesWithBalances(?(ЗначениеЗаполнено(CloseOfPeriod), New Boundary(CloseOfPeriod.Date + 1, BoundaryType.Excluding), '39991231235959'), AccountingCustomer, AccountingContract, , GuestGroup, AccountingCurrency, Гостиница);
//	
//	// Fill services tabular part
//	pmFillServices(vCharges, vLanguage);
//	
//	// Fill totals
//	Сумма = Services.Total("Сумма");
//	VATSum = Services.Total("СуммаНДС");
//	CommissionSum = Services.Total("СуммаКомиссии");
//	
//	// Fill list of payments
//	pmFillListOfPayments();
//КонецПроцедуры //pmFillByGuestGroup
//
////-----------------------------------------------------------------------------
//Процедура pmFillByInvoice(pDoc) Экспорт
//	If НЕ ЗначениеЗаполнено(pDoc) Тогда
//		Return;
//	EndIf;
//	
//	If НЕ ЗначениеЗаполнено(pDoc.ДокОснование) Тогда
//		FillPropertyValues(ThisObject, pDoc, , "Number, Date, Автор, DeletionMark, Posted, ДокОснование");
//		If ЗначениеЗаполнено(pDoc.ГруппаГостей) Тогда
//			pmFillByGuestGroup(pDoc.ГруппаГостей);
//		ElsIf ЗначениеЗаполнено(pDoc.Договор) Тогда
//			pmFillByContract(pDoc.Договор);
//		ElsIf ЗначениеЗаполнено(pDoc.Контрагент) Тогда
//			pmFillByCustomer(pDoc.Контрагент);
//		EndIf;
//	Else
//		If TypeOf(pDoc.ДокОснование) = Type("DocumentRef.СчетПроживания") Тогда
//			pmFillByFolio(pDoc.ДокОснование);
//		ElsIf TypeOf(pDoc.ДокОснование) = Type("DocumentRef.Reservation") Тогда 
//			pmFillByDocument(pDoc.ДокОснование);
//		ElsIf TypeOf(pDoc.ДокОснование) = Type("DocumentRef.Размещение") Тогда 
//			pmFillByDocument(pDoc.ДокОснование);
//		ElsIf TypeOf(pDoc.ДокОснование) = Type("DocumentRef.БроньУслуг") Тогда 
//			pmFillByResourceReservation(pDoc.ДокОснование);
//		EndIf;
//	EndIf;
//	ParentDoc = pDoc;
//КонецПроцедуры //pmFillByInvoice
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
//	If ЗначениеЗаполнено(AccountingCustomer) Тогда
//		If НЕ IsBlankString(AccountingCustomer.Consignee) Тогда
//			Consignee = TrimR(AccountingCustomer.Consignee);
//		EndIf;
//	EndIf;
//	
//	// Fill currency
//	If ЗначениеЗаполнено(AccountingContract) Тогда
//		AccountingCurrency = AccountingContract.AccountingCurrency;
//	Else
//		If ЗначениеЗаполнено(AccountingCustomer) Тогда
//			AccountingCurrency = AccountingCustomer.AccountingCurrency;
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
//	CommissionSum = 0;
//	
//	// Clear tabular part Services
//	Services.Clear();
//	
//	// Get all Контрагент current accounts receivable services with balances per end of time
//	vCharges = cmGetCurrentAccountsReceivableChargesWithBalances(?(ЗначениеЗаполнено(CloseOfPeriod), New Boundary(CloseOfPeriod.Date + 1, BoundaryType.Excluding), '39991231235959'), AccountingCustomer, , , GuestGroup, AccountingCurrency, Гостиница);
//	
//	// Fill services tabular part
//	pmFillServices(vCharges, vLanguage);
//	
//	// Fill totals
//	Сумма = Services.Total("Сумма");
//	VATSum = Services.Total("СуммаНДС");
//	CommissionSum = Services.Total("СуммаКомиссии");
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
//	If ЗначениеЗаполнено(AccountingCustomer) Тогда
//		If НЕ IsBlankString(AccountingCustomer.Consignee) Тогда
//			Consignee = TrimR(AccountingCustomer.Consignee);
//		EndIf;
//	EndIf;
//	
//	// Fill currency
//	If ЗначениеЗаполнено(AccountingContract) Тогда
//		AccountingCurrency = AccountingContract.AccountingCurrency;
//	Else
//		If ЗначениеЗаполнено(AccountingCustomer) Тогда
//			AccountingCurrency = AccountingCustomer.AccountingCurrency;
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
//	CommissionSum = 0;
//	
//	// Clear tabular part Services
//	Services.Clear();
//	
//	// Get all contract current accounts receivable services with balances per end of time
//	vCharges = cmGetCurrentAccountsReceivableChargesWithBalances(?(ЗначениеЗаполнено(CloseOfPeriod), New Boundary(CloseOfPeriod.Date + 1, BoundaryType.Excluding), '39991231235959'), AccountingCustomer, AccountingContract, , GuestGroup, AccountingCurrency, Гостиница);
//	
//	// Fill services tabular part
//	pmFillServices(vCharges, vLanguage);
//	
//	// Fill totals
//	Сумма = Services.Total("Сумма");
//	VATSum = Services.Total("СуммаНДС");
//	CommissionSum = Services.Total("СуммаКомиссии");
//КонецПроцедуры //pmFillByContract
//
////-----------------------------------------------------------------------------
//Процедура pmCalculateTotals() Экспорт
//	vSum = Services.Total("Сумма");
//	If vSum <> Сумма Тогда
//		Сумма = vSum;
//	EndIf;
//	vVATSum = Services.Total("СуммаНДС");
//	If vVATSum <> VATSum Тогда
//		VATSum = vVATSum;
//	EndIf;
//	vCommissionSum = Services.Total("СуммаКомиссии");
//	If vCommissionSum <> CommissionSum Тогда
//		CommissionSum = vCommissionSum;
//	EndIf;
//КонецПроцедуры //pmCalculateTotals
//
////-----------------------------------------------------------------------------
//Function pmGetServicesPostedToAccounts() Экспорт
//	vServices = New ValueTable();
//	If Posted Тогда
//		vQry = New Query();
//		vQry.Text = 
//		"SELECT
//		|	Взаиморасчеты.Клиент,
//		|	Взаиморасчеты.НомерРазмещения,
//		|	Взаиморасчеты.Начисление.ВидРазмещения AS ВидРазмещения,
//		|	ISNULL(Взаиморасчеты.ДокОснование.КоличествоЧеловек, 0) AS КоличествоЧеловек,
//		|	Взаиморасчеты.Ресурс,
//		|	BEGINOFPERIOD(Взаиморасчеты.Period, DAY) AS УчетнаяДата,
//		|	Взаиморасчеты.Услуга,
//		|	Взаиморасчеты.Цена,
//		|	Взаиморасчеты.Услуга.ЕдИзмерения AS ЕдИзмерения,
//		|	Взаиморасчеты.Количество,
//		|	Взаиморасчеты.Сумма,
//		|	Взаиморасчеты.СтавкаНДС,
//		|	Взаиморасчеты.Начисление.СуммаНДС AS СуммаНДС,
//		|	Взаиморасчеты.Примечания,
//		|	Взаиморасчеты.IsInPrice,
//		|	Взаиморасчеты.IsRoomRevenue,
//		|	Взаиморасчеты.IsResourceRevenue,
//		|	Взаиморасчеты.СчетПроживания.Контрагент AS Контрагент,
//		|	Взаиморасчеты.СчетПроживания.Договор AS Договор,
//		|	Взаиморасчеты.СчетПроживания.ГруппаГостей AS ГруппаГостей,
//		|	Взаиморасчеты.ВалютаЛицСчета,
//		|	Взаиморасчеты.СчетПроживания,
//		|	Взаиморасчеты.ДокОснование,
//		|	Взаиморасчеты.Начисление,
//		|	Взаиморасчеты.ТипДеньКалендарь,
//		|	Взаиморасчеты.СчетПроживания.Агент AS Агент,
//		|	Взаиморасчеты.Начисление.КомиссияАгента AS КомиссияАгента,
//		|	Взаиморасчеты.Начисление.ВидКомиссииАгента AS ВидКомиссииАгента,
//		|	Взаиморасчеты.Начисление.СуммаКомиссии AS СуммаКомиссии,
//		|	Взаиморасчеты.Начисление.VATCommissionSum AS VATCommissionSum,
//		|	Взаиморасчеты.Начисление.ПутевкаКурсовка AS ПутевкаКурсовка,
//		|	Взаиморасчеты.PaymentSection
//		|FROM
//		|	AccumulationRegister.Взаиморасчеты AS Взаиморасчеты
//		|WHERE
//		|	Взаиморасчеты.Recorder = &qRecorder
//		|
//		|ORDER BY
//		|	Взаиморасчеты.LineNumber,
//		|	Взаиморасчеты.PointInTime";
//		vQry.SetParameter("qRecorder", Ref);
//		vServices = vQry.Execute().Unload();
//		If vServices.Count() > 0 And Services.Count() > 0 And vServices.Total("Сумма") <> Services.Total("Сумма") Тогда
//			For Each vSrvRow In vServices Do
//				vDocRowToUse = Services.Get(0);
//				For Each vDocRow In Services Do
//					If ЗначениеЗаполнено(vSrvRow.PaymentSection) And ЗначениеЗаполнено(vDocRow.Service) And vSrvRow.PaymentSection = vDocRow.Service.PaymentSection Тогда
//						vDocRowToUse = vDocRow;
//						Break;
//					ElsIf vDocRow.IsRoomRevenue Or vDocRow.IsResourceRevenue Тогда
//						vDocRowToUse = vDocRow;
//						Break;
//					EndIf;
//				EndDo;
//				vSrvRow.VATSum = 0;
//				If vSrvRow.Quantity = 0 Тогда
//					vSrvRow.Quantity = 1;
//				EndIf;
//				If vSrvRow.Price = 0 Тогда
//					vSrvRow.Price = vSrvRow.Sum;
//				EndIf;
//				FillPropertyValues(vSrvRow, vDocRowToUse, , "Количество, Сумма, Цена, СуммаНДС, СуммаКомиссии, VATCommissionSum, Начисление");
//				cmPriceOnChange(vSrvRow.Price, vSrvRow.Quantity, vSrvRow.Sum, vSrvRow.VATRate, vSrvRow.VATSum);
//				If vSrvRow.AgentCommission <> 0 Тогда
//					vSrvRow.CommissionSum = Round(vSrvRow.Sum * vSrvRow.AgentCommission / 100, 2);
//					vSrvRow.VATCommissionSum = cmCalculateVATSum(vSrvRow.VATRate, vSrvRow.CommissionSum);
//				Else
//					vSrvRow.CommissionSum = 0;
//					vSrvRow.VATCommissionSum = 0;
//				EndIf;
//				If ЗначениеЗаполнено(GuestGroup) Тогда
//					If ЗначениеЗаполнено(GuestGroup.Client) Тогда
//						vSrvRow.Client = GuestGroup.Client;
//					EndIf;
//					If ЗначениеЗаполнено(GuestGroup.ClientDoc) Тогда
//						vClientDoc = GuestGroup.ClientDoc;
//						If TypeOf(vClientDoc) = Type("DocumentRef.Размещение") Or TypeOf(vClientDoc) = Type("DocumentRef.Reservation") Тогда
//							vSrvRow.ParentDoc = vClientDoc;
//							vSrvRow.ГруппаНомеров = vClientDoc.НомерРазмещения;
//							vSrvRow.AccommodationType = vClientDoc.ВидРазмещения;
//							vSrvRow.NumberOfPersons = vClientDoc.КоличествоЧеловек;
//						EndIf;
//					EndIf;
//					vSrvRow.Remarks = TrimAll(NStr("en='Payment for the group N '; ru='Оплата по группе № '; de='Die Zahlung für die Gruppe Nr. '") + Format(GuestGroup.Code, "ND=12; NFD=0; NZ=; NG=") + ?(IsBlankString(vSrvRow.Remarks), "", ", " + TrimAll(vSrvRow.Remarks)));
//				EndIf;
//			EndDo;
//		Else
//			vServices.Clear();
//		EndIf;
//	EndIf;
//	Return vServices;
//EndFunction //pmGetServicesPostedToAccounts
//
////-----------------------------------------------------------------------------
//Процедура Filling(pBase)
//	// Fill attributes with default values
//	pmFillAttributesWithDefaultValues();
//	// Fill from the base
//	If ЗначениеЗаполнено(pBase) Тогда
//		If TypeOf(pBase) = Type("DocumentRef.СчетПроживания") Тогда
//			pmFillByFolio(pBase);
//		ElsIf TypeOf(pBase) = Type("DocumentRef.Reservation") Тогда 
//			pmFillByDocument(pBase);
//		ElsIf TypeOf(pBase) = Type("DocumentRef.Размещение") Тогда 
//			pmFillByDocument(pBase);
//		ElsIf TypeOf(pBase) = Type("DocumentRef.БроньУслуг") Тогда 
//			pmFillByResourceReservation(pBase);
//		ElsIf TypeOf(pBase) = Type("DocumentRef.СчетНаОплату") Тогда 
//			pmFillByInvoice(pBase);
//		ElsIf TypeOf(pBase) = Type("CatalogRef.ГруппыГостей") Тогда 
//			pmFillByGuestGroup(pBase);
//		ElsIf TypeOf(pBase) = Type("CatalogRef.Контрагенты") Тогда
//			pmFillByCustomer(pBase);
//		ElsIf TypeOf(pBase) = Type("CatalogRef.Договора") Тогда
//			pmFillByContract(pBase);
//		EndIf;
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
//		  Services.Total("Количество") <> vOldServices.Total("Количество") Тогда
//		Return True;
//	Else
//		vNewServices = Services.Unload();
//		vOldServices = vOldServices.Unload();
//		vNewServices.GroupBy("Услуга", "Сумма, СуммаНДС, СуммаКомиссии, Количество");
//		vOldServices.GroupBy("Услуга", "Сумма, СуммаНДС, СуммаКомиссии, Количество");
//		For Each vNewServicesRow In vNewServices Do
//			vOldServicesRow = vOldServices.Find(vNewServicesRow.Service, "Услуга");
//			If vOldServicesRow = Неопределено Тогда
//				Return True;
//			ElsIf vOldServicesRow.Сумма <> vNewServicesRow.Sum Or 
//				  vOldServicesRow.СуммаНДС <> vNewServicesRow.VATSum Or 
//				  vOldServicesRow.СуммаКомиссии <> vNewServicesRow.CommissionSum Or 
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
//			WriteLogEvent(NStr("en='Document.DataValidation';ru='Документ.КонтрольДанных';de='Document.DataValidation'"), EventLogLevel.Warning, ThisObject.Metadata(), ThisObject.Ref, NStr(vMessage));
//			Message(NStr(vMessage), MessageStatus.Attention);
//			ВызватьИсключение NStr(vMessage);
//		EndIf;
//		If IsBlankString(InvoiceNumber) And НЕ DoNotExportToTheAccountingSystem And 
//		   ЗначениеЗаполнено(Фирма) And Фирма.AutoAssignVATInvoiceNumbers Тогда
//			vLastInvoiceNumber = cmGetLastUsedVATInvoiceNumber(Фирма);
//			InvoiceNumber = cmGetNextVATInvoiceNumber(vLastInvoiceNumber);
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
//		If DeletionMark Тогда
//			WriteLogEvent(NStr("en='SuspiciousEvents.SettlementSetDeletionMark';de='SuspiciousEvents.SettlementSetDeletionMark';ru='СигналыОПодозрительныхДействиях.УстановкаПометкиНаУдалениеВАкте'"), EventLogLevel.Warning, Metadata(), Ref, NStr("en='Set document deletion mark';ru='Установка отметки удаления';de='Erstellung der Löschmarkierung'"));
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
//	WriteLogEvent(NStr("en='SuspiciousEvents.SettlementDeletion';de='SuspiciousEvents.SettlementDeletion';ru='СигналыОПодозрительныхДействиях.УдалениеАкта'"), EventLogLevel.Warning, Metadata(), Ref, NStr("en='Document deletion';ru='Непосредственное удаление';de='Unmittelbare Löschung'"));
//КонецПроцедуры //BeforeDelete
//
////-----------------------------------------------------------------------------
//Процедура OnSetNewNumber(pStandardProcessing, pPrefix)
//	vPrefix = "";
//	If ЗначениеЗаполнено(Фирма) Тогда
//		vPrefix = TrimAll(Фирма.Prefix);
//	ElsIf ЗначениеЗаполнено(Гостиница) Тогда
//		vPrefix = TrimAll(Гостиница.GetObject().pmGetPrefix());
//	ElsIf ЗначениеЗаполнено(ПараметрыСеанса.ТекущаяГостиница) Тогда
//		If ЗначениеЗаполнено(ПараметрыСеанса.ТекущаяГостиница.Фирма) Тогда
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
//	InvoiceNumber = "";
//КонецПроцедуры //OnCopy
//
////-----------------------------------------------------------------------------
//Процедура pmPrintSettlement(vSpreadsheet, SelLanguage, SelGroupBy, SelObjectPrintForm, pPageBreak = False) Экспорт
//	// Basic checks
//	vHotel = Гостиница;
//	If НЕ ЗначениеЗаполнено(vHotel) Тогда
//		Message("Не задана гостиница!", MessageStatus.Attention);
//		Return;
//	EndIf;
//	vCompany = Фирма;
//	If НЕ ЗначениеЗаполнено(vCompany) Тогда
//		Message("Не задана фирма!", MessageStatus.Attention);
//		Return;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(SelLanguage) Тогда
//		SelLanguage = ПараметрыСеанса.ТекЛокализация;
//	EndIf;
//	
//	// Fill and check grouping parameter
//	vParameter = Upper(TrimAll(SelObjectPrintForm.Parameter));
//	
//	// Choose template
//	vSettlObj = ThisObject;
//	If pPageBreak Тогда
//		vSpreadsheet.PutHorizontalPageBreak();
//	Else
//		vSpreadsheet.Clear();
//	EndIf;
//	If ЗначениеЗаполнено(SelLanguage) Тогда
//		If SelLanguage = Справочники.Локализация.EN Тогда
//			vTemplate = vSettlObj.GetTemplate("SettlementDetailedEn");
//			If НЕ IsBlankString(SelGroupBy) Тогда
//				If SelGroupBy = "InPricePerFolio" Or SelGroupBy = "InPrice" Or SelGroupBy = "AllPerFolio" Or SelGroupBy = "All" Or SelGroupBy = "PerFolio" Or SelGroupBy = "ByService" Тогда
//					vTemplate = vSettlObj.GetTemplate("SettlementShortEn");
//				EndIf;
//			EndIf;
//		ElsIf SelLanguage = Справочники.Локализация.RU Тогда
//			vTemplate = vSettlObj.GetTemplate("SettlementDetailedRu");
//			If НЕ IsBlankString(SelGroupBy) Тогда
//				If SelGroupBy = "InPricePerFolio" Or SelGroupBy = "InPrice" Or SelGroupBy = "AllPerFolio" Or SelGroupBy = "All" Or SelGroupBy = "PerFolio" Or SelGroupBy = "ByService" Тогда
//					vTemplate = vSettlObj.GetTemplate("SettlementShortRu");
//				EndIf;
//			EndIf;
//		Else
//			Message("Не найден шаблон печатной формы акта для языка " + SelLanguage.Code , MessageStatus.Attention);
//			Return;
//		EndIf;
//	Else
//		vTemplate = vSettlObj.GetTemplate("SettlementDetailedRu");
//		If НЕ IsBlankString(SelGroupBy) Тогда
//			If SelGroupBy = "InPricePerFolio" Or SelGroupBy = "InPrice" Or SelGroupBy = "AllPerFolio" Or SelGroupBy = "All" Or SelGroupBy = "PerFolio" Or SelGroupBy = "ByService" Тогда
//				vTemplate = vSettlObj.GetTemplate("SettlementShortRu");
//			EndIf;
//		EndIf;
//	EndIf;
//	// Load external template if any
//	vExtTemplate = cmReadExternalSpreadsheetDocumentTemplate(SelObjectPrintForm);
//	If vExtTemplate <> Неопределено Тогда
//		vTemplate = vExtTemplate;
//	EndIf;
//	
//	// Load pictures
//	vStampIsSet = False;
//	vStamp = New Picture;
//	If ЗначениеЗаполнено(Фирма) Тогда
//		If Фирма.Stamp <> Неопределено Тогда
//			vStamp = Фирма.Stamp.Get();
//			If vStamp = Неопределено Тогда
//				vStamp = New Picture;
//			Else
//				vStampIsSet = True;
//			EndIf;
//		EndIf;
//	EndIf;
//	vDirectorSignatureIsSet = False;
//	vDirectorSignature = New Picture;
//	If Фирма.DirectorSignature <> Неопределено Тогда
//		vDirectorSignature = Фирма.DirectorSignature.Get();
//		If vDirectorSignature = Неопределено Тогда
//			vDirectorSignature = New Picture;
//		Else
//			vDirectorSignatureIsSet = True;
//		EndIf;
//	EndIf;
//	
//	// Header
//	vHeader = vTemplate.GetArea("Header");
//	// Гостиница
//	vHotelObj = vHotel.GetObject();
//	mHotelPrintName = vHotelObj.pmGetHotelPrintName(SelLanguage);
//	mHotelPostAddressPresentation = vHotelObj.pmGetHotelPostAddressPresentation(SelLanguage);
//	vHotelPhones = TrimAll(vHotel.Телефоны);
//	vHotelFax = TrimAll(vHotel.Fax);
//	mHotelPhones = vHotelPhones + ?(IsBlankString(vHotelFax), "",", факс '" + vHotelFax);
//	// Фирма
//	vCompanyObj = vCompany.GetObject();
//	vCompanyLegacyName = vCompanyObj.pmGetCompanyPrintName(SelLanguage);
//	vCompanyLegacyAddress = vCompanyObj.pmGetCompanyLegacyAddressPresentation(SelLanguage);
//	vCompanyPostAddress = vCompanyObj.pmGetCompanyPostAddressPresentation(SelLanguage);
//	If vCompanyPostAddress = vCompanyLegacyAddress Тогда
//		vCompanyPostAddress = "";
//	EndIf;
//	vCompanyTIN = TrimAll(vCompany.ИНН);
//	vCompanyKPP = TrimAll(vCompany.KPP);
//	vCompanyTIN = " ИНН '" + vCompanyTIN + ?(IsBlankString(vCompanyKPP), "", "/" + vCompanyKPP);
//	mCompany = TrimAll(vCompanyLegacyName + vCompanyTIN + Chars.LF + vCompanyLegacyAddress + ?(IsBlankString(vCompanyPostAddress), "", Chars.LF + vCompanyPostAddress));
//	// Settlement date and number
//	mSettlementNumber = ?(vCompany.PrintInvoiceAndSettlementNumbersWithPrefixes, TrimAll(Number), cmGetDocumentNumberPresentation(Number));
//	mSettlementDate = cmGetDocumentDatePresentation(Date);
//	// Контрагент
//	vCustomer = AccountingCustomer;
//	vCustomerLegacyName = "";
//	vCustomerLegacyAddress = "";
//	vCustomerPostAddress = "";
//	vCustomerTIN = "";
//	vCustomerPhones = "";
//	If ЗначениеЗаполнено(vCustomer) Тогда
//		vCustomerLegacyName = TrimAll(vCustomer.ЮрИмя);
//		If IsBlankString(vCustomerLegacyName) Тогда
//			vCustomerLegacyName = TrimAll(vCustomer.Description);
//		EndIf;
//		vCustomerLegacyAddress = cmGetAddressPresentation(vCustomer.LegacyAddress);
//		vCustomerPostAddress = cmGetAddressPresentation(vCustomer.PostAddress);
//		If vCustomerPostAddress = vCustomerLegacyAddress Тогда
//			vCustomerPostAddress = "";
//		EndIf;
//		vCustomerTIN = TrimAll(vCustomer.ИНН);
//		vCustomerKPP = TrimAll(vCustomer.KPP);
//		vCustomerTIN = " ИНН '" + vCustomerTIN + ?(IsBlankString(vCustomerKPP), "", "/" + vCustomerKPP);
//		// Fax and E-Mail
//		vCustomerPhones = TrimAll(vCustomer.Телефон);
//		vCustomerFax = TrimAll(vCustomer.Fax);
//		vCustomerPhones = vCustomerPhones + ?(IsBlankString(vCustomerFax), "", ", факс '" + vCustomerFax);
//	EndIf;
//	mCustomer = TrimAll(vCustomerLegacyName + vCustomerTIN + Chars.LF + vCustomerLegacyAddress + ?(IsBlankString(vCustomerPostAddress), "", Chars.LF + vCustomerPostAddress) + Chars.LF + vCustomerPhones);
//	// Contract
//	mContract = "";
//	If ЗначениеЗаполнено(AccountingContract) Тогда
//		mContract = TrimAll(AccountingContract.Description);
//	EndIf;
//	// Guest group code
//	mGuestGroup = "";
//	If ЗначениеЗаполнено(GuestGroup) Тогда
//		mGuestGroup = Format(GuestGroup.Code, "ND=12; NFD=0");
//		If ЗначениеЗаполнено(Гостиница) Тогда
//			vHotelPrefix = Гостиница.GetObject().pmGetPrefix();
//			If НЕ IsBlankString(vHotelPrefix) And Гостиница.ShowHotelPrefixBeforeGroupCode Тогда
//				mGuestGroup = vHotelPrefix + mGuestGroup;
//			EndIf;
//		EndIf;
//	EndIf;
//	// Currency
//	mAccountingCurrency = "";
//	If ЗначениеЗаполнено(AccountingCurrency) Тогда
//		vCurrencyObj = AccountingCurrency.GetObject();
//		mAccountingCurrency = vCurrencyObj.pmGetCurrencyDescription(SelLanguage);
//	EndIf;
//	// Parent document
//	mParentDoc = String(ParentDoc);
//	// Set parameters and put report section
//	vHeader.Parameters.mHotelPrintName = mHotelPrintName;
//	vHeader.Parameters.mHotelPostAddressPresentation = mHotelPostAddressPresentation;
//	vHeader.Parameters.mHotelPhones = mHotelPhones;
//	vHeader.Parameters.mSettlementNumber = mSettlementNumber;
//	vHeader.Parameters.mSettlementDate = mSettlementDate;
//	vHeader.Parameters.mCompany = mCompany;
//	vHeader.Parameters.mCustomer = mCustomer;
//	vHeader.Parameters.mContract = mContract;
//	vHeader.Parameters.mGuestGroup = mGuestGroup;
//	vHeader.Parameters.mAccountingCurrency = mAccountingCurrency;
//	vHeader.Parameters.mParentDoc = mParentDoc;
//	vSpreadsheet.Put(vHeader);
//	
//	// Get template areas
//	vFolio = vTemplate.GetArea("СчетПроживания");
//	vRow = vTemplate.GetArea("Row");
//	
//	// Get all services
//	vServices = Services.Unload();
//	
//	// Change accounting dates for breakfast
//	If НЕ IsBlankString(SelGroupBy) And SelGroupBy <> "ByService" Тогда
//		For Each vSrvRow In vServices Do
//			If vSrvRow.IsInPrice And ЗначениеЗаполнено(vSrvRow.Service.QuantityCalculationRule) And
//			   vSrvRow.Service.QuantityCalculationRule.QuantityCalculationRuleType = Перечисления.QuantityCalculationRuleTypes.Breakfast Тогда
//				If ЗначениеЗаполнено(vSrvRow.ЛицевойСчет) And BegOfDay(vSrvRow.AccountingDate) > BegOfDay(vSrvRow.ЛицевойСчет.DateTimeFrom) Тогда
//					vSrvRow.AccountingDate = vSrvRow.AccountingDate - 24*3600;
//				EndIf;
//			EndIf;
//		EndDo;
//	EndIf;
//	
//	// Join services according to service parameters
//	If НЕ IsBlankString(SelGroupBy) And SelGroupBy <> "ByService" Тогда
//		i = 0;
//		While i < vServices.Count() Do
//			vSrvRow = vServices.Get(i);
//			If НЕ vSrvRow.IsInPrice And ЗначениеЗаполнено(vSrvRow.Услуга.HideIntoServiceOnPrint) Тогда
//				// Try to find service to hide current one to
//				vHideToServices = vServices.FindRows(New Structure("Услуга, УчетнаяДата, СчетПроживания", vSrvRow.Услуга.HideIntoServiceOnPrint, vSrvRow.УчетнаяДата, vSrvRow.СчетПроживания));
//				If vHideToServices.Count() = 1 Тогда
//					vSrv2Hide2 = vHideToServices.Get(0);
//					vSrv2Hide2.Сумма = vSrv2Hide2.Сумма + vSrvRow.Сумма;
//					vSrv2Hide2.СуммаНДС = vSrv2Hide2.СуммаНДС + vSrvRow.СуммаНДС;
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
//		If SelGroupBy = "InPricePerFolioPerDay" Or SelGroupBy = "InPricePerDay" Or
//		   SelGroupBy = "AllPerFolioPerDay" Or SelGroupBy = "AllPerDay" Or
//		   SelGroupBy = "InPricePerFolio" Or SelGroupBy = "InPrice" Or
//		   SelGroupBy = "AllPerFolio" Or SelGroupBy = "All" Тогда
//			If Find(vParameter, "SHOWZEROES") = 0 Тогда
//				If vSrvRow.Сумма = 0 Тогда
//					vServices.Delete(i);
//					Continue;
//				EndIf;
//			EndIf;
//		EndIf;
//		If vAccommodationService = Неопределено And vSrvRow.IsRoomRevenue And НЕ vSrvRow.Услуга.RoomRevenueAmountsOnly Тогда
//			vAccommodationService = vSrvRow.Услуга;
//			vAccommodationServiceVATRate = vSrvRow.СтавкаНДС;
//			vAccommodationRemarks = TrimAll(vSrvRow.Примечания);
//			If SelGroupBy = "InPricePerFolioPerDay" Or SelGroupBy = "InPricePerDay" Or
//			   SelGroupBy = "AllPerFolioPerDay" Or SelGroupBy = "AllPerDay" Or
//			   SelGroupBy = "InPricePerFolio" Or SelGroupBy = "InPrice" Or
//			   SelGroupBy = "AllPerFolio" Or SelGroupBy = "All" Тогда
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
//	// Group by services according to the settlement print type
//	If НЕ IsBlankString(SelGroupBy) Тогда
//		If SelGroupBy = "InPricePerFolioPerDay" Or SelGroupBy = "InPricePerDay" Тогда
//			For Each vSrvRow In vServices Do
//				// Reset "is in price" flag if necessary
//				If ЗначениеЗаполнено(vSrvRow.Service) And vSrvRow.Service.DoNotGroupIntoRoomRateOnPrint Тогда
//					vSrvRow.IsInPrice = False;
//				EndIf;
//				vSrvRow.AccountingDate = BegOfDay(vSrvRow.AccountingDate);
//				vSrvRow.CalendarDayType = Справочники.ТипДневногоКалендаря.EmptyRef();
//				vSrvRow.ГруппаНомеров = Справочники.НомернойФонд.EmptyRef();
//				If SelGroupBy = "InPricePerDay" Тогда
//					vSrvRow.ЛицевойСчет = Documents.СчетПроживания.EmptyRef();
//				EndIf;
//				If ЗначениеЗаполнено(vAccommodationService) And vAccommodationServiceVATRate = vSrvRow.VATRate Тогда
//					If НЕ vSrvRow.IsRoomRevenue And vSrvRow.IsInPrice Тогда
//						vSrvRow.Service = ?(ЗначениеЗаполнено(vAccommodationService), vAccommodationService, vSrvRow.Service);
//						vSrvRow.Remarks = ?(IsBlankString(vAccommodationRemarks), TrimAll(vSrvRow.Remarks), vAccommodationRemarks);
//						vSrvRow.Quantity = ?(IsBlankString(vAccommodationRemarks), vSrvRow.Quantity, 0);
//						vSrvRow.Price = 0;
//					ElsIf vSrvRow.IsRoomRevenue And vSrvRow.IsInPrice Тогда
//						If vSrvRow.Service.RoomRevenueAmountsOnly Тогда
//							vSrvRow.Quantity = 0;
//							vSrvRow.Price = 0;
//						EndIf;
//						vSrvRow.Service = ?(ЗначениеЗаполнено(vAccommodationService), vAccommodationService, vSrvRow.Service);
//						vSrvRow.Remarks = ?(IsBlankString(vAccommodationRemarks), TrimAll(vSrvRow.Remarks), vAccommodationRemarks);
//					EndIf;
//				EndIf;
//			EndDo;
//		ElsIf SelGroupBy = "AllPerFolioPerDay" Or SelGroupBy = "AllPerDay" Тогда
//			For Each vSrvRow In vServices Do
//				vSrvRow.AccountingDate = BegOfDay(vSrvRow.AccountingDate);
//				vSrvRow.CalendarDayType = Справочники.ТипДневногоКалендаря.EmptyRef();
//				vSrvRow.ГруппаНомеров = Справочники.НомернойФонд.EmptyRef();
//				If SelGroupBy = "AllPerDay" Тогда
//					vSrvRow.ЛицевойСчет = Documents.СчетПроживания.EmptyRef();
//				EndIf;
//				If ЗначениеЗаполнено(vAccommodationService) And vAccommodationServiceVATRate = vSrvRow.VATRate Тогда
//					If vSrvRow.Service.RoomRevenueAmountsOnly Тогда
//						vSrvRow.Quantity = 0;
//						vSrvRow.Price = 0;
//					EndIf;
//					vSrvRow.Service = ?(ЗначениеЗаполнено(vAccommodationService), vAccommodationService, vSrvRow.Service);
//					vSrvRow.Remarks = ?(IsBlankString(vAccommodationRemarks), TrimAll(vSrvRow.Remarks), vAccommodationRemarks);
//					If НЕ vSrvRow.IsRoomRevenue Тогда
//						vSrvRow.Quantity = ?(IsBlankString(vAccommodationRemarks), vSrvRow.Quantity, 0);
//						vSrvRow.Price = 0;
//					EndIf;
//				EndIf;
//			EndDo;
//		ElsIf SelGroupBy = "PerFolio" Тогда
//			For Each vSrvRow In vServices Do
//				vSrvRow.AccountingDate = BegOfDay(Date);
//			EndDo;
//		ElsIf SelGroupBy = "ByService" Тогда
//			For Each vSrvRow In vServices Do
//				vSrvRow.AccountingDate = BegOfDay(Date);
//				vSrvRow.ЛицевойСчет = Documents.СчетПроживания.EmptyRef();
//				vSrvRow.CalendarDayType = Справочники.ТипДневногоКалендаря.EmptyRef();
//				vSrvRow.ГруппаНомеров = Справочники.НомернойФонд.EmptyRef();
//				vSrvRow.Resource = Справочники.Ресурсы.EmptyRef();
//			EndDo;
//		ElsIf SelGroupBy = "InPricePerFolio" Or SelGroupBy = "InPrice" Тогда
//			For Each vSrvRow In vServices Do
//				// Reset "is in price" flag if necessary
//				If ЗначениеЗаполнено(vSrvRow.Service) And vSrvRow.Service.DoNotGroupIntoRoomRateOnPrint Тогда
//					vSrvRow.IsInPrice = False;
//				EndIf;
//				vSrvRow.AccountingDate = BegOfDay(Date);
//				If SelGroupBy = "InPrice" Тогда
//					vSrvRow.ЛицевойСчет = Documents.СчетПроживания.EmptyRef();
//					vSrvRow.CalendarDayType = Справочники.ТипДневногоКалендаря.EmptyRef();
//					vSrvRow.ГруппаНомеров = Справочники.НомернойФонд.EmptyRef();
//				EndIf;
//				If ЗначениеЗаполнено(vAccommodationService) And vAccommodationServiceVATRate = vSrvRow.VATRate Тогда
//					If НЕ vSrvRow.IsRoomRevenue And vSrvRow.IsInPrice Тогда
//						vSrvRow.Service = ?(ЗначениеЗаполнено(vAccommodationService), vAccommodationService, vSrvRow.Service);
//						vSrvRow.Remarks = ?(IsBlankString(vAccommodationRemarks), TrimAll(vSrvRow.Remarks), vAccommodationRemarks);
//						vSrvRow.Quantity = ?(IsBlankString(vAccommodationRemarks), vSrvRow.Quantity, 0);
//						vSrvRow.Price = 0;
//					ElsIf vSrvRow.IsRoomRevenue And vSrvRow.IsInPrice Тогда
//						If vSrvRow.Service.RoomRevenueAmountsOnly Тогда
//							vSrvRow.Quantity = 0;
//							vSrvRow.Price = 0;
//						EndIf;
//						vSrvRow.Service = ?(ЗначениеЗаполнено(vAccommodationService), vAccommodationService, vSrvRow.Service);
//						vSrvRow.Remarks = ?(IsBlankString(vAccommodationRemarks), TrimAll(vSrvRow.Remarks), vAccommodationRemarks);
//					EndIf;
//				EndIf;
//			EndDo;
//		ElsIf SelGroupBy = "AllPerFolio" Or SelGroupBy = "All" Тогда
//			For Each vSrvRow In vServices Do
//				vSrvRow.AccountingDate = BegOfDay(Date);
//				vSrvRow.CalendarDayType = Справочники.ТипДневногоКалендаря.EmptyRef();
//				vSrvRow.ГруппаНомеров = Справочники.НомернойФонд.EmptyRef();
//				If SelGroupBy = "All" Тогда
//					vSrvRow.ЛицевойСчет = Documents.СчетПроживания.EmptyRef();
//				EndIf;
//				If ЗначениеЗаполнено(vAccommodationService) And vAccommodationServiceVATRate = vSrvRow.VATRate Тогда
//					If vSrvRow.Service.RoomRevenueAmountsOnly Тогда
//						vSrvRow.Quantity = 0;
//						vSrvRow.Price = 0;
//					EndIf;
//					vSrvRow.Service = ?(ЗначениеЗаполнено(vAccommodationService), vAccommodationService, vSrvRow.Service);
//					vSrvRow.Remarks = ?(IsBlankString(vAccommodationRemarks), TrimAll(vSrvRow.Remarks), vAccommodationRemarks);
//					If НЕ vSrvRow.IsRoomRevenue Тогда
//						vSrvRow.Quantity = ?(IsBlankString(vAccommodationRemarks), vSrvRow.Quantity, 0);
//						vSrvRow.Price = 0;
//					EndIf;
//				EndIf;
//			EndDo;
//		EndIf;
//		// Group by transactions
//		vServices.GroupBy("СчетПроживания, УчетнаяДата, Услуга, ТипДеньКалендарь, НомерРазмещения, Ресурс, Примечания, СтавкаНДС", "Сумма, СуммаНДС, Цена, Количество");
//		// Recalculate price for all services and delete zero sum rows
//		i = 0;
//		While i < vServices.Count() Do
//			vSrvRow = vServices.Get(i);
//			If vSrvRow.Сумма = 0 And SelGroupBy <> "ByService" And Find(vParameter, "SHOWZEROES") = 0 Тогда
//				vServices.Delete(i);
//			Else
//				vSrvRow.СуммаНДС = cmCalculateVATSum(vSrvRow.СтавкаНДС, vSrvRow.Сумма);
//				vSrvRow.Цена = cmRecalculatePrice(vSrvRow.Сумма, vSrvRow.Количество);
//				i = i + 1;
//			EndIf;
//		EndDo;
//	EndIf;
//	vServices.Sort("СчетПроживания, УчетнаяДата");
//	
//	// Print services
//	vTotalSum = 0;
//	vTotalVATSum = 0;
//	vCurFolio = Documents.СчетПроживания.EmptyRef();
//	For Each vSrvRow In vServices Do
//		// Print folio header if necessary
//		If vSrvRow.ЛицевойСчет <> vCurFolio Тогда
//			vCurFolio = vSrvRow.ЛицевойСчет;
//			// Fill folio parameters
//			mClient = "";
//			If ЗначениеЗаполнено(vCurFolio.Клиент) Тогда
//				mClient = TrimAll(TrimAll(vCurFolio.Клиент.Фамилия) + " " + TrimAll(vCurFolio.Клиент.Имя) + " " + TrimAll(vCurFolio.Клиент.Отчество));
//			ElsIf ЗначениеЗаполнено(vCurFolio.Контрагент) Тогда
//				If НЕ IsBlankString(vCurFolio.Контрагент.ЮрИмя) Тогда
//					mClient = TrimAll(vCurFolio.Контрагент.ЮрИмя);
//				Else
//					mClient = TrimAll(vCurFolio.Контрагент.Description);
//				EndIf;
//			EndIf;
//			vDateFrom = vCurFolio.DateTimeFrom;
//			vDateTo = vCurFolio.DateTimeTo;
//			cmGetServicesPeriodByFolio(vCurFolio, Ref, vDateFrom, vDateTo);
//			vRStr = "";
//			If ЗначениеЗаполнено(vCurFolio.НомерРазмещения) Тогда
//				vRStr = TrimAll(vCurFolio.НомерРазмещения.Description);
//			ElsIf ЗначениеЗаполнено(vSrvRow.Resource) Тогда
//				vRStr = vSrvRow.Resource.GetObject().pmGetResourceDescription(SelLanguage);
//			EndIf;
//			mClient = mClient + 
//			          ?(vCompany.OutputGuestPeriodInVATInvoice, ?(ЗначениеЗаполнено(vDateFrom), ", " + cmPeriodPresentation(vDateFrom, vDateTo), ""), "") + 
//			          ?(IsBlankString(vRStr), "" , ", " + vRStr);
//			// Set folio parameters
//			vFolio.Parameters.mClient = mClient;
//			// Put folio
//			vSpreadsheet.Put(vFolio);
//		EndIf;
//		// Fill row parameters
//		mAccountingDate = Format(vSrvRow.AccountingDate, "DF=dd.MM.yy");
//		mPrice = vSrvRow.Price;
//		mDescription = vSrvRow.Remarks;
//		mSum = vSrvRow.Sum;
//		If Round(vSrvRow.Quantity, 3) <> vSrvRow.Quantity Тогда
//			mQuantity = ?(vSrvRow.Quantity = 0, "", Format(vSrvRow.Quantity, "ND=17; NFD=3"));
//		Else
//			mQuantity = ?(vSrvRow.Quantity = 0, "", String(vSrvRow.Quantity));
//		EndIf;
//		If ЗначениеЗаполнено(vSrvRow.Service) Тогда
//			If vSrvRow.Quantity <> 0 Тогда
//				vServiceObj = vSrvRow.Service.GetObject();
//				mQuantity = vServiceObj.pmGetServiceQuantityPresentation(vSrvRow.Quantity, SelLanguage);
//			EndIf;
//		EndIf;
//		vTotalSum = vTotalSum + vSrvRow.Sum;
//		vTotalVATSum = vTotalVATSum + vSrvRow.VATSum;
//		// Set parameters
//		If SelGroupBy <> "InPrice" And SelGroupBy <> "InPricePerFolio" And SelGroupBy <> "All" And SelGroupBy <> "AllPerFolio" And SelGroupBy <> "PerFolio" And SelGroupBy <> "ByService" Тогда
//			vRow.Parameters.mAccountingDate = mAccountingDate;
//		EndIf;
//		vRow.Parameters.mPrice = Format(mPrice, "ND=17; NFD=2");
//		vRow.Parameters.mQuantity = mQuantity;
//		If SelGroupBy = "InPricePerFolio" Or SelGroupBy = "AllPerFolio" Or SelGroupBy = "PerFolio" Тогда
//			vRow.Parameters.mDescription = Chars.Tab + mDescription;
//		Else
//			vRow.Parameters.mDescription = mDescription;
//		EndIf;
//		vRow.Parameters.mSum = Format(mSum, "ND=17; NFD=2");
//		// Put row
//		If НЕ IsBlankString(mSum) Тогда
//			vSpreadsheet.Put(vRow);
//		EndIf;
//	EndDo;
//	
//	// Footer
//	vFooter = vTemplate.GetArea("Footer");
//	// Fill parameters
//	mTotalSum = Format(vTotalSum, "ND=17; NFD=2") + " " + mAccountingCurrency;
//	If ЗначениеЗаполнено(vCompany) And vCompany.DoNotPrintVAT Тогда
//		mTotalVATSum = "";
//	Else
//		If vTotalVATSum <> 0 Тогда
//			mTotalVATSum = "В том числе НДС ';de='Darunter MwSt. '" + Format(vTotalVATSum, "ND=17; NFD=2") + " " + mAccountingCurrency;
//		Else
//			mTotalVATSum = "НДС не облагается';de='MwSt. wird nicht berechnet'";
//		EndIf;
//	EndIf;
//	mTotalSumInWords = cmSumInWords(vTotalSum, AccountingCurrency, SelLanguage);
//	// Set parameters
//	vFooter.Parameters.mRemarks = TrimAll(Remarks);
//	vFooter.Parameters.mTotalSum = mTotalSum;
//	vFooter.Parameters.mTotalVATSum = mTotalVATSum;
//	vFooter.Parameters.mTotalSumInWords = mTotalSumInWords;
//	// Put footer
//	vSpreadsheet.Put(vFooter);
//	
//	// Simple tax system
//	If vCompany.IsUsingSimpleTaxSystem Тогда
//		vSTS = vTemplate.GetArea("SimpleTaxSystem");
//		vSpreadsheet.Put(vSTS);
//	EndIf;
//	
//	// Signatures
//	vSignatures = vTemplate.GetArea("Signatures");
//	// Фирма stamp and signatures
//	If PrintWithCompanyStamp Тогда
//		If vStampIsSet Тогда
//			vSignatures.Drawings.Stamp.Print = True;
//			vSignatures.Drawings.Stamp.Picture = vStamp;
//		Else
//			vSignatures.Drawings.Delete(vSignatures.Drawings.Stamp);
//		EndIf;
//		If vDirectorSignatureIsSet Тогда
//			vSignatures.Drawings.DirectorSignature.Print = True;
//			vSignatures.Drawings.DirectorSignature.Picture = vDirectorSignature;
//		Else
//			vSignatures.Drawings.Delete(vSignatures.Drawings.DirectorSignature);
//		EndIf;
//	Else
//		vSignatures.Drawings.Delete(vSignatures.Drawings.Stamp);
//		vSignatures.Drawings.Delete(vSignatures.Drawings.DirectorSignature);
//	EndIf;
//	vSpreadsheet.Put(vSignatures);
//
//	// Setup default attributes
//	cmSetDefaultPrintFormSettings(vSpreadsheet, PageOrientation.Portrait, True, , True);
//	// Check authorities
//	cmSetSpreadsheetProtection(vSpreadsheet);
//КонецПроцедуры //pmPrintSettlement
//
////-----------------------------------------------------------------------------
//Процедура pmPrintSettlementHotelProducts(vSpreadsheet, SelLanguage, SelGroupBy, SelObjectPrintForm, pPageBreak = False) Экспорт
//	// Basic checks
//	vHotel = Гостиница;
//	If НЕ ЗначениеЗаполнено(vHotel) Тогда
//		Message(NStr("en='Гостиница should be filled!';ru='Не задана гостиница!';de='Das Гостиница ist nicht angegeben!'"), MessageStatus.Attention);
//		Return;
//	EndIf;
//	vCompany = Фирма;
//	If НЕ ЗначениеЗаполнено(vCompany) Тогда
//		Message(NStr("en='Фирма should be filled!';ru='Не задана фирма!';de='Die Firma ist nicht angegeben!'"), MessageStatus.Attention);
//		Return;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(SelLanguage) Тогда
//		SelLanguage = ПараметрыСеанса.ТекЛокализация;
//	EndIf;
//	
//	// Choose template
//	vSettlObj = ThisObject;
//	If pPageBreak Тогда
//		vSpreadsheet.PutHorizontalPageBreak();
//	Else
//		vSpreadsheet.Clear();
//	EndIf;
//	vTemplate = vSettlObj.GetTemplate("WayBill");
//	// Load external template if any
//	vExtTemplate = cmReadExternalSpreadsheetDocumentTemplate(SelObjectPrintForm);
//	If vExtTemplate <> Неопределено Тогда
//		vTemplate = vExtTemplate;
//	EndIf;
//	
//	// Load pictures
//	vStampIsSet = False;
//	vStamp = New Picture;
//	If ЗначениеЗаполнено(Фирма) Тогда
//		If Фирма.Stamp <> Неопределено Тогда
//			vStamp = Фирма.Stamp.Get();
//			If vStamp = Неопределено Тогда
//				vStamp = New Picture;
//			Else
//				vStampIsSet = True;
//			EndIf;
//		EndIf;
//	EndIf;
//	vDirectorSignatureIsSet = False;
//	vDirectorSignature = New Picture;
//	If Фирма.DirectorSignature <> Неопределено Тогда
//		vDirectorSignature = Фирма.DirectorSignature.Get();
//		If vDirectorSignature = Неопределено Тогда
//			vDirectorSignature = New Picture;
//		Else
//			vDirectorSignatureIsSet = True;
//		EndIf;
//	EndIf;
//	vAccountantGeneralSignatureIsSet = False;
//	vAccountantGeneralSignature = New Picture;
//	If Фирма.AccountantGeneralSignature <> Неопределено Тогда
//		vAccountantGeneralSignature = Фирма.AccountantGeneralSignature.Get();
//		If vAccountantGeneralSignature = Неопределено Тогда
//			vAccountantGeneralSignature = New Picture;
//		Else
//			vAccountantGeneralSignatureIsSet = True;
//		EndIf;
//	EndIf;
//	
//	// Header
//	vHeader = vTemplate.GetArea("Header");
//	// Гостиница
//	vHotelObj = vHotel.GetObject();
//	mHotelPrintName = vHotelObj.pmGetHotelPrintName(SelLanguage);
//	mHotelPostAddressPresentation = vHotelObj.pmGetHotelPostAddressPresentation(SelLanguage);
//	vHotelPhones = TrimAll(vHotel.Телефоны);
//	vHotelFax = TrimAll(vHotel.Fax);
//	mHotelPhones = vHotelPhones + ?(IsBlankString(vHotelFax), "", ", факс '" + vHotelFax);
//	// Фирма
//	vCompanyObj = vCompany.GetObject();
//	vCompanyLegacyName = vCompanyObj.pmGetCompanyPrintName(SelLanguage);
//	vCompanyLegacyAddress = vCompanyObj.pmGetCompanyLegacyAddressPresentation(SelLanguage);
//	vCompanyPostAddress = vCompanyObj.pmGetCompanyPostAddressPresentation(SelLanguage);
//	If vCompanyPostAddress = vCompanyLegacyAddress Тогда
//		vCompanyPostAddress = "";
//	EndIf;
//	vCompanyTIN = TrimAll(vCompany.ИНН);
//	vCompanyKPP = TrimAll(vCompany.KPP);
//	vCompanyTIN = " ИНН '" + vCompanyTIN + ?(IsBlankString(vCompanyKPP), "", "/" + vCompanyKPP);
//	mCompany = TrimAll(vCompanyLegacyName + vCompanyTIN + Chars.LF + vCompanyLegacyAddress + ?(IsBlankString(vCompanyPostAddress), "", Chars.LF + vCompanyPostAddress));
//	// Settlement date and number
//	mSettlementNumber = ?(vCompany.PrintInvoiceAndSettlementNumbersWithPrefixes, TrimAll(Number), cmGetDocumentNumberPresentation(Number));
//	mSettlementDate = cmGetDocumentDatePresentation(Date);
//	// Контрагент
//	vCustomer = AccountingCustomer;
//	vCustomerLegacyName = "";
//	vCustomerLegacyAddress = "";
//	vCustomerPostAddress = "";
//	vCustomerTIN = "";
//	vCustomerPhones = "";
//	If ЗначениеЗаполнено(vCustomer) Тогда
//		vCustomerLegacyName = TrimAll(vCustomer.ЮрИмя);
//		If IsBlankString(vCustomerLegacyName) Тогда
//			vCustomerLegacyName = TrimAll(vCustomer.Description);
//		EndIf;
//		vCustomerLegacyAddress = cmGetAddressPresentation(vCustomer.LegacyAddress);
//		vCustomerPostAddress = cmGetAddressPresentation(vCustomer.PostAddress);
//		If vCustomerPostAddress = vCustomerLegacyAddress Тогда
//			vCustomerPostAddress = "";
//		EndIf;
//		vCustomerTIN = TrimAll(vCustomer.ИНН);
//		vCustomerKPP = TrimAll(vCustomer.KPP);
//		vCustomerTIN = " ИНН '" + vCustomerTIN + ?(IsBlankString(vCustomerKPP), "", "/" + vCustomerKPP);
//		// Fax and E-Mail
//		vCustomerPhones = TrimAll(vCustomer.Телефон);
//		vCustomerFax = TrimAll(vCustomer.Fax);
//		vCustomerPhones = vCustomerPhones + ?(IsBlankString(vCustomerFax), "",", факс '" + vCustomerFax);
//	EndIf;
//	mCustomer = TrimAll(vCustomerLegacyName + vCustomerTIN + Chars.LF + vCustomerLegacyAddress + ?(IsBlankString(vCustomerPostAddress), "", Chars.LF + vCustomerPostAddress) + Chars.LF + vCustomerPhones);
//	// Contract
//	mContract = "";
//	If ЗначениеЗаполнено(AccountingContract) Тогда
//		mContract = TrimAll(AccountingContract.Description);
//	EndIf;
//	// Guest group code
//	mGuestGroup = "";
//	If ЗначениеЗаполнено(GuestGroup) Тогда
//		mGuestGroup = Format(GuestGroup.Code, "ND=12; NFD=0");
//		If ЗначениеЗаполнено(Гостиница) Тогда
//			vHotelPrefix = Гостиница.GetObject().pmGetPrefix();
//			If НЕ IsBlankString(vHotelPrefix) And Гостиница.ShowHotelPrefixBeforeGroupCode Тогда
//				mGuestGroup = vHotelPrefix + mGuestGroup;
//			EndIf;
//		EndIf;
//	EndIf;
//	// Currency
//	mAccountingCurrency = "";
//	If ЗначениеЗаполнено(AccountingCurrency) Тогда
//		vCurrencyObj = AccountingCurrency.GetObject();
//		mAccountingCurrency = vCurrencyObj.pmGetCurrencyDescription(SelLanguage);
//	EndIf;
//	// Parent document
//	mParentDoc = String(ParentDoc);
//	// Set parameters and put report section
//	vHeader.Parameters.mHotelPrintName = mHotelPrintName;
//	vHeader.Parameters.mHotelPostAddressPresentation = mHotelPostAddressPresentation;
//	vHeader.Parameters.mHotelPhones = mHotelPhones;
//	vHeader.Parameters.mSettlementNumber = mSettlementNumber;
//	vHeader.Parameters.mSettlementDate = mSettlementDate;
//	vHeader.Parameters.mCompany = mCompany;
//	vHeader.Parameters.mCustomer = mCustomer;
//	vHeader.Parameters.mContract = mContract;
//	vHeader.Parameters.mGuestGroup = mGuestGroup;
//	vHeader.Parameters.mAccountingCurrency = mAccountingCurrency;
//	vHeader.Parameters.mParentDoc = mParentDoc;
//	vSpreadsheet.Put(vHeader);
//	
//	// Get template areas
//	vFolio = vTemplate.GetArea("СчетПроживания");
//	vRow = vTemplate.GetArea("Row");
//	
//	// Get all services
//	vServices = Services.Unload();
//	
//	// Change accounting dates for breakfast
//	If НЕ IsBlankString(SelGroupBy) And SelGroupBy <> "ByService" Тогда
//		For Each vSrvRow In vServices Do
//			If vSrvRow.IsInPrice And ЗначениеЗаполнено(vSrvRow.Service.QuantityCalculationRule) And
//			   vSrvRow.Service.QuantityCalculationRule.QuantityCalculationRuleType = Перечисления.QuantityCalculationRuleTypes.Breakfast Тогда
//				If ЗначениеЗаполнено(vSrvRow.ЛицевойСчет) And BegOfDay(vSrvRow.AccountingDate) > BegOfDay(vSrvRow.ЛицевойСчет.DateTimeFrom) Тогда
//					vSrvRow.AccountingDate = vSrvRow.AccountingDate - 24*3600;
//				EndIf;
//			EndIf;
//		EndDo;
//	EndIf;
//	
//	// Join services according to service parameters
//	If НЕ IsBlankString(SelGroupBy) And SelGroupBy <> "ByService" Тогда
//		i = 0;
//		While i < vServices.Count() Do
//			vSrvRow = vServices.Get(i);
//			If НЕ vSrvRow.IsInPrice And ЗначениеЗаполнено(vSrvRow.Услуга.HideIntoServiceOnPrint) Тогда
//				// Try to find service to hide current one to
//				vHideToServices = vServices.FindRows(New Structure("Услуга, УчетнаяДата, СчетПроживания", vSrvRow.Услуга.HideIntoServiceOnPrint, vSrvRow.УчетнаяДата, vSrvRow.СчетПроживания));
//				If vHideToServices.Count() = 1 Тогда
//					vSrv2Hide2 = vHideToServices.Get(0);
//					vSrv2Hide2.Сумма = vSrv2Hide2.Сумма + vSrvRow.Сумма;
//					vSrv2Hide2.СуммаНДС = vSrv2Hide2.СуммаНДС + vSrvRow.СуммаНДС;
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
//		If SelGroupBy = "InPricePerFolioPerDay" Or SelGroupBy = "InPricePerDay" Or
//		   SelGroupBy = "AllPerFolioPerDay" Or SelGroupBy = "AllPerDay" Or
//		   SelGroupBy = "InPricePerFolio" Or SelGroupBy = "InPrice" Or
//		   SelGroupBy = "AllPerFolio" Or SelGroupBy = "All" Тогда
//			If vSrvRow.Сумма = 0 Тогда
//				vServices.Delete(i);
//				Continue;
//			EndIf;
//		EndIf;
//		If vAccommodationService = Неопределено And vSrvRow.IsRoomRevenue And НЕ vSrvRow.Услуга.RoomRevenueAmountsOnly Тогда
//			vAccommodationService = vSrvRow.Услуга;
//			vAccommodationServiceVATRate = vSrvRow.СтавкаНДС;
//			vAccommodationRemarks = TrimAll(vSrvRow.Примечания);
//			If SelGroupBy = "AllPerFolio" Or SelGroupBy = "All" Тогда
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
//	// Fill hotel product from charges
//	If vServices.Columns.Find("ПутевкаКурсовка") = Неопределено Тогда
//		vServices.Columns.Add("ПутевкаКурсовка", cmGetCatalogTypeDescription("ПутевкиКурсовки"));
//	EndIf;
//	For Each vServicesRow In vServices Do
//		If ЗначениеЗаполнено(vServicesRow.Charge) And ЗначениеЗаполнено(vServicesRow.Charge.ПутевкаКурсовка) Тогда
//			vServicesRow.HotelProduct = vServicesRow.Charge.ПутевкаКурсовка;
//		EndIf;
//	EndDo;
//	
//	// Get list of hotel products
//	vHotelProducts = vServices.Copy(, "ПутевкаКурсовка");
//	vHotelProducts.GroupBy("ПутевкаКурсовка", );
//	
//	// Print service name and hotel product type
//	If НЕ IsBlankString(vAccommodationRemarks) Тогда
//		vRow.Parameters.mDescription = vAccommodationRemarks;
//		// Try to get first hotel product type
//		For Each vHotelProductsRow In vHotelProducts Do
//			vHotelProduct = vHotelProductsRow.HotelProduct;
//			If ЗначениеЗаполнено(vHotelProduct) Тогда
//				vRow.Parameters.mDescription = vRow.Parameters.mDescription + ?(ЗначениеЗаполнено(vHotelProduct.Parent), ", " + TrimAll(vHotelProduct.Parent), "");
//				Break;
//			EndIf;
//		EndDo;
//		vSpreadsheet.Put(vRow);
//	EndIf;
//	
//	// Initialize totals
//	vTotalSum = 0;
//	vTotalVATSum = 0;
//	vTotalQuantity = 0;
//	
//	// Do for each hotel product in the list
//	For Each vHotelProductsRow In vHotelProducts Do
//		vHotelProduct = vHotelProductsRow.HotelProduct;
//		
//		// Choose services for this current hotel product
//		vHPServicesArray = vServices.FindRows(New Structure("ПутевкаКурсовка", vHotelProduct));
//		If vHPServicesArray.Count() > 0 Тогда
//			vHPServices = vServices.CopyColumns();
//			For Each vHPServicesArrayRow In vHPServicesArray Do
//				vHPServicesRow = vHPServices.Add();
//				FillPropertyValues(vHPServicesRow, vHPServicesArrayRow);
//			EndDo;
//					
//			// Group by all services to the one accommodation service
//			For Each vSrvRow In vHPServices Do
//				vSrvRow.AccountingDate = BegOfDay(Date);
//				vSrvRow.CalendarDayType = Справочники.ТипДневногоКалендаря.EmptyRef();
//				vSrvRow.ГруппаНомеров = Справочники.НомернойФонд.EmptyRef();
//				If SelGroupBy = "All" Тогда
//					vSrvRow.ЛицевойСчет = Documents.СчетПроживания.EmptyRef();
//				EndIf;
//				If ЗначениеЗаполнено(vAccommodationService) And vAccommodationServiceVATRate = vSrvRow.VATRate Тогда
//					If vSrvRow.Service.RoomRevenueAmountsOnly Тогда
//						vSrvRow.Quantity = 0;
//						vSrvRow.Price = 0;
//					EndIf;
//					vSrvRow.Service = ?(ЗначениеЗаполнено(vAccommodationService), vAccommodationService, vSrvRow.Service);
//					vSrvRow.Remarks = ?(IsBlankString(vAccommodationRemarks), TrimAll(vSrvRow.Remarks), vAccommodationRemarks);
//					If НЕ vSrvRow.IsRoomRevenue Тогда
//						vSrvRow.Quantity = ?(IsBlankString(vAccommodationRemarks), vSrvRow.Quantity, 0);
//						vSrvRow.Price = 0;
//					EndIf;
//				EndIf;
//			EndDo;
//			// Group by transactions
//			vHPServices.GroupBy("СчетПроживания, УчетнаяДата, Услуга, ТипДеньКалендарь, НомерРазмещения, Ресурс, Примечания, СтавкаНДС", "Сумма, СуммаНДС, Цена, Количество");
//			// Recalculate price for all services
//			For Each vSrvRow In vHPServices Do
//				vSrvRow.Price = cmRecalculatePrice(vSrvRow.Sum, vSrvRow.Quantity);
//			EndDo;
//			vHPServices.Sort("СчетПроживания, УчетнаяДата");
//	
//			// Print hotel product
//			If ЗначениеЗаполнено(vHotelProduct) Тогда
//				// Fill hotel product parameters
//				mDescription = Chars.Tab + "№" + TrimAll(vHotelProduct.Description);
//				If ЗначениеЗаполнено(vHotelProduct.CheckInDate) And ЗначениеЗаполнено(vHotelProduct.CheckOutDate) Тогда
//					mDescription = mDescription + Chars.Tab + Chars.Tab + Chars.Tab + 
//					               Format(vHotelProduct.CheckInDate, "DF='dd.MM.yy'") + " - " +
//					               Format(vHotelProduct.CheckOutDate, "DF='dd.MM.yy'");
//				EndIf;
//				mPrice = vHPServices.Total("Сумма");
//				mSum = mPrice;
//				mQuantity = 1;
//				vTotalSum = vTotalSum + vSrvRow.Sum;
//				vTotalVATSum = vTotalVATSum + cmCalculateVATSum(vSrvRow.VATRate, vSrvRow.Sum);
//				vTotalQuantity = vTotalQuantity + 1;
//				// Set parameters
//				vRow.Parameters.mDescription = mDescription;
//				vRow.Parameters.mQuantity = mQuantity;
//				vRow.Parameters.mPrice = Format(mPrice, "ND=17; NFD=2");
//				vRow.Parameters.mSum = Format(mSum, "ND=17; NFD=2");
//				// Put row
//				If НЕ IsBlankString(mSum) Тогда
//					vSpreadsheet.Put(vRow);
//				EndIf;
//				// Print guest names if services are grouped be folio
//				If SelGroupBy = "AllPerFolio" Тогда
//					vCurFolio = Documents.СчетПроживания.EmptyRef();
//					For Each vSrvRow In vHPServices Do
//						If vSrvRow.ЛицевойСчет <> vCurFolio Тогда
//							vCurFolio = vSrvRow.ЛицевойСчет;
//							// Fill client parameters
//							mClient = "";
//							If ЗначениеЗаполнено(vCurFolio.Клиент) Тогда
//								mClient = TrimAll(TrimAll(vCurFolio.Клиент.Фамилия) + " " + TrimAll(vCurFolio.Клиент.Имя) + " " + TrimAll(vCurFolio.Клиент.Отчество));
//							ElsIf ЗначениеЗаполнено(vCurFolio.Контрагент) Тогда
//								If НЕ IsBlankString(vCurFolio.Контрагент.ЮрИмя) Тогда
//									mClient = TrimAll(vCurFolio.Контрагент.ЮрИмя);
//								Else
//									mClient = TrimAll(vCurFolio.Контрагент.Description);
//								EndIf;
//							EndIf;
//							// Set folio parameters
//							vFolio.Parameters.mClient = Chars.Tab + Chars.Tab + mClient;
//							// Put folio
//							vSpreadsheet.Put(vFolio);
//						EndIf;
//					EndDo;
//				EndIf;
//			Else
//				vCurFolio = Documents.СчетПроживания.EmptyRef();
//				For Each vSrvRow In vHPServices Do
//					// Print folio header if necessary
//					If vSrvRow.ЛицевойСчет <> vCurFolio Тогда
//						vCurFolio = vSrvRow.ЛицевойСчет;
//						// Fill folio parameters
//						mClient = "";
//						If ЗначениеЗаполнено(vCurFolio.Клиент) Тогда
//							mClient = TrimAll(TrimAll(vCurFolio.Клиент.Фамилия) + " " + TrimAll(vCurFolio.Клиент.Имя) + " " + TrimAll(vCurFolio.Клиент.Отчество));
//						ElsIf ЗначениеЗаполнено(vCurFolio.Контрагент) Тогда
//							If НЕ IsBlankString(vCurFolio.Контрагент.ЮрИмя) Тогда
//								mClient = TrimAll(vCurFolio.Контрагент.ЮрИмя);
//							Else
//								mClient = TrimAll(vCurFolio.Контрагент.Description);
//							EndIf;
//						EndIf;
//						vDateFrom = vCurFolio.DateTimeFrom;
//						vDateTo = vCurFolio.DateTimeTo;
//						cmGetServicesPeriodByFolio(vCurFolio, Ref, vDateFrom, vDateTo);
//						vRStr = "";
//						If ЗначениеЗаполнено(vCurFolio.НомерРазмещения) Тогда
//							vRStr = TrimAll(vCurFolio.НомерРазмещения.Description);
//						ElsIf ЗначениеЗаполнено(vSrvRow.Resource) Тогда
//							vRStr = vSrvRow.Resource.GetObject().pmGetResourceDescription(SelLanguage);
//						EndIf;
//						mClient = mClient + 
//						          ?(vCompany.OutputGuestPeriodInVATInvoice, ?(ЗначениеЗаполнено(vDateFrom), ", " + cmPeriodPresentation(vDateFrom, vDateTo), ""), "") + 
//						          ?(IsBlankString(vRStr), "" , ", " + vRStr);
//						// Set folio parameters
//						vFolio.Parameters.mClient = mClient;
//						// Put folio
//						vSpreadsheet.Put(vFolio);
//					EndIf;
//					// Fill row parameters
//					mPrice = vSrvRow.Price;
//					mDescription = vSrvRow.Remarks;
//					mSum = vSrvRow.Sum;
//					If Round(vSrvRow.Quantity, 3) <> vSrvRow.Quantity Тогда
//						mQuantity = ?(vSrvRow.Quantity = 0, "", Format(vSrvRow.Quantity, "ND=17; NFD=3"));
//					Else
//						mQuantity = ?(vSrvRow.Quantity = 0, "", String(vSrvRow.Quantity));
//					EndIf;
//					If ЗначениеЗаполнено(vSrvRow.Service) Тогда
//						If vSrvRow.Quantity <> 0 Тогда
//							vServiceObj = vSrvRow.Service.GetObject();
//							mQuantity = vServiceObj.pmGetServiceQuantityPresentation(vSrvRow.Quantity, SelLanguage);
//						EndIf;
//					EndIf;
//					vTotalSum = vTotalSum + vSrvRow.Sum;
//					vTotalVATSum = vTotalVATSum + cmCalculateVATSum(vSrvRow.VATRate, vSrvRow.Sum);
//					// Set parameters
//					vRow.Parameters.mPrice = Format(mPrice, "ND=17; NFD=2");
//					vRow.Parameters.mQuantity = mQuantity;
//					If SelGroupBy = "AllPerFolio" Тогда
//						vRow.Parameters.mDescription = Chars.Tab + mDescription;
//					Else
//						vRow.Parameters.mDescription = mDescription;
//					EndIf;
//					vRow.Parameters.mSum = Format(mSum, "ND=17; NFD=2");
//					// Put row
//					If НЕ IsBlankString(mSum) Тогда
//						vSpreadsheet.Put(vRow);
//					EndIf;
//				EndDo;
//			EndIf;
//		EndIf;
//	EndDo;
//	
//	// Footer
//	vFooter = vTemplate.GetArea("Footer");
//	// Fill parameters
//	mTotalSum = Format(vTotalSum, "ND=17; NFD=2");
//	If ЗначениеЗаполнено(vCompany) And vCompany.DoNotPrintVAT Тогда
//		mTotalVATSum = "";
//	Else
//		If vTotalVATSum <> 0 Тогда
//			mTotalVATSum = "В том числе НДС " + Format(vTotalVATSum, "ND=17; NFD=2");
//		Else
//			mTotalVATSum = "НДС не облагается";
//		EndIf;
//	EndIf;
//	mTotalSumInWords = cmSumInWords(vTotalSum, AccountingCurrency, SelLanguage);
//	mTotalQuantity = Format(vTotalQuantity, "ND=17; NFD=0");
//	// Set parameters
//	vFooter.Parameters.mRemarks = TrimAll(Remarks);
//	vFooter.Parameters.mTotalSum = mTotalSum;
//	vFooter.Parameters.mTotalVATSum = mTotalVATSum;
//	vFooter.Parameters.mTotalSumInWords = mTotalSumInWords;
//	vFooter.Parameters.mTotalQuantity = mTotalQuantity;
//	// Put footer
//	vSpreadsheet.Put(vFooter);
//	
//	// Signatures
//	vSignatures = vTemplate.GetArea("Signatures");
//	vSignatures.Parameters.mDirectorPosition = "Генеральный директор";
//	If НЕ IsBlankString(vCompany.RKODirectorPosition) Тогда
//		vSignatures.Parameters.mDirectorPosition = vCompany.RKODirectorPosition;
//	EndIf;
//	vSignatures.Parameters.mDirector = vCompany.Director;
//	vSignatures.Parameters.mAccountant =vCompany.AccountantGeneral;
//	// Фирма stamp and signatures
//	If PrintWithCompanyStamp Тогда
//		If vStampIsSet Тогда
//			vSignatures.Drawings.Stamp.Print = True;
//			vSignatures.Drawings.Stamp.Picture = vStamp;
//		Else
//			vSignatures.Drawings.Delete(vSignatures.Drawings.Stamp);
//		EndIf;
//		If vDirectorSignatureIsSet Тогда
//			vSignatures.Drawings.DirectorSignature.Print = True;
//			vSignatures.Drawings.DirectorSignature.Picture = vDirectorSignature;
//		Else
//			vSignatures.Drawings.Delete(vSignatures.Drawings.DirectorSignature);
//		EndIf;
//		If vAccountantGeneralSignatureIsSet Тогда
//			vSignatures.Drawings.AccountantGeneralSignature.Print = True;
//			vSignatures.Drawings.AccountantGeneralSignature.Picture = vAccountantGeneralSignature;
//		Else
//			vSignatures.Drawings.Delete(vSignatures.Drawings.AccountantGeneralSignature);
//		EndIf;
//	Else
//		vSignatures.Drawings.Delete(vSignatures.Drawings.Stamp);
//		vSignatures.Drawings.Delete(vSignatures.Drawings.DirectorSignature);
//		vSignatures.Drawings.Delete(vSignatures.Drawings.AccountantGeneralSignature);
//	EndIf;
//	vSpreadsheet.Put(vSignatures);
//
//	// Setup default attributes
//	cmSetDefaultPrintFormSettings(vSpreadsheet, PageOrientation.Portrait, True, , True);
//	// Check authorities
//	cmSetSpreadsheetProtection(vSpreadsheet);
//КонецПроцедуры //pmPrintSettlementHotelProducts
//
////-----------------------------------------------------------------------------
//Процедура pmPrintSettlement7G(vSpreadsheet, SelLanguage, SelGroupBy, SelObjectPrintForm, pPageBreak = False) Экспорт
//	// Basic checks
//	vHotel = Гостиница;
//	If НЕ ЗначениеЗаполнено(vHotel) Тогда
//		Message("Не задана гостиница!", MessageStatus.Attention);
//		Return;
//	EndIf;
//	vCompany = Фирма;
//	If НЕ ЗначениеЗаполнено(vCompany) Тогда
//		Message("Не задана фирма!", MessageStatus.Attention);
//		Return;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(SelLanguage) Тогда
//		SelLanguage = ПараметрыСеанса.ТекЛокализация;
//	EndIf;
//	
//	// Fill and check grouping parameter
//	vParameter = Upper(TrimAll(SelObjectPrintForm.Parameter));
//	
//	// Choose template
//	vSettlObj = ThisObject;
//	If pPageBreak Тогда
//		vSpreadsheet.PutHorizontalPageBreak();
//	Else
//		vSpreadsheet.Clear();
//	EndIf;
//	If ЗначениеЗаполнено(SelLanguage) Тогда
//		If SelLanguage = Справочники.Локализация.EN Тогда
//			vTemplate = vSettlObj.GetTemplate("Settlement7GEn");
//		ElsIf SelLanguage = Справочники.Локализация.RU Тогда
//			vTemplate = vSettlObj.GetTemplate("Settlement7GRu");
//		Else
//			Message("Не найден шаблон печатной формы акта для языка " + SelLanguage.Code + "!"  , MessageStatus.Attention);
//			Return;
//		EndIf;
//	Else
//		vTemplate = vSettlObj.GetTemplate("Settlement7GRu");
//	EndIf;
//	// Load external template if any
//	vExtTemplate = cmReadExternalSpreadsheetDocumentTemplate(SelObjectPrintForm);
//	If vExtTemplate <> Неопределено Тогда
//		vTemplate = vExtTemplate;
//	EndIf;
//	
//	// Load managers Подпись
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
//	
//	// Basic initialization
//	vBegOfMonth = BegOfMonth(Date);
//	vEndOfMonth = BegOfDay(EndOfMonth(Date)) + 24*3600;
//	
//	// Header
//	// 3G, 9G, 12G Headers
//	vHeader = vTemplate.GetArea("Header");
//	If SelLanguage = Справочники.Локализация.RU Тогда
//		If vHotel.PrintGHeaders Тогда
//			vHeader = vTemplate.GetArea("GHeader");
//		EndIf;
//	EndIf;
//	// Фирма
//	vCompanyObj = vCompany.GetObject();
//	vCompanyLegacyName = vCompanyObj.pmGetCompanyPrintName(SelLanguage);
//	vCompanyLegacyAddress = vCompanyObj.pmGetCompanyLegacyAddressPresentation(SelLanguage);
//	vCompanyTIN = TrimAll(vCompany.ИНН);
//	vCompanyKPP = TrimAll(vCompany.KPP);
//	// Контрагент
//	vCustomer = AccountingCustomer;
//	vCustomerLegacyName = "";
//	If ЗначениеЗаполнено(vCustomer) Тогда
//		vCustomerLegacyName = TrimAll(vCustomer.ЮрИмя);
//		If IsBlankString(vCustomerLegacyName) Тогда
//			vCustomerLegacyName = TrimAll(vCustomer.Description);
//		EndIf;
//	EndIf;
//	// Guest group
//	vGuestGroup = GuestGroup;
//	vGuestGroupCode = "";
//	vGuestGroupDescription = "";
//	vGuestGroupDate = "";
//	If ЗначениеЗаполнено(vGuestGroup) Тогда
//		vGuestGroupCode = TrimAll(vGuestGroup.Code);
//		If ЗначениеЗаполнено(Гостиница) Тогда
//			vHotelPrefix = Гостиница.GetObject().pmGetPrefix();
//			If НЕ IsBlankString(vHotelPrefix) And Гостиница.ShowHotelPrefixBeforeGroupCode Тогда
//				vGuestGroupCode = vHotelPrefix + vGuestGroupCode;
//			EndIf;
//		EndIf;
//		vGuestGroupDescription = TrimAll(vGuestGroup.Description);
//		// Retrieve guest group date
//		vGuestGroupObj = vGuestGroup.GetObject();
//		vReservations = vGuestGroupObj.pmGetReservations();
//		For Each vReservationsRow In vReservations Do
//			vGuestGroupDate = vReservationsRow.Reservation.ДатаДок;
//			Break;
//		EndDo;
//	EndIf;
//	// Currency
//	vAccountingCurrency = "";
//	If ЗначениеЗаполнено(AccountingCurrency) Тогда
//		vCurrencyObj = AccountingCurrency.GetObject();
//		vAccountingCurrency = vCurrencyObj.pmGetCurrencyDescription(SelLanguage);
//	EndIf;
//	// Set parameters and put report section
//	vHeader.Parameters.mCompanyLegacyName = vCompanyLegacyName;
//	vHeader.Parameters.mCompanyLegacyAddress = vCompanyLegacyAddress;
//	vHeader.Parameters.mCompanyTIN = vCompanyTIN;
//	vHeader.Parameters.mCompanyKPP = vCompanyKPP;
//	vHeader.Parameters.mGuestGroupCode = vGuestGroupCode;
//	vHeader.Parameters.mGuestGroupDescription = vGuestGroupDescription;
//	vHeader.Parameters.mGuestGroupDate = Format(vGuestGroupDate, "DF=dd.MM.yyyy");
//	vHeader.Parameters.mCustomerLegacyName = vCustomerLegacyName;
//	vHeader.Parameters.mAccountingCurrency = vAccountingCurrency;
//	// Print header
//	vSpreadsheet.Put(vHeader);
//	
//	// Get template areas
//	vClient = vTemplate.GetArea("Клиент");
//	vClientTotal = vTemplate.GetArea("ClientTotal");
//	vService = vTemplate.GetArea("Услуга");
//	vRoomRevenueService = vTemplate.GetArea("RoomRevenueService");
//	
//	// Get all services
//	vServices = Services.Unload();
//	
//	// Change accounting dates for breakfast
//	If НЕ IsBlankString(SelGroupBy) And SelGroupBy <> "ByService" Тогда
//		For Each vSrvRow In vServices Do
//			If vSrvRow.IsInPrice And ЗначениеЗаполнено(vSrvRow.Service.QuantityCalculationRule) And
//			   vSrvRow.Service.QuantityCalculationRule.QuantityCalculationRuleType = Перечисления.QuantityCalculationRuleTypes.Breakfast Тогда
//				If ЗначениеЗаполнено(vSrvRow.ЛицевойСчет) And BegOfDay(vSrvRow.AccountingDate) > BegOfDay(vSrvRow.ЛицевойСчет.DateTimeFrom) Тогда
//					vSrvRow.AccountingDate = vSrvRow.AccountingDate - 24*3600;
//				EndIf;
//			EndIf;
//		EndDo;
//	EndIf;
//	
//	// Join services according to service parameters
//	If НЕ IsBlankString(SelGroupBy) And SelGroupBy <> "ByService" Тогда
//		i = 0;
//		While i < vServices.Count() Do
//			vSrvRow = vServices.Get(i);
//			If НЕ vSrvRow.IsInPrice And ЗначениеЗаполнено(vSrvRow.Услуга.HideIntoServiceOnPrint) Тогда
//				// Try to find service to hide current one to
//				vHideToServices = vServices.FindRows(New Structure("Услуга, УчетнаяДата, СчетПроживания", vSrvRow.Услуга.HideIntoServiceOnPrint, vSrvRow.УчетнаяДата, vSrvRow.СчетПроживания));
//				If vHideToServices.Count() = 1 Тогда
//					vSrv2Hide2 = vHideToServices.Get(0);
//					vSrv2Hide2.Сумма = vSrv2Hide2.Сумма + vSrvRow.Сумма;
//					vSrv2Hide2.СуммаНДС = vSrv2Hide2.СуммаНДС + vSrvRow.СуммаНДС;
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
//	// Search for min/max accounting dates
//	vAllServicesAreInOneMonth = True;
//	vMinMaxServices = vServices.Copy();
//	vMinMaxServices.Sort("УчетнаяДата");
//	If vMinMaxServices.Count() > 0 Тогда
//		vFirstRow = vMinMaxServices.Get(0);
//		vLastRow = vMinMaxServices.Get(vMinMaxServices.Count() - 1);
//		If vFirstRow.УчетнаяДата < vBegOfMonth Or vLastRow.УчетнаяДата > (vEndOfMonth - 1) Тогда
//			vAllServicesAreInOneMonth = False;
//		EndIf;
//	EndIf;
//	
//	// Get accommodation service name
//	vRoomRevenueServices = vServices.Copy();
//	vAccommodationService = Неопределено;	
//	vAccommodationRemarks = "";	
//	vAccommodationServiceVATRate = Неопределено;
//	i = 0;
//	While i < vServices.Count() Do
//		vSrvRow = vServices.Get(i);
//		If SelGroupBy = "InPricePerFolioPerDay" Or SelGroupBy = "InPricePerDay" Or
//		   SelGroupBy = "AllPerFolioPerDay" Or SelGroupBy = "AllPerDay" Or
//		   SelGroupBy = "InPricePerFolio" Or SelGroupBy = "InPrice" Or
//		   SelGroupBy = "AllPerFolio" Or SelGroupBy = "All" Тогда
//			If Find(vParameter, "SHOWZEROES") = 0 Тогда
//				If vSrvRow.Сумма = 0 Тогда
//					vServices.Delete(i);
//					Continue;
//				EndIf;
//			EndIf;
//		EndIf;
//		If vSrvRow.IsRoomRevenue And НЕ vSrvRow.Услуга.RoomRevenueAmountsOnly Тогда
//			If НЕ ЗначениеЗаполнено(vAccommodationService) Тогда 
//				vAccommodationService = vSrvRow.Услуга;
//				vAccommodationServiceVATRate = vSrvRow.СтавкаНДС;
//				vAccommodationRemarks = TrimAll(vSrvRow.Примечания);
//				If SelGroupBy = "InPricePerFolio" Or SelGroupBy = "AllPerFolio" Тогда
//					If ЗначениеЗаполнено(vAccommodationService) Тогда
//						vSrvDescr = vAccommodationService.GetObject().pmGetServiceDescription(SelLanguage, False);
//						vSrvGrpDescr = vAccommodationService.GetObject().pmGetServiceDescription(SelLanguage, True);
//						vAccommodationRemarks = StrReplace(vAccommodationRemarks, vSrvDescr, vSrvGrpDescr);
//					EndIf;
//				EndIf;
//			EndIf;
//		EndIf;
//		i = i + 1;
//	EndDo;
//	
//	// Group by services according to the settlement print type
//	If НЕ IsBlankString(SelGroupBy) Тогда
//		If SelGroupBy = "ByServicePerFolio" Тогда
//			For Each vSrvRow In vServices Do
//				vSrvRow.AccountingDate = BegOfDay(Date);
//			EndDo;
//		ElsIf SelGroupBy = "InPricePerFolio" Тогда
//			For Each vSrvRow In vServices Do
//				// Reset "is in price" flag if necessary
//				If ЗначениеЗаполнено(vSrvRow.Service) And vSrvRow.Service.DoNotGroupIntoRoomRateOnPrint Тогда
//					vSrvRow.IsInPrice = False;
//				EndIf;
//				vSrvRow.AccountingDate = BegOfDay(Date);
//				If ЗначениеЗаполнено(vAccommodationService) And vAccommodationServiceVATRate = vSrvRow.VATRate Тогда
//					If НЕ vSrvRow.IsRoomRevenue And vSrvRow.IsInPrice Тогда
//						vSrvRow.Service = vAccommodationService;
//						vSrvRow.Remarks = vAccommodationRemarks;
//						vSrvRow.Quantity = 0;
//						vSrvRow.Price = 0;
//					ElsIf vSrvRow.IsRoomRevenue Тогда
//						If vSrvRow.IsInPrice Тогда
//							If vSrvRow.Service.RoomRevenueAmountsOnly Тогда
//								vSrvRow.Quantity = 0;
//								vSrvRow.Price = 0;
//							EndIf;
//							vSrvRow.Service = vAccommodationService;
//							vSrvRow.Remarks = vAccommodationRemarks;
//						EndIf;
//					EndIf;
//				EndIf;
//			EndDo;
//		ElsIf SelGroupBy = "AllPerFolio" Тогда
//			For Each vSrvRow In vServices Do
//				vSrvRow.AccountingDate = BegOfDay(Date);
//				vSrvRow.CalendarDayType = Справочники.ТипДневногоКалендаря.EmptyRef();
//				vSrvRow.ГруппаНомеров = Справочники.НомернойФонд.EmptyRef();
//				If ЗначениеЗаполнено(vAccommodationService) And vAccommodationServiceVATRate = vSrvRow.VATRate Тогда
//					If vSrvRow.Service.RoomRevenueAmountsOnly Тогда
//						vSrvRow.Quantity = 0;
//						vSrvRow.Price = 0;
//					EndIf;
//					vSrvRow.Service = vAccommodationService;
//					vSrvRow.Remarks = vAccommodationRemarks;
//					If НЕ vSrvRow.IsRoomRevenue Тогда
//						vSrvRow.Quantity = 0;
//						vSrvRow.Price = 0;
//					EndIf;
//				EndIf;
//			EndDo;
//		EndIf;
//		// Group by transactions
//		vServices.GroupBy("СчетПроживания, Услуга, ТипДеньКалендарь, НомерРазмещения, Примечания, СтавкаНДС", "Сумма, СуммаНДС, Цена, Количество");
//		// Recalculate price for all services
//		For Each vSrvRow In vServices Do
//			vSrvRow.VATSum = cmCalculateVATSum(vSrvRow.VATRate, vSrvRow.Sum);
//			vSrvRow.Price = cmRecalculatePrice(vSrvRow.Sum, vSrvRow.Quantity);
//		EndDo;
//	EndIf;
//	vServices.Sort("СчетПроживания");
//	
//	// Print services
//	vTotalSum = 0;
//	vTotalVATSum = 0;
//	vClientSum = 0;
//	vTotalNumberOfPersons = 0;
//	
//	vCurFolio = Documents.СчетПроживания.EmptyRef();
//	For Each vSrvRow In vServices Do
//		// Print folio header if necessary
//		If vSrvRow.ЛицевойСчет <> vCurFolio Тогда
//			// Print previous folio footer
//			If ЗначениеЗаполнено(vCurFolio) Тогда
//				vClientTotal.Parameters.mClientName = TrimAll(vCurFolio.Клиент);
//				vClientTotal.Parameters.mClientSum = Format(vClientSum, "ND=17; NFD=2");
//				// Put client total
//				vSpreadsheet.Put(vClientTotal);
//				// Count clients
//				vTotalNumberOfPersons = vTotalNumberOfPersons + 1;
//				// Reset client totals
//				vClientSum = 0;
//			EndIf;
//			// Change current folio
//			vCurFolio = vSrvRow.ЛицевойСчет;
//			// Fill client parameters
//			vClientName = TrimAll(vCurFolio.Клиент);
//			// Cut off dates by settlement month
//			vDateTimeFrom = vCurFolio.DateTimeFrom;
//			vDateTimeTo = vCurFolio.DateTimeTo;
//			If vAllServicesAreInOneMonth Тогда
//				If vDateTimeFrom < vBegOfMonth Тогда
//					vDateTimeFrom = vBegOfMonth;
//				EndIf;
//				If vDateTimeTo > vEndOfMonth Тогда
//					vDateTimeTo = vEndOfMonth;
//				EndIf;
//			EndIf;
//			vCheckInDate = Format(vDateTimeFrom, "DF='dd.MM.yy HH:mm'");
//			vCheckOutDate = Format(vDateTimeTo, "DF='dd.MM.yy HH:mm'");
//			vRoom = TrimAll(vCurFolio.НомерРазмещения);
//			vRoomType = "";
//			vRoomRate = "";
//			If ЗначениеЗаполнено(vCurFolio.ДокОснование) And TypeOf(vCurFolio.ДокОснование) = Type("DocumentRef.Размещение") Тогда
//				vRoomType = TrimAll(vCurFolio.ДокОснование.ТипНомера);
//				vRoomRate = TrimAll(vCurFolio.ДокОснование.Тариф);
//			EndIf;
//			// Set client parameters
//			vClient.Parameters.mRoomType = vRoomType;
//			vClient.Parameters.mRoomRate = vRoomRate;
//			vClient.Parameters.mClientName = vClientName;
//			vClient.Parameters.mCheckInDate = vCheckInDate;
//			vClient.Parameters.mCheckOutDate = vCheckOutDate;
//			vClient.Parameters.mRoom = vRoom;
//			// Put client
//			vSpreadsheet.Put(vClient);
//		EndIf;
//		// Fill row parameters
//		vServiceObj = vSrvRow.Service.GetObject();
//		vDescription = TrimAll(vSrvRow.Remarks);
//		vPrice = vSrvRow.Price;
//		vSum = vSrvRow.Sum;
//		vUnit = vServiceObj.pmGetServiceUnitDescription(SelLanguage);
//		vQuantity = "";
//		If vSrvRow.Quantity <> 0 Тогда
//			vQuantity = vServiceObj.pmGetServiceQuantityPresentation(vSrvRow.Quantity, SelLanguage);
//		EndIf;
//		// Totals
//		vTotalSum = vTotalSum + vSrvRow.Sum;
//		vClientSum = vClientSum + vSrvRow.Sum;
//		vTotalVATSum = vTotalVATSum + vSrvRow.VATSum;
//		// Set parameters
//		vService.Parameters.mDescription = vDescription;
//		vService.Parameters.mPrice = Format(vPrice, "ND=17; NFD=2");
//		vService.Parameters.mUnit = vUnit;
//		vService.Parameters.mQuantity = vQuantity;
//		vService.Parameters.mSum = Format(vSum, "ND=17; NFD=2");
//		// Put row
//		If vSum <> 0 Тогда
//			vSpreadsheet.Put(vService);
//		EndIf;
//	EndDo;
//	// Print previous folio footer
//	If ЗначениеЗаполнено(vCurFolio) Тогда
//		vClientTotal.Parameters.mClientName = TrimAll(vCurFolio.Клиент);
//		vClientTotal.Parameters.mClientSum = Format(vClientSum, "ND=17; NFD=2");
//		// Put client total
//		vSpreadsheet.Put(vClientTotal);
//		// Count clients
//		vTotalNumberOfPersons = vTotalNumberOfPersons + 1;
//	EndIf;
//	
//	// Footer
//	vFooter = vTemplate.GetArea("Footer");
//	// Fill parameters
//	mTotalSum = Format(vTotalSum, "ND=17; NFD=2");
//	mVATHeader = "";
//	If ЗначениеЗаполнено(vCompany) And vCompany.DoNotPrintVAT Тогда
//		mTotalVATSum = "";
//		mTotalVATSumInWords = "";
//	Else
//		If vTotalVATSum <> 0 Тогда
//			mVATHeader = ("В том числе НДС 18%");
//			mTotalVATSum = Format(vTotalVATSum, "ND=17; NFD=2");
//		Else
//			mVATHeader = "НДС не облагается";
//			mTotalVATSum = Format(vTotalVATSum, "ND=17; NFD=2");
//		EndIf;
//		mTotalVATSumInWords = " в т.ч. НДС на сумму: " + cmSumInWords(vTotalVATSum, AccountingCurrency, SelLanguage);
//	EndIf;
//	mTotalSumInWords = cmSumInWords(vTotalSum, AccountingCurrency, SelLanguage);
//	// Set parameters
//	vFooter.Parameters.mGuestGroupCode = vGuestGroupCode;
//	vFooter.Parameters.mTotalSum = mTotalSum;
//	vFooter.Parameters.mTotalVATSum = mTotalVATSum;
//	vFooter.Parameters.mVATHeader = mVATHeader;
//	vFooter.Parameters.mTotalSumInWords = mTotalSumInWords;
//	vFooter.Parameters.mTotalVATSumInWords = mTotalVATSumInWords;
//	// Put footer
//	vSpreadsheet.Put(vFooter);
//	
//	// Print ГруппаНомеров revenue services
//	For Each vSrvRow In vRoomRevenueServices Do
//		If vSrvRow.IsRoomRevenue Тогда
//			vSrvRow.Service = vAccommodationService;
//		ElsIf vSrvRow.IsInPrice Тогда
//			vSrvRow.Service = vAccommodationService;
//			vSrvRow.IsRoomRevenue = True;
//			vSrvRow.Quantity = 0;
//		EndIf;
//	EndDo;
//	vRoomRevenueServices.GroupBy("Услуга, IsRoomRevenue, СтавкаНДС", "Количество, Сумма");
//	For Each vSrvRow In vRoomRevenueServices Do
//		If НЕ ЗначениеЗаполнено(vSrvRow.Service) Тогда
//			Continue;
//		EndIf;
//		If НЕ vSrvRow.IsRoomRevenue Тогда
//			Continue;
//		EndIf;
//		If vSrvRow.Sum = 0 Тогда
//			Continue;
//		EndIf;
//		vServiceObj = vSrvRow.Service.GetObject();
//		mRoomRevenueService = vServiceObj.pmGetServiceDescription(SelLanguage, True) + " " + 
//		                      Format(Round(vSrvRow.Quantity, 3)) + " " + vServiceObj.pmGetServiceUnitDescription(SelLanguage) + 
//							  " на сумму " + Format(vSrvRow.Sum, "ND=17; NFD=2");
//		vRoomRevenueService.Parameters.mRoomRevenueService = mRoomRevenueService;
//		// Put ГруппаНомеров revenue service
//		vSpreadsheet.Put(vRoomRevenueService);
//	EndDo;
//	
//	// Signatures
//	vSignatures = vTemplate.GetArea("Signatures");
//	vEmployeeName = TrimAll(ПараметрыСеанса.ТекПользователь);
//	vEmployeePosition ="Дежурный администратор";
//	If НЕ IsBlankString(ПараметрыСеанса.ТекПользователь.Должность) Тогда
//		vEmployeePosition = TrimAll(ПараметрыСеанса.ТекПользователь.Должность);
//	EndIf;
//	vSignatures.Parameters.mEmployeePosition = vEmployeePosition;
//	vSignatures.Parameters.mEmployeeName = vEmployeeName;
//	vSignatures.Parameters.mTotalNumberOfPersons = Format(vTotalNumberOfPersons, "ND=8; NFD=0; NZ=; NG=");
//	// Manager's Подпись
//	If PrintWithCompanyStamp Тогда
//		If vSignatureIsSet Тогда
//			vSignatures.Drawings.Подпись.Print = True;
//			vSignatures.Drawings.Подпись.Picture = vSignature;
//		Else
//			vSignatures.Drawings.Delete(vSignatures.Drawings.Подпись);
//		EndIf;
//	Else
//		vSignatures.Drawings.Delete(vSignatures.Drawings.Подпись);
//	EndIf;
//	vSpreadsheet.Put(vSignatures);
//
//	// Setup default attributes
//	cmSetDefaultPrintFormSettings(vSpreadsheet, PageOrientation.Landscape, True, , True);
//	// Check authorities
//	cmSetSpreadsheetProtection(vSpreadsheet);
//КонецПроцедуры //pmPrintSettlement7G
//
////-----------------------------------------------------------------------------
//Процедура pmPrintVATInvoice(vSpreadsheet, SelLanguage, SelGroupBy, SelObjectPrintForm, SelServiceGroup, pPageBreak = False) Экспорт
//	// Basic checks
//	vCompany = Фирма;
//	If НЕ ЗначениеЗаполнено(vCompany) Тогда
//		Message("'Не задана фирма!", MessageStatus.Attention);
//		Return;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(SelLanguage) Тогда
//		SelLanguage = ПараметрыСеанса.ТекЛокализация;
//	EndIf;
//	
//	// Get spreadsheet
//	If pPageBreak Тогда
//		vSpreadsheet.PutHorizontalPageBreak();
//	Else
//		vSpreadsheet.Clear();
//	EndIf;
//	// Setup default attributes
//	cmSetDefaultPrintFormSettings(vSpreadsheet, PageOrientation.Landscape, True, 2, True);
//	
//	// Choose template
//	vSettlObj = ThisObject;
//	vTemplate = vSettlObj.GetTemplate("VATInvoice");
//	// Load external template if any
//	vExtTemplate = cmReadExternalSpreadsheetDocumentTemplate(SelObjectPrintForm);
//	If vExtTemplate <> Неопределено Тогда
//		vTemplate = vExtTemplate;
//	EndIf;
//	
//	// Load pictures
//	vDirectorSignatureIsSet = False;
//	vDirectorSignature = New Picture;
//	If Фирма.DirectorSignature <> Неопределено Тогда
//		vDirectorSignature = Фирма.DirectorSignature.Get();
//		If vDirectorSignature = Неопределено Тогда
//			vDirectorSignature = New Picture;
//		Else
//			vDirectorSignatureIsSet = True;
//		EndIf;
//	EndIf;
//	vAccountantGeneralSignatureIsSet = False;
//	vAccountantGeneralSignature = New Picture;
//	If Фирма.AccountantGeneralSignature <> Неопределено Тогда
//		vAccountantGeneralSignature = Фирма.AccountantGeneralSignature.Get();
//		If vAccountantGeneralSignature = Неопределено Тогда
//			vAccountantGeneralSignature = New Picture;
//		Else
//			vAccountantGeneralSignatureIsSet = True;
//		EndIf;
//	EndIf;
//	
//	// Header
//	vHeader = vTemplate.GetArea("Header");
//	vTableHeader = vTemplate.GetArea("TableHeader");
//	// VAT invoice date and number
//	mInvoiceNumber = TrimAll(InvoiceNumber);
//	mInvoiceDate = cmGetDocumentDatePresentation(Date);
//	// Фирма
//	vCompanyObj = vCompany.GetObject();
//	If ЗначениеЗаполнено(vCompany.ParentCompany) Тогда
//		vCompanyObj = vCompany.ParentCompany.GetObject();
//	EndIf;
//	mCompanyLegacyName = vCompanyObj.pmGetCompanyPrintName(SelLanguage);
//	mCompanyLegacyAddress = vCompanyObj.pmGetCompanyLegacyAddressPresentation(SelLanguage);
//	vCompanyTIN = TrimAll(vCompanyObj.ИНН);
//	vCompanyKPP = TrimAll(vCompanyObj.KPP);
//	mCompanyTIN = vCompanyTIN + ?(IsBlankString(vCompanyKPP), "", "/" + vCompanyKPP);
//	// Контрагент
//	vCustomer = AccountingCustomer;
//	mCustomerLegacyName = "";
//	mCustomerLegacyAddress = "";
//	mCustomerTIN = "";
//	If ЗначениеЗаполнено(vCustomer) Тогда
//		mCustomerLegacyName = ?(ЗначениеЗаполнено(vCustomer.ParentOrganization), TrimAll(vCustomer.ParentOrganization.ЮрИмя), TrimAll(vCustomer.ЮрИмя));
//		mCustomerLegacyAddress = ?(ЗначениеЗаполнено(vCustomer.ParentOrganization), cmGetAddressPresentation(vCustomer.ParentOrganization.LegacyAddress), cmGetAddressPresentation(vCustomer.LegacyAddress));
//		vCustomerTIN = ?(ЗначениеЗаполнено(vCustomer.ParentOrganization), TrimAll(vCustomer.ParentOrganization.ИНН), TrimAll(vCustomer.ИНН));
//		vCustomerKPP = ?(ЗначениеЗаполнено(vCustomer.ParentOrganization), TrimAll(vCustomer.ParentOrganization.KPP), TrimAll(vCustomer.KPP));
//		mCustomerTIN = vCustomerTIN + ?(IsBlankString(vCustomerKPP), "", "/" + vCustomerKPP);
//	EndIf;
//	// Consignor and consignee
//	mConsignor = "----";
//	mConsignee = "----";
//	If НЕ vCompany.UseDashForConsignorConsignee Тогда
//		If vCompany.UseIdemForConsignor Тогда
//			mConsignor = "он же";
//		Else
//			vCompanyObj = vCompany.GetObject();
//			mConsignor = vCompanyObj.pmGetCompanyPrintName(SelLanguage) + ?(IsBlankString(vCompany.LegacyAddress), "", ", " + vCompanyObj.pmGetCompanyLegacyAddressPresentation(SelLanguage));
//		EndIf;
//		mConsignee = TrimAll(vCustomer.ЮрИмя) + ?(IsBlankString(vCustomer.LegacyAddress), "", ", " + cmGetAddressPresentation(vCustomer.LegacyAddress));
//	EndIf;
//	If НЕ IsBlankString(Consignor) Тогда
//		mConsignor = TrimR(Consignor);
//	EndIf;
//	If НЕ IsBlankString(Consignee) Тогда
//		mConsignee = TrimR(Consignee);
//	EndIf;
//	// Currency
//	mAccountingCurrency = "";
//	If ЗначениеЗаполнено(AccountingCurrency) Тогда
//		mAccountingCurrency = TrimAll(AccountingCurrency.Code) + ", " + ?(IsBlankString(AccountingCurrency.Remarks), TrimAll(AccountingCurrency.Description), TrimAll(AccountingCurrency.Remarks));
//	EndIf;
//	// Payment and account document
//	mPaymentDocuments = "";
//	If PaymentDocuments.Count() > 0 Тогда
//		For Each vRow In PaymentDocuments Do
//			If vRow.LineNumber > 1 Тогда
//				mPaymentDocuments = mPaymentDocuments + ", ";
//			EndIf;
//			mPaymentDocuments = mPaymentDocuments + ?(IsBlankString(vRow.PaymentDocNumber), "_______________", TrimAll(vRow.PaymentDocNumber)) + 
//			                    " от " + ?(ЗначениеЗаполнено(vRow.PaymentDocDate), Format(vRow.PaymentDocDate, "DF=dd.MM.yyyy"), "_______________");
//		EndDo;
//	Else
//		mPaymentDocuments = "_______________ от _______________";
//	EndIf;
//	// Set parameters
//	vHeader.Parameters.mInvoiceNumber = mInvoiceNumber;
//	vHeader.Parameters.mInvoiceDate = mInvoiceDate;
//	vHeader.Parameters.mCompanyLegacyName = mCompanyLegacyName;
//	vHeader.Parameters.mCompanyLegacyAddress = mCompanyLegacyAddress;
//	vHeader.Parameters.mCompanyTIN = mCompanyTIN;
//	vHeader.Parameters.mCustomerLegacyName = mCustomerLegacyName;
//	vHeader.Parameters.mCustomerLegacyAddress = mCustomerLegacyAddress;
//	vHeader.Parameters.mCustomerTIN = mCustomerTIN;
//	vHeader.Parameters.mConsignor = mConsignor;
//	vHeader.Parameters.mConsignee = mConsignee;
//	vHeader.Parameters.mAccountingCurrency = mAccountingCurrency;
//	vHeader.Parameters.mPaymentDocuments = mPaymentDocuments;
//	vSpreadsheet.Put(vHeader);
//	vSpreadsheet.Put(vTableHeader);
//	
//	// Get row template area
//	vRow = vTemplate.GetArea("Row");
//	
//	// Get all services
//	vServices = Services.Unload();
//	
//	// Change accounting dates for breakfast
//	If НЕ IsBlankString(SelGroupBy) And SelGroupBy <> "ByService" Тогда
//		For Each vSrvRow In vServices Do
//			If vSrvRow.IsInPrice And ЗначениеЗаполнено(vSrvRow.Service.QuantityCalculationRule) And
//			   vSrvRow.Service.QuantityCalculationRule.QuantityCalculationRuleType = Перечисления.QuantityCalculationRuleTypes.Breakfast Тогда
//				If ЗначениеЗаполнено(vSrvRow.ЛицевойСчет) And BegOfDay(vSrvRow.AccountingDate) > BegOfDay(vSrvRow.ЛицевойСчет.DateTimeFrom) Тогда
//					vSrvRow.AccountingDate = vSrvRow.AccountingDate - 24*3600;
//				EndIf;
//			EndIf;
//		EndDo;
//	EndIf;
//	
//	// Join services according to service parameters
//	If НЕ IsBlankString(SelGroupBy) And SelGroupBy <> "ByService" Тогда
//		i = 0;
//		While i < vServices.Count() Do
//			vSrvRow = vServices.Get(i);
//			If НЕ vSrvRow.IsInPrice And ЗначениеЗаполнено(vSrvRow.Услуга.HideIntoServiceOnPrint) Тогда
//				// Try to find service to hide current one to
//				vHideToServices = vServices.FindRows(New Structure("Услуга, УчетнаяДата, СчетПроживания", vSrvRow.Услуга.HideIntoServiceOnPrint, vSrvRow.УчетнаяДата, vSrvRow.СчетПроживания));
//				If vHideToServices.Count() = 1 Тогда
//					vSrv2Hide2 = vHideToServices.Get(0);
//					vSrv2Hide2.Сумма = vSrv2Hide2.Сумма + vSrvRow.Сумма;
//					vSrv2Hide2.СуммаНДС = vSrv2Hide2.СуммаНДС + vSrvRow.СуммаНДС;
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
//	// Delete services not in service group choosen
//	If ЗначениеЗаполнено(SelServiceGroup) Тогда
//		i = 0;
//		While i < vServices.Count() Do
//			vSrvRow = vServices.Get(i);
//			If НЕ cmIsServiceInServiceGroup( vSrvRow.Услуга, SelServiceGroup) Тогда
//				vServices.Delete(i);
//			Else
//				i = i + 1;
//			EndIf;
//		EndDo;
//	EndIf;
//	
//	// Get accommodation service name
//	vAccommodationService = Неопределено;
//	vAccommodationRemarks = "";	
//	vAccommodationUnit = "";	
//	vAccommodationServiceVATRate = Неопределено;
//	i = 0;
//	While i < vServices.Count() Do
//		vSrvRow = vServices.Get(i);
//		If SelGroupBy = "InPricePerFolioPerDay" Or SelGroupBy = "InPricePerDay" Or
//		   SelGroupBy = "AllPerFolioPerDay" Or SelGroupBy = "AllPerDay" Or
//		   SelGroupBy = "InPricePerFolio" Or SelGroupBy = "InPrice" Or
//		   SelGroupBy = "AllPerFolio" Or SelGroupBy = "All" Тогда
//			If vSrvRow.Сумма = 0 Тогда
//				vServices.Delete(i);
//				Continue;
//			EndIf;
//		EndIf;
//		If vAccommodationService = Неопределено And vSrvRow.IsRoomRevenue And НЕ vSrvRow.Услуга.RoomRevenueAmountsOnly Тогда
//			vAccommodationService = vSrvRow.Услуга;
//			vAccommodationServiceVATRate = vSrvRow.СтавкаНДС;
//			vAccommodationRemarks = TrimAll(vSrvRow.Примечания);
//			If SelGroupBy = "InPricePerFolioPerDay" Or SelGroupBy = "InPricePerDay" Or
//			   SelGroupBy = "AllPerFolioPerDay" Or SelGroupBy = "AllPerDay" Or
//			   SelGroupBy = "InPricePerFolio" Or SelGroupBy = "InPrice" Or
//			   SelGroupBy = "AllPerFolio" Or SelGroupBy = "All" Тогда
//				If ЗначениеЗаполнено(vAccommodationService) Тогда
//					vSrvDescr = vAccommodationService.GetObject().pmGetServiceDescription(SelLanguage, False);
//					vSrvGrpDescr = vAccommodationService.GetObject().pmGetServiceDescription(SelLanguage, True);
//					vAccommodationRemarks = StrReplace(vAccommodationRemarks, vSrvDescr, vSrvGrpDescr);
//					vAccommodationUnit = vAccommodationService.GetObject().pmGetServiceUnitDescription(SelLanguage);
//				EndIf;
//			EndIf;
//		EndIf;
//		i = i + 1;
//	EndDo;
//	
//	// Group by services according to the VAT invoice print type
//	If НЕ IsBlankString(SelGroupBy) Тогда
//		If SelGroupBy = "InPricePerFolioPerDay" Or SelGroupBy = "InPricePerDay" Тогда
//			For Each vSrvRow In vServices Do
//				// Reset "is in price" flag if necessary
//				If ЗначениеЗаполнено(vSrvRow.Service) And vSrvRow.Service.DoNotGroupIntoRoomRateOnPrint Тогда
//					vSrvRow.IsInPrice = False;
//				EndIf;
//				vSrvRow.AccountingDate = BegOfDay(vSrvRow.AccountingDate);
//				vSrvRow.CalendarDayType = Справочники.ТипДневногоКалендаря.EmptyRef();
//				vSrvRow.ГруппаНомеров = Справочники.НомернойФонд.EmptyRef();
//				If SelGroupBy = "InPricePerDay" Тогда
//					vSrvRow.ЛицевойСчет = Documents.СчетПроживания.EmptyRef();
//				EndIf;
//				If ЗначениеЗаполнено(vAccommodationService) And vAccommodationServiceVATRate = vSrvRow.VATRate Тогда
//					If НЕ vSrvRow.IsRoomRevenue And vSrvRow.IsInPrice Тогда
//						vSrvRow.Remarks = ?(IsBlankString(vAccommodationRemarks), TrimAll(vSrvRow.Remarks), vAccommodationRemarks);
//						vSrvRow.Quantity = ?(IsBlankString(vAccommodationRemarks), vSrvRow.Quantity, 0);
//						vSrvRow.Unit = vAccommodationUnit;
//						vSrvRow.Price = 0;
//					ElsIf vSrvRow.IsRoomRevenue And vSrvRow.IsInPrice Тогда
//						If vSrvRow.Service.RoomRevenueAmountsOnly Тогда
//							vSrvRow.Quantity = 0;
//							vSrvRow.Price = 0;
//						EndIf;
//						vSrvRow.Remarks = ?(IsBlankString(vAccommodationRemarks), TrimAll(vSrvRow.Remarks), vAccommodationRemarks);
//						vSrvRow.Unit = vAccommodationUnit;
//					EndIf;
//				EndIf;
//			EndDo;
//		ElsIf SelGroupBy = "AllPerFolioPerDay" Or SelGroupBy = "AllPerDay" Тогда
//			// Change transaction services
//			For Each vSrvRow In vServices Do
//				vSrvRow.AccountingDate = BegOfDay(vSrvRow.AccountingDate);
//				vSrvRow.CalendarDayType = Справочники.ТипДневногоКалендаря.EmptyRef();
//				vSrvRow.ГруппаНомеров = Справочники.НомернойФонд.EmptyRef();
//				If SelGroupBy = "AllPerDay" Тогда
//					vSrvRow.ЛицевойСчет = Documents.СчетПроживания.EmptyRef();
//				EndIf;
//				If ЗначениеЗаполнено(vAccommodationService) And vAccommodationServiceVATRate = vSrvRow.VATRate Тогда
//					If vSrvRow.Service.RoomRevenueAmountsOnly Тогда
//						vSrvRow.Quantity = 0;
//						vSrvRow.Price = 0;
//					EndIf;
//					vSrvRow.Remarks = ?(IsBlankString(vAccommodationRemarks), TrimAll(vSrvRow.Remarks), vAccommodationRemarks);
//					vSrvRow.Unit = vAccommodationUnit;
//					If НЕ vSrvRow.IsRoomRevenue Тогда
//						vSrvRow.Quantity = ?(IsBlankString(vAccommodationRemarks), vSrvRow.Quantity, 0);
//						vSrvRow.Price = 0;
//					EndIf;
//				EndIf;
//			EndDo;
//		ElsIf SelGroupBy = "PerFolio" Тогда
//			For Each vSrvRow In vServices Do
//				vSrvRow.AccountingDate = BegOfDay(Date);
//			EndDo;
//		ElsIf SelGroupBy = "ByService" Тогда
//			// Change transaction services
//			For Each vSrvRow In vServices Do
//				vSrvRow.AccountingDate = BegOfDay(Date);
//				vSrvRow.ЛицевойСчет = Documents.СчетПроживания.EmptyRef();
//				vSrvRow.CalendarDayType = Справочники.ТипДневногоКалендаря.EmptyRef();
//				vSrvRow.ГруппаНомеров = Справочники.НомернойФонд.EmptyRef();
//			EndDo;
//		ElsIf SelGroupBy = "InPricePerFolio" Or SelGroupBy = "InPrice" Тогда
//			// Change transaction services
//			For Each vSrvRow In vServices Do
//				// Reset "is in price" flag if necessary
//				If ЗначениеЗаполнено(vSrvRow.Service) And vSrvRow.Service.DoNotGroupIntoRoomRateOnPrint Тогда
//					vSrvRow.IsInPrice = False;
//				EndIf;
//				vSrvRow.AccountingDate = BegOfDay(Date);
//				If SelGroupBy = "InPrice" Тогда
//					vSrvRow.ЛицевойСчет = Documents.СчетПроживания.EmptyRef();
//					vSrvRow.CalendarDayType = Справочники.ТипДневногоКалендаря.EmptyRef();
//					vSrvRow.ГруппаНомеров = Справочники.НомернойФонд.EmptyRef();
//				EndIf;
//				If ЗначениеЗаполнено(vAccommodationService) And vAccommodationServiceVATRate = vSrvRow.VATRate Тогда
//					If НЕ vSrvRow.IsRoomRevenue And vSrvRow.IsInPrice Тогда
//						vSrvRow.Remarks = ?(IsBlankString(vAccommodationRemarks), TrimAll(vSrvRow.Remarks), vAccommodationRemarks);
//						vSrvRow.Unit = vAccommodationUnit;
//						vSrvRow.Quantity = ?(IsBlankString(vAccommodationRemarks), vSrvRow.Quantity, 0);
//						vSrvRow.Price = 0;
//					ElsIf vSrvRow.IsRoomRevenue And vSrvRow.IsInPrice Тогда
//						If vSrvRow.Service.RoomRevenueAmountsOnly Тогда
//							vSrvRow.Quantity = 0;
//							vSrvRow.Price = 0;
//						EndIf;
//						vSrvRow.Remarks = ?(IsBlankString(vAccommodationRemarks), TrimAll(vSrvRow.Remarks), vAccommodationRemarks);
//						vSrvRow.Unit = vAccommodationUnit;
//					EndIf;
//				EndIf;
//			EndDo;
//		ElsIf SelGroupBy = "AllPerFolio" Or SelGroupBy = "All" Тогда
//			// Change transaction services
//			For Each vSrvRow In vServices Do
//				vSrvRow.AccountingDate = BegOfDay(Date);
//				vSrvRow.CalendarDayType = Справочники.ТипДневногоКалендаря.ПустаяСсылка();
//				vSrvRow.ГруппаНомеров = Справочники.НомернойФонд.Пустаяссылка();
//				If SelGroupBy = "All" Тогда
//					vSrvRow.ЛицевойСчет = Documents.СчетПроживания.EmptyRef();
//				EndIf;
//				If ЗначениеЗаполнено(vAccommodationService) And vAccommodationServiceVATRate = vSrvRow.VATRate Тогда
//					If vSrvRow.Service.RoomRevenueAmountsOnly Тогда
//						vSrvRow.Quantity = 0;
//						vSrvRow.Price = 0;
//					EndIf;
//					vSrvRow.Remarks = ?(IsBlankString(vAccommodationRemarks), TrimAll(vSrvRow.Remarks), vAccommodationRemarks);
//					vSrvRow.Unit = vAccommodationUnit;
//					If НЕ vSrvRow.IsRoomRevenue Тогда
//						vSrvRow.Quantity = ?(IsBlankString(vAccommodationRemarks), vSrvRow.Quantity, 0);
//						vSrvRow.Price = 0;
//					EndIf;
//				EndIf;
//			EndDo;
//		EndIf;
//		// Group by transactions
//		vServices.GroupBy("СчетПроживания, УчетнаяДата, ТипДневногоКалендаря, НомерРазмещения, Примечания, ЕдИзмерения, СтавкаНДС", "Сумма, СуммаНДС, Цена, Количество");
//	EndIf;
//	// Recalculate price for all services and delete zero sum rows
//	i = 0;
//	While i < vServices.Count() Do
//		vSrvRow = vServices.Get(i);
//		If vSrvRow.Сумма = 0 And SelGroupBy <> "ByService" And НЕ IsBlankString(SelGroupBy) Тогда
//			vServices.Delete(i);
//		Else
//			vSrvRow.СуммаНДС = cmCalculateVATSum(vSrvRow.СтавкаНДС, vSrvRow.Сумма);
//			vSrvRow.Цена = cmRecalculatePrice(vSrvRow.Сумма - vSrvRow.СуммаНДС, vSrvRow.Количество);
//			i = i + 1;
//		EndIf;
//	EndDo;
//	vServices.Sort("СчетПроживания, УчетнаяДата");
//	
//	// Calculate totals
//	vTotalSum = 0;
//	vTotalVATSum = 0;
//	vTotalSumWithoutVAT = 0;
//	For Each vSrvRow In vServices Do
//		vTotalSum = vTotalSum + vSrvRow.Sum;
//		vVATSum = cmCalculateVATSum(vSrvRow.VATRate, vSrvRow.Sum);
//		vTotalVATSum = vTotalVATSum + vVATSum;
//		vTotalSumWithoutVAT = vTotalSumWithoutVAT + vSrvRow.Sum - vVATSum;
//	EndDo;
//	
//	// Build footer
//	vFooterAreas = new Array();
//	vFooter = vTemplate.GetArea("Footer");
//	// Fill parameters
//	mTotalSum = ?(vTotalSum = 0, "-----", Format(vTotalSum, "ND=17; NFD=2"));
//	mTotalSumWithoutVAT = ?(vTotalSumWithoutVAT = 0, "-----", Format(vTotalSumWithoutVAT, "ND=17; NFD=2"));
//	mTotalVATSum = ?(vTotalVATSum = 0, "-----", Format(vTotalVATSum, "ND=17; NFD=2"));
//	mCompanyDirector = ?(ЗначениеЗаполнено(vCompany.ParentCompany), TrimAll(vCompany.ParentCompany.Director), TrimAll(vCompany.Director));
//	mCompanyAccountantGeneral = ?(ЗначениеЗаполнено(vCompany.ParentCompany), TrimAll(vCompany.ParentCompany.AccountantGeneral), TrimAll(vCompany.AccountantGeneral));
//	// Set parameters
//	vFooter.Parameters.mTotalSum = mTotalSum;
//	vFooter.Parameters.mTotalSumWithoutVAT = mTotalSumWithoutVAT;
//	vFooter.Parameters.mTotalVATSum = mTotalVATSum;
//	vFooter.Parameters.mCompanyDirector = mCompanyDirector;
//	vFooter.Parameters.mCompanyAccountantGeneral = mCompanyAccountantGeneral;
//	// Фирма stamp and signatures
//	If PrintWithCompanyStamp Тогда
//		If vDirectorSignatureIsSet Тогда
//			vFooter.Drawings.DirectorSignature.Print = True;
//			vFooter.Drawings.DirectorSignature.Picture = vDirectorSignature;
//		Else
//			vFooter.Drawings.Delete(vFooter.Drawings.DirectorSignature);
//		EndIf;
//		If vAccountantGeneralSignatureIsSet Тогда
//			vFooter.Drawings.AccountantGeneralSignature.Print = True;
//			vFooter.Drawings.AccountantGeneralSignature.Picture = vAccountantGeneralSignature;
//		Else
//			vFooter.Drawings.Delete(vFooter.Drawings.AccountantGeneralSignature);
//		EndIf;
//	Else
//		vFooter.Drawings.Delete(vFooter.Drawings.DirectorSignature);
//		vFooter.Drawings.Delete(vFooter.Drawings.AccountantGeneralSignature);
//	EndIf;
//	// Put footer
//	vFooterAreas.Add(vFooter);
//	
//	// Print services
//	vCurFolio = Documents.СчетПроживания.EmptyRef();
//	For Each vSrvRow In vServices Do
//		// Fill parameters
//		mDescription = "";
//		If SelGroupBy <> "InPrice" And SelGroupBy <> "InPricePerFolio" And SelGroupBy <> "All" And SelGroupBy <> "AllPerFolio" And SelGroupBy <> "PerFolio" And SelGroupBy <> "ByService" Тогда
//			mDescription = mDescription + Format(vSrvRow.AccountingDate, "DF=dd.MM.yy") + " ";
//		EndIf;
//		mDescription = mDescription + vSrvRow.Remarks;
//		// Print folio header if necessary
//		If vSrvRow.ЛицевойСчет <> vCurFolio Тогда
//			vCurFolio = vSrvRow.ЛицевойСчет;
//			// Fill folio parameters
//			mClient = "";
//			If ЗначениеЗаполнено(vCurFolio.Клиент) Тогда
//				mClient = TrimAll(TrimAll(vCurFolio.Клиент.Фамилия) + " " + TrimAll(vCurFolio.Клиент.Имя) + " " + TrimAll(vCurFolio.Клиент.Отчество));
//			ElsIf ЗначениеЗаполнено(vCurFolio.Контрагент) Тогда
//				If НЕ IsBlankString(vCurFolio.Контрагент.ЮрИмя) Тогда
//					mClient = TrimAll(vCurFolio.Контрагент.ЮрИмя);
//				Else
//					mClient = TrimAll(vCurFolio.Контрагент.Description);
//				EndIf;
//			EndIf;
//			vDateFrom = vCurFolio.DateTimeFrom;
//			vDateTo = vCurFolio.DateTimeTo;
//			cmGetServicesPeriodByFolio(vCurFolio, Ref, vDateFrom, vDateTo);
//			vRoom = "";
//			If ЗначениеЗаполнено(vCurFolio.НомерРазмещения) Тогда
//				vRoom = TrimAll(vCurFolio.НомерРазмещения.Description);
//			EndIf;
//			mClient = mClient + 
//			          ?(vCompany.OutputGuestPeriodInVATInvoice, ?(ЗначениеЗаполнено(vDateFrom), ", " + cmPeriodPresentation(vDateFrom, vDateTo), ""), "") + 
//			          ?(IsBlankString(vRoom), "" , ", " + vRoom);
//			// Set description
//			If НЕ IsBlankString(mClient) Тогда
//				mDescription = mDescription + " - " + mClient;
//			EndIf;
//		EndIf;
//		mUnit = vSrvRow.Unit;
//		mUnitCode = cmGetUnitCode(mUnit);
//		mQuantity = vSrvRow.Quantity;
//		mPrice = vSrvRow.Price;
//		vVATSum = cmCalculateVATSum(vSrvRow.VATRate, vSrvRow.Sum);
//		mSumWithoutVAT = vSrvRow.Sum - vVATSum;
//		mVATRate = vSrvRow.VATRate;
//		mVATSum = vVATSum;
//		mSum = vSrvRow.Sum;
//		// Set parameters
//		vRow.Parameters.mDescription = mDescription;
//		vRow.Parameters.mUnit = ?(IsBlankString(mUnit), "---", mUnit);
//		vRow.Parameters.mUnitCode = ?(IsBlankString(mUnitCode), "", mUnitCode);
//		vRow.Parameters.mQuantity = Format(mQuantity, "ND=10; NFD=3; NZ=");
//		vRow.Parameters.mPrice = Format(mPrice, "ND=17; NFD=2");
//		vRow.Parameters.mSumWithoutVAT = ?(mSumWithoutVAT = 0, "-----", Format(mSumWithoutVAT, "ND=17; NFD=2"));
//		vRow.Parameters.mVATRate = TrimAll(mVATRate);
//		vRow.Parameters.mVATSum = ?(mVATSum = 0, "-----", Format(mVATSum, "ND=17; NFD=2"));
//		vRow.Parameters.mSum = ?(mSum = 0, "-----", Format(mSum, "ND=17; NFD=2"));
//		// Check if we can print footer completely
//		If (vServices.IndexOf(vSrvRow) + 1) = vServices.Count() Тогда
//			vFooterAreas.Вставить(0, vRow);
//			If НЕ vSpreadsheet.CheckPut(vFooterAreas) Тогда
//				vSpreadsheet.PutHorizontalPageBreak();
//				vSpreadsheet.Put(vTableHeader);
//			EndIf;
//			vFooterAreas.Delete(0);
//		Else
//			If НЕ vSpreadsheet.CheckPut(vRow) Тогда
//				vSpreadsheet.PutHorizontalPageBreak();
//				vSpreadsheet.Put(vTableHeader);
//			EndIf;
//		EndIf;
//		// Put row
//		vSpreadsheet.Put(vRow);
//	EndDo;
//	
//	// Put footer areas
//	For Each vFooterArea In vFooterAreas Do
//		vSpreadsheet.Put(vFooterArea);
//	EndDo;
//
//	// Check authorities
//	cmSetSpreadsheetProtection(vSpreadsheet);
//КонецПроцедуры //pmPrintVATInvoice
