//-----------------------------------------------------------------------------
// Gets list of reservations for this group
// Returns ValueTable
//-----------------------------------------------------------------------------
Function pmGetReservations(pPostedOnly = True, pActiveOnly = False, pCancelledOnly = False, pInWaitingListOnly = False, pDocRef = Неопределено, pDocsList = Неопределено) Экспорт 
	If pPostedOnly = Неопределено Тогда
		pPostedOnly = True;
	EndIf;
	vUseDocsList = False;
	If pDocsList <> Неопределено Тогда
		vUseDocsList = True;
	EndIf;
	// Build and run query
	vQry = New Query;
	vQry.Text = 
	"SELECT
	|	Бронирование.Ref AS Бронирование,
	|	Бронирование.ДатаДок AS Date,
	|	Бронирование.НомерДока AS Number,
	|	Бронирование.Posted AS Posted,
	|	Бронирование.DeletionMark AS DeletionMark,
	|	Бронирование.IsMaster AS IsMaster,
	|	Бронирование.ReservationStatus AS Status,
	|	Бронирование.CheckInDate AS CheckInDate,
	|	Бронирование.Продолжительность AS Продолжительность,
	|	Бронирование.ДатаВыезда AS ДатаВыезда,
	|	Бронирование.Клиент AS Клиент,
	|	Бронирование.НомерРазмещения AS НомерРазмещения,
	|	Бронирование.ТипНомера AS ТипНомера,
	|	Бронирование.RoomQuantity AS RoomQuantity,
	|	Бронирование.КоличествоЧеловек AS КоличествоЧеловек,
	|	Бронирование.ВидРазмещения AS ВидРазмещения,
	|	Бронирование.ВидРазмещения.ПорядокСортировки AS AccommodationTypeSortCode,
	|	Бронирование.Тариф AS Тариф,
	|	Бронирование.RoomRateServiceGroup AS RoomRateServiceGroup,
	|	Бронирование.ServicePackage AS ServicePackage,
	|	Бронирование.ПутевкаКурсовка AS ПутевкаКурсовка,
	|	Бронирование.Фирма AS Фирма,
	|	Бронирование.КоличествоНомеров AS КоличествоНомеров,
	|	Бронирование.КоличествоМест AS КоличествоМест,
	|	Бронирование.КолДопМест AS КолДопМест,
	|	Бронирование.КоличествоМестНомер AS КоличествоМестНомер,
	|	Бронирование.КоличествоГостейНомер AS КоличествоГостейНомер,
	|	Бронирование.ДокОснование AS ДокОснование,
	|	Бронирование.Примечания AS Примечания,
	|	ISNULL(Бронирование.НомерРазмещения.ПорядокСортировки, 0) AS RoomSortCode,
	|	ISNULL(Бронирование.ТипНомера.ПорядокСортировки, 0) AS RoomTypeSortCode,
	|	Бронирование.PointInTime AS PointInTime
	|FROM
	|	Document.Бронирование AS Бронирование
	|WHERE
	|	Бронирование.ГруппаГостей = &qGuestGroup
	|	AND (Бронирование.Posted
	|			OR &qAll)" + 
		?(ЗначениеЗаполнено(pDocRef), " AND Бронирование.Ref = &qDocRef ", "") + 
		?(vUseDocsList, " AND Бронирование.Ref IN (&qDocsList) ", "") + 
		?(pActiveOnly, " AND Бронирование.Posted AND (Бронирование.ReservationStatus.IsActive OR Бронирование.ReservationStatus.ЭтоЗаезд OR Бронирование.ReservationStatus.IsPreliminary) ", "") + 
		?(pCancelledOnly, " AND Бронирование.Posted AND NOT Бронирование.ReservationStatus.IsActive AND NOT Бронирование.ReservationStatus.ЭтоЗаезд AND NOT Бронирование.ReservationStatus.IsPreliminary ", "") + 
		?(pInWaitingListOnly, " AND Бронирование.Posted AND Бронирование.ReservationStatus.IsInWaitingList AND NOT Бронирование.ReservationStatus.ЭтоЗаезд AND NOT Бронирование.ReservationStatus.IsPreliminary ", "") + "
	|
	|ORDER BY
	|	RoomSortCode,
	|	RoomTypeSortCode,
	|	Number,
	|	CheckInDate,
	|	AccommodationTypeSortCode,
	|	Date,
	|	PointInTime";
	vQry.SetParameter("qGuestGroup", Ref);
	vQry.SetParameter("qAll", ?(ЗначениеЗаполнено(pDocRef), True, (НЕ pPostedOnly)));
	vQry.SetParameter("qDocRef", pDocRef);
	vQry.SetParameter("qDocsList", pDocsList);
	vDocs = vQry.Execute().Unload();
	Return vDocs;
EndFunction //pmGetReservations

//-----------------------------------------------------------------------------
// Gets list of accommodations for this group
// Returns ValueTable
//-----------------------------------------------------------------------------
Function pmGetAccommodations(pPostedOnly = True, pDocsList = Неопределено) Экспорт 
	If pPostedOnly = Неопределено Тогда
		pPostedOnly = True;
	EndIf;
	vUseDocsList = False;
	If pDocsList <> Неопределено Тогда
		vUseDocsList = True;
	EndIf;
	// Build and run query
	vQry = New Query;
	vQry.Text = 
	"SELECT
	|	Размещение.Ref AS Размещение,
	|	Размещение.ДатаДок AS Date,
	|	Размещение.НомерДока AS Number,
	|	Размещение.Posted AS Posted,
	|	Размещение.DeletionMark AS DeletionMark,
	|	Размещение.IsMaster AS IsMaster,
	|	Размещение.PayerAccommodation AS PayerAccommodation,
	|	Размещение.СтатусРазмещения AS Status,
	|	Размещение.CheckInDate AS CheckInDate,
	|	Размещение.Продолжительность AS Продолжительность,
	|	Размещение.ДатаВыезда AS ДатаВыезда,
	|	Размещение.Клиент AS Клиент,
	|	Размещение.НомерРазмещения AS НомерРазмещения,
	|	Размещение.ТипНомера AS ТипНомера,
	|	Размещение.КоличествоЧеловек AS КоличествоЧеловек,
	|	Размещение.ВидРазмещения AS ВидРазмещения,
	|	Размещение.ВидРазмещения.ПорядокСортировки AS AccommodationTypeSortCode,
	|	Размещение.Тариф AS Тариф,
	|	Размещение.RoomRateServiceGroup AS RoomRateServiceGroup,
	|	Размещение.ServicePackage AS ServicePackage,
	|	Размещение.ПутевкаКурсовка AS ПутевкаКурсовка,
	|	Размещение.Фирма AS Фирма,
	|	Размещение.КоличествоНомеров AS КоличествоНомеров,
	|	Размещение.КоличествоМест AS КоличествоМест,
	|	Размещение.КолДопМест AS КолДопМест,
	|	Размещение.КоличествоМестНомер AS КоличествоМестНомер,
	|	Размещение.КоличествоГостейНомер AS КоличествоГостейНомер,
	|	Размещение.ДокументОснование AS ДокОснование,
	|	Размещение.Примечания AS Примечания,
	|	ISNULL(Размещение.НомерРазмещения.ПорядокСортировки, 0) AS RoomSortCode,
	|	Размещение.PointInTime AS PointInTime
	|FROM
	|	Document.Размещение AS Размещение
	|WHERE
	|	Размещение.ГруппаГостей = &qGuestGroup
	|	AND (Размещение.Posted
	|			OR &qAll)
	|	AND (ISNULL(Размещение.СтатусРазмещения.Действует, FALSE)
	|			OR &qAll)" + 
		?(vUseDocsList, " AND Размещение.Ref IN (&qDocsList) ", "") + "
	|ORDER BY
	|	RoomSortCode,
	|	CheckInDate,
	|	AccommodationTypeSortCode,
	|	Number,
	|	Date,
	|	PointInTime";
	vQry.SetParameter("qGuestGroup", Ref);
	vQry.SetParameter("qAll", (НЕ pPostedOnly));
	vQry.SetParameter("qDocsList", pDocsList);
	vDocs = vQry.Execute().Unload();
	Return vDocs;
EndFunction //pmGetAccommodations

