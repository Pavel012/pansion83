//-----------------------------------------------------------------------------
// Reports framework start
//-----------------------------------------------------------------------------

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
	If НЕ ЗначениеЗаполнено(PeriodFrom) Тогда
		PeriodFrom = BegOfDay(CurrentDate()); // For today
		PeriodTo = EndOfDay(PeriodFrom);
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
							 TrimAll(GuestGroup.Code) + 
							 ";" + Chars.LF;
	EndIf;							 
	If ЗначениеЗаполнено(Company) Тогда
		If НЕ Company.IsFolder Тогда
			vParamPresentation = vParamPresentation + NStr("ru = 'Фирма '; en = 'Фирма '") + 
			                     TrimAll(Company.Description) + 
			                     ";" + Chars.LF;
		Else
			vParamPresentation = vParamPresentation + NStr("ru = 'Группа фирм '; en = 'Companies folder '") + 
			                     TrimAll(Company.Description) + 
			                     ";" + Chars.LF;
		EndIf;
	EndIf;					 
	Return vParamPresentation;
EndFunction //pmGetReportParametersPresentation

//-----------------------------------------------------------------------------
// Runs report
//-----------------------------------------------------------------------------
Процедура pmGenerate(pSpreadsheet) Экспорт
	
	
	// Reset report builder template
	ReportBuilder.Template = Неопределено;
	
	// Initialize report builder query generator attributes
	ReportBuilder.PresentationAdding = PresentationAdditionType.Add;
	
	// Fill report parameters
	ReportBuilder.Parameters.Вставить("qHotel", Гостиница);
	ReportBuilder.Parameters.Вставить("qHotelIsEmpty", НЕ ЗначениеЗаполнено(Гостиница));
	ReportBuilder.Parameters.Вставить("qPeriodFrom", PeriodFrom);
	ReportBuilder.Parameters.Вставить("qPeriodTo", PeriodTo);
	ReportBuilder.Parameters.Вставить("qCompany", Company);
	ReportBuilder.Parameters.Вставить("qCompanyIsEmpty", НЕ ЗначениеЗаполнено(Company));
	ReportBuilder.Parameters.Вставить("qCustomer", Customer);
	ReportBuilder.Parameters.Вставить("qCustomerIsEmpty", НЕ ЗначениеЗаполнено(Customer));
	ReportBuilder.Parameters.Вставить("qContract", Contract);
	ReportBuilder.Parameters.Вставить("qContractIsEmpty", НЕ ЗначениеЗаполнено(Contract));
	ReportBuilder.Parameters.Вставить("qGuestGroup", GuestGroup);
	ReportBuilder.Parameters.Вставить("qGuestGroupIsEmpty", НЕ ЗначениеЗаполнено(GuestGroup));
	
	// Execute report builder query
	ReportBuilder.Execute();
	
	//// Apply appearance settings to the report template
	//vTemplateAttributes = cmApplyReportTemplateAppearance(ThisObject);
	//
	//// Output report to the spreadsheet
	//
	//ReportBuilder.Put(pSpreadsheet);
	////ReportBuilder.Template.Show(); // For debug purpose

	//// Apply appearance settings to the report spreadsheet
	//cmApplyReportAppearance(ThisObject, pSpreadsheet, vTemplateAttributes);
КонецПроцедуры //pmGenerate
	
