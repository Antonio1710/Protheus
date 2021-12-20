#INCLUDE "totvs.ch"
#INCLUDE "FWMVCDef.ch"
#INCLUDE "topconn.ch"

#define ZI7EXCLUS  '|ZI7_FILIAL|ZI7_PERIDO|ZI7_MAT|ZI7_PRODUT|ZI7_PERIOD|'

/*/{Protheus.doc} User Function ADGPE066P
    Rotina de integração e manutenção dos registros importados do RM para entrega dos kits frangos para os funcionários Ad'oro.
    @type  Function
    @author Leonardo P. Monteiro
    @since 21/07/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)

    U_ADGPE066P()
    @history chamado     ti - Leonardo P. Monteiro - 18/09/2021 - Finalização do desenvolvimento.
    @history chamado     ti - Leonardo P. Monteiro - 19/09/2021 - Ajuste no status de liberação por faltas.
    @history Ticket   65396 - Adriano Savoine      - 17/12/2021 - ADEQUANDO O RELATORIO AOS DADOS EXISTENTES NAS REGRAS DE INFRAESTRUTURA ADORO.
/*/

Static cTitulo := "..:: Manutenção de KITs Frangos ::.."

User Function ADGPE066P()
    Local aArea     := GetArea()
    Local aParamBox := {}
    Local aRet      := {}
    Private cPerBrw := ""
    Private oBrowse

    cPerBrw := fPerAbe()
    
    if Empty(Alltrim(cPerBrw))
        cPerBrw := cValtoChar(YEAR(DATE()))+"/"+StrZero(MONTH(DATE()),2)
    endif

    Aadd( aParamBox ,{1,"Período?"						,cPerBrw,"9999/99" ,'.T.',"",'.T.',80,.F.})
    
    

    if ParamBox(aParamBox,"Parâmetros",@aRet)
        
        cPerBrw := Alltrim(MV_PAR01)
        
        DbSelectArea("ZI0")
        ZI0->(DbSetOrder(4))
        //Set Filter to ZI0->ZI0_PERIOD==cPerBrw
        ZI0->(DbSetFilter( { || Alltrim(ZI0->ZI0_PERIOD)==cPerBrw }, "ltrim(rtrim(ZI0->ZI0_PERIOD))='"+cPerBrw+"'" ) )
        ZI0->(DbSetOrder(1))
    else
        cPerBrw := ""
    endif
        SetFunName("ADGPE066P")

        U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro de Grupo de inspeção Relacionado na tabela de clientes SA1 e SC5')
        
        //Instânciando FWMBrowse - Somente com dicionário de dados
        oBrowse := FWMarkBrowse():New()
        
        //Setando a tabela de cadastro de grupo de inspeção
        oBrowse:SetAlias("ZI0")
        //Controla a seleção para diversos usuários.
        //oBrowse:SetSemaphore(.T.)

        if !Empty(cPerBrw)
            oBrowse:SetFilterDefault("ZI0->ZI0_PERIOD='"+ cPerBrw +"'")
        endif
        //Setando a descrição da rotina
        oBrowse:SetDescription(cTitulo)

        oBrowse:SetFieldMark( 'ZI0_OK' )
        //oBrowse:Setfocus()

        //Legendas
        oBrowse:AddLegend( "ZI0->ZI0_STATUS == '1' .AND. ZI0->ZI0_AUTAJU !='S' ", "BR_VERMELHO" ,  "Fase 1 - Registro bloqueado para entrega." )
        oBrowse:AddLegend( "ZI0->ZI0_STATUS == '1' .AND. ZI0->ZI0_AUTAJU =='S' ", "BR_VERDE"    ,  "Fase 1 - Registro aprovado, aguardando liberação." )
        oBrowse:AddLegend( "ZI0->ZI0_STATUS == '2' ", "BR_LARANJA"  ,  "Fase 2 - Registro entregue pela Expedição." )
        oBrowse:AddLegend( "ZI0->ZI0_STATUS == '3' ", "BR_AMARELO"  ,  "Fase 3 - Registro verificado pela Portaria." )
        oBrowse:AddLegend( "ZI0->ZI0_STATUS == '4' ", "BR_PRETO"    ,  "Fase 4 - Período finalilzado." )
        

        //Ativa a Browse
        oBrowse:Activate()
        
    //endif
    //SetFunName(cFunBkp)
    RestArea(aArea)
Return .T.

Static Function MenuDef() 

	Local aRotina := {}  
	
	//ADD OPTION aRotina TITLE 'Incluir'              ACTION 'VIEWDEF.ADGPE066P' OPERATION MODEL_OPERATION_INSERT ACCESS 0 DISABLE MENU
	ADD OPTION aRotina TITLE 'Visualizar'           ACTION 'VIEWDEF.ADGPE066P' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 DISABLE MENU
	ADD OPTION aRotina TITLE 'Alterar'              ACTION 'VIEWDEF.ADGPE066P' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 DISABLE MENU
    ADD OPTION aRotina TITLE 'Gera Excel'           ACTION 'U_GPE066PD()' OPERATION MODEL_OPERATION_DELETE ACCESS 0 DISABLE MENU
    ADD OPTION aRotina TITLE 'Excluir'              ACTION 'MsAguarde({|| U_GPE066PB("EXCLUI") },"Função GPE066PA","Excluindo registros, aguarde...")' OPERATION MODEL_OPERATION_DELETE ACCESS 0 DISABLE MENU
    ADD OPTION aRotina TITLE 'Estorno Liberação'    ACTION 'MsAguarde({|| U_GPE066PB("CANC_ENTREGA") },"Função GPE066PA","Cancelando entregas, aguarde...")' OPERATION MODEL_OPERATION_DELETE ACCESS 0 DISABLE MENU
    ADD OPTION aRotina TITLE 'Importar RM'          ACTION 'MsAguarde({|| U_GPE066PA() },"Função GPE066PA","Importando os dados do RM, aguarde...")' OPERATION MODEL_OPERATION_INSERT ACCESS 0 DISABLE MENU
    ADD OPTION aRotina TITLE 'Finalizar período'    ACTION 'U_GPE066PC()' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 DISABLE MENU
Return aRotina

user Function GPE066PC()
    Local aArea         := GetArea()
    
    Private aParamBox     := {}
    Private cPeriod     := Space(07)
    Private aRet        := {}

    cPeriod := fPerAbe()

    Aadd( aParamBox ,{1,"Período?"						,cPeriod,"9999/99" ,'.T.',"",'.T.',80,.F.})
    
    if ParamBox(aParamBox,"Parâmetros",@aRet)
        if MsgYesNo("Confirma a ação fechamento do período "+ cPeriod +"?", "Fechamento")
            MsAguarde({|| fFecham() },"Função Fechamento","Finalizando período, aguarde...")
        else
            MsgAlert("Ação cancelada pelo operador!", "..:: Alerta ::..")
        endif
    else
        msginfo("Operação cancelada pelo operador!")
    endif

    RestArea(aArea)

    oBrowse:refresh()
return


user Function GPE066PD()
    Local aArea         := GetArea()
    
    Private aParamBox     := {}
    Private cPeriod     := Space(07)
    Private aRet        := {}
    Private CTABELA     := "Kit_Frangro"
    Private cPlanilha   := "Planilha"
    Private CPATHREL    := "c:\TEMP\"  //Ticket   65396 - Adriano Savoine      - 17/12/2021 

    cPeriod := fPerAbe()

    Aadd( aParamBox ,{1,"Período?"						,cPeriod,"9999/99" ,'.T.',"",'.T.',80,.F.})
    
    if ParamBox(aParamBox,"Parâmetros",@aRet)
        MsAguarde({|| fExcel() },"Gerando Relatório","Gerando Excel, aguarde...")
    else
        msginfo("Operação cancelada pelo operador!")
    endif

    RestArea(aArea)

    oBrowse:refresh()
return

