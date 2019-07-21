//----------------------------------------------------------------
&AtServer
Процедура OnCreateAtServer(pCancel, pStandardProcessing)
	TableBoxContracts.Parameters.SetParameterValue("qOwner", Object.Ref);
	TableBoxBankAccounts.Parameters.SetParameterValue("qOwner", Object.Ref);
	vObj = FormAttributeToValue("Object");
	If vObj.ЭтоНовый() Тогда
		If НЕ cmCheckUserPermissions("HavePermissionToEditCustomer") Тогда
			pCancel = True;
			Message(NStr("en='You do not have rights to create new customers!';ru='У вас нет прав регистрировать новых контрагентов!';de='Sie haben keine Rechte, neue Partner zu registrieren!'"));
		EndIf;
	EndIf;
КонецПроцедуры //OnCreateAtServer

//-----------------------------------------------------------------------------
&AtServer
Процедура DisableFieldsByCustomer()
	//Disabled fields if Контрагент is filled
	If ЗначениеЗаполнено(ПараметрыСеанса.ТекПользователь.Контрагент) Тогда
		//Контрагент attributes
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
		Items.ТипКонтрагента.Enabled = False;
		Items.ТипКонтрагента.OpenButton = False;
		Items.ТипКонтрагента.ClearButton = False;
		Items.ТипКонтрагента.ChoiceButton = False;
		Items.Payer.Enabled = False;
		Items.PlannedPaymentMethod.Enabled = False;
		Items.PlannedPaymentMethod.OpenButton = False;
		Items.PlannedPaymentMethod.ClearButton = False;
		Items.PlannedPaymentMethod.ChoiceButton = False;
		Items.ЧерныйЛист.Enabled = False;
		Items.БелыйЛист.Enabled = False;
		Items.DoNotPostCommission.Enabled = False;
		Items.ExternalCode.Enabled = False;
		//Charging rules
		Items.ChargingRules.ReadOnly = True;
		//ГруппаНомеров rates
		Items.GroupRoomRates.Visible = False;
		Items.Тариф.Enabled = False;
		Items.Тариф.OpenButton = False;
		Items.Тариф.ClearButton = False;
		Items.Тариф.ChoiceButton = False;
		Items.RoomRateServiceGroup.Enabled = False;
		Items.RoomRateServiceGroup.OpenButton = False;
		Items.RoomRateServiceGroup.ClearButton = False;
		Items.RoomRateServiceGroup.ChoiceButton = False;
		Items.NoShowFeeTerms.Enabled = False;
		Items.NoShowFeeTerms.OpenButton = False;
		Items.NoShowFeeTerms.ClearButton = False;
		Items.NoShowFeeTerms.ChoiceButton = False;
		Items.DaysBeforeCheckIn.Enabled = False;
        Items.DaysAfterReservation.Enabled = False;
		Items.Тарифы.ReadOnly = True;
		Items.RoomRatesApproved.Enabled =False;
		Items.ТипСкидки.Enabled = False;
		Items.ТипСкидки.OpenButton = False;
		Items.ТипСкидки.ClearButton = False;
		Items.ТипСкидки.ChoiceButton = False;
		Items.ОснованиеСкидки.Enabled = False;
		//Contracts
		Items.Договор.Enabled = False;
		Items.Договор.OpenButton = False;
		Items.Договор.ClearButton = False;
		Items.Договор.ChoiceButton = False;
		Items.AgentCommissionContract.Enabled = False;
		Items.AgentCommissionContract.OpenButton = False;
		Items.AgentCommissionContract.ClearButton = False;
		Items.AgentCommissionContract.ChoiceButton = False;
        Items.TableBoxContracts.ReadOnly = True;
	EndIf;
КонецПроцедуры //DisableFieldsByCustomer

//----------------------------------------------------------------
&НаКлиенте
Процедура OnOpen(pCancel)
	OnOpenForm();
КонецПроцедуры //OnOpen

