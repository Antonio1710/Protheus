#Include "RwMake.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "Topconn.ch"

/*/{Protheus.doc} User Function nomeFunction
    Pré-Cadastro de Fornecedor
    @type  Function
    @author Ricardo Lima
    @since 12/12/2017
    @version 01
    @history Chamado TI     - Ricardo Lima      - 02/03/2018 - Identifica origem por pre-cadastro
    @history Chamado 044568 - Ricardo Lima      - 17/10/2018 - Retirado a validação de e-mail do pre-cadastro
    @history Chamado 045441 - Everson           - 11/12/2018 - Criada tabela genérica (SX5) para cadastramento de bancos. 
    @history Chamado 047230 - Ricardo Lima      - 15/02/2019 - Habilita rotina por parametro
    @history Chamado 048664 - Adriano Savoine   - 22/04/2019 - Inserida nova Validação para o campo Email não permitindo entrar vazio 
    @history Chamado 049800 - Fernando sigoli   - 11/06/2019 - Deixar Obrigatorio Condição de pagamento
    @history Chamado 050498 - Adriano Savoine   - 18/07/2019 - Não permitir entrar codigo de Natureza que não exista na Base de Dados.
    @history Chamado 050760 - Adriano Savoine   - 30/07/2019 - Não Permitir entrar codigo de condição de pagamento invalido na base de dados.
    @history Chamado 049218 - FWNM              - 27/08/2019 - Novo status p/ recusa (A2_XPRECAD = 3) 
    @history Chamado 049218 - WILLIAM COSTA     - 20/09/2019 - Validacao campo de CNPJ nao deixar campo menor que 14 ou 11
    @history Chamado 049218 - WILLIAM COSTA     - 16/10/2019 - Validacao campo de CNPJ nao deixar campo menor que 14 ou 11
    @history Chamado 052327 - Adriana Oliveira  - 16/10/2019 - Ajuste emails Pre-Cadastro p/ SAFEGG
    @history Chamado 053083 - WILLIAM COSTA     - 08/11/2019 - Retirado regras de CNPJ e adicionado novas para não deixar entra CNPJ e inscrição estadual igual
    @history Chamado 053801 - ADRIANO SAVOINE   - 03/12/2019 - Mensagem na linha 148 se o Fornecedor posicionado for de recusa carrega os dados e na linha 200 valida se o Banco for vazio não faz nada para evitar error log.
    @history Chamado 053083 - WILLIAM COSTA     - 06/12/2019 - Adicionado tratativa no CNPJ para verificar se já existe um fornecedor atraves do cnpj que tenha a inscrição estadual isento ou branco e não deixar entrar
    @history Chamado 054075 - ADRIANO SAVOINE   - 13/12/2019 - Adicionado novos campos para não validar o CNPJ que está na tela no caso de que ouver recusa no cadastro do Fornecedor permitindo assim alterar e encaminhar novamente.
    @history Chamado 055258 - WILLIAM COSTA     - 27/01/2020 - Adicionado um IIF na variavel de endereço e numero quando o fornecedor está bloqueado para carregar corretamente o endereço e numero quando o fornecedor não tem virgula no endereço. Após ajuste foi solucionado.
	@history Chamado TI     - Adriana Oliveira  - 11/02/2020 - Para correção do error.log: Variable does not exist CEMPANT on U_ADCOM15(ADCOM015P.PRW) 03/02/2020 15:49:01 line : 841
    @history Chamado 055585 - Adriano / Abel    - 14/02/2020 - Criado a Validação para renovar a Tela quando alterar de pessoa Fisica / Juridica, E tambem adicionado a Validação no campo IE para não aceitar caracter especial.
    @history Chamado 057996 - WILLIAM COSTA     - 14/02/2020 - Identificado que o tracinho não era feito a troca no campo cIE, foi ajustado para solucionar casos de duplicidade de fornecedores
    @history Chamado TI     - WILLIAM COSTA     - 27/05/2020 - Alterado as variaveis que estavam declaradas fora da função para dentro da funcão como private.
    @history Chamado TI     - Adriana Oliveira  - 30/07/2020 - Corrigido inicializador do campo A2_COD para U_SXESXF("SA2").
    @history Chamado TI     - Adriana Oliveira  - 10/08/2020 - Desabilitadas chamadas das funcoes CONFIRMSX8 e ROLLBACKSX8 .
    @history Ticket     35  - Adriana Oliveira  - 28/09/2020 - Alteradas validações de CNPJ para produtor rural, e ajuste nas posições dos campos na tela de cadastro
    @history Ticket     39  - Fernando Macieira - 12/11/2020 - Projeto RM
    @history Ticket     TI  - William Costa     - 27/11/2020 - Ajuste na Função que gera o Codigo do Fornecedor quando o campo RM está marcado pois na RNX2 não tinha nenhum fornecedor ainda cadastrado com F, a variavel de retorno trazia branco, ajustado o IF e adicionado um Else
    @history Ticket    6648 - Adriano Savoine   - 15/12/2020 - Eliminado da Static Function o Metodo FreeChildren pois ele elimina todos os objetos da classe e causava error log ao mudar o combo produtor rural.
/*/

User Function ADCOM015P() 

	Local oPanel
    Local oNewPag
    Local cNomeFor  := Space(80)
    Local cNomeFan  := Space(40)
    Local cEnd      := Space(40) 
    Local cBairro   := Space(50)
    Local cCodCid   := Space(15)
    Local cCidade   := Space(50)
    Local cCep      := Space(08)
    Local cIe       := Space(18)
    Local cIm       := Space(18)
    Local sObs      := Space(254) 
    Local dDataNasc := CTOD('  /  /    ')
    Local cNum      := Space(6)
    Local cPais     := Space(150)
    Local cCodPais  := Space(5)
    Local cNaturez  := Space(10)
    Local cContato  := Space(50)
    Local cTelefone := Space(11)
    Local cTele2    := Space(11)
    Local cEmail    := Space(125)
    Local cBco      := Space(03)
    Local cAge      := Space(05)
    Local cDigAge   := Space(01)
    Local cCta      := Space(10)
    Local cDigCta   := Space(01)
    Local cCond     := Space(15)
    Local nRG       := Space(15)
    Local oPanelBkg
    Private cEst      := Space(02)
    Private cCnpj     := Space(14)
    Private cLojFor :='' //CHAMADO: 054075 - ADRIANO SAVOINE 13/12/2019
    Private oCombo1        
    Private aItens1:= {'Juridica','Fisica'}
    Private cCombo1:= aItens1[1]
    Private oCmbBco
    Private aBco := FNMNTBCO()
    Private cCmbBco := aBco[1]
    Private oCombo2        
    Private aItens2:= {'Não','Sim'}
    Private cCombo2:= aItens2[1]
    Private oCombo3        
    Private aItens3:= {'Não','Sim'}
    Private cCombo3:= aItens2[1]
    Private sEmailDt := SuperGetMv( "MV_#EMLWF1" , .F. , '' ,  )+';'+SuperGetMv( "MV_#EMLWF2" , .F. , '' ,  )
    Private oTGetTipo := NIL
    Private oStepWiz  := NIL
    Private oDlg      := NIL
    Private oNewPag1  := NIL
    Private cGetPict  := ""

    Private oComboRM
    Private aItensRM := {'Não','Sim'}
    Private cComboRM := aItensRM[1]
    Private cRMFunc  := Space(100)

    PtInternal(1,ALLTRIM(PROCNAME()))

    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
 
    DEFINE DIALOG oDlg TITLE 'FWWizardControl' PIXEL STYLE nOR(  WS_VISIBLE ,  WS_POPUP )
    oDlg:nWidth  := 900
    oDlg:nHeight := 720
 
    oPanelBkg := tPanel():New(0,0,"",oDlg,,,,,,400,400)
    oPanelBkg:Align := CONTROL_ALIGN_ALLCLIENT
 
    //Instancia a classe FWWizard
    oStepWiz:= FWWizardControl():New(oPanelBkg)
    oStepWiz:ActiveUISteps()
    
    //----------------------
    // Pagina 1
    //----------------------
    oNewPag1 := oStepWiz:AddStep("1")
    //Altera a descrição do step
    oNewPag1:SetStepDescription("Dados Fornecedor")
    //Define o bloco de construção
    oNewPag1:SetConstruction({|Panel|cria_pg1( Panel , @cNomeFor , @cNomeFan , @cEnd , @cBairro , @cCodCid , @cCidade , @cEst , @cCep , @cCnpj , @cIe , @cIm , @sObs, @aItens1, @cCombo1, @dDataNasc, @cNum, @cPais, @cCodPais, @cNaturez, @cContato, @cTelefone, @cTele2, @cEmail, @cBco, @cAge, @cCta, @cCond, @cDigAge, @cDigCta, @nRG )})
    //Define o bloco ao clicar no botão Próximo
    //CHAMADO: 054075 - ADRIANO SAVOINE 13/12/2019 INSERIDO cLojFor em valida_pg1
    oNewPag1:SetNextAction({||valida_pg1( @cCodFor, cLojFor,@cNomeFor , @cNomeFan , @cEnd , @cBairro , @cCodCid , @cCidade , @cEst , @cCep , @cCnpj , @cIe , @cIm , @sObs, @aItens1, @cCombo1, @dDataNasc, @cNum, @cPais, @cCodPais, @cNaturez, @cContato, @cTelefone, @cTele2, @cEmail, @cBco, @cAge, @cCta, @cCond, @cDigAge, @cDigCta, @nRG )})
    //Define o bloco ao clicar no botão Cancelar
     oNewPag1:SetCancelAction({|| Iif(MsgYesNo( "Cancela Entrada de Dados?", "Prospect de Fornecedor" ),(.T.,oDlg:End()),.F.) }) //Ticket     35  -  Adriana Oliveira- 28/09/2020
  
    //----------------------
    // Pagina 2
    //----------------------               
    oNewPag := oStepWiz:AddStep("2", {|Panel|cria_pn2(Panel)})
    oNewPag:SetStepDescription("Conclui Pré-Cadastro")
    oNewPag:SetNextAction({|| salva_con( @cNomeFor , @cNomeFan , @cEnd , @cBairro, @cCodCid , @cCidade , @cEst , @cCep , @cCnpj , @cIe , @cIm , @sObs, @aItens1, @cCombo1, @dDataNasc, @cNum, @cPais, @cCodPais, @cNaturez, @cContato, @cTelefone, @cTele2, @cEmail, @cBco, @cAge, @cCta, @cCond, @cDigAge, @cDigCta, @nRG ) , .T. , oDlg:End()})
    oNewPag:SetCancelAction({|| Iif(MsgYesNo( "Cancela Entrada de Dados?", "Prospect de Fornecedor" ),(.T.,oDlg:End()),.F.)}) //Ticket     35  -  Adriana Oliveira- 28/09/2020
    oNewPag:SetCancelWhen({||.F.})
    oStepWiz:Activate()
    
    ACTIVATE DIALOG oDlg CENTER
    oStepWiz:Destroy()
