#Include 'Protheus.ch'
#Include 'FwMvcDef.ch'
#Include 'Parmtype.ch'
#Include "Topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADFIN043P   บ Autor ณ Everson          บ Data ณ  25/10/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณCadastro de tarifa de bancos.                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 037320.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function ADFIN043P() // U_ADFIN043P()
		
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Local aArea	   := GetArea()
	Local oBrowse  := Nil
	Local cFunName := FunName()
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro de tarifa de bancos.')
	
	SetFunName("ADFIN043P")
		
		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias("ZC2")
		oBrowse:SetDescription("Cadastro de tarifas bancแrias")

		oBrowse:Activate()
		
	SetFunName(cFunName)
	
	RestArea(aArea)
	
Return Nil

Static Function ModelDef()
		
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local oModel := Nil
	Local oStruct:= FwFormStruct(1,'ZC2')
	
	oModel:= MpFormModel():New('_FIN042P',Nil,{|oModel| vldInAlt(oModel) })
	oModel:AddFields('MASTERALIAS',Nil,oStruct)
	oModel:SetDescription("Cadastro de Tarifas Bancแrias")
	oModel:GetModel('MASTERALIAS'):SetDescription("Cadastro de Tarifas Bancแrias")
	
	oStruct:SetProperty( 'ZC2_BANCO' , MODEL_FIELD_WHEN  , {|oModel| oModel:GetOperation()== 3 })
	oStruct:SetProperty( 'ZC2_TARIFA', MODEL_FIELD_WHEN  , {|oModel| oModel:GetOperation()== 3 })
	oStruct:SetProperty( 'ZC2_DTFIM' , MODEL_FIELD_VALID , {|oModel| Eval({||Iif( (DToS( oModel:GetValue( 'MASTERALIAS', 'ZC2_DTFIM' )) < DToS(oModel:GetValue( 'MASTERALIAS', 'ZC2_DTINI' )));
																				  .Or.oModel:GetValue( 'MASTERALIAS', 'ZC2_DTFIM' ) < Date() ,.F.,.T.)}) })
	oStruct:SetProperty( 'ZC2_VALOR' , MODEL_FIELD_VALID , {|oModel| Eval({||Iif( oModel:GetValue( 'MASTERALIAS', 'ZC2_VALOR' ) < 0,.F.,.T.)}) })
	
	oModel:SetPrimaryKey( { 'ZC2_FILIAL', 'ZC2_CODIGO' } )

Return oModel

Static Function ViewDef()
		
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local oModel := FwLoadModel('ADFIN043P')
	Local oStruct:= FwFormStruct(2,'ZC2')
	Local oView  := FwFormView():New()
	
	oView:SetModel(oModel)
	oView:AddField('VIEW_MASTER',oStruct,'MASTERALIAS')
	oView:CreateHorizontalBox('TELA',100)
	oView:SetOwnerView('VIEW_MASTER','TELA')

Return oView

Static Function MenuDef()
Return (FwMvcMenu('ADFIN043P'))

Static Function vldInAlt(oModel)
		
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Local aArea  := GetArea()
	Local cQuery := ""
	
	Local cFil    := oModel:GetValue( 'MASTERALIAS', 'ZC2_FILIAL' )
	Local cTarifa := oModel:GetValue( 'MASTERALIAS', 'ZC2_TARIFA' )
	Local cBanco  := oModel:GetValue( 'MASTERALIAS', 'ZC2_BANCO' )
	Local cAgencia:= oModel:GetValue( 'MASTERALIAS', 'ZC2_AGENCI' )
	Local cConta  := oModel:GetValue( 'MASTERALIAS', 'ZC2_CONTA' )
	Local cDataIni:= DToS(oModel:GetValue( 'MASTERALIAS', 'ZC2_DTINI' ))
	Local cDataFim:= DToS(oModel:GetValue( 'MASTERALIAS', 'ZC2_DTFIM' ))
	
	//
/*	If oModel:GetOperation() == 5
		Return vldExclusao()
		
	EndIf*/
	
	//Valida็ใo apenas para opera็ใo de inclusใo e altera็ใo.
	If oModel:GetOperation() <> 3 .And. oModel:GetOperation() <> 4
		RestArea(aArea)
		Return .T.
		
	EndIf
	
	//
	If cDataFim < cDataIni
		Help( ,, 'HELP',, 'Data final nใo pode ser menor que data inicial.', 1, 0)
		RestArea(aArea)
		Return .F.
			
	EndIf
	
	cQuery := ""
	cQuery += " SELECT * " 
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("ZC2") + " AS ZC2 (NOLOCK) " 
	cQuery += " WHERE " 
	cQuery += " ZC2.D_E_L_E_T_ = '' " 
	cQuery += " AND ZC2_FILIAL = '" + cFilAnt  + "' " 
	cQuery += " AND ZC2_TARIFA = '" + cTarifa  + "' " 
	cQuery += " AND ZC2_BANCO  = '" + cBanco   + "' " 
	cQuery += " AND ZC2_AGENCI = '" + cAgencia + "' " 
	cQuery += " AND ZC2_CONTA  = '" + cConta   + "' " 
	cQuery += " AND ZC2_DTFIM  >= '"+ cDataIni + "' " 
	
	If oModel:GetOperation() == 4
		cQuery += " AND ZC2.R_E_C_N_O_  <> '" + cValToChar(ZC2->(Recno())) + "' " 
		
	EndIf
	
	//
	If Select("CHK_ZC2") > 0
		CHK_ZC2->(DbCloseArea())
		
	EndIf
	
	TcQuery cQuery New Alias 'CHK_ZC2'
	DbSelectArea('CHK_ZC2')
	CHK_ZC2->(DbGoTop())
	If ! CHK_ZC2->(Eof())

		Help( ,, 'HELP',, 'O registro nใo pode ser duplicado.', 1, 0)
		CHK_ZC2->(DbCloseArea())
		RestArea(aArea)
		Return .F.
		
	EndIf
	CHK_ZC2->(DbCloseArea()) 
	
	RestArea(aArea)
	
Return .T.

Static Function vldExclusao()


Return .T.