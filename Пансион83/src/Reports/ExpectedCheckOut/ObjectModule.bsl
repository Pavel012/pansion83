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
//		PeriodTo = EndOfDay(CurrentDate()); // End of today
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
//	If НЕ ЗначениеЗаполнено(PeriodTo) Тогда
//		vParamPresentation = vParamPresentation + NStr("en='Report period is not set';ru='Период отчета не установлен';de='Berichtszeitraum nicht festgelegt'") + 
//		                     ";" + Chars.LF;
//	Else
//		vParamPresentation = vParamPresentation + NStr("ru = 'Выезд до '; en = 'Check out to '") + 
//		                     Format(PeriodTo, "DF='dd.MM.yyyy HH:mm:ss'") + 
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
//	Return vParamPresentation;
//EndFunction //pmGetReportParametersPresentation
//
////-----------------------------------------------------------------------------
//// Runs report and returns if report form should be shown
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
//	ReportBuilder.Parameters.Вставить("qPeriodTo", PeriodTo);
//	ReportBuilder.Parameters.Вставить("qBalancePeriodTo", '39991231235959');
//	ReportBuilder.Parameters.Вставить("qRoom", ГруппаНомеров);
//	ReportBuilder.Parameters.Вставить("qRoomType", RoomType);
//	ReportBuilder.Parameters.Вставить("qEmptyCustomer", Справочники.Customers.EmptyRef());
//	ReportBuilder.Parameters.Вставить("qIndividualsCustomer", ?(ЗначениеЗаполнено(Гостиница), Гостиница.IndividualsCustomer, Справочники.Customers.EmptyRef()));
//	ReportBuilder.Parameters.Вставить("qIndividualsCustomerFolder", Справочники.Customers.КонтрагентПоУмолчанию);
//	ReportBuilder.Parameters.Вставить("qFolioDescription", FolioDescription);
//	ReportBuilder.Parameters.Вставить("qFolioDescriptionIsEmpty", IsBlankString(FolioDescription));
//	ReportBuilder.Parameters.Вставить("qPaymentSection", PaymentSection);
//	ReportBuilder.Parameters.Вставить("qPaymentSectionIsEmpty", НЕ ЗначениеЗаполнено(PaymentSection));
//	ReportBuilder.Parameters.Вставить("qFolioCurrency", FolioCurrency);
//	ReportBuilder.Parameters.Вставить("qFolioCurrencyIsEmpty", НЕ ЗначениеЗаполнено(FolioCurrency));
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
//	|	ЗагрузкаНомеров.Recorder.CheckInDate AS CheckInDate,
//	|	ЗагрузкаНомеров.Recorder.Продолжительность AS Продолжительность,
//	|	ЗагрузкаНомеров.Recorder.CheckOutDate AS CheckOutDate,
//	|	ЗагрузкаНомеров.ТипНомера AS ТипНомера,
//	|	ЗагрузкаНомеров.Recorder.ВидРазмещения AS ВидРазмещения,
//	|	ЗагрузкаНомеров.Recorder.Тариф AS Тариф,
//	|	ЗагрузкаНомеров.Recorder.Примечания AS Примечания,
//	|	ЗагрузкаНомеров.Recorder.ГруппаГостей AS ГруппаГостей,
//	|	ЗагрузкаНомеров.InHouseGuests AS InHouseGuests,
//	|	ЗагрузкаНомеров.ИспользованоНомеров AS ИспользованоНомеров,
//	|	ЗагрузкаНомеров.ИспользованоМест AS ИспользованоМест,
//	|	ЗагрузкаНомеров.InHouseAdditionalBeds AS InHouseAdditionalBeds,
//	|	ЗагрузкаНомеров.Recorder.PricePresentation AS PricePresentation,
//	|	ЗагрузкаНомеров.ВалютаЛицСчета AS ВалютаЛицСчета,
//	|	ЗагрузкаНомеров.ClientSumBalance AS ClientSumBalance
//	|{SELECT
//	|	Гостиница.* AS Гостиница,
//	|	НомерРазмещения.* AS НомерРазмещения,
//	|	ЗагрузкаНомеров.Recorder.ТипКонтрагента.* AS ТипКонтрагента,
//	|	Контрагент.* AS Контрагент,
//	|	ЗагрузкаНомеров.Recorder.Договор.* AS Договор,
//	|	ЗагрузкаНомеров.Recorder.КонтактноеЛицо AS КонтактноеЛицо,
//	|	ЗагрузкаНомеров.Recorder.Агент.* AS Агент,
//	|	ЗагрузкаНомеров.Recorder.ТипКлиента.* AS ТипКлиента,
//	|	Клиент.* AS Клиент,
//	|	CheckInDate AS CheckInDate,
//	|	Продолжительность AS Продолжительность,
//	|	CheckOutDate AS CheckOutDate,
//	|	ЗагрузкаНомеров.CheckInAccountingDate AS CheckInAccountingDate,
//	|	ЗагрузкаНомеров.CheckOutAccountingDate AS CheckOutAccountingDate,
//	|	(HOUR(ЗагрузкаНомеров.Recorder.CheckOutDate)) AS CheckOutHour,
//	|	(DAY(ЗагрузкаНомеров.Recorder.CheckOutDate)) AS CheckOutDay,
//	|	(WEEK(ЗагрузкаНомеров.Recorder.CheckOutDate)) AS CheckOutWeek,
//	|	(MONTH(ЗагрузкаНомеров.Recorder.CheckOutDate)) AS CheckOutMonth,
//	|	(QUARTER(ЗагрузкаНомеров.Recorder.CheckOutDate)) AS CheckOutQuarter,
//	|	(YEAR(ЗагрузкаНомеров.Recorder.CheckOutDate)) AS CheckOutYear,
//	|	ТипНомера.* AS ТипНомера,
//	|	ВидРазмещения.* AS ВидРазмещения,
//	|	ЗагрузкаНомеров.Recorder.RoomRateType.* AS RoomRateType,
//	|	Тариф.* AS Тариф,
//	|	PricePresentation AS PricePresentation,
//	|	ЗагрузкаНомеров.Recorder.PlannedPaymentMethod.* AS PlannedPaymentMethod,
//	|	InHouseGuests AS InHouseGuests,
//	|	ИспользованоНомеров AS ИспользованоНомеров,
//	|	ИспользованоМест AS ИспользованоМест,
//	|	InHouseAdditionalBeds AS InHouseAdditionalBeds,
//	|	Примечания AS Примечания,
//	|	ЗагрузкаНомеров.Recorder.Car AS Car,
//	|	ГруппаГостей.* AS ГруппаГостей,
//	|	СтатусРазмещения.* AS СтатусРазмещения,
//	|	ЗагрузкаНомеров.Recorder.IsMaster AS IsMaster,
//	|	ЗагрузкаНомеров.Recorder.ПутевкаКурсовка AS ПутевкаКурсовка,
//	|	ЗагрузкаНомеров.Recorder.КвотаНомеров AS КвотаНомеров,
//	|	ЗагрузкаНомеров.Recorder.МаретингНапрвл AS МаретингНапрвл,
//	|	ЗагрузкаНомеров.Recorder.TripPurpose AS TripPurpose,
//	|	ЗагрузкаНомеров.Recorder.ИсточИнфоГостиница AS ИсточИнфоГостиница,
//	|	ЗагрузкаНомеров.Recorder.ДисконтКарт AS ДисконтКарт,
//	|	ЗагрузкаНомеров.Recorder.ТипСкидки AS ТипСкидки,
//	|	ЗагрузкаНомеров.Recorder.Скидка AS Скидка,
//	|	ЗагрузкаНомеров.Recorder.КомиссияАгента AS КомиссияАгента,
//	|	ЗагрузкаНомеров.Recorder.ВидКомиссииАгента AS ВидКомиссииАгента,
//	|	ЗагрузкаНомеров.Recorder.КоличествоМестНомер AS КоличествоМестНомер,
//	|	ЗагрузкаНомеров.Recorder.КоличествоГостейНомер AS КоличествоГостейНомер,
//	|	ЗагрузкаНомеров.Recorder.ДокОснование AS ДокОснование,
//	|	ЗагрузкаНомеров.Recorder.* AS Recorder,
//	|	ЗагрузкаНомеров.Recorder.PointInTime AS PointInTime,
//	|	ЗагрузкаНомеров.ClientSumBalance AS ClientSumBalance,
//	|	ЗагрузкаНомеров.ВалютаЛицСчета.* AS FolioCurrency}
//	|FROM
//	|	(SELECT
//	|		RoomInventoryTurnovers.Recorder AS Recorder,
//	|		RoomInventoryTurnovers.НомерРазмещения AS НомерРазмещения,
//	|		RoomInventoryTurnovers.ТипНомера AS ТипНомера,
//	|		ClientBalances.ВалютаЛицСчета AS ВалютаЛицСчета,
//	|		RoomInventoryTurnovers.CheckInAccountingDate AS CheckInAccountingDate,
//	|		RoomInventoryTurnovers.CheckOutAccountingDate AS CheckOutAccountingDate,
//	|		RoomInventoryTurnovers.GuestsCheckedOut AS InHouseGuests,
//	|		CASE
//	|			WHEN RoomInventoryTurnovers.RoomsCheckedOut < 0
//	|				THEN 0
//	|			ELSE RoomInventoryTurnovers.RoomsCheckedOut
//	|		END AS ИспользованоНомеров,
//	|		RoomInventoryTurnovers.BedsCheckedOut AS ИспользованоМест,
//	|		RoomInventoryTurnovers.AdditionalBedsCheckedOut AS InHouseAdditionalBeds,
//	|		ISNULL(ClientBalances.ClientSumBalance, 0) AS ClientSumBalance
//	|	FROM
//	|		(SELECT
//	|			RoomInventoryMovements.Recorder AS Recorder,
//	|			RoomInventoryMovements.НомерРазмещения AS НомерРазмещения,
//	|			RoomInventoryMovements.ТипНомера AS ТипНомера,
//	|			MIN(RoomInventoryMovements.CheckInAccountingDate) AS CheckInAccountingDate,
//	|			MAX(RoomInventoryMovements.CheckOutAccountingDate) AS CheckOutAccountingDate,
//	|			SUM(RoomInventoryMovements.GuestsCheckedOut) AS GuestsCheckedOut,
//	|			SUM(RoomInventoryMovements.RoomsCheckedOut) AS RoomsCheckedOut,
//	|			SUM(RoomInventoryMovements.BedsCheckedOut) AS BedsCheckedOut,
//	|			SUM(RoomInventoryMovements.AdditionalBedsCheckedOut) AS AdditionalBedsCheckedOut
//	|		FROM
//	|			AccumulationRegister.ЗагрузкаНомеров AS RoomInventoryMovements
//	|		WHERE
//	|			RoomInventoryMovements.RecordType = VALUE(AccumulationRecordType.Receipt)
//	|			AND RoomInventoryMovements.IsAccommodation
//	|			AND RoomInventoryMovements.ЭтоГости
//	|			AND RoomInventoryMovements.ЭтоВыезд
//	|			AND RoomInventoryMovements.Гостиница IN HIERARCHY(&qHotel)
//	|			AND RoomInventoryMovements.НомерРазмещения IN HIERARCHY(&qRoom)
//	|			AND RoomInventoryMovements.ТипНомера IN HIERARCHY(&qRoomType)
//	|			AND RoomInventoryMovements.ПериодПо = RoomInventoryMovements.CheckOutDate
//	|			AND RoomInventoryMovements.ПериодПо <= &qPeriodTo
//	|			AND RoomInventoryMovements.CheckOutDate <= &qPeriodTo
//	|		
//	|		GROUP BY
//	|			RoomInventoryMovements.Recorder,
//	|			RoomInventoryMovements.НомерРазмещения,
//	|			RoomInventoryMovements.ТипНомера) AS RoomInventoryTurnovers
//	|			LEFT JOIN (SELECT
//	|				AccountsBalance.ВалютаЛицСчета AS ВалютаЛицСчета,
//	|				AccountsBalance.СчетПроживания.ДокОснование AS FolioParentDoc,
//	|				SUM(AccountsBalance.SumBalance) AS ClientSumBalance
//	|			FROM
//	|				AccumulationRegister.Взаиморасчеты.Balance(
//	|						&qBalancePeriodTo,
//	|						(СчетПроживания.Контрагент = &qEmptyCustomer
//	|							OR СчетПроживания.Контрагент = &qIndividualsCustomer
//	|							OR СчетПроживания.Контрагент <> &qEmptyCustomer
//	|								AND СчетПроживания.Контрагент IN HIERARCHY (&qIndividualsCustomerFolder))
//	|							AND (ВалютаЛицСчета = &qFolioCurrency
//	|								OR &qFolioCurrencyIsEmpty)
//	|							AND (СчетПроживания.PaymentSection = &qPaymentSection
//	|								OR &qPaymentSectionIsEmpty)
//	|							AND (СчетПроживания.Description = &qFolioDescription
//	|								OR &qFolioDescriptionIsEmpty)) AS AccountsBalance
//	|			
//	|			GROUP BY
//	|				AccountsBalance.ВалютаЛицСчета,
//	|				AccountsBalance.СчетПроживания.ДокОснование) AS ClientBalances
//	|			ON RoomInventoryTurnovers.Recorder = ClientBalances.FolioParentDoc) AS ЗагрузкаНомеров
//	|{WHERE
//	|	ЗагрузкаНомеров.Recorder.* AS Recorder,
//	|	ЗагрузкаНомеров.Recorder.Гостиница.* AS Гостиница,
//	|	ЗагрузкаНомеров.ТипНомера.* AS ТипНомера,
//	|	ЗагрузкаНомеров.НомерРазмещения.* AS НомерРазмещения,
//	|	ЗагрузкаНомеров.Recorder.Контрагент.* AS Контрагент,
//	|	ЗагрузкаНомеров.Recorder.ТипКонтрагента.* AS ТипКонтрагента,
//	|	ЗагрузкаНомеров.Recorder.Договор.* AS Договор,
//	|	ЗагрузкаНомеров.Recorder.КонтактноеЛицо AS КонтактноеЛицо,
//	|	ЗагрузкаНомеров.Recorder.Агент.* AS Агент,
//	|	ЗагрузкаНомеров.Recorder.ГруппаГостей.* AS ГруппаГостей,
//	|	ЗагрузкаНомеров.Recorder.ДокОснование.* AS ДокОснование,
//	|	ЗагрузкаНомеров.Recorder.ПутевкаКурсовка.* AS ПутевкаКурсовка,
//	|	ЗагрузкаНомеров.Recorder.СтатусРазмещения.* AS СтатусРазмещения,
//	|	ЗагрузкаНомеров.Recorder.CheckInDate AS CheckInDate,
//	|	ЗагрузкаНомеров.Recorder.Продолжительность AS Продолжительность,
//	|	ЗагрузкаНомеров.Recorder.CheckOutDate AS CheckOutDate,
//	|	ЗагрузкаНомеров.CheckInAccountingDate AS CheckInAccountingDate,
//	|	ЗагрузкаНомеров.CheckOutAccountingDate AS CheckOutAccountingDate,
//	|	ЗагрузкаНомеров.InHouseGuests AS InHouseGuests,
//	|	ЗагрузкаНомеров.ИспользованоНомеров AS ИспользованоНомеров,
//	|	ЗагрузкаНомеров.ИспользованоМест AS ИспользованоМест,
//	|	ЗагрузкаНомеров.InHouseAdditionalBeds AS InHouseAdditionalBeds,
//	|	ЗагрузкаНомеров.Recorder.КвотаНомеров.* AS КвотаНомеров,
//	|	ЗагрузкаНомеров.Recorder.ТипКлиента.* AS ТипКлиента,
//	|	ЗагрузкаНомеров.Recorder.Клиент.* AS Клиент,
//	|	ЗагрузкаНомеров.Recorder.МаретингНапрвл.* AS МаретингНапрвл,
//	|	ЗагрузкаНомеров.Recorder.TripPurpose.* AS TripPurpose,
//	|	ЗагрузкаНомеров.Recorder.ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
//	|	ЗагрузкаНомеров.Recorder.RoomRateType.* AS RoomRateType,
//	|	ЗагрузкаНомеров.Recorder.Тариф.* AS Тариф,
//	|	ЗагрузкаНомеров.Recorder.PricePresentation AS PricePresentation,
//	|	ЗагрузкаНомеров.Recorder.ДисконтКарт AS ДисконтКарт,
//	|	ЗагрузкаНомеров.Recorder.ТипСкидки AS ТипСкидки,
//	|	ЗагрузкаНомеров.Recorder.Скидка AS Скидка,
//	|	ЗагрузкаНомеров.Recorder.PlannedPaymentMethod.* AS PlannedPaymentMethod,
//	|	ЗагрузкаНомеров.Recorder.Car AS Car,
//	|	ЗагрузкаНомеров.Recorder.Примечания AS Примечания,
//	|	ЗагрузкаНомеров.Recorder.КомиссияАгента AS КомиссияАгента,
//	|	ЗагрузкаНомеров.Recorder.ВидКомиссииАгента AS ВидКомиссииАгента,
//	|	ЗагрузкаНомеров.Recorder.IsMaster AS IsMaster,
//	|	ЗагрузкаНомеров.ВалютаЛицСчета.* AS ВалютаЛицСчета,
//	|	ЗагрузкаНомеров.ClientSumBalance AS ClientSumBalance}
//	|
//	|ORDER BY
//	|	Гостиница,
//	|	НомерРазмещения,
//	|	CheckInDate,
//	|	Клиент
//	|{ORDER BY
//	|	Контрагент.* AS Контрагент,
//	|	ЗагрузкаНомеров.Recorder.ТипКонтрагента.* AS ТипКонтрагента,
//	|	ЗагрузкаНомеров.Recorder.Договор.* AS Договор,
//	|	ЗагрузкаНомеров.Recorder.Агент.* AS Агент,
//	|	ГруппаГостей.* AS ГруппаГостей,
//	|	Клиент.* AS Клиент,
//	|	ЗагрузкаНомеров.Recorder.МаретингНапрвл.* AS МаретингНапрвл,
//	|	ЗагрузкаНомеров.Recorder.TripPurpose.* AS TripPurpose,
//	|	ЗагрузкаНомеров.Recorder.ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
//	|	ЗагрузкаНомеров.Recorder.RoomRateType.* AS RoomRateType,
//	|	ЗагрузкаНомеров.Recorder.ТипКлиента.* AS ТипКлиента,
//	|	Тариф.* AS Тариф,
//	|	PricePresentation AS PricePresentation,
//	|	ЗагрузкаНомеров.Recorder.ДисконтКарт.* AS ДисконтКарт,
//	|	ЗагрузкаНомеров.Recorder.ТипСкидки.* AS ТипСкидки,
//	|	ЗагрузкаНомеров.Recorder.PlannedPaymentMethod.* AS PlannedPaymentMethod,
//	|	НомерРазмещения.* AS НомерРазмещения,
//	|	ТипНомера.* AS ТипНомера,
//	|	Гостиница.* AS Гостиница,
//	|	ЗагрузкаНомеров.Recorder.PointInTime AS PointInTime,
//	|	CheckInDate AS CheckInDate,
//	|	Продолжительность AS Продолжительность,
//	|	CheckOutDate AS CheckOutDate,
//	|	InHouseGuests AS InHouseGuests,
//	|	ИспользованоНомеров AS ИспользованоНомеров,
//	|	ИспользованоМест AS ИспользованоМест,
//	|	InHouseAdditionalBeds AS InHouseAdditionalBeds,
//	|	ЗагрузкаНомеров.CheckInAccountingDate AS CheckInAccountingDate,
//	|	ЗагрузкаНомеров.CheckOutAccountingDate AS CheckOutAccountingDate,
//	|	(HOUR(ЗагрузкаНомеров.Recorder.CheckOutDate)) AS CheckOutHour,
//	|	(DAY(ЗагрузкаНомеров.Recorder.CheckOutDate)) AS CheckOutDay,
//	|	(WEEK(ЗагрузкаНомеров.Recorder.CheckOutDate)) AS CheckOutWeek,
//	|	(MONTH(ЗагрузкаНомеров.Recorder.CheckOutDate)) AS CheckOutMonth,
//	|	(QUARTER(ЗагрузкаНомеров.Recorder.CheckOutDate)) AS CheckOutQuarter,
//	|	(YEAR(ЗагрузкаНомеров.Recorder.CheckOutDate)) AS CheckOutYear,
//	|	ЗагрузкаНомеров.Recorder.КвотаНомеров AS КвотаНомеров,
//	|	ВалютаЛицСчета.* AS ВалютаЛицСчета,
//	|	ClientSumBalance AS ClientSumBalance}
//	|TOTALS
//	|	SUM(InHouseGuests),
//	|	SUM(ИспользованоНомеров),
//	|	SUM(ИспользованоМест),
//	|	SUM(InHouseAdditionalBeds)
//	|BY
//	|	OVERALL,
//	|	Гостиница,
//	|	НомерРазмещения
//	|{TOTALS BY
//	|	Гостиница.* AS Гостиница,
//	|	ЗагрузкаНомеров.CheckInAccountingDate AS CheckInAccountingDate,
//	|	ЗагрузкаНомеров.CheckOutAccountingDate AS CheckOutAccountingDate,
//	|	(HOUR(ЗагрузкаНомеров.Recorder.CheckOutDate)) AS CheckOutHour,
//	|	(DAY(ЗагрузкаНомеров.Recorder.CheckOutDate)) AS CheckOutDay,
//	|	(WEEK(ЗагрузкаНомеров.Recorder.CheckOutDate)) AS CheckOutWeek,
//	|	(MONTH(ЗагрузкаНомеров.Recorder.CheckOutDate)) AS CheckOutMonth,
//	|	(QUARTER(ЗагрузкаНомеров.Recorder.CheckOutDate)) AS CheckOutQuarter,
//	|	(YEAR(ЗагрузкаНомеров.Recorder.CheckOutDate)) AS CheckOutYear,
//	|	ТипНомера.* AS ТипНомера,
//	|	НомерРазмещения.* AS НомерРазмещения,
//	|	Контрагент.* AS Контрагент,
//	|	ЗагрузкаНомеров.Recorder.ТипКонтрагента.* AS ТипКонтрагента,
//	|	ЗагрузкаНомеров.Recorder.Договор.* AS Договор,
//	|	ЗагрузкаНомеров.Recorder.Агент.* AS Агент,
//	|	ЗагрузкаНомеров.Recorder.КонтактноеЛицо AS КонтактноеЛицо,
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
//	|	ЗагрузкаНомеров.Recorder.ДисконтКарт AS ДисконтКарт,
//	|	ЗагрузкаНомеров.Recorder.ТипСкидки AS ТипСкидки,
//	|	ЗагрузкаНомеров.Recorder.* AS Recorder,
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
//	ReportBuilder.HeaderText = NStr("EN='Expected check-out';RU='Планируемый выезд';de='Geplante Abreise'");
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