Return

/*/{Protheus.doc} Static Function cria_pg1
   
    @type  Function
    @author Ricardo Lima
    @since 12/12/2017
    @version 01
    @history Chamado 049218 - FWNM                 - 27/08/2019 - Novo status p/ recusa (A2_XPRECAD = 3) 
    
/*/
 
Static Function cria_pg1( oPanel , cNomeFor , cNomeFan , cEnd , cBairro, cCodCid , cCidade , cEst , cCep , cCnpj , cIe , cIm , sObs, aItens1, cCombo1, dDataNasc, cNum, cPais, cCodPais, cNaturez, cContato, cTelefone, cTele2, cEmail, cBco, cAge, cCta, cCond, cDigAge, cDigCta, nRG )

    Local oSay1
    
    Local oFont1 := TFont():New('Courier new',,-18,.T.)
    Local oFont2 := TFont():New('Courier new',,-16,.T.)
    Local oFont4 := TFont():New('Courier new',,-12 ,.T.)
    
    Local lCNPJ := .F.  // Chamado n. 049218 || OS 050526 || FINANCAS || ANDREA || 8319 || CAD. FORNECEDOR - fwnm - 28/08/2019

    Private oTGet1
    
    // Chamado n. 049218 || OS 050526 || FINANCAS || ANDREA || 8319 || CAD. FORNECEDOR - fwnm - 27/08/2019
    If SA2->A2_XPRECAD == "3" // Recusado

		ApMsgInfo('Fornecedor Selecionado Com Status de Recusa. Será Carregado os Dados do Mesmo, Se Não For Alterar Este Clique em Cancelar, Posicione no Proximo Fornecedor e abra o Pre Cadastro. Verifique!','Prospect de Fornecedor') // CHAMADO:053801 ADRIANO SAVOINE - SE O FORNECEDOR POSICIONADO FOR RECUSADO CARREGA OS DADOS 
		
        lCNPJ := .T.

        cCodFor  := SA2->A2_COD //CHAMADO: 054075 - ADRIANO SAVOINE 13/12/2019
        cLojFor  := SA2->A2_LOJA //CHAMADO: 054075 - ADRIANO SAVOINE 13/12/2019
 		cNomeFor := SA2->A2_NOME
		cNomeFan := SA2->A2_NREDUZ 
		cEnd     := IIF(RAT(",",SA2->A2_END) == 0,SA2->A2_END,Left(AllTrim(Left(SA2->A2_END,RAT(",",AllTrim(SA2->A2_END)))),Len(AllTrim(Left(SA2->A2_END,RAT(",",AllTrim(SA2->A2_END)))))-1)) //chamado 055258 27/01/2020 WILLIAM COSTA
		cNum     := IIF(RAT(",",SA2->A2_END) == 0,Space(6),AllTrim(Subs(AllTrim(SA2->A2_END),RAT(",",AllTrim(SA2->A2_END))+1,Len(AllTrim(SA2->A2_END))))) //chamado 055258 27/01/2020 WILLIAM COSTA
		cBairro  := SA2->A2_BAIRRO 
        cCodCid  := SA2->A2_COD_MUN
		cCidade  := SA2->A2_MUN 
		cEst     := SA2->A2_EST  
		cCep     := SA2->A2_CEP  
		cCnpj    := SA2->A2_CGC      
		cIe      := SA2->A2_INSCR 
		cIm      := SA2->A2_INSCRM 
        cNaturez := SA2->A2_NATUREZ 
        cCodPais := SA2->A2_CODPAIS 
        dDataNasc:= SA2->A2_DTNASC 
        nRG      := SA2->A2_PFISICA 
        cContato := SA2->A2_CONTATO 
        cTelefone:= SA2->A2_DDD + SA2->A2_TEL 
        cTele2   := SA2->A2_DDD + SA2->A2_TELRE
        cEmail   := SA2->A2_EMAIL 
        cAge     := SA2->A2_AGENCIA 
        cDigAge  := SA2->A2_DIGAG 
        cDigCta  := SA2->A2_DIGCTA 
        cCta     := SA2->A2_NUMCON 
        cCond    := SA2->A2_COND  
        cNaturez := SA2->A2_NATUREZ
        
        // Pessoa Fisica/Juridica
        If SA2->A2_TIPO == "J"
        	cCombo1:= aItens1[1]
        ElseIf SA2->A2_TIPO == "F"
        	cCombo1:= aItens1[2]
        EndIf

        // Produtor Rural
        If SA2->A2_XPR == "1"
        	cCombo2 := aItens2[2]
        ElseIf SA2->A2_XPR == "2"
        	cCombo2 := aItens2[1]
        EndIf

        // Descontar IPR
        If SA2->A2_XDI == "1"
        	cCombo3 := aItens3[2]
        ElseIf SA2->A2_XDI == "2"
        	cCombo3 := aItens3[1]
        EndIf

        // Banco
        If !Empty(SA2->A2_BANCO) // CHAMADO:053801 ADRIANO SAVOINE - VALIDA SE NAO É VAZIO
        	nPosBco := aScan( aBco,{ |x| Left(AllTrim(x),3) == SA2->A2_BANCO } )  
       		cCmbBco := aBco[nPosBco]
        EndIf 
    	
    EndIf
    //

    oFont2:Bold := .T.
    oFont4:Bold := .T.
    //Inicio Ticket     35  -  Adriana Oliveira- 28/09/2020
    oSay1:= TSay():New(02,10,{||'Pré-Cadastro de Fornecedor, Preencher todos os campos solicitados.'},oPanel,,oFont2,,,,.T.,,,370,20)                   
    
    oSay1	:= TSay():New(15,10,{||'Razão Social/ Nome*'},oPanel,,oFont4,,,,.T.,CLR_BLUE,,80,20)	
    oTGet1 	:= TGet():New(15,80,{|u| if( PCount() > 0, cNomeFor := u, cNomeFor ) } ,oPanel,140,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"cNomeFor")
    
    oSay1	:= TSay():New(30,10,{||'Nome Fantasia*'},oPanel,,oFont4,,,,.T.,CLR_BLUE,,55,20)
    oTGet1 	:= TGet():New(30,80,{|u| if( PCount() > 0, cNomeFan := u, cNomeFan ) },oPanel,100,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"cNomeFan")

    oSay1	:= TSay():New(45,10,{||'CEP'},oPanel,,oFont4,,,,.T.,CLR_BLUE,,50,20)
    oSay1	:= TSay():New(45,22,{||'*'},oPanel,,oFont4,,,,.T.,CLR_RED,,50,20)
    oTGet1 	:= TGet():New(45,80,{|u| if( PCount() > 0, cCep := u, cCep ) } ,oPanel,60,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,'JC2A12',"cCep")

    oSay1	:= TSay():New(60,10,{||'Endereço*'},oPanel,,oFont4,,,,.T.,CLR_BLUE,,50,20)
    oTGet1 	:= TGet():New(60,80,{|u| if( PCount() > 0, cEnd := u, cEnd ) } ,oPanel,100,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"cEnd")

    oSay1	:= TSay():New(60,185,{||'Numero*'},oPanel,,oFont4,,,,.T.,CLR_BLUE,,50,20)
    oTGet1 	:= TGet():New(60,210,{|u| if( PCount() > 0, cNum := u, cNum ) } ,oPanel,10,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"cNum")
    
    oSay1	:= TSay():New(75,10,{||'Bairro*'},oPanel,,oFont4,,,,.T.,CLR_BLUE,,50,20)
    oTGet1 	:= TGet():New(75,80,{|u| if( PCount() > 0, cBairro := u, cBairro ) } ,oPanel,100,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"cBairro")
    
    oSay1	:= TSay():New(90,10,{||'Cidade*'},oPanel,,oFont4,,,,.T.,CLR_BLUE,,50,20)
    oTGet1 	:= TGet():New(90,38,{|u| if( PCount() > 0, cCodCid := u, cCodCid ) } ,oPanel,40,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,'CC2A11',"cCodCid")
    oTGet1 	:= TGet():New(90,80,{|u| if( PCount() > 0, cCidade := u, cCidade ) } ,oPanel,100,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,"cCidade")

    oSay1	:= TSay():New(105,10,{||'Estado*'},oPanel,,oFont4,,,,.T.,CLR_BLUE,,50,20)
    oTGet1 	:= TGet():New(105,80,{|u| if( PCount() > 0, cEst := u, cEst ) } ,oPanel,60,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,'12',"cEst")
    
    oSay1	:= TSay():New(120,10,{||'Pais*'},oPanel,,oFont4,,,,.T.,CLR_BLUE,,80,20)
    oTGet1 	:= TGet():New(120,80,{|u| if( PCount() > 0, cCodPais := u, cCodPais ) } ,oPanel,30,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,'CCHPRE',"cCodPais")
    oTGet1 	:= TGet():New(120,120,{|u| if( PCount() > 0, cPais := u, cPais ) } ,oPanel,100,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,"cPais")
    
     //Chamado 055585 - Adriano / Abel / William       - 14/02/2020
    oSay1	:= TSay():New(135,10,{||'Tipo Pessoa*'},oPanel,,oFont4,,,,.T.,CLR_BLUE,,50,20)	
    oCombo1 := TComboBox():New(135,80,{|u|if(PCount()>0,cCombo1:=u,cCombo1)},aItens1,50,009,oPanel,,{||PictureCGC(cCombo1, cCombo2, cEst, oPanel)},,,,.T.,,,,,,,,,'cCombo1')
    //Chamado 055585 - Adriano / Abel /William       - 14/02/2020

    oSay1	:= TSay():New(135,150,{||'Produtor Rural'},oPanel,,oFont4,,,,.T.,CLR_BLUE,,60,20)
    oCombo2 := TComboBox():New(135,210,{|u|if(PCount()>0,cCombo2:=u,cCombo2)},aItens2,30,009,oPanel,,{||PictureCGC(cCombo1, cCombo2, cEst, oPanel)},,,,.T.,,,,,,,,,'cCombo2')

   oSay1	:= TSay():New(150,10,{||'Cnpj / CPF*'},oPanel,,oFont4,,,,.T.,CLR_BLUE,,50,20)
   // Chamado n. 049218 || OS 050526 || FINANCAS || ANDREA || 8319 || CAD. FORNECEDOR - fwnm - 27/08/2019
    If cCombo1 == "Fisica" .and. cEST = "SP" .and. cCombo2 = "Sim"
    	If lCNPJ
    		oSay1	:= TSay():New(150,80,{||cCNPJ},oPanel,,oFont4,,,,.T.,CLR_BLACK,,50,20)
    	Else
    		oTGetTipo 	:= TGet():New(150,80,{|u| if( PCount() > 0, cCnpj := u, cCnpj ) } ,oPanel,60,009,'@R 99.999.999/9999-99',{|| VldCNPJ(cCnpj, cEst, cCombo2) },0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"cCnpj")
    	EndIf
    Elseif cCombo1 == "Fisica" .and. !(cEST = "SP" .and. cCombo2 = "Sim")
  	    If lCNPJ
    		oSay1	:= TSay():New(150,80,{||cCNPJ},oPanel,,oFont4,,,,.T.,CLR_BLACK,,50,20)
    	Else
    		oTGetTipo 	:= TGet():New(150,80,{|u| if( PCount() > 0, cCnpj := u, cCnpj ) } ,oPanel,60,009,'@R 999.999.999-99',{|| VldCNPJ(cCnpj, cEst, cCombo2) },0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"cCnpj")
    	EndIf
    Else 
    	If lCNPJ
    		oSay1	:= TSay():New(150,80,{||cCNPJ},oPanel,,oFont4,,,,.T.,CLR_BLACK,,50,20)
    	Else
    		oTGetTipo 	:= TGet():New(150,80,{|u| if( PCount() > 0, cCnpj := u, cCnpj ) } ,oPanel,60,009,'@R 99.999.999/9999-99',{|| VldCNPJ(cCnpj, cEst, cCombo2) },0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"cCnpj")
    	EndIf
    EndIf
    //

    oSay1	:= TSay():New(150,160,{||'Descontar IPR'},oPanel,,oFont4,,,,.T.,CLR_BLUE,,60,20)
    oCombo3 := TComboBox():New(150,210,{|u|if(PCount()>0,cCombo3:=u,cCombo3)},aItens3,30,009,oPanel,,,,,,.T.,,,,{|| IIf(oCombo2:aItems[oCombo2:NAT]='Sim',.T.,.F.) },,,,,'cCombo3',,,,)

    oSay1	:= TSay():New(165,10,{||'Incrição Estadual'},oPanel,,oFont4,,,,.T.,CLR_BLUE,,80,20)
    oTGet1 	:= TGet():New(165,80,{|u| if( PCount() > 0, cIe := u, cIe ) } ,oPanel,60,009,"@!",{|| VldIE(cIe, cEst) },0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"cIe")
    
    oSay1	:= TSay():New(180,10,{||'Incrição Municipal'},oPanel,,oFont4,,,,.T.,CLR_BLUE,,80,20)
    oTGet1 	:= TGet():New(180,80,{|u| if( PCount() > 0, cIm := u, cIm ) } ,oPanel,60,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"cIm")
    
    oSay1	:= TSay():New(180,170,{||'RG'},oPanel,,oFont4,,,,.T.,CLR_BLUE,,100,20)
    oTGet1 	:= TGet():New(180,180,{|u| if( PCount() > 0, nRG := u, nRG ) } ,oPanel,55,009,"",{|| VldRG( nRG ) },0,,,.F.,,.T.,,.F.,{|| Iif(oCombo1:aItems[oCombo1:NAT]='Fisica',.T.,.F.) } ,.F.,.F.,,.F.,.F.,,"nRG")
    
    oSay1	:= TSay():New(15,255,{||'Data Nascimento'},oPanel,,oFont4,,,,.T.,CLR_BLUE,,100,20)
    oTGet1 	:= TGet():New(15,335,{|u| if( PCount() > 0, dDataNasc := u, dDataNasc ) } ,oPanel,55,009,"",,0,,,.F.,,.T.,,.F.,{|| Iif(oCombo1:aItems[oCombo1:NAT]='Fisica',.T.,.F.) } ,.F.,.F.,,.F.,.F.,,"dDataNasc")

    oSay1	:= TSay():New(30,255,{||'Contato'},oPanel,,oFont4,,,,.T.,CLR_BLUE,,60,20)
    oTGet1 	:= TGet():New(30,335,{|u| if( PCount() > 0, cContato := u, cContato ) } ,oPanel,55,009,"",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"cContato")

    oSay1	:= TSay():New(45,255,{||'Telefone*'},oPanel,,oFont4,,,,.T.,CLR_BLUE,,60,20)
    oTGet1 	:= TGet():New(45,335,{|u| if( PCount() > 0, cTelefone := u, cTelefone ) } ,oPanel,55,009,"@R (#9#)999999999999",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"cTelefone")

    oSay1	:= TSay():New(60,255,{||'Telefone Compl.'},oPanel,,oFont4,,,,.T.,CLR_BLUE,,60,20)
    oTGet1 	:= TGet():New(60,335,{|u| if( PCount() > 0, cTele2 := u, cTele2 ) } ,oPanel,55,009,"@R (#9#)999999999999",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"cTele2")

    oSay1	:= TSay():New(75,255,{||'E-mail*'},oPanel,,oFont4,,,,.T.,CLR_BLUE,,60,20)
    oTGet1 	:= TGet():New(75,295,{|u| if( PCount() > 0, cEmail := u, cEmail ) } ,oPanel,95,009,"",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"cEmail")

    oSay1	:= TSay():New(90,255,{||'Banco'},oPanel,,oFont4,,,,.T.,CLR_BLUE,,60,20)
    oCmbBco := TComboBox():New(90,295,{|u|if(PCount()>0,cCmbBco:=u,cCmbBco)},aBco,95,009,oPanel,,,,,,.T.,,,,,,,,,'cCmbBco')

    oSay1	:= TSay():New(105,255,{||'Agencia'},oPanel,,oFont4,,,,.T.,CLR_BLUE,,60,20)
    oTGet1 	:= TGet():New(105,335,{|u| if( PCount() > 0, cAge := u, cAge ) } ,oPanel,35,009,"",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"cAge")
    oTGet1 	:= TGet():New(105,375,{|u| if( PCount() > 0, cDigAge := u, cDigAge ) } ,oPanel,15,009,"",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"cDigAge")

    oSay1	:= TSay():New(120,255,{||'Conta Corrente'},oPanel,,oFont4,,,,.T.,CLR_BLUE,,60,20)
    oTGet1 	:= TGet():New(120,335,{|u| if( PCount() > 0, cCta := u, cCta ) } ,oPanel,35,009,"",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"cCta")
    oTGet1 	:= TGet():New(120,375,{|u| if( PCount() > 0, cDigCta := u, cDigCta ) } ,oPanel,15,009,"",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"cDigCta")

    oSay1	:= TSay():New(135,255,{||'Condição Pagamento*'},oPanel,,oFont4,,,,.T.,CLR_BLUE,,90,20)
    oTGet1 	:= TGet():New(135,335,{|u| if( PCount() > 0, cCond := u, cCond ) } ,oPanel,55,009,"",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,'SE4',"cCond")

    oSay1	:= TSay():New(150,255,{||'Natureza*'},oPanel,,oFont4,,,,.T.,CLR_BLUE,,80,20)
    oTGet1 	:= TGet():New(150,330,{|u| if( PCount() > 0, cNaturez := u, cNaturez ) } ,oPanel,60,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,'SED',"cNaturez")

    oSay1	:= TSay():New(165,255,{||'Observações'},oPanel,,oFont4,,,,.T.,CLR_BLUE,,50,20)
    oTGet1  := tMultiget():new( 175, 255, {| u | if( pCount() > 0, sObs := u, sObs ) }, oPanel, 140, 25, , , , , , .T. )

    //Fim Ticket     35  -  Adriana Oliveira- 28/09/2020

    //oSay1	:= TSay():New(135,150,{||'Produtor Rural'},oPanel,,oFont4,,,,.T.,CLR_BLUE,,60,20)
    //oCombo2 := TComboBox():New(135,210,{|u|if(PCount()>0,cCombo2:=u,cCombo2)},aItens2,30,009,oPanel,,{||PictureCGC(cCombo1, cCombo2, cEst, oPanel)},,,,.T.,,,,,,,,,'cCombo2')

    //oSay1	:= TSay():New(150,160,{||'Descontar IPR'},oPanel,,oFont4,,,,.T.,CLR_BLUE,,60,20)
    //oCombo3 := TComboBox():New(150,210,{|u|if(PCount()>0,cCombo3:=u,cCombo3)},aItens3,30,009,oPanel,,,,,,.T.,,,,{|| IIf(oCombo2:aItems[oCombo2:NAT]='Sim',.T.,.F.) },,,,,'cCombo3',,,,)

    //oSay1	:= TSay():New(165,10,{||'Incrição Estadual'},oPanel,,oFont4,,,,.T.,CLR_BLUE,,80,20)
    //oTGet1 	:= TGet():New(165,80,{|u| if( PCount() > 0, cIe := u, cIe ) } ,oPanel,60,009,"@!",{|| VldIE(cIe, cEst) },0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"cIe")

    //oSay1	:= TSay():New(15,10,{||'Razão Social/ Nome*'},oPanel,,oFont4,,,,.T.,CLR_BLUE,,80,20)	
    //oTGet1 	:= TGet():New(15,80,{|u| if( PCount() > 0, cNomeFor := u, cNomeFor ) } ,oPanel,140,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"cNomeFor")

    //oSay1	:= TSay():New(180,170,{||'RG'},oPanel,,oFont4,,,,.T.,CLR_BLUE,,100,20)
    //oTGet1 	:= TGet():New(180,180,{|u| if( PCount() > 0, nRG := u, nRG ) } ,oPanel,55,009,"",{|| VldRG( nRG ) },0,,,.F.,,.T.,,.F.,{|| Iif(oCombo1:aItems[oCombo1:NAT]='Fisica',.T.,.F.) } ,.F.,.F.,,.F.,.F.,,"nRG")

    // Ticket 39 - Projeto RM - FWNM - 12/11/2020
    oSay1	 := TSay():New(195,10,{||'Integra RM?'},oPanel,,oFont4,,,,.T.,CLR_BLUE,,60,20)
    oComboRM := TComboBox():New(195,70,{|u|if(PCount()>0,cComboRM:=u,cComboRM)},aItensRM,30,009,oPanel,,,,,,.T.,,,,,,,,,'cComboRM',,,,)

    oSay1	 := TSay():New(210,10,{||'(RM) Chapa-Nome Funcionário'},oPanel,,oFont4,,,,.T.,CLR_BLUE,,80,20)
    oTGet1 	 := TGet():New(210,70,{|u| if( PCount() > 0, cRMFunc := u, cRMFunc ) } ,oPanel,330,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"cRMFunc")
    //

