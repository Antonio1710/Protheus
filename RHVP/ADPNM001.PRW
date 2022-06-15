#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "RWMAKE.CH"     
#INCLUDE "TOPCONN.CH"
#INCLUDE "PONWORK.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADPNM001  ºAutor  ³NGSi                º Data ³  18/09/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para Start do Processo de Leitura                    º±±
±±º          ³e apontamento do Ponto.                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico ADORO                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³Chamado³  Motivo da Alteracao                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Adriana     ³11/06/19³  TI   ³Conout para acompanhamento de email,     ³±±
±±³            ³        ³       ³correcao autenticacao email, correcao    ³±±
±±³            ³        ³       ³error.log Alias does not exist: ZBN      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function ADPNM001(aParam)

Local nOpca := 0
Local aRegs	:={}
Local cPerg := ""
Local aSays:={ }, aButtons:= { } 
Local cPathArq 
Local cNewArq

Private lGrvZa4 := .F.
Private _lJob 
private _cEmp
private _cFil
private cEol  :=   CHR(13)+CHR(10)
                
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//|Verifica se a Rotina esta recebendo Parametros - Caso esteja a mesma esta sendo executada pelo JOB  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If aParam == Nil
	_lJob := .F.
Else
	_lJob := aParam[1]
	_cEmp := aParam[2]
	_cFil := aParam[3]

	RPCClearEnv()
    RPCSetType(3)  //Nao consome licensas

	PREPARE ENVIRONMENT EMPRESA ( _cEmp ) FILIAL ( _cFil ) Modulo "PON" Tables "RFD", "RFE", "SP8", "SP0"

	// Garanto uma única thread sendo executada - // Adoro - Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - fwnm - 29/06/2020
	If !LockByName("ADPNM001"+_cEmp, .T., .F.)
		ConOut("[ADPNM001] - Existe outro processamento sendo executado! Verifique...")
		RPCClearEnv()
		Return
	EndIf

	// @history Ticket 70142 	- Rodrigo Mello | Flek - 22/03/2022 - Substituicao de funcao PTInternal por FWMonitorMsg MP 12.1.33
	//FWMonitorMsg(ALLTRIM(PROCNAME()))

	//INICIO CHAMADO 033882 - WILLIAM COSTA - Grava log de Execucao Schedule
	logZBN("1") //Log início.
	//FINAL CHAMADO 033882 - WILLIAM COSTA - Grava log de Execucao Schedule

EndIf

GeraArq()	  

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Destrava a rotina para o usuário	    ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	UnLockByName("ADPNM001"+cEmpAnt)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADPNM001  ºAutor  ³GILBERTO - NGSI     º Data ³  18/09/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para geração do arquivo texto para ser utilizado na  º±±
±±º          ³leitura e apontamento do Ponto.                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico ADORO                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function GeraArq()

Local cQuery_ 
Local cPathArq 
Local dDataDe  
Local dDataAte 
Local cMatDe  
Local cMatAte 
Local cCont
Local nRet
Local lGrvLido	:= .F.     
Local cRelogio  := GetMv( "MV_#RELOG" , .F. , "" )   //Apenas relogios ativos para o schedule, que tem arquivo txt, Ex: relogio99.txt, onde 99 e o codigo constante no parametro
local x
//Local cPergPon 	:= ""
//Local lAchou	:= .F.


RpcSetEnv(_cEmp, _cFil,, 'FOLHA' )   //Seta o Ambiente

