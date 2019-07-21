&НаКлиенте
Перем InOnActivateRowMode;

&AtServer
Процедура OnCreateAtServer(pCancel, pStandardProcessing)
	vDocument = Неопределено;
	Object.ДатаДок = CurrentDate();
	Title = NStr("en='Manual charges';ru='Ручные начисления';de='Manuelle Anrechnungen'");
	IsByDocument = False;
	If Parameters.Property("Document", vDocument) Тогда
		IsByDocument = True;
		Object.Document = vDocument;
		If TypeOf(vDocument)=Type("DocumentRef.Бронирование") Тогда
			Title = NStr("en='Charge to reservation: ';ru='Начисление по брони: ';de='Anrechnung zur Reservierung: '");
		ElsIf TypeOf(vDocument)=Type("DocumentRef.Размещение") Тогда
			Title = NStr("en='Charge to accommodation: ';ru='Начисление по размещению: ';de='Anrechnung zur Unterbringung: '");
		EndIf;
		Title = Title + TrimAll(vDocument.НомерДока)+", "+TrimAll(vDocument.ГруппаГостей)+", "+NStr("en='from ';ru='с ';de='ab '")+Format(vDocument.CheckInDate, "DF='dd.MM.yyyy HH:mm'")+NStr("en=' to ';ru=' по ';de=' bis '")+Format(vDocument.CheckOutDate, "DF='dd.MM.yyyy HH:mm'");
	EndIf;
	If ЗначениеЗаполнено(Object.Document) Тогда
		If TypeOf(Object.Document) = Type("DocumentRef.Бронирование") Тогда
			Object.ДатаДок = Object.Document.CheckInDate;
		ElsIf TypeOf(Object.Document) = Type("DocumentRef.Размещение") Тогда
			Object.ДатаДок = CurrentDate();
		EndIf;
		Object.ГруппаГостей = Object.Document.ГруппаГостей;
		Object.Клиент = Object.Document.Клиент;
		Object.НомерРазмещения = Object.Document.НомерРазмещения;
		Object.ТипКлиента = Object.Document.ТипКлиента;
		Object.МаркетингКод = Object.Document.МаркетингКод;
		Object.ИсточникИнфоГостиница = Object.Document.ИсточникИнфоГостиница;
		Object.ТипСкидки = Object.Document.ТипСкидки;
	EndIf;
КонецПроцедуры //OnCreateAtServer

&AtServer
Процедура FillHeaderDecoration()
	If Object.НачислениеУслуг.Count() = 0 Тогда
		Items.HeaderDecoration.Title = NStr("en='Add new row to the charges list...';ru='Добавьте новую строку в таблицу начислений...';de='Fügen Sie eine neue Zeile in die Anrechnungstabelle ein…'");
	Else
		vCurRowId = Items.НачислениеУслуг.CurrentRow;
		If vCurRowId <> Неопределено Тогда
			vCurRow = Object.НачислениеУслуг.FindByID(vCurRowId);
			If vCurRow <> Неопределено And ЗначениеЗаполнено(vCurRow.Услуга) Тогда
				Items.HeaderDecoration.Title = NStr("en='Use edit button or double click row to change charge parameters...';ru='Для редактирования начисления выделите строку двойным щелчком мыши или нажмите кнопку <Изменить>...';de='Für die Änderung der Anrechnung heben Sie die durch Doppelklick Zeile hervor und drücken Sie die Taste <Ändern>…'");
			Else
				Items.HeaderDecoration.Title = NStr("en='Input charge data below and press <OK> button...';ru='Заполните параметры начисления и нажмите <ОК>...';de='Anrechnungsparameter ausfüllen und <ОК> drücken...'");
			EndIf;
		Else
			Items.HeaderDecoration.Title = NStr("en='Input charge data below and press <OK> button...';ru='Заполните параметры начисления и нажмите <ОК>...';de='Anrechnungsparameter ausfüllen und <ОК> drücken...'");
		EndIf;
		If Items.ClientGroup.Visible Тогда
			If ЗначениеЗаполнено(Object.Document) Тогда
				Items.HeaderDecoration.Title = ?(ЗначениеЗаполнено(Object.Document.Клиент), String(Object.Document.Клиент), ?(ЗначениеЗаполнено(Object.Document.Контрагент), String(Object.Document.Контрагент), ""))+
				NStr("en=' from ';ru=' с ';de=' ab '")+Format(Object.Document.CheckInDate, "DF='dd.MM.yyyy HH:mm'")+
				NStr("en=' to ';ru=' по ';de=' bis '")+Format(Object.Document.CheckOutDate, "DF='dd.MM.yyyy HH:mm'");
			Else
				If ЗначениеЗаполнено(Object.Клиент) Тогда
					Items.HeaderDecoration.Title = String(Object.Клиент);
				EndIf;
			EndIf;
		EndIf;
	EndIf;
КонецПроцедуры //FillHeaderDecoration

&AtServer
Процедура ClearParameters()
	If НЕ IsByDocument Тогда
		Object.ДатаДок = CurrentDate();
		Object.Услуга = Неопределено;
		Object.ServicePackage = Неопределено;
		ServiceOnChangeAtServer();
		Object.ГруппаГостей = Неопределено;
		Object.НомерРазмещения = Неопределено;
		Object.Клиент = Неопределено;
		Object.Document = Неопределено;
		ClientsList.Clear();
		RoomsList.Clear();
		ClientsTable.Clear();
	EndIf;
КонецПроцедуры //ClearParameters

&НаКлиенте
Процедура FillParametersByRow(pCurData = Неопределено)
	If pCurData <> Неопределено Тогда
		Object.Document = pCurData.Document;
		If ЗначениеЗаполнено(pCurData.Document) Тогда
			Object.ГруппаГостей = УпрСерверныеФункции.cmGetAttributeByRef(pCurData.Document, "ГруппаГостей");
		EndIf;
		Object.НомерРазмещения = pCurData.НомерРазмещения;
		Object.Клиент = pCurData.Клиент;
		GetDocumentsInGG(?(ЗначениеЗаполнено(Object.Клиент), True, False), ?(ЗначениеЗаполнено(Object.НомерРазмещения), True, False));
		RoomOnChangeAtServer();
		Object.Цена = pCurData.Цена;
		Object.Количество = pCurData.Количество;
		Object.Услуга = pCurData.Услуга;
		Items.ServiceGroup.Visible = True;
		Items.ServicePackGroup.Visible = False;
		ServiceOnChangeAtServer();
		Object.Сумма = pCurData.Сумма;
	EndIf;
	FillHeaderDecoration();
КонецПроцедуры //FillParametersByRow

&НаКлиенте
Процедура Charge(pCommand)
	vCancel = False;
	If Items.SelectedChargeParametersGroup.Enabled Тогда
		//vAnswer = Неопределено;

		ShowQueryBox(Новый ОписаниеОповещения("ChargeЗавершение", ЭтотОбъект, Новый Структура("Items", Items)), NStr("en='Save current changes?';ru='Сохранить текущие изменения?';de='Aktuelle Veränderungen speichern?'"), QuestionDialogMode.YesNoCancel);
        Возврат;
	EndIf;
	ChargeФрагмент(vCancel);
