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
	If PeriodToWait = 0 Тогда
		PeriodToWait = 1;
	EndIf;
	If НЕ ЗначениеЗаполнено(Гостиница) Тогда
		Гостиница = ПараметрыСеанса.ТекущаяГостиница;
	EndIf;
	// Try to find active resource reservation status with both "Do charging" and 
	// "Services are delivered" flags checked
	If НЕ ЗначениеЗаполнено(FinishedResourceReservationStatus) Тогда
		vQry = New Query();
		vQry.Text = 
		"SELECT TOP 1
		|	СтатусБрониРесурсов.Ref
		|FROM
		|	Catalog.СтатусБрониРесурсов AS СтатусБрониРесурсов
		|WHERE
		|	(NOT СтатусБрониРесурсов.DeletionMark)
		|	AND (NOT СтатусБрониРесурсов.IsFolder)
		|	AND СтатусБрониРесурсов.IsActive
		|	AND СтатусБрониРесурсов.DoCharging
		|	AND СтатусБрониРесурсов.ServicesAreDelivered";
		vStses = vQry.Execute().Unload();
		If vStses.Count() > 0 Тогда
			FinishedResourceReservationStatus = vStses.Get(0).Ref;
		EndIf;
	EndIf;
	// Set processing date time
	ProcessingDateTime = CurrentDate() - PeriodToWait*3600;
КонецПроцедуры //pmFillAttributesWithDefaultValues

//-----------------------------------------------------------------------------
// Run data processor in silent mode
//-----------------------------------------------------------------------------
Процедура pmRun(pParameter = Неопределено, pIsInteractive = False) Экспорт
	// Process finished resource reservations
	pmProcessFinishedResourceReservations(pIsInteractive);
КонецПроцедуры //pmRun

//-----------------------------------------------------------------------------
// Data processors framework end
//-----------------------------------------------------------------------------
	
