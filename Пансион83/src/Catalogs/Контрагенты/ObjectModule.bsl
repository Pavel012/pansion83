//-----------------------------------------------------------------------------
Процедура BeforeWrite(Cancel)
	Description = Upper(СокрЛП(Description));
КонецПроцедуры //BeforeWrite

//-----------------------------------------------------------------------------
Процедура pmCreateFolios(pHotel, pDate) Экспорт
	vChargingRules = Неопределено;
	vParent = Parent;
	While ЗначениеЗаполнено(vParent) Do
		If vParent.ChargingRules.Count() > 0 Тогда
			vChargingRules = vParent.ChargingRules.Unload();
			Break;
		EndIf;
		vParent = vParent.Parent;
	EndDo;
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
		
		vFolioObj.Гостиница = Справочники.Hotels.EmptyRef();
		vFolioObj.Контрагент = ThisObject.Ref;
		vFolioObj.Договор = Contract;
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
			
			vFolioObj.Гостиница = Справочники.Hotels.EmptyRef();
			vFolioObj.Контрагент = ThisObject.Ref;
			vFolioObj.Договор = Contract;
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
	Автор = ПараметрыСеанса.ТекПользователь;
	CreateDate = CurrentDate();
	// Initialization based on hotel
	vHotel = ПараметрыСеанса.ТекущаяГостиница;
	If ЗначениеЗаполнено(vHotel) Тогда
		// Language
		If НЕ ЗначениеЗаполнено(Language) Тогда
			Language = vHotel.Language;
		EndIf;
		// Currency
		If НЕ ЗначениеЗаполнено(AccountingCurrency) Тогда
			AccountingCurrency = vHotel.ВалютаЛицСчета;
		EndIf;
		// Planned payment method
		PlannedPaymentMethod = vHotel.PlannedPaymentMethod;
		// Default charging rules
		If vHotel.AlwaysCreateDefaultChargingRulesForNewCustomers Тогда
			pmCreateFolios(vHotel, CreateDate);
		Else
			vParent = Parent;
			While ЗначениеЗаполнено(vParent) Do
				If vParent.AlwaysCreateDefaultChargingRulesForNewCustomers Тогда
					pmCreateFolios(vHotel, CreateDate);
					Break;
				EndIf;
				vParent = vParent.Parent;
			EndDo;
		EndIf;
		// Do not post commission to Контрагент accounts
		DoNotPostCommission = vHotel.DoNotPostCommission;
	EndIf;
	// Fill Контрагент type
	If ЗначениеЗаполнено(Parent) And ЗначениеЗаполнено(Parent.ТипКонтрагента) Тогда
		ТипКонтрагента = Parent.ТипКонтрагента;
	EndIf;
КонецПроцедуры //pmFillAttributesWithDefaultValues

//-----------------------------------------------------------------------------
// Fill planned payment method from charging rules
//-----------------------------------------------------------------------------
Процедура pmFillPlannedPaymentMethodFromChargingRules() Экспорт
	If ChargingRules.Count() > 0 Тогда
		vFirstCRRow = ChargingRules.Get(0);
		If ЗначениеЗаполнено(vFirstCRRow.ChargingFolio) And ЗначениеЗаполнено(vFirstCRRow.ChargingFolio.PaymentMethod) Тогда
			If PlannedPaymentMethod <> vFirstCRRow.ChargingFolio.PaymentMethod Тогда
				PlannedPaymentMethod = vFirstCRRow.ChargingFolio.PaymentMethod;
			EndIf;
		Else
			If ЗначениеЗаполнено(ПараметрыСеанса.ТекущаяГостиница) Тогда
				If ЗначениеЗаполнено(ПараметрыСеанса.ТекущаяГостиница.PlannedPaymentMethod) Тогда
					If PlannedPaymentMethod <> ПараметрыСеанса.ТекущаяГостиница.PlannedPaymentMethod Тогда
						PlannedPaymentMethod = ПараметрыСеанса.ТекущаяГостиница.PlannedPaymentMethod;
					EndIf;
				EndIf;
			EndIf;
		EndIf;
	Else
		If ЗначениеЗаполнено(ПараметрыСеанса.ТекущаяГостиница) Тогда
			If ЗначениеЗаполнено(ПараметрыСеанса.ТекущаяГостиница.PlannedPaymentMethod) Тогда
				If PlannedPaymentMethod <> ПараметрыСеанса.ТекущаяГостиница.PlannedPaymentMethod Тогда
					PlannedPaymentMethod = ПараметрыСеанса.ТекущаяГостиница.PlannedPaymentMethod;
				EndIf;
			EndIf;
		EndIf;
	EndIf;
