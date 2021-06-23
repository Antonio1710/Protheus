#include "protheus.ch"
#include "topconn.ch"
//--------------------------RELEASE 4-------------------------------------------//
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DEVEDATA³ Autor ³Mauricio - MDS Tecnologia Data ³16/04/2014³±±                 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Relatorio para detalhamento das devoluções com dados do Pro-³±±
±±³          ³theus e do Edata. Solicitado pelo Evandro.                  ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1: Objeto do relatório                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³USO       ³ADORO                                                       ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³ Manutencao efetuada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function DEVEDATA()
Private cAliasDEV := "" 
Private cPerg   := "DEDATA"

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio para detalhamento das devoluções com dados do Protheus e do Edata. Solicitado pelo Evandro.')

//If FindFunction("TRepInUse") .And. TRepInUse()

   aHelpPor := {}
   aHelpSpa := {}
   aHelpEng := {}

   PutSX1(cPerg,"01","Periodo De"          ,"Periodo De"          ,"Periodo De"          ,"mv_ch1","D",08,0,0,"G",""         ,"","","","mv_par01" ,"","","","","","","","","","","","","","",""," ")
   PutSX1(cPerg,"02","Periodo Ate"         ,"Periodo Ate"         ,"Periodo Ate"         ,"mv_ch2","D",08,0,0,"G",""         ,"","","","mv_par02" ,"","","","","","","","","","","","","","",""," ")   
   //PutSX1(cPerg,"03","Resumido/Detalhado?","Resumido/Detalhado?","Resumido/Detalhado?","mv_ch3","N",1,0,0,"C","",""  ,"","","mv_par03" ,"Resumido","Resumido","Resumido","","Detalhado","Detalhado","Detalhado","","","","","","","",""," ")
   Pergunte(cPerg,.F.)
   
   oReport := ReportDef(@cAliasDEV)
   oReport:PrintDialog()
   
//Endif
	
Return()

Static Function ReportDef(cAliasDEV)

Local oReport
Local oProjeto
Local oDetDF
Local oDetMF
Local aOrdem := {}

Private _nSomNfe := 0

#IFNDEF TOP
	cAliasDEV := "SE2"
#ELSE
	cAliasDEV := GetNextAlias()
#ENDIF

dbSelectArea("SE2")
dbSetOrder(1)

oReport := TReport():New("DEVEDATA",OemToAnsi("Detalhamento de devoluções Protheus x Edata"), cPerg, ;
			{|oReport| ReportPrint(cAliasDEV)},;
			OemToAnsi("Relatorio com detalhamento de devoluções com da-")+CRLF+;
			OemToAnsi("dos do Protheus e do Edata.")+CRLF+;
			OemToAnsi("Detalhamento de devoluções Protheus x Edata") )
            oReport:SetLandscape()
oReport:SetTotalInLine(.F.)            
            
oProjeto := TRSection():New(oReport, OemToAnsi("Devoluções"),{"SF1", "SD1"}, aOrdem /*{}*/, .F., .F.)
oProjeto:SetTotalInLine(.F.)

