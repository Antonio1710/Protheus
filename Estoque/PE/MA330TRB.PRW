
#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"

#DEFINE ENTER CHR(13)+CHR(10)

/*/{Protheus.doc} User Function MA330TRB
	Ponto de Entrada Recalculo Custo Medio Altera ordem de processamento de movimentos  
	https://tdn.totvs.com/display/public/mp/Ponto+de+Entrada+MA330TRB
	https://tdn.totvs.com/pages/releaseview.action?pageId=340361781
	https://tdn.totvs.com/display/public/PROT/Materiais+-+Monitor+de+Custos
	@type  Function 
	@author Fernando Macieira
	@since  09/04/18 
	@version version
	@history 01/12/2020, Andre Mendes, TKT:3515 - Ajustar a ordem das transferências, colocando as mesmas em primeiro lugar, ou seja 100.
	@history 27/01/2022, Fer Macieira, TKT:66653- Regra Sequencia de Calculo arm 11 filial 02 TM 503 - Mudança sequência cálculo armazém devolução quebra
	@history 18/07/2022, Fernando Macieira, TKT:75632- Sequencia de Calculo filial 02 arm 46
/*/
User Function MA330TRB()

	Local aArea 	:= GetArea()
	Local aAreaSD3 	:= SD3->( GetArea() )
	Local nTt       := 0
	Local nTtAlt    := 0
	Local cEmpProc	:= GetMV("MV_#CMEMP",,"01")
	Local cFilProc	:= GetMV("MV_#CMFIL",,"02")
	Local cTMProc	:= GetMV("MV_#CMTM",,"503")
	Local cAlmProc	:= GetMV("MV_#CMALM",,"11")
	Local cAlmDev	:= GetMV("MV_#CMALD",,"46") // @history 18/07/2022, Fernando Macieira, TKT:75632- Sequencia de Calculo filial 02 arm 46

	//cTimeIni := time()
	
	//Copy to "CMTEMP1"+GETDBEXTENSION() //copia trb antes da mudança das sequências 

	dbSelectArea("TRB")
	TRB->( dbSetOrder(9) )
	TRB->( dbGoTop() )
	Do While TRB->( !EOF() )

		nTt++

		// @history 27/01/2022, Fer Macieira, TKT:66653- Regra Sequencia de Calculo arm 11 filial 02 TM 503 - Mudança sequência cálculo armazém devolução quebra
		If (AllTrim(cEmpAnt) $ AllTrim(cEmpProc)) .and. (AllTrim(TRB->TRB_FILIAL) $ AllTrim(cFilProc))

			If AllTrim(TRB->TRB_LOCAL) $ AllTrim(cAlmProc) .and. AllTrim(TRB->TRB_ALIAS) == "SD3"
			
				SD3->( dbGoTo( TRB->TRB_RECNO ) ) // Posiciono na SD3 e confiro registro setado para ter ctz de que está no movimento correto!
				If !SD3->( EOF() ) .and. AllTrim(SD3->D3_COD) == AllTrim(TRB->TRB_COD) .and. AllTrim(SD3->D3_NUMSEQ) == AllTrim(TRB->TRB_SEQ) .and. AllTrim(SD3->D3_TM) $ AllTrim(cTMProc) .and. AllTrim(TRB->TRB_LOCAL) == AllTrim(SD3->D3_LOCAL)

					nTtAlt++
					RecLock("TRB", .F.)
						TRB->TRB_ORDEM := "601"
						TRB->TRB_NIVEL := Subs(TRB_NIVEL,1,2)+"z"
					TRB->( msUnlock() )

				EndIf

			EndIf

			// @history 18/07/2022, Fernando Macieira, TKT:75632- Sequencia de Calculo filial 02 arm 46
			/*
			500 = Saída para Vendas
			500 = Entrada por Devolução de Venda - Período Atual
			*/
			If AllTrim(TRB->TRB_LOCAL) $ AllTrim(cAlmDev) .and. AllTrim(TRB->TRB_ALIAS) == "SD1" .and. AllTrim(TRB->TRB_TIPONF) == "D"
				RecLock("TRB", .F.)
					TRB->TRB_ORDEM := "499"
					TRB->TRB_NIVEL := Subs(TRB_NIVEL,1,2)+"z"
				TRB->( msUnlock() )
			EndIf
			//

		EndIf

		//TKT:3515- Ajustar a ordem das transferências, colocando as mesmas em primeiro lugar, ou seja 100.  
		If TRB->TRB_ALIAS == "SD1" .and. TRB->TRB_ORDEM == "300" .and. TRB->TRB_USATRA == "S"
			RecLock("TRB", .F.)
				TRB_ORDEM := "100"
			TRB->( MsUnlock() )
		Endif      
	
		TRB->( dbSkip() )

	EndDo

	//dbSelectArea("TRB")
	//dbGoTop()
	//Copy to "CMTEMP2"+GETDBEXTENSION() //copia trb após as mudanças das sequências

	/*
	Alert("Total regs TRB:" + Str(nTt))
	Alert("Total regs TRB alterados:" + Str(nTtAlt))
	Alert("Tempo total: " + ElapTime(cTimeIni, Time()))
	*/

	RestArea( aAreaSD3 )
	RestArea( aArea )

