//-----------------------------------------------------------------------------
Function CheckIfDocumentIsAlreadyPosted()
	vIsPosted = False;
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	Акт.Ref
	|FROM
	|	Document.Акт AS Акт
	|WHERE
	|	Акт.ЗакрытиеПериода = &qCloseOfPeriod
	|	AND Акт.Posted
	|
	|ORDER BY
	|	Акт.PointInTime";
	vQry.SetParameter("qCloseOfPeriod", Ref);
	vQryRes = vQry.Execute();
	If НЕ vQryRes.IsEmpty() Тогда
		vIsPosted = True;
	EndIf;
	Return vIsPosted; 
EndFunction //CheckIfDocumentIsAlreadyPosted

//-----------------------------------------------------------------------------
Function pmGetCloseOfDaySettlements() Экспорт
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	Акт.Ref AS Акт
	|FROM
	|	Document.Акт AS Акт
	|WHERE
	|	Акт.ЗакрытиеПериода = &qCloseOfPeriod
	|	AND Акт.Posted = TRUE";
	vQry.SetParameter("qCloseOfPeriod", Ref);
	Return vQry.Execute().Unload();
EndFunction //pmGetCloseOfDaySettlements

//-----------------------------------------------------------------------------
Function GetOpenFoliosCountForGuestGroup(pGuestGroup)
	vQry = New Query();
	vQry.Text =
	"SELECT
	|	Folios.Ref AS СчетПроживания
	|FROM
	|	Document.СчетПроживания AS Folios
	|WHERE
	|	Folios.ГруппаГостей = &qGuestGroup
	|	AND (NOT Folios.IsClosed)
	|	AND (NOT Folios.DeletionMark)";
	vQry.SetParameter("qGuestGroup", pGuestGroup);
	vQryRes = vQry.Execute().Unload();
	// Remove folios where parent document is not accommodation
	i = 0;
	While i < vQryRes.Count() Do
		vRow = vQryRes.Get(i);
		If НЕ vRow.СчетПроживания.IsMaster Тогда
			If ЗначениеЗаполнено(vRow.СчетПроживания.ДокОснование) Тогда
				If TypeOf(vRow.СчетПроживания.ДокОснование) <> Type("DocumentRef.Размещение") And 
				   TypeOf(vRow.СчетПроживания.ДокОснование) <> Type("DocumentRef.Бронирование") Тогда
					vQryRes.Delete(vRow);
					Continue;
				Else
					If НЕ vRow.СчетПроживания.ДокОснование.Posted Тогда
						vQryRes.Delete(vRow);
						Continue;
					EndIf;
				EndIf;
			Else
				vQryRes.Delete(vRow);
				Continue;
			EndIf;
		EndIf;
		i = i + 1;
	EndDo;
	// Return folios count
	Return vQryRes.Count();
EndFunction //GetOpenFoliosCountForGuestGroup

//-----------------------------------------------------------------------------
Процедура UpdateReportingCurrencyExchangeRates(pDate, pIsPosted = False)
	// Do processing if document is not posted only
	If pIsPosted Тогда
		Return;
	EndIf;
	// Log start of charge reporting currency exchange rates update
	WriteLogEvent(NStr("en='CloseOfPeriod.ReportingCurrencyExchangeRatesUpdate';ru='ЗакрытиеПериода.ОбновлениеКурсовОтчетнойВалюты';de='CloseOfPeriod.ReportingCurrencyExchangeRatesUpdate'"), EventLogLevel.Information, Metadata(), Ref, NStr("en='Start reporting currency exchange rates update...';ru='Начата операция обновления курсов отчетной валюты...';de='Die Aktualisierung der Berichtswährungskurse wurde gestartet…'"), EventLogEntryTransactionMode.Transactional);
	// Initialize value list of charges processed
	vChargesProcessed = New СписокЗначений();
	// Get charges that should be recalculated
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	Начисление.Ref AS Начисление,
	|	ISNULL(КурсВалют.Rate, 0) AS CurrencyRate,
	|	ISNULL(КурсВалют.Factor, 0) AS CurrencyFactor
	|FROM
	|	Document.Начисление AS Начисление
	|		LEFT JOIN InformationRegister.КурсВалют.SliceLast(
	|				&qPeriod,
	|				Гостиница IN HIERARCHY (&qHotel)
	|					OR &qHotelIsEmpty) AS КурсВалют
	|		ON (КурсВалют.Валюта = Начисление.Валюта)
	|WHERE
	|	Начисление.Posted
	|	AND Начисление.ExchangeRateDate = &qDate
	|	AND Начисление.ReportingCurrencyExchangeRate <> (CAST(ISNULL(КурсВалют.Rate, 0) / ISNULL(КурсВалют.Factor, 1) AS NUMBER(19, 7)))
	|	AND (Начисление.Гостиница IN HIERARCHY (&qHotel)
	|			OR &qHotelIsEmpty)
	|	AND (Начисление.Фирма IN HIERARCHY (&qCompany)
	|			OR &qCompanyIsEmpty)";
	vQry.SetParameter("qHotel", Гостиница);
	vQry.SetParameter("qHotelIsEmpty", НЕ ЗначениеЗаполнено(Гостиница));
	vQry.SetParameter("qCompany", Company);
	vQry.SetParameter("qCompanyIsEmpty", НЕ ЗначениеЗаполнено(Company));
	vQry.SetParameter("qPeriod", EndOfDay(pDate));
	vQry.SetParameter("qDate", BegOfDay(pDate));
	vQryRes = vQry.Execute().Choose();
	While vQryRes.Next() Do
		If vQryRes.CurrencyRate > 0 And vQryRes.CurrencyFactor > 0 Тогда
			vChargeObj = vQryRes.Начисление.GetObject();
			If ЗначениеЗаполнено(vChargeObj.Валюта) Тогда
				vChargeObj.Write(DocumentWriteMode.Posting);
				// Add to charges processed value list
				vChargesProcessed.Add(vQryRes.Начисление);
			EndIf;
		EndIf;
	EndDo;
	// Repost storno based on charges processed
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	Сторно.Ref AS Сторно
	|FROM
	|	Document.Сторно AS Сторно
	|WHERE
	|	Сторно.Posted
	|	AND Сторно.Ref IN(&qCharges)";
	vQry.SetParameter("qCharges", vChargesProcessed);
	vQryRes = vQry.Execute().Choose();
	While vQryRes.Next() Do
		vStornoObj = vQryRes.Сторно.GetObject();
		vStornoObj.Write(DocumentWriteMode.Posting);
	EndDo;
	// Log end of charge reporting currency exchange rates update
	WriteLogEvent(NStr("en='CloseOfPeriod.ReportingCurrencyExchangeRatesUpdate';ru='ЗакрытиеПериода.ОбновлениеКурсовОтчетнойВалюты';de='CloseOfPeriod.ReportingCurrencyExchangeRatesUpdate'"), EventLogLevel.Information, Metadata(), Ref, NStr("en='Number of charges where reporting currency exchange rates were updated is ';ru='Обновлены курсы отчетной валюты у начислений: ';de='Die Kurse der Berichtswährung bei Anrechnungen sind aktualisiert: '") + vChargesProcessed.Count(), EventLogEntryTransactionMode.Transactional);
КонецПроцедуры //UpdateReportingCurrencyExchangeRates 

//-----------------------------------------------------------------------------
Процедура DeleteServicesThatShouldBeChargedExternally(pIsPosted)
	// Do processing if document is not posted only
	If pIsPosted Тогда
		Return;
	EndIf;
	// Log start of charge reporting currency exchange rates update
	WriteLogEvent(NStr("en='CloseOfPeriod.DeleteServicesThatShouldBeChargedExternally';de='CloseOfPeriod.DeleteServicesThatShouldBeChargedExternally';ru='ЗакрытиеПериода.УдалениеУслугКоторыеДолжныБытьНачисленыИзВнешнейСистемы'"), EventLogLevel.Information, Metadata(), Ref, NStr("ru = 'Начата операция удаления начислений...';en = 'Start deletion of charges...';de = 'Start deletion of charges...'"), EventLogEntryTransactionMode.Transactional);
	// Initialize value list of documents processed
	vDocsProcessed = New СписокЗначений();
	// Get accommodations that should be reposted
	vQry = New Query();
	vQry.Text = 
	"SELECT DISTINCT
	|	Размещение.Ref AS Doc
	|FROM
	|	Document.Размещение.Услуги AS Размещение
	|WHERE
	|	Размещение.Ref.Posted
	|	AND Размещение.Ref.СтатусРазмещения.IsActive
	|	AND Размещение.Ref.CheckInDate < &qEndOfDate
	|	AND Размещение.Ref.CheckOutDate > &qBegOfDate
	|	AND ISNULL(Размещение.Услуга.ServiceType.ActualAmountIsChargedExternally, FALSE)
	|	AND (Размещение.Ref.Гостиница IN HIERARCHY (&qHotel)
	|			OR &qHotelIsEmpty)
	|	AND (Размещение.СчетПроживания.Фирма IN HIERARCHY (&qCompany)
	|			OR &qCompanyIsEmpty)";
	vQry.SetParameter("qHotel", Гостиница);
	vQry.SetParameter("qHotelIsEmpty", НЕ ЗначениеЗаполнено(Гостиница));
	vQry.SetParameter("qCompany", Company);
	vQry.SetParameter("qCompanyIsEmpty", НЕ ЗначениеЗаполнено(Company));
	vQry.SetParameter("qEndOfDate", EndOfDay(Date));
	vQry.SetParameter("qBegOfDate", BegOfDay(Date));
	vQryRes = vQry.Execute().Choose();
	While vQryRes.Next() Do
		vAccObj = vQryRes.Doc.GetObject();
		vAccObj.Write(DocumentWriteMode.Posting);
		// Add to charges processed value list
		vDocsProcessed.Add(vQryRes.Doc);
	EndDo;
	// Log end of charge reporting currency exchange rates update
	WriteLogEvent(NStr("en='CloseOfPeriod.DeleteServicesThatShouldBeChargedExternally';de='CloseOfPeriod.DeleteServicesThatShouldBeChargedExternally';ru='ЗакрытиеПериода.УдалениеУслугКоторыеДолжныБытьНачисленыИзВнешнейСистемы'"), EventLogLevel.Information, Metadata(), Ref, NStr("ru = 'Кол-во перепроведенных размещений: ';en = 'Number of reposted accommodations is: ';de = 'Number of reposted accommodations is: '") + vDocsProcessed.Count(), EventLogEntryTransactionMode.Transactional);
	// Initialize value list of documents processed
	vDocsProcessed = New СписокЗначений();
	// Get resource reservations that should be reposted
	vQry = New Query();
	vQry.Text = 
	"SELECT DISTINCT
	|	ResourceReservations.Ref AS Doc
	|FROM
	|	Document.БроньУслуг.Услуги AS ResourceReservations
	|WHERE
	|	ResourceReservations.Ref.Posted
	|	AND ResourceReservations.Ref.ResourceReservationStatus.IsActive
	|	AND NOT ResourceReservations.Ref.ResourceReservationStatus.DoCharging
	|	AND ResourceReservations.Ref.DateTimeFrom < &qEndOfDate
	|	AND ResourceReservations.Ref.DateTimeTo > &qBegOfDate
	|	AND ISNULL(ResourceReservations.Услуга.ServiceType.ActualAmountIsChargedExternally, FALSE)
	|	AND (ResourceReservations.Ref.Гостиница IN HIERARCHY (&qHotel)
	|			OR &qHotelIsEmpty)
	|	AND (ResourceReservations.Ref.ChargingFolio.Фирма IN HIERARCHY (&qCompany)
	|			OR &qCompanyIsEmpty)";
	vQry.SetParameter("qHotel", Гостиница);
	vQry.SetParameter("qHotelIsEmpty", НЕ ЗначениеЗаполнено(Гостиница));
	vQry.SetParameter("qCompany", Company);
	vQry.SetParameter("qCompanyIsEmpty", НЕ ЗначениеЗаполнено(Company));
	vQry.SetParameter("qEndOfDate", EndOfDay(Date));
	vQry.SetParameter("qBegOfDate", BegOfDay(Date));
	vQryRes = vQry.Execute().Choose();
	While vQryRes.Next() Do
		vRRObj = vQryRes.Doc.GetObject();
		vRRObj.Write(DocumentWriteMode.Posting);
		// Add to charges processed value list
		vDocsProcessed.Add(vQryRes.Doc);
	EndDo;
	// Log end of charge reporting currency exchange rates update
	WriteLogEvent(NStr("en='CloseOfPeriod.DeleteServicesThatShouldBeChargedExternally';de='CloseOfPeriod.DeleteServicesThatShouldBeChargedExternally';ru='ЗакрытиеПериода.УдалениеУслугКоторыеДолжныБытьНачисленыИзВнешнейСистемы'"), EventLogLevel.Information, Metadata(), Ref, NStr("ru = 'Кол-во перепроведенных броней ресурсов: ';en = 'Number of reposted resource reservations is: ';de = 'Number of reposted resource reservations is: '") + vDocsProcessed.Count(), EventLogEntryTransactionMode.Transactional);
КонецПроцедуры //DeleteServicesThatShouldBeChargedExternally 

//-----------------------------------------------------------------------------
Function CheckRevenueServicesCount(pDimensionsRow)
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	COUNT(*) AS Count
	|FROM
	|	AccumulationRegister.РелизацияТекОтчетПериод AS РелизацияТекОтчетПериод
	|WHERE
	|	РелизацияТекОтчетПериод.Period >= &qPeriodFrom
	|	AND РелизацияТекОтчетПериод.Гостиница = &qHotel
	|	AND РелизацияТекОтчетПериод.Фирма = &qCompany
	|	AND РелизацияТекОтчетПериод.Контрагент = &qCustomer
	|	AND РелизацияТекОтчетПериод.Договор = &qContract
	|	AND РелизацияТекОтчетПериод.ГруппаГостей = &qGuestGroup
	|	AND РелизацияТекОтчетПериод.ВалютаЛицСчета = &qFolioCurrency
	|	AND (РелизацияТекОтчетПериод.Начисление.IsRoomRevenue
	|			OR РелизацияТекОтчетПериод.Начисление.IsResourceRevenue)" +
		?(ЗначениеЗаполнено(pDimensionsRow.SeparateAccommodation), " AND ДокОснование = &qAccommodation", "") + 
		?(ЗначениеЗаполнено(pDimensionsRow.SeparateService), " AND Начисление.Услуга = &qService", "");
	vQry.SetParameter("qPeriodFrom", Date + 1);
	vQry.SetParameter("qHotel", pDimensionsRow.Гостиница);
	vQry.SetParameter("qCompany", pDimensionsRow.Фирма);
	vQry.SetParameter("qCustomer", pDimensionsRow.Контрагент);
	vQry.SetParameter("qContract", pDimensionsRow.Договор);
	vQry.SetParameter("qGuestGroup", pDimensionsRow.ГруппаГостей);
	vQry.SetParameter("qFolioCurrency", pDimensionsRow.ВалютаЛицСчета);
	vQry.SetParameter("qAccommodation", pDimensionsRow.SeparateAccommodation);
	vQry.SetParameter("qService", pDimensionsRow.SeparateService);
	vCharges = vQry.Execute().Unload();
	If vCharges.Count() > 0 Тогда
		If vCharges.Get(0).Count = 0 Тогда
			Return True;
		Else
			Return False;
		Endif;
	Else
		Return False;
	EndIf;
