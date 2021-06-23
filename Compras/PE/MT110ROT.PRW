#Include "Protheus.ch"
#Include "Topconn.ch"       
/*/{Protheus.doc} User Function MT110ROT
	Ponto de entrada para adicionar novas funcionalidades. Chamado 054714.
    @type  Function
    @author Everson
    @since 11/05/2020
    @version 01
    @history Everson, 12/05/2020, Chamado 054714. Tratamento para envio de solicitação pelo e-mail informado na interface.
    /*/
User function MT110ROT()
    
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	 
	Local aArea	:= GetArea()
	
    //
    If __cUserId $Alltrim(GetMv("MV_#ENVCOT",,""))
	    AAdd( aRotina, { "WorkFlow Cotação", "U_MT110R1( SC1->C1_NUM)", 0, 7 } )

    EndIf
	
    //
	RestArea(aArea) 
	
Return aRotina
/*/{Protheus.doc} User Function MT110R1
    Exibe interface para envio de cotações.
    @type  Function
    @author Everson
    @since 11/05/2020
    @version 01
    /*/
User Function MT110R1(cNumSC)
    
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aArea		:= GetArea()
	Local aDados	:= {}
	Local aDadosEnv	:= {}
	Local i         := 1
    Local lEnd      := .F.
    Local cEmail    := ""
	Local cNumCT 	:= ""
    Local cArq      := ""

    //Everson - 12/05/2020. Chamado 054714.
    Local cCod      := ""
    Local cLoja     := ""
 	
	//Recupera dados do BD.
	aDados := consulta_BD(cNumSC)
	
	//Checa se há registros de cotação.
	If Len(aDados) <= 0
		MsgAlert("Não há registro de cotação para a solicitação de compra " + Alltrim(cValToChar(cNumSC)) + ", ou esta já está fechada.","Função MT110R1(MT110ROT)")
		RestArea(aArea)
		Return Nil

	EndIf
	
	//Recebe os registros selecionados na MarkBrowse.
	aDadosEnv := MkBrwWF(aDados)
	
    //
	If Len(aDadosEnv) > 0
	
	    //Pergunta se o usuário deseja enviar e-mail para cotação.
	    If !MsgYesNo("Deseja enviar solicitação de cotação?","Função MT110R1(MT110ROT)")
			RestArea(aArea)
	    	Return Nil

	    EndIf
	    
		//
	    For i := 1 To Len(aDadosEnv)

            //Everson - 12/05/2020. Chamado 054714.
            cCod    := Alltrim(cValtoChar(aDadosEnv[i][1])) 
            cLoja   := Alltrim(cValtoChar(aDadosEnv[i][2])) 
            //

	    	cNumCT 	:= Alltrim(cValtoChar(aDadosEnv[i][5])) 
            cEmail  := Alltrim(cValtoChar(aDadosEnv[i][4]))
            cArq    := Alltrim(cValtoChar(aDadosEnv[i][7]))
		    
            //
			Processa({|lEnd|U_ADCOM035P(cCod,cLoja,cNumCT,cEmail,cArq,@lEnd)},"Aguarde...","Enviando solicitação de cotação.",.T.) //Everson - 12/05/2020. Chamado 054714.
			
		Next

	EndIf

	//
	RestArea(aArea)
	
Return Nil
/*/{Protheus.doc} consulta_BD
    (long_description)
    @type  Static Function
    @author Everson
    @since 11/05/2020
    @version 01
    /*/
Static Function consulta_BD(cNumCT)
    
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aArea		:= GetArea()
	Local aDados	:= {}
	Local cQuery	:= ""
	
    //
    cQuery := ""
	cQuery += " SELECT "
    cQuery += " DISTINCT A2_COD, A2_LOJA, A2_NOME, A2_EMAIL, C8_NUM, C8_XEMWF " 
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("SC1") + " AS SC1 " 
	cQuery += " INNER JOIN " 
	cQuery += " " + RetSqlName("SC8") + " AS SC8 ON " 
	cQuery += " C1_FILIAL = C8_FILIAL " 
	cQuery += " AND C1_NUM = C8_NUMSC " 
	cQuery += " INNER JOIN " 
	cQuery += " " + RetSqlName("SA2") + " AS SA2 ON " 
	cQuery += " C8_FORNECE = A2_COD " 
	cQuery += " AND C8_LOJA = A2_LOJA " 
	cQuery += " WHERE " 
    cQuery += " SC1.C1_FILIAL = '" + FWxFilial("SC1") + "' "
	cQuery += " AND SC1.D_E_L_E_T_ = '' " 
	cQuery += " AND SC8.D_E_L_E_T_ = '' " 
	cQuery += " AND SA2.D_E_L_E_T_ = '' "
	cQuery += " AND C8_NUMPED = '' "  
	cQuery += " AND C1_NUM = '" + Alltrim(cValToChar(cNumCT)) + "' " 
	
    //
	If Select("DADOSFOR") > 0
		DADOSFOR->(DbCloseArea())

	EndIf
	
    //
	TcQuery cQuery New Alias "DADOSFOR"
	DbSelectArea("DADOSFOR")
	DADOSFOR->(DbGoTop())
	While ! DADOSFOR->(Eof())
	
		Aadd(aDados,{;
                    	DADOSFOR->A2_COD,;
		 				DADOSFOR->A2_LOJA,;
		 				DADOSFOR->A2_NOME,;
		 				DADOSFOR->A2_EMAIL,;
		 				DADOSFOR->C8_NUM,;
		 				DADOSFOR->C8_XEMWF})
		
		DADOSFOR->(DbSkip())

	EndDo

	//
	DADOSFOR->(DbCloseArea())

	//
	RestArea(aArea)
	