//-----------------------------------------------------------------------------
// Gets list of invoices with balances for this group
// Returns ValueTable
//-----------------------------------------------------------------------------
Function pmGetInvoices(pCustomer = Неопределено, pContract = Неопределено) Экспорт 
	// Build and run query
	vQry = New Query;
	vQry.Text = 
	"SELECT
	|	Invoices.Ref AS СчетНаОплату,
	|	Invoices.Posted AS Posted,
	|	Invoices.НомерДока AS InvoiceNumber,
	|	Invoices.ДатаДок AS InvoiceDate,
	|	Invoices.Фирма AS Фирма,
	|	Invoices.Контрагент AS Контрагент,
	|	Invoices.Договор AS Договор,
	|	Invoices.ГруппаГостей AS ГруппаГостей,
	|	Invoices.Сумма AS Сумма,
	|	Invoices.СуммаНДС AS СуммаНДС,
	|	Invoices.ВалютаРасчетов AS Валюта,
	|	Invoices.Примечания AS Примечания,
	|	Invoices.Автор AS Автор,
	|	ISNULL(InvoiceAccountsBalance.SumBalance, 0) AS Balance,
	|	Invoices.CheckDate AS CheckDate,
	|	Invoices.PointInTime AS PointInTime,
	|	Invoices.Presentation AS Presentation
	|FROM
	|	Document.СчетНаОплату AS Invoices
	|		LEFT JOIN (SELECT
	|			ВзаиморасчетыПоСчетам.СчетНаОплату AS СчетНаОплату,
	|			ВзаиморасчетыПоСчетам.SumBalance AS SumBalance
	|		FROM
	|			AccumulationRegister.ВзаиморасчетыПоСчетам.Balance(&qPeriod, ГруппаГостей = &qGuestGroup) AS ВзаиморасчетыПоСчетам) AS InvoiceAccountsBalance
	|		ON Invoices.Ref = InvoiceAccountsBalance.СчетНаОплату
	|WHERE
	|	Invoices.ГруппаГостей = &qGuestGroup
	|	AND (Invoices.Контрагент = &qCustomer
	|			OR &qCustomerIsEmpty)
	|	AND (Invoices.Договор = &qContract
	|			OR &qContractIsEmpty)
	|	AND Invoices.Posted
	|
	|ORDER BY
	|	Invoices.PointInTime";
	vQry.SetParameter("qPeriod", '39991231235959');
	vQry.SetParameter("qGuestGroup", Ref);
	vQry.SetParameter("qCustomer", ?(ЗначениеЗаполнено(pCustomer), pCustomer, Owner.IndividualsCustomer));
	vQry.SetParameter("qCustomerIsEmpty", ?(pCustomer = Неопределено, True, False));
	vQry.SetParameter("qContract", ?(ЗначениеЗаполнено(pCustomer), pContract, Owner.IndividualsContract));
	vQry.SetParameter("qContractIsEmpty", ?(pContract = Неопределено, True, False));
	vDocs = vQry.Execute().Unload();
	Return vDocs;
EndFunction //pmGetInvoices

//-----------------------------------------------------------------------------
// Gets list of settlemets for this group
// Returns ValueTable
//-----------------------------------------------------------------------------
Function pmGetSettlements() Экспорт
	// Build and run query
	vQry = New Query;
	vQry.Text = 
	"SELECT
	|	Settlements.Ref AS СчетНаОплату,
	|	Settlements.Posted AS Posted,
	|	Settlements.НомерДока AS InvoiceNumber,
	|	Settlements.ДатаДок AS InvoiceDate,
	|	Settlements.Фирма AS Фирма,
	|	Settlements.Контрагент AS Контрагент,
	|	Settlements.Договор AS Договор,
	|	Settlements.ГруппаГостей AS ГруппаГостей,
	|	Settlements.Сумма AS Сумма,
	|	Settlements.СуммаНДС AS СуммаНДС,
	|	Settlements.ВалютаРасчетов AS Валюта,
	|	Settlements.Примечания AS Примечания,
	|	Settlements.Автор AS Автор,
	|	0 AS Balance,
	|	Settlements.PointInTime AS PointInTime,
	|	Settlements.Presentation AS Presentation
	|FROM
	|	Document.Акт AS Settlements
	|WHERE
	|	Settlements.ГруппаГостей = &qGuestGroup
	|	AND Settlements.Posted
	|ORDER BY
	|	Settlements.PointInTime";
	vQry.SetParameter("qPeriod", '39991231235959');
	vQry.SetParameter("qGuestGroup", Ref);
	vSettlements = vQry.Execute().Unload();
	Return vSettlements;
EndFunction //pmGetSettlements

//-----------------------------------------------------------------------------
// Gets list of resource reservations for this group
// Returns ValueTable
//-----------------------------------------------------------------------------
Function pmGetResourceReservations(pPostedOnly = True) Экспорт 
	If pPostedOnly = Неопределено Тогда
		pPostedOnly = True;
	EndIf;
	// Build and run query
	vQry = New Query;
	vQry.Text = 
	"SELECT
	|	БроньУслуг.Ref AS Бронирование,
	|	БроньУслуг.Posted AS Posted,
	|	БроньУслуг.DeletionMark AS DeletionMark,
	|	БроньУслуг.ResourceReservationStatus AS Status,
	|	БроньУслуг.DateTimeFrom AS DateTimeFrom,
	|	БроньУслуг.Продолжительность AS Продолжительность,
	|	БроньУслуг.DateTimeTo AS DateTimeTo,
	|	БроньУслуг.Клиент AS Клиент,
	|	БроньУслуг.Ресурс AS Ресурс,
	|	БроньУслуг.ТипРесурса AS ТипРесурса,
	|	БроньУслуг.КоличествоЧеловек AS КоличествоЧеловек,
	|	БроньУслуг.ДокОснование AS ДокОснование
	|FROM
	|	Document.БроньУслуг AS БроньУслуг
	|WHERE
	|	БроньУслуг.ГруппаГостей = &qGuestGroup
	|	AND (БроньУслуг.Posted
	|			OR &qAll)
	|
	|ORDER BY
	|	БроньУслуг.PointInTime";
	vQry.SetParameter("qGuestGroup", Ref);
	vQry.SetParameter("qAll", (НЕ pPostedOnly));
	vDocs = vQry.Execute().Unload();
	Return vDocs;
EndFunction //pmGetResourceReservations

//-----------------------------------------------------------------------------
Function pmGetRoomInventoryTotals(pCheckInDate = '00010101') Экспорт
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	GroupTotals.ГруппаГостей,
	|	SUM(GroupTotals.ExpectedRoomsCheckedIn + GroupTotals.ЗаездНомеров) AS ЗабронНомеров,
	|	SUM(GroupTotals.ПланЗаездМест + GroupTotals.ЗаездМест) AS ЗабронированоМест,
	|	SUM(GroupTotals.ПланЗаездДопМест + GroupTotals.ЗаездДополнительныхМест) AS ЗабронДопМест,
	|	SUM(GroupTotals.ExpectedGuestsCheckedIn + GroupTotals.ЗаездГостей) AS ЗабронГостей,
	|	SUM(GroupTotals.ЗаездНомеров) AS ЗаездНомеров,
	|	SUM(GroupTotals.ЗаездМест) AS ЗаездМест,
	|	SUM(GroupTotals.ЗаездДополнительныхМест) AS ЗаездДополнительныхМест,
	|	SUM(GroupTotals.ЗаездГостей) AS ЗаездГостей,
	|	SUM(GroupTotals.ExpectedRoomsCheckedIn) AS RoomsExpected,
	|	SUM(GroupTotals.ПланЗаездМест) AS BedsExpected,
	|	SUM(GroupTotals.ПланЗаездДопМест) AS AdditionalBedsExpected,
	|	SUM(GroupTotals.ExpectedGuestsCheckedIn) AS GuestsExpected
	|FROM
	|	(SELECT
	|		ЗагрузкаНомеров.ГруппаГостей AS ГруппаГостей,
	|		ЗагрузкаНомеров.ExpectedRoomsCheckedIn AS ExpectedRoomsCheckedIn,
	|		ЗагрузкаНомеров.ПланЗаездМест AS ПланЗаездМест,
	|		ЗагрузкаНомеров.ПланЗаездДопМест AS ПланЗаездДопМест,
	|		ЗагрузкаНомеров.ExpectedGuestsCheckedIn AS ExpectedGuestsCheckedIn,
	|		ЗагрузкаНомеров.ЗаездНомеров AS ЗаездНомеров,
	|		ЗагрузкаНомеров.ЗаездМест AS ЗаездМест,
	|		ЗагрузкаНомеров.ЗаездДополнительныхМест AS ЗаездДополнительныхМест,
	|		ЗагрузкаНомеров.ЗаездГостей AS ЗаездГостей
	|	FROM
	|		AccumulationRegister.ЗагрузкаНомеров AS ЗагрузкаНомеров
	|	WHERE
	|		ЗагрузкаНомеров.ГруппаГостей = &qGuestGroup
	|		AND (ЗагрузкаНомеров.ЭтоЗаезд
	|				OR ЗагрузкаНомеров.IsReservation)
	|		AND ЗагрузкаНомеров.RecordType = &qRecordType
	|		AND (NOT &qCheckInDateIsFilled
	|				OR &qCheckInDateIsFilled
	|					AND ЗагрузкаНомеров.CheckInAccountingDate = &qCheckInDate)) AS GroupTotals
	|
	|GROUP BY
	|	GroupTotals.ГруппаГостей";
	vQry.SetParameter("qGuestGroup", Ref);
	vQry.SetParameter("qRecordType", AccumulationRecordType.Expense);
	vQry.SetParameter("qCheckInDate", BegOfDay(pCheckInDate));
	vQry.SetParameter("qCheckInDateIsFilled", ЗначениеЗаполнено(pCheckInDate));
	Return vQry.Execute().Unload();
