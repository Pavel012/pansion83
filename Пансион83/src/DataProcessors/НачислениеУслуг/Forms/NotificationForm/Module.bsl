//--------------------------------------------------------------------------
&НаКлиенте
Процедура OnOpen(pCancel)
	OnOpenAtServer();
КонецПроцедуры //OnOpen

//--------------------------------------------------------------------------
&AtServer
Процедура OnOpenAtServer()
	vChargesFailCount = 0;
	vChargesSuccessCount = 0;
	vIsNotOneFolio = False;
	ErrorsString = NStr("en='НЕ posted transactions:';ru='Непроведенные транзакции: ';de='Nicht durchgeführte Transaktionen: '")+Chars.LF;
	Sum = 0;
	For Each vRow In Object.НачислениеУслуг Do
		If vRow.Error Тогда
			vChargesFailCount = vChargesFailCount + 1;
			If ЗначениеЗаполнено(vRow.СчетПроживания) Тогда
				ErrorsString = ErrorsString + String(vChargesFailCount)+". "+Format(vRow.ДатаДок, "DF='dd.MM.yyyy'")+" "+
				?(ЗначениеЗаполнено(vRow.Клиент), TrimAll(vRow.Клиент), "")+
				?(ЗначениеЗаполнено(vRow.НомерРазмещения),NStr("en=' ГруппаНомеров: ';ru=' Номер: ';de=' Zimmer: '")+TrimAll(vRow.НомерРазмещения), "")+
				NStr("en=' ЛицевойСчет: ';ru=' Фолио: ';de=' ЛицевойСчет: '")+TrimAll(vRow.СчетПроживания.НомерДока)+" ("+TrimAll(vRow.Услуга)+")"+Chars.LF;
			Else
				ErrorsString = ErrorsString + String(vChargesFailCount)+". "+Format(vRow.ДатаДок, "DF='dd.MM.yyyy'")+" "+
				?(ЗначениеЗаполнено(vRow.Клиент), TrimAll(vRow.Клиент), "")+
				?(ЗначениеЗаполнено(vRow.НомерРазмещения),NStr("en=' ГруппаНомеров: ';ru=' Номер: ';de=' Zimmer: '")+TrimAll(vRow.НомерРазмещения), "")+" ("+TrimAll(vRow.Услуга)+")"+Chars.LF;
			EndIf;
		Else
			vChargesSuccessCount = vChargesSuccessCount + 1;
			If ЗначениеЗаполнено(vRow.СчетПроживания) Тогда
				If vRow.СчетПроживания <> Object.НачислениеУслуг.Get(0).СчетПроживания Тогда
					vIsNotOneFolio = True;
				EndIf;
			EndIf;
			Sum = Sum + vRow.Сумма;
		EndIf;
	EndDo;	
	Items.MainMessage.Title = "Успешно начислено "+vChargesSuccessCount+"/"+String(vChargesFailCount+vChargesSuccessCount)+" транзакций на сумму: "+Format(Sum, "ND=17; NFD=2; NZ=");
	If vChargesFailCount > 0 Тогда
		Items.AdditionalErrorsTabulation.Visible = False;
		Items.OpenErrorList.Visible = True;
	Else
		If НЕ vIsNotOneFolio Тогда
			Items.AdditionalPaymentTabulation.Visible = False;
			Items.DoPayment.Visible = True;
		EndIf;
	EndIf;
КонецПроцедуры //OnOpenAtServer

//--------------------------------------------------------------------------
&НаКлиенте
Процедура CloseButton(pCommand)
	ЭтаФорма.Close();
	If НЕ ЭтаФорма.FormOwner.Window.IsMain Тогда
		ЭтаФорма.FormOwner.Close();
	EndIf;
КонецПроцедуры //Close

//--------------------------------------------------------------------------
&НаКлиенте
Процедура DoPayment(pCommand)
	// Create new payment
	УпрСерверныеФункции.cmWriteLogEventAtServer(NStr("en='Document.Create';ru='Документ.СозданиеНового';de='Document.Create'"),, "Documents.Платеж", "Documents.Платеж.EmptyRef()", NStr("en='Create new';ru='Создание нового';de='Erstellung eines neuen'"));
	OpenForm("Document.Платеж.Form.tcDocumentForm", New Structure("Document, Сумма", Object.НачислениеУслуг.Get(0).СчетПроживания, Sum, ЭтаФорма),,,,, Новый ОписаниеОповещения("DoPaymentЗавершение", ЭтотОбъект), РежимОткрытияОкнаФормы.БлокироватьВесьИнтерфейс);
КонецПроцедуры

&НаКлиенте
Процедура DoPaymentЗавершение(Result, ДополнительныеПараметры) Экспорт
	
	CloseButton(Неопределено);

КонецПроцедуры //DoPayment

//--------------------------------------------------------------------------
&НаКлиенте
Процедура OpenErrorList(pCommand)
	Items.ErrorsString.Visible = НЕ Items.ErrorsString.Visible;
КонецПроцедуры //OpenErrorList

