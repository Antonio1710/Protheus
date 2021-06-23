#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FILEIO.CH"
#INCLUDE "TopConn.CH"  
#INCLUDE "rwmake.ch"     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADCOM030R ºAutor  ³William COSTA       º Data ³  23/02/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio de Conta Corrente para o Pedido de Compra,       º±±
±±ºDesc.     ³Verificar Pedido de Compra, Notas de Entrada e Devolucoes   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGACOM                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±ºAlteracao ³                                                            º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function ADCOM030R()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private aSays		:= {}
	Private aButtons	:= {}   
	Private cCadastro	:= "Relatorio de Pedido de Compra Conta Corrente"    
	PRIVATE oFontA06	:= TFont():New( "Arial",,10,,.f.,,,,,.f. )
	PRIVATE oFontA09	:= TFont():New( "Arial",,-9,,.f.,,,,,.f. )
	PRIVATE oFontA09b	:= TFont():New( "Arial",,-9,,.t.,,,,,.f. )
	PRIVATE oFontA07	:= TFont():New( "Arial",,12,,.T.,,,,,.f. )
	PRIVATE oPrn		:= TMSPrinter():New()
	Private nOpca		:= 0
	Private cPerg		:= 'ADCOM030R'

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
	//+------------------------------------------------+
	//|Cria grupo de Perguntas                         |
	//+------------------------------------------------+
	 MontaPerg()
	 
	 //+-----------------------------------------------+
	//|Monta Form Batch - Interface com o Usuario     |
	//+-----------------------------------------------+
	AADD(aSays,"Este programa tem a finalidade de Gerar um arquivo Excel " )
	AADD(aSays,"Relatorio de Pedido de Compra Conta Corrente"     )
    
	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T.) }})
	AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||LogADCOM030R()},"Gerando arquivo","Aguarde...")    }})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})
	
	FormBatch( cCadastro, aSays, aButtons )  
	
Return (Nil)  
    
Static Function LogADCOM030R()  
  
	PRIVATE oExcel      := FWMSEXCEL():New()
	PRIVATE cPath       := ''
	PRIVATE cArquivo    := 'REL_PED_COM_CORRENTE.XML'
	PRIVATE oMsExcel
	PRIVATE cPlanilha   := "Pedido de Compra Corrente"
    PRIVATE cTitulo     := "Pedido de Compra Corrente"
	PRIVATE aLinhas     := {}
	
	BEGIN SEQUENCE
		
		IF .NOT.( ApOleClient("MsExcel") )   // se nao existir o excel sai fora..
		    Alert("Não Existe Excel Instalado")
            BREAK
        EndIF
		
		Cabec()             
		GeraExcel()
	          
		SalvaXml()
		CriaExcel()
	
	    MsgInfo("Arquivo Excel gerado!")    
	    
	END SEQUENCE

Return(NIL) 

