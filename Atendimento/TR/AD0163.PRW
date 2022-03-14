#INCLUDE "rwmake.ch"
#INCLUDE "vkey.ch"

/*/{Protheus.doc} User Function AD0163
	BROWSER DE OCORRENCIAS
	@type  Function
	@author Não Identificado
	@since 28/04/2006
	@version 01
	@history Chamado TI   - DANIEL PITTHAN SILVEIRA - 27/10/2006 - ALTERADO O 'SET FILTER' PELO FILTRO DA MICROSIGA
	@history Chamado 4992 - William Costa           - 24/11/2020 - Adicionado no Filtro para ver notas que estão com 'XXXXXX' que são notas denegadas ou Canceladas, e conseguir limpar a Placa delas.
	@history Chamado 5657 - William Costa           - 30/11/2020 - Voltado versão de limpa placa, pq não deu certo o jeito que foi pensado será feito na tela de Ocorrências de Devoluções.
	@history ticket  9648 - Fernando Macieira       - 17/02/2021 - variable does not exist CPERG on EPAPERG(AD0163.PRW) 30/11/2020 08:44:35 line : 96
	@history ticket 64881 - Fernando Sigoli         - 09/12/2021 - Adicionar limpar placa na tela de ocorrencias  
	@history ticket TI    - Leonardo P. Monteiro    - 08/02/2022 - Correção da rotina para eliminar o lock na tabela SC5 quando selecionada as opções do menu.
	@history Ticket 69533 - ADRIANO SAVOINE         - 11/03/2022 - Ajustado o Fonte para funcionar a consulta pelo Botão F12
/*/
User Function AD0163(xAutoCab,xAutoItens) // U_AD0163() 

	Local aArea   := GetArea()
	Private cPerg      := "AD0163" // @history ticket  9648 - Fernando Macieira       - 17/02/2021 - variable does not exist CPERG on EPAPERG(AD0163.PRW) 30/11/2020 08:44:35 line : 96
	Private l410Auto := xAutoCab <> NIL .And. xAutoItens <> NIL
	Private cCondicao  := ""
	Private oBrowse := FWMBrowse():New()

	oBrowse:SetAlias('SC5') 

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'BROWSER DE OCORRENCIAS')

	IF EpaPerg(cPerg)

	
		SetKey(VK_F12,{|| EpaPerg(cPerg)}) // @history ticket  9648 - Fernando Macieira       - 17/02/2021 - variable does not exist CPERG on EPAPERG(AD0163.PRW) 30/11/2020 08:44:35 line : 96
		

		
		Private aIndSC5     := {}  
		Private cCadastro 	:= "Cadastro de Ocorrencias de Entrega"
		Private aRotina 	:= { {"Pesquisar" 	          ,"AxPesqui"			  ,0,01},;
							{"Visualizar"	          ,"AxVisual"			  ,0,02},;
							{"Pedido"    	          ,'Execblock("AD0165")'  ,0,03},;                     
							{"Consultas" 	          ,'U_AD0168("")'		  ,0,04},;                     
							{"Cliente"    	          ,'U_AD0080("")'     	  ,0,02},;  
							{"Ocorrencias"	          ,'U_AD0019("O")'		  ,0,06},; // "O" Ocorrencias                  
							{"Romaneio" 	          ,'U_ROMANEIO("B")'	  ,0,07},;	// EXECUTA EM MODO BROWSER
							{"Rel. Devol."	          ,'U_AD0016'			  ,0,08},; // rel de fechamento
							{"Legenda    "	          ,'Execblock("Legenda")' ,0,09},; 
							{"Env. SF.    "          ,'U_envOcorrSF()'	      ,0,10},; 
							{"Limp. Placa "          ,'ExecBlock("UnRote")'  ,0,11},; //tkt 64881 - Fernando Sigoli - Adicionar limpar placa na tela de ocorrencias  
							{"Ped. Não Será Entregue",'U_ADLOG072()'	      ,0,12}}                    


		oBrowse:AddLegend("C5_MOK = '01' ","BR_VERMELHO" )
		oBrowse:AddLegend("C5_MOK = '02' ","BR_VERDE"    )
		oBrowse:AddLegend("C5_MOK = '03' ","BR_AZUL"     )
		oBrowse:AddLegend("C5_MOK = '04' ","BR_MARROM"   )
		oBrowse:AddLegend("C5_MOK = '05' ","BR_AMARELO"  )
		oBrowse:AddLegend("C5_MOK = '06' ","BR_PRETO"    )
							

	
		oBrowse:Activate()
	ENDIF

	RestArea(aArea)

