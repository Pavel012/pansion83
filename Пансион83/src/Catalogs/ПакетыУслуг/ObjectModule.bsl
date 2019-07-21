//-----------------------------------------------------------------------------
Процедура BeforeWrite(pCancel)
	For Each vSrvRow In Services Do
		If НЕ ЗначениеЗаполнено(vSrvRow.Period) Тогда
			vSrvRow.Period = '20000101';
		EndIf;
	EndDo;
КонецПроцедуры //BeforeWrite

//-----------------------------------------------------------------------------
// Write to the service package records register
//-----------------------------------------------------------------------------
Процедура OnWrite(pCancel)
	vRcdSet = InformationRegisters.ЗапПакУслуг.CreateRecordSet();
	vServicePackageFlt = vRcdSet.Filter.ServicePackage;
	vServicePackageFlt.ComparisonType = ComparisonType.Equal;
	vServicePackageFlt.Value = Ref;
	vServicePackageFlt.Use = True;
	For Each vSrvRow In Services Do
		vRcdSetRow = vRcdSet.Add();
		vRcdSetRow.ServicePackage = Ref;
		FillPropertyValues(vRcdSetRow, vSrvRow);
		vRcdSetRow.RowNumber = vSrvRow.LineNumber;
	EndDo;
	vRcdSet.Write(True);
КонецПроцедуры //OnWrite

//-----------------------------------------------------------------------------
// Write to the service package records register
//-----------------------------------------------------------------------------
Function pmGetServices(pDate) Экспорт
	vQry = New Query();
	vQry.Text =
	"SELECT
	|	ServicePackageRecordsSliceLast.ServicePackage,
	|	ServicePackageRecordsSliceLast.ТипКлиента,
	|	ServicePackageRecordsSliceLast.Услуга,
	|	ServicePackageRecordsSliceLast.ВидРазмещения,
	|	ServicePackageRecordsSliceLast.QuantityCalculationRule,
	|	ServicePackageRecordsSliceLast.ТипДеньКалендарь,
	|	ServicePackageRecordsSliceLast.УчетнаяДата,
	|	ServicePackageRecordsSliceLast.AccountingDayNumber,
	|	ServicePackageRecordsSliceLast.Цена,
	|	ServicePackageRecordsSliceLast.Валюта,
	|	ServicePackageRecordsSliceLast.Количество,
	|	ServicePackageRecordsSliceLast.ЕдИзмерения,
	|	ServicePackageRecordsSliceLast.СтавкаНДС,
	|	ServicePackageRecordsSliceLast.Примечания,
	|	ServicePackageRecordsSliceLast.IsInPrice,
	|	ServicePackageRecordsSliceLast.IsServicePerPerson,
	|	ServicePackageRecordsSliceLast.RowNumber
	|FROM
	|	InformationRegister.ServicePackageRecords.SliceLast(&qDate, ServicePackage = &qServicePackage) AS ServicePackageRecordsSliceLast
	|
	|ORDER BY
	|	ServicePackageRecordsSliceLast.RowNumber";
	vQry.SetParameter("qServicePackage", Ref);
	vQry.SetParameter("qDate", pDate);
	vServices = vQry.Execute().Unload();
	Return vServices;
EndFunction //pmGetServices
