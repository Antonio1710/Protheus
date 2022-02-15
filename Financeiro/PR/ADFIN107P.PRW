#include "protheus.ch"    
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FILEIO.CH"


/*/{Protheus.doc} User Function ADFIN107P
	PROGRAMA DE TRANSFERÊNCIA DE PORTADOR EM LOTE.
	@type  Function
	@author ANDRE MENDES - Obify
	@since 17/12/2020
	@history Ticket 428 - Andre Mendes - 17/12/2020 - Requisição - Alterar Portador em Lote   
/*/


User Function ADFIN107P

    Private oMark
    PRIVATE cCadastro := "Contas a Receber"  // "Contas a Receber"

    oMark := FWMarkBrowse():New()
 
    oMark:SetAlias('SE1')

    oMark:SetDescription('Transferencia de portador')

    oMark:SetFieldMark( 'E1_XOKTRAN' )

    oMark:AddLegend( "Empty(E1_PORTADO) .AND. E1_SALDO>0 .AND. E1_SITUACA == 'F'", "BR_AMARELO", "Titulo Protestado" )
    oMark:AddLegend( "E1_SITUACA == '0' .AND. E1_SALDO > 0", "ENABLE" , "Titulo em Carteira" )
    oMark:AddLegend( "E1_SITUACA <> '0' .and. E1_SALDO>0", "DISABLE" , "Titulo Transferido" )
    oMark:AddLegend( "E1_SALDO=0", "BR_AZUL" , "Titulo Baixado" )
    

    oMark:Activate()
    
    //
    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'PROGRAMA DE TRANSFERÊNCIA DE PORTADOR EM LOTE')
    //

Return 


Static Function MenuDef()
Local aRotina := {}
    ADD OPTION aRotina TITLE 'Transferir' ACTION 'StaticCall(ADFIN107P,FUN107Proc)' OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE 'Visualizar' ACTION 'FA280Visua' OPERATION 2 ACCESS 0
    
Return aRotina





