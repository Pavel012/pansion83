Перем TotalPerDay;

//-------------------------------------------------------------------------
&НаКлиенте
Процедура CurrentDateFieldClick(pItem, pStandardProcessing)
	pStandardProcessing = False;
	GotoURL("e1cib/navigationpoint/desktop/CommonCommand.AvailableRoomsReportCommand");
КонецПроцедуры //CurrentDateFieldClick

//-------------------------------------------------------------------------
&НаКлиенте
Процедура SummaryIndexesLinkClick(pItem)
	GotoURL("e1cib/navigationpoint/desktop/CommonCommand.MainMenuSummaryIndexesCommand");
КонецПроцедуры //SummaryIndexesLinkClick

//-------------------------------------------------------------------------
&НаКлиенте
Процедура AvailableRoomsLinkClick(pItem)
	GotoURL("e1cib/navigationpoint/desktop/CommonCommand.AvailableRoomsReportCommand");
КонецПроцедуры //AvailableRoomsLinkClick

//-------------------------------------------------------------------------
&НаКлиенте
Процедура ReservationLinkClick(pItem)
	GotoURL("e1cib/navigationpoint/desktop/CommonCommand.ReservationCommand");
КонецПроцедуры //ReservationLinkClick

//-------------------------------------------------------------------------
&НаКлиенте
Процедура InvoiceLinkClick(pItem)
	GotoURL("e1cib/navigationpoint/desktop/CommonCommand.InvoiceCommand");
КонецПроцедуры //InvoiceLinkClick

//-------------------------------------------------------------------------
&НаКлиенте
Процедура ReportsLinkClick(pItem)
	GotoURL("e1cib/navigationpoint/desktop/CommonCommand.ReportsCommand");
КонецПроцедуры //ReportsLinkClick

//-------------------------------------------------------------------------
&AtServer
Процедура ПриСозданииНаСервере(pCancel, pStandardProcessing)
	
	If ЗначениеЗаполнено(ПараметрыСеанса.ТекПользователь) Тогда
		If ЗначениеЗаполнено(ПараметрыСеанса.ТекПользователь.Контрагент) Тогда
			Items.AccommodationGroup.Visible = False;
		EndIf;
	Else
		Items.AccommodationGroup.Visible = False;
	EndIf;
	CurrentDateField = CurrentSessionDate();
	If ЗначениеЗаполнено(ПараметрыСеанса.ТекущаяГостиница) Тогда
		Title = ПараметрыСеанса.ТекущаяГостиница.GetObject().pmGetHotelPrintName(ПараметрыСеанса.ТекЛокализация);
	Else
		If ЗначениеЗаполнено(ПараметрыСеанса.ТекПользователь.Контрагент) Тогда
			Title = NStr("en='Гостиница agent remote workplace';ru='Удаленное рабочее место агента';de='Gelöschter Arbeitsplatz des Agenten'");
		Else
			Title = NStr("en='Гостиница employee remote worksplace';ru='Удаленное рабочее место сотрудника отеля';de='Gelöschter Arbeitsplatz des Hotelmitarbeiters'");
		EndIf;
	EndIf;
	GetInvoiceCount();
	If ЗначениеЗаполнено(InvoiceCount) Тогда
		Items.PaymentExpired.Title = NStr("en='Payment is expired';ru='Просроченная оплата';de='überfällige Zahlung'") + " ("+String(InvoiceCount)+")";
		Items.PaymentExpired.TextColor = New Color(255, 0, 0);
	Else
		Items.PaymentExpired.Title = NStr("en='Payment is expired';ru='Просроченная оплата';de='überfällige Zahlung'");
		Items.PaymentExpired.TextColor = New Color();
	EndIf;
	GetSummaryPercent();
	Items.SummaryIndexesLink.Title = NStr("en='Summary indexes';ru='Сводные показатели';de='Gesamtindikatoren'") + " ("+String(Occupation)+"%)";
	CreateChart();
КонецПроцедуры //OnCreateAtServer

