//----------------------------------------------------------------------
&AtServer
Процедура OnCreateAtServer(pCancel, pStandardProcessing)
	PeriodFrom = BegOfMonth(CurrentDate());
	PeriodTo = EndOfDay(CurrentDate());
	If Report.SettingsComposer.Settings.DataParameters.Items.Find("qByCheckInDates").Value Тогда
		PeriodCheckType = Перечисления.SalesReportsPeriodCheckTypes.ByCheckInDates;
	ElsIf Report.SettingsComposer.Settings.DataParameters.Items.Find("qByCheckOutDates").Value Тогда
		PeriodCheckType = Перечисления.SalesReportsPeriodCheckTypes.ByCheckOutDates;
	Else
		PeriodCheckType = Перечисления.SalesReportsPeriodCheckTypes.ByChargeDates;
	EndIf;
	If ЗначениеЗаполнено(ПараметрыСеанса.ТекПользователь) And ЗначениеЗаполнено(ПараметрыСеанса.ТекПользователь.Контрагент) Тогда
		Customer = ПараметрыСеанса.ТекПользователь.Контрагент;
		Items.Контрагент.ReadOnly = True;
		Items.Контрагент.ClearButton = False;
		Contract = Customer.Договор;
		ServiceGroup = Customer.AgentCommissionServiceGroup;
	Else
		Customer = Report.SettingsComposer.Settings.DataParameters.Items.Find("qCustomer").Value;
		Contract = Report.SettingsComposer.Settings.DataParameters.Items.Find("qContract").Value;
	EndIf;
	GuestGroup = Report.SettingsComposer.Settings.DataParameters.Items.Find("qGuestGroup").Value;
	If ЗначениеЗаполнено(GuestGroup) Тогда
		Гостиница = GuestGroup.Owner;
	ElsIf ЗначениеЗаполнено(ЭтаФорма.Parameters.Гостиница) Тогда
		Гостиница = ЭтаФорма.Parameters.Гостиница;
	Else
		Гостиница = ПараметрыСеанса.ТекущаяГостиница;
	EndIf;
	cmSetSpreadsheetProtection(Items.Result);
КонецПроцедуры //OnCreateAtServer

//----------------------------------------------------------------------
&НаКлиенте
Процедура PeriodFromOnChange(pItem)
	FillReportDataParameters();
КонецПроцедуры //PeriodFromOnChange

//----------------------------------------------------------------------
&НаКлиенте
Процедура PeriodToOnChange(pItem)
	FillReportDataParameters();
КонецПроцедуры //PeriodToOnChange

//----------------------------------------------------------------------
&НаКлиенте
Процедура HotelOnChange(pItem)
	FillReportDataParameters();
КонецПроцедуры //HotelOnChange

//----------------------------------------------------------------------
&НаКлиенте
Процедура CustomerOnChange(pItem)
	FillReportDataParameters();
КонецПроцедуры //CustomerOnChange

//----------------------------------------------------------------------
&НаКлиенте
Процедура ContractOnChange(pItem)
	FillReportDataParameters();
КонецПроцедуры //ContractOnChange

//----------------------------------------------------------------------
&НаКлиенте
Процедура GuestGroupOnChange(pItem)
	FillReportDataParameters();
КонецПроцедуры //GuestGroupOnChange

//----------------------------------------------------------------------
&НаКлиенте
Процедура ServiceGroupOnChange(pItem)
	FillReportDataParameters();
КонецПроцедуры //ServiceGroupOnChange

//----------------------------------------------------------------------
&НаКлиенте
Процедура PeriodCheckTypeOnChange(pItem)
	FillReportDataParameters();
КонецПроцедуры //PeriodCheckTypeOnChange

//----------------------------------------------------------------------
&НаКлиенте
Процедура ChoosePeriod(pCommand)
	vChoosePeriodDialog = New StandardPeriodEditDialog();
	vChoosePeriodDialog.Show(Новый ОписаниеОповещения("ChoosePeriodЗавершение", ЭтотОбъект, Новый Структура("vChoosePeriodDialog", vChoosePeriodDialog)));