КонецПроцедуры

&НаКлиенте
Процедура ChargeЗавершение(QuestionResult, ДополнительныеПараметры) Экспорт
	
	Items = ДополнительныеПараметры.Items;
	
	
	vAnswer = QuestionResult; 
	If vAnswer = DialogReturnCode.Cancel Тогда
		vCancel = True;
	ElsIf vAnswer = DialogReturnCode.Yes Тогда
		Items.DoClientList.Enabled = False;
		Items.DoServicePackage.Enabled = False;
		OK(Неопределено);
	Else
		Cancel(Неопределено);
	EndIf;
	
	ChargeФрагмент(vCancel);

КонецПроцедуры

&НаКлиенте
Процедура ChargeФрагмент(Знач vCancel)
	
	Перем  vChargeItem, vChargeRef, vChargeRowsToDeleteList, vFrm, vIsEmpty, vRow;
	
	If НЕ vCancel Тогда
		vIsEmpty = False;
		If Object.НачислениеУслуг.Count() > 0 Тогда
			vChargeRowsToDeleteList = New СписокЗначений;
			For Each vRow In Object.НачислениеУслуг Do
				If ЗначениеЗаполнено(vRow.Document) Тогда
					Try
						vChargeRef = ChargeAtServer(vRow.Document, vRow.Услуга, vRow.ДатаДок, vRow.НомерРазмещения, vRow.Количество, vRow.Цена, vRow.Сумма);
						If vChargeRef = Неопределено Тогда
							ВызватьИсключение "";
						EndIf;
						ChangeChargeRowAttribute(vRow.GetID(), "СчетПроживания", УпрСерверныеФункции.cmGetAttributeByRef(vChargeRef, "СчетПроживания"));
						//vRow.ЛицевойСчет = tcOnServer.cmGetAttributeByRef(vChargeRef, "ЛицевойСчет");
						vChargeRowsToDeleteList.Add(vRow.GetID());
						// Оповестить changes in the accounts subsystem
						Оповестить("Subsystem.Взаиморасчеты.Changed", УпрСерверныеФункции.cmGetAttributeByRef(vChargeRef, "СчетПроживания"), vChargeRef);
						Оповестить("Document.Начисление.Write", vChargeRef, ЭтаФорма);
					Except
						ChangeChargeRowAttribute(vRow.GetID(), "Error", True);
						//vRow.Error = True;
					EndTry;
				Else
					Object.НачислениеУслуг.Delete(vRow);
				EndIf;
			EndDo;
			vFrm = ПолучитьФорму("DataProcessor.НачислениеУслуг.Form.NotificationForm",, ЭтаФорма);
			CopyFormData(Object, vFrm.Object);
			vChargeRowsToDeleteList.SortByValue(SortDirection.Desc);
			For Each vChargeItem In vChargeRowsToDeleteList Do
				Object.НачислениеУслуг.Delete(vChargeItem.Value);
			EndDo;
			vFrm.DoModal();
		Else
			If Object.НачислениеУслуг.Count() = 1 Тогда
				If НЕ ЗначениеЗаполнено(Object.НачислениеУслуг.Get(0).Document) Тогда
					vIsEmpty = True;
				EndIf;
			Else
				vIsEmpty = True;
			EndIf;
			If vIsEmpty Тогда
				ShowMessageBox(Неопределено, NStr("en='Charges table is empty!';ru='Пустая таблица начислений!';de='Leere Berechnungstabelle!'"));
			EndIf;
		EndIf;
	EndIf;

КонецПроцедуры

&AtServer
Процедура ChangeChargeRowAttribute(pRowID, pAttribute, pParam)
	vChargesObj = FormAttributeToValue("Object");
	vChargeRow = vChargesObj.НачислениеУслуг.Get(pRowID);
	vChargeRow[pAttribute] = pParam;
	ValueToFormAttribute(vChargesObj, "Object");
КонецПроцедуры //ChangeChargeRowAttribute

&AtServer
Function ChargeAtServer(pDocument, pService, pDate, pRoom, pQuantity, pPrice, pSum)
	vFolio = Неопределено;
	For Each vCRRow In pDocument.ChargingRules Do
		// Check if current service fit to the current charging rule
		If cmIsServiceFitToTheChargingRule(vCRRow, pService, BegOfDay(pDate), False, pService.IsRoomRevenue) Тогда
			vFolio = vCRRow.ChargingFolio;
			Break;
		EndIf;
	EndDo;
	If НЕ ЗначениеЗаполнено(vFolio) Тогда
		Return Неопределено;
	EndIf;
	vChargeObj = Documents.Начисление.CreateDocument();
	//vChargeObj.pmFillAttributesWithDefaultValues();
	vChargeObj.Fill(vFolio);
	vChargeObj.ДатаДок = pDate;
	vChargeObj.НомерРазмещения = pRoom;
	vChargeObj.ТипКлиента = Object.ТипКлиента;
	vChargeObj.Услуга = pService;
	vChargeObj.Количество = pQuantity;
	vChargeObj.Цена = pPrice;
	vChargeObj.IsAdditional = True;
	vChargeObj.Сумма = pSum;
	vChargeObj.Write(DocumentWriteMode.Posting);
	Return vChargeObj.Ref;
EndFunction //ChargeAtServer

&НаКлиенте
Процедура RoomOnChange(pItem)
	RoomOnChangeAtServer();
КонецПроцедуры //RoomOnChange

&AtServer
Процедура RoomOnChangeAtServer()
	If ЗначениеЗаполнено(Object.Document) AND
		Object.НомерРазмещения <> УпрСерверныеФункции.cmGetAttributeByRef(Object.Document, "НомерРазмещения") Тогда
		Object.Document = Неопределено;
	EndIf;
	GetClientsList();
	CheckDocumentFilling();
КонецПроцедуры //RoomOnChangeAtServer

&НаКлиенте
Процедура ClientOnChange(pItem)
	ClientOnChangeAtServer();
КонецПроцедуры //ClientOnChange

&AtServer
Процедура ClientOnChangeAtServer()
	If ЗначениеЗаполнено(Object.Document) AND
		Object.Клиент <> УпрСерверныеФункции.cmGetAttributeByRef(Object.Document, "Клиент") Тогда
		Object.Document = Неопределено;
	EndIf;
	GetResultDocument();
	CheckDocumentFilling();
КонецПроцедуры //ClientOnChangeAtServer