Static Function GeraExcel()

    Local nExcel       := 0
	Local cNumPed      := ''
	Local cItem        := ''
	Local cNumOld      := ''
	Local cItemOld     := ''
	Local cProduto     := ''
	Local cDEscProd    := ''
	Private nLinha     := 0
	Private nSaldoPed  := 0
	Private nSaldoVal  := 0
	Private nSaldoNot  := 0
	Private nQtdResi   := 0 
	Private nQtdResi2  := 0
	Private oTempTable := NIL
	Private aCampos    := {}
	Private nLinIni    := 0
	Private nLinFin    := 0
	Private nCont      := 0
	Private cProd2     := ''
	Private cNomeFor   := ''
	Private nVlUnit    := 0
	Private nVlDev     := 0
	Private nVlNota    := 0
	Private nVlPed     := 0	
	// *** INICIO MONTAR CONTA CORRENTE TABELA TEMPORARIA *** //
	
	// *** INICIO CRIA TABELA TEMPORARIA *** //
	IncProc("Criando Tabela Temporária")  
	oTempTable := FWTemporaryTable():New("TRC")
	
	// INICIO Monta os campos da tabela
	aadd(aCampos,{"DATAEMIS" ,"C",08,0})
    aadd(aCampos,{"CHAVE"    ,"C",45,0})
    aadd(aCampos,{"NUMERO"   ,"C",09,0})
    aadd(aCampos,{"ITEM"     ,"C",04,0})
    aadd(aCampos,{"PRODUTO"  ,"C",15,0})
    aadd(aCampos,{"DESCPROD" ,"C",40,0})
    aadd(aCampos,{"TABELA"   ,"C",03,0})
    aadd(aCampos,{"TIPO"     ,"C",20,0})
    aadd(aCampos,{"QTD"      ,"N",17,4})
    aadd(aCampos,{"QTDUSADA" ,"N",17,4})
    aadd(aCampos,{"QTDDEV"   ,"N",17,4})
    aadd(aCampos,{"QTD_PEDI" ,"N",17,4})
    aadd(aCampos,{"VLUNIT"   ,"N",17,4})
    aadd(aCampos,{"TOTAL"    ,"N",17,2})
    aadd(aCampos,{"RESIDUO"  ,"C",01,0})
    aadd(aCampos,{"QTDRESID" ,"N",17,2})
    aadd(aCampos,{"DOC"      ,"C",09,0})
    aadd(aCampos,{"VLICM"    ,"N",17,2})
    aadd(aCampos,{"VLIPI"    ,"N",17,2})
    aadd(aCampos,{"VLPIS"    ,"N",17,2})
    aadd(aCampos,{"VLCOFINS" ,"N",17,2})
    aadd(aCampos,{"VLDESPESA","N",17,2})
    aadd(aCampos,{"NOMEFORNE","C",60,0})
    
    
    // FINAL Monta os campos da tabela
    
	oTemptable:SetFields(aCampos)
	oTempTable:AddIndex("01", {"CHAVE"} )
	
	//------------------
	//Criação da tabela
	//------------------
	oTempTable:Create()
    
	// *** FINAL CRIA TABELA TEMPORARIA *** //
	cNumPed      := ''
	cItem        := ''
	cProduto     := ''
	cDEscProd    := ''
	
	SqlPedidoCompra()
	DBSELECTAREA("TRD")
	TRD->(DBGOTOP())
	WHILE TRD->(!EOF())
	
		cNumPed   := TRD->C7_NUM
		cItem     := TRD->C7_ITEM
		cProduto  := TRD->C7_PRODUTO
		cDEscProd := POSICIONE("SB1",1,FWXFILIAL("SB1")+TRD->C7_PRODUTO,"B1_DESC")
		nQtdResi  := IIF(TRD->C7_RESIDUO == 'S',TRD->C7_QUANT - TRD->C7_QUJE,0)
		
		 
		IncProc("TEMP TABLE SC7 - Produto: " + cProduto + " Item: " + cItem)
	
		Reclock("TRC",.T.)
				    
	    	TRC->DATAEMIS  := TRD->C7_EMISSAO
	    	TRC->CHAVE     := TRD->CHAVE
	    	TRC->NUMERO    := cNumPed
	    	TRC->DOC       := ''
	    	TRC->ITEM      := cItem 
	    	TRC->PRODUTO   := cProduto
	    	TRC->DESCPROD  := cDEscProd
	    	TRC->TABELA    := TRD->TABELA
	    	TRC->TIPO      := TRD->TIPO
	    	TRC->QTD       := TRD->C7_QUANT
	    	TRC->QTDUSADA  := TRD->C7_QUJE
	    	TRC->QTDDEV    := TRD->QTD_DEV
	    	TRC->QTD_PEDI  := TRD->QTD_PEDI
	    	TRC->VLICM     := 0
	    	TRC->VLIPI     := 0
	    	TRC->VLPIS     := 0
	    	TRC->VLCOFINS  := 0
	    	TRC->VLDESPESA := 0
	    	TRC->VLUNIT    := TRD->C7_PRECO
	    	TRC->TOTAL     := TRD->C7_TOTAL 
	    	TRC->RESIDUO   := TRD->C7_RESIDUO
	    	TRC->QTDRESID  := nQtdResi
	    	TRC->NOMEFORNE := TRD->A2_NOME
	    	
	    TRC->(MSUNLOCK())
	    
	    SqlNFEntrada(TRD->C7_NUM,TRD->C7_PRODUTO,TRD->C7_ITEM,TRD->C7_FORNECE,TRD->C7_LOJA)
	    DBSELECTAREA("TRE")
		TRE->(DBGOTOP())
		WHILE TRE->(!EOF())
		
			IncProc("TEMP TABLE SD1 - Produto: " + cProduto + " Item: " + cItem)
		
			Reclock("TRC",.T.)
				    
		    	TRC->DATAEMIS  := TRE->D1_DTDIGIT
		    	TRC->CHAVE     := TRE->CHAVE
		    	TRC->NUMERO    := cNumPed
		    	TRC->DOC       := TRE->D1_DOC
		    	TRC->ITEM      := cItem 
		    	TRC->PRODUTO   := cProduto
		    	TRC->DESCPROD  := cDEscProd
		    	TRC->TABELA    := TRE->TABELA
		    	TRC->TIPO      := TRE->TIPO
		    	TRC->QTD       := TRE->D1_QUANT
		    	TRC->QTDUSADA  := TRE->QTDUSADA
		    	TRC->QTDDEV    := TRE->QTD_DEV
		    	TRC->QTD_PEDI  := TRE->QTD_PEDI
		    	TRC->VLICM     := TRE->D1_VALICM
		    	TRC->VLIPI     := TRE->D1_VALIPI
		    	TRC->VLPIS     := TRE->D1_VALIMP6
		    	TRC->VLCOFINS  := TRE->D1_VALIMP5
		    	TRC->VLDESPESA := BUSCADESPESA(TRE->D1_FILIAL,TRE->D1_DOC,TRE->D1_SERIE,TRE->D1_FORNECE,TRE->D1_LOJA)
		    	TRC->VLUNIT    := TRE->D1_VUNIT
		    	TRC->TOTAL     := TRE->D1_TOTAL
		    	TRC->RESIDUO   := ''
		    	TRC->QTDRESID  := nQtdResi
		    	TRC->NOMEFORNE := ''
		    	
		    TRC->(MSUNLOCK())
		    
		    SqlNFSaida(TRE->D1_DOC,TRE->D1_SERIE,TRE->D1_COD,TRE->D1_ITEM,TRE->D1_FORNECE,TRE->D1_LOJA)
		    DBSELECTAREA("TRF")
			TRF->(DBGOTOP())
			WHILE TRF->(!EOF())
			
				IncProc("TEMP TABLE SD2 - Produto: " + cProduto + " Item: " + cItem)
			
				Reclock("TRC",.T.)
					    
			    	TRC->DATAEMIS  := TRF->D2_EMISSAO
			    	TRC->CHAVE     := TRF->CHAVE
			    	TRC->NUMERO    := cNumPed
			    	TRC->DOC       := TRF->D2_DOC
			    	TRC->ITEM      := cItem 
			    	TRC->PRODUTO   := cProduto
			    	TRC->DESCPROD  := cDEscProd
			    	TRC->TABELA    := TRF->TABELA
			    	TRC->TIPO      := TRF->TIPO
			    	TRC->QTD       := TRF->D2_QUANT
			    	TRC->QTDUSADA  := TRF->QTDUSADA
			    	TRC->QTDDEV    := TRF->QTD_DEV
			    	TRC->QTD_PEDI  := TRF->QTD_PEDI
			    	TRC->VLICM     := 0
			    	TRC->VLIPI     := 0
			    	TRC->VLPIS     := 0
			    	TRC->VLCOFINS  := 0
			    	TRC->VLDESPESA := 0
			    	TRC->VLUNIT    := TRF->D2_PRCVEN
			    	TRC->TOTAL     := TRF->D2_TOTAL
			    	TRC->RESIDUO   := ''
			    	TRC->QTDRESID  := nQtdResi
			    	TRC->NOMEFORNE := ''
			    	
			    TRC->(MSUNLOCK())
				
				TRF->(dbSkip())    
			
			ENDDO //end do while TRF
			TRF->( DBCLOSEAREA() ) 
			
			TRE->(dbSkip())    
		
		ENDDO //end do while 
		TRE->( DBCLOSEAREA() )  
		
		TRD->(dbSkip())    
	
	ENDDO //end do while 
	TRD->( DBCLOSEAREA() )   
	// *** FINAL MONTAR CONTA CORRENTE TABELA TEMPORARIA *** //
	
	SqlGeral() 
	ProcRegua(Contar("TRB","!Eof()") * 2)
	DBSELECTAREA("TRB")
	TRB->(DBGOTOP())
	cNumOld    := TRB->NUMERO
	cItemOld   := TRB->ITEM
	nSaldoPed  := 0
	nSaldoVal  := 0
	nSaldoNot  := 0
	nLinIni    := 1
	nLinFin    := 0
	WHILE TRB->(!EOF())
	
		IncProc("Criando Excel - Produto: " + TRB->PRODUTO + " Item: " + TRB->ITEM)
	
		IF TRB->NUMERO == cNumOld .AND. ;
		   TRB->ITEM   == cItemOld
		     
           nLinFin := nLinFin + 1
		   nLinha  := nLinha + 1 
	
	        //===================== INICIO CRIA VETOR COM POSICAO VAZIA 
		   	LINHAEMBRANCO()
			//===================== FINAL CRIA VETOR COM POSICAO VAZIA
			
			//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================
			SOMASALDOS()
			aLinhas[nLinha][01] := IF(ALLTRIM(TRB->DATAEMIS) <> '',STOD(TRB->DATAEMIS), '') //A
			aLinhas[nLinha][02] := TRB->RESIDUO                                             //B
			aLinhas[nLinha][03] := TRB->NUMERO                                              //C
			aLinhas[nLinha][04] := TRB->DOC                                                 //D
			aLinhas[nLinha][05] := TRB->ITEM                                                //E
			aLinhas[nLinha][06] := TRB->PRODUTO                                             //F
			aLinhas[nLinha][07] := TRB->DESCPROD                                            //G
			aLinhas[nLinha][08] := TRB->TABELA                                              //H
			aLinhas[nLinha][09] := TRB->TIPO                                                //I
			aLinhas[nLinha][10] := TRB->QTD                                                 //J
			aLinhas[nLinha][11] := TRB->QTDUSADA                                            //K
			aLinhas[nLinha][12] := TRB->QTDDEV                                              //L
			aLinhas[nLinha][13] := TRB->QTD_PEDI                                            //M
			aLinhas[nLinha][14] := TRB->VLICM                                               //N
			aLinhas[nLinha][15] := TRB->VLIPI                                               //O
			aLinhas[nLinha][16] := TRB->VLPIS                                               //P
			aLinhas[nLinha][17] := TRB->VLCOFINS                                            //Q
			aLinhas[nLinha][18] := TRB->VLDESPESA                                           //R
			aLinhas[nLinha][19] := TRB->VLUNIT                                              //S
			aLinhas[nLinha][20] := TRB->TOTAL                                               //T
			aLinhas[nLinha][21] := nSaldoPed              									//U
			aLinhas[nLinha][22] := nSaldoNot              									//V
			aLinhas[nLinha][23] := nSaldoVal              									//W
			aLinhas[nLinha][24] := ""                                                       //X
			aLinhas[nLinha][25] := ""                                                       //Y
			aLinhas[nLinha][26] := ""                                                       //Z
			
			IF TRB->TABELA == 'SC7'
			
				cProd2   := TRB->PRODUTO
				nVlUnit  := TRB->VLUNIT
				cNomeFor := TRB->NOMEFORNE
				nVlPed   := nVlPed + TRB->TOTAL
			
			ENDIF
			
			IF TRB->TABELA == 'SD2'
			
				nVlDev := nVlDev + TRB->TOTAL
			
			ENDIF
			
			IF TRB->TABELA == 'SD1'
			
				nVlNota := nVlNota + TRB->TOTAL
			
			ENDIF
									
			//======================================= FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===================
		
		ELSE
		
			nLinFin := nLinFin + 1
			nLinha  := nLinha + 1 
			//===================== INICIO CRIA VETOR COM POSICAO VAZIA 
			LINHAEMBRANCO()
			//===================== FINAL CRIA VETOR COM POSICAO VAZIA
			
			//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================
			LINHATOTAL(cNumOld,cItemOld,cProd2,nVlUnit,cNomeFor,nVlPed,nVlDev,nVlNota)
			//======================================= FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===================
			
			// *** FINAL MOSTRA TOTAL *** //
			
			// *** INICIO MARCA TODOS DAQUELE PEDIDO E ITEM COM NOK OU OK
			FOR nCont := nLinIni TO (nLinFin - 1)
			
				aLinhas[nCont][24] := aLinhas[nLinha][24]
			
			NEXT
			
			// *** FINAL MARCA TODOS DAQUELE PEDIDO E ITEM COM NOK OU OK
						
			nLinFin := nLinFin + 1
			nLinIni := nLinFin
			nLinha  := nLinha + 1 
	
	        //===================== INICIO CRIA VETOR COM POSICAO VAZIA 
		   	LINHAEMBRANCO()
			//===================== FINAL CRIA VETOR COM POSICAO VAZIA
			
			//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================
			nSaldoPed := 0
			nSaldoNot := 0
			nSaldoVal := 0
			SOMASALDOS()
			aLinhas[nLinha][01] := IF(ALLTRIM(TRB->DATAEMIS) <> '',STOD(TRB->DATAEMIS), '') //A
			aLinhas[nLinha][02] := TRB->RESIDUO                                             //B
			aLinhas[nLinha][03] := TRB->NUMERO                                              //C
			aLinhas[nLinha][04] := TRB->DOC                                                 //D
			aLinhas[nLinha][05] := TRB->ITEM                                                //E
			aLinhas[nLinha][06] := TRB->PRODUTO                                             //F
			aLinhas[nLinha][07] := TRB->DESCPROD                                            //G
			aLinhas[nLinha][08] := TRB->TABELA                                              //H
			aLinhas[nLinha][09] := TRB->TIPO                                                //I
			aLinhas[nLinha][10] := TRB->QTD                                                 //J
			aLinhas[nLinha][11] := TRB->QTDUSADA                                            //K
			aLinhas[nLinha][12] := TRB->QTDDEV                                              //L
			aLinhas[nLinha][13] := TRB->QTD_PEDI                                            //M
			aLinhas[nLinha][14] := TRB->VLICM                                               //N
			aLinhas[nLinha][15] := TRB->VLIPI                                               //O
			aLinhas[nLinha][16] := TRB->VLPIS                                               //P
			aLinhas[nLinha][17] := TRB->VLCOFINS                                            //Q
			aLinhas[nLinha][18] := TRB->VLDESPESA                                           //R
			aLinhas[nLinha][19] := TRB->VLUNIT                                              //S
			aLinhas[nLinha][20] := TRB->TOTAL                                               //T
			aLinhas[nLinha][21] := nSaldoPed              									//U
			aLinhas[nLinha][22] := nSaldoNot              									//V
			aLinhas[nLinha][23] := nSaldoVal              									//W
			aLinhas[nLinha][24] := ""                                                       //X
			aLinhas[nLinha][25] := ""                                                       //Y
			aLinhas[nLinha][26] := ""                                                       //Z
			
			//======================================= FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===================
			
			cNumOld   := TRB->NUMERO
		    cItemOld  := TRB->ITEM
		    nVlPed    := 0
		    nVlDev    := 0
		    nVlNota   := 0
		    
		    IF TRB->TABELA == 'SC7'
			
				cProd2   := TRB->PRODUTO
				nVlUnit  := TRB->VLUNIT
				cNomeFor := TRB->NOMEFORNE
				nVlPed   := nVlPed + TRB->TOTAL
			
			ENDIF
			
			IF TRB->TABELA == 'SD2'
			
				nVlDev := nVlDev + TRB->TOTAL
			
			ENDIF
			
			IF TRB->TABELA == 'SD1'
			
				nVlNota := nVlNota + TRB->TOTAL
			
			ENDIF
					
		ENDIF
			
		TRB->(dbSkip())    
	
	ENDDO //end do while TRB
	TRB->( DBCLOSEAREA() )   
	
	// *** INICIO MOSTRA TOTAL *** //
	
	nLinFin := nLinFin + 1
	nLinha  := nLinha + 1                                       
	
    //===================== INICIO CRIA VETOR COM POSICAO VAZIA 
	LINHAEMBRANCO()
	//===================== FINAL CRIA VETOR COM POSICAO VAZIA
	
	//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================
	LINHATOTAL(cNumOld,cItemOld,cProd2,nVlUnit,cNomeFor,nVlPed,nVlDev,nVlNota)
	
	// *** INICIO MARCA TODOS DAQUELE PEDIDO E ITEM COM NOK OU OK
		FOR nCont := nLinIni TO (nLinFin - 1)
		
			aLinhas[nCont][24] := aLinhas[nLinha][24]
		
		NEXT
		
	// *** FINAL MARCA TODOS DAQUELE PEDIDO E ITEM COM NOK OU OK
	
	//======================================= FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===================
	
	// *** FINAL MOSTRA TOTAL *** //
	
	//============================== INICIO IMPRIME LINHA NO EXCEL
	FOR nExcel := 1 TO nLinha
	
		IncProc("Imprindo Excel: " + CVALTOCHAR(nExcel) + '/' + CVALTOCHAR(nLinha))
		
		IF MV_PAR05 == 2 // 'Somente P.C. Divergentes? == SIM'
		
			IF aLinhas[nExcel][24] == 'NOK'
		
			   	oExcel:AddRow(cPlanilha,cTitulo,{aLinhas[nExcel][01],; // 01 A  
				                                 aLinhas[nExcel][02],; // 02 B  
				                                 aLinhas[nExcel][03],; // 03 C  
				                                 aLinhas[nExcel][04],; // 04 D  
				                                 aLinhas[nExcel][05],; // 05 E  
				                                 aLinhas[nExcel][06],; // 06 F  
				                                 aLinhas[nExcel][07],; // 07 G 
				                                 aLinhas[nExcel][08],; // 08 H  
				                                 aLinhas[nExcel][09],; // 09 I  
				                                 aLinhas[nExcel][10],; // 10 J
				                                 aLinhas[nExcel][11],; // 11 K
				                                 aLinhas[nExcel][12],; // 12 L
				                                 aLinhas[nExcel][13],; // 13 M
				                                 aLinhas[nExcel][14],; // 14 N
				                                 aLinhas[nExcel][15],; // 15 O
				                                 aLinhas[nExcel][16],; // 16 P
				                                 aLinhas[nExcel][17],; // 17 Q
				                                 aLinhas[nExcel][18],; // 18 R
				                                 aLinhas[nExcel][19],; // 19 S
				                                 aLinhas[nExcel][20],; // 20 T
				                                 aLinhas[nExcel][21],; // 21 U
				                                 aLinhas[nExcel][22],; // 22 V
				                                 aLinhas[nExcel][23],; // 23 W
				                                 aLinhas[nExcel][24],; // 24 X
				                                 aLinhas[nExcel][25],; // 25 Y
				                                 aLinhas[nExcel][26] ; // 26 Z
				                                                    }) //GRAVANDO NA LINHA MANDANDO PARA O EXCEL O ARRAY COM AS LINHAS
	       ENDIF
	  ELSE
	  
	  	oExcel:AddRow(cPlanilha,cTitulo,{aLinhas[nExcel][01],; // 01 A  
		                                 aLinhas[nExcel][02],; // 02 B  
		                                 aLinhas[nExcel][03],; // 03 C  
		                                 aLinhas[nExcel][04],; // 04 D  
		                                 aLinhas[nExcel][05],; // 05 E  
		                                 aLinhas[nExcel][06],; // 06 F  
		                                 aLinhas[nExcel][07],; // 07 G 
		                                 aLinhas[nExcel][08],; // 08 H  
		                                 aLinhas[nExcel][09],; // 09 I  
		                                 aLinhas[nExcel][10],; // 10 J
		                                 aLinhas[nExcel][11],; // 11 K
		                                 aLinhas[nExcel][12],; // 12 L
		                                 aLinhas[nExcel][13],; // 13 M
		                                 aLinhas[nExcel][14],; // 14 N
		                                 aLinhas[nExcel][15],; // 15 O
		                                 aLinhas[nExcel][16],; // 16 P
		                                 aLinhas[nExcel][17],; // 17 Q
		                                 aLinhas[nExcel][18],; // 18 R
		                                 aLinhas[nExcel][19],; // 19 S
		                                 aLinhas[nExcel][20],; // 20 T
		                                 aLinhas[nExcel][21],; // 21 U
		                                 aLinhas[nExcel][22],; // 22 V
		                                 aLinhas[nExcel][23],; // 23 W
		                                 aLinhas[nExcel][24],; // 24 X
		                                 aLinhas[nExcel][25],; // 25 Y
		                                 aLinhas[nExcel][26] ; // 26 Z
		                                                    }) //GRAVANDO NA LINHA MANDANDO PARA O EXCEL O ARRAY COM AS LINHAS
         
      ENDIF		                                                    
    NEXT 
    //============================== FINAL IMPRIME LINHA NO EXCEL
    
    //---------------------------------
	//Exclui a tabela Temporária
	//---------------------------------
	oTempTable:Delete()
 	