КонецПроцедуры

&НаКлиенте
Процедура ChoosePeriodЗавершение(Period, ДополнительныеПараметры) Экспорт
	
	vChoosePeriodDialog = ДополнительныеПараметры.vChoosePeriodDialog;
	
	
	If Period Тогда
		PeriodFrom = vChoosePeriodDialog.Period.StartDate;
		PeriodTo = vChoosePeriodDialog.Period.EndDate;
		FillReportDataParameters();
	EndIf;

КонецПроцедуры //ChoosePeriod

//----------------------------------------------------------------------
&AtServer
Процедура FillReportDataParameters()
	Report.SettingsComposer.Settings.DataParameters.Items.Find("qPeriod").Value = CurrentDate();
	Report.SettingsComposer.Settings.DataParameters.Items.Find("qPeriod").Use = True;
	Report.SettingsComposer.Settings.DataParameters.Items.Find("qHotel").Value = Гостиница;
	Report.SettingsComposer.Settings.DataParameters.Items.Find("qHotel").Use = True;
	Report.SettingsComposer.Settings.DataParameters.Items.Find("qCustomer").Value = Customer;
	Report.SettingsComposer.Settings.DataParameters.Items.Find("qCustomer").Use = True;
	Report.SettingsComposer.Settings.DataParameters.Items.Find("qCustomerIsEmpty").Value = НЕ ЗначениеЗаполнено(Customer);
	Report.SettingsComposer.Settings.DataParameters.Items.Find("qCustomerIsEmpty").Use = True;
	Report.SettingsComposer.Settings.DataParameters.Items.Find("qContract").Value = Contract;
	Report.SettingsComposer.Settings.DataParameters.Items.Find("qContract").Use = True;
	Report.SettingsComposer.Settings.DataParameters.Items.Find("qContractIsEmpty").Value = НЕ ЗначениеЗаполнено(Contract);
	Report.SettingsComposer.Settings.DataParameters.Items.Find("qContractIsEmpty").Use = True;
	Report.SettingsComposer.Settings.DataParameters.Items.Find("qGuestGroup").Value = GuestGroup;
	Report.SettingsComposer.Settings.DataParameters.Items.Find("qGuestGroup").Use = True;
	Report.SettingsComposer.Settings.DataParameters.Items.Find("qGuestGroupIsEmpty").Value = НЕ ЗначениеЗаполнено(GuestGroup);
	Report.SettingsComposer.Settings.DataParameters.Items.Find("qGuestGroupIsEmpty").Use = True;
	Report.SettingsComposer.Settings.DataParameters.Items.Find("qByCheckInDates").Value = False;
	Report.SettingsComposer.Settings.DataParameters.Items.Find("qByCheckOutDates").Value = False;
	If PeriodCheckType = УпрСерверныеФункции.cmGetEnumItem("SalesReportsPeriodCheckTypes", "ByCheckInDates") Тогда
		Report.SettingsComposer.Settings.DataParameters.Items.Find("qByCheckInDates").Value = True;
		Report.SettingsComposer.Settings.DataParameters.Items.Find("qByCheckOutDates").Value = False;
	ElsIf PeriodCheckType = УпрСерверныеФункции.cmGetEnumItem("SalesReportsPeriodCheckTypes", "ByCheckOutDates") Тогда
		Report.SettingsComposer.Settings.DataParameters.Items.Find("qByCheckInDates").Value = False;
		Report.SettingsComposer.Settings.DataParameters.Items.Find("qByCheckOutDates").Value = True;
	EndIf;
	Report.SettingsComposer.Settings.DataParameters.Items.Find("qByCheckInDates").Use = True;
	Report.SettingsComposer.Settings.DataParameters.Items.Find("qByCheckOutDates").Use = True;
	Report.SettingsComposer.Settings.DataParameters.Items.Find("qPeriodFrom").Value = BegOfDay(PeriodFrom);
	Report.SettingsComposer.Settings.DataParameters.Items.Find("qPeriodFrom").Use = True;
	Report.SettingsComposer.Settings.DataParameters.Items.Find("qPeriodTo").Value = EndOfDay(PeriodTo);
	Report.SettingsComposer.Settings.DataParameters.Items.Find("qPeriodTo").Use = True;
	If PeriodCheckType = УпрСерверныеФункции.cmGetEnumItem("SalesReportsPeriodCheckTypes", "ByCheckInDates") Or 
	   PeriodCheckType = УпрСерверныеФункции.cmGetEnumItem("SalesReportsPeriodCheckTypes", "ByCheckOutDates") Тогда
		Report.SettingsComposer.Settings.DataParameters.Items.Find("qServicesPeriodFrom").Value = '00010101';
		Report.SettingsComposer.Settings.DataParameters.Items.Find("qServicesPeriodTo").Value = EndOfDay('39991231');
		Report.SettingsComposer.Settings.DataParameters.Items.Find("qForecastPeriodFrom").Value = BegOfDay(CurrentDate());
		Report.SettingsComposer.Settings.DataParameters.Items.Find("qForecastPeriodTo").Value = EndOfDay('39991231');
	Else
		Report.SettingsComposer.Settings.DataParameters.Items.Find("qServicesPeriodFrom").Value = BegOfDay(PeriodFrom);
		Report.SettingsComposer.Settings.DataParameters.Items.Find("qServicesPeriodTo").Value = EndOfDay(PeriodTo);
		Report.SettingsComposer.Settings.DataParameters.Items.Find("qForecastPeriodFrom").Value = Max(BegOfDay(PeriodFrom), BegOfDay(CurrentDate()));
		Report.SettingsComposer.Settings.DataParameters.Items.Find("qForecastPeriodTo").Value = ?(ЗначениеЗаполнено(PeriodTo), Max(PeriodTo, EndOfDay(CurrentDate()-24*3600)), '00010101');
	EndIf;
	Report.SettingsComposer.Settings.DataParameters.Items.Find("qServicesPeriodFrom").Use = True;
	Report.SettingsComposer.Settings.DataParameters.Items.Find("qServicesPeriodTo").Use = True;
	Report.SettingsComposer.Settings.DataParameters.Items.Find("qForecastPeriodFrom").Use = True;
	Report.SettingsComposer.Settings.DataParameters.Items.Find("qForecastPeriodTo").Use = True;
	vUseServicesList = False;
	vServicesList = New СписокЗначений();
	If ЗначениеЗаполнено(ServiceGroup) Тогда
		If НЕ ServiceGroup.IncludeAll Тогда
			vUseServicesList = True;
			vServicesList.LoadValues(ServiceGroup.Услуги.UnloadColumn("Услуга"));
		EndIf;
	EndIf;
	Report.SettingsComposer.Settings.DataParameters.Items.Find("qUseServicesList").Value = vUseServicesList;
	Report.SettingsComposer.Settings.DataParameters.Items.Find("qUseServicesList").Use = True;
	Report.SettingsComposer.Settings.DataParameters.Items.Find("qServicesList").Value = vServicesList;
	Report.SettingsComposer.Settings.DataParameters.Items.Find("qServicesList").Use = True;
	OnChangingParamters();
КонецПроцедуры //FillReportDataParameters

//----------------------------------------------------------------------
&НаКлиенте
Процедура OnOpen(pCancel)
	FillReportDataParameters();
КонецПроцедуры //OnOpen

//----------------------------------------------------------------------
&НаКлиенте
Процедура BeforeClose(pCancel, pStandardProcessing)
	VariantModified = False;
КонецПроцедуры //BeforeClose

//----------------------------------------------------------------------
&AtServer
Процедура OnChangingParamters()
	Items.Result.StatePresentation.AdditionalShowMode = AdditionalShowMode.Irrelevance;
	Items.Result.StatePresentation.Text = NStr("en='Parameters have been changed. Please, click on ""Generate"" button';ru='Параметры были изменены. Нажмите на кнопку ""Сформировать""';de='Parameter wurden verändert. Betätigen Sie die Schaltfläche ""Erzeugen""'");
	Items.Result.StatePresentation.Visible = True;
КонецПроцедуры //OnChangingParameters
