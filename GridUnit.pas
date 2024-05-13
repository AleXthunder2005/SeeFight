Unit GridUnit;

Interface
Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.StdCtrls, Vcl.ExtCtrls, FieldGeneratorUnit;

    Procedure DrawField(Var Image: TImage; StateMatrix: TField);
    Procedure DrawShip(Var Image: TImage; ColCount, RowCount: Byte);

Implementation
Uses
    SettingsUnit;

Procedure DrawShip(Var Image: TImage; ColCount, RowCount: Byte);
Var
    I, J, X, Y: Byte;
    CurrRect: TRect;
Const
    DECK_WIDTH = 30;
Begin
    With Image do
    Begin
        Height := RowCount * DECK_WIDTH;
        Width := ColCount * DECK_WIDTH;

        Picture := Nil;

        Canvas.Pen.Color:= ClDkGray;
        For I := 0 To RowCount-1 Do
        Begin
            Y :=  I*DECK_WIDTH;
            For J := 0 To ColCount-1 Do
            Begin
                X := J*DECK_WIDTH;
                CurrRect := Rect(X, Y, X + DECK_WIDTH, Y + DECK_WIDTH);

                Canvas.Brush.Color:= Apperance.ShipColor;
                Canvas.FillRect(CurrRect);

                Canvas.Rectangle(CurrRect);
            End;
        End;
    End;
End;

Procedure DrawField(Var Image: TImage; StateMatrix: TField);
Const
    SIZE = 10;
    CELL_WIDTH = 30;
Var
    I, J: ShortInt;
    X, Y: Word;
    CurrRect: TRect;
    CellColor: TColor;
Begin
    With Image Do
    Begin
        Height := SIZE * CELL_WIDTH;
        Width := SIZE * CELL_WIDTH;

        Canvas.Pen.Color:=clSkyBlue;
        For I := Low(StateMatrix)+1 To High(StateMatrix)-1 Do
        Begin
            Y :=  I*CELL_WIDTH;
            For J := Low(StateMatrix)+1 To High(StateMatrix)-1 Do
            Begin
                X := J*CELL_WIDTH;
                CurrRect := Rect(X, Y, X + CELL_WIDTH, Y + CELL_WIDTH);

                Case StateMatrix[J, I] Of
                    stImpossible: CellColor := Apperance.ImpossibleShipColor;
                    stFree: CellColor := Apperance.FreeCellColor;
                    stDamaged: CellColor := Apperance.DamagedShipColor;
                Else
                    CellColor := Apperance.ShipColor;
                End;

                Canvas.Brush.Color:=CellColor;
                Canvas.FillRect(CurrRect);

                Canvas.Rectangle(CurrRect);
            End;
        End;
    End;
End;

End.
