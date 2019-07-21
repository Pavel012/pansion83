//-----------------------------------------------------------------------------
&НаКлиенте
Процедура OnOpen(pCancel)
	OnOpenForm();
КонецПроцедуры //OnOpen

//-----------------------------------------------------------------------------
&AtServer
Процедура OnOpenForm(pObj = Неопределено)
	vUseParametersObject = True;
	ClientTypeIsDisabled = False;
	//Check parameters
	vObj = pObj;
	If pObj = Неопределено Тогда
		//Get object value
		vObj = FormAttributeToValue("Object");
		vUseParametersObject = False;
	EndIf;
	If vObj.ЭтоНовый() Тогда
		// Fill attributes with default values
		If НЕ ЗначениеЗаполнено(vObj.Автор) Тогда
			vObj.pmFillAttributesWithDefaultValues();
		EndIf;
	EndIf;
	If vObj.ChargingRules.Count() > 0 Тогда
		Payer = Перечисления.КтоПлатит1.Контрагент;
	Else
		Payer = Перечисления.КтоПлатит1.Клиент;
	EndIf;
	// Check user rights to edit charging rules
	If НЕ cmCheckUserPermissions("HavePermissionToEditChargingRules") Тогда
		Items.ChargingRules.ReadOnly = True;
	EndIf;
	// Open read only if user do not have rights to edit Контрагент
	If НЕ cmCheckUserPermissions("HavePermissionToEditCustomer") Тогда
		Message(NStr("en='You do not have rights to edit contracts! Contract data will be opened read only.';ru='У вас нет прав редактировать данные договоров! Карточка договора будет открыта на просмотр.';de='Sie haben keine Rechte, Daten von Verträgen zu redigieren! Die Karte der Verträge wird zur Ansicht geöffnet.'"));
		ЭтаФорма.ReadOnly = True;
	EndIf;
	// Check user rights to edit discounts
	If НЕ cmCheckUserPermissions("HavePermissionToAddManualDiscounts") Тогда
		Items.ТипСкидки.Enabled = False;
	EndIf;
	// Check user rights to edit client type
	If НЕ cmCheckUserPermissions("HavePermissionToChooseClientTypeManually") Тогда
		Items.ТипКлиента.Enabled = False;
		ClientTypeIsDisabled = True;
	EndIf;
	// Check user rights to edit manager
	If НЕ cmCheckUserPermissions("HavePermissionToEditCustomerAndGuestGroupManagers") Тогда
		Items.Автор.ReadOnly = True;
		Items.Автор.TextEdit = False;
		Items.Автор.OpenButton = False;
	EndIf;
	// Check user rights to edit ГруппаНомеров rates
	If НЕ cmCheckUserPermissions("HavePermissionToApproveRoomRates") Тогда
		Items.RoomRatesApproved.Enabled = False;
	Else
		Items.RoomRatesApproved.Enabled = True;
	EndIf;
	RoomRatesApprovedAppearance(vObj);
	DisableFieldsByCustomer();
	// Reset write in form flag
	WasWriteInForm = False;
	If НЕ vUseParametersObject Тогда
		//Set object value
		ValueToFormAttribute(vObj, "Object");
	EndIf;
КонецПроцедуры //OnOpenForm

//-----------------------------------------------------------------------------
&AtServer
Процедура RoomRatesApprovedAppearance(pObj = Неопределено)
	//Check parameters
	vObj = pObj;
	If pObj = Неопределено Тогда
		vObj = Object;
	EndIf;
	If vObj.RoomRatesApproved Тогда
		Items.ТипСкидки.ReadOnly = True;
		Items.Тариф.ReadOnly = True;
		Items.RoomRateServiceGroup.ReadOnly = True;
		Items.Тарифы.ReadOnly = True;
		Items.ШтрафыУсловия.ReadOnly = True;
		Items.DaysBeforeCheckIn.ReadOnly = True;
		Items.DaysAfterReservation.ReadOnly = True;
		Items.DaysAfterSettlement.ReadOnly = True;
		Items.ВалютаРасчетов.ReadOnly = True;
		Items.Агент.ReadOnly = True;
		Items.КомиссияАгента.ReadOnly = True;
		Items.ВидКомиссииАгента.ReadOnly = True;
		Items.КомиссияАгентУслуги.ReadOnly = True;
	Else
		Items.ТипСкидки.ReadOnly = False;
		Items.Тариф.ReadOnly = False;
		Items.RoomRateServiceGroup.ReadOnly = False;
		Items.Тарифы.ReadOnly = False;
		Items.ШтрафыУсловия.ReadOnly = False;
		Items.DaysBeforeCheckIn.ReadOnly = False;
		Items.DaysAfterReservation.ReadOnly = False;
		Items.DaysAfterSettlement.ReadOnly = False;
		Items.ВалютаРасчетов.ReadOnly = False;
		Items.Агент.ReadOnly = False;
		Items.КомиссияАгента.ReadOnly = False;
		Items.ВидКомиссииАгента.ReadOnly = False;
		Items.КомиссияАгентУслуги.ReadOnly = False;
	EndIf;
