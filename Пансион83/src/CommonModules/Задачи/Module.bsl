//-----------------------------------------------------------------------------
// Description: Returns value table with messages for the given object
// Parameters: Object reference, Whether to return closed messages or not
// Return value: Value table with messages
//-----------------------------------------------------------------------------
Function cmGetMessagesForObject(pObject = Неопределено, pShowClosed = False, pDate = '00010101', pShowTotals = False) Экспорт
	If pShowTotals = Неопределено Тогда
		pShowTotals = False;
	EndIf;
	// Build and run query
	qGetMsgs = New Query;
	If TypeOf(pObject) = Type("CatalogRef.Сотрудники") Тогда
		qGetMsgs.Text = 
		"SELECT
		|	Задачи.УчетнаяДата AS УчетнаяДата,
		|	1 AS СчетчикДокКвота,
		|	Задачи.Period,
		|	Задачи.Recorder,
		|	Задачи.LineNumber,
		|	Задачи.Active,
		|	Задачи.Object,
		|	Задачи.MessageType,
		|	Задачи.MessageStatus,
		|	Задачи.ValidFromDate AS ValidFromDate,
		|	Задачи.ValidToDate,
		|	Задачи.CloseToDate,
		|	Задачи.Примечания,
		|	Задачи.ForEmployee,
		|	Задачи.ForDepartment,
		|	Задачи.IsClosed,
		|	Задачи.PopUp,
		|	Задачи.Автор,
		|	Задачи.Color,
		|	MessagesLastComments.LastComment AS LastComment,
		|	MessagesLastComments.LastCommentPeriod AS LastCommentPeriod,
		|	MessagesLastComments.LastCommentAuthor AS LastCommentAuthor
		|FROM
		|	InformationRegister.Задачи AS Задачи
		|		LEFT JOIN (SELECT
		|			LastCommentLineNumbers.Ref AS Ref,
		|			LastComments.Comments AS LastComment,
		|			LastComments.Employee AS LastCommentAuthor,
		|			LastComments.Period AS LastCommentPeriod
		|		FROM
		|			(SELECT
		|				MessageComments.Ref AS Ref,
		|				MAX(MessageComments.LineNumber) AS LastCommentLineNumber
		|			FROM
		|				Document.Задача.Comments AS MessageComments
		|			WHERE
		|				MessageComments.Ref.Posted
		|				AND (NOT MessageComments.Ref.IsClosed)
		|				AND (MessageComments.Ref.ByObject = &qObject
		|						OR MessageComments.Ref.ForEmployee = &qObject
		|						OR MessageComments.Ref.ForDepartment = &qDepartment
		|							AND MessageComments.Ref.ForDepartment <> &qEmptyDepartmentRef
		|						OR MessageComments.Ref.ForEmployee = &qEmptyEmployeeRef
		|							AND MessageComments.Ref.ForDepartment = &qEmptyDepartmentRef
		|							AND MessageComments.Ref.ByObject = UNDEFINED)
		|				AND (MessageComments.Ref.ValidFromDate <= &qEndOfPeriod
		|						OR MessageComments.Ref.ValidFromDate = &qEmptyDate
		|						OR &qDateIsEmpty)
		|				AND (MessageComments.Ref.ValidToDate >= &qBeginOfPeriod
		|						OR MessageComments.Ref.ValidToDate = &qEmptyDate
		|						OR &qDateIsEmpty)
		|			
		|			GROUP BY
		|				MessageComments.Ref) AS LastCommentLineNumbers
		|				INNER JOIN Document.Задача.Comments AS LastComments
		|				ON LastCommentLineNumbers.Ref = LastComments.Ref
		|					AND LastCommentLineNumbers.LastCommentLineNumber = LastComments.LineNumber) AS MessagesLastComments
		|		ON Задачи.Recorder = MessagesLastComments.Ref
		|WHERE
		|	((NOT Задачи.IsClosed)
		|				AND (NOT &qShowClosed)
		|			OR &qShowClosed)
		|	AND (Задачи.Object = &qObject
		|			OR Задачи.ForEmployee = &qObject
		|			OR Задачи.ForDepartment = &qDepartment
		|				AND Задачи.ForDepartment <> &qEmptyDepartmentRef
		|			OR Задачи.ForEmployee = &qEmptyEmployeeRef
		|				AND Задачи.ForDepartment = &qEmptyDepartmentRef
		|				AND Задачи.Object = UNDEFINED)
		|	AND (Задачи.ValidFromDate <= &qEndOfPeriod
		|			OR Задачи.ValidFromDate = &qEmptyDate
		|			OR &qDateIsEmpty)
		|	AND (Задачи.ValidToDate >= &qBeginOfPeriod
		|			OR Задачи.ValidToDate = &qEmptyDate
		|			OR &qDateIsEmpty)
		|	AND (&qDateIsEmpty
		|			OR (NOT &qDateIsEmpty)
		|				AND Задачи.УчетнаяДата = &qDate)
		|
		|ORDER BY
		|	УчетнаяДата,
		|	ValidFromDate,
		|	Задачи.PointInTime DESC";
		If ЗначениеЗаполнено(pObject) Тогда
			qGetMsgs.SetParameter("qDepartment", pObject.Department);
		Else
			qGetMsgs.SetParameter("qDepartment", Неопределено);
		EndIf;
		qGetMsgs.SetParameter("qEmptyEmployeeRef", Справочники.Сотрудники.EmptyRef());
		qGetMsgs.SetParameter("qEmptyDepartmentRef", Справочники.Отделы.EmptyRef());
	Else
		qGetMsgs.Text = 
		"SELECT
		|	Задачи.УчетнаяДата AS УчетнаяДата,
		|	1 AS СчетчикДокКвота,
		|	Задачи.Period,
		|	Задачи.Recorder,
		|	Задачи.LineNumber,
		|	Задачи.Active,
		|	Задачи.Object,
		|	Задачи.MessageType,
		|	Задачи.MessageStatus,
		|	Задачи.ValidFromDate AS ValidFromDate,
		|	Задачи.ValidToDate,
		|	Задачи.CloseToDate,
		|	Задачи.Примечания,
		|	Задачи.ForEmployee,
		|	Задачи.ForDepartment,
		|	Задачи.IsClosed,
		|	Задачи.PopUp,
		|	Задачи.Автор,
		|	Задачи.Color,
		|	MessagesLastComments.LastComment AS LastComment,
		|	MessagesLastComments.LastCommentPeriod AS LastCommentPeriod,
		|	MessagesLastComments.LastCommentAuthor AS LastCommentAuthor
		|FROM
		|	InformationRegister.Задачи AS Задачи
		|		LEFT JOIN (SELECT
		|			LastCommentLineNumbers.Ref AS Ref,
		|			LastComments.Comments AS LastComment,
		|			LastComments.Employee AS LastCommentAuthor,
		|			LastComments.Period AS LastCommentPeriod
		|		FROM
		|			(SELECT
		|				MessageComments.Ref AS Ref,
		|				MAX(MessageComments.LineNumber) AS LastCommentLineNumber
		|			FROM
		|				Document.Задача.Comments AS MessageComments
		|			WHERE
		|				MessageComments.Ref.Posted
		|				AND (NOT MessageComments.Ref.IsClosed)
		|				AND MessageComments.Ref.ByObject = &qObject
		|				AND (MessageComments.Ref.ValidFromDate <= &qEndOfPeriod
		|						OR MessageComments.Ref.ValidFromDate = &qEmptyDate
		|						OR &qDateIsEmpty)
		|				AND (MessageComments.Ref.ValidToDate >= &qBeginOfPeriod
		|						OR MessageComments.Ref.ValidToDate = &qEmptyDate
		|						OR &qDateIsEmpty)
		|			
		|			GROUP BY
		|				MessageComments.Ref) AS LastCommentLineNumbers
		|				INNER JOIN Document.Задача.Comments AS LastComments
		|				ON LastCommentLineNumbers.Ref = LastComments.Ref
		|					AND LastCommentLineNumbers.LastCommentLineNumber = LastComments.LineNumber) AS MessagesLastComments
		|		ON Задачи.Recorder = MessagesLastComments.Ref
		|WHERE
		|	((NOT Задачи.IsClosed)
		|				AND (NOT &qShowClosed)
		|			OR &qShowClosed)
		|	AND Задачи.Object = &qObject
		|	AND (Задачи.ValidFromDate <= &qEndOfPeriod
		|			OR Задачи.ValidFromDate = &qEmptyDate
		|			OR &qDateIsEmpty)
		|	AND (Задачи.ValidToDate >= &qBeginOfPeriod
		|			OR Задачи.ValidToDate = &qEmptyDate
		|			OR &qDateIsEmpty)
		|	AND (&qDateIsEmpty
		|			OR (NOT &qDateIsEmpty)
		|				AND Задачи.УчетнаяДата = &qDate)
		|
		|ORDER BY
		|	УчетнаяДата,
		|	ValidFromDate,
		|	Задачи.PointInTime DESC";
	EndIf;
	If pShowTotals Тогда
		qGetMsgs.Text = qGetMsgs.Text + "
		|TOTALS 
		|	SUM(СчетчикДокКвота)
		|BY
		|	УчетнаяДата";
	EndIf;
	qGetMsgs.SetParameter("qObject", pObject);
	qGetMsgs.SetParameter("qDate", BegOfDay(pDate));
	qGetMsgs.SetParameter("qBeginOfPeriod", BegOfDay(pDate));
	qGetMsgs.SetParameter("qEndOfPeriod", EndOfDay(pDate) + 1);
	qGetMsgs.SetParameter("qPeriodIsEmpty", НЕ ЗначениеЗаполнено(pDate));
	qGetMsgs.SetParameter("qEmptyDate", '00010101');
	qGetMsgs.SetParameter("qDateIsEmpty", НЕ ЗначениеЗаполнено(pDate));
	qGetMsgs.SetParameter("qShowClosed", pShowClosed);
	vMsgs = qGetMsgs.Execute().Unload();
	Return vMsgs;
