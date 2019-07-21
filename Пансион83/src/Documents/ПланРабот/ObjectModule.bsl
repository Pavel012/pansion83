//-----------------------------------------------------------------------------
Function pmCheckDocumentAttributes(pMessage, pAttributeInErr) Экспорт
	vHasErrors = False;
	pMessage = "";
	pAttributeInErr = "";
	vMsgTextRu = "";
	vMsgTextEn = "";
	vMsgTextDe = "";
	If НЕ ЗначениеЗаполнено(Гостиница) Тогда
		vHasErrors = True; 
		vMsgTextRu = vMsgTextRu + "Реквизит <Гостиница> должен быть заполнен!" + Chars.LF;
		vMsgTextEn = vMsgTextEn + "<Гостиница> attribute should be filled!" + Chars.LF;
		vMsgTextDe = vMsgTextDe + "<Гостиница> attribute should be filled!" + Chars.LF;
		pAttributeInErr = ?(pAttributeInErr = "", "Гостиница", pAttributeInErr);
	EndIf;
	If vHasErrors Тогда
		pMessage = "ru='" + TrimAll(vMsgTextRu) + "';" + "en='" + TrimAll(vMsgTextEn) + "';" + "de='" + TrimAll(vMsgTextDe) + "';";
	EndIf;
	Return vHasErrors;
EndFunction //pmCheckDocumentAttributes

//-----------------------------------------------------------------------------
Процедура pmFillAuthorAndDate() Экспорт
	Date = CurrentDate();
	Автор = ПараметрыСеанса.ТекПользователь;
КонецПроцедуры //pmFillAuthorAndDate

//-----------------------------------------------------------------------------
Процедура pmFillAttributesWithDefaultValues() Экспорт
	// Fill author and document date
	pmFillAuthorAndDate();
	// Fill from session parameters
	If НЕ ЗначениеЗаполнено(Гостиница) Тогда
		Гостиница = ПараметрыСеанса.ТекущаяГостиница;
	EndIf;
	If ЗначениеЗаполнено(Гостиница) Тогда
		If НЕ ЗначениеЗаполнено(HousekeepingDepartment) Тогда
			HousekeepingDepartment = Гостиница.HousekeepingDepartment;
		EndIf;
		If НЕ ЗначениеЗаполнено(CheckOutCleaning) Тогда
			CheckOutCleaning = Гостиница.CheckOutCleaning;
		EndIf;
		If НЕ ЗначениеЗаполнено(RegularCleaning) Тогда
			RegularCleaning = Гостиница.RegularCleaning;
		EndIf;
		If НЕ ЗначениеЗаполнено(VacantRoomCleaning) Тогда
			VacantRoomCleaning = Гостиница.VacantRoomCleaning;
		EndIf;
		If НЕ ЗначениеЗаполнено(RepairEndCleaning) Тогда
			RepairEndCleaning = Гостиница.RepairEndCleaning;
		EndIf;
		If НЕ ЗначениеЗаполнено(RegularOperationGroup) Тогда
			RegularOperationGroup = Гостиница.RegularOperationGroup;
		EndIf;
		If НЕ ЗначениеЗаполнено(RoomStatusAfterCheckOut) Тогда
			RoomStatusAfterCheckOut = Гостиница.RoomStatusAfterCheckOut;
		EndIf;
		If НЕ ЗначениеЗаполнено(RoomStatusAfterEarlyCheckIn) Тогда
			RoomStatusAfterEarlyCheckIn = Гостиница.RoomStatusAfterEarlyCheckIn;
		EndIf;
		If НЕ ЗначениеЗаполнено(OccupiedDirtyRoomStatus) Тогда
			OccupiedDirtyRoomStatus = Гостиница.OccupiedDirtyRoomStatus;
		EndIf;
		If НЕ ЗначениеЗаполнено(RoomStatusInspection) Тогда
			RoomStatusInspection = Гостиница.RoomStatusInspection;
		EndIf;
	EndIf;
КонецПроцедуры //pmFillAttributesWithDefaultValues

