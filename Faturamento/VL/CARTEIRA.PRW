#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

//CONTROLE DE CARTEIRAS COMERCIAIS
//RAFAEL HENRIQUE DA SILVEIRA, 10/12/2007

USER FUNCTION CARTEIRA() 

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'CONTROLE DE CARTEIRAS COMERCIAIS')

_lRet		  	:= .T.
_cCliente:=M->C5_CLIENTE    
_cLoja :=IIF(!EMPTY(M->C5_LOJACLI),M->C5_LOJACLI,"")

// *** INICIO CHAMADO 040123 WILLIAM COSTA 07/03/2018

IF ISALPHA(_cCliente) //Verifica se foi digito um nome de cliente no campo M->C5_CLIENTE

	SqlBuscaCliente(M->C5_CLIENTE)
        
	While TRC->(!EOF())
              
            _cCliente:= TRC->A1_COD    
            _cLoja   := TRC->A1_LOJA      
            
        	TRC->(dbSkip())
	ENDDO
	TRC->(dbCloseArea())

ENDIF

// *** INICIO CHAMADO 040123 WILLIAM COSTA 07/03/2018

_lret := U_VLDCART() // FONTE M410ALOK              

RETURN(_lret)

Static Function SqlBuscaCliente(cNomeCli)

	Local cQuery := ''
	
	cQuery := " SELECT TOP(1) A1_COD,A1_LOJA  " 
	cQuery += " FROM "+RetSqlName("SA1") + " "  
   	cQuery += " WHERE D_E_L_E_T_ <> '*' " 
	cQuery += " AND A1_MSBLQL   = '2' " 
	cQuery += " AND A1_NOME LIKE '%"+ALLTRIM(cNomeCli)+"%'"
	 
	  TCQUERY cQuery new alias "TRC"   
	       
RETURN(NIL)