EndFunction //cmGetMessagesForObject

//-----------------------------------------------------------------------------
// Description: Returns number of active messages for the given object
// Parameters: Object reference
// Return value: Number of active messages
//-----------------------------------------------------------------------------
Function cmGetNumberOfMessagesForObject(pObject = Неопределено, pPopUpOnly = False) Экспорт
	vCount = 0;
	//// Build and run query
	//qGetMsgs = New Query;
	//If TypeOf(pObject) = Type("CatalogRef.Сотрудники") Тогда
	//	qGetMsgs.Text = 
	//	"SELECT
	//	|	COUNT(*) AS Count
	//	|FROM
	//	|	Document.Задача AS Задачи
	//	|WHERE
	//	|	Задачи.Posted
	//	|	AND NOT Задачи.IsClosed
	//	|	AND (NOT &qPopUp
	//	|			OR &qPopUp
	//	|				AND Задачи.PopUp)
	//	|	AND (Задачи.ByObject = &qObject
	//	|			OR Задачи.ForEmployee = &qObject
	//	|			OR Задачи.ForDepartment = &qDepartment
	//	|				AND Задачи.ForDepartment <> &qEmptyDepartmentRef
	//	|			OR Задачи.ForEmployee = &qEmptyEmployeeRef
	//	|				AND Задачи.ForDepartment = &qEmptyDepartmentRef
	//	|				AND Задачи.ByObject = UNDEFINED)
	//	|	AND Задачи.ValidFromDate <= &qPeriod
	//	|	AND (Задачи.ValidToDate > &qPeriod
	//	|			OR Задачи.ValidToDate = &qEmptyDate)";
	//	If ЗначениеЗаполнено(pObject) Тогда
	//		qGetMsgs.SetParameter("qDepartment", pObject.Отдел);
	//	Else
	//		qGetMsgs.SetParameter("qDepartment", Неопределено);
	//	EndIf;
	//	qGetMsgs.SetParameter("qEmptyEmployeeRef", Справочники.Сотрудники.EmptyRef());
	//	qGetMsgs.SetParameter("qEmptyDepartmentRef", Справочники.Отделы.EmptyRef());
	//	qGetMsgs.SetParameter("qPopUp", pPopUpOnly);
	//Else
	//	qGetMsgs.Text = 
	//	"SELECT
	//	|	COUNT(*) AS Count
	//	|FROM
	//	|	Document.Задача AS Задачи
	//	|WHERE
	//	|	Задачи.Проведен
	//	|	AND (NOT &qPopUp OR &qPopUp AND Задачи.PopUp)
	//	|	AND (NOT Задачи.IsClosed)
	//	|	AND Задачи.ByObject = &qObject
	//	|	AND Задачи.ValidFromDate <= &qPeriod
	//	|	AND (Задачи.ValidToDate > &qPeriod
	//	|			OR Задачи.ValidToDate = &qEmptyDate)";
	//EndIf;
	//qGetMsgs.SetParameter("qObject", pObject);
	//qGetMsgs.SetParameter("qPeriod", CurrentDate());
	//qGetMsgs.SetParameter("qEmptyDate", '00010101');
	//qGetMsgs.SetParameter("qPopUp", pPopUpOnly);
	//vMsgs = qGetMsgs.Execute().Unload();
	//For Each vMsgsRow In vMsgs Do
	//	vCount = vMsgsRow.Count;
	//	Break;
	//EndDo;
	Return vCount;
