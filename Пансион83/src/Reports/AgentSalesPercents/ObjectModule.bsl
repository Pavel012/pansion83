//-----------------------------------------------------------------------------
// Reports framework start
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
		PeriodFrom = BegOfMonth(CurrentDate()); // For beg of month
		PeriodTo = EndOfDay(CurrentDate());
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
	If ЗначениеЗаполнено(Agent) Тогда
		If НЕ Agent.IsFolder Тогда
			vParamPresentation = vParamPresentation + NStr("en='Agent ';ru='Агент ';de='Vertreter'") + 
			                     TrimAll(Agent.Description) + 
			                     ";" + Chars.LF;
		Else
			vParamPresentation = vParamPresentation + NStr("en='Agents folder ';ru='Группа агентов ';de='Gruppe Vertreter'") + 
			                     TrimAll(Agent.Description) + 
			                     ";" + Chars.LF;
		EndIf;
	EndIf;							 
	If ЗначениеЗаполнено(Customer) Тогда
		If НЕ Customer.IsFolder Тогда
			vParamPresentation = vParamPresentation + NStr("de='Firma';en='Контрагент ';ru='Контрагент '") + 
			                     TrimAll(Customer.Description) + 
			                     ";" + Chars.LF;
		Else
			vParamPresentation = vParamPresentation + NStr("de='Gruppe Firmen';en='Customers folder ';ru='Группа контрагентов '") + 
			                     TrimAll(Customer.Description) + 
			                     ";" + Chars.LF;
		EndIf;
	EndIf;							 
	If ЗначениеЗаполнено(Contract) Тогда
		vParamPresentation = vParamPresentation + NStr("en='Contract ';ru='Договор ';de='Vertrag '") + 
							 TrimAll(Contract.Description) + 
							 ";" + Chars.LF;
	EndIf;							 
	If ЗначениеЗаполнено(Company) Тогда
		If НЕ Company.IsFolder Тогда
			vParamPresentation = vParamPresentation + NStr("ru = 'Фирма '; en = 'Фирма '") + 
			                     TrimAll(Company.Description) + 
			                     ";" + Chars.LF;
		Else
			vParamPresentation = vParamPresentation + NStr("ru = 'Группа фирм '; en = 'Companies folder '") + 
			                     TrimAll(Company.Description) + 
			                     ";" + Chars.LF;
		EndIf;
	EndIf;							 
	If ЗначениеЗаполнено(ServiceGroup) Тогда
		If НЕ ServiceGroup.IsFolder Тогда
			vParamPresentation = vParamPresentation + NStr("ru = 'Набор услуг '; en = 'Service group '") + 
			                     TrimAll(ServiceGroup.Description) + 
			                     ";" + Chars.LF;
		Else
			vParamPresentation = vParamPresentation + NStr("ru = 'Группа наборов услуг '; en = 'Service groups folder '") + 
			                     TrimAll(ServiceGroup.Description) + 
			                     ";" + Chars.LF;
		EndIf;
	EndIf;					 
	Return vParamPresentation;
EndFunction //pmGetReportParametersPresentation