Static function fExcel()
    Private _lAbreEx    := .T.
    Private oExcel      := FWMsExcelEx():New()
	
    if fQryExc()
    
        cArquivo := cPathRel +  'ADGPE066P_' + DTOS(DATE()) + STRTRAN(TIME(),':','') + '.xls'

        oExcel:AddworkSheet(cTabela)
        oExcel:AddTable(cTabela,cPlanilha)
        oExcel:AddColumn(cTabela,cPlanilha,"Filial",1,1) //01 - QEXCEL->ZI0_FILIAL
        oExcel:AddColumn(cTabela,cPlanilha,"Status",1,1) //02 - QEXCEL->ZI0_STATUS
        oExcel:AddColumn(cTabela,cPlanilha,"Período",1,1) //03 - QEXCEL->ZI0_PERIOD
        oExcel:AddColumn(cTabela,cPlanilha,"Per. Inicial",3,1) //04 - QEXCEL->ZI0_PERINI
        oExcel:AddColumn(cTabela,cPlanilha,"Per. Final",3,1) //05 - QEXCEL->ZI0_PERFIM
        oExcel:AddColumn(cTabela,cPlanilha,"Matrícula",1,1) //06 - QEXCEL->ZI0_MAT
        oExcel:AddColumn(cTabela,cPlanilha,"Credencial",1,1) //017 - QEXCEL->ZI0_CREDEN
        oExcel:AddColumn(cTabela,cPlanilha,"Cod. Pessoa",1,1) //08 - QEXCEL->ZI0_CODPES
        oExcel:AddColumn(cTabela,cPlanilha,"Nome",1,1) //09 - QEXCEL->ZI1_NOME
        oExcel:AddColumn(cTabela,cPlanilha,"Situação",1,1) //10 - QEXCEL->ZI0_CODSIT +"-"+QEXCEL->CODSITDESC
        oExcel:AddColumn(cTabela,cPlanilha,"Produto",1,1) //11 - QEXCEL->ZI0_PRODUT
        oExcel:AddColumn(cTabela,cPlanilha,"Centro Custo",1,1) //12 - QEXCEL->ZI0_CC
        oExcel:AddColumn(cTabela,cPlanilha,"Função",1,1) //13 - QEXCEL->ZI0_FUNCAO +"-"+QEXCEL->FUNCDESC
        oExcel:AddColumn(cTabela,cPlanilha,"Seção",1,1) //14 - QEXCEL->ZI0_SECAO+"-"+QEXCEL->SECDESC
        oExcel:AddColumn(cTabela,cPlanilha,"Tipo",1,1) //15 - QEXCEL->ZI0_CODTIP
        oExcel:AddColumn(cTabela,cPlanilha,"tp. Receb",1,1) //16 - QEXCEL->ZI0_TIPREC
        oExcel:AddColumn(cTabela,cPlanilha,"Cod. Horário",1,1) //17 - QEXCEL->ZI0_CODHOR+"-"+QEXCEL->HORADESCR
        oExcel:AddColumn(cTabela,cPlanilha,"Dt. Nascimento",1,1) //18 - QEXCEL->ZI0_DTNASC
        oExcel:AddColumn(cTabela,cPlanilha,"Origem Registro",1,1) //19 - QEXCEL->ZI0_ORIGEM
        oExcel:AddColumn(cTabela,cPlanilha,"Motivo",1,1) //20 - QEXCEL->ZI0_MOTIVO
        oExcel:AddColumn(cTabela,cPlanilha,"Faltas",1,1) //21 - QEXCEL->ZI0_FALTAS
        oExcel:AddColumn(cTabela,cPlanilha,"Faltas Status",1,1) //22 - QEXCEL->ZI0_FALVLD
        oExcel:AddColumn(cTabela,cPlanilha,"Atrasos",1,1) //23 - QEXCEL->ZI0_ATRQTD
        oExcel:AddColumn(cTabela,cPlanilha,"Atrasos Status",1,1) //24 - QEXCEL->ZI0_ATRVLD
        oExcel:AddColumn(cTabela,cPlanilha,"Dias Afastamento",1,1) //25 - QEXCEL->ZI0_DIAFAQ
        oExcel:AddColumn(cTabela,cPlanilha,"Dias Afast. Status",1,1) //26 - QEXCEL->ZI0_DIAFAV
        oExcel:AddColumn(cTabela,cPlanilha,"Dias Trabalhado",1,1) //27 - QEXCEL->ZI0_DIATRA
        oExcel:AddColumn(cTabela,cPlanilha,"Dias Trab. Status",1,1) //28 - QEXCEL->ZI0_DIATVL
        //oExcel:AddColumn(cTabela,cPlanilha,"Mês Nasc.",1,1) //29
        //oExcel:AddColumn(cTabela,cPlanilha,"Nascim Status",1,1) //30
        oExcel:AddColumn(cTabela,cPlanilha,"Mês Contr. Exper",1,1) //31 - QEXCEL->ZI0_MEXMES
        oExcel:AddColumn(cTabela,cPlanilha,"Contr. Exp Status",1,1) //32 - QEXCEL->ZI0_MEXVLD
        oExcel:AddColumn(cTabela,cPlanilha,"Autor. Original",1,1) //33 - QEXCEL->ZI0_AUTORI
        oExcel:AddColumn(cTabela,cPlanilha,"Autor. Manual",1,1) //34 - QEXCEL->ZI0_AUTAJU
        oExcel:AddColumn(cTabela,cPlanilha,"Motivo",1,1) //35 - QEXCEL->ZI0_MOTAJU
        oExcel:AddColumn(cTabela,cPlanilha,"Fechamento",1,1) //36 - QEXCEL->ZI0_FECHAM
        oExcel:AddColumn(cTabela,cPlanilha,"Usu. Fechamento",1,1) //37 - QEXCEL->ZI0_FECUSU
        oExcel:AddColumn(cTabela,cPlanilha,"ID",1,1) //38 - QEXCEL->ZI0_UUID
        oExcel:AddColumn(cTabela,cPlanilha,"Data Importação",1,1) //39 - QEXCEL->ZI0_IMPDAT
        oExcel:AddColumn(cTabela,cPlanilha,"Usuário Importa",1,1) //40 - QEXCEL->ZI0_IMPUSU
        oExcel:AddColumn(cTabela,cPlanilha,"Expedição-Insp",1,1) //41 - QEXCEL->ZI0_EXPVLD
        oExcel:AddColumn(cTabela,cPlanilha,"Expedição-Data",1,1) //42 - QEXCEL->ZI0_EXPDAT
        oExcel:AddColumn(cTabela,cPlanilha,"Expedição-Usuário",1,1) //43 - QEXCEL->ZI0_EXPUSU
        oExcel:AddColumn(cTabela,cPlanilha,"Expedição-Data Excl.",1,1) //44 - QEXCEL->ZI0_EXPDEX
        oExcel:AddColumn(cTabela,cPlanilha,"Expedição-Usuario Excl.",1,1) //45 - QEXCEL->ZI0_EXPUEX
        oExcel:AddColumn(cTabela,cPlanilha,"Portaria-Insp",1,1) //46 - QEXCEL->ZI0_PORVLD
        oExcel:AddColumn(cTabela,cPlanilha,"Portaria-Data",1,1) //47 - QEXCEL->ZI0_PORDAT
        oExcel:AddColumn(cTabela,cPlanilha,"Portaria-Usuário",1,1) //48 - QEXCEL->ZI0_PORUSU
        oExcel:AddColumn(cTabela,cPlanilha,"Portaria-Data Excl.",1,1) //49 - QEXCEL->ZI0_PORDEX
        oExcel:AddColumn(cTabela,cPlanilha,"Portaria-Usuario Excl.",1,1) //50 - QEXCEL->ZI0_PORUEX
        oExcel:AddColumn(cTabela,cPlanilha,"Data. Exclusão",1,1) //51 - QEXCEL->ZI0_EXCDAT           
        oExcel:AddColumn(cTabela,cPlanilha,"Usuário Exclusão",1,1) //52 - QEXCEL->ZI0_EXCUSU


        QEXCEL->(Dbgotop())
        
        While QEXCEL->(!eof())
            oExcel:AddRow(cTabela,cPlanilha,;
            {QEXCEL->ZI0_FILIAL,;
            fGetSt("ZI0_STATUS", QEXCEL->ZI0_STATUS),;
            QEXCEL->ZI0_PERIOD,;
            STOD(QEXCEL->ZI0_PERINI),;
            STOD(QEXCEL->ZI0_PERFIM),;
            QEXCEL->ZI0_MAT,;
            QEXCEL->ZI0_CREDEN,;
            QEXCEL->ZI0_CODPES,;
            QEXCEL->ZI1_NOME,;
            QEXCEL->ZI0_CODSIT +"-"+QEXCEL->CODSITDESC,;
            QEXCEL->ZI0_PRODUT,;
            QEXCEL->ZI0_CC,;
            QEXCEL->ZI0_FUNCAO +"-"+QEXCEL->FUNCDESC,;
            QEXCEL->ZI0_SECAO+"-"+QEXCEL->SECDESC,;
            fGetSt("ZI0_CODTIP", QEXCEL->ZI0_CODTIP),;
            fGetSt("ZI0_TIPREC", QEXCEL->ZI0_TIPREC),;
            QEXCEL->ZI0_CODHOR+"-"+QEXCEL->HORADESCR,;
            STOD(QEXCEL->ZI0_DTNASC),;
            fGetSt("ZI0_ORIGEM", QEXCEL->ZI0_ORIGEM),;
            QEXCEL->ZI0_MOTIVO,;
            QEXCEL->ZI0_FALTAS,;
            fGetSt("REGRAS", QEXCEL->ZI0_FALVLD),;
            QEXCEL->ZI0_ATRQTD,;
            fGetSt("REGRAS", QEXCEL->ZI0_ATRVLD),;
            QEXCEL->ZI0_DIAFAQ,;
            fGetSt("REGRAS", QEXCEL->ZI0_DIAFAV),;
            QEXCEL->ZI0_DIATRA,;
            fGetSt("REGRAS", QEXCEL->ZI0_DIATVL),;
            QEXCEL->ZI0_MEXMES,;
            fGetSt("REGRAS", QEXCEL->ZI0_MEXVLD),;
            fGetSt("REGRAS", QEXCEL->ZI0_AUTORI),;
            fGetSt("REGRAS", QEXCEL->ZI0_AUTAJU),;
            QEXCEL->ZI0_MOTAJU,;
            QEXCEL->ZI0_FECHAM,;
            QEXCEL->ZI0_FECUSU,;
            QEXCEL->ZI0_UUID,;
            STOD(QEXCEL->ZI0_IMPDAT),;
            QEXCEL->ZI0_IMPUSU,;
            fGetSt("APROVACAO", QEXCEL->ZI0_EXPVLD),;
            STOD(QEXCEL->ZI0_EXPDAT),;
            QEXCEL->ZI0_EXPUSU,;
            QEXCEL->ZI0_EXPDEX,;
            QEXCEL->ZI0_EXPUEX,;
            fGetSt("APROVACAO", QEXCEL->ZI0_PORVLD),;
            QEXCEL->ZI0_PORDAT,;
            QEXCEL->ZI0_PORUSU,;
            QEXCEL->ZI0_PORDEX,;
            QEXCEL->ZI0_PORUEX,;
            QEXCEL->ZI0_EXCDAT,;
            QEXCEL->ZI0_EXCUSU})

            QEXCEL->(Dbskip())
        enddo
        
 		oExcel:Activate()              
		oExcel:GetXMLFile(cArquivo) 

		oExcelApp := MsExcel():New()
		oExcelApp:WorkBooks:Open(cArquivo)
		oExcelApp:SetVisible(.T.)
    endif

    QEXCEL->(DbcloseArea())
return

Static function fGetSt(cRegra, cValor)
    Local cRet := cValor

    if cRegra == "ZI0_STATUS"
        if cValor == "1" .AND. QEXCEL->ZI0_AUTAJU == "S"
            cRet := Alltrim(cValor)+"-Aguardando coleta"
        Elseif cValor == "1" .AND. QEXCEL->ZI0_AUTAJU != "S"
            cRet := Alltrim(cValor)+"-Bloqueado p/ coleta"
        Elseif cValor == "2"
            cRet := Alltrim(cValor)+"-Item entregue na expedição"
        Elseif cValor == "3"
            cRet := Alltrim(cValor)+"-Pendente de checagem na portaria"
        Elseif cValor == "4"
            cRet := Alltrim(cValor)+"-Período finalizado"
        endif
    // N=Normal;D=Diretor;T=Terceiros;Z=Aprendiz                                                                                       
    elseif cRegra == "ZI0_CODTIP"
        if cValor == "N"
            cRet := Alltrim(cValor)+"-Normal"
        elseif cValor == "D"
            cRet := Alltrim(cValor)+"-Diretor"
        elseif cValor == "T"
            cRet := Alltrim(cValor)+"-Terceiros"
        elseif cValor == "Z"
            cRet := Alltrim(cValor)+"-Aprendiz"
        else
            cret := cValor
        endif
    elseif cRegra == "ZI0_TIPREC"
        if cValor == "M"
            cRet := Alltrim(cValor)+"-Mensalista"
        else
            cRet := Alltrim(cValor)
        endif
    elseif cRegra == "ZI0_ORIGEM"
        if cValor == "I"
            cRet := Alltrim(cValor)+"-Integrado RM"
        Elseif cValor == "A"
            cRet := Alltrim(cValor)+"-Geração automática"
        else
            cRet := Alltrim(cValor)
        endif
    elseif cRegra == "REGRAS"
        if cValor == "S" .or. cValor == "E"
            cRet := Alltrim(cValor)+"-Elegível"
        elseif cValor == "A"
            cRet := Alltrim(cValor)+"-Não elegível"
        elseif cValor == "Z"
            cRet := Alltrim(cValor)+"-Não considera"
        else
            cRet := Alltrim(cValor)
        endif
    elseif cRegra == "APROVACAO"
        if cValor == "1"
            cRet := Alltrim(cValor)+"-Exige Validação"
        else
            cRet := Alltrim(cValor)+"-Não Exige Validação"
        endif
    endif

