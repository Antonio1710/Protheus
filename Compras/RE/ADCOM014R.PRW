#Include 'Protheus.ch'
#Include 'FwMvcDef.ch'
#Include 'Parmtype.ch'
#Include "Topconn.ch"


#DEFINE POS_FORNECEDOR 6

//+--------ย---------------+-----ย-------------------------------+----+----------+
//|Programa| COTABOM       |Autor| DANIEL PITTHAN SILVEIRA       |Data| 31.05.10 |
//+--------ล---------------+-----ม-------------------------------+----+----------+
//|Descric.| Monta analise de cotacao em uma tabela cruzada                      |
//|        |                                                                     |
//|        |                             |           Total do Fornec.            |
//|        |Produto Quantidade Descricao Fornecedor 01 Fornecedor 02 Fornecedor n|
//|        |203010  100        zzzz       10.00         11.00     xx.00          |
//|        |203011  150        zzzz       25.00         22.00     xx.00          |
//|        |                                                                     |
//+--------+---------------------+-----------------------------------------------+
//|Modulo  | Financeiro          |Tipo | [X]Transacao   		[ ]Relatorio     |
//|        |                     |     | [ ]Processamento       [ ]Validacao     |
//|        |                     |     | [ ]Ponto de Entrada    [ ]Gatilho       |
//+--------+---------------------+-----+-----------------------------------------+ 
//|Bops    | Autor               | Data     | Descricao                          |
//+--------+---------------------+----------+------------------------------------+
//|        |                     |          |                                    |
//|        |                     |          |                                    |
//|        |                     |          |                                    |
//+--------+---------------------+----------+------------------------------------+


USER FUNCTION ADCOM014P()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ                                 DECLARACAO DE VARIAVEIS                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private lShowDlg	:=.T.				//Define se exibe Dialogo ou Nao
Private cNum		:=SC8->C8_NUM		//Numero da Cotacao 
Private aItCheap	:={}				//Itens Mais Baratos    
Private aTpFrete	:={}
Private aButtons	:={	{'COLFORM',{|| SomaTudo()},"Soma","Soma"},;
						{"Excel",{|| DlgToExcel({{"GETDADOS","Previsao de Cotacao: "+cNum,oGetD:aHeader,oGetD:aCols}})} ,"Exp. Excel","Exp. Excel"} }
Private cPerg		:="COTABOM"

//+-------------------------------------+
//|MsNewGetDados                        |
//+-------------------------------------+
Private nStyle		:= GD_UPDATE		//GD_INSERT + GD_UPDATE + GD_DELETE
Private cLinOk 		:= "AllwaysTrue"	//Funcao executada para validar o contexto da linha atual do aCols
Private cTudoOk 	:= "AllwaysTrue"	//Funcao executada para validar o contexto geral da MsNewGetDados 
Private cIniCpos 	:= "" 	 			//Nome dos campos do tipo caracter que utilizarใo incremento automแtico
Private aAlterGDa 	:= {}              	//Vetor com os campos que poderใo ser alterados
Private nFreeze 	:= (POS_FORNECEDOR-1)//Indica qual coluna ficarแ congelada na exibi็ใo
Private nMax 		:= 999  			//NUmero maximo de linhas permitidas. Valor padrใo 99
Private cFieldOk 	:= "AllwaysTrue"  	//Funcao executada na valida็ใo do campo
Private cSuperDel 	:= "" 				//Fun็ใo executada quando pressionada as teclas <Ctrl>+<Delete>
Private cDelOk 		:= "AllwaysTrue" 	//Funcao executada para validar a exclusใo de uma linha do aCols
Private aHeader 	:= {}
Private aCols 		:= {}  
Private nUsado		:= 0
Private oGetD							//Objeto do MsNewgetDados
Private oScrollB1                      	//Objeto do Scroll Box

//+-------------------------------------+
//|Acols e aHeaders                     |
//+-------------------------------------+
Private nPosFor		:=0					//Posicao do aHeader do fornecedor     
Private nPosProd	:=0					//Posicao do aHeader do Cod. Prod
Private nPosProd2	:=0					//Posicao do aHeader do Cod. Prod
Private nPosQtd		:=0					//Posicao do aHeader do Quantidade 
Private nPosDesc    :=0					//Posicao do aHeader da descricao ddo Produto
Private nPosPrc		:=0					//Ultimo preco de compra
Private nPosEmiss	:=0                 //Data do ultimo preco de compra
Private cCodFor		:=''				//Cod do Fornecedor

