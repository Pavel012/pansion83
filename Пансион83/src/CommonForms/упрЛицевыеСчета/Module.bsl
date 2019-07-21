&НаКлиенте
Перем DragIndex;

//------------------------------------------------------------------------------------------------
&НаКлиенте
Процедура OnOpen(pCancel)
	// Fill document references
	AccRef = AccObject.Ref;
	ResRef = ResObject.Ref;
	// Get list of guests with old debts
	vGuestsList = OnOpenForm();
	If vGuestsList.Count() > 0 Тогда
		vGuestsStr = "";
		For Each vGuestItem In vGuestsList Do
			If IsBlankString(vGuestsStr) Тогда
				vGuestsStr = СокрЛП(vGuestItem.Value);
			Else
				vGuestsStr = vGuestsStr + ", " + СокрЛП(vGuestItem.Value);
			EndIf;
		EndDo;
		If vGuestsList.Count() > 1 Тогда
			ShowMessageBox(Неопределено, NStr("ru='У гостей: " + vGuestsStr + " есть долги/переплаты прошлых периодов! Будут открыты их счета (со знаком восклицания)'; 
			                  |en='There are folios with previous period debts/deposits for the clients: " + vGuestsStr + "! Now will open their folios (with exclamation mark)';
							  |de='There are folios with previous period debts/deposits for the clients: " + vGuestsStr + "! Now will open their folios (with exclamation mark)'"));
		Else
			ShowMessageBox(Неопределено, NStr("ru='У гостя " + vGuestsStr + " есть долги/переплаты прошлых периодов! Будет открыт его счет (со знаком восклицания)'; 
			                  |en='There are folios with previous period debts/deposits for the " + vGuestsStr + " client! Now will open his folio (with exclamation mark)';
							  |de='There are folios with previous period debts/deposits for the " + vGuestsStr + " client! Now will open his folio (with exclamation mark)'"));
		EndIf;
	EndIf;
КонецПроцедуры //OnOpen

//------------------------------------------------------------------------------------------------
&AtServer
Function OnOpenForm()
	vDocumentsArray = New Array;
	MaxPagesCount = 5;
	If НЕ ЭтоНовыйObj Тогда
		WasPosted = True;
		// Fill one ГруппаНомеров guests
		vQry = New Query;
		If ЗначениеЗаполнено(AccObject.Автор) And ЗначениеЗаполнено(AccObject.ДатаДок) Тогда
			vQry.Text = "SELECT
			|	Размещение.Ref AS Ref
			|FROM
			|	Document.Размещение AS Размещение
			|WHERE
			|	Размещение.ГруппаГостей = &qGroup
			|	AND Размещение.НомерРазмещения = &qRoom
			|	AND Размещение.Ref <> &qAccRef
			|	AND Размещение.Posted
			|	AND NOT Размещение.DeletionMark
			|	AND ((Размещение.СтатусРазмещения.IsActive
			|			OR Размещение.СтатусРазмещения.ЭтоЗаезд
			|			OR Размещение.СтатусРазмещения.ЭтоГости)
			|		OR (Размещение.СтатусРазмещения = &qAccStatus))
			|ORDER BY
			|	Размещение.ВидРазмещения.ПорядокСортировки";
			vQry.SetParameter("qAccStatus", AccObject.СтатусРазмещения);
			vQry.SetParameter("qAccRef", AccRef);
			vObjRef = AccRef;
		Else
			vQry.Text = "SELECT
			|	Бронирование.Ref AS Ref
			|FROM
			|	Document.Бронирование AS Бронирование
			|WHERE
			|	Бронирование.ГруппаГостей = &qGroup
			|	AND (Бронирование.НомерРазмещения = &qRoom
			|				AND &qRoomIsFilled
			|			OR Бронирование.НомерДока = &qNumber
			|				AND NOT &qRoomIsFilled)
			|	AND (Бронирование.Клиент <> &qGuest 
			|			Or (Бронирование.Клиент = &qEmptyGuest 
			|					And Бронирование.ВидРазмещения <> &qAccType))
			|	AND Бронирование.Posted
			|	AND NOT Бронирование.DeletionMark
			|	AND ((Бронирование.ReservationStatus.IsActive
			|			OR Бронирование.ReservationStatus.ЭтоЗаезд
			|			OR Бронирование.ReservationStatus.IsPreliminary
			|			OR Бронирование.ReservationStatus.IsInWaitingList)
			|		OR	(Бронирование.ReservationStatus = &qReservStatus))
			|ORDER BY
			|	Бронирование.ВидРазмещения.ПорядокСортировки";
			vQry.SetParameter("qReservStatus", ResObject.ReservationStatus);
			vObjRef = ResRef;
		EndIf;
		vQry.SetParameter("qGroup", vObjRef.ГруппаГостей);
		vQry.SetParameter("qRoom", vObjRef.НомерРазмещения);
		vQry.SetParameter("qGuest", vObjRef.Клиент);
		vQry.SetParameter("qEmptyGuest", Справочники.Клиенты.EmptyRef());
		vQry.SetParameter("qAccType", vObjRef.ВидРазмещения);
		vQry.SetParameter("qRoomIsFilled", ЗначениеЗаполнено(vObjRef.НомерРазмещения));
		vQry.SetParameter("qNumber", vObjRef.НомерДока);
		vQryResult = vQry.Execute().Unload();
		vDocumentsArray = vQryResult.UnloadColumn("Ref");
		If ЗначениеЗаполнено(vObjRef) Тогда
			vDocumentsArray.Вставить(0, vObjRef);
		EndIf;
	Else
//		If ЗначениеЗаполнено(AccObject.Автор) And ЗначениеЗаполнено(AccObject.ДатаДок) Тогда
//			vObj = FormAttributeToValue("AccObject");
//		Else
//			vObj = FormAttributeToValue("ResObject");
//		EndIf;
		//vRef = vObj.pmGetThisDocumentRef();
		//vDocumentsArray.Add(vRef);
	EndIf;
	GetFolios(vDocumentsArray);
	vGuestsList = New СписокЗначений;
	DebtFoliosList.Clear();
	For Each vRef In vDocumentsArray Do
		vDocRef = vRef;
		If TypeOf(vRef) = Type("DocumentRef.Размещение") Тогда
			// Get last accommodation in chain
			vDocRef = vRef.GetObject().pmGetLastAccommodationInChain();
			If НЕ ЗначениеЗаполнено(vDocRef) Тогда
				vDocRef = vRef;
			EndIf;
		EndIf;
		
		// Try to find guest master folio in the document charging rules.
		vGuestMasterFolio = Неопределено;
		For Each vCRRow In vDocRef.ChargingRules Do
			If ЗначениеЗаполнено(vCRRow.ChargingFolio) And vCRRow.ChargingFolio.IsMaster Тогда
				If ЗначениеЗаполнено(vDocRef.Клиент) And ЗначениеЗаполнено(vCRRow.Owner) And vDocRef.Клиент = vCRRow.Owner Тогда
					vGuestMasterFolio = vCRRow.ChargingFolio;
					Break;
				EndIf;
			EndIf;
		EndDo;
		
		// Check if there are any folios with debts for the current guest
		If ЗначениеЗаполнено(vDocRef.Клиент) Тогда
			If НЕ ЗначениеЗаполнено(vGuestMasterFolio) Тогда
				vDebtFolios = cmGetClientFoliosWithDebts(vDocRef.Клиент, vDocRef.ГруппаГостей);
				If vDebtFolios.Count() > 0 Тогда
					For Each vDebtFolio In vDebtFolios Do
						CreateNewDebtFolio(vDebtFolio.Value);	
					EndDo;
					vGuestsList.Add(vDocRef.Клиент);
				EndIf;
			EndIf;
		EndIf;
	EndDo;
	Return vGuestsList;
EndFunction //OnOpenForm

//------------------------------------------------------------------------------------------------
&AtServer
Процедура CreateNewDebtFolio(pFolio)
	If PagesCount = MaxPagesCount Тогда
		CreateNewPagesAndTables(PagesCount, 1);
	EndIf;
	CreateNewFolio(PagesCount+1,,pFolio);
КонецПроцедуры //CreateNewDebtFolio

//------------------------------------------------------------------------------------------------
&AtServer
Процедура GetFolios(pRefArray = Неопределено)
	If ЗначениеЗаполнено(AccObject.Автор) And ЗначениеЗаполнено(AccObject.ДатаДок) Тогда
		Items.HeaderDecoration.Title = NStr("en='ГруппаНомеров: ';ru='Номер: ';de='Zimmer: '")+СокрЛП(AccObject.НомерРазмещения)+NStr("en='     Guest group: ';ru='     Группа гостей: ';de='     Gästegruppe: '")+СокрЛП(AccObject.ГруппаГостей)+Chars.LF+
		NStr("en='from: ';ru='с: ';de='ab: '")+Format(AccObject.CheckInDate, "DF=dd/MM/yy")+NStr("en='     to: ';ru='     по: ';de='     bis: '")+Format(AccObject.ДатаВыезда, "DF=dd/MM/yy");
		Items.ParentDocDecoration.Title = СокрЛП(AccRef);
	Else
		Items.HeaderDecoration.Title = NStr("en='ГруппаНомеров: ';ru='Номер: ';de='Zimmer: '")+СокрЛП(ResObject.НомерРазмещения)+NStr("en='     Guest group: ';ru='     Группа гостей: ';de='     Gästegruppe: '")+СокрЛП(ResObject.ГруппаГостей)+Chars.LF+
		NStr("en='from: ';ru='с: ';de='ab: '")+Format(ResObject.CheckInDate, "DF=dd/MM/yy")+NStr("en='     to: ';ru='     по: ';de='     bis: '")+Format(ResObject.ДатаВыезда, "DF=dd/MM/yy");
		Items.ParentDocDecoration.Title = СокрЛП(ResRef);
	EndIf;
	vQry = New Query;
	vQry.Text =
	"SELECT
	|	СчетПроживания.Ref AS Ref,
	|	NULL AS CurrentDocument,
	|	СчетПроживания.ДокОснование AS ДокОснование,
	|	СчетПроживания.ДокОснование.ДатаДок AS ParentDocDate,
	|	СчетПроживания.НомерДока AS Number,
	|	СчетПроживания.ДатаДок AS Date,
	|	СчетПроживания.Клиент AS Клиент,
	|	СчетПроживания.DateTimeFrom AS DateTimeFrom,
	|	СчетПроживания.DateTimeTo AS DateTimeTo,
	|	СчетПроживания.Контрагент AS Контрагент,
	|	СчетПроживания.Договор AS Договор,
	|	СчетПроживания.Примечания AS Примечания
	|FROM
	|	Document.СчетПроживания AS СчетПроживания
	|WHERE
	|	NOT СчетПроживания.DeletionMark ";
	vInQueryText = "SELECT
	|							AccommodationChargingRules.ChargingFolio.Ref
	|						 FROM
	|							Document.Размещение.ChargingRules AS AccommodationChargingRules
	|						 WHERE
	|							AccommodationChargingRules.Ref IN(&qRefArray) ";
	
	vQrySecondPartText = " UNION ALL
	|
	|SELECT
	|	AccommodationChargingRules.ChargingFolio.Ref,
	|	AccommodationChargingRules.Ref,
	|	AccommodationChargingRules.ChargingFolio.ДокОснование,
	|	AccommodationChargingRules.ChargingFolio.ДокОснование.ДатаДок,
	|	AccommodationChargingRules.ChargingFolio.НомерДока,
	|	AccommodationChargingRules.ChargingFolio.ДатаДок,
	|	AccommodationChargingRules.ChargingFolio.Клиент,
	|	AccommodationChargingRules.ChargingFolio.DateTimeFrom,
	|	AccommodationChargingRules.ChargingFolio.DateTimeTo,
	|	AccommodationChargingRules.ChargingFolio.Контрагент,
	|	AccommodationChargingRules.ChargingFolio.Договор,
	|	AccommodationChargingRules.ChargingFolio.Примечания
	|FROM
	|	Document.Размещение.ChargingRules AS AccommodationChargingRules
	|WHERE
	|	AccommodationChargingRules.Ref IN(&qRefArray) ";
	vQry.Text = vQry.Text + " AND СчетПроживания.Ref NOT IN("+vInQueryText+") AND СчетПроживания.ДокОснование IN (&qRefArray) ";
	vQrySecondPartText = vQrySecondPartText + " AND AccommodationChargingRules.Ref IN (&qRefArray) ORDER BY ParentDocDate, Number, Date";
	vQry.SetParameter("qRefArray", pRefArray);
	vQry.Text = vQry.Text + vQrySecondPartText;
    vQryResult = vQry.Execute().Unload();
	vQryResult.GroupBy("Ref,ДокОснование,ParentDocDate,Number,Date,Клиент,DateTimeFrom,DateTimeTo,Контрагент,Договор,Примечания");
    vQryResult.Columns.Add("RuleString");
	PagesCount = vQryResult.Count();
	For vInd = 1 To MaxPagesCount Do
		If НЕ ЗначениеЗаполнено(ПараметрыСеанса.ТекПользователь.Контрагент) Тогда
			vPaymentButton = Items["ЛицевойСчет"+vInd+"Платеж"];
			vPaymentButton.Visible = True;
		EndIf;
	EndDo;
	If PagesCount > MaxPagesCount Тогда
		CreateNewPagesAndTables(MaxPagesCount, PagesCount-MaxPagesCount);
	ElsIf PagesCount <= MaxPagesCount Тогда
		For vInd=1 To MaxPagesCount Do
			vPage = Items["ЛицевойСчет"+vInd+"Group"];
			vPage.Visible = False;
			If vInd > PagesCount Тогда
				vFolioCommandItem = Items["FormFolioCommand"+vInd];
				vFolioCommandItem.Visible = False;
				vFolioCommandItem.Check = False;
			EndIf;
		EndDo;
	EndIf;
	vInd = 1;
	vTotalTable = New ValueTable;
	vTotalTable.Columns.Add("Контрагент");
	vTotalTable.Columns.Add("Total");
	vTotalTable.Columns.Add("Валюта");
	vTotalTable.Columns.Add("TotalDescription");
	For Each vFolioStr In vQryResult Do
		// Calculate totals
		If ЗначениеЗаполнено(vFolioStr.Customer) Тогда
			vFindedRow = vTotalTable.Find(vFolioStr.Customer, "Контрагент");
		Else
			vFindedRow = vTotalTable.Find(vFolioStr.Client, "Контрагент");
		EndIf;
		If vFindedRow = Неопределено Тогда
			vFindedRow = vTotalTable.Add();
			vFindedRow.Контрагент = ?(ЗначениеЗаполнено(vFolioStr.Customer), vFolioStr.Customer, vFolioStr.Client);
			vFindedRow.Total = 0;
			vFindedRow.Валюта = vFolioStr.Ref.ВалютаЛицСчета;
		EndIf;
		// End of calculate totals (it will be continued at the end of the FillFolioPage procedure)
		FillFolioPage(vFolioStr, vQryResult.IndexOf(vFolioStr), vFindedRow, vTotalTable);
		If ЗначениеЗаполнено(vFolioStr.Customer) Тогда
			vPic = PictureLib.Контрагент;
		Else
			vPic = PictureLib.Adult;
		EndIf;
		FoliosNumberList.Add(vInd, cmGetDocumentNumberPresentation(vFolioStr.Number)+?(ЗначениеЗаполнено(vFolioStr.Ref.Description),СокрЛП(vFolioStr.Ref.Description),""),, vPic);
		vInd = vInd + 1;
	EndDo; 
	If PagesCount = 1 Тогда
		Items.Folio1Group.Visible = True;
		Items.FormFolioCommand1.Check = True;
		Items.EmptyPageTable.Visible = True;
		Items.EmptyPageTable1.Visible = False;
	ElsIf PagesCount > 1 Тогда
		Items.Folio1Group.Visible = True;
		Items.FormFolioCommand1.Check = True;
		Items.Folio2Group.Visible = True;
		Items.FormFolioCommand2.Check = True;
		Items.EmptyPageTable.Visible = False;
		Items.EmptyPageTable1.Visible = False;
	Else
		Items.EmptyPageTable.Visible = True;
		Items.EmptyPageTable1.Visible = True;
	EndIf;
	CurrentFolio = PageFolio1;	
КонецПроцедуры //GetFolios

//------------------------------------------------------------------------------------------------
&AtServer
Процедура CreateNewPagesAndTables(pPagesCountNow, pNewAttributesNumber)
	//Value table type description
	vTypesArray = New Array;
	vTypesArray.Add(Type("ValueTable"));
	vValueTableTD = New TypeDescription(vTypesArray);
	//Value table column (Date) type description
	vTypesArray = New Array;
	vTypesArray.Add(Type("Date"));
	vDateTD = New TypeDescription(vTypesArray,,,New DateQualifiers(DateFractions.ДатаДок));
	//Value table column (Service) type description
	vTypesArray = New Array;
	vTypesArray.Add(Type("String"));
	vTypesArray.Add(Type("CatalogRef.Услуги"));
	vServiceTD = New TypeDescription(vTypesArray);
	//Value table column (Sum) type description
	vTypesArray = New Array;
	vTypesArray.Add(Type("Number"));
	vNQ = New NumberQualifiers(10, 2);
	vSumTD = New TypeDescription(vTypesArray, , ,vNQ);
	//Value table column (Remarks) type description
	vTypesArray = New Array;
	vTypesArray.Add(Type("String"));
	vRemarksTD = New TypeDescription(vTypesArray);
	//Value table column (IsPayment) type description
	vTypesArray = New Array;
	vTypesArray.Add(Type("Boolean"));
	vIsPaymentTD = New TypeDescription(vTypesArray);
	//Value table column (Ref) type description
	vTypesArray = New Array;
	vTypesArray.Add(Type("DocumentRef.Начисление"));
	vTypesArray.Add(Type("DocumentRef.Платеж"));
	vTypesArray.Add(Type("DocumentRef.Сторно"));
	vTypesArray.Add(Type("DocumentRef.ПреАвторизация"));
	vTypesArray.Add(Type("DocumentRef.Акт"));
	vTypesArray.Add(Type("DocumentRef.ПеремещениеДепозита"));
	vRefTD = New TypeDescription(vTypesArray);
	//ЛицевойСчет attribute type description
	vTypesArray = New Array;
	vTypesArray.Add(Type("DocumentRef.СчетПроживания"));
	vFolioRefTD = New TypeDescription(vTypesArray);
    vPagesCountNow = pPagesCountNow;
	For vInd = 1 To pNewAttributesNumber Do
		vIndex = vPagesCountNow+vInd;
		//Create value table
		vVTAttribute = New FormAttribute("FolioDocuments"+String(vIndex), vValueTableTD,, NStr("en='ЛицевойСчет documents ';ru='Документы фолио ';de='Dokumente ЛицевойСчет '")+String(vIndex));
		//Create value table columns
		vDateAttribute = New FormAttribute("Date", vDateTD, "FolioDocuments"+vIndex, NStr("en='Date';ru='Дата';de='Datum'"));
		vServiceAttribute = New FormAttribute("Услуга", vServiceTD, "FolioDocuments"+vIndex, NStr("en='Service';ru='Услуга';de='Dienstleistung'"));
		vSumAttribute = New FormAttribute("Сумма", vSumTD, "FolioDocuments"+vIndex, NStr("en='Amount';ru='Сумма';de='Summe'"));
		vRemarksAttribute = New FormAttribute("Примечания", vRemarksTD, "FolioDocuments"+vIndex, NStr("en='Remarks';ru='Примечания';de='Anmerkungen'"));
		vSumPresentationAttribute = New FormAttribute("SumPresentation", vRemarksTD, "FolioDocuments"+vIndex, NStr("en='Amount';ru='Сумма';de='Summe'"));
		vIsPaymentAttribute = New FormAttribute("IsPayment", vIsPaymentTD, "FolioDocuments"+vIndex, NStr("en='Is payment';ru='Это платеж';de='Das ist die Zahlung'"));
		vRefAttribute = New FormAttribute("Ref", vRefTD, "FolioDocuments"+vIndex, NStr("en='Ref';ru='Ссылка';de='Link'"));
		//Create folio attributes
		vFolioRefAttribute = New FormAttribute("PageFolio"+vIndex, vFolioRefTD,, NStr("en='Ref';ru='Ссылка';de='Link'"));
		//vTotalSumAttribute = New FormAttribute("PageTotalSumPresentation"+vIndex, vRemarksTD,, NStr("en='Total sum';ru='Итого';de='Gesamt'"));
		vCommandAttribute = Commands.Add("FolioCommand"+vIndex);
		vCommandAttribute.Action = "FolioCommand";
		//Add new attributes to array
		vAttributesArray = New Array;
		vAttributesArray.Add(vVTAttribute);
		vAttributesArray.Add(vDateAttribute);
		vAttributesArray.Add(vServiceAttribute);
		vAttributesArray.Add(vSumAttribute);
		vAttributesArray.Add(vSumPresentationAttribute);
		vAttributesArray.Add(vRemarksAttribute);
		vAttributesArray.Add(vIsPaymentAttribute);
		vAttributesArray.Add(vRefAttribute);
		vAttributesArray.Add(vFolioRefAttribute);
		//vAttributesArray.Add(vTotalSumAttribute);
		//Change attributes
		ChangeAttributes(vAttributesArray);
		//Add folio main group
		vNewPage = Items.Add("СчетПроживания"+vIndex+"Group", Type("FormGroup"), Items.MainFoliosGroup);
		vNewPage.ТипРазмещения = FormGroupType.UsualGroup;
		vNewPage.Title = NStr("en='""ЛицевойСчет ';ru='Группа ""Фолио ';de='Gruppe ""ЛицевойСчет"" '")+vIndex+NStr("ru='""'; en='"" group'; de='"" Gruppe'");
		vNewPage.Representation = UsualGroupRepresentation.GroupBox;
		vNewPage.Group = ChildFormItemsGroup.Vertical;
		vNewPage.ShowTitle = False;
		vNewPage.Visible = False;
		//Add folio header group
		vNewFolioHeaderGroup = Items.Add("СчетПроживания"+vIndex+"HeaderGroup", Type("FormGroup"), vNewPage);
		vNewFolioHeaderGroup.ТипРазмещения = FormGroupType.UsualGroup;
		vNewFolioHeaderGroup.Title = NStr("en='""ЛицевойСчет ';ru='Группа ""Фолио ';de='Gruppe ""ЛицевойСчет"" '")+vIndex+NStr("en=' header"" group';ru=' шапка""';de=' Kopf""'");
		vNewFolioHeaderGroup.Representation = UsualGroupRepresentation.None;
		vNewFolioHeaderGroup.Group = ChildFormItemsGroup.Horizontal;
		vNewFolioHeaderGroup.ShowTitle = False;
		vNewFolioHeaderGroup.Width = 46;
		vNewFolioHeaderGroup.HorizontalStretch = False;
		//Add folio number decoration field
		vNewFolioNumberDecorationField = Items.Add("СчетПроживания"+vIndex+"NumberDecoration", Type("FormDecoration"), vNewFolioHeaderGroup);
		vNewFolioNumberDecorationField.ТипРазмещения = FormDecorationType.Picture;
		vNewFolioNumberDecorationField.Font = New Font(,,True);
		vNewFolioNumberDecorationField.Width = 2;
		vNewFolioNumberDecorationField.Height = 1;
		vNewFolioNumberDecorationField.HorizontalStretch = False;
		//vNewFolioNumberDecorationField.HorizontalAlign = ItemHorizontalLocation.Center;
		vNewFolioNumberDecorationField.Hyperlink = True;
		vNewFolioNumberDecorationField.Title = String(vIndex)+".";
		vNewFolioNumberDecorationField.SetAction("Click", "FolioNumberDecorationClick");
		//Add folio description decoration field
		vNewFolioDescriptionDecorationField = Items.Add("СчетПроживания"+vIndex+"DescriptionDecoration", Type("FormDecoration"), vNewFolioHeaderGroup);
		vNewFolioDescriptionDecorationField.ТипРазмещения = FormDecorationType.Label;
		vNewFolioDescriptionDecorationField.Font = New Font(,,True);
		vNewFolioDescriptionDecorationField.HorizontalStretch = True;
		//Add new payment button
		If НЕ ЗначениеЗаполнено(ПараметрыСеанса.ТекПользователь.Контрагент) Тогда
			vNewPaymentButton = Items.Add("СчетПроживания"+vIndex+"Платеж", Type("FormButton"), vNewFolioHeaderGroup);
			vNewPaymentButton.ТипРазмещения = FormButtonType.UsualButton;
			vNewPaymentButton.Title = NStr("en='Payment';ru='Платеж';de='Zahlung'");
			vNewPaymentButton.Width = 10;
			vNewPaymentButton.Representation = ButtonRepresentation.Auto;
			vNewPaymentButton.CommandName = "Платеж";
		EndIf;
        //Add folio delete decoration field
		vNewFolioDeleteDecorationField = Items.Add("СчетПроживания"+vIndex+"DeleteDecoration", Type("FormDecoration"), vNewFolioHeaderGroup);
		vNewFolioDeleteDecorationField.ТипРазмещения = FormDecorationType.Picture;
		vNewFolioDeleteDecorationField.Picture = PictureLib.Close;
		vNewFolioDeleteDecorationField.Width = 3;
		vNewFolioDeleteDecorationField.Height = 1;
		vNewFolioDeleteDecorationField.PictureSize = PictureSize.RealSize;
		vNewFolioDeleteDecorationField.Hyperlink = True;
		vNewFolioDeleteDecorationField.Title = NStr("en='""ЛицевойСчет ';ru='Декорация ""Фолио ';de='Dekoration ""ЛицевойСчет '")+vIndex+NStr("en=' delete"" decoration';ru=' - кнопка удалить""';de=' - Taste löschen""'");
		vNewFolioDeleteDecorationField.SetAction("Click", "FolioDeleteDecorationClick");
		//Add new form table
		vNewFormTable = Items.Add("FolioDocuments"+vIndex, Type("FormTable"), vNewPage);
		vNewFormTable.DataPath = "FolioDocuments"+vIndex;
		vNewFormTable.Title = NStr("en='ЛицевойСчет ';ru='Фолио ';de='ЛицевойСчет '")+vIndex+NStr("en=' transactions list';ru=' список транзакций';de=' Liste der Transaktionen'");
		vNewFormTable.ChangeRowOrder = False;
		vNewFormTable.ChangeRowSet = False;
		vNewFormTable.CommandBarLocation = FormItemCommandBarLabelLocation.None;
		vNewFormTable.ReadOnly = False;
		vNewFormTable.BackColor = StyleColors.FormBackColor;
		vNewFormTable.Width = 46;
		vNewFormTable.HorizontalStretch = False;
		vNewFormTable.Footer = True;
		vNewFormTable.SetAction("DragEnd", "FolioDocumentsDragEnd");
		vNewFormTable.SetAction("Drag", "FolioDocumentsDrag");
		//Add form table columns
		vNewDateColumn = Items.Add("FolioDocuments"+vIndex+"Date", Type("FormField"), vNewFormTable);
		vNewDateColumn.DataPath = "FolioDocuments"+vIndex+".ДатаДок";
		vNewDateColumn.Title = NStr("en='Date';ru='Дата';de='Datum'");
		vNewDateColumn.ReadOnly = True;
		vNewDateColumn.HorizontalStretch = False;
		vNewServiceColumn = Items.Add("FolioDocuments"+vIndex+"Услуга", Type("FormField"), vNewFormTable);
		vNewServiceColumn.DataPath = "FolioDocuments"+vIndex+".Услуга";
		vNewServiceColumn.Title = NStr("en='Service';ru='Услуга';de='Dienstleistung'");
		vNewServiceColumn.ReadOnly = True;
		vNewServiceColumn.HorizontalStretch = True;
		vNewSumColumn = Items.Add("FolioDocuments"+vIndex+"SumPresentation", Type("FormField"), vNewFormTable);
		vNewSumColumn.DataPath = "FolioDocuments"+vIndex+".SumPresentation";
		vNewSumColumn.Title = NStr("en='Amount';ru='Сумма';de='Summe'");
		vNewSumColumn.ReadOnly = True;
		vNewSumColumn.Width = 12;
		vNewSumColumn.HorizontalStretch = False;
		vNewSumColumn.HorizontalAlign = ItemHorizontalLocation.Right;
		vNewSumColumn.HeaderHorizontalAlign = ItemHorizontalLocation.Right;
		vNewSumColumn.FooterHorizontalAlign = ItemHorizontalLocation.Right;
		vNewSumColumn.FooterFont = New Font(,,True);		
		//Add commands
		vNewFolioButton = Items.Add("FormFolioCommand"+vIndex, Type("FormButton"), Items.FormCommandBar);
		vNewFolioButton.ТипРазмещения = FormButtonType.CommandBarButton;
		vNewFolioButton.Representation = ButtonRepresentation.PictureAndText;
		vNewFolioButton.CommandName = "FolioCommand"+vIndex;
		//Add new conditional appearance 
		vNewAppearence = ЭтаФорма.ConditionalAppearance.Items.Add();
		vNewAppearence.Appearance.SetParameterValue("TextColor", New Color(17, 133, 0));
		vNewAppearence.Appearance.SetParameterValue("Font", New Font(,,True));
		vNewFilter = vNewAppearence.Filter.Items.Add(Type("DataCompositionFilterItem"));
		vNewFilter.ComparisonType = DataCompositionComparisonType.Equal;
		vNewFilter.LeftValue = New DataCompositionField("FolioDocuments"+vIndex+".IsPayment");
		vNewFilter.RightValue = True;
		vNewFilter.Use = True;
		vNewField = vNewAppearence.Fields.Items.Add();
		vNewField.Field = New DataCompositionField("FolioDocuments"+vIndex+"SumPresentation");
		vNewField.Use = True;
		vNewField = vNewAppearence.Fields.Items.Add();
		vNewField.Field = New DataCompositionField("FolioDocuments"+vIndex+"Услуга");
		vNewField.Use = True;
		vNewField = vNewAppearence.Fields.Items.Add();
		vNewField.Field = New DataCompositionField("FolioDocuments"+vIndex+"Date");
		vNewField.Use = True;
		MaxPagesCount = MaxPagesCount + 1;
	EndDo;
КонецПроцедуры //CreateNewPagesAndTables

//------------------------------------------------------------------------------------------------
&AtServer
Процедура FillFolioPage(pFolioStr, pIndex, pRow = Неопределено, pTotaltable=Неопределено, pIsDebt = False)
	vFolioObj = pFolioStr.Ref.GetObject();
	vAllTransactions = vFolioObj.pmGetAllFolioTransactions();
	vPageIndex = pIndex + 1;
	vHeaderDecoration = Items["ЛицевойСчет"+vPageIndex+"DescriptionDecoration"];
	If ЗначениеЗаполнено(pFolioStr.Контрагент) Тогда
		vHeaderDecoration.Title = СокрЛП(pFolioStr.Контрагент)+" ("+СокрЛП(pFolioStr.НомерДока)+")";
	ElsIf ЗначениеЗаполнено(pFolioStr.Клиент) Тогда
		vHeaderDecoration.Title = СокрЛП(pFolioStr.Клиент)+" ("+СокрЛП(pFolioStr.НомерДока)+")";
	Else
		vHeaderDecoration.Title = СокрЛП(pFolioStr.НомерДока);
	EndIf;
	If pIsDebt Тогда
		vPic = PictureLib.Attention;
	ElsIf ЗначениеЗаполнено(vFolioObj.Контрагент) Тогда
		vPic = PictureLib.Контрагент;
	Else
		vPic = PictureLib.Adult;
	EndIf;
	If Items["ЛицевойСчет"+vPageIndex+"NumberDecoration"].Picture <> PictureLib.Attention Тогда
		Items["ЛицевойСчет"+vPageIndex+"NumberDecoration"].Picture = vPic;
	EndIf;
	ЭтаФорма["PageFolio"+vPageIndex] = vFolioObj.Ref;
	vSum = 0;
	vTable = ЭтаФорма["FolioDocuments"+vPageIndex];
	vTable.Clear();
	For Each vTransactionRow In vAllTransactions Do
		vNewRow = vTable.Add();
		vNewRow.ДатаДок = vTransactionRow.Period;
		vNewRow.Услуга = vTransactionRow.Услуга;
		vNewRow.Примечания = vTransactionRow.Примечания;
		vNewRow.Сумма = vTransactionRow.Сумма;
		If TypeOf(vTransactionRow.Document) = Type("DocumentRef.Платеж") Or TypeOf(vTransactionRow.Document) = Type("DocumentRef.Акт")
			Or TypeOf(vTransactionRow.Document) = Type("DocumentRef.ПеремещениеДепозита") Тогда
			vNewRow.IsPayment = True;
			If TypeOf(vTransactionRow.Document) = Type("DocumentRef.ПеремещениеДепозита") Тогда
				vNewRow.Услуга = NStr("en='Deposit transfer';ru='Перенос дипозита';de='Übertragung des Deposits'");
			Else
				vNewRow.Услуга = String(vTransactionRow.Document.СпособОплаты);
			EndIf;
			If Left(vTransactionRow.Сумма, 1)="-" Тогда
				vNewRow.SumPresentation = cmFormatSum(0-vTransactionRow.Сумма, vFolioObj.ВалютаЛицСчета);
			Else
				vNewRow.SumPresentation = "-"+cmFormatSum(vTransactionRow.Сумма, vFolioObj.ВалютаЛицСчета);
			EndIf;
			vSum = vSum - vTransactionRow.Сумма;
		Else
			vNewRow.SumPresentation = cmFormatSum(vTransactionRow.Сумма, vFolioObj.ВалютаЛицСчета);
			vNewRow.IsPayment = False;
			vSum = vSum + vTransactionRow.Сумма;
		EndIf;
		vNewRow.Ref = vTransactionRow.Document;
	EndDo;
	vCommandItem = Items["FormFolioCommand"+vPageIndex];
	vCommandItem.Title = cmFormatSum(vSum, vFolioObj.ВалютаЛицСчета, "NZ=");
	If vCommandItem.Picture <> PictureLib.Attention Тогда
		vCommandItem.Picture = vPic;
	EndIf;
	vCommandItem.Representation = ButtonRepresentation.PictureAndText;
	Items["FolioDocuments"+vPageIndex+"SumPresentation"].FooterText = cmFormatSum(vSum, vFolioObj.ВалютаЛицСчета, "NZ=");
	If pRow <> Неопределено Тогда
		If pRow.Валюта = vFolioObj.ВалютаЛицСчета Тогда
			pRow.Total = pRow.Total + vSum;
		Else
			vNewRow = pTotaltable.Add();
			vNewRow.Контрагент = pRow.Контрагент;
			vNewRow.Total = vSum;
			vNewRow.Валюта = vFolioObj.ВалютаЛицСчета;
		EndIf;
	EndIf;
	If vPageIndex = 1 Тогда
		vAdditionalText = "";
		If pRow = Неопределено Тогда
			If ЗначениеЗаполнено(pFolioStr.Контрагент) Тогда
				Items.Payer1Pic.Picture = PictureLib.Контрагент;
				vAdditionalText = NStr("ru='Контрагент';en='Контрагент';de='Firma'");
				Items.Payer1NameDecoration.Title = ?(ЗначениеЗаполнено(СокрЛП(pFolioStr.Контрагент)), СокрЛП(pFolioStr.Контрагент), vAdditionalText)+" =";
			Else
				Items.Payer1Pic.Picture = PictureLib.Adult;
				vAdditionalText = NStr("en='Guest';ru='Гость';de='Gast'");
				Items.Payer1NameDecoration.Title = ?(ЗначениеЗаполнено(СокрЛП(pFolioStr.Клиент)), СокрЛП(pFolioStr.Клиент), vAdditionalText)+" =";
			EndIf;
		Else
			If TypeOf(pRow.Контрагент)=Type("CatalogRef.Контрагенты") Тогда
				Items.Payer1Pic.Picture = PictureLib.Контрагент;
				vAdditionalText = NStr("ru='Контрагент';en='Контрагент';de='Firma'");
			Else
				Items.Payer1Pic.Picture = PictureLib.Adult;
				vAdditionalText = NStr("en='Guest';ru='Гость';de='Gast'");
			EndIf;
			Items.Payer1NameDecoration.Title = ?(ЗначениеЗаполнено(СокрЛП(pRow.Контрагент)), СокрЛП(pRow.Контрагент), vAdditionalText)+" =";
		EndIf;
		If pTotaltable <> Неопределено Тогда
			vFindedRows = pTotalTable.FindRows(New Structure("Контрагент", pRow.Контрагент));
			vFindedRowIndex = 0;
			For Each vFindedRow In vFindedRows Do
				Items.Payer1Decoration.Title = Items.Payer1Decoration.Title+?(IsBlankString(Items.Payer1Decoration.Title),"","; ")+cmFormatSum(vFindedRow.Total, vFindedRow.Валюта, "NZ=");
				If vFindedRowIndex > 0 Тогда
					pTotalTable.Delete(vFindedRow);
				EndIf;
				vFindedRowIndex = vFindedRowIndex + 1;
			EndDo;
		Else
			Items.Payer1Decoration.Title = cmFormatSum(vSum, vFolioObj.ВалютаЛицСчета, "NZ=");
		EndIf;
	Else
		vAdditionalText = "";
		If НЕ ЗначениеЗаполнено(Items.Payer2Decoration.Title) Тогда
			If pRow = Неопределено Тогда
				If ЗначениеЗаполнено(pFolioStr.Контрагент) Тогда
					Items.Payer2Pic.Picture = PictureLib.Контрагент;
					vAdditionalText = NStr("ru='Контрагент';en='Контрагент';de='Firma'");
					Items.Payer2NameDecoration.Title = ?(ЗначениеЗаполнено(СокрЛП(pFolioStr.Контрагент)), СокрЛП(pFolioStr.Контрагент), vAdditionalText)+" =";
				Else
					Items.Payer2Pic.Picture = PictureLib.Adult;
					vAdditionalText = NStr("en='Guest';ru='Гость';de='Gast'");
					Items.Payer2NameDecoration.Title = ?(ЗначениеЗаполнено(СокрЛП(pFolioStr.Клиент)), СокрЛП(pFolioStr.Клиент), vAdditionalText)+" =";
				EndIf;
			Else
				If TypeOf(pRow.Контрагент)=Type("CatalogRef.Контрагенты") Тогда
					Items.Payer2Pic.Picture = PictureLib.Контрагент;
					vAdditionalText = NStr("ru='Контрагент';en='Контрагент';de='Firma'");
				Else
					Items.Payer2Pic.Picture = PictureLib.Adult;
					vAdditionalText = NStr("en='Guest';ru='Гость';de='Gast'");
				EndIf;
				Items.Payer2NameDecoration.Title = ?(ЗначениеЗаполнено(СокрЛП(pRow.Контрагент)), СокрЛП(pRow.Контрагент), vAdditionalText)+" =";
			EndIf;
			If pTotaltable <> Неопределено Тогда
				vFindedRows = pTotalTable.FindRows(New Structure("Контрагент", pRow.Контрагент));
				vFindedRowIndex = 0;
				For Each vFindedRow In vFindedRows Do
					Items.Payer2Decoration.Title = Items.Payer2Decoration.Title+?(IsBlankString(Items.Payer2Decoration.Title),"","; ")+cmFormatSum(vFindedRow.Total, vFindedRow.Валюта, "NZ=");
					If vFindedRowIndex > 0 Тогда
						pTotalTable.Delete(vFindedRow);
					EndIf;
					vFindedRowIndex = vFindedRowIndex + 1;
				EndDo;
			Else
				Items.Payer2Decoration.Title = cmFormatSum(vSum, vFolioObj.ВалютаЛицСчета, "NZ=");
			EndIf;
		EndIf;
	EndIf;
КонецПроцедуры //FillFolioPage

//------------------------------------------------------------------------------------------------
&AtServer
Function GetCurrentFolioStructure(vIndex = Неопределено)
	If vIndex = Неопределено Тогда
		vFolioStructure = New Structure;
		vFolioStructure.Вставить("Ref", CurrentFolio);
		vFolioStructure.Вставить("Контрагент", CurrentFolio.Контрагент);
		vFolioStructure.Вставить("Клиент", CurrentFolio.Клиент);
		vFolioStructure.Вставить("Number", СокрЛП(CurrentFolio.НомерДока));
		vFolioStructure.Вставить("ДокОснование", CurrentFolio.ДокОснование);
	Else
		vFolio = ЭтаФорма["PageFolio"+String(vIndex)];
		vFolioStructure = New Structure;
		vFolioStructure.Вставить("Ref", vFolio);
		vFolioStructure.Вставить("Контрагент", vFolio.Контрагент);
		vFolioStructure.Вставить("Клиент", vFolio.Клиент);
		vFolioStructure.Вставить("Number", СокрЛП(vFolio.НомерДока));
		vFolioStructure.Вставить("ДокОснование", vFolio.ДокОснование);
	EndIf;
	Return vFolioStructure;
EndFunction //GetCurrentFolioStructure

//------------------------------------------------------------------------------------------------
&НаКлиенте
Процедура NotificationProcessing(pEventName, pParameter, pSource)
	If pEventName = "Document.Платеж.Write" Тогда
		For vInd = 1 To PagesCount Do
			FillFolioPage(GetCurrentFolioStructure(vInd), vInd-1);
		EndDo;
	ElsIf pEventName = "Document.Начисление.Write" Тогда
		For vInd = 1 To PagesCount Do
			FillFolioPage(GetCurrentFolioStructure(vInd), vInd-1);
		EndDo;
	ElsIf pEventName = "Document.ПеремещениеДепозита.Write" Тогда
		For vInd = 1 To PagesCount Do
			FillFolioPage(GetCurrentFolioStructure(vInd), vInd-1);
		EndDo;
	EndIf;
КонецПроцедуры //NotificationProcessing

//-----------------------------------------------------------------------------
&AtServer
Процедура CreateNewFolio(pIndexStr=Неопределено, pDeleting = False, pFolio = Неопределено)
	If pDeleting Тогда
		vDeletingFolioObj = pFolio.GetObject();
		vDeletingFolioObj.DeletionMark = True;
		vDeletingFolioObj.IsClosed = True;
		vDeletingFolioObj.Write(DocumentWriteMode.Write);
		Return;
	EndIf;
	if НЕ pDeleting And pFolio = Неопределено Тогда
		vFolioObj = Documents.СчетПроживания.CreateDocument();
		vFolioObj.SetTime(AutoTimeMode.CurrentOrLast);
		//vFolioObj.pmFillAttributesWithDefaultValues();
		If ЗначениеЗаполнено(AccObject.Автор) And ЗначениеЗаполнено(AccObject.ДатаДок) Тогда
			FillPropertyValues(vFolioObj, AccObject.Ref,,"Date, Автор");
			vFolioObj.Клиент = AccObject.Клиент;
			vFolioObj.ДокОснование = AccObject.Ref;
		Else
			FillPropertyValues(vFolioObj, ResObject.Ref,,"Date, Автор");
			vFolioObj.Клиент = ResObject.Клиент;
			vFolioObj.ДокОснование = ResObject.Ref;
		EndIf;
		vFolioObj.Контрагент = Справочники.Контрагенты.EmptyRef();
		vFolioObj.Договор = Справочники.Договора.EmptyRef();
		vFolioObj.Write(DocumentWriteMode.Write);
		ЭтаФорма["PageFolio"+pIndexStr] = vFolioObj.Ref;
		PrevLastPageFolio = vFolioObj.Ref;
		CurrentFolio = vFolioObj.Ref;
		FillFolioPage(GetCurrentFolioStructure(), Number(pIndexStr)-1);
	Else
		ЭтаФорма["PageFolio"+pIndexStr] = pFolio;
		PrevLastPageFolio = pFolio;
		CurrentFolio = pFolio;
		FillFolioPage(GetCurrentFolioStructure(), Number(pIndexStr)-1,,, True);
	EndIf;
	If Items.EmptyPageTable1.Visible Тогда
		Items.EmptyPageTable1.Visible = False;
		vFolioGroup = Items["ЛицевойСчет"+pIndexStr+"Group"];
		vFolioGroup.Visible = True;
		For vInd = 1 To PagesCount Do
			//vCurrentFolioFooter = Items["ЛицевойСчет"+vInd+"FooterDecoration"];
			//vCurrentFolioFooter.Hyperlink = True;
			vCommandItem = Items["FormFolioCommand"+vInd];
			vCommandItem.Check = False;
		EndDo;
	ElsIf Items.EmptyPageTable.Visible Тогда
		Items.EmptyPageTable.Visible = False;
		vFolioGroup = Items["ЛицевойСчет"+pIndexStr+"Group"];
		vFolioGroup.Visible = True;
		For vInd = 1 To PagesCount Do
			If НЕ Items["ЛицевойСчет"+vInd+"Group"].Visible Тогда
				//vCurrentFolioFooter = Items["ЛицевойСчет"+vInd+"FooterDecoration"];
				//vCurrentFolioFooter.Hyperlink = True;
				vCommandItem = Items["FormFolioCommand"+vInd];
				vCommandItem.Check = False;
			EndIf;
		EndDo;
	Else
		For vInd = 1 To PagesCount Do
			If Items["ЛицевойСчет"+vInd+"Group"].Visible Тогда
				vCurrentFolioGroup = Items["ЛицевойСчет"+vInd+"Group"];
				//vCurrentFolioFooter = Items["ЛицевойСчет"+vInd+"FooterDecoration"];
				vCurrentCommandItem = Items["FormFolioCommand"+vInd];
			EndIf;
		EndDo;
		vCurrentCommandItem.Check = False;
		//Делаем невидимой только последнюю группу фолио
		vCurrentFolioGroup.Visible = False;
		//делаем видимой выбранную группу
		vFolioGroup = Items["ЛицевойСчет"+pIndexStr+"Group"];
		vFolioGroup.Visible = True;
	EndIf;
	//vFolioFooterGroup = Items["ЛицевойСчет"+pIndexStr+"FooterGroup"];
	//vFolioFooterGroup.Visible = True;
	vFolioCommandItem = Items["FormFolioCommand"+pIndexStr];
	vFolioCommandItem.Visible = True;
	vFolioCommandItem.Check = True;
	//Items["ЛицевойСчет"+pIndexStr+"FooterDecoration"].Hyperlink = False;
	PagesCount = PagesCount + 1;
КонецПроцедуры //CreateNewFolio

//+//-----------------------------------------------------------------------------
&НаКлиенте
Процедура Payment(pCommand)
	vCurItem = ЭтаФорма.CurrentItem;
	vCurIndex = Left(vCurItem.Name, StrLen(vCurItem.Name)-7);
	vCurIndex = Right(vCurIndex, StrLen(vCurIndex)-5);
	vCurFolio = ЭтаФорма["PageFolio"+vCurIndex];
	If ЗначениеЗаполнено(vCurFolio) Тогда
		If (WasPosted = False Or IsFormModified) Тогда
			vResult = ЭтаФорма.FormOwner.WriteAtServer();
			If ЗначениеЗаполнено(vResult) And vResult <> "Error" Тогда
				ShowMessageBox(Неопределено, vResult);
			ElsIf НЕ ЗначениеЗаполнено(vResult) Тогда
				// Get preauthorisation documents selected
				vPreauthDocRef = GetPreauthorisationsSelected();
				If vPreauthDocRef = Неопределено Тогда
					// Create new payment
					УпрСерверныеФункции.cmWriteLogEventAtServer(NStr("en='Document.Create';ru='Документ.СозданиеНового';de='Document.Create'"),, "Documents.Платеж", "Documents.Платеж.EmptyRef()", NStr("en='Create new';ru='Создание нового';de='Erstellung eines neuen'"));
					OpenForm("Document.Платеж.Form.tcDocumentForm", New Structure("Document", vCurFolio), ЭтаФорма,,,, Неопределено, РежимОткрытияОкнаФормы.БлокироватьВесьИнтерфейс);
				Else
					OpenForm("Document.Платеж.Form.tcDocumentForm", New Structure("Document", vPreauthDocRef), ЭтаФорма,,,, Неопределено, РежимОткрытияОкнаФормы.БлокироватьВесьИнтерфейс);
				EndIf;
			EndIf;         
		Else
			// Get preauthorisation documents selected
			vPreauthDocRef = GetPreauthorisationsSelected();
			If vPreauthDocRef = Неопределено Тогда
				// Create new payment
				УпрСерверныеФункции.cmWriteLogEventAtServer(NStr("en='Document.Create';ru='Документ.СозданиеНового';de='Document.Create'"),, "Documents.Платеж", "Documents.Платеж.EmptyRef()", NStr("en='Create new';ru='Создание нового';de='Erstellung eines neuen'"));
				OpenForm("Document.Платеж.Form.tcDocumentForm", New Structure("Document", vCurFolio), ЭтаФорма,,,, Неопределено, РежимОткрытияОкнаФормы.БлокироватьВесьИнтерфейс);
			Else
				OpenForm("Document.Платеж.Form.tcDocumentForm", New Structure("Document", vPreauthDocRef), ЭтаФорма,,,, Неопределено, РежимОткрытияОкнаФормы.БлокироватьВесьИнтерфейс);
			EndIf;
		EndIf;
	Else
		ShowMessageBox(Неопределено, NStr("en='No folio is selected!';ru='Не выбран лицевой счет!';de='Kein Personenkonto ist gewählt!'"));
	EndIf;
КонецПроцедуры //Payment

//+//-----------------------------------------------------------------------------
&AtServer
Function GetPreauthorisationsSelected()
	vCurrButton = ЭтаФорма.CurrentItem;
	//Folio1Payment
	vFP = Left(vCurrButton.Name, StrLen(vCurrButton.Name)-7); //Folio1
	vTableNumberStr = Right(vFP, StrLen(vFP)-5); //1
	vFolioDocuments = ЭтаФорма["FolioDocuments"+vTableNumberStr];
	For Each vCurRow In vFolioDocuments Do
		If ЗначениеЗаполнено(vCurRow.Ref) And TypeOf(vCurRow.Ref) = Type("DocumentRef.ПреАвторизация") Тогда
			If vCurRow.Ref.Status = Перечисления.PreauthorisationStatuses.Authorised Тогда
				Return vCurRow.Ref;
			EndIf;
		EndIf;
	EndDo;
	Return Неопределено;
EndFunction //GetPreauthorisationsSelected

//+//-----------------------------------------------------------------------------
&НаКлиенте
Процедура Charge(pCommand)
	If (WasPosted = False Or IsFormModified) Тогда
		vResult = ЭтаФорма.FormOwner.WriteAtServer();
		If ЗначениеЗаполнено(vResult) And vResult <> "Error" Тогда
			ShowMessageBox(Неопределено, vResult);
		ElsIf НЕ ЗначениеЗаполнено(vResult) Тогда
			vResult = ChargeAtServer();
			If ЗначениеЗаполнено(vResult) Тогда
				ShowMessageBox(Неопределено, vResult);
			Else
				OpenForm("DataProcessor.НачислениеУслуг.Form", New Structure("Document", ?(ЗначениеЗаполнено(AccObject.Автор) And ЗначениеЗаполнено(AccObject.ДатаДок), AccObject.Ref, ResObject.Ref)), ЭтаФорма,,,, Неопределено, РежимОткрытияОкнаФормы.БлокироватьВесьИнтерфейс);
			Endif;
		Endif;
	Else
		vResult = ChargeAtServer();
		If ЗначениеЗаполнено(vResult) Тогда
			ShowMessageBox(Неопределено, vResult);
		Else
			OpenForm("DataProcessor.НачислениеУслуг.Form", New Structure("Document", ?(ЗначениеЗаполнено(AccObject.Автор) And ЗначениеЗаполнено(AccObject.ДатаДок), AccObject.Ref, ResObject.Ref)), ЭтаФорма,,,, Неопределено, РежимОткрытияОкнаФормы.БлокироватьВесьИнтерфейс);
		Endif;
	Endif;
КонецПроцедуры //Charge

//-----------------------------------------------------------------------------
&AtServer
Function ChargeAtServer()
	If ЗначениеЗаполнено(CurrentFolio) Тогда
		// Check user rights
		If НЕ cmCheckUserPermissions("HavePermissionToEditClosedFolios") And CurrentFolio.IsClosed Тогда
			Return NStr("en='You do not have rights to edit closed folio transactions set!';ru='У вас нет прав на изменение набора транзакций по закрытым лицевым счетам!';de='Sie haben keine Rechte, den Transaktionsbestand nach geschlossenen Personenkonten zu bearbeiten!'");
		EndIf;
		If НЕ cmCheckUserPermissions("HavePermissionToEditCustomerFolioTransactions") Тогда
			If ЗначениеЗаполнено(CurrentFolio.СпособОплаты) And 
			   CurrentFolio.СпособОплаты.IsByBankTransfer Тогда
				Return NStr("en='You do not have rights to change Контрагент folio transactions set!';ru='У вас нет прав на изменение набора транзакций по лицевым счетам контрагентов!';de='Sie haben keine Rechte, den Transaktionsbestand nach  Personenkonten der Partner zu bearbeiten!'");
			EndIf;
		EndIf;
		// Create new charge
		WriteLogEvent(NStr("en='Document.Create';ru='Документ.СозданиеНового';de='Document.Create'"), EventLogLevel.Information, Metadata.Documents.Начисление, Documents.Начисление.EmptyRef(), NStr("en='Create new';ru='Создание нового';de='Erstellung eines neuen'"));
		Return "";
	Else
		Return NStr("en='No folio is selected!';ru='Не выбран лицевой счет!';de='Kein Personenkonto ist gewählt!'");
	EndIf;
EndFunction //ChargeAtServer

//-----------------------------------------------------------------------------
&AtServer
Процедура OnCreateAtServer(pCancel, pStandardProcessing)
	vParametersStructure = Неопределено;
	Parameters.Property("ParametersStructure", vParametersStructure);
	If vParametersStructure <> Неопределено Тогда
		//AccObject = vParametersStructure.Object;
		ЭтоНовыйObj = vParametersStructure.ЭтоНовый;
		WasPosted = vParametersStructure.WasPosted;
		IsFormModified = vParametersStructure.IsFormModified;
	Else
		pCancel = True;
	EndIf;
КонецПроцедуры //OnCreateAtServer

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура ParentDocDecorationClick(pItem)
	If ЗначениеЗаполнено(AccObject.Автор) And ЗначениеЗаполнено(AccObject.ДатаДок) Тогда
		ShowValue(Неопределено, AccObject.Ref);
	Else
		ShowValue(Неопределено, ResObject.Ref);
	EndIf;
КонецПроцедуры //ParentDocDecorationClick

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура FolioDeleteDecorationClick(pItem)
	vFP = Left(pItem.Name, StrLen(pItem.Name)-16);
	vIndexStr = Right(vFP, StrLen(vFP)-5);
	vFolioGroup = Items["ЛицевойСчет"+vIndexStr+"Group"];
	vFolioGroup.Visible = False;
	//vFolioFooter = Items["ЛицевойСчет"+vIndexStr+"FooterDecoration"];
	//vFolioFooter.Hyperlink = True;
	vCommandItem = Items["FormFolioCommand"+vIndexStr];
	vCommandItem.Check = False;
	If Items.EmptyPageTable.Visible Тогда
		Items.EmptyPageTable1.Visible = True;
	Else
		Items.EmptyPageTable1.Visible = False;
	EndIf;
	Items.EmptyPageTable.Visible = True;
КонецПроцедуры //FolioDeleteDecorationClick

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура FolioFooterDecorationClick(pItem)
	vFP = Left(pItem.Name, StrLen(pItem.Name)-16);
	vIndexStr = Right(vFP, StrLen(vFP)-5);
	If Items.EmptyPageTable1.Visible Тогда
		Items.EmptyPageTable1.Visible = False;
		vFolioGroup = Items["ЛицевойСчет"+vIndexStr+"Group"];
		vFolioGroup.Visible = True;
		For vInd = 1 To PagesCount Do
			vCurrentFolioFooter = Items["ЛицевойСчет"+vInd+"FooterDecoration"];
			vCurrentFolioFooter.Hyperlink = True;
		EndDo;
	ElsIf Items.EmptyPageTable.Visible Тогда
		Items.EmptyPageTable.Visible = False;
		vFolioGroup = Items["ЛицевойСчет"+vIndexStr+"Group"];
		vFolioGroup.Visible = True;
		For vInd = 1 To PagesCount Do
			If НЕ Items["ЛицевойСчет"+vInd+"Group"].Visible Тогда
				vCurrentFolioFooter = Items["ЛицевойСчет"+vInd+"FooterDecoration"];
				vCurrentFolioFooter.Hyperlink = True;
			EndIf;
		EndDo;
	Else
		For vInd = 1 To PagesCount Do
			If Items["ЛицевойСчет"+vInd+"Group"].Visible Тогда
				vCurrentFolioGroup = Items["ЛицевойСчет"+vInd+"Group"];
				vCurrentFolioFooter = Items["ЛицевойСчет"+vInd+"FooterDecoration"];
			EndIf;
		EndDo;
		vCurrentFolioFooter.Hyperlink = True;
		//Делаем невидимой только последнюю группу фолио
		vCurrentFolioGroup.Visible = False;
		//делаем видимой выбранную группу
		vFolioGroup = Items["ЛицевойСчет"+vIndexStr+"Group"];
		vFolioGroup.Visible = True;
	EndIf;
	pItem.Hyperlink = False;
КонецПроцедуры //FolioFooterDecorationClick

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура FolioNumberDecorationClick(pItem)
	vFP = Left(pItem.Name, StrLen(pItem.Name)-16);
	vCurPageIndexStr = Right(vFP, StrLen(vFP)-5);
	vCL = New СписокЗначений;
	For Each vListItem In FoliosNumberList Do
		If String(vListItem.Value)<>vCurPageIndexStr Тогда
			vCl.Add(vListItem.Value, vListItem.Presentation,,vListItem.Picture);
		EndIf;
	EndDo;
	For vInd = 1 To PagesCount Do
		If Items["ЛицевойСчет"+vInd+"Group"].Visible Тогда
			vListItem = vCL.FindByValue(vInd);
			If vListItem<>Неопределено Тогда
				vCL.Delete(vListItem);
			EndIf;
		EndIf;
	EndDo;
	//vResultItem = Неопределено;

	ShowChooseFromList(Новый ОписаниеОповещения("FolioNumberDecorationClickЗавершение", ЭтотОбъект, Новый Структура("Items, vCurPageIndexStr", Items, vCurPageIndexStr)), vCl, pItem);
КонецПроцедуры

&НаКлиенте
Процедура FolioNumberDecorationClickЗавершение(SelectedItem, ДополнительныеПараметры) Экспорт
	
	Items = ДополнительныеПараметры.Items;
	vCurPageIndexStr = ДополнительныеПараметры.vCurPageIndexStr;
	
	
	vResultItem = SelectedItem;
	If vResultItem <> Неопределено Тогда
		vCurPageItem = Items["ЛицевойСчет"+vCurPageIndexStr+"Group"];
		vCurPageItem.Visible = False;
		//vCurPageDecoration = Items["ЛицевойСчет"+vCurPageIndexStr+"FooterDecoration"];
		//vCurPageDecoration.Hyperlink = True;
		vCommandItem = Items["FormFolioCommand"+vCurPageIndexStr];
		vCommandItem.Check = False;
		
		vNewPageItem = Items["ЛицевойСчет"+String(vResultItem.Value)+"Group"];
		vNewPageItem.Visible = True;
		//vNewPageDecoration = Items["ЛицевойСчет"+String(vResultItem.Value)+"FooterDecoration"];
		//vNewPageDecoration.Hyperlink = False;
		vNewPageCommandItem = Items["FormFolioCommand"+String(vResultItem.Value)];
		vNewPageCommandItem.Check = True;
	EndIf;

КонецПроцедуры //FolioNumberDecorationClick

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура FolioDocumentsDrag(pItem, pDragParameters, pStandardProcessing, pRow, pField)
	pStandardProcessing = False;
	If pDragParameters <> Неопределено And pDragParameters.Value.Count()>0 Тогда
		vTable = ЭтаФорма[pItem.Name];
		vPageIndex = Number(Right(pItem.Name, StrLen(pItem.Name)-14));
		vCurFolio = ЭтаФорма["PageFolio"+vPageIndex];
		//Try
			//BeginTransaction(DataLockControlMode.Managed);
			//vDoTransfer = False;
			vFolioFrom = Неопределено;
			For Each vArrayItem In pDragParameters.Value Do
				If TypeOf(vArrayItem.Ref)=Type("DocumentRef.Сторно") Or TypeOf(vArrayItem.Ref)=Type("DocumentRef.Акт") Тогда
					Continue;
				EndIf;
				If TypeOf(vArrayItem.Ref)=Type("DocumentRef.ПеремещениеДепозита") Or TypeOf(vArrayItem.Ref)=Type("DocumentRef.Платеж") Тогда
					//vDoTransfer = True;
					If vFolioFrom = Неопределено Тогда
						If TypeOf(vArrayItem.Ref)=Type("DocumentRef.ПеремещениеДепозита") Тогда
							If Left(vArrayItem.SumPresentation, 1) = "-" Тогда
								vFolioFrom = УпрСерверныеФункции.cmGetAttributeByRef(vArrayItem.Ref, "FolioTo");
							Else
								vFolioFrom = УпрСерверныеФункции.cmGetAttributeByRef(vArrayItem.Ref, "FolioFrom");
							EndIf;
						Else
							vFolioFrom = УпрСерверныеФункции.cmGetAttributeByRef(vArrayItem.Ref, "СчетПроживания");
						EndIf;
					EndIf;
					Continue;
				EndIf;
				vNewRow = vTable.Add();
				vNewRow.ДатаДок = vArrayItem.ДатаДок;
				vNewRow.IsPayment = vArrayItem.IsPayment;
				vNewRow.Ref = vArrayItem.Ref;
				vNewRow.Примечания = vArrayItem.Примечания;
				vNewRow.Услуга = vArrayItem.Услуга;
				vNewRow.Сумма = vArrayItem.Сумма;
				vNewRow.SumPresentation = vArrayItem.SumPresentation;
				//If TypeOf(vArrayItem.Ref)=Type("DocumentRef.DepositTransfer") Тогда
				//	AddNewTransactionToFolio(vCurFolio, vArrayItem.Ref, pItem.Name, Left(vArrayItem.SumPresentation, 1));
				//Else
				AddNewTransactionToFolio(vCurFolio, vArrayItem.Ref, pItem.Name);
				//EndIf;
			EndDo;
//			If vDoTransfer Тогда
//				//CreateDepositTransfer(vFolioFrom, vCurFolio);
//				vFrm = ПолучитьФорму("Document.ПеремещениеДепозита.Form.tcDocumentForm",, ЭтаФорма);
//				CopyFormData(DepositTransfer, vFrm.Object);
//				vFrm.Open();
//			EndIf;
			//CommitTransaction();
		//Except
		//	vErrorDescription = ErrorDescription();
		//	If TransactionActive() Тогда
		//		RollbackTransaction();
		//	EndIf;
		//	Return;
		//EndTry;
		DragIndex = vPageIndex;
		vTable.Sort("Date");
	EndIf;
КонецПроцедуры //FolioDocumentsDrag



//-----------------------------------------------------------------------------
&НаКлиенте
Процедура FolioDocumentsDragEnd(pItem, pDragParameters, pStandardProcessing)
	pStandardProcessing = False;
	If pDragParameters <> Неопределено And pDragParameters.Value.Count()>0 Тогда
		vTable = ЭтаФорма[pItem.Name];
		vPageIndex = Number(Right(pItem.Name, StrLen(pItem.Name)-14));
		For Each vItem In pDragParameters.Value Do
			If TypeOf(vItem.Ref)=Type("DocumentRef.Сторно") Or TypeOf(vItem.Ref)=Type("DocumentRef.Акт")  Тогда
				Continue;
			EndIf;
			vTable.Delete(vItem);
		EndDo;
		If ЗначениеЗаполнено(DragIndex) Тогда
			FillFolioPage(GetCurrentFolioStructure(DragIndex), DragIndex-1);
		EndIf;
		FillFolioPage(GetCurrentFolioStructure(vPageIndex), vPageIndex-1);
	EndIf;
КонецПроцедуры //FolioDocumentsDragEnd

//-----------------------------------------------------------------------------
&AtServer
Процедура AddNewTransactionToFolio(pFolio, pTransactionRef, pTableName = "")
	If НЕ ЗначениеЗаполнено(pFolio) Or НЕ ЗначениеЗаполнено(pTransactionRef) Тогда
		return;
	EndIf;
	//If TypeOf(pTransactionRef) = Type("DocumentRef.Payment") Тогда
		//vSum = pTransactionRef.Sum;
		//vFolioFrom = pTransactionRef.ЛицевойСчет;
		//vFolioTo = pFolio;
		////Storno
		//vNewDepositTransfer = Documents.DepositTransfer.CreateDocument();
		//vNewDepositTransfer.Fill(vFolioFrom);
		//vNewDepositTransfer.FolioTo = vFolioTo;
		//vNewDepositTransfer.pmFolioToOnChange();
		//vNewDepositTransfer.SumInFolioFromCurrency = vSum;
		//If vFolioTo.FolioCurrency <> vFolioFrom.FolioCurrency Тогда
		//	vNewDepositTransfer.SumInFolioToCurrency = Round(cmConvertCurrencies(vNewDepositTransfer.SumInFolioFromCurrency, vNewDepositTransfer.FolioFromCurrency, vNewDepositTransfer.FolioFromCurrencyExchangeRate, vNewDepositTransfer.FolioToCurrency, vNewDepositTransfer.FolioToCurrencyExchangeRate, vNewDepositTransfer.ExchangeRateDate, vNewDepositTransfer.Гостиница), 2);
		//Else
		//	vNewDepositTransfer.SumInFolioToCurrency = vSum;
		//EndIf;
		//If ЗначениеЗаполнено(pTransactionRef.Гостиница) And pTransactionRef.Гостиница.SplitFolioBalanceByPaymentSections Тогда
		//	vPSRow = vNewDepositTransfer.PaymentSections.Add();
		//	vPSRow.SumInFolioFromCurrency = vSum;
		//	If vFolioTo.FolioCurrency <> vFolioFrom.FolioCurrency Тогда
		//		vPSRow.SumInFolioToCurrency = Round(cmConvertCurrencies(vPSRow.SumInFolioFromCurrency, vNewDepositTransfer.FolioFromCurrency, vNewDepositTransfer.FolioFromCurrencyExchangeRate, vNewDepositTransfer.FolioToCurrency, vNewDepositTransfer.FolioToCurrencyExchangeRate, vNewDepositTransfer.ExchangeRateDate, vNewDepositTransfer.Гостиница), 2);
		//	Else
		//		vPSRow.SumInFolioToCurrency = vSum;
		//	EndIf;
		//EndIf;
		//vNewDepositTransfer.Write(DocumentWriteMode.Posting);
		//If ЗначениеЗаполнено(pTableName) Тогда
		//	vTable = ЭтаФорма[pTableName];
		//	vRow = vTable.Get(vTable.Count()-1);
		//	vRow.Ref = vNewDepositTransfer.Ref;
		//	vRow.Service = NStr("en='Deposit transfer';ru='Перенос дипозита';de='Übertragung des Deposits'");
		//EndIf;
	//ElsIf TypeOf(pTransactionRef) = Type("DocumentRef.DepositTransfer") Тогда
		//If pMinus = "-" Тогда
		//	vFolioFrom = pTransactionRef.FolioTo;
		//	vFolioFromSum = pTransactionRef.SumInFolioToCurrency;
		//Else
		//	vFolioFrom = pTransactionRef.FolioFrom;
		//	vFolioFromSum = pTransactionRef.SumInFolioFromCurrency;
		//EndIf;
		//vFolioToSum = pTransactionRef.SumInFolioToCurrency;
		//vFolioFrom = pTransactionRef.FolioFrom;
		//vFolioTo = pFolio;
		////Storno
		//vNewDepositTransfer = Documents.DepositTransfer.CreateDocument();
		//vNewDepositTransfer.Fill(vFolioFrom);
		//vNewDepositTransfer.FolioTo = vFolioTo;
		//vNewDepositTransfer.pmFolioToOnChange();
		//vNewDepositTransfer.SumInFolioFromCurrency = vSum;
		//If vFolioTo.FolioCurrency <> vFolioFrom.FolioCurrency Тогда
		//	vNewDepositTransfer.SumInFolioToCurrency = Round(cmConvertCurrencies(vNewDepositTransfer.SumInFolioFromCurrency, vNewDepositTransfer.FolioFromCurrency, vNewDepositTransfer.FolioFromCurrencyExchangeRate, vNewDepositTransfer.FolioToCurrency, vNewDepositTransfer.FolioToCurrencyExchangeRate, vNewDepositTransfer.ExchangeRateDate, vNewDepositTransfer.Гостиница), 2);
		//Else
		//	vNewDepositTransfer.SumInFolioToCurrency = vSum;
		//EndIf;
		//If ЗначениеЗаполнено(pTransactionRef.Гостиница) And pTransactionRef.Гостиница.SplitFolioBalanceByPaymentSections Тогда
		//	vPSRow = vNewDepositTransfer.PaymentSections.Add();
		//	vPSRow.SumInFolioFromCurrency = vSum;
		//	If vFolioTo.FolioCurrency <> vFolioFrom.FolioCurrency Тогда
		//		vPSRow.SumInFolioToCurrency = Round(cmConvertCurrencies(vPSRow.SumInFolioFromCurrency, vNewDepositTransfer.FolioFromCurrency, vNewDepositTransfer.FolioFromCurrencyExchangeRate, vNewDepositTransfer.FolioToCurrency, vNewDepositTransfer.FolioToCurrencyExchangeRate, vNewDepositTransfer.ExchangeRateDate, vNewDepositTransfer.Гостиница), 2);
		//	Else
		//		vPSRow.SumInFolioToCurrency = vSum;
		//	EndIf;
		//EndIf;
		//vNewDepositTransfer.Write(DocumentWriteMode.Posting);
		//If ЗначениеЗаполнено(pTableName) Тогда
		//	vTable = ЭтаФорма[pTableName];
		//	vRow = vTable.Get(vTable.Count()-1);
		//	vRow.Ref = vNewDepositTransfer.Ref;
		//	vRow.Service = NStr("en='Deposit transfer';ru='Перенос дипозита';de='Übertragung des Deposits'");
		//EndIf;
	//Else
		vTransactionObj = pTransactionRef.GetObject();
		If TypeOf(pTransactionRef) = Type("DocumentRef.Платеж") Тогда
			vSum = vTransactionObj.Сумма;
		EndIf;
		vTransactionObj.Fill(pFolio);
		vTransactionObj.SetNewNumber();
		If TypeOf(pTransactionRef) = Type("DocumentRef.Платеж") Тогда
			vTransactionObj.Сумма = vSum;
			vTransactionObj.SumInFolioCurrency = vSum;
			If ЗначениеЗаполнено(vTransactionObj.Гостиница) And vTransactionObj.Гостиница.SplitFolioBalanceByPaymentSections Тогда
				vTransactionObj.ОтделОплаты.Clear();
				vPSRow = vTransactionObj.ОтделОплаты.Add();
				vPSRow.Сумма = vSum;
				vTransactionObj.pmCalculateTotalsByPaymentSections();
			EndIf;
		EndIf;
		vTransactionObj.Write(DocumentWriteMode.Posting);
	//EndIf;
КонецПроцедуры //AddNewTransactionToFolio

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура FolioCommand(pCommand)
	vFolioCommandItem = Items["Form"+pCommand.Name];
	vIndexStr = Right(pCommand.Name, StrLen(pCommand.Name)-12);
	If vFolioCommandItem.Check Тогда
		vFolioCommandItem.Check = False;
		vFolioGroup = Items["ЛицевойСчет"+vIndexStr+"Group"];
		vFolioGroup.Visible = False;
		//vFolioFooter = Items["ЛицевойСчет"+vIndexStr+"FooterDecoration"];
		//vFolioFooter.Hyperlink = True;
		If Items.EmptyPageTable.Visible Тогда
			Items.EmptyPageTable1.Visible = True;
		Else
			Items.EmptyPageTable1.Visible = False;
		EndIf;
		Items.EmptyPageTable.Visible = True;
	Else
		If Items.EmptyPageTable1.Visible Тогда
			Items.EmptyPageTable1.Visible = False;
			vFolioGroup = Items["ЛицевойСчет"+vIndexStr+"Group"];
			vFolioGroup.Visible = True;
			For vInd = 1 To PagesCount Do
				vCurrentFolioCommand = Items["FormFolioCommand"+vInd];
				vCurrentFolioCommand.Check = False;
			EndDo;
		ElsIf Items.EmptyPageTable.Visible Тогда
			Items.EmptyPageTable.Visible = False;
			vFolioGroup = Items["ЛицевойСчет"+vIndexStr+"Group"];
			vFolioGroup.Visible = True;
			For vInd = 1 To PagesCount Do
				If НЕ Items["ЛицевойСчет"+vInd+"Group"].Visible Тогда
					vCurrentFolioCommand = Items["FormFolioCommand"+vInd];
					vCurrentFolioCommand.Check = False;
				EndIf;
			EndDo;
		Else
			For vInd = 1 To PagesCount Do
				If Items["ЛицевойСчет"+vInd+"Group"].Visible Тогда
					vCurrentFolioGroup = Items["ЛицевойСчет"+vInd+"Group"];
					vCurrentFolioCommand = Items["FormFolioCommand"+vInd];
				EndIf;
			EndDo;
			vCurrentFolioCommand.Check = False;
			//Делаем невидимой только последнюю группу фолио
			vCurrentFolioGroup.Visible = False;
			//делаем видимой выбранную группу
			vFolioGroup = Items["ЛицевойСчет"+vIndexStr+"Group"];
			vFolioGroup.Visible = True;
		EndIf;
		vFolioCommandItem.Check = True;
	EndIf;
КонецПроцедуры

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура AddFolioPageCommand(pCommand)
	If PagesCount = MaxPagesCount Тогда
		CreateNewPagesAndTables(PagesCount, 1);
	EndIf;
	If (WasPosted = False Or IsFormModified) Тогда
		vResult = ЭтаФорма.FormOwner.WriteAtServer();
		If ЗначениеЗаполнено(vResult) And vResult <> "Error" Тогда
			ShowMessageBox(Неопределено, vResult);
		ElsIf НЕ ЗначениеЗаполнено(vResult) Тогда
			CreateNewFolio(PagesCount+1);
		EndIf;         
	Else
		CreateNewFolio(PagesCount+1);
	EndIf;
КонецПроцедуры //AddFolioPageCommand
