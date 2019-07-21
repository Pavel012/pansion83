//-----------------------------------------------------------------------------
&AtServer
Функция cmGetDocumentItemRefByDocNumber(pDocName, pDocNumber, pEmptyRef=False) Экспорт	
	Если pEmptyRef = Неопределено Тогда
		pEmptyRef = False;
	КонецЕсли;
	Если pEmptyRef Тогда
		Возврат Documents[pDocName].EmptyRef();
	Else
		vDocRef = Documents[pDocName].FindByNumber(pDocNumber);
		Возврат vDocRef;
	КонецЕсли;
КонецФункции //cmGetDocumentItemRefByDocNumber

//-----------------------------------------------------------------------------
&AtServer
Функция cmGetCatalogItemRefByCode(pCatalogName, pCode = "", pEmptyRef=False, pAttribute="")	Экспорт	
	Если pEmptyRef = Неопределено Тогда
		pEmptyRef = False;
	КонецЕсли;
	Если pAttribute = Неопределено Тогда
		pAttribute = "";
	КонецЕсли;
	Если pEmptyRef Тогда
		Возврат Справочники[pCatalogName].EmptyRef();
	Else
		Если ЗначениеЗаполнено(pAttribute) Тогда
			vCatalogRef = Справочники[pCatalogName].FindByCode(pCode)[pAttribute];
		Else
			vCatalogRef = Справочники[pCatalogName].FindByCode(pCode);
		КонецЕсли;
		Возврат vCatalogRef;
	КонецЕсли;
КонецФункции //cmGetCatalogItemRefByCode

//-----------------------------------------------------------------------------
&AtServer
Функция cmGetCatalogItemRefByName(pCatalogName, pName = "", pEmptyRef=False, pAttribute="")	Экспорт	
	Если pEmptyRef = Неопределено Тогда
		pEmptyRef = False;
	КонецЕсли;
	Если pAttribute = Неопределено Тогда
		pAttribute = "";
	КонецЕсли;
	Если pEmptyRef Тогда
		Возврат Справочники[pCatalogName].EmptyRef();
	Else
		Если ЗначениеЗаполнено(pAttribute) Тогда
			vCatalogRef = Справочники[pCatalogName][pName][pAttribute];
		Else
			vCatalogRef = Справочники[pCatalogName][pName];
		КонецЕсли;
		Возврат vCatalogRef;
	КонецЕсли;
КонецФункции //cmGetCatalogItemRefByName

//-----------------------------------------------------------------------------
&AtServer
Функция cmGetCatalogItemRefByDescription(pCatalogName, pDescription = "", pEmptyRef=False, pAttribute="") Экспорт	
	Если pEmptyRef = Неопределено Тогда
		pEmptyRef = False;
	КонецЕсли;
	Если pAttribute = Неопределено Тогда
		pAttribute = "";
	КонецЕсли;
	Если pEmptyRef Тогда
		Возврат Справочники[pCatalogName].EmptyRef();
	Else
		Если ЗначениеЗаполнено(pAttribute) Тогда
			vCatalogRef = Справочники[pCatalogName].FindByDescription(pDescription, True)[pAttribute];
		Else
			vCatalogRef = Справочники[pCatalogName].FindByDescription(pDescription, True);
		КонецЕсли;
		Возврат vCatalogRef;
	КонецЕсли;
КонецФункции //cmGetCatalogItemRefByDescription

//-----------------------------------------------------------------------------
&AtServer
Функция cmGetEnumItem(pEnumName, pEnumItem) Экспорт
	vEnum = Перечисления[pEnumName][pEnumItem];
	Возврат vEnum;
КонецФункции //cmGetEnumItem

//-----------------------------------------------------------------------------
&AtServer
Функция cmGetAttributeByRef(pRef, pAttribute = "") Экспорт
	Если pAttribute = Неопределено Тогда
		pAttribute = "";
	КонецЕсли;
	Если Не ЗначениеЗаполнено(pAttribute) Тогда
		vVal = pRef.Description;
	Else
		vFindedDot = Find(pAttribute, ".");
		Если vFindedDot > 0 Тогда
			vFirstAttribute = Left(pAttribute, vFindedDot-1);
			vSecondAttribute = Right(pAttribute, StrLen(pAttribute)-vFindedDot);
			vVal = pRef[vFirstAttribute];
			vVal = vVal[vSecondAttribute];
		Else
			vVal = pRef[pAttribute];
		КонецЕсли;
	КонецЕсли;
	Возврат vVal;
КонецФункции //cmGetAttributeByRef

//-----------------------------------------------------------------------------
&AtServer
Процедура cmChangeObjectAttributeByRef(pRef, pAttribute = "", pValue = Неопределено) Экспорт
	Если Не ЗначениеЗаполнено(pRef) Or Не ЗначениеЗаполнено(pAttribute) Тогда
		Возврат;
	КонецЕсли;
	Try
		vObj = pRef.GetObject();
		vObj[pAttribute] = pValue;
		vObj.Write();
	Except
		Возврат;
	EndTry;
