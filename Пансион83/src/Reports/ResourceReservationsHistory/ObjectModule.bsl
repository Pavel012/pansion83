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
//	If НЕ ЗначениеЗаполнено(PeriodCheckType) Тогда
//		PeriodCheckType = Перечисления.PeriodCheckTypes.Intersection;
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
//	If НЕ ЗначениеЗаполнено(PeriodCheckType) Тогда
//		vParamPresentation = vParamPresentation + NStr("en='Report period check type is not set';ru='Вид проверки периода отчета не установлен';de='Art der Kontrolle des Berichtszeitraums nicht festgelegt'") + 
//		                     ";" + Chars.LF;
//	ElsIf PeriodCheckType = Перечисления.PeriodCheckTypes.Intersection Тогда
//		vParamPresentation = vParamPresentation + NStr("en='Reservations for the period selected';ru='Отбор брони в выбранном периоде';de='Reservierungsauswahl im gewählten Zeitraum'") + 
//		                     ";" + Chars.LF;
//	ElsIf PeriodCheckType = Перечисления.PeriodCheckTypes.StartsInPeriod Тогда
//		vParamPresentation = vParamPresentation + NStr("en='Reservations with time from in the period selected';ru='Отбор брони с временем начала в выбранном периоде';de='Auswahl der Buchung mit Beginnzeit im gewählten Zeitraum'") + 
//		                     ";" + Chars.LF;
//	ElsIf PeriodCheckType = Перечисления.PeriodCheckTypes.EndsInPeriod Тогда
//		vParamPresentation = vParamPresentation + NStr("en='Reservations with time to in the period selected';ru='Отбор брони с временем окончания в выбранном периоде';de='Auswahl der Buchung mit Endzeit im gewählten Zeitraum'") + 
//		                     ";" + Chars.LF;
//	ElsIf PeriodCheckType = Перечисления.PeriodCheckTypes.StartsOrEndsInPeriod Тогда
//		vParamPresentation = vParamPresentation + NStr("en='Reservations with time from or time to in the period selected';ru='Отбор брони с временем начала или временем окончания в выбранном периоде';de='Auswahl der Buchung mit Beginn- und Endzeit im gewählten Zeitraum'") + 
//		                     ";" + Chars.LF;
//	ElsIf PeriodCheckType = Перечисления.PeriodCheckTypes.DocDateInPeriod Тогда
//		vParamPresentation = vParamPresentation + NStr("en='Reservations with creation date in the period selected';ru='Отбор брони с датой создания в выбранном периоде';de='Auswahl der Buchung mit Erstellungsdatum im gewählten Zeitraum'") + 
//		                     ";" + Chars.LF;
//	Endif;		
//	If ЗначениеЗаполнено(Resource) Тогда
//		vParamPresentation = vParamPresentation + NStr("en='Resource ';ru='Ресурс ';de='Ressource'") + 
//							 TrimAll(Resource.Description) + 
//							 ";" + Chars.LF;
//	EndIf;
//	If ЗначениеЗаполнено(ResourceType) Тогда
//		If НЕ ResourceType.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("en='Resource type ';ru='Тип ресурса ';de='Ressourcentyp'") + 
//			                     TrimAll(ResourceType.Description) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("en='Resource types folder ';ru='Группа типов ресурсов ';de='Gruppe Ressourcentypen'") + 
//			                     TrimAll(ResourceType.Description) + 
//			                     ";" + Chars.LF;
//		EndIf;
//	EndIf;
//	If ЗначениеЗаполнено(GuestGroup) Тогда
//		If НЕ GuestGroup.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("en='Group ';ru='Группа ';de='Gruppe '") + 
//			                     TrimAll(GuestGroup.Description) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("ru = 'Папка групп '; en = 'Groups folder '") + 
//			                     TrimAll(GuestGroup.Description) + 
//			                     ";" + Chars.LF;
//		EndIf;
//	EndIf;
//	If ShowActiveOnly Тогда
//		vParamPresentation = vParamPresentation + NStr("en='Active reservations only';ru='Только действующая бронь';de='Nur gültige Reservierung'") + 
//							 ";" + Chars.LF;
//	EndIf;
//	If ShowInactiveOnly Тогда
//		vParamPresentation = vParamPresentation + NStr("en='Inactive reservations only';ru='Только недействующая бронь';de='Nur ungültige Reservierung'") + 
//							 ";" + Chars.LF;
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
//	ReportBuilder.Parameters.Вставить("qGuestGroup", GuestGroup);
//	ReportBuilder.Parameters.Вставить("qGuestGroupIsEmpty", НЕ ЗначениеЗаполнено(GuestGroup));
//	ReportBuilder.Parameters.Вставить("qPeriodFrom", PeriodFrom);
//	ReportBuilder.Parameters.Вставить("qPeriodTo", PeriodTo);
//	ReportBuilder.Parameters.Вставить("qBegOfTime", '00010101');
//	ReportBuilder.Parameters.Вставить("qEndOfTime", '39991231235959');
//	ReportBuilder.Parameters.Вставить("qBegOfCurrentDate", BegOfDay(CurrentDate()));
//	ReportBuilder.Parameters.Вставить("qPeriodCheckType", PeriodCheckType);
//	ReportBuilder.Parameters.Вставить("qIntersection", Перечисления.PeriodCheckTypes.Intersection);
//	ReportBuilder.Parameters.Вставить("qCheckIn", Перечисления.PeriodCheckTypes.StartsInPeriod);
//	ReportBuilder.Parameters.Вставить("qCheckOut", Перечисления.PeriodCheckTypes.EndsInPeriod);
//	ReportBuilder.Parameters.Вставить("qCheckInOrCheckOut", Перечисления.PeriodCheckTypes.StartsOrEndsInPeriod);
//	ReportBuilder.Parameters.Вставить("qDocDateInPeriod", Перечисления.PeriodCheckTypes.DocDateInPeriod);
//	ReportBuilder.Parameters.Вставить("qResource", Resource);
//	ReportBuilder.Parameters.Вставить("qResourceIsEmpty", НЕ ЗначениеЗаполнено(Resource));
//	ReportBuilder.Parameters.Вставить("qResourceType", ResourceType);
//	ReportBuilder.Parameters.Вставить("qResourceTypeIsEmpty", НЕ ЗначениеЗаполнено(ResourceType));
//	ReportBuilder.Parameters.Вставить("qRecordType", AccumulationRecordType.Expense);
//	ReportBuilder.Parameters.Вставить("qShowActiveOnly", ShowActiveOnly);
//	ReportBuilder.Parameters.Вставить("qShowInactiveOnly", ShowInactiveOnly);
//	ReportBuilder.Parameters.Вставить("qShowInvoicesAndDeposits", ShowInvoicesAndDeposits);
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
//	|	Reservations.Гостиница AS Гостиница,
//	|	Reservations.Контрагент AS Контрагент,
//	|	Reservations.Договор AS Договор,
//	|	Reservations.ГруппаГостей AS ГруппаГостей,
//	|	Reservations.Ref.ResourceReservationStatus AS ResourceReservationStatus,
//	|	Reservations.Ref.Клиент AS Клиент,
//	|	Reservations.Ref.DateTimeFrom AS DateTimeFrom,
//	|	Reservations.Ref.Продолжительность AS Продолжительность,
//	|	Reservations.Ref.DateTimeTo AS DateTimeTo,
//	|	Reservations.Ref.ТипРесурса AS ТипРесурса,
//	|	Reservations.Ref.Ресурс AS Ресурс,
//	|	Reservations.Ref AS Recorder,
//	|	Reservations.КоличествоЧеловек AS КоличествоЧеловек
//	|{SELECT
//	|	Гостиница.* AS Гостиница,
//	|	Reservations.Ref.Агент.* AS Агент,
//	|	Reservations.Ref.ТипКонтрагента AS ТипКонтрагента,
//	|	Контрагент.* AS Контрагент,
//	|	Договор.* AS Договор,
//	|	ГруппаГостей.* AS ГруппаГостей,
//	|	Reservations.КонтактноеЛицо AS КонтактноеЛицо,
//	|	Reservations.Ref.ТипКлиента.* AS ТипКлиента,
//	|	DateTimeFrom AS DateTimeFrom,
//	|	Продолжительность AS Продолжительность,
//	|	DateTimeTo AS DateTimeTo,
//	|	(HOUR(Reservations.Ref.DateTimeFrom)) AS FromHour,
//	|	(DAY(Reservations.Ref.DateTimeFrom)) AS FromDay,
//	|	(WEEK(Reservations.Ref.DateTimeFrom)) AS FromWeek,
//	|	(MONTH(Reservations.Ref.DateTimeFrom)) AS FromMonth,
//	|	(QUARTER(Reservations.Ref.DateTimeFrom)) AS FromQuarter,
//	|	(YEAR(Reservations.Ref.DateTimeFrom)) AS FromYear,
//	|	Клиент.* AS Клиент,
//	|	ТипРесурса.* AS ТипРесурса,
//	|	Ресурс.* AS Ресурс,
//	|	Reservations.Ref.PlannedPaymentMethod.* AS PlannedPaymentMethod,
//	|	Reservations.Ref.PricePresentation AS PricePresentation,
//	|	ResourceReservationStatus.* AS ResourceReservationStatus,
//	|	Reservations.Ref.МаретингНапрвл.* AS МаретингНапрвл,
//	|	Reservations.Ref.ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
//	|	Reservations.Ref.ДисконтКарт AS ДисконтКарт,
//	|	Reservations.Ref.ТипСкидки AS ТипСкидки,
//	|	Reservations.Ref.Скидка AS Скидка,
//	|	Reservations.Ref.КомиссияАгента AS КомиссияАгента,
//	|	Reservations.Ref.ВидКомиссииАгента AS ВидКомиссииАгента,
//	|	Reservations.Ref.ДокОснование.* AS ДокОснование,
//	|	Reservations.Фирма.* AS Фирма,
//	|	Reservations.Примечания AS Примечания,
//	|	Reservations.Ref.Car AS Car,
//	|	Reservations.Автор.* AS Автор,
//	|	Reservations.Ref.* AS Recorder,
//	|	Reservations.КоличествоЧеловек AS КоличествоЧеловек,
//	|	Reservations.Account.*,
//	|	Reservations.ВалютаСчета.*,
//	|	Reservations.DaysBeforeDateFrom,
//	|	Reservations.InvoiceAge,
//	|	Reservations.SumInvoice,
//	|	Reservations.SumPayed,
//	|	Reservations.AccountBalance}
//	|FROM
//	|	(SELECT
//	|		ReservationTotals.Ref.Гостиница AS Гостиница,
//	|		ReservationTotals.Ref.ГруппаГостей AS ГруппаГостей,
//	|		ReservationTotals.Ref.Контрагент AS Контрагент,
//	|		ReservationTotals.Ref.Договор AS Договор,
//	|		ReservationTotals.Ref.КонтактноеЛицо AS КонтактноеЛицо,
//	|		ReservationTotals.Ref AS Ref,
//	|		ReservationTotals.Ref.Примечания AS Примечания,
//	|		ReservationTotals.Ref.Фирма AS Фирма,
//	|		ReservationTotals.Ref.Автор AS Автор,
//	|		ReservationFolioBalances.СчетПроживания AS Account,
//	|		ReservationFolioBalances.ВалютаЛицСчета AS ВалютаСчета,
//	|		DATEDIFF(&qBegOfCurrentDate, BEGINOFPERIOD(ReservationTotals.Ref.DateTimeFrom, DAY), DAY) AS DaysBeforeDateFrom,
//	|		0 AS InvoiceAge,
//	|		0 AS SumInvoice,
//	|		ISNULL(ReservationFolioBalances.FolioBalance, 0) AS AccountBalance,
//	|		0 AS SumPayed,
//	|		ReservationTotals.КоличествоЧеловек AS КоличествоЧеловек
//	|	FROM
//	|		(SELECT
//	|			ReservationsRef.Ref AS Ref,
//	|			ReservationsRef.КоличествоЧеловек AS КоличествоЧеловек
//	|		FROM
//	|			Document.БроньУслуг AS ReservationsRef
//	|		WHERE
//	|			ReservationsRef.Posted
//	|			AND (ReservationsRef.Гостиница IN HIERARCHY (&qHotel)
//	|					OR &qHotelIsEmpty)
//	|			AND (ReservationsRef.ГруппаГостей = &qGuestGroup
//	|					OR &qGuestGroupIsEmpty)
//	|			AND (ReservationsRef.Ресурс = &qResource
//	|					OR &qResourceIsEmpty)
//	|			AND (ReservationsRef.ТипРесурса IN HIERARCHY (&qResourceType)
//	|					OR &qResourceTypeIsEmpty)
//	|			AND (ISNULL(ReservationsRef.ResourceReservationStatus.IsActive, FALSE)
//	|					OR (NOT &qShowActiveOnly))
//	|			AND ((NOT ISNULL(ReservationsRef.ResourceReservationStatus.IsActive, FALSE))
//	|					OR (NOT &qShowInactiveOnly))
//	|			AND (ReservationsRef.DateTimeFrom < &qPeriodTo
//	|						AND ReservationsRef.DateTimeTo > &qPeriodFrom
//	|						AND &qPeriodCheckType = &qIntersection
//	|					OR ReservationsRef.DateTimeFrom >= &qPeriodFrom
//	|						AND ReservationsRef.DateTimeFrom < &qPeriodTo
//	|						AND (&qPeriodCheckType = &qCheckIn
//	|							OR &qPeriodCheckType = &qCheckInOrCheckOut)
//	|					OR ReservationsRef.DateTimeTo > &qPeriodFrom
//	|						AND ReservationsRef.DateTimeTo <= &qPeriodTo
//	|						AND (&qPeriodCheckType = &qCheckOut
//	|							OR &qPeriodCheckType = &qCheckInOrCheckOut)
//	|					OR ReservationsRef.ДатаДок >= &qPeriodFrom
//	|						AND ReservationsRef.ДатаДок < &qPeriodTo
//	|						AND &qPeriodCheckType = &qDocDateInPeriod)) AS ReservationTotals
//	|			LEFT JOIN (SELECT
//	|				AccountsBalance.СчетПроживания AS СчетПроживания,
//	|				AccountsBalance.ВалютаЛицСчета AS ВалютаЛицСчета,
//	|				AccountsBalance.СчетПроживания.ДокОснование AS FolioParentDoc,
//	|				SUM(AccountsBalance.SumBalance) AS FolioBalance
//	|			FROM
//	|				AccumulationRegister.Взаиморасчеты.Balance(&qEndOfTime, СчетПроживания.Гостиница IN HIERARCHY (&qHotel)) AS AccountsBalance
//	|			
//	|			GROUP BY
//	|				AccountsBalance.СчетПроживания,
//	|				AccountsBalance.ВалютаЛицСчета,
//	|				AccountsBalance.СчетПроживания.ДокОснование) AS ReservationFolioBalances
//	|			ON ReservationTotals.Ref = ReservationFolioBalances.FolioParentDoc
//	|				AND (&qShowInvoicesAndDeposits)
//	|	
//	|	UNION ALL
//	|	
//	|	SELECT
//	|		InvoiceAccountsTurnovers.Гостиница,
//	|		InvoiceAccountsTurnovers.ГруппаГостей,
//	|		InvoiceAccountsTurnovers.Контрагент,
//	|		InvoiceAccountsTurnovers.Договор,
//	|		InvoiceAccountsTurnovers.СчетНаОплату.КонтактноеЛицо,
//	|		NULL,
//	|		InvoiceAccountsTurnovers.СчетНаОплату.Примечания,
//	|		InvoiceAccountsTurnovers.Фирма,
//	|		InvoiceAccountsTurnovers.СчетНаОплату.Автор,
//	|		InvoiceAccountsTurnovers.СчетНаОплату,
//	|		InvoiceAccountsTurnovers.ВалютаРасчетов,
//	|		0,
//	|		DATEDIFF(BEGINOFPERIOD(InvoiceAccountsTurnovers.СчетНаОплату.ДатаДок, DAY), &qBegOfCurrentDate, DAY),
//	|		InvoiceAccountsTurnovers.SumReceipt,
//	|		InvoiceAccountsTurnovers.SumReceipt - InvoiceAccountsTurnovers.SumExpense,
//	|		InvoiceAccountsTurnovers.SumExpense,
//	|		0
//	|	FROM
//	|		AccumulationRegister.ВзаиморасчетыПоСчетам.Turnovers(
//	|				&qBegOfTime,
//	|				&qEndOfTime,
//	|				Period,
//	|				Гостиница IN HIERARCHY (&qHotel)
//	|					AND ГруппаГостей IN
//	|						(SELECT
//	|							PlannedFrom.ГруппаГостей
//	|						FROM
//	|							Document.БроньУслуг AS PlannedFrom
//	|						WHERE
//	|							PlannedFrom.Posted
//	|							AND (PlannedFrom.Гостиница IN HIERARCHY (&qHotel)
//	|								OR &qHotelIsEmpty)
//	|							AND (PlannedFrom.ГруппаГостей = &qGuestGroup
//	|								OR &qGuestGroupIsEmpty)
//	|							AND (PlannedFrom.Ресурс = &qResource
//	|								OR &qResourceIsEmpty)
//	|							AND (PlannedFrom.ТипРесурса IN HIERARCHY (&qResourceType)
//	|								OR &qResourceTypeIsEmpty)
//	|							AND (ISNULL(PlannedFrom.ResourceReservationStatus.IsActive, FALSE)
//	|								OR (NOT &qShowActiveOnly))
//	|							AND ((NOT ISNULL(PlannedFrom.ResourceReservationStatus.IsActive, FALSE))
//	|								OR (NOT &qShowInactiveOnly))
//	|							AND (PlannedFrom.DateTimeFrom < &qPeriodTo
//	|									AND PlannedFrom.DateTimeTo > &qPeriodFrom
//	|									AND &qPeriodCheckType = &qIntersection
//	|								OR PlannedFrom.DateTimeFrom >= &qPeriodFrom
//	|									AND PlannedFrom.DateTimeFrom < &qPeriodTo
//	|									AND (&qPeriodCheckType = &qCheckIn
//	|										OR &qPeriodCheckType = &qCheckInOrCheckOut)
//	|								OR PlannedFrom.DateTimeTo > &qPeriodFrom
//	|									AND PlannedFrom.DateTimeTo <= &qPeriodTo
//	|									AND (&qPeriodCheckType = &qCheckOut
//	|										OR &qPeriodCheckType = &qCheckInOrCheckOut)
//	|								OR PlannedFrom.ДатаДок >= &qPeriodFrom
//	|									AND PlannedFrom.ДатаДок < &qPeriodTo
//	|									AND &qPeriodCheckType = &qDocDateInPeriod)
//	|							AND &qShowInvoicesAndDeposits
//	|						GROUP BY
//	|										PlannedFrom.ГруппаГостей)) AS InvoiceAccountsTurnovers) AS Reservations
//	|{WHERE
//	|	Reservations.Ref.* AS Recorder,
//	|	Reservations.Гостиница.* AS Гостиница,
//	|	Reservations.Ref.ТипРесурса.* AS ТипРесурса,
//	|	Reservations.Ref.Ресурс.* AS Ресурс,
//	|	Reservations.Контрагент.* AS Контрагент,
//	|	Reservations.Ref.ТипКонтрагента.* AS ТипКонтрагента,
//	|	Reservations.Договор.* AS Договор,
//	|	Reservations.КонтактноеЛицо AS КонтактноеЛицо,
//	|	Reservations.Ref.Агент.* AS Агент,
//	|	Reservations.ГруппаГостей.* AS ГруппаГостей,
//	|	Reservations.Ref.ДокОснование.* AS ДокОснование,
//	|	Reservations.Ref.ResourceReservationStatus.* AS ResourceReservationStatus,
//	|	Reservations.Ref.DateTimeFrom AS DateTimeFrom,
//	|	Reservations.Ref.Продолжительность AS Продолжительность,
//	|	Reservations.Ref.DateTimeTo AS DateTimeTo,
//	|	Reservations.Ref.ТипКлиента.* AS ТипКлиента,
//	|	Reservations.Ref.Клиент.* AS Клиент,
//	|	Reservations.Ref.МаретингНапрвл.* AS МаретингНапрвл,
//	|	Reservations.Ref.ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
//	|	Reservations.Ref.ДисконтКарт AS ДисконтКарт,
//	|	Reservations.Ref.ТипСкидки AS ТипСкидки,
//	|	Reservations.Ref.Скидка AS Скидка,
//	|	Reservations.Ref.PlannedPaymentMethod.* AS PlannedPaymentMethod,
//	|	Reservations.Ref.PricePresentation AS PricePresentation,
//	|	Reservations.Фирма.* AS Фирма,
//	|	Reservations.Примечания AS Примечания,
//	|	Reservations.Ref.Car AS Car,
//	|	Reservations.Автор.* AS Автор,
//	|	Reservations.Ref.КомиссияАгента AS КомиссияАгента,
//	|	Reservations.Ref.ВидКомиссииАгента AS ВидКомиссииАгента,
//	|	Reservations.КоличествоЧеловек AS КоличествоЧеловек,
//	|	Reservations.Account.*,
//	|	Reservations.ВалютаСчета.*,
//	|	Reservations.DaysBeforeDateFrom,
//	|	Reservations.InvoiceAge,
//	|	Reservations.AccountBalance,
//	|	Reservations.SumInvoice,
//	|	Reservations.SumPayed}
//	|
//	|ORDER BY
//	|	Гостиница,
//	|	Контрагент,
//	|	Договор,
//	|	ГруппаГостей,
//	|	DateTimeFrom,
//	|	Клиент
//	|{ORDER BY
//	|	Гостиница.* AS Гостиница,
//	|	Reservations.Ref.Агент.* AS Агент,
//	|	Контрагент.* AS Контрагент,
//	|	Reservations.Ref.ТипКонтрагента.* AS ТипКонтрагента,
//	|	Договор.* AS Договор,
//	|	ГруппаГостей.* AS ГруппаГостей,
//	|	Клиент.* AS Клиент,
//	|	Reservations.Ref.МаретингНапрвл.* AS МаретингНапрвл,
//	|	Reservations.Ref.ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
//	|	Reservations.Ref.ResourceReservationStatus.* AS ResourceReservationStatus,
//	|	Reservations.Ref.ДисконтКарт.* AS ДисконтКарт,
//	|	Reservations.Ref.ТипСкидки.* AS ТипСкидки,
//	|	Reservations.Ref.PlannedPaymentMethod.* AS PlannedPaymentMethod,
//	|	Reservations.Ref.PricePresentation AS PricePresentation,
//	|	Ресурс.* AS Ресурс,
//	|	ТипРесурса.* AS ТипРесурса,
//	|	DateTimeFrom AS DateTimeFrom,
//	|	Продолжительность AS Продолжительность,
//	|	DateTimeTo AS DateTimeTo,
//	|	Reservations.Фирма.* AS Фирма,
//	|	Reservations.Автор.* AS Автор,
//	|	Reservations.Ref.ДокОснование.* AS ДокОснование,
//	|	Reservations.Ref.* AS Recorder,
//	|	(HOUR(Reservations.Ref.DateTimeFrom)) AS FromHour,
//	|	(DAY(Reservations.Ref.DateTimeFrom)) AS FromDay,
//	|	(WEEK(Reservations.Ref.DateTimeFrom)) AS FromWeek,
//	|	(MONTH(Reservations.Ref.DateTimeFrom)) AS FromMonth,
//	|	(QUARTER(Reservations.Ref.DateTimeFrom)) AS FromQuarter,
//	|	(YEAR(Reservations.Ref.DateTimeFrom)) AS FromYear,
//	|	Reservations.КоличествоЧеловек AS КоличествоЧеловек,
//	|	Reservations.Account.*,
//	|	Reservations.ВалютаСчета.*,
//	|	Reservations.DaysBeforeDateFrom,
//	|	Reservations.InvoiceAge,
//	|	Reservations.SumInvoice,
//	|	Reservations.AccountBalance,
//	|	Reservations.SumPayed}
//	|TOTALS
//	|	SUM(КоличествоЧеловек)
//	|BY
//	|	OVERALL,
//	|	Гостиница,
//	|	Контрагент,
//	|	Договор,
//	|	ГруппаГостей
//	|{TOTALS BY
//	|	Гостиница.* AS Гостиница,
//	|	ТипРесурса.* AS ТипРесурса,
//	|	Ресурс.* AS Ресурс,
//	|	Контрагент.* AS Контрагент,
//	|	Reservations.Ref.ТипКонтрагента.* AS ТипКонтрагента,
//	|	Договор.* AS Договор,
//	|	Reservations.КонтактноеЛицо AS КонтактноеЛицо,
//	|	Reservations.Ref.Агент.* AS Агент,
//	|	ГруппаГостей.* AS ГруппаГостей,
//	|	Клиент.* AS Клиент,
//	|	ResourceReservationStatus.* AS ResourceReservationStatus,
//	|	Reservations.Ref.ТипКлиента.* AS ТипКлиента,
//	|	Reservations.Ref.МаретингНапрвл.* AS МаретингНапрвл,
//	|	Reservations.Ref.ИсточИнфоГостиница.* AS ИсточИнфоГостиница,
//	|	Reservations.Ref.ДисконтКарт.* AS ДисконтКарт,
//	|	Reservations.Ref.ТипСкидки.* AS ТипСкидки,
//	|	Reservations.Фирма.* AS Фирма,
//	|	Reservations.Автор.* AS Автор,
//	|	Reservations.Ref.PlannedPaymentMethod.* AS PlannedPaymentMethod,
//	|	Reservations.Ref.PricePresentation AS PricePresentation,
//	|	Reservations.Account.*,
//	|	Reservations.ВалютаСчета.*,
//	|	Reservations.Ref.ДокОснование.* AS ДокОснование,
//	|	Reservations.Ref.* AS Recorder,
//	|	(HOUR(Reservations.Ref.DateTimeFrom)) AS FromHour,
//	|	(DAY(Reservations.Ref.DateTimeFrom)) AS FromDay,
//	|	(WEEK(Reservations.Ref.DateTimeFrom)) AS FromWeek,
//	|	(MONTH(Reservations.Ref.DateTimeFrom)) AS FromMonth,
//	|	(QUARTER(Reservations.Ref.DateTimeFrom)) AS FromQuarter,
//	|	(YEAR(Reservations.Ref.DateTimeFrom)) AS FromYear}";
//	ReportBuilder.Text = QueryText;
//	ReportBuilder.FillSettings();
//	
//	// Initialize report builder with default query
//	vRB = New ReportBuilder(QueryText);
//	vRBSettings = vRB.GetSettings(True, True, True, True, True);
//	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
//	
//	// Set default report builder header text
//	ReportBuilder.HeaderText = NStr("EN='Resource reservations history';RU='История бронирования ресурсов';de='Verlauf der Ressourcenreservierung'");
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