Return() 

Static Function SqlPedidoCompra()

	Local cFilOrig := FWxFILIAL("SC7")  
	Local cDataIni := DTOS(MV_PAR03)
	Local cDataFin := DTOS(MV_PAR04)
     
    BeginSQL Alias "TRD"
			%NoPARSER%  
			SELECT C7_EMISSAO,
			       C7_FILIAL+C7_NUM+C7_PRODUTO+C7_ITEM AS CHAVE,
				   'SC7' AS TABELA,
				   'PEDIDO DE COMPRA' AS TIPO,
				   C7_QUANT, 
				   C7_QUJE,
				   0 AS QTD_DEV,
				   0 AS QTD_PEDI,
				   C7_TOTAL,
				   C7_RESIDUO,
				   C7_FILIAL,
				   C7_NUM,
				   C7_PRODUTO,
				   C7_ITEM,
				   C7_FORNECE,
				   C7_LOJA,
				   C7_PRECO,
				   A2_NOME 
			  FROM %TABLE:SC7% WITH (NOLOCK) 
	    INNER JOIN %TABLE:SA2%
			    ON A2_COD                  = C7_FORNECE
			   AND A2_LOJA                 = C7_LOJA
			   AND A2_EST                 <> 'EX'
			   AND %TABLE:SA2%.D_E_L_E_T_ <> '*'
			 WHERE C7_FILIAL              = %EXP:cFilOrig%
			   AND C7_NUM                 >= %EXP:MV_PAR01%
			   AND C7_NUM                 <= %EXP:MV_PAR02%
			   AND C7_EMISSAO             >= %EXP:cDataIni%
			   AND C7_EMISSAO             <= %EXP:cDataFin%
			   AND C7_MOEDA                = '1'
			   AND C7_QUJE     			   > 0 
			   AND %TABLE:SC7%.D_E_L_E_T_ <> '*'
   
	EndSQl
