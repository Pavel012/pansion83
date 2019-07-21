//-----------------------------------------------------------------------------
Процедура mmLoadFromDictionary() Экспорт
	Try
		BeginTransaction(DataLockControlMode.Managed);
		vIDDocsList = Справочники.УдостоверениеЛичности.GetTemplate("UMMSCodesRu");
		vCount = vIDDocsList.TableHeight - 1;
		For i = 2 To (vCount + 1) Do
			vDocCode = СокрЛП(vIDDocsList.Area(i, 3, i, 3).Text);
			If IsBlankString(vDocCode) Тогда
				Break;
			EndIf;
			If vDocCode = "10" Тогда
				vDocCode = "ИП";
			EndIf;
			If vDocCode = "13" Тогда
				vDocCode = "УБ";
			EndIf;
			If StrLen(vDocCode) = 1 Тогда
				vDocCode = "0" + vDocCode;
			EndIf;
			
			vDoLoad = СокрЛП(vIDDocsList.Area(i, 4, i, 4).Text);
			If vDoLoad <> "True" Тогда
				Continue;
			EndIf;
			
			vDocRef = Справочники.УдостоверениеЛичности.FindByCode(vDocCode);
			If ЗначениеЗаполнено(vDocRef) Тогда
				vDocObj = vDocRef.GetObject();
			Else
				vDocObj = Справочники.УдостоверениеЛичности.CreateItem();
				vDocObj.Code = vDocCode;
			EndIf;
			
			vDocObj.Description = СокрЛП(vIDDocsList.Area(i, 2, i, 2).Text);
			vDocObj.ExternalCode = СокрЛП(vIDDocsList.Area(i, 1, i, 1).Text);
			
			vDocObj.Write();
		EndDo;
		CommitTransaction();
		Message(NStr("en='Identity document types have been processed';ru='Обновлена информация о видах документов удостоверяющих личность';de='Informationen wurden aktualisiert'"), MessageStatus.Information);
	Except
		vErrorDescription = ErrorDescription();
		RollbackTransaction();
		ВызватьИсключение vErrorDescription;
	EndTry;
КонецПроцедуры //mmLoadFromDictionary