//-----------------------------------------------------------------------------
Процедура pmInitializeReportBuilder() Экспорт
	ReportBuilder = New ReportBuilder();
	
	// Initialize default query text
	QueryText = 
	"SELECT
	|	ПеремещениеНачисления.ДатаДок AS Date,
	|	ПеремещениеНачисления.Ref AS ПеремещениеНачисления,
	|	ПеремещениеНачисления.ParentCharge AS ParentCharge,
	|	ПеремещениеНачисления.ParentCharge.Услуга AS Услуга,
	|	ПеремещениеНачисления.ParentCharge.Количество AS Количество,
	|	ПеремещениеНачисления.ParentCharge.Сумма - ПеремещениеНачисления.ParentCharge.СуммаСкидки AS Сумма,
	|	ПеремещениеНачисления.FolioFrom.ВалютаЛицСчета AS ВалютаЛицСчета,
	|	ПеремещениеНачисления.FolioFrom.Контрагент,
	|	ПеремещениеНачисления.FolioFrom.Договор,
	|	ПеремещениеНачисления.FolioFrom.ГруппаГостей,
	|	ПеремещениеНачисления.FolioFrom.Клиент,
	|	ПеремещениеНачисления.FolioFrom.НомерРазмещения,
	|	ПеремещениеНачисления.FolioFrom.DateTimeFrom,
	|	ПеремещениеНачисления.FolioFrom.DateTimeTo,
	|	ПеремещениеНачисления.FolioTo.Контрагент,
	|	ПеремещениеНачисления.FolioTo.Договор,
	|	ПеремещениеНачисления.FolioTo.ГруппаГостей,
	|	ПеремещениеНачисления.FolioTo.Клиент,
	|	ПеремещениеНачисления.FolioTo.НомерРазмещения,
	|	ПеремещениеНачисления.FolioTo.DateTimeFrom,
	|	ПеремещениеНачисления.FolioTo.DateTimeTo,
	|	ПеремещениеНачисления.Примечания,
	|	ПеремещениеНачисления.Автор
	|{SELECT
	|	Date,
	|	ПеремещениеНачисления.*,
	|	ПеремещениеНачисления.FolioFrom.*,
	|	ParentCharge.*,
	|	Услуга.*,
	|	Количество,
	|	Сумма,
	|	ВалютаЛицСчета.*,
	|	ПеремещениеНачисления.FolioFrom.СпособОплаты.* AS FolioFromPaymentMethod,
	|	FolioFromCustomer.*,
	|	FolioFromContract.*,
	|	FolioFromGuestGroup.*,
	|	FolioFromClient.*,
	|	FolioFromRoom.*,
	|	FolioFromDateTimeFrom,
	|	FolioFromDateTimeTo,
	|	ПеремещениеНачисления.FolioTo.*,
	|	ПеремещениеНачисления.FolioTo.СпособОплаты.* AS FolioToPaymentMethod,
	|	FolioToCustomer.*,
	|	FolioToContract.*,
	|	FolioToGuestGroup.*,
	|	FolioToClient.*,
	|	FolioToRoom.*,
	|	FolioToDateTimeFrom,
	|	FolioToDateTimeTo,
	|	ПеремещениеНачисления.ДокОснование.*,
	|	Примечания,
	|	Автор.*,
	|	ПеремещениеНачисления.Гостиница.*,
	|	(BEGINOFPERIOD(ПеремещениеНачисления.ДатаДок, DAY)) AS УчетнаяДата,
	|	(WEEK(ПеремещениеНачисления.ДатаДок)) AS AccountingWeek,
	|	(MONTH(ПеремещениеНачисления.ДатаДок)) AS AccountingMonth,
	|	(QUARTER(ПеремещениеНачисления.ДатаДок)) AS AccountingQuarter,
	|	(YEAR(ПеремещениеНачисления.ДатаДок)) AS AccountingYear}
	|FROM
	|	Document.ПеремещениеНачисления AS ПеремещениеНачисления
	|WHERE
	|	(ПеремещениеНачисления.Гостиница IN HIERARCHY (&qHotel)
	|			OR &qHotelIsEmpty)
	|	AND (ПеремещениеНачисления.FolioFrom.Контрагент IN HIERARCHY (&qCustomer)
	|			OR ПеремещениеНачисления.FolioTo.Контрагент IN HIERARCHY (&qCustomer)
	|			OR &qCustomerIsEmpty)
	|	AND (ПеремещениеНачисления.FolioFrom.Договор = &qContract
	|			OR ПеремещениеНачисления.FolioTo.Договор = &qContract
	|			OR &qContractIsEmpty)
	|	AND (ПеремещениеНачисления.FolioFrom.ГруппаГостей = &qGuestGroup
	|			OR ПеремещениеНачисления.FolioTo.ГруппаГостей = &qGuestGroup
	|			OR &qGuestGroupIsEmpty)
	|	AND ПеремещениеНачисления.ДатаДок >= &qPeriodFrom
	|	AND ПеремещениеНачисления.ДатаДок < &qPeriodTo
	|	AND ПеремещениеНачисления.Posted
	|	AND (ПеремещениеНачисления.FolioFrom.Фирма IN HIERARCHY (&qCompany)
	|			OR ПеремещениеНачисления.FolioTo.Фирма IN HIERARCHY (&qCompany)
	|			OR &qCompanyIsEmpty)
	|{WHERE
	|	ПеремещениеНачисления.ДатаДок,
	|	ПеремещениеНачисления.Ref.* AS ПеремещениеНачисления,
	|	ПеремещениеНачисления.FolioFrom.* AS FolioFrom,
	|	ПеремещениеНачисления.ParentCharge.* AS ParentCharge,
	|	ПеремещениеНачисления.ParentCharge.Услуга.* AS Услуга,
	|	ПеремещениеНачисления.ParentCharge.Количество AS Количество,
	|	(ПеремещениеНачисления.ParentCharge.Сумма - ПеремещениеНачисления.ParentCharge.СуммаСкидки) AS Сумма,
	|	ПеремещениеНачисления.FolioFrom.ВалютаЛицСчета.* AS ВалютаЛицСчета,
	|	ПеремещениеНачисления.FolioFrom.СпособОплаты.* AS FolioFromPaymentMethod,
	|	ПеремещениеНачисления.FolioFrom.Контрагент.* AS FolioFromCustomer,
	|	ПеремещениеНачисления.FolioFrom.Договор.* AS FolioFromContract,
	|	ПеремещениеНачисления.FolioFrom.ГруппаГостей.* AS FolioFromGuestGroup,
	|	ПеремещениеНачисления.FolioFrom.Клиент.* AS FolioFromClient,
	|	ПеремещениеНачисления.FolioFrom.НомерРазмещения.* AS FolioFromRoom,
	|	ПеремещениеНачисления.FolioFrom.DateTimeFrom AS FolioFromDateTimeFrom,
	|	ПеремещениеНачисления.FolioFrom.DateTimeTo AS FolioFromDateTimeTo,
	|	ПеремещениеНачисления.FolioTo.* AS FolioTo,
	|	ПеремещениеНачисления.FolioTo.СпособОплаты.* AS FolioToPaymentMethod,
	|	ПеремещениеНачисления.FolioTo.Контрагент.* AS FolioToCustomer,
	|	ПеремещениеНачисления.FolioTo.Договор.* AS FolioToContract,
	|	ПеремещениеНачисления.FolioTo.ГруппаГостей.* AS FolioToGuestGroup,
	|	ПеремещениеНачисления.FolioTo.Клиент.* AS FolioToClient,
	|	ПеремещениеНачисления.FolioTo.НомерРазмещения.* AS FolioToRoom,
	|	ПеремещениеНачисления.FolioTo.DateTimeFrom AS FolioToDateTimeFrom,
	|	ПеремещениеНачисления.FolioTo.DateTimeTo AS FolioToDateTimeTo,
	|	ПеремещениеНачисления.ДокОснование.* AS ДокОснование,
	|	ПеремещениеНачисления.Примечания AS Примечания,
	|	ПеремещениеНачисления.Автор.* AS Автор,
	|	ПеремещениеНачисления.Гостиница.* AS Гостиница}
	|
	|ORDER BY
	|	Date
	|{ORDER BY
	|	Date,
	|	ПеремещениеНачисления.*,
	|	ПеремещениеНачисления.FolioFrom.*,
	|	ParentCharge.*,
	|	Услуга.*,
	|	Количество,
	|	Сумма,
	|	ВалютаЛицСчета.*,
	|	ПеремещениеНачисления.FolioFrom.СпособОплаты.* AS FolioFromPaymentMethod,
	|	FolioFromCustomer.*,
	|	FolioFromContract.*,
	|	FolioFromGuestGroup.*,
	|	FolioFromClient.*,
	|	FolioFromRoom.*,
	|	FolioFromDateTimeFrom,
	|	FolioFromDateTimeTo,
	|	ПеремещениеНачисления.FolioTo.*,
	|	ПеремещениеНачисления.FolioTo.СпособОплаты.* AS FolioToPaymentMethod,
	|	FolioToCustomer.*,
	|	FolioToContract.*,
	|	FolioToGuestGroup.*,
	|	FolioToClient.*,
	|	FolioToRoom.*,
	|	FolioToDateTimeFrom,
	|	FolioToDateTimeTo,
	|	ПеремещениеНачисления.ДокОснование.*,
	|	Автор.*,
	|	ПеремещениеНачисления.Гостиница.*}
	|TOTALS
	|	SUM(Количество),
	|	SUM(Сумма)
	|BY
	|	OVERALL
	|{TOTALS BY
	|	ПеремещениеНачисления.*,
	|	ПеремещениеНачисления.FolioFrom.*,
	|	ParentCharge.*,
	|	Услуга.*,
	|	ВалютаЛицСчета.*,
	|	ПеремещениеНачисления.FolioFrom.СпособОплаты.* AS FolioFromPaymentMethod,
	|	FolioFromCustomer.*,
	|	FolioFromContract.*,
	|	FolioFromGuestGroup.*,
	|	FolioFromClient.*,
	|	FolioFromRoom.*,
	|	FolioFromDateTimeFrom,
	|	FolioFromDateTimeTo,
	|	ПеремещениеНачисления.FolioTo.*,
	|	ПеремещениеНачисления.FolioTo.СпособОплаты.* AS FolioToPaymentMethod,
	|	FolioToCustomer.*,
	|	FolioToContract.*,
	|	FolioToGuestGroup.*,
	|	FolioToClient.*,
	|	FolioToRoom.*,
	|	FolioToDateTimeFrom,
	|	FolioToDateTimeTo,
	|	ПеремещениеНачисления.ДокОснование.*,
	|	Автор.*,
	|	ПеремещениеНачисления.Гостиница.*,
	|	(BEGINOFPERIOD(ПеремещениеНачисления.ДатаДок, DAY)) AS УчетнаяДата,
	|	(WEEK(ПеремещениеНачисления.ДатаДок)) AS AccountingWeek,
	|	(MONTH(ПеремещениеНачисления.ДатаДок)) AS AccountingMonth,
	|	(QUARTER(ПеремещениеНачисления.ДатаДок)) AS AccountingQuarter,
	|	(YEAR(ПеремещениеНачисления.ДатаДок)) AS AccountingYear}";
	ReportBuilder.Text = QueryText;
	ReportBuilder.FillSettings();
	
	// Initialize report builder with default query
	vRB = New ReportBuilder(QueryText);
	vRBSettings = vRB.GetSettings(True, True, True, True, True);
	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
	
	// Set default report builder header text
	ReportBuilder.HeaderText = NStr("EN='Charge transfers';RU='Перемещения начислений';de='Verschiebungen der Anrechnungen'");
	
	
	// Reset report builder template
	ReportBuilder.Template = Неопределено;
КонецПроцедуры //pmInitializeReportBuilder

//-----------------------------------------------------------------------------
// Reports framework end
//-----------------------------------------------------------------------------
