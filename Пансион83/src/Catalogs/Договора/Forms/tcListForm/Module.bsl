//-----------------------------------------------------------------------------
&AtServer
Процедура OnCreateAtServer(Cancel, StandardProcessing)
	// Set Контрагент filter if necessary
	If ЗначениеЗаполнено(ЭтаФорма.Parameters.Filter.Owner) Тогда
		vOwnerFilter = List.Filter.Items.Add(Type("DataCompositionFilterItem"));
		vOwnerFilter.LeftValue = New DataCompositionField("Owner");
		vOwnerFilter.ComparisonType = DataCompositionComparisonType.Equal;
		vOwnerFilter.RightValue = ЭтаФорма.Parameters.Filter.Owner;
		vOwnerFilter.Use = True;
		Items.Owner.Visible = False;
	EndIf;
	// Filter by current hotel
	If ЗначениеЗаполнено(ПараметрыСеанса.ТекущаяГостиница) Тогда
		vFilter = List.Filter.Items.Add(Type("DataCompositionFilterItem"));
		vFilter.LeftValue = New DataCompositionField("Гостиница");
		vFilter.ComparisonType = DataCompositionComparisonType.InList;
		vList = New СписокЗначений;
		vList.Add(Справочники.Гостиницы.EmptyRef());
		vList.Add(ПараметрыСеанса.ТекущаяГостиница);
		vFilter.RightValue = vList;
		vFilter.Use = True;
	EndIf;
КонецПроцедуры //OnCreateAtServer
