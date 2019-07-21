//-----------------------------------------------------------------------------
// Reports framework start
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
//Процедура pmSaveReportAttributes() Экспорт
//	cmSaveReportAttributes(ThisObject);
//КонецПроцедуры //pmSaveReportAttributes
//
////-----------------------------------------------------------------------------
//Процедура pmLoadReportAttributes(pParameter = Неопределено) Экспорт
//	cmLoadReportAttributes(ThisObject, pParameter);
//КонецПроцедуры //pmLoadReportAttributes

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
	If НЕ ЗначениеЗаполнено(PeriodFrom) Тогда
		PeriodFrom = BegOfDay(CurrentDate()); // For today
		PeriodTo = EndOfDay(PeriodFrom);
	EndIf;
КонецПроцедуры //pmFillAttributesWithDefaultValues

//-----------------------------------------------------------------------------
Function pmGetReportParametersPresentation() Экспорт
	vParamPresentation = "";
	If ЗначениеЗаполнено(Employee) Тогда
		If НЕ Employee.IsFolder Тогда
			vParamPresentation = vParamPresentation + NStr("en='Employee ';ru='Сотрудник ';de='Mitarbeiter'") + 
			                     TrimAll(Employee) + 
			                     ";" + Chars.LF;
		Else
			vParamPresentation = vParamPresentation + NStr("ru = 'Группа сотрудников '; en = 'Employees folder '") + 
			                     TrimAll(Employee) + 
			                     ";" + Chars.LF;
		EndIf;
	EndIf;
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
	If НЕ ЗначениеЗаполнено(PeriodFrom) And НЕ ЗначениеЗаполнено(PeriodTo) Тогда
		vParamPresentation = vParamPresentation + NStr("en='Report period is not set';ru='Период отчета не установлен';de='Berichtszeitraum nicht festgelegt'") + 
		                     ";" + Chars.LF;
	ElsIf НЕ ЗначениеЗаполнено(PeriodFrom) And ЗначениеЗаполнено(PeriodTo) Тогда
		vParamPresentation = vParamPresentation + NStr("ru = 'Период c '; en = 'Period from '") + 
		                     Format(PeriodFrom, "DF='dd.MM.yyyy HH:mm:ss'") + 
		                     ";" + Chars.LF;
	ElsIf ЗначениеЗаполнено(PeriodFrom) And НЕ ЗначениеЗаполнено(PeriodTo) Тогда
		vParamPresentation = vParamPresentation + NStr("ru = 'Период по '; en = 'Period to '") + 
		                     Format(PeriodTo, "DF='dd.MM.yyyy HH:mm:ss'") + 
		                     ";" + Chars.LF;
	ElsIf PeriodFrom = PeriodTo Тогда
		vParamPresentation = vParamPresentation + NStr("ru = 'Период на '; en = 'Period on '") + 
		                     Format(PeriodFrom, "DF='dd.MM.yyyy HH:mm:ss'") + 
		                     ";" + Chars.LF;
	
	Else
		vParamPresentation = vParamPresentation + NStr("en='Period is wrong!';ru='Неправильно задан период!';de='Der Zeitraum wurde falsch eingetragen!'") + 
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
	Return vParamPresentation;
EndFunction //pmGetReportParametersPresentation

//-----------------------------------------------------------------------------
// Runs report
//-----------------------------------------------------------------------------
Процедура pmGenerate(pSpreadsheet) Экспорт
	
	
	// Reset report builder template
	ReportBuilder.Template = Неопределено;
	
	// Initialize report builder query generator attributes
	ReportBuilder.PresentationAdding = PresentationAdditionType.Add;
	
	// Fill report parameters
	ReportBuilder.Parameters.Вставить("qHotel", Гостиница);
	ReportBuilder.Parameters.Вставить("qPeriodFrom", PeriodFrom);
	ReportBuilder.Parameters.Вставить("qPeriodTo", PeriodTo);
	ReportBuilder.Parameters.Вставить("qEndOfTime", '39991231235959');
	ReportBuilder.Parameters.Вставить("qEmptyDate", '00010101');
	ReportBuilder.Parameters.Вставить("qRoom", Room);
	ReportBuilder.Parameters.Вставить("qRoomType", RoomType);
	ReportBuilder.Parameters.Вставить("qEmployee", Employee);

	// Execute report builder query
	ReportBuilder.Execute();
	
	//// Apply appearance settings to the report template
	//vTemplateAttributes = cmApplyReportTemplateAppearance(ThisObject);
	//
	//// Output report to the spreadsheet
	//ReportBuilder.Put(pSpreadsheet);
	////ReportBuilder.Template.Show(); // For debug purpose

	//// Apply appearance settings to the report spreadsheet
	//cmApplyReportAppearance(ThisObject, pSpreadsheet, vTemplateAttributes);
