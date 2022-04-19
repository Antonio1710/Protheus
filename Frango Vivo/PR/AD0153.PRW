#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AD0153    º Autor ³ Daniel             º Data ³  18/10/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Gera Frete Frango Vivo	                                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function AD0153

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Gera Frete Frango Vivo')

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                               
//Incluido 26/09/11 - Ana. Atendendo chamado 010470. Pois de um dia para outro o sistema nao atualiza a data base, gravando sempre a data do dia de logon no sistema.
DDATABASE := Date() 

Private cString 	:= "ZV1"
Private _dHORA		:=TIME()	//HORA ATUAL			--> ZK_HORA
Private _dDATE		:=DDATABASE	//DATA ATUAL         	--> ZK_DTEFECH
Private _nZV1GUIAPE	:= SPACE(6)	//GUIA DE PESAGEM		--> ZK_ROTEIRO
Private _nZV1NumOc	:= 0		//NUMERO DA OC 			--> ZK_ROTEIRO
Private _dZV1DTABAT	:= ''		//DATA DE ABATE 		--> ZK_DTENTR
Private _nZV1PPLACA	:= 0		//PLACA 				--> ZK_PLACA
Private _nZV1RHVP 	:= ''       //HORA DE CHEGADA EM VP --> ZK_HORAENT
Private _nPESLIQ	:= 0		//PESO LIQUIDO 			--> ZK_PESOL
Private _nZV1PESONF	:= 0		//PESO DA NF, BRUTO		--> ZK_PESONF
Private _nTRSNSP	:= Space(6)	//COD DO FORNECEDOR		-->	ZK_FORNEC
Private _nLOJTRS	:= Space(2)	//LOJA FORNEC			--> ZK_LOJFOR
Private _nZV22PESO	:= 0		//SEGUNDO PESO
Private _nZV21PESO	:= 0		//PRIMEIRO PESO			--> ZK_PESOBAL
Private _nZV2KMENT	:= 0		//KM DE ENT.			--> ZK_KMENT
Private _nZV2KMSAI	:= 0		//KM DE SAI.			--> ZK_KMSAI
Private _nKMPAGO    := 0        //KM PAGO
Private _cSA2NOME	:= Space(2) // NOME DO FORNECEDOR 	--> ZK_NOMEFOR
Private _nZV1NumOc	:= ZV1_NUMOC		//NUMERO DA OC
Private _cCidade    :=  ZV1_PCIDAD
Private _cStatus    :=  ZV1_STATUS   // STATUS DO FRANGO VIVO
Private _cDescFrt   :=  Space(2)    // Descricao do Tipo de Frete
Private _cTipVei    := Space(2)     // Tipo do Veiculo
Private	_cTabela  	:= Space(TamSX3("ZV4_TABELA")[1])	//--> ZV4_TABELA 	// INCLUIDO EM 18/02/2010 POR DANIEL G.JR. TI1239
Private _nKmPago    := 0            // Km pago
Private _cFret      := Space(2)     // Tipo de Frete
Private _nPrcQueb   := 0                // Parametro de Quebra
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Guarda ambiente inicial                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_cAlias := Alias()
_nIndex := IndexOrd()
_nRecno := Recno()

//Procuro pelo codigo do fornecedor padrao dos integrados
//da adoro nos paramentros e comparo com o codigo atual
//se for igual uso a porcentagem de quebra para integrados
//da adoro, caso nao calculo a porcentagem de quebra
_nContFor:= Getmv("MV_FORITAD")
_nContFor:=alltrim(_nContFor)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifico se já tem frete gerado
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  _cStatus = 'G'
	// Variavel para controlar quem chamou na origem AD0130 or AD0178
	//If _ProcPrd = 'N'
		Alert ("ABORTANDO O PROCESSO, JA FOI GERADO FRETE O.C. " +_nZV1NumOc)
	//Endif
	dbSelectArea(_cAlias)
	dbSetOrder(_nIndex)
	dbGoto(_nRecno)
	Return
	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Obtendo dados de ZV1³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DbselectArea("ZV1")
