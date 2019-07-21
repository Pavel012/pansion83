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
//		PeriodFrom = BegOfMonth(CurrentDate()); // For beg of month
//		PeriodTo = EndOfDay(CurrentDate());
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
//Процедура pmGenerate(pSpreadsheet, pAddChart = False) Экспорт
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
//	ReportBuilder.Parameters.Вставить("qRoomType", RoomType);
//	ReportBuilder.Parameters.Вставить("qIsEmptyRoomType", НЕ ЗначениеЗаполнено(RoomType));
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
//	
//	// Add chart 
//	If pAddChart Тогда
//		cmAddReportChart(pSpreadsheet, ThisObject);
//	EndIf;
//КонецПроцедуры //pmGenerate
//	
////-----------------------------------------------------------------------------
//Процедура pmInitializeReportBuilder() Экспорт
//	ReportBuilder = New ReportBuilder();
//	
//	// Initialize default query text
//	QueryText = 
//	"SELECT
//	|	PlanFact.CheckInDay AS CheckInDay,
//	|	PlanFact.ЗаездНомеров AS ЗаездНомеров,
//	|	PlanFact.ЗаездМест AS ЗаездМест,
//	|	PlanFact.ЗаездДополнительныхМест AS ЗаездДополнительныхМест,
//	|	PlanFact.ЗаездГостей AS ЗаездГостей,
//	|	PlanFact.ЗабронГостей AS ЗабронГостей,
//	|	PlanFact.ЗабронНомеров AS ЗабронНомеров,
//	|	PlanFact.ЗабронированоМест AS ЗабронированоМест,
//	|	PlanFact.ЗабронДопМест AS ЗабронДопМест,
//	|	PlanFact.ЗабронГостей - PlanFact.ЗаездГостей AS NoShowGuests,
//	|	PlanFact.ЗабронНомеров - PlanFact.ЗаездНомеров AS NoShowRooms,
//	|	PlanFact.ЗабронированоМест - PlanFact.ЗаездМест AS NoShowBeds,
//	|	PlanFact.ЗабронДопМест - PlanFact.ЗаездДополнительныхМест AS NoShowAdditionalBeds
//	|{SELECT
//	|	CheckInDay,
//	|	PlanFact.CheckInWeek,
//	|	PlanFact.CheckInMonth,
//	|	PlanFact.CheckInQuarter,
//	|	PlanFact.CheckInYear,
//	|	PlanFact.Гостиница.*,
//	|	PlanFact.ТипНомера.*,
//	|	PlanFact.Reservation.*,
//	|	PlanFact.ReservationStatus.*,
//	|	PlanFact.Размещение.*,
//	|	PlanFact.СтатусРазмещения.*,
//	|	PlanFact.Контрагент.*,
//	|	PlanFact.Договор.*,
//	|	PlanFact.ГруппаГостей.*,
//	|	PlanFact.Агент.*,
//	|	PlanFact.Клиент.*,
//	|	PlanFact.Тариф.*,
//	|	PlanFact.ВидРазмещения.*,
//	|	PlanFact.ДокОснование.*,
//	|	ЗаездНомеров,
//	|	ЗаездМест,
//	|	ЗаездДополнительныхМест,
//	|	ЗаездГостей,
//	|	ЗабронГостей,
//	|	ЗабронНомеров,
//	|	ЗабронированоМест,
//	|	ЗабронДопМест,
//	|	NoShowGuests,
//	|	NoShowRooms,
//	|	NoShowBeds,
//	|	NoShowAdditionalBeds}
//	|FROM
//	|	(SELECT
//	|		BEGINOFPERIOD(Размещение.CheckInDate, DAY) AS CheckInDay,
//	|		WEEK(Размещение.CheckInDate) AS CheckInWeek,
//	|		MONTH(Размещение.CheckInDate) AS CheckInMonth,
//	|		QUARTER(Размещение.CheckInDate) AS CheckInQuarter,
//	|		YEAR(Размещение.CheckInDate) AS CheckInYear,
//	|		Размещение.Гостиница AS Гостиница,
//	|		Размещение.ТипНомера AS ТипНомера,
//	|		Размещение.Reservation AS Reservation,
//	|		Размещение.Recorder AS Размещение,
//	|		Размещение.ДокОснование AS ДокОснование,
//	|		Размещение.Reservation.ReservationStatus AS ReservationStatus,
//	|		Размещение.СтатусРазмещения AS СтатусРазмещения,
//	|		Размещение.Контрагент AS Контрагент,
//	|		Размещение.Договор AS Договор,
//	|		Размещение.ГруппаГостей AS ГруппаГостей,
//	|		Размещение.Агент AS Агент,
//	|		Размещение.Клиент AS Клиент,
//	|		Размещение.Тариф AS Тариф,
//	|		Размещение.ВидРазмещения AS ВидРазмещения,
//	|		SUM(Размещение.КоличествоЧеловек) AS ЗаездГостей,
//	|		SUM(Размещение.КоличествоНомеров) AS ЗаездНомеров,
//	|		SUM(Размещение.КоличествоМест) AS ЗаездМест,
//	|		SUM(Размещение.КолДопМест) AS ЗаездДополнительныхМест,
//	|		0 AS ЗабронГостей,
//	|		0 AS ЗабронНомеров,
//	|		0 AS ЗабронированоМест,
//	|		0 AS ЗабронДопМест
//	|	FROM
//	|		AccumulationRegister.ЗагрузкаНомеров AS Размещение
//	|	WHERE
//	|		Размещение.IsAccommodation
//	|		AND Размещение.RecordType = VALUE(AccumulationRecordType.Expense)
//	|		AND Размещение.ЭтоЗаезд
//	|		AND Размещение.CheckInDate >= &qPeriodFrom
//	|		AND Размещение.CheckInDate < &qPeriodTo
//	|		AND Размещение.Гостиница IN HIERARCHY(&qHotel)
//	|		AND (Размещение.ТипНомера IN HIERARCHY (&qRoomType)
//	|				OR &qIsEmptyRoomType)
//	|	
//	|	GROUP BY
//	|		BEGINOFPERIOD(Размещение.CheckInDate, DAY),
//	|		WEEK(Размещение.CheckInDate),
//	|		MONTH(Размещение.CheckInDate),
//	|		QUARTER(Размещение.CheckInDate),
//	|		YEAR(Размещение.CheckInDate),
//	|		Размещение.Гостиница,
//	|		Размещение.ТипНомера,
//	|		Размещение.Recorder,
//	|		Размещение.СтатусРазмещения,
//	|		Размещение.Контрагент,
//	|		Размещение.Договор,
//	|		Размещение.ГруппаГостей,
//	|		Размещение.Агент,
//	|		Размещение.Клиент,
//	|		Размещение.Тариф,
//	|		Размещение.ВидРазмещения,
//	|		Размещение.Reservation,
//	|		Размещение.ДокОснование,
//	|		Размещение.Reservation.ReservationStatus
//	|	
//	|	UNION ALL
//	|	
//	|	SELECT
//	|		BEGINOFPERIOD(Reservation.CheckInDate, DAY),
//	|		WEEK(Reservation.CheckInDate),
//	|		MONTH(Reservation.CheckInDate),
//	|		QUARTER(Reservation.CheckInDate),
//	|		YEAR(Reservation.CheckInDate),
//	|		Reservation.Гостиница,
//	|		Reservation.ТипНомера,
//	|		Reservation.Ref,
//	|		NULL,
//	|		Reservation.ДокОснование,
//	|		Reservation.ReservationStatus,
//	|		NULL,
//	|		Reservation.Контрагент,
//	|		Reservation.Договор,
//	|		Reservation.ГруппаГостей,
//	|		Reservation.Агент,
//	|		Reservation.Клиент,
//	|		Reservation.Тариф,
//	|		Reservation.ВидРазмещения,
//	|		0,
//	|		0,
//	|		0,
//	|		0,
//	|		SUM(Reservation.КоличествоЧеловек),
//	|		SUM(Reservation.КоличествоНомеров),
//	|		SUM(Reservation.КоличествоМест),
//	|		SUM(Reservation.КолДопМест)
//	|	FROM
//	|		Document.Reservation AS Reservation
//	|	WHERE
//	|		Reservation.Posted
//	|		AND Reservation.CheckInDate >= &qPeriodFrom
//	|		AND Reservation.CheckInDate < &qPeriodTo
//	|		AND Reservation.Гостиница IN HIERARCHY(&qHotel)
//	|		AND (Reservation.ТипНомера IN HIERARCHY (&qRoomType)
//	|				OR &qIsEmptyRoomType)
//	|	
//	|	GROUP BY
//	|		BEGINOFPERIOD(Reservation.CheckInDate, DAY),
//	|		WEEK(Reservation.CheckInDate),
//	|		MONTH(Reservation.CheckInDate),
//	|		QUARTER(Reservation.CheckInDate),
//	|		YEAR(Reservation.CheckInDate),
//	|		Reservation.Гостиница,
//	|		Reservation.ТипНомера,
//	|		Reservation.Ref,
//	|		Reservation.ReservationStatus,
//	|		Reservation.Контрагент,
//	|		Reservation.Договор,
//	|		Reservation.ГруппаГостей,
//	|		Reservation.Агент,
//	|		Reservation.Клиент,
//	|		Reservation.Тариф,
//	|		Reservation.ВидРазмещения,
//	|		Reservation.ДокОснование) AS PlanFact
//	|{WHERE
//	|	PlanFact.CheckInDay,
//	|	PlanFact.CheckInWeek,
//	|	PlanFact.CheckInMonth,
//	|	PlanFact.CheckInQuarter,
//	|	PlanFact.CheckInYear,
//	|	PlanFact.Гостиница.*,
//	|	PlanFact.ТипНомера.*,
//	|	PlanFact.Reservation.*,
//	|	PlanFact.Размещение.*,
//	|	PlanFact.ДокОснование.*,
//	|	PlanFact.ReservationStatus.*,
//	|	PlanFact.СтатусРазмещения.*,
//	|	PlanFact.Контрагент.* AS Контрагент,
//	|	PlanFact.Договор.* AS Договор,
//	|	PlanFact.ГруппаГостей.* AS ГруппаГостей,
//	|	PlanFact.Агент.* AS Агент,
//	|	PlanFact.Клиент.* AS Клиент,
//	|	PlanFact.Тариф.* AS Тариф,
//	|	PlanFact.ВидРазмещения.* AS ВидРазмещения,
//	|	PlanFact.ЗаездНомеров,
//	|	PlanFact.ЗаездМест,
//	|	PlanFact.ЗаездДополнительныхМест,
//	|	PlanFact.ЗаездГостей,
//	|	PlanFact.ЗабронГостей,
//	|	PlanFact.ЗабронНомеров,
//	|	PlanFact.ЗабронированоМест,
//	|	PlanFact.ЗабронДопМест,
//	|	(PlanFact.ЗабронГостей - PlanFact.ЗаездГостей) AS NoShowGuests,
//	|	(PlanFact.ЗабронНомеров - PlanFact.ЗаездНомеров) AS NoShowRooms,
//	|	(PlanFact.ЗабронированоМест - PlanFact.ЗаездМест) AS NoShowBeds,
//	|	(PlanFact.ЗабронДопМест - PlanFact.ЗаездДополнительныхМест) AS NoShowAdditionalBeds}
//	|
//	|ORDER BY
//	|	CheckInDay
//	|{ORDER BY
//	|	CheckInDay,
//	|	PlanFact.CheckInWeek,
//	|	PlanFact.CheckInMonth,
//	|	PlanFact.CheckInQuarter,
//	|	PlanFact.CheckInYear,
//	|	PlanFact.Гостиница.*,
//	|	PlanFact.ТипНомера.*,
//	|	PlanFact.Reservation.*,
//	|	PlanFact.Размещение.*,
//	|	PlanFact.ДокОснование.*,
//	|	PlanFact.ReservationStatus.*,
//	|	PlanFact.СтатусРазмещения.*,
//	|	PlanFact.Контрагент.* AS Контрагент,
//	|	PlanFact.Договор.* AS Договор,
//	|	PlanFact.ГруппаГостей.* AS ГруппаГостей,
//	|	PlanFact.Агент.* AS Агент,
//	|	PlanFact.Клиент.* AS Клиент,
//	|	PlanFact.Тариф.* AS Тариф,
//	|	PlanFact.ВидРазмещения.* AS ВидРазмещения,
//	|	ЗаездНомеров,
//	|	ЗаездМест,
//	|	ЗаездДополнительныхМест,
//	|	ЗаездГостей,
//	|	ЗабронГостей,
//	|	ЗабронНомеров,
//	|	ЗабронированоМест,
//	|	AdditionalBedsReserved}
//	|TOTALS
//	|	SUM(ЗаездНомеров),
//	|	SUM(ЗаездМест),
//	|	SUM(ЗаездДополнительныхМест),
//	|	SUM(ЗаездГостей),
//	|	SUM(ЗабронГостей),
//	|	SUM(ЗабронНомеров),
//	|	SUM(ЗабронированоМест),
//	|	SUM(ЗабронДопМест),
//	|	SUM(NoShowGuests),
//	|	SUM(NoShowRooms),
//	|	SUM(NoShowBeds),
//	|	SUM(NoShowAdditionalBeds)
//	|BY
//	|	OVERALL,
//	|	CheckInDay
//	|{TOTALS BY
//	|	CheckInDay,
//	|	PlanFact.CheckInWeek,
//	|	PlanFact.CheckInMonth,
//	|	PlanFact.CheckInQuarter,
//	|	PlanFact.CheckInYear,
//	|	PlanFact.Гостиница.*,
//	|	PlanFact.ТипНомера.*,
//	|	PlanFact.ReservationStatus.*,
//	|	PlanFact.СтатусРазмещения.*,
//	|	PlanFact.Контрагент.* AS Контрагент,
//	|	PlanFact.Договор.* AS Договор,
//	|	PlanFact.ГруппаГостей.* AS ГруппаГостей,
//	|	PlanFact.Агент.* AS Агент,
//	|	PlanFact.Клиент.* AS Клиент,
//	|	PlanFact.Тариф.* AS Тариф,
//	|	PlanFact.ВидРазмещения.* AS ВидРазмещения,
//	|	PlanFact.Reservation.*,
//	|	PlanFact.Размещение.*,
//	|	PlanFact.ДокОснование.*}";
//	ReportBuilder.Text = QueryText;
//	ReportBuilder.FillSettings();
//	
//	// Initialize report builder with default query
//	vRB = New ReportBuilder(QueryText);
//	vRBSettings = vRB.GetSettings(True, True, True, True, True);
//	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
//	
//	// Set default report builder header text
//	ReportBuilder.HeaderText = NStr("EN='Reservations plan/fact analysis';RU='План/фактный анализ брони';de='Plan-/Ist-Analyse der Buchung'");
//	
//	// Fill report builder fields presentations from the report template
//	cmFillReportAttributesPresentations(ThisObject);
//	
//	// Reset report builder template
//	ReportBuilder.Template = Неопределено;
//КонецПроцедуры //pmInitializeReportBuilder
//
////-----------------------------------------------------------------------------
//Function pmIsResource(pName) Экспорт
//	If pName = "ЗаездНомеров" 
//	   Or pName = "ЗаездМест" 
//	   Or pName = "ЗаездДополнительныхМест" 
//	   Or pName = "ЗаездГостей" 
//	   Or pName = "ЗабронНомеров" 
//	   Or pName = "ЗабронированоМест" 
//	   Or pName = "ЗабронДопМест" 
//	   Or pName = "ЗабронГостей" Тогда
//		Return True;
//	Else
//		Return False;
//	EndIf;
//EndFunction //pmIsResource
//
////-----------------------------------------------------------------------------
//// Reports framework end
////-----------------------------------------------------------------------------
