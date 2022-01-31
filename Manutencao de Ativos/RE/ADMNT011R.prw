#INCLUDE "PROTHEUS.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#Include 'TOTVS.ch'
#INCLUDE "topconn.ch"

/*/{Protheus.doc} ADMNT011R - Relatorio de Custo por OS / Eqto Exporta Excel
)
    @type  Function
    @author Tiago Stocco
    @since 20/07/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
	@history Chamado: T.I   - 05/08/2020, Tiago Stocco - Adicionado informaçoes no relatorio de custo de manutenção de ativos
    @history Ticket : 62637 - 18/10/2021, Tiago Stocco - Adicionado informaçoes no relatorio de custo de manutenção de ativos - Data Final
/*/

User Function ADMNT011R()
Local bProcess 		:= {|oSelf| Executa(oSelf) }
Local cPerg 		:= "ADMNT011R"
Local aInfoCustom 	:= {}
Local cTxtIntro	:=	"Rotina responsável pela extracao EXCEL dos Valores da OS"
Private oProcess
//Aadd(aInfoCustom,{"Visualizar",{|oCenterPanel| visualiza(oCenterPanel)},"WATCH" })
//Aadd(aInfoCustom,{"Relatorio" ,{|oCenterPanel| Relat(oCenterPanel) },"RELATORIO"})
oProcess := tNewProcess():New("ADMNT011R","Custo OS",bProcess,cTxtIntro,cPerg,aInfoCustom, .T.,5, "Custo OS", .T. )
Return

Static Function Executa(oProcess)
Local cQry      := ""
Local cAlias    := GetNextAlias()
Local cBem      := ""
Local cServico  := ""
Local cProd     := ""
Local cTPProd   := ""
Local cNomFor   := ""
Local cGrpProd  := ""
Local CDESCGRP  := ""
Local cSolicit  := ""
Private oExcel  := FwMsExcel():New()
Private dDataIni	:= MV_PAR01
Private dDataFim	:= MV_PAR02

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Extracao EXCEL dos Valores da OS ')

oExcel:AddworkSheet("CUSTO") // Planilha
oExcel:AddTable ("CUSTO","Itens") // Titulo da Planilha (Cabeçalho)
oExcel:AddColumn("CUSTO","Itens","Filial"       ,1,1)
oExcel:AddColumn("CUSTO","Itens","OS"		    ,1,1)
oExcel:AddColumn("CUSTO","Itens","Plano"	    ,1,1)
oExcel:AddColumn("CUSTO","Itens","Sequencia"	,1,1)
oExcel:AddColumn("CUSTO","Itens","Tarefa"		,1,1)
oExcel:AddColumn("CUSTO","Itens","TpReg"		,1,1)
oExcel:AddColumn("CUSTO","Itens","Codigo"		,1,1)
oExcel:AddColumn("CUSTO","Itens","Desc.Produto"	,1,1)
oExcel:AddColumn("CUSTO","Itens","TipoProduto"  ,1,1)
oExcel:AddColumn("CUSTO","Itens","Grupo"        ,1,1)
oExcel:AddColumn("CUSTO","Itens","Desc.Grupo"   ,1,1)
oExcel:AddColumn("CUSTO","Itens","Qtde"			,3,3)
oExcel:AddColumn("CUSTO","Itens","Unidade"		,1,1)
oExcel:AddColumn("CUSTO","Itens","Custo"		,3,3)
oExcel:AddColumn("CUSTO","Itens","SA"           ,1,1)
oExcel:AddColumn("CUSTO","Itens","Solicitante"  ,1,1)
oExcel:AddColumn("CUSTO","Itens","Dt.Inicio"	,1,4)
oExcel:AddColumn("CUSTO","Itens","Nota Fiscal"	,1,1)
oExcel:AddColumn("CUSTO","Itens","Serie NF"	    ,1,1)
oExcel:AddColumn("CUSTO","Itens","CodFornece"	,1,1)
oExcel:AddColumn("CUSTO","Itens","LojaFornec"	,1,1)
oExcel:AddColumn("CUSTO","Itens","Nome"	        ,1,1)
oExcel:AddColumn("CUSTO","Itens","Cod.Bem"	    ,1,1)
oExcel:AddColumn("CUSTO","Itens","Bem"	        ,1,1)
oExcel:AddColumn("CUSTO","Itens","Servico"      ,1,1)
oExcel:AddColumn("CUSTO","Itens","Desc.Serv"    ,1,1)
oExcel:AddColumn("CUSTO","Itens","Tp.Servico"   ,1,1)

