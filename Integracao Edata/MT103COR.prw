
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNOVO6     บAutor  ณMicrosiga           บ Data ณ  12/03/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function MT103COR

//_aFilNova := ParamIXB[1]

Local aCores := .t. 

If Alltrim(cEmpAnt) == "01"       //ALTERADO EM 31/03/2015 DEVIDO ERROR.LOG APRESENTADO - CHAMADO 022498
	aCores  := {	{'Empty(F1_STATUS) .AND. Empty(F1_XFLAGE)'	,'ENABLE'		},;	// NF Nao Classificada
	{'F1_STATUS=="B"'	,'BR_LARANJA'	},;	// NF Bloqueada
	{'F1_STATUS=="C"'	,'BR_VIOLETA'   },;	// NF Bloqueada s/classf.
	{'F1_TIPO=="N"'		,'DISABLE'   	},;	// NF Normal
	{'F1_TIPO=="P"'		,'BR_AZUL'   	},;	// NF de Compl. IPI
	{'F1_TIPO=="I"'		,'BR_MARROM' 	},;	// NF de Compl. ICMS
	{'F1_TIPO=="C"'		,'BR_PINK'   	},;	// NF de Compl. Preco/Frete
	{'F1_TIPO=="B"'		,'BR_CINZA'  	},;	// NF de Beneficiamento
	{'F1_TIPO=="D" .and. !Empty(F1_STATUS)'		,'BR_AMARELO'	},; 	// NF de Devolucao
	{'F1_XFLAGE == "1"', 'BR_MARRON'  	},;	// Devolucao Pendente (edata)
	{'F1_XFLAGE == "2"', 'BR_BRANCO'  	},;	// Devolucao Liberada (edata)
	{'F1_XFLAGE == "3"', 'BR_PRETO'  	}}	// Devolucao Bloqueada (edata)
endif

Return( aCores )