RETURN()

Static Function SqlNFEntrada(cNum,cProd,cItem,cFornece,cLoja)

	Local cFilOrig := FWxFILIAL("SD1")  
     
    BeginSQL Alias "TRE"
			%NoPARSER%
            SELECT D1_DTDIGIT,
			       D1_FILIAL+D1_PEDIDO+D1_COD+D1_ITEMPC+D1_FORNECE+D1_LOJA AS CHAVE,
				   'SD1' AS TABELA,
				   'NF ENTRADA' AS TIPO,
				   D1_QUANT, 
				   0 QTDUSADA,
				   D1_QTDEDEV AS QTD_DEV,
				   D1_QTDPEDI AS QTD_PEDI,
				   D1_TOTAL,
				   D1_FILIAL,
				   D1_PEDIDO,
				   D1_ITEMPC,
				   D1_FORNECE,
				   D1_LOJA,
				   D1_DOC,
				   D1_SERIE,
				   D1_COD,
				   D1_ITEM,
				   D1_VUNIT,
				   D1_VALICM,
				   D1_VALIPI,
				   D1_VALIMP6,
				   D1_VALIMP5
			  FROM %TABLE:SD1%  WITH (NOLOCK)
			 WHERE D1_FILIAL   = %EXP:cFilOrig%
			   AND D1_PEDIDO   = %EXP:cNum%
			   AND D1_COD      = %EXP:cProd%
			   AND D1_ITEMPC   = %EXP:cItem%
			   AND D1_FORNECE  = %EXP:cFornece%
			   AND D1_LOJA     = %EXP:cLoja%
			   AND D_E_L_E_T_ <> '*' 
			ORDER BY R_E_C_N_O_
  
	EndSQl