КонецПроцедуры //RoomRatesApprovedAppearance

//-----------------------------------------------------------------------------
&AtServer
Процедура OnCreateAtServer(pCancel, pStandardProcessing)
	//Get object value
	vObj = FormAttributeToValue("Object");
	If vObj.ЭтоНовый() Тогда
		If НЕ cmCheckUserPermissions("HavePermissionToEditCustomer") Тогда
			pCancel = True;
			Message(NStr("en='You do not have rights to create new contracts!';ru='У вас нет прав регистрировать новые договора контрагентов!';de='Sie haben keine Rechte, neue Verträge der Partner zu registrieren!'"));
		EndIf;
	EndIf;
КонецПроцедуры //OnCreateAtServer

//-----------------------------------------------------------------------------
&AtServer
Процедура DisableFieldsByCustomer()
	//Disabled fields if Контрагент is filled
	If ЗначениеЗаполнено(ПараметрыСеанса.ТекПользователь.Контрагент) Тогда
		ЭтаФорма.ReadOnly = True;
		//Contract data
		Items.Гостиница.ClearButton = False;
		Items.ВалютаРасчетов.Enabled = False;
		Items.ВалютаРасчетов.OpenButton = False;
		Items.ВалютаРасчетов.ClearButton = False;
		Items.ВалютаРасчетов.ChoiceButton = False;
		Items.Агент.Enabled = False;
		Items.Агент.OpenButton = False;
		Items.Агент.ClearButton = False;
		Items.Агент.ChoiceButton = False;
		Items.ВидКомиссииАгента.Enabled = False;
		Items.ВидКомиссииАгента.OpenButton = False;
		Items.ВидКомиссииАгента.ClearButton = False;
		Items.ВидКомиссииАгента.ChoiceButton = False;
		Items.КомиссияАгента.Enabled = False;
		Items.КомиссияАгента.OpenButton = False;
		Items.КомиссияАгента.ClearButton = False;
		Items.КомиссияАгента.ChoiceButton = False;
		Items.КомиссияАгентУслуги.Enabled = False;
		Items.КомиссияАгентУслуги.OpenButton = False;
		Items.КомиссияАгентУслуги.ClearButton = False;
		Items.КомиссияАгентУслуги.ChoiceButton = False;
		Items.Payer.Enabled = False;
		Items.Payer.ChoiceListButton = False;
		Items.PlannedPaymentMethod.Enabled = False;
		Items.PlannedPaymentMethod.OpenButton = False;
		Items.PlannedPaymentMethod.ClearButton = False;
		Items.PlannedPaymentMethod.ChoiceButton = False;
		//Charging rules
		Items.ChargingRules.ReadOnly = True;
		//ГруппаНомеров rates
		Items.ТипСкидки.Enabled = False;
		Items.ТипСкидки.OpenButton = False;
		Items.ТипСкидки.ClearButton = False;
		Items.ТипСкидки.ChoiceButton = False;
        Items.ОснованиеСкидки.Enabled = False;
		Items.Тариф.Enabled = False;
		Items.Тариф.OpenButton = False;
		Items.Тариф.ClearButton = False;
		Items.Тариф.ChoiceButton = False;
		Items.RoomRateServiceGroup.Enabled = False;
		Items.RoomRateServiceGroup.OpenButton = False;
		Items.RoomRateServiceGroup.ClearButton = False;
		Items.RoomRateServiceGroup.ChoiceButton = False;
		Items.ШтрафыУсловия.Enabled = False;
		Items.ШтрафыУсловия.OpenButton = False;
		Items.ШтрафыУсловия.ClearButton = False;
		Items.ШтрафыУсловия.ChoiceButton = False;
		Items.DaysBeforeCheckIn.Enabled = False;
        Items.DaysAfterReservation.Enabled = False;
		Items.DaysAfterSettlement.Enabled = False;
		Items.RoomRatesApproved.Enabled = False;
		Items.Тарифы.ReadOnly = True;
		Items.AllowRoomRatesGroup.ReadOnly = True;
		Items.DefAnaliticalParametersGroup.Enabled = False;
	EndIf;
