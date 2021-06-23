#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"      

#DEFINE BROWSE_ALIAS  		"ZC1"
#DEFINE BROWSE_DESCRIPTION "Projeto x Centro de Custo"
#DEFINE NAME_MODEL			"ADPRJ002P"
#DEFINE MVC_MODEL			"_PRJ002P"

Static cFunBkp  := FunName()
Static aAreaAtu := GetArea()

/*
Programa: ADPRJ002P.PRW
Autor: Adriana Oliveira
Data: 19/10/2017
Origem: Menu Gestao de Projetos     
Descricao: Cadastro Projeto x Centro de Custo
Chamado: 037663
*/                 

User Function ADPRJ002P()

Local oBrowse
cFunBkp  := FunName()
aAreaAtu := GetArea()

SetFunName("ADPRJ002P")

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro Projeto x Centro de Custo')

// Reseto quando chamada ocorre dentro de outro MVC
If AllTrim(cFunBkp) <> "ADPRJ002P"
	aRotina := {}       
EndIf

//NEW MODEL para tabela não normalizada tipo master x detail

NEW MODEL ;
TYPE 2 ;
DESCRIPTION BROWSE_DESCRIPTION ;
BROWSE oBrowse ;
SOURCE NAME_MODEL ;
MODELID MVC_MODEL ;
MASTER BROWSE_ALIAS ;
PRIMARYKEY {'ZC1_FILIAL','ZC1_PROJET', 'ZC1_CC'} ;
HEADER { 'ZC1_PROJET' } ;
RELATION { { 'ZC1_FILIAL', 'xFilial( "ZC1" )' }, ;
{ 'ZC1_PROJET', 'ZC1_PROJET' } } ;
UNIQUELINE { 'ZC1_CC' } ;  
ORDERKEY ZC1->( IndexKey( 1 ) ) ;
                            
SetFunName(cFunBkp)
RestArea(aAreaAtu)   

Return NIL