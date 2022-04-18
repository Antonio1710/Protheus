#include "Protheus.ch"
#include "rwmake.ch"


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ NVIMPJOX ³ Autor ³ ALEX BORGES          ³ Data ³ 21/11/11   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Importacao de Preço Custo JOX na tabela ZZS                ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Comercial                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³ Arquivos ³                                                            ³±±
±±³ em Uso   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³ Manutencao :                                                          ³±±
±±³                                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
@history Everson, 14/04/2022. Chamado 71231 - Tratamento para envio de meta apenas pela empresa 01 e filial 02.
/*/

User Function ADVEN011P()
	&&Mauricio - 22/07/15 - trara o preco meta tambem para o arquivo ZZS

	/*LAYOUT DO ARQUIVO CSV A SER IMPORTADO:

	Delimitado por ";", com 1 linha de cabecalho


	1= Supervisor 	
	2= Grupo  
	3= Data 	
	4= Valor  	(Tipo Numerico, com 2 decimais, mascara 999999,99)
	5= Peso 	(Tipo Numerico)
	*/

	_nTamLin 	:= 100            		// Tamanho da linha no arquivo texto
	_nHdl    	:= Nil           		// Handle para abertura do arquivo
	_cBuffer 	:= Space(_nTamLin+1) 	// Variavel para leitura
	_nBytes  	:= 0                	// Variavel para verificacao do fim de arquivo
	_cFileLog 	:= ""                   // Arquivo para gravacao do log de execucao da rotina
	_cPath 		:= ""  					//caminho onde sera gravado o arquivo de LOG
	_nQtChar 	:= 2
	_cDelimit	:= ";"                 //Delimitador do arquivo CSV

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Importacao de Preço Custo JOX na tabela ZZS')

	_cPerg		:= PADR("IMPJOX",10," ")
	ValidPerg()

	if Pergunte(_cPerg,.T.)
		_cArq    	:= MV_PAR01      		// Arquivo texto a importar

		If MsgBox(OemToAnsi("Confirma importação de Valores do arquivo "+Alltrim(_cArq)+" para a tabela de custo JOX? "),"ATENCAO","YESNO")
			_nHdl := fOpen(_cArq,2) // Abre o arquivo
			fClose(_nHdl)
			If _nHdl == -1
				Aviso( "AVISO",OemToAnsi("Não foi possível abrir o arquivo "+_cArq),{"Sair"} )
			else
				Processa({|| ImpCSVJO()})
			endif
		endif
	Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ImpCSVJO ºAutor  ³Alex Borges -        º Data ³  21/11/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Executa rotina de importacao com regua de processamento     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ImpCSVJO()

	Local cDtSF := ""
	
	Dbgotop()

	ft_fUse(_cArq) 	//Abre o arquivo

	ProcRegua(RecCount())
	ft_fGoTop()		//Posiciona no inicio do arquivo
	_nLin := 1     
	_Grupo := ""
	_NomGrupo := ""
	_Valor := 0
	_nPrcMet := 0
	Do While !ft_fEOF() 
		_arqOk := .T.
		_cBuffer := ft_fReadLn() 
		_nCmp := 1 

		FOR I := 1 TO 5
			_cTxtPos := Substr(_cBuffer,1,At(_cDelimit, _cBuffer)-1)
			if _nCmp = 1	
				_Grupo    := ALLTRIM(_cTxtPos)
				//Verifica se existe o supervisor
				dbSelectArea("SBM")
				dbSetOrder(1)
				//Posicinar no primeiro supervisor do parametro
				If dbseek(xFilial("SBM")+_Grupo,.f.) 
					If _Grupo = BM_GRUPO
						_NomGrupo := BM_DESC 
					Else
						ALERT("Grupo "+_Grupo+" INVALIDO NA LINHA :"+ALLTRIM(Str(_nLin)))
						Return
					End If		
				Else
					ALERT("Grupo "+_Grupo+" INVALIDO NA LINHA :"+ALLTRIM(Str(_nLin)))
					Return	 
				End If
			elseif _nCmp = 2   
				_Data := CToD(_cTxtPos )
			elseif _nCmp = 3   
				_Valor := Val(StrTran(_cBuffer,",","."))
			elseif _nCmp = 4   
				_nPrcMet := Val(StrTran(_cBuffer,",","."))	
			endif  
			_cBuffer := Substr(_cBuffer,At(";", _cBuffer)+1)
			_nCmp++
		End
		IncProc("Importando :  Grupo: " + _Grupo + " Data: "+DTOC(_Data)) 

		dbSelectArea("ZZS")
		DBSETORDER(1)
		// Verifica se ja tem o custo JOX
		// Caso tenho sobrepor
		If dbseek(xFilial("ZZS")+_Grupo+DTOS(_Data),.t.)
			RecLock("ZZS",.F.)
			// Sobrepor informacoes 
			Replace ZZS_VALOR    With _Valor
			Replace ZZS_PRMETA   With _nPrcMet
			MSUNLOCK()
		Else
			RecLock("ZZS",.T.)
			// Incluir informacoes
			Replace ZZS_FILIAL   With xFilial("ZZS")
			Replace ZZS_GRUPO    With _Grupo
			Replace ZZS_DESC     With _NomGrupo
			Replace ZZS_DATA     With _Data
			Replace ZZS_VALOR    With _Valor
			Replace ZZS_PRMETA   With _nPrcMet
			MSUNLOCK()
		Endif
		
		//
		If ! (("'" + DTOS(_Data) + "',") $cDtSF)
			cDtSF += "'" + DTOS(_Data) + "',"
		
		EndIf
		
		ft_fSkip()
		_nLin ++


	End
	
	//Everson - 04/03/2018. Chamado 037261. SalesForce.
	If cEmpAnt == "01" .And. cFilAnt = "02" .And. FindFunction("U_ADVEN073P") .And. !Empty(cDtSF) //Everson - 14/04/2022. Chamado 71231.
		
		cDtSF := Substr(cDtSF,1,Len(cDtSF) -1)
		U_ADVEN073P("","",.F., " AND ZZS_DATA IN (" + cDtSF + ") " )
		
	EndIf

	iF _arqOk
		msgInfo("Processamento concluido com sucesso!")
	endIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VALIDPERG ºAutor  ³ADRIANA - HC        º Data ³  27/10/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Para incluir perguntas no SX1                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ValidPerg

	PutSx1(_cPerg,"01","Importar do Arquivo CSV ?", "Importar do Arquivo ?", "Importar do Arquivo ?", "mv_ch1","C",50,0,0,"G",""         ,"","","","mv_par01","","","","","","","","","","","","","","","","","","","")


Return