EndFunction //CheckRevenueServicesCount

//-----------------------------------------------------------------------------
Function GetGuestGroupsWithCorrections(pIsPosted = False)
	vGuestGroupsWithCorrections = New СписокЗначений();
	// Do processing if document is not posted only
	If pIsPosted Тогда
		Return vGuestGroupsWithCorrections;
	EndIf;
	// Date to be used to retreive balances
	vDate = Date + 1;
	// Date to be used to decide that it is previous period correction
	vCorrectionsBoundaryDate = BegOfMonth(Date);
	// Run query to get all guest groups with current receivable accounts balances
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	CurrentAccountsReceivableBalance.Гостиница AS Гостиница,
	|	CurrentAccountsReceivableBalance.Фирма AS Фирма,
	|	CurrentAccountsReceivableBalance.Контрагент AS Контрагент,
	|	CurrentAccountsReceivableBalance.Договор AS Договор,
	|	CurrentAccountsReceivableBalance.ГруппаГостей AS ГруппаГостей,
	|	CurrentAccountsReceivableBalance.ВалютаЛицСчета AS ВалютаЛицСчета,
	|	SUM(CurrentAccountsReceivableBalance.SumBalance) AS Amount
	|FROM
	|	AccumulationRegister.РелизацияТекОтчетПериод.Balance(
	|		&qDate, TRUE " +
			?(ЗначениеЗаполнено(Гостиница), " AND Гостиница IN HIERARCHY(&qHotel)", "") + 
			?(ЗначениеЗаполнено(Company), " AND Фирма IN HIERARCHY(&qCompany)", "") + 
			?(ProcessClosedFoliosOnly, " AND (ISNULL(СчетПроживания.IsClosed, FALSE) AND NOT ISNULL(ГруппаГостей.IsPending, FALSE) OR Начисление.Услуга.IsStockArticle OR (СчетПроживания.DateTimeTo = &qEmptyDate AND &qEndOfMonth))", "") + "
	|		AND ISNULL(Начисление.ДатаДок, &qEmptyDate) <= &qPeriodTo
	|	) AS CurrentAccountsReceivableBalance
	|
	|GROUP BY
	|	CurrentAccountsReceivableBalance.Гостиница,
	|	CurrentAccountsReceivableBalance.Фирма,
	|	CurrentAccountsReceivableBalance.Контрагент,
	|	CurrentAccountsReceivableBalance.Договор,
	|	CurrentAccountsReceivableBalance.ГруппаГостей, 
	|	CurrentAccountsReceivableBalance.ВалютаЛицСчета";
	vQry.SetParameter("qDate", New Boundary(vDate, BoundaryType.Excluding));
	vQry.SetParameter("qHotel", Гостиница);
	vQry.SetParameter("qCompany", Company);
	vQry.SetParameter("qPeriodTo", Date);
	vQry.SetParameter("qEmptyDate", '00010101');
	vQry.SetParameter("qEndOfMonth", ?(EndOfDay(Date) = EndOfMonth(Date), True, False));
	vGroups = vQry.Execute().Unload();
	For Each vGroupsRow In vGroups Do
		vHasCorrections = False;
		vGroupCheckOutDate = vGroupsRow.GuestGroup.CheckOutDate;
		If vGroupsRow.Amount < 0 Тогда
			// If guest group amount is negative then it is correction
			vHasCorrections = True;
		ElsIf ЗначениеЗаполнено(vGroupCheckOutDate) And vGroupCheckOutDate < vCorrectionsBoundaryDate Тогда
			// If guest group check-out date is earlier then accounting period start date then it is correction
			vHasCorrections = True;
		EndIf;
		If vHasCorrections Тогда
			If vGuestGroupsWithCorrections.FindByValue(vGroupsRow.GuestGroup) = Неопределено Тогда
				vGuestGroupsWithCorrections.Add(vGroupsRow.GuestGroup);
			EndIf;
		EndIf;
	EndDo;
	Return vGuestGroupsWithCorrections;
EndFunction //GetGuestGroupsWithCorrections

