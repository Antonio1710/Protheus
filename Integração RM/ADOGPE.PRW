//#INCLUDE "msobjects.ch"
#INCLUDE "topconn.ch"
#INCLUDE "protheus.ch"

/*/{Protheus.doc} User Function ADOGPE
    Classe responsável pelas funções customizadas e genéricas dos módulos da folha de pagamento.
    @type  Function
    @author Leonardo P. Monteiro
    @since 20/01/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)

    @history chamado  - Leonardo P. Monteiro - 18/09/2021 - Finalização do desenvolvimento.
    @history chamado     ti - Leonardo P. Monteiro - 19/09/2021 - Ajuste no status de liberação por faltas.
    @history Ticket   65396 - Adriano Savoine      - 17/12/2021 - ADEQUANDO O RELATORIO AOS DADOS EXISTENTES NAS REGRAS DE INFRAESTRUTURA ADORO.
    @history Ticket   69148 - Leonardo P. Monteiro - 03/03/2022 - Correção de error.log no tratamento da varíavel cSexo.
    @history Chamado 16833 - Leonardo P. Monteiro - 08/03/2022- Ajustes e adequações nos fontes conforme novas regras propostas e inconsistências encontradas.
    @history Chamado 16833 - Leonardo P. Monteiro - 31/03/2022- Correção na gravação dos campos de medidas para os uniformes e armários. Quando alterado o cadastro os valores estavam sendo zerados.
/*/

Class ADOGPE

Data cEOL  			AS String
Data cQuery			AS String

Method New() Constructor
Method fCadEleg()

Method Destroy()  && Inline Super:Destroy()

EndClass

&& Metodo construtor
Method New() Class ADOGPE
	::cEOL   		:= CHR(13)+CHR(10)
    ::cQuery        := ""

Return