//-----------------------------------------------------------------------------
Function pmGetOperations() Экспорт
	vQry = New Query();
	vQry.Text = 
	"SELECT DISTINCT
	|	CleaningTasks.Гостиница AS Гостиница,
	|	CleaningTasks.Гостиница.ПорядокСортировки AS HotelSortCode,
	|	CleaningTasks.НомерРазмещения AS НомерРазмещения,
	|	CleaningTasks.НомерРазмещения.ПорядокСортировки AS RoomSortCode,
	|	CleaningTasks.ТипНомера AS ТипНомера,
	|	CleaningTasks.ТипНомера.ПорядокСортировки AS RoomTypeSortCode,
	|	RoomStatusLastChangeRecord.СтатусНомера AS СтатусНомера,
	|	RoomStatusLastChangeRecord.Period AS RoomStatusChangeTime,
	|	CASE
	|		WHEN NOT &qHousekeepingDepartmentIsFilled
	|			THEN RoomStatusLastChangeRecord.User
	|		WHEN RoomStatusLastChangeRecord.User.Отдел = &qHousekeepingDepartment
	|			THEN RoomStatusLastChangeRecord.User
	|		ELSE NULL
	|	END AS RoomStatusChangeAuthor,
	|	CASE
	|		WHEN CleaningTasks.CheckOutCleaning IS NOT NULL 
	|			THEN CleaningTasks.CheckOutCleaning
	|		WHEN CleaningTasks.RegularOperation IS NOT NULL 
	|			THEN CleaningTasks.RegularOperation
	|		WHEN CleaningTasks.RegularCleaning IS NOT NULL 
	|			THEN CleaningTasks.RegularCleaning
	|		WHEN CleaningTasks.RepairEndCleaning IS NOT NULL 
	|			THEN CleaningTasks.RepairEndCleaning
	|		WHEN CleaningTasks.VacantRoomCleaning IS NOT NULL 
	|			THEN CleaningTasks.VacantRoomCleaning
	|		ELSE NULL
	|	END AS Operation,
	|	CASE
	|		WHEN CleaningTasks.CheckOutCleaning IS NOT NULL 
	|			THEN CleaningTasks.CheckOutCleaningSortCode
	|		WHEN CleaningTasks.RegularOperation IS NOT NULL 
	|			THEN CleaningTasks.RegularOperationSortCode
	|		WHEN CleaningTasks.RegularCleaning IS NOT NULL 
	|			THEN CleaningTasks.RegularCleaningSortCode
	|		WHEN CleaningTasks.RepairEndCleaning IS NOT NULL 
	|			THEN CleaningTasks.RepairEndCleaningSortCode
	|		WHEN CleaningTasks.VacantRoomCleaning IS NOT NULL 
	|			THEN CleaningTasks.VacantRoomCleaningSortCode
	|		ELSE 999999
	|	END AS OperationSortCode,
	|	CASE
	|		WHEN CleaningTasks.CheckOutAccommodation IS NOT NULL 
	|				AND CleaningTasks.CheckOutGuestIsInHouse
	|			THEN CleaningTasks.CheckOutGuest
	|		WHEN CleaningTasks.InHouseAccommodation IS NOT NULL 
	|			THEN CleaningTasks.InHouseGuest
	|		WHEN CleaningTasks.CheckedInAccommodation IS NOT NULL 
	|			THEN CleaningTasks.CheckedInGuest
	|		WHEN CleaningTasks.PlannedCheckInReservation IS NOT NULL 
	|			THEN CleaningTasks.PlannedCheckInGuest
	|		WHEN CleaningTasks.CheckOutAccommodation IS NOT NULL 
	|			THEN CleaningTasks.CheckOutGuest
	|		ELSE NULL
	|	END AS Клиент,
	|	CASE
	|		WHEN CleaningTasks.CheckOutAccommodation IS NOT NULL 
	|				AND CleaningTasks.CheckOutGuestIsInHouse
	|			THEN CleaningTasks.CheckOutGuest.Гражданство
	|		WHEN CleaningTasks.InHouseAccommodation IS NOT NULL 
	|			THEN CleaningTasks.InHouseGuest.Гражданство
	|		WHEN CleaningTasks.CheckedInAccommodation IS NOT NULL 
	|			THEN CleaningTasks.CheckedInGuest.Гражданство
	|		WHEN CleaningTasks.PlannedCheckInReservation IS NOT NULL 
	|			THEN CleaningTasks.PlannedCheckInGuest.Гражданство
	|		WHEN CleaningTasks.CheckOutAccommodation IS NOT NULL 
	|			THEN CleaningTasks.CheckOutGuest.Гражданство
	|		ELSE NULL
	|	END AS Гражданство,
	|	CASE
	|		WHEN CleaningTasks.CheckOutAccommodation IS NOT NULL 
	|				AND CleaningTasks.CheckOutGuestIsInHouse
	|			THEN CleaningTasks.CheckOutAccommodation.ТипКлиента
	|		WHEN CleaningTasks.InHouseAccommodation IS NOT NULL 
	|			THEN CleaningTasks.InHouseAccommodation.ТипКлиента
	|		WHEN CleaningTasks.CheckedInAccommodation IS NOT NULL 
	|			THEN CleaningTasks.CheckedInAccommodation.ТипКлиента
	|		WHEN CleaningTasks.PlannedCheckInReservation IS NOT NULL 
	|			THEN CleaningTasks.PlannedCheckInReservation.ТипКлиента
	|		WHEN CleaningTasks.CheckOutAccommodation IS NOT NULL 
	|			THEN CleaningTasks.CheckOutAccommodation.ТипКлиента
	|		ELSE NULL
	|	END AS ТипКлиента,
	|	CASE
	|		WHEN CleaningTasks.CheckOutAccommodation IS NOT NULL 
	|				AND CleaningTasks.CheckOutGuestIsInHouse
	|			THEN CleaningTasks.CheckOutCheckInDate
	|		WHEN CleaningTasks.InHouseAccommodation IS NOT NULL 
	|			THEN CleaningTasks.InHouseCheckInDate
	|		WHEN CleaningTasks.БлокНомер IS NOT NULL 
	|			THEN CleaningTasks.RoomBlockStartDate
	|		WHEN CleaningTasks.CheckedInAccommodation IS NOT NULL 
	|			THEN CleaningTasks.CheckedInCheckInDate
	|		WHEN CleaningTasks.PlannedCheckInReservation IS NOT NULL 
	|			THEN CleaningTasks.PlannedCheckInCheckInDate
	|		WHEN CleaningTasks.CheckOutAccommodation IS NOT NULL 
	|			THEN CleaningTasks.CheckOutCheckInDate
	|		ELSE NULL
	|	END AS CheckInDate,
	|	CASE
	|		WHEN CleaningTasks.CheckOutAccommodation IS NOT NULL 
	|				AND CleaningTasks.CheckOutGuestIsInHouse
	|			THEN CleaningTasks.CheckOutCheckOutDate
	|		WHEN CleaningTasks.InHouseAccommodation IS NOT NULL 
	|			THEN CleaningTasks.InHouseCheckOutDate
	|		WHEN CleaningTasks.БлокНомер IS NOT NULL 
	|			THEN CleaningTasks.RoomBlockEndDate
	|		WHEN CleaningTasks.CheckedInAccommodation IS NOT NULL 
	|			THEN CleaningTasks.CheckedInCheckOutDate
	|		WHEN CleaningTasks.PlannedCheckInReservation IS NOT NULL 
	|			THEN CleaningTasks.PlannedCheckInCheckOutDate
	|		WHEN CleaningTasks.CheckOutAccommodation IS NOT NULL 
	|			THEN CleaningTasks.CheckOutCheckOutDate
	|		ELSE NULL
	|	END AS ДатаВыезда,
	|	CASE
	|		WHEN CleaningTasks.CheckOutAccommodation IS NOT NULL 
	|				AND CleaningTasks.CheckOutGuestIsInHouse
	|			THEN CleaningTasks.CheckOutAccommodation
	|		WHEN CleaningTasks.InHouseAccommodation IS NOT NULL 
	|			THEN CleaningTasks.InHouseAccommodation
	|		WHEN CleaningTasks.БлокНомер IS NOT NULL 
	|			THEN CleaningTasks.БлокНомер
	|		WHEN CleaningTasks.CheckedInAccommodation IS NOT NULL 
	|			THEN CleaningTasks.CheckedInAccommodation
	|		WHEN CleaningTasks.PlannedCheckInReservation IS NOT NULL 
	|			THEN CleaningTasks.PlannedCheckInReservation
	|		WHEN CleaningTasks.CheckOutAccommodation IS NOT NULL 
	|			THEN CleaningTasks.CheckOutAccommodation
	|		ELSE NULL
	|	END AS ДокОснование,
	|	CleaningTasks.CheckOutCleaning,
	|	CleaningTasks.RegularCleaning,
	|	CleaningTasks.RepairEndCleaning,
	|	CleaningTasks.VacantRoomCleaning,
	|	CleaningTasks.RegularOperation,
	|	CleaningTasks.IsCheckInWaiting,
	|	CleaningTasks.InHouseAccommodation,
	|	CleaningTasks.InHouseGuest,
	|	CleaningTasks.InHouseCheckInDate,
	|	CleaningTasks.InHouseCheckOutDate,
	|	CleaningTasks.InHouseCustomer AS Контрагент,
	|	CASE
	|		WHEN CleaningTasks.CheckOutAccommodation IS NOT NULL 
	|				AND CleaningTasks.CheckOutGuestIsInHouse
	|			THEN CleaningTasks.CheckOutNumberOfPersons
	|		WHEN CleaningTasks.InHouseAccommodation IS NOT NULL 
	|			THEN CleaningTasks.InHouseNumberOfPersons
	|		WHEN CleaningTasks.CheckedInAccommodation IS NOT NULL 
	|			THEN CleaningTasks.CheckedInNumberOfPersons
	|		WHEN CleaningTasks.CheckOutAccommodation IS NOT NULL 
	|			THEN CleaningTasks.CheckOutNumberOfPersons
	|		ELSE 0
	|	END AS NumberOfGuests,
	|	CAST(CleaningTasks.InHouseAccommodation.HousekeepingRemarks AS STRING(1024)) AS InHouseAccommodationHousekeepingRemarks,
	|	CleaningTasks.CheckOutAccommodation,
	|	CleaningTasks.CheckOutGuest,
	|	CleaningTasks.CheckOutCheckInDate,
	|	CleaningTasks.CheckOutCheckOutDate,
	|	CleaningTasks.БлокНомер,
	|	CleaningTasks.RoomBlockType,
	|	CleaningTasks.RoomBlockRemarks,
	|	CleaningTasks.RoomBlockStartDate,
	|	CleaningTasks.RoomBlockEndDate,
	|	CleaningTasks.CurrentRoomBlockType
	|FROM
	|	(SELECT
	|		RoomInventoryBalance.Гостиница AS Гостиница,
	|		RoomInventoryBalance.НомерРазмещения AS НомерРазмещения,
	|		RoomInventoryBalance.НомерРазмещения.СтатусНомера AS СтатусНомера,
	|		RoomInventoryBalance.ТипНомера AS ТипНомера,
	|		RoomInventoryBalance.TotalRoomsBalance AS TotalRoomsBalance,
	|		RoomInventoryBalance.TotalBedsBalance AS TotalBedsBalance,
	|		CheckedInPersons.Recorder AS CheckedInAccommodation,
	|		CheckedInPersons.Клиент AS CheckedInGuest,
	|		CheckedInPersons.ГруппаГостей AS CheckedInGuestGroup,
	|		CASE
	|			WHEN &qShowGuestGroupDescriptionInCustomerColumns
	|				THEN CheckedInPersons.ГруппаГостей.Description
	|			ELSE CheckedInPersons.Контрагент
	|		END AS CheckedInCustomer,
	|		CheckedInPersons.КоличествоЧеловек AS CheckedInNumberOfPersons,
	|		CheckedInPersons.CheckInDate AS CheckedInCheckInDate,
	|		CheckedInPersons.ДатаВыезда AS CheckedInCheckOutDate,
	|		InHousePersons.Recorder AS InHouseAccommodation,
	|		InHousePersons.Клиент AS InHouseGuest,
	|		InHousePersons.ГруппаГостей AS InHouseGuestGroup,
	|		CASE
	|			WHEN &qShowGuestGroupDescriptionInCustomerColumns
	|				THEN InHousePersons.ГруппаГостей.Description
	|			ELSE InHousePersons.Контрагент
	|		END AS InHouseCustomer,
	|		InHousePersons.КоличествоЧеловек AS InHouseNumberOfPersons,
	|		InHousePersons.CheckInDate AS InHouseCheckInDate,
	|		InHousePersons.ДатаВыезда AS InHouseCheckOutDate,
	|		CASE
	|			WHEN NOT InHousePersons.Recorder IS NULL 
	|					AND CheckedOutGuests.Recorder IS NULL 
	|					AND (RoomInventoryBalance.НомерРазмещения.СтатусНомера <> &qRoomStatusAfterCheckOut
	|						OR NOT &qRoomStatusAfterCheckOutIsFilled)
	|				THEN &qRegularCleaning
	|			WHEN RoomInventoryBalance.НомерРазмещения.СтатусНомера = &qRoomStatusAfterEarlyCheckIn
	|					AND &qRoomStatusAfterEarlyCheckinIsFilled
	|				THEN &qRegularCleaning
	|			WHEN RoomInventoryBalance.НомерРазмещения.СтатусНомера = &qOccupiedDirtyRoomStatus
	|					AND &qOccupiedDirtyRoomStatusIsFilled
	|				THEN &qRegularCleaning
	|			ELSE NULL
	|		END AS RegularCleaning,
	|		CASE
	|			WHEN NOT InHousePersons.Recorder IS NULL 
	|					AND CheckedOutGuests.Recorder IS NULL 
	|					AND (RoomInventoryBalance.НомерРазмещения.СтатусНомера <> &qRoomStatusAfterCheckOut
	|						OR NOT &qRoomStatusAfterCheckOutIsFilled)
	|				THEN &qRegularCleaningSortCode
	|			WHEN RoomInventoryBalance.НомерРазмещения.СтатусНомера = &qRoomStatusAfterEarlyCheckIn
	|					AND &qRoomStatusAfterEarlyCheckinIsFilled
	|				THEN &qRegularCleaningSortCode
	|			WHEN RoomInventoryBalance.НомерРазмещения.СтатусНомера = &qOccupiedDirtyRoomStatus
	|					AND &qOccupiedDirtyRoomStatusIsFilled
	|				THEN &qRegularCleaningSortCode
	|			ELSE 999999
	|		END AS RegularCleaningSortCode,
	|		CheckedOutGuests.Recorder AS CheckOutAccommodation,
	|		CheckedOutGuests.Клиент AS CheckOutGuest,
	|		CheckedOutGuests.ГруппаГостей AS CheckOutGuestGroup,
	|		CASE
	|			WHEN &qShowGuestGroupDescriptionInCustomerColumns
	|				THEN CheckedOutGuests.ГруппаГостей.Description
	|			ELSE CheckedOutGuests.Контрагент
	|		END AS CheckOutCustomer,
	|		CheckedOutGuests.КоличествоЧеловек AS CheckOutNumberOfPersons,
	|		CheckedOutGuests.CheckInDate AS CheckOutCheckInDate,
	|		CheckedOutGuests.ДатаВыезда AS CheckOutCheckOutDate,
	|		CASE
	|			WHEN NOT CheckedOutGuests.Recorder IS NULL 
	|				THEN &qCheckOutCleaning
	|			WHEN RoomInventoryBalance.НомерРазмещения.СтатусНомера = &qRoomStatusAfterCheckOut
	|					AND &qRoomStatusAfterCheckOutIsFilled
	|				THEN &qCheckOutCleaning
	|			ELSE NULL
	|		END AS CheckOutCleaning,
	|		CASE
	|			WHEN NOT CheckedOutGuests.Recorder IS NULL 
	|				THEN &qCheckOutCleaningSortCode
	|			WHEN RoomInventoryBalance.НомерРазмещения.СтатусНомера = &qRoomStatusAfterCheckOut
	|					AND &qRoomStatusAfterCheckOutIsFilled
	|				THEN &qCheckOutCleaningSortCode
	|			ELSE 999999
	|		END AS CheckOutCleaningSortCode,
	|		ISNULL(CheckedOutGuests.Recorder.СтатусРазмещения.ЭтоГости, FALSE) AS CheckOutGuestIsInHouse,
	|		FinishedRoomBlocks.Recorder AS БлокНомер,
	|		FinishedRoomBlocks.RoomBlockType AS RoomBlockType,
	|		SUBSTRING(FinishedRoomBlocks.Примечания, 1, 999) AS RoomBlockRemarks,
	|		FinishedRoomBlocks.CheckInDate AS RoomBlockStartDate,
	|		FinishedRoomBlocks.ДатаВыезда AS RoomBlockEndDate,
	|		CASE
	|			WHEN NOT FinishedRoomBlocks.Recorder IS NULL 
	|				THEN &qRepairEndCleaning
	|			ELSE NULL
	|		END AS RepairEndCleaning,
	|		CASE
	|			WHEN NOT FinishedRoomBlocks.Recorder IS NULL 
	|				THEN &qRepairEndCleaningSortCode
	|			ELSE 999999
	|		END AS RepairEndCleaningSortCode,
	|		CASE
	|			WHEN CheckedOutGuests.Recorder IS NULL 
	|					AND YesterdayCheckedOutGuests.НомерРазмещения IS NULL 
	|					AND InHousePersons.Recorder IS NULL 
	|					AND CheckedInPersons.Recorder IS NULL 
	|					AND CheckedOutGuests.Recorder IS NULL 
	|					AND RoomRepairs.Recorder IS NULL 
	|					AND (RoomInventoryBalance.НомерРазмещения.СтатусНомера <> &qRoomStatusAfterCheckOut
	|						OR NOT &qRoomStatusAfterCheckOutIsFilled)
	|				THEN &qVacantRoomCleaning
	|			ELSE NULL
	|		END AS VacantRoomCleaning,
	|		CASE
	|			WHEN CheckedOutGuests.Recorder IS NULL 
	|					AND YesterdayCheckedOutGuests.НомерРазмещения IS NULL 
	|					AND InHousePersons.Recorder IS NULL 
	|					AND CheckedInPersons.Recorder IS NULL 
	|					AND CheckedOutGuests.Recorder IS NULL 
	|					AND RoomRepairs.Recorder IS NULL 
	|					AND (RoomInventoryBalance.НомерРазмещения.СтатусНомера <> &qRoomStatusAfterCheckOut
	|						OR NOT &qRoomStatusAfterCheckOutIsFilled)
	|				THEN &qVacantRoomCleaningSortCode
	|			ELSE 999999
	|		END AS VacantRoomCleaningSortCode,
	|		CASE
	|			WHEN PlannedCheckedIn.Recorder IS NULL 
	|				THEN FALSE
	|			ELSE TRUE
	|		END AS IsCheckInWaiting,
	|		PlannedCheckedIn.Recorder AS PlannedCheckInReservation,
	|		PlannedCheckedIn.Клиент AS PlannedCheckInGuest,
	|		PlannedCheckedIn.CheckInDate AS PlannedCheckInCheckInDate,
	|		PlannedCheckedIn.ДатаВыезда AS PlannedCheckInCheckOutDate,
	|		RegularOperations.RegularOperation AS RegularOperation,
	|		CASE
	|			WHEN RegularOperations.RegularOperation IS NOT NULL 
	|				THEN RegularOperations.RegularOperation.ПорядокСортировки
	|			ELSE 999999
	|		END AS RegularOperationSortCode,
	|		БлокирНомеров.RoomBlockType AS CurrentRoomBlockType
	|	FROM
	|		AccumulationRegister.ЗагрузкаНомеров.Balance(
	|				&qPeriodTo,
	|				(Гостиница IN HIERARCHY (&qHotel)
	|					OR &qIsEmptyHotel)
	|					AND (НомерРазмещения IN HIERARCHY (&qRoom)
	|						OR &qIsEmptyRoom)
	|					AND (НомерРазмещения.Секция IN HIERARCHY (&qRoomSection)
	|						OR &qIsEmptyRoomSection)) AS RoomInventoryBalance
	|			LEFT JOIN AccumulationRegister.ЗагрузкаНомеров AS InHousePersons
	|			ON RoomInventoryBalance.НомерРазмещения = InHousePersons.НомерРазмещения
	|				AND (InHousePersons.RecordType = &qExpense)
	|				AND (InHousePersons.ЭтоГости)
	|				AND (InHousePersons.ПериодС < &qPeriodFrom)
	|				AND (InHousePersons.ПериодПо > &qPeriodTo)
	|			LEFT JOIN AccumulationRegister.ЗагрузкаНомеров AS CheckedOutGuests
	|			ON RoomInventoryBalance.НомерРазмещения = CheckedOutGuests.НомерРазмещения
	|				AND (CheckedOutGuests.RecordType = &qReceipt)
	|				AND (CheckedOutGuests.ЭтоВыезд)
	|				AND (CheckedOutGuests.ПериодПо = CheckedOutGuests.ДатаВыезда)
	|				AND (CheckedOutGuests.ПериодПо > &qPeriodFrom)
	|				AND (CheckedOutGuests.ПериодПо <= &qPeriodTo)
	|			LEFT JOIN (SELECT
	|				RoomInventoryYesterdayCheckedOutGuests.НомерРазмещения AS НомерРазмещения
	|			FROM
	|				AccumulationRegister.ЗагрузкаНомеров AS RoomInventoryYesterdayCheckedOutGuests
	|			WHERE
	|				RoomInventoryYesterdayCheckedOutGuests.RecordType = &qReceipt
	|				AND RoomInventoryYesterdayCheckedOutGuests.ЭтоВыезд
	|				AND RoomInventoryYesterdayCheckedOutGuests.ПериодПо = RoomInventoryYesterdayCheckedOutGuests.ДатаВыезда
	|				AND RoomInventoryYesterdayCheckedOutGuests.ПериодПо > &qYesterdayPeriodFrom
	|				AND RoomInventoryYesterdayCheckedOutGuests.ПериодПо <= &qYesterdayPeriodTo
	|			
	|			GROUP BY
	|				RoomInventoryYesterdayCheckedOutGuests.НомерРазмещения) AS YesterdayCheckedOutGuests
	|			ON RoomInventoryBalance.НомерРазмещения = YesterdayCheckedOutGuests.НомерРазмещения
	|			LEFT JOIN (SELECT
	|				RoomInventoryLastCheckedOutGuests.НомерРазмещения AS НомерРазмещения,
	|				MAX(RoomInventoryLastCheckedOutGuests.ПериодПо) AS LastCheckOutDate
	|			FROM
	|				AccumulationRegister.ЗагрузкаНомеров AS RoomInventoryLastCheckedOutGuests
	|			WHERE
	|				RoomInventoryLastCheckedOutGuests.RecordType = &qReceipt
	|				AND RoomInventoryLastCheckedOutGuests.ЭтоВыезд
	|				AND RoomInventoryLastCheckedOutGuests.ДатаВыезда <= &qPeriodFrom
	|			
	|			GROUP BY
	|				RoomInventoryLastCheckedOutGuests.НомерРазмещения) AS LastCheckedOutGuests
	|			ON RoomInventoryBalance.НомерРазмещения = LastCheckedOutGuests.НомерРазмещения
	|			LEFT JOIN AccumulationRegister.ЗагрузкаНомеров AS БлокирНомеров
	|			ON RoomInventoryBalance.НомерРазмещения = БлокирНомеров.НомерРазмещения
	|				AND (БлокирНомеров.RecordType = &qExpense)
	|				AND (БлокирНомеров.IsBlocking)
	|				AND (БлокирНомеров.Recorder.ДатаКонКвоты > &qPeriodFrom
	|					OR БлокирНомеров.Recorder.ДатаКонКвоты = &qEmptyDate)
	|				AND (БлокирНомеров.Recorder.ДатаНачКвоты < &qPeriodTo)
	|				AND (БлокирНомеров.Recorder.ДатаНачКвоты = БлокирНомеров.CheckInDate)
	|			LEFT JOIN AccumulationRegister.ЗагрузкаНомеров AS RoomRepairs
	|			ON RoomInventoryBalance.НомерРазмещения = RoomRepairs.НомерРазмещения
	|				AND (RoomRepairs.RecordType = &qExpense)
	|				AND (RoomRepairs.IsBlocking)
	|				AND (RoomRepairs.RoomBlockType.IsRoomRepair)
	|				AND (RoomRepairs.Recorder.ДатаКонКвоты > &qPeriodFrom
	|					OR RoomRepairs.Recorder.ДатаКонКвоты = &qEmptyDate)
	|				AND (RoomRepairs.Recorder.ДатаНачКвоты < &qPeriodTo)
	|				AND (RoomRepairs.Recorder.ДатаНачКвоты = RoomRepairs.CheckInDate)
	|			LEFT JOIN AccumulationRegister.ЗагрузкаНомеров AS FinishedRoomBlocks
	|			ON RoomInventoryBalance.НомерРазмещения = FinishedRoomBlocks.НомерРазмещения
	|				AND (FinishedRoomBlocks.RecordType = &qExpense)
	|				AND (FinishedRoomBlocks.IsBlocking)
	|				AND (FinishedRoomBlocks.Recorder.ДатаКонКвоты > &qPeriodFrom)
	|				AND (FinishedRoomBlocks.Recorder.ДатаКонКвоты <= &qPeriodTo)
	|				AND (FinishedRoomBlocks.RoomBlockType.IsRoomRepair)
	|				AND (FinishedRoomBlocks.Recorder.ДатаНачКвоты = FinishedRoomBlocks.CheckInDate)
	|			LEFT JOIN AccumulationRegister.ЗагрузкаНомеров AS CheckedInPersons
	|			ON RoomInventoryBalance.НомерРазмещения = CheckedInPersons.НомерРазмещения
	|				AND (CheckedInPersons.RecordType = &qExpense)
	|				AND (CheckedInPersons.ЭтоГости)
	|				AND (CheckedInPersons.ПериодС = CheckedInPersons.CheckInDate)
	|				AND (CheckedInPersons.ПериодС >= &qPeriodFrom)
	|				AND (CheckedInPersons.ПериодС < &qPeriodTo)
	|			LEFT JOIN AccumulationRegister.ЗагрузкаНомеров AS PlannedCheckedIn
	|			ON RoomInventoryBalance.НомерРазмещения = PlannedCheckedIn.НомерРазмещения
	|				AND (PlannedCheckedIn.RecordType = &qExpense)
	|				AND (PlannedCheckedIn.IsReservation)
	|				AND (PlannedCheckedIn.ПериодС = PlannedCheckedIn.CheckInDate)
	|				AND (PlannedCheckedIn.ПериодС >= &qPeriodFrom)
	|				AND (PlannedCheckedIn.ПериодС < &qPeriodTo)
	|			LEFT JOIN Catalog.НаборРегламентныхРабот.RegularOperations AS RegularOperations
	|			ON (RegularOperations.Ref = &qRegularOperationGroup)
	|				AND (RegularOperations.PerformWhenRoomIsBusy
	|						AND DATEDIFF(&qPeriodFrom, BEGINOFPERIOD(InHousePersons.ПериодС, DAY), DAY) / RegularOperations.RegularOperationFrequency = (CAST(DATEDIFF(&qPeriodFrom, BEGINOFPERIOD(InHousePersons.ПериодС, DAY), DAY) / RegularOperations.RegularOperationFrequency AS NUMBER(17, 0)))
	|						AND DATEDIFF(&qPeriodFrom, BEGINOFPERIOD(InHousePersons.ПериодС, DAY), DAY) <> 0
	|					OR RegularOperations.PerformWhenRoomIsBusy
	|						AND RegularOperations.PerformOnCheckInDay
	|						AND CheckedInPersons.Recorder IS NOT NULL 
	|					OR RegularOperations.PerformWhenRoomIsBusy
	|						AND RegularOperations.PerformOnCheckOutDay
	|						AND CheckedOutGuests.Recorder IS NOT NULL 
	|					OR RegularOperations.PerformWhenRoomIsFree
	|						AND InHousePersons.Recorder IS NULL 
	|						AND CheckedInPersons.Recorder IS NULL 
	|						AND CheckedOutGuests.Recorder IS NULL 
	|						AND (RegularOperations.RegularOperationFrequency = 0
	|							OR RegularOperations.RegularOperationFrequency = 1
	|							OR RegularOperations.RegularOperationFrequency > 1
	|								AND DATEDIFF(&qPeriodFrom, BEGINOFPERIOD(LastCheckedOutGuests.LastCheckOutDate, DAY), DAY) / RegularOperations.RegularOperationFrequency = (CAST(DATEDIFF(&qPeriodFrom, BEGINOFPERIOD(LastCheckedOutGuests.LastCheckOutDate, DAY), DAY) / RegularOperations.RegularOperationFrequency AS NUMBER(17, 0)))
	|								AND DATEDIFF(&qPeriodFrom, BEGINOFPERIOD(LastCheckedOutGuests.LastCheckOutDate, DAY), DAY) <> 0))
	|				AND (NOT RegularOperations.DoNotPerformOnWeekends
	|					OR RegularOperations.DoNotPerformOnWeekends
	|						AND WEEKDAY(&qPeriodFrom) < 6)
	|				AND (RegularOperations.ТипНомера = &qEmptyRoomType
	|					OR RegularOperations.ТипНомера <> &qEmptyRoomType
	|						AND RoomInventoryBalance.ТипНомера = RegularOperations.ТипНомера
	|					OR RegularOperations.ТипНомера <> &qEmptyRoomType
	|						AND RoomInventoryBalance.ТипНомера.Parent <> &qEmptyRoomType
	|						AND RoomInventoryBalance.ТипНомера.Parent = RegularOperations.ТипНомера)
	|				AND (RegularOperations.Тариф = &qEmptyRoomRate
	|					OR RegularOperations.Тариф <> &qEmptyRoomRate
	|						AND NOT InHousePersons.Recorder.Тариф IS NULL 
	|						AND InHousePersons.Recorder.Тариф <> &qEmptyRoomRate
	|						AND (InHousePersons.Recorder.Тариф = RegularOperations.Тариф
	|							OR InHousePersons.Recorder.Тариф.Parent = RegularOperations.Тариф
	|							OR InHousePersons.Recorder.Тариф.Parent.Parent = RegularOperations.Тариф))
	|	WHERE
	|		RoomInventoryBalance.TotalRoomsBalance > 0
	|	
	|	UNION ALL
	|	
	|	SELECT
	|		VirtualRooms.Owner,
	|		VirtualRooms.Ref,
	|		VirtualRooms.СтатусНомера,
	|		VirtualRooms.ТипНомера,
	|		0,
	|		0,
	|		NULL,
	|		NULL,
	|		NULL,
	|		NULL,
	|		0,
	|		NULL,
	|		NULL,
	|		NULL,
	|		NULL,
	|		NULL,
	|		NULL,
	|		0,
	|		NULL,
	|		NULL,
	|		CASE
	|			WHEN VirtualRooms.СтатусНомера = &qRoomStatusAfterEarlyCheckIn
	|					AND &qRoomStatusAfterEarlyCheckinIsFilled
	|				THEN &qRegularCleaning
	|			WHEN VirtualRooms.СтатусНомера = &qOccupiedDirtyRoomStatus
	|					AND &qOccupiedDirtyRoomStatusIsFilled
	|				THEN &qRegularCleaning
	|			ELSE NULL
	|		END,
	|		CASE
	|			WHEN VirtualRooms.СтатусНомера = &qRoomStatusAfterEarlyCheckIn
	|					AND &qRoomStatusAfterEarlyCheckinIsFilled
	|				THEN &qRegularCleaningSortCode
	|			WHEN VirtualRooms.СтатусНомера = &qOccupiedDirtyRoomStatus
	|					AND &qOccupiedDirtyRoomStatusIsFilled
	|				THEN &qRegularCleaningSortCode
	|			ELSE 999999
	|		END,
	|		NULL,
	|		NULL,
	|		NULL,
	|		NULL,
	|		0,
	|		NULL,
	|		NULL,
	|		CASE
	|			WHEN VirtualRooms.СтатусНомера = &qRoomStatusAfterCheckOut
	|					AND &qRoomStatusAfterCheckOutIsFilled
	|				THEN &qCheckOutCleaning
	|			ELSE NULL
	|		END,
	|		CASE
	|			WHEN VirtualRooms.СтатусНомера = &qRoomStatusAfterCheckOut
	|					AND &qRoomStatusAfterCheckOutIsFilled
	|				THEN &qCheckOutCleaningSortCode
	|			ELSE 999999
	|		END,
	|		FALSE,
	|		NULL,
	|		NULL,
	|		NULL,
	|		NULL,
	|		NULL,
	|		NULL,
	|		NULL,
	|		NULL,
	|		999999,
	|		FALSE,
	|		NULL,
	|		NULL,
	|		NULL,
	|		NULL,
	|		NULL,
	|		999999,
	|		NULL
	|	FROM
	|		Catalog.НомернойФонд AS VirtualRooms
	|	WHERE
	|		VirtualRooms.ВиртуальныйНомер
	|		AND NOT VirtualRooms.IsFolder
	|		AND NOT VirtualRooms.DeletionMark
	|		AND VirtualRooms.ДатаВводаЭкспл <= &qPeriodTo
	|		AND (VirtualRooms.ДатаВыводаЭкспл = &qEmptyDate
	|				OR VirtualRooms.ДатаВыводаЭкспл > &qPeriodTo)
	|		AND (VirtualRooms.Owner IN HIERARCHY (&qHotel)
	|				OR &qIsEmptyHotel)
	|		AND (VirtualRooms.Ref IN HIERARCHY (&qRoom)
	|				OR &qIsEmptyRoom)
	|		AND (VirtualRooms.Секция IN HIERARCHY (&qRoomSection)
	|				OR &qIsEmptyRoomSection)) AS CleaningTasks
	|		LEFT JOIN (SELECT
	|			ИсторияИзмСтатусаНомеров.Period AS Period,
	|			ИсторияИзмСтатусаНомеров.User AS User,
	|			ИсторияИзмСтатусаНомеров.НомерРазмещения AS НомерРазмещения,
	|			ИсторияИзмСтатусаНомеров.СтатусНомера AS СтатусНомера
	|		FROM
	|			InformationRegister.ИсторияИзмСтатусаНомеров AS ИсторияИзмСтатусаНомеров
	|				INNER JOIN InformationRegister.ИсторияИзмСтатусаНомеров.SliceLast(
	|						&qPeriod,
	|						(НомерРазмещения.Owner IN HIERARCHY (&qHotel)
	|							OR &qIsEmptyHotel)
	|							AND (НомерРазмещения IN HIERARCHY (&qRoom)
	|								OR &qIsEmptyRoom)
	|							AND (НомерРазмещения.Секция IN HIERARCHY (&qRoomSection)
	|								OR &qIsEmptyRoomSection)) AS RoomStatusChangeHistorySliceLast
	|				ON ИсторияИзмСтатусаНомеров.Period = RoomStatusChangeHistorySliceLast.Period
	|					AND ИсторияИзмСтатусаНомеров.НомерРазмещения = RoomStatusChangeHistorySliceLast.НомерРазмещения) AS RoomStatusLastChangeRecord
	|		ON CleaningTasks.НомерРазмещения = RoomStatusLastChangeRecord.НомерРазмещения
	|
	|ORDER BY
	|	HotelSortCode,
	|	RoomSortCode,
	|	OperationSortCode,
	|	Клиент";
	// Fill query parameters
	vQry.SetParameter("qPeriod", EndOfDay(Date));
	vQry.SetParameter("qPeriodFrom", BegOfDay(Date));
	vQry.SetParameter("qPeriodTo", EndOfDay(Date));
	vQry.SetParameter("qYesterdayPeriodFrom", BegOfDay(Date)-24*3600);
	vQry.SetParameter("qYesterdayPeriodTo", EndOfDay(Date)-24*3600);
	vQry.SetParameter("qEmptyDate", '00010101');
	vQry.SetParameter("qHotel", Гостиница);
	vQry.SetParameter("qIsEmptyHotel", НЕ ЗначениеЗаполнено(Гостиница));
	vQry.SetParameter("qRoom", Room);
	vQry.SetParameter("qIsEmptyRoom", НЕ ЗначениеЗаполнено(Room));
    vQry.SetParameter("qRoomSection", RoomSection);
    vQry.SetParameter("qIsEmptyRoomSection", НЕ ЗначениеЗаполнено(RoomSection));
	vQry.SetParameter("qExpense", AccumulationRecordType.Expense);
	vQry.SetParameter("qReceipt", AccumulationRecordType.Receipt);
	vQry.SetParameter("qRegularCleaning", RegularCleaning);
	vQry.SetParameter("qRegularCleaningSortCode", ?(ЗначениеЗаполнено(RegularCleaning), RegularCleaning.SortCode, 0));
	vQry.SetParameter("qCheckOutCleaning", CheckOutCleaning);
	vQry.SetParameter("qCheckOutCleaningSortCode", ?(ЗначениеЗаполнено(CheckOutCleaning), CheckOutCleaning.SortCode, 0));
	vQry.SetParameter("qVacantRoomCleaning", VacantRoomCleaning);
	vQry.SetParameter("qVacantRoomCleaningSortCode", ?(ЗначениеЗаполнено(VacantRoomCleaning), VacantRoomCleaning.SortCode, 0));
	vQry.SetParameter("qRepairEndCleaning", RepairEndCleaning);
	vQry.SetParameter("qRepairEndCleaningSortCode", ?(ЗначениеЗаполнено(RepairEndCleaning), RepairEndCleaning.SortCode, 0));
	vQry.SetParameter("qRoomStatusAfterCheckOut", RoomStatusAfterCheckOut);
	vQry.SetParameter("qRoomStatusAfterCheckOutIsFilled", ЗначениеЗаполнено(RoomStatusAfterCheckOut));
    vQry.SetParameter("qRegularOperationGroup", RegularOperationGroup);
	//vQry.SetParameter("qShowGuestGroupDescriptionInCustomerColumns", cmCheckUserPermissions("ShowGuestGroupDescriptionInCustomerColumns"));
	vQry.SetParameter("qHousekeepingDepartment", HousekeepingDepartment);
	vQry.SetParameter("qHousekeepingDepartmentIsFilled", ЗначениеЗаполнено(HousekeepingDepartment)); 
	vQry.SetParameter("qRoomStatusAfterEarlyCheckin", RoomStatusAfterEarlyCheckIn);
	vQry.SetParameter("qRoomStatusAfterEarlyCheckinIsFilled", ЗначениеЗаполнено(RoomStatusAfterEarlyCheckIn));
	vQry.SetParameter("qOccupiedDirtyRoomStatus", OccupiedDirtyRoomStatus);
	vQry.SetParameter("qOccupiedDirtyRoomStatusIsFilled", ЗначениеЗаполнено(OccupiedDirtyRoomStatus));
	vQry.SetParameter("qEmptyRoomType", Справочники.ТипыНомеров.EmptyRef());
	vQry.SetParameter("qEmptyRoomRate", Справочники.Тарифы.EmptyRef());
	vOperations = vQry.Execute().Unload();
	// Remove doubled rows per guests
	i = 0;
	While i < (vOperations.Count() - 1) Do
		vRow = vOperations.Get(i);
		vNextRow = vOperations.Get(i + 1);
		If ЗначениеЗаполнено(vRow.НомерРазмещения) And ЗначениеЗаполнено(vRow.Operation) And ЗначениеЗаполнено(vRow.ДокОснование) And 
		   vRow.НомерРазмещения = vNextRow.НомерРазмещения And vRow.Operation = vNextRow.Operation And vRow.ДокОснование = vNextRow.ДокОснование Тогда
			vOperations.Delete(i + 1);
		Else
			i = i + 1;
		EndIf;
	EndDo;
	// Clear per ГруппаНомеров operations added per every guest
	For Each vRow In vOperations Do
		If ЗначениеЗаполнено(vRow.Room) And ЗначениеЗаполнено(vRow.Operation) Тогда
			If НЕ vRow.Operation.IsPerGuest Тогда
				vOprRows = vOperations.FindRows(New Structure("НомерРазмещения, Operation", vRow.ГруппаНомеров, vRow.Operation));
				If vOprRows.Count() > 1 Тогда
					For i = 1 To (vOprRows.Count()-1) Do
						vOprRow = vOprRows.Get(i);
						vOprRow.Operation = Справочники.Работы.EmptyRef();
						vOprRow.OperationSortCode = 999999;
						If vOprRow.CheckOutCleaning = vRow.Operation Тогда
							vOprRow.CheckOutCleaning = Справочники.Работы.EmptyRef();
						EndIf;
						If vOprRow.RegularCleaning = vRow.Operation Тогда
							vOprRow.RegularCleaning = Справочники.Работы.EmptyRef();
						EndIf;
						If vOprRow.VacantRoomCleaning = vRow.Operation Тогда
							vOprRow.VacantRoomCleaning = Справочники.Работы.EmptyRef();
						EndIf;
						If vOprRow.RepairEndCleaning = vRow.Operation Тогда
							vOprRow.RepairEndCleaning = Справочники.Работы.EmptyRef();
						EndIf;
						If vOprRow.RegularOperation = vRow.Operation Тогда
							vOprRow.RegularOperation = Справочники.Работы.EmptyRef();
						EndIf;
					EndDo;
				EndIf;
			EndIf;
		EndIf;
	EndDo;
	// Sort operations
	vOperations.Sort("HotelSortCode, RoomSortCode, OperationSortCode, Клиент");
	// Return
	Return vOperations;