//-------------------------------------------------------------------------
&AtServer
Процедура CreateChart()
	// Get monitor template
	vTemplate = GetCommonTemplate("MonitorTemplate");
	// Get diagram
	vDiagramCDE = vTemplate.GetArea("RoomsSold|Last3Column");
	ChartDiagram = vDiagramCDE.Area("RoomsSoldMeter").Object;	
	// Get occupation percent meter
	ChartDiagram.RefreshEnabled = False;
	ChartDiagram.AutoSeriesText = False;
	ChartDiagram.AutoPointText = False;
	ChartDiagram.BorderColor = StyleColors.FormBackColor;
	ChartDiagram.Clear();
	vSeria = ChartDiagram.Series.Add(NStr("en='Occupancy %'; de='Occupancy %'; ru='% Загрузки'"));
	vPoint = ChartDiagram.Points.Add(NStr("en='By rooms sold';ru='По проданным номерам';de='Nach verkauften Zimmern'"));
	ChartDiagram.SetValue(vPoint, vSeria, Occupation);
	//ChartDiagram.RefreshEnabled = True;
КонецПроцедуры

//-------------------------------------------------------------------------------------------------
&AtServer
Процедура GetQResultTableTotals(pTbl, pTemplate, pResources)
	// Convert pTbl to the value table if necessary
	vTbl = pTbl;
	If TypeOf(pTbl) = Type("Array") Тогда                 
		vTbl = pTemplate.CopyColumns();
		For Each vRow In pTbl Do
			vTblRow = vTbl.Add();
			FillPropertyValues(vTblRow, vRow);
		EndDo;
	EndIf;
	
	If vTbl.Count() = 0 Тогда
		vTbl.Add();
	EndIf;
	
	vTbl.GroupBy(, pResources);
	TotalPerDay = vTbl.Get(0);
КонецПроцедуры //GetQResultTableTotals