КонецПроцедуры //DisableFieldsByCustomer

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура CodeOnChange(pItem)
	CodeOnChangeAtServer();
КонецПроцедуры //CodeOnChange

//-----------------------------------------------------------------------------
&AtServer
Процедура CodeOnChangeAtServer(pObj = Неопределено)
	vUseParametersObject = True;
	//Check parameters
	vObj = pObj;
	If pObj = Неопределено Тогда
		//Get object value
		vObj = FormAttributeToValue("Object");
		vUseParametersObject = False;
	EndIf;
	If vObj.ЭтоНовый() Тогда
		If НЕ IsBlankString(vObj.Code) And IsBlankString(vObj.Description) Тогда
			vObj.Description = СокрЛП(vObj.Code);
		EndIf;
	EndIf;
	If НЕ vUseParametersObject Тогда
		//Set object value
		ValueToFormAttribute(vObj, "Object");
	EndIf;
КонецПроцедуры //CodeOnChangeAtServer

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура DiscountTypeOnChange(pItem)
	DiscountTypeOnChangeAtServer();
КонецПроцедуры //DiscountTypeOnChange

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура DiscountConfirmationTextOnChange(pItem)
	DiscountTypeOnChangeAtServer();
КонецПроцедуры //DiscountConfirmationTextOnChange

//-----------------------------------------------------------------------------
&AtServer
Процедура DiscountTypeOnChangeAtServer(pObj = Неопределено)
	//Check parameters
	vUseParameterObject = True;
	vObj = pObj;
	If pObj = Неопределено Тогда
		//Get object value
		vObj = FormAttributeToValue("Object");
		vUseParameterObject = False;
	EndIf;
	//vDiscountType = vObj.ТипСкидки;
	//vDiscountConfirmationText = vObj.ОснованиеСкидки;
//	If НЕ ЗначениеЗаполнено(vDiscountType) Тогда
//		pDiscountConfirmationText = "";
//	EndIf;
	If НЕ vUseParameterObject Тогда
		//Set object value
		ValueToFormAttribute(vObj, "Object");
	EndIf;
КонецПроцедуры //DiscountTypeOnChangeAtServer

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура RoomRatesApprovedOnChange(pItem)
	RoomRatesApprovedAppearance();
КонецПроцедуры //RoomRatesApprovedOnChange

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура SourceOfBusinessStartListChoice(pItem, pStandardProcessing)
	Items.ИсточникИнфоГостиница.ChoiceList.LoadValues(GetArrayOfAllSourceOfBusiness());
КонецПроцедуры //SourceOfBusinessStartListChoice

//-----------------------------------------------------------------------------
&AtServer
Function GetArrayOfAllSourceOfBusiness()
	vSOBTable = cmGetAllSourcesOfBusiness();
	vSOBArray = vSOBTable.UnloadColumn("ИсточИнфоГостиница");
	Return vSOBArray;
EndFunction //GetListOfAllSourceOfBusiness

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура ClientTypeStartListChoice(pItem, pStandardProcessing)
	Items.ТипКлиента.ChoiceList.LoadValues(GetArrayOfAllClientTypes());
КонецПроцедуры //ClientTypeStartListChoice

//-----------------------------------------------------------------------------
&AtServer
Function GetArrayOfAllClientTypes()
	vCTTable = cmGetAllClientTypes();
	vCTArray = vCTTable.UnloadColumn("ТипКлиента");
	Return vCTArray;
EndFunction //GetArrayOfAllClientTypes

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура ClientTypeOnChange(pItem)
	ClientTypeOnChangeAtServer();
КонецПроцедуры //ClientTypeOnChange

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура ClientTypeConfirmationTextOnChange(pItem)
	ClientTypeOnChangeAtServer();
