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
//	If НЕ ЗначениеЗаполнено(PeriodCheckType) Тогда
//		PeriodCheckType = Перечисления.PeriodCheckTypes.Intersection;
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
//	If НЕ ЗначениеЗаполнено(PeriodCheckType) Тогда
//		vParamPresentation = vParamPresentation + NStr("en='Report period check type is not set';ru='Вид проверки периода отчета не установлен';de='Art der Kontrolle des Berichtszeitraums nicht festgelegt'") + 
//		                     ";" + Chars.LF;
//	ElsIf PeriodCheckType = Перечисления.PeriodCheckTypes.Intersection Тогда
//		vParamPresentation = vParamPresentation + NStr("en='Guests in rooms for the period selected';ru='Отбор гостей проживавших в выбранном периоде';de='Auswahl von Gästen die im ausgewählten Zeitraum übernachten'") + 
//		                     ";" + Chars.LF;
//	ElsIf PeriodCheckType = Перечисления.PeriodCheckTypes.StartsInPeriod Тогда
//		vParamPresentation = vParamPresentation + NStr("en='Guests checked in during the period selected';ru='Отбор гостей заехавших в выбранном периоде';de='Auswahl von Gästen, die im ausgewählten Zeitraum angereist sind'") + 
//		                     ";" + Chars.LF;
//	ElsIf PeriodCheckType = Перечисления.PeriodCheckTypes.EndsInPeriod Тогда
//		vParamPresentation = vParamPresentation + NStr("en='Guests checked out during the period selected';ru='Отбор гостей выехавших в выбранном периоде';de='Auswahl von Gästen, die im ausgewählten Zeitraum abgereist sind'") + 
//		                     ";" + Chars.LF;
//	ElsIf PeriodCheckType = Перечисления.PeriodCheckTypes.StartsOrEndsInPeriod Тогда
//		vParamPresentation = vParamPresentation + NStr("en='Guests checked in or checked out during the period selected';ru='Отбор гостей заехавших или выехавших в выбранном периоде';de='Auswahl von Gästen, die im ausgewählten Zeitraum an- oder abgereist sind'") + 
//		                     ";" + Chars.LF;
//	ElsIf PeriodCheckType = Перечисления.PeriodCheckTypes.DocDateInPeriod Тогда
//		vParamPresentation = vParamPresentation + NStr("en='Guests registered during the period selected';ru='Отбор гостей зарегистрированных в выбранном периоде';de='Auswahl von im ausgewählten Zeitraum registrierten Gästen'") + 
//		                     ";" + Chars.LF;
//	Endif;		
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
//	If ЗначениеЗаполнено(Guest) Тогда
//		If НЕ Guest.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("ru = 'Гость '; en = 'Guest '") + 
//			                     TrimAll(Guest.Description) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("ru = 'Группа клиентов '; en = 'Clients folder '") + 
//			                     TrimAll(Guest.Description) + 
//			                     ";" + Chars.LF;
//		EndIf;
//	EndIf;
//	If ShowInHouseOnly Тогда
//		vParamPresentation = vParamPresentation + NStr("en='In-house guests only';ru='Только проживающие (невыселенные) гости';de='Nur übernachtende (nicht ausquartierte) Gäste'") + 
//							 ";" + Chars.LF;
//	EndIf;
//	If ShowNotInHouseOnly Тогда
//		vParamPresentation = vParamPresentation + NStr("en='Checked-out guests only';ru='Только выселенные гости';de='Nur ausquartierte Gäste'") + 
//							 ";" + Chars.LF;
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
//	ReportBuilder.Parameters.Вставить("qBegOfPeriodFrom", BegOfDay(PeriodFrom));
//	ReportBuilder.Parameters.Вставить("qPeriodTo", PeriodTo);
//	ReportBuilder.Parameters.Вставить("qEndOfPeriodTo", EndOfDay(PeriodTo));
//	ReportBuilder.Parameters.Вставить("qPeriodCheckType", PeriodCheckType);
//	ReportBuilder.Parameters.Вставить("qAccommodation", Перечисления.PeriodCheckTypes.Intersection);
//	ReportBuilder.Parameters.Вставить("qCheckIn", Перечисления.PeriodCheckTypes.StartsInPeriod);
//	ReportBuilder.Parameters.Вставить("qCheckOut", Перечисления.PeriodCheckTypes.EndsInPeriod);
//	ReportBuilder.Parameters.Вставить("qCheckInOrCheckOut", Перечисления.PeriodCheckTypes.StartsOrEndsInPeriod);
//	ReportBuilder.Parameters.Вставить("qDocDateInPeriod", Перечисления.PeriodCheckTypes.DocDateInPeriod);
//	ReportBuilder.Parameters.Вставить("qRoom", ГруппаНомеров);
//	ReportBuilder.Parameters.Вставить("qRoomType", RoomType);
//	ReportBuilder.Parameters.Вставить("qShowInHouseOnly", ShowInHouseOnly);
//	ReportBuilder.Parameters.Вставить("qShowNotInHouseOnly", ShowNotInHouseOnly);
//	ReportBuilder.Parameters.Вставить("qEndOfTime", '39991231235959');
//	ReportBuilder.Parameters.Вставить("qEmptyDate", '00010101');
//	ReportBuilder.Parameters.Вставить("qGuest", Guest);
//	ReportBuilder.Parameters.Вставить("qGuestIsEmpty", НЕ ЗначениеЗаполнено(Guest));
//	ReportBuilder.Parameters.Вставить("qEmptyCustomer", Справочники.Customers.EmptyRef());
//	ReportBuilder.Parameters.Вставить("qIndividualsCustomerFolder", Справочники.Customers.КонтрагентПоУмолчанию);
//	ReportBuilder.Parameters.Вставить("qEmptyForeignerRegistryRecord", Documents.ForeignerRegistryRecord.EmptyRef());
//	ReportBuilder.Parameters.Вставить("qEmptyClientDataScan", Documents.ДанныеКлиента.EmptyRef());
//	If ReportBuilder.SelectedFields.Find("ClientSumBalance") <> Неопределено Тогда
//		ReportBuilder.Parameters.Вставить("qShowBalances", True);
//	Else
//		ReportBuilder.Parameters.Вставить("qShowBalances", False);
//	EndIf;
//	If ReportBuilder.SelectedFields.Find("Продажи") <> Неопределено Or ReportBuilder.SelectedFields.Find("ДоходНомеров") <> Неопределено Тогда
//		ReportBuilder.Parameters.Вставить("qShowSales", True);
//	Else
//		ReportBuilder.Parameters.Вставить("qShowSales", False);
//	EndIf;
//	vShowFRR = False;
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
//	|	ЗагрузкаНомеров.Recorder.Гостиница AS Гостиница,
//	|	ЗагрузкаНомеров.НомерРазмещения AS НомерРазмещения,
//	|	ЗагрузкаНомеров.Recorder.Контрагент AS Контрагент,
//	|	ЗагрузкаНомеров.Recorder.СтатусРазмещения AS СтатусРазмещения,
//	|	ЗагрузкаНомеров.Recorder.Клиент AS Клиент,
//	|	ЗагрузкаНомеров.CheckInDate AS CheckInDate,
//	|	ЗагрузкаНомеров.Продолжительность AS Продолжительность,
//	|	ЗагрузкаНомеров.CheckOutDate AS CheckOutDate,
//	|	ЗагрузкаНомеров.ТипНомера AS ТипНомера,
//	|	ЗагрузкаНомеров.ВидРазмещения AS ВидРазмещения,
//	|	ЗагрузкаНомеров.Recorder.Тариф AS Тариф,
//	|	ЗагрузкаНомеров.Recorder.Примечания AS Примечания,
//	|	ЗагрузкаНомеров.Recorder.ГруппаГостей AS ГруппаГостей,
//	|	ЗагрузкаНомеров.InHouseGuests AS InHouseGuests,
//	|	ЗагрузкаНомеров.ИспользованоНомеров AS ИспользованоНомеров,
//	|	ЗагрузкаНомеров.ИспользованоМест AS ИспользованоМест,
//	|	ЗагрузкаНомеров.InHouseAdditionalBeds AS InHouseAdditionalBeds,
//	|	ЗагрузкаНомеров.Recorder.ПутевкаКурсовка.Сумма AS HotelProductSum,
//	|	ЗагрузкаНомеров.Recorder.PricePresentation AS PricePresentation,
//	|	ISNULL(GuestPeriodSales.Продажи, 0) AS Продажи,
//	|	ISNULL(GuestPeriodSales.ДоходНомеров, 0) AS ДоходНомеров,
//	|	ISNULL(ClientBalances.ClientSumBalance, 0) AS ClientSumBalance
//	|{SELECT
//	|	Гостиница.*,
//	|	НомерРазмещения.*,
//	|	ЗагрузкаНомеров.Recorder.ТипКонтрагента.* AS ТипКонтрагента,
//	|	Контрагент.*,
//	|	ЗагрузкаНомеров.Recorder.Договор.* AS Договор,
//	|	ЗагрузкаНомеров.Recorder.КонтактноеЛицо AS КонтактноеЛицо,
//	|	ЗагрузкаНомеров.Recorder.Агент.* AS Агент,
//	|	ЗагрузкаНомеров.Recorder.ТипКлиента.* AS ТипКлиента,
//	|	Клиент.*,
//	|	CheckInDate,
//	|	Продолжительность,
//	|	CheckOutDate,
//	|	ЗагрузкаНомеров.CheckInAccountingDate AS CheckInAccountingDate,
//	|	ЗагрузкаНомеров.CheckOutAccountingDate AS CheckOutAccountingDate,
//	|	(HOUR(ЗагрузкаНомеров.Recorder.CheckInDate)) AS CheckInHour,
//	|	(DAY(ЗагрузкаНомеров.Recorder.CheckInDate)) AS CheckInDay,
//	|	(WEEK(ЗагрузкаНомеров.Recorder.CheckInDate)) AS CheckInWeek,
//	|	(MONTH(ЗагрузкаНомеров.Recorder.CheckInDate)) AS CheckInMonth,
//	|	(QUARTER(ЗагрузкаНомеров.Recorder.CheckInDate)) AS CheckInQuarter,
//	|	(YEAR(ЗагрузкаНомеров.Recorder.CheckInDate)) AS CheckInYear,
//	|	ТипНомера.*,
//	|	ВидРазмещения.*,
//	|	ЗагрузкаНомеров.Recorder.RoomRateType.* AS RoomRateType,
//	|	Тариф.*,
//	|	PricePresentation,
//	|	ЗагрузкаНомеров.Recorder.PlannedPaymentMethod.* AS PlannedPaymentMethod,
//	|	InHouseGuests,
//	|	ИспользованоНомеров,
//	|	ИспользованоМест,
//	|	InHouseAdditionalBeds,
//	|	Примечания,
//	|	ЗагрузкаНомеров.Recorder.Car AS Car,
//	|	ГруппаГостей.*,
//	|	СтатусРазмещения.*,
//	|	ЗагрузкаНомеров.Recorder.IsMaster AS IsMaster,
//	|	ЗагрузкаНомеров.Recorder.ПутевкаКурсовка.* AS ПутевкаКурсовка,
//	|	ЗагрузкаНомеров.Recorder.КвотаНомеров.* AS КвотаНомеров,
//	|	ЗагрузкаНомеров.Recorder.МаретингНапрвл.* AS МаретингНапрвл,
//	|	ЗагрузкаНомеров.Recorder.TripPurpose.* AS TripPurpose,
//	|	ЗагрузкаНомеров.Recorder.ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
//	|	ЗагрузкаНомеров.Recorder.ДисконтКарт.* AS ДисконтКарт,
//	|	ЗагрузкаНомеров.Recorder.ТипСкидки.* AS ТипСкидки,
//	|	ЗагрузкаНомеров.Recorder.Скидка AS Скидка,
//	|	ЗагрузкаНомеров.Recorder.КомиссияАгента AS КомиссияАгента,
//	|	ЗагрузкаНомеров.Recorder.ВидКомиссииАгента AS ВидКомиссииАгента,
//	|	ЗагрузкаНомеров.Recorder.RoomQuantity AS RoomQuantity,
//	|	ЗагрузкаНомеров.Recorder.КоличествоМестНомер AS КоличествоМестНомер,
//	|	ЗагрузкаНомеров.Recorder.КоличествоГостейНомер AS КоличествоГостейНомер,
//	|	HotelProductSum,
//	|	ЗагрузкаНомеров.Recorder.ПутевкаКурсовка.Валюта.* AS HotelProductCurrency,
//	|	ЗагрузкаНомеров.Recorder.ДокОснование.* AS ДокОснование,
//	|	ЗагрузкаНомеров.Recorder.Автор.* AS Автор,
//	|	ЗагрузкаНомеров.Recorder.* AS Recorder,
//	|	ЗагрузкаНомеров.ForeignerRegistryRecord.* AS ForeignerRegistryRecord,
//	|	ЗагрузкаНомеров.ClientDataScan.* AS ClientDataScan,
//	|	(CASE
//	|			WHEN ЗагрузкаНомеров.ForeignerRegistryRecord.MigrationCardDateTo <> &qEmptyDate
//	|				THEN DATEDIFF(ЗагрузкаНомеров.ForeignerRegistryRecord.MigrationCardDateTo, RoomInventory.Recorder.CheckOutDate, DAY)
//	|			ELSE 0
//	|		END) AS MigrationCardDateToDeviance,
//	|	(CASE
//	|			WHEN ЗагрузкаНомеров.ForeignerRegistryRecord.VisaToDate <> &qEmptyDate
//	|				THEN DATEDIFF(ЗагрузкаНомеров.ForeignerRegistryRecord.VisaToDate, RoomInventory.Recorder.CheckOutDate, DAY)
//	|			ELSE 0
//	|		END) AS VisaToDateDeviance,
//	|	ЗагрузкаНомеров.Recorder.PointInTime AS PointInTime,
//	|	Продажи,
//	|	ДоходНомеров,
//	|	ClientSumBalance,
//	|	(NULL) AS EmptyColumn}
//	|FROM
//	|	(SELECT
//	|		RoomInventoryPeriods.Recorder AS Recorder,
//	|		RoomInventoryPeriods.НомерРазмещения AS НомерРазмещения,
//	|		RoomInventoryPeriods.ТипНомера AS ТипНомера,
//	|		RoomInventoryPeriods.ВидРазмещения AS ВидРазмещения,
//	|		RoomInventoryPeriods.ПериодС AS CheckInDate,
//	|		RoomInventoryPeriods.PeriodDuration AS Продолжительность,
//	|		RoomInventoryPeriods.ПериодПо AS CheckOutDate,
//	|		RoomInventoryPeriods.CheckInAccountingDate AS CheckInAccountingDate,
//	|		RoomInventoryPeriods.CheckOutAccountingDate AS CheckOutAccountingDate,
//	|		CASE
//	|			WHEN ForeignerRegistryRecords.ForeignerRegistryRecord IS NULL 
//	|				THEN &qEmptyForeignerRegistryRecord
//	|			ELSE ForeignerRegistryRecords.ForeignerRegistryRecord
//	|		END AS ForeignerRegistryRecord,
//	|		CASE
//	|			WHEN ДанныеКлиента.Ref IS NULL 
//	|				THEN &qEmptyClientDataScan
//	|			ELSE ДанныеКлиента.Ref
//	|		END AS ClientDataScan,
//	|		MAX(RoomInventoryPeriods.InHouseGuests) AS InHouseGuests,
//	|		MAX(RoomInventoryPeriods.ИспользованоНомеров) AS ИспользованоНомеров,
//	|		MAX(RoomInventoryPeriods.ИспользованоМест) AS ИспользованоМест,
//	|		MAX(RoomInventoryPeriods.InHouseAdditionalBeds) AS InHouseAdditionalBeds
//	|	FROM
//	|		AccumulationRegister.ЗагрузкаНомеров AS RoomInventoryPeriods
//	|			LEFT JOIN InformationRegister.AccommodationForeignerRegistryRecords.SliceLast(&qEndOfTime, &qShowFRR) AS ForeignerRegistryRecords
//	|			ON RoomInventoryPeriods.Recorder = ForeignerRegistryRecords.Размещение
//	|			LEFT JOIN Document.ДанныеКлиента AS ДанныеКлиента
//	|			ON RoomInventoryPeriods.Recorder = ДанныеКлиента.ДокОснование 
//	|				AND (ДанныеКлиента.Posted) AND &qShowCDS
//	|	WHERE
//	|		RoomInventoryPeriods.RecordType = VALUE(AccumulationRecordType.Expense)
//	|		AND RoomInventoryPeriods.IsAccommodation = TRUE
//	|		AND RoomInventoryPeriods.Гостиница IN HIERARCHY(&qHotel)
//	|		AND RoomInventoryPeriods.НомерРазмещения IN HIERARCHY(&qRoom)
//	|		AND RoomInventoryPeriods.ТипНомера IN HIERARCHY(&qRoomType)
//	|		AND (&qGuestIsEmpty
//	|				OR RoomInventoryPeriods.Клиент IN HIERARCHY (&qGuest))
//	|		AND (ISNULL(RoomInventoryPeriods.СтатусРазмещения.ЭтоГости, FALSE)
//	|				OR NOT &qShowInHouseOnly)
//	|		AND (NOT ISNULL(RoomInventoryPeriods.СтатусРазмещения.ЭтоГости, FALSE)
//	|				OR NOT &qShowNotInHouseOnly)
//	|		AND (RoomInventoryPeriods.ПериодС < &qPeriodTo
//	|					AND RoomInventoryPeriods.ПериодПо > &qPeriodFrom
//	|					AND &qPeriodCheckType = &qAccommodation
//	|				OR RoomInventoryPeriods.ПериодС >= &qPeriodFrom
//	|					AND RoomInventoryPeriods.ПериодС < &qPeriodTo
//	|					AND RoomInventoryPeriods.ПериодС = RoomInventoryPeriods.CheckInDate
//	|					AND (&qPeriodCheckType = &qCheckIn
//	|						OR &qPeriodCheckType = &qCheckInOrCheckOut)
//	|				OR RoomInventoryPeriods.ПериодПо > &qPeriodFrom
//	|					AND RoomInventoryPeriods.ПериодПо <= &qPeriodTo
//	|					AND RoomInventoryPeriods.ПериодПо = RoomInventoryPeriods.CheckOutDate
//	|					AND (&qPeriodCheckType = &qCheckOut
//	|						OR &qPeriodCheckType = &qCheckInOrCheckOut)
//	|				OR RoomInventoryPeriods.Recorder.ДатаДок >= &qPeriodFrom
//	|					AND RoomInventoryPeriods.Recorder.ДатаДок < &qPeriodTo
//	|					AND &qPeriodCheckType = &qDocDateInPeriod)
//	|	
//	|	GROUP BY
//	|		RoomInventoryPeriods.Recorder,
//	|		RoomInventoryPeriods.НомерРазмещения,
//	|		RoomInventoryPeriods.ТипНомера,
//	|		RoomInventoryPeriods.ВидРазмещения,
//	|		RoomInventoryPeriods.ПериодС,
//	|		RoomInventoryPeriods.PeriodDuration,
//	|		RoomInventoryPeriods.ПериодПо,
//	|		RoomInventoryPeriods.CheckInAccountingDate,
//	|		RoomInventoryPeriods.CheckOutAccountingDate,
//	|		CASE
//	|			WHEN ForeignerRegistryRecords.ForeignerRegistryRecord IS NULL 
//	|				THEN &qEmptyForeignerRegistryRecord
//	|			ELSE ForeignerRegistryRecords.ForeignerRegistryRecord
//	|		END,
//	|		CASE
//	|			WHEN ДанныеКлиента.Ref IS NULL 
//	|				THEN &qEmptyClientDataScan
//	|			ELSE ДанныеКлиента.Ref
//	|		END) AS ЗагрузкаНомеров
//	|		LEFT JOIN (SELECT
//	|			GuestSales.ДокОснование AS ДокОснование,
//	|			GuestSales.SalesTurnover AS Продажи,
//	|			GuestSales.RoomRevenueTurnover AS ДоходНомеров
//	|		FROM
//	|			AccumulationRegister.Продажи.Turnovers(&qBegOfPeriodFrom, &qEndOfPeriodTo, , &qShowSales) AS GuestSales) AS GuestPeriodSales
//	|		ON ЗагрузкаНомеров.Recorder = GuestPeriodSales.ДокОснование
//	|			AND (&qShowSales)
//	|		LEFT JOIN (SELECT
//	|			AccountsBalance.СчетПроживания.ДокОснование AS FolioParentDoc,
//	|			SUM(AccountsBalance.SumBalance) AS ClientSumBalance
//	|		FROM
//	|			AccumulationRegister.Взаиморасчеты.Balance(
//	|					&qEndOfPeriodTo,
//	|					&qShowBalances
//	|						AND (СчетПроживания.Контрагент = &qEmptyCustomer
//	|							OR СчетПроживания.Контрагент = СчетПроживания.Гостиница.IndividualsCustomer
//	|							OR СчетПроживания.Контрагент <> &qEmptyCustomer
//	|								AND СчетПроживания.Контрагент IN HIERARCHY (&qIndividualsCustomerFolder))) AS AccountsBalance
//	|		
//	|		GROUP BY
//	|			AccountsBalance.СчетПроживания.ДокОснование) AS ClientBalances
//	|		ON ЗагрузкаНомеров.Recorder = ClientBalances.FolioParentDoc
//	|			AND (&qShowBalances)
//	|{WHERE
//	|	ЗагрузкаНомеров.Recorder.* AS Recorder,
//	|	ЗагрузкаНомеров.ForeignerRegistryRecord.* AS ForeignerRegistryRecord,
//	|	ЗагрузкаНомеров.ClientDataScan.* AS ClientDataScan,
//	|	ЗагрузкаНомеров.Recorder.Гостиница.* AS Гостиница,
//	|	ЗагрузкаНомеров.ТипНомера.* AS ТипНомера,
//	|	ЗагрузкаНомеров.НомерРазмещения.* AS НомерРазмещения,
//	|	ЗагрузкаНомеров.ВидРазмещения.* AS ВидРазмещения,
//	|	ЗагрузкаНомеров.Recorder.Контрагент.* AS Контрагент,
//	|	ЗагрузкаНомеров.Recorder.ТипКонтрагента AS ТипКонтрагента,
//	|	ЗагрузкаНомеров.Recorder.Договор.* AS Договор,
//	|	ЗагрузкаНомеров.Recorder.КонтактноеЛицо AS КонтактноеЛицо,
//	|	ЗагрузкаНомеров.Recorder.Агент.* AS Агент,
//	|	ЗагрузкаНомеров.Recorder.ГруппаГостей.* AS ГруппаГостей,
//	|	ЗагрузкаНомеров.Recorder.ДокОснование.* AS ДокОснование,
//	|	ЗагрузкаНомеров.Recorder.ПутевкаКурсовка.* AS ПутевкаКурсовка,
//	|	ЗагрузкаНомеров.Recorder.СтатусРазмещения.* AS СтатусРазмещения,
//	|	ЗагрузкаНомеров.CheckInDate AS CheckInDate,
//	|	ЗагрузкаНомеров.Продолжительность AS Продолжительность,
//	|	ЗагрузкаНомеров.CheckOutDate AS CheckOutDate,
//	|	ЗагрузкаНомеров.CheckInAccountingDate AS CheckInAccountingDate,
//	|	ЗагрузкаНомеров.CheckOutAccountingDate AS CheckOutAccountingDate,
//	|	ЗагрузкаНомеров.InHouseGuests AS InHouseGuests,
//	|	ЗагрузкаНомеров.ИспользованоНомеров AS ИспользованоНомеров,
//	|	ЗагрузкаНомеров.ИспользованоМест AS ИспользованоМест,
//	|	ЗагрузкаНомеров.InHouseAdditionalBeds AS InHouseAdditionalBeds,
//	|	(ISNULL(GuestPeriodSales.Продажи, 0)) AS Продажи,
//	|	(ISNULL(GuestPeriodSales.ДоходНомеров, 0)) AS ДоходНомеров,
//	|	(ISNULL(ClientBalances.ClientSumBalance, 0)) AS ClientSumBalance,
//	|	ЗагрузкаНомеров.Recorder.КвотаНомеров.* AS КвотаНомеров,
//	|	ЗагрузкаНомеров.Recorder.RoomQuantity AS RoomQuantity,
//	|	ЗагрузкаНомеров.Recorder.ТипКлиента.* AS ТипКлиента,
//	|	ЗагрузкаНомеров.Recorder.Клиент.* AS Клиент,
//	|	ЗагрузкаНомеров.Recorder.МаретингНапрвл.* AS МаретингНапрвл,
//	|	ЗагрузкаНомеров.Recorder.TripPurpose.* AS TripPurpose,
//	|	ЗагрузкаНомеров.Recorder.ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
//	|	ЗагрузкаНомеров.Recorder.RoomRateType.* AS RoomRateType,
//	|	ЗагрузкаНомеров.Recorder.Тариф.* AS Тариф,
//	|	ЗагрузкаНомеров.Recorder.PricePresentation AS PricePresentation,
//	|	ЗагрузкаНомеров.Recorder.ДисконтКарт.* AS ДисконтКарт,
//	|	ЗагрузкаНомеров.Recorder.ТипСкидки.* AS ТипСкидки,
//	|	ЗагрузкаНомеров.Recorder.Скидка AS Скидка,
//	|	ЗагрузкаНомеров.Recorder.PlannedPaymentMethod.* AS PlannedPaymentMethod,
//	|	ЗагрузкаНомеров.Recorder.Car AS Car,
//	|	ЗагрузкаНомеров.Recorder.Примечания AS Примечания,
//	|	ЗагрузкаНомеров.Recorder.Автор.* AS Автор,
//	|	ЗагрузкаНомеров.Recorder.КомиссияАгента AS КомиссияАгента,
//	|	ЗагрузкаНомеров.Recorder.ВидКомиссииАгента.* AS ВидКомиссииАгента,
//	|	ЗагрузкаНомеров.Recorder.IsMaster AS IsMaster,
//	|	(CASE
//	|			WHEN ЗагрузкаНомеров.ForeignerRegistryRecord.MigrationCardDateTo <> &qEmptyDate
//	|				THEN DATEDIFF(ЗагрузкаНомеров.ForeignerRegistryRecord.MigrationCardDateTo, RoomInventory.Recorder.CheckOutDate, DAY)
//	|			ELSE 0
//	|		END) AS MigrationCardDateToDeviance,
//	|	(CASE
//	|			WHEN ЗагрузкаНомеров.ForeignerRegistryRecord.VisaToDate <> &qEmptyDate
//	|				THEN DATEDIFF(ЗагрузкаНомеров.ForeignerRegistryRecord.VisaToDate, RoomInventory.Recorder.CheckOutDate, DAY)
//	|			ELSE 0
//	|		END) AS VisaToDateDeviance,
//	|	ЗагрузкаНомеров.Recorder.СтатусРазмещения.ЭтоЗаезд AS ЭтоЗаезд,
//	|	ЗагрузкаНомеров.Recorder.СтатусРазмещения.ЭтоВыезд AS ЭтоВыезд,
//	|	ЗагрузкаНомеров.Recorder.СтатусРазмещения.IsRoomChange AS IsRoomChange,
//	|	ЗагрузкаНомеров.Recorder.СтатусРазмещения.ЭтоГости AS IsInHouse}
//	|
//	|ORDER BY
//	|	Гостиница,
//	|	НомерРазмещения,
//	|	CheckInDate,
//	|	Клиент
//	|{ORDER BY
//	|	ЗагрузкаНомеров.Recorder.* AS Recorder,
//	|	ЗагрузкаНомеров.ForeignerRegistryRecord.* AS ForeignerRegistryRecord,
//	|	ЗагрузкаНомеров.ClientDataScan.* AS ClientDataScan,
//	|	Контрагент.* AS Контрагент,
//	|	ЗагрузкаНомеров.Recorder.ТипКонтрагента.* AS ТипКонтрагента,
//	|	ЗагрузкаНомеров.Recorder.Договор.* AS Договор,
//	|	ЗагрузкаНомеров.Recorder.Агент.* AS Агент,
//	|	ГруппаГостей.* AS ГруппаГостей,
//	|	Клиент.* AS Клиент,
//	|	ЗагрузкаНомеров.Recorder.МаретингНапрвл.* AS МаретингНапрвл,
//	|	ЗагрузкаНомеров.Recorder.TripPurpose.* AS TripPurpose,
//	|	ЗагрузкаНомеров.Recorder.ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
//	|	Тариф.* AS Тариф,
//	|	ЗагрузкаНомеров.Recorder.RoomRateType.* AS RoomRateType,
//	|	ЗагрузкаНомеров.Recorder.ДисконтКарт.* AS ДисконтКарт,
//	|	ЗагрузкаНомеров.Recorder.ТипСкидки.* AS ТипСкидки,
//	|	ЗагрузкаНомеров.Recorder.PlannedPaymentMethod.* AS PlannedPaymentMethod,
//	|	НомерРазмещения.* AS НомерРазмещения,
//	|	ТипНомера.* AS ТипНомера,
//	|	ВидРазмещения.* AS ВидРазмещения,
//	|	Гостиница.* AS Гостиница,
//	|	ЗагрузкаНомеров.Recorder.PointInTime AS PointInTime,
//	|	CheckInDate AS CheckInDate,
//	|	Продолжительность AS Продолжительность,
//	|	CheckOutDate AS CheckOutDate,
//	|	ЗагрузкаНомеров.Recorder.RoomRateType.* AS RoomRateType,
//	|	Тариф.* AS Тариф,
//	|	PricePresentation AS PricePresentation,
//	|	ЗагрузкаНомеров.Recorder.Автор.* AS Автор,
//	|	InHouseGuests AS InHouseGuests,
//	|	ИспользованоНомеров AS ИспользованоНомеров,
//	|	ИспользованоМест AS ИспользованоМест,
//	|	InHouseAdditionalBeds AS InHouseAdditionalBeds,
//	|	ЗагрузкаНомеров.CheckInAccountingDate AS CheckInAccountingDate,
//	|	ЗагрузкаНомеров.CheckOutAccountingDate AS CheckOutAccountingDate,
//	|	(HOUR(ЗагрузкаНомеров.Recorder.CheckInDate)) AS CheckInHour,
//	|	(DAY(ЗагрузкаНомеров.Recorder.CheckInDate)) AS CheckInDay,
//	|	(WEEK(ЗагрузкаНомеров.Recorder.CheckInDate)) AS CheckInWeek,
//	|	(MONTH(ЗагрузкаНомеров.Recorder.CheckInDate)) AS CheckInMonth,
//	|	(QUARTER(ЗагрузкаНомеров.Recorder.CheckInDate)) AS CheckInQuarter,
//	|	(YEAR(ЗагрузкаНомеров.Recorder.CheckInDate)) AS CheckInYear,
//	|	Продажи,
//	|	ДоходНомеров,
//	|	ClientSumBalance,
//	|	ЗагрузкаНомеров.Recorder.КвотаНомеров.* AS RoomQuota}
//	|TOTALS
//	|	SUM(InHouseGuests),
//	|	SUM(ИспользованоНомеров),
//	|	SUM(ИспользованоМест),
//	|	SUM(InHouseAdditionalBeds),
//	|	SUM(HotelProductSum),
//	|	SUM(Продажи),
//	|	SUM(ДоходНомеров),
//	|	SUM(ClientSumBalance)
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
//	|	ТипНомера.* AS ТипНомера,
//	|	НомерРазмещения.* AS НомерРазмещения,
//	|	ВидРазмещения.* AS ВидРазмещения,
//	|	Контрагент.* AS Контрагент,
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
//	|	Тариф.* AS Тариф,
//	|	PricePresentation AS PricePresentation,
//	|	ЗагрузкаНомеров.Recorder.ДисконтКарт.* AS ДисконтКарт,
//	|	ЗагрузкаНомеров.Recorder.ТипСкидки.* AS ТипСкидки,
//	|	ЗагрузкаНомеров.Recorder.Автор.* AS Автор,
//	|	ЗагрузкаНомеров.Recorder.* AS Recorder,
//	|	ЗагрузкаНомеров.ForeignerRegistryRecord.* AS ForeignerRegistryRecord,
//	|	ЗагрузкаНомеров.ClientDataScan.* AS ClientDataScan,
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
//	ReportBuilder.HeaderText = NStr("en='ГруппаНомеров occupation history';de='Zimmerbesatzungsgeschichte';ru='История заселения номеров'");
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
