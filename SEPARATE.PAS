Program SeparateArray;
Const Max=100;
      FI='Data2.txt';
Type hData=Record
                 Value,Key,h:Integer;
                 OK:Boolean;
           End;
     Data=Record
                Value,Key:Integer;
          End;
     ArraySD=Array[1..Max] of Integer;
     ArrayMD=Array[1..Max] of hData;
     ArrayResult=Array[1..Max] of Data;
     ArrayRem=Array[1..Max] of Integer;
Var ASD:ArraySD;
    AMD:ArrayMD;
    Right,Left:ArrayResult;
    Length,lRight,lLeft:Integer;

Procedure Init(Var a:ArraySD; Var n:Integer);
Var F:Text;
    i:Integer;
Begin
     Assign(F,FI);
     Reset(F);
     Readln(F,n);
     For i:=1 to n do
         Read(F,a[i]);
     Close(F);
End;

Procedure Swaph(Var a,b:hData);
Var temp:hData;
Begin
     temp:=a;
     a:=b;
     b:=temp;
End;

Procedure SortMD(Var aMD:ArrayMD; n:Integer);
Var i,j:Integer;
Begin
     For i:=1 to n-1 do
         For j:=i+1 to n do
             If aMD[i].Value<aMD[j].Value then
                Swaph(aMD[i],aMD[j]);
End;

Procedure Converse(Var aMD:ArrayMD; aSD:ArraySD; n:Integer);
Var i:Integer;
Begin
     For i:=1 to n do
         Begin
              aMD[i].Value:=aSD[i];
              aMD[i].Key:=i;
              aMD[i].h:=0;
              aMD[i].OK:=False;
         End;
     SortMD(aMD,n);
End;
{-----------------------------------------------------}
Function CheckOK(aMD:ArrayMD; n:Integer):Boolean;
Var i:Integer;
Begin
     CheckOK:=True;
     For i:=1 to n do
         If aMD[i].OK=False then
            Begin
                 CheckOK:=False;
                 Exit;
            End;
End;

Function SearchFirst(aMD:ArrayMD; n:Integer):Integer;
Var i:Integer;
Begin
     SearchFirst:=0;
     For i:=1 to n do
         If aMD[i].OK=False then
            Begin
                 SearchFirst:=i;
                 Exit;
            End;
End;

Function Sum(R:ArrayRem; n:Integer):Integer;
Var i,S:Integer;
Begin
     S:=0;
     For i:= 1 to n do
         S:=S+AMD[R[i]].Value;
     Sum:=S;
End;

Procedure Copy(Var A:ArrayResult; Var l:Integer; R:ArrayRem; n:Integer);
Var k:Integer;
Begin
     For k:=1 to n do
         Begin
              l:=l+1;
              A[l].Value:=AMD[R[k]].Value;
              A[l].Key:=AMD[R[k]].Key;
         End;
End;

Procedure Push(Var R:ArrayRem;Var aMD:ArrayMD; n:Integer; l:Integer);
Begin
     R[n]:=l;
     aMD[l].OK:=True;
End;

Function heuristic(aMD:ArrayMD; SR,SL,Rem,n:Integer):Integer;
Var i,Min:Integer;
Begin
     Min:=0;
     For i:=1 to n do
         If aMD[i].OK=False then
            Begin
                 aMD[i].h:=Abs(SL+aMD[i].Value+Rem-SR);
                 Min:=i;
            End;
     If Min=0 then
        heuristic:=0
     Else
         Begin
              For i:=n downto 1 do
                  If (aMD[i].OK=False) And (aMD[Min].h>aMD[i].h) then
                     Min:=i;
              heuristic:=Min;
         End;
End;

Procedure CopyChoice(Var Right,Left:ArrayResult; Var lRight,lLeft:Integer; Rem:Integer; l:Integer; aMD:ArrayMD);
Begin
     If Rem<0 then
        Begin
             lLeft:=lLeft+1;
             Left[lLeft].Value:=aMD[l].Value;
             Left[lLeft].Key:=aMD[l].Key;
        End
     Else
        Begin
             lRight:=lRight+1;
             Right[lRight].Value:=aMD[l].Value;
             Right[lRight].Key:=aMD[l].Key;
        End;
End;

Procedure Separate(Var Right,Left:ArrayResult; Var lRight,lLeft:Integer; aMD:ArrayMD; n:Integer);
Var RemR,RemL:ArrayRem;
    i,j,k,Rem,SR,SL:Integer;
Begin
     Rem:=0;
     While Not CheckOK(aMD,n) do
           Begin
                i:=1;
                j:=1;
                Push(RemR,aMD,i,SearchFirst(aMD,n));{dua vao va danh dau}
                If SearchFirst(aMD,n)=0 then
                   CopyChoice(Right,Left,lRight,lLeft,Rem,RemR[i],aMD)
                Else
                    Begin
                         Push(RemL,aMD,j,SearchFirst(aMD,n));
                         SR:=Sum(RemR,i);
                         SL:=Sum(RemL,j);
                         If SR>SL+Rem then
                            Repeat
                                  k:=heuristic(aMD,SR,SL,Rem,n);
                                  If k=0 then Break
                                  Else
                                      Begin
                                           j:=j+1;
                                           Push(RemL,aMD,j,k);
                                           SL:=SL+aMD[k].Value;
                                      End;
                            Until (Rem+SL-SR)>=0;
                         If Rem+SL-SR>=0 then
                            Begin
                                 Copy(Right,lRight,RemR,i);
                                 Copy(Left,lLeft,RemL,j);
                            End
                         Else
                             If Rem<=0 then
                                Begin
                                     Copy(Left,lLeft,RemR,i);
                                     Copy(Right,lRight,RemL,j);
                                End
                             Else
                                 Begin
                                      Copy(Right,lRight,RemR,i);
                                      Copy(Left,lLeft,RemL,j);
                                 End;
                         Rem:=Rem+SL-SR;
                    End;
           End;
End;
{----------------------------------------------------------------------------------------}
Procedure Swap(Var a,b:Data);
Var temp:Data;
Begin
     temp:=a;
     a:=b;
     b:=temp;
End;

Procedure Sort(Var A:ArrayResult; n:Integer);
Var i,j:Integer;
Begin
     For i:=1 to n-1 do
         For j:=i+1 to n do
             If A[i].Key>A[j].Key then
                Swap(A[i],A[j]);
End;

Procedure WriteArray(aSD:ArraySD; n:Integer; Right,Left:ArrayResult; lRight,lLeft:Integer);
Var i,S:Integer;
Begin
     Sort(Right,lRight);
     Sort(Left,lLeft);
     Writeln('Day so ban dau la:');
     S:=0;
     For i:=1 to n do
         Begin
              S:=S+aSD[i];
              Write(aSD[i]:4);
         End;
     Writeln;
     Writeln('Voi tong la:',S);
     Writeln('Duoc chia ra hai day nhu sau:');
     Write('Day 1:');
     S:=0;
     For i:= 1 to lRight do
         Begin
              S:=S+Right[i].Value;
              Write(Right[i].Value:3);
         End;
     Writeln;
     Writeln('Voi tong la:',S);
     Write('Day 2:');
     s:=0;
     For i:= 1 to lLeft do
         Begin
              S:=S+Left[i].Value;
              Write(Left[i].Value:3);
         End;
     Writeln;
     Writeln('Voi tong la:',S);
End;

Begin
     Init(ASD,Length);
     Converse(AMD,ASD,Length);
     Separate(Right,Left,lRight,lLeft,AMD,Length);
     WriteArray(ASD,Length,Right,Left,lRight,lLeft);
     Readln;
End.