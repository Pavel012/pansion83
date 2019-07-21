//-----------------------------------------------------------------------------
Процедура pmFillAttributesWithDefaultValues() Экспорт
	Гостиница = ПараметрыСеанса.ТекущаяГостиница;
	DoWriteOff = True;
КонецПроцедуры //pmFillAttributesWithDefaultValues

//-----------------------------------------------------------------------------
Function pmGetIntersectingCheckInPeriods(pPeriodFrom, pPeriodTo, pHotel = Неопределено) Экспорт
	// Try to find intersecting periods 
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	AllotmentCheckInPeriods.Гостиница,
	|	AllotmentCheckInPeriods.Тариф,
	|	AllotmentCheckInPeriods.КвотаНомеров,
	|	AllotmentCheckInPeriods.CheckInDate,
	|	AllotmentCheckInPeriods.Продолжительность,
	|	AllotmentCheckInPeriods.ДатаВыезда
	|FROM
	|	InformationRegister.RoomQuotaCheckInPeriods AS AllotmentCheckInPeriods
	|WHERE
	|	AllotmentCheckInPeriods.Гостиница = &qHotel
	|	AND AllotmentCheckInPeriods.КвотаНомеров = &qRoomQuota
	|	AND AllotmentCheckInPeriods.CheckInDate < &qCheckOutDate
	|	AND AllotmentCheckInPeriods.ДатаВыезда > &qCheckInDate
	|	AND NOT AllotmentCheckInPeriods.IsNotActive
	|
	|ORDER BY
	|	AllotmentCheckInPeriods.CheckInDate,
	|	AllotmentCheckInPeriods.Продолжительность";
	vQry.SetParameter("qHotel", ?(ЗначениеЗаполнено(pHotel), pHotel, Гостиница));
	vQry.SetParameter("qRoomQuota", Ref);
	
	vPeriods = vQry.Execute().Unload();
	Return vPeriods;
EndFunction //pmGetIntersectingCheckInPeriods

//-----------------------------------------------------------------------------
Function pmGetAllotmentDocuments() Экспорт
	// Try to find intersecting periods 
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	СоставКвоты.Ref
	|FROM
	|	Document.СоставКвоты AS СоставКвоты
	|WHERE
	|	СоставКвоты.Posted
	|	AND СоставКвоты.КвотаНомеров = &qRoomQuota
	|
	|ORDER BY
	|	СоставКвоты.PointInTime";
	vQry.SetParameter("qRoomQuota", Ref);
	vDocs = vQry.Execute().Unload();
	Return vDocs;
EndFunction //pmGetAllotmentDocuments

//-----------------------------------------------------------------------------
Процедура OnCopy(pCopiedObject)
	// Clear set ГруппаНомеров quota documents
	For Each vRow In RoomTypes Do
		vRow.SetRoomQuota = Documents.СоставКвоты.EmptyRef();
	EndDo;
КонецПроцедуры //OnCopy