return cRet


Static function fQryExc()
    Local cQuery    := ""
    Local lRet      := .F.
    Local cEOL      := Chr(13)+chr(10)

    cQuery := " SELECT	ZI0.ZI0_FILIAL, " +cEOL
	cQuery += " 	ZI0.ZI0_STATUS, " +cEOL
	cQuery += " 	ZI0.ZI0_PERIOD, " +cEOL
	cQuery += " 	ZI0.ZI0_PERINI, " +cEOL
	cQuery += " 	ZI0.ZI0_PERFIM, " +cEOL
	cQuery += " 	ZI0.ZI0_MAT, " +cEOL
	cQuery += " 	ZI0.ZI0_CREDEN, " +cEOL
	cQuery += " 	ZI0.ZI0_CODPES, " +cEOL
	cQuery += " 	ZI1.ZI1_NOME, " +cEOL
	cQuery += " 	ZI0.ZI0_CODSIT, " +cEOL
	cQuery += " 	ZI3.ZI3_DESCRI CODSITDESC, " +cEOL
	cQuery += " 	ZI0.ZI0_PRODUT, " +cEOL
	cQuery += " 	ZI0.ZI0_CC, " +cEOL
	cQuery += " 	ZI0.ZI0_FUNCAO, " +cEOL
	cQuery += " 	ZI4.ZI4_DESCRI FUNCDESC, " +cEOL
	cQuery += " 	ZI0.ZI0_SECAO, " +cEOL
	cQuery += " 	ZI5.ZI5_DESCRI SECDESC, " +cEOL
	cQuery += " 	ZI0.ZI0_CODTIP, " +cEOL
	cQuery += " 	ZI0.ZI0_TIPREC, " +cEOL
	cQuery += " 	ZI0.ZI0_CODHOR, " +cEOL
	cQuery += " 	ZI6.ZI6_DESCRI HORADESCR, " +cEOL
	cQuery += " 	ZI0.ZI0_DTNASC, " +cEOL
	cQuery += " 	ZI0.ZI0_ORIGEM, " +cEOL
	cQuery += " 	CAST(CAST(ZI0.ZI0_MOTIVO AS varbinary(4000)) AS VARCHAR(4000)) ZI0_MOTIVO, " +cEOL
	cQuery += " 	ZI0.ZI0_FALTAS, " +cEOL
	cQuery += " 	ZI0.ZI0_FALVLD, " +cEOL
	cQuery += " 	ZI0.ZI0_ATRQTD, " +cEOL
	cQuery += " 	ZI0.ZI0_ATRVLD, " +cEOL
	cQuery += " 	ZI0.ZI0_DIAFAQ, " +cEOL
	cQuery += " 	ZI0.ZI0_DIAFAV, " +cEOL
	cQuery += " 	ZI0.ZI0_DIATRA, " +cEOL
	cQuery += " 	ZI0.ZI0_DIATVL, " +cEOL
	cQuery += " 	ZI0.ZI0_NASMES, " +cEOL
	cQuery += " 	ZI0.ZI0_NASVLD, " +cEOL
	cQuery += " 	ZI0.ZI0_MEXMES, " +cEOL
	cQuery += " 	ZI0.ZI0_MEXVLD, " +cEOL
	cQuery += " 	ZI0.ZI0_AUTORI, " +cEOL
	cQuery += " 	ZI0.ZI0_AUTAJU, " +cEOL
	cQuery += " 	CAST(CAST(ZI0.ZI0_MOTAJU AS varbinary(4000)) AS VARCHAR(4000)) ZI0_MOTAJU, " +cEOL
	cQuery += " 	ZI0.ZI0_FECHAM, " +cEOL
	cQuery += " 	ZI0.ZI0_FECUSU, " +cEOL
	cQuery += " 	ZI0.ZI0_UUID, " +cEOL
	cQuery += " 	ZI0.ZI0_IMPDAT, " +cEOL
	cQuery += " 	ZI0.ZI0_IMPUSU, " +cEOL
	cQuery += " 	ZI0.ZI0_EXPDAT, " +cEOL
	cQuery += " 	ZI0.ZI0_EXPUSU, " +cEOL
	cQuery += " 	ZI0.ZI0_EXPDEX, " +cEOL
	cQuery += " 	ZI0.ZI0_EXPUEX, " +cEOL
	cQuery += " 	ZI0.ZI0_PORDAT, " +cEOL
	cQuery += " 	ZI0.ZI0_PORUSU, " +cEOL
	cQuery += " 	ZI0.ZI0_EXCDAT, " +cEOL
	cQuery += " 	ZI0.ZI0_PORDEX, " +cEOL
	cQuery += " 	ZI0.ZI0_EXCUSU, " +cEOL
	cQuery += " 	ZI0.ZI0_PORUEX, " +cEOL
	cQuery += " 	ZI0.ZI0_EXPVLD, " +cEOL
	cQuery += " 	ZI0.ZI0_PORVLD  " +cEOL
    cQuery += " FROM "+ RetSqlName("ZI0") +" ZI0 LEFT JOIN "+ RetSqlName("ZI1") +" ZI1 ON ZI1.D_E_L_E_T_='' AND ZI0.D_E_L_E_T_='' AND ZI1.ZI1_MAT=ZI0.ZI0_MAT " +cEOL
	cQuery += " 			LEFT JOIN "+ RetSqlName("ZI3") +" ZI3 ON ZI3.D_E_L_E_T_='' AND ZI3.ZI3_CODIGO=ZI0.ZI0_CODSIT " +cEOL
	cQuery += " 			LEFT JOIN "+ RetSqlName("ZI4") +" ZI4 ON ZI4.D_E_L_E_T_='' AND ZI4.ZI4_CODIGO=ZI0.ZI0_FUNCAO " +cEOL
	cQuery += " 			LEFT JOIN "+ RetSqlName("ZI5") +" ZI5 ON ZI5.D_E_L_E_T_='' AND ZI5.ZI5_CODIGO=ZI0.ZI0_SECAO " +cEOL
	cQuery += " 			LEFT JOIN "+ RetSqlName("ZI6") +" ZI6 ON ZI6.D_E_L_E_T_='' AND ZI6.ZI6_CODIGO=ZI0.ZI0_CODHOR " +cEOL
    cQuery += " WHERE ZI0.D_E_L_E_T_='' AND ZI0.ZI0_PERIOD='"+ cPeriod +"'; "

    TcQuery cQuery ALIAS "QEXCEL" NEW

    if QEXCEL->(!eof())
        lRet := .T.
    endif

return lRet

Static Function fPerAbe()
    Local cRet      := Space(07)
    Local cQuery    := ""

    cQuery := " SELECT DISTINCT ZI0_PERIOD FROM "+ RetSqlName("ZI0") +" WHERE D_E_L_E_T_='' AND ZI0_FECHAM='';"

    Tcquery cQuery ALIAS "QFEC" NEW

    if QFEC->(!EOF())
        cRet := Alltrim(QFEC->ZI0_PERIOD)
    else
        cRet := Space(07)
    endif

    QFEC->(DbcloseArea())
return cRet

Static Function fFecham()
    Local cQuery    := ""

    DbSelectArea("ZI0")
    ZI0->(DbSetorder(4))
    ZI0->(Dbgotop())

    if ZI0->(Dbseek(cPeriod))

        While Alltrim(ZI0->ZI0_PERIOD) == Alltrim(cPeriod)

            if RecLock("ZI0", .F.)
                ZI0_STATUS := "4"
                ZI0_FECUSU	:= __cUserID
                ZI0_FECHAM	:= Date()

                ZI0->(MsUnlock())
            endif
        
            ZI0->(Dbskip())
        enddo
        
        cQuery  := " SELECT R_E_C_N_O_ REGISTRO "
        cQuery  += " FROM "+ RetSqlName("ZI1") +" "
        cQuery  += " WHERE D_E_L_E_T_='' AND ZI1_MONATV='1'; "

        TcQuery cQuery ALIAS "QMON" NEW
        DbSelectArea("ZI1")
        
        While QMON->(!EOF())
            ZI1->(Dbgoto(QMON->REGISTRO))

            IF ZI1->(RECNO()) == QMON->REGISTRO
                RecLock("ZI1", .F.)
                    ZI1_MONATV := "2"
                MsUnlock()
            ENDIF
            QMON->(Dbskip())
        enddo

        QMON->(DbcloseArea())

        msginfo("Período finalizado com sucesso!")
    else
        msginfo("Não foram encontrados registros para o período informado!")
    endif
    
return

User Function GPE066PB(cAcao)
    Local aArea     := GetArea()
    Local cMark     := oBrowse:Mark()
    Local cMens     := ""
    Local cTexto    := ""
    
    
    if cAcao == "EXCLUI"
        cTexto  := "exclusão"
    elseif cAcao == "CANC_ENTREGA"
        cTexto  := " estorno de liberação dos Kits"
    ENDIF

    if MsgYesNo("Confirma a ação selecionada de "+cTexto+"?", "Exclusão")
        
        ZI0->(Dbgotop())
        //ZI0->(DbSetOrder(4))

        While ZI0->(!Eof())

            if oBrowse:Ismark(cMark) .AND. (Alltrim(ZI0->ZI0_PERIOD)==cPerBrw .OR. Empty(Alltrim(cPerBrw)) )
                if !Empty(ZI0->ZI0_FECHAM)
                    cMens += IIF(Empty(cMens),"- ",Chr(13)+Chr(10)+"- ")+" Registro ("+ZI0->ZI0_PERIOD+"/"+ ZI0->ZI0_MAT+"/"+ZI0->ZI0_PRODUT+") não pode ser alterado. Período fechado. "
                else
                    if cAcao == "EXCLUI"
                        
                        if ZI0->ZI0_STATUS !='1' .or. ZI0->ZI0_STATUS == "4"
                            cMens += IIF(Empty(cMens),"- ",Chr(13)+Chr(10)+"- ")+" Registro ("+ZI0->ZI0_PERIOD+"/"+ ZI0->ZI0_MAT+"/"+ZI0->ZI0_PRODUT+") não pode ser excluído. "
                        else
                            cFilPrt := ZI0->ZI0_FILIAL
                            cMat    := ZI0->ZI0_MAT
                            cPerZI0 := ZI0->ZI0_PERIOD
                            cProdut := ZI0->ZI0_PRODUT

                            if RecLock("ZI0", .F.)
                                ZI0_EXCUSU	:= __cUserID
                                ZI0_EXCDAT	:= Dtoc(Date())+" "+Time()
                                Dbdelete()
                            ZI0->(MsUnlock())

                                fExcZI7(cFilPrt, cMat, cPerZI0, cProdut)
                            endif
                        endif
                    
                    else
                        
                        if ZI0->ZI0_STATUS == "4" .or. !Empty(ZI0->ZI0_FECHAM)
                            cMens += IIF(Empty(cMens),"- ",Chr(13)+Chr(10)+"- ")+" Registro ("+ZI0->ZI0_PERIOD+"/"+ ZI0-ZI0_MAT+"/"+ZI0->ZI0_PRODUT+") - Período fechado."
                        else
                            if RecLock("ZI0", .F.)
                                // Estorna a liberação da expedição.
                                if ZI0->ZI0_STATUS== "2" .OR. !Empty(ZI0->ZI0_EXPDAT)
                                    ZI0->ZI0_STATUS := "1"
                                    ZI0_EXPUSU	:= ""
                                    ZI0_EXPDAT	:= ""
                                    ZI0_EXPUEX	:= __cUserID
                                    ZI0_EXPDEX	:= Dtoc(Date())+" "+Time()
                                endif
                                // Estorna a verificação da portaria.
                                if ZI0->ZI0_STATUS== "3" .OR. !Empty(ZI0->ZI0_PORDAT)
                                    ZI0->ZI0_STATUS := "1"
                                    ZI0_PORUSU	:= ""
                                    ZI0_PORDAT	:= ""
                                    ZI0_PORUEX	:= __cUserID
                                    ZI0_PORDEX	:= Dtoc(Date())+" "+Time()
                                endif

                            ZI0->(MsUnlock())
                            endif
                        endif
                        
                    endif
                ENdif
            endif
            ZI0->(Dbskip())
        enddo
    
        if !Empty(cMens)
            MsgAlert("Não foi possível executar as ações:"+cMens, "..:: Alerta ::..")
        endif
    
        ZI0->(DBClearFilter())
    endif

    RestArea(aArea)

    oBrowse:refresh()