//+-------------------------------------+
//|Ambiente                             |
//+-------------------------------------+
Private X3TITULO	:=''
Private X3CAMPO		:=''
Private X3PICTURE	:=''
Private X3TAMANHO	:=0
Private X3DECIMAL	:=0
Private X3USADO		:=''
Private X3TIPO		:=''
Private X3ARQUIVO	:=''
Private X3CONTEXT	:=''


Private FILSB1		:=xFilial('SB1')
Private FILSA2		:=xFilial('SA2')

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

                       
//+------------------------------------------------------+
//|Monta Grupo de Perguntas                              |
//+------------------------------------------------------+
MontaPerg(cPerg)                                        



//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta aHeader compostos de varias tabelas                                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

//+-------------------------------------------------+
//|Adciona o Codigo do Produto guarda dados do total|
//+-------------------------------------------------+
dbSelectArea("SX3")
DBGOTOP()
DBSETORDER(1)
dbSeek("SC8")  
 
While !Eof().And.(X3_ARQUIVO=='SC8')	
	If  ALLTRIM(X3_CAMPO)=='C8_PRODUTO'  
		nUsado:=nUsado+1
		AADD(aHeader,{ TRIM(X3_titulo), X3_campo, X3_picture,;
			X3_tamanho, X3_decimal,"AllwaysTrue()",;
			X3_usado, X3_tipo, X3_arquivo, X3_context } )  
	Endif  	      
	
	
	//+---------------------------------------------------------------------+
	//|Guarda os dados do fornecedor para montar as colunas de fornecedores |
	//+---------------------------------------------------------------------+
	IF ALLTRIM(X3_CAMPO)=='C8_TOTAL' 
		X3TITULO	:=X3_TITULO
		X3CAMPO		:=X3_CAMPO
		X3PICTURE	:=X3_PICTURE
		X3TAMANHO	:=X3_TAMANHO
		X3DECIMAL	:=X3_DECIMAL
		X3USADO		:=X3_USADO
		X3TIPO		:=X3_TIPO
		X3ARQUIVO	:=X3_ARQUIVO
		X3CONTEXT	:=X3_CONTEXT
	ENDIF
	
	dbSkip()
End

                                                     
//+-------------------------------------------------+
//|Adciona a Descricao do Produto                   |
//+-------------------------------------------------+
dbSelectArea("SX3")
DBGOTOP()
DBSETORDER(1)
dbSeek("SB1")  
While !Eof().And.(X3_ARQUIVO=='SB1')	
	If  ALLTRIM(X3_CAMPO)=='B1_DESC' 
		nUsado:=nUsado+1
		AADD(aHeader,{ TRIM(X3_titulo), X3_campo, X3_picture,;
			X3_tamanho, X3_decimal,"AllwaysTrue()",;
			X3_usado, X3_tipo, X3_arquivo, X3_context } )  
	Endif  	      	
	dbSkip()
End        
  

//+-------------------------------------------------+
//|Adciona a Quantidade da Cotacao                  |
//+-------------------------------------------------+
dbSelectArea("SX3")
DBGOTOP()
DBSETORDER(1)
dbSeek("SC8")  
While !Eof().And.(X3_ARQUIVO=='SC8')
	
	If  ALLTRIM(X3_CAMPO)=='C8_QUANT' .OR. ; 
	    ALLTRIM(X3_CAMPO)=='C8_XULPRC' .OR. ;
	    ALLTRIM(X3_CAMPO)=='C8_EMISSAO'
	    
		nUsado:=nUsado+1
		AADD(aHeader,{ TRIM(X3_titulo), X3_campo, X3_picture,;
			X3_tamanho, X3_decimal,"AllwaysTrue()",;
			X3_usado, X3_tipo, X3_arquivo, X3_context } )
			  
	Endif  	      	
	dbSkip()
End     


//+-------------------------------------------------+
//|Adciona os codigos dos fornecedores              |
//+-------------------------------------------------+
BEGINSQL ALIAS 'TRBA'
	SELECT C8_FORNECE,C8_TPFRETE 
	FROM %Table:SC8% as C8
	WHERE C8_NUM=%Exp:cNum%
	AND C8.%NotDel%
	AND C8_FILIAL=%Exp:xFilial("SC8")%
	GROUP BY C8_FORNECE, C8_TPFRETE
