#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch" 

/*/{Protheus.doc} User Function MT410CPY
	PE. ATIVADO NA FUNCAO DE COPIA DO MATA410 (PV)
	@type  Function
	@author Daniel
	@since 19/03/2007
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history chamado 040649 - Ricardo Lima    - 02/02/2018 - Ajuste para copia de pedido de devolucao, controle de quantidade
	@history chamado 045862 - Fernando Sigoli - 17/12/2018 - Na copia de pedido, subir o campo C5_SHELFLF com o valor default .f.
	@history chamado 056247 - FWNM            - 09/04/2020 - || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS
	@history chamado 059415 - FWNM            - 28/07/2020 - || OS 060907 || FINANCAS || WAGNER || 11940283101 || WS BRADESCO
	@history ticket  9765   - Abel Babini 		- 19/02/2021 - Ajustado o ponto de entrada de cópia de pedidos de venda para que o Tipo do cliente seja atualizado com a informação do cadastro do cliente no momento da cópia.
	@history ticket  8465   - Leonardo P. Monteiro - 13/04/2021 - Limpeza do campo Grupo de Inspeção no eData.
	@history Ticket 22639   - Everson - 14/09/2021 - Limpeza do flag de pré-aprovado financeiro e erro de retorno do Edata.
	@history Ticket 69574   - Abel Babini          - 21/03/2022 - Projeto FAI
/*/
User Function MT410CPY()

	Local _ny	:= 1 //Everson - 14/09/2021. Chamado 22639.
	Local cEmpSF:= GetMv("MV_#SFEMP",,"01|") 		//Ticket 69574   - Abel Babini          - 21/03/2022 - Projeto FAI
	Local cFilSF:= GetMv("MV_#SFFIL",,"02|0B|") 	//Ticket 69574   - Abel Babini          - 21/03/2022 - Projeto FAI

	Private _aAreaNow	:= GetArea() 				//AREA
	Private _aAreaSA1	:= SA1->(GetArea())		//AREA DO SA1
	Private _cFilSA1	:= xFilial("SA1")			//FILIAL DO SA1

	DbSelectArea("SA1")
	DbSetOrder(1)                

	//Private _nCfop	:= 0	           				//POSICAO CFOP
	Private _nCfop	:= ''	           				//CFOP
	Private _cCli	:= M->C5_CLIENTE				//CLIENTE
	Private _cLoj	:= M->C5_LOJACLI				//LOJA DO CLIENTE
	Private _cUF	:= ''								//Unidade Federativa
	Private _lUF	:= .F.								//Indica se a Unidade Federativa e de fora do Estado
	Private _lExUF  := .F.								//Indica se o cliente e de exportacao

	//&&Mauricio - 26/06/2017 - chamado 35017 - INICIO - Copia de pedido "diversos"  
	Private _cNrPd  := M->C5_NUM                    

	Conout( DToC(Date()) + " " + Time() + " MT410CPY >>> INICIO PE" )

	_lDiv   := fchkped(_cNrPd,_cCli,_cLoj)

	If _lDiv
		M->C5_ROTEIRO := Posicione("SA1",1,xFilial("SA1")+_cCli+_cLoj,"A1_ROTEIRO")  &&Roteiro deve vir do cadastro de clientes
	Endif
	//&&FIM chamado 35017

	M->C5_NLACRE1 	:= Space(16)        // ALTERADO POR HCCONSYS EM 19/11/08 PARA LIMPAR NUMERO DO LACRE NA COPIA DO PEDIDO. 
	M->C5_PLACA	  	:= Space(07) 
	M->C5_XLIBERA 	:= Space(01)        &&Mauricio 23/05/11 - Adicionado campos da nova tabela de preço para irem com conteudo zersado na copia.
	M->C5_APROV1  	:= Space(06)
	M->C5_LIBER1  	:= Space(01)
	M->C5_CODRED  	:= Space(06)
	M->C5_REDE    	:= Space(01)
	M->C5_APROV2  	:= Space(06)
	M->C5_LIBER2  	:= Space(01)
	M->C5_APROV3  	:= Space(06)
	M->C5_LIBER3  	:= Space(01) 
	M->C5_DTBLOQ  	:= CTOD(Space(08))
	M->C5_HRBLOQ  	:= Space(08) 
	M->C5_DTLIB1  	:= CTOD(Space(08))
	M->C5_HRLIB1  	:= Space(08)
	M->C5_DTLIB2  	:= CTOD(Space(08))
	M->C5_HRLIB2  	:= Space(08)
	M->C5_DTLIB3  	:= CTOD(Space(08))
	M->C5_HRLIB3  	:= Space(08) 
	M->C5_CHAVE   	:= Space(09)
	M->C5_TOTDIG  	:= 0.00
	M->C5_TOTTAB  	:= 0.00
	M->C5_XIPTAB  	:= 0.00
	M->C5_ANALISE 	:= " "                            
	M->C5_X_SQED  	:= ""
	M->C5_X_DATA  	:= CTOD(Space(08))
	M->C5_OBS       := SPACE(70) //WILLIAM COSTA CHAMADO 041196 limpar esse campo pois esta levando placas erradas
	M->C5_XOBS	  	:= ""
	M->C5_XINT	  	:= "1"
	M->C5_XFLAGE  	:= "1"

	//Ticket 22639 - Everson - 14/09/2021 - Limpeza do flag de pré-aprovado financeiro e erro de retorno do Edata.
	M->C5_XPREAPR	:= " "
	M->C5_XERRO		:= " "
	//

	//Ticket  8465   - Leonardo P. Monteiro - 13/04/2021 - Limpeza do campo Grupo de Inspeção no eData.
	M->C5_XGRPINS	:= "01"
	
	//ticket  9765   - Abel Babini 		- 19/02/2021 - Ajustado o ponto de entrada de cópia de pedidos de venda para que o Tipo do cliente seja atualizado com a informação do cadastro do cliente no momento da cópia.
	M->C5_TIPOCLI := Posicione("SA1",1,xFilial("SA1")+_cCli+_cLoj,"A1_TIPO")

	//Chamado: TI - 14/11/2018 - Fernando Sigoli
	M->C5_XAPREFA   := "N"  
	M->C5_XOBSRFA   := " "
	M->C5_XUSREFA   := " " 

	// Everson - 04/10/2018. Chamado 044154.
	//Ticket 69574   - Abel Babini          - 21/03/2022 - Projeto FAI
	If (Alltrim(cEmpAnt) $ cEmpSF .And. Alltrim(cFilAnt) $ cFilSF)
		M->C5_XPEDSAL   := "" 
		M->C5_XSFPED    := ""
		M->C5_XSFSTAT   := ""
		M->C5_XGERSF    := "1"
	EndIf
	//

	//&&Mauricio - 20/10/2017 - Chamado 037330
	M->C5_XREFATD   := ""
	M->C5_XPEDGER   := ""

	//Incluido por Adriana em 11/12/2014 - devido aos erros na cópia do pedido de venda EDI, roteirização, refaturamento, doacao
	M->C5_EDI		:= Space(Len(M->C5_EDI))
	M->C5_UFPLACA	:= Space(Len(M->C5_UFPLACA))
	M->C5_HRINCLU	:= Time()
	M->C5_XFATANT	:= Space(Len(M->C5_XFATANT))
	M->C5_XPLACAS	:= Space(Len(M->C5_XPLACAS))
	M->C5_MSEXP		:= Space(Len(M->C5_MSEXP))
	M->C5_REFATUR	:= Space(Len(M->C5_REFATUR))
	M->C5_DOACAO	:= Space(Len(M->C5_DOACAO))
	M->C5_STATDOA	:= Space(Len(M->C5_STATDOA))
	M->C5_APRVDOA	:= Space(Len(M->C5_APRVDOA))
	M->C5_DTAPDOA	:= Ctod("  /  /  ")
	M->C5_HRAPDOA	:= Space(Len(M->C5_HRAPDOA))

	//chamado:038632 - Fernand Sigoli 14/12/2017
	M->C5_CANHOTO   := Space(01)
	M->C5_CANHMOT   := Space(50)
	M->C5_CANHUSU   := Space(15)
	M->C5_CANHDAT   := CTOD(Space(08))
	M->C5_CANHHOR   := Space(05)     

	//Incluido por Adriana em 06/04/2015 - devido a incompatibilidade de dados de clientes entre SF2+SD2 e XML+Danfe   
	//Quando estes campos estão preenchidos e são diferentes de C5_CLIENTE+C5_LOJA no XML+Danfe, serão utilizados os dados de cadastro do C5_CLIENT+C5_LOJAENT
	M->C5_CLIENT	:= M->C5_CLIENTE
	M->C5_LOJAENT	:= M->C5_LOJACLI
	M->C5_XCOPIA	:= iif(Alltrim(FunName())="AD0163","R","C") //Identificar que o pedido foi incluido pela opção de cópia/ reprogramação - por Adriana em 17/07/2015
	M->C5_XPDEVOR   := iif( Alltrim(FunName() ) = "AD0163" , cNumPedOri , "" ) // Ricardo Lima - 02/02/18

	//VAR_IXB := {'COPIA_PV',M->C5_DTENTR}
	//Alterado por Adriana em 20/05/2015 para utilizar a variavel publica para filtro de clientes PE M410FSQL

	If Type("VAR_IXB") <> "A"
		VAR_IXB := {'COPIA_PV',M->C5_DTENTR,""}   //Inicia variavel publica    
	else
		VAR_IXB[1] := 'COPIA_PV' 
		VAR_IXB[2] := M->C5_DTENTR
	Endif

	M->C5_DTENTR  := CTOD("")

	//Chamado: 045862
	M->C5_SHELFLF   := .F.

	//LOG DE COPIA
	If M->C5_XCOPIA == "C" //incluido por copia
		u_GrLogZBE (Date(),TIME(),cUserName," COPIA DE PEDIDO ","LOGISTICA","MT410CPY",;
					"COPIA DE PEDIDO VENDA "+_cNrPd+" CLIENTE "+_cCli+" LOJA "+_cLoj,ComputerName(),LogUserName()) 
		
	ElseIf M->C5_XCOPIA == "R" //incluido por reprogramacao
		
		u_GrLogZBE (Date(),TIME(),cUserName," REPROGRAMACAO DE PEDIDO ","LOGISTICA","MT410CPY",;
					"REPROGRAMACAO DE PEDIDO VENDA "+_cNrPd+" CLIENTE "+_cCli+" LOJA "+_cLoj,ComputerName(),LogUserName()) 
			
	EndIF

	//&&Mauricio - 17/06/15 - zerar conteudo dos campos C6_QTDORI,C6_QTDORI2,C6_QT1ORIC e C6_QT2ORIC os quais são atualizados pela tela de corte e por rotinas Edata.
	_nPosQT1 := GDFIELDPOS("C6_QTDORI")
	_nPosQT2 := GDFIELDPOS("C6_QTDORI2")
	_nPos1QT := GDFIELDPOS("C6_QT1ORIC")
	_nPos2QT := GDFIELDPOS("C6_QT2ORIC")
	_nPoslog := GDFIELDPOS("C6_LOGCORT")
	_nPosPro := GDFIELDPOS("C6_PRODUTO")
	_nPosLoc := GDFIELDPOS("C6_LOCAL")
	_nPosTES := GDFIELDPOS("C6_TES")   // incluido por Adriana em 31/03/17
	_nPosSF  := GDFIELDPOS("C6_XIDSF") // Everson - 04/10/2018. Chamado 044154. 

	_aTES:= {{"523",	"501"},{"654",	"603"},{"559",	"558"},{"560",	"557"},{"687",	"519"},{"803",	"505"},{"601",	"598"}}   //incluido por Adriana em 04/04/17 - para garantir que na copia nao sejam utilizados TES sem tributacao

	_nNovoTES := 0

	If _nPosQT1 <> 0 .And. _nPosQT2 <> 0 .And. _nPos1QT <> 0 .And. _nPos2QT <> 0 .And. _nPoslog <> 0

	For _ny := 1 to len(aCols)
			_nNovoTES := Ascan( _aTES, { |x|x[ 01 ] == aCols[_ny][_nPosTES] } )
		aCols[_ny][_nPosQT1] := 0
		aCols[_ny][_nPosQT2] := 0
		aCols[_ny][_nPos1QT] := 0
		aCols[_ny][_nPos2QT] := 0
		aCols[_ny][_nPoslog] := "" 
		aCols[_ny][_nPosLoc] := IIF(!RetArqProd(aCols[_ny][_nPosPro]),POSICIONE("SBZ",1,xFilial("SBZ")+aCols[_ny][_nPosPro],"BZ_LOCPAD"),POSICIONE("SB1",1,xFilial("SB1")+aCols[_ny][_nPosPro],"B1_LOCPAD")) //ALTERACAO REFERENTE A TABELA SBZ INDICADORES DE PRODUTOS CHAMADO 030317 - WILLIAM COSTA  // chamado 031276  - erro no local na copia do pedido copiava o local errado ocasionando problema no estoque
		aCols[_ny][_nPosTES] := IIF(VAR_IXB[2] < ctod("01/04/2017") .and. _nNovoTES <> 0,_aTES[_nNovoTES,2],aCols[_ny][_nPosTES]) // incluido por Adriana em 31/03/17//incluido por Adriana em 04/04/17 - para garantir que na copia nao sejam utilizados TES sem tributacao
		
		//Ticket 69574   - Abel Babini          - 21/03/2022 - Projeto FAI
		If (Alltrim(cEmpAnt) $ cEmpSF .And. Alltrim(cFilAnt) $ cFilSF)

			aCols[_ny][_nPosSF]  := "" // Everson - 04/10/2018. Chamado 044154.
		
		EndIf  
		
	Next _ny
	
	Endif   

	//+-------------------------------------+
	//|VERIFICANDO SE JA NAO EXITES PEDIDO  |
	//|PARA ESSE CLIENTE                    |
	//+-------------------------------------+
	U_FAVCLI10(_cCli)

	//+------------------------------------+
	//|Buscando o estado do Cliente        |
	//|Busco pelo estado de cobranca       |
	//+------------------------------------+
	DbSelectArea("SA1")
	If DbSeek(_cFilSA1+_cCli+_cLoj,.T.)
		If !Empty(SA1->A1_EST)						//ESTADO DE COBRANCA
		_cUF := SA1->A1_EST 
		EndIf	
	EndIf             

	//+------------------------------+
	//|Validando UF do cliente com   |
	//|da Adoro                      |
	//+------------------------------+
	If ALLTRIM(GETMV("MV_ESTADO"))<>_cUF
		_lUF := .T.                
		If _cUF == "EX"
			_lExUF := .T.	
		EndIf
	EndIf

	//+------------------------------+
	//|Obtendo a CFO                 |
	//+------------------------------+
	_nCfop := aScan(aHeader, {|x| x[2] == "C6_CF" } )   

	//+------------------------------+
	//|Validando o CFOP              |
	//+------------------------------+
	/*                 retirado para o teste Mauricio 24/05/11
	For i := 1 To Len(aCols)        
		//+--------------------------------------------------+
		//|Verificando se o CFOP esta errado                 |
		//+--------------------------------------------------+
		If Left(aCols[i][_nCFOP],1) == '5' .And. _lUF 		      
			//+--------------------------------------------------+
			//|Verificando se o estado e exportacao              |
			//+--------------------------------------------------+
			
			//+--------------------------------------------------+
			//|Removo o primeiro caracter e concateno com digito |
			//|correto do estado                                 |
			//|6 - mercado interno fora do estado                |
			//|7 - exportacao                                    |
			//+--------------------------------------------------+
			If _lExUF                                    
				aCols[i][_nCFOP] := '7'+Right(aCols[i][_nCFOP],Len(aCols[i][_nCFOP])-1)		
			Else
				aCols[i][_nCFOP] := '6'+Right(aCols[i][_nCFOP],Len(aCols[i][_nCFOP])-1)		
			EndIf
		EndIf                           
	Next                               
	*/
	//+-------------------------------+
	//|Retornado Ambiente             | 
	//+-------------------------------+
	RestArea(_aAreaNow)
	RestArea(_aAreaSA1)                                              

	//VAR_IXB := {'COPIA_PV',M->C5_DTENTR} // incluido por Adriana em 01/09/2010 - chamado 007766

	M->C5_XWSPAGO := "" // Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 09/04/2020
	M->C5_XWSBOLG := "" // Chamado n. 059415 || OS 060907 || FINANCAS || WAGNER || 11940283101 || WS BRADESCO - FWNM - 28/07/2020
	
	Conout( DToC(Date()) + " " + Time() + " MT410CPY >>> FINAL PE" )
RETURN

//&&Mauricio - 26/06/2017 - chamado 35017 - Copia de pedido "diversos"  
Static Function fchkped(_cNrPd,_cCli,_cLoj)

	Local l_Ret := .F.
	Local _ny	:= 1 //Everson - 14/09/2021. Chamado 22639.
		
		_nPosTES := GDFIELDPOS("C6_TES")   // incluido por Adriana em 31/03/17
		
		For _ny := 1 to len(aCols)
		
			DbSelectArea("SF4")
			DbSetOrder(1)
			if dbseek(xFilial("SF4")+aCols[_ny][_nPosTES])
			If SF4->F4_XTIPO == "2"
				l_Ret := .T.	       
			Endif
			Endif     
	Next _ny
	
Return(l_Ret)