EndFunction //pmGetRoomInventoryTotals

//-----------------------------------------------------------------------------
Function pmGetSalesTotals() Экспорт
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	GuestGroupSales.Услуга AS Услуга,
	|	GuestGroupSales.Валюта AS Валюта,
	|	GuestGroupSales.Услуга.ПорядокСортировки AS ServiceSortCode,
	|	GuestGroupSales.Валюта.ПорядокСортировки AS CurrencySortCode,
	|	SUM(GuestGroupSales.SalesTurnover) AS Продажи,
	|	SUM(GuestGroupSales.SalesWithoutVATTurnover) AS ПродажиБезНДС,
	|	SUM(GuestGroupSales.SalesForecastTurnover) AS ПрогнозПродаж,
	|	SUM(GuestGroupSales.SalesWithoutVATForecastTurnover) AS SalesWithoutVATForecast,
	|	SUM(GuestGroupSales.ExpectedSalesTurnover) AS ПланПродаж,
	|	SUM(GuestGroupSales.ExpectedSalesWithoutVATTurnover) AS ExpectedSalesWithoutVAT
	|FROM
	|	(SELECT
	|		CurrentAccountsReceivableTurnovers.Начисление.Услуга AS Услуга,
	|		CurrentAccountsReceivableTurnovers.ВалютаЛицСчета AS Валюта,
	|		CurrentAccountsReceivableTurnovers.SumReceipt - CurrentAccountsReceivableTurnovers.CommissionSumReceipt AS SalesTurnover,
	|		CASE
	|			WHEN CurrentAccountsReceivableTurnovers.SumReceipt = 0
	|				THEN CurrentAccountsReceivableTurnovers.SumReceipt - CurrentAccountsReceivableTurnovers.VATSumReceipt - CurrentAccountsReceivableTurnovers.CommissionSumReceipt
	|			ELSE CurrentAccountsReceivableTurnovers.SumReceipt - CurrentAccountsReceivableTurnovers.VATSumReceipt - (CurrentAccountsReceivableTurnovers.CommissionSumReceipt - CurrentAccountsReceivableTurnovers.CommissionSumReceipt * CurrentAccountsReceivableTurnovers.VATSumReceipt / CurrentAccountsReceivableTurnovers.SumReceipt)
	|		END AS SalesWithoutVATTurnover,
	|		0 AS SalesForecastTurnover,
	|		0 AS SalesWithoutVATForecastTurnover,
	|		0 AS ExpectedSalesTurnover,
	|		0 AS ExpectedSalesWithoutVATTurnover
	|	FROM
	|		AccumulationRegister.РелизацияТекОтчетПериод.Turnovers(&qPeriodFrom, &qPeriodTo, Period, ГруппаГостей = &qGuestGroup) AS CurrentAccountsReceivableTurnovers
	|	
	|	UNION ALL
	|	
	|	SELECT
	|		AccountsReceivableForecastTurnovers.Услуга,
	|		AccountsReceivableForecastTurnovers.ВалютаЛицСчета,
	|		0,
	|		0,
	|		AccountsReceivableForecastTurnovers.SalesTurnover - AccountsReceivableForecastTurnovers.CommissionSumTurnover,
	|		AccountsReceivableForecastTurnovers.SalesWithoutVATTurnover - AccountsReceivableForecastTurnovers.CommissionSumWithoutVATTurnover,
	|		AccountsReceivableForecastTurnovers.ExpectedSalesTurnover - AccountsReceivableForecastTurnovers.ExpectedCommissionSumTurnover,
	|		AccountsReceivableForecastTurnovers.ExpectedSalesWithoutVATTurnover - AccountsReceivableForecastTurnovers.ExpectedCommissionSumWithoutVATTurnover
	|	FROM
	|		AccumulationRegister.ПрогнозРеализации.Turnovers(&qPeriodFrom, &qPeriodTo, Period, ГруппаГостей = &qGuestGroup) AS AccountsReceivableForecastTurnovers) AS GuestGroupSales
	|
	|GROUP BY
	|	GuestGroupSales.Услуга,
	|	GuestGroupSales.Валюта,
	|	GuestGroupSales.Услуга.ПорядокСортировки,
	|	GuestGroupSales.Валюта.ПорядокСортировки
	|
	|ORDER BY
	|	ServiceSortCode,
	|	CurrencySortCode";
	vQry.SetParameter("qGuestGroup", Ref);
	vQry.SetParameter("qPeriodFrom", '00010101000000');
	vQry.SetParameter("qPeriodTo", '00010101000000');
	Return vQry.Execute().Unload();
EndFunction //pmGetSalesTotals

//-----------------------------------------------------------------------------
Function pmGetPaymentsTotals() Экспорт
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	BEGINOFPERIOD(Платежи.Period, DAY) AS УчетнаяДата,
	|	Платежи.ВалютаРасчетов AS Валюта,
	|	Платежи.ВалютаРасчетов.ПорядокСортировки AS CurrencySortCode,
	|	SUM(Платежи.SumExpense) AS Сумма,
	|	SUM(Платежи.SumExpense * &qVATRate / (100 + &qVATRate)) AS СуммаНДС
	|FROM
	|	AccumulationRegister.ВзаиморасчетыКонтрагенты.BalanceAndTurnovers(&qPeriodFrom, &qPeriodTo, Day, RegisterRecordsAndPeriodBoundaries, ГруппаГостей = &qGuestGroup) AS Платежи
	|
	|GROUP BY
	|	BEGINOFPERIOD(Платежи.Period, DAY),
	|	Платежи.ВалютаРасчетов,
	|	Платежи.ВалютаРасчетов.ПорядокСортировки
	|
	|ORDER BY
	|	УчетнаяДата,
	|	CurrencySortCode";
	vQry.SetParameter("qGuestGroup", Ref);
	vQry.SetParameter("qPeriodFrom", '00010101000000');
	vQry.SetParameter("qPeriodTo", '00010101000000');
	vQry.SetParameter("qVATRate", ?(ЗначениеЗаполнено(Owner.Фирма), ?(ЗначениеЗаполнено(Owner.Фирма.СтавкаНДС), Owner.Фирма.СтавкаНДС.Ставка, 0), 0));
	Return vQry.Execute().Unload();
EndFunction //pmGetPaymentsTotals

//-----------------------------------------------------------------------------
Function pmGetActiveResourceReservations() Экспорт
	// Run query to get all resources reserved
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	ResourceReservationHistory.Ресурс.Code AS ResourceCode,
	|	ResourceReservationHistory.Period,
	|	ResourceReservationHistory.Recorder,
	|	ResourceReservationHistory.Ресурс,
	|	ResourceReservationHistory.Контрагент,
	|	ResourceReservationHistory.DateTimeFrom,
	|	ResourceReservationHistory.Продолжительность,
	|	ResourceReservationHistory.DateTimeTo,
	|	ResourceReservationHistory.КоличествоЧеловек,
	|	ResourceReservationHistory.Клиент
	|FROM
	|	InformationRegister.ResourceReservationHistory AS ResourceReservationHistory
	|WHERE
	|	ResourceReservationHistory.ГруппаГостей = &qGuestGroup
	|	AND ResourceReservationHistory.ResourceReservationStatus.IsActive
	|ORDER BY
	|	ResourceReservationHistory.Ресурс.ПорядокСортировки,
	|	ResourceReservationHistory.Period";
	vQry.SetParameter("qGuestGroup", Ref);
	Return vQry.Execute().Unload();