//-----------------------------------------------------------------------------
// Runs report
//-----------------------------------------------------------------------------
Процедура pmGenerate(pSpreadsheet, pAddChart = False) Экспорт
	
	
	// Check if there are any filters set for the report builder
	vFilterIsNotSet = True;
	For Each vFilterRow In ReportBuilder.Filter Do
		If vFilterRow.Use Тогда
			vFilterIsNotSet = False;
			Break;
		EndIf;
	EndDo;
	// Check if there is any custom ordering applied for the report builder
	vOrderIsNotSet = True;
	If ReportBuilder.Order.Count() > 0 Тогда
		vOrderIsNotSet = False;
	EndIf;
	
	// Reset report builder template
	ReportBuilder.Template = Неопределено;
	
	// Initialize report builder query generator attributes
	ReportBuilder.PresentationAdding = PresentationAdditionType.Add;
	
	// Run query to get available rooms for days
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	TotalRoomInventoryBalanceAndTurnovers.Period AS Period,
	|	SUM(TotalRoomInventoryBalanceAndTurnovers.CounterClosingBalance) AS CounterClosingBalance,
	|	SUM(TotalRoomInventoryBalanceAndTurnovers.TotalRoomsClosingBalance) AS ВсегоНомеров,
	|	SUM(TotalRoomInventoryBalanceAndTurnovers.TotalBedsClosingBalance) AS ВсегоМест,
	|	-SUM(TotalRoomInventoryBalanceAndTurnovers.RoomsBlockedClosingBalance) AS TotalRoomsBlocked,
	|	-SUM(TotalRoomInventoryBalanceAndTurnovers.BedsBlockedClosingBalance) AS TotalBedsBlocked,
	|	SUM(TotalRoomInventoryBalanceAndTurnovers.GuestsReservedReceipt) AS TotalGuestsReservedReceipt,
	|	SUM(TotalRoomInventoryBalanceAndTurnovers.GuestsReservedExpense) AS TotalGuestsReservedExpense,
	|	SUM(TotalRoomInventoryBalanceAndTurnovers.InHouseGuestsReceipt) AS TotalInHouseGuestsReceipt,
	|	SUM(TotalRoomInventoryBalanceAndTurnovers.InHouseGuestsExpense) AS TotalInHouseGuestsExpense
	|FROM
	|	AccumulationRegister.ЗагрузкаНомеров.BalanceAndTurnovers(
	|			&qPeriodFrom,
	|			&qPeriodTo,
	|			Day,
	|			RegisterRecordsAndPeriodBoundaries,
	|			Гостиница IN HIERARCHY (&qHotel)
	|				AND (НомерРазмещения IN HIERARCHY (&qRoom)
	|					OR &qIsEmptyRoom)
	|				AND (ТипНомера IN HIERARCHY (&qRoomType)
	|					OR &qIsEmptyRoomType)) AS TotalRoomInventoryBalanceAndTurnovers
	|
	|GROUP BY
	|	TotalRoomInventoryBalanceAndTurnovers.Period
	|
	|ORDER BY
	|	Period";
	vQry.SetParameter("qHotel", Гостиница);
	vQry.SetParameter("qPeriodFrom", PeriodFrom);
	vQry.SetParameter("qPeriodTo", PeriodTo);
	vQry.SetParameter("qRoom", Room);
	vQry.SetParameter("qIsEmptyRoom", НЕ ЗначениеЗаполнено(Room));
	vQry.SetParameter("qRoomType", RoomType);
	vQry.SetParameter("qIsEmptyRoomType", НЕ ЗначениеЗаполнено(RoomType));
	vTotals = vQry.Execute().Unload();
	
	AddMissingPeriods(vTotals);
	
	vTotalRooms = vTotals.Total("ВсегоНомеров");
	vTotalBeds = vTotals.Total("ВсегоМест");
	vTotalRoomsBlocked = vTotals.Total("TotalRoomsBlocked");
	vTotalBedsBlocked = vTotals.Total("TotalBedsBlocked");
	
	
	
	// Run main query to get data
	vQry = New Query();
	vQry.Text = TrimAll(QueryText);
	vQry.SetParameter("qHotel", Гостиница);
	vQry.SetParameter("qPeriodFrom", PeriodFrom);
	vQry.SetParameter("qPeriodTo", PeriodTo);
	vQry.SetParameter("qForecastPeriodFrom", Max(BegOfDay(PeriodFrom), BegOfDay(CurrentDate())));
	vQry.SetParameter("qForecastPeriodTo", ?(ЗначениеЗаполнено(PeriodTo), Max(PeriodTo, EndOfDay(CurrentDate()-24*3600)), '00010101'));
	vQry.SetParameter("qAgent", Agent);
	vQry.SetParameter("qIsEmptyAgent", НЕ ЗначениеЗаполнено(Agent));
	vQry.SetParameter("qCustomer", Customer);
	vQry.SetParameter("qIsEmptyCustomer", НЕ ЗначениеЗаполнено(Customer));
	vQry.SetParameter("qContract", Contract);
	vQry.SetParameter("qIsEmptyContract", НЕ ЗначениеЗаполнено(Contract));
	vQry.SetParameter("qCompany", Company);
	vQry.SetParameter("qIsEmptyCompany", НЕ ЗначениеЗаполнено(Company));
	vQry.SetParameter("qRoom", Room);
	vQry.SetParameter("qIsEmptyRoom", НЕ ЗначениеЗаполнено(Room));
	vQry.SetParameter("qRoomType", RoomType);
	vQry.SetParameter("qIsEmptyRoomType", НЕ ЗначениеЗаполнено(RoomType));
	vQry.SetParameter("qEmptyCommissionType", Перечисления.AgentCommissionTypes.EmptyRef());
	vUseServicesList = False;
	vServicesList = New СписокЗначений();
	If ЗначениеЗаполнено(ServiceGroup) Тогда
		If НЕ ServiceGroup.IncludeAll Тогда
			vUseServicesList = True;
			vServicesList.LoadValues(ServiceGroup.Services.UnloadColumn("Услуга"));
		EndIf;
	EndIf;
	vQry.SetParameter("qUseServicesList", vUseServicesList);
	vQry.SetParameter("qServicesList", vServicesList);
	vQry.SetParameter("qEmptyString", "                  ");
	vResults = vQry.Execute().Unload();
	
	// Get total sales and ГруппаНомеров revenue assuming this is the first row in the query results table
	vTotalRoomRevenue = 0;
	vTotalRoomRevenueWithoutVAT = 0;
	vTotalSales = 0;
	vTotalSalesWithoutVAT = 0;
	vTotalCommissionSum = 0;
	vTotalCommissionSumWithoutVAT = 0;
	vTotalDiscountSum = 0;
	vTotalDiscountSumWithoutVAT = 0;
	vTotalRoomsRented = 0;
	vTotalBedsRented = 0;
	vTotalAdditionalBedsRented = 0;
	vTotalGuestDays = 0;
	vTotalGuestsCheckedIn = 0;
	vTotalRoomsCheckedIn = 0;
	vTotalBedsCheckedIn = 0;
	vTotalAdditionalBedsCheckedIn = 0;
	If vResults.Count() > 0 Тогда
		vRow = vResults.Get(0);
		
		vTotalRoomRevenue = vRow.ДоходНомеров;
		vTotalRoomRevenueWithoutVAT = vRow.ДоходПродажиБезНДС;
		vTotalSales = vRow.Продажи;
		vTotalSalesWithoutVAT = vRow.ПродажиБезНДС;
		vTotalCommissionSum = vRow.СуммаКомиссии;
		vTotalCommissionSumWithoutVAT = vRow.КомиссияБезНДС;
		vTotalDiscountSum = vRow.СуммаСкидки;
		vTotalDiscountSumWithoutVAT = vRow.СуммаСкидкиБезНДС;
		vTotalRoomsRented = vRow.ПроданоНомеров;
		vTotalBedsRented = vRow.ПроданоМест;
		vTotalAdditionalBedsRented = vRow.ПроданоМест;
		vTotalGuestDays = vRow.ЧеловекаДни;
		vTotalGuestsCheckedIn = vRow.ЗаездГостей;
		vTotalRoomsCheckedIn = vRow.ЗаездНомеров;
		vTotalBedsCheckedIn = vRow.ЗаездМест;
		vTotalAdditionalBedsCheckedIn = vRow.ЗаездДополнительныхМест;
		
		// Move first row to the last Должность or remove totals if there are filters or custom ordering
		If vResults.Count() > 1 Тогда
			If vFilterIsNotSet And vOrderIsNotSet Тогда
				vResults.Move(vRow, vResults.Count() - 1);
			Else
				vResults.Delete(vRow);
			EndIf;
		EndIf;
	EndIf;
	
	// For each row in resulting table calculate all percents
	For Each vRow In vResults Do
		vRow.TotalRooms = vTotalRooms;
		vRow.TotalBeds = vTotalBeds;
		vRow.TotalRoomsBlocked = vTotalRoomsBlocked;
		vRow.TotalBedsBlocked = vTotalBedsBlocked;
		vRow.TotalRoomsRentedPercent = Round(?(vTotalRooms = 0, 0, 100 * vRow.RoomsRented/vTotalRooms), 2);
		vRow.TotalBedsRentedPercent = Round(?(vTotalBeds = 0, 0, 100 * vRow.BedsRented/vTotalBeds), 2);
		vRow.RoomRevenuePercent = Round(?(vTotalRoomRevenue = 0, 0, 100 * vRow.RoomRevenue/vTotalRoomRevenue), 2);
		vRow.SalesPercent = Round(?(vTotalSales = 0, 0, 100 * vRow.Sales/vTotalSales), 2);

		vRow.ADR = ?(vRow.RoomsRented = 0, 0, Round(vRow.RoomRevenue/vRow.RoomsRented, 2));
		vRow.ADRWithoutVAT = ?(vRow.RoomsRented = 0, 0, Round(vRow.RoomRevenueWithoutVAT/vRow.RoomsRented, 2));
		vRow.ADBR = ?(vRow.BedsRented = 0, 0, Round(vRow.RoomRevenue/vRow.BedsRented, 2));
		vRow.ADBRWithoutVAT = ?(vRow.BedsRented = 0, 0, Round(vRow.RoomRevenueWithoutVAT/vRow.BedsRented, 2));
		vRow.RevPAC = ?(vRow.GuestDays = 0, 0, Round(vRow.RoomRevenue/vRow.GuestDays, 2));
		vRow.RevPACWithoutVAT = ?(vRow.GuestDays = 0, 0, Round(vRow.RoomRevenueWithoutVAT/vRow.GuestDays, 2));
		vRow.ALS = ?(vRow.GuestsCheckedIn = 0, 0, Round(vRow.GuestDays/vRow.GuestsCheckedIn, 3));
		
		// Calculate ABC analysis percent
		vRow.ABCAnalysisPercent = 0;
		If ABCAnalysisResourceName = "Продажи" Тогда
			vRow.ABCAnalysisPercent = Round(100*vRow.Sales/vTotalSales, 7);
		ElsIf ABCAnalysisResourceName = "ПродажиБезНДС" Тогда
			vRow.ABCAnalysisPercent = Round(100*vRow.SalesWithoutVAT/vTotalSalesWithoutVAT, 7);
		ElsIf ABCAnalysisResourceName = "ДоходНомеров" Тогда
			vRow.ABCAnalysisPercent = Round(100*vRow.RoomRevenue/vTotalRoomRevenue, 7);
		ElsIf ABCAnalysisResourceName = "ДоходПродажиБезНДС" Тогда
			vRow.ABCAnalysisPercent = Round(100*vRow.RoomRevenueWithoutVAT/vTotalRoomRevenueWithoutVAT, 7);
		ElsIf ABCAnalysisResourceName = "СуммаКомиссии" Тогда
			vRow.ABCAnalysisPercent = Round(100*vRow.CommissionSum/vTotalCommissionSum, 7);
		ElsIf ABCAnalysisResourceName = "КомиссияБезНДС" Тогда
			vRow.ABCAnalysisPercent = Round(100*vRow.CommissionSumWithoutVAT/vTotalCommissionSumWithoutVAT, 7);
		ElsIf ABCAnalysisResourceName = "СуммаСкидки" Тогда
			vRow.ABCAnalysisPercent = Round(100*vRow.DiscountSum/vTotalDiscountSum, 7);
		ElsIf ABCAnalysisResourceName = "СуммаСкидкиБезНДС" Тогда
			vRow.ABCAnalysisPercent = Round(100*vRow.DiscountSumWithoutVAT/vTotalDiscountSumWithoutVAT, 7);
		ElsIf ABCAnalysisResourceName = "ПроданоНомеров" Тогда
			vRow.ABCAnalysisPercent = Round(100*vRow.RoomsRented/vTotalRoomsRented, 7);
		ElsIf ABCAnalysisResourceName = "ПроданоМест" Тогда
			vRow.ABCAnalysisPercent = Round(100*vRow.BedsRented/vTotalBedsRented, 7);
		ElsIf ABCAnalysisResourceName = "ПроданоДопМест" Тогда
			vRow.ABCAnalysisPercent = Round(100*vRow.AdditionalBedsRented/vTotalAdditionalBedsRented, 7);
		ElsIf ABCAnalysisResourceName = "ЧеловекаДни" Тогда
			vRow.ABCAnalysisPercent = Round(100*vRow.GuestDays/vTotalGuestDays, 7);
		ElsIf ABCAnalysisResourceName = "ЗаездГостей" Тогда
			vRow.ABCAnalysisPercent = Round(100*vRow.GuestsCheckedIn/vTotalGuestsCheckedIn, 7);
		ElsIf ABCAnalysisResourceName = "ЗаездНомеров" Тогда
			vRow.ABCAnalysisPercent = Round(100*vRow.RoomsCheckedIn/vTotalRoomsCheckedIn, 7);
		ElsIf ABCAnalysisResourceName = "ЗаездМест" Тогда
			vRow.ABCAnalysisPercent = Round(100*vRow.BedsCheckedIn/vTotalBedsCheckedIn, 7);
		ElsIf ABCAnalysisResourceName = "ЗаездДополнительныхМест" Тогда
			vRow.ABCAnalysisPercent = Round(100*vRow.AdditionalBedsCheckedIn/vTotalAdditionalBedsCheckedIn, 7);
		EndIf;
	EndDo;
	
	// Calculate ABC analysis group
	If НЕ IsBlankString(ABCAnalysisResourceName) And vResults.Count() > 0 Тогда
		vABCAnalysisResults = vResults.Copy();
		vABCAnalysisResults.Delete(vABCAnalysisResults.Count()-1);
		vABCAnalysisResults.Sort("ABCAnalysisPercent DESC");
		vAccumulatingPercent = 0;
		For Each vABCAnalysisRow In vABCAnalysisResults Do
			If vAccumulatingPercent <= ABCAnalysisAGroupPercent Тогда
				vABCAnalysisRow.ABCAnalysisGroup = NStr("en='A Group';ru='Группа A';de='Gruppe A'");
			ElsIf vAccumulatingPercent <= (ABCAnalysisAGroupPercent + ABCAnalysisBGroupPercent) Тогда
				vABCAnalysisRow.ABCAnalysisGroup = NStr("en='B Group';ru='Группа B';de='Gruppe B'");
			Else
				vABCAnalysisRow.ABCAnalysisGroup = NStr("en='C Group';ru='Группа C';de='Gruppe C'");
			EndIf;
			vRows = vResults.FindRows(New Structure("Валюта, Гостиница, Агент", vABCAnalysisRow.ReportingCurrency, vABCAnalysisRow.Гостиница, vABCAnalysisRow.Agent));
			If vRows.Count() > 0 Тогда
				vRow = vRows.Get(0);
				vRow.ABCAnalysisGroup = vABCAnalysisRow.ABCAnalysisGroup;
			EndIf;
			vAccumulatingPercent = vAccumulatingPercent + vABCAnalysisRow.ABCAnalysisPercent;
		EndDo;
	EndIf;
	
	// Save current report builder settings
	vCurReportBuilderSettings = ReportBuilder.GetSettings(True, True, True, True, True);
	
	// Set resulting table as data source for the report builder
	ReportBuilder.DataSource = New DataSourceDescription(vResults);
	
	// Fill report builder fields presentations from the report template
	
	
	// Apply current report builder settings
	ReportBuilder.SetSettings(vCurReportBuilderSettings);
	
	// Execute report builder
	ReportBuilder.Execute();
	
	//// Apply appearance settings to the report template
	//vTemplateAttributes = cmApplyReportTemplateAppearance(ThisObject);
	//
	//// Output report to the spreadsheet
	//ReportBuilder.Put(pSpreadsheet);
	////ReportBuilder.Template.Show(); // For debug purpose

	// Add totals caption and appearance to the last report row
	If vResults.Count() > 0 And vFilterIsNotSet And vOrderIsNotSet Тогда
		vLastRepRow = pSpreadsheet.Area(pSpreadsheet.TableHeight-2, 2, pSpreadsheet.TableHeight-2, pSpreadsheet.TableWidth);
		vLastRepRow.Font = New Font(pSpreadsheet.Area(pSpreadsheet.TableHeight-2, 2, pSpreadsheet.TableHeight-2, 2).Font, , , True);
		vLastRepRow.BackColor = pSpreadsheet.Area(4, 2, 4, 2).BackColor;
		pSpreadsheet.Area(pSpreadsheet.TableHeight-2, 2, pSpreadsheet.TableHeight-2, 2).Text = NStr("en='Totals';ru='Итог';de='Ergebnis'");
	EndIf;