//----------------------------------------------------------------
&AtServer
Процедура OnOpenForm(pObj = Неопределено)
	//Check paramters
	vObj = pObj;
	vUseParamterObject = True;
	If pObj = Неопределено Тогда
		//Get object value
		vObj = FormAttributeToValue("Object");
		vUseParamterObject = False;
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
	// Check user rights to edit discounts
	If НЕ cmCheckUserPermissions("HavePermissionToAddManualDiscounts") Тогда
		Items.DiscountGroup.Enabled = False;
	EndIf;
	// Check user rights to edit manager
	If НЕ cmCheckUserPermissions("HavePermissionToEditCustomerAndGuestGroupManagers") Тогда
		Items.Автор.ReadOnly = True;
		Items.Автор.TextEdit = False;
		Items.Автор.ChoiceButton = False;
		Items.Автор.OpenButton = False;
		Items.Автор.ClearButton = False;
	EndIf;
	// Check user rights to edit ГруппаНомеров rates
	If НЕ cmCheckUserPermissions("HavePermissionToApproveRoomRates") Тогда
		Items.RoomRatesApproved.Enabled = False;
	Else
		Items.RoomRatesApproved.Enabled = True;
	EndIf;
	RoomRatesApprovedAppearance(vObj);
	// Open read only if user do not have rights to edit Контрагент
	If НЕ cmCheckUserPermissions("HavePermissionToEditCustomer") Тогда
		Message(NStr("en='You do not have rights to edit customers! Контрагент data will be opened read only.';ru='У вас нет прав редактировать данные контрагентов! Карточка контрагента будет открыта на просмотр.';de='Sie haben keine Rechte, Daten von Partnern zu redigieren! Die Karte des Partners wird zur Ansicht geöffnet.'"));
		ЭтаФорма.ReadOnly = True;
	EndIf;
	DisableFieldsByCustomer();
	If НЕ vUseParamterObject Тогда
		//Set object value
		ValueToFormAttribute(vObj, "Object");
	EndIf;
	// Reset write in form flag
	WasWriteInForm = False;
КонецПроцедуры //OnOpenForm

//-----------------------------------------------------------------------------
&AtServer
Процедура RoomRatesApprovedAppearance(pObj = Неопределено)
	//Check paramters
	vObj = pObj;
	If pObj = Неопределено Тогда
		vObj = Object;
	EndIf;
	If vObj.RoomRatesApproved Тогда
		Items.ТипСкидки.ReadOnly = True;
		Items.Тариф.ReadOnly = True;
		Items.RoomRateServiceGroup.ReadOnly = True;
		Items.Тарифы.ReadOnly = True;
		Items.NoShowFeeTerms.ReadOnly = True;
		Items.DaysBeforeCheckIn.ReadOnly = True;
		Items.DaysAfterReservation.ReadOnly = True;
		Items.DefaultContract.ReadOnly = True;
		Items.TableBoxContracts.ReadOnly = True;
		Items.ВалютаРасчетов.ReadOnly = True;
		Items.Агент.ReadOnly = True;
		Items.КомиссияАгента.ReadOnly = True;
		Items.ВидКомиссииАгента.ReadOnly = True;
		Items.КомиссияАгентУслуги.ReadOnly = True;
		Items.AgentCommissionContract.ReadOnly = True;
		Items.DoNotPostCommission.Enabled = False;
	Else
		Items.ТипСкидки.ReadOnly = False;
		Items.Тариф.ReadOnly = False;
		Items.RoomRateServiceGroup.ReadOnly = False;
		Items.Тарифы.ReadOnly = False;
		Items.NoShowFeeTerms.ReadOnly = False;
		Items.DaysBeforeCheckIn.ReadOnly = False;
		Items.DaysAfterReservation.ReadOnly = False;
		Items.TableBoxContracts.ReadOnly = False;
		Items.ВалютаРасчетов.ReadOnly = False;
		Items.Агент.ReadOnly = False;
		Items.КомиссияАгента.ReadOnly = False;
		Items.ВидКомиссииАгента.ReadOnly = False;
		Items.КомиссияАгентУслуги.ReadOnly = False;
		Items.AgentCommissionContract.ReadOnly = False;
		Items.DoNotPostCommission.Enabled = True;
	EndIf;