return

Static Function fExcZI7(cFilPrt, cMat, cPerZI0, cProdut)
    Local cQuery := ""

    cQuery  := " SELECT R_E_C_N_O_ REGISTRO "
    cQuery  += " FROM "+ RetSqlName("ZI7") +" ZI7 "
    cQuery  += " WHERE ZI7.D_E_L_E_T_='' "
    cQuery  += "  AND ZI7.ZI7_FILIAL='"+ cFilPrt +"' AND ZI7.ZI7_PERIOD='"+ cPerZI0 +"' AND ZI7.ZI7_MAT='"+ cMat +"' AND ZI7.ZI7_PRODUT='"+ cProdut +"'; "

    TcQuery cQuery ALIAS "QZI7" NEW

    While QZI7->(!EOF())
        ZI7->(Dbgoto(QZI7->REGISTRO))

        IF QZI7->REGISTRO == ZI7->(RECNO())
            If RecLock('ZI7',.F.)
                Dbdelete()    
                ZI7->(MsUnlock())
            EndIf
        endif

        QZI7->(Dbskip())
    Enddo

    QZI7->(DbcloseArea())

return

User function GPE066PA()
    Private oProcess
    Private aParam      := {}
    Private lEnd        := .T.
    Private cDtDe       := ""
    Private cDtAte      := ""
    Private dDtDe       := Stod("")
    Private dDtAte      := Stod("")
    Private nTotaKit    := 0
    Private nSubFAN     := 0
    Private nSubFME     := 0
    Private nSubFMO     := 0
    Private nSubAUT     := 0
    Private nSubZI2     := 0
    Private nCont       := 0
    Private nAcumul     := 0
    Private cPeriod     := ""
    Private cFilMat     := ""
    Private cCodSitu    := ""
    Private cCodFunc    := ""
    Private cCodSess    := ""
    Private cCodHora    := ""   
    Private cUUID       := FWUUIDV4()
    Private lInclu      := .T.

    // Retorna os parâmetros de execução da rotina e períodos do ponto do RM.
    aParam := U_ADGPE068P()

    if Len(aParam) == 0
        MsgInfo("Operação cancelada!", "Cancelada")
    Else
        cDtDe       := Dtos(aParam[03]) 
        cDtAte      := Dtos(aParam[04])
        dDtDe       := aParam[03]
        dDtAte      := aParam[04]
        cPeriod     := cValtochar(aParam[01]) +"/"+Strzero(aParam[02],2)

        if fVldPer(cPeriod)
            oProcess := MsNewProcess():New( {|lEnd| fImpDados(@lEnd, aParam)}, "Importando Dados", "Importação em andamento, Aguarde...", .F. )
            oProcess:ACTIVATE()

            oBrowse:SetFilterDefault("ZI0->ZI0_PERIOD='"+ cPeriod +"'")
        else
            MsgAlert("Não foi possível importar esse período. Verifique se o período está finalizado ou existe outro período em aberto!", "Erro")
        Endif
    endif

    ZI0->(Dbgotop())
    oBrowse:gotop()
    oBrowse:refresh()

return

Static Function fVldPer(cPeriod)
    Local lRet      := .T.
    Local cQuery    := ""

    cQuery := " SELECT COUNT(*) CONTADOR "
    cQuery += " FROM "+ Retsqlname("ZI0") +" "
    cQuery += " WHERE D_E_L_E_T_='' AND ZI0_PERIOD!='' AND ((ZI0_PERIOD='"+ cPeriod +"' AND ZI0_FECHAM !='') OR (ZI0_PERIOD!='"+ cPeriod +"' AND ZI0_FECHAM ='')) "

    Tcquery cQuery ALIAS "QAB" NEW

    if QAB->(!Eof())
        if QAB->CONTADOR > 0
            lRet := .F.
        endif
    endif

    QAB->(DbcloseArea())
return lRet

