//-----------------------------------------------------------------------------
Function pmGetClientAge(pDate) Экспорт
	If НЕ ЗначениеЗаполнено(ДатаРождения) Тогда
		Return 0;
	EndIf;
	If НЕ ЗначениеЗаполнено(pDate) Тогда
		Return 0;
	EndIf;
	vAge = Year(pDate) - Year(ДатаРождения) - 1;
	vBirthDateDayOfYear = DayOfYear(ДатаРождения);
	vDateDayOfYear = DayOfYear(pDate);
	If vDateDayOfYear >= vBirthDateDayOfYear Тогда
		vAge = vAge + 1;
	EndIf;
	If vAge < 0 Тогда
		vAge = 0;
	EndIf;
	Return vAge;
EndFunction //pmGetClientAge

//-----------------------------------------------------------------------------
Function pmGetClientAgeRange(pAge = -1) Экспорт
	If НЕ ЗначениеЗаполнено(ДатаРождения) Тогда
		Return Справочники.ВозрастныеГруппы.AgeUndefined;
	EndIf;
	vAge = Age;
	If pAge <> -1 Тогда
		vAge = pAge;
	EndIf;
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	ВозрастныеГруппы.Ref
	|FROM
	|	Catalog.ВозрастныеГруппы AS AgeRanges
	|WHERE
	|	(NOT ВозрастныеГруппы.DeletionMark)
	|	AND ВозрастныеГруппы.FromAge <= &qAge
	|	AND ВозрастныеГруппы.ToAge >= &qAge
	|
	|ORDER BY
	|	ВозрастныеГруппы.FromAge";
	vQry.SetParameter("qAge", vAge);
	vQryRes = vQry.Execute().Unload();
	If vQryRes.Count() > 0 Тогда
		vQryResRow = vQryRes.Get(0);
		Return vQryResRow.Ref;
	Else
		Return Справочники.ВозрастныеГруппы.AgeUndefined;
	EndIf;
EndFunction //pmGetClientAgeRange

//-------------------------
Function pmGetPreviousObjectState(pPeriod) Экспорт
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	*
	|FROM
	|	InformationRegister.ИсторияИзмКлиентов.SliceLast(&qPeriod, Клиент = &qRef) AS ИсторияИзмКлиентов";
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
КонецПроцедуры //pmRestoreAttributesFromHistory

//-----------------------------------------------------------------------------
Процедура BeforeWrite(pCancel)
	If ThisObject.DataExchange.Load Тогда
		Return;
	EndIf;
	If НЕ IsFolder Тогда
		Description = pmGetDescription();
		FullName = pmGetFullName();
		// Phone
		//Phone = SMS.GetValidPhoneNumber(Phone);
		// Analitical parameters
		Age = pmGetClientAge(CurrentDate());
		
		// Identity document data presentation
		IdentityDocumentPresentation = СокрЛП(СокрЛП(IdentityDocumentType) + " " + 
		                                       СокрЛП(IdentityDocumentSeries) + " " + 
									           СокрЛП(IdentityDocumentNumber) + " " + 
											   ?(IsBlankString(IdentityDocumentUnitCode), "", СокрЛП(IdentityDocumentUnitCode) + " ") + 
									           ?(IsBlankString(IdentityDocumentIssuedBy), "", СокрЛП(IdentityDocumentIssuedBy) + " ") + 
									           ?(ЗначениеЗаполнено(IdentityDocumentIssueDate), Format(IdentityDocumentIssueDate, "DF=dd.MM.yyyy"), ""));
	EndIf;
КонецПроцедуры //BeforeWrite

//-----------------------------------------------------------------------------


