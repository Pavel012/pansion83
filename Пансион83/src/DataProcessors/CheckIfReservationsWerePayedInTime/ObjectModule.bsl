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
	EndIf;
	If НЕ ЗначениеЗаполнено(GuaranteedReservationStatus) Тогда
		If ЗначениеЗаполнено(Гостиница) Тогда
			GuaranteedReservationStatus = Гостиница.GuaranteedReservationStatus;
		EndIf;
	EndIf;
	If НЕ ЗначениеЗаполнено(PaymentDateExpiredReservationStatus) Тогда
		If ЗначениеЗаполнено(Гостиница) Тогда
			PaymentDateExpiredReservationStatus = Гостиница.PaymentDateExpiredReservationStatus;
		EndIf;
	EndIf;
	If НЕ ЗначениеЗаполнено(PaymentTimeExpiredReservationStatus) Тогда
		If ЗначениеЗаполнено(Гостиница) Тогда
			PaymentTimeExpiredReservationStatus = Гостиница.PaymentDateExpiredReservationStatus;
		EndIf;
	EndIf;
	If TimeToWaitOnlineReservationPayment = 0 Тогда
		TimeToWaitOnlineReservationPayment = 120;
	EndIf;
	If НЕ ЗначениеЗаполнено(DepartmentToSendNotificationsTo) Тогда
		If ЗначениеЗаполнено(Гостиница) Тогда
			DepartmentToSendNotificationsTo = Гостиница.ReservationDepartment;
		EndIf;
	EndIf;
КонецПроцедуры //pmFillAttributesWithDefaultValues

//-----------------------------------------------------------------------------
// Run data processor in silent mode
//-----------------------------------------------------------------------------
Процедура pmRun(pParameter = Неопределено, pIsInteractive = False) Экспорт
	// Check reservations
	pmDoCheck(pIsInteractive);
КонецПроцедуры //pmRun

//-----------------------------------------------------------------------------
// Data processors framework end
//-----------------------------------------------------------------------------
	
