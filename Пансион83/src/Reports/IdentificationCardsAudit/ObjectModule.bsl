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
//		PeriodFrom = BegOfDay(CurrentDate()); // For today
//		PeriodTo = EndOfDay(PeriodFrom);
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
//	If ЗначениеЗаполнено(Author) Тогда
//		If НЕ Author.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("en='Employee ';ru='Сотрудник ';de='Mitarbeiter'") + 
//			                     TrimAll(Author.Description) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("ru = 'Группа сотрудников '; en = 'Employees folder '") + 
//			                     TrimAll(Author.Description) + 
//			                     ";" + Chars.LF;
//		EndIf;
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
//	ReportBuilder.Parameters.Вставить("qPeriodFromIsEmpty", НЕ ЗначениеЗаполнено(PeriodFrom));
//	ReportBuilder.Parameters.Вставить("qPeriodTo", PeriodTo);
//	ReportBuilder.Parameters.Вставить("qPeriodToIsEmpty", НЕ ЗначениеЗаполнено(PeriodTo));
//	ReportBuilder.Parameters.Вставить("qRoom", ГруппаНомеров);
//	ReportBuilder.Parameters.Вставить("qRoomIsEmpty", НЕ ЗначениеЗаполнено(ГруппаНомеров));
//	ReportBuilder.Parameters.Вставить("qRoomType", RoomType);
//	ReportBuilder.Parameters.Вставить("qRoomTypeIsEmpty", НЕ ЗначениеЗаполнено(RoomType));
//	ReportBuilder.Parameters.Вставить("qAuthor", Author);
//	ReportBuilder.Parameters.Вставить("qAuthorIsEmpty", НЕ ЗначениеЗаполнено(Author));
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
//	|	КартаИД.Ref AS IdentificationCard,
//	|	КартаИД.Code,
//	|	КартаИД.Description,
//	|	КартаИД.IsBlocked,
//	|	КартаИД.IsCheckedOut,
//	|	КартаИД.Identifier,
//	|	КартаИД.IdentificationCardType,
//	|	КартаИД.CardUID,
//	|	КартаИД.СчетПроживания,
//	|	КартаИД.ДокОснование,
//	|	КартаИД.ГруппаГостей,
//	|	КартаИД.Клиент,
//	|	КартаИД.НомерРазмещения,
//	|	КартаИД.НомерРазмещения.ТипНомера AS ТипНомера,
//	|	КартаИД.DateTimeFrom,
//	|	КартаИД.DateTimeTo,
//	|	КартаИД.Гостиница,
//	|	КартаИД.BlockReason,
//	|	КартаИД.CreateDate AS CreateDate,
//	|	КартаИД.Автор,
//	|	FolioBalance.SumBalance AS FolioSumBalance,
//	|	FolioBalance.LimitBalance AS FolioLimitBalance,
//	|	1 AS СчетчикДокКвота
//	|{SELECT
//	|	IdentificationCard.* AS IdentificationCard,
//	|	Code,
//	|	Description,
//	|	IsBlocked,
//	|	IsCheckedOut,
//	|	Identifier,
//	|	IdentificationCardType.*,
//	|	CardUID,
//	|	СчетПроживания.*,
//	|	ДокОснование.*,
//	|	ГруппаГостей.*,
//	|	Клиент.*,
//	|	НомерРазмещения.*,
//	|	ТипНомера.*,
//	|	DateTimeFrom,
//	|	DateTimeTo,
//	|	Гостиница.*,
//	|	BlockReason,
//	|	CreateDate,
//	|	(BEGINOFPERIOD(КартаИД.CreateDate, DAY)) AS УчетнаяДата,
//	|	Автор.*,
//	|	FolioSumBalance,
//	|	FolioLimitBalance,
//	|	Counter}
//	|FROM
//	|	Catalog.КартаИД AS КартаИД
//	|		LEFT JOIN (SELECT
//	|			AccountsBalance.Гостиница AS Гостиница,
//	|			AccountsBalance.ВалютаЛицСчета AS ВалютаЛицСчета,
//	|			AccountsBalance.СчетПроживания AS СчетПроживания,
//	|			AccountsBalance.SumBalance AS SumBalance,
//	|			AccountsBalance.LimitBalance AS LimitBalance
//	|		FROM
//	|			AccumulationRegister.Взаиморасчеты.Balance(
//	|					,
//	|					(Гостиница IN HIERARCHY (&qHotel)
//	|						OR &qHotelIsEmpty)
//	|						AND (СчетПроживания.НомерРазмещения IN (&qRoom)
//	|							OR &qRoomIsEmpty)
//	|						AND (СчетПроживания.НомерРазмещения.ТипНомера IN (&qRoomType)
//	|							OR &qRoomTypeIsEmpty)) AS AccountsBalance) AS FolioBalance
//	|		ON КартаИД.СчетПроживания = FolioBalance.СчетПроживания
//	|WHERE
//	|	NOT КартаИД.DeletionMark
//	|	AND (КартаИД.Гостиница IN (&qHotel)
//	|			OR &qHotelIsEmpty)
//	|	AND (КартаИД.НомерРазмещения IN (&qRoom)
//	|			OR &qRoomIsEmpty)
//	|	AND (КартаИД.НомерРазмещения.ТипНомера IN (&qRoomType)
//	|			OR &qRoomTypeIsEmpty)
//	|	AND (КартаИД.Автор IN (&qAuthor)
//	|			OR &qAuthorIsEmpty)
//	|	AND (КартаИД.CreateDate >= &qPeriodFrom
//	|			OR &qPeriodFromIsEmpty)
//	|	AND (КартаИД.CreateDate <= &qPeriodTo
//	|			OR &qPeriodToIsEmpty)
//	|{WHERE
//	|	КартаИД.Ref.* AS IdentificationCard,
//	|	КартаИД.Code,
//	|	КартаИД.Description,
//	|	КартаИД.IsBlocked,
//	|	КартаИД.IsCheckedOut,
//	|	КартаИД.Identifier,
//	|	КартаИД.IdentificationCardType.*,
//	|	КартаИД.CardUID,
//	|	КартаИД.СчетПроживания.*,
//	|	КартаИД.ДокОснование.*,
//	|	КартаИД.ГруппаГостей.*,
//	|	КартаИД.Клиент.*,
//	|	КартаИД.НомерРазмещения.*,
//	|	КартаИД.НомерРазмещения.ТипНомера.* AS ТипНомера,
//	|	КартаИД.DateTimeFrom,
//	|	КартаИД.DateTimeTo,
//	|	КартаИД.Гостиница.*,
//	|	КартаИД.BlockReason,
//	|	КартаИД.CreateDate,
//	|	КартаИД.Автор.*,
//	|	FolioBalance.SumBalance AS FolioSumBalance,
//	|	FolioBalance.LimitBalance AS FolioLimitBalance}
//	|
//	|ORDER BY
//	|	CreateDate
//	|{ORDER BY
//	|	IdentificationCard.* AS IdentificationCard,
//	|	Code,
//	|	Description,
//	|	IsBlocked,
//	|	IsCheckedOut,
//	|	Identifier,
//	|	IdentificationCardType.*,
//	|	CardUID,
//	|	СчетПроживания.*,
//	|	ДокОснование.*,
//	|	ГруппаГостей.*,
//	|	Клиент.*,
//	|	НомерРазмещения.*,
//	|	ТипНомера.*,
//	|	DateTimeFrom,
//	|	DateTimeTo,
//	|	Гостиница.*,
//	|	BlockReason,
//	|	CreateDate,
//	|	Автор.*,
//	|	FolioSumBalance,
//	|	FolioLimitBalance}
//	|TOTALS
//	|	CASE
//	|		WHEN IdentificationCard IS NULL 
//	|			THEN SUM(FolioSumBalance)
//	|		ELSE 0
//	|	END AS FolioSumBalance,
//	|	CASE
//	|		WHEN IdentificationCard IS NULL 
//	|			THEN SUM(FolioLimitBalance)
//	|		ELSE 0
//	|	END AS FolioLimitBalance,
//	|	SUM(СчетчикДокКвота)
//	|BY
//	|	OVERALL,
//	|	IdentificationCard
//	|{TOTALS BY
//	|	IdentificationCard.* AS IdentificationCard,
//	|	Code,
//	|	Description,
//	|	IsBlocked,
//	|	IsCheckedOut,
//	|	Identifier,
//	|	IdentificationCardType.*,
//	|	CardUID,
//	|	СчетПроживания.*,
//	|	ДокОснование.*,
//	|	ГруппаГостей.*,
//	|	Клиент.*,
//	|	НомерРазмещения.*,
//	|	ТипНомера.*,
//	|	Гостиница.*,
//	|	BlockReason,
//	|	(BEGINOFPERIOD(КартаИД.CreateDate, DAY)) AS УчетнаяДата,
//	|	Автор.*}";
//	ReportBuilder.Text = QueryText;
//	ReportBuilder.FillSettings();
//	
//	// Initialize report builder with default query
//	vRB = New ReportBuilder(QueryText);
//	vRBSettings = vRB.GetSettings(True, True, True, True, True);
//	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
//	
//	// Set default report builder header text
//	ReportBuilder.HeaderText = NStr("EN='Client identification cards audit';RU='Аудит выданных карт идентификации клиентов';de='Prüfung der ausgegebenen Identifikationskarten der Kunden'");
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