//-----------------------------------------------------------------------------
Процедура pmCreateFolios(pHotel, pDate) Экспорт
	vChargingRules = Неопределено;
	If ЗначениеЗаполнено(pHotel) Тогда
		If pHotel.ClientChargingRules.Count() > 0 Тогда
			vChargingRules = pHotel.ClientChargingRules.Unload();
		EndIf;
	Else
		Return;
	EndIf;
	// Check list of template rules
	If vChargingRules = Неопределено Тогда
		// Create new folio and take parameters from the hotel
		vFolioObj = Documents.СчетПроживания.CreateDocument();
		
		vFolioObj.Гостиница = Справочники.Гостиницы.EmptyRef();
		vFolioObj.Клиент = ThisObject.Ref;
		vFolioObj.Write();
		
		// Add it to the charging rules
		vCR = ChargingRules.Add();
		vCR.СпособРазделенияОплаты = Перечисления.ChargingRuleTypes.Any;
		vCR.ChargingFolio = vFolioObj.Ref;
	Else
		For Each vRule In vChargingRules Do
			vIsTemplate = True;
			vTemplateFolio = vRule.ChargingFolio;
			If ЗначениеЗаполнено(vTemplateFolio) Тогда
				vIsTemplate = НЕ vTemplateFolio.IsMaster;
			EndIf;
			If vIsTemplate Тогда
				// Create new folio from template
				vFolioObj = Documents.СчетПроживания.CreateDocument();
				
				vFolioObj.Гостиница = Справочники.Гостиницы.EmptyRef();
				vFolioObj.Клиент = ThisObject.Ref;
				vFolioObj.Write();
				
				// Add it to the charging rules
				vCR = ChargingRules.Add();
				FillPropertyValues(vCR, vRule, , "ChargingFolio");
				vCR.ChargingFolio = vFolioObj.Ref;
			Else
				// Copy charging rule
				vCR = ChargingRules.Add();
				FillPropertyValues(vCR, vRule);
			EndIf;
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
		// Гражданство
		//If НЕ ЗначениеЗаполнено(Гражданство) Тогда
		//	Гражданство = vHotel.Гражданство;
		//EndIf;
		// Language
		//If НЕ ЗначениеЗаполнено(Language) Тогда
		//	Language = vHotel.Language;
		//EndIf;
		// Identity document
		If НЕ ЗначениеЗаполнено(IdentityDocumentType) Тогда
			IdentityDocumentType = vHotel.IdentityDocumentType;
		EndIf;
		// Default charging rules
		If vHotel.AlwaysCreateDefaultChargingRulesForNewClients Тогда
			pmCreateFolios(vHotel, CreateDate);
		EndIf;
	EndIf;
КонецПроцедуры //pmFillAttributesWithDefaultValues

//-----------------------------------------------------------------------------
Function pmGetForeignerRegistryRecords(pDateFrom, pDateTo) Экспорт
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	ForeignerRegistryRecord.Ref AS ForeignerRegistryRecord
	|FROM
	|	Document.ForeignerRegistryRecord AS ForeignerRegistryRecord
	|WHERE
	|	ForeignerRegistryRecord.Клиент = &qClient
	|	AND ForeignerRegistryRecord.ДатаДок >= &qDateFrom
	|	AND ForeignerRegistryRecord.ДатаДок < &qDateTo
	|	AND ForeignerRegistryRecord.Posted
	|ORDER BY
	|	ForeignerRegistryRecord.ДатаДок";
	vQry.SetParameter("qClient", Ref);
	vQry.SetParameter("qDateFrom", pDateFrom);
	vQry.SetParameter("qDateTo", pDateTo);
	vRecords = vQry.Execute().Unload();
	Return vRecords;
EndFunction //pmGetForeignerRegistryRecords

//-----------------------------------------------------------------------------
Function pmGetDescription() Экспорт
	vDescription = Upper(СокрЛП(Фамилия));
	If НЕ IsBlankString(Имя) Тогда
		vDescription = vDescription + " " + Upper(Left(TrimL(Имя), 1)) + ".";
	EndIf;
	If НЕ IsBlankString(Отчество) Тогда
		vDescription = vDescription + " " + Upper(Left(TrimL(Отчество), 1)) + ".";
	EndIf;
	Return vDescription;
EndFunction //pmGetDescription

//-----------------------------------------------------------------------------
Function pmGetFullName() Экспорт
	Return СокрЛП(СокрЛП(Фамилия) + " " + СокрЛП(Имя) + " " + СокрЛП(Отчество));
EndFunction //pmGetFullName

