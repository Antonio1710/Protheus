#INCLUDE "TOPCONN.CH"    
#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"   
#INCLUDE "RWMAKE.CH"                           

// Op��es do MessageBox
  #define MB_OK                       0
  #define MB_OKCANCEL                 1
  #define MB_YESNO                    4
  #define MB_ICONHAND                 16
  #define MB_ICONQUESTION             32
  #define MB_ICONEXCLAMATION          48
  #define MB_ICONASTERISK             64
  
  // Retornos poss�veis do MessageBox
  #define IDOK			    1
  #define IDCANCEL		    2
  #define IDYES			    6
  #define IDNO			    7

/*/{Protheus.doc} User Function FA740BRW
    Adiciona itens no menu da mBrowse - Fun��es contas a receber
    @type  Function
    @author Fernando Sigoli
    @since 14/03/2017
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @history chamado 056247 - FWNM - 12/03/2020 - || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS
	@history chamado 056247 - FWNM - 21/05/2020 - Error log apenas via execauto na cria��o do arquivo e inclusao de ZBE em diversos pontos    
    @history chamado 056247 - FWNM - 27/05/2020 - Ajuste para liberar cr�dito e estoque automaticamente quando C5_XWSPAGO = S de todos os itens do pedido de venda
    @history chamado 056247 - FWNM - 17/06/2020 - || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - Bot�o para desvincular RA x PV (FIE)
    @history chamado 059415 - FWNM - 13/08/2020 - || OS 060907 || FINANCAS || WAGNER || 11940283101 || WS BRADESCO
    @history ticket 102  - FWNM - 18/08/2020 - WS BRADESCO 
    @history ticket 102  - FWNM - 26/08/2020 - WS BRADESCO 
    @history ticket 745  - FWNM - 17/09/2020 - Implementa��o t�tulo PR
    @history ticket 1768 - FWNM - 23/09/2020 - PV com adiantamento superior a NF
    @history ticket 745  - FWNM - 30/09/2020 - C5_XWSPAGO com identifica��o para libera��o manual
    @history ticket TI   - FWNM - 21/10/2020 - Registro manual mesmo com o E1_XWSBRAC em branco 
/*/
User Function FA740BRW()
    
    Local aBotao := {}

    aAdd(aBotao, {'Posicao Tit.Receber'          , "FINC040()"     , 0, 3 })
    aAdd(aBotao, {'Posicao Cliente'              , "FINC010()"     , 0, 4 })
    aAdd(aBotao, {'Registra Bol Bradesco WS'     , "u_BolBrad()"   , 0, 5 }) // Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 12/03/2020
    aAdd(aBotao, {'Imprime PDF Bol Bradesco WS'  , "u_RunHCRFB()"  , 0, 6 }) // Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 18/03/2020
    aAdd(aBotao, {'Confirma Pgto Bol Bradesco WS', "u_PgtoWS(.T.)" , 0, 7 }) // Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 07/05/2020
    aAdd(aBotao, {'Desvincular PV x PR/RA'       , "u_ExcRAPV()"   , 0, 8 }) // Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 17/06/2020
    
Return aBotao