EndFunction //cmGetNumberOfMessagesForObject

//-----------------------------------------------------------------------------
// Description: Returns number of pop up messages for the given employee
// Parameters: Employee reference
// Return value: Number of active employee pop up messages
//-----------------------------------------------------------------------------
Function cmGetNumberOfPopUpMessagesForEmployee(pObject = Неопределено) Экспорт
	// Build and run query
	//qGetMsgs = New Query;
	//qGetMsgs.Text = 
	//"SELECT
	//|	Задачи.ДатаДок AS Period,
	//|	Задачи.ByObject AS Object,
	//|	Задачи.Ref AS Recorder
	//|FROM
	//|	Document.Задача AS Задачи
	//|WHERE
	//|	Задачи.Posted
	//|	AND (NOT Задачи.IsClosed)
	//|	AND (Задачи.ByObject = &qObject
	//|			OR Задачи.ForEmployee = &qObject
	//|			OR Задачи.ForDepartment = &qDepartment
	//|				AND Задачи.ForDepartment <> &qEmptyDepartmentRef
	//|			OR Задачи.ForEmployee = &qEmptyEmployeeRef
	//|				AND Задачи.ForDepartment = &qEmptyDepartmentRef
	//|				AND Задачи.ByObject = UNDEFINED)
	//|	AND Задачи.ValidFromDate <= &qPeriod
	//|	AND (Задачи.ValidToDate > &qPeriod
	//|			OR Задачи.ValidToDate = &qEmptyDate)
	//|	AND Задачи.PopUp";
	//If ЗначениеЗаполнено(pObject) Тогда
	//	qGetMsgs.SetParameter("qDepartment", pObject.Отдел);
	//Else
	//	qGetMsgs.SetParameter("qDepartment", Неопределено);
	//EndIf;
	//qGetMsgs.SetParameter("qEmptyEmployeeRef", Справочники.Сотрудники.EmptyRef());
	//qGetMsgs.SetParameter("qEmptyDepartmentRef", Справочники.Отделы.EmptyRef());
	//qGetMsgs.SetParameter("qObject", pObject);
	//qGetMsgs.SetParameter("qPeriod", CurrentDate());
	//qGetMsgs.SetParameter("qEmptyDate", '00010101');
	//vMsgs = qGetMsgs.Execute().Unload();
	// Process pop up messages and remove pop up flag from then
	vCount = 0;
	//For Each vMsgsRow In vMsgs Do
	//	// Count pop up messages
	//	vCount = vCount + 1;
	//	// Update message to remove pop up flag
	//	If ЗначениеЗаполнено(vMsgsRow.Recorder) Тогда
	//		vMsgObj = vMsgsRow.Recorder.GetObject();
	//		vMsgObj.PopUp = False;
	//		vMsgObj.Write(DocumentWriteMode.Posting);
	//	EndIf;
	//EndDo;
	Return vCount;
