//-----------------------------------------------------------------------------
Процедура pmFillAttributesWithDefaultValues() Экспорт
	// Current hotel
	If НЕ ЗначениеЗаполнено(Гостиница) Тогда
		Гостиница = ПараметрыСеанса.ТекущаяГостиница;
	EndIf;
	// Use round-the-clock calendar by default
	If НЕ ЗначениеЗаполнено(Calendar) Тогда
		Calendar = Справочники.Календари.RoundTheClock;
		RoundTheClockOperation = True;
	EndIf;
КонецПроцедуры //pmFillAttributesWithDefaultValues

//-----------------------------------------------------------------------------
Function pmCheckResourceAttributes(pMessage, pAttributeInErr) Экспорт
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
		vMsgTextRu = vMsgTextRu + "Реквизит <Тип ресурса> должен быть заполнен!" + Chars.LF;
		vMsgTextEn = vMsgTextEn + "<Ресурс type> attribute should be filled!" + Chars.LF;
		pAttributeInErr = ?(pAttributeInErr = "", "Owner", pAttributeInErr);
	EndIf;
	If НЕ ЗначениеЗаполнено(Calendar) Тогда
		vHasErrors = True; 
		vMsgTextRu = vMsgTextRu + "Реквизит <Календарь работы ресурса> должен быть заполнен!" + Chars.LF;
		vMsgTextEn = vMsgTextEn + "<Ресурс working time calendar> attribute should be filled!" + Chars.LF;
		pAttributeInErr = ?(pAttributeInErr = "", "Calendar", pAttributeInErr);
	EndIf;
	If vHasErrors Тогда
		pMessage = "ru = '" + СокрЛП(vMsgTextRu) + "';" + "en = '" + СокрЛП(vMsgTextEn) + "';";
	EndIf;
	Return vHasErrors;
EndFunction //pmCheckResourceAttributes

//-----------------------------------------------------------------------------
Function pmGetResourceDescription(pLang) Экспорт
	vDescr = "";
	If НЕ ЗначениеЗаполнено(pLang) Тогда
		vDescr = СокрЛП(Description);
	Else
		If IsBlankString(DescriptionTranslations) Тогда
			vDescr = СокрЛП(Description);
		Else
			vDescr = СокрЛП(DescriptionTranslations);
		EndIf;
	EndIf;
	Return vDescr;
EndFunction //pmGetResourceDescription

//-----------------------------------------------------------------------------
// Get resource characteristics
// Returns ValueTable 
//-----------------------------------------------------------------------------
Function pmGetResourceCharacteristics() Экспорт
	// Build and run query
	vQry = New Query;
	vQry.Text = 
	"SELECT
	|	ResourceCharacteristics.Ресурс,
	|	ResourceCharacteristics.ResourceCharacteristic,
	|	ResourceCharacteristics.ResourceCharacteristicValue
	|FROM
	|	InformationRegister.ResourceCharacteristics AS ResourceCharacteristics
	|WHERE
	|	ResourceCharacteristics.Ресурс = &qResource AND
	|	ResourceCharacteristics.ResourceCharacteristic.DeletionMark = FALSE
	|ORDER BY
	|	ResourceCharacteristics.ResourceCharacteristic.Code";
	vQry.SetParameter("qResource", Ref);
	vChars = vQry.Execute().Unload();
	Return vChars;
EndFunction //pmGetResourceCharacteristics

//-----------------------------------------------------------------------------
// Get resource characteristic value
// Returns Value
//-----------------------------------------------------------------------------
Function pmGetResourceCharacteristicValue(pResourceCharacteristic) Экспорт
	vCharValue = Неопределено;
	// Build and run query
	vQry = New Query;
	vQry.Text = 
	"SELECT
	|	ResourceCharacteristics.ResourceCharacteristicValue
	|FROM
	|	InformationRegister.ResourceCharacteristics AS ResourceCharacteristics
	|WHERE
	|	ResourceCharacteristics.Ресурс = &qResource AND
	|	ResourceCharacteristics.ResourceCharacteristic = &qResourceCharacteristic
	|ORDER BY
	|	ResourceCharacteristics.ResourceCharacteristic.Code";
	vQry.SetParameter("qResource", Ref);
	vQry.SetParameter("qResourceCharacteristic", pResourceCharacteristic);
	vChars = vQry.Execute().Choose();
	While vChars.Next() Do
		vCharValue = vChars.ResourceCharacteristicValue;
		Break;
	EndDo;
	Return vCharValue;
