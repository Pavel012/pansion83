//-----------------------------------------------------------------------------
// Description: Returns value table with ГруппаНомеров statuses
// Parameters: External system code, Language code, ..., Return type
// Return value: Value table with rooms and ГруппаНомеров statuses
//-----------------------------------------------------------------------------
Function cmGetRoomsWithStatuses(pExtSystemCode, pLanguageCode = "RU", pHotelCode, pRoomSectionCode, pRoomStatusCode, pRoomTypeCode, pOutputType = "CSV") Экспорт
	WriteLogEvent(NStr("en='Get rooms with statuses';ru='Получить список номеров с статусами';de='Zimmerliste mit Status erhalten'"), EventLogLevel.Information, , , 
	              NStr("en='External system code: ';ru='Код внешней системы: ';de='Code des externen Systems: '") + pExtSystemCode + Chars.LF + 
	              NStr("en='Language code: ';ru='Код языка: ';de='Sprachencode: '") + pLanguageCode + Chars.LF + 
	              NStr("en='Гостиница code: ';ru='Код гостиницы: ';de='Code des Hotels: '") + pHotelCode + Chars.LF + 
	              NStr("en='Section code: ';ru='Код секции номеров: ';de='Code der Zimmersektion: '") + pRoomSectionCode + Chars.LF + 
	              NStr("en='ГруппаНомеров status code: ';ru='Код статуса номера: ';de='Zimmerstatuscode: '") + pRoomStatusCode + Chars.LF + 
	              NStr("en='ГруппаНомеров type code: ';ru='Код типа номера: ';de='Zimmertypcode: '") + pRoomTypeCode);
	// Retrieve language
	vLanguage = cmGetLanguageByCode(pLanguageCode);
	// Retreive hotel reference 
	vHotel = cmGetHotelByCode(pHotelCode, pExtSystemCode);
	// Retrieve parameter references based on codes
	vRoomType = Справочники.ТипыНомеров.EmptyRef();
	If НЕ IsBlankString(pRoomTypeCode) Тогда
		vRoomType = cmGetObjectRefByExternalSystemCode(vHotel, pExtSystemCode, "ТипыНомеров", pRoomTypeCode);
	EndIf;
	vRoomSection = Справочники.СекцииНомерногоФонда.EmptyRef();
	If НЕ IsBlankString(pRoomSectionCode) Тогда
		vRoomSection = cmGetObjectRefByExternalSystemCode(vHotel, pExtSystemCode, "СекцииНомерногоФонда", pRoomSectionCode);
	EndIf;
	vRoomStatus = Справочники.СтатусыНомеров.EmptyRef();
	If НЕ IsBlankString(pRoomStatusCode) Тогда
		vRoomStatus = cmGetObjectRefByExternalSystemCode(vHotel, pExtSystemCode, "СтатусыНомеров", pRoomStatusCode);
	EndIf;
	// Run query to get list of rooms
	vQry = New Query();
	vQry.Text = 
	"SELECT TOP 999999
	|	НомернойФонд.Description,
	|	НомернойФонд.ТипНомера,
	|	НомернойФонд.ТипНомера.Code AS RoomTypeCode,
	|	НомернойФонд.Секция,
	|	НомернойФонд.Секция.Code AS RoomSectionCode,
	|	НомернойФонд.Секция.Description AS RoomSectionDescription,
	|	НомернойФонд.СтатусНомера,
	|	НомернойФонд.СтатусНомера.Code AS RoomStatusCode,
	|	НомернойФонд.СтатусНомера.Description AS RoomStatusDescription,
	|	НомернойФонд.Parent,
	|	НомернойФонд.Parent.Description AS ParentDescription,
	|	RoomStatusChangeHistorySliceLast.Period AS StatusLastChangeTime,
	|	RoomStatusChangeHistorySliceLast.User AS StatusLastChangeEmployee,
	|	НомернойФонд.СтатусНомера.RoomStatusIcon AS RoomStatusIcon,
	|	TodayReservations.CheckInDate AS CheckInDate
	|FROM
	|	Catalog.НомернойФонд AS НомернойФонд
	|		LEFT JOIN InformationRegister.ИсторияИзмСтатусаНомеров.SliceLast(&qPeriod, НомерРазмещения.Owner = &qHotel) AS RoomStatusChangeHistorySliceLast
	|		ON НомернойФонд.Ref = RoomStatusChangeHistorySliceLast.НомерРазмещения
	|		LEFT JOIN (SELECT
	|			Reservations.НомерРазмещения AS НомерРазмещения,
	|			MIN(Reservations.CheckInDate) AS CheckInDate
	|		FROM
	|			AccumulationRegister.ЗагрузкаНомеров AS Reservations
	|		WHERE
	|			Reservations.IsReservation
	|			AND Reservations.RecordType = &qExpense
	|			AND Reservations.CheckInDate >= &qPeriodFrom
	|			AND Reservations.CheckInDate <= &qPeriodTo
	|			AND Reservations.Гостиница = &qHotel
	|			AND Reservations.НомерРазмещения <> &qEmptyRoom
	|		
	|		GROUP BY
	|			Reservations.НомерРазмещения) AS TodayReservations
	|		ON НомернойФонд.Ref = TodayReservations.НомерРазмещения
	|WHERE
	|	NOT НомернойФонд.DeletionMark
	|	AND НомернойФонд.ДатаВводаЭкспл <= &qPeriod
	|	AND (НомернойФонд.ДатаВыводаЭкспл > &qPeriod
	|			OR НомернойФонд.ДатаВыводаЭкспл = &qEmptyDate)
	|	AND (НомернойФонд.Секция IN HIERARCHY (&qRoomSection)
	|			OR &qRoomSectionIsEmpty)
	|	AND (НомернойФонд.СтатусНомера IN HIERARCHY (&qRoomStatus)
	|			OR &qRoomStatusIsEmpty)
	|	AND (НомернойФонд.ТипНомера IN HIERARCHY (&qRoomType)
	|			OR &qRoomTypeIsEmpty)
	|	AND НомернойФонд.Owner = &qHotel
	|
	|ORDER BY
	|	НомернойФонд.ПорядокСортировки";
	vQry.SetParameter("qPeriod", CurrentDate());
	vQry.SetParameter("qPeriodFrom", BegOfDay(CurrentDate()));
	vQry.SetParameter("qPeriodTo", EndOfDay(CurrentDate()));
	vQry.SetParameter("qEmptyDate", '00010101');
	vQry.SetParameter("qEmptyRoom", Справочники.НомернойФонд.EmptyRef());
	vQry.SetParameter("qHotel", vHotel);
	vQry.SetParameter("qRoomType", vRoomType);
	vQry.SetParameter("qRoomTypeIsEmpty", НЕ ЗначениеЗаполнено(vRoomType));
	vQry.SetParameter("qRoomSection", vRoomSection);
	vQry.SetParameter("qRoomSectionIsEmpty", НЕ ЗначениеЗаполнено(vRoomSection));
	vQry.SetParameter("qRoomStatus", vRoomStatus);
	vQry.SetParameter("qRoomStatusIsEmpty", НЕ ЗначениеЗаполнено(vRoomStatus));
	vQry.SetParameter("qExpense", AccumulationRecordType.Expense);
	vRooms = vQry.Execute().Unload();
	// Initialize return values
	vRetStr = "";
	For Each vRoomsRow In vRooms Do
		vChangeTimePresentation = "";
		If ЗначениеЗаполнено(vRoomsRow.StatusLastChangeTime) Тогда
			If BegOfDay(vRoomsRow.StatusLastChangeTime) = BegOfDay(CurrentDate()) Тогда
				vChangeTimePresentation = Format(vRoomsRow.StatusLastChangeTime, "DF=HH:mm");
			Else
				vChangeTimePresentation = Format(vRoomsRow.StatusLastChangeTime, "DF='dd.MM HH:mm'");
			EndIf;
		EndIf;
		vCheckInTimePresentation = "";
		If ЗначениеЗаполнено(vRoomsRow.CheckInDate) Тогда
			vCheckInTimePresentation = Format(vRoomsRow.CheckInDate, "DF=HH:mm");
		EndIf;
		vRetStr = vRetStr + """" + СокрЛП(vRoomsRow.Description) + """" + 
		                    ", """ + СокрЛП(vRoomsRow.RoomTypeCode) + """" + 
		                    ", """ + cmRemoveComma(vRoomsRow.RoomType.GetObject().pmGetRoomTypeDescription(vLanguage)) + """" + 
		                    ", """ + СокрЛП(vRoomsRow.RoomSectionCode) + """" + 
		                    ", """ + cmRemoveComma(СокрЛП(vRoomsRow.RoomSectionDescription)) + """" + 
		                    ", """ + СокрЛП(vRoomsRow.RoomStatusCode) + """" + 
		                    ", """ + cmRemoveComma(СокрЛП(vRoomsRow.RoomStatusDescription)) + """" + 
		                    ", """ + СокрЛП(vRoomsRow.ParentDescription) + """" + 
		                    ", """ + ?(ЗначениеЗаполнено(vRoomsRow.StatusLastChangeEmployee), vRoomsRow.StatusLastChangeEmployee.GetObject().pmGetEmployeeDescription(vLanguage), "") + """" + 
		                    ", """ + Format(?(ЗначениеЗаполнено(vRoomsRow.StatusLastChangeTime), vRoomsRow.StatusLastChangeTime, '00010101'), "DF='yyyy.MM.dd HH:mm:ss'") + """" + 
		                    ", """ + СокрЛП(vRoomsRow.RoomStatusIcon) + """" + 
		                    ", """ + СокрЛП(vChangeTimePresentation) + """" + 
							", """ + СокрЛП(vCheckInTimePresentation) + """" + Chars.LF;
	EndDo;
	WriteLogEvent(NStr("en='Get rooms with statuses';ru='Получить список номеров с статусами';de='Zimmerliste mit Status erhalten'"), EventLogLevel.Information, , , NStr("en='Return string: ';ru='Строка возврата: ';de='Zeilenrücklauf: '") + vRetStr);
	If pOutputType = "CSV" Тогда
		Return vRetStr;
	Else
		vRetXDTO = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/housekeeping/", "GetRoomsWithStatuses"));
		vRetRowType = XDTOFactory.Type("http://www.1chotel.ru/interfaces/housekeeping/", "GetRoomsWithStatusesRow");
		For Each vRoomsRow In vRooms Do
			vRetRow = XDTOFactory.Create(vRetRowType);
			vRetRow.НомерРазмещения = СокрЛП(vRoomsRow.Description);
			vRetRow.RoomTypeCode = СокрЛП(vRoomsRow.RoomTypeCode);
			vRetRow.RoomTypeDescription = Left(vRoomsRow.RoomType.GetObject().pmGetRoomTypeDescription(vLanguage), 170);
			vRetRow.RoomStatusCode = СокрЛП(vRoomsRow.RoomStatusCode);
			vRetRow.RoomStatusDescription = Left(СокрЛП(vRoomsRow.RoomStatusDescription), 170);
			vRetRow.RoomSectionCode = СокрЛП(vRoomsRow.RoomSectionCode);
			vRetRow.RoomSectionDescription = Left(СокрЛП(vRoomsRow.RoomSectionDescription), 170);
			vRetRow.RoomParent = СокрЛП(vRoomsRow.ParentDescription);
			vRetRow.StatusLastChangeEmployee = ?(ЗначениеЗаполнено(vRoomsRow.StatusLastChangeEmployee), vRoomsRow.StatusLastChangeEmployee.GetObject().pmGetEmployeeDescription(vLanguage), "");
			vRetRow.StatusLastChangeTime = '00010101';
			If ЗначениеЗаполнено(vRoomsRow.StatusLastChangeTime) Тогда
				vRetRow.StatusLastChangeTime = vRoomsRow.StatusLastChangeTime;
			EndIf;
			vRetRow.RoomStatusIcon = СокрЛП(vRoomsRow.RoomStatusIcon);
			If ЗначениеЗаполнено(vRoomsRow.StatusLastChangeTime) Тогда
				If BegOfDay(vRoomsRow.StatusLastChangeTime) = BegOfDay(CurrentDate()) Тогда
					vRetRow.StatusLastChangeTimePresentation = Format(vRoomsRow.StatusLastChangeTime, "DF=HH:mm");
				Else
					vRetRow.StatusLastChangeTimePresentation = Format(vRoomsRow.StatusLastChangeTime, "DF='dd.MM HH:mm'");
				EndIf;
			EndIf;
			vCheckInTimePresentation = "";
			If ЗначениеЗаполнено(vRoomsRow.CheckInDate) Тогда
				vCheckInTimePresentation = Format(vRoomsRow.CheckInDate, "DF=HH:mm");
			EndIf;
			vRetRow.CheckInTime = vCheckInTimePresentation;
			vRetXDTO.GetRoomsWithStatusesRow.Add(vRetRow);
		EndDo;
		Return vRetXDTO;
	EndIf;
EndFunction //cmGetRoomsWithStatuses 

//-----------------------------------------------------------------------------
// Description: Returns value table with ГруппаНомеров statuses allowed for current user
// Parameters: External system code, Language code, Return type
// Return value: Value table with ГруппаНомеров statuses list
//-----------------------------------------------------------------------------
Function cmGetRoomStatuses(pExtSystemCode, pLanguageCode = "RU", pEmployeeCode = 0, pOutputType = "CSV") Экспорт
	WriteLogEvent(NStr("en='Get allowed ГруппаНомеров statuses list';ru='Получить список разрешенных статусов номеров';de='Liste zulässiger Zimmerstatus erhalten'"), EventLogLevel.Information, , , 
	NStr("en='External system code: ';ru='Код внешней системы: ';de='Code des externen Systems: '") + pExtSystemCode + Chars.LF + 
	NStr("en='Language code: ';ru='Код языка: ';de='Sprachencode: '") + pLanguageCode + Chars.LF + 
	NStr("en='Employee code: ';ru='Код сотрудника: ';de='Code des Mitarbeiters: '") + pEmployeeCode);
	// Retrieve language
	vLanguage = cmGetLanguageByCode(pLanguageCode);
	// Retrieve employee by code
	vEmployee = cmGetEmployeeByPBXCode(pEmployeeCode);
	// Run query to get list of ГруппаНомеров statuses
	vRoomStatuses = cmGetAllowedRoomStatuses(vEmployee);
	// Initialize return values
	vRetStr = ?(ЗначениеЗаполнено(vEmployee), vEmployee.GetObject().pmGetEmployeeDescription(vLanguage), "") + Chars.LF;
	For Each vRoomStatusesRow In vRoomStatuses Do
		vRoomStatus = vRoomStatusesRow.СтатусНомера;
		vRetStr = vRetStr + """" + СокрЛП(vRoomStatus.Code) + """" + 
		", """ + СокрЛП(vRoomStatus.Description) + """" + 
		", """ + СокрЛП(vRoomStatus.RoomStatusIcon) + """" + 
		", " + Format(vRoomStatus.ПорядокСортировки, "ND=6; NFD=0; NZ=; NG=") + Chars.LF;
	EndDo;
	vRetStr = СокрЛП(vRetStr);
	WriteLogEvent(NStr("en='Get allowed ГруппаНомеров statuses list';ru='Получить список разрешенных статусов номеров';de='Liste zulässiger Zimmerstatus erhalten'"), EventLogLevel.Information, , , NStr("en='Return string: ';ru='Строка возврата: ';de='Zeilenrücklauf: '") + vRetStr);
	If pOutputType = "CSV" Тогда
		Return vRetStr;
	Else
		vRetXDTO = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/housekeeping/", "GetRoomStatuses"));
		vRetXDTO.EmployeeName = ?(ЗначениеЗаполнено(vEmployee), vEmployee.GetObject().pmGetEmployeeDescription(vLanguage), "");
		vRetRowType = XDTOFactory.Type("http://www.1chotel.ru/interfaces/housekeeping/", "GetRoomStatusesRow");
		For Each vRoomStatusesRow In vRoomStatuses Do
			vRoomStatus = vRoomStatusesRow.СтатусНомера;
			vRetRow = XDTOFactory.Create(vRetRowType);
			vRetRow.RoomStatusCode = СокрЛП(vRoomStatus.Code);
			vRetRow.RoomStatusDescription = Left(СокрЛП(vRoomStatus.Description), 170);
			vRetRow.RoomStatusIcon = СокрЛП(vRoomStatus.RoomStatusIcon);
			vRetRow.RoomStatusSortCode = vRoomStatus.ПорядокСортировки;
			vRetXDTO.GetRoomStatusesRow.Add(vRetRow);
		EndDo;
		Return vRetXDTO;
	EndIf;
EndFunction //cmGetRoomStatuses 

//-----------------------------------------------------------------------------
// Description: Changes ГруппаНомеров status to the next from the current status or to 
//              the specified as input parameter
// Parameters: External system code, Language code, Гостиница code, ГруппаНомеров code, 
//             Current ГруппаНомеров status code, New ГруппаНомеров status code (if empty string is 
//             passed then next allowed for the employee ГруппаНомеров status will be used), 
//             Employee code, Output type
// Return value: Structure with new ГруппаНомеров status data
//-----------------------------------------------------------------------------
Function cmChangeRoomStatus(pExtSystemCode, pLanguageCode = "RU", pHotelCode, pRoomCode, pCurrentRoomStatusCode, pNewRoomStatusCode = "", pEmployeeCode = 0, pOutputType = "CSV") Экспорт
	WriteLogEvent(NStr("en='Change ГруппаНомеров status';ru='Изменить статус номера';de='Zimmerstatus ändern'"), EventLogLevel.Information, , , 
	NStr("en='External system code: ';ru='Код внешней системы: ';de='Code des externen Systems: '") + pExtSystemCode + Chars.LF + 
	NStr("en='Language code: ';ru='Код языка: ';de='Sprachencode: '") + pLanguageCode + Chars.LF + 
	NStr("en='Гостиница code: ';ru='Код гостиницы: ';de='Code des Hotels: '") + pHotelCode + Chars.LF + 
	NStr("en='ГруппаНомеров code: ';ru='Код номера: ';de='Zimmercode: '") + pRoomCode + Chars.LF + 
	NStr("en='Current ГруппаНомеров status code: ';ru='Текущий код статуса номера: ';de='Aktueller Statuscode des Zimmers: '") + pCurrentRoomStatusCode + Chars.LF + 
	NStr("en='New ГруппаНомеров status code: ';ru='Новый код статуса номера: ';de='Neuer Code des Zimmerstatus: '") + pNewRoomStatusCode + Chars.LF + 
	NStr("en='Employee code: ';ru='Код сотрудника: ';de='Code des Mitarbeiters: '") + pEmployeeCode);
	// Retrieve language
	vLanguage = cmGetLanguageByCode(pLanguageCode);
	// Retreive hotel reference 
	vHotel = cmGetHotelByCode(pHotelCode, pExtSystemCode);
	// Retrieve parameter references based on codes
	vRoom = Справочники.НомернойФонд.EmptyRef();
	If НЕ IsBlankString(pRoomCode) Тогда
		vRoom = Справочники.НомернойФонд.FindByDescription(pRoomCode, True, , vHotel);
	EndIf;
	If НЕ ЗначениеЗаполнено(vRoom) Тогда
		ВызватьИсключение NStr("en='Failed to get ГруппаНомеров by code!';ru='Ошибка поиска номера по коду!';de='Fehler bei der Zimmersuche nach Code!'");
	EndIf;
	// Retrieve employee by code
	vEmployee = cmGetEmployeeByPBXCode(pEmployeeCode);
	// Get current ГруппаНомеров status
	vCurrentRoomStatus = Справочники.СтатусыНомеров.EmptyRef();
	If НЕ IsBlankString(pCurrentRoomStatusCode) Тогда
		vCurrentRoomStatus = cmGetObjectRefByExternalSystemCode(vHotel, pExtSystemCode, "СтатусыНомеров", pCurrentRoomStatusCode);
	EndIf;
	If НЕ ЗначениеЗаполнено(vCurrentRoomStatus) Тогда
		ВызватьИсключение NStr("en='Failed to get current ГруппаНомеров status by code!';ru='Ошибка поиска текущего статуса номера по коду!';de='Fehler bei der Suche nach dem aktuellen Zimmerstatus nach Code!'");
	EndIf;
	// Get new ГруппаНомеров status
	vNewRoomStatus = Справочники.СтатусыНомеров.EmptyRef();
	If НЕ IsBlankString(pNewRoomStatusCode) Тогда
		vNewRoomStatus = cmGetObjectRefByExternalSystemCode(vHotel, pExtSystemCode, "СтатусыНомеров", pNewRoomStatusCode);
	Else
		// Run query to get list of ГруппаНомеров statuses
		vAllRoomStatuses = cmGetAllRoomStatuses();
		vAllowedRoomStatuses = cmGetAllowedRoomStatuses(vEmployee);
		vCurrentRoomStatusRow = vAllRoomStatuses.Find(vCurrentRoomStatus, "СтатусНомера");
		If vCurrentRoomStatusRow <> Неопределено And vAllowedRoomStatuses.Count() > 0 Тогда
			i = vAllRoomStatuses.IndexOf(vCurrentRoomStatusRow) + 1;
			While True Do
				If i < vAllRoomStatuses.Count() Тогда
					vNewRoomStatus = vAllRoomStatuses.Get(i).СтатусНомера;
				Else
					i = 0;
					vNewRoomStatus = vAllRoomStatuses.Get(i).СтатусНомера;
				EndIf;
				If ЗначениеЗаполнено(vNewRoomStatus) Тогда
					If vAllowedRoomStatuses.Find(vNewRoomStatus, "СтатусНомера") <> Неопределено Тогда
						Break;
					EndIf;
				EndIf;
				i = i + 1;
			EndDo;
		EndIf;
	EndIf;
	If НЕ ЗначениеЗаполнено(vNewRoomStatus) Тогда
		ВызватьИсключение NStr("en='Failed to get new ГруппаНомеров status by code!';ru='Ошибка поиска нового статуса номера по коду!';de='Fehler bei der Suche des neuen Zimmerstatus nach Code!'");
	EndIf;
	// Do ГруппаНомеров status update
	vRoomObj = vRoom.GetObject();
	vRoomObj.СтатусНомера = vNewRoomStatus;
	vRoomObj.Write();
	// Add record to the ГруппаНомеров status change history
	vRoomObj.pmWriteToRoomStatusChangeHistory(CurrentDate(), ?(ЗначениеЗаполнено(vEmployee), vEmployee, ПараметрыСеанса.ТекПользователь), NStr("en='External interface call';ru='Внешний интерфейс';de='Externes Interface'"));
	// Initialize return values
	vRetStr = """" + СокрЛП(vRoom.Description) + """" + 
	          ", """ + СокрЛП(vRoom.ТипНомера.Code) + """" + 
	          ", """ + vRoom.ТипНомера.GetObject().pmGetRoomTypeDescription(vLanguage) + """" + 
	          ", """ + СокрЛП(vNewRoomStatus.Code) + """" + 
	          ", """ + СокрЛП(vNewRoomStatus.Description) + """" + 
	          ", """ + СокрЛП(vNewRoomStatus.RoomStatusIcon) + """" + 
	          ", """ + ?(ЗначениеЗаполнено(vEmployee), vEmployee.GetObject().pmGetEmployeeDescription(vLanguage), ПараметрыСеанса.ТекПользователь.GetObject().pmGetEmployeeDescription(vLanguage)) + """" +
	          ", """ + Format(CurrentDate(), "DF='yyyy.MM.dd HH:mm:ss'") + """" + 
	          ", " + Format(vNewRoomStatus.ПорядокСортировки, "ND=6; NFD=0; NZ=; NG=") + 
	          ", """ + Format(CurrentDate(), "DF=HH:mm") + """" + Chars.LF;
	WriteLogEvent(NStr("en='Change ГруппаНомеров status';ru='Изменить статус номера';de='Zimmerstatus ändern'"), EventLogLevel.Information, , , NStr("en='Return string: ';ru='Строка возврата: ';de='Zeilenrücklauf: '") + vRetStr);
	If pOutputType = "CSV" Тогда
		Return vRetStr;
	Else
		vRetXDTO = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/housekeeping/", "ChangeRoomStatus"));
		vRetXDTO.RoomStatusCode = СокрЛП(vNewRoomStatus.Code);
		vRetXDTO.RoomStatusDescription = Left(СокрЛП(vNewRoomStatus.Description), 170);
		vRetXDTO.RoomStatusIcon = СокрЛП(vNewRoomStatus.RoomStatusIcon);
		vRetXDTO.StatusLastChangeEmployee = ?(ЗначениеЗаполнено(vEmployee), vEmployee.GetObject().pmGetEmployeeDescription(vLanguage), ПараметрыСеанса.ТекПользователь.GetObject().pmGetEmployeeDescription(vLanguage));
		vRetXDTO.StatusLastChangeTime = CurrentDate();
		vRetXDTO.RoomStatusSortCode = vNewRoomStatus.ПорядокСортировки;
		vRetXDTO.StatusLastChangeTimePresentation = Format(vRetXDTO.StatusLastChangeTime, "DF=HH:mm");
		vRetXDTO.НомерРазмещения = СокрЛП(vRoom.Description);
		vRetXDTO.RoomTypeCode = СокрЛП(vRoom.ТипНомера.Code);
		vRetXDTO.RoomTypeDescription = Left(vRoom.ТипНомера.GetObject().pmGetRoomTypeDescription(vLanguage), 170);
		Return vRetXDTO;
	EndIf;
EndFunction //cmChangeRoomStatus


//-----------------------------------------------------------------------------
Function cmActionProcessing(pMainCode, pActionCode, pTimestamp, pLanguage = "RU") Экспорт
	WriteLogEvent(NStr("en='Action processing';ru='Обработка действия';de='Aktionsverarbeitung'"), EventLogLevel.Information, , , 
					NStr("en='Main code: ';ru='Основной код: ';de='Hauptcode: '") + pMainCode + Chars.LF + 
					NStr("en='Action code: ';ru='Код действия: ';de='Aktionscode: '") + pActionCode + Chars.LF + 
					NStr("en='Timestamp: ';ru='Момент времени: ';de='Timestamp: '") + pTimestamp + Chars.LF + 
					NStr("en='Language code: ';ru='Код языка: ';de='Sprachencode: '") + pLanguage);
	
	// Parameters
	vErrorDescription 	= "";
	vEmployee 			= Справочники.Employees.EmptyRef();
	vRoom 				= Справочники.НомернойФонд.EmptyRef();
	vHotel 				= ПараметрыСеанса.ТекущаяГостиница;
	//We're not use Date value from phone. Use current server date
	//vCurDate 			= pTimestamp;
	vCurDate 			= CurrentDate();
	// Retrieve language
	vLanguage 			= cmGetLanguageByCode(pLanguage);
	
	// Type of return data
	vNeedToReturnOperationsList 	= False;
	vNeedToReturnOperationDetails	= False;
	// If this is first launch an app
	If НЕ ЗначениеЗаполнено(pMainCode) Тогда
		// Get employee
		vEmployeeStruc = cmGetDataByActionCode(pActionCode, "Employees");
		If vEmployeeStruc = Неопределено Тогда
			vErrorDescription = vErrorDescription + "Необходимо авторизоваться. Приложите Вашу карту. (Сотрудник не найден в системе!" + Chars.LF;
		Else
			vEmployee = vEmployeeStruc.Data;
			// Get hotel
			If ЗначениеЗаполнено(vEmployeeStruc.Гостиница) And vEmployeeStruc.Гостиница <> vHotel Тогда
				vHotel = vEmployeeStruc.Гостиница;
			EndIf;
		EndIf;
		If НЕ ЗначениеЗаполнено(vErrorDescription) Тогда
			If НЕ ЗначениеЗаполнено(vEmployee) Тогда
				vErrorDescription = vErrorDescription + "Сотрудник не распознан!" + Chars.LF;
			EndIf;
			If НЕ ЗначениеЗаполнено(vHotel) Тогда
				vErrorDescription = vErrorDescription + "Настройте систему: гостиница не найдена!" + Chars.LF;
			EndIf;
			If НЕ ЗначениеЗаполнено(vErrorDescription) Тогда
				vNeedToReturnOperationsList = True;
			EndIf;
		EndIf;
	// If this is new employee authorization or start of any action
	Else
		// Recognizing the action
		vDataStructure = cmGetDataByActionCode(pActionCode);
		If vDataStructure <> Неопределено Тогда
			// If this is new employee authorization
			If vDataStructure.ТипРазмещения = "Employees" Тогда
				vEmployee = vDataStructure.Data;
				// Get hotel
				If ЗначениеЗаполнено(vDataStructure.Гостиница) And vDataStructure.Гостиница <> vHotel Тогда
					vHotel = vDataStructure.Гостиница;
				EndIf;
				If НЕ ЗначениеЗаполнено(vEmployee) Тогда
					vErrorDescription = vErrorDescription + "Сотрудник не распознан!" + Chars.LF;
				EndIf;
				If НЕ ЗначениеЗаполнено(vHotel) Тогда
					vErrorDescription = vErrorDescription + "Настройте систему: гостиница не найдена!" + Chars.LF;
				EndIf;
				If НЕ ЗначениеЗаполнено(vErrorDescription) Тогда
					vNeedToReturnOperationsList = True;
				EndIf;
			// If this is start or end an operation
			ElsIf vDataStructure.ТипРазмещения = "НомернойФонд" Тогда
				// Get ГруппаНомеров
				vRoom = vDataStructure.Data;
				// Get hotel
				If ЗначениеЗаполнено(vDataStructure.Гостиница) Тогда
					vHotel = vDataStructure.Гостиница;
				EndIf;
				// Get employee
				vEmployeeStruc = cmGetDataByActionCode(pMainCode, "Employees");
				If vEmployeeStruc = Неопределено Тогда
					vErrorDescription = vErrorDescription + "Сотрудник не найден в системе!" + Chars.LF;
				Else
					vEmployee = vEmployeeStruc.Data;
					// Get hotel
					If ЗначениеЗаполнено(vEmployeeStruc.Гостиница) And vEmployeeStruc.Гостиница <> vHotel Тогда
						vHotel = vEmployeeStruc.Гостиница;
					EndIf;
				EndIf;
				If НЕ ЗначениеЗаполнено(vErrorDescription) Тогда
					// Get current ГруппаНомеров status 
					vCurrentRoomStatus = vRoom.СтатусНомера;
					// Skip updating status if it is equal to the new one
					If ЗначениеЗаполнено(vCurrentRoomStatus.NextRoomStatus) Тогда
						// Update ГруппаНомеров status
						vRoomObj = vRoom.GetObject();
						vRoomObj.СтатусНомера = vCurrentRoomStatus.NextRoomStatus;
						vRoomObj.Write();
						// Add record to the ГруппаНомеров status change history
						vRoomObj.pmWriteToRoomStatusChangeHistory(vCurDate, ?(ЗначениеЗаполнено(vEmployee), vEmployee, ПараметрыСеанса.ТекПользователь), "HOUSEKEEPING");
					EndIf;
					// Process start operation and end operation
					If ЗначениеЗаполнено(vEmployee) And ЗначениеЗаполнено(vCurrentRoomStatus) And ЗначениеЗаполнено(vCurrentRoomStatus.Operation) Тогда
						vOperation = vCurrentRoomStatus.Operation;
						// Try to find pending employee operation
						vEmpOpRef = cmGetPendingEmployeeOperation(vEmployee, vOperation, vCurDate, vRoom);
						If НЕ ЗначениеЗаполнено(vEmpOpRef) Тогда
							// Add operation start record
							vStOfOpResult = cmWriteStartOfOperation(vEmployee, vOperation, vRoom, vCurDate, vLanguage);
							If ЗначениеЗаполнено(vStOfOpResult) Тогда
								vErrorDescription = vErrorDescription + vStOfOpResult + Chars.LF;
							EndIf;
						Else
							// End operation
							vEndOfOpResult = cmWriteEndOfOperation(vEmpOpRef, vCurDate, vLanguage);
							If ЗначениеЗаполнено(vEndOfOpResult) Тогда
								vErrorDescription = vErrorDescription + vEndOfOpResult + Chars.LF;
							EndIf;
							// Maid moved to another ГруппаНомеров and forgot to finish operation in previous ГруппаНомеров.
							If vEmpOpRef.НомерРазмещения <> vRoom Or vEmpOpRef.Operation <> vOperation Or (vCurDate - vEmpOpRef.OperationStartTime)/(12*3600) > 12 Тогда
								vStOfOpResult = cmWriteStartOfOperation(vEmployee, vOperation, vRoom, vCurDate, vLanguage);
								If ЗначениеЗаполнено(vStOfOpResult) Тогда
									vErrorDescription = vErrorDescription + vStOfOpResult + Chars.LF;
								EndIf;
							EndIf;
						EndIf;
					EndIf;
					If НЕ ЗначениеЗаполнено(vErrorDescription) Тогда
						If НЕ ЗначениеЗаполнено(vEmployee) Тогда
							vErrorDescription = vErrorDescription + "Сотрудник не распознан!" + Chars.LF;
						EndIf;
						If НЕ ЗначениеЗаполнено(vHotel) Тогда
							vErrorDescription = vErrorDescription + "Настройте систему: гостиница не найдена!" + Chars.LF;
						EndIf;
						If НЕ ЗначениеЗаполнено(vRoom) Тогда
							vErrorDescription = vErrorDescription + "НомерРазмещения не распознан!" + Chars.LF;
						EndIf;
						If НЕ ЗначениеЗаполнено(vErrorDescription) Тогда
							vNeedToReturnOperationDetails = True;
						EndIf;
					EndIf;
				EndIf;
			// If check a mini bar
			ElsIf vDataStructure.ТипРазмещения = "MiniBar" Тогда
			
				
				
				
			Else
				vErrorDescription = vErrorDescription + "Действие не распознано!"+ Chars.LF;
			EndIf;
		Else
			vErrorDescription = vErrorDescription + "Данные об этой карте не найдены в системе!" + Chars.LF;
		EndIf;
	EndIf;
	
	// RETURN DATA
	
	If ЗначениеЗаполнено(vErrorDescription) Тогда
		// return error description
		vRetXDTO = cmGetOperationInfo(vLanguage, vHotel, vEmployee, vCurDate, , vErrorDescription);
	ElsIf vNeedToReturnOperationDetails Тогда
		// return an operation details
		vRetXDTO = cmGetOperationInfo(vLanguage, vHotel, vEmployee, vCurDate, vRoom);
	ElsIf vNeedToReturnOperationsList Тогда
		// return an operations list
		vRetXDTO = cmGetOperationInfo(vLanguage, vHotel, vEmployee, vCurDate);
	Else
		// undefined error
		vRetXDTO = cmGetOperationInfo(vLanguage, vHotel, vEmployee, vCurDate, , "ru='Неизвестная ошибка!");
	EndIf;
	
	Return vRetXDTO;
EndFunction //cmActionProcessing

//----------------------------------------------------------------------------
Function cmGetDataByActionCode(pActionCode, pType = "") Экспорт
	vQuery = New Query;
	vQuery.Text = 
	"SELECT
	|	ExternalSystemsObjectCodesMappings.ObjectRef AS DataRef,
	|	ExternalSystemsObjectCodesMappings.ObjectTypeName AS DataType,
	|	ExternalSystemsObjectCodesMappings.Гостиница AS Гостиница
	|FROM
	|	InformationRegister.ExternalSystemsObjectCodesMappings AS ExternalSystemsObjectCodesMappings
	|WHERE
	|	ExternalSystemsObjectCodesMappings.ExternalSystemCode = &qExternalSystemCode
	|	" + ?(ЗначениеЗаполнено(pType), "AND ExternalSystemsObjectCodesMappings.ObjectTypeName = &qObjectTypeName ", " ") + "
	|	AND ExternalSystemsObjectCodesMappings.ObjectExternalCode = &qObjectExternalCode";
	vQuery.SetParameter("qExternalSystemCode", "HOUSEKEEPING");
	vQuery.SetParameter("qObjectExternalCode", СокрЛП(pActionCode));
	If ЗначениеЗаполнено(pType) Тогда
		vQuery.SetParameter("qObjectTypeName", СокрЛП(pType));
	EndIf;
	vQryResult = vQuery.Execute().Unload();
	
	If vQryResult.Count() > 0 Тогда
		vReturnStructure = New Structure("Type, Data, Гостиница", vQryResult[0].DataType, vQryResult[0].DataRef, vQryResult[0].Гостиница);
		Return vReturnStructure;
	EndIf;
	Return Неопределено;
EndFunction //cmGetDataByActionCode

//-----------------------------------------------------------------------------
Function cmWriteEndOfOperation(pEmpOpRef, pCurrentDate, pLanguage) Экспорт
	Try
		// Update employee operation document
		vEmpOpObj = pEmpOpRef.GetObject();
		// Fill operation end time and duration
		vEmpOpObj.OperationEndTime = pCurrentDate;
		vEmpOpObj.Продолжительность = vEmpOpObj.pmGetOperationDuration();
		// Post document
		vEmpOpObj.Write(DocumentWriteMode.Posting);
	Except
		Return "Не удалось записать конец работы сотрудника! Описание ошибки: " + ErrorDescription();
	EndTry;
	Return "";
EndFunction //cmWriteEndOfOperation

//-----------------------------------------------------------------------------
Function cmWriteStartOfOperation(pEmployee, pOperation, pRoom, pCurrentDate, pLanguage) Экспорт
	Try
		// Check if there is such operation already. Skip loading if found
		vEmpOperations = cmGetEmployeeOperation(pEmployee, pOperation, pCurrentDate);
		If vEmpOperations.Count() = 0 Тогда
			// Create new employee operation document
			vEmpOpObj = Documents.ОперацииСотрудников.CreateDocument();
			vEmpOpObj.SetTime(AutoTimeMode.CurrentOrLast);
			vEmpOpObj.Гостиница = pRoom.Owner;
			vEmpOpObj.pmFillAttributesWithDefaultValues();
			// Fill employee and operation
			vEmpOpObj.Employee = pEmployee;
			vEmpOpObj.Operation = pOperation;
			vEmpOpObj.НомерРазмещения = pRoom;
			vEmpOpObj.OperationStartTime = pCurrentDate;
			// Retrieve ГруппаНомеров resources
			vRoomAttrs = vEmpOpObj.НомерРазмещения.GetObject().pmGetRoomAttributes(vEmpOpObj.OperationStartTime);
			For Each vRoomAttrsRow In vRoomAttrs Do
				vEmpOpObj.ТипНомера = vRoomAttrsRow.ТипНомера;
				Break;
			EndDo;
			// Get number of persons in the ГруппаНомеров for the operation start date
			vEmpOpObj.КоличествоЧеловек = vEmpOpObj.pmGetNumberOfPersons();
			// Fill operation start and end PBX codes
			vEmpOpObj.pmFillPBXCodes();
			// Get operation ГруппаНомеров space
			vStds = vEmpOpObj.Operation.GetObject().pmGetOperationStandards(vEmpOpObj.Гостиница, vEmpOpObj.ТипНомера, vEmpOpObj.НомерРазмещения);
			If vStds.Count() > 0 then
				vStdsRow = vStds.Get(0);
				vEmpOpObj.RoomSpace = vEmpOpObj.Количество * vStdsRow.RoomSpace;
			EndIf;
			// Fill operation articles consumption standards table
			vEmpOpObj.Articles.Clear();
			vEmpOpObj.pmFillArticles();
			// Fill remarks with call data
			vEmpOpObj.Примечания = "HOUSEKEEPING";
			// Post document
			vEmpOpObj.Write(DocumentWriteMode.Posting);
		EndIf;
	Except
		Return "Не удалось записать начало работы сотрудника! Описание ошибки: " + ErrorDescription();
	EndTry;
	Return "";
EndFunction //cmWriteStartOfOperation

//-----------------------------------------------------------------------------
// Description: Returns value table with ГруппаНомеров statuses
// Parameters: External system code, Language code, ..., Return type
// Return value: Value table with rooms and ГруппаНомеров statuses
//-----------------------------------------------------------------------------
Function cmGetOperationInfo(pLanguage, pHotel, pEmployee, pCurrentDate, pRoom = Неопределено, pErrorDescription = "") Экспорт
	WriteLogEvent(NStr("en='Get operation info';ru='Получить информацию о работе';de='Holen Betrieb Infos'"), EventLogLevel.Information, , , 
				NStr("en='Language: ';ru='Язык: ';de='Sprachen: '") + pLanguage + Chars.LF + 
				NStr("en='Гостиница code: ';ru='Код гостиницы: ';de='Code des Hotels: '") + СокрЛП(pHotel.Code) + Chars.LF + 
				NStr("en='Employee code: ';ru='Код сотрудника: ';de='Code des Mitarbeiters: '") + pEmployee.Code + Chars.LF +
				NStr("en='Current date: ';ru='Текущая дата: ';de='aktuelle Datum: '") + Format(pCurrentDate, "DF='dd.MM.yyyy HH:mm:ss'") + Chars.LF + 
				NStr("en='ГруппаНомеров code: ';ru='Код номера: ';de='Zimmercode: '") + СокрЛП(pRoom) + Chars.LF + 
				NStr("en='Error description: ';ru='Текст ошибки: ';de='Fehlerbeschreibung: '") + СокрЛП(pErrorDescription)); 
	
	If pRoom = Неопределено Тогда
		pRoom = Справочники.НомернойФонд.EmptyRef();
	EndIf;
	If НЕ ЗначениеЗаполнено(pErrorDescription) Тогда
		vQry = New Query;
		vQry.Text =	
		"SELECT
		|	OperationScheduleOperations.НомерРазмещения.Owner.Code AS HotelCode,
		|	OperationScheduleOperations.НомерРазмещения AS НомерРазмещения,
		|	OperationScheduleOperations.НомерРазмещения.ТипНомера AS ТипНомера,
		|	OperationScheduleOperations.НомерРазмещения.ТипНомера.Code AS RoomTypeCode,
		|	OperationScheduleOperations.НомерРазмещения.ТипНомера.Description AS RoomTypeDescription,
		|	OperationScheduleOperations.НомерРазмещения.СтатусНомера AS СтатусНомера,
		|	OperationScheduleOperations.НомерРазмещения.СтатусНомера.Code AS RoomStatusCode,
		|	OperationScheduleOperations.НомерРазмещения.СтатусНомера.Description AS RoomStatusDescription,
		|	OperationScheduleOperations.НомерРазмещения.СтатусНомера.RoomStatusIcon AS RoomStatusIcon,
		|	OperationScheduleOperations.Operation.Code AS OperationCode,
		|	OperationScheduleOperations.Operation.Description AS OperationDescription,
		|	ISNULL(EmployeeOperationsHistorySliceLast.OperationStartTime, &qEmptyDate) AS OperationStartTime,
		|	ISNULL(EmployeeOperationsHistorySliceLast.OperationEndTime, &qEmptyDate) AS OperationEndTime
		|FROM
		|	Document.ПланРабот.Работы AS OperationScheduleOperations
		|		LEFT JOIN InformationRegister.EmployeeOperationsHistory.SliceLast(
		|				&qCurrentDate,
		|				Employee = &qEmployee
		|					AND OperationEndTime = &qEmptyDate) AS EmployeeOperationsHistorySliceLast
		|		ON OperationScheduleOperations.НомерРазмещения = EmployeeOperationsHistorySliceLast.НомерРазмещения
		|			AND OperationScheduleOperations.Operation = EmployeeOperationsHistorySliceLast.Operation
		|WHERE
		|	NOT OperationScheduleOperations.Ref.DeletionMark
		|	AND (OperationScheduleOperations.НомерРазмещения = &qRoom
		|			OR &qRoomIsEmpty)
		|	AND OperationScheduleOperations.Ref.ДатаДок <= &qCurrentDate
		|	AND OperationScheduleOperations.Ref.ДатаДок >= &qBegOfCurrentDate
		|	AND OperationScheduleOperations.Ref.Posted
		|	AND OperationScheduleOperations.Ref.Гостиница = &qHotel
		|	AND OperationScheduleOperations.Employee = &qEmployee
		|	AND ISNULL(EmployeeOperationsHistorySliceLast.OperationStartTime, &qEmptyDate) <= &qCurrentDate
		|	AND (ISNULL(EmployeeOperationsHistorySliceLast.OperationEndTime, &qEmptyDate) > &qCurrentDate
		|			OR ISNULL(EmployeeOperationsHistorySliceLast.OperationEndTime, &qEmptyDate) = &qEmptyDate)
		|	AND NOT OperationScheduleOperations.НомерРазмещения.DeletionMark
		|	AND OperationScheduleOperations.НомерРазмещения.Owner = &qHotel " +
		?(НЕ ЗначениеЗаполнено(pRoom), " AND OperationScheduleOperations.Operation <> &qEmptyOperation ", "") +
		
		" ORDER BY
		|	OperationScheduleOperations.НомерРазмещения.ПорядокСортировки";
		vQry.SetParameter("qCurrentDate", pCurrentDate);
		vQry.SetParameter("qEmptyDate", '00010101');
		vQry.SetParameter("qBegOfCurrentDate", BegOfDay(pCurrentDate));
		vQry.SetParameter("qRoom", pRoom);
		If НЕ ЗначениеЗаполнено(pRoom) Тогда
			vQry.SetParameter("qEmptyOperation", Справочники.Работы.EmptyRef());
		EndIf;
		vQry.SetParameter("qRoomIsEmpty", НЕ ЗначениеЗаполнено(pRoom));
		vQry.SetParameter("qEmployee", pEmployee);
		vQry.SetParameter("qHotel", pHotel);
		vRooms = vQry.Execute().Unload();
		
		If vRooms.Count() = 0 Тогда
			vQry = New Query;
			vQry.Text =	
			"SELECT TOP 999999
			|	НомернойФонд.Owner.Code AS HotelCode,
			|	НомернойФонд.Ref AS НомерРазмещения,
			|	НомернойФонд.ТипНомера AS ТипНомера,
			|	НомернойФонд.ТипНомера.Code AS RoomTypeCode,
			|	НомернойФонд.ТипНомера.Description AS RoomTypeDescription,
			|	НомернойФонд.СтатусНомера AS СтатусНомера,
			|	НомернойФонд.СтатусНомера.Code AS RoomStatusCode,
			|	НомернойФонд.СтатусНомера.Description AS RoomStatusDescription,
			|	НомернойФонд.СтатусНомера.RoomStatusIcon AS RoomStatusIcon,
			|	НомернойФонд.СтатусНомера.Operation.Code AS OperationCode,
			|	НомернойФонд.СтатусНомера.Operation.Description AS OperationDescription,
			|	ISNULL(EmployeeOperationsHistorySliceLast.OperationStartTime, &qEmptyDate) AS OperationStartTime,
			|	ISNULL(EmployeeOperationsHistorySliceLast.OperationEndTime, &qEmptyDate) AS OperationEndTime
			|FROM
			|	Catalog.НомернойФонд AS НомернойФонд
			|		LEFT JOIN InformationRegister.EmployeeOperationsHistory.SliceLast(
			|				&qCurrentDate,
			|				Employee = &qEmployee
			|					AND OperationEndTime = &qEmptyDate) AS EmployeeOperationsHistorySliceLast
			|		ON НомернойФонд.Ref = EmployeeOperationsHistorySliceLast.НомерРазмещения
			|			AND НомернойФонд.СтатусНомера.Operation = EmployeeOperationsHistorySliceLast.Operation
			|WHERE
			|	NOT НомернойФонд.DeletionMark
			|	AND ISNULL(EmployeeOperationsHistorySliceLast.OperationStartTime, &qEmptyDate) <= &qCurrentDate
			|	AND (ISNULL(EmployeeOperationsHistorySliceLast.OperationEndTime, &qEmptyDate) > &qCurrentDate
			|			OR ISNULL(EmployeeOperationsHistorySliceLast.OperationEndTime, &qEmptyDate) = &qEmptyDate)
			|	AND НомернойФонд.Owner = &qHotel
			|	AND (НомернойФонд.Ref = &qRoom
			|			OR &qRoomIsEmpty) " +
			?(НЕ ЗначениеЗаполнено(pRoom), "	AND НомернойФонд.СтатусНомера.Operation <> &qEmptyOperation ", "") +
			
			" ORDER BY
			|	НомернойФонд.ПорядокСортировки";
			vQry.SetParameter("qCurrentDate", pCurrentDate);
			vQry.SetParameter("qEmptyDate", '00010101');
			vQry.SetParameter("qRoom", pRoom);
			If НЕ ЗначениеЗаполнено(pRoom) Тогда
				vQry.SetParameter("qEmptyOperation", Справочники.Работы.EmptyRef());
			EndIf;
			vQry.SetParameter("qRoomIsEmpty", НЕ ЗначениеЗаполнено(pRoom));
			vQry.SetParameter("qEmployee", pEmployee);
			vQry.SetParameter("qHotel", pHotel);
			vRooms = vQry.Execute().Unload();
		EndIf;
		
		vRetXDTO = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/housekeeping/", "ActionProcessing"));
		If ЗначениеЗаполнено(pRoom) Тогда
			vRetXDTO.ResponseType = "Detail";
		Else
			vRetXDTO.ResponseType = "List";
		EndIf;
		vRetXDTO.ErrorDescription = СокрЛП(pErrorDescription);
		
		vRetRowType				= XDTOFactory.Type("http://www.1chotel.ru/interfaces/housekeeping/", "ActionProcessingRow");
		vRetGuestListRowType	= XDTOFactory.Type("http://www.1chotel.ru/interfaces/housekeeping/", "GuestListRow");
		For Each vRoomsRow In vRooms Do
			vRetRow = XDTOFactory.Create(vRetRowType);
			
			vNumberOfGuests	= 0;
			
			vRetRow.Гостиница 					= СокрЛП(vRoomsRow.HotelCode);
			vRetRow.НомерРазмещения 					= СокрЛП(vRoomsRow.Room);
			vRetRow.RoomTypeCode 			= СокрЛП(vRoomsRow.RoomTypeCode);
			vRetRow.RoomTypeDescription 	= Left(vRoomsRow.RoomType.GetObject().pmGetRoomTypeDescription(pLanguage), 170);
			vRetRow.RoomStatusCode 			= СокрЛП(vRoomsRow.RoomStatusCode);
			vRetRow.RoomStatusDescription 	= Left(СокрЛП(vRoomsRow.RoomStatusDescription), 170);
			vRetRow.RoomStatusType = "None";
			If vRoomsRow.RoomStatusIcon = Перечисления.RoomStatusesIcons.ВыездФакт Тогда
				vRetRow.RoomStatusType = "ВыездФакт";
			ElsIf vRoomsRow.RoomStatusIcon = Перечисления.RoomStatusesIcons.Occupied Тогда
				vRetRow.RoomStatusType = "Occupied";
			ElsIf vRoomsRow.RoomStatusIcon = Перечисления.RoomStatusesIcons.Reserved Тогда
				vRetRow.RoomStatusType = "Reserved";
			ElsIf vRoomsRow.RoomStatusIcon = Перечисления.RoomStatusesIcons.TidyingUp Тогда
				vRetRow.RoomStatusType = "TidyingUp";
			ElsIf vRoomsRow.RoomStatusIcon = Перечисления.RoomStatusesIcons.Vacant Тогда
				vRetRow.RoomStatusType = "Vacant";
			ElsIf vRoomsRow.RoomStatusIcon = Перечисления.RoomStatusesIcons.Waiting Тогда
				vRetRow.RoomStatusType = "Waiting";
			EndIf;
			vRetRow.OperationCode = СокрЛП(vRoomsRow.OperationCode);
			vRetRow.OperationDescription = СокрЛП(vRoomsRow.OperationDescription);
			vRetRow.OperationStartTime = vRoomsRow.OperationStartTime;
			vRetRow.OperationEndTime = vRoomsRow.OperationEndTime;
			
			// Get ГруппаНомеров object
			vRoomObj = vRoomsRow.ГруппаНомеров.GetObject();
			
			// Get guests in house
			vGuestsTable = vRoomObj.pmGetInHouseGuests();
			
			vIsCheckInWaiting = False;
			If vGuestsTable.Count() = 0 Тогда
				vGuestsTable = cmGetCheckInWaitingGuests(pHotel, vRoomsRow.Room, pCurrentDate);
				If vGuestsTable.Count() > 0 Тогда
					vIsCheckInWaiting = True;
				EndIf;
			Else
				vRowsToDeleteArray = New Array();
				For Each vGuestRow In vGuestsTable Do
					vAccommodation = vGuestRow.Размещение;
					If vAccommodation.ДатаВыезда <= pCurrentDate Тогда
						vRowsToDeleteArray.Add(vGuestRow);
					EndIf;
				EndDo;
				For Each vRowsToDeleteItem in vRowsToDeleteArray Do
					vGuestsTable.Delete(vRowsToDeleteItem);
				EndDo;
			EndIf;
			vRetRow.IsCheckInWaiting = vIsCheckInWaiting;
			
			vRoomBlockTypeCode 			= "";
			vRoomBlockTypeDescription 	= "";
			If vRoomsRow.ГруппаНомеров.ЕстьБлокировки Тогда
				// Get ГруппаНомеров blocks
				vRoomBlocks = vRoomObj.pmGetRoomBlocks();
				
				For Each vRBlock In vRoomBlocks Do
					vRoomBlockTypeCode 			= СокрЛП(vRBlock.RoomBlockType.Code);
					vRoomBlockTypeDescription 	= СокрЛП(vRBlock.RoomBlockType.Description);
					Break;
				EndDo;
			EndIf;
			vRetRow.RoomBlockTypeCode 			= vRoomBlockTypeCode;
			vRetRow.RoomBlockTypeDescription 	= vRoomBlockTypeDescription;
			
			// Create XDTO Guest list
			vRetGuestListXDTO = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/housekeeping/", "GuestList"));
			
			vMiniBarIsOpen = False;
			If vGuestsTable.Count() > 0 Тогда
				For Each vGuestRow In vGuestsTable Do
					// Create XDTO Guest list row
					vRetGuestListRow = XDTOFactory.Create(vRetGuestListRowType);
					
					If vIsCheckInWaiting Тогда
						vNumberOfGuests = vNumberOfGuests + vGuestRow.Бронирование.КоличествоЧеловек;
						If ЗначениеЗаполнено(vGuestRow.Бронирование.Клиент) Тогда
							vRetGuestListRow.Фамилия = СокрЛП(vGuestRow.Бронирование.Клиент.Фамилия);
							vRetGuestListRow.Имя = СокрЛП(vGuestRow.Бронирование.Клиент.Имя);
							vRetGuestListRow.Отчество = СокрЛП(vGuestRow.Бронирование.Клиент.Отчество);
							vRetGuestListRow.Sex = СокрЛП(vGuestRow.Бронирование.Клиент.Sex);
							vRetGuestListRow.ClientTypeDescription = СокрЛП(vGuestRow.Бронирование.Клиент.ТипКлиента.Description);
						Else
							vRetGuestListRow.Фамилия = "";
							vRetGuestListRow.Имя = "";
							vRetGuestListRow.Отчество = "";
							vRetGuestListRow.Sex = "";
							vRetGuestListRow.ClientTypeDescription = "";
						EndIf;
					Else
						vNumberOfGuests = vNumberOfGuests + vGuestRow.Размещение.КоличествоЧеловек;
						vRetGuestListRow.Фамилия = СокрЛП(vGuestRow.Размещение.Клиент.Фамилия);
						vRetGuestListRow.Имя = СокрЛП(vGuestRow.Размещение.Клиент.Имя);
						vRetGuestListRow.Отчество = СокрЛП(vGuestRow.Размещение.Клиент.Отчество);
						vRetGuestListRow.Sex = СокрЛП(vGuestRow.Размещение.Клиент.Sex);
						vRetGuestListRow.ClientTypeDescription = СокрЛП(vGuestRow.Размещение.Клиент.ТипКлиента.Description);
						if vGuestRow.Размещение.Минибар Тогда
							vMiniBarIsOpen = True;
						EndIf;
					EndIf;
					
					vRetGuestListXDTO.GuestListRow.Add(vRetGuestListRow);
				EndDo;
			EndIf;
			
			vRetRow.Минибар 	= vMiniBarIsOpen;
			vRetRow.NumberOfGuests 	= String(vNumberOfGuests);
			vRetRow.GuestList 		= vRetGuestListXDTO;
			vRetXDTO.ActionProcessingRow.Add(vRetRow);
		EndDo;
		If vRooms.Count() = 0 Тогда
			vRetXDTO.ResponseType = "Error";
			vRetXDTO.ErrorDescription = "Обратитесь к Вашему руководству!";
		EndIf;
	Else
		vRetXDTO = XDTOFactory.Create(XDTOFactory.Type("http://www.1chote7l.ru/interfaces/housekeeping/", "ActionProcessing"));
		vRetXDTO.ResponseType = "Error";
		vRetXDTO.ErrorDescription = СокрЛП(pErrorDescription);
	EndIf;
	Return vRetXDTO;	
EndFunction //cmGetOperationInfo

//-----------------------------------------------------------------------------
Function cmGetCheckInWaitingGuests(pHotel, pRoom = Неопределено, pPeriod = '00010101') Экспорт
	If НЕ ЗначениеЗаполнено(pPeriod) Тогда
		pPeriod = CurrentDate();
	EndIf;
	// Build and run query
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	ЗагрузкаНомеров.Клиент AS Клиент,
	|	ЗагрузкаНомеров.Recorder AS Бронирование,
	|	ЗагрузкаНомеров.CheckInDate AS CheckInDate
	|FROM
	|	AccumulationRegister.ЗагрузкаНомеров AS ЗагрузкаНомеров
	|WHERE
	|	ЗагрузкаНомеров.Гостиница = &qHotel
	|	AND ЗагрузкаНомеров.НомерРазмещения = &qRoom
	|	AND ЗагрузкаНомеров.RecordType = &qExpense
	|	AND ЗагрузкаНомеров.IsReservation
	|	AND ЗагрузкаНомеров.CheckInDate > &qPeriod 
	|	AND ЗагрузкаНомеров.CheckInDate < &qEndOfDay 
	|
	|GROUP BY
	|	ЗагрузкаНомеров.Клиент,
	|	ЗагрузкаНомеров.Recorder,
	|	ЗагрузкаНомеров.CheckInDate
	|
	|ORDER BY
	|	ЗагрузкаНомеров.CheckInDate";
	vQry.SetParameter("qHotel", pHotel);
	vQry.SetParameter("qRoom", pRoom);
	vQry.SetParameter("qPeriod", pPeriod);
	vQry.SetParameter("qEndOfDay", EndOfDay(pPeriod));
	vQry.SetParameter("qEmptyRoom", НЕ ЗначениеЗаполнено(pRoom));
	vQry.SetParameter("qExpense", AccumulationRecordType.Expense);
	vQryTab = vQry.Execute().Unload();
	Return vQryTab;
EndFunction //cmGetCheckInWaitingGuests

//-----------------------------------------------------------------------------
Function cmChangeMiniBarStatus(pRoomCode, pHotelCode, pLanguage) Экспорт
	WriteLogEvent(NStr("en='Change mini-bar status';ru='Сменить статус мини-бара';de='Ändern Minibar Status'"), EventLogLevel.Information, , , 
				NStr("en='Language: ';ru='Язык: ';de='Sprachen: '") + СокрЛП(pLanguage) + Chars.LF + 
				NStr("en='Гостиница code: ';ru='Код гостиницы: ';de='Code des Hotels: '") + СокрЛП(pHotelCode) + Chars.LF + 
				NStr("en='ГруппаНомеров code: ';ru='Код номера: ';de='Zimmercode: '") + СокрЛП(pRoomCode)); 
				
				
	vErrorDescription = "";			
	vHotel = cmGetHotelByCode(pHotelCode);
	// Retrieve language
	//vLanguage = cmGetLanguageByCode(pLanguage);
	// Retrieve parameter references based on codes
	vRoom = Справочники.НомернойФонд.EmptyRef();
	If НЕ IsBlankString(pRoomCode) Тогда
		vRoom = Справочники.НомернойФонд.FindByDescription(pRoomCode, True, , vHotel);
	EndIf;
	If НЕ ЗначениеЗаполнено(vRoom) Тогда
		vErrorDescription = "Ошибка поиска номера по коду!";
	EndIf;
	vMiniBarIsOpen = False;
	If НЕ ЗначениеЗаполнено(vErrorDescription) Тогда
		vQry = New Query;
		vQry.Text = 
			"SELECT
			|	Размещение.Ref AS Ref
			|FROM
			|	Document.Размещение AS Размещение
			|WHERE
			|	Размещение.Posted
			|	AND NOT Размещение.DeletionMark
			|	AND Размещение.Гостиница = &qHotel
			|	AND Размещение.СтатусРазмещения.ЭтоГости
			|	AND Размещение.СтатусРазмещения.IsActive
			|	AND Размещение.НомерРазмещения = &qRoom
			|	AND Размещение.CheckInDate <= &qCurrentDate
			|	AND Размещение.ДатаВыезда >= &qCurrentDate";

		vQry.SetParameter("qHotel", vHotel);
		vQry.SetParameter("qRoom", vRoom);
		vQry.SetParameter("qCurrentDate", CurrentDate());

		vResult = vQry.Execute();

		vSelectionDetailRecords = vResult.Choose();
		
        vAccommodation = Documents.Размещение.EmptyRef();
		While vSelectionDetailRecords.Next() Do
			vAccommodation = vSelectionDetailRecords.Ref;
			Break;
		EndDo; 
		If ЗначениеЗаполнено(vAccommodation) Тогда
			vAccObject = vAccommodation.GetObject();
			vAccObject.Минибар = НЕ vAccObject.Минибар;
			vMiniBarIsOpen = vAccObject.Минибар;
			vAccObject.Write();
		Else
			vErrorDescription = "Документ размещения не найден!";
		EndIf;
	EndIf;
	
	WriteLogEvent("Сменить статус мини-бара", EventLogLevel.Information, , , 
		"Мини-бар открыт: " + СокрЛП(vMiniBarIsOpen) + Chars.LF + 
		"Текст ошибки: " + СокрЛП(vErrorDescription));

	vRetXDTO = XDTOFactory.Create(XDTOFactory.Type("http://www.1chote7l.ru/interfaces/housekeeping/", "ChangeMiniBarStatus"));
	vRetXDTO.ErrorDescription = СокрЛП(vErrorDescription);
	Return vRetXDTO;
EndFunction //cmChangeMiniBarStatus

//-----------------------------------------------------------------------------
Function cmRegisterRoomTag(pActionCode, pRoomCode, pHotelCode, pLanguage) Экспорт
	WriteLogEvent(NStr("en='Register ГруппаНомеров tag';ru='Зарегистрировать метку номера';de='Registrieren Raumbeschriftung'"), EventLogLevel.Information, , , 
				NStr("en='Action code: ';ru='Код действия: ';de='Aktionscode: '") + pActionCode + Chars.LF + 
				NStr("en='ГруппаНомеров code: ';ru='Код номера: ';de='Zimmercode: '") + СокрЛП(pRoomCode) + Chars.LF + 
				NStr("en='Language: ';ru='Язык: ';de='Sprachen: '") + СокрЛП(pLanguage) + Chars.LF + 
				NStr("en='Гостиница code: ';ru='Код гостиницы: ';de='Code des Hotels: '") + СокрЛП(pHotelCode));
				
	vHotel = cmGetHotelByCode(pHotelCode);
	// Retrieve language
	vLanguage = cmGetLanguageByCode(pLanguage);
	// Retrieve parameter references based on codes
	vRoom = Справочники.НомернойФонд.EmptyRef();
	If НЕ IsBlankString(pRoomCode) Тогда
		vRoom = Справочники.НомернойФонд.FindByDescription(pRoomCode, True, , vHotel);
	EndIf;		
	vErrorDescription = "";
	If НЕ ЗначениеЗаполнено(vHotel) Or НЕ ЗначениеЗаполнено(vLanguage) Or НЕ ЗначениеЗаполнено(vRoom) Тогда
		vMessage = "Не удалось найти отель или НомерРазмещения в системе.";
		WriteLogEvent("Зарегистрировать метку номера", EventLogLevel.Error, , , vMessage + Chars.LF +
		"Debug info: Гостиница is found: " + String(ЗначениеЗаполнено(vHotel)) + Chars.LF +
		"Language is found: " + String(ЗначениеЗаполнено(vLanguage)) + Chars.LF +
		"НомерРазмещения is found: " + String(ЗначениеЗаполнено(vRoom)));
		vErrorDescription = vMessage;
	EndIf;
	If НЕ ЗначениеЗаполнено(vErrorDescription) Тогда
		Try
			cmDeleteExternalSystemsObjectCodesMappingRowsByObjectRef(vHotel, "HOUSEKEEPING", "НомернойФонд", vRoom);
			cmDeleteExternalSystemsObjectCodesMappingRowsByObjectExternalCode(vHotel, "HOUSEKEEPING", , pActionCode);
			
			// Try to update existing mapping or create new one
			vMgrObj = InformationRegisters.ExternalSystemsObjectCodesMappings.CreateRecordManager();
			vMgrObj.Гостиница = vHotel;
			vMgrObj.ExternalSystemCode = "HOUSEKEEPING";
			vMgrObj.ObjectTypeName = "НомернойФонд";
			vMgrObj.ObjectExternalCode = СокрЛП(pActionCode);
			vMgrObj.ObjectRef = vRoom;
			vMgrObj.Write(True);
		Except
			WriteLogEvent(NStr("en='Register ГруппаНомеров tag';ru='Зарегистрировать метку номера';de='Registrieren Raumbeschriftung'"), EventLogLevel.Error, , , ErrorDescription());
			vErrorDescription = ErrorDescription();
		EndTry;
	EndIf;
	vRetXDTO = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/housekeeping/", "RoomInfoShell"));
	vRetXDTO.ErrorDescription = СокрЛП(vErrorDescription);
	vRoomInfo = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/housekeeping/", "RoomInfo"));
	If ЗначениеЗаполнено(vRoom) Тогда
		vRoomInfo.НомерРазмещения = СокрЛП(vRoom.Description);
		vRoomInfo.RoomTypeCode = СокрЛП(vRoom.ТипНомера.Code);
		vRoomInfo.RoomTypeDescription = СокрЛП(vRoom.ТипНомера.Description);
		vRoomInfo.RoomStatusCode = СокрЛП(vRoom.СтатусНомера.Code);
		vRoomInfo.RoomStatusDescription = СокрЛП(vRoom.СтатусНомера.Description);
		vRoomInfo.Этаж = СокрЛП(vRoom.Этаж);
		vRoomInfo.RoomSectionCode = СокрЛП(vRoom.Секция.Code);
		vRoomInfo.RoomSectionDescription = СокрЛП(vRoom.Секция.Description);
		vRoomInfo.HasRoomBlock = vRoom.ЕстьБлокировки;
		vRoomInfo.СнятСПродажи = vRoom.СнятСПродажи;
		vRoomInfo.Примечания = Left(СокрЛП(vRoom.Примечания), 2048);
	Else
		vRoomInfo.НомерРазмещения = "";
		vRoomInfo.RoomTypeCode = "";
		vRoomInfo.RoomTypeDescription = "";
		vRoomInfo.RoomStatusCode = "";
		vRoomInfo.RoomStatusDescription = "";
		vRoomInfo.Этаж = "";
		vRoomInfo.RoomSectionCode = "";
		vRoomInfo.RoomSectionDescription = "";
		vRoomInfo.HasRoomBlock = False;
		vRoomInfo.СнятСПродажи = False;
		vRoomInfo.Примечания = "";
	EndIf;
	vRetXDTO.RoomInfo = vRoomInfo;
	Return vRetXDTO;
EndFunction //cmRegisterRoomTag

//-----------------------------------------------------------------------------
Function cmRegisterEmployeeTag(pActionCode, pEmployeeCode, pHotelCode, pLanguage) Экспорт
	WriteLogEvent(NStr("en='Register employee tag';ru='Зарегистрировать метку сотрудника';de='Registrieren Mitarbeiter-Tag'"), EventLogLevel.Information, , , 
				NStr("en='Action code: ';ru='Код действия: ';de='Aktionscode: '") + pActionCode + Chars.LF + 
				NStr("en='Employee code: ';ru='Код сотрудника: ';de='Code des Mitarbeiters: '") + СокрЛП(pEmployeeCode) + Chars.LF + 
				NStr("en='Language: ';ru='Язык: ';de='Sprachen: '") + СокрЛП(pLanguage) + Chars.LF + 
				NStr("en='Гостиница code: ';ru='Код гостиницы: ';de='Code des Hotels: '") + СокрЛП(pHotelCode));
				
	vHotel = cmGetHotelByCode(pHotelCode);
	// Retrieve language
	vLanguage = cmGetLanguageByCode(pLanguage);
	// Retrieve parameter references based on codes
	vEmployee = Справочники.Employees.EmptyRef();
	If НЕ IsBlankString(pEmployeeCode) Тогда
		vEmployee = cmGetEmployeeByPBXAccountCode(Number(pEmployeeCode));
	EndIf;	
	vErrorDescription = "";
	If НЕ ЗначениеЗаполнено(vHotel) Or НЕ ЗначениеЗаполнено(vLanguage) Or НЕ ЗначениеЗаполнено(vEmployee) Тогда
		vMessage = "Не удалось найти отель или сотрудника в системе.";
		WriteLogEvent("Зарегистрировать метку сотрудника", EventLogLevel.Error, , ,  vMessage + Chars.LF +
		"Debug info: Гостиница is found: " + String(ЗначениеЗаполнено(vHotel)) + Chars.LF +
		"Language is found: " + String(ЗначениеЗаполнено(vLanguage)) + Chars.LF +
		"Employee is found: " + String(ЗначениеЗаполнено(vEmployee)));
		vErrorDescription = vMessage;
	EndIf;
	If НЕ ЗначениеЗаполнено(vErrorDescription) Тогда
		Try
			cmDeleteExternalSystemsObjectCodesMappingRowsByObjectRef(vHotel, "HOUSEKEEPING", "Employees", vEmployee);
			cmDeleteExternalSystemsObjectCodesMappingRowsByObjectExternalCode(vHotel, "HOUSEKEEPING", , pActionCode);
			
			// Try to update existing mapping or create new one
			vMgrObj = InformationRegisters.ExternalSystemsObjectCodesMappings.CreateRecordManager();
			vMgrObj.Гостиница = vHotel;
			vMgrObj.ExternalSystemCode = "HOUSEKEEPING";
			vMgrObj.ObjectTypeName = "Employees";
			vMgrObj.ObjectExternalCode = СокрЛП(pActionCode);
			vMgrObj.ObjectRef = vEmployee;
			vMgrObj.Write(True);
		Except
			WriteLogEvent(NStr("en='Register employee tag';ru='Зарегистрировать метку сотрудника';de='Registrieren Mitarbeiter-Tag'"), EventLogLevel.Error, , , ErrorDescription());
			vErrorDescription = ErrorDescription();
		EndTry;
	EndIf;
	vRetXDTO = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/housekeeping/", "EmployeeInfoShell"));
	vRetXDTO.ErrorDescription = СокрЛП(vErrorDescription);
	vEmployeeInfo = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/housekeeping/", "EmployeeInfo"));
	If ЗначениеЗаполнено(vEmployee) Тогда
		vEmployeeInfo.EmployeeCode = СокрЛП(vEmployee.Code);
		vEmployeeInfo.EmployeeDescription = СокрЛП(vEmployee.Description);
		vEmployeeInfo.НомерРазмещения = СокрЛП(vEmployee.НомерРазмещения.Description);
		vEmployeeInfo.КодДоступаАТС = vEmployee.КодДоступаАТС;
	Else
		vEmployeeInfo.EmployeeCode = "";
		vEmployeeInfo.EmployeeDescription = "";
		vEmployeeInfo.НомерРазмещения = "";
		vEmployeeInfo.КодДоступаАТС = 0;
	EndIf;
	vRetXDTO.EmployeeInfo = vEmployeeInfo;
	Return vRetXDTO;
EndFunction //cmRegisterEmployeeTag

//-----------------------------------------------------------------------------
Function cmRegisterMinibarTag(pActionCode, pRoomCode, pHotelCode, pLanguage) Экспорт
	WriteLogEvent(NStr("en='Register mini-bar tag';ru='Зарегистрировать метку мини-бара';de='Registrieren Mini-bar Tag'"), EventLogLevel.Information, , , 
				NStr("en='Action code: ';ru='Код действия: ';de='Aktionscode: '") + pActionCode + Chars.LF + 
				NStr("en='ГруппаНомеров code: ';ru='Код номера: ';de='Zimmercode: '") + СокрЛП(pRoomCode) + Chars.LF + 
				NStr("en='Language: ';ru='Язык: ';de='Sprachen: '") + СокрЛП(pLanguage) + Chars.LF + 
				NStr("en='Гостиница code: ';ru='Код гостиницы: ';de='Code des Hotels: '") + СокрЛП(pHotelCode));
				
	vHotel = cmGetHotelByCode(pHotelCode);
	// Retrieve language
	vLanguage = cmGetLanguageByCode(pLanguage);
	// Retrieve parameter references based on codes
	vRoom = Справочники.НомернойФонд.EmptyRef();
	If НЕ IsBlankString(pRoomCode) Тогда
		vRoom = Справочники.НомернойФонд.FindByDescription(pRoomCode, True, , vHotel);
	EndIf;	
	vErrorDescription = "";
	If НЕ ЗначениеЗаполнено(vHotel) Or НЕ ЗначениеЗаполнено(vLanguage) Or НЕ ЗначениеЗаполнено(vRoom) Тогда
		vMessage = "Не удалось найти отель или НомерРазмещения в системе.";
		WriteLogEvent("Зарегистрировать метку мини-бара", EventLogLevel.Error, , , vMessage + Chars.LF +
		"Debug info: Гостиница is found: " + String(ЗначениеЗаполнено(vHotel)) + Chars.LF +
		"Language is found: " + String(ЗначениеЗаполнено(vLanguage)) + Chars.LF +
		"НомерРазмещения is found: " + String(ЗначениеЗаполнено(vRoom)));
		vErrorDescription = vMessage;
	EndIf;
	If НЕ ЗначениеЗаполнено(vErrorDescription) Тогда
		Try
			//cmDeleteExternalSystemsObjectCodesMappingRowsByObjectRef(vHotel, "HOUSEKEEPING", "MiniBars", vRoom);
			//cmDeleteExternalSystemsObjectCodesMappingRowsByObjectExternalCode(vHotel, "HOUSEKEEPING", , pActionCode);
			
			//// Try to update existing mapping or create new one
			//vMgrObj = InformationRegisters.ExternalSystemsObjectCodesMappings.CreateRecordManager();
			//vMgrObj.Гостиница = vHotel;
			//vMgrObj.ExternalSystemCode = "HOUSEKEEPING";
			//vMgrObj.ObjectTypeName = "MiniBars";
			//vMgrObj.ObjectExternalCode = СокрЛП(pActionCode);
			//vMgrObj.ObjectRef = vRoom;
			//vMgrObj.Write(True);
		Except
			WriteLogEvent(NStr("en='Register mini-bar tag';ru='Зарегистрировать метку мини-бара';de='Registrieren Mini-bar Tag'"), EventLogLevel.Error, , , ErrorDescription());
			vErrorDescription = ErrorDescription();
		EndTry;
	EndIf;
	vRetXDTO = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/housekeeping/", "RoomInfoShell"));
	vRetXDTO.ErrorDescription = СокрЛП(vErrorDescription);
	vRoomInfo = XDTOFactory.Create(XDTOFactory.Type("http://www.1chotel.ru/interfaces/housekeeping/", "RoomInfo"));
	If ЗначениеЗаполнено(vRoom) Тогда
		vRoomInfo.НомерРазмещения = СокрЛП(vRoom.Description);
		vRoomInfo.RoomTypeCode = СокрЛП(vRoom.ТипНомера.Code);
		vRoomInfo.RoomTypeDescription = СокрЛП(vRoom.ТипНомера.Description);
		vRoomInfo.RoomStatusCode = СокрЛП(vRoom.СтатусНомера.Code);
		vRoomInfo.RoomStatusDescription = СокрЛП(vRoom.СтатусНомера.Description);
		vRoomInfo.Этаж = СокрЛП(vRoom.Этаж);
		vRoomInfo.RoomSectionCode = СокрЛП(vRoom.Секция.Code);
		vRoomInfo.RoomSectionDescription = СокрЛП(vRoom.Секция.Description);
		vRoomInfo.HasRoomBlock = vRoom.ЕстьБлокировки;
		vRoomInfo.СнятСПродажи = vRoom.СнятСПродажи;
		vRoomInfo.Примечания = Left(СокрЛП(vRoom.Примечания), 2048);
	Else
		vRoomInfo.НомерРазмещения = "";
		vRoomInfo.RoomTypeCode = "";
		vRoomInfo.RoomTypeDescription = "";
		vRoomInfo.RoomStatusCode = "";
		vRoomInfo.RoomStatusDescription = "";
		vRoomInfo.Этаж = "";
		vRoomInfo.RoomSectionCode = "";
		vRoomInfo.RoomSectionDescription = "";
		vRoomInfo.HasRoomBlock = False;
		vRoomInfo.СнятСПродажи = False;
		vRoomInfo.Примечания = "";
	EndIf;
	vRetXDTO.RoomInfo = vRoomInfo;
	Return vRetXDTO;
EndFunction //cmRegisterMinibarTag

//-----------------------------------------------------------------------------
Процедура cmDeleteExternalSystemsObjectCodesMappingRowsByObjectRef(pHotel, pExternalSystemCode, pObjectTypeName, pObjectRef) Экспорт
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	ExternalSystemsObjectCodesMappings.ObjectExternalCode AS ObjectExternalCode
	|FROM
	|	InformationRegister.ExternalSystemsObjectCodesMappings AS ExternalSystemsObjectCodesMappings
	|WHERE
	|	ExternalSystemsObjectCodesMappings.Гостиница = &qHotel
	|	AND ExternalSystemsObjectCodesMappings.ExternalSystemCode = &qExternalSystemCode
	|	AND ExternalSystemsObjectCodesMappings.ObjectTypeName = &qObjectTypeName
	|	AND ExternalSystemsObjectCodesMappings.ObjectRef = &qObjectRef";
	vQry.SetParameter("qHotel", pHotel);
	vQry.SetParameter("qExternalSystemCode", pExternalSystemCode);
	vQry.SetParameter("qObjectTypeName", pObjectTypeName); 
	vQry.SetParameter("qObjectRef", pObjectRef); 
	vObjects = vQry.Execute().Unload();
	For Each vObjRow In vObjects Do
		Try
			vRcdSetObj = InformationRegisters.ExternalSystemsObjectCodesMappings.CreateRecordSet();
			
			vHotelFlt = vRcdSetObj.Filter.Гостиница;
			vHotelFlt.ComparisonType = ComparisonType.Equal;
			vHotelFlt.Value = pHotel;
			vHotelFlt.Use = True;
			
			vExtSystemCodeFlt = vRcdSetObj.Filter.ExternalSystemCode;
			vExtSystemCodeFlt.ComparisonType = ComparisonType.Equal;
			vExtSystemCodeFlt.Value = pExternalSystemCode;
			vExtSystemCodeFlt.Use = True;
			
			vObjectTypeFlt = vRcdSetObj.Filter.ObjectTypeName;
			vObjectTypeFlt.ComparisonType = ComparisonType.Equal;
			vObjectTypeFlt.Value = pObjectTypeName;
			vObjectTypeFlt.Use = True;
			
			vObjectExternalCodeFlt = vRcdSetObj.Filter.ObjectExternalCode;
			vObjectExternalCodeFlt.ComparisonType = ComparisonType.Equal;
			vObjectExternalCodeFlt.Value = СокрЛП(vObjRow.ObjectExternalCode);
			vObjectExternalCodeFlt.Use = True;
			
			vRcdSetObj.Clear();
			vRcdSetObj.Write(True);
		Except
		EndTry;
	EndDo;
КонецПроцедуры //cmDeleteExternalSystemsObjectCodesMappingRowsByObjectRef

//-----------------------------------------------------------------------------
Процедура cmDeleteExternalSystemsObjectCodesMappingRowsByObjectExternalCode(pHotel, pExternalSystemCode, pObjectTypeName = "", pObjectExternalCode) Экспорт
	Try
		vRcdSetObj = InformationRegisters.ExternalSystemsObjectCodesMappings.CreateRecordSet();
		
		vHotelFlt = vRcdSetObj.Filter.Гостиница;
		vHotelFlt.ComparisonType = ComparisonType.Equal;
		vHotelFlt.Value = pHotel;
		vHotelFlt.Use = True;
		
		vExtSystemCodeFlt = vRcdSetObj.Filter.ExternalSystemCode;
		vExtSystemCodeFlt.ComparisonType = ComparisonType.Equal;
		vExtSystemCodeFlt.Value = pExternalSystemCode;
		vExtSystemCodeFlt.Use = True;
		
		if ЗначениеЗаполнено(pObjectTypeName) Тогда
			vObjectTypeFlt = vRcdSetObj.Filter.ObjectTypeName;
			vObjectTypeFlt.ComparisonType = ComparisonType.Equal;
			vObjectTypeFlt.Value = pObjectTypeName;
			vObjectTypeFlt.Use = True;
		EndIf;
		
		vObjectExternalCodeFlt = vRcdSetObj.Filter.ObjectExternalCode;
		vObjectExternalCodeFlt.ComparisonType = ComparisonType.Equal;
		vObjectExternalCodeFlt.Value = СокрЛП(pObjectExternalCode);
		vObjectExternalCodeFlt.Use = True;
		
		vRcdSetObj.Clear();
		vRcdSetObj.Write(True);
	Except
	EndTry;
КонецПроцедуры //cmDeleteExternalSystemsObjectCodesMappingRowsByObjectExternalCode
