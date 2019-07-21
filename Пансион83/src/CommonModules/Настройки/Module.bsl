//-----------------------------------------------------------------------------
// Description: Returns catalog object reference by it's external system code
// Parameters: Гостиница, External system code, Name of the catalog in the 
//             metadata, Object's code in the external system
// Return value: Reference to the catalog object or undefined
//-----------------------------------------------------------------------------
Function cmGetObjectRefByExternalSystemCode(pHotelRef, pExternalSystemCode, pObjectTypeName, pObjectExternalCode) Экспорт
	vObjectRef = Неопределено;
	// Try to find reference to the object in the program by external code
	If НЕ IsBlankString(pExternalSystemCode) And НЕ IsBlankString(pObjectExternalCode) Тогда
		vQry = New Query();
		vQry.Text = 
		"SELECT
		|	ExternalSystemsObjectCodesMappings.ObjectRef
		|FROM
		|	InformationRegister.ExternalSystemsObjectCodesMappings AS ExternalSystemsObjectCodesMappings
		|WHERE
		|	ExternalSystemsObjectCodesMappings.Гостиница = &qHotel
		|	AND ExternalSystemsObjectCodesMappings.ExternalSystemCode = &qExternalSystemCode
		|	AND ExternalSystemsObjectCodesMappings.ObjectTypeName = &qObjectTypeName
		|	AND ExternalSystemsObjectCodesMappings.ObjectExternalCode = &qObjectExternalCode";
		vQry.SetParameter("qHotel", pHotelRef);
		vQry.SetParameter("qExternalSystemCode", СокрЛП(pExternalSystemCode));
		vQry.SetParameter("qObjectTypeName", СокрЛП(pObjectTypeName));
		vQry.SetParameter("qObjectExternalCode", СокрЛП(pObjectExternalCode));
		vObjects = vQry.Execute().Unload();
		If vObjects.Count() = 1 Тогда
			vObjectRef = vObjects.Get(0).ObjectRef;
		EndIf;
	EndIf;
	If НЕ ЗначениеЗаполнено(vObjectRef) And НЕ IsBlankString(pObjectExternalCode) And НЕ IsBlankString(pObjectTypeName) Тогда
		// Try to find object ref by code assuming that object type name is name of the catalog
		vQry = New Query();
		
		If pObjectTypeName = "НомернойФонд" Тогда
			vQry = New Query();
			vQry.Text = 
			"SELECT
			|	CatalogItems.Ref
			|FROM
			|	Catalog." + pObjectTypeName + " AS CatalogItems
			|WHERE
			|	(NOT CatalogItems.DeletionMark)
			|	AND CatalogItems.Description = &qObjectExternalCode";
		ElsIf pObjectTypeName = "ТипыНомеров" Тогда
			vQry.Text = 
			"SELECT
			|	CatalogItems.Ref
			|FROM
			|	Catalog." + pObjectTypeName + " AS CatalogItems
			|WHERE
			|	NOT CatalogItems.DeletionMark
			|	AND CatalogItems.Code = &qObjectExternalCode
			|	AND (CatalogItems.Owner = &qHotel
			|		OR &qHotelIsEmpty)";
			vQry.SetParameter("qHotel", pHotelRef);
			vQry.SetParameter("qHotelIsEmpty", НЕ ЗначениеЗаполнено(pHotelRef));
		Else
			vQry.Text = 
			"SELECT
			|	CatalogItems.Ref
			|FROM
			|	Catalog." + pObjectTypeName + " AS CatalogItems
			|WHERE
			|	(NOT CatalogItems.DeletionMark)
			|	AND CatalogItems.Code = &qObjectExternalCode";
		EndIf;
		vQry.SetParameter("qObjectExternalCode", СокрЛП(pObjectExternalCode));
		vObjects = vQry.Execute().Unload();
		If vObjects.Count() = 1 Тогда
			vObjectRef = vObjects.Get(0).Ref;
		EndIf;
	EndIf;
	If НЕ ЗначениеЗаполнено(vObjectRef) And НЕ IsBlankString(pObjectExternalCode) Тогда
		// Try to find object ref by description assuming that object type name is name of the catalog
		vQry = New Query();
		vQry.Text = 
		"SELECT
		|	CatalogItems.Ref
		|FROM
		|	Catalog." + pObjectTypeName + " AS CatalogItems
		|WHERE
		|	(NOT CatalogItems.DeletionMark)
		|	AND CatalogItems.Description = &qObjectExternalCode";
		vQry.SetParameter("qObjectExternalCode", СокрЛП(pObjectExternalCode));
		vObjects = vQry.Execute().Unload();
		If vObjects.Count() = 1 Тогда
			vObjectRef = vObjects.Get(0).Ref;
		EndIf;
	EndIf;
	Return vObjectRef;