cQry    := " SELECT "
cQry    += " TL_FILIAL,"
cQry    += " TL_ORDEM,"
cQry    += " TL_PLANO,"
cQry    += " TL_SEQRELA,"
cQry    += " TL_TAREFA,"
cQry    += " TL_TIPOREG,"
cQry    += " TL_CODIGO,"
cQry    += " TL_QUANTID,"
cQry    += " TL_UNIDADE,"
cQry    += " TL_CUSTO,"
cQry    += " TL_DTINICI,"
cQry    += " TL_NOTFIS,"
cQry    += " TL_SERIE,"
cQry    += " TL_FORNEC,"
cQry    += " TL_LOJA,"
cQry    += " TL_NUMSEQ,"
cQry    += " TL_NUMSA,"
cQry    += " TJ_CODBEM,"
cQry    += " TJ_SERVICO,"
cQry    += " TE_NOME"
cQry    += " FROM "+RetSqlName("STL")+" TL " 
cQry    += " INNER JOIN "+RetSqlName("STJ")+" TJ ON "
cQry    += " TL_FILIAL = TJ_FILIAL "
cQry    += " AND TL_ORDEM = TJ_ORDEM "
cQry    += " AND TJ.D_E_L_E_T_ = '' "
cQry    += " LEFT JOIN "+RetSqlName("ST4")+" T4 ON "
cQry    += " T4_FILIAL = TJ_FILIAL "
cQry    += " AND T4_SERVICO = TJ_SERVICO "
cQry    += " AND T4.D_E_L_E_T_ = '' "
cQry    += " LEFT JOIN "+RetSqlName("STE")+" TE ON "
cQry    += " TE_FILIAL = T4_FILIAL "
cQry    += " AND TE_TIPOMAN = T4_TIPOMAN "
cQry    += " AND TE.D_E_L_E_T_ = '' "
cQry    += " WHERE "
cQry    += " TL_DTINICI BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "
cQry    += " AND TL.D_E_L_E_T_ = ' ' "
cQry    += " AND TL_TIPOREG <> 'E' "
cQry    += " ORDER BY TL_FILIAL,TL_DTINICI,TL_ORDEM "
MemoWrite("c:\TEMP\cQry.txt", cQry)
IF Select (cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf
DbUseArea(.T., "TOPCONN", TcGenQry(,,cQry), cAlias)
DbSelectArea(cAlias)
DbGotop()
If (cAlias)->(!EOF())
	While (cAlias)->(!EOF())
        If Alltrim((cAlias)->TL_TIPOREG) == "P"
            If Empty((cAlias)->TL_NUMSEQ)
                (cAlias)->(DbSkip())
                Loop
            EndIf
        EndIf
        cSolicit    := ""
        cBem        := Posicione("ST9",1,xFilial("ST9")+(cAlias)->TJ_CODBEM,"T9_NOME")
        cServico    := Posicione("ST4",1,xFilial("ST4")+(cAlias)->TJ_SERVICO,"T4_NOME")
        Do Case
        Case Alltrim((cAlias)->TL_TIPOREG) == "P"
            DbSelectArea("SB1")
            DbSetOrder(1)
            DbSeek(xFilial("SB1")+(cAlias)->TL_CODIGO)
            cProd   := SB1->B1_DESC
            cTPProd := SB1->B1_TIPO
            cGrpProd:= SB1->B1_GRUPO
            cDescGrp:= Posicione("SBM",1,xFilial("SBM")+SB1->B1_GRUPO,"BM_DESC")
        Case Alltrim((cAlias)->TL_TIPOREG) == "M"
            cProd   := Posicione("ST1",1,xFilial("ST1")+(cAlias)->TL_CODIGO,"T1_NOME")
        End
        If !Empty((cAlias)->TL_FORNEC)
            cNomFor := Posicione("SA2",1,xFilial("SA2")+(cAlias)->TL_FORNEC+(cAlias)->TL_LOJA,"A2_NREDUZ")
        else
            cNomFor := ""
        EndIf
        If !Empty((cAlias)->TL_NUMSA)
            DbSelectArea("SCP")
            DbSetOrder(1)
            DbSeek(xFilial("SCP")+(cAlias)->TL_NUMSA)
            cSolicit := UsrRetName(SCP->CP_USER)
        EndIf
        oExcel:AddRow("CUSTO","Itens",{	(cAlias)->TL_FILIAL			    ,;
                                                (cAlias)->TL_ORDEM      ,;
                                                (cAlias)->TL_PLANO		,;
                                                (cAlias)->TL_SEQRELA	,;
                                                (cAlias)->TL_TAREFA		,;
                                                (cAlias)->TL_TIPOREG	,;
                                                (cAlias)->TL_CODIGO     ,;
                                                cProd                   ,;
                                                cTPProd                 ,;
                                                cGrpProd                ,;
                                                cDescGrp                ,;
                                                (cAlias)->TL_QUANTID	,;
                                                (cAlias)->TL_UNIDADE	,;
                                                (cAlias)->TL_CUSTO		,;
                                                (cAlias)->TL_NUMSA      ,;
                                                cSolicit                ,;
                                                STOD((cAlias)->TL_DTINICI)	,;
                                                (cAlias)->TL_NOTFIS     ,;
                                                (cAlias)->TL_SERIE      ,;
                                                (cAlias)->TL_FORNEC     ,;
                                                (cAlias)->TL_LOJA       ,;
                                                cNomFor                 ,;
                                                (cAlias)->TJ_CODBEM		,;
                                                cBem                    ,;
                                                (cAlias)->TJ_SERVICO	,;
                                                cServico                ,;
                                                (cAlias)->TE_NOME  		})	// Linha
        (cAlias)->(DbSkip())
    EndDo
    (cAlias)->(DbCloseArea())

    oExcel:AddworkSheet("OS") // Planilha
    oExcel:AddTable ("OS","Relacao de OS") // Titulo da Planilha (Cabeçalho)
    oExcel:AddColumn("OS","Relacao de OS","Filial"       ,1,1)
    oExcel:AddColumn("OS","Relacao de OS","OS"		     ,1,1)
    oExcel:AddColumn("OS","Relacao de OS","Plano"	     ,1,1)
    oExcel:AddColumn("OS","Relacao de OS","Cod.Bem"	     ,1,1)
    oExcel:AddColumn("OS","Relacao de OS","Bem"	         ,1,1)
    oExcel:AddColumn("OS","Relacao de OS","Servico"      ,1,1)
    oExcel:AddColumn("OS","Relacao de OS","Desc.Serv"    ,1,1)
    oExcel:AddColumn("OS","Relacao de OS","Tp.Servico"   ,1,1)
    oExcel:AddColumn("OS","Relacao de OS","Finalizada"   ,1,1)
    oExcel:AddColumn("OS","Relacao de OS","Dt.Manut.Ini"  ,1,4)
    oExcel:AddColumn("OS","Relacao de OS","Dt.Manut.Fim"  ,1,4) //Ticket : 62637 - 18/10/2021, Tiago Stocco
    cAlias2    := GetNextAlias()
    cQry    := " SELECT "
    cQry    += " TJ_FILIAL,"
    cQry    += " TJ_ORDEM,"
    cQry    += " TJ_PLANO,"
    cQry    += " TJ_CODBEM,"
    cQry    += " TJ_SERVICO,"
    cQry    += " TJ_TERMINO,"
    cQry    += " TJ_DTORIGI,"
    cQry    += " TJ_DTMRFIM," //Ticket : 62637 - 18/10/2021, Tiago Stocco
    cQry    += " TE_NOME"
    cQry    += " FROM "+RetSqlName("STJ")+" TJ " 
    cQry    += " LEFT JOIN "+RetSqlName("ST4")+" T4 ON "
    cQry    += " T4_FILIAL = TJ_FILIAL "
    cQry    += " AND T4_SERVICO = TJ_SERVICO "
    cQry    += " AND T4.D_E_L_E_T_ = '' "
    cQry    += " LEFT JOIN "+RetSqlName("STE")+" TE ON "
    cQry    += " TE_FILIAL = T4_FILIAL "
    cQry    += " AND TE_TIPOMAN = T4_TIPOMAN "
    cQry    += " AND TE.D_E_L_E_T_ = '' "
    cQry    += " WHERE "
    //cQry    += " TJ_DTORIGI BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "
    cQry    += " TJ_DTMPINI BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "
    cQry    += " AND TJ.D_E_L_E_T_ = ' ' "
    cQry    += " ORDER BY TJ_FILIAL,TJ_ORDEM "
    //MemoWrite("c:\TEMP\cQry.txt", cQry)
    IF Select (cAlias2) > 0
        (cAlias2)->(DbCloseArea())
    EndIf
    DbUseArea(.T., "TOPCONN", TcGenQry(,,cQry), cAlias2)
    DbSelectArea(cAlias2)
    DbGotop()
    If (cAlias2)->(!EOF())
        While (cAlias2)->(!EOF())
        cBem        := Posicione("ST9",1,xFilial("ST9")+(cAlias2)->TJ_CODBEM,"T9_NOME")
        cServico    := Posicione("ST4",1,xFilial("ST4")+(cAlias2)->TJ_SERVICO,"T4_NOME")
        oExcel:AddRow("OS","Relacao de OS",{(cAlias2)->TJ_FILIAL    ,;
                                            (cAlias2)->TJ_ORDEM     ,;
                                            (cAlias2)->TJ_PLANO		,;
                                            (cAlias2)->TJ_CODBEM	,;
                                            cBem                    ,;
                                            (cAlias2)->TJ_SERVICO	,;
                                            cServico                ,;
                                            (cAlias2)->TE_NOME  	,;
                                            (cAlias2)->TJ_TERMINO   ,;
                                            STOD((cAlias2)->TJ_DTORIGI),;	
                                            STOD((cAlias2)->TJ_DTMRFIM)})	// Linha
            (cAlias2)->(DbSkip())
        End
    (cAlias2)->(DbCloseArea())
    EndIf
    cNomArq := "c:\temp\CUST_OS.XLS"
	oExcel:Activate()
	MsAguarde({||Processa({|| oExcel:GetXMLFile(cNomArq) })},"Processanento", "Gerando arquivo XML, aguarde....")
	// oExcel:WorkBooks:Open(cNomArq) 	// Abre uma planilha
	// oExcel:SetVisible(.T.) 			// visualiza a planilha
	// apresenta a planilha gerada                      
	// oExcel:OpenXML(cNomArq) 
	oExcelApp:=MsExcel():New()                                         
	oExcelApp:WorkBooks:Open( cNomArq ) // Abre uma planilha
	oExcelApp:SetVisible(.T.)
EndIf
Return