ENDSQL  
DbselectArea('TRBA')
DbGotop() 

While !Eof()	
		 
		//Monta/guarda o Tipo de Frete por fornecedor
		IF aScan(aTpFrete,{|x| ALLTRIM(x[1])==C8_FORNECE})==0   
			AADD(aTpFrete,{C8_FORNECE,C8_TPFRETE})
		EndIf
		
		AADD(aHeader,{ TRIM(C8_FORNECE), X3campo, X3picture,;
			X3tamanho, X3decimal,"AllwaysTrue()",;
			X3usado, X3tipo, "", X3context } )  
			
			nUsado:=nUsado+1 
	Dbskip()
End     


//+-----------------------------------------------------------+
//|Fecha Alias                                                |
//+-----------------------------------------------------------+
TRBA->(DbCloseArea()) 
   
    
//+-----------------------------------------------------------+
//|Adciona a Linha dos Itens Mais Baratos                     |
//+-----------------------------------------------------------+
AADD(aHeader,{ "Itens Mais Baratos", X3campo, X3picture,;
		X3tamanho, X3decimal,"AllwaysTrue()",;
		X3usado, X3tipo, "", X3context } )  
		
nUsado:=nUsado+1             


//Campos que podem ser alterados	
Aadd(aAlterGDa,X3campo)



//+-----------------------------------------------------------+
//|Grava as posicoes do aHeader para perfeita gravacao        |
//|do Acols                                                   |
//+-----------------------------------------------------------+
nPosProd :=aScan(aHeader,{|x| ALLTRIM(x[2])=='C8_PRODUTO'})   
nPosQtd  :=aScan(aHeader,{|x| ALLTRIM(x[2])=='C8_QUANT'})
nPosDesc :=aScan(aHeader,{|x| ALLTRIM(x[2])=='B1_DESC'})
nPosPrc  :=aScan(aHeader,{|x| ALLTRIM(x[2])=='C8_XULPRC'})
nPosEmiss:=aScan(aHeader,{|x| ALLTRIM(x[2])=='C8_EMISSAO'})

		

