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
//		ShowUsed = True;
//		ShowIssuedButNotUsed = True;
//		ShowMarkedDeleted = True;
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
//	If ЗначениеЗаполнено(HotelProduct) Тогда
//		If НЕ HotelProduct.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("ru = 'Путевка '; en = 'Гостиница product '") + 
//			                     TrimAll(HotelProduct.Description) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("ru = 'Тип путевок/курсовок '; en = 'Гостиница products type '") + 
//			                     TrimAll(HotelProduct.Description) + 
//			                     ";" + Chars.LF;
//		EndIf;
//	EndIf;
//	If ShowUsed Тогда
//			vParamPresentation = vParamPresentation + NStr("en='Show used products';ru='Показывать использованные путевки';de='Nur verwendete Reisen anzeigen'") + 
//			                     ";" + Chars.LF;
//	EndIf;
//	If ShowIssuedButNotUsed Тогда
//			vParamPresentation = vParamPresentation + NStr("en='Show issued but not used products';ru='Показывать отгруженные но не использованные путевки';de='Versandte, aber nicht genutzte Reisen anzeigen'") + 
//			                     ";" + Chars.LF;
//	EndIf;
//	If ShowMarkedDeleted Тогда
//			vParamPresentation = vParamPresentation + NStr("en='Show marked as deleted products';ru='Показывать испорченные путевки';de='ungültige Reiseunterlagen anzeigen'") + 
//			                     ";" + Chars.LF;
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
//	// Fill report parameters
//	ReportBuilder.Parameters.Вставить("qHotel", Гостиница);
//	ReportBuilder.Parameters.Вставить("qHotelIsEmpty", НЕ ЗначениеЗаполнено(Гостиница));
//	ReportBuilder.Parameters.Вставить("qPeriodFrom", PeriodFrom);
//	ReportBuilder.Parameters.Вставить("qPeriodTo", PeriodTo);
//	ReportBuilder.Parameters.Вставить("qPeriodToIsEmpty", НЕ ЗначениеЗаполнено(PeriodTo));
//	ReportBuilder.Parameters.Вставить("qHotelProductType", HotelProduct);
//	ReportBuilder.Parameters.Вставить("qHotelProductTypeIsEmpty", НЕ ЗначениеЗаполнено(HotelProduct));
//	ReportBuilder.Parameters.Вставить("qShowUsed", ShowUsed);
//	ReportBuilder.Parameters.Вставить("qShowIssuedButNotUsed", ShowIssuedButNotUsed);
//	ReportBuilder.Parameters.Вставить("qShowMarkedDeleted", ShowMarkedDeleted);
//	ReportBuilder.Parameters.Вставить("qEmptyString", "");
//	ReportBuilder.Parameters.Вставить("qEmptyDate", '00010101');
//	ReportBuilder.Parameters.Вставить("qEmptyPaymentMethod", Справочники.СпособОплаты.EmptyRef());
//	ReportBuilder.Parameters.Вставить("qEmptyPaymentSection", Справочники.ОтделОплаты.EmptyRef());
//	ReportBuilder.Parameters.Вставить("qEmptyHotelProduct", Справочники.ПутевкиКурсовки.EmptyRef());
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
//	"SELECT
//	|	ПутевкиКурсовки.HotelProductType,
//	|	ПутевкиКурсовки.Code,
//	|	ПутевкиКурсовки.Description,
//	|	ПутевкиКурсовки.Гостиница,
//	|	ПутевкиКурсовки.КвотаНомеров,
//	|	ПутевкиКурсовки.ТипНомера,
//	|	ПутевкиКурсовки.Клиент,
//	|	ПутевкиКурсовки.CheckInDate,
//	|	ПутевкиКурсовки.Продолжительность,
//	|	ПутевкиКурсовки.CheckOutDate,
//	|	ПутевкиКурсовки.FixProductPeriod,
//	|	ПутевкиКурсовки.FixPlannedPeriod,
//	|	ПутевкиКурсовки.FixProductCost,
//	|	ПутевкиКурсовки.Сумма AS Сумма,
//	|	ПутевкиКурсовки.SumWithoutCommission AS SumWithoutCommission,
//	|	ПутевкиКурсовки.Цена AS Цена,
//	|	ПутевкиКурсовки.PaymentSum AS PaymentSum,
//	|	ПутевкиКурсовки.CashSum AS CashSum,
//	|	ПутевкиКурсовки.CreditCardSum AS CreditCardSum,
//	|	ПутевкиКурсовки.BankTransferSum AS BankTransferSum,
//	|	ПутевкиКурсовки.Валюта,
//	|	ПутевкиКурсовки.PaymentDate,
//	|	ПутевкиКурсовки.СпособОплаты,
//	|	ПутевкиКурсовки.Примечания,
//	|	ПутевкиКурсовки.ExternalCode,
//	|	ПутевкиКурсовки.SocialGroup,
//	|	ПутевкиКурсовки.CreateDateTime AS CreateDateTime,
//	|	ПутевкиКурсовки.Автор,
//	|	ПутевкиКурсовки.DeletionMark,
//	|	ПутевкиКурсовки.DeletionMarkDateTime,
//	|	ПутевкиКурсовки.DeletionMarkAuthor,
//	|	ПутевкиКурсовки.СчетчикДокКвота AS СчетчикДокКвота
//	|{SELECT
//	|	HotelProductType.*,
//	|	Code,
//	|	Description,
//	|	Гостиница.*,
//	|	КвотаНомеров.*,
//	|	ТипНомера.*,
//	|	Клиент.*,
//	|	CheckInDate,
//	|	Продолжительность,
//	|	CheckOutDate,
//	|	FixProductPeriod,
//	|	FixPlannedPeriod,
//	|	FixProductCost,
//	|	Сумма,
//	|	SumWithoutCommission,
//	|	Цена,
//	|	PaymentSum,
//	|	CashSum,
//	|	CreditCardSum,
//	|	BankTransferSum,
//	|	Валюта.*,
//	|	PaymentDate,
//	|	СпособОплаты.*,
//	|	ПутевкиКурсовки.PaymentSection.*,
//	|	Примечания,
//	|	ExternalCode,
//	|	SocialGroup.*,
//	|	CreateDateTime,
//	|	(BEGINOFPERIOD(ПутевкиКурсовки.CreateDateTime, DAY)) AS CreateDate,
//	|	Автор.*,
//	|	DeletionMark,
//	|	DeletionMarkDateTime,
//	|	(BEGINOFPERIOD(ПутевкиКурсовки.DeletionMarkDateTime, DAY)) AS DeletionMarkDate,
//	|	DeletionMarkAuthor.*,
//	|	Counter}
//	|FROM
//	|	(SELECT
//	|		UsedHotelProducts.Parent AS HotelProductType,
//	|		UsedHotelProducts.Code AS Code,
//	|		UsedHotelProducts.Description AS Description,
//	|		UsedHotelProducts.Гостиница AS Гостиница,
//	|		UsedHotelProducts.КвотаНомеров AS КвотаНомеров,
//	|		UsedHotelProducts.ТипНомера AS ТипНомера,
//	|		UsedHotelProducts.Клиент AS Клиент,
//	|		UsedHotelProducts.CheckInDate AS CheckInDate,
//	|		UsedHotelProducts.Продолжительность AS Продолжительность,
//	|		UsedHotelProducts.CheckOutDate AS CheckOutDate,
//	|		UsedHotelProducts.FixProductPeriod AS FixProductPeriod,
//	|		UsedHotelProducts.FixPlannedPeriod AS FixPlannedPeriod,
//	|		UsedHotelProducts.FixProductCost AS FixProductCost,
//	|		HotelProductTotalSales.Сумма AS Сумма,
//	|		HotelProductTotalSales.Сумма - HotelProductTotalSales.СуммаКомиссии AS SumWithoutCommission,
//	|		UsedHotelProducts.Сумма AS Цена,
//	|		UsedHotelProducts.Валюта AS Валюта,
//	|		UsedHotelProducts.PaymentDate AS PaymentDate,
//	|		UsedHotelProducts.СпособОплаты AS СпособОплаты,
//	|		HotelProductPaymentTotals.PaymentSection AS PaymentSection,
//	|		UsedHotelProducts.Примечания AS Примечания,
//	|		UsedHotelProducts.ExternalCode AS ExternalCode,
//	|		UsedHotelProducts.SocialGroup AS SocialGroup,
//	|		UsedHotelProducts.CreateDate AS CreateDateTime,
//	|		UsedHotelProducts.Автор AS Автор,
//	|		UsedHotelProducts.DeletionMark AS DeletionMark,
//	|		UsedHotelProducts.DeletionMarkDate AS DeletionMarkDateTime,
//	|		UsedHotelProducts.DeletionMarkAuthor AS DeletionMarkAuthor,
//	|		1 AS СчетчикДокКвота,
//	|		HotelProductPaymentTotals.PaymentSum AS PaymentSum,
//	|		HotelProductPaymentTotals.CashSum AS CashSum,
//	|		HotelProductPaymentTotals.CreditCardSum AS CreditCardSum,
//	|		HotelProductPaymentTotals.BankTransferSum AS BankTransferSum
//	|	FROM
//	|		Catalog.ПутевкиКурсовки AS UsedHotelProducts
//	|			LEFT JOIN (SELECT
//	|				HotelProductSalesTurnovers.ПутевкаКурсовка AS ПутевкаКурсовка,
//	|				HotelProductSalesTurnovers.SalesTurnover AS Сумма,
//	|				HotelProductSalesTurnovers.CommissionSumTurnover AS СуммаКомиссии
//	|			FROM
//	|				AccumulationRegister.ПродажиПутевокКурсовок.Turnovers(
//	|						,
//	|						,
//	|						Period,
//	|						(ПутевкаКурсовка IN HIERARCHY (&qHotelProductType)
//	|							OR &qHotelProductTypeIsEmpty)
//	|							AND (Гостиница = &qHotel
//	|								OR &qHotelIsEmpty)) AS HotelProductSalesTurnovers) AS HotelProductTotalSales
//	|			ON (HotelProductTotalSales.ПутевкаКурсовка = UsedHotelProducts.Ref)
//	|			LEFT JOIN (SELECT
//	|				HotelProductPayments.PaymentSection AS PaymentSection,
//	|				HotelProductPayments.ВалютаРасчетов AS ВалютаРасчетов,
//	|				CASE
//	|					WHEN NOT HotelProductPayments.СчетПроживания.ПутевкаКурсовка IS NULL 
//	|							AND HotelProductPayments.СчетПроживания.ПутевкаКурсовка <> &qEmptyHotelProduct
//	|						THEN HotelProductPayments.СчетПроживания.ПутевкаКурсовка
//	|					WHEN NOT HotelProductPayments.СчетПроживания.ДокОснование.ПутевкаКурсовка IS NULL 
//	|							AND HotelProductPayments.СчетПроживания.ДокОснование.ПутевкаКурсовка <> &qEmptyHotelProduct
//	|						THEN HotelProductPayments.СчетПроживания.ДокОснование.ПутевкаКурсовка
//	|					ELSE HotelProductPayments.ДокОснование.ПутевкаКурсовка
//	|				END AS ПутевкаКурсовка,
//	|				SUM(HotelProductPayments.Сумма) AS PaymentSum,
//	|				SUM(CASE
//	|						WHEN ISNULL(HotelProductPayments.Recorder.СпособОплаты.IsByCash, FALSE)
//	|							THEN HotelProductPayments.Сумма
//	|						ELSE 0
//	|					END) AS CashSum,
//	|				SUM(CASE
//	|						WHEN ISNULL(HotelProductPayments.Recorder.СпособОплаты.IsByCreditCard, FALSE)
//	|							THEN HotelProductPayments.Сумма
//	|						ELSE 0
//	|					END) AS CreditCardSum,
//	|				SUM(CASE
//	|						WHEN ISNULL(HotelProductPayments.Recorder.СпособОплаты.IsByBankTransfer, FALSE)
//	|							THEN HotelProductPayments.Сумма
//	|						ELSE 0
//	|					END) AS BankTransferSum
//	|			FROM
//	|				AccumulationRegister.ВзаиморасчетыКонтрагенты AS HotelProductPayments
//	|			WHERE
//	|				HotelProductPayments.RecordType = VALUE(AccumulationrecordType.Expense)
//	|				AND (HotelProductPayments.Гостиница = &qHotel
//	|						OR &qHotelIsEmpty)
//	|			
//	|			GROUP BY
//	|				HotelProductPayments.PaymentSection,
//	|				HotelProductPayments.ВалютаРасчетов,
//	|				CASE
//	|					WHEN NOT HotelProductPayments.СчетПроживания.ПутевкаКурсовка IS NULL 
//	|							AND HotelProductPayments.СчетПроживания.ПутевкаКурсовка <> &qEmptyHotelProduct
//	|						THEN HotelProductPayments.СчетПроживания.ПутевкаКурсовка
//	|					WHEN NOT HotelProductPayments.СчетПроживания.ДокОснование.ПутевкаКурсовка IS NULL 
//	|							AND HotelProductPayments.СчетПроживания.ДокОснование.ПутевкаКурсовка <> &qEmptyHotelProduct
//	|						THEN HotelProductPayments.СчетПроживания.ДокОснование.ПутевкаКурсовка
//	|					ELSE HotelProductPayments.ДокОснование.ПутевкаКурсовка
//	|				END) AS HotelProductPaymentTotals
//	|			ON (HotelProductPaymentTotals.ПутевкаКурсовка = UsedHotelProducts.Ref)
//	|				AND (HotelProductPaymentTotals.PaymentSection = UsedHotelProducts.Parent.PaymentSection
//	|					OR UsedHotelProducts.Parent.PaymentSection = &qEmptyPaymentSection)
//	|				AND (HotelProductPaymentTotals.ВалютаРасчетов = UsedHotelProducts.Валюта)
//	|	WHERE
//	|		NOT UsedHotelProducts.IsFolder
//	|		AND UsedHotelProducts.CreateDate >= &qPeriodFrom
//	|		AND (UsedHotelProducts.CreateDate <= &qPeriodTo
//	|				OR &qPeriodToIsEmpty)
//	|		AND (UsedHotelProducts.Ref IN HIERARCHY (&qHotelProductType)
//	|				OR &qHotelProductTypeIsEmpty)
//	|		AND (UsedHotelProducts.Гостиница = &qHotel
//	|				OR &qHotelIsEmpty)
//	|		AND (&qShowUsed
//	|					AND NOT UsedHotelProducts.DeletionMark
//	|				OR &qShowMarkedDeleted
//	|					AND UsedHotelProducts.DeletionMark)
//	|	
//	|	UNION ALL
//	|	
//	|	SELECT
//	|		IssuedHotelProducts.HotelProductParent,
//	|		IssuedHotelProducts.ProductCode,
//	|		&qEmptyString,
//	|		IssuedHotelProducts.Гостиница,
//	|		IssuedHotelProducts.КвотаНомеров,
//	|		IssuedHotelProducts.ТипНомера,
//	|		IssuedHotelProducts.ДокОснование.Клиент,
//	|		IssuedHotelProducts.CheckInDate,
//	|		IssuedHotelProducts.Продолжительность,
//	|		IssuedHotelProducts.CheckOutDate,
//	|		IssuedHotelProducts.FixProductPeriod,
//	|		IssuedHotelProducts.FixPlannedPeriod,
//	|		IssuedHotelProducts.FixProductCost,
//	|		0,
//	|		0,
//	|		IssuedHotelProducts.Цена,
//	|		IssuedHotelProducts.Валюта,
//	|		&qEmptyDate,
//	|		&qEmptyPaymentMethod,
//	|		&qEmptyPaymentSection,
//	|		IssuedHotelProducts.BillOfShipment,
//	|		&qEmptyString,
//	|		IssuedHotelProducts.SocialGroup,
//	|		IssuedHotelProducts.Recorder.ДатаДок,
//	|		IssuedHotelProducts.Recorder.Автор,
//	|		FALSE,
//	|		&qEmptyDate,
//	|		NULL,
//	|		1,
//	|		0,
//	|		0,
//	|		0,
//	|		0
//	|	FROM
//	|		InformationRegister.IssuedHotelProducts AS IssuedHotelProducts
//	|	WHERE
//	|		&qShowIssuedButNotUsed
//	|		AND IssuedHotelProducts.Recorder.ДатаДок >= &qPeriodFrom
//	|		AND (IssuedHotelProducts.Recorder.ДатаДок <= &qPeriodTo
//	|				OR &qPeriodToIsEmpty)
//	|		AND (IssuedHotelProducts.HotelProductParent IN HIERARCHY (&qHotelProductType)
//	|				OR &qHotelProductTypeIsEmpty)
//	|		AND (IssuedHotelProducts.Гостиница = &qHotel
//	|				OR &qHotelIsEmpty)
//	|		AND NOT IssuedHotelProducts.ProductCode IN
//	|					(SELECT
//	|						AllHotelProducts.Code
//	|					FROM
//	|						Catalog.ПутевкиКурсовки AS AllHotelProducts
//	|					WHERE
//	|						(AllHotelProducts.Гостиница = &qHotel
//	|							OR &qHotelIsEmpty)
//	|						AND NOT AllHotelProducts.IsFolder)) AS ПутевкиКурсовки
//	|{WHERE
//	|	ПутевкиКурсовки.HotelProductType.*,
//	|	ПутевкиКурсовки.Code,
//	|	ПутевкиКурсовки.Description,
//	|	ПутевкиКурсовки.Гостиница.*,
//	|	ПутевкиКурсовки.КвотаНомеров.*,
//	|	ПутевкиКурсовки.ТипНомера.*,
//	|	ПутевкиКурсовки.Клиент.*,
//	|	ПутевкиКурсовки.CheckInDate,
//	|	ПутевкиКурсовки.Продолжительность,
//	|	ПутевкиКурсовки.CheckOutDate,
//	|	ПутевкиКурсовки.FixProductPeriod,
//	|	ПутевкиКурсовки.FixPlannedPeriod,
//	|	ПутевкиКурсовки.FixProductCost,
//	|	ПутевкиКурсовки.Сумма,
//	|	ПутевкиКурсовки.SumWithoutCommission,
//	|	ПутевкиКурсовки.Цена,
//	|	ПутевкиКурсовки.PaymentSum,
//	|	ПутевкиКурсовки.CashSum,
//	|	ПутевкиКурсовки.CreditCardSum,
//	|	ПутевкиКурсовки.BankTransferSum,
//	|	ПутевкиКурсовки.Валюта.*,
//	|	ПутевкиКурсовки.PaymentDate,
//	|	ПутевкиКурсовки.СпособОплаты.*,
//	|	ПутевкиКурсовки.PaymentSection.*,
//	|	ПутевкиКурсовки.Примечания,
//	|	ПутевкиКурсовки.ExternalCode,
//	|	ПутевкиКурсовки.SocialGroup.*,
//	|	ПутевкиКурсовки.CreateDateTime,
//	|	ПутевкиКурсовки.Автор.*,
//	|	ПутевкиКурсовки.DeletionMarkDateTime,
//	|	ПутевкиКурсовки.DeletionMarkAuthor.*}
//	|
//	|ORDER BY
//	|	CreateDateTime
//	|{ORDER BY
//	|	HotelProductType.*,
//	|	Code,
//	|	Description,
//	|	Гостиница.*,
//	|	КвотаНомеров.*,
//	|	ТипНомера.*,
//	|	Клиент.*,
//	|	CheckInDate,
//	|	Продолжительность,
//	|	CheckOutDate,
//	|	FixProductPeriod,
//	|	FixPlannedPeriod,
//	|	FixProductCost,
//	|	Сумма,
//	|	SumWithoutCommission,
//	|	Цена,
//	|	PaymentSum,
//	|	CashSum,
//	|	CreditCardSum,
//	|	BankTransferSum,
//	|	Валюта.*,
//	|	PaymentDate,
//	|	СпособОплаты.*,
//	|	ПутевкиКурсовки.PaymentSection.*,
//	|	Примечания,
//	|	ExternalCode,
//	|	SocialGroup.*,
//	|	CreateDateTime,
//	|	Автор.*,
//	|	DeletionMark,
//	|	DeletionMarkDateTime,
//	|	DeletionMarkAuthor.*}
//	|TOTALS
//	|	SUM(Сумма),
//	|	SUM(SumWithoutCommission),
//	|	SUM(Цена),
//	|	SUM(PaymentSum),
//	|	SUM(CashSum),
//	|	SUM(CreditCardSum),
//	|	SUM(BankTransferSum),
//	|	SUM(СчетчикДокКвота)
//	|BY
//	|	OVERALL
//	|{TOTALS BY
//	|	HotelProductType.*,
//	|	Code,
//	|	Description,
//	|	Гостиница.*,
//	|	КвотаНомеров.*,
//	|	ТипНомера.*,
//	|	Клиент.*,
//	|	CheckInDate,
//	|	Продолжительность,
//	|	CheckOutDate,
//	|	FixProductPeriod,
//	|	FixPlannedPeriod,
//	|	FixProductCost,
//	|	Валюта.*,
//	|	PaymentDate,
//	|	СпособОплаты.*,
//	|	ПутевкиКурсовки.PaymentSection.*,
//	|	Примечания,
//	|	ExternalCode,
//	|	SocialGroup.*,
//	|	CreateDateTime,
//	|	(BEGINOFPERIOD(ПутевкиКурсовки.CreateDateTime, DAY)) AS CreateDate,
//	|	Автор.*,
//	|	DeletionMark,
//	|	DeletionMarkDateTime,
//	|	(BEGINOFPERIOD(ПутевкиКурсовки.DeletionMarkDateTime, DAY)) AS DeletionMarkDate,
//	|	DeletionMarkAuthor.*}";
//	ReportBuilder.Text = QueryText;
//	ReportBuilder.FillSettings();
//	
//	// Initialize report builder with default query
//	vRB = New ReportBuilder(QueryText);
//	vRBSettings = vRB.GetSettings(True, True, True, True, True);
//	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
//	
//	// Set default report builder header text
//	ReportBuilder.HeaderText = NStr("EN='Гостиница products register';RU='Реестр использованных бланков путевок';de='Verzeichnis der verwendeten Reisescheckformulare'");
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
