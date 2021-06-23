#INCLUDE "rwmake.ch"

/*/
Programa   SeqNuBra  Autor Jose Carlos Gouveia  Data   03/10/01   
Descricao  Sequencia Numerica do CNAB  ADORO                               
/*/

/*/{Protheus.doc} SeqNuBra
//Chamado TI - Configuracao CNAB FOL BRADESCO - Empresa RNX2 - FWNM - 25/03/2019 
/*/

User Function SeqNuBra  

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Sequencia Numerica do CNAB')
	
	// Declaracao de Variaveis                                             
	Private aSav_,aSavSA6_
	Private cSeq_ := ""
	Private nSeq_ := 0
	
	//Salva Ambiente
	aSav_  := {Alias(), Recno(), IndexOrd()}
	
	dbSelectArea("SA6")
	aSavSA6_  := {"", Recno(), IndexOrd()}
	dbSetOrder(1)
	
	// fwnm - 25/03/2019
	//SA6->(dbSeek(xFilial() + iif(Alltrim(cEmpAnt)="02","2373367","23733677"))) //se CERES a agencia foi cadastrada sem digito - alterado por Adriana em 14/09/2017
	SA6->(dbSeek(xFilial() + iif(Alltrim(cEmpAnt)="01","23733677","2373367"))) // Apenas na Adoro a agencia foi cadastrad com digito - Ceres e RNX2 estao sem!
	// 
	
	If Found()
		nSeq_ := VAL(SA6->A6_NUMSEQ_)
		nSeq_ := nSeq_ + 1
		
		If RecLock("SA6",.F.)
			SA6->A6_NUMSEQ_ := StrZero(nSeq_,6)
		Endif   
		
		cSeq_ := StrZero(nSeq_,16)
	Endif
	
	//Retorna Ambiente 
	dbSelectArea(aSav_[1])
	dbGoto(aSav_[2])
	dbSetOrder(aSav_[3])		

//Fim da Rotina
Return(cSeq_)