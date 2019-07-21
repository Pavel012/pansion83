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
//	If Ready Тогда
//		vParamPresentation = vParamPresentation + NStr("en='Show reservations that could be confirmed only';ru='Показывать только бронь, которую можно подтвердить';de='Nur Reservierungen anzeigen, die bestätigt werden können'") + 
//							 ";" + Chars.LF;
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
//	ReportBuilder.Parameters.Вставить("qPeriodTo", ?(ЗначениеЗаполнено(PeriodTo), PeriodTo, '39991231235959'));
//	ReportBuilder.Parameters.Вставить("qRoomType", RoomType);
//	ReportBuilder.Parameters.Вставить("qIsEmptyRoomType", НЕ ЗначениеЗаполнено(RoomType));
//	ReportBuilder.Parameters.Вставить("qReady", Ready);
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
//	|	WaitingList.Reservation.ГруппаГостей AS ReservationGuestGroup,
//	|	WaitingList.Reservation.CheckInDate AS ReservationCheckInDate,
//	|	WaitingList.Reservation.CheckOutDate AS ReservationCheckOutDate,
//	|	WaitingList.Reservation.ТипНомера AS ReservationRoomType,
//	|	WaitingList.Reservation.КоличествоЧеловек AS ReservationNumberOfPersons,
//	|	WaitingList.Reservation.КоличествоНомеров AS ReservationNumberOfRooms,
//	|	WaitingList.Reservation.КоличествоМест AS ReservationNumberOfBeds,
//	|	WaitingList.Reservation.КолДопМест AS ReservationNumberOfAdditionalBeds,
//	|	WaitingList.Reservation AS Reservation,
//	|	WaitingList.Rating AS Rating,
//	|	WaitingList.Ready AS Ready,
//	|	1 AS ReservationsCount
//	|{SELECT
//	|	Reservation.*,
//	|	Rating,
//	|	Ready,
//	|	ReservationsCount}
//	|FROM
//	|	InformationRegister.ReservationWaitingList AS WaitingList
//	|WHERE
//	|	WaitingList.Reservation.CheckInDate >= &qPeriodFrom
//	|	AND WaitingList.Reservation.CheckInDate < &qPeriodTo
//	|	AND WaitingList.Reservation.Гостиница IN HIERARCHY(&qHotel)
//	|	AND (WaitingList.Reservation.ТипНомера IN HIERARCHY (&qRoomType)
//	|			OR &qIsEmptyRoomType)
//	|	AND ((NOT &qReady)
//	|			OR &qReady
//	|				AND WaitingList.Ready)
//	|{WHERE
//	|	WaitingList.Reservation.*,
//	|	WaitingList.Reservation.ГруппаГостей AS ReservationGuestGroup,
//	|	WaitingList.Reservation.CheckInDate AS ReservationCheckInDate,
//	|	WaitingList.Reservation.CheckOutDate AS ReservationCheckOutDate,
//	|	WaitingList.Reservation.ТипНомера AS ReservationRoomType,
//	|	WaitingList.Rating,
//	|	WaitingList.Ready}
//	|
//	|ORDER BY
//	|	Rating DESC,
//	|	WaitingList.Reservation.ТипНомера.ПорядокСортировки,
//	|	ReservationCheckInDate,
//	|	ReservationCheckOutDate
//	|{ORDER BY
//	|	Reservation.*,
//	|	ReservationGuestGroup.*,
//	|	ReservationCheckInDate,
//	|	ReservationCheckOutDate,
//	|	ReservationRoomType.*,
//	|	Rating,
//	|	Ready}
//	|TOTALS
//	|	SUM(ReservationNumberOfPersons),
//	|	SUM(ReservationNumberOfRooms),
//	|	SUM(ReservationNumberOfBeds),
//	|	SUM(ReservationNumberOfAdditionalBeds),
//	|	SUM(ReservationsCount)
//	|BY
//	|	OVERALL
//	|{TOTALS BY
//	|	Reservation.*,
//	|	ReservationGuestGroup.*,
//	|	ReservationCheckInDate,
//	|	ReservationCheckOutDate,
//	|	ReservationRoomType.*,
//	|	Rating,
//	|	Ready}";
//	ReportBuilder.Text = QueryText;
//	ReportBuilder.FillSettings();
//	
//	// Initialize report builder with default query
//	vRB = New ReportBuilder(QueryText);
//	vRBSettings = vRB.GetSettings(True, True, True, True, True);
//	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
//	
//	// Set default report builder header text
//	ReportBuilder.HeaderText = NStr("en='Reservation waiting list';de='Buchung Warteliste';ru='Лист ожидания брони'");
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
//	If pName = "ReservationNumberOfPersons" 
//	   Or pName = "ReservationNumberOfRooms" 
//	   Or pName = "ReservationNumberOfBeds" 
//	   Or pName = "ReservationNumberOfAdditionalBeds" 
//	   Or pName = "ReservationsCount" Тогда
//		Return True;
//	Else
//		Return False;
//	EndIf;
//EndFunction //pmIsResource
//
////-----------------------------------------------------------------------------
//// Reports framework end
////-----------------------------------------------------------------------------