dbsetorder (1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Passo como um parametro a guia de pesagem para o AD0046³
//³Chamo AD0046 para calculo do frete                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Private _cCidade    := ZV1_PCIDAD
Private _cStatus    := ZV1_STATUS
Private _nZV1GUIAPE	:= ZV1_GUIAPE		//GUIA DE PESAGEM		--> ZK_GUIA
Private _nZV1NumOc	:= ZV1_NUMOC		//NUMERO DA OC 			--> ZK_ROTEIRO
Private _dZV1DTABAT	:= ZV1_DTABAT		//DATA DE ABATE 		--> ZK_DTENTR
Private _nZV1PPLACA	:= ZV1_RPLACA		//PLACA 				--> ZK_PLACA
Private _nZV1RHVP 	:= ZV1_RHVP         //HORA DE CHEGADA EM VP --> ZK_HORAENT
Private _nZV1PESONF	:= ZV1_PESONF		//PESO DA NF, BRUTO		--> ZK_PESONF
Private _nRGRANJ	:= ZV1_CODFOR 		//COD DO FORNECEDOR		-->	ZK_FORNEC
Private _nLOJGRANJ	:= ZV1_LOJFOR 		//COD DO FORNECEDOR		-->	ZK_FORNEC
Private _nFORREC    := ZV1_FORREC       //COD FORNECEDOR RECEBIDO
Private _nTarPrd    := ZV1_TARAPD       // Tara Padrao
Private _nParQrb    := ZV1_CLIVOL       // Seco / Molhado
Private _nQtdQrb    := ZV1_QTDQBR      // QUANTIDADE DA QUEBRA
//Regra para posicionar no Fornecedor
//AND ZV1_CODFOR  = A2_COD AND ZV1_LOJFOR  = A2_LOJA

Private _nTRSNSP    := Space(6)	//TRANSPORTADORA
Private _nLOJTRS	:= Space(2)	//LOJA FORNEC

Private _nZV1STATUS	:= ZV1_STATUS		//STATUS DO FRETE
Private _nPesAjust  := ZV1_AJUSPS       //AJUSTE DE PESO
Public _cPlac		:= ZV1_RPLACA                 //Placa
Public _dDatEntr	:= ZV1_DTABAT                 //Data de Abate
Public _nGuia		:= ZV1_GUIAPE                 //Guia
Public _cKmOdm 		:= ZV1_KMODM                  //Considera Km Odometro

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Obtendo dados de ZV2³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dBselectarea ("ZV2")
dBsetorder (1)
If DbSeek (xFilial("ZV2")+_nZV1GUIAPE,.T.)
	// Por seguranca pode ter registro vazio em ZV2
	If (_nZV1GUIAPE<>"")
		//Tara Padrao para calculo do Frete
		If _nTarPrd = 0
			_nZV22PESO	:= ZV2_2PESO		//SEGUNDO PESO
		Else
			_nZV22PESO	:= _nTarPrd		    //TARA PADRAO
		Endif
		//Forco lancar peso ajustado
		_nZV21PESO	:= ZV2_1PESO - _nQtdQrb   	//PRIMEIRO PESO - QUEBRA 
		_nZV2KMENT	:= ZV2_KMENT		//KM DE ENT.		--> ZK_KMENT
		_nZV2KMSAI	:= ZV2_KMSAI		//KM DE SAI.		--> ZK_KMSAI
		_nKmPago	:= ZV2_KMENT - ZV2_KMSAI
	EndIf
Else
	//SE NAO ENCONTRANDO ZERA VALORES
	Alert ("NAO PODE GERAR FRETE SEM GUIA DE PESAGEM, O.C. " +_nZV1NumOc)
	_nZV22PESO	:=0
	_nZV21PESO	:=0
	_nZV2KMENT	:=0
	_nZV2KMSAI	:=0
EndIf


// Calculo Peso Liquido conforme ajuste
// Multiplico o peso liquido pelo fator de quebra
_nPESLIQ := (_nZV21PESO - _nZV22PESO)  + _nPesAjust


// Pego o Tipo fo Caminhao
dBselectarea ("ZV4")
dBsetorder (1)
If DbSeek (xFilial("ZV4")+_cPlac,.T.)
	_cTipVei = ZV4_TIPVEI
	_cTabela = ZV4_TABELA
	// Pego o Codigo da Transportadora
	_nTRSNSP    := ZV4_FORNEC    // TRANSPORTADORA
	_nLOJTRS	:= ZV4_LOJFOR    // LOJA FORNEC
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifico se existe a 2o pesagem. ³
//|Verifico existe Guia de Pesagem  |
//___________________________________
If (_nZV1GUIAPE="      ")
	//Alert ("ABORTANDO O PROCESSO, NAO FOI GERADO GUIA O.C. " +_nZV1NumOc)
	dbSelectArea(_cAlias)
	dbSetOrder(_nIndex)
	dbGoto(_nRecno)
	// Para o processo
	Return
EndIf
If ( _nZV22PESO=0)
	
	Alert ("ABORTANDO O PROCESSO, 2o PESAGEM NAO REALIZADA O.C. " +_nZV1NumOc)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura ambiente inicial                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea(_cAlias)
	dbSetOrder(_nIndex)
	dbGoto(_nRecno)
	Return
	
EndIf

//Verificando a variavel
//Private _nRGRANJ	:= ZV1_CODFOR 		//COD DO FORNECEDOR		-->	ZK_FORNEC
//Private _nLOJGRANJ	:= ZV1_LOJFOR 		//COD DO FORNECEDOR		-->	ZK_FORNEC


//PROCURANDO PELO INTEGRADO PARA PEGAR KM
dbSelectArea("SA2")
dbSetOrder(1)
If dBseek(xfilial("SA2") + _nRGRANJ +  _nLOJGRANJ )
	// Se tiver marcado 'S' pego a Km do Odometro caso contrario
	// considero da tabela
	// Quando for fornece Adoro Km do Cadastro
	If _nContFor = _nFORREC
		// Com Excessao quando é marcado do Odometro
		If _cKmOdm	= 'S'
			// Assume do Odometro
			//_nKmPago := A2_KMCOMP
		Else
			_nKmPago :=  A2_KMABT // DEVE MUDAR PARA A2_KMCOMP
		Endif
	Endif
	
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ|
//³Procurando o nome do fornecedor na tabela SA2³
//³Caso nao encontrado grava nome como branco   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ|

dbselectarea("SA2")
dbsetorder(1)
IF DbSeek(xFilial("SA2")+_nTRSNSP+_nLOJTRS	)
	_cSA2NOME	:= A2_NOME		//NOME DO FORNECEDOR 		--> ZK_NOMEFOR
Else
	Alert (" NAO ENCONTRADO NO CADASTRO DE TRANSPORTADORA, O.C. " +_nZV1NumOc)
	_cSA2NOME:=""
EndIF

//PROCURANDO EM SZH O TIPO DE FRETE QUE ESTOU GERANDO
_cTPFRETE := SPACE(2)
//Pego o Tipo de Frete
DBSELECTAREA("SZH")
dbsetorder(1)
IF DbSeek(xFilial("SZH")+ _cTabela ,.T.)
	_cDescFrt := ZH_DESCRIC
	_cFret    := ZH_TIPFRT
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ|
	//³Eviando dados do ZV1 para SZK                                 ³
	//³Procuro pelo registro corrente em SZK e vejo se ele não existe³
	//³Verifico se em ZV1 se nao foi gerado frete                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ|
	
	dbselectarea("SZK")
	DbsetOrder(2)
 
	If DbSeek(xFilial("SZK") + _nZV1GUIAPE + DTOS(_dZV1DTABAT) + _nZV1PPLACA,.T.)
		Alert ("Registro ja se encontra em SZK010")
		//grava log	
		u_GrLogZBE (Date(),TIME(),cUserName," RecLock(SZK,.F.)","LOGISTICA","AD0153",;
     	            "Filial: "+xFilial("SZK")+" Guia: "+_nZV1GUIAPE+" Data: "+DTOS(_dZV1DTABAT)+" Placa: "+_nZV1PPLACA,ComputerName(),LogUserName())
	Else
	
		//grava log	
		u_GrLogZBE (Date(),TIME(),cUserName," RecLock(SZK,.T.)","LOGISTICA","AD0153",;
     	            "Filial: "+xFilial("SZK")+" Guia: "+_nZV1GUIAPE+" Data: "+DTOS(_dZV1DTABAT)+" Placa: "+_nZV1PPLACA,ComputerName(),LogUserName())
         	            
		Reclock("SZK",.T.)
		Replace ZK_FILIAL  With FWxFilial("SZK")
		Replace ZK_HORA    with _dHORA				//HORA ATUAL
		Replace ZK_DTFECH  with _dDATE				//DATA ATUAL                        
		
		
		Replace ZK_GUIA	   with _nZV1GUIAPE 		//GUIA DE PESAGEM
		Replace ZK_NUMOC   with _nZV1NumOc			//NUMERO DA OC
		Replace ZK_DTENTR  with _dZV1DTABAT			//DATA DE ABATE
		Replace ZK_PLACA   with _nZV1PPLACA			//PLACA
		Replace ZK_PLACAPG with _nZV1PPLACA			//PLACA
		Replace ZK_HORAENT with _nZV1RHVP   		//HORA DE CHEGADA EM VP
		Replace ZK_PESOL   with _nPESLIQ			//PESO LIQUIDO
		Replace ZK_PBRUTO  with _nZV1PESONF			//PESO DA NF, BRUTO
		Replace	ZK_FORNEC  with _nTRSNSP   			//COD DO FORNECEDOR
		Replace ZK_LOJA	   with _nLOJTRS     		//LOJA FORNEC
		Replace ZK_PESOBAL with _nPESLIQ			//PRIMEIRO PESO
		Replace ZK_PBRUTO  with _nPESLIQ			//PESO LIQUIDO
		Replace ZK_KMENT   with _nZV2KMENT			//KM DE ENT.
		Replace ZK_KMSAI   with _nZV2KMSAI			//KM DE SAI.
		Replace ZK_KMPAG   with _nKmPago  			//KM DE PAGO
		Replace ZK_NOMFOR  with _cSA2NOME			//NOME DO FORNECEDOR
		Replace ZK_TPFRETE with _cTABELA			//TIPO DO FRETE
		Replace ZK_DESTINO with	_cCidade            //CIDADE DESTINO
		Replace ZK_ENTREGA with 1                    //ASSUME UM PARA NUMERO DE VIAGENS
		Replace ZK_DESCRI  with	_cDescFrt         // Descricao do Frete
		Replace ZK_TABELA  with	_cTipVei           // Tipo de Veiculo
		Replace ZK_TIPFRT  with	_cFret             // Tipo do Frete / Abatido/Fivo
		dbcommit()
		MsUnlock()
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Passo como um parametro a guia de pesagem para o AD0162³
	//³Chamo AD0162 para calculo do frete                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	//Public _ctpfrt	:=_cTPFRETE    //Frete tipo
	Public _cPlac		:=_nZV1PPLACA              //Placa
	Public _dDatEntr	:=_dZV1DTABAT              //Data de Abate
	Public _nGuia		:=_nZV1GUIAPE              //Guia
	
	Execblock("AD0162") 
	Reclock ("ZV1",.F.)
	// Marco que gerou o Frete e Nao permito gerar novamente
	Replace ZV1_STATUS with 'G'
	MsUnlock ()
	
ELSE
	Alert (" NAO ENCONTRADO TIPO DE FRETE NA PLACA "+_cPlac + " O.C. " +_nZV1NumOc)
ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ|
//³Marco o flag em ZV1 que ja foi gerado o Frete³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ|
dbSelectArea(_cAlias)
dbSetOrder(_nIndex)
dbGoto(_nRecno)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ|
//³Troco o flag em ZV1 que ja foi calculado o Frete³
//³so calculo frete se ZV1->SZK                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ|


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura ambiente inicial                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(_cAlias)
dbSetOrder(_nIndex)
dbGoto(_nRecno)
Return