EndFunction //pmGetResourceCharacteristicValue

//-----------------------------------------------------------------------------
Процедура pmSaveResourceCharacteristicValue(pResourceCharacteristic, pResourceCharacteristicValue) Экспорт
	vResourceCharsMgr = InformationRegisters.ХарактеристикаРесурса.CreateRecordManager();
	vResourceCharsMgr.Ресурс = Ref;
	vResourceCharsMgr.ResourceCharacteristic = pResourceCharacteristic;
	vResourceCharsMgr.Read();
	If vResourceCharsMgr.Selected() Тогда
		vResourceCharsMgr.Ресурс = Ref;
		vResourceCharsMgr.ResourceCharacteristic = pResourceCharacteristic;
		vResourceCharsMgr.ResourceCharacteristicValue = pResourceCharacteristicValue;
		vResourceCharsMgr.Write();
	EndIf;
КонецПроцедуры //pmSaveResourceCharacteristicValue

//-----------------------------------------------------------------------------
// Get resource children
// Returns ValueTable
//-----------------------------------------------------------------------------
Function pmGetResourceChildren() Экспорт
	// Build and run query
	vQry = New Query;
	vQry.Text = 
	"SELECT
	|	Ресурсы.Ref AS Ресурс
	|FROM
	|	Catalog.Ресурсы AS Ресурсы
	|WHERE
	|	Ресурсы.Parent = &qResource
	|	AND (NOT Ресурсы.DeletionMark)
	|ORDER BY
	|	Ресурсы.ПорядокСортировки";
	vQry.SetParameter("qResource", Ref);
	vChildren = vQry.Execute().Unload();
	Return vChildren;
EndFunction //pmGetResourceChildren

//-----------------------------------------------------------------------------
// Get resource default charging time
// Returns Structure with TimeFrom and TimeTo elements
//-----------------------------------------------------------------------------
Function pmGetResourceDefaultChargingTimes(pAccountingDate) Экспорт
	// Check resource attributes
	If ЗначениеЗаполнено(TimeFrom) And ЗначениеЗаполнено(TimeTo) And TimeTo >= TimeFrom Тогда
		Return New Structure("ВремяС, ВремяПо", TimeFrom, TimeTo);
	EndIf;
	// Check calendar timetable
	If ЗначениеЗаполнено(Calendar) Тогда
		vCalendarObj = Calendar.GetObject();
		vDays = vCalendarObj.pmGetDays(BegOfDay(pAccountingDate), BegOfDay(pAccountingDate));
		If vDays.Count() > 0 Тогда
			vDaysRow = vDays.Get(0);
			vTimetable = vDaysRow.Timetable;
			If ЗначениеЗаполнено(vTimeTable) And vTimeTable.WorkingTimes.Count() > 0 Тогда
				vWorkingTimes = vTimeTable.WorkingTimes.Unload();
				vWorkingTimes.Sort("ВремяС");
				vTimeFrom = vWorkingTimes.Get(0).ВремяС;
				vTimeTo = vWorkingTimes.Get(vWorkingTimes.Count() - 1).ВремяПо;
				If ЗначениеЗаполнено(vTimeFrom) And ЗначениеЗаполнено(vTimeTo) And vTimeTo >= vTimeFrom Тогда
					Return New Structure("ВремяС, ВремяПо", vTimeFrom, vTimeTo);
				EndIf;
			EndIf;
		EndIf;
	EndIf;
	Return New Structure("ВремяС, ВремяПо", '00010101', '00010101');
EndFunction //pmGetResourceDefaultChargingTimes