//-------------------------------------------------------------------------------------------------
&AtServer
Процедура GetSummaryPercent()
	Occupation = 0;
	vBegOfPeriod = НачалоДня(ТекущаяДата());
	vEndOfPeriod = КонецДня(ТекущаяДата());
	// Initialize typesof data to show
	vInRooms = True;
	//vWithVAT = True;
	

	// Run query to get total number of rooms, rooms blocked, vacant number of rooms
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	СУММА(ЗагрузкаНомеровОстаткиИОбороты.CounterКонечныйОстаток) AS CounterClosingBalance,
	|	СУММА(ЗагрузкаНомеровОстаткиИОбороты.ВсегоНомеровРасход) AS TotalRoomsClosingBalance,
	|	СУММА(ЗагрузкаНомеровОстаткиИОбороты.ВсегоМестКонечныйОстаток) AS TotalBedsClosingBalance,
	|	-СУММА(ЗагрузкаНомеровОстаткиИОбороты.ЗаблокНомеровКонечныйОстаток) AS RoomsBlockedClosingBalance,
	|	-СУММА(ЗагрузкаНомеровОстаткиИОбороты.ЗаблокМестКонечныйОстаток) AS BedsBlockedClosingBalance
	|FROM
	|	РегистрНакопления.ЗагрузкаНомеров.ОстаткиИОбороты КАК ЗагрузкаНомеровОстаткиИОбороты";
	vQry.SetParameter("qPeriodFrom", vBegOfPeriod);
	vQry.SetParameter("qPeriodTo", vEndOfPeriod);
	vQry.SetParameter("qHotel", ПараметрыСеанса.ТекущаяГостиница);
	vQryResult = vQry.Execute().Unload();
	
	vResources = "TotalRoomsClosingBalance, TotalBedsClosingBalance, RoomsBlockedClosingBalance, BedsBlockedClosingBalance";
	GetQResultTableTotals(vQryResult, vQryResult, vResources);
	vTotalRooms = cmCastToNumber(TotalPerDay.TotalRoomsClosingBalance);
	vTotalBeds = cmCastToNumber(TotalPerDay.TotalBedsClosingBalance);	
	vBlockedRooms = cmCastToNumber(TotalPerDay.RoomsBlockedClosingBalance);
	vBlockedBeds = cmCastToNumber(TotalPerDay.BedsBlockedClosingBalance);
	vRoomsForSale = vTotalRooms - vBlockedRooms;
	vBedsForSale = vTotalBeds - vBlockedBeds;
	
	// Run query to get number of blocked rooms per ГруппаНомеров block types
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	RoomBlocksBalanceAndTurnovers.RoomBlockType AS RoomBlockType,
	|	RoomBlocksBalanceAndTurnovers.Period AS Period,
	|	SUM(RoomBlocksBalanceAndTurnovers.RoomsBlockedClosingBalance) AS RoomsBlockedClosingBalance,
	|	SUM(RoomBlocksBalanceAndTurnovers.BedsBlockedClosingBalance) AS BedsBlockedClosingBalance
	|FROM
	|	AccumulationRegister.БлокирНомеров.BalanceAndTurnovers(&qPeriodFrom, &qPeriodTo, Day, RegisterRecordsAndPeriodBoundaries, Гостиница IN HIERARCHY (&qHotel)) AS RoomBlocksBalanceAndTurnovers
	|
	|GROUP BY
	|	RoomBlocksBalanceAndTurnovers.RoomBlockType,
	|	RoomBlocksBalanceAndTurnovers.Period
	|
	|ORDER BY
	|	RoomBlocksBalanceAndTurnovers.RoomBlockType.ПорядокСортировки,
	|	Period";
	vQry.SetParameter("qPeriodFrom", vBegOfPeriod);
	vQry.SetParameter("qPeriodTo", vEndOfPeriod);
	vQry.SetParameter("qHotel", ПараметрыСеанса.ТекущаяГостиница);
	vQryResult = vQry.Execute().Unload();
	
	// Get list of ГруппаНомеров block types
	vSpecRoomsBlocked = 0;
	vSpecBedsBlocked = 0;
	vRoomBlockTypes = vQryResult.Copy();
	vRoomBlockTypes.GroupBy("RoomBlockType", );
	If vQryResult.Count()>0 Тогда
		// Put ГруппаНомеров blocks per ГруппаНомеров block type
		For Each vRow In vRoomBlockTypes Do
			vRoomBlockType = vRow.RoomBlockType;
			
			// Get records for the current ГруппаНомеров block type only
			vQrySubresult = vQryResult.FindRows(New Structure("RoomBlockType", vRoomBlockType));
			GetQResultTableTotals(vQrySubresult, vQryResult, "RoomsBlockedClosingBalance, BedsBlockedClosingBalance");
			
			If vInRooms Тогда
				vBlockedRooms = cmCastToNumber(TotalPerDay.RoomsBlockedClosingBalance);					
				If vRoomBlockType.AddToRoomsRentedInSummaryIndexes Тогда
					vSpecRoomsBlocked = vSpecRoomsBlocked + cmCastToNumber(TotalPerDay.RoomsBlockedClosingBalance);
				EndIf;
			Else
				vBlockedBeds = cmCastToNumber(TotalPerDay.BedsBlockedClosingBalance);				
				If vRoomBlockType.AddToRoomsRentedInSummaryIndexes Тогда
					vSpecBedsBlocked = vSpecBedsBlocked + cmCastToNumber(TotalPerDay.BedsBlockedClosingBalance);
				EndIf;
			EndIf;
		EndDo;
	EndIf;	
	// Run query to get ГруппаНомеров sales
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	ОборотыПродажиНомеров.Period AS Period,
	|	ОборотыПродажиНомеров.Тариф.IsComplimentary AS RoomRateIsComplimentary,
	|	SUM(ОборотыПродажиНомеров.SalesTurnover) AS SalesTurnover,
	|	SUM(ОборотыПродажиНомеров.SalesWithoutVATTurnover) AS SalesWithoutVATTurnover,
	|	SUM(ОборотыПродажиНомеров.RoomRevenueTurnover) AS RoomRevenueTurnover,
	|	SUM(ОборотыПродажиНомеров.RoomRevenueWithoutVATTurnover) AS RoomRevenueWithoutVATTurnover,
	|	SUM(ОборотыПродажиНомеров.RoomsRentedTurnover) AS RoomsRentedTurnover,
	|	SUM(ОборотыПродажиНомеров.BedsRentedTurnover) AS BedsRentedTurnover
	|FROM
	|	AccumulationRegister.Продажи.Turnovers(&qPeriodFrom, &qPeriodTo, Day, Гостиница IN HIERARCHY (&qHotel)) AS ОборотыПродажиНомеров
	|GROUP BY
	|	ОборотыПродажиНомеров.Period,
	|	ОборотыПродажиНомеров.Тариф.IsComplimentary
	|ORDER BY
	|	Period,
	|	RoomRateIsComplimentary";
	vQry.SetParameter("qPeriodFrom", vBegOfPeriod);
	vQry.SetParameter("qPeriodTo", vEndOfPeriod);
	vQry.SetParameter("qHotel", ПараметрыСеанса.ТекущаяГостиница);
	vQryResult = vQry.Execute().Unload();
	
	// Add forecast sales if period is set in the future
	If vEndOfPeriod >= EndOfDay(CurrentDate()) Тогда
		vQry = New Query();
		vQry.Text = 
		"SELECT
		|	RoomSalesForecastTurnovers.Period AS Period,
		|	RoomSalesForecastTurnovers.Тариф.IsComplimentary AS RoomRateIsComplimentary,
		|	SUM(RoomSalesForecastTurnovers.SalesTurnover) AS SalesTurnover,
		|	SUM(RoomSalesForecastTurnovers.SalesWithoutVATTurnover) AS SalesWithoutVATTurnover,
		|	SUM(RoomSalesForecastTurnovers.RoomRevenueTurnover) AS RoomRevenueTurnover,
		|	SUM(RoomSalesForecastTurnovers.RoomRevenueWithoutVATTurnover) AS RoomRevenueWithoutVATTurnover,
		|	SUM(RoomSalesForecastTurnovers.RoomsRentedTurnover) AS RoomsRentedTurnover,
		|	SUM(RoomSalesForecastTurnovers.BedsRentedTurnover) AS BedsRentedTurnover
		|FROM
		|	AccumulationRegister.ПрогнозПродаж.Turnovers(&qPeriodFrom, &qPeriodTo, Day, Гостиница IN HIERARCHY (&qHotel)) AS RoomSalesForecastTurnovers
		|GROUP BY
		|	RoomSalesForecastTurnovers.Period,
		|	RoomSalesForecastTurnovers.Тариф.IsComplimentary
		|ORDER BY
		|	Period,
		|	RoomRateIsComplimentary";
		vQry.SetParameter("qPeriodFrom", vBegOfPeriod);
		vQry.SetParameter("qPeriodTo", vEndOfPeriod);
		vQry.SetParameter("qHotel", ПараметрыСеанса.ТекущаяГостиница);
		vForecastQryResult = vQry.Execute().Unload();
		
		// Merge forecast sales with real ones
		For Each vForecastRow In vForecastQryResult Do
			vFound = False;
			For Each vRow In vQryResult Do
				If vRow.Period = vForecastRow.Period And
					vRow.RoomRateIsComplimentary = vForecastRow.RoomRateIsComplimentary Тогда
					vFound = True;
					Break;
				EndIf;
			EndDo;
			If НЕ vFound Тогда
				vRow = vQryResult.Add();
				vRow.Period = vForecastRow.Period;
				vRow.RoomRateIsComplimentary = vForecastRow.RoomRateIsComplimentary;
				vRow.SalesTurnover = 0;
				vRow.SalesWithoutVATTurnover = 0;
				vRow.RoomRevenueTurnover = 0;
				vRow.RoomRevenueWithoutVATTurnover = 0;
				vRow.RoomsRentedTurnover = 0;
				vRow.BedsRentedTurnover = 0;
			EndIf;
			vRow.SalesTurnover = vRow.SalesTurnover + vForecastRow.SalesTurnover;
			vRow.SalesWithoutVATTurnover = vRow.SalesWithoutVATTurnover + vForecastRow.SalesWithoutVATTurnover;
			vRow.RoomRevenueTurnover = vRow.RoomRevenueTurnover + vForecastRow.RoomRevenueTurnover;
			vRow.RoomRevenueWithoutVATTurnover = vRow.RoomRevenueWithoutVATTurnover + vForecastRow.RoomRevenueWithoutVATTurnover;
			vRow.RoomsRentedTurnover = vRow.RoomsRentedTurnover + vForecastRow.RoomsRentedTurnover;
			vRow.BedsRentedTurnover = vRow.BedsRentedTurnover + vForecastRow.BedsRentedTurnover;
		EndDo;
	EndIf;	
	
	vResources = "SalesTurnover, SalesWithoutVATTurnover, RoomRevenueTurnover, RoomRevenueWithoutVATTurnover, RoomsRentedTurnover, BedsRentedTurnover";
	
	// Split table to total and complimentary only
	vQryResultComplArray = vQryResult.Copy().FindRows(New Structure("RoomRateIsComplimentary", True));
	vQryResult.GroupBy("Period", vResources);
	vQryResultCompl = vQryResult.CopyColumns();
	For Each vRow In vQryResultComplArray Do
		vTabRow = vQryResultCompl.Add();
		FillPropertyValues(vTabRow, vRow);
	EndDo;
	vQryResultCompl.GroupBy("Period", vResources);
	
	// Put rooms rented
	GetQResultTableTotals(vQryResult, vQryResult, vResources);
	If vInRooms Тогда
		vRoomsRented = cmCastToNumber(TotalPerDay.RoomsRentedTurnover);
	Else
		vBedsRented = cmCastToNumber(TotalPerDay.BedsRentedTurnover);
	EndIf;	
	// Put occupation percents	
	If vInRooms Тогда
		Occupation = Round(?((vRoomsForSale + vSpecRoomsBlocked) <> 0, 100*(vRoomsRented + vSpecRoomsBlocked)/(vRoomsForSale + vSpecRoomsBlocked), 0), 2);
	Else
		Occupation = Round(?((vBedsForSale + vSpecBedsBlocked) <> 0, 100*(vBedsRented + vSpecBedsBlocked)/(vBedsForSale + vSpecBedsBlocked), 0), 2);
	EndIf;