EndFunction //pmGetActiveResourceReservations

//-----------------------------------------------------------------------------
Function pmGetResourceCodes() Экспорт
	vResourceCodes = "";
	// Run query to get all resources reserved
	vResources = pmGetActiveResourceReservations();
	vResources.GroupBy("ResourceCode",);
	For Each vResourcesRow In vResources Do
		vResourceCodes = vResourceCodes + Upper(СокрЛП(vResourcesRow.ResourceCode)) + " ";
	EndDo;
	Return СокрЛП(vResourceCodes);
EndFunction //pmGetResourceCodes

//-----------------------------------------------------------------------------
Function pmGetResourceDescriptions() Экспорт
	vResourceDescr = "";
	// Run query to get all resources reserved
	vResources = pmGetActiveResourceReservations();
	For Each vResourcesRow In vResources Do
		If BegOfDay(vResourcesRow.DateTimeFrom) = BegOfDay(vResourcesRow.DateTimeTo) Тогда
			vResourceDescr = vResourceDescr + СокрЛП(vResourcesRow.Ресурс) + " " + 
			                 Format(vResourcesRow.DateTimeFrom, "DF='dd.MM.yy HH:mm'") + " - " + 
							 Format(vResourcesRow.DateTimeTo, "DF='HH:mm'") + "; ";
		Else
			vResourceDescr = vResourceDescr + СокрЛП(vResourcesRow.Ресурс) + " " + 
			                 Format(vResourcesRow.DateTimeFrom, "DF='dd.MM.yy HH:mm'") + " - " + 
							 Format(vResourcesRow.DateTimeTo, "DF='dd.MM.yy HH:mm'") + "; ";
		EndIf;
	EndDo;
	Return СокрЛП(vResourceDescr);
EndFunction //pmGetResourceDescriptions

//-----------------------------------------------------------------------------
Function pmGetHotelProducts() Экспорт
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	Docs.ПутевкаКурсовка
	|FROM
	|	(SELECT
	|		Accommodations.ПутевкаКурсовка AS ПутевкаКурсовка
	|	FROM
	|		Document.Размещение AS Accommodations
	|	WHERE
	|		Accommodations.Posted
	|		AND Accommodations.ПутевкаКурсовка <> &qEmptyHotelProduct
	|		AND Accommodations.ГруппаГостей = &qGuestGroup
	|	
	|	UNION ALL
	|	
	|	SELECT
	|		Reservations.ПутевкаКурсовка
	|	FROM
	|		Document.Бронирование AS Reservations
	|	WHERE
	|		Reservations.Posted
	|		AND Reservations.ПутевкаКурсовка <> &qEmptyHotelProduct
	|		AND Reservations.ГруппаГостей = &qGuestGroup
	|	
	|	UNION ALL
	|	
	|	SELECT
	|		НачислениеУслуг.ПутевкаКурсовка
	|	FROM
	|		Document.Начисление AS НачислениеУслуг
	|	WHERE
	|		НачислениеУслуг.Posted
	|		AND НачислениеУслуг.ПутевкаКурсовка <> &qEmptyHotelProduct
	|		AND НачислениеУслуг.СчетПроживания.ГруппаГостей = &qGuestGroup) AS Docs
	|
	|GROUP BY
	|	Docs.ПутевкаКурсовка
	|
	|ORDER BY
	|	Docs.ПутевкаКурсовка.Code";
	vQry.SetParameter("qGuestGroup", Ref);
	vQry.SetParameter("qEmptyHotelProduct", Справочники.HotelProducts.EmptyRef());
	Return vQry.Execute().Unload();
EndFunction //pmGetHotelProducts

//-----------------------------------------------------------------------------
Function pmGetGuestGroupParameters() Экспорт
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	GuestGroupTotals.ГруппаГостей,
	|	GuestGroupTotals.Контрагент,
	|	GuestGroupTotals.Договор,
	|	GuestGroupTotals.Агент,
	|	GuestGroupTotals.PlannedPaymentMethod,
	|	MIN(GuestGroupTotals.DateTimeFrom) AS DateTimeFrom,
	|	MAX(GuestGroupTotals.DateTimeTo) AS DateTimeTo
	|FROM
	|	(SELECT
	|		Бронирование.ГруппаГостей AS ГруппаГостей,
	|		Бронирование.Контрагент AS Контрагент,
	|		Бронирование.Договор AS Договор,
	|		Бронирование.Агент AS Агент,
	|		Бронирование.PlannedPaymentMethod AS PlannedPaymentMethod,
	|		Бронирование.CheckInDate AS DateTimeFrom,
	|		Бронирование.ДатаВыезда AS DateTimeTo
	|	FROM
	|		Document.Бронирование AS Бронирование
	|	WHERE
	|		Бронирование.Posted
	|		AND Бронирование.ГруппаГостей = &qGuestGroup
	|		AND (Бронирование.ReservationStatus.IsActive
	|				OR Бронирование.ReservationStatus.ЭтоЗаезд)
	|	
	|	UNION ALL
	|	
	|	SELECT
	|		Размещение.ГруппаГостей,
	|		Размещение.Контрагент,
	|		Размещение.Договор,
	|		Размещение.Агент,
	|		Размещение.PlannedPaymentMethod,
	|		Размещение.CheckInDate,
	|		Размещение.ДатаВыезда
	|	FROM
	|		Document.Размещение AS Размещение
	|	WHERE
	|		Размещение.Posted
	|		AND Размещение.ГруппаГостей = &qGuestGroup
	|		AND Размещение.СтатусРазмещения.IsActive
	|	
	|	UNION ALL
	|	
	|	SELECT
	|		БроньУслуг.ГруппаГостей,
	|		БроньУслуг.Контрагент,
	|		БроньУслуг.Договор,
	|		БроньУслуг.Агент,
	|		БроньУслуг.PlannedPaymentMethod,
	|		БроньУслуг.DateTimeFrom,
	|		БроньУслуг.DateTimeTo
	|	FROM
	|		Document.БроньУслуг AS БроньУслуг
	|	WHERE
	|		БроньУслуг.Posted
	|		AND БроньУслуг.ГруппаГостей = &qGuestGroup
	|		AND БроньУслуг.ResourceReservationStatus.IsActive) AS GuestGroupTotals
	|
	|GROUP BY
	|	GuestGroupTotals.ГруппаГостей,
	|	GuestGroupTotals.Контрагент,
	|	GuestGroupTotals.Договор,
	|	GuestGroupTotals.Агент,
	|	GuestGroupTotals.PlannedPaymentMethod";
	vQry.SetParameter("qGuestGroup", Ref);
	Return vQry.Execute().Unload();
EndFunction //pmGetGuestGroupParameters

//-----------------------------------------------------------------------------
// Checks if this is preliminary guest group
//-----------------------------------------------------------------------------
Function pmIsPreliminary() Экспорт
	vIsPreliminary = False;
	// Run query to find reservations in preliminary status
	If НЕ ЭтоНовый() Тогда
		vQry = New Query();
		vQry.Text = 
		"SELECT
		|	Бронирование.Ref
		|FROM
		|	Document.Бронирование AS Бронирование
		|WHERE
		|	Бронирование.Posted
		|	AND (NOT Бронирование.ReservationStatus.IsActive)
		|	AND Бронирование.ReservationStatus.IsPreliminary
		|	AND Бронирование.ГруппаГостей = &qGuestGroup
		|
		|ORDER BY
		|	Бронирование.ДатаДок,
		|	Бронирование.PointInTime";
		vQry.SetParameter("qGuestGroup", Ref);
		vQryRes = vQry.Execute().Unload();
		If vQryRes.Count() > 0 Тогда
			vIsPreliminary = True;
		EndIf;
	EndIf;
	Return vIsPreliminary;
EndFunction //pmIsPreliminary