&AtServer
Процедура GetResultDocument()
	vDocumentsTable = FormAttributeToValue("DocumentsTable");
	If ЗначениеЗаполнено(Object.НомерРазмещения) Тогда
		If ЗначениеЗаполнено(Object.Клиент) Тогда
			vDocumentsTable.GroupBy("Document, НомерРазмещения, Клиент");
			vFindedDocuments = vDocumentsTable.FindRows(New Structure("НомерРазмещения, Клиент", Object.НомерРазмещения, Object.Клиент));
			If vFindedDocuments.Count() > 0 Тогда
				Object.Document = vFindedDocuments.Get(0).Document;
				Object.ГруппаГостей = Object.Document.ГруппаГостей;
				GetDocumentsInGG(True, True);
			Else
				Object.Document = Неопределено;
			EndIf;
		Else
			vDocumentsTable.GroupBy("Document, НомерРазмещения");
			vFindedDocuments = vDocumentsTable.FindRows(New Structure("НомерРазмещения", Object.НомерРазмещения));
			If vFindedDocuments.Count() = 1 Тогда
				Object.Document = vFindedDocuments.Get(0).Document;
				Object.Клиент = Object.Document.Клиент;
				Object.ГруппаГостей = Object.Document.ГруппаГостей;
				GetDocumentsInGG(True, True);
			Else
				Object.Document = Неопределено;
			EndIf;
		EndIf;
	Else
		If ЗначениеЗаполнено(Object.Клиент) Тогда
			vDocumentsTable.GroupBy("Document, Клиент");
			vClientDocumentRow = vDocumentsTable.Find(Object.Клиент, "Клиент");
			If vClientDocumentRow <> Неопределено Тогда
				Object.Document = vClientDocumentRow.Document;
				Object.НомерРазмещения = Object.Document.НомерРазмещения;
				Object.ГруппаГостей = Object.Document.ГруппаГостей;
				GetDocumentsInGG(True, True);
				GetClientsList();
			Else
				Object.Document = Неопределено;
			EndIf;
		Else
			vDocumentsTable.GroupBy("Document");
			If vDocumentsTable.Count() = 1 Тогда
				Object.Document = vDocumentsTable.Get(0).Document;
				Object.НомерРазмещения = Object.Document.НомерРазмещения;
				Object.ГруппаГостей = Object.Document.ГруппаГостей;
				GetDocumentsInGG(, True);
				GetClientsList();
			Else
				Object.Document = Неопределено;
			EndIf;
		EndIf;
	EndIf;
КонецПроцедуры //GetResultDocument

&НаКлиенте
Процедура SumOnChange(pItem)
	SumOnChangeAtServer();
КонецПроцедуры //SumOnChange

&AtServer
Процедура SumOnChangeAtServer()
	If ЗначениеЗаполнено(Object.Услуга) And Object.Услуга.RecalculatePriceWhenSumChanged Тогда
		If ЗначениеЗаполнено(Object.Количество) Тогда
			Object.Цена = Object.Сумма/Object.Количество;
		EndIf;
	Else
		If ЗначениеЗаполнено(Object.Цена) Тогда
			Object.Количество = Object.Сумма/Object.Цена;
		EndIf;
	EndIf;
КонецПроцедуры //SumOnChangeAtServer

&НаКлиенте
Процедура PriceOnChange(pItem)
	PriceOnChangeAtServer();
КонецПроцедуры //PriceOnChange

&AtServer
Процедура PriceOnChangeAtServer()
	If Object.Количество <= 0 Тогда
		Object.Количество = 1;
	EndIf;
	Object.Сумма = Object.Цена*Object.Количество;
КонецПроцедуры //PriceOnChangeAtServer

&НаКлиенте
Процедура QuantityOnChange(pItem)
	If Object.Количество <= 0 Тогда
		Object.Количество = 1;
	EndIf;
	Object.Сумма = Object.Количество*Object.Цена;
КонецПроцедуры //QuantityOnChange

&НаКлиенте
Процедура ServiceOnChange(pItem)
	ServiceOnChangeAtServer();
КонецПроцедуры //ServiceOnChange

&AtServer
Процедура ServiceOnChangeAtServer()
	If ЗначениеЗаполнено(Object.Услуга) Тогда
		Items.Цена.Enabled = True;
		Items.Количество.Enabled = True;
		Items.Сумма.Enabled = True;
	Else
		Items.Цена.Enabled = False;
		Items.Количество.Enabled = False;
		Items.Сумма.Enabled = False;
		Object.Цена = 0;
		Object.Количество = 0;
		Object.Сумма = 0;
	EndIf;
	vPriceStruc = GetServicePrice(Object.Услуга, Object.ДатаДок);
	If vPriceStruc <> Неопределено Тогда
		Object.Цена = vPriceStruc.Цена;
		PriceOnChangeAtServer();
	EndIf;
	// Check if user can edit service price
	Items.Цена.ReadOnly = False;
	If НЕ Object.Услуга.AllowChangePrice Тогда
		If НЕ cmCheckUserPermissions("HavePermissionToEditServicePrices") Тогда
			Items.Цена.ReadOnly = True;
		EndIf;
	EndIf;
КонецПроцедуры //ServiceOnChangeAtServer

&AtServer
Function GetServicePrice(pService, pDate = Неопределено)
	vList = New СписокЗначений;
	vList.Add(pService);
	vDate = pDate;
	If pDate = Неопределено then
		vDate = CurrentDate();
	EndIf;
	vPrices = cmGetServicePrices(vList, ПараметрыСеанса.ТекущаяГостиница, vDate, Object.ТипКлиента);
	If vPrices.Count() > 0 Тогда
		vPriceStruc = New Structure;
		vPriceStruc.Вставить("Цена", vPrices[0].Цена);
		vPriceStruc.Вставить("Валюта", vPrices[0].Валюта);
		Return vPriceStruc;
	EndIf;
	Return Неопределено;
EndFunction //GetServicePrice

&НаКлиенте
Процедура GuestGroupOnChange(pItem)
	GuestGroupOnChangeAtServer();
КонецПроцедуры //GuestGroupOnChange

&AtServer
Процедура GuestGroupOnChangeAtServer()
	Object.Document = Неопределено;
	Object.НомерРазмещения = Неопределено;
	Object.Клиент = Неопределено;
	If ЗначениеЗаполнено(Object.ГруппаГостей) Тогда
		Items.НомерРазмещения.Enabled = True;
		Items.ClientGroup.Enabled = True;
		Items.ClientStringGroup.Enabled = True;
		Items.ClientsTable.Enabled = True;
		GetDocumentsInGG();
	Else
		ClientsTable.Clear();
		If IsByDocument Тогда
			Items.НомерРазмещения.Enabled = False;
			Items.ClientGroup.Enabled = False;
			Items.ClientStringGroup.Enabled = False;
			Items.ClientsTable.Enabled = False;
		Else
			Items.НомерРазмещения.Enabled = True;
			Items.ClientGroup.Enabled = True;
			Items.ClientStringGroup.Enabled = True;
			Items.ClientsTable.Enabled = True;
			GetDocumentsInGG();
		EndIf;
	EndIf;
	CheckDocumentFilling();
КонецПроцедуры //GuestGroupOnChangeAtServer