КонецПроцедуры //ClientTypeConfirmationTextOnChange

//-----------------------------------------------------------------------------
Процедура ClientTypeOnChangeAtServer(pObj = Неопределено) 
	//Check parameters
	vUseParameterObject = True;
	vObj = pObj;
	If pObj = Неопределено Тогда
		//Get object value
		vObj = FormAttributeToValue("Object");
		vUseParameterObject = False;
	EndIf;
	//vClientType = vObj.ТипКлиента;
//	vClientTypeConfirmationText = vObj.СтрокаПодтверждения;
//	If НЕ ЗначениеЗаполнено(vClientType) Тогда
//		vClientTypeConfirmationText = "";
//	EndIf;
	If НЕ vUseParameterObject Тогда
		//Set object value
		ValueToFormAttribute(vObj, "Object");
	EndIf;
КонецПроцедуры //ClientTypeOnChangeAtServer

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура PayerOnChange(pItem)
	PayerOnChangeAtServer();
КонецПроцедуры //PayerOnChange

//-----------------------------------------------------------------------------
&AtServer
Процедура PayerOnChangeAtServer(pObj = Неопределено)
	//Check parameters
	vUseParamterObject = True;
	vObj = pObj;
	If pObj = Неопределено Тогда
		//Get object value
		vObj = FormAttributeToValue("Object");
		vUseParamterObject = False;
	EndIf;
	If Payer = Перечисления.КтоПлатит1.Клиент Тогда
		vHotel = ПараметрыСеанса.ТекущаяГостиница;
		If ЗначениеЗаполнено(vHotel) Тогда
			vObj.PlannedPaymentMethod = vHotel.PlannedPaymentMethod;
		Else
			vObj.PlannedPaymentMethod = Справочники.СпособОплаты.EmptyRef();
			Message(NStr("en='Default hotel is not filled!';ru='Не выбрана гостиница по умолчанию!';de='Kein Гостиница als Standard-Einstellung ist gewählt!'"));
		EndIf;
		vObj.ChargingRules.Clear();
	ElsIf Payer = Перечисления.КтоПлатит1.Контрагент Тогда
		If ЗначениеЗаполнено(vHotel) Тогда
			vObj.PlannedPaymentMethod = vHotel.PaymentMethodForCustomerPayments;
			ChargingFolioParametersOnChangeAtServer(vObj);
		Else
			vObj.PlannedPaymentMethod = Справочники.СпособОплаты.EmptyRef();
		EndIf;
		LoadDefaultChargingRules(vObj);
	EndIf;
	If НЕ vUseParamterObject Тогда
		//Set object value
		ValueToFormAttribute(vObj, "Object");
	EndIf;
КонецПроцедуры //PayerOnChangeAtServer

//-----------------------------------------------------------------------------
&AtServer
Процедура LoadDefaultChargingRules(pObj = Неопределено)
	//Check paramters
	vUseParamterObject = True;
	vObj = pObj;
	If pObj = Неопределено Тогда
		//Get object value
		vObj = FormAttributeToValue("Object");
		vUseParamterObject = False;
	EndIf;
	vHotel = ПараметрыСеанса.ТекущаяГостиница;
	If ЗначениеЗаполнено(vHotel) Тогда
		vObj.ChargingRules.Clear();
		vObj.pmCreateFolios(vHotel, CurrentDate());
	Else
		Message(NStr("en='Default hotel is not filled!';ru='Не выбрана гостиница по умолчанию!';de='Kein Гостиница als Standard-Einstellung ist gewählt!'"));
	EndIf;
	If НЕ vUseParamterObject Тогда
		//Set object value
		ValueToFormAttribute(vObj, "Object");
	EndIf;
КонецПроцедуры //LoadDefaultChargingRules

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура AccountingCurrencyOnChange(pItem)
	ChargingFolioParametersOnChangeAtServer();
КонецПроцедуры //AccountingCurrencyOnChange

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура PlannedPaymentMethodOnChange(pItem)
	ChargingFolioParametersOnChangeAtServer();
КонецПроцедуры //PlannedPaymentMethodOnChange