//-----------------------------------------------------------------------------
Процедура pmDoCheck(pIsInteractive = False) Экспорт
	WriteLogEvent("Обработка.ПроверитьПоступлениеОплатыПоБрони", EventLogLevel.Information, ThisObject.Metadata(), Неопределено,"Начало выполнения';de='Anfang der Ausführung'");
	If ЗначениеЗаполнено(GuaranteedReservationStatus) Or ЗначениеЗаполнено(FullyPaidReservationStatus) Or ЗначениеЗаполнено(GuaranteedOnlineReservationStatus) Тогда
		vGuestGroups = New СписокЗначений();
		// Get list of reservations with payments received
		vQry = New Query();
		vQry.Text = 
		"SELECT
		|	Reservations.ГруппаГостей AS ГруппаГостей
		|INTO PayedGuestGroups
		|FROM
		|	Document.Reservation AS Reservations
		|		INNER JOIN (SELECT
		|			Платежи.ГруппаГостей AS ГруппаГостей,
		|			Платежи.SumExpense AS Сумма
		|		FROM
		|			AccumulationRegister.ВзаиморасчетыКонтрагенты.BalanceAndTurnovers(
		|					&qPeriodFrom,
		|					&qPeriodTo,
		|					Period,
		|					RegisterRecords,
		|					NOT &qHotelIsFilled
		|						OR &qHotelIsFilled
		|							AND Гостиница IN HIERARCHY (&qHotel)) AS Платежи) AS GuestGroupTurnovers
		|		ON (GuestGroupTurnovers.ГруппаГостей = Reservations.ГруппаГостей)
		|WHERE
		|	Reservations.Posted
		|	AND NOT Reservations.ReservationStatus.IsAnnulation
		|	AND NOT Reservations.ReservationStatus.ЭтоЗаезд
		|	AND NOT Reservations.ReservationStatus.IsNoShow
		|	AND NOT Reservations.ReservationStatus.IsFullyPaid
		|	AND (NOT &qHotelIsFilled
		|			OR &qHotelIsFilled
		|				AND Reservations.Гостиница IN HIERARCHY (&qHotel))
		|	AND (NOT Reservations.ReservationStatus.IsActive
		|				AND (Reservations.КоличествоМест = 0
		|					AND Reservations.КолДопМест = 0
		|					AND Reservations.КоличествоЧеловек = 0)
		|			OR (Reservations.ReservationStatus.IsActive
		|				OR Reservations.ReservationStatus.IsPreliminary)
		|				AND (Reservations.КоличествоМест > 0
		|					OR Reservations.КолДопМест > 0
		|					OR Reservations.КоличествоЧеловек > 0))
		|
		|GROUP BY
		|	Reservations.ГруппаГостей
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|SELECT
		|	Reservations.Ref AS Reservation,
		|	Reservations.ReservationStatus AS ReservationStatus,
		|	Reservations.ГруппаГостей AS ГруппаГостей
		|FROM
		|	Document.Reservation AS Reservations
		|		INNER JOIN PayedGuestGroups AS PayedGuestGroups
		|		ON Reservations.ГруппаГостей = PayedGuestGroups.ГруппаГостей
		|WHERE
		|	Reservations.Posted
		|	AND NOT Reservations.ReservationStatus.IsAnnulation
		|	AND NOT Reservations.ReservationStatus.ЭтоЗаезд
		|	AND NOT Reservations.ReservationStatus.IsNoShow
		|	AND NOT Reservations.ReservationStatus.IsFullyPaid
		|	AND (NOT &qHotelIsFilled
		|			OR &qHotelIsFilled
		|				AND Reservations.Гостиница IN HIERARCHY (&qHotel))
		|	AND (NOT Reservations.ReservationStatus.IsActive
		|				AND (Reservations.КоличествоМест = 0
		|					AND Reservations.КолДопМест = 0
		|					AND Reservations.КоличествоЧеловек = 0)
		|			OR (Reservations.ReservationStatus.IsActive
		|				OR Reservations.ReservationStatus.IsPreliminary)
		|				AND (Reservations.КоличествоМест > 0
		|					OR Reservations.КолДопМест > 0
		|					OR Reservations.КоличествоЧеловек > 0))
		|
		|GROUP BY
		|	Reservations.Ref,
		|	Reservations.ГруппаГостей,
		|	Reservations.ReservationStatus
		|
		|ORDER BY
		|	Reservations.ГруппаГостей.Code,
		|	Reservations.Ref.PointInTime";
		vQry.SetParameter("qPeriodFrom", '00010101');
		vQry.SetParameter("qPeriodTo", '39991231');
		vQry.SetParameter("qHotel", Гостиница);
		vQry.SetParameter("qHotelIsFilled", ЗначениеЗаполнено(Гостиница));
		vReservations = vQry.Execute().Unload();
		// Change reservation status for each reservation and post it
		vCurGuestGroup = Неопределено;
		vGroupIsFullyPaid = False;
		For Each vReservationsRow In vReservations Do
			Try
				// Check if group is fully paid
				If ЗначениеЗаполнено(FullyPaidReservationStatus) Тогда
					If vCurGuestGroup <> vReservationsRow.GuestGroup Тогда
						vGroupIsFullyPaid = False;
						vCurGuestGroup = vReservationsRow.GuestGroup;
						vCurGuestGroupObj = vCurGuestGroup.GetObject();
						vGroupSales = vCurGuestGroupObj.pmGetSalesTotals();
						vGroupSales.GroupBy("Валюта", "Продажи, ПрогнозПродаж");
						vGroupPayments = vCurGuestGroupObj.pmGetPaymentsTotals();
						If vGroupSales.Count() > 0 And vGroupSales.Count() = vGroupPayments.Count() Тогда
							vGroupIsPayed = True;
							i = 0;
							While i < vGroupSales.Count() Do
								vGroupSalesRow = vGroupSales.Get(i);
								vGroupPaymentsRow = vGroupPayments.Get(i);
								If vGroupSalesRow.Валюта <> vGroupPaymentsRow.Валюта Or 
								   vGroupSalesRow.Валюта = vGroupPaymentsRow.Валюта And 
								  (vGroupSalesRow.Продажи + vGroupSalesRow.ПрогнозПродаж) > vGroupPaymentsRow.Сумма Тогда
									vGroupIsPayed = False;
									Break;
								EndIf;
								i = i + 1;
							EndDo;
							If vGroupIsPayed Тогда
								vGroupIsFullyPaid = True;
							EndIf;
						EndIf;
					EndIf;
				EndIf;
				
				// Get reservation object
				vReservationRef = vReservationsRow.Reservation;