КонецПроцедуры //RoomRatesApprovedAppearance

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
						Message(NStr("en='Failed to change planned payment method! Please try again.';ru='Не удалось сохранить планируемый способ оплаты! Повторите изменение еще раз.';de='Die geplante Zahlungsmethode konnte nicht gespeichert werden! Wiederholen Sie die Änderung noch einmal.'"));
					EndTry;
				EndIf;
			EndIf;
		EndIf;
	EndIf;
КонецПроцедуры //ChargingFolioParametersOnChangeAtServer

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура DescriptionOnChange(pItem)
	DescriptionOnChangeAtServer();
КонецПроцедуры //DescriptionOnChange

//-----------------------------------------------------------------------------
&AtServer
Процедура DescriptionOnChangeAtServer(pObj = Неопределено)
	//Check parameters
	vObj = pObj;
	vUseParameterObject = True;
	If pObj = Неопределено Тогда
		//Get object value
		vObj = FormAttributeToValue("Object");
		vUseParameterObject = False;
	EndIf;
	If vObj.ЭтоНовый() Тогда
		If НЕ IsBlankString(vObj.Description) And IsBlankString(vObj.LegacyName) Тогда
			vObj.ЮрИмя = СокрЛП(vObj.Description);
		EndIf;
	EndIf;
	If НЕ vUseParameterObject Тогда
		//Set object value
		ValueToFormAttribute(vObj, "Object");
	EndIf;
КонецПроцедуры //DescriptionOnChangeAtServer
//
////-----------------------------------------------------------------------------
//&НаКлиенте
//Процедура LegacyAddressStartChoice(pItem, pChoiceData, pStandardProcessing)
//	pStandardProcessing = False;
//	vFrm = ПолучитьФорму("CommonForm.упрВводАдреса",,pItem);
//	vFrm.Address = СокрЛП(Object.LegacyAddress);
//	vFrm.AddressType = "";
//	vAddress = vFrm.DoModal();
//	If vAddress <> Неопределено Тогда
//		Object.LegacyAddress = vAddress;
//	EndIf;
//КонецПроцедуры //LegacyAddressStartChoice

////-----------------------------------------------------------------------------
//&НаКлиенте
//Процедура PostAddressStartChoice(pItem, pChoiceData, pStandardProcessing)
//	pStandardProcessing = False;
//	vFrm = ПолучитьФорму("CommonForm.упрВводАдреса",,pItem);
//	vFrm.Address = СокрЛП(Object.PostAddress);
//	vFrm.AddressType = "";
//	vAddress = vFrm.DoModal();
//	If vAddress <> Неопределено Тогда
//		Object.PostAddress = vAddress;
//	EndIf;
//КонецПроцедуры //PostAddressStartChoice

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура DiscountTypeOnChange(pItem)
	DiscountTypeOnChangeAtServer();
КонецПроцедуры //DiscountTypeOnChange

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
	
	
	If НЕ vUseParameterObject Тогда
		//Set object value
		ValueToFormAttribute(vObj, "Object");
	EndIf;
КонецПроцедуры //DiscountTypeOnChangeAtServer

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура DiscountConfirmationTextOnChange(pItem)
	DiscountTypeOnChangeAtServer();
КонецПроцедуры //DiscountConfirmationTextOnChange

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура RoomRatesApprovedOnChange(pItem)
	RoomRatesApprovedAppearance();
КонецПроцедуры //RoomRatesApprovedOnChange

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура SetAsDefault(pCommand)
	vCurData = Items.TableBoxBankAccounts.CurrentData;
	If vCurData <> Неопределено Тогда
		Object.BankAccount = vCurData.Ref;
	EndIf;
