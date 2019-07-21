//-----------------------------------------------------------------------------
// Get ГруппаНомеров attributes valid on specified date
// - pDate is optional. If is not specified, then function gets attributes on current date
// Returns ValueTable 
//-----------------------------------------------------------------------------
Function pmGetRoomAttributes(Val pDate = Неопределено) Экспорт
	// Fill parameter default values 
	If НЕ ЗначениеЗаполнено(pDate) Тогда
		pDate = CurrentDate();
	EndIf;
	
	// Build and run query
	vQry = New Query;
	vQry.Text = 
	"SELECT 
	|	* 
	|FROM
	|	InformationRegister.RoomChangeHistory.SliceLast(
	|	&qDate, 
	|	НомерРазмещения = &qRoom) AS RoomChangeHistory";
	vQry.SetParameter("qDate", pDate);
	vQry.SetParameter("qRoom", Ref);
	vAttrs = vQry.Execute().Unload();
	
	Return vAttrs;
EndFunction //pmGetRoomAttributes

//-----------------------------------------------------------------------------
// Get ГруппаНомеров properties
// Returns ValueTable 
//-----------------------------------------------------------------------------
Function pmGetRoomProperties() Экспорт
	// Build and run query
	vQry = New Query;
	vQry.Text = 
	"SELECT
	|	СвойстваНомеров.НомерРазмещения,
	|	СвойстваНомеров.RoomProperty,
	|	СвойстваНомеров.Примечания,
	|	СвойстваНомеров.Автор,
	|	СвойстваНомеров.RoomProperty.ПорядокСортировки AS RoomPropertySortCode
	|FROM
	|	InformationRegister.СвойстваНомеров AS СвойстваНомеров
	|WHERE
	|	СвойстваНомеров.НомерРазмещения = &qRoom
	|ORDER BY
	|	RoomPropertySortCode";
	vQry.SetParameter("qRoom", Ref);
	vProperties = vQry.Execute().Unload();
	Return vProperties;
EndFunction //pmGetRoomProperties

//-----------------------------------------------------------------------------
// Get ГруппаНомеров blocks
// Returns ValueTable 
//-----------------------------------------------------------------------------
Function pmGetRoomBlocks() Экспорт
	// Build and run query
	vQry = New Query;
	vQry.Text = 
	"SELECT
	|	ЗагрузкаНомеров.Recorder AS БлокНомер,
	|	ЗагрузкаНомеров.Гостиница,
	|	ЗагрузкаНомеров.ТипНомера,
	|	ЗагрузкаНомеров.НомерРазмещения,
	|	ЗагрузкаНомеров.RoomBlockType,
	|	ЗагрузкаНомеров.RoomBlockType.ПорядокСортировки AS RoomBlockTypeSortCode,
	|	ЗагрузкаНомеров.CheckInDate AS ДатаНачКвоты,
	|	ЗагрузкаНомеров.Продолжительность,
	|	ЗагрузкаНомеров.ДатаВыезда AS ДатаКонКвоты,
	|	ЗагрузкаНомеров.ЗаблокНомеров,
	|	ЗагрузкаНомеров.ЗаблокМест,
	|	ЗагрузкаНомеров.КоличествоМестНомер,
	|	ЗагрузкаНомеров.КоличествоГостейНомер,
	|	ЗагрузкаНомеров.Автор,
	|	ЗагрузкаНомеров.IsFinished,
	|	ЗагрузкаНомеров.Примечания
	|FROM
	|	AccumulationRegister.ЗагрузкаНомеров AS ЗагрузкаНомеров
	|WHERE
	|	ЗагрузкаНомеров.НомерРазмещения = &qRoom AND 
	|	ЗагрузкаНомеров.IsBlocking = TRUE AND 
	|	ЗагрузкаНомеров.IsFinished = FALSE AND 
	|	ЗагрузкаНомеров.RecordType = &qExpense
	|ORDER BY
	|	ДатаНачКвоты,
	|	RoomBlockTypeSortCode";
	vQry.SetParameter("qRoom", Ref);
	vQry.SetParameter("qExpense", AccumulationRecordType.Expense);
	vBlocks = vQry.Execute().Unload();
	Return vBlocks;
EndFunction //pmGetRoomBlocks