//-----------------------------------------------------------------------------
Процедура CloseHotelProducts(pCancel, pPostingMode, pIsPosted = False, pGuestGroupsWithCorrections)
	// Do processing if document is not posted only
	If pIsPosted Тогда
		Return;
	EndIf;
	WriteLogEvent(NStr("en='CloseOfPeriod.BuildSettlementsForHotelProducts';ru='ЗакрытиеПериода.ФормированиеАктовПоПутевкам';de='CloseOfPeriod.BuildSettlementsForHotelProducts'"), EventLogLevel.Information, Metadata(), Ref, NStr("en='Start of building hotel product settlements...';ru='Начата операция формирования актов по путевкам...';de='Erstellung von Übergabeprotokollen zu Reiseschecks wurde gestartet…'"), EventLogEntryTransactionMode.Transactional);
	// Check if there are any companies waiting for hotel products
	If ЗначениеЗаполнено(Company) And НЕ Company.WaitForHotelProduct Тогда
		WriteLogEvent(NStr("en='CloseOfPeriod.BuildSettlementsForHotelProducts';ru='ЗакрытиеПериода.ФормированиеАктовПоПутевкам';de='CloseOfPeriod.BuildSettlementsForHotelProducts'"), EventLogLevel.Information, Metadata(), Ref, NStr("en='Гостиница products are not used! End of building hotel product settlements';ru='Путевки с ожиданием ввода номеров не используются! Операция формирования актов по путевкам завершена';de='Reisechecks mit erwarteter Eingabe der Nummern werden nicht verwendet! Die Erstellung eines Vorgangs nach Reisechecks ist beendet'"), EventLogEntryTransactionMode.Transactional);
		Return;
	Else
		vCompanyQry = New Query();
		vCompanyQry.Text = 
		"SELECT
		|	Фирмы.Ref
		|FROM
		|	Catalog.Фирмы AS Companies
		|WHERE
		|	Фирмы.WaitForHotelProduct
		|	AND NOT Фирмы.IsFolder";
		vCompanies = vCompanyQry.Execute().Unload();
		If vCompanies.Count() = 0 Тогда
			WriteLogEvent(NStr("en='CloseOfPeriod.BuildSettlementsForHotelProducts';ru='ЗакрытиеПериода.ФормированиеАктовПоПутевкам';de='CloseOfPeriod.BuildSettlementsForHotelProducts'"), EventLogLevel.Information, Metadata(), Ref, NStr("en='Гостиница products are not used! End of building hotel product settlements';ru='Путевки с ожиданием ввода номеров не используются! Операция формирования актов по путевкам завершена';de='Reisechecks mit erwarteter Eingabe der Nummern werden nicht verwendet! Die Erstellung eines Vorgangs nach Reisechecks ist beendet'"), EventLogEntryTransactionMode.Transactional);
			Return;
		EndIf;
	EndIf;
	// Date to be used to retreive balances
	vDate = '39991231235959';
	// Get table with customers, contracts and guest groups with balances in Current Accounts Receivable
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	CurrentAccountsReceivableBalance.Гостиница AS Гостиница,
	|	CurrentAccountsReceivableBalance.Фирма AS Фирма,
	|	CurrentAccountsReceivableBalance.Контрагент AS Контрагент,
	|	CurrentAccountsReceivableBalance.Договор AS Договор,
	|	CASE
	|		WHEN CurrentAccountsReceivableBalance.ГруппаГостей IN (&qGuestGroupsWithCorrections) THEN
	|			CurrentAccountsReceivableBalance.ГруппаГостей 
	|		WHEN &qOneSettlementPerCustomerGuestGroups THEN
	|			&qEmptyGuestGroup
	|		WHEN &qOneSettlementPerIndividualsCustomerGuestGroups AND 
	|		     (CurrentAccountsReceivableBalance.Контрагент = &qEmptyCustomer OR CurrentAccountsReceivableBalance.Контрагент = CurrentAccountsReceivableBalance.Гостиница.IndividualsCustomer) THEN
	|			&qEmptyGuestGroup
	|		ELSE 
	|			CurrentAccountsReceivableBalance.ГруппаГостей 
	|	END AS ГруппаГостей,
	|	CASE
	|		WHEN CurrentAccountsReceivableBalance.ГруппаГостей IN (&qGuestGroupsWithCorrections) THEN
	|			CurrentAccountsReceivableBalance.ГруппаГостей.Code 
	|		WHEN &qOneSettlementPerCustomerGuestGroups THEN
	|			0
	|		WHEN &qOneSettlementPerIndividualsCustomerGuestGroups AND 
	|		     (CurrentAccountsReceivableBalance.Контрагент = &qEmptyCustomer OR CurrentAccountsReceivableBalance.Контрагент = CurrentAccountsReceivableBalance.Гостиница.IndividualsCustomer) THEN
	|			0
	|		WHEN CurrentAccountsReceivableBalance.ГруппаГостей = &qEmptyGuestGroup THEN
	|			999999999999
	|		ELSE 
	|			CurrentAccountsReceivableBalance.ГруппаГостей.Code 
	|	END AS GuestGroupCode,
	|	CurrentAccountsReceivableBalance.ВалютаЛицСчета AS ВалютаЛицСчета,
	|	CASE
	|		WHEN &qSplitSettllementsByVATRate THEN
	|			CurrentAccountsReceivableBalance.Начисление.СтавкаНДС
	|		ELSE
	|			&qEmptyVATRate
	|	END AS СтавкаНДС,
	|	CurrentAccountsReceivableBalance.Контрагент.Description AS CustomerDescription,
	|	CurrentAccountsReceivableBalance.Договор.Description AS ContractDescription,
	|	CASE
	|		WHEN ISNULL(CurrentAccountsReceivableBalance.ДокОснование.HasOfficialLetter, FALSE) THEN
	|			CurrentAccountsReceivableBalance.ДокОснование
	|		ELSE &qEmptyAccommodation
	|	END AS SeparateAccommodation,
	|	CASE 
	|		WHEN ISNULL(CurrentAccountsReceivableBalance.Начисление.Услуга.SplitToSeparateSettlements, FALSE) THEN
	|			CurrentAccountsReceivableBalance.Начисление.Услуга
	|		WHEN ISNULL(CurrentAccountsReceivableBalance.Начисление.Услуга.DoNotExportToTheAccountingSystem, FALSE) THEN
	|			CurrentAccountsReceivableBalance.Начисление.Услуга
	|		ELSE &qEmptyService
	|	END AS SeparateService,
	|	ISNULL(CurrentAccountsReceivableBalance.Начисление.ПутевкаКурсовка.Parent, &qEmptyHotelProduct) AS HotelProductParent
	|FROM
	|	AccumulationRegister.РелизацияТекОтчетПериод.Balance(
	|		&qDate, 
	|		Начисление.Услуга.IsHotelProductService 
	|		AND Фирма.WaitForHotelProduct 
	|		AND Начисление.ПутевкаКурсовка <> &qEmptyHotelProduct
	|		" + 
			?(ЗначениеЗаполнено(Гостиница), " AND Гостиница IN HIERARCHY(&qHotel)", "") + 
			?(ЗначениеЗаполнено(Company), " AND Фирма IN HIERARCHY(&qCompany)", "") + 
			?(ProcessClosedFoliosOnly, " AND ISNULL(СчетПроживания.IsClosed, FALSE) AND NOT ISNULL(ГруппаГостей.IsPending, FALSE)", "") + "
	|		AND ISNULL(СчетПроживания.DateTimeFrom, &qEmptyDate) <= &qPeriodTo
	|	) AS CurrentAccountsReceivableBalance
	|
	|GROUP BY
	|	CurrentAccountsReceivableBalance.Гостиница,
	|	CurrentAccountsReceivableBalance.Фирма,
	|	CurrentAccountsReceivableBalance.Контрагент,
	|	CurrentAccountsReceivableBalance.Договор,
	|	CASE
	|		WHEN CurrentAccountsReceivableBalance.ГруппаГостей IN (&qGuestGroupsWithCorrections) THEN
	|			CurrentAccountsReceivableBalance.ГруппаГостей 
	|		WHEN &qOneSettlementPerCustomerGuestGroups THEN
	|			&qEmptyGuestGroup
	|		WHEN &qOneSettlementPerIndividualsCustomerGuestGroups AND 
	|		     (CurrentAccountsReceivableBalance.Контрагент = &qEmptyCustomer OR CurrentAccountsReceivableBalance.Контрагент = CurrentAccountsReceivableBalance.Гостиница.IndividualsCustomer) THEN
	|			&qEmptyGuestGroup
	|		ELSE 
	|			CurrentAccountsReceivableBalance.ГруппаГостей 
	|	END,
	|	CASE
	|		WHEN CurrentAccountsReceivableBalance.ГруппаГостей IN (&qGuestGroupsWithCorrections) THEN
	|			CurrentAccountsReceivableBalance.ГруппаГостей.Code 
	|		WHEN &qOneSettlementPerCustomerGuestGroups THEN
	|			0
	|		WHEN &qOneSettlementPerIndividualsCustomerGuestGroups AND 
	|		     (CurrentAccountsReceivableBalance.Контрагент = &qEmptyCustomer OR CurrentAccountsReceivableBalance.Контрагент = CurrentAccountsReceivableBalance.Гостиница.IndividualsCustomer) THEN
	|			0
	|		WHEN CurrentAccountsReceivableBalance.ГруппаГостей = &qEmptyGuestGroup THEN
	|			999999999999
	|		ELSE 
	|			CurrentAccountsReceivableBalance.ГруппаГостей.Code 
	|	END,
	|	CurrentAccountsReceivableBalance.ВалютаЛицСчета,
	|	CASE
	|		WHEN &qSplitSettllementsByVATRate THEN
	|			CurrentAccountsReceivableBalance.Начисление.СтавкаНДС
	|		ELSE
	|			&qEmptyVATRate
	|	END,
	|	CASE
	|		WHEN ISNULL(CurrentAccountsReceivableBalance.ДокОснование.HasOfficialLetter, FALSE) THEN
	|			CurrentAccountsReceivableBalance.ДокОснование
	|		ELSE &qEmptyAccommodation
	|	END,
	|	CASE 
	|		WHEN ISNULL(CurrentAccountsReceivableBalance.Начисление.Услуга.SplitToSeparateSettlements, FALSE) THEN
	|			CurrentAccountsReceivableBalance.Начисление.Услуга
	|		WHEN ISNULL(CurrentAccountsReceivableBalance.Начисление.Услуга.DoNotExportToTheAccountingSystem, FALSE) THEN
	|			CurrentAccountsReceivableBalance.Начисление.Услуга
	|		ELSE &qEmptyService
	|	END,
	|	ISNULL(CurrentAccountsReceivableBalance.Начисление.ПутевкаКурсовка.Parent, &qEmptyHotelProduct)
	|ORDER BY
	|	CustomerDescription,
	|	ContractDescription,
	|	GuestGroupCode,
	|	ВалютаЛицСчета.ПорядокСортировки,
	|	SeparateAccommodation DESC,
	|	SeparateService DESC";
	vQry.SetParameter("qDate", New Boundary(vDate, BoundaryType.Excluding));
	vQry.SetParameter("qHotel", Гостиница);
	vQry.SetParameter("qCompany", Company);
	vQry.SetParameter("qEmptyCustomer", Справочники.Контрагенты.EmptyRef());
	vQry.SetParameter("qEmptyGuestGroup", Справочники.ГруппыГостей.EmptyRef());
	vQry.SetParameter("qEmptyAccommodation", Documents.Размещение.EmptyRef());
	vQry.SetParameter("qEmptyService", Справочники.Услуги.EmptyRef());
	vQry.SetParameter("qOneSettlementPerCustomerGuestGroups", OneSettlementPerCustomerGuestGroups);
	vQry.SetParameter("qOneSettlementPerIndividualsCustomerGuestGroups", OneSettlementPerIndividualsCustomerGuestGroups);
	vQry.SetParameter("qSplitSettllementsByVATRate", SplitSettllementsByVATRate);
	vQry.SetParameter("qEmptyVATRate", Неопределено);
	vQry.SetParameter("qPeriodTo", Date);
	vQry.SetParameter("qEmptyDate", '00010101');
	vQry.SetParameter("qEmptyHotelProduct", Справочники.ПутевкиКурсовки.EmptyRef());
	vQry.SetParameter("qGuestGroupsWithCorrections", pGuestGroupsWithCorrections);
	vDimensions = vQry.Execute().Unload();
	// Create settlement for each row in dimensions table
	For Each vDimensionsRow In vDimensions Do
		// If only closed folios should be procesed then check that all 
		// folios of the current guest group are closed
		If ProcessClosedFoliosOnly Тогда
			If ЗначениеЗаполнено(vDimensionsRow.Company) And 
			   ЗначениеЗаполнено(vDimensionsRow.Фирма.CompanyAccountingPolicyType) Тогда
				If vDimensionsRow.Фирма.CompanyAccountingPolicyType = Перечисления.CompanyAccountingPolicyTypes.ByCheckedOutGuestGroupsServices Тогда
					vGuestGroup = vDimensionsRow.GuestGroup;
					If ЗначениеЗаполнено(vGuestGroup) Тогда
						vCount = GetOpenFoliosCountForGuestGroup(vGuestGroup);
						If vCount > 0 Тогда
							Continue;
						EndIf;
					EndIf;
				EndIf;
			EndIf;
		EndIf;
		
		// Fill dimensions and accounting currency
		vAccountingCustomer = Справочники.Контрагенты.EmptyRef();
		vAccountingContract = Справочники.Договора.EmptyRef();
		vLanguage = Неопределено;
		If ЗначениеЗаполнено(vDimensionsRow.Customer) Тогда
			vAccountingCustomer = vDimensionsRow.Контрагент;
			// Get Контрагент language
			If ЗначениеЗаполнено(vAccountingCustomer) Тогда
				vLanguage = vAccountingCustomer.Language;
			EndIf;
		Else
			If ЗначениеЗаполнено(vDimensionsRow.Гостиница) Тогда
				vAccountingCustomer = vDimensionsRow.Гостиница.IndividualsCustomer;
				vAccountingContract = vDimensionsRow.Гостиница.IndividualsContract;
			EndIf;
		EndIf;
		If ЗначениеЗаполнено(vDimensionsRow.Contract) Тогда
			vAccountingContract = vDimensionsRow.Contract;
		EndIf;
		vAccountingCurrency = vDimensionsRow.FolioCurrency;
		
		// Skip individuals if neccessary
		If DoNotCloseIndividuals And ЗначениеЗаполнено(vDimensionsRow.Гостиница) Тогда
			If ЗначениеЗаполнено(vDimensionsRow.Гостиница.IndividualsCustomer) And vAccountingCustomer = vDimensionsRow.Гостиница.IndividualsCustomer Тогда
				Continue;
			EndIf;
		EndIf;
		
		// Check if current guest group is in the corrections list
		vIsCorrection = False;
		If pGuestGroupsWithCorrections.FindByValue(vDimensionsRow.GuestGroup) <> Неопределено Тогда
			vIsCorrection = True;
		EndIf;
		
		// Retrieve all balances for the current dimensions where folio payment method is by bank transfer
		vQry = New Query();
		vQry.Text = 
		"SELECT
		|	CurrentAccountsReceivableBalance.Гостиница,
		|	CurrentAccountsReceivableBalance.Фирма,
		|	CurrentAccountsReceivableBalance.Контрагент,
		|	CurrentAccountsReceivableBalance.Договор,
		|	CurrentAccountsReceivableBalance.ГруппаГостей,
		|	CurrentAccountsReceivableBalance.ВалютаЛицСчета,
		|	CurrentAccountsReceivableBalance.СчетПроживания,
		|	CurrentAccountsReceivableBalance.ДокОснование,
		|	CurrentAccountsReceivableBalance.Начисление.ПутевкаКурсовка AS ПутевкаКурсовка,
		|	CurrentAccountsReceivableBalance.Начисление,
		|	CurrentAccountsReceivableBalance.Начисление.Скидка AS Скидка,
		|	CurrentAccountsReceivableBalance.Начисление.СуммаСкидки AS СуммаСкидки,
		|	CurrentAccountsReceivableBalance.Начисление.ВидКомиссииАгента AS ВидКомиссииАгента,
		|	CurrentAccountsReceivableBalance.Начисление.КомиссияАгента AS КомиссияАгента,
		|	ISNULL(CurrentAccountsReceivableBalance.Начисление.ПутевкаКурсовка.Parent, &qEmptyHotelProduct) AS HotelProductParent,
		|	CurrentAccountsReceivableBalance.CommissionSumBalance,
		|	CurrentAccountsReceivableBalance.SumBalance,
		|	CurrentAccountsReceivableBalance.VATSumBalance,
		|	CurrentAccountsReceivableBalance.QuantityBalance,
		|	CurrentAccountsReceivableBalance.Начисление.PointInTime AS ChargePointInTime
		|FROM
		|	AccumulationRegister.РелизацияТекОтчетПериод.Balance(
		|		&qDate, 
		|		Начисление.Услуга.IsHotelProductService 
		|		AND Фирма.WaitForHotelProduct 
		|		AND Начисление.ПутевкаКурсовка <> &qEmptyHotelProduct
		|		AND Гостиница = &qHotel
		|		AND Фирма = &qCompany
		|		AND Контрагент = &qCustomer
		|		AND Договор = &qContract" + 
				?(vIsCorrection, "", ?(OneSettlementPerCustomerGuestGroups, "", ?(OneSettlementPerIndividualsCustomerGuestGroups, "", " AND ГруппаГостей = &qGuestGroup"))) + 
				?(vIsCorrection, "", ?(OneSettlementPerIndividualsCustomerGuestGroups, " AND (ГруппаГостей = &qGuestGroup OR &qGuestGroupIsEmpty)", "")) + 
				?(vIsCorrection, " AND ГруппаГостей = &qGuestGroup", "") + 
				?(SplitSettllementsByVATRate, " AND Начисление.СтавкаНДС = &qVATRate", "") + "
		|		AND ISNULL(СчетПроживания.DateTimeFrom, &qEmptyDate) <= &qPeriodTo
		|		AND ISNULL(Начисление.ПутевкаКурсовка.Parent, &qEmptyHotelProduct) = &qHotelProductParent
		|		AND ВалютаЛицСчета = &qFolioCurrency" + 
				?(ProcessClosedFoliosOnly, " AND ISNULL(СчетПроживания.IsClosed, FALSE)", "") + 
				?(ЗначениеЗаполнено(vDimensionsRow.SeparateAccommodation), " AND ДокОснование = &qAccommodation", "") + 
				?(ЗначениеЗаполнено(vDimensionsRow.SeparateService), " AND Начисление.Услуга = &qService", "") + "
		|	) AS CurrentAccountsReceivableBalance
		|
		|ORDER BY
		|	ChargePointInTime";
		vQry.SetParameter("qDate", New Boundary(vDate, BoundaryType.Excluding));
		vQry.SetParameter("qHotel", vDimensionsRow.Гостиница);
		vQry.SetParameter("qCompany", vDimensionsRow.Company);
		vQry.SetParameter("qCustomer", vDimensionsRow.Customer);
		vQry.SetParameter("qContract", vDimensionsRow.Contract);
		vQry.SetParameter("qGuestGroup", vDimensionsRow.GuestGroup);
		vQry.SetParameter("qGuestGroupIsEmpty", НЕ ЗначениеЗаполнено(vDimensionsRow.GuestGroup));
		vQry.SetParameter("qFolioCurrency", vDimensionsRow.FolioCurrency);
		vQry.SetParameter("qAccommodation", vDimensionsRow.SeparateAccommodation);
		vQry.SetParameter("qService", vDimensionsRow.SeparateService);
		vQry.SetParameter("qVATRate", vDimensionsRow.VATRate);
		vQry.SetParameter("qHotelProductParent", vDimensionsRow.HotelProductParent);
		vQry.SetParameter("qPeriodTo", Date);
		vQry.SetParameter("qEmptyDate", '00010101');
		vQry.SetParameter("qEmptyHotelProduct", Справочники.ПутевкиКурсовки.EmptyRef());
		vCharges = vQry.Execute().Unload();
		If vCharges.Count() > 0 Тогда
			// Create settlement and fill it's services with charges retrieved
			CreateAndPostSettlement(vDimensionsRow, vAccountingCustomer, vAccountingContract, vAccountingCurrency, 
			                        vLanguage, vCharges, False);
		EndIf;
	EndDo;
	WriteLogEvent(NStr("en='CloseOfPeriod.BuildSettlementsForHotelProducts';ru='ЗакрытиеПериода.ФормированиеАктовПоПутевкам';de='CloseOfPeriod.BuildSettlementsForHotelProducts'"), EventLogLevel.Information, Metadata(), Ref, NStr("en='End of building hotel product settlements';ru='Закончена операция формирования актов по путевкам';de='Die Erstellung von Übergabeprotokollen zu Reisepapieren ist abgeschlossen'"), EventLogEntryTransactionMode.Transactional);
КонецПроцедуры //CloseHotelProducts