Static Function FUN107Proc()

    Local aArea := GetArea()
    Local cMarca := oMark:Mark()
    Local cFilter := "E1_XOKTRAN ='"+cMarca+"'"
    Local cAgen060		:= CriaVar("EF_AGENCIA",.f.)

    Local cConta060		:= CRIAVAR("EF_CONTA",.F.)
    Local cPort060		:= CRIAVAR("EF_BANCO",.F.)
    Local lEnabled := .T.
    Local cDescricao	:= ""
    Local cSituacao := CRIAVAR("E1_SITUACA",.F.)
    Local cContrato	:= CRIAVAR("E1_CONTRAT",.F.)
    Local cNumBco	:= CRIAVAR("E1_NUMBCO",.F.)
    Local lTransCart := .f.

    Local bMakeLog 		:= {}
    Local aLogTitle		:= {}
    Private aLogXTransf	:= {}
    Private nCt := 0
    Private nCtErr := 0



    nEspLarg := 0
    nEspLin  := 0
    DEFINE MSDIALOG oDlg FROM	15,6 TO 175,562 TITLE OemToAnsi("Transferencia") PIXEL
    //Painel dos dados
    oPanelD := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,25,25)
    oPanelD:Align := CONTROL_ALIGN_ALLCLIENT

    @ 010, 003+nEspLarg SAY	OemToAnsi("Portador")	SIZE 32, 7 OF oPanelD PIXEL  // "Portador"
    @ 010, 030+nEspLarg MSGET oPort060 VAR cPort060 F3 "SA6" ;   
        SIZE 25,10 OF oPanelD PIXEL HASBUTTON WHEN lEnabled

    @ 010, 068+nEspLarg SAY	OemToAnsi("Agencia")	SIZE 26, 7 OF oPanelD PIXEL  // "Agˆncia"
    @ 010, 095+nEspLarg MSGET cAgen060 ;   
        SIZE 35,10 OF oPanelD PIXEL WHEN lEnabled

    @ 010,135+nEspLarg SAY	OemToAnsi("Conta")	SIZE 26, 7 OF oPanelD PIXEL  //"Conta"
    @ 010,155+nEspLarg MSGET cConta060	;
         SIZE 50,10 OF oPanelD PIXEL WHEN lEnabled

    @ 025, 003+nEspLarg SAY OemToAnsi("Situacao")	SIZE 26, 7 OF oPanelD PIXEL  // "Situa‡„o"

    @ 025, 030+nEspLarg MSGET oSituacao VAR cSituacao  F3 "FRV" PICTURE "@!" ;
        Valid (fDescri(cSituacao,@cDescricao));
         SIZE 35, 10 OF oPanelD PIXEL HASBUTTON

    @ 025, 068+nEspLarg SAY 'Descricao' SIZE 25, 7 	OF oPanelD PIXEL  	//'Descrição'
    @ 025, 095+nEspLarg MSGET oDescricao VAR cDescricao SIZE 120, 10 OF oPanelD PIXEL WHEN .F.

    @ 041, 003+nEspLarg SAY OemToAnsi("Contrato") 	SIZE 25, 7 OF oPanelD PIXEL  // "Contrato"
    @ 041, 030+nEspLarg MSGET cContrato			SIZE 45,10 OF oPanelD PIXEL WHEN .f.

    @ 041, 090+nEspLarg SAY	 OemToAnsi("No. Portador")	SIZE 42, 7 OF oPanelD PIXEL  // "No. Portador"
    @ 041, 126+nEspLarg MSGET cNumBco 			SIZE 88,10 OF oPanelD PIXEL WHEN .f.


    @ 001, 001+nEspLarg TO 060, 280+nEspLarg LABEL OemToAnsi("Transferir para") OF oPanelD PIXEL  // "Transferir para"

    DEFINE SBUTTON FROM 68, 224 TYPE 1 ACTION (nOpca:=1,oDlg:End()	) ENABLE OF oPanelD
				
	DEFINE SBUTTON FROM 68, 251 TYPE 2 ACTION (nOpca:=0,oDlg:End()) ENABLE OF oPanelD
	
	ACTIVATE MSDIALOG oDlg CENTERED


    
	SE1->(dbSetFilter({|| &cFilter}, cFilter))
    SE1->( dbGoTop() )

    If cSituacao <> '0'
        If MsgYesNo("Deseja voltar o(s) titulo(s) para carteira antes dessa transferencia?")  
            lTransCart := .t.
        else
            lTransCart := .f.

        Endif
    Endif
    While !SE1->( EOF() )
        If oMark:IsMark(cMarca)
                
                
                aAdd( aLogXTransf,  "Titulo" + ": " + SE1->E1_PREFIXO + " - " + SE1->E1_NUM + " - " + SE1->E1_PARCELA+ " - " + SE1->E1_TIPO  ) // "Funcionario"

                cNumBco := SE1->E1_NUMBCO

                // Voltando o título para carteira
                
                If lTransCart
                      
                    MsAguarde( { || FIN107Trf("","","","0","")},"Transferindo titulo carteira")
                Endif

                // transferencia final
                MsAguarde( { || FIN107Trf(cPort060,cAgen060,cConta060,cSituacao,cNumBco)},"Transferindo titulo")
                
        EndIf
        SE1->( dbSkip() )
    End

    aAdd(aLogTitle, "Log de transferencias" )

    aAdd( aLogXTransf,  "Total transferidos com sucesso ........................... : " + PADL(alltrim(Str(nCt)),4)  ) 
    aAdd( aLogXTransf,  "Total de erros ........................................... : " + PADL(alltrim(Str(nCtErr)),4)  ) 

    bMakeLog := { || fMakeLog( { aLogXTransf } , aLogTitle,  NIL , .T. , FunName() , NIL , "G" , "P" , NIL , NIL ) }
	MsAguarde( bMakeLog , OemToAnsi( "Gerando Log de Transferencia" ) ) 

    //ApMsgInfo( 'Foram processados ' + AllTrim( Str( nCt ) ) + ' registros.' )
    RestArea( aArea )
    

