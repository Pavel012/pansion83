////-----------------------------------------------------------------------------
//Процедура PostToAccounts()
//	If PaymentSections.Count() > 0 Тогда
//		For Each vPSRow In PaymentSections Do
//			If vPSRow.SumInFolioFromCurrency = 0 Тогда
//				Continue;
//			EndIf;
//					
//			// Storno movement for folio from
//			Movement = RegisterRecords.Взаиморасчеты.Add();
//			
//			Movement.RecordType = AccumulationRecordType.Expense;
//			Movement.Period = Date;
//			
//			FillPropertyValues(Movement, FolioFrom);
//			If ЗначениеЗаполнено(ParentDoc) Тогда
//				FillPropertyValues(Movement, ParentDoc);
//			EndIf;
//			FillPropertyValues(Movement, ThisObject);
//			
//			// Dimensions
//			Movement.СчетПроживания = FolioFrom;
//			Movement.ВалютаЛицСчета = FolioFromCurrency;
//			
//			// Payment section
//			Movement.PaymentSection = vPSRow.PaymentSection;
//			
//			// Resources
//			Movement.Сумма = -vPSRow.SumInFolioFromCurrency;
//			If ЗначениеЗаполнено(Movement.PaymentSection) And ЗначениеЗаполнено(Movement.PaymentSection.СтавкаНДС) Тогда
//				Movement.СтавкаНДС = Movement.PaymentSection.СтавкаНДС;
//			ElsIf ЗначениеЗаполнено(FolioFrom.Фирма) And ЗначениеЗаполнено(FolioFrom.Фирма.VATRate) Тогда
//				Movement.СтавкаНДС = FolioFrom.Фирма.VATRate;
//			EndIf;
//			Movement.СуммаНДС = 0;
//			If ЗначениеЗаполнено(Movement.СтавкаНДС) Тогда
//				Movement.СуммаНДС = cmCalculateVATSum(Movement.СтавкаНДС, Movement.Сумма);
//			EndIf;
//			
//			// Expense movement for folio to
//			Movement = RegisterRecords.Взаиморасчеты.Add();
//			
//			Movement.RecordType = AccumulationRecordType.Expense;
//			Movement.Period = Date;
//			
//			FillPropertyValues(Movement, FolioTo);
//			FillPropertyValues(Movement, ThisObject);
//			
//			// Dimensions
//			Movement.СчетПроживания = FolioTo;
//			Movement.ВалютаЛицСчета = FolioToCurrency;
//			
//			// Payment section
//			Movement.PaymentSection = ?(ЗначениеЗаполнено(PaymentSection), PaymentSection, vPSRow.PaymentSection);
//			
//			// Resources
//			Movement.Сумма = vPSRow.SumInFolioToCurrency;
//			If ЗначениеЗаполнено(Movement.PaymentSection) And ЗначениеЗаполнено(Movement.PaymentSection.СтавкаНДС) Тогда
//				Movement.СтавкаНДС = Movement.PaymentSection.СтавкаНДС;
//			ElsIf ЗначениеЗаполнено(FolioTo.Фирма) And ЗначениеЗаполнено(FolioTo.Фирма.VATRate) Тогда
//				Movement.СтавкаНДС = FolioTo.Фирма.VATRate;
//			EndIf;
//			Movement.СуммаНДС = 0;
//			If ЗначениеЗаполнено(Movement.СтавкаНДС) Тогда
//				Movement.СуммаНДС = cmCalculateVATSum(Movement.СтавкаНДС, Movement.Сумма);
//			EndIf;
//		EndDo;
//	Else
//		// Storno movement for folio from
//		Movement = RegisterRecords.Взаиморасчеты.Add();
//		
//		Movement.RecordType = AccumulationRecordType.Expense;
//		Movement.Period = Date;
//		
//		FillPropertyValues(Movement, FolioFrom);
//		If ЗначениеЗаполнено(ParentDoc) Тогда
//			FillPropertyValues(Movement, ParentDoc);
//		EndIf;
//		FillPropertyValues(Movement, ThisObject);
//		
//		// Dimensions
//		Movement.СчетПроживания = FolioFrom;
//		Movement.ВалютаЛицСчета = FolioFromCurrency;
//		
//		// Resources
//		Movement.Сумма = -SumInFolioFromCurrency;
//		If ЗначениеЗаполнено(Movement.PaymentSection) And ЗначениеЗаполнено(Movement.PaymentSection.СтавкаНДС) Тогда
//			Movement.СтавкаНДС = Movement.PaymentSection.СтавкаНДС;
//		ElsIf ЗначениеЗаполнено(FolioFrom.Фирма) And ЗначениеЗаполнено(FolioFrom.Фирма.VATRate) Тогда
//			Movement.СтавкаНДС = FolioFrom.Фирма.VATRate;
//		EndIf;
//		Movement.СуммаНДС = 0;
//		If ЗначениеЗаполнено(Movement.СтавкаНДС) Тогда
//			Movement.СуммаНДС = cmCalculateVATSum(Movement.СтавкаНДС, Movement.Сумма);
//		EndIf;
//		
//		// Payment section
//		If ЗначениеЗаполнено(Гостиница) And НЕ Гостиница.SplitFolioBalanceByPaymentSections Тогда
//			Movement.PaymentSection = Справочники.ОтделОплаты.EmptyRef();
//		EndIf;
//		
//		// Expense movement for folio to
//		Movement = RegisterRecords.Взаиморасчеты.Add();
//		
//		Movement.RecordType = AccumulationRecordType.Expense;
//		Movement.Period = Date;
//		
//		FillPropertyValues(Movement, FolioTo);
//		FillPropertyValues(Movement, ThisObject);
//		
//		// Dimensions
//		Movement.СчетПроживания = FolioTo;
//		Movement.ВалютаЛицСчета = FolioToCurrency;
//		
//		// Resources
//		Movement.Сумма = SumInFolioToCurrency;
//		If ЗначениеЗаполнено(Movement.PaymentSection) And ЗначениеЗаполнено(Movement.PaymentSection.СтавкаНДС) Тогда
//			Movement.СтавкаНДС = Movement.PaymentSection.СтавкаНДС;
//		ElsIf ЗначениеЗаполнено(FolioTo.Фирма) And ЗначениеЗаполнено(FolioTo.Фирма.VATRate) Тогда
//			Movement.СтавкаНДС = FolioTo.Фирма.VATRate;
//		EndIf;
//		Movement.СуммаНДС = 0;
//		If ЗначениеЗаполнено(Movement.СтавкаНДС) Тогда
//			Movement.СуммаНДС = cmCalculateVATSum(Movement.СтавкаНДС, Movement.Сумма);
//		EndIf;
//		
//		// Payment section
//		If ЗначениеЗаполнено(Гостиница) And НЕ Гостиница.SplitFolioBalanceByPaymentSections Тогда
//			Movement.PaymentSection = Справочники.ОтделОплаты.EmptyRef();
//		EndIf;
//	EndIf;
//	
//	// Write movements
//	RegisterRecords.Взаиморасчеты.Write();
//КонецПроцедуры //PostToAccounts
//
////-----------------------------------------------------------------------------
//Процедура PostToDeposits()
//	If PaymentSections.Count() > 0 Тогда
//		For Each vPSRow In PaymentSections Do
//			If vPSRow.SumInFolioFromCurrency = 0 Тогда
//				Continue;
//			EndIf;
//			
//			// Storno movement for folio from
//			Movement = RegisterRecords.Депозиты.Add();
//			
//			Movement.Period = Date;
//			
//			FillPropertyValues(Movement, FolioFrom);
//			If ЗначениеЗаполнено(ParentDoc) Тогда
//				FillPropertyValues(Movement, ParentDoc);
//			EndIf;
//			FillPropertyValues(Movement, ThisObject);
//			
//			// Dimensions
//			Movement.СчетПроживания = FolioFrom;
//			Movement.ВалютаЛицСчета = FolioFromCurrency;
//			Movement.Платеж = ThisObject.Ref;
//			
//			// Resources
//			Movement.Сумма = -vPSRow.SumInFolioFromCurrency;
//			
//			// Attributes
//			Movement.PaymentCurrency = FolioFromCurrency;
//			Movement.SumInPaymentCurrency = -vPSRow.SumInFolioFromCurrency;
//			Movement.PaymentSection = vPSRow.PaymentSection;
//			
//			// Expense movement for folio to
//			Movement = RegisterRecords.Депозиты.Add();
//			
//			Movement.Period = Date;
//			
//			FillPropertyValues(Movement, FolioTo);
//			FillPropertyValues(Movement, ThisObject);
//			
//			// Dimensions
//			Movement.СчетПроживания = FolioTo;
//			Movement.ВалютаЛицСчета = FolioToCurrency;
//			Movement.Платеж = ThisObject.Ref;
//			
//			// Resources
//			Movement.Сумма = vPSRow.SumInFolioToCurrency;
//			
//			// Attributes
//			Movement.PaymentCurrency = FolioToCurrency;
//			Movement.SumInPaymentCurrency = vPSRow.SumInFolioToCurrency;
//			Movement.PaymentSection = ?(ЗначениеЗаполнено(PaymentSection), PaymentSection, vPSRow.PaymentSection);
//			
//			// Write movements
//			RegisterRecords.Депозиты.Write();
//		EndDo;
//	Else					
//		// Storno movement for folio from
//		Movement = RegisterRecords.Депозиты.Add();
//		
//		Movement.Period = Date;
//		
//		FillPropertyValues(Movement, FolioFrom);
//		If ЗначениеЗаполнено(ParentDoc) Тогда
//			FillPropertyValues(Movement, ParentDoc);
//		EndIf;
//		FillPropertyValues(Movement, ThisObject);
//		
//		// Dimensions
//		Movement.СчетПроживания = FolioFrom;
//		Movement.ВалютаЛицСчета = FolioFromCurrency;
//		Movement.Платеж = ThisObject.Ref;
//		
//		// Resources
//		Movement.Сумма = -SumInFolioFromCurrency;
//		
//		// Attributes
//		Movement.PaymentCurrency = FolioFromCurrency;
//		Movement.SumInPaymentCurrency = -SumInFolioFromCurrency;
//		
//		// Expense movement for folio to
//		Movement = RegisterRecords.Депозиты.Add();
//		
//		Movement.Period = Date;
//		
//		FillPropertyValues(Movement, FolioTo);
//		FillPropertyValues(Movement, ThisObject);
//		
//		// Dimensions
//		Movement.СчетПроживания = FolioTo;
//		Movement.ВалютаЛицСчета = FolioToCurrency;
//		Movement.Платеж = ThisObject.Ref;
//		
//		// Resources
//		Movement.Сумма = SumInFolioToCurrency;
//		
//		// Attributes
//		Movement.PaymentCurrency = FolioToCurrency;
//		Movement.SumInPaymentCurrency = SumInFolioToCurrency;
//		
//		// Write movements
//		RegisterRecords.Депозиты.Write();
//	EndIf;
//КонецПроцедуры //PostToDeposits
//
////-----------------------------------------------------------------------------
//Процедура PostToPaymentServices()
//	If PaymentSections.Count() > 0 Тогда
//		For Each vPSRow In PaymentSections Do
//			If vPSRow.SumInFolioFromCurrency = 0 Тогда
//				Continue;
//			EndIf;
//			
//			// Storno movement for folio from
//			Movement = RegisterRecords.ПлатежиУслуги.Add();
//			
//			Movement.RecordType = AccumulationRecordType.Expense;
//			Movement.Period = Date;
//			
//			// Dimensions
//			Movement.СчетПроживания = FolioFrom;
//			Movement.Услуга = Справочники.Услуги.EmptyRef();
//			Movement.Платеж = Ref;
//			
//			// Resources
//			Movement.Сумма = -vPSRow.SumInFolioFromCurrency;
//			
//			// Expense movement for folio to
//			Movement = RegisterRecords.ПлатежиУслуги.Add();
//			
//			Movement.RecordType = AccumulationRecordType.Expense;
//			Movement.Period = Date;
//			
//			// Dimensions
//			Movement.СчетПроживания = FolioTo;
//			Movement.Услуга = Справочники.Услуги.EmptyRef();
//			Movement.Платеж = Ref;
//			
//			// Resources
//			Movement.Сумма = vPSRow.SumInFolioToCurrency;
//			
//			// Write movements
//			RegisterRecords.ПлатежиУслуги.Write();
//		EndDo;			
//	Else
//		// Storno movement for folio from
//		Movement = RegisterRecords.ПлатежиУслуги.Add();
//		
//		Movement.RecordType = AccumulationRecordType.Expense;
//		Movement.Period = Date;
//		
//		// Dimensions
//		Movement.СчетПроживания = FolioFrom;
//		Movement.Услуга = Справочники.Услуги.EmptyRef();
//		Movement.Платеж = Ref;
//		
//		// Resources
//		Movement.Сумма = -SumInFolioFromCurrency;
//		
//		// Expense movement for folio to
//		Movement = RegisterRecords.ПлатежиУслуги.Add();
//		
//		Movement.RecordType = AccumulationRecordType.Expense;
//		Movement.Period = Date;
//		
//		// Dimensions
//		Movement.СчетПроживания = FolioTo;
//		Movement.Услуга = Справочники.Услуги.EmptyRef();
//		Movement.Платеж = Ref;
//		
//		// Resources
//		Movement.Сумма = SumInFolioToCurrency;
//		
//		// Write movements
//		RegisterRecords.ПлатежиУслуги.Write();
//	EndIf;
//КонецПроцедуры //PostToPaymentServices
//
////-----------------------------------------------------------------------------
//Function CheckPaymentSections()
//	If ЗначениеЗаполнено(PaymentSection) And PaymentSections.Count() > 0 Тогда
//		For Each vPSRow In PaymentSections Do
//			If vPSRow.SumInFolioFromCurrency = 0 Тогда
//				Continue;
//			EndIf;
//			If vPSRow.PaymentSection <> PaymentSection Тогда
//				Return True;
//			EndIf;
//		EndDo;
//		Return False;
//	Else
//		Return False;
//	EndIf;
//EndFunction //CheckPaymentSections 
//
////-----------------------------------------------------------------------------
//Процедура PostToCustomerAccounts()
//	// Post movents if Контрагент accounts accummulation register 
//	// dimensions are not the same for source and target folios
//	If FolioFrom.Фирма <> FolioTo.Фирма Or
//	   FolioFrom.Контрагент <> FolioTo.Контрагент Or
//	   FolioFrom.Contract <> FolioTo.Contract Or
//	   FolioFrom.FolioCurrency <> FolioTo.FolioCurrency Or
//	   FolioFrom.GuestGroup <> FolioTo.GuestGroup Or
//	   FolioFrom.Гостиница <> FolioTo.Гостиница Or 
//	   FolioFrom.Description <> FolioTo.Description Or 
//	   CheckPaymentSections() Тогда
//	   
//		If PaymentSections.Count() > 0 Тогда
//			For Each vPSRow In PaymentSections Do
//				If vPSRow.SumInFolioFromCurrency = 0 Тогда
//					Continue;
//				EndIf;
//				
//				// Do correction movement for the source folio   
//				Movement = RegisterRecords.ВзаиморасчетыКонтрагенты.Add();
//				
//				Movement.RecordType = AccumulationRecordType.Expense;
//				Movement.Period = Date;
//				
//				// Dimensions
//				Movement.ВалютаРасчетов = FolioFromCurrency;
//				Movement.Гостиница = FolioFrom.Гостиница;
//				Movement.Фирма = FolioFrom.Фирма;
//				If ЗначениеЗаполнено(FolioFrom.Контрагент) Тогда
//					Movement.Контрагент = FolioFrom.Контрагент;
//					Movement.Договор = FolioFrom.Contract;
//				Else
//					Movement.Контрагент = FolioFrom.Гостиница.IndividualsCustomer;
//					Movement.Договор = FolioFrom.Гостиница.IndividualsContract;
//				EndIf;
//				Movement.ГруппаГостей = FolioFrom.GuestGroup;
//				
//				// Resources
//				Movement.Сумма = -vPSRow.SumInFolioFromCurrency;
//				
//				// Attributes
//				Movement.СчетПроживания = FolioFrom;
//				Movement.Клиент = FolioFrom.Client;
//				Movement.НомерРазмещения = FolioFrom.ГруппаНомеров;
//				Movement.УчетнаяДата = BegOfDay(Date);
//				Movement.PaymentSection = vPSRow.PaymentSection;
//				If ЗначениеЗаполнено(Movement.PaymentSection) And ЗначениеЗаполнено(Movement.PaymentSection.СтавкаНДС) Тогда
//					Movement.СтавкаНДС = Movement.PaymentSection.СтавкаНДС;
//				ElsIf ЗначениеЗаполнено(FolioFrom.Фирма) And ЗначениеЗаполнено(FolioFrom.Фирма.VATRate) Тогда
//					Movement.СтавкаНДС = FolioFrom.Фирма.VATRate;
//				EndIf;
//				Movement.СуммаНДС = 0;
//				If ЗначениеЗаполнено(Movement.СтавкаНДС) Тогда
//					Movement.СуммаНДС = cmCalculateVATSum(Movement.СтавкаНДС, Movement.Сумма);
//				EndIf;
//				
//				// Do payment movement for the target folio   
//				Movement = RegisterRecords.ВзаиморасчетыКонтрагенты.Add();
//				
//				Movement.RecordType = AccumulationRecordType.Expense;
//				Movement.Period = Date;
//				
//				// Dimensions
//				Movement.ВалютаРасчетов = FolioToCurrency;
//				Movement.Гостиница = FolioTo.Гостиница;
//				Movement.Фирма = FolioTo.Фирма;
//				If ЗначениеЗаполнено(FolioTo.Контрагент) Тогда
//					Movement.Контрагент = FolioTo.Контрагент;
//					Movement.Договор = FolioTo.Contract;
//				Else
//					Movement.Контрагент = FolioTo.Гостиница.IndividualsCustomer;
//					Movement.Договор = FolioTo.Гостиница.IndividualsContract;
//				EndIf;
//				Movement.ГруппаГостей = FolioTo.GuestGroup;
//				
//				// Resources
//				Movement.Сумма = vPSRow.SumInFolioToCurrency;
//				
//				// Attributes
//				Movement.СчетПроживания = FolioTo;
//				Movement.Клиент = FolioTo.Client;
//				Movement.НомерРазмещения = FolioTo.ГруппаНомеров;
//				Movement.УчетнаяДата = BegOfDay(Date);
//				Movement.PaymentSection = vPSRow.PaymentSection;
//				If ЗначениеЗаполнено(PaymentSection) Тогда
//					Movement.PaymentSection = PaymentSection;
//				EndIf;
//				If ЗначениеЗаполнено(Movement.PaymentSection) And ЗначениеЗаполнено(Movement.PaymentSection.СтавкаНДС) Тогда
//					Movement.СтавкаНДС = Movement.PaymentSection.СтавкаНДС;
//				ElsIf ЗначениеЗаполнено(FolioTo.Фирма) And ЗначениеЗаполнено(FolioTo.Фирма.VATRate) Тогда
//					Movement.СтавкаНДС = FolioTo.Фирма.VATRate;
//				EndIf;
//				Movement.СуммаНДС = 0;
//				If ЗначениеЗаполнено(Movement.СтавкаНДС) Тогда
//					Movement.СуммаНДС = cmCalculateVATSum(Movement.СтавкаНДС, Movement.Сумма);
//				EndIf;
//				
//				// Write movements
//				RegisterRecords.ВзаиморасчетыКонтрагенты.Write();
//			EndDo;
//		Else
//			// Do correction movement for the source folio   
//			Movement = RegisterRecords.ВзаиморасчетыКонтрагенты.Add();
//			
//			Movement.RecordType = AccumulationRecordType.Expense;
//			Movement.Period = Date;
//			
//			// Dimensions
//			Movement.ВалютаРасчетов = FolioFromCurrency;
//			Movement.Гостиница = FolioFrom.Гостиница;
//			Movement.Фирма = FolioFrom.Фирма;
//			If ЗначениеЗаполнено(FolioFrom.Контрагент) Тогда
//				Movement.Контрагент = FolioFrom.Контрагент;
//				Movement.Договор = FolioFrom.Contract;
//			Else
//				Movement.Контрагент = FolioFrom.Гостиница.IndividualsCustomer;
//				Movement.Договор = FolioFrom.Гостиница.IndividualsContract;
//			EndIf;
//			Movement.ГруппаГостей = FolioFrom.GuestGroup;
//			
//			// Resources
//			Movement.Сумма = -SumInFolioFromCurrency;
//			
//			// Attributes
//			Movement.СчетПроживания = FolioFrom;
//			Movement.Клиент = FolioFrom.Client;
//			Movement.НомерРазмещения = FolioFrom.ГруппаНомеров;
//			Movement.УчетнаяДата = BegOfDay(Date);
//			Movement.PaymentSection = PaymentSection;
//			If ЗначениеЗаполнено(Movement.PaymentSection) And ЗначениеЗаполнено(Movement.PaymentSection.СтавкаНДС) Тогда
//				Movement.СтавкаНДС = Movement.PaymentSection.СтавкаНДС;
//			ElsIf ЗначениеЗаполнено(FolioFrom.Фирма) And ЗначениеЗаполнено(FolioFrom.Фирма.VATRate) Тогда
//				Movement.СтавкаНДС = FolioFrom.Фирма.VATRate;
//			EndIf;
//			Movement.СуммаНДС = 0;
//			If ЗначениеЗаполнено(Movement.СтавкаНДС) Тогда
//				Movement.СуммаНДС = cmCalculateVATSum(Movement.СтавкаНДС, Movement.Сумма);
//			EndIf;
//			
//			// Do payment movement for the target folio   
//			Movement = RegisterRecords.ВзаиморасчетыКонтрагенты.Add();
//			
//			Movement.RecordType = AccumulationRecordType.Expense;
//			Movement.Period = Date;
//			
//			// Dimensions
//			Movement.ВалютаРасчетов = FolioToCurrency;
//			Movement.Гостиница = FolioTo.Гостиница;
//			Movement.Фирма = FolioTo.Фирма;
//			If ЗначениеЗаполнено(FolioTo.Контрагент) Тогда
//				Movement.Контрагент = FolioTo.Контрагент;
//				Movement.Договор = FolioTo.Contract;
//			Else
//				Movement.Контрагент = FolioTo.Гостиница.IndividualsCustomer;
//				Movement.Договор = FolioTo.Гостиница.IndividualsContract;
//			EndIf;
//			Movement.ГруппаГостей = FolioTo.GuestGroup;
//			
//			// Resources
//			Movement.Сумма = SumInFolioToCurrency;
//			
//			// Attributes
//			Movement.СчетПроживания = FolioTo;
//			Movement.Клиент = FolioTo.Client;
//			Movement.НомерРазмещения = FolioTo.ГруппаНомеров;
//			Movement.УчетнаяДата = BegOfDay(Date);
//			Movement.PaymentSection = PaymentSection;
//			If ЗначениеЗаполнено(Movement.PaymentSection) And ЗначениеЗаполнено(Movement.PaymentSection.СтавкаНДС) Тогда
//				Movement.СтавкаНДС = Movement.PaymentSection.СтавкаНДС;
//			ElsIf ЗначениеЗаполнено(FolioTo.Фирма) And ЗначениеЗаполнено(FolioTo.Фирма.VATRate) Тогда
//				Movement.СтавкаНДС = FolioTo.Фирма.VATRate;
//			EndIf;
//			Movement.СуммаНДС = 0;
//			If ЗначениеЗаполнено(Movement.СтавкаНДС) Тогда
//				Movement.СуммаНДС = cmCalculateVATSum(Movement.СтавкаНДС, Movement.Сумма);
//			EndIf;
//			
//			// Write movements
//			RegisterRecords.ВзаиморасчетыКонтрагенты.Write();
//		EndIf;
//	EndIf;
//КонецПроцедуры //PostToCustomerAccounts
//
////-----------------------------------------------------------------------------
//Процедура FillHotelProductPaymentDate()
//	If ЗначениеЗаполнено(FolioTo) Тогда
//		If ЗначениеЗаполнено(FolioTo.HotelProduct) Тогда
//			If НЕ ЗначениеЗаполнено(FolioTo.HotelProduct.PaymentDate) Тогда
//				vHPObj = FolioTo.HotelProduct.GetObject();
//				vPaymentMethod = Неопределено;
//				vHPObj.PaymentDate = vHPObj.pmGetHotelProductPaymentDate(vPaymentMethod);
//				If ЗначениеЗаполнено(vPaymentMethod) Тогда
//					vHPObj.СпособОплаты = vPaymentMethod;
//				EndIf;
//				vHPObj.Write();
//			EndIf;
//		EndIf;
//		If ЗначениеЗаполнено(FolioTo.ParentDoc) And 
//		   (TypeOf(FolioTo.ParentDoc) = Type("DocumentRef.Размещение") Or TypeOf(FolioTo.ParentDoc) = Type("DocumentRef.Reservation")) Тогда
//			If ЗначениеЗаполнено(FolioTo.ParentDoc.ПутевкаКурсовка) Тогда
//				If НЕ ЗначениеЗаполнено(FolioTo.ParentDoc.ПутевкаКурсовка.PaymentDate) Тогда
//					vHPObj = FolioTo.ParentDoc.ПутевкаКурсовка.GetObject();
//					vPaymentMethod = Неопределено;
//					vHPObj.PaymentDate = vHPObj.pmGetHotelProductPaymentDate(vPaymentMethod);
//					If ЗначениеЗаполнено(vPaymentMethod) Тогда
//						vHPObj.СпособОплаты = vPaymentMethod;
//					EndIf;
//					If ЗначениеЗаполнено(vHPObj.PaymentDate) Тогда
//						vHPObj.Write();
//					EndIf;
//				EndIf;
//			EndIf;
//		EndIf;
//	EndIf;
//КонецПроцедуры //FillHotelProductPaymentDate
//
////-----------------------------------------------------------------------------
//Процедура Posting(pCancel, pMode)
//	If ThisObject.DataExchange.Load Тогда
//		Return;
//	EndIf;
//	
//	// 1. Post to Accounts
//	PostToAccounts();
//	
//	// 2. Post to Deposits
//	PostToDeposits();
//	
//	// 3. Post to Контрагент accounts
//	PostToCustomerAccounts();
//	
//	// 4. Post to Payment services
//	If Гостиница.DoPaymentsDistributionToServices Тогда
//		PostToPaymentServices();
//	EndIf;
//	
//	// 5. Repost settlements if any
//	pmRepostSettlements();
//	
//	// 6. Set hotel product payment date
//	FillHotelProductPaymentDate();
//	
//	// 7. Update folio accounting number
//	If ЗначениеЗаполнено(FolioTo) And ЗначениеЗаполнено(Гостиница) And Гостиница.UseFolioAccountingNumberPrefix Тогда
//		vHotelObj = Гостиница.GetObject();
//		vFolioAccountingNumberPrefix = vHotelObj.pmGetFolioAccountingNumberPrefix();
//		If НЕ IsBlankString(vFolioAccountingNumberPrefix) And Upper(Left(TrimR(FolioTo.Number), StrLen(vFolioAccountingNumberPrefix))) <> Upper(vFolioAccountingNumberPrefix) Or
//		   IsBlankString(vFolioAccountingNumberPrefix) And НЕ cmIsNumber(TrimAll(FolioTo.Number)) Тогда
//			vFolioObj = FolioTo.GetObject();
//			vFolioObj.SetNewNumber(vFolioAccountingNumberPrefix);
//			vFolioObj.Write(DocumentWriteMode.Write);
//		EndIf;
//	EndIf;
//КонецПроцедуры //Posting
//
////-----------------------------------------------------------------------------
//Процедура pmRepostSettlements() Экспорт
//	If ЗначениеЗаполнено(Гостиница) And Гостиница.SwitchOffRepostingOfSettlements Тогда
//		Return;
//	EndIf;
//	If ЗначениеЗаполнено(FolioFrom) And ЗначениеЗаполнено(FolioFrom.PaymentMethod) And 
//	   FolioFrom.PaymentMethod.IsByBankTransfer Тогда
//		vSettlements = FolioFrom.GetObject().pmGetAllFolioSettlements();
//		For Each vSettlementsRow In vSettlements Do
//			vSettlementObj = vSettlementsRow.Document.GetObject();
//			vSettlementObj.pmPostToAccountsAndPayments();
//		EndDo;
//	EndIf;
//	If ЗначениеЗаполнено(FolioTo) And ЗначениеЗаполнено(FolioTo.PaymentMethod) And 
//	   FolioTo.PaymentMethod.IsByBankTransfer Тогда
//		vSettlements = FolioTo.GetObject().pmGetAllFolioSettlements();
//		For Each vSettlementsRow In vSettlements Do
//			vSettlementObj = vSettlementsRow.Document.GetObject();
//			vSettlementObj.pmPostToAccountsAndPayments();
//		EndDo;
//	EndIf;
//КонецПроцедуры //pmRepostSettlements
//
////-----------------------------------------------------------------------------
//Процедура FillByFolio(pFolio)
//	If НЕ ЗначениеЗаполнено(pFolio) Тогда
//		Return;
//	EndIf;
//	
//	FolioFrom = pFolio;
//	
//	If ЗначениеЗаполнено(FolioFrom.Гостиница) Тогда
//		If Гостиница <> FolioFrom.Гостиница Тогда
//			Гостиница = FolioFrom.Гостиница;
//			SetNewNumber(TrimAll(Гостиница.GetObject().pmGetPrefix()));
//		EndIf;
//	EndIf;
//	
//	ParentDoc = FolioFrom.ParentDoc;
//	If ЗначениеЗаполнено(Гостиница) And Гостиница.SplitFolioBalanceByPaymentSections Тогда
//		PaymentSection = Справочники.ОтделОплаты.EmptyRef();
//	Else
//		PaymentSection = FolioFrom.PaymentSection;
//	EndIf;
//	
//	FolioFromCurrency = FolioFrom.FolioCurrency;
//	FolioFromCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, FolioFromCurrency, ExchangeRateDate);
//	
//	vFolioBalance = 0;
//	PaymentSections.Clear();
//	If ЗначениеЗаполнено(Гостиница) And Гостиница.SplitFolioBalanceByPaymentSections Тогда
//		vPaymentSectionBalances = FolioFrom.GetObject().pmGetPaymentSectionBalances('39991231235959');
//		For Each vPSBalancesRow In vPaymentSectionBalances Do
//			If vPSBalancesRow.SumBalance < 0 Тогда
//				vPSRow = PaymentSections.Add();
//				vPSRow.PaymentSection = vPSBalancesRow.PaymentSection;
//				vPSRow.SumInFolioFromCurrency = -vPSBalancesRow.SumBalance;
//				vPSRow.SumInFolioToCurrency = Round(cmConvertCurrencies(vPSRow.SumInFolioFromCurrency, FolioFromCurrency, FolioFromCurrencyExchangeRate, FolioToCurrency, FolioToCurrencyExchangeRate, ExchangeRateDate, Гостиница), 2);
//			EndIf;
//		EndDo;
//	Else
//		vFolioBalance = FolioFrom.GetObject().pmGetBalance('39991231235959');
//		SumInFolioFromCurrency = 0;
//		If vFolioBalance < 0 Тогда
//			SumInFolioFromCurrency = -vFolioBalance;
//			SumInFolioToCurrency = Round(cmConvertCurrencies(SumInFolioFromCurrency, FolioFromCurrency, FolioFromCurrencyExchangeRate, FolioToCurrency, FolioToCurrencyExchangeRate, ExchangeRateDate, Гостиница), 2);
//		EndIf;
//	EndIf;
//КонецПроцедуры //FillByFolio
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
//		If FolioFrom = FolioTo And
//		   (PaymentSections.Count() = 0 Or PaymentSections.Count() <> 0 And НЕ ЗначениеЗаполнено(PaymentSection)) Тогда
//			vHasErrors = True; 
//			vMsgTextRu = vMsgTextRu + "Лицевые счета должны быть разными!" + Chars.LF;
//			vMsgTextEn = vMsgTextEn + "Folios should not be the same!" + Chars.LF;
//			vMsgTextDe = vMsgTextDe + "Folios should not be the same!" + Chars.LF;
//			pAttributeInErr = ?(pAttributeInErr = "", "FolioTo", pAttributeInErr);
//		EndIf;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(FolioFromCurrency) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Валюта лицевого счета источника> должен быть заполнен!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "<СчетПроживания from Валюта> attribute should be filled!" + Chars.LF;
//		vMsgTextDe = vMsgTextDe + "<СчетПроживания from Валюта> attribute should be filled!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "FolioFromCurrency", pAttributeInErr);
//	EndIf;
//	If НЕ ЗначениеЗаполнено(FolioToCurrency) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Валюта лицевого счета получателя> должен быть заполнен!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "<СчетПроживания to Валюта> attribute should be filled!" + Chars.LF;
//		vMsgTextDe = vMsgTextDe + "<СчетПроживания to Валюта> attribute should be filled!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "FolioToCurrency", pAttributeInErr);
//	EndIf;
//	If НЕ ЗначениеЗаполнено(ExchangeRateDate) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Дата курса> должен быть заполнен!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "<Exchange rate date> attribute should be filled!" + Chars.LF;
//		vMsgTextDe = vMsgTextDe + "<Exchange rate date> attribute should be filled!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "ExchangeRateDate", pAttributeInErr);
//	EndIf;
//	If SumInFolioFromCurrency < 0 Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Для оформления возврата необходимо использовать документ ""Возврат""!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "Use ""Return"" document to return money!" + Chars.LF;
//		vMsgTextDe = vMsgTextDe + "Use ""Return"" document to return money!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "SumInFolioFromCurrency", pAttributeInErr);
//	EndIf;
//	If vHasErrors Тогда
//		pMessage = "ru='" + TrimAll(vMsgTextRu) + "';" + "en='" + TrimAll(vMsgTextEn) + "';"+ "de='" + TrimAll(vMsgTextDe) + "';";
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
//	PaymentMethod = Справочники.СпособОплаты.ПеремещениеДепозита;
//	If НЕ ЗначениеЗаполнено(Гостиница) Тогда
//		Гостиница = ПараметрыСеанса.ТекущаяГостиница;
//	EndIf;
//	If ЗначениеЗаполнено(Гостиница) Тогда
//		FolioFromCurrency = Гостиница.FolioCurrency;
//		FolioToCurrency = Гостиница.FolioCurrency;
//		FolioFromCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, FolioFromCurrency, ExchangeRateDate);
//		FolioToCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, FolioToCurrency, ExchangeRateDate);
//	EndIf;
//КонецПроцедуры //pmFillAttributesWithDefaultValues
//
////-----------------------------------------------------------------------------
//Процедура pmCalculateSums() Экспорт
//	If PaymentSections.Count() > 0 Тогда
//		For Each vPSRow In PaymentSections Do
//			vPSRow.SumInFolioToCurrency = Round(cmConvertCurrencies(vPSRow.SumInFolioFromCurrency, FolioFromCurrency, FolioFromCurrencyExchangeRate, 
//			                                                        FolioToCurrency, FolioToCurrencyExchangeRate, 
//			                                                        ExchangeRateDate, Гостиница), 2);
//		EndDo;
//		SumInFolioFromCurrency = PaymentSections.Total("SumInFolioFromCurrency");
//		SumInFolioToCurrency = PaymentSections.Total("SumInFolioToCurrency");
//	Else
//		SumInFolioToCurrency = Round(cmConvertCurrencies(SumInFolioFromCurrency, FolioFromCurrency, FolioFromCurrencyExchangeRate, 
//		                                                 FolioToCurrency, FolioToCurrencyExchangeRate, 
//		                                                 ExchangeRateDate, Гостиница), 2);
//	EndIf;
//КонецПроцедуры //pmCalculateSums
//
////-----------------------------------------------------------------------------
//Процедура pmFolioToOnChange() Экспорт
//	If ЗначениеЗаполнено(FolioTo) Тогда
//		FolioToCurrency = FolioTo.FolioCurrency;
//		FolioToCurrencyExchangeRate = cmGetCurrencyExchangeRate(Гостиница, FolioToCurrency, ExchangeRateDate);
//		pmCalculateSums();
//	EndIf;
//КонецПроцедуры //pmFolioToOnChange
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
//	If pWriteMode = DocumentWriteMode.Posting Тогда
//		pCancel	= pmCheckDocumentAttributes(vMessage, vAttributeInErr);
//		If pCancel Тогда
//			WriteLogEvent(NStr("en='Document.DataValidation';ru='Документ.КонтрольДанных';de='Document.DataValidation'"), EventLogLevel.Warning, ThisObject.Metadata(), ThisObject.Ref, NStr(vMessage));
//			Message(NStr(vMessage), MessageStatus.Attention);
//			ВызватьИсключение NStr(vMessage);
//		EndIf;
//		If ЗначениеЗаполнено(FolioFrom) And ЗначениеЗаполнено(FolioTo) And
//		   FolioFrom.GuestGroup <> FolioTo.GuestGroup Тогда
//			WriteLogEvent(NStr("en='AccountingAttentionEvents.DepositTransferBetweenGroups';de='AccountingAttentionEvents.DepositTransferBetweenGroups';ru='СигналыДляБухгалтерии.ПеремещениеДепозитаМеждуРазнымиГруппамиГостей'"), EventLogLevel.Warning, Metadata(), Ref, TrimAll(FolioFrom.GuestGroup) + " -> " + TrimAll(FolioTo.GuestGroup) + ", " + cmFormatSum(SumInFolioFromCurrency, FolioFromCurrency));
//		EndIf;
//	EndIf;
//КонецПроцедуры //BeforeWrite
//
////-----------------------------------------------------------------------------
//Процедура OnSetNewNumber(pStandardProcessing, pPrefix)
//	vPrefix = "";
//	If ЗначениеЗаполнено(Гостиница) Тогда
//		vPrefix = TrimAll(Гостиница.GetObject().pmGetPrefix());
//	ElsIf ЗначениеЗаполнено(ПараметрыСеанса.ТекущаяГостиница) Тогда
//		If ЗначениеЗаполнено(ПараметрыСеанса.ТекущаяГостиница) Тогда
//			vPrefix = TrimAll(ПараметрыСеанса.ТекущаяГостиница.GetObject().pmGetPrefix());
//		EndIf;
//	EndIf;
//	If vPrefix <> "" Тогда
//		pPrefix = vPrefix;
//	EndIf;
//КонецПроцедуры //OnSetNewNumber
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