&AtServer
Процедура CheckDocumentFilling()
	If Items.ClientGroup.Visible Тогда
		If ЗначениеЗаполнено(Object.Document) Тогда
			Items.OK.Enabled = True;
		Else
			Items.OK.Enabled = False;
		EndIf;
	Else
		Items.OK.Enabled = False;
		For Each vRow In ClientsTable Do
			If vRow.Check Тогда
				Items.OK.Enabled = True;
				Break;
			EndIf;
		EndDo;
	EndIf;
	FillHeaderDecoration();
КонецПроцедуры //CheckDocumentFilling

&AtServer
Процедура GetDocumentsInGG(pClientIsSelected = False, pRoomIsSelected = False)
	ClientsTable.Clear();
	vQry = New Query;
	vQry.Text =
	"SELECT
	|	Размещение.Ref AS Document,
	|	Размещение.НомерРазмещения,
	|	Размещение.Клиент,
	|	Размещение.ДатаДок AS Date
	|FROM
	|	Document.Размещение AS Размещение
	|WHERE
	|	NOT Размещение.DeletionMark
	|	AND Размещение.Posted
	|	AND (Размещение.ГруппаГостей = &qGuestGroup Or &qIsGGEmpty)
	|	AND Размещение.Гостиница = &qHotel
	//|	"+?(pClientIsSelected," AND Accommodation.Guest = &qGuest ", "")+?(pRoomIsSelected," AND Accommodation.ГруппаНомеров = &qRoom ", "")+
	|	AND (Размещение.СтатусРазмещения.IsActive AND "+?(IsByDocument, "Размещение.СтатусРазмещения.ЭтоВыезд)", "Размещение.СтатусРазмещения.ЭтоГости)")+
	" UNION ALL
	|
	|SELECT
	|	Reservation.Ref,
	|	Reservation.НомерРазмещения,
	|	Reservation.Клиент,
	|	Reservation.ДатаДок
	|FROM
	|	Document.Reservation AS Reservation
	|WHERE
	|	NOT Reservation.DeletionMark
	|	AND Reservation.Posted
	|	AND Reservation.Гостиница = &qHotel
	//|	"+?(pClientIsSelected," AND Reservation.Guest = &qGuest", "")+?(pRoomIsSelected," AND Reservation.ГруппаНомеров = &qRoom ", "")+
	|	AND (Reservation.ГруппаГостей = &qGuestGroup Or &qIsGGEmpty)
	|	AND (Reservation.ReservationStatus.IsActive
	|	"+?(IsByDocument," OR Reservation.ReservationStatus.IsPreliminary)", " AND NOT Reservation.ReservationStatus.ЭтоЗаезд)")+
	" ORDER BY
	|	Date DESC";
	vQry.SetParameter("qHotel", ПараметрыСеанса.ТекущаяГостиница);
	vQry.SetParameter("qGuestGroup", Object.ГруппаГостей);
	//If pClientIsSelected Тогда
	//	vQry.SetParameter("qGuest", Object.Client);
	//EndIf;
	//If pRoomIsSelected Тогда
	//	vQry.SetParameter("qRoom", Object.ГруппаНомеров);
	//EndIf;
	vQry.SetParameter("qIsGGEmpty", ?(ЗначениеЗаполнено(Object.ГруппаГостей), False, True));
	vQryResult = vQry.Execute().Unload();
	ValueToFormAttribute(vQryResult, "DocumentsTable");
	
	//Check documents
	vDocsResultTable = vQryResult.Copy();
	vDocsResultTable.GroupBy("Document");
	If vDocsResultTable.Count() = 1 Тогда
		Object.Document = vDocsResultTable.Get(0).Document;
		Object.НомерРазмещения = Object.Document.НомерРазмещения;
		Object.Клиент = Object.Document.Клиент;
	EndIf;
	
	//Fill rooms list (selection in ГруппаНомеров field)
	vRoomsResultTable = vQryResult.Copy();
	vRoomsResultTable.GroupBy("НомерРазмещения");
	RoomsList.LoadValues(vRoomsResultTable.UnloadColumn("НомерРазмещения"));
	RoomsList.SortByValue();
	//delete empty rooms
	vDeleteItemsArray = New Array;
	For each vItem In RoomsList Do
		If НЕ ЗначениеЗаполнено(vItem.Value) Тогда
			vDeleteItemsArray.Add(vItem);
		EndIf;
	EndDo;
	For Each vDelItem In vDeleteItemsArray Do
		RoomsList.Delete(vDelItem);
	EndDo;
	
	//Fill clients list (selection in client field)
	vQryResult.GroupBy("Клиент");
	ClientsList.LoadValues(vQryResult.UnloadColumn("Клиент"));
	ClientsList.SortByValue();
	//delete empty rooms
	vDeleteItemsArray = New Array;
	For each vItem In ClientsList Do
		If НЕ ЗначениеЗаполнено(vItem.Value) Тогда
			vDeleteItemsArray.Add(vItem);
		EndIf;
	EndDo;
	For Each vDelItem In vDeleteItemsArray Do
		ClientsList.Delete(vDelItem);
	EndDo;
	
	//Fill clients table
	vClientsTable = FormAttributeToValue("ClientsTable");
	For Each vItem In ClientsList Do
		vDocuments = DocumentsTable.FindRows(New Structure("Клиент", vItem.Value));
		If vDocuments.Count() > 0 Тогда
			vDocumentRow = vDocuments.Get(0);
			vNewRow = vClientsTable.Add();
			vNewRow.Check = False;
			vNewRow.Клиент = vItem.Value;
			vNewRow.Document = vDocumentRow.Document;
			vNewRow.Description = ?(ЗначениеЗаполнено(vDocumentRow.НомерРазмещения), TrimAll(vDocumentRow.НомерРазмещения)+" ,", "")+TrimAll(vItem.Value);
		EndIf;
	EndDo;
	ValueToFormAttribute(vClientsTable, "ClientsTable");
КонецПроцедуры //FindDocumentsInGG

