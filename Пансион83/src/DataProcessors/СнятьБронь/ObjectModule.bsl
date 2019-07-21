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
	If PeriodToKeepReservations = 0 Тогда
		PeriodToKeepReservations = 60;
	EndIf;
	If НЕ ЗначениеЗаполнено(Гостиница) Тогда
		Гостиница = ПараметрыСеанса.ТекущаяГостиница;
	EndIf;
КонецПроцедуры //pmFillAttributesWithDefaultValues

//-----------------------------------------------------------------------------
// Run data processor in silent mode
//-----------------------------------------------------------------------------
Процедура pmRun(pParameter = Неопределено, pIsInteractive = False) Экспорт
	// Cancel non guaranteed reservations
	pmCancelNonGuaranteedReservations(pIsInteractive);
КонецПроцедуры //pmRun

//-----------------------------------------------------------------------------
// Data processors framework end
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
Function GetChangeStatusReservationState(pReservation)
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	*
	|FROM
	|	InformationRegister.ReservationChangeHistory AS ReservationChangeHistory
	|WHERE
	|	ReservationChangeHistory.Reservation = &qReservation
	|	AND ReservationChangeHistory.ReservationStatus = &qReservationStatus
	|ORDER BY
	|	ReservationChangeHistory.Period";
	vQry.SetParameter("qReservation", pReservation);
	vQry.SetParameter("qReservationStatus", pReservation.ReservationStatus);
	vStates = vQry.Execute().Unload();
	If vStates.Count() > 0 Тогда
		Return vStates.Get(0);
	Else
		Return Неопределено;
	EndIf;
EndFunction //GetChangeStatusReservationState
	
