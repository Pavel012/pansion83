//-----------------------------------------------------------------------------
// Description: Finds employee by it's PBX account code
// Parameters: PBX account code
// Return value: Employee reference
//-----------------------------------------------------------------------------
Function cmGetEmployeeByPBXAccountCode(pPBXAccountCode) Экспорт
	vEmployee = Справочники.Сотрудники.EmptyRef();
	If pPBXAccountCode = 0 Тогда
		Return vEmployee;
	EndIf;
	
	// Run query
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	Сотрудники.Ref AS Employee
	|FROM
	|	Catalog.Сотрудники AS Employees
	|WHERE
	|	Сотрудники.КодДоступаАТС = &qPBXAccountCode
	|	AND (NOT Сотрудники.DeletionMark)
	|	AND (NOT Сотрудники.IsFolder)
	|ORDER BY
	|	Сотрудники.ПорядокСортировки";
	vQry.SetParameter("qPBXAccountCode", pPBXAccountCode);
	vQryRes = vQry.Execute().Unload();
	For Each vQryResRow In vQryRes Do
		vEmployee = vQryResRow.Employee;
		Break;
	EndDo;
	
	Return vEmployee;
EndFunction //cmGetEmployeeByPBXAccountCode

//-----------------------------------------------------------------------------
// Description: Finds operation by it's PBX phone number
// Parameters: PBX phone number
// Return value: Operation item reference
//-----------------------------------------------------------------------------
Function cmGetOperationByPBXPhoneNumber(pPBXPhoneNumber, rIsStart = True) Экспорт
	vOperation = Справочники.Работы.EmptyRef();
	If pPBXPhoneNumber = 0 Тогда
		Return vOperation;
	EndIf;
	rIsStart = True;
	
	// Run query to find operation
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	Работы.Ref AS Operation,
	|FROM
	|	Catalog.Работы AS Работы
	|ORDER BY
	|	Работы.ПорядокСортировки";
	vQryRes = vQry.Execute().Unload();
	For Each vQryResRow In vQryRes Do
		vOperation = vQryResRow.Operation;
		Break;
	EndDo;
	
	Return vOperation;
EndFunction //cmGetOperationByPBXPhoneNumber

//-----------------------------------------------------------------------------
// Description: Finds ГруппаНомеров status by it's PBX phone number
// Parameters: PBX phone number
// Return value: ГруппаНомеров status item reference
//-----------------------------------------------------------------------------
Function cmGetRoomStatusByPBXPhoneNumber(pPBXPhoneNumber) Экспорт
	vRoomStatus = Справочники.СтатусыНомеров.EmptyRef();
	If pPBXPhoneNumber = 0 Тогда
		Return vRoomStatus;
	EndIf;
	
	// Run query
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	СтатусыНомеров.Ref AS СтатусНомера
	|FROM
	|	Catalog.СтатусыНомеров AS СтатусыНомеров
	|WHERE
	|	СтатусыНомеров.PBXCode = &qPBXPhoneNumber
	|	AND (NOT СтатусыНомеров.DeletionMark)
	|	AND (NOT СтатусыНомеров.IsFolder)
	|ORDER BY
	|	СтатусыНомеров.ПорядокСортировки";
	vQry.SetParameter("qPBXPhoneNumber", pPBXPhoneNumber);
	vQryRes = vQry.Execute().Unload();
	For Each vQryResRow In vQryRes Do
		vRoomStatus = vQryResRow.RoomStatus;
		Break;
	EndDo;
	
	Return vRoomStatus;
EndFunction //cmGetRoomStatusByPBXPhoneNumber

