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
	ReportBuilder.Parameters.Вставить("qEmptyDate", '00010101');
	ReportBuilder.Parameters.Вставить("qRoomType", RoomType);
	ReportBuilder.Parameters.Вставить("qFilterByRoomType", ЗначениеЗаполнено(RoomType));
	ReportBuilder.Parameters.Вставить("qRoom", Room);
	ReportBuilder.Parameters.Вставить("qFilterByRoom", ЗначениеЗаполнено(Room));
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
	|	Folios.Ref AS СчетПроживания
	|INTO Folios
	|FROM
	|	Document.СчетПроживания AS Folios
	|WHERE
	|	NOT Folios.DeletionMark
	|	AND (Folios.DateTimeFrom < &qPeriodTo
	|			OR &qPeriodTo = &qEmptyDate
	|			OR Folios.DateTimeFrom = &qEmptyDate)
	|	AND (Folios.DateTimeTo > &qPeriodFrom
	|			OR &qPeriodFrom = &qEmptyDate
	|			OR Folios.DateTimeTo = &qEmptyDate)
	|	AND Folios.Гостиница IN HIERARCHY(&qHotel)
	|	AND (Folios.ВалютаЛицСчета = &qFolioCurrency
	|			OR NOT &qFilterByFolioCurrency)
	|	AND (Folios.НомерРазмещения IN HIERARCHY (&qRoom)
	|			OR NOT &qFilterByRoom)
	|	AND (Folios.НомерРазмещения.ТипНомера IN HIERARCHY (&qRoomType)
	|			OR NOT &qFilterByRoomType)
	|	AND (Folios.ГруппаГостей = &qGuestGroup
	|			OR NOT &qFilterByGuestGroup)
	|	AND (Folios.Контрагент IN HIERARCHY (&qCustomer)
	|			OR NOT &qFilterByCustomer)
	|	AND (Folios.Договор = &qContract
	|			OR NOT &qFilterByContract)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	FolioBalances.СчетПроживания AS СчетПроживания,
	|	CASE
	|		WHEN FolioBalances.СчетПроживания.Контрагент <> &qEmptyCustomer
	|				AND FolioBalances.СчетПроживания.Контрагент <> &qIndividualsCustomer
	|				AND NOT FolioBalances.СчетПроживания.Контрагент IN HIERARCHY (&qIndividualsCustomerFolder)
	|			THEN TRUE
	|		ELSE FALSE
	|	END AS IsCustomerBalance,
	|	CASE
	|		WHEN FolioBalances.СчетПроживания.Контрагент <> &qEmptyCustomer
	|				AND FolioBalances.СчетПроживания.Контрагент <> &qIndividualsCustomer
	|				AND NOT FolioBalances.СчетПроживания.Контрагент IN HIERARCHY (&qIndividualsCustomerFolder)
	|			THEN FALSE
	|		ELSE TRUE
	|	END AS IsClientBalance,
	|	FolioBalances.SumBalance AS SumBalance,
	|	CASE
	|		WHEN FolioBalances.СчетПроживания.Контрагент <> &qEmptyCustomer
	|				AND FolioBalances.СчетПроживания.Контрагент <> &qIndividualsCustomer
	|				AND NOT FolioBalances.СчетПроживания.Контрагент IN HIERARCHY (&qIndividualsCustomerFolder)
	|			THEN FolioBalances.SumBalance
	|		ELSE 0
	|	END AS CustomerSumBalance,
	|	CASE
	|		WHEN FolioBalances.СчетПроживания.Контрагент <> &qEmptyCustomer
	|				AND FolioBalances.СчетПроживания.Контрагент <> &qIndividualsCustomer
	|				AND NOT FolioBalances.СчетПроживания.Контрагент IN HIERARCHY (&qIndividualsCustomerFolder)
	|			THEN 0
	|		ELSE FolioBalances.SumBalance
	|	END AS ClientSumBalance,
	|	FolioBalances.LimitBalance AS LimitBalance
	|INTO FolioBalances
	|FROM
	|	AccumulationRegister.Взаиморасчеты.Balance(
	|			,
	|			СчетПроживания IN
	|				(SELECT
	|					Folios.СчетПроживания
	|				FROM
	|					Folios AS Folios)) AS FolioBalances
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|SELECT
	|	FoliosList.СчетПроживания.Гостиница AS Гостиница,
	|	FoliosList.СчетПроживания.ВалютаЛицСчета AS ВалютаЛицСчета,
	|	FoliosList.СчетПроживания.PaymentSection AS FolioPaymentSection,
	|	FoliosList.СчетПроживания.СпособОплаты AS FolioPaymentMethod,
	|	FoliosList.СчетПроживания.Контрагент AS FolioCustomer,
	|	FoliosList.СчетПроживания.Договор AS FolioContract,
	|	FoliosList.СчетПроживания.ГруппаГостей AS FolioGuestGroup,
	|	FoliosList.СчетПроживания.Клиент AS FolioClient,
	|	ISNULL(FolioBalances.IsCustomerBalance, FALSE) AS IsCustomerBalance,
	|	ISNULL(FolioBalances.IsClientBalance, TRUE) AS IsClientBalance,
	|	ISNULL(FolioBalances.SumBalance, 0) AS SumBalance,
	|	ISNULL(FolioBalances.CustomerSumBalance, 0) AS CustomerSumBalance,
	|	ISNULL(FolioBalances.ClientSumBalance, 0) AS ClientSumBalance,
	|	ISNULL(FolioBalances.LimitBalance, 0) AS LimitBalance
	|{SELECT
	|	Гостиница.*,
	|	ВалютаЛицСчета.* AS ВалютаЛицСчета,
	|	FolioPaymentSection.* AS FolioPaymentSection,
	|	FolioPaymentMethod.* AS FolioPaymentMethod,
	|	FolioCustomer.* AS FolioCustomer,
	|	FolioContract.* AS FolioContract,
	|	FolioGuestGroup.* AS FolioGuestGroup,
	|	FoliosList.СчетПроживания.Агент.* AS FolioAgent,
	|	FolioClient.* AS FolioClient,
	|	FoliosList.СчетПроживания.* AS FolioRef,
	|	FoliosList.СчетПроживания.Description AS FolioDescription,
	|	FoliosList.СчетПроживания.Примечания AS FolioRemarks,
	|	FoliosList.СчетПроживания.DateTimeFrom AS FolioDateTimeFrom,
	|	FoliosList.СчетПроживания.DateTimeTo AS FolioDateTimeTo,
	|	FoliosList.СчетПроживания.ДокОснование.* AS FolioParentDoc,
	|	FoliosList.СчетПроживания.Фирма.* AS FolioCompany,
	|	FoliosList.СчетПроживания.НомерРазмещения.ТипНомера.* AS FolioRoomRoomType,
	|	FoliosList.СчетПроживания.НомерРазмещения.* AS FolioRoom,
	|	FoliosList.СчетПроживания.Автор.* AS FolioAuthor,
	|	FoliosList.СчетПроживания.IsMaster AS FolioIsMaster,
	|	FoliosList.СчетПроживания.IsClosed AS FolioIsClosed,
	|	SumBalance AS SumBalance,
	|	CustomerSumBalance AS CustomerSumBalance,
	|	ClientSumBalance AS ClientSumBalance,
	|	LimitBalance AS LimitBalance}
	|FROM
	|	Folios AS FoliosList
	|		LEFT JOIN FolioBalances AS FolioBalances
	|		ON (FolioBalances.СчетПроживания = FoliosList.СчетПроживания)
	|{WHERE
	|	FoliosList.СчетПроживания.Гостиница.* AS Гостиница,
	|	FoliosList.СчетПроживания.ВалютаЛицСчета.* AS ВалютаЛицСчета,
	|	FoliosList.СчетПроживания.PaymentSection.* AS FolioPaymentSection,
	|	FoliosList.СчетПроживания.СпособОплаты.* AS FolioPaymentMethod,
	|	FoliosList.СчетПроживания.* AS FolioRef,
	|	FoliosList.СчетПроживания.Description AS FolioDescription,
	|	FoliosList.СчетПроживания.Примечания AS FolioRemarks,
	|	FoliosList.СчетПроживания.Фирма.* AS FolioCompany,
	|	FoliosList.СчетПроживания.ДокОснование.* AS FolioParentDoc,
	|	FoliosList.СчетПроживания.Контрагент.* AS FolioCustomer,
	|	FoliosList.СчетПроживания.Договор.* AS FolioContract,
	|	FoliosList.СчетПроживания.Агент.* AS FolioAgent,
	|	FoliosList.СчетПроживания.Клиент.* AS FolioClient,
	|	FoliosList.СчетПроживания.ГруппаГостей.* AS FolioGuestGroup,
	|	FoliosList.СчетПроживания.НомерРазмещения.* AS FolioRoom,
	|	FoliosList.СчетПроживания.НомерРазмещения.ТипНомера.* AS FolioRoomRoomType,
	|	FoliosList.СчетПроживания.DateTimeFrom AS FolioDateTimeFrom,
	|	FoliosList.СчетПроживания.DateTimeTo AS FolioDateTimeTo,
	|	FoliosList.СчетПроживания.Примечания AS FolioRemarks,
	|	FoliosList.СчетПроживания.Автор.* AS FolioAuthor,
	|	FoliosList.СчетПроживания.IsMaster AS FolioIsMaster,
	|	FoliosList.СчетПроживания.IsClosed AS FolioIsClosed,
	|	(ISNULL(FolioBalances.IsCustomerBalance, FALSE)) AS IsCustomerBalance,
	|	(ISNULL(FolioBalances.IsClientBalance, TRUE)) AS IsClientBalance,
	|	(ISNULL(FolioBalances.SumBalance, 0)) AS SumBalance,
	|	(ISNULL(FolioBalances.CustomerSumBalance, 0)) AS CustomerSumBalance,
	|	(ISNULL(FolioBalances.ClientSumBalance, 0)) AS ClientSumBalance,
	|	(ISNULL(FolioBalances.LimitBalance, 0)) AS LimitBalance}
	|{ORDER BY
	|	Гостиница.*,
	|	ВалютаЛицСчета.* AS ВалютаЛицСчета,
	|	FolioPaymentSection.* AS FolioPaymentSection,
	|	FolioPaymentMethod.* AS FolioPaymentMethod,
	|	FolioCustomer.* AS FolioCustomer,
	|	FolioContract.* AS FolioContract,
	|	FolioGuestGroup.* AS FolioGuestGroup,
	|	FoliosList.СчетПроживания.Агент.* AS FolioAgent,
	|	FolioClient.* AS FolioClient,
	|	FoliosList.СчетПроживания.* AS FolioRef,
	|	FoliosList.СчетПроживания.Description AS FolioDescription,
	|	FoliosList.СчетПроживания.Примечания AS FolioRemarks,
	|	FoliosList.СчетПроживания.DateTimeFrom AS FolioDateTimeFrom,
	|	FoliosList.СчетПроживания.DateTimeTo AS FolioDateTimeTo,
	|	FoliosList.СчетПроживания.ДокОснование.* AS FolioParentDoc,
	|	FoliosList.СчетПроживания.Фирма.* AS FolioCompany,
	|	FoliosList.СчетПроживания.НомерРазмещения.ТипНомера.* AS FolioRoomRoomType,
	|	FoliosList.СчетПроживания.НомерРазмещения.* AS FolioRoom,
	|	FoliosList.СчетПроживания.Автор.* AS FolioAuthor,
	|	FoliosList.СчетПроживания.IsMaster AS FolioIsMaster,
	|	FoliosList.СчетПроживания.IsClosed AS FolioIsClosed}
	|TOTALS
	|	SUM(SumBalance),
	|	SUM(CustomerSumBalance),
	|	SUM(ClientSumBalance),
	|	SUM(LimitBalance)
	|BY
	|	Гостиница,
	|	ВалютаЛицСчета
	|{TOTALS BY
	|	Гостиница.*,
	|	ВалютаЛицСчета.* AS ВалютаЛицСчета,
	|	FolioPaymentSection.* AS FolioPaymentSection,
	|	FolioPaymentMethod.* AS FolioPaymentMethod,
	|	FolioCustomer.* AS FolioCustomer,
	|	FolioContract.* AS FolioContract,
	|	FolioGuestGroup.* AS FolioGuestGroup,
	|	FoliosList.СчетПроживания.Агент.* AS FolioAgent,
	|	FolioClient.* AS FolioClient,
	|	FoliosList.СчетПроживания.* AS FolioRef,
	|	FoliosList.СчетПроживания.Description AS FolioDescription,
	|	FoliosList.СчетПроживания.Примечания AS FolioRemarks,
	|	FoliosList.СчетПроживания.DateTimeFrom AS FolioDateTimeFrom,
	|	FoliosList.СчетПроживания.DateTimeTo AS FolioDateTimeTo,
	|	FoliosList.СчетПроживания.ДокОснование.* AS FolioParentDoc,
	|	FoliosList.СчетПроживания.Фирма.* AS FolioCompany,
	|	FoliosList.СчетПроживания.НомерРазмещения.ТипНомера.* AS FolioRoomRoomType,
	|	FoliosList.СчетПроживания.НомерРазмещения.* AS FolioRoom,
	|	FoliosList.СчетПроживания.Автор.* AS FolioAuthor,
	|	FoliosList.СчетПроживания.IsMaster AS FolioIsMaster,
	|	FoliosList.СчетПроживания.IsClosed AS FolioIsClosed}";
	ReportBuilder.Text = QueryText;
	ReportBuilder.FillSettings();
	
	// Initialize report builder with default query
	vRB = New ReportBuilder(QueryText);
	vRBSettings = vRB.GetSettings(True, True, True, True, True);
	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
	
	// Set default report builder header text
	ReportBuilder.HeaderText = NStr("EN='Folios';RU='Лицевые счета';de='Personenkonten'");
	
	// Fill report builder fields presentations from the report template
//	cmFillReportAttributesPresentations(ThisObject);
	
	// Reset report builder template
	ReportBuilder.Template = Неопределено;
КонецПроцедуры //pmInitializeReportBuilder

//-----------------------------------------------------------------------------
// Reports framework end
//-----------------------------------------------------------------------------