EndFunction //pmGetOperations

//-----------------------------------------------------------------------------
Function AddComma(pStr)
	If IsBlankString(pStr) Тогда
		Return "";
	Else
		Return ", ";
	EndIf;
EndFunction //AddComma

//-----------------------------------------------------------------------------
Function GetGuestFullName(pGuest)
	If ЗначениеЗаполнено(pGuest) Тогда
		Return TrimAll(pGuest.FullName);
	Else
		Return "";
	EndIf;
EndFunction //GetGuestFullName

//-----------------------------------------------------------------------------
Function pmGetOperationRemarks(pOprRow) Экспорт
	vOprRem = "";
	If ЗначениеЗаполнено(pOprRow.CheckOutCleaning) Тогда
		If ЗначениеЗаполнено(pOprRow.CheckOutGuest) And ЗначениеЗаполнено(pOprRow.CheckOutAccommodation) Тогда
			If ЗначениеЗаполнено(pOprRow.CheckOutAccommodation.СтатусРазмещения) And pOprRow.CheckOutAccommodation.СтатусРазмещения.ЭтоГости Тогда
				vOprRem = vOprRem + AddComma(vOprRem) + GetGuestFullName(pOprRow.CheckOutGuest);
			ElsIf ЗначениеЗаполнено(pOprRow.Клиент) Тогда
				vOprRem = vOprRem + AddComma(vOprRem) + GetGuestFullName(pOprRow.Клиент);
			EndIf;
		EndIf;
	ElsIf ЗначениеЗаполнено(pOprRow.RegularOperation) Тогда
		vOprRem = vOprRem + AddComma(vOprRem) + GetGuestFullName(pOprRow.InHouseGuest);
		If НЕ IsBlankString(pOprRow.InHouseAccommodationHousekeepingRemarks) Тогда
			vOprRem = vOprRem + AddComma(vOprRem) + TrimAll(pOprRow.InHouseAccommodationHousekeepingRemarks);
		EndIf;
	ElsIf ЗначениеЗаполнено(pOprRow.RegularCleaning) Тогда
		vOprRem = vOprRem + AddComma(vOprRem) + GetGuestFullName(pOprRow.InHouseGuest);
		If НЕ IsBlankString(pOprRow.InHouseAccommodationHousekeepingRemarks) Тогда
			vOprRem = vOprRem + AddComma(vOprRem) + TrimAll(pOprRow.InHouseAccommodationHousekeepingRemarks);
		EndIf;
	ElsIf ЗначениеЗаполнено(pOprRow.RepairEndCleaning) Тогда
		vOprRem = vOprRem + AddComma(vOprRem) + TrimAll(pOprRow.RoomBlockRemarks);
	ElsIf ЗначениеЗаполнено(pOprRow.Клиент) Тогда
		vOprRem = vOprRem + AddComma(vOprRem) + GetGuestFullName(pOprRow.Клиент);
	EndIf;
	Return vOprRem;