КонецПроцедуры //GetSummaryPercent

//-----------------------------------------------------------------------------
&AtServer
Процедура GetInvoiceCount() 
	vQry = Новый Query;
	vQry.Text =
	"ВЫБРАТЬ
	|	КОЛИЧЕСТВО(СчетНаОплату.Ссылка) AS СчетНаОплату
	|ИЗ
	|	Document.СчетНаОплату AS DocumentInvoice
	|		LEFT JOIN AccumulationRegister.ВзаиморасчетыПоСчетам.Balance(&qDate,) AS InvoiceAccountsBalance
	|		ON (InvoiceAccountsBalance.СчетНаОплату = DocumentInvoice.Ref)
	|ГДЕ
	|	ВЫБОР
	|		КОГДА DocumentInvoice.Posted
	|			ТОГДА ВЫБОР
	|				КОГДА DocumentInvoice.CheckDate <> &qEmptyDate
	|				И НАЧАЛОПЕРИОДА(DocumentInvoice.CheckDate, DAY) < НАЧАЛОПЕРИОДА(&qCurrentDate, DAY)
	|				И ЕСТЬNULL(СчетНаОплату.Сумма, 0) - ЕСТЬNULL(InvoiceAccountsBalance.СуммаОстаток, 0) = 0
	|					ТОГДА 6
	|				ИНАЧЕ ВЫБОР
	|					КОГДА ЕСТЬNULL(DocumentInvoice.Сумма, 0) - ЕСТЬNULL(InvoiceAccountsBalance.СуммаОстаток,
	|						0) >= DocumentInvoice.Сумма
	|						ТОГДА 5
	|					ИНАЧЕ ВЫБОР
	|						КОГДА ЕСТЬNULL(DocumentInvoice.Сумма, 0) - ЕСТЬNULL(InvoiceAccountsBalance.СуммаОстаток, 0) > 0
	|							ТОГДА 3
	|						ИНАЧЕ 1
	|					КОНЕЦ
	|				КОНЕЦ
	|			КОНЕЦ
	|		ИНАЧЕ 0
	|	КОНЕЦ В (&qPayedStatus)
	|	AND DocumentInvoice.Гостиница В ИЕРАРХИИ (&qHotel)";
	If ЗначениеЗаполнено(ПараметрыСеанса.ТекПользователь.Контрагент) Тогда
		vQry.Text = vQry.Text + " AND DocumentInvoice.Контрагент IN HIERARCHY (&qCustomer) ";
		vQry.SetParameter("qCustomer", ПараметрыСеанса.ТекПользователь.Контрагент);
	EndIf;
	vQry.SetParameter("qHotel", ПараметрыСеанса.ТекущаяГостиница);
	vQry.SetParameter("qDate", '39991231235959');
	vQry.SetParameter("qPayedStatus", 6);
	vQry.SetParameter("qEmptyDate", '00010101');
	vQry.SetParameter("qCurrentDate", CurrentDate());
	vResultQry = vQry.Выполнить().Выгрузить();
	InvoiceCount = 0;
	While vResultQry.Next() Do
		InvoiceCount = vResultQry.Количество();
	EndDo;
