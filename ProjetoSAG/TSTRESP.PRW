#include "TOTVS.CH"
 
// Direções disponívels para o parâmetro nDirection do construtor e da respectiva propriedade
#define LAYOUT_LINEAR_L2R 0 // LEFT TO RIGHT
#define LAYOUT_LINEAR_R2L 1 // RIGHT TO LEFT
#define LAYOUT_LINEAR_T2B 2 // TOP TO BOTTOM
#define LAYOUT_LINEAR_B2T 3 // BOTTOM TO TOP
 
// Definições de alinhamento específicas para o parâmetro nAlign do método addInLayout
#define LAYOUT_ALIGN_LEFT     1
#define LAYOUT_ALIGN_RIGHT    2
#define LAYOUT_ALIGN_HCENTER  4
#define LAYOUT_ALIGN_TOP      32
#define LAYOUT_ALIGN_BOTTOM   64
#define LAYOUT_ALIGN_VCENTER  128
 
User function TSTRESP() // U_TSTRESP()
 
  DEFINE MSDIALOG oWnd TITLE "Segunda Pesagem de Ração" FROM C(242),C(284) TO C(480),C(820) PIXEL STYLE DS_MODALFRAME

 
  oLayout1:= tLinearLayout():New(oWnd,LAYOUT_LINEAR_T2B,CONTROL_ALIGN_TOP,0,60)
  oLayout1:SetColor(,CLR_BLUE)
  oTButton1 := TButton():New( 0, 0, "Botão 01", oLayout1,{||alert("Botão 01")}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
  oTButton2 := TButton():New( 0, 0, "Botão 02", oLayout1,{||alert("Botão 02")}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
  oTButton3 := TButton():New( 0, 0, "Botão 03", oLayout1,{||alert("Botão 03")}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
  oLayout1:addInLayout(oTButton1)
  oLayout1:addInLayout(oTButton2)
  oLayout1:addInLayout(oTButton3)
 
  oLayout2:= tLinearLayout():New(oWnd,LAYOUT_LINEAR_L2R,CONTROL_ALIGN_RIGHT,100,0)
  oLayout2:SetColor(,CLR_RED)
  oTButton4 := TButton():New( 0, 0, "Botão 04", oLayout2,{||alert("Botão 04")}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
  oTButton5 := TButton():New( 0, 0, "Botão 05", oLayout2,{||alert("Botão 05")}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
  oTButton6 := TButton():New( 0, 0, "Botão 06", oLayout2,{||alert("Botão 06")}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
  oLayout2:addInLayout(oTButton4,LAYOUT_ALIGN_TOP)
  oLayout2:addInLayout(oTButton5,LAYOUT_ALIGN_VCENTER)
  oLayout2:addInLayout(oTButton6,LAYOUT_ALIGN_BOTTOM)
 
  oLayout3:= tLinearLayout():New(oWnd,LAYOUT_LINEAR_B2T,CONTROL_ALIGN_LEFT,100,0)
  oLayout3:SetColor(,CLR_GREEN)
  oTButton7 := TButton():New( 0, 0, "Botão 07", oLayout3,{||alert("Botão 07")}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
  oTButton8 := TButton():New( 0, 0, "Botão 08", oLayout3,{||alert("Botão 08")}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
  oTButton9 := TButton():New( 0, 0, "Botão 09", oLayout3,{||alert("Botão 09")}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
  oLayout3:addInLayout(oTButton7)
  oLayout3:addInLayout(oTButton8)
  oLayout3:addInLayout(oTButton9)
 
  oLayout4:= tLinearLayout():New(oWnd,LAYOUT_LINEAR_R2L,CONTROL_ALIGN_BOTTOM,0,60)
  oLayout4:SetColor(,CLR_YELLOW)
  oTButton10 := TButton():New( 0, 0, "Botão 10", oLayout4,{||alert("Botão 10")}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
  oTButton11 := TButton():New( 0, 0, "Botão 11", oLayout4,{||alert("Botão 11")}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
  oTButton12 := TButton():New( 0, 0, "Botão 12", oLayout4,{||alert("Botão 12")}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
  oLayout4:addInLayout(oTButton10,,60)
  oLayout4:addInLayout(oTButton11,,30)
  oLayout4:addInLayout(oTButton12,,10)
 
  oLayout5:= tLinearLayout():New(oWnd,LAYOUT_LINEAR_T2B,CONTROL_ALIGN_ALLCLIENT,0,60)
  oLayout5:SetColor(,CLR_BLACK)
  oTButton13 := TButton():New( 0, 0, "Botão 13", oLayout5,{||alert("Botão 13")}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
  oTButton14 := TButton():New( 0, 0, "Botão 14", oLayout5,{||alert("Botão 14")}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
  oTButton15 := TButton():New( 0, 0, "Botão 15", oLayout5,{||alert("Botão 15")}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
  oLayout5:addInLayout(oTButton13)
  oLayout5:addInLayout(oTButton14)
  oLayout5:addInLayout(oTButton15)
  oLayout5:addSpacer(4)
 
  oWnd:Activate("MAXIMIZED")
return