КонецПроцедуры //pmGenerate
	
//-----------------------------------------------------------------------------
Процедура pmInitializeReportBuilder() Экспорт
	ReportBuilder = New ReportBuilder();
	
	// Initialize default query text
	QueryText = 
	"SELECT
	|	CustomerSales.Валюта AS Валюта,
	|	CustomerSales.Гостиница AS Гостиница,
	|	CustomerSales.Агент AS Агент,
	|	&qEmptyString AS ABCAnalysisGroup,
	|	0 AS ABCAnalysisPercent,
	|	SUM(CustomerSales.SalesTurnover) AS Продажи,
	|	SUM(CustomerSales.RoomRevenueTurnover) AS ДоходНомеров,
	|	SUM(CustomerSales.SalesWithoutVATTurnover) AS ПродажиБезНДС,
	|	SUM(CustomerSales.RoomRevenueWithoutVATTurnover) AS ДоходПродажиБезНДС,
	|	SUM(CustomerSales.CommissionSumTurnover) AS СуммаКомиссии,
	|	SUM(CustomerSales.CommissionSumWithoutVATTurnover) AS КомиссияБезНДС,
	|	SUM(CustomerSales.DiscountSumTurnover) AS СуммаСкидки,
	|	SUM(CustomerSales.DiscountSumWithoutVATTurnover) AS СуммаСкидкиБезНДС,
	|	SUM(CustomerSales.RoomsRentedTurnover) AS ПроданоНомеров,
	|	SUM(CustomerSales.BedsRentedTurnover) AS ПроданоМест,
	|	SUM(CustomerSales.AdditionalBedsRentedTurnover) AS ПроданоДопМест,
	|	SUM(CustomerSales.GuestDaysTurnover) AS ЧеловекаДни,
	|	SUM(CustomerSales.GuestsCheckedInTurnover) AS ЗаездГостей,
	|	SUM(CustomerSales.RoomsCheckedInTurnover) AS ЗаездНомеров,
	|	SUM(CustomerSales.BedsCheckedInTurnover) AS ЗаездМест,
	|	SUM(CustomerSales.AdditionalBedsCheckedInTurnover) AS ЗаездДополнительныхМест,
	|	0 AS ВсегоНомеров,
	|	0 AS ВсегоМест,
	|	0 AS TotalRoomsBlocked,
	|	0 AS TotalBedsBlocked,
	|	0 AS TotalRoomsRentedPercent,
	|	0 AS TotalBedsRentedPercent,
	|	0 AS RoomRevenuePercent,
	|	0 AS SalesPercent,
	|	0 AS ADR,
	|	0 AS ADBR,
	|	0 AS ADRWithoutVAT,
	|	0 AS ADBRWithoutVAT,
	|	0 AS RevPAC,
	|	0 AS RevPACWithoutVAT,
	|	0 AS ALS
	|{SELECT
	|	Валюта.*,
	|	Гостиница.*,
	|	Агент.*,
	|	ABCAnalysisGroup,
	|	ABCAnalysisPercent,
	|	Продажи,
	|	ДоходНомеров,
	|	ПродажиБезНДС,
	|	ДоходПродажиБезНДС,
	|	СуммаКомиссии,
	|	КомиссияБезНДС,
	|	СуммаСкидки,
	|	СуммаСкидкиБезНДС,
	|	ПроданоНомеров,
	|	ПроданоМест,
	|	ПроданоДопМест,
	|	ЧеловекаДни,
	|	ЗаездГостей,
	|	ЗаездНомеров,
	|	ЗаездМест,
	|	ЗаездДополнительныхМест,
	|	ВсегоНомеров,
	|	ВсегоМест,
	|	TotalRoomsBlocked,
	|	TotalBedsBlocked,
	|	TotalRoomsRentedPercent,
	|	TotalBedsRentedPercent,
	|	RoomRevenuePercent,
	|	SalesPercent,
	|	ADR,
	|	ADBR,
	|	ADRWithoutVAT,
	|	ADBRWithoutVAT,
	|	RevPAC,
	|	RevPACWithoutVAT,
	|	ALS}
	|FROM
	|	(SELECT
	|		CustomerSalesTurnovers.Валюта AS Валюта,
	|		CustomerSalesTurnovers.Гостиница AS Гостиница,
	|		CustomerSalesTurnovers.Агент AS Агент,
	|		CustomerSalesTurnovers.SalesTurnover AS SalesTurnover,
	|		CustomerSalesTurnovers.RoomRevenueTurnover AS RoomRevenueTurnover,
	|		CustomerSalesTurnovers.SalesWithoutVATTurnover AS SalesWithoutVATTurnover,
	|		CustomerSalesTurnovers.RoomRevenueWithoutVATTurnover AS RoomRevenueWithoutVATTurnover,
	|		CustomerSalesTurnovers.CommissionSumTurnover AS CommissionSumTurnover,
	|		CustomerSalesTurnovers.CommissionSumWithoutVATTurnover AS CommissionSumWithoutVATTurnover,
	|		CustomerSalesTurnovers.DiscountSumTurnover AS DiscountSumTurnover,
	|		CustomerSalesTurnovers.DiscountSumWithoutVATTurnover AS DiscountSumWithoutVATTurnover,
	|		CustomerSalesTurnovers.RoomsRentedTurnover AS RoomsRentedTurnover,
	|		CustomerSalesTurnovers.BedsRentedTurnover AS BedsRentedTurnover,
	|		CustomerSalesTurnovers.AdditionalBedsRentedTurnover AS AdditionalBedsRentedTurnover,
	|		CustomerSalesTurnovers.GuestDaysTurnover AS GuestDaysTurnover,
	|		CustomerSalesTurnovers.GuestsCheckedInTurnover AS GuestsCheckedInTurnover,
	|		CustomerSalesTurnovers.RoomsCheckedInTurnover AS RoomsCheckedInTurnover,
	|		CustomerSalesTurnovers.BedsCheckedInTurnover AS BedsCheckedInTurnover,
	|		CustomerSalesTurnovers.AdditionalBedsCheckedInTurnover AS AdditionalBedsCheckedInTurnover
	|	FROM
	|		AccumulationRegister.Продажи.Turnovers(
	|				&qPeriodFrom,
	|				&qPeriodTo,
	|				Day,
	|				Гостиница IN HIERARCHY (&qHotel)
	|					AND (Агент IN HIERARCHY (&qAgent)
	|						OR &qIsEmptyAgent)
	|					AND (Фирма IN HIERARCHY (&qCompany)
	|						OR &qIsEmptyCompany)
	|					AND (ДокОснование.Контрагент IN HIERARCHY (&qCustomer)
	|						OR &qIsEmptyCustomer)
	|					AND (ДокОснование.Договор = &qContract
	|						OR &qIsEmptyContract)
	|					AND (ДокОснование.НомерРазмещения IN HIERARCHY (&qRoom)
	|						OR &qIsEmptyRoom)
	|					AND (ДокОснование.ТипНомера IN HIERARCHY (&qRoomType)
	|						OR &qIsEmptyRoomType)
	|					AND (Услуга IN HIERARCHY (&qServicesList)
	|						OR (NOT &qUseServicesList))
	|					AND ВидКомиссииАгента <> &qEmptyCommissionType) AS CustomerSalesTurnovers
	|	
	|	UNION ALL
	|	
	|	SELECT
	|		CustomerSalesForecastTurnovers.Валюта,
	|		CustomerSalesForecastTurnovers.Гостиница,
	|		CustomerSalesForecastTurnovers.Агент,
	|		CustomerSalesForecastTurnovers.SalesTurnover,
	|		CustomerSalesForecastTurnovers.RoomRevenueTurnover,
	|		CustomerSalesForecastTurnovers.SalesWithoutVATTurnover,
	|		CustomerSalesForecastTurnovers.RoomRevenueWithoutVATTurnover,
	|		CustomerSalesForecastTurnovers.CommissionSumTurnover,
	|		CustomerSalesForecastTurnovers.CommissionSumWithoutVATTurnover,
	|		CustomerSalesForecastTurnovers.DiscountSumTurnover,
	|		CustomerSalesForecastTurnovers.DiscountSumWithoutVATTurnover,
	|		CustomerSalesForecastTurnovers.RoomsRentedTurnover,
	|		CustomerSalesForecastTurnovers.BedsRentedTurnover,
	|		CustomerSalesForecastTurnovers.AdditionalBedsRentedTurnover,
	|		CustomerSalesForecastTurnovers.GuestDaysTurnover,
	|		CustomerSalesForecastTurnovers.GuestsCheckedInTurnover,
	|		CustomerSalesForecastTurnovers.RoomsCheckedInTurnover,
	|		CustomerSalesForecastTurnovers.BedsCheckedInTurnover,
	|		CustomerSalesForecastTurnovers.AdditionalBedsCheckedInTurnover
	|	FROM
	|		AccumulationRegister.ПрогнозПродаж.Turnovers(
	|				&qForecastPeriodFrom,
	|				&qForecastPeriodTo,
	|				Day,
	|				Гостиница IN HIERARCHY (&qHotel)
	|					AND (Агент IN HIERARCHY (&qAgent)
	|						OR &qIsEmptyAgent)
	|					AND (Фирма IN HIERARCHY (&qCompany)
	|						OR &qIsEmptyCompany)
	|					AND (ДокОснование.Контрагент IN HIERARCHY (&qCustomer)
	|						OR &qIsEmptyCustomer)
	|					AND (ДокОснование.Договор = &qContract
	|						OR &qIsEmptyContract)
	|					AND (ДокОснование.НомерРазмещения IN HIERARCHY (&qRoom)
	|						OR &qIsEmptyRoom)
	|					AND (ДокОснование.ТипНомера IN HIERARCHY (&qRoomType)
	|						OR &qIsEmptyRoomType)
	|					AND (Услуга IN HIERARCHY (&qServicesList)
	|						OR (NOT &qUseServicesList))
	|					AND ВидКомиссииАгента <> &qEmptyCommissionType) AS CustomerSalesForecastTurnovers) AS CustomerSales
	|{WHERE
	|	CustomerSales.Валюта.*,
	|	CustomerSales.Гостиница.*,
	|	CustomerSales.Агент.*,
	|	(SUM(CustomerSales.SalesTurnover)) AS Продажи,
	|	(SUM(CustomerSales.RoomRevenueTurnover)) AS ДоходНомеров,
	|	(SUM(CustomerSales.SalesWithoutVATTurnover)) AS ПродажиБезНДС,
	|	(SUM(CustomerSales.RoomRevenueWithoutVATTurnover)) AS ДоходПродажиБезНДС,
	|	(SUM(CustomerSales.CommissionSumTurnover)) AS СуммаКомиссии,
	|	(SUM(CustomerSales.CommissionSumWithoutVATTurnover)) AS КомиссияБезНДС,
	|	(SUM(CustomerSales.DiscountSumTurnover)) AS СуммаСкидки,
	|	(SUM(CustomerSales.DiscountSumWithoutVATTurnover)) AS СуммаСкидкиБезНДС,
	|	(SUM(CustomerSales.RoomsRentedTurnover)) AS ПроданоНомеров,
	|	(SUM(CustomerSales.BedsRentedTurnover)) AS ПроданоМест,
	|	(SUM(CustomerSales.AdditionalBedsRentedTurnover)) AS ПроданоДопМест,
	|	(SUM(CustomerSales.GuestDaysTurnover)) AS ЧеловекаДни,
	|	(SUM(CustomerSales.GuestsCheckedInTurnover)) AS ЗаездГостей,
	|	(SUM(CustomerSales.RoomsCheckedInTurnover)) AS ЗаездНомеров,
	|	(SUM(CustomerSales.BedsCheckedInTurnover)) AS ЗаездМест,
	|	(SUM(CustomerSales.AdditionalBedsCheckedInTurnover)) AS ЗаездДополнительныхМест,
	|	(0) AS ВсегоНомеров,
	|	(0) AS ВсегоМест,
	|	(0) AS TotalRoomsBlocked,
	|	(0) AS TotalBedsBlocked,
	|	(0) AS TotalRoomsRentedPercent,
	|	(0) AS TotalBedsRentedPercent,
	|	(0) AS RoomRevenuePercent,
	|	(0) AS SalesPercent,
	|	(0) AS ADR,
	|	(0) AS ADBR,
	|	(0) AS ADRWithoutVAT,
	|	(0) AS ADBRWithoutVAT,
	|	(0) AS RevPAC,
	|	(0) AS RevPACWithoutVAT,
	|	(0) AS ALS,
	|	(&qEmptyString) AS ABCAnalysisGroup,
	|	(0) AS ABCAnalysisPercent}
	|
	|GROUP BY
	|	CustomerSales.Валюта,
	|	CustomerSales.Гостиница,
	|	CustomerSales.Агент
	|
	|ORDER BY
	|	CustomerSales.Валюта.ПорядокСортировки,
	|	CustomerSales.Гостиница.ПорядокСортировки,
	|	CustomerSales.Агент.Description
	|{ORDER BY
	|	Валюта.*,
	|	Гостиница.*,
	|	Агент.*,
	|	ABCAnalysisGroup,
	|	ABCAnalysisPercent,
	|	Продажи,
	|	ДоходНомеров,
	|	ПродажиБезНДС,
	|	ДоходПродажиБезНДС,
	|	СуммаКомиссии,
	|	КомиссияБезНДС,
	|	СуммаСкидки,
	|	СуммаСкидкиБезНДС,
	|	ПроданоНомеров,
	|	ПроданоМест,
	|	ПроданоДопМест,
	|	ЧеловекаДни,
	|	ЗаездГостей,
	|	ЗаездНомеров,
	|	ЗаездМест,
	|	ЗаездДополнительныхМест,
	|	ВсегоНомеров,
	|	ВсегоМест,
	|	TotalRoomsBlocked,
	|	TotalBedsBlocked,
	|	TotalRoomsRentedPercent,
	|	TotalBedsRentedPercent,
	|	RoomRevenuePercent,
	|	SalesPercent,
	|	ADR,
	|	ADBR,
	|	ADRWithoutVAT,
	|	ADBRWithoutVAT,
	|	RevPAC,
	|	RevPACWithoutVAT,
	|	ALS}
	|TOTALS
	|	SUM(Продажи),
	|	SUM(ДоходНомеров),
	|	SUM(ПродажиБезНДС),
	|	SUM(ДоходПродажиБезНДС),
	|	SUM(СуммаКомиссии),
	|	SUM(КомиссияБезНДС),
	|	SUM(СуммаСкидки),
	|	SUM(СуммаСкидкиБезНДС),
	|	SUM(ПроданоНомеров),
	|	SUM(ПроданоМест),
	|	SUM(ПроданоДопМест),
	|	SUM(ЧеловекаДни),
	|	SUM(ЗаездГостей),
	|	SUM(ЗаездНомеров),
	|	SUM(ЗаездМест),
	|	SUM(ЗаездДополнительныхМест)
	|BY
	|	OVERALL
	|{TOTALS BY
	|	CustomerSales.Валюта.*,
	|	CustomerSales.Гостиница.*,
	|	CustomerSales.Агент.*}";
	ReportBuilder.Text = QueryText;
	ReportBuilder.FillSettings();
	
	// Initialize report builder with default query
	vRB = New ReportBuilder(QueryText);
	vRBSettings = vRB.GetSettings(True, True, True, True, True);
	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
	
	// Set default report builder header text
	ReportBuilder.HeaderText = NStr("EN='Agent sales percents';RU='Проценты продаж по агентам';de='Verkaufsprozente nach Vertragspartner'");
	
	
	// Reset report builder template
	ReportBuilder.Template = Неопределено;