//-----------------------------------------------------------------------------
Процедура CloseCurrentAccountsReceivable(pCancel, pPostingMode, pIsPosted = False, pGuestGroupsWithCorrections)
	// Do processing if document is not posted only
	If pIsPosted Тогда
		Return;
	EndIf;
	WriteLogEvent(NStr("en='CloseOfPeriod.BuildSettlements';ru='ЗакрытиеПериода.ФормированиеАктов';de='CloseOfPeriod.BuildSettlements'"), EventLogLevel.Information, Metadata(), Ref, NStr("en='Start of building settlements...';ru='Начата операция формирования актов...';de='Erstellung von Übergabeprotokollen wurde gestartet…'"), EventLogEntryTransactionMode.Transactional);
	// Check if there are any companies waiting for hotel products
	vNoHotelProducts = False;
	If ЗначениеЗаполнено(Company) And НЕ Company.WaitForHotelProduct Тогда
		vNoHotelProducts = True;
	Else
		vCompanyQry = New Query();
		vCompanyQry.Text = 
		"SELECT
		|	Фирмы.Ref
		|FROM
		|	Catalog.Фирмы AS Companies
		|WHERE
		|	Фирмы.WaitForHotelProduct
		|	AND NOT Фирмы.IsFolder";
		vCompanies = vCompanyQry.Execute().Unload();
		If vCompanies.Count() = 0 Тогда
			vNoHotelProducts = True;
		EndIf;
	EndIf;
	// Date to be used to retreive balances
	vDate = Date + 1;
	// Get table with customers, contracts and guest groups with balances in Current Accounts Receivable
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	CurrentAccountsReceivableBalance.Гостиница AS Гостиница,
	|	CurrentAccountsReceivableBalance.Фирма AS Фирма,
	|	CurrentAccountsReceivableBalance.Контрагент AS Контрагент,
	|	CurrentAccountsReceivableBalance.Договор AS Договор,
	|	CASE
	|		WHEN CurrentAccountsReceivableBalance.ГруппаГостей IN (&qGuestGroupsWithCorrections) THEN
	|			CurrentAccountsReceivableBalance.ГруппаГостей 
	|		WHEN &qOneSettlementPerCustomerGuestGroups THEN
	|			&qEmptyGuestGroup
	|		WHEN &qOneSettlementPerIndividualsCustomerGuestGroups AND 
	|		     (CurrentAccountsReceivableBalance.Контрагент = &qEmptyCustomer OR CurrentAccountsReceivableBalance.Контрагент = CurrentAccountsReceivableBalance.Гостиница.IndividualsCustomer) THEN
	|			&qEmptyGuestGroup
	|		ELSE 
	|			CurrentAccountsReceivableBalance.ГруппаГостей 
	|	END AS ГруппаГостей,
	|	CASE
	|		WHEN CurrentAccountsReceivableBalance.ГруппаГостей IN (&qGuestGroupsWithCorrections) THEN
	|			CurrentAccountsReceivableBalance.ГруппаГостей.Code 
	|		WHEN &qOneSettlementPerCustomerGuestGroups THEN
	|			0
	|		WHEN &qOneSettlementPerIndividualsCustomerGuestGroups AND 
	|		     (CurrentAccountsReceivableBalance.Контрагент = &qEmptyCustomer OR CurrentAccountsReceivableBalance.Контрагент = CurrentAccountsReceivableBalance.Гостиница.IndividualsCustomer) THEN
	|			0
	|		WHEN CurrentAccountsReceivableBalance.ГруппаГостей = &qEmptyGuestGroup THEN
	|			999999999999
	|		ELSE 
	|			CurrentAccountsReceivableBalance.ГруппаГостей.Code 
	|	END AS GuestGroupCode,
	|	CurrentAccountsReceivableBalance.ВалютаЛицСчета AS ВалютаЛицСчета,
	|	CASE
	|		WHEN &qSplitSettllementsByVATRate THEN
	|			CurrentAccountsReceivableBalance.Начисление.СтавкаНДС
	|		ELSE
	|			&qEmptyVATRate
	|	END AS СтавкаНДС,
	|	CurrentAccountsReceivableBalance.Контрагент.Description AS CustomerDescription,
	|	CurrentAccountsReceivableBalance.Договор.Description AS ContractDescription,
	|	CASE
	|		WHEN ISNULL(CurrentAccountsReceivableBalance.ДокОснование.HasOfficialLetter, FALSE) THEN
	|			CurrentAccountsReceivableBalance.ДокОснование
	|		ELSE &qEmptyAccommodation
	|	END AS SeparateAccommodation,
	|	CASE 
	|		WHEN ISNULL(CurrentAccountsReceivableBalance.Начисление.Услуга.SplitToSeparateSettlements, FALSE) THEN
	|			CurrentAccountsReceivableBalance.Начисление.Услуга
	|		WHEN ISNULL(CurrentAccountsReceivableBalance.Начисление.Услуга.DoNotExportToTheAccountingSystem, FALSE) THEN
	|			CurrentAccountsReceivableBalance.Начисление.Услуга
	|		ELSE &qEmptyService
	|	END AS SeparateService,
	|	ISNULL(CurrentAccountsReceivableBalance.Начисление.ПутевкаКурсовка.Parent, &qEmptyHotelProduct) AS HotelProductParent
	|FROM
	|	AccumulationRegister.РелизацияТекОтчетПериод.Balance(
	|		&qDate, " + 
			?(vNoHotelProducts, "TRUE", "(NOT Начисление.Услуга.IsHotelProductService OR 
	|		         Начисление.Услуга.IsHotelProductService AND 
	|		         NOT Фирма.WaitForHotelProduct)
	|		") + 
			?(ЗначениеЗаполнено(Гостиница), " AND Гостиница IN HIERARCHY(&qHotel)", "") + 
			?(ЗначениеЗаполнено(Company), " AND Фирма IN HIERARCHY(&qCompany)", "") + 
			?(ProcessClosedFoliosOnly, " AND (ISNULL(СчетПроживания.IsClosed, FALSE) AND NOT ISNULL(ГруппаГостей.IsPending, FALSE) OR Начисление.Услуга.IsStockArticle OR (СчетПроживания.DateTimeTo = &qEmptyDate AND &qEndOfMonth))", "") + "
	|		AND ISNULL(Начисление.ДатаДок, &qEmptyDate) <= &qPeriodTo
	|		AND (&qEndOfMonth OR NOT &qEndOfMonth AND NOT ISNULL(Контрагент.ТипКонтрагента.CreateSettlementsAtTheEndOfAccountingPeriodOnly, FALSE))
	|	) AS CurrentAccountsReceivableBalance
	|
	|GROUP BY
	|	CurrentAccountsReceivableBalance.Гостиница,
	|	CurrentAccountsReceivableBalance.Фирма,
	|	CurrentAccountsReceivableBalance.Контрагент,
	|	CurrentAccountsReceivableBalance.Договор,
	|	CASE
	|		WHEN CurrentAccountsReceivableBalance.ГруппаГостей IN (&qGuestGroupsWithCorrections) THEN
	|			CurrentAccountsReceivableBalance.ГруппаГостей 
	|		WHEN &qOneSettlementPerCustomerGuestGroups THEN
	|			&qEmptyGuestGroup
	|		WHEN &qOneSettlementPerIndividualsCustomerGuestGroups AND 
	|		     (CurrentAccountsReceivableBalance.Контрагент = &qEmptyCustomer OR CurrentAccountsReceivableBalance.Контрагент = CurrentAccountsReceivableBalance.Гостиница.IndividualsCustomer) THEN
	|			&qEmptyGuestGroup
	|		ELSE 
	|			CurrentAccountsReceivableBalance.ГруппаГостей 
	|	END,
	|	CASE
	|		WHEN CurrentAccountsReceivableBalance.ГруппаГостей IN (&qGuestGroupsWithCorrections) THEN
	|			CurrentAccountsReceivableBalance.ГруппаГостей.Code 
	|		WHEN &qOneSettlementPerCustomerGuestGroups THEN
	|			0
	|		WHEN &qOneSettlementPerIndividualsCustomerGuestGroups AND 
	|		     (CurrentAccountsReceivableBalance.Контрагент = &qEmptyCustomer OR CurrentAccountsReceivableBalance.Контрагент = CurrentAccountsReceivableBalance.Гостиница.IndividualsCustomer) THEN
	|			0
	|		WHEN CurrentAccountsReceivableBalance.ГруппаГостей = &qEmptyGuestGroup THEN
	|			999999999999
	|		ELSE 
	|			CurrentAccountsReceivableBalance.ГруппаГостей.Code 
	|	END,
	|	CurrentAccountsReceivableBalance.ВалютаЛицСчета,
	|	CASE
	|		WHEN &qSplitSettllementsByVATRate THEN
	|			CurrentAccountsReceivableBalance.Начисление.СтавкаНДС
	|		ELSE
	|			&qEmptyVATRate
	|	END,
	|	CASE
	|		WHEN ISNULL(CurrentAccountsReceivableBalance.ДокОснование.HasOfficialLetter, FALSE) THEN
	|			CurrentAccountsReceivableBalance.ДокОснование
	|		ELSE &qEmptyAccommodation
	|	END,
	|	CASE 
	|		WHEN ISNULL(CurrentAccountsReceivableBalance.Начисление.Услуга.SplitToSeparateSettlements, FALSE) THEN
	|			CurrentAccountsReceivableBalance.Начисление.Услуга
	|		WHEN ISNULL(CurrentAccountsReceivableBalance.Начисление.Услуга.DoNotExportToTheAccountingSystem, FALSE) THEN
	|			CurrentAccountsReceivableBalance.Начисление.Услуга
	|		ELSE &qEmptyService
	|	END,
	|	ISNULL(CurrentAccountsReceivableBalance.Начисление.ПутевкаКурсовка.Parent, &qEmptyHotelProduct)
	|ORDER BY
	|	CustomerDescription,
	|	ContractDescription,
	|	GuestGroupCode,
	|	ВалютаЛицСчета.ПорядокСортировки,
	|	SeparateAccommodation DESC,
	|	SeparateService DESC";
	vQry.SetParameter("qDate", New Boundary(vDate, BoundaryType.Excluding));
	vQry.SetParameter("qHotel", Гостиница);
	vQry.SetParameter("qCompany", Company);
	vQry.SetParameter("qEmptyCustomer", Справочники.Контрагенты.EmptyRef());
	vQry.SetParameter("qEmptyGuestGroup", Справочники.ГруппыГостей.EmptyRef());
	vQry.SetParameter("qEmptyAccommodation", Documents.Размещение.EmptyRef());
	vQry.SetParameter("qEmptyService", Справочники.Услуги.EmptyRef());
	vQry.SetParameter("qOneSettlementPerCustomerGuestGroups", OneSettlementPerCustomerGuestGroups);
	vQry.SetParameter("qOneSettlementPerIndividualsCustomerGuestGroups", OneSettlementPerIndividualsCustomerGuestGroups);
	vQry.SetParameter("qSplitSettllementsByVATRate", SplitSettllementsByVATRate);
	vQry.SetParameter("qEmptyVATRate", Неопределено);
	vQry.SetParameter("qPeriodTo", Date);
	vQry.SetParameter("qEmptyDate", '00010101');
	vQry.SetParameter("qEmptyHotelProduct", Справочники.ПутевкиКурсовки.EmptyRef());
	vQry.SetParameter("qEndOfMonth", ?(EndOfDay(Date) = EndOfMonth(Date), True, False));
	vQry.SetParameter("qGuestGroupsWithCorrections", pGuestGroupsWithCorrections);
	vDimensions = vQry.Execute().Unload();
	// Create settlement for each row in dimensions table
	For Each vDimensionsRow In vDimensions Do
		// Date to be used to retreive balances
		vDate = Date + 1;
		// If only closed folios should be procesed then check that all 
		// folios of the current guest group are closed
		vJoinFirstDayOfMonthBreakfasts = False;
		vBegOfNextMonthDay = Неопределено;
		vEndOfNextMonthDay = Неопределено;
		If ProcessClosedFoliosOnly Тогда
			If ЗначениеЗаполнено(vDimensionsRow.Company) And 
			   ЗначениеЗаполнено(vDimensionsRow.Фирма.CompanyAccountingPolicyType) Тогда
				If vDimensionsRow.Фирма.CompanyAccountingPolicyType = Перечисления.CompanyAccountingPolicyTypes.ByCheckedOutGuestGroupsServices Тогда
					vGuestGroup = vDimensionsRow.GuestGroup;
					If ЗначениеЗаполнено(vGuestGroup) Тогда
						vCount = GetOpenFoliosCountForGuestGroup(vGuestGroup);
						If vCount > 0 Тогда
							Continue;
						EndIf;
					EndIf;
				EndIf;
				If vDimensionsRow.Фирма.CompanyAccountingPolicyType = Перечисления.CompanyAccountingPolicyTypes.ByCheckedOutGuestGroupsServices Or 
				   vDimensionsRow.Фирма.CompanyAccountingPolicyType = Перечисления.CompanyAccountingPolicyTypes.ByCheckedOutGuestsServices Тогда
					// Use end of month to catch services that could be in the future to the close of period date
					vDate = EndOfMonth(Date) + 1;
				EndIf;
			EndIf;
		Else
			// At the end of the accounting period (usually month) we'll try to join breakfasts and other additional services for the guests that checking-out on 1 day of next month to the previous month settlement
			If ЗначениеЗаполнено(vDimensionsRow.GuestGroup) Тогда
				If ЗначениеЗаполнено(vDimensionsRow.Company) And 
				   ЗначениеЗаполнено(vDimensionsRow.Фирма.CompanyAccountingPolicyType) Тогда
					If vDimensionsRow.Фирма.CompanyAccountingPolicyType = Перечисления.CompanyAccountingPolicyTypes.ByCheckedOutGuestGroupsServices Or 
					   vDimensionsRow.Фирма.CompanyAccountingPolicyType = Перечисления.CompanyAccountingPolicyTypes.ByCheckedOutGuestsServices Тогда
						If EndOfDay(Date) = EndOfMonth(Date) Тогда
							If CheckRevenueServicesCount(vDimensionsRow) Тогда
								vDate = '39991231235959';
							Else
								vBegOfNextMonthDay = BegOfDay(EndOfDay(Date) + 1);
								vEndOfNextMonthDay = EndOfDay(EndOfDay(Date) + 1);
								vJoinFirstDayOfMonthBreakfasts = True;
							EndIf;
						EndIf;
					EndIf;
				EndIf;
			EndIf;
		EndIf;
		
		// Fill dimensions and accounting currency
		vAccountingCustomer = Справочники.Контрагенты.EmptyRef();
		vAccountingContract = Справочники.Договора.EmptyRef();
		vLanguage = Неопределено;
		If ЗначениеЗаполнено(vDimensionsRow.Customer) Тогда
			vAccountingCustomer = vDimensionsRow.Контрагент;
			// Get Контрагент language
			If ЗначениеЗаполнено(vAccountingCustomer) Тогда
				vLanguage = vAccountingCustomer.Language;
			EndIf;
		Else
			If ЗначениеЗаполнено(vDimensionsRow.Гостиница) Тогда
				vAccountingCustomer = vDimensionsRow.Гостиница.IndividualsCustomer;
				vAccountingContract = vDimensionsRow.Гостиница.IndividualsContract;
			EndIf;
		EndIf;
		If ЗначениеЗаполнено(vDimensionsRow.Contract) Тогда
			vAccountingContract = vDimensionsRow.Contract;
		EndIf;
		vAccountingCurrency = vDimensionsRow.FolioCurrency;
		
		// Skip individuals if neccessary
		If DoNotCloseIndividuals And ЗначениеЗаполнено(vDimensionsRow.Гостиница) Тогда
			If ЗначениеЗаполнено(vDimensionsRow.Гостиница.IndividualsCustomer) And vAccountingCustomer = vDimensionsRow.Гостиница.IndividualsCustomer Тогда
				Continue;
			EndIf;
		EndIf;
		
		// Check if current guest group is in the corrections list
		vIsCorrection = False;
		If pGuestGroupsWithCorrections.FindByValue(vDimensionsRow.GuestGroup) <> Неопределено Тогда
			vIsCorrection = True;
		EndIf;
		
		// Retrieve all balances for the current dimensions where folio payment method is by bank transfer
		vQry = New Query();
		vQry.Text = 
		"SELECT
		|	CurrentAccountsReceivableBalance.Гостиница,
		|	CurrentAccountsReceivableBalance.Фирма,
		|	CurrentAccountsReceivableBalance.Контрагент,
		|	CurrentAccountsReceivableBalance.Договор,
		|	CurrentAccountsReceivableBalance.ГруппаГостей,
		|	CurrentAccountsReceivableBalance.ВалютаЛицСчета,
		|	CurrentAccountsReceivableBalance.СчетПроживания,
		|	CurrentAccountsReceivableBalance.ДокОснование,
		|	CurrentAccountsReceivableBalance.Начисление.ПутевкаКурсовка AS ПутевкаКурсовка,
		|	CurrentAccountsReceivableBalance.Начисление,
		|	CurrentAccountsReceivableBalance.Начисление.Скидка AS Скидка,
		|	CurrentAccountsReceivableBalance.Начисление.СуммаСкидки AS СуммаСкидки,
		|	CurrentAccountsReceivableBalance.Начисление.ВидКомиссииАгента AS ВидКомиссииАгента,
		|	CurrentAccountsReceivableBalance.Начисление.КомиссияАгента AS КомиссияАгента,
		|	ISNULL(CurrentAccountsReceivableBalance.Начисление.ПутевкаКурсовка.Parent, &qEmptyHotelProduct) AS HotelProductParent,
		|	CurrentAccountsReceivableBalance.CommissionSumBalance,
		|	CurrentAccountsReceivableBalance.SumBalance,
		|	CurrentAccountsReceivableBalance.VATSumBalance,
		|	CurrentAccountsReceivableBalance.QuantityBalance,
		|	CurrentAccountsReceivableBalance.Начисление.PointInTime AS ChargePointInTime
		|FROM
		|	AccumulationRegister.РелизацияТекОтчетПериод.Balance(
		|		&qDate, " + 
				?(vNoHotelProducts, "TRUE", "(NOT Начисление.Услуга.IsHotelProductService OR 
		|		         Начисление.Услуга.IsHotelProductService AND 
		|		         NOT Фирма.WaitForHotelProduct)
		|		") + "
		|		AND Гостиница = &qHotel
		|		AND Фирма = &qCompany
		|		AND Контрагент = &qCustomer
		|		AND Договор = &qContract" + 
				?(vIsCorrection, "", ?(OneSettlementPerCustomerGuestGroups, "", ?(OneSettlementPerIndividualsCustomerGuestGroups, "", " AND ГруппаГостей = &qGuestGroup"))) + 
				?(vIsCorrection, "", ?(OneSettlementPerIndividualsCustomerGuestGroups, " AND (ГруппаГостей = &qGuestGroup OR &qGuestGroupIsEmpty)", "")) + 
				?(vIsCorrection, " AND ГруппаГостей = &qGuestGroup", "") + 
				?(SplitSettllementsByVATRate, " AND Начисление.СтавкаНДС = &qVATRate", "") + "
		|		AND ISNULL(Начисление.ДатаДок, &qEmptyDate) <= &qPeriodTo
		|		AND ISNULL(Начисление.ПутевкаКурсовка.Parent, &qEmptyHotelProduct) = &qHotelProductParent
		|		AND ВалютаЛицСчета = &qFolioCurrency" + 
				?(ProcessClosedFoliosOnly, " AND (ISNULL(СчетПроживания.IsClosed, FALSE) OR Начисление.Услуга.IsStockArticle OR (СчетПроживания.DateTimeTo = &qEmptyDate AND &qEndOfMonth))", "") + 
				?(ЗначениеЗаполнено(vDimensionsRow.SeparateAccommodation), " AND ДокОснование = &qAccommodation", "") + 
				?(ЗначениеЗаполнено(vDimensionsRow.SeparateService), " AND Начисление.Услуга = &qService", "") + "
		|	) AS CurrentAccountsReceivableBalance
		|UNION ALL
		|SELECT
		|	CurrentAccountsReceivableNextMonthDayBalance.Гостиница,
		|	CurrentAccountsReceivableNextMonthDayBalance.Фирма,
		|	CurrentAccountsReceivableNextMonthDayBalance.Контрагент,
		|	CurrentAccountsReceivableNextMonthDayBalance.Договор,
		|	CurrentAccountsReceivableNextMonthDayBalance.ГруппаГостей,
		|	CurrentAccountsReceivableNextMonthDayBalance.ВалютаЛицСчета,
		|	CurrentAccountsReceivableNextMonthDayBalance.СчетПроживания,
		|	CurrentAccountsReceivableNextMonthDayBalance.ДокОснование,
		|	CurrentAccountsReceivableNextMonthDayBalance.Начисление.ПутевкаКурсовка AS ПутевкаКурсовка,
		|	CurrentAccountsReceivableNextMonthDayBalance.Начисление,
		|	CurrentAccountsReceivableNextMonthDayBalance.Начисление.Скидка AS Скидка,
		|	CurrentAccountsReceivableNextMonthDayBalance.Начисление.СуммаСкидки AS СуммаСкидки,
		|	CurrentAccountsReceivableNextMonthDayBalance.Начисление.ВидКомиссииАгента AS ВидКомиссииАгента,
		|	CurrentAccountsReceivableNextMonthDayBalance.Начисление.КомиссияАгента AS КомиссияАгента,
		|	ISNULL(CurrentAccountsReceivableNextMonthDayBalance.Начисление.ПутевкаКурсовка.Parent, &qEmptyHotelProduct) AS HotelProductParent,
		|	CurrentAccountsReceivableNextMonthDayBalance.CommissionSumBalance,
		|	CurrentAccountsReceivableNextMonthDayBalance.SumBalance,
		|	CurrentAccountsReceivableNextMonthDayBalance.VATSumBalance,
		|	CurrentAccountsReceivableNextMonthDayBalance.QuantityBalance,
		|	CurrentAccountsReceivableNextMonthDayBalance.Начисление.PointInTime
		|FROM
		|	AccumulationRegister.РелизацияТекОтчетПериод.Balance(
		|		&qEndOfNextMonthDay, 
		|		&qJoinFirstDayOfMonthBreakfasts " + 
				?(vNoHotelProducts, "", " AND (NOT Начисление.Услуга.IsHotelProductService OR 
		|		         Начисление.Услуга.IsHotelProductService AND 
		|		         NOT Фирма.WaitForHotelProduct)
		|		") + "
		|		AND ISNULL(Начисление.ДатаДок, &qEmptyDate) >= &qBegOfNextMonthDay
		|		AND ISNULL(Начисление.ДатаДок, &qEmptyDate) <= &qEndOfNextMonthDay
		|		AND Начисление.Услуга.QuantityCalculationRule.QuantityCalculationRuleType = &qBreakfast
		|		AND ISNULL(Начисление.ПутевкаКурсовка.Parent, &qEmptyHotelProduct) = &qHotelProductParent
		|		AND Гостиница = &qHotel
		|		AND Фирма = &qCompany
		|		AND Контрагент = &qCustomer
		|		AND Договор = &qContract" + 
				?(vIsCorrection, "", ?(OneSettlementPerCustomerGuestGroups, "", ?(OneSettlementPerIndividualsCustomerGuestGroups, "", " AND ГруппаГостей = &qGuestGroup"))) + 
				?(vIsCorrection, "", ?(OneSettlementPerIndividualsCustomerGuestGroups, " AND (ГруппаГостей = &qGuestGroup OR &qGuestGroupIsEmpty)", "")) + 
				?(vIsCorrection, " AND ГруппаГостей = &qGuestGroup", "") + 
				?(SplitSettllementsByVATRate, " AND Начисление.СтавкаНДС = &qVATRate", "") + "
		|		AND ВалютаЛицСчета = &qFolioCurrency" + 
				?(ProcessClosedFoliosOnly, " AND (ISNULL(СчетПроживания.IsClosed, FALSE) OR Начисление.Услуга.IsStockArticle OR (СчетПроживания.DateTimeTo = &qEmptyDate AND &qEndOfMonth))", "") + 
				?(ЗначениеЗаполнено(vDimensionsRow.SeparateAccommodation), " AND ДокОснование = &qAccommodation", "") + 
				?(ЗначениеЗаполнено(vDimensionsRow.SeparateService), " AND Начисление.Услуга = &qService", "") + "
		|		AND (&qEndOfMonth OR NOT &qEndOfMonth AND NOT ISNULL(Контрагент.ТипКонтрагента.CreateSettlementsAtTheEndOfAccountingPeriodOnly, FALSE))
		|	) AS CurrentAccountsReceivableNextMonthDayBalance
		|
		|ORDER BY
		|	ChargePointInTime";
		vQry.SetParameter("qDate", New Boundary(vDate, BoundaryType.Excluding));
		vQry.SetParameter("qBegOfNextMonthDay", vBegOfNextMonthDay);
		vQry.SetParameter("qEndOfNextMonthDay", vEndOfNextMonthDay);
		vQry.SetParameter("qJoinFirstDayOfMonthBreakfasts", vJoinFirstDayOfMonthBreakfasts);
		vQry.SetParameter("qBreakfast", Перечисления.QuantityCalculationRuleTypes.Breakfast);
		vQry.SetParameter("qHotel", vDimensionsRow.Гостиница);
		vQry.SetParameter("qCompany", vDimensionsRow.Company);
		vQry.SetParameter("qCustomer", vDimensionsRow.Customer);
		vQry.SetParameter("qContract", vDimensionsRow.Contract);
		vQry.SetParameter("qGuestGroup", vDimensionsRow.GuestGroup);
		vQry.SetParameter("qGuestGroupIsEmpty", НЕ ЗначениеЗаполнено(vDimensionsRow.GuestGroup));
		vQry.SetParameter("qFolioCurrency", vDimensionsRow.FolioCurrency);
		vQry.SetParameter("qAccommodation", vDimensionsRow.SeparateAccommodation);
		vQry.SetParameter("qService", vDimensionsRow.SeparateService);
		vQry.SetParameter("qVATRate", vDimensionsRow.VATRate);
		vQry.SetParameter("qHotelProductParent", vDimensionsRow.HotelProductParent);
		vQry.SetParameter("qPeriodTo", Max(vDate - 1, EndOfMonth(Date)));
		vQry.SetParameter("qEmptyDate", '00010101');
		vQry.SetParameter("qEmptyHotelProduct", Справочники.ПутевкиКурсовки.EmptyRef());
		vQry.SetParameter("qEndOfMonth", ?(EndOfDay(Date) = EndOfMonth(Date), True, False));
		vCharges = vQry.Execute().Unload();
		If vCharges.Count() > 0 Тогда
			// Create settlement and fill it's services with charges retrieved
			CreateAndPostSettlement(vDimensionsRow, vAccountingCustomer, vAccountingContract, vAccountingCurrency, 
			                        vLanguage, vCharges, vIsCorrection);
		EndIf;
	EndDo;
	WriteLogEvent(NStr("en='CloseOfPeriod.BuildSettlements';ru='ЗакрытиеПериода.ФормированиеАктов';de='CloseOfPeriod.BuildSettlements'"), EventLogLevel.Information, Metadata(), Ref, NStr("en='End of building settlements';ru='Закончена операция формирования актов';de='Operation der Übergabeprotokollerstellung ist abgeschlossen'"), EventLogEntryTransactionMode.Transactional);
