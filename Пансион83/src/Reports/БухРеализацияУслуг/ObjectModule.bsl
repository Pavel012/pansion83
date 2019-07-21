//-----------------------------------------------------------------------------
// Reports framework start
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
//Процедура pmSaveReportAttributes() Экспорт
//	cmSaveReportAttributes(ThisObject);
//КонецПроцедуры //pmSaveReportAttributes
//
////-----------------------------------------------------------------------------
//Процедура pmLoadReportAttributes(pParameter = Неопределено) Экспорт
//	cmLoadReportAttributes(ThisObject, pParameter);
//КонецПроцедуры //pmLoadReportAttributes

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
	If НЕ ЗначениеЗаполнено(Company) Тогда
		If ЗначениеЗаполнено(Гостиница) Тогда
			Company = Гостиница.Фирма;
		EndIf;
	EndIf;
	If НЕ ЗначениеЗаполнено(PeriodFrom) Тогда
		PeriodFrom = BegOfMonth(CurrentDate()); // For beg. of month
	EndIf;
	If НЕ ЗначениеЗаполнено(PeriodTo) Тогда
		PeriodTo = EndOfMonth(CurrentDate()); // For end of month
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
	If ЗначениеЗаполнено(Company) Тогда
		If НЕ Company.IsFolder Тогда
			vParamPresentation = vParamPresentation + NStr("ru = 'Фирма '; en = 'Фирма '") + 
			                     Company.GetObject().pmGetCompanyPrintName(ПараметрыСеанса.ТекЛокализация) + 
			                     ";" + Chars.LF;
		Else
			vParamPresentation = vParamPresentation + NStr("ru = 'Группа фирм '; en = 'Companies folder '") + 
			                     Company.GetObject().pmGetCompanyPrintName(ПараметрыСеанса.ТекЛокализация) + 
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
		vParamPresentation = vParamPresentation + NStr("ru = 'Группа гостей '; en = 'Guest group '") + 
							 TrimAll(TrimAll(GuestGroup.Code) + " " + TrimAll(GuestGroup.Description)) + 
							 ";" + Chars.LF;
	EndIf;							 
	If ЗначениеЗаполнено(ServiceGroup) Тогда
		If НЕ ServiceGroup.IsFolder Тогда
			vParamPresentation = vParamPresentation + NStr("ru = 'Набор услуг '; en = 'Service group '") + 
			                     TrimAll(ServiceGroup.Description) + 
			                     ";" + Chars.LF;
		Else
			vParamPresentation = vParamPresentation + NStr("ru = 'Группа наборов услуг '; en = 'Service groups folder '") + 
			                     TrimAll(ServiceGroup.Description) + 
			                     ";" + Chars.LF;
		EndIf;
	EndIf;					 
	Return vParamPresentation;
EndFunction //pmGetReportParametersPresentation

//-----------------------------------------------------------------------------
// Runs report
//-----------------------------------------------------------------------------
Процедура pmGenerate(pSpreadsheet, pAddChart = False) Экспорт
	
	
	// Reset report builder template
	ReportBuilder.Template = Неопределено;
	
	// Initialize report builder query generator attributes
	ReportBuilder.PresentationAdding = PresentationAdditionType.Add;
	
	// Fill report parameters
	ReportBuilder.Parameters.Вставить("qPeriodFrom", PeriodFrom);
	ReportBuilder.Parameters.Вставить("qPeriodTo", PeriodTo);
	ReportBuilder.Parameters.Вставить("qHotel", Гостиница);
	ReportBuilder.Parameters.Вставить("qIsEmptyHotel", НЕ ЗначениеЗаполнено(Гостиница));
	ReportBuilder.Parameters.Вставить("qCompany", Company);
	ReportBuilder.Parameters.Вставить("qIsEmptyCompany", НЕ ЗначениеЗаполнено(Company));
	ReportBuilder.Parameters.Вставить("qCustomer", Customer);
	ReportBuilder.Parameters.Вставить("qIsEmptyCustomer", НЕ ЗначениеЗаполнено(Customer));
	ReportBuilder.Parameters.Вставить("qContract", Contract);
	ReportBuilder.Parameters.Вставить("qIsEmptyContract", НЕ ЗначениеЗаполнено(Contract));
	ReportBuilder.Parameters.Вставить("qGuestGroup", GuestGroup);
	ReportBuilder.Parameters.Вставить("qIsEmptyGuestGroup", НЕ ЗначениеЗаполнено(GuestGroup));
	vUseServicesList = False;
	vServicesList = New СписокЗначений();
	If ЗначениеЗаполнено(ServiceGroup) Тогда
		If НЕ ServiceGroup.IncludeAll Тогда
			vUseServicesList = True;
			vServicesList.LoadValues(ServiceGroup.Services.UnloadColumn("Услуга"));
		EndIf;
	EndIf;
	ReportBuilder.Parameters.Вставить("qUseServicesList", vUseServicesList);
	ReportBuilder.Parameters.Вставить("qServicesList", vServicesList);
	
	// Execute report builder query
	ReportBuilder.Execute();
	
	//// Apply appearance settings to the report template
	//vTemplateAttributes = cmApplyReportTemplateAppearance(ThisObject);
	//
	//// Output report to the spreadsheet
	//ReportBuilder.Put(pSpreadsheet);
	////ReportBuilder.Template.Show(); // For debug purpose

	//// Apply appearance settings to the report spreadsheet
	//cmApplyReportAppearance(ThisObject, pSpreadsheet, vTemplateAttributes);
	
	// Add chart 
	