КонецПроцедуры //cmChangeObjectAttributeByRef

//-----------------------------------------------------------------------------
&AtServer
Функция cmGetMetadataMethodOrAttribiteByRef(pRef, pMethod = "", pAttribute = "") Экспорт
	//Check paramters
	Если pAttribute = Неопределено Тогда
		pAttribute = "";
	КонецЕсли;
	Если pMethod = Неопределено Тогда
		pMethod = "";
	КонецЕсли;
	Если Не IsBlankString(pMethod) Тогда
		Если pMethod = "Presentation" Тогда
			vVal = pRef.Metadata().Presentation();
		ИначеЕсли pMethod = "FullName" Тогда
			vVal = pRef.Metadata().FullName();
		ИначеЕсли pMethod = "Parent" Тогда
			vVal = pRef.Metadata().Parent();
		Else
			vVal = pRef.Description;
		КонецЕсли;
	Else
		Если Не IsBlankString(pAttribute) Тогда
			vVal = pRef.Metadata[pAttribute];
		Else
			vVal = pRef.Description;
		КонецЕсли;
	КонецЕсли;
	Возврат vVal;
КонецФункции //cmGetMetadataMethodOrAttribiteByRef

//-----------------------------------------------------------------------------
// Description: Returns icon of the given ГруппаНомеров status
// Parameters: ГруппаНомеров status 
// Возврат value: Picture object
//-----------------------------------------------------------------------------
&AtServer
Функция cmGetRoomStatusIconOnServer(pRoomStatus) Экспорт
	vPicture = PictureLib.Empty;
	Если ЗначениеЗаполнено(pRoomStatus) Тогда
		Если ЗначениеЗаполнено(pRoomStatus.RoomStatusIcon) Тогда
			Если pRoomStatus.RoomStatusIcon = Перечисления.RoomStatusesIcons.Occupied Тогда
				vPicture = PictureLib.Occupied;
			ИначеЕсли pRoomStatus.RoomStatusIcon = Перечисления.RoomStatusesIcons.Reserved Тогда
				vPicture = PictureLib.Reserved;
			ИначеЕсли pRoomStatus.RoomStatusIcon = Перечисления.RoomStatusesIcons.Waiting Тогда
				vPicture = PictureLib.Waiting;
			ИначеЕсли pRoomStatus.RoomStatusIcon = Перечисления.RoomStatusesIcons.TidyingUp Тогда
				vPicture = PictureLib.TidyingUp;
			ИначеЕсли pRoomStatus.RoomStatusIcon = Перечисления.RoomStatusesIcons.ВыездФакт Тогда
				vPicture = PictureLib.ВыездФакт;
			ИначеЕсли pRoomStatus.RoomStatusIcon = Перечисления.RoomStatusesIcons.Vacant Тогда
				vPicture = PictureLib.Vacant;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	Возврат vPicture;
КонецФункции //cmGetRoomStatusIconOnServer

//-----------------------------------------------------------------------------
&AtServer
Функция cmGetCurrentHotelAttribute(pAttr = "") Экспорт
	//Check parameters
	Если pAttr = Неопределено Тогда
		pAttr = "";
	КонецЕсли;
	Если ЗначениеЗаполнено(pAttr) Тогда
		Возврат ПараметрыСеанса.ТекущаяГостиница[pAttr];
	Else
		Возврат ПараметрыСеанса.ТекущаяГостиница;
	КонецЕсли;
КонецФункции //cmGetCurrentHotelAttribute

//-----------------------------------------------------------------------------
&AtServer
Функция cmGetCurrentUserAttribute(pAttr = "") Экспорт
	Если pAttr = Неопределено Тогда
		pAttr = "";
	КонецЕсли;
	Если ЗначениеЗаполнено(pAttr) Тогда
		Возврат ПараметрыСеанса.ТекПользователь[pAttr];
	Else
		Возврат ПараметрыСеанса.ТекПользователь;
	КонецЕсли;
КонецФункции //cmGetCurrentUserAttribute

//-----------------------------------------------------------------------------
&AtServer
Функция cmGetGuestsChoiceDataList(pText) Экспорт
	vChoiceDataList = Новый СписокЗначений;
	vQry = Новый Query;
	vQry.Text =
	"SELECT
	|	Клиенты.Ref,
	|	Клиенты.Description,
	|	Клиенты.FullName,
	|	Клиенты.Code,
	|	Клиенты.ДатаРождения,
	|	Клиенты.IdentityDocumentSeries AS IDSeries,
	|	Клиенты.IdentityDocumentNumber AS IDNumber
	|FROM
	|	Catalog.Клиенты AS Клиенты
	|WHERE
	|	NOT Клиенты.IsFolder
	|	AND NOT Клиенты.DeletionMark
	|	AND Клиенты.FullName LIKE &qText";
	vQry.SetParameter("qText", "%"+pText+"%");
	vQryResult = vQry.Execute().Choose();
	Пока vQryResult.Next() Цикл
		vChoiceDataList.Add(vQryResult.Ref, vQryResult.FullName+?(ЗначениеЗаполнено(vQryResult.ДатаРождения), " "+Format(vQryResult.ДатаРождения, "DLF=D")+" ", " ")+?(ЗначениеЗаполнено(vQryResult.IDSeries), СокрЛП(vQryResult.IDSeries)+" ", " ")+?(ЗначениеЗаполнено(vQryResult.IDNumber), СокрЛП(vQryResult.IDNumber)+" ", " ")+"("+?(Число(vQryResult.Code), Format(Number(vQryResult.Code), "ND=12; NFD=0; NG="), СокрЛП(vQryResult.Code))+")");
	EndDo;
	//Возврат
	Возврат PutToTempStorage(vChoiceDataList);