Return aDados
/*/{Protheus.doc} MkBrwWF
    Cria objeto markbrowse.
    @type  Static Function
    @author Everson
    @since 11/05/2020
    @version 01
    /*/
Static Function MkBrwWF(aDados)
    
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	  
    Local aStruct       := {}
    Local oTable        := Nil
    Local aFields       := {}          
    Local i             := 1
    Local cStatus		:= ""
    Local cMsgStatus	:= ""
    
    //
    Private aEmail      := {}
    Private aRotina     := {}   
    Private cCadastro   := "WorkFlow de Cotação" 
    Private cMark       := GetMark()
    
    //Opções no menu da tela.
    aRotina   := {;
                  {"Enviar WF"       , "Eval({|| U_MT110R2(), CloseBrowse() })", 0, 9},;
                  {"Inverter Seleção", "U_MT110R4()", 0, 10},;
                  {"Anexar Arquivo"  , "Eval({|| U_MT110R5() })", 0, 11},;
                  {"Alterar e-mail"  , "Eval({|| U_MT110R6() })", 0, 12};
                 }

    //    
    Aadd(aStruct,{"A2_OK"    ,"C"    , 2,0})
    Aadd(aStruct,{"A2_COD"   ,"C"    , 6,0})
    Aadd(aStruct,{"A2_LOJA"  ,"C"    , 2,0})
    Aadd(aStruct,{"A2_NOME"  ,"C"    ,50,0})
    Aadd(aStruct,{"A2_EMAIL" ,"C"    ,50,0})
    Aadd(aStruct,{"A2_COT" 	 ,"C"    , 6,0})
    Aadd(aStruct,{"A2_STATUS","C"    ,60,0})
    Aadd(aStruct,{"A2_ARQ"   ,"C"    ,255,0})

    //
    oTable := FwTemporaryTable():New("TRB")
    oTable:SetFields(aStruct)
    oTable:AddIndex("indice1",{"A2_COD","A2_LOJA"})
    
    //
    oTable:Create()
    
    //Atribui valores ao arquivo temporário.
    For i := 1 To Len(aDados) 
        
        //
        cStatus := Alltrim(cValToChar(aDados[i][6])) 
        
        //
        If     cStatus == "A"
        	cMsgStatus := "Solicitação de cotação enviada ao fornecedor"

        ElseIf cStatus == "B"
        	cMsgStatus := "Cotação recebida pelo servidor"

        ElseIf cStatus == "C"
        	cMsgStatus := "Solicitação de cotação reenviada ao fornecedor"

        Else
        	cMsgStatus := "Solicitação de cotação não enviada ao fornecedor"

        EndIf

        //      
        RecLock("TRB",.T.)    
            TRB->A2_OK     := cMark                           
	        TRB->A2_COD    := Alltrim(cValtoChar(aDados[i][1]))                             
	        TRB->A2_LOJA   := Alltrim(cValToChar(aDados[i][2]))
	        TRB->A2_NOME   := Alltrim(cValtoChar(aDados[i][3]))                             
	        TRB->A2_EMAIL  := Alltrim(cValToChar(aDados[i][4]))
	        TRB->A2_COT    := Alltrim(cValToChar(aDados[i][5])) 
	        TRB->A2_STATUS := cMsgStatus     
        MsUnlock()  
              
    Next i
    
    //Campos que serão exibidos na MarkBrowse.
    Aadd(aFields,{"A2_OK"		,"",""})
    Aadd(aFields,{"A2_COD"		,"","Código"})
    Aadd(aFields,{"A2_LOJA"	    ,"","Loja"})
    Aadd(aFields,{"A2_NOME"	    ,"","Nome"})
    Aadd(aFields,{"A2_EMAIL"	,"","E-mail"})
    Aadd(aFields,{"A2_COT"		,"","Nr. Cotação"})
    Aadd(aFields,{"A2_STATUS"	,"","Status"})
    Aadd(aFields,{"A2_ARQ"	    ,"","Arquivo"})
    
    //
    DbSelectArea("TRB")
    TRB->(DbGotop())
    
    //Função MarkBrowse.
    MarkBrow( 'TRB', 'A2_OK',,aFields,, cMark,'U_MT110R4()',,,,'U_MT110R3()')
    
    //
    TRB->(DbCloseArea()) 
         
    //Apaga a tabela temporária.
    oTable:Delete()
     