Return  

/*/{Protheus.doc} Static Function valida_pg1
   
    @type  Function
    @author Ricardo Lima
    @since 12/12/2017
    @version 01
    
/*/
 //CHAMADO: 054075 - ADRIANO SAVOINE 13/12/2019 - Inserido cCodFor,cLojFor no valida_pg1
Static Function valida_pg1( cCodFor,cLojFor,cNomeFor , cNomeFan , cEnd , cBairro, cCodCid , cCidade , cEst , cCep , cCnpj , cIe , cIm, sObs, aItens1, cCombo1, dDataNasc, cNum, cPais, cCodPais, cNaturez, cContato, cTelefone, cTele2, cEmail, cBco, cAge, cCta, cCond, cDigAge, cDigCta, nRG )

 Local lVldChk := .T.

 
 If cEst = 'EX'
    lVldChk := .T.
    Return lVldChk
 Endif
 
 IF EMPTY(cCnpj)
 	lVldChk := .F.
    ApMsgInfo('O campo Cnpj não foi Preenchido, Verifique!','Prospect de Fornecedor')
 else
    If oCombo2:aItems[oCombo2:NAT] = 'Não'
       // Chamado 055585 - Adriano / Abel       - 14/02/2020
        cIE := RetCEsp(cIe)
        cIe := cIe + Space(18-Len(cIe))
        //Chamado 055585 - Adriano / Abel       - 14/02/2020

        // *** INICIO WILLIAM 08/11/2019 CHAMADO 053083 || OS 054465 || FINANCAS || TATIANE || 8351 || CAD. FORNECEDORES
        //CHAMADO: 054075 - ADRIANO SAVOINE 13/12/2019 - Inserido no SqlFornece cCodFor,cLojFor
        SqlFornece(cCodFor,cLojFor,ALLTRIM(STRTRAN(STRTRAN(cCnpj, ".", "" ), "-", "" )))
        While TRB->(!EOF())       

            IF ALLTRIM(STRTRAN(STRTRAN(cCnpj, ".", "" ), "-", "" ))  == ALLTRIM(STRTRAN(STRTRAN(TRB->A2_CGC, ".", "" ), "-", "" )) .AND. ;
               ALLTRIM(STRTRAN(cIE, ".", "" ))                       == ALLTRIM(STRTRAN(TRB->A2_INSCR, ".", "" )) 
                
                lVldChk := .F.
                ApMsgInfo('Esse Cnpj já foi utilizado no Fornecedor: '+TRB->A2_COD+'-'+Alltrim(TRB->A2_NOME)+', Verifique!','Prospect de Fornecedor')

            ENDIF

            // *** INICIO WILLIAM 05/12/2019 CHAMADO 053833 || OS 055225 || FINANCAS || TATIANE || 8351 || CAD. FORNECEDORES

            IF lVldChk == .T.
                IF ALLTRIM(STRTRAN(STRTRAN(cCnpj, ".", "" ), "-", "" ))  == ALLTRIM(STRTRAN(STRTRAN(TRB->A2_CGC, ".", "" ), "-", "" )) .AND. ;
                ALLTRIM(STRTRAN(cIE, ".", "" ))                       == 'ISENTO'                                                   .AND. ;
                (ALLTRIM(STRTRAN(TRB->A2_INSCR, ".", "" ))            == ''                                                          .OR. ;
                ALLTRIM(STRTRAN(TRB->A2_INSCR, ".", "" ))             == 'ISENTO')
                    
                    lVldChk := .F.
                    ApMsgInfo('Essa Inscrição Estadual está marcado como isento, já existe um CNPJ com a Inscrição Isento ou branco, não pode continuar o cadastro' + ', Verifique!','Prospect de Fornecedor')
                    ApMsgInfo('Esse Cnpj já foi utilizado no Fornecedor: '+TRB->A2_COD+'-'+Alltrim(TRB->A2_NOME)+', Verifique!','Prospect de Fornecedor')
    
                ENDIF
            ENDIF

            IF lVldChk == .T.

                IF ALLTRIM(STRTRAN(STRTRAN(cCnpj, ".", "" ), "-", "" ))  == ALLTRIM(STRTRAN(STRTRAN(TRB->A2_CGC, ".", "" ), "-", "" )) .AND. ;
                    ALLTRIM(STRTRAN(cIE, ".", "" ))            == ''                                                                    .AND. ;
                    (ALLTRIM(STRTRAN(TRB->A2_INSCR, ".", "" )) == ''                                                                     .OR. ;
                    ALLTRIM(STRTRAN(TRB->A2_INSCR, ".", "" ))  == 'ISENTO')
                    
                    lVldChk := .F.
                    ApMsgInfo('Essa Inscrição Estadual está marcado como branco, já existe um CNPJ com a Inscrição Isento ou branco, não pode continuar o cadastro' + ', Verifique!','Prospect de Fornecedor')
                    ApMsgInfo('Esse Cnpj já foi utilizado no Fornecedor: '+TRB->A2_COD+'-'+Alltrim(TRB->A2_NOME)+', Verifique!','Prospect de Fornecedor')
    
                ENDIF
            ENDIF
            // *** FINAL WILLIAM 05/12/2019 CHAMADO 053833 || OS 055225 || FINANCAS || TATIANE || 8351 || CAD. FORNECEDORES
            
            TRB->(dbSkip())
                    
        ENDDO
        TRB->(dbCloseArea())
           
       
        // *** FINAL WILLIAM 08/11/2019 CHAMADO 053083 || OS 054465 || FINANCAS || TATIANE || 8351 || CAD. FORNECEDORES
 
    Else 
	    If SA2->A2_XPRECAD <> "3" // Recusado // Chamado n. 049218 || OS 050526 || FINANCAS || ANDREA || 8319 || CAD. FORNECEDOR - fwnm - 28/08/2019
	    	lVldChk := U_ADCOM024P(cCnpj , Alltrim(cIe))
	    EndIf
    Endif
 ENDIF

 IF EMPTY(cCep)
 	lVldChk := .F.
    ApMsgInfo('O campo CEP não foi Preenchido, Verifique!','Prospect de Fornecedor') 
 ENDIF     
 //Inicio: Chamado: 049800 - Fernando sigoli 11/06/2019 
 IF EMPTY(cCond)
 	lVldChk := .F.
    ApMsgInfo('O campo Condicao de pagamento não foi Preenchido, Verifique!','Prospect de Fornecedor') 
 ENDIF     
 //Fim: Chamado: 049800 - Fernando sigoli 11/06/2019 
 
  //  Inserido nova validação que não permite inserir um codigo de pagamento que não exista no banco de dados.
 //  Inicio: Feito por Adriano Savoine 30/07/2019 no chamado 050760.
 DbSelectArea("SE4")
 IF !DbSeek( FWxFilial("SE4") + cCond, .T. )
 
 	lVldChk := .F.
    ApMsgInfo('A Condição de Pagamento não Existe na Base de dados Verifique!')
           
 ENDIF 
 //  Fim: Feito por Adriano Savoine 30/07/2019 no chamado 050760.

 if oCombo1:aItems[oCombo1:NAT] = 'Fisica' .and. oCombo2:aItems[oCombo2:NAT] <> 'Sim' //Ticket     35  -  Adriana Oliveira- 28/09/2020
    if Empty(dDataNasc)
        lVldChk := .F. 	    
        ApMsgInfo('Cliente pessoa Fisica é Obrigátorio Data de Nascimento!','Prospect de Fornecedor')
    EndIf
    if Empty(nRG)
        lVldChk := .F. 	    
        ApMsgInfo('Cliente pessoa Fisica é Obrigátorio RG!','Prospect de Fornecedor')
    EndIf
 EndIf

 if oCombo1:aItems[oCombo1:NAT] = 'Juridica'
    if Empty(cIe) .AND. EMPTY(cIm)
        lVldChk := .F. 	    
        ApMsgInfo('Cliente pessoa Juridica é Obrigátorio o preenchimento da Incrição estadual ou Municipal','Prospect de Fornecedor')
    EndIf
 EndIf

 IF EMPTY(cNomeFor)
 	lVldChk := .F.
    ApMsgInfo('O campo Razão Social não foi Preenchido, Verifique!','Prospect de Fornecedor')
 ENDIF

 IF EMPTY(cNomeFan)
 	lVldChk := .F.
    ApMsgInfo('O campo Nome Fantasia não foi Preenchido, Verifique!','Prospect de Fornecedor')
 ENDIF

 IF EMPTY(cEnd)
 	lVldChk := .F.
    ApMsgInfo('O campo Endereço não foi Preenchido, Verifique!','Prospect de Fornecedor')
 ENDIF

 IF EMPTY(cNum)
    lVldChk := .F.
    ApMsgInfo('O campo Numero não foi Preenchido, Verifique!','Prospect de Fornecedor')
 ENDIF

 IF EMPTY(cBairro)
 	lVldChk := .F.
    ApMsgInfo('O campo Bairro não foi Preenchido, Verifique!','Prospect de Fornecedor')
 ENDIF

 IF EMPTY(cCodCid)
 	lVldChk := .F.
    ApMsgInfo('O campo Codigo de Cidade não foi Preenchido, Verifique!','Prospect de Fornecedor')
 ENDIF

 IF EMPTY(cCidade)
 	lVldChk := .F.
    ApMsgInfo('O campo Cidade não foi Preenchido, Verifique!','Prospect de Fornecedor')
 ENDIF

 IF EMPTY(cEst)
 	lVldChk := .F.
    ApMsgInfo('O campo Estado não foi Preenchido, Verifique!','Prospect de Fornecedor')
 ENDIF

 IF EMPTY(cCep)
 	lVldChk := .F.
    ApMsgInfo('O campo CEP não foi Preenchido, Verifique!','Prospect de Fornecedor')
 ENDIF

 /*
 IF EMPTY(cPais)
 	lVldChk := .F.
    ApMsgInfo('O campo Pais não foi Preenchido, Verifique!','Prospect de Fornecedor')
 ENDIF
*/

 IF EMPTY(cCodPais)
 	lVldChk := .F.
    ApMsgInfo('O campo Codigo do Pais não foi Preenchido, Verifique!','Prospect de Fornecedor')
 ENDIF

 IF EMPTY(cNaturez)
 	lVldChk := .F.
    ApMsgInfo('O campo Natureza não foi Preenchido, Verifique!','Prospect de Fornecedor')
 ENDIF
 //  Inserido nova validação que não permite inserir um codigo de natureza que não exista no banco de dados.
 //  Feito por Adriano Savoine 18/07/2019 no chamado 050498.
 DbSelectArea("SED")
 IF DbSeek( FWxFilial("SED") + cNaturez, .T. )
    
 ELSE
 
 	lVldChk := .F.
    ApMsgInfo('O codigo Natureza não Existe na Base de dados Verifique!')
           
 ENDIF
 IF EMPTY(cTelefone)
 	lVldChk := .F.
    ApMsgInfo('O campo Telefone não foi Preenchido, Verifique!','Prospect de Fornecedor')
 ENDIF
 // Inserida nova Validação para o campo Email não permitindo entrar vazio 
 // Feito por Adriano Savoine 22/04/2019 no chamado 048664. 
 IF EMPTY(cEmail)
 	lVldChk := .F.
    ApMsgInfo('O campo Email não foi Preenchido, Verifique!','Prospect de Fornecedor')
 ENDIF 

 // Ticket 39 - Projeto RM - FWNM - 12/11/2020
 If oComboRM:aItems[oComboRM:NAT] == 'Sim'
    If Empty(AllTrim(cRMFunc))
        lVldChk := .F.
        Alert("Obrigatório informar o número da coligada, chapa e do funcionário/pensionista quando integra RM = Sim")
    EndIf
 EndIf
 //

