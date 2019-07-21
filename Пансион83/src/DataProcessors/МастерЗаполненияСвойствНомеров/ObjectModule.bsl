//-----------------------------------------------------------------------------
Процедура pmExecute() Экспорт
	For Each vRoomsRow In Rooms Do
		If ЗначениеЗаполнено(vRoomsRow.Room) Тогда
			vProps = InformationRegisters.СвойстваНомеров.CreateRecordSet();
			vProps.Filter.НомерРазмещения.Set(vRoomsRow.Room);
			For Each vRow In RoomProperties Do
				If ЗначениеЗаполнено(vRow.RoomProperty) Тогда
					vPropsRec = vProps.Add();
					vPropsRec.НомерРазмещения = vRoomsRow.ГруппаНомеров;
					vPropsRec.RoomProperty = vRow.RoomProperty;
					vPropsRec.Примечания = vRow.RoomProperty.Remarks;
					vPropsRec.Автор = ПараметрыСеанса.ТекПользователь;
				EndIf;
			EndDo;
			If RoomProperties.Count() > 0 Тогда
				vProps.Write(False);
			Else
				vProps.Clear();
				vProps.Write(True);
			EndIf;
		EndIf;
	EndDo;
КонецПроцедуры //pmExecute