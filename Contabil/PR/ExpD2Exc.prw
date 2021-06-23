#Include "Protheus.ch"
#Include "Rwmake.ch"
#include "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ADOA020   ³ Ausor ³ hcconsys - heverson   ³ Data ³ 21.05.08 ³±±                                               
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³CSV - Gera Saldo Poder de terceiros 			  			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function ExpD2Exc()

//Local cPerg	:= "ADOA08"
Local cPerg	:= PADR("EXPD2EXC",10," ")

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

ValidPerg(cPerg)

If !Pergunte(cPerg,.T.)
	Return ( .T. )
EndIf

MsgRun("Aguarde, Gerando Planilha ...","",{|| CursorWait(),GeraSD2(),CursorArrow()})

Return


/**********************/
Static Function GeraSD2()

Local aStru		:= {}
Local aRegs		:= {}
Local cArq		:= "PROD_D2"
                                  
// MONTA CABECALHO EXCEL

aStru := {	{"FILIAL"		  		, "C", 02, 0},; //Data do Embarque
			{"PRODUTO"				, "C", 40, 0},;	// Descricao do Produto 
			{"DESCRICAO"			, "C", 15, 0},;	// Codigo Produto 
			{"QUANTIDADE"	 		, "N", 13, 4},;	//	quantidade original    
			{"VLR.UNITARIO"			, "N", 13, 4},;	//	Preço de venda    
			{"VLR.TOTAL"			, "N", 13, 4},;	//	Preço de venda    
			{"COD.FISCAL" 			, "C", 04, 0},;	// serie de nf original 
			{"C CONTABIL"			, "C", 15, 0},;	//	numero de nf origina
			{"LOCAL"				, "C", 06, 0},;	//	local //chamado: 036825 - fernando sigoli 22/08/2017
			{"NUM. DA NOTA"			, "C", 15, 0},;	// serie de nf original 
			{"EMISSAO"				, "D", 10, 0},;	//	emissao da nf 
			{"CLIENTE"				, "C", 6, 0},;	//	emissao da nf			
			{"LOJA"				    , "C", 2, 0},;	//	emissao da nf			
			{"NOME"				    , "C", 40, 0}}	//	emissao da nf			

cQuery := "SELECT D2_FILIAL, "
cQuery += " (SELECT TOP 1 B1_DESC FROM  "+RetSqlName("SB1")+" WITH(NOLOCK) WHERE D_E_L_E_T_ <> '*' "
cQuery += " AND B1_FILIAL = '' AND B1_COD = D2_COD) 'B1_DESC', D2_COD , D2_QUANT , D2_PRCVEN , "
cQuery += " D2_TOTAL , D2_CF , D2_CONTA, D2_LOCAL, "
cQuery += " D2_DOC, D2_CLIENTE, D2_LOJA, " 
cQuery += " (SELECT TOP 1 A1_NOME FROM  "+RetSqlName("SA1")+" WITH(NOLOCK) WHERE D_E_L_E_T_ <> '*' "
cQuery += " AND A1_FILIAL = '' AND A1_COD = D2_CLIENTE AND A1_LOJA = D2_LOJA) 'A1_NOME' , "
cQuery += " CONVERT(VARCHAR(10), CONVERT(SMALLDATETIME, D2_EMISSAO), 103) 'D2_EMISSAO' "
cQuery += " FROM  "+RetSqlName("SD2")+" WITH(NOLOCK) WHERE D_E_L_E_T_ <> '*' "
cQuery += " AND D2_FILIAL = '"+mv_par03+"' "
cQuery += " AND D2_EMISSAO BETWEEN '"+Dtos(mv_par01)+"' AND '"+Dtos(mv_par02)+"' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRY",.T.,.T.)

QRY->(dbGotop())                    

