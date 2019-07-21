&НаКлиенте
Процедура OnOpen(Cancel)
	If ЗначениеЗаполнено(УпрСерверныеФункции.cmGetCurrentUserAttribute("Контрагент")) Тогда
		ЭтаФорма.ReadOnly = True;
	EndIf;
	If НЕ УпрСерверныеФункции.cmCheckUserPermissionsAtServer("HavePermissionToManagePrices") Тогда
		ЭтаФорма.ReadOnly = True;
	EndIf;
	If НЕ УпрСерверныеФункции.cmCheckUserPermissionsAtServer("HavePermissionToApproveRoomRates") Тогда
		If Object.RoomRatesApproved Тогда
			ЭтаФорма.ReadOnly = True;
		EndIf;
	EndIf;
КонецПроцедуры
