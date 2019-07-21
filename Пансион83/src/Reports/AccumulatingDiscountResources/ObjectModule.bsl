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
	If НЕ ЗначениеЗаполнено(PeriodFrom) Тогда
		PeriodFrom = BegOfYear(CurrentDate()); // For beg. of year
	EndIf;
	If НЕ ЗначениеЗаполнено(PeriodTo) Тогда
		PeriodTo = CurrentDate(); // Current date
	EndIf;
КонецПроцедуры //pmFillAttributesWithDefaultValues

//-----------------------------------------------------------------------------
Function pmGetReportParametersPresentation() Экспорт
	vParamPresentation = "";
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
	If ЗначениеЗаполнено(DiscountType) Тогда
		If НЕ DiscountType.IsFolder Тогда
			vParamPresentation = vParamPresentation + NStr("ru = 'Тип скидки '; en = 'Discount type '") + 
			                     TrimAll(DiscountType.Description) + 
			                     ";" + Chars.LF;
		Else
			vParamPresentation = vParamPresentation + NStr("ru = 'Группа типов скидок '; en = 'Discount types folder '") + 
			                     TrimAll(DiscountType.Description) + 
			                     ";" + Chars.LF;
		EndIf;
	EndIf;							 
	If ЗначениеЗаполнено(DiscountDimension) Тогда
		If НЕ DiscountDimension.IsFolder Тогда
			vParamPresentation = vParamPresentation + NStr("ru = 'Измерение '; en = 'Dimension '") + 
			                     TrimAll(DiscountDimension.Description) + 
			                     ";" + Chars.LF;
		Else
			vParamPresentation = vParamPresentation + NStr("ru = 'Группа измерений '; en = 'Dimensions folder '") + 
			                     TrimAll(DiscountDimension.Description) + 
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
	ReportBuilder.Parameters.Вставить("qDiscountType", DiscountType);
	ReportBuilder.Parameters.Вставить("qIsEmptyDiscountType", НЕ ЗначениеЗаполнено(DiscountType));
	ReportBuilder.Parameters.Вставить("qDiscountDimension", DiscountDimension);
	ReportBuilder.Parameters.Вставить("qIsEmptyDiscountDimension", НЕ ЗначениеЗаполнено(DiscountDimension));
	
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
	|	AccumulatingDiscountResourcesBalanceAndTurnovers.ТипСкидки AS ТипСкидки,
	|	AccumulatingDiscountResourcesBalanceAndTurnovers.ИзмерениеСкидки AS ИзмерениеСкидки,
	|	AccumulatingDiscountResourcesBalanceAndTurnovers.Period AS Period,
	|	AccumulatingDiscountResourcesBalanceAndTurnovers.ГруппаГостей,
	|	AccumulatingDiscountResourcesBalanceAndTurnovers.ResourceOpeningBalance AS ResourceOpeningBalance,
	|	AccumulatingDiscountResourcesBalanceAndTurnovers.ResourceTurnover AS ResourceTurnover,
	|	AccumulatingDiscountResourcesBalanceAndTurnovers.ResourceClosingBalance AS ResourceClosingBalance,
	|	AccumulatingDiscountResourcesBalanceAndTurnovers.BonusOpeningBalance AS BonusOpeningBalance,
	|	AccumulatingDiscountResourcesBalanceAndTurnovers.BonusReceipt AS BonusReceipt,
	|	AccumulatingDiscountResourcesBalanceAndTurnovers.BonusExpense AS BonusExpense,
	|	AccumulatingDiscountResourcesBalanceAndTurnovers.BonusClosingBalance AS BonusClosingBalance
	|{SELECT
	|	ТипСкидки.*,
	|	ИзмерениеСкидки.*,
	|	Period,
	|	ГруппаГостей.*,
	|	ResourceOpeningBalance,
	|	ResourceTurnover,
	|	ResourceClosingBalance,
	|	BonusOpeningBalance,
	|	BonusReceipt,
	|	BonusExpense,
	|	BonusClosingBalance}
	|FROM
	|	AccumulationRegister.НакопитСкидки.BalanceAndTurnovers(
	|			&qPeriodFrom,
	|			&qPeriodTo,
	|			Day,
	|			RegisterRecordsAndPeriodBoundaries,
	|			(ИзмерениеСкидки IN HIERARCHY (&qDiscountDimension)
	|				OR &qIsEmptyDiscountDimension)
	|				AND (ТипСкидки IN HIERARCHY (&qDiscountType)
	|					OR &qIsEmptyDiscountType)) AS AccumulatingDiscountResourcesBalanceAndTurnovers
	|{WHERE
	|	AccumulatingDiscountResourcesBalanceAndTurnovers.ТипСкидки.*,
	|	AccumulatingDiscountResourcesBalanceAndTurnovers.ИзмерениеСкидки.*,
	|	AccumulatingDiscountResourcesBalanceAndTurnovers.ГруппаГостей.*,
	|	AccumulatingDiscountResourcesBalanceAndTurnovers.BonusOpeningBalance,
	|	AccumulatingDiscountResourcesBalanceAndTurnovers.BonusReceipt,
	|	AccumulatingDiscountResourcesBalanceAndTurnovers.BonusExpense,
	|	AccumulatingDiscountResourcesBalanceAndTurnovers.BonusClosingBalance,
	|	AccumulatingDiscountResourcesBalanceAndTurnovers.ResourceOpeningBalance,
	|	AccumulatingDiscountResourcesBalanceAndTurnovers.ResourceTurnover,
	|	AccumulatingDiscountResourcesBalanceAndTurnovers.ResourceClosingBalance}
	|
	|ORDER BY
	|	ТипСкидки,
	|	ИзмерениеСкидки,
	|	Period,
	|	AccumulatingDiscountResourcesBalanceAndTurnovers.ГруппаГостей
	|{ORDER BY
	|	ТипСкидки.*,
	|	ИзмерениеСкидки.*,
	|	Period,
	|	ГруппаГостей.*,
	|	ResourceOpeningBalance,
	|	ResourceTurnover,
	|	ResourceClosingBalance,
	|	BonusOpeningBalance,
	|	BonusReceipt,
	|	BonusExpense,
	|	BonusClosingBalance}
	|TOTALS
	|	SUM(ResourceOpeningBalance),
	|	SUM(ResourceTurnover),
	|	SUM(ResourceClosingBalance),
	|	SUM(BonusOpeningBalance),
	|	SUM(BonusReceipt),
	|	SUM(BonusExpense),
	|	SUM(BonusClosingBalance)
	|BY
	|	ТипСкидки,
	|	ИзмерениеСкидки,
	|	Period
	|{TOTALS BY
	|	ТипСкидки.*,
	|	ИзмерениеСкидки.*,
	|	Period,
	|	ГруппаГостей.*}";
	ReportBuilder.Text = QueryText;
	ReportBuilder.FillSettings();
	
	// Initialize report builder with default query
	vRB = New ReportBuilder(QueryText);
	vRBSettings = vRB.GetSettings(True, True, True, True, True);
	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
	
	// Set default report builder header text
	ReportBuilder.HeaderText = NStr("EN='Accumulating discount resources';RU='Ресурсы накопительных скидок';de='Ressourcen summarischer Preisnachlässe'");
	
	// Fill report builder fields presentations from the report template
	
	// Reset report builder template
	ReportBuilder.Template = Неопределено;
КонецПроцедуры //pmInitializeReportBuilder

//-----------------------------------------------------------------------------
Function pmIsResource(pName) Экспорт
	If pName = "ResourceOpeningBalance" 
	   Or pName = "ResourceOpeningBalance" 
	   Or pName = "ResourceOpeningBalance" 
	   Or pName = "BonusOpeningBalance" 
	   Or pName = "BonusReceipt" 
	   Or pName = "BonusExpense" 
	   Or pName = "BonusTurnover" 
	   Or pName = "BonusClosingBalance" Тогда
		Return True;
	Else
		Return False;
	EndIf;
EndFunction //pmIsResource

//-----------------------------------------------------------------------------
// Reports framework end
//-----------------------------------------------------------------------------
