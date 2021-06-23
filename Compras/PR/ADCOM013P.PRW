#Include "RwMake.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "Topconn.ch"

// ############################################################################################################
// Projeto: Projeto Financas
// Modulo : SIGACOM
// Fonte  : ADCOM013P
// ---------+-------------------+--------------------------------------------------------------+---------------
// Data     | Autor             | Descricao                                                    | Chamado
// ---------+-------------------+--------------------------------------------------------------+---------------
// 12/12/17 | Ricardo Lima      | Aplica Bloqueio de titulo com base nos criterio de pontuacao | 038613
//          |                   | definidos pela politica de seguranca financeira              |
// ---------+-------------------+--------------------------------------------------------------+---------------
//          |                   |                                                              |
// ---------+-------------------+--------------------------------------------------------------+---------------
// ############################################################################################################

User Function ADCOM013P

	Local oPanel
    Local oNewPag
    Local cCodCli := Space(8)
    Local cFornec := Space(8)
    Local cNome   := Space(30) 
    Local cFornDe := Space(6) 
    Local cFornAte:= Space(6)
    Local cProdDe := Space(15) 
    Local cProdAte:= Space(15)
    Local cGrupo  := Space(4)
    Local cCombo1 := ""
    
    Local oStepWiz := nil
    Local oDlg     := nil
    Local oPanelBkg
    
    Private lCheck1 := GetMv("MV_#COM131")
    Private lCheck2 := GetMv("MV_#COM132")
    Private lCheck3 := GetMv("MV_#COM133")
    Private lCheck4 := GetMv("MV_#COM134")    
    
    PRIVATE aCpoBro	 := {}
    
    Private cMark   := GetMark()   
	Private oMark        

  U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
 
    //Para que a tela da classe FWWizardControl fique no layout com bordas arredondadas
    //iremos fazer com que a janela do Dialog oculte as bordas e a barra de titulo
    //para isso usaremos os estilos WS_VISIBLE e WS_POPUP
    DEFINE DIALOG oDlg TITLE 'FWWizardControl' PIXEL STYLE nOR(  WS_VISIBLE ,  WS_POPUP )
    oDlg:nWidth  := 800
    oDlg:nHeight := 620
 
    oPanelBkg := tPanel():New(0,0,"",oDlg,,,,,,300,300)
    oPanelBkg:Align := CONTROL_ALIGN_ALLCLIENT
 
    //Instancia a classe FWWizard
    oStepWiz:= FWWizardControl():New(oPanelBkg)
    oStepWiz:ActiveUISteps()
    
    //----------------------
    // Pagina 1
    //----------------------
    oNewPag := oStepWiz:AddStep("1")
    //Altera a descrição do step
    oNewPag:SetStepDescription("Tipos de Bloqueio")
    //Define o bloco de construção
    oNewPag:SetConstruction({|Panel|cria_pg1( Panel, @lCheck1, @lCheck2, @lCheck3, @lCheck4 )})
    //Define o bloco ao clicar no botão Próximo
    oNewPag:SetNextAction({||valida_pg1( @lCheck1, @lCheck2, @lCheck3, @lCheck4 )})
    //Define o bloco ao clicar no botão Cancelar
    oNewPag:SetCancelAction({||Alert("Cancelou na pagina 1"), .T., oDlg:End()})
            
    //----------------------
    // Pagina 2
    //----------------------    
    oNewPag := oStepWiz:AddStep("2", {|Panel|cria_pg2(Panel, @cFornDe, @cFornAte, @cProdDe, @cProdAte)})
    oNewPag:SetStepDescription("Seleção de Fornecedores")
    oNewPag:SetNextAction({||valida_pg2(@cFornDe, @cFornAte, @cProdDe, @cProdAte)})
 
    //Define o bloco ao clicar no botão Voltar
    oNewPag:SetCancelAction({||Alert("Cancelou na pagina 2"), .T., oDlg:End()})
    //Ser na propriedade acima (SetCancelAction) o segundo parametro estiver com .F., não será possível voltar
    //para a página anterior
    
    oNewPag:SetPrevAction({|| .T.})
    oNewPag:SetPrevTitle("Voltar")
    
    //----------------------
    // Pagina 3
    //----------------------
    oNewPag := oStepWiz:AddStep("3", {|Panel|cria_pn3(Panel)})
    oNewPag:SetStepDescription("Conclui Parametrização")
    oNewPag:SetNextAction({|| Processa({|| salva_con() },"Configurando","Aguarde...") , .T. , oDlg:End()})
    oNewPag:SetCancelAction({||Alert("Cancelou na pagina 3"), .T., oDlg:End()})
    oNewPag:SetCancelWhen({||.F.})
    oStepWiz:Activate()
    
    ACTIVATE DIALOG oDlg CENTER
    oStepWiz:Destroy()
