//-----------------------------------------------------------------------------
Процедура pmCreateFolios(pHotel, pDate) Экспорт
	vChargingRules = Неопределено;
	If ЗначениеЗаполнено(Owner) And ЗначениеЗаполнено(Owner.Parent) Тогда
		If Owner.Parent.ChargingRules.Count() > 0 Тогда
			vChargingRules = Owner.Parent.ChargingRules.Unload();
		EndIf;
	EndIf;
	If vChargingRules = Неопределено Тогда
		If ЗначениеЗаполнено(pHotel) Тогда
			If pHotel.CustomerChargingRules.Count() > 0 Тогда
				vChargingRules = pHotel.CustomerChargingRules.Unload();
			EndIf;
		Else
			Return;
		EndIf;
	EndIf;
	// Check list of template rules
	If vChargingRules = Неопределено Тогда
		// Create new folio and take parameters from the hotel
		vFolioObj = Documents.СчетПроживания.CreateDocument();
		
		vFolioObj.Гостиница = Справочники.Гостиницы.EmptyRef();
		vFolioObj.Контрагент = Owner;
		vFolioObj.Договор = Ref;
		If ЗначениеЗаполнено(pHotel) And ЗначениеЗаполнено(pHotel.PaymentMethodForCustomerPayments) Тогда
			vFolioObj.СпособОплаты = pHotel.PaymentMethodForCustomerPayments;
		ElsIf ЗначениеЗаполнено(PlannedPaymentMethod) Тогда
			vFolioObj.СпособОплаты = PlannedPaymentMethod;
		EndIf;
		If ЗначениеЗаполнено(AccountingCurrency) Тогда
			vFolioObj.ВалютаЛицСчета = AccountingCurrency;
		EndIf;
		vFolioObj.Write();
		
		// Add it to the charging rules
		vCR = ChargingRules.Add();
		vCR.СпособРазделенияОплаты = Перечисления.ChargingRuleTypes.InRate;
		vCR.ChargingFolio = vFolioObj.Ref;
	Else
		For Each vRule In vChargingRules Do
			// Create new folio from template
			vFolioObj = Documents.СчетПроживания.CreateDocument();
			
			vFolioObj.Гостиница = Справочники.Гостиницы.EmptyRef();
			vFolioObj.Контрагент = Owner;
			vFolioObj.Договор = Ref;
			If ЗначениеЗаполнено(AccountingCurrency) Тогда
				vFolioObj.ВалютаЛицСчета = AccountingCurrency;
			EndIf;
			vFolioObj.IsMaster = vRule.ChargingFolio.IsMaster;
			vFolioObj.Write();
			
			// Add it to the charging rules
			vCR = ChargingRules.Add();
			FillPropertyValues(vCR, vRule, , "ChargingFolio");
			vCR.ChargingFolio = vFolioObj.Ref;
		EndDo;
	EndIf;
КонецПроцедуры //pmCreateFolios

//-----------------------------------------------------------------------------
Процедура pmFillAttributesWithDefaultValues() Экспорт
	// Author and date
	Author = ПараметрыСеанса.ТекПользователь;
	CreateDate = CurrentDate();
	// Initialization based on hotel
	vHotel = ПараметрыСеанса.ТекущаяГостиница;
	If ЗначениеЗаполнено(vHotel) Тогда
		// Currency
		If НЕ ЗначениеЗаполнено(AccountingCurrency) Тогда
			AccountingCurrency = vHotel.ВалютаЛицСчета;
		EndIf;
		// Planned payment method
		PlannedPaymentMethod = vHotel.PlannedPaymentMethod;
		// Default charging rules
		If vHotel.AlwaysCreateDefaultChargingRulesForNewCustomers Тогда
			pmCreateFolios(vHotel, CreateDate);
		ElsIf ЗначениеЗаполнено(Owner) Тогда
			vParent = Owner.Parent;
			While ЗначениеЗаполнено(vParent) Do
				If vParent.AlwaysCreateDefaultChargingRulesForNewCustomers Тогда
					pmCreateFolios(vHotel, CreateDate);
					Break;
				EndIf;
				vParent = vParent.Parent;
			EndDo;
		EndIf;
	EndIf;