U_ADINF009P('ADPNM001' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina para Start do Processo de Leitura e apontamento do Ponto.')

cEMail    := GETMV( "NG_SPMAIL",,"" )

		FOR X:=1 TO 20 //10 alterado por Adriana chamado 034890 EM 28/04/2017
            
			If strzero(x,2) $ cRelogio //Incluido por Adriana chamado 034890 EM 28/04/2017

            	IF _lJOB
   	 	        	cPathArq := "\relogio\"+DTOS(DATE()) +"\relogio"+ STRZERO(X,2)+ ".TXT"

   		    	ELSE   
    		    	cPathArq := "Z:\Saida\relogio"+ STRZERO(X,2)+ ".TXT"
            	ENDIF
            
		    	cNewArq  := "\RELOGIO\RELOGIO"+ STRZERO(X,2) + ".TXT"

				COPY FILE &(cPathArq) TO &(cNewArq)

				If !File(cPathArq)
 					Conout("Erro. Arquivo nao copiado: ",cNewArq ) 
 				Else
 					Conout("OK. Arquivo copiado: ",cNewArq )  				
				EndIf
				
			Endif
		    
		 NEXT X   

		// Chamada da Rotina de Leitura e Apontamento
		u_XPonScheduler( {_cEmp	,;	//01 -> Codigo da Empresa no SIGAMAT
					     _cFil,;            //               _cFil	,;	//02 -> Codigo da Filial no SIGAMAT
						.T.		,;	//03 -> Utilizar os Parametros do SX1 para o Processo de Leitura / Apontamento
						.T.		,;	//04 -> Limitar a Data Final do Apontamento aa DataBase do Sistema
						.T.		,;	//05 -> Efetuar o Apontamento Por Filial
						.F.		,;	//06 -> Efetua Apontamento para Relogios nao Lidos
						.T.		,;	//07 -> Forcar o Reapontamento das Marcacoes   
						.T.		 ;  //08 -> Processa apenas a filial passada como parametro 
					   })
	
		// Renomeia o Arquivo Texto Apos o Processamento
		 FOR X:=1 TO 20 //10 alterado por Adriana chamado 034890 EM 28/04/2017

			If strzero(x,2) $ cRelogio //Incluido por Adriana chamado 034890 EM 28/04/2017

		    	cPathArq := "\RELOGIO\RELOGIO"+ STRZERO(X,2)+ ".TXT"
		    	cNewArq  := "\RELOGIO\RELOGIO"+ STRZERO(X,2)+ "-" + Dtos(Date()) + "-" + StrTran(Time(),":","") + ".TXT"
		    	If fRename( cPathArq, cNewArq ) < 0
	    			Conout('Rotina ADPNM001 - Erro ao Renomear o arquivo texto ' + cPathArq)
		    	Else
			    	Conout('Rotina ADPNM001 - Arquivo texto renomeado para ' + cNewArq)
		    	EndIf 
		    	
			Endif
		    
		 NEXT X   


    /// tratamento do envio de email

    cSubject  := "PROCESSAMENTO DO SCHEDULLE DO PONTO - Empresa "+_cEmp  //acrescentada empresa ao assunto do email.

    cMensagem := '<p>O Schedulle de Leitura e apontamento foi processado!</p>' + cEol
    cMensagem += '<p>Data: '+DTOC(date()) + ' as ' + Time() + cEol

    cEmail    := cEMail 
    
    aFiles := {}
    
    lTEXT := .t. 
    
    //alterado por Adriana para acompanhar envio em 11/06/19
    If fEnvMail( cSubject, cMensagem, cEMail, aFiles, lText )
    	Conout("Rotina ADPNM001 - Empresa "+_cEmp+" eMail enviado.") 
    else
    	Conout("Rotina ADPNM001 - Empresa "+_cEmp+" eMail NAO enviado.")
    Endif
    //
    /// fim do tratamento do envio do email.
    

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Finaliza o Ambiente da Empresa										³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		If _lJob 

			logZBN("2") //Log fim.	//Alterado por Adriana chamada antes de resetar o ambiente em 11/06/19

			RESET ENVIRONMENT

			Conout('Rotina ADPNM001 - Finalizada')
			CONOUT('')
			
		endif	

Return()

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ As Instrucoes Abaixo deverao ser Incluidas no INI do Server			³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

[ONSTART]
JOBS=LEITURA_CLASSIFICACAO	//Define o Nome do Job

[LEITURA_CLASSIFICACAO]		//Configuracoes do Job
Main=u_StartJobPon			//ou Main=wfStart() se tiver apenas uma empresa
Environment=Environment		//Nome do Environment que devera ser utilizado


ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ A chamada abaixo devera ser Incluida no Agendamento do WorkFlow		³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
u_PonScheduler(		"01"	,;	//01 -> Codigo da Empresa no SIGAMAT
				 	"01"	,;	//02 -> Codigo da Filial no SIGAMAT
				 	.F.		,;	//03 -> Utilizar os Parametros do SX1 para o Processo de Leitura / Apontamento
				 	.T.		,;	//04 -> Limitar a Data Final do Apontamento aa DataBase do Sistema
				 	.T.		,;	//05 -> Efetuar o Apontamento Por Filial
				 	.F.		,;	//06 -> Efetua Apontamento para Relogios nao Lidos
				 	.F.		,;	//07 -> Forcar o Reapontamento das Marcacoes   
				 	.F.		 ;  //08 -> Processa apenas a filial passada como parametro 
			   )

ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³PonScheduler ³ Autor ³ GILBERTO - NGSI    ³ Data ³18/09/2015³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Prepara o Ambiente da Empresa e Executa a  Leitura/Apontamen³
³          ³to														    ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³u_PonScheduler( aUserDefParam )								³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³aUserDefParam -> Array contendo os Parametros do Usuario	³
³          ³       														³
³Conteudo  ³aUserDefParam[1]Codigo da Empresa no SIGAMAT				³
³          ³       														³
³          ³aUserDefParam[2]Codigo da Filial no SIGAMAT  				³
³          ³       														³
³          ³aUserDefParam[3]Se .T. caracterizara que o Programa   devera³
³          ³                utilizar os Parametros do Programa de  Leitu³
³          ³                ra/Apontamento, confome Definidos pelo 	Usua³
³          ³                rio. Caso Contrario Ira considerar os Parame³
³          ³                tros De/Ate de Forma Generica. 				³
³          ³       														³
³          ³aUserDefParam[4]Se a Data Fim dos Parametros deve ser Litida³
³          ³                da a Menor Data entra a DataBase e o Fim  do³
³          ³                Periodo de Apontamento						³
³          ³aUserDefParam[5]Se Deve Processar Por Filial                ³
³          ³aUserDefParam[6]Se Deve Efetuar Apontamento Quando nao Conse³
³          ³                gui Ler o Arquivo do Relogio                ³
³          ³aUserDefParam[7]Se Deve Forcar o Reapontamento 				³
³          ³aUserDefParam[8]Se Utiliza a Filial passada como a que deve-³
³          ³                ra ser processada como parametro.			³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³PonWork                                                    	³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Observacao³Essa Funcao devera ser Cadastrada no Agendamento           	³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
User Function XPonScheduler( aUserDefParam )

//	_cEmp	,;	//01 -> Codigo da Empresa no SIGAMAT
//	_cFil	,;	//02 -> Codigo da Filial no SIGAMAT
//	.T.		,;	//03 -> Utilizar os Parametros do SX1 para o Processo de Leitura / Apontamento
//	.T.		,;	//04 -> Limitar a Data Final do Apontamento aa DataBase do Sistema
//	.T.		,;	//05 -> Efetuar o Apontamento Por Filial
//	.F.		,;	//06 -> Efetua Apontamento para Relogios nao Lidos
//	.T.		,;	//07 -> Forcar o Reapontamento das Marcacoes   
//	.T.		 ;  //08 -> Processa apenas a filial passada como parametro 


Local aFiliais			:= {}
Local cEmp				:= ""
Local cFil				:= ""
Local lWorkFlow		    := .T.
Local lUserDefParam		:= aUserDefParam[3]
Local lLimitaDataFim	:= aUserDefParam[4]
Local lProcFilial		:= aUserDefParam[5]
Local lApontaNaoLidas	:= aUserDefParam[6]
Local lForceReaponta	:= aUserDefParam[7]  
Local lSomentecFil		:= aUserDefParam[8]
Local nUserParam		:= 0.00
Local nLenParam			:= 0.00
Local nFilial			:= 0.00

Local dDataDe
Local dDataAte
Local cPergPon 	:= ""
Local lAchou	:= .F.

U_ADINF009P('ADPNM001' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina para Start do Processo de Leitura e apontamento do Ponto.')

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Enviando Mensagens para o Console do Server                 			³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
ConOut("")
ConOut( STR0001 )	//"Iniciando U_PonScheduler()..."
ConOut("")

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Verifica os Parametros passados          								³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
IF ( !Empty( aUserDefParam ) .and. ValType( aUserDefParam ) == "A" )
	nLenParam := Len( aUserDefParam )
	For nUserParam := 1 To nLenParam
		Do Case
			Case ( nUserParam == 1 ) ; cEmp          	:= IF( ( ValType( aUserDefParam[ nUserParam ] ) == "C" ) , aUserDefParam[ nUserParam ] , ""	 )
			Case ( nUserParam == 2 ) ; cFil				:= IF( ( ValType( aUserDefParam[ nUserParam ] ) == "C" ) , aUserDefParam[ nUserParam ] , ""	 )
			Case ( nUserParam == 3 ) ; lUserDefParam	:= IF( ( ValType( aUserDefParam[ nUserParam ] ) == "L" ) , aUserDefParam[ nUserParam ] , .F. )
			Case ( nUserParam == 4 ) ; lLimitaDataFim	:= IF( ( ValType( aUserDefParam[ nUserParam ] ) == "L" ) , aUserDefParam[ nUserParam ] , .T. )
			Case ( nUserParam == 5 ) ; lProcFilial		:= IF( ( ValType( aUserDefParam[ nUserParam ] ) == "L" ) , aUserDefParam[ nUserParam ] , .F. )
			Case ( nUserParam == 6 ) ; lApontaNaoLidas	:= IF( ( ValType( aUserDefParam[ nUserParam ] ) == "L" ) , aUserDefParam[ nUserParam ] , .F. )
			Case ( nUserParam == 7 ) ; lForceReaponta	:= IF( ( ValType( aUserDefParam[ nUserParam ] ) == "L" ) , aUserDefParam[ nUserParam ] , .F. )
			Case ( nUserParam == 8 ) ; lSomentecFil		:= IF( ( ValType( aUserDefParam[ nUserParam ] ) == "L" ) , aUserDefParam[ nUserParam ] , .F. )
		End Case
	Next nUserParam
EndIF

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Verifica se Empresa/Filial foram Passados								³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
IF !Empty( cEmp ) .and. !Empty( cFil )

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Enviando Mensagens para o Console do Server                 			³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	ConOut("")
	ConOut( STR0002 ) //"Preparando Ambiente da Empresa. Aguarde... "
	ConOut("")
	
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Prepara Ambiente da Empresa											³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
//	PREPARE ENVIRONMENT EMPRESA ( cEmp ) FILIAL ( cFil ) Modulo "PON" Tables "RFD", "RFE", "SP8", "SP0", "ZA4"
	
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Redefine nModulo de forma a Garantir que o Modulo seja o SIGAPON		³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		SetModulo( "SIGAPON" , "PON" )

		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Enviando Mensagens para o Console do Server                 			³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		ConOut("")
		ConOut("ROTINA PonScheduler - AJUSTANDO RESPOSTAS NO GRUPO DE PERGUNTA PNM010...")
		ConOut("")
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³GRAVA PARAMETROS PARA LEITURA E APONTAMENTO	                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cPergPon	:= PADR("PNM010",LEN(SX1->X1_GRUPO))
		
		//If Val(Strtran(Left(Time(),5) ,":",".")) > 03.00
		//	dDataDe  := DTOS(Date())
		//Else
		//	dDataDe  := DTOS(Date()-1)
		//EndIf

		dDataDe  := DTOS(Date()-1)
		dDataAte := DTOS(Date())
		
		IF DAY(Date()) = 18 				
		   DDATABASE:= DATE() - 1
		ENDIF
		   
		DbSelectArea("SX1")
		DbSetOrder(1)
		  
		IF lAchou := ( SX1->( dbSeek( cPergPon + "01" , .T. ) ) )
			While SX1->(!EOF()) .And. SX1->X1_GRUPO == cPergPon
				RecLock("SX1",.F.)
				    If SX1->X1_ORDEM == "01"          // filial de
						SX1->X1_CNT01 := "0"  // cFil 
				    ElseIf SX1->X1_ORDEM == "02"     // filial ate
						SX1->X1_CNT01 := "99" // cFil 
				    ElseIf SX1->X1_ORDEM == "03"     //Centro de Custo De ?          
						SX1->X1_CNT01 := "0"		    
				    ElseIf SX1->X1_ORDEM == "04"     //Centro de Custo Ate ?         
						SX1->X1_CNT01 := "ZZZZZZZZZ"		    
				    ElseIf SX1->X1_ORDEM == "05"     //Turno De ?                    
						SX1->X1_CNT01 := "0"
				    ElseIf SX1->X1_ORDEM == "06"     //Turno Ate ?                   
						SX1->X1_CNT01 := "ZZZ"
				    ElseIf SX1->X1_ORDEM == "07"     //Matricula De ?                
						SX1->X1_CNT01 := "0"
				    ElseIf SX1->X1_ORDEM == "08"     //Matricula Ate ?                
						SX1->X1_CNT01 := "ZZZZZZ"
				    ElseIf SX1->X1_ORDEM == "09"     //Nome De ?                     
						SX1->X1_CNT01 := "A"
				    ElseIf SX1->X1_ORDEM == "10"     //Nome Ate ?                     
						SX1->X1_CNT01 := "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"
				    ElseIf SX1->X1_ORDEM == "11"     //Relogio De ?                  
						SX1->X1_CNT01 := "0  "
				    ElseIf SX1->X1_ORDEM == "12"     //Relogio Ate ?                 
						SX1->X1_CNT01 := "999"
				    ElseIf SX1->X1_ORDEM == "13"     //Periodo Inicial ?             
						SX1->X1_CNT01 := dDataDe
				    ElseIf SX1->X1_ORDEM == "14"     //Periodo Final ?               
						SX1->X1_CNT01 := dDataAte
				    ElseIf SX1->X1_ORDEM == "15"     //Regra de Apont.De ?           
						SX1->X1_CNT01 := "01"
				    ElseIf SX1->X1_ORDEM == "16"     //Regra de Apont.Ate ?          
						SX1->X1_CNT01 := "99"        
				    ElseIf SX1->X1_ORDEM == "17"     // Processamento ?               
						SX1->X1_CNT01 :=  "3" //Space( Len( SX1->X1_CNT01 ) )
				    ElseIf SX1->X1_ORDEM == "18"	//Leitura/Apontamento ?         	    		    		    		    		    		    		    		    		    		    		    		    
						SX1->X1_CNT01 :=  "5" //Space( Len( SX1->X1_CNT01 ) )
				    ElseIf SX1->X1_ORDEM == "19"	//Reapontar ?                   	    		    		    		    		    		    		    		    		    		    		    		    
						SX1->X1_CNT01 :=  "3"  //Space( Len( SX1->X1_CNT01 ) )
				    ElseIf SX1->X1_ORDEM == "20"	// Ler a partir do ?            	    		    		    		    		    		    		    		    		    		    		    		    
						SX1->X1_CNT01 :=  "1"   //Space( Len( SX1->X1_CNT01 ) )
				    ElseIf SX1->X1_ORDEM == "21"	//Categorias ?                  	    		    		    		    		    		    		    		    		    		    		    		    
						SX1->X1_CNT01 := "ACDEGHIJMPST"
				    ElseIf SX1->X1_ORDEM == "22"	//Situacoes a gerar ?           	    		    		    		    		    		    		    		    		    		    		    		    
						SX1->X1_CNT01 := " ADFT"
					EndIf		    		    		    		    		    				
				MsUnLock()
			    SX1->(DbSkip())
			EndDo
				
		EndIF	
		
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Processando a Leitura/Apontamento                           			³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		IF ( lProcFilial )
		
			If lSomentecFil 
				/*
				ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³ Processa somente a Filial passada como parametro            			³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				aFiliais := GetFilRecnos(cEmpAnt, cFil, cFil)
			Else 
				/*
				ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³ Processa todas as Filiais da Empresa passada como parametro  			³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				aFiliais := GetFilRecnos(cEmpAnt , Space(FWGETTAMFILIAL), Replicate("Z", FWGETTAMFILIAL))
			Endif
        
            For nFilial := 1 To Len( aFiliais )
			
				/*
				ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³ Posiciona o SM0 na Filial a ser Processada                  			³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				SM0->( dbGoto( aFiliais[ nFilial , 02 ] ) )

				/*
				ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³ Enviando Mensagens para o Console do Server                 			³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				ConOut("")
				//"Inicio da Leitura/Apontamento em: "###" as "
				ConOut( STR0003  + Dtoc( MsDate() ) + STR0004 + Time() )
				ConOut("")
				//"Empresa: "
				ConOut( STR0005 + SM0->( FWGETCODFILIAL + " - " + AllTrim( M0_NOMECOM ) ) )
				ConOut("")
				//"Filial:  "
				ConOut( STR0006 + SM0->( FWGETCODFILIAL + " - " + AllTrim( M0_FILIAL ) + "/" + AllTrim( M0_NOME ) ) )
				ConOut("")

				/*
				ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³ Chamada a Funcao de Leitura e Apontamento das Marcacoes     			³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				Ponm010(	lWorkFlow					,;	//Define Que a Chamada Esta Sendo Efetuada Atraves do WorkFlow
						 	lUserDefParam				,;	//Verifica Se Devera Considerar os Parametros Pre-Definidos Pelo Usuario
						 	lLimitaDataFim				,;	//Verifica Se Devera Limitar a Data Fim a Menor Data entre a DataBase e o Periodo Final de Apontamento
							aFiliais[ nFilial , 01 ]	,;	//Filial a ser processada
						 	lProcFilial					,;	//Processo por Filial
						 	lApontaNaoLidas				,;	//Se Aponta as Marcacoes para as Filiais nao Lidas
						 	lForceReaponta				 ;	//Forcar o Reapontamento das Marcacoes
						)

				/*
				ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³ Garante o Posicionamento no SIGAMAT                         			³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				SM0->( MsGoto( aFiliais[ nFilial , 02 ] ) )

				/*
				ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³ Enviando Mensagens para o Console do Server                 			³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				ConOut("")
				// "Final da Leitura/Apontamento em: "###" as "
				ConOut(STR0007 + Dtoc( MsDate() ) + STR0004 + Time() )
				ConOut("")
				//"Empresa: "
				ConOut(STR0005 + SM0->( M0_CODIGO + " - " + AllTrim( M0_NOMECOM ) ) )
				ConOut("")
				//"Filial:  "
				ConOut(STR0006 + FWGETCODFILIAL + " - " +  SM0->(AllTrim(M0_FILIAL) + "/" + AllTrim(M0_NOME) ) )
				ConOut("")

            Next nFilial
		Else

			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Enviando Mensagens para o Console do Server                 			³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			ConOut("")
			//"Inicio da Leitura/Apontamento em: "###" as "
			ConOut( STR0003  + Dtoc( MsDate() ) + STR0004 + Time() )
			ConOut("")

			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Chamada a Funcao de Leitura e Apontamento das Marcacoes     			³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			Ponm010(	lWorkFlow					,;	//Define Que a Chamada Esta Sendo Efetuada Atraves do WorkFlow
					 	lUserDefParam				,;	//Verifica Se Devera Considerar os Parametros Pre-Definidos Pelo Usuario
					 	lLimitaDataFim				,;	//Verifica Se Devera Limitar a Data Fim a Menor Data entre a DataBase e o Periodo Final de Apontamento
						cFil						,;	//Filial a ser processada
					 	lProcFilial					,;	//Processo por Filial
					 	lApontaNaoLidas				,;	//Se Aponta as Marcacoes para as Filiais nao Lidas
					 	lForceReaponta				 ;	//Forcar o Reapontamento das Marcacoes
					)

			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Enviando Mensagens para o Console do Server                 			³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			ConOut("")
			// "Final da Leitura/Apontamento em: "###" as "
			ConOut( STR0007 + Dtoc( MsDate() ) + STR0004 + Time() )
			ConOut("")

		EndIF		
		
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Enviando Mensagens para o Console do Server                 			³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	ConOut("")
	ConOut( STR0008 )	//"Encerrando Ambiente da Empresa. Aguarde... "
	ConOut("")
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Finaliza o Ambiente da Empresa										³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
//	RESET ENVIRONMENT

Else

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Enviando Mensagens para o Console do Server                 			³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	ConOut("")
	ConOut( STR0009 )	//"Nao foi possivel concluir o processo. Empresa ou Filial Invalidas."
	ConOut("")

EndIF

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Enviando Mensagens para o Console do Server                 			³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
ConOut("")
ConOut("Finalizando U_PonScheduler()...")
ConOut("")
	
Return( NIL )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³StartJobPon  ³ Autor ³ NGSI               ³ Data ³21/11/2001³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Start do Processo de WorkFlow                               ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³u_StartJobPon												³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³															³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³PonWork                                                    	³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Observacao³Essa Funcao devera ser Incluida no .INI do Server          	³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
User Function ADStartJobPon()

Local aEmpFil := Array( 02 )

aEmpFil[ 01 ] := "01"	//Codigo da Empresa confome SIGAMAT
aEmpFil[ 02 ] := "02"	//Codigo da Filial  confome SIGAMAT

Return( wfStart( aEmpFil ) )                            
                           

USER FUNCTION TSTPON
           //job / empresa / filial
U_ADPNM001({.T. , "01"    ,  "02" })

RETURN()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ fEnvMail ºAutor  ³ Adilson Silva      º Data ³ 19/04/2012  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para Envio de Emails.                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP10                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function fEnvMail( cSubject, cMensagem, cEMail, aFiles, lText )

Local lEnvioOK    := .F.			// Variavel que verifica se foi conectado OK
Local cMailConta  := GETMV( "MV_RELACNT" ) //alterado por Adriana para corrigir problema na autenticacao do email 11/06/19 
Local cMailServer := GETMV( "MV_RELSERV" ) //alterado por Adriana para corrigir problema na autenticacao do email 11/06/19 
Local cMailSenha  := GETMV( "MV_RELPSW" ) //alterado por Adriana para corrigir problema na autenticacao do email 11/06/19 
Local cMailFrom   := GETMV( "MV_RELFROM" ) //alterado por Adriana para corrigir problema na autenticacao do email 11/06/19 
Local lMailAuth   := GETMV( "MV_RELAUTH",,.F. )
Local lAutentic	  := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia email                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cMailServer) .And. !Empty(cMailConta) 

   CONNECT SMTP SERVER cMailServer ACCOUNT cMailConta PASSWORD cMailSenha RESULT lOk
   
   //-- Faz autenticacao no servidor //alterado por Adriana para corrigir problema na autenticacao do email 11/06/19 

	if lAutentic = .F.
		IF lMailAuth
			lAutentic := MailAuth(cMailConta, cMailSenha)
		ELSE
			lAutentic := .T.
		ENDIF
	ENDIF


   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Envia o email                                                ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If lOk .And. lAutentic
   	  Conout("Rotina ADPNM001 - Empresa "+_cEmp+" SMTP OK.")     //incluido por Adriana para acompanhar envio em 11/06/19 
      If ( MailSend( cMailFROM, {cEmail}, {}, {}, cSubject, cMensagem, aFiles, lText ))
         lEnvioOK := .T.
      EndIf
   Else
   	  Conout("Rotina ADPNM001 - Empresa "+_cEmp+" SMTP nao Autenticou."+iif(lOk,"lOk=.t.","lOk=.F.")+iif(lAutentic,"lAutentic=.T.","lAutentic=.F."))     //incluido por Adriana para acompanhar envio em 11/06/19 
   EndIf
   MailSmtpOff()
EndIf

Return( lEnvioOK )  

Static Function logZBN(cStatus)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variávies.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea	:= GetArea()
	
	DbSelectArea("ZBN") 
	ZBN->(DbSetOrder(1))
	ZBN->(DbGoTop()) 
	If ZBN->(DbSeek(xFilial("ZBN") + 'ADPNM001'))
	
		RecLock("ZBN",.F.)
		
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_ROTINA	:= 'ADPNM001'
			ZBN_DESCRI  := 'Leitura e Apontamento de Marcações de Ponto-Adoro'
			ZBN_DATA    := dDataBase
			ZBN_HORA    := TIME()
			ZBN_PERIOD  := '1'
			ZBN_PERDES  := 'DIA'
			ZBN_QTDVEZ  := 1
			ZBN_HORAIN  := '08:00:00'
			ZBN_DATAPR  := dDataBase + 1
			ZBN_HORAPR  := '08:00:00'
			ZBN_STATUS	:= cStatus
			
		MsUnlock() 
		
	Else
	
		RecLock("ZBN",.T.)
		
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_ROTINA	:= 'ADPNM001'
			ZBN_DESCRI  := 'Leitura e Apontamento de Marcações de Ponto-Adoro'
			ZBN_DATA    := dDataBase
			ZBN_HORA    := TIME()
			ZBN_PERIOD  := '1'
			ZBN_PERDES  := 'DIA'
			ZBN_QTDVEZ  := 1
			ZBN_HORAIN  := '08:00:00'
			ZBN_DATAPR  := dDataBase + 1
			ZBN_HORAPR  := '08:00:00'
			ZBN_STATUS	:= cStatus
	
		MsUnlock() 	
	
	EndIf
	
	ZBN->(dbCloseArea())
		
	RestArea(aArea)

Return Nil
