#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.ch'

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
//ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
//ฑฑบPrograma  ณMA265TDOK บAutor  ณWILLIAM COSTA       บ Data ณ  08/05/2018 บฑฑ
//ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
//ฑฑบDesc.     ณ Ponto de entrada para tratar a validacao dos campos de     บฑฑ
//ฑฑบ          ณ enderecar produtos MATA265                                 บฑฑ
//ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
//ฑฑบUso       ณ SIGAEST                                                    บฑฑ
//ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
//฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿


USER FUNCTION MA265TDOK()
	
	Local lRet        := .T.
	Local nCont       := 0
	Local nPosLocaliz := 0
	Local nPosData    := 0
	Local nEstorno    := 0
	
	nPosLocaliz := Ascan( aHeader, { |x| Alltrim( x[2] ) == "DB_LOCALIZ" } )
	nPosData    := Ascan( aHeader, { |x| Alltrim( x[2] ) == "DB_DATA" 	 } )
	nEstorno    := Ascan( aHeader, { |x| Alltrim( x[2] ) == "DB_ESTORNO" } )
	
	FOR nCont:=1 TO LEN(aCols)
	
		IF aCols[nCont][nEstorno] <> 'S' //Regra para validar somente a linha que nใo tem estorno
		
			//Regra para a filial 02 local 02
			IF FWFILIAL("SDA")       == '02' .AND. ;
			   !(ALLTRIM(M->DA_LOCAL) $ GETMV("MV_#ARMEXC",,'03')) // Locais para nใo entrar nessa valida็ใo
			
				IF aCols[nCont][nPosLocaliz] <> Posicione("SBE",10,xFilial("SBE")+M->DA_PRODUTO+M->DA_LOCAL,"BE_LOCALIZ")
				   
				    MsgStop("OLม " + Alltrim(cUserName) + ", o endere็o nใo estแ correto, favor verificar", "MA265TDOK-01 - VALIDA ENDEREวAMENTO")
					lRet        := .F.
					
				ENDIF
			ENDIF
			
			IF aCols[nCont][nPosData] <> M->DA_DATA   
			
				MsgStop("OLม " + Alltrim(cUserName) + ", S๓ ้ permitido endere็ar produto com a mesma data da entrada", "MA265TDOK-02 - VALIDA ENDEREวAMENTO")
				lRet        := .F.
				
			ENDIF
		ENDIF
	NEXT

RETURN(lRet)