//-----------------------------------------------------------------------------
Процедура pmCreateFolios(pDate) Экспорт
	vChargingRules = Неопределено;
	If ЗначениеЗаполнено(Owner) Тогда
		If Owner.CustomerChargingRules.Count() > 0 Тогда
			vChargingRules = Owner.CustomerChargingRules.Unload();
		EndIf;
	Else
		Return;
	EndIf;
	// Check list of template rules
	If vChargingRules = Неопределено Тогда
		// Create new folio and take parameters from the hotel
		vFolioObj = Documents.СчетПроживания.CreateDocument();
		vFolioObj.Гостиница = Owner;
		
		vFolioObj.ГруппаГостей = Ref;
		vFolioObj.Контрагент = Customer;
		vFolioObj.Договор = Справочники.Contracts.EmptyRef();
		If ЗначениеЗаполнено(Customer) And ЗначениеЗаполнено(Customer.PlannedPaymentMethod) Тогда
			vFolioObj.СпособОплаты = Customer.PlannedPaymentMethod;
			If ЗначениеЗаполнено(Customer.AccountingCurrency) Тогда
				vFolioObj.ВалютаЛицСчета = Customer.AccountingCurrency;
			EndIf;
		ElsIf ЗначениеЗаполнено(Owner.PaymentMethodForCustomerPayments) Тогда
			vFolioObj.СпособОплаты = Owner.PaymentMethodForCustomerPayments;
		EndIf;
		If НЕ ЗначениеЗаполнено(vFolioObj.Контрагент) Or ЗначениеЗаполнено(vFolioObj.Гостиница) And vFolioObj.Контрагент = vFolioObj.Гостиница.IndividualsCustomer Тогда
			vFolioObj.Клиент = Client;
		EndIf;
		vFolioObj.DateTimeFrom = CheckInDate;
		vFolioObj.DateTimeTo = CheckOutDate;
		vFolioObj.Write();
		
		// Add it to the charging rules
		vCR = ChargingRules.Add();
		vCR.СпособРазделенияОплаты = Перечисления.ChargingRuleTypes.InRate;
		vCR.ChargingFolio = vFolioObj.Ref;
	Else
		For Each vRule In vChargingRules Do
			vIsTemplate = True;
			vTemplateFolio = vRule.ChargingFolio;
			If ЗначениеЗаполнено(vTemplateFolio) Тогда
				vIsTemplate = НЕ vTemplateFolio.IsMaster;
			EndIf;
			If vIsTemplate Тогда
				// Create new folio from template
				vFolioObj = Documents.СчетПроживания.CreateDocument();
				vFolioObj.Гостиница = Owner;
				
				vFolioObj.ГруппаГостей = Ref;
				vFolioObj.Контрагент = Customer;
				vFolioObj.Договор = Справочники.Contracts.EmptyRef();
				If ЗначениеЗаполнено(Customer) And ЗначениеЗаполнено(Customer.AccountingCurrency) Тогда
					vFolioObj.ВалютаЛицСчета = Customer.AccountingCurrency;
				EndIf;
				If НЕ ЗначениеЗаполнено(vFolioObj.Контрагент) Or ЗначениеЗаполнено(vFolioObj.Гостиница) And vFolioObj.Контрагент = vFolioObj.Гостиница.IndividualsCustomer Тогда
					vFolioObj.Клиент = Client;
				EndIf;
				vFolioObj.DateTimeFrom = CheckInDate;
				vFolioObj.DateTimeTo = CheckOutDate;
				vFolioObj.Write();
				
				// Add it to the charging rules
				vCR = ChargingRules.Add();
				FillPropertyValues(vCR, vRule, , "ChargingFolio");
				vCR.ChargingFolio = vFolioObj.Ref;
			Else
				// Copy charging rule
				vCR = ChargingRules.Add();
				FillPropertyValues(vCR, vRule);
			EndIf;
		EndDo;
	EndIf;
КонецПроцедуры //pmCreateFolios

//-----------------------------------------------------------------------------
Процедура BeforeWrite(pCancel)
	If ThisObject.DataExchange.Load Тогда
		Return;
	EndIf;
	If ЭтоНовый() Тогда
		If НЕ IsFolder Тогда
			// Set guest group description prefix
			If IsBlankString(Description) Тогда
				If ЗначениеЗаполнено(Owner) Тогда
					If НЕ IsBlankString(Owner.GuestGroupDescriptionPrefix) Тогда
						If Code = 0 Тогда
							SetNewCode();
						EndIf;
						Description = TrimR(Owner.GuestGroupDescriptionPrefix) + Format(Code, "ND=12; NFD=0; NZ=; NG=");
					EndIf;
				EndIf;
			EndIf;
			// Author and date
			If НЕ ЗначениеЗаполнено(Автор) Тогда
				Автор = ПараметрыСеанса.ТекПользователь;
				CreateDate = CurrentDate();
			EndIf;
		EndIf;
	EndIf;
	If DeletionMark Тогда
		WriteLogEvent(NStr("en='SuspiciousEvents.GuestGroupSetDeletionMark'; de='SuspiciousEvents.GuestGroupSetDeletionMark'; ru='SuspiciousEvents.GuestGroupSetDeletionMark'"), EventLogLevel.Warning, Metadata(), Ref, NStr("en='Set guest group deletion mark';ru='Установка отметки удаления';de='Erstellung der Löschmarkierung'") + Chars.LF + СокрЛП(Customer) + ", " + СокрЛП(Client) + ", " + СокрЛП(GuestsCheckedIn) + ", " + Format(CheckInDate, "DF='dd.MM.yyyy HH:mm'") + " - " + Format(CheckOutDate, "DF='dd.MM.yyyy HH:mm'"));
	EndIf;
КонецПроцедуры //BeforeWrite

//-----------------------------------------------------------------------------
Процедура OnCopy(pCopiedObject)
	// Author and date
	If НЕ IsFolder Тогда
		Автор = ПараметрыСеанса.ТекПользователь;
		CreateDate = CurrentDate();
	EndIf;
КонецПроцедуры //OnCopy

//-----------------------------------------------------------------------------
Процедура OnWrite(pCancel)
	// Update charging rule folio parameters
	If Owner.UseGuestGroupFolios Тогда
		For Each vCRRow In ChargingRules Do
			If ЗначениеЗаполнено(vCRRow.ChargingFolio) Тогда
				vDoFolioUpdate = False;
				vFolioObj = vCRRow.ChargingFolio.GetObject();
				If vFolioObj.Гостиница <> Owner Тогда
					vFolioObj.Гостиница = Owner;
					vDoFolioUpdate = True;
				EndIf;
				If vFolioObj.ГруппаГостей <> Ref Тогда
					vFolioObj.ГруппаГостей = Ref;
					vDoFolioUpdate = True;
				EndIf;
				If vFolioObj.DateTimeFrom <> CheckInDate Тогда
					vFolioObj.DateTimeFrom = CheckInDate;
					vDoFolioUpdate = True;
				EndIf;
				If vFolioObj.DateTimeTo <> CheckOutDate Тогда
					vFolioObj.DateTimeTo = CheckOutDate;
					vDoFolioUpdate = True;
				EndIf;
				If vFolioObj.Клиент <> Client Тогда
					If НЕ ЗначениеЗаполнено(vFolioObj.Контрагент) Or ЗначениеЗаполнено(vFolioObj.Гостиница) And vFolioObj.Контрагент = vFolioObj.Гостиница.IndividualsCustomer Тогда
						vFolioObj.Клиент = Client;
						vDoFolioUpdate = True;
					EndIf;
				EndIf;
				If vFolioObj.Контрагент <> Customer Тогда
					vFolioObj.Контрагент = Customer;
					vFolioObj.Договор = Справочники.Contracts.EmptyRef();
					vDoFolioUpdate = True;
				EndIf;
				If vDoFolioUpdate Тогда
					vFolioObj.Write(DocumentWriteMode.Write);
				EndIf;
			EndIf;
		EndDo;
	EndIf;
КонецПроцедуры //OnWrite

//-----------------------------------------------------------------------------
Function pmGetGuestGroupResumeRecords() Экспорт
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	GuestGroupAttachments.Period AS Period,
	|	GuestGroupAttachments.ГруппаГостей,
	|	GuestGroupAttachments.IsIncoming,
	|	GuestGroupAttachments.EMail,
	|	GuestGroupAttachments.Fax,
	|	GuestGroupAttachments.AttachmentType,
	|	GuestGroupAttachments.AttachmentStatus,
	|	GuestGroupAttachments.DocumentText,
	|	GuestGroupAttachments.ExtFile,
	|	GuestGroupAttachments.FileName,
	|	GuestGroupAttachments.FileLoadTime,
	|	GuestGroupAttachments.FileLastChangeTime,
	|	GuestGroupAttachments.Примечания,
	|	GuestGroupAttachments.Автор
	|FROM
	|	InformationRegister.GuestGroupAttachments AS GuestGroupAttachments
	|WHERE
	|	GuestGroupAttachments.ГруппаГостей = &qGuestGroup
	|	AND GuestGroupAttachments.AttachmentType = &qGroupResume
	|
	|ORDER BY
	|	Period";
	vQry.SetParameter("qGuestGroup", Ref);
	vQry.SetParameter("qGroupResume", Перечисления.AttachmentTypes.GroupResume);
	Return vQry.Execute().Unload();