КонецПроцедуры //pmGenerate
	
//-----------------------------------------------------------------------------
Процедура pmInitializeReportBuilder() Экспорт
	ReportBuilder = New ReportBuilder();
	
	// Initialize default query text
	QueryText = 
	"SELECT
	|	БухРеализацияУслуг.Period AS Period,
	|	БухРеализацияУслуг.Фирма AS Фирма,
	|	БухРеализацияУслуг.Контрагент AS Контрагент,
	|	БухРеализацияУслуг.ГруппаГостей AS ГруппаГостей,
	|	БухРеализацияУслуг.СчетПроживания AS СчетПроживания,
	|	БухРеализацияУслуг.СчетПроживания.Клиент AS FolioClient,
	|	БухРеализацияУслуг.СчетПроживания.НомерРазмещения AS FolioRoom,
	|	БухРеализацияУслуг.СчетПроживания.DateTimeFrom AS FolioDateTimeFrom,
	|	БухРеализацияУслуг.СчетПроживания.DateTimeTo AS FolioDateTimeTo,
	|	БухРеализацияУслуг.Услуга AS Услуга,
	|	БухРеализацияУслуг.CommissionSumTurnover AS СуммаКомиссии,
	|	БухРеализацияУслуг.SumTurnover AS Сумма,
	|	БухРеализацияУслуг.VATSumTurnover AS СуммаНДС,
	|	БухРеализацияУслуг.QuantityTurnover AS Количество
	|{SELECT
	|	Period,
	|	БухРеализацияУслуг.УчетнаяДата,
	|	БухРеализацияУслуг.Гостиница.*,
	|	БухРеализацияУслуг.Акт.*,
	|	БухРеализацияУслуг.ДокОснование.*,
	|	БухРеализацияУслуг.ПутевкаКурсовка.*,
	|	Фирма.*,
	|	БухРеализацияУслуг.ВалютаРасчетов.*,
	|	Контрагент.*,
	|	БухРеализацияУслуг.Договор.*,
	|	ГруппаГостей.*,
	|	СчетПроживания.*,
	|	FolioRoom.*,
	|	FolioClient.*,
	|	FolioDateTimeFrom,
	|	FolioDateTimeTo,
	|	Услуга.*,
	|	БухРеализацияУслуг.СтавкаНДС.*,
	|	СуммаКомиссии,
	|	Сумма,
	|	СуммаНДС,
	|	Quantity}
	|FROM
	|	AccumulationRegister.БухРеализацияУслуг.Turnovers(
	|			&qPeriodFrom,
	|			&qPeriodTo,
	|			Day,
	|			(Гостиница IN HIERARCHY (&qHotel)
	|				OR &qIsEmptyHotel)
	|				AND (Фирма IN HIERARCHY (&qCompany)
	|					OR &qIsEmptyCompany)
	|				AND (Контрагент IN HIERARCHY (&qCustomer)
	|					OR &qIsEmptyCustomer)
	|				AND (Договор = &qContract
	|					OR &qIsEmptyContract)
	|				AND (ГруппаГостей = &qGuestGroup
	|					OR &qIsEmptyGuestGroup)
	|				AND (Услуга IN HIERARCHY (&qServicesList)
	|					OR (NOT &qUseServicesList))) AS БухРеализацияУслуг
	|{WHERE
	|	БухРеализацияУслуг.Period,
	|	БухРеализацияУслуг.УчетнаяДата,
	|	БухРеализацияУслуг.Акт.*,
	|	БухРеализацияУслуг.Гостиница.*,
	|	БухРеализацияУслуг.Фирма.*,
	|	БухРеализацияУслуг.ВалютаРасчетов.*,
	|	БухРеализацияУслуг.Контрагент.*,
	|	БухРеализацияУслуг.Договор.*,
	|	БухРеализацияУслуг.ДокОснование.*,
	|	БухРеализацияУслуг.ПутевкаКурсовка.*,
	|	БухРеализацияУслуг.ГруппаГостей.*,
	|	БухРеализацияУслуг.СчетПроживания.*,
	|	БухРеализацияУслуг.СчетПроживания.НомерРазмещения.* AS FolioRoom,
	|	БухРеализацияУслуг.СчетПроживания.Клиент.* AS FolioClient,
	|	БухРеализацияУслуг.СчетПроживания.DateTimeFrom AS FolioDateTimeFrom,
	|	БухРеализацияУслуг.СчетПроживания.DateTimeTo AS FolioDateTimeTo,
	|	БухРеализацияУслуг.Услуга.*,
	|	БухРеализацияУслуг.СтавкаНДС.*,
	|	БухРеализацияУслуг.CommissionSumTurnover AS СуммаКомиссии,
	|	БухРеализацияУслуг.SumTurnover AS Сумма,
	|	БухРеализацияУслуг.VATSumTurnover AS СуммаНДС,
	|	БухРеализацияУслуг.QuantityTurnover AS Quantity}
	|
	|ORDER BY
	|	Period,
	|	Фирма,
	|	Контрагент,
	|	ГруппаГостей,
	|	СчетПроживания,
	|	Услуга
	|{ORDER BY
	|	Period,
	|	БухРеализацияУслуг.УчетнаяДата,
	|	БухРеализацияУслуг.Акт.*,
	|	БухРеализацияУслуг.Гостиница.*,
	|	Фирма.*,
	|	БухРеализацияУслуг.ВалютаРасчетов.*,
	|	Контрагент.*,
	|	БухРеализацияУслуг.Договор.*,
	|	БухРеализацияУслуг.ДокОснование.*,
	|	БухРеализацияУслуг.ПутевкаКурсовка.*,
	|	ГруппаГостей.*,
	|	СчетПроживания.*,
	|	FolioClient.*,
	|	FolioRoom.*,
	|	FolioDateTimeFrom,
	|	FolioDateTimeTo,
	|	Услуга.*,
	|	БухРеализацияУслуг.СтавкаНДС.*,
	|	СуммаКомиссии,
	|	Сумма,
	|	СуммаНДС,
	|	Quantity}
	|TOTALS
	|	SUM(СуммаКомиссии),
	|	SUM(Сумма),
	|	SUM(СуммаНДС),
	|	SUM(Количество)
	|BY
	|	OVERALL,
	|	Period,
	|	Фирма HIERARCHY,
	|	Контрагент HIERARCHY,
	|	ГруппаГостей,
	|	СчетПроживания
	|{TOTALS BY
	|	Period,
	|	БухРеализацияУслуг.УчетнаяДата,
	|	БухРеализацияУслуг.Акт.*,
	|	БухРеализацияУслуг.Гостиница.*,
	|	БухРеализацияУслуг.ДокОснование.*,
	|	БухРеализацияУслуг.ПутевкаКурсовка.*,
	|	Фирма.*,
	|	БухРеализацияУслуг.ВалютаРасчетов.*,
	|	Контрагент.*,
	|	БухРеализацияУслуг.Договор.*,
	|	ГруппаГостей.*,
	|	СчетПроживания.*,
	|	FolioRoom.*,
	|	FolioClient.*,
	|	Услуга.*,
	|	БухРеализацияУслуг.СтавкаНДС.*}";
	ReportBuilder.Text = QueryText;
	ReportBuilder.FillSettings();
	
	// Initialize report builder with default query
	vRB = New ReportBuilder(QueryText);
	vRBSettings = vRB.GetSettings(True, True, True, True, True);
	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
	
	// Set default report builder header text
	ReportBuilder.HeaderText = NStr("EN='Accounts receivable';RU='Бухгалтерская реализация услуг';de='rechnerische Realisation von Dienstleistungen'");
	
	// Fill report builder fields presentations from the report template
	
	
	// Reset report builder template
	ReportBuilder.Template = Неопределено;
КонецПроцедуры //pmInitializeReportBuilder

//-----------------------------------------------------------------------------
Function pmIsResource(pName) Экспорт
	If pName = "Сумма" 
	   Or pName = "СуммаКомиссии" 
	   Or pName = "СуммаНДС" 
	   Or pName = "Количество" Тогда
		Return True;
	Else
		Return False;
	EndIf;
EndFunction //pmIsResource

//-----------------------------------------------------------------------------
// Reports framework end
//-----------------------------------------------------------------------------
