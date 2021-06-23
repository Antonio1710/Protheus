#INCLUDE "Protheus.ch"
#include "rwmake.ch"   
#include "topconn.ch"                                    
#include "AP5MAIL.CH" 

/*/{Protheus.doc} User Function EECPEM36 
    Ponto de entrada EMBARQUE DE EXPORTACAO BOTAO OK Caminho: Atualizações/Embarque/Cons.Manutenção/Opções Incluir ou Alterar/Botão OK.Descrição: Chamada no botão de OK da função de manutenção de embarque AE100MAN() para as opções de inclusão ou alteração.Uso: Executar rotinas de validações nos dados digitados. Os campos são todos de memória, seguindo p/ o arquivo após a execução completa da função em que está o ponto de entrada. utilizado para garantir que o campo DATA DE EMBARQUE e DUE sejam preenchidos corretamente
    @type  Function
    @author William Costa
    @since 03/03/2020
    @version 01
/*/

User Function EECPEM36()

    Local aArea	    := GetArea()
    Local lRet      := .T.
    
    IF VALTYPE(PARAMIXB) <> "U"

        lRet := .T.
        RETURN(lRet)   

    ENDIF

    IF !EMPTY(M->EEC_DTEMBA)        .AND. ;
       ALLTRIM(M->EEC_NRODUE) == '' 

        lRet:= .F.        
        MsgStop("Olá " + Alltrim(cUserName) + ", necessário digitar o numero do DUE para continuar, favor verificar")
        
    ELSE

        lRet:= .T.

    ENDIF

    RestArea(aArea)

RETURN(lRet)         