EndFunction //cmGetNumberOfPopUpMessagesForEmployee

//-----------------------------------------------------------------------------
// Description: Applies Messages button appearance
// Parameters: Messages button control, Object
// Return value: None
//-----------------------------------------------------------------------------
Процедура cmMessagesButtonAppearance(pButton, pObject) Экспорт
	If ЗначениеЗаполнено(pObject) Тогда
		vCount = cmGetNumberOfMessagesForObject(pObject);
		pButton.Enabled = True;
		If vCount = 0 Тогда
			pButton.Caption = NStr("en='Tasks (F11)';ru='Задачи (F11)';de='Aufgaben (F11)'");
			pButton.ButtonBackColor = StyleColors.ButtonBackColor;
			pButton.ButtonTextColor = StyleColors.ButtonTextColor;
		Else
			pButton.Caption = NStr("ru = 'Задачи (F11) - " + vCount + "'; en = 'Tasks (F11) - " + vCount + "'; de = 'Aufgaben (F11) - " + vCount + "'");
			pButton.ButtonBackColor = StyleColors.SpecialTextColor;
			pButton.ButtonTextColor = StyleColors.FieldSelectedTextColor;
		EndIf;
	Else
		pButton.Caption = NStr("en='Tasks (F11)';ru='Задачи (F11)';de='Aufgaben (F11)'");
		pButton.ButtonBackColor = StyleColors.ButtonBackColor;
		pButton.ButtonTextColor = StyleColors.ButtonTextColor;
		pButton.Enabled = True;
	EndIf;