КонецПроцедуры //CloseCurrentAccountsReceivable

//-----------------------------------------------------------------------------
Процедура DoPaymentsDistributionToServices(pCancel, pPostingMode)
	If ЗначениеЗаполнено(Гостиница) And НЕ Гостиница.DoPaymentsDistributionToServices Тогда
		Return;
	EndIf;
	WriteLogEvent(NStr("en='CloseOfPeriod.PaymentsDistributionToServices';ru='ЗакрытиеПериода.РаспределениеПлатежейПоУслугам';de='CloseOfPeriod.PaymentsDistributionToServices'"), EventLogLevel.Information, Metadata(), Ref, NStr("en='Start of payments distribution to services...';ru='Начата операция распределения платежей по услугам...';de='Verteilung von Zahlungen nach Dienstleistungen wurde gestartet…'"), EventLogEntryTransactionMode.Transactional);
	// Get table with returns only
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	ReturnServicesBalance.СчетПроживания,
	|	ReturnServicesBalance.Платеж,
	|	ReturnServicesBalance.SumBalance AS ReturnBalance
	|FROM
	|	AccumulationRegister.ПлатежиУслуги.Balance(
	|			&qDate,
	|			(СчетПроживания.Гостиница IN HIERARCHY (&qHotel)
	|				OR &qHotelIsEmpty)
	|				AND (СчетПроживания.Фирма IN HIERARCHY (&qCompany)
	|					OR &qCompanyIsEmpty)
	|				AND СчетПроживания.Гостиница.DoPaymentsDistributionToServices
	|				AND Платеж <> UNDEFINED
	|				AND Услуга = &qEmptyService) AS ReturnServicesBalance
	|		INNER JOIN (SELECT
	|			PaymentServicesTurnovers.СчетПроживания AS СчетПроживания,
	|			PaymentServicesTurnovers.SumTurnover AS SumTurnover
	|		FROM
	|			AccumulationRegister.ПлатежиУслуги.Turnovers(
	|					,
	|					,
	|					Period,
	|					(СчетПроживания.Гостиница IN HIERARCHY (&qHotel)
	|						OR &qHotelIsEmpty)
	|						AND (СчетПроживания.Фирма IN HIERARCHY (&qCompany)
	|							OR &qCompanyIsEmpty)
	|						AND СчетПроживания.Гостиница.DoPaymentsDistributionToServices
	|						AND Платеж = UNDEFINED
	|						AND Услуга <> &qEmptyService) AS PaymentServicesTurnovers) AS ServicesTurnovers
	|		ON ReturnServicesBalance.СчетПроживания = ServicesTurnovers.СчетПроживания
	|WHERE
	|	ReturnServicesBalance.SumBalance > 0
	|
	|ORDER BY
	|	ReturnServicesBalance.СчетПроживания.PointInTime,
	|	ReturnServicesBalance.Платеж.PointInTime DESC";
	vQry.SetParameter("qDate", New Boundary(Date + 1, BoundaryType.Excluding));
	vQry.SetParameter("qHotel", Гостиница);
	vQry.SetParameter("qHotelIsEmpty", НЕ ЗначениеЗаполнено(Гостиница));
	vQry.SetParameter("qCompany", Company);
	vQry.SetParameter("qCompanyIsEmpty", НЕ ЗначениеЗаполнено(Company));
	vQry.SetParameter("qEmptyService", Справочники.Услуги.EmptyRef());
	vReturns = vQry.Execute().Unload();
	
	// Process returns
	vCurFolio = Неопределено;
	vCharges = New ValueTable();
	For Each vReturnsRow In vReturns Do
		// Try to find charges for the current folio
		If vCurFolio <> vReturnsRow.ЛицевойСчет Тогда
			vCurFolio = vReturnsRow.ЛицевойСчет;
			
			vQry = New Query();
			vQry.Text = 
			"SELECT
			|	FolioCharges.СчетПроживания,
			|	FolioCharges.Услуга,
			|	FolioCharges.Платеж,
			|	SUM(FolioCharges.Сумма) AS Сумма
			|FROM
			|	AccumulationRegister.ПлатежиУслуги AS FolioCharges
			|WHERE
			|	FolioCharges.СчетПроживания = &qFolio
			|	AND FolioCharges.Услуга <> &qEmptyService
			|	AND FolioCharges.Платеж <> UNDEFINED
			|	AND FolioCharges.RecordType = &qExpense
			|	AND FolioCharges.Сумма <> 0
			|
			|GROUP BY
			|	FolioCharges.СчетПроживания,
			|	FolioCharges.Услуга,
			|	FolioCharges.Платеж
			|
			|HAVING
			|	SUM(FolioCharges.Сумма) <> 0
			|
			|ORDER BY
			|	FolioCharges.Услуга.IsRoomRevenue,
			|	FolioCharges.Услуга.ПорядокСортировки DESC";
			vQry.SetParameter("qFolio", vCurFolio);
			vQry.SetParameter("qEmptyService", Справочники.Услуги.EmptyRef());
			vQry.SetParameter("qExpense", AccumulationRecordType.Expense);
			vCharges = vQry.Execute().Unload();
		EndIf;
		If vCharges.Count() > 0 Тогда
			For Each vChargesRow In vCharges Do
				If vReturnsRow.ReturnBalance > 0 Тогда
					// Sum being undistributed
					vUndistrSum = Min(vReturnsRow.ReturnBalance, vChargesRow.Sum);

					// Add charge write off cancellation movement
					Movement = RegisterRecords.ПлатежиУслуги.Add();
					Movement.RecordType = AccumulationRecordType.Expense;
					Movement.Period = vReturnsRow.Payment.ДатаДок;
					Movement.СчетПроживания = vCurFolio;
					Movement.Услуга = vChargesRow.Service;
					Movement.Платеж = Неопределено;
					Movement.Сумма = -vUndistrSum;

					// Add charge undistribution movement
					Movement = RegisterRecords.ПлатежиУслуги.Add();
					Movement.RecordType = AccumulationRecordType.Expense;
					Movement.Period = vReturnsRow.Payment.ДатаДок;
					Movement.СчетПроживания = vCurFolio;
					Movement.Услуга = vChargesRow.Service;
					Movement.Платеж = vChargesRow.Payment;
					Movement.Сумма = -vUndistrSum;
					
					// Add payment write off cancellation movement
					Movement = RegisterRecords.ПлатежиУслуги.Add();
					Movement.RecordType = AccumulationRecordType.Expense;
					Movement.Period = vReturnsRow.Payment.ДатаДок;
					Movement.СчетПроживания = vCurFolio;
					Movement.Услуга = Справочники.Услуги.EmptyRef();
					Movement.Платеж = vChargesRow.Payment;
					Movement.Сумма = vUndistrSum;
					
					// Correct working table row
					vReturnsRow.ReturnBalance = vReturnsRow.ReturnBalance - vUndistrSum;
				Else
					Break;
				EndIf;
			EndDo;
		EndIf;
	EndDo;
	
	// Write return movements
	If RegisterRecords.ПлатежиУслуги.Count() > 0 Тогда
		RegisterRecords.ПлатежиУслуги.Write();
	EndIf;
	
	// Get table with undistributed service balances
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	ServicesBalance.СчетПроживания,
	|	ServicesBalance.Услуга,
	|	ServicesBalance.SumBalance
	|FROM
	|	AccumulationRegister.ПлатежиУслуги.Balance(
	|			&qEndOfTime,
	|			(СчетПроживания.Гостиница IN HIERARCHY (&qHotel)
	|				OR &qHotelIsEmpty)
	|				AND (СчетПроживания.Фирма IN HIERARCHY (&qCompany)
	|					OR &qCompanyIsEmpty)
	|				AND СчетПроживания.Гостиница.DoPaymentsDistributionToServices
	|				AND Платеж = UNDEFINED
	|				AND Услуга <> &qEmptyService) AS ServicesBalance
	|		INNER JOIN (SELECT
	|			PaymentsBalance.СчетПроживания AS СчетПроживания
	|		FROM
	|			(SELECT
	|				PaymentServicesBalance.СчетПроживания AS СчетПроживания,
	|				PaymentServicesBalance.Платеж AS Платеж,
	|				-PaymentServicesBalance.SumBalance AS PaymentBalance
	|			FROM
	|				AccumulationRegister.ПлатежиУслуги.Balance(
	|						&qDate,
	|						(СчетПроживания.Гостиница IN HIERARCHY (&qHotel)
	|							OR &qHotelIsEmpty)
	|							AND (СчетПроживания.Фирма IN HIERARCHY (&qCompany)
	|								OR &qCompanyIsEmpty)
	|							AND СчетПроживания.Гостиница.DoPaymentsDistributionToServices
	|							AND Платеж <> UNDEFINED
	|							AND Услуга = &qEmptyService) AS PaymentServicesBalance
	|			WHERE
	|				PaymentServicesBalance.SumBalance < 0) AS PaymentsBalance
	|		
	|		GROUP BY
	|			PaymentsBalance.СчетПроживания) AS FoliosWithPayments
	|		ON ServicesBalance.СчетПроживания = FoliosWithPayments.СчетПроживания
	|
	|ORDER BY
	|	ServicesBalance.СчетПроживания.PointInTime,
	|	ServicesBalance.Услуга.IsRoomRevenue DESC,
	|	ServicesBalance.Услуга.ПорядокСортировки";
	vQry.SetParameter("qEndOfTime", '39991231235959');
	vQry.SetParameter("qDate", New Boundary(Date + 1, BoundaryType.Excluding));
	vQry.SetParameter("qHotel", Гостиница);
	vQry.SetParameter("qHotelIsEmpty", НЕ ЗначениеЗаполнено(Гостиница));
	vQry.SetParameter("qCompany", Company);
	vQry.SetParameter("qCompanyIsEmpty", НЕ ЗначениеЗаполнено(Company));
	vQry.SetParameter("qEmptyService", Справочники.Услуги.EmptyRef());
	vServices = vQry.Execute().Unload();
	
	// Get table with undistributed payment balances
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	PaymentServicesBalance.СчетПроживания,
	|	PaymentServicesBalance.Платеж,
	|	-PaymentServicesBalance.SumBalance AS PaymentBalance
	|FROM
	|	AccumulationRegister.ПлатежиУслуги.Balance(
	|			&qDate,
	|			(СчетПроживания.Гостиница IN HIERARCHY (&qHotel)
	|				OR &qHotelIsEmpty)
	|				AND (СчетПроживания.Фирма IN HIERARCHY (&qCompany)
	|					OR &qCompanyIsEmpty)
	|				AND СчетПроживания.Гостиница.DoPaymentsDistributionToServices
	|				AND Платеж <> UNDEFINED
	|				AND Услуга = &qEmptyService) AS PaymentServicesBalance
	|WHERE
	|	PaymentServicesBalance.SumBalance < 0
	|
	|ORDER BY
	|	PaymentServicesBalance.СчетПроживания.PointInTime,
	|	PaymentServicesBalance.Платеж.PointInTime,
	|	PaymentServicesBalance.Услуга.IsRoomRevenue DESC,
	|	PaymentServicesBalance.Услуга.ПорядокСортировки";
	vQry.SetParameter("qDate", New Boundary(Date + 1, BoundaryType.Excluding));
	vQry.SetParameter("qHotel", Гостиница);
	vQry.SetParameter("qHotelIsEmpty", НЕ ЗначениеЗаполнено(Гостиница));
	vQry.SetParameter("qCompany", Company);
	vQry.SetParameter("qCompanyIsEmpty", НЕ ЗначениеЗаполнено(Company));
	vQry.SetParameter("qEmptyService", Справочники.Услуги.EmptyRef());
	vPayments = vQry.Execute().Unload();
	
	// Process undistributed services with balances
	vCurFolio = Неопределено;
	vFolioPayments = New Array;
	For Each vServicesRow In vServices Do
		// Try to find payments for the current folio
		If vCurFolio <> vServicesRow.ЛицевойСчет Тогда
			vCurFolio = vServicesRow.ЛицевойСчет;
			vFolioPayments = vPayments.FindRows(New Structure("СчетПроживания", vCurFolio));
		EndIf;
		If vFolioPayments.Count() > 0 Тогда
			For Each vPaymentsRow In vFolioPayments Do
				If vPaymentsRow.PaymentBalance > 0 Тогда
					// Sum being distributed
					vDistrSum = Min(vServicesRow.SumBalance, vPaymentsRow.PaymentBalance);

					// Add payment distribution movement
					Movement = RegisterRecords.ПлатежиУслуги.Add();
					Movement.RecordType = AccumulationRecordType.Expense;
					Movement.Period = vPaymentsRow.Платеж.ДатаДок;
					Movement.СчетПроживания = vCurFolio;
					Movement.Услуга = vServicesRow.Service;
					Movement.Платеж = vPaymentsRow.Платеж;
					Movement.Сумма = vDistrSum;

					// Add service write off movement
					Movement = RegisterRecords.ПлатежиУслуги.Add();
					Movement.RecordType = AccumulationRecordType.Expense;
					Movement.Period = vPaymentsRow.Платеж.ДатаДок;
					Movement.СчетПроживания = vCurFolio;
					Movement.Услуга = vServicesRow.Service;
					Movement.Платеж = Неопределено;
					Movement.Сумма = vDistrSum;
					
					// Add payment write off movement
					Movement = RegisterRecords.ПлатежиУслуги.Add();
					Movement.RecordType = AccumulationRecordType.Expense;
					Movement.Period = vPaymentsRow.Платеж.ДатаДок;
					Movement.СчетПроживания = vCurFolio;
					Movement.Услуга = Справочники.Услуги.EmptyRef();
					Movement.Платеж = vPaymentsRow.Платеж;
					Movement.Сумма = -vDistrSum;
					
					// Correct working table row
					vPaymentsRow.PaymentBalance = vPaymentsRow.PaymentBalance - vDistrSum;
					vServicesRow.SumBalance = vServicesRow.SumBalance - vDistrSum;
				EndIf;
			EndDo;
		EndIf;
	EndDo;
	
	// Write all movements
	RegisterRecords.ПлатежиУслуги.Write();
	WriteLogEvent(NStr("en='CloseOfPeriod.PaymentsDistributionToServices';ru='ЗакрытиеПериода.РаспределениеПлатежейПоУслугам';de='CloseOfPeriod.PaymentsDistributionToServices'"), EventLogLevel.Information, Metadata(), Ref, NStr("en='End of payments distribution to services';ru='Закончена операция распределения платежей по услугам';de='Operation der Zahlungsverteilung nach Dienstleistungen ist abgeschlossen'"), EventLogEntryTransactionMode.Transactional);
