#INCLUDE "PROTHEUS.CH"  
#INCLUDE "AP5MAIL.CH"     
#INCLUDE "rwmake.ch"  
#INCLUDE "topconn.ch"
#INCLUDE 'FWMVCDEF.CH'  
#INCLUDE "FILEIO.CH" 

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
//±±ºPrograma  ³ADVEN047P ºAutor  ³WILLIAM COSTA       º Data ³  06/07/2017 º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºDesc.     ³Modelo 1 da tabela ZB7 De/Para EDI                          º±±
//±±º          ³                                                            º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºUso       ³                                                            º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºALTERACAO ³050848 || OS 052150 || ADM. || AS_002 || 979699037 ||       º±±
//±±º          ³PAINEL P.V EDI - WILLIAM COSTA 06/08/2019 - Criado botao    º±±
//±±º          ³chegou EDI para verificar se ja chegou arquivo para importarº±±
//±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

USER FUNCTION ADVEN047P()
         
    Local aArea   	  := GetArea()  
    Local oBrowse   
    Local cFiltro     := ''         
    Local cFunNamBkp  := FunName()
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Modelo 1 da tabela ZB7 De/Para EDI')
    
	SetFunName("ADVEN047P")
	
	// Instanciamento da Classe de Browse 
	oBrowse := FWMBrowse():New() 
	 
	// Definição da tabela do Browse 
	oBrowse:SetAlias('ZB7') 
	 
	// Definição da legenda 
	oBrowse:AddLegend( "!EMPTY(ZB7_CODDE) .AND. !EMPTY(ZB7_CODPAR)", "RED", "COD EAN AJUSTADO"  ) 
	 
	// Definição de filtro 
	// Se for vendedor faz filtro se nao num faz nada
	SqlBuscaVendedor(__CUSERID)
	         
	IF TRB->(!EOF()) 
		
		cFiltro := "ZB7_USERVE = '" + Alltrim(__CUSERID) + "'" 
		oBrowse:SetFilterDefault("@"+cFiltro)
	
	ENDIF
	TRB->(dbCloseArea())
	    
	// Titulo da Browse 
	oBrowse:SetDescription('De/Para Edi') 
	 
	// Opcionalmente pode ser desligado a exibição dos detalhes 
	//oBrowse:DisableDetails() 
	 
	// Ativação da Classe 
	oBrowse:Activate() 
	        
	SetFunName("cFunNamBkp")
	RestArea(aArea) 
Return NIL

Static Function ModelDef() 
               
	// Cria a estrutura a ser usada no Modelo de Dados 
	Local oStruZB7 := FWFormStruct( 1, 'ZB7' ) 
	Local oModel // Modelo de dados que será construído 
	  
	// Cria o objeto do Modelo de Dados 
	oModel := MPFormModel():New( '_VEN047P' )           
	 
	// Adiciona ao modelo um componente de formulário 
	oModel:AddFields( 'ZB7MASTER', /*cOwner*/, oStruZB7 )
	
	oModel:SetPrimaryKey( { "ZB7_FILIAL", "ZB7_REDE" } )       
	        
	// Adiciona a descrição do Modelo de Dados 
	oModel:SetDescription( 'Modelo de De/Para Edi' )
	 
	// Adiciona a descrição do Componente do Modelo de Dados 
	oModel:GetModel( 'ZB7MASTER' ):SetDescription( 'Dados de  De/Para Edi' )  
      
// Retorna o Modelo de dados 
Return oModel     

Static Function ViewDef()                                                         

	// Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado 
	Local oModel := FWLoadModel( 'ADVEN047P' )        
	
	// Cria a estrutura a ser usada na View 
	Local oStruZB7 := FWFormStruct( 2, 'ZB7' ) 
	 
	// Interface de visualização construída 
	Local oView   
	
	// Cria o objeto de View 
	oView := FWFormView():New() 
	 
	// Define qual o Modelo de dados será utilizado na View 
	oView:SetModel( oModel ) 
    
	// Adiciona no nosso View um controle do tipo formulário  
	// (antiga Enchoice) 
	oView:AddField( 'VIEW_ZB7', oStruZB7, 'ZB7MASTER' ) 
	   
	// Criar um "box" horizontal para receber algum elemento da view 
	oView:CreateHorizontalBox( 'TELA' , 100 ) 
	
	// Relaciona o identificador (ID) da View com o "box" para exibição 
	oView:SetOwnerView( 'VIEW_ZB7', 'TELA' )  
	
	//Colocando título do formulário
	
	oView:EnableTitleView('VIEW_ZB7', 'Dados de De/Para Edi' )  
	
    //Força o fechamento da janela na confirmação
	
	oView:SetCloseOnOk({||.T.})
	
	//O formulário da interface será colocado dentro do container
	
	oView:SetOwnerView("VIEW_ZB7","TELA")

