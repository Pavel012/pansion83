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
//		PeriodFrom = AddMonth(BegOfMonth(CurrentDate()), -1);
//	EndIf;
//	If НЕ ЗначениеЗаполнено(PeriodTo) Тогда
//		PeriodTo = AddMonth(EndOfMonth(CurrentDate()), -1);
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
//	If ЗначениеЗаполнено(Service) Тогда
//		If НЕ Service.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("en='Service ';ru='Услуга ';de='Dienstleistung'") + 
//			                     TrimAll(Service.Description) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("ru = 'Группа услуг '; en = 'Services folder '") + 
//			                     TrimAll(Service.Description) + 
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
//	// Fill report parameters
//	ReportBuilder.Parameters.Вставить("qPeriodFrom", PeriodFrom);
//	ReportBuilder.Parameters.Вставить("qPeriodTo", PeriodTo);
//	ReportBuilder.Parameters.Вставить("qPeriodIsEmpty", НЕ ЗначениеЗаполнено(PeriodTo));
//	ReportBuilder.Parameters.Вставить("qService", Service);
//	ReportBuilder.Parameters.Вставить("qServiceIsEmpty", НЕ ЗначениеЗаполнено(Service));
//	ReportBuilder.Parameters.Вставить("qHotel", Гостиница);
//	ReportBuilder.Parameters.Вставить("qHotelIsEmpty", НЕ ЗначениеЗаполнено(Гостиница));
//	ReportBuilder.Parameters.Вставить("qEmptyHotel", Справочники.Гостиницы.EmptyRef());
//	ReportBuilder.Parameters.Вставить("qEmptyDate", '00010101');
//	ReportBuilder.Parameters.Вставить("qEmptyString", "");
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
//	
//	// Add chart 
//	If pAddChart Тогда
//		cmAddReportChart(pSpreadsheet, ThisObject);
//	EndIf;
//КонецПроцедуры //pmGenerate
//	
////-----------------------------------------------------------------------------
//Процедура pmInitializeReportBuilder() Экспорт
//	ReportBuilder = New ReportBuilder();
//	
//	// Initialize default query text
//	QueryText = 
//	"SELECT
//	|	ПодарочСертификат.GiftCertificate AS GiftCertificate,
//	|	ПодарочСертификат.Гостиница,
//	|	ПодарочСертификат.AmountOpeningBalance AS AmountOpeningBalance,
//	|	ПодарочСертификат.AmountReceipt AS PayedAmount,
//	|	ПодарочСертификат.AmountExpense AS WriteOffAmount,
//	|	ПодарочСертификат.AmountClosingBalance AS AmountClosingBalance,
//	|	1 AS Количество
//	|INTO ActiveGiftCertificates
//	|FROM
//	|	AccumulationRegister.ПодарочСертификат.BalanceAndTurnovers(
//	|			&qPeriodFrom,
//	|			&qPeriodTo,
//	|			PERIOD,
//	|			RegisterRecordsAndPeriodBoundaries,
//	|			&qHotelIsEmpty
//	|				OR NOT &qHotelIsEmpty
//	|					AND (Гостиница IN HIERARCHY (&qHotel)
//	|						OR Гостиница = &qEmptyHotel)) AS ПодарочСертификат
//	|;
//	|
//	|////////////////////////////////////////////////////////////////////////////////
//	|SELECT
//	|	BlockedGiftCertificatesSliceLast.GiftCertificate,
//	|	BlockedGiftCertificatesSliceLast.BlockReason,
//	|	BlockedGiftCertificatesSliceLast.BlockDate,
//	|	BlockedGiftCertificatesSliceLast.BlockAuthor,
//	|	BlockedGiftCertificatesSliceLast.Period
//	|INTO BlockedGiftCertificates
//	|FROM
//	|	InformationRegister.GiftCertificates.SliceLast(
//	|			&qPeriodTo,
//	|			&qHotelIsEmpty
//	|				OR NOT &qHotelIsEmpty
//	|					AND (Гостиница IN HIERARCHY (&qHotel)
//	|						OR Гостиница = &qEmptyHotel)) AS BlockedGiftCertificatesSliceLast
//	|WHERE
//	|	BlockedGiftCertificatesSliceLast.BlockDate <> &qEmptyDate
//	|	AND (&qPeriodIsEmpty
//	|			OR NOT &qPeriodIsEmpty
//	|				AND BlockedGiftCertificatesSliceLast.BlockDate < BEGINOFPERIOD(&qPeriodTo, DAY))
//	|;
//	|
//	|////////////////////////////////////////////////////////////////////////////////
//	|SELECT
//	|	ActiveGiftCertificates.GiftCertificate AS GiftCertificate,
//	|	ActiveGiftCertificates.Гостиница,
//	|	GiftCertificateCharges.Услуга AS Услуга,
//	|	GiftCertificateCharges.NominalAmount AS NominalAmount,
//	|	GiftCertificatePayments.Клиент AS Клиент,
//	|	GiftCertificatePayments.Контрагент AS Контрагент,
//	|	GiftCertificatePayments.Договор AS Договор,
//	|	GiftCertificatePayments.ГруппаГостей AS ГруппаГостей,
//	|	GiftCertificatePayments.ПериодС AS ПериодС,
//	|	GiftCertificatePayments.ПериодПо AS ПериодПо,
//	|	GiftCertificatePayments.НомерРазмещения AS НомерРазмещения,
//	|	GiftCertificatePayments.ТипНомера AS ТипНомера,
//	|	GiftCertificatePayments.Фирма AS Фирма,
//	|	GiftCertificatePayments.ДокОснование AS ДокОснование,
//	|	GiftCertificatePayments.Автор AS Автор,
//	|	GiftCertificatePayments.RegistrationDate AS RegistrationDate,
//	|	ActiveGiftCertificates.AmountOpeningBalance AS AmountOpeningBalance,
//	|	ActiveGiftCertificates.PayedAmount AS PayedAmount,
//	|	ActiveGiftCertificates.WriteOffAmount AS WriteOffAmount,
//	|	ActiveGiftCertificates.AmountClosingBalance AS AmountClosingBalance,
//	|	ActiveGiftCertificates.Количество AS Количество
//	|{SELECT
//	|	GiftCertificate,
//	|	Гостиница.*,
//	|	Услуга.*,
//	|	Клиент.*,
//	|	Контрагент.*,
//	|	Договор.*,
//	|	ГруппаГостей.*,
//	|	ПериодС,
//	|	ПериодПо,
//	|	НомерРазмещения.*,
//	|	ТипНомера.*,
//	|	Фирма.*,
//	|	Автор.*,
//	|	RegistrationDate,
//	|	ДокОснование.*,
//	|	(CASE
//	|			WHEN BlockedGiftCertificates.BlockDate IS NULL 
//	|				THEN FALSE
//	|			ELSE TRUE
//	|		END) AS IsBlocked,
//	|	BlockedGiftCertificates.BlockReason AS BlockReason,
//	|	BlockedGiftCertificates.BlockDate AS BlockDate,
//	|	BlockedGiftCertificates.BlockAuthor.* AS BlockAuthor,
//	|	NominalAmount,
//	|	AmountOpeningBalance,
//	|	PayedAmount,
//	|	WriteOffAmount,
//	|	AmountClosingBalance,
//	|	Quantity}
//	|FROM
//	|	ActiveGiftCertificates AS ActiveGiftCertificates
//	|		LEFT JOIN (SELECT
//	|			Начисление.GiftCertificate AS GiftCertificate,
//	|			Начисление.Услуга AS Услуга,
//	|			Начисление.Сумма - Начисление.СуммаСкидки AS NominalAmount
//	|		FROM
//	|			Document.Начисление AS Начисление
//	|		WHERE
//	|			Начисление.Posted
//	|			AND Начисление.GiftCertificate <> &qEmptyString
//	|			AND (&qHotelIsEmpty
//	|					OR NOT &qHotelIsEmpty
//	|						AND Начисление.Гостиница IN HIERARCHY (&qHotel))
//	|			AND Начисление.Услуга.IsGiftCertificate) AS GiftCertificateCharges
//	|		ON ActiveGiftCertificates.GiftCertificate = GiftCertificateCharges.GiftCertificate
//	|		LEFT JOIN (SELECT
//	|			Платежи.GiftCertificate AS GiftCertificate,
//	|			Платежи.Автор AS Автор,
//	|			MIN(Платежи.ДатаДок) AS RegistrationDate,
//	|			Платежи.Клиент AS Клиент,
//	|			Платежи.Контрагент AS Контрагент,
//	|			Платежи.Договор AS Договор,
//	|			Платежи.ГруппаГостей AS ГруппаГостей,
//	|			Платежи.ПериодС AS ПериодС,
//	|			Платежи.ПериодПо AS ПериодПо,
//	|			Платежи.Гостиница AS Гостиница,
//	|			Платежи.НомерРазмещения AS НомерРазмещения,
//	|			Платежи.ТипНомера AS ТипНомера,
//	|			Платежи.Фирма AS Фирма,
//	|			Платежи.ДокОснование AS ДокОснование
//	|		FROM
//	|			(SELECT
//	|				Платеж.GiftCertificate AS GiftCertificate,
//	|				Платеж.Автор AS Автор,
//	|				Платеж.ДатаДок AS Date,
//	|				Платеж.СчетПроживания.Клиент AS Клиент,
//	|				Платеж.СчетПроживания.Контрагент AS Контрагент,
//	|				Платеж.СчетПроживания.Договор AS Договор,
//	|				Платеж.СчетПроживания.ГруппаГостей AS ГруппаГостей,
//	|				Платеж.СчетПроживания.DateTimeFrom AS ПериодС,
//	|				Платеж.СчетПроживания.DateTimeTo AS ПериодПо,
//	|				Платеж.СчетПроживания.Гостиница AS Гостиница,
//	|				Платеж.СчетПроживания.НомерРазмещения AS НомерРазмещения,
//	|				Платеж.СчетПроживания.НомерРазмещения.ТипНомера AS ТипНомера,
//	|				Платеж.СчетПроживания.Фирма AS Фирма,
//	|				Платеж.СчетПроживания.ДокОснование AS ДокОснование
//	|			FROM
//	|				Document.Платеж AS Платеж
//	|			WHERE
//	|				Платеж.Posted
//	|				AND Платеж.GiftCertificate <> &qEmptyString
//	|				AND (&qHotelIsEmpty
//	|						OR NOT &qHotelIsEmpty
//	|							AND Платеж.Гостиница IN HIERARCHY (&qHotel))
//	|				AND NOT Платеж.СпособОплаты.IsByGiftCertificate
//	|			
//	|			UNION ALL
//	|			
//	|			SELECT
//	|				Return.GiftCertificate,
//	|				Return.Автор,
//	|				Return.ДатаДок,
//	|				Return.СчетПроживания.Клиент,
//	|				Return.СчетПроживания.Контрагент,
//	|				Return.СчетПроживания.Договор,
//	|				Return.СчетПроживания.ГруппаГостей,
//	|				Return.СчетПроживания.DateTimeFrom,
//	|				Return.СчетПроживания.DateTimeTo,
//	|				Return.СчетПроживания.Гостиница,
//	|				Return.СчетПроживания.НомерРазмещения,
//	|				Return.СчетПроживания.НомерРазмещения.ТипНомера,
//	|				Return.СчетПроживания.Фирма,
//	|				Return.СчетПроживания.ДокОснование
//	|			FROM
//	|				Document.Возврат AS Return
//	|			WHERE
//	|				Return.Posted
//	|				AND Return.GiftCertificate <> &qEmptyString
//	|				AND (&qHotelIsEmpty
//	|						OR NOT &qHotelIsEmpty
//	|							AND Return.Гостиница IN HIERARCHY (&qHotel))
//	|				AND NOT Return.СпособОплаты.IsByGiftCertificate) AS Платежи
//	|		
//	|		GROUP BY
//	|			Платежи.GiftCertificate,
//	|			Платежи.Автор,
//	|			Платежи.Клиент,
//	|			Платежи.Контрагент,
//	|			Платежи.Договор,
//	|			Платежи.ГруппаГостей,
//	|			Платежи.ПериодС,
//	|			Платежи.ПериодПо,
//	|			Платежи.Гостиница,
//	|			Платежи.НомерРазмещения,
//	|			Платежи.ТипНомера,
//	|			Платежи.Фирма,
//	|			Платежи.ДокОснование) AS GiftCertificatePayments
//	|		ON ActiveGiftCertificates.GiftCertificate = GiftCertificatePayments.GiftCertificate
//	|		LEFT JOIN BlockedGiftCertificates AS BlockedGiftCertificates
//	|		ON ActiveGiftCertificates.GiftCertificate = BlockedGiftCertificates.GiftCertificate
//	|WHERE
//	|	(&qServiceIsEmpty
//	|			OR NOT &qServiceIsEmpty
//	|				AND GiftCertificateCharges.Услуга IN HIERARCHY (&qService))
//	|{WHERE
//	|	ActiveGiftCertificates.GiftCertificate AS GiftCertificate,
//	|	ActiveGiftCertificates.Гостиница.* AS Гостиница,
//	|	GiftCertificateCharges.Услуга.* AS Услуга,
//	|	GiftCertificateCharges.NominalAmount AS NominalAmount,
//	|	GiftCertificatePayments.Клиент.* AS Клиент,
//	|	GiftCertificatePayments.Контрагент.* AS Контрагент,
//	|	GiftCertificatePayments.Договор.* AS Договор,
//	|	GiftCertificatePayments.ГруппаГостей.* AS ГруппаГостей,
//	|	GiftCertificatePayments.ПериодС AS ПериодС,
//	|	GiftCertificatePayments.ПериодПо AS ПериодПо,
//	|	GiftCertificatePayments.НомерРазмещения.* AS НомерРазмещения,
//	|	GiftCertificatePayments.ТипНомера.* AS ТипНомера,
//	|	GiftCertificatePayments.Фирма.* AS Фирма,
//	|	GiftCertificatePayments.ДокОснование.* AS ДокОснование,
//	|	GiftCertificatePayments.Автор.* AS Автор,
//	|	GiftCertificatePayments.RegistrationDate AS RegistrationDate,
//	|	(CASE
//	|			WHEN BlockedGiftCertificates.BlockDate IS NULL 
//	|				THEN FALSE
//	|			ELSE TRUE
//	|		END) AS IsBlocked,
//	|	BlockedGiftCertificates.BlockReason AS BlockReason,
//	|	BlockedGiftCertificates.BlockDate AS BlockDate,
//	|	BlockedGiftCertificates.BlockAuthor.* AS BlockAuthor,
//	|	ActiveGiftCertificates.AmountOpeningBalance AS AmountOpeningBalance,
//	|	ActiveGiftCertificates.PayedAmount AS PayedAmount,
//	|	ActiveGiftCertificates.WriteOffAmount AS WriteOffAmount,
//	|	ActiveGiftCertificates.AmountClosingBalance AS AmountClosingBalance}
//	|
//	|ORDER BY
//	|	GiftCertificate
//	|{ORDER BY
//	|	GiftCertificate,
//	|	Гостиница.*,
//	|	Услуга.*,
//	|	Клиент.*,
//	|	Контрагент.*,
//	|	Договор.*,
//	|	ГруппаГостей.*,
//	|	ПериодС,
//	|	ПериодПо,
//	|	НомерРазмещения.*,
//	|	ТипНомера.*,
//	|	Фирма.*,
//	|	ДокОснование.*,
//	|	Автор.*,
//	|	RegistrationDate,
//	|	(CASE
//	|			WHEN BlockedGiftCertificates.BlockDate IS NULL 
//	|				THEN FALSE
//	|			ELSE TRUE
//	|		END) AS IsBlocked,
//	|	BlockedGiftCertificates.BlockReason AS BlockReason,
//	|	BlockedGiftCertificates.BlockDate AS BlockDate,
//	|	BlockedGiftCertificates.BlockAuthor.* AS BlockAuthor,
//	|	NominalAmount,
//	|	AmountOpeningBalance,
//	|	PayedAmount,
//	|	WriteOffAmount,
//	|	AmountClosingBalance}
//	|TOTALS
//	|	SUM(NominalAmount),
//	|	SUM(AmountOpeningBalance),
//	|	SUM(PayedAmount),
//	|	SUM(WriteOffAmount),
//	|	SUM(AmountClosingBalance),
//	|	SUM(Количество)
//	|BY
//	|	OVERALL
//	|{TOTALS BY
//	|	Гостиница.*,
//	|	Услуга.*,
//	|	Клиент.*,
//	|	Контрагент.*,
//	|	Договор.*,
//	|	ГруппаГостей.*,
//	|	НомерРазмещения.*,
//	|	ТипНомера.*,
//	|	Фирма.*,
//	|	ДокОснование.*,
//	|	Автор.*,
//	|	(CASE
//	|			WHEN BlockedGiftCertificates.BlockDate IS NULL 
//	|				THEN FALSE
//	|			ELSE TRUE
//	|		END) AS IsBlocked,
//	|	BlockedGiftCertificates.BlockReason AS BlockReason,
//	|	BlockedGiftCertificates.BlockAuthor.* AS BlockAuthor}";
//	ReportBuilder.Text = QueryText;
//	ReportBuilder.FillSettings();
//	
//	// Initialize report builder with default query
//	vRB = New ReportBuilder(QueryText);
//	vRBSettings = vRB.GetSettings(True, True, True, True, True);
//	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
//	
//	// Set default report builder header text
//	ReportBuilder.HeaderText = NStr("EN='Gift certificates';RU='Подарочные сертификаты';de='Geschenkgutscheine'");
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
//	If pName = "Количество" 
//	   Or pName = "NominalAmount" 
//	   Or pName = "AmountOpeningBalance" 
//	   Or pName = "PayedAmount" 
//	   Or pName = "WriteOffAmount" 
//	   Or pName = "AmountClosingBalance" Тогда
//		Return True;
//	Else
//		Return False;
//	EndIf;
//EndFunction //pmIsResource
//
////-----------------------------------------------------------------------------
//// Reports framework end
////-----------------------------------------------------------------------------
