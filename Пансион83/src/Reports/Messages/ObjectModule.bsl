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
//		vParamPresentation = vParamPresentation + NStr("ru = 'Период c '; en = 'Period from '; de = 'Period from '") + 
//		                     Format(PeriodFrom, "DF='dd.MM.yyyy HH:mm:ss'") + 
//		                     ";" + Chars.LF;
//	ElsIf ЗначениеЗаполнено(PeriodFrom) And НЕ ЗначениеЗаполнено(PeriodTo) Тогда
//		vParamPresentation = vParamPresentation + NStr("ru = 'Период по '; en = 'Period to '; de = 'Period to '") + 
//		                     Format(PeriodTo, "DF='dd.MM.yyyy HH:mm:ss'") + 
//		                     ";" + Chars.LF;
//	ElsIf PeriodFrom = PeriodTo Тогда
//		vParamPresentation = vParamPresentation + NStr("ru = 'Период на '; en = 'Period on '; de = 'Period on '") + 
//		                     Format(PeriodFrom, "DF='dd.MM.yyyy HH:mm:ss'") + 
//		                     ";" + Chars.LF;
//	ElsIf PeriodFrom < PeriodTo Тогда
//		vParamPresentation = vParamPresentation + NStr("ru = 'Период '; en = 'Period '; de = 'Period '") + PeriodPresentation(PeriodFrom, PeriodTo, cmLocalizationCode()) + 
//		                     ";" + Chars.LF;
//	Else
//		vParamPresentation = vParamPresentation + NStr("en='Period is wrong!';ru='Неправильно задан период!';de='Der Zeitraum wurde falsch eingetragen!'") + 
//		                     ";" + Chars.LF;
//	EndIf;
//	If ЗначениеЗаполнено(MessageType) Тогда
//		If НЕ MessageType.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("ru = 'Тип '; en = 'Type '; de = 'Typ '") + 
//			                     TrimAll(MessageType.Description) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("ru = 'Группа типов '; en = 'Types folder '; de = 'Typen folder '") + 
//			                     TrimAll(MessageType.Description) + 
//			                     ";" + Chars.LF;
//		EndIf;
//	EndIf;
//	If ЗначениеЗаполнено(MessageStatus) Тогда
//		If НЕ MessageStatus.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("ru = 'Статус '; en = 'Status '; de = 'Status '") + 
//			                     TrimAll(MessageStatus.Description) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("ru = 'Группа статусов '; en = 'Statuses folder '; de = 'Status folder '") + 
//			                     TrimAll(MessageStatus.Description) + 
//			                     ";" + Chars.LF;
//		EndIf;
//	EndIf;
//	If ЗначениеЗаполнено(Employee) Тогда
//		If НЕ Employee.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("en='Employee ';ru='Сотрудник ';de='Mitarbeiter '") + 
//			                     TrimAll(Employee.Description) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("ru = 'Группа сотрудников '; en = 'Employees folder '; de = 'Mitarbeiteren folder '") + 
//			                     TrimAll(Employee.Description) + 
//			                     ";" + Chars.LF;
//		EndIf;
//	EndIf;
//	If ЗначениеЗаполнено(Отдел) Тогда
//		If НЕ Отдел.IsFolder Тогда
//			vParamPresentation = vParamPresentation + NStr("ru = 'Отдел '; en = 'Отдел '; de = 'Abteilung '") + 
//			                     TrimAll(Отдел.Description) + 
//			                     ";" + Chars.LF;
//		Else
//			vParamPresentation = vParamPresentation + NStr("ru = 'Группа отделов '; en = 'Departments folder '; de = 'Abteilungen folder '") + 
//			                     TrimAll(Отдел.Description) + 
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
//	If ЗначениеЗаполнено(Object) Тогда
//		vParamPresentation = vParamPresentation + NStr("ru = 'Объект '; en = 'Object '; de = 'Object '") + 
//							 TrimAll(Object.Description) + 
//							 ";" + Chars.LF;
//	EndIf;
//	If НЕ ShowClosedMessages Тогда
//		vParamPresentation = vParamPresentation + NStr("en='Active tasks only';ru='Только действующие задачи';de='Nur aktuelle Aufgaben'") + 
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
//	ReportBuilder.Parameters.Вставить("qPeriodFrom", PeriodFrom);
//	ReportBuilder.Parameters.Вставить("qPeriodTo", ?(ЗначениеЗаполнено(PeriodTo), PeriodTo, '39991231235959'));
//	ReportBuilder.Parameters.Вставить("qRoom", ГруппаНомеров);
//	ReportBuilder.Parameters.Вставить("qIsEmptyRoom", НЕ ЗначениеЗаполнено(ГруппаНомеров));
//	ReportBuilder.Parameters.Вставить("qObject", Object);
//	ReportBuilder.Parameters.Вставить("qIsEmptyObject", НЕ ЗначениеЗаполнено(Object));
//	ReportBuilder.Parameters.Вставить("qEmployee", Employee);
//	ReportBuilder.Parameters.Вставить("qIsEmptyEmployee", НЕ ЗначениеЗаполнено(Employee));
//	ReportBuilder.Parameters.Вставить("qDepartment", Отдел);
//	ReportBuilder.Parameters.Вставить("qIsEmptyDepartment", НЕ ЗначениеЗаполнено(Отдел));
//	ReportBuilder.Parameters.Вставить("qMessageType", MessageType);
//	ReportBuilder.Parameters.Вставить("qIsEmptyMessageType", НЕ ЗначениеЗаполнено(MessageType));
//	ReportBuilder.Parameters.Вставить("qMessageStatus", MessageStatus);
//	ReportBuilder.Parameters.Вставить("qIsEmptyMessageStatus", НЕ ЗначениеЗаполнено(MessageStatus));
//	ReportBuilder.Parameters.Вставить("qShowClosedMessages", ShowClosedMessages);
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
//	|	Задачи.Period AS Period,
//	|	Задачи.Object AS Object,
//	|	Задачи.Примечания,
//	|	Задачи.Автор,
//	|	MessagesLastComments.LastComment AS LastComment,
//	|	MessagesLastComments.LastCommentPeriod AS LastCommentPeriod,
//	|	MessagesLastComments.LastCommentAuthor AS LastCommentAuthor,
//	|	1 AS Count
//	|{SELECT
//	|	Period,
//	|	Object.*,
//	|	Задачи.MessageType.* AS MessageType,
//	|	Задачи.MessageStatus.* AS MessageStatus,
//	|	Примечания,
//	|	Задачи.ForEmployee.*,
//	|	Задачи.ForDepartment.*,
//	|	Задачи.ValidFromDate,
//	|	Задачи.ValidToDate,
//	|	Задачи.CloseToDate,
//	|	Автор.*,
//	|	Задачи.Recorder.*,
//	|	Задачи.IsClosed,
//	|	Count,
//	|	LastComment,
//	|	LastCommentPeriod,
//	|	LastCommentAuthor.*,
//	|	Задачи.ClosedBy.*,
//	|	Задачи.DateWhenClosed}
//	|FROM
//	|	InformationRegister.Задачи AS Задачи
//	|		LEFT JOIN (SELECT
//	|			LastCommentLineNumbers.Ref AS Ref,
//	|			LastComments.Comments AS LastComment,
//	|			LastComments.Employee AS LastCommentAuthor,
//	|			LastComments.Period AS LastCommentPeriod
//	|		FROM
//	|			(SELECT
//	|				MessageComments.Ref AS Ref,
//	|				MAX(MessageComments.LineNumber) AS LastCommentLineNumber
//	|			FROM
//	|				Document.Задача.Comments AS MessageComments
//	|			WHERE
//	|				MessageComments.Ref.Posted
//	|				AND (NOT MessageComments.Ref.IsClosed
//	|						OR &qShowClosedMessages)
//	|				AND (MessageComments.Ref.MessageStatus IN HIERARCHY (&qMessageStatus)
//	|							AND NOT &qIsEmptyMessageStatus
//	|						OR &qIsEmptyMessageStatus)
//	|				AND (MessageComments.Ref.ForEmployee IN HIERARCHY (&qEmployee)
//	|							AND NOT &qIsEmptyEmployee
//	|						OR &qIsEmptyEmployee)
//	|				AND (MessageComments.Ref.ForDepartment IN HIERARCHY (&qDepartment)
//	|							AND NOT &qIsEmptyDepartment
//	|						OR &qIsEmptyDepartment)
//	|				AND (MessageComments.Ref.ByObject = &qObject
//	|						OR &qIsEmptyObject)
//	|				AND (MessageComments.Ref.ByObject IN HIERARCHY (&qRoom)
//	|							AND NOT &qIsEmptyRoom
//	|						OR &qIsEmptyRoom)
//	|			
//	|			GROUP BY
//	|				MessageComments.Ref) AS LastCommentLineNumbers
//	|				INNER JOIN Document.Задача.Comments AS LastComments
//	|				ON LastCommentLineNumbers.Ref = LastComments.Ref
//	|					AND LastCommentLineNumbers.LastCommentLineNumber = LastComments.LineNumber) AS MessagesLastComments
//	|		ON Задачи.Recorder = MessagesLastComments.Ref
//	|WHERE
//	|	(NOT Задачи.IsClosed
//	|			OR &qShowClosedMessages)
//	|	AND (Задачи.MessageType IN HIERARCHY (&qMessageType)
//	|				AND NOT &qIsEmptyMessageType
//	|			OR &qIsEmptyMessageType)
//	|	AND (Задачи.MessageStatus IN HIERARCHY (&qMessageStatus)
//	|				AND NOT &qIsEmptyMessageStatus
//	|			OR &qIsEmptyMessageStatus)
//	|	AND (Задачи.ForEmployee IN HIERARCHY (&qEmployee)
//	|				AND NOT &qIsEmptyEmployee
//	|			OR &qIsEmptyEmployee)
//	|	AND (Задачи.ForDepartment IN HIERARCHY (&qDepartment)
//	|				AND NOT &qIsEmptyDepartment
//	|			OR &qIsEmptyDepartment)
//	|	AND (Задачи.Object = &qObject
//	|			OR &qIsEmptyObject)
//	|	AND (Задачи.Object IN HIERARCHY (&qRoom)
//	|				AND NOT &qIsEmptyRoom
//	|			OR &qIsEmptyRoom)
//	|	AND Задачи.Period >= &qPeriodFrom
//	|	AND Задачи.Period <= &qPeriodTo
//	|{WHERE
//	|	Задачи.Period,
//	|	Задачи.MessageType.* AS MessageType,
//	|	Задачи.MessageStatus.* AS MessageStatus,
//	|	Задачи.Recorder.*,
//	|	Задачи.ForEmployee.*,
//	|	Задачи.ForDepartment.*,
//	|	Задачи.Object.*,
//	|	Задачи.ValidFromDate,
//	|	Задачи.ValidToDate,
//	|	Задачи.CloseToDate,
//	|	Задачи.Примечания,
//	|	MessagesLastComments.LastComment AS LastComment,
//	|	MessagesLastComments.LastCommentPeriod AS LastCommentPeriod,
//	|	MessagesLastComments.LastCommentAuthor AS LastCommentAuthor,
//	|	Задачи.Автор.*,
//	|	Задачи.IsClosed,
//	|	Задачи.ClosedBy.*,
//	|	Задачи.DateWhenClosed}
//	|
//	|ORDER BY
//	|	Period
//	|{ORDER BY
//	|	Period,
//	|	Задачи.MessageType.* AS MessageType,
//	|	Задачи.MessageStatus.* AS MessageStatus,
//	|	Задачи.Recorder.*,
//	|	Задачи.ForEmployee.*,
//	|	Задачи.ForDepartment.*,
//	|	Object.*,
//	|	Задачи.ValidFromDate,
//	|	Задачи.ValidToDate,
//	|	Задачи.CloseToDate,
//	|	LastComment,
//	|	LastCommentPeriod,
//	|	LastCommentAuthor.*,
//	|	Автор.*,
//	|	Задачи.IsClosed,
//	|	Задачи.ClosedBy.*,
//	|	Задачи.DateWhenClosed}
//	|TOTALS
//	|	SUM(Count)
//	|BY
//	|	OVERALL,
//	|	Object HIERARCHY
//	|{TOTALS BY
//	|	Задачи.MessageType.* AS MessageType,
//	|	Задачи.MessageStatus.* AS MessageStatus,
//	|	Задачи.ForEmployee.*,
//	|	Задачи.ForDepartment.*,
//	|	Object.*,
//	|	LastCommentAuthor.*,
//	|	Автор.*,
//	|	Задачи.IsClosed,
//	|	Задачи.ClosedBy.*,
//	|	Задачи.DateWhenClosed}";
//	ReportBuilder.Text = QueryText;
//	ReportBuilder.FillSettings();
//	
//	// Initialize report builder with default query
//	vRB = New ReportBuilder(QueryText);
//	vRBSettings = vRB.GetSettings(True, True, True, True, True);
//	ReportBuilder.SetSettings(vRBSettings, True, True, True, True, True);
//	
//	// Set default report builder header text
//	ReportBuilder.HeaderText = NStr("EN='Tasks';RU='Задачи';de='Aufgaben'");
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