// --------------------------------------------------------------------------------------------------------
// fCadEleg - Cadastro de elegíveis.
// --------------------------------------------------------------------------------------------------------
METHOD fCadEleg(cFilPro,;
                cCredencial,;
                cChapa,;
                cCodPessoa,;
                cNome,;
                dAdmissao,;
                dDemissao,;
                cCodSit,;
                cDesSit,;
                cCC,;
                cCodSecao,;
                cDesSecao,;
                cCodFunc,;
                cDesFunc,;
                cCodTipo,;
                cCodTpRec,;
                cCodHorar,;
                cDesHorar,;
                dDtNasc,;
                cCamisa1,;
                cBlusaT1,;
                cCalca1,;
                cCalcT1,;
                cCalcado1,;
                cMeia1,;
                cSexo) CLASS ADOGPE
    Local cQuery        := ""

    Private cIncAlt     := "N"
    Private cCodSitT    := ""
    Private cCodFunT    := ""
    Private cCodSecT    := ""
    Private cCodHorT    := ""
    Private dDemissT    := Stod("")
    Private cCamisa1T   := ""
    Private cBlusaT1T   := ""
    Private cCalca1T    := ""
    Private cCalcT1T    := ""
    Private cCalcado1T  := ""
    Private cMeia1T     := ""
    Private cJalecoT    := ""
    Private cCodZHLT    := ""

    Default cCamisa1    := ""
    Default cBlusaT1    := ""
    Default cCalca1     := ""
    Default cCalcT1     := ""
    Default cCalcado1   := ""
    Default cMeia1      := ""
    Default cSexo       := ""

    DbSelectarea("ZI1")

    cQuery := fGetSQL(cFilPro,;
                cCredencial,;
                cChapa,;
                cCodPessoa,;
                cNome,;
                dAdmissao,;
                dDemissao,;
                cCodSit,;
                cDesSit,;
                cCC,;
                cCodSecao,;
                cDesSecao,;
                cCodFunc,;
                cDesFunc,;
                cCodTipo,;
                cCodTpRec,;
                cCodHorar,;
                cDesHorar,;
                dDtNasc,;
                cCamisa1,;
                cBlusaT1,;
                cCalca1,;
                cCalcT1,;
                cCalcado1,;
                cMeia1,;
                cSexo)

    Tcquery cQuery ALIAS "QZI1" NEW

    If QZI1->(!eof())
        if QZI1->REGZI1A != 0
            ZI1->(Dbgoto(QZI1->REGZI1))
            if ZI1->(Recno()) == QZI1->REGZI1
                
                cCodSitT    := ZI1->ZI1_CODSIT
                cCodFunT    := ZI1->ZI1_FUNCAO
                cCodSecT    := ZI1->ZI1_SECAO
                cCodHorT    := ZI1->ZI1_CODHOR
                dDemissT    := ZI1->ZI1_DEMISS

                cCamisa1T   := ZI1->ZI1_TCAMPA
                cBlusaT1T   := ZI1->ZI1_TBLUTE
                cCalca1T    := ZI1->ZI1_TCALPA
                cCalcT1T    := ZI1->ZI1_TCALTE
                cCalcado1T  := ZI1->ZI1_TCALCA
                cMeia1T     := ZI1->ZI1_TMEIAS
                cJalecoT    := ZI1->ZI1_TJALEC

                cCodZHLT    := ZI1->ZI1_CODZHL
            

                if Reclock("ZI1",.F.)
                    Dbdelete()
                    ZI1->(MsUnlock())
                    cIncAlt := "A"
                endif

            endif
            
        endif
        
    else
        cIncAlt := "I"
    endif

    if cIncAlt != "N"

        // ZI3 - Cadastro da função.
        fCadSit(cCodSit, cDesSit)
        
        // ZI4 - Cadastro da função.
        fCadFun(cCodFunc, cDesSecao)
        
        // ZI5 - Cadastro da seção.
        fCadSec(cCodSecao, cDesSecao)
        
        // ZI6 - Cadastro do horário.
        fCadHor(cCodHorar, cDesHorar)
        
        // ZIJ - Cadastra as Unidades de Medidas cadastradas no RM.
        if !Empty(cCamisa1)
            fCadUM("01", cCamisa1)
        endif
        // ZIJ - Cadastra as Unidades de Medidas cadastradas no RM.
        if !Empty(cBlusaT1)
            fCadUM("02", cBlusaT1)
        endif
        // ZIJ - Cadastra as Unidades de Medidas cadastradas no RM.
        if !Empty(cCalca1)
            fCadUM("03", cCalca1)
        endif
        // ZIJ - Cadastra as Unidades de Medidas cadastradas no RM.
        if !Empty(cCalcT1)
            fCadUM("04", cCalcT1)
        endif
        // ZIJ - Cadastra as Unidades de Medidas cadastradas no RM.
        if !Empty(cCalcado1)
            fCadUM("05", cCalcado1)
        endif
        // ZIJ - Cadastra as Unidades de Medidas cadastradas no RM.
        if !Empty(cMeia1)
            fCadUM("06", cMeia1)
        endif
        
        if Reclock("ZI1",.T.)
            // --------------------------------------------------------------------------------------------------------
            // Campos gerais do cadastro do funcionário, terceiros e parceiros.
            // --------------------------------------------------------------------------------------------------------
            ZI1_FILIAL  := cFilPro
            ZI1_MAT     := cChapa
            ZI1_CREDEN  := cCredencial
            ZI1_CODPES  := cCodPessoa
            ZI1_NOME    := cNome
            ZI1_CC      := cCC
            ZI1_SECAO   := cCodSecao
            ZI1_FUNCAO  := cCodFunc
            ZI1_CODTIP  := cCodTipo
            ZI1_CODSIT  := cCodSit
            ZI1_TIPREC  := cCodTpRec
            ZI1_CODHOR  := cCodHorar
            ZI1_ADMISS  := dAdmissao
            ZI1_DEMISS  := dDemissao

            // Regrava as informações na alteração do registro.
            if cIncAlt == "A"
                ZI1->ZI1_CODSIT := cCodSitT
                ZI1->ZI1_FUNCAO := cCodFunT
                ZI1->ZI1_SECAO  := cCodSecT
                ZI1->ZI1_CODHOR := cCodHorT
                ZI1->ZI1_DEMISS := dDemissT

                ZI1->ZI1_TCALCA := cCalcado1T
                ZI1->ZI1_TBLUTE := cBlusaT1T
                ZI1->ZI1_TCALPA := cCalca1T
                ZI1->ZI1_TCALTE := cCalcT1T
                ZI1->ZI1_TCAMPA := cCamisa1T
                ZI1->ZI1_TJALEC := cJalecoT
                ZI1->ZI1_TMEIAS := cMeia1T
                
                ZI1->ZI1_CODZHL := cCodZHLT
            endif



            if !Empty(cCamisa1) .AND. Empty(ZI1->ZI1_TCAMPA)
                ZI1->ZI1_TCAMPA := Alltrim(cCamisa1)
            endif
            
            if !Empty(cBlusaT1) .AND. Empty(ZI1->ZI1_TBLUTE)
                ZI1->ZI1_TBLUTE := Alltrim(cBlusaT1)
            endif
            
            if !Empty(cCalca1)  .AND. Empty(ZI1->ZI1_TCALPA)
                ZI1->ZI1_TCALPA := Alltrim(cCalca1)
            endif
            
            if !Empty(cCalcT1)  .AND. Empty(ZI1->ZI1_TCALTE)
                ZI1->ZI1_TCALTE := Alltrim(cCalcT1)
            endif
            
            if !Empty(cCalcado1) .AND. Empty(ZI1->ZI1_TCALCA)
                ZI1_TCALCA := Alltrim(cCalcado1)
            endif
            
            if !Empty(cMeia1)   .AND. Empty(ZI1->ZI1_TMEIAS)
                ZI1_TMEIAS := Alltrim(cMeia1)
            endif

            if !Empty(cSexo)
                ZI1_SEXO := Alltrim(cSexo)
            endif

            if !Empty(dDtNasc)
                ZI1_DTNASC := dDtNasc
            endif
            

            // --------------------------------------------------------------------------------------------------------
            // Parâmtros do Kit Frango.
            // --------------------------------------------------------------------------------------------------------
            ZI1_KITMON  := "2"
            ZI1_MONATV  := "2"
            ZI1_KITANI  := "2"
            ZI1_KITMEN  := "2"

            
            // --------------------------------------------------------------------------------------------------------
            // Parâmtros referentes ao Uniformes/Armários/Transportes.
            // --------------------------------------------------------------------------------------------------------
            if dDemissT != dDemissao
                ZI1_STDEMI := "1"
            Elseif cIncAlt == "I"
                ZI1_STNVCO  := "1"
            else
                if cCodSitT != cCodSit
                    ZI1_STSITU := "1" 
                endif

                IF cCodFunT  != Alltrim(cCodFunc)
                    ZI1_STFUNC := "1" 
                endif
                if cCodSecT  != Alltrim(cCodSecao)
                    ZI1_STSECA := "1"
                endif
                
                if cCodHorT  != Alltrim(cCodHorar)
                    ZI1_STHORA := "1"
                endif

            endif

            if Empty(ZI1->ZI1_STDEMI)
                ZI1_STDEMI := "2"
            endif

            if Empty(ZI1->ZI1_STNVCO)
                ZI1_STNVCO  := "2"
            endif

            if Empty(ZI1->ZI1_STSITU)
                ZI1_STSITU := "2" 
            endif

            IF Empty(ZI1->ZI1_STFUNC)
                ZI1_STFUNC := "2" 
            endif
            if Empty(ZI1->ZI1_STSECA)
                ZI1_STSECA := "2"
            endif
            
            if Empty(ZI1->ZI1_STHORA)
                ZI1_STHORA := "2"
            endif

            // --------------------------------------------------------------------------------------------------------
            // Campos referente ao integração e não permite que sejam editados registros importados do RM.
            // --------------------------------------------------------------------------------------------------------
            ZI1_TIPINC  := "I"
            ZI1_MSBLQL  := "2"
            ZI1_WKALTE  := Stod("") 

            ZI1->(MsUnlock())

        endif

    endif

    if select("QZI1") > 0
        QZI1->(DbcloseArea())
    endif

    ZI3->(DBCLOSEAREA())
    ZI4->(DBCLOSEAREA())
    ZI5->(DBCLOSEAREA())
    ZI6->(DBCLOSEAREA())
