#include 'rwmake.ch'
#include 'protheus.ch'   
#include "AP5MAIL.CH"
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
  
Static cTitulo      := "LOG da CT2"

/*/{Protheus.doc} User Function nomeFunction
	Rotina que gera um arquivo excel com o log da tabela CT2.
	@type  Function
	@author Ana Helena
	@since 18/06/2014
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history chamado 050729  - FWNM         - 25/06/2020 - || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE
/*/
User Function DESEMCT2()

	Local cQuery := ""
	Local _aStr  := {}

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

	If Select("TMPQRY") > 0
		DbSelectArea("TMPQRY")
		DbCloseArea("TMPQRY")
	Endif 

	cPerg 	:= PADR("DESEMCT2",10," ")
	Pergunte	(cPerg,.T.)        

	cQuery := " SELECT CT2_DATA,CT2_LOTE,CT2_SBLOTE,CT2_DOC,CT2_LINHA,CT2_DC,CT2_DEBITO,CT2_CREDIT,CT2_VALOR,CT2_HIST,CT2_CCD, "
	cQuery += " CT2_CCC,CT2_ITEMD,CT2_ITEMC,CT2_USERGA, D_E_L_E_T_ AS EXCLUIDO "
	cQuery += " FROM " + RetSqlName("CT2") + " WITH(NOLOCK) "
	cQuery += " WHERE CT2_DATA = '" + DTOS(mv_par01) + "' "
	cQuery += " AND CT2_LOTE = '" + Alltrim(mv_par02) + "' "
	cQuery += " AND CT2_DOC = '" + Alltrim(mv_par03) + "' "
	cQuery += " ORDER BY R_E_C_N_O_ "

	TCQUERY cQuery NEW ALIAS "TMPQRY"

	dbselectArea("TMPQRY")
	DbgoTop()

	AADD(_aStr,{'CT2_USERGA',"D",08,0})
	AADD(_aStr,{'CT2_NOME',"C",50,0})
	AADD(_aStr,{'CT2_DATA'   ,"D",08,0}) 
	AADD(_aStr,{'CT2_LOTE'   ,"C",6})
	AADD(_aStr,{'CT2_SBLOTE'   ,"C",3})
	AADD(_aStr,{'CT2_DOC'   ,"C",6})
	AADD(_aStr,{'CT2_LINHA'   ,"C",3})
	AADD(_aStr,{'CT2_DC'   ,"C",1})
	AADD(_aStr,{'CT2_DEBITO'   ,"C",20})
	AADD(_aStr,{'CT2_CREDIT'   ,"C",20})
	AADD(_aStr,{'CT2_VALOR'   ,"N",15,4})
	AADD(_aStr,{'CT2_HIST'   ,"C",70})
	AADD(_aStr,{'CT2_CCD'   ,"C",9})
	AADD(_aStr,{'CT2_CCC'   ,"C",9})
	AADD(_aStr,{'CT2_ITEMD'   ,"C",9})
	AADD(_aStr,{'CT2_ITEMC'   ,"C",9})
	AADD(_aStr,{'EXCLUIDO'   ,"C",1})

	_cArqTmp :=CriaTrab(_aStr,.T.)
	DbUseArea(.T.,,_cArqTmp,"TIM",.F.,.F.)
	_cIndex:="CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA"
	indRegua("TIM",_cArqTmp,_cIndex,,,"Criando Indices...")         

	dbselectArea("TMPQRY")
	DbgoTop()

	While TMPQRY->(!EOF())
		If Alltrim(TMPQRY->CT2_LOTE) <> ""
			RecLock("TIM",.T.)	 
			TIM->CT2_DOC  := TMPQRY->CT2_DOC
			cStr     := TMPQRY->CT2_USERGA
			cNovaStr := Embaralha(cStr, 1) // parametro 0 embaralha, 1 desembaralha
			cUsu     := UsrRetName(Substr(cNovaStr,3,6))
			nDias    := Load2in4(SubStr(cNovaStr,16))
			dData    := CtoD("01/01/96","DDMMYY") + nDias
			TIM->CT2_USERGA  := dData
			TIM->CT2_NOME    := cUsu 
		
			TIM->CT2_DATA     := STOD(TMPQRY->CT2_DATA)
			TIM->CT2_LOTE     := TMPQRY->CT2_LOTE
			TIM->CT2_SBLOTE   := TMPQRY->CT2_SBLOTE
			TIM->CT2_LINHA    := TMPQRY->CT2_LINHA
			TIM->CT2_DC       := TMPQRY->CT2_DC
			TIM->CT2_DEBITO   := TMPQRY->CT2_DEBITO
			TIM->CT2_CREDIT   := TMPQRY->CT2_CREDIT
			TIM->CT2_VALOR    := TMPQRY->CT2_VALOR
			TIM->CT2_HIST     := TMPQRY->CT2_HIST
			TIM->CT2_CCD      := TMPQRY->CT2_CCD
			TIM->CT2_CCC      := TMPQRY->CT2_CCC
			TIM->CT2_ITEMD    := TMPQRY->CT2_ITEMD
			TIM->CT2_ITEMC    := TMPQRY->CT2_ITEMC
			If Alltrim(TMPQRY->EXCLUIDO) <> ''
				TIM->EXCLUIDO := "S"
			Else
				TIM->EXCLUIDO := "N"	
			Endif
			TIM->(MsUnLock())
		endif	
		TMPQRY->(dbSkip())
	Enddo	 

	bBloco:={|| expExcel()}
	MsAguarde(bBloco,"Aguarde...","Exportando dados para Microsoft Excel...",.F.)

	dbCloseArea("TMPQRY")
	dbCloseArea("TIM")

