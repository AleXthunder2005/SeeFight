unit ClassFieldUnit;

interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls;

type
    TFieldCellState = (stImpossible = -1, stFree, stShortShip, stSmallShip, stMiddleShip, stLongShip);
    TField = array [-1..10, -1..10] of TFieldCellState;

    TFieldImage = class (TImage)
        StateMatrix: TField;

        private
            function CreateNewField(): TField;
        public
            { Public declarations }
        constructor Create (Owner: TComponent); override;
        procedure Draw; override;
    end;

implementation

constructor TFieldImage.Create(Owner: TComponent);
begin
    inherited Create(Owner);
    Self.StateMatrix := CreateNewField();
end;

procedure TFieldImage.Draw;
begin
    inherited Draw();
end;

function CreateNewField(): TField;
var
    I, J: ShortInt;
    EmptyField: TField;
begin
    for J := Low(EmptyField) to High(EmptyField) do
        EmptyField[-1, J] := stImpossible;

    for I := Low(EmptyField)+1 to High(EmptyField)-1 do
    begin
        for J := Low(EmptyField)+1 to High(EmptyField)-1 do
            EmptyField[I, J] := stFree;
        EmptyField[I, Low(EmptyField)] := stImpossible;
        EmptyField[I, High(EmptyField)] := stImpossible;
    end;

    for J := Low(EmptyField) to High(EmptyField) do
        EmptyField[High(EmptyField), J] := stImpossible;
    CreateNewField := EmptyField;
end;
end.