//-----------------------------------------------------------------------------
Процедура pmProcessFinishedResourceReservations(pIsInteractive = False) Экспорт
	WriteLogEvent(NStr("en='DataProcessor.ProcessFinishedResourceReservations';ru='Обработка.ОбработкаЗавершеннойБрониРесурсов';de='DataProcessor.ProcessFinishedResourceReservations'"), EventLogLevel.Information, ThisObject.Metadata(), Неопределено, NStr("en='Start of processing';ru='Начало выполнения';de='Anfang der Ausführung'"));
	// Check parameters
	WriteLogEvent(NStr("en='DataProcessor.ProcessFinishedResourceReservations';ru='Обработка.ОбработкаЗавершеннойБрониРесурсов';de='DataProcessor.ProcessFinishedResourceReservations'"), EventLogLevel.Information, ThisObject.Metadata(), FinishedResourceReservationStatus, NStr("en='Гостиница: ';ru='Гостиница: ';de='Гостиница: '") + TrimAll(Гостиница));
	If НЕ ЗначениеЗаполнено(FinishedResourceReservationStatus) Тогда
		vMessage = NStr("ru='Не указан статус завершенной брони!';
		                |de='Der Status einer abgeschlossenen Reservierung ist nicht angegeben!';
						|en='Finished resource reservation status is not set!'");
		WriteLogEvent(NStr("en='DataProcessor.ProcessFinishedResourceReservations';ru='Обработка.ОбработкаЗавершеннойБрониРесурсов';de='DataProcessor.ProcessFinishedResourceReservations'"), EventLogLevel.Warning, ThisObject.Metadata(), Неопределено, vMessage);
		If pIsInteractive Тогда
			Message(vMessage, MessageStatus.Attention);
			Return;
		Else
			ВызватьИсключение vMessage;
		EndIf;
	Else
		WriteLogEvent(NStr("en='DataProcessor.ProcessFinishedResourceReservations';ru='Обработка.ОбработкаЗавершеннойБрониРесурсов';de='DataProcessor.ProcessFinishedResourceReservations'"), EventLogLevel.Information, ThisObject.Metadata(), FinishedResourceReservationStatus, NStr("en='Finished resource reservation status: ';ru='Статус завершенной брони: ';de='Status der abgeschlossenen Reservierung: '") + TrimAll(FinishedResourceReservationStatus));
	EndIf;
	If НЕ ЗначениеЗаполнено(ProcessingDateTime) Тогда
		vMessage = NStr("ru='Не указана дата, на которую считать бронь завершенной!';
		                |de='Das Datum, an dem die Reservierung als abgeschlossen betrachtet werden kann, ist nicht angegeben!'; 
						|en='Finished resource reservation date is not set!'");
		WriteLogEvent(NStr("en='DataProcessor.ProcessFinishedResourceReservations';ru='Обработка.ОбработкаЗавершеннойБрониРесурсов';de='DataProcessor.ProcessFinishedResourceReservations'"), EventLogLevel.Warning, ThisObject.Metadata(), Неопределено, vMessage);
		If pIsInteractive Тогда
			Message(vMessage, MessageStatus.Attention);
			Return;
		Else
			ВызватьИсключение vMessage;
		EndIf;
	Else
		WriteLogEvent(NStr("en='DataProcessor.ProcessFinishedResourceReservations';ru='Обработка.ОбработкаЗавершеннойБрониРесурсов';de='DataProcessor.ProcessFinishedResourceReservations'"), EventLogLevel.Information, ThisObject.Metadata(), Неопределено, NStr("en='Finished resource reservation date and time: ';ru='Дата и время на которые считать бронь завершенной: ';de='Datum und Zeit, zu denen die Reservierung als abgeschlossen gelten kann: '") + Format(ProcessingDateTime, "DF='dd.MM.yyyy HH:mm'"));
	EndIf;
	// Get list of resource reservations to process
	vQry = New Query();
	vQry.Text = 
	"SELECT DISTINCT
	|	ResourceReservations.Ref AS БроньУслуг,
	|	ResourceReservations.Ref.PointInTime AS PointInTime
	|FROM
	|	Document.БроньУслуг AS ResourceReservations
	|WHERE
	|	ResourceReservations.Posted
	|	AND NOT ResourceReservations.ResourceReservationStatus.ServicesAreDelivered
	|	AND ResourceReservations.ResourceReservationStatus.IsActive
	|	AND ResourceReservations.Ref.DateTimeTo <= &qProcessingDateTime
	|	AND ResourceReservations.ResourceReservationStatus <> &qFinishedResourceReservationStatus
	|	AND (ResourceReservations.Гостиница IN HIERARCHY (&qHotel)
	|			OR &qHotelIsEmpty)
	|
	|ORDER BY
	|	ResourceReservations.Ref.PointInTime";
	vQry.SetParameter("qProcessingDateTime", ProcessingDateTime);
	vQry.SetParameter("qFinishedResourceReservationStatus", FinishedResourceReservationStatus);
	vQry.SetParameter("qHotel", Гостиница);
	vQry.SetParameter("qHotelIsEmpty", НЕ ЗначениеЗаполнено(Гостиница));
	vReservations = vQry.Execute().Unload();
	// Change reservation status for each reservation and post it
	For Each vReservationsRow In vReservations Do
		Try
			vReservationObj = vReservationsRow.ResourceReservation.GetObject();
			If TypeOf(vReservationObj.Ref) <> Type("DocumentRef.БроньУслуг") Тогда
				Continue;
			EndIf;
			vReservationObj.ResourceReservationStatus = FinishedResourceReservationStatus;
			vReservationObj.DoCharging = FinishedResourceReservationStatus.DoCharging;
			vReservationObj.Write(DocumentWriteMode.Posting);
			// Save data to the document history
			vReservationObj.pmWriteToResourceReservationChangeHistory(CurrentDate(), ПараметрыСеанса.ТекПользователь);
			
			// Log current state
			vMessage = NStr("ru = 'Обработан документ: " + String(vReservationObj.Ref) + " - группа № " + TrimAll(vReservationObj.ГруппаГостей) + "'; 
			                |de = 'Document " + String(vReservationObj.Ref) + " - group N " + TrimAll(vReservationObj.ГруппаГостей) + " was processed'; 
			                |en = 'Document " + String(vReservationObj.Ref) + " - group N " + TrimAll(vReservationObj.ГруппаГостей) + " was processed'");
			WriteLogEvent(NStr("en='DataProcessor.ProcessFinishedResourceReservations';ru='Обработка.ОбработкаЗавершеннойБрониРесурсов';de='DataProcessor.ProcessFinishedResourceReservations'"), EventLogLevel.Information, ThisObject.Metadata(), vReservationObj.Ref, vMessage);
			If pIsInteractive Тогда
				Message(vMessage, MessageStatus.Information);
			Endif;
		Except
			vMessage = ErrorDescription();
			WriteLogEvent(NStr("en='DataProcessor.ProcessFinishedResourceReservations';ru='Обработка.ОбработкаЗавершеннойБрониРесурсов';de='DataProcessor.ProcessFinishedResourceReservations'"), EventLogLevel.Warning, ThisObject.Metadata(), ?(vReservationObj = Неопределено, Неопределено, vReservationObj.Ref), vMessage);
			If pIsInteractive Тогда
				Message(vMessage, MessageStatus.Attention);
			EndIf;
		EndTry;
	EndDo;
	WriteLogEvent(NStr("en='DataProcessor.ProcessFinishedResourceReservations';ru='Обработка.ОбработкаЗавершеннойБрониРесурсов';de='DataProcessor.ProcessFinishedResourceReservations'"), EventLogLevel.Information, ThisObject.Metadata(), Неопределено, NStr("en='End of processing';ru='Конец выполнения';de='Ende des Ausführung'"));
КонецПроцедуры //pmProcessFinishedResourceReservations
