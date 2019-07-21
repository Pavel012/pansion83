//-----------------------------------------------------------------------------
// Data processors framework start
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Initialize attributes with default values
// Attention: This procedure could be called AFTER some attributes initialization
// routine, so it SHOULD NOT reset attributes being set before
//-----------------------------------------------------------------------------
Процедура pmFillAttributesWithDefaultValues() Экспорт
	If НЕ ЗначениеЗаполнено(Гостиница) Тогда
		Гостиница = ПараметрыСеанса.ТекущаяГостиница;
		If ЗначениеЗаполнено(Гостиница) Тогда
			If НЕ ЗначениеЗаполнено(OccupiedDirtyRoomStatus) And ЗначениеЗаполнено(Гостиница.OccupiedDirtyRoomStatus) Тогда
				OccupiedDirtyRoomStatus = Гостиница.OccupiedDirtyRoomStatus;
			EndIf;
			If НЕ ЗначениеЗаполнено(RoomStatusAfterEarlyCheckIn) And ЗначениеЗаполнено(Гостиница.RoomStatusAfterEarlyCheckIn) Тогда
				RoomStatusAfterEarlyCheckIn = Гостиница.RoomStatusAfterEarlyCheckIn;
				If НЕ ЗначениеЗаполнено(EarlyCheckInTime) Тогда
					EarlyCheckInTime = '00010101' + 6 * 3600; // Set to the 06:00
				EndIf;
			EndIf;
		EndIf;
	EndIf;
КонецПроцедуры //pmFillAttributesWithDefaultValues

//-----------------------------------------------------------------------------
// Run data processor in silent mode
//-----------------------------------------------------------------------------
Процедура pmRun(pParameter = Неопределено, pIsInteractive = False) Экспорт
	// Manage occupied ГруппаНомеров statuses
	pmManageOccupiedRoomStatuses(pIsInteractive);
КонецПроцедуры //pmRun

//-----------------------------------------------------------------------------
// Data processors framework end
//-----------------------------------------------------------------------------
	