Return


Static Function fDescri(cSituacao, cDescricao)

	If FRV->(MsSeek(xFilial("FRV")+cSituacao))
		cDescricao 		:= FRV->FRV_DESCRI

	Endif

    oSituacao:Refresh()
	oDescricao:Refresh()
Return 




Static function FIN107Trf(cBanco,cAgencia,cConta,cSituaca,cNumBco)

    Local aTit :={}
    Local cPrefixo := SE1->E1_PREFIXO
    Local cNumero := SE1->E1_NUM
    Local cParcela := SE1->E1_PARCELA
    Local cTipo := SE1->E1_TIPO
  
    Local nDesconto := 0
    Local nValCred := 0
    Local nVlIof := 0
    Local dDataMov := ddatabase

    //-- Variáveis utilizadas para o controle de erro da rotina automática
    Local aErroAuto :={}
    Local cErroRet :=""
    Local nCntErr :=0
    Private lMsErroAuto := .F.
    Private lMsHelpAuto := .T.
    Private lAutoErrNoFile := .T.

 

    //Para retornar o título para carteira é necessário informar o banco em "branco"
    If cSituaca =="0"

        cBanco := ""
        cAgencia := ""
        cConta := ""
        cNumBco := ""

    EndIf

    //Chave do título

    aAdd(aTit, {"E1_PREFIXO" , PadR(cPrefixo , TamSX3("E1_PREFIXO")[1]) ,Nil})
    aAdd(aTit, {"E1_NUM" , PadR(cNumero , TamSX3("E1_NUM")[1]) ,Nil})
    aAdd(aTit, {"E1_PARCELA" , PadR(cParcela , TamSX3("E1_PARCELA")[1]) ,Nil})
    aAdd(aTit, {"E1_TIPO" , PadR(cTipo , TamSX3("E1_TIPO")[1]) ,Nil})

    //Informações bancárias

    aAdd(aTit, {"AUTDATAMOV" , dDataMov ,Nil})
    aAdd(aTit, {"AUTBANCO" , PadR(cBanco ,TamSX3("A6_COD")[1]) ,Nil})
    aAdd(aTit, {"AUTAGENCIA" , PadR(cAgencia ,TamSX3("A6_AGENCIA")[1]) ,Nil})
    aAdd(aTit, {"AUTCONTA" , PadR(cConta ,TamSX3("A6_NUMCON")[1]) ,Nil})
    aAdd(aTit, {"AUTSITUACA" , PadR(cSituaca ,TamSX3("E1_SITUACA")[1]) ,Nil})
    aAdd(aTit, {"AUTNUMBCO" , PadR(cNumBco ,TamSX3("E1_NUMBCO")[1]) ,Nil})

    //Carteira descontada deve ser encaminhado o valor de crédito, desconto e IOF já calculados
    /*
    If cSituaca ="2"

        nDesconto := 0
        nValCred := 0
        nVlIof := 0
        aAdd(aTit, {"AUTDESCONT" , nDesconto ,Nil})
        aAdd(aTit, {"AUTCREDIT" , nValCred ,Nil})
        aAdd(aTit, {"AUTIOF" , nVlIof ,Nil})

    EndIf
    */
    MSExecAuto({|a, b| FINA060(a, b)}, 2,aTit)

    If lMsErroAuto

        aErroAuto := GetAutoGRLog()
        For nCntErr := 1 To Len(aErroAuto)

            cErroRet += aErroAuto[nCntErr]

        Next
        nCtErr++
        aAdd( aLogXTransf,  "        ==== >>> Erro na tranferencia: "+ cErroRet  ) // "Funcionario"

    else
        nCt++
        aAdd( aLogXTransf,  "        ==== >>> Transferido com sucesso!"  ) // "Funcionario"


    EndIf

Return

