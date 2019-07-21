//-----------------------------------------------------------------------------
// Reports framework start
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Initialize attributes with default values
// Attention: This procedure could be called AFTER some attributes initialization
// routine, so it SHOULD NOT reset attributes being set before
//-----------------------------------------------------------------------------
Процедура pmFillAttributesWithDefaultValues() Экспорт
	// Fill parameters with default values
	If НЕ ЗначениеЗаполнено(Гостиница) Тогда
		Гостиница = ПараметрыСеанса.ТекущаяГостиница;
	EndIf;
	If НЕ ЗначениеЗаполнено(PeriodTo) Тогда
		PeriodTo = EndOfDay(CurrentDate()); // End of today
	EndIf;
КонецПроцедуры //pmFillAttributesWithDefaultValues

//-----------------------------------------------------------------------------
Function pmGetReportParametersPresentation() Экспорт
	vParamPresentation = "";
	If ЗначениеЗаполнено(Гостиница) Тогда
		If НЕ Гостиница.IsFolder Тогда
			vParamPresentation = vParamPresentation + NStr("en='Гостиница ';ru='Гостиница ';de='Гостиница'") + 
			                     Гостиница.GetObject().pmGetHotelPrintName(ПараметрыСеанса.ТекЛокализация) + 
			                     ";" + Chars.LF;
		Else
			vParamPresentation = vParamPresentation + NStr("en='Hotels folder ';ru='Группа гостиниц ';de='Gruppe Hotels '") + 
			                     Гостиница.GetObject().pmGetHotelPrintName(ПараметрыСеанса.ТекЛокализация) + 
			                     ";" + Chars.LF;
		EndIf;
	EndIf;
	If НЕ ЗначениеЗаполнено(PeriodTo) Тогда
		vParamPresentation = vParamPresentation + NStr("en='Report period is not set';ru='Период отчета не установлен';de='Berichtszeitraum nicht festgelegt'") + 
		                     ";" + Chars.LF;
	Else
		vParamPresentation = vParamPresentation + NStr("ru = 'На дату и время '; en = 'Period '") + 
		                     Format(PeriodTo, "DF='dd.MM.yyyy HH:mm:ss'") + 
		                     ";" + Chars.LF;
	EndIf;
	If ЗначениеЗаполнено(Room) Тогда
		If НЕ Room.IsFolder Тогда
			vParamPresentation = vParamPresentation + NStr("en='ГруппаНомеров ';ru='Номер ';de='Zimmer'") + 
			                     TrimAll(Room.Description) + 
			                     ";" + Chars.LF;
		Else
			vParamPresentation = vParamPresentation + NStr("en='Rooms folder ';ru='Группа номеров ';de='Gruppe Zimmer '") + 
			                     TrimAll(Room.Description) + 
			                     ";" + Chars.LF;
		EndIf;
	EndIf;
	If ЗначениеЗаполнено(RoomType) Тогда
		If НЕ RoomType.IsFolder Тогда
			vParamPresentation = vParamPresentation + NStr("en='ГруппаНомеров type ';ru='Тип номера ';de='Zimmertyp'") + 
			                     TrimAll(RoomType.Description) + 
			                     ";" + Chars.LF;
		Else
			vParamPresentation = vParamPresentation + NStr("en='ГруппаНомеров types folder ';ru='Группа типов номеров ';de='Gruppe Zimmertypen'") + 
			                     TrimAll(RoomType.Description) + 
			                     ";" + Chars.LF;
		EndIf;
	EndIf;
	If DoNotShowReservations Тогда
		vParamPresentation = vParamPresentation + NStr("en='Without reservations';ru='Без брони';de='Ohne Buchung'") + 
							 ";" + Chars.LF;
	EndIf;
	Return vParamPresentation;
EndFunction //pmGetReportParametersPresentation