Return
 
//--------------------------
// Construção da página 1
//--------------------------
Static Function cria_pg1( oPanel , lCheck1 , lCheck2 , lCheck3 , lCheck4 )

    Local oSay1
    Local oSay2
    
    Local oCheck1
    Local oCheck2
    Local oCheck3
    Local oCheck4
    
    Local oFont1 := TFont():New('Courier new',,-18,.T.)
    Local oFont2 := TFont():New('Courier new',,-16,.T.)
    Local oFont3 := TFont():New('Courier new',,-12,.T.)
    
    oFont1:Bold := .T.        
    
    oSay1:= TSay():New(10,10,{||'Parametros de validação da entrada de Nota Fiscal'},oPanel,,oFont1,,,,.T.,,,370,20)    
    oSay1:= TSay():New(30,10,{||'Criamos 4 regras na entrada do Título gerado por nota fiscal no sistema, onde avaliaremos se o mesmo está em acordo com os pré-requisitos de liberação para pagamento;'},oPanel,,oFont2,,,,.T.,,,370,30)     
     
    oCheck1 := TCheckBox():New(071,03,'Será analisado se o título gerado está na média de valor dos últimos 12 meses?'                     ,{|u|if( pcount()>0, lCheck1:= u, lCheck1)},oPanel,370,210,,,oFont3,,,,,.T.,,,)
    oCheck2 := TCheckBox():New(081,03,'Busca no sistema de armazenamento de xml se o documento de entrada que gerou o título contém o xml?',{|u|if( pcount()>0, lCheck2:= u, lCheck2)},oPanel,370,210,,,oFont3,,,,,.T.,,,)
    oCheck3 := TCheckBox():New(091,03,'Será analisado se existe pedido de compra para a nota fiscal que gerou o título?'                   ,{|u|if( pcount()>0, lCheck3:= u, lCheck3)},oPanel,370,210,,,oFont3,,,,,.T.,,,)
    oCheck4 := TCheckBox():New(101,03,'Será analisado se a entrada da nota que gerou o título recebeu a vistoria física no Recebimento?'   ,{|u|if( pcount()>0, lCheck4:= u, lCheck4)},oPanel,370,210,,,oFont3,,,,,.T.,,,)
         
Return
 
 
//----------------------------------------
// Validação do botão Próximo da página 1
//----------------------------------------
Static Function valida_pg1( lCheck1 , lCheck2 , lCheck3 , lCheck4 )

 Local lVldChk := .T.    
    
    if !lCheck1
    	lVldChk := .F.
    endif 
    if !lCheck2
    	lVldChk := .F.
    endif    
    if !lCheck3
    	lVldChk := .F.
    endif 
    if !lCheck4
    	lVldChk := .F.
    endif
    
    if !lVldChk
    	If MsgYesNo("Existe Item(ns) Não marcados, Deseja continuar?")
    	 lVldChk := .T.    	
    	endif    	
    endif
    
Return lVldChk
 