RETURN(NIL)
      

Static Function fFiltro()

	DBSELECTAREA("SC5")
	SC5->(DBORDERNICKNAME("SC5_9")) //atualização protheus 12 WILLIAM COSTA 28/12/2017 CHAMADO 036032
	DBGOTOP()


	IF ALLTRIM(MV_PAR02) <> '' .and. ALLTRIM(MV_PAR03) <> ''
	
		_nFiltRot := " C5_DTENTR = '"+ALLTRIM(DTOS(MV_PAR01))+"' .AND. C5_PLACA = '"+ ALLTRIM(MV_PAR02) +"' AND C5_ROTEIRO = '" + ALLTRIM(MV_PAR03)+"'"    //SQL

	Else
		If ALLTRIM(MV_PAR02) <> ''
	
			_nFiltRot := " C5_DTENTR = '"+ALLTRIM(DTOS(MV_PAR01))+"' .AND. C5_PLACA = '"+ ALLTRIM(MV_PAR02) +"'"    //SQL

		Else 
	
			_nFiltRot := " C5_DTENTR = '"+ALLTRIM(DTOS(MV_PAR01))+"'"	   //SQL

		Endif
	Endif	

	cCondicao  := " C5_FILIAL = '" + xFilial("SC5") + "' .AND. " + _nFiltRot

Return ()	


Static Function EpaPerg(cPerg)
	Local lRet := .T.

	lRet := Pergunte(cPerg,.T.)

	IF	lRet

		fFiltro()
		oBrowse:SetFilterDefault(cCondicao)

	ELSE

		MsgInfo("Operacao cancelada", "Filtro.")

	ENDIF

RETURN(lRet)



User  Function Legenda()
      
Local aLegenda := {} 

aAdd( aLegenda , { "BR_VERMELHO " , "A Entregar    "} )  // 01
aAdd( aLegenda , { "BR_VERDE"     , "Entregue      "} )  // 02
aAdd( aLegenda , { "BR_AZUL"      , "Devolvido     "} )  // 03
aAdd( aLegenda , { "BR_MARROM"    , "Ocorrencias   "} )  // 04
aAdd( aLegenda , { "BR_AMARELO"   , "Reprogramacao "} )  // 05
aAdd( aLegenda , { "BR_PRETO"     , "Quebra 	   "} )  // 06
                                          
BrwLegenda(cCadastro , "Legenda" , aLegenda)

Return



/*/{Protheus.doc} User Function envOcorrSF
	(Função para enviar ocorrências de devolução ao SalesForce)
	@type  Function
	@author EVERSON
	@since 27/04/2018
	@history Chamado 037261.
/*/

