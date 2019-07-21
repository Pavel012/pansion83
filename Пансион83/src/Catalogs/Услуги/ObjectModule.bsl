//-----------------------------------------------------------------------------
Function pmGetServiceDescription(pLang, pUseGroupByDescription = False) Экспорт
	vDescr = "";
	If НЕ ЗначениеЗаполнено(pLang) Тогда
		vDescr = СокрЛП(Description);
	Else
		If pUseGroupByDescription And НЕ IsBlankString(GroupByDescriptionTranslations) Тогда
			vDescr = СокрЛП(GroupByDescriptionTranslations);
		Else
			If IsBlankString(DescriptionTranslations) Тогда
				vDescr = СокрЛП(Description);
			Else
				vDescr = СокрЛП(DescriptionTranslations);
			EndIf;
		EndIf;
	EndIf;
	Return vDescr;
EndFunction //pmGetServiceDescription

//-----------------------------------------------------------------------------
Function pmGetServiceUnitDescription(pLang) Экспорт
	vDescr = "";
	If НЕ ЗначениеЗаполнено(pLang) Тогда
		vDescr = СокрЛП(Unit);
	Else
		If IsBlankString(UnitTranslations) Тогда
			vDescr = СокрЛП(Unit);
		Else
			vDescr = СокрЛП(UnitTranslations);
		EndIf;
	EndIf;
	Return vDescr;
EndFunction //pmGetServiceUnitDescription

//-----------------------------------------------------------------------------
Function pmGetServiceQuantityPresentation(pQuantity, pLang) Экспорт
	vQuantityStr = "";
	If Round(pQuantity, 3) <> pQuantity Тогда
		vQuantityStr = ?(pQuantity = 0, "", Format(pQuantity, "ND=17; NFD=3"));
	Else
		vQuantityStr = ?(pQuantity = 0, "", String(pQuantity));
	EndIf;
	vQuantityStr = СокрЛП(vQuantityStr + " " + pmGetServiceUnitDescription(pLang));
	If GetUnitFromRule And ЗначениеЗаполнено(QuantityCalculationRule) Тогда
		If QuantityCalculationRule.PeriodInHours = 24 Тогда
			vQuantityInHours = Round(pQuantity * QuantityCalculationRule.PeriodInHours);
			vQuantityInDays = Int(vQuantityInHours/24);
			vQuantityInHours = vQuantityInHours - vQuantityInDays*24;
			If vQuantityInDays <> 0 Тогда
				vQuantityStr = String(vQuantityInDays) + " " + pmGetServiceUnitDescription(pLang) + " ";
			Else
				vQuantityStr = "";
			EndIf;
			If vQuantityInHours <> 0 Тогда
				vQuantityStr = vQuantityStr + String(vQuantityInHours) + " ч";
			EndIf;
		EndIf;
	ElsIf IsResourceRevenue And НЕ RoomRevenueAmountsOnly Тогда
		If IsPricePerMinute And СокрЛП(Unit) = СокрЛП(Справочники.ЕдИзмерения.Minute) Тогда
			vQuantityStr = String(pQuantity) + " м";
		ElsIf СокрЛП(Unit) = СокрЛП(Справочники.ЕдИзмерения.Hour) Тогда
			vQuantityInHours = Int(pQuantity);
			vQuantityInMinutes = Round((pQuantity - Int(pQuantity))*60, 0);
			If vQuantityInHours <> 0 Тогда
				vQuantityStr = String(vQuantityInHours) + " ч ";
			Else
				vQuantityStr = "";
			EndIf;
			If vQuantityInMinutes <> 0 Тогда
				vQuantityStr = vQuantityStr + String(vQuantityInMinutes) + " м";
			EndIf;
		EndIf;
	EndIf;
	Return vQuantityStr;
EndFunction //pmGetServiceQuantityPresentation	