/*/{Protheus.doc} User Function BolBrad
    Registro manual do boleto bradesco WS
    @type  Static Function
    @author FWNM
    @since 12/03/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @chamado 056247
/*/
User Function BolBrad()

    Local cCodRetOk := GetMV("MV_#WSOCOK",,"00")
    Local cCodRet69 := GetMV("MV_#WSOC69",,"69") // @history ticket TI   - FWNM - 21/10/2020 - Registro manual mesmo com o E1_XWSBRAC em branco 

    // Chamada via PV
    If AllTrim(FunName()) == "MATA410" 
        FIE->( dbSetOrder(1) ) // FIE_FILIAL, FIE_CART, FIE_PEDIDO
        If FIE->( !dbSeek(SC5->C5_FILIAL+"R"+SC5->C5_NUM) )
            MsgStop("Pedido n�o possui t�tulo de adiantamento! Verifique tabela FIE...", "04 - Fun��o BolBrad - FA740BRW - MA410MNU")
            Return
        Else
            SE1->( dbSetOrder(2) ) //E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_
            If SE1->( !dbSeek(FIE->(FIE_FILIAL+FIE_CLIENT+FIE_LOJA+FIE_PREFIX+FIE_NUM+FIE_PARCEL+FIE_TIPO)) )
                MsgStop("Pedido n�o possui t�tulo de adiantamento! Verifique contas a receber...", "06 - Fun��o BolBrad - FA740BRW - MA410MNU")
                Return
            EndIf
        EndIf
    EndIf
    //

    // Registra boleto bradesco WS
    //If !Empty(SE1->E1_NUMBCO) .and. !Empty(SE1->E1_IDCNAB) .and. !Empty(SE1->E1_XWSBRAC)
    If !Empty(SE1->E1_NUMBCO) .and. !Empty(SE1->E1_IDCNAB) // // @history ticket TI   - FWNM - 21/10/2020 - Registro manual mesmo com o E1_XWSBRAC em branco 

        If ( Val(AllTrim(SE1->E1_XWSBRAC)) <> Val(AllTrim(cCodRetOk)) .and. Val(AllTrim(SE1->E1_XWSBRAC)) <> Val(AllTrim(cCodRet69)) ) .or. Empty(SE1->E1_XWSBRAC)
        	u_T288BPCK7(SE1->E1_FILIAL, SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO)
        Else
            MsgStop("Este t�tulo j� foi registrado! Imprima o boleto...", "03 - Fun��o BolBrad - FA740BRW")
        EndIf
    
    Else

        //MsgStop("Este t�tulo n�o pode ser registrado por este recurso, pois n�o � um boleto de adiantamento", "01 - Fun��o BolBrad - FA740BRW")
        MsgStop("Este t�tulo n�o pode ser registrado, pois n�o possui nosso n�mero (E1_NUMBCO) e/ou IDCNAB (E1_IDCNAB)", "01 - Fun��o BolBrad - FA740BRW") // // @history ticket TI   - FWNM - 21/10/2020 - Registro manual mesmo com o E1_XWSBRAC em branco 

    EndIf
    
Return

/*/{Protheus.doc} User Function RunHCRFB
    Impress�o manual do boleto bradesco WS
    @type  Static Function
    @author FWNM
    @since 18/03/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @chamado 056247
/*/
User Function RunHCRFB()

    Local cCodRetOk := GetMV("MV_#WSOCOK",,"00")

    // Chamada via PV
    If AllTrim(FunName()) == "MATA410" 
        FIE->( dbSetOrder(1) ) // FIE_FILIAL, FIE_CART, FIE_PEDIDO
        If FIE->( !dbSeek(SC5->C5_FILIAL+"R"+SC5->C5_NUM) )
            MsgStop("Pedido n�o possui t�tulo de adiantamento! Verifique tabela FIE...", "05 - Fun��o RunHCRFB - FA740BRW - MA410MNU")
            Return
        Else
            SE1->( dbSetOrder(2) ) //E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_
            If SE1->( !dbSeek(FIE->(FIE_FILIAL+FIE_CLIENT+FIE_LOJA+FIE_PREFIX+FIE_NUM+FIE_PARCEL+FIE_TIPO)) )
                MsgStop("Pedido n�o possui t�tulo de adiantamento! Verifique contas a receber...", "07 - Fun��o RunHCRFB - FA740BRW - MA410MNU")
                Return
            EndIf
        EndIf
    EndIf
    //

    If !Empty(SE1->E1_NUMBCO) .and. !Empty(SE1->E1_XWSBRAC) .and. Val(AllTrim(SE1->E1_XWSBRAC)) == Val(AllTrim(cCodRetOk))
    	//u_HCRFIBLT()
        msAguarde( { || u_HCRFIBLT() }, "Imprimindo boleto de adiantamento em PDF n " + SE1->E1_NUM )

    Else
        MsgStop("O boleto deste t�tulo n�o pode ser impresso, pois seu registro no banco n�o aconteceu!", "02 - Fun��o RunHCRFB - FA740BRW")
    EndIf

Return