КонецПроцедуры //DoPaymentsDistributionToServices

//-----------------------------------------------------------------------------
Процедура CloseOrphanFolios(pIsPosted = False)
	// Do processing if document is not posted only
	If pIsPosted Тогда
		Return;
	EndIf;
	// Log start of closing orphan folios
	WriteLogEvent(NStr("en='CloseOfPeriod.CloseOrphanFolios';ru='ЗакрытиеПериода.ЗакрытиеПросроченныхЛицевыхСчетов';de='CloseOfPeriod.CloseOrphanFolios'"), EventLogLevel.Information, Metadata(), Ref, NStr("en='Start of closing orphan folios...';ru='Начата операция закрытия лицевых счетов с пустым документом основанием...';de='Schließen von Personenkonten mit leerem Begründungdokument wurde gestartet…'"), EventLogEntryTransactionMode.Transactional);
	// Run query to get folios to process
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	СчетПроживания.Ref AS СчетПроживания
	|FROM
	|	Document.СчетПроживания AS СчетПроживания
	|WHERE
	|	NOT СчетПроживания.IsClosed
	|	AND NOT СчетПроживания.DeletionMark
	|	AND NOT СчетПроживания.IsMaster
	|	AND СчетПроживания.DateTimeTo <> &qEmptyDate
	|	AND СчетПроживания.DateTimeTo <= &qPeriodTo
	|	AND (СчетПроживания.ДокОснование.DeletionMark
	|			OR СчетПроживания.ДокОснование = &qUndefined
	|			OR СчетПроживания.ДокОснование <> &qUndefined AND СчетПроживания.ДокОснование.ДатаДок IS NULL
	|			OR СчетПроживания.ДокОснование = &qEmptyAccommodation
	|			OR СчетПроживания.ДокОснование = &qEmptyReservation
	|			OR СчетПроживания.ДокОснование = &qEmptyResourceReservation
	|			OR СчетПроживания.ДокОснование <> &qUndefined AND СчетПроживания.DateTimeTo <= &qPrevAccountingPeriodTo
	|				AND &qPrevAccountingPeriodTo < &qPeriodTo)" + 
		?(ЗначениеЗаполнено(Гостиница), " AND СчетПроживания.Гостиница IN HIERARCHY(&qHotel)", "") + 
		?(ЗначениеЗаполнено(Company), " AND СчетПроживания.Фирма IN HIERARCHY(&qCompany)", "");
	vQry.SetParameter("qUndefined", Неопределено);
	vQry.SetParameter("qEmptyAccommodation", Documents.Размещение.EmptyRef());
	vQry.SetParameter("qEmptyReservation", Documents.Reservation.EmptyRef());
	vQry.SetParameter("qEmptyResourceReservation", Documents.БроньУслуг.EmptyRef());
	vQry.SetParameter("qEmptyDate", '00010101');
	vQry.SetParameter("qPeriodTo", Date);
	vQry.SetParameter("qHotel", Гостиница);
	vQry.SetParameter("qCompany", Company);
	// If folio parent doc is filled but folio check-out date is in the previous accounting period then close it
	vQry.SetParameter("qPrevAccountingPeriodTo", '00010101');
	If ЗначениеЗаполнено(Company) Тогда
		If НЕ ЗначениеЗаполнено(Company.TaxAccountingPeriodType) Or 
		   Company.TaxAccountingPeriodType = Перечисления.TaxAccountingPeriodTypes.Month Or 
		   Company.TaxAccountingPeriodType = Перечисления.TaxAccountingPeriodTypes.None Тогда
			If EndOfDay(Date) = EndOfMonth(Date) Тогда
				vQry.SetParameter("qPrevAccountingPeriodTo", (BegOfMonth(Date) - 1));
			EndIf;
		ElsIf Company.TaxAccountingPeriodType = Перечисления.TaxAccountingPeriodTypes.Quarter Тогда
			If EndOfDay(Date) = EndOfQuarter(Date) Тогда
				vQry.SetParameter("qPrevAccountingPeriodTo", (BegOfQuarter(Date) - 1));
			EndIf;
		ElsIf Company.TaxAccountingPeriodType = Перечисления.TaxAccountingPeriodTypes.HalfYear Тогда
			If Month(Date) >= 7 Тогда
				If EndOfDay(Date) = EndOfYear(Date) Тогда
					vQry.SetParameter("qPrevAccountingPeriodTo", AddMonth((BegOfYear(Date) - 1), 6));
				EndIf;
			Else
				If EndOfDay(Date) = AddMonth((BegOfYear(Date) - 1), 6) Тогда
					vQry.SetParameter("qPrevAccountingPeriodTo", (BegOfYear(Date) - 1));
				EndIf;
			EndIf;
		ElsIf Company.TaxAccountingPeriodType = Перечисления.TaxAccountingPeriodTypes.Year Тогда
			If EndOfDay(Date) = EndOfYear(Date) Тогда
				vQry.SetParameter("qPrevAccountingPeriodTo", (BegOfYear(Date) - 1));
			EndIf;
		EndIf;		
	EndIf;
	vQryRes = vQry.Execute().Unload();
	For Each vQryResRow In vQryRes Do
		vFolioObj = vQryResRow.ЛицевойСчет.GetObject();
		// Check hotel edit prohibited date
		vHotelObj = Неопределено;
		vSavEditProhibitedDate = Неопределено;
		If ЗначениеЗаполнено(vFolioObj.Гостиница) And ЗначениеЗаполнено(vFolioObj.DateTimeTo) And 
		   BegOfDay(vFolioObj.Гостиница.EditProhibitedDate) >= BegOfDay(vFolioObj.DateTimeTo) Тогда
			vHotelObj = vFolioObj.Гостиница.GetObject();
			vSavEditProhibitedDate = vHotelObj.EditProhibitedDate;
			vHotelObj.EditProhibitedDate = '00010101';
			vHotelObj.Write();
		EndIf;
		vFolioObj.IsClosed = True;
