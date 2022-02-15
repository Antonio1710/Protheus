#include "protheus.ch"
#include "topconn.ch"
/*/{Protheus.doc} User Function ADFAT014P
    Inicializador padrão do campo C5_XNFECTE.
    Chamado 11368
    @type  Function
    @author Leonardo P. Monteiro
    @since 13/04/2021
    @version 01
/*/
user function ADFAT014P()
    Local cNfe      := ""
    Local cQry      := ""
    Local aArea     := getArea()
    Local cDocFat   := ""

    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Inicializador padrão do campo C5_XNFECTE')
    
    cDocFat := SC5->C5_NOTA
    
    IF !Empty(cDocFat)
        
        cQry := " SELECT C7_XNFECTE FROM "+ RetSqlName("SC7") +" (NOLOCK) WHERE D_E_L_E_T_='' AND C7_FILIAL='"+ xfilial("SC7") +"' AND C7_XDOCFAT='"+ cDocFat +"'; "
        
        TcQuery cQry ALIAS "QSC7" NEW

        IF QSC7->(!eof())
            cNFe := QSC7->C7_XNFECTE
        ENDIF

        qsc7->(DbcloseArea())
    endif

    restArea(aArea)
return cNfe