//				If TypeOf(vReservationRef) <> Type("DocumentRef.Reservation") Тогда
//					Continue;
//				EndIf;
				vReservationRefReservationStatus = vReservationsRow.ReservationStatus;
				
				// Set reservation status
				vNewReservationStatus = Неопределено;
				If ЗначениеЗаполнено(FullyPaidReservationStatus) And vGroupIsFullyPaid And vReservationRef.ReservationStatus <> FullyPaidReservationStatus And НЕ vReservationRef.ReservationStatus.IsFullyPaid Тогда
					vNewReservationStatus = FullyPaidReservationStatus;
				ElsIf ЗначениеЗаполнено(GuaranteedOnlineReservationStatus) And vReservationRefReservationStatus = NewOnlineReservationStatus Тогда
					vNewReservationStatus = GuaranteedOnlineReservationStatus;
				ElsIf ЗначениеЗаполнено(GuaranteedReservationStatus) And vReservationRefReservationStatus <> GuaranteedReservationStatus And НЕ vReservationRefReservationStatus.IsGuaranteed Тогда
					vNewReservationStatus = GuaranteedReservationStatus;
				Else
					Continue;
				EndIf;
				vReservationObj = vReservationRef.GetObject();
				vReservationObj.ReservationStatus = vNewReservationStatus;
				vReservationObj.GuaranteeType = GuaranteeType;
				vReservationObj.pmSetDoCharging();
				If (GuaranteedReservationStatus.DoNoShowCharging Or GuaranteedReservationStatus.DoLateAnnulationCharging) Тогда
					vReservationObj.pmCalculateServices();
				EndIf;
				vReservationObj.Write(DocumentWriteMode.Posting);
				
				// Save data to the document history
				vReservationObj.pmWriteToReservationChangeHistory(CurrentDate(), ПараметрыСеанса.ТекПользователь);
				
				// Log current state
				vMessage = NStr("ru='Обработан документ: " + String(vReservationObj.Ref) + " - группа № " + TrimAll(vReservationObj.ГруппаГостей) + ", статус установлен в " + TrimAll(vReservationObj.ReservationStatus) + ""); 
				WriteLogEvent("Обработка.ПроверитьПоступлениеОплатыПоБрони", EventLogLevel.Information, ThisObject.Metadata(), vReservationObj.Ref, vMessage);
				If pIsInteractive Тогда
					Message(vMessage, MessageStatus.Information);
				EndIf;
				
				// Write guest group attachement
				If ЗначениеЗаполнено(ReplyMessageType) And ReplyMessageType = Перечисления.AttachmentTypes.EMail Тогда
					vGuestGroupRef = vReservationObj.ГруппаГостей;
					If vGuestGroups.FindByValue(vGuestGroupRef) = Неопределено Тогда
						vGuestGroups.Add(vGuestGroupRef);
						
						//vLanguage = vHotel.Language;
//						If ЗначениеЗаполнено(vGuestGroupRef.Клиент) And ЗначениеЗаполнено(vGuestGroupRef.Клиент.Language) Тогда
//							vLanguage = vGuestGroupRef.Клиент.Language;
//						EndIf;
						// Build message text
//						vRemarks = vHotel.GetObject().pmGetHotelPrintName(vLanguage) + 
//						           "Статус брони № " + Format(vGuestGroupRef.Code, "ND=12; NFD=0; NG=") + " изменен на " + GuaranteedReservationStatus.GetObject().pmGetReservationStatusDescription(vLanguage) + "'";
						//vDocumentText = "Автоматизированная система рассылки уведомлений об изменении статусов брони:'"+
						                       // Chars.LF + Chars.LF +