//-----------------------------------------------------------------------------
// Get ГруппаНомеров characteristics
// Returns ValueTable 
//-----------------------------------------------------------------------------
Function pmGetRoomCharacteristics() Экспорт
	// Build and run query
	vQry = New Query;
	vQry.Text = 
	"SELECT
	|	RoomCharacteristics.НомерРазмещения,
	|	RoomCharacteristics.RoomCharacteristic,
	|	RoomCharacteristics.RoomCharacteristicValue
	|FROM
	|	InformationRegister.RoomCharacteristics AS RoomCharacteristics
	|WHERE
	|	RoomCharacteristics.НомерРазмещения = &qRoom AND
	|	RoomCharacteristics.RoomCharacteristic.DeletionMark = FALSE
	|ORDER BY
	|	RoomCharacteristics.RoomCharacteristic.Code";
	vQry.SetParameter("qRoom", Ref);
	vChars = vQry.Execute().Unload();
	Return vChars;
EndFunction //pmGetRoomCharacteristics

//-----------------------------------------------------------------------------
// Get ГруппаНомеров characteristic value
// Returns Value
//-----------------------------------------------------------------------------
Function pmGetRoomCharacteristicValue(pRoomCharacteristic) Экспорт
	vCharValue = Неопределено;
	// Build and run query
	vQry = New Query;
	vQry.Text = 
	"SELECT
	|	RoomCharacteristics.RoomCharacteristicValue
	|FROM
	|	InformationRegister.RoomCharacteristics AS RoomCharacteristics
	|WHERE
	|	RoomCharacteristics.НомерРазмещения = &qRoom AND
	|	RoomCharacteristics.RoomCharacteristic = &qRoomCharacteristic
	|ORDER BY
	|	RoomCharacteristics.RoomCharacteristic.Code";
	vQry.SetParameter("qRoom", Ref);
	vQry.SetParameter("qRoomCharacteristic", pRoomCharacteristic);
	vChars = vQry.Execute().Choose();
	While vChars.Next() Do
		vCharValue = vChars.RoomCharacteristicValue;
		Break;
	EndDo;
	Return vCharValue;
EndFunction //pmGetRoomCharacteristicValue

//-----------------------------------------------------------------------------
Процедура pmSaveRoomCharacteristicValue(pRoomCharacteristic, pRoomCharacteristicValue) Экспорт
	vRoomCharsMgr = InformationRegisters.RoomCharacteristics.CreateRecordManager();
	vRoomCharsMgr.НомерРазмещения = Ref;
	vRoomCharsMgr.RoomCharacteristic = pRoomCharacteristic;
	vRoomCharsMgr.Read();
	If vRoomCharsMgr.Selected() Тогда
		vRoomCharsMgr.НомерРазмещения = Ref;
		vRoomCharsMgr.RoomCharacteristic = pRoomCharacteristic;
		vRoomCharsMgr.RoomCharacteristicValue = pRoomCharacteristicValue;
		vRoomCharsMgr.Write();
	EndIf;
КонецПроцедуры //pmSaveRoomCharacteristicValue

//-----------------------------------------------------------------------------
Function pmCheckRoomAttributes(pMessage, pAttributeInErr) Экспорт
	vHasErrors = False;
	pMessage = "";
	pAttributeInErr = "";
	vMsgTextRu = "";
	vMsgTextEn = "";
	If НЕ ЗначениеЗаполнено(Owner) Тогда
		vHasErrors = True; 
		vMsgTextRu = vMsgTextRu + "Реквизит <Гостиница> должен быть заполнен!" + Chars.LF;
		vMsgTextEn = vMsgTextEn + "<Гостиница> attribute should be filled!" + Chars.LF;
		pAttributeInErr = ?(pAttributeInErr = "", "Owner", pAttributeInErr);
	EndIf;
	If НЕ ЗначениеЗаполнено(ТипНомера) Тогда
		vHasErrors = True; 
		vMsgTextRu = vMsgTextRu + "Реквизит <Тип номера> должен быть заполнен!" + Chars.LF;
		vMsgTextEn = vMsgTextEn + "<НомерРазмещения type> attribute should be filled!" + Chars.LF;
		pAttributeInErr = ?(pAttributeInErr = "", "ТипНомера", pAttributeInErr);
	EndIf;
	If НЕ ЗначениеЗаполнено(ДатаВводаЭкспл) Тогда
		vHasErrors = True; 
		vMsgTextRu = vMsgTextRu + "Реквизит <Дата ввода номера в эксплуатацию> должен быть заполнен!" + Chars.LF;
		vMsgTextEn = vMsgTextEn + "<НомерРазмещения operation start date> attribute should be filled!" + Chars.LF;
		pAttributeInErr = ?(pAttributeInErr = "", "ДатаВводаЭкспл", pAttributeInErr);
	EndIf;
	If vHasErrors Тогда
		pMessage = "ru = '" + СокрЛП(vMsgTextRu) + "';" + "en = '" + СокрЛП(vMsgTextEn) + "';";
	EndIf;
	Return vHasErrors;
