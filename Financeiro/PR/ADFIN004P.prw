#Include "PROTHEUS.CH"  
#INCLUDE 'FILEIO.CH'
#INCLUDE 'TopConn.CH'  
#INCLUDE "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADFIN004P ºAutor  ³William Costa       º Data ³  16/11/2015 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Programa de importacao de uma planilha em csv para levar    º±±
±±º          ³ao programa protheus o cadastro de Latitude e longitude     º±±
±±º          ³do cadastro de clientes                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFIN                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/   


/*BEGINDOC
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄD¿
//³LAYOUT ARQUIVO CSV                                            ³
//³                                                              ³
//³COLUNA A| COLUNA B     | COLUNA C     | COLUNA D  | COLUNA E  ³
//³CNPJ    | DT MAIOR ACUM| VL MAIOR ACUM| DT ULT COM| DT PEN COM³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄDÙ
ENDDOC*/

User Function ADFIN004P()

	Local cBuffer    := ""
	Local cFileOpen  := ""
	Local cTitulo1   := "Selecione o arquivo"
	Local cExtens	 := "Arquivo CSV | *.csv" 
	Local nPos1      := 0
	Local nPos2      := 0
	Local nPos3      := 0 
	Local nPos4      := 0
	Local cCnpj      := ''
	Local cDtMaiorAc := '' 
	Local nVlMaiorAc := 0 
	Local cDtPenCom  := ''
	Local cDtUltCom  := ''
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programa de importacao de uma planilha em csv para levar ao programa protheus o cadastro de Latitude e longitude do cadastro de clientes')
	
	cFileOpen := cGetFile(cExtens,cTitulo1,2,,.T.,GETF_LOCALHARD+GETF_NETWORKDRIVE,.T.)
	
	If !File(cFileOpen)
		MsgAlert("Arquivo texto: "+cFileOpen+" não localizado",cCadastro)
		Return(.F.)
	EndIf
	
	FT_FUSE(cFileOpen)   //ABRIR
	FT_FGOTOP()          //PONTO NO TOPO
	ProcRegua(FT_FLASTREC()) //QTOS REGISTROS LER
	
	While !FT_FEOF()  //FACA ENQUANTO NAO FOR FIM DE ARQUIVO
		IncProc()
		
		// Capturar dados
		cBuffer    := FT_FREADLN() //LENDO LINHA
		
	    nPos1 := at(";",cBuffer)               		       // cnpj
		nPos2 := at(";",subs(cBuffer,nPos1+1))		       // dt maior acumulo
		nPos3 := at(";",subs(cBuffer,nPos1+nPos2+1))       // vl maior acumulo 
		nPos4 := at(";",subs(cBuffer,nPos1+nPos2+nPos3+1)) // dt ultima compra
		
		cCnpj      := STRZERO(VAL(subs(cBuffer,01,nPos1-1)),8)
	    cDtMaiorAc := STRZERO(VAL(subs(cBuffer,nPos1+1,8)),8)
	    nVlMaiorAc := VAL(subs(cBuffer,nPos1+nPos2+1,nPos1+nPos2+1))
	    cDtUltCom  := STRZERO(VAL(subs(cBuffer,nPos1+nPos2+nPos3+1,nPos1+nPos2+nPos3-1)),8)
	    cDtPenCom  := STRZERO(VAL(subs(cBuffer,nPos1+nPos2+nPos3+nPos4+1,nPos1+nPos2+nPos3+nPos4-1)),8)
	    
    	SqlCliCgc(cCnpj)
	
		While TRB->(!EOF()) 
		
			DBSELECTAREA("SA1")
			DbSetOrder(1)
		   		
			IF SA1->(DbSeek(xFilial("SA1")+TRB->A1_COD+TRB->A1_LOJA))
			    
				RecLock("SA1",.F.)              
				
				    SA1->A1_DTACUMU := STOD(cDtMaiorAc)
				    SA1->A1_VLACUMU := nVlMaiorAc 
				    SA1->A1_DTULTRE := STOD(cDtUltCom)
				    SA1->A1_XDTPENU := STOD(cDtPenCom)
	
				MsUnlock()	   
				
			ENDIF		
			
			DBCLOSEAREA("SA1")
		
		    TRB->(dbSkip()) 
	    	
		ENDDO
		TRB->(dbCloseArea()) 
		
	    FT_FSKIP()   //proximo registro no arquivo txt
		
	EndDo
	
	FT_FUSE() //fecha o arquivo txt  
	
Return(NIL)

Static Function SqlCliCgc(cCnpj)

	BeginSQL Alias "TRB"
			%NoPARSER% 
			SELECT  A1_COD,
					A1_LOJA,
					A1_NOME, 
					A1_DTACUMU, 
					A1_VLACUMU, 
					A1_DTULTRE, 
					RTRIM((LEFT(A1_CGC,8))) AS A1_CGC
				FROM %Table:SA1% WITH(NOLOCK)
				WHERE RTRIM((LEFT(A1_CGC,8))) <> '00000000'
				AND RTRIM((LEFT(A1_CGC,8))) <> '' 
				AND RTRIM((LEFT(A1_CGC,8))) = %EXP:cCnpj%      
				AND D_E_L_E_T_ <> '*' 
			
				ORDER BY A1_CGC
	EndSQl             
RETURN(NIL) 