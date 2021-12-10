#INCLUDE "Protheus.ch"
#include "rwmake.ch"   
#include "topconn.ch"                                    
#include "AP5MAIL.CH" 

/*/{Protheus.doc} User Function EECPEM44
    Este ponto de entrada é executado na confirmação da inclusão e alteração do pedido de exportação.
    @type  Function
    @author William Costa
    @since 27/02/2020
    @version 01
    @history Chamado 8465  - Leonardo P. Monteiro - 04/03/2021 - Inclusão das validações do projeto de exportação.
    @history Chamado 8465  - Leonardo P. Monteiro - 04/03/2021 - Alteração do campo chave do roteiro para a placa.
    @history Chamado 8465  - Leonardo P. Monteiro - 18/03/2021 - Valida se o campo Modelo Certificado foi incluso.
    @history Chamado 64964 - Leonardo P. Monteiro - 08/12/2021 - Torna obrigatório o modelo de certificado somente para a filial de Várzea Paulista.
/*/

User Function EECPEM44()

    Local aArea	    := GetArea()
    Local lRet      := .T.
    Local cUsrVend  := ''
    Local oEST055P  := ADEST055P():New()
    //PGA - Chamada das validações da PGA em relação ao cadastro.
    //Local oEST055P  := nil
    SqlVend()

    WHILE TRB->(!EOF()) 

        cUsrVend := TRB->A3_CODUSR
    
        TRB->(dbSkip())							
    ENDDO

    TRB->(dbCloseArea())

    IF cUsrVend == __cUserId

        lRet:= .T.        
        
    ELSE

        lRet    := .F.        
        MsgStop("[EECPEM44-02] - Olá " + Alltrim(cUserName) + ", o único usuário que pode colocar pedido de exportação é o: " + cUsrVend + '-' + UsrFullName(cUsrVend) + " conforme carteira do comercial nº 000800")

    ENDIF
    
    //Chamado 64964 - Leonardo P. Monteiro - 08/12/2021 - Torna obrigatório o modelo de certificado somente para a filial de Várzea Paulista.
    If (cEmpAnt+cFilAnt)$SuperGetMv("ZZ_PEM4401",,"0102")
        if Empty( M->EE7_XMODCS )
            lRet    := .F.        
            MsgStop("[EECPEM44-03] - É necessário informar o Modelo de Certificado para finalizar a inclusão do processo de exportação.")
        ENDIF
    ENDIF

    DbSelectArea("SC5")
    SC5->(DbsetOrder(1))

    If dbSeek( FWxFilial("SC5") + M->EE7_PEDFAT ) .AND. lAltera
        if !Empty(SC5->C5_PLACA) .OR. !Empty(SC5->C5_X_SQED)
            MsgAlert("[EECPEM44-01] - Pedidos de Venda faturados ou integrados ao eData não podem ser alterados!")
            lRet := .F.
        endif
    endif

    // Tkt 8465 - LPM - Valida se o produto está cadastrado e vinculado ao cadastro PGA.
    // Verifica se a função PGA está habilitada.
    if lRet .and. oEST055P:lPrcPGA

        nRecno      := workit->(Recno())
        WorkIt->(DbGotop())

        While WorkIt->(!eof())
            IF !(oEST055P:PGAVldPrd(alltrim(WorkIt->EE8_COD_I), M->EE7_PAISET, Alltrim(Funname())))
                lRet := .F.
            EndIf
            WorkIt->(DbSkip())
        enddo

        workit->(Dbgoto(nRecno))

        RestArea(aArea)
    
    endif

RETURN(lRet)

Static Function SqlVend()
        
    BeginSQL Alias "TRB"
			%NoPARSER% 
            SELECT A3_CODUSR
              FROM SA3010
             WHERE A3_COD      = '000800'
               AND D_E_L_E_T_ <> '*'  
			
	EndSQl
RETURN(NIL)                  