//		If TypeOf(vFolioObj.ДокОснование) = Type("DocumentRef.Размещение") And cmIsBrokenRef("Document.Размещение", vFolioObj.ДокОснование) Тогда
//			vFolioObj.ДокОснование = Неопределено;
//		ElsIf TypeOf(vFolioObj.ДокОснование) = Type("DocumentRef.Reservation") And cmIsBrokenRef("Document.Reservation", vFolioObj.ДокОснование) Тогда
//			vFolioObj.ДокОснование = Неопределено;
//		ElsIf TypeOf(vFolioObj.ДокОснование) = Type("DocumentRef.БроньУслуг") And cmIsBrokenRef("Document.БроньУслуг", vFolioObj.ДокОснование) Тогда
//			vFolioObj.ДокОснование = Неопределено;
//		EndIf;
		vFolioObj.Write(DocumentWriteMode.Write);
		If vHotelObj <> Неопределено And vSavEditProhibitedDate <> Неопределено Тогда
			vHotelObj.EditProhibitedDate = vSavEditProhibitedDate;
			vHotelObj.Write();
		EndIf;
		// Log close of folio
		WriteLogEvent(NStr("en='CloseOfPeriod.CloseOrphanFolios';ru='ЗакрытиеПериода.ЗакрытиеПросроченныхЛицевыхСчетов';de='CloseOfPeriod.CloseOrphanFolios'"), EventLogLevel.Information, Metadata(), vFolioObj.Ref, TrimAll(Ref), EventLogEntryTransactionMode.Transactional);
	EndDo;
	// Log number of closed of folios
	WriteLogEvent(NStr("en='CloseOfPeriod.CloseOrphanFolios';ru='ЗакрытиеПериода.ЗакрытиеПросроченныхЛицевыхСчетов';de='CloseOfPeriod.CloseOrphanFolios'"), EventLogLevel.Information, Metadata(), Ref, NStr("en='Closed are ';ru='Закрыто ';de='Geschlossen '") + vQryRes.Count() + NStr("en=' folios';ru=' лицевых счетов';de=' persönlicher Konten'"), EventLogEntryTransactionMode.Transactional);
КонецПроцедуры //CloseOrphanFolios

//-----------------------------------------------------------------------------
Процедура CloseServiceRegistration()
	WriteLogEvent(NStr("en='CloseOfPeriod.CloseServiceRegistration';ru='ЗакрытиеПериода.ОбнулениеБалансаПоФактическиОказаннымУслугам';de='CloseOfPeriod.CloseServiceRegistration'"), EventLogLevel.Information, Metadata(), Ref, NStr("en='Start of fixing registered services balances...';ru='Начата операция обнуления балансов по фактически оказанным услугам...';de='Die Nullung von Bilanzen nach tatsächlich erbrachten Dienstleistungen wurde gestartet…'"), EventLogEntryTransactionMode.Transactional);
	// Run query to get balances
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	ServiceRegistrationBalance.Гостиница AS Гостиница,
	|	ServiceRegistrationBalance.ГруппаГостей AS ГруппаГостей,
	|	ServiceRegistrationBalance.НомерРазмещения AS НомерРазмещения,
	|	ServiceRegistrationBalance.Ресурс AS Ресурс,
	|	ServiceRegistrationBalance.Клиент AS Клиент,
	|	ServiceRegistrationBalance.ВалютаЛицСчета AS ВалютаЛицСчета,
	|	ServiceRegistrationBalance.СчетПроживания AS СчетПроживания,
	|	ServiceRegistrationBalance.УчетнаяДата AS УчетнаяДата,
	|	ServiceRegistrationBalance.Услуга AS Услуга,
	|	ServiceRegistrationBalance.SumBalance AS SumBalance,
	|	ServiceRegistrationBalance.QuantityBalance AS QuantityBalance
	|FROM
	|	AccumulationRegister.РегистрацияУслуги.Balance(
	|			&qPeriod,
	|			Гостиница = &qHotel
	|				OR &qHotelIsEmpty) AS ServiceRegistrationBalance";
	vQry.SetParameter("qPeriod", New Boundary(Date, BoundaryType.Including));
	vQry.SetParameter("qHotel", Гостиница);
	vQry.SetParameter("qHotelIsEmpty", НЕ ЗначениеЗаполнено(Гостиница));
	vServiceRegistrationBalances = vQry.Execute().Unload();
	// Process balances
	If vServiceRegistrationBalances.Count() > 0 Тогда
		For Each vSRBRow In vServiceRegistrationBalances Do
			Movement = RegisterRecords.РегистрацияУслуги.Add();
			
			Movement.RecordType = AccumulationRecordType.Receipt;
			Movement.Period = Date;
			
			// Fill properties
			FillPropertyValues(Movement, vSRBRow);
			
			// Resources
			Movement.Сумма = -vSRBRow.SumBalance;
			Movement.Количество = -vSRBRow.QuantityBalance;
		EndDo;
		
		// Write movements
		RegisterRecords.РегистрацияУслуги.Write();
	EndIf;
	WriteLogEvent(NStr("en='CloseOfPeriod.CloseServiceRegistration';ru='ЗакрытиеПериода.ОбнулениеБалансаПоФактическиОказаннымУслугам';de='CloseOfPeriod.CloseServiceRegistration'"), EventLogLevel.Information, Metadata(), Ref, NStr("en='Number of fixed charges is ';ru='Обнулены балансы по начислениям в количестве ';de='Bilanzen zu Anrechnungen in Höhe von genullt: '") + vServiceRegistrationBalances.Count(), EventLogEntryTransactionMode.Transactional);
КонецПроцедуры //CloseServiceRegistration

//-----------------------------------------------------------------------------
Процедура ArchivePreauthorisations(pIsPosted = False)
	// Do processing if document is not posted only
	If pIsPosted Тогда
		Return;
	EndIf;
	WriteLogEvent(NStr("en='CloseOfPeriod.ArchivePreauthorisations';ru='ЗакрытиеПериода.АрхивацияПреавторизаций';de='CloseOfPeriod.ArchivePreauthorisations'"), EventLogLevel.Information, Metadata(), Ref, NStr("en='Start of preauthorisation archiving...';ru='Начата операция архивации преавторизаций...';de='Die Archivierung von Vorautorisierungen wurde gestartet…'"), EventLogEntryTransactionMode.Transactional);
	// Run query to get preauthorisations based on closed folios
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	ПреАвторизация.Ref,
	|	ПреАвторизация.СчетПроживания,
	|	ПреАвторизация.ГруппаГостей
	|FROM
	|	Document.ПреАвторизация AS ПреАвторизация
	|WHERE
	|	ПреАвторизация.Posted
	|	AND ПреАвторизация.ДатаДок <= &qPeriod
	|	AND ПреАвторизация.СчетПроживания.IsClosed
	|	AND ПреАвторизация.Status = &qAuthorised
	|	AND (ПреАвторизация.Гостиница = &qHotel
	|			OR &qHotelIsEmpty)
	|ORDER BY
	|	ПреАвторизация.ДатаДок";
	vQry.SetParameter("qPeriod", Date);
	vQry.SetParameter("qHotel", Гостиница);
	vQry.SetParameter("qHotelIsEmpty", НЕ ЗначениеЗаполнено(Гостиница));
	vQry.SetParameter("qAuthorised", Перечисления.PreauthorisationStatuses.Authorised);
	vPrs = vQry.Execute().Unload();
	// Process preauthorisations
	If vPrs.Count() > 0 Тогда
		For Each vPrsRow In vPrs Do
			vOpnCount = 0;
			If ЗначениеЗаполнено(vPrsRow.GuestGroup) Тогда
				// Check if all folios of current guest group are closed
				vOpnCount = GetOpenFoliosCountForGuestGroup(vPrsRow.GuestGroup);
			EndIf;
			If vOpnCount = 0 Тогда
				vPrsObj = vPrsRow.Ref.GetObject();
				vPrsObj.Status = Перечисления.PreauthorisationStatuses.Archived;
				vPrsObj.Write(DocumentWriteMode.Posting);
			EndIf;
		EndDo;
	EndIf;
	WriteLogEvent(NStr("en='CloseOfPeriod.ArchivePreauthorisations';ru='ЗакрытиеПериода.АрхивацияПреавторизаций';de='CloseOfPeriod.ArchivePreauthorisations'"), EventLogLevel.Information, Metadata(), Ref, NStr("en='Number of archived preauthorisations is ';ru='Изменен статус у преавторизаций в количестве ';de='Status der Vorautorisierungen geändert in der Zahl: '") + vPrs.Count(), EventLogEntryTransactionMode.Transactional);
КонецПроцедуры //ArchivePreauthorisations

//-----------------------------------------------------------------------------
Процедура CloseCashRegisterFolioBalances(pIsPosted = False)
	// Log start of fixing payment section folio balances
	WriteLogEvent(NStr("en='CloseOfPeriod.FixPaymentSectionFolioBalances';ru='ЗакрытиеПериода.ОбнулениеБалансовЛицевыхСчетовПоКассовымСекциям';de='CloseOfPeriod.FixPaymentSectionFolioBalances'"), EventLogLevel.Information, Metadata(), Ref, NStr("en='Start of fixing payment section balances for closed zeroed folios...';ru='Начата операция обнуления балансов по кассовым секциям у закрытых лицевых счетов с общим нулевым балансом...';de='Die Nullung von Bilanzen nach Kassensektionen bei geschlossenen Personenkonten mit allgemeiner Nullbilanz wurde gestartet…'"), EventLogEntryTransactionMode.Transactional);
	// Get payment section balances for closed folios with zero total balance
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	FoliosWithBalances.СчетПроживания,
	|	FoliosWithBalances.SumBalance
	|INTO FoliosWithBalances
	|FROM
	|	AccumulationRegister.Взаиморасчеты.Balance(
	|			,
	|			СчетПроживания.IsClosed
	|				AND (Гостиница = &qHotel
	|					OR &qHotelIsEmpty)) AS FoliosWithBalances
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	AccountsBalance.Гостиница,
	|	AccountsBalance.СчетПроживания,
	|	AccountsBalance.ВалютаЛицСчета,
	|	AccountsBalance.PaymentSection,
	|	AccountsBalance.SumBalance
	|FROM
	|	AccumulationRegister.Взаиморасчеты.Balance(
	|			,
	|			СчетПроживания.IsClosed
	|				AND (Гостиница = &qHotel
	|					OR &qHotelIsEmpty)) AS AccountsBalance
	|WHERE
	|	(NOT AccountsBalance.СчетПроживания IN
	|				(SELECT
	|					FoliosWithBalances.СчетПроживания
	|				FROM
	|					FoliosWithBalances AS FoliosWithBalances))";
	vQry.SetParameter("qHotel", Гостиница);
	vQry.SetParameter("qHotelIsEmpty", НЕ ЗначениеЗаполнено(Гостиница));
	vFolios = vQry.Execute().Unload();
	// Process each record received
	For Each vFoliosRow In vFolios Do
		Movement = RegisterRecords.Взаиморасчеты.Add();
		
		Movement.RecordType = AccumulationRecordType.Expense;
		Movement.Period = Date;
		
		// Fill properties
		FillPropertyValues(Movement, vFoliosRow);
		
		// Resources
		Movement.Сумма = vFoliosRow.SumBalance;
		
		// Attributes
		If ЗначениеЗаполнено(Movement.PaymentSection) Тогда
			Movement.СтавкаНДС = Movement.PaymentSection.СтавкаНДС;
		ElsIf ЗначениеЗаполнено(Movement.Гостиница) And ЗначениеЗаполнено(Movement.Гостиница.Фирма) Тогда
			Movement.СтавкаНДС = Movement.Гостиница.Фирма.СтавкаНДС;
		EndIf;
	EndDo;
	If vFolios.Count() > 0 Тогда
		// Write movements
		RegisterRecords.Взаиморасчеты.Write();
	EndIf;
	// Log end of fixing folio payment section balances
	WriteLogEvent(NStr("en='CloseOfPeriod.FixPaymentSectionFolioBalances';ru='ЗакрытиеПериода.ОбнулениеБалансовЛицевыхСчетовПоКассовымСекциям';de='CloseOfPeriod.FixPaymentSectionFolioBalances'"), EventLogLevel.Information, Metadata(), Ref, NStr("en='Payment section balances fixed: ';ru='Обнулено строк балансов: ';de='Bilanzzeilen genullt: '") + vFolios.Count(), EventLogEntryTransactionMode.Transactional);
КонецПроцедуры //CloseCashRegisterFolioBalances