Return lVldChk

/*/{Protheus.doc} Static Function cria_pn2
   
    @type  Function
    @author Ricardo Lima
    @since 12/12/2017
    @version 01
    
/*/
 
Static Function cria_pn2(oPanel)	
	   
    Local oSay1
    Local oFont1 := TFont():New('Courier new',,-18,.T.)
    Local oFont2 := TFont():New('Courier new',,-18,.T.)       
    
    oFont2:Bold := .T.                
    
    oSay1:= TSay():New(20,10,{||'Dados Preenchidos com Sucesso!'},oPanel,,oFont2,,,,.T.,,,370,20)
    oSay1:= TSay():New(40,10,{||'A partir desse momento, será gerado o Pré-Cadastro;'},oPanel,,oFont1,,,,.T.,,,370,20)
    oSay1:= TSay():New(50,10,{||'O mesmo será analisado e efetivado, após a Conclusão do Cadastro, você receberá um retorno com o Codigo do Fornecedor.'},oPanel,,oFont1,,,,.T.,,,370,20)    
 
Return

/*/{Protheus.doc} Static Function salva_con
   
    @type  Function
    @author Ricardo Lima
    @since 12/12/2017
    @version 01
    
/*/
Static Function salva_con( cNomeFor , cNomeFan , cEnd , cBairro, cCodCid , cCidade , cEst , cCep , cCnpj , cIe , cIm , sObs, aItens1, cCombo1, dDataNasc, cNum, cPais, cCodPais, cNaturez, cContato, cTelefone, cTele2, cEmail, cBco, cAge, cCta, cCond, cDigAge, cDigCta, nRG )

	Local cMensagem := ""
	Local cAssunto  := "Fornecedor Bloqueado na empresa: " + Alltrim(FWGrpName(cempant)) // Por Adriana Oliveira em 16/10/2019 - Chamado 052327
	Local cQuery	 := ""
	Local cDestMail := ""
	
	Local cCodFor := U_SXESXF("SA2") //GETSX8NUM("SA2") // por Adriana Oliveira- 30/07/2020
	Local cLojFor := "01"
	Local lCodFor := .T.
    Local sDescrSE4 := ""
    
    Local lGrvSA2 := .T. // Chamado n. 049218 || OS 050526 || FINANCAS || ANDREA || 8319 || CAD. FORNECEDOR - fwnm - 28/08/2019 
    
    // Chamado n. 049218 || OS 050526 || FINANCAS || ANDREA || 8319 || CAD. FORNECEDOR - fwnm - 28/08/2019
    If SA2->A2_XPRECAD == "3" // Recusado
    	lGrvSA2 := .F.
    	cCodFor := SA2->A2_COD
    	cLojFor := SA2->A2_LOJA
    	cAssunto := "[Recusa Projeto - Correção] - Fornecedor bloqueado novamente após correções na empresa: " +Alltrim(FWGrpName(cempant)) // Por Adriana Oliveira em 16/10/2019 - Chamado 052327

		PswOrder(2) // Ordem de nome
		If PswSeek( AllTrim(SA2->A2_USERALT), .T. )
			aRetUser  := PswRet(1)
			cDestMail := Upper(Alltrim(aRetUser[1,14]))
		EndIf	 
	//
    Else
		WHILE lCodFor		
			DbSelectArea("SA2")
			DbSetOrder(1)
			if DbSeek( xFilial("SA2") + cCodFor + cLojFor )			
				cCodFor := Soma1(cCodFor)
			else
				lCodFor := .F.
			endif		
		END
	
	EndIf

    DbSelectArea("SE4")
    DbSetOrder(1)
    If DbSeek( FWxFilial("SE4") + cCond )
        sDescrSE4 := SE4->E4_DESCRI
    Endif

    // Ticket 39 - Projeto RM - FWNM - 12/11/2020
    If AllTrim(cComboRM) == "Sim"
        cCodFor := SXESXFRM()
    EndIf
    //

	//if reclock('SA2',.T.) // Chamado n. 049218 || OS 050526 || FINANCAS || ANDREA || 8319 || CAD. FORNECEDOR - fwnm - 28/08/2019
	If RecLock("SA2", lGrvSA2)// Chamado n. 049218 || OS 050526 || FINANCAS || ANDREA || 8319 || CAD. FORNECEDOR - fwnm - 28/08/2019 
            
		// Chamado n. 049218 || OS 050526 || FINANCAS || ANDREA || 8319 || CAD. FORNECEDOR - fwnm - 28/08/2019
		If lGrvSA2
			SA2->A2_COD     := cCodFor 
			SA2->A2_LOJA    := cLojFor
			SA2->A2_CGC     := cCnpj
			SA2->A2_USERINC := CUSERNAME
			SA2->A2_DTINC   := DATE() 
		Else
			SA2->A2_USERALT := CUSERNAME
			SA2->A2_DTALT   := DATE() 
		EndIf
		//

		SA2->A2_NOME    := cNomeFor
		SA2->A2_NREDUZ  := cNomeFan
    	SA2->A2_END     := Alltrim(cEnd) +', '+ Alltrim(cNum)
		SA2->A2_BAIRRO  := cBairro
        SA2->A2_COD_MUN := cCodCid
		SA2->A2_MUN     := cCidade
		SA2->A2_EST     := cEst
		SA2->A2_CEP     := cCep
		SA2->A2_INSCR   := cIe
		SA2->A2_INSCRM  := cIm
		SA2->A2_MSBLQL  := "1"
		SA2->A2_XOBSPP  := sObs + chr(13)+chr(10) + 'Condição de Pagamento: ' + cCond+"-"+sDescrSE4 + chr(13)+chr(10) + 'Banco: ' + oCmbBco:aItems[oCmbBco:NAT] + chr(13)+chr(10)+"Usuario Pré-Cadastro: "+CUSERNAME+", Data Inclusão: "+Dtoc(Date())
        SA2->A2_NATUREZ := cNaturez
        SA2->A2_CODPAIS := cCodPais
        SA2->A2_PAIS    := SUBSTR(cCodPais,2,3)
        SA2->A2_DTNASC  := dDataNasc
        IF oCombo1:aItems[oCombo1:NAT] = 'Fisica'
            SA2->A2_TIPO := 'F'
            SA2->A2_PFISICA  := nRG // - Novo Campo
        else
            SA2->A2_TIPO := 'J'
        endif
        SA2->A2_CONTATO := cContato
        SA2->A2_DDD     := Substr(Alltrim(cTelefone),1,3)
        SA2->A2_TEL     := Substr(Alltrim(cTelefone),4,11)
        SA2->A2_TELRE   := Substr(Alltrim(cTele2),4,11)
        SA2->A2_EMAIL   := cEmail
        SA2->A2_BANCO   := SUBSTR( oCmbBco:aItems[oCmbBco:NAT],1,3)
        SA2->A2_AGENCIA := cAge
        SA2->A2_DIGAG   := cDigAge
        SA2->A2_DIGCTA  := cDigCta
        SA2->A2_NUMCON  := cCta
        SA2->A2_COND    := cCond
         DbSelectArea("SED")
         DbSetOrder(1)
         if DbSeek( XFILIAL("SED") + cNaturez )
            SA2->A2_CONTA := IIF(cCodPais='01058','211110001', Iif(cEst='EX','211110002',SED->ED_CONTA ))
         EndIf
		SA2->A2_XTIPO := '3' // OUTROS
        SA2->A2_INDRUR := IIf( oCombo2:aItems[oCombo2:NAT] = 'Sim' , '1' , '0' ) //Ticket     35  -  Adriana Oliveira- 28/09/2020
        SA2->A2_XPR := IIf( oCombo2:aItems[oCombo2:NAT] = 'Sim' , '1' , '2' )
        SA2->A2_XDI := Iif( oCombo3:aItems[oCombo3:NAT] = 'Sim'.AND.oCombo2:aItems[oCombo2:NAT] = 'Sim' , '1' , '2' )
        SA2->A2_XBLQZCL := '2'                          
        
        /* Desabilitado pois nao utilizamos mais a GETSX8NUM - por Adriana em 10/08/2020
        // Chamado n. 049218 || OS 050526 || FINANCAS || ANDREA || 8319 || CAD. FORNECEDOR - fwnm - 28/08/2019
    	If lGrvSA2
    		ConfirmSx8()
    	EndIf
    	//
        */

		SA2->A2_XPRECAD := "1" // Ricardo Lima - 02/03/18

        // Ticket 39 - Projeto RM - FWNM - 12/11/2020
        If AllTrim(cComboRM) == "Sim"
            SA2->A2_XRM     := Left(AllTrim(cComboRM),1)
            SA2->A2_XRMFUNC := cRMFunc
        EndIf
        //

        msunlock('SA2')
    	
    	cMensagem := u_MntMsc( SA2->A2_COD , SA2->A2_LOJA , SA2->A2_NOME , SA2->A2_CGC , SA2->A2_INSCR , SA2->A2_END , SA2->A2_BAIRRO , SA2->A2_MUN , SA2->A2_USERINC , SA2->A2_DTINC , "I" , SA2->A2_XOBSPP )
	
		IF !EMPTY(sEmailDt) .or. !Empty(cDestMail) 
            U_F50En2WF( sEmailDt+';'+cDestMail , '' , cAssunto , cMensagem , '' )
		ENDIF
    	    	    	
    else
        /* Desabilitado pois nao utilizamos mais a GETSX8NUM - por Adriana em 10/08/2020
        // Chamado n. 049218 || OS 050526 || FINANCAS || ANDREA || 8319 || CAD. FORNECEDOR - fwnm - 28/08/2019
    	If lGrvSA2
    		RollbackSx8()
    	EndIf
    	//
        */
    endif