&AtServer
Процедура GetClientsList()
	ClientsList.Clear();
	ClientsTable.Clear();
	//Object.Client = Неопределено;
	vDocumentsTable = FormAttributeToValue("DocumentsTable");
	If ЗначениеЗаполнено(Object.НомерРазмещения) Тогда
		vDocumentsTableCopy = vDocumentsTable.Copy();
		vDocumentsTableCopy.GroupBy("Document, НомерРазмещения, Клиент");
		vFindedDocuments = vDocumentsTableCopy.FindRows(New Structure("НомерРазмещения", Object.НомерРазмещения));
		If vFindedDocuments.Count() = 1 Тогда
			Object.Document = vFindedDocuments.Get(0).Document;
			Object.Клиент = Object.Document.Клиент;
			Object.ГруппаГостей = Object.Document.ГруппаГостей;
			GetDocumentsInGG(True, True);
			ClientsList.Clear();
			ClientsTable.Clear();
		EndIf;
		For Each vRowItem In vFindedDocuments Do
			ClientsList.Add(vRowItem.Клиент);
		EndDo;
		ClientsList.SortByValue();
		//delete empty rooms
		vDeleteItemsArray = New Array;
		For each vItem In ClientsList Do
			If НЕ ЗначениеЗаполнено(vItem.Value) Тогда
				vDeleteItemsArray.Add(vItem);
			EndIf;
		EndDo;
		For Each vDelItem In vDeleteItemsArray Do
			ClientsList.Delete(vDelItem);
		EndDo;
		
		//Fill clients table
		vClientsTable = FormAttributeToValue("ClientsTable");
		For Each vItem In ClientsList Do
			vDocuments = DocumentsTable.FindRows(New Structure("Клиент, НомерРазмещения", vItem.Value, Object.НомерРазмещения));
			If vDocuments.Count() > 0 Тогда
				vDocumentRow = vDocuments.Get(0);
				vNewRow = vClientsTable.Add();
			    vNewRow.Check = False;
				vNewRow.Клиент = vItem.Value;
				vNewRow.Document = vDocumentRow.Document;
				vNewRow.Description = ?(ЗначениеЗаполнено(vDocumentRow.НомерРазмещения), TrimAll(vDocumentRow.НомерРазмещения)+" ,", "")+TrimAll(vItem.Value);
			EndIf;
		EndDo;
		ValueToFormAttribute(vClientsTable, "ClientsTable");
	Else
		vDocumentsTableCopy = vDocumentsTable.Copy();
		If Items.ClientGroup.Visible Тогда
			If ЗначениеЗаполнено(Object.Клиент) Тогда
				vDocumentsTableCopy.GroupBy("Document, Клиент");
				vFindedRows = vDocumentsTableCopy.FindRows(New Structure("Клиент", Object.Клиент));
				If vFindedRows.Count() = 1 Тогда
					Object.Document = vFindedRows.Get(0).Document;
					Object.НомерРазмещения = Object.Document.НомерРазмещения;
					Object.ГруппаГостей = Object.Document.ГруппаГостей;
					GetDocumentsInGG(True, True);
				Else
					Object.Document = Неопределено;
					GetDocumentsInGG(True);
				EndIf;
			Else
				vDocumentsTableCopy.GroupBy("Document");
				If vDocumentsTableCopy.Count() = 1 Тогда
					Object.Document = vDocumentsTableCopy.Get(0).Document;
					Object.НомерРазмещения = Object.Document.НомерРазмещения;
					Object.ГруппаГостей = Object.Document.ГруппаГостей;
					GetDocumentsInGG(, True);
				Else
					Object.Document = Неопределено;
					GetDocumentsInGG();
				EndIf;
			EndIf;
		Else
			vDocumentsTableCopy.GroupBy("Document");
			If vDocumentsTableCopy.Count() = 1 Тогда
				Object.Document = vDocumentsTableCopy.Get(0).Document;
				Object.НомерРазмещения = Object.Document.НомерРазмещения;
				Object.ГруппаГостей = Object.Document.ГруппаГостей;
				GetDocumentsInGG(, True);
			Else
				Object.Document = Неопределено;
				GetDocumentsInGG();
			EndIf;
		EndIf;
	EndIf;
КонецПроцедуры //GetClientsList

&НаКлиенте
Процедура RoomStartListChoice(pItem, pStandardProcessing)
	Items.НомерРазмещения.ChoiceList.LoadValues(RoomsList.UnloadValues());
КонецПроцедуры

&НаКлиенте
Процедура DateOnChange(pItem)
	If ЗначениеЗаполнено(Object.ДатаДок) Тогда
		Items.Услуга.Enabled = True;
		Items.DoServicePackage.Enabled = True;
		Items.ГруппаГостей.Enabled = True;
	Else
		Object.Услуга = Неопределено;
		Object.НомерРазмещения = Неопределено;
		Object.Клиент = Неопределено;
		Object.ГруппаГостей = Неопределено;
		Object.Цена = 0;
		Object.Количество = 0;
		Object.Сумма = 0;
		Items.Услуга.Enabled = False;
		Items.DoServicePackage.Enabled = False;
		Items.НомерРазмещения.Enabled = False;
		Items.Клиент.Enabled = False;
		Items.DoClientList.Enabled = False;
		Items.ГруппаГостей.Enabled = False;
		Items.Цена.Enabled = False;
		Items.Количество.Enabled = False;
		Items.Сумма.Enabled = False;
	EndIf;
КонецПроцедуры

&НаКлиенте
Процедура OnOpen(pCancel)
	FillHeaderDecoration();
КонецПроцедуры

&НаКлиенте
Процедура AddChargeRow(pCommand)
	vCancel = False;
	If Items.SelectedChargeParametersGroup.Enabled Тогда
		//vAnswer = Неопределено;

		ShowQueryBox(Новый ОписаниеОповещения("AddChargeRowЗавершение", ЭтотОбъект, Новый Структура("Items", Items)), NStr("en='Save current changes?';ru='Сохранить текущие изменения?';de='Aktuelle Veränderungen speichern?'"), QuestionDialogMode.YesNoCancel);
        Возврат;
	EndIf;
	AddChargeRowФрагмент(Items, vCancel);
КонецПроцедуры

&НаКлиенте
Процедура AddChargeRowЗавершение(QuestionResult, ДополнительныеПараметры) Экспорт
	
	Items = ДополнительныеПараметры.Items;
	
	
	vAnswer = QuestionResult; 
	If vAnswer = DialogReturnCode.Cancel Тогда
		vCancel = True;
	ElsIf vAnswer = DialogReturnCode.Yes Тогда
		Items.DoClientList.Enabled = False;
		Items.DoServicePackage.Enabled = False;
		OK(Неопределено);
	Else
		Cancel(Неопределено);
	EndIf;
	
	AddChargeRowФрагмент(Items, vCancel);

КонецПроцедуры

&НаКлиенте
Процедура AddChargeRowФрагмент(Знач Items, Знач vCancel)
	
	Перем vNewRow;
	
	If НЕ vCancel Тогда
		vNewRow = Object.НачислениеУслуг.Add();
		Items.SelectedChargeParametersGroup.Enabled = True;
		vNewRow.ДатаДок = CurrentDate();
		vNewRow.IsChanging = True;
		Object.ДатаДок = CurrentDate();
		GuestGroupOnChangeAtServer();
		CurrentRowID = vNewRow.GetID();
		Items.НачислениеУслуг.CurrentRow = CurrentRowID;
	EndIf;

КонецПроцедуры

&НаКлиенте
Процедура DoClientList(pCommand)
	If Items.ClientsTable.Visible Тогда
		Items.ClientsTable.Visible = False;
		For Each vRow In ClientsTable Do
			vRow.Check = False;
		EndDo;
		Items.ClientStringGroup.Visible = False;
		Items.ClientGroup.Visible = True;
		RoomOnChangeAtServer();
	Else
		Object.Клиент = Неопределено;
		Object.Document = Неопределено;
		Items.ClientsTable.Visible = True;
		Items.ClientStringGroup.Visible = True;
		ClientString = NStr("en='Choose clients from list:';ru='Выберите гостей из списка:';de='Wählen Sie die Gäste aus der Liste:'");
		Items.ClientGroup.Visible = False;
	EndIf;
	CheckDocumentFilling();
