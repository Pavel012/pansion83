//----------------------------------------------
&НаКлиенте
Процедура Cancel(pCommand)
	ЭтаФорма.Close()
КонецПроцедуры //Cancel

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура OK(pCommand)
	// Check user input
	If НЕ ЗначениеЗаполнено(Date) Тогда
		ShowMessageBox(Новый ОписаниеОповещения("OKЗавершение", ЭтотОбъект), NStr("en='Date should be entered!';ru='Дата должна быть указана!';de='Das Datum muss angegeben sein!'"));
		Return;
	EndIf;
	// Build return parameter
	vDateTime = AddTimeAtServer();
	ЭтаФорма.Close(vDateTime);
КонецПроцедуры

&НаКлиенте
Процедура OKЗавершение(ДополнительныеПараметры) Экспорт
	
	CurrentItem = Items.ДатаДок;

КонецПроцедуры //OK

//-----------------------------------------------------------------------------
&AtServer
Function AddTimeAtServer()
	vDateTime = cmAddTime(Date, Time, False);
	Return vDateTime;
EndFunction //AddTimeAtServer

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура TimeStartChoice(pItem, pChoiceData, pStandardProcessing)
	pStandardProcessing = False;
	vList = TimeStartChoiceAtServer();
	//vDayTime = Неопределено;

	ShowChooseFromList(Новый ОписаниеОповещения("TimeStartChoiceЗавершение", ЭтотОбъект), vList, pitem);
КонецПроцедуры

&НаКлиенте
Процедура TimeStartChoiceЗавершение(SelectedItem, ДополнительныеПараметры) Экспорт
	
	vDayTime = SelectedItem;
	If vDayTime <> Неопределено Тогда
		Time = vDayTime.Value;
	EndIf;

КонецПроцедуры //TimeStartChoice

//-----------------------------------------------------------------------------
&AtServer
Function TimeStartChoiceAtServer()
	vDayTimes = cmGetDayTimes();
	vList = New СписокЗначений();
	For Each vDayTimesRow In vDayTimes Do
		vList.Add(vDayTimesRow.Time, vDayTimesRow.Presentation);
	EndDo;
	Return vList;
EndFunction //SelTimeStartChoice

//-----------------------------------------------------------------------------
&НаКлиенте
Процедура OnOpen(pCancel)
	// Check if is in protected mode
	If IsProtected Тогда
		Items.ДатаДок.ReadOnly = True;
		Items.Time.ReadOnly = True;
	EndIf;
	If DateIsProtected Тогда
		Items.ДатаДок.ReadOnly = True;
	EndIf;
КонецПроцедуры //OnOpen

