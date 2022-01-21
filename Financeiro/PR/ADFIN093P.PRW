#Include "Protheus.ch"
#include 'topconn.ch'

/*/{Protheus.doc} User Function ADFIN093P
     (Cadastro de Feriados para o Financeiro, ao cadastrar a data ex: DD/MM ou DD/MM/AA a mesma valida ao selecionar o dia passando o vencimento para o Proximo dia util.)
     @type  Function
     @author ADRIANO SAVOINE
     @since 26/08/2020
     @version 01
     @history chamado 060906 - 26/08/2020 - ADRIANO SAVOINE - Criado o Programa para lançar datas de Feriado.
     @history Ticket  TI     - 20/01/2022 - ADRIANO SAVOINE - Corrigido o campo para String.
     /*/
 

USER FUNCTION ADFIN093P()

    PRIVATE cCadastro := "Cadastro de Feriado"

    PRIVATE aRotina     := { }
    

    AADD(aRotina, { "Pesquisar", "AxPesqui", 0, 1 })

    AADD(aRotina, { "Visualizar", "AxVisual"  , 0, 2 })

    AADD(aRotina, { "Incluir"      , "U_INC()"   , 0, 3 })

    AADD(aRotina, { "Alterar"     , "AxAltera"  , 0, 4 })


    dbSelectArea("SX5")
    dbSetOrder(1)

    Set Filter To SX5->X5_FILIAL = xFilial("SX5") .AND. SX5->X5_TABELA = '63'

    mBrowse(6, 1, 22, 75, "SX5")



RETURN NIL


User Function INC()  

    Local nOpca := ""
    Local aCpoInc := {"X5_DESCRI","X5_DESCSPA","X5_DESCENG"}


    dbSelectArea("SX5")
    nOpca := AxInclui("SX5",SX5->(Recno()), 3,,"u_CARRESX5()",aCpoInc,,.T.,,,,,,.T.,,,.T.,,)
	


Return 

USER FUNCTION CARRESX5()

    Local cQuery := ""
   
    // Ticket  TI     - 20/01/2022 - ADRIANO SAVOINE
    cQuery := "SELECT MAX ((X5.X5_CHAVE) + 1)MX FROM "+RetSqlName("SX5")+" X5 WHERE  X5.X5_TABELA = '63' AND D_E_L_E_T_ = '' AND X5.X5_FILIAL = '"+xFilial("SX5")+"' 
    cQuery := changequery(cQuery)

    dbUsearea(.T.,"TOPCONN",TCGenQry(,,cQuery), "TMPQRY")

    M->X5_TABELA := '63'
    M->X5_CHAVE  := PADL(TMPQRY->MX,3,'0')

    DBCloseArea()

RETURN
