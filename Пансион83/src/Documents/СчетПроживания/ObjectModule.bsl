////-----------------------------------------------------------------------------
//Процедура pmFillAuthorAndDate() Экспорт
//	Date = CurrentDate();
//	Author = ПараметрыСеанса.ТекПользователь;
//КонецПроцедуры //pmFillAuthorAndDate
//
////-----------------------------------------------------------------------------
//Процедура pmFillAttributesWithDefaultValues() Экспорт
//	// Fill author and document date
//	pmFillAuthorAndDate();
//	// Fill from session parameters
//	IsClosed = False;
//	If НЕ ЗначениеЗаполнено(Гостиница) Тогда
//		Гостиница = ПараметрыСеанса.ТекущаяГостиница;
//	EndIf;
//	If ЗначениеЗаполнено(Гостиница) Тогда
//		If НЕ ЗначениеЗаполнено(FolioCurrency) Тогда
//			FolioCurrency = Гостиница.FolioCurrency;
//		EndIf;
//		If НЕ ЗначениеЗаполнено(PaymentMethod) Тогда
//			PaymentMethod = Гостиница.PlannedPaymentMethod;
//		EndIf;
//		If НЕ ЗначениеЗаполнено(Фирма) Тогда
//			Фирма = Гостиница.Фирма;
//		EndIf;
//	EndIf;
//КонецПроцедуры //pmFillAttributesWithDefaultValues
//
////-----------------------------------------------------------------------------
//Function pmCheckDocumentAttributes(pMessage, pAttributeInErr) Экспорт
//	vHasErrors = False;
//	pMessage = "";
//	pAttributeInErr = "";
//	vMsgTextRu = "";
//	vMsgTextEn = "";
//	vMsgTextDe = "";
//	If НЕ ЗначениеЗаполнено(FolioCurrency) Тогда
//		vHasErrors = True; 
//		vMsgTextRu = vMsgTextRu + "Реквизит <Валюта лицевого счета> должен быть заполнен!" + Chars.LF;
//		vMsgTextEn = vMsgTextEn + "<СчетПроживания Валюта> attribute should be filled!" + Chars.LF;
//		vMsgTextDe = vMsgTextDe + "<СчетПроживания Валюта> attribute should be filled!" + Chars.LF;
//		pAttributeInErr = ?(pAttributeInErr = "", "ВалютаЛицСчета", pAttributeInErr);
//	EndIf;
//	If vHasErrors Тогда
//		pMessage = "ru='" + TrimAll(vMsgTextRu) + "';" + "en='" + TrimAll(vMsgTextEn) + "';" + "de='" + TrimAll(vMsgTextDe) + "';";
//	EndIf;
//	Return vHasErrors;
//EndFunction //pmCheckDocumentAttributes
//
////-----------------------------------------------------------------------------
//// Get folio balance
//// - pDate is optional. If is not specified, then function calculates current balance
//// - pHotel is optional. If is not specified, then function calculates balance for the 
////   folio hotel. If it is not specified, then function calculates balance per all hotels.
//// - pPaymentSection is optional. If it is specified, then function calculates balance for the given payment section only
//// Returns balance as number
////-----------------------------------------------------------------------------
//Function pmGetBalance(Val pDate = Неопределено, Val pHotel = Неопределено, Val pPaymentSection = Неопределено, pLimit = 0) Экспорт
//	// Fill parameter default values 
//	If НЕ ЗначениеЗаполнено(pDate) Тогда
//		pDate = '39991231235959';
//		vHotel = pHotel;
//		If НЕ ЗначениеЗаполнено(vHotel) Тогда
//			vHotel = Гостиница;
//		EndIf;
//		If ЗначениеЗаполнено(vHotel) Тогда
//			If vHotel.ShowDebtsOnCurrentDate Тогда
//				pDate = CurrentDate();
//			EndIf;
//		EndIf;
//	EndIf;
//
//	// Build query to get accounts balance
//	rVATBalance = 0;
//	vAccBalance = 0;
//	vLimit = 0;
//	vQry = New Query;
//	vQry.Text =
//	"SELECT
//	|	SUM(ISNULL(AccountsBalance.SumBalance, 0)) AS SumBalance, 
//	|	-SUM(ISNULL(AccountsBalance.LimitBalance, 0)) AS LimitBalance, " +
//		?(ЗначениеЗаполнено(pHotel), "AccountsBalance.Гостиница AS Гостиница, ", "") + 
//	"	AccountsBalance.ВалютаЛицСчета AS ВалютаЛицСчета,
//	|	AccountsBalance.СчетПроживания AS СчетПроживания
//	|FROM
//	|	AccumulationRegister.Взаиморасчеты.Balance(&qDate, " +
//		?(ЗначениеЗаполнено(pHotel), "Гостиница = &qHotel AND ", "") +
//		?(pPaymentSection <> Неопределено, "PaymentSection = &qPaymentSection AND ", "") +
//		"ВалютаЛицСчета = &qFolioCurrency AND СчетПроживания = &qFolio) AS AccountsBalance
//	|GROUP BY " +
//		?(ЗначениеЗаполнено(pHotel), "AccountsBalance.Гостиница, ", "") +
//	"	AccountsBalance.ВалютаЛицСчета,
//	|	AccountsBalance.СчетПроживания";
//	vQry.SetParameter("qDate", pDate);
//	vQry.SetParameter("qHotel", pHotel);
//	vQry.SetParameter("qFolioCurrency", FolioCurrency);
//	vQry.SetParameter("qFolio", Ref);
//	vQry.SetParameter("qPaymentSection", pPaymentSection);
//	vQryRes = vQry.Execute().Unload();
//	For Each vQryResRow In vQryRes Do
//		vAccBalance = vAccBalance + vQryResRow.SumBalance;
//		vLimit = vLimit + vQryResRow.LimitBalance;
//	EndDo;	
//	pLimit = vLimit;
//	
//	Return vAccBalance;
//EndFunction //pmGetBalance
//
////-----------------------------------------------------------------------------
//// Get folio payment section balances
//// - pDate is optional. If is not specified, then function calculates current balance
//// - pHotel is optional. If is not specified, then function calculates balance for the 
////   folio hotel. If it is not specified, then function calculates balance per all hotels.
//// - pPaymentSection is optional. If it is specified, then function calculates balance for the given payment section only
//// Returns balances for each folio payment section in a value table
////-----------------------------------------------------------------------------
//Function pmGetPaymentSectionBalances(Val pDate = Неопределено, Val pHotel = Неопределено, Val pPaymentSection = Неопределено) Экспорт
//	// Fill parameter default values 
//	If НЕ ЗначениеЗаполнено(pDate) Тогда
//		pDate = '39991231235959';
//		vHotel = pHotel;
//		If НЕ ЗначениеЗаполнено(vHotel) Тогда
//			vHotel = Гостиница;
//		EndIf;
//		If ЗначениеЗаполнено(vHotel) Тогда
//			If vHotel.ShowDebtsOnCurrentDate Тогда
//				pDate = CurrentDate();
//			EndIf;
//		EndIf;
//	EndIf;
//
//	// Build query to get accounts balance
//	rVATBalance = 0;
//	vAccBalance = 0;
//	vQry = New Query;
//	vQry.Text =
//	"SELECT
//	|	SUM(ISNULL(AccountsBalance.SumBalance, 0)) AS SumBalance, " +
//		?(ЗначениеЗаполнено(pHotel), "AccountsBalance.Гостиница AS Гостиница, ", "") + 
//	"	AccountsBalance.ВалютаЛицСчета AS ВалютаЛицСчета,
//	|	AccountsBalance.PaymentSection AS PaymentSection,
//	|	AccountsBalance.СчетПроживания AS СчетПроживания
//	|FROM
//	|	AccumulationRegister.Взаиморасчеты.Balance(&qDate, " +
//		?(ЗначениеЗаполнено(pHotel), "Гостиница = &qHotel AND ", "") +
//		?(pPaymentSection <> Неопределено, "PaymentSection = &qPaymentSection AND ", "") +
//		"ВалютаЛицСчета = &qFolioCurrency AND СчетПроживания = &qFolio) AS AccountsBalance
//	|GROUP BY " +
//		?(ЗначениеЗаполнено(pHotel), "AccountsBalance.Гостиница, ", "") +
//	"	AccountsBalance.ВалютаЛицСчета,
//	|	AccountsBalance.PaymentSection, 
//	|	AccountsBalance.СчетПроживания";
//	vQry.SetParameter("qDate", pDate);
//	vQry.SetParameter("qHotel", pHotel);
//	vQry.SetParameter("qFolioCurrency", FolioCurrency);
//	vQry.SetParameter("qFolio", Ref);
//	vQryRes = vQry.Execute().Unload();
//	
//	Return vQryRes;
//EndFunction //pmGetPaymentSectionBalances
//
////-----------------------------------------------------------------------------
//Function pmGetAllFolioTransactions(pRecordersList = Неопределено) Экспорт
//	vQry = New Query();
//	vQry.Text =
//	"SELECT
//	|	Взаиморасчеты.Recorder AS Document,
//	|	Взаиморасчеты.Начисление AS Начисление,
//	|	Взаиморасчеты.RecordType,
//	|	Взаиморасчеты.СчетПроживания,
//	|	Взаиморасчеты.СчетПроживания.ДокОснование AS FolioParentDoc,
//	|	Взаиморасчеты.Начисление.ДокОснование AS ChargeParentDoc,
//	|	Взаиморасчеты.СчетПроживания.Клиент AS FolioClient,
//	|	Взаиморасчеты.PaymentSection,
//	|	Взаиморасчеты.Услуга,
//	|	Взаиморасчеты.Сумма,
//	|	Взаиморасчеты.СуммаНДС,
//	|	Взаиморасчеты.Количество,
//	|	Взаиморасчеты.Цена,
//	|	Взаиморасчеты.Limit,
//	|	CASE
//	|		WHEN Взаиморасчеты.RecordType = &qExpense AND Взаиморасчеты.СпособОплаты <> &qSettlement
//	|			THEN Взаиморасчеты.Сумма
//	|		ELSE
//	|			0
//	|	END AS PaymentSum,
//	|	Взаиморасчеты.Начисление.Цена AS NettoPrice,
//	|	Взаиморасчеты.Начисление.СуммаСкидки AS Скидка,
//	|	Взаиморасчеты.Period AS Period,
//	|	Взаиморасчеты.Примечания,
//	|	Взаиморасчеты.СпособОплаты,
//	|	Взаиморасчеты.Recorder.НомерДока AS RecorderNumber,
//	|	Взаиморасчеты.Recorder.Payer AS Payer,
//	|	Взаиморасчеты.IsRoomRevenue,
//	|	Взаиморасчеты.IsInPrice,
//	|	Взаиморасчеты.ТипДеньКалендарь,
//	|	Взаиморасчеты.НомерРазмещения AS НомерРазмещения,
//	|	Взаиморасчеты.СтавкаНДС,
//	|	CASE
//	|		WHEN (NOT ISNULL(Взаиморасчеты.Начисление.IsFixedCharge, FALSE))
//	|			THEN Взаиморасчеты.Начисление.Performer
//	|		ELSE &qEmptyEmployee
//	|	END AS Performer
//	|FROM
//	|	AccumulationRegister.Взаиморасчеты AS Взаиморасчеты
//	|WHERE
//	|	Взаиморасчеты.СчетПроживания = &qFolio
//	|	AND (NOT Взаиморасчеты.Recorder REFS Document.ЗакрытиеПериода)" + 
//		?(pRecordersList <> Неопределено, " AND Взаиморасчеты.Recorder IN (&qRecordersList) ", "") + "
//	|ORDER BY
//	|	Period";
//	vQry.SetParameter("qFolio", Ref);
//	vQry.SetParameter("qRecordersList", pRecordersList);
//	vQry.SetParameter("qEmptyEmployee", Справочники.Сотрудники.EmptyRef());
//	vQry.SetParameter("qExpense", AccumulationRecordType.Expense);
//	vQry.SetParameter("qSettlement", Справочники.СпособОплаты.Акт);
//	Return vQry.Execute().Unload();
//EndFunction //pmGetAllFolioTransactions
//
////-----------------------------------------------------------------------------
//Function pmGetRoomRateServicesTurnover(pPeriodFrom = '00010101', pPeriodTo = '39991231235959', pPaymentSection = Неопределено) Экспорт
//	vQry = New Query();
//	vQry.Text =
//	"SELECT
//	|	Взаиморасчеты.ВалютаЛицСчета AS ВалютаЛицСчета,
//	|	SUM(Взаиморасчеты.Сумма) AS Сумма
//	|FROM
//	|	AccumulationRegister.Взаиморасчеты AS Взаиморасчеты
//	|WHERE
//	|	Взаиморасчеты.СчетПроживания = &qFolio AND NOT (Взаиморасчеты.Recorder REFS Document.ЗакрытиеПериода)
//	|	AND Взаиморасчеты.Period >= &qPeriodFrom
//	|	AND Взаиморасчеты.Period < &qPeriodTo
//	|	AND (Взаиморасчеты.PaymentSection = &qPaymentSection
//	|			OR (NOT &qPaymentSectionIsSet))
//	|	AND Взаиморасчеты.RecordType = &qReceipt
//	|	AND (NOT Взаиморасчеты.Recorder.IsAdditional)
//	|GROUP BY
//	|	Взаиморасчеты.ВалютаЛицСчета";
//	vQry.SetParameter("qFolio", Ref);
//	vQry.SetParameter("qPeriodFrom", pPeriodFrom);
//	vQry.SetParameter("qPeriodTo", pPeriodTo);
//	vQry.SetParameter("qPaymentSection", pPaymentSection);
//	vQry.SetParameter("qPaymentSectionIsSet", ?(pPaymentSection = Неопределено, False, True));
//	vQry.SetParameter("qReceipt", AccumulationRecordType.Receipt);
//	vQryRes = vQry.Execute().Unload();
//	If vQryRes.Count() > 0 Тогда
//		Return vQryRes.Get(0).Сумма;
//	Else
//		Return 0;
//	EndIf;
//EndFunction //pmGetRoomRateServicesTurnover
//
////-----------------------------------------------------------------------------
//Function pmGetAllFolioTransactionsCount() Экспорт
//	vQry = New Query();
//	vQry.Text =
//	"SELECT
//	|	COUNT(*) AS Count
//	|FROM
//	|	AccumulationRegister.Взаиморасчеты AS Взаиморасчеты
//	|WHERE
//	|	Взаиморасчеты.СчетПроживания = &qFolio AND NOT (Взаиморасчеты.Recorder REFS Document.ЗакрытиеПериода)";
//	vQry.SetParameter("qFolio", Ref);
//	vQryRes = vQry.Execute().Unload();
//	If vQryRes.Count() > 0 Тогда
//		vRow = vQryRes.Get(0);
//		Return vRow.Count;
//	Else
//		Return 0;
//	EndIf;
//EndFunction //pmGetAllFolioTransactionsCount
//
////-----------------------------------------------------------------------------
//Function pmGetAllFolioCharges() Экспорт
//	vQry = New Query();
//	vQry.Text =
//	"SELECT
//	|	Взаиморасчеты.Recorder AS Document,
//	|	Взаиморасчеты.Начисление AS Начисление,
//	|	Взаиморасчеты.СчетПроживания,
//	|	Взаиморасчеты.PaymentSection,
//	|	Взаиморасчеты.Услуга,
//	|	Взаиморасчеты.Сумма,
//	|	Взаиморасчеты.СуммаНДС,
//	|	Взаиморасчеты.Количество,
//	|	Взаиморасчеты.Цена,
//	|	Взаиморасчеты.Period,
//	|	Взаиморасчеты.Примечания,
//	|	Взаиморасчеты.СпособОплаты,
//	|	Взаиморасчеты.Recorder.НомерДока AS RecorderNumber,
//	|	Взаиморасчеты.Recorder.Payer AS Payer,
//	|	Взаиморасчеты.IsRoomRevenue,
//	|	Взаиморасчеты.IsInPrice,
//	|	Взаиморасчеты.ТипДеньКалендарь
//	|FROM
//	|	AccumulationRegister.Взаиморасчеты AS Взаиморасчеты
//	|WHERE
//	|	Взаиморасчеты.СчетПроживания = &qFolio
//	|	AND Взаиморасчеты.RecordType = &qReceipt
//	|ORDER BY
//	|	Взаиморасчеты.Period";
//	vQry.SetParameter("qFolio", Ref);
//	vQry.SetParameter("qReceipt", AccumulationRecordType.Receipt);
//	Return vQry.Execute().Unload();
//EndFunction //pmGetAllFolioCharges
//
////-----------------------------------------------------------------------------
//Function pmGetAllFolioDeposits(pPostedOnly = True) Экспорт
//	vQry = New Query;
//	vQry.Text =
//	"SELECT
//	|	Депозиты.Period AS Period,
//	|	Депозиты.Recorder AS Document,
//	|	Депозиты.Сумма AS Сумма,
//	|	Депозиты.Limit AS Limit,
//	|	Депозиты.Recorder.НомерДока AS Number,
//	|	Депозиты.Payer AS Payer,
//	|	Депозиты.PaymentSection AS PaymentSection,
//	|	Депозиты.СпособОплаты AS СпособОплаты,
//	|	Депозиты.Автор AS Автор,
//	|	Депозиты.Касса AS Касса,
//	|	Депозиты.Recorder.Status AS Status,
//	|	FALSE AS IsAnnulated
//	|FROM
//	|	AccumulationRegister.Депозиты AS Депозиты
//	|WHERE
//	|	Депозиты.СчетПроживания = &qFolio
//	|
//	|UNION ALL
//	|
//	|SELECT
//	|	AnnulatedPayments.ДатаДок,
//	|	AnnulatedPayments.Ref,
//	|	AnnulatedPayments.SumInFolioCurrency,
//	|	0,
//	|	AnnulatedPayments.НомерДока,
//	|	AnnulatedPayments.Payer,
//	|	AnnulatedPayments.PaymentSection,
//	|	AnnulatedPayments.СпособОплаты,
//	|	AnnulatedPayments.Автор,
//	|	AnnulatedPayments.Касса,
//	|	&qAnnulationStatus,
//	|	TRUE
//	|FROM
//	|	Document.Платеж AS AnnulatedPayments
//	|WHERE
//	|	(NOT &qPostedOnly)
//	|	AND AnnulatedPayments.СчетПроживания = &qFolio
//	|	AND AnnulatedPayments.DeletionMark
//	|	AND AnnulatedPayments.DateOfAnnulation > &qEmptyDate
//	|
//	|ORDER BY
//	|	Period";
//	vQry.SetParameter("qFolio", Ref);
//	vQry.SetParameter("qPostedOnly", pPostedOnly);
//	vQry.SetParameter("qEmptyDate", '00010101');
//	vQry.SetParameter("qAnnulationStatus", "Аннулирован");
//	Return vQry.Execute().Unload();
//EndFunction //pmGetAllFolioDeposits
//
////-----------------------------------------------------------------------------
//Function pmGetAllFolioDepositsCount() Экспорт
//	vQry = New Query();
//	vQry.Text =
//	"SELECT
//	|	COUNT(*) AS Count
//	|FROM
//	|	AccumulationRegister.Депозиты AS Депозиты
//	|WHERE
//	|	Депозиты.СчетПроживания = &qFolio";
//	vQry.SetParameter("qFolio", Ref);
//	vQryRes = vQry.Execute().Unload();
//	If vQryRes.Count() > 0 Тогда
//		vRow = vQryRes.Get(0);
//		Return vRow.Count;
//	Else
//		Return 0;
//	EndIf;
//EndFunction //pmGetAllFolioDepositsCount
//
////-----------------------------------------------------------------------------
//Function pmGetAllFolioSettlements() Экспорт
//	vQry = New Query;
//	vQry.Text =
//	"SELECT
//	|	БухРеализацияУслуг.СчетПроживания AS СчетПроживания,
//	|	БухРеализацияУслуг.Period AS Period,
//	|	БухРеализацияУслуг.Recorder AS Document,
//	|	БухРеализацияУслуг.Recorder.НомерДока AS Number,
//	|	БухРеализацияУслуг.Контрагент AS Контрагент,
//	|	БухРеализацияУслуг.Договор AS Договор,
//	|	БухРеализацияУслуг.ВалютаРасчетов AS Валюта,
//	|	БухРеализацияУслуг.ГруппаГостей AS ГруппаГостей,
//	|	БухРеализацияУслуг.Фирма AS Фирма,
//	|	БухРеализацияУслуг.Recorder.Автор AS Автор,
//	|	SUM(БухРеализацияУслуг.Сумма) AS Сумма
//	|FROM
//	|	AccumulationRegister.БухРеализацияУслуг AS БухРеализацияУслуг
//	|WHERE
//	|	БухРеализацияУслуг.СчетПроживания = &qFolio
//	|GROUP BY
//	|	БухРеализацияУслуг.СчетПроживания,
//	|	БухРеализацияУслуг.Period,
//	|	БухРеализацияУслуг.Recorder,
//	|	БухРеализацияУслуг.Контрагент,
//	|	БухРеализацияУслуг.Договор,
//	|	БухРеализацияУслуг.ВалютаРасчетов,
//	|	БухРеализацияУслуг.ГруппаГостей,
//	|	БухРеализацияУслуг.Фирма,
//	|	БухРеализацияУслуг.Recorder.НомерДока,
//	|	БухРеализацияУслуг.Recorder.Автор
//	|ORDER BY
//	|	Period";
//	vQry.SetParameter("qFolio", Ref);
//	Return vQry.Execute().Unload();
//EndFunction //pmGetAllFolioSettlements
//
////-----------------------------------------------------------------------------
//Function pmGetAllFolioSettlementsRowsCount() Экспорт
//	vQry = New Query();
//	vQry.Text =
//	"SELECT
//	|	COUNT(*) AS Count
//	|FROM
//	|	AccumulationRegister.РелизацияТекОтчетПериод AS РелизацияТекОтчетПериод
//	|WHERE
//	|	РелизацияТекОтчетПериод.СчетПроживания = &qFolio";
//	vQry.SetParameter("qFolio", Ref);
//	vQryRes = vQry.Execute().Unload();
//	If vQryRes.Count() > 0 Тогда
//		vRow = vQryRes.Get(0);
//		Return vRow.Count;
//	Else
//		Return 0;
//	EndIf;
//EndFunction //pmGetAllFolioSettlementsRowsCount
//
////-----------------------------------------------------------------------------
//Function pmGetAllChargeTransfersFrom() Экспорт
//	vQry = New Query();
//	vQry.Text = 
//	"SELECT
//	|	ПеремещениеНачисления.Ref AS Document,
//	|	ПеремещениеНачисления.ParentCharge.ДатаДок AS Period,
//	|	ПеремещениеНачисления.ParentCharge.Услуга AS Услуга,
//	|	ПеремещениеНачисления.ParentCharge.Сумма AS Сумма,
//	|	ПеремещениеНачисления.ParentCharge.СтавкаНДС AS СтавкаНДС,
//	|	ПеремещениеНачисления.FolioFrom,
//	|	ПеремещениеНачисления.FolioTo,
//	|	ПеремещениеНачисления.Примечания,
//	|	ПеремещениеНачисления.Автор
//	|FROM
//	|	Document.ПеремещениеНачисления AS ПеремещениеНачисления
//	|WHERE
//	|	ПеремещениеНачисления.Posted
//	|	AND ПеремещениеНачисления.FolioFrom = &qFolioFrom
//	|ORDER BY
//	|	ПеремещениеНачисления.PointInTime";
//	vQry.SetParameter("qFolioFrom", Ref);
//	Return vQry.Execute().Unload();
//EndFunction //pmGetAllChargeTransfersFrom
//
////-----------------------------------------------------------------------------
//Function pmGetCurrentAccountsReceivableChargesWithBalances(pDate = Неопределено) Экспорт
//	// Fill parameter default values 
//	If НЕ ЗначениеЗаполнено(pDate) Тогда
//		pDate = CurrentDate();
//	EndIf;
//
//	// Build query to get services
//	vQry = New Query;
//	vQry.Text =
//	"SELECT
//	|	CurrentAccountsReceivableBalance.Гостиница,
//	|	CurrentAccountsReceivableBalance.Фирма,
//	|	CurrentAccountsReceivableBalance.Контрагент,
//	|	CurrentAccountsReceivableBalance.Договор,
//	|	CurrentAccountsReceivableBalance.ГруппаГостей,
//	|	CurrentAccountsReceivableBalance.ВалютаЛицСчета,
//	|	CurrentAccountsReceivableBalance.СчетПроживания,
//	|	CurrentAccountsReceivableBalance.ДокОснование,
//	|	CurrentAccountsReceivableBalance.Начисление.ПутевкаКурсовка AS ПутевкаКурсовка,
//	|	CurrentAccountsReceivableBalance.Начисление AS Начисление,
//	|	CurrentAccountsReceivableBalance.Начисление.Скидка AS Скидка,
//	|	CurrentAccountsReceivableBalance.Начисление.СуммаСкидки AS СуммаСкидки,
//	|	CurrentAccountsReceivableBalance.Начисление.ВидКомиссииАгента AS ВидКомиссииАгента,
//	|	CurrentAccountsReceivableBalance.Начисление.КомиссияАгента AS КомиссияАгента,
//	|	CurrentAccountsReceivableBalance.CommissionSumBalance,
//	|	CurrentAccountsReceivableBalance.SumBalance,
//	|	CurrentAccountsReceivableBalance.VATSumBalance,
//	|	CurrentAccountsReceivableBalance.QuantityBalance
//	|FROM
//	|	AccumulationRegister.РелизацияТекОтчетПериод.Balance(
//	|			&qPeriod,
//	|			СчетПроживания = &qFolio
//	|				AND ВалютаЛицСчета = &qCurrency) AS CurrentAccountsReceivableBalance
//	|
//	|ORDER BY
//	|	CurrentAccountsReceivableBalance.Начисление.PointInTime";
//	vQry.SetParameter("qPeriod", pDate);
//	vQry.SetParameter("qFolio", Ref);
//	vQry.SetParameter("qCurrency", FolioCurrency);
//	vQryRes = vQry.Execute().Unload();
//	
//	Return vQryRes;
//EndFunction //pmGetCurrentAccountsReceivableChargesWithBalances
//
////-----------------------------------------------------------------------------
//Function pmGetHotelProducts() Экспорт
//	vQry = New Query();
//	vQry.Text = 
//	"SELECT
//	|	Начисление.ПутевкаКурсовка
//	|FROM
//	|	Document.Начисление AS Начисление
//	|WHERE
//	|	Начисление.Posted
//	|	AND Начисление.ПутевкаКурсовка <> &qEmptyHotelProduct
//	|	AND Начисление.СчетПроживания = &qFolio
//	|GROUP BY
//	|	Начисление.ПутевкаКурсовка
//	|ORDER BY
//	|	Начисление.ПутевкаКурсовка.Code";
//	vQry.SetParameter("qFolio", Ref);
//	vQry.SetParameter("qEmptyHotelProduct", Справочники.ПутевкиКурсовки.EmptyRef());
//	Return vQry.Execute().Unload();
//EndFunction //pmGetHotelProducts
//
////-----------------------------------------------------------------------------
//Процедура pmChargeServicePackage(pServicePackage, pClientType, pClientTypeConfirmationText = "", pServicesPerformers = Неопределено, pMarketingCode = Неопределено, pMarketingCodeConfirmationText = "", pSourceOfBusiness = Неопределено, pDate = Неопределено) Экспорт
//	If НЕ ЗначениеЗаполнено(pServicePackage) Тогда
//		ВызватьИсключение "Для начисления на лицевой счет не выбран пакет услуг!";
//	EndIf;
//	vPackageServices = pServicePackage.GetObject().pmGetServices(?(ЗначениеЗаполнено(pDate), pDate, CurrentDate())).FindRows(New Structure("ТипКлиента", pClientType));
//	If ЗначениеЗаполнено(pClientType) And vPackageServices.Count() = 0 Тогда
//		vPackageServices = pServicePackage.GetObject().pmGetServices(?(ЗначениеЗаполнено(pDate), pDate, CurrentDate())).FindRows(New Structure("ТипКлиента", Справочники.ТипыКлиентов.EmptyRef()));
//	EndIf;
//	// Do some initialization
//	vIsCheckIn = True;
//	vIsCheckOut = True;
//	vIsRoomChange = False;
//	vIsBeforeRoomChange = False;
//	If ЗначениеЗаполнено(ParentDoc) And TypeOf(ParentDoc) = Type("DocumentRef.Размещение") Тогда
//		If ЗначениеЗаполнено(ParentDoc.СтатусРазмещения) Тогда
//			vIsCheckIn = ParentDoc.СтатусРазмещения.ЭтоЗаезд;
//			vIsCheckOut = ParentDoc.СтатусРазмещения.ЭтоВыезд;
//			vIsRoomChange = ParentDoc.СтатусРазмещения.ЗтоПереселение;
//			If ParentDoc.СтатусРазмещения.Действует And НЕ ParentDoc.СтатусРазмещения.ЭтоВыезд Тогда
//				vIsBeforeRoomChange = True;
//			EndIf;
//		EndIf;
//	EndIf;
//	vParentDocObj = Неопределено;
//	If ЗначениеЗаполнено(ParentDoc) Тогда
//		vParentDocObj = ParentDoc.GetObject();
//	EndIf;
//	vIsBasedOnReservation = False;
//	If ЗначениеЗаполнено(ParentDoc) Тогда
//		If TypeOf(ParentDoc) = Type("DocumentRef.Размещение") And ParentDoc.РазмПоБрони Тогда
//			If vIsCheckIn Тогда
//				vIsBasedOnReservation = True;
//			EndIf;
//		ElsIf TypeOf(ParentDoc) = Type("DocumentRef.Reservation") Тогда
//			vIsBasedOnReservation = True;
//		EndIf;
//	EndIf;
//	// Choose rows of the client type choosen
//	i = -1;
//	For Each vServicePackageRow In vPackageServices Do
//		i = i + 1;
//		// Check accommodation type
//		If ЗначениеЗаполнено(ParentDoc) Тогда
//			If TypeOf(ParentDoc) = Type("DocumentRef.Размещение") Or TypeOf(ParentDoc) = Type("DocumentRef.Reservation") Тогда
//				If ЗначениеЗаполнено(vServicePackageRow.ВидРазмещения) And 
//				   vServicePackageRow.ВидРазмещения <> ParentDoc.ВидРазмещения Тогда
//					Continue;
//				EndIf;
//			EndIf;
//		EndIf;
//		
//		// Services period
//		vDateTimeFrom = DateTimeFrom;
//		If НЕ ЗначениеЗаполнено(vDateTimeFrom) Тогда
//			vDateTimeFrom = BegOfDay(CurrentDate());
//		EndIf;
//		vDateTimeTo = DateTimeTo;
//		If НЕ ЗначениеЗаполнено(vDateTimeTo) Тогда
//			vDateTimeTo = EndOfDay(CurrentDate());
//		EndIf;
//		
//		// Get accounting date from the package service settings
//		vAccountingDatesList = New СписокЗначений();
//		If ЗначениеЗаполнено(pDate) Тогда
//			vAccountingDatesList.Add(pDate);
//		ElsIf ЗначениеЗаполнено(vServicePackageRow.УчетнаяДата) Тогда
//			vAccountingDatesList.Add(vServicePackageRow.УчетнаяДата);
//		ElsIf vServicePackageRow.AccountingDayNumber = 9999 Тогда
//			vAccountingDatesList.Add(BegOfDay(vDateTimeTo));
//		ElsIf vServicePackageRow.AccountingDayNumber <> 0 Тогда
//			vAccountingDatesList.Add(BegOfDay(vDateTimeFrom) + (vServicePackageRow.AccountingDayNumber - 1)*24*3600);
//		ElsIf ЗначениеЗаполнено(vServicePackageRow.QuantityCalculationRule) Тогда
//			vCurDate = BegOfDay(vDateTimeFrom);
//			While vCurDate <= BegOfDay(vDateTimeTo) Do
//				// Check calendar day type
//				If ЗначениеЗаполнено(vServicePackageRow.ТипДняКалендаря) Тогда
//					If ЗначениеЗаполнено(ParentDoc) Тогда
//						If TypeOf(ParentDoc) = Type("DocumentRef.Размещение") Or TypeOf(ParentDoc) = Type("DocumentRef.Reservation") Тогда
//							vRoomRate = ParentDoc.Тариф;
//							If ParentDoc.Тарифы.Count() > 0 Тогда
//								vRoomRatesRow = ParentDoc.Тарифы.Find(vCurDate, "УчетнаяДата");
//								If vRoomRatesRow <> Неопределено Тогда
//									If ЗначениеЗаполнено(vRoomRatesRow.Тариф) Тогда
//										vRoomRate = vRoomRatesRow.Тариф;
//									EndIf;
//								EndIf;
//							EndIf;
//							vCalendarDayType = cmGetCalendarDayType(vRoomRate, vCurDate, ParentDoc.CheckInDate, ParentDoc.CheckOutDate);
//							If vCalendarDayType <> vServicePackageRow.ТипДняКалендаря Тогда
//								// Go to the next date
//								vCurDate = vCurDate + 24*3600;
//								Continue;
//							EndIf;
//						ElsIf TypeOf(ParentDoc) = Type("DocumentRef.БроньУслуг") Тогда
//							vCalendarDayType = Справочники.ТипДневногоКалендаря.EmptyRef();
//							vCalendar = Справочники.Календари.EmptyRef();
//							If ЗначениеЗаполнено(ParentDoc.Ресурс) And ЗначениеЗаполнено(ParentDoc.Ресурс.Calendar) Тогда
//								vCalendar = ParentDoc.Ресурс.Calendar;
//							EndIf;
//							If ЗначениеЗаполнено(vCalendar) Тогда
//								vCalendarDays = vCalendar.GetObject().pmGetDays(vCurDate, vCurDate, vDateTimeFrom, vDateTimeTo);
//								If vCalendarDays.Count() > 0 Тогда
//									vCalendarDayType = vCalendarDays.Get(0).ТипДняКалендаря;
//								EndIf;
//							EndIf;
//							If vCalendarDayType <> vServicePackageRow.ТипДняКалендаря Тогда
//								// Go to the next date
//								vCurDate = vCurDate + 24*3600;
//								Continue;
//							EndIf;
//						EndIf;
//					EndIf;
//				EndIf;
//				// Fill parameters
//				vCurPrice = vServicePackageRow.Цена;
//				vCurCurrency = vServicePackageRow.Валюта;
//				vCurRemarks = "";
//				vIsDayUse = False;
//				vWrkDate = vCurDate;
//				// Calculate quantity
//				vCurQuantity = cmCalculateServiceQuantity(vServicePackageRow.Услуга, vServicePackageRow.QuantityCalculationRule, 
//														  vWrkDate, vDateTimeFrom, vDateTimeTo, 
//														  vParentDocObj, vParentDocObj, vIsCheckIn, vIsBasedOnReservation, 
//														  vIsBeforeRoomChange, vIsRoomChange, vIsCheckOut, False, 
//														  vCurPrice, vCurCurrency, vCurRemarks, vIsDayUse);
//				// Add current accounting date if quantity being calculated is not equal zero
//				If vCurQuantity <> 0 Тогда
//					vAccountingDatesList.Add(vWrkDate);
//				EndIf;
//				// Go to the next date
//				vCurDate = vCurDate + 24*3600;
//			EndDo;
//		ElsIf НЕ ЗначениеЗаполнено(vServicePackageRow.QuantityCalculationRule) And НЕ ЗначениеЗаполнено(vServicePackageRow.УчетнаяДата) And vServicePackageRow.AccountingDayNumber = 0 Тогда
//			// Add all days
//			vCurDate = BegOfDay(vDateTimeFrom);
//			While vCurDate <= BegOfDay(vDateTimeTo) Do
//				// Check calendar day type
//				If ЗначениеЗаполнено(vServicePackageRow.ТипДняКалендаря) Тогда
//					If ЗначениеЗаполнено(ParentDoc) Тогда
//						If TypeOf(ParentDoc) = Type("DocumentRef.Размещение") Or TypeOf(ParentDoc) = Type("DocumentRef.Reservation") Тогда
//							vRoomRate = ParentDoc.Тариф;
//							If ParentDoc.Тарифы.Count() > 0 Тогда
//								vRoomRatesRow = ParentDoc.Тарифы.Find(vCurDate, "УчетнаяДата");
//								If vRoomRatesRow <> Неопределено Тогда
//									If ЗначениеЗаполнено(vRoomRatesRow.Тариф) Тогда
//										vRoomRate = vRoomRatesRow.Тариф;
//									EndIf;
//								EndIf;
//							EndIf;
//							vCalendarDayType = cmGetCalendarDayType(vRoomRate, vCurDate, ParentDoc.CheckInDate, ParentDoc.CheckOutDate);
//							If vCalendarDayType <> vServicePackageRow.ТипДняКалендаря Тогда
//								// Go to the next date
//								vCurDate = vCurDate + 24*3600;
//								Continue;
//							EndIf;
//						ElsIf TypeOf(ParentDoc) = Type("DocumentRef.БроньУслуг") Тогда
//							vCalendarDayType = Справочники.ТипДневногоКалендаря.EmptyRef();
//							vCalendar = Справочники.Календари.EmptyRef();
//							If ЗначениеЗаполнено(ParentDoc.Ресурс) And ЗначениеЗаполнено(ParentDoc.Ресурс.Calendar) Тогда
//								vCalendar = ParentDoc.Ресурс.Calendar;
//							EndIf;
//							If ЗначениеЗаполнено(vCalendar) Тогда
//								vCalendarDays = vCalendar.GetObject().pmGetDays(vCurDate, vCurDate, vDateTimeFrom, vDateTimeTo);
//								If vCalendarDays.Count() > 0 Тогда
//									vCalendarDayType = vCalendarDays.Get(0).ТипДняКалендаря;
//								EndIf;
//							EndIf;
//							If vCalendarDayType <> vServicePackageRow.ТипДняКалендаря Тогда
//								// Go to the next date
//								vCurDate = vCurDate + 24*3600;
//								Continue;
//							EndIf;
//						EndIf;
//					EndIf;
//				EndIf;
//				// Add current accounting date
//				vAccountingDatesList.Add(vCurDate);
//				// Go to the next date
//				vCurDate = vCurDate + 24*3600;
//			EndDo;
//		EndIf;
//		
//		For Each vAccountingDatesItem In vAccountingDatesList Do
//			vAccountingDate = vAccountingDatesItem.Value;
//			
//			// Add charge
//			vChargeObj = Documents.Начисление.CreateDocument();
//			vChargeObj.Fill(Ref);
//			vChargeObj.Услуга = vServicePackageRow.Услуга;
//			vChargeObj.PaymentSection = vChargeObj.Услуга.PaymentSection;
//			vChargeObj.IsRoomRevenue = vChargeObj.Услуга.IsRoomRevenue;
//			vChargeObj.RoomRevenueAmountsOnly = vChargeObj.Услуга.RoomRevenueAmountsOnly;
//			vChargeObj.IsResourceRevenue = vChargeObj.Услуга.IsResourceRevenue;
//			vChargeObj.IsInPrice = vServicePackageRow.IsInPrice;
//			vChargeObj.IsManual = True;
//			vChargeObj.IsAdditional = True;
//			vChargeObj.Примечания = vServicePackageRow.Примечания;
//			vChargeObj.Фирма = Фирма;
//			If ЗначениеЗаполнено(pClientType) Тогда 
//				vChargeObj.ТипКлиента = pClientType;
//				If НЕ IsBlankString(pClientTypeConfirmationText) Тогда
//					vChargeObj.СтрокаПодтверждения = pClientTypeConfirmationText;
//				EndIf;
//			EndIf;
//			
//			// Fill accounting date
//			vChargeObj.ДатаДок = ?(ЗначениеЗаполнено(vAccountingDate), vAccountingDate, CurrentDate());
//			// Fill calendar day type
//			If (vChargeObj.IsManual Or vChargeObj.IsAdditional) And 
//			   ЗначениеЗаполнено(ParentDoc) And TypeOf(ParentDoc) <> Type("DocumentRef.БроньУслуг") And 
//			   ЗначениеЗаполнено(ParentDoc.Тариф) Тогда
//				vChargeObj.ТипДняКалендаря = cmGetCalendarDayType(ParentDoc.Тариф, vChargeObj.ДатаДок, ParentDoc.CheckInDate, ParentDoc.CheckOutDate);
//			EndIf;
//				
//			// Recalculate price
//			vChargeObj.Цена = Round(cmConvertCurrencies(vServicePackageRow.Цена, vServicePackageRow.Валюта, , 
//														 vChargeObj.ВалютаЛицСчета, 
//														 vChargeObj.FolioCurrencyExchangeRate, 
//														 vChargeObj.ExchangeRateDate, vChargeObj.Гостиница), 2);
//			vChargeObj.ЕдИзмерения = vServicePackageRow.ЕдИзмерения;
//			vChargeObj.СтавкаНДС = vServicePackageRow.СтавкаНДС;
//			If ЗначениеЗаполнено(ParentDoc) Тогда
//				vChargeObj.Количество = vServicePackageRow.Количество * ?(vServicePackageRow.IsServicePerPerson, ?(ParentDoc.КоличествоЧеловек = 0, 1, ParentDoc.КоличествоЧеловек), 1);
//			Else
//				vChargeObj.Количество = vServicePackageRow.Количество;
//			EndIf;
//			// Sum and VAT sum
//			cmPriceOnChange(vChargeObj.Цена, vChargeObj.Количество, vChargeObj.Сумма, vChargeObj.СтавкаНДС, vChargeObj.СуммаНДС);
//			// Set charge discounts
//			vChargeObj.pmSetDiscounts();
//			// ГруппаНомеров sales resources
//			If vChargeObj.IsRoomRevenue And НЕ vChargeObj.ЭтоРазделение Тогда
//				If ЗначениеЗаполнено(ParentDoc) And 
//				  (TypeOf(ParentDoc) = Type("DocumentRef.Reservation") Or TypeOf(ParentDoc) = Type("DocumentRef.Размещение")) Тогда
//					vCurPeriodInHours = 24;
//					If ЗначениеЗаполнено(vChargeObj.Услуга.QuantityCalculationRule) Тогда
//						If vChargeObj.Услуга.QuantityCalculationRule.PeriodInHours <> 0 Тогда
//							vCurPeriodInHours = vChargeObj.Услуга.QuantityCalculationRule.PeriodInHours;
//						EndIf;
//					ElsIf ЗначениеЗаполнено(vChargeObj.Тариф) And vChargeObj.Тариф.PeriodInHours <> 0 Тогда
//						vCurPeriodInHours = vChargeObj.Тариф.PeriodInHours;
//					EndIf;
//					If vCurPeriodInHours <> 0 Тогда
//						vChargeObj.ПроданоНомеров = ?(ParentDoc.КоличествоМестНомер = 0, 0, Round(ParentDoc.КоличествоМест/ParentDoc.КоличествоМестНомер*vChargeObj.Количество*vCurPeriodInHours/24, 7));
//						vChargeObj.ПроданоМест = Round(ParentDoc.КоличествоМест*vChargeObj.Количество*vCurPeriodInHours/24, 7);
//						vChargeObj.ПроданоДопМест = Round(ParentDoc.КолДопМест*vChargeObj.Количество*vCurPeriodInHours/24, 7);
//						vChargeObj.ЧеловекаДни = Round(ParentDoc.КоличествоЧеловек*vChargeObj.Количество*vCurPeriodInHours/24, 7);
//						If BegOfDay(ParentDoc.CheckInDate) = BegOfDay(vAccountingDate) Тогда
//							vChargeObj.ЗаездГостей = ParentDoc.КоличествоЧеловек;
//						EndIf;
//					EndIf;
//				EndIf;
//			EndIf;
//			// Discount
//			vChargeObj.СуммаСкидки = 0;
//			vChargeObj.НДСскидка = 0;
//			If vChargeObj.Скидка <> 0 And cmIsServiceInServiceGroup(vChargeObj.Услуга, vChargeObj.DiscountServiceGroup) Тогда
//				vChargeObj.СуммаСкидки = Round(vChargeObj.Сумма * vChargeObj.Скидка / 100, 2);
//				vChargeObj.НДСскидка = cmCalculateVATSum(vChargeObj.СтавкаНДС, vChargeObj.СуммаСкидки);
//			EndIf;
//			// Commission
//			vChargeObj.СуммаКомиссии = 0;
//			vChargeObj.СуммаКомиссииНДС = 0;
//			If cmIsServiceInServiceGroup(vChargeObj.Услуга, vChargeObj.КомиссияАгентУслуги) Тогда
//				If vChargeObj.ВидКомиссииАгента = Перечисления.AgentCommissionTypes.Percent Тогда
//					If vChargeObj.КомиссияАгента <> 0 Тогда
//						vChargeObj.СуммаКомиссии = Round((vChargeObj.Сумма - vChargeObj.СуммаСкидки) * vChargeObj.КомиссияАгента / 100, 2);
//						vChargeObj.СуммаКомиссииНДС = cmCalculateVATSum(vChargeObj.СтавкаНДС, vChargeObj.СуммаКомиссии);
//					EndIf;
//				ElsIf vChargeObj.ВидКомиссииАгента = Перечисления.AgentCommissionTypes.FirstDayPercent Тогда
//					If ЗначениеЗаполнено(vChargeObj.ДокОснование) Тогда
//						If (TypeOf(vChargeObj.ДокОснование) = Type("DocumentRef.Reservation") Or TypeOf(vChargeObj.ДокОснование) = Type("DocumentRef.Размещение")) And 
//						   BegOfDay(vChargeObj.ДокОснование.CheckInDate) = BegOfDay(vChargeObj.ДатаДок) Тогда
//							vChargeObj.СуммаКомиссии = Round((vChargeObj.Сумма - vChargeObj.СуммаСкидки) * vChargeObj.КомиссияАгента/100, 2);
//							vChargeObj.СуммаКомиссииНДС = cmCalculateVATSum(vChargeObj.СтавкаНДС, vChargeObj.СуммаКомиссии);
//						ElsIf TypeOf(vChargeObj.ДокОснование) = Type("DocumentRef.БроньУслуг") And BegOfDay(vChargeObj.ДокОснование.DateTimeFrom) = BegOfDay(vChargeObj.ДатаДок) Тогда
//							vChargeObj.СуммаКомиссии = Round((vChargeObj.Сумма - vChargeObj.СуммаСкидки) * vChargeObj.КомиссияАгента/100, 2);
//							vChargeObj.СуммаКомиссииНДС = cmCalculateVATSum(vChargeObj.СтавкаНДС, vChargeObj.СуммаКомиссии);
//						EndIf;
//					EndIf;
//				EndIf;
//			EndIf;
//			// Service performer
//			If pServicesPerformers <> Неопределено Тогда
//				vSPRow = pServicesPerformers.Get(i);
//				If vSPRow <> Неопределено Тогда
//					vChargeObj.Performer = vSPRow.Employee;
//				EndIf;
//			EndIf;
//			// Marketing code and source of business
//			If pMarketingCode <> Неопределено Тогда
//				vChargeObj.МаркетингКод = pMarketingCode;
//				vChargeObj.MarketingCodeConfirmationText = pMarketingCodeConfirmationText;
//			EndIf;
//			If pSourceOfBusiness <> Неопределено Тогда
//				vChargeObj.ИсточникИнфоГостиница = pSourceOfBusiness;
//			EndIf;
//			// Write current charge
//			WriteLogEvent("Документ.СозданиеНового", EventLogLevel.Information, vChargeObj.Metadata(), Documents.Начисление.EmptyRef(), "Создание нового'");
//			// Post charge object
//			vChargeObj.Write(DocumentWriteMode.Posting);
//		EndDo;
//	EndDo;
//КонецПроцедуры //pmChargeServicePackage
//
////-----------------------------------------------------------------------------
//Процедура BeforeWrite(pCancel, pWriteMode, pPostingMode)
//	Перем vMessage, vAttributeInErr;
//	If ThisObject.DataExchange.Load Тогда
//		Return;
//	EndIf;
//	If pWriteMode = DocumentWriteMode.Posting Тогда
//		pCancel	= pmCheckDocumentAttributes(vMessage, vAttributeInErr);
//		If pCancel Тогда
//			WriteLogEvent("Документ.КонтрольДанных", EventLogLevel.Warning, ThisObject.Metadata(), ThisObject.Ref, vMessage);
//			Message(vMessage, MessageStatus.Attention);
//			ВызватьИсключение vMessage;
//		EndIf;
//	EndIf;
//	// Fill author and date when folio was closed
//	If IsClosed Тогда
//		If НЕ ЗначениеЗаполнено(IsClosedDate) Тогда
//			IsClosedDate = CurrentDate();
//			IsClosedAuthor = ПараметрыСеанса.ТекПользователь;
//		EndIf;
//	Else
//		If ЗначениеЗаполнено(IsClosedDate) Тогда
//			IsClosedDate = '00010101';
//			IsClosedAuthor = Справочники.Сотрудники.EmptyRef();
//		EndIf;
//	EndIf;
//КонецПроцедуры //BeforeWrite
//
////-----------------------------------------------------------------------------
//Процедура OnSetNewNumber(pStandardProcessing, pPrefix)
//	If IsBlankString(Number) Тогда
//		vHotel = Гостиница;
//		If НЕ ЗначениеЗаполнено(vHotel) Тогда
//			vHotel = ПараметрыСеанса.ТекущаяГостиница;
//		EndIf;
//		If ЗначениеЗаполнено(vHotel) Тогда
//			If vHotel.UseFolioAccountingNumberPrefix Тогда
//				pPrefix = TrimAll(vHotel.GetObject().pmGetFolioProFormaNumberPrefix());
//			Else
//				vPrefix = TrimAll(vHotel.GetObject().pmGetPrefix());
//				If vPrefix <> "" Тогда
//					pPrefix = vPrefix;
//				EndIf;
//			EndIf;
//		EndIf;
//	EndIf;
//КонецПроцедуры //OnSetNewNumber
//
////-----------------------------------------------------------------------------
//Процедура Filling(pBase)
//	// Fill from the base
//	If ЗначениеЗаполнено(pBase) Тогда
//		If TypeOf(pBase) = Type("CatalogRef.ШаблоныОпераций") Тогда
//			// Fill attributes with default values
//			pmFillAttributesWithDefaultValues();
//			// Fill attributes based on object template
//			If ЗначениеЗаполнено(pBase.ТипСкидки) Тогда
//				FolioDiscountType = pBase.ТипСкидки;
//			EndIf;
//			If ЗначениеЗаполнено(pBase.Фирма) Тогда
//				Фирма = pBase.Фирма;
//			EndIf;
//			DoNotUpdateCompany = pBase.DoNotUpdateCompany;
//			If ЗначениеЗаполнено(pBase.ВалютаЛицСчета) Тогда
//				FolioCurrency = pBase.ВалютаЛицСчета;
//			EndIf;
//			If ЗначениеЗаполнено(pBase.Контрагент) Тогда
//				Контрагент = pBase.Контрагент;
//			EndIf;
//			If ЗначениеЗаполнено(pBase.Договор) Тогда
//				Contract = pBase.Договор;
//			EndIf;
//			If ЗначениеЗаполнено(pBase.Агент) Тогда
//				Agent = pBase.Агент;
//			EndIf;
//			If ЗначениеЗаполнено(pBase.ГруппаГостей) Тогда
//				GuestGroup = pBase.ГруппаГостей;
//			EndIf;
//			If ЗначениеЗаполнено(pBase.Клиент) Тогда
//				Client = pBase.Клиент;
//			EndIf;
//			If ЗначениеЗаполнено(pBase.PaymentSection) Тогда
//				PaymentSection = pBase.PaymentSection;
//			EndIf;
//			If ЗначениеЗаполнено(pBase.НомерРазмещения) Тогда
//				ГруппаНомеров = pBase.НомерРазмещения;
//			EndIf;
//			If ЗначениеЗаполнено(pBase.DateTimeFrom) Тогда
//				DateTimeFrom = pBase.DateTimeFrom;
//			EndIf;
//			If ЗначениеЗаполнено(pBase.DateTimeTo) Тогда
//				DateTimeTo = pBase.DateTimeTo;
//			EndIf;
//			If pBase.UseCurrentDateForTheFolioPeriod Тогда
//				DateTimeFrom = BegOfDay(CurrentDate());
//				DateTimeTo = EndOfDay(CurrentDate());
//			EndIf;
//			If ЗначениеЗаполнено(pBase.СпособОплаты) Тогда
//				PaymentMethod = pBase.СпособОплаты;
//			EndIf;
//			If pBase.CreditLimit <> 0 Тогда
//				CreditLimit = pBase.CreditLimit;
//			EndIf;
//			IsClosed = pBase.IsClosed;
//			IsMaster = pBase.IsMaster;
//			DoNotUpdateCompany = pBase.DoNotUpdateCompany;
//			// Fill folio description
//			Description = pBase.FolioDescription;
//		EndIf;
//	EndIf;
//КонецПроцедуры //Filling
//
////-----------------------------------------------------------------------------
//Процедура OnWrite(pCancel)
//	If ThisObject.DataExchange.Load Тогда
//		Return;
//	EndIf;
//	vCustomer = Контрагент;
//	vContract = Contract;
//	If ЗначениеЗаполнено(Гостиница) Тогда
//		vCustomer = ?(ЗначениеЗаполнено(Контрагент), Контрагент, Гостиница.IndividualsCustomer);
//		vContract = ?(ЗначениеЗаполнено(Contract), Contract, Гостиница.IndividualsContract);
//	EndIf;
//	// What to repost
//	vRepostCharges = False;
//	vRepostPayments = False;
//	// Check if there are settlements with currency different from current folio currency
//	vQry = New Query();
//	vQry.Text = "SELECT
//	            |	SettlementServices.СчетПроживания,
//	            |	SettlementServices.ВалютаЛицСчета
//	            |FROM
//	            |	Document.Акт.Услуги AS SettlementServices
//	            |WHERE
//	            |	SettlementServices.Ref.Posted
//	            |	AND SettlementServices.СчетПроживания = &qFolio
//	            |	AND SettlementServices.ВалютаЛицСчета <> &qFolioCurrency
//	            |
//	            |ORDER BY
//	            |	SettlementServices.Ref.PointInTime";
//	vQry.SetParameter("qFolio", Ref);
//	vQry.SetParameter("qFolioCurrency", FolioCurrency);
//	vQryRes = vQry.Execute().Unload();
//	For Each vQryRow In vQryRes Do
//		vErrText = "По фолио № " + TrimAll(Number) + " существуют акты в валюте " + TrimAll(vQryRow.FolioCurrency) + 
//						    ", которая отличается от новой валюты лицевого счета " + TrimAll(FolioCurrency) + 
//							". Пожалуйста удалите эти акты и, после изменения валюты лицевого счета, создайте новые акты.'";
//		ВызватьИсключение vErrText;
//	EndDo;
//	// Check if there are payments or preauthorisations with currency different from current folio currency
//	vQry = New Query();
//	vQry.Text = "SELECT
//	            |	Платежи.Recorder,
//	            |	Платежи.ВалютаЛицСчета
//	            |FROM
//	            |	AccumulationRegister.Взаиморасчеты AS Платежи
//	            |WHERE
//	            |	Платежи.СчетПроживания = &qFolio
//	            |	AND Платежи.ВалютаЛицСчета <> &qFolioCurrency
//	            |	AND (NOT Платежи.Recorder REFS Document.ЗакрытиеПериода)
//	            |	AND Платежи.RecordType = VALUE(AccumulationRecordType.Expense)
//	            |	AND Платежи.СпособОплаты <> &qSettlement
//	            |
//	            |ORDER BY
//	            |	Платежи.PointInTime";
//	vQry.SetParameter("qFolio", Ref);
//	vQry.SetParameter("qFolioCurrency", FolioCurrency);
//	vQry.SetParameter("qSettlement", Справочники.СпособОплаты.Акт);
//	vQryRes = vQry.Execute().Unload();
//	If vQryRes.Count() > 0 Тогда
//		vRepostPayments = True;
//	EndIf;
//	// Check if currency has changed for some charges
//	vQry = New Query();
//	vQry.Text = 
//	"SELECT
//	|	Взаиморасчеты.Recorder AS Recorder
//	|FROM
//	|	AccumulationRegister.Взаиморасчеты AS Взаиморасчеты
//	|WHERE
//	|	Взаиморасчеты.СчетПроживания = &qFolio
//	|	AND Взаиморасчеты.ВалютаЛицСчета <> &qFolioCurrency
//	|	AND Взаиморасчеты.RecordType = VALUE(AccumulationRecordType.Receipt)
//	|
//	|ORDER BY
//	|	Взаиморасчеты.PointInTime";
//	vQry.SetParameter("qFolio", Ref);
//	vQry.SetParameter("qFolioCurrency", FolioCurrency);
//	vQryRes = vQry.Execute().Unload();
//	If vQryRes.Count() > 0 Тогда
//		vRepostCharges = True;
//	EndIf;
//	// Check if there are payments with Контрагент/contract/guest group/Фирма different from current ones
//	// If there are payments with Фирма different from this folio Фирма then we have to cancel operation
//	// Otherwise we have to repost payments and fix Контрагент/contract/guest group parameters there
//	vQry = New Query();
//	vQry.Text = 
//	"SELECT
//	|	Взаиморасчеты.Recorder.Фирма AS Фирма,
//	|	Взаиморасчеты.Recorder.Контрагент AS Контрагент,
//	|	Взаиморасчеты.Recorder.Договор AS Договор,
//	|	Взаиморасчеты.Recorder.ГруппаГостей AS ГруппаГостей,
//	|	Взаиморасчеты.ВалютаЛицСчета AS ВалютаЛицСчета,
//	|	SUM(Взаиморасчеты.Сумма) AS SumExpense,
//	|	SUM(Взаиморасчеты.Limit) AS LimitExpense
//	|FROM
//	|	AccumulationRegister.Взаиморасчеты AS Взаиморасчеты
//	|WHERE
//	|	Взаиморасчеты.СчетПроживания = &qFolio 
//	|	AND NOT (Взаиморасчеты.Recorder REFS Document.ЗакрытиеПериода)
//	|	AND Взаиморасчеты.RecordType = VALUE(AccumulationRecordType.Expense)
//	|	AND Взаиморасчеты.СпособОплаты <> &qSettlement
//	|
//	|GROUP BY
//	|	Взаиморасчеты.Recorder.Фирма,
//	|	Взаиморасчеты.Recorder.Контрагент,
//	|	Взаиморасчеты.Recorder.Договор,
//	|	Взаиморасчеты.Recorder.ГруппаГостей,
//	|	Взаиморасчеты.ВалютаЛицСчета";
//	vQry.SetParameter("qFolio", Ref);
//	vQry.SetParameter("qSettlement", Справочники.СпособОплаты.Акт);
//	vQryRes = vQry.Execute().Unload();
//	For Each vQryRow In vQryRes Do
//		If vQryRow.Фирма <> Null And vQryRow.Фирма <> Фирма Тогда
//			If vQryRow.SumExpense <> 0 Or vQryRow.LimitExpense <> 0 Тогда
//				vErrText = "По фолио № " + TrimAll(Number) + " проведены платежи по фирме: " + Chars.LF +
//				                TrimAll(vQryRow.Фирма) + ", 
//						        |которая отличается от нового значения фирмы: " + Chars.LF + 
//							    TrimAll(Фирма) + " 
//							    |Перед изменением фирмы необходимо аннулировать существующие платежи или оформить по ним возвраты!";
//				ВызватьИсключение vErrText;
//			EndIf;
//		EndIf;
//		If vQryRow.Контрагент <> Null Тогда 
//			If ЗначениеЗаполнено(Гостиница) Тогда
//				vQryRow.Контрагент = ?(ЗначениеЗаполнено(vQryRow.Контрагент), vQryRow.Контрагент, Гостиница.IndividualsCustomer);
//				vQryRow.Contract = ?(ЗначениеЗаполнено(vQryRow.Contract), vQryRow.Contract, Гостиница.IndividualsContract);
//			EndIf;
//			If vQryRow.Контрагент <> vCustomer Or vQryRow.Contract <> vContract Or 
//			   vQryRow.GuestGroup <> GuestGroup Тогда
//				If vQryRow.SumExpense <> 0 Тогда
//					vRepostPayments = True;
//				EndIf;
//			EndIf;			
//		EndIf;
//	EndDo;
//	// Repost payments
//	If vRepostPayments Тогда
//		vQry = New Query();
//		vQry.Text = 
//		"SELECT
//		|	Взаиморасчеты.Recorder AS Recorder
//		|FROM
//		|	AccumulationRegister.Взаиморасчеты AS Взаиморасчеты
//		|WHERE
//		|	Взаиморасчеты.СчетПроживания = &qFolio
//		|	AND (NOT Взаиморасчеты.Recorder REFS Document.ЗакрытиеПериода)
//		|	AND Взаиморасчеты.RecordType = VALUE(AccumulationRecordType.Expense)
//		|
//		|ORDER BY
//		|	Взаиморасчеты.PointInTime";
//		vQry.SetParameter("qFolio", Ref);
//		vQryRes = vQry.Execute().Unload();
//		#IF CLIENT THEN
//			// Show progress bar
//			ProgressForm = GetCommonForm("Индикатор");
//			ProgressForm.Open();
//			ProgressForm.MaxValue = vQryRes.Count();
//			ProgressForm.Value = 0;
//			ProgressForm.ActionRemarks = "Изменение лицевого счета";
//			ProgressForm.Value = 0;
//			ProgressForm.ValueRemarks = "Перепроведение платежей...'";
//		#ENDIF
//		i = 1;
//		For Each vQryRow In vQryRes Do
//			If TypeOf(vQryRow.Recorder) = Type("DocumentRef.Платеж") Or TypeOf(vQryRow.Recorder) = Type("DocumentRef.Возврат") Тогда
//				vDocObj = vQryRow.Recorder.GetObject();
//				If vDocObj <> Неопределено Тогда
//					vDocObj.Контрагент = vCustomer;
//					vDocObj.Договор = vContract;
//					vDocObj.ГруппаГостей = GuestGroup;
//					If vDocObj.ВалютаЛицСчета <> FolioCurrency Тогда
//						vDocObj.ВалютаЛицСчета = FolioCurrency;
//						vDocObj.FolioCurrencyExchangeRate = cmGetCurrencyExchangeRate(vDocObj.Гостиница, vDocObj.ВалютаЛицСчета, vDocObj.ExchangeRateDate);
//	                	vDocObj.pmRecalculateSums();
//					EndIf;
//					vDocObj.Write(DocumentWriteMode.Posting);
//				EndIf;
//			ElsIf TypeOf(vQryRow.Recorder) = Type("DocumentRef.ПреАвторизация") Тогда
//				vDocObj = vQryRow.Recorder.GetObject();
//				If vDocObj <> Неопределено Тогда
//					vDocObj.ГруппаГостей = GuestGroup;
//					If vDocObj.ВалютаЛицСчета <> FolioCurrency Тогда
//						vDocObj.ВалютаЛицСчета = FolioCurrency;
//						vDocObj.FolioCurrencyExchangeRate = cmGetCurrencyExchangeRate(vDocObj.Гостиница, vDocObj.ВалютаЛицСчета, vDocObj.ExchangeRateDate);
//	                	vDocObj.pmRecalculateSums();
//					EndIf;
//					vDocObj.Write(DocumentWriteMode.Posting);
//				EndIf;
//			EndIf;
//			// Show progress status
//			#IF CLIENT THEN
//				ProgressForm.Value = i;
//			#ENDIF
//			i = i + 1;
//		EndDo;
//		// Close progress bar
//		#IF CLIENT THEN
//			ProgressForm.Value = 0;
//			If ProgressForm.IsOpen() Тогда
//				ProgressForm.Close();
//			EndIf;
//			ProgressForm = Неопределено;
//		#ENDIF
//	EndIf;
//	// We have to always repost deposit transfers
//	vQry = New Query();
//	vQry.Text = 
//	"SELECT DISTINCT
//	|	Взаиморасчеты.Recorder AS Recorder,
//	|	Взаиморасчеты.PointInTime AS PointInTime
//	|FROM
//	|	AccumulationRegister.Взаиморасчеты AS Взаиморасчеты
//	|WHERE
//	|	Взаиморасчеты.СчетПроживания = &qFolio
//	|	AND Взаиморасчеты.RecordType = VALUE(AccumulationRecordType.Expense)
//	|	AND Взаиморасчеты.Recorder REFS Document.ПеремещениеДепозита
//	|
//	|ORDER BY
//	|	PointInTime";
//	vQry.SetParameter("qFolio", Ref);
//	vQryRes = vQry.Execute().Unload();
//	i = 1;
//	For Each vQryRow In vQryRes Do
//		If TypeOf(vQryRow.Recorder) = Type("DocumentRef.ПеремещениеДепозита") Тогда
//			vDocObj = vQryRow.Recorder.GetObject();
//			If vDocObj <> Неопределено Тогда
//				vDocObj.Write(DocumentWriteMode.Posting);
//			EndIf;
//		EndIf;
//		i = i + 1;
//	EndDo;
//	// Check should we repost charges
//	If НЕ vRepostCharges Тогда
//		vQry = New Query();
//		vQry.Text = 
//		"SELECT
//		|	РелизацияТекОтчетПериод.Фирма AS Фирма,
//		|	РелизацияТекОтчетПериод.Контрагент AS Контрагент,
//		|	РелизацияТекОтчетПериод.Договор AS Договор,
//		|	РелизацияТекОтчетПериод.ГруппаГостей AS ГруппаГостей,
//		|	РелизацияТекОтчетПериод.SumReceipt AS SumReceipt
//		|FROM
//		|	AccumulationRegister.РелизацияТекОтчетПериод.Turnovers(
//		|			,
//		|			,
//		|			Period,
//		|			СчетПроживания = &qFolio) AS РелизацияТекОтчетПериод";
//		vQry.SetParameter("qFolio", Ref);
//		vQryRes = vQry.Execute().Unload();
//		For Each vQryRow In vQryRes Do
//			If ЗначениеЗаполнено(Гостиница) Тогда
//				vQryRow.Контрагент = ?(ЗначениеЗаполнено(vQryRow.Контрагент), vQryRow.Контрагент, Гостиница.IndividualsCustomer);
//				vQryRow.Contract = ?(ЗначениеЗаполнено(vQryRow.Contract), vQryRow.Contract, Гостиница.IndividualsContract);
//			EndIf;
//			If vQryRow.Фирма <> Фирма Or vQryRow.Контрагент <> vCustomer Or vQryRow.Contract <> vContract Or vQryRow.GuestGroup <> GuestGroup Тогда
//				vRepostCharges = True;
//				Break;
//			EndIf;
//		EndDo;
//	EndIf;
//	// Check if hotel product has changed for all charges
//	If ЗначениеЗаполнено(HotelProduct) Тогда
//		vQry = New Query();
//		vQry.Text = 
//		"SELECT
//		|	Взаиморасчеты.Recorder AS Recorder
//		|FROM
//		|	AccumulationRegister.Взаиморасчеты AS Взаиморасчеты
//		|WHERE
//		|	Взаиморасчеты.СчетПроживания = &qFolio
//		|	AND Взаиморасчеты.RecordType = VALUE(AccumulationRecordType.Receipt)
//		|	AND ISNULL(Взаиморасчеты.Начисление.ПутевкаКурсовка, &qEmptyHotelProduct) <> &qHotelProduct
//		|
//		|ORDER BY
//		|	Взаиморасчеты.PointInTime";
//		vQry.SetParameter("qFolio", Ref);
//		vQry.SetParameter("qHotelProduct", HotelProduct);
//		vQry.SetParameter("qEmptyHotelProduct", Справочники.ПутевкиКурсовки.EmptyRef());
//		vQryRes = vQry.Execute().Unload();
//		If vQryRes.Count() > 0 Тогда
//			vRepostCharges = True;
//		EndIf;
//	EndIf;
//	If vRepostCharges Тогда
//		vQry = New Query();
//		vQry.Text = 
//		"SELECT
//		|	Взаиморасчеты.Recorder AS Recorder
//		|FROM
//		|	AccumulationRegister.Взаиморасчеты AS Взаиморасчеты
//		|WHERE
//		|	Взаиморасчеты.СчетПроживания = &qFolio
//		|	AND Взаиморасчеты.RecordType = VALUE(AccumulationRecordType.Receipt)
//		|
//		|ORDER BY
//		|	Взаиморасчеты.PointInTime";
//		vQry.SetParameter("qFolio", Ref);
//		vQryRes = vQry.Execute().Unload();
//		#IF CLIENT THEN
//			// Show progress bar
//			ProgressForm = GetCommonForm("Индикатор");
//			ProgressForm.Open();
//			ProgressForm.MaxValue = vQryRes.Count();
//			ProgressForm.Value = 0;
//			ProgressForm.ActionRemarks = "Изменение лицевого счета";
//			ProgressForm.Value = 0;
//			ProgressForm.ValueRemarks = "Перепроведение начислений...'";
//		#ENDIF
//		i = 1;
//		For Each vQryRow In vQryRes Do
//			vDocObj = vQryRow.Recorder.GetObject();
//			If vDocObj <> Неопределено Тогда
//				If TypeOf(vQryRow.Recorder) = Type("DocumentRef.Начисление") Тогда
//					vDocObj.Фирма = Фирма;
//					If vDocObj.ВалютаЛицСчета <> FolioCurrency Тогда
//						If ЗначениеЗаполнено(FolioCurrency) And vDocObj.Количество <> 0 Тогда
//							vOldCurrency = vDocObj.ВалютаЛицСчета;
//							vOldCurrencyExchangeRate = vDocObj.FolioCurrencyExchangeRate;
//							vDocObj.ВалютаЛицСчета = FolioCurrency;
//							vDocObj.FolioCurrencyExchangeRate = cmGetCurrencyExchangeRate(vDocObj.Гостиница, vDocObj.ВалютаЛицСчета, vDocObj.ExchangeRateDate);
//							// Sum & Price
//							vDocObj.Сумма = cmConvertCurrencies(vDocObj.Сумма, vOldCurrency, vOldCurrencyExchangeRate, vDocObj.ВалютаЛицСчета, vDocObj.FolioCurrencyExchangeRate, vDocObj.ExchangeRateDate, vDocObj.Гостиница);
//							vDocObj.Цена = Round(vDocObj.Сумма/vDocObj.Количество, 2);
//							// VAT Sum
//							vDocObj.СуммаНДС = cmCalculateVATSum(vDocObj.СтавкаНДС, vDocObj.Сумма);
//							// Discount
//							vDocObj.СуммаСкидки = 0;
//							vDocObj.НДСскидка = 0;
//							If ЗначениеЗаполнено(vDocObj.Услуга) Тогда
//								If cmIsServiceInServiceGroup(vDocObj.Услуга, vDocObj.DiscountServiceGroup) Тогда
//									vDocObj.СуммаСкидки = Round(vDocObj.Сумма * vDocObj.Скидка / 100, 2);
//									vDocObj.НДСскидка = cmCalculateVATSum(vDocObj.СтавкаНДС, vDocObj.СуммаСкидки);
//								EndIf;
//							EndIf;
//							// Commission
//							vDocObj.СуммаКомиссии = 0;
//							vDocObj.СуммаКомиссииНДС = 0;
//							If ЗначениеЗаполнено(vDocObj.Услуга) Тогда
//								If cmIsServiceInServiceGroup(vDocObj.Услуга, vDocObj.КомиссияАгентУслуги) Тогда
//									If vDocObj.ВидКомиссииАгента = Перечисления.AgentCommissionTypes.Percent Тогда
//										vDocObj.СуммаКомиссии = Round((vDocObj.Сумма - vDocObj.СуммаСкидки) * vDocObj.КомиссияАгента/100, 2);
//										vDocObj.СуммаКомиссииНДС = cmCalculateVATSum(vDocObj.СтавкаНДС, vDocObj.СуммаКомиссии);
//									ElsIf vDocObj.ВидКомиссииАгента = Перечисления.AgentCommissionTypes.FirstDayPercent Тогда
//										If ЗначениеЗаполнено(vDocObj.ДокОснование) Тогда
//											If (TypeOf(vDocObj.ДокОснование) = Type("DocumentRef.Reservation") Or TypeOf(vDocObj.ДокОснование) = Type("DocumentRef.Размещение")) And 
//											   BegOfDay(vDocObj.ДокОснование.CheckInDate) = BegOfDay(vDocObj.ДатаДок) Тогда
//												vDocObj.СуммаКомиссии = Round((vDocObj.Сумма - vDocObj.СуммаСкидки) * vDocObj.КомиссияАгента/100, 2);
//												vDocObj.СуммаКомиссииНДС = cmCalculateVATSum(vDocObj.СтавкаНДС, vDocObj.СуммаКомиссии);
//											ElsIf TypeOf(vDocObj.ДокОснование) = Type("DocumentRef.БроньУслуг") And BegOfDay(vDocObj.ДокОснование.DateTimeFrom) = BegOfDay(vDocObj.ДатаДок) Тогда
//												vDocObj.СуммаКомиссии = Round((vDocObj.Сумма - vDocObj.СуммаСкидки) * vDocObj.КомиссияАгента/100, 2);
//												vDocObj.СуммаКомиссииНДС = cmCalculateVATSum(vDocObj.СтавкаНДС, vDocObj.СуммаКомиссии);
//											EndIf;
//										EndIf;
//									EndIf;
//								EndIf;
//							EndIf;
//						EndIf;
//					EndIf;
//					If ЗначениеЗаполнено(HotelProduct) And HotelProduct <> vDocObj.ПутевкаКурсовка Тогда
//						If ЗначениеЗаполнено(vDocObj.СтавкаНДС) And vDocObj.СтавкаНДС.БезНДС Тогда
//							vDocObj.ПутевкаКурсовка = HotelProduct;
//						EndIf;
//					EndIf;
//				EndIf;
//			EndIf;
//			vDocObj.Write(DocumentWriteMode.Posting);
//			// Show progress status
//			#IF CLIENT THEN
//				ProgressForm.Value = i;
//			#ENDIF
//			i = i + 1;
//		EndDo;
//		// Close progress bar
//		#IF CLIENT THEN
//			ProgressForm.Value = 0;
//			If ProgressForm.IsOpen() Тогда
//				ProgressForm.Close();
//			EndIf;
//			ProgressForm = Неопределено;
//		#ENDIF
//	EndIf;
//	// Check should we repost settlements or not 
//	If ЗначениеЗаполнено(PaymentMethod) And ЗначениеЗаполнено(Гостиница) And НЕ Гостиница.SwitchOffRepostingOfSettlements Тогда
//		If PaymentMethod.IsByBankTransfer Тогда
//			// If there are no account movements but there are settlements for this folio 
//			// then try to repost those settlements
//			vQry = New Query();
//			vQry.Text = 
//			"SELECT
//			|	Settlements.Акт AS Акт,
//			|	Settlements.Акт.PointInTime AS PointInTime
//			|FROM
//			|	(SELECT
//			|		SettlementServices.Ref AS Акт,
//			|		Взаиморасчеты.Recorder AS Recorder
//			|	FROM
//			|		Document.Акт.Услуги AS SettlementServices
//			|			LEFT JOIN AccumulationRegister.Взаиморасчеты AS Взаиморасчеты
//			|			ON SettlementServices.Ref = Взаиморасчеты.Recorder
//			|	WHERE
//			|		SettlementServices.СчетПроживания = &qFolio
//			|		AND SettlementServices.Ref.Posted
//			|		AND SettlementServices.Сумма <> 0
//			|		AND Взаиморасчеты.Recorder IS NULL ) AS Settlements
//			|
//			|GROUP BY
//			|	Settlements.Акт,
//			|	Settlements.Акт.PointInTime
//			|
//			|ORDER BY
//			|	PointInTime";
//			vQry.SetParameter("qFolio", Ref);
//			vSettlements = vQry.Execute().Unload();
//			For Each vSettlementsRow In vSettlements Do
//				vSettlementObj = vSettlementsRow.Settlement.GetObject();
//				If vSettlementObj <> Неопределено Тогда
//					vSettlementObj.pmPostToAccountsAndPayments();
//				EndIf;
//			EndDo;
//		Else
//			// If there are any account movements made by settlements
//			// then we have to repost those settlements
//			vQry = New Query();
//			vQry.Text = 
//			"SELECT
//			|	Взаиморасчеты.Recorder AS Акт,
//			|	Взаиморасчеты.Recorder.PointInTime AS PointInTime
//			|FROM
//			|	AccumulationRegister.Взаиморасчеты AS Взаиморасчеты
//			|WHERE
//			|	Взаиморасчеты.СчетПроживания = &qFolio
//			|	AND Взаиморасчеты.СпособОплаты = &qSettlement
//			|	AND Взаиморасчеты.RecordType = &qExpense
//			|
//			|GROUP BY
//			|	Взаиморасчеты.Recorder,
//			|	Взаиморасчеты.Recorder.PointInTime
//			|
//			|ORDER BY
//			|	PointInTime";
//			vQry.SetParameter("qFolio", Ref);
//			vQry.SetParameter("qSettlement", Справочники.СпособОплаты.Акт);
//			vQry.SetParameter("qExpense", AccumulationRecordType.Expense);
//			vSettlements = vQry.Execute().Unload();
//			For Each vSettlementsRow In vSettlements Do
//				vSettlementObj = vSettlementsRow.Settlement.GetObject();
//				If vSettlementObj <> Неопределено Тогда
//					vSettlementObj.pmPostToAccountsAndPayments();
//				EndIf;
//			EndDo;
//		EndIf;
//	EndIf;
//	// Update attributes of the client identification cards
//	vClearCardsData = False;
//	If ЗначениеЗаполнено(Гостиница) Тогда
//		vClearCardsData = Гостиница.ClearClientIdentificationCardDataOnGuestsCheckOut;
//	EndIf;
//	vCards = cmGetClientIdentificationCardsByFolio(Ref);
//	For Each vCardsRow In vCards Do
//		vCardRef = vCardsRow.Ref;
//		vCardObj = vCardRef.GetObject();
//		If vCardObj <> Неопределено Тогда
//			If (IsClosed And НЕ vCardRef.IsCheckedOut) Or
//			   (НЕ IsClosed And vCardRef.IsCheckedOut) Тогда
//				vCardObj.IsCheckedOut = IsClosed;
//			ElsIf DeletionMark And НЕ vCardRef.IsCheckedOut Тогда
//				vCardObj.IsCheckedOut = True;
//			EndIf;
//			If НЕ vClearCardsData Or НЕ IsClosed Тогда
//				vCardObj.ГруппаГостей = GuestGroup;
//				If ЗначениеЗаполнено(vCardObj.ДокОснование) Тогда
//					If TypeOf(vCardObj.ДокОснование) = Type("DocumentRef.Размещение") Or TypeOf(vCardObj.ДокОснование) = Type("DocumentRef.Reservation") Тогда
//						vCardObj.Клиент = vCardObj.ДокОснование.Клиент;
//					ElsIf TypeOf(ParentDoc) = Type("DocumentRef.БроньУслуг") Тогда
//						vCardObj.Клиент = vCardObj.ДокОснование.Клиент;
//					ElsIf TypeOf(ParentDoc) = Type("DocumentRef.СчетПроживания") Тогда
//						vCardObj.Клиент = vCardObj.ДокОснование.Клиент;
//					EndIf;
//				Else
//					vCardObj.Клиент = Client;
//				EndIf;
//				If ЗначениеЗаполнено(vCardObj.Клиент) Тогда
//					vCardObj.Description = TrimAll(vCardObj.Клиент.FullName);
//				Else
//					vCardObj.Description = "";
//				EndIf;
//				vCardObj.Гостиница = Гостиница;
//				vCardObj.НомерРазмещения = ГруппаНомеров;
//				vCardObj.DateTimeFrom = DateTimeFrom;
//				vCardObj.DateTimeTo = DateTimeTo;
//				vCardObj.Write();
//			Else
//				vCardObj.ГруппаГостей = Справочники.ГруппыГостей.EmptyRef();
//				vCardObj.СчетПроживания = Documents.СчетПроживания.EmptyRef();
//				vCardObj.ДокОснование = Неопределено;
//				vCardObj.Клиент = Справочники.Клиенты.EmptyRef();
//				vCardObj.Description = "";
//				vCardObj.Гостиница = Гостиница;
//				vCardObj.НомерРазмещения = Справочники.НомернойФонд.EmptyRef();
//				vCardObj.DateTimeFrom = '00010101';
//				vCardObj.DateTimeTo = '00010101';
//				vCardObj.IsBlocked = False;
//				vCardObj.BlockReason = "";
//				vCardObj.Write();
//			EndIf;
//		EndIf;
//	EndDo;
//	// Fill hotel product payment date
//	If ЗначениеЗаполнено(HotelProduct) Тогда
//		If НЕ ЗначениеЗаполнено(HotelProduct.PaymentDate) Тогда
//			vHPObj = HotelProduct.GetObject();
//			If vHPObj <> Неопределено Тогда
//				vPaymentMethod = Неопределено;
//				vHPObj.PaymentDate = vHPObj.pmGetHotelProductPaymentDate(vPaymentMethod);
//				If ЗначениеЗаполнено(vPaymentMethod) Тогда
//					vHPObj.СпособОплаты = vPaymentMethod;
//				EndIf;
//				If ЗначениеЗаполнено(vHPObj.PaymentDate) Тогда
//					vHPObj.Write();
//				EndIf;
//			EndIf;
//		EndIf;
//	EndIf;
//	// Block used gift certificates
//	If IsClosed And ЗначениеЗаполнено(IsClosedDate) And ЗначениеЗаполнено(IsClosedAuthor) And ЗначениеЗаполнено(Гостиница) Тогда
//		vGiftCertificatesArePerHotel = Constants.GiftCertificatesArePerHotel.Get();
//		vBlockUsedGiftCertificates = 0;
//		If vBlockUsedGiftCertificates Тогда
//			vFolioCertificates = pmGetFolioCertificates();
//			For Each vFolioCertificatesRow In vFolioCertificates Do
//				If НЕ IsBlankString(vFolioCertificatesRow.GiftCertificate) Тогда
//					vBlockedCertificatesRM = InformationRegisters.ПодарочСертификатСведения.CreateRecordManager();
//					vBlockedCertificatesRM.Period = vFolioCertificatesRow.Period;
//					vBlockedCertificatesRM.Гостиница = ?(vGiftCertificatesArePerHotel, Гостиница, Справочники.Гостиницы.EmptyRef());
//					vBlockedCertificatesRM.GiftCertificate = TrimAll(vFolioCertificatesRow.GiftCertificate);
//					vBlockedCertificatesRM.Read();
//					If vBlockedCertificatesRM.Selected() Тогда
//						vBlockedCertificatesRM.BlockDate = BegOfDay(IsClosedDate);
//						vBlockedCertificatesRM.BlockAuthor = IsClosedAuthor;
//						vBlockedCertificatesRM.BlockReason = "en='ЛицевойСчет was closed on " + Format(vBlockedCertificatesRM.BlockDate, "DF=dd.MM.yyyy") + "!'; 
//						                                     |ru='Лицевой счет закрыт " + Format(vBlockedCertificatesRM.BlockDate, "DF=dd.MM.yyyy") + "!';
//															 |de='ЛицевойСчет wurde am " + Format(vBlockedCertificatesRM.BlockDate, "DF=dd.MM.yyyy") + " geschlossen!'";
//						vBlockedCertificatesRM.Write(True);
//					EndIf;
//				EndIf;
//			EndDo;
//		EndIf;
//	EndIf;
//КонецПроцедуры //OnWrite
//
////-----------------------------------------------------------------------------
//Function pmGetFolioCertificates() Экспорт
//	vQry = New Query();
//	vQry.Text = 
//	"SELECT
//	|	Платеж.ДатаДок AS Period,
//	|	Платеж.GiftCertificate AS GiftCertificate
//	|FROM
//	|	Document.Платеж AS Платеж
//	|WHERE
//	|	Платеж.Posted
//	|	AND Платеж.СчетПроживания = &qFolio
//	|	AND Платеж.СпособОплаты.IsByGiftCertificate
//	|	AND Платеж.GiftCertificate <> &qEmptyString
//	|
//	|GROUP BY
//	|	Платеж.ДатаДок,
//	|	Платеж.GiftCertificate
//	|
//	|ORDER BY
//	|	Period,
//	|	GiftCertificate";
//	vQry.SetParameter("qFolio", Ref);
//	vQry.SetParameter("qEmptyString", "");
//	Return vQry.Execute().Unload();
//EndFunction //pmGetFolioCertificates
//
////-----------------------------------------------------------------------------
//Function pmGetFolioCertificateCharges() Экспорт
//	vQry = New Query();
//	vQry.Text = 
//	"SELECT
//	|	Начисление.GiftCertificate AS GiftCertificate
//	|FROM
//	|	Document.Начисление AS Начисление
//	|WHERE
//	|	Начисление.Posted
//	|	AND Начисление.СчетПроживания = &qFolio
//	|	AND Начисление.Услуга.IsGiftCertificate
//	|	AND Начисление.GiftCertificate <> &qEmptyString
//	|
//	|GROUP BY
//	|	Начисление.GiftCertificate
//	|
//	|ORDER BY
//	|	GiftCertificate";
//	vQry.SetParameter("qFolio", Ref);
//	vQry.SetParameter("qEmptyString", "");
//	Return vQry.Execute().Unload();
//EndFunction //pmGetFolioCertificateCharges
//
////-----------------------------------------------------------------------------
//Процедура pmRepostAdditionalCharges(pSkipDocRef = Неопределено) Экспорт
//	vQry = New Query();
//	vQry.Text = 
//	"SELECT
//	|	Взаиморасчеты.Recorder AS Recorder
//	|FROM
//	|	AccumulationRegister.Взаиморасчеты AS Взаиморасчеты
//	|WHERE
//	|	Взаиморасчеты.СчетПроживания = &qFolio
//	|	AND Взаиморасчеты.Period > ENDOFPERIOD(Взаиморасчеты.СчетПроживания.Гостиница.EditProhibitedDate, DAY)
//	|	AND Взаиморасчеты.RecordType = VALUE(AccumulationRecordType.Receipt)
//	|	AND ISNULL(Взаиморасчеты.Начисление.IsAdditional, FALSE)
//	|	AND Взаиморасчеты.Recorder <> &qSkipDocRef
//	|
//	|ORDER BY
//	|	Взаиморасчеты.PointInTime";
//	vQry.SetParameter("qFolio", Ref);
//	vQry.SetParameter("qSkipDocRef", pSkipDocRef);
//	vQryRes = vQry.Execute().Unload();
//	#IF CLIENT THEN
//		// Show progress bar
//		ProgressForm = GetCommonForm("Индикатор");
//		ProgressForm.Open();
//		ProgressForm.MaxValue = vQryRes.Count();
//		ProgressForm.Value = 0;
//		ProgressForm.ActionRemarks = "Изменение лицевого счета";
//		ProgressForm.Value = 0;
//		ProgressForm.ValueRemarks = "Перепроведение начислений...";
//	#ENDIF
//	i = 1;
//	For Each vQryRow In vQryRes Do
//		vDocObj = vQryRow.Recorder.GetObject();
//		vDocObj.Write(DocumentWriteMode.Posting);
//		// Show progress status
//		#IF CLIENT THEN
//			ProgressForm.Value = i;
//		#ENDIF
//		i = i + 1;
//	EndDo;
//	// Close progress bar
//	#IF CLIENT THEN
//		ProgressForm.Value = 0;
//		If ProgressForm.IsOpen() Тогда
//			ProgressForm.Close();
//		EndIf;
//		ProgressForm = Неопределено;
//	#ENDIF
//КонецПроцедуры //pmRepostAdditionalCharges