EndFunction //pmGetOperationRemarks

//-----------------------------------------------------------------------------
Процедура pmFillOperationRowResources(pRow, pOprRow) Экспорт
	pRow.CheckOutCleaningCount = 0;
	pRow.RegularCleaningCount = 0;
	pRow.RepairEndCleaningCount = 0;
	pRow.VacantRoomCleaningCount = 0;
	pRow.RoomSpace = 0;
	pRow.Продолжительность = 0;
	If ЗначениеЗаполнено(pRow.Operation) Тогда
		If pOprRow.CheckOutCleaning = CheckOutCleaning And ЗначениеЗаполнено(CheckOutCleaning) Тогда
			pRow.CheckOutCleaningCount = 1;
		ElsIf ЗначениеЗаполнено(pOprRow.RegularOperation) And ЗначениеЗаполнено(RegularOperationGroup) Тогда
			pRow.RegularCleaningCount = 1;
		ElsIf pOprRow.RegularCleaning = RegularCleaning And ЗначениеЗаполнено(RegularCleaning) Тогда
			pRow.RegularCleaningCount = 1;
		ElsIf pOprRow.RepairEndCleaning = RepairEndCleaning And ЗначениеЗаполнено(RepairEndCleaning) Тогда
			pRow.RepairEndCleaningCount = 1;
		ElsIf pOprRow.VacantRoomCleaning = VacantRoomCleaning And ЗначениеЗаполнено(VacantRoomCleaning) Тогда
			pRow.VacantRoomCleaningCount = 1;
		EndIf;
		vOprObj = pRow.Operation.GetObject();
		vOprStds = vOprObj.pmGetOperationStandards(Гостиница, pRow.ТипНомера, pRow.НомерРазмещения);
		If vOprStds.Count() > 0 Тогда
			vOprStdsRow = vOprStds.Get(0);
			pRow.RoomSpace = vOprStdsRow.RoomSpace;
			pRow.Продолжительность = vOprStdsRow.Продолжительность;
		EndIf;
	EndIf;
