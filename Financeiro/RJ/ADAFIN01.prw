#INCLUDE "Rwmake.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "Topconn.ch"

User Function ADAFIN01()

Local aCores   		:= {}
Private bOk			:= {|| fAtualiza() }
Private nOp			:= Nil                             
Private cAlias		:= "ZAG"
&&Private aRotina	:= {} MenuDef()
Private cCadastro 	:= OemToAnsi('Historico de Indices') 
Private aRotina		:= MenuDef()
Private lValida		:= .T.             
Private aCores 		:= {	{"Empty(ZAG_LEGEND)"		,'ENABLE' }	,;	&& Fator nao Aplicado
							{"!Empty(ZAG_LEGEND)"		,'DISABLE'}}	&& Fator aplicado
							
U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

MBrowse( 6,1,22,75,'ZAG',,,,,,aCores,,,,,,,,)

dbSelectArea(cAlias)
dbSetOrder(1)
dbClearFilter()

Return(.T.)             

Static Function MenuDef()

Private aRotina := {	{ OemToAnsi("Pesquisar"),"AxPesqui"			,0,1,0 ,.F.},;		//"Pesquisar"
						{ OemToAnsi("Visual")	,"AxVisual"			,0,2,0 ,NIL},;		//"Visual"
						{ OemToAnsi("Incluir")	,"U_ADA1Inclui()"	,0,3,0 ,NIL},;		//"Incluir"
						{ OemToAnsi("Alterar")	,"U_ADA1Altera()"	,0,4,20,NIL},;		//"Alterar"
						{ OemToAnsi("Excluir")	,'U_ADA1Deleta()'	,0,5,0,NIL},; 		// Excluir 
						{ OemToAnsi("Ajustes")	,"U_ADA1Ajuste()"	,0,3,0 ,NIL},;		//"Rotina sem validacao"						
						{ OemToAnsi("Legenda")	,"U_ADA1Legend()"	,0,0,0 ,.F.} }		//"Legenda"
					

Return(aRotina)

User Function ADA1Inclui(cAlias,nReg,nOpc)

Local aPosObj   	:= {}
Local aObjects  	:= {}
Local aSize     	:= {}
Local aPosGet   	:= {}
Local aInfo     	:= {}
Local aCpos     	:= Nil
Local nOpcA 		:= 0
Local nCntFor		:= 0
Local nGetLin   	:= 0
Local cCadastro 	:= OemToAnsi("Inclusao de Historico de Indices")
Local cReadBkp  	:= ReadVar()
Local lMemory   	:= .F.
Local oDlg
Local oGetD
Local oSAY1
Local oSAY2
Local oSAY3
Local oSAY4
Local nTotDesc   	:= 0
Local aHeadAGG   	:= {}
Local aColsAGG   	:= {}
Local nStack    	:= GetSX8Len()
Local lContTPV  	:= SuperGetMv("MV_TELAPVX",.F.,.F.)
Local lAltPrcCtr	:= (SuperGetMv("MV_ALTCTR2",.F.,"2") == "1")
Local lIntACD		:= SuperGetMV("MV_INTACD",.F.,"0") == "1"
Local nOpcA			:= 0
Local bOk			:= {|| fAtualiza(oDlg) }

Private aOpc1		:= {Space(30),"000=Indice Atualiz. RJ","001=Opcao 1        ","002=Opcao 2      "}
Private aDistrInd	:={}
Private aColsBn 	:= {}
Private aTela[0][0]
Private aGets[0]
Private bArqF3
Private bCpoF3
Private aTrocaF3  	:= {}
Private aHeadFor  	:= {}
Private aColsFor  	:= {}
Private lFixo    	:= .T. 
Private aColsGrade	:= {}
Private aHeadGrade	:= {}
Private cCodigo		:= CriaVar("ZAG_CODIGO",.F.)	&&Codigo       
Private dIni		:= dDataBase && CriaVar("ZAG_DATAIN",.F.)
Private dFim		:= dDataBase && CriaVar("ZAG_DATAFI",.F.)
Private nJuros		:= CriaVar("ZAG_JUROS",.F.)
Private nTR			:= CriaVar("ZAG_TR",.F.)
Private nCorrec		:= CriaVar("ZAG_CORREC",.F.)
Private nCalc1		:= 0
Private nCalc2		:= 0          
Private nPeriodo	:= 0