КонецПроцедуры //GetInvoiceCount

//-------------------------------------------------------------------------
&НаКлиенте
Процедура HotelChoiceClick(pItem)
	OpenForm("Catalog.Гостиницы.ФормаВыбора", , ЭтаФорма);
КонецПроцедуры //HotelChoiceClick

//-------------------------------------------------------------------------
&НаКлиенте
Процедура ChoiceProcessing(pSelectedValue, pChoiceSource)
	If ЗначениеЗаполнено(pSelectedValue) And TypeOf(pSelectedValue) = Type("CatalogRef.Гостиницы") Тогда
		Title = УпрСерверныеФункции.cmChangeCurrentHotel(pSelectedValue);
		GetInvoiceCount();
		If ЗначениеЗаполнено(InvoiceCount) Тогда
			Items.PaymentExpired.Title = NStr("en='Payment is expired';ru='Просроченная оплата';de='überfällige Zahlung'") + " ("+String(InvoiceCount)+")";
			Items.PaymentExpired.TextColor = New Color(255, 0, 0);
		Else
			Items.PaymentExpired.Title = NStr("en='Payment is expired';ru='Просроченная оплата';de='überfällige Zahlung'");
			Items.PaymentExpired.TextColor = New Color();
		EndIf;
		GetSummaryPercent();
		Items.SummaryIndexesLink.Title = NStr("en='Summary indexes';ru='Сводные показатели';de='Gesamtindikatoren'") + " ("+String(Occupation)+"%)";
	EndIf;