return

Static Function fGetSQL(cFilPro,;
                cCredencial,;
                cChapa,;
                cCodPessoa,;
                cNome,;
                dAdmissao,;
                dDemissao,;
                cCodSit,;
                cDesSit,;
                cCC,;
                cCodSecao,;
                cDesSecao,;
                cCodFunc,;
                cDesFunc,;
                cCodTipo,;
                cCodTpRec,;
                cCodHorar,;
                cDesHorar,;
                dDtNasc,;
                cCamisa1,;
                cBlusaT1,;
                cCalca1,;
                cCalcT1,;
                cCalcado1,;
                cMeia1,;
                cSexo)
    Local cQuery := ""

    /**************************************************************************************************************
    Incluir nessa condição qualquer campo que seja uma condicional para atualizar o cadastro dos funcionários.
    **************************************************************************************************************/
    cQuery := " SELECT ZI1.R_E_C_N_O_ REGZI1, isnull(ZI1A.R_E_C_N_O_,0) REGZI1A "
    cQuery += " FROM "+ Retsqlname("ZI1") +" (nolock) ZI1 LEFT JOIN "+ Retsqlname("ZI1") +" (nolock) ZI1A ON ZI1.D_E_L_E_T_='' AND ZI1A.D_E_L_E_T_='' AND ZI1.R_E_C_N_O_=ZI1A.R_E_C_N_O_ "
    cQuery += "  AND ( "
    cQuery += "     LTRIM(RTRIM(ZI1A.ZI1_CODPES)) != '"+ Alltrim(cCodPessoa) +"' "
    cQuery += "  OR LTRIM(RTRIM(ZI1A.ZI1_CREDEN)) != '"+ Alltrim(cCredencial) +"' "
    cQuery += "  OR LTRIM(RTRIM(ZI1A.ZI1_NOME))   != '"+ Alltrim(cNome) +"' "
    cQuery += "  OR LTRIM(RTRIM(ZI1A.ZI1_CC))     != '"+ Alltrim(cCC) +"' "
    cQuery += "  OR LTRIM(RTRIM(ZI1A.ZI1_SECAO))  != '"+ Alltrim(cCodSecao) +"' "
    cQuery += "  OR LTRIM(RTRIM(ZI1A.ZI1_FUNCAO)) != '"+ Alltrim(cCodFunc) +"' "
    cQuery += "  OR LTRIM(RTRIM(ZI1A.ZI1_CODTIP)) != '"+ Alltrim(cCodTipo) +"' "
    cQuery += "  OR LTRIM(RTRIM(ZI1A.ZI1_CODSIT)) != '"+ Alltrim(cCodSit) +"' "
    cQuery += "  OR LTRIM(RTRIM(ZI1A.ZI1_TIPREC)) != '"+ Alltrim(cCodTpRec) +"' "
    cQuery += "  OR LTRIM(RTRIM(ZI1A.ZI1_CODHOR)) != '"+ Alltrim(cCodHorar) +"' "
    cQuery += "  OR LTRIM(RTRIM(ZI1A.ZI1_ADMISS)) != '"+ Dtos(dAdmissao) +"' "
    cQuery += "  OR LTRIM(RTRIM(ZI1A.ZI1_DEMISS)) != '"+ Dtos(dDemissao) +"' "
    
    if !Empty(cCamisa1)
        cQuery += "  OR ltrim(rtrim(ZI1A.ZI1_TCAMPA)) != '"+ Alltrim(cCamisa1) +"' "
    endif
    if !Empty(cBlusaT1)
        cQuery += "  OR ltrim(rtrim(ZI1A.ZI1_TBLUTE)) != '"+ Alltrim(cBlusaT1) +"' "
    endif
    if !Empty(cCalca1)
        cQuery += "  OR ltrim(rtrim(ZI1A.ZI1_TCALPA)) != '"+ Alltrim(cCalca1) +"' "
    endif
    if !Empty(cCalcT1)
        cQuery += "  OR ltrim(rtrim(ZI1A.ZI1_TCALTE)) != '"+ Alltrim(cCalcT1) +"' "
    endif
    if !Empty(cCalcado1)
        cQuery += "  OR ltrim(rtrim(ZI1A.ZI1_TCALCA)) != '"+ Alltrim(cCalcado1) +"' "
    endif
    if !Empty(cMeia1)
        cQuery += "  OR ltrim(rtrim(ZI1A.ZI1_TMEIAS)) != '"+ Alltrim(cMeia1) +"' "
    endif
    if !Empty(cSexo)
        cQuery += "  OR LTRIM(RTRIM(ZI1A.ZI1_SEXO)) != '"+ Alltrim(cSexo) +"' "
    endif

    
    if !Empty(dDtNasc)
        cQuery += "  OR ZI1A.ZI1_DTNASC != '"+ Dtos(dDtNasc) +"' "
    endif
    cQuery += " ) "
    cQuery += " WHERE ZI1.D_E_L_E_T_='' AND ZI1.ZI1_FILIAL='"+ cFilPro +"' AND ZI1.ZI1_MAT='"+ cChapa +"' "

