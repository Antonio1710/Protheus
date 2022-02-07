#include "TOTVS.CH"
#Include "Topconn.ch"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} User Function U_ADGPE083P()
    Worflow de integração dos cadastros de colaboradores.
    Chamado 16833
    @type  Function
    @author Leonardo P. Monteiro
    @since 24/01/2022
    @version 01
    @history Chamado 16833 - Leonardo P. Monteiro - 24/01/2022- Desenvolvimento inicial.
    
/*/
user function ADGPE082P(aEmpFil)
	//local aEmpIni := {}
	Local cCodEmp   := ""
	Local cCodFil   := ""
    Local cPerg     := "ADGPE082P"
    Private lEnd    := .T.
    
    //RPCSetType(3)
	//RpcSetEnv("01","02",,,,GetEnvServer(),{ })
    

	if valType(aEmpFil) == "A"
		if len(aEmpFil) >= 2
			cCodEmp := aEmpFil[1]
			cCodFil := aEmpFil[2]
		endIf
	endIf

	if (!Empty(cCodEmp) .and. !Empty(cCodFil)) .AND. SELECT("SX2") == 0
		Qout(" JOB ADGPE082P-Protheus - 01 - Executando em modo Schedule Empresa "+ aEmpFil[1] + " e Filial " +aEmpFil[2] +"...")
		Qout(" JOB ADGPE082P-Protheus - 02 - Início da rotina...")

		PREPARE ENVIRONMENT EMPRESA cCodEmp FILIAL cCodFil
		lInJob := .F.
		RPCSetType(3) //nÃ£o consome licenÃ§a.
		Qout(DtoC(dDatabase) + "-" + Time() + " JOB ADGPE082P-Protheus - 03 - Início da rotina na Empresa "+ aEmpFil[1] + " e Filial " +aEmpFil[2] +"...")
		// Executa as rotinas de WorkFlow
		execWF(@lEnd, .T., cFilAnt, cFilAnt,'','ZZZZZZZZZZZZ')
		Qout(DtoC(dDatabase) + "-" + Time() + " JOB ADGPE082P-Protheus - 04 - Fim da rotina na Empresa "+ aEmpFil[1] + " e Filial " +aEmpFil[2] +"...")
		RESET ENVIRONMENT
		//PREPARE ENVIRONMENT EMPRESA "51" FILIAL "04"
		Qout(" JOB ADGPE082P-Protheus - 05 - Fim da execução...") 
	else
		// Executa as rotinas de WorkFlow
		if Pergunte(cPerg)
            //MsAguarde({|| execWF(.F.)},"Aguarde...","Enviando notificação de embarques...")
            oProcess := MsNewProcess():New( {|lEnd| execWF(@lEnd, .F., MV_PAR01, MV_PAR02, MV_PAR03, MV_PAR04)}, "Importando Dados", "Importação em andamento, Aguarde...", .F. )
            oProcess:ACTIVATE()
        endif
	endIf
return

Static Function execWF(lEnd, lAutom, cFilIni, cFilFim, cMatDe, cMatAte)
    
    Local oADOGPE       := ADOGPE():New()
    Local nTotEmp       := 0
    Local nConEmp       := 0
    Local nTotCol       := 0
    Local nConCol       := 0
    Local cDtIni        := Dtos(dDatabase-60)
    Default cFilIni     := cFilAnt 
    Default cFilFim     := cFilAnt
    
    cDtIni      := left(cDtIni,4)+"-"+Substr(cDtIni,5,2)+"-"+Substr(cDtIni,7,2)+" 00:00:00"

    cQuery := " SELECT ZI2_FILIAL, ZI2_COLRM, ZI2_FILRM, ZI2_DESCRI "
    cQuery += " FROM "+ RetSqlname("ZI2") +" ZI2 "
    cQuery += " WHERE D_E_L_E_T_='' AND ZI2_FILIAL BETWEEN '"+ cFilIni +"' AND '"+ cFilFim +"' "
    cQuery += " ORDER BY  ZI2_FILIAL, ZI2_COLRM, ZI2_FILRM; "
    
    TcQuery cQuery ALIAS "QZI2" NEW
    Count to nTotEmp
    QZI2->(Dbgotop())

    
    if QZI2->(!eof())
        nConEmp := 0
        nConCol := 0
        if !lAutom
            oProcess:setRegua1(nTotEmp)
        endif

        while QZI2->(!eof())
            nConEmp += 1
            if !lAutom
                oProcess:incRegua1("Empresa: "+ QZI2->ZI2_FILIAL+"-"+Alltrim(QZI2->ZI2_DESCRI) +" "+ CValToChar(nConEmp) +" de "+ CValToChar(nTotEmp))
            endif
            cQuery := " exec [dbo].[SP_RM_COLABORADORES] "+ QZI2->ZI2_COLRM +", "+ QZI2->ZI2_FILRM +", "+ QZI2->ZI2_FILRM +", '"+ cDtIni +"', '"+cMatDe+"', '"+cMatAte+"'; "
            
            TcQuery cQuery ALIAS "QCOL" NEW
            Count to nTotCol
            QCOL->(Dbgotop())

            if QCOL->(!eof())
                
                if !lAutom
                    oProcess:setRegua2(nTotCol)
                endif

                while QCOL->(!eof())
                    nConCol += 1

                    if !lAutom
                        oProcess:incRegua2(CValToChar(nConCol) +" de "+ CValToChar(nTotCol)+": "+ alltrim(QCOL->CHAPA)+"-"+Alltrim(QCOL->NOME) )
                    endif

                    oADOGPE:fCadEleg(QZI2->ZI2_FILIAL,;
                                    QCOL->PTOCREDENCIAL,;
                                    QCOL->CHAPA,;
                                    cvaltochar(QCOL->CODPESSOA),;
                                    QCOL->NOME,;
                                    QCOL->ADMISSAO,;
                                    QCOL->DEMISSAO,;
                                    QCOL->CODSITUACAO,;
                                    QCOL->SITUACAO,;
                                    QCOL->CCUSTO,;
                                    QCOL->CODSECAO,;
                                    QCOL->SECAO,;
                                    QCOL->CODFUNCAO,;
                                    QCOL->FUNCAO,;
                                    QCOL->CODTIPO,;
                                    QCOL->TIPORECEB,;
                                    QCOL->CODHORARIO,;
                                    QCOL->HORARIO,;
                                    QCOL->DTNASCIMENTO,;
                                    QCOL->TAM_CAMISA,;
                                    QCOL->TAM_BLUSATERMICA,;
                                    QCOL->TAM_CALCA,;
                                    QCOL->TAM_CALCATERMICA,;
                                    QCOL->TAM_CALCADO,;
                                    QCOL->TAM_MEIA)

                    QCOL->(Dbskip())

                enddo

                QCOL->(DBCLOSEAREA())
            endif
            nConEmp++
            QZI2->(Dbskip())
        ENDDO
    elseif !lAutom
        MsgAlert("Não foi encontrada nenhum empresa cadastrada!", "Empresas")
    endif

    QZI2->(DbcloseArea())

    FREEOBJ(oADOGPE)
Return .T.