КонецПроцедуры //ChoiceProcessing

//-------------------------------------------------------------------------
&НаКлиенте
Function GetMainWindow()
	vWindows = GetWindows();
	vMainWindow = Неопределено;
	For Each vWindow In vWindows Do
		If vWindow.IsMain Тогда
			vMainWindow = vWindow;
			Break;
		EndIf;
	EndDo;
	Return vMainWindow;
EndFunction //GetMainWindow

//-------------------------------------------------------------------------
&НаКлиенте
Процедура CheckInTodayClick(pItem)
	GotoURL("e1cib/navigationpoint/desktop/CommonCommand.ReservationCommand");
	vFrm = ПолучитьФорму("Document.Бронирование.ФормаСписка", , Неопределено, "tcReservationsListForm", GetMainWindow());
	vFrm.SelCheckInDate = BegOfDay(CurrentDate());
	vFrm.GetParam("CheckInDate", vFrm.SelCheckInDate);
	vFrm.ShowList(vFrm.Items.ShowListHeader);
КонецПроцедуры //CheckInTomorrowClick

//-------------------------------------------------------------------------
&НаКлиенте
Процедура MyCreatedTodayClick(pItem)
	GotoURL("e1cib/navigationpoint/desktop/CommonCommand.ReservationCommand");
	vFrm = ПолучитьФорму("Document.Бронирование.ФормаСписка", , Неопределено, "tcReservationsListForm", GetMainWindow());
	vFrm.SelCheckInDate = '00010101';
	vFrm.GetParam("CheckInDate", vFrm.SelCheckInDate);
	vFrm.SelCreatePeriodFrom = BegOfDay(CurrentDate());
	vFrm.GetParam("CreatePeriodFrom", vFrm.SelCreatePeriodFrom);
	vFrm.SelCreatePeriodTo = EndOfDay(CurrentDate());
	vFrm.GetParam("CreatePeriodTo", vFrm.SelCreatePeriodTo);
	vFrm.SelAuthor = УпрСерверныеФункции.cmGetCurrentUserAttribute();
	vFrm.GetParam("Автор", vFrm.SelAuthor);
	vFrm.SelReservationStatusesStr = "";
	vFrm.GetParam("ReservationStatus", УпрСерверныеФункции.cmGetCatalogItemRefByCode("СтатусБрони", "", True));
	vFrm.ShowList(vFrm.Items.ShowListHeader);
КонецПроцедуры //MyCreatedTodayClick

//-------------------------------------------------------------------------
&НаКлиенте
Процедура PaymentExpiredClick(pItem)
	GotoURL("e1cib/navigationpoint/desktop/CommonCommand.InvoiceCommand");
	vFrm = ПолучитьФорму("Document.СчетНаОплату.ФормаСписка", , Неопределено, "tcInvoicesListForm", GetMainWindow());
	vFrm.PayTypes = vFrm.Items.PayTypes.ChoiceList.FindByValue("6").Presentation;
	vFrm.PayTypesNumber = "6";
	vFrm.OnOpenForm();