КонецПроцедуры //pmFillOperationRowResources

//-----------------------------------------------------------------------------
Function pmGetAvailableEmployees() Экспорт
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	EmployeeWorkingTimeSchedule.Employee,
	|	EmployeeWorkingTimeSchedule.Employee.Отдел AS Отдел,
	|	EmployeeWorkingTimeSchedule.Employee.ПорядокСортировки AS EmployeeSortCode,
	|	SUM(EmployeeWorkingTimeSchedule.Hours) AS Hours
	|FROM
	|	InformationRegister.EmployeeWorkingTimeSchedule AS EmployeeWorkingTimeSchedule
	|WHERE
	|	(EmployeeWorkingTimeSchedule.Гостиница IN HIERARCHY (&qHotel)
	|			OR &qIsEmptyHotel)
	|	AND (EmployeeWorkingTimeSchedule.НомерРазмещения IN HIERARCHY (&qRoom)
	|			OR &qIsEmptyRoom)
	|	AND (EmployeeWorkingTimeSchedule.Секция IN HIERARCHY (&qRoomSection)
	|			OR &qIsEmptyRoomSection)
	|	AND (EmployeeWorkingTimeSchedule.Отдел IN HIERARCHY (&qDepartment)
	|			OR &qIsEmptyDepartment)
	|	AND EmployeeWorkingTimeSchedule.Period >= &qPeriodFrom
	|	AND EmployeeWorkingTimeSchedule.Period < &qPeriodTo
	|GROUP BY
	|	EmployeeWorkingTimeSchedule.Employee,
	|	EmployeeWorkingTimeSchedule.Employee.Отдел,
	|	EmployeeWorkingTimeSchedule.Employee.ПорядокСортировки
	|HAVING
	|	SUM(EmployeeWorkingTimeSchedule.Hours) > 0
	|ORDER BY
	|	EmployeeSortCode,
	|	EmployeeWorkingTimeSchedule.Employee.Отдел.ПорядокСортировки";
	vQry.SetParameter("qPeriodFrom", BegOfDay(Date));
	vQry.SetParameter("qPeriodTo", EndOfDay(Date));
	vQry.SetParameter("qHotel", Гостиница);
	vQry.SetParameter("qIsEmptyHotel", НЕ ЗначениеЗаполнено(Гостиница));
	vQry.SetParameter("qRoom", Room);
	vQry.SetParameter("qIsEmptyRoom", НЕ ЗначениеЗаполнено(Room));
    vQry.SetParameter("qRoomSection", RoomSection);
    vQry.SetParameter("qIsEmptyRoomSection", НЕ ЗначениеЗаполнено(RoomSection));
	vQry.SetParameter("qDepartment", HousekeepingDepartment);
	vQry.SetParameter("qIsEmptyDepartment", НЕ ЗначениеЗаполнено(HousekeepingDepartment));
	vEmployees = vQry.Execute().Unload();
	Return vEmployees;
