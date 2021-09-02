#include 'rwmake.ch'
#include 'topconn.ch'

/*/{Protheus.doc} User Function MA020ALT
    P.E. para validacao dos dados na alteracao do cadastro de fornecedores.
    Tirado obrigatoriedade do campo A2_CGC, pois quando estado = "EX" nao precisa ser preenchido
    @type  Function
    @author user
    @since 19/11/2010
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @history ticket 11639 - Fernando Macieira - 31/05/2021 - Projeto - OPS Documento de entrada - Industrialização/Beneficiamento
/*/
User Function MA020ALT()   
                       
    Local _lRetCGC := .F.

    If M->A2_EST = 'EX'
        _lRetCGC := .T.	
    Else
        If Empty(M->A2_CGC)
            _lRetCGC := .F.                                   
        Else
            _lRetCGC := .T.	
        Endif
    Endif

    If !_lRetCGC
        Alert("Campo CGC é obrigatorio - PE MA020ALT")
    Endif

    //Chamado 032707 - WILLIAM COSTA 02/09/2017
    If _lRetCGC

        IF ALLTRIM(M->A2_LOCAL) <> '' .AND. ;
            (ALLTRIM(M->A2_XTIPO) == '1' .OR. ALLTRIM(M->A2_XTIPO) == '2' .OR. ALLTRIM(M->A2_XTIPO) == '4')

            cNNRDESCRI := ""
            If AllTrim(M->A2_XTIPO) == "1"
                cNNRDESCRI := 'INCUBATORIO-'
            ElseIf AllTrim(M->A2_XTIPO) == "2"
                cNNRDESCRI := 'INTEGRADO-'
            ElseIf AllTrim(M->A2_XTIPO) == "4"
                cNNRDESCRI := 'INDUSTRIALIZACAO-'
            EndIf
            
            DBSELECTAREA("NNR")
            NNR->(DBSETORDER(1))
            NNR->(DBGOTOP())
            IF !DBSEEK(xfilial("NNR") + ALLTRIM(M->A2_LOCAL))
                
                RecLock("NNR", .T.)  
                    
                    NNR->NNR_FILIAL	:= xFilial("NNR")
                    NNR->NNR_CODIGO	:= ALLTRIM(M->A2_LOCAL)
                    NNR->NNR_TIPO	:= '1'
                    NNR->NNR_DESCRI	:= cNNRDESCRI + ALLTRIM(M->A2_LOCAL)
                    //NNR->NNR_DESCRI	:= IIF(ALLTRIM(M->A2_XTIPO) == '1','INCUBATORIO-','INTEGRADO-') + ALLTRIM(M->A2_LOCAL)
                        
                NNR->( MsUnLock() )    
                            
                MsgINFO("Olá " + Alltrim(cusername) + ", Local de Armazém Criado: " + ALLTRIM(M->A2_LOCAL), "MA020ALT - Criação de Almoxarifado")
                            
            ENDIF
                
            NNR->( DBCLOSEAREA() )  
                
        ENDIF
        
    ENDIF

    // @history ticket 11639 - Fernando Macieira - 31/05/2021 - Projeto - OPS Documento de entrada - Industrialização/Beneficiamento
    If _lRetCGC
        
        If AllTrim(M->A2_XTIPO) == '4' // Terceiro
        
            If Empty(M->A2_LOCAL)
               _lRetCGC := .f.
               Alert("[MA020ALT-02] - Para terceiro, obrigatório preencher o campo 'Almoxarifado' (campo A2_LOCAL)! Será utilizado no retorno dos insumos...")
            Else
                _lRetCGC := ChkLoc3()
            EndIf

        EndIf

    EndIf
    //
               
Return(_lRetCGC)

/*/{Protheus.doc} Static Function ChkLoc3()
    Checa se armazém de terceiro não está sendo utilizado em outro fornecedor
    @type  Static Function
    @author FWNM
    @since 31/05/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ChkLoc3()

    Local lRet := .t.
    Local cQuery := ""

    If Select("Work") > 0
        Work->( DbCloseArea() )
    EndIf

    cQuery := " SELECT A2_COD, A2_LOJA, A2_NREDUZ
    cQuery += " FROM " + RetSqlName("SA2") + " (NOLOCK)
    cQuery += " WHERE A2_COD+A2_LOJA<>'"+M->A2_COD+M->A2_LOJA+"'
    cQuery += " AND A2_LOCAL='"+M->A2_LOCAL+"'
    cQuery += " AND D_E_L_E_T_=''

    tcQuery cQuery New Alias "Work"

    Work->( dbGoTop() )
    If Work->( !EOF() )
        lRet := .f.
        Alert("[MA020ALT-03] - O 'Almoxarifado' (conteúdo do campo A2_LOCAL)! já foi utilizado para o fornecedor " + Work->A2_COD + "/" + Work->A2_LOJA + " - " + Work->A2_NREDUZ + " ! Informe um código ainda não utilizado...")
    EndIf

    If Select("Work") > 0
        Work->( DbCloseArea() )
    EndIf

Return lRet