Static function fImpDados(lEnd, aParam)
    Local cQuery        := ""
    Local cFalVld       := ""
    
    if lInclu
        cDtDe   := Substr(cDtDe,1,4) +"-"+Substr(cDtDe,5,2) +"-"+Substr(cDtDe,7,2)  +" 00:00:00.000"
        cDtAte  := Substr(cDtAte,1,4)+"-"+Substr(cDtAte,5,2)+"-"+Substr(cDtAte,7,2) +" 23:59:59.999"

        // Consulta a relação de empresas e seus DePara com as coligadas (Empresa/filial) do RM.
        cQuery := " SELECT * "
        cQuery += " FROM "+ RetSqlName("ZI2") +" ZI2 "
        cQuery += " WHERE ZI2.D_E_L_E_T_='' AND ZI2.ZI2_MSBLQL !='1'; "

        TcQuery cQuery ALIAS "QZI2" NEW
        
        dbSelectArea("QZI2")
        QZI2->(Dbgotop())
        Count to nSubZI2

        oProcess:setRegua1(nSubZI2)

        QZI2->(Dbgotop())

        While QZI2->(!eof())
            oProcess:incRegua1(""+cValtochar(QZI2->ZI2_COLRM)+"/"+cValtochar(QZI2->ZI2_FILRM)+"-"+Alltrim(QZI2->ZI2_DESCRI) +" sendo importada...")
            nTotaKit    := 0
            nSubFAN     := 0
            nSubFME     := 0
            nSubAUT     := 0
            nSubFMO     := 0
            nCount      := 0 
            nAcumul     := 0
            
            
            MsAguarde({|| fgetRM() },"Consultando",""+cValtochar(QZI2->ZI2_COLRM)+"/"+cValtochar(QZI2->ZI2_FILRM)+"-"+Alltrim(QZI2->ZI2_DESCRI)+" consultando, aguarde...")
            
            nTotaKit := nSubFAN+nSubFME+nSubFMO+nSubAUT

            oProcess:setRegua2(nTotaKit)

            // Kit Aniversário - Inicia o processamento e gravação.
            QKAN->(Dbgotop())
            
            nCont := 0

            IF QZI2->ZI2_KANVLD == "1"
                while QKAN->(!eof())
                    nCont   += 1
                    nAcumul += 1

                    // Valida se o kit já foi entregue ou o período fechado.
                    if fVldReg(QZI2->ZI2_FILIAL, QZI2->ZI2_KANPRD, cPeriod, QKAN->CHAPA)
                        
                        // ZI1 - Cadastra ou atualiza os funcionários.
                        IF cFilMat != cValtochar(QKAN->CODCOLIGADA)+cvaltochar(QKAN->CODFILIAL)+Alltrim(QKAN->CHAPA)
                            
                            // Cadastra os elegíveis(colaboradores) na tabela ZI1.
                            fCadEleg(QZI2->ZI2_FILIAL,;
                                    QKAN->PTOCREDENCIAL,;
                                    QKAN->CHAPA,;
                                    cvaltochar(QKAN->CODPESSOA),;
                                    QKAN->NOME,;
                                    QKAN->ADMISSAO,;
                                    QKAN->DEMISSAO,;
                                    QKAN->CODSITUACAO,;
                                    QKAN->CCUSTO,;
                                    QKAN->CODSECAO,;
                                    QKAN->CODFUNCAO,;
                                    QKAN->CODTIPO,;
                                    QKAN->TIPORECEB,;
                                    QKAN->CODHORARIO,;
                                    QKAN->DTNASCIMENTO)
                        endif

                        // ZI3 - Cadastro da função.
                        if cCodSitu != Alltrim(QKAN->CODFUNCAO)
                            fCadSit(QKAN->CODSITUACAO, QKAN->SITUACAO)
                        endif
                        
                        // ZI4 - Cadastro da função.
                        if cCodFunc != Alltrim(QKAN->CODFUNCAO)
                            fCadFun(QKAN->CODFUNCAO, QKAN->FUNCAO)
                        endif
                        
                        // ZI5 - Cadastro da seção.
                        if cCodSess != Alltrim(QKAN->CODSECAO)
                            fCadSec(QKAN->CODSECAO, QKAN->SECAO)
                        endif
                        
                        // ZI6 - Cadastro do horário.
                        if cCodHora != Alltrim(QKAN->CODHORARIO)
                            fCadHor(QKAN->CODHORARIO, QKAN->HORARIO)
                        endif
                        
                        cCodSitu    := Alltrim(QKAN->CODFUNCAO)
                        cCodFunc    := Alltrim(QKAN->CODFUNCAO)
                        cCodSess    := Alltrim(QKAN->CODSECAO)
                        cFilMat     := cValtochar(QKAN->CODCOLIGADA)+cvaltochar(QKAN->CODFILIAL)+Alltrim(QKAN->CHAPA)
                        
                        //Grava o registro principal de entrega na tabela ZI0.
                        fGrvKAN()
                    endif
                    
                    oProcess:incRegua2("Kit Aniver (1/4)-S: "+ CValToChar(nCont) +" de "+ CValToChar(nSubFAN) +" - T: "+ CValToChar(nAcumul) +" de "+ CValToChar(nTotaKit) +" ")
                    QKAN->(Dbskip())
                enddo
            
            Endif    
            
            QKAN->(DbcloseArea())
            
            // Kit Monitor - Inicia o processamento e gravação.
            
            IF QZI2->ZI2_KMOVLD == "1"
                QKMO->(Dbgotop())
                
                nCont := 0
                
                while QKMO->(!eof())
                    nCont   += 1
                    nAcumul += 1
                    
                    // Valida se o kit já foi entregue ou o período fechado.
                    if fVldReg(QZI2->ZI2_FILIAL, QZI2->ZI2_KMOPRD, cPeriod, QKMO->CHAPA)

                        // ZI1 - Cadastra ou atualiza os funcionários no cadastro ZI1.
                        IF cFilMat != cValtochar(QKMO->CODCOLIGADA)+cvaltochar(QKMO->CODFILIAL)+Alltrim(QKMO->CHAPA)
                            
                            // Cadastra os elegíveis(colaboradores) na tabela ZI1.
                            fCadEleg(QZI2->ZI2_FILIAL,;
                                    QKMO->PTOCREDENCIAL,;
                                    QKMO->CHAPA,;
                                    cvaltochar(QKMO->CODPESSOA),;
                                    QKMO->NOME,;
                                    QKMO->ADMISSAO,;
                                    QKMO->DEMISSAO,;
                                    QKMO->CODSITUACAO,;
                                    QKMO->CCUSTO,;
                                    QKMO->CODSECAO,;
                                    QKMO->CODFUNCAO,;
                                    QKMO->CODTIPO,;
                                    QKMO->TIPORECEB,;
                                    QKMO->CODHORARIO,;
                                    Stod(""))
                        endif

                        // ZI3 - Cadastro da função.
                        if cCodSitu != Alltrim(QKMO->CODFUNCAO)
                            fCadSit(QKMO->CODSITUACAO, QKMO->SITUACAO)
                        endif
                        
                        // ZI4 - Cadastro da função.
                        if cCodFunc != Alltrim(QKMO->CODFUNCAO)
                            fCadFun(QKMO->CODFUNCAO, QKMO->FUNCAO)
                        endif
                        
                        // ZI5 - Cadastro da seção.
                        if cCodSess != Alltrim(QKMO->CODSECAO)
                            fCadSec(QKMO->CODSECAO, QKMO->SECAO)
                        endif
                        
                        // ZI6 - Cadastro do horário.
                        if cCodHora != Alltrim(QKMO->CODHORARIO)
                            fCadHor(QKMO->CODHORARIO, QKMO->HORARIO)
                        endif

                        cCodSitu    := Alltrim(QKMO->CODFUNCAO)
                        cCodFunc    := Alltrim(QKMO->CODFUNCAO)
                        cCodSess    := Alltrim(QKMO->CODSECAO)
                        cFilMat     := cValtochar(QKMO->CODCOLIGADA)+cvaltochar(QKMO->CODFILIAL)+Alltrim(QKMO->CHAPA)
                        
                        //Grava o registro principal de entrega na tabela ZI0.
                        fGrvKMO()
                    else
                    
                    endif

                    oProcess:incRegua2("Kit Monitor (2/4)-S: "+ CValToChar(nCont) +" de "+ CValToChar(nSubFMO) +" - T: "+ CValToChar(nAcumul) +" de "+ CValToChar(nTotaKit) +" ")
                    QKMO->(Dbskip())
                enddo
                
            ENDIF

            QKMO->(DbcloseArea())
            
            
            // Kit Mensal - Inicia o processamento e gravação.
            IF QZI2->ZI2_KMEVLD == "1"
                QKME->(Dbgotop())

                nCont := 0

                while QKME->(!eof())
                    nCont   += 1
                    nAcumul += 1

                    // Valida se o kit já foi entregue ou o período fechado.
                    if fVldReg(QZI2->ZI2_FILIAL, QZI2->ZI2_KMEPRD , cPeriod, QKME->CHAPA)

                        // ZI1 - Cadastra ou atualiza os funcionários no cadastro ZI1.
                        IF cFilMat != cValtochar(QKME->CODCOLIGADA)+cvaltochar(QKME->CODFILIAL)+Alltrim(QKME->CHAPA)
                            
                            // Cadastra os elegíveis(colaboradores) na tabela ZI1.
                            fCadEleg(QZI2->ZI2_FILIAL,;
                                    QKME->PTOCREDENCIAL,;
                                    QKME->CHAPA,;
                                    cvaltochar(QKME->CODPESSOA),;
                                    QKME->NOME,;
                                    QKME->ADMISSAO,;
                                    QKME->DEMISSAO,;
                                    QKME->CODSITUACAO,;
                                    QKME->CCUSTO,;
                                    QKME->CODSECAO,;
                                    QKME->CODFUNCAO,;
                                    QKME->CODTIPO,;
                                    QKME->TIPORECEB,;
                                    QKME->CODHORARIO,;
                                    Stod(""))
                        endif

                        // ZI3 - Cadastro da função.
                        if cCodSitu != Alltrim(QKME->CODFUNCAO)
                            fCadSit(QKME->CODSITUACAO, QKME->SITUACAO)
                        endif
                        
                        // ZI4 - Cadastro da função.
                        if cCodFunc != Alltrim(QKME->CODFUNCAO)
                            fCadFun(QKME->CODFUNCAO, QKME->FUNCAO)
                        endif
                        
                        // ZI5 - Cadastro da seção.
                        if cCodSess != Alltrim(QKME->CODSECAO)
                            fCadSec(QKME->CODSECAO, QKME->SECAO)
                        endif
                        
                        // ZI6 - Cadastro do horário.
                        if cCodHora != Alltrim(QKME->CODHORARIO)
                            fCadHor(QKME->CODHORARIO, QKME->HORARIO)
                        endif
                        
                        //Grava os registros de faltas vinculados ao período.
                        //IF cFilMat != cValtochar(QKME->CODCOLIGADA)+cvaltochar(QKME->CODFILIAL)+Alltrim(QKME->CHAPA)
                            cFalVld := "Z"
                            cFalVld := fGrvFal(QZI2->ZI2_FILIAL, QZI2->ZI2_COLRM, Alltrim(QZI2->ZI2_KMEPRD), cPeriod, QKME->CHAPA, cDtDe, cDtAte )
                        //ENDIF

                        //Grava o registro principal de entrega na tabela ZI0.
                        fGrvKME(cFalVld)

                        
                        cCodSitu    := Alltrim(QKME->CODFUNCAO)
                        cCodFunc    := Alltrim(QKME->CODFUNCAO)
                        cCodSess    := Alltrim(QKME->CODSECAO)
                        cFilMat     := cValtochar(QKME->CODCOLIGADA)+cvaltochar(QKME->CODFILIAL)+Alltrim(QKME->CHAPA)
                        
                        

                    endif

                    oProcess:incRegua2("Kit Mensal (3/4)-S: "+ CValToChar(nCont) +" de "+ CValToChar(nSubFME) +" - T: "+ CValToChar(nAcumul) +" de "+ CValToChar(nTotaKit) +" ")
                    QKME->(Dbskip())
                enddo

            ENDIF    
            
            QKME->(DbcloseArea())
            
            QAUT->(Dbgotop())

            nCont := 0

            while QAUT->(!eof())
                nCont   += 1
                nAcumul += 1
                
                fGrvAUT()
                
                oProcess:incRegua2("Kit Aut(4/4)-S: "+ CValToChar(nCont) +" de "+ CValToChar(nSubAUT) +" - T: "+ CValToChar(nAcumul) +" de "+ CValToChar(nTotaKit) +" ")
                QAUT->(Dbskip())
            enddo
            QAUT->(DbcloseArea())

            QZI2->(Dbskip())
        enddo

        lEnd    := .T.
        lInclu  := .F.

        QZI2->(Dbclosearea())
    endif
return

Static Function fGrvFal(cFilPrt, nColigada, cProd, cPeriod, cChapa, cDtDe, cDtAte)
    Local cDia      := ""
    Local cQuery    := ""
    Local cRet      := "S"
    Local cRetTmp   := ""
    
    DbSelectArea("ZI7")
    ZI7->(DbSetOrder(1))
    
    //Processa os registros de declaração médica.
    cQuery := "EXEC [dbo].[SP_RM_DECLARACAO_MEDICA] "+ cValtochar(nColigada) +", '"+ Alltrim(cChapa) +"', '"+ cDtDe +"', '"+ cDtAte +"'; "
            
    TcQuery cQuery ALIAS "QZI7" NEW
    dbSelectArea("QZI7")
    
    QZI7->(Dbgotop())
    
    while QZI7->(!EOF())
        cDia    := replace(left(Dtos(QZI7->DATAREFERENCIA),10),"-","")
        cRetTmp := fGrvZI7(1, cFilPrt, cProd, cPeriod, cChapa, cDia)
        cRet    := iif(cRet=="N",cRet,cRetTmp)
        
        QZI7->(Dbskip())
    enddo

    QZI7->(DbcloseArea())

    //Processa os registros de declaração médica.
    cQuery := "EXEC [dbo].[SP_RM_FALTAS_INJUSTIFICADAS] "+ cValtochar(nColigada) +", '"+ Alltrim(cChapa) +"', '"+ cDtDe +"', '"+ cDtAte +"'; "
            
    TcQuery cQuery ALIAS "QZI7" NEW
    dbSelectArea("QZI7")
    
    QZI7->(Dbgotop())
    
    while QZI7->(!EOF())
        cDia    := replace(left(Dtos(QZI7->DATAREFERENCIA),10),"-","")
        cRetTmp := fGrvZI7(2, cFilPrt, cProd, cPeriod, cChapa, cDia)
        cRet    := iif(cRet=="N",cRet,cRetTmp)

        QZI7->(Dbskip())
    enddo

    QZI7->(DbcloseArea())

    //Processa os registros de declaração médica.
    cQuery := "EXEC [dbo].[SP_RM_FALTAS_JUSTIFICADAS] "+ cValtochar(nColigada) +", '"+ Alltrim(cChapa) +"', '"+ cDtDe +"', '"+ cDtAte +"'; "
            
    TcQuery cQuery ALIAS "QZI7" NEW
    dbSelectArea("QZI7")
    
    QZI7->(Dbgotop())
    
    while QZI7->(!EOF())
        cDia    := replace(left(Dtos(QZI7->DATAREFERENCIA),10),"-","")
        cRetTmp := fGrvZI7(3, cFilPrt, cProd, cPeriod, cChapa, cDia)
        cRet    := iif(cRet=="N",cRet,cRetTmp)

        QZI7->(Dbskip())
    enddo

    QZI7->(DbcloseArea())

return cRet

