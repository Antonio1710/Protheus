#include "protheus.ch"
#include "topconn.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE 'Protheus.ch'
#INCLUDE "FWEVENTVIEWCONSTS.CH"                            
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE 'Parmtype.ch'
#INCLUDE "rwmake.ch"
#INCLUDE "MSMGADD.CH"  
#INCLUDE "FWBROWSE.CH"   
#INCLUDE "DBINFO.CH"
#INCLUDE 'FILEIO.CH'
  
Static cTitulo      := "Informações de quebra de acordo"

/*/{Protheus.doc} User Function RQRYQUEBRA
	Exporta para excel informacoes de quebra de acordo com
	@type  Function
	@author Ana Helena
	@since 13/09/2013
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
    @history chamado 050729 - FWNM - 24/06/2020 - || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE	
/*/
User Function RQRYQUEBRA()
                   
	Local _aStr   := {}

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Exporta para excel informacoes de quebra de acordo com de data / parametro de data ')

	cPerg   := PADR('RQRYQUEBRA',10," ")
	If !Pergunte(cPerg,.T.)
		Return
	EndIf

	fDados()

	AADD(_aStr,{'ZX_FILIAL'   ,"C",02})
	AADD(_aStr,{'ZX_QUEBRA'   ,"N",15,2})
	AADD(_aStr,{'QBRXTOT'     ,"N",15,2})
	AADD(_aStr,{'ZD_OBSR1'    ,"C",200})
	AADD(_aStr,{'ZD_OBSR2'    ,"C",200})
	AADD(_aStr,{'ZD_OBSR3'    ,"C",200})
	AADD(_aStr,{'ZD_NUMNF'    ,"C",09})
	AADD(_aStr,{'ZD_SERIE'    ,"C",03})
	AADD(_aStr,{'ZX_ITEMNF'   ,"C",02})
	AADD(_aStr,{'ZD_CODCLI'   ,"C",06})    
	AADD(_aStr,{'ZD_LOJA'     ,"C",06})
	AADD(_aStr,{'ZD_NOMECLI'  ,"C",20})
	AADD(_aStr,{'ZX_CODPROD'  ,"C",09})
	AADD(_aStr,{'ZX_DESCRIC'  ,"C",30})
	AADD(_aStr,{'ZX_QTDEV2U'  ,"N",15,2})
	AADD(_aStr,{'ZX_QTDE'     ,"N",15,2})
	AADD(_aStr,{'ZX_UNIDADE'  ,"C",02})
	AADD(_aStr,{'ZX_QTSEGUM'  ,"N",15,2})
	AADD(_aStr,{'ZX_SEGUM'    ,"C",02})
	AADD(_aStr,{'ZX_QTDEV1U'  ,"N",15,2})
	AADD(_aStr,{'ZX_TOTAL'    ,"N",15,2})
	AADD(_aStr,{'ZX_MOTIVO'   ,"C",02})
	AADD(_aStr,{'ZD_DEVTOT'   ,"C",01})
	AADD(_aStr,{'ZD_DTDEV'    ,"C",08})
	AADD(_aStr,{'ZD_AUTNOME'  ,"C",15})
	AADD(_aStr,{'ZD_RESPONS'  ,"C",06})
	AADD(_aStr,{'ZD_RESPNOM'  ,"C",20})
	AADD(_aStr,{'ZD_MOTIVO'   ,"C",06})
	AADD(_aStr,{'ZD_DESCMOT'  ,"C",20})
	AADD(_aStr,{'ZD_PEDIDO'   ,"C",06})
	AADD(_aStr,{'ZD_PLACA'    ,"C",07})
	AADD(_aStr,{'ZD_ROTEIRO'  ,"C",03})
	AADD(_aStr,{'ZD_SEQUENC'  ,"C",02})
	AADD(_aStr,{'ZD_OBS1'     ,"C",40})
	AADD(_aStr,{'ZD_VEND'     ,"C",06})
	AADD(_aStr,{'ZD_PERNOIT'  ,"C",01})
	AADD(_aStr,{'ZD_RESP1'    ,"C",03})
	AADD(_aStr,{'ZD_CODMOTP'  ,"C",03})
	AADD(_aStr,{'ZD_MTVPERN'  ,"C",20})
	AADD(_aStr,{'ZD_PEDPERN'  ,"C",20})
	AADD(_aStr,{'ZD_MOTORI'   ,"C",50})
	AADD(_aStr,{'ZD_TELEFON'  ,"C",13})
	AADD(_aStr,{'ZD_EMLMOT'   ,"C",50})

	_cArqTmp :=CriaTrab(_aStr,.T.)
	DbUseArea(.T.,,_cArqTmp,"TMPIMP",.F.,.F.)
	_cIndex:="ZD_NUMNF"
	indRegua("TMPIMP",_cArqTmp,_cIndex,,,"Criando Indices...")         

	dbselectArea("TMPQRY")
	DbgoTop()

	While TMPQRY->(!EOF())
		RecLock("TMPIMP",.T.)	
			TMPIMP->ZX_FILIAL  := TMPQRY->ZX_FILIAL 
			TMPIMP->ZX_QUEBRA  := TMPQRY->ZX_QUEBRA 
			TMPIMP->QBRXTOT    := TMPQRY->QBRXTOT   
			TMPIMP->ZD_NUMNF   := TMPQRY->ZD_NUMNF  
			TMPIMP->ZD_SERIE   := TMPQRY->ZD_SERIE  
			TMPIMP->ZX_ITEMNF  := TMPQRY->ZX_ITEMNF 
			TMPIMP->ZD_CODCLI  := TMPQRY->ZD_CODCLI 
			TMPIMP->ZD_LOJA    := TMPQRY->ZD_LOJA   
			TMPIMP->ZD_NOMECLI := TMPQRY->ZD_NOMECLI
			TMPIMP->ZX_CODPROD := TMPQRY->ZX_CODPROD
			TMPIMP->ZX_DESCRIC := TMPQRY->ZX_DESCRIC
			TMPIMP->ZX_QTDEV2U := TMPQRY->ZX_QTDEV2U
			TMPIMP->ZX_QTDE    := TMPQRY->ZX_QTDE   
			TMPIMP->ZX_UNIDADE := TMPQRY->ZX_UNIDADE
			TMPIMP->ZX_QTSEGUM := TMPQRY->ZX_QTSEGUM
			TMPIMP->ZX_SEGUM   := TMPQRY->ZX_SEGUM  
			TMPIMP->ZX_QTDEV1U := TMPQRY->ZX_QTDEV1U
			TMPIMP->ZX_TOTAL   := TMPQRY->ZX_TOTAL  
			TMPIMP->ZX_MOTIVO  := TMPQRY->ZX_MOTIVO 
			TMPIMP->ZD_DEVTOT  := TMPQRY->ZD_DEVTOT 
			TMPIMP->ZD_DTDEV   := TMPQRY->ZD_DTDEV  
			TMPIMP->ZD_AUTNOME := TMPQRY->ZD_AUTNOME
			TMPIMP->ZD_RESPONS := TMPQRY->ZD_RESPONS
			TMPIMP->ZD_RESPNOM := TMPQRY->ZD_RESPNOM
			TMPIMP->ZD_MOTIVO  := TMPQRY->ZD_MOTIVO 
			TMPIMP->ZD_DESCMOT := TMPQRY->ZD_DESCMOT
			TMPIMP->ZD_PEDIDO  := TMPQRY->ZD_PEDIDO 
			TMPIMP->ZD_PLACA   := TMPQRY->ZD_PLACA  
			TMPIMP->ZD_ROTEIRO := TMPQRY->ZD_ROTEIRO
			TMPIMP->ZD_SEQUENC := TMPQRY->ZD_SEQUENC
			TMPIMP->ZD_OBS1    := TMPQRY->ZD_OBS1   
			TMPIMP->ZD_VEND    := TMPQRY->ZD_VEND   
			TMPIMP->ZD_PERNOIT := TMPQRY->ZD_PERNOIT
			TMPIMP->ZD_RESP1   := TMPQRY->ZD_RESP1  
			TMPIMP->ZD_CODMOTP := TMPQRY->ZD_CODMOTP
			TMPIMP->ZD_MTVPERN := TMPQRY->ZD_MTVPERN
			TMPIMP->ZD_PEDPERN := TMPQRY->ZD_PEDPERN
			TMPIMP->ZD_MOTORI  := TMPQRY->ZD_MOTORI 
			TMPIMP->ZD_TELEFON := TMPQRY->ZD_TELEFON
			TMPIMP->ZD_EMLMOT  := TMPQRY->ZD_EMLMOT
			TMPIMP->ZD_OBSR1   := " "
			TMPIMP->ZD_OBSR2   := " "	
			TMPIMP->ZD_OBSR3   := " "	
			dbSelectArea("SZD")
			dbSetOrder(1)
			dbGoTop()
			If dbSeek(xFilial("SZD")+TMPQRY->ZD_NUMNF+TMPQRY->ZD_SERIE) 
				_cObserT := ""
				_cObserv := SZD->ZD_OBSER
				_nLinhas := MlCount(_cObserv,105)
				For _nX := 1 To _nLinhas
					_cObserT += Alltrim(MemoLine(_cObserv,105,_nX)) + " "
				Next _nX
				TMPIMP->ZD_OBSR1 := SUBSTR(_cObserT,1,200)
				TMPIMP->ZD_OBSR2 := SUBSTR(_cObserT,201,400)		
				TMPIMP->ZD_OBSR3 := SUBSTR(_cObserT,401,600)		
			Endif
		MsUnLock()     
		TMPQRY->(dbSkip())
	Enddo

	bBloco:={|| expExcel()}
	MsAguarde(bBloco,"Aguarde...","Exportando dados para Microsoft Excel...",.F.)

	dbCloseArea("TMPQRY")

