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
//	If НЕ ЗначениеЗаполнено(DebtorsFilterType) Тогда
//		DebtorsFilterType = Перечисления.DebtorsFilterTypes.All;
//	EndIf;
//КонецПроцедуры //pmFillAttributesWithDefaultValues
//
////-----------------------------------------------------------------------------
//Function pmGetReportParametersPresentation() Экспорт
//	vParamPresentation = "";
//	If ЗначениеЗаполнено(PeriodTo) Тогда
//		vParamPresentation = vParamPresentation + NStr("ru = 'Должники на '; en = 'Debts on '") + 
//							 Format(PeriodTo, "DF='dd.MM.yyyy HH:mm'") + 
//							 ";" + Chars.LF;
//	EndIf;
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
//	If ЗначениеЗаполнено(FolioCurrency) Тогда
//		vParamPresentation = vParamPresentation + NStr("ru = 'Валюта фолио '; en = 'ЛицевойСчет currency '") + 
//							 TrimAll(FolioCurrency.Description) + 
//							 ";" + Chars.LF;
//	EndIf;
//	If ЗначениеЗаполнено(Контрагент) Тогда
//		If НЕ Контрагент.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("de='Firma';en='Контрагент ';ru='Контрагент '") + 
//			                     TrimAll(Контрагент.Description) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("de='Gruppe Firmen';en='Customers folder ';ru='Группа контрагентов '") + 
//			                     TrimAll(Контрагент.Description) + 
//			                     ";" + Chars.LF;
//		EndIf;
//	EndIf;
//	If ЗначениеЗаполнено(Contract) Тогда
//		vParamPresentation = vParamPresentation + NStr("en='Contract ';ru='Договор ';de='Vertrag '") + 
//							 TrimAll(Contract.Description) + 
//							 ";" + Chars.LF;
//	EndIf;
//	If ЗначениеЗаполнено(Service) Тогда
//		If НЕ Service.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("ru = 'Отбор лицевых счетов по услуге '; en = 'Filter folios by service '") + 
//			                     TrimAll(Service.Description) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("ru = 'Отбор лицевых счетов по группе услуг '; en = 'Filter folios by services folder '") + 
//			                     TrimAll(Service.Description) + 
//			                     ";" + Chars.LF;
//		EndIf;
//	EndIf;					 
//	If ЗначениеЗаполнено(DebtorsFilterType) Тогда
//		If DebtorsFilterType = Перечисления.DebtorsFilterTypes.NoDecisionYet Тогда
//			vParamPresentation = vParamPresentation + NStr("en='Show debts where there is no decision yet';ru='Показывать должников, по которым еще не принято какое-либо решение';de='Schuldner anzeigen, zu denen noch keine Entscheidung getroffen wurde'") + 
//			                     ";" + Chars.LF;
//		ElsIf DebtorsFilterType = Перечисления.DebtorsFilterTypes.ThereIsDecision Тогда
//			vParamPresentation = vParamPresentation + NStr("en='Show debts where decision was already made';ru='Показывать должников, по которым уже принято решение';de='Schuldner anzeigen, zu denen die Entscheidung bereits getroffen wurde'") + 
//			                     ";" + Chars.LF;
//		EndIf;
//	EndIf;
//	If ЗначениеЗаполнено(DebtDecision) Тогда
//			vParamPresentation = vParamPresentation + NStr("ru = 'Решение по долгам '; en = 'Debts decision '") + 
//			                     TrimAll(DebtDecision) + 
//			                     ";" + Chars.LF;
//	EndIf;
//	Return vParamPresentation;
//EndFunction //pmGetReportParametersPresentation
//
////-----------------------------------------------------------------------------
//// Runs report and returns if report form should be shown
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
//	ReportBuilder.Parameters.Вставить("qPeriodTo", ?(ЗначениеЗаполнено(PeriodTo), New Boundary(PeriodTo, BoundaryType.Excluding), '39991231235959'));
//	ReportBuilder.Parameters.Вставить("qCurrentDate", CurrentDate());
//	ReportBuilder.Parameters.Вставить("qRoom", ГруппаНомеров);
//	ReportBuilder.Parameters.Вставить("qFilterByRoom", ЗначениеЗаполнено(ГруппаНомеров));
//	ReportBuilder.Parameters.Вставить("qRoomType", RoomType);
//	ReportBuilder.Parameters.Вставить("qFilterByRoomType", ЗначениеЗаполнено(RoomType));
//	ReportBuilder.Parameters.Вставить("qCustomer", Контрагент);
//	ReportBuilder.Parameters.Вставить("qFilterByCustomer", ЗначениеЗаполнено(Контрагент));
//	ReportBuilder.Parameters.Вставить("qEmptyCustomer", Справочники.Контрагенты.EmptyRef());
//	ReportBuilder.Parameters.Вставить("qIndividualsCustomer", ?(ЗначениеЗаполнено(Гостиница), Гостиница.IndividualsCustomer, Справочники.Контрагенты.EmptyRef()));
//	ReportBuilder.Parameters.Вставить("qIndividualsCustomerFolder", Справочники.Контрагенты.КонтрагентПоУмолчанию);
//	ReportBuilder.Parameters.Вставить("qContract", Contract);
//	ReportBuilder.Parameters.Вставить("qFilterByContract", ЗначениеЗаполнено(Contract));
//	ReportBuilder.Parameters.Вставить("qFolioCurrency", FolioCurrency);
//	ReportBuilder.Parameters.Вставить("qFilterByFolioCurrency", ЗначениеЗаполнено(FolioCurrency));
//	ReportBuilder.Parameters.Вставить("qService", Service);
//	ReportBuilder.Parameters.Вставить("qServiceIsFilled", ЗначениеЗаполнено(Service));
//	ReportBuilder.Parameters.Вставить("qDebtDecision", DebtDecision);
//	ReportBuilder.Parameters.Вставить("qEmptyDebtDecision", Перечисления.DebtsDecisionTypes.EmptyRef());
//	ReportBuilder.Parameters.Вставить("qDebtDecisionIsFilled", ЗначениеЗаполнено(DebtDecision));
//	ReportBuilder.Parameters.Вставить("qAll", True);
//	ReportBuilder.Parameters.Вставить("qNoDecisionYet", True);
//	ReportBuilder.Parameters.Вставить("qThereIsDecision", True);
//	If ЗначениеЗаполнено(DebtorsFilterType) Тогда
//		If DebtorsFilterType = Перечисления.DebtorsFilterTypes.NoDecisionYet Тогда
//			ReportBuilder.Parameters.qAll = False;
//			ReportBuilder.Parameters.qThereIsDecision = False;
//		ElsIf DebtorsFilterType = Перечисления.DebtorsFilterTypes.ThereIsDecision Тогда
//			ReportBuilder.Parameters.qAll = False;
//			ReportBuilder.Parameters.qNoDecisionYet = False;
//		EndIf;
//	EndIf;
//
//	// Execute report builder query
//	ReportBuilder.Execute();
//	//Message(ReportBuilder.GetQuery().Text); // For debug purpose
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
//	|	Debts.Гостиница AS Гостиница,
//	|	Debts.ВалютаЛицСчета AS ВалютаЛицСчета,
//	|	Debts.FolioRoom AS FolioRoom,
//	|	Debts.СчетПроживания AS СчетПроживания,
//	|	Debts.FolioDescription AS FolioDescription,
//	|	Debts.FolioCustomer AS FolioCustomer,
//	|	Debts.FolioClient AS FolioClient,
//	|	Debts.FolioGuestGroup AS FolioGuestGroup,
//	|	Debts.FolioDateTimeFrom AS FolioDateTimeFrom,
//	|	Debts.FolioDateTimeTo AS FolioDateTimeTo,
//	|	Debts.FolioRemarks AS FolioRemarks,
//	|	Debts.SumBalance AS SumBalance,
//	|	Debts.CustomerSumBalance AS CustomerSumBalance,
//	|	Debts.ClientSumBalance AS ClientSumBalance,
//	|	Debts.LimitBalance AS LimitBalance,
//	|	Debts.PlanBalance AS PlanBalance,
//	|	Debts.OverlimitBalance AS OverlimitBalance,
//	|	Debts.SumCurrentBalance AS SumCurrentBalance
//	|{SELECT
//	|	Гостиница.*,
//	|	ВалютаЛицСчета.* AS ВалютаЛицСчета,
//	|	FolioRoom.* AS FolioRoom,
//	|	СчетПроживания.* AS СчетПроживания,
//	|	FolioDescription AS FolioDescription,
//	|	FolioCustomer.* AS FolioCustomer,
//	|	Debts.FolioContract.* AS FolioContract,
//	|	Debts.FolioAgent.* AS FolioAgent,
//	|	FolioClient.* AS FolioClient,
//	|	FolioDateTimeFrom AS FolioDateTimeFrom,
//	|	FolioDateTimeTo AS FolioDateTimeTo,
//	|	FolioGuestGroup.* AS FolioGuestGroup,
//	|	Debts.FolioParentDoc.* AS FolioParentDoc,
//	|	Debts.FolioCompany.* AS FolioCompany,
//	|	Debts.FolioRoomRoomType.* AS FolioRoomRoomType,
//	|	FolioRemarks AS FolioRemarks,
//	|	Debts.FolioAuthor.* AS FolioAuthor,
//	|	Debts.FolioPaymentSection.* AS FolioPaymentSection,
//	|	Debts.FolioPaymentMethod.* AS FolioPaymentMethod,
//	|	Debts.FolioIsMaster AS FolioIsMaster,
//	|	Debts.FolioIsClosed AS FolioIsClosed,
//	|	Debts.FolioDateTimeFromHour AS FolioDateTimeFromHour,
//	|	Debts.FolioDateTimeFromDay AS FolioDateTimeFromDay,
//	|	Debts.FolioDateTimeFromWeek AS FolioDateTimeFromWeek,
//	|	Debts.FolioDateTimeFromMonth AS FolioDateTimeFromMonth,
//	|	Debts.FolioDateTimeFromQuarter AS FolioDateTimeFromQuarter,
//	|	Debts.FolioDateTimeFromYear AS FolioDateTimeFromYear,
//	|	Debts.IsCustomerBalance AS IsCustomerBalance,
//	|	Debts.IsClientBalance AS IsClientBalance,
//	|	SumBalance AS SumBalance,
//	|	CustomerSumBalance AS CustomerSumBalance,
//	|	ClientSumBalance AS ClientSumBalance,
//	|	LimitBalance AS LimitBalance,
//	|	PlanBalance AS PlanBalance,
//	|	OverlimitBalance AS OverlimitBalance,
//	|	SumCurrentBalance AS SumCurrentBalance}
//	|FROM
//	|	(SELECT
//	|		FolioBalances.Гостиница AS Гостиница,
//	|		FolioBalances.ВалютаЛицСчета AS ВалютаЛицСчета,
//	|		FolioBalances.СчетПроживания AS СчетПроживания,
//	|		FolioBalances.PaymentSection AS FolioPaymentSection,
//	|		FolioBalances.СчетПроживания.НомерРазмещения AS FolioRoom,
//	|		FolioBalances.СчетПроживания.Description AS FolioDescription,
//	|		FolioBalances.СчетПроживания.Контрагент AS FolioCustomer,
//	|		FolioBalances.СчетПроживания.Договор AS FolioContract,
//	|		FolioBalances.СчетПроживания.Агент AS FolioAgent,
//	|		FolioBalances.СчетПроживания.Клиент AS FolioClient,
//	|		FolioBalances.СчетПроживания.DateTimeFrom AS FolioDateTimeFrom,
//	|		FolioBalances.СчетПроживания.DateTimeTo AS FolioDateTimeTo,
//	|		FolioBalances.СчетПроживания.ГруппаГостей AS FolioGuestGroup,
//	|		FolioBalances.СчетПроживания.ДокОснование AS FolioParentDoc,
//	|		FolioBalances.СчетПроживания.Фирма AS FolioCompany,
//	|		FolioBalances.СчетПроживания.НомерРазмещения.ТипНомера AS FolioRoomRoomType,
//	|		FolioBalances.СчетПроживания.Примечания AS FolioRemarks,
//	|		FolioBalances.СчетПроживания.Автор AS FolioAuthor,
//	|		FolioBalances.СчетПроживания.СпособОплаты AS FolioPaymentMethod,
//	|		FolioBalances.СчетПроживания.IsMaster AS FolioIsMaster,
//	|		FolioBalances.СчетПроживания.IsClosed AS FolioIsClosed,
//	|		HOUR(FolioBalances.СчетПроживания.DateTimeFrom) AS FolioDateTimeFromHour,
//	|		DAY(FolioBalances.СчетПроживания.DateTimeFrom) AS FolioDateTimeFromDay,
//	|		WEEK(FolioBalances.СчетПроживания.DateTimeFrom) AS FolioDateTimeFromWeek,
//	|		MONTH(FolioBalances.СчетПроживания.DateTimeFrom) AS FolioDateTimeFromMonth,
//	|		QUARTER(FolioBalances.СчетПроживания.DateTimeFrom) AS FolioDateTimeFromQuarter,
//	|		YEAR(FolioBalances.СчетПроживания.DateTimeFrom) AS FolioDateTimeFromYear,
//	|		CASE
//	|			WHEN FolioBalances.СчетПроживания.Контрагент <> &qEmptyCustomer
//	|					AND FolioBalances.СчетПроживания.Контрагент <> &qIndividualsCustomer
//	|					AND NOT FolioBalances.СчетПроживания.Контрагент IN HIERARCHY(&qIndividualsCustomerFolder)
//	|				THEN TRUE
//	|			ELSE FALSE
//	|		END AS IsCustomerBalance,
//	|		CASE
//	|			WHEN FolioBalances.СчетПроживания.Контрагент <> &qEmptyCustomer
//	|					AND FolioBalances.СчетПроживания.Контрагент <> &qIndividualsCustomer
//	|					AND NOT FolioBalances.СчетПроживания.Контрагент IN HIERARCHY(&qIndividualsCustomerFolder)
//	|				THEN FALSE
//	|			ELSE TRUE
//	|		END AS IsClientBalance,
//	|		FolioBalances.SumBalance AS SumBalance,
//	|		CASE
//	|			WHEN FolioBalances.СчетПроживания.Контрагент <> &qEmptyCustomer
//	|					AND FolioBalances.СчетПроживания.Контрагент <> &qIndividualsCustomer
//	|					AND NOT FolioBalances.СчетПроживания.Контрагент IN HIERARCHY(&qIndividualsCustomerFolder)
//	|				THEN FolioBalances.SumBalance
//	|			ELSE 0
//	|		END AS CustomerSumBalance,
//	|		CASE
//	|			WHEN FolioBalances.СчетПроживания.Контрагент <> &qEmptyCustomer
//	|					AND FolioBalances.СчетПроживания.Контрагент <> &qIndividualsCustomer
//	|					AND NOT FolioBalances.СчетПроживания.Контрагент IN HIERARCHY(&qIndividualsCustomerFolder)
//	|				THEN 0
//	|			ELSE FolioBalances.SumBalance
//	|		END AS ClientSumBalance,
//	|		FolioBalances.LimitBalance AS LimitBalance,
//	|		FolioBalances.SumCurrentBalance AS SumCurrentBalance,
//	|		FolioBalances.SumBalance - FolioBalances.SumCurrentBalance AS PlanBalance,
//	|		FolioBalances.SumBalance - FolioBalances.LimitBalance AS OverlimitBalance
//	|	FROM
//	|		(SELECT
//	|			AccountsBalances.Гостиница AS Гостиница,
//	|			AccountsBalances.ВалютаЛицСчета AS ВалютаЛицСчета,
//	|			AccountsBalances.СчетПроживания AS СчетПроживания,
//	|			AccountsBalances.PaymentSection AS PaymentSection,
//	|			SUM(AccountsBalances.SumBalance) AS SumBalance,
//	|			SUM(AccountsBalances.LimitBalance) AS LimitBalance,
//	|			SUM(AccountsBalances.SumCurrentBalance) AS SumCurrentBalance,
//	|			SUM(AccountsBalances.LimitCurrentBalance) AS LimitCurrentBalance
//	|		FROM
//	|			(SELECT
//	|				AccountsBalance.Гостиница AS Гостиница,
//	|				AccountsBalance.ВалютаЛицСчета AS ВалютаЛицСчета,
//	|				AccountsBalance.СчетПроживания AS СчетПроживания,
//	|				AccountsBalance.PaymentSection AS PaymentSection,
//	|				AccountsBalance.SumBalance AS SumBalance,
//	|				-AccountsBalance.LimitBalance AS LimitBalance,
//	|				0 AS SumCurrentBalance,
//	|				0 AS LimitCurrentBalance
//	|			FROM
//	|				AccumulationRegister.Взаиморасчеты.Balance(
//	|						&qPeriodTo,
//	|						Гостиница IN HIERARCHY (&qHotel)
//	|							AND (ВалютаЛицСчета = &qFolioCurrency
//	|								OR &qFilterByFolioCurrency = FALSE)) AS AccountsBalance
//	|			WHERE
//	|				(NOT &qServiceIsFilled)
//	|				AND (AccountsBalance.СчетПроживания.НомерРазмещения IN HIERARCHY (&qRoom)
//	|						OR (NOT &qFilterByRoom))
//	|				AND (AccountsBalance.СчетПроживания.НомерРазмещения.ТипНомера IN HIERARCHY (&qRoomType)
//	|						OR (NOT &qFilterByRoomType))
//	|				AND (AccountsBalance.СчетПроживания.Контрагент IN HIERARCHY (&qCustomer)
//	|						OR (NOT &qFilterByCustomer))
//	|				AND (AccountsBalance.СчетПроживания.Договор = &qContract
//	|						OR (NOT &qFilterByContract))
//	|				AND (&qAll
//	|						OR &qNoDecisionYet
//	|							AND AccountsBalance.СчетПроживания.DebtDecision = &qEmptyDebtDecision
//	|						OR &qThereIsDecision
//	|							AND AccountsBalance.СчетПроживания.DebtDecision <> &qEmptyDebtDecision
//	|							AND ((NOT &qDebtDecisionIsFilled)
//	|								OR &qDebtDecisionIsFilled
//	|									AND AccountsBalance.СчетПроживания.DebtDecision IN HIERARCHY (&qDebtDecision)))
//	|			
//	|			UNION ALL
//	|			
//	|			SELECT
//	|				AccountsCurrentBalance.Гостиница,
//	|				AccountsCurrentBalance.ВалютаЛицСчета,
//	|				AccountsCurrentBalance.СчетПроживания,
//	|				AccountsCurrentBalance.PaymentSection,
//	|				0,
//	|				0,
//	|				AccountsCurrentBalance.SumBalance,
//	|				-AccountsCurrentBalance.LimitBalance
//	|			FROM
//	|				AccumulationRegister.Взаиморасчеты.Balance(
//	|						&qCurrentDate,
//	|						Гостиница IN HIERARCHY (&qHotel)
//	|							AND (ВалютаЛицСчета = &qFolioCurrency
//	|								OR &qFilterByFolioCurrency = FALSE)) AS AccountsCurrentBalance
//	|			WHERE
//	|				(NOT &qServiceIsFilled)
//	|				AND (AccountsCurrentBalance.СчетПроживания.НомерРазмещения IN HIERARCHY (&qRoom)
//	|						OR (NOT &qFilterByRoom))
//	|				AND (AccountsCurrentBalance.СчетПроживания.НомерРазмещения.ТипНомера IN HIERARCHY (&qRoomType)
//	|						OR (NOT &qFilterByRoomType))
//	|				AND (AccountsCurrentBalance.СчетПроживания.Контрагент IN HIERARCHY (&qCustomer)
//	|						OR (NOT &qFilterByCustomer))
//	|				AND (AccountsCurrentBalance.СчетПроживания.Договор = &qContract
//	|						OR (NOT &qFilterByContract))
//	|				AND (&qAll
//	|						OR &qNoDecisionYet
//	|							AND AccountsCurrentBalance.СчетПроживания.DebtDecision = &qEmptyDebtDecision
//	|						OR &qThereIsDecision
//	|							AND AccountsCurrentBalance.СчетПроживания.DebtDecision <> &qEmptyDebtDecision
//	|							AND ((NOT &qDebtDecisionIsFilled)
//	|								OR &qDebtDecisionIsFilled
//	|									AND AccountsCurrentBalance.СчетПроживания.DebtDecision IN HIERARCHY (&qDebtDecision)))
//	|			
//	|			UNION ALL
//	|			
//	|			SELECT
//	|				AccountsBalance.Гостиница,
//	|				AccountsBalance.ВалютаЛицСчета,
//	|				AccountsBalance.СчетПроживания,
//	|				AccountsBalance.PaymentSection,
//	|				AccountsBalance.SumBalance,
//	|				-AccountsBalance.LimitBalance,
//	|				0,
//	|				0
//	|			FROM
//	|				AccumulationRegister.Взаиморасчеты.Balance(
//	|						&qPeriodTo,
//	|						Гостиница IN HIERARCHY (&qHotel)
//	|							AND (ВалютаЛицСчета = &qFolioCurrency
//	|								OR &qFilterByFolioCurrency = FALSE)) AS AccountsBalance
//	|					INNER JOIN (SELECT
//	|						ServiceSalesMovements.СчетПроживания AS СчетПроживания
//	|					FROM
//	|						AccumulationRegister.Продажи AS ServiceSalesMovements
//	|					WHERE
//	|						&qServiceIsFilled
//	|						AND ServiceSalesMovements.Услуга IN HIERARCHY(&qService)
//	|					
//	|					GROUP BY
//	|						ServiceSalesMovements.СчетПроживания) AS ServiceSales
//	|					ON AccountsBalance.СчетПроживания = ServiceSales.СчетПроживания
//	|			WHERE
//	|				(AccountsBalance.СчетПроживания.НомерРазмещения IN HIERARCHY (&qRoom)
//	|						OR (NOT &qFilterByRoom))
//	|				AND (AccountsBalance.СчетПроживания.НомерРазмещения.ТипНомера IN HIERARCHY (&qRoomType)
//	|						OR (NOT &qFilterByRoomType))
//	|				AND (AccountsBalance.СчетПроживания.Контрагент IN HIERARCHY (&qCustomer)
//	|						OR (NOT &qFilterByCustomer))
//	|				AND (AccountsBalance.СчетПроживания.Договор = &qContract
//	|						OR (NOT &qFilterByContract))
//	|				AND (&qAll
//	|						OR &qNoDecisionYet
//	|							AND AccountsBalance.СчетПроживания.DebtDecision = &qEmptyDebtDecision
//	|						OR &qThereIsDecision
//	|							AND AccountsBalance.СчетПроживания.DebtDecision <> &qEmptyDebtDecision
//	|							AND ((NOT &qDebtDecisionIsFilled)
//	|								OR &qDebtDecisionIsFilled
//	|									AND AccountsBalance.СчетПроживания.DebtDecision IN HIERARCHY (&qDebtDecision)))
//	|			
//	|			UNION ALL
//	|			
//	|			SELECT
//	|				AccountsCurrentBalance.Гостиница,
//	|				AccountsCurrentBalance.ВалютаЛицСчета,
//	|				AccountsCurrentBalance.СчетПроживания,
//	|				AccountsCurrentBalance.PaymentSection,
//	|				0,
//	|				0,
//	|				AccountsCurrentBalance.SumBalance,
//	|				-AccountsCurrentBalance.LimitBalance
//	|			FROM
//	|				AccumulationRegister.Взаиморасчеты.Balance(
//	|						&qCurrentDate,
//	|						Гостиница IN HIERARCHY (&qHotel)
//	|							AND (ВалютаЛицСчета = &qFolioCurrency
//	|								OR &qFilterByFolioCurrency = FALSE)) AS AccountsCurrentBalance
//	|					INNER JOIN (SELECT
//	|						ServiceSalesMovements.СчетПроживания AS СчетПроживания
//	|					FROM
//	|						AccumulationRegister.Продажи AS ServiceSalesMovements
//	|					WHERE
//	|						&qServiceIsFilled
//	|						AND ServiceSalesMovements.Услуга IN HIERARCHY(&qService)
//	|					
//	|					GROUP BY
//	|						ServiceSalesMovements.СчетПроживания) AS ServiceSales
//	|					ON AccountsCurrentBalance.СчетПроживания = ServiceSales.СчетПроживания
//	|			WHERE
//	|				(AccountsCurrentBalance.СчетПроживания.НомерРазмещения IN HIERARCHY (&qRoom)
//	|						OR (NOT &qFilterByRoom))
//	|				AND (AccountsCurrentBalance.СчетПроживания.НомерРазмещения.ТипНомера IN HIERARCHY (&qRoomType)
//	|						OR (NOT &qFilterByRoomType))
//	|				AND (AccountsCurrentBalance.СчетПроживания.Контрагент IN HIERARCHY (&qCustomer)
//	|						OR (NOT &qFilterByCustomer))
//	|				AND (AccountsCurrentBalance.СчетПроживания.Договор = &qContract
//	|						OR (NOT &qFilterByContract))
//	|				AND (&qAll
//	|						OR &qNoDecisionYet
//	|							AND AccountsCurrentBalance.СчетПроживания.DebtDecision = &qEmptyDebtDecision
//	|						OR &qThereIsDecision
//	|							AND AccountsCurrentBalance.СчетПроживания.DebtDecision <> &qEmptyDebtDecision
//	|							AND ((NOT &qDebtDecisionIsFilled)
//	|								OR &qDebtDecisionIsFilled
//	|									AND AccountsCurrentBalance.СчетПроживания.DebtDecision IN HIERARCHY (&qDebtDecision)))) AS AccountsBalances
//	|		
//	|		GROUP BY
//	|			AccountsBalances.Гостиница,
//	|			AccountsBalances.ВалютаЛицСчета,
//	|			AccountsBalances.СчетПроживания,
//	|			AccountsBalances.PaymentSection) AS FolioBalances) AS Debts
//	|{WHERE
//	|	Debts.Гостиница.* AS Гостиница,
//	|	Debts.ВалютаЛицСчета.* AS ВалютаЛицСчета,
//	|	Debts.СчетПроживания AS СчетПроживания,
//	|	Debts.FolioDescription AS FolioDescription,
//	|	Debts.FolioCompany.* AS FolioCompany,
//	|	Debts.FolioIsClosed AS FolioIsClosed,
//	|	Debts.FolioParentDoc.* AS FolioParentDoc,
//	|	Debts.FolioCustomer.* AS FolioCustomer,
//	|	Debts.FolioContract.* AS FolioContract,
//	|	Debts.FolioAgent.* AS FolioAgent,
//	|	Debts.FolioClient.* AS FolioClient,
//	|	Debts.FolioGuestGroup.* AS FolioGuestGroup,
//	|	Debts.FolioRoom.* AS FolioRoom,
//	|	Debts.FolioDateTimeFrom AS FolioDateTimeFrom,
//	|	Debts.FolioDateTimeTo AS FolioDateTimeTo,
//	|	Debts.FolioRemarks AS FolioRemarks,
//	|	Debts.FolioAuthor.* AS FolioAuthor,
//	|	Debts.FolioPaymentSection.* AS FolioPaymentSection,
//	|	Debts.FolioPaymentMethod.* AS FolioPaymentMethod,
//	|	Debts.FolioIsMaster AS FolioIsMaster,
//	|	Debts.FolioRoomRoomType.* AS FolioRoomRoomType,
//	|	Debts.FolioDateTimeFromHour AS FolioDateTimeFromHour,
//	|	Debts.FolioDateTimeFromDay AS FolioDateTimeFromDay,
//	|	Debts.FolioDateTimeFromWeek AS FolioDateTimeFromWeek,
//	|	Debts.FolioDateTimeFromMonth AS FolioDateTimeFromMonth,
//	|	Debts.FolioDateTimeFromQuarter AS FolioDateTimeFromQuarter,
//	|	Debts.FolioDateTimeFromYear AS FolioDateTimeFromYear,
//	|	Debts.IsCustomerBalance AS IsCustomerBalance,
//	|	Debts.IsClientBalance AS IsClientBalance,
//	|	Debts.SumBalance AS SumBalance,
//	|	Debts.LimitBalance AS LimitBalance,
//	|	Debts.PlanBalance AS PlanBalance,
//	|	Debts.OverlimitBalance AS OverlimitBalance,
//	|	Debts.SumCurrentBalance AS SumCurrentBalance}
//	|
//	|ORDER BY
//	|	Гостиница,
//	|	ВалютаЛицСчета,
//	|	FolioRoom,
//	|	FolioDateTimeFrom,
//	|	FolioClient
//	|{ORDER BY
//	|	Гостиница.*,
//	|	СчетПроживания.*,
//	|	ВалютаЛицСчета.* AS ВалютаЛицСчета,
//	|	FolioDescription,
//	|	Debts.FolioCompany.* AS FolioCompany,
//	|	Debts.FolioIsClosed,
//	|	Debts.FolioParentDoc.*,
//	|	FolioCustomer.*,
//	|	Debts.FolioContract.*,
//	|	Debts.FolioAgent.*,
//	|	FolioClient.*,
//	|	FolioGuestGroup.*,
//	|	FolioRoom.*,
//	|	FolioDateTimeFrom,
//	|	FolioDateTimeTo,
//	|	FolioRemarks,
//	|	Debts.FolioAuthor.*,
//	|	Debts.FolioPaymentSection.*,
//	|	Debts.FolioPaymentMethod.*,
//	|	Debts.FolioIsMaster,
//	|	Debts.FolioRoomRoomType.*,
//	|	Debts.FolioDateTimeFromHour,
//	|	Debts.FolioDateTimeFromDay,
//	|	Debts.FolioDateTimeFromWeek,
//	|	Debts.FolioDateTimeFromMonth,
//	|	Debts.FolioDateTimeFromQuarter,
//	|	Debts.FolioDateTimeFromYear,
//	|	Debts.IsCustomerBalance AS IsCustomerBalance,
//	|	Debts.IsClientBalance AS IsClientBalance,
//	|	SumBalance AS SumBalance,
//	|	LimitBalance AS LimitBalance,
//	|	PlanBalance AS PlanBalance,
//	|	OverlimitBalance AS OverlimitBalance,
//	|	SumCurrentBalance AS SumCurrentBalance}
//	|TOTALS
//	|	SUM(SumBalance),
//	|	SUM(CustomerSumBalance),
//	|	SUM(ClientSumBalance),
//	|	SUM(LimitBalance),
//	|	SUM(PlanBalance),
//	|	SUM(OverlimitBalance),
//	|	SUM(SumCurrentBalance)
//	|BY
//	|	Гостиница,
//	|	ВалютаЛицСчета,
//	|	FolioRoom,
//	|	СчетПроживания
//	|{TOTALS BY
//	|	Гостиница.*,
//	|	СчетПроживания.*,
//	|	ВалютаЛицСчета.* AS ВалютаЛицСчета,
//	|	FolioDescription,
//	|	Debts.FolioCompany.*,
//	|	Debts.FolioIsClosed,
//	|	Debts.FolioParentDoc.*,
//	|	FolioCustomer.*,
//	|	Debts.FolioContract.*,
//	|	Debts.FolioAgent.*,
//	|	FolioClient.*,
//	|	FolioGuestGroup.*,
//	|	FolioRoom.*,
//	|	FolioDateTimeFrom,
//	|	FolioDateTimeTo,
//	|	Debts.IsCustomerBalance AS IsCustomerBalance,
//	|	Debts.IsClientBalance AS IsClientBalance,
//	|	Debts.FolioAuthor.*,
//	|	Debts.FolioPaymentSection.*,
//	|	Debts.FolioPaymentMethod.*,
//	|	Debts.FolioIsMaster,
//	|	Debts.FolioDateTimeFromHour,
//	|	Debts.FolioDateTimeFromDay,
//	|	Debts.FolioDateTimeFromWeek,
//	|	Debts.FolioDateTimeFromMonth,
//	|	Debts.FolioDateTimeFromQuarter,
//	|	Debts.FolioDateTimeFromYear,
//	|	Debts.FolioRoomRoomType.*}";
//	ReportBuilder.Text = QueryText;
//	ReportBuilder.FillSettings();
//	
//	// Initialize report builder with default query
//	vRB = New ReportBuilder(QueryText);
//	vRBSettings = vRB.GetSettings(True, True, True, True, True);
//	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
//	
//	// Set default report builder header text
//	ReportBuilder.HeaderText = NStr("EN='Debtors';RU='Должники';de='Zahlungspflichtige'");
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