КонецПроцедуры //pmFillPlannedPaymentMethodFromChargingRules

//-----------------------------------------------------------------------------
Function pmLoadCustomerContactPersonsList() Экспорт
	// Load Контрагент contact persons list
	vCPList = New СписокЗначений();
	If НЕ IsBlankString(ContactPerson) Тогда
		vCPList.Add(TrimR(ContactPerson));
	EndIf;
	For Each vCP In ContactPersons Do
		If НЕ IsBlankString(vCP.ContactPerson) Тогда
			If vCPList.FindByValue(TrimR(vCP.ContactPerson)) = Неопределено Тогда
				vCPList.Add(TrimR(vCP.ContactPerson));
			EndIf;
		EndIf;
	EndDo;
	Return vCPList;
EndFunction //pmLoadCustomerContactPersonsList

//-----------------------------------------------------------------------------
Function pmCheckCustomerAttributes(pMessage, pAttributeInErr) Экспорт
	vHasErrors = False;
	pMessage = "";
	pAttributeInErr = "";
	vMsgTextRu = "";
	vMsgTextEn = "";
	If IsBlankString(Description) Тогда
		vHasErrors = True; 
		vMsgTextRu = vMsgTextRu + "Реквизит <Наименование> должен быть заполнен!" + Chars.LF;
		vMsgTextEn = vMsgTextEn + "<Description> attribute should be filled!" + Chars.LF;
		pAttributeInErr = ?(pAttributeInErr = "", "Description", pAttributeInErr);
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
EndFunction //pmCheckCustomerAttributes

//-----------------------------------------------------------------------------
Процедура FillCChgAttributes(pCChgRec, pPeriod, pUser)
	FillPropertyValues(pCChgRec, ThisObject);
	
	pCChgRec.Period = pPeriod;
	pCChgRec.Контрагент = ThisObject.Ref;
	pCChgRec.User = pUser;
	
	// Store tabular parts
	vChargingRules = New ValueStorage(ChargingRules.Unload());
	pCChgRec.ChargingRules = vChargingRules;
	vContactPersons = New ValueStorage(ContactPersons.Unload());
	pCChgRec.ContactPersons = vContactPersons;
	vRoomRates = New ValueStorage(RoomRates.Unload());
	pCChgRec.Тарифы = vRoomRates;
КонецПроцедуры //FillCChgAttributes

//-----------------------------------------------------------------------------
Процедура pmWriteToCustomerChangeHistory(pPeriod, pUser) Экспорт
	// Get channges description
	vChanges = ThisObject;
	If НЕ IsBlankString(vChanges) Тогда
		vCChgRec = InformationRegisters.ИсторияИзмКонтрагентов.CreateRecordManager();
		
		FillCChgAttributes(vCChgRec, pPeriod, pUser);
		vCChgRec.Changes = vChanges;
		
		// Write record
		vCChgRec.Write(True);
	EndIf;
КонецПроцедуры //pmWriteToCustomerChangeHistory