Return

/*
https://tdn.totvs.com/display/public/mp/Ponto+de+Entrada+MA330TRB

Recálculo do Custo Médio - Ponto de entrada MA330TRB

   A função primordial da rotina de recálculo do custo médio é reordenar as movimentações de forma que todas as entradas sejam processadas antes das saídas em um mesmo período. As informações disponíveis para realizar esta ordenação são: data da movimentação (i.e.: movimentações que ocorreram no início do período influenciarão o custo das demais, e não o inverso) e a natureza da movimentação (i.e.: normalmente uma produção utiliza a matéria prima já existente no estoque, por isso consideramos que movimentações de entrada de matéria prima terão influência no custo do produto a ser produzido, e não o contrário). Para casos em que ocorrem várias movimentações em um mesmo período, como  por exemplo, no método de apropriação mensal, com todas as movimentações que ocorreram dentro do mês devem ser ordenadas independentemente da data em que tenha ocorrido, utilizamos apenas a natureza da movimentação como critério de desempate nesta reordenação.

   Para atender a maioria dos casos encontrados em nossos clientes definimos que nossa rotina de recálculo de custo médio deve ordenar as naturezas das movimentações ocorridas dentro de um mesmo período (dia, semana, mês etc.) da seguinte forma:

 Ordem de Cálculo

Tipo de Movimentação

Observação

080

Movimento de Ajuste Cambial (para a localização da Bolívia)

Tabela SD3

095

Entrada por Remito de Compra (apenas para algumas localizações)

Tabela SCM

100

Entrada por Compra

Tabela SD1

110

Entrada por Liberação ou Rejeição de CQ

Tabela SD3

120

Entrada direcionada a OP (i.e.: gera RE5) de Produto de terceiros a ser Beneficiado por mim - Período Anterior

Tabelas SD1/SD3

120

Entrada direcionada a OP (i.e.: gera RE5) - Período Anterior

Tabelas SD1/SD3

145

Entrada por Devolução de Compra (apenas para algumas localizações)

Tabela SCM

150

Entrada por Devolução Compra

Tabela SD2

195

Entrada por Devolução de Vendas (apenas para algumas localizações) - Período Anterior

Tabela SCN

200

Entrada por Devolução de Vendas - Período Anterior

Tabela SD1

250

Entrada por Recebimento de Produto de terceiros a ser Beneficiado por mim - Período Atual

Tabela SD1

280

Entrada por Recebimento de Produto de terceiros a ser Beneficiado por mim - Período Anterior

Tabela SD1

290

Saída para Envio de Beneficiamento feito por mim

Tabela SD2

300w

Transferência

Tabela SD3

300w

Saída para Transferência entre Filiais

Tabela SD2

300w

Entrada de Transferência entre Filiais

Tabela SD1

300x

Saída - Envio de Produto sem estrutura para Beneficiamento a ser feito por terceiros

Tabela SD2

300x

Entrada por Recebimento de Produtos com estrutura que foi Beneficiado por terceiros

Tabela SD1

300y

Entrada por Recebimento de Produtos sem estrutura que foi Beneficiado por terceiros

Tabela SD1

300y

Saída - Envio de Produto com estrutura para Beneficiamento a ser feito por terceiros

Tabela SD2

300

Movimentações Internas, exceto Requisição para Consumo (i.e.: ordem 301) e Transferência (i.e.: ordem 300w).

Tabela SD3

300

Entrada direcionada a OP (i.e.: gera RE5) de Produto de terceiros a ser Beneficiado por mim - Período Atual

Tabelas SD1/SD3

300

Entrada direcionada a OP (i.e.: gera RE5) - Período Atual

Tabelas SD1/SD3

301

Saída para Requisição de Consumo

Tabela SD3

480

Saída para Apontamento de Projetos (SIGAPMS)

SIGAPMS

495

Saída para Remito de Venda (apenas para algumas localizações)

Tabela SCN

500

Saída para Vendas

Tabela SD2

500

Entrada por Devolução de Venda - Período Atual

Tabela SD1

545

Entrada por Devolução de Venda (apenas para algumas localizações) - Período Atual

Tabela SCN

600

Reavaliação de Custo (REA/DEA)

Tabela SD3

610

Movimento de acerto do custo de reposição

Tabela SD3

 

 

   Com esta seqüencia atendemos grande parte da operação de nossos clientes, mas há casos particulares ou situações pontuais que exigem que as movimentações sejam ordenadas de forma diferente desta mostrada acima. Veja: normalmente as operações de transferência devem ser consideradas em uma seqüência posterior a operações de movimentos internos para que o custo das devoluções ao estoque seja agregado ao custo do produto antes que este seja transferido. Observe que esta situação está coberta pela seqüência padrão de calculo acima, onde movimentações internas recebem a seqüência de cálculo 300 e movimentações de transferência recebem a seqüência de cálculo 300w. Se por qualquer motivo uma empresa precise que seja feita uma transferência entre diferentes produtos, fazendo com que o estoque de produto A seja transferido para (i.e.: se “transforme” em) produto B para que a seguir o estoque deste produto B seja requisitado para determinada OP... Neste caso a seqüência padrão já não seria mais válida; A transferência de produtos receberia a seqüência de cálculo 300w e a requisição para OP, feita logo a seguir, receba a seqüência de cálculo 300...

   Neste exemplo a ordenação proposta pelo sistema padrão inverteria a ordem natural da movimentação, fazendo com que o custo da devolução da transferência não fosse considerado na requisição para OP. Mais um ponto: se estas fossem as primeiras movimentações no período e se o produto não tivesse custo histórico o custo do mesmo ficaria negativo!

   A ferramenta disponibilizada para adequar casos como o exemplificado acima é o ponto de entrada MA330TRB ( neste link do TDN existem mais informações sobre este ponto, inclusive com um exemplo real de utilização postado pelo Henrique Magalhaes Dias da Silva), que possibilita a alteração da seqüência de cálculo que é atribuída pelo sistema à determinada movimentação durante o recálculo do custo; No exemplo acima o tratamento deveria abranger apenas as transferência de produtos que tivessem códigos diferentes na entrada e saída de uma mesma movimentação de transferência – para estes casos a seqüência de cálculo pode ser alterada, por exemplo, de 300w para 290w, incluindo esta movimentação antes dos movimentos internos, que possuem seqüência de cálculo 300.

   Este ponto de entrada interfere no desempenho da rotina e  não fere a integridade dos dados, sendo considerado como um dispositivo padrão de parametrização do recálculo do custo médio nos casos, onde a ordenação padrão sugerida não atende as necessidades específicas encontradas em determinadas empresas.


*/