//-----------------------------------------------------------------------------
Процедура pmManageOccupiedRoomStatuses(pIsInteractive = False) Экспорт
	WriteLogEvent(NStr("en='DataProcessor.ManageOccupiedRoomStatuses';ru='Обработка.УправлениеСтатусамиЗанятыхНомеров';de='DataProcessor.ManageOccupiedRoomStatuses'"), EventLogLevel.Information, ThisObject.Metadata(), Неопределено, NStr("en='Start of processing';ru='Начало выполнения';de='Anfang der Ausführung'"));
	// Get list of rooms to process
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	Accommodations.НомерРазмещения AS НомерРазмещения,
	|	MIN(Accommodations.CheckInDate) AS CheckInDate
	|FROM
	|	AccumulationRegister.ЗагрузкаНомеров AS Accommodations
	|WHERE
	|	Accommodations.IsAccommodation
	|	AND Accommodations.RecordType = VALUE(AccumulationRecordType.Expense)
	|	AND Accommodations.ЭтоГости
	|	AND (Accommodations.Гостиница IN HIERARCHY (&qHotel)
	|			OR &qHotelIsEmpty)
	|	AND Accommodations.ПериодС <= &qCurrentDate
	|	AND Accommodations.ПериодПо > &qCurrentDate
	|
	|GROUP BY
	|	Accommodations.НомерРазмещения
	|
	|ORDER BY
	|	Accommodations.НомерРазмещения.ПорядокСортировки";
	vQry.SetParameter("qHotel", Гостиница);
	vQry.SetParameter("qHotelIsEmpty", НЕ ЗначениеЗаполнено(Гостиница));
	vQry.SetParameter("qCurrentDate", CurrentDate());
	vRooms = vQry.Execute().Unload();
	For Each vRoomsRow In vRooms Do
		BeginTransaction(DataLockControlMode.Managed);
		Try
			vRoomObj = vRoomsRow.ГруппаНомеров.GetObject();
			
			// Set ГруппаНомеров status to occupied/dirty
			vRoomStatusHasChanged = False;
			If ЗначениеЗаполнено(OccupiedDirtyRoomStatus) Or ЗначениеЗаполнено(RoomStatusAfterEarlyCheckIn) Тогда
				If ЗначениеЗаполнено(vRoomsRow.CheckInDate) Тогда
					If ЗначениеЗаполнено(RoomStatusAfterEarlyCheckIn) And BegOfDay(vRoomsRow.CheckInDate) = BegOfDay(CurrentDate()) And
					   vRoomsRow.CheckInDate < (BegOfDay(CurrentDate()) + (EarlyCheckInTime - BegOfDay(EarlyCheckInTime))) Тогда
						vRoomObj.СтатусНомера = RoomStatusAfterEarlyCheckIn;
						vRoomStatusHasChanged = True;
					ElsIf ЗначениеЗаполнено(OccupiedDirtyRoomStatus) And BegOfDay(vRoomsRow.CheckInDate) < BegOfDay(CurrentDate()) Тогда
						vRoomObj.СтатусНомера = OccupiedDirtyRoomStatus;
						vRoomStatusHasChanged = True;
					EndIf;
				EndIf;
			EndIf;
			
			// Update ГруппаНомеров if necessary
			If vRoomStatusHasChanged Тогда
				vRoomObj.Write();
				
				// Add record to the ГруппаНомеров status change history
				vRoomObj.pmWriteToRoomStatusChangeHistory(CurrentDate(), ПараметрыСеанса.ТекПользователь, NStr("en = 'Automatically because ГруппаНомеров is in-use'; ru = 'Автоматически, т.к. номер занят'; de = 'Automatisch, da die Nummer belegt ist'"));
				
				// Log current state
				vMessage = NStr("ru = 'Статус номера " + TrimAll(vRoomObj.Ref) + " установлен в " + TrimAll(vRoomObj.СтатусНомера) + "'; 
				                |de = 'Zimmer: " + TrimAll(vRoomObj.Ref) + ", neu Status: " + TrimAll(vRoomObj.СтатусНомера) + "'; 
				                |en = 'ГруппаНомеров " + TrimAll(vRoomObj.Ref) + " status has been changed to " + TrimAll(vRoomObj.СтатусНомера) + "'");
				WriteLogEvent(NStr("en='DataProcessor.ManageOccupiedRoomStatuses';ru='Обработка.УправлениеСтатусамиЗанятыхНомеров';de='DataProcessor.ManageOccupiedRoomStatuses'"), EventLogLevel.Information, ThisObject.Metadata(), vRoomObj.Ref, vMessage);
				If pIsInteractive Тогда
					Message(vMessage, MessageStatus.Information);
				EndIf;
			EndIf;
			CommitTransaction();
		Except
			vMessage = ErrorDescription();
			WriteLogEvent(NStr("en='DataProcessor.ManageOccupiedRoomStatuses';ru='Обработка.УправлениеСтатусамиЗанятыхНомеров';de='DataProcessor.ManageOccupiedRoomStatuses'"), EventLogLevel.Warning, ThisObject.Metadata(), vRoomsRow.Room, vMessage);
			If TransactionActive() Тогда
				RollbackTransaction();
			EndIf;
			If pIsInteractive Тогда
				Message(vMessage, MessageStatus.Attention);
			EndIf;
		EndTry;
	EndDo;
	WriteLogEvent(NStr("en='DataProcessor.ManageOccupiedRoomStatuses';ru='Обработка.УправлениеСтатусамиЗанятыхНомеров';de='DataProcessor.ManageOccupiedRoomStatuses'"), EventLogLevel.Information, ThisObject.Metadata(), Неопределено, NStr("en='End of processing';ru='Конец выполнения';de='Ende des Ausführung'"));
КонецПроцедуры //pmManageOccupiedRoomStatuses
