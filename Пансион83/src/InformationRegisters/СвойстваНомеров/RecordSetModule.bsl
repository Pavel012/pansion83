//-----------------------------------------------------------------------------
Процедура OnWrite(pCancel, pReplacing)
	If ThisObject.DataExchange.Load Тогда
		Return;
	EndIf;
	Try
		vRoom = ThisObject.Filter.НомерРазмещения.Value;
		If ЗначениеЗаполнено(vRoom) And НЕ vRoom.IsFolder Тогда
			vRoomObj = vRoom.GetObject();
			If pReplacing Тогда
				vRoomObj.RoomPropertiesCodes = "";
				vRoomObj.СвойстваНомера = "";
			EndIf;
			For Each vRoomPropertyRow In ThisObject Do
				If ЗначениеЗаполнено(vRoomPropertyRow.RoomProperty) Тогда
					If IsBlankString(vRoomObj.RoomPropertiesCodes) Тогда
						vRoomObj.RoomPropertiesCodes = TrimAll(vRoomPropertyRow.RoomProperty.Code);
						vRoomObj.СвойстваНомера = TrimAll(vRoomPropertyRow.RoomProperty.Description);
					Else
						vRoomObj.RoomPropertiesCodes = TrimAll(vRoomObj.RoomPropertiesCodes) + Chars.LF + TrimAll(vRoomPropertyRow.RoomProperty.Code);
						vRoomObj.СвойстваНомера = TrimAll(vRoomObj.СвойстваНомера) + Chars.LF + TrimAll(vRoomPropertyRow.RoomProperty.Description);
					EndIf;
				EndIf;
			EndDo;
			vRoomObj.Write();
		EndIf;
	Except
	EndTry;
КонецПроцедуры //OnWrite
