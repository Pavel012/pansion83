//-----------------------------------------------------------------------------
Процедура BeforeWrite(pCancel)
	If ThisObject.DataExchange.Load Тогда
		Return;
	EndIf;
	If ВидыРазмещений.Count() = 0 Тогда
		ВызватьИсключение NStr("en='Accommodation types list should be filled!';ru='Не заполнен список видов размещения!';de='Die Liste der Unterbringungstypen ist nicht ausgefüllt!'");
	EndIf;
КонецПроцедуры //BeforeWrite
