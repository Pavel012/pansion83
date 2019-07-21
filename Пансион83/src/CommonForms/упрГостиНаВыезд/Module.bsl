//-----------------------------------------------------------
&НаКлиенте
Процедура OnOpen(pCancel)
	vFrequency = GetFrequencyFromCurrentWorkstation();
	vFrequency = ?(vFrequency = 0, 300, vFrequency*60);
	ЭтаФорма.AttachIdleHandler("RefreshDocsList", vFrequency);
КонецПроцедуры //OnOpen

//-----------------------------------------------------------
&AtServer
Function GetFrequencyFromCurrentWorkstation()
	Return ПараметрыСеанса.РабочееМесто.InHouseGuestsPeriodOfStayAutoExtensionFrequency;
EndFunction //GetFrequencyFromCurrentWorkstation()

//-----------------------------------------------------------
&НаКлиенте
Процедура ProlongForHour(pCommand)
	vCurrData = Items.Docs.CurrentData;
	If vCurrData <> Неопределено Тогда
		vFrm = vCurrData.Ref.ПолучитьФорму();
		vFrm.Open();
		vCheckOutDate = vFrm.ДатаВыезда+3600;
		vFrm.ДатаВыезда = vCheckOutDate;
		vFrm.CheckOutTime = ExtractTime(vCheckOutDate);
		vFrm.CheckOutDateOnChange(vFrm.ЭлементыФормы.ДатаВыезда);
	EndIf;
КонецПроцедуры //ProlongForHour

//-----------------------------------------------------------
&AtServer
Function ExtractTime(pDate)
	Return cmExtractTime(pDate);
EndFunction //ExtractTime
//-----------------------------------------------------------
&НаКлиенте
Процедура ProlongFor2Hour(pCommand)
	vCurrData = Items.Docs.CurrentData;
	If vCurrData <> Неопределено Тогда
		vFrm = vCurrData.Ref.ПолучитьФорму();
		vFrm.Open();
		vCheckOutDate = vFrm.ДатаВыезда+7200;
		vFrm.ДатаВыезда = vCheckOutDate;
		vFrm.CheckOutTime = ExtractTime(vCheckOutDate);
		vFrm.CheckOutDateOnChange(vFrm.ЭлементыФормы.ДатаВыезда);
	EndIf;
КонецПроцедуры //ProlongFor2Hour

//-----------------------------------------------------------
&НаКлиенте
Процедура Refresh(pCommand)
	RefreshDocsList();
КонецПроцедуры //Refresh

//-----------------------------------------------------------
&НаКлиенте
Процедура RefreshDocsList()
	RefreshDocsListAtServer();
КонецПроцедуры //RefreshDocsList

//-----------------------------------------------------------
&AtServer
Процедура RefreshDocsListAtServer()
	If Docs.Count()>0 Тогда
		vAccRef = Docs.Get(0).Ref;
		// Build list of accommodations to checking out
		vQry = New Query();
		vQry.Text = 
		"SELECT
		|	Размещение.Ref AS Ref,
		|	Размещение.НомерРазмещения AS НомерРазмещения,
		|	Размещение.Клиент.FullName AS Клиент,
		|	Размещение.CheckInDate AS CheckInDate,
		|	Размещение.ДатаВыезда AS ДатаВыезда
		|FROM
		|	Document.Размещение AS Размещение
		|WHERE
		|	(&qHotelIsEmpty
		|			OR Размещение.Гостиница = &qHotel)
		|	AND Размещение.Posted
		|	AND Размещение.СтатусРазмещения.IsActive
		|	AND Размещение.СтатусРазмещения.ЭтоГости
		|	AND (Размещение.ВидРазмещения.ТипРазмещения = &qRoom
		|			OR Размещение.ВидРазмещения.ТипРазмещения = &qBeds)
		|	AND Размещение.ДатаВыезда < &qCheckOutDate
		|
		|ORDER BY
		|	Размещение.PointInTime";
		vQry.SetParameter("qHotel", vAccRef.Гостиница);
		vQry.SetParameter("qHotelIsEmpty", НЕ ЗначениеЗаполнено(vAccRef.Гостиница));
		vQry.SetParameter("qCheckOutDate", CurrentDate()+900);
		vQry.SetParameter("qRoom", Перечисления.ВидыРазмещений.НомерРазмещения);
		vQry.SetParameter("qBeds", Перечисления.ВидыРазмещений.Beds);
		vAccDocs = vQry.Execute().Choose();
		Docs.Clear();
		While vAccDocs.Next() Do
			vNewStr = Docs.Add();
			vNewStr.Ref = vAccDocs.Ref;
			vNewStr.НомерРазмещения = vAccDocs.НомерРазмещения;
			vNewStr.Клиент = vAccDocs.Клиент;
			vNewStr.CheckInDate = vAccDocs.CheckInDate;
			vNewStr.ДатаВыезда = vAccDocs.ДатаВыезда;
			If vAccDocs.ДатаВыезда < CurrentDate() Тогда
				vNewStr.Icon = PictureLib.RedCube;
			Else
				vNewStr.Icon = PictureLib.YellowCube;
			EndIf;
		EndDo;
	EndIf;
КонецПроцедуры //RefreshDocsListAtServer

//-----------------------------------------------------------
&НаКлиенте
Процедура DocsSelection(pItem, pSelectedRow, pField, pStandardProcessing)
	If pField.Name = "Клиент" Тогда
		vCurrData = pItem.CurrentData;
		vFrm = vCurrData.Ref.ПолучитьФорму();
		vFrm.Open();
	EndIf;
КонецПроцедуры //DocsSelection

//-----------------------------------------------------------
&НаКлиенте
Процедура NotificationProcessing(pEventName, pParameter, pSource)
	If pEventName = "Document.Размещение.WriteNew" 
	   Or pEventName = "Document.Размещение.Write" Тогда
		RefreshDocsListAtServer();
	EndIf;
КонецПроцедуры //NotificationProcessing