// Retorna o objeto de View criado 	
Return oView 

Static Function MenuDef() 

	Local aRotina := {}  
	
		ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.ADVEN047P' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 DISABLE MENU
		ADD OPTION aRotina TITLE 'Legenda'    ACTION 'u_LVEN047'         OPERATION 6                      ACCESS 0 DISABLE MENU
		ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.ADVEN047P' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 DISABLE MENU
		ADD OPTION aRotina TITLE 'Chegou EDI ?' ACTION 'u_VEN047EDI'     OPERATION 7                      ACCESS 0 DISABLE MENU
	
Return aRotina     

USER FUNCTION LVEN047()

    LOCAL aLegenda := {}

	U_ADINF009P('ADVEN047P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Modelo 1 da tabela ZB7 De/Para EDI')
     
    //Monta as cores
    AADD(aLegenda,{"BR_VERMELHO",   "COD EAN AJUSTADO"})
     
    BrwLegenda("Legenda de De/Para Edi", "Legenda", aLegenda) 
    
RETURN(NIL)

USER FUNCTION VEN047EDI()

	Local nCont        := 0
	Local nLinha       := 0  
	Local cCnpjComp    := ''
	Local cTxt         := ''
	Local cMensagem    := ''
	Local aCampos      := {}
	Private oTempTable := NIL
	Private aDirectory := {} 

	U_ADINF009P('ADVEN047P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Modelo 1 da tabela ZB7 De/Para EDI')

	// *** INICIO WILLIAM COSTA 06/08/2019 CHAMADO 050848 || OS 052150 || ADM. || AS_002 || 979699037 ||

	// *** INICIO CRIA TABELA TEMPORARIA *** //
	IncProc("Criando Tabela Temporária")  
	oTempTable := FWTemporaryTable():New("TRC")
	
	// INICIO Monta os campos da tabela
	aadd(aCampos,{"CODCLI"   ,"C",06,0})
	aadd(aCampos,{"LOJA"     ,"C",02,0})
    aadd(aCampos,{"CGCCLI"   ,"C",14,0})
    aadd(aCampos,{"NOMECLI"  ,"C",90,0})
    aadd(aCampos,{"REDE"     ,"C",06,0})
    aadd(aCampos,{"CODVEND"  ,"C",06,0})
    aadd(aCampos,{"NOMEVEND" ,"C",90,0})
    aadd(aCampos,{"QUANT"    ,"N",14,0})
    
    // FINAL Monta os campos da tabela
    
	oTemptable:SetFields(aCampos)
	oTempTable:AddIndex("01", {"CODCLI","LOJA"})
	oTempTable:AddIndex("02", {"REDE"})
	
	//------------------
	//Criação da tabela
	//------------------
	oTempTable:Create()
	
	aDirectory := DIRECTORY("\SYSTEM\edi\pedidos\*.txt")
	
	nCont        := 0
	nQuant       := 0
	nQuantNaoEnc := 0
	nLinha       := 0  
	
	FOR nCont := 1 TO LEN(aDirectory)
		
		FT_FUse( '\SYSTEM\edi\pedidos\' + aDirectory[nCont][1] )   
		FT_FGoTop()   
		aItens := {}
		
		While ! ( FT_FEof() )
		
			cTxt :=  FT_FReadLN()    
			
			IF SUBSTR(cTxt,001,002) == "01"  
			    
				cCnpjComp     := Substr(cTxt,181,014)
				
				DbSelectArea("SA1")
				DbSetOrder(3)	  
            	IF DbSeek(xFilial("SA1")+cCnpjComp, .T.)
	        	
            		Reclock("TRC",.T.)
				    
				    	TRC->CODCLI   := SA1->A1_COD
				    	TRC->LOJA     := SA1->A1_LOJA
				    	TRC->CGCCLI   := SA1->A1_CGC
				    	TRC->NOMECLI  := SA1->A1_NOME
				    	TRC->REDE     := SA1->A1_CODRED
				    	TRC->CODVEND  := SA1->A1_VEND 
				    	TRC->NOMEVEND := Posicione("SA3",1,xFilial("SA3")+SA1->A1_VEND,"A3_NOME")
				    	TRC->QUANT    := 1
				    	
				    TRC->(MSUNLOCK())
	            
	            ELSE  
	            
	            	Reclock("TRC",.T.)
				    
				    	TRC->CODCLI   := 'NAO ENCONTRADO'
				    	TRC->LOJA     := 'NAO ENCONTRADO'
				    	TRC->CGCCLI   := 'NAO ENCONTRADO'
				    	TRC->NOMECLI  := 'NAO ENCONTRADO'
				    	TRC->REDE     := 'NAO ENCONTRADO'
				    	TRC->CODVEND  := 'NAO ENCONTRADO' 
				    	TRC->NOMEVEND := 'NAO ENCONTRADO'
				    	TRC->QUANT    := 1
				    	
				    TRC->(MSUNLOCK())
	            	
	            ENDIF	
		    ENDIF 
			
			nLinha := nLinha + 1  
	    	FT_FSkip()
	    	
		ENDDO
			   
		FT_FUSE()
		        
	NEXT  
	
	IF LEN(aDirectory) == 0
	
		Reclock("TRC",.T.)
				    
	    	TRC->CODCLI   := ''
	    	TRC->LOJA     := ''
	    	TRC->CGCCLI   := ''
	    	TRC->NOMECLI  := 'NAO CHEGOU ARQUIVO'
	    	TRC->REDE     := ''
	    	TRC->CODVEND  := '' 
	    	TRC->NOMEVEND := 'NAO CHEGOU ARQUIVO'
	    	TRC->QUANT    := 0
	    	
	    TRC->(MSUNLOCK())
		
	ENDIF
	
	cMensagem := ''
	SqlChegouEdi()
	WHILE TRD->(!EOF())
	
		cMensagem := cMensagem + 'Rede:' + IIF(LEN(ALLTRIM(TRD->REDE)) == 6,TRD->REDE,ALLTRIM(TRD->REDE) + SPACE(6-LEN(ALLTRIM(TRD->REDE))))  + '||' + ' Vendedor:' + TRD->CODVEND + '/' + TRD->NOMEVEND + ' Qtd Arquivos:' + STR(TRD->QUANT) + CHR(13) + CHR(10) + CHR(13) + CHR(10) 
	
		TRD->(dbSkip())    
	
	ENDDO //end do while TRD
	TRD->( DBCLOSEAREA() )
	 
	MSGINFO("Olá " + Alltrim(cusername) + CHR(13) + CHR(10) + CHR(13) + CHR(10) + cMensagem + CHR(13) + CHR(10) + CHR(13) + CHR(10) + "Aviso: Programa do Edi é rodado todos os dias às 15:00 e às 16:45","ADVEN048P- TELA EDI") 
		
    //---------------------------------
    //Exclui a tabela Temporária
    //---------------------------------
	oTempTable:Delete()  
	
	// *** FINAL WILLIAM COSTA 06/08/2019 CHAMADO 050848 || OS 052150 || ADM. || AS_002 || 979699037 ||                                                                                

RETUR(NIL)

STATIC FUNCTION SqlBuscaVendedor(cCodUser) 

	BeginSQL Alias "TRB"
			%NoPARSER% 
			SELECT A3_COD,
			       A3_CODUSR,
				   A3_NOME 
			  FROM %Table:SA3%
			  WHERE A3_CODUSR = %EXP:cCodUser%
			    AND D_E_L_E_T_ <> '*'
			    
	EndSQl  
	
RETURN(NIL)
        
Static Function SqlChegouEdi()

	Local cQuery1 := ''
	
	cQuery1 := " SELECT REDE,CODVEND,NOMEVEND,SUM(QUANT) AS QUANT "
	cQuery1 += "   FROM " + oTempTable:GetRealName() + " WITH (NOLOCK) "
	cQuery1 += " GROUP BY REDE,CODVEND,NOMEVEND" 
	cQuery1 += " ORDER BY REDE"
			 
	MPSysOpenQuery( cQuery1, 'TRD' )
	
RETURN()                            