EndFunction //cmGetObjectRefByExternalSystemCode 

//-----------------------------------------------------------------------------
// Description: Returns catalog object external code for the external system
// Parameters: Гостиница, External system code, Name of the catalog in the 
//             metadata, Catalog object reference
// Return value: Code of the catalog object in the external system or empty string
//-----------------------------------------------------------------------------
Function cmGetObjectExternalSystemCodeByRef(pHotelRef, pExternalSystemCode, pObjectTypeName, pObjectRef, pEmptyIfNotFound = False) Экспорт
	vObjectExternalCode = "";
	// Try to find reference to the object in the program by external code
	If ЗначениеЗаполнено(pObjectRef) Тогда
		vQry = New Query();
		vQry.Text = 
		"SELECT
		|	ExternalSystemsObjectCodesMappings.ObjectExternalCode
		|FROM
		|	InformationRegister.ExternalSystemsObjectCodesMappings AS ExternalSystemsObjectCodesMappings
		|WHERE
		|	ExternalSystemsObjectCodesMappings.Гостиница = &qHotel
		|	AND ExternalSystemsObjectCodesMappings.ExternalSystemCode = &qExternalSystemCode
		|	AND ExternalSystemsObjectCodesMappings.ObjectTypeName = &qObjectTypeName
		|	AND ExternalSystemsObjectCodesMappings.ObjectRef = &qObject";
		vQry.SetParameter("qHotel", pHotelRef);
		vQry.SetParameter("qExternalSystemCode", СокрЛП(pExternalSystemCode));
		vQry.SetParameter("qObjectTypeName", СокрЛП(pObjectTypeName));
		vQry.SetParameter("qObject", pObjectRef);
		vObjects = vQry.Execute().Unload();
		If vObjects.Count() = 1 Тогда
			vObjectExternalCode = vObjects.Get(0).ObjectExternalCode;
		EndIf;
		If IsBlankString(vObjectExternalCode) And НЕ pEmptyIfNotFound Тогда
			// Try to return object description instead
			Try
				vObjectExternalCode = СокрЛП(pObjectRef.Description);
			Except
				vObjectExternalCode = "";
			EndTry;
		EndIf;
	EndIf;
	Return vObjectExternalCode;
EndFunction //cmGetObjectRefByExternalSystemCode 

