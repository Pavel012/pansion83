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
//	If НЕ ЗначениеЗаполнено(PeriodFrom) Тогда
//		PeriodFrom = BegOfMonth(CurrentDate()); // Begin of current month
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
//	If НЕ ЗначениеЗаполнено(PeriodFrom) And НЕ ЗначениеЗаполнено(PeriodTo) Тогда
//		vParamPresentation = vParamPresentation + NStr("en='Report period is not set';ru='Период отчета не установлен';de='Berichtszeitraum nicht festgelegt'") + 
//		                     ";" + Chars.LF;
//	ElsIf НЕ ЗначениеЗаполнено(PeriodFrom) Тогда
//		vParamPresentation = vParamPresentation + NStr("ru = 'Период по '; en = 'Period to '") + 
//		                     Format(PeriodTo, "DF='dd.MM.yyyy'") + 
//		                     ";" + Chars.LF;
//	ElsIf НЕ ЗначениеЗаполнено(PeriodTo) Тогда
//		vParamPresentation = vParamPresentation + NStr("ru = 'Период с '; en = 'Period from '") + 
//		                     Format(PeriodFrom, "DF='dd.MM.yyyy'") + 
//		                     ";" + Chars.LF;
//	ElsIf BegOfDay(PeriodFrom) = BegOfDay(PeriodTo) Тогда
//		vParamPresentation = vParamPresentation + NStr("ru = 'Период на '; en = 'Period on '") + 
//		                     Format(PeriodFrom, "DF='dd.MM.yyyy'") + 
//		                     ";" + Chars.LF;
//	ElsIf PeriodFrom <= PeriodTo Тогда
//		vParamPresentation = vParamPresentation + NStr("ru = 'Период '; en = 'Period '") + PeriodPresentation(PeriodFrom, PeriodTo, cmLocalizationCode()) + 
//		                     ";" + Chars.LF;
//	Else
//		vParamPresentation = vParamPresentation + NStr("en='Period is wrong!';ru='Неправильно задан период!';de='Der Zeitraum wurde falsch eingetragen!'") + 
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
//	// Save report builder settings
//	vReportBuilderSettings = ReportBuilder.GetSettings(True, True, True, True, True);
//	
//	// Build and set report builder query
//	vCurDay = BegOfDay(PeriodFrom);
//	vReportBuilderText = QuerySelect;
//	While EndOfDay(vCurDay) <= EndOfDay(PeriodTo) Do
//		vYYYYMMDD = Format(BegOfDay(vCurDay), "DF=yyyyMMdd");
//		vDDMMYYYY = Format(BegOfDay(vCurDay), "DF=ddMMyyyy");
//		
//		If vCurDay > BegOfDay(PeriodFrom) Тогда
//			vReportBuilderText = vReportBuilderText + Chars.LF + "UNION ALL" + Chars.LF;
//		EndIf;
//		vReportBuilderText = vReportBuilderText + StrReplace(StrReplace(QueryYYYYMMDDSelect, "YYYYMMDD", vYYYYMMDD), "DDMMYYYY", vDDMMYYYY);
//		
//		vCurDay = vCurDay + 24*3600;
//	EndDo;
//	vReportBuilderText = vReportBuilderText + QueryTail;
//	ReportBuilder.Text = vReportBuilderText;
//	
//	// Fill static report query parameters
//	ReportBuilder.Parameters.Вставить("qHotel", Гостиница);
//	ReportBuilder.Parameters.Вставить("qIsEmptyHotel", НЕ ЗначениеЗаполнено(Гостиница));
//	ReportBuilder.Parameters.Вставить("qRoom", ГруппаНомеров);
//	ReportBuilder.Parameters.Вставить("qIsEmptyRoom", НЕ ЗначениеЗаполнено(ГруппаНомеров));
//	ReportBuilder.Parameters.Вставить("qExpense", AccumulationRecordType.Expense);
//	ReportBuilder.Parameters.Вставить("qReceipt", AccumulationRecordType.Receipt);
//	ReportBuilder.Parameters.Вставить("qRegularCleaning", RegularCleaning);
//	ReportBuilder.Parameters.Вставить("qRegularCleaningCode", ?(ЗначениеЗаполнено(RegularCleaning), RegularCleaning.Code, ""));
//	ReportBuilder.Parameters.Вставить("qRegularCleaningSortCode", ?(ЗначениеЗаполнено(RegularCleaning), RegularCleaning.SortCode, 0));
//	ReportBuilder.Parameters.Вставить("qCheckOutCleaning", CheckOutCleaning);
//	ReportBuilder.Parameters.Вставить("qCheckOutCleaningCode", ?(ЗначениеЗаполнено(CheckOutCleaning), CheckOutCleaning.Code, ""));
//	ReportBuilder.Parameters.Вставить("qCheckOutCleaningSortCode", ?(ЗначениеЗаполнено(CheckOutCleaning), CheckOutCleaning.SortCode, 0));
//	ReportBuilder.Parameters.Вставить("qVacantRoomCleaning", VacantRoomCleaning);
//	ReportBuilder.Parameters.Вставить("qVacantRoomCleaningCode", ?(ЗначениеЗаполнено(VacantRoomCleaning), VacantRoomCleaning.Code, ""));
//	ReportBuilder.Parameters.Вставить("qVacantRoomCleaningSortCode", ?(ЗначениеЗаполнено(VacantRoomCleaning), VacantRoomCleaning.SortCode, 0));
//	ReportBuilder.Parameters.Вставить("qRepairEndCleaning", RepairEndCleaning);
//	ReportBuilder.Parameters.Вставить("qRepairEndCleaningCode", ?(ЗначениеЗаполнено(RepairEndCleaning), RepairEndCleaning.Code, ""));
//	ReportBuilder.Parameters.Вставить("qRepairEndCleaningSortCode", ?(ЗначениеЗаполнено(RepairEndCleaning), RepairEndCleaning.SortCode, 0));
//    ReportBuilder.Parameters.Вставить("qRegularOperationGroup", RegularOperationGroup);
//	
//	// Fill dynamic report query parameters
//	vCurDay = BegOfDay(PeriodFrom);
//	While EndOfDay(vCurDay) <= EndOfDay(PeriodTo) Do
//		vDDMMYYYY = Format(BegOfDay(vCurDay), "DF=ddMMyyyy");
//		
//		ReportBuilder.Parameters.Вставить("qPeriodFrom" + vDDMMYYYY, BegOfDay(vCurDay));
//		ReportBuilder.Parameters.Вставить("qPeriodTo" + vDDMMYYYY, EndOfDay(vCurDay));
//		
//		vCurDay = vCurDay + 24*3600;
//	EndDo;
//	
//	// Fill report builder fields presentations from the report template
//	cmFillReportAttributesPresentations(ThisObject);
//	
//	// Load report builder settings
//	ReportBuilder.SetSettings(vReportBuilderSettings, True, True, True, True, True);
//	
//	// Execute report builder query
//	ReportBuilder.Execute();
//	
//	// Apply appearance settings to the report template
////	vTemplateAttributes = cmApplyReportTemplateAppearance(ThisObject);
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
//	// Initialize main SELECT part of the query
//	QuerySelect = 
//	"SELECT
//	|	TaskTurnovers.Гостиница AS Гостиница,
//	|	TaskTurnovers.НомерРазмещения AS НомерРазмещения,
//	|	TaskTurnovers.ТипНомера AS ТипНомера,
//	|	TaskTurnovers.Клиент AS Клиент,
//	|	TaskTurnovers.RoomBlockType AS RoomBlockType,
//	|	TaskTurnovers.Гражданство AS Гражданство,
//	|	TaskTurnovers.CheckInDate AS CheckInDate,
//	|	TaskTurnovers.CheckOutDate AS CheckOutDate,
//	|	TaskTurnovers.CheckOutCleaning AS CheckOutCleaning,
//	|	TaskTurnovers.RegularCleaning AS RegularCleaning,
//	|	TaskTurnovers.RepairEndCleaning AS RepairEndCleaning,
//	|	TaskTurnovers.VacantRoomCleaning AS VacantRoomCleaning,
//	|	TaskTurnovers.RegularOperation AS RegularOperation,
//	|	TaskTurnovers.CheckOutCleaningCode AS CheckOutCleaningCode,
//	|	TaskTurnovers.RegularCleaningCode AS RegularCleaningCode,
//	|	TaskTurnovers.RepairEndCleaningCode AS RepairEndCleaningCode,
//	|	TaskTurnovers.VacantRoomCleaningCode AS VacantRoomCleaningCode,
//	|	TaskTurnovers.RegularOperationCode AS RegularOperationCode,
//	|	TaskTurnovers.CheckOutCleaningSortCode AS CheckOutCleaningSortCode,
//	|	TaskTurnovers.RegularCleaningSortCode AS RegularCleaningSortCode,
//	|	TaskTurnovers.RepairEndCleaningSortCode AS RepairEndCleaningSortCode,
//	|	TaskTurnovers.VacantRoomCleaningSortCode AS VacantRoomCleaningSortCode,
//	|	TaskTurnovers.RegularOperationSortCode AS RegularOperationSortCode,
//	|	SUM(TaskTurnovers.CheckOutCleaningCount) AS CheckOutCleaningCount,
//	|	SUM(TaskTurnovers.RegularCleaningCount) AS RegularCleaningCount,
//	|	SUM(TaskTurnovers.RepairEndCleaningCount) AS RepairEndCleaningCount,
//	|	SUM(TaskTurnovers.VacantRoomCleaningCount) AS VacantRoomCleaningCount,
//	|	SUM(TaskTurnovers.RegularOperationCount) AS RegularOperationCount
//	|{SELECT
//	|	Гостиница.* AS Гостиница,
//	|	НомерРазмещения.* AS НомерРазмещения,
//	|	ТипНомера.* AS ТипНомера,
//	|	RoomBlockType.* AS RoomBlockType,
//	|	Клиент.* AS Клиент,
//	|	Гражданство.* AS Гражданство,
//	|	CheckInDate AS CheckInDate,
//	|	CheckOutDate AS CheckOutDate,
//	|	CheckOutCleaning.* AS CheckOutCleaning,
//	|	RegularCleaning.* AS RegularCleaning,
//	|	RepairEndCleaning.* AS RepairEndCleaning,
//	|	VacantRoomCleaning.* AS VacantRoomCleaning,
//	|	RegularOperation.* AS RegularOperation,
//	|	CheckOutCleaningCode AS CheckOutCleaningCode,
//	|	RegularCleaningCode AS RegularCleaningCode,
//	|	RepairEndCleaningCode AS RepairEndCleaningCode,
//	|	VacantRoomCleaningCode AS VacantRoomCleaningCode,
//	|	RegularOperationCode AS RegularOperationCode,
//	|	CheckOutCleaningSortCode AS CheckOutCleaningSortCode,
//	|	RegularCleaningSortCode AS RegularCleaningSortCode,
//	|	RepairEndCleaningSortCode AS RepairEndCleaningSortCode,
//	|	VacantRoomCleaningSortCode AS VacantRoomCleaningSortCode,
//	|	RegularOperationSortCode AS RegularOperationSortCode,
//	|	CheckOutCleaningCount AS CheckOutCleaningCount,
//	|	RegularCleaningCount AS RegularCleaningCount,
//	|	RepairEndCleaningCount AS RepairEndCleaningCount,
//	|	VacantRoomCleaningCount AS VacantRoomCleaningCount,
//	|	RegularOperationCount AS RegularOperationCount}
//	|FROM (";
//	
//	// Initialize per day query text
//	QueryYYYYMMDDSelect = 
//	"SELECT DISTINCT
//	|	TaskTurnoversYYYYMMDD.Гостиница AS Гостиница,
//	|	TaskTurnoversYYYYMMDD.НомерРазмещения AS НомерРазмещения,
//	|	TaskTurnoversYYYYMMDD.ТипНомера AS ТипНомера,
//	|	CASE
//	|		WHEN TaskTurnoversYYYYMMDD.CheckOutAccommodation IS NOT NULL 
//	|			THEN TaskTurnoversYYYYMMDD.CheckOutGuest
//	|		WHEN TaskTurnoversYYYYMMDD.InHouseAccommodation IS NOT NULL 
//	|			THEN TaskTurnoversYYYYMMDD.InHouseGuest
//	|		WHEN TaskTurnoversYYYYMMDD.CheckInAccommodation IS NOT NULL 
//	|			THEN TaskTurnoversYYYYMMDD.CheckInGuest
//	|		ELSE NULL
//	|	END AS Клиент,
//	|	CASE
//	|		WHEN TaskTurnoversYYYYMMDD.CheckOutAccommodation IS NOT NULL 
//	|			THEN TaskTurnoversYYYYMMDD.CheckOutGuest.Гражданство
//	|		WHEN TaskTurnoversYYYYMMDD.InHouseAccommodation IS NOT NULL 
//	|			THEN TaskTurnoversYYYYMMDD.InHouseGuest.Гражданство
//	|		WHEN TaskTurnoversYYYYMMDD.CheckInAccommodation IS NOT NULL 
//	|			THEN TaskTurnoversYYYYMMDD.CheckInGuest.Гражданство
//	|		ELSE NULL
//	|	END AS Гражданство,
//	|	CASE
//	|		WHEN TaskTurnoversYYYYMMDD.CheckOutAccommodation IS NOT NULL 
//	|			THEN NULL
//	|		WHEN TaskTurnoversYYYYMMDD.InHouseAccommodation IS NOT NULL 
//	|			THEN NULL
//	|		WHEN TaskTurnoversYYYYMMDD.БлокНомер IS NOT NULL 
//	|			THEN TaskTurnoversYYYYMMDD.RoomBlockType
//	|		WHEN TaskTurnoversYYYYMMDD.CheckInAccommodation IS NOT NULL 
//	|			THEN NULL
//	|		ELSE NULL
//	|	END AS RoomBlockType,
//	|	CASE
//	|		WHEN TaskTurnoversYYYYMMDD.CheckOutAccommodation IS NOT NULL 
//	|			THEN TaskTurnoversYYYYMMDD.CheckOutCheckInDate
//	|		WHEN TaskTurnoversYYYYMMDD.InHouseAccommodation IS NOT NULL 
//	|			THEN TaskTurnoversYYYYMMDD.InHouseCheckInDate
//	|		WHEN TaskTurnoversYYYYMMDD.БлокНомер IS NOT NULL 
//	|			THEN TaskTurnoversYYYYMMDD.RoomBlockStartDate
//	|		WHEN TaskTurnoversYYYYMMDD.CheckInAccommodation IS NOT NULL 
//	|			THEN TaskTurnoversYYYYMMDD.CheckInCheckInDate
//	|		ELSE NULL
//	|	END AS CheckInDate,
//	|	CASE
//	|		WHEN TaskTurnoversYYYYMMDD.CheckOutAccommodation IS NOT NULL 
//	|			THEN TaskTurnoversYYYYMMDD.CheckOutCheckOutDate
//	|		WHEN TaskTurnoversYYYYMMDD.InHouseAccommodation IS NOT NULL 
//	|			THEN TaskTurnoversYYYYMMDD.InHouseCheckOutDate
//	|		WHEN TaskTurnoversYYYYMMDD.БлокНомер IS NOT NULL 
//	|			THEN TaskTurnoversYYYYMMDD.RoomBlockEndDate
//	|		WHEN TaskTurnoversYYYYMMDD.CheckInAccommodation IS NOT NULL 
//	|			THEN TaskTurnoversYYYYMMDD.CheckInCheckOutDate
//	|		ELSE NULL
//	|	END AS CheckOutDate,
//	|	TaskTurnoversYYYYMMDD.CheckOutCleaning AS CheckOutCleaning,
//	|	TaskTurnoversYYYYMMDD.RegularCleaning AS RegularCleaning,
//	|	TaskTurnoversYYYYMMDD.RepairEndCleaning AS RepairEndCleaning,
//	|	TaskTurnoversYYYYMMDD.VacantRoomCleaning AS VacantRoomCleaning,
//	|	TaskTurnoversYYYYMMDD.RegularOperation AS RegularOperation,
//	|	TaskTurnoversYYYYMMDD.CheckOutCleaningCode AS CheckOutCleaningCode,
//	|	TaskTurnoversYYYYMMDD.RegularCleaningCode AS RegularCleaningCode,
//	|	TaskTurnoversYYYYMMDD.RepairEndCleaningCode AS RepairEndCleaningCode,
//	|	TaskTurnoversYYYYMMDD.VacantRoomCleaningCode AS VacantRoomCleaningCode,
//	|	TaskTurnoversYYYYMMDD.RegularOperationCode AS RegularOperationCode,
//	|	TaskTurnoversYYYYMMDD.CheckOutCleaningSortCode AS CheckOutCleaningSortCode,
//	|	TaskTurnoversYYYYMMDD.RegularCleaningSortCode AS RegularCleaningSortCode,
//	|	TaskTurnoversYYYYMMDD.RepairEndCleaningSortCode AS RepairEndCleaningSortCode,
//	|	TaskTurnoversYYYYMMDD.VacantRoomCleaningSortCode AS VacantRoomCleaningSortCode,
//	|	TaskTurnoversYYYYMMDD.RegularOperationSortCode AS RegularOperationSortCode,
//	|	CASE 
//	|		WHEN TaskTurnoversYYYYMMDD.CheckOutCleaning IS NOT NULL
//	|			THEN 1
//	|		ELSE 0
//	|	END AS CheckOutCleaningCount,
//	|	CASE 
//	|		WHEN TaskTurnoversYYYYMMDD.RegularCleaning IS NOT NULL
//	|			THEN 1
//	|		ELSE 0
//	|	END AS RegularCleaningCount,
//	|	CASE 
//	|		WHEN TaskTurnoversYYYYMMDD.RepairEndCleaning IS NOT NULL
//	|			THEN 1
//	|		ELSE 0
//	|	END AS RepairEndCleaningCount,
//	|	CASE 
//	|		WHEN TaskTurnoversYYYYMMDD.VacantRoomCleaning IS NOT NULL
//	|			THEN 1
//	|		ELSE 0
//	|	END AS VacantRoomCleaningCount,
//	|	CASE 
//	|		WHEN TaskTurnoversYYYYMMDD.RegularOperation IS NOT NULL
//	|			THEN 1
//	|		ELSE 0
//	|	END AS RegularOperationCount
//	|FROM
//	|	(SELECT
//	|		RoomInventoryBalanceYYYYMMDD.Гостиница AS Гостиница,
//	|		RoomInventoryBalanceYYYYMMDD.НомерРазмещения AS НомерРазмещения,
//	|		RoomInventoryBalanceYYYYMMDD.ТипНомера AS ТипНомера,
//	|		RoomInventoryBalanceYYYYMMDD.TotalRoomsBalance AS TotalRoomsBalance,
//	|		RoomInventoryBalanceYYYYMMDD.TotalBedsBalance AS TotalBedsBalance,
//	|		InHousePersonsYYYYMMDD.Recorder AS InHouseAccommodation,
//	|		InHousePersonsYYYYMMDD.Клиент AS InHouseGuest,
//	|		InHousePersonsYYYYMMDD.CheckInDate AS InHouseCheckInDate,
//	|		InHousePersonsYYYYMMDD.CheckOutDate AS InHouseCheckOutDate,
//	|		CASE
//	|			WHEN (NOT InHousePersonsYYYYMMDD.Recorder IS NULL )
//	|					AND CheckedOutGuestsYYYYMMDD.Recorder IS NULL 
//	|				THEN &qRegularCleaning
//	|			ELSE NULL
//	|		END AS RegularCleaning,
//	|		CASE
//	|			WHEN (NOT InHousePersonsYYYYMMDD.Recorder IS NULL )
//	|					AND CheckedOutGuestsYYYYMMDD.Recorder IS NULL 
//	|				THEN &qRegularCleaningCode
//	|			ELSE NULL
//	|		END AS RegularCleaningCode,
//	|		CASE
//	|			WHEN (NOT InHousePersonsYYYYMMDD.Recorder IS NULL )
//	|					AND CheckedOutGuestsYYYYMMDD.Recorder IS NULL 
//	|				THEN &qRegularCleaningSortCode
//	|			ELSE NULL
//	|		END AS RegularCleaningSortCode,
//	|		CheckedOutGuestsYYYYMMDD.Recorder AS CheckOutAccommodation,
//	|		CheckedOutGuestsYYYYMMDD.Клиент AS CheckOutGuest,
//	|		CheckedOutGuestsYYYYMMDD.CheckInDate AS CheckOutCheckInDate,
//	|		CheckedOutGuestsYYYYMMDD.CheckOutDate AS CheckOutCheckOutDate,
//	|		CASE
//	|			WHEN (NOT CheckedOutGuestsYYYYMMDD.Recorder IS NULL )
//	|				THEN &qCheckOutCleaning
//	|			ELSE NULL
//	|		END AS CheckOutCleaning,
//	|		CASE
//	|			WHEN (NOT CheckedOutGuestsYYYYMMDD.Recorder IS NULL )
//	|				THEN &qCheckOutCleaningCode
//	|			ELSE NULL
//	|		END AS CheckOutCleaningCode,
//	|		CASE
//	|			WHEN (NOT CheckedOutGuestsYYYYMMDD.Recorder IS NULL )
//	|				THEN &qCheckOutCleaningSortCode
//	|			ELSE NULL
//	|		END AS CheckOutCleaningSortCode,
//	|		RoomBlocksYYYYMMDD.Recorder AS БлокНомер,
//	|		RoomBlocksYYYYMMDD.RoomBlockType AS RoomBlockType,
//	|		SUBSTRING(RoomBlocksYYYYMMDD.Примечания, 1, 999) AS RoomBlockRemarks,
//	|		RoomBlocksYYYYMMDD.CheckInDate AS RoomBlockStartDate,
//	|		RoomBlocksYYYYMMDD.CheckOutDate AS RoomBlockEndDate,
//	|		CASE
//	|			WHEN (NOT RoomBlocksYYYYMMDD.Recorder IS NULL )
//	|				THEN &qRepairEndCleaning
//	|			ELSE NULL
//	|		END AS RepairEndCleaning,
//	|		CASE
//	|			WHEN (NOT RoomBlocksYYYYMMDD.Recorder IS NULL )
//	|				THEN &qRepairEndCleaningCode
//	|			ELSE NULL
//	|		END AS RepairEndCleaningCode,
//	|		CASE
//	|			WHEN (NOT RoomBlocksYYYYMMDD.Recorder IS NULL )
//	|				THEN &qRepairEndCleaningSortCode
//	|			ELSE NULL
//	|		END AS RepairEndCleaningSortCode,
//	|		CASE
//	|			WHEN CheckedOutGuestsYYYYMMDD.Recorder IS NULL 
//	|					AND InHousePersonsYYYYMMDD.Recorder IS NULL 
//	|					AND CheckedInPersonsYYYYMMDD.Recorder IS NULL 
//	|				THEN &qVacantRoomCleaning
//	|			ELSE NULL
//	|		END AS VacantRoomCleaning,
//	|		CASE
//	|			WHEN CheckedOutGuestsYYYYMMDD.Recorder IS NULL 
//	|					AND InHousePersonsYYYYMMDD.Recorder IS NULL 
//	|					AND CheckedInPersonsYYYYMMDD.Recorder IS NULL 
//	|				THEN &qVacantRoomCleaningCode
//	|			ELSE NULL
//	|		END AS VacantRoomCleaningCode,
//	|		CASE
//	|			WHEN CheckedOutGuestsYYYYMMDD.Recorder IS NULL 
//	|					AND InHousePersonsYYYYMMDD.Recorder IS NULL 
//	|					AND CheckedInPersonsYYYYMMDD.Recorder IS NULL 
//	|				THEN &qVacantRoomCleaningSortCode
//	|			ELSE NULL
//	|		END AS VacantRoomCleaningSortCode,
//	|		RegularOperationsYYYYMMDD.RegularOperation AS RegularOperation,
//	|		CASE
//	|			WHEN RegularOperationsYYYYMMDD.RegularOperation IS NOT NULL 
//	|				THEN RegularOperationsYYYYMMDD.RegularOperation.Code
//	|			ELSE NULL
//	|		END AS RegularOperationCode,
//	|		CASE
//	|			WHEN RegularOperationsYYYYMMDD.RegularOperation IS NOT NULL 
//	|				THEN RegularOperationsYYYYMMDD.RegularOperation.ПорядокСортировки
//	|			ELSE NULL
//	|		END AS RegularOperationSortCode,
//	|		CheckedInPersonsYYYYMMDD.Recorder AS CheckInAccommodation,
//	|		CheckedInPersonsYYYYMMDD.Клиент AS CheckInGuest,
//	|		CheckedInPersonsYYYYMMDD.Recorder.CheckInDate AS CheckInCheckInDate,
//	|		CheckedInPersonsYYYYMMDD.Recorder.CheckOutDate AS CheckInCheckOutDate
//	|	FROM
//	|		AccumulationRegister.ЗагрузкаНомеров.Balance(
//	|				&qPeriodToDDMMYYYY,
//	|				(Гостиница IN HIERARCHY (&qHotel)
//	|					OR &qIsEmptyHotel)
//	|					AND (НомерРазмещения IN HIERARCHY (&qRoom)
//	|						OR &qIsEmptyRoom)) AS RoomInventoryBalanceYYYYMMDD
//	|			LEFT JOIN AccumulationRegister.ЗагрузкаНомеров AS InHousePersonsYYYYMMDD
//	|			ON RoomInventoryBalanceYYYYMMDD.НомерРазмещения = InHousePersonsYYYYMMDD.НомерРазмещения
//	|				AND (InHousePersonsYYYYMMDD.RecordType = &qExpense)
//	|				AND (InHousePersonsYYYYMMDD.ЭтоГости)
//	|				AND (InHousePersonsYYYYMMDD.CheckInDate < &qPeriodFromDDMMYYYY)
//	|				AND (InHousePersonsYYYYMMDD.CheckOutDate > &qPeriodToDDMMYYYY)
//	|			LEFT JOIN AccumulationRegister.ЗагрузкаНомеров AS CheckedOutGuestsYYYYMMDD
//	|			ON RoomInventoryBalanceYYYYMMDD.НомерРазмещения = CheckedOutGuestsYYYYMMDD.НомерРазмещения
//	|				AND (CheckedOutGuestsYYYYMMDD.RecordType = &qReceipt)
//	|				AND (CheckedOutGuestsYYYYMMDD.ЭтоВыезд)
//	|				AND (CheckedOutGuestsYYYYMMDD.CheckOutDate > &qPeriodFromDDMMYYYY)
//	|				AND (CheckedOutGuestsYYYYMMDD.CheckOutDate <= &qPeriodToDDMMYYYY)
//	|			LEFT JOIN AccumulationRegister.ЗагрузкаНомеров AS RoomBlocksYYYYMMDD
//	|			ON RoomInventoryBalanceYYYYMMDD.НомерРазмещения = RoomBlocksYYYYMMDD.НомерРазмещения
//	|				AND (RoomBlocksYYYYMMDD.RecordType = &qExpense)
//	|				AND (RoomBlocksYYYYMMDD.IsBlocking)
//	|				AND (RoomBlocksYYYYMMDD.CheckOutDate > &qPeriodFromDDMMYYYY)
//	|				AND (RoomBlocksYYYYMMDD.CheckOutDate <= &qPeriodToDDMMYYYY)
//	|				AND (RoomBlocksYYYYMMDD.RoomBlockType.IsRoomRepair)
//	|			LEFT JOIN AccumulationRegister.ЗагрузкаНомеров AS CheckedInPersonsYYYYMMDD
//	|			ON RoomInventoryBalanceYYYYMMDD.НомерРазмещения = CheckedInPersonsYYYYMMDD.НомерРазмещения
//	|				AND (CheckedInPersonsYYYYMMDD.RecordType = &qExpense)
//	|				AND (CheckedInPersonsYYYYMMDD.ЭтоГости)
//	|				AND (CheckedInPersonsYYYYMMDD.CheckInDate >= &qPeriodFromDDMMYYYY)
//	|				AND (CheckedInPersonsYYYYMMDD.CheckInDate < &qPeriodToDDMMYYYY)
//	|			LEFT JOIN Catalog.НаборРегламентныхРабот.RegularOperations AS RegularOperationsYYYYMMDD
//	|			ON (RegularOperationsYYYYMMDD.Ref = &qRegularOperationGroup)
//	|				AND (RegularOperationsYYYYMMDD.PerformWhenRoomIsBusy
//	|						AND DATEDIFF(&qPeriodFromDDMMYYYY, BEGINOFPERIOD(InHousePersonsYYYYMMDD.CheckInDate, DAY), DAY) / RegularOperationsYYYYMMDD.RegularOperationFrequency = (CAST(DATEDIFF(&qPeriodFromDDMMYYYY, BEGINOFPERIOD(InHousePersonsYYYYMMDD.CheckInDate, DAY), DAY) / RegularOperationsYYYYMMDD.RegularOperationFrequency AS NUMBER(17, 0)))
//	|						AND DATEDIFF(&qPeriodFromDDMMYYYY, BEGINOFPERIOD(InHousePersonsYYYYMMDD.CheckInDate, DAY), DAY) <> 0
//	|					OR RegularOperationsYYYYMMDD.PerformWhenRoomIsBusy
//	|						AND RegularOperationsYYYYMMDD.PerformOnCheckInDay
//	|						AND CheckedInPersonsYYYYMMDD.Recorder IS NOT NULL 
//	|					OR RegularOperationsYYYYMMDD.PerformWhenRoomIsBusy
//	|						AND RegularOperationsYYYYMMDD.PerformOnCheckOutDay
//	|						AND CheckedOutGuestsYYYYMMDD.Recorder IS NOT NULL 
//	|					OR RegularOperationsYYYYMMDD.PerformWhenRoomIsFree
//	|						AND InHousePersonsYYYYMMDD.Recorder IS NULL 
//	|						AND CheckedInPersonsYYYYMMDD.Recorder IS NULL 
//	|						AND CheckedOutGuestsYYYYMMDD.Recorder IS NULL )
//	|				AND ((NOT RegularOperationsYYYYMMDD.DoNotPerformOnWeekends)
//	|					OR RegularOperationsYYYYMMDD.DoNotPerformOnWeekends
//	|						AND WEEKDAY(&qPeriodFromDDMMYYYY) < 6)
//	|				AND (RegularOperationsYYYYMMDD.ТипНомера = &qEmptyRoomType
//	|					OR RegularOperationsYYYYMMDD.ТипНомера <> &qEmptyRoomType
//	|						AND RoomInventoryBalanceYYYYMMDD.ТипНомера = RegularOperationsYYYYMMDD.ТипНомера
//	|					OR RegularOperationsYYYYMMDD.ТипНомера <> &qEmptyRoomType
//	|						AND RoomInventoryBalanceYYYYMMDD.ТипНомера.Parent <> &qEmptyRoomType
//	|						AND RoomInventoryBalanceYYYYMMDD.ТипНомера.Parent = RegularOperationsYYYYMMDD.ТипНомера)
//	|	WHERE
//	|		RoomInventoryBalanceYYYYMMDD.TotalRoomsBalance > 0) AS TaskTurnoversYYYYMMDD ";
//	
//	QueryTail = 
//	") AS TaskTurnovers
//	|GROUP BY
//	|	TaskTurnovers.Гостиница,
//	|	TaskTurnovers.НомерРазмещения,
//	|	TaskTurnovers.ТипНомера,
//	|	TaskTurnovers.Клиент,
//	|	TaskTurnovers.RoomBlockType,
//	|	TaskTurnovers.Гражданство,
//	|	TaskTurnovers.CheckInDate,
//	|	TaskTurnovers.CheckOutDate,
//	|	TaskTurnovers.CheckOutCleaning,
//	|	TaskTurnovers.RegularCleaning,
//	|	TaskTurnovers.RepairEndCleaning,
//	|	TaskTurnovers.VacantRoomCleaning,
//	|	TaskTurnovers.RegularOperation,
//	|	TaskTurnovers.CheckOutCleaningCode,
//	|	TaskTurnovers.RegularCleaningCode,
//	|	TaskTurnovers.RepairEndCleaningCode,
//	|	TaskTurnovers.VacantRoomCleaningCode,
//	|	TaskTurnovers.RegularOperationCode,
//	|	TaskTurnovers.CheckOutCleaningSortCode,
//	|	TaskTurnovers.RegularCleaningSortCode,
//	|	TaskTurnovers.RepairEndCleaningSortCode,
//	|	TaskTurnovers.VacantRoomCleaningSortCode,
//	|	TaskTurnovers.RegularOperationSortCode
//	|HAVING
//	|	SUM(TaskTurnovers.CheckOutCleaningCount) > 0
//	|	OR SUM(TaskTurnovers.RegularCleaningCount) > 0
//	|	OR SUM(TaskTurnovers.RepairEndCleaningCount) > 0
//	|	OR SUM(TaskTurnovers.VacantRoomCleaningCount) > 0
//	|	OR SUM(TaskTurnovers.RegularOperationCount) > 0
//	|{WHERE
//	|	TaskTurnovers.Гостиница.*,
//	|	TaskTurnovers.НомерРазмещения.*,
//	|	TaskTurnovers.ТипНомера.*,
//	|	TaskTurnovers.RoomBlockType.*,
//	|	TaskTurnovers.Клиент.*,
//	|	TaskTurnovers.CheckInDate,
//	|	TaskTurnovers.CheckOutDate,
//	|	TaskTurnovers.CheckOutCleaning.*,
//	|	TaskTurnovers.RegularCleaning.*,
//	|	TaskTurnovers.RepairEndCleaning.*,
//	|	TaskTurnovers.VacantRoomCleaning.*,
//	|	TaskTurnovers.RegularOperation.*}
//	|{ORDER BY
//	|	Гостиница.* AS Гостиница,
//	|	НомерРазмещения.* AS НомерРазмещения,
//	|	ТипНомера.* AS ТипНомера,
//	|	Клиент.* AS Клиент,
//	|	RoomBlockType.* AS RoomBlockType,
//	|	Гражданство.* AS Гражданство,
//	|	CheckInDate AS CheckInDate,
//	|	CheckOutDate AS CheckOutDate,
//	|	CheckOutCleaning.* AS CheckOutCleaning,
//	|	RegularCleaning.* AS RegularCleaning,
//	|	RepairEndCleaning.* AS RepairEndCleaning,
//	|	VacantRoomCleaning.* AS VacantRoomCleaning,
//	|	RegularOperation.* AS RegularOperation,
//	|	CheckOutCleaningCode AS CheckOutCleaningCode,
//	|	RegularCleaningCode AS RegularCleaningCode,
//	|	RepairEndCleaningCode AS RepairEndCleaningCode,
//	|	VacantRoomCleaningCode AS VacantRoomCleaningCode,
//	|	RegularOperationCode AS RegularOperationCode,
//	|	CheckOutCleaningSortCode AS CheckOutCleaningSortCode,
//	|	RegularCleaningSortCode AS RegularCleaningSortCode,
//	|	RepairEndCleaningSortCode AS RepairEndCleaningSortCode,
//	|	VacantRoomCleaningSortCode AS VacantRoomCleaningSortCode,
//	|	RegularOperationSortCode AS RegularOperationSortCode}
//	|TOTALS 
//	|	SUM(CheckOutCleaningCount),
//	|	SUM(RegularCleaningCount),
//	|	SUM(RepairEndCleaningCount),
//	|	SUM(VacantRoomCleaningCount),
//	|	SUM(RegularOperationCount)
//	|BY
//	|	OVERALL,
//	|	Гостиница,
//	|	ТипНомера
//	|{TOTALS BY
//	|	Гостиница.* AS Гостиница,
//	|	НомерРазмещения.* AS НомерРазмещения,
//	|	ТипНомера.* AS ТипНомера,
//	|	RoomBlockType.* AS RoomBlockType,
//	|	Гражданство.* AS Гражданство,
//	|	CheckOutCleaning.* AS CheckOutCleaning,
//	|	RegularCleaning.* AS RegularCleaning,
//	|	RepairEndCleaning.* AS RepairEndCleaning,
//	|	VacantRoomCleaning.* AS VacantRoomCleaning,
//	|	RegularOperation.* AS RegularOperation}";
//	
//	QueryText = QuerySelect + QueryYYYYMMDDSelect + QueryTail;
//	ReportBuilder.Text = QueryText;
//	ReportBuilder.FillSettings();
//	
//	// Initialize report builder with default query
//	vRB = New ReportBuilder(QueryText);
//	vRBSettings = vRB.GetSettings(True, True, True, True, True);
//	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
//	
//	// Set default report builder header text
//	ReportBuilder.HeaderText = NStr("en='Employee ГруппаНомеров operation tasks turnovers';ru='Обороты по заданиям на выполнение работ в номерах';de='Umsätze nach Aufgaben und Erbringen von Arbeit in den Zimmern'");
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