КонецПроцедуры //pmGenerate

//-----------------------------------------------------------------------------
Процедура pmInitializeReportBuilder() Экспорт
	ReportBuilder = New ReportBuilder();
	
	// Initialize default query text
	QueryText = 
	"SELECT DISTINCT
	|	AccommodationChangeHistorySliceFirst.Period AS CheckInTime,
	|	AccommodationChangeHistorySliceFirst.НомерРазмещения AS CheckInRoom,
	|	AccommodationChangeHistorySliceLast.Автор AS Автор,
	|	AccommodationChangeHistorySliceLast.Размещение AS Размещение,
	|	AccommodationChangeHistorySliceLast.CheckInDate AS CheckInDate,
	|	AccommodationChangeHistorySliceLast.Продолжительность AS Продолжительность,
	|	AccommodationChangeHistorySliceLast.CheckOutDate AS CheckOutDate,
	|	AccommodationChangeHistorySliceLast.НомерРазмещения AS НомерРазмещения,
	|	AccommodationChangeHistorySliceLast.ТипНомера AS ТипНомера,
	|	AccommodationChangeHistorySliceLast.Клиент AS Клиент,
	|	AccommodationChangeHistorySliceLast.ВидРазмещения AS ВидРазмещения,
	|	ИсторияИзмененийРазмещения.НомерРазмещения AS MovedToRoom,
	|	ИсторияИзмененийРазмещения.ТипНомера AS MovedToRoomType,
	|	ИсторияИзмененийРазмещения.Period AS MovedToTime,
	|	ИсторияИзмененийРазмещения.User AS MovedToAuthor,
	|	1 AS MovedToCount
	|{SELECT
	|	CheckInTime,
	|	Автор.*,
	|	CheckInRoom.*,
	|	Размещение.*,
	|	AccommodationChangeHistorySliceLast.Гостиница.* AS Гостиница,
	|	AccommodationChangeHistorySliceLast.ГруппаГостей.* AS ГруппаГостей,
	|	CheckInDate,
	|	Продолжительность,
	|	CheckOutDate,
	|	Клиент.*,
	|	НомерРазмещения.*,
	|	ТипНомера.*,
	|	ВидРазмещения.*,
	|	AccommodationChangeHistorySliceLast.Тариф.* AS Тариф,
	|	MovedToTime,
	|	MovedToAuthor.*,
	|	MovedToRoom.*,
	|	ИсторияИзмененийРазмещения.Гостиница.* AS MovedToHotel,
	|	ИсторияИзмененийРазмещения.СтатусРазмещения.* AS MovedToAccommodationStatus,
	|	ИсторияИзмененийРазмещения.CheckInDate AS MovedToCheckInDate,
	|	ИсторияИзмененийРазмещения.Продолжительность AS MovedToDuration,
	|	ИсторияИзмененийРазмещения.CheckOutDate AS MovedToCheckOutDate,
	|	MovedToRoomType.* AS MovedToRoomType,
	|	ИсторияИзмененийРазмещения.ВидРазмещения.* AS MovedToAccommodationType,
	|	ИсторияИзмененийРазмещения.КоличествоЧеловек AS MovedToNumberOfPersons,
	|	ИсторияИзмененийРазмещения.Контрагент.* AS MovedToCustomer,
	|	ИсторияИзмененийРазмещения.Договор.* AS MovedToContract,
	|	ИсторияИзмененийРазмещения.КонтактноеЛицо AS MovedToContactPerson,
	|	ИсторияИзмененийРазмещения.Агент.* AS MovedToAgent,
	|	ИсторияИзмененийРазмещения.Клиент.* AS MovedToGuest,
	|	ИсторияИзмененийРазмещения.ТипКлиента.* AS MovedToClientType,
	|	ИсторияИзмененийРазмещения.Тариф.* AS MovedToRoomRate,
	|	ИсторияИзмененийРазмещения.TripPurpose.* AS MovedToTripPurpose,
	|	ИсторияИзмененийРазмещения.ИсточИнфоГостиница.* AS MovedToSourceOfBusiness,
	|	ИсторияИзмененийРазмещения.МаретингНапрвл.* AS MovedToMarketingCode,
	|	ИсторияИзмененийРазмещения.КвотаНомеров.* AS MovedToRoomQuota,
	|	ИсторияИзмененийРазмещения.ГруппаГостей.* AS MovedToGuestGroup,
	|	ИсторияИзмененийРазмещения.ПутевкаКурсовка.* AS MovedToHotelProduct,
	|	ИсторияИзмененийРазмещения.ТипСкидки.* AS MovedToDiscountType,
	|	ИсторияИзмененийРазмещения.Скидка AS MovedToDiscount,
	|	ИсторияИзмененийРазмещения.PlannedPaymentMethod.* AS MovedToPlannedPaymentMethod,
	|	ИсторияИзмененийРазмещения.Фирма.* AS MovedToCompany,
	|	ИсторияИзмененийРазмещения.Примечания AS MovedToRemarks,
	|	ИсторияИзмененийРазмещения.Car AS MovedToCar,
	|	MovedToCount}
	|FROM
	|	InformationRegister.ИсторияИзмененийРазмещения.SliceLast(&qEndOfTime, ) AS AccommodationChangeHistorySliceLast
	|		INNER JOIN InformationRegister.ИсторияИзмененийРазмещения.SliceFirst(&qEmptyDate, ) AS AccommodationChangeHistorySliceFirst
	|		ON AccommodationChangeHistorySliceLast.Размещение = AccommodationChangeHistorySliceFirst.Размещение
	|		INNER JOIN InformationRegister.ИсторияИзмененийРазмещения AS ИсторияИзмененийРазмещения
	|		ON AccommodationChangeHistorySliceLast.Размещение = ИсторияИзмененийРазмещения.Размещение
	|			AND AccommodationChangeHistorySliceLast.НомерРазмещения <> ИсторияИзмененийРазмещения.НомерРазмещения
	|WHERE
	|	AccommodationChangeHistorySliceLast.Гостиница IN HIERARCHY(&qHotel)
	|	AND AccommodationChangeHistorySliceLast.НомерРазмещения IN HIERARCHY(&qRoom)
	|	AND AccommodationChangeHistorySliceLast.ТипНомера IN HIERARCHY(&qRoomType)
	|	AND ИсторияИзмененийРазмещения.User IN HIERARCHY(&qEmployee)
	|	AND AccommodationChangeHistorySliceLast.CheckInDate >= &qPeriodFrom
	|	AND AccommodationChangeHistorySliceLast.CheckInDate < &qPeriodTo
	|{WHERE
	|	AccommodationChangeHistorySliceFirst.Period AS CheckInTime,
	|	AccommodationChangeHistorySliceFirst.НомерРазмещения.* AS CheckInRoom,
	|	AccommodationChangeHistorySliceLast.Автор.*,
	|	AccommodationChangeHistorySliceLast.Размещение.*,
	|	AccommodationChangeHistorySliceLast.Гостиница.* AS Гостиница,
	|	AccommodationChangeHistorySliceLast.ГруппаГостей.* AS ГруппаГостей,
	|	AccommodationChangeHistorySliceLast.CheckInDate,
	|	AccommodationChangeHistorySliceLast.Продолжительность,
	|	AccommodationChangeHistorySliceLast.CheckOutDate,
	|	AccommodationChangeHistorySliceLast.НомерРазмещения.*,
	|	AccommodationChangeHistorySliceLast.Клиент.*,
	|	AccommodationChangeHistorySliceLast.ВидРазмещения.*,
	|	AccommodationChangeHistorySliceLast.ТипНомера.*,
	|	AccommodationChangeHistorySliceLast.Тариф.* AS Тариф,
	|	ИсторияИзмененийРазмещения.НомерРазмещения.* AS MovedToRoom,
	|	ИсторияИзмененийРазмещения.Period AS MovedToTime,
	|	ИсторияИзмененийРазмещения.User.* AS MovedToAuthor,
	|	ИсторияИзмененийРазмещения.Гостиница.* AS MovedToHotel,
	|	ИсторияИзмененийРазмещения.СтатусРазмещения.* AS MovedToAccommodationStatus,
	|	ИсторияИзмененийРазмещения.CheckInDate AS MovedToCheckInDate,
	|	ИсторияИзмененийРазмещения.Продолжительность AS MovedToDuration,
	|	ИсторияИзмененийРазмещения.CheckOutDate AS MovedToCheckOutDate,
	|	ИсторияИзмененийРазмещения.ТипНомера.* AS MovedToRoomType,
	|	ИсторияИзмененийРазмещения.ВидРазмещения.* AS MovedToAccommodationType,
	|	ИсторияИзмененийРазмещения.КоличествоЧеловек AS MovedToNumberOfPersons,
	|	ИсторияИзмененийРазмещения.Контрагент.* AS MovedToCustomer,
	|	ИсторияИзмененийРазмещения.Договор.* AS MovedToContract,
	|	ИсторияИзмененийРазмещения.КонтактноеЛицо AS MovedToContactPerson,
	|	ИсторияИзмененийРазмещения.Агент.* AS MovedToAgent,
	|	ИсторияИзмененийРазмещения.Клиент.* AS MovedToGuest,
	|	ИсторияИзмененийРазмещения.ТипКлиента.* AS MovedToClientType,
	|	ИсторияИзмененийРазмещения.Тариф.* AS MovedToRoomRate,
	|	ИсторияИзмененийРазмещения.TripPurpose.* AS MovedToTripPurpose,
	|	ИсторияИзмененийРазмещения.ИсточИнфоГостиница.* AS MovedToSourceOfBusiness,
	|	ИсторияИзмененийРазмещения.МаретингНапрвл.* AS MovedToMarketingCode,
	|	ИсторияИзмененийРазмещения.КвотаНомеров.* AS MovedToRoomQuota,
	|	ИсторияИзмененийРазмещения.ГруппаГостей.* AS MovedToGuestGroup,
	|	ИсторияИзмененийРазмещения.ПутевкаКурсовка.* AS MovedToHotelProduct,
	|	ИсторияИзмененийРазмещения.ТипСкидки.* AS MovedToDiscountType,
	|	ИсторияИзмененийРазмещения.Скидка AS MovedToDiscount,
	|	ИсторияИзмененийРазмещения.PlannedPaymentMethod.* AS MovedToPlannedPaymentMethod,
	|	ИсторияИзмененийРазмещения.Фирма.* AS MovedToCompany,
	|	ИсторияИзмененийРазмещения.Примечания AS MovedToRemarks,
	|	ИсторияИзмененийРазмещения.Car AS MovedToCar}
	|
	|ORDER BY
	|	CheckInTime
	|{ORDER BY
	|	CheckInTime,
	|	CheckInRoom.*,
	|	Автор.*,
	|	Размещение.*,
	|	CheckInDate,
	|	Продолжительность,
	|	CheckOutDate,
	|	НомерРазмещения.*,
	|	Клиент.*,
	|	ВидРазмещения.*,
	|	ТипНомера.*,
	|	MovedToRoom.*,
	|	MovedToTime,
	|	MovedToAuthor.*}
	|TOTALS
	|	SUM(MovedToCount)
	|BY
	|	OVERALL
	|{TOTALS BY
	|	CheckInRoom.*,
	|	Автор.*,
	|	Размещение.*,
	|	НомерРазмещения.*,
	|	Клиент.*,
	|	ВидРазмещения.*,
	|	ТипНомера.*,
	|	MovedToRoom.*,
	|	MovedToAuthor.*}";
	ReportBuilder.Text = QueryText;
	ReportBuilder.FillSettings();
	
	// Initialize report builder with default query
	vRB = New ReportBuilder(QueryText);
	vRBSettings = vRB.GetSettings(True, True, True, True, True);
	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
	
	// Set default report builder header text
	ReportBuilder.HeaderText = NStr("EN='Сhange ГруппаНомеров in accommodations audit';RU='Аудит замен номеров комнат в размещениях';de='Audit des Zimmernummernwechsels in Unterbringungen'");
	
	// Fill report builder fields presentations from the report template
	//cmFillReportAttributesPresentations(ThisObject);
	
	// Reset report builder template
	ReportBuilder.Template = Неопределено;
КонецПроцедуры //pmInitializeReportBuilder

//-----------------------------------------------------------------------------
// Reports framework end
//-----------------------------------------------------------------------------
