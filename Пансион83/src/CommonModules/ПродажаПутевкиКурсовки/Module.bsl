//-----------------------------------------------------------------------------
// Description: Returns value table with all hotel products
// Parameters: Гостиница products folder to return products from, Maximum number of 
//             products to return, return items and folders or items only
// Return value: Value table
//-----------------------------------------------------------------------------
Function cmGetAllHotelProducts(pHotelProductFolder = Неопределено, pTop = 0, pShowFolders = False) Экспорт
	// Build and run query
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ " + ?(pTop = 0, "", "ПЕРВЫЕ " + pTop) + "
	|	ПутевкиКурсовки.Ссылка КАК Путевка
	|ИЗ
	|	Справочник.ПутевкиКурсовки КАК ПутевкиКурсовки
	|ГДЕ 
	|	ПутевкиКурсовки.ПометкаУдаления = FALSE " + 
		?(НЕ pShowFolders, " И ПутевкиКурсовки.ЭтоГруппа = FALSE ", "") +
		?(ЗначениеЗаполнено(pHotelProductFolder), " И ПутевкиКурсовки.ссылка В ИЕРАРХИЯ(&qHotelProductFolder) ", "") + "
	|УПОРЯДОЧИТЬ ПО ПутевкиКурсовки.Код";
	Запрос.SetParameter("qHotelProductFolder", pHotelProductFolder);
	vList = Запрос.Выполнить().Выгрузить();
	Return vList;
EndFunction //cmGetAllHotelProducts

//-----------------------------------------------------------------------------
// Description: Returns value table with all hotel product folders
// Parameters: Гостиница products folder to return folders from, Maximum number of 
//             product folders to return
// Return value: Value table
//-----------------------------------------------------------------------------
Function cmGetAllHotelProductFolders(pHotelProductFolder = Неопределено, pTop = 0) Экспорт
	// Build and run query
	vQry = New Query;
	vQry.Text = 
	"SELECT " + ?(pTop = 0, "", "TOP " + pTop) + "
	|	ПутевкиКурсовки.Ref AS ПутевкаКурсовка
	|FROM
	|	Catalog.ПутевкиКурсовки AS HotelProducts
	|WHERE 
	|	ПутевкиКурсовки.IsFolder = TRUE AND " +
		?(ЗначениеЗаполнено(pHotelProductFolder), "ПутевкиКурсовки.Ref IN HIERARCHY(&qHotelProductFolder) AND ", "") + "
	|	ПутевкиКурсовки.DeletionMark = FALSE
	|ORDER BY ПутевкиКурсовки.Code";
	vQry.SetParameter("qHotelProductFolder", pHotelProductFolder);
	vList = vQry.Execute().Unload();
	Return vList;
EndFunction //cmGetAllHotelProductFolders

//-----------------------------------------------------------------------------
// Description: Returns value table with all social group items
// Parameters: Social group folder to return items from, Maximum number of 
//             items to return
// Return value: Value table
//-----------------------------------------------------------------------------
Function cmGetAllSocialGroups(pSocialGroupFolder = Неопределено, pTop = 0) Экспорт
	// Build and run query
	vQry = New Query;
	vQry.Text = 
	"SELECT " + ?(pTop = 0, "", "TOP " + pTop) + "
	|	SocialGroups.Ref AS SocialGroup
	|FROM
	|	Catalog.SocialGroups AS SocialGroups
	|WHERE 
	|	SocialGroups.IsFolder = FALSE AND " +
		?(ЗначениеЗаполнено(pSocialGroupFolder), "SocialGroups.Ref IN HIERARCHY(&qSocialGroupFolder) AND ", "") + "
	|	SocialGroups.DeletionMark = FALSE
	|ORDER BY SocialGroups.Code";
	vQry.SetParameter("qSocialGroupFolder", pSocialGroupFolder);
	vList = vQry.Execute().Unload();
	Return vList;
EndFunction //cmGetAllSocialGroups