Return aEmail
/*/{Protheus.doc} User Function MT110R1
    Processa os arquivos selecionados no MarkBrow.
    @type  Static Function
    @author Everson
    @since 11/05/2020
    @version 01
    /*/
User Function MT110R2()
     
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

    //
    DbSelectArea("TRB")
    TRB->(DbGoTop())
    While !TRB->(Eof())

        //
        If !Empty(Alltrim(TRB->A2_OK)) .And. ! Empty(Alltrim(TRB->A2_EMAIL)) //Everson - 12/05/2020. Chamado 054714.
            Aadd(aEmail, {TRB->A2_COD, TRB->A2_LOJA, TRB->A2_NOME, TRB->A2_EMAIL, TRB->A2_COT, TRB->A2_STATUS, TRB->A2_ARQ})

        EndIf

        //
        TRB->(DbSkip())

    End

Return Nil
/*/{Protheus.doc} User Function MT110R3
    Seleciona opção no MarkBrow.
    @type  Function
    @author Everson
    @since 11/05/2020
    @version 01
    /*/
User Function MT110R3()

    //
    If IsMark("A2_OK", cMark )

        //
        RecLock("TRB", .F. )
            Replace TRB->A2_OK With Space(2)

        MsUnLock()
    
    Else

        //
        RecLock("TRB", .F. )
            Replace TRB->A2_OK With cMark
        
        MsUnLock()
    
    EndIf

Return Nil
/*/{Protheus.doc} User Function MT110R4
    Marca todas a opções do MarkBrow.
    @type  Function
    @author Everson
    @since 11/05/2020
    @version 01
    /*/
User Function MT110R4()
     
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
    Local oMark := GetMarkBrow()

    //
    DbSelectArea("TRB")
    TRB->(DbGotop())

    //
    While !Eof()
        
        //
        U_MT110R3()

        //
        TRB->(DbSkip())

    End

    // força o posicionamento do browse no primeiro registro
    oMark:oBrowse:Gotop()
    MarkBRefresh()
    
Return Nil
/*/{Protheus.doc} MT110R5
    Vincula anexo para envio.
    @type  Static Function
    @author Everson
    @since 11/05/2020
    @version 01
    /*/
User Function MT110R5()
     
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
    Local aArea := GetArea()
    Local cArq  := cGetFile('Arquivo|*.*|Arquivo *|*.*','Selecione o arquivo',0,'C:\',.T.,GETF_LOCALHARD + GETF_NETWORKDRIVE,.T.)

    //
    If MsgYesNo("Deseja vincular o arquivo a todas solicitações de cotação?","Função MT110R5(MT110ROT)")

        //
        DbSelectArea("TRB")
        TRB->(DbGotop())

        //
        While ! TRB->(Eof())
            
            //
            RecLock("TRB", .F. )
                Replace TRB->A2_ARQ With Alltrim(cArq)

            TRB->(MsUnLock()) 

            //
            TRB->(DbSkip())

        End

    Else

        //
        RecLock("TRB", .F. )
            Replace TRB->A2_ARQ With Alltrim(cArq)

        TRB->(MsUnLock())   

    EndIf

    //
    RestArea(aArea)

    //
    MarkBRefresh()

Return Nil
/*/{Protheus.doc} MT110R6
    Altera e-mail.
    @type  Static Function
    @author user
    @since 11/05/2020
    @version 01
    /*/
User Function MT110R6()
    
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
    Local cEmail := FWInputBox("Digite o e-mail:", Alltrim(TRB->A2_EMAIL))

    //
    If Empty(cEmail)
        MsgStop("Campo em branco.","Função MT110R6(MT110ROT)")
        Return Nil 

    EndIf

    //
    RecLock("TRB", .F. )
        Replace TRB->A2_EMAIL With Alltrim(cEmail)

    TRB->(MsUnLock()) 

    //
    MarkBRefresh()

Return Nil