КонецПроцедуры //pmInitializeReportBuilder

//-----------------------------------------------------------------------------
Function pmIsResource(pName) Экспорт
	If pName = "Продажи" 
	   Or pName = "ДоходНомеров" 
	   Or pName = "ПродажиБезНДС" 
	   Or pName = "ДоходПродажиБезНДС" 
	   Or pName = "СуммаКомиссии" 
	   Or pName = "КомиссияБезНДС" 
	   Or pName = "СуммаСкидки" 
	   Or pName = "СуммаСкидкиБезНДС" 
	   Or pName = "ПроданоНомеров" 
	   Or pName = "ПроданоМест" 
	   Or pName = "ПроданоДопМест" 
	   Or pName = "ЧеловекаДни" 
	   Or pName = "ЗаездГостей" 
	   Or pName = "ЗаездНомеров" 
	   Or pName = "ЗаездМест" 
	   Or pName = "ЗаездДополнительныхМест" 
	   Or pName = "ADR"
	   Or pName = "ADRWithoutVAT"
	   Or pName = "ADBR"
	   Or pName = "ADBRWithoutVAT"
	   Or pName = "RevPAC"
	   Or pName = "RevPACWithoutVAT"
	   Or pName = "ALS"
	   Or pName = "ВсегоНомеров"
	   Or pName = "ВсегоМест"
	   Or pName = "TotalRoomsBlocked"
	   Or pName = "TotalBedsBlocked"
	   Or pName = "TotalRoomsRentedPercent"
	   Or pName = "TotalBedsRentedPercent"
	   Or pName = "RoomRevenuePercent"
	   Or pName = "BedsRentedPercent"
	   Or pName = "SalesPercent" Тогда
		Return True;
	Else
		Return False;
	EndIf;
