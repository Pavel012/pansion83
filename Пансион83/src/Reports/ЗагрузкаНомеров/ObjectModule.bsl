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
//	If НЕ ЗначениеЗаполнено(PeriodTo) Тогда
//		PeriodTo = CurrentDate(); // For now
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
//	If ЗначениеЗаполнено(PeriodTo) Тогда
//		vParamPresentation = vParamPresentation + NStr("ru = 'На '; en = 'On '") + 
//		                     Format(PeriodTo, "DF='dd.MM.yyyy HH:mm:ss'") + 
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
//	If ЗначениеЗаполнено(RoomQuota) Тогда
//		If НЕ RoomQuota.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("en='Allotment ';ru='Квота ';de='Quote '") + 
//			                     TrimAll(RoomQuota.Description) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("en='Allotments folder ';ru='Группа квот ';de='Gruppe Quoten '") + 
//			                     TrimAll(RoomQuota.Description) + 
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
//	ReportBuilder.Parameters.Вставить("qIsEmptyHotel", НЕ ЗначениеЗаполнено(Гостиница));
//	ReportBuilder.Parameters.Вставить("qPeriodTo", PeriodTo);
//	ReportBuilder.Parameters.Вставить("qRoom", ГруппаНомеров);
//	ReportBuilder.Parameters.Вставить("qIsEmptyRoom", НЕ ЗначениеЗаполнено(ГруппаНомеров));
//	ReportBuilder.Parameters.Вставить("qRoomType", RoomType);
//	ReportBuilder.Parameters.Вставить("qIsEmptyRoomType", НЕ ЗначениеЗаполнено(RoomType));
//	ReportBuilder.Parameters.Вставить("qRoomQuota", RoomQuota);
//	ReportBuilder.Parameters.Вставить("qIsEmptyRoomQuota", НЕ ЗначениеЗаполнено(RoomQuota));
//	ReportBuilder.Parameters.Вставить("qEmptyDate", '00010101');
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
//	|	ЗагрузкаНомеров.Гостиница AS Гостиница,
//	|	ЗагрузкаНомеров.Status AS Status,
//	|	ЗагрузкаНомеров.НомерРазмещения AS НомерРазмещения,
//	|	ЗагрузкаНомеров.Контрагент AS Контрагент,
//	|	ЗагрузкаНомеров.Договор AS Договор,
//	|	ЗагрузкаНомеров.ГруппаГостей AS ГруппаГостей,
//	|	ЗагрузкаНомеров.Клиент AS Клиент,
//	|	ЗагрузкаНомеров.CheckInDate AS CheckInDate,
//	|	ЗагрузкаНомеров.Продолжительность AS Продолжительность,
//	|	ЗагрузкаНомеров.CheckOutDate AS CheckOutDate,
//	|	ЗагрузкаНомеров.ТипНомера AS ТипНомера,
//	|	ЗагрузкаНомеров.ВидРазмещения,
//	|	ЗагрузкаНомеров.КвотаНомеров AS КвотаНомеров,
//	|	ЗагрузкаНомеров.Примечания AS Примечания,
//	|	ЗагрузкаНомеров.Recorder AS Recorder,
//	|	ЗагрузкаНомеров.IsRoomInventory AS IsRoomInventory,
//	|	ЗагрузкаНомеров.IsBlocking AS IsBlocking,
//	|	ЗагрузкаНомеров.IsRoomQuota AS IsRoomQuota,
//	|	ЗагрузкаНомеров.IsReservation AS IsReservation,
//	|	ЗагрузкаНомеров.IsAccommodation AS IsAccommodation,
//	|	ЗагрузкаНомеров.RoomsVacant AS RoomsVacant,
//	|	ЗагрузкаНомеров.BedsVacant AS BedsVacant
//	|{SELECT
//	|	Гостиница.*,
//	|	Recorder.*,
//	|	Status.*,
//	|	НомерРазмещения.*,
//	|	Контрагент.*,
//	|	Договор.*,
//	|	ГруппаГостей.*,
//	|	Клиент.*,
//	|	CheckInDate,
//	|	Продолжительность,
//	|	CheckOutDate,
//	|	ТипНомера.*,
//	|	ВидРазмещения.*,
//	|	КвотаНомеров.*,
//	|	Примечания,
//	|	IsRoomInventory,
//	|	IsBlocking,
//	|	IsRoomQuota,
//	|	IsReservation,
//	|	IsAccommodation,
//	|	RoomsVacant,
//	|	BedsVacant}
//	|FROM
//	|	(SELECT DISTINCT
//	|		RoomInventoryMovements.Гостиница AS Гостиница,
//	|		RoomInventoryMovements.Status AS Status,
//	|		RoomInventoryMovements.НомерРазмещения AS НомерРазмещения,
//	|		RoomInventoryMovements.Контрагент AS Контрагент,
//	|		RoomInventoryMovements.Договор AS Договор,
//	|		RoomInventoryMovements.ГруппаГостей AS ГруппаГостей,
//	|		RoomInventoryMovements.Клиент AS Клиент,
//	|		RoomInventoryMovements.CheckInDate AS CheckInDate,
//	|		RoomInventoryMovements.Продолжительность AS Продолжительность,
//	|		RoomInventoryMovements.CheckOutDate AS CheckOutDate,
//	|		RoomInventoryMovements.ТипНомера AS ТипНомера,
//	|		RoomInventoryMovements.ВидРазмещения AS ВидРазмещения,
//	|		RoomInventoryMovements.КвотаНомеров AS КвотаНомеров,
//	|		CAST(RoomInventoryMovements.Примечания AS STRING(1024)) AS Примечания,
//	|		RoomInventoryMovements.Recorder AS Recorder,
//	|		RoomInventoryMovements.IsRoomInventory AS IsRoomInventory,
//	|		RoomInventoryMovements.IsBlocking AS IsBlocking,
//	|		RoomInventoryMovements.IsRoomQuota AS IsRoomQuota,
//	|		RoomInventoryMovements.IsReservation AS IsReservation,
//	|		RoomInventoryMovements.IsAccommodation AS IsAccommodation,
//	|		RoomInventoryMovements.RoomsVacant AS RoomsVacant,
//	|		RoomInventoryMovements.BedsVacant AS BedsVacant
//	|	FROM
//	|		(SELECT
//	|			AvailableRooms.Гостиница AS Гостиница,
//	|			NULL AS Status,
//	|			NULL AS НомерРазмещения,
//	|			NULL AS Контрагент,
//	|			NULL AS Договор,
//	|			NULL AS ГруппаГостей,
//	|			NULL AS Клиент,
//	|			NULL AS CheckInDate,
//	|			NULL AS Продолжительность,
//	|			NULL AS CheckOutDate,
//	|			NULL AS ТипНомера,
//	|			NULL AS ВидРазмещения,
//	|			NULL AS КвотаНомеров,
//	|			NULL AS Примечания,
//	|			NULL AS Recorder,
//	|			TRUE AS IsRoomInventory,
//	|			FALSE AS IsBlocking,
//	|			FALSE AS IsRoomQuota,
//	|			FALSE AS IsReservation,
//	|			FALSE AS IsAccommodation,
//	|			ISNULL(AvailableRooms.TotalRoomsBalance, 0) AS RoomsVacant,
//	|			ISNULL(AvailableRooms.TotalBedsBalance, 0) AS BedsVacant
//	|		FROM
//	|			AccumulationRegister.ЗагрузкаНомеров.Balance(
//	|					&qPeriodTo,
//	|					&qIsEmptyRoomQuota
//	|						AND (Гостиница IN HIERARCHY (&qHotel)
//	|							OR &qIsEmptyHotel)
//	|						AND (НомерРазмещения IN HIERARCHY (&qRoom)
//	|							OR &qIsEmptyRoom)
//	|						AND (ТипНомера IN HIERARCHY (&qRoomType)
//	|							OR &qIsEmptyRoomType)) AS AvailableRooms
//	|		
//	|		UNION ALL
//	|		
//	|		SELECT
//	|			БлокирНомеров.Гостиница,
//	|			БлокирНомеров.RoomBlockType,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			FALSE,
//	|			TRUE,
//	|			FALSE,
//	|			FALSE,
//	|			FALSE,
//	|			-ISNULL(БлокирНомеров.RoomsBlockedBalance, 0),
//	|			-ISNULL(БлокирНомеров.BedsBlockedBalance, 0)
//	|		FROM
//	|			AccumulationRegister.БлокирНомеров.Balance(
//	|					&qPeriodTo,
//	|					&qIsEmptyRoomQuota
//	|						AND (Гостиница IN HIERARCHY (&qHotel)
//	|							OR &qIsEmptyHotel)
//	|						AND (НомерРазмещения IN HIERARCHY (&qRoom)
//	|							OR &qIsEmptyRoom)
//	|						AND (ТипНомера IN HIERARCHY (&qRoomType)
//	|							OR &qIsEmptyRoomType)) AS БлокирНомеров
//	|		
//	|		UNION ALL
//	|		
//	|		SELECT
//	|			КвотаНомеров.Гостиница,
//	|			КвотаНомеров.КвотаНомеров,
//	|			NULL,
//	|			КвотаНомеров.КвотаНомеров.Контрагент,
//	|			КвотаНомеров.КвотаНомеров.Договор,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			NULL,
//	|			КвотаНомеров.КвотаНомеров,
//	|			NULL,
//	|			NULL,
//	|			FALSE,
//	|			FALSE,
//	|			TRUE,
//	|			FALSE,
//	|			FALSE,
//	|			-ISNULL(КвотаНомеров.RoomsRemainsBalance, 0),
//	|			-ISNULL(КвотаНомеров.BedsRemainsBalance, 0)
//	|		FROM
//	|			AccumulationRegister.ПродажиКвот.Balance(
//	|					&qPeriodTo,
//	|					КвотаНомеров.DoWriteOff
//	|						AND (Гостиница IN HIERARCHY (&qHotel)
//	|							OR &qIsEmptyHotel)
//	|						AND (КвотаНомеров IN HIERARCHY (&qRoomQuota)
//	|							OR &qIsEmptyRoomQuota)
//	|						AND (НомерРазмещения IN HIERARCHY (&qRoom)
//	|							OR &qIsEmptyRoom)
//	|						AND (ТипНомера IN HIERARCHY (&qRoomType)
//	|							OR &qIsEmptyRoomType)) AS КвотаНомеров
//	|		
//	|		UNION ALL
//	|		
//	|		SELECT
//	|			Reservations.Гостиница,
//	|			Reservations.ReservationStatus,
//	|			Reservations.НомерРазмещения,
//	|			Reservations.Контрагент,
//	|			Reservations.Договор,
//	|			Reservations.ГруппаГостей,
//	|			Reservations.Клиент,
//	|			Reservations.ПериодС,
//	|			Reservations.PeriodDuration,
//	|			Reservations.ПериодПо,
//	|			Reservations.ТипНомера,
//	|			Reservations.ВидРазмещения,
//	|			Reservations.КвотаНомеров,
//	|			Reservations.Примечания,
//	|			Reservations.Recorder,
//	|			FALSE,
//	|			FALSE,
//	|			FALSE,
//	|			TRUE,
//	|			FALSE,
//	|			-Reservations.RoomsVacant,
//	|			-Reservations.BedsVacant
//	|		FROM
//	|			AccumulationRegister.ЗагрузкаНомеров AS Reservations
//	|		WHERE
//	|			Reservations.RecordType = VALUE(AccumulationRecordType.Expense)
//	|			AND Reservations.IsReservation
//	|			AND (Reservations.Гостиница IN HIERARCHY (&qHotel)
//	|					OR &qIsEmptyHotel)
//	|			AND (Reservations.НомерРазмещения IN HIERARCHY (&qRoom)
//	|					OR &qIsEmptyRoom)
//	|			AND (Reservations.КвотаНомеров IN HIERARCHY (&qRoomQuota)
//	|					OR &qIsEmptyRoomQuota)
//	|			AND (Reservations.ТипНомера IN HIERARCHY (&qRoomType)
//	|					OR &qIsEmptyRoomType)
//	|			AND Reservations.ПериодС = Reservations.Period
//	|			AND Reservations.CheckInDate <= &qPeriodTo
//	|			AND Reservations.CheckOutDate > &qPeriodTo
//	|			AND Reservations.ПериодС <= &qPeriodTo
//	|			AND (Reservations.ПериодПо > &qPeriodTo
//	|					OR Reservations.ПериодПо = &qEmptyDate)
//	|		
//	|		UNION ALL
//	|		
//	|		SELECT
//	|			Accommodations.Гостиница,
//	|			Accommodations.СтатусРазмещения,
//	|			Accommodations.НомерРазмещения,
//	|			Accommodations.Контрагент,
//	|			Accommodations.Договор,
//	|			Accommodations.ГруппаГостей,
//	|			Accommodations.Клиент,
//	|			Accommodations.ПериодС,
//	|			Accommodations.PeriodDuration,
//	|			Accommodations.ПериодПо,
//	|			Accommodations.ТипНомера,
//	|			Accommodations.ВидРазмещения,
//	|			Accommodations.КвотаНомеров,
//	|			Accommodations.Примечания,
//	|			Accommodations.Recorder,
//	|			FALSE,
//	|			FALSE,
//	|			FALSE,
//	|			FALSE,
//	|			TRUE,
//	|			-Accommodations.RoomsVacant,
//	|			-Accommodations.BedsVacant
//	|		FROM
//	|			AccumulationRegister.ЗагрузкаНомеров AS Accommodations
//	|		WHERE
//	|			Accommodations.RecordType = VALUE(AccumulationRecordType.Expense)
//	|			AND Accommodations.IsAccommodation
//	|			AND (Accommodations.Гостиница IN HIERARCHY (&qHotel)
//	|					OR &qIsEmptyHotel)
//	|			AND (Accommodations.НомерРазмещения IN HIERARCHY (&qRoom)
//	|					OR &qIsEmptyRoom)
//	|			AND (Accommodations.КвотаНомеров IN HIERARCHY (&qRoomQuota)
//	|					OR &qIsEmptyRoomQuota)
//	|			AND (Accommodations.ТипНомера IN HIERARCHY (&qRoomType)
//	|					OR &qIsEmptyRoomType)
//	|			AND Accommodations.ПериодС = Accommodations.Period
//	|			AND Accommodations.CheckInDate <= &qPeriodTo
//	|			AND Accommodations.CheckOutDate > &qPeriodTo
//	|			AND Accommodations.ПериодС <= &qPeriodTo
//	|			AND (Accommodations.ПериодПо > &qPeriodTo
//	|					OR Accommodations.ПериодПо = &qEmptyDate)) AS RoomInventoryMovements) AS ЗагрузкаНомеров
//	|{WHERE
//	|	ЗагрузкаНомеров.Гостиница.*,
//	|	ЗагрузкаНомеров.Status.*,
//	|	ЗагрузкаНомеров.НомерРазмещения.*,
//	|	ЗагрузкаНомеров.Контрагент.*,
//	|	ЗагрузкаНомеров.Договор.*,
//	|	ЗагрузкаНомеров.ГруппаГостей.*,
//	|	ЗагрузкаНомеров.Клиент.*,
//	|	ЗагрузкаНомеров.CheckInDate,
//	|	ЗагрузкаНомеров.Продолжительность,
//	|	ЗагрузкаНомеров.CheckOutDate,
//	|	ЗагрузкаНомеров.ТипНомера.*,
//	|	ЗагрузкаНомеров.ВидРазмещения.*,
//	|	ЗагрузкаНомеров.КвотаНомеров.*,
//	|	ЗагрузкаНомеров.Примечания,
//	|	ЗагрузкаНомеров.Recorder.*,
//	|	ЗагрузкаНомеров.IsRoomInventory,
//	|	ЗагрузкаНомеров.IsBlocking,
//	|	ЗагрузкаНомеров.IsRoomQuota,
//	|	ЗагрузкаНомеров.IsReservation,
//	|	ЗагрузкаНомеров.IsAccommodation,
//	|	ЗагрузкаНомеров.RoomsVacant,
//	|	ЗагрузкаНомеров.BedsVacant}
//	|
//	|ORDER BY
//	|	Гостиница,
//	|	IsRoomInventory DESC,
//	|	IsBlocking DESC,
//	|	IsRoomQuota DESC,
//	|	IsReservation DESC,
//	|	IsAccommodation DESC,
//	|	Контрагент,
//	|	НомерРазмещения,
//	|	CheckInDate,
//	|	Клиент
//	|{ORDER BY
//	|	Гостиница.*,
//	|	Status.*,
//	|	НомерРазмещения.*,
//	|	Контрагент.*,
//	|	Договор.*,
//	|	ГруппаГостей.*,
//	|	Клиент.*,
//	|	CheckInDate,
//	|	Продолжительность,
//	|	CheckOutDate,
//	|	ТипНомера.*,
//	|	ВидРазмещения.*,
//	|	КвотаНомеров.*,
//	|	Примечания,
//	|	Recorder.*,
//	|	IsRoomInventory,
//	|	IsBlocking,
//	|	IsRoomQuota,
//	|	IsReservation,
//	|	IsAccommodation,
//	|	RoomsVacant,
//	|	BedsVacant}
//	|TOTALS
//	|	SUM(RoomsVacant),
//	|	SUM(BedsVacant)
//	|BY
//	|	OVERALL,
//	|	Контрагент
//	|{TOTALS BY
//	|	Гостиница.*,
//	|	Status.*,
//	|	НомерРазмещения.*,
//	|	Контрагент.*,
//	|	Договор.*,
//	|	ГруппаГостей.*,
//	|	Клиент.*,
//	|	ТипНомера.*,
//	|	КвотаНомеров.*,
//	|	Recorder.*,
//	|	IsRoomInventory,
//	|	IsBlocking,
//	|	IsRoomQuota,
//	|	IsReservation,
//	|	IsAccommodation}";
//	ReportBuilder.Text = QueryText;
//	ReportBuilder.FillSettings();
//	// Initialize report builder with default query
//	vRB = New ReportBuilder(QueryText);
//	vRBSettings = vRB.GetSettings(True, True, True, True, True);
//	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
//	
//	// Set default report builder header text
//	ReportBuilder.HeaderText = NStr("EN='ГруппаНомеров inventory';RU='Загрузка номеров';de='Laden von Zimmern'");
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
