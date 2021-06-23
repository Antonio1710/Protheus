#INCLUDE "protheus.ch"

/*/{Protheus.doc} User Function MT100GRV
  Ponto de Entrada desenvolvido para corrigir data de emissão dos Doc. de Entrada conforme regra:
    Tipo = Devolução
    Formulário Próprio = Não
    Esse erro começou a ocorrer após a atualização da MATA103 de Dez/2019.
    As variáveis do cabeçalho da pré nota estão declaradas como Private e são: cTipo / cFormul / cNFiscal / cSerie / dDEmissao / cA100For / cLoja / cEspecie / cUfOrigP
    Apesar da variável dDEmissao ser atualizada a mesma não foi apresentada na tela de forma correta, sendo necessário atualizar também o array aAutoCab.
    Esse ponto de entrada permite manipular os dados da Pré Nota antes de exibir a tela.
  @type User Function
  @author Abel Babini
  @since 02/03/2020
  @version 1
  @history Chamado Interno TI - Abel Babini			- 02/03/2020 - Criação de validação para não permitir a gravação de documento de entrada com data de emissão incorreta
  /*/

User Function MT140CAB(lExp01)
  Local nPosEmis  := aScan(aAutoCab,{|x| AllTrim(Upper(x[1]))=="F1_EMISSAO"})
  Local nPosTipo  := aScan(aAutoCab,{|x| AllTrim(Upper(x[1]))=="F1_TIPO"})
  Local nPosForm  := aScan(aAutoCab,{|x| AllTrim(Upper(x[1]))=="F1_FORMUL"})
  Local lRet      := .T.

  IF  INCLUI .AND. ;
      IsInCallStack( "U_CENTNFEXM" ) .AND. ;
      aAutoCab[nPosTipo,2] == 'D' .AND. ;
      aAutoCab[nPosForm,2] == 'N'
    
    aAutoCab[nPosEmis,2] := RECNFXML->XML_EMISSA
    dDEmissao := RECNFXML->XML_EMISSA
  ENDIF

Return lRet
