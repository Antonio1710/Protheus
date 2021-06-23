#include 'protheus.ch'
#include 'parmtype.ch'

user function MA972VLR()
Local cCodigo := PARAMIXB[1] //CODIGO QUE ESTA EM EXECUÇÃO("23", "24" ou "25")
Local cAlias  := PARAMIXB[2] // cAliasSF3
Local nValor  := PARAMIXB[3] // Valor que esta sendo processado para esta saída


//Validações para registro 23

if cCodigo ="23" .and. alltrim((cAlias)->F3_ESPECIE) $ "SPED"
       Return 1
endif
 

//Validações para registro 24
if cCodigo ="24" .and. alltrim((cAlias)->F3_ESPECIE) $ "NFSC"
       Return 1
endif


//Validações para registro 25

if cCodigo ="25" .and. alltrim((cAlias)->F3_ESPECIE) $ "SPED"
       Return 1
endif

Return nValor