КонецПроцедуры //cmMessagesButtonAppearance
	
//-----------------------------------------------------------------------------
// Description: Returns active messages value table for the given objects list
// Parameters: Value list with objects
// Return value: Value table with active messages
//-----------------------------------------------------------------------------
Function cmGetMessagesForObjectsList(pObjects) Экспорт
	// Get the table of messages
	vQryMsg = New Query();
	vQryMsg.Text = 
	"SELECT
	|	Задачи.ByObject AS Object,
	|	Задачи.Автор AS Автор,
	|	Задачи.Примечания AS Примечания,
	|	Задачи.Ref AS Recorder
	|FROM
	|	Document.Задача AS Задачи
	|WHERE
	|	Задачи.Posted
	|	AND (NOT Задачи.IsClosed)
	|	AND Задачи.ByObject IN(&qObjects)
	|	AND Задачи.ValidFromDate <= &qPeriod
	|	AND (Задачи.ValidToDate > &qPeriod
	|			OR Задачи.ValidToDate = &qEmptyDate)
	|
	|ORDER BY
	|	Задачи.PointInTime DESC";
	vQryMsg.SetParameter("qObjects", pObjects);
	vQryMsg.SetParameter("qPeriod", CurrentDate());
	vQryMsg.SetParameter("qEmptyDate", '00010101');
	vMessages = vQryMsg.Execute().Unload();
	Return vMessages;
EndFunction //cmGetMessagesForObjectsList

//-----------------------------------------------------------------------------
// Description: Returns string with messages text
// Parameters: Value table with messages, Object
// Return value: String with joined message texts
//-----------------------------------------------------------------------------
Function cmGetMessagesPresentationForObject(pMessages, pObject) Экспорт
	vMessagesStr = "";
	vMessagesArray = pMessages.FindRows(New Structure("Object", pObject));
	For Each vMessagesRow In vMessagesArray Do
		If vMessagesStr <> "" Тогда
			vMessagesStr = vMessagesStr + Chars.LF;
		EndIf;
		vMessagesStr = vMessagesStr + СокрЛП(vMessagesRow.Автор) + ": " + СокрЛП(vMessagesRow.Примечания);
	EndDo;
	Return vMessagesStr;
EndFunction //cmGetMessagesPresentationForObject

//-----------------------------------------------------------------------------
// Description: Returns value table with all message statuses
// Parameters: None
// Return value: Value table with all message status catalog items
//-----------------------------------------------------------------------------
Function cmGetAllMessageStatuses() Экспорт
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	СтатусЗадачи.Ref AS MessageStatus,
	|	СтатусЗадачи.Code AS Code,
	|	СтатусЗадачи.IsClosed AS IsClosed,
	|	СтатусЗадачи.Description AS Description,
	|	СтатусЗадачи.ПорядокСортировки AS ПорядокСортировки
	|FROM
	|	Catalog.СтатусЗадачи AS СтатусЗадачи
	|WHERE
	|	СтатусЗадачи.DeletionMark = FALSE AND
	|	СтатусЗадачи.IsFolder = FALSE
	|ORDER BY
	|	ПорядокСортировки";
	vElements = vQry.Execute().Unload();
	Return vElements;
EndFunction //cmGetAllMessageStatuses

//-----------------------------------------------------------------------------
// Description: Returns value table with all message types
// Parameters: None
// Return value: Value table with all message type catalog items
//-----------------------------------------------------------------------------
Function cmGetAllMessageTypes() Экспорт
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	ТипыСообщений.Ref AS MessageType,
	|	ТипыСообщений.Code AS Code,
	|	ТипыСообщений.Description AS Description,
	|	ТипыСообщений.ПорядокСортировки AS ПорядокСортировки
	|FROM
	|	Catalog.ТипыСообщений AS ТипыСообщений
	|WHERE
	|	ТипыСообщений.DeletionMark = FALSE
	|	AND ТипыСообщений.IsFolder = FALSE
	|
	|ORDER BY
	|	ПорядокСортировки";
	vElements = vQry.Execute().Unload();
	Return vElements;
EndFunction //cmGetAllMessageTypes