//						                ?(ЗначениеЗаполнено(vGuestGroupRef) And ЗначениеЗаполнено(vGuestGroupRef.Клиент), "Клиент:" + TrimAll(vGuestGroupRef.Клиент.FullName) + Chars.LF, "") + 
//						                ?(ЗначениеЗаполнено(vGuestGroupRef) And ЗначениеЗаполнено(vGuestGroupRef.CheckInDate) And ЗначениеЗаполнено(vGuestGroupRef.CheckOutDate), "Период проживания: " + Format(vGuestGroupRef.CheckInDate, "DF='dd.MM.yyyy HH:mm'") + " - "  + Format(vGuestGroupRef.CheckOutDate, "DF='dd.MM.yyyy HH:mm'") + Chars.LF, "") + 
//						                Chars.LF + 
//						                "Статус брони № " + Format(vGuestGroupRef.Code, "ND=12; NFD=0; NG=") + " изменен на " + GuaranteedReservationStatus.GetObject().pmGetReservationStatusDescription(vLanguage) + "'" + Chars.LF + Chars.LF + 
//						                "С уважением," + Chars.LF + 
//						                vHotel.GetObject().pmGetHotelPrintName(vLanguage) + Chars.LF + 
//								        ПараметрыСеанса.ИмяКонфигурации;
						// Call user exit procedure to give possibility to override message subject ans message text
						vUserExitProc = Справочники.ВнешниеОбработки.WriteGuestGroupPaymentConfirmation;
						If ЗначениеЗаполнено(vUserExitProc) Тогда
							If vUserExitProc.ExternalProcessingType = Перечисления.ExternalProcessingTypes.Algorithm Тогда
								If НЕ IsBlankString(vUserExitProc.Algorithm) Тогда
									Execute(TrimAll(vUserExitProc.Algorithm));
								EndIf;
							EndIf;
						EndIf;
						// Write attachment
						
					EndIf;
				EndIf;
			Except
				vMessage = ErrorDescription();
				WriteLogEvent("Обработка.ПроверитьПоступлениеОплатыПоБрони", EventLogLevel.Warning, ThisObject.Metadata(), ?(vReservationObj = Неопределено, Неопределено, vReservationObj.Ref), vMessage);
				If pIsInteractive Тогда
					Message(vMessage, MessageStatus.Attention);
				EndIf;
			EndTry;
		EndDo;
	EndIf;
	// Get list of reservations with expired payment date
	vGuestGroups = New СписокЗначений();
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	Reservations.ГруппаГостей AS ГруппаГостей
	|INTO PayedGuestGroups
	|FROM
	|	Document.Reservation AS Reservations
	|		INNER JOIN (SELECT
	|			Платежи.ГруппаГостей AS ГруппаГостей,
	|			Платежи.SumExpense AS Сумма
	|		FROM
	|			AccumulationRegister.ВзаиморасчетыКонтрагенты.BalanceAndTurnovers(
	|					&qPeriodFrom,
	|					&qPeriodTo,
	|					Period,
	|					RegisterRecords,
	|					NOT &qHotelIsFilled
	|						OR &qHotelIsFilled
	|							AND Гостиница IN HIERARCHY (&qHotel)) AS Платежи) AS GuestGroupTurnovers
	|		ON (GuestGroupTurnovers.ГруппаГостей = Reservations.ГруппаГостей)
	|WHERE
	|	Reservations.Posted
	|	AND NOT Reservations.ReservationStatus.IsAnnulation
	|	AND NOT Reservations.ReservationStatus.ЭтоЗаезд
	|	AND NOT Reservations.ReservationStatus.IsNoShow
	|	AND NOT Reservations.ReservationStatus.IsFullyPaid
	|	AND (NOT &qHotelIsFilled
	|			OR &qHotelIsFilled
	|				AND Reservations.Гостиница IN HIERARCHY (&qHotel))
	|	AND (NOT Reservations.ReservationStatus.IsActive
	|				AND (Reservations.КоличествоМест = 0
	|					AND Reservations.КолДопМест = 0
	|					AND Reservations.КоличествоЧеловек = 0)
	|			OR (Reservations.ReservationStatus.IsActive
	|				OR Reservations.ReservationStatus.IsPreliminary)
	|				AND (Reservations.КоличествоМест > 0
	|					OR Reservations.КолДопМест > 0
	|					OR Reservations.КоличествоЧеловек > 0))
	|
	|GROUP BY
	|	Reservations.ГруппаГостей
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	Reservations.Ref AS Reservation,
	|	Reservations.ReservationStatus AS ReservationStatus,
	|	Reservations.ГруппаГостей AS ГруппаГостей,
	|	Reservations.ГруппаГостей.CheckDate AS CheckDate
	|FROM
	|	Document.Reservation AS Reservations
	|WHERE
	|	Reservations.Posted
	|	AND Reservations.ReservationStatus <> &qPaymentDateExpiredReservationStatus
	|	AND Reservations.ReservationStatus <> &qPaymentTimeExpiredReservationStatus
	|	AND Reservations.ReservationStatus <> &qGuaranteedReservationStatus
	|	AND Reservations.ReservationStatus <> &qFullyPaidReservationStatus
	|	AND Reservations.ReservationStatus <> &qGuaranteedOnlineReservationStatus
	|	AND NOT Reservations.ReservationStatus.IsGuaranteed
	|	AND NOT Reservations.ReservationStatus.ЭтоЗаезд
	|	AND NOT Reservations.ReservationStatus.IsNoShow
	|	AND NOT Reservations.ReservationStatus.IsFullyPaid
	|	AND (Reservations.ГруппаГостей.CheckDate <= &qCheckDate
	|				AND Reservations.ГруппаГостей.CheckDate > &qEmptyDate
	|			OR Reservations.ReservationStatus = &qNewOnlineReservationStatus
	|				AND Reservations.ДатаДок <= &qOnlineCheckDate)
	|	AND (NOT &qHotelIsFilled
	|			OR &qHotelIsFilled
	|				AND Reservations.Гостиница IN HIERARCHY (&qHotel))
	|	AND (NOT Reservations.ReservationStatus.IsActive
	|				AND (Reservations.КоличествоМест = 0
	|					AND Reservations.КолДопМест = 0
	|					AND Reservations.КоличествоЧеловек = 0)
	|			OR (Reservations.ReservationStatus.IsActive
	|				OR Reservations.ReservationStatus.IsPreliminary)
	|				AND (Reservations.КоличествоМест > 0
	|					OR Reservations.КолДопМест > 0
	|					OR Reservations.КоличествоЧеловек > 0))
	|	AND NOT Reservations.ГруппаГостей IN
	|				(SELECT
	|					PayedGuestGroups.ГруппаГостей
	|				FROM
	|					PayedGuestGroups AS PayedGuestGroups)
	|
	|GROUP BY
	|	Reservations.Ref,
	|	Reservations.ГруппаГостей,
	|	Reservations.ГруппаГостей.CheckDate
	|
	|ORDER BY
	|	Reservations.Ref.PointInTime";
	vQry.SetParameter("qPaymentDateExpiredReservationStatus", PaymentDateExpiredReservationStatus);
	vQry.SetParameter("qPaymentTimeExpiredReservationStatus", PaymentTimeExpiredReservationStatus);
	vQry.SetParameter("qGuaranteedReservationStatus", GuaranteedReservationStatus);
	vQry.SetParameter("qFullyPaidReservationStatus", FullyPaidReservationStatus);
	vQry.SetParameter("qGuaranteedOnlineReservationStatus", GuaranteedOnlineReservationStatus);
	vQry.SetParameter("qNewOnlineReservationStatus", NewOnlineReservationStatus);
	vQry.SetParameter("qCheckDate", BegOfDay(CurrentDate()));
	vQry.SetParameter("qOnlineCheckDate", CurrentDate() - TimeToWaitOnlineReservationPayment * 60);
	vQry.SetParameter("qEmptyDate", '00010101');
	vQry.SetParameter("qPeriodFrom", '00010101');
	vQry.SetParameter("qPeriodTo", '39991231');
	vQry.SetParameter("qHotel", Гостиница);
	vQry.SetParameter("qHotelIsFilled", ЗначениеЗаполнено(Гостиница));
	vReservations = vQry.Execute().Unload();
	// Change reservation status for each reservation and post it
	vProcessedGuestGroups = New ValueTable();
