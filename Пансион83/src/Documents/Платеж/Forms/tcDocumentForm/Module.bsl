//-----------------------------------------------------------------------------
&AtServer
Процедура OnCreateAtServer(pCancel, pStandardProcessing)
	vDocument = Неопределено;
	If Parameters.Property("Document", vDocument) Тогда
		vObj = FormAttributeToValue("Object");
		vObj.Fill(vDocument);
		vSum = 0;
		If Parameters.Property("Сумма", vSum) Тогда
			vObj.Сумма = vSum;
			vObj.SumInFolioCurrency = vSum;
			Sum = vSum;
		EndIf;
		ValueToFormAttribute(vObj, "Object");
	EndIf;
КонецПроцедуры //OnCreateAtServer

//-----------------------------------------------------------------------------
&AtServer
Процедура FillListOfPaymentMethods(pObj)
	Items.СпособОплаты.ChoiceList.LoadValues(cmGetListOfPaymentMethodsAllowed(ПараметрыСеанса.ТекПользователь, , pObj.Касса).UnloadValues());
	// Check that current payment method is in the list
	If pObj.Posted Тогда
		If ЗначениеЗаполнено(pObj.СпособОплаты) Тогда
			If Items.СпособОплаты.ChoiceList.FindByValue(pObj.СпособОплаты) = Неопределено Тогда
				Items.СпособОплаты.ChoiceList.Add(pObj.СпособОплаты);
			EndIf;
		EndIf;
	EndIf;
КонецПроцедуры //FillListOfPaymentMethods

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура SumOnChange(pItem)
	SumOnChangeAtServer();
КонецПроцедуры //SumOnChange

//-----------------------------------------------------------------------------
&AtServer
Процедура SumOnChangeAtServer(pObj = Неопределено)
	vObj = pObj;
	If pObj = Неопределено Тогда
		vObj = FormAttributeToValue("Object");
	EndIf;
	If ЗначениеЗаполнено(vObj.Гостиница) And vObj.Гостиница.SplitFolioBalanceByPaymentSections Тогда
		vObj.ОтделОплаты.Clear();
		vNewRow = vObj.ОтделОплаты.Add();
		vNewRow.Сумма = vObj.Сумма;
	EndIf; 
	If vObj.ОтделОплаты.Count() > 0 Тогда
		For Each vPSRow In vObj.ОтделОплаты Do
			vPSRow.СуммаНДС = cmCalculateVATSum(vPSRow.СтавкаНДС, vPSRow.Сумма);

			vPSRow.SumInFolioCurrency = Round(cmConvertCurrencies(vPSRow.Сумма, vObj.PaymentCurrency, vObj.PaymentCurrencyExchangeRate, 
			                                                      vObj.ВалютаЛицСчета, vObj.FolioCurrencyExchangeRate, 
			                                                      vObj.ExchangeRateDate, vObj.Гостиница), 2);
			vPSRow.VATSumInFolioCurrency = cmCalculateVATSum(vPSRow.СтавкаНДС, vPSRow.SumInFolioCurrency);
		EndDo;
		vObj.pmCalculateTotalsByPaymentSections();
	Else
		vObj.СуммаНДС = cmCalculateVATSum(vObj.СтавкаНДС, vObj.Сумма);
		vObj.SumInFolioCurrency = Round(cmConvertCurrencies(vObj.Сумма, vObj.PaymentCurrency, vObj.PaymentCurrencyExchangeRate, 
		                                               vObj.ВалютаЛицСчета, vObj.FolioCurrencyExchangeRate, 
		                                               vObj.ExchangeRateDate, vObj.Гостиница), 2);
		vObj.VATSumInFolioCurrency = cmCalculateVATSum(vObj.СтавкаНДС, vObj.SumInFolioCurrency);
	EndIf;
	If pObj = Неопределено Тогда
		ValueToFormAttribute(vObj, "Object");
	EndIf;