//-----------------------------------------------------------------------------
Function pmGetPreviousObjectState(pPeriod) Экспорт
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	*
	|FROM
	|	InformationRegister.ИсторияИзмКонтрагентов.SliceLast(&qPeriod, Контрагент = &qRef) AS ИсторияИзмКонтрагентов";
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
	vContactPersons = pChgRec.ContactPersons.Get();
	If vContactPersons <> Неопределено Тогда
		ContactPersons.Load(vContactPersons);
	Else
		ContactPersons.Clear();
	EndIf;
	vRoomRates = pChgRec.Тарифы.Get();
	If vRoomRates <> Неопределено Тогда
		RoomRates.Load(vRoomRates);
	Else
		RoomRates.Clear();
	EndIf;
КонецПроцедуры //pmRestoreAttributesFromHistory

//-----------------------------------------------------------------------------
Процедура OnSetNewCode(pStandardProcessing, pPrefix)
	vPrefix = "";
	If ЗначениеЗаполнено(ПараметрыСеанса.ТекущаяГостиница) Тогда
		vPrefix = СокрЛП(ПараметрыСеанса.ТекущаяГостиница.GetObject().pmGetPrefix());
	EndIf;
	If vPrefix <> "" Тогда
		pPrefix = vPrefix;
	EndIf;
КонецПроцедуры //OnSetNewCode

//-----------------------------------------------------------------------------
// Counts Контрагент guests check-ins
//-----------------------------------------------------------------------------
Function pmCountNumberOfCheckIns() Экспорт
	vNumberOfCheckIns = 0;
	// Run query
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	SUM(ISNULL(ЗагрузкаНомеров.ЗаездГостей, 0)) AS ЗаездГостей,
	|	ЗагрузкаНомеров.Контрагент
	|FROM
	|	AccumulationRegister.ЗагрузкаНомеров AS ЗагрузкаНомеров
	|WHERE
	|	ЗагрузкаНомеров.Контрагент = &qCustomer
	|	AND ЗагрузкаНомеров.IsAccommodation
	|GROUP BY
	|	ЗагрузкаНомеров.Контрагент";
	vQry.SetParameter("qCustomer", Ref);
	vQryRes = vQry.Execute().Choose();
	While vQryRes.Next() Do
		If vQryRes.ЗаездГостей <> NULL Тогда
			vNumberOfCheckIns = vQryRes.ЗаездГостей;
		EndIf;
		Break;
	EndDo;
	Return vNumberOfCheckIns;
EndFunction //pmCountNumberOfCheckIns

//-----------------------------------------------------------------------------
// Count Контрагент guests nights
//-----------------------------------------------------------------------------
Function pmCountNumberOfNights() Экспорт
	vNumberOfNights = 0;
	// Run query
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	SUM(ISNULL(SalesTurnovers.GuestDaysTurnover, 0)) AS GuestDaysTurnover
	|FROM
	|	AccumulationRegister.Продажи.Turnovers(, , Period, Контрагент = &qCustomer) AS SalesTurnovers";
	vQry.SetParameter("qCustomer", Ref);
	vQryRes = vQry.Execute().Choose();
	While vQryRes.Next() Do
		If vQryRes.GuestDaysTurnover <> NULL Тогда
			vNumberOfNights = vQryRes.GuestDaysTurnover;
		EndIf;
		Break;
	EndDo;
	Return vNumberOfNights;
EndFunction //pmCountNumberOfNights