EndFunction //pmGetAvailableEmployees

//-----------------------------------------------------------------------------
Function pmGetEmployeePresentation(pEmpRow) Экспорт
	vEmpPres = "";
	// Add employee name
	If ЗначениеЗаполнено(pEmpRow.Employee) Тогда
		vEmpPres = TrimAll(pEmpRow.Employee);
	EndIf;
	// Add employee totals for time and space
	If НЕ IsBlankString(vEmpPres) Тогда
		vEmpPres = vEmpPres + ", ";
	EndIf;
	If pEmpRow.Hours > 0 Тогда
//		vEmpPres = vEmpPres + cmFormatDurationInHours(pEmpRow.Продолжительность, True) + "/" +
//		                      cmFormatDurationInHours(pEmpRow.Hours, True);
	EndIf;
	If pEmpRow.RoomSpace > 0 Тогда
		vEmpPres = vEmpPres + " (" + Format(pEmpRow.RoomSpace, "ND=8; NFD=2; NZ=") + ")";
	EndIf;
	// Add cleaning counts by types
	If НЕ IsBlankString(vEmpPres) Тогда
		vEmpPres = vEmpPres + ", ";
	EndIf;
	If pEmpRow.CheckOutCleaningCount > 0 Тогда
		vEmpPres = vEmpPres + NStr("en='C ';ru='В ';de='In '") + Format(pEmpRow.CheckOutCleaningCount, "ND=6; NFD=0; NZ=");
	EndIf;
	If НЕ IsBlankString(vEmpPres) Тогда
		vEmpPres = vEmpPres + ", ";
	EndIf;
	If pEmpRow.RegularCleaningCount > 0 Тогда
		vEmpPres = vEmpPres + NStr("en='R ';ru='Т ';de='Т '") + Format(pEmpRow.RegularCleaningCount, "ND=6; NFD=0; NZ=");
	EndIf;
	If НЕ IsBlankString(vEmpPres) Тогда
		vEmpPres = vEmpPres + ", ";
	EndIf;
	If pEmpRow.VacantRoomCleaningCount > 0 Тогда
		vEmpPres = vEmpPres + NStr("en='V ';ru='С ';de='Ab '") + Format(pEmpRow.VacantRoomCleaningCount, "ND=6; NFD=0; NZ=");
	EndIf;
	If НЕ IsBlankString(vEmpPres) Тогда
		vEmpPres = vEmpPres + ", ";
	EndIf;
	If pEmpRow.RepairEndCleaningCount > 0 Тогда
		vEmpPres = vEmpPres + NStr("en='A ';ru='Р ';de='R '") + Format(pEmpRow.RepairEndCleaningCount, "ND=6; NFD=0; NZ=");
	EndIf;
	// Remove trailing commas
	vEmpPres = TrimAll(vEmpPres);
	While Right(vEmpPres, 1) = "," Do
		vEmpPres = Left(vEmpPres, StrLen(vEmpPres)-1);
		vEmpPres = TrimAll(vEmpPres);
	EndDo;
	// Return
	Return vEmpPres;
