#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FA390TOK() º Autor ³ HCCONSYS          º Data ³  12/02/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Ponto de Entrada utilizado na Geracao de Cheque S/Titulo   º±±
±±º          ³ Nao permite que sejam utilizados cheques de mesmo numero   º±±
±±º          ³ para mesma banco/agencia/conta independ. da Filial   		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8		                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function FA390TOK()

Local aArea		:= GetArea()
Local lRet		:= .T.       
Local cQuery	:= ""
Local nRegs		:= 0     

//--------------------------------------
// Se opção for Redepósito de Cheques   
// não executa validação abaixo 
//--------------------------------------
if paramIxb:CTITLE == "Redepositar Cheque"
   return(lRet) 
endif 


&& Verificar se ja existe cheque com numero informado, nao importando a Filial.
cQuery := "SELECT EF_BANCO,EF_AGENCIA,EF_CONTA,EF_NUM,EF_FILIAL "
cQuery += "FROM " + RETSQLNAME("SEF") + "  "
cQuery += "WHERE D_E_L_E_T_ = ' ' "
cQuery += "AND EF_BANCO 	= '" + cBanco390 		+ "'  "
cQuery += "AND EF_AGENCIA 	= '" + cAgencia390 	+ "'  "
cQuery += "AND EF_CONTA 	= '" + cConta390 		+ "'  "
cQuery += "AND EF_NUM 		= '" + cCheque390		+ "'  "

TcQuery cQuery New Alias "TSEF"

Count to nRegs

TSEF->(dbGoTop())

If nRegs > 0 
	
	MsgInfo("Numero de cheque ja informado para a Filial " + TSEF->EF_FILIAL + ". Verifique!" )
	lRet	:= .F. 	
Endif

TSEF->(dbCloseArea())      

RestArea(aArea)

Return(lRet)
            

/*
CBANCO390
CAGENCIA39
CCONTA390
CCHEQUE390
DVENCINI
DVENCFIM
NLIMIT190
CFORN390
CBENEF390
CNATUR390
CHIST390
*/