//-----------------------------------------------------------------------------
// Runs report and returns if report form should be shown
//-----------------------------------------------------------------------------
Процедура pmGenerate(pSpreadsheet) Экспорт
	
	
	// Reset report builder template
	ReportBuilder.Template = Неопределено;
	
	// Initialize report builder query generator attributes
	ReportBuilder.PresentationAdding = PresentationAdditionType.Add;
	
	// Fill report parameters
	ReportBuilder.Parameters.Вставить("qHotel", Гостиница);
	ReportBuilder.Parameters.Вставить("qPeriodTo", PeriodTo);
	ReportBuilder.Parameters.Вставить("qRoom", Room);
	ReportBuilder.Parameters.Вставить("qRoomType", RoomType);
	ReportBuilder.Parameters.Вставить("qEmptyDate", '00010101');
	ReportBuilder.Parameters.Вставить("qExpense", AccumulationRecordType.Expense);
	ReportBuilder.Parameters.Вставить("qIsEmptyHotel", НЕ ЗначениеЗаполнено(Гостиница));
	ReportBuilder.Parameters.Вставить("qIsEmptyRoomType", НЕ ЗначениеЗаполнено(RoomType));
	ReportBuilder.Parameters.Вставить("qIsEmptyRoom", НЕ ЗначениеЗаполнено(Room));
	ReportBuilder.Parameters.Вставить("qDoNotShowReservations", DoNotShowReservations);

	// Execute report builder query
	ReportBuilder.Execute();
	
	// Apply appearance settings to the report template
	//vTemplateAttributes = cmApplyReportTemplateAppearance(ThisObject);
	
	// Output report to the spreadsheet
	ReportBuilder.Put(pSpreadsheet);
	//ReportBuilder.Template.Show(); // For debug purpose

	// Apply appearance settings to the report spreadsheet
	//cmApplyReportAppearance(ThisObject, pSpreadsheet, vTemplateAttributes);
		
	// Apply number of pages to be printed on the one paper sheet
	//cmApplyReportMultiplePages(ThisObject, pSpreadsheet)
КонецПроцедуры //pmGenerate