КонецПроцедуры

&НаКлиенте
Процедура ClientStartListChoice(pItem, pStandardProcessing)
	Items.Клиент.ChoiceList.LoadValues(ClientsList.UnloadValues());
КонецПроцедуры

&НаКлиенте
Процедура DoServicePackage(Command)
	If Items.ServiceGroup.Visible Тогда
		Items.ServiceGroup.Visible = False;
		Items.ServicePackGroup.Visible = True;
		Items.Цена.Enabled = False;
		Items.Количество.Enabled = False;
		Items.Сумма.Enabled = False;
		OpenForm("Catalog.ПакетыУслуг.ФормаВыбора",, Items.ServicePackage,,,, Новый ОписаниеОповещения("DoServicePackageЗавершение", ЭтотОбъект, Новый Структура("Items", Items)), РежимОткрытияОкнаФормы.БлокироватьВесьИнтерфейс);
	Else
		Items.ServiceGroup.Visible = True;
		Items.ServicePackGroup.Visible = False;
		ServiceOnChangeAtServer();
	EndIf;
КонецПроцедуры

&НаКлиенте
Процедура DoServicePackageЗавершение(Result, ДополнительныеПараметры) Экспорт
	
	Items = ДополнительныеПараметры.Items;
	
	
	Object.ServicePackage = Result;
	If ЗначениеЗаполнено(Object.ServicePackage) Тогда
		Object.Цена = 0;
		Object.Количество = 0;
		Object.Сумма = 0;
	EndIf;			
	ServicePackageOnChange(Items.ServicePackage);

КонецПроцедуры

&НаКлиенте
Процедура ServiceStartChoice(pItem, pChoiceData, pStandardProcessing)
	pStandardProcessing = False;
	//vFrmResult = Неопределено;

	OpenForm("Catalog.Услуги.Form.tcMultipleChoiceForm", New Structure("ТипКлиента, MultipleChoice", Object.ТипКлиента, False), pItem,,,, Новый ОписаниеОповещения("ServiceStartChoiceЗавершение", ЭтотОбъект), РежимОткрытияОкнаФормы.БлокироватьВесьИнтерфейс);
КонецПроцедуры

&НаКлиенте
Процедура ServiceStartChoiceЗавершение(Result, ДополнительныеПараметры) Экспорт
	
	vFrmResult = Result; 
	If vFrmResult <> Неопределено Тогда
		If TypeOf(vFrmResult) = Type("Array") And vFrmResult.Count()>0 Тогда
			Object.Услуга = vFrmResult.Get(0).Услуга;
			ServiceOnChangeAtServer();
			Object.Цена = vFrmResult.Get(0).Цена;
			Object.Количество = vFrmResult.Get(0).Количество;
			PriceOnChangeAtServer();
		EndIf;
	EndIf;

КонецПроцедуры

&НаКлиенте
Процедура ClientsTableCheckOnChange(pItem)
	vCurData = pItem.Parent.Parent.CurrentData;
	If vCurData.Check Тогда
		Items.OK.Enabled = True;
	Else
		vIsChecked = False;
		For Each vRow In ClientsTable Do
			If vRow.Check Тогда
				vIsChecked = True;
				Items.OK.Enabled = True;
				Break;
			EndIf;
		EndDo;
		If НЕ vIsChecked Тогда
			Items.OK.Enabled = False;
		EndIf;
	EndIf;
КонецПроцедуры

&НаКлиенте
Процедура ServicePackageOnChange(pItem)
	If НЕ ЗначениеЗаполнено(Object.ServicePackage) Тогда
		Items.ServiceGroup.Visible = True;
		Items.ServicePackGroup.Visible = False;
		ServiceOnChangeAtServer();
	EndIf;
КонецПроцедуры

&НаКлиенте
Процедура GuestGroupStartChoice(pItem, pChoiceData, pStandardProcessing)
	pStandardProcessing = False;
	//vFrmResult = Неопределено;

	OpenForm("Catalog.ГруппыГостей.ФормаВыбора", New Structure("InHouse", True), pItem,,,, Новый ОписаниеОповещения("GuestGroupStartChoiceЗавершение", ЭтотОбъект), РежимОткрытияОкнаФормы.БлокироватьВесьИнтерфейс);
КонецПроцедуры

&НаКлиенте
Процедура GuestGroupStartChoiceЗавершение(Result, ДополнительныеПараметры) Экспорт
	
	vFrmResult = Result;
	If vFrmResult <> Неопределено Тогда
		Object.ГруппаГостей = vFrmResult;
		GuestGroupOnChangeAtServer();
	EndIf;

КонецПроцедуры

&НаКлиенте
Процедура ChargeChange(pCommand)
	vCancel = False;
	If Items.SelectedChargeParametersGroup.Enabled Тогда
		vAnswer = DoQueryBox(NStr("en='Save current changes?';ru='Сохранить текущие изменения?';de='Aktuelle Veränderungen speichern?'"), QuestionDialogMode.YesNoCancel); 
		If vAnswer = DialogReturnCode.Cancel Тогда
			vCancel = True;
		ElsIf vAnswer = DialogReturnCode.Yes Тогда
			Items.DoClientList.Enabled = False;
			Items.DoServicePackage.Enabled = False;
			vIsOK = False;
			If Items.ClientGroup.Visible Тогда
				If ЗначениеЗаполнено(Object.Document) Тогда
					vIsOK = True;
				Else
					vIsOK = False;
				EndIf;
			Else
				vIsOK = False;
				For Each vRow In ClientsTable Do
					If vRow.Check Тогда
						vIsOK = True;
						Break;
					EndIf;
				EndDo;
			EndIf;
			If vIsOK Тогда
				OK(Неопределено);
			Else
				vCancel = True;
				Предупреждение(NStr("en='Document is not exist';ru='Для продолжения, закончите редактирование предыдущей строки!';de='Zum Fortsetzen beenden Sie die Bearbeitung der Vorzeile!'"));
			EndIf;
		Else
			Cancel(Неопределено);
		EndIf;
	EndIf;
	If НЕ vCancel Тогда
		Items.SelectedChargeParametersGroup.Enabled = True;
		vCurData = Items.НачислениеУслуг.CurrentData;
		If vCurData <> Неопределено Тогда
			vCurData.IsChanging = True;
			FillParametersByRow(vCurData);
			CurrentRowID = vCurData.GetID();
		EndIf;
	EndIf;
КонецПроцедуры

