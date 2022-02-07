#include "rwmake.ch" 

/*/{Protheus.doc} User Function WhenSC5
   Especifico Ad'oro Alimenticia 
   Rotina utilizada na propriedade X3_WHEN dos campos do SC5
   Rotina utilizada na propriedade X3_WHEN dos campos do SC5
   para que nao sejam editados na rotina AROTEM2.PRX, ou seja
   na roteirizacao manual (Modelo 2 - GetDados) 
    @type  Function
    @author Rogerio Eduardo Nutti
    @since 01/02/2011
    @version 01
    @history Macieira - ticket TI   - 07/02/2022 - Mudança do cabeçalho do fonte..
/*/

User Function WhenSC5()    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_lRetorn := .F. //chamado 031808 William Costa, falha no when para bloquear campos como C5_ENDERE entre outros 

If Alltrim(FunName())=="#ALTEROTE"  // Ideal seria se fosse apenas "AROTEM2"
   _lRetorn := .F.                  // porem a funcao FunName() sempre
Endif                               // retorna a rotina principal.

Return(_lRetorn)