Static Function fGrvZI7(nTipo, cFilPrt, cProd, cPeriod, cChapa, cDia)
    Local cRet := "S"

    if fGetZI7(cFilPrt, cPeriod, cChapa, cProd, cDia )
        
        If RecLock('ZI7',.F.)

            if nTipo == 1
                ZI7_DECMED  := QZI7->HORAS
            elseif nTipo == 2
                ZI7_FALINJ  := QZI7->HORAS
            elseif nTipo == 3
                ZI7_FALJUS  := QZI7->HORAS
            endif

            ZI7_VLDFAL  := fGrvVld()
            ZI7_OBSERV  := fGrvObs()
            cRet := ZI7->ZI7_VLDFAL

            ZI7->(MsUnlock())
        EndIf
    else
        
        If RecLock('ZI7',.T.)
            ZI7_FILIAL  := cFilPrt
            ZI7_MAT     := cChapa
            ZI7_PERIOD  := cPeriod
            ZI7_PRODUT  := cProd
            ZI7_DATA    := sTod(cDia)
 
            if nTipo == 1
                ZI7_DECMED  := QZI7->HORAS
            Elseif nTipo == 2
                ZI7_FALINJ  := QZI7->HORAS
            Elseif nTipo == 3
                ZI7_FALJUS  := QZI7->HORAS
            endif

            ZI7_VLDFAL  := fGrvVld()
            ZI7_OBSERV  := fGrvObs()

            cRet := ZI7->ZI7_VLDFAL

            ZI7->(MsUnlock())
        EndIf
    endif

return cRet

Static function fGetZI7(cFilPrt, cPeriod, cChapa, cProd, cDia )
    Local lRet      := .F.
    Local cQuery    := ""

    cQuery  := "SELECT ZI7.R_E_C_N_O_ REGISTRO "
    cQuery  += "FROM "+RetSqlName("ZI7")+" ZI7 "
    cQuery  += "WHERE ZI7.D_E_L_E_T_='' AND ZI7.ZI7_FILIAL='"+ cFilPrt +"' AND ZI7.ZI7_PERIOD='"+ cPeriod +"' AND ZI7.ZI7_MAT='"+ cChapa +"' AND ZI7.ZI7_DATA='"+ cDia +"'; "
            
    TcQuery cQuery ALIAS "QREG" NEW
    dbSelectArea("QREG")
    
    QREG->(Dbgotop())
    
    if QREG->(!EOF())
        ZI7->(Dbgoto(QREG->REGISTRO))

        IF QREG->REGISTRO == ZI7->(RECNO())
            lRet := .T.
        else
            lRet := .F.
        endif

    else
        lRet := .F.
    endif

    QREG->(DbcloseArea())
return lRet

Static Function fGrvObs()
    Local cRet := ""

    IF ZI7->ZI7_DECMED > 2
        cRet += "Declaração médica acima de 2 horas. "
    ELSEIF ABS(ZI7->ZI7_FALINJ-ZI7->ZI7_FALJUS) > 0
        cRet += "Faltas injustificadas. "
    ELSEIF ABS(ZI7->ZI7_FALINJ-ZI7->ZI7_FALJUS) > 0 .and. ZI7->ZI7_FALJUS > 0
        cRet += "Faltas justificadas. "
    ENDIF
    
return cRet

Static Function fGrvVld()
    Local cRet := ""

    IF ZI7->ZI7_VLDFAL != "N"
        IF ZI7->ZI7_DECMED > 2
            cRet := "N"
        ELSEIF ABS(ZI7->ZI7_FALINJ-ZI7->ZI7_FALJUS) > 0 .AND. (ZI7->ZI7_FALINJ > 0 .OR. ZI7->ZI7_FALJUS > 0)
            cRet := "N"
        ELSE
            cRet := "S"
        ENDIF
    ENDIF

return cRet

// Valida se o kit já foi entregue ou o período fechado.
Static function fVldReg(cFilKit, cKitPrd, cPeriod, cChapa)
    Local lRet      := .T.
    Local cQuery    := ""

    cQuery  := " SELECT count(*) CONTADOR "
    cQuery  += " FROM "+ RetSqlName("ZI0") +" ZI0 "
    cQuery  += " WHERE D_E_L_E_T_='' AND ZI0_FILIAL='"+ cFilKit +"' AND ZI0_PRODUT='"+ cKitPrd +"' AND ZI0_PERIOD='"+ cPeriod +"' AND ZI0_MAT='"+ cChapa +"' "
    cQuery  += " AND (ZI0_FECHAM !='' OR ZI0_STATUS !='1'); "

    TcQuery cQuery ALIAS "QVLDALT" NEW

    IF QVLDALT->(!EOF())
        if QVLDALT->CONTADOR > 0
            lRet := .F.
        endif
    endif

    QVLDALT->(DbcloseArea())

return lRet


Static Function fgetRM()

    if lInclu
        // Executa a procedure de consulta ao RM para retornar os Kits aniversário. Quantifica os registros.
        fExcDados(QZI2->ZI2_FILIAL, QZI2->ZI2_KANPRD , cPeriod, dDtDe, dDtAte)
        cQuery := "EXEC SP_RM_KIT_FRANGO_ANIVERSARIO "+ QZI2->ZI2_COLRM +", "+ QZI2->ZI2_FILRM +", "+ QZI2->ZI2_FILRM +", '"+cDtDe+"','"+ cDtAte +"' "
            
        TcQuery cQuery ALIAS "QKAN" NEW
        dbSelectArea("QKAN")
        QKAN->(Dbgotop())
        Count to nSubFAN

        // Executa a procedure de consulta ao RM para retornar os Kits monitor de frango. Quantifica os registros.
        fExcDados(QZI2->ZI2_FILIAL, QZI2->ZI2_KMOPRD , cPeriod, dDtDe, dDtAte)
        cQuery := "EXEC SP_RM_KIT_FRANGO_MONITOR "+ QZI2->ZI2_COLRM +", "+ QZI2->ZI2_FILRM +", "+ QZI2->ZI2_FILRM +", '"+cDtDe+"','"+ cDtAte +"' "
            
        TcQuery cQuery ALIAS "QKMO" NEW
        dbSelectArea("QKMO")
        QKMO->(Dbgotop())
        Count to nSubFMO
        
        // Executa a procedure de consulta ao RM para retornar os Kits mensais de frango. Quantifica os registros.
        fExcDados(QZI2->ZI2_FILIAL, QZI2->ZI2_KMEPRD , cPeriod, dDtDe, dDtAte)
        cQuery := "EXEC SP_RM_KIT_FRANGO_MENSAL "+ QZI2->ZI2_COLRM +", "+ QZI2->ZI2_FILRM +", "+ QZI2->ZI2_FILRM +", '"+cDtDe+"','"+ cDtAte +"' "
        
        TcQuery cQuery ALIAS "QKME" NEW
        dbSelectArea("QKME")
        QKME->(Dbgotop())
        Count to nSubFME

        cQuery := " SELECT * "
        cQuery += " FROM "+ RetSqlName("ZI1") +" ZI1 "
        cQuery += " WHERE D_E_L_E_T_='' AND ZI1_FILIAL='"+ QZI2->ZI2_FILIAL +"' AND ZI1_MSBLQL !='1' AND ZI1_TIPINC='M' AND (ZI1_KITANI='1' OR ZI1_KITMEN='1' OR ZI1_KITMON='1'); "

        Tcquery cQuery ALIAS "QAUT" NEW 
        
        dbSelectArea("QAUT")
        QAUT->(Dbgotop())
        Count to nSubAUT
    ENDIF

return

Static function fExcDados(cFilKit, cKitPrd , cPeriod, dDtDe, dDtAte)
    Local cQuery := ""
    
    DbSelectarea("ZI0")
    DbSelectarea("ZI7")

    cQuery  := " SELECT ZI7.R_E_C_N_O_ REGISTRO "
    cQuery  += " FROM "+ RetSqlName("ZI0") +" ZI0 INNER JOIN "+ RetSqlName("ZI7") +" ZI7 ON ZI0.ZI0_FILIAL=ZI7.ZI7_FILIAL AND ZI0.ZI0_PERIOD=ZI7.ZI7_PERIOD AND ZI0.ZI0_MAT=ZI7.ZI7_MAT AND ZI0.ZI0_PRODUT=ZI7.ZI7_PRODUT "
    cQuery  += " WHERE ZI0.D_E_L_E_T_='' AND ZI0_FILIAL='"+ cFilKit +"' AND ZI0_PRODUT='"+ cKitPrd +"' AND ZI0_PERIOD='"+ cPeriod +"' AND ZI0_PERINI ='"+ Dtos(dDtDe) +"' AND ZI0_PERFIM='"+ Dtos(dDtAte) +"' "
    cQuery  += " AND ZI0_FECHAM='' AND ZI0_STATUS='1'; "

    TcQuery cQuery ALIAS "QEXC" NEW

    while QEXC->(!EOF())
        ZI7->(Dbgoto(QEXC->REGISTRO))

        if ZI7->(RECNO()) == QEXC->REgistro
            Reclock("ZI7",.F.)    
            Dbdelete()
            ZI7->(MsUnlock())
        ENDIF

        QEXC->(DbSkip())
    enddo

    QEXC->(DbcloseArea())

    DbSelectarea("ZI0")

    cQuery  := " SELECT R_E_C_N_O_ REGISTRO "
    cQuery  += " FROM "+ RetSqlName("ZI0") +" ZI0 "
    cQuery  += " WHERE D_E_L_E_T_='' AND ZI0_FILIAL='"+ cFilKit +"' AND ZI0_PRODUT='"+ cKitPrd +"' AND ZI0_PERIOD='"+ cPeriod +"' AND ZI0_PERINI ='"+ Dtos(dDtDe) +"' AND ZI0_PERFIM='"+ Dtos(dDtAte) +"' "
    cQuery  += " AND ZI0_FECHAM='' AND ZI0_STATUS='1'; "

    TcQuery cQuery ALIAS "QEXC" NEW

    while QEXC->(!EOF())
        ZI0->(Dbgoto(QEXC->REGISTRO))

        if ZI0->(RECNO()) == QEXC->REgistro
            Reclock("ZI0",.F.)
            ZI0_EXCUSU	:= __cUserID
            ZI0_EXCDAT	:= Dtoc(Date())+" "+Time()
            
            Dbdelete()
            ZI0->(MsUnlock())
        ENDIF

        QEXC->(DbSkip())
    enddo

    QEXC->(DbcloseArea())

    
return

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
        MsUnlock("ZI5")
    endif
return

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

Static Function fGrvAUT()
    //Para os colaboradores inclusos manualmente os registros de kits devem ser gerados de forma independentes.
    //if QZI2->ZI2_KANVLD == "1"
        if QAUT->ZI1_KITANI == "1" .and. !Empty(QAUT->ZI1_DTNASC)
            if substring(QAUT->ZI1_DTNASC,5,2) == right(alltrim(cPeriod),2)

                // Valida se o kit já foi entregue ou o período fechado.
                if fVldReg(QZI2->ZI2_FILIAL, QZI2->ZI2_KANPRD, cPeriod, QAUT->ZI1_MAT)
                    fGeraAut(QZI2->ZI2_KANPRD, QZI2->ZI2_KANAP1, QZI2->ZI2_KANAP2)
                Endif
            endif
        ENDIF
    //endif
    //Para os colaboradores inclusos manualmente os registros de kits devem ser gerados de forma independentes.
    //if QZI2->ZI2_KMEVLD == "1"
        if QAUT->ZI1_KITMEN == "1"

            // Valida se o kit já foi entregue ou o período fechado.
            if fVldReg(QZI2->ZI2_FILIAL, QZI2->ZI2_KMEPRD, cPeriod, QAUT->ZI1_MAT)
                fGeraAut(QZI2->ZI2_KMEPRD, QZI2->ZI2_KMEAP1, QZI2->ZI2_KMEAP2)
            endif
        ENDIF
    //ENDIF
    //Para os colaboradores inclusos manualmente os registros de kits devem ser gerados de forma independentes.
    //if QZI2->ZI2_KMOVLD == "1"
        if QAUT->ZI1_KITMON == "1"

            // Valida se o kit já foi entregue ou o período fechado.
            if fVldReg(QZI2->ZI2_FILIAL, QZI2->ZI2_KMOPRD, cPeriod, QAUT->ZI1_MAT)
                fGeraAut(QZI2->ZI2_KMOPRD, QZI2->ZI2_KMOAP1, QZI2->ZI2_KMOAP2)
            endif
        ENDIF
    //ENDIF