&НаКлиенте
Процедура OK(Command)
	vError = False;
	If Items.ClientGroup.Visible And НЕ ЗначениеЗаполнено(Object.Document) Тогда
		Предупреждение(NStr("en='Document is not exist';ru='Документ не найден';de='Das Dokument wurde nicht gefunden'"));
	Else
		If Items.ServiceGroup.Visible Тогда
			If NOT ЗначениеЗаполнено(Object.Услуга) Тогда
				vMessage = New UserMessage;
				vMessage.Text = NStr("en='Fill the service';ru='Выберите услугу';de=' Wählen Sie die Dienstleistung'");
				vMessage.Field = "Object.Услуга";
				vMessage.Message();
				vError = True;
			EndIf;
		EndIf;
		If НЕ vError Тогда
			vIsOK = False;
			If Items.ClientGroup.Visible Тогда
				If ЗначениеЗаполнено(Object.Document) Тогда
					vIsOK = True;
				Else
					vIsOK = False;
				EndIf;
			Else
				vIsOK = False;
				For Each vRow In ClientsTable Do
					If vRow.Check Тогда
						vIsOK = True;
						Break;
					EndIf;
				EndDo;
			EndIf;
			If vIsOK Тогда
				vResult = OkAtServer();
				If ЗначениеЗаполнено(vResult) Тогда
					Предупреждение(vResult);
				EndIf;
			Else
				vCurRow = Object.НачислениеУслуг.FindByID(CurrentRowID);
				If vCurRow <>Неопределено Тогда
					If НЕ ЗначениеЗаполнено(vCurRow.Document) Тогда
						Object.НачислениеУслуг.Delete(vCurRow);
					EndIf;
				EndIf;
			EndIf;
		EndIf;
	EndIf;
	If НЕ vError Тогда
		ClearParameters();
		Items.DoClientList.Enabled = True;
		Items.DoServicePackage.Enabled = True;
		Items.SelectedChargeParametersGroup.Enabled = False;
		Items.FooterDecoration.Title = NStr("en='Charge ';ru='Начисление ';de='Anrechnungen '")+Object.НачислениеУслуг.Count()+NStr("en=' services ';ru=' услуг ';de=' Dienstleistungen '")+
		NStr("en='total amount: ';ru='на общую сумму: ';de='für die Gesamtsumme: '") + Format(Object.НачислениеУслуг.Total("Сумма"), "ND=17; NFD=2; NZ=");
	EndIf;
КонецПроцедуры

&AtServer
Function OkAtServer()
	vCurRow = Object.НачислениеУслуг.FindByID(CurrentRowID);
	If vCurRow <> Неопределено Тогда
		//Items.Charges.CurrentRow = CurrentRowID;				
		vIsFirstRow = True;
		If Items.ServiceGroup.Visible Тогда
			If Items.ClientsTable.Visible Тогда
				For Each vClientRow In ClientsTable Do
					If vClientRow.Check Тогда
						If vIsFirstRow Тогда
							vNewRow = vCurRow;
							vIsFirstRow = False;
						Else
							vNewRow = Object.НачислениеУслуг.Add();
						EndIf;
						vNewRow.ДатаДок = Object.ДатаДок;
						vNewRow.Клиент = vClientRow.Клиент;
						If ЗначениеЗаполнено(Object.НомерРазмещения) Тогда
							vNewRow.НомерРазмещения = Object.НомерРазмещения;
						Else
							vNewRow.НомерРазмещения = vClientRow.Document.НомерРазмещения;
						EndIf;
						vNewRow.Услуга = Object.Услуга;
						vNewRow.Цена = Object.Цена;
						vNewRow.Сумма = Object.Сумма;
						vNewRow.Количество = Object.Количество;
						vNewRow.Document = vClientRow.Document;
					Endif;
				EndDo;
			Else
				vNewRow = vCurRow;;
				vNewRow.ДатаДок = Object.ДатаДок;
				If ЗначениеЗаполнено(Object.Клиент) Тогда
					vNewRow.Клиент = Object.Клиент;
				Else
					vNewRow.Клиент = Object.Document.Клиент;
				EndIf;
				If ЗначениеЗаполнено(Object.НомерРазмещения) Тогда
					vNewRow.НомерРазмещения = Object.НомерРазмещения;
				Else
					vNewRow.НомерРазмещения = Object.Document.НомерРазмещения;
				EndIf;
				vNewRow.Услуга = Object.Услуга;
				vNewRow.Цена = Object.Цена;
				vNewRow.Сумма = Object.Сумма;
				vNewRow.Количество = Object.Количество;
				vNewRow.Document = Object.Document;
			EndIf;
		Else
			If Items.ClientsTable.Visible Тогда
				For Each vClientRow In ClientsTable Do
					If vClientRow.Check Тогда
						vServicePackageObj = Object.ServicePackage.GetObject();
						vPackageServices = vServicePackageObj.pmGetServices(Object.ДатаДок);
						For Each vServiceRow In vPackageServices Do
							If vServiceRow.ТипКлиента = Object.ТипКлиента Тогда
								If vIsFirstRow Тогда
									vNewRow = vCurRow;
									vIsFirstRow = False;
								Else
									vNewRow = Object.НачислениеУслуг.Add();
								EndIf;
								vNewRow.ДатаДок = Object.ДатаДок;
								vNewRow.Клиент = vClientRow.Клиент;
								If ЗначениеЗаполнено(Object.НомерРазмещения) Тогда
									vNewRow.НомерРазмещения = Object.НомерРазмещения;
								Else
									vNewRow.НомерРазмещения = vClientRow.Document.НомерРазмещения;
								EndIf;
								vNewRow.Услуга = vServiceRow.Услуга;
								vNewRow.Цена = vServiceRow.Цена;
								vNewRow.Сумма = vServiceRow.Цена*?(vServiceRow.Количество=0,1,vServiceRow.Количество);
								vNewRow.Количество = vServiceRow.Количество;
								vNewRow.Document = vClientRow.Document;
							EndIf;
						EndDo;
					Endif;
				EndDo;
			Else
				vServicePackageObj = Object.ServicePackage.GetObject();
				vPackageServices = vServicePackageObj.pmGetServices(Object.ДатаДок);
				For Each vServiceRow In vPackageServices Do
					If vServiceRow.ТипКлиента = Object.ТипКлиента Тогда
						If vIsFirstRow Тогда
							vNewRow = vCurRow;
							vIsFirstRow = False;
						Else
							vNewRow = Object.НачислениеУслуг.Add();
						EndIf;
						vNewRow.ДатаДок = Object.ДатаДок;
						If ЗначениеЗаполнено(Object.Клиент) Тогда
							vNewRow.Клиент = Object.Клиент;
						Else
							vNewRow.Клиент = Object.Document.Клиент;
						EndIf;
						If ЗначениеЗаполнено(Object.НомерРазмещения) Тогда
							vNewRow.НомерРазмещения = Object.НомерРазмещения;
						Else
							vNewRow.НомерРазмещения =  Object.Document.НомерРазмещения;
						EndIf;
						vNewRow.Услуга = vServiceRow.Услуга;
						vNewRow.Цена = vServiceRow.Цена;
						vNewRow.Сумма = vServiceRow.Цена*?(vServiceRow.Количество=0,1,vServiceRow.Количество);
						vNewRow.Количество = vServiceRow.Количество;
						vNewRow.Document = Object.Document;
					EndIf;
				EndDo;
			EndIf;
		EndIf;	
		vCurRow.IsChanging = False;
	Else
		Return NStr("en='The row was deleted!';ru='Строка удалена!';de='Zeile gelöscht!'");
	EndIf;
	Return "";