//-----------------------------------------------------------------------------
// Description: Clears mappings for given hotel, external system name and object type
// Parameters: Гостиница, External system code, Name of the catalog in the 
//             metadata
// Return value: None
//-----------------------------------------------------------------------------
Процедура cmClearExternalSystemObjectMapping(pHotelRef, pExternalSystemCode, pObjectTypeName) Экспорт
	vMgrObj = InformationRegisters.ExternalSystemsObjectCodesMappings.CreateRecordManager();
	vRcdSetObj = InformationRegisters.ExternalSystemsObjectCodesMappings.CreateRecordSet();
	
	vHotelFlt = vRcdSetObj.Filter.Гостиница;
	vHotelFlt.ComparisonType = ComparisonType.Equal;
	vHotelFlt.Value = pHotelRef;
	vHotelFlt.Use = True;
	
	vExtSystemCodeFlt = vRcdSetObj.Filter.ExternalSystemCode;
	vExtSystemCodeFlt.ComparisonType = ComparisonType.Equal;
	vExtSystemCodeFlt.Value = TrimR(pExternalSystemCode);
	vExtSystemCodeFlt.Use = True;
	
	vObjectTypeFlt = vRcdSetObj.Filter.ObjectTypeName;
	vObjectTypeFlt.ComparisonType = ComparisonType.Equal;
	vObjectTypeFlt.Value = TrimR(pObjectTypeName);
	vObjectTypeFlt.Use = True;
	
	vRcdSetObj.Read();
	For Each vRcdSetObjRow In vRcdSetObj Do
		vObjectExternalCode = TrimR(vRcdSetObjRow.ObjectExternalCode);
		If pObjectTypeName = "ВидыРазмещения" And 
		   (vObjectExternalCode = "OneGuestInRoom" Or vObjectExternalCode = "Together" Or vObjectExternalCode = "MainGuestInRoom") Тогда
			Continue;
		EndIf;
		vMgrObj.Гостиница = pHotelRef;
		vMgrObj.ExternalSystemCode = TrimR(pExternalSystemCode);
		vMgrObj.ObjectTypeName = TrimR(pObjectTypeName);
		vMgrObj.ObjectExternalCode = vObjectExternalCode;
		vMgrObj.Read();
		If vMgrObj.Selected() Тогда
			vMgrObj.Delete();
		EndIf;
	EndDo;
КонецПроцедуры //cmClearExternalSystemObjectMapping
	
//-----------------------------------------------------------------------------
// Description: Creates or updates record in external system objects mapping table
// Parameters: Гостиница, External system code, Name of the catalog in the 
//             metadata, Код объекта в 1C:Отель, Код объекта во внешней системе
// Return value: None
//-----------------------------------------------------------------------------
Процедура cmSaveExternalSystemObjectMapping(pHotelRef, pExternalSystemCode, pObjectTypeName, pObjectCode, pExtObjectCode) Экспорт
	// Try to find object ref by code
	vObjectRef = Справочники[pObjectTypeName].FindByCode(TrimR(pObjectCode), False, , pHotelRef);
	// Try to update existing mapping or create new one
	vMgrObj = InformationRegisters.ExternalSystemsObjectCodesMappings.CreateRecordManager();
	vMgrObj.Гостиница = pHotelRef;
	vMgrObj.ExternalSystemCode = TrimR(pExternalSystemCode);
	vMgrObj.ObjectTypeName = TrimR(pObjectTypeName);
	vMgrObj.ObjectExternalCode = TrimR(pExtObjectCode);
	vMgrObj.ObjectRef = vObjectRef;
	vMgrObj.Write(True);
КонецПроцедуры //cmSaveExternalSystemObjectMapping

//-----------------------------------------------------------------------------
// Description: Copies last to the current time interaction ID translation table data
// Parameters: None
// Return value: None
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Description: Returns reference to interaction item by external id
// Parameters: Interaction ID as string
// Return value: Reference to interaction item
//-----------------------------------------------------------------------------
Function cmGetInteractionByID(pInteractionID) Экспорт
	vQry = New Query();
	vQry.Text = 
	"SELECT
	|	ВзамВнешниеСистемы.Ref
	|FROM
	|	Catalog.ВзамВнешниеСистемы AS ExternalSystemInteractions
	|WHERE
	|	NOT ВзамВнешниеСистемы.DeletionMark
	|	AND ВзамВнешниеСистемы.InteractionID = &qInteractionID
	|	AND NOT ВзамВнешниеСистемы.IsFolder
	|	AND ВзамВнешниеСистемы.IsActive";
	vQry.SetParameter("qInteractionID", pInteractionID);
	Return vQry.Execute().Unload();
EndFunction //cmGetInteractionByID