return

Static Function fGeraAut(cProduto, cAprExp, cAprPor)

    if reclock("ZI0",.T.)

        ZI0_FILIAL  := QZI2->ZI2_FILIAL
        ZI0_OK      := ""	
        ZI0_STATUS  := "1"
        ZI0_MAT     := QAUT->ZI1_MAT          // Chapa ou matrícula.
        ZI0_CREDEN	:= QAUT->ZI1_CREDEN  // Credencial do ponto
        ZI0_CODPES	:= QAUT->ZI1_CODPES      // Código da pessoa.
        ZI0_CODSIT	:= QAUT->ZI1_CODSIT    //Situação do funcionário
        ZI0_CC      := QAUT->ZI1_CC         // Centro de Custo
        ZI0_FUNCAO	:= QAUT->ZI1_FUNCAO     // FUNCAO
        ZI0_SECAO	:= QAUT->ZI1_SECAO      // SECAO
        ZI0_CODTIP	:= QAUT->ZI1_CODTIP     // Tipo do colaborador.
        ZI0_TIPREC	:= QAUT->ZI1_TIPREC     // RECEBIMENTO
        ZI0_CODHOR  := QAUT->ZI1_CODHOR     // HORARIO
        ZI0_PERIOD  := cPeriod	            // Período
        ZI0_PRODUT  := cProduto             // Produto
        ZI0_ORIGEM  := "A"                  // Origem do registro.
        ZI0_MOTIVO  := ""
        ZI0_FALTAS	:= ""
        ZI0_FALVLD  := "Z"
        ZI0_DIAFAQ  := 0
        ZI0_DIAFAV  := "Z"
        ZI0_DIATRA  := 0
        ZI0_DIATVL  := "Z"

        ZI0_ATRQTD	:= ""
        ZI0_ATRVLD  := "Z"

        ZI0_AUTORI  := "S"
        ZI0_MOTAJU  := ""
        ZI0_AUTAJU	:= "S"

        ZI0_IMPUSU	:= __cUserID
        ZI0_IMPDAT	:= Dtoc(Date())+" "+Time()

        ZI0_EXPVLD  := cValtochar(cAprExp)
        ZI0_PORVLD  := cValtochar(cAprPor)

        //Entrega na expedição do Kit Frango.
        ZI0_EXPUSU	:= ""
        ZI0_EXPDAT	:= ""
        //Verificação na portaria do Kit Frango.
        ZI0_PORUSU	:= ""
        ZI0_PORDAT	:= ""
        //Data de fechamento do período.
        ZI0_FECHAM	:= Stod("")
        ZI0_PERINI  := dDtDe
        ZI0_PERFIM  := dDtAte
        ZI0_UUID    := cUUID
        ZI0->(MsUnlock())
    endif
return

Static Function fGrvKMO()
    
    if reclock("ZI0",.T.)

        ZI0_FILIAL  := QZI2->ZI2_FILIAL
        ZI0_OK      := ""	
        ZI0_STATUS  := "1"	
        ZI0_MAT     := QKMO->CHAPA          // Chapa ou matrícula.
        ZI0_CREDEN	:= QKMO->PTOCREDENCIAL  // Credencial do ponto
        ZI0_CODPES	:= cValtochar(QKMO->CODPESSOA)      // Código da pessoa.
        ZI0_CODSIT	:= QKMO->CODSITUACAO    //Situação do funcionário
        ZI0_CC      := QKMO->CCUSTO         // Centro de Custo
        ZI0_FUNCAO	:= QKMO->CODFUNCAO      // FUNCAO
        ZI0_SECAO	:= QKMO->CODSECAO       // SECAO
        ZI0_CODTIP	:= QKMO->CODTIPO        // Tipo do colaborador.
        ZI0_TIPREC	:= QKMO->TIPORECEB      // RECEBIMENTO
        ZI0_CODHOR  := QKMO->CODHORARIO     // HORARIO
        ZI0_PERIOD  := cPeriod	            // Período
        ZI0_PRODUT  := QZI2->ZI2_KMOPRD     // Produto
        ZI0_ORIGEM  := "I"                  // Origem do registro.
        ZI0_MOTIVO  := ""
        ZI0_FALTAS	:= ""
        ZI0_FALVLD  := "Z"
        ZI0_DIAFAQ  := QKMO->DIAS_AFAST_OT
        ZI0_DIAFAV  := fRetVld(QKMO->VALIDA_AFAST_OT)
        ZI0_DIATRA  := 0
        ZI0_DIATVL  := "Z"

        ZI0_EXPVLD  := cValtochar(QZI2->ZI2_KMOAP1)
        ZI0_PORVLD  := cValtochar(QZI2->ZI2_KMOAP2)

        ZI0_ATRQTD	:= ""
        ZI0_ATRVLD  := "Z"

        ZI0_AUTORI  := fRetVld(QKMO->VALIDACAO_FINAL)
        ZI0_MOTAJU  := ""
        ZI0_AUTAJU	:= fRetVld(QKMO->VALIDACAO_FINAL)

        ZI0_IMPUSU	:= __cUserID
        ZI0_IMPDAT	:= Dtoc(Date())+" "+Time()

        //Entrega na expedição do Kit Frango.
        ZI0_EXPUSU	:= ""
        ZI0_EXPDAT	:= ""
        //Verificação na portaria do Kit Frango.
        ZI0_PORUSU	:= ""
        ZI0_PORDAT	:= ""
        //Data de fechamento do período.
        ZI0_FECHAM	:= Stod("")
        ZI0_PERINI  := dDtDe
        ZI0_PERFIM  := dDtAte
        ZI0_UUID    := cUUID
        ZI0->(MsUnlock())
    endif
return

Static Function fGrvKAN()
    Local Lret := .F.
    
    if reclock("ZI0",.T.)

        ZI0_FILIAL  := QZI2->ZI2_FILIAL
        ZI0_OK      := ""	
        ZI0_STATUS  := "1"	
        ZI0_MAT     := QKAN->CHAPA          // Chapa ou matrícula.
        ZI0_CREDEN	:= QKAN->PTOCREDENCIAL  // Credencial do ponto
        ZI0_CODPES	:= cValtochar(QKAN->CODPESSOA)      // Código da pessoa.
        ZI0_CODSIT	:= QKAN->CODSITUACAO    //Situação do funcionário
        ZI0_CC      := QKAN->CCUSTO         // Centro de Custo
        ZI0_FUNCAO	:= QKAN->CODFUNCAO      // FUNCAO
        ZI0_SECAO	:= QKAN->CODSECAO       // SECAO
        ZI0_CODTIP	:= QKAN->CODTIPO        // Tipo do colaborador.
        ZI0_TIPREC	:= QKAN->TIPORECEB      // RECEBIMENTO
        ZI0_CODHOR  := QKAN->CODHORARIO     // HORARIO
        ZI0_PERIOD  := cPeriod	            // Período
        ZI0_PRODUT  := QZI2->ZI2_KANPRD     // Produto
        ZI0_ORIGEM  := "I"                  // Origem do registro.
        ZI0_MOTIVO  := ""
        /* Relacionados ao Kit aniversário */
        ZI0_DTNASC  := QKAN->DTNASCIMENTO   // Data de nascimento.
        ZI0_NASMES  := Strzero(QKAN->MES_ANIV,2)   // Mês de nascimento.
        ZI0_NASVLD  := fRetVld(QKAN->VALIDA_MES_ANIVERSARIO)
        ZI0_MEXMES  := Strzero(QKAN->MES_FIM_CONTR_EXP,2)
        ZI0_MEXVLD  := QKAN->VALIDACAO_EXPER
        /* Relacionados ao Kit aniversário */

        ZI0_EXPVLD  := cValtochar(QZI2->ZI2_KANAP1)
        ZI0_PORVLD  := cValtochar(QZI2->ZI2_KANAP2)

        ZI0_FALTAS	:= ""
        ZI0_FALVLD  := "Z"
        ZI0_DIAFAQ  := 0
        ZI0_DIAFAV  := "Z"
        ZI0_DIATRA  := 0
        ZI0_DIATVL  := "Z"

        ZI0_ATRQTD	:= ""
        ZI0_ATRVLD  := "Z"

        ZI0_AUTORI  := fRetVld(QKAN->VALIDACAO_FINAL)
        ZI0_MOTAJU  := ""
        ZI0_AUTAJU	:= fRetVld(QKAN->VALIDACAO_FINAL)

        ZI0_IMPUSU	:= __cUserID
        ZI0_IMPDAT	:= Dtoc(Date())+" "+Time()

        //Entrega na expedição do Kit Frango.
        ZI0_EXPUSU	:= ""
        ZI0_EXPDAT	:= ""
        //Verificação na portaria do Kit Frango.
        ZI0_PORUSU	:= ""
        ZI0_PORDAT	:= ""
        //Data de fechamento do período.
        ZI0_FECHAM	:= Stod("")
        ZI0_PERINI  := dDtDe
        ZI0_PERFIM  := dDtAte
        ZI0_UUID    := cUUID
        ZI0->(MsUnlock())
    endif
return lRet