return cQuery


Static function fGeraLog(cPosicao,cIncAlt)

    Local cParame := "Filial/Mat/Creden/Nome/CC/Secao/Funcao/Tipo/Situação/TpRec/Horário/Admissão/Demissão"+;
                ZI1->ZI1_FILIAL+"/"+ZI1->ZI1_MAT+"/"+ZI1->ZI1_CREDEN+"/"+alltrim(ZI1->ZI1_NOME)+"/"+ZI1->ZI1_CC+ZI1_SECAO+;
                "/"+ZI1->ZI1_FUNCAO+"/"+ZI1->ZI1_CODTIP+"/"+ZI1->ZI1_CODSIT+"/"+ZI1->ZI1_TIPREC+"/"+ZI1->ZI1_CODHOR+;
                "/"+Stod(ZI1->ZI1_ADMISS)+"/"+Stod(ZI1->ZI1_DEMISS)
            
    u_GrLogZBE( Date(),;
        TIME(),;
        cUserName,;
        "Gravação de Colaboradores ("+ iif(cIncAlt== "I","Inclusão","Alteração") +") ",;
        "GESTÃO DE PESSOAL",;
        Funname(),;
        "["+cPosicao+"] - "+ iif(cIncAlt== "I","Inclusão","Alteração") +" - "+ cParame,;
        ComputerName(),;
        LogUserName())