КонецПроцедуры //SetAsDefault

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура BeforeWrite(pCancel, pWriteParameters)
	// Save state
	WasModified = ЭтаФорма.Modified;
	vResultMessage = BeforeWriteServer(pCancel);
	If НЕ IsBlankString(vResultMessage) Тогда
		If DoQueryBox(vResultMessage, QuestionDialogMode.OKCancel, , DialogReturnCode.Cancel) = DialogReturnCode.Cancel Тогда
			pCancel = True;
		EndIf;
	EndIf;
КонецПроцедуры //BeforeWrite

//-----------------------------------------------------------------------------
&AtServer
Function BeforeWriteServer(rCancel, pObj = Неопределено)
	//Check paramters
	vObj = pObj;
	//vUseParamterObject = True;
	If pObj = Неопределено Тогда
		//Get object value
		vObj = FormAttributeToValue("Object");
		//vUseParamterObject = False;
	EndIf;
	// Save state
	WasNew = vObj.ЭтоНовый();
	// Check Контрагент attributes
	vMessage = "";
	vAttributeInErr = "";
	rCancel = vObj.pmCheckCustomerAttributes(vMessage, vAttributeInErr);
	If rCancel Тогда
		WriteLogEvent(NStr("en='Catalog.Write';ru='Справочник.Запись';de='Catalog.Write'"), EventLogLevel.Warning, vObj.Metadata(), vObj.Ref, NStr(vMessage));
		Message(NStr(vMessage));
		If НЕ IsBlankString(vAttributeInErr) Тогда
			ЭтаФорма.CurrentItem = ЭтаФорма.Items[vAttributeInErr];
		EndIf;
		// Reset write in form flag
		WasWriteInForm = False;
	Else
		// Check ГруппаНомеров rates
		i = 0;
		While i < vObj.Тарифы.Count() Do
			vRRRow = vObj.Тарифы.Get(i);
			If НЕ ЗначениеЗаполнено(vRRRow.Тариф) Тогда
				vObj.Тарифы.Delete(i);
			Else
				i = i + 1;
			EndIf;
		EndDo;
	EndIf;
	// Check ИНН for the Контрагент
	If НЕ rCancel Тогда
		If НЕ IsBlankString(vObj.TIN) Тогда
			vQry = New Query();
			vQry.Text = 
			"SELECT
			|	Контрагенты.Ref AS Контрагент
			|FROM
			|	Catalog.Контрагенты AS Customers
			|WHERE
			|	Контрагенты.ИНН = &qTIN
			|	AND Контрагенты.DeletionMark = FALSE
			|ORDER BY
			|	Контрагенты.CreateDate";
			vQry.SetParameter("qTIN", СокрЛП(vObj.TIN));
			vRes = vQry.Execute().Unload();
			vNumberOfCustomers = vRes.Count();
			If НЕ WasNew Тогда
				For Each vResRow In vRes Do
					If vResRow.Контрагент = vObj.Ref Тогда
						vNumberOfCustomers = vNumberOfCustomers - 1;
					EndIf;
				EndDo;
			EndIf;
			If vNumberOfCustomers > 0 Тогда
				vMessage = NStr("ru='" + vNumberOfCustomers + " контрагент(ов) найдено с тем же ИНН (" + СокрЛП(vObj.TIN) + ")!';
				                |de='" + vNumberOfCustomers + " Контрагент(s) with the same ИНН (" + СокрЛП(vObj.TIN) + ") are found!';
				                |en='" + vNumberOfCustomers + " Контрагент(s) with the same ИНН (" + СокрЛП(vObj.TIN) + ") are found!'");
				If НЕ WasNew Тогда
					For Each vResRow In vRes Do
						If vResRow.Контрагент <> vObj.Ref Тогда
							vMessage = vMessage + Chars.LF + СокрЛП(vResRow.Контрагент.Description) + " (" + NStr("en='Code: ';ru='Код: ';de='Code: '") + СокрЛП(vResRow.Контрагент.Code) + ")";
						EndIf;
					EndDo;
				EndIf;
				//Return
				Return vMessage;
			EndIf;
		EndIf;
	EndIf;
	//Return
	Return "";
EndFunction //BeforeWriteServer


