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
//	vParamPresentation = vParamPresentation + NStr("en='Blocks in rooms for the period selected';ru='Отбор блокировок пересекающихся с выбранным периодом';de='Auswahl der sich mit dem ausgewählten Zeitraum überschneidenden Blockierungen'") + 
//						 ";" + Chars.LF;
//	If ЗначениеЗаполнено(RoomBlockType) Тогда
//		If НЕ RoomBlockType.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("ru = 'Тип блокировки '; en = 'ГруппаНомеров block type '") + 
//			                     TrimAll(RoomBlockType.Description) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("ru = 'Группа типов блокировок '; en = 'ГруппаНомеров block types folder '") + 
//			                     TrimAll(RoomBlockType.Description) + 
//			                     ";" + Chars.LF;
//		EndIf;
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
//	ReportBuilder.Parameters.Вставить("qRoomBlockType", RoomBlockType);
//	ReportBuilder.Parameters.Вставить("qRoomType", RoomType);
//	ReportBuilder.Parameters.Вставить("qIsEmptyRoomType", НЕ ЗначениеЗаполнено(RoomType));
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
////	cmApplyReportAppearance(ThisObject, pSpreadsheet, vTemplateAttributes);
//КонецПроцедуры //pmGenerate
//
////-----------------------------------------------------------------------------
//Процедура pmInitializeReportBuilder() Экспорт
//	ReportBuilder = New ReportBuilder();
//	
//	// Initialize default query text
//	QueryText = 
//	"SELECT
//	|	Accommodations.Клиент AS AccommodationGuest,
//	|	Accommodations.CheckInDate AS AccommodationCheckInDate,
//	|	Accommodations.CheckOutDate AS AccommodationCheckOutDate,
//	|	ЗагрузкаНомеров.Гостиница AS Гостиница,
//	|	ЗагрузкаНомеров.RoomBlockType AS RoomBlockType,
//	|	ЗагрузкаНомеров.НомерРазмещения AS НомерРазмещения,
//	|	ЗагрузкаНомеров.CheckInDate AS CheckInDate,
//	|	ЗагрузкаНомеров.Продолжительность AS Продолжительность,
//	|	ЗагрузкаНомеров.CheckOutDate AS CheckOutDate,
//	|	ЗагрузкаНомеров.IsFinished AS IsFinished,
//	|	ЗагрузкаНомеров.Примечания AS Примечания,
//	|	ЗагрузкаНомеров.Recorder AS Recorder,
//	|	1 AS GuestsCount
//	|{SELECT
//	|	Гостиница.* AS Гостиница,
//	|	RoomBlockType.* AS RoomBlockType,
//	|	НомерРазмещения.* AS НомерРазмещения,
//	|	ЗагрузкаНомеров.ТипНомера.* AS ТипНомера,
//	|	CheckInDate AS CheckInDate,
//	|	Продолжительность AS Продолжительность,
//	|	CheckOutDate AS CheckOutDate,
//	|	IsFinished AS IsFinished,
//	|	Примечания AS Примечания,
//	|	ЗагрузкаНомеров.Автор.* AS Автор,
//	|	Recorder.* AS Recorder,
//	|	AccommodationGuest.*,
//	|	AccommodationCheckInDate,
//	|	AccommodationCheckOutDate,
//	|	Accommodations.Размещение.* AS Размещение,
//	|	ЗагрузкаНомеров.PointInTime AS PointInTime,
//	|	ЗагрузкаНомеров.Period AS Period,
//	|	ЗагрузкаНомеров.CheckInAccountingDate AS CheckInAccountingDate,
//	|	ЗагрузкаНомеров.CheckOutAccountingDate AS CheckOutAccountingDate,
//	|	(HOUR(ЗагрузкаНомеров.CheckInDate)) AS CheckInHour,
//	|	(DAY(ЗагрузкаНомеров.CheckInDate)) AS CheckInDay,
//	|	(WEEK(ЗагрузкаНомеров.CheckInDate)) AS CheckInWeek,
//	|	(MONTH(ЗагрузкаНомеров.CheckInDate)) AS CheckInMonth,
//	|	(QUARTER(ЗагрузкаНомеров.CheckInDate)) AS CheckInQuarter,
//	|	(YEAR(ЗагрузкаНомеров.CheckInDate)) AS CheckInYear,
//	|	ЗагрузкаНомеров.ЗаблокНомеров AS ЗаблокНомеров,
//	|	ЗагрузкаНомеров.ЗаблокМест AS ЗаблокМест,
//	|	GuestsCount}
//	|FROM
//	|	AccumulationRegister.ЗагрузкаНомеров AS RoomInventory
//	|		LEFT JOIN (SELECT
//	|			Размещение.Клиент AS Клиент,
//	|			Размещение.НомерРазмещения AS AccommodationRoom,
//	|			Размещение.ПериодС AS CheckInDate,
//	|			Размещение.ПериодПо AS CheckOutDate,
//	|			Размещение.Recorder AS Размещение
//	|		FROM
//	|			AccumulationRegister.ЗагрузкаНомеров AS Размещение
//	|		WHERE
//	|			Размещение.IsAccommodation = TRUE
//	|			AND Размещение.Гостиница IN HIERARCHY(&qHotel)
//	|			AND Размещение.НомерРазмещения IN HIERARCHY(&qRoom)
//	|			AND (Размещение.ТипНомера IN HIERARCHY (&qRoomType)
//	|					OR &qIsEmptyRoomType)
//	|			AND Размещение.RecordType = VALUE(AccumulationRecordType.Expense)) AS Accommodations
//	|		ON ЗагрузкаНомеров.НомерРазмещения = Accommodations.AccommodationRoom
//	|			AND (Accommodations.CheckInDate < &qPeriodTo)
//	|			AND (Accommodations.CheckOutDate > &qPeriodFrom)
//	|			AND (Accommodations.CheckInDate < ЗагрузкаНомеров.ПериодПо
//	|				OR ЗагрузкаНомеров.ПериодПо = &qEmptyDate)
//	|			AND (Accommodations.CheckOutDate > ЗагрузкаНомеров.ПериодС)
//	|WHERE
//	|	ЗагрузкаНомеров.RecordType = VALUE(AccumulationRecordType.Expense)
//	|	AND ЗагрузкаНомеров.IsBlocking = TRUE
//	|	AND ЗагрузкаНомеров.Гостиница IN HIERARCHY(&qHotel)
//	|	AND ЗагрузкаНомеров.НомерРазмещения IN HIERARCHY(&qRoom)
//	|	AND (ЗагрузкаНомеров.ТипНомера IN HIERARCHY (&qRoomType)
//	|			OR &qIsEmptyRoomType)
//	|	AND ЗагрузкаНомеров.RoomBlockType IN HIERARCHY(&qRoomBlockType)
//	|	AND ЗагрузкаНомеров.ПериодС < &qPeriodTo
//	|	AND (ЗагрузкаНомеров.ПериодПо > &qPeriodFrom
//	|			OR ЗагрузкаНомеров.ПериодПо = &qEmptyDate)
//	|{WHERE
//	|	ЗагрузкаНомеров.Гостиница,
//	|	ЗагрузкаНомеров.ТипНомера,
//	|	ЗагрузкаНомеров.НомерРазмещения,
//	|	ЗагрузкаНомеров.RoomBlockType.*,
//	|	ЗагрузкаНомеров.CheckInDate,
//	|	ЗагрузкаНомеров.Продолжительность,
//	|	ЗагрузкаНомеров.CheckOutDate,
//	|	Accommodations.Клиент.* AS AccommodationGuest,
//	|	Accommodations.CheckInDate AS AccommodationCheckInDate,
//	|	Accommodations.CheckOutDate AS AccommodationCheckOutDate,
//	|	Accommodations.Размещение.* AS Размещение,
//	|	ЗагрузкаНомеров.CheckInAccountingDate,
//	|	ЗагрузкаНомеров.CheckOutAccountingDate,
//	|	ЗагрузкаНомеров.Period,
//	|	ЗагрузкаНомеров.IsFinished,
//	|	ЗагрузкаНомеров.Примечания,
//	|	ЗагрузкаНомеров.Автор.*,
//	|	ЗагрузкаНомеров.Recorder.*,
//	|	ЗагрузкаНомеров.ЗаблокМест,
//	|	ЗагрузкаНомеров.RoomsBlocked}
//	|
//	|ORDER BY
//	|	Гостиница,
//	|	RoomBlockType,
//	|	НомерРазмещения,
//	|	CheckInDate
//	|{ORDER BY
//	|	Гостиница.*,
//	|	ЗагрузкаНомеров.ТипНомера.*,
//	|	НомерРазмещения.*,
//	|	RoomBlockType.*,
//	|	CheckInDate,
//	|	Продолжительность,
//	|	CheckOutDate,
//	|	AccommodationGuest.*,
//	|	AccommodationCheckInDate,
//	|	AccommodationCheckOutDate,
//	|	Accommodations.Размещение.* AS Размещение,
//	|	IsFinished,
//	|	Примечания,
//	|	ЗагрузкаНомеров.Автор.*,
//	|	ЗагрузкаНомеров.CheckInAccountingDate,
//	|	ЗагрузкаНомеров.CheckOutAccountingDate,
//	|	(HOUR(ЗагрузкаНомеров.CheckInDate)) AS CheckInHour,
//	|	(DAY(ЗагрузкаНомеров.CheckInDate)) AS CheckInDay,
//	|	(WEEK(ЗагрузкаНомеров.CheckInDate)) AS CheckInWeek,
//	|	(MONTH(ЗагрузкаНомеров.CheckInDate)) AS CheckInMonth,
//	|	(QUARTER(ЗагрузкаНомеров.CheckInDate)) AS CheckInQuarter,
//	|	(YEAR(ЗагрузкаНомеров.CheckInDate)) AS CheckInYear,
//	|	ЗагрузкаНомеров.PointInTime,
//	|	ЗагрузкаНомеров.Period,
//	|	Recorder.*,
//	|	ЗагрузкаНомеров.ЗаблокНомеров AS ЗаблокНомеров,
//	|	ЗагрузкаНомеров.ЗаблокМест AS BedsBlocked}
//	|TOTALS
//	|	SUM(GuestsCount)
//	|BY
//	|	OVERALL,
//	|	Гостиница,
//	|	RoomBlockType,
//	|	НомерРазмещения
//	|{TOTALS BY
//	|	Гостиница,
//	|	RoomBlockType.*,
//	|	НомерРазмещения,
//	|	ЗагрузкаНомеров.ТипНомера,
//	|	AccommodationGuest.*,
//	|	Accommodations.Размещение.* AS Размещение,
//	|	ЗагрузкаНомеров.CheckInAccountingDate,
//	|	ЗагрузкаНомеров.CheckOutAccountingDate,
//	|	(HOUR(ЗагрузкаНомеров.CheckInDate)) AS CheckInHour,
//	|	(DAY(ЗагрузкаНомеров.CheckInDate)) AS CheckInDay,
//	|	(WEEK(ЗагрузкаНомеров.CheckInDate)) AS CheckInWeek,
//	|	(MONTH(ЗагрузкаНомеров.CheckInDate)) AS CheckInMonth,
//	|	(QUARTER(ЗагрузкаНомеров.CheckInDate)) AS CheckInQuarter,
//	|	(YEAR(ЗагрузкаНомеров.CheckInDate)) AS CheckInYear,
//	|	Recorder.*,
//	|	ЗагрузкаНомеров.Автор.*}";
//	ReportBuilder.Text = QueryText;
//	ReportBuilder.FillSettings();
//	
//	// Initialize report builder with default query
//	vRB = New ReportBuilder(QueryText);
//	vRBSettings = vRB.GetSettings(True, True, True, True, True);
//	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
//	
//	// Set default report builder header text
//	ReportBuilder.HeaderText = NStr("EN='Guests in blocked rooms';RU='Гости в заблокированных номерах';de='Gäste in blockierten Zimmern'");
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