EndFunction //pmGetEmployeePresentation 

//-----------------------------------------------------------------------------
Function GetDayDocuments(pRow, pDay)
	// Get all documents for the given day
	vQry =  New Query();
	vQry.Text = 
	"SELECT
	|	ОперацииСотрудников.Ref
	|FROM
	|	Document.ОперацииСотрудников AS ОперацииСотрудников
	|WHERE
	|	ОперацииСотрудников.OperationStartTime >= &qPeriodFrom
	|			AND ОперацииСотрудников.OperationStartTime <= &qPeriodTo
	|	AND ОперацииСотрудников.Posted
	|	AND ОперацииСотрудников.Employee = &qEmployee
	|	AND ОперацииСотрудников.ТипНомера = &qRoomType
	|	AND ОперацииСотрудников.НомерРазмещения = &qRoom
	|	AND ОперацииСотрудников.Operation = &qOperation";
	vQry.SetParameter("qEmployee", pRow.Employee);
	vQry.SetParameter("qRoomType", pRow.ТипНомера);
	vQry.SetParameter("qRoom", pRow.НомерРазмещения);
	vQry.SetParameter("qOperation", pRow.Operation);
	vQry.SetParameter("qPeriodFrom", BegOfDay(pDay));
	vQry.SetParameter("qPeriodTo", EndOfDay(pDay));
	Return vQry.Execute().Unload();