EndFunction

&НаКлиенте
Процедура Cancel(Command)
	vCurRow = Object.НачислениеУслуг.FindByID(CurrentRowID);
	If vCurRow <> Неопределено Тогда
		vCurRow.IsChanging = False;
		If НЕ ЗначениеЗаполнено(vCurRow.Document) Тогда
			Object.НачислениеУслуг.Delete(vCurRow);
		EndIf;
	EndIf;
	ClearParameters();
	Items.DoClientList.Enabled = True;
	Items.DoServicePackage.Enabled = True;
	Items.SelectedChargeParametersGroup.Enabled = False;
КонецПроцедуры

&НаКлиенте
Процедура ChargesBeforeDeleteRow(pItem, pCancel)
	vCurData = pItem.CurrentData;
	pCancel = True;
	If vCurData <> Неопределено Тогда
		vCancel = False;
		If vCurData.IsChanging Тогда
			Cancel(Неопределено);
		Else
			If Items.SelectedChargeParametersGroup.Enabled Тогда
				vAnswer = DoQueryBox(NStr("en='Save current changes?';ru='Сохранить текущие изменения?';de='Aktuelle Veränderungen speichern?'"), QuestionDialogMode.YesNoCancel); 
				If vAnswer = DialogReturnCode.Cancel Тогда
					vCancel = True;
				ElsIf vAnswer = DialogReturnCode.Yes Тогда
					Items.DoClientList.Enabled = False;
					Items.DoServicePackage.Enabled = False;
					OK(Неопределено);
				Else
					Cancel(Неопределено);
				EndIf;
			EndIf;
		EndIf;
		If НЕ vCancel Тогда
			pCancel = False;
		EndIf;
	EndIf;
КонецПроцедуры

&НаКлиенте
Процедура ChargesOnActivateRow(pItem)
	If InOnActivateRowMode Тогда
		Return;
	EndIf;
	InOnActivateRowMode = True;
	vCurData = pItem.CurrentData;
	If vCurData <> Неопределено And НЕ vCurData.IsChanging Тогда
		Items.ChargesChargeChange.Enabled = True;
		Items.ChargesChargeCopy.Enabled = True;
	Else
		Items.ChargesChargeChange.Enabled = False;
		Items.ChargesChargeCopy.Enabled = False;
	EndIf;
	If Object.НачислениеУслуг.Count() > 0 Тогда
		FillHeaderDecoration();
	EndIf;
	InOnActivateRowMode = False;
КонецПроцедуры

&НаКлиенте
Процедура CheckAllClients(pCommand)
	For Each vClientRow In ClientsTable Do
		vClientRow.Check = True;
		Items.OK.Enabled = True;
	EndDo;
КонецПроцедуры

&НаКлиенте
Процедура UncheckAllClients(pCommand)
	For Each vClientRow In ClientsTable Do
		vClientRow.Check = False;
		Items.OK.Enabled = False;
	EndDo;
КонецПроцедуры

&НаКлиенте
Процедура ChargesSelection(pItem, pSelectedRow, pField, pStandardProcessing)
	ChargeChange(Items.ChargesChargeChange);
	FillHeaderDecoration();
КонецПроцедуры

&НаКлиенте
Процедура ChargesAfterDeleteRow(Item)
	FillHeaderDecoration();
	If Object.НачислениеУслуг.Count() = 0 Тогда
		Items.FooterDecoration.Title = "";
	Else
		Items.FooterDecoration.Title = NStr("en='Charge ';ru='Начисление ';de='Anrechnungen '")+Object.НачислениеУслуг.Count()+NStr("en=' services ';ru=' услуг ';de=' Dienstleistungen '")+
		NStr("en='total amount: ';ru='на общую сумму: ';de='für die Gesamtsumme: '") + Format(Object.НачислениеУслуг.Total("Сумма"), "ND=17; NFD=2; NZ=");
	EndIf;
КонецПроцедуры

&НаКлиенте
Процедура ChargeCopy(pCommand)
	vCancel = False;
	If Items.SelectedChargeParametersGroup.Enabled Тогда
		//vAnswer = Неопределено;

		ShowQueryBox(Новый ОписаниеОповещения("ChargeCopyЗавершение", ЭтотОбъект, Новый Структура("Items", Items)), NStr("en='Save current changes?';ru='Сохранить текущие изменения?';de='Aktuelle Veränderungen speichern?'"), QuestionDialogMode.YesNoCancel);
        Возврат;
	EndIf;
	ChargeCopyФрагмент(Items, vCancel);
КонецПроцедуры

&НаКлиенте
Процедура ChargeCopyЗавершение(QuestionResult, ДополнительныеПараметры) Экспорт
	
	Items = ДополнительныеПараметры.Items;
	
	
	vAnswer = QuestionResult; 
	If vAnswer = DialogReturnCode.Cancel Тогда
		vCancel = True;
	ElsIf vAnswer = DialogReturnCode.Yes Тогда
		Items.DoClientList.Enabled = False;
		Items.DoServicePackage.Enabled = False;
		OK(Неопределено);
	Else
		Cancel(Неопределено);
	EndIf;
	
	ChargeCopyФрагмент(Items, vCancel);

КонецПроцедуры

&НаКлиенте
Процедура ChargeCopyФрагмент(Знач Items, Знач vCancel)
	
	Перем vCurRow, vCurRowID, vNewRow;
	
	If НЕ vCancel Тогда
		vCurRowID = Items.НачислениеУслуг.CurrentRow;
		If vCurRowID <> Неопределено Тогда
			vCurRow = Object.НачислениеУслуг.Get(vCurRowID);
			vNewRow = Object.НачислениеУслуг.Add();
			Items.SelectedChargeParametersGroup.Enabled = True;
			vNewRow.ДатаДок = vCurRow.ДатаДок;
			vNewRow.IsChanging = True;
			Object.ДатаДок = vCurRow.ДатаДок;
			//vNewRow.GuestGroup = tcOnServer.cmGetAttributeByRef(vCurRow.Document, "GuestGroup");
			vNewRow.НомерРазмещения = vCurRow.НомерРазмещения;
			vNewRow.Клиент = vCurRow.Клиент;
			vNewRow.Услуга = vCurRow.Услуга;
			vNewRow.Цена = vCurRow.Цена;
			vNewRow.Количество = vCurRow.Количество;
			vNewRow.Сумма = vCurRow.Сумма;
			vNewRow.Document = vCurRow.Document;
			FillParametersByRow(vNewRow);
			//GetDocumentsInGG(?(ЗначениеЗаполнено(vNewRow.Client), True, False), ?(ЗначениеЗаполнено(vNewRow.ГруппаНомеров), True, False));
			CurrentRowID = vNewRow.GetID();
			Items.НачислениеУслуг.CurrentRow = CurrentRowID;
		EndIf;
	EndIf;

КонецПроцедуры

InOnActivateRowMode = False;