//-----------------------------------------------------------------------------
// Description: Returns employee and operation by PBX account code
// Parameters: PBX account code
// Return value: "Employee PBX codes" information register record data as Structure
//-----------------------------------------------------------------------------
Function cmGetEmployeeAndOperationByPBXCode(pPBXCode) Экспорт
	vStruct = New Structure("Employee, Operation, СтатусНомера, IsOperationStart, IsOperationEnd", 
	                        Справочники.Сотрудники.EmptyRef(), 
	                        Справочники.Работы.EmptyRef(),
	                        Справочники.СтатусыНомеров.EmptyRef(),
	                        False, False);
	
	// Run query to get data from the information register
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	EmployeePBXCodes.Employee,
	|	EmployeePBXCodes.Operation,
	|	EmployeePBXCodes.СтатусНомера,
	|	EmployeePBXCodes.IsOperationStart,
	|	EmployeePBXCodes.IsOperationEnd
	|FROM
	|	InformationRegister.EmployeePBXCodes AS EmployeePBXCodes
	|WHERE
	|	EmployeePBXCodes.PBXCode = &qPBXCode";
	vQry.SetParameter("qPBXCode", pPBXCode);
	vQryRes = vQry.Execute().Unload();
	For Each vQryResRow In vQryRes Do
		FillPropertyValues(vStruct, vQryResRow);
		Break;
	EndDo;
	
	Return vStruct;
EndFunction //cmGetEmployeeAndOperationByPBXCode

//-----------------------------------------------------------------------------
// Description: Returns employee by PBX employee account code
// Parameters: PBX account code
// Return value: Reference to the employee item
//-----------------------------------------------------------------------------
Function cmGetEmployeeByPBXCode(pPBXCode) Экспорт
	vEmployee = Неопределено;
	If pPBXCode = 0 Тогда
		Return vEmployee;
	EndIf;
	
	// Run query
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	Сотрудники.Ref AS Employee
	|FROM
	|	Catalog.Сотрудники AS Employees
	|WHERE
	|	Сотрудники.КодДоступаАТС = &qPBXCode
	|	AND (NOT Сотрудники.DeletionMark)
	|	AND (NOT Сотрудники.IsFolder)";
	vQry.SetParameter("qPBXCode", pPBXCode);
	vQryRes = vQry.Execute().Unload();
	For Each vQryResRow In vQryRes Do
		vEmployee = vQryResRow.Employee;
		Break;
	EndDo;
	
	Return vEmployee;
EndFunction //cmGetEmployeeByPBXCode 

//-----------------------------------------------------------------------------
// Description: Returns pending employee operation (started but not finished)
// Parameters: Employee, Operation, Date
// Return value: Employee operation document reference
//-----------------------------------------------------------------------------
Function cmGetPendingEmployeeOperation(pEmployee, pOperation, pPeriod, pRoom) Экспорт
	// Run query to get pending employee operation
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	EmployeeOperationsHistorySliceLast.Recorder
	|FROM
	|	InformationRegister.EmployeeOperationsHistory.SliceLast(
	|			&qPeriod,
	|			Employee = &qEmployee
	|				AND Operation = &qOperation
	|				AND OperationEndTime = &qEmptyTime) AS EmployeeOperationsHistorySliceLast";
	vQry.SetParameter("qEmployee", pEmployee);
	vQry.SetParameter("qOperation", pOperation);
	vQry.SetParameter("qPeriod", pPeriod);
	vQry.SetParameter("qEmptyTime", '00010101');
	vQryRes = vQry.Execute().Unload();
	For Each vQryResRow In vQryRes Do
		vEmpOpr = vQryResRow.Recorder;
		Break;
	EndDo;
	// Try to find the same operation started by another employee
	If НЕ ЗначениеЗаполнено(vEmpOpr) Тогда
		vQry = New Query();
		vQry.Text = 
		"SELECT
		|	EmployeeOperationsHistory.Recorder
		|FROM
		|	InformationRegister.EmployeeOperationsHistory AS EmployeeOperationsHistory
		|WHERE
		|	EmployeeOperationsHistory.НомерРазмещения = &qRoom
		|	AND EmployeeOperationsHistory.Operation = &qOperation
		|	AND EmployeeOperationsHistory.OperationStartTime <= &qPeriod
		|	AND EmployeeOperationsHistory.OperationEndTime = &qEmptyTime
		|
		|ORDER BY
		|	EmployeeOperationsHistory.OperationStartTime DESC";
		vQry.SetParameter("qRoom", pRoom);
		vQry.SetParameter("qOperation", pOperation);
		vQry.SetParameter("qPeriod", pPeriod);
		vQry.SetParameter("qEmptyTime", '00010101');
		vQryRes = vQry.Execute().Unload();
		For Each vQryResRow In vQryRes Do
			vEmpOpr = vQryResRow.Recorder;
			Break;
		EndDo;
	EndIf;
	Return vEmpOpr;
