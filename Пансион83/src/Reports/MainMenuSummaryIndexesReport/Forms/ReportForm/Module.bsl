//----------------------------------------------------------------------
&AtServer
Процедура OnCreateAtServer(pCancel, pStandardProcessing)
	PeriodFrom = Report.SettingsComposer.Settings.DataParameters.Items.Find("BeginOfPeriod").Value.ДатаДок;
	PeriodTo = Report.SettingsComposer.Settings.DataParameters.Items.Find("EndOfPeriod").Value.ДатаДок;
	vHotel = Неопределено;
	ЭтаФорма.Parameters.Property("Гостиница", vHotel);
	If ЗначениеЗаполнено(vHotel) Тогда
		Гостиница = vHotel;
	Else
		Гостиница = ПараметрыСеанса.ТекущаяГостиница;
	EndIf;
	cmSetSpreadsheetProtection(Items.Result);
	vBegOfPeriod = Неопределено;
	ЭтаФорма.Parameters.Property("BegOfPeriod", vBegOfPeriod);
	If ЗначениеЗаполнено(vBegOfPeriod) Тогда
		PeriodFrom = vBegOfPeriod;
	EndIf;
	vEndOfPeriod = Неопределено;
	ЭтаФорма.Parameters.Property("EndOfPeriod", vEndOfPeriod);
	If ЗначениеЗаполнено(vEndOfPeriod) Тогда
		PeriodTo = vEndOfPeriod;
	EndIf;
КонецПроцедуры //OnCreateAtServer

//----------------------------------------------------------------------
&НаКлиенте
Процедура PeriodFromOnChange(pItem)
	Report.SettingsComposer.Settings.DataParameters.SetParameterValue("BeginOfPeriod", PeriodFrom);
	ChangePeriodFromAtServer();
КонецПроцедуры //PeriodFromOnChange

//----------------------------------------------------------------------
&AtServer
Процедура ChangePeriodFromAtServer()
	Report.SettingsComposer.Settings.DataParameters.SetParameterValue("BeginOfPeriod", PeriodFrom);
	OnChangingParamters();
КонецПроцедуры //ChangePeriodFromAtServer

//----------------------------------------------------------------------
&НаКлиенте
Процедура PeriodToOnChange(pItem)
	Report.SettingsComposer.Settings.DataParameters.SetParameterValue("EndOfPeriod", PeriodTo);
	ChangePeriodToAtServer();
КонецПроцедуры //PeriodToOnChange

//----------------------------------------------------------------------
&AtServer
Процедура ChangePeriodToAtServer()
	Report.SettingsComposer.Settings.DataParameters.SetParameterValue("EndOfPeriod", PeriodTo);
	OnChangingParamters();
КонецПроцедуры //ChangePeriodToAtServer

//----------------------------------------------------------------------
&AtServer
Процедура OnChangingParamters()
	Items.Result.StatePresentation.AdditionalShowMode = AdditionalShowMode.Irrelevance;
	Items.Result.StatePresentation.Text = NStr("en='Parameters have been changed. Please, click on ""Generate"" button';ru='Параметры были изменены. Нажмите на кнопку ""Сформировать""';de='Parameter wurden verändert. Betätigen Sie die Schaltfläche ""Erzeugen""'");
	Items.Result.StatePresentation.Visible = True;
КонецПроцедуры //OnChangingParameters

//----------------------------------------------------------------------
&НаКлиенте
Процедура HotelOnChange(pItem)
	Report.SettingsComposer.Settings.DataParameters.SetParameterValue("Гостиница", Гостиница);
	ChangeHotelAtServer();
КонецПроцедуры //HotelOnChange

//----------------------------------------------------------------------
&AtServer
Процедура ChangeHotelAtServer()
	Report.SettingsComposer.Settings.DataParameters.SetParameterValue("Гостиница", Гостиница);
	OnChangingParamters();
КонецПроцедуры //ChangeHotelAtServer

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
		PeriodFromOnChange(Items.ПериодС);
		PeriodTo = vChoosePeriodDialog.Period.EndDate;
		PeriodToOnChange(Items.ПериодПо);
	EndIf;

КонецПроцедуры //ChoosePeriod

//----------------------------------------------------------------------
&НаКлиенте
Процедура OnOpen(pCancel)
	Report.SettingsComposer.Settings.DataParameters.SetParameterValue("BeginOfPeriod", PeriodFrom);
	Report.SettingsComposer.Settings.DataParameters.SetParameterValue("EndOfPeriod", PeriodTo);
	Report.SettingsComposer.Settings.DataParameters.SetParameterValue("Гостиница", Гостиница);
КонецПроцедуры //OnOpen

//----------------------------------------------------------------------
&НаКлиенте
Процедура BeforeClose(pCancel, pStandardProcessing)
	VariantModified = False;
КонецПроцедуры //BeforeClose
