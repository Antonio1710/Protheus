#INCLUDE "Topconn.ch"
#INCLUDE "Protheus.ch"
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma    ณMT110VLDณPonto de Entrada que valida o registro na solicita็ใo de compras บฑฑ
ฑฑฬออออออออออออุออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAutor       ณ01/08/12 Ana Helena                                                       บฑฑ
ฑฑฬออออออออออออุออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบPonto de entrada executado ao clicar nos bot๕es incluir / alterar / excluir / copiar daบฑฑ
ฑฑบsolicitacao de compras. ExpN1: Cont้m o valor da opera็ใo selecionada:                 บฑฑ
ฑฑบ                                       3- Inclusใo, 4- Altera็ใo, 8- Copia, 6- Exclusใoบฑฑ
ฑฑฬออออออออออออุออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
User Function MT110VLD()

Local ExpN1    := Paramixb[1]
Local ExpL1    := .T. 

If ExpN1 <> 3 .And. ExpN1 <> 8
	
	If (cEmpAnt == "01" .And. cFilAnt = "03") .Or. cEmpAnt == "07"

		cNumSC := SC1->C1_NUM
		
		dbselectArea("SC1")
		dbgotop(1)
		dbseek(xFilial("SC1")+cNumSC)
		While !Eof() .And. SC1->C1_NUM == cNumSC

			If Alltrim(SC1->C1_USER) != Alltrim(__CUSERID)  // Valida็ใo do Usuario para interromper a grava็ใo                                               
				If Alltrim(SC1->C1_CC) == "8001"
					ExpL1 := .F.  
				EndIf   
			Endif	
			dbSkip()
		End	                             
    
		If !ExpL1
			Alert("S๓ ้ permitido altera็ใo desta solicita็ใo pelo usuแrio que a incluiu")
		Endif		 
		
	Endif

Endif

Return ExpL1