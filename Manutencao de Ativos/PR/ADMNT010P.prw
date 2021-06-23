#Include 'Protheus.ch'
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#Include 'TOTVS.ch'
#INCLUDE "topconn.ch"


/*/{Protheus.doc} User Function ADMNT010P
	Rotina responsável pelo CALCULO do Custo da MO das OS do MNT Ativo
	@type  Function
	@author Tiago Stocco
	@since 13/07/2020
	@version 01
/*/

User Function ADMNT010P()

	Local bProcess 		:= {|oSelf| Executa(oSelf) }
	Local cPerg 		:= "ADMNT010"
	Local aInfoCustom 	:= {}
	Local cTxtIntro	:=	"Rotina responsável pelo CALCULO do Custo da MO das OS do MNT Ativo"
	Private oProcess
	//Aadd(aInfoCustom,{"Visualizar",{|oCenterPanel| visualiza(oCenterPanel)},"WATCH" })
	//Aadd(aInfoCustom,{"Relatorio" ,{|oCenterPanel| Relat(oCenterPanel) },"RELATORIO"})
	oProcess := tNewProcess():New("ADMNT010","Custo MO OS",bProcess,cTxtIntro,cPerg,aInfoCustom, .T.,5, "Custo MO OS", .T. )
Return

STATIC Function Executa(oProcess)
Local cTipo  := ""
Local nCusto := 0
Local cQry   := ""
Private dDataIni	:= MV_PAR01
Private dDataFim	:= MV_PAR02
cQry := " SELECT * "
cQry += " FROM "+RetSqlName('STL')+ " STL "
cQry += " WHERE "
cQry += " TL_FILIAL = '"+ xFilial("STL") +"' "
cQry += " AND STL.D_E_L_E_T_ = ' ' "
cQry += " AND TL_DTINICI BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' "
cQry += " AND TL_TIPOREG IN ('E','M') "
cQry += " ORDER BY TL_DTINICI, TL_TIPOREG "
IF Select ("TMPSTL")>0
    TMPSTL->(DbCloseArea())
EndIf
DbUseArea(.T., "TOPCONN", TcGenQry(,,cQry), 'TMPSTL')
DbSelectArea("TMPSTL")
DbGotop()
nCountSTL := TMPSTL->(LASTREC())
oProcess:SetRegua2(nCountSTL)
If TMPSTL->(!EOF())
    While TMPSTL->(!EOF())
        oProcess:IncRegua2("Processando acerto...")
        If TMPSTL->TL_TIPOREG == 'E'
            nCusto:=Posicione("ST0",1,xFilial("ST0")+TMPSTL->TL_CODIGO,"T0_SALARIO")
            DbSelectArea("STL")
			DbGoto(TMPSTL->R_E_C_N_O_)
			Reclock("STL",.f.)
                STL->TL_CUSTO := STL->TL_QUANTID * nCusto
            MsUnlock()
            DbSelectArea("SD3")
            DBSETORDER(4)
            If DBSEEK(xFilial("SD3")+TMPSTL->TL_NUMSEQ)
            Reclock("SD3",.f.)
                SD3->D3_CUSTO1 := STL->TL_CUSTO
            MsUnlock()
            EndIf


        ENDIF

        If TMPSTL->TL_TIPOREG == 'M'
            nCusto:=Posicione("ST1",1,xFilial("ST1")+TMPSTL->TL_CODIGO,"T1_SALARIO")
            DbSelectArea("STL")
			DbGoto(TMPSTL->R_E_C_N_O_)
			Reclock("STL",.f.)
                STL->TL_CUSTO := STL->TL_QUANTID * nCusto
            MsUnlock()
            DbSelectArea("SD3")
            DBSETORDER(4)
            If DBSEEK(xFilial("SD3")+TMPSTL->TL_NUMSEQ)
            Reclock("SD3",.f.)
                SD3->D3_CUSTO1 := STL->TL_CUSTO
            MsUnlock()
            EndIf
        EndIf
        TMPSTL->(DbSkip())
    EndDo
TMPSTL->(DbCloseArea())
EndIf

Return()