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
//	ReportBuilder.Parameters.Вставить("qHotelIsFolder", ?(ЗначениеЗаполнено(Гостиница), Гостиница.IsFolder, False));
//	ReportBuilder.Parameters.Вставить("qPeriodFrom", PeriodFrom);
//	ReportBuilder.Parameters.Вставить("qPeriodTo", PeriodTo);
//	ReportBuilder.Parameters.Вставить("qRoom", ГруппаНомеров);
//	ReportBuilder.Parameters.Вставить("qRoomIsEmpty", НЕ ЗначениеЗаполнено(ГруппаНомеров));
//	ReportBuilder.Parameters.Вставить("qRoomType", RoomType);
//	ReportBuilder.Parameters.Вставить("qRoomTypeIsEmpty", НЕ ЗначениеЗаполнено(RoomType));
//	ReportBuilder.Parameters.Вставить("qEmptyCustomer", Справочники.Customers.EmptyRef());
//	ReportBuilder.Parameters.Вставить("qIndividualsCustomer", ?(ЗначениеЗаполнено(Гостиница), Гостиница.IndividualsCustomer, Справочники.Customers.EmptyRef()));
//	ReportBuilder.Parameters.Вставить("qIndividualsCustomerFolder", Справочники.Customers.КонтрагентПоУмолчанию);
//	ReportBuilder.Parameters.Вставить("qFolioDescription", FolioDescription);
//	ReportBuilder.Parameters.Вставить("qFolioDescriptionIsEmpty", IsBlankString(FolioDescription));
//	ReportBuilder.Parameters.Вставить("qPaymentSection", PaymentSection);
//	ReportBuilder.Parameters.Вставить("qPaymentSectionIsEmpty", НЕ ЗначениеЗаполнено(PaymentSection));
//	ReportBuilder.Parameters.Вставить("qFolioCurrency", FolioCurrency);
//	ReportBuilder.Parameters.Вставить("qFolioCurrencyIsEmpty", НЕ ЗначениеЗаполнено(FolioCurrency));
//	ReportBuilder.Parameters.Вставить("qEmptyDate", '00010101');
//	ReportBuilder.Parameters.Вставить("qEndOfTime", '39991231');
//	ReportBuilder.Parameters.Вставить("qShowCheckOutByReservations", ShowCheckOutByReservations);
//	ReportBuilder.Parameters.Вставить("qEmptyAccommodationStatus", Справочники.AccommodationStatuses.EmptyRef());
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
//	//// Apply appearance settings to the report spreadsheet
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
//	|	ЗагрузкаНомеров.Recorder.Гостиница AS Гостиница,
//	|	ЗагрузкаНомеров.НомерРазмещения AS НомерРазмещения,
//	|	ЗагрузкаНомеров.Recorder.Контрагент AS Контрагент,
//	|	ЗагрузкаНомеров.СтатусРазмещения AS СтатусРазмещения,
//	|	ЗагрузкаНомеров.Recorder.Клиент AS Клиент,
//	|	ЗагрузкаНомеров.Recorder.CheckInDate AS CheckInDate,
//	|	ЗагрузкаНомеров.Recorder.Продолжительность AS Продолжительность,
//	|	ЗагрузкаНомеров.Recorder.CheckOutDate AS CheckOutDate,
//	|	ЗагрузкаНомеров.ТипНомера AS ТипНомера,
//	|	ЗагрузкаНомеров.Recorder.ВидРазмещения AS ВидРазмещения,
//	|	ЗагрузкаНомеров.Recorder.Тариф AS Тариф,
//	|	ЗагрузкаНомеров.Recorder.Примечания AS Примечания,
//	|	ЗагрузкаНомеров.Recorder.ГруппаГостей AS ГруппаГостей,
//	|	ЗагрузкаНомеров.GuestsCheckedOut AS GuestsCheckedOut,
//	|	ЗагрузкаНомеров.RoomsCheckedOut AS RoomsCheckedOut,
//	|	ЗагрузкаНомеров.BedsCheckedOut AS BedsCheckedOut,
//	|	ЗагрузкаНомеров.AdditionalBedsCheckedOut AS AdditionalBedsCheckedOut,
//	|	ЗагрузкаНомеров.Recorder.PricePresentation AS PricePresentation,
//	|	ЗагрузкаНомеров.ВалютаЛицСчета AS ВалютаЛицСчета,
//	|	ЗагрузкаНомеров.ClientSumBalance AS ClientSumBalance
//	|{SELECT
//	|	Гостиница.* AS Гостиница,
//	|	НомерРазмещения.* AS НомерРазмещения,
//	|	ЗагрузкаНомеров.Recorder.ТипКонтрагента.* AS ТипКонтрагента,
//	|	Контрагент.* AS Контрагент,
//	|	ЗагрузкаНомеров.Recorder.Договор.* AS Договор,
//	|	ЗагрузкаНомеров.Recorder.КонтактноеЛицо AS КонтактноеЛицо,
//	|	ЗагрузкаНомеров.Recorder.Агент.* AS Агент,
//	|	ЗагрузкаНомеров.Recorder.ТипКлиента.* AS ТипКлиента,
//	|	Клиент.* AS Клиент,
//	|	CheckInDate AS CheckInDate,
//	|	Продолжительность AS Продолжительность,
//	|	CheckOutDate AS CheckOutDate,
//	|	ЗагрузкаНомеров.CheckInAccountingDate AS CheckInAccountingDate,
//	|	ЗагрузкаНомеров.CheckOutAccountingDate AS CheckOutAccountingDate,
//	|	(HOUR(ЗагрузкаНомеров.Recorder.CheckOutDate)) AS CheckOutHour,
//	|	(DAY(ЗагрузкаНомеров.Recorder.CheckOutDate)) AS CheckOutDay,
//	|	(WEEK(ЗагрузкаНомеров.Recorder.CheckOutDate)) AS CheckOutWeek,
//	|	(MONTH(ЗагрузкаНомеров.Recorder.CheckOutDate)) AS CheckOutMonth,
//	|	(QUARTER(ЗагрузкаНомеров.Recorder.CheckOutDate)) AS CheckOutQuarter,
//	|	(YEAR(ЗагрузкаНомеров.Recorder.CheckOutDate)) AS CheckOutYear,
//	|	ТипНомера.* AS ТипНомера,
//	|	ВидРазмещения.* AS ВидРазмещения,
//	|	ЗагрузкаНомеров.Recorder.RoomRateType.* AS RoomRateType,
//	|	Тариф.* AS Тариф,
//	|	PricePresentation AS PricePresentation,
//	|	ЗагрузкаНомеров.Recorder.PlannedPaymentMethod.* AS PlannedPaymentMethod,
//	|	Примечания AS Примечания,
//	|	ЗагрузкаНомеров.Recorder.Car AS Car,
//	|	ГруппаГостей.* AS ГруппаГостей,
//	|	СтатусРазмещения.* AS СтатусРазмещения,
//	|	ЗагрузкаНомеров.Recorder.IsMaster AS IsMaster,
//	|	ЗагрузкаНомеров.Recorder.ПутевкаКурсовка.* AS ПутевкаКурсовка,
//	|	ЗагрузкаНомеров.Recorder.КвотаНомеров.* AS КвотаНомеров,
//	|	ЗагрузкаНомеров.Recorder.МаретингНапрвл.* AS МаретингНапрвл,
//	|	ЗагрузкаНомеров.Recorder.TripPurpose.* AS TripPurpose,
//	|	ЗагрузкаНомеров.Recorder.ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
//	|	ЗагрузкаНомеров.Recorder.ДисконтКарт.* AS ДисконтКарт,
//	|	ЗагрузкаНомеров.Recorder.ТипСкидки.* AS ТипСкидки,
//	|	ЗагрузкаНомеров.Recorder.Скидка AS Скидка,
//	|	ЗагрузкаНомеров.Recorder.КомиссияАгента AS КомиссияАгента,
//	|	ЗагрузкаНомеров.Recorder.ВидКомиссииАгента.* AS ВидКомиссииАгента,
//	|	ЗагрузкаНомеров.Recorder.КоличествоМестНомер AS КоличествоМестНомер,
//	|	ЗагрузкаНомеров.Recorder.КоличествоГостейНомер AS КоличествоГостейНомер,
//	|	ЗагрузкаНомеров.Recorder.ДокОснование.* AS ДокОснование,
//	|	ЗагрузкаНомеров.Recorder.Reservation.* AS Reservation,
//	|	ЗагрузкаНомеров.Recorder.* AS Recorder,
//	|	ЗагрузкаНомеров.Recorder.CheckOutOperationTime AS CheckOutOperationTime,
//	|	(CASE
//	|			WHEN ЗагрузкаНомеров.Recorder.CheckOutOperationTime = &qEmptyDate
//	|				THEN 0
//	|			ELSE DATEDIFF(ЗагрузкаНомеров.Recorder.CheckOutDate, RoomInventory.Recorder.CheckOutOperationTime, HOUR)
//	|		END) AS CheckOutOperationDelayHours,
//	|	ЗагрузкаНомеров.Recorder.CheckOutOperationAuthor.* AS CheckOutOperationAuthor,
//	|	ЗагрузкаНомеров.Recorder.Автор.* AS Автор,
//	|	ЗагрузкаНомеров.Recorder.PointInTime AS PointInTime,
//	|	(CASE
//	|			WHEN NOT ЗагрузкаНомеров.Recorder.Reservation.CheckInDate IS NULL 
//	|					AND BEGINOFPERIOD(ЗагрузкаНомеров.Recorder.Reservation.CheckInDate, DAY) <> BEGINOFPERIOD(RoomInventory.Recorder.CheckInDate, DAY)
//	|				THEN TRUE
//	|			ELSE FALSE
//	|		END) AS AccommodationAndReservationCheckInDatesAreNotTheSame,
//	|	(CASE
//	|			WHEN NOT ЗагрузкаНомеров.Recorder.Reservation.CheckOutDate IS NULL 
//	|					AND BEGINOFPERIOD(ЗагрузкаНомеров.Recorder.Reservation.CheckOutDate, DAY) <> BEGINOFPERIOD(RoomInventory.Recorder.CheckOutDate, DAY)
//	|				THEN TRUE
//	|			ELSE FALSE
//	|		END) AS AccommodationAndReservationCheckOutDatesAreNotTheSame,
//	|	ForeignerRegistryRecords.ForeignerRegistryRecord.* AS ForeignerRegistryRecord,
//	|	GuestsCheckedOut AS GuestsCheckedOut,
//	|	RoomsCheckedOut AS RoomsCheckedOut,
//	|	BedsCheckedOut AS BedsCheckedOut,
//	|	AdditionalBedsCheckedOut AS AdditionalBedsCheckedOut,
//	|	ClientSumBalance AS ClientSumBalance,
//	|	ВалютаЛицСчета.* AS FolioCurrency}
//	|FROM
//	|	(SELECT
//	|		RoomInventoryTurnovers.Recorder AS Recorder,
//	|		RoomInventoryTurnovers.НомерРазмещения AS НомерРазмещения,
//	|		RoomInventoryTurnovers.ТипНомера AS ТипНомера,
//	|		CASE
//	|			WHEN RoomInventoryTurnovers.Recorder.СтатусРазмещения IS NULL 
//	|				THEN RoomInventoryTurnovers.Recorder.ReservationStatus
//	|			ELSE RoomInventoryTurnovers.Recorder.СтатусРазмещения
//	|		END AS СтатусРазмещения,
//	|		ClientBalances.ВалютаЛицСчета AS ВалютаЛицСчета,
//	|		RoomInventoryTurnovers.CheckInAccountingDate AS CheckInAccountingDate,
//	|		RoomInventoryTurnovers.CheckOutAccountingDate AS CheckOutAccountingDate,
//	|		RoomInventoryTurnovers.GuestsCheckedOut AS GuestsCheckedOut,
//	|		RoomInventoryTurnovers.RoomsCheckedOut AS RoomsCheckedOut,
//	|		RoomInventoryTurnovers.BedsCheckedOut AS BedsCheckedOut,
//	|		RoomInventoryTurnovers.AdditionalBedsCheckedOut AS AdditionalBedsCheckedOut,
//	|		ISNULL(ClientBalances.ClientSumBalance, 0) AS ClientSumBalance
//	|	FROM
//	|		(SELECT
//	|			RoomInventoryMovements.Recorder AS Recorder,
//	|			RoomInventoryMovements.НомерРазмещения AS НомерРазмещения,
//	|			RoomInventoryMovements.ТипНомера AS ТипНомера,
//	|			MIN(RoomInventoryMovements.CheckInAccountingDate) AS CheckInAccountingDate,
//	|			MAX(RoomInventoryMovements.CheckOutAccountingDate) AS CheckOutAccountingDate,
//	|			SUM(CASE
//	|					WHEN RoomInventoryMovements.СтатусРазмещения = &qEmptyAccommodationStatus
//	|						THEN RoomInventoryMovements.ЗабронГостей
//	|					ELSE RoomInventoryMovements.GuestsCheckedOut
//	|				END) AS GuestsCheckedOut,
//	|			SUM(CASE
//	|					WHEN RoomInventoryMovements.СтатусРазмещения = &qEmptyAccommodationStatus
//	|						THEN RoomInventoryMovements.ЗабронНомеров
//	|					ELSE RoomInventoryMovements.RoomsCheckedOut
//	|				END) AS RoomsCheckedOut,
//	|			SUM(CASE
//	|					WHEN RoomInventoryMovements.СтатусРазмещения = &qEmptyAccommodationStatus
//	|						THEN RoomInventoryMovements.ЗабронированоМест
//	|					ELSE RoomInventoryMovements.BedsCheckedOut
//	|				END) AS BedsCheckedOut,
//	|			SUM(CASE
//	|					WHEN RoomInventoryMovements.СтатусРазмещения = &qEmptyAccommodationStatus
//	|						THEN RoomInventoryMovements.ЗабронДопМест
//	|					ELSE RoomInventoryMovements.AdditionalBedsCheckedOut
//	|				END) AS AdditionalBedsCheckedOut
//	|		FROM
//	|			AccumulationRegister.ЗагрузкаНомеров AS RoomInventoryMovements
//	|		WHERE
//	|			RoomInventoryMovements.RecordType = VALUE(AccumulationRecordType.Receipt)
//	|			AND (NOT &qShowCheckOutByReservations
//	|						AND RoomInventoryMovements.IsAccommodation
//	|					OR &qShowCheckOutByReservations
//	|						AND (RoomInventoryMovements.IsAccommodation
//	|							OR RoomInventoryMovements.IsReservation))
//	|			AND (&qHotelIsEmpty
//	|					OR &qHotelIsFolder
//	|						AND RoomInventoryMovements.Гостиница IN HIERARCHY (&qHotel)
//	|					OR NOT &qHotelIsFolder
//	|						AND RoomInventoryMovements.Гостиница = &qHotel)
//	|			AND (&qRoomIsEmpty
//	|					OR RoomInventoryMovements.НомерРазмещения IN HIERARCHY (&qRoom))
//	|			AND (&qRoomTypeIsEmpty
//	|					OR RoomInventoryMovements.ТипНомера IN HIERARCHY (&qRoomType))
//	|			AND RoomInventoryMovements.ПериодПо > &qPeriodFrom
//	|			AND RoomInventoryMovements.ПериодПо <= &qPeriodTo
//	|			AND RoomInventoryMovements.CheckOutDate = RoomInventoryMovements.ПериодПо
//	|			AND (RoomInventoryMovements.ЭтоВыезд
//	|						AND RoomInventoryMovements.IsAccommodation
//	|					OR RoomInventoryMovements.IsReservation)
//	|		
//	|		GROUP BY
//	|			RoomInventoryMovements.Recorder,
//	|			RoomInventoryMovements.НомерРазмещения,
//	|			RoomInventoryMovements.ТипНомера) AS RoomInventoryTurnovers
//	|			LEFT JOIN (SELECT
//	|				AccountsBalance.ВалютаЛицСчета AS ВалютаЛицСчета,
//	|				AccountsBalance.СчетПроживания.ДокОснование AS FolioParentDoc,
//	|				SUM(AccountsBalance.SumBalance) AS ClientSumBalance
//	|			FROM
//	|				AccumulationRegister.Взаиморасчеты.Balance(
//	|						&qPeriodTo,
//	|						(СчетПроживания.Контрагент = &qEmptyCustomer
//	|							OR СчетПроживания.Контрагент = &qIndividualsCustomer
//	|							OR СчетПроживания.Контрагент <> &qEmptyCustomer
//	|								AND СчетПроживания.Контрагент IN HIERARCHY (&qIndividualsCustomerFolder))
//	|							AND (ВалютаЛицСчета = &qFolioCurrency
//	|								OR &qFolioCurrencyIsEmpty)
//	|							AND (СчетПроживания.PaymentSection = &qPaymentSection
//	|								OR &qPaymentSectionIsEmpty)
//	|							AND (СчетПроживания.Description = &qFolioDescription
//	|								OR &qFolioDescriptionIsEmpty)) AS AccountsBalance
//	|			
//	|			GROUP BY
//	|				AccountsBalance.ВалютаЛицСчета,
//	|				AccountsBalance.СчетПроживания.ДокОснование) AS ClientBalances
//	|			ON RoomInventoryTurnovers.Recorder = ClientBalances.FolioParentDoc) AS ЗагрузкаНомеров
//	|		LEFT JOIN InformationRegister.AccommodationForeignerRegistryRecords.SliceLast(&qEndOfTime, ) AS ForeignerRegistryRecords
//	|		ON ЗагрузкаНомеров.Recorder = ForeignerRegistryRecords.Размещение
//	|{WHERE
//	|	ЗагрузкаНомеров.Recorder.* AS Recorder,
//	|	ЗагрузкаНомеров.Recorder.Гостиница.* AS Гостиница,
//	|	ЗагрузкаНомеров.ТипНомера.* AS ТипНомера,
//	|	ЗагрузкаНомеров.НомерРазмещения.* AS НомерРазмещения,
//	|	ЗагрузкаНомеров.Recorder.Контрагент.* AS Контрагент,
//	|	ЗагрузкаНомеров.Recorder.ТипКонтрагента.* AS ТипКонтрагента,
//	|	ЗагрузкаНомеров.Recorder.Договор.* AS Договор,
//	|	ЗагрузкаНомеров.Recorder.КонтактноеЛицо AS КонтактноеЛицо,
//	|	ЗагрузкаНомеров.Recorder.Агент.* AS Агент,
//	|	ЗагрузкаНомеров.Recorder.ГруппаГостей.* AS ГруппаГостей,
//	|	ЗагрузкаНомеров.Recorder.ДокОснование.* AS ДокОснование,
//	|	ЗагрузкаНомеров.Recorder.Reservation.* AS Reservation,
//	|	ЗагрузкаНомеров.Recorder.ПутевкаКурсовка.* AS ПутевкаКурсовка,
//	|	ЗагрузкаНомеров.СтатусРазмещения.* AS СтатусРазмещения,
//	|	ЗагрузкаНомеров.Recorder.CheckInDate AS CheckInDate,
//	|	ЗагрузкаНомеров.Recorder.Продолжительность AS Продолжительность,
//	|	ЗагрузкаНомеров.Recorder.CheckOutDate AS CheckOutDate,
//	|	ЗагрузкаНомеров.CheckInAccountingDate AS CheckInAccountingDate,
//	|	ЗагрузкаНомеров.CheckOutAccountingDate AS CheckOutAccountingDate,
//	|	(HOUR(ЗагрузкаНомеров.Recorder.CheckOutDate)) AS CheckOutHour,
//	|	ЗагрузкаНомеров.Recorder.КвотаНомеров.* AS КвотаНомеров,
//	|	ЗагрузкаНомеров.Recorder.ТипКлиента.* AS ТипКлиента,
//	|	ЗагрузкаНомеров.Recorder.Клиент.* AS Клиент,
//	|	ЗагрузкаНомеров.Recorder.МаретингНапрвл.* AS МаретингНапрвл,
//	|	ЗагрузкаНомеров.Recorder.TripPurpose.* AS TripPurpose,
//	|	ЗагрузкаНомеров.Recorder.ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
//	|	ЗагрузкаНомеров.Recorder.RoomRateType.* AS RoomRateType,
//	|	ЗагрузкаНомеров.Recorder.Тариф.* AS Тариф,
//	|	ЗагрузкаНомеров.Recorder.PricePresentation AS PricePresentation,
//	|	ЗагрузкаНомеров.Recorder.ДисконтКарт.* AS ДисконтКарт,
//	|	ЗагрузкаНомеров.Recorder.ТипСкидки.* AS ТипСкидки,
//	|	ЗагрузкаНомеров.Recorder.Скидка AS Скидка,
//	|	ЗагрузкаНомеров.Recorder.PlannedPaymentMethod.* AS PlannedPaymentMethod,
//	|	ЗагрузкаНомеров.Recorder.Car AS Car,
//	|	ЗагрузкаНомеров.Recorder.Примечания AS Примечания,
//	|	ЗагрузкаНомеров.Recorder.CheckOutOperationTime AS CheckOutOperationTime,
//	|	(CASE
//	|			WHEN ЗагрузкаНомеров.Recorder.CheckOutOperationTime = &qEmptyDate
//	|				THEN 0
//	|			ELSE DATEDIFF(ЗагрузкаНомеров.Recorder.CheckOutDate, RoomInventory.Recorder.CheckOutOperationTime, HOUR)
//	|		END) AS CheckOutOperationDelayHours,
//	|	ЗагрузкаНомеров.Recorder.CheckOutOperationAuthor.* AS CheckOutOperationAuthor,
//	|	ЗагрузкаНомеров.Recorder.Автор.* AS Автор,
//	|	ЗагрузкаНомеров.Recorder.КомиссияАгента AS КомиссияАгента,
//	|	ЗагрузкаНомеров.Recorder.ВидКомиссииАгента AS ВидКомиссииАгента,
//	|	ЗагрузкаНомеров.Recorder.IsMaster AS IsMaster,
//	|	(CASE
//	|			WHEN NOT ЗагрузкаНомеров.Recorder.Reservation.CheckInDate IS NULL 
//	|					AND BEGINOFPERIOD(ЗагрузкаНомеров.Recorder.Reservation.CheckInDate, DAY) <> BEGINOFPERIOD(RoomInventory.Recorder.CheckInDate, DAY)
//	|				THEN TRUE
//	|			ELSE FALSE
//	|		END) AS AccommodationAndReservationCheckInDatesAreNotTheSame,
//	|	(CASE
//	|			WHEN NOT ЗагрузкаНомеров.Recorder.Reservation.CheckOutDate IS NULL 
//	|					AND BEGINOFPERIOD(ЗагрузкаНомеров.Recorder.Reservation.CheckOutDate, DAY) <> BEGINOFPERIOD(RoomInventory.Recorder.CheckOutDate, DAY)
//	|				THEN TRUE
//	|			ELSE FALSE
//	|		END) AS AccommodationAndReservationCheckOutDatesAreNotTheSame,
//	|	ForeignerRegistryRecords.ForeignerRegistryRecord.* AS ForeignerRegistryRecord,
//	|	ЗагрузкаНомеров.RoomsCheckedOut AS RoomsCheckedOut,
//	|	ЗагрузкаНомеров.BedsCheckedOut AS BedsCheckedOut,
//	|	ЗагрузкаНомеров.AdditionalBedsCheckedOut AS AdditionalBedsCheckedOut,
//	|	ЗагрузкаНомеров.GuestsCheckedOut AS GuestsCheckedOut,
//	|	ЗагрузкаНомеров.ВалютаЛицСчета.* AS ВалютаЛицСчета,
//	|	ЗагрузкаНомеров.ClientSumBalance AS ClientSumBalance}
//	|
//	|ORDER BY
//	|	Гостиница,
//	|	НомерРазмещения,
//	|	CheckOutDate,
//	|	Клиент
//	|{ORDER BY
//	|	Контрагент.* AS Контрагент,
//	|	ЗагрузкаНомеров.Recorder.ТипКонтрагента.* AS ТипКонтрагента,
//	|	ЗагрузкаНомеров.Recorder.Договор.* AS Договор,
//	|	ЗагрузкаНомеров.Recorder.Агент.* AS Агент,
//	|	ГруппаГостей.* AS ГруппаГостей,
//	|	Клиент.* AS Клиент,
//	|	ЗагрузкаНомеров.Recorder.ПутевкаКурсовка.* AS ПутевкаКурсовка,
//	|	СтатусРазмещения.* AS СтатусРазмещения,
//	|	ВидРазмещения.* AS ВидРазмещения,
//	|	ЗагрузкаНомеров.Recorder.КвотаНомеров.* AS КвотаНомеров,
//	|	ЗагрузкаНомеров.Recorder.ТипКлиента.* AS ТипКлиента,
//	|	ЗагрузкаНомеров.Recorder.МаретингНапрвл.* AS МаретингНапрвл,
//	|	ЗагрузкаНомеров.Recorder.TripPurpose.* AS TripPurpose,
//	|	ЗагрузкаНомеров.Recorder.ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
//	|	ЗагрузкаНомеров.Recorder.RoomRateType.* AS RoomRateType,
//	|	Тариф.* AS Тариф,
//	|	PricePresentation AS PricePresentation,
//	|	ЗагрузкаНомеров.Recorder.ДисконтКарт.* AS ДисконтКарт,
//	|	ЗагрузкаНомеров.Recorder.ТипСкидки.* AS ТипСкидки,
//	|	ЗагрузкаНомеров.Recorder.PlannedPaymentMethod.* AS PlannedPaymentMethod,
//	|	НомерРазмещения.* AS НомерРазмещения,
//	|	ТипНомера.* AS ТипНомера,
//	|	Гостиница.* AS Гостиница,
//	|	ЗагрузкаНомеров.Recorder.PointInTime AS PointInTime,
//	|	CheckInDate AS CheckInDate,
//	|	Продолжительность AS Продолжительность,
//	|	CheckOutDate AS CheckOutDate,
//	|	ЗагрузкаНомеров.CheckInAccountingDate AS CheckInAccountingDate,
//	|	ЗагрузкаНомеров.CheckOutAccountingDate AS CheckOutAccountingDate,
//	|	(HOUR(ЗагрузкаНомеров.Recorder.CheckOutDate)) AS CheckOutHour,
//	|	(DAY(ЗагрузкаНомеров.Recorder.CheckOutDate)) AS CheckOutDay,
//	|	(WEEK(ЗагрузкаНомеров.Recorder.CheckOutDate)) AS CheckOutWeek,
//	|	(MONTH(ЗагрузкаНомеров.Recorder.CheckOutDate)) AS CheckOutMonth,
//	|	(QUARTER(ЗагрузкаНомеров.Recorder.CheckOutDate)) AS CheckOutQuarter,
//	|	(YEAR(ЗагрузкаНомеров.Recorder.CheckOutDate)) AS CheckOutYear,
//	|	ЗагрузкаНомеров.Recorder.КвотаНомеров.* AS КвотаНомеров,
//	|	ЗагрузкаНомеров.Recorder.CheckOutOperationTime AS CheckOutOperationTime,
//	|	(CASE
//	|			WHEN ЗагрузкаНомеров.Recorder.CheckOutOperationTime = &qEmptyDate
//	|				THEN 0
//	|			ELSE DATEDIFF(ЗагрузкаНомеров.Recorder.CheckOutDate, RoomInventory.Recorder.CheckOutOperationTime, HOUR)
//	|		END) AS CheckOutOperationDelayHours,
//	|	ЗагрузкаНомеров.Recorder.CheckOutOperationAuthor.* AS CheckOutOperationAuthor,
//	|	ЗагрузкаНомеров.Recorder.Автор.* AS Автор,
//	|	ForeignerRegistryRecords.ForeignerRegistryRecord.* AS ForeignerRegistryRecord,
//	|	RoomsCheckedOut AS RoomsCheckedOut,
//	|	BedsCheckedOut AS BedsCheckedOut,
//	|	AdditionalBedsCheckedOut AS AdditionalBedsCheckedOut,
//	|	GuestsCheckedOut AS GuestsCheckedOut,
//	|	ВалютаЛицСчета.* AS ВалютаЛицСчета,
//	|	ClientSumBalance AS ClientSumBalance}
//	|TOTALS
//	|	SUM(GuestsCheckedOut),
//	|	SUM(RoomsCheckedOut),
//	|	SUM(BedsCheckedOut),
//	|	SUM(AdditionalBedsCheckedOut)
//	|BY
//	|	OVERALL,
//	|	Гостиница,
//	|	НомерРазмещения
//	|{TOTALS BY
//	|	Гостиница.* AS Гостиница,
//	|	ЗагрузкаНомеров.CheckInAccountingDate AS CheckInAccountingDate,
//	|	ЗагрузкаНомеров.CheckOutAccountingDate AS CheckOutAccountingDate,
//	|	(HOUR(ЗагрузкаНомеров.Recorder.CheckOutDate)) AS CheckOutHour,
//	|	(DAY(ЗагрузкаНомеров.Recorder.CheckOutDate)) AS CheckOutDay,
//	|	(WEEK(ЗагрузкаНомеров.Recorder.CheckOutDate)) AS CheckOutWeek,
//	|	(MONTH(ЗагрузкаНомеров.Recorder.CheckOutDate)) AS CheckOutMonth,
//	|	(QUARTER(ЗагрузкаНомеров.Recorder.CheckOutDate)) AS CheckOutQuarter,
//	|	(YEAR(ЗагрузкаНомеров.Recorder.CheckOutDate)) AS CheckOutYear,
//	|	ТипНомера.* AS ТипНомера,
//	|	НомерРазмещения.* AS НомерРазмещения,
//	|	Контрагент.* AS Контрагент,
//	|	Клиент.* AS Клиент,
//	|	ЗагрузкаНомеров.Recorder.ТипКонтрагента.* AS ТипКонтрагента,
//	|	ЗагрузкаНомеров.Recorder.Договор.* AS Договор,
//	|	ЗагрузкаНомеров.Recorder.КонтактноеЛицо AS КонтактноеЛицо,
//	|	ЗагрузкаНомеров.Recorder.Агент.* AS Агент,
//	|	ГруппаГостей.* AS ГруппаГостей,
//	|	ЗагрузкаНомеров.Recorder.ПутевкаКурсовка.* AS ПутевкаКурсовка,
//	|	СтатусРазмещения.* AS СтатусРазмещения,
//	|	ВидРазмещения.* AS ВидРазмещения,
//	|	ЗагрузкаНомеров.Recorder.КвотаНомеров.* AS КвотаНомеров,
//	|	ЗагрузкаНомеров.Recorder.ТипКлиента.* AS ТипКлиента,
//	|	ЗагрузкаНомеров.Recorder.МаретингНапрвл.* AS МаретингНапрвл,
//	|	ЗагрузкаНомеров.Recorder.TripPurpose.* AS TripPurpose,
//	|	ЗагрузкаНомеров.Recorder.ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
//	|	Тариф.* AS Тариф,
//	|	ЗагрузкаНомеров.Recorder.RoomRateType.* AS RoomRateType,
//	|	(CASE
//	|			WHEN ЗагрузкаНомеров.Recorder.CheckOutOperationTime = &qEmptyDate
//	|				THEN 0
//	|			ELSE DATEDIFF(ЗагрузкаНомеров.Recorder.CheckOutDate, RoomInventory.Recorder.CheckOutOperationTime, HOUR)
//	|		END) AS CheckOutOperationDelayHours,
//	|	ЗагрузкаНомеров.Recorder.CheckOutOperationAuthor.* AS CheckOutOperationAuthor,
//	|	ЗагрузкаНомеров.Recorder.Автор.* AS Автор,
//	|	ForeignerRegistryRecords.ForeignerRegistryRecord.* AS ForeignerRegistryRecord,
//	|	PricePresentation AS PricePresentation,
//	|	ВалютаЛицСчета.* AS ВалютаЛицСчета,
//	|	ЗагрузкаНомеров.Recorder.ДисконтКарт AS ДисконтКарт,
//	|	ЗагрузкаНомеров.Recorder.ТипСкидки AS ТипСкидки,
//	|	ЗагрузкаНомеров.Recorder.* AS Recorder,
//	|	ЗагрузкаНомеров.Recorder.PlannedPaymentMethod.* AS PlannedPaymentMethod}";
//	ReportBuilder.Text = QueryText;
//	ReportBuilder.FillSettings();
//	
//	// Initialize report builder with default query
//	vRB = New ReportBuilder(QueryText);
//	vRBSettings = vRB.GetSettings(True, True, True, True, True);
//	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
//	
//	// Set default report builder header text
//	ReportBuilder.HeaderText = NStr("EN='Guests checked-out';RU='Фактический выезд';de='Faktische Abreise'");
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