КонецПроцедуры //pmFillAttributesWithDefaultValues

//-----------------------------------------------------------------------------
Function pmCheckContractAttributes(pMessage, pAttributeInErr) Экспорт
	vHasErrors = False;
	pMessage = "";
	pAttributeInErr = "";
	vMsgTextRu = "";
	vMsgTextEn = "";
	If IsBlankString(Code) Тогда
		vHasErrors = True; 
		vMsgTextRu = vMsgTextRu + "Реквизит <Код> должен быть заполнен!" + Chars.LF;
		vMsgTextEn = vMsgTextEn + "<Code> attribute should be filled!" + Chars.LF;
		pAttributeInErr = ?(pAttributeInErr = "", "Code", pAttributeInErr);
	EndIf;
	If IsBlankString(Description) Тогда
		vHasErrors = True; 
		vMsgTextRu = vMsgTextRu + "Реквизит <Наименование> должен быть заполнен!" + Chars.LF;
		vMsgTextEn = vMsgTextEn + "<Description> attribute should be filled!" + Chars.LF;
		pAttributeInErr = ?(pAttributeInErr = "", "Description", pAttributeInErr);
	EndIf;
	If НЕ ЗначениеЗаполнено(Owner) Тогда
		vHasErrors = True; 
		vMsgTextRu = vMsgTextRu + "Реквизит <Контрагент> должен быть заполнен!" + Chars.LF;
		vMsgTextEn = vMsgTextEn + "<Контрагент> attribute should be filled!" + Chars.LF;
		pAttributeInErr = ?(pAttributeInErr = "", "Owner", pAttributeInErr);
	EndIf;
	If НЕ ЗначениеЗаполнено(AccountingCurrency) Тогда
		vHasErrors = True; 
		vMsgTextRu = vMsgTextRu + "Реквизит <Валюта взаиморасчетов> должен быть заполнен!" + Chars.LF;
		vMsgTextEn = vMsgTextEn + "<Accounting Валюта> attribute should be filled!" + Chars.LF;
		pAttributeInErr = ?(pAttributeInErr = "", "ВалютаРасчетов", pAttributeInErr);
	EndIf;
	If vHasErrors Тогда
		pMessage = "ru = '" + СокрЛП(vMsgTextRu) + "';" + "en = '" + СокрЛП(vMsgTextEn) + "';";
	EndIf;
	Return vHasErrors;
EndFunction //pmCheckContractAttributes

//-----------------------------------------------------------------------------


//-----------------------------------------------------------------------------


//-----------------------------------------------------------------------------
Function pmGetPreviousObjectState(pPeriod) Экспорт
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	*
	|FROM
	|	InformationRegister.ИсторияИзмРеквДоговоров.SliceLast(&qPeriod, Договор = &qRef) AS ИсторияИзмРеквДоговоров";
	vQry.SetParameter("qPeriod", pPeriod);
	vQry.SetParameter("qRef", Ref);
	vStates = vQry.Execute().Unload();
	If vStates.Count() > 0 Тогда
		Return vStates.Get(0);
	Else
		Return Неопределено;
	EndIf;
EndFunction //pmGetPreviousObjectState

//-----------------------------------------------------------------------------
Процедура pmRestoreAttributesFromHistory(pChgRec) Экспорт
	FillPropertyValues(ThisObject, pChgRec, , "Code, Description");
	If НЕ IsBlankString(pChgRec.Code) Тогда
		Code = pChgRec.Code;
	EndIf;
	If НЕ IsBlankString(pChgRec.Description) Тогда
		Description = pChgRec.Description;
	EndIf;
	// Restore tabular parts
	vChargingRules = pChgRec.ChargingRules.Get();
	If vChargingRules <> Неопределено Тогда
		ChargingRules.Load(vChargingRules);
	Else
		ChargingRules.Clear();
	EndIf;
	vRoomRates = pChgRec.Тарифы.Get();
	If vRoomRates <> Неопределено Тогда
		RoomRates.Load(vRoomRates);
	Else
		RoomRates.Clear();
	EndIf;
КонецПроцедуры //pmRestoreAttributesFromHistory