//-----------------------------------------------------------------------------
Function pmGetServicePrices(pHotel, pDate = Неопределено, pClientType = Неопределено) Экспорт
	// Common checks	
	If НЕ ЗначениеЗаполнено(pHotel) Тогда
		ВызватьИсключение(NStr("en='ERR: Error calling Service.pmGetServicePrices function.
		               |CAUSE: Empty pHotel parameter value was passed to the function.
					   |DESC: Mandatory parameter pHotel should be filled.';
				   |ru='ERR: Ошибка вызова функции Service.pmGetServicePrices.
					   |CAUSE: В функцию передано пустое значение параметра pHotel.
					   |DESC: Обязательный параметр pHotel должен быть явно указан.';
				   |de='ERR: Fehler beim Aufruf der Funktion cmGetServicePrices.
				       |CAUSE: In die Funktion wurde ein leerer Wert des Parameters pHotel übertragen.
					   |DESC: Das Pflichtparameter pHotel muss eindeutig angegeben sein.'"));
	EndIf;
	
	// Fill parameters default values 
	If НЕ ЗначениеЗаполнено(pDate) Тогда
		pDate = CurrentDate();
	EndIf;
	If НЕ ЗначениеЗаполнено(pClientType) Тогда
		pClientType = Справочники.ТипыКлиентов.EmptyRef();
	EndIf;
	
	// Build and run query
	qGetPrices = New Query();
	qGetPrices.Text = 
	"SELECT
	|	ServicePrices.Period,
	|	ServicePrices.Гостиница,
	|	ServicePrices.Услуга,
	|	ServicePrices.ТипКлиента,
	|	ServicePrices.Цена,
	|	ServicePrices.Валюта,
	|	ServicePrices.СтавкаНДС
	|FROM
	|	InformationRegister.ServicePrices.SliceLast(
	|			&qDate,
	|			Гостиница = &qHotel
	|				AND Услуга = &qService
	|				AND ТипКлиента = &qClientType) AS ServicePrices";
	qGetPrices.SetParameter("qDate", pDate);
	qGetPrices.SetParameter("qHotel", pHotel);
	qGetPrices.SetParameter("qService", Ref);
	qGetPrices.SetParameter("qClientType", pClientType);
	vPrices = qGetPrices.Execute().Unload();
	
	If vPrices.Count() = 0 And ЗначениеЗаполнено(pClientType) Тогда
		// Build and run query
		qGetPrices = New Query();
		qGetPrices.Text = 
		"SELECT
		|	ServicePrices.Period,
		|	ServicePrices.Гостиница,
		|	ServicePrices.Услуга,
		|	ServicePrices.ТипКлиента,
		|	ServicePrices.Цена,
		|	ServicePrices.Валюта,
		|	ServicePrices.СтавкаНДС
		|FROM
		|	InformationRegister.ServicePrices.SliceLast(
		|			&qDate,
		|			Гостиница = &qHotel
		|				AND Услуга = &qService
		|				AND ТипКлиента = &qEmptyClientType) AS ServicePrices";
		qGetPrices.SetParameter("qDate", pDate);
		qGetPrices.SetParameter("qHotel", pHotel);
		qGetPrices.SetParameter("qService", Ref);
		qGetPrices.SetParameter("qEmptyClientType", Справочники.ТипыКлиентов.EmptyRef());
		vPrices = qGetPrices.Execute().Unload();
	EndIf;
	
	Return vPrices;
EndFunction //pmGetServicePrices

//-----------------------------------------------------------------------------
Процедура OnCopy(pCopiedObject)
	If НЕ IsFolder Тогда
		ExternalCode = "";
	EndIf;
КонецПроцедуры //OnCopy

//-----------------------------------------------------------------------------
// Get service characteristics
// Returns ValueTable 
//-----------------------------------------------------------------------------
Function pmGetServiceCharacteristics() Экспорт
	// Build and run query
	vQry = New Query;
	vQry.Text = 
	"SELECT
	|	ServiceCharacteristics.Услуга,
	|	ServiceCharacteristics.ServiceCharacteristic,
	|	ServiceCharacteristics.ServiceCharacteristicValue
	|FROM
	|	InformationRegister.ServiceCharacteristics AS ServiceCharacteristics
	|WHERE
	|	ServiceCharacteristics.Услуга = &qService AND
	|	ServiceCharacteristics.ServiceCharacteristic.DeletionMark = FALSE
	|ORDER BY
	|	ServiceCharacteristics.ServiceCharacteristic.Code";
	vQry.SetParameter("qService", Ref);
	vChars = vQry.Execute().Unload();
	Return vChars;
EndFunction //pmGetServiceCharacteristics

//-----------------------------------------------------------------------------
// Get service characteristic value
// Returns Value
//-----------------------------------------------------------------------------
Function pmGetServiceCharacteristicValue(pServiceCharacteristic) Экспорт
	vCharValue = Неопределено;
	// Build and run query
	vQry = New Query;
	vQry.Text = 
	"SELECT
	|	ServiceCharacteristics.ServiceCharacteristicValue
	|FROM
	|	InformationRegister.ServiceCharacteristics AS ServiceCharacteristics
	|WHERE
	|	ServiceCharacteristics.Услуга = &qService AND
	|	ServiceCharacteristics.ServiceCharacteristic = &qServiceCharacteristic
	|ORDER BY
	|	ServiceCharacteristics.ServiceCharacteristic.Code";
	vQry.SetParameter("qService", Ref);
	vQry.SetParameter("qServiceCharacteristic", pServiceCharacteristic);
	vChars = vQry.Execute().Choose();
	While vChars.Next() Do
		vCharValue = vChars.ServiceCharacteristicValue;
		Break;
	EndDo;
	Return vCharValue;
EndFunction //pmGetServiceCharacteristicValue

//-----------------------------------------------------------------------------
Процедура pmSaveServiceCharacteristicValue(pServiceCharacteristic, pServiceCharacteristicValue) Экспорт
	vServiceCharsMgr = InformationRegisters.ХарактеристикаУслуг.CreateRecordManager();
	vServiceCharsMgr.Услуга = Ref;
	vServiceCharsMgr.ServiceCharacteristic = pServiceCharacteristic;
	vServiceCharsMgr.Read();
	If vServiceCharsMgr.Selected() Тогда
		vServiceCharsMgr.Услуга = Ref;
		vServiceCharsMgr.ServiceCharacteristic = pServiceCharacteristic;
		vServiceCharsMgr.ServiceCharacteristicValue = pServiceCharacteristicValue;
		vServiceCharsMgr.Write();
	EndIf;
КонецПроцедуры //pmSaveServiceCharacteristicValue