//-----------------------------------------------------------------------------
Процедура pmInitializeReportBuilder() Экспорт
	ReportBuilder = New ReportBuilder();
	
	// Initialize default query text
	QueryText = 
	"SELECT
	|	Accommodations.Гостиница AS Гостиница,
	|	Accommodations.НомерРазмещения AS НомерРазмещения,
	|	Accommodations.ТипНомера AS ТипНомера,
	|	Accommodations.Document AS Document,
	|	Accommodations.ДокОснование AS ДокОснование,
	|	Accommodations.Клиент AS Клиент,
	|	Accommodations.CheckInDate AS CheckInDate,
	|	Accommodations.CheckOutDate AS CheckOutDate,
	|	Accommodations.ВидРазмещения AS ВидРазмещения,
	|	Accommodations.Status AS Status,
	|	Accommodations.ГруппаГостей AS ГруппаГостей,
	|	Accommodations.Агент AS Агент,
	|	Accommodations.Контрагент AS Контрагент,
	|	Accommodations.Договор AS Договор,
	|	Accommodations.КонтактноеЛицо AS КонтактноеЛицо,
	|	Accommodations.PlannedPaymentMethod AS PlannedPaymentMethod,
	|	Accommodations.Примечания AS Примечания,
	|	Accommodations.IsAccommodation AS IsAccommodation,
	|	Accommodations.IsReservation AS IsReservation,
	|	Accommodations.IsBlocking AS IsBlocking,
	|	1 AS RoomsCount
	|{SELECT
	|	Гостиница.*,
	|	НомерРазмещения.*,
	|	ТипНомера.*,
	|	Status.*,
	|	Клиент.*,
	|	CheckInDate,
	|	CheckOutDate,
	|	ВидРазмещения.*,
	|	PlannedPaymentMethod.*,
	|	Агент.*,
	|	Контрагент.*,
	|	Договор.*,
	|	ГруппаГостей.*,
	|	КонтактноеЛицо,
	|	Примечания,
	|	Document.*,
	|	ДокОснование.*,
	|	IsAccommodation,
	|	IsReservation,
	|	IsBlocking,
	|	RoomsCount}
	|FROM
	|	(SELECT
	|		RoomInventoryBalance.Гостиница AS Гостиница,
	|		RoomInventoryBalance.НомерРазмещения AS НомерРазмещения,
	|		RoomInventoryBalance.ТипНомера AS ТипНомера,
	|		RoomInventoryBalance.TotalRoomsBalance AS TotalRoomsBalance,
	|		RoomInventoryBalance.TotalBedsBalance AS TotalBedsBalance,
	|		Documents.Document AS Document,
	|		Documents.Status AS Status,
	|		Documents.ДокОснование AS ДокОснование,
	|		Documents.Клиент AS Клиент,
	|		Documents.CheckInDate AS CheckInDate,
	|		Documents.CheckOutDate AS CheckOutDate,
	|		Documents.ВидРазмещения AS ВидРазмещения,
	|		Documents.Агент AS Агент,
	|		Documents.Контрагент AS Контрагент,
	|		Documents.Договор AS Договор,
	|		Documents.ГруппаГостей AS ГруппаГостей,
	|		Documents.PlannedPaymentMethod AS PlannedPaymentMethod,
	|		Documents.КонтактноеЛицо AS КонтактноеЛицо,
	|		Documents.Примечания AS Примечания,
	|		Documents.IsAccommodation AS IsAccommodation,
	|		Documents.IsReservation AS IsReservation,
	|		Documents.IsBlocking AS IsBlocking
	|	FROM
	|		AccumulationRegister.ЗагрузкаНомеров.Balance(
	|				&qPeriodTo,
	|				(Гостиница IN HIERARCHY (&qHotel)
	|					OR &qIsEmptyHotel)
	|					AND (ТипНомера IN HIERARCHY (&qRoomType)
	|						OR &qIsEmptyRoomType)
	|					AND (НомерРазмещения IN HIERARCHY (&qRoom)
	|						OR &qIsEmptyRoom)) AS RoomInventoryBalance
	|			LEFT JOIN (SELECT
	|				AccommodationDocs.Recorder AS Document,
	|				AccommodationDocs.НомерРазмещения AS НомерРазмещения,
	|				AccommodationDocs.СтатусРазмещения AS Status,
	|				AccommodationDocs.ДокОснование AS ДокОснование,
	|				AccommodationDocs.Клиент AS Клиент,
	|				AccommodationDocs.ПериодС AS CheckInDate,
	|				AccommodationDocs.ПериодПо AS CheckOutDate,
	|				AccommodationDocs.ВидРазмещения AS ВидРазмещения,
	|				AccommodationDocs.Агент AS Агент,
	|				AccommodationDocs.Контрагент AS Контрагент,
	|				AccommodationDocs.Договор AS Договор,
	|				AccommodationDocs.ГруппаГостей AS ГруппаГостей,
	|				AccommodationDocs.PlannedPaymentMethod AS PlannedPaymentMethod,
	|				AccommodationDocs.КонтактноеЛицо AS КонтактноеЛицо,
	|				AccommodationDocs.Примечания AS Примечания,
	|				TRUE AS IsAccommodation,
	|				FALSE AS IsReservation,
	|				FALSE AS IsBlocking
	|			FROM
	|				AccumulationRegister.ЗагрузкаНомеров AS AccommodationDocs
	|			WHERE
	|				AccommodationDocs.IsAccommodation = TRUE
	|				AND AccommodationDocs.RecordType = VALUE(AccumulationRecordType.Expense)
	|				AND AccommodationDocs.ЭтоГости = TRUE
	|				AND AccommodationDocs.ПериодС <= &qPeriodTo
	|				AND AccommodationDocs.ПериодПо > &qPeriodTo
	|			
	|			UNION ALL
	|			
	|			SELECT
	|				ReservationDocs.Recorder,
	|				ReservationDocs.НомерРазмещения,
	|				ReservationDocs.ReservationStatus,
	|				ReservationDocs.ДокОснование,
	|				ReservationDocs.Клиент,
	|				ReservationDocs.ПериодС,
	|				ReservationDocs.ПериодПо,
	|				ReservationDocs.ВидРазмещения,
	|				ReservationDocs.Агент,
	|				ReservationDocs.Контрагент,
	|				ReservationDocs.Договор,
	|				ReservationDocs.ГруппаГостей,
	|				ReservationDocs.PlannedPaymentMethod,
	|				ReservationDocs.КонтактноеЛицо,
	|				ReservationDocs.Примечания,
	|				FALSE,
	|				TRUE,
	|				FALSE
	|			FROM
	|				AccumulationRegister.ЗагрузкаНомеров AS ReservationDocs
	|			WHERE
	|				ReservationDocs.IsReservation = TRUE
	|				AND ReservationDocs.RecordType = VALUE(AccumulationRecordType.Expense)
	|				AND NOT &qDoNotShowReservations
	|			
	|			UNION ALL
	|			
	|			SELECT
	|				БлокирНомеров.Recorder,
	|				БлокирНомеров.НомерРазмещения,
	|				БлокирНомеров.RoomBlockType,
	|				NULL,
	|				NULL,
	|				БлокирНомеров.CheckInDate,
	|				БлокирНомеров.CheckOutDate,
	|				NULL,
	|				NULL,
	|				NULL,
	|				NULL,
	|				NULL,
	|				NULL,
	|				NULL,
	|				БлокирНомеров.Примечания,
	|				FALSE,
	|				FALSE,
	|				TRUE
	|			FROM
	|				AccumulationRegister.ЗагрузкаНомеров AS БлокирНомеров
	|			WHERE
	|				БлокирНомеров.RecordType = &qExpense
	|				AND БлокирНомеров.IsBlocking = TRUE
	|				AND БлокирНомеров.CheckInDate <= &qPeriodTo
	|				AND (БлокирНомеров.CheckOutDate > &qPeriodTo
	|						OR БлокирНомеров.CheckOutDate = &qEmptyDate)) AS Documents
	|			ON RoomInventoryBalance.НомерРазмещения = Documents.НомерРазмещения
	|				AND (RoomInventoryBalance.TotalRoomsBalance > 0)) AS Accommodations
	|{WHERE
	|	Accommodations.Гостиница.*,
	|	Accommodations.НомерРазмещения.*,
	|	Accommodations.ТипНомера.*,
	|	Accommodations.Document.*,
	|	Accommodations.ДокОснование.*,
	|	Accommodations.Клиент.*,
	|	Accommodations.CheckInDate,
	|	Accommodations.CheckOutDate,
	|	Accommodations.ВидРазмещения.*,
	|	Accommodations.Status.*,
	|	Accommodations.Агент.*,
	|	Accommodations.Контрагент.*,
	|	Accommodations.Договор.*,
	|	Accommodations.ГруппаГостей.*,
	|	Accommodations.PlannedPaymentMethod.*,
	|	Accommodations.КонтактноеЛицо,
	|	Accommodations.Примечания,
	|	Accommodations.IsAccommodation,
	|	Accommodations.IsReservation,
	|	Accommodations.IsBlocking}
	|
	|ORDER BY
	|	Гостиница,
	|	НомерРазмещения,
	|	CheckInDate,
	|	Клиент
	|{ORDER BY
	|	Гостиница.*,
	|	НомерРазмещения.*,
	|	CheckInDate,
	|	Клиент.*,
	|	ТипНомера.*,
	|	Document.*,
	|	ДокОснование.*,
	|	CheckOutDate,
	|	ВидРазмещения.*,
	|	Status.*,
	|	Агент.*,
	|	Контрагент.*,
	|	Договор.*,
	|	ГруппаГостей.*,
	|	PlannedPaymentMethod.*,
	|	КонтактноеЛицо,
	|	Remarks}
	|TOTALS
	|	SUM(RoomsCount)
	|BY
	|	OVERALL,
	|	Гостиница,
	|	НомерРазмещения
	|{TOTALS BY
	|	Гостиница,
	|	НомерРазмещения.*,
	|	Агент.*,
	|	Контрагент.*,
	|	Договор.*,
	|	ГруппаГостей.*,
	|	ТипНомера.*,
	|	Status,
	|	PlannedPaymentMethod}";
	ReportBuilder.Text = QueryText;
	ReportBuilder.FillSettings();
	
	// Initialize report builder with default query
	vRB = New ReportBuilder(QueryText);
	vRBSettings = vRB.GetSettings(True, True, True, True, True);
	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
	
	// Set default report builder header text
	ReportBuilder.HeaderText = NStr("en='State of all rooms';ru='Шахматка';de='Schachbretttabelle'");
	
	// Fill report builder fields presentations from the report template
	//cmFillReportAttributesPresentations(ThisObject);
	
	// Reset report builder template
	ReportBuilder.Template = Неопределено;
КонецПроцедуры //pmInitializeReportBuilder

//-----------------------------------------------------------------------------
// Reports framework end
//-----------------------------------------------------------------------------
