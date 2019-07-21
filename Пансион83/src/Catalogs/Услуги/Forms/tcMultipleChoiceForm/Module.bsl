//--------------------------------------------------------------------------
&НаКлиенте
Процедура Choose(pCommand)
	vServicesArray = GetServicesArray();
	NotifyChoice(vServicesArray);
КонецПроцедуры //Choose

//--------------------------------------------------------------------------
&AtServer
Function GetServicesArray()
	vServicesArray = New Array;
	For Each vServiceRow In ServicesTable Do
		If vServiceRow.Check And vServiceRow.Количество > 0 Тогда
			vRowStruc = New Structure;
			vRowStruc.Вставить("Услуга", vServiceRow.Услуга);
			vRowStruc.Вставить("Цена", vServiceRow.Цена);
			vRowStruc.Вставить("Количество", vServiceRow.Количество);
			vServicesArray.Add(vRowStruc);
		EndIf;
	EndDo;
	Return vServicesArray;
EndFunction //GetServicesArray

//--------------------------------------------------------------------------
&НаКлиенте
Процедура ServicesTableCheckOnChange(pItem)
	vCurData = pItem.Parent.Parent.CurrentData;
	If vCurData <> Неопределено Тогда
		If vCurData.Check Тогда
			If НЕ ЗначениеЗаполнено(vCurData.Количество) Тогда
				vCurData.Количество = 1;
			EndIf;
			pItem.Parent.Parent.CurrentItem = Items.ServicesTableQuantity;
		Else
			vCurData.Количество = 0;
		EndIf;
	EndIf;
КонецПроцедуры //ServicesTableCheckOnChange

//--------------------------------------------------------------------------
&AtServer
Процедура OnCreateAtServer(pCancel, pStandardProcessing)
	Parameters.Property("ТипКлиента", ClientType);
	vIsMultiple = True;
	Parameters.Property("MultipleChoice", vIsMultiple);
	If НЕ vIsMultiple Тогда
		Items.ServicesTableCheck.Visible = False;
		Items.ServicesTable.SelectionMode = TableSelectionMode.SingleRow;
	EndIf;
	FillServicesTable();
КонецПроцедуры //OnCreateAtServer

//--------------------------------------------------------------------------
&AtServer
Процедура FillServicesTable()
	// Build list of services
	vServices = New СписокЗначений();
	vQry = New Query;
	vQry.Text = 
	"SELECT
	|	Услуги.Ref
	|FROM
	|	Catalog.Услуги AS Услуги
	|WHERE
	|	NOT Услуги.IsFolder
	|	AND NOT Услуги.DeletionMark
	|	AND Услуги.Гостиница IN (&qHotelList)";
	vList = New СписокЗначений;
	vList.Add(Справочники.Гостиницы.EmptyRef());
	vList.Add(ПараметрыСеанса.ТекущаяГостиница);
	vQry.SetParameter("qHotelList", vList);
	vQryResult = vQry.Execute().Choose();
	While vQryResult.Next() Do
		vServices.Add(vQryResult.Ref);
	EndDo;
	// Get table with active orders for the ГруппаНомеров rates in the list
	vPrices = cmGetServicePrices(vServices, ПараметрыСеанса.ТекущаяГостиница, CurrentDate(), ClientType);
	For Each vListItem In vServices Do
		vService = vListItem.Value;
		vNewRow = ServicesTable.Add();
		vNewRow.Check = False;
		vNewRow.Услуга = vService;
		vPricesRow = vPrices.Find(vService, "Услуга");
		vPriceStr = "";
		vNewRow.Цена = 0;
		If vPricesRow <> Неопределено Тогда
			vPriceStr = cmFormatSum(vPricesRow.Цена, vPricesRow.Валюта, "NZ=---");
			vNewRow.Цена = vPricesRow.Цена;
		EndIf;
		vNewRow.PriceStr = vPriceStr;
		vNewRow.Количество = 0;
	EndDo;
КонецПроцедуры //FillServicesTable

//--------------------------------------------------------------------------
&НаКлиенте
Процедура ClientTypeOnChange(pItem)
	FillServicesTable();
КонецПроцедуры //ClientTypeOnChange

//--------------------------------------------------------------------------
&НаКлиенте
Процедура ServicesTableSelection(pItem, pSelectedRow, pField, pStandardProcessing)
	If pItem.CurrentItem.Name <> "ServicesTableQuantity" Тогда
		vCurData = pItem.CurrentData;
		If vCurData <> Неопределено Тогда
			vCurData.Check = True;
			If vCurData.Количество = 0 Тогда
				vCurData.Количество = 1;
			EndIf;
			vServicesArray = GetServicesArray();
			NotifyChoice(vServicesArray);
		EndIf;
	EndIf;
КонецПроцедуры //ServicesTableSelection