//-----------------------------------------------------------------------------
// Get Контрагент revenue statistics
//-----------------------------------------------------------------------------
Function pmGetCustomerRevenueStatistics() Экспорт
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	SalesTurnovers.Валюта,
	|	SUM(ISNULL(SalesTurnovers.SalesTurnover, 0)) AS SalesTurnover,
	|	SUM(ISNULL(SalesTurnovers.SalesWithoutVATTurnover, 0)) AS SalesWithoutVATTurnover,
	|	SUM(ISNULL(SalesTurnovers.RoomRevenueTurnover, 0)) AS RoomRevenueTurnover,
	|	SUM(ISNULL(SalesTurnovers.RoomRevenueWithoutVATTurnover, 0)) AS RoomRevenueWithoutVATTurnover
	|FROM
	|	AccumulationRegister.Продажи.Turnovers(, , Period, Контрагент = &qCustomer) AS SalesTurnovers
	|
	|GROUP BY
	|	SalesTurnovers.Валюта
	|
	|ORDER BY
	|	SalesTurnovers.Валюта.ПорядокСортировки";
	vQry.SetParameter("qCustomer", Ref);
	vQryRes = vQry.Execute().Unload();
	Return vQryRes;
EndFunction //pmGetCustomerRevenueStatistics

//-----------------------------------------------------------------------------
// Get Контрагент reservation statistics
//-----------------------------------------------------------------------------
Function pmGetCustomerReservationStatistics() Экспорт
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	Бронирование.ReservationStatus,
	|	COUNT(*) AS Count
	|FROM
	|	Document.Бронирование AS Бронирование
	|WHERE
	|	Бронирование.Posted
	|	AND Бронирование.Контрагент = &qCustomer
	|	AND Бронирование.ReservationStatus <> Бронирование.Гостиница.CheckInReservationStatus
	|GROUP BY
	|	Бронирование.ReservationStatus
	|ORDER BY
	|	Бронирование.ReservationStatus.ПорядокСортировки";
	vQry.SetParameter("qCustomer", Ref);
	vQryRes = vQry.Execute().Unload();
	Return vQryRes;
EndFunction //pmGetCustomerReservationStatistics

//-----------------------------------------------------------------------------
// Get Контрагент last accommodation
//-----------------------------------------------------------------------------
Function pmGetCustomerLastAccommodation() Экспорт
	vLastAcc = Неопределено;
	// Run query
	vQry = New Query();
	vQry.Text = 
	"SELECT TOP 1
	|	Размещение.Ref
	|FROM
	|	Document.Размещение AS Размещение
	|WHERE
	|	Размещение.Posted
	|	AND Размещение.Контрагент = &qCustomer
	|	AND Размещение.СтатусРазмещения.ЭтоВыезд
	|	AND Размещение.СтатусРазмещения.IsActive
	|ORDER BY
	|	Размещение.PointInTime DESC";
	vQry.SetParameter("qCustomer", Ref);
	vQryRes = vQry.Execute().Choose();
	While vQryRes.Next() Do
		vLastAcc = vQryRes.Ref;
		Break;
	EndDo;
	Return vLastAcc;
EndFunction //pmGetCustomerLastAccommodation

//-----------------------------------------------------------------------------
// Get Контрагент first accommodation
//-----------------------------------------------------------------------------
Function pmGetCustomerFirstAccommodation() Экспорт
	vFirstAcc = Неопределено;
	// Run query
	vQry = New Query();
	vQry.Text = 
	"SELECT TOP 1
	|	Размещение.Ref
	|FROM
	|	Document.Размещение AS Размещение
	|WHERE
	|	Размещение.Posted
	|	AND Размещение.Контрагент = &qCustomer
	|	AND Размещение.СтатусРазмещения.ЭтоЗаезд
	|	AND Размещение.СтатусРазмещения.IsActive
	|ORDER BY
	|	Размещение.PointInTime";
	vQry.SetParameter("qCustomer", Ref);
	vQryRes = vQry.Execute().Choose();
	While vQryRes.Next() Do
		vFirstAcc = vQryRes.Ref;
		Break;
	EndDo;
	Return vFirstAcc;
EndFunction //pmGetCustomerFirstAccommodation

//-----------------------------------------------------------------------------
Процедура OnCopy(pCopiedObject)
	ExternalCode = "";
	// Author and date
	Автор = ПараметрыСеанса.ТекПользователь;
	CreateDate = CurrentDate();
КонецПроцедуры //OnCopy
