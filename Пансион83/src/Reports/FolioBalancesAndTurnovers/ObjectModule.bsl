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
	If ЗначениеЗаполнено(GuestGroup) Тогда
		vParamPresentation = vParamPresentation + NStr("en='Guest group ';ru='Группа ';de='Gruppe '") + 
		                     TrimAll(GuestGroup.Code) + " " + TrimAll(GuestGroup.Description) + 
		                     ";" + Chars.LF;
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
	If ЗначениеЗаполнено(FolioCurrency) Тогда
		vParamPresentation = vParamPresentation + NStr("ru = 'Валюта фолио '; en = 'ЛицевойСчет currency '") + 
							 TrimAll(FolioCurrency.Description) + 
							 ";" + Chars.LF;
	EndIf;
	Return vParamPresentation;
EndFunction //pmGetReportParametersPresentation

//-----------------------------------------------------------------------------
// Runs report and returns if report form should be shown
//-----------------------------------------------------------------------------
Процедура pmGenerate(pSpreadsheet) Экспорт
	
	
	// Reset report builder template
	ReportBuilder.Template = Неопределено;
	
	// Initialize report builder query generator attributes
	ReportBuilder.PresentationAdding = PresentationAdditionType.Add;
	
	// Fill report parameters
	ReportBuilder.Parameters.Вставить("qHotel", Гостиница);
	ReportBuilder.Parameters.Вставить("qPeriodFrom", PeriodFrom);
	ReportBuilder.Parameters.Вставить("qPeriodTo", ?(ЗначениеЗаполнено(PeriodTo), PeriodTo, '39991231235959'));
	ReportBuilder.Parameters.Вставить("qRoomType", RoomType);
	ReportBuilder.Parameters.Вставить("qFilterByRoomType", ЗначениеЗаполнено(RoomType));
	ReportBuilder.Parameters.Вставить("qCustomer", Customer);
	ReportBuilder.Parameters.Вставить("qFilterByCustomer", ЗначениеЗаполнено(Customer));
	ReportBuilder.Parameters.Вставить("qEmptyCustomer", Справочники.Контрагенты.EmptyRef());
	ReportBuilder.Parameters.Вставить("qIndividualsCustomer", ?(ЗначениеЗаполнено(Гостиница), Гостиница.IndividualsCustomer, Справочники.Контрагенты.EmptyRef()));
	ReportBuilder.Parameters.Вставить("qIndividualsCustomerFolder", Справочники.Контрагенты.КонтрагентПоУмолчанию);
	ReportBuilder.Parameters.Вставить("qContract", Contract);
	ReportBuilder.Parameters.Вставить("qFilterByContract", ЗначениеЗаполнено(Contract));
	ReportBuilder.Parameters.Вставить("qGuestGroup", GuestGroup);
	ReportBuilder.Parameters.Вставить("qFilterByGuestGroup", ЗначениеЗаполнено(GuestGroup));
	ReportBuilder.Parameters.Вставить("qFolioCurrency", FolioCurrency);
	ReportBuilder.Parameters.Вставить("qFilterByFolioCurrency", ЗначениеЗаполнено(FolioCurrency));

	// Execute report builder query
	ReportBuilder.Execute();
	//Message(ReportBuilder.GetQuery().Text); // For debug purpose
	
	// Apply appearance settings to the report template
	//vTemplateAttributes = cmApplyReportTemplateAppearance(ThisObject);
	
	// Output report to the spreadsheet
	ReportBuilder.Put(pSpreadsheet);
	//ReportBuilder.Template.Show(); // For debug purpose

	// Apply appearance settings to the report spreadsheet
	//cmApplyReportAppearance(ThisObject, pSpreadsheet, vTemplateAttributes);
КонецПроцедуры //pmGenerate