EndFunction //pmGetGuestGroupResumeRecords

//-----------------------------------------------------------------------------
Function pmGetGuestGroupResumeRecord(pPeriod) Экспорт
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	GuestGroupAttachments.Period AS Period,
	|	GuestGroupAttachments.ГруппаГостей,
	|	GuestGroupAttachments.IsIncoming,
	|	GuestGroupAttachments.EMail,
	|	GuestGroupAttachments.Fax,
	|	GuestGroupAttachments.AttachmentType,
	|	GuestGroupAttachments.AttachmentStatus,
	|	GuestGroupAttachments.DocumentText,
	|	GuestGroupAttachments.ExtFile,
	|	GuestGroupAttachments.FileName,
	|	GuestGroupAttachments.FileLoadTime,
	|	GuestGroupAttachments.FileLastChangeTime,
	|	GuestGroupAttachments.Примечания,
	|	GuestGroupAttachments.Автор
	|FROM
	|	InformationRegister.GuestGroupAttachments AS GuestGroupAttachments
	|WHERE
	|	GuestGroupAttachments.ГруппаГостей = &qGuestGroup
	|	AND GuestGroupAttachments.Period = &qPeriod
	|
	|ORDER BY
	|	Period";
	vQry.SetParameter("qGuestGroup", Ref);
	vQry.SetParameter("qPeriod", pPeriod);
	Return vQry.Execute().Unload();
EndFunction //pmGetGuestGroupResumeRecord

//-----------------------------------------------------------------------------
Процедура pmAddBankTransferChargingRule() Экспорт
	vCustomer = Customer;
	If НЕ ЗначениеЗаполнено(vCustomer) Тогда
		If ЗначениеЗаполнено(Owner) Тогда
			vCustomer = Owner.IndividualsCustomer;
		EndIf;
	EndIf;
	// Get default owners charging rules
	vOwnerCRs = New ValueTable();
	If НЕ ЗначениеЗаполнено(vCustomer) Тогда
		vOwnerCRs = Owner.ChargingRules;
	Else
		vOwnerCRs = Owner.CustomerChargingRules;
		If vCustomer.ChargingRules.Count() > 0  Тогда
			vOwnerCRs = vCustomer.ChargingRules;
		Else 
			vCustomerParent = vCustomer.Parent;
			While ЗначениеЗаполнено(vCustomerParent) Do
				If vCustomerParent.ChargingRules.Count() > 0  Тогда
					vOwnerCRs = vCustomerParent.ChargingRules;
					Break;
				EndIf;
				vCustomerParent = vCustomerParent.Parent; 
			EndDo;
		EndIf;
	EndIf;
	If vOwnerCRs.Count() = 0 Тогда
		// Try to update existing charging rules
		vCRIsFound = False;
		vCRRows = ChargingRules.FindRows(New Structure("СпособРазделенияОплаты, ПравилаНачисления, ValidFromDate, ValidToDate", Перечисления.ChargingRuleTypes.InRate, Неопределено, '00010101', '00010101'));
		If vCRRows.Count() = 1 Тогда
			vCRIsFound = True;
			vCR = vCRRows.Get(0);
		Else
			vCR = ChargingRules.Вставить(0);
		EndIf;
		
		// Create new folio and use base rules
		If vCRIsFound And ЗначениеЗаполнено(vCR.ChargingFolio) Тогда
			vFolioObj = vCR.ChargingFolio.GetObject();
		Else
			vFolioObj = Documents.СчетПроживания.CreateDocument();
		EndIf;
		
		vFolioObj.ДокОснование = Неопределено;
		vFolioObj.Контрагент = vCustomer;
		vFolioObj.ГруппаГостей = Ref;
		vFolioObj.СпособОплаты = Owner.PaymentMethodForCustomerPayments;
		If ЗначениеЗаполнено(vCustomer) Тогда
			vFolioObj.ВалютаЛицСчета = vCustomer.ВалютаРасчетов;
			If ЗначениеЗаполнено(vCustomer.PlannedPaymentMethod) Тогда
				vFolioObj.СпособОплаты = vCustomer.PlannedPaymentMethod;
			EndIf;
		Else
			vFolioObj.ВалютаЛицСчета = Owner.BaseCurrency;
			vFolioObj.СпособОплаты = Owner.PlannedPaymentMethod;
		EndIf;
		If НЕ ЗначениеЗаполнено(vFolioObj.Контрагент) Or ЗначениеЗаполнено(vFolioObj.Гостиница) And vFolioObj.Контрагент = vFolioObj.Гостиница.IndividualsCustomer Тогда
			vFolioObj.Клиент = Client;
			vFolioObj.НомерРазмещения = Справочники.НомернойФонд.EmptyRef();
		EndIf;
		vFolioObj.DateTimeFrom = CheckInDate;
		vFolioObj.DateTimeTo = CheckOutDate;
		vFolioObj.Write(DocumentWriteMode.Write);
		
		// Add new charging rule
		vCR.ChargingFolio = vFolioObj.Ref;
		vCR.СпособРазделенияОплаты = Перечисления.ChargingRuleTypes.InRate;
	Else
		// Do for each owner charging rule
		For i = 0 To (vOwnerCRs.Count() - 1) Do
			vOwnerCRsRow = vOwnerCRs.Get(i);
			If НЕ ЗначениеЗаполнено(vOwnerCRsRow.ChargingFolio) Тогда
				Continue;
			EndIf;
			
			// Try to find existing charging rule row with the same type
			vCRIsFound = False;
			vCRRows = ChargingRules.FindRows(New Structure("СпособРазделенияОплаты, ПравилаНачисления, ValidFromDate, ValidToDate", vOwnerCRsRow.СпособРазделенияОплаты, vOwnerCRsRow.ПравилаНачисления, vOwnerCRsRow.ValidFromDate, vOwnerCRsRow.ValidToDate));
			If vCRRows.Count() = 1 Тогда
				vCRIsFound = True;
				vCR = vCRRows.Get(0);
			Else
				vCR = ChargingRules.Вставить(i);
			EndIf;
			
			// Get folio object
			vFolioObj = Неопределено;
			If vCRIsFound And ЗначениеЗаполнено(vCR.ChargingFolio) And НЕ vOwnerCRsRow.ChargingFolio.IsMaster Тогда
				vFolioObj = vCR.ChargingFolio.GetObject();
				
				vFolioObj.ДокОснование = Неопределено;
				vFolioObj.Контрагент = vCustomer;
				vFolioObj.ГруппаГостей = Ref;
				vFolioObj.DateTimeFrom = CheckInDate;
				vFolioObj.DateTimeTo = CheckOutDate;
				If НЕ ЗначениеЗаполнено(vFolioObj.Контрагент) Or ЗначениеЗаполнено(vFolioObj.Гостиница) And vFolioObj.Контрагент = vFolioObj.Гостиница.IndividualsCustomer Тогда
					vFolioObj.Клиент = Client;
					vFolioObj.НомерРазмещения = Справочники.НомернойФонд.EmptyRef();
				EndIf;
				vFolioObj.Write(DocumentWriteMode.Write);
			Else
				If НЕ vOwnerCRsRow.ChargingFolio.IsMaster Тогда
					// Create new folio and take parameters from the template folio
					vFolioObj = Documents.СчетПроживания.CreateDocument();
					
					vFolioObj.ДокОснование = Неопределено;
					vFolioObj.Контрагент = vCustomer;
					vFolioObj.ГруппаГостей = Ref;
					vFolioObj.DateTimeFrom = CheckInDate;
					vFolioObj.DateTimeTo = CheckOutDate;
					If НЕ ЗначениеЗаполнено(vFolioObj.Контрагент) Or ЗначениеЗаполнено(vFolioObj.Гостиница) And vFolioObj.Контрагент = vFolioObj.Гостиница.IndividualsCustomer Тогда
						vFolioObj.Клиент = Client;
						vFolioObj.НомерРазмещения = Справочники.НомернойФонд.EmptyRef();
					EndIf;
					vFolioObj.Write(DocumentWriteMode.Write);
				Else
					vFolioObj = vOwnerCRsRow.ChargingFolio.GetObject();
				EndIf;
			EndIf;
			
			// Add new charging rule
			vCR.ChargingFolio = vFolioObj.Ref;
			vCR.СпособРазделенияОплаты = vOwnerCRsRow.СпособРазделенияОплаты;
			vCR.ПравилаНачисления = vOwnerCRsRow.ПравилаНачисления;
			vCR.ValidFromDate = vOwnerCRsRow.ValidFromDate;
			vCR.ValidToDate = vOwnerCRsRow.ValidToDate;
		EndDo;
	EndIf;