//	vProcessedGuestGroups.Columns.Add("ГруппаГостей", cmGetCatalogTypeDescription("ГруппыГостей"));
//	vProcessedGuestGroups.Columns.Add("CheckDate", cmGetDateTimeTypeDescription());
	If ЗначениеЗаполнено(PaymentDateExpiredReservationStatus) Or ЗначениеЗаполнено(PaymentTimeExpiredReservationStatus) Тогда
		For Each vReservationsRow In vReservations Do
			Try
				vReservationRef = vReservationsRow.Reservation;
//				If TypeOf(vReservationRef) <> Type("DocumentRef.Reservation") Тогда
//					Continue;
//				EndIf;
				vReservationRefReservationStatus = vReservationsRow.ReservationStatus;
				
				// Set reservation status
				vNewReservationStatus = Неопределено;
				If ЗначениеЗаполнено(PaymentTimeExpiredReservationStatus) And vReservationRefReservationStatus = NewOnlineReservationStatus Тогда
					vNewReservationStatus = PaymentTimeExpiredReservationStatus;
				ElsIf ЗначениеЗаполнено(PaymentDateExpiredReservationStatus) Тогда
					vNewReservationStatus = PaymentDateExpiredReservationStatus;
				Else
					Continue;
				EndIf;
				vReservationObj = vReservationRef.GetObject();
				vReservationObj.ReservationStatus = vNewReservationStatus;
				vReservationObj.pmSetDoCharging();
				If (vReservationObj.ReservationStatus.DoNoShowCharging And vReservationObj.ReservationStatus.DoLateAnnulationCharging) Тогда
					vReservationObj.pmCalculateServices();
				EndIf;
				vReservationObj.Write(DocumentWriteMode.Posting);
				// Save data to the document history
				vReservationObj.pmWriteToReservationChangeHistory(CurrentDate(), ПараметрыСеанса.ТекПользователь);
				
				vPGRow = vProcessedGuestGroups.Add();
				vPGRow.ГруппаГостей = vReservationsRow.GuestGroup;
				vPGRow.CheckDate = vReservationsRow.CheckDate;
				
				// Log current state
				vMessage = NStr("ru='Обработан документ: " + String(vReservationObj.Ref) + " - группа № " + TrimAll(vReservationObj.ГруппаГостей) + ", статус установлен в " + TrimAll(vReservationObj.ReservationStatus) + "'; 
				                |de='Document " + String(vReservationObj.Ref) + " - group N " + TrimAll(vReservationObj.ГруппаГостей) + " was processed, status was set to " + TrimAll(vReservationObj.ReservationStatus) + "'; 
								|en='Document " + String(vReservationObj.Ref) + " - group N " + TrimAll(vReservationObj.ГруппаГостей) + " was processed, status was set to " + TrimAll(vReservationObj.ReservationStatus) + "'");
				WriteLogEvent(NStr("en='DataProcessor.CheckIfReservationsWerePayedInTime';ru='Обработка.ПроверитьПоступлениеОплатыПоБрони';de='DataProcessor.CheckIfReservationsWerePayedInTime'"), EventLogLevel.Information, ThisObject.Metadata(), vReservationObj.Ref, vMessage);
				If pIsInteractive Тогда
					Message(vMessage, MessageStatus.Information);
				Endif;
				
				// Write guest group attachement
				If ЗначениеЗаполнено(ReplyMessageType) And ReplyMessageType = Перечисления.AttachmentTypes.EMail Тогда
					vGuestGroupRef = vReservationObj.ГруппаГостей;
					If vGuestGroups.FindByValue(vGuestGroupRef) = Неопределено Тогда
						vGuestGroups.Add(vGuestGroupRef);
				
//						If ЗначениеЗаполнено(vGuestGroupRef.Клиент) And ЗначениеЗаполнено(vGuestGroupRef.Клиент.Language) Тогда
//							vLanguage = vGuestGroupRef.Клиент.Language;
//						EndIf;
						// Build message text
//						vRemarks = vHotel.GetObject().pmGetHotelPrintName(vLanguage) + 
//						           "Статус брони № " + Format(vGuestGroupRef.Code, "ND=12; NFD=0; NG=") + " изменен на " + vReservationObj.ReservationStatus.GetObject().pmGetReservationStatusDescription(vLanguage) + "'";
//						vDocumentText = "Автоматизированная система рассылки уведомлений об изменении статусов брони:" + Chars.LF + Chars.LF +
//						                ?(ЗначениеЗаполнено(vGuestGroupRef) And ЗначениеЗаполнено(vGuestGroupRef.Клиент), "Клиент:" + TrimAll(vGuestGroupRef.Клиент.FullName) + Chars.LF, "") + 
//						                ?(ЗначениеЗаполнено(vGuestGroupRef) And ЗначениеЗаполнено(vGuestGroupRef.CheckInDate) And ЗначениеЗаполнено(vGuestGroupRef.CheckOutDate), "Период проживания:" + Format(vGuestGroupRef.CheckInDate, "DF='dd.MM.yyyy HH:mm'") + " - "  + Format(vGuestGroupRef.CheckOutDate, "DF='dd.MM.yyyy HH:mm'") + Chars.LF, "") + 
//						                Chars.LF + 
//						                "Статус брони № " + Format(vGuestGroupRef.Code, "ND=12; NFD=0; NG=") + " изменен на " + vReservationObj.ReservationStatus.GetObject().pmGetReservationStatusDescription(vLanguage) + "'" + Chars.LF + Chars.LF + 
//						                "С уважением," + Chars.LF + 
//						                vHotel.GetObject().pmGetHotelPrintName(vLanguage) + Chars.LF + 
//								        ПараметрыСеанса.ИмяКонфигурации;
						// Call user exit procedure to give possibility to override message subject ans message text
						vUserExitProc = Справочники.ВнешниеОбработки.WriteGuestGroupPaymentWaitTimeIsExpiredNotification;
						If ЗначениеЗаполнено(vUserExitProc) Тогда
							If vUserExitProc.ExternalProcessingType = Перечисления.ExternalProcessingTypes.Algorithm Тогда
								If НЕ IsBlankString(vUserExitProc.Algorithm) Тогда
									Execute(TrimAll(vUserExitProc.Algorithm));
								EndIf;
							EndIf;
						EndIf;
						// Write attachment
						//cmWriteGuestGroupAttachment(vGuestGroupRef, ReplyMessageType, vRemarks, vDocumentText);
					EndIf;
				EndIf;
			Except
				vMessage = ErrorDescription();
				WriteLogEvent("Обработка.ПроверитьПоступлениеОплатыПоБрони", EventLogLevel.Warning, ThisObject.Metadata(), ?(vReservationObj = Неопределено, Неопределено, vReservationObj.Ref), vMessage);
				If pIsInteractive Тогда
					Message(vMessage, MessageStatus.Attention);
				EndIf;
			EndTry;
		EndDo;
	EndIf;
	// Send notifications
	If ЗначениеЗаполнено(DepartmentToSendNotificationsTo) Тогда
		vGuestGroups = New СписокЗначений();
		vProcessedGuestGroups.GroupBy("ГруппаГостей, CheckDate", );
		For Each vReservationsRow In vProcessedGuestGroups Do
			vGuestGroupRef = vReservationsRow.ГруппаГостей;
			If vGuestGroups.FindByValue(vGuestGroupRef) = Неопределено Тогда
				vGuestGroups.Add(vGuestGroupRef);
//				vMessageStatus = Неопределено;
//				If ЗначениеЗаполнено(vGuestGroupRef) And ЗначениеЗаполнено(vGuestGroupRef.Owner.MessageStatus) Тогда
//					vMessageStatus = vGuestGroupRef.Owner.MessageStatus;
//				EndIf;
				vMessage = "Просрочена оплата по брони группы № " + TrimAll(vGuestGroupRef) + ", " + TrimAll(vGuestGroupRef.Контрагент) + ", " + Format(vGuestGroupRef.CheckInDate, "DF=dd.MM.yyyy") + " - " + Format(vGuestGroupRef.CheckOutDate, "DF=dd.MM.yyyy");
				//cmSendMessageToDepartment(DepartmentToSendNotificationsTo, vMessage, vMessageStatus, False, vGuestGroupRef);
			EndIf;
		EndDo;
	EndIf;
	WriteLogEvent("Обработка.ПроверитьПоступлениеОплатыПоБрони", EventLogLevel.Information, ThisObject.Metadata(), Неопределено);
КонецПроцедуры //pmDoCheck
