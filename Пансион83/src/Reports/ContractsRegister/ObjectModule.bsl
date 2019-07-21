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
//	// Nothing to initialize yet
//КонецПроцедуры //pmFillAttributesWithDefaultValues
//
////-----------------------------------------------------------------------------
//Function pmGetReportParametersPresentation() Экспорт
//	vParamPresentation = "";
//	If НЕ ЗначениеЗаполнено(PeriodFrom) And ЗначениеЗаполнено(PeriodTo) Тогда
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
//	If ЗначениеЗаполнено(Employee) Тогда
//		If НЕ Employee.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("en='Employee ';ru='Сотрудник ';de='Mitarbeiter'") + 
//								 TrimAll(Employee.Description) + 
//								 ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("ru = 'Группа сотрудников '; en = 'Employees folder '") + 
//								 TrimAll(Employee.Description) + 
//								 ";" + Chars.LF;
//		EndIf;
//	EndIf;
//	If ЗначениеЗаполнено(Контрагент) Тогда
//		If НЕ Контрагент.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("ru = 'Контрагент '; en = 'Контрагент '; de = 'Kunde '") + 
//								 TrimAll(Контрагент.Description) + 
//								 ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("ru = 'Группа контрагентов '; en = 'Customers folder '; de = 'Kunden '") + 
//								 TrimAll(Контрагент.Description) + 
//								 ";" + Chars.LF;
//		EndIf;
//	EndIf;							 
//	If ЗначениеЗаполнено(CustomerType) Тогда
//		If НЕ CustomerType.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("ru = 'Тип контрагента '; en = 'Контрагент type '; de = 'Kunden typ '") + 
//								 TrimAll(Контрагент.Description) + 
//								 ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("ru = 'Группа типов контрагентов '; en = 'Контрагент types folder '; de = 'Kunden typen '") + 
//								 TrimAll(CustomerType.Description) + 
//								 ";" + Chars.LF;
//		EndIf;
//	EndIf;							 
//	If ЗначениеЗаполнено(ContractType) Тогда
//		vParamPresentation = vParamPresentation + NStr("ru = 'Тип договора '; en = 'Contract type '; de = 'Vertragsart '") + 
//								 TrimAll(ContractType.Description) + 
//								 ";" + Chars.LF;
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
//	ReportBuilder.Parameters.Вставить("qPeriodFrom", PeriodFrom);
//	ReportBuilder.Parameters.Вставить("qPeriodTo", ?(ЗначениеЗаполнено(PeriodTo), EndOfDay(PeriodTo), '39991231235959'));
//	ReportBuilder.Parameters.Вставить("qCompany", Фирма);
//	ReportBuilder.Parameters.Вставить("qCompanyIsEmpty", НЕ ЗначениеЗаполнено(Фирма));
//	ReportBuilder.Parameters.Вставить("qCustomer", Контрагент);
//	ReportBuilder.Parameters.Вставить("qCustomerIsEmpty", НЕ ЗначениеЗаполнено(Контрагент));
//	ReportBuilder.Parameters.Вставить("qCustomerType", CustomerType);
//	ReportBuilder.Parameters.Вставить("qCustomerTypeIsEmpty", НЕ ЗначениеЗаполнено(CustomerType));
//	ReportBuilder.Parameters.Вставить("qContractType", ContractType);
//	ReportBuilder.Parameters.Вставить("qContractTypeIsEmpty", НЕ ЗначениеЗаполнено(ContractType));
//	ReportBuilder.Parameters.Вставить("qEmployee", Employee);
//	ReportBuilder.Parameters.Вставить("qEmployeeIsEmpty", НЕ ЗначениеЗаполнено(Employee));
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
//	|	Договора.Code AS Code,
//	|	Договора.ДатаДок AS Date,
//	|	Договора.Owner AS Контрагент,
//	|	Договора.Owner.ТипКонтрагента AS ТипКонтрагента,
//	|	Договора.ContractType,
//	|	Договора.ValidFromDate,
//	|	Договора.ValidToDate,
//	|	Договора.Автор,
//	|	Договора.Примечания,
//	|	1 AS СчетчикДокКвота
//	|{SELECT
//	|	Code,
//	|	Date,
//	|	Контрагент.*,
//	|	ТипКонтрагента.*,
//	|	ContractType.*,
//	|	ValidFromDate,
//	|	ValidToDate,
//	|	Автор.*,
//	|	Примечания,
//	|	Договора.CreateDate AS CreateDate,
//	|	Договора.Description AS Description,
//	|	Договора.Ref.* AS Договор,
//	|	Counter}
//	|FROM
//	|	Catalog.Договора AS Contracts
//	|WHERE
//	|	NOT Договора.DeletionMark
//	|	AND Договора.ДатаДок BETWEEN &qPeriodFrom AND &qPeriodTo
//	|	AND (NOT &qCompanyIsEmpty
//	|				AND Договора.Фирма IN HIERARCHY (&qCompany)
//	|			OR &qCompanyIsEmpty)
//	|	AND (NOT &qCustomerIsEmpty
//	|				AND Договора.Owner IN HIERARCHY (&qCustomer)
//	|			OR &qCustomerIsEmpty)
//	|	AND (NOT &qCustomerTypeIsEmpty
//	|				AND Договора.Owner.ТипКонтрагента IN HIERARCHY (&qCustomerType)
//	|			OR &qCustomerTypeIsEmpty)
//	|	AND (NOT &qContractTypeIsEmpty
//	|				AND Договора.ContractType = &qContractType
//	|			OR &qContractTypeIsEmpty)
//	|	AND (NOT &qEmployeeIsEmpty
//	|				AND Договора.Автор IN HIERARCHY (&qEmployee)
//	|			OR &qEmployeeIsEmpty)
//	|{WHERE
//	|	Договора.Code,
//	|	Договора.Description,
//	|	Договора.Owner.* AS Контрагент,
//	|	Договора.Owner.ТипКонтрагента.* AS ТипКонтрагента,
//	|	Договора.ДатаДок,
//	|	Договора.ContractType.*,
//	|	Договора.ValidFromDate,
//	|	Договора.ValidToDate,
//	|	Договора.Автор.*,
//	|	Договора.CreateDate,
//	|	Договора.Примечания,
//	|	Договора.Ref.* AS Contract}
//	|
//	|ORDER BY
//	|	Code,
//	|	Date
//	|{ORDER BY
//	|	Code,
//	|	Date,
//	|	Контрагент.*,
//	|	ТипКонтрагента.*,
//	|	ContractType.*,
//	|	ValidFromDate,
//	|	ValidToDate,
//	|	Автор.*,
//	|	Примечания,
//	|	Договора.CreateDate,
//	|	Договора.Description,
//	|	Договора.Ref.* AS Contract}
//	|TOTALS
//	|	SUM(СчетчикДокКвота)
//	|BY
//	|	OVERALL
//	|{TOTALS BY
//	|	Контрагент.*,
//	|	ТипКонтрагента.*,
//	|	ContractType.*,
//	|	Автор.*,
//	|	Договора.Ref.* AS Contract}";
//	ReportBuilder.Text = QueryText;
//	ReportBuilder.FillSettings();
//	
//	// Initialize report builder with default query
//	vRB = New ReportBuilder(QueryText);
//	vRBSettings = vRB.GetSettings(True, True, True, True, True);
//	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
//	
//	// Set default report builder header text
//	ReportBuilder.HeaderText = NStr("ru='Реестр договоров';de='Verträgen Register';en='Contracts register'");
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