//+-----------------------------------------------------------+
//|Carrega acols                                              |
//+-----------------------------------------------------------+ 
DbSelectArea("SC8");DbsetOrder(1)
dbSeek(xFilial("SC8")+SC8->C8_NUM)
While !eof() .and. SC8->C8_NUM==cNum    
       
		//+-----------------------------------------------------------+
		//|Veririfica se o produto ja existe no array                 |
		//+-----------------------------------------------------------+
		IF aScan(aCols,{|x| ALLTRIM(x[nPosProd])==ALLTRIM(SC8->C8_PRODUTO)}) ==0     
			//+-----------------------------------------------------------+
			//|Cria a 1a Linha Vazia                                      |  
			//+-----------------------------------------------------------+
			AADD(aCols,Array(nUsado+1))  
			
			                                                               
			//+-----------------------------------------------------------+
			//|Grava o codigo do Produto                                  |
			//+-----------------------------------------------------------+
			aCols[Len(aCols),nPosProd]	:=FieldGet(FieldPos('C8_PRODUTO'))   
			
			
			//+-----------------------------------------------------------+
			//|Adiciona a Descricao do Produto                            |
			//+-----------------------------------------------------------+
			DbSelectArea("SB1")
			DbSeek(FILSB1+SC8->C8_PRODUTO)
			aCols[Len(aCols),nPosDesc]	:=SB1->B1_DESC
			DbSelectArea("SC8")			
			
			//+-----------------------------------------------------------+
			//|Grava a Quantidade do Produto	                          |
			//+-----------------------------------------------------------+
			aCols[Len(aCols),nPosQtd]	:=FieldGet(FieldPos('C8_QUANT'))
			  
			//+----------------------------------------------------------------+
			//|Procura o Codigo do fornecedor no aHeader para gravar o Total   |
			//+----------------------------------------------------------------+
			nPosFor:=aScan(aHeader,{|x| ALLTRIM(x[1])==ALLTRIM(SC8->C8_FORNECE)})		
   			aCols[Len(aCols),nPosFor]	:=FieldGet(FieldPos('C8_TOTAL'))	//Grava o Total no fornecedor    
   			
   			//+----------------------------------------------------------------+
   			//|Soma o valor do IPI no total                                    |
   			//+----------------------------------------------------------------+       
   			IF MV_PAR05==1
	   			aCols[Len(aCols),nPosFor]	+=FieldGet(FieldPos('C8_VALIPI'))  
	   		ENDIF
   			
   			//+----------------------------------------------------------------+
   			//|Grava o Iten mais barato do produto sempre igual a zero, pois   |
   			//|sera atualizado mais tarde                                      |
   			//+----------------------------------------------------------------+
   			aCols[Len(aCols),Len(aHeader)]:=0                                 
   			
   			//+----------------------------------------------------------------+
   			//|Grava o Ultimo preco praticado e Sua Data                       |
   			//+----------------------------------------------------------------+
   			aCols[Len(aCols),nPosPrc]  :=ULPRC()//Trabalha com o Alias Posicionado
   			aCols[Len(aCols),nPosEmiss]:=ULPRCDT()
   			
   		Else
   			//+-----------------------------------------------------------------+
   			//|Se o produto ja existe no Acols, procuro pelo produto e          |
   			//|fornecedor, gravando o Total do produto no fornecedor.           |
   			//+-----------------------------------------------------------------+
   			nPosFor		:=aScan(aHeader,{|x| ALLTRIM(x[1])==ALLTRIM(SC8->C8_FORNECE)})     	//Procuro a Coluna do Fornecedor
   			nPosProd2	:=aScan(aCols,{|x| ALLTRIM(x[nPosProd])==ALLTRIM(SC8->C8_PRODUTO)})   //Procuro a Linha do Produto
   			aCols[nPosProd2,nPosFor]:=FieldGet(FieldPos('C8_TOTAL'))							//Grava o Total do Produto no fornecedor 				
   			
   			
   			//+----------------------------------------------------------------+
   			//|Soma o valor do IPI no total                                    |
   			//+----------------------------------------------------------------+       
   			IF MV_PAR05==1
	   			aCols[nPosProd2,nPosFor]	+=FieldGet(FieldPos('C8_VALIPI'))  
	   		ENDIF
   			
   		EndIF                                                                                                                   
   			
   			
		aCols[Len(aCols),nUsado+1]:=.F. //Defino que a linha nao esta deletada
		
        //Avancao o Registro
		SC8->(dbSkip())
End



//+-----------------------------------------------------------+
//|Identifico  abaixo os itens mais baratos de Cada fornecedor|
//+-----------------------------------------------------------+
For i:=1 to Len(aCols)             
	//+-----------------------------------------------------------------------+
	//|Removo a ultima coluna da selecao por se tratar do resuldado da busca  |
	//+-----------------------------------------------------------------------+
	For j:=POS_FORNECEDOR to (Len(aHeader)-1) 	
		AADD(aItCheap,{IF(aCols[i][j]==NIL,0,aCols[i][j])})
	Next   
	//+-----------------------------------------------------------+
	//|Ordeno o Array crescente, o Mais barato primeiro           |
	//+-----------------------------------------------------------+
	ASort(aItCheap,,,{|x,y| x[1]<y[1]})                          
	
	//+-----------------------------------------------------------+
	//|Gravo o item mais barato na Coluna correta do acols        |
	//+-----------------------------------------------------------+
	For t:=1 to Len(aItCheap)
		IF aItCheap[t][01]>0
			aCols[i,Len(aHeader)]:=aItCheap[t][01]
			Exit
		ENDIF
	Next   
	aItCheap:={}	//Zera Array
Next

//+-----------------------------------------------------------+
//|Adiciona a Linha de Frete                                  |
//+-----------------------------------------------------------+
AADD(aCols,Array(nUsado+1))
aCols[Len(aCols),nPosProd]:="FRETE"
aCols[Len(aCols),nPosDesc]:=""
aCols[Len(aCols),nPosQtd]:=0                                              
For i:=POS_FORNECEDOR to Len(aHeader)
	aCols[Len(aCols),i]:=0
Next
aCols[Len(aCols),nUsado+1]:=.F.


			    