U_ADINF009P('ADAFIN01' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

RegToMemory( "ZAG", .T., .F. )

lRefresh := .T.
&& Montagem Tela/Get

		aSize := MsAdvSize()
		aObjects := {}
		AAdd( aObjects, { 100, 100, .t., .t. } )
		AAdd( aObjects, { 100, 100, .t., .t. } )
		AAdd( aObjects, { 100, 020, .t., .f. } )
		aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
		aPosObj := MsObjSize( aInfo, aObjects )
		aPosGet := MsObjGetPos(aSize[3]-aSize[1],315,{{003,033,160,200,240,263}} )
		nGetLin := aPosObj[3,1]   
		
		If lContTPV		
			DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL STYLE nOR( WS_VISIBLE ,DS_MODALFRAME )
		Else
			DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
		EndIf
		/*
		@ 025,002 SAY 'Período Correção'							SIZE 080,011 	OF oDlg PIXEL
		@ 020,030 MSGET cPeriodo  						F3	"ZAG"	SIZE 050,010 	OF oDlg PIXEL 
        */

		@ 025,002 SAY 'Codigo'										SIZE 080,011 	OF oDlg PIXEL
		@ 020,030 COMBOBOX cCodigo	ITEMS aOpc1 					SIZE 080,011 	OF oDlg PIXEL 

		@ 045,002 SAY 'Periodo' 	 			   					SIZE 080,011 	OF oDlg PIXEL
		@ 045,090 SAY "até"		 	 								SIZE 040,011 	OF oDlg PIXEL
		@ 045,200 SAY 'Dias'	 	 								SIZE 040,011 	OF oDlg PIXEL
		@ 040,030 MSGET dIni    									SIZE 050,010 	OF oDlg PIXEL 
		@ 040,110 MSGET dFim    									SIZE 050,010 	OF oDlg PIXEL 
		@ 045,180 SAY 	dFim-dIni  			Picture '@E 999.99'		SIZE 050,010 	OF oDlg PIXEL 
        
		
		@ 065,002 SAY 'Taxa Juros' 	 		  				 		SIZE 080,011 	OF oDlg PIXEL
		@ 065,085 SAY "% ao ano  Fator 1"					 		SIZE 050,011 	OF oDlg PIXEL
		@ 060,030 MSGET nJuros    			Picture '@E 999.99999999'	SIZE 050,010 	OF oDlg PIXEL 
		nCalc1 := ((( (nJuros /100)+1)^(1/360))) &&((( nJuros /100)^(1/360) ))
		@ 065,150 SAY ((( (nJuros /100)+1)^(1/360) ))			Picture '@E 999.99999999'	SIZE 050,010 	OF oDlg PIXEL 
		
		@ 085,002 SAY 'Taxa TR'	 	 								SIZE 080,011 	OF oDlg PIXEL
		@ 085,085 SAY "% ao mês  Fator 2"							SIZE 050,011 	OF oDlg PIXEL
		@ 080,030 MSGET nTR	    			Picture '@E 999.99999999'	SIZE 050,010 	OF oDlg PIXEL 
		nCalc2 := ((( (nTR /100)+1)^(1/30) ))
		@ 085,150 SAY ((( (nTR /100)+1)^(1/30) )) 				Picture '@E 999.99999999'	SIZE 050,010 	OF oDlg PIXEL 
                        
		
		@ 105,002 SAY 'Fator Cor.'	 								SIZE 080,011 	OF oDlg PIXEL
		@ 105,075 SAY "ao periodo"									SIZE 040,011 	OF oDlg PIXEL
		&&nCorrec := nCalc1 * nCalc2
		nCorrec :=  ( ((( (nJuros /100)+1)^(1/360) )) * ((( (nTR /100)+1)^(1/30) ))) ^ ( (dFim-dIni)+1 ) 
		nPeriodo:= (dFim-dIni)+1
		@ 105,035 SAY ( ((( (nJuros /100)+1)^(1/360) )) * ((( (nTR /100)+1)^(1/30) ))) ^ ( (dFim-dIni)+1 )    			Picture '@E 999.99999999'		SIZE 050,010 	OF oDlg PIXEL 

		Activate MsDialog oDlg On Init fEnchBar(oDlg,bOk) Centered                  

dbSelectArea(cAlias)
Return( nOpcA )
               
User Function ADA1Ajuste(cAlias,nReg,nOpc)

Local aPosObj   	:= {}
Local aObjects  	:= {}
Local aSize     	:= {}
Local aPosGet   	:= {}
Local aInfo     	:= {}
Local aCpos     	:= Nil
Local nOpcA 		:= 0
Local nCntFor		:= 0
Local nGetLin   	:= 0
Local cCadastro 	:= OemToAnsi("Inclusao de Historico de Indices")
Local cReadBkp  	:= ReadVar()
Local lMemory   	:= .F.
Local oDlg
Local oGetD
Local oSAY1
Local oSAY2
Local oSAY3
Local oSAY4
Local nTotDesc   	:= 0
Local aHeadAGG   	:= {}
Local aColsAGG   	:= {}
Local nStack    	:= GetSX8Len()
Local lContTPV  	:= SuperGetMv("MV_TELAPVX",.F.,.F.)
Local lAltPrcCtr	:= (SuperGetMv("MV_ALTCTR2",.F.,"2") == "1")
Local lIntACD		:= SuperGetMV("MV_INTACD",.F.,"0") == "1"
Local nOpcA			:= 0
Local bOk			:= {|| fAtualiza(oDlg) }

Private aOpc1		:= {Space(30),"000=Resgate Exec. Judicial","100=Opcao 1        ","200=Opcao 2      "}
Private aDistrInd	:={}
Private aColsBn 	:= {}
Private aTela[0][0]
Private aGets[0]
Private bArqF3
Private bCpoF3
Private aTrocaF3  	:= {}
Private aHeadFor  	:= {}
Private aColsFor  	:= {}
Private lFixo    	:= .T. 
Private aColsGrade	:= {}
Private aHeadGrade	:= {}
Private cCodigo		:= CriaVar("ZAG_CODIGO",.F.)	&&Codigo       
Private dIni		:= dDataBase && CriaVar("ZAG_DATAIN",.F.)
Private dFim		:= dDataBase && CriaVar("ZAG_DATAFI",.F.)
Private nJuros		:= CriaVar("ZAG_JUROS",.F.)
Private nTR			:= CriaVar("ZAG_TR",.F.)
Private nCorrec		:= CriaVar("ZAG_CORREC",.F.)
Private nCalc1		:= 0
Private nCalc2		:= 0        
Private nPeriodo	:= 0

U_ADINF009P('ADAFIN01' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

lValida		:= .F.	&& Desabilita validacoes de datas

RegToMemory( "ZAG", .T., .F. )

lRefresh := .T.
&& Montagem Tela/Get

		aSize := MsAdvSize()
		aObjects := {}
		AAdd( aObjects, { 100, 100, .t., .t. } )
		AAdd( aObjects, { 100, 100, .t., .t. } )
		AAdd( aObjects, { 100, 020, .t., .f. } )
		aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
		aPosObj := MsObjSize( aInfo, aObjects )
		aPosGet := MsObjGetPos(aSize[3]-aSize[1],315,{{003,033,160,200,240,263}} )
		nGetLin := aPosObj[3,1]   
		
		If lContTPV		
			DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL STYLE nOR( WS_VISIBLE ,DS_MODALFRAME )
		Else
			DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
		EndIf
		/*
		@ 025,002 SAY 'Período Correção'							SIZE 080,011 	OF oDlg PIXEL
		@ 020,030 MSGET cPeriodo  						F3	"ZAG"	SIZE 050,010 	OF oDlg PIXEL 
        */

		@ 025,002 SAY 'Codigo'										SIZE 080,011 	OF oDlg PIXEL
		@ 020,030 COMBOBOX cCodigo	ITEMS aOpc1 					SIZE 080,011 	OF oDlg PIXEL 

		@ 045,002 SAY 'Periodo' 	 			   					SIZE 080,011 	OF oDlg PIXEL
		@ 045,090 SAY "até"		 	 								SIZE 040,011 	OF oDlg PIXEL
		@ 045,200 SAY 'Dias'	 	 								SIZE 040,011 	OF oDlg PIXEL
		@ 040,030 MSGET dIni    									SIZE 050,010 	OF oDlg PIXEL 
		@ 040,110 MSGET dFim    									SIZE 050,010 	OF oDlg PIXEL 
		@ 045,180 SAY 	dFim-dIni  			Picture '@E 999.99'		SIZE 050,010 	OF oDlg PIXEL 
        
		
		@ 065,002 SAY 'Taxa Juros' 	 		  				 		SIZE 080,011 	OF oDlg PIXEL
		@ 065,085 SAY "% ao ano  Fator 1"					 		SIZE 050,011 	OF oDlg PIXEL
		@ 060,030 MSGET nJuros    			Picture '@E 999.99999999'	SIZE 050,010 	OF oDlg PIXEL 
		nCalc1 := ((( (nJuros /100)+1)^(1/360))) &&((( nJuros /100)^(1/360) ))
		@ 065,150 SAY ((( (nJuros /100)+1)^(1/360) ))			Picture '@E 999.99999999'	SIZE 050,010 	OF oDlg PIXEL 
		
		@ 085,002 SAY 'Taxa TR'	 	 								SIZE 080,011 	OF oDlg PIXEL
		@ 085,085 SAY "% ao mês  Fator 2"							SIZE 050,011 	OF oDlg PIXEL
		@ 080,030 MSGET nTR	    			Picture '@E 999.99999999'	SIZE 050,010 	OF oDlg PIXEL 
		nCalc2 := ((( (nTR /100)+1)^(1/30) ))
		@ 085,150 SAY ((( (nTR /100)+1)^(1/30) )) 				Picture '@E 999.99999999'	SIZE 050,010 	OF oDlg PIXEL 
                        
		
		@ 105,002 SAY 'Fator Cor.'	 								SIZE 080,011 	OF oDlg PIXEL
		@ 105,075 SAY "ao dia"										SIZE 040,011 	OF oDlg PIXEL
		&&nCorrec := ((( (nJuros /100)+1)^(1/360) )) * ((( (nTR /100)+1)^(1/30) ))
		nCorrec :=  ( ((( (nJuros /100)+1)^(1/360) )) * ((( (nTR /100)+1)^(1/30) ))) ^ ( (dFim-dIni)+1 ) 
		nPeriodo:= (dFim-dIni)+1
		@ 105,035 SAY ( ((( (nJuros /100)+1)^(1/360) )) * ((( (nTR /100)+1)^(1/30) )) ) ^ ( (dFim-dIni)+1 )  			Picture '@E 999.99999999'		SIZE 050,010 	OF oDlg PIXEL 

		Activate MsDialog oDlg On Init fEnchBar(oDlg,bOk) Centered                  

dbSelectArea(cAlias)
Return( nOpcA )

User Function ADA1Altera(cAlias,nReg,nOpc)

Local aPosObj   	:= {}
Local aObjects  	:= {}
Local aSize     	:= {}
Local aPosGet   	:= {}
Local aInfo     	:= {}
Local aCpos     	:= Nil
Local nOpcA 		:= 0
Local nCntFor		:= 0
Local nGetLin   	:= 0
Local cCadastro 	:= OemToAnsi("Alteracao de Historico de Indices")
Local cReadBkp  	:= ReadVar()
Local lMemory   	:= .F.
Local oDlg
Local oGetD
Local oSAY1
Local oSAY2
Local oSAY3
Local oSAY4
Local nTotDesc   	:= 0
Local aHeadAGG   	:= {}
Local aColsAGG   	:= {}
Local nStack    	:= GetSX8Len()
Local lContTPV  	:= SuperGetMv("MV_TELAPVX",.F.,.F.)
Local lAltPrcCtr	:= (SuperGetMv("MV_ALTCTR2",.F.,"2") == "1")
Local lIntACD		:= SuperGetMV("MV_INTACD",.F.,"0") == "1"
Local nOpcA			:= 0
Local bOk			:= {|| fAtuAlt(oDlg) }

Private aOpc1		:= {Space(30),"000=Resgate Exec. Judicial","100=Opcao 1        ","200=Opcao 2      "}
Private aDistrInd	:={}
Private aColsBn 	:= {}
Private aTela[0][0]
Private aGets[0]
Private bArqF3
Private bCpoF3
Private aTrocaF3  	:= {}
Private aHeadFor  	:= {}
Private aColsFor  	:= {}
Private lFixo    	:= .T. 
Private aColsGrade	:= {}
Private aHeadGrade	:= {}
Private cCodigo		:= CriaVar("ZAG_CODIGO",.F.)	&&Codigo       
Private dIni		:= dDataBase && CriaVar("ZAG_DATAIN",.F.)
Private dFim		:= dDataBase && CriaVar("ZAG_DATAFI",.F.)
Private nJuros		:= CriaVar("ZAG_JUROS",.F.)
Private nTR			:= CriaVar("ZAG_TR",.F.)
Private nCorrec		:= CriaVar("ZAG_CORREC",.F.)
Private nCalc1		:= 0
Private nCalc2		:= 0    
Private nPeriodo	:= 0

U_ADINF009P('ADAFIN01' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

cCodigo		:= ZAG->ZAG_CODIGO
dIni		:= ZAG->ZAG_DATAIN
dFim		:= ZAG->ZAG_DATAFI
nJuros		:= ZAG->ZAG_JUROS
nTR			:= ZAG->ZAG_TR
nCorrec		:= ZAG->ZAG_CORREC
nCalc1		:= 0
nCalc2		:= 0

lRefresh := .T.
&& Montagem Tela/Get

		aSize := MsAdvSize()
		aObjects := {}
		AAdd( aObjects, { 100, 100, .t., .t. } )
		AAdd( aObjects, { 100, 100, .t., .t. } )
		AAdd( aObjects, { 100, 020, .t., .f. } )
		aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
		aPosObj := MsObjSize( aInfo, aObjects )
		aPosGet := MsObjGetPos(aSize[3]-aSize[1],315,{{003,033,160,200,240,263}} )
		nGetLin := aPosObj[3,1]   
		
		If lContTPV		
			DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL STYLE nOR( WS_VISIBLE ,DS_MODALFRAME )
		Else
			DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
		EndIf
		
		@ 025,002 SAY 'Codigo'										SIZE 080,011 	OF oDlg PIXEL
		@ 020,030 COMBOBOX cCodigo	ITEMS aOpc1 					SIZE 080,011 	OF oDlg PIXEL 

		@ 045,002 SAY 'Periodo' 	 			   					SIZE 080,011 	OF oDlg PIXEL
		@ 045,090 SAY "até"		 	 								SIZE 040,011 	OF oDlg PIXEL
		@ 045,200 SAY 'Dias'	 	 								SIZE 040,011 	OF oDlg PIXEL
		@ 040,030 MSGET dIni    									SIZE 050,010 	OF oDlg PIXEL 
		@ 040,110 MSGET dFim    									SIZE 050,010 	OF oDlg PIXEL 
		@ 045,180 SAY 	dFim-dIni  			Picture '@E 999.99'		SIZE 050,010 	OF oDlg PIXEL 

		nCalc1 := ((( (nJuros /100)+1)^(1/360)))
		@ 065,002 SAY 'Taxa Juros' 	 		  				 		SIZE 080,011 	OF oDlg PIXEL
		@ 065,085 SAY "% ao ano  Fator 1"					 		SIZE 050,011 	OF oDlg PIXEL
		@ 060,030 MSGET nJuros    			Picture '@E 999.99999999'		SIZE 050,010 	OF oDlg PIXEL 
		@ 065,150 SAY nCalc1   				Picture '@E 999.99999999'		SIZE 050,010 	OF oDlg PIXEL 
	
		nCalc2 := ((( (nTR /100)+1)^(1/30)))
		@ 085,002 SAY 'Taxa TR'	 	 								SIZE 080,011 	OF oDlg PIXEL
		@ 085,085 SAY "% ao mês  Fator 2"							SIZE 050,011 	OF oDlg PIXEL
		@ 080,030 MSGET nTR	    			Picture '@E 999.99999999'		SIZE 050,010 	OF oDlg PIXEL 
		@ 085,150 SAY nCalc2   				Picture '@E 999.99999999'		SIZE 050,010 	OF oDlg PIXEL 
		
		&&nCorrec := nCalc1 * nCalc2
		nCorrec :=  ( ((( (nJuros /100)+1)^(1/360) )) * ((( (nTR /100)+1)^(1/30) ))) ^ ( (dFim-dIni)+1 ) 
		nPeriodo:= (dFim-dIni)+1
		@ 105,002 SAY 'Fator Cor.'	 								SIZE 080,011 	OF oDlg PIXEL
		@ 105,085 SAY "ao dia"										SIZE 040,011 	OF oDlg PIXEL
		@ 100,035 SAY ( ((( (nJuros /100)+1)^(1/360))) * ((( (nTR /100)+1)^(1/30)))) ^ ( (dFim-dIni)+1 )    			Picture '@E 999.99999999'		SIZE 050,010 	OF oDlg PIXEL 

		Activate MsDialog oDlg On Init fEnchBar(oDlg,bOk) Centered                  

dbSelectArea(cAlias)
Return( nOpcA )

User Function ADA1Deleta(cAlias,nReg,nOpc)

Local aPosObj   	:= {}
Local aObjects  	:= {}
Local aSize     	:= {}
Local aPosGet   	:= {}
Local aInfo     	:= {}
Local aCpos     	:= Nil
Local nOpcA 		:= 0
Local nCntFor		:= 0
Local nGetLin   	:= 0
Local cCadastro 	:= OemToAnsi("Exclusao de Historico de Indices")
Local cReadBkp  	:= ReadVar()
Local lMemory   	:= .F.
Local oDlg
Local oGetD
Local oSAY1
Local oSAY2
Local oSAY3
Local oSAY4
Local nTotDesc   	:= 0
Local aHeadAGG   	:= {}
Local aColsAGG   	:= {}
Local nStack    	:= GetSX8Len()
Local lContTPV  	:= SuperGetMv("MV_TELAPVX",.F.,.F.)
Local lAltPrcCtr	:= (SuperGetMv("MV_ALTCTR2",.F.,"2") == "1")
Local lIntACD		:= SuperGetMV("MV_INTACD",.F.,"0") == "1"
Local nOpcA			:= 0
Local bOk			:= {|| fAtuExc(oDlg) }

Private aOpc1		:= {Space(30),"000=Resgate Exec. Judicial","100=Opcao 1        ","200=Opcao 2      "}
Private aDistrInd	:={}
Private aColsBn 	:= {}
Private aTela[0][0]
Private aGets[0]
Private bArqF3
Private bCpoF3
Private aTrocaF3  	:= {}
Private aHeadFor  	:= {}
Private aColsFor  	:= {}
Private lFixo    	:= .T. 
Private aColsGrade	:= {}
Private aHeadGrade	:= {}
Private cCodigo		:= CriaVar("ZAG_CODIGO",.F.)	&&Codigo       
Private dIni		:= dDataBase && CriaVar("ZAG_DATAIN",.F.)
Private dFim		:= dDataBase && CriaVar("ZAG_DATAFI",.F.)
Private nJuros		:= CriaVar("ZAG_JUROS",.F.)
Private nTR			:= CriaVar("ZAG_TR",.F.)
Private nCorrec		:= CriaVar("ZAG_CORREC",.F.)
Private nCalc1		:= 0
Private nCalc2		:= 0         
Private nPeriodo	:= 0

U_ADINF009P('ADAFIN01' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

cCodigo		:= ZAG->ZAG_CODIGO
dIni		:= ZAG->ZAG_DATAIN
dFim		:= ZAG->ZAG_DATAFI
nJuros		:= ZAG->ZAG_JUROS
nTR			:= ZAG->ZAG_TR
nCorrec		:= ZAG->ZAG_CORREC
nCalc1		:= 0
nCalc2		:= 0

lRefresh := .T.
&& Montagem Tela/Get

		aSize := MsAdvSize()
		aObjects := {}
		AAdd( aObjects, { 100, 100, .t., .t. } )
		AAdd( aObjects, { 100, 100, .t., .t. } )
		AAdd( aObjects, { 100, 020, .t., .f. } )
		aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
		aPosObj := MsObjSize( aInfo, aObjects )
		aPosGet := MsObjGetPos(aSize[3]-aSize[1],315,{{003,033,160,200,240,263}} )
		nGetLin := aPosObj[3,1]   
		
		If lContTPV		
			DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL STYLE nOR( WS_VISIBLE ,DS_MODALFRAME )
		Else
			DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
		EndIf
		
		@ 025,002 SAY 'Codigo'										SIZE 080,011 	OF oDlg PIXEL
		@ 020,030 COMBOBOX cCodigo	ITEMS aOpc1 					SIZE 080,011 	OF oDlg PIXEL 

		@ 045,002 SAY 'Periodo' 	 			   					SIZE 080,011 	OF oDlg PIXEL
		@ 045,090 SAY "até"		 	 								SIZE 040,011 	OF oDlg PIXEL
		@ 045,200 SAY 'Dias'	 	 								SIZE 040,011 	OF oDlg PIXEL
		@ 040,030 SAY dIni 		   									SIZE 050,010 	OF oDlg PIXEL 
		@ 040,110 SAY dFim 		   									SIZE 050,010 	OF oDlg PIXEL 
		@ 045,180 SAY dFim-dIni  			Picture '@E 999.99'		SIZE 050,010 	OF oDlg PIXEL 

		nCalc1 := ((( (nJuros /100)+1)^(1/360)))
		@ 065,002 SAY 'Taxa Juros' 	 		  				 		SIZE 080,011 	OF oDlg PIXEL
		@ 065,085 SAY "% ao ano  Fator 1"					 		SIZE 050,011 	OF oDlg PIXEL
		@ 060,030 SAY nJuros    			Picture '@E 999.99999999'		SIZE 050,010 	OF oDlg PIXEL 
		@ 065,150 SAY nCalc1   				Picture '@E 999.99999999'		SIZE 050,010 	OF oDlg PIXEL 

		nCalc2 := ((( (nTR /100)+1)^(1/30)))
		@ 085,002 SAY 'Taxa TR'	 	 								SIZE 080,011 	OF oDlg PIXEL
		@ 085,085 SAY "% ao mês  Fator 2"							SIZE 050,011 	OF oDlg PIXEL
		@ 080,030 SAY nTR	    			Picture '@E 999.99999999'		SIZE 050,010 	OF oDlg PIXEL 
		@ 085,150 SAY nCalc2   				Picture '@E 999.99999999'		SIZE 050,010 	OF oDlg PIXEL 
		
		&&nCorrec := nCalc1 * nCalc2	
		nCorrec :=  ( ((( (nJuros /100)+1)^(1/360) )) * ((( (nTR /100)+1)^(1/30) ))) ^ ( (dFim-dIni)+1 ) 
		nPeriodo:= (dFim-dIni)+1	
		@ 105,002 SAY 'Fator Cor.'	 								SIZE 080,011 	OF oDlg PIXEL
		@ 105,085 SAY "ao dia"										SIZE 040,011 	OF oDlg PIXEL
		@ 100,035 SAY (nCorrec)^nPeriodo    			Picture '@E 999.99999999'		SIZE 050,010 	OF oDlg PIXEL 

		Activate MsDialog oDlg On Init fEnchBar(oDlg,bOk) Centered                  

dbSelectArea(cAlias)
Return( nOpcA )


Static Function fEnchBar(oDlg1,bOk)

Local oBar, oBtOk

Define ButtonBar oBar SIZE 25,25 3D TOP Of oDlg1                                             

&&Define Button Resource "S4WB008N"	Of oBar Group	Action Calculadora()		Tooltip ""
&&Define Button Resource "S4WB010N"	Of oBar 		Action OurSpool() 			Tooltip "Spool"
&&Define Button Resource "S4WB016N"	Of oBar Group	Action HelProg() 			Tooltip "Help"
Define Button Resource "OK"			Of oBar Group	Action Eval(bOk)			&&Tooltip "Ok"
Define Button Resource "Cancel"		Of oBar Group	Action oDlg1:End()			&&Tooltip "Cancela"
	                  
Return()                                 

Static Function fAtualiza(oDlg1)

Local lRet		:= .T.
Local cQuery	:= ''
Local nTot		:= 0
                                    
&& Atualiza calculos de variaveis

cQuery := "SELECT MAX(ZAG_DATAIN) AS MAIORIN,MAX(ZAG_DATAFI) AS MAIORFI   FROM " + RetSqlName("ZAG") + " WHERE D_E_L_E_T_ = '' AND ZAG_FILIAL = '" + xFilial("ZAG") + "'  "
cQuery += "AND ZAG_CODIGO = '" + cCodigo + "' "
cQuery += "AND SUBSTRING(ZAG_DATAIN,1,6) >= '" + Substr(Dtos(dIni),1,6) + "' AND SUBSTRING(ZAG_DATAIN,1,6) <= '" + Substr(Dtos(dFim),1,6) + "' "
//cQuery += "AND ZAG_DATAIN >=  '" + Dtos(dIni) + "' AND ZAG_DATAIN <= '" + Dtos(dFim) + "' AND ZAG_CODIGO = '" + cCodigo + "' "

tcQuery cQuery New Alias "TZAG"

Count to nTot

TZAG->(dbGoTop())

If lValida
	If  Dtos(dIni) <= TZAG->MAIORIN &&Dtos(dIni) >= TZAG->MAIORIN .AND. Dtos(dFim) <= TZAG->MAIORFI 
		MsgInfo("Período informado não permitido. Verifique os parametros informados.")
		lRet := .F.	
	ElseIf Dtos(dIni) <= TZAG->MAIORFI
		MsgInfo("Período informado não permitido. Verifique os parametros informados.")
		lRet := .F.	
	ElseIf Dtos(dFim) <= TZAG->MAIORFI
		MsgInfo("Período informado não permitido. Verifique os parametros informados.")
		lRet := .F.	
	ElseIf 	Dtos(dFim) <= TZAG->MAIORIN 
		MsgInfo("Período informado não permitido. Verifique os parametros informados.")
		lRet := .F.		
	EndIf
EnDIf

TZAG->(dbCloseArea())
          
If lRet
	RecLock("ZAG",.T.)
		ZAG->ZAG_FILIAL		:= XFILIAL("ZAG")
		ZAG->ZAG_CODIGO		:= cCodigo
		ZAG->ZAG_DATAIN		:= dini
		ZAG->ZAG_DATAFI		:= dFim
		ZAG->ZAG_JUROS		:= nJuros
		ZAG->ZAG_TR			:= nTR
		ZAG->ZAG_CORREC		:= ( ((( (nJuros /100)+1)^(1/360) )) * ((( (nTR /100)+1)^(1/30) ))) ^ ( (dFim-dIni)+1 )
	MsUnlock("ZAG")
Endif

oDlg1:End()	
Return(lRet)                                                     

Static Function fAtuAlt(oDlg1)

Local lRet		:= .T.
Local cQuery	:= ''
Local nTot		:= 0
                                    
&& Atualiza calculos de variaveis


If ZAG->ZAG_CODIGO == cCodigo .AND. ZAG->ZAG_DATAIN == dIni .AND. ZAG->ZAG_DATAFI == dFim
	lRet := .T.
Else
	
	cQuery := "SELECT MAX(ZAG_DATAIN) AS MAIORIN,MAX(ZAG_DATAFI) AS MAIORFI   FROM " + RetSqlName("ZAG") + " WHERE D_E_L_E_T_ = '' AND ZAG_FILIAL = '" + xFilial("ZAG") + "'  "
	cQuery += "AND ZAG_CODIGO = '" + cCodigo + "' "
	cQuery += "AND SUBSTRING(ZAG_DATAIN,1,6) >= '" + Substr(Dtos(dIni),1,6) + "' AND SUBSTRING(ZAG_DATAIN,1,6) <= '" + Substr(Dtos(dFim),1,6) + "' "
	//cQuery += "AND ZAG_DATAIN >=  '" + Dtos(dIni) + "' AND ZAG_DATAIN <= '" + Dtos(dFim) + "' AND ZAG_CODIGO = '" + cCodigo + "' "

	tcQuery cQuery New Alias "TZAG"

	Count to nTot

	TZAG->(dbGoTop())

	If lValida
		If  Dtos(dIni) <= TZAG->MAIORIN &&Dtos(dIni) >= TZAG->MAIORIN .AND. Dtos(dFim) <= TZAG->MAIORFI 
			MsgInfo("Período informado não permitido. Verifique os parametros informados.")
			lRet := .F.	
		ElseIf Dtos(dIni) <= TZAG->MAIORFI
			MsgInfo("Período informado não permitido. Verifique os parametros informados.")
			lRet := .F.	
		ElseIf Dtos(dFim) <= TZAG->MAIORFI
			MsgInfo("Período informado não permitido. Verifique os parametros informados.")
			lRet := .F.	
		ElseIf 	Dtos(dFim) <= TZAG->MAIORIN 
			MsgInfo("Período informado não permitido. Verifique os parametros informados.")
			lRet := .F.		
		EndIf
	EnDIf

	TZAG->(dbCloseArea())

Endif
          
If lRet

	If !Empty(ZAG->ZAG_LEGEND)
		MsgInfo("Alteracao não permitida para indice ja aplicado. Verifique os parametros informados.")
		lRet := .F.
	Else
		RecLock("ZAG",.F.)
			ZAG->ZAG_CODIGO		:= cCodigo
			ZAG->ZAG_DATAIN		:= dini
			ZAG->ZAG_DATAFI		:= dFim
			ZAG->ZAG_JUROS		:= nJuros
			ZAG->ZAG_TR			:= nTR
			ZAG->ZAG_CORREC		:= nCorrec
		MsUnlock("ZAG")
	EndIf	  
Else	
	If !Empty(ZAG->ZAG_LEGEND)
		MsgInfo("Exclusao não permitida para indice ja aplicado. Verifique!!")
		lRet := .F.                   
	EndIf	
Endif

oDlg1:End()	
Return(lRet)                                                     

User Function ADA1Legend()

Local aCores := {}

U_ADINF009P('ADAFIN01' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

aCores := {	{"ENABLE"	,'Fator nao Aplicado'},; 
			{"DISABLE"	,'Fator Aplicado'}}

BrwLegenda(cCadastro,'Legenda Historico de Indices',aCores)

Return(.T.)                                                      

Static Function fAtuExc(oDlg1)

Local lRet		:= .T.
Local cQuery	:= ''
Local nTot		:= 0

If !Empty(ZAG->ZAG_LEGEND)
	MsgInfo("Não permitida exclusao para indice ja aplicado. Verifique!!")
	lRet := .F.
Else
	RecLock("ZAG",.F.)
		dbDelete()
	MsUnlock("ZAG")
EndIf	

oDlg1:End()	
Return(lRet)