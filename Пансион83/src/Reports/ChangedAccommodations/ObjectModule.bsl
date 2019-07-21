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
	If ShowInHouseOnly Тогда
		vParamPresentation = vParamPresentation + NStr("en='In-house guests only';ru='Только проживающие (невыселенные) гости';de='Nur übernachtende (nicht ausquartierte) Gäste'") + 
							 ";" + Chars.LF;
	EndIf;
	If ShowNotInHouseOnly Тогда
		vParamPresentation = vParamPresentation + NStr("en='Checked-out guests only';ru='Только выселенные гости';de='Nur ausquartierte Gäste'") + 
							 ";" + Chars.LF;
	EndIf;
	If ShowForeignersOnly Тогда
		vParamPresentation = vParamPresentation + NStr("en='Foreigners only';ru='Только иностранцы';de='Nur Ausländer'") + 
							 ";" + Chars.LF;
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
	ReportBuilder.Parameters.Вставить("qAccommodation", Перечисления.PeriodCheckTypes.Intersection);
	ReportBuilder.Parameters.Вставить("qRoom", Room);
	ReportBuilder.Parameters.Вставить("qRoomType", RoomType);
	ReportBuilder.Parameters.Вставить("qShowInHouseOnly", ShowInHouseOnly);
	ReportBuilder.Parameters.Вставить("qShowNotInHouseOnly", ShowNotInHouseOnly);
	ReportBuilder.Parameters.Вставить("qShowForeignersOnly", ShowForeignersOnly);
	ReportBuilder.Parameters.Вставить("qBaseCountry", ?(ЗначениеЗаполнено(Гостиница), Гостиница.Citizenship, Справочники.Countries.EmptyRef()));
	ReportBuilder.Parameters.Вставить("qEndOfTime", '39991231235959');
	ReportBuilder.Parameters.Вставить("qEmptyDate", '00010101');
	ReportBuilder.Parameters.Вставить("qEmptyClient", Справочники.Clients.EmptyRef());

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
	|	ЗагрузкаНомеров.Recorder.Гостиница AS Гостиница,
	|	ЗагрузкаНомеров.Recorder.НомерРазмещения AS НомерРазмещения,
	|	ЗагрузкаНомеров.Recorder.Контрагент AS Контрагент,
	|	ЗагрузкаНомеров.Recorder.СтатусРазмещения AS СтатусРазмещения,
	|	ЗагрузкаНомеров.Recorder.Клиент AS Клиент,
	|	ЗагрузкаНомеров.Recorder.CheckInDate AS CheckInDate,
	|	ЗагрузкаНомеров.Recorder.Продолжительность AS Продолжительность,
	|	ЗагрузкаНомеров.Recorder.CheckOutDate AS CheckOutDate,
	|	ЗагрузкаНомеров.Recorder.ТипНомера AS ТипНомера,
	|	ЗагрузкаНомеров.Recorder.ВидРазмещения AS ВидРазмещения,
	|	ЗагрузкаНомеров.Recorder.Тариф AS Тариф,
	|	ЗагрузкаНомеров.Recorder.Примечания AS Примечания,
	|	ЗагрузкаНомеров.Recorder.ГруппаГостей AS ГруппаГостей,
	|	ЗагрузкаНомеров.Recorder.PricePresentation AS PricePresentation,
	|	ЗагрузкаНомеров.FirstStateRoom AS FirstStateRoom,
	|	ЗагрузкаНомеров.FirstStateCheckInDate AS FirstStateCheckInDate,
	|	ЗагрузкаНомеров.FirstStateDuration AS FirstStateDuration,
	|	ЗагрузкаНомеров.FirstStateCheckOutDate AS FirstStateCheckOutDate,
	|	ЗагрузкаНомеров.Recorder.КоличествоЧеловек AS InHouseGuests,
	|	ЗагрузкаНомеров.Recorder.КоличествоНомеров AS ИспользованоНомеров,
	|	ЗагрузкаНомеров.Recorder.КоличествоМест AS ИспользованоМест,
	|	ЗагрузкаНомеров.Recorder.КолДопМест AS InHouseAdditionalBeds
	|{SELECT
	|	Гостиница.*,
	|	НомерРазмещения.*,
	|	ЗагрузкаНомеров.Recorder.ТипКонтрагента.* AS ТипКонтрагента,
	|	Контрагент.*,
	|	ЗагрузкаНомеров.Recorder.Договор.* AS Договор,
	|	ЗагрузкаНомеров.Recorder.КонтактноеЛицо AS КонтактноеЛицо,
	|	ЗагрузкаНомеров.Recorder.Агент.* AS Агент,
	|	ЗагрузкаНомеров.Recorder.ТипКлиента.* AS ТипКлиента,
	|	Клиент.*,
	|	CheckInDate,
	|	Продолжительность,
	|	CheckOutDate,
	|	ТипНомера.*,
	|	ВидРазмещения.*,
	|	ЗагрузкаНомеров.Recorder.RoomRateType.* AS RoomRateType,
	|	Тариф.*,
	|	PricePresentation,
	|	ЗагрузкаНомеров.Recorder.PlannedPaymentMethod.* AS PlannedPaymentMethod,
	|	FirstStateRoom.* AS FirstStateRoom,
	|	FirstStateCheckInDate AS FirstStateCheckInDate,
	|	FirstStateDuration AS FirstStateDuration,
	|	FirstStateCheckOutDate AS FirstStateCheckOutDate,
	|	InHouseGuests,
	|	ИспользованоНомеров,
	|	ИспользованоМест,
	|	InHouseAdditionalBeds,
	|	Примечания,
	|	ЗагрузкаНомеров.Recorder.Car AS Car,
	|	ГруппаГостей.*,
	|	СтатусРазмещения.*,
	|	ЗагрузкаНомеров.Recorder.IsMaster AS IsMaster,
	|	ЗагрузкаНомеров.Recorder.ПутевкаКурсовка.* AS ПутевкаКурсовка,
	|	ЗагрузкаНомеров.Recorder.КвотаНомеров.* AS КвотаНомеров,
	|	ЗагрузкаНомеров.Recorder.МаретингНапрвл.* AS МаретингНапрвл,
	|	ЗагрузкаНомеров.Recorder.TripPurpose.* AS TripPurpose,
	|	ЗагрузкаНомеров.Recorder.ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
	|	ЗагрузкаНомеров.Recorder.ДисконтКарт.* AS ДисконтКарт,
	|	ЗагрузкаНомеров.Recorder.ТипСкидки.* AS ТипСкидки,
	|	ЗагрузкаНомеров.Recorder.Скидка AS Скидка,
	|	ЗагрузкаНомеров.Recorder.КомиссияАгента AS КомиссияАгента,
	|	ЗагрузкаНомеров.Recorder.ВидКомиссииАгента AS ВидКомиссииАгента,
	|	ЗагрузкаНомеров.Recorder.КоличествоМестНомер AS КоличествоМестНомер,
	|	ЗагрузкаНомеров.Recorder.КоличествоГостейНомер AS КоличествоГостейНомер,
	|	ЗагрузкаНомеров.Recorder.ДокОснование.* AS ДокОснование,
	|	ЗагрузкаНомеров.Recorder.Автор.* AS Автор,
	|	ЗагрузкаНомеров.Recorder.* AS Recorder,
	|	ЗагрузкаНомеров.ForeignerRegistryRecord.* AS ForeignerRegistryRecord,
	|	(CASE
	|			WHEN ЗагрузкаНомеров.ForeignerRegistryRecord.MigrationCardDateTo <> &qEmptyDate
	|				THEN DATEDIFF(ЗагрузкаНомеров.ForeignerRegistryRecord.MigrationCardDateTo, RoomInventory.Recorder.CheckOutDate, DAY)
	|			ELSE 0
	|		END) AS MigrationCardDateToDeviance,
	|	(CASE
	|			WHEN ЗагрузкаНомеров.ForeignerRegistryRecord.VisaToDate <> &qEmptyDate
	|				THEN DATEDIFF(ЗагрузкаНомеров.ForeignerRegistryRecord.VisaToDate, RoomInventory.Recorder.CheckOutDate, DAY)
	|			ELSE 0
	|		END) AS VisaToDateDeviance,
	|	ЗагрузкаНомеров.Recorder.PointInTime AS PointInTime}
	|FROM
	|	(SELECT
	|		ChangedAccommodations.Recorder AS Recorder,
	|		ForeignerRegistryRecords.ForeignerRegistryRecord AS ForeignerRegistryRecord,
	|		ChangedAccommodations.FirstStateCheckInDate AS FirstStateCheckInDate,
	|		ChangedAccommodations.FirstStateDuration AS FirstStateDuration,
	|		ChangedAccommodations.FirstStateCheckOutDate AS FirstStateCheckOutDate,
	|		ChangedAccommodations.FirstStateRoom AS FirstStateRoom
	|	FROM
	|		(SELECT
	|			ИсторияИзмененийРазмещения.Размещение AS Recorder,
	|			FirstState.CheckInDate AS FirstStateCheckInDate,
	|			FirstState.Продолжительность AS FirstStateDuration,
	|			FirstState.CheckOutDate AS FirstStateCheckOutDate,
	|			FirstState.НомерРазмещения AS FirstStateRoom
	|		FROM
	|			InformationRegister.ИсторияИзмененийРазмещения.SliceLast(
	|					&qPeriodTo,
	|					Гостиница IN HIERARCHY (&qHotel)
	|						AND НомерРазмещения IN HIERARCHY (&qRoom)
	|						AND ТипНомера IN HIERARCHY (&qRoomType)
	|						AND (ISNULL(Размещение.СтатусРазмещения.ЭтоГости, FALSE)
	|							OR NOT &qShowInHouseOnly)
	|						AND (NOT ISNULL(Размещение.СтатусРазмещения.ЭтоГости, FALSE)
	|							OR NOT &qShowNotInHouseOnly)
	|						AND (ISNULL(Клиент.Гражданство, &qBaseCountry) <> &qBaseCountry
	|								AND &qShowForeignersOnly
	|							OR NOT &qShowForeignersOnly)) AS ИсторияИзмененийРазмещения
	|				LEFT JOIN (SELECT
	|					FirstStateAccommodations.Размещение AS Размещение,
	|					FirstStateAccommodations.Клиент AS Клиент,
	|					FirstStateAccommodations.НомерРазмещения AS НомерРазмещения,
	|					BEGINOFPERIOD(FirstStateAccommodations.CheckInDate, DAY) AS CheckInDate,
	|					FirstStateAccommodations.Продолжительность AS Продолжительность,
	|					BEGINOFPERIOD(FirstStateAccommodations.CheckOutDate, DAY) AS CheckOutDate
	|				FROM
	|					InformationRegister.ИсторияИзмененийРазмещения.SliceLast(
	|							&qPeriodFrom,
	|							Гостиница IN HIERARCHY (&qHotel)
	|								AND НомерРазмещения IN HIERARCHY (&qRoom)
	|								AND ТипНомера IN HIERARCHY (&qRoomType)) AS FirstStateAccommodations) AS FirstState
	|				ON ИсторияИзмененийРазмещения.Размещение = FirstState.Размещение
	|		WHERE
	|			NOT FirstState.Размещение IS NULL 
	|			AND NOT ИсторияИзмененийРазмещения.Размещение IN
	|						(SELECT
	|							NotChangedAccommodations.Размещение
	|						FROM
	|							(SELECT
	|								LastState.Размещение,
	|								LastState.Клиент,
	|								LastState.НомерРазмещения,
	|								BEGINOFPERIOD(LastState.CheckInDate, DAY) AS CheckInDate,
	|								BEGINOFPERIOD(LastState.CheckOutDate, DAY) AS CheckOutDate
	|							FROM
	|								InformationRegister.ИсторияИзмененийРазмещения.SliceLast(&qPeriodTo, Гостиница IN HIERARCHY (&qHotel)
	|									AND НомерРазмещения IN HIERARCHY (&qRoom)
	|									AND ТипНомера IN HIERARCHY (&qRoomType)) AS LastState INNER JOIN (SELECT
	|										FirstStateAccommodations.Размещение,
	|										FirstStateAccommodations.Клиент,
	|										FirstStateAccommodations.НомерРазмещения,
	|										BEGINOFPERIOD(FirstStateAccommodations.CheckInDate, DAY) AS CheckInDate,
	|										BEGINOFPERIOD(FirstStateAccommodations.CheckOutDate, DAY) AS CheckOutDate
	|									FROM
	|										InformationRegister.ИсторияИзмененийРазмещения.SliceLast(&qPeriodFrom, Гостиница IN HIERARCHY (&qHotel)
	|											AND НомерРазмещения IN HIERARCHY (&qRoom)
	|											AND ТипНомера IN HIERARCHY (&qRoomType)) AS FirstStateAccommodations
	|									) AS FirstState
	|									ON
	|										LastState.Размещение = FirstState.Размещение
	|											AND LastState.Клиент = FirstState.Клиент
	|											AND LastState.НомерРазмещения = FirstState.НомерРазмещения
	|											AND BEGINOFPERIOD(LastState.CheckInDate, DAY) = BEGINOFPERIOD(FirstState.CheckInDate, DAY)
	|											AND BEGINOFPERIOD(LastState.CheckOutDate, DAY) = BEGINOFPERIOD(FirstState.CheckOutDate, DAY)
	|							) AS NotChangedAccommodations
	|						GROUP BY
	|										NotChangedAccommodations.Размещение)
	|		
	|		UNION ALL
	|		
	|		SELECT
	|			ChangeRoomAccommodations.Recorder,
	|			ChangeRoomAccommodations.ПериодС,
	|			ChangeRoomAccommodations.PeriodDuration,
	|			ChangeRoomAccommodations.ПериодПо,
	|			ChangeRoomAccommodations.НомерРазмещения
	|		FROM
	|			AccumulationRegister.ЗагрузкаНомеров AS ChangeRoomAccommodations
	|		WHERE
	|			ChangeRoomAccommodations.IsAccommodation
	|			AND ChangeRoomAccommodations.RecordType = VALUE(AccumulationRecordType.Expense)
	|			AND ChangeRoomAccommodations.IsRoomChange
	|			AND ChangeRoomAccommodations.ПериодС >= &qPeriodFrom
	|			AND ChangeRoomAccommodations.ПериодС < &qPeriodTo
	|			AND ChangeRoomAccommodations.Гостиница IN HIERARCHY(&qHotel)
	|			AND ChangeRoomAccommodations.НомерРазмещения IN HIERARCHY(&qRoom)
	|			AND ChangeRoomAccommodations.ТипНомера IN HIERARCHY(&qRoomType)
	|			AND (ChangeRoomAccommodations.ЭтоГости
	|					OR NOT &qShowInHouseOnly)
	|			AND (NOT ChangeRoomAccommodations.ЭтоГости
	|					OR NOT &qShowNotInHouseOnly)
	|			AND (ISNULL(ChangeRoomAccommodations.Клиент.Гражданство, &qBaseCountry) <> &qBaseCountry
	|						AND &qShowForeignersOnly
	|					OR NOT &qShowForeignersOnly)
	|		
	|		UNION ALL
	|		
	|		SELECT
	|			SameDayCheckInAccommodations.Recorder,
	|			SameDayCheckInAccommodations.ПериодС,
	|			SameDayCheckInAccommodations.PeriodDuration,
	|			SameDayCheckInAccommodations.ПериодПо,
	|			SameDayCheckInAccommodations.НомерРазмещения
	|		FROM
	|			AccumulationRegister.ЗагрузкаНомеров AS SameDayCheckInAccommodations
	|				INNER JOIN (SELECT
	|					PrevCheckOuts.Клиент AS Клиент,
	|					MAX(PrevCheckOuts.ПериодПо) AS CheckOutDate
	|				FROM
	|					AccumulationRegister.ЗагрузкаНомеров AS PrevCheckOuts
	|				WHERE
	|					PrevCheckOuts.IsAccommodation
	|					AND PrevCheckOuts.RecordType = VALUE(AccumulationRecordType.Expense)
	|					AND PrevCheckOuts.Клиент <> &qEmptyClient
	|					AND PrevCheckOuts.ЭтоВыезд
	|					AND PrevCheckOuts.ПериодПо >= &qPeriodFrom
	|					AND PrevCheckOuts.ПериодПо < &qPeriodTo
	|					AND PrevCheckOuts.Гостиница IN HIERARCHY(&qHotel)
	|				
	|				GROUP BY
	|					PrevCheckOuts.Клиент) AS GuestLastCheckOut
	|				ON SameDayCheckInAccommodations.Клиент = GuestLastCheckOut.Клиент
	|					AND SameDayCheckInAccommodations.CheckOutDate <> GuestLastCheckOut.CheckOutDate
	|					AND (BEGINOFPERIOD(SameDayCheckInAccommodations.CheckInDate, DAY) = BEGINOFPERIOD(GuestLastCheckOut.CheckOutDate, DAY))
	|		WHERE
	|			SameDayCheckInAccommodations.IsAccommodation
	|			AND SameDayCheckInAccommodations.RecordType = VALUE(AccumulationRecordType.Expense)
	|			AND SameDayCheckInAccommodations.Клиент <> &qEmptyClient
	|			AND SameDayCheckInAccommodations.ЭтоЗаезд
	|			AND SameDayCheckInAccommodations.CheckInDate >= &qPeriodFrom
	|			AND SameDayCheckInAccommodations.CheckInDate < &qPeriodTo
	|			AND SameDayCheckInAccommodations.Гостиница IN HIERARCHY(&qHotel)
	|			AND SameDayCheckInAccommodations.НомерРазмещения IN HIERARCHY(&qRoom)
	|			AND SameDayCheckInAccommodations.ТипНомера IN HIERARCHY(&qRoomType)
	|			AND (SameDayCheckInAccommodations.ЭтоГости
	|					OR NOT &qShowInHouseOnly)
	|			AND (NOT SameDayCheckInAccommodations.ЭтоГости
	|					OR NOT &qShowNotInHouseOnly)
	|			AND (ISNULL(SameDayCheckInAccommodations.Клиент.Гражданство, &qBaseCountry) <> &qBaseCountry
	|						AND &qShowForeignersOnly
	|					OR NOT &qShowForeignersOnly)) AS ChangedAccommodations
	|			LEFT JOIN InformationRegister.AccommodationForeignerRegistryRecords.SliceLast(&qEndOfTime, ) AS ForeignerRegistryRecords
	|			ON ChangedAccommodations.Recorder = ForeignerRegistryRecords.Размещение
	|	
	|	GROUP BY
	|		ChangedAccommodations.Recorder,
	|		ForeignerRegistryRecords.ForeignerRegistryRecord,
	|		ChangedAccommodations.FirstStateCheckInDate,
	|		ChangedAccommodations.FirstStateDuration,
	|		ChangedAccommodations.FirstStateCheckOutDate,
	|		ChangedAccommodations.FirstStateRoom) AS ЗагрузкаНомеров
	|{WHERE
	|	ЗагрузкаНомеров.Recorder.* AS Recorder,
	|	ЗагрузкаНомеров.ForeignerRegistryRecord.* AS ForeignerRegistryRecord,
	|	ЗагрузкаНомеров.Recorder.Гостиница.* AS Гостиница,
	|	ЗагрузкаНомеров.Recorder.ТипНомера.* AS ТипНомера,
	|	ЗагрузкаНомеров.Recorder.НомерРазмещения.* AS НомерРазмещения,
	|	ЗагрузкаНомеров.Recorder.Контрагент.* AS Контрагент,
	|	ЗагрузкаНомеров.Recorder.ТипКонтрагента AS ТипКонтрагента,
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
	|	ЗагрузкаНомеров.FirstStateRoom.* AS FirstStateRoom,
	|	ЗагрузкаНомеров.FirstStateCheckInDate AS FirstStateCheckInDate,
	|	ЗагрузкаНомеров.FirstStateDuration AS FirstStateDuration,
	|	ЗагрузкаНомеров.FirstStateCheckOutDate AS FirstStateCheckOutDate,
	|	ЗагрузкаНомеров.Recorder.КоличествоЧеловек AS InHouseGuests,
	|	ЗагрузкаНомеров.Recorder.КоличествоНомеров AS ИспользованоНомеров,
	|	ЗагрузкаНомеров.Recorder.КоличествоМест AS ИспользованоМест,
	|	ЗагрузкаНомеров.Recorder.КолДопМест AS InHouseAdditionalBeds,
	|	ЗагрузкаНомеров.Recorder.КвотаНомеров.* AS КвотаНомеров,
	|	ЗагрузкаНомеров.Recorder.ТипКлиента.* AS ТипКлиента,
	|	ЗагрузкаНомеров.Recorder.Клиент.* AS Клиент,
	|	ЗагрузкаНомеров.Recorder.МаретингНапрвл.* AS МаретингНапрвл,
	|	ЗагрузкаНомеров.Recorder.TripPurpose.* AS TripPurpose,
	|	ЗагрузкаНомеров.Recorder.ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
	|	ЗагрузкаНомеров.Recorder.RoomRateType.* AS RoomRateType,
	|	ЗагрузкаНомеров.Recorder.Тариф.* AS Тариф,
	|	ЗагрузкаНомеров.Recorder.PricePresentation AS PricePresentation,
	|	ЗагрузкаНомеров.Recorder.ДисконтКарт.* AS ДисконтКарт,
	|	ЗагрузкаНомеров.Recorder.ТипСкидки.* AS ТипСкидки,
	|	ЗагрузкаНомеров.Recorder.Скидка AS Скидка,
	|	ЗагрузкаНомеров.Recorder.PlannedPaymentMethod.* AS PlannedPaymentMethod,
	|	ЗагрузкаНомеров.Recorder.Car AS Car,
	|	ЗагрузкаНомеров.Recorder.Примечания AS Примечания,
	|	ЗагрузкаНомеров.Recorder.Автор.* AS Автор,
	|	ЗагрузкаНомеров.Recorder.КомиссияАгента AS КомиссияАгента,
	|	ЗагрузкаНомеров.Recorder.ВидКомиссииАгента.* AS ВидКомиссииАгента,
	|	ЗагрузкаНомеров.Recorder.IsMaster AS IsMaster,
	|	(CASE
	|			WHEN ЗагрузкаНомеров.ForeignerRegistryRecord.MigrationCardDateTo <> &qEmptyDate
	|				THEN DATEDIFF(ЗагрузкаНомеров.ForeignerRegistryRecord.MigrationCardDateTo, RoomInventory.Recorder.CheckOutDate, DAY)
	|			ELSE 0
	|		END) AS MigrationCardDateToDeviance,
	|	(CASE
	|			WHEN ЗагрузкаНомеров.ForeignerRegistryRecord.VisaToDate <> &qEmptyDate
	|				THEN DATEDIFF(ЗагрузкаНомеров.ForeignerRegistryRecord.VisaToDate, RoomInventory.Recorder.CheckOutDate, DAY)
	|			ELSE 0
	|		END) AS VisaToDateDeviance,
	|	ЗагрузкаНомеров.Recorder.СтатусРазмещения.ЭтоЗаезд AS ЭтоЗаезд,
	|	ЗагрузкаНомеров.Recorder.СтатусРазмещения.ЭтоВыезд AS ЭтоВыезд,
	|	ЗагрузкаНомеров.Recorder.СтатусРазмещения.IsRoomChange AS IsRoomChange,
	|	ЗагрузкаНомеров.Recorder.СтатусРазмещения.ЭтоГости AS IsInHouse}
	|
	|ORDER BY
	|	Гостиница,
	|	НомерРазмещения,
	|	CheckInDate,
	|	Клиент
	|{ORDER BY
	|	ЗагрузкаНомеров.Recorder.* AS Recorder,
	|	ЗагрузкаНомеров.ForeignerRegistryRecord.* AS ForeignerRegistryRecord,
	|	Контрагент.* AS Контрагент,
	|	ЗагрузкаНомеров.Recorder.ТипКонтрагента.* AS ТипКонтрагента,
	|	ЗагрузкаНомеров.Recorder.Договор.* AS Договор,
	|	ЗагрузкаНомеров.Recorder.Агент.* AS Агент,
	|	ГруппаГостей.* AS ГруппаГостей,
	|	Клиент.* AS Клиент,
	|	ЗагрузкаНомеров.Recorder.МаретингНапрвл.* AS МаретингНапрвл,
	|	ЗагрузкаНомеров.Recorder.TripPurpose.* AS TripPurpose,
	|	ЗагрузкаНомеров.Recorder.ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
	|	Тариф.* AS Тариф,
	|	ЗагрузкаНомеров.Recorder.RoomRateType.* AS RoomRateType,
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
	|	ЗагрузкаНомеров.Recorder.RoomRateType.* AS RoomRateType,
	|	Тариф.* AS Тариф,
	|	PricePresentation AS PricePresentation,
	|	ЗагрузкаНомеров.Recorder.Автор.* AS Автор,
	|	FirstStateRoom.* AS FirstStateRoom,
	|	FirstStateCheckInDate AS FirstStateCheckInDate,
	|	FirstStateDuration AS FirstStateDuration,
	|	FirstStateCheckOutDate AS FirstStateCheckOutDate,
	|	InHouseGuests AS InHouseGuests,
	|	ИспользованоНомеров AS ИспользованоНомеров,
	|	ИспользованоМест AS ИспользованоМест,
	|	InHouseAdditionalBeds AS InHouseAdditionalBeds,
	|	ЗагрузкаНомеров.Recorder.КвотаНомеров.* AS RoomQuota}
	|TOTALS
	|	SUM(InHouseGuests),
	|	SUM(ИспользованоНомеров),
	|	SUM(ИспользованоМест),
	|	SUM(InHouseAdditionalBeds)
	|BY
	|	OVERALL,
	|	Гостиница,
	|	НомерРазмещения
	|{TOTALS BY
	|	Гостиница.* AS Гостиница,
	|	ТипНомера.* AS ТипНомера,
	|	НомерРазмещения.* AS НомерРазмещения,
	|	Контрагент.* AS Контрагент,
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
	|	Тариф.* AS Тариф,
	|	PricePresentation AS PricePresentation,
	|	FirstStateRoom.* AS FirstStateRoom,
	|	ЗагрузкаНомеров.Recorder.ДисконтКарт.* AS ДисконтКарт,
	|	ЗагрузкаНомеров.Recorder.ТипСкидки.* AS ТипСкидки,
	|	ЗагрузкаНомеров.Recorder.Автор.* AS Автор,
	|	ЗагрузкаНомеров.Recorder.* AS Recorder,
	|	ЗагрузкаНомеров.ForeignerRegistryRecord.* AS ForeignerRegistryRecord,
	|	ЗагрузкаНомеров.Recorder.PlannedPaymentMethod.* AS PlannedPaymentMethod}";
	ReportBuilder.Text = QueryText;
	ReportBuilder.FillSettings();
	
	// Initialize report builder with default query
	vRB = New ReportBuilder(QueryText);
	vRBSettings = vRB.GetSettings(True, True, True, True, True);
	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
	
	// Set default report builder header text
	ReportBuilder.HeaderText = NStr("EN='List of changed accommodations';RU='Список измененных размещений';de='Liste der veränderten Unterbringungen'");
	
	// Fill report builder fields presentations from the report template
	
	
	// Reset report builder template
	ReportBuilder.Template = Неопределено;
КонецПроцедуры //pmInitializeReportBuilder

//-----------------------------------------------------------------------------
// Reports framework end
//-----------------------------------------------------------------------------