//+-----------------------------------------------------------+
//|Inclui novos Sub-Totais                                    |
//+-----------------------------------------------------------+
IF MV_PAR01==1     
	//Sub-Total 01                                           
	AADD(aCols,Array(nUsado+1))
	aCols[Len(aCols),nPosProd]:=MV_PAR02
	aCols[Len(aCols),nPosDesc]:=""
	aCols[Len(aCols),nPosQtd]:=0                                              
	For i:=POS_FORNECEDOR to Len(aHeader)
		aCols[Len(aCols),i]:=0
	Next
	aCols[Len(aCols),nUsado+1]:=.F.   

	//Sub-Total 02	
	AADD(aCols,Array(nUsado+1))
	aCols[Len(aCols),nPosProd]:=MV_PAR03
	aCols[Len(aCols),nPosDesc]:=""
	aCols[Len(aCols),nPosQtd]:=0                                              
	For i:=POS_FORNECEDOR to Len(aHeader)
		aCols[Len(aCols),i]:=0
	Next
	aCols[Len(aCols),nUsado+1]:=.F.
	
	//Sub-Total 03	
	AADD(aCols,Array(nUsado+1))
	aCols[Len(aCols),nPosProd]:=MV_PAR04
	aCols[Len(aCols),nPosDesc]:=""
	aCols[Len(aCols),nPosQtd]:=0                                              
	For i:=POS_FORNECEDOR to Len(aHeader)
		aCols[Len(aCols),i]:=0
	Next
	aCols[Len(aCols),nUsado+1]:=.F.
EndIf
 
   
//+-----------------------------------------------------------+
//|Adiciona a Linha de Total                                  |
//+-----------------------------------------------------------+
AADD(aCols,Array(nUsado+1))
aCols[Len(aCols),nPosProd]:="TOTAL"
aCols[Len(aCols),nPosDesc]:=""
aCols[Len(aCols),nPosQtd]:=0                                              
For i:=POS_FORNECEDOR to Len(aHeader)
	aCols[Len(aCols),i]:=0
Next
aCols[Len(aCols),nUsado+1]:=.F.
                            
          




//+-----------------------------------------------------------+
//|Adciona o Nome dos fornecedores no aHeader                 |  
//|Faco isso somente apos a montagem do aCols pois me         |
//|Utilizo da Descricao do aHeader, que contem o codigo       |
//|do fornecedor, para as pesquisas no acols da tabela cruzada|  
//+-----------------------------------------------------------+
DbSelectArea("SA2")
For j:=1 to Len(aHeader)
	If DbSeek(FILSA2+ALLTRIM(aHeader[j][01]),.T.) 
	
			
		//Vejo o Tipo de Frete do fornecedor e incluo no Titulo
		nPosTPFrt:=aScan(aTpFrete,{|x| ALLTRIM(x[1])==aHeader[j][01]})  
		
		If nPosTPFrt>0      
			IF aTpFrete[nPosTPFrt][2]=='C'
				aHeader[j][01]+=" - "+ALLTRIM(A2_NREDUZ)+" -CIF"
			Else
				aHeader[j][01]+=" - "+ALLTRIM(A2_NREDUZ)+" -FOB"
			EndIf
		EndIf 
	EndIf
Next




//+---------------------------------------------------+
//|Monta o Dialogo                                    |
//+---------------------------------------------------+
DEFINE MSDIALOG oDlg TITLE "Previsao de Cotacao: "+cNum FROM 000, 000  TO 350, 600  PIXEL

	oScrollB1 :=TScrollBox():New(oDlg,015,000,123,293,.T.,.T.,.T. ) 
  	oGetd 	  := MsNewGetDados():New(005, 005, 121, 290,nStyle,cLinOk,cTudoOk,;
							cIniCpos,aAlterGDa,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oScrollB1,aHeader,aCols) 

								
ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,   {|| oDlg:end()},{||  oDlg:end()},.F.,aButtons)

RETURN 

//+ Ultimo preco e data

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCOTABOM   บAutor  ณDaniel Pitthan      บ Data ณ  05/31/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Faz a Soma de todo aCols                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function SomaTudo()
Local nTemp:=0

	For h:=POS_FORNECEDOR To Len(aHeader)
		For g:=1 To (Len(aCols)-1)
			nTemp+=IF(ValType(oGetD:Acols[G][h])<>'U',oGetD:Acols[G][h],0)
		Next
		oGetD:Acols[Len(oGetD:Acols)][h]:=nTemp			//Altera a estrutura logica, apenas o display
		Acols[Len(aCols)][h]:=nTemp						//Altera a estrutura Fisica     
		nTemp:=0
	Next
	oGetD:Refresh()