//-----------------------------------------------------------------------------
// Counts guest check-ins
//-----------------------------------------------------------------------------
Function pmCountNumberOfCheckIns(pPeriodFrom = Неопределено, pPeriodTo = Неопределено, pUseResourcesPayedAsIndividual = False, pUseResourcesPayedByRackRates = False) Экспорт
	vNumberOfCheckIns = 0;
	// Run query
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	SUM(ISNULL(SalesTurnovers.GuestsCheckedInTurnover, 0)) AS ЗаездГостей
	|FROM
	|	AccumulationRegister.Продажи.Turnovers(
	|			&qPeriodFrom,
	|			&qPeriodTo,
	|			Period,
	|			Клиент = &qClient
	|				AND (NOT &qUseResourcesPayedAsIndividual
	|					OR &qUseResourcesPayedAsIndividual
	|						AND (Контрагент = &qEmptyCustomer
	|							OR Контрагент = Гостиница.IndividualsCustomer))
	|				AND (NOT &qUseResourcesPayedByRackRates
	|					OR &qUseResourcesPayedByRackRates
	|						AND ISNULL(Тариф.IsRackRate, FALSE))) AS SalesTurnovers";
	vQry.SetParameter("qClient", Ref);
	vQry.SetParameter("qPeriodFrom", pPeriodFrom);
	vQry.SetParameter("qPeriodTo", pPeriodTo);
	vQry.SetParameter("qUseResourcesPayedAsIndividual", pUseResourcesPayedAsIndividual);
	vQry.SetParameter("qUseResourcesPayedByRackRates", pUseResourcesPayedByRackRates);
	vQry.SetParameter("qEmptyCustomer", Справочники.Контрагенты.EmptyRef());
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
// Count guest nights
//-----------------------------------------------------------------------------
Function pmCountNumberOfNights(pPeriodFrom = Неопределено, pPeriodTo = Неопределено, pUseResourcesPayedAsIndividual = False, pUseResourcesPayedByRackRates = False) Экспорт
	vNumberOfNights = 0;
	// Run query
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	SUM(ISNULL(SalesTurnovers.GuestDaysTurnover, 0)) AS GuestDaysTurnover
	|FROM
	|	AccumulationRegister.Продажи.Turnovers(
	|			&qPeriodFrom,
	|			&qPeriodTo,
	|			Period,
	|			Клиент = &qClient
	|				AND (NOT &qUseResourcesPayedAsIndividual
	|					OR &qUseResourcesPayedAsIndividual
	|						AND (Контрагент = &qEmptyCustomer
	|							OR Контрагент = Гостиница.IndividualsCustomer))
	|				AND (NOT &qUseResourcesPayedByRackRates
	|					OR &qUseResourcesPayedByRackRates
	|						AND ISNULL(Тариф.IsRackRate, FALSE))) AS SalesTurnovers";
	vQry.SetParameter("qClient", Ref);
	vQry.SetParameter("qPeriodFrom", pPeriodFrom);
	vQry.SetParameter("qPeriodTo", pPeriodTo);
	vQry.SetParameter("qUseResourcesPayedAsIndividual", pUseResourcesPayedAsIndividual);
	vQry.SetParameter("qUseResourcesPayedByRackRates", pUseResourcesPayedByRackRates);
	vQry.SetParameter("qEmptyCustomer", Справочники.Контрагенты.EmptyRef());
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
// Get client revenue statistics
//-----------------------------------------------------------------------------
Function pmGetClientRevenueStatistics(pPeriodFrom = Неопределено, pPeriodTo = Неопределено, pUseResourcesPayedAsIndividual = False, pUseResourcesPayedByRackRates = False) Экспорт
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	SalesTurnovers.Валюта,
	|	SUM(ISNULL(SalesTurnovers.SalesTurnover, 0)) AS SalesTurnover,
	|	SUM(ISNULL(SalesTurnovers.SalesWithoutVATTurnover, 0)) AS SalesWithoutVATTurnover,
	|	SUM(ISNULL(SalesTurnovers.RoomRevenueTurnover, 0)) AS RoomRevenueTurnover,
	|	SUM(ISNULL(SalesTurnovers.RoomRevenueWithoutVATTurnover, 0)) AS RoomRevenueWithoutVATTurnover
	|FROM
	|	AccumulationRegister.Продажи.Turnovers(
	|			&qPeriodFrom,
	|			&qPeriodTo,
	|			Period,
	|			Клиент = &qClient
	|				AND (NOT &qUseResourcesPayedAsIndividual
	|					OR &qUseResourcesPayedAsIndividual
	|						AND (Контрагент = &qEmptyCustomer
	|							OR Контрагент = Гостиница.IndividualsCustomer))
	|				AND (NOT &qUseResourcesPayedByRackRates
	|					OR &qUseResourcesPayedByRackRates
	|						AND ISNULL(Тариф.IsRackRate, FALSE))) AS SalesTurnovers
	|
	|GROUP BY
	|	SalesTurnovers.Валюта
	|
	|ORDER BY
	|	SalesTurnovers.Валюта.ПорядокСортировки";
	vQry.SetParameter("qClient", Ref);
	vQry.SetParameter("qPeriodFrom", pPeriodFrom);
	vQry.SetParameter("qPeriodTo", pPeriodTo);
	vQry.SetParameter("qUseResourcesPayedAsIndividual", pUseResourcesPayedAsIndividual);
	vQry.SetParameter("qUseResourcesPayedByRackRates", pUseResourcesPayedByRackRates);
	vQry.SetParameter("qEmptyCustomer", Справочники.Контрагенты.EmptyRef());
	vQryRes = vQry.Execute().Unload();
	Return vQryRes;
EndFunction //pmGetClientRevenueStatistics