КонецПроцедуры //PaymentExpiredClick

//-------------------------------------------------------------------------
&НаКлиенте
Процедура NewReservationClick(pItem)
	#If НЕ WebClient Тогда
		Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 10, NStr("en='Opening...';ru='Открытие формы...';de='Öffnen des Formulars...'"), PictureLib.LongOperation); 
	#EndIf
	vDocFormParameters = New Structure;
	vDocFormParameters.Вставить("Document", УпрСерверныеФункции.cmGetDocumentItemRefByDocNumber("Бронирование", "", True) );
	vFrm = ПолучитьФорму("Document.Бронирование.ObjectForm", vDocFormParameters, ЭтаФорма);
	#If НЕ WebClient Тогда
		Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 30, NStr("en='Opening...';ru='Открытие формы...';de='Öffnen des Formulars...'"), PictureLib.LongOperation); 
	#EndIf
	vFrm.Open();
КонецПроцедуры //NewReservationClick

//-------------------------------------------------------------------------
&НаКлиенте
Процедура NewInvoiceClick(pItem)
	OpenForm("Document.СчетНаОплату.ObjectForm");
КонецПроцедуры //NewInvoiceClick

//-------------------------------------------------------------------------
&НаКлиенте
Процедура RoomsGanttChartClick(pItem)
	#If НЕ WebClient Тогда
		Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 10, NStr("en='Building chart...';ru='Заполнение диаграммы...';de='Ausfüllen des Diagramms…'"), PictureLib.LongOperation);
	#EndIf
	
	OpenForm("CommonForm.упрКартаНомерногоФонда");
	
	#If НЕ WebClient Тогда
		Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 100, NStr("en='Building chart...';ru='Заполнение диаграммы...';de='Ausfüllen des Diagramms…'"), PictureLib.LongOperation);
	#EndIf
КонецПроцедуры //RoomsGanttChartClick

//-------------------------------------------------------------------------
&НаКлиенте
Процедура ManualPostingsClick(pItem)
	GotoURL("e1cib/navigationpoint/desktop/CommonCommand.ManualPostings");
КонецПроцедуры //ManualPostingsClick

//-------------------------------------------------------------------------
&НаКлиенте
Процедура NewAccommodationClick(pItem)
	#If НЕ WebClient Тогда
		Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 10, NStr("en='Opening...';ru='Открытие формы...';de='Öffnen des Formulars...'"), PictureLib.LongOperation); 
	#EndIf
	vFrm = ПолучитьФорму("Document.Размещение.ObjectForm", , ЭтаФорма);
	#If НЕ WebClient Тогда
		Status(NStr("en='Wait...';ru='Подождите...';de='Bitte warten...'"), 30, NStr("en='Opening...';ru='Открытие формы...';de='Öffnen des Formulars...'"), PictureLib.LongOperation); 
	#EndIf
	vFrm.Open();
КонецПроцедуры //NewAccommodationClick

//-------------------------------------------------------------------------
&НаКлиенте
Процедура InHouseGuestsLinkClick(Item)
	GotoURL("e1cib/navigationpoint/desktop/CommonCommand.AccommodationCommand");
	vFrm = ПолучитьФорму("Document.Размещение.ФормаСписка", , Неопределено, "tcAccommodationsListForm", GetMainWindow());
	vFrm.SelAccommodationStatusesStr = NStr("en='In-house guests';ru='Проживающие гости';de='Hotelgäste'");
	vFrm.GetParam("СтатусРазмещения", vFrm.SelAccommodationStatusesStr);
	vFrm.ShowList(vFrm.Items.ShowListHeader);
КонецПроцедуры

//-------------------------------------------------------------------------
&НаКлиенте
Процедура AccommodationArchiveLinkClick(Item)
	GotoURL("e1cib/navigationpoint/desktop/CommonCommand.AccommodationCommand");
	vFrm = ПолучитьФорму("Document.Размещение.ФормаСписка", , Неопределено, "tcAccommodationsListForm", GetMainWindow());
	vFrm.SelAccommodationStatusesStr = NStr("en='Archive';ru='Архив';de='Archiv'");
	vFrm.GetParam("СтатусРазмещения", vFrm.SelAccommodationStatusesStr);
КонецПроцедуры
