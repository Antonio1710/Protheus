#include "Protheus.ch"
/*/{Protheus.doc} MNTA3308
    (long_description)
    @type  Function
    @author Tiago H. Stocco - Obify
    @since 19/01/2021
    @version TKT - 4931
    @param param_name, param_type, param_descr
    Retorno:	
    .T. (Verdadeiro) ? Desconsidera a manutenção para a geração das ordens de serviço do plano.
    .F. (Falso) ? Considera a manutenção gerando uma ordem para o plano.
    PONTO DE ENTRADA PARA NAO GERAR A OS COM MESMO SERVIÇO PREVENTIVO NO MESMO PERIODO,
    PREVENTIVA DIARIA ESTAVA DUPLICANDO TODAS NA SEGUNDA FEIRA
    **SOLUCAO DESPREZAR OS DE SABADO E DOMINGO VIA PLANO DE MANUTENCAO
       /*/

User Function MNTA3308()
   
Local lReturn   := .F.
Local cTable    := ParamIXB[1]
Local aFields   := ParamIXB[2]

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Gravar o custo do Salario do Funcionario da Manutenção')

//Alert((ctable)->DTREAL+" - "+Transform(DOW((ctable)->DTREAL),"@E 999,99"))
If DOW((ctable)->DTREAL) == 1 .or. DOW((ctable)->DTREAL) == 7 //Verifica se é sabado e domingo
    lReturn := .T. //Despreza OS de Sabado e Domingo
EndIf

Return lReturn
