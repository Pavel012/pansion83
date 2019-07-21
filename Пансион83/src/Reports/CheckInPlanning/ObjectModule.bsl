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
//		PeriodFrom = BegOfDay(CurrentDate());
//		PeriodTo = EndOfDay(PeriodFrom) + 90*24*3600;
//	EndIf;
//	If PeriodOfStay = 0 Тогда
//		PeriodOfStay = 1;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(DurationCalculationRuleType) Тогда
//		DurationCalculationRuleType = Перечисления.DurationCalculationRuleTypes.ByReferenceHour;
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
//	If PeriodOfStay > 0 Тогда
//		vParamPresentation = vParamPresentation + NStr("ru = 'Продолжительность проживания '; en = 'Period of stay duration '") + 
//							 Format(PeriodOfStay, "ND=10; NFD=0; NG=") + 
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
//	// Run main query to get data
//	vQry = New Query();
//	vQry.Text = TrimAll(QueryText);
//	vQry.SetParameter("qHotel", Гостиница);
//	vQry.SetParameter("qIsEmptyHotel", НЕ ЗначениеЗаполнено(Гостиница));
//	vQry.SetParameter("qPeriodFrom", PeriodFrom);
//	vQry.SetParameter("qPeriodTo", PeriodTo);
//	vQry.SetParameter("qRoom", ГруппаНомеров);
//	vQry.SetParameter("qIsEmptyRoom", НЕ ЗначениеЗаполнено(ГруппаНомеров));
//	vQry.SetParameter("qRoomType", RoomType);
//	vQry.SetParameter("qIsEmptyRoomType", НЕ ЗначениеЗаполнено(RoomType));
//	vVacants = vQry.Execute().Unload();
//	
//	// Initialize results table
//	vResults = vVacants.CopyColumns("Гостиница, ТипНомера, RoomsVacant, BedsVacant, RoomsAvailable, BedsAvailable");
//	vResults.Columns.Add("CheckInDate", cmGetDateTimeTypeDescription());
//	vResults.Columns.Add("Продолжительность", cmGetNumberTypeDescription(10, 0));
//	vResults.Columns.Add("CheckOutDate", cmGetDateTimeTypeDescription());
//	
//	// Check period of stay duration
//	PeriodOfStay = ?(PeriodOfStay > 0, PeriodOfStay, 1);
//	
//	// Check duration calculation rule
//	If НЕ ЗначениеЗаполнено(DurationCalculationRuleType) Тогда
//		DurationCalculationRuleType = Перечисления.DurationCalculationRuleTypes.ByReferenceHour;
//	EndIf;
//	
//	// Check minimum vacant ГруппаНомеров balances for the each possible check-in period
//	vCurCheckInDate = BegOfDay(PeriodFrom);
//	If DurationCalculationRuleType = Перечисления.DurationCalculationRuleTypes.ByDays Тогда
//		vCurCheckOutDate = vCurCheckInDate + (PeriodOfStay-1)*24*3600;
//	Else
//		vCurCheckOutDate = vCurCheckInDate + PeriodOfStay*24*3600;
//	EndIf;
//	While vCurCheckOutDate <= BegOfDay(PeriodTo) Do
//		// Calculate minimum vacant rooms/beds balances for the current period
//		For Each vVacantsRow In vVacants Do
//			If НЕ ЗначениеЗаполнено(vVacantsRow.Period) Or НЕ ЗначениеЗаполнено(vVacantsRow.Гостиница) Тогда
//				Continue;
//			EndIf;
//			If vVacantsRow.Period >= vCurCheckInDate And vVacantsRow.Period < vCurCheckOutDate Тогда
//				// Try to find results row for the given hotel, ГруппаНомеров type and day
//				vResultsRows = vResults.FindRows(New Structure("Гостиница, ТипНомера, CheckInDate", vVacantsRow.Гостиница, vVacantsRow.RoomType, vCurCheckInDate));
//				vResultsRow = Неопределено;
//				If vResultsRows.Count() > 0 Тогда
//					vResultsRow = vResultsRows.Get(0);
//					vResultsRow.RoomsVacant = Min(vResultsRow.RoomsVacant, vVacantsRow.RoomsVacant);
//					vResultsRow.BedsVacant = Min(vResultsRow.BedsVacant, vVacantsRow.BedsVacant);
//					vResultsRow.RoomsAvailable = Min(vResultsRow.RoomsAvailable, vVacantsRow.RoomsAvailable);
//					vResultsRow.BedsAvailable = Min(vResultsRow.BedsAvailable, vVacantsRow.BedsAvailable);
//				Else
//					vResultsRow = vResults.Add();
//					vResultsRow.Гостиница = vVacantsRow.Гостиница;
//					vResultsRow.ТипНомера = vVacantsRow.RoomType;
//					vResultsRow.CheckInDate = vCurCheckInDate;
//					vResultsRow.CheckOutDate = vCurCheckOutDate;
//					vResultsRow.Продолжительность = PeriodOfStay;
//					vResultsRow.RoomsVacant = vVacantsRow.RoomsVacant;
//					vResultsRow.BedsVacant = vVacantsRow.BedsVacant;
//					vResultsRow.RoomsAvailable = vVacantsRow.RoomsAvailable;
//					vResultsRow.BedsAvailable = vVacantsRow.BedsAvailable;
//				EndIf;
//			EndIf;
//		EndDo;
//		
//		// Subtract check-in period vacant rooms/beds from the vacants value table
//		vResultsRows = vResults.FindRows(New Structure("CheckInDate", vCurCheckInDate));
//		For Each vResultsRow In vResultsRows Do
//			vVacantsRows = vVacants.FindRows(New Structure("Гостиница, ТипНомера", vResultsRow.Гостиница, vResultsRow.ТипНомера));
//			For Each vVacantsRow In vVacantsRows Do
//				If НЕ ЗначениеЗаполнено(vVacantsRow.Period) Or НЕ ЗначениеЗаполнено(vVacantsRow.Гостиница) Тогда
//					Continue;
//				EndIf;
//				If vVacantsRow.Period >= vResultsRow.CheckInDate And 
//				   vVacantsRow.Period < vResultsRow.CheckOutDate Тогда
//					If vResultsRow.RoomsVacant > 0 Тогда
//						vVacantsRow.RoomsVacant = vVacantsRow.RoomsVacant - vResultsRow.RoomsVacant;
//					EndIf;
//					If vResultsRow.BedsVacant > 0 Тогда
//						vVacantsRow.BedsVacant = vVacantsRow.BedsVacant - vResultsRow.BedsVacant;
//					EndIf;
//				EndIf;
//			EndDo;
//		EndDo;
//		
//		// Go to the next day
//		vCurCheckInDate = vCurCheckInDate + 24*3600;
//		If DurationCalculationRuleType = Перечисления.DurationCalculationRuleTypes.ByDays Тогда
//			vCurCheckOutDate = vCurCheckInDate + (PeriodOfStay-1)*24*3600;
//		Else
//			vCurCheckOutDate = vCurCheckInDate + PeriodOfStay*24*3600;
//		EndIf;
//	EndDo;
//		
//	// Delete rows with negative or zero balances from the results value table
//	i = 0;
//	While i < vResults.Count() Do
//		vResultsRow = vResults.Get(i);
//		If vResultsRow.RoomsVacant <= 0 And vResultsRow.BedsVacant <= 0 Тогда
//			vResults.Delete(i);
//		Else
//			i = i + 1;
//		EndIf;
//	EndDo;
//	
//	// Add totals row
//	vTotalsRow = vResults.Add();
//	vTotalsRow.RoomsVacant = vResults.Total("RoomsVacant");
//	vTotalsRow.BedsVacant = vResults.Total("BedsVacant");
//
//	// Save current report builder settings
//	vCurReportBuilderSettings = ReportBuilder.GetSettings(True, True, True, True, True);
//	
//	// Set resulting table as data source for the report builder
//	ReportBuilder.DataSource = New DataSourceDescription(vResults);
//	
//	// Fill report builder fields presentations from the report template
//	cmFillReportAttributesPresentations(ThisObject);
//	
//	// Apply current report builder settings
//	ReportBuilder.SetSettings(vCurReportBuilderSettings);
//	
//	// Execute report builder
//	ReportBuilder.Execute();
//	
//	//// Apply appearance settings to the report template
//	//vTemplateAttributes = cmApplyReportTemplateAppearance(ThisObject);
//	
//	// Output report to the spreadsheet
//	ReportBuilder.Put(pSpreadsheet);
//	//ReportBuilder.Template.Show(); // For debug purpose
//
//	// Add totals caption and appearance to the last report row
//	vLastRepRow = pSpreadsheet.Area(pSpreadsheet.TableHeight-2, 2, pSpreadsheet.TableHeight-2, pSpreadsheet.TableWidth);
//	vLastRepRow.Font = New Font(pSpreadsheet.Area(pSpreadsheet.TableHeight-2, 2, pSpreadsheet.TableHeight-2, 2).Font, , , True);
//	vLastRepRow.BackColor = pSpreadsheet.Area(4, 2, 4, 2).BackColor;
//	pSpreadsheet.Area(pSpreadsheet.TableHeight-2, 2, pSpreadsheet.TableHeight-2, 2).Text = NStr("en='Totals';ru='Итог';de='Ergebnis'");
//	
//	//// Apply appearance settings to the report spreadsheet
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
//	|	RoomInventoryBalance.Period AS Period,
//	|	RoomInventoryBalance.Гостиница AS Гостиница,
//	|	RoomInventoryBalance.ТипНомера AS ТипНомера,
//	|	RoomInventoryBalance.RoomsVacantClosingBalance AS RoomsVacant,
//	|	RoomInventoryBalance.BedsVacantClosingBalance AS BedsVacant,
//	|	RoomInventoryBalance.TotalRoomsClosingBalance + RoomInventoryBalance.RoomsBlockedClosingBalance AS RoomsAvailable,
//	|	RoomInventoryBalance.TotalBedsClosingBalance + RoomInventoryBalance.BedsBlockedClosingBalance AS BedsAvailable,
//	|	RoomInventoryBalance.Гостиница.ПорядокСортировки AS HotelSortCode,
//	|	RoomInventoryBalance.ТипНомера.ПорядокСортировки AS RoomTypeSortCode
//	|{SELECT
//	|	Period,
//	|	RoomInventoryBalance.Period AS CheckInDate,
//	|	(0) AS Продолжительность,
//	|	RoomInventoryBalance.Period AS CheckOutDate,
//	|	Гостиница.*,
//	|	ТипНомера.*,
//	|	RoomsVacant,
//	|	BedsVacant,
//	|	RoomsAvailable,
//	|	BedsAvailable}
//	|FROM
//	|	AccumulationRegister.ЗагрузкаНомеров.BalanceAndTurnovers(
//	|			&qPeriodFrom,
//	|			&qPeriodTo,
//	|			Day,
//	|			RegisterRecordsAndPeriodBoundaries,
//	|			(Гостиница IN HIERARCHY (&qHotel)
//	|				OR &qIsEmptyHotel)
//	|				AND (НомерРазмещения IN HIERARCHY (&qRoom)
//	|					OR &qIsEmptyRoom)
//	|				AND (ТипНомера IN HIERARCHY (&qRoomType)
//	|					OR &qIsEmptyRoomType)) AS RoomInventoryBalance
//	|{WHERE
//	|	RoomInventoryBalance.Period,
//	|	RoomInventoryBalance.Period AS CheckInDate,
//	|	(0) AS Продолжительность,
//	|	RoomInventoryBalance.Period AS CheckOutDate,
//	|	RoomInventoryBalance.Гостиница.*,
//	|	RoomInventoryBalance.ТипНомера.*,
//	|	RoomInventoryBalance.RoomsVacantClosingBalance AS RoomsVacant,
//	|	RoomInventoryBalance.BedsVacantClosingBalance AS BedsVacant,
//	|	(RoomInventoryBalance.TotalRoomsClosingBalance + RoomInventoryBalance.RoomsBlockedClosingBalance) AS RoomsAvailable,
//	|	(RoomInventoryBalance.TotalBedsClosingBalance + RoomInventoryBalance.BedsBlockedClosingBalance) AS BedsAvailable}
//	|
//	|ORDER BY
//	|	HotelSortCode,
//	|	RoomTypeSortCode,
//	|	Period
//	|{ORDER BY
//	|	Period,
//	|	RoomInventoryBalance.Period AS CheckInDate,
//	|	(0) AS Продолжительность,
//	|	RoomInventoryBalance.Period AS CheckOutDate,
//	|	Гостиница.*,
//	|	ТипНомера.*,
//	|	RoomsVacant,
//	|	BedsVacant,
//	|	RoomsAvailable,
//	|	BedsAvailable}
//	|TOTALS
//	|	SUM(RoomsVacant),
//	|	SUM(BedsVacant),
//	|	SUM(RoomsAvailable),
//	|	SUM(BedsAvailable)
//	|BY
//	|	Гостиница HIERARCHY,
//	|	ТипНомера HIERARCHY,
//	|	Period PERIODS(DAY, &qPeriodFrom, &qPeriodTo)";
//	ReportBuilder.Text = QueryText;
//	ReportBuilder.FillSettings();
//	
//	// Initialize report builder with default query
//	vRB = New ReportBuilder(QueryText);
//	vRBSettings = vRB.GetSettings(True, True, True, True, True);
//	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
//	
//	// Set default report builder header text
//	ReportBuilder.HeaderText = NStr("EN='Check-in planning';RU='Планирование заездов';de='Planung der Anreisen'");
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
