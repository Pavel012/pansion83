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
//		If ЗначениеЗаполнено(Гостиница) Тогда
//			If НЕ ЗначениеЗаполнено(CheckOutCleaning) Тогда
//				CheckOutCleaning = Гостиница.CheckOutCleaning;
//			EndIf;
//			If НЕ ЗначениеЗаполнено(RegularCleaning) Тогда
//				RegularCleaning = Гостиница.RegularCleaning;
//			EndIf;
//			If НЕ ЗначениеЗаполнено(VacantRoomCleaning) Тогда
//				VacantRoomCleaning = Гостиница.VacantRoomCleaning;
//			EndIf;
//			If НЕ ЗначениеЗаполнено(RepairEndCleaning) Тогда
//				RepairEndCleaning = Гостиница.RepairEndCleaning;
//			EndIf;
//			If НЕ ЗначениеЗаполнено(RoomStatusAfterCheckOut) Тогда
//				RoomStatusAfterCheckOut = Гостиница.RoomStatusAfterCheckOut;
//			EndIf;
//			If НЕ ЗначениеЗаполнено(RegularOperationGroup) Тогда
//				RegularOperationGroup = Гостиница.RegularOperationGroup;
//			EndIf;
//		EndIf;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(PeriodTo) Тогда
//		PeriodTo = CurrentDate(); // Today
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
//		vParamPresentation = vParamPresentation + NStr("ru = 'На '; en = 'On '") + 
//		                     Format(PeriodTo, "DF='dd.MM.yyyy'") + 
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
//	ReportBuilder.Parameters.Вставить("qPeriod", EndOfDay(PeriodTo));
//	ReportBuilder.Parameters.Вставить("qPeriodFrom", BegOfDay(PeriodTo));
//	ReportBuilder.Parameters.Вставить("qPeriodTo", EndOfDay(PeriodTo));
//	ReportBuilder.Parameters.Вставить("qYesterdayPeriodFrom", BegOfDay(PeriodTo)-24*3600);
//	ReportBuilder.Parameters.Вставить("qYesterdayPeriodTo", EndOfDay(PeriodTo)-24*3600);
//	ReportBuilder.Parameters.Вставить("qEmptyDate", '00010101');
//	ReportBuilder.Parameters.Вставить("qHotel", Гостиница);
//	ReportBuilder.Parameters.Вставить("qIsEmptyHotel", НЕ ЗначениеЗаполнено(Гостиница));
//	ReportBuilder.Parameters.Вставить("qRoom", ГруппаНомеров);
//	ReportBuilder.Parameters.Вставить("qIsEmptyRoom", НЕ ЗначениеЗаполнено(ГруппаНомеров));
//	ReportBuilder.Parameters.Вставить("qExpense", AccumulationRecordType.Expense);
//	ReportBuilder.Parameters.Вставить("qReceipt", AccumulationRecordType.Receipt);
//	ReportBuilder.Parameters.Вставить("qRegularCleaning", RegularCleaning);
//	ReportBuilder.Parameters.Вставить("qRegularCleaningCode", ?(ЗначениеЗаполнено(RegularCleaning), RegularCleaning.Code, ""));
//	ReportBuilder.Parameters.Вставить("qRegularCleaningSortCode", ?(ЗначениеЗаполнено(RegularCleaning), RegularCleaning.SortCode, 0));
//	ReportBuilder.Parameters.Вставить("qRoomStatusAfterEarlyCheckIn", ?(ЗначениеЗаполнено(Гостиница), Гостиница.RoomStatusAfterEarlyCheckIn, Неопределено));
//	ReportBuilder.Parameters.Вставить("qRoomStatusAfterEarlyCheckInIsFilled", ЗначениеЗаполнено(?(ЗначениеЗаполнено(Гостиница), Гостиница.RoomStatusAfterEarlyCheckIn, Неопределено)));
//	ReportBuilder.Parameters.Вставить("qCheckOutCleaning", CheckOutCleaning);
//	ReportBuilder.Parameters.Вставить("qCheckOutCleaningCode", ?(ЗначениеЗаполнено(CheckOutCleaning), CheckOutCleaning.Code, ""));
//	ReportBuilder.Parameters.Вставить("qCheckOutCleaningSortCode", ?(ЗначениеЗаполнено(CheckOutCleaning), CheckOutCleaning.SortCode, 0));
//	ReportBuilder.Parameters.Вставить("qVacantRoomCleaning", VacantRoomCleaning);
//	ReportBuilder.Parameters.Вставить("qVacantRoomCleaningCode", ?(ЗначениеЗаполнено(VacantRoomCleaning), VacantRoomCleaning.Code, ""));
//	ReportBuilder.Parameters.Вставить("qVacantRoomCleaningSortCode", ?(ЗначениеЗаполнено(VacantRoomCleaning), VacantRoomCleaning.SortCode, 0));
//	ReportBuilder.Parameters.Вставить("qRepairEndCleaning", RepairEndCleaning);
//	ReportBuilder.Parameters.Вставить("qRepairEndCleaningCode", ?(ЗначениеЗаполнено(RepairEndCleaning), RepairEndCleaning.Code, ""));
//	ReportBuilder.Parameters.Вставить("qRepairEndCleaningSortCode", ?(ЗначениеЗаполнено(RepairEndCleaning), RepairEndCleaning.SortCode, 0));
//	ReportBuilder.Parameters.Вставить("qRoomStatusAfterCheckOut", RoomStatusAfterCheckOut);
//	ReportBuilder.Parameters.Вставить("qRoomStatusAfterCheckOutIsFilled", ЗначениеЗаполнено(RoomStatusAfterCheckOut));
//    ReportBuilder.Parameters.Вставить("qRegularOperationGroup", RegularOperationGroup);
//	ReportBuilder.Parameters.Вставить("qShowGuestGroupDescriptionInCustomerColumns", cmCheckUserPermissions("ShowGuestGroupDescriptionInCustomerColumns"));
//	ReportBuilder.Parameters.Вставить("qEmptyRoomType", Справочники.ТипыНомеров.EmptyRef());
//	ReportBuilder.Parameters.Вставить("qEmptyRoomRate", Справочники.Тарифы.EmptyRef());
//	ReportBuilder.Parameters.Вставить("qAccTypeRoom", Перечисления.AccomodationTypes.НомерРазмещения);
//	ReportBuilder.Parameters.Вставить("qAccTypeBeds", Перечисления.AccomodationTypes.Beds);
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
//	"SELECT DISTINCT
//	|	CleaningTasks.Гостиница AS Гостиница,
//	|	CleaningTasks.НомерРазмещения AS НомерРазмещения,
//	|	RoomStatusLastChangeRecord.СтатусНомера AS СтатусНомера,
//	|	RoomStatusLastChangeRecord.Period AS RoomStatusChangeTime,
//	|	RoomStatusLastChangeRecord.User AS RoomStatusChangeAuthor,
//	|	CASE
//	|		WHEN CleaningTasks.CheckOutCleaning IS NOT NULL 
//	|			THEN CleaningTasks.CheckOutCleaningCode
//	|		WHEN CleaningTasks.RegularOperation IS NOT NULL 
//	|			THEN CleaningTasks.RegularOperationCode
//	|		WHEN CleaningTasks.RegularCleaning IS NOT NULL 
//	|			THEN CleaningTasks.RegularCleaningCode
//	|		WHEN CleaningTasks.RepairEndCleaning IS NOT NULL 
//	|			THEN CleaningTasks.RepairEndCleaningCode
//	|		WHEN CleaningTasks.VacantRoomCleaning IS NOT NULL 
//	|			THEN CleaningTasks.VacantRoomCleaningCode
//	|		ELSE NULL
//	|	END AS OperationCode,
//	|	CASE
//	|		WHEN CleaningTasks.CheckOutCleaning IS NOT NULL 
//	|			THEN CleaningTasks.CheckOutCleaning
//	|		WHEN CleaningTasks.RegularOperation IS NOT NULL 
//	|			THEN CleaningTasks.RegularOperation
//	|		WHEN CleaningTasks.RegularCleaning IS NOT NULL 
//	|			THEN CleaningTasks.RegularCleaning
//	|		WHEN CleaningTasks.RepairEndCleaning IS NOT NULL 
//	|			THEN CleaningTasks.RepairEndCleaning
//	|		WHEN CleaningTasks.VacantRoomCleaning IS NOT NULL 
//	|			THEN CleaningTasks.VacantRoomCleaning
//	|		ELSE NULL
//	|	END AS Operation,
//	|	CASE
//	|		WHEN CleaningTasks.CheckOutCleaning IS NOT NULL 
//	|			THEN CleaningTasks.CheckOutCleaningSortCode
//	|		WHEN CleaningTasks.RegularOperation IS NOT NULL 
//	|			THEN CleaningTasks.RegularOperationSortCode
//	|		WHEN CleaningTasks.RegularCleaning IS NOT NULL 
//	|			THEN CleaningTasks.RegularCleaningSortCode
//	|		WHEN CleaningTasks.RepairEndCleaning IS NOT NULL 
//	|			THEN CleaningTasks.RepairEndCleaningSortCode
//	|		WHEN CleaningTasks.VacantRoomCleaning IS NOT NULL 
//	|			THEN CleaningTasks.VacantRoomCleaningSortCode
//	|		ELSE NULL
//	|	END AS OperationSortCode,
//	|	CASE
//	|		WHEN CleaningTasks.InHouseAccommodation IS NOT NULL 
//	|			THEN CleaningTasks.InHouseAccommodation.ТипКлиента
//	|		WHEN CleaningTasks.CheckOutAccommodation IS NOT NULL 
//	|			THEN CleaningTasks.CheckOutAccommodation.ТипКлиента
//	|		WHEN CleaningTasks.PlannedCheckedInRecorder IS NOT NULL 
//	|			THEN CleaningTasks.PlannedCheckedInRecorder.ТипКлиента
//	|		ELSE NULL
//	|	END AS ТипКлиента,
//	|	CASE
//	|		WHEN CleaningTasks.InHouseAccommodation IS NOT NULL 
//	|			THEN CleaningTasks.InHouseGuest.Фамилия
//	|		WHEN CleaningTasks.CheckOutAccommodation IS NOT NULL 
//	|			THEN CleaningTasks.CheckOutGuest.Фамилия
//	|		WHEN CleaningTasks.PlannedCheckedInRecorder IS NOT NULL 
//	|			THEN CleaningTasks.PlannedCheckedInGuest.Фамилия
//	|		WHEN CleaningTasks.БлокНомер IS NOT NULL 
//	|			THEN CleaningTasks.RoomBlockType.Code
//	|		ELSE NULL
//	|	END AS Фамилия,
//	|	CASE
//	|		WHEN CleaningTasks.InHouseAccommodation IS NOT NULL 
//	|			THEN CleaningTasks.InHouseGuest.Имя
//	|		WHEN CleaningTasks.CheckOutAccommodation IS NOT NULL 
//	|			THEN CleaningTasks.CheckOutGuest.Имя
//	|		WHEN CleaningTasks.PlannedCheckedInRecorder IS NOT NULL 
//	|			THEN CleaningTasks.PlannedCheckedInGuest.Имя
//	|		WHEN CleaningTasks.БлокНомер IS NOT NULL 
//	|			THEN CleaningTasks.RoomBlockType.Description
//	|		ELSE NULL
//	|	END AS Имя,
//	|	CASE
//	|		WHEN CleaningTasks.InHouseAccommodation IS NOT NULL 
//	|			THEN CleaningTasks.InHouseGuest.Отчество
//	|		WHEN CleaningTasks.CheckOutAccommodation IS NOT NULL 
//	|			THEN CleaningTasks.CheckOutGuest.Отчество
//	|		WHEN CleaningTasks.PlannedCheckedInRecorder IS NOT NULL 
//	|			THEN CleaningTasks.PlannedCheckedInGuest.Отчество
//	|		WHEN CleaningTasks.БлокНомер IS NOT NULL 
//	|			THEN CleaningTasks.RoomBlockRemarks
//	|		ELSE NULL
//	|	END AS Отчество,
//	|	CASE
//	|		WHEN CleaningTasks.InHouseAccommodation IS NOT NULL 
//	|			THEN CleaningTasks.InHouseGuest.Гражданство
//	|		WHEN CleaningTasks.CheckOutAccommodation IS NOT NULL 
//	|			THEN CleaningTasks.CheckOutGuest.Гражданство
//	|		WHEN CleaningTasks.PlannedCheckedInRecorder IS NOT NULL 
//	|			THEN CleaningTasks.PlannedCheckedInGuest.Гражданство
//	|		ELSE NULL
//	|	END AS Гражданство,
//	|	CASE
//	|		WHEN CleaningTasks.InHouseAccommodation IS NOT NULL 
//	|			THEN CleaningTasks.InHouseCheckInDate
//	|		WHEN CleaningTasks.CheckOutAccommodation IS NOT NULL 
//	|			THEN CleaningTasks.CheckOutCheckInDate
//	|		WHEN CleaningTasks.PlannedCheckedInRecorder IS NOT NULL 
//	|			THEN CleaningTasks.PlannedCheckedInCheckInDate
//	|		WHEN CleaningTasks.БлокНомер IS NOT NULL 
//	|			THEN CleaningTasks.RoomBlockStartDate
//	|		ELSE NULL
//	|	END AS CheckInDate,
//	|	CASE
//	|		WHEN CleaningTasks.InHouseAccommodation IS NOT NULL 
//	|			THEN CleaningTasks.InHouseCheckOutDate
//	|		WHEN CleaningTasks.CheckOutAccommodation IS NOT NULL 
//	|			THEN CleaningTasks.CheckOutCheckOutDate
//	|		WHEN CleaningTasks.PlannedCheckedInRecorder IS NOT NULL 
//	|			THEN CleaningTasks.PlannedCheckedInCheckOutDate
//	|		WHEN CleaningTasks.БлокНомер IS NOT NULL 
//	|			THEN CleaningTasks.RoomBlockEndDate
//	|		ELSE NULL
//	|	END AS CheckOutDate,
//	|	CleaningTasks.NumberOfGuests AS NumberOfGuests,
//	|	CleaningTasks.NumberOfExpectedGuests AS NumberOfExpectedGuests,
//	|	CleaningTasks.NumberOfInHouseGuests AS NumberOfInHouseGuests
//	|{SELECT
//	|	Гостиница.*,
//	|	НомерРазмещения.*,
//	|	(CAST(CleaningTasks.НомерРазмещения.RoomPropertiesCodes AS STRING(1024))) AS RoomPropertiesCodes,
//	|	(CAST(CleaningTasks.НомерРазмещения.СвойстваНомера AS STRING(1024))) AS СвойстваНомера,
//	|	СтатусНомера.*,
//	|	RoomStatusChangeTime,
//	|	RoomStatusChangeAuthor.*,
//	|	(CASE
//	|			WHEN CleaningTasks.CheckOutCleaning IS NOT NULL 
//	|				THEN CleaningTasks.CheckOutCleaningCode
//	|			WHEN CleaningTasks.RegularOperation IS NOT NULL 
//	|				THEN CleaningTasks.RegularOperationCode
//	|			WHEN CleaningTasks.RegularCleaning IS NOT NULL 
//	|				THEN CleaningTasks.RegularCleaningCode
//	|			WHEN CleaningTasks.RepairEndCleaning IS NOT NULL 
//	|				THEN CleaningTasks.RepairEndCleaningCode
//	|			WHEN CleaningTasks.VacantRoomCleaning IS NOT NULL 
//	|				THEN CleaningTasks.VacantRoomCleaningCode
//	|			ELSE NULL
//	|		END) AS OperationCode,
//	|	(CASE
//	|			WHEN CleaningTasks.CheckOutCleaning IS NOT NULL 
//	|				THEN CleaningTasks.CheckOutCleaning
//	|			WHEN CleaningTasks.RegularOperation IS NOT NULL 
//	|				THEN CleaningTasks.RegularOperation
//	|			WHEN CleaningTasks.RegularCleaning IS NOT NULL 
//	|				THEN CleaningTasks.RegularCleaning
//	|			WHEN CleaningTasks.RepairEndCleaning IS NOT NULL 
//	|				THEN CleaningTasks.RepairEndCleaning
//	|			WHEN CleaningTasks.VacantRoomCleaning IS NOT NULL 
//	|				THEN CleaningTasks.VacantRoomCleaning
//	|			ELSE NULL
//	|		END).* AS Operation,
//	|	(CASE
//	|			WHEN CleaningTasks.CheckOutCleaning IS NOT NULL 
//	|				THEN CleaningTasks.CheckOutCleaningSortCode
//	|			WHEN CleaningTasks.RegularOperation IS NOT NULL 
//	|				THEN CleaningTasks.RegularOperationSortCode
//	|			WHEN CleaningTasks.RegularCleaning IS NOT NULL 
//	|				THEN CleaningTasks.RegularCleaningSortCode
//	|			WHEN CleaningTasks.RepairEndCleaning IS NOT NULL 
//	|				THEN CleaningTasks.RepairEndCleaningSortCode
//	|			WHEN CleaningTasks.VacantRoomCleaning IS NOT NULL 
//	|				THEN CleaningTasks.VacantRoomCleaningSortCode
//	|			ELSE NULL
//	|		END) AS OperationSortCode,
//	|	(CASE
//	|			WHEN CleaningTasks.InHouseAccommodation IS NOT NULL 
//	|				THEN CleaningTasks.InHouseGuest
//	|			WHEN CleaningTasks.CheckOutAccommodation IS NOT NULL 
//	|				THEN CleaningTasks.CheckOutGuest
//	|			WHEN CleaningTasks.PlannedCheckedInRecorder IS NOT NULL 
//	|				THEN CleaningTasks.PlannedCheckedInGuest
//	|			ELSE NULL
//	|		END).* AS Клиент,
//	|	ТипКлиента.* AS ТипКлиента,
//	|	Фамилия AS Фамилия,
//	|	Имя AS Имя,
//	|	Отчество AS Отчество,
//	|	Гражданство.* AS Гражданство,
//	|	(CASE
//	|			WHEN CleaningTasks.InHouseAccommodation IS NOT NULL 
//	|				THEN CleaningTasks.InHouseAccommodation.ВидРазмещения
//	|			WHEN CleaningTasks.CheckOutAccommodation IS NOT NULL 
//	|				THEN CleaningTasks.CheckOutAccommodation.ВидРазмещения
//	|			WHEN CleaningTasks.PlannedCheckedInRecorder IS NOT NULL 
//	|				THEN CleaningTasks.PlannedCheckedInRecorder.ВидРазмещения
//	|			ELSE NULL
//	|		END).* AS GuestAccommodationType,
//	|	CheckInDate AS CheckInDate,
//	|	CheckOutDate AS CheckOutDate,
//	|	(CASE
//	|			WHEN CleaningTasks.InHouseAccommodation IS NOT NULL 
//	|				THEN CleaningTasks.InHouseAccommodation
//	|			WHEN CleaningTasks.CheckOutAccommodation IS NOT NULL 
//	|				THEN CleaningTasks.CheckOutAccommodation
//	|			WHEN CleaningTasks.PlannedCheckedInRecorder IS NOT NULL 
//	|				THEN CleaningTasks.PlannedCheckedInRecorder
//	|			ELSE NULL
//	|		END).* AS GuestDocument,
//	|	CleaningTasks.CheckOutCleaning,
//	|	CleaningTasks.RegularCleaning,
//	|	CleaningTasks.RepairEndCleaning,
//	|	CleaningTasks.VacantRoomCleaning,
//	|	CleaningTasks.RegularOperation.*,
//	|	CleaningTasks.IsCheckInWaiting,
//	|	CleaningTasks.CheckOutCleaningCode,
//	|	CleaningTasks.RegularCleaningCode,
//	|	CleaningTasks.RepairEndCleaningCode,
//	|	CleaningTasks.VacantRoomCleaningCode,
//	|	CleaningTasks.RegularOperationCode,
//	|	CleaningTasks.InHouseAccommodation.*,
//	|	CleaningTasks.InHouseGuest.*,
//	|	CleaningTasks.InHouseCheckInDate,
//	|	CleaningTasks.InHouseCheckOutDate,
//	|	CleaningTasks.InHouseCustomer.* AS Контрагент,
//	|	CleaningTasks.GuestStatus.*,
//	|	CleaningTasks.InHouseAccommodationType.*,
//	|	CleaningTasks.GuestHousekeepingRemarks AS GuestHousekeepingRemarks,
//	|	NumberOfGuests AS NumberOfGuests,
//	|	NumberOfExpectedGuests AS NumberOfExpectedGuests,
//	|	NumberOfInHouseGuests AS NumberOfInHouseGuests,
//	|	CleaningTasks.CheckOutAccommodation.*,
//	|	CleaningTasks.CheckOutGuest.*,
//	|	CleaningTasks.CheckOutCheckInDate,
//	|	CleaningTasks.CheckOutCheckOutDate,
//	|	CleaningTasks.PlannedCheckedInGuest.*,
//	|	CleaningTasks.PlannedCheckedInCheckInDate,
//	|	CleaningTasks.PlannedCheckedInCheckOutDate,
//	|	CleaningTasks.PlannedCheckedInRecorder.*,
//	|	CleaningTasks.БлокНомер.*,
//	|	CleaningTasks.RoomBlockType.*,
//	|	CleaningTasks.RoomBlockRemarks,
//	|	CleaningTasks.RoomBlockStartDate,
//	|	CleaningTasks.RoomBlockEndDate,
//	|	CleaningTasks.ТипНомера.*}
//	|FROM
//	|	(SELECT
//	|		RoomInventoryBalance.Гостиница AS Гостиница,
//	|		RoomInventoryBalance.НомерРазмещения AS НомерРазмещения,
//	|		RoomInventoryBalance.НомерРазмещения.СтатусНомера AS СтатусНомера,
//	|		RoomInventoryBalance.ТипНомера AS ТипНомера,
//	|		RoomInventoryBalance.TotalRoomsBalance AS TotalRoomsBalance,
//	|		RoomInventoryBalance.TotalBedsBalance AS TotalBedsBalance,
//	|		InHousePersons.Recorder AS InHouseAccommodation,
//	|		InHousePersons.Клиент AS InHouseGuest,
//	|		InHousePersons.ГруппаГостей AS InHouseGuestGroup,
//	|		CASE
//	|			WHEN &qShowGuestGroupDescriptionInCustomerColumns
//	|					AND NOT InHousePersons.Recorder IS NULL 
//	|				THEN InHousePersons.ГруппаГостей.Description
//	|			WHEN NOT &qShowGuestGroupDescriptionInCustomerColumns
//	|					AND NOT InHousePersons.Recorder IS NULL 
//	|				THEN InHousePersons.Контрагент
//	|			ELSE NULL
//	|		END AS InHouseCustomer,
//	|		InHousePersons.КоличествоЧеловек AS InHouseNumberOfPersons,
//	|		InHousePersons.CheckInDate AS InHouseCheckInDate,
//	|		InHousePersons.CheckOutDate AS InHouseCheckOutDate,
//	|		InHousePersons.Recorder.ВидРазмещения AS InHouseAccommodationType,
//	|		CASE
//	|			WHEN NOT InHousePersons.Recorder IS NULL 
//	|				THEN InHousePersons.Recorder.СтатусРазмещения
//	|			WHEN NOT CheckedOutGuests.Recorder IS NULL 
//	|				THEN CheckedOutGuests.Recorder.СтатусРазмещения
//	|			ELSE PlannedCheckedIn.Recorder.ReservationStatus
//	|		END AS GuestStatus,
//	|		CASE
//	|			WHEN NOT PlannedCheckedIn.Recorder IS NULL 
//	|				THEN SUBSTRING(PlannedCheckedIn.Recorder.HousekeepingRemarks, 1, 999)
//	|			ELSE SUBSTRING(InHousePersons.Recorder.HousekeepingRemarks, 1, 999)
//	|		END AS GuestHousekeepingRemarks,
//	|		CASE
//	|			WHEN NOT InHousePersonsForCleaning.Recorder IS NULL 
//	|					AND CheckedOutGuests.Recorder IS NULL 
//	|					AND (RoomInventoryBalance.НомерРазмещения.СтатусНомера <> &qRoomStatusAfterCheckOut
//	|						OR NOT &qRoomStatusAfterCheckOutIsFilled)
//	|				THEN &qRegularCleaning
//	|			ELSE NULL
//	|		END AS RegularCleaning,
//	|		CASE
//	|			WHEN NOT InHousePersonsForCleaning.Recorder IS NULL 
//	|					AND CheckedOutGuests.Recorder IS NULL 
//	|					AND (RoomInventoryBalance.НомерРазмещения.СтатусНомера <> &qRoomStatusAfterCheckOut
//	|						OR NOT &qRoomStatusAfterCheckOutIsFilled)
//	|				THEN &qRegularCleaningCode
//	|			ELSE NULL
//	|		END AS RegularCleaningCode,
//	|		CASE
//	|			WHEN NOT InHousePersonsForCleaning.Recorder IS NULL 
//	|					AND CheckedOutGuests.Recorder IS NULL 
//	|					AND (RoomInventoryBalance.НомерРазмещения.СтатусНомера <> &qRoomStatusAfterCheckOut
//	|						OR NOT &qRoomStatusAfterCheckOutIsFilled)
//	|				THEN &qRegularCleaningSortCode
//	|			ELSE NULL
//	|		END AS RegularCleaningSortCode,
//	|		PlannedCheckedIn.Recorder AS PlannedCheckedInRecorder,
//	|		PlannedCheckedIn.Клиент AS PlannedCheckedInGuest,
//	|		PlannedCheckedIn.КоличествоЧеловек AS PlannedCheckedInNumberOfPersons,
//	|		PlannedCheckedIn.CheckInDate AS PlannedCheckedInCheckInDate,
//	|		PlannedCheckedIn.CheckOutDate AS PlannedCheckedInCheckOutDate,
//	|		CheckedOutGuests.Recorder AS CheckOutAccommodation,
//	|		CheckedOutGuests.Клиент AS CheckOutGuest,
//	|		CheckedOutGuests.КоличествоЧеловек AS CheckOutNumberOfPersons,
//	|		CheckedOutGuests.CheckInDate AS CheckOutCheckInDate,
//	|		CheckedOutGuests.CheckOutDate AS CheckOutCheckOutDate,
//	|		CASE
//	|			WHEN NOT CheckedOutGuests.Recorder IS NULL 
//	|				THEN &qCheckOutCleaning
//	|			WHEN RoomInventoryBalance.НомерРазмещения.СтатусНомера = &qRoomStatusAfterCheckOut
//	|					AND &qRoomStatusAfterCheckOutIsFilled
//	|				THEN &qCheckOutCleaning
//	|			ELSE NULL
//	|		END AS CheckOutCleaning,
//	|		CASE
//	|			WHEN NOT CheckedOutGuests.Recorder IS NULL 
//	|				THEN &qCheckOutCleaningCode
//	|			WHEN RoomInventoryBalance.НомерРазмещения.СтатусНомера = &qRoomStatusAfterCheckOut
//	|					AND &qRoomStatusAfterCheckOutIsFilled
//	|				THEN &qCheckOutCleaningCode
//	|			ELSE NULL
//	|		END AS CheckOutCleaningCode,
//	|		CASE
//	|			WHEN NOT CheckedOutGuests.Recorder IS NULL 
//	|				THEN &qCheckOutCleaningSortCode
//	|			WHEN RoomInventoryBalance.НомерРазмещения.СтатусНомера = &qRoomStatusAfterCheckOut
//	|					AND &qRoomStatusAfterCheckOutIsFilled
//	|				THEN &qCheckOutCleaningSortCode
//	|			ELSE NULL
//	|		END AS CheckOutCleaningSortCode,
//	|		FinishedRoomBlocks.Recorder AS БлокНомер,
//	|		FinishedRoomBlocks.RoomBlockType AS RoomBlockType,
//	|		SUBSTRING(FinishedRoomBlocks.Примечания, 1, 999) AS RoomBlockRemarks,
//	|		FinishedRoomBlocks.CheckInDate AS RoomBlockStartDate,
//	|		FinishedRoomBlocks.CheckOutDate AS RoomBlockEndDate,
//	|		CASE
//	|			WHEN NOT FinishedRoomBlocks.Recorder IS NULL 
//	|				THEN &qRepairEndCleaning
//	|			ELSE NULL
//	|		END AS RepairEndCleaning,
//	|		CASE
//	|			WHEN NOT FinishedRoomBlocks.Recorder IS NULL 
//	|				THEN &qRepairEndCleaningCode
//	|			ELSE NULL
//	|		END AS RepairEndCleaningCode,
//	|		CASE
//	|			WHEN NOT FinishedRoomBlocks.Recorder IS NULL 
//	|				THEN &qRepairEndCleaningSortCode
//	|			ELSE NULL
//	|		END AS RepairEndCleaningSortCode,
//	|		CASE
//	|			WHEN CheckedOutGuests.Recorder IS NULL 
//	|					AND YesterdayCheckedOutGuests.НомерРазмещения IS NULL 
//	|					AND InHousePersons.Recorder IS NULL 
//	|					AND CheckedInPersons.Recorder IS NULL 
//	|					AND CheckedOutGuests.Recorder IS NULL 
//	|					AND БлокирНомеров.Recorder IS NULL 
//	|					AND (RoomInventoryBalance.НомерРазмещения.СтатусНомера <> &qRoomStatusAfterCheckOut
//	|						OR NOT &qRoomStatusAfterCheckOutIsFilled)
//	|				THEN &qVacantRoomCleaning
//	|			ELSE NULL
//	|		END AS VacantRoomCleaning,
//	|		CASE
//	|			WHEN CheckedOutGuests.Recorder IS NULL 
//	|					AND YesterdayCheckedOutGuests.НомерРазмещения IS NULL 
//	|					AND InHousePersons.Recorder IS NULL 
//	|					AND CheckedInPersons.Recorder IS NULL 
//	|					AND CheckedOutGuests.Recorder IS NULL 
//	|					AND БлокирНомеров.Recorder IS NULL 
//	|					AND (RoomInventoryBalance.НомерРазмещения.СтатусНомера <> &qRoomStatusAfterCheckOut
//	|						OR NOT &qRoomStatusAfterCheckOutIsFilled)
//	|				THEN &qVacantRoomCleaningCode
//	|			ELSE NULL
//	|		END AS VacantRoomCleaningCode,
//	|		CASE
//	|			WHEN CheckedOutGuests.Recorder IS NULL 
//	|					AND YesterdayCheckedOutGuests.НомерРазмещения IS NULL 
//	|					AND InHousePersons.Recorder IS NULL 
//	|					AND CheckedInPersons.Recorder IS NULL 
//	|					AND CheckedOutGuests.Recorder IS NULL 
//	|					AND БлокирНомеров.Recorder IS NULL 
//	|					AND (RoomInventoryBalance.НомерРазмещения.СтатусНомера <> &qRoomStatusAfterCheckOut
//	|						OR NOT &qRoomStatusAfterCheckOutIsFilled)
//	|				THEN &qVacantRoomCleaningSortCode
//	|			ELSE NULL
//	|		END AS VacantRoomCleaningSortCode,
//	|		RegularOperations.RegularOperation AS RegularOperation,
//	|		CASE
//	|			WHEN RegularOperations.RegularOperation IS NOT NULL 
//	|				THEN RegularOperations.RegularOperation.Code
//	|			ELSE NULL
//	|		END AS RegularOperationCode,
//	|		CASE
//	|			WHEN RegularOperations.RegularOperation IS NOT NULL 
//	|				THEN RegularOperations.RegularOperation.ПорядокСортировки
//	|			ELSE NULL
//	|		END AS RegularOperationSortCode,
//	|		CASE
//	|			WHEN PlannedCheckedIn.КоличествоЧеловек IS NULL 
//	|				THEN FALSE
//	|			ELSE TRUE
//	|		END AS IsCheckInWaiting,
//	|		PlannedCheckedInGuests.КоличествоЧеловек AS NumberOfExpectedGuests,
//	|		InHouseGuestsTotals.КоличествоЧеловек AS NumberOfInHouseGuests,
//	|		CASE
//	|			WHEN InHousePersons.Recorder IS NOT NULL 
//	|				THEN InHousePersons.КоличествоЧеловек
//	|			WHEN CheckedOutGuests.Recorder IS NOT NULL 
//	|				THEN CheckedOutGuests.КоличествоЧеловек
//	|			ELSE 0
//	|		END AS NumberOfGuests
//	|	FROM
//	|		AccumulationRegister.ЗагрузкаНомеров.Balance(
//	|				&qPeriodTo,
//	|				(Гостиница IN HIERARCHY (&qHotel)
//	|					OR &qIsEmptyHotel)
//	|					AND (НомерРазмещения IN HIERARCHY (&qRoom)
//	|						OR &qIsEmptyRoom)) AS RoomInventoryBalance
//	|			LEFT JOIN AccumulationRegister.ЗагрузкаНомеров AS InHousePersons
//	|			ON RoomInventoryBalance.НомерРазмещения = InHousePersons.НомерРазмещения
//	|				AND (InHousePersons.RecordType = &qExpense)
//	|				AND (InHousePersons.ЭтоГости)
//	|				AND (InHousePersons.IsAccommodation)
//	|				AND (InHousePersons.ПериодС < &qPeriodTo)
//	|				AND (InHousePersons.ПериодПо > &qPeriodFrom)
//	|			LEFT JOIN AccumulationRegister.ЗагрузкаНомеров AS InHousePersonsForCleaning
//	|			ON RoomInventoryBalance.НомерРазмещения = InHousePersonsForCleaning.НомерРазмещения
//	|				AND (InHousePersonsForCleaning.RecordType = &qExpense)
//	|				AND (InHousePersonsForCleaning.ЭтоГости)
//	|				AND (InHousePersonsForCleaning.IsAccommodation)
//	|				AND (InHousePersonsForCleaning.CheckInDate < &qPeriodFrom
//	|					OR &qRoomStatusAfterEarlyCheckInIsFilled
//	|						AND BEGINOFPERIOD(InHousePersonsForCleaning.CheckInDate, DAY) = &qPeriodFrom
//	|						AND DATEDIFF(&qPeriodFrom, InHousePersonsForCleaning.CheckInDate, MINUTE) < 360)
//	|				AND (InHousePersonsForCleaning.ПериодПо > &qPeriodFrom)
//	|			LEFT JOIN (SELECT
//	|				InHouseGuestsCount.НомерРазмещения AS НомерРазмещения,
//	|				SUM(InHouseGuestsCount.КоличествоЧеловек) AS КоличествоЧеловек
//	|			FROM
//	|				AccumulationRegister.ЗагрузкаНомеров AS InHouseGuestsCount
//	|			WHERE
//	|				InHouseGuestsCount.RecordType = &qExpense
//	|				AND InHouseGuestsCount.IsAccommodation
//	|				AND InHouseGuestsCount.ЭтоГости
//	|				AND InHouseGuestsCount.ПериодС < &qPeriodTo
//	|				AND InHouseGuestsCount.ПериодПо > &qPeriodFrom
//	|			
//	|			GROUP BY
//	|				InHouseGuestsCount.НомерРазмещения) AS InHouseGuestsTotals
//	|			ON RoomInventoryBalance.НомерРазмещения = InHouseGuestsTotals.НомерРазмещения
//	|			LEFT JOIN AccumulationRegister.ЗагрузкаНомеров AS CheckedOutGuests
//	|			ON RoomInventoryBalance.НомерРазмещения = CheckedOutGuests.НомерРазмещения
//	|				AND (CheckedOutGuests.RecordType = &qReceipt)
//	|				AND (CheckedOutGuests.ЭтоВыезд)
//	|				AND (CheckedOutGuests.IsAccommodation)
//	|				AND (CheckedOutGuests.CheckOutDate = CheckedOutGuests.Period)
//	|				AND (CheckedOutGuests.CheckOutDate = CheckedOutGuests.ПериодПо)
//	|				AND (CheckedOutGuests.CheckOutDate > &qPeriodFrom)
//	|				AND (CheckedOutGuests.CheckOutDate <= &qPeriodTo)
//	|			LEFT JOIN (SELECT
//	|				RoomInventoryYesterdayCheckedOutGuests.НомерРазмещения AS НомерРазмещения
//	|			FROM
//	|				AccumulationRegister.ЗагрузкаНомеров AS RoomInventoryYesterdayCheckedOutGuests
//	|			WHERE
//	|				RoomInventoryYesterdayCheckedOutGuests.RecordType = &qReceipt
//	|				AND RoomInventoryYesterdayCheckedOutGuests.ЭтоВыезд
//	|				AND RoomInventoryYesterdayCheckedOutGuests.IsAccommodation
//	|				AND (RoomInventoryYesterdayCheckedOutGuests.ВидРазмещения.ТипРазмещения = &qAccTypeRoom
//	|						OR RoomInventoryYesterdayCheckedOutGuests.ВидРазмещения.ТипРазмещения = &qAccTypeBeds)
//	|				AND RoomInventoryYesterdayCheckedOutGuests.CheckOutDate = RoomInventoryYesterdayCheckedOutGuests.Period
//	|				AND RoomInventoryYesterdayCheckedOutGuests.CheckOutDate > &qYesterdayPeriodFrom
//	|				AND RoomInventoryYesterdayCheckedOutGuests.CheckOutDate <= &qYesterdayPeriodTo
//	|			
//	|			GROUP BY
//	|				RoomInventoryYesterdayCheckedOutGuests.НомерРазмещения) AS YesterdayCheckedOutGuests
//	|			ON RoomInventoryBalance.НомерРазмещения = YesterdayCheckedOutGuests.НомерРазмещения
//	|			LEFT JOIN (SELECT
//	|				RoomInventoryLastCheckedOutGuests.НомерРазмещения AS НомерРазмещения,
//	|				MAX(RoomInventoryLastCheckedOutGuests.CheckOutDate) AS LastCheckOutDate
//	|			FROM
//	|				AccumulationRegister.ЗагрузкаНомеров AS RoomInventoryLastCheckedOutGuests
//	|			WHERE
//	|				RoomInventoryLastCheckedOutGuests.RecordType = &qReceipt
//	|				AND RoomInventoryLastCheckedOutGuests.IsAccommodation
//	|				AND RoomInventoryLastCheckedOutGuests.ЭтоВыезд
//	|				AND RoomInventoryLastCheckedOutGuests.CheckOutDate = RoomInventoryLastCheckedOutGuests.Period
//	|				AND RoomInventoryLastCheckedOutGuests.CheckOutDate <= &qPeriodFrom
//	|			
//	|			GROUP BY
//	|				RoomInventoryLastCheckedOutGuests.НомерРазмещения) AS LastCheckedOutGuests
//	|			ON RoomInventoryBalance.НомерРазмещения = LastCheckedOutGuests.НомерРазмещения
//	|			LEFT JOIN AccumulationRegister.ЗагрузкаНомеров AS FinishedRoomBlocks
//	|			ON RoomInventoryBalance.НомерРазмещения = FinishedRoomBlocks.НомерРазмещения
//	|				AND (FinishedRoomBlocks.RecordType = &qExpense)
//	|				AND (FinishedRoomBlocks.IsBlocking)
//	|				AND (FinishedRoomBlocks.Recorder.ДатаКонКвоты > &qPeriodFrom)
//	|				AND (FinishedRoomBlocks.Recorder.ДатаКонКвоты <= &qPeriodTo)
//	|				AND (FinishedRoomBlocks.RoomBlockType.IsRoomRepair)
//	|				AND (FinishedRoomBlocks.CheckInDate = FinishedRoomBlocks.Period)
//	|				AND (FinishedRoomBlocks.CheckInDate = FinishedRoomBlocks.Recorder.ДатаНачКвоты)
//	|			LEFT JOIN AccumulationRegister.ЗагрузкаНомеров AS БлокирНомеров
//	|			ON RoomInventoryBalance.НомерРазмещения = БлокирНомеров.НомерРазмещения
//	|				AND (БлокирНомеров.RecordType = &qExpense)
//	|				AND (БлокирНомеров.IsBlocking)
//	|				AND (БлокирНомеров.Recorder.ДатаНачКвоты = БлокирНомеров.Period)
//	|				AND (БлокирНомеров.Recorder.ДатаКонКвоты > &qPeriodFrom
//	|					OR БлокирНомеров.Recorder.ДатаКонКвоты = &qEmptyDate)
//	|				AND (БлокирНомеров.Recorder.ДатаНачКвоты < &qPeriodTo)
//	|				AND (БлокирНомеров.RoomBlockType.IsRoomRepair)
//	|				AND (БлокирНомеров.CheckInDate = БлокирНомеров.Recorder.ДатаНачКвоты)
//	|			LEFT JOIN AccumulationRegister.ЗагрузкаНомеров AS CheckedInPersons
//	|			ON RoomInventoryBalance.НомерРазмещения = CheckedInPersons.НомерРазмещения
//	|				AND (CheckedInPersons.RecordType = &qExpense)
//	|				AND (CheckedInPersons.ЭтоГости)
//	|				AND (CheckedInPersons.IsAccommodation)
//	|				AND (CheckedInPersons.CheckInDate = CheckedInPersons.Period)
//	|				AND (CheckedInPersons.CheckInDate >= &qPeriodFrom)
//	|				AND (CheckedInPersons.CheckInDate < &qPeriodTo)
//	|			LEFT JOIN (SELECT
//	|				PlannedCheckedInRows.Recorder AS Recorder,
//	|				PlannedCheckedInRows.Контрагент AS Контрагент,
//	|				PlannedCheckedInRows.ГруппаГостей AS ГруппаГостей,
//	|				PlannedCheckedInRows.Клиент AS Клиент,
//	|				PlannedCheckedInRows.CheckInDate AS CheckInDate,
//	|				PlannedCheckedInRows.CheckOutDate AS CheckOutDate,
//	|				PlannedCheckedInRows.НомерРазмещения AS НомерРазмещения,
//	|				SUM(PlannedCheckedInRows.КоличествоЧеловек) AS КоличествоЧеловек
//	|			FROM
//	|				AccumulationRegister.ЗагрузкаНомеров AS PlannedCheckedInRows
//	|			WHERE
//	|				PlannedCheckedInRows.RecordType = &qExpense
//	|				AND PlannedCheckedInRows.IsReservation
//	|				AND PlannedCheckedInRows.Period = PlannedCheckedInRows.CheckInDate
//	|				AND PlannedCheckedInRows.CheckInDate >= &qPeriodFrom
//	|				AND PlannedCheckedInRows.CheckInDate < &qPeriodTo
//	|			
//	|			GROUP BY
//	|				PlannedCheckedInRows.Recorder,
//	|				PlannedCheckedInRows.Контрагент,
//	|				PlannedCheckedInRows.ГруппаГостей,
//	|				PlannedCheckedInRows.Клиент,
//	|				PlannedCheckedInRows.CheckInDate,
//	|				PlannedCheckedInRows.CheckOutDate,
//	|				PlannedCheckedInRows.НомерРазмещения) AS PlannedCheckedIn
//	|			ON RoomInventoryBalance.НомерРазмещения = PlannedCheckedIn.НомерРазмещения
//	|			LEFT JOIN (SELECT
//	|				PlannedCheckedInGuests.НомерРазмещения AS НомерРазмещения,
//	|				SUM(PlannedCheckedInGuests.КоличествоЧеловек) AS КоличествоЧеловек
//	|			FROM
//	|				AccumulationRegister.ЗагрузкаНомеров AS PlannedCheckedInGuests
//	|			WHERE
//	|				PlannedCheckedInGuests.RecordType = &qExpense
//	|				AND PlannedCheckedInGuests.IsReservation
//	|				AND PlannedCheckedInGuests.Period = PlannedCheckedInGuests.CheckInDate
//	|				AND PlannedCheckedInGuests.CheckInDate >= &qPeriodFrom
//	|				AND PlannedCheckedInGuests.CheckInDate < &qPeriodTo
//	|			
//	|			GROUP BY
//	|				PlannedCheckedInGuests.НомерРазмещения) AS PlannedCheckedInGuests
//	|			ON RoomInventoryBalance.НомерРазмещения = PlannedCheckedInGuests.НомерРазмещения
//	|			LEFT JOIN Catalog.НаборРегламентныхРабот.RegularOperations AS RegularOperations
//	|			ON (RegularOperations.Ref = &qRegularOperationGroup)
//	|				AND (RegularOperations.PerformWhenRoomIsBusy
//	|						AND InHousePersons.Recorder IS NOT NULL 
//	|						AND DATEDIFF(&qPeriodFrom, BEGINOFPERIOD(InHousePersons.CheckInDate, DAY), DAY) / RegularOperations.RegularOperationFrequency = (CAST(DATEDIFF(&qPeriodFrom, BEGINOFPERIOD(InHousePersons.CheckInDate, DAY), DAY) / RegularOperations.RegularOperationFrequency AS NUMBER(17, 0)))
//	|						AND DATEDIFF(&qPeriodFrom, BEGINOFPERIOD(InHousePersons.CheckInDate, DAY), DAY) <> 0
//	|					OR RegularOperations.PerformWhenRoomIsBusy
//	|						AND RegularOperations.PerformOnCheckInDay
//	|						AND CheckedInPersons.Recorder IS NOT NULL 
//	|					OR RegularOperations.PerformWhenRoomIsBusy
//	|						AND RegularOperations.PerformOnCheckOutDay
//	|						AND CheckedOutGuests.Recorder IS NOT NULL 
//	|					OR RegularOperations.PerformWhenRoomIsFree
//	|						AND InHousePersons.Recorder IS NULL 
//	|						AND CheckedInPersons.Recorder IS NULL 
//	|						AND CheckedOutGuests.Recorder IS NULL 
//	|						AND (RegularOperations.RegularOperationFrequency = 0
//	|							OR RegularOperations.RegularOperationFrequency = 1
//	|							OR RegularOperations.RegularOperationFrequency > 1
//	|								AND DATEDIFF(&qPeriodFrom, BEGINOFPERIOD(LastCheckedOutGuests.LastCheckOutDate, DAY), DAY) / RegularOperations.RegularOperationFrequency = (CAST(DATEDIFF(&qPeriodFrom, BEGINOFPERIOD(LastCheckedOutGuests.LastCheckOutDate, DAY), DAY) / RegularOperations.RegularOperationFrequency AS NUMBER(17, 0)))
//	|								AND DATEDIFF(&qPeriodFrom, BEGINOFPERIOD(LastCheckedOutGuests.LastCheckOutDate, DAY), DAY) <> 0))
//	|				AND (NOT RegularOperations.DoNotPerformOnWeekends
//	|					OR RegularOperations.DoNotPerformOnWeekends
//	|						AND WEEKDAY(&qPeriodFrom) < 6)
//	|				AND (RegularOperations.ТипНомера = &qEmptyRoomType
//	|					OR RegularOperations.ТипНомера <> &qEmptyRoomType
//	|						AND RoomInventoryBalance.ТипНомера = RegularOperations.ТипНомера
//	|					OR RegularOperations.ТипНомера <> &qEmptyRoomType
//	|						AND RoomInventoryBalance.ТипНомера.Parent <> &qEmptyRoomType
//	|						AND RoomInventoryBalance.ТипНомера.Parent = RegularOperations.ТипНомера)
//	|				AND (RegularOperations.Тариф = &qEmptyRoomRate
//	|					OR RegularOperations.Тариф <> &qEmptyRoomRate
//	|						AND NOT InHousePersons.Recorder.Тариф IS NULL 
//	|						AND InHousePersons.Recorder.Тариф <> &qEmptyRoomRate
//	|						AND (InHousePersons.Recorder.Тариф = RegularOperations.Тариф
//	|							OR InHousePersons.Recorder.Тариф.Parent = RegularOperations.Тариф
//	|							OR InHousePersons.Recorder.Тариф.Parent.Parent = RegularOperations.Тариф))
//	|	WHERE
//	|		RoomInventoryBalance.TotalRoomsBalance > 0
//	|	
//	|	UNION ALL
//	|	
//	|	SELECT
//	|		VirtualRooms.Owner,
//	|		VirtualRooms.Ref,
//	|		VirtualRooms.СтатусНомера,
//	|		VirtualRooms.ТипНомера,
//	|		0,
//	|		0,
//	|		NULL,
//	|		NULL,
//	|		NULL,
//	|		NULL,
//	|		0,
//	|		NULL,
//	|		NULL,
//	|		NULL,
//	|		NULL,
//	|		"""",
//	|		CASE
//	|			WHEN VirtualRooms.СтатусНомера = &qRoomStatusAfterCheckOut
//	|					AND &qRoomStatusAfterCheckOutIsFilled
//	|				THEN &qCheckOutCleaning
//	|			ELSE NULL
//	|		END,
//	|		CASE
//	|			WHEN VirtualRooms.СтатусНомера = &qRoomStatusAfterCheckOut
//	|					AND &qRoomStatusAfterCheckOutIsFilled
//	|				THEN &qCheckOutCleaningCode
//	|			ELSE NULL
//	|		END,
//	|		CASE
//	|			WHEN VirtualRooms.СтатусНомера = &qRoomStatusAfterCheckOut
//	|					AND &qRoomStatusAfterCheckOutIsFilled
//	|				THEN &qCheckOutCleaningSortCode
//	|			ELSE NULL
//	|		END,
//	|		NULL,
//	|		NULL,
//	|		0,
//	|		NULL,
//	|		NULL,
//	|		NULL,
//	|		NULL,
//	|		0,
//	|		NULL,
//	|		NULL,
//	|		NULL,
//	|		NULL,
//	|		NULL,
//	|		NULL,
//	|		NULL,
//	|		"""",
//	|		NULL,
//	|		NULL,
//	|		NULL,
//	|		NULL,
//	|		NULL,
//	|		NULL,
//	|		NULL,
//	|		NULL,
//	|		NULL,
//	|		NULL,
//	|		NULL,
//	|		FALSE,
//	|		0,
//	|		0,
//	|		0
//	|	FROM
//	|		Catalog.НомернойФонд AS VirtualRooms
//	|	WHERE
//	|		VirtualRooms.ВиртуальныйНомер
//	|		AND NOT VirtualRooms.IsFolder
//	|		AND NOT VirtualRooms.DeletionMark
//	|		AND VirtualRooms.ДатаВводаЭкспл <= &qPeriodTo
//	|		AND (VirtualRooms.ДатаВыводаЭкспл = &qEmptyDate
//	|				OR VirtualRooms.ДатаВыводаЭкспл > &qPeriodTo)
//	|		AND (VirtualRooms.Owner IN HIERARCHY (&qHotel)
//	|				OR &qIsEmptyHotel)
//	|		AND (VirtualRooms.Ref IN HIERARCHY (&qRoom)
//	|				OR &qIsEmptyRoom)) AS CleaningTasks
//	|		LEFT JOIN (SELECT
//	|			ИсторияИзмСтатусаНомеров.Period AS Period,
//	|			ИсторияИзмСтатусаНомеров.User AS User,
//	|			ИсторияИзмСтатусаНомеров.НомерРазмещения AS НомерРазмещения,
//	|			ИсторияИзмСтатусаНомеров.СтатусНомера AS СтатусНомера
//	|		FROM
//	|			InformationRegister.ИсторияИзмСтатусаНомеров AS ИсторияИзмСтатусаНомеров
//	|				INNER JOIN InformationRegister.ИсторияИзмСтатусаНомеров.SliceLast(
//	|						&qPeriod,
//	|						(НомерРазмещения.Owner IN HIERARCHY (&qHotel)
//	|							OR &qIsEmptyHotel)
//	|							AND (НомерРазмещения IN HIERARCHY (&qRoom)
//	|								OR &qIsEmptyRoom)) AS RoomStatusChangeHistorySliceLast
//	|				ON ИсторияИзмСтатусаНомеров.Period = RoomStatusChangeHistorySliceLast.Period
//	|					AND ИсторияИзмСтатусаНомеров.НомерРазмещения = RoomStatusChangeHistorySliceLast.НомерРазмещения) AS RoomStatusLastChangeRecord
//	|		ON CleaningTasks.НомерРазмещения = RoomStatusLastChangeRecord.НомерРазмещения
//	|{WHERE
//	|	CleaningTasks.Гостиница.*,
//	|	CleaningTasks.НомерРазмещения.*,
//	|	(CAST(CleaningTasks.НомерРазмещения.RoomPropertiesCodes AS STRING(1024))) AS RoomPropertiesCodes,
//	|	(CAST(CleaningTasks.НомерРазмещения.СвойстваНомера AS STRING(1024))) AS СвойстваНомера,
//	|	CleaningTasks.СтатусНомера.*,
//	|	CleaningTasks.CheckOutCleaning,
//	|	CleaningTasks.CheckOutGuest.*,
//	|	CleaningTasks.CheckOutCheckInDate,
//	|	CleaningTasks.CheckOutCheckOutDate,
//	|	CleaningTasks.CheckOutAccommodation.*,
//	|	CleaningTasks.CheckOutGuest.*,
//	|	CleaningTasks.RegularCleaning,
//	|	(CASE
//	|			WHEN CleaningTasks.InHouseAccommodation IS NOT NULL 
//	|				THEN CleaningTasks.InHouseGuest
//	|			WHEN CleaningTasks.CheckOutAccommodation IS NOT NULL 
//	|				THEN CleaningTasks.CheckOutGuest
//	|			WHEN CleaningTasks.PlannedCheckedInRecorder IS NOT NULL 
//	|				THEN CleaningTasks.PlannedCheckedInGuest
//	|			ELSE NULL
//	|		END).* AS Клиент,
//	|	(CASE
//	|			WHEN CleaningTasks.InHouseAccommodation IS NOT NULL 
//	|				THEN CleaningTasks.InHouseAccommodation
//	|			WHEN CleaningTasks.CheckOutAccommodation IS NOT NULL 
//	|				THEN CleaningTasks.CheckOutAccommodation
//	|			WHEN CleaningTasks.PlannedCheckedInRecorder IS NOT NULL 
//	|				THEN CleaningTasks.PlannedCheckedInRecorder
//	|			ELSE NULL
//	|		END).* AS GuestDocument,
//	|	(CASE
//	|			WHEN CleaningTasks.InHouseAccommodation IS NOT NULL 
//	|				THEN CleaningTasks.InHouseAccommodation.ВидРазмещения
//	|			WHEN CleaningTasks.CheckOutAccommodation IS NOT NULL 
//	|				THEN CleaningTasks.CheckOutAccommodation.ВидРазмещения
//	|			WHEN CleaningTasks.PlannedCheckedInRecorder IS NOT NULL 
//	|				THEN CleaningTasks.PlannedCheckedInRecorder.ВидРазмещения
//	|			ELSE NULL
//	|		END).* AS GuestAccommodationType,
//	|	(CASE
//	|			WHEN CleaningTasks.InHouseAccommodation IS NOT NULL 
//	|				THEN CleaningTasks.InHouseAccommodation.ТипКлиента
//	|			WHEN CleaningTasks.CheckOutAccommodation IS NOT NULL 
//	|				THEN CleaningTasks.CheckOutAccommodation.ТипКлиента
//	|			WHEN CleaningTasks.PlannedCheckedInRecorder IS NOT NULL 
//	|				THEN CleaningTasks.PlannedCheckedInRecorder.ТипКлиента
//	|			ELSE NULL
//	|		END).* AS ТипКлиента,
//	|	(CASE
//	|			WHEN CleaningTasks.InHouseAccommodation IS NOT NULL 
//	|				THEN CleaningTasks.InHouseGuest.Фамилия
//	|			WHEN CleaningTasks.CheckOutAccommodation IS NOT NULL 
//	|				THEN CleaningTasks.CheckOutGuest.Фамилия
//	|			WHEN CleaningTasks.PlannedCheckedInRecorder IS NOT NULL 
//	|				THEN CleaningTasks.PlannedCheckedInGuest.Фамилия
//	|			WHEN CleaningTasks.БлокНомер IS NOT NULL 
//	|				THEN CleaningTasks.RoomBlockType.Code
//	|			ELSE NULL
//	|		END) AS Фамилия,
//	|	(CASE
//	|			WHEN CleaningTasks.InHouseAccommodation IS NOT NULL 
//	|				THEN CleaningTasks.InHouseGuest.Имя
//	|			WHEN CleaningTasks.CheckOutAccommodation IS NOT NULL 
//	|				THEN CleaningTasks.CheckOutGuest.Имя
//	|			WHEN CleaningTasks.PlannedCheckedInRecorder IS NOT NULL 
//	|				THEN CleaningTasks.PlannedCheckedInGuest.Имя
//	|			WHEN CleaningTasks.БлокНомер IS NOT NULL 
//	|				THEN CleaningTasks.RoomBlockType.Description
//	|			ELSE NULL
//	|		END) AS Имя,
//	|	(CASE
//	|			WHEN CleaningTasks.InHouseAccommodation IS NOT NULL 
//	|				THEN CleaningTasks.InHouseGuest.Отчество
//	|			WHEN CleaningTasks.CheckOutAccommodation IS NOT NULL 
//	|				THEN CleaningTasks.CheckOutGuest.Отчество
//	|			WHEN CleaningTasks.PlannedCheckedInRecorder IS NOT NULL 
//	|				THEN CleaningTasks.PlannedCheckedInGuest.Отчество
//	|			WHEN CleaningTasks.БлокНомер IS NOT NULL 
//	|				THEN CleaningTasks.RoomBlockRemarks
//	|			ELSE NULL
//	|		END) AS Отчество,
//	|	(CASE
//	|			WHEN CleaningTasks.InHouseAccommodation IS NOT NULL 
//	|				THEN CleaningTasks.InHouseGuest.Гражданство
//	|			WHEN CleaningTasks.CheckOutAccommodation IS NOT NULL 
//	|				THEN CleaningTasks.CheckOutGuest.Гражданство
//	|			WHEN CleaningTasks.PlannedCheckedInRecorder IS NOT NULL 
//	|				THEN CleaningTasks.PlannedCheckedInGuest.Гражданство
//	|			ELSE NULL
//	|		END).* AS Гражданство,
//	|	(CASE
//	|			WHEN CleaningTasks.InHouseAccommodation IS NOT NULL 
//	|				THEN CleaningTasks.InHouseCheckInDate
//	|			WHEN CleaningTasks.CheckOutAccommodation IS NOT NULL 
//	|				THEN CleaningTasks.CheckOutCheckInDate
//	|			WHEN CleaningTasks.PlannedCheckedInRecorder IS NOT NULL 
//	|				THEN CleaningTasks.PlannedCheckedInCheckInDate
//	|			WHEN CleaningTasks.БлокНомер IS NOT NULL 
//	|				THEN CleaningTasks.RoomBlockStartDate
//	|			ELSE NULL
//	|		END) AS CheckInDate,
//	|	(CASE
//	|			WHEN CleaningTasks.InHouseAccommodation IS NOT NULL 
//	|				THEN CleaningTasks.InHouseCheckOutDate
//	|			WHEN CleaningTasks.CheckOutAccommodation IS NOT NULL 
//	|				THEN CleaningTasks.CheckOutCheckOutDate
//	|			WHEN CleaningTasks.PlannedCheckedInRecorder IS NOT NULL 
//	|				THEN CleaningTasks.PlannedCheckedInCheckOutDate
//	|			WHEN CleaningTasks.БлокНомер IS NOT NULL 
//	|				THEN CleaningTasks.RoomBlockEndDate
//	|			ELSE NULL
//	|		END) AS CheckOutDate,
//	|	CleaningTasks.InHouseGuest.*,
//	|	CleaningTasks.InHouseCheckInDate,
//	|	CleaningTasks.InHouseCheckOutDate,
//	|	CleaningTasks.InHouseAccommodation.*,
//	|	CleaningTasks.PlannedCheckedInGuest.*,
//	|	CleaningTasks.PlannedCheckedInCheckInDate,
//	|	CleaningTasks.PlannedCheckedInCheckOutDate,
//	|	CleaningTasks.PlannedCheckedInRecorder.*,
//	|	CleaningTasks.БлокНомер.*,
//	|	CleaningTasks.RoomBlockType.*,
//	|	CleaningTasks.RoomBlockRemarks,
//	|	CleaningTasks.RoomBlockStartDate,
//	|	CleaningTasks.RoomBlockEndDate,
//	|	CleaningTasks.RepairEndCleaning,
//	|	CleaningTasks.VacantRoomCleaning,
//	|	CleaningTasks.RegularOperation,
//	|	CleaningTasks.ТипНомера.*}
//	|
//	|ORDER BY
//	|	Гостиница,
//	|	НомерРазмещения
//	|{ORDER BY
//	|	Гостиница.*,
//	|	НомерРазмещения.*,
//	|	(CAST(CleaningTasks.НомерРазмещения.RoomPropertiesCodes AS STRING(1024))) AS RoomPropertiesCodes,
//	|	(CAST(CleaningTasks.НомерРазмещения.СвойстваНомера AS STRING(1024))) AS СвойстваНомера,
//	|	СтатусНомера.*,
//	|	CleaningTasks.CheckOutCleaning,
//	|	CleaningTasks.CheckOutCleaningCode,
//	|	CleaningTasks.CheckOutCleaningSortCode,
//	|	CleaningTasks.CheckOutGuest.*,
//	|	CleaningTasks.CheckOutCheckInDate,
//	|	CleaningTasks.CheckOutCheckOutDate,
//	|	CleaningTasks.PlannedCheckedInGuest.*,
//	|	CleaningTasks.PlannedCheckedInCheckInDate,
//	|	CleaningTasks.PlannedCheckedInCheckOutDate,
//	|	CleaningTasks.PlannedCheckedInRecorder.*,
//	|	CleaningTasks.RegularCleaning,
//	|	CleaningTasks.RegularCleaningCode,
//	|	CleaningTasks.RegularCleaningSortCode,
//	|	CleaningTasks.InHouseGuest.*,
//	|	CleaningTasks.InHouseCheckInDate,
//	|	CleaningTasks.InHouseCheckOutDate,
//	|	CleaningTasks.GuestStatus.*,
//	|	CleaningTasks.InHouseAccommodationType.*,
//	|	CleaningTasks.RepairEndCleaning,
//	|	CleaningTasks.RepairEndCleaningCode,
//	|	CleaningTasks.RepairEndCleaningSortCode,
//	|	CleaningTasks.RoomBlockType.*,
//	|	CleaningTasks.RoomBlockRemarks,
//	|	CleaningTasks.RoomBlockStartDate,
//	|	CleaningTasks.RoomBlockEndDate,
//	|	CleaningTasks.VacantRoomCleaning,
//	|	CleaningTasks.VacantRoomCleaningCode,
//	|	CleaningTasks.VacantRoomCleaningSortCode,
//	|	CleaningTasks.RegularOperation,
//	|	CleaningTasks.RegularOperationCode,
//	|	CleaningTasks.RegularOperationSortCode,
//	|	CleaningTasks.ТипНомера.*,
//	|	CleaningTasks.InHouseAccommodation.*,
//	|	CleaningTasks.CheckOutAccommodation.*,
//	|	CleaningTasks.CheckOutGuest.*,
//	|	CleaningTasks.БлокНомер.*,
//	|	(CASE
//	|			WHEN CleaningTasks.InHouseAccommodation IS NOT NULL 
//	|				THEN CleaningTasks.InHouseGuest
//	|			WHEN CleaningTasks.CheckOutAccommodation IS NOT NULL 
//	|				THEN CleaningTasks.CheckOutGuest
//	|			WHEN CleaningTasks.PlannedCheckedInRecorder IS NOT NULL 
//	|				THEN CleaningTasks.PlannedCheckedInGuest
//	|			ELSE NULL
//	|		END).* AS Клиент,
//	|	(CASE
//	|			WHEN CleaningTasks.InHouseAccommodation IS NOT NULL 
//	|				THEN CleaningTasks.InHouseAccommodation
//	|			WHEN CleaningTasks.CheckOutAccommodation IS NOT NULL 
//	|				THEN CleaningTasks.CheckOutAccommodation
//	|			WHEN CleaningTasks.PlannedCheckedInRecorder IS NOT NULL 
//	|				THEN CleaningTasks.PlannedCheckedInRecorder
//	|			ELSE NULL
//	|		END).* AS GuestDocument,
//	|	(CASE
//	|			WHEN CleaningTasks.InHouseAccommodation IS NOT NULL 
//	|				THEN CleaningTasks.InHouseAccommodation.ВидРазмещения
//	|			WHEN CleaningTasks.CheckOutAccommodation IS NOT NULL 
//	|				THEN CleaningTasks.CheckOutAccommodation.ВидРазмещения
//	|			WHEN CleaningTasks.PlannedCheckedInRecorder IS NOT NULL 
//	|				THEN CleaningTasks.PlannedCheckedInRecorder.ВидРазмещения
//	|			ELSE NULL
//	|		END).* AS GuestAccommodationType,
//	|	Operation.*,
//	|	OperationCode,
//	|	OperationSortCode,
//	|	Фамилия,
//	|	Имя,
//	|	Отчество,
//	|	Гражданство.*,
//	|	CheckInDate,
//	|	CheckOutDate}
//	|TOTALS
//	|	SUM(NumberOfGuests),
//	|	SUM(NumberOfExpectedGuests),
//	|	SUM(NumberOfInHouseGuests)
//	|BY
//	|	OVERALL,
//	|	Гостиница,
//	|	НомерРазмещения
//	|{TOTALS BY
//	|	Гостиница.*,
//	|	НомерРазмещения.*,
//	|	СтатусНомера.*,
//	|	(CAST(CleaningTasks.НомерРазмещения.RoomPropertiesCodes AS STRING(1024))) AS RoomPropertiesCodes,
//	|	(CAST(CleaningTasks.НомерРазмещения.СвойстваНомера AS STRING(1024))) AS СвойстваНомера,
//	|	CleaningTasks.CheckOutGuest.*,
//	|	CleaningTasks.CheckOutCleaning,
//	|	CleaningTasks.InHouseGuest.*,
//	|	CleaningTasks.RegularCleaning,
//	|	CleaningTasks.RepairEndCleaning,
//	|	CleaningTasks.VacantRoomCleaning,
//	|	CleaningTasks.RegularOperation,
//	|	CleaningTasks.RoomBlockType.*,
//	|	CleaningTasks.InHouseAccommodation.*,
//	|	CleaningTasks.CheckOutAccommodation.*,
//	|	CleaningTasks.БлокНомер.*,
//	|	ТипКлиента.* AS ТипКлиента,
//	|	(CASE
//	|			WHEN CleaningTasks.InHouseAccommodation IS NOT NULL 
//	|				THEN CleaningTasks.InHouseGuest
//	|			WHEN CleaningTasks.CheckOutAccommodation IS NOT NULL 
//	|				THEN CleaningTasks.CheckOutGuest
//	|			WHEN CleaningTasks.PlannedCheckedInRecorder IS NOT NULL 
//	|				THEN CleaningTasks.PlannedCheckedInGuest
//	|			ELSE NULL
//	|		END).* AS Клиент,
//	|	(CASE
//	|			WHEN CleaningTasks.InHouseAccommodation IS NOT NULL 
//	|				THEN CleaningTasks.InHouseAccommodation
//	|			WHEN CleaningTasks.CheckOutAccommodation IS NOT NULL 
//	|				THEN CleaningTasks.CheckOutAccommodation
//	|			WHEN CleaningTasks.PlannedCheckedInRecorder IS NOT NULL 
//	|				THEN CleaningTasks.PlannedCheckedInRecorder
//	|			ELSE NULL
//	|		END).* AS GuestDocument,
//	|	(CASE
//	|			WHEN CleaningTasks.InHouseAccommodation IS NOT NULL 
//	|				THEN CleaningTasks.InHouseAccommodation.ВидРазмещения
//	|			WHEN CleaningTasks.CheckOutAccommodation IS NOT NULL 
//	|				THEN CleaningTasks.CheckOutAccommodation.ВидРазмещения
//	|			WHEN CleaningTasks.PlannedCheckedInRecorder IS NOT NULL 
//	|				THEN CleaningTasks.PlannedCheckedInRecorder.ВидРазмещения
//	|			ELSE NULL
//	|		END).* AS GuestAccommodationType,
//	|	Operation}";
//	ReportBuilder.Text = QueryText;
//	ReportBuilder.FillSettings();
//	
//	// Initialize report builder with default query
//	vRB = New ReportBuilder(QueryText);
//	vRBSettings = vRB.GetSettings(True, True, True, True, True);
//	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
//	
//	// Set default report builder header text
//	ReportBuilder.HeaderText = NStr("EN='Cleaning task';RU='Задание на уборку';de='Aufgabe der Reinigung'");
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