return

// --------------------------------------------------------------------------------------------------------
// Cadastro das Unidades de Medidas.
// --------------------------------------------------------------------------------------------------------
Static Function fCadUM(cTipo, cUM)
    DbselectArea("ZHJ")
    ZHJ->(DbSetOrder(1))

    if !ZHJ->(Dbseek(xFilial("ZHJ")+cTipo+cUM))
        reclock("ZHJ",.T.)
        ZHJ_FILIAL  := xFilial("ZHJ")
        ZHJ_TIPO    := cTipo
        ZHJ_UM      := cUM
        MsUnlock("ZHJ")
    endif
return


// --------------------------------------------------------------------------------------------------------
// Cadastro da situação do colaborador.
// --------------------------------------------------------------------------------------------------------
Static Function fCadSit(cCod, cDescri)
    DbselectArea("ZI3")
    ZI3->(DbSetOrder(1))

    if ZI3->(Dbseek(xFilial("ZI3")+cCod))
        reclock("ZI3",.F.)
        ZI3_DESCRI  := cDescri
        MsUnlock("ZI3")
    else
        reclock("ZI3",.T.)
        ZI3_FILIAL  := xFilial("ZI3")
        ZI3_CODIGO  := cCod
        ZI3_DESCRI  := cDescri
        MsUnlock("ZI3")
    endif
return

// --------------------------------------------------------------------------------------------------------
// Cadastro de funções.
// --------------------------------------------------------------------------------------------------------
Static Function fCadFun(cCod, cDescri)
    DbselectArea("ZI4")
    ZI4->(DbSetOrder(1))

    if ZI4->(Dbseek(xFilial("ZI4")+cCod))
        reclock("ZI4",.F.)
        ZI4_DESCRI  := cDescri
        MsUnlock("ZI4")
    else
        reclock("ZI4",.T.)
        ZI4_FILIAL  := xFilial("ZI4")
        ZI4_CODIGO  := cCod
        ZI4_DESCRI  := cDescri
        MsUnlock("ZI4")
    endif
return

// --------------------------------------------------------------------------------------------------------
// Cadastro da seção.
// --------------------------------------------------------------------------------------------------------
Static Function fCadSec(cCod, cDescri)
    DbselectArea("ZI5")
    ZI5->(DbSetOrder(1))

    if ZI5->(Dbseek(xFilial("ZI5")+cCod))
        reclock("ZI5",.F.)
        ZI5_DESCRI  := cDescri
        MsUnlock("ZI5")
    else
        reclock("ZI5",.T.)
        ZI5_FILIAL  := xFilial("ZI5")
        ZI5_CODIGO  := cCod
        ZI5_DESCRI  := cDescri
        ZI5_SECVLD  := "S"
        ZI5_MSBLQL  := "2"
        MsUnlock("ZI5")
    endif
return

// --------------------------------------------------------------------------------------------------------
// Cadastro do horário de trabalho do colaborador.
// --------------------------------------------------------------------------------------------------------
Static Function fCadHor(cCod, cDescri)
    DbselectArea("ZI6")
    ZI6->(DbSetOrder(1))

    if ZI6->(Dbseek(xFilial("ZI6")+cCod))
        reclock("ZI6",.F.)
        ZI6_DESCRI  := cDescri
        MsUnlock("ZI6")
    else
        reclock("ZI6",.T.)
        ZI6_FILIAL  := xFilial("ZI6")
        ZI6_CODIGO  := cCod
        ZI6_DESCRI  := cDescri
        MsUnlock("ZI6")
    endif
return