//-----------------------------------------------------------------------------
Процедура pmInitializeReportBuilder() Экспорт
	ReportBuilder = New ReportBuilder();
	
	// Initialize default query text
	QueryText = 
	"SELECT
	|	FolioBalancesAndTurnovers.Гостиница AS Гостиница,
	|	FolioBalancesAndTurnovers.ВалютаЛицСчета AS ВалютаЛицСчета,
	|	FolioBalancesAndTurnovers.PaymentSection AS PaymentSection,
	|	FolioBalancesAndTurnovers.СчетПроживания.PaymentSection AS FolioPaymentSection,
	|	FolioBalancesAndTurnovers.СчетПроживания.СпособОплаты AS FolioPaymentMethod,
	|	FolioBalancesAndTurnovers.СчетПроживания.Контрагент AS FolioCustomer,
	|	FolioBalancesAndTurnovers.СчетПроживания.Договор AS FolioContract,
	|	FolioBalancesAndTurnovers.СчетПроживания.ГруппаГостей AS FolioGuestGroup,
	|	FolioBalancesAndTurnovers.СчетПроживания.Клиент AS FolioClient,
	|	CASE
	|		WHEN FolioBalancesAndTurnovers.СчетПроживания.Контрагент <> &qEmptyCustomer
	|				AND FolioBalancesAndTurnovers.СчетПроживания.Контрагент <> &qIndividualsCustomer
	|				AND NOT FolioBalancesAndTurnovers.СчетПроживания.Контрагент IN HIERARCHY (&qIndividualsCustomerFolder)
	|			THEN TRUE
	|		ELSE FALSE
	|	END AS IsCustomerBalance,
	|	CASE
	|		WHEN FolioBalancesAndTurnovers.СчетПроживания.Контрагент <> &qEmptyCustomer
	|				AND FolioBalancesAndTurnovers.СчетПроживания.Контрагент <> &qIndividualsCustomer
	|				AND NOT FolioBalancesAndTurnovers.СчетПроживания.Контрагент IN HIERARCHY (&qIndividualsCustomerFolder)
	|			THEN FALSE
	|		ELSE TRUE
	|	END AS IsClientBalance,
	|	FolioBalancesAndTurnovers.SumOpeningBalance AS SumOpeningBalance,
	|	CASE
	|		WHEN FolioBalancesAndTurnovers.СчетПроживания.Контрагент <> &qEmptyCustomer
	|				AND FolioBalancesAndTurnovers.СчетПроживания.Контрагент <> &qIndividualsCustomer
	|				AND NOT FolioBalancesAndTurnovers.СчетПроживания.Контрагент IN HIERARCHY (&qIndividualsCustomerFolder)
	|			THEN FolioBalancesAndTurnovers.SumOpeningBalance
	|		ELSE 0
	|	END AS CustomerSumOpeningBalance,
	|	CASE
	|		WHEN FolioBalancesAndTurnovers.СчетПроживания.Контрагент <> &qEmptyCustomer
	|				AND FolioBalancesAndTurnovers.СчетПроживания.Контрагент <> &qIndividualsCustomer
	|				AND NOT FolioBalancesAndTurnovers.СчетПроживания.Контрагент IN HIERARCHY (&qIndividualsCustomerFolder)
	|			THEN 0
	|		ELSE FolioBalancesAndTurnovers.SumOpeningBalance
	|	END AS ClientSumOpeningBalance,
	|	FolioBalancesAndTurnovers.SumClosingBalance AS SumClosingBalance,
	|	CASE
	|		WHEN FolioBalancesAndTurnovers.СчетПроживания.Контрагент <> &qEmptyCustomer
	|				AND FolioBalancesAndTurnovers.СчетПроживания.Контрагент <> &qIndividualsCustomer
	|				AND NOT FolioBalancesAndTurnovers.СчетПроживания.Контрагент IN HIERARCHY (&qIndividualsCustomerFolder)
	|			THEN FolioBalancesAndTurnovers.SumClosingBalance
	|		ELSE 0
	|	END AS CustomerSumClosingBalance,
	|	CASE
	|		WHEN FolioBalancesAndTurnovers.СчетПроживания.Контрагент <> &qEmptyCustomer
	|				AND FolioBalancesAndTurnovers.СчетПроживания.Контрагент <> &qIndividualsCustomer
	|				AND NOT FolioBalancesAndTurnovers.СчетПроживания.Контрагент IN HIERARCHY (&qIndividualsCustomerFolder)
	|			THEN 0
	|		ELSE FolioBalancesAndTurnovers.SumClosingBalance
	|	END AS ClientSumClosingBalance,
	|	FolioBalancesAndTurnovers.SumReceipt AS SumReceipt,
	|	CASE
	|		WHEN FolioBalancesAndTurnovers.СчетПроживания.Контрагент <> &qEmptyCustomer
	|				AND FolioBalancesAndTurnovers.СчетПроживания.Контрагент <> &qIndividualsCustomer
	|				AND NOT FolioBalancesAndTurnovers.СчетПроживания.Контрагент IN HIERARCHY (&qIndividualsCustomerFolder)
	|			THEN FolioBalancesAndTurnovers.SumReceipt
	|		ELSE 0
	|	END AS CustomerSumReceipt,
	|	CASE
	|		WHEN FolioBalancesAndTurnovers.СчетПроживания.Контрагент <> &qEmptyCustomer
	|				AND FolioBalancesAndTurnovers.СчетПроживания.Контрагент <> &qIndividualsCustomer
	|				AND NOT FolioBalancesAndTurnovers.СчетПроживания.Контрагент IN HIERARCHY (&qIndividualsCustomerFolder)
	|			THEN 0
	|		ELSE FolioBalancesAndTurnovers.SumReceipt
	|	END AS ClientSumReceipt,
	|	FolioBalancesAndTurnovers.SumExpense AS SumExpense,
	|	CASE
	|		WHEN FolioBalancesAndTurnovers.СчетПроживания.Контрагент <> &qEmptyCustomer
	|				AND FolioBalancesAndTurnovers.СчетПроживания.Контрагент <> &qIndividualsCustomer
	|				AND NOT FolioBalancesAndTurnovers.СчетПроживания.Контрагент IN HIERARCHY (&qIndividualsCustomerFolder)
	|			THEN FolioBalancesAndTurnovers.SumExpense
	|		ELSE 0
	|	END AS CustomerSumExpense,
	|	CASE
	|		WHEN FolioBalancesAndTurnovers.СчетПроживания.Контрагент <> &qEmptyCustomer
	|				AND FolioBalancesAndTurnovers.СчетПроживания.Контрагент <> &qIndividualsCustomer
	|				AND NOT FolioBalancesAndTurnovers.СчетПроживания.Контрагент IN HIERARCHY (&qIndividualsCustomerFolder)
	|			THEN 0
	|		ELSE FolioBalancesAndTurnovers.SumExpense
	|	END AS ClientSumExpense,
	|	FolioBalancesAndTurnovers.LimitOpeningBalance AS LimitOpeningBalance,
	|	FolioBalancesAndTurnovers.LimitExpense AS LimitExpense,
	|	FolioBalancesAndTurnovers.LimitReceipt AS LimitReceipt,
	|	FolioBalancesAndTurnovers.LimitClosingBalance AS LimitClosingBalance
	|{SELECT
	|	Гостиница.*,
	|	ВалютаЛицСчета.* AS ВалютаЛицСчета,
	|	PaymentSection.* AS PaymentSection,
	|	FolioPaymentSection.* AS FolioPaymentSection,
	|	FolioPaymentMethod.* AS FolioPaymentMethod,
	|	FolioCustomer.* AS FolioCustomer,
	|	FolioContract.* AS FolioContract,
	|	FolioGuestGroup.* AS FolioGuestGroup,
	|	FolioBalancesAndTurnovers.СчетПроживания.Агент.* AS FolioAgent,
	|	FolioClient.* AS FolioClient,
	|	FolioBalancesAndTurnovers.СчетПроживания.* AS FolioRef,
	|	FolioBalancesAndTurnovers.СчетПроживания.Description AS FolioDescription,
	|	FolioBalancesAndTurnovers.СчетПроживания.Примечания AS FolioRemarks,
	|	FolioBalancesAndTurnovers.СчетПроживания.DateTimeFrom AS FolioDateTimeFrom,
	|	FolioBalancesAndTurnovers.СчетПроживания.DateTimeTo AS FolioDateTimeTo,
	|	FolioBalancesAndTurnovers.СчетПроживания.ДокОснование.* AS FolioParentDoc,
	|	FolioBalancesAndTurnovers.СчетПроживания.Фирма.* AS FolioCompany,
	|	FolioBalancesAndTurnovers.СчетПроживания.НомерРазмещения.ТипНомера.* AS FolioRoomRoomType,
	|	FolioBalancesAndTurnovers.СчетПроживания.НомерРазмещения.* AS FolioRoom,
	|	FolioBalancesAndTurnovers.СчетПроживания.Автор.* AS FolioAuthor,
	|	FolioBalancesAndTurnovers.СчетПроживания.IsMaster AS FolioIsMaster,
	|	FolioBalancesAndTurnovers.СчетПроживания.IsClosed AS FolioIsClosed,
	|	SumOpeningBalance AS SumOpeningBalance,
	|	CustomerSumOpeningBalance AS CustomerSumOpeningBalance,
	|	ClientSumOpeningBalance AS ClientSumOpeningBalance,
	|	SumReceipt AS SumReceipt,
	|	CustomerSumReceipt AS CustomerSumReceipt,
	|	ClientSumReceipt AS ClientSumReceipt,
	|	SumExpense AS SumExpense,
	|	CustomerSumExpense AS CustomerSumExpense,
	|	ClientSumExpense AS ClientSumExpense,
	|	SumClosingBalance AS SumClosingBalance,
	|	CustomerSumClosingBalance AS CustomerSumClosingBalance,
	|	ClientSumClosingBalance AS ClientSumClosingBalance,
	|	LimitOpeningBalance AS LimitOpeningBalance,
	|	LimitReceipt AS LimitReceipt,
	|	LimitExpense AS LimitExpense,
	|	LimitClosingBalance AS LimitClosingBalance}
	|FROM
	|	AccumulationRegister.Взаиморасчеты.BalanceAndTurnovers(
	|			&qPeriodFrom,
	|			&qPeriodTo,
	|			Period,
	|			RegisterRecordsAndPeriodBoundaries,
	|			Гостиница IN HIERARCHY (&qHotel)
	|				AND (ВалютаЛицСчета = &qFolioCurrency
	|					OR NOT &qFilterByFolioCurrency)
	|				AND (СчетПроживания.НомерРазмещения.ТипНомера IN HIERARCHY (&qRoomType)
	|					OR NOT &qFilterByRoomType)
	|				AND (СчетПроживания.ГруппаГостей = &qGuestGroup
	|					OR NOT &qFilterByGuestGroup)
	|				AND (СчетПроживания.Контрагент IN HIERARCHY (&qCustomer)
	|					OR NOT &qFilterByCustomer)
	|				AND (СчетПроживания.Договор = &qContract
	|					OR NOT &qFilterByContract)) AS FolioBalancesAndTurnovers
	|{WHERE
	|	FolioBalancesAndTurnovers.Гостиница.* AS Гостиница,
	|	FolioBalancesAndTurnovers.ВалютаЛицСчета.* AS ВалютаЛицСчета,
	|	FolioBalancesAndTurnovers.PaymentSection.* AS PaymentSection,
	|	FolioBalancesAndTurnovers.СчетПроживания.PaymentSection.* AS FolioPaymentSection,
	|	FolioBalancesAndTurnovers.СчетПроживания.СпособОплаты.* AS FolioPaymentMethod,
	|	FolioBalancesAndTurnovers.СчетПроживания.* AS FolioRef,
	|	FolioBalancesAndTurnovers.СчетПроживания.Description AS FolioDescription,
	|	FolioBalancesAndTurnovers.СчетПроживания.Примечания AS FolioRemarks,
	|	FolioBalancesAndTurnovers.СчетПроживания.Фирма.* AS FolioCompany,
	|	FolioBalancesAndTurnovers.СчетПроживания.ДокОснование.* AS FolioParentDoc,
	|	FolioBalancesAndTurnovers.СчетПроживания.Контрагент.* AS FolioCustomer,
	|	FolioBalancesAndTurnovers.СчетПроживания.Договор.* AS FolioContract,
	|	FolioBalancesAndTurnovers.СчетПроживания.Агент.* AS FolioAgent,
	|	FolioBalancesAndTurnovers.СчетПроживания.Клиент.* AS FolioClient,
	|	FolioBalancesAndTurnovers.СчетПроживания.ГруппаГостей.* AS FolioGuestGroup,
	|	FolioBalancesAndTurnovers.СчетПроживания.НомерРазмещения.* AS FolioRoom,
	|	FolioBalancesAndTurnovers.СчетПроживания.НомерРазмещения.ТипНомера.* AS FolioRoomRoomType,
	|	FolioBalancesAndTurnovers.СчетПроживания.DateTimeFrom AS FolioDateTimeFrom,
	|	FolioBalancesAndTurnovers.СчетПроживания.DateTimeTo AS FolioDateTimeTo,
	|	FolioBalancesAndTurnovers.СчетПроживания.Примечания AS FolioRemarks,
	|	FolioBalancesAndTurnovers.СчетПроживания.Автор.* AS FolioAuthor,
	|	FolioBalancesAndTurnovers.СчетПроживания.IsMaster AS FolioIsMaster,
	|	FolioBalancesAndTurnovers.СчетПроживания.IsClosed AS FolioIsClosed,
	|	(CASE
	|			WHEN FolioBalancesAndTurnovers.СчетПроживания.Контрагент <> &qEmptyCustomer
	|					AND FolioBalancesAndTurnovers.СчетПроживания.Контрагент <> &qIndividualsCustomer
	|					AND NOT FolioBalancesAndTurnovers.СчетПроживания.Контрагент IN HIERARCHY (&qIndividualsCustomerFolder)
	|				THEN TRUE
	|			ELSE FALSE
	|		END) AS IsCustomerBalance,
	|	(CASE
	|			WHEN FolioBalancesAndTurnovers.СчетПроживания.Контрагент <> &qEmptyCustomer
	|					AND FolioBalancesAndTurnovers.СчетПроживания.Контрагент <> &qIndividualsCustomer
	|					AND NOT FolioBalancesAndTurnovers.СчетПроживания.Контрагент IN HIERARCHY (&qIndividualsCustomerFolder)
	|				THEN FALSE
	|			ELSE TRUE
	|		END) AS IsClientBalance,
	|	FolioBalancesAndTurnovers.SumOpeningBalance AS SumOpeningBalance,
	|	(CASE
	|			WHEN FolioBalancesAndTurnovers.СчетПроживания.Контрагент <> &qEmptyCustomer
	|					AND FolioBalancesAndTurnovers.СчетПроживания.Контрагент <> &qIndividualsCustomer
	|					AND NOT FolioBalancesAndTurnovers.СчетПроживания.Контрагент IN HIERARCHY (&qIndividualsCustomerFolder)
	|				THEN FolioBalancesAndTurnovers.SumOpeningBalance
	|			ELSE 0
	|		END) AS CustomerSumOpeningBalance,
	|	(CASE
	|			WHEN FolioBalancesAndTurnovers.СчетПроживания.Контрагент <> &qEmptyCustomer
	|					AND FolioBalancesAndTurnovers.СчетПроживания.Контрагент <> &qIndividualsCustomer
	|					AND NOT FolioBalancesAndTurnovers.СчетПроживания.Контрагент IN HIERARCHY (&qIndividualsCustomerFolder)
	|				THEN 0
	|			ELSE FolioBalancesAndTurnovers.SumOpeningBalance
	|		END) AS ClientSumOpeningBalance,
	|	FolioBalancesAndTurnovers.SumClosingBalance AS SumClosingBalance,
	|	(CASE
	|			WHEN FolioBalancesAndTurnovers.СчетПроживания.Контрагент <> &qEmptyCustomer
	|					AND FolioBalancesAndTurnovers.СчетПроживания.Контрагент <> &qIndividualsCustomer
	|					AND NOT FolioBalancesAndTurnovers.СчетПроживания.Контрагент IN HIERARCHY (&qIndividualsCustomerFolder)
	|				THEN FolioBalancesAndTurnovers.SumClosingBalance
	|			ELSE 0
	|		END) AS CustomerSumClosingBalance,
	|	(CASE
	|			WHEN FolioBalancesAndTurnovers.СчетПроживания.Контрагент <> &qEmptyCustomer
	|					AND FolioBalancesAndTurnovers.СчетПроживания.Контрагент <> &qIndividualsCustomer
	|					AND NOT FolioBalancesAndTurnovers.СчетПроживания.Контрагент IN HIERARCHY (&qIndividualsCustomerFolder)
	|				THEN 0
	|			ELSE FolioBalancesAndTurnovers.SumClosingBalance
	|		END) AS ClientSumClosingBalance,
	|	FolioBalancesAndTurnovers.SumReceipt AS SumReceipt,
	|	(CASE
	|			WHEN FolioBalancesAndTurnovers.СчетПроживания.Контрагент <> &qEmptyCustomer
	|					AND FolioBalancesAndTurnovers.СчетПроживания.Контрагент <> &qIndividualsCustomer
	|					AND NOT FolioBalancesAndTurnovers.СчетПроживания.Контрагент IN HIERARCHY (&qIndividualsCustomerFolder)
	|				THEN FolioBalancesAndTurnovers.SumReceipt
	|			ELSE 0
	|		END) AS CustomerSumReceipt,
	|	(CASE
	|			WHEN FolioBalancesAndTurnovers.СчетПроживания.Контрагент <> &qEmptyCustomer
	|					AND FolioBalancesAndTurnovers.СчетПроживания.Контрагент <> &qIndividualsCustomer
	|					AND NOT FolioBalancesAndTurnovers.СчетПроживания.Контрагент IN HIERARCHY (&qIndividualsCustomerFolder)
	|				THEN 0
	|			ELSE FolioBalancesAndTurnovers.SumReceipt
	|		END) AS ClientSumReceipt,
	|	FolioBalancesAndTurnovers.SumExpense AS SumExpense,
	|	(CASE
	|			WHEN FolioBalancesAndTurnovers.СчетПроживания.Контрагент <> &qEmptyCustomer
	|					AND FolioBalancesAndTurnovers.СчетПроживания.Контрагент <> &qIndividualsCustomer
	|					AND NOT FolioBalancesAndTurnovers.СчетПроживания.Контрагент IN HIERARCHY (&qIndividualsCustomerFolder)
	|				THEN FolioBalancesAndTurnovers.SumExpense
	|			ELSE 0
	|		END) AS CustomerSumExpense,
	|	(CASE
	|			WHEN FolioBalancesAndTurnovers.СчетПроживания.Контрагент <> &qEmptyCustomer
	|					AND FolioBalancesAndTurnovers.СчетПроживания.Контрагент <> &qIndividualsCustomer
	|					AND NOT FolioBalancesAndTurnovers.СчетПроживания.Контрагент IN HIERARCHY (&qIndividualsCustomerFolder)
	|				THEN 0
	|			ELSE FolioBalancesAndTurnovers.SumExpense
	|		END) AS ClientSumExpense,
	|	FolioBalancesAndTurnovers.LimitOpeningBalance AS LimitOpeningBalance,
	|	FolioBalancesAndTurnovers.LimitExpense AS LimitExpense,
	|	FolioBalancesAndTurnovers.LimitReceipt AS LimitReceipt,
	|	FolioBalancesAndTurnovers.LimitClosingBalance AS LimitClosingBalance}
	|
	|ORDER BY
	|	Гостиница,
	|	ВалютаЛицСчета,
	|	FolioPaymentSection
	|{ORDER BY
	|	Гостиница.*,
	|	ВалютаЛицСчета.* AS ВалютаЛицСчета,
	|	PaymentSection.* AS PaymentSection,
	|	FolioPaymentSection.* AS FolioPaymentSection,
	|	FolioPaymentMethod.* AS FolioPaymentMethod,
	|	FolioCustomer.* AS FolioCustomer,
	|	FolioContract.* AS FolioContract,
	|	FolioGuestGroup.* AS FolioGuestGroup,
	|	FolioBalancesAndTurnovers.СчетПроживания.Агент.* AS FolioAgent,
	|	FolioClient.* AS FolioClient,
	|	FolioBalancesAndTurnovers.СчетПроживания.* AS FolioRef,
	|	FolioBalancesAndTurnovers.СчетПроживания.Description AS FolioDescription,
	|	FolioBalancesAndTurnovers.СчетПроживания.Примечания AS FolioRemarks,
	|	FolioBalancesAndTurnovers.СчетПроживания.DateTimeFrom AS FolioDateTimeFrom,
	|	FolioBalancesAndTurnovers.СчетПроживания.DateTimeTo AS FolioDateTimeTo,
	|	FolioBalancesAndTurnovers.СчетПроживания.ДокОснование.* AS FolioParentDoc,
	|	FolioBalancesAndTurnovers.СчетПроживания.Фирма.* AS FolioCompany,
	|	FolioBalancesAndTurnovers.СчетПроживания.НомерРазмещения.ТипНомера.* AS FolioRoomRoomType,
	|	FolioBalancesAndTurnovers.СчетПроживания.НомерРазмещения.* AS FolioRoom,
	|	FolioBalancesAndTurnovers.СчетПроживания.Автор.* AS FolioAuthor,
	|	FolioBalancesAndTurnovers.СчетПроживания.IsMaster AS FolioIsMaster,
	|	FolioBalancesAndTurnovers.СчетПроживания.IsClosed AS FolioIsClosed,
	|	SumOpeningBalance AS SumOpeningBalance,
	|	CustomerSumOpeningBalance AS CustomerSumOpeningBalance,
	|	ClientSumOpeningBalance AS ClientSumOpeningBalance,
	|	SumReceipt AS SumReceipt,
	|	CustomerSumReceipt AS CustomerSumReceipt,
	|	ClientSumReceipt AS ClientSumReceipt,
	|	SumExpense AS SumExpense,
	|	CustomerSumExpense AS CustomerSumExpense,
	|	ClientSumExpense AS ClientSumExpense,
	|	SumClosingBalance AS SumClosingBalance,
	|	CustomerSumClosingBalance AS CustomerSumClosingBalance,
	|	ClientSumClosingBalance AS ClientSumClosingBalance,
	|	LimitOpeningBalance AS LimitOpeningBalance,
	|	LimitReceipt AS LimitReceipt,
	|	LimitExpense AS LimitExpense,
	|	LimitClosingBalance AS LimitClosingBalance}
	|TOTALS
	|	SUM(SumOpeningBalance),
	|	SUM(CustomerSumOpeningBalance),
	|	SUM(ClientSumOpeningBalance),
	|	SUM(SumClosingBalance),
	|	SUM(CustomerSumClosingBalance),
	|	SUM(ClientSumClosingBalance),
	|	SUM(SumReceipt),
	|	SUM(CustomerSumReceipt),
	|	SUM(ClientSumReceipt),
	|	SUM(SumExpense),
	|	SUM(CustomerSumExpense),
	|	SUM(ClientSumExpense),
	|	SUM(LimitOpeningBalance),
	|	SUM(LimitExpense),
	|	SUM(LimitReceipt),
	|	SUM(LimitClosingBalance)
	|BY
	|	OVERALL,
	|	Гостиница,
	|	ВалютаЛицСчета,
	|	FolioPaymentSection
	|{TOTALS BY
	|	Гостиница.*,
	|	ВалютаЛицСчета.* AS ВалютаЛицСчета,
	|	PaymentSection.* AS PaymentSection,
	|	FolioPaymentSection.* AS FolioPaymentSection,
	|	FolioPaymentMethod.* AS FolioPaymentMethod,
	|	FolioCustomer.* AS FolioCustomer,
	|	FolioContract.* AS FolioContract,
	|	FolioGuestGroup.* AS FolioGuestGroup,
	|	FolioBalancesAndTurnovers.СчетПроживания.Агент.* AS FolioAgent,
	|	FolioClient.* AS FolioClient,
	|	FolioBalancesAndTurnovers.СчетПроживания.* AS FolioRef,
	|	FolioBalancesAndTurnovers.СчетПроживания.ДокОснование.* AS FolioParentDoc,
	|	FolioBalancesAndTurnovers.СчетПроживания.Фирма.* AS FolioCompany,
	|	FolioBalancesAndTurnovers.СчетПроживания.НомерРазмещения.ТипНомера.* AS FolioRoomRoomType,
	|	FolioBalancesAndTurnovers.СчетПроживания.НомерРазмещения.* AS FolioRoom,
	|	FolioBalancesAndTurnovers.СчетПроживания.Автор.* AS FolioAuthor,
	|	FolioBalancesAndTurnovers.СчетПроживания.IsMaster AS FolioIsMaster,
	|	FolioBalancesAndTurnovers.СчетПроживания.IsClosed AS FolioIsClosed}";
	ReportBuilder.Text = QueryText;
	ReportBuilder.FillSettings();
	
	// Initialize report builder with default query
	vRB = New ReportBuilder(QueryText);
	vRBSettings = vRB.GetSettings(True, True, True, True, True);
	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
	
	// Set default report builder header text
	ReportBuilder.HeaderText = NStr("EN='ЛицевойСчет balances and turnovers';RU='Остатки и обороты по лицевым счетам';de='Restbestände und Umsätze nach Personenkonten'");
	
	// Fill report builder fields presentations from the report template
	//cmFillReportAttributesPresentations(ThisObject);
	
	// Reset report builder template
	ReportBuilder.Template = Неопределено;
КонецПроцедуры //pmInitializeReportBuilder

//-----------------------------------------------------------------------------
// Reports framework end
//-----------------------------------------------------------------------------