User Function envOcorrSF()

	Local aArea := GetArea()

	U_ADINF009P('envOcorrSF' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Função para enviar ocorrências de devolução ao SalesForce.')
		
	
	If cEmpAnt == "01" .And. FindFunction("U_ADVEN084P") .And. Alltrim(cValToChar(SC5->C5_NOTA)) <> '' .And. Alltrim(cValToChar(SC5->C5_SERIE)) <> '' .And. Alltrim(cValToChar(SC5->C5_XPEDSAL)) <> ''
		U_ADVEN084P(Alltrim(cValToChar(SC5->C5_NOTA)),Alltrim(cValToChar(SC5->C5_SERIE)),.F.,"")
	
	EndIf
	
	
	RestArea(aArea)

Return Nil

User Function ADLOG072()

	Local aArea       := GetArea()
	Local lStatusNota := .F.
	
	U_ADINF009P('ADLOG072' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Limpa Placa para notas denegadas ou canceladas')
		
	IF ALLTRIM(SC5->C5_NOTA) == '' .OR. ;
	   ISALPHA(SC5->C5_NOTA) == .T.

	    //*** INICIO VERIFICA SE TEM ALGUMA NOTA JÁ PROCESSADA QUE FOI DELETADA E SPED É IGUAL A 07 - CANCELADA OU DENEGADA
		SQLSD2(SC5->C5_FILIAL,SC5->C5_NUM)	
		TRB->(DbGoTop())
		WHILE !TRB->(EOF()) 
			
			IF lStatusNota == .F.

				lStatusNota := .T.

			ELSE  

				EXIT  

			ENDIF    

			TRB->(DBSKIP())    

		ENDDO
		TRB->(DbCloseArea())

	    //*** FINAL VERIFICA SE TEM ALGUMA NOTA JÁ PROCESSADA QUE FOI DELETADA E SPED É IGUAL A 07 - CANCELADA OU DENEGADA

	    //*** INICIO ALTERA O ROTEIRO E A PLACA APOS VALIDAÇAO QUE A NOTA FOI CANCELADA OU DENEGADA

		IF lStatusNota == .T. 

			MsgInfo("OLÁ " + Alltrim(cUserName) + ", Numero do Pedido: " + SC5->C5_NUM + " Limpado a Placa com Sucesso.", "AD0163-01")

			RecLock("SC5",.F.)

				SC5->C5_PLACA   := ''	  
				SC5->C5_UFPLACA := ''	  
				SC5->C5_ROTEIRO := '599'	  

			MsUnlock()

			u_GrLogZBE (Date(),TIME(),cUserName," Ocorrencias/devolucao","LOGISTICA","AD0163",;
						"PEDIDO DENEGADO/CANCELADO LIMPADO PLACA: "+SC5->C5_NUM+" CLIENTE: "+SC5->C5_CLIENTE+" LOJA: "+SC5->C5_LOJACLI,ComputerName(),LogUserName())			
            
		ELSE 

			MsgStop("OLÁ " + Alltrim(cUserName) + ", Numero do Pedido: " + SC5->C5_NUM + " não encontrado no SPED, não consta como Nota Denegada ou Cancelada, não será limpado a Placa.", "AD0163-02")


	    ENDIF	  

	    //*** FINAL ALTERA O ROTEIRO E A PLACA APOS VALIDAÇAO QUE A NOTA FOI CANCELADA OU DENEGADA

	ELSE 

		MsgStop("OLÁ " + Alltrim(cUserName) + ", Numero do Pedido: " + SC5->C5_NUM + " esse botão só serve para Limpar Placa de Pedidos que tiveram nota Denegada ou Cancelada, não será limpado a Placa.", "AD0163-03")	

	ENDIF   

	RestArea(aArea)

RETURN(NIL)

STATIC FUNCTION SQLSD2(cFilAtu,cPedido)
	BeginSQL Alias "TRB"
		     %NoPARSER%
			  SELECT D2_DOC,D2_SERIE,STATUS
				FROM %TABLE:SC5% SC5 WITH(NOLOCK)
		  INNER JOIN %TABLE:SD2% SD2 WITH(NOLOCK)
		  		  ON D2_FILIAL        = C5_FILIAL
				 AND D2_PEDIDO        = C5_NUM
		  INNER JOIN [SPED].[CCZERN_120413_TS_PD].[dbo].[SPED050] WITH(NOLOCK)
				  ON NFE_ID           = D2_SERIE + D2_DOC 
			   WHERE C5_FILIAL        = %EXP:cFilAtu%
				 AND C5_NUM           = %EXP:cPedido%
				 AND (C5_NOTA         = ''
				  OR LEFT(C5_NOTA,1)  = 'X')
				 AND SC5.D_E_L_E_T_  <> '*' 

				GROUP BY D2_DOC,D2_SERIE,STATUS
            
	EndSQl

RETURN(NIL)