//--------------------------
// Construção da página 2
//--------------------------
Static Function cria_pg2(oPanel, cFornDe, cFornAte, cProdDe, cProdAte)

    Local oCombo1
    Local cCombo1
    Local oSay1
    Local oTGet1
    Local oSay2
    Local oTGet2
    Local oSay3
    Local oTGet3
    Local dData := CTOD("//")
    
    Local oTButton1    
    
    Private lInverte := .F.    
    
    SetPrvt( "oBROWSER" )
    
    aCpoBro  := { {"OK"      , , "Mark"              , "@!"},; 
    			  {"A2_COD"  , , "Codigo"            , " " },;
    			  {"A2_LOJA" , , "Loja"              , " " },;
    			  {"A2_NOME" , , "Nome Fornecedor"   , " " } }

    oSay1	:= TSay():New(10,10,{||'Fornecedor de'},oPanel,,,,,,.T.,,,40,20)	
    oTGet1 	:= TGet():New(10,50,{|u| if( PCount() > 0, cFornDe := u, cFornDe ) } ,oPanel,050,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"SA2","cFornDe")
    
    oSay2	:= TSay():New(10,110,{||'Fornecedor ate'},oPanel,,,,,,.T.,,,40,20)
    oTGet2 	:= TGet():New(10,150,{|u| if( PCount() > 0, cFornAte := u, cFornAte ) },oPanel,050,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"SA2","cFornAte")
    
    oSay1	:= TSay():New(10,210,{||'Produto de'},oPanel,,,,,,.T.,,,40,20)
    oTGet1 	:= TGet():New(10,240,{|u| if( PCount() > 0, cProdDe := u, cProdDe ) } ,oPanel,050,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"SB1","cProdDe")
    
    oSay1	:= TSay():New(10,300,{||'Produto Ate'},oPanel,,,,,,.T.,,,40,20)
    oTGet2 	:= TGet():New(10,340,{|u| if( PCount() > 0, cProdAte := u, cProdAte ) },oPanel,050,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"SB1","cProdAte")
    
    oTButton1 := TButton():New( 030 , 355 , "Atualizar"      ,oPanel,{|| Processa({|| ADCOMB13( "2" , cFornDe , cFornAte, cProdDe, cProdAte ) },"Atualizando","Aguarde...") } , 41 ,18,,,.F.,.T.,.F.,,.F.,,,.F. )
    oTButton1 := TButton():New( 055 , 355 , "Marca Todos"    ,oPanel,{|| Processa({|| ADCOMM13('M') },"Atualizando","Aguarde...") } , 41 ,18,,,.F.,.T.,.F.,,.F.,,,.F. )
    oTButton1 := TButton():New( 080 , 355 , "Desmarca Todos" ,oPanel,{|| Processa({|| ADCOMM13('D') },"Atualizando","Aguarde...") } , 41 ,18,,,.F.,.T.,.F.,,.F.,,,.F. )
    
    ADCOMB13( "1" , cFornDe , cFornAte, cProdDe, cProdAte )
    
    oMark := MsSelect():New("ADCOMB13","OK","",aCpoBro,@lInverte,@cMark,{030,008,200,350}, , , oPanel )
	oMark:bMark := {| | Disp() }
    
Return
 
//----------------------------------------
// Validação do botão Próximo da página 2
//----------------------------------------
Static Function valida_pg2( cFornDe , cFornAte, cProdDe, cProdAte )  
Return( .T. )
 
//--------------------------
// Construção da página 3
//--------------------------
Static Function cria_pn3(oPanel)	
	   
    Local oSay1
    Local oFont1 := TFont():New('Courier new',,-18,.T.)          
    
    oSay1:= TSay():New(20,10,{||'Parametrização Efetuada com Sucesso!'},oPanel,,oFont1,,,,.T.,,,370,20)
    oSay1:= TSay():New(40,10,{||'A partir desse momento todos os titulos gerado por Nota Fiscal de entrada passarão pela avaliação da Politica se segurança.'},oPanel,,oFont1,,,,.T.,,,370,20)    
 
Return
//--------------------------
// Salva Configuração
//--------------------------
Static Function salva_con()