/*/{Protheus.doc} User Function u_PgtoWS()
    Confirma��o manual do pagamento do pedido de adiantamento 
    @type  Function
    @author FWNM
    @since 07/05/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @chamado 056247
/*/
User Function PgtoWS(lManual)
    
    Local lRet      := .t. //@history ticket 102 - FWNM - 18/08/2020 - WS BRADESCO 
    Local cUsrAut   := GetMV("MV_#WSAUTF",,"000000") // Usuarios autorizados
    Local cCodRetOk := GetMV("MV_#WSOCOK",,"00")
    Local cCodRet69 := GetMV("MV_#WSOC69",,"69")

    Local lBxPROk   := .f.
    Local cMsgYesNo := ""

    Default lManual := .T.

	// Logins autorizados
    If !(RetCodUsr() $ cUsrAut)
        lRet := .f.
        MsgStop("Login " + RetCodUsr() + " - " + AllTrim(cUserName) + " sem acesso para usar esta rotina!", "05 - Fun��o PgtoWS - FA740BRW")
		Return lRet
	EndIf

    // Verifica registro boleto bradesco WS - Libera C5_XWSPAGO
    If !Empty(SE1->E1_NUMBCO) .and. !Empty(SE1->E1_IDCNAB) .and. !Empty(SE1->E1_XWSBRAC)
        
        If Val(AllTrim(SE1->E1_XWSBRAC)) == Val(AllTrim(cCodRetOk)) .or. Val(AllTrim(SE1->E1_XWSBRAC)) == Val(AllTrim(cCodRet69))

            FIE->( dbSetOrder(2) ) // FIE_FILIAL, FIE_CART, FIE_CLIENT, FIE_LOJA, FIE_PREFIX, FIE_NUM, FIE_PARCEL, FIE_TIPO, FIE_PEDIDO, R_E_C_N_O_, D_E_L_E_T_
            If FIE->( dbSeek(FWxFilial("FIE")+"R"+SE1->(E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)+PadR(SE1->E1_NUM,Len(FIE->FIE_PEDIDO))) )
                
                SC5->( dbSetOrder(1) ) // C5_FILIAL+C5_NUM
                If SC5->( dbSeek( FWxFilial("SC5")+FIE->FIE_PEDIDO ) )

                    // ticket 745 - FWNM - 28/09/2020 - Implementa��o t�tulo PR
                    If lManual
                        cMsgYesNo := "Confirma libera��o manual do PV n. " + SC5->C5_NUM + " ? " + Chr(13) + Chr(10) + "Sua confirma��o apenas autorizar� o faturamento, mas n�o baixar� o boleto (PR) e t�o pouco ser� gerado a RA para compensa��o autom�tica da NF. " + Chr(13) + Chr(10) + "Somente a confirma��o do pagamento via retorno do CNAB (ocorr�ncia 06) baixar� a PR e gerar� a RA para compensa��o manual..."
                    Else
                        cMsgYesNo := "Confirma pagamento do PV n. " + SC5->C5_NUM + " ? Sua confirma��o ir� baixar o boleto para gera��o do Adiantamento (RA)..."
                    EndIf
                    //
                    
                    If msgYesNo(cMsgYesNo)

                        // ticket 745 - FWNM - 17/09/2020 - Implementa��o t�tulo PR
                        If lManual
                           lBxPROk := .t. 
                        Else
                            msAguarde( { || lBxPROk := u_BxWSPR(lManual, SE1->E1_FILIAL, SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_CLIENTE, SE1->E1_LOJA) }, "Substituindo boleto por (RA), PV n. " + SC5->C5_NUM )
                        EndIf
                        
                        If lBxPROk

                            RecLock("SC5", .f.)

                                // ticket 745 - FWNM - 30/09/2020 - C5_XWSPAGO com identifica��o para libera��o manual
                                If lManual
                                    SC5->C5_XWSPAGO := "M" 
                                Else
                                    SC5->C5_XWSPAGO := "S"
                                EndIf
                                
                                SC5->C5_XPREAPR := "L" //@history ticket 102 - FWNM - 18/08/2020 - WS Bradesco - Gravar C5_XAPREAPR=L quando C5_XWSPAGO=S

                            SC5->( msUnLock() )

                            logZBE(SC5->C5_NUM + " FOI GRAVADO O CAMPO C5_XWSPAGO = " + Iif(lManual,"M","S") + " PELA ROTINA MANUAL") // Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 21/05/2020

                            // Desvincula PV x PR para que a rotina padr�o n�o efetue a compensa��o automaticamente
                            RecLock("FIE", .F.)
                                FIE->( dbDelete() )
                            FIE->( msUnLock() )
                    
                            logZBE(SE1->E1_NUM + " " + SC5->C5_NUM + " AMARRACAO PV x PR FOI DESFEITA PELA LIBERACAO MANUAL - U_PgtoWS")

                            // Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 21/05/2020                            
                            SC9->( dbSetOrder(1) ) // C9_FILIAL, C9_PEDIDO, C9_ITEM, C9_SEQUEN, C9_PRODUTO, C9_BLEST, C9_BLCRED, R_E_C_N_O_, D_E_L_E_T_
                            If SC9->( dbSeek(SC5->(C5_FILIAL+C5_NUM)) )
                                Do While SC9->( !EOF() ) .and. SC9->C9_FILIAL==SC5->C5_FILIAL .and. SC9->C9_PEDIDO==SC5->C5_NUM // Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 27/05/2020
                                    a450Grava(1,.T.,.T.)
                                    SC9->( dbSkip() )
                                EndDo
                                logZBE(SC5->C5_NUM + " FOI LIBERADO CREDITO/ESTOQUE PELA ROTINA MANUAL QUE MARCA C5_XWSPAGO UTILIZANDO ROTINA PADRAO A450GRAVA") // Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 21/05/2020
                            EndIf
                            //

                            RecLock("ZBE",.T.)
                                Replace ZBE_FILIAL 	   	WITH FWxFilial("ZBE")
                                Replace ZBE_DATA 	   	WITH msDate()
                                Replace ZBE_HORA 	   	WITH TIME()
                                Replace ZBE_USUARI	    WITH RetCodUsr()
                                Replace ZBE_LOG	        WITH SC5->C5_NUM + " Pagamento manual C5_XWSPAGO= " + Iif(lManual,"M","S") + " - Computador: " + AllTrim(ComputerName())
                                Replace ZBE_MODULO	    WITH "SIGAFIN"
                                Replace ZBE_ROTINA	    WITH "ADFIN087P"
                            ZBE->( msUnlock() )

                            If lManual
                                MessageBox("PV n. " + SC5->C5_NUM + " liberado para faturamento sem a baixa do boleto (PR) e a gera��o do RA que dever� ser inclu�do/compensado manualmente, caso n�o seja processado nenhum arquivo de retorno com ocorr�ncia 06...","WS Bradesco - Pagamento manual",MB_ICONASTERISK)
                            Else
                                MessageBox("Gerado RA para o PV n. " + SC5->C5_NUM + " ! Faturamento liberado...","WS Bradesco - Pagamento manual",MB_ICONASTERISK)
                            EndIf

                            // ticket 745 - FWNM - 30/09/2020 - C5_XWSPAGO com identifica��o para libera��o manual
                            If lManual
                                SendManual() // Envia email 
                            EndIf

                        Else
                            
                            lRet := .f.
                            MessageBox("Boleto n. " + SC5->C5_NUM + " n�o gerou RA! Faturamento n�o liberado...","WS Bradesco - Substitui��o manual PR -> RA",MB_ICONHAND)

                        EndIf

                    Else
    
                        lRet := .f.
                        MessageBox("Pedido n. " + SC5->C5_NUM + " n�o registrado como pago! Faturamento n�o liberado...","WS Bradesco - Cancelamento confirma��o pagamento manual",MB_ICONHAND)
                    
                    EndIf

                EndIf
            
            EndIf

        Else

            lRet := .f.
            MsgStop("O pedido deste t�tulo n�o pode ser marcado como pago pois n�o foi registrado! Registre o boleto...", "07 - Fun��o PgtoWS - FA740BRW")
            Return lRet
        
        EndIf
    
    Else

        lRet := .f.
        MsgStop("O pedido deste t�tulo n�o pode ser marcado como pago por este recurso, pois n�o � um boleto de adiantamento", "06 - Fun��o PgtoWS - FA740BRW")
        Return lRet

    EndIf