Return( .T. )


/*/{Protheus.doc} Static Function VldCNPJ
   
    @type  Function
    @author Ricardo Lima
    @since 12/12/2017
    @version 01
    
/*/

Static Function VldCNPJ( nCnpj , cEst)

    Local lRet       := .T.

    // *** INICIO WILLIAM COSTA 20/09/2019 - CHAMADO 051581 || OS 052901 || FINANCAS || TATIANE || 8351 || VALIDACAO CPF

    IF !Empty(nCnpj) .AND. cEst <> 'EX'

        IF oCombo1:aItems[oCombo1:NAT] = 'Juridica' .or. ;
            (oCombo1:aItems[oCombo1:NAT] = 'Fisica' .and. ;
                cEst = "SP" .and. oCombo2:aItems[oCombo2:NAT] = "Sim") //Ticket     35  -  Adriana Oliveira- 28/09/2020
 
            IF lRet == .T. .AND. LEN(ALLTRIM(nCnpj)) < 14

                ApMsgInfo('O campo Cnpj não pode ser menor que 14 numeros verifique!','Prospect de Fornecedor')
                lRet := .F.

            ENDIF

            IF lRet == .T.

                lRet := (CGC( nCnpj ) .And. A020VldUCod())

            ENDIF

        ELSE //CPF

            IF lRet == .T. .AND. LEN(ALLTRIM(nCnpj)) < 11

                ApMsgInfo('O campo de CPF não pode ser menor que 11 numeros verifique!','Prospect de Fornecedor')
                lRet := .F.

            ENDIF
        ENDIF
    ENDIF

    // *** FINAL WILLIAM COSTA 20/09/2019 - CHAMADO 051581 || OS 052901 || FINANCAS || TATIANE || 8351 || VALIDACAO CPF