//-----------------------------------------------------------------------------
// Description: Returns value table with hotel product items
// Parameters: Гостиница product code, Гостиница, Maximum number of 
//             products to return
// Return value: Value table
//-----------------------------------------------------------------------------
Function cmGetHotelProductsList(pCode, pHotel, pMaxNumber = 10, pShowDeleted = False) Экспорт
	// Build and run query
	qGetList = New Query;
	qGetList.Text = 
	"SELECT DISTINCT TOP " + pMaxNumber + "
	|	ПутевкиКурсовки.Code,
	|	ПутевкиКурсовки.Description,
	|	ПутевкиКурсовки.Ref
	|FROM
	|	Catalog.ПутевкиКурсовки AS HotelProducts
	|WHERE
	|	ПутевкиКурсовки.Гостиница = &qHotel AND 
	|	ПутевкиКурсовки.Code = &qCode AND 
	|	ПутевкиКурсовки.IsFolder = False AND
	|	(NOT &qShowDeleted AND NOT ПутевкиКурсовки.DeletionMark OR &qShowDeleted)
	|ORDER BY Description";
	qGetList.SetParameter("qHotel", pHotel);
	qGetList.SetParameter("qCode", СокрЛП(pCode));
	qGetList.SetParameter("qShowDeleted", pShowDeleted);
	vList = qGetList.Execute().Unload();
	Return vList;
EndFunction //cmGetHotelProductsList