КонецПроцедуры //pmAddBankTransferChargingRule

//-----------------------------------------------------------------------------
Function pmSetPlannedPaymentMethod(rPlannedPaymentMethod = Неопределено) Экспорт
	vPayer = Перечисления.КтоПлатит1.Клиент;
	vAccSrvFolio = Неопределено;
	vChargingRules = ChargingRules.Unload();
	If vChargingRules.Count() > 0 Тогда
		// Set planned payment method from the first charging rule
		vCRRow = vChargingRules.Get(0);
		If ЗначениеЗаполнено(vCRRow.ChargingFolio) Тогда
			If ЗначениеЗаполнено(vCRRow.ChargingFolio.СпособОплаты) Тогда
				vAccSrvFolio = vCRRow.ChargingFolio;
				If rPlannedPaymentMethod <> vAccSrvFolio.СпособОплаты Тогда
					rPlannedPaymentMethod = vAccSrvFolio.СпособОплаты;
				EndIf;
			EndIf;
		EndIf;
	EndIf;
	If ЗначениеЗаполнено(vAccSrvFolio) Тогда
		vCustomer = Неопределено;
		vClient = Неопределено;
		For Each vCRRow In vChargingRules Do
			If vCRRow.ChargingFolio = vAccSrvFolio Тогда
				If ЗначениеЗаполнено(vAccSrvFolio.Контрагент) Тогда
					vCustomer = vAccSrvFolio.Контрагент;
				Else
					vClient = vAccSrvFolio.Клиент;
				EndIf;
			EndIf;
		EndDo;
		If ЗначениеЗаполнено(vCustomer) Тогда
			If vCustomer = Customer Тогда
				vPayer = Перечисления.КтоПлатит1.Контрагент;
			Else
				vPayer = Перечисления.КтоПлатит1.ChargingRules;
			EndIf;
		ElsIf ЗначениеЗаполнено(vClient) Тогда
			If vClient = Client Тогда
				vPayer = Перечисления.КтоПлатит1.Клиент;
			Else
				vPayer = Перечисления.КтоПлатит1.ChargingRules;
			EndIf;
		EndIf;
	EndIf;
	Return vPayer;
EndFunction //pmSetPlannedPaymentMethod