//-----------------------------------------------------------------------------
// Document will:
// 1. Create settlements to close balances in Current Accounts Receivable
// 2. Do payments distribution to services charged
//-----------------------------------------------------------------------------
Процедура Posting(pCancel, pPostingMode)
	If ThisObject.DataExchange.Load Тогда
		Return;
	EndIf;
	
	// Check if daocument was already posted
	vIsPosted = CheckIfDocumentIsAlreadyPosted();
	
	// Add data locks
	If ЗначениеЗаполнено(Company) Тогда
		vDataLock = New DataLock();
		vCmpItem = vDataLock.Add("Catalog.Фирмы");
		vCmpItem.Mode = DataLockMode.Exclusive;
		vCmpItem.SetValue("Ref", Company);
		vDataLock.Lock();
	EndIf;
	
	// 1. Close folios with empty parent document but with "period to" filled and 
	// less or equal close period date or with deleted parent document
	CloseOrphanFolios(vIsPosted);
	
	// 2. Close cash register section folio balances
	CloseCashRegisterFolioBalances(vIsPosted);
	
	// 3. Update reporting currency exchange rates for the charges on the closing date
	UpdateReportingCurrencyExchangeRates(Date, vIsPosted);
	// and date after closing (because we are loading rates for tomorrow today by common scenario)
	UpdateReportingCurrencyExchangeRates(Date + 24*3600, vIsPosted);
	
	// 4. Delete services that should be charged externally
	DeleteServicesThatShouldBeChargedExternally(vIsPosted);
	
	// 5. Get guest groups with corrections
	WriteLogEvent(NStr("en='CloseOfPeriod.SearchingGuestGroupsWithCorrections';ru='ЗакрытиеПериода.ПоискГруппГостейСКорректировками';de='CloseOfPeriod.SearchingGuestGroupsWithCorrections'"), EventLogLevel.Information, Metadata(), Ref, NStr("en='Start of searching guest groups with corrections...';ru='Начата операция получения списка групп гостей, по которым были корректировки...';de='Das Abrufen der Gästegruppenliste wurde gestartet, zu denen es Korrekturen gab…'"), EventLogEntryTransactionMode.Transactional);
	vGuestGroupsWithCorrections = GetGuestGroupsWithCorrections(vIsPosted);
	WriteLogEvent(NStr("en='CloseOfPeriod.SearchingGuestGroupsWithCorrections';ru='ЗакрытиеПериода.ПоискГруппГостейСКорректировками';de='CloseOfPeriod.SearchingGuestGroupsWithCorrections'"), EventLogLevel.Information, Metadata(), Ref, NStr("en='Number of guest groups with corrections found is ';ru='Найдено групп гостей, по которым были корректировки: ';de='Es wurden Gästegruppen gefunden, zu denen es Korrekturen gab:'") + vGuestGroupsWithCorrections.Count(), EventLogEntryTransactionMode.Transactional);
	If vGuestGroupsWithCorrections.Count() > 100 Тогда
		WriteLogEvent(NStr("en='CloseOfPeriod.SearchingGuestGroupsWithCorrections';ru='ЗакрытиеПериода.ПоискГруппГостейСКорректировками';de='CloseOfPeriod.SearchingGuestGroupsWithCorrections'"), EventLogLevel.Warning, Metadata(), Ref, NStr("ru='Слишком много групп, список очищен!';en='Too much groups found. List is cleared!';de='Too much groups found. List is cleared!'"), EventLogEntryTransactionMode.Transactional);
		vGuestGroupsWithCorrections.Clear();
	EndIf;
	
	// 6. Close hotel products waiting for the hotel product number to be entered
	CloseHotelProducts(pCancel, pPostingMode, vIsPosted, vGuestGroupsWithCorrections);
	
	// 7. Close current accounts receivable
	CloseCurrentAccountsReceivable(pCancel, pPostingMode, vIsPosted, vGuestGroupsWithCorrections);
	
	// 8. Do payments distribution to services charged
	DoPaymentsDistributionToServices(pCancel, pPostingMode);
	
	// 9. Close service registrations
	If CloseServiceRegistration Тогда
		CloseServiceRegistration();
	EndIf;
	
	// 10. Archive not used preauthorisations
	ArchivePreauthorisations(vIsPosted);
	
	// 11. Move hotel accounting date
	vNewAccountingDate = BegOfDay(EndOfDay(Date) + 1);
	If ЗначениеЗаполнено(Гостиница) And Гостиница.AccountingDate < vNewAccountingDate Тогда
		vHotelObj = Гостиница.GetObject();
		vHotelObj.УчетнаяДата = vNewAccountingDate;
		vHotelObj.Write();
	EndIf;
	
	// 12. Process user exit algorithm if any
	vUserExitProc = Справочники.ВнешниеОбработки.ЗакрытиеПериода;
	If ЗначениеЗаполнено(vUserExitProc) Тогда
		If vUserExitProc.ExternalProcessingType = Перечисления.ExternalProcessingTypes.Algorithm Тогда
			If НЕ IsBlankString(vUserExitProc.Algorithm) Тогда
				// Log start of user external algorithm
				WriteLogEvent(NStr("en='CloseOfPeriod.UserExitProcedure';ru='ЗакрытиеПериода.АлгоритмПользователя';de='CloseOfPeriod.UserExitProcedure'"), EventLogLevel.Information, Metadata(), Ref, NStr("en='Start of user exit procedure...';ru='Начато выполнение пользовательского алгоритма...';de='Die Ausführung des Nutzeralgorithmus wurde gestartet…'"), EventLogEntryTransactionMode.Transactional);
				Execute(TrimAll(vUserExitProc.Algorithm));
				WriteLogEvent(NStr("en='CloseOfPeriod.UserExitProcedure';ru='ЗакрытиеПериода.АлгоритмПользователя';de='CloseOfPeriod.UserExitProcedure'"), EventLogLevel.Information, Metadata(), Ref, NStr("en='End of user exit procedure';ru='Закончено выполнение пользовательского алгоритма';de='Die Ausführung des Nutzeralgorithmus ist abgeschlossen'"), EventLogEntryTransactionMode.Transactional);
			EndIf;
		EndIf;
	EndIf;
КонецПроцедуры //Posting

//-----------------------------------------------------------------------------
Процедура CreateAndPostSettlement(pDimensionsRow, pAccountingCustomer, pAccountingContract, pAccountingCurrency, 
                                  pLanguage, pCharges, pIsCorrection = False)
	vSettlementObj = Documents.Акт.CreateDocument();
	// Fill settlement attributes
	vSettlementObj.ДатаДок = Date;
	vSettlementObj.Автор = ПараметрыСеанса.ТекПользователь;
	vSettlementObj.Гостиница = pDimensionsRow.Гостиница;
	vSettlementObj.ДокОснование = Неопределено;
	vSettlementObj.Фирма = pDimensionsRow.Фирма;
	vSettlementObj.SetNewNumber();
	vSettlementObj.Контрагент = pAccountingCustomer;
	vSettlementObj.Договор = pAccountingContract;
	vSettlementObj.ГруппаГостей = pDimensionsRow.ГруппаГостей;
	vSettlementObj.ВалютаРасчетов = pAccountingCurrency;
	vSettlementObj.HotelProductParent = pDimensionsRow.HotelProductParent;
	vSettlementObj.Примечания = "";
	If pIsCorrection Тогда
		vSettlementObj.Примечания = NStr("en='Is correction! ';ru='Корректировка! ';de='Korrektur! '");
	EndIf;
	vSettlementObj.Примечания = vSettlementObj.Примечания + NStr("ru = 'Закрытие периода № " + TrimAll(Number) + "'; en = 'Close of period N " + TrimAll(Number) + "'; de = 'Close of period N " + TrimAll(Number) + "'");
	vSettlementObj.InvoiceNumber = "";
	vSettlementObj.ЗакрытиеПериода = Ref;
	vSettlementObj.СпособОплаты = Справочники.СпособОплаты.Акт;
	//vSettlementObj.pmFillServices(pCharges, pLanguage);
	vSettlementObj.Сумма = vSettlementObj.Услуги.Total("Сумма");
	vSettlementObj.СуммаНДС = vSettlementObj.Услуги.Total("СуммаНДС");
	vSettlementObj.СуммаКомиссии = vSettlementObj.Услуги.Total("СуммаКомиссии");
	If SplitSettllementsByVATRate And vSettlementObj.Услуги.Count() > 0 Тогда
		v1SrvRow = vSettlementObj.Услуги.Get(0);
		vSettlementObj.СтавкаНДС = v1SrvRow.СтавкаНДС;
	EndIf;		
	// Экспорт to the accounting system flag
	If ЗначениеЗаполнено(pDimensionsRow.SeparateService) Тогда
		If pDimensionsRow.SeparateService.DoNotExportToTheAccountingSystem Тогда
			vSettlementObj.DoNotExportToTheAccountingSystem = True;
		EndIf;
	EndIf;
	// Fill list of payments
//	If ЗначениеЗаполнено(vSettlementObj.Контрагент) And 
//	   ЗначениеЗаполнено(vSettlementObj.Гостиница) And 
//	   ЗначениеЗаполнено(vSettlementObj.ГруппаГостей) Тогда
//		If vSettlementObj.Контрагент <> vSettlementObj.Гостиница.IndividualsCustomer Тогда
//			vSettlementObj.pmFillListOfPayments();
//		EndIf;
//	EndIf;
	// Post settlement
	If vSettlementObj.Услуги.Count() > 0 Тогда
		vSettlementObj.Write(DocumentWriteMode.Posting);
	EndIf;
КонецПроцедуры //CreateAndPostSettlement 

//-----------------------------------------------------------------------------
Function pmCheckDocumentAttributes(pMessage, pAttributeInErr) Экспорт
	vHasErrors = False;
	pMessage = "";
	pAttributeInErr = "";
	vMsgTextRu = "";
	vMsgTextEn = "";
	vMsgTextDe = "";
	If НЕ ЗначениеЗаполнено(Date) Тогда
		vHasErrors = True; 
		vMsgTextRu = vMsgTextRu + "Реквизит <Дата закрытия периода> должен быть заполнен!" + Chars.LF;
		vMsgTextEn = vMsgTextEn + "<Close of period date> attribute should be filled!" + Chars.LF;
		vMsgTextDe = vMsgTextDe + "<Close of period date> attribute should be filled!" + Chars.LF;
		pAttributeInErr = ?(pAttributeInErr = "", "Date", pAttributeInErr);
	EndIf;
	If vHasErrors Тогда
		pMessage = "ru='" + TrimAll(vMsgTextRu) + "';" + "en='" + TrimAll(vMsgTextEn) + "';" + "de='" + TrimAll(vMsgTextDe) + "';";
	EndIf;
	Return vHasErrors;
EndFunction //CheckDocumentAttributes

//-----------------------------------------------------------------------------
Процедура pmFillAuthorAndDate() Экспорт
	Author = ПараметрыСеанса.ТекПользователь;
	Date = EndOfDay(CurrentDate()) - 24*3600; // End of previous calendar day
КонецПроцедуры //pmFillAuthorAndDate

//-----------------------------------------------------------------------------
Процедура pmFillAttributesWithDefaultValues() Экспорт
	// Fill author and document date
	pmFillAuthorAndDate();
	// Fill from session parameters
	If НЕ ЗначениеЗаполнено(Гостиница) Тогда
		Гостиница = ПараметрыСеанса.ТекущаяГостиница;
		CloseServiceRegistration = Гостиница.CloseServiceRegistration;
	EndIf;
	If ЗначениеЗаполнено(Гостиница) Тогда
		Company = Гостиница.Фирма;
		If ЗначениеЗаполнено(Company) Тогда
			pmFillByCompany(Company);
		EndIf;
	EndIf;
КонецПроцедуры //pmFillAttributesWithDefaultValues

//-----------------------------------------------------------------------------
Процедура pmFillByCompany(pCompany) Экспорт
	If НЕ ЗначениеЗаполнено(pCompany) Тогда
		Return;
	EndIf;
	Company = pCompany;
	// Check Фирма accounting policy
	ProcessClosedFoliosOnly = False;
	DoNotCloseIndividuals = False;
	If ЗначениеЗаполнено(Company.CompanyAccountingPolicyType) Тогда
		If Company.CompanyAccountingPolicyType = Перечисления.CompanyAccountingPolicyTypes.ByCheckedOutGuestsServices Or
		   Company.CompanyAccountingPolicyType = Перечисления.CompanyAccountingPolicyTypes.ByCheckedOutGuestGroupsServices Тогда
			If НЕ ЗначениеЗаполнено(Company.TaxAccountingPeriodType) Or Company.TaxAccountingPeriodType = Перечисления.TaxAccountingPeriodTypes.Month Тогда
				If EndOfDay(Date) <> EndOfMonth(Date) Тогда
					ProcessClosedFoliosOnly = True;
					If Company.CloseIndividualsAtAccountingPeriodEndOnly Тогда
						DoNotCloseIndividuals = True;
					EndIf;
				EndIf;
			ElsIf Company.TaxAccountingPeriodType = Перечисления.TaxAccountingPeriodTypes.Quarter Тогда
				If EndOfDay(Date) <> EndOfQuarter(Date) Тогда
					ProcessClosedFoliosOnly = True;
					If Company.CloseIndividualsAtAccountingPeriodEndOnly Тогда
						DoNotCloseIndividuals = True;
					EndIf;
				EndIf;
			ElsIf Company.TaxAccountingPeriodType = Перечисления.TaxAccountingPeriodTypes.HalfYear Тогда
				If EndOfDay(Date) <> AddMonth(EndOfYear(Date), -6) Тогда
					ProcessClosedFoliosOnly = True;
					If Company.CloseIndividualsAtAccountingPeriodEndOnly Тогда
						DoNotCloseIndividuals = True;
					EndIf;
				EndIf;
			ElsIf Company.TaxAccountingPeriodType = Перечисления.TaxAccountingPeriodTypes.Year Тогда
				If EndOfDay(Date) <> EndOfYear(Date) Тогда
					ProcessClosedFoliosOnly = True;
					If Company.CloseIndividualsAtAccountingPeriodEndOnly Тогда
						DoNotCloseIndividuals = True;
					EndIf;
				EndIf;
			ElsIf Company.TaxAccountingPeriodType = Перечисления.TaxAccountingPeriodTypes.None Тогда
				ProcessClosedFoliosOnly = True;
			EndIf;
		EndIf;
	EndIf;
	OneSettlementPerCustomerGuestGroups = Company.OneSettlementPerCustomerGuestGroups;
	OneSettlementPerIndividualsCustomerGuestGroups = Company.OneSettlementPerIndividualsCustomerGuestGroups;
	SplitSettllementsByVATRate = Company.SplitSettllementsByVATRate;
КонецПроцедуры //pmFillByCompany

//-----------------------------------------------------------------------------
Процедура Filling(pBase)
	// Fill attributes with default values
	pmFillAttributesWithDefaultValues();
	// Fill from the base
	If ЗначениеЗаполнено(pBase) Тогда
		If TypeOf(pBase) = Type("CatalogRef.Фирмы") Тогда
			pmFillByCompany(pBase);
		EndIf;
	EndIf;
КонецПроцедуры //Filling

//-----------------------------------------------------------------------------
Процедура BeforeWrite(pCancel, pWriteMode, pPostingMode)
	Перем vMessage, vAttributeInErr;
	If ThisObject.DataExchange.Load Тогда
		Return;
	EndIf;
	If pWriteMode = DocumentWriteMode.Posting Тогда
		pCancel	= pmCheckDocumentAttributes(vMessage, vAttributeInErr);
		If pCancel Тогда
			WriteLogEvent(NStr("en='Document.DataValidation';ru='Документ.КонтрольДанных';de='Document.DataValidation'"), EventLogLevel.Warning, ThisObject.Metadata(), ThisObject.Ref, NStr(vMessage));
			Message(NStr(vMessage), MessageStatus.Attention);
			ВызватьИсключение NStr(vMessage);
		EndIf;
	EndIf;
КонецПроцедуры //BeforeWrite

//-----------------------------------------------------------------------------
Процедура OnSetNewNumber(pStandardProcessing, pPrefix)
	vPrefix = "";
	If ЗначениеЗаполнено(Гостиница) Тогда
		vPrefix = TrimAll(Гостиница.GetObject().pmGetPrefix());
	ElsIf ЗначениеЗаполнено(ПараметрыСеанса.ТекущаяГостиница) Тогда
		vPrefix = TrimAll(ПараметрыСеанса.ТекущаяГостиница.GetObject().pmGetPrefix());
	EndIf;
	If vPrefix <> "" Тогда
		pPrefix = vPrefix;
	EndIf;
КонецПроцедуры //OnSetNewNumber
