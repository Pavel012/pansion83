//-----------------------------------------------------------------------------
Процедура OnWrite(pCancel, pReplacing)
	If ThisObject.DataExchange.Load Тогда
		Return;
	EndIf;
	// Check if we have to log ГруппаНомеров inventory changes to the change history
	vChangesRcdSet = InformationRegisters.РесурсыНомеров.CreateRecordSet();
	For Each vRQSRow In ThisObject Do
		If (vRQSRow.IsRoomQuota Or vRQSRow.IsReservation Or vRQSRow.IsAccommodation) And 
		   ЗначениеЗаполнено(vRQSRow.Гостиница) And vRQSRow.Гостиница.EnableRoomInventoryChangeHistoryLogging And 
		   vRQSRow.RecordType = AccumulationRecordType.Expense And 
		   ЗначениеЗаполнено(vRQSRow.ДатаНачКвоты) And ЗначениеЗаполнено(vRQSRow.ДатаКонКвоты) And 
		   vRQSRow.ДатаНачКвоты < vRQSRow.ДатаКонКвоты Тогда
		    // Initialize check-in and check-out dates
			vCurDate = BegOfDay(vRQSRow.ДатаНачКвоты);
			vEndDate = BegOfDay(vRQSRow.ДатаКонКвоты);
			// Add records for each date inside period
			While vCurDate <= vEndDate Do
				// Clear recordset and filter from the previous data
				vChangesRcdSet.Clear();
				vChangesRcdSet.Filter.Reset();
				// Set filter to the current data
				vHotelFlt = vChangesRcdSet.Filter.Гостиница;
				vHotelFlt.ComparisonType = ComparisonType.Equal;
				vHotelFlt.Value = vRQSRow.Гостиница;
				vHotelFlt.Use = True;
				vRoomQuotaFlt = vChangesRcdSet.Filter.КвотаНомеров;
				vRoomQuotaFlt.ComparisonType = ComparisonType.Equal;
				vRoomQuotaFlt.Value = vRQSRow.КвотаНомеров;
				vRoomQuotaFlt.Use = True;
				vRoomTypeFlt = vChangesRcdSet.Filter.ТипНомера;
				vRoomTypeFlt.ComparisonType = ComparisonType.Equal;
				vRoomTypeFlt.Value = vRQSRow.ТипНомера;
				vRoomTypeFlt.Use = True;
				vDateFlt = vChangesRcdSet.Filter.ДатаДок;
				vDateFlt.ComparisonType = ComparisonType.Equal;
				vDateFlt.Value = vCurDate;
				vDateFlt.Use = True;
				// Add new record
				vChangesRow = vChangesRcdSet.Add();
				vChangesRow.Гостиница = vRQSRow.Гостиница;
				vChangesRow.КвотаНомеров = vRQSRow.КвотаНомеров;
				vChangesRow.ТипНомера = vRQSRow.ТипНомера;
				vChangesRow.ДатаДок = vCurDate;
				// Write record to the database
				vChangesRcdSet.Write(True);
				// Go to the next date
				vCurDate = vCurDate + 24*3600;
			EndDo;
		EndIf;
	EndDo;
КонецПроцедуры //OnWrite
