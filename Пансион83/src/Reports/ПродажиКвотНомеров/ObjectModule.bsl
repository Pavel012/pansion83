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
//		If НЕ ЗначениеЗаполнено(PeriodFrom) Тогда
//			PeriodFrom = BegOfMonth(CurrentDate()); // For beg. of month
//			PeriodTo = EndOfDay(CurrentDate());
//		EndIf;
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
//	If ЗначениеЗаполнено(RoomQuota) Тогда
//		If НЕ RoomQuota.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("ru = 'Квота номеров '; en = 'Allotment '") + 
//			                     TrimAll(RoomQuota.Description) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("ru = 'Группа квот номеров '; en = 'Allotments folder '") + 
//			                     TrimAll(RoomQuota.Description) + 
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
//	If ЗначениеЗаполнено(Agent) Тогда
//		If НЕ Agent.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("en='Agent ';ru='Агент ';de='Vertreter'") + 
//			                     TrimAll(Agent.Description) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("en='Agents folder ';ru='Группа агентов ';de='Gruppe Vertreter'") + 
//			                     TrimAll(Agent.Description) + 
//			                     ";" + Chars.LF;
//		EndIf;
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
//	ReportBuilder.Parameters.Вставить("qHotel", Гостиница);
//	ReportBuilder.Parameters.Вставить("qIsEmptyHotel", НЕ ЗначениеЗаполнено(Гостиница));
//	ReportBuilder.Parameters.Вставить("qPeriodFrom", PeriodFrom);
//	ReportBuilder.Parameters.Вставить("qPeriodTo", PeriodTo);
//	ReportBuilder.Parameters.Вставить("qAgent", Agent);
//	ReportBuilder.Parameters.Вставить("qIsEmptyAgent", НЕ ЗначениеЗаполнено(Agent));
//	ReportBuilder.Parameters.Вставить("qCustomer", Контрагент);
//	ReportBuilder.Parameters.Вставить("qIsEmptyCustomer", НЕ ЗначениеЗаполнено(Контрагент));
//	ReportBuilder.Parameters.Вставить("qContract", Contract);
//	ReportBuilder.Parameters.Вставить("qIsEmptyContract", НЕ ЗначениеЗаполнено(Contract));
//	ReportBuilder.Parameters.Вставить("qRoomQuota", RoomQuota);
//	ReportBuilder.Parameters.Вставить("qIsEmptyRoomQuota", НЕ ЗначениеЗаполнено(RoomQuota));
//	ReportBuilder.Parameters.Вставить("qRoomType", RoomType);
//	ReportBuilder.Parameters.Вставить("qIsEmptyRoomType", НЕ ЗначениеЗаполнено(RoomType));
//	If BegOfDay(PeriodTo) = BegOfDay(PeriodFrom) Тогда
//		ReportBuilder.Parameters.Вставить("qIsOneDayPeriod", True);
//	Else
//		ReportBuilder.Parameters.Вставить("qIsOneDayPeriod", False);
//	EndIf;
//	
//	// Execute report builder query
//	ReportBuilder.Execute();
//	
//	// Apply appearance settings to the report template
//	//vTemplateAttributes = cmApplyReportTemplateAppearance(ThisObject);
//	
//	// Add details parameter to the report dates
//	vPeriodArea = ReportBuilder.Template.FindText("Period", ReportBuilder.Template.Area(5, 1));
//	If vPeriodArea <> Неопределено Тогда
//		vPeriodArea.DetailsParameter = vPeriodArea.Parameter;
//	EndIf;
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
//	|	ПродажиКвот.КвотаНомеров.Агент AS Агент,
//	|	ПродажиКвот.КвотаНомеров.Контрагент AS Контрагент,
//	|	ПродажиКвот.КвотаНомеров.Договор AS Договор,
//	|	ПродажиКвот.КвотаНомеров AS КвотаНомеров,
//	|	ПродажиКвот.ТипНомера AS ТипНомера,
//	|	ПродажиКвот.Period AS Period,
//	|	SUM(ПродажиКвот.RoomsInQuotaClosingBalance) AS RoomsInQuotaClosingBalance,
//	|	SUM(ПродажиКвот.BedsInQuotaClosingBalance) AS BedsInQuotaClosingBalance,
//	|	-SUM(ПродажиКвот.RoomsReservedClosingBalance) AS RoomsReservedClosingBalance,
//	|	-SUM(ПродажиКвот.BedsReservedClosingBalance) AS BedsReservedClosingBalance,
//	|	-SUM(ПродажиКвот.GuaranteedRoomsReservedClosingBalance) AS GuaranteedRoomsReservedClosingBalance,
//	|	-SUM(ПродажиКвот.GuaranteedBedsReservedClosingBalance) AS GuaranteedBedsReservedClosingBalance,
//	|	-SUM(ПродажиКвот.InHouseRoomsClosingBalance) AS InHouseRoomsClosingBalance,
//	|	-SUM(ПродажиКвот.InHouseBedsClosingBalance) AS InHouseBedsClosingBalance,
//	|	SUM(ПродажиКвот.RoomsRemainsClosingBalance) AS RoomsRemainsClosingBalance,
//	|	SUM(ПродажиКвот.BedsRemainsClosingBalance) AS BedsRemainsClosingBalance
//	|{SELECT
//	|	Агент.* AS Агент,
//	|	Контрагент.* AS Контрагент,
//	|	Договор.* AS Договор,
//	|	КвотаНомеров.* AS КвотаНомеров,
//	|	ТипНомера.* AS ТипНомера,
//	|	ПродажиКвот.Гостиница.* AS Гостиница,
//	|	ПродажиКвот.НомерРазмещения.* AS НомерРазмещения,
//	|	Period,
//	|	RoomsInQuotaClosingBalance,
//	|	BedsInQuotaClosingBalance,
//	|	RoomsReservedClosingBalance,
//	|	BedsReservedClosingBalance,
//	|	GuaranteedRoomsReservedClosingBalance,
//	|	GuaranteedBedsReservedClosingBalance,
//	|	InHouseRoomsClosingBalance,
//	|	InHouseBedsClosingBalance,
//	|	RoomsRemainsClosingBalance,
//	|	BedsRemainsClosingBalance}
//	|FROM
//	|	AccumulationRegister.ПродажиКвот.BalanceAndTurnovers(
//	|			&qPeriodFrom,
//	|			&qPeriodTo,
//	|			Day,
//	|			RegisterRecordsAndPeriodBoundaries,
//	|			(Гостиница IN HIERARCHY (&qHotel)
//	|				OR &qIsEmptyHotel)
//	|				AND (КвотаНомеров IN HIERARCHY (&qRoomQuota)
//	|					OR &qIsEmptyRoomQuota)
//	|				AND (КвотаНомеров.Агент IN HIERARCHY (&qAgent)
//	|					OR &qIsEmptyAgent)
//	|				AND (КвотаНомеров.Контрагент IN HIERARCHY (&qCustomer)
//	|					OR &qIsEmptyCustomer)
//	|				AND (КвотаНомеров.Договор = &qContract
//	|					OR &qIsEmptyContract)
//	|				AND (ТипНомера IN HIERARCHY (&qRoomType)
//	|					OR &qIsEmptyRoomType)) AS ПродажиКвот
//	|{WHERE
//	|	ПродажиКвот.КвотаНомеров.Агент.* AS Агент,
//	|	ПродажиКвот.КвотаНомеров.Контрагент.* AS Контрагент,
//	|	ПродажиКвот.КвотаНомеров.Договор.* AS Договор,
//	|	ПродажиКвот.КвотаНомеров.* AS КвотаНомеров,
//	|	ПродажиКвот.Гостиница.* AS Гостиница,
//	|	ПродажиКвот.ТипНомера.* AS ТипНомера,
//	|	ПродажиКвот.НомерРазмещения.* AS НомерРазмещения,
//	|	RoomsInQuotaClosingBalance,
//	|	BedsInQuotaClosingBalance,
//	|	RoomsReservedClosingBalance,
//	|	BedsReservedClosingBalance,
//	|	GuaranteedRoomsReservedClosingBalance,
//	|	GuaranteedBedsReservedClosingBalance,
//	|	InHouseRoomsClosingBalance,
//	|	InHouseBedsClosingBalance,
//	|	RoomsRemainsClosingBalance,
//	|	BedsRemainsClosingBalance,
//	|	ПродажиКвот.Period}
//	|
//	|GROUP BY
//	|	ПродажиКвот.КвотаНомеров.Агент,
//	|	ПродажиКвот.КвотаНомеров.Контрагент,
//	|	ПродажиКвот.КвотаНомеров.Договор,
//	|	ПродажиКвот.КвотаНомеров,
//	|	ПродажиКвот.ТипНомера,
//	|	ПродажиКвот.Period
//	|
//	|ORDER BY
//	|	Агент,
//	|	Контрагент,
//	|	Договор,
//	|	КвотаНомеров,
//	|	ТипНомера,
//	|	Period
//	|{ORDER BY
//	|	Агент.* AS Агент,
//	|	Контрагент.* AS Контрагент,
//	|	Договор.* AS Договор,
//	|	КвотаНомеров.* AS КвотаНомеров,
//	|	ПродажиКвот.Гостиница.* AS Гостиница,
//	|	ТипНомера.* AS ТипНомера,
//	|	ПродажиКвот.НомерРазмещения.* AS НомерРазмещения,
//	|	RoomsInQuotaClosingBalance,
//	|	BedsInQuotaClosingBalance,
//	|	RoomsReservedClosingBalance,
//	|	BedsReservedClosingBalance,
//	|	GuaranteedRoomsReservedClosingBalance,
//	|	GuaranteedBedsReservedClosingBalance,
//	|	InHouseRoomsClosingBalance,
//	|	InHouseBedsClosingBalance,
//	|	RoomsRemainsClosingBalance,
//	|	BedsRemainsClosingBalance,
//	|	Period}
//	|TOTALS
//	|	CASE
//	|		WHEN &qIsOneDayPeriod THEN
//	|			SUM(RoomsInQuotaClosingBalance)
//	|		ELSE
//	|			NULL
//	|	END AS RoomsInQuotaClosingBalance,
//	|	CASE
//	|		WHEN &qIsOneDayPeriod THEN
//	|			SUM(BedsInQuotaClosingBalance)
//	|		ELSE
//	|			NULL
//	|	END AS BedsInQuotaClosingBalance,
//	|	CASE
//	|		WHEN &qIsOneDayPeriod THEN
//	|			SUM(RoomsReservedClosingBalance)
//	|		ELSE
//	|			NULL
//	|	END AS RoomsReservedClosingBalance,
//	|	CASE
//	|		WHEN &qIsOneDayPeriod THEN
//	|			SUM(BedsReservedClosingBalance)
//	|		ELSE
//	|			NULL
//	|	END AS BedsReservedClosingBalance,
//	|	CASE
//	|		WHEN &qIsOneDayPeriod THEN
//	|			SUM(GuaranteedRoomsReservedClosingBalance)
//	|		ELSE
//	|			NULL
//	|	END AS GuaranteedRoomsReservedClosingBalance,
//	|	CASE
//	|		WHEN &qIsOneDayPeriod THEN
//	|			SUM(GuaranteedBedsReservedClosingBalance)
//	|		ELSE
//	|			NULL
//	|	END AS GuaranteedBedsReservedClosingBalance,
//	|	CASE
//	|		WHEN &qIsOneDayPeriod THEN
//	|			SUM(InHouseRoomsClosingBalance)
//	|		ELSE
//	|			NULL
//	|	END AS InHouseRoomsClosingBalance,
//	|	CASE
//	|		WHEN &qIsOneDayPeriod THEN
//	|			SUM(InHouseBedsClosingBalance)
//	|		ELSE
//	|			NULL
//	|	END AS InHouseBedsClosingBalance,
//	|	CASE
//	|		WHEN &qIsOneDayPeriod THEN
//	|			SUM(RoomsRemainsClosingBalance)
//	|		ELSE
//	|			NULL
//	|	END AS RoomsRemainsClosingBalance,
//	|	CASE
//	|		WHEN &qIsOneDayPeriod THEN
//	|			SUM(BedsRemainsClosingBalance)
//	|		ELSE
//	|			NULL
//	|	END AS BedsRemainsClosingBalance
//	|BY
//	|	Агент,
//	|	Контрагент,
//	|	Договор,
//	|	КвотаНомеров,
//	|	ТипНомера,
//	|	Period
//	|{TOTALS BY
//	|	Агент.* AS Агент,
//	|	Контрагент.* AS Контрагент,
//	|	Договор.* AS Договор,
//	|	КвотаНомеров.* AS КвотаНомеров,
//	|	ПродажиКвот.Гостиница.* AS Гостиница,
//	|	ТипНомера.* AS ТипНомера,
//	|	ПродажиКвот.НомерРазмещения.* AS НомерРазмещения,
//	|	Period}";
//	ReportBuilder.Text = QueryText;
//	ReportBuilder.FillSettings();
//	
//	// Initialize report builder with default query
//	vRB = New ReportBuilder(QueryText);
//	vRBSettings = vRB.GetSettings(True, True, True, True, True);
//	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
//	
//	// Set default report builder header text
//	ReportBuilder.HeaderText = NStr("en='Allotment sales';ru='Продажи квот номеров';de='Verkäufe von Zimmerkontingenten'");
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
//	If pName = "RoomsInQuotaClosingBalance" Or
//	   pName = "BedsInQuotaClosingBalance" Or 
//	   pName = "RoomsReservedClosingBalance" Or 
//	   pName = "BedsReservedClosingBalance" Or 
//	   pName = "InHouseRoomsClosingBalance" Or 
//	   pName = "InHouseBedsClosingBalance" Or 
//	   pName = "RoomsRemainsClosingBalance" Or 
//	   pName = "BedsRemainsClosingBalance" Тогда
//		Return True;
//	Else
//		Return False;
//	EndIf;
//EndFunction //pmIsResource
//
////-----------------------------------------------------------------------------
//// Reports framework end
////-----------------------------------------------------------------------------
