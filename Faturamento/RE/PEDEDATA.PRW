#include "protheus.ch"
#include "topconn.ch"


/*/{Protheus.doc} User Function PEDEDATA
	(Relatorio com detalhes dos pedidos de venda com dados do Protheus e do Edata. Solicitado pelo Evandro.)
	@type  Function
	@author Mauricio - MDS Tecnologia
	@since 28/05/2014
	@version 04
	@history Chamado: 059758 - 17/07/2020 - ADRIANO SAVOINE - Foi efetuado o ajuste no relatorio devido ao erro do tamanho do campo o mesmo nao gerava apos alterar a query TEDATA funcionou normalmente gerando o relatorio em excel.
	/*/

User Function PEDEDATA()
Private cAliasPED := "" 
Private cPerg   := "PEDATA"

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio com detalhes dos pedidos de venda com dados do Protheus e do Edata. Solicitado pelo Evandro.')



   PutSX1(cPerg,"01","Periodo De"          ,"Periodo De"          ,"Periodo De"          ,"mv_ch1","D",08,0,0,"G",""         ,"","","","mv_par01" ,"","","","","","","","","","","","","","",""," ")
   PutSX1(cPerg,"02","Periodo Ate"         ,"Periodo Ate"         ,"Periodo Ate"         ,"mv_ch2","D",08,0,0,"G",""         ,"","","","mv_par02" ,"","","","","","","","","","","","","","",""," ")   
   Pergunte(cPerg,.F.)
   
   oReport := ReportDef(@cAliasPED)
   oReport:PrintDialog()
   

	
Static Function ReportDef(cAliasPED)

Local oReport
Local oProjeto
Local oDetDF
Local oDetMF
Local aOrdem := {}

Private _nSomNfe := 0

#IFNDEF TOP
	cAliasPED := "SC5"
#ELSE
	cAliasPED := GetNextAlias()
#ENDIF

dbSelectArea("SC5")
dbSetOrder(1)

oReport := TReport():New("PEDEDATA",OemToAnsi("Pedidos de Venda Protheus x Edata"), cPerg, ;
			{|oReport| ReportPrint(cAliasPED)},;
			OemToAnsi("Relatorio com detalhamento de PV entre os da-")+CRLF+;
			OemToAnsi("dos do Protheus e do Edata.")+CRLF+;
			OemToAnsi("Pedidso de Venda Protheus x Edata") )
            oReport:SetLandscape()
oReport:SetTotalInLine(.F.)            
            
oProjeto := TRSection():New(oReport, OemToAnsi("Pedidos"),{"SC5", "SC6", "SD2"}, aOrdem /*{}*/, .F., .F.)
oProjeto:SetTotalInLine(.F.)

TRCell():New(oProjeto,	"Produto"	    ,,/*Titulo*/,/*Picture*/,15/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oProjeto,	"Descrição"	    ,,/*Titulo*/,/*Picture*/,30/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oProjeto,	"Roteiro"	    ,,/*Titulo*/,/*Picture*/,4/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oProjeto,	"Ped. Protheus" ,,/*Titulo*/,/*Picture*/,06/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oProjeto,	"Data Ped.Protheus"	        ,,/*Titulo*/,PesqPict("SC5","C5_EMISSAO"),12/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oProjeto,	"Nr.Carga Edata",,/*Titulo*/,/*Picture*/,15/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oProjeto,	"Peso Liq.Edata",,/*Titulo*/,/*Picture*/,15/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oProjeto,	"Peso Venda Edata"	    ,,/*Titulo*/,/*Picture*/,15/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oProjeto,	"Peso Fatur.Protheus"	    ,,/*Titulo*/,/*Picture*/,15/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oProjeto,	"Diferença(P-E)"	    ,,/*Titulo*/,/*Picture*/,15/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oProjeto,	"Dif.Liq.Exp x Fat"	        ,,/*Titulo*/,/*Picture*/,15/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oProjeto,	"Data Emis Danfe"	        ,,/*Titulo*/,PesqPict("SC5","C5_EMISSAO"),12/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oProjeto,	"Nr Danfe"	        ,,/*Titulo*/,/*Picture*/,10/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oProjeto,	"Situacao Danfe"	    ,,/*Titulo*/,/*Picture*/,12/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oProjeto,	"Bloq.Credito"	    ,,/*Titulo*/,/*Picture*/,03/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)


Return(oReport)

Static Function ReportPrint( cAliasPED )
Local oProjeto  	:= oReport:Section(1)

dbSelectArea("SC5")
dbSetOrder(1)
                                 
dbSelectArea("SC6")
dbSetOrder(1)

dbSelectArea("SD2")
dbSetOrder(1)

MakeSqlExpr(cPerg)

If Select("TPED") > 0
   DbSelectArea("TPED")
   DbCloseArea("TPED")
Endif

cQuery := "SELECT * FROM "+RetSqlName("SC5")+" C5, "+RetSqlName("SC6")+" C6, " +retsqlname("SF4")+" F4  "
cQuery += "WHERE C5.D_E_L_E_T_ <> '*' AND C6.D_E_L_E_T_ <> '*' AND F4.D_E_L_E_T_ <> '*' AND C5.C5_TIPO = 'N' " 
cQuery += "AND C5.C5_NUM = C6.C6_NUM AND C6.C6_TES = F4.F4_CODIGO "
cQuery += "AND C5.C5_FILIAL = '" + cFilAnt + "' "
cQuery += "AND C5.C5_EMISSAO BETWEEN '"+dtos(mv_par01)+"' AND '"+dtos(mv_par02)+"' AND F4.F4_DUPLIC   = 'S' "
cQuery += "ORDER BY C5.C5_EMISSAO, C5.C5_NUM, C6.C6_ITEM " 
     	