While QRY->(!EOF())  

	cCamposB6 := '"' + STRZERO(VAL(QRY->D2_FILIAL),2) 			+ '"'	+";"
	cCamposB6 += '"' + Alltrim(STRZERO(VAL(QRY->D2_COD),6))		+ '"' 	+";"
	cCamposB6 += '"' + Alltrim(QRY->B1_DESC)					+ '"'	+";"
	cCamposB6 += '"' + Alltrim(Transform((QRY->D2_QUANT),"@E 999,999,999.999"))	+ '"' 	+";"
	cCamposB6 += '"' + Alltrim(Transform((QRY->D2_PRCVEN),"@E 9,999,999.9999"))+ '"' 	+";"
	cCamposB6 += '"' + Alltrim(Transform((QRY->D2_TOTAL),"@E 99,999,999,999.99"))	+ '"'	+";"
	cCamposB6 += '"' + Alltrim(STRZERO(VAL(QRY->D2_CF),4))		+ '"'		+";"
	cCamposB6 += QRY->D2_CONTA +";"
	cCamposB6 += QRY->D2_LOCAL +";" //chamado: 036825 - fernando sigoli 22/08/2017
	cCamposB6 += QRY->D2_DOC +";"
	cCamposB6 += Alltrim(QRY->D2_EMISSAO)	+";"
	cCamposB6 += QRY->D2_CLIENTE +";"	
	cCamposB6 += QRY->D2_LOJA +";"		
	cCamposB6 += QRY->A1_NOME +";"		
	AAdd(aRegs,cCamposB6)
	
	QRY->(DbSkip())
	
EndDo

CriaExcel(aStru,aRegs,cArq)

QRY->(dbCloseArea())

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CriaExcel ºAutor  ³hcconsys            º Data ³  08/05/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gera o arquivo excel de acordo com a estrutura, registros e º±±
±±º          ³nome passados a funcao.                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico (Especifico adoro                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CriaExcel(aStru,aRegs,cArq)

Local cDirDocs 	:= MsDocPath()
Local cPath		:= AllTrim(GetTempPath())
Local oExcelApp
Local cCrLf 	:= Chr(13) + Chr(10)
Local nHandle
Local nX

ProcRegua(Len(aRegs)+2)

if file(cPath+"\"+cArq+".CSV")
	FErase(cPath+"\"+cArq+".CSV")		
endif

nHandle := MsfCreate(cDirDocs+"\"+cArq+".CSV",0)

If nHandle > 0
	
	// Grava o cabecalho do arquivo

	IncProc("Aguarde! Gerando arquivo de integração com Excel...")

	aEval(aStru, {|e,nX| fWrite(nHandle, e[1] + If(nX < Len(aStru), ";", "") ) } )
	
	fWrite(nHandle, cCrLf ) // Pula linha

	
	For nX := 1 to Len(aRegs)
		IncProc("Aguarde! Gerando arquivo de integração com Excel...")
		fWrite(nHandle,aRegs[nX])
		fWrite(nHandle, cCrLf ) // Pula linha
	Next
	
	IncProc("Aguarde! Abrindo o arquivo..." )
	
	fClose(nHandle)
	
	CpyS2T( cDirDocs+"\"+cArq+".CSV" , cPath, .T. )	
	
	If ! ApOleClient('MsExcel')
		MsgAlert("Excel nao instalado!")
		Return
	Else
		
		oExcelApp := MsExcel():New()
		oExcelApp:WorkBooks:Open( cPath+cArq+".CSV" ) // Abre uma planilha
		oExcelApp:SetVisible(.T.)
	
	EndIf
Else
	MsgAlert( "Falha na criacao do arquivo" )
Endif

Return


/******************************/
Static Function ValidPerg(cPerg)

Local _sAlias := Alias()
Local aRegs   := {}
Local i, j

dbSelectArea("SX1")
dbSetOrder(1)

cPerg := Padr(cPerg,10," ")

aAdd(aRegs,{cPerg,"01","Data de       ?","Data de   	 ","Data de        "	,"mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Data Ate      ?","Data Ate       ","Data Ate       "	,"mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Filial        ?",".     	     ",".			   "	,"mv_ch3","C",02,0,0,"G","","mv_par03","",".",".","","","",".",".","","","",".",".","","","","","","","","","",""})

For i := 1 to Len(aRegs)
	If 	!dbSeek( cPerg + aRegs[i,2] )
		RecLock("SX1", .T.)
		For j := 1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock("SX1")
	Endif
Next

dbSelectArea(_sAlias)

Return