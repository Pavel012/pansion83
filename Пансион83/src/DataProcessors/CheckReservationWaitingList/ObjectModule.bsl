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
			ReservationDepartment = Гостиница.ReservationDepartment;
		EndIf;
	EndIf;
КонецПроцедуры //pmFillAttributesWithDefaultValues

//-----------------------------------------------------------------------------
// Run data processor in silent mode
//-----------------------------------------------------------------------------
Процедура pmRun(pParameter = Неопределено, pIsInteractive = False) Экспорт
	// Check reservation waiting list
	pmCheck(pIsInteractive);
КонецПроцедуры //pmRun

//-----------------------------------------------------------------------------
// Data processors framework end
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
Процедура UpdateWaitingListRecordStatus(pReservation)
	// Update current attachment status
	vSet = InformationRegisters.ОжиданиеБрони.CreateRecordSet();
	vSet.Filter.Recorder.Value = pReservation;
	vSet.Filter.Recorder.ComparisonType = ComparisonType.Equal;
	vSet.Filter.Recorder.Use = True;
	vSet.Read();
	For Each vSetRow In vSet Do
		vSetRow.Ready = True;
	EndDo;
	vSet.Write();
КонецПроцедуры //UpdateWaitingListRecordStatus

//-----------------------------------------------------------------------------
Процедура pmCheck(pIsInteractive = False) Экспорт
	WriteLogEvent(NStr("en='DataProcessor.CheckReservationWaitingList';ru='Обработка.ПроверкаЛистаОжиданияБрони';de='DataProcessor.CheckReservationWaitingList'"), EventLogLevel.Information, ThisObject.Metadata(), Неопределено, NStr("en='Start of processing';ru='Начало выполнения';de='Anfang der Ausführung'"));
	// Get up to date reservations in the waiting list
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	ReservationWaitingList.Reservation,
	|	ReservationWaitingList.Rating,
	|	ReservationWaitingList.Ready
	|FROM
	|	InformationRegister.ReservationWaitingList AS ReservationWaitingList
	|WHERE
	|	ReservationWaitingList.Active
	|	AND (ReservationWaitingList.Reservation.Гостиница = &qHotel OR &qHotelIsEmpty)
	|	AND ReservationWaitingList.Reservation.CheckInDate >= &qCurrentDate";
	vQry.SetParameter("qHotel", Гостиница);
	vQry.SetParameter("qHotelIsEmpty", НЕ ЗначениеЗаполнено(Гостиница));
	vQry.SetParameter("qCurrentDate", CurrentDate());
	vReservations = vQry.Execute().Unload();
	// Check notification transport type
	For Each vReservationsRow In vReservations Do
		vReservationRef = vReservationsRow.Reservation;
		If НЕ ЗначениеЗаполнено(vReservationRef) Тогда
			Continue;
		EndIf;
		If НЕ ЗначениеЗаполнено(vReservationRef.Гостиница.NewReservationStatus) Тогда
			Continue;
		EndIf;
		If НЕ vReservationRef.Гостиница.NewReservationStatus.IsActive Тогда
			Continue;
		EndIf;
		BeginTransaction(DataLockControlMode.Managed);
		Try
			// Change reservation status and try to post it
			vReservationObj = vReservationRef.GetObject();
			vReservationObj.ReservationStatus = vReservationObj.Гостиница.NewReservationStatus;
			vReservationObj = vReservationRef.GetObject();
			vReservationObj.Write(DocumentWriteMode.Posting);
			// Check ГруппаНомеров quota inventory balances
			
		
			// Roll back transaction if all checks has passed
			RollbackTransaction();
			// Log current state
			vMessage = NStr("en='Reservation could be confirmed: ';ru='Бронь может быть подтверждена: ';de='Die Reservierung kann bestätigt werden: '") + Chars.LF + 
					   Format(vReservationRef.ГруппаГостей.Code, "ND=12; NFD=0; NG=") + ", " + 
					   Format(vReservationRef.CheckInDate, "DF='dd.MM.yyyy HH:mm'") + " - " + Format(vReservationRef.CheckOutDate, "DF='dd.MM.yyyy HH:mm'") + ", " + 
					   TrimAll(vReservationRef.ТипНомера) + ", " + TrimAll(vReservationRef.НомерРазмещения);
			WriteLogEvent(NStr("en='DataProcessor.CheckReservationWaitingList';ru='Обработка.ПроверкаЛистаОжиданияБрони';de='DataProcessor.CheckReservationWaitingList'"), EventLogLevel.Information, ThisObject.Metadata(), vReservationRef, vMessage);
			If pIsInteractive Тогда
				Message(vMessage, MessageStatus.Information);
			EndIf;
			// Update current waiting list record status
			UpdateWaitingListRecordStatus(vReservationRef);
			// Write notification message
			
		Except
			vErrDescription = ErrorDescription();
			If TransactionActive() Тогда
				RollbackTransaction();
			EndIf;
			WriteLogEvent(NStr("en='DataProcessor.CheckReservationWaitingList';ru='Обработка.ПроверкаЛистаОжиданияБрони';de='DataProcessor.CheckReservationWaitingList'"), EventLogLevel.Information, ThisObject.Metadata(), vReservationRef, vErrDescription);
			// Exit
			If pIsInteractive Тогда
				Message(vErrDescription, MessageStatus.Attention);
			EndIf;
		EndTry;
	EndDo;
	WriteLogEvent(NStr("en='DataProcessor.CheckReservationWaitingList';ru='Обработка.ПроверкаЛистаОжиданияБрони';de='DataProcessor.CheckReservationWaitingList'"), EventLogLevel.Information, ThisObject.Metadata(), Неопределено, NStr("en='End of processing';ru='Конец выполнения';de='Ende des Ausführung'"));
КонецПроцедуры //pmCheck