TCQUERY cQuery NEW ALIAS "TPED"

DbSelectArea("TPED")
DbGoTop()
While TPED->(!Eof())

     oReport:SetMeter(("TPED")->(LastRec()))
          
     oProjeto:Init()

     If oReport:Cancel()
		oReport:PrintText(OemToAnsi("Cancelado"))
		Exit
	 EndIf
	      
	 _cFil     := TPED->C5_FILIAL	 
	 _cProd    := TPED->C6_PRODUTO
	 _cDesc    := Alltrim(Posicione("SB1",1,xFilial("SB1")+_cProd,"B1_DESC"))
	 _cRot     := TPED->C5_ROTEIRO
	 _cPed     := TPED->C5_NUM
	 _dEmissP  := STOD(TPED->C5_EMISSAO)	 	 

	//Chamado: 059758 - 17/07/2020 - ADRIANO SAVOINE INICIO.

	 If Select("TEDATA") > 0
           DbSelectArea("TEDATA")
           DbCloseArea("TEDATA")
     Endif

     cQuery := "SELECT (ID_CARGEXPE) CARG, (QN_PESOPADREXPEITEMPEDIVEND) PL, (QN_PESOITEMPEDIVEND) PV  "
     cQuery += "FROM  [LNKMIMS].[SMART].[dbo].[PEDIDO_VENDA] PED, "
     cQuery += "[LNKMIMS].[SMART].[dbo].[PEDIDO_VENDA_ITEM] ITE, "
     cQuery += "[LNKMIMS].[SMART].[dbo].[VW_MATERIAL_EMBALAGEM] EMBA "     
     cQuery += "WHERE PED.ID_PEDIVEND = ITE.ID_PEDIVEND "
     cQuery += "AND PED.IE_PEDIVEND = '"+_cPED+"' "
     cQuery += "AND ITE.ID_MATEEMBA = EMBA.ID_MATEEMBA AND EMBA.IE_MATEEMBA = '"+alltrim(_cProd)+"' "
	 
	 TCQUERY cQuery NEW ALIAS "TEDATA"
           
     DbSelectArea("TEDATA")       
     DbGoTop()
     _cCarga   := ""
     _nPesLiqE := 0
     _nPesVenE := 0    
     While TEDATA->(!Eof())
           _cCarga := Alltrim(STR(TEDATA->CARG))
           _nPesLiqE := TEDATA->PL
           _nPesVenE := TEDATA->PV
           TEDATA->(dbSkip())	     
	 Enddo
	 
	 DbCloseArea("TEDATA")

	//Chamado: 059758 - 17/07/2020 - ADRIANO SAVOINE FIM.	 

	 DbSelectArea("SD2")
	 DbSetOrder(8)
	 If dbseek(xFilial("SD2")+_cPed+TPED->C6_ITEM) 
	    _nPesFatP := SD2->D2_QUANT
	    _dEmissD  := SD2->D2_EMISSAO
	    _cDanfe   := SD2->D2_DOC                                          	 
	    _cBlqCred := "  "
	 Else
	    _nPesFatP := 0
	    _dEmissD  := "  "
	    _cDanfe   := ""                                         	 
	    _cBlqCred := "  "	 
	 Endif
	  
	 If Empty(_cDanfe)
	    _cSit := "A emitir"
	 Else
	    _cSit := "Emitida"
	 Endif   
	 	
	 DbSelectArea("SC9")
	 DbSetOrder(1)
	 If Dbseek(xFilial("SC9")+_cPed+TPED->C6_ITEM)
	    _cBlqCred := SC9->C9_BLCRED
	 Endif	 	
	 	 	 
	 oProjeto:Cell("Produto")	:SetBlock( {|| _cProd} )
	 oProjeto:Cell("Descrição")	:SetBlock( {|| _cDesc} )
	 oProjeto:Cell("Roteiro")	:SetBlock( {|| _cRot} )
	 oProjeto:Cell("Ped. Protheus")	:SetBlock( {|| _cPed} )
	 oProjeto:Cell("Data Ped.Protheus")      	:SetBlock( {|| _dEmissP} )
	 oProjeto:Cell("Nr.Carga Edata")	    :SetBlock( {|| _cCarga} )
	 oProjeto:Cell("Peso Liq.Edata")	:SetBlock( {|| _nPesLiqE} )
	 oProjeto:Cell("Peso Venda Edata")  	:SetBlock( {|| _nPesVenE} )
	 oProjeto:Cell("Peso Fatur.Protheus")   	:SetBlock( {|| _nPesFatP} )
	 oProjeto:Cell("Diferença(P-E)")   	    :SetBlock( {|| _nPesFatP - _nPesVenE} )
	 oProjeto:Cell("Dif.Liq.Exp x Fat")      	:SetBlock( {||_nPesFatP - _nPesLiqE } )
	 oProjeto:Cell("Data Emis Danfe")	        :SetBlock( {|| _dEmissD} )
	 oProjeto:Cell("Nr Danfe")    	:SetBlock( {|| _cDanfe} )
	 oProjeto:Cell("Situacao Danfe")	    :SetBlock( {|| _cSit} )
	 oProjeto:Cell("Bloq.Credito")	:SetBlock( {|| _cBlqCred} )
	 oProjeto:PrintLine()
	                             	             	                
     dbSelectArea("TPED")
     TPED->(dbSkip())
   
    oReport:IncMeter()        
EndDo
oReport:SkipLine() 
oProjeto:Finish()
DbcloseArea("TPED")

Return()