RETURN()

Static Function SqlNFSaida(cNum,cSerie,cProd,cItem,cFornece,cLoja)

	Local cFilOrig := FWxFILIAL("SD1")  
     
    BeginSQL Alias "TRF"
			%NoPARSER%
            SELECT D2_EMISSAO,
			       D2_FILIAL+D2_NFORI+D2_SERIORI+D2_COD+D2_ITEMORI+D2_CLIENTE+D2_LOJA AS CHAVE,
				   'SD2' AS TABELA,
				   'NF DEVOLUCAO' AS TIPO,
				   D2_QUANT, 
				   0 AS QTDUSADA,
				   0 AS QTD_DEV,
				   0 AS QTD_PEDI,
				   D2_PRCVEN,
				   D2_TOTAL,
				   D2_DOC
			  FROM %TABLE:SD2%  WITH (NOLOCK)
			   WHERE D2_FILIAL   = %EXP:cFilOrig%
			     AND D2_NFORI    = %EXP:cNum%
				 AND D2_SERIORI  = %EXP:cSerie%
				 AND D2_COD      = %EXP:cProd%
				 AND D2_ITEMORI  = %EXP:cItem%
				 AND D2_CLIENTE  = %EXP:cFornece%
	             AND D2_LOJA     = %EXP:cLoja%
				 AND D_E_L_E_T_ <> '*'
			ORDER BY R_E_C_N_O_
  
	EndSQl
