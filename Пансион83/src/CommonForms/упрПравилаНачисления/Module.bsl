
//--------------------------------------------------------
&AtServer
Процедура OnCreateAtServer(pCancel, pStandardProcessing)
	vObjectRef = Неопределено;
	Parameters.Property("ObjectRef", vObjectRef);
	If vObjectRef <> Неопределено Тогда
		ObjectRef = vObjectRef;
		If TypeOf(vObjectRef) = Type("DocumentRef.Размещение") Or TypeOf(vObjectRef) = Type("DocumentRef.Бронирование") Тогда
			vChargingRules = ObjectRef.ChargingRules.Unload(, "СпособРазделенияОплаты, ПравилаНачисления, ChargingFolio, ValidFromDate, ValidToDate, Owner, IsMaster, IsPersonal, IsTransfer");
		Else
			vChargingRules = ObjectRef.ChargingRules.Unload(, "СпособРазделенияОплаты, ПравилаНачисления, ChargingFolio, ValidFromDate, ValidToDate");
			vChargingRules.Columns.Add("IsMaster");
			vChargingRules.Columns.Add("IsTransfer");
			vChargingRules.Columns.Add("IsPersonal");
			vChargingRules.Columns.Add("Owner");
		EndIf;
		ValueToFormAttribute(vChargingRules, "ChargingRules");
	Else
		pCancel = True;
	EndIf;
КонецПроцедуры //OnCreateAtServer

//--------------------------------------------------------
&НаКлиенте
Процедура OnOpen(pCancel)
	If TypeOf(ObjectRef) = Type("DocumentRef.Размещение") Or TypeOf(ObjectRef) = Type("DocumentRef.Бронирование") Тогда
		Items.ChargingRulesIsMaster.Visible = True;
		Items.ChargingRulesIsPersonal.Visible = True;
		Items.ChargingRulesIsTransfer.Visible = True;
		Items.ChargingRulesOwner.Visible = True;
	Else
		Items.ChargingRulesIsMaster.Visible = False;
		Items.ChargingRulesIsPersonal.Visible = False;
		Items.ChargingRulesIsTransfer.Visible = False;
		Items.ChargingRulesOwner.Visible = False;
	EndIf;
КонецПроцедуры //OnOpen
