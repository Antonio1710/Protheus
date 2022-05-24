#include "Topconn.ch"

/*/{Protheus.doc} User Function ADVEN082
	Filtro para Consulta Padrão da tabela SA1 para uso no Pedido de Vendas - SC5
	// Projeto: Projeto Financas
	// Modulo : SIGAFIN
	// Fonte  : ADVEN082 
	@type  Function
	@author Ricardo Lima
	@since 28/03/18
	@history Ticket 69574   - Abel Bab - 21/03/2022 - Projeto FAI
	/*/
User Function ADVEN082   // #U_ADVEN082()

Local _aCodSup 	:= {}
Local _cSupV 	:= ""
Local cM410fil  := ""
Local cEmpSF:= GetMv("MV_#SFEMP",,"01|") //Ticket 69574   - Abel Bab - 21/03/2022 - Projeto FAI
Local _ni := 0

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Filtro para Consulta Padrão da tabela SA1 para uso no Pedido de Vendas - SC5')

Private _cUserName := '""

_cUserName := Alltrim(cUsername)

If Alltrim(cEmpAnt) $ cEmpSF
	
	If ! Alltrim(_cUserName) $ GetMV("MV_GERENTE")
		_cCodUs := __cUserID
				
		dbSelectArea("SA3")
		dbSetOrder(7)
		If dbSeek( xFilial("SA3")+_cCodUs )
			If SA3->A3_NIVETAB == "2"
				_aCodSup := {}
				While SA3->(!Eof()) .And. SA3->A3_CODUSR == _cCodUs
					AADD(_aCodSup,{SA3->A3_SUPER})
					SA3->(dbSkip())
				Enddo
				
				_cSupV  := ""
				
				For _ni := 1 to len(_aCodSup)
					dbSelectArea("SA3")
					dbSetOrder(5)
					If dbSeek( xFilial("SA3")+_aCodSup[_ni][1] )
						Do While !Eof() .and. xFilial("SA3") == SA3->A3_FILIAL	.and. ;
							_aCodSup[_ni][1]       == SA3->A3_SUPER
							IF ! SA3->A3_COD $ _cSupV 
							 _cSupV  += SA3->A3_COD + "|"
							ENDIF
							SA3->(dbSkip())
						Enddo
					Endif
				Next _ni

				If !Empty(_cSupV)
					
					cM410fil := "@A1_VEND IN ( "+ _cSupV +" ) "
				Endif
			Elseif SA3->A3_NIVETAB == "1"
				_cCodVen := SA3->A3_COD
				
				cM410fil :=	"@A1_VEND = '"+ _cCodVen +"'"
			Endif
		Endif
	Endif	
Endif

Return(cM410fil)