// grava configuracao
PutMv( "MV_#COM131" , lCheck1 )
PutMv( "MV_#COM132" , lCheck2 )
PutMv( "MV_#COM133" , lCheck3 )
PutMv( "MV_#COM134" , lCheck4 )    

 dbSelectArea("ADCOMB13")
 dbGoTop()
 ProcRegua(RecCount())
 
 	WHILE ADCOMB13->( !EOF() )
	
	 DbSelectArea("SA2")
	 DbSetOrder(1)
	 if DbSeek( xFilial("SA2") + ADCOMB13->A2_COD + ADCOMB13->A2_LOJA )	  
	  RecLock("SA2", .F.)			
	  IF ADCOMB13->OK = cMark
	   SA2->A2_XBLQPON    := "1"
	  ELSE
	   SA2->A2_XBLQPON    := "2"
	  ENDIF	  						
	  MSUnLock()
	 endif
	 dbSelectArea("ADCOMB13")
	 ADCOMB13->( DbSkip() )	
	  IncProc() 
	end

Return( .T. )

// ##########################################################################################
// Projeto: Projeto Financas
// Modulo : SIGAFIN
// Fonte  : ADCOMB13
// ---------+-------------------+--------------------------------------------+---------------
// Data     | Autor             | Descricao                                  | Chamado
// ---------+-------------------+--------------------------------------------+---------------
// 14/11/17 | Ricardo Lima      | Central de Aprovacao                       |  
// ---------+-------------------+--------------------------------------------+---------------
//          |                   |                                            |
// ---------+-------------------+--------------------------------------------+---------------
// ##########################################################################################

STATIC Function ADCOMB13( opc , cFornDe , cFornAte, cProdDe, cProdAte )

Local cArq     := CriaTrab( NIL, .F.)
Local cNameIdx := FileNoExt(cArq)
Local cQuery   := ""
PRIVATE aCampos := {}

	aCampos := { {"OK"      , "C", 02 , 0}, ;
				 {"A2_COD"	, "C", 06 , 0}, ;
				 {"A2_LOJA"	, "C", 02 , 0}, ;
				 {"A2_NOME"	, "C", 35 , 0}  }								 
	
IF opc = "2"
  IF EMPTY(cFornAte)
  	opc := "1"
  ENDIF
ENDIF 

IF opc = "1"

 If ( SELECT("ADCOMB13" ) !=  0 )
	dbSelectArea("ADCOMB13")
	dbCloseArea()
 Endif

 dbCreate( cArq, aCampos )
 dbUseArea( .T., , cArq, "ADCOMB13", .F., .F.)
 DBCreateIndex(cNameIdx,'A2_COD+A2_LOJA')
	
	dbSelectArea("SA2")
	dbSetOrder( 1 )  
	
		While !EOF() .AND.  SA2->A2_COD <= "000020"
			dbSelectArea("ADCOMB13")
			RecLock("ADCOMB13", .T.)
			
			IF SA2->A2_XBLQPON = "1"
			 ADCOMB13->OK      := cMark
			ELSE
			 ADCOMB13->OK      := ""
			ENDIF
			ADCOMB13->A2_COD  := SA2->A2_COD
			ADCOMB13->A2_LOJA := SA2->A2_LOJA
			ADCOMB13->A2_NOME := SA2->A2_NOME			
			
			MSUnLock()
			
			dbSelectArea("SA2")
			dbSkip()
		Enddo
	
 dbSelectArea("ADCOMB13")
 dbGoTop()

