#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"   
#INCLUDE "XMLXFUN.CH"
#INCLUDE "Rwmake.ch"
#INCLUDE 'Topconn.ch' 

/*{Protheus.doc} User Function MT170SLD
	É executado dentro do laço onde  é feito o cálculo do saldo do produto de todos os almoxarifados. O resultado do cálculo do saldo é guardado na variável nSaldo. O ponto de entrada é executado após a atualização desta variável, produto a produto (todos os almoxarifados). Não trazer mais produtos com ponto de pedido < 0
	@type  Function
	@author WILLIAM COSTA
	@since 23/09/2020
	@version 01
	
*/

User Function MT170SLD( )

    Local nQuant    := PARAMIXB[1]     //-- Saldo calculado pelo sistema
    Local cProd     := PARAMIXB[2]     //-- Códido do produto
    Local cLocal    := PARAMIXB[3]     //-- Armazém do produto
    Local nNewSaldo := 0 

    IF nQuant < 0

        nNewSaldo := 0

    ELSE

        nNewSaldo := nQuant

    ENDIF        

Return (nNewSaldo)