Return()

                      
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//GERACAO DOS DADOS EM EXCEL
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function expExcel(cArqTRC)
 
     // Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - FWNM - 25/06/2020
	Local oExcel    := FWMsExcelEx():New()
    Local nLinha    := 0
    Local nExcel    := 1

    Private aLinhas   := {}

	dbSelectArea("TIM")
	TIM->( dbGoTop() )

	cDirDocs := MsDocPath()
	cPath    := AllTrim(GetTempPath())

	cArq:="\RQRYPED"+substr(time(),1,2)+substr(time(),4,2)+substr(time(),7,2)+".XLS"
	_cCamin:=cDirDocs+cArq

    // Cabecalho Excel
    oExcel:AddworkSheet(cArq)
	oExcel:AddTable (cArq,cTitulo)
    oExcel:AddColumn(cArq,cTitulo,"CT2_USERGA"            ,1,1) // 01 A
	oExcel:AddColumn(cArq,cTitulo,"CT2_NOME"        ,1,1) // 02 B
	oExcel:AddColumn(cArq,cTitulo,"CT2_DATA"       ,1,1) // 03 C
	oExcel:AddColumn(cArq,cTitulo,"CT2_LOTE"       ,1,1) // 04 D
	oExcel:AddColumn(cArq,cTitulo,"CT2_SBLOTE"        ,1,1) // 05 E
	oExcel:AddColumn(cArq,cTitulo,"CT2_DOC"        ,1,1) // 06 F
	oExcel:AddColumn(cArq,cTitulo,"CT2_LINHA"       ,1,1) // 07 G
	oExcel:AddColumn(cArq,cTitulo,"CT2_DC"     ,1,1) // 08 H
	oExcel:AddColumn(cArq,cTitulo,"CT2_DEBITO"         ,1,1) // 09 I
	oExcel:AddColumn(cArq,cTitulo,"CT2_CREDIT"     ,1,1) // 10 I
	oExcel:AddColumn(cArq,cTitulo,"CT2_VALOR"      ,1,1) // 11 I
	oExcel:AddColumn(cArq,cTitulo,"CT2_HIST"     ,1,1) // 12 I
	oExcel:AddColumn(cArq,cTitulo,"CT2_CCD"     ,1,1) // 13 I
	oExcel:AddColumn(cArq,cTitulo,"CT2_CCC"     ,1,1) // 14 I
	oExcel:AddColumn(cArq,cTitulo,"CT2_ITEMD"     ,1,1) // 15 I
	oExcel:AddColumn(cArq,cTitulo,"CT2_ITEMC"     ,1,1) // 16 I
	oExcel:AddColumn(cArq,cTitulo,"EXCLUIDO"     ,1,1) // 17 I

    // Gera Excel
    TIM->( dbGoTop() )
    Do While TIM->( !EOF() )

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
	   	               "", ; // 08 H   
	   	               "", ; // 08 H   
	   	               "", ; // 08 H   
	   	               "", ; // 08 H   
	   	               "", ; // 08 H   
	   	               "", ; // 08 H   
	   	               "", ; // 08 H   
	   	               "", ; // 08 H   
	   	               ""  ; // 09 I  
	   	                   })

		aLinhas[nLinha][01] := CT2_USERGA
		aLinhas[nLinha][02] := CT2_NOME
		aLinhas[nLinha][03] := CT2_DATA
		aLinhas[nLinha][04] := CT2_LOTE
		aLinhas[nLinha][05] := CT2_SBLOTE
		aLinhas[nLinha][06] := CT2_DOC
		aLinhas[nLinha][07] := CT2_LINHA
		aLinhas[nLinha][08] := CT2_DC
		aLinhas[nLinha][09] := CT2_DEBITO
		aLinhas[nLinha][10] := CT2_CREDIT
		aLinhas[nLinha][11] := CT2_VALOR
		aLinhas[nLinha][12] := CT2_HIST
		aLinhas[nLinha][13] := CT2_CCD
		aLinhas[nLinha][14] := CT2_CCC
		aLinhas[nLinha][15] := CT2_ITEMD
		aLinhas[nLinha][16] := CT2_ITEMC
		aLinhas[nLinha][17] := EXCLUIDO

        TIM->( dbSkip() )

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
	                                     aLinhas[nExcel][17] ; // 09 I  
	                                                        }) //GRAVANDO NA LINHA MANDANDO PARA O EXCEL O ARRAY COM AS LINHAS
    Next nExcel 

    oExcel:Activate()
	oExcel:GetXMLFile(cPath + cArq)

	//COPY TO &_cCamin VIA "DBFCDXADS"
	//CpyS2T(_cCamin, cPath, .T. )

	//------------------------------
	// Abre MS-EXCEL
	//------------------------------
	If ! ApOleClient( 'MsExcel' )
		MsgStop( "Ocorreram problemas que impossibilitaram abrir o MS-Excel ou mesmo não está instalado. Por favor, tente novamente." )  //'MsExcel nao instalado'
		Return
	EndIf

	oExcelApp:= MsExcel():New()  && Objeto para abrir Excel.
	oExcelApp:WorkBooks:Open( cPath + cArq ) // Abre uma planilha
	oExcelApp:SetVisible(.T.)

Return 