EndFunction //GetDayDocuments

//-----------------------------------------------------------------------------
Процедура Posting(pCancel, pPostingMode)
	vOperationScheduleDocs = pmGetEmployeeOperations();
	vActualDocs = New СписокЗначений();
	vOperations = New ValueTable();
//	vOperations.Columns.Add("Employee", cmGetCatalogTypeDescription("Employees"));
//	vOperations.Columns.Add("ТипНомера", cmGetCatalogTypeDescription("ТипыНомеров"));
//	vOperations.Columns.Add("НомерРазмещения", cmGetCatalogTypeDescription("НомернойФонд"));
//	vOperations.Columns.Add("Operation", cmGetCatalogTypeDescription("Работы"));
//	vOperations.Columns.Add("Количество", cmGetNumberTypeDescription(6, 0));
//	vOperations.Columns.Add("КоличествоЧеловек", cmGetNumberTypeDescription(6, 0));
	For Each vOprRow In Operations Do
		If ЗначениеЗаполнено(vOprRow.Room) And ЗначениеЗаполнено(vOprRow.RoomType) And 
		   ЗначениеЗаполнено(vOprRow.Operation) And ЗначениеЗаполнено(vOprRow.Employee) Тогда
			vCurOprRow = vOperations.Add();
			vCurOprRow.Employee = vOprRow.Employee;
			vCurOprRow.ТипНомера = vOprRow.RoomType;
			vCurOprRow.НомерРазмещения = vOprRow.ГруппаНомеров;
			vCurOprRow.Operation = vOprRow.Operation;
			If vCurOprRow.Operation = RegularOperationGroup And ЗначениеЗаполнено(RegularCleaning) Тогда
				vCurOprRow.Operation = RegularCleaning;
			EndIf;
			If vOprRow.CheckOutCleaningCount > 0 Тогда
				vCurOprRow.Количество = vOprRow.CheckOutCleaningCount;
			ElsIf vOprRow.RepairEndCleaningCount > 0 Тогда
				vCurOprRow.Количество = vOprRow.RepairEndCleaningCount;
			ElsIf vOprRow.RegularCleaningCount > 0 Тогда
				vCurOprRow.Количество = vOprRow.RegularCleaningCount;
			ElsIf vOprRow.VacantRoomCleaningCount > 0 Тогда
				vCurOprRow.Количество = vOprRow.VacantRoomCleaningCount;
			Else
				vCurOprRow.Количество = 1;
			EndIf;
			vCurOprRow.КоличествоЧеловек = vOprRow.NumberOfGuests;
		EndIf;
	EndDo;
	vOperations.GroupBy("Employee, ТипНомера, НомерРазмещения, Operation", "Количество, КоличествоЧеловек");
	For Each vOperationsRow In vOperations Do
		// Skip posting operation if it is registered manually or via PBX system
		If vOperationsRow.Operation.OperationRegistrationIsUsed Тогда
			Continue;
		EndIf;
		// Get all documents for the given day
		vDocs = GetDayDocuments(vOperationsRow, Date);
		// If current day quantity is zero then get all documents for the given day and delete them
		If vOperationsRow.Количество = 0 Тогда
			For Each vDocsRow In vDocs Do
				vDocObj = vDocsRow.Ref.GetObject();
				vDocObj.SetDeletionMark(True);
				// Save reference to the document being written
				vActualDocs.Add(vDocObj.Ref);
			EndDo;
		EndIf;
		// Update first one and delete all other
		vDocObj = Неопределено;
		If vDocs.Count() > 0 Тогда
			If vDocs.Count() > 1 Тогда
				j = 1;
				While j < vDocs.Count() Do
					vDocObj = vDocs.Get(j).Ref.GetObject();
					vDocObj.SetDeletionMark(True);
					j = j + 1;
					// Save reference to the document being written
					vActualDocs.Add(vDocObj.Ref);
				EndDo;
			EndIf;
			vDocObj = vDocs.Get(0).Ref.GetObject();
		Else
			vDocObj = Documents.ОперацииСотрудников.CreateDocument();
			If ЗначениеЗаполнено(Гостиница) And НЕ Гостиница.IsFolder Тогда
				vDocObj.Гостиница = Гостиница;
			EndIf;
			vDocObj.pmFillAttributesWithDefaultValues();
			vDocObj.ДатаДок = Date;
			vDocObj.SetTime(AutoTimeMode.DontUse);
			vDocObj.Количество = 0; // Reset quantity
			vDocObj.Employee = vOperationsRow.Employee;
			vDocObj.ТипНомера = vOperationsRow.ТипНомера;
			vDocObj.НомерРазмещения = vOperationsRow.НомерРазмещения;
			vDocObj.Operation = vOperationsRow.Operation;
			//vDocObj.OperationStartTime = cm1SecondShift(BegOfDay(Date));
		EndIf;
		// Write document only if it's quantity has changed
		If vDocObj.Количество <> vOperationsRow.Количество Тогда
			// Fill quantity
			vDocObj.Количество = vOperationsRow.Количество;
			// Get operation ГруппаНомеров space
			vStds = vDocObj.Operation.GetObject().pmGetOperationStandards(vDocObj.Гостиница, vDocObj.ТипНомера, vDocObj.НомерРазмещения);
			If vStds.Count() > 0 Тогда
				vStdsRow = vStds.Get(0);
				vDocObj.Продолжительность = vDocObj.Количество * vStdsRow.Продолжительность;
				//vDocObj.OperationEndTime = vDocObj.pmGetOperationEndTime();
				vDocObj.RoomSpace = vDocObj.Количество * vStdsRow.RoomSpace;
			EndIf;
			// Fill number of persons as number of beds in the ГруппаНомеров
			vDocObj.КоличествоЧеловек = vOperationsRow.КоличествоЧеловек;
			// Fill operation articles consumption standards table
			vDocObj.Articles.Clear();
			vDocObj.pmFillArticles();
			// Fill reference to the current document
			vDocObj.ПланРабот = Ref;
			// Post document
			vDocObj.Write(DocumentWriteMode.Posting);
		EndIf;
		// Save reference to the document being written
		vActualDocs.Add(vDocObj.Ref);
	EndDo;
	vOperationScheduleDocs = pmGetEmployeeOperations();
	For Each vOperationScheduleDocsRow In vOperationScheduleDocs Do
		If vActualDocs.FindByValue(vOperationScheduleDocsRow.Ref) = Неопределено Тогда
			vDocObj = vOperationScheduleDocsRow.Ref.GetObject();
			vDocObj.SetDeletionMark(True);
		EndIf;
	EndDo;
КонецПроцедуры //Posting

//-----------------------------------------------------------------------------
Function pmGetEmployeeOperations() Экспорт
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	ОперацииСотрудников.Ref
	|FROM
	|	Document.ОперацииСотрудников AS ОперацииСотрудников
	|WHERE
	|	ОперацииСотрудников.Posted
	|	AND ОперацииСотрудников.ПланРабот = &qOperationSchedule
	|
	|ORDER BY
	|	ОперацииСотрудников.ДатаДок,
	|	ОперацииСотрудников.PointInTime";
	vQry.SetParameter("qOperationSchedule", Ref);
	Return vQry.Execute().Unload();
EndFunction //pmGetEmployeeOperations

//-----------------------------------------------------------------------------
Процедура UndoPosting(pCancel)
	vOperationScheduleDocs = pmGetEmployeeOperations();
	For Each vOperationScheduleDocsRow In vOperationScheduleDocs Do
		vDocObj = vOperationScheduleDocsRow.Ref.GetObject();
		vDocObj.SetDeletionmark(True);
	EndDo;
КонецПроцедуры //UndoPosting