//-----------------------------------------------------------------------------
// Description: Returns all active messages for the given employee
// Parameters: Employee
// Return value: Value list with message documents
//-----------------------------------------------------------------------------
Function cmGetEmployeeMessages(pEmployee) Экспорт
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	Задачи.Ref AS Ref
	|FROM
	|	Document.Задача AS Задачи
	|WHERE
	|	Задачи.Posted
	|	AND (Задачи.Автор = &qEmployee
	|			OR Задачи.ForEmployee = &qEmployee
	|			OR Задачи.ForDepartment IN HIERARCHY (&qDepartment)
	|				AND &qDepartment <> &qEmptyDepartment
	|			OR Задачи.ForEmployee = &qEmptyEmployee
	|				AND Задачи.ForDepartment = &qEmptyDepartment
	|				AND Задачи.ByObject = UNDEFINED)
	|
	|ORDER BY
	|	Задачи.PointInTime";
	vQry.SetParameter("qEmployee", pEmployee);
	vQry.SetParameter("qDepartment", ?(ЗначениеЗаполнено(pEmployee), pEmployee.Department, Неопределено));
	vQry.SetParameter("qEmptyEmployee", Справочники.Сотрудники.EmptyRef());
	vQry.SetParameter("qEmptyDepartment", Справочники.Отделы.EmptyRef());
	vDocsArray = vQry.Execute().Unload().UnloadColumn("Ref");
	vDocsList = New СписокЗначений();
	If vDocsArray.Count() > 0 Тогда
		vDocsList.LoadValues(vDocsArray);
	EndIf;
	Return vDocsList;
EndFunction //cmGetEmployeeMessages

//-----------------------------------------------------------------------------
// Description: Sends message to the given employee
// Parameters: Employee, Message text, Message status, Is pop up message
// Return value: None
//-----------------------------------------------------------------------------
Процедура cmSendMessageToEmployee(pEmployee, pMsg, pMessageStatus = Неопределено, pPopUp = False) Экспорт
	vMsgObj = Documents.Задача.CreateDocument();
	vMsgObj.pmFillAttributesWithDefaultValues();
	If ЗначениеЗаполнено(pMessageStatus) Тогда
		vMsgObj.MessageStatus = pMessageStatus;
		vMsgObj.IsClosed = vMsgObj.MessageStatus.IsClosed;
	EndIf;
	vMsgObj.ForEmployee = pEmployee;
	vMsgObj.Примечания = pMsg;
	vMsgObj.PopUp = pPopUp;
	vMsgObj.Write(DocumentWriteMode.Posting);
КонецПроцедуры //cmSendMessageToEmployee

//-----------------------------------------------------------------------------
// Description: Sends message to all employees in the Отдел
// Parameters: Отдел, Message text, Message status, Is pop up message
// Return value: None
//-----------------------------------------------------------------------------
Процедура cmSendMessageToDepartment(pDepartment, pMsg, pMessageStatus = Неопределено, pPopUp = False, pObject = Неопределено) Экспорт
	vMsgObj = Documents.Задача.CreateDocument();
	vMsgObj.pmFillAttributesWithDefaultValues();
	If ЗначениеЗаполнено(pMessageStatus) Тогда
		vMsgObj.MessageStatus = pMessageStatus;
		vMsgObj.IsClosed = vMsgObj.MessageStatus.IsClosed;
	EndIf;
	vMsgObj.ForDepartment = pDepartment;
	If ЗначениеЗаполнено(pObject) Тогда
		vMsgObj.ByObject = pObject;
	EndIf;
	vMsgObj.Примечания = pMsg;
	vMsgObj.PopUp = pPopUp;
	vMsgObj.Write(DocumentWriteMode.Posting);
КонецПроцедуры //cmSendMessageToDepartment

//-----------------------------------------------------------------------------
// Description: Sends message to the object
// Parameters: Object reference, Message text, Message status, Is pop up message
// Return value: None
//-----------------------------------------------------------------------------
Процедура cmSendMessageToObject(pObjectRef, pMsg, pMessageStatus = Неопределено, pPopUp = False) Экспорт
	vMsgObj = Documents.Задача.CreateDocument();
	vMsgObj.pmFillAttributesWithDefaultValues();
	If ЗначениеЗаполнено(pMessageStatus) Тогда
		vMsgObj.MessageStatus = pMessageStatus;
		vMsgObj.IsClosed = vMsgObj.MessageStatus.IsClosed;
	EndIf;
	vMsgObj.ByObject = pObjectRef;
	vMsgObj.Примечания = pMsg;
	vMsgObj.PopUp = pPopUp;
	vMsgObj.Write(DocumentWriteMode.Posting);
КонецПроцедуры //cmSendMessageToObject