КонецПроцедуры //SumOnChangeAtServer

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура PaymentMethodOnChange(pItem)
	// Fill list of cash registers allowed for the current user
	FillListOfCashRegisters();
	// Set default cash register
	vResult = SetDefaultCashRegister();
	If vResult Тогда
		//vUserChoiceItem = Неопределено;

		CashRegistersList.ShowChooseItem(Новый ОписаниеОповещения("PaymentMethodOnChangeЗавершение", ЭтотОбъект), NStr("en='Select cash register please!';ru='Выберите ККМ!';de='Wählen Sie Registrierkasse!'"));
	EndIf;
КонецПроцедуры

&НаКлиенте
Процедура PaymentMethodOnChangeЗавершение(SelectedItem, ДополнительныеПараметры) Экспорт
	
	vUserChoiceItem = SelectedItem;
	If vUserChoiceItem <> Неопределено Тогда
		Object.Касса = vUserChoiceItem.Value;
		CashRegisterOnChangeAtServer();
	EndIf;

КонецПроцедуры //PaymentMethodOnChange

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура OnOpen(pCancel)
	
	If CheckInvoices() Тогда
		//@skip-warning
		vFrm = ПолучитьФорму("Document.СчетНаОплату.ФормаПодбора", New Structure("ChoiceMode", True));
		vFrm.SelHotel = Object.Гостиница;
		vFrm.SelGuestGroup = Object.ГруппаГостей;
		
		
	EndIf;
	
	// Set default cash register
	If ЭтоНовый Тогда
		vResult = SetDefaultCashRegister();
		If vResult Тогда
			//vUserChoiceItem = Неопределено;

			CashRegistersList.ShowChooseItem(Новый ОписаниеОповещения("OnOpenЗавершение", ЭтотОбъект), NStr("en='Select cash register please!';ru='Выберите ККМ!';de='Wählen Sie Registrierkasse!'"));
		EndIf;
	EndIf;
КонецПроцедуры

&НаКлиенте
Процедура OnOpenЗавершение(SelectedItem, ДополнительныеПараметры) Экспорт
	
	vUserChoiceItem = SelectedItem;
	If vUserChoiceItem <> Неопределено Тогда
		Object.Касса = vUserChoiceItem.Value;
		CashRegisterOnChangeAtServer();
	EndIf;

КонецПроцедуры //OnOpen


//-----------------------------------------------------------------------------
&AtServer
Function CheckInvoices()
	If ЭтоНовый Тогда
		// Check if payment folio is based on reservation and there are invoices for this guest group then
		// ask user to choose invoice
		If ЗначениеЗаполнено(Object.СчетПроживания) And ЗначениеЗаполнено(Object.СчетПроживания.ГруппаГостей) And НЕ ЗначениеЗаполнено(Object.СчетНаОплату) Тогда
			If НЕ ЗначениеЗаполнено(Object.СчетПроживания.ДокОснование) Or ЗначениеЗаполнено(Object.СчетПроживания.ДокОснование) And 
			  (TypeOf(Object.СчетПроживания.ДокОснование) = Type("DocumentRef.Бронирование") Or TypeOf(Object.СчетПроживания.ДокОснование) = Type("DocumentRef.Размещение") Or TypeOf(Object.СчетПроживания.ДокОснование) = Type("DocumentRef.БроньУслуг")) Тогда
				vGroupObj = Object.СчетПроживания.ГруппаГостей.GetObject();
				vInvoices = vGroupObj.pmGetInvoices(Object.СчетПроживания.Контрагент, Object.СчетПроживания.Договор);
				If vInvoices.Count() > 0 Тогда
					Return True;
				EndIf;
			EndIf;
		EndIf;
	EndIf;
	Return False;
EndFunction //CheckInvoices









//-----------------------------------------------------------------------------
&AtServer
Процедура CashRegisterOnChangeAtServer(pObj = Неопределено)
	vObj = pObj;
	If pObj = Неопределено Тогда
		vObj = FormAttributeToValue("Object");
	EndIf;
	// Fill list of payment methods allowed for the current user
	FillListOfPaymentMethods(vObj);
	// Set default payment method
	If vObj.ЭтоНовый() Тогда
		SetDefaultPaymentMethod(vObj);
	EndIf;
	If pObj = Неопределено Тогда
		ValueToFormAttribute(vObj, "Object");
	EndIf;