EndFunction //cmGetPendingEmployeeOperation

//-----------------------------------------------------------------------------
// Description: Returns value table of all pending employee operations for the 
//              given rooms list
// Parameters: Rooms value list
// Return value: Value table with employee operations data
//-----------------------------------------------------------------------------
Function cmGetPendingEmployeeOperations(pRooms) Экспорт
	// Run query to get pending employee operations
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	EmployeeOperationsHistorySliceLast.НомерРазмещения,
	|	EmployeeOperationsHistorySliceLast.OperationStartTime,
	|	EmployeeOperationsHistorySliceLast.Employee,
	|	EmployeeOperationsHistorySliceLast.Примечания
	|FROM
	|	InformationRegister.EmployeeOperationsHistory.SliceLast(
	|			&qPeriod,
	|			НомерРазмещения IN (&qRooms)
	|				AND OperationEndTime = &qEmptyTime) AS EmployeeOperationsHistorySliceLast";
	vQry.SetParameter("qRooms", pRooms);
	vQry.SetParameter("qPeriod", CurrentDate());
	vQry.SetParameter("qEmptyTime", '00010101');
	vQryRes = vQry.Execute().Unload();
	Return vQryRes;
EndFunction //cmGetPendingEmployeeOperations

//-----------------------------------------------------------------------------
// Description: Returns value table of all employee operations for the 
//              given operation and operation start time
// Parameters: Employee, Operation, Operation start time
// Return value: Value table with employee operation documents
//-----------------------------------------------------------------------------
Function cmGetEmployeeOperation(pEmployee, pOperation, pOperationStartTime) Экспорт
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	EmployeeOperationsHistory.Recorder
	|FROM
	|	InformationRegister.EmployeeOperationsHistory AS EmployeeOperationsHistory
	|WHERE
	|	EmployeeOperationsHistory.Employee = &qEmployee
	|	AND EmployeeOperationsHistory.Operation = &qOperation
	|	AND EmployeeOperationsHistory.OperationStartTime = &qOperationStartTime
	|ORDER BY
	|	EmployeeOperationsHistory.PointInTime";
	vQry.SetParameter("qEmployee", pEmployee);
	vQry.SetParameter("qOperation", pOperation);
	vQry.SetParameter("qOperationStartTime", pOperationStartTime);
	vEmpOperations = vQry.Execute().Unload();
	Return vEmpOperations;
EndFunction //cmGetEmployeeOperation

//-----------------------------------------------------------------------------
// Description: Returns value table with ГруппаНомеров status last change author and date 
//              for the given rooms list
// Parameters: Rooms value list
// Return value: Value table with ГруппаНомеров status change data
//-----------------------------------------------------------------------------
Function cmGetAuthorAndDateOfLastChangeOfRoomStatuses(pRooms) Экспорт
	// Run query to get pending employee operations
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	ИсторияИзмСтатусаНомеров.Period,
	|	ИсторияИзмСтатусаНомеров.User,
	|	ИсторияИзмСтатусаНомеров.НомерРазмещения,
	|	ИсторияИзмСтатусаНомеров.СтатусНомера,
	|	ИсторияИзмСтатусаНомеров.Примечания
	|FROM
	|	InformationRegister.ИсторияИзмСтатусаНомеров AS ИсторияИзмСтатусаНомеров
	|		INNER JOIN InformationRegister.ИсторияИзмСтатусаНомеров.SliceLast(&qPeriod, НомерРазмещения IN (&qRooms)) AS RoomStatusChangeHistorySliceLast
	|		ON ИсторияИзмСтатусаНомеров.Period = RoomStatusChangeHistorySliceLast.Period
	|			AND ИсторияИзмСтатусаНомеров.НомерРазмещения = RoomStatusChangeHistorySliceLast.НомерРазмещения
	|WHERE
	|	ИсторияИзмСтатусаНомеров.НомерРазмещения IN(&qRooms)";
	vQry.SetParameter("qRooms", pRooms);
	vQry.SetParameter("qPeriod", CurrentDate());
	vQryRes = vQry.Execute().Unload();
	Return vQryRes;
EndFunction //cmGetAuthorAndDateOfLastChangeOfRoomStatuses
