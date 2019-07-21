//---------------------------------------------------------------------------------------------
&AtServer
Процедура OnCreateAtServer(pCancel, pStandardProcessing)
	// Default hotel
	If ЗначениеЗаполнено(ПараметрыСеанса.ТекущаяГостиница) Тогда
		vFilterItem = List.Filter.Items.Add(Type("DataCompositionFilterItem"));
		vFilterItem.LeftValue = List.Filter.FilterAvailableFields.Items.Find("Owner").Field;
		vFilterItem.ComparisonType = DataCompositionComparisonType.Equal;
		vFilterItem.RightValue = ПараметрыСеанса.ТекущаяГостиница;
	EndIf;
	vOrderItem = List.Order.Items.Add(Type("DataCompositionOrderItem"));
	vOrderItem.Field = List.Filter.FilterAvailableFields.Items.Find("ПорядокСортировки").Field;
	vOrderItem.OrderType = DataCompositionSortDirection.Asc;
КонецПроцедуры //OnCreateAtServer
