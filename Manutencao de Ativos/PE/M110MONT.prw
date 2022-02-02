#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} User Function M110MONT
    Ponto de entrada que permite efetuar valida��es diversas nas vari�veis utilizadas na solicita��o de compras.
    LOCALIZA��O: Fun��o a110Monta - Rotina de montagem do aHeader e do aCols da solicita��o de compra.
    EM QUE PONTO: No final da fun��o, ap�s a cria��o do aHeader e aCols e antes da abertura da tela. 
    @type  Function
    @author Fernando Macieira
    @since 08/02/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @history ticket 8582 - Fernando Macieira - 08/02/2021 - Replicar OP na pr�xima linha
	@history ticket TI - Everson - 11/05/2021 - Adicionado GetArea e RestArea.
/*/
User Function M110MONT()

    Local aArea   := GetArea()
    Local cNumSC1 := PARAMIXB[1]
    Local nOpc    := PARAMIXB[2]
    Local lCopia  := PARAMIXB[3]
    Local cOp     := Space(11)
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'P.E valida�oes na solicita��o de compras ')

	
    //Alterado por Tiago Stocco 10/05/2021 - Somente preencher a OP quando nao for copia de SC
    If nOpc == 1
        If lCopia
            MSGINFO("Ao utilizar a op��o de Copia o numero da OP N�o ser� copiado","M110MONT")
            For i:=1 to Len(aCols)
                gdFieldPut("C1_OP", cOP, i)
                GetdRefresh()
            Next i
            lPri := .F.
        else
            For i:=1 to Len(aCols)
                // ORDER 1 = C1_FILIAL, C1_NUM, C1_ITEM, C1_ITEMGRD, R_E_C_N_O_, D_E_L_E_T_
                cOP := Posicione("SC1",1,FWxFilial("SC1")+cNumSC1+aCols[i,1],"C1_OP")
                gdFieldPut("C1_OP", cOP, i)
            Next i
        EndIf
    EndIf

    //
    RestArea(aArea)

Return
