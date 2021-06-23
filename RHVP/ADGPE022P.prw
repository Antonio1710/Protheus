
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณBaseNegat บAutor  ณNGSi                บ Data ณ  02/09/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gera evento base negativa de INSS e FGTS.                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP11 - Adoro                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function BaseNegat()

Local n_BSFGTS := 0	//Grava o valor das verbas do calculo que compoe a base do INSS
Local n_BSINSS := 0 //Grava o valor das verbas do calculo que compoe a base do FGTS

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Gera evento base negativa de INSS e FGTS.')

//Busca Bases de FGTS
aEval(aPD,{|x|SomaInc(x,6,@n_BSFGTS,12,"N",,,,,aCodFol) } )

//Busca Bases de INSS
aEval(aPD,{|x|SomaInc(x,4,@n_BSINSS,11,"N",12,"N",,,aCodFol) } )

If n_BSINSS < 0
	FGERAVERBA("910",Abs(n_BSINSS),0,,,"V","C",,,,.F.,,,,)
EndIf

If n_BSFGTS < 0
	FGERAVERBA("911",Abs(n_BSFGTS),0,,,"V","C",,,,.F.,,,,)
EndIf

Return(0)

/* 
** ESTRUTURA DO APDV **

RV_COD     --> 01-Codigo
RV_PERC    --> 02-Percentual da Verba
RV_CODCORR --> 03-Codigo Correspondente
RV_INSS    --> 04-Incidencia Base INSS
RV_IR      --> 05-Incidencia Base IR
RV_FGTS    --> 06-Incidencia Base FGTS
RV_MED13   --> 07-Incidencia Media 13o
RV_MEDFER  --> 08-Incidencia Media Ferias
RV_PERICUL --> 09-Incidencia Base Periculosidade
RV_INSALUB --> 10-Incidencia Base Insalubridade
RV_REFFER  --> 11-Se Refere a Ferias
RV_REF13   --> 12-Se Refere a 13o Salario
RV_ADIANTA --> 13-Se Refere a Adiantamento
RV_RAIS    --> 14-Incidencia para RAIS
RV_DIRF    --> 15-Incidencia para DIRF
RV_DSRHE   --> 16-Incidencia para DSR S/ Horas
RV_HE      --> 17-Se e Verba de Hora Extras
RV_INCORP  --> 18-Se a Verba Incorpora Salario
RV_ADICTS  --> 19-Verba Adic. Tempo Servico
RV_SINDICA --> 20-Incidencia Base Contrib. Sindical
RV_SALFAMI --> 21-Incidencia Base Sal. Familia
RV_SEGVIDA --> 22-Incidencia Base Seguro Vida
RV_MEDAVI  --> 23-Incidencia Media Aviso Previo
RV_CONVCOL --> 24-Incidencia Base Convencao Coletiva
RV_DEDINSS --> 25-Verba Deduz da Guia INSS
RV_MEDREAJ --> 26-Se e Media Reajustavel
RV_TIPOCOD --> 27-Tipo do Codigo 1=Prov.,2=Desc.,3=Base
RV_PENSAO  --> 28-Incidencia para Pensao Alimenticia
RV_DSRPROF --> 29-Incidencia para DSR Professores
RV_HRSATIV --> 30-Incidencia para Horas Atividade Professores
RV_TAREFA  --> 31-Codigo da Tarefa
RV_CODDSR  --> 32-Codigo DSR
RV_BSCCIVI --> 33-Incidencia Base Constru็ใo civil

*/