КонецФункции //cmGetGuestsChoiceDataList

//-----------------------------------------------------------------------------
&AtServer
Функция cmChangeCurrentHotel(pHotel) Экспорт
	Если ЗначениеЗаполнено(pHotel) Тогда
		ПараметрыСеанса.ТекущаяГостиница = pHotel;
		Возврат pHotel.GetObject().pmGetHotelPrintName(ПараметрыСеанса.ТекЛокализация);
	Else
		Возврат "";
	КонецЕсли;
КонецФункции //cmChangeCurrentHotel

//-----------------------------------------------------------------------------
// Description: Returns text according to the current or parameter language.  
//              In comparison to the NStr() function it is simply returns input string if 
//              string format is wrong or language is undefined. NStr() in this case returns empty string
// Parameters: Text string in different languages, Language
// Возврат value: Text in given language
//-----------------------------------------------------------------------------
&AtServer
Функция cmNStrAtServer(pStr, pLang = Неопределено) Экспорт
	vStr = TrimR(pStr);
	vStr = StrReplace(vStr, "RU = '", "ru='");
	vStr = StrReplace(vStr, "RU='", "ru='");
	vStr = StrReplace(vStr, "EN = '", "en='");
	vStr = StrReplace(vStr, "EN='", "en='");
	vStr = StrReplace(vStr, "DE = '", "de='");
	vStr = StrReplace(vStr, "DE='", "de='");
	vNStr = "";
	Если pLang = Неопределено Тогда
		vNStr = NStr(vStr);
	Else
		vNStr = NStr(vStr, Lower(СокрЛП(pLang.Code)));
	КонецЕсли;
	Если IsBlankString(vNStr) Тогда
		vDePos = Find(vStr, "de='");
		Если vDePos = 0 Тогда
			vEnPos = Find(vStr, "en='");
			Если vEnPos > 0 Тогда
				vEnText = Mid(vStr, vEnPos + 4);
				vApPos = Find(vEnText, "'");
				Если vApPos > 0 Тогда
					vEnText = Left(vEnText, vApPos - 1);
					Если Не IsBlankString(vEnText) Тогда
						vFixedStr = vStr + ";de='" + vEnText + "'";
						Если pLang = Неопределено Тогда
							vNStr = NStr(vFixedStr);
						Else
							vNStr = NStr(vFixedStr, СокрЛП(pLang.Code));
						КонецЕсли;
						Если Не IsBlankString(vNStr) Тогда
							Возврат vNStr;
						КонецЕсли;
					КонецЕсли;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
		Возврат vStr;
	Else
		Возврат vNStr;
	КонецЕсли;
КонецФункции //cmNStrAtServer

//-----------------------------------------------------------------------------
&AtServer
Процедура cmWriteLogEventAtServer(pEventName, pEventLogLevel = Неопределено, pMetadata = Неопределено, pData = Неопределено, pRemarks = "") Экспорт
	vMetadata = Неопределено;
	Если pMetadata <> Неопределено Тогда
		Execute("vMetadata = Metadata."+pMetadata);
	КонецЕсли;
	vData = Неопределено;
	Если pData <> Неопределено Тогда
		Execute("vData = "+pData);
	КонецЕсли;
	WriteLogEvent(pEventName, ?(pEventLogLevel=Неопределено, EventLogLevel.Information, pEventLogLevel), vMetadata, vData, pRemarks);
КонецПроцедуры //cmWriteLogEventAtServer

//-----------------------------------------------------------------------------
&AtServer
Функция cmCheckUserPermissionsAtServer(pPermission) Экспорт
	Возврат cmCheckUserPermissions(pPermission);
КонецФункции //cmCheckUserPermissionsAtServer

//-----------------------------------------------------------------------------
&AtServer
Функция cmGetEmployeePermissionGroupAtServer(pEmployee) Экспорт
	Возврат cmGetEmployeePermissionGroup(pEmployee);
КонецФункции //cmGetEmployeePermissionGroupAtServer

//-----------------------------------------------------------------------------
&AtServer
Функция cmGetServerCurrentDate() Экспорт
	Возврат CurrentDate();
КонецФункции //cmGetServerCurrentDate

