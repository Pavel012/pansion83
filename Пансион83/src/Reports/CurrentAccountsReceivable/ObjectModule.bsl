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
//	If НЕ ЗначениеЗаполнено(Фирма) Тогда
//		If ЗначениеЗаполнено(Гостиница) Тогда
//			Фирма = Гостиница.Фирма;
//		EndIf;
//	EndIf;
//	If НЕ ЗначениеЗаполнено(PeriodFrom) Тогда
//		PeriodFrom = BegOfMonth(CurrentDate()); // For beg. of month
//	EndIf;
//	If НЕ ЗначениеЗаполнено(PeriodTo) Тогда
//		PeriodTo = EndOfMonth(CurrentDate()); // For end of month
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
//	If ЗначениеЗаполнено(Фирма) Тогда
//		If НЕ Фирма.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("ru = 'Фирма '; en = 'Фирма '") + 
//			                     Фирма.GetObject().pmGetCompanyPrintName(ПараметрыСеанса.ТекЛокализация) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("ru = 'Группа фирм '; en = 'Companies folder '") + 
//			                     Фирма.GetObject().pmGetCompanyPrintName(ПараметрыСеанса.ТекЛокализация) + 
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
//	If ЗначениеЗаполнено(GuestGroup) Тогда
//		vParamPresentation = vParamPresentation + NStr("ru = 'Группа гостей '; en = 'Guest group '") + 
//							 TrimAll(TrimAll(GuestGroup.Code) + " " + TrimAll(GuestGroup.Description)) + 
//							 ";" + Chars.LF;
//	EndIf;							 
//	If ЗначениеЗаполнено(ServiceGroup) Тогда
//		If НЕ ServiceGroup.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("ru = 'Набор услуг '; en = 'Service group '") + 
//			                     TrimAll(ServiceGroup.Description) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("ru = 'Группа наборов услуг '; en = 'Service groups folder '") + 
//			                     TrimAll(ServiceGroup.Description) + 
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
//	ReportBuilder.Parameters.Вставить("qHotel", Гостиница);
//	ReportBuilder.Parameters.Вставить("qIsEmptyHotel", НЕ ЗначениеЗаполнено(Гостиница));
//	ReportBuilder.Parameters.Вставить("qCompany", Фирма);
//	ReportBuilder.Parameters.Вставить("qIsEmptyCompany", НЕ ЗначениеЗаполнено(Фирма));
//	ReportBuilder.Parameters.Вставить("qCustomer", Контрагент);
//	ReportBuilder.Parameters.Вставить("qIsEmptyCustomer", НЕ ЗначениеЗаполнено(Контрагент));
//	ReportBuilder.Parameters.Вставить("qContract", Contract);
//	ReportBuilder.Parameters.Вставить("qIsEmptyContract", НЕ ЗначениеЗаполнено(Contract));
//	ReportBuilder.Parameters.Вставить("qGuestGroup", GuestGroup);
//	ReportBuilder.Parameters.Вставить("qIsEmptyGuestGroup", НЕ ЗначениеЗаполнено(GuestGroup));
//	vUseServicesList = False;
//	vServicesList = New СписокЗначений();
//	If ЗначениеЗаполнено(ServiceGroup) Тогда
//		If НЕ ServiceGroup.IncludeAll Тогда
//			vUseServicesList = True;
//			vServicesList.LoadValues(ServiceGroup.Services.UnloadColumn("Услуга"));
//		EndIf;
//	EndIf;
//	ReportBuilder.Parameters.Вставить("qUseServicesList", vUseServicesList);
//	ReportBuilder.Parameters.Вставить("qServicesList", vServicesList);
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
//	|	РелизацияТекОтчетПериод.Фирма AS Фирма,
//	|	РелизацияТекОтчетПериод.Контрагент AS Контрагент,
//	|	РелизацияТекОтчетПериод.Договор AS Договор,
//	|	РелизацияТекОтчетПериод.ГруппаГостей AS ГруппаГостей,
//	|	РелизацияТекОтчетПериод.СчетПроживания.Клиент AS FolioClient,
//	|	РелизацияТекОтчетПериод.СчетПроживания.НомерРазмещения AS FolioRoom,
//	|	РелизацияТекОтчетПериод.Начисление.Услуга AS Услуга,
//	|	РелизацияТекОтчетПериод.CommissionSumOpeningBalance AS CommissionSumOpeningBalance,
//	|	РелизацияТекОтчетПериод.SumOpeningBalance AS SumOpeningBalance,
//	|	РелизацияТекОтчетПериод.QuantityOpeningBalance AS QuantityOpeningBalance,
//	|	РелизацияТекОтчетПериод.CommissionSumTurnover AS CommissionSumTurnover,
//	|	РелизацияТекОтчетПериод.SumTurnover AS SumTurnover,
//	|	РелизацияТекОтчетПериод.VATSumTurnover AS VATSumTurnover,
//	|	РелизацияТекОтчетПериод.QuantityTurnover AS QuantityTurnover,
//	|	РелизацияТекОтчетПериод.CommissionSumClosingBalance AS CommissionSumClosingBalance,
//	|	РелизацияТекОтчетПериод.SumClosingBalance AS SumClosingBalance,
//	|	РелизацияТекОтчетПериод.QuantityClosingBalance AS QuantityClosingBalance,
//	|	РелизацияТекОтчетПериод.CommissionSumReceipt AS CommissionSumReceipt,
//	|	РелизацияТекОтчетПериод.SumReceipt AS SumReceipt,
//	|	РелизацияТекОтчетПериод.CommissionSumExpense AS CommissionSumExpense,
//	|	РелизацияТекОтчетПериод.SumExpense AS SumExpense,
//	|	РелизацияТекОтчетПериод.VATSumReceipt AS VATSumReceipt,
//	|	РелизацияТекОтчетПериод.VATSumExpense AS VATSumExpense,
//	|	РелизацияТекОтчетПериод.QuantityReceipt AS QuantityReceipt,
//	|	РелизацияТекОтчетПериод.QuantityExpense AS QuantityExpense
//	|{SELECT
//	|	Фирма.*,
//	|	РелизацияТекОтчетПериод.Гостиница.*,
//	|	РелизацияТекОтчетПериод.ВалютаЛицСчета.*,
//	|	Контрагент.*,
//	|	Договор.*,
//	|	ГруппаГостей.*,
//	|	РелизацияТекОтчетПериод.ДокОснование.*,
//	|	РелизацияТекОтчетПериод.СчетПроживания.*,
//	|	FolioClient.* AS FolioClient,
//	|	FolioRoom.* AS FolioRoom,
//	|	Услуга.* AS Услуга,
//	|	РелизацияТекОтчетПериод.Начисление.*,
//	|	РелизацияТекОтчетПериод.Начисление.СтавкаНДС.* AS СтавкаНДС,
//	|	(CASE
//	|			WHEN РелизацияТекОтчетПериод.Начисление.ДатаДок < BEGINOFPERIOD(РелизацияТекОтчетПериод.Period, MONTH)
//	|				THEN TRUE
//	|			ELSE FALSE
//	|		END) AS ChangeInPreviousAccountingPeriod,
//	|	CommissionSumOpeningBalance AS CommissionSumOpeningBalance,
//	|	SumOpeningBalance AS SumOpeningBalance,
//	|	QuantityOpeningBalance AS QuantityOpeningBalance,
//	|	CommissionSumTurnover AS CommissionSumTurnover,
//	|	SumTurnover AS SumTurnover,
//	|	VATSumTurnover AS VATSumTurnover,
//	|	QuantityTurnover AS QuantityTurnover,
//	|	CommissionSumClosingBalance AS CommissionSumClosingBalance,
//	|	SumClosingBalance AS SumClosingBalance,
//	|	QuantityClosingBalance AS QuantityClosingBalance,
//	|	CommissionSumReceipt,
//	|	SumReceipt,
//	|	CommissionSumExpense,
//	|	SumExpense,
//	|	VATSumReceipt,
//	|	VATSumExpense,
//	|	QuantityReceipt,
//	|	QuantityExpense}
//	|FROM
//	|	AccumulationRegister.РелизацияТекОтчетПериод.BalanceAndTurnovers(
//	|			&qPeriodFrom,
//	|			&qPeriodTo,
//	|			Period,
//	|			RegisterRecordsAndPeriodBoundaries,
//	|			(Гостиница IN HIERARCHY (&qHotel)
//	|				OR &qIsEmptyHotel)
//	|				AND (Фирма IN HIERARCHY (&qCompany)
//	|					OR &qIsEmptyCompany)
//	|				AND (Контрагент IN HIERARCHY (&qCustomer)
//	|					OR &qIsEmptyCustomer)
//	|				AND (Договор = &qContract
//	|					OR &qIsEmptyContract)
//	|				AND (ГруппаГостей = &qGuestGroup
//	|					OR &qIsEmptyGuestGroup)
//	|				AND (Начисление.Услуга IN HIERARCHY (&qServicesList)
//	|					OR (NOT &qUseServicesList))) AS РелизацияТекОтчетПериод
//	|{WHERE
//	|	РелизацияТекОтчетПериод.Фирма.*,
//	|	РелизацияТекОтчетПериод.Гостиница.*,
//	|	РелизацияТекОтчетПериод.ВалютаЛицСчета.*,
//	|	РелизацияТекОтчетПериод.Контрагент.*,
//	|	РелизацияТекОтчетПериод.Договор.*,
//	|	РелизацияТекОтчетПериод.ГруппаГостей.*,
//	|	РелизацияТекОтчетПериод.Начисление.Услуга.* AS Услуга,
//	|	РелизацияТекОтчетПериод.СчетПроживания.*,
//	|	РелизацияТекОтчетПериод.СчетПроживания.Клиент.* AS FolioClient,
//	|	РелизацияТекОтчетПериод.СчетПроживания.НомерРазмещения.* AS FolioRoom,
//	|	РелизацияТекОтчетПериод.Начисление.СтавкаНДС.* AS СтавкаНДС,
//	|	РелизацияТекОтчетПериод.ДокОснование.*,
//	|	РелизацияТекОтчетПериод.Начисление.*,
//	|	(CASE
//	|			WHEN РелизацияТекОтчетПериод.Начисление.ДатаДок < BEGINOFPERIOD(РелизацияТекОтчетПериод.Period, MONTH)
//	|				THEN TRUE
//	|			ELSE FALSE
//	|		END) AS ChangeInPreviousAccountingPeriod,
//	|	РелизацияТекОтчетПериод.CommissionSumTurnover,
//	|	РелизацияТекОтчетПериод.SumTurnover,
//	|	РелизацияТекОтчетПериод.VATSumTurnover,
//	|	РелизацияТекОтчетПериод.QuantityTurnover,
//	|	РелизацияТекОтчетПериод.CommissionSumOpeningBalance,
//	|	РелизацияТекОтчетПериод.SumOpeningBalance,
//	|	РелизацияТекОтчетПериод.CommissionSumClosingBalance,
//	|	РелизацияТекОтчетПериод.SumClosingBalance,
//	|	РелизацияТекОтчетПериод.QuantityOpeningBalance,
//	|	РелизацияТекОтчетПериод.QuantityClosingBalance,
//	|	РелизацияТекОтчетПериод.CommissionSumReceipt,
//	|	РелизацияТекОтчетПериод.SumReceipt,
//	|	РелизацияТекОтчетПериод.CommissionSumExpense,
//	|	РелизацияТекОтчетПериод.SumExpense,
//	|	РелизацияТекОтчетПериод.VATSumReceipt,
//	|	РелизацияТекОтчетПериод.VATSumExpense,
//	|	РелизацияТекОтчетПериод.QuantityReceipt,
//	|	РелизацияТекОтчетПериод.QuantityExpense}
//	|
//	|ORDER BY
//	|	Фирма,
//	|	Контрагент,
//	|	Договор,
//	|	ГруппаГостей,
//	|	FolioClient,
//	|	FolioRoom,
//	|	Услуга
//	|{ORDER BY
//	|	РелизацияТекОтчетПериод.Гостиница.*,
//	|	Фирма.*,
//	|	РелизацияТекОтчетПериод.ВалютаЛицСчета.*,
//	|	Контрагент.*,
//	|	Договор.*,
//	|	ГруппаГостей.*,
//	|	Услуга.* AS Услуга,
//	|	РелизацияТекОтчетПериод.СчетПроживания.*,
//	|	FolioClient.* AS FolioClient,
//	|	FolioRoom.* AS FolioRoom,
//	|	РелизацияТекОтчетПериод.Начисление.СтавкаНДС.* AS СтавкаНДС,
//	|	РелизацияТекОтчетПериод.ДокОснование.*,
//	|	РелизацияТекОтчетПериод.Начисление.*,
//	|	CommissionSumTurnover,
//	|	SumTurnover,
//	|	VATSumTurnover,
//	|	QuantityTurnover,
//	|	CommissionSumOpeningBalance,
//	|	SumOpeningBalance,
//	|	CommissionSumClosingBalance,
//	|	SumClosingBalance,
//	|	QuantityOpeningBalance,
//	|	QuantityClosingBalance,
//	|	CommissionSumReceipt,
//	|	SumReceipt,
//	|	CommissionSumExpense,
//	|	SumExpense,
//	|	VATSumReceipt,
//	|	VATSumExpense,
//	|	QuantityReceipt,
//	|	QuantityExpense}
//	|TOTALS
//	|	SUM(CommissionSumOpeningBalance),
//	|	SUM(SumOpeningBalance),
//	|	SUM(QuantityOpeningBalance),
//	|	SUM(CommissionSumTurnover),
//	|	SUM(SumTurnover),
//	|	SUM(VATSumTurnover),
//	|	SUM(QuantityTurnover),
//	|	SUM(CommissionSumClosingBalance),
//	|	SUM(SumClosingBalance),
//	|	SUM(QuantityClosingBalance),
//	|	SUM(CommissionSumReceipt),
//	|	SUM(SumReceipt),
//	|	SUM(CommissionSumExpense),
//	|	SUM(SumExpense),
//	|	SUM(VATSumReceipt),
//	|	SUM(VATSumExpense),
//	|	SUM(QuantityReceipt),
//	|	SUM(QuantityExpense)
//	|BY
//	|	OVERALL,
//	|	Фирма,
//	|	Контрагент HIERARCHY,
//	|	Договор,
//	|	ГруппаГостей,
//	|	FolioClient,
//	|	FolioRoom,
//	|	Услуга
//	|{TOTALS BY
//	|	РелизацияТекОтчетПериод.Гостиница.*,
//	|	Фирма.*,
//	|	РелизацияТекОтчетПериод.ВалютаЛицСчета.*,
//	|	Контрагент.*,
//	|	Договор.*,
//	|	ГруппаГостей.*,
//	|	Услуга.* AS Услуга,
//	|	РелизацияТекОтчетПериод.СчетПроживания.*,
//	|	FolioClient.*,
//	|	FolioRoom.*,
//	|	РелизацияТекОтчетПериод.Начисление.СтавкаНДС.* AS СтавкаНДС,
//	|	РелизацияТекОтчетПериод.ДокОснование.*,
//	|	РелизацияТекОтчетПериод.Начисление.*,
//	|	(CASE
//	|			WHEN РелизацияТекОтчетПериод.Начисление.ДатаДок < BEGINOFPERIOD(РелизацияТекОтчетПериод.Period, MONTH)
//	|				THEN TRUE
//	|			ELSE FALSE
//	|		END) AS ChangeInPreviousAccountingPeriod}";
//	ReportBuilder.Text = QueryText;
//	ReportBuilder.FillSettings();
//	
//	// Initialize report builder with default query
//	vRB = New ReportBuilder(QueryText);
//	vRBSettings = vRB.GetSettings(True, True, True, True, True);
//	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
//	
//	// Set default report builder header text
//	ReportBuilder.HeaderText = NStr("EN='Current accounts receivable';RU='Текущая реализация услуг';de='Aktuelle Realisation von Diensten'");
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
//	If pName = "SumOpeningBalance" 
//	   Or pName = "CommissionSumOpeningBalance" 
//	   Or pName = "QuantityOpeningBalance" 
//	   Or pName = "CommissionSumClosingBalance" 
//	   Or pName = "SumClosingBalance" 
//	   Or pName = "QuantityClosingBalance" 
//	   Or pName = "CommissionSumTurnover" 
//	   Or pName = "SumTurnover" 
//	   Or pName = "VATSumTurnover" 
//	   Or pName = "QuantityTurnover" 
//	   Or pName = "SumReceipt" 
//	   Or pName = "SumExpense" 
//	   Or pName = "VATSumReceipt" 
//	   Or pName = "VATSumExpense" 
//	   Or pName = "QuantityReceipt" 
//	   Or pName = "QuantityExpense" 
//	   Or pName = "CommissionSumReceipt" 
//	   Or pName = "CommissionSumExpense" Тогда
//		Return True;
//	Else
//		Return False;
//	EndIf;
//EndFunction //pmIsResource
//
////-----------------------------------------------------------------------------
//// Reports framework end
////-----------------------------------------------------------------------------
