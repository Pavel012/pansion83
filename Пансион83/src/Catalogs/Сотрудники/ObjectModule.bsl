//-----------------------------------------------------------------------------
Function pmGetEmployeeDescription(pLang) Экспорт
	vDescr = "";
	If НЕ ЗначениеЗаполнено(pLang) Тогда
		vDescr = СокрЛП(Description);
		EndIf;
	Return vDescr;
EndFunction //pmGetEmployeeDescription

//-----------------------------------------------------------------------------
// Get employee operation pbx codes
//-----------------------------------------------------------------------------
Function pmGetOperationPBXCodes(pOperation) Экспорт
	// Build and run query to get data for the operation
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	*
	|FROM
	|	InformationRegister.EmployeePBXCodes AS EmployeePBXCodes
	|WHERE
	|	EmployeePBXCodes.Employee = &qEmployee
	|	AND EmployeePBXCodes.Operation = &qOperation";
	vQry.SetParameter("qEmployee", Ref);
	vQry.SetParameter("qOperation", pOperation);
	vCodes = vQry.Execute().Unload();
	Return vCodes;
EndFunction //pmGetOperationPBXCodes

//-----------------------------------------------------------------------------
Function pmGetNonReplicatingAttributes() Экспорт
	Return СохранениеНастроек.сmGetEmployeeNonReplicatingAttributes(Ref);
EndFunction //pmGetNonReplicatingAttributes