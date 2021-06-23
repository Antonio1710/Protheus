#Include "RwMake.ch"
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE "TOTVS.CH"
#Include "Topconn.ch"   
#Include 'FWEditPanel.ch'
#Include 'Parmtype.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ADLOG048Pº Autor ³ Ricardo Lima       º Data ³  08/01/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Chamado: 044314, CAdastro de Pedágios por Municipio        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function ADLOG048P

    Local   oBrowse
    Private aRotina := AdMnDef()
	Private nN      := 0

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'CAdastro de Pedágios por Municipio')

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZFE")
	oBrowse:SetDescription("Pedágios por Destino")
	oBrowse:Activate()
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AdMnDef  º Autor ³ Ricardo Lima       º Data ³  08/01/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Chamado: 044314, CAdastro de Pedágios por Municipio        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC Function AdMnDef()

	LOCAL aRotina := {}

	ADD OPTION aRotina TITLE "Visualizar" ACTION "ViewDef.ADLOG048P" OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"    ACTION "ViewDef.ADLOG048P" OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"    ACTION "ViewDef.ADLOG048P" OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"    ACTION "ViewDef.ADLOG048P" OPERATION 5 ACCESS 0

Return aRotina
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ModelDef º Autor ³ Ricardo Lima       º Data ³  08/01/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Chamado: 044314, CAdastro de Pedágios por Municipio        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC Function ModelDef()

	LOCAL oStruZFE  := FWFormStruct( 1, "ZFE",{|cCabCampos| AllTrim(cCabCampos) $ "ZFE_ORIGEM|ZFE_DESCOR|ZFE_CODMUN|ZFE_DESMUN|ZFE_DISMUN"} /*bAvalCampo*/, /*lViewUsado*/ )
	LOCAL oStru2ZFE := FWFormStruct( 1, "ZFE",{|cCabCampos| !AllTrim(cCabCampos) $ "ZFE_ORIGEM|ZFE_DESCOR|ZFE_CODMUN|ZFE_DESMUN|ZFE_DISMUN"} /*bAvalCampo*/, /*lViewUsado*/ )
	LOCAL oModel

	oModel := MPFormModel():New("ModelDef_MVC", /*bPreVld*/ ,/*bPosVld*/, /*bCommit*/, /*bCancel*/ )

	oModel:AddFields('ZFEMASTER', /*cOwner*/, oStruZFE )
	oModel:SetPrimaryKey( { 'ZFE_FILIAL','ZFE_CODMUN' } )
	oModel:AddGrid("ZFEDETAIL", "ZFEMASTER", oStru2ZFE, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
	oModel:GetModel("ZFEDETAIL"):SetUniqueLine( {'ZFE_CODROD','ZFE_SEQROD' } )
	oModel:SetRelation("ZFEDETAIL", { { "ZFE_FILIAL",'FWxFilial("ZFE")' },{"ZFE_CODMUN","ZFE_CODMUN"} }, ZFE->( IndexKey( 1 ) ) )
	oModel:GetModel("ZFEDETAIL"):SetOptional( .T. )
	oModel:GetModel("ZFEMASTER"):SetDescription("Origem - Destino")
	oModel:GetModel("ZFEDETAIL"):SetDescription("Pedágios por Destino")

Return oModel
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ViewDef  º Autor ³ Ricardo Lima       º Data ³  08/01/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Chamado: 044314, CAdastro de Pedágios por Municipio        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC Function ViewDef()

	LOCAL oView
	LOCAL oModelVd	:= ModelDef()
	LOCAL oStruZFE	:= FWFormStruct( 2, "ZFE" , {|cCabCampos| AllTrim(cCabCampos) $ "ZFE_ORIGEM|ZFE_DESCOR|ZFE_CODMUN|ZFE_DESMUN|ZFE_DISMUN"} )
	LOCAL oStru2ZFE	:= FWFormStruct( 2, "ZFE" ,{|cCabCampos| !AllTrim(cCabCampos) $ "ZFE_ORIGEM|ZFE_DESCOR|ZFE_CODMUN|ZFE_DESMUN|ZFE_DISMUN"} )

	oView := FWFormView():New()
    
	oView:SetModel( oModelVd )
	oView:AddField( "VIEW_ZFE", oStruZFE, "ZFEMASTER" )
	oView:AddGrid( "VIEW_ZFEE", oStru2ZFE, "ZFEDETAIL" )
	oView:CreateHorizontalBox("SUPERIOR", 25 )
	oView:CreateHorizontalBox("INFERIOR", 75 )
	oView:SetOwnerView("VIEW_ZFE", "SUPERIOR" )
	oView:SetOwnerView("VIEW_ZFEE", "INFERIOR" )
	oView:AddIncrementField("VIEW_ZFEE", "ZFE_SEQROD")
	oView:AddUserButton( 'Pedágios' , 'CLIPS', {|oView| U_ADLG481() } )
    oView:SetCloseOnOk( { || .T. } )

Return oView
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ADLG481  º Autor ³ Ricardo Lima       º Data ³  08/01/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Chamado: 044314, CAdastro de Pedágios por Municipio        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function ADLG481() 

	SetPrvt("_OMARK,_STRU,CARQ,_CINDEX,_CCHAVE,ACAMPOS")
	SetPrvt("LREFRESH,") 

	PRIVATE nVZDSM := 0

	U_ADINF009P('ADLOG048P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'CAdastro de Pedágios por Municipio')

	_stru:={}
	AADD(_stru,{"RB_OK","C",2,0})
	AADD(_stru,{"RB_CODIGO","C",6,0})
	AADD(_stru,{"RB_CODROD","C",06,0})
	AADD(_stru,{"RB_DESROD","C",20,0})
	AADD(_stru,{"RB_MUNIC","C",20,0})
	AADD(_stru,{"RB_KM","N",3,0})
	AADD(_stru,{"RB_VALOR","N",6,2})
	

	cArq:=Criatrab(_stru,.T.)

	DBUSEAREA(.t.,,carq,"TRB")
	
	INDEX ON RB_CODIGO TO TESTE
	
	cMarca := GetMark()  
	
	cQuery := " SELECT * "
	cQuery += " FROM "+RetSqlName('DU0')+" DU0 "
	cQuery += " WHERE DU0_FILIAL = '"+xFilial("DU0")+"' "
 	cQuery += " AND  DU0.D_E_L_E_T_ = '' "  
	
	TCQUERY cQuery new alias "QDU0"
	
	DBSELECTAREA("QDU0")
	DBGOTOP()
	WHILE !EOF()
		DBSELECTAREA("TRB")
	  	RECLOCK("TRB",.T.) 
	  	TRB->RB_CODIGO := QDU0->DU0_CODROD
	   	TRB->RB_CODROD := QDU0->DU0_SEQPDG
	   	TRB->RB_DESROD := POSICIONE("DTZ",1,XFILIAL("DTZ")+QDU0->DU0_CODROD,"DTZ_NOMROD")
	   	TRB->RB_MUNIC  := QDU0->DU0_MUNPDG
	   	TRB->RB_KM     := QDU0->DU0_KM 
	   	TRB->RB_VALOR  := QDU0->DU0_VALEIX
	   	TRB->RB_OK     := cMarca
	 	MSUNLOCK()
	DBSELECTAREA("QDU0")
	DBSKIP()
	ENDDO
	
	_cIndex:=Criatrab(Nil,.F.)
	_cChave:="RB_CODIGO+RB_CODROD"

	Indregua("TRB",_cIndex,_cchave,,,"Selecionando Registros...")
 	dBSETINDEX(_cIndex+ordbagext())

	DEFINE MSDIALOG oDlg2 FROM 200,1 TO 500,590 TITLE "Praça Pedágio" PIXEL

	aCampos := {}
	AADD(aCampos,{"RB_OK"    ,""          ,"@!"       ,"2" ,"0"})
	AADD(aCampos,{"RB_CODIGO","Codigo"    ,"@!"       ,"6" ,"0"}) 
	AADD(aCampos,{"RB_DESROD","Rodovia"   ,"@!"       ,"20","0"}) 
	AADD(aCampos,{"RB_CODROD","Pedagio"   ,"@!"       ,"6" ,"0"})
	AADD(aCampos,{"RB_MUNIC" ,"Municipio" ,"@!"       ,"20","0"}) 
	AADD(aCampos,{"RB_KM"    ,"KM"        ,"@E 999.99","06","2"})
	AADD(aCampos,{"RB_VALOR" ,"Valor EIXO","@E 999.99","6" ,"2"})

	@ 000,000 TO 116,297 BROWSE "TRB" FIELDS acampos MARK "RB_OK" object _oMark
	@ 120,010 SAY "Cadastros de Pedagio, Selecione o Desejado e Confirme."  SIZE 142, 007 OF oDlg2 COLORS 0, 16777215 PIXEL
	@ 130,010 BUTTON "Confirma" SIZE 40,15 ACTION (CONFOK(),Close(oDlg2)) SIZE 037, 012 OF oDlg2 PIXEL
	@ 130,060 BUTTON "Marca Tudo" SIZE 40,15 ACTION Marca() SIZE 037, 012 OF oDlg2 PIXEL
	@ 130,110 BUTTON "Desmarca Tudo" SIZE 50,15 ACTION Desmarca() SIZE 037, 012 OF oDlg2 PIXEL
	@ 130,220 BUTTON "Sair" SIZE 40,15 ACTION Close(oDlg2) SIZE 037, 012 OF oDlg2 PIXEL

	IF nVZDSM = 0
  		Desmarca()
 		nVZDSM := 1
	ENDIF

	ACTIVATE MSDIALOG oDlg2 CENTERED

	DBSELECTAREA("TRB")
 	DBCLOSEAREA()
  	FERASE(cArq)   

	QDU0->(dbclosearea()) 
  
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CONFOK   º Autor ³ Ricardo Lima       º Data ³  08/01/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Chamado: 044314, CAdastro de Pedágios por Municipio        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION CONFOK() 
    
	Local oModel     := FWModelActive()
	Local oView      := FWViewActive()
	Local oModelZFE  := oModel:GetModel( 'ZFEDETAIL' )
	Local nOperation := oModel:GetOperation()
	
	DbSelectArea("TRB")
	DbGoTop()
	While TRB->(!EOF())
		IF Marked("RB_OK")
			If nOperation = 3  
				If nN > 0
					oModelZFE:AddLine()	
				EndIf
			Else
				oModelZFE:AddLine()	
			EndIf
            oModelZFE:SetValue('ZFE_CODROD' , TRB->RB_CODIGO )
			oModelZFE:SetValue('ZFE_NOMROD' , Alltrim(TRB->RB_DESROD) ) 
			oModelZFE:SetValue('ZFE_SEQROD' , Alltrim(TRB->RB_CODROD) ) 
			oModelZFE:SetValue('ZFE_MUNPDG' , Alltrim(TRB->RB_MUNIC) ) 
			oModelZFE:SetValue('ZFE_KM'     , TRB->RB_KM ) 
			oModelZFE:SetValue('ZFE_VALEIX' , TRB->RB_VALOR ) 
	  	EndIf 
	  	TRB->(DbSkip())
		nN++
	ENDDO 
	oModelZFE:GoLine(1)
	oView:Refresh()
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Marca    º Autor ³ Ricardo Lima       º Data ³  08/01/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Chamado: 044314, CAdastro de Pedágios por Municipio        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Marca() 

	cMarca := GetMark()

	DbSelectArea("TRB")
	DbGoTop()
	While !EOF()
		If !Marked("RB_OK")
    		Reclock("TRB",.F.)
     		TRB->RB_OK := cMarca
    		MsUnlock()
  		EndIf
		DbSkip()
	End
	DbGoTop()
	_oMark:oBrowse:Refresh()
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ DesMarca º Autor ³ Ricardo Lima       º Data ³  08/01/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Chamado: 044314, CAdastro de Pedágios por Municipio        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DesMarca() 

	DbSelectArea("TRB")
	DbGoTop()
		While !EOF()
			If Marked("RB_OK")
  				Reclock("TRB",.F.)
    			TRB->RB_OK := ThisMark()
  				MsUnlock()
			EndIf
			DbSkip()
  		End
	DbGoTop()
	_oMark:oBrowse:Refresh()
Return