Return lRet

/*/{Protheus.doc} Static Function LOGZBE
	Gera log ZBE
	@type  Static Function
	@author Everson
	@since 24/05/2019
	@version 01
	@history chamado 056247 - FWNM - 21/05/2020 - Error log apenas via execauto na cria��o do arquivo e inclusao de ZBE em diversos pontos
/*/
Static Function logZBE(cMensagem)

	RecLock("ZBE", .T.)
		Replace ZBE_FILIAL 	   	With FWxFilial("ZBE")
		Replace ZBE_DATA 	   	With msDate()
		Replace ZBE_HORA 	   	With Time()
		Replace ZBE_USUARI	    With Upper(Alltrim(cUserName))
		Replace ZBE_LOG	        With cMensagem
		Replace ZBE_MODULO	    With "SIGAFIN"
		Replace ZBE_ROTINA	    With "ADFIN087P" 
	ZBE->( msUnlock() )

Return

/*/{Protheus.doc} User Function u_ExcRAPV
    Desvincula RA x PV para possibilitar exclus�o do RA (Padr�o n�o ser� utilizado pois o usu�rio tem que clicar em ALTERAR no PV)
    @type  Function
    @author user
    @since 17/06/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
User Function ExcRAPV()

    Local cUsrAut := GetMV("MV_#WSAUTF",,"000000|002048|002027") // Usuarios autorizados

    // @history ticket 102 - FWNM - 26/08/2020 - WS BRADESCO 
    //@history ticket 102 - FWNM - 18/08/2020 - WS BRADESCO 
    //MsgStop("Rotina desativada pois impactou no retorno do CNAB gerando baixa de RA e em todas as rotinas que envolvem pedido de venda com adiantamento!")
	//Return
    //

	// Logins autorizados
    If !(RetCodUsr() $ cUsrAut)
        MsgStop("Login " + RetCodUsr() + " - " + AllTrim(cUserName) + " sem acesso para usar esta rotina!", "Fun��o EXCRAPV - FA740BRW")
		Return
	EndIf

    // Verifica se o PV foi pago
    FIE->( dbSetOrder(2) ) // FIE_FILIAL, FIE_CART, FIE_CLIENT, FIE_LOJA, FIE_PREFIX, FIE_NUM, FIE_PARCEL, FIE_TIPO, FIE_PEDIDO, R_E_C_N_O_, D_E_L_E_T_
    If FIE->( dbSeek(FWxFilial("FIE")+"R"+SE1->(E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)+PadR(SE1->E1_NUM,Len(FIE->FIE_PEDIDO))) )
                
        // @history ticket 102 - FWNM - 26/08/2020 - WS BRADESCO 
        SC5->( dbSetOrder(1) ) // C5_FILIAL, C5_NUM, R_E_C_N_O_, D_E_L_E_T_
        If SC5->( dbSeek(FIE->(FIE_FILIAL+FIE_PEDIDO)) ) .and. !Empty(SC5->C5_NOTA) // ticket 1768 - FWNM - 23/09/2020 - PV com adiantamento superior a NF
        //If SC5->( !msSeek(FIE->(FIE_FILIAL+FIE_PEDIDO)) )

            RecLock("FIE", .F.)
                FIE->( dbDelete() )
            FIE->( msUnLock() )
                    
            logZBE(SE1->E1_NUM + " " + SC5->C5_NUM + " AMARRACAO RA X PV FOI DESFEITA PELA ROTINA MANUAL U_EXCRAPV")

            MessageBox("RA n. " + SE1->E1_NUM + " foi desvinculado do PV com sucesso!", "WS Bradesco - Desvincula��o RA x PV manual", MB_OK)

        Else
            
            MessageBox("Necess�rio excluir o PV n. " + SC5->C5_NUM + " para poder realizar a desvincula��o! Faturamento n�o realizado ainda...", "WS Bradesco - Desvincula��o RA x PV manual", MB_OK)
        
        EndIf
        //
    
    Else
        
        MessageBox("RA n. " + SE1->E1_NUM + " n�o possui PV vinculado!", "WS Bradesco - Desvincula��o RA x PV manual", MB_OK)

    EndIf
    
Return

/*/{Protheus.doc} Static Function SendManual
	Envia email quando PV � liberado manualmente
	@type  Static Function
	@author Fernando Macieira
	@since 30/09/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function SendManual()

	Local cMensagem	:= ""
	Local cAssunto	:= "[ Libera��o Manual ] - PV de adiantamento n. " + SC5->C5_NUM + " foi liberado manualmente"
	Local cMails    := GetMV("MV_#WSPRCX",,"cobranca@adoro.com.br;wagner.ferreira@adoro.com.br")

	// Cabe�alho
	cMensagem += '<html>'
	cMensagem += '<body>'
	cMensagem += '<p style="color:red">'+cValToChar(cAssunto)+'</p>'
	cMensagem += '<hr>'
	cMensagem += '<table border="1">'
	cMensagem += '<tr style="background-color: black;color:white">'
	cMensagem += '<td>Pedido Venda</td>'
	cMensagem += '<td>Cliente</td>'
	cMensagem += '<td>Dt Entrega</td>'
	cMensagem += '<td>Valor Total</td>'
	cMensagem += '<td>Conte�do C5_XWSPAGO</td>'
	cMensagem += '<td>Data Libera��o</td>'
	cMensagem += '<td>Hora Libera��o</td>'
	cMensagem += '<td>Login</td>'
	cMensagem += '<td>Computador</td>'
	cMensagem += '</tr>'

	// Detalhes
	cMensagem += '<tr>'
	cMensagem += '<td>' + cValToChar(SC5->C5_NUM)     + '</td>'
	cMensagem += '<td>' + cValToChar(SE1->E1_NOMCLI)  + '</td>'
	cMensagem += '<td>' + cValToChar(SC5->C5_DTENTR)  + '</td>'
	cMensagem += '<td>' + cValToChar(Transform(SE1->E1_VALOR,"@E 999,999,999.99")) + '</td>'
	cMensagem += '<td>' + cValToChar(SC5->C5_XWSPAGO)  + '</td>'
    cMensagem += '<td>' + cValToChar(msDate()) + '</td>'
    cMensagem += '<td>' + cValToChar(Time()) + '</td>'
    cMensagem += '<td>' + cValToChar(Upper(Alltrim(cUserName))) + '</td>'
    cMensagem += '<td>' + cValToChar(AllTrim(ComputerName())) + '</td>'

	cMensagem += '</tr>'

	cMensagem += '</table>'
	cMensagem += '</body>'
	cMensagem += '</html>'

	ProcessarEmail(cAssunto,cMensagem,cMails)

