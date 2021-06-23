///////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Função            : MT103IPC                                                                              //
// Autor             : Mauricio - HC Consys                                                                  //
// Data criação      : 06/07/2009                                                                            //
// Descrição         : Grava campo projeto na NF de entrada com campo projeto do Pedido de Compra.Cham.004603//
// Parâmetros        : nenhum                                                                                //
// Retorno           : nenhum                                                                                //
// Utilização        : Empresa Adoro                                                                         //
// ----------------------------------------------------------------------------------------------------------//
// ALTERAÇÕES EFETUADAS                                                                                      //
// Nº | Data        | Programador         | Descrição                                                        //
// 01 |             |                     |                                                                  //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////


//   JUNTAR COM PE DA PRODUCAO
#INCLUDE "rwmake.ch"

User Function MT103IPC()

//Alteração 01 - INÍCIO
Local _cOldArea
Local _nTipPro	 := 0
Local _nPosPedido  := 0
Local _nPosAliqIPI := 0
Local _nOrdemSC7   := 0
Local _nPosValIPI  := 0
Local _nCntaCol    := 0  

_cOldArea := GetArea() //Salva área atual 

if cEmpAnt == "01"
_nPosPedido   := aScan(aHeader,{|x|AllTrim(x[2]) == "D1_PEDIDO"})
_nPosItem	  := aScan(aHeader,{|x|AllTRim(x[2]) == "D1_ITEMPC"})
_nPosVerba    := aScan(aHeader,{|x|AllTrim(x[2]) == "D1_PROJETO"})
_nOrderSC7	:= SC7->( RetIndex() )

SC7->( dbSetOrder(1) )

For _nCntaCol := 1 to Len(aCols)
	SC7->( dbSeek(xFilial("SC7")+aCols[_nCntaCol][_nPosPedido]+aCols[_nCntaCol][_nPosItem]))
	If SC7->( Found() )
		aCols[_nCntaCol][_nPosVerba] := SC7->C7_PROJETO
	EndIf
Next _nCntaCol

SC7->( dbSetOrder(_nOrderSC7) )
endif
RestArea(_cOldArea) // Devolve área atual 

Return(Nil)

