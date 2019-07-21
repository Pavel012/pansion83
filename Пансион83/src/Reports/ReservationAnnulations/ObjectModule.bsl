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
//	If ЗначениеЗаполнено(Employee) Тогда
//		If НЕ Employee.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("en='Employee ';ru='Сотрудник ';de='Mitarbeiter'") + 
//			                     TrimAll(Employee) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("ru = 'Группа сотрудников '; en = 'Employees folder '") + 
//			                     TrimAll(Employee) + 
//			                     ";" + Chars.LF;
//		EndIf;
//	EndIf;
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
//	If ЗначениеЗаполнено(Контрагент) Тогда
//		If НЕ Контрагент.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("de='Firma';en='Контрагент ';ru='Контрагент '") + 
//			                     TrimAll(Контрагент.Description) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("de='Gruppe Firmen';en='Customers folder ';ru='Группа контрагентов '") + 
//			                     TrimAll(Контрагент.Description) + 
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
//	ReportBuilder.Parameters.Вставить("qPeriodFrom", PeriodFrom);
//	ReportBuilder.Parameters.Вставить("qPeriodTo", PeriodTo);
//	ReportBuilder.Parameters.Вставить("qCustomer", Контрагент);
//	ReportBuilder.Parameters.Вставить("qCustomerIsEmpty", НЕ ЗначениеЗаполнено(Контрагент));
//	ReportBuilder.Parameters.Вставить("qRoomType", RoomType);
//	ReportBuilder.Parameters.Вставить("qRoomTypeIsEmpty", НЕ ЗначениеЗаполнено(RoomType));
//	ReportBuilder.Parameters.Вставить("qEmployee", Employee);
//	ReportBuilder.Parameters.Вставить("qEmployeeIsEmpty", НЕ ЗначениеЗаполнено(Employee));
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
//	|	Reservations.DateOfAnnulation AS DateOfAnnulation,
//	|	BEGINOFPERIOD(Reservations.DateOfAnnulation, DAY) AS AccountingDateOfAnnulation,
//	|	Reservations.AuthorOfAnnulation AS AuthorOfAnnulation,
//	|	Reservations.AnnulationReason AS AnnulationReason,
//	|	Reservations.Ref AS Reservation,
//	|	Reservations.Гостиница AS Гостиница,
//	|	Reservations.НомерРазмещения AS НомерРазмещения,
//	|	Reservations.Контрагент AS Контрагент,
//	|	Reservations.ГруппаГостей AS ГруппаГостей,
//	|	Reservations.ReservationStatus AS ReservationStatus,
//	|	Reservations.Клиент AS Клиент,
//	|	Reservations.CheckInDate AS CheckInDate,
//	|	Reservations.Продолжительность AS Продолжительность,
//	|	Reservations.CheckOutDate AS CheckOutDate,
//	|	Reservations.ТипНомера AS ТипНомера,
//	|	Reservations.ВидРазмещения AS ВидРазмещения,
//	|	Reservations.Тариф AS Тариф,
//	|	Reservations.PricePresentation AS PricePresentation,
//	|	Reservations.Примечания AS Примечания,
//	|	Reservations.КоличествоЧеловек AS КоличествоЧеловек,
//	|	Reservations.RoomQuantity AS RoomQuantity,
//	|	Reservations.КоличествоМест AS КоличествоМест,
//	|	Reservations.КолДопМест AS КолДопМест,
//	|	ReservationAmounts.Валюта AS Валюта,
//	|	ReservationAmounts.ПланПродаж AS ПланПродаж,
//	|	ReservationAmounts.ExpectedSalesWithoutVAT AS ExpectedSalesWithoutVAT,
//	|	1 AS СчетчикДокКвота
//	|{SELECT
//	|	DateOfAnnulation,
//	|	AccountingDateOfAnnulation,
//	|	AuthorOfAnnulation.*,
//	|	AnnulationReason,
//	|	Reservation.*,
//	|	Гостиница.* AS Гостиница,
//	|	НомерРазмещения.* AS НомерРазмещения,
//	|	Reservations.ТипКонтрагента.* AS ТипКонтрагента,
//	|	Контрагент.* AS Контрагент,
//	|	Reservations.Договор.* AS Договор,
//	|	Reservations.КонтактноеЛицо AS КонтактноеЛицо,
//	|	Reservations.Агент.* AS Агент,
//	|	Reservations.ТипКлиента.* AS ТипКлиента,
//	|	Клиент.* AS Клиент,
//	|	CheckInDate AS CheckInDate,
//	|	Продолжительность AS Продолжительность,
//	|	CheckOutDate AS CheckOutDate,
//	|	(BEGINOFPERIOD(Reservations.CheckInDate, DAY)) AS CheckInAccountingDate,
//	|	(BEGINOFPERIOD(Reservations.CheckOutDate, DAY)) AS CheckOutAccountingDate,
//	|	ТипНомера.* AS ТипНомера,
//	|	ВидРазмещения.* AS ВидРазмещения,
//	|	Reservations.RoomRateType.* AS RoomRateType,
//	|	Тариф.* AS Тариф,
//	|	PricePresentation AS PricePresentation,
//	|	Reservations.PlannedPaymentMethod.* AS PlannedPaymentMethod,
//	|	Примечания AS Примечания,
//	|	Reservations.Car AS Car,
//	|	ГруппаГостей.* AS ГруппаГостей,
//	|	ReservationStatus.* AS ReservationStatus,
//	|	Reservations.IsMaster AS IsMaster,
//	|	Reservations.ПутевкаКурсовка.* AS ПутевкаКурсовка,
//	|	Reservations.КвотаНомеров.* AS КвотаНомеров,
//	|	Reservations.МаретингНапрвл.* AS МаретингНапрвл,
//	|	Reservations.TripPurpose.* AS TripPurpose,
//	|	Reservations.ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
//	|	Reservations.Автор.* AS Автор,
//	|	Reservations.ДисконтКарт.* AS ДисконтКарт,
//	|	Reservations.ТипСкидки.* AS ТипСкидки,
//	|	Reservations.Скидка AS Скидка,
//	|	Reservations.КомиссияАгента AS КомиссияАгента,
//	|	Reservations.ВидКомиссииАгента.* AS ВидКомиссииАгента,
//	|	Reservations.КоличествоМестНомер AS КоличествоМестНомер,
//	|	Reservations.КоличествоГостейНомер AS КоличествоГостейНомер,
//	|	Reservations.ДокОснование.* AS ДокОснование,
//	|	КоличествоЧеловек AS КоличествоЧеловек,
//	|	RoomQuantity AS RoomQuantity,
//	|	КоличествоМест AS КоличествоМест,
//	|	КолДопМест AS КолДопМест,
//	|	Валюта.* AS Валюта,
//	|	ПланПродаж,
//	|	ExpectedSalesWithoutVAT,
//	|	СчетчикДокКвота AS Counter}
//	|FROM
//	|	Document.Reservation AS Reservations
//	|		LEFT JOIN (SELECT
//	|			ReservationAmountTurnovers.ДокОснование AS Reservation,
//	|			ReservationAmountTurnovers.ВалютаЛицСчета AS Валюта,
//	|			ReservationAmountTurnovers.ExpectedSalesTurnover AS ПланПродаж,
//	|			ReservationAmountTurnovers.ExpectedSalesWithoutVATTurnover AS ExpectedSalesWithoutVAT
//	|		FROM
//	|			AccumulationRegister.ПрогнозРеализации.Turnovers(, , Period, ) AS ReservationAmountTurnovers) AS ReservationAmounts
//	|		ON Reservations.Ref = ReservationAmounts.Reservation
//	|WHERE
//	|	Reservations.Posted
//	|	AND Reservations.DateOfAnnulation <> &qEmptyDate
//	|	AND Reservations.DateOfAnnulation >= &qPeriodFrom
//	|	AND Reservations.DateOfAnnulation <= &qPeriodTo
//	|	AND (Reservations.Гостиница IN HIERARCHY (&qHotel)
//	|			OR &qHotelIsEmpty)
//	|	AND (Reservations.Контрагент IN HIERARCHY (&qCustomer)
//	|			OR &qCustomerIsEmpty)
//	|	AND (Reservations.ТипНомера IN HIERARCHY (&qRoomType)
//	|			OR &qRoomTypeIsEmpty)
//	|	AND (Reservations.AuthorOfAnnulation IN HIERARCHY (&qEmployee)
//	|			OR &qEmployeeIsEmpty)
//	|{WHERE
//	|	Reservations.DateOfAnnulation,
//	|	Reservations.AuthorOfAnnulation.*,
//	|	Reservations.AnnulationReason,
//	|	Reservations.Ref.* AS Reservation,
//	|	Reservations.Гостиница.* AS Гостиница,
//	|	Reservations.НомерРазмещения.* AS НомерРазмещения,
//	|	Reservations.ТипКонтрагента.* AS ТипКонтрагента,
//	|	Reservations.Контрагент.* AS Контрагент,
//	|	Reservations.Договор.* AS Договор,
//	|	Reservations.КонтактноеЛицо AS КонтактноеЛицо,
//	|	Reservations.Агент.* AS Агент,
//	|	Reservations.ТипКлиента.* AS ТипКлиента,
//	|	Reservations.Клиент.* AS Клиент,
//	|	Reservations.CheckInDate AS CheckInDate,
//	|	Reservations.Продолжительность AS Продолжительность,
//	|	Reservations.CheckOutDate AS CheckOutDate,
//	|	Reservations.ТипНомера.* AS ТипНомера,
//	|	Reservations.ВидРазмещения.* AS ВидРазмещения,
//	|	Reservations.RoomRateType.* AS RoomRateType,
//	|	Reservations.Тариф.* AS Тариф,
//	|	Reservations.PricePresentation AS PricePresentation,
//	|	Reservations.PlannedPaymentMethod.* AS PlannedPaymentMethod,
//	|	Reservations.Примечания AS Примечания,
//	|	Reservations.Car AS Car,
//	|	Reservations.ГруппаГостей.* AS ГруппаГостей,
//	|	Reservations.ReservationStatus.* AS ReservationStatus,
//	|	Reservations.IsMaster AS IsMaster,
//	|	Reservations.ПутевкаКурсовка.* AS ПутевкаКурсовка,
//	|	Reservations.КвотаНомеров.* AS КвотаНомеров,
//	|	Reservations.МаретингНапрвл.* AS МаретингНапрвл,
//	|	Reservations.TripPurpose.* AS TripPurpose,
//	|	Reservations.ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
//	|	Reservations.Автор.* AS Автор,
//	|	Reservations.ДисконтКарт.* AS ДисконтКарт,
//	|	Reservations.ТипСкидки.* AS ТипСкидки,
//	|	Reservations.Скидка AS Скидка,
//	|	Reservations.КомиссияАгента AS КомиссияАгента,
//	|	Reservations.ВидКомиссииАгента.* AS ВидКомиссииАгента,
//	|	Reservations.КоличествоМестНомер AS КоличествоМестНомер,
//	|	Reservations.КоличествоГостейНомер AS КоличествоГостейНомер,
//	|	Reservations.ДокОснование.* AS ДокОснование,
//	|	Reservations.КоличествоЧеловек AS КоличествоЧеловек,
//	|	Reservations.RoomQuantity AS RoomQuantity,
//	|	Reservations.КоличествоМест AS КоличествоМест,
//	|	Reservations.КолДопМест AS КолДопМест,
//	|	ReservationAmounts.Валюта.* AS Валюта,
//	|	ReservationAmounts.ПланПродаж AS ПланПродаж,
//	|	ReservationAmounts.ExpectedSalesWithoutVAT AS ExpectedSalesWithoutVAT,
//	|	(1) AS Counter}
//	|
//	|ORDER BY
//	|	Гостиница,
//	|	Контрагент,
//	|	ГруппаГостей,
//	|	CheckInDate,
//	|	ВидРазмещения,
//	|	Клиент
//	|{ORDER BY
//	|	DateOfAnnulation,
//	|	AccountingDateOfAnnulation,
//	|	AuthorOfAnnulation.*,
//	|	AnnulationReason,
//	|	Reservation.*,
//	|	Гостиница.* AS Гостиница,
//	|	НомерРазмещения.* AS НомерРазмещения,
//	|	Reservations.ТипКонтрагента.* AS ТипКонтрагента,
//	|	Контрагент.* AS Контрагент,
//	|	Reservations.Договор.* AS Договор,
//	|	Reservations.КонтактноеЛицо AS КонтактноеЛицо,
//	|	Reservations.Агент.* AS Агент,
//	|	Reservations.ТипКлиента.* AS ТипКлиента,
//	|	Клиент.* AS Клиент,
//	|	CheckInDate AS CheckInDate,
//	|	Продолжительность AS Продолжительность,
//	|	CheckOutDate AS CheckOutDate,
//	|	(BEGINOFPERIOD(Reservations.CheckInDate, DAY)) AS CheckInAccountingDate,
//	|	(BEGINOFPERIOD(Reservations.CheckOutDate, DAY)) AS CheckOutAccountingDate,
//	|	ТипНомера.* AS ТипНомера,
//	|	ВидРазмещения.* AS ВидРазмещения,
//	|	Reservations.RoomRateType.* AS RoomRateType,
//	|	Тариф.* AS Тариф,
//	|	PricePresentation AS PricePresentation,
//	|	Reservations.PlannedPaymentMethod.* AS PlannedPaymentMethod,
//	|	Примечания AS Примечания,
//	|	Reservations.Car AS Car,
//	|	ГруппаГостей.* AS ГруппаГостей,
//	|	ReservationStatus.* AS ReservationStatus,
//	|	Reservations.IsMaster AS IsMaster,
//	|	Reservations.ПутевкаКурсовка.* AS ПутевкаКурсовка,
//	|	Reservations.КвотаНомеров.* AS КвотаНомеров,
//	|	Reservations.МаретингНапрвл.* AS МаретингНапрвл,
//	|	Reservations.TripPurpose.* AS TripPurpose,
//	|	Reservations.ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
//	|	Reservations.Автор.* AS Автор,
//	|	Reservations.ДисконтКарт.* AS ДисконтКарт,
//	|	Reservations.ТипСкидки.* AS ТипСкидки,
//	|	Reservations.Скидка AS Скидка,
//	|	Reservations.КомиссияАгента AS КомиссияАгента,
//	|	Reservations.ВидКомиссииАгента.* AS ВидКомиссииАгента,
//	|	Reservations.КоличествоМестНомер AS КоличествоМестНомер,
//	|	Reservations.КоличествоГостейНомер AS КоличествоГостейНомер,
//	|	Reservations.ДокОснование.* AS ДокОснование,
//	|	КоличествоЧеловек AS КоличествоЧеловек,
//	|	RoomQuantity AS RoomQuantity,
//	|	КоличествоМест AS КоличествоМест,
//	|	КолДопМест AS КолДопМест,
//	|	Валюта.* AS Валюта,
//	|	ПланПродаж,
//	|	ExpectedSalesWithoutVAT,
//	|	СчетчикДокКвота AS Counter}
//	|TOTALS
//	|	SUM(КоличествоЧеловек),
//	|	SUM(RoomQuantity),
//	|	SUM(КоличествоМест),
//	|	SUM(КолДопМест),
//	|	SUM(ПланПродаж),
//	|	SUM(ExpectedSalesWithoutVAT),
//	|	SUM(СчетчикДокКвота)
//	|BY
//	|	OVERALL,
//	|	Гостиница,
//	|	Контрагент,
//	|	ГруппаГостей
//	|{TOTALS BY
//	|	AccountingDateOfAnnulation,
//	|	AuthorOfAnnulation.*,
//	|	Reservation.*,
//	|	Гостиница.* AS Гостиница,
//	|	НомерРазмещения.* AS НомерРазмещения,
//	|	Reservations.ТипКонтрагента.* AS ТипКонтрагента,
//	|	Контрагент.* AS Контрагент,
//	|	Reservations.Договор.* AS Договор,
//	|	Reservations.КонтактноеЛицо AS КонтактноеЛицо,
//	|	Reservations.Агент.* AS Агент,
//	|	Reservations.ТипКлиента.* AS ТипКлиента,
//	|	Клиент.* AS Клиент,
//	|	Продолжительность AS Продолжительность,
//	|	(BEGINOFPERIOD(Reservations.CheckInDate, DAY)) AS CheckInAccountingDate,
//	|	(BEGINOFPERIOD(Reservations.CheckOutDate, DAY)) AS CheckOutAccountingDate,
//	|	ТипНомера.* AS ТипНомера,
//	|	ВидРазмещения.* AS ВидРазмещения,
//	|	Reservations.RoomRateType.* AS RoomRateType,
//	|	Тариф.* AS Тариф,
//	|	PricePresentation AS PricePresentation,
//	|	Reservations.PlannedPaymentMethod.* AS PlannedPaymentMethod,
//	|	ГруппаГостей.* AS ГруппаГостей,
//	|	ReservationStatus.* AS ReservationStatus,
//	|	Reservations.ПутевкаКурсовка.* AS ПутевкаКурсовка,
//	|	Reservations.КвотаНомеров.* AS КвотаНомеров,
//	|	Reservations.МаретингНапрвл.* AS МаретингНапрвл,
//	|	Reservations.TripPurpose.* AS TripPurpose,
//	|	Reservations.ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
//	|	Reservations.Автор.* AS Автор,
//	|	Reservations.ДисконтКарт.* AS ДисконтКарт,
//	|	Reservations.ТипСкидки.* AS ТипСкидки,
//	|	Reservations.Скидка AS Скидка,
//	|	Reservations.КомиссияАгента AS КомиссияАгента,
//	|	Reservations.ВидКомиссииАгента.* AS ВидКомиссииАгента,
//	|	Валюта.* AS Валюта,
//	|	Reservations.ДокОснование.* AS ParentDoc}";
//	ReportBuilder.Text = QueryText;
//	ReportBuilder.FillSettings();
//	
//	// Initialize report builder with default query
//	vRB = New ReportBuilder(QueryText);
//	vRBSettings = vRB.GetSettings(True, True, True, True, True);
//	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
//	
//	// Set default report builder header text
//	ReportBuilder.HeaderText = NStr("EN='Reservation annulations audit';RU='Аудит аннуляций брони';de='Buchprüfung der Annullierung der Buchung'");
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
