#Include "Protheus.CH"

/*/{Protheus.doc} User Function GP670CPO 
	Ponto de Entrada do GPEM670 (Integracao Financeiro)
	@type  Function
	@author Rogerio Eduardo Nutti
	@since 31/03/2005
	@version 01
	@history Ticket 049395 -  FWNM		    - 12/06/2019 - TIT. ACORDO JUDICIAL
	@history Ticket 4220   -  William Costa	- 16/11/2020 - Gravar o campo E2_LOGDTHR 

/*/

User Function GP670CPO()

	Local _aArea	  := GetArea()
	Local _aAreaSI3	  := SI3->( GetArea() )
	Local _aAreaSRA	  := SRA->( GetArea() ) 
	Local _aAreaSRQ	  := SRQ->( GetArea() )
	Local _aAreaSE2	  := SE2->( GetArea() )
	Local _aAreaRC0	  := RC0->( GetArea() )
	Local _aAreaRC1	  := RC1->( GetArea() )
	Local _dtVenc	  := ""
	Local _dtVencR	  := ""
	Local _cE2_OBS_AP := ""
	Local _cE2_HIST	  := ""
	Local _cItemCTB	  := IIF(RC1->RC1_FILTIT$"01/02","121",IIF(RC1->RC1_FILTIT == "03","114",IIF(RC1->RC1_FILTIT == "04","112","")))
	
	//Validacoes
	RC0->(DBSEEK(FwXFilial("RC0") + RC1->RC1_CODTIT))

	IF !Empty(RC1->RC1_MAT)
	
		IF RC0->RC0_TPTIT == "1"
	
			_cE2_OBS_AP := "CHQ. NOMINAL A: " + RC1->RC1_NOMCTA
			_cE2_HIST	:= "MATR.: " + RC1->RC1_MAT
		
	    ELSE
	    
			_dtVenc	 := IIF(RC1->RC1_CODTIT != "025",RC1->RC1_VENCTO,DataValida(RC1->RC1_VENCTO,.F.))
			_dtVencR := IIF(RC1->RC1_CODTIT != "025",RC1->RC1_VENREA,DataValida(RC1->RC1_VENREA,.F.))
	
			DBSELECTAREA("SRA")
			DBSETORDER(01)
	
			IF DBSEEK(FWxFilial("SRA") + RC1->RC1_MAT)
				
				_cE2_OBS_AP := "CHQ. NOMINAL A: " + SRA->RA_NOME
				_cE2_HIST	:= "MATR.: " + RC1->RC1_MAT
	
	
			ENDIF
	
		ENDIF
		
	ELSE

		_cE2_OBS_AP := RC1->RC1_DESCRI

	ENDIF
	
	//Atualiza Titulo                                              
	
	DBSELECTAREA("SE2")
	DBSETORDER(01)
	
	RECLOCK("SE2",.F.)

		SE2->E2_OBS_AP	:= IIF(!EMPTY(_cE2_OBS_AP),_cE2_OBS_AP, SE2->E2_OBS_AP)
		SE2->E2_HIST	:= IIF(!EMPTY(_cE2_HIST)  ,_cE2_HIST  , SE2->E2_HIST)
		SE2->E2_VENCTO	:= IIF(!EMPTY(_dtVenc)    ,_dtVenc	  , SE2->E2_VENCTO)
		SE2->E2_VENCREA	:= IIF(!EMPTY(_dtVencR)   ,_dtVencR	  , SE2->E2_VENCREA)
		SE2->E2_ITEMD	:= IIF(!EMPTY(_cItemCTB)  ,_cItemCTB  , SE2->E2_ITEMD)
		SE2->E2_ITEMC	:= IIF(!EMPTY(_cItemCTB)  ,_cItemCTB  , SE2->E2_ITEMC)
		SE2->E2_NATUREZ	:= RC1->RC1_NATURE
		SE2->E2_DEBITO	:= POSICIONE("SA2",1,FWXFILIAL("SA2")+RC1->RC1_FORNEC+RC1->RC1_LOJA,"A2_CONTA") // EVERALDO CASAROLI 26/12/07
		SE2->E2_LOGDTHR	:= IIF(EMPTY(SE2->E2_LOGDTHR),DTOC(DATE()) + ' ' + TIME(),SE2->E2_LOGDTHR)
		
		//Faz a atualizacao dos dados bancarios - Everaldo Casaroli 26/12/07
		IF ALLTRIM(RC1->RC1_CODTIT) == "901"			//  Pagamento de Autonomo
		
			SE2->E2_BANCO	:= Substr(SRA->RA_BCDEPSA,1,3)		
			SE2->E2_AGEN	:= Substr(SRA->RA_BCDEPSA,4,4) 
			SE2->E2_DIGAG	:= Substr(SRA->RA_BCDEPSA,8,1)
			SE2->E2_NOCTA	:= ALLTRIM(SRA->RA_CTDEPSA)
			SE2->E2_DIGCTA	:= ALLTRIM(SRA->RA_DIGCTA)
			SE2->E2_NOMCTA	:= ALLTRIM(SRA->RA_NOME)
			SE2->E2_CNPJ	:= SRA->RA_CIC
			
		ELSEIF ALLTRIM(RC1->RC1_CODTIT) == "025"		// Pagamento de Recisao
		
			SE2->E2_BANCO	:= Substr(SRA->RA_BCDEPSA,1,3)		
			SE2->E2_AGEN	:= Substr(SRA->RA_BCDEPSA,4,4) 
			SE2->E2_DIGAG	:= Substr(SRA->RA_BCDEPSA,8,1) 
			SE2->E2_NOCTA	:= Substr(SRA->RA_CTDEPSA,1,Len(alltrim(SRA->RA_CTDEPSA))-1) //IIF(Substr(SRA->RA_BCDEPSA,1,3)=="237",Substr(SRA->RA_CTDEPSA,1,7),Substr(SRA->RA_CTDEPSA,1,Len(alltrim(SRA->RA_CTDEPSA))-1))
			SE2->E2_DIGCTA	:= Right(Alltrim(SRA->RA_CTDEPSA),1,1) //IIF(Substr(SRA->RA_BCDEPSA,1,3)=="237",Substr(SRA->RA_CTDEPSA,9,1),Right(Alltrim(SRA->RA_CTDEPSA),1,1))
			SE2->E2_NOMCTA	:= ALLTRIM(SRA->RA_NOME)
			SE2->E2_CNPJ	:= SRA->RA_CIC
		
		ELSEIF RC0->RC0_TPTIT == "1"
		
			SE2->E2_BANCO	:= RC1->RC1_BANCO
			SE2->E2_AGEN	:= RC1->RC1_AGEN
			SE2->E2_DIGAG	:= RC1->RC1_DIGAG
			SE2->E2_NOCTA	:= RC1->RC1_NOCTA
			SE2->E2_DIGCTA	:= RC1->RC1_DIGCTA
			SE2->E2_NOMCTA	:= RC1->RC1_NOMCTA
			SE2->E2_CNPJ	:= RC1->RC1_CNPJ
		
		// Chamado n. 049395 || OS 050723 || FINANCAS || ANA || 8384 || ±TIT. ACORDO JUDICIAL - FWNM - 12/06/2019
		ELSE

			SE2->E2_BANCO	:= RC1->RC1_BANCO
			SE2->E2_AGEN	:= RC1->RC1_AGEN
			SE2->E2_DIGAG	:= RC1->RC1_DIGAG
			SE2->E2_NOCTA	:= RC1->RC1_NOCTA
			SE2->E2_DIGCTA	:= RC1->RC1_DIGCTA
			SE2->E2_NOMCTA	:= RC1->RC1_NOMCTA
			SE2->E2_CNPJ	:= RC1->RC1_CNPJ
		
		ENDIF
		//Fim da alteracao - Everaldo Casaroli 26/12/2007
		
	SE2->(MsUnLock())
	
	//Restaura Ambiente Inicial
	RestArea(_aAreaSI3)
	RestArea(_aAreaSRA)
	RestArea(_aAreaSRQ)
	RestArea(_aAreaSE2)
	RestArea(_aAreaRC0)
	RestArea(_aAreaRC1)
	RestArea(_aArea)

RETURN(NIL)
