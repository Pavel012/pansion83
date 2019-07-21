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
//		PeriodFrom = BegOfMonth(CurrentDate()); // For beg of month
//		PeriodTo = EndOfDay(CurrentDate());
//	EndIf;
//	If НЕ ЗначениеЗаполнено(Periodicity) Тогда
//		Periodicity = Перечисления.PeriodicityTypes.Day;
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
//	If ЗначениеЗаполнено(Service) Тогда
//		If НЕ Service.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("en='Service ';ru='Услуга ';de='Dienstleistung'") + 
//								 TrimAll(Service.Description) + 
//								 ";" + Chars.LF;
//		 Else
//			vParamPresentation = vParamPresentation + NStr("ru = 'Группа услуг '; en = 'Services folder '") + 
//								 TrimAll(Service.Description) + 
//								 ";" + Chars.LF;
//		 EndIf;							 
//	EndIf;							 
//	If ЗначениеЗаполнено(ServiceGroup) Тогда
//		If НЕ ServiceGroup.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("ru = 'Набор услуг '; en = 'Service group '") + 
//			                     TrimAll(ServiceGroup.Description) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("ru = 'Группа наборов услуг '; en = 'Service groups folder '") + 
//			                     TrimAll(ServiceGroup.Description) + 
//			                     ";" + Chars.LF;
//		EndIf;
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
//	// Run query to get available rooms
//	vQry = New Query();
//	vQry.Text = 
//	"SELECT
//	|	TotalRoomInventoryBalanceAndTurnovers.Period AS Period,
//	|	SUM(TotalRoomInventoryBalanceAndTurnovers.CounterClosingBalance) AS CounterClosingBalance,
//	|	SUM(TotalRoomInventoryBalanceAndTurnovers.TotalRoomsClosingBalance) AS ВсегоНомеров,
//	|	SUM(TotalRoomInventoryBalanceAndTurnovers.TotalBedsClosingBalance) AS ВсегоМест,
//	|	-SUM(TotalRoomInventoryBalanceAndTurnovers.RoomsBlockedClosingBalance) AS TotalRoomsBlocked,
//	|	-SUM(TotalRoomInventoryBalanceAndTurnovers.BedsBlockedClosingBalance) AS TotalBedsBlocked,
//	|	SUM(TotalRoomInventoryBalanceAndTurnovers.GuestsReservedReceipt) AS TotalGuestsReservedReceipt,
//	|	SUM(TotalRoomInventoryBalanceAndTurnovers.GuestsReservedExpense) AS TotalGuestsReservedExpense,
//	|	SUM(TotalRoomInventoryBalanceAndTurnovers.InHouseGuestsReceipt) AS TotalInHouseGuestsReceipt,
//	|	SUM(TotalRoomInventoryBalanceAndTurnovers.InHouseGuestsExpense) AS TotalInHouseGuestsExpense
//	|FROM
//	|	AccumulationRegister.ЗагрузкаНомеров.BalanceAndTurnovers(
//	|			&qPeriodFrom,
//	|			&qPeriodTo,
//	|			Day,
//	|			RegisterRecordsAndPeriodBoundaries,
//	|			Гостиница IN HIERARCHY (&qHotel)
//	|				AND (НомерРазмещения IN HIERARCHY (&qRoom)
//	|					OR &qIsEmptyRoom)
//	|				AND (ТипНомера IN HIERARCHY (&qRoomType)
//	|					OR &qIsEmptyRoomType)) AS TotalRoomInventoryBalanceAndTurnovers
//	|
//	|GROUP BY
//	|	TotalRoomInventoryBalanceAndTurnovers.Period
//	|
//	|ORDER BY
//	|	Period";
//	vQry.SetParameter("qHotel", Гостиница);
//	vQry.SetParameter("qPeriodFrom", PeriodFrom);
//	vQry.SetParameter("qPeriodTo", PeriodTo);
//	vQry.SetParameter("qRoom", ГруппаНомеров);
//	vQry.SetParameter("qIsEmptyRoom", НЕ ЗначениеЗаполнено(ГруппаНомеров));
//	vQry.SetParameter("qRoomType", RoomType);
//	vQry.SetParameter("qIsEmptyRoomType", НЕ ЗначениеЗаполнено(RoomType));
//	vTotals = vQry.Execute().Unload();
//	
//	AddMissingPeriods(vTotals);
//	
//	// Run query to get total ГруппаНомеров blocks that should be added to the number of total rooms rented
//	vQry = New Query();
//	vQry.Text = 
//	"SELECT
//	|	RoomBlocksBalanceAndTurnovers.Period AS Period,
//	|	SUM(RoomBlocksBalanceAndTurnovers.RoomsBlockedClosingBalance) AS SpecRoomsBlocked,
//	|	SUM(RoomBlocksBalanceAndTurnovers.BedsBlockedClosingBalance) AS SpecBedsBlocked
//	|FROM
//	|	AccumulationRegister.БлокирНомеров.BalanceAndTurnovers(
//	|			&qPeriodFrom,
//	|			&qPeriodTo,
//	|			Day,
//	|			RegisterRecordsAndPeriodBoundaries,
//	|			Гостиница IN HIERARCHY (&qHotel)
//	|				AND (НомерРазмещения IN HIERARCHY (&qRoom)
//	|					OR &qIsEmptyRoom)
//	|				AND (ТипНомера IN HIERARCHY (&qRoomType)
//	|					OR &qIsEmptyRoomType)
//	|				AND RoomBlockType.AddToRoomsRentedInSummaryIndexes) AS RoomBlocksBalanceAndTurnovers
//	|
//	|GROUP BY
//	|	RoomBlocksBalanceAndTurnovers.Period
//	|
//	|ORDER BY
//	|	Period";
//	vQry.SetParameter("qHotel", Гостиница);
//	vQry.SetParameter("qPeriodFrom", PeriodFrom);
//	vQry.SetParameter("qPeriodTo", PeriodTo);
//	vQry.SetParameter("qRoom", ГруппаНомеров);
//	vQry.SetParameter("qIsEmptyRoom", НЕ ЗначениеЗаполнено(ГруппаНомеров));
//	vQry.SetParameter("qRoomType", RoomType);
//	vQry.SetParameter("qIsEmptyRoomType", НЕ ЗначениеЗаполнено(RoomType));
//	vTotalSpecBlocks = vQry.Execute().Unload();
//	
//	AddMissingPeriods(vTotalSpecBlocks);
//	
//	// Run main query to get data
//	vQry = New Query();
//	vQry.Text = TrimAll(StrReplace(QueryText, "Day,", GetPeriodicityPresentation()));
//	vQry.SetParameter("qHotel", Гостиница);
//	vQry.SetParameter("qPeriodFrom", PeriodFrom);
//	vQry.SetParameter("qForecastPeriodFrom", Max(BegOfDay(PeriodFrom), BegOfDay(CurrentDate())));
//	vQry.SetParameter("qPeriodTo", PeriodTo);
//	vQry.SetParameter("qForecastPeriodTo", Max(PeriodTo, EndOfDay(CurrentDate()-24*3600)));
//	vQry.SetParameter("qRoom", ГруппаНомеров);
//	vQry.SetParameter("qIsEmptyRoom", НЕ ЗначениеЗаполнено(ГруппаНомеров));
//	vQry.SetParameter("qRoomType", RoomType);
//	vQry.SetParameter("qIsEmptyRoomType", НЕ ЗначениеЗаполнено(RoomType));
//	vQry.SetParameter("qService", Service);
//	vQry.SetParameter("qIsEmptyService", НЕ ЗначениеЗаполнено(Service));
//	vUseServicesList = False;
//	vServicesList = New СписокЗначений();
//	If ЗначениеЗаполнено(ServiceGroup) Тогда
//		If НЕ ServiceGroup.IncludeAll Тогда
//			vUseServicesList = True;
//			vServicesList.LoadValues(ServiceGroup.Services.UnloadColumn("Услуга"));
//		EndIf;
//	EndIf;
//	vQry.SetParameter("qUseServicesList", vUseServicesList);
//	vQry.SetParameter("qServicesList", vServicesList);
//	vQry.SetParameter("qEmptyString", "                              ");
//	vResults = vQry.Execute().Unload();
//	
//	// Move period column value to the first day of the current period
//	For Each vRow In vResults Do
//		If ЗначениеЗаполнено(vRow.Period) Тогда
//			If Periodicity = Перечисления.PeriodicityTypes.Week Тогда
//				vRow.Period = BegOfWeek(vRow.Period);
//			ElsIf Periodicity = Перечисления.PeriodicityTypes.Month Тогда
//				vRow.Period = BegOfMonth(vRow.Period);
//			ElsIf Periodicity = Перечисления.PeriodicityTypes.Quarter Тогда
//				vRow.Period = BegOfQuarter(vRow.Period);
//			ElsIf Periodicity = Перечисления.PeriodicityTypes.Year Тогда
//				vRow.Period = BegOfYear(vRow.Period);
//			EndIf;
//		EndIf;
//	EndDo;
//	If ЗначениеЗаполнено(Periodicity) And Periodicity <> Перечисления.PeriodicityTypes.Day Тогда
//		vResults.GroupBy("Валюта,Гостиница,PerPresentation,Period", GetReportResourcesList());
//	EndIf;
//	
//	// Move totals row to the last row Должность
//	If vResults.Count() > 0 Тогда
//		vRow = vResults.Get(0);
//		If vResults.Count() > 1 Тогда
//			vResults.Move(vRow, vResults.Count() - 1);
//		EndIf;
//	EndIf;
//	
//	// For each row in resulting table calculate load percents
//	For Each vRow In vResults Do
//		vTotalRooms = 0;
//		vTotalBeds = 0;
//		vTotalRoomsBlocked = 0;
//		vTotalBedsBlocked = 0;
//		vTotalSpecRoomsBlocked = 0;
//		vTotalSpecBedsBlocked = 0;
//		If НЕ ЗначениеЗаполнено(vRow.Period) Тогда
//			vTotalRooms = vTotals.Total("ВсегоНомеров");
//			vTotalBeds = vTotals.Total("ВсегоМест");
//			vTotalRoomsBlocked = vTotals.Total("TotalRoomsBlocked");
//			vTotalBedsBlocked = vTotals.Total("TotalBedsBlocked");
//			
//			vTotalSpecRoomsBlocked = vTotalSpecBlocks.Total("SpecRoomsBlocked");
//			vTotalSpecBedsBlocked = vTotalSpecBlocks.Total("SpecBedsBlocked");
//		Else
//			vRowPeriod = vRow.Period;
//			
//			vPeriodTotals = vTotals.FindRows(New Structure("Period", vRowPeriod));
//			vPeriodTotalSpecBlocks = vTotalSpecBlocks.FindRows(New Structure("Period", vRowPeriod));
//			
//			For Each vTotalsRow In vPeriodTotals Do
//				vTotalRooms = vTotalRooms + vTotalsRow.ВсегоНомеров;
//				vTotalBeds = vTotalBeds + vTotalsRow.ВсегоМест;
//				vTotalRoomsBlocked = vTotalRoomsBlocked + vTotalsRow.TotalRoomsBlocked;
//				vTotalBedsBlocked = vTotalBedsBlocked + vTotalsRow.TotalBedsBlocked;
//			EndDo;
//			
//			For Each vTotalsSpecBlocksRow In vPeriodTotalSpecBlocks Do
//				vTotalSpecRoomsBlocked = vTotalSpecRoomsBlocked + vTotalsSpecBlocksRow.SpecRoomsBlocked;
//				vTotalSpecBedsBlocked = vTotalSpecBedsBlocked + vTotalsSpecBlocksRow.SpecBedsBlocked;
//			EndDo;
//		EndIf;
//		vTotalRoomsAvailable = vTotalRooms - vTotalRoomsBlocked + vTotalSpecRoomsBlocked;
//		vTotalBedsAvailable = vTotalBeds - vTotalBedsBlocked + vTotalSpecBedsBlocked;
//		
//		// Fill period resources
//		vRow.TotalRooms = vTotalRooms;
//		vRow.TotalBeds = vTotalBeds;
//		vRow.TotalRoomsBlocked = vTotalRoomsBlocked;
//		vRow.TotalBedsBlocked = vTotalBedsBlocked;
//
//		vRow.TotalRoomsRentedPercent = ?(vTotalRooms = 0, 0, 100 * (vRow.RoomsRented + vTotalSpecRoomsBlocked)/vTotalRooms);
//		vRow.TotalBedsRentedPercent = ?(vTotalBeds = 0, 0, 100 * (vRow.BedsRented + vTotalSpecBedsBlocked)/vTotalBeds);
//		vRow.TotalRoomsRentedWithBlocksPercent = ?(vTotalRoomsAvailable = 0, 0, 100 * (vRow.RoomsRented + vTotalSpecRoomsBlocked)/vTotalRoomsAvailable);
//		vRow.TotalBedsRentedWithBlocksPercent = ?(vTotalBedsAvailable = 0, 0, 100 * (vRow.BedsRented + vTotalSpecBedsBlocked)/vTotalBedsAvailable);
//		
//		vRow.RoomsRented = vRow.RoomsRented + vTotalSpecRoomsBlocked;
//		vRow.BedsRented = vRow.BedsRented + vTotalSpecBedsBlocked;
//		
//		vRow.TotalRoomsBlocked = vTotalRoomsBlocked - vTotalSpecRoomsBlocked;
//		vRow.TotalBedsBlocked = vTotalBedsBlocked - vTotalSpecBedsBlocked;
//		
//		vRow.TotalRoomsAvailable = vTotalRoomsAvailable;
//		vRow.TotalBedsAvailable = vTotalBedsAvailable;
//
//		vRow.ADR = ?(vRow.RoomsRented = 0, 0, Round(vRow.RoomRevenue/vRow.RoomsRented, 2));
//		vRow.ADRWithoutVAT = ?(vRow.RoomsRented = 0, 0, Round(vRow.RoomRevenueWithoutVAT/vRow.RoomsRented, 2));
//		vRow.ADBR = ?(vRow.BedsRented = 0, 0, Round(vRow.RoomRevenue/vRow.BedsRented, 2));
//		vRow.ADBRWithoutVAT = ?(vRow.BedsRented = 0, 0, Round(vRow.RoomRevenueWithoutVAT/vRow.BedsRented, 2));
//		vRow.RevPAR = ?(vTotalRoomsAvailable = 0, 0, Round(vRow.RoomRevenue/vTotalRoomsAvailable, 2));
//		vRow.RevPARWithoutVAT = ?(vTotalRoomsAvailable = 0, 0, Round(vRow.RoomRevenueWithoutVAT/vTotalRoomsAvailable, 2));
//		vRow.RevPAB = ?(vTotalBedsAvailable = 0, 0, Round(vRow.RoomRevenue/vTotalBedsAvailable, 2));
//		vRow.RevPABWithoutVAT = ?(vTotalBedsAvailable = 0, 0, Round(vRow.RoomRevenueWithoutVAT/vTotalBedsAvailable, 2));
//		vRow.RevPAC = ?(vRow.GuestDays = 0, 0, Round(vRow.RoomRevenue/vRow.GuestDays, 2));
//		vRow.RevPACWithoutVAT = ?(vRow.GuestDays = 0, 0, Round(vRow.RoomRevenueWithoutVAT/vRow.GuestDays, 2));
//		vRow.ALS = ?(vRow.GuestsCheckedIn = 0, 0, Round(vRow.GuestDays/vRow.GuestsCheckedIn, 3));
//		
//		// Fill period presentation
//		If ЗначениеЗаполнено(vRow.Period) Тогда
//			If ЗначениеЗаполнено(Periodicity) Тогда
//				If Periodicity = Перечисления.PeriodicityTypes.Day Тогда
//					vRow.PerPresentation = Format(vRow.Period, "DF=dd.MM.yyyy");
//				ElsIf Periodicity = Перечисления.PeriodicityTypes.Week Тогда
//					vRow.PerPresentation = PeriodPresentation(BegOfWeek(vRow.Period), EndOfWeek(vRow.Period), cmLocalizationCode());
//				ElsIf Periodicity = Перечисления.PeriodicityTypes.Month Тогда
//					vRow.PerPresentation = PeriodPresentation(BegOfMonth(vRow.Period), EndOfMonth(vRow.Period), cmLocalizationCode());
//				ElsIf Periodicity = Перечисления.PeriodicityTypes.Quarter Тогда
//					vRow.PerPresentation = PeriodPresentation(BegOfQuarter(vRow.Period), EndOfQuarter(vRow.Period), cmLocalizationCode());
//				ElsIf Periodicity = Перечисления.PeriodicityTypes.Year Тогда
//					vRow.PerPresentation = PeriodPresentation(BegOfYear(vRow.Period), EndOfYear(vRow.Period), cmLocalizationCode());
//				EndIf;
//			Else
//				vRow.PerPresentation = Format(vRow.Period, "DF=dd.MM.yyyy");
//			EndIf;
//		EndIf;
//	EndDo;
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
//	// Apply appearance settings to the report template
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
//Function GetPeriodicityPresentation()
//	// Get periodicity presentation
//	vPeriodicity = "Day,";
//	If Periodicity = Перечисления.PeriodicityTypes.Week Тогда
//		vPeriodicity = "Week,";
//	ElsIf Periodicity = Перечисления.PeriodicityTypes.Month Тогда
//		vPeriodicity = "Month,";
//	ElsIf Periodicity = Перечисления.PeriodicityTypes.Quarter Тогда
//		vPeriodicity = "Quarter,";
//	ElsIf Periodicity = Перечисления.PeriodicityTypes.Year Тогда
//		vPeriodicity = "Year,";
//	EndIf;
//	Return vPeriodicity;
//EndFunction //GetPeriodicityPresentation
//
////-----------------------------------------------------------------------------
//Процедура pmInitializeReportBuilder() Экспорт
//	ReportBuilder = New ReportBuilder();
//	
//	// Initialize default query text
//	QueryText = 
//	"SELECT
//	|	ОборотыПродажиНомеров.Валюта AS Валюта,
//	|	ОборотыПродажиНомеров.Гостиница AS Гостиница,
//	|	&qEmptyString AS PerPresentation,
//	|	ОборотыПродажиНомеров.Period AS Period,
//	|	SUM(ОборотыПродажиНомеров.SalesTurnover) AS Продажи,
//	|	SUM(ОборотыПродажиНомеров.RoomRevenueTurnover) AS ДоходНомеров,
//	|	SUM(ОборотыПродажиНомеров.SalesWithoutVATTurnover) AS ПродажиБезНДС,
//	|	SUM(ОборотыПродажиНомеров.RoomRevenueWithoutVATTurnover) AS ДоходПродажиБезНДС,
//	|	SUM(ОборотыПродажиНомеров.CommissionSumTurnover) AS СуммаКомиссии,
//	|	SUM(ОборотыПродажиНомеров.CommissionSumWithoutVATTurnover) AS КомиссияБезНДС,
//	|	SUM(ОборотыПродажиНомеров.DiscountSumTurnover) AS СуммаСкидки,
//	|	SUM(ОборотыПродажиНомеров.DiscountSumWithoutVATTurnover) AS СуммаСкидкиБезНДС,
//	|	SUM(ОборотыПродажиНомеров.RoomsRentedTurnover) AS ПроданоНомеров,
//	|	SUM(ОборотыПродажиНомеров.BedsRentedTurnover) AS ПроданоМест,
//	|	SUM(ОборотыПродажиНомеров.AdditionalBedsRentedTurnover) AS ПроданоДопМест,
//	|	SUM(ОборотыПродажиНомеров.GuestDaysTurnover) AS ЧеловекаДни,
//	|	SUM(ОборотыПродажиНомеров.GuestsCheckedInTurnover) AS ЗаездГостей,
//	|	SUM(ОборотыПродажиНомеров.RoomsCheckedInTurnover) AS ЗаездНомеров,
//	|	SUM(ОборотыПродажиНомеров.BedsCheckedInTurnover) AS ЗаездМест,
//	|	SUM(ОборотыПродажиНомеров.AdditionalBedsCheckedInTurnover) AS ЗаездДополнительныхМест,
//	|	SUM(ОборотыПродажиНомеров.QuantityTurnover) AS Количество,
//	|	0 AS ADR,
//	|	0 AS ADRWithoutVAT,
//	|	0 AS ADBR,
//	|	0 AS ADBRWithoutVAT,
//	|	0 AS RevPAR,
//	|	0 AS RevPARWithoutVAT,
//	|	0 AS RevPAB,
//	|	0 AS RevPABWithoutVAT,
//	|	0 AS RevPAC,
//	|	0 AS RevPACWithoutVAT,
//	|	0 AS ALS,
//	|	0 AS ВсегоНомеров,
//	|	0 AS ВсегоМест,
//	|	0 AS TotalRoomsBlocked,
//	|	0 AS TotalBedsBlocked,
//	|	0 AS TotalRoomsAvailable,
//	|	0 AS TotalBedsAvailable,
//	|	0 AS TotalRoomsRentedPercent,
//	|	0 AS TotalBedsRentedPercent,
//	|	0 AS TotalRoomsRentedWithBlocksPercent,
//	|	0 AS TotalBedsRentedWithBlocksPercent
//	|{SELECT
//	|	Валюта.*,
//	|	Гостиница.*,
//	|	PerPresentation,
//	|	Period,
//	|	Продажи,
//	|	ДоходНомеров,
//	|	ПродажиБезНДС,
//	|	ДоходПродажиБезНДС,
//	|	СуммаКомиссии,
//	|	КомиссияБезНДС,
//	|	СуммаСкидки,
//	|	СуммаСкидкиБезНДС,
//	|	ПроданоНомеров,
//	|	ПроданоМест,
//	|	ПроданоДопМест,
//	|	ЧеловекаДни,
//	|	ЗаездГостей,
//	|	ЗаездНомеров,
//	|	ЗаездМест,
//	|	ЗаездДополнительныхМест,
//	|	Количество,
//	|	ADR,
//	|	ADRWithoutVAT,
//	|	ADBR,
//	|	ADBRWithoutVAT,
//	|	RevPAR,
//	|	RevPARWithoutVAT,
//	|	RevPAB,
//	|	RevPABWithoutVAT,
//	|	RevPAC,
//	|	RevPACWithoutVAT,
//	|	ALS,
//	|	ВсегоНомеров,
//	|	ВсегоМест,
//	|	TotalRoomsBlocked,
//	|	TotalBedsBlocked,
//	|	TotalRoomsAvailable,
//	|	TotalBedsAvailable,
//	|	TotalRoomsRentedPercent,
//	|	TotalBedsRentedPercent,
//	|	TotalRoomsRentedWithBlocksPercent,
//	|	TotalBedsRentedWithBlocksPercent}
//	|FROM
//	|	(SELECT
//	|		RoomSales.Валюта AS Валюта,
//	|		RoomSales.Гостиница AS Гостиница,
//	|		RoomSales.Period AS Period,
//	|		RoomSales.SalesTurnover AS SalesTurnover,
//	|		RoomSales.RoomRevenueTurnover AS RoomRevenueTurnover,
//	|		RoomSales.SalesWithoutVATTurnover AS SalesWithoutVATTurnover,
//	|		RoomSales.RoomRevenueWithoutVATTurnover AS RoomRevenueWithoutVATTurnover,
//	|		RoomSales.CommissionSumTurnover AS CommissionSumTurnover,
//	|		RoomSales.CommissionSumWithoutVATTurnover AS CommissionSumWithoutVATTurnover,
//	|		RoomSales.DiscountSumTurnover AS DiscountSumTurnover,
//	|		RoomSales.DiscountSumWithoutVATTurnover AS DiscountSumWithoutVATTurnover,
//	|		RoomSales.RoomsRentedTurnover AS RoomsRentedTurnover,
//	|		RoomSales.BedsRentedTurnover AS BedsRentedTurnover,
//	|		RoomSales.AdditionalBedsRentedTurnover AS AdditionalBedsRentedTurnover,
//	|		RoomSales.GuestDaysTurnover AS GuestDaysTurnover,
//	|		RoomSales.GuestsCheckedInTurnover AS GuestsCheckedInTurnover,
//	|		RoomSales.RoomsCheckedInTurnover AS RoomsCheckedInTurnover,
//	|		RoomSales.BedsCheckedInTurnover AS BedsCheckedInTurnover,
//	|		RoomSales.AdditionalBedsCheckedInTurnover AS AdditionalBedsCheckedInTurnover,
//	|		RoomSales.QuantityTurnover AS QuantityTurnover
//	|	FROM
//	|		AccumulationRegister.Продажи.Turnovers(
//	|				&qPeriodFrom,
//	|				&qPeriodTo,
//	|				Day,
//	|				Гостиница IN HIERARCHY (&qHotel)
//	|					AND (НомерРазмещения IN HIERARCHY (&qRoom)
//	|						OR &qIsEmptyRoom)
//	|					AND (ТипНомера IN HIERARCHY (&qRoomType)
//	|						OR &qIsEmptyRoomType)
//	|					AND (Услуга IN HIERARCHY (&qService)
//	|						OR &qIsEmptyService)
//	|					AND (Услуга IN HIERARCHY (&qServicesList)
//	|						OR (NOT &qUseServicesList))) AS RoomSales
//	|	
//	|	UNION ALL
//	|	
//	|	SELECT
//	|		RoomSalesForecast.Валюта,
//	|		RoomSalesForecast.Гостиница,
//	|		RoomSalesForecast.Period,
//	|		RoomSalesForecast.SalesTurnover,
//	|		RoomSalesForecast.RoomRevenueTurnover,
//	|		RoomSalesForecast.SalesWithoutVATTurnover,
//	|		RoomSalesForecast.RoomRevenueWithoutVATTurnover,
//	|		RoomSalesForecast.CommissionSumTurnover,
//	|		RoomSalesForecast.CommissionSumWithoutVATTurnover,
//	|		RoomSalesForecast.DiscountSumTurnover,
//	|		RoomSalesForecast.DiscountSumWithoutVATTurnover,
//	|		RoomSalesForecast.RoomsRentedTurnover,
//	|		RoomSalesForecast.BedsRentedTurnover,
//	|		RoomSalesForecast.AdditionalBedsRentedTurnover,
//	|		RoomSalesForecast.GuestDaysTurnover,
//	|		RoomSalesForecast.GuestsCheckedInTurnover,
//	|		RoomSalesForecast.RoomsCheckedInTurnover,
//	|		RoomSalesForecast.BedsCheckedInTurnover,
//	|		RoomSalesForecast.AdditionalBedsCheckedInTurnover,
//	|		RoomSalesForecast.QuantityTurnover
//	|	FROM
//	|		AccumulationRegister.ПрогнозПродаж.Turnovers(
//	|				&qForecastPeriodFrom,
//	|				&qForecastPeriodTo,
//	|				Day,
//	|				Гостиница IN HIERARCHY (&qHotel)
//	|					AND (НомерРазмещения IN HIERARCHY (&qRoom)
//	|						OR &qIsEmptyRoom)
//	|					AND (ТипНомера IN HIERARCHY (&qRoomType)
//	|						OR &qIsEmptyRoomType)
//	|					AND (Услуга IN HIERARCHY (&qService)
//	|						OR &qIsEmptyService)
//	|					AND (Услуга IN HIERARCHY (&qServicesList)
//	|						OR (NOT &qUseServicesList))) AS RoomSalesForecast) AS ОборотыПродажиНомеров
//	|{WHERE
//	|	ОборотыПродажиНомеров.Валюта.*,
//	|	ОборотыПродажиНомеров.Гостиница.*,
//	|	ОборотыПродажиНомеров.Period,
//	|	(SUM(ОборотыПродажиНомеров.SalesTurnover)) AS Продажи,
//	|	(SUM(ОборотыПродажиНомеров.RoomRevenueTurnover)) AS ДоходНомеров,
//	|	(SUM(ОборотыПродажиНомеров.SalesWithoutVATTurnover)) AS ПродажиБезНДС,
//	|	(SUM(ОборотыПродажиНомеров.RoomRevenueWithoutVATTurnover)) AS ДоходПродажиБезНДС,
//	|	(SUM(ОборотыПродажиНомеров.CommissionSumTurnover)) AS СуммаКомиссии,
//	|	(SUM(ОборотыПродажиНомеров.CommissionSumWithoutVATTurnover)) AS КомиссияБезНДС,
//	|	(SUM(ОборотыПродажиНомеров.DiscountSumTurnover)) AS СуммаСкидки,
//	|	(SUM(ОборотыПродажиНомеров.DiscountSumWithoutVATTurnover)) AS СуммаСкидкиБезНДС,
//	|	(SUM(ОборотыПродажиНомеров.RoomsRentedTurnover)) AS ПроданоНомеров,
//	|	(SUM(ОборотыПродажиНомеров.BedsRentedTurnover)) AS ПроданоМест,
//	|	(SUM(ОборотыПродажиНомеров.AdditionalBedsRentedTurnover)) AS ПроданоДопМест,
//	|	(SUM(ОборотыПродажиНомеров.GuestDaysTurnover)) AS ЧеловекаДни,
//	|	(SUM(ОборотыПродажиНомеров.GuestsCheckedInTurnover)) AS ЗаездГостей,
//	|	(SUM(ОборотыПродажиНомеров.RoomsCheckedInTurnover)) AS ЗаездНомеров,
//	|	(SUM(ОборотыПродажиНомеров.BedsCheckedInTurnover)) AS ЗаездМест,
//	|	(SUM(ОборотыПродажиНомеров.AdditionalBedsCheckedInTurnover)) AS ЗаездДополнительныхМест,
//	|	(SUM(ОборотыПродажиНомеров.QuantityTurnover)) AS Количество,
//	|	(0) AS ADR,
//	|	(0) AS ADRWithoutVAT,
//	|	(0) AS ADBR,
//	|	(0) AS ADBRWithoutVAT,
//	|	(0) AS RevPAR,
//	|	(0) AS RevPARWithoutVAT,
//	|	(0) AS RevPAB,
//	|	(0) AS RevPABWithoutVAT,
//	|	(0) AS RevPAC,
//	|	(0) AS RevPACWithoutVAT,
//	|	(0) AS ALS,
//	|	(0) AS ВсегоНомеров,
//	|	(0) AS ВсегоМест,
//	|	(0) AS TotalRoomsBlocked,
//	|	(0) AS TotalBedsBlocked,
//	|	(0) AS TotalRoomsAvailable,
//	|	(0) AS TotalBedsAvailable,
//	|	(0) AS TotalRoomsRentedPercent,
//	|	(0) AS TotalBedsRentedPercent,
//	|	(0) AS TotalRoomsRentedWithBlocksPercent,
//	|	(0) AS TotalBedsRentedWithBlocksPercent}
//	|
//	|GROUP BY
//	|	ОборотыПродажиНомеров.Валюта,
//	|	ОборотыПродажиНомеров.Гостиница,
//	|	ОборотыПродажиНомеров.Period
//	|
//	|ORDER BY
//	|	ОборотыПродажиНомеров.Валюта.Description,
//	|	ОборотыПродажиНомеров.Гостиница.ПорядокСортировки,
//	|	Period
//	|TOTALS
//	|	SUM(Продажи),
//	|	SUM(ДоходНомеров),
//	|	SUM(ПродажиБезНДС),
//	|	SUM(ДоходПродажиБезНДС),
//	|	SUM(СуммаКомиссии),
//	|	SUM(КомиссияБезНДС),
//	|	SUM(СуммаСкидки),
//	|	SUM(СуммаСкидкиБезНДС),
//	|	SUM(ПроданоНомеров),
//	|	SUM(ПроданоМест),
//	|	SUM(ПроданоДопМест),
//	|	SUM(ЧеловекаДни),
//	|	SUM(ЗаездГостей),
//	|	SUM(ЗаездНомеров),
//	|	SUM(ЗаездМест),
//	|	SUM(ЗаездДополнительныхМест),
//	|	SUM(Количество)
//	|BY
//	|	OVERALL";
//	ReportBuilder.Text = QueryText;
//	ReportBuilder.FillSettings();
//	
//	// Initialize report builder with default query
//	vRB = New ReportBuilder(QueryText);
//	vRBSettings = vRB.GetSettings(True, True, True, True, True);
//	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
//	
//	// Set default report builder header text
//	ReportBuilder.HeaderText = NStr("EN='Revenue turnovers';RU='Доходность и загрузка';de='Wirtschaftlichkeit und Auslastung'");
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
//	If pName = "Продажи" 
//	   Or pName = "ДоходНомеров" 
//	   Or pName = "ПродажиБезНДС" 
//	   Or pName = "ДоходПродажиБезНДС" 
//	   Or pName = "СуммаКомиссии" 
//	   Or pName = "КомиссияБезНДС" 
//	   Or pName = "СуммаСкидки" 
//	   Or pName = "СуммаСкидкиБезНДС" 
//	   Or pName = "ПроданоНомеров" 
//	   Or pName = "ПроданоМест" 
//	   Or pName = "ПроданоДопМест" 
//	   Or pName = "ЧеловекаДни" 
//	   Or pName = "ЗаездГостей" 
//	   Or pName = "ЗаездНомеров" 
//	   Or pName = "ЗаездМест" 
//	   Or pName = "ЗаездДополнительныхМест" 
//	   Or pName = "Количество" 
//	   Or pName = "ADR"
//	   Or pName = "ADRWithoutVAT"
//	   Or pName = "ADBR"
//	   Or pName = "ADBRWithoutVAT"
//	   Or pName = "RevPAR"
//	   Or pName = "RevPARWithoutVAT"
//	   Or pName = "RevPAB"
//	   Or pName = "RevPABWithoutVAT"
//	   Or pName = "RevPAC"
//	   Or pName = "RevPACWithoutVAT"
//	   Or pName = "ALS"
//	   Or pName = "ВсегоНомеров"
//	   Or pName = "ВсегоМест"
//	   Or pName = "TotalRoomsBlocked"
//	   Or pName = "TotalBedsBlocked"
//	   Or pName = "TotalRoomsAvailable"
//	   Or pName = "TotalBedsAvailable"
//	   Or pName = "TotalRoomsRentedPercent"
//	   Or pName = "TotalBedsRentedPercent"
//	   Or pName = "TotalRoomsRentedWithBlocksPercent"
//	   Or pName = "TotalBedsRentedWithBlocksPercent" Тогда
//		Return True;
//	Else
//		Return False;
//	EndIf;
//EndFunction //pmIsResource
//
////-----------------------------------------------------------------------------
//Function GetReportResourcesList()
//	vResources = "Продажи,ДоходНомеров,ПродажиБезНДС,ДоходПродажиБезНДС,СуммаКомиссии,КомиссияБезНДС,Количество," +
//	             "СуммаСкидки,СуммаСкидкиБезНДС,ПроданоНомеров,ПроданоМест,ПроданоДопМест," + 
//	             "ЧеловекаДни,ЗаездГостей,ЗаездНомеров,ЗаездМест,ЗаездДополнительныхМест,ADR,ADRWithoutVAT,ADBR,ADBRWithoutVAT," + 
//	             "RevPAR,RevPARWithoutVAT,RevPAB,RevPABWithoutVAT,RevPAC,RevPACWithoutVAT,ALS," + 
//	             "ВсегоНомеров,ВсегоМест,TotalRoomsBlocked,TotalBedsBlocked,TotalRoomsAvailable,TotalBedsAvailable," + 
//	             "TotalRoomsRentedPercent,TotalBedsRentedPercent,TotalRoomsRentedWithBlocksPercent,TotalBedsRentedWithBlocksPercent";
//	Return vResources;
//EndFunction //GetReportResourcesList
//
////-----------------------------------------------------------------------------
//// Reports framework end
////-----------------------------------------------------------------------------
//
////-----------------------------------------------------------------------------
//Процедура AddMissingPeriods(pTbl)
//	// Add missing days to the table
//	If pTbl.Count() > 0 Тогда
//		vLastDayRow = pTbl.Get(0);
//		
//		vDay = BegOfDay(vLastDayRow.Period);
//		While vDay <= BegOfDay(PeriodTo) Do
//			vRow = pTbl.Find(vDay, "Period");
//			If vRow = Неопределено Тогда
//				vRow = pTbl.Add();
//				FillPropertyValues(vRow, vLastDayRow);
//				vRow.Period = vDay;
//			Else
//				vLastDayRow = vRow;
//			EndIf;
//			
//			vDay = vDay + 24*3600;
//		EndDo;
//	EndIf;
//	
//	// Convert periods to report periodicity
//	If ЗначениеЗаполнено(Periodicity) And Periodicity <> Перечисления.PeriodicityTypes.Day Тогда
//		For Each vRow In pTbl Do
//			If ЗначениеЗаполнено(vRow.Period) Тогда
//				If Periodicity = Перечисления.PeriodicityTypes.Week Тогда
//					vRow.Period = BegOfWeek(vRow.Period);
//				ElsIf Periodicity = Перечисления.PeriodicityTypes.Month Тогда
//					vRow.Period = BegOfMonth(vRow.Period);
//				ElsIf Periodicity = Перечисления.PeriodicityTypes.Quarter Тогда
//					vRow.Period = BegOfQuarter(vRow.Period);
//				ElsIf Periodicity = Перечисления.PeriodicityTypes.Year Тогда
//					vRow.Period = BegOfYear(vRow.Period);
//				EndIf;
//			EndIf;
//		EndDo;
//	EndIf;
//КонецПроцедуры //AddMissingPeriods