EndFunction //pmCheckRoomAttributes

//-----------------------------------------------------------------------------
Процедура pmWriteToRoomStatusChangeHistory(pPeriod, pUser, pRemarks) Экспорт
	// Add record to the ГруппаНомеров status change history
	vRCHRec = InformationRegisters.ИзмСтатусовНомеров.CreateRecordManager();
	
	vRCHRec.НомерРазмещения = Ref;
	vRCHRec.Period = pPeriod;
	vRCHRec.User = pUser;
	
	vRCHRec.СтатусНомера = СтатусНомера;
	vRCHRec.Примечания = pRemarks;
	
	vRCHRec.Write(True);
КонецПроцедуры //pmWriteToRoomStatusChangeHistory

//-----------------------------------------------------------------------------
Function pmGetRoomStatusHistoryState(pPeriod, pRoomStatus = Неопределено) Экспорт
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	*
	|FROM
	|	InformationRegister.ИсторияИзмСтатусаНомеров.SliceLast(
	|			&qPeriod,
	|			НомерРазмещения = &qRoom" + 
				?(pRoomStatus <> Неопределено, " AND СтатусНомера <> &qRoomStatus", "") + ") AS RoomStatusChangeHistorySliceLast";
	vQry.SetParameter("qPeriod", New Boundary(pPeriod, BoundaryType.Including));
	vQry.SetParameter("qRoom", Ref);
	vQry.SetParameter("qRoomStatus", pRoomStatus);
	vPrevRoomStatusStates = vQry.Execute().Unload();
	Return vPrevRoomStatusStates;
EndFunction //pmGetRoomStatusHistoryState

//-----------------------------------------------------------------------------
Function pmGetCheckedOutGuest(Val pPeriod = Неопределено) Экспорт
	If pPeriod = Неопределено Тогда
		pPeriod = CurrentDate();
	EndIf;
	// Build and run query
	vQry = New Query();
	vQry.Text = 
	"SELECT TOP 1
	|	ЗагрузкаНомеров.Клиент AS Клиент,
	|	ЗагрузкаНомеров.Recorder AS Размещение
	|FROM
	|	AccumulationRegister.ЗагрузкаНомеров AS ЗагрузкаНомеров
	|WHERE
	|	ЗагрузкаНомеров.Гостиница = &qHotel
	|	AND ЗагрузкаНомеров.НомерРазмещения = &qRoom
	|	AND ЗагрузкаНомеров.RecordType = &qReceipt
	|	AND ЗагрузкаНомеров.ПериодПо <= &qPeriod
	|	AND ЗагрузкаНомеров.IsAccommodation
	|	AND ЗагрузкаНомеров.ЭтоВыезд
	|
	|ORDER BY
	|	ЗагрузкаНомеров.ПериодПо DESC";
	vQry.SetParameter("qHotel", Owner);
	vQry.SetParameter("qRoom", Ref);
	vQry.SetParameter("qReceipt", AccumulationRecordType.Receipt);
	vQry.SetParameter("qPeriod", pPeriod);
	vQryTab = vQry.Execute().Unload();
	Return vQryTab;
EndFunction //pmGetCheckedOutGuest

//-----------------------------------------------------------------------------
Function pmGetInHouseGuests() Экспорт
	// Build and run query
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	ЗагрузкаНомеров.Клиент AS Клиент,
	|	ЗагрузкаНомеров.Recorder AS Размещение,
	|	ЗагрузкаНомеров.CheckInDate AS CheckInDate
	|FROM
	|	AccumulationRegister.ЗагрузкаНомеров AS ЗагрузкаНомеров
	|WHERE
	|	ЗагрузкаНомеров.Гостиница = &qHotel
	|	AND ЗагрузкаНомеров.НомерРазмещения = &qRoom
	|	AND ЗагрузкаНомеров.RecordType = &qExpense
	|	AND ЗагрузкаНомеров.IsAccommodation
	|	AND ЗагрузкаНомеров.ЭтоГости
	|	AND ЗагрузкаНомеров.ПериодС <= &qCurrentDate
	|	AND ЗагрузкаНомеров.ПериодПо >= &qCurrentDate
	|
	|GROUP BY
	|	ЗагрузкаНомеров.Клиент,
	|	ЗагрузкаНомеров.Recorder,
	|	ЗагрузкаНомеров.CheckInDate
	|
	|ORDER BY
	|	ЗагрузкаНомеров.CheckInDate";
	vQry.SetParameter("qHotel", Owner);
	vQry.SetParameter("qRoom", Ref);
	vQry.SetParameter("qCurrentDate", CurrentDate());
	vQry.SetParameter("qExpense", AccumulationRecordType.Expense);
	vQryTab = vQry.Execute().Unload();
	Return vQryTab;
EndFunction //pmGetInHouseGuests

//-----------------------------------------------------------------------------
Function pmGetRoomInventoryDocuments(pAll = False) Экспорт
	// Build and run query
	vQry = New Query;
	vQry.Text = 
	"SELECT
	|	AddRooms.Ref AS Ref,
	|	AddRooms.PointInTime AS PointInTime
	|FROM
	|	Document.AddRoom AS AddRooms
	|WHERE
	|	AddRooms.НомерРазмещения = &qRoom
	|	AND (AddRooms.Posted OR &qAll)
	|
	|UNION ALL
	|
	|SELECT
	|	ChangeRooms.Ref,
	|	ChangeRooms.PointInTime
	|FROM
	|	Document.ПереселениеНомер AS ChangeRooms
	|WHERE
	|	ChangeRooms.НомерРазмещения = &qRoom
	|	AND (ChangeRooms.Posted OR &qAll)
	|
	|ORDER BY
	|	PointInTime DESC";
	vQry.SetParameter("qRoom", Ref);
	vQry.SetParameter("qAll", pAll);
	vRIDocs = vQry.Execute().Unload();
	Return vRIDocs;
EndFunction //pmGetRoomInventoryDocuments

//-----------------------------------------------------------------------------
Процедура pmSetStopSaleFlag() Экспорт
	vStopSale = False;
	For Each vRow In ПериодыСнятияСПродажи Do
		If vRow.СнятСПродажи Тогда
			If НЕ ЗначениеЗаполнено(vRow.ПериодС) And НЕ ЗначениеЗаполнено(vRow.ПериодПо) Тогда
				vStopSale = True;
				Break;
			ElsIf НЕ ЗначениеЗаполнено(vRow.ПериодС) And ЗначениеЗаполнено(vRow.ПериодПо) Тогда
				If vRow.ПериодПо > CurrentDate() Тогда
					vStopSale = True;
					Break;
				EndIf;
			ElsIf ЗначениеЗаполнено(vRow.ПериодС) And НЕ ЗначениеЗаполнено(vRow.ПериодПо) Тогда
				vStopSale = True;
				Break;
			ElsIf ЗначениеЗаполнено(vRow.ПериодС) And ЗначениеЗаполнено(vRow.ПериодПо) Тогда
				If vRow.ПериодПо > CurrentDate() Тогда
					vStopSale = True;
					Break;
				EndIf;
			EndIf;
		EndIf;
	EndDo;
	If vStopSale <> СнятСПродажи Тогда
		СнятСПродажи = vStopSale;
	EndIf;
КонецПроцедуры //pmSetStopSaleFlag

//-----------------------------------------------------------------------------
Процедура OnWrite(pCancel)
	If ThisObject.DataExchange.Load Тогда
		Return;
	EndIf;
	// Mark all ГруппаНомеров inventory operations as deleted
	If DeletionMark Тогда
		vDocs = pmGetRoomInventoryDocuments();
		For Each vDocsRow In vDocs Do
			vRIDocObj = vDocsRow.Ref.GetObject();
			vRIDocObj.УстановитьПометкуУдаления(Истина);
		EndDo;
	EndIf;
КонецПроцедуры //OnWrite

//-----------------------------------------------------------------------------
Процедура BeforeDelete(pCancel)
	If ThisObject.DataExchange.Load Тогда
		Return;
	EndIf;
	// Delete all ГруппаНомеров inventory documents
	vDocs = pmGetRoomInventoryDocuments(True);
	For Each vDocsRow In vDocs Do
		vRIDocObj = vDocsRow.Ref.GetObject();
		vRIDocObj.Delete();
	EndDo;
КонецПроцедуры //BeforeDelete