//-----------------------------------------------------------------------------
Процедура pmLoadChargingRules(pOwner) Экспорт
	// Get list of hotel default charging rules owners
	vHotelCROwners = pOwner;
	// Remove charging rules for objects of the same type
	i = 0;
	j = 0;
	vCRTo = ChargingRules.Unload();
	While i < vCRTo.Count() Do
		vCRRow = vCRTo.Get(i);
		If ЗначениеЗаполнено(vCRRow.ChargingFolio.Контрагент) Тогда
			If TypeOf(pOwner) = TypeOf(vCRRow.ChargingFolio.Контрагент) Тогда
				If vHotelCROwners.FindByValue(vCRRow.ChargingFolio.Контрагент) = Неопределено Тогда
					// Try to find hotel template rule of the same type
					vHotelCRRows = Owner.ChargingRules.FindRows(New Structure("СпособРазделенияОплаты, ПравилаНачисления, ValidFromDate, ValidToDate", vCRRow.СпособРазделенияОплаты, vCRRow.ПравилаНачисления, vCRRow.ValidFromDate, vCRRow.ValidToDate));
					If vHotelCRRows.Count() <> 1 Тогда
						// Delete charging rule row
						vCRTo.Delete(i);
						// Save Должность of the first deleted charging rule
						If j = 0 Тогда
							j = i;
						EndIf;
						Continue;
					Else
						
						// Update charging folio
						vFolioObj = vCRRow.ChargingFolio.GetObject();
						
						vFolioObj.ДокОснование = Неопределено;
						vFolioObj.ГруппаГостей = Ref;
						vFolioObj.DateTimeFrom = CheckInDate;
						vFolioObj.DateTimeTo = CheckOutDate;
						
						If TypeOf(pOwner) = Type("CatalogRef.Клиенты") Тогда
							vFolioObj.Клиент = Справочники.Clients.EmptyRef();
						Else
							vFolioObj.Клиент = Client;
						EndIf;
						vFolioObj.Write(DocumentWriteMode.Write);
					EndIf;
				EndIf;
			EndIf;
		EndIf;
		i = i + 1;
	EndDo;
	// Load changed charging rules to the tabular part
	ChargingRules.Load(vCRTo);
	// Check owner
	If НЕ ЗначениеЗаполнено(pOwner) Тогда
		If ChargingRules.Count() = 0 Тогда
			pmCreateFolios(CreateDate);
		EndIf;
		Return;
	EndIf;
	vCRFrom = Неопределено;
	vCRFrom = pOwner.ChargingRules.Unload();
	If vCRFrom = Неопределено Тогда
		If ChargingRules.Count() = 0 Тогда
			pmCreateFolios(CreateDate);
		EndIf;
		Return;
	EndIf;
	If vCRFrom.Count() = 0 Тогда
		If ChargingRules.Count() = 0 Тогда
			pmCreateFolios(CreateDate);
		EndIf;
		Return;
	EndIf;
	If ЗначениеЗаполнено(Owner) And Owner.UseGuestGroupFolios Тогда
		vCRTo = ChargingRules.Unload();
		
		// Вставить owners charging rules before this document charging rules
		For Each vCRRow In vCRFrom Do
			// Check if current folio should be used as template
			vIsTemplate = True;
			If ЗначениеЗаполнено(vCRRow.ChargingFolio) Тогда
				vIsTemplate = НЕ vCRRow.ChargingFolio.IsMaster;
			EndIf;
			// Try to find existing charging rule of the same type
			vReuseFolio = False;
			vCRToRows = vCRTo.FindRows(New Structure("СпособРазделенияОплаты, ПравилаНачисления, ValidFromDate, ValidToDate", vCRRow.СпособРазделенияОплаты, vCRRow.ПравилаНачисления, vCRRow.ValidFromDate, vCRRow.ValidToDate));
			If vCRToRows.Count() = 1 Тогда
				// Reuse existing one
				vCRToRow = vCRToRows.Get(0);
				vReuseFolio = True;
			Else
				// New charging rule row
				vCRToRow = vCRTo.Вставить(j);
				j = j + 1;
			EndIf;
			vCRToRow.СпособРазделенияОплаты = vCRRow.СпособРазделенияОплаты;
			vCRToRow.ПравилаНачисления = vCRRow.ПравилаНачисления;
			vCRToRow.ValidFromDate = vCRRow.ValidFromDate;
			vCRToRow.ValidToDate = vCRRow.ValidToDate;
			// If current charging folio is template then create new based on it
			If НЕ vReuseFolio Тогда
				If vIsTemplate Тогда
					// Create new folio from template
					vFolioObj = Documents.СчетПроживания.CreateDocument();
					
					vFolioObj.ДокОснование = Неопределено;
					If TypeOf(pOwner) = Type("CatalogRef.Клиенты") Тогда
						vFolioObj.Клиент = pOwner;
					EndIf;
					If НЕ ЗначениеЗаполнено(vFolioObj.Контрагент) Or ЗначениеЗаполнено(vFolioObj.Гостиница) And vFolioObj.Контрагент = vFolioObj.Гостиница.IndividualsCustomer Тогда
						vFolioObj.Клиент = Client;
					EndIf;
					vFolioObj.ГруппаГостей = Ref;
					vFolioObj.DateTimeFrom = CheckInDate;
					vFolioObj.DateTimeTo = CheckOutDate;
				Else
					vCRToRow.ChargingFolio = vCRRow.ChargingFolio;
					vFolioObj = vCRToRow.ChargingFolio.GetObject();
					vFolioObj.ДокОснование = Неопределено;
				EndIf;
			Else
				// Update folio from template
				If vIsTemplate Тогда
					vFolioObj = vCRToRow.ChargingFolio.GetObject();
					
					vFolioObj.ДокОснование = Неопределено;
					If TypeOf(pOwner) = Type("CatalogRef.Клиенты") Тогда
						vFolioObj.Клиент = pOwner;
					EndIf;
					If НЕ ЗначениеЗаполнено(vFolioObj.Контрагент) Or ЗначениеЗаполнено(vFolioObj.Гостиница) And vFolioObj.Контрагент = vFolioObj.Гостиница.IndividualsCustomer Тогда
						vFolioObj.Клиент = Client;
					Else
						vFolioObj.Клиент = Справочники.Clients.EmptyRef();
					EndIf;
					vFolioObj.ГруппаГостей = Ref;
					vFolioObj.DateTimeFrom = CheckInDate;
					vFolioObj.DateTimeTo = CheckOutDate;
				Else
					vCRToRow.ChargingFolio = vCRRow.ChargingFolio;
					vFolioObj = vCRToRow.ChargingFolio.GetObject();
					vFolioObj.ДокОснование = Неопределено;
				EndIf;
			EndIf;
			If TypeOf(pOwner) = Type("CatalogRef.Клиенты") Тогда
				vFolioObj.Клиент = pOwner;
			EndIf;
			vFolioObj.Write(DocumentWriteMode.Write);
			vCRToRow.ChargingFolio = vFolioObj.Ref;
		EndDo;
		// Load changed charging rules to the tabular part
		ChargingRules.Load(vCRTo);
	Else	
		// Вставить owners charging rules before this document charging rules
		For Each vCRRow In vCRFrom Do
			// Check if current folio should be used as template
			vIsTemplate = True;
			If ЗначениеЗаполнено(vCRRow.ChargingFolio) Тогда
				vIsTemplate = НЕ vCRRow.ChargingFolio.IsMaster;
			EndIf;
			// Try to find existing charging rule of the same type
			vReuseFolio = False;
			vCRToRows = vCRTo.FindRows(New Structure("СпособРазделенияОплаты, ПравилаНачисления, ValidFromDate, ValidToDate", vCRRow.СпособРазделенияОплаты, vCRRow.ПравилаНачисления, vCRRow.ValidFromDate, vCRRow.ValidToDate));
			If vCRToRows.Count() = 1 Тогда
				// Reuse existing one
				vCRToRow = vCRToRows.Get(0);
				vReuseFolio = True;
			Else
				// New charging rule row
				vCRToRow = vCRTo.Вставить(j);
				j = j + 1;
			EndIf;
			vCRToRow.СпособРазделенияОплаты = vCRRow.СпособРазделенияОплаты;
			vCRToRow.ПравилаНачисления = vCRRow.ПравилаНачисления;
			vCRToRow.ValidFromDate = vCRRow.ValidFromDate;
			vCRToRow.ValidToDate = vCRRow.ValidToDate;
			// If current charging folio is template then create new based on it
			If НЕ vReuseFolio Тогда
				If vIsTemplate Тогда
					// Create new folio from template
					vFolioObj = Documents.СчетПроживания.CreateDocument();
					
					vFolioObj.ДокОснование = Неопределено;
					If TypeOf(pOwner) = Type("CatalogRef.Клиенты") Тогда
						vFolioObj.Клиент = pOwner;
					EndIf;
					If НЕ ЗначениеЗаполнено(vFolioObj.Контрагент) Or ЗначениеЗаполнено(vFolioObj.Гостиница) And vFolioObj.Контрагент = vFolioObj.Гостиница.IndividualsCustomer Тогда
						vFolioObj.Клиент = Client;
					EndIf;
					vFolioObj.ГруппаГостей = Ref;
					vFolioObj.DateTimeFrom = CheckInDate;
					vFolioObj.DateTimeTo = CheckOutDate;
				Else
					vCRToRow.ChargingFolio = vCRRow.ChargingFolio;
					vFolioObj = vCRToRow.ChargingFolio.GetObject();
					vFolioObj.ДокОснование = Неопределено;
				EndIf;
			Else
				// Update folio from template
				If vIsTemplate Тогда
					vFolioObj = vCRToRow.ChargingFolio.GetObject();
					
					vFolioObj.ДокОснование = Неопределено;
					If TypeOf(pOwner) = Type("CatalogRef.Клиенты") Тогда
						vFolioObj.Клиент = pOwner;
					EndIf;
					If НЕ ЗначениеЗаполнено(vFolioObj.Контрагент) Or ЗначениеЗаполнено(vFolioObj.Гостиница) And vFolioObj.Контрагент = vFolioObj.Гостиница.IndividualsCustomer Тогда
						vFolioObj.Клиент = Client;
					Else
						vFolioObj.Клиент = Справочники.Clients.EmptyRef();
					EndIf;
					vFolioObj.ГруппаГостей = Ref;
					vFolioObj.DateTimeFrom = CheckInDate;
					vFolioObj.DateTimeTo = CheckOutDate;
				Else
					vCRToRow.ChargingFolio = vCRRow.ChargingFolio;
					vFolioObj = vCRToRow.ChargingFolio.GetObject();
					vFolioObj.ДокОснование = Неопределено;
				EndIf;
			КонецЕсли;	
			If TypeOf(pOwner) = Type("CatalogRef.Клиенты") Тогда
				vFolioObj.Клиент = pOwner;
			EndIf;
			vFolioObj.Write(DocumentWriteMode.Write);
			vCRToRow.ChargingFolio = vFolioObj.Ref;
		EndDo;
		// Load changed charging rules to the tabular part
		ChargingRules.Load(vCRTo);
	EndIf;
	If ChargingRules.Count() = 0 Тогда
		pmCreateFolios(CreateDate);
	EndIf;
КонецПроцедуры //pmLoadChargingRules

//-----------------------------------------------------------------------------
Процедура OnSetNewCode(pStandardProcessing, pPrefix)
	If Constants.UseSequentionalGroupNumberingForAllHotels.Get() Тогда
		pStandardProcessing = False;
		// Add exclusive lock to the constant
		vDataLock = New DataLock();
		vDLItem = vDataLock.Add("Constant.UseSequentionalGroupNumberingForAllHotels");
		vDLItem.Mode = DataLockMode.Exclusive;
		While True Do
			Try
				vDataLock.Lock();
				Break;
			Except
				Message(ErrorDescription(), MessageStatus.Attention);
			EndTry;
		EndDo;
		// Get guest groups prefix for current node 
		vGuestGroupsCodesFrom = 0;
		vGuestGroupsCodesTo = 0;
		vCentralOfficeExchangePlan = ExchangePlans.CentralOfficeExchangePlan.ThisNode();
		If ЗначениеЗаполнено(vCentralOfficeExchangePlan) And (vCentralOfficeExchangePlan.GuestGroupsCodesFrom > 0 Or vCentralOfficeExchangePlan.GuestGroupsCodesTo > 0) Тогда
			vGuestGroupsCodesFrom = Max(vGuestGroupsCodesFrom, vCentralOfficeExchangePlan.GuestGroupsCodesFrom);
			vGuestGroupsCodesTo = Max(vGuestGroupsCodesTo, vCentralOfficeExchangePlan.GuestGroupsCodesTo);
		EndIf;
		vReplicationExchangePlan = ExchangePlans.ReplicationExchangePlan.ThisNode();
		If ЗначениеЗаполнено(vReplicationExchangePlan) And (vReplicationExchangePlan.GuestGroupsCodesFrom > 0 Or vReplicationExchangePlan.GuestGroupsCodesTo > 0) Тогда
			vGuestGroupsCodesFrom = Max(vGuestGroupsCodesFrom, vReplicationExchangePlan.GuestGroupsCodesFrom);
			vGuestGroupsCodesTo = Max(vGuestGroupsCodesTo, vReplicationExchangePlan.GuestGroupsCodesTo);
		EndIf;
		// Get last used guest group code
	
		
		
		// Set new code
			If vGuestGroupsCodesFrom > 0 Тогда
				Code = vGuestGroupsCodesFrom + 1;
			Else
				Code = 1;
			EndIf;
		
	EndIf;
КонецПроцедуры //OnSetNewCode