КонецПроцедуры //CashRegisterOnChangeAtServer

//-----------------------------------------------------------------------------
&AtServer
Процедура FillListOfCashRegisters(pObj=Неопределено)
	vObj = pObj;
	If pObj = Неопределено Тогда
		vObj = FormAttributeToValue("Object");
	EndIf;
	If cmCheckUserPermissions("HavePermissionToViewAllCashRegisters") Тогда
		CashRegistersList = cmGetListOfAllCashRegisters(vObj.Фирма);
	Else
		CashRegistersList = cmGetListOfCashRegistersAllowed(vObj.Фирма, ПараметрыСеанса.РабочееМесто, vObj.СпособОплаты);
	EndIf;
	// Check that current cash register is in the list
	If vObj.Posted Тогда
		If ЗначениеЗаполнено(vObj.Касса) Тогда
			If CashRegistersList.FindByValue(vObj.Касса) = Неопределено Тогда
				CashRegistersList.Add(vObj.Касса);
			EndIf;
		EndIf;
	EndIf;
	If pObj = Неопределено Тогда
		ValueToFormAttribute(vObj, "Object");
	EndIf;
КонецПроцедуры //FillListOfCashRegisters

//-----------------------------------------------------------------------------
&AtServer
Function SetDefaultCashRegister(pObj = Неопределено)
	vObj = pObj;
	If pObj = Неопределено Тогда
		vObj = FormAttributeToValue("Object");
	EndIf;
	If CashRegistersList.FindByValue(vObj.Касса) = Неопределено Тогда
		If pObj = Неопределено Тогда
			vObj.Касса = Справочники.ККМ.EmptyRef();
		Else
			pObj.Касса = Справочники.ККМ.EmptyRef();
		EndIf;
		If ЗначениеЗаполнено(vObj.СпособОплаты) Тогда
			If vObj.СпособОплаты.BookByCashRegister Тогда
				If CashRegistersList.Count() = 1 Тогда
					If pObj = Неопределено Тогда
						vObj.Касса = CashRegistersList.Get(0).Value;
					Else
						pObj.Касса = CashRegistersList.Get(0).Value;
					EndIf;
				ElsIf CashRegistersList.Count() > 1 Тогда
					Return True;
				EndIf;
			EndIf;
		EndIf;
	EndIf;
	If pObj = Неопределено Тогда
		ValueToFormAttribute(vObj, "Object");
	EndIf;
	Return False;
EndFunction //SetDefaultCashRegister

//-----------------------------------------------------------------------------
&AtServer
Процедура SetDefaultPaymentMethod(pObj)
	If НЕ ЗначениеЗаполнено(pObj.СпособОплаты) Тогда
		If ЗначениеЗаполнено(pObj.Гостиница) Тогда
			If ЗначениеЗаполнено(pObj.Гостиница.PlannedPaymentMethod) Тогда
				pObj.СпособОплаты = pObj.Гостиница.PlannedPaymentMethod;
			EndIf;
		EndIf;
		If ЗначениеЗаполнено(pObj.ДокОснование) Тогда
			If ЗначениеЗаполнено(pObj.ДокОснование.PlannedPaymentMethod) Тогда
				pObj.СпособОплаты = pObj.ДокОснование.PlannedPaymentMethod;
			EndIf;
		EndIf;
		If ЗначениеЗаполнено(pObj.СчетПроживания) Тогда
			If ЗначениеЗаполнено(pObj.СчетПроживания.СпособОплаты) Тогда
				pObj.СпособОплаты = pObj.СчетПроживания.СпособОплаты;
			EndIf;
		EndIf;
	EndIf;
	If ЗначениеЗаполнено(pObj.СпособОплаты) Тогда
		If Items.СпособОплаты.ChoiceList.FindByValue(pObj.СпособОплаты) = Неопределено Тогда
			pObj.СпособОплаты = Справочники.СпособОплаты.EmptyRef();
		EndIf;
	EndIf;
КонецПроцедуры //SetDefaultPaymentMethod

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура AfterWrite(pWriteParameters)
	Оповестить("Document.Платеж.Write", Object.Ref, ЭтаФорма);
КонецПроцедуры //AfterWrite