Return
      


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCOTABOM   บAutor  ณDaniel Pitthan      บ Data ณ  05/31/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta Grupo de Pergunta                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function MontaPerg(cPerg)                                  
Private bValid	:=Nil 
Private cF3		:=Nil
Private cSXG	:=Nil
Private cPyme	:=Nil

PutSx1(cPerg,'01','Inclui Sub-Totais?','','','mv_ch1','N',1,0,1,'C',bValid,cF3,cSXG,cPyme,'MV_PAR01','Sim',,,,'Nao',,) 
PutSx1(cPerg,'02','Sub-Total 01 ?','','','mv_ch2','C',15,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR02') 
PutSx1(cPerg,'03','Sub-Total 02 ?','','','mv_ch3','C',15,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR03') 
PutSx1(cPerg,'04','Sub-Total 03 ?','','','mv_ch4','C',15,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR04') 
PutSx1(cPerg,'05','Soma IPI no Preco?','','','mv_ch5','N',1,0,0,'C',bValid,cF3,cSXG,cPyme,'MV_PAR05','Sim',,,,'Nao',,) 

Pergunte(cPerg,.T.)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLIBCOM    บAutor  ณDaniel Pitthan      บ Data ณ  01/18/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Localiza o ultimo Preco de Compras do produto              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

STATIC FUNCTION ULPRC()        

	aArea		:=GetArea()		//Salva o Alias Atual
	cQuery		:={}			//Resultado da Query 
	nUltPreco	:=0				//Ultimo preco de compras
	
	
	//+-------------------------------------------------------------+
	//|Monta a Query de consulta, traz o ultimo pedido de compras   |
	//+-------------------------------------------------------------+	
	BeginSql Alias 'TSD1'
	%NOPARSER%
	
	SELECT TOP 1 *
	FROM %table:SD1% SD1 
	WHERE 
		 SD1.%NOTDEL%
		AND D1_COD=%exp:ALLTRIM(SC8->C8_PRODUTO)%  
		AND D1_FILIAL=%Exp:xFilial('SD1')%
		
	ORDER BY R_E_C_N_O_ DESC
	EndSql  
	 
	DbSelectArea('TSD1'); DbGotop()
	 
	//Retorna dados daQuery
	cQuery:=GetLastQuery()
	
	While TSD1->(!EOF())
	                  
            //Ultimo preco de compra
            nUltPreco:=TSD1->D1_VUNIT
            
        	TSD1->(dbSkip())
	ENDDO
	
	TSD1->(DbCloseArea())
	
	
	//Restaura o Alias original
	RestArea(aArea)
RETURN(nUltPreco)      



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLIBCOM    บAutor  ณDaniel Pitthan      บ Data ณ  01/18/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Localiza o ultima data do Preco de Compras do produto      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

STATIC FUNCTION ULPRCDT()      

	aArea		:= GetArea()		//Salva o Alias Atual
	cQuery		:= {}			    //Resultado da Query 
	dData    	:= CTOD("  /  /  ")	//Data
	
	
	//+-------------------------------------------------------------+
	//|Monta a Query de consulta, traz o ultimo pedido de compras   |
	//+-------------------------------------------------------------+	
	BeginSql Alias 'TSC7'
	%NOPARSER%
	
	SELECT TOP 1 *
	FROM %table:SC7% SC7 
	WHERE 
		 SC7.%NOTDEL%
		AND C7_PRODUTO=%exp:ALLTRIM(SC8->C8_PRODUTO)%
		
	ORDER BY R_E_C_N_O_ DESC	
	EndSql  
	
	DbSelectArea('TSC7'); DbGotop()
	
	 
	//Retorna dados daQuery
	cQuery:=GetLastQuery()
	
	While TSC7->(!EOF())
	                  
		//Ultimo preco de compra
        dData :=STOD(TSC7->C7_EMISSAO)
            
        	TSC7->(dbSkip())
	ENDDO
	
	TSC7->(DbCloseArea())
	
	
	//Restaura o Alias original
	RestArea(aArea)
	
RETURN(dData )