elseIF opc = "2"

	If ( SELECT("ADCOMB13" ) !=  0 )
		dbSelectArea("ADCOMB13")
		dbCloseArea()
	Endif

	dbCreate( cArq, aCampos )
	dbUseArea( .T., , cArq, "ADCOMB13", .F., .F.)
	DBCreateIndex(cNameIdx,'A2_COD+A2_LOJA')
	
	//, cProdDe, cProdAte
	
	cQuery := " SELECT DISTINCT A2_COD, A2_LOJA, A2_NOME, A2_XBLQPON " 
	cQuery += " FROM "+ RetSqlName("SA2") +" A2 "
	if !Empty(cProdAte)
	  cQuery += " INNER JOIN "+ RetSqlName("SD1") +" D1 ON D1_FORNECE=A2_COD AND D1_LOJA=A2_LOJA "
	endif
	cQuery += " WHERE A2_COD BETWEEN '"+ cFornDe +"' AND '"+ cFornAte +"' "
	if !Empty(cProdAte)
	 cQuery += " AND D1_COD BETWEEN '"+ cProdDe +"' AND '"+ cProdAte +"' "
	endif
	cQuery += " AND A2.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY A2_COD, A2_LOJA "
	
	If Select("tADCOMB13") > 0
		tADCOMB13->(DbCloseArea())		
	EndIf
	
	TcQuery cQuery New Alias "tADCOMB13"
	
	WHILE tADCOMB13->( !EOF() )
	
	 dbSelectArea("ADCOMB13")
	 RecLock("ADCOMB13", .T.)
			
	 IF tADCOMB13->A2_XBLQPON = "1"
	   ADCOMB13->OK    := cMark
	 ELSE
	   ADCOMB13->OK    := ""
	 ENDIF
	 ADCOMB13->A2_COD  := tADCOMB13->A2_COD
	 ADCOMB13->A2_LOJA := tADCOMB13->A2_LOJA
	 ADCOMB13->A2_NOME := tADCOMB13->A2_NOME			
			
	 MSUnLock()
	
	 dbSelectArea("tADCOMB13")
	 tADCOMB13->( DbSkip() )	
	end
	
	dbSelectArea("ADCOMB13")
	dbGoTop()
	oMark:oBrowse:Refresh()
ENDIF

Return

// ##########################################################################################
// Projeto: Projeto Financas
// Modulo : SIGAFIN
// Fonte  : Disp
// ---------+-------------------+--------------------------------------------+---------------
// Data     | Autor             | Descricao                                  | Chamado
// ---------+-------------------+--------------------------------------------+---------------
// 14/11/17 | Ricardo Lima      | Central de Aprovacao                       |  
// ---------+-------------------+--------------------------------------------+---------------
// ##########################################################################################

Static Function Disp()

	 RecLock("ADCOMB13",.F.)
	  If Marked("OK")	
	   ADCOMB13->OK := cMark
	  Else	
	   ADCOMB13->OK := ""
	  Endif             
	 MSUNLOCK()
	oMark:oBrowse:Refresh()
						
Return()

// ##################################################################################################
// Projeto: Projeto Financas
// Modulo : SIGAFIN
// Fonte  : ADCOMM13
// ---------+-------------------+----------------------------------------------------+---------------
// Data     | Autor             | Descricao                                          | Chamado
// ---------+-------------------+----------------------------------------------------+---------------
// 16/04/18 | Ricardo Lima      | Marca ou Desmarca todos os registros selecionado   |  
// ---------+-------------------+----------------------------------------------------+---------------
// ##################################################################################################

Static Function ADCOMM13(nOpc)

	if nOpc = 'M'
        dbSelectArea("ADCOMB13")
        dbGoTop()

        WHILE ADCOMB13->( !EOF() )		 
            RecLock("ADCOMB13",.F.)
	            ADCOMB13->OK := cMark
	        MSUNLOCK()
            dbSelectArea("ADCOMB13")
	        ADCOMB13->( DbSkip() )	
	    end
    Else
        dbSelectArea("ADCOMB13")
        dbGoTop()

        WHILE ADCOMB13->( !EOF() )		 
            RecLock("ADCOMB13",.F.)
	            ADCOMB13->OK := ""
	        MSUNLOCK()
            dbSelectArea("ADCOMB13")
	        ADCOMB13->( DbSkip() )	
	    end
    Endif

     dbSelectArea("ADCOMB13")
     dbGoTop()

	oMark:oBrowse:Refresh()
						
Return()
