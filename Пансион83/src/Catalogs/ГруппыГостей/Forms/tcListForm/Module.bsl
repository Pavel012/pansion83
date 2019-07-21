//--------------------------------------------------------------
&AtServer
Процедура OnCreateAtServer(pCancel, pStandardProcessing)
	vInHouse = False;
	If НЕ Parameters.Property("InHouse", vInHouse) Тогда
		vInHouse = False;
	EndIf;
	FillGGList(vInHouse);
КонецПроцедуры //OnCreateAtServer

//--------------------------------------------------------------
&AtServer
Процедура FillGGList(pInHouse)
	vQry = New Query;
	If pInHouse Тогда
		vQry.Text = 
		"SELECT
		|	Размещение.ГруппаГостей.Code AS Code,
		|	Размещение.ГруппаГостей AS ГруппаГостей,
		|	Размещение.ГруппаГостей.CheckInDate AS CheckInDate,
		|	Размещение.ГруппаГостей.Продолжительность AS Продолжительность,
		|	Размещение.ГруппаГостей.ДатаВыезда AS ДатаВыезда,
		|	Размещение.ГруппаГостей.ЗаездГостей AS ЗаездГостей,
		|	Размещение.ГруппаГостей.Контрагент AS Контрагент,
		|	Размещение.ГруппаГостей.Клиент AS Клиент,
		|	Размещение.ГруппаГостей.Description AS Description,
		|	Размещение.ГруппаГостей.Status AS Status
		|FROM
		|	Document.Размещение AS Размещение
		|WHERE
		|	NOT Размещение.DeletionMark
		|	AND Размещение.Posted
		|	AND Размещение.Гостиница = &qHotel
		|	AND Размещение.ГруппаГостей.Owner = &qHotel
		|	AND Размещение.СтатусРазмещения.IsActive
		|	AND Размещение.СтатусРазмещения.ЭтоГости
		|
		|GROUP BY
		|	Размещение.ГруппаГостей,
		|	Размещение.ГруппаГостей.Code
		|
		|UNION ALL
		|
		|SELECT
		|	Бронирование.ГруппаГостей.Code,
		|	Бронирование.ГруппаГостей,
		|	Бронирование.ГруппаГостей.CheckInDate,
		|	Бронирование.ГруппаГостей.Продолжительность,
		|	Бронирование.ГруппаГостей.ДатаВыезда,
		|	Бронирование.ГруппаГостей.ЗаездГостей,
		|	Бронирование.ГруппаГостей.Контрагент,
		|	Бронирование.ГруппаГостей.Клиент,
		|	Бронирование.ГруппаГостей.Description,
		|	Бронирование.ГруппаГостей.Status
		|FROM
		|	Document.Бронирование AS Бронирование
		|WHERE
		|	Бронирование.Posted
		|	AND NOT Бронирование.DeletionMark
		|	AND Бронирование.Гостиница = &qHotel
		|	AND Бронирование.ГруппаГостей.Owner = &qHotel
		|	AND NOT Бронирование.ГруппаГостей.DeletionMark
		|	AND Бронирование.ReservationStatus.IsActive
		|	AND NOT Бронирование.ReservationStatus.ЭтоЗаезд
		|
		|GROUP BY
		|	Бронирование.ГруппаГостей,
		|	Бронирование.ГруппаГостей.Code";
		vQry.SetParameter("qSkipCheckIn", False);
	Else
		vQry.Text =
		"SELECT
		|	ГруппыГостей.Code AS Code,
		|	ГруппыГостей.Ref AS ГруппаГостей,
		|	ГруппыГостей.CheckInDate,
		|	ГруппыГостей.Продолжительность,
		|	ГруппыГостей.ДатаВыезда,
		|	ГруппыГостей.ЗаездГостей,
		|	ГруппыГостей.Контрагент,
		|	ГруппыГостей.Клиент,
		|	ГруппыГостей.Description,
		|	ГруппыГостей.Status
		|FROM
		|	Catalog.ГруппыГостей AS GuestGroups
		|WHERE
		|	ГруппыГостей.Owner = &qHotel
		|	AND NOT ГруппыГостей.IsFolder
		|	AND NOT ГруппыГостей.DeletionMark";
	EndIf;
	vQry.SetParameter("qHotel", ПараметрыСеанса.ТекущаяГостиница);
	vQryResult = vQry.Execute().Unload();
	vQryResult.GroupBy("Code, ГруппаГостей, CheckInDate, Продолжительность, ДатаВыезда, ЗаездГостей, Контрагент, Клиент, Description, Status");
	vQryResult.Sort("Code");
	ValueToFormAttribute(vQryResult, "List");
КонецПроцедуры //FillGGList

//--------------------------------------------------------------
&НаКлиенте
Процедура ListSelection(pItem, pSelectedRow, pField, pStandardProcessing)
	vCurData = pItem.CurrentData;
	If vCurData <> Неопределено Тогда
		Close(vCurData.ГруппаГостей);
	EndIf;
КонецПроцедуры //ListSelection

//--------------------------------------------------------------
&НаКлиенте
Процедура OnOpen(pCancel)
	// Activate last row
	If List.Count() > 0 Тогда
		Items.List.CurrentRow = List.Get(List.Count()-1).GetID();
	EndIf;
КонецПроцедуры //OnOpen

//--------------------------------------------------------------
&НаКлиенте
Процедура Choose(pCommand)
	vCurData = Items.List.CurrentData;
	If vCurData <> Неопределено Тогда
		Close(vCurData.ГруппаГостей);
	EndIf;
КонецПроцедуры //Choose