Static Function fGrvKME(cFalVld)
    Local Lret := .F.

    if reclock("ZI0",.T.)

        ZI0_FILIAL  := QZI2->ZI2_FILIAL
        ZI0_OK      := ""	
        ZI0_STATUS  := "1"	
        ZI0_MAT     := QKME->CHAPA          // Chapa ou matrícula.
        ZI0_CREDEN	:= QKME->PTOCREDENCIAL  // Credencial do ponto
        ZI0_CODPES	:= cValtochar(QKME->CODPESSOA)      // Código da pessoa.
        ZI0_CODSIT	:= QKME->CODSITUACAO    //Situação do funcionário
        ZI0_CC      := QKME->CCUSTO         // Centro de Custo
        ZI0_FUNCAO	:= QKME->CODFUNCAO      // FUNCAO
        ZI0_SECAO	:= QKME->CODSECAO       // SECAO
        ZI0_CODTIP	:= QKME->CODTIPO        // Tipo do colaborador.
        ZI0_TIPREC	:= QKME->TIPORECEB      // RECEBIMENTO
        ZI0_CODHOR  := QKME->CODHORARIO     // HORARIO
        ZI0_PERIOD  := cPeriod	            // Período
        ZI0_PRODUT  := QZI2->ZI2_KMEPRD     // Produto
        ZI0_ORIGEM  := "I"                  // Origem do registro.
        ZI0_MOTIVO  := ""
        // Reformulação das regras de faltas.
        //ZI0_FALTAS	:= QKME->FALTAS
        //ZI0_FALVLD  := fRetVld(QKME->VALIDA_FALTAS)
        ZI0_DIAFAQ  := QKME->DIAS_AFAST_OT
        ZI0_DIAFAV  := fRetVld(QKME->VALIDA_AFAST_OT)
        ZI0_DIATRA  := QKME->DIAS_TRAB_MES
        ZI0_DIATVL  := fRetVld(QKME->VALIDA_DIAS_TRAB_MES)

        ZI0_EXPVLD  := cValtochar(QZI2->ZI2_KMEAP1)
        ZI0_PORVLD  := cValtochar(QZI2->ZI2_KMEAP2)
        // Reformulação das regras de faltas.
        //ZI0_ATRQTD	:= QKME->ATRASOS
        //ZI0_ATRVLD  := fRetVld(QKME->VALIDA_ATRASOS)
        
        ZI0_FALVLD  := cFalVld
        
        // Revisar a regra.
        // Reformulação das regras de faltas.
        IF ZI0_DIAFAV == "N" .OR. ZI0_DIATVL =="N" .OR. ZI0_FALVLD == "N"
            cAutori := "N"
        Else
            cAutori := "S"
        ENDIF

        ZI0_AUTORI  := cAutori 
        //ZI0_AUTORI  := fRetVld(QKME->VALIDACAO_FINAL)
        ZI0_MOTAJU  := ""
        //ZI0_AUTAJU	:= fRetVld(QKME->VALIDACAO_FINAL)
        ZI0_AUTAJU  := cAutori

        ZI0_IMPUSU	:= __cUserID
        ZI0_IMPDAT	:= Dtoc(Date())+" "+Time()

        //Entrega na expedição do Kit Frango.
        ZI0_EXPUSU	:= ""
        ZI0_EXPDAT	:= ""
        //Verificação na portaria do Kit Frango.
        ZI0_PORUSU	:= ""
        ZI0_PORDAT	:= ""
        //Data de fechamento do período.
        ZI0_FECHAM	:= Stod("")
        ZI0_PERINI  := dDtDe
        ZI0_PERFIM  := dDtAte
        ZI0_UUID    := cUUID
        ZI0->(MsUnlock())
    endif

return lRet

Static Function fRetVld(cLabel)
    Local cRet := ""
    cLabel := Alltrim(cLabel)

    if cLabel == "Elegível"
        cRet := "S"
    else
        cRet := "N"
    endif
return cRet

// Cadastra os elegíveis(colaboradores) na tabela ZI1.
Static function fCadEleg(cFilPro,;
             cCredencial,;
             cChapa,;
             cCodPessoa,;
             cNome,;
             dAdmissao,;
             dDemissao,;
             cCodSit,;
             cCC,;
             cCodSecao,;
             cCodFunc,;
             cCodTipo,;
             cCodTpRec,;
             cCodHorar,;
             dDtNasc)

    Local lIncAlt   := .F.
    Local cQuery    := ""

    DbSelectarea("ZI1")

    cQuery := " SELECT ZI1.R_E_C_N_O_ REGZI1, isnull(ZI1A.R_E_C_N_O_,0) REGZI1A "
    cQuery += " FROM "+ Retsqlname("ZI1") +" (nolock) ZI1 LEFT JOIN "+ Retsqlname("ZI1") +" (nolock) ZI1A ON ZI1.D_E_L_E_T_='' AND ZI1A.D_E_L_E_T_='' AND ZI1.R_E_C_N_O_=ZI1A.R_E_C_N_O_ "
    cQuery += "  AND ZI1A.ZI1_CODPES != '"+ Alltrim(cCodPessoa) +"' "
    cQuery += "  AND ZI1A.ZI1_CREDEN != '"+ Alltrim(cCredencial) +"' "
    cQuery += "  AND ZI1A.ZI1_NOME   != '"+ Alltrim(cNome) +"' "
    cQuery += "  AND ZI1A.ZI1_CC     != '"+ Alltrim(cCC) +"' "
    cQuery += "  AND ZI1A.ZI1_SECAO  != '"+ Alltrim(cCodSecao) +"' "
    cQuery += "  AND ZI1A.ZI1_FUNCAO != '"+ Alltrim(cCodFunc) +"' "
    cQuery += "  AND ZI1A.ZI1_CODTIP != '"+ Alltrim(cCodTipo) +"' "
    cQuery += "  AND ZI1A.ZI1_CODSIT != '"+ Alltrim(cCodSit) +"' "
    cQuery += "  AND ZI1A.ZI1_TIPREC != '"+ Alltrim(cCodTpRec) +"' "
    cQuery += "  AND ZI1A.ZI1_CODHOR != '"+ Alltrim(cCodHorar) +"' "
    cQuery += "  AND ZI1A.ZI1_ADMISS != '"+ Dtos(dAdmissao) +"' "
    cQuery += "  AND ZI1A.ZI1_DEMISS != '"+ Dtos(dDemissao) +"' "
    
    if !Empty(dDtNasc)
        cQuery += "  AND ZI1A.ZI1_DTNASC != '"+ Dtos(dDtNasc) +"' "
    endif

    cQuery += " WHERE ZI1.D_E_L_E_T_='' AND ZI1.ZI1_FILIAL='"+ cFilPro +"' AND ZI1.ZI1_MAT='"+ cChapa +"' "

    Tcquery cQuery ALIAS "QZI1" NEW

    If QZI1->(!eof())
        if QZI1->REGZI1A != 0
            ZI1->(Dbgoto(QZI1->REGZI1))
            if ZI1->(Recno()) == QZI1->REGZI1
                if Reclock("ZI1",.F.)
                    Dbdelete()
                    ZI1->(MsUnlock())
                    lIncAlt := .T.
                endif

            endif
            
        endif
        
    else
        lIncAlt := .T.
    endif

    if lIncAlt
        if Reclock("ZI1",.T.)
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
            ZI1_KITMON  := "2"
            ZI1_MONATV  := "2"
            ZI1_KITANI  := "2"
            ZI1_KITMEN  := "2"

            if !Empty(dDtNasc)
                ZI1_DTNASC := dDtNasc
            endif

            ZI1_TIPINC  := "I"
            ZI1_MSBLQL  := "2" 
            ZI1->(MsUnlock())
        endif
    endif

    if select("QZI1") > 0
        QZI1->(DbcloseArea())
    endif
return

// --------------------------------------------------------------------------------------------------------
// InÃ­cio da ViewDef e ModelDef.
// --------------------------------------------------------------------------------------------------------
Static Function ModelDef()
 Local oModel		:= MPFormModel():New("mdlADGPE066P", ,{|| fVldForm()},)
 //Local oModel       := FWLoadModel('ADGPE066P')
 Local oStrutZI0	:= FWFormStruct(1,"ZI0")
 Local oStrutZI7	:= FWFormStruct(1,"ZI7")
 
 oModel:SetDescription(cTitulo)
 
 oModel:addFields("CABEC_ZI0",nil,oStrutZI0)
 oModel:addGrid("DETAI_ZI7","CABEC_ZI0",oStrutZI7)

 oModel:GetModel("DETAI_ZI7"):setNoInsertLine(.T.)
 oModel:GetModel("DETAI_ZI7"):setNoDeleteLine(.T.)

 oModel:SetRelation( 'DETAI_ZI7',;
                        {{ 'ZI7_FILIAL'	, 'FwXFilial("ZI7")'},;   
                         { 'ZI7_PERIOD'	, 'ZI0_PERIOD'      },;
						 { 'ZI7_MAT'    , 'ZI0_MAT'         },;
                         { 'ZI7_PRODUT' , 'ZI0_PRODUT'      };
                         },;
                        ZI7->(IndexKey(1));
                      )

 oModel:setPrimaryKey({"ZI0_FILIAL","ZI0_MAT","ZI0_PERIOD","ZI0_PRODUT"})

return oModel


Static Function viewDef()
 Local oView		:= Nil
 Local oModel		:= FWLoadModel("ADGPE066P")
 Local oStrutZI0	:= FWFormStruct(2,"ZI0")
 Local oStrutZI7	:= FWFormStruct(2,"ZI7", {| cCampo | !('|' + AllTrim( cCampo ) + '|' $ ZI7EXCLUS)	})
  
 DbSelectArea("ZI0")
 
 ZI0->(DbSetOrder(1))
  
 oView	:= FWFormView():New()
 oView:setModel(oModel)
 
 oView:GetProgressBar(.T.)
 
 oView:addField("V_CABEC_ZI0",oStrutZI0,"CABEC_ZI0")
  oView:addGrid("V_DETAI_ZI7",oStrutZI7,"DETAI_ZI7")
   
 oView:createHorizontalBox("H_CABEC",70)
 oView:createVerticalBox("V_CABEC" ,100	,"H_CABEC")
 oView:createHorizontalBox("H_DETAI",30)
 oView:createVerticalBox("V_DETAI" ,100	,"H_DETAI")
 
 
 oView:setOwnerView("V_CABEC_ZI0","V_CABEC")
 oView:setOwnerView("V_DETAI_ZI7","V_DETAI")
  
Return oView


static function fVldForm()
	Local lRet 		:= .T.
	Local oView     := FWViewActive()
	Local oModel	:= FWModelActive()
	Local oModZI0	:= oModel:getModel("CABEC_ZI0")

	If oView:GetOperation() ==  1 
		lRet	:= .T.
	// Insert
	ElseIf oView:GetOperation() == 3
		lRet	:= .F.
	//Update or Only Update.
	ElseIf oView:GetOperation() == 4 .OR. oView:GetOperation() == 6
		
        if oModZI0:getValue("ZI0_STATUS") != "1"
            lRet := .F.
            MsgInfo("Registro não pode ser alterado por já estar em processo de entrega.", "Alteração")
        elseif !Empty(oModZI0:getValue("ZI0_FECHAM"))
            lRet := .F.
            MsgInfo("Registro em um período já finalizado.", "Alteração")
        endif
        
		
	// Delete
	ElseIf oView:GetOperation() == 5
		if oModZI0:getValue("ZI0_STATUS") != "1"
            lRet := .F.
            MsgInfo("Registro não pode ser alterado por já estar em processo de entrega.", "Exclusão")
        elseif !Empty(oModZI0:getValue("ZI0_FECHAM"))
            lRet := .F.
            MsgInfo("Registro em um período já finalizado.", "Exclusão")
        endif
	EndIf

return lRet
