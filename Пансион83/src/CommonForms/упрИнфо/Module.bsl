//--------------------------------------------------------------------------
&AtServer
Процедура OnCreateAtServer(pCancel, pStandardProcessing)
	Try
		InfoLink = Parameters.InfoLink;
	Except
		InfoLink = "";
	EndTry;
	Try
		PictureLink = Parameters.PictureLink;
	Except
		PictureLink = "";
	EndTry;
	Try
		RoomType = Parameters.ТипНомера;
	Except
	
		
	EndTry;
	If ЗначениеЗаполнено(RoomType) Тогда
		Title = NStr("en='Information about the type of ГруппаНомеров: ';ru='Информация о типе номера: ';de='Zimmertypinformation: '") + String(RoomType);
	Else
		Title = NStr("en='Information';ru='Информация';de='Information'");
	EndIf;
КонецПроцедуры //OnCreateAtServer

//--------------------------------------------------------------------------
&НаКлиенте
Процедура OnOpen(pCancel)
	If ЗначениеЗаполнено(PictureLink) Тогда
		vStorageAddress = "";
		
		BeginPutFile(Новый ОписаниеОповещения("OnOpenЗавершение", ЭтотОбъект, Новый Структура("vStorageAddress", vStorageAddress)), vStorageAddress, PictureLink, False, UUID);
        Возврат;
	Else
		Items.PictureField.Visible = False;
	EndIf;
	OnOpenФрагмент(Items);
КонецПроцедуры

&НаКлиенте
Процедура OnOpenЗавершение(Result, Адрес, ВыбранноеИмяФайла, ДополнительныеПараметры) Экспорт
	
	vStorageAddress = ДополнительныеПараметры.vStorageAddress;
	
	
	If Result Тогда
		vFileInTempStorage = vStorageAddress;
	EndIf;
	PictureField = vFileInTempStorage;
	
	OnOpenФрагмент(Items);

КонецПроцедуры

&НаКлиенте
Процедура OnOpenФрагмент(Знач Items)
	
	Перем vRemarks;
	
	If ЗначениеЗаполнено(InfoLink) Тогда
		HTMLDocument = InfoLink;
	Else
		Items.HTMLDocument.Visible = False;
	EndIf;
	vRemarks = УпрСерверныеФункции.cmGetAttributeByRef(RoomType, "Примечания");
	If ЗначениеЗаполнено(vRemarks) Тогда
		Remarks = vRemarks;
	ElsIf НЕ ЗначениеЗаполнено(InfoLink) Тогда
		Items.Примечания.Visible = False;
	Else
		Items.Примечания.Visible = True;
	EndIf;
	
КонецПроцедуры
 //OnOpen