//-----------------------------------------------------------------------------
Процедура pmCancelNonGuaranteedReservations(pIsInteractive = False) Экспорт
	WriteLogEvent(NStr("en='DataProcessor.DisableNonGuaranteedReservations';ru='Обработка.СнятьНегарантированнуюБронь';de='DataProcessor.DisableNonGuaranteedReservations'"), EventLogLevel.Information, ThisObject.Metadata(), Неопределено, NStr("en='Start of processing';ru='Начало выполнения';de='Anfang der Ausführung'"));
	// Check parameters
	If НЕ ЗначениеЗаполнено(NonGuaranteedReservationStatus) Тогда
		vMessage = NStr("ru='Не указан статус негарантированной брони!';
		                |de='Status einer nicht garantierten Reservierung ist nicht angegeben!';
						|en='Non guaranteed reservations status is not set!'");
		WriteLogEvent(NStr("en='DataProcessor.DisableNonGuaranteedReservations';ru='Обработка.СнятьНегарантированнуюБронь';de='DataProcessor.DisableNonGuaranteedReservations'"), EventLogLevel.Warning, ThisObject.Metadata(), Неопределено, vMessage);
		If pIsInteractive Тогда
			Message(vMessage, MessageStatus.Attention);
			Return;
		Else
			ВызватьИсключение vMessage;
		EndIf;
	EndIf;
	If НЕ ЗначениеЗаполнено(CanceledReservationStatus) Тогда
		vMessage = NStr("ru='Не указан статус отмененной брони!';
		                |de='Der Status einer gelöschten Reservierung ist nicht angegeben!';
						|en='Canceled reservations status is not set!'");
		WriteLogEvent(NStr("en='DataProcessor.DisableNonGuaranteedReservations';ru='Обработка.СнятьНегарантированнуюБронь';de='DataProcessor.DisableNonGuaranteedReservations'"), EventLogLevel.Warning, ThisObject.Metadata(), Неопределено, vMessage);
		If pIsInteractive Тогда
			Message(vMessage, MessageStatus.Attention);
			Return;
		Else
			ВызватьИсключение vMessage;
		EndIf;
	EndIf;
	If PeriodToKeepReservations <= 0 Тогда
		vMessage = NStr("ru='Не указан период удержания негарантированной брони в минутах!';
		                |de='Zeitraum für die Aufrechterhaltung einer nicht garantierten Reservierung in Minuten!'; 
						|en='Period to keep non guaranteed reservations in minutes is not set!'");
		WriteLogEvent(NStr("en='DataProcessor.DisableNonGuaranteedReservations';ru='Обработка.СнятьНегарантированнуюБронь';de='DataProcessor.DisableNonGuaranteedReservations'"), EventLogLevel.Warning, ThisObject.Metadata(), Неопределено, vMessage);
		If pIsInteractive Тогда
			Message(vMessage, MessageStatus.Attention);
			Return;
		Else
			ВызватьИсключение vMessage;
		EndIf;
	EndIf;
	// Calculate time to check reservation statuses
	vCheckTime = CurrentDate() - 60 * PeriodToKeepReservations;
	// Get list of reservations to process
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	ЗагрузкаНомеров.Recorder AS Reservation
	|FROM
	|	AccumulationRegister.ЗагрузкаНомеров AS RoomInventory
	|WHERE
	|	ЗагрузкаНомеров.ReservationStatus = &qNonGuaranteedReservationStatus 
	|	AND ЗагрузкаНомеров.Recorder.ДатаДок < &qCancellationDate " + 
		?(ЗначениеЗаполнено(Гостиница), " AND ЗагрузкаНомеров.Гостиница IN HIERARCHY (&qHotel)", "") + "
	|	AND (ЗагрузкаНомеров.ЗабронированоМест > 0
	|			OR ЗагрузкаНомеров.ЗабронДопМест > 0
	|			OR ЗагрузкаНомеров.ЗабронГостей > 0)
	|	AND ЗагрузкаНомеров.RecordType = &qExpense
	|
	|GROUP BY
	|	ЗагрузкаНомеров.Recorder
	|
	|ORDER BY
	|	ЗагрузкаНомеров.Recorder.PointInTime";
	vQry.SetParameter("qNonGuaranteedReservationStatus", NonGuaranteedReservationStatus);
	vQry.SetParameter("qCancellationDate", vCheckTime);
	vQry.SetParameter("qHotel", Гостиница);
	vQry.SetParameter("qExpense", AccumulationRecordType.Expense);
	vReservations = vQry.Execute().Unload();
	// Change reservation status for each reservation and post it
	For Each vReservationsRow In vReservations Do
		Try
			vReservationRef = vReservationsRow.Reservation;
			vReservationObj = Неопределено;
			vReservationObj = vReservationRef.GetObject();
			
			
			// Check non guaranteed reservation status set time
			vResObjState = GetChangeStatusReservationState(vReservationRef);
			If vResObjState <> Неопределено Тогда
				If vResObjState.Period >= vCheckTime Тогда
					Continue;
				EndIf;
			EndIf;
			
			// Set reservation status
			vReservationObj.ReservationStatus = CanceledReservationStatus;
			vReservationObj.pmSetDoCharging();
			If (vReservationObj.ReservationStatus.DoNoShowCharging Or vReservationObj.ReservationStatus.DoLateAnnulationCharging) Тогда
				vReservationObj.pmCalculateServices();
			EndIf;
			vReservationObj.Write(DocumentWriteMode.Posting);
			// Save data to the document history
			vReservationObj.pmWriteToReservationChangeHistory(CurrentDate(), ПараметрыСеанса.ТекПользователь);
			
			// Log current state
			vMessage = NStr("ru='Обработан документ: " + String(vReservationObj.Ref) + " - группа № " + TrimAll(vReservationObj.ГруппаГостей) + "'; 
			                |de='Document " + String(vReservationObj.Ref) + " - group N " + TrimAll(vReservationObj.ГруппаГостей) + " was processed'; 
			                |en='Document " + String(vReservationObj.Ref) + " - group N " + TrimAll(vReservationObj.ГруппаГостей) + " was processed'");
			WriteLogEvent(NStr("en='DataProcessor.DisableNonGuaranteedReservations';ru='Обработка.СнятьНегарантированнуюБронь';de='DataProcessor.DisableNonGuaranteedReservations'"), EventLogLevel.Information, ThisObject.Metadata(), vReservationObj.Ref, vMessage);
			If pIsInteractive Тогда
				Message(vMessage, MessageStatus.Information);
			EndIf;
		Except
			vMessage = ErrorDescription();
			WriteLogEvent(NStr("en='DataProcessor.DisableNonGuaranteedReservations';ru='Обработка.СнятьНегарантированнуюБронь';de='DataProcessor.DisableNonGuaranteedReservations'"), EventLogLevel.Warning, ThisObject.Metadata(), ?(vReservationObj = Неопределено, Неопределено, vReservationObj.Ref), vMessage);
			If pIsInteractive Тогда
				Message(vMessage, MessageStatus.Attention);
			EndIf;
		EndTry;
	EndDo;
	WriteLogEvent(NStr("en='DataProcessor.DisableNonGuaranteedReservations';ru='Обработка.СнятьНегарантированнуюБронь';de='DataProcessor.DisableNonGuaranteedReservations'"), EventLogLevel.Information, ThisObject.Metadata(), Неопределено, NStr("en='End of processing';ru='Конец выполнения';de='Ende des Ausführung'"));
КонецПроцедуры //pmCancelNonGuaranteedReservations