//-----------------------------------------------------------------------------
&AtServer
Процедура ChargingFolioParametersOnChangeAtServer(pObj = Неопределено)
	//Check parameters
	vObj = pObj;
	If pObj = Неопределено Тогда
		vObj = Object;
	EndIf;
	If Payer = Перечисления.КтоПлатит1.Контрагент Тогда
		If ЗначениеЗаполнено(vObj.PlannedPaymentMethod) Тогда
			If vObj.ChargingRules.Count() > 0 Тогда
				If НЕ vObj.ChargingRules.Get(0).ChargingFolio.IsEmpty() Тогда
					vFolioObj = vObj.ChargingRules.Get(0).ChargingFolio.GetObject();
					vFolioObj.СпособОплаты = vObj.PlannedPaymentMethod;
					vFolioObj.ВалютаЛицСчета = vObj.ВалютаРасчетов;
					Try
						vFolioObj.Write();
					Except
						Message("Не удалось сохранить планируемый способ оплаты! Повторите изменение еще раз.");
					EndTry;
				EndIf;
			EndIf;
		EndIf;
	EndIf;
КонецПроцедуры //ChargingFolioParametersOnChangeAtServer

//-----------------------------------------------------------------------------
&AtServer
Процедура BeforeWriteAtServer(pCancel, pCurrentObject, pWriteParameters)
	vMessage = ""; 
	vAttributeInErr = "";
	// Save state
	WasModified = ЭтаФорма.Modified;
	WasNew = pCurrentObject.ЭтоНовый();
	// Check item attributes
	pCancel = pCurrentObject.pmCheckContractAttributes(vMessage, vAttributeInErr);
	If pCancel Тогда
		WriteLogEvent("Справочник.Запись", EventLogLevel.Warning, pCurrentObject.Metadata(), pCurrentObject.Ref, vMessage);
		Message(vMessage);
		If НЕ IsBlankString(vAttributeInErr) Тогда
			ЭтаФорма.CurrentItem = ЭтаФорма.Items[vAttributeInErr];
		EndIf;
		// Reset write in form flag
		WasWriteInForm = False;
	Else
		// Check ГруппаНомеров rates
		i = 0;
		While i < pCurrentObject.Тарифы.Count() Do
			vRRRow = pCurrentObject.Тарифы.Get(i);
			If НЕ ЗначениеЗаполнено(vRRRow.Тариф) Тогда
				pCurrentObject.Тарифы.Delete(i);
			Else
				i = i + 1;
			EndIf;
		EndDo;
	EndIf;
КонецПроцедуры //BeforeWriteAtServer

//-----------------------------------------------------------------------------
//&AtServer
//Процедура AfterWriteAtServer(pCurrentObject, pWriteParameters)
//	// Save changes to the client change history
//	If WasModified Тогда
//		pCurrentObject.pmWriteToContractChangeHistory(CurrentDate(), ПараметрыСеанса.ТекПользователь);
//	EndIf;
//КонецПроцедуры //AfterWriteAtServer

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура AfterWrite(pWriteParameters)
	WriteAtServer();
КонецПроцедуры //AfterWrite

//-----------------------------------------------------------------------------
&AtServer
Процедура WriteAtServer()
	//Get object value
	vObj = FormAttributeToValue("Object");
	// Update Контрагент and contract attribute for all folios in the charging rules if was new
	If WasNew Тогда
		For Each vRow In vObj.ChargingRules Do
			vFolio = vRow.ChargingFolio;
			If ЗначениеЗаполнено(vFolio) Тогда
				vFolioObj = vFolio.GetObject();
				If НЕ ЗначениеЗаполнено(vFolioObj.Договор) Тогда
					vFolioObj.Контрагент = vObj.Owner;
					vFolioObj.Договор = vObj.Ref;
					Try
						vFolioObj.Write();
					Except
						vErrInfo = ErrorInfo();
						WriteLogEvent(NStr("en='Catalog.Contracts.AfterWrite';ru='Справочник.Договоры.ПослеЗаписи';de='Catalog.Contracts.AfterWrite'"), EventLogLevel.Warning, vObj.Metadata(), vObj.Ref, cmGetRootErrorDescription(vErrInfo));
						Message(NStr("en='Write error!';ru='Ошибка записи!';de='Fehler beim Schreiben!'"));
					EndTry;
				EndIf;
			EndIf;
		EndDo;
	EndIf;
	// Reset write in form flag
	WasWriteInForm = False;
КонецПроцедуры


