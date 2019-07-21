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
//		                     Format(PeriodFrom, "DF=dd.MM.yyyy") + 
//		                     ";" + Chars.LF;
//	ElsIf ЗначениеЗаполнено(PeriodFrom) And НЕ ЗначениеЗаполнено(PeriodTo) Тогда
//		vParamPresentation = vParamPresentation + NStr("ru = 'Период по '; en = 'Period to '") + 
//		                     Format(PeriodTo, "DF=dd.MM.yyyy") + 
//		                     ";" + Chars.LF;
//	ElsIf BegOfDay(PeriodFrom) = BegOfDay(PeriodTo) Тогда
//		vParamPresentation = vParamPresentation + NStr("ru = 'Период на '; en = 'Period on '") + 
//		                     Format(PeriodFrom, "DF=dd.MM.yyyy") + 
//		                     ";" + Chars.LF;
//	ElsIf PeriodFrom < PeriodTo Тогда
//		vParamPresentation = vParamPresentation + NStr("ru = 'Период с '; en = 'Period from '") + 
//		                     Format(PeriodFrom, "DF=dd.MM.yyyy") + NStr("en=' to ';ru=' по ';de='bis'") + 
//							 Format(PeriodTo, "DF=dd.MM.yyyy") + 
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
//	ReportBuilder.Parameters.Вставить("qPeriodFrom", BegOfDay(PeriodFrom));
//	ReportBuilder.Parameters.Вставить("qPeriodTo", EndOfDay(PeriodTo));
//	ReportBuilder.Parameters.Вставить("qRoom", ГруппаНомеров);
//	ReportBuilder.Parameters.Вставить("qRoomType", RoomType);
//	ReportBuilder.Parameters.Вставить("qEndOfTime", '39991231');
//	ReportBuilder.Parameters.Вставить("qEmptyDate", '00010101');
//	ReportBuilder.Parameters.Вставить("qEmptyRoom", Справочники.НомернойФонд.EmptyRef());
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
//	|	ЗагрузкаНомеров.Recorder.Гостиница AS Гостиница,
//	|	ЗагрузкаНомеров.НомерРазмещения AS НомерРазмещения,
//	|	ЗагрузкаНомеров.Recorder.Контрагент AS Контрагент,
//	|	ЗагрузкаНомеров.Recorder.ГруппаГостей AS ГруппаГостей,
//	|	CASE
//	|		WHEN ЗагрузкаНомеров.Recorder.СтатусРазмещения IS NULL 
//	|			THEN ЗагрузкаНомеров.Recorder.ReservationStatus
//	|		ELSE ЗагрузкаНомеров.Recorder.СтатусРазмещения
//	|	END AS Status,
//	|	ЗагрузкаНомеров.Recorder.Клиент AS Клиент,
//	|	ЗагрузкаНомеров.Recorder.Клиент.ДатаРождения AS GuestDateOfBirth,
//	|	ЗагрузкаНомеров.Recorder.CheckInDate AS CheckInDate,
//	|	ЗагрузкаНомеров.Recorder.Продолжительность AS Продолжительность,
//	|	ЗагрузкаНомеров.Recorder.CheckOutDate AS CheckOutDate,
//	|	ЗагрузкаНомеров.ТипНомера AS ТипНомера,
//	|	ЗагрузкаНомеров.Recorder.ВидРазмещения AS ВидРазмещения,
//	|	ЗагрузкаНомеров.Recorder.Тариф AS Тариф,
//	|	ЗагрузкаНомеров.Recorder.PricePresentation AS PricePresentation,
//	|	ЗагрузкаНомеров.Recorder.Примечания AS Примечания,
//	|	1 AS NumberOfGuests
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
//	|	GuestDateOfBirth AS GuestDateOfBirth,
//	|	CheckInDate AS CheckInDate,
//	|	Продолжительность AS Продолжительность,
//	|	CheckOutDate AS CheckOutDate,
//	|	ЗагрузкаНомеров.CheckInAccountingDate AS CheckInAccountingDate,
//	|	ЗагрузкаНомеров.CheckOutAccountingDate AS CheckOutAccountingDate,
//	|	(HOUR(ЗагрузкаНомеров.Recorder.CheckInDate)) AS CheckInHour,
//	|	(DAY(ЗагрузкаНомеров.Recorder.CheckInDate)) AS CheckInDay,
//	|	(WEEK(ЗагрузкаНомеров.Recorder.CheckInDate)) AS CheckInWeek,
//	|	(MONTH(ЗагрузкаНомеров.Recorder.CheckInDate)) AS CheckInMonth,
//	|	(QUARTER(ЗагрузкаНомеров.Recorder.CheckInDate)) AS CheckInQuarter,
//	|	(YEAR(ЗагрузкаНомеров.Recorder.CheckInDate)) AS CheckInYear,
//	|	ТипНомера.* AS ТипНомера,
//	|	ВидРазмещения.* AS ВидРазмещения,
//	|	ЗагрузкаНомеров.Recorder.RoomRateType.* AS RoomRateType,
//	|	Тариф.* AS Тариф,
//	|	PricePresentation AS PricePresentation,
//	|	ЗагрузкаНомеров.Recorder.PlannedPaymentMethod.* AS PlannedPaymentMethod,
//	|	Примечания AS Примечания,
//	|	ЗагрузкаНомеров.Recorder.Car AS Car,
//	|	ГруппаГостей.* AS ГруппаГостей,
//	|	Status.* AS Status,
//	|	ЗагрузкаНомеров.Recorder.IsMaster AS IsMaster,
//	|	ЗагрузкаНомеров.Recorder.ПутевкаКурсовка.* AS ПутевкаКурсовка,
//	|	ЗагрузкаНомеров.Recorder.КвотаНомеров.* AS КвотаНомеров,
//	|	ЗагрузкаНомеров.Recorder.МаретингНапрвл.* AS МаретингНапрвл,
//	|	ЗагрузкаНомеров.Recorder.TripPurpose.* AS TripPurpose,
//	|	ЗагрузкаНомеров.Recorder.ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
//	|	ЗагрузкаНомеров.Recorder.Автор.* AS Автор,
//	|	ЗагрузкаНомеров.Recorder.ДисконтКарт.* AS ДисконтКарт,
//	|	ЗагрузкаНомеров.Recorder.ТипСкидки.* AS ТипСкидки,
//	|	ЗагрузкаНомеров.Recorder.Скидка AS Скидка,
//	|	ЗагрузкаНомеров.Recorder.КомиссияАгента AS КомиссияАгента,
//	|	ЗагрузкаНомеров.Recorder.ВидКомиссииАгента.* AS ВидКомиссииАгента,
//	|	ЗагрузкаНомеров.Recorder.КоличествоМестНомер AS КоличествоМестНомер,
//	|	ЗагрузкаНомеров.Recorder.КоличествоГостейНомер AS КоличествоГостейНомер,
//	|	ЗагрузкаНомеров.Recorder.ДокОснование.* AS ДокОснование,
//	|	ЗагрузкаНомеров.Recorder.* AS Recorder,
//	|	ЗагрузкаНомеров.Recorder.PointInTime AS PointInTime,
//	|	ForeignerRegistryRecords.ForeignerRegistryRecord.* AS ForeignerRegistryRecord,
//	|	NumberOfGuests AS NumberOfGuests}
//	|FROM
//	|	(SELECT
//	|		RoomInventoryMovements.Recorder AS Recorder,
//	|		RoomInventoryMovements.Recorder.НомерРазмещения AS НомерРазмещения,
//	|		RoomInventoryMovements.Recorder.ТипНомера AS ТипНомера,
//	|		MIN(RoomInventoryMovements.CheckInAccountingDate) AS CheckInAccountingDate,
//	|		MAX(RoomInventoryMovements.CheckOutAccountingDate) AS CheckOutAccountingDate
//	|	FROM
//	|		AccumulationRegister.ЗагрузкаНомеров AS RoomInventoryMovements
//	|	WHERE
//	|		RoomInventoryMovements.RecordType = VALUE(AccumulationRecordType.Expense)
//	|		AND (RoomInventoryMovements.IsAccommodation
//	|				OR RoomInventoryMovements.IsReservation)
//	|		AND RoomInventoryMovements.Гостиница IN HIERARCHY(&qHotel)
//	|		AND (RoomInventoryMovements.НомерРазмещения IN HIERARCHY (&qRoom)
//	|				OR RoomInventoryMovements.НомерРазмещения = &qEmptyRoom
//	|					AND &qRoom = &qEmptyRoom)
//	|		AND RoomInventoryMovements.ТипНомера IN HIERARCHY(&qRoomType)
//	|		AND RoomInventoryMovements.CheckInDate < &qPeriodTo
//	|		AND RoomInventoryMovements.CheckOutDate > &qPeriodFrom
//	|		AND RoomInventoryMovements.CheckInDate = RoomInventoryMovements.ПериодС
//	|		AND RoomInventoryMovements.Клиент.ДатаРождения > &qEmptyDate
//	|		AND (YEAR(&qPeriodTo) = YEAR(&qPeriodFrom)
//	|					AND MONTH(RoomInventoryMovements.Клиент.ДатаРождения) * 100 + DAY(RoomInventoryMovements.Клиент.ДатаРождения) >= MONTH(&qPeriodFrom) * 100 + DAY(&qPeriodFrom)
//	|					AND MONTH(RoomInventoryMovements.Клиент.ДатаРождения) * 100 + DAY(RoomInventoryMovements.Клиент.ДатаРождения) <= MONTH(&qPeriodTo) * 100 + DAY(&qPeriodTo)
//	|				OR YEAR(&qPeriodTo) <> YEAR(&qPeriodFrom)
//	|					AND (MONTH(RoomInventoryMovements.Клиент.ДатаРождения) * 100 + DAY(RoomInventoryMovements.Клиент.ДатаРождения) >= MONTH(&qPeriodFrom) * 100 + DAY(&qPeriodFrom)
//	|							AND MONTH(RoomInventoryMovements.Клиент.ДатаРождения) * 100 + DAY(RoomInventoryMovements.Клиент.ДатаРождения) <= 1231
//	|						OR MONTH(RoomInventoryMovements.Клиент.ДатаРождения) * 100 + DAY(RoomInventoryMovements.Клиент.ДатаРождения) <= MONTH(&qPeriodTo) * 100 + DAY(&qPeriodTo)
//	|							AND MONTH(RoomInventoryMovements.Клиент.ДатаРождения) * 100 + DAY(RoomInventoryMovements.Клиент.ДатаРождения) >= 101))
//	|	
//	|	GROUP BY
//	|		RoomInventoryMovements.Recorder,
//	|		RoomInventoryMovements.Recorder.НомерРазмещения,
//	|		RoomInventoryMovements.Recorder.ТипНомера) AS ЗагрузкаНомеров
//	|		LEFT JOIN InformationRegister.AccommodationForeignerRegistryRecords.SliceLast(&qEndOfTime, ) AS ForeignerRegistryRecords
//	|		ON ЗагрузкаНомеров.Recorder = ForeignerRegistryRecords.Размещение
//	|{WHERE
//	|	ЗагрузкаНомеров.Recorder.* AS Recorder,
//	|	ЗагрузкаНомеров.Recorder.Гостиница.* AS Гостиница,
//	|	ЗагрузкаНомеров.НомерРазмещения.* AS НомерРазмещения,
//	|	ЗагрузкаНомеров.Recorder.Контрагент.* AS Контрагент,
//	|	ЗагрузкаНомеров.Recorder.ТипКонтрагента.* AS ТипКонтрагента,
//	|	ЗагрузкаНомеров.Recorder.Договор.* AS Договор,
//	|	ЗагрузкаНомеров.Recorder.КонтактноеЛицо AS КонтактноеЛицо,
//	|	ЗагрузкаНомеров.Recorder.Агент.* AS Агент,
//	|	ЗагрузкаНомеров.Recorder.ГруппаГостей.* AS ГруппаГостей,
//	|	ЗагрузкаНомеров.Recorder.ДокОснование.* AS ДокОснование,
//	|	ЗагрузкаНомеров.Recorder.ПутевкаКурсовка.* AS ПутевкаКурсовка,
//	|	(CASE
//	|			WHEN ЗагрузкаНомеров.Recorder.СтатусРазмещения IS NULL 
//	|				THEN ЗагрузкаНомеров.Recorder.ReservationStatus
//	|			ELSE ЗагрузкаНомеров.Recorder.СтатусРазмещения
//	|		END).* AS Status,
//	|	ЗагрузкаНомеров.Recorder.CheckInDate AS CheckInDate,
//	|	ЗагрузкаНомеров.Recorder.Продолжительность AS Продолжительность,
//	|	ЗагрузкаНомеров.Recorder.CheckOutDate AS CheckOutDate,
//	|	ЗагрузкаНомеров.CheckInAccountingDate AS CheckInAccountingDate,
//	|	ЗагрузкаНомеров.CheckOutAccountingDate AS CheckOutAccountingDate,
//	|	(HOUR(ЗагрузкаНомеров.Recorder.CheckInDate)) AS CheckInHour,
//	|	ЗагрузкаНомеров.Recorder.КвотаНомеров.* AS КвотаНомеров,
//	|	ЗагрузкаНомеров.Recorder.ТипКлиента.* AS ТипКлиента,
//	|	ЗагрузкаНомеров.Recorder.Клиент.* AS Клиент,
//	|	ЗагрузкаНомеров.Recorder.Клиент.ДатаРождения AS GuestDateOfBirth,
//	|	ЗагрузкаНомеров.Recorder.МаретингНапрвл.* AS МаретингНапрвл,
//	|	ЗагрузкаНомеров.Recorder.TripPurpose.* AS TripPurpose,
//	|	ЗагрузкаНомеров.Recorder.ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
//	|	ЗагрузкаНомеров.ТипНомера.* AS ТипНомера,
//	|	ЗагрузкаНомеров.Recorder.ВидРазмещения.* AS ВидРазмещения,
//	|	ЗагрузкаНомеров.Recorder.RoomRateType.* AS RoomRateType,
//	|	ЗагрузкаНомеров.Recorder.Тариф.* AS Тариф,
//	|	ЗагрузкаНомеров.Recorder.PricePresentation AS PricePresentation,
//	|	ЗагрузкаНомеров.Recorder.Автор.* AS Автор,
//	|	ЗагрузкаНомеров.Recorder.ДисконтКарт.* AS ДисконтКарт,
//	|	ЗагрузкаНомеров.Recorder.ТипСкидки.* AS ТипСкидки,
//	|	ЗагрузкаНомеров.Recorder.Скидка AS Скидка,
//	|	ЗагрузкаНомеров.Recorder.PlannedPaymentMethod.* AS PlannedPaymentMethod,
//	|	ЗагрузкаНомеров.Recorder.Car AS Car,
//	|	ЗагрузкаНомеров.Recorder.Примечания AS Примечания,
//	|	ЗагрузкаНомеров.Recorder.КомиссияАгента AS КомиссияАгента,
//	|	ЗагрузкаНомеров.Recorder.ВидКомиссииАгента.* AS ВидКомиссииАгента,
//	|	ЗагрузкаНомеров.Recorder.IsMaster AS IsMaster,
//	|	ForeignerRegistryRecords.ForeignerRegistryRecord.* AS ForeignerRegistryRecord,
//	|	(1) AS NumberOfGuests}
//	|
//	|ORDER BY
//	|	Гостиница,
//	|	CheckInDate,
//	|	Клиент
//	|{ORDER BY
//	|	Контрагент.*,
//	|	ЗагрузкаНомеров.Recorder.ТипКонтрагента.* AS ТипКонтрагента,
//	|	ЗагрузкаНомеров.Recorder.Договор.* AS Договор,
//	|	ЗагрузкаНомеров.Recorder.Агент.* AS Агент,
//	|	ГруппаГостей.* AS ГруппаГостей,
//	|	Клиент.* AS Клиент,
//	|	GuestDateOfBirth AS GuestDateOfBirth,
//	|	ЗагрузкаНомеров.Recorder.МаретингНапрвл.* AS МаретингНапрвл,
//	|	ЗагрузкаНомеров.Recorder.TripPurpose.* AS TripPurpose,
//	|	ЗагрузкаНомеров.Recorder.ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
//	|	ЗагрузкаНомеров.Recorder.RoomRateType.* AS RoomRateType,
//	|	ЗагрузкаНомеров.Recorder.ПутевкаКурсовка.* AS ПутевкаКурсовка,
//	|	Тариф.* AS Тариф,
//	|	Status.* AS Status,
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
//	|	(HOUR(ЗагрузкаНомеров.Recorder.CheckInDate)) AS CheckInHour,
//	|	(DAY(ЗагрузкаНомеров.Recorder.CheckInDate)) AS CheckInDay,
//	|	(WEEK(ЗагрузкаНомеров.Recorder.CheckInDate)) AS CheckInWeek,
//	|	(MONTH(ЗагрузкаНомеров.Recorder.CheckInDate)) AS CheckInMonth,
//	|	(QUARTER(ЗагрузкаНомеров.Recorder.CheckInDate)) AS CheckInQuarter,
//	|	(YEAR(ЗагрузкаНомеров.Recorder.CheckInDate)) AS CheckInYear,
//	|	ЗагрузкаНомеров.Recorder.КвотаНомеров.* AS КвотаНомеров,
//	|	ЗагрузкаНомеров.Recorder.Автор.* AS Автор,
//	|	ЗагрузкаНомеров.Recorder.ДокОснование.* AS ДокОснование,
//	|	ЗагрузкаНомеров.Recorder.* AS Recorder,
//	|	ForeignerRegistryRecords.ForeignerRegistryRecord.* AS ForeignerRegistryRecord}
//	|TOTALS
//	|	SUM(NumberOfGuests)
//	|BY
//	|	OVERALL,
//	|	Гостиница,
//	|	НомерРазмещения
//	|{TOTALS BY
//	|	Гостиница.* AS Гостиница,
//	|	ЗагрузкаНомеров.CheckInAccountingDate AS CheckInAccountingDate,
//	|	ЗагрузкаНомеров.CheckOutAccountingDate AS CheckOutAccountingDate,
//	|	(HOUR(ЗагрузкаНомеров.Recorder.CheckInDate)) AS CheckInHour,
//	|	(DAY(ЗагрузкаНомеров.Recorder.CheckInDate)) AS CheckInDay,
//	|	(WEEK(ЗагрузкаНомеров.Recorder.CheckInDate)) AS CheckInWeek,
//	|	(MONTH(ЗагрузкаНомеров.Recorder.CheckInDate)) AS CheckInMonth,
//	|	(QUARTER(ЗагрузкаНомеров.Recorder.CheckInDate)) AS CheckInQuarter,
//	|	(YEAR(ЗагрузкаНомеров.Recorder.CheckInDate)) AS CheckInYear,
//	|	Клиент.* AS Клиент,
//	|	ВидРазмещения.* AS ВидРазмещения,
//	|	Тариф.* AS Тариф,
//	|	ТипНомера.* AS ТипНомера,
//	|	НомерРазмещения.* AS НомерРазмещения,
//	|	Контрагент.* AS Контрагент,
//	|	ЗагрузкаНомеров.Recorder.ДокОснование.* AS ДокОснование,
//	|	ЗагрузкаНомеров.Recorder.* AS Recorder,
//	|	ЗагрузкаНомеров.Recorder.ТипКонтрагента.* AS ТипКонтрагента,
//	|	ЗагрузкаНомеров.Recorder.Договор.* AS Договор,
//	|	ЗагрузкаНомеров.Recorder.КонтактноеЛицо AS КонтактноеЛицо,
//	|	ЗагрузкаНомеров.Recorder.Агент.* AS Агент,
//	|	ГруппаГостей.* AS ГруппаГостей,
//	|	ЗагрузкаНомеров.Recorder.ПутевкаКурсовка.* AS ПутевкаКурсовка,
//	|	Status.* AS Status,
//	|	ЗагрузкаНомеров.Recorder.КвотаНомеров.* AS КвотаНомеров,
//	|	ЗагрузкаНомеров.Recorder.ТипКлиента.* AS ТипКлиента,
//	|	ЗагрузкаНомеров.Recorder.МаретингНапрвл.* AS МаретингНапрвл,
//	|	ЗагрузкаНомеров.Recorder.TripPurpose.* AS TripPurpose,
//	|	ЗагрузкаНомеров.Recorder.ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
//	|	ЗагрузкаНомеров.Recorder.RoomRateType.* AS RoomRateType,
//	|	ЗагрузкаНомеров.Recorder.Автор.* AS Автор,
//	|	PricePresentation AS PricePresentation,
//	|	ForeignerRegistryRecords.ForeignerRegistryRecord.* AS ForeignerRegistryRecord,
//	|	ЗагрузкаНомеров.Recorder.ДисконтКарт.* AS ДисконтКарт,
//	|	ЗагрузкаНомеров.Recorder.ТипСкидки.* AS ТипСкидки,
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
//	ReportBuilder.HeaderText = NStr("EN='Guests with birthday';RU='Гости, у которых день рождения';de='Gäste, die im angegebenen Zeitraum Geburtstag haben'");
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