RETURN()

Static Function SqlGeral()

	Local cQuery1 := ''
	
	cQuery1 := " SELECT * "
	cQuery1 += "   FROM " + oTempTable:GetRealName() + " WITH (NOLOCK) " 
	cQuery1 += " ORDER BY  NUMERO,ITEM,DATAEMIS,TABELA"
			 
	MPSysOpenQuery( cQuery1, 'TRB' )
	
RETURN()

Static Function SalvaXml()

	oExcel:Activate()
	oExcel:GetXMLFile("C:\temp\REL_PED_COM_CORRENTE.XML")

Return()

Static Function CriaExcel()              

    oMsExcel := MsExcel():New()
	oMsExcel:WorkBooks:Open("C:\temp\REL_PED_COM_CORRENTE.XML")
	oMsExcel:SetVisible( .T. )
	oMsExcel := oMsExcel:Destroy()

Return() 

Static Function MontaPerg() 
                                 
	Private bValid	:=Nil 
	Private cF3		:=Nil
	Private cSXG	:=Nil
	Private cPyme	:=Nil
	
    u_xPutSx1(cPerg,'01','Pedido Compra Ini       ?','','','mv_ch1','C',06,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR01')
	u_xPutSx1(cPerg,'02','Pedido Compra Fin       ?','','','mv_ch2','C',06,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR02')
	u_xPutSx1(cPerg,'03','Data          Ini       ?','','','mv_ch3','D',08,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR03')
	u_xPutSx1(cPerg,'04','Data          Fin       ?','','','mv_ch4','D',08,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR04')
	u_xPutSx1(cPerg,"05","Somente P.C. Divergentes?",'','','mv_ch5',"N",1 ,0,1,"C",bValid,cF3,cSXG,cPyme,'MV_PAR05',"Não","Não","Não","1","Sim","Sim","Sim","","","","","","","","","")
		
	Pergunte(cPerg,.F.)
Return Nil

STATIC FUNCTION LINHAEMBRANCO()

	AADD(aLinhas,{ "", ; // 01 A  
   	               "", ; // 02 B   
   	               "", ; // 03 C  
   	               "", ; // 04 D  
   	               "", ; // 05 E  
   	               "", ; // 06 F
   	               "", ; // 07 G
   	               "", ; // 08 H
   	               "", ; // 09 I   
   	                0, ; // 10 J 
   	                0, ; // 11 K   
   	                0, ; // 12 L  
   	                0, ; // 13 M
   	                0, ; // 14 N
   	                0, ; // 15 O
   	                0, ; // 16 P
   	                0, ; // 17 Q
   	                0, ; // 18 R
   	                0, ; // 19 S
   	                0, ; // 20 T
   	                0, ; // 21 U
   	                0, ; // 22 V
   	                0, ; // 23 W
   	                0, ; // 24 X
   	                0, ; // 25 Y
   	               ""  ; // 26 Z
   	                   })

RETURN(NIL)

STATIC FUNCTION LINHATOTAL(cNumOld,cItemOld,cProd2,nVlUnit,cNomeFor,nVlPed,nVlDev,nVlNota)

	Local nDifVlUnit := 0
	
	nDifVlUnit := ROUND((nSaldoNot - nQtdResi2) * nVlUnit,2)

	aLinhas[nLinha][01] := 'TOTAL '               //A
	aLinhas[nLinha][02] := ''                     //B
	aLinhas[nLinha][03] := cNumOld                //C
	aLinhas[nLinha][04] := ''                     //D
	aLinhas[nLinha][05] := cItemOld               //E
	aLinhas[nLinha][06] := cProd2                 //F
	aLinhas[nLinha][07] := cNomeFor               //G
	aLinhas[nLinha][08] := ''                     //H
	aLinhas[nLinha][09] := ''                     //I
	aLinhas[nLinha][10] := ''                     //J
	aLinhas[nLinha][11] := ''                     //K
	aLinhas[nLinha][12] := nVlDev                 //L
	aLinhas[nLinha][13] := ''                     //M
	aLinhas[nLinha][14] := ''                     //N
	aLinhas[nLinha][15] := ''                     //O
	aLinhas[nLinha][16] := ''                     //P
	aLinhas[nLinha][17] := ''                     //Q
	aLinhas[nLinha][18] := nVlPed                 //R
	aLinhas[nLinha][19] := nVlUnit                //S
	aLinhas[nLinha][20] := nVlNota                //T
	aLinhas[nLinha][21] := nSaldoPed              //U
	aLinhas[nLinha][22] := nSaldoNot - nQtdResi2  //V
	aLinhas[nLinha][23] := nSaldoVal              //W
	aLinhas[nLinha][24] := IIF(nSaldoPed < 0 .OR. nSaldoNot < 0 .OR. (nSaldoVal + GETMV("MV_#VLTOTN")) < 0, 'NOK', 'OK') //X
	aLinhas[nLinha][25] := nDifVlUnit             //Y
	aLinhas[nLinha][26] := IIF(nDifVlUnit == nSaldoVal , 'OK', 'NOK') //Z
	

RETURN(NIL)
                                
Static Function Cabec() 

    oExcel:AddworkSheet(cPlanilha)
	oExcel:AddTable (cPlanilha,cTitulo)
    oExcel:AddColumn(cPlanilha,cTitulo,"DATA "                        ,1,1) // 01 A
    oExcel:AddColumn(cPlanilha,cTitulo,"RESIDUO "                     ,1,1) // 02 B
	oExcel:AddColumn(cPlanilha,cTitulo,"NUM PED COM "                 ,1,1) // 03 C
	oExcel:AddColumn(cPlanilha,cTitulo,"NUM NOTA "                    ,1,1) // 04 D
	oExcel:AddColumn(cPlanilha,cTitulo,"ITEM PED"                     ,1,1) // 05 E
	oExcel:AddColumn(cPlanilha,cTitulo,"PRODUTO "                     ,1,1) // 06 F
	oExcel:AddColumn(cPlanilha,cTitulo,"DESC PROD /NOME FORNEC"       ,1,1) // 07 G
	oExcel:AddColumn(cPlanilha,cTitulo,"TABELA "                      ,1,1) // 08 H
	oExcel:AddColumn(cPlanilha,cTitulo,"TIPO "                        ,1,1) // 09 I
	oExcel:AddColumn(cPlanilha,cTitulo,"QTD PED/NOTA"                 ,1,1) // 10 J
	oExcel:AddColumn(cPlanilha,cTitulo,"QTD USADA PED"                ,1,1) // 11 K
	oExcel:AddColumn(cPlanilha,cTitulo,"QTD DEV NF / VL TOTAL DEV"    ,1,1) // 12 L
	oExcel:AddColumn(cPlanilha,cTitulo,"QTD PED NA NF "               ,1,1) // 13 M
	oExcel:AddColumn(cPlanilha,cTitulo,"VL ICM "                      ,1,1) // 14 N
	oExcel:AddColumn(cPlanilha,cTitulo,"VL IPI "                      ,1,1) // 15 O
	oExcel:AddColumn(cPlanilha,cTitulo,"VL PIS "                      ,1,1) // 16 P
	oExcel:AddColumn(cPlanilha,cTitulo,"VL COFINS "                   ,1,1) // 17 Q
	oExcel:AddColumn(cPlanilha,cTitulo,"TOTAL DESPESA / VL TOTAL PED" ,1,1) // 18 R
	oExcel:AddColumn(cPlanilha,cTitulo,"VALOR UNIT"                   ,1,1) // 19 S
	oExcel:AddColumn(cPlanilha,cTitulo,"VALOR TOTAL"                  ,1,1) // 20 T
	oExcel:AddColumn(cPlanilha,cTitulo,"SALDO PED "                   ,1,1) // 21 U
	oExcel:AddColumn(cPlanilha,cTitulo,"SALDO NOTA "                  ,1,1) // 22 V
	oExcel:AddColumn(cPlanilha,cTitulo,"SALDO VL "                    ,1,1) // 23 W
	oExcel:AddColumn(cPlanilha,cTitulo,"STATUS "                      ,1,1) // 24 X
	oExcel:AddColumn(cPlanilha,cTitulo,"DIF VL UNIT / QUANT "         ,1,1) // 25 Y
	oExcel:AddColumn(cPlanilha,cTitulo,"STATUS DIFERENCA "            ,1,1) // 26 Z
	
RETURN(NIL)

STATIC FUNCTION BUSCADESPESA(cfilatu,cDoc,cSerie,cFornece,cLoja)

	nValor := 0
	
	BeginSQL Alias "TRG"
			%NoPARSER%
			SELECT F1_FRETE,
			       F1_DESPESA,
			       F1_SEGURO,
			       F1_DESCONT
			  FROM %TABLE:SF1%  WITH (NOLOCK)
			 WHERE F1_FILIAL   = %EXP:cfilatu%
			   AND F1_DOC      = %EXP:cDoc%
			   AND F1_SERIE    = %EXP:cSerie%
			   AND F1_FORNECE  = %EXP:cFornece%
			   AND F1_LOJA     = %EXP:cLoja%
			   AND D_E_L_E_T_ <> '*'
			ORDER BY R_E_C_N_O_
  
	EndSQl
	
	DBSELECTAREA("TRG")
	TRG->(DBGOTOP())
	WHILE TRG->(!EOF())
	    	
	    nValor := (TRG->F1_FRETE + TRG->F1_DESPESA + TRG->F1_SEGURO) - TRG->F1_DESCONT 
	    		
		TRG->(dbSkip())    
	
	ENDDO //end do while TRG
	TRG->( DBCLOSEAREA() )
	

RETURN(nValor)

STATIC FUNCTION SOMASALDOS()

	IF TRB->TABELA == 'SC7'
			
		nSaldoPed := nSaldoPed + TRB->QTDUSADA
	    nSaldoNot := nSaldoNot + TRB->QTD
	    nSaldoVal := nSaldoVal + TRB->TOTAL
	    
	ELSEIF TRB->TABELA == 'SD1'
	
		nQtdResi2 := 0
		nSaldoPed := nSaldoPed - TRB->QTD_PEDI
		nSaldoNot := nSaldoNot - TRB->QTD
		nSaldoVal := nSaldoVal - TRB->TOTAL
		nQtdResi2 := TRB->QTDRESID
	    
	ELSE
	
		nSaldoPed := nSaldoPed + TRB->QTD
		nSaldoNot := nSaldoNot + TRB->QTD
		nSaldoVal := nSaldoVal + TRB->TOTAL
		
	ENDIF 
	
RETURN(NIL)