Return lRet

/*/{Protheus.doc} Static Function VldIE
   
    @type  Function
    @author Ricardo Lima
    @since 12/12/2017
    @version 01
    
/*/

Static Function VldIE(cIe, cEst)

    Local lRet := .T.

    //Retirando caracteres
    cIe := StrTran(cIe, "'", "")
    cIe := StrTran(cIe, "#", "")
    cIe := StrTran(cIe, "%", "")
    cIe := StrTran(cIe, "*", "")
    cIe := StrTran(cIe, "&", "")
    cIe := StrTran(cIe, ">", "")
    cIe := StrTran(cIe, "<", "")
    cIe := StrTran(cIe, "!", "")
    cIe := StrTran(cIe, "@", "")
    cIe := StrTran(cIe, "$", "")
    cIe := StrTran(cIe, "(", "")
    cIe := StrTran(cIe, ")", "")
    cIe := StrTran(cIe, "-", "") //chamado 057996
    cIe := StrTran(cIe, "_", "")
    cIe := StrTran(cIe, "=", "")
    cIe := StrTran(cIe, "+", "")
    cIe := StrTran(cIe, "{", "")
    cIe := StrTran(cIe, "}", "")
    cIe := StrTran(cIe, "[", "")
    cIe := StrTran(cIe, "]", "")
    cIe := StrTran(cIe, "/", "")
    cIe := StrTran(cIe, "?", "")
    cIe := StrTran(cIe, ".", "")
    cIe := StrTran(cIe, "\", "")
    cIe := StrTran(cIe, "|", "")
    cIe := StrTran(cIe, ":", "")
    cIe := StrTran(cIe, ";", "")
    cIe := StrTran(cIe, '"', '')
    cIe := StrTran(cIe, '°', '')
    cIe := StrTran(cIe, 'ª', '')
    cIe := StrTran(cIe, ' ', '')
    cIe := cIe + Space(18-Len(cIe))

    If oCombo1:aItems[oCombo1:NAT] = 'Juridica'
        lRet := IE(cIe, cEst) .And. A020VldUCod()
    EndIf

Return lRet


/*/{Protheus.doc} Static Function VldCNPJ
   
    @type  Function
    @author Ricardo Lima
    @since 12/12/2017
    @version 01
   
    
/*/

Static Function VldRG( nRG )

Local lRet := .T.

If oCombo1:aItems[oCombo1:NAT] = 'Fisica'
   A020VldUCod()
EndIf

Return lRet

/*/{Protheus.doc} Static Function FNMNTBCO
   
    @type  Function
    @author Ricardo Lima
    @since 12/12/2017
    @version 01
    
/*/

Static Function FNMNTBCO()

	Local aRet 		:= {}
	Local cQuery	:= "" //Everson 11/12/2018. Chamado 045441.

	//Everson 11/12/2018. Chamado 045441.
	cQuery := ""
	cQuery += " SELECT  " 
	cQuery += " X5_CHAVE, X5_DESCRI  " 
	cQuery += " FROM  " 
	cQuery += " " + RetSqlName("SX5") + " (NOLOCK) SX5 " 
	cQuery += " WHERE " 
	cQuery += " X5_FILIAL = '" + FWxFilial("SX5") + "' " // Por Adriana Oliveira em 16/10/2019 - Chamado 052327
	cQuery += " AND X5_TABELA = '_U'  " 
	cQuery += " AND SX5.D_E_L_E_T_ = '' ORDER BY X5_CHAVE " 
	
	If Select("D_BANCOS") > 0
		D_BANCOS->(DbCloseArea())
		
	EndIf
	
	//
	TcQuery cQuery New Alias "D_BANCOS"
	DbSelectArea("D_BANCOS")
	D_BANCOS->(DbGoTop())
	Aadd(aRet,"")
	While ! D_BANCOS->(Eof())
		Aadd(aRet,Alltrim(cValToChar(D_BANCOS->X5_CHAVE)) + "-" +Alltrim(cValToChar(D_BANCOS->X5_DESCRI)))
		//Conout("ADCOM015P - " + Alltrim(cValToChar(D_BANCOS->X5_CHAVE)) + "-" +Alltrim(cValToChar(D_BANCOS->X5_DESCRI)))
		D_BANCOS->(DbSkip())
		
	End
	//
	
Return aRet

/*/{Protheus.doc} User Function ADCOM15
   
    @type  Function
    @author Ricardo Lima
    @since 12/12/2017
    @version 01
    
/*/

User Function ADCOM15( cCodEmp , cCodFil )  // Ricardo Lima-15/02/2019

Local cMensagem := ""
Local cAssunto  := "Fornecedor Bloqueado pendente para Analise - " // Por Adriana Oliveira em 16/10/2019 - Chamado 052327
Local cDestMail := ""
Local cQuery    := ""
Local lAutoJob := .F.
Local sEmailDt := ""

    If Select("SX6") == 0
	    lAutoJob := .T.
    EndIf

    IF lAutoJob
        
        RPCClearEnv()
        RpcSetType(3)
        RpcSetEnv( cCodEmp , cCodFil ) // Ricardo Lima-15/02/2019
        
        // Garanto uma única thread sendo executada - // Adoro - Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - fwnm - 30/06/2020
        If !LockByName("ADCOM015P"+cEmpAnt, .T., .F.)
            ConOut("[ADCOM015P] - Existe outro processamento sendo executado! Verifique...")
            RPCClearEnv()
            Return
        EndIf
        
        ConOut( "Inicio - Workflow Fornecedor Bloqueado pendente para Analise - " + time() )

        sEmailDt := SuperGetMv( "MV_#EMLWF1" , .F. , '' ,  )+';'+SuperGetMv( "MV_#EMLWF2" , .F. , '' ,  )

    EndIf

    U_ADINF009P('ADCOM015P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

    cQuery := " SELECT A2_COD , A2_LOJA "
    cQuery += " FROM "+RetSqlName("SA2")+" "
    cQuery += " WHERE A2_XPRECAD = '1' "
    cQuery += " AND D_E_L_E_T_ = ' ' "
    If Select("ADCOMB015") > 0
   		ADCOM15->(DbCloseArea())		
   	EndIf	
   	TcQuery cQuery New Alias "ADCOM15"

    WHILE ADCOM15->( !EOF() )   

        DbSelectArea("SA2")
        DbSetOrder(1)
        DbSeek( FWxFilial("SA2") + ADCOM15->A2_COD + ADCOM15->A2_LOJA )

        cMensagem := u_MntMsc( SA2->A2_COD , SA2->A2_LOJA , SA2->A2_NOME , SA2->A2_CGC , SA2->A2_INSCR , SA2->A2_END , SA2->A2_BAIRRO , SA2->A2_MUN , SA2->A2_USERINC , SA2->A2_DTINC , "I" , SA2->A2_XOBSPP )
    
        IF !EMPTY(sEmailDt) 
            U_F50En2WF( sEmailDt , '' , cAssunto + Alltrim(FWGrpName(cempant)) , cMensagem , '' ) // Por Adriana Oliveira em 11/02/2020 - Chamado TI
        ENDIF

        ADCOM15->( DbSkip() )
	END

    IF lAutoJob

        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
        //³Destrava a rotina para o usuário	    ?
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
        UnLockByName("ADCOM015P"+cEmpAnt)

        RpcClearEnv()

        ConOut( "Termino - Workflow Fornecedor Bloqueado pendente para Analise - " + time() )

    EndIf

Return
    //CHAMADO: 054075 - ADRIANO SAVOINE 13/12/2019 - Inserido as Variaveis cCodFor,cLojFor 
STATIC FUNCTION  SqlFornece(cCodFor,cLojFor,cCnpj)

    LOCAL cCodLoja:=''

    cCodLoja:= cCodFor+cLojFor //CHAMADO: 054075 - ADRIANO SAVOINE 13/12/2019
    
    BeginSQL Alias "TRB"
    %NoPARSER%  

    SELECT A2_COD,
           A2_LOJA,
           A2_NOME,
           A2_CGC,
           A2_INSCR
      FROM %TABLE:SA2%
     WHERE A2_CGC = %EXP:cCnpj%
        AND A2_COD + A2_LOJA <> %EXP:cCodLoja% //CHAMADO: 054075 - ADRIANO SAVOINE 13/12/2019
        AND D_E_L_E_T_ <> '*'
        
    EndSQl 
RETURN(NIL)

/*/{Protheus.doc} Static Function PictureCGC
    Recria campo de solicitação de CNPJ / CPF conforme conteúdo do Combo1
    @type  Function
    @author Abel Babini
    @since 14/02/2020
    @version 1
    @history Chamado 055585 - Adriano / Abel    - 14/02/2020
    @history Ticket      35 - Adriana Oliveira  - 28/09/2020 - inclui tratamento para produtor rural
    @history Ticket    6648 - Adriano Savoine   - 15/12/2020 - Eliminado da Static Function o Metodo FreeChildren pois ele elimina todos os objetos da classe e causava error log ao mudar o combo produtor rural.

    /*/

STATIC FUNCTION PictureCGC(cCombo1, cCombo2, cEst, oPanel)

    //oTGetTipo:FreeChildren() - 15/12/2020 - Ticket: 6648 - Adriano Savoine
    
    If cCombo1 == "Fisica" .and. cEST = "SP" .and. cCombo2 = "Sim"
   		oTGetTipo 	:= TGet():New(150,80,{|u| if( PCount() > 0, cCnpj := u, cCnpj ) } ,oPanel,60,009,'@R 99.999.999/9999-99',{|| VldCNPJ(cCnpj, cEst, cCombo2) },0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"cCnpj")
     Elseif cCombo1 == "Fisica" .and. !(cEST = "SP" .and. cCombo2 = "Sim")
   		oTGetTipo 	:= TGet():New(150,80,{|u| if( PCount() > 0, cCnpj := u, cCnpj ) } ,oPanel,60,009,'@R 999.999.999-99',{|| VldCNPJ(cCnpj, cEst, cCombo2) },0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"cCnpj")
    Else 
   		oTGetTipo 	:= TGet():New(150,80,{|u| if( PCount() > 0, cCnpj := u, cCnpj ) } ,oPanel,60,009,'@R 99.999.999/9999-99',{|| VldCNPJ(cCnpj, cEst, cCombo2) },0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"cCnpj")
    EndIf
    oTGetTipo:OGET:CtrlRefresh(.T.)
    oPanel:Refresh(.T.)
    oTGetTipo:SetFocus(.T.)

RETURN(NIL)

/*/{Protheus.doc} Static Function RetCEsp
    Retira caracteres especiais
    @type  Function
    @author Abel Babini
    @since 14/02/2020
    @version 1
    @history Chamado 055585 - Adriano / Abel       - 14/02/2020
    /*/
Static Function RetCEsp(cIe)

    cIe := StrTran(cIe, "'", "")
    cIe := StrTran(cIe, "#", "")
    cIe := StrTran(cIe, "%", "")
    cIe := StrTran(cIe, "*", "")
    cIe := StrTran(cIe, "&", "")
    cIe := StrTran(cIe, ">", "")
    cIe := StrTran(cIe, "<", "")
    cIe := StrTran(cIe, "!", "")
    cIe := StrTran(cIe, "@", "")
    cIe := StrTran(cIe, "$", "")
    cIe := StrTran(cIe, "(", "")
    cIe := StrTran(cIe, ")", "")
    cIe := StrTran(cIe, "_", "")
    cIe := StrTran(cIe, "-", "") //chamado 057996
    cIe := StrTran(cIe, "=", "")
    cIe := StrTran(cIe, "+", "")
    cIe := StrTran(cIe, "{", "")
    cIe := StrTran(cIe, "}", "")
    cIe := StrTran(cIe, "[", "")
    cIe := StrTran(cIe, "]", "")
    cIe := StrTran(cIe, "/", "")
    cIe := StrTran(cIe, "?", "")
    cIe := StrTran(cIe, ".", "")
    cIe := StrTran(cIe, "\", "")
    cIe := StrTran(cIe, "|", "")
    cIe := StrTran(cIe, ":", "")
    cIe := StrTran(cIe, ";", "")
    cIe := StrTran(cIe, '"', '')
    cIe := StrTran(cIe, '°', '')
    cIe := StrTran(cIe, 'ª', '')
    cIe := StrTran(cIe, ' ', '')
    
Return(cIe)

/*/{Protheus.doc} Static Function SXESXFRM
    (long_description)
    @type  Function
    @author Fernando Macieira
    @since 12/11/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function SXESXFRM()

    Local cNextCodRM := ""
    Local cQuery     := ""

    If Select("Work") > 0
        Work->( dbCloseArea() )
    EndIf

    cQuery := " SELECT MAX(A2_COD) AS NEXT_COD
    cQuery += " FROM " + RetSqlName("SA2") + " (NOLOCK)
    cQuery += " WHERE A2_FILIAL='"+FWxFilial("SA2")+"'
    cQuery += " AND A2_COD LIKE 'F%' "
    cQuery += " AND D_E_L_E_T_='' "

    tcQuery cQuery New Alias "Work"

    IF ALLTRIM(Work->NEXT_COD) <> ''

        cNextCodRM := Soma1(AllTrim(Work->NEXT_COD))

    ELSE 

        cNextCodRM := 'F00001'

    ENDIF    

    If Select("Work") > 0
        Work->( dbCloseArea() )
    EndIf

Return cNextCodRM