Return

/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author user
	@since 26/06/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function fDados()

	Local cQuery:=""

	If Select("TMPQRY") > 0
		DbSelectArea("TMPQRY")
		DbCloseArea("TMPQRY")
	Endif         

	cQuery := " SELECT ZD_OBSER, ZX_QUEBRA, ZX_QUEBRA*D2_PRCVEN AS QBRXTOT, ZX_FILIAL, "
	cQuery += " ZX_QTDEV2U, ZX_CODPROD, ZX_DESCRIC, ZX_QTDE, ZX_UNIDADE, ZX_QTSEGUM, ZX_SEGUM, ZX_QTDEV1U, ZX_TOTAL, ZX_MOTIVO, "
	cQuery += " ZX_ITEMNF, ZD_CODCLI, ZD_LOJA, ZD_NOMECLI, ZD_DEVTOT, ZD_DTDEV, ZD_AUTNOME, ZD_RESPONS, ZD_RESPNOM, ZD_MOTIVO, "
	cQuery += " ZD_DESCMOT, ZD_PEDIDO, ZD_PLACA, ZD_ROTEIRO, ZD_SEQUENC, ZD_OBS1, ZD_VEND, ZD_PERNOIT, ZD_RESP1, ZD_CODMOTP, ZD_MTVPERN, ZD_PEDPERN, ZD_MOTORI, " 
	cQuery += " ZD_TELEFON, ZD_EMLMOT, ZD_NUMNF, ZD_SERIE "
	cQuery += " FROM " + RetSqlName("SZX")
	cQuery += " INNER JOIN "+RetSqlName("SZD")+ " ON ZX_FILIAL = ZD_FILIAL AND ZX_NF = ZD_NUMNF "
	cQuery += " INNER JOIN "+RetSqlName("SD2")+ " ON D2_FILIAL = ZD_FILIAL AND D2_DOC = ZD_NUMNF AND D2_COD = ZX_CODPROD "
	cQuery += " WHERE ZD_DTDEV BETWEEN '" + DTOS(mv_par01) + "' AND '" + DTOS(mv_par02) + "' "
	cQuery += " AND " + RetSqlName("SZD") + ".D_E_L_E_T_ <> '*'  "
	cQuery += " AND " + RetSqlName("SZX") + ".D_E_L_E_T_ <> '*'  "
	cQuery += " AND " + RetSqlName("SD2") + ".D_E_L_E_T_ <> '*'  "
	cQuery += " AND ZD_DEVTOT = 'Q' "
	cQuery += " ORDER BY ZX_NF "

	TCQUERY cQuery NEW ALIAS "TMPQRY"

	dbselectArea("TMPQRY")
	DbgoTop()