EndFunction //pmIsResource

//-----------------------------------------------------------------------------
Function pmGetListOfABCAnalysisResources() Экспорт
	vResources = New СписокЗначений();
	vResources.Add("Продажи", NStr("en='Sales';ru='Продажи';de='Verkäufe'"));
	vResources.Add("ДоходНомеров", NStr("en='ГруппаНомеров revenue';ru='Продажи номеров';de='Zimmerverkäufe'"));
	vResources.Add("ПродажиБезНДС", NStr("en='Sales without VAT';ru='Продажи без НДС';de='Verkäufe ohne MwSt.'"));
	vResources.Add("ДоходПродажиБезНДС", NStr("en='ГруппаНомеров revenue without VAT';ru='Продажи номеров без НДС';de='Zimmerverkäufe ohne MwSt.'"));
	vResources.Add("СуммаКомиссии", NStr("en='Commission sum';ru='Сумма комиссии';de='Summe der Kommission'"));
	vResources.Add("КомиссияБезНДС", NStr("en='Commission sum without VAT';ru='Сумма комиссии без НДС';de='Kommissionssumme ohne MwSt.'"));
	vResources.Add("СуммаСкидки", NStr("en='Discount sum';ru='Сумма скидок';de='Preisnachlasssumme'"));
	vResources.Add("СуммаСкидкиБезНДС", NStr("en='Discount sum without VAT';ru='Сумма скидок без НДС';de='Preisnachlasssumme ohne MwSt.'"));
	vResources.Add("ПроданоНомеров", NStr("en='Rooms rented';ru='Продано номеродней';de='Zimmertage verkauft'"));
	vResources.Add("ПроданоМест", NStr("en='Beds rented';ru='Продано местодней';de='Verkaufte Betten pro Tag'"));
	vResources.Add("ПроданоДопМест", NStr("en='Additional beds rented';ru='Продано дополнительных местодней';de='Zusätzliche Betten nach Tagen verkauft'"));
	vResources.Add("ЧеловекаДни", NStr("en='Guest days';ru='Продано человеко-дней';de='Personen-Tag verkauft'"));
	vResources.Add("ЗаездГостей", NStr("en='Guests checked-in';ru='Заезд гостей';de='Anreise der Gäste'"));
	vResources.Add("ЗаездНомеров", NStr("en='Rooms checked-in'; ru='Заезд номеров'"));
	vResources.Add("ЗаездМест", NStr("en='Beds checked-in'; ru='Заезд мест'"));
	vResources.Add("ЗаездДополнительныхМест", NStr("en='Additional beds checked-in';ru='Заезд доп. мест';de='Anreise zusätzlicher Betten'"));
	Return vResources;
EndFunction //pmGetListOfABCAnalysisResources 

//-----------------------------------------------------------------------------
// Reports framework end
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
Процедура AddMissingPeriods(pTbl)
	If pTbl.Count() > 0 Тогда
		vLastDayRow = pTbl.Get(0);
		
		vDay = BegOfDay(vLastDayRow.Period);
		While vDay <= BegOfDay(PeriodTo) Do
			vRow = pTbl.Find(vDay, "Period");
			If vRow = Неопределено Тогда
				vRow = pTbl.Add();
				FillPropertyValues(vRow, vLastDayRow);
				vRow.Period = vDay;
			Else
				vLastDayRow = vRow;
			EndIf;
			
			vDay = vDay + 24*3600;
		EndDo;
	EndIf;
КонецПроцедуры //AddMissingPeriods