Return

/*/{Protheus.doc} Static Function PROCESSAREMAIL
	Configura��es EMAIL
	@type  Static Function
	@author Fernando Macieira
	@since 18/04/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function ProcessarEmail(cAssunto,cMensagem,email)

	Local lOk           := .T.
	Local cBody         := cMensagem
	Local cErrorMsg     := ""
	Local cServer       := Alltrim(GetMv("MV_RELSERV"))
	Local cAccount      := AllTrim(GetMv("MV_RELACNT"))
	Local cPassword     := AllTrim(GetMv("MV_RELPSW"))
	Local cFrom         := AllTrim(GetMv("MV_RELFROM")) 
	Local cTo           := email
	Local lSmtpAuth     := GetMv("MV_RELAUTH",,.F.)
	Local lAutOk        := .F.
	Local cAtach        := ""
	Local cSubject      := ""
	Local cCopia        := ""
	Local cCpOcul       := GetMV("MV_#WSMATI",,"fernando.sigoli@adoro.com.br")

	//Assunto do e-mail.
	cSubject := cAssunto

	//Conecta ao servidor SMTP.
	Connect Smtp Server cServer Account cAccount  Password cPassword Result lOk

	If !lAutOk
		If ( lSmtpAuth )
			lAutOk := MailAuth(cAccount,cPassword)
		Else
			lAutOk := .T.
		EndIf
	EndIf

	If lOk .And. lAutOk

		//Envia o e-mail.
		Send Mail From cFrom To cTo CC cCopia BCC cCpOcul Subject cSubject Body cBody ATTACHMENT cAtach Result lOk
		//Send Mail From cDe To cPara CC cCopia Subject cAssunto Body cMensag Attachment cAnexo Result lOk
		//Send Mail From cDe To cPara CC cCopia BCC cCpOcul Subject cAssunto Body cMensag Attachment cAnexo Result lOk

		//Tratamento de erro no envio do e-mail.
		If !lOk
			Get Mail Error cErrorMsg
			ConOut("3 - " + cErrorMsg)
		Else
			ConOut(	"[ADFIN087P] - Email enviado com sucesso sobre RA gerado para: " + email )
		EndIf

	Else
	
		Get Mail Error cErrorMsg
		ConOut("4 - " + cErrorMsg)

	EndIf

	If lOk
		Disconnect Smtp Server
	EndIf

Return
