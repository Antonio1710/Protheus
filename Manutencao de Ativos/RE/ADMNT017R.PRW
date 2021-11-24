#INCLUDE "PROTHEUS.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#Include 'TOTVS.ch'
#INCLUDE "topconn.ch"
/*/{Protheus.doc} ADMNT017R - Relatorio de Custo por solicitante / Eqto Exporta Excel
)
    @type  Function
    @author Tiago Stocco
    @since 23/11/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    TICKET 64237
    /*/
User Function ADMNT017R()
Local bProcess 		:= {|oSelf| Executa(oSelf) }
Local cPerg 		:= "ADMNT011R"
Local aInfoCustom 	:= {}
Local cTxtIntro	:=	"Rotina responsável pela extracao EXCEL dos Valores da OS por solicitante"
Private oProcess
//Aadd(aInfoCustom,{"Visualizar",{|oCenterPanel| visualiza(oCenterPanel)},"WATCH" })
//Aadd(aInfoCustom,{"Relatorio" ,{|oCenterPanel| Relat(oCenterPanel) },"RELATORIO"})
oProcess := tNewProcess():New("ADMNT017R","Custo OS solicitante",bProcess,cTxtIntro,cPerg,aInfoCustom, .T.,5, "Custo OS solicitante", .T. )
Return

Static Function Executa(oProcess)
Local cQry      := ""
Local cAlias    := GetNextAlias()
Local cSolicit  := ""
Private oExcel  := FwMsExcel():New()
Private dDataIni	:= MV_PAR01
Private dDataFim	:= MV_PAR02


oExcel:AddworkSheet("Custo_Solicit") // Planilha
oExcel:AddTable ("Custo_Solicit","Custo_x_Solicitante") // Titulo da Planilha (Cabeçalho)
oExcel:AddColumn("Custo_Solicit","Custo_x_Solicitante","Solicitante"    ,1,1)
oExcel:AddColumn("Custo_Solicit","Custo_x_Solicitante","Custo"		    ,3,3)

cQry    := " SELECT "
cQry    += " CP_USER,"
cQry    += " SUM(TL_CUSTO) AS CUSTO "
cQry    += " FROM "+RetSqlName("STL")+" TL WITH (NOLOCK) " 
cQry    += " INNER JOIN "+RetSqlName("SCP")+" SCP WITH (NOLOCK) ON "
cQry    += " CP_FILIAL = TL_FILIAL "
cQry    += " AND CP_NUM = TL_NUMSA "
cQry    += " AND CP_PRODUTO = TL_CODIGO "
cQry    += " AND CP_ITEM = TL_ITEMSA "
cQry    += " AND SCP.D_E_L_E_T_ = '' "
cQry    += " WHERE "
cQry    += " TL_DTINICI BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "
cQry    += " AND TL.D_E_L_E_T_ = '' "
cQry    += " AND TL_SEQRELA <> '0' "
cQry    += " AND TL_FORNEC = '' "
cQry    += " AND TL_TIPOREG = 'P' "
cQry    += " AND TL_FILIAL = '"+xFilial("STL")+"' "
cQry    += " GROUP BY CP_USER,TL_FILIAL "
cQry    += " ORDER BY CP_USER"
MemoWrite("c:\TEMP\cQry.txt", cQry)
IF Select (cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf
DbUseArea(.T., "TOPCONN", TcGenQry(,,cQry), cAlias)
DbSelectArea(cAlias)
DbGotop()
If (cAlias)->(!EOF())
	While (cAlias)->(!EOF())
        cSolicit    :=  UsrRetName((cAlias)->CP_USER)
        oExcel:AddRow("Custo_Solicit","Custo_x_Solicitante",{cSolicit		    ,;
                                                             (cAlias)->CUSTO     })	// Linha
        (cAlias)->(DbSkip())
    EndDo
    (cAlias)->(DbCloseArea())
    cNomArq := "c:\temp\CUST_SOLICIT.XLS"
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
