#INCLUDE "Topconn.ch"
#INCLUDE "Protheus.ch"
#Include "MSMGADD.CH"     
#Include "Chamado.CH"  

/*/{Protheus.doc} User Function ADINF006P
	BROWSER PARA OS GESTORES VEREM OS CHAMADOS DA TI
	@type  Function
	@author William Costa
	@since 13/02/2017
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
    @history chamado 050729 - FWNM - 29/06/2020 - || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE
/*/
User Function ADINF006P()
    
	Local aTRB        := {}
	Local aHeadMBrow  := {}
	Local aCores 	  := {{ "PAA_TPENCE=='0'", "BR_LARANJA" },;
	                      { "PAA_TPENCE=='2'" , "BR_BRANCO"	},;
                          { "PAA_TPENCE=='5'", "BR_PINK"	},;
                          { "PAA_TPENCE=='6'", "BR_AMARELO" },;
                          { "PAA_TPENCE=='7'", "BR_AZUL"	},;
                          { "PAA_TPENCE=='8'", "BR_VERDE"	}}
                          
    Private cCadastro := "Cadastro de Chamados"
	Private aRotina   := {{"Acompanhamento","U_AcompGestao",0,1},;
	                      {"Visualizar"    ,"U_VISUGESTAO" ,0,2},;
	                      {"Apontamentos"  ,"U_ApontOS"    ,0,3},;
					      {"LEGENDA"       ,"U_LegGestao"  ,0,4}}
	Private cArqTRB   := ""
	Private cInd1     := ""
	Private cInd2     := ""
	Private cHOras    := ""
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'BROWSER PARA OS GESTORES VEREM OS CHAMADOS DA TI')
	                      
	MsgRun("Criando estrutura e carregando dados no arquivo temporário...",,{|| aTRB := FileTRB() } )

	MsgRun("Criando coluna para MBrowse...",,{|| aHeadMBrow := HeadBrow() } )
	
	dbSelectArea("TRB")
	dbSetOrder(1)
	
	MBrowse(,,,,"TRB",aHeadMBrow,,,,,aCores,"","")
	dbSelectArea( "TRB" )
	
	TMP0->(dbclosearea())
	TRB->(dbclosearea()) 
	
	 // Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - FWNM - 29/06/2020
	//IF FILE("\SYSTEM\"+cArqTRB+ '.DBF')
	IF FILE("\SYSTEM\"+cArqTRB+ GETDBEXTENSION())
		FErase("\SYSTEM\"+cArqTRB+ GETDBEXTENSION())
//		FErase("\SYSTEM\"+cArqTRB+ '.DBF')
	ENDIF
	
	//IF FILE("\SYSTEM\"+cInd1+ '.IDX')
	IF FILE("\SYSTEM\"+cInd1+ OrdBagExt())
		FErase("\SYSTEM\"+cInd1+ OrdBagExt())
		//FErase("\SYSTEM\"+cInd1+ '.IDX')
	ENDIF
	
	//IF FILE("\SYSTEM\"+cInd2+ '.IDX')
	IF FILE("\SYSTEM\"+cInd2+ OrdBagExt())
		FErase("\SYSTEM\"+cInd2+ OrdBagExt())
		//FErase("\SYSTEM\"+cInd2+ '.IDX')
	ENDIF
	
Return(NIL) 

/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author user
	@since 29/06/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function FileTRB()

	Local aStruct := {} 
	Local nCont   := 0 
	
	AAdd( aStruct, { "PAA_CHAMAD", "C",06, 0 } )
	AAdd( aStruct, { "PAA_USUARI", "C",40, 0 } )
	AAdd( aStruct, { "PAA_DSRVAC", "C",30, 0 } )
	AAdd( aStruct, { "PAA_DRESUM", "C",20, 0 } )
	AAdd( aStruct, { "PAA_PRISCR", "C",09, 0 } )
	AAdd( aStruct, { "PAA_SPRINT", "C",09, 0 } )
	AAdd( aStruct, { "PAA_SOLICI", "D",08, 0 } )
	AAdd( aStruct, { "IDADE"     , "C",09, 0 } )
	AAdd( aStruct, { "PAA_DTINI" , "D",08, 0 } )
	AAdd( aStruct, { "PAA_DTPREV", "D",08, 0 } )
	AAdd( aStruct, { "PA6_DESPE" , "C",50, 0 } )
	AAdd( aStruct, { "PAA_NOMTEC", "C",50, 0 } )
	AAdd( aStruct, { "PAA_TPENCE", "C",1, 0 } )
	AAdd( aStruct, { "LEGENDA"   , "C",20, 0 } )
	AAdd( aStruct, { "PAA_TPITIL", "C",10, 0 } )
	AAdd( aStruct, { "HR_CHAMAD" , "C",08, 0 } )
	
	// Criar fisicamente o arquivo.
	cArqTRB := CriaTrab( aStruct, .T. )
	cInd1   := Left( cArqTRB, 7 ) + "1"
	cInd2   := Left( cArqTRB, 7 ) + "2"
	
	// Acessar o arquivo e coloca-lo na lista de arquivos abertos.
	dbUseArea( .T., __LocalDriver, cArqTRB, "TRB", .F., .F. )
	
	// Criar os índices.               
	IndRegua( "TRB", cInd1, "PAA_TPENCE+PAA_SPRINT", , , "Criando índices...")
	IndRegua( "TRB", cInd2, "PAA_CHAMAD", , , "Criando índices...")
	
	// Libera os índices.
	dbClearIndex()
	
	// Agrega a lista dos índices da tabela (arquivo).
	dbSetIndex( cInd1 + OrdBagExt() )  
	dbSetIndex( cInd2 + OrdBagExt() ) 
	
	SqlGeral()
	
	While ! TMP0->(Eof())
	
		SqlHoras(TMP0->PAA_CHAMAD)
		While TRC->(!EOF())
	                  
	    	cHoras := CVALTOCHAR(TRC->HORAS)
	            
            TRC->(dbSkip())
		ENDDO
		TRC->(dbCloseArea())
	
		TRB->(RecLock("TRB",.T.))
		
			TRB->PAA_CHAMAD := TMP0->PAA_CHAMAD
			TRB->PAA_USUARI := TMP0->PAA_USUARI
			TRB->PAA_DSRVAC := TMP0->PAA_DSRVAC
			TRB->PAA_DRESUM := TMP0->PAA_DRESUM 
			TRB->PAA_PRISCR := CVALTOCHAR(TMP0->PAA_PRISCR)
			TRB->PAA_SPRINT := TMP0->PAA_SPRINT  
			TRB->PAA_SOLICI := STOD(TMP0->PAA_SOLICI)
			TRB->IDADE      := CVALTOCHAR( DATE() - STOD(TMP0->PAA_SOLICI) )
			TRB->PAA_DTINI  := STOD(TMP0->PAA_DTINI)		
			TRB->PAA_DTPREV := STOD(TMP0->PAA_DTPREV)
			TRB->PA6_DESPE  := IIF(ALLTRIM(Posicione("PA6",4,xFilial("PA6")+TMP0->PAA_SRVACT,"PA6_DESPE2")) == '',Posicione("PA6",4,xFilial("PA6")+TMP0->PAA_SRVACT,"PA6_DESPE"), Posicione("PA6",4,xFilial("PA6")+TMP0->PAA_SRVACT,"PA6_DESPE2")) 
			TRB->PAA_NOMTEC := TMP0->PAA_NOMTEC
			TRB->PAA_TPENCE := TMP0->PAA_TPENCE
			TRB->LEGENDA    := IIF(TMP0->PAA_TPENCE == '0', 'Em Atendimento', IIF(TMP0->PAA_TPENCE == '2', 'Atendimento Pausado', IIF(TMP0->PAA_TPENCE == '6', 'Aguard. Usuario',IIF(TMP0->PAA_TPENCE == '7', 'Aguard. Terceiro', IIF(TMP0->PAA_TPENCE == '8', 'Aguard. Atendimento', ''))))) 
			TRB->PAA_TPITIL := IIF(TMP0->PAA_TPITIL == '1', 'Incidente','Requisicao')
			TRB->HR_CHAMAD  := cHoras
			
		TRB->(MsUnLock())
		TMP0->(dbSkip())
		
	Enddo 
	
Return({cArqTRB,cInd1}) 

/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author user
	@since 29/06/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function HeadBrow()

	Local aHead := {}
	
	//Campos que aparecerão na MBrowse, como não é baseado no SX3 deve ser criado.
	//Sequência do vetor: Título, Campo, Tipo, Tamanho, Decimal, Picture
	
	AAdd( aHead, { "Chamado"      , {|| TRB->PAA_CHAMAD} ,"C", 06, 0, "" } )
	AAdd( aHead, { "Usuario"      , {|| TRB->PAA_USUARI} ,"C", 40, 0, "" } )
	AAdd( aHead, { "Desc. Rotina" , {|| TRB->PAA_DSRVAC} ,"C", 30, 0, "" } )
	AAdd( aHead, { "Des. Resumida", {|| TRB->PAA_DRESUM} ,"C", 20, 0, "" } )
	AAdd( aHead, { "Prior. Gestor", {|| TRB->PAA_PRISCR} ,"C", 09, 0, "" } )
	AAdd( aHead, { "Sprint"       , {|| TRB->PAA_SPRINT} ,"C", 09, 0, "" } )
	AAdd( aHead, { "Data Inclusao", {|| TRB->PAA_SOLICI} ,"D", 08, 0, "" } )
	AAdd( aHead, { "Idade"        , {|| TRB->IDADE}      ,"C", 09, 0, "" } )
	AAdd( aHead, { "Data Inicial" , {|| TRB->PAA_DTINI } ,"D", 08, 0, "" } )
	AAdd( aHead, { "Data Previsao", {|| TRB->PAA_DTPREV} ,"D", 08, 0, "" } )
	AAdd( aHead, { "Especialista" , {|| TRB->PA6_DESPE } ,"C", 50, 0, "" } )   
	AAdd( aHead, { "Tecnico"      , {|| TRB->PAA_NOMTEC} ,"C", 50, 0, "" } )         
	AAdd( aHead, { "Andamento"    , {|| TRB->PAA_TPENCE} ,"C", 01, 0, "" } ) 
	AAdd( aHead, { "Legenda"      , {|| TRB->LEGENDA}    ,"C", 20, 0, "" } ) 
	AAdd( aHead, { "Atendimento"  , {|| TRB->PAA_TPITIL} ,"C", 10, 0, "" } ) 
	AAdd( aHead, { "Horas Chamado", {|| TRB->HR_CHAMAD } ,"C", 08, 0, "" } )  
    
Return( aHead )                              

/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author user
	@since 29/06/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
USER FUNCTION AcompGestao()   

	Private aArea:=GetArea()
	Private nopcX:=0
	Private cDescAcom:=""
	Private cHtml:=""
	Private cTo2 :=Space(200)

	U_ADINF009P('ADINF006P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'BROWSER PARA OS GESTORES VEREM OS CHAMADOS DA TI')
	
	//+------------------------------------------------+
	//|Valida quanto ao status do chamado              |
	//+------------------------------------------------+
	if TRB->PAA_TPENCE $ '13'
		MsgInfo("Nao e' possivel solicitar acompanhamento a esse chamado"+CRLF+"Chamado encerrado ou transferido")
		Return
	EndIF
	
	//+------------------------------------------------+
	//|Chamada da Tela de Interassao                   |
	//+------------------------------------------------+
	nopcX:=MntCalPos()
	
	//+------------------------------------------------+
	//|TRATA O CANCELAMENTO DA ROTINA                  |
	//+------------------------------------------------+
	If nOpcx==0
		Return(NIL)
	EndIf
	
	//MONTA A STRING
	cDescAcomCH:=CRLF+;
	"EM "+DTOC(DATE())+" "+left(time(),5)+" - SOLICITA?O DE ACOMPANHAMENTO"+CRLF+cDescAcom+CRLF+;
	"--------------------------------------------------------------------------------"
	
	//Monta corpo de Email
	cHtml+='<html>'
	cHtml+='<head>'
	cHtml+='<title>SOLICITA?O DE ACOMPANHAMENTO DE CHAMADO</title>'
	cHtml+='</head>'
	cHtml+='<body>'
	
	cHtml+='<table border="1" cellpadding="0" cellspacing="0"  width="70%">'
	cHtml+='<tr>'
	cHtml+='	<th> Chamado:</th>'
	cHtml+='	<td>'+TRB->PAA_CHAMAD+'</td>'
	cHtml+=' </tr>'
	cHtml+='</table>'
	
	cHtml+='<H2>Solicitacao de Acompanhamento</H2>'
	
	cHtml+='<table border="1" cellpadding="0" cellspacing="0"  width="70%">'
	cHtml+='  <tr>'
	//cHtml+='  		<td>It</td>'
	cHtml+='  		<td >Descricao</td>'
	cHtml+='			<td>Solicitante</td>'
	cHtml+='			<td>Data</td>'
	
	cHtml+='</tr>'
	cHtml+='<tr >'
	//  		<td>001</td>
	cHtml+='		<td ><pre>'+cDescAcom+'</pre></td>'
	cHtml+='		<td>'+CUSERNAME+'</td>             '
	cHtml+='		<td>'+DTOC(DATE())+' - '+TIME()+'</td>'
	cHtml+='</tr>	'
	
	cHtml+='</table> '
	
	cHtml+='</body> '
	cHtml+='</html>'
	
	_cTo   := 'ti.todos@adoro.com.br'
	_cFrom := Alltrim(UsrRetMail(__cUserID))
	_cCC   := Alltrim(UsrRetMail(__cUserID))
	
	MsAguarde({|| U_CHEnviaMail( _cFrom, _cTo,_cCC, "Solicitacao de Acompanhamento ["+TRB->PAA_CHAMAD+"]",, cHtml )}, "Enviando Email", "Enviando Solicita?o", .F. )
	
	RestArea(aArea)     
	
RETURN(NIL)

//+==================================================+
//|Monta tela de acompanhamento dos chamados         |
//+==================================================+
Static Function MntCalPos()

	Local oDlg1,oSay1,oSay2,oDescAcom,oTo2
	Local aButtons:={}
	Private nopcX:=0
	
	oDlg1      := MSDialog():New( 216,340,689,883,"Acompanhamento",,,.F.,,,,,,.T.,,,.T. )
	oSay1      := TSay():New( 028,004,{||"Descricao"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oDescAcom  := TMultiGet():New( 040,004,{|u| If(PCount()>0,cDescAcom:=u,cDescAcom)},oDlg1,256,128,,,CLR_BLACK,CLR_WHITE,,.T.,"",,,.F.,.F.,.F.,,,.F.,,  )
	
	oDlg1:bInit := {|| EnchoiceBar(oDlg1, {|| nopcX:=1,oDlg1:End()}, {|| nopcX:=0,oDlg1:End()},,aButtons)}
	oDlg1:Activate(,,,.T.)

Return(nopcX)

/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author user
	@since 29/06/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
USER FUNCTION LegGestao()

	Local _aArea		:= GetArea()
	Local _aLegenda	:= {{ "BR_AMARELO"	, OemToAnsi( STR0077 ) },;
	                    { "BR_BRANCO"	, OemToAnsi( STR0170 ) },;
	                    { "BR_AZUL"		, OemToAnsi( STR0165 ) },;
	                    { "BR_LARANJA"	, OemToAnsi( STR0075 ) },;
 	                    { "BR_PINK"		, OemToAnsi( STR0076 ) },;
 	                    { "BR_CINZA"	, OemToAnsi( STR0164 ) },;
 	                    { "BR_PRETO"	, OemToAnsi( STR0079 ) },;
	                    { "BR_VERDE"	, OemToAnsi( STR0166 ) },;
	                    { "BR_VERMELHO"	, OemToAnsi( STR0078 ) } }

	U_ADINF009P('ADINF006P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'BROWSER PARA OS GESTORES VEREM OS CHAMADOS DA TI')						
	
	BrwLegenda( OemToAnsi( STR0007 ), OemToAnsi( STR0023 ), _aLegenda )
	
	RestArea( _aArea )

RETURN ( NIL ) 

/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author user
	@since 29/06/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
USER FUNCTION VISUGESTAO()

	Local oDlg  := NIL
	Local oMemo := NIL
	Local cDesc := ''

	U_ADINF009P('ADINF006P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'BROWSER PARA OS GESTORES VEREM OS CHAMADOS DA TI')
	
	DbSelectArea("PAA")
    PAA->(dbSetOrder(2)) 
    
	    IF PAA->(DbSeek(xFilial("PAA")+TRB->PAA_CHAMAD)) // Busca exata
		
			cDesc := PAA->PAA_ESCOPO
		
		ENDIF
	
	PAA->(dbCloseArea())
	
	Define MSDialog oDlg Title "Chamado" From 0,0 To 0,0 Pixel
	
		oDlg:lMaximized := .T. 
	        
	    @ 001,001 TO 298,745 OF oDlg PIXEL
	    
	    @ 010,010 SAY 'Chamado' SIZE 55, 07 OF oDlg PIXEL
        @ 020,010 MSGET TRB->PAA_CHAMAD SIZE 30, 10 OF oDlg PIXEL 
		
		@ 010,050 SAY 'Usuario' SIZE 55, 07 OF oDlg PIXEL
        @ 020,050 MSGET TRB->PAA_USUARI SIZE 95, 10 OF oDlg PIXEL 
		
		@ 010,160 SAY 'Desc. Rotina' SIZE 55, 07 OF oDlg PIXEL
        @ 020,160 MSGET TRB->PAA_DSRVAC SIZE 80, 10 OF oDlg PIXEL
		
		@ 010,250 SAY 'Desc. Resumida' SIZE 55, 07 OF oDlg PIXEL
        @ 020,250 MSGET TRB->PAA_DRESUM SIZE 70, 10 OF oDlg PIXEL
		
		@ 010,330 SAY 'Prior. Gestor' SIZE 55, 07 OF oDlg PIXEL
        @ 020,330 MSGET TRB->PAA_PRISCR SIZE 07, 10 OF oDlg PIXEL 
		
		@ 010,380 SAY 'SPRINT' SIZE 55, 07 OF oDlg PIXEL
        @ 020,380 MSGET TRB->PAA_SPRINT SIZE 07, 10 OF oDlg PIXEL
		
		@ 040,010 SAY 'Dt. Inclusao' SIZE 55, 07 OF oDlg PIXEL
        @ 050,010 MSGET DTOC(TRB->PAA_SOLICI) SIZE 40, 10 OF oDlg PIXEL
		
		@ 040,060 SAY 'Idade Chamado' SIZE 55, 07 OF oDlg PIXEL
        @ 050,060 MSGET TRB->IDADE SIZE 40, 10 OF oDlg PIXEL           
		
		@ 040,110 SAY 'Dt. Inicial' SIZE 55, 07 OF oDlg PIXEL
        @ 050,110 MSGET DTOC(TRB->PAA_DTINI) SIZE 40, 10 OF oDlg PIXEL
		
		@ 040,160 SAY 'Dt. Previsao' SIZE 55, 07 OF oDlg PIXEL
        @ 050,160 MSGET DTOC(TRB->PAA_DTPREV) SIZE 40, 10 OF oDlg PIXEL
		
		@ 070,010 SAY 'Especialista' SIZE 55, 07 OF oDlg PIXEL
        @ 080,010 MSGET TRB->PA6_DESPE SIZE 110, 10 OF oDlg PIXEL 
		
		@ 070,130 SAY 'Tecnico' SIZE 55, 07 OF oDlg PIXEL
        @ 080,130 MSGET TRB->PAA_NOMTEC SIZE 110, 10 OF oDlg PIXEL
		
		@ 100,010 SAY 'Legenda' SIZE 55, 07 OF oDlg PIXEL
        @ 110,010 MSGET TRB->LEGENDA SIZE 60, 10 OF oDlg PIXEL 
		
		@ 100,080 SAY 'Atendimento' SIZE 55, 07 OF oDlg PIXEL
        @ 110,080 MSGET TRB->PAA_TPITIL SIZE 60, 10 OF oDlg PIXEL
		
		@ 100,150 SAY 'Horas Chamado' SIZE 55, 07 OF oDlg PIXEL
        @ 110,150 MSGET TRB->HR_CHAMAD SIZE 40, 10 OF oDlg PIXEL
		
		@ 130,010 SAY 'Descricao Chamado' SIZE 55, 07 OF oDlg PIXEL
		@ 140,010 Get oMemo Var cDesc MEMO HScroll ReadOnly Size 300,150  Of oDlg Pixel
	
	    oMemo:bRClicked := {||AllwaysTrue()}
	
		Define SButton From 300, 720 Type 20 Action oDlg:End() Enable Of oDlg Pixel
	                                                             
	Activate MsDialog oDlg Centered
	
Return ( Nil )

/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author user
	@since 29/06/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
User function ApontOS()

	Local oDlg  := NIL
	Local oMemo := NIL
	Local cDesc := ''

	U_ADINF009P('ADINF006P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'BROWSER PARA OS GESTORES VEREM OS CHAMADOS DA TI')
	
	DbSelectArea("PAI")
	PAI->(dbgotop())
    PAI->(dbSetOrder(1)) 
    While PAI->(!EOF()) 
       
        IF TRB->PAA_CHAMAD == PAI->PAI_CHAMAD
    
	    //IF PAI->(DbSeek(xFilial("PAA")+TRB->PAA_CHAMAD)) // Busca exata
		
			cDesc += 'Data: '  + DTOC(PAI->PAI_DATA)        + ' - '             + ;
			         'Horas: ' + CVALTOCHAR(PAI->PAI_HORAS) + ' - '             + ;
			         'Desc: '  + PAI->PAI_DESC              + CHR(13) + CHR(10) + ;
			         CHR(13) + CHR(10)
		
		ENDIF
		
		PAI->(dbSkip())
		
	ENDDO
	
	PAI->(dbCloseArea())
	
	Define MSDialog oDlg Title "Apontamento de Horas" From 0,0 To 0,0 Pixel
	
		oDlg:lMaximized := .T. 
	        
	    @ 001,001 TO 298,745 OF oDlg PIXEL
	    
	    @ 010,010 SAY 'Apontamento de Horas TI:' SIZE 80, 07 OF oDlg PIXEL
		@ 020,010 Get oMemo Var cDesc MEMO HScroll ReadOnly Size 730,270  Of oDlg Pixel
	
	    oMemo:bRClicked := {||AllwaysTrue()}
	
		Define SButton From 300, 720 Type 20 Action oDlg:End() Enable Of oDlg Pixel
	                                                             
	Activate MsDialog oDlg Centered
		
Return(NIL)

/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author user
	@since 29/06/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function SqlGeral()

	BeginSQL Alias "TMP0"
			
			%NoPARSER%  
			
			SELECT PAA_CHAMAD,
				   PAA_USUARI,
				   PAA_DSRVAC,
				   PAA_DRESUM,
				   PAA_PRISCR,
				   PAA_SPRINT,
				   PAA_SOLICI,
				   PAA_DTINI,
				   PAA_DTPREV, 
				   PA6_DESPE,
				   PAA_NOMTEC, 
				   PAA_TPENCE,
				   PAA_TPITIL,
				   PAA_SRVACT
			
			  FROM %Table:AA1% , %Table:PA6%,%Table:PAA%
			
			 WHERE AA1_CODUSR              = %EXP:__cUserID%
			   AND %Table:AA1%.D_E_L_E_T_ <> '*'
			   AND (PA6_RESP               = AA1_CODTEC
	 		    OR PA6_RESP2               = AA1_CODTEC)
			   AND PA6_BLQ                 = '1'
			   AND %Table:PA6%.D_E_L_E_T_ <> '*'
			   AND (PAA_TECNIC             = PA6_ESPE
			    OR PAA_SRVACT              = PA6_CODIGO) 
			   AND PAA_FIM                 = ''
			   AND PAA_GRACT               = '01'
			   AND %Table:PAA%.D_E_L_E_T_ <> '*'
			   
			GROUP BY PAA_CHAMAD,PAA_USUARI,PAA_DSRVAC,PAA_DRESUM,PAA_PRISCR,PAA_SPRINT,PAA_SOLICI,PAA_DTINI,PAA_DTPREV,PA6_DESPE,PAA_NOMTEC,PAA_TPENCE,PAA_TPITIL,PAA_SRVACT
			
			ORDER BY PAA_TPENCE,PAA_SPRINT,PAA_DTINI,PAA_DTPREV

	EndSQl             

RETURN(NIL)

/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author user
	@since 29/06/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
STATIC FUNCTION SqlHoras(cCodChamado)

	BeginSQL Alias "TRC"
			
			%NoPARSER%  
			
			SELECT SUM(CONVERT(FLOAT,REPLACE(PAI_HORAS,',','.'))) AS HORAS
  	          FROM PAI010
		    WHERE  PAI_CHAMAD = %EXP:cCodChamado%

	EndSQl             

RETURN(NIL)