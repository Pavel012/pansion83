////-----------------------------------------------------------------------------
//// Reports framework start
////-----------------------------------------------------------------------------
//
////-----------------------------------------------------------------------------
//Процедура pmSaveReportAttributes() Экспорт
//	cmSaveReportAttributes(ThisObject);
//КонецПроцедуры //pmSaveReportAttributes
//
////-----------------------------------------------------------------------------
//Процедура pmLoadReportAttributes(pParameter = Неопределено) Экспорт
//	cmLoadReportAttributes(ThisObject, pParameter);
//КонецПроцедуры //pmLoadReportAttributes
//
////-----------------------------------------------------------------------------
//// Initialize attributes with default values
//// Attention: This procedure could be called AFTER some attributes initialization
//// routine, so it SHOULD NOT reset attributes being set before
////-----------------------------------------------------------------------------
//Процедура pmFillAttributesWithDefaultValues() Экспорт
//	// Fill parameters with default values
//	If НЕ ЗначениеЗаполнено(Гостиница) Тогда
//		Гостиница = ПараметрыСеанса.ТекущаяГостиница;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(PeriodFrom) Тогда
//		PeriodFrom = BegOfDay(CurrentDate()); // For today
//		PeriodTo = EndOfDay(PeriodFrom);
//	EndIf;
//	If НЕ ЗначениеЗаполнено(PeriodCheckType) Тогда
//		PeriodCheckType = Перечисления.PeriodCheckTypes.Intersection;
//	EndIf;
//КонецПроцедуры //pmFillAttributesWithDefaultValues
//
////-----------------------------------------------------------------------------
//Function pmGetReportParametersPresentation() Экспорт
//	vParamPresentation = "";
//	If ЗначениеЗаполнено(Гостиница) Тогда
//		If НЕ Гостиница.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("en='Гостиница ';ru='Гостиница ';de='Гостиница'") + 
//			                     Гостиница.GetObject().pmGetHotelPrintName(ПараметрыСеанса.ТекЛокализация) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("en='Hotels folder ';ru='Группа гостиниц ';de='Gruppe Hotels '") + 
//			                     Гостиница.GetObject().pmGetHotelPrintName(ПараметрыСеанса.ТекЛокализация) + 
//			                     ";" + Chars.LF;
//		EndIf;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(PeriodFrom) And НЕ ЗначениеЗаполнено(PeriodTo) Тогда
//		vParamPresentation = vParamPresentation + NStr("en='Report period is not set';ru='Период отчета не установлен';de='Berichtszeitraum nicht festgelegt'") + 
//		                     ";" + Chars.LF;
//	ElsIf НЕ ЗначениеЗаполнено(PeriodFrom) And ЗначениеЗаполнено(PeriodTo) Тогда
//		vParamPresentation = vParamPresentation + NStr("ru = 'Период c '; en = 'Period from '") + 
//		                     Format(PeriodFrom, "DF='dd.MM.yyyy HH:mm:ss'") + 
//		                     ";" + Chars.LF;
//	ElsIf ЗначениеЗаполнено(PeriodFrom) And НЕ ЗначениеЗаполнено(PeriodTo) Тогда
//		vParamPresentation = vParamPresentation + NStr("ru = 'Период по '; en = 'Period to '") + 
//		                     Format(PeriodTo, "DF='dd.MM.yyyy HH:mm:ss'") + 
//		                     ";" + Chars.LF;
//	ElsIf PeriodFrom = PeriodTo Тогда
//		vParamPresentation = vParamPresentation + NStr("ru = 'Период на '; en = 'Period on '") + 
//		                     Format(PeriodFrom, "DF='dd.MM.yyyy HH:mm:ss'") + 
//		                     ";" + Chars.LF;
//	ElsIf PeriodFrom < PeriodTo Тогда
//		vParamPresentation = vParamPresentation + NStr("ru = 'Период '; en = 'Period '") + PeriodPresentation(PeriodFrom, PeriodTo, cmLocalizationCode()) + 
//		                     ";" + Chars.LF;
//	Else
//		vParamPresentation = vParamPresentation + NStr("en='Period is wrong!';ru='Неправильно задан период!';de='Der Zeitraum wurde falsch eingetragen!'") + 
//		                     ";" + Chars.LF;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(PeriodCheckType) Тогда
//		vParamPresentation = vParamPresentation + NStr("en='Report period check type is not set';ru='Вид проверки периода отчета не установлен';de='Art der Kontrolle des Berichtszeitraums nicht festgelegt'") + 
//		                     ";" + Chars.LF;
//	ElsIf PeriodCheckType = Перечисления.PeriodCheckTypes.Intersection Тогда
//		vParamPresentation = vParamPresentation + NStr("en='Reservations for the period selected';ru='Отбор брони в выбранном периоде';de='Reservierungsauswahl im gewählten Zeitraum'") + 
//		                     ";" + Chars.LF;
//	ElsIf PeriodCheckType = Перечисления.PeriodCheckTypes.StartsInPeriod Тогда
//		vParamPresentation = vParamPresentation + NStr("en='Reservations with check-in date in the period selected';ru='Отбор брони с датой заезда в выбранном периоде';de='Auswahl der Buchung mit Anreisedatum im gewählten Zeitraum'") + 
//		                     ";" + Chars.LF;
//	ElsIf PeriodCheckType = Перечисления.PeriodCheckTypes.EndsInPeriod Тогда
//		vParamPresentation = vParamPresentation + NStr("en='Reservations with check-out date in the period selected';ru='Отбор брони с датой выезда в выбранном периоде';de='Auswahl der Buchung mit Abreisedatum im gewählten Zeitraum'") + 
//		                     ";" + Chars.LF;
//	ElsIf PeriodCheckType = Перечисления.PeriodCheckTypes.StartsOrEndsInPeriod Тогда
//		vParamPresentation = vParamPresentation + NStr("en='Reservations with check-in or check-out date in the period selected';ru='Отбор брони с датой заезда или датой выезда в выбранном периоде';de='Auswahl der Buchung mit Anreise- oder Abreisedatum im gewählten Zeitraum'") + 
//		                     ";" + Chars.LF;
//	ElsIf PeriodCheckType = Перечисления.PeriodCheckTypes.DocDateInPeriod Тогда
//		vParamPresentation = vParamPresentation + NStr("en='Reservations with creation date in the period selected';ru='Отбор брони с датой создания в выбранном периоде';de='Auswahl der Buchung mit Erstellungsdatum im gewählten Zeitraum'") + 
//		                     ";" + Chars.LF;
//	Endif;		
//	If ЗначениеЗаполнено(ГруппаНомеров) Тогда
//		If НЕ ГруппаНомеров.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("en='ГруппаНомеров ';ru='Номер ';de='Zimmer'") + 
//			                     TrimAll(ГруппаНомеров.Description) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("en='Rooms folder ';ru='Группа номеров ';de='Gruppe Zimmer '") + 
//			                     TrimAll(ГруппаНомеров.Description) + 
//			                     ";" + Chars.LF;
//		EndIf;
//	EndIf;
//	If ЗначениеЗаполнено(RoomType) Тогда
//		If НЕ RoomType.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("en='ГруппаНомеров type ';ru='Тип номера ';de='Zimmertyp'") + 
//			                     TrimAll(RoomType.Description) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("en='ГруппаНомеров types folder ';ru='Группа типов номеров ';de='Gruppe Zimmertypen'") + 
//			                     TrimAll(RoomType.Description) + 
//			                     ";" + Chars.LF;
//		EndIf;
//	EndIf;
//	If ShowActiveOnly Тогда
//		vParamPresentation = vParamPresentation + NStr("en='Active reservations only';ru='Только действующая бронь';de='Nur gültige Reservierung'") + 
//							 ";" + Chars.LF;
//	EndIf;
//	If ShowInactiveOnly Тогда
//		vParamPresentation = vParamPresentation + NStr("en='Inactive reservations only';ru='Только недействующая бронь';de='Nur ungültige Reservierung'") + 
//							 ";" + Chars.LF;
//	EndIf;
//	Return vParamPresentation;
//EndFunction //pmGetReportParametersPresentation
//
////-----------------------------------------------------------------------------
//// Runs report
////-----------------------------------------------------------------------------
//Процедура pmGenerate(pSpreadsheet) Экспорт
//	Перем vTemplateAttributes;
//	
//	// Reset report builder template
//	ReportBuilder.Template = Неопределено;
//	
//	// Initialize report builder query generator attributes
//	ReportBuilder.PresentationAdding = PresentationAdditionType.Add;
//	
//	// Fill report parameters
//	ReportBuilder.Parameters.Вставить("qHotel", Гостиница);
//	ReportBuilder.Parameters.Вставить("qHotelIsEmpty", НЕ ЗначениеЗаполнено(Гостиница));
//	ReportBuilder.Parameters.Вставить("qPeriodFrom", PeriodFrom);
//	ReportBuilder.Parameters.Вставить("qPeriodTo", PeriodTo);
//	ReportBuilder.Parameters.Вставить("qBegOfTime", '00010101');
//	ReportBuilder.Parameters.Вставить("qEndOfTime", '39991231235959');
//	ReportBuilder.Parameters.Вставить("qBegOfCurrentDate", BegOfDay(CurrentDate()));
//	ReportBuilder.Parameters.Вставить("qPeriodCheckType", PeriodCheckType);
//	ReportBuilder.Parameters.Вставить("qIntersection", Перечисления.PeriodCheckTypes.Intersection);
//	ReportBuilder.Parameters.Вставить("qCheckIn", Перечисления.PeriodCheckTypes.StartsInPeriod);
//	ReportBuilder.Parameters.Вставить("qCheckOut", Перечисления.PeriodCheckTypes.EndsInPeriod);
//	ReportBuilder.Parameters.Вставить("qCheckInOrCheckOut", Перечисления.PeriodCheckTypes.StartsOrEndsInPeriod);
//	ReportBuilder.Parameters.Вставить("qDocDateInPeriod", Перечисления.PeriodCheckTypes.DocDateInPeriod);
//	ReportBuilder.Parameters.Вставить("qRoom", ГруппаНомеров);
//	ReportBuilder.Parameters.Вставить("qRoomIsEmpty", НЕ ЗначениеЗаполнено(ГруппаНомеров));
//	ReportBuilder.Parameters.Вставить("qRoomType", RoomType);
//	ReportBuilder.Parameters.Вставить("qRoomTypeIsEmpty", НЕ ЗначениеЗаполнено(RoomType));
//	ReportBuilder.Parameters.Вставить("qRecordType", AccumulationRecordType.Expense);
//	ReportBuilder.Parameters.Вставить("qShowActiveOnly", ShowActiveOnly);
//	ReportBuilder.Parameters.Вставить("qShowInactiveOnly", ShowInactiveOnly);
//	ReportBuilder.Parameters.Вставить("qShowInvoicesAndDeposits", ShowInvoicesAndDeposits);
//
//	// Execute report builder query
//	ReportBuilder.Execute();
//	
//	// Apply appearance settings to the report template
//	//vTemplateAttributes = cmApplyReportTemplateAppearance(ThisObject);
//	
//	// Output report to the spreadsheet
//	ReportBuilder.Put(pSpreadsheet);
//	//ReportBuilder.Template.Show(); // For debug purpose
//
//	// Apply appearance settings to the report spreadsheet
//	//cmApplyReportAppearance(ThisObject, pSpreadsheet, vTemplateAttributes);
//КонецПроцедуры //pmGenerate
//
////-----------------------------------------------------------------------------
//Процедура pmInitializeReportBuilder() Экспорт
//	ReportBuilder = New ReportBuilder();
//	
//	// Initialize default query text
//	QueryText = 
//	"SELECT
//	|	ReservationsRef.ГруппаГостей AS ГруппаГостей,
//	|	COUNT(ReservationsRef.Ref) AS ReservationsCount
//	|INTO ReservationsPerGuestGroup
//	|FROM
//	|	Document.Reservation AS ReservationsRef
//	|WHERE
//	|	ReservationsRef.Posted
//	|	AND (ReservationsRef.Гостиница IN HIERARCHY (&qHotel)
//	|			OR &qHotelIsEmpty)
//	|	AND (ReservationsRef.НомерРазмещения IN HIERARCHY (&qRoom)
//	|			OR &qRoomIsEmpty)
//	|	AND (ReservationsRef.ТипНомера IN HIERARCHY (&qRoomType)
//	|			OR &qRoomTypeIsEmpty)
//	|	AND (ISNULL(ReservationsRef.ReservationStatus.IsActive, FALSE)
//	|			OR NOT &qShowActiveOnly)
//	|	AND (NOT ISNULL(ReservationsRef.ReservationStatus.IsActive, FALSE)
//	|			OR NOT &qShowInactiveOnly)
//	|	AND (ReservationsRef.CheckInDate < &qPeriodTo
//	|				AND ReservationsRef.CheckOutDate > &qPeriodFrom
//	|				AND &qPeriodCheckType = &qIntersection
//	|			OR ReservationsRef.CheckInDate >= &qPeriodFrom
//	|				AND ReservationsRef.CheckInDate < &qPeriodTo
//	|				AND (&qPeriodCheckType = &qCheckIn
//	|					OR &qPeriodCheckType = &qCheckInOrCheckOut)
//	|			OR ReservationsRef.CheckOutDate > &qPeriodFrom
//	|				AND ReservationsRef.CheckOutDate <= &qPeriodTo
//	|				AND (&qPeriodCheckType = &qCheckOut
//	|					OR &qPeriodCheckType = &qCheckInOrCheckOut)
//	|			OR ReservationsRef.ДатаДок >= &qPeriodFrom
//	|				AND ReservationsRef.ДатаДок < &qPeriodTo
//	|				AND &qPeriodCheckType = &qDocDateInPeriod)
//	|
//	|GROUP BY
//	|	ReservationsRef.ГруппаГостей
//	|;
//	|
//	|////////////////////////////////////////////////////////////////////////////////
//	|SELECT
//	|	Reservations.Гостиница AS Гостиница,
//	|	Reservations.Контрагент AS Контрагент,
//	|	Reservations.Договор AS Договор,
//	|	Reservations.ГруппаГостей AS ГруппаГостей,
//	|	Reservations.Ref.ReservationStatus AS ReservationStatus,
//	|	Reservations.Ref.Клиент AS Клиент,
//	|	Reservations.Ref.CheckInDate AS CheckInDate,
//	|	Reservations.Ref.Продолжительность AS Продолжительность,
//	|	Reservations.Ref.CheckOutDate AS CheckOutDate,
//	|	Reservations.Ref.ТипНомера AS ТипНомера,
//	|	Reservations.Ref.ВидРазмещения AS ВидРазмещения,
//	|	Reservations.Ref.НомерРазмещения AS НомерРазмещения,
//	|	Reservations.Ref.Тариф AS Тариф,
//	|	Reservations.Ref AS Recorder,
//	|	Reservations.КоличествоЧеловек AS КоличествоЧеловек,
//	|	Reservations.КоличествоНомеров AS КоличествоНомеров,
//	|	Reservations.КоличествоМест AS КоличествоМест,
//	|	Reservations.КолДопМест AS КолДопМест,
//	|	Reservations.NumberOfCheckedInGuests AS NumberOfCheckedInGuests,
//	|	Reservations.NumberOfCheckedInRooms AS NumberOfCheckedInRooms,
//	|	Reservations.NumberOfCheckedInBeds AS NumberOfCheckedInBeds,
//	|	Reservations.NumberOfCheckedInAdditionalBeds AS NumberOfCheckedInAdditionalBeds,
//	|	BEGINOFPERIOD(Reservations.Ref.ДатаДок, DAY) AS CreateDate,
//	|	WEEK(Reservations.Ref.ДатаДок) AS CreateWeek,
//	|	Услуги.Валюта,
//	|	ChargedServices.Amount AS Amount,
//	|	Услуги.ExpectedAmount AS ExpectedAmount,
//	|	Reservations.GuestGroupsCount AS GuestGroupsCount,
//	|	Reservations.AverageGuestGroupsCountPerWeek AS AverageGuestGroupsCountPerWeek
//	|{SELECT
//	|	Гостиница.* AS Гостиница,
//	|	Reservations.Ref.Агент.* AS Агент,
//	|	Reservations.Ref.ТипКонтрагента AS ТипКонтрагента,
//	|	Контрагент.* AS Контрагент,
//	|	Договор.* AS Договор,
//	|	ГруппаГостей.* AS ГруппаГостей,
//	|	Reservations.КонтактноеЛицо AS КонтактноеЛицо,
//	|	Reservations.Ref.ТипКлиента.* AS ТипКлиента,
//	|	CheckInDate AS CheckInDate,
//	|	Продолжительность AS Продолжительность,
//	|	CheckOutDate AS CheckOutDate,
//	|	(HOUR(Reservations.Ref.CheckInDate)) AS CheckInHour,
//	|	(BEGINOFPERIOD(Reservations.Ref.CheckInDate, DAY)) AS CheckInDay,
//	|	(WEEK(Reservations.Ref.CheckInDate)) AS CheckInWeek,
//	|	(MONTH(Reservations.Ref.CheckInDate)) AS CheckInMonth,
//	|	(QUARTER(Reservations.Ref.CheckInDate)) AS CheckInQuarter,
//	|	(YEAR(Reservations.Ref.CheckInDate)) AS CheckInYear,
//	|	(HOUR(Reservations.Ref.ДатаДок)) AS CreateHour,
//	|	CreateDate,
//	|	CreateWeek,
//	|	(MONTH(Reservations.Ref.ДатаДок)) AS CreateMonth,
//	|	(QUARTER(Reservations.Ref.ДатаДок)) AS CreateQuarter,
//	|	(YEAR(Reservations.Ref.ДатаДок)) AS CreateYear,
//	|	Клиент.* AS Клиент,
//	|	ТипНомера.* AS ТипНомера,
//	|	ВидРазмещения.* AS ВидРазмещения,
//	|	НомерРазмещения.* AS НомерРазмещения,
//	|	Reservations.Ref.RoomRateType.* AS RoomRateType,
//	|	Тариф.* AS Тариф,
//	|	Reservations.Ref.PlannedPaymentMethod.* AS PlannedPaymentMethod,
//	|	Reservations.Ref.ReservationStatus.* AS ReservationStatus,
//	|	Reservations.Ref.IsMaster AS IsMaster,
//	|	Reservations.Ref.ПутевкаКурсовка.* AS ПутевкаКурсовка,
//	|	Reservations.Ref.КвотаНомеров.* AS КвотаНомеров,
//	|	Reservations.Ref.МаретингНапрвл.* AS МаретингНапрвл,
//	|	Reservations.Ref.TripPurpose.* AS TripPurpose,
//	|	Reservations.Ref.ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
//	|	Reservations.Ref.ДисконтКарт AS ДисконтКарт,
//	|	Reservations.Ref.ТипСкидки AS ТипСкидки,
//	|	Reservations.Ref.Скидка AS Скидка,
//	|	Reservations.Ref.КомиссияАгента AS КомиссияАгента,
//	|	Reservations.Ref.ВидКомиссииАгента AS ВидКомиссииАгента,
//	|	Reservations.Ref.RoomQuantity AS RoomQuantity,
//	|	Reservations.Ref.КоличествоМестНомер AS КоличествоМестНомер,
//	|	Reservations.Ref.КоличествоГостейНомер AS КоличествоГостейНомер,
//	|	Reservations.Ref.ДокОснование.* AS ДокОснование,
//	|	Reservations.Ref.СрокБрони AS СрокБрони,
//	|	Reservations.Фирма.* AS Фирма,
//	|	Reservations.Примечания AS Примечания,
//	|	Reservations.Ref.Car AS Car,
//	|	Reservations.Автор.* AS Автор,
//	|	Reservations.Ref.AnnulationReason AS AnnulationReason,
//	|	Reservations.Ref.DateOfAnnulation AS DateOfAnnulation,
//	|	Reservations.Ref.AuthorOfAnnulation AS AuthorOfAnnulation,
//	|	Reservations.Ref.* AS Recorder,
//	|	Reservations.Ref.ExternalCode AS ExternalCode,
//	|	Валюта.* AS Валюта,
//	|	КоличествоЧеловек,
//	|	КоличествоНомеров,
//	|	КоличествоМест,
//	|	КолДопМест,
//	|	NumberOfCheckedInGuests,
//	|	NumberOfCheckedInRooms,
//	|	NumberOfCheckedInBeds,
//	|	NumberOfCheckedInAdditionalBeds,
//	|	Amount,
//	|	ExpectedAmount,
//	|	Reservations.Account.*,
//	|	Reservations.ВалютаСчета.*,
//	|	Reservations.DaysBeforeCheckIn,
//	|	Reservations.InvoiceAge,
//	|	Reservations.SumInvoice,
//	|	Reservations.SumPayed,
//	|	Reservations.AccountBalance,
//	|	GuestGroupsCount,
//	|	AverageGuestGroupsCountPerWeek}
//	|FROM
//	|	(SELECT
//	|		ReservationTotals.Ref.Гостиница AS Гостиница,
//	|		ReservationTotals.Ref.ГруппаГостей AS ГруппаГостей,
//	|		ReservationTotals.Ref.Контрагент AS Контрагент,
//	|		ReservationTotals.Ref.Договор AS Договор,
//	|		ReservationTotals.Ref.КонтактноеЛицо AS КонтактноеЛицо,
//	|		ReservationTotals.Ref AS Ref,
//	|		ReservationTotals.Ref.Примечания AS Примечания,
//	|		ReservationTotals.Ref.Фирма AS Фирма,
//	|		ReservationTotals.Ref.Автор AS Автор,
//	|		ReservationFolioBalances.СчетПроживания AS Account,
//	|		ReservationFolioBalances.ВалютаЛицСчета AS ВалютаСчета,
//	|		DATEDIFF(&qBegOfCurrentDate, BEGINOFPERIOD(ReservationTotals.Ref.CheckInDate, DAY), DAY) AS DaysBeforeCheckIn,
//	|		0 AS InvoiceAge,
//	|		0 AS SumInvoice,
//	|		ISNULL(ReservationFolioBalances.FolioBalance, 0) AS AccountBalance,
//	|		0 AS SumPayed,
//	|		ReservationTotals.КоличествоЧеловек AS КоличествоЧеловек,
//	|		ReservationTotals.КоличествоНомеров AS КоличествоНомеров,
//	|		ReservationTotals.КоличествоМест AS КоличествоМест,
//	|		ReservationTotals.КолДопМест AS КолДопМест,
//	|		ReservationTotals.NumberOfCheckedInGuests AS NumberOfCheckedInGuests,
//	|		ReservationTotals.NumberOfCheckedInRooms AS NumberOfCheckedInRooms,
//	|		ReservationTotals.NumberOfCheckedInBeds AS NumberOfCheckedInBeds,
//	|		ReservationTotals.NumberOfCheckedInAdditionalBeds AS NumberOfCheckedInAdditionalBeds,
//	|		1 / ReservationsPerGuestGroup.ReservationsCount AS GuestGroupsCount,
//	|		0 AS AverageGuestGroupsCountPerWeek
//	|	FROM
//	|		(SELECT
//	|			ReservationsRef.Ref AS Ref,
//	|			1 AS GuestGroupsCount,
//	|			MIN(ReservationsRef.КоличествоЧеловек) AS КоличествоЧеловек,
//	|			MIN(ReservationsRef.КоличествоНомеров) AS КоличествоНомеров,
//	|			MIN(ReservationsRef.КоличествоМест) AS КоличествоМест,
//	|			MIN(ReservationsRef.КолДопМест) AS КолДопМест,
//	|			SUM(Accommodations.ЗаездГостей) AS NumberOfCheckedInGuests,
//	|			SUM(Accommodations.ЗаездНомеров) AS NumberOfCheckedInRooms,
//	|			SUM(Accommodations.ЗаездМест) AS NumberOfCheckedInBeds,
//	|			SUM(Accommodations.ЗаездДополнительныхМест) AS NumberOfCheckedInAdditionalBeds
//	|		FROM
//	|			Document.Reservation AS ReservationsRef
//	|				LEFT JOIN AccumulationRegister.ЗагрузкаНомеров AS Accommodations
//	|				ON (Accommodations.ДокОснование = ReservationsRef.Ref)
//	|					AND (Accommodations.IsAccommodation)
//	|					AND (Accommodations.ЭтоЗаезд)
//	|					AND (Accommodations.RecordType = &qRecordType)
//	|		WHERE
//	|			ReservationsRef.Posted
//	|			AND (ReservationsRef.Гостиница IN HIERARCHY (&qHotel)
//	|					OR &qHotelIsEmpty)
//	|			AND (ReservationsRef.НомерРазмещения IN HIERARCHY (&qRoom)
//	|					OR &qRoomIsEmpty)
//	|			AND (ReservationsRef.ТипНомера IN HIERARCHY (&qRoomType)
//	|					OR &qRoomTypeIsEmpty)
//	|			AND (ISNULL(ReservationsRef.ReservationStatus.IsActive, FALSE)
//	|					OR NOT &qShowActiveOnly)
//	|			AND (NOT ISNULL(ReservationsRef.ReservationStatus.IsActive, FALSE)
//	|					OR NOT &qShowInactiveOnly)
//	|			AND (ReservationsRef.CheckInDate < &qPeriodTo
//	|						AND ReservationsRef.CheckOutDate > &qPeriodFrom
//	|						AND &qPeriodCheckType = &qIntersection
//	|					OR ReservationsRef.CheckInDate >= &qPeriodFrom
//	|						AND ReservationsRef.CheckInDate < &qPeriodTo
//	|						AND (&qPeriodCheckType = &qCheckIn
//	|							OR &qPeriodCheckType = &qCheckInOrCheckOut)
//	|					OR ReservationsRef.CheckOutDate > &qPeriodFrom
//	|						AND ReservationsRef.CheckOutDate <= &qPeriodTo
//	|						AND (&qPeriodCheckType = &qCheckOut
//	|							OR &qPeriodCheckType = &qCheckInOrCheckOut)
//	|					OR ReservationsRef.ДатаДок >= &qPeriodFrom
//	|						AND ReservationsRef.ДатаДок < &qPeriodTo
//	|						AND &qPeriodCheckType = &qDocDateInPeriod)
//	|		
//	|		GROUP BY
//	|			ReservationsRef.Ref) AS ReservationTotals
//	|			LEFT JOIN (SELECT
//	|				AccountsBalance.СчетПроживания AS СчетПроживания,
//	|				AccountsBalance.ВалютаЛицСчета AS ВалютаЛицСчета,
//	|				AccountsBalance.СчетПроживания.ДокОснование AS FolioParentDoc,
//	|				SUM(AccountsBalance.SumBalance) AS FolioBalance
//	|			FROM
//	|				AccumulationRegister.Взаиморасчеты.Balance(&qEndOfTime, СчетПроживания.Гостиница IN HIERARCHY (&qHotel)) AS AccountsBalance
//	|			
//	|			GROUP BY
//	|				AccountsBalance.СчетПроживания,
//	|				AccountsBalance.ВалютаЛицСчета,
//	|				AccountsBalance.СчетПроживания.ДокОснование) AS ReservationFolioBalances
//	|			ON ReservationTotals.Ref = ReservationFolioBalances.FolioParentDoc
//	|				AND (&qShowInvoicesAndDeposits)
//	|			LEFT JOIN ReservationsPerGuestGroup AS ReservationsPerGuestGroup
//	|			ON ReservationTotals.Ref.ГруппаГостей = ReservationsPerGuestGroup.ГруппаГостей
//	|	
//	|	UNION ALL
//	|	
//	|	SELECT
//	|		InvoiceAccountsTurnovers.Гостиница,
//	|		InvoiceAccountsTurnovers.ГруппаГостей,
//	|		InvoiceAccountsTurnovers.Контрагент,
//	|		InvoiceAccountsTurnovers.Договор,
//	|		InvoiceAccountsTurnovers.СчетНаОплату.КонтактноеЛицо,
//	|		NULL,
//	|		InvoiceAccountsTurnovers.СчетНаОплату.Примечания,
//	|		InvoiceAccountsTurnovers.Фирма,
//	|		InvoiceAccountsTurnovers.СчетНаОплату.Автор,
//	|		InvoiceAccountsTurnovers.СчетНаОплату,
//	|		InvoiceAccountsTurnovers.ВалютаРасчетов,
//	|		0,
//	|		DATEDIFF(BEGINOFPERIOD(InvoiceAccountsTurnovers.СчетНаОплату.ДатаДок, DAY), &qBegOfCurrentDate, DAY),
//	|		InvoiceAccountsTurnovers.SumReceipt,
//	|		InvoiceAccountsTurnovers.SumReceipt - InvoiceAccountsTurnovers.SumExpense,
//	|		InvoiceAccountsTurnovers.SumExpense,
//	|		0,
//	|		0,
//	|		0,
//	|		0,
//	|		0,
//	|		0,
//	|		0,
//	|		0,
//	|		0,
//	|		0
//	|	FROM
//	|		AccumulationRegister.ВзаиморасчетыПоСчетам.Turnovers(
//	|				&qBegOfTime,
//	|				&qEndOfTime,
//	|				Period,
//	|				Гостиница IN HIERARCHY (&qHotel)
//	|					AND ГруппаГостей IN
//	|						(SELECT
//	|							PlannedCheckIn.ГруппаГостей
//	|						FROM
//	|							Document.Reservation AS PlannedCheckIn
//	|						WHERE
//	|							PlannedCheckIn.Posted
//	|							AND (PlannedCheckIn.Гостиница IN HIERARCHY (&qHotel)
//	|								OR &qHotelIsEmpty)
//	|							AND (PlannedCheckIn.НомерРазмещения IN HIERARCHY (&qRoom)
//	|								OR &qRoomIsEmpty)
//	|							AND (PlannedCheckIn.ТипНомера IN HIERARCHY (&qRoomType)
//	|								OR &qRoomTypeIsEmpty)
//	|							AND (ISNULL(PlannedCheckIn.ReservationStatus.IsActive, FALSE)
//	|								OR NOT &qShowActiveOnly)
//	|							AND (NOT ISNULL(PlannedCheckIn.ReservationStatus.IsActive, FALSE)
//	|								OR NOT &qShowInactiveOnly)
//	|							AND (PlannedCheckIn.CheckInDate < &qPeriodTo
//	|									AND PlannedCheckIn.CheckOutDate > &qPeriodFrom
//	|									AND &qPeriodCheckType = &qIntersection
//	|								OR PlannedCheckIn.CheckInDate >= &qPeriodFrom
//	|									AND PlannedCheckIn.CheckInDate < &qPeriodTo
//	|									AND (&qPeriodCheckType = &qCheckIn
//	|										OR &qPeriodCheckType = &qCheckInOrCheckOut)
//	|								OR PlannedCheckIn.CheckOutDate > &qPeriodFrom
//	|									AND PlannedCheckIn.CheckOutDate <= &qPeriodTo
//	|									AND (&qPeriodCheckType = &qCheckOut
//	|										OR &qPeriodCheckType = &qCheckInOrCheckOut)
//	|								OR PlannedCheckIn.ДатаДок >= &qPeriodFrom
//	|									AND PlannedCheckIn.ДатаДок < &qPeriodTo
//	|									AND &qPeriodCheckType = &qDocDateInPeriod)
//	|							AND &qShowInvoicesAndDeposits
//	|						GROUP BY
//	|										PlannedCheckIn.ГруппаГостей)) AS InvoiceAccountsTurnovers) AS Reservations
//	|		LEFT JOIN (SELECT
//	|			ReservationServices.ДокОснование AS Ref,
//	|			ReservationServices.ВалютаЛицСчета AS Валюта,
//	|			SUM(ReservationServices.ExpectedSalesTurnover) AS ExpectedAmount
//	|		FROM
//	|			AccumulationRegister.ПрогнозРеализации.Turnovers(
//	|					,
//	|					,
//	|					Period,
//	|					(Гостиница IN HIERARCHY (&qHotel)
//	|						OR &qHotelIsEmpty)
//	|						AND (ДокОснование.НомерРазмещения IN HIERARCHY (&qRoom)
//	|							OR &qRoomIsEmpty)
//	|						AND (ДокОснование.ТипНомера IN HIERARCHY (&qRoomType)
//	|							OR &qRoomTypeIsEmpty)
//	|						AND (ISNULL(ДокОснование.ReservationStatus.IsActive, FALSE)
//	|							OR NOT &qShowActiveOnly)
//	|						AND (NOT ISNULL(ДокОснование.ReservationStatus.IsActive, FALSE)
//	|							OR NOT &qShowInactiveOnly)
//	|						AND (ДокОснование.CheckInDate < &qPeriodTo
//	|								AND ДокОснование.CheckOutDate > &qPeriodFrom
//	|								AND &qPeriodCheckType = &qIntersection
//	|							OR ДокОснование.CheckInDate >= &qPeriodFrom
//	|								AND ДокОснование.CheckInDate < &qPeriodTo
//	|								AND (&qPeriodCheckType = &qCheckIn
//	|									OR &qPeriodCheckType = &qCheckInOrCheckOut)
//	|							OR ДокОснование.CheckOutDate > &qPeriodFrom
//	|								AND ДокОснование.CheckOutDate <= &qPeriodTo
//	|								AND (&qPeriodCheckType = &qCheckOut
//	|									OR &qPeriodCheckType = &qCheckInOrCheckOut)
//	|							OR ДокОснование.ДатаДок >= &qPeriodFrom
//	|								AND ДокОснование.ДатаДок < &qPeriodTo
//	|								AND &qPeriodCheckType = &qDocDateInPeriod)) AS ReservationServices
//	|		
//	|		GROUP BY
//	|			ReservationServices.ДокОснование,
//	|			ReservationServices.ВалютаЛицСчета) AS Услуги
//	|		ON Reservations.Ref = Услуги.Ref
//	|		LEFT JOIN (SELECT
//	|			ReservationChargedServices.ДокОснование AS Ref,
//	|			ReservationChargedServices.ВалютаЛицСчета AS Валюта,
//	|			SUM(ReservationChargedServices.SumReceipt) AS Amount
//	|		FROM
//	|			AccumulationRegister.РелизацияТекОтчетПериод.BalanceAndTurnovers(
//	|					,
//	|					,
//	|					Period,
//	|					RegisterRecordsAndPeriodBoundaries,
//	|					(Гостиница IN HIERARCHY (&qHotel)
//	|						OR &qHotelIsEmpty)
//	|						AND (ДокОснование.НомерРазмещения IN HIERARCHY (&qRoom)
//	|							OR &qRoomIsEmpty)
//	|						AND (ДокОснование.ТипНомера IN HIERARCHY (&qRoomType)
//	|							OR &qRoomTypeIsEmpty)
//	|						AND (ISNULL(ДокОснование.ReservationStatus.IsActive, FALSE)
//	|							OR NOT &qShowActiveOnly)
//	|						AND (NOT ISNULL(ДокОснование.ReservationStatus.IsActive, FALSE)
//	|							OR NOT &qShowInactiveOnly)
//	|						AND (ДокОснование.CheckInDate < &qPeriodTo
//	|								AND ДокОснование.CheckOutDate > &qPeriodFrom
//	|								AND &qPeriodCheckType = &qIntersection
//	|							OR ДокОснование.CheckInDate >= &qPeriodFrom
//	|								AND ДокОснование.CheckInDate < &qPeriodTo
//	|								AND (&qPeriodCheckType = &qCheckIn
//	|									OR &qPeriodCheckType = &qCheckInOrCheckOut)
//	|							OR ДокОснование.CheckOutDate > &qPeriodFrom
//	|								AND ДокОснование.CheckOutDate <= &qPeriodTo
//	|								AND (&qPeriodCheckType = &qCheckOut
//	|									OR &qPeriodCheckType = &qCheckInOrCheckOut)
//	|							OR ДокОснование.ДатаДок >= &qPeriodFrom
//	|								AND ДокОснование.ДатаДок < &qPeriodTo
//	|								AND &qPeriodCheckType = &qDocDateInPeriod)) AS ReservationChargedServices
//	|		
//	|		GROUP BY
//	|			ReservationChargedServices.ДокОснование,
//	|			ReservationChargedServices.ВалютаЛицСчета) AS ChargedServices
//	|		ON Reservations.Ref = ChargedServices.Ref
//	|{WHERE
//	|	Reservations.Ref.* AS Recorder,
//	|	Reservations.Ref.ExternalCode AS ExternalCode,
//	|	Reservations.Гостиница.* AS Гостиница,
//	|	Reservations.Ref.ТипНомера.* AS ТипНомера,
//	|	Reservations.Ref.НомерРазмещения.* AS НомерРазмещения,
//	|	Reservations.Контрагент.* AS Контрагент,
//	|	Reservations.Ref.ТипКонтрагента.* AS ТипКонтрагента,
//	|	Reservations.Договор.* AS Договор,
//	|	Reservations.КонтактноеЛицо AS КонтактноеЛицо,
//	|	Reservations.Ref.Агент.* AS Агент,
//	|	Reservations.ГруппаГостей.* AS ГруппаГостей,
//	|	Reservations.Ref.ДокОснование.* AS ДокОснование,
//	|	Reservations.Ref.ПутевкаКурсовка.* AS ПутевкаКурсовка,
//	|	Reservations.Ref.ReservationStatus.* AS ReservationStatus,
//	|	Reservations.Ref.CheckInDate AS CheckInDate,
//	|	Reservations.Ref.Продолжительность AS Продолжительность,
//	|	Reservations.Ref.CheckOutDate AS CheckOutDate,
//	|	Reservations.Ref.КвотаНомеров.* AS КвотаНомеров,
//	|	Reservations.Ref.RoomQuantity AS RoomQuantity,
//	|	Reservations.Ref.ТипКлиента.* AS ТипКлиента,
//	|	Reservations.Ref.Клиент.* AS Клиент,
//	|	Reservations.Ref.МаретингНапрвл.* AS МаретингНапрвл,
//	|	Reservations.Ref.TripPurpose.* AS TripPurpose,
//	|	Reservations.Ref.ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
//	|	Reservations.Ref.RoomRateType.* AS RoomRateType,
//	|	Reservations.Ref.Тариф.* AS Тариф,
//	|	Reservations.Ref.ДисконтКарт AS ДисконтКарт,
//	|	Reservations.Ref.ТипСкидки AS ТипСкидки,
//	|	Reservations.Ref.Скидка AS Скидка,
//	|	Reservations.Ref.PlannedPaymentMethod.* AS PlannedPaymentMethod,
//	|	Reservations.Ref.СрокБрони AS СрокБрони,
//	|	Reservations.Фирма.* AS Фирма,
//	|	Reservations.Примечания AS Примечания,
//	|	Reservations.Ref.Car AS Car,
//	|	Reservations.Автор.* AS Автор,
//	|	Reservations.Ref.КомиссияАгента AS КомиссияАгента,
//	|	Reservations.Ref.ВидКомиссииАгента AS ВидКомиссииАгента,
//	|	Reservations.Ref.IsMaster AS IsMaster,
//	|	Reservations.КоличествоЧеловек AS КоличествоЧеловек,
//	|	Reservations.КоличествоНомеров AS КоличествоНомеров,
//	|	Reservations.КоличествоМест AS КоличествоМест,
//	|	Reservations.КолДопМест AS КолДопМест,
//	|	Reservations.NumberOfCheckedInGuests AS NumberOfCheckedInGuests,
//	|	Reservations.NumberOfCheckedInRooms AS NumberOfCheckedInRooms,
//	|	Reservations.NumberOfCheckedInBeds AS NumberOfCheckedInBeds,
//	|	Reservations.NumberOfCheckedInAdditionalBeds AS NumberOfCheckedInAdditionalBeds,
//	|	Услуги.Валюта.* AS Валюта,
//	|	ChargedServices.Amount AS Amount,
//	|	Услуги.ExpectedAmount AS ExpectedAmount,
//	|	Reservations.Account.*,
//	|	Reservations.ВалютаСчета.*,
//	|	Reservations.DaysBeforeCheckIn,
//	|	Reservations.InvoiceAge,
//	|	Reservations.AccountBalance,
//	|	Reservations.SumInvoice,
//	|	Reservations.SumPayed,
//	|	Reservations.GuestGroupsCount}
//	|
//	|ORDER BY
//	|	Гостиница,
//	|	Контрагент,
//	|	Договор,
//	|	ГруппаГостей,
//	|	CheckInDate,
//	|	Клиент
//	|{ORDER BY
//	|	Reservations.Ref.* AS Recorder,
//	|	Гостиница.* AS Гостиница,
//	|	Reservations.Ref.Агент.* AS Агент,
//	|	Контрагент.* AS Контрагент,
//	|	Reservations.Ref.ТипКонтрагента.* AS ТипКонтрагента,
//	|	Договор.* AS Договор,
//	|	ГруппаГостей.* AS ГруппаГостей,
//	|	CheckInDate AS CheckInDate,
//	|	Клиент.* AS Клиент,
//	|	Reservations.Ref.МаретингНапрвл.* AS МаретингНапрвл,
//	|	Reservations.Ref.TripPurpose.* AS TripPurpose,
//	|	Reservations.Ref.ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
//	|	Reservations.Ref.ReservationStatus.* AS ReservationStatus,
//	|	Тариф.* AS Тариф,
//	|	Reservations.Ref.RoomRateType.* AS RoomRateType,
//	|	Reservations.Ref.ДисконтКарт.* AS ДисконтКарт,
//	|	Reservations.Ref.ТипСкидки.* AS ТипСкидки,
//	|	Reservations.Ref.PlannedPaymentMethod.* AS PlannedPaymentMethod,
//	|	Reservations.Ref.НомерРазмещения.* AS НомерРазмещения,
//	|	Reservations.Ref.ТипНомера.* AS ТипНомера,
//	|	Reservations.Ref.ExternalCode AS ExternalCode,
//	|	Reservations.Ref.СрокБрони AS СрокБрони,
//	|	CheckInDate AS CheckInDate,
//	|	Продолжительность AS Продолжительность,
//	|	CheckOutDate AS CheckOutDate,
//	|	Reservations.Ref.RoomRateType.* AS RoomRateType,
//	|	Тариф.* AS Тариф,
//	|	Reservations.Фирма.* AS Фирма,
//	|	Reservations.Автор.* AS Автор,
//	|	Reservations.Ref.КвотаНомеров.* AS КвотаНомеров,
//	|	Валюта.*,
//	|	Amount,
//	|	ExpectedAmount,
//	|	(HOUR(Reservations.Ref.CheckInDate)) AS CheckInHour,
//	|	(BEGINOFPERIOD(Reservations.Ref.CheckInDate, DAY)) AS CheckInDay,
//	|	(WEEK(Reservations.Ref.CheckInDate)) AS CheckInWeek,
//	|	(MONTH(Reservations.Ref.CheckInDate)) AS CheckInMonth,
//	|	(QUARTER(Reservations.Ref.CheckInDate)) AS CheckInQuarter,
//	|	(YEAR(Reservations.Ref.CheckInDate)) AS CheckInYear,
//	|	(HOUR(Reservations.Ref.ДатаДок)) AS CreateHour,
//	|	CreateDate,
//	|	CreateWeek,
//	|	(MONTH(Reservations.Ref.ДатаДок)) AS CreateMonth,
//	|	(QUARTER(Reservations.Ref.ДатаДок)) AS CreateQuarter,
//	|	(YEAR(Reservations.Ref.ДатаДок)) AS CreateYear,
//	|	КоличествоЧеловек,
//	|	КоличествоНомеров,
//	|	КоличествоМест,
//	|	КолДопМест,
//	|	NumberOfCheckedInGuests,
//	|	NumberOfCheckedInRooms,
//	|	NumberOfCheckedInBeds,
//	|	NumberOfCheckedInAdditionalBeds,
//	|	Reservations.Account.*,
//	|	Reservations.ВалютаСчета.*,
//	|	Reservations.DaysBeforeCheckIn,
//	|	Reservations.InvoiceAge,
//	|	Reservations.SumInvoice,
//	|	Reservations.AccountBalance,
//	|	Reservations.SumPayed,
//	|	GuestGroupsCount}
//	|TOTALS
//	|	SUM(КоличествоЧеловек),
//	|	SUM(КоличествоНомеров),
//	|	SUM(КоличествоМест),
//	|	SUM(КолДопМест),
//	|	SUM(NumberOfCheckedInGuests),
//	|	SUM(NumberOfCheckedInRooms),
//	|	SUM(NumberOfCheckedInBeds),
//	|	SUM(NumberOfCheckedInAdditionalBeds),
//	|	SUM(Amount),
//	|	SUM(ExpectedAmount),
//	|	SUM(GuestGroupsCount),
//	|	CASE
//	|		WHEN CreateDate IS NULL 
//	|				AND NOT CreateWeek IS NULL 
//	|			THEN SUM(GuestGroupsCount) / 7
//	|		ELSE SUM(AverageGuestGroupsCountPerWeek)
//	|	END AS AverageGuestGroupsCountPerWeek
//	|BY
//	|	OVERALL,
//	|	Гостиница,
//	|	Контрагент,
//	|	Договор,
//	|	ГруппаГостей,
//	|	CreateWeek,
//	|	CreateDate
//	|{TOTALS BY
//	|	Гостиница.* AS Гостиница,
//	|	ТипНомера.* AS ТипНомера,
//	|	НомерРазмещения.* AS НомерРазмещения,
//	|	Контрагент.* AS Контрагент,
//	|	Reservations.Ref.* AS Recorder,
//	|	Reservations.Ref.ТипКонтрагента.* AS ТипКонтрагента,
//	|	Договор.* AS Договор,
//	|	Reservations.КонтактноеЛицо AS КонтактноеЛицо,
//	|	Reservations.Ref.Агент.* AS Агент,
//	|	ГруппаГостей.* AS ГруппаГостей,
//	|	Reservations.Ref.ПутевкаКурсовка.* AS ПутевкаКурсовка,
//	|	ReservationStatus.* AS ReservationStatus,
//	|	Reservations.Ref.КвотаНомеров.* AS КвотаНомеров,
//	|	Reservations.Ref.ТипКлиента.* AS ТипКлиента,
//	|	Reservations.Ref.МаретингНапрвл.* AS МаретингНапрвл,
//	|	Reservations.Ref.TripPurpose.* AS TripPurpose,
//	|	Reservations.Ref.ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
//	|	Reservations.Ref.RoomRateType.* AS RoomRateType,
//	|	Тариф.* AS Тариф,
//	|	Reservations.Ref.ДисконтКарт.* AS ДисконтКарт,
//	|	Reservations.Ref.ТипСкидки.* AS ТипСкидки,
//	|	Reservations.Фирма.* AS Фирма,
//	|	Reservations.Автор.* AS Автор,
//	|	Reservations.Ref.PlannedPaymentMethod.* AS PlannedPaymentMethod,
//	|	Reservations.Account.*,
//	|	Reservations.ВалютаСчета.*,
//	|	Reservations.Ref.СрокБрони AS СрокБрони,
//	|	Валюта.*,
//	|	(HOUR(Reservations.Ref.CheckInDate)) AS CheckInHour,
//	|	(BEGINOFPERIOD(Reservations.Ref.CheckInDate, DAY)) AS CheckInDay,
//	|	(WEEK(Reservations.Ref.CheckInDate)) AS CheckInWeek,
//	|	(MONTH(Reservations.Ref.CheckInDate)) AS CheckInMonth,
//	|	(QUARTER(Reservations.Ref.CheckInDate)) AS CheckInQuarter,
//	|	(YEAR(Reservations.Ref.CheckInDate)) AS CheckInYear,
//	|	(HOUR(Reservations.Ref.ДатаДок)) AS CreateHour,
//	|	CreateDate,
//	|	CreateWeek,
//	|	(MONTH(Reservations.Ref.ДатаДок)) AS CreateMonth,
//	|	(QUARTER(Reservations.Ref.ДатаДок)) AS CreateQuarter,
//	|	(YEAR(Reservations.Ref.ДатаДок)) AS CreateYear}";
//	ReportBuilder.Text = QueryText;
//	ReportBuilder.FillSettings();
//	
//	// Initialize report builder with default query
//	vRB = New ReportBuilder(QueryText);
//	vRBSettings = vRB.GetSettings(True, True, True, True, True);
//	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
//	
//	// Set default report builder header text
//	ReportBuilder.HeaderText = NStr("EN='Reservations history'; RU='История брони'");
//	
//	// Fill report builder fields presentations from the report template
//	cmFillReportAttributesPresentations(ThisObject);
//	
//	// Reset report builder template
//	ReportBuilder.Template = Неопределено;
//КонецПроцедуры //pmInitializeReportBuilder
//
////-----------------------------------------------------------------------------
//// Reports framework end
////-----------------------------------------------------------------------------