TRCell():New(oProjeto,	"DT Emissao Danfe"	    ,,/*Titulo*/,PesqPict("SD1","D1_EMISSAO"),12/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oProjeto,	"DT Classificacao"	    ,,/*Titulo*/,PesqPict("SD1","D1_EMISSAO"),12/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oProjeto,	"DT Entr.Edata"	    ,,/*Titulo*/,PesqPict("SD1","D1_EMISSAO"),12/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oProjeto,	"NR Ocorrencia"	    ,,/*Titulo*/,/*Picture*/,15/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oProjeto,	"Tipo"	            ,,/*Titulo*/,/*Picture*/,11/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oProjeto,	"Docto Entrada"	        ,,/*Titulo*/,/*Picture*/,09/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oProjeto,	"Docto.Orig."	    ,,/*Titulo*/,/*Picture*/,09/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oProjeto,	"Ser.Ori."	    ,,/*Titulo*/,/*Picture*/,03/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oProjeto,	"Cliente"	    ,,/*Titulo*/,/*Picture*/,06/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oProjeto,	"Loja"	        ,,/*Titulo*/,/*Picture*/,02/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oProjeto,	"Nome"	        ,,/*Titulo*/,/*Picture*/,30/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oProjeto,	"CNPJ"	        ,,/*Titulo*/,/*Picture*/,15/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oProjeto,	"Municipio"	    ,,/*Titulo*/,/*Picture*/,15/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oProjeto,	"Estado"	    ,,/*Titulo*/,/*Picture*/,02/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oProjeto,	"Ped.Protheus"	,,/*Titulo*/,/*Picture*/,06/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oProjeto,	"Ped.Edata"	    ,,/*Titulo*/,/*Picture*/,10/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oProjeto,	"Vendedor"  	,,/*Titulo*/,/*Picture*/,06/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oProjeto,	"Produto"   	,,/*Titulo*/,/*Picture*/,15/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oProjeto,	"Descrição"   	,,/*Titulo*/,/*Picture*/,30/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oProjeto,	"Total Exp."   	,,/*Titulo*/,/*Picture*/,10/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oProjeto,	"Total Dev."	,,/*Titulo*/,/*Picture*/,10/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oProjeto,	"Vlr.Unit."	    ,,/*Titulo*/,/*Picture*/,10/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oProjeto,	"Vlr.Total"	    ,,/*Titulo*/,/*Picture*/,12/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oProjeto,	"Vlr.ICMS"	    ,,/*Titulo*/,/*Picture*/,10/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oProjeto,	"Total Lido"	    ,,/*Titulo*/,/*Picture*/,10/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oProjeto,	"Diferenca"	    ,,/*Titulo*/,/*Picture*/,10/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oProjeto,	"Ajustado"	    ,,/*Titulo*/,/*Picture*/,10/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oProjeto,	"Mot.Dev."	    ,,/*Titulo*/,/*Picture*/,02/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oProjeto,	"Mot.Protheus"	    ,,/*Titulo*/,/*Picture*/,30/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oProjeto,	"Mot.Edata"    ,,/*Titulo*/,/*Picture*/,30/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oProjeto,	"Dev.Edata"	,,/*Titulo*/,/*Picture*/,05/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oProjeto,	"Nr.Carga"	,,/*Titulo*/,/*Picture*/,10/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oProjeto,	"Placa"       	,,/*Titulo*/,/*Picture*/,09/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oProjeto,	"Transport."	,,/*Titulo*/,/*Picture*/,10/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
TRCell():New(oProjeto,	"Motorista "	,,/*Titulo*/,/*Picture*/,15/*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)

Return(oReport)

Static Function ReportPrint( cAliasDEV )
Local oProjeto  	:= oReport:Section(1)
                                 
dbSelectArea("SF1")
dbSetOrder(1)

dbSelectArea("SD1")
dbSetOrder(1)

MakeSqlExpr(cPerg)

If Select("TSD1") > 0
   DbSelectArea("TSD1")
   DbCloseArea("TSD1")
Endif

cQuery := "SELECT * FROM "+RetSqlName("SD1")+" D1 "
&&alterado query para considerar toda e qualquer devolução no Protheus
&&cQuery += "WHERE D1.D_E_L_E_T_ <> '*' AND D1.D1_X_PEDED <> '' AND D1.D1_TIPO = 'D' " 
cQuery += "WHERE D1.D_E_L_E_T_ <> '*' AND D1.D1_TIPO = 'D' " 
cQuery += "AND D1.D1_EMISSAO BETWEEN '"+dtos(mv_par01)+"' AND '"+dtos(mv_par02)+"' "
cQuery += "AND D1.D1_FILIAL = '" + Alltrim(cFilAnt) + "' "
cQuery += "ORDER BY D1.D1_EMISSAO, D1.D1_DOC, D1.D1_SERIE " 
     	
TCQUERY cQuery NEW ALIAS "TSD1"

DbSelectArea("TSD1")
DbGoTop()
While TSD1->(!Eof())

     oReport:SetMeter(("TSD1")->(LastRec()))
          
     oProjeto:Init()

     If oReport:Cancel()
		oReport:PrintText(OemToAnsi("Cancelado"))
		Exit
	 EndIf
	      
	 _cFil     := TSD1->D1_FILIAL
	 _dEmiss   := STOD(TSD1->D1_EMISSAO)
	 _dDTDIG   := STOD(TSD1->D1_DTDIGIT)
	 _cNROCO   := TSD1->D1_CTRDEVO
	 _cPEDED   := TSD1->D1_X_PEDED
	 _cNFDEV   := TSD1->D1_DOC
	 _cSRDEV   := TSD1->D1_SERIE
	 _cNFORI   := TSD1->D1_NFORI
	 _cSRORI   := TSD1->D1_SERIORI
	 _cITORI   := TSD1->D1_ITEMORI
	 _cProd    := TSD1->D1_COD
	 _cDesc    := Alltrim(Posicione("SB1",1,xFilial("SB1")+_cProd,"B1_DESC"))
	 _cCli     := TSD1->D1_FORNECE
	 _cLoj     := TSD1->D1_LOJA
	 _cNome    := Alltrim(Posicione("SA1",1,xFilial("SA1")+_cCli+_cLoj,"A1_NOME"))
	 _cCNPJ    := Posicione("SA1",1,xFilial("SA1")+_cCli+_cLoj,"A1_CGC")
	 _cMun     := Alltrim(Posicione("SA1",1,xFilial("SA1")+_cCli+_cLoj,"A1_MUN"))
	 _cEst     := Posicione("SA1",1,xFilial("SA1")+_cCli+_cLoj,"A1_EST")
	 _nQTDKG   := TSD1->D1_QUANT
	 _nPRECO   := TSD1->D1_VUNIT
	 _nTOTDV   := TSD1->D1_TOTAL
	 _nICMS    := TSD1->D1_VALICM
	 
	 DbSelectArea("SD2")
	 DbSetOrder(3)
	 If dbSeek(_cFil+_cNFORI+_cSRORI+_cCli+_cLoj+_cProd+_cITORI)
	    _cPEDPRO := SD2->D2_PEDIDO
	    _nQTOKG  := SD2->D2_QUANT
	 Else
	    _cPEDPRO := ""   
	    _nQTOKG  := 0	    
	 Endif
	 
	 IF !Empty(_cPEDPRO)
	    DbSelectArea("SC5")
	    DbSetOrder(1)
	    If dbSeek(_cFil+_cPEDPRO)
	       _cVend := SC5->C5_VEND1
	    Else
	       _cVend := ""
	    Endif	 
	 Else
	    _cVend := ""
	 Endif   
	 
	 &&busco detalhes da ocorrencia no protheus.... 
	 If !Empty(_cNROCO) 
	    If Select("TOCO") > 0
           DbSelectArea("TOCO")
           DbCloseArea("TOCO")
        Endif

        cQuery := "SELECT * FROM "+RetSqlName("SZD")+" ZD "
        cQuery += "WHERE ZD.D_E_L_E_T_ <> '*' "
        cQuery += "AND ZD.ZD_CONTROL =  '"+_cNROCO+"' "    
     	
        TCQUERY cQuery NEW ALIAS "TOCO"

        DbSelectArea("TOCO")
        DbGoTop()
        _cOcorr  := ""
        _cCMOTIV := ""
        _cDMOTIV := ""
        While TOCO->(!Eof())
	       IF TOCO->ZD_DEVTOT == "E"
	          _cOcorr := "Entregue"
	       Elseif TOCO->ZD_DEVTOT == "O"   
	          _cOcorr := "Ocorrencia"
	       Elseif TOCO->ZD_DEVTOT == "T"   
	          _cOcorr := "Total"
	       Elseif TOCO->ZD_DEVTOT == "P"   
	          _cOcorr := "Parcial"
	       Elseif TOCO->ZD_DEVTOT == "Q"   
	          _cOcorr := "Quebra"   
	       Endif
	       _cCMOTIV := Alltrim(TOCO->ZD_MOTIVO)
	       _cDMOTIV := Alltrim(Posicione("SZS",1,xFilial("SZS")+_cCMOTIV,"ZS_DESCRI"))
	       TOCO->(dbSkip())
	    Enddo
	 
	    DbCloseArea("TOCO")
	 Else
	    _cOcorr  := ""
        _cCMOTIV := ""
        _cDMOTIV := ""
	 Endif   
	 
	 &&busco dados do Edata....
	 
	 &&Mauricio 30/04/14 - alterado para duas possiveis situações.....existir o campo D1_X_PEDED atualizado no Protheus ou não....
	 
	 If !Empty(_cPEDED)
	    If Select("TEDATA") > 0
           DbSelectArea("TEDATA")
           DbCloseArea("TEDATA")
        Endif

        cQuery := "SELECT PED.ID_PEDIVEND, PED.IE_PEDIVEND, PED.ID_CARGEXPE, DEVIT.QN_EMBAEXPEITEMPEDIDEVOVEND, DEVIT.QN_EMBAITEMPEDIDEVOVEND, MOT.NM_MOTIDEVOVEND, DEV.ID_PEDIDEVOVEND, CONVERT(CHAR(10), DEV.DT_PEDIDEVOVEND, 103) AS DATAD, EMBA.IE_MATEEMBA, "
        cQuery += "TRA.GN_PLACVEICTRAN, TRA.ID_FORNECEDOR_TRANSPORTADOR, TRA.ID_TRANMOTOTRAN, DEVIT.QN_EMBAAJUSITEMPEDIDEVOVEND FROM  [LNKMIMS].[SMART].[dbo].[PEDIDO_VENDA] PED, "
        cQuery += "[LNKMIMS].[SMART].[dbo].[PEDIDO_DEVOLUCAO_VENDA] DEV, "
        cQuery += "[LNKMIMS].[SMART].[dbo].[PEDIDO_DEVOLUCAO_VENDA_ITEM] DEVIT, "
        cQuery += "[LNKMIMS].[SMART].[dbo].[VW_MATERIAL_EMBALAGEM] EMBA, "
        cQuery += "[LNKMIMS].[SMART].[dbo].[TRANSPORTADOR_VEICULO] TRA, "
        cQuery += "[LNKMIMS].[SMART].[dbo].[VENDA_DEVOLUCAO_MOTIVO] MOT "
        cQuery += "WHERE PED.ID_PEDIVEND = DEV.ID_PEDIVEND AND DEVIT.ID_PEDIDEVOVEND = DEV.ID_PEDIDEVOVEND AND DEV.ID_MOTIDEVOVEND = MOT.ID_MOTIDEVOVEND "
        cQuery += "AND PED.ID_PEDIVEND = '"+_cPEDED+"' AND TRA.ID_VEICTRAN = DEV.ID_VEICTRAN "
        cQuery += "AND DEVIT.ID_MATEEMBA = EMBA.ID_MATEEMBA AND EMBA.IE_MATEEMBA = '"+alltrim(_cProd)+"' "
	 
	    TCQUERY cQuery NEW ALIAS "TEDATA"
             
        DbSelectArea("TEDATA")       
        DbGoTop()
        _dDTDVED  := CTOD("  /  /  ")
        _cNRDVED  := ""
        _cCARGED  := ""
        _cPlc := ""
	    _cTrp := ""
	    _cmot := ""
	    _cMotivo := ""
	    _nCXDevo := 0
	    _nCXAJUS := 0
        While TEDATA->(!Eof())
	          _dDTDVED := TEDATA->DATAD
	          _cNRDVED := Alltrim(STR(TEDATA->ID_PEDIDEVOVEND))
	          _cCARGED := ALltrim(STR(TEDATA->ID_CARGEXPE))
	          _cPlc    := TEDATA->GN_PLACVEICTRAN
	          _cTrp    := Alltrim(STR(TEDATA->ID_FORNECEDOR_TRANSPORTADOR))
	          _cmot    := Alltrim(STR(TEDATA->ID_TRANMOTOTRAN))
	          _cMotivo := Alltrim(TEDATA->NM_MOTIDEVOVEND)
	          _nCXDEVO := CONVUM(_cProd,0,TEDATA->QN_EMBAEXPEITEMPEDIDEVOVEND,1)    &&lido
	          _nCXAJUS := CONVUM(_cProd,0,TEDATA->QN_EMBAAJUSITEMPEDIDEVOVEND,1)	 	 
	          TEDATA->(dbSkip())	     
	    Enddo
	 
	    DbCloseArea("TEDATA")
	 Else
	    If Select("TEDATA") > 0
           DbSelectArea("TEDATA")
           DbCloseArea("TEDATA")
        Endif

        cQuery := "SELECT PED.ID_PEDIVEND, PED.IE_PEDIVEND, PED.ID_CARGEXPE, DEVIT.QN_EMBAEXPEITEMPEDIDEVOVEND, DEVIT.QN_EMBAITEMPEDIDEVOVEND, MOT.NM_MOTIDEVOVEND, DEV.ID_PEDIDEVOVEND, CONVERT(CHAR(10), DEV.DT_PEDIDEVOVEND, 103) AS DATAD, EMBA.IE_MATEEMBA, "
        cQuery += "TRA.GN_PLACVEICTRAN, TRA.ID_FORNECEDOR_TRANSPORTADOR, TRA.ID_TRANMOTOTRAN, DEVIT.QN_EMBAAJUSITEMPEDIDEVOVEND FROM  [LNKMIMS].[SMART].[dbo].[PEDIDO_VENDA] PED, "
        cQuery += "[LNKMIMS].[SMART].[dbo].[PEDIDO_DEVOLUCAO_VENDA] DEV, "
        cQuery += "[LNKMIMS].[SMART].[dbo].[PEDIDO_DEVOLUCAO_VENDA_ITEM] DEVIT, "
        cQuery += "[LNKMIMS].[SMART].[dbo].[VW_MATERIAL_EMBALAGEM] EMBA, "
        cQuery += "[LNKMIMS].[SMART].[dbo].[TRANSPORTADOR_VEICULO] TRA, "
        cQuery += "[LNKMIMS].[SMART].[dbo].[VENDA_DEVOLUCAO_MOTIVO] MOT "
        cQuery += "WHERE PED.ID_PEDIVEND = DEV.ID_PEDIVEND AND DEVIT.ID_PEDIDEVOVEND = DEV.ID_PEDIDEVOVEND AND DEV.ID_MOTIDEVOVEND = MOT.ID_MOTIDEVOVEND "        
        cQuery += "AND PED.IE_PEDIVEND = '"+_cPEDPRO+"' AND TRA.ID_VEICTRAN = DEV.ID_VEICTRAN "
        cQuery += "AND DEVIT.ID_MATEEMBA = EMBA.ID_MATEEMBA AND EMBA.IE_MATEEMBA = '"+alltrim(_cProd)+"' "
	 
	    TCQUERY cQuery NEW ALIAS "TEDATA"
             
        DbSelectArea("TEDATA")       
        DbGoTop()
        _dDTDVED  := CTOD("  /  /  ")
        _cNRDVED  := ""
        _cCARGED  := ""
        _cPlc := ""
	    _cTrp := ""
	    _cmot := ""
	    _cMotivo := ""
	    _nCXDevo := 0
	    _nCXAJUS := 0
        While TEDATA->(!Eof())
	          _dDTDVED := TEDATA->DATAD
	          _cNRDVED := Alltrim(STR(TEDATA->ID_PEDIDEVOVEND))
	          _cCARGED := ALltrim(STR(TEDATA->ID_CARGEXPE))
	          _cPlc    := TEDATA->GN_PLACVEICTRAN
	          _cTrp    := Alltrim(STR(TEDATA->ID_FORNECEDOR_TRANSPORTADOR))
	          _cmot    := Alltrim(STR(TEDATA->ID_TRANMOTOTRAN))
	          _cMotivo := Alltrim(TEDATA->NM_MOTIDEVOVEND)
	          _nCXDEVO := CONVUM(_cProd,0,TEDATA->QN_EMBAEXPEITEMPEDIDEVOVEND,1)    &&lido
	          _nCXAJUS := CONVUM(_cProd,0,TEDATA->QN_EMBAAJUSITEMPEDIDEVOVEND,1)	 	 
	          TEDATA->(dbSkip())	     
	    Enddo
	 
	    DbCloseArea("TEDATA")
	 	 	    	    
	 Endif
	 	 	 	 	 	 
	 oProjeto:Cell("DT Emissao Danfe")	:SetBlock( {|| _dEmiss} )
	 oProjeto:Cell("DT Classificacao")	:SetBlock( {|| _dDTDIG} )
	 oProjeto:Cell("DT Entr.Edata")	:SetBlock( {|| _dDTDVED} )
	 oProjeto:Cell("NR Ocorrencia")	:SetBlock( {|| _cNROCO} )
	 oProjeto:Cell("Tipo")      	:SetBlock( {|| _cOcorr} )
	 oProjeto:Cell("Docto Entrada")	    :SetBlock( {|| _cNFDEV} )
	 oProjeto:Cell("Docto.Orig.")	:SetBlock( {|| _cNFORI} )
	 oProjeto:Cell("Ser.Ori.")  	:SetBlock( {|| _cSRORI} )
	 oProjeto:Cell("Cliente")   	:SetBlock( {|| _cCLi} )
	 oProjeto:Cell("Loja")   	    :SetBlock( {|| _cLoj} )
	 oProjeto:Cell("Nome")      	:SetBlock( {|| _cNome} )
	 oProjeto:Cell("CNPJ")	        :SetBlock( {|| _cCNPJ} )
	 oProjeto:Cell("Municipio")    	:SetBlock( {|| _cMUN} )
	 oProjeto:Cell("Estado")	    :SetBlock( {|| _cEst} )
	 oProjeto:Cell("Ped.Protheus")	:SetBlock( {|| _cPEDPRO} )
	 oProjeto:Cell("Ped.Edata")  	:SetBlock( {|| _cPEDED} ) 
	 oProjeto:Cell("Vendedor")  	:SetBlock( {|| _cVend } )
	 oProjeto:Cell("Produto")  	    :SetBlock( {|| _cProd } )
	 oProjeto:Cell("Descrição")  	:SetBlock( {|| _cDesc} )
	 oProjeto:Cell("Total Exp.")	:SetBlock( {|| _nQTOKG} )
	 oProjeto:Cell("Total Dev.")	:SetBlock( {|| _nQTDKG} )
	 oProjeto:Cell("Vlr.Unit.")	    :SetBlock( {|| _nPRECO} )
	 oProjeto:Cell("Vlr.Total")	    :SetBlock( {|| _nTOTDV } )
	 oProjeto:Cell("Vlr.ICMS")      :SetBlock( {|| _nICMS} )
	 oProjeto:Cell("Total Lido")	:SetBlock( {|| _nCXDEVO } )
	 oProjeto:Cell("Diferenca") 	:SetBlock( {|| _nQTDKG - _nCXDEVO  } )
	 oProjeto:Cell("Ajustado")  	:SetBlock( {|| _nCXAJUS } )
	 oProjeto:Cell("Mot.Dev.")   	:SetBlock( {|| _cCMOTIV} )
	 oProjeto:Cell("Mot.Protheus") 	:SetBlock( {|| _cDMOTIV} )
	 oProjeto:Cell("Mot.Edata")   	:SetBlock( {|| _cMotivo} )
	 oProjeto:Cell("Dev.Edata")     :SetBlock( {|| _cNRDVED} )
	 oProjeto:Cell("Nr.Carga")	    :SetBlock( {|| _cCARGED} )
	 oProjeto:Cell("Placa")    	    :SetBlock( {|| _cPlc} )
	 oProjeto:Cell("Transport.")	:SetBlock( {|| _cTrp} )
	 oProjeto:Cell("Motorista ")	:SetBlock( {|| _cMot} )	 
	 oProjeto:PrintLine()
	                             	             	                
     dbSelectArea("TSD1")
     TSD1->(dbSkip())
        
     oReport:IncMeter()        
EndDo 
&&Mauricio - 25/06/14 - inclusão de informmações das ocorrencias do Protheus - Solicitado por Evandro e Consultor Adoro.
If Select("TOCO") > 0
   DbSelectArea("TOCO")
   DbCloseArea("TOCO")
Endif
&&Mauricio - 23/07/14 - retirada ocorrencias do tipo entregue.
cQuery := "SELECT * FROM "+RetSqlName("SZD")+" ZD "
cQuery += "WHERE ZD_CONTROL <> ' ' AND ZD.ZD_DTDEV BETWEEN '"+dtos(mv_par01)+"' AND '"+dtos(mv_par02)+"' AND ZD.D_E_L_E_T_ <> '*' AND ZD.ZD_DEVTOT NOT IN('E','O') AND "
cQuery += "ZD_CONTROL NOT IN(SELECT D1_CTRDEVO FROM "+RetSqlName("SD1")+" D1 "
cQuery += "WHERE D1.D1_CTRDEVO <> ' ' AND D1.D_E_L_E_T_ <> '*' AND D1.D1_DTDIGIT >= '20140101') "
        	
TCQUERY cQuery NEW ALIAS "TOCO"

DbSelectArea("TOCO")
DbGoTop()
_cOcorr  := ""
_cCMOTIV := ""
_cDMOTIV := ""
_cNROCO  := ""
While TOCO->(!Eof())
	  IF TOCO->ZD_DEVTOT == "E"
	     _cOcorr := "Entregue"
	  Elseif TOCO->ZD_DEVTOT == "O"   
	     _cOcorr := "Ocorrencia"
	  Elseif TOCO->ZD_DEVTOT == "T"   
	     _cOcorr := "Total"
	  Elseif TOCO->ZD_DEVTOT == "P"   
	     _cOcorr := "Parcial"
	  Elseif TOCO->ZD_DEVTOT == "Q"   
	     _cOcorr := "Quebra"   
	  Endif
	  
	  _cCMOTIV  := Alltrim(TOCO->ZD_MOTIVO)
	  _cDMOTIV  := Alltrim(Posicione("SZS",1,xFilial("SZS")+_cCMOTIV,"ZS_DESCRI"))
	  _cNROCO   := TOCO->ZD_CONTROL	  
	  _cCNPJ    := Posicione("SA1",1,xFilial("SA1")+TOCO->ZD_CODCLI+TOCO->ZD_LOJA,"A1_CGC")
	  _cMun     := Alltrim(Posicione("SA1",1,xFilial("SA1")+TOCO->ZD_CODCLI+TOCO->ZD_LOJA,"A1_MUN"))
	  _cEst     := Posicione("SA1",1,xFilial("SA1")+TOCO->ZD_CODCLI+TOCO->ZD_LOJA,"A1_EST")
	  
	  DbSelectArea("SC5")
	  DbSetOrder(1)
	  If dbSeek(xfilial("SC5") + TOCO->ZD_PEDIDO)
	     _cVend := SC5->C5_VEND1
	  Else
	     _cVend := ""
	  Endif
	      
	  DbSelectArea("TOCO")
	  
	  oProjeto:Cell("DT Emissao Danfe")	:SetBlock( {|| CTOD("  /  /  ")} )
	  oProjeto:Cell("DT Classificacao")	:SetBlock( {|| CTOD("  /  /  ")} )
	  oProjeto:Cell("DT Entr.Edata")	:SetBlock( {||CTOD("  /  /  ")} )
	  oProjeto:Cell("NR Ocorrencia")	:SetBlock( {|| _cNROCO} )
	  oProjeto:Cell("Tipo")      	:SetBlock( {|| _cOcorr} )
	  oProjeto:Cell("Docto Entrada")	    :SetBlock( {|| Space(09)} )
	  oProjeto:Cell("Docto.Orig.")	:SetBlock( {|| TOCO->ZD_NUMNF} )
	  oProjeto:Cell("Ser.Ori.")  	:SetBlock( {|| TOCO->ZD_SERIE} )
	  oProjeto:Cell("Cliente")   	:SetBlock( {|| TOCO->ZD_CODCLI} )
	  oProjeto:Cell("Loja")   	    :SetBlock( {|| TOCO->ZD_LOJA} )
	  oProjeto:Cell("Nome")      	:SetBlock( {|| TOCO->ZD_NOMECLI} )
	  oProjeto:Cell("CNPJ")	        :SetBlock( {|| _cCNPJ} )
	  oProjeto:Cell("Municipio")    	:SetBlock( {|| _cMun } )
	  oProjeto:Cell("Estado")	    :SetBlock( {|| _cEst } )
	  oProjeto:Cell("Ped.Protheus")	:SetBlock( {|| TOCO->ZD_PEDIDO} )
	  oProjeto:Cell("Ped.Edata")  	:SetBlock( {|| Space(06)} ) 
	  oProjeto:Cell("Vendedor")  	:SetBlock( {|| _cVend } )
	  oProjeto:Cell("Produto")  	    :SetBlock( {|| "" } )
	  oProjeto:Cell("Descrição")  	:SetBlock( {|| ""} )
	  oProjeto:Cell("Total Exp.")	:SetBlock( {|| 0} )
	  oProjeto:Cell("Total Dev.")	:SetBlock( {|| 0} )
	  oProjeto:Cell("Vlr.Unit.")	    :SetBlock( {|| 0} )
	  oProjeto:Cell("Vlr.Total")	    :SetBlock( {|| 0 } )
	  oProjeto:Cell("Vlr.ICMS")      :SetBlock( {|| 0} )
	  oProjeto:Cell("Total Lido")	:SetBlock( {|| 0 } )
	  oProjeto:Cell("Diferenca") 	:SetBlock( {|| 0  } )
	  oProjeto:Cell("Ajustado")  	:SetBlock( {|| 0 } )
	  oProjeto:Cell("Mot.Dev.")   	:SetBlock( {|| _cCMOTIV} )
	  oProjeto:Cell("Mot.Protheus") 	:SetBlock( {|| _cDMOTIV} )
	  oProjeto:Cell("Mot.Edata")   	:SetBlock( {|| ""} )
	  oProjeto:Cell("Dev.Edata")     :SetBlock( {|| ""} )
	  oProjeto:Cell("Nr.Carga")	    :SetBlock( {|| ""} )
	  oProjeto:Cell("Placa")    	    :SetBlock( {|| ""} )
	  oProjeto:Cell("Transport.")	:SetBlock( {|| ""} )
	  oProjeto:Cell("Motorista ")	:SetBlock( {|| ""} )	 
	  oProjeto:PrintLine()	 	   	  
	 	   	  
	  TOCO->(dbSkip())
	  	  	  	  
Enddo
	 
DbCloseArea("TOCO")
oReport:SkipLine() 
oProjeto:Finish()
DbcloseArea("TSD1")
Return()