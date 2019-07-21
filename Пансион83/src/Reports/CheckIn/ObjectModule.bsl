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
//	ReportBuilder.Parameters.Вставить("qPeriodFrom", PeriodFrom);
//	ReportBuilder.Parameters.Вставить("qPeriodTo", PeriodTo);
//	ReportBuilder.Parameters.Вставить("qRoom", ГруппаНомеров);
//	ReportBuilder.Parameters.Вставить("qRoomType", RoomType);
//	ReportBuilder.Parameters.Вставить("qEndOfTime", '39991231');
// 	vShowFRR = False;
//	vShowCDS = False;
//	For Each vFld In ReportBuilder.SelectedFields Do
//		If Left(vFld.Name, 23) = "ForeignerRegistryRecord" Тогда
//			vShowFRR = True;
//		EndIf;
//		If Left(vFld.Name, 14) = "ClientDataScan" Тогда
//			vShowCDS = True;
//		EndIf;
//	EndDo;
//	ReportBuilder.Parameters.Вставить("qShowFRR", vShowFRR);
//	ReportBuilder.Parameters.Вставить("qShowCDS", vShowCDS);
//	ReportBuilder.Parameters.Вставить("qEmptyForeignerRegistryRecord", Documents.ForeignerRegistryRecord.EmptyRef());
//	ReportBuilder.Parameters.Вставить("qEmptyClientDataScan", Documents.ДанныеКлиента.EmptyRef());
//
//	// Execute report builder query
//	ReportBuilder.Execute();
//	
//	//// Apply appearance settings to the report template
//	//vTemplateAttributes = cmApplyReportTemplateAppearance(ThisObject);
//	//
//	//// Output report to the spreadsheet
//	//ReportBuilder.Put(pSpreadsheet);
//	////ReportBuilder.Template.Show(); // For debug purpose
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
//	|	ЗагрузкаНомеров.Recorder.ГруппаГостей AS ГруппаГостей,
//	|	ЗагрузкаНомеров.Recorder.СтатусРазмещения AS СтатусРазмещения,
//	|	ЗагрузкаНомеров.Recorder.Клиент AS Клиент,
//	|	ЗагрузкаНомеров.Recorder.CheckInDate AS CheckInDate,
//	|	ЗагрузкаНомеров.Recorder.Продолжительность AS Продолжительность,
//	|	ЗагрузкаНомеров.Recorder.CheckOutDate AS CheckOutDate,
//	|	ЗагрузкаНомеров.ТипНомера AS ТипНомера,
//	|	ЗагрузкаНомеров.Recorder.ВидРазмещения AS ВидРазмещения,
//	|	ЗагрузкаНомеров.Recorder.Тариф AS Тариф,
//	|	ЗагрузкаНомеров.Recorder.PricePresentation AS PricePresentation,
//	|	ЗагрузкаНомеров.Recorder.Reservation.Тариф AS ParentDocRoomRate,
//	|	ЗагрузкаНомеров.Recorder.Reservation.PricePresentation AS ParentDocPricePresentation,
//	|	CASE
//	|		WHEN ЗагрузкаНомеров.Recorder.Reservation.PricePresentation <> """"
//	|				AND ЗагрузкаНомеров.Recorder.Reservation.PricePresentation <> RoomInventory.Recorder.PricePresentation
//	|			THEN TRUE
//	|		ELSE FALSE
//	|	END AS ThereIsPriceDifference,
//	|	ЗагрузкаНомеров.Recorder.Примечания AS Примечания,
//	|	ЗагрузкаНомеров.ЗаездГостей AS ЗаездГостей,
//	|	ЗагрузкаНомеров.ЗаездНомеров AS ЗаездНомеров,
//	|	ЗагрузкаНомеров.ЗаездМест AS ЗаездМест,
//	|	ЗагрузкаНомеров.ЗаездДополнительныхМест AS ЗаездДополнительныхМест
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
//	|	ЗагрузкаНомеров.Recorder.Reservation.ТипНомера.* AS ParentDocRoomType,
//	|	ЗагрузкаНомеров.Recorder.Reservation.ВидРазмещения.* AS ParentDocAccommodationType,
//	|	ЗагрузкаНомеров.Recorder.Reservation.RoomRateType.* AS ParentDocRoomRateType,
//	|	ParentDocRoomRate.* AS ParentDocRoomRate,
//	|	ParentDocPricePresentation AS ParentDocPricePresentation,
//	|	ThereIsPriceDifference AS ThereIsPriceDifference,
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
//	|	ЗагрузкаНомеров.Recorder.Автор.* AS Автор,
//	|	ЗагрузкаНомеров.Recorder.ДисконтКарт.* AS ДисконтКарт,
//	|	ЗагрузкаНомеров.Recorder.ТипСкидки.* AS ТипСкидки,
//	|	ЗагрузкаНомеров.Recorder.Скидка AS Скидка,
//	|	ЗагрузкаНомеров.Recorder.КомиссияАгента AS КомиссияАгента,
//	|	ЗагрузкаНомеров.Recorder.ВидКомиссииАгента.* AS ВидКомиссииАгента,
//	|	ЗагрузкаНомеров.Recorder.КоличествоМестНомер AS КоличествоМестНомер,
//	|	ЗагрузкаНомеров.Recorder.КоличествоГостейНомер AS КоличествоГостейНомер,
//	|	ЗагрузкаНомеров.Recorder.Reservation.* AS ДокОснование,
//	|	ЗагрузкаНомеров.Recorder.* AS Recorder,
//	|	(DATEDIFF(ЗагрузкаНомеров.Recorder.Reservation.ДатаДок, RoomInventory.Recorder.ДатаДок, MINUTE)) AS CheckInWaitTimeInMinutes,
//	|	(DATEDIFF(ЗагрузкаНомеров.Recorder.Reservation.ДатаДок, RoomInventory.Recorder.ДатаДок, HOUR)) AS CheckInWaitTimeInHours,
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
//	|	ЗагрузкаНомеров.Recorder.PointInTime AS PointInTime,
//	|	(CASE
//	|			WHEN ForeignerRegistryRecords.ForeignerRegistryRecord IS NULL 
//	|				THEN &qEmptyForeignerRegistryRecord
//	|			ELSE ForeignerRegistryRecords.ForeignerRegistryRecord
//	|		END).* AS ForeignerRegistryRecord,
//	|	(CASE
//	|			WHEN ДанныеКлиента.Ref IS NULL 
//	|				THEN &qEmptyClientDataScan
//	|			ELSE ДанныеКлиента.Ref
//	|		END).* AS ClientDataScan,
//	|	ЗаездГостей AS ЗаездГостей,
//	|	ЗаездНомеров AS ЗаездНомеров,
//	|	ЗаездМест AS ЗаездМест,
//	|	ЗаездДополнительныхМест AS AdditionalBedsCheckedIn}
//	|FROM
//	|	(SELECT
//	|		RoomInventoryMovements.Recorder AS Recorder,
//	|		RoomInventoryMovements.НомерРазмещения AS НомерРазмещения,
//	|		RoomInventoryMovements.ТипНомера AS ТипНомера,
//	|		MIN(RoomInventoryMovements.CheckInAccountingDate) AS CheckInAccountingDate,
//	|		MAX(RoomInventoryMovements.CheckOutAccountingDate) AS CheckOutAccountingDate,
//	|		SUM(RoomInventoryMovements.ЗаездГостей) AS ЗаездГостей,
//	|		SUM(RoomInventoryMovements.ЗаездНомеров) AS ЗаездНомеров,
//	|		SUM(RoomInventoryMovements.ЗаездМест) AS ЗаездМест,
//	|		SUM(RoomInventoryMovements.ЗаездДополнительныхМест) AS ЗаездДополнительныхМест
//	|	FROM
//	|		AccumulationRegister.ЗагрузкаНомеров AS RoomInventoryMovements
//	|	WHERE
//	|		RoomInventoryMovements.RecordType = VALUE(AccumulationRecordType.Expense)
//	|		AND RoomInventoryMovements.IsAccommodation = TRUE
//	|		AND RoomInventoryMovements.Гостиница IN HIERARCHY(&qHotel)
//	|		AND RoomInventoryMovements.НомерРазмещения IN HIERARCHY(&qRoom)
//	|		AND RoomInventoryMovements.ТипНомера IN HIERARCHY(&qRoomType)
//	|		AND RoomInventoryMovements.ПериодС >= &qPeriodFrom
//	|		AND RoomInventoryMovements.ПериодС < &qPeriodTo
//	|		AND RoomInventoryMovements.CheckInDate = RoomInventoryMovements.ПериодС
//	|		AND RoomInventoryMovements.ЭтоЗаезд = TRUE
//	|	
//	|	GROUP BY
//	|		RoomInventoryMovements.Recorder,
//	|		RoomInventoryMovements.НомерРазмещения,
//	|		RoomInventoryMovements.ТипНомера) AS ЗагрузкаНомеров
//	|		LEFT JOIN InformationRegister.AccommodationForeignerRegistryRecords.SliceLast(&qEndOfTime, &qShowFRR) AS ForeignerRegistryRecords
//	|		ON ЗагрузкаНомеров.Recorder = ForeignerRegistryRecords.Размещение
//	|		LEFT JOIN Document.ДанныеКлиента AS ДанныеКлиента
//	|		ON ЗагрузкаНомеров.Recorder = ДанныеКлиента.ДокОснование
//	|			AND (ДанныеКлиента.Posted)
//	|			AND (&qShowCDS)
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
//	|	ЗагрузкаНомеров.Recorder.Reservation.* AS ДокОснование,
//	|	ЗагрузкаНомеров.Recorder.ПутевкаКурсовка.* AS ПутевкаКурсовка,
//	|	ЗагрузкаНомеров.Recorder.СтатусРазмещения.* AS СтатусРазмещения,
//	|	ЗагрузкаНомеров.Recorder.CheckInDate AS CheckInDate,
//	|	ЗагрузкаНомеров.Recorder.Продолжительность AS Продолжительность,
//	|	ЗагрузкаНомеров.Recorder.CheckOutDate AS CheckOutDate,
//	|	ЗагрузкаНомеров.CheckInAccountingDate AS CheckInAccountingDate,
//	|	ЗагрузкаНомеров.CheckOutAccountingDate AS CheckOutAccountingDate,
//	|	(HOUR(ЗагрузкаНомеров.Recorder.CheckInDate)) AS CheckInHour,
//	|	ЗагрузкаНомеров.Recorder.КвотаНомеров.* AS КвотаНомеров,
//	|	ЗагрузкаНомеров.Recorder.ТипКлиента.* AS ТипКлиента,
//	|	ЗагрузкаНомеров.Recorder.Клиент.* AS Клиент,
//	|	ЗагрузкаНомеров.Recorder.МаретингНапрвл.* AS МаретингНапрвл,
//	|	ЗагрузкаНомеров.Recorder.TripPurpose.* AS TripPurpose,
//	|	ЗагрузкаНомеров.Recorder.ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
//	|	ЗагрузкаНомеров.ТипНомера.* AS ТипНомера,
//	|	ЗагрузкаНомеров.Recorder.ВидРазмещения.* AS ВидРазмещения,
//	|	ЗагрузкаНомеров.Recorder.RoomRateType.* AS RoomRateType,
//	|	ЗагрузкаНомеров.Recorder.Тариф.* AS Тариф,
//	|	ЗагрузкаНомеров.Recorder.PricePresentation AS PricePresentation,
//	|	ЗагрузкаНомеров.Recorder.Reservation.ТипНомера.* AS ParentDocRoomType,
//	|	ЗагрузкаНомеров.Recorder.Reservation.ВидРазмещения.* AS ParentDocAccommodationType,
//	|	ЗагрузкаНомеров.Recorder.Reservation.RoomRateType.* AS ParentDocRoomRateType,
//	|	ЗагрузкаНомеров.Recorder.Reservation.Тариф.* AS ParentDocRoomRate,
//	|	ЗагрузкаНомеров.Recorder.Reservation.PricePresentation AS ParentDocPricePresentation,
//	|	(CASE
//	|			WHEN ЗагрузкаНомеров.Recorder.Reservation.PricePresentation <> """"
//	|					AND ЗагрузкаНомеров.Recorder.Reservation.PricePresentation <> RoomInventory.Recorder.PricePresentation
//	|				THEN TRUE
//	|			ELSE FALSE
//	|		END) AS ThereIsPriceDifference,
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
//	|	(DATEDIFF(ЗагрузкаНомеров.Recorder.Reservation.ДатаДок, RoomInventory.Recorder.ДатаДок, MINUTE)) AS CheckInWaitTimeInMinutes,
//	|	(DATEDIFF(ЗагрузкаНомеров.Recorder.Reservation.ДатаДок, RoomInventory.Recorder.ДатаДок, HOUR)) AS CheckInWaitTimeInHours,
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
//	|	(CASE
//	|			WHEN ForeignerRegistryRecords.ForeignerRegistryRecord IS NULL 
//	|				THEN &qEmptyForeignerRegistryRecord
//	|			ELSE ForeignerRegistryRecords.ForeignerRegistryRecord
//	|		END).* AS ForeignerRegistryRecord,
//	|	(CASE
//	|			WHEN ДанныеКлиента.Ref IS NULL 
//	|				THEN &qEmptyClientDataScan
//	|			ELSE ДанныеКлиента.Ref
//	|		END).* AS ClientDataScan,
//	|	ЗагрузкаНомеров.ЗаездНомеров AS ЗаездНомеров,
//	|	ЗагрузкаНомеров.ЗаездМест AS ЗаездМест,
//	|	ЗагрузкаНомеров.ЗаездДополнительныхМест AS ЗаездДополнительныхМест,
//	|	ЗагрузкаНомеров.ЗаездГостей AS GuestsCheckedIn}
//	|
//	|ORDER BY
//	|	Гостиница,
//	|	НомерРазмещения,
//	|	CheckInDate,
//	|	Клиент
//	|{ORDER BY
//	|	Контрагент.*,
//	|	ЗагрузкаНомеров.Recorder.ТипКонтрагента.* AS ТипКонтрагента,
//	|	ЗагрузкаНомеров.Recorder.Договор.* AS Договор,
//	|	ЗагрузкаНомеров.Recorder.Агент.* AS Агент,
//	|	ГруппаГостей.* AS ГруппаГостей,
//	|	Клиент.* AS Клиент,
//	|	ЗагрузкаНомеров.Recorder.МаретингНапрвл.* AS МаретингНапрвл,
//	|	ЗагрузкаНомеров.Recorder.TripPurpose.* AS TripPurpose,
//	|	ЗагрузкаНомеров.Recorder.ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
//	|	ЗагрузкаНомеров.Recorder.RoomRateType.* AS RoomRateType,
//	|	ЗагрузкаНомеров.Recorder.ПутевкаКурсовка.* AS ПутевкаКурсовка,
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
//	|	(HOUR(ЗагрузкаНомеров.Recorder.CheckInDate)) AS CheckInHour,
//	|	(DAY(ЗагрузкаНомеров.Recorder.CheckInDate)) AS CheckInDay,
//	|	(WEEK(ЗагрузкаНомеров.Recorder.CheckInDate)) AS CheckInWeek,
//	|	(MONTH(ЗагрузкаНомеров.Recorder.CheckInDate)) AS CheckInMonth,
//	|	(QUARTER(ЗагрузкаНомеров.Recorder.CheckInDate)) AS CheckInQuarter,
//	|	(YEAR(ЗагрузкаНомеров.Recorder.CheckInDate)) AS CheckInYear,
//	|	ЗагрузкаНомеров.Recorder.КвотаНомеров.* AS КвотаНомеров,
//	|	ЗагрузкаНомеров.Recorder.Автор.* AS Автор,
//	|	ЗагрузкаНомеров.Recorder.Reservation.* AS ДокОснование,
//	|	ЗагрузкаНомеров.Recorder.* AS Recorder,
//	|	ЗагрузкаНомеров.Recorder.Reservation.ТипНомера.* AS ParentDocRoomType,
//	|	ЗагрузкаНомеров.Recorder.Reservation.ВидРазмещения.* AS ParentDocAccommodationType,
//	|	ЗагрузкаНомеров.Recorder.Reservation.RoomRateType.* AS ParentDocRoomRateType,
//	|	(DATEDIFF(ЗагрузкаНомеров.Recorder.Reservation.ДатаДок, RoomInventory.Recorder.ДатаДок, MINUTE)) AS CheckInWaitTimeInMinutes,
//	|	(DATEDIFF(ЗагрузкаНомеров.Recorder.Reservation.ДатаДок, RoomInventory.Recorder.ДатаДок, HOUR)) AS CheckInWaitTimeInHours,
//	|	ParentDocRoomRate.* AS ParentDocRoomRate,
//	|	(CASE
//	|			WHEN ForeignerRegistryRecords.ForeignerRegistryRecord IS NULL 
//	|				THEN &qEmptyForeignerRegistryRecord
//	|			ELSE ForeignerRegistryRecords.ForeignerRegistryRecord
//	|		END).* AS ForeignerRegistryRecord,
//	|	(CASE
//	|			WHEN ДанныеКлиента.Ref IS NULL 
//	|				THEN &qEmptyClientDataScan
//	|			ELSE ДанныеКлиента.Ref
//	|		END).* AS ClientDataScan,
//	|	ЗаездНомеров AS ЗаездНомеров,
//	|	ЗаездМест AS ЗаездМест,
//	|	ЗаездДополнительныхМест AS ЗаездДополнительныхМест,
//	|	ЗаездГостей AS GuestsCheckedIn}
//	|TOTALS
//	|	SUM(ЗаездГостей),
//	|	SUM(ЗаездНомеров),
//	|	SUM(ЗаездМест),
//	|	SUM(ЗаездДополнительныхМест)
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
//	|	СтатусРазмещения.* AS СтатусРазмещения,
//	|	ВидРазмещения.* AS ВидРазмещения,
//	|	Тариф.* AS Тариф,
//	|	ТипНомера.* AS ТипНомера,
//	|	НомерРазмещения.* AS НомерРазмещения,
//	|	Контрагент.* AS Контрагент,
//	|	ЗагрузкаНомеров.Recorder.Reservation.* AS ДокОснование,
//	|	ЗагрузкаНомеров.Recorder.* AS Recorder,
//	|	ЗагрузкаНомеров.Recorder.ТипКонтрагента.* AS ТипКонтрагента,
//	|	ЗагрузкаНомеров.Recorder.Договор.* AS Договор,
//	|	ЗагрузкаНомеров.Recorder.КонтактноеЛицо AS КонтактноеЛицо,
//	|	ЗагрузкаНомеров.Recorder.Агент.* AS Агент,
//	|	ГруппаГостей.* AS ГруппаГостей,
//	|	ЗагрузкаНомеров.Recorder.ПутевкаКурсовка.* AS ПутевкаКурсовка,
//	|	СтатусРазмещения.* AS СтатусРазмещения,
//	|	ЗагрузкаНомеров.Recorder.КвотаНомеров.* AS КвотаНомеров,
//	|	ЗагрузкаНомеров.Recorder.ТипКлиента.* AS ТипКлиента,
//	|	ЗагрузкаНомеров.Recorder.МаретингНапрвл.* AS МаретингНапрвл,
//	|	ЗагрузкаНомеров.Recorder.TripPurpose.* AS TripPurpose,
//	|	ЗагрузкаНомеров.Recorder.ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
//	|	ЗагрузкаНомеров.Recorder.RoomRateType.* AS RoomRateType,
//	|	ЗагрузкаНомеров.Recorder.Автор.* AS Автор,
//	|	PricePresentation AS PricePresentation,
//	|	ЗагрузкаНомеров.Recorder.Reservation.ТипНомера.* AS ParentDocRoomType,
//	|	ЗагрузкаНомеров.Recorder.Reservation.ВидРазмещения.* AS ParentDocAccommodationType,
//	|	ЗагрузкаНомеров.Recorder.Reservation.RoomRateType.* AS ParentDocRoomRateType,
//	|	ParentDocRoomRate.* AS ParentDocRoomRate,
//	|	(DATEDIFF(ЗагрузкаНомеров.Recorder.Reservation.ДатаДок, RoomInventory.Recorder.ДатаДок, MINUTE)) AS CheckInWaitTimeInMinutes,
//	|	(DATEDIFF(ЗагрузкаНомеров.Recorder.Reservation.ДатаДок, RoomInventory.Recorder.ДатаДок, HOUR)) AS CheckInWaitTimeInHours,
//	|	(CASE
//	|			WHEN ForeignerRegistryRecords.ForeignerRegistryRecord IS NULL 
//	|				THEN &qEmptyForeignerRegistryRecord
//	|			ELSE ForeignerRegistryRecords.ForeignerRegistryRecord
//	|		END).* AS ForeignerRegistryRecord,
//	|	(CASE
//	|			WHEN ДанныеКлиента.Ref IS NULL 
//	|				THEN &qEmptyClientDataScan
//	|			ELSE ДанныеКлиента.Ref
//	|		END).* AS ClientDataScan,
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
//	ReportBuilder.HeaderText = NStr("EN='Guests checked-in';RU='Фактический заезд';de='Faktische Anreise'");
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