Return()

                      
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//GERACAO DOS DADOS EM EXCEL
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function expExcel(cArqTRC)
 
	// Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - FWNM - 26/06/2020

	Local oExcel    := FWMsExcelEx():New()
    Local nLinha    := 0
    Local nExcel    := 1

    Private aLinhas   := {}

	dbSelectArea("TMPIMP")
	cDirDocs := MsDocPath()
	cPath    := AllTrim(GetTempPath())
	cArq:="\RQRYQUEBRA"+substr(time(),1,2)+substr(time(),4,2)+substr(time(),7,2)+".XLS"
	_cCamin:=cDirDocs+cArq

    // Cabecalho Excel
    oExcel:AddworkSheet(cArq)
	oExcel:AddTable (cArq,cTitulo)
    oExcel:AddColumn(cArq,cTitulo,"ZX_FILIAL"         ,1,1) // 01 A
	oExcel:AddColumn(cArq,cTitulo,"ZX_QUEBRA"         ,1,1) // 02 B
	oExcel:AddColumn(cArq,cTitulo,"QBRXTOT"       ,1,1) // 03 C
	oExcel:AddColumn(cArq,cTitulo,"ZD_OBSR1"             ,1,1) // 04 D
	oExcel:AddColumn(cArq,cTitulo,"ZD_OBSR2"      ,1,1) // 05 E
	oExcel:AddColumn(cArq,cTitulo,"ZD_OBSR3"              ,1,1) // 06 F
	oExcel:AddColumn(cArq,cTitulo,"ZD_NUMNF"      ,1,1) // 07 G
	oExcel:AddColumn(cArq,cTitulo,"ZD_SERIE"       ,1,1) // 08 H
	oExcel:AddColumn(cArq,cTitulo,"ZX_ITEMNF"             ,1,1) // 09 I
	oExcel:AddColumn(cArq,cTitulo,"ZD_CODCLI"             ,1,1) // 09 I
	oExcel:AddColumn(cArq,cTitulo,"ZD_LOJA"             ,1,1) // 09 I
	oExcel:AddColumn(cArq,cTitulo,"ZD_NOMECLI"             ,1,1) // 09 I
	oExcel:AddColumn(cArq,cTitulo,"ZX_CODPROD"             ,1,1) // 09 I
	oExcel:AddColumn(cArq,cTitulo,"ZX_DESCRIC"             ,1,1) // 09 I
	oExcel:AddColumn(cArq,cTitulo,"ZX_QTDEV2U"             ,1,1) // 09 I
	oExcel:AddColumn(cArq,cTitulo,"ZX_QTDE"             ,1,1) // 09 I
	oExcel:AddColumn(cArq,cTitulo,"ZX_UNIDADE"             ,1,1) // 09 I
	oExcel:AddColumn(cArq,cTitulo,"ZX_QTSEGUM"             ,1,1) // 09 I
	oExcel:AddColumn(cArq,cTitulo,"ZX_SEGUM"             ,1,1) // 09 I
	oExcel:AddColumn(cArq,cTitulo,"ZX_QTDEV1U"             ,1,1) // 09 I
	oExcel:AddColumn(cArq,cTitulo,"ZX_TOTAL"             ,1,1) // 09 I
	oExcel:AddColumn(cArq,cTitulo,"ZX_MOTIVO"             ,1,1) // 09 I
	oExcel:AddColumn(cArq,cTitulo,"ZD_DEVTOT"             ,1,1) // 09 I
	oExcel:AddColumn(cArq,cTitulo,"ZD_DTDEV"             ,1,1) // 09 I
	oExcel:AddColumn(cArq,cTitulo,"ZD_AUTNOME"             ,1,1) // 09 I
	oExcel:AddColumn(cArq,cTitulo,"ZD_RESPONS"             ,1,1) // 09 I
	oExcel:AddColumn(cArq,cTitulo,"ZD_RESPNOM"             ,1,1) // 09 I
	oExcel:AddColumn(cArq,cTitulo,"ZD_MOTIVO"             ,1,1) // 09 I
	oExcel:AddColumn(cArq,cTitulo,"ZD_DESCMOT"             ,1,1) // 09 I
	oExcel:AddColumn(cArq,cTitulo,"ZD_PEDIDO"             ,1,1) // 09 I
	oExcel:AddColumn(cArq,cTitulo,"ZD_PLACA"             ,1,1) // 09 I
	oExcel:AddColumn(cArq,cTitulo,"ZD_ROTEIRO"             ,1,1) // 09 I
	oExcel:AddColumn(cArq,cTitulo,"ZD_SEQUENC"             ,1,1) // 09 I
	oExcel:AddColumn(cArq,cTitulo,"ZD_OBS1"             ,1,1) // 09 I
	oExcel:AddColumn(cArq,cTitulo,"ZD_VEND"             ,1,1) // 09 I
	oExcel:AddColumn(cArq,cTitulo,"ZD_PERNOIT"             ,1,1) // 09 I
	oExcel:AddColumn(cArq,cTitulo,"ZD_RESP1"             ,1,1) // 09 I
	oExcel:AddColumn(cArq,cTitulo,"ZD_CODMOTP"             ,1,1) // 09 I
	oExcel:AddColumn(cArq,cTitulo,"ZD_MTVPERN"             ,1,1) // 09 I
	oExcel:AddColumn(cArq,cTitulo,"ZD_PEDPERN"             ,1,1) // 09 I
	oExcel:AddColumn(cArq,cTitulo,"ZD_MOTORI"             ,1,1) // 09 I
	oExcel:AddColumn(cArq,cTitulo,"ZD_TELEFON"             ,1,1) // 09 I
	oExcel:AddColumn(cArq,cTitulo,"ZD_EMLMOT"             ,1,1) // 09 I

    // Gera Excel
    TMPIMP->( dbGoTop() )
    Do While TMPIMP->( !EOF() )

    	nLinha++

	   	aAdd(aLinhas,{ "", ; // 01 A  
	   	               "", ; // 02 B   
	   	               "", ; // 03 C  
	   	               "", ; // 04 D  
	   	               "", ; // 05 E  
	   	               "", ; // 06 F   
	   	               "", ; // 07 G 
	   	               "", ; // 08 H   
	   	               "", ; // 08 H   
	   	               "", ; // 08 H   
	   	               "", ; // 08 H   
	   	               "", ; // 02 B   
	   	               "", ; // 03 C  
	   	               "", ; // 04 D  
	   	               "", ; // 05 E  
	   	               "", ; // 06 F   
	   	               "", ; // 07 G 
	   	               "", ; // 08 H   
	   	               "", ; // 08 H   
	   	               "", ; // 08 H   
	   	               "", ; // 08 H   
	   	               "", ; // 02 B   
	   	               "", ; // 03 C  
	   	               "", ; // 04 D  
	   	               "", ; // 05 E  
	   	               "", ; // 06 F   
	   	               "", ; // 07 G 
	   	               "", ; // 08 H   
	   	               "", ; // 08 H   
	   	               "", ; // 08 H   
	   	               "", ; // 08 H   
	   	               "", ; // 02 B   
	   	               "", ; // 03 C  
	   	               "", ; // 04 D  
	   	               "", ; // 05 E  
	   	               "", ; // 06 F   
	   	               "", ; // 07 G 
	   	               "", ; // 08 H   
	   	               "", ; // 08 H   
	   	               "", ; // 08 H   
	   	               "", ; // 08 H   
	   	               "", ; // 08 H   
	   	               ""  ; // 09 I  
	   	                   })

		aLinhas[nLinha][01] := TMPIMP->ZX_FILIAL     //A
		aLinhas[nLinha][02] := TMPIMP->ZX_QUEBRA     //B
		aLinhas[nLinha][03] := TMPIMP->QBRXTOT   //C
		aLinhas[nLinha][04] := TMPIMP->ZD_OBSR1         //D
		aLinhas[nLinha][05] := TMPIMP->ZD_OBSR2  //E
		aLinhas[nLinha][06] := TMPIMP->ZD_OBSR3          //F
		aLinhas[nLinha][07] := TMPIMP->ZD_NUMNF  //G
		aLinhas[nLinha][08] := TMPIMP->ZD_SERIE   //J
		aLinhas[nLinha][09] := TMPIMP->ZX_ITEMNF         //K
		aLinhas[nLinha][10] := TMPIMP->ZD_CODCLI         //K
		aLinhas[nLinha][11] := TMPIMP->ZD_LOJA         //K
		aLinhas[nLinha][12] := TMPIMP->ZD_NOMECLI         //K
		aLinhas[nLinha][13] := TMPIMP->ZX_CODPROD         //K
		aLinhas[nLinha][14] := TMPIMP->ZX_DESCRIC         //K
		aLinhas[nLinha][15] := TMPIMP->ZX_QTDEV2U         //K
		aLinhas[nLinha][16] := TMPIMP->ZX_QTDE         //K
		aLinhas[nLinha][17] := TMPIMP->ZX_UNIDADE         //K
		aLinhas[nLinha][18] := TMPIMP->ZX_QTSEGUM         //K
		aLinhas[nLinha][19] := TMPIMP->ZX_SEGUM         //K
		aLinhas[nLinha][20] := TMPIMP->ZX_QTDEV1U         //K
		aLinhas[nLinha][21] := TMPIMP->ZX_TOTAL         //K
		aLinhas[nLinha][22] := TMPIMP->ZX_MOTIVO         //K
		aLinhas[nLinha][23] := TMPIMP->ZD_DEVTOT         //K
		aLinhas[nLinha][24] := TMPIMP->ZD_DTDEV         //K
		aLinhas[nLinha][25] := TMPIMP->ZD_AUTNOME         //K
		aLinhas[nLinha][26] := TMPIMP->ZD_RESPONS         //K
		aLinhas[nLinha][27] := TMPIMP->ZD_RESPNOM         //K
		aLinhas[nLinha][28] := TMPIMP->ZD_MOTIVO         //K
		aLinhas[nLinha][29] := TMPIMP->ZD_DESCMOT         //K
		aLinhas[nLinha][30] := TMPIMP->ZD_PEDIDO         //K
		aLinhas[nLinha][31] := TMPIMP->ZD_PLACA         //K
		aLinhas[nLinha][32] := TMPIMP->ZD_ROTEIRO         //K
		aLinhas[nLinha][33] := TMPIMP->ZD_SEQUENC         //K
		aLinhas[nLinha][34] := TMPIMP->ZD_OBS1         //K
		aLinhas[nLinha][35] := TMPIMP->ZD_VEND         //K
		aLinhas[nLinha][36] := TMPIMP->ZD_PERNOIT         //K
		aLinhas[nLinha][37] := TMPIMP->ZD_RESP1         //K
		aLinhas[nLinha][38] := TMPIMP->ZD_CODMOTP         //K
		aLinhas[nLinha][39] := TMPIMP->ZD_MTVPERN         //K
		aLinhas[nLinha][40] := TMPIMP->ZD_PEDPERN         //K
		aLinhas[nLinha][41] := TMPIMP->ZD_MOTORI         //K
		aLinhas[nLinha][42] := TMPIMP->ZD_TELEFON         //K
		aLinhas[nLinha][43] := TMPIMP->ZD_EMLMOT         //K

        TMPIMP->( dbSkip() )

    EndDo

	// IMPRIME LINHA NO EXCEL
	For nExcel := 1 to nLinha
       	oExcel:AddRow(cArq,cTitulo,{aLinhas[nExcel][01],; // 01 A  
	                                     aLinhas[nExcel][02],; // 02 B  
	                                     aLinhas[nExcel][03],; // 03 C  
	                                     aLinhas[nExcel][04],; // 04 D  
	                                     aLinhas[nExcel][05],; // 05 E  
	                                     aLinhas[nExcel][06],; // 06 F  
	                                     aLinhas[nExcel][07],; // 07 G 
	                                     aLinhas[nExcel][08],; // 08 H  
	                                     aLinhas[nExcel][09],; // 08 H  
	                                     aLinhas[nExcel][10],; // 08 H  
	                                     aLinhas[nExcel][11],; // 08 H  
	                                     aLinhas[nExcel][12],; // 08 H  
	                                     aLinhas[nExcel][13],; // 08 H  
	                                     aLinhas[nExcel][14],; // 08 H  
	                                     aLinhas[nExcel][15],; // 08 H  
	                                     aLinhas[nExcel][16],; // 08 H  
	                                     aLinhas[nExcel][17],; // 08 H  
	                                     aLinhas[nExcel][18],; // 08 H  
	                                     aLinhas[nExcel][19],; // 08 H  
	                                     aLinhas[nExcel][20],; // 08 H  
	                                     aLinhas[nExcel][21],; // 08 H  
	                                     aLinhas[nExcel][22],; // 08 H  
	                                     aLinhas[nExcel][23],; // 08 H  
	                                     aLinhas[nExcel][24],; // 08 H  
	                                     aLinhas[nExcel][25],; // 08 H  
	                                     aLinhas[nExcel][26],; // 08 H  
	                                     aLinhas[nExcel][27],; // 08 H  
	                                     aLinhas[nExcel][28],; // 08 H  
	                                     aLinhas[nExcel][29],; // 08 H  
	                                     aLinhas[nExcel][30],; // 08 H  
	                                     aLinhas[nExcel][31],; // 08 H  
	                                     aLinhas[nExcel][32],; // 08 H  
	                                     aLinhas[nExcel][33],; // 08 H  
	                                     aLinhas[nExcel][34],; // 08 H  
	                                     aLinhas[nExcel][35],; // 08 H  
	                                     aLinhas[nExcel][36],; // 08 H  
	                                     aLinhas[nExcel][37],; // 08 H  
	                                     aLinhas[nExcel][38],; // 08 H  
	                                     aLinhas[nExcel][39],; // 08 H  
	                                     aLinhas[nExcel][40],; // 08 H  
	                                     aLinhas[nExcel][41],; // 08 H  
	                                     aLinhas[nExcel][42],; // 08 H  
	                                     aLinhas[nExcel][43] ; // 09 I  
	                                                        }) //GRAVANDO NA LINHA MANDANDO PARA O EXCEL O ARRAY COM AS LINHAS
    Next nExcel 

    oExcel:Activate()
	oExcel:GetXMLFile(cPath + cArq)

	/*
	COPY TO &_cCamin VIA "DBFCDXADS"
	CpyS2T(_cCamin, cPath, .T. )
	*/

	//------------------------------
	// Abre MS-EXCEL
	//------------------------------
	If ! ApOleClient( 'MsExcel' )
		MsgStop( "Ocorreram problemas que impossibilitaram abrir o MS-Excel ou mesmo não está instalado. Por favor, tente novamente." )  //'MsExcel nao instalado'
		Return
	EndIf
	oExcelApp:= MsExcel():New()  // Objeto para abrir Excel.
	oExcelApp:WorkBooks:Open( cPath + cArq ) // Abre uma planilha
	oExcelApp:SetVisible(.T.)

Return