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
	If ЗначениеЗаполнено(НомерРазмещения) Тогда
		If НЕ НомерРазмещения.IsFolder Тогда
			vParamPresentation = vParamPresentation + NStr("en='ГруппаНомеров ';ru='Номер ';de='Zimmer'") + 
			                     TrimAll(НомерРазмещения.Description) + 
			                     ";" + Chars.LF;
		Else
			vParamPresentation = vParamPresentation + NStr("en='Rooms folder ';ru='Группа номеров ';de='Gruppe Zimmer '") + 
			                     TrimAll(НомерРазмещения.Description) + 
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
	ReportBuilder.Parameters.Вставить("qRoom", НомерРазмещения);
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
	"SELECT
	|	AccommodationFirstAnnulation.Period AS TimeOfAnnulation,
	|	AccommodationFirstAnnulation.User AS AuthorOfAnnulation,
	|	DATEDIFF(ЗагрузкаНомеров.Recorder.CheckInDate, AccommodationFirstAnnulation.Period, MINUTE) AS MinutesBetweenAnnulationAndCheckIn,
	|	DATEDIFF(ЗагрузкаНомеров.Recorder.CheckInDate, AccommodationFirstAnnulation.Period, HOUR) AS HoursBetweenAnnulationAndCheckIn,
	|	Returns.Возврат AS Return,
	|	ЗагрузкаНомеров.Количество AS Количество,
	|	PaymentAnnulations.AnnulatedPayment AS AnnulatedPayment,
	|	ЗагрузкаНомеров.Recorder.Гостиница AS Гостиница,
	|	ЗагрузкаНомеров.Recorder.НомерРазмещения AS НомерРазмещения,
	|	ЗагрузкаНомеров.Recorder.Контрагент AS Контрагент,
	|	ЗагрузкаНомеров.Recorder.ГруппаГостей AS ГруппаГостей,
	|	ЗагрузкаНомеров.Recorder.СтатусРазмещения AS СтатусРазмещения,
	|	ЗагрузкаНомеров.Recorder.Клиент AS Клиент,
	|	ЗагрузкаНомеров.Recorder.CheckInDate AS CheckInDate,
	|	ЗагрузкаНомеров.Recorder.Продолжительность AS Продолжительность,
	|	ЗагрузкаНомеров.Recorder.CheckOutDate AS CheckOutDate,
	|	ЗагрузкаНомеров.Recorder.ТипНомера AS ТипНомера,
	|	ЗагрузкаНомеров.Recorder.ВидРазмещения AS ВидРазмещения,
	|	ЗагрузкаНомеров.Recorder.Тариф AS Тариф,
	|	ЗагрузкаНомеров.Recorder.PricePresentation AS PricePresentation,
	|	ЗагрузкаНомеров.Recorder.ДокОснование.Тариф AS ParentDocRoomRate,
	|	ЗагрузкаНомеров.Recorder.ДокОснование.PricePresentation AS ParentDocPricePresentation,
	|	CASE
	|		WHEN ЗагрузкаНомеров.Recorder.ДокОснование.PricePresentation <> """"
	|				AND ЗагрузкаНомеров.Recorder.ДокОснование.PricePresentation <> RoomInventory.Recorder.PricePresentation
	|			THEN TRUE
	|		ELSE FALSE
	|	END AS ThereIsPriceDifference,
	|	ЗагрузкаНомеров.Recorder.Примечания AS Примечания,
	|	ЗагрузкаНомеров.ЗаездГостей AS ЗаездГостей,
	|	ЗагрузкаНомеров.ЗаездНомеров AS ЗаездНомеров,
	|	ЗагрузкаНомеров.ЗаездМест AS ЗаездМест,
	|	ЗагрузкаНомеров.ЗаездДополнительныхМест AS ЗаездДополнительныхМест
	|{SELECT
	|	TimeOfAnnulation,
	|	AuthorOfAnnulation.*,
	|	MinutesBetweenAnnulationAndCheckIn,
	|	HoursBetweenAnnulationAndCheckIn,
	|	Return.*,
	|	AnnulatedPayment.*,
	|	Количество,
	|	Гостиница.* AS Гостиница,
	|	НомерРазмещения.* AS НомерРазмещения,
	|	ЗагрузкаНомеров.Recorder.ТипКонтрагента.* AS ТипКонтрагента,
	|	Контрагент.* AS Контрагент,
	|	ЗагрузкаНомеров.Recorder.Договор.* AS Договор,
	|	ЗагрузкаНомеров.Recorder.КонтактноеЛицо AS КонтактноеЛицо,
	|	ЗагрузкаНомеров.Recorder.Агент.* AS Агент,
	|	ЗагрузкаНомеров.Recorder.ТипКлиента.* AS ТипКлиента,
	|	Клиент.* AS Клиент,
	|	CheckInDate AS CheckInDate,
	|	Продолжительность AS Продолжительность,
	|	CheckOutDate AS CheckOutDate,
	|	ЗагрузкаНомеров.CheckInAccountingDate AS CheckInAccountingDate,
	|	ЗагрузкаНомеров.CheckOutAccountingDate AS CheckOutAccountingDate,
	|	(HOUR(ЗагрузкаНомеров.Recorder.CheckInDate)) AS CheckInHour,
	|	(DAY(ЗагрузкаНомеров.Recorder.CheckInDate)) AS CheckInDay,
	|	(WEEK(ЗагрузкаНомеров.Recorder.CheckInDate)) AS CheckInWeek,
	|	(MONTH(ЗагрузкаНомеров.Recorder.CheckInDate)) AS CheckInMonth,
	|	(QUARTER(ЗагрузкаНомеров.Recorder.CheckInDate)) AS CheckInQuarter,
	|	(YEAR(ЗагрузкаНомеров.Recorder.CheckInDate)) AS CheckInYear,
	|	ТипНомера.* AS ТипНомера,
	|	ВидРазмещения.* AS ВидРазмещения,
	|	ЗагрузкаНомеров.Recorder.RoomRateType.* AS RoomRateType,
	|	Тариф.* AS Тариф,
	|	PricePresentation AS PricePresentation,
	|	ЗагрузкаНомеров.Recorder.ДокОснование.ТипНомера.* AS ParentDocRoomType,
	|	ЗагрузкаНомеров.Recorder.ДокОснование.ВидРазмещения.* AS ParentDocAccommodationType,
	|	ЗагрузкаНомеров.Recorder.ДокОснование.RoomRateType.* AS ParentDocRoomRateType,
	|	ParentDocRoomRate.* AS ParentDocRoomRate,
	|	ParentDocPricePresentation AS ParentDocPricePresentation,
	|	ThereIsPriceDifference AS ThereIsPriceDifference,
	|	ЗагрузкаНомеров.Recorder.PlannedPaymentMethod.* AS PlannedPaymentMethod,
	|	Примечания AS Примечания,
	|	ЗагрузкаНомеров.Recorder.Car AS Car,
	|	ГруппаГостей.* AS ГруппаГостей,
	|	СтатусРазмещения.* AS СтатусРазмещения,
	|	ЗагрузкаНомеров.Recorder.IsMaster AS IsMaster,
	|	ЗагрузкаНомеров.Recorder.ПутевкаКурсовка.* AS ПутевкаКурсовка,
	|	ЗагрузкаНомеров.Recorder.КвотаНомеров.* AS КвотаНомеров,
	|	ЗагрузкаНомеров.Recorder.МаретингНапрвл.* AS МаретингНапрвл,
	|	ЗагрузкаНомеров.Recorder.TripPurpose.* AS TripPurpose,
	|	ЗагрузкаНомеров.Recorder.ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
	|	ЗагрузкаНомеров.Recorder.Автор.* AS Автор,
	|	ЗагрузкаНомеров.Recorder.ДисконтКарт.* AS ДисконтКарт,
	|	ЗагрузкаНомеров.Recorder.ТипСкидки.* AS ТипСкидки,
	|	ЗагрузкаНомеров.Recorder.Скидка AS Скидка,
	|	ЗагрузкаНомеров.Recorder.КомиссияАгента AS КомиссияАгента,
	|	ЗагрузкаНомеров.Recorder.ВидКомиссииАгента.* AS ВидКомиссииАгента,
	|	ЗагрузкаНомеров.Recorder.КоличествоМестНомер AS КоличествоМестНомер,
	|	ЗагрузкаНомеров.Recorder.КоличествоГостейНомер AS КоличествоГостейНомер,
	|	ЗагрузкаНомеров.Recorder.ДокОснование.* AS ДокОснование,
	|	ЗагрузкаНомеров.Recorder.* AS Recorder,
	|	ЗагрузкаНомеров.Recorder.PointInTime AS PointInTime,
	|	ЗаездГостей AS ЗаездГостей,
	|	ЗаездНомеров AS ЗаездНомеров,
	|	ЗаездМест AS ЗаездМест,
	|	ЗаездДополнительныхМест AS AdditionalBedsCheckedIn}
	|FROM
	|	(SELECT
	|		RoomInventoryMovements.Ref AS Recorder,
	|		1 AS Количество,
	|		MIN(BEGINOFPERIOD(RoomInventoryMovements.CheckInDate, DAY)) AS CheckInAccountingDate,
	|		MAX(BEGINOFPERIOD(RoomInventoryMovements.CheckOutDate, DAY)) AS CheckOutAccountingDate,
	|		SUM(RoomInventoryMovements.КоличествоЧеловек) AS ЗаездГостей,
	|		SUM(RoomInventoryMovements.КоличествоНомеров) AS ЗаездНомеров,
	|		SUM(RoomInventoryMovements.КоличествоМест) AS ЗаездМест,
	|		SUM(RoomInventoryMovements.КолДопМест) AS ЗаездДополнительныхМест
	|	FROM
	|		Document.Размещение AS RoomInventoryMovements
	|	WHERE
	|		((NOT RoomInventoryMovements.СтатусРазмещения.IsActive)
	|				OR RoomInventoryMovements.DeletionMark)
	|		AND RoomInventoryMovements.Гостиница IN HIERARCHY(&qHotel)
	|		AND RoomInventoryMovements.НомерРазмещения IN HIERARCHY(&qRoom)
	|		AND RoomInventoryMovements.ТипНомера IN HIERARCHY(&qRoomType)
	|		AND RoomInventoryMovements.Автор IN HIERARCHY(&qEmployee)
	|		AND RoomInventoryMovements.CheckInDate >= &qPeriodFrom
	|		AND RoomInventoryMovements.CheckInDate < &qPeriodTo
	|	
	|	GROUP BY
	|		RoomInventoryMovements.Ref) AS ЗагрузкаНомеров
	|		INNER JOIN (SELECT
	|			AccommodationChangeHistorySliceFirst.Размещение AS Размещение,
	|			AccommodationChangeHistorySliceFirst.Period AS Period,
	|			AccommodationChangeHistorySliceFirst.User AS User
	|		FROM
	|			InformationRegister.ИсторияИзмененийРазмещения.SliceFirst(&qPeriodFrom, (NOT СтатусРазмещения.IsActive)) AS AccommodationChangeHistorySliceFirst) AS AccommodationFirstAnnulation
	|		ON ЗагрузкаНомеров.Recorder = AccommodationFirstAnnulation.Размещение
	|		LEFT JOIN (SELECT
	|			Return.Ref AS Return,
	|			Return.ДокОснование AS ДокОснование
	|		FROM
	|			Document.Возврат AS Return) AS Returns
	|		ON ЗагрузкаНомеров.Recorder = Returns.ДокОснование
	|		LEFT JOIN (SELECT
	|			Платеж.Ref AS AnnulatedPayment,
	|			Платеж.ДокОснование AS ДокОснование,
	|			Платеж.DeletionMark AS DeletionMark
	|		FROM
	|			Document.Платеж AS Платеж) AS PaymentAnnulations
	|		ON ЗагрузкаНомеров.Recorder = PaymentAnnulations.ДокОснование
	|			AND (PaymentAnnulations.DeletionMark)
	|{WHERE
	|	AccommodationFirstAnnulation.Period AS TimeOfAnnulation,
	|	AccommodationFirstAnnulation.User.* AS AuthorOfAnnulation,
	|	(DATEDIFF(ЗагрузкаНомеров.Recorder.CheckInDate, AccommodationFirstAnnulation.Period, MINUTE)) AS MinutesBetweenAnnulationAndCheckIn,
	|	(DATEDIFF(ЗагрузкаНомеров.Recorder.CheckInDate, AccommodationFirstAnnulation.Period, HOUR)) AS HoursBetweenAnnulationAndCheckIn,
	|	Returns.Возврат AS Return,
	|	PaymentAnnulations.AnnulatedPayment AS AnnulatedPayment,
	|	ЗагрузкаНомеров.Recorder.* AS Recorder,
	|	ЗагрузкаНомеров.Recorder.Гостиница.* AS Гостиница,
	|	ЗагрузкаНомеров.Recorder.НомерРазмещения.* AS НомерРазмещения,
	|	ЗагрузкаНомеров.Recorder.Контрагент.* AS Контрагент,
	|	ЗагрузкаНомеров.Recorder.ТипКонтрагента.* AS ТипКонтрагента,
	|	ЗагрузкаНомеров.Recorder.Договор.* AS Договор,
	|	ЗагрузкаНомеров.Recorder.КонтактноеЛицо AS КонтактноеЛицо,
	|	ЗагрузкаНомеров.Recorder.Агент.* AS Агент,
	|	ЗагрузкаНомеров.Recorder.ГруппаГостей.* AS ГруппаГостей,
	|	ЗагрузкаНомеров.Recorder.ДокОснование.* AS ДокОснование,
	|	ЗагрузкаНомеров.Recorder.ПутевкаКурсовка.* AS ПутевкаКурсовка,
	|	ЗагрузкаНомеров.Recorder.СтатусРазмещения.* AS СтатусРазмещения,
	|	ЗагрузкаНомеров.Recorder.CheckInDate AS CheckInDate,
	|	ЗагрузкаНомеров.Recorder.Продолжительность AS Продолжительность,
	|	ЗагрузкаНомеров.Recorder.CheckOutDate AS CheckOutDate,
	|	ЗагрузкаНомеров.CheckInAccountingDate AS CheckInAccountingDate,
	|	ЗагрузкаНомеров.CheckOutAccountingDate AS CheckOutAccountingDate,
	|	ЗагрузкаНомеров.Recorder.КвотаНомеров.* AS КвотаНомеров,
	|	ЗагрузкаНомеров.Recorder.ТипКлиента.* AS ТипКлиента,
	|	ЗагрузкаНомеров.Recorder.Клиент.* AS Клиент,
	|	ЗагрузкаНомеров.Recorder.МаретингНапрвл.* AS МаретингНапрвл,
	|	ЗагрузкаНомеров.Recorder.TripPurpose.* AS TripPurpose,
	|	ЗагрузкаНомеров.Recorder.ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
	|	ЗагрузкаНомеров.Recorder.ТипНомера.* AS ТипНомера,
	|	ЗагрузкаНомеров.Recorder.ВидРазмещения.* AS ВидРазмещения,
	|	ЗагрузкаНомеров.Recorder.RoomRateType.* AS RoomRateType,
	|	ЗагрузкаНомеров.Recorder.Тариф.* AS Тариф,
	|	ЗагрузкаНомеров.Recorder.PricePresentation AS PricePresentation,
	|	ЗагрузкаНомеров.Recorder.ДокОснование.ТипНомера.* AS ParentDocRoomType,
	|	ЗагрузкаНомеров.Recorder.ДокОснование.ВидРазмещения.* AS ParentDocAccommodationType,
	|	ЗагрузкаНомеров.Recorder.ДокОснование.RoomRateType.* AS ParentDocRoomRateType,
	|	ЗагрузкаНомеров.Recorder.ДокОснование.Тариф.* AS ParentDocRoomRate,
	|	ЗагрузкаНомеров.Recorder.ДокОснование.PricePresentation AS ParentDocPricePresentation,
	|	(CASE
	|			WHEN ЗагрузкаНомеров.Recorder.ДокОснование.PricePresentation <> """"
	|					AND ЗагрузкаНомеров.Recorder.ДокОснование.PricePresentation <> RoomInventory.Recorder.PricePresentation
	|				THEN TRUE
	|			ELSE FALSE
	|		END) AS ThereIsPriceDifference,
	|	ЗагрузкаНомеров.Recorder.Автор.* AS Автор,
	|	ЗагрузкаНомеров.Recorder.ДисконтКарт.* AS ДисконтКарт,
	|	ЗагрузкаНомеров.Recorder.ТипСкидки.* AS ТипСкидки,
	|	ЗагрузкаНомеров.Recorder.Скидка AS Скидка,
	|	ЗагрузкаНомеров.Recorder.PlannedPaymentMethod.* AS PlannedPaymentMethod,
	|	ЗагрузкаНомеров.Recorder.Car AS Car,
	|	ЗагрузкаНомеров.Recorder.Примечания AS Примечания,
	|	ЗагрузкаНомеров.Recorder.КомиссияАгента AS КомиссияАгента,
	|	ЗагрузкаНомеров.Recorder.ВидКомиссииАгента.* AS ВидКомиссииАгента,
	|	ЗагрузкаНомеров.Recorder.IsMaster AS IsMaster,
	|	ЗагрузкаНомеров.ЗаездНомеров AS ЗаездНомеров,
	|	ЗагрузкаНомеров.ЗаездМест AS ЗаездМест,
	|	ЗагрузкаНомеров.ЗаездДополнительныхМест AS ЗаездДополнительныхМест,
	|	ЗагрузкаНомеров.ЗаездГостей AS GuestsCheckedIn}
	|
	|ORDER BY
	|	Гостиница,
	|	НомерРазмещения,
	|	CheckInDate,
	|	Клиент
	|{ORDER BY
	|	TimeOfAnnulation,
	|	AuthorOfAnnulation.*,
	|	MinutesBetweenAnnulationAndCheckIn,
	|	HoursBetweenAnnulationAndCheckIn,
	|	Return.*,
	|	AnnulatedPayment.*,
	|	Контрагент.*,
	|	ЗагрузкаНомеров.Recorder.ТипКонтрагента.* AS ТипКонтрагента,
	|	ЗагрузкаНомеров.Recorder.Договор.* AS Договор,
	|	ЗагрузкаНомеров.Recorder.Агент.* AS Агент,
	|	ГруппаГостей.* AS ГруппаГостей,
	|	Клиент.* AS Клиент,
	|	ЗагрузкаНомеров.Recorder.МаретингНапрвл.* AS МаретингНапрвл,
	|	ЗагрузкаНомеров.Recorder.TripPurpose.* AS TripPurpose,
	|	ЗагрузкаНомеров.Recorder.ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
	|	ЗагрузкаНомеров.Recorder.RoomRateType.* AS RoomRateType,
	|	ЗагрузкаНомеров.Recorder.ПутевкаКурсовка.* AS ПутевкаКурсовка,
	|	Тариф.* AS Тариф,
	|	PricePresentation AS PricePresentation,
	|	ЗагрузкаНомеров.Recorder.ДисконтКарт.* AS ДисконтКарт,
	|	ЗагрузкаНомеров.Recorder.ТипСкидки.* AS ТипСкидки,
	|	ЗагрузкаНомеров.Recorder.PlannedPaymentMethod.* AS PlannedPaymentMethod,
	|	НомерРазмещения.* AS НомерРазмещения,
	|	ТипНомера.* AS ТипНомера,
	|	Гостиница.* AS Гостиница,
	|	ЗагрузкаНомеров.Recorder.PointInTime AS PointInTime,
	|	CheckInDate AS CheckInDate,
	|	Продолжительность AS Продолжительность,
	|	CheckOutDate AS CheckOutDate,
	|	ЗагрузкаНомеров.CheckInAccountingDate AS CheckInAccountingDate,
	|	ЗагрузкаНомеров.CheckOutAccountingDate AS CheckOutAccountingDate,
	|	(HOUR(ЗагрузкаНомеров.Recorder.CheckInDate)) AS CheckInHour,
	|	(DAY(ЗагрузкаНомеров.Recorder.CheckInDate)) AS CheckInDay,
	|	(WEEK(ЗагрузкаНомеров.Recorder.CheckInDate)) AS CheckInWeek,
	|	(MONTH(ЗагрузкаНомеров.Recorder.CheckInDate)) AS CheckInMonth,
	|	(QUARTER(ЗагрузкаНомеров.Recorder.CheckInDate)) AS CheckInQuarter,
	|	(YEAR(ЗагрузкаНомеров.Recorder.CheckInDate)) AS CheckInYear,
	|	ЗагрузкаНомеров.Recorder.КвотаНомеров.* AS КвотаНомеров,
	|	ЗагрузкаНомеров.Recorder.Автор.* AS Автор,
	|	ЗагрузкаНомеров.Recorder.ДокОснование.* AS ДокОснование,
	|	ЗагрузкаНомеров.Recorder.* AS Recorder,
	|	ЗагрузкаНомеров.Recorder.ДокОснование.ТипНомера.* AS ParentDocRoomType,
	|	ЗагрузкаНомеров.Recorder.ДокОснование.ВидРазмещения.* AS ParentDocAccommodationType,
	|	ЗагрузкаНомеров.Recorder.ДокОснование.RoomRateType.* AS ParentDocRoomRateType,
	|	ParentDocRoomRate.* AS ParentDocRoomRate,
	|	ЗаездНомеров AS ЗаездНомеров,
	|	ЗаездМест AS ЗаездМест,
	|	ЗаездДополнительныхМест AS ЗаездДополнительныхМест,
	|	ЗаездГостей AS GuestsCheckedIn}
	|TOTALS
	|	SUM(Количество),
	|	SUM(ЗаездГостей),
	|	SUM(ЗаездНомеров),
	|	SUM(ЗаездМест),
	|	SUM(ЗаездДополнительныхМест)
	|BY
	|	OVERALL,
	|	Гостиница,
	|	НомерРазмещения
	|{TOTALS BY
	|	AuthorOfAnnulation.*,
	|	Гостиница.* AS Гостиница,
	|	ЗагрузкаНомеров.CheckInAccountingDate AS CheckInAccountingDate,
	|	ЗагрузкаНомеров.CheckOutAccountingDate AS CheckOutAccountingDate,
	|	(HOUR(ЗагрузкаНомеров.Recorder.CheckInDate)) AS CheckInHour,
	|	(DAY(ЗагрузкаНомеров.Recorder.CheckInDate)) AS CheckInDay,
	|	(WEEK(ЗагрузкаНомеров.Recorder.CheckInDate)) AS CheckInWeek,
	|	(MONTH(ЗагрузкаНомеров.Recorder.CheckInDate)) AS CheckInMonth,
	|	(QUARTER(ЗагрузкаНомеров.Recorder.CheckInDate)) AS CheckInQuarter,
	|	(YEAR(ЗагрузкаНомеров.Recorder.CheckInDate)) AS CheckInYear,
	|	Клиент.* AS Клиент,
	|	СтатусРазмещения.* AS СтатусРазмещения,
	|	ВидРазмещения.* AS ВидРазмещения,
	|	Тариф.* AS Тариф,
	|	ТипНомера.* AS ТипНомера,
	|	НомерРазмещения.* AS НомерРазмещения,
	|	Контрагент.* AS Контрагент,
	|	ЗагрузкаНомеров.Recorder.ДокОснование.* AS ДокОснование,
	|	ЗагрузкаНомеров.Recorder.* AS Recorder,
	|	ЗагрузкаНомеров.Recorder.ТипКонтрагента.* AS ТипКонтрагента,
	|	ЗагрузкаНомеров.Recorder.Договор.* AS Договор,
	|	ЗагрузкаНомеров.Recorder.КонтактноеЛицо AS КонтактноеЛицо,
	|	ЗагрузкаНомеров.Recorder.Агент.* AS Агент,
	|	ГруппаГостей.* AS ГруппаГостей,
	|	ЗагрузкаНомеров.Recorder.ПутевкаКурсовка.* AS ПутевкаКурсовка,
	|	СтатусРазмещения.* AS СтатусРазмещения,
	|	ЗагрузкаНомеров.Recorder.КвотаНомеров.* AS КвотаНомеров,
	|	ЗагрузкаНомеров.Recorder.ТипКлиента.* AS ТипКлиента,
	|	ЗагрузкаНомеров.Recorder.МаретингНапрвл.* AS МаретингНапрвл,
	|	ЗагрузкаНомеров.Recorder.TripPurpose.* AS TripPurpose,
	|	ЗагрузкаНомеров.Recorder.ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
	|	ЗагрузкаНомеров.Recorder.RoomRateType.* AS RoomRateType,
	|	ЗагрузкаНомеров.Recorder.Автор.* AS Автор,
	|	PricePresentation AS PricePresentation,
	|	ЗагрузкаНомеров.Recorder.ДокОснование.ТипНомера.* AS ParentDocRoomType,
	|	ЗагрузкаНомеров.Recorder.ДокОснование.ВидРазмещения.* AS ParentDocAccommodationType,
	|	ЗагрузкаНомеров.Recorder.ДокОснование.RoomRateType.* AS ParentDocRoomRateType,
	|	ParentDocRoomRate.* AS ParentDocRoomRate,
	|	ЗагрузкаНомеров.Recorder.ДисконтКарт.* AS ДисконтКарт,
	|	ЗагрузкаНомеров.Recorder.ТипСкидки.* AS ТипСкидки,
	|	ЗагрузкаНомеров.Recorder.PlannedPaymentMethod.* AS PlannedPaymentMethod}";
	ReportBuilder.Text = QueryText;
	ReportBuilder.FillSettings();
	
	// Initialize report builder with default query
	vRB = New ReportBuilder(QueryText);
	vRBSettings = vRB.GetSettings(True, True, True, True, True);
	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
	
	// Set default report builder header text
	ReportBuilder.HeaderText = NStr("EN='Accommodation annulations audit';RU='Аудит аннуляций размещений';de='Buchprüfung der Annullierung von Unterbringungen'");
	
	// Fill report builder fields presentations from the report template
	//cmFillReportAttributesPresentations(ThisObject);
	
	// Reset report builder template
	ReportBuilder.Template = Неопределено;
КонецПроцедуры //pmInitializeReportBuilder

//-----------------------------------------------------------------------------
// Reports framework end
//-----------------------------------------------------------------------------