//-----------------------------------------------------------------------------
Процедура OnCopy(pCopiedObject)
	ExternalCode = "";
	// Author and date
	Author = ПараметрыСеанса.ТекПользователь;
	CreateDate = CurrentDate();
КонецПроцедуры //OnCopy

//-----------------------------------------------------------------------------
// Get characteristics
// Returns ValueTable 
//-----------------------------------------------------------------------------
Function pmGetLimitsAndConditions() Экспорт
	// Build and run query
	vQry = New Query;
	vQry.Text = 
	"SELECT
	|	LimitsAndSpecialConditions.Owner AS Договор,
	|	LimitsAndSpecialConditions.Гостиница,
	|	LimitsAndSpecialConditions.Characteristic,
	|	LimitsAndSpecialConditions.CharacteristicValue
	|FROM
	|	InformationRegister.LimitsAndSpecialConditions AS LimitsAndSpecialConditions
	|WHERE
	|	LimitsAndSpecialConditions.Owner = &qContract
	|	AND (LimitsAndSpecialConditions.Гостиница = &qHotel
	|			OR LimitsAndSpecialConditions.Гостиница = &qEmptyHotel
	|			OR LimitsAndSpecialConditions.Гостиница = &qCurrentHotel)
	|	AND LimitsAndSpecialConditions.Characteristic.DeletionMark = FALSE
	|
	|ORDER BY
	|	LimitsAndSpecialConditions.Characteristic.Code";
	vQry.SetParameter("qContract", Ref);
	vQry.SetParameter("qHotel", Гостиница);
	vQry.SetParameter("qEmptyHotel", Справочники.Гостиницы.EmptyRef());
	vQry.SetParameter("qCurrentHotel", ПараметрыСеанса.ТекущаяГостиница);
	vChars = vQry.Execute().Unload();
	Return vChars;
EndFunction //pmGetLimitsAndConditions

//-----------------------------------------------------------------------------
// Get characteristic value
// Returns Value
//-----------------------------------------------------------------------------
Function pmGetLimitsAndConditionsValue(pCharacteristic, pHotel) Экспорт
	vCharValue = Неопределено;
	// Build and run query
	vQry = New Query;
	vQry.Text = 
	"SELECT
	|	LimitsAndSpecialConditions.CharacteristicValue
	|FROM
	|	InformationRegister.LimitsAndSpecialConditions AS LimitsAndSpecialConditions
	|WHERE
	|	LimitsAndSpecialConditions.Owner = &qContract
	|	AND (LimitsAndSpecialConditions.Гостиница = &qHotel OR LimitsAndSpecialConditions.Гостиница = &qEmptyHotel)
	|	AND LimitsAndSpecialConditions.Characteristic = &qCharacteristic
	|
	|ORDER BY
	|	LimitsAndSpecialConditions.Characteristic.Code";
	vQry.SetParameter("qContract", Ref);
	vQry.SetParameter("qHotel", pHotel);
	vQry.SetParameter("qEmptyHotel", Справочники.Гостиницы.EmptyRef());
	vQry.SetParameter("qCharacteristic", pCharacteristic);
	vChars = vQry.Execute().Choose();
	While vChars.Next() Do
		vCharValue = vChars.CharacteristicValue;
		Break;
	EndDo;
	Return vCharValue;
EndFunction //pmGetLimitsAndConditionsValue

//-----------------------------------------------------------------------------
Процедура pmSaveLimitsAndConditionsValue(pCharacteristic, pCharacteristicValue, pHotel) Экспорт
	vCharsMgr = InformationRegisters.LimitsAndSpecialConditions.CreateRecordManager();
	vCharsMgr.Owner = Ref;
	vCharsMgr.Characteristic = pCharacteristic;
	vCharsMgr.Гостиница = pHotel;
	vCharsMgr.Read();
	If vCharsMgr.Selected() Тогда
		vCharsMgr.Owner = Ref;
		vCharsMgr.Characteristic = pCharacteristic;
		vCharsMgr.CharacteristicValue = pCharacteristicValue;
		vCharsMgr.Гостиница = pHotel;
		vCharsMgr.Write();
	EndIf;
КонецПроцедуры //pmSaveLimitsAndConditionsValue