//-----------------------------------------------------------------------------
// Description: Processes text edit end event in the hotel product controls
// Parameters: Object, Form, Гостиница product control, Text entered, Value to return, 
//             Standard processing flag 
// Return value: True if hotel product was changed, False if not
//-----------------------------------------------------------------------------
Function cmHotelProductTextEditEnd(pObject, pForm, pControl, pText, pValue, pStandardProcessing, pBaseObject = Неопределено) Экспорт
	vIsChanged = False;
	pStandardProcessing = False;
	vText = Upper(СокрЛП(pText));
	vTab = cmGetHotelProductsList(vText, ?(pObject <> Неопределено, pObject.Гостиница, ПараметрыСеанса.ТекущаяГостиница), 10, True);
	If vTab.Count() > 0 Тогда
		vRow = vTab.Get(0);
		vHPRef = vRow.Ref;
		If TypeOf(pObject) = Type("DocumentObject.Размещение") Or
		   TypeOf(pObject) = Type("DocumentObject.Бронирование") Or
		   TypeOf(pObject) = Type("DocumentObject.Начисление") Тогда
			If vHPRef.DeletionMark Тогда
				Message(NStr("en='This product was already deleted!'; de='Dieser Reisecheck/Kurkarte ist schon löschen!'; ru='Эта путевка/курсовка испорчена!'"), MessageStatus.Attention);
			Else
				Message(NStr("en='This product was already registered';ru='Эта путевка/курсовка уже зарегистрирована';de='Dieser Reisecheck/Kurkarte ist schon registriert'"), MessageStatus.Information);
			EndIf;
		EndIf;
		If TypeOf(pObject) = Type("DocumentObject.Размещение") Or
		   TypeOf(pObject) = Type("DocumentObject.Бронирование") Тогда
			If vHPRef.FixProductCost Тогда
				If vHPRef.Продолжительность > 0 And vHPRef.Сумма > 0 And 
				   (НЕ ЗначениеЗаполнено(vHPRef.CheckInDate) Or НЕ ЗначениеЗаполнено(vHPRef.CheckInDate)) Тогда
					vHPObj = vHPRef.GetObject();
					vReferenceHour = '00010101';
					If ЗначениеЗаполнено(pObject.Тариф) Тогда
						vReferenceHour = pObject.Тариф.ReferenceHour;
					EndIf;
					vHPObj.CheckInDate = BegOfDay(pObject.CheckInDate) + (vReferenceHour - BegOfDay(vReferenceHour));
					vHPObj.ДатаВыезда = vHPObj.CheckInDate + vHPObj.Продолжительность*24*3600;
					If vReferenceHour = '00010101' Тогда
						vHPObj.ДатаВыезда = vHPObj.ДатаВыезда - 1;
					EndIf;
					vHPObj.Write();
				EndIf;
			EndIf;
		EndIf;
		pValue = vHPRef;
		vIsChanged = True;
	Else
		Try
			// Try to find issued hotel product in the information register
			vQry = New Query();
			vQry.Text = 
			"SELECT
			|	IssuedHotelProducts.Recorder,
			|	IssuedHotelProducts.LineNumber,
			|	IssuedHotelProducts.Active,
			|	IssuedHotelProducts.ProductCode,
			|	IssuedHotelProducts.Гостиница,
			|	IssuedHotelProducts.Фирма,
			|	IssuedHotelProducts.Контрагент,
			|	IssuedHotelProducts.Договор,
			|	IssuedHotelProducts.ГруппаГостей,
			|	IssuedHotelProducts.ДокОснование,
			|	IssuedHotelProducts.КвотаНомеров,
			|	IssuedHotelProducts.BillOfShipment,
			|	IssuedHotelProducts.СтавкаНДС,
			|	IssuedHotelProducts.FixProductPeriod,
			|	IssuedHotelProducts.FixPlannedPeriod,
			|	IssuedHotelProducts.FixProductCost,
			|	IssuedHotelProducts.HotelProductParent,
			|	IssuedHotelProducts.CheckInDate,
			|	IssuedHotelProducts.Продолжительность,
			|	IssuedHotelProducts.ДатаВыезда,
			|	IssuedHotelProducts.Цена,
			|	IssuedHotelProducts.Валюта
			|FROM
			|	InformationRegister.IssuedHotelProducts AS IssuedHotelProducts
			|WHERE
			|	IssuedHotelProducts.ProductCode = &qProductCode
			|	AND IssuedHotelProducts.Гостиница = &qHotel
			|ORDER BY
			|	IssuedHotelProducts.Recorder.PointInTime DESC";
			vQry.SetParameter("qProductCode", vText);
			vQry.SetParameter("qHotel", pObject.Гостиница);
			vIHPs = vQry.Execute().Unload();
			If vIHPs.Count() > 0 Тогда
				vIHPRow = vIHPs.Get(0);
				// Create and return new hotel product filled with data from the issued one
				vHPObj = Справочники.ПутевкиКурсовки.CreateItem();
				vHPObj.CreateDate = CurrentDate();
				vHPObj.Автор = ПараметрыСеанса.ТекПользователь;
				vHPObj.Code = СокрЛП(vIHPRow.ProductCode);
				vHPObj.Description = СокрЛП(vHPObj.Code);
				FillPropertyValues(vHPObj, vIHPRow);
				vHPObj.Parent = vIHPRow.HotelProductParent;
				vHPObj.Сумма = vIHPRow.Цена;
				vHPObj.Write();
				pValue = vHPObj.Ref;
				vIsChanged = True;
			Else
				// If there are hotel product folders then ask user to choose one
				vHPFolder = Неопределено;
				// Try to get hotel product type from the ГруппаНомеров rate
				If TypeOf(pObject) = Type("DocumentObject.Размещение") Or
				   TypeOf(pObject) = Type("DocumentObject.Бронирование") Тогда
					If ЗначениеЗаполнено(pObject.Тариф) Тогда
						vHPFolder = pObject.Тариф.HotelProductType;
					EndIf;
				EndIf;					
				If НЕ ЗначениеЗаполнено(vHPFolder) Тогда
					vHPFolders = cmGetAllHotelProductFolders();
					If vHPFolders.Count() > 0 Тогда
						vHPFolder = Справочники.ПутевкиКурсовки.GetFolderChoiceForm().DoModal();
						If vHPFolder = Неопределено Тогда
							Return vIsChanged;
						EndIf;
					EndIf;
				EndIf;
				// If there are social groups then ask user to choose one if necessary
				vSocialGroup = Неопределено;
				vSocialGroups = cmGetAllSocialGroups();
				If vSocialGroups.Count() > 0 Тогда
					vSocialGroup = Справочники.SocialGroups.GetChoiceForm().DoModal();
					If vSocialGroup = Неопределено Тогда
						Return vIsChanged;
					EndIf;
				EndIf;
				// Create and return new hotel product
				vHPObj = Справочники.ПутевкиКурсовки.CreateItem();
				vHPObj.CreateDate = CurrentDate();
				vHPObj.Автор = ПараметрыСеанса.ТекПользователь;
				vHPObj.Code = Upper(СокрЛП(pText));
				vHPObj.Description = Upper(СокрЛП(pText));
				vHPObj.Гостиница = ?(pObject <> Неопределено, pObject.Гостиница, ПараметрыСеанса.ТекущаяГостиница);
				vHPObj.Валюта = vHPObj.Гостиница.ВалютаЛицСчета;
				vHPObj.SocialGroup = vSocialGroup;
				If ЗначениеЗаполнено(vHPFolder) Тогда
					vHPObj.Parent = vHPFolder;
					vHPObj.КвотаНомеров = vHPFolder.КвотаНомеров;
					vHPObj.FixProductCost = vHPFolder.FixProductCost;
					vHPObj.FixProductPeriod = vHPFolder.FixProductPeriod;
					vHPObj.FixPlannedPeriod = vHPFolder.FixPlannedPeriod;
				EndIf;
				If TypeOf(pObject) = Type("DocumentObject.Размещение") Or
				   TypeOf(pObject) = Type("DocumentObject.Бронирование") Тогда
					vHPObj.Клиент = pObject.Клиент;
					vHPObj.Продолжительность = pObject.Продолжительность;
					If vHPObj.FixProductCost Тогда
						vReferenceHour = '00010101';
						If ЗначениеЗаполнено(pObject.Тариф) Тогда
							vReferenceHour = pObject.Тариф.ReferenceHour;
						EndIf;
						vHPObj.CheckInDate = BegOfDay(pObject.CheckInDate) + (vReferenceHour - BegOfDay(vReferenceHour));
						vHPObj.ДатаВыезда = vHPObj.CheckInDate + vHPObj.Продолжительность*24*3600;
						If vReferenceHour = '00010101' Тогда
							vHPObj.ДатаВыезда = vHPObj.ДатаВыезда - 1;
						EndIf;
					Else
						vHPObj.CheckInDate = pObject.CheckInDate;
						vHPObj.ДатаВыезда = pObject.ДатаВыезда;
					EndIf;
					vHPObj.Сумма = 0;
					For Each vSrvRow In pObject.Услуги Do
						If ЗначениеЗаполнено(vSrvRow.Услуга) And vSrvRow.Услуга.IsHotelProductService Тогда
							vHPObj.Сумма = vHPObj.Сумма + vSrvRow.Сумма - vSrvRow.СуммаСкидки;
						EndIf;
					EndDo;
					// If document product is filled then copy it's parameters
					If pBaseObject <> Неопределено And ЗначениеЗаполнено(pBaseObject.ПутевкаКурсовка) And pBaseObject.ПутевкаКурсовка.Parent = vHPObj.Parent And 
					   pBaseObject.ТипНомера = pObject.ТипНомера And pBaseObject.ВидРазмещения = pObject.ВидРазмещения And pBaseObject.Продолжительность = pObject.Продолжительность Тогда
						vBaseProduct = pBaseObject.ПутевкаКурсовка;
						If vBaseProduct.FixProductPeriod Тогда
							vHPObj.FixProductPeriod = True;
							vHPObj.CheckInDate = vBaseProduct.CheckInDate;
							vHPObj.ДатаВыезда = vBaseProduct.ДатаВыезда;
						EndIf;
						If vBaseProduct.FixPlannedPeriod Тогда
							vHPObj.FixPlannedPeriod = True;
							vHPObj.CheckInDate = vBaseProduct.CheckInDate;
							vHPObj.ДатаВыезда = vBaseProduct.ДатаВыезда;
						EndIf;
						If vBaseProduct.FixProductCost Тогда
							vHPObj.FixProductCost = True;
							vHPObj.CheckInDate = vBaseProduct.CheckInDate;
							vHPObj.ДатаВыезда = vBaseProduct.ДатаВыезда;
							vHPObj.Сумма = vBaseProduct.Сумма;
							vHPObj.Валюта = vBaseProduct.Валюта;
						EndIf;
					EndIf;
				ElsIf TypeOf(pObject) = Type("DocumentObject.СчетПроживания") Тогда
					vHPObj.Клиент = pObject.Клиент;
				ElsIf TypeOf(pObject) = Type("DocumentObject.Начисление") And ЗначениеЗаполнено(pObject.СчетПроживания) Тогда
					vHPObj.Клиент = pObject.СчетПроживания.Клиент;
				EndIf;
				vHPObj.Write();
				pValue = vHPObj.Ref;
				vIsChanged = True;
			EndIf;
		Except
		EndTry;
	EndIf;
	If vIsChanged And ЗначениеЗаполнено(pValue) Тогда
		If ЗначениеЗаполнено(pValue.Parent) Тогда
			If pValue.Parent.OpenNewProductForm Тогда
				vFrm = pValue.ПолучитьФорму(, pControl);
				vFrm.Open();
			EndIf;
		EndIf;
	EndIf;
	Return vIsChanged;
EndFunction //cmHotelProductTextEditEnd
