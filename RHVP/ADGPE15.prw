#INCLUDE "protheus.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � ADGPE15  �Autor  � Anderson Casarotti � Data � 23/07/2011  ���
�������������������������������������������������������������������������͹��
���Desc.     � Roteiro - Calculo do Vale Transporte - Fretado             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 10                                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function ADGPE15()

Local aArea     := GetArea()
Local nSalAte   := 0
Local nValDesc  := 0
Local nPercDesc := 0
Local nTeto	  	:= 0
Local nDesc 	:= 0
Local nQtFaltas := 0
Local cTab, nLinha
Local cAnoMesDem   
Local cFolMes 

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Roteiro - Calculo do Vale Transporte - Fretado')

//Verifica qual filial deve ser processada "Essa condicao foi feita para que nao seja necessario alterar o campo   
//                                          RA_TRANS_ para N, caso o funcionario seja transferido de filial"
If cEmpAnt == "01"
   If !( SRA->RA_FILIAL $ "02" ) //So trata filiais 02-Varzea e 06-Itupeva	// Retirada Filial 06 - Adilson - 13/04/2018
      Return("")
   EndIf
EndIf

//So calcula para os funcionarios que tiverem o campo Vale Transporte = S
If SRA->RA_TRANS_ <> "S" 
   Return("")
EndIf


//So calcula para os funcionarios diferentes de Autonomos
IF SRA->RA_CATFUNC=="A"
   Return("")
EndIF         
                 
//Nos casos em que o funcionario utiliza tanto o fretado quanto o vale transporte padrao
//o que ira predominar e o desconto do vale transporte padrao(6% do salario)
If Abs(fBuscApd("451")) > 0
   Return("")
EndIf
 
cAnoMesDem := Subs(Dtos(dDataDem),1,6)
cFolMes := fFolMes()		// Alltrim(GetMv("MV_FOLMES")) - Parametro MV_FOLMES nao utilizado no P12 - Adilson - 13/04/2018

//��������������������������������������������������������������Ŀ
//� Pesquisa o conteudo da Tabela U003                           �
//����������������������������������������������������������������
//If cEmpAnt == "01" 
cTab := "U003"		// Fixado uso da tabela U003. A tabela U004 � para Cesta Basica - Adilson - 13/04/2018
//If Alltrim(cEmpAnt) $ ("01/02") 
//   cTab := "U003"
//Else
//   cTab := "U004"
//EndIf   

If ( nLinha := fPosTab(cTab,SALMES,"<=",4) ) > 0   //Compara o Salario com o campo "Salario Ate" da tabela U003
	nValDesc  := fTabela(cTab,nLinha,5)      		//Valor de Desconto
	nPercDesc := fTabela(cTab,nLinha,6) / 100		//Percentual de Desconto
	nTeto     := fTabela(cTab,nLinha,7)      		//Teto de Desconto
Else
	//Exibe Help
	Help(" ",1,"SEMTABELA",,"Tabela "+cTab+" nao cadastrada na manutencao de tabelas",4,5)
	Return
EndIf

//��������������������������������������������������������������Ŀ
//� Processamento                                                �
//����������������������������������������������������������������
If nPercDesc > 0
   nDesc := SALMES * nPercDesc
EndIf

If nValDesc > 0         //Se Valor de Desconto for maior que zero
   nDesc := nValDesc   	//Entao pega o valor de desconto
ElseIf nDesc > nTeto  	//Senao Se o Salario x Percentual for maior que o Teto 
   nDesc := nTeto	//Entao pega o valor do Teto 
Else
   nDesc := nDesc	//Senao pega Salario x Percentual
EndIf   

//Caso existam faltas, tem que descontar proporcional
If Abs(fBuscaPD("409,435")) > 0                             
   nQtFaltas := Int( Abs(fBuscaPD("409,435","H")) / 7.33 ) //Transforma em dias
Endif

nDesc := nDesc / 30 * (DiasTrab - nQtFaltas)

If (GetRotExec()=="FOL") .or. (GetRotExec() == "RES" .and. cCompl # "S") .or.;
	(GetRotExec() == "RES" .and. cCompl == "S" .and. cAnoMesDem==cFolMes )
	
	// Gera a Verba
	fGeraVerba("443",nDesc,,,,,,,,,.T.)                     
		
Endif

RestArea(aArea)
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LIB_DIVERSOS�Autor  �Microsiga         � Data �  07/29/17   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP12                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function fFolMes( aPerAtu, __Filial, __Processo, __Roteiro, __lShow )

 Local aOldAtu := GETAREA()
 Local cRet    := ""

 dbSelectArea( "RCH" )
 
 aPerAtu := {}
 __Filial   := RhFilial("RCH",cFilAnt)
 __Processo := "00001"
 __Roteiro  := "FOL"
 __lShow    := .F.

 // Valida o Periodo Atual em Aberto
 fGetPerAtual( @aPerAtu, __Filial, __Processo, __Roteiro ) // Busca o periodo aberto para trabalho
 If Len( aPerAtu ) = 0
    If __lShow
       Aviso("ATENCAO","N�o Existem Per�odos em Aberto para Este C�lculo!",{"Sair"})
    EndIf
 Else
    cRet := aPerAtu[1,1]
 EndIf

 RESTAREA( aOldAtu )

Return( cRet )