//-----------------------------------------------------------------------------
// Get client reservation statistics
//-----------------------------------------------------------------------------
Function pmGetClientReservationStatistics() Экспорт
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	Бронирование.ReservationStatus,
	|	COUNT(*) AS Count
	|FROM
	|	Document.Бронирование AS Бронирование
	|WHERE
	|	Бронирование.Posted
	|	AND Бронирование.Клиент = &qGuest
	|	AND Бронирование.ReservationStatus <> Бронирование.Гостиница.CheckInReservationStatus
	|GROUP BY
	|	Бронирование.ReservationStatus
	|ORDER BY
	|	Бронирование.ReservationStatus.ПорядокСортировки";
	vQry.SetParameter("qGuest", Ref);
	vQryRes = vQry.Execute().Unload();
	Return vQryRes;
EndFunction //pmGetClientReservationStatistics

//-----------------------------------------------------------------------------
// Get client last accommodation
//-----------------------------------------------------------------------------
Function pmGetClientLastAccommodation() Экспорт
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
	|	AND Размещение.Клиент = &qGuest
	|	AND Размещение.СтатусРазмещения.ЭтоВыезд
	|	AND Размещение.СтатусРазмещения.Действует
	|ORDER BY
	|	Размещение.PointInTime DESC";
	vQry.SetParameter("qGuest", Ref);
	vQryRes = vQry.Execute().Choose();
	While vQryRes.Next() Do
		vLastAcc = vQryRes.Ref;
		Break;
	EndDo;
	Return vLastAcc;
EndFunction //pmGetClientLastAccommodation

//-----------------------------------------------------------------------------
// Get client last resource reservation
//-----------------------------------------------------------------------------
Function pmGetClientLastResourceReservation() Экспорт
	vLastRes = Неопределено;
	// Run query
	vQry = New Query();
	vQry.Text = 
	"SELECT TOP 1
	|	БроньУслуг.Ref
	|FROM
	|	Document.БроньУслуг AS БроньУслуг
	|WHERE
	|	БроньУслуг.Posted
	|	AND БроньУслуг.Клиент = &qGuest
	|	AND БроньУслуг.ResourceReservationStatus.IsActive
	|
	|ORDER BY
	|	БроньУслуг.PointInTime DESC";
	vQry.SetParameter("qGuest", Ref);
	vQryRes = vQry.Execute().Choose();
	While vQryRes.Next() Do
		vLastRes = vQryRes.Ref;
		Break;
	EndDo;
	Return vLastRes;
EndFunction //pmGetClientLastResourceReservation

//-----------------------------------------------------------------------------
// Get client first accommodation
//-----------------------------------------------------------------------------
Function pmGetClientFirstAccommodation() Экспорт
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
	|	AND Размещение.Клиент = &qGuest
	|	AND Размещение.СтатусРазмещения.ЭтоЗаезд
	|	AND Размещение.СтатусРазмещения.Действует
	|ORDER BY
	|	Размещение.PointInTime";
	vQry.SetParameter("qGuest", Ref);
	vQryRes = vQry.Execute().Choose();
	While vQryRes.Next() Do
		vFirstAcc = vQryRes.Ref;
		Break;
	EndDo;
	Return vFirstAcc;
EndFunction //pmGetClientFirstAccommodation

//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
Процедура OnCopy(pCopiedObject)
	ExternalCode = "";
	// Author and date
	Автор = ПараметрыСеанса.ТекПользователь;
	CreateDate = CurrentDate();
КонецПроцедуры //OnCopy

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
// Get characteristics
// Returns ValueTable 
//-----------------------------------------------------------------------------
Function pmGetLimitsAndConditions() Экспорт
	// Build and run query
	vQry = New Query;
	vQry.Text = 
	"SELECT
	|	LimitsAndSpecialConditions.Owner AS Клиент,
	|	LimitsAndSpecialConditions.Гостиница,
	|	LimitsAndSpecialConditions.Characteristic,
	|	LimitsAndSpecialConditions.CharacteristicValue
	|FROM
	|	InformationRegister.LimitsAndSpecialConditions AS LimitsAndSpecialConditions
	|WHERE
	|	LimitsAndSpecialConditions.Owner = &qClient
	|	AND LimitsAndSpecialConditions.Characteristic.DeletionMark = FALSE
	|
	|ORDER BY
	|	LimitsAndSpecialConditions.Characteristic.Code";
	vQry.SetParameter("qClient", Ref);
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
	|	LimitsAndSpecialConditions.Owner = &qClient
	|	AND (LimitsAndSpecialConditions.Гостиница = &qHotel OR LimitsAndSpecialConditions.Гостиница = &qEmptyHotel)
	|	AND LimitsAndSpecialConditions.Characteristic = &qCharacteristic
	|
	|ORDER BY
	|	LimitsAndSpecialConditions.Characteristic.Code";
	vQry.SetParameter("qClient", Ref);
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
