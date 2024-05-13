Unit ConstructorUnit;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.StdCtrls, Vcl.ExtCtrls, FieldGeneratorUnit;

Type
  TConstructorForm = Class(TForm)
    MainMenu: TMainMenu;
    FileMenuItem: TMenuItem;
    ManualMenuItem: TMenuItem;
    AboutDeveloperMenuItem: TMenuItem;
    LoadTemplateMenuItem: TMenuItem;
    SaveTemplateMenuItem: TMenuItem;
    BackLabel: TLabel;
    StartLabel: TLabel;
    UserFieldImage: TImage;
    LongShip: TImage;
    MiddleShip: TImage;
    SmallShip: TImage;
    ShortShip: TImage;
    PopupMenu: TPopupMenu;
    DeleteShipButton: TMenuItem;
    TurnButton: TMenuItem;
    GenerateFieldButton: TLabel;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    SettingsMenuItem: TMenuItem;
    Procedure LabelMouseEnter(Sender: TObject);
    Procedure LabelMouseLeave(Sender: TObject);
    Procedure BackLabelClick(Sender: TObject);
    Procedure FormShow(Sender: TObject);
    Procedure UserFieldImageDragOver(Sender, Source: TObject; X, Y: Integer;
        State: TDragState; var Accept: Boolean);
    Procedure UserFieldImageDragDrop(Sender, Source: TObject; X, Y: Integer);
    Procedure UserFieldImageMouseDown(Sender: TObject; Button: TMouseButton;
        Shift: TShiftState; X, Y: Integer);
    Procedure UserFieldImageMouseMove(Sender: TObject; Shift: TShiftState; X,
        Y: Integer);
    Procedure UserFieldImageMouseUp(Sender: TObject; Button: TMouseButton;
        Shift: TShiftState; X, Y: Integer);
    Procedure ShipStartDrag(Sender: TObject; var DragObject: TDragObject);
    Procedure DeleteShipButtonClick(Sender: TObject);
    Procedure TurnButtonClick(Sender: TObject);
    Procedure GenerateFieldButtonClick(Sender: TObject);
    Procedure StartLabelClick(Sender: TObject);
    Procedure ManualMenuItemClick(Sender: TObject);
    Procedure AboutDeveloperMenuItemClick(Sender: TObject);
    Procedure LoadTemplateMenuItemClick(Sender: TObject);
    Procedure SaveTemplateMenuItemClick(Sender: TObject);
    Procedure CreateParams(Var Params: TCreateParams); Override;
    Procedure SettingsMenuItemClick(Sender: TObject);
  Private
    { Private declarations }
  Public
    { Public declarations }
  End;

Var
    ConstructorForm: TConstructorForm;
    Field: TField;

Implementation

Uses
    GridUnit, BattleUnit, ManualUnit, AboutDeveloperUnit, SettingsUnit;

Type
    TFieldRecord = Record
        Field: TField;
        ImpossibleCellsMatrix: TImpossibleCellsMatrix;
    End;
    TFieldFile = File Of TFieldRecord;

Const
    CELL_WIDTH = 30;
Var
    BufField, NewField: TField;
    ImpossibleCellsMatrix, BufMatrix: TImpossibleCellsMatrix;
    ShipsCountArr: TShipsCountArray;
    IsDrag, IsMovingShipHorizontal, IsShipPlaced: Boolean;

    MovingShipType: TShip;
    MovingShipCol, MovingShipRow: ShortInt;

{$R *.dfm}

Procedure TConstructorForm.CreateParams(Var Params: TCreateParams);
Begin
    Inherited;
    Params.ExStyle := Params.ExStyle Or WS_EX_APPWINDOW;
End;

Procedure TConstructorForm.AboutDeveloperMenuItemClick(Sender: TObject);
Begin
    AboutDeveloperForm.Position := PoDesktopCenter;
    AboutDeveloperForm.ShowModal;
End;

Procedure TConstructorForm.BackLabelClick(Sender: TObject);
Begin
    ConstructorForm.Close;
End;

Procedure TConstructorForm.LabelMouseEnter(Sender: TObject);
Begin
    With Sender As TLabel Do
    Begin
        Font.Color := ClBlack;
    End;
End;

Procedure TConstructorForm.LabelMouseLeave(Sender: TObject);
Begin
    With Sender As TLabel Do
    Begin
        Font.Color := ClGrayText;
    End;
End;

Procedure TConstructorForm.ManualMenuItemClick(Sender: TObject);
Begin
    ManualForm.Position := PoDesktopCenter;
    ManualForm.ShowModal;
End;

Procedure HideShipImage(Ship: TShip);
Begin
    With ConstructorForm Do
        Case Ship Of
            TShortShip:
                ShortShip.Visible := False;
            TSmallShip:
                SmallShip.Visible := False;
            TMiddleShip:
                MiddleShip.Visible := False;
            TLongShip:
                LongShip.Visible := False;
        End;
End;

Procedure ShowShipImage(Ship: TShip);
Begin
    With ConstructorForm Do
        Case Ship Of
            TShortShip:
                ShortShip.Visible := True;
            TSmallShip:
                SmallShip.Visible := True;
            TMiddleShip:
                MiddleShip.Visible := True;
            TLongShip:
                LongShip.Visible := True;
        End;
End;

Procedure DrawShips();
Begin
    With ConstructorForm Do
    Begin
        DrawShip(LongShip, 4, 1);
        LongShip.Visible := True;

        DrawShip(MiddleShip, 3, 1);
        MiddleShip.Visible := True;

        DrawShip(SmallShip, 2, 1);
        SmallShip.Visible := True;

        DrawShip(ShortShip, 1, 1);
        ShortShip.Visible := True;
    End;
End;

Procedure HideShips();
Begin
    With ConstructorForm Do
    Begin
        LongShip.Visible := False;
        MiddleShip.Visible := False;
        SmallShip.Visible := False;
        ShortShip.Visible := False;
    End;
End;

Procedure ClearShipsCountArr(var ShipsCountArr: TShipsCountArray);
Var
    I: TShip;
Begin
    For I := Low(ShipsCountArr) To High(ShipsCountArr) Do
        ShipsCountArr[I] := 0;
End;

Procedure TConstructorForm.FormShow(Sender: TObject);
Begin
    Field := CreateField();
    ImpossibleCellsMatrix := CreateImpossibleCellsMatrix();
    DrawShips();
    ShipsCountArr := IinializeShipsCountArray();
    IsShipPlaced := False;
    StartLabel.Enabled := False;
    DrawField(UserFieldImage, Field);
    SaveTemplateMenuItem.Enabled := False;
End;

Procedure TConstructorForm.GenerateFieldButtonClick(Sender: TObject);
Begin
    ImpossibleCellsMatrix := CreateImpossibleCellsMatrix();
    Field := GenerateField(ImpossibleCellsMatrix);
    HideShips();
    ClearShipsCountArr(ShipsCountArr);
    StartLabel.Enabled := True;
    SaveTemplateMenuItem.Enabled := True;
    DrawField(UserFieldImage, Field);
End;

Function ConvertImageToShipType(MovingShip: TImage): TShip;
Const
    TempArr: Array [1..4] Of TShip = (TShortShip, TSmallShip, TMiddleShip, TLongShip);
Var
    DeckCount: Byte;
Begin
    DeckCount := MovingShip.Width Div CELL_WIDTH;
    ConvertImageToShipType := TempArr[DeckCount];
End;

Procedure TConstructorForm.ShipStartDrag(Sender: TObject;
    Var DragObject: TDragObject);
Var
    MovingShip: TImage;
Begin
    MovingShip := TImage(Sender);
    IsMovingShipHorizontal := True;
    MovingShipType := ConvertImageToShipType(MovingShip);
End;

Procedure TConstructorForm.StartLabelClick(Sender: TObject);
Begin
    ConstructorForm.Hide;
    BattleForm.Position := PoDesktopCenter;
    BattleForm.ShowModal;
    ConstructorForm.Close;
End;

Procedure TConstructorForm.UserFieldImageDragOver(Sender, Source: TObject; X,
    Y: Integer; State: TDragState; Var Accept: Boolean);
Var
    Col, Row: ShortInt;
Begin
    Col := X Div CELL_WIDTH;
    Row := Y Div CELL_WIDTH;

    Accept := CanPlaceShipHere(Field, MovingShipType, Col, Row, IsMovingShipHorizontal); //установка допускается, только если корабль можно поместить в эту ячейку поля
    If Accept Then
    Begin
        BufField := Field;
        PlaceShipHere(BufField, MovingShipType, Col, Row, IsMovingShipHorizontal);
        DrawField(UserFieldImage, BufField);
    End;

    If State = dsDragLeave Then
        DrawField(UserFieldImage, Field);
End;

Procedure TConstructorForm.UserFieldImageDragDrop(Sender, Source: TObject; X,
    Y: Integer);
Var
    Col, Row: Byte;
Begin
    Col := X Div CELL_WIDTH;
    Row := Y Div CELL_WIDTH;

    Dec(ShipsCountArr[MovingShipType]);
    If ShipsCountArr[MovingShipType] = 0 Then
        HideShipImage(MovingShipType);

    Field := BufField;
    FillImpossibleCellsMatrix(ImpossibleCellsMatrix, MovingShipType, Col, Row, IsMovingShipHorizontal);
    DrawField(UserFieldImage, Field);

    if IsShipsCountArrayEmpty(ShipsCountArr) Then
    Begin
        StartLabel.Enabled := True;
        SaveTemplateMenuItem.Enabled := True;
    End;
End;

Procedure TConstructorForm.TurnButtonClick(Sender: TObject);
Var
   FirstSideCol, FirstSideRow, SecondSideCol, SecondSideRow, I: ShortInt;
   CanPlace: Boolean;
Begin
    BufField := Field;
    FindSideOfShip(BufField, MovingShipType, MovingShipCol, MovingShipRow, FirstSideCol, FirstSideRow, IsMovingShipHorizontal, -1);
    FindSideOfShip(BufField, MovingShipType, MovingShipCol, MovingShipRow, SecondSideCol, SecondSideRow, IsMovingShipHorizontal, 1);

    DeleteShip(BufField, ImpossibleCellsMatrix, FirstSideCol, FirstSideRow, SecondSideCol, SecondSideRow, IsMovingShipHorizontal);

    If CanPlaceShipHere(BufField, MovingShipType, MovingShipCol, MovingShipRow, Not IsMovingShipHorizontal) Then
    Begin
        PlaceShipHere(BufField, MovingShipType, MovingShipCol, MovingShipRow, Not IsMovingShipHorizontal);
        Field := BufField;
        FillImpossibleCellsMatrix(ImpossibleCellsMatrix, MovingShipType, MovingShipCol, MovingShipRow, Not IsMovingShipHorizontal);
    End
    Else
    Begin
        I := -1;
        Repeat
            Inc(I);
            CanPlace := CanPlaceShipInLine(BufField, MovingShipType, I, Not IsMovingShipHorizontal);
        Until CanPlace Or (I = High(Field));

        If CanPlace Then
        Begin
            PlaceShipInLine(BufField, ImpossibleCellsMatrix, MovingShipType, I, Not IsMovingShipHorizontal);
            Field := BufField;
        End;
    End;
    DrawField(UserFieldImage, Field);
End;

Procedure TConstructorForm.DeleteShipButtonClick(Sender: TObject);
Var
    FirstSideCol, FirstSideRow, SecondSideCol, SecondSideRow: ShortInt;
Begin
    FindSideOfShip(Field, MovingShipType, MovingShipCol, MovingShipRow, FirstSideCol, FirstSideRow, IsMovingShipHorizontal, -1);
    FindSideOfShip(Field, MovingShipType, MovingShipCol, MovingShipRow, SecondSideCol, SecondSideRow, IsMovingShipHorizontal, 1);

    DeleteShip(Field, ImpossibleCellsMatrix, FirstSideCol, FirstSideRow, SecondSideCol, SecondSideRow, IsMovingShipHorizontal);
    DrawField(UserFieldImage, Field);

    Inc(ShipsCountArr[MovingShipType]);
    If ShipsCountArr[MovingShipType] = 1 Then
    begin
        ShowShipImage(MovingShipType);
        StartLabel.Enabled := False;
        SaveTemplateMenuItem.Enabled := False;
    end;
End;

Procedure TConstructorForm.UserFieldImageMouseDown(Sender: TObject;
    Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
Var
    Col, Row, FirstSideCol, FirstSideRow, SecondSideCol, SecondSideRow: ShortInt;
    IsShip: Boolean;
Begin
    Col := X Div CELL_WIDTH;
    Row := Y Div CELL_WIDTH;

    IsShip := Ord(Field[Col, Row]) > 0;
    If IsShip Then
    Begin
        MovingShipType := ConvertFieldStateToShip(Field[Col, Row]);
        IsMovingShipHorizontal := IsShipInFieldHorizontal(Field, MovingShipType, Col, Row);

        Case Button Of
            mbLeft:
            Begin
                IsDrag := True;

                BufField := Field;
                BufMatrix := ImpossibleCellsMatrix;

                FindSideOfShip(BufField, MovingShipType, Col, Row, FirstSideCol, FirstSideRow, IsMovingShipHorizontal, -1);
                FindSideOfShip(BufField, MovingShipType, Col, Row, SecondSideCol, SecondSideRow, IsMovingShipHorizontal, 1);

                DeleteShip(BufField, BufMatrix, FirstSideCol, FirstSideRow, SecondSideCol, SecondSideRow, IsMovingShipHorizontal);
            End;
            mbRight:
            Begin
                MovingShipCol := Col;
                MovingShipRow := Row;

                X := X + Left + UserFieldImage.Left + 15;
                Y :=  Y + Top + UserFieldImage.Top + 30;
                PopupMenu.Popup(X, Y);
            End;
            mbMiddle: ;
        End;
    End;
End;

Procedure TConstructorForm.UserFieldImageMouseMove(Sender: TObject;
    Shift: TShiftState; X, Y: Integer);
Var
    Col, Row: ShortInt;
    CanPlaceShip, IsCursorOnField: Boolean;
Begin
    If IsDrag Then
    Begin
        Col := X Div CELL_WIDTH;
        Row := Y Div CELL_WIDTH;

        IsCursorOnField := (Col > -1) And (Col < 10) And (Row > -1) And (Row < 10);
        If IsCursorOnField Then
        Begin
            NewField := BufField;

            CanPlaceShip := CanPlaceShipHere(NewField, MovingShipType, Col, Row, IsMovingShipHorizontal);
            If CanPlaceShip Then
            Begin
                PlaceShipHere(NewField, MovingShipType, Col, Row, IsMovingShipHorizontal);
                DrawField(UserFieldImage, NewField);

                MovingShipCol := Col;
                MovingShipRow := Row;

                Field := NewField;
                IsShipPlaced := True;
            End;
        End;
    End;
End;

Procedure TConstructorForm.UserFieldImageMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
Begin
    If IsDrag And IsShipPlaced Then
    Begin
        FillImpossibleCellsMatrix(BufMatrix, MovingShipType, MovingShipCol, MovingShipRow, IsMovingShipHorizontal);
        ImpossibleCellsMatrix := BufMatrix;
    End;
    IsShipPlaced := False;
    IsDrag := False;
    DrawField(UserFieldImage, Field);
End;

Function IsSaveFilesPathCorrect(var SaveFile: TFieldFile): Boolean;
Var
    IsFileCorrect: Boolean;
    Path: String;
Begin
    With ConstructorForm Do
    Begin
        IsFileCorrect := True;

        Path := SaveDialog.FileName;
        AssignFile(SaveFile, Path);

        If FileExists(Path) And (MessageBox(Handle, 'Вы действетельно хотите перезаписать файл?', 'Вы уверены?', MB_YESNO Or MB_ICONQUESTION) = IDNO) Then
            IsFileCorrect := False;

        If IsFileCorrect Then
            Try
                Rewrite(SaveFile);
            Except
                IsFileCorrect := False;
                MessageBox(Handle, 'Не удалось открыть файл!', 'Ошибка', MB_OK Or MB_ICONERROR);
            End;

        If IsFileCorrect Then
            CloseFile(SaveFile);
    End;

    IsSaveFilesPathCorrect := IsFileCorrect;
End;

Procedure TConstructorForm.SaveTemplateMenuItemClick(Sender: TObject);
Var
    SaveFile: TFieldFile;
    NewFieldRecord: TFieldRecord;
Begin
    If SaveDialog.Execute And IsSaveFilesPathCorrect(SaveFile) Then
    Begin
        NewFieldRecord.Field := Field;
        NewFieldRecord.ImpossibleCellsMatrix := ImpossibleCellsMatrix;

        Rewrite(SaveFile);
        Write(SaveFile, NewFieldRecord);
        CloseFile(SaveFile);
    End;
End;

Procedure TConstructorForm.SettingsMenuItemClick(Sender: TObject);
Begin
    SettingsForm.ShowModal;
    DrawField(UserFieldImage, Field);
End;

Function IsFileInPathCorrect(Var FieldFile: TFieldFile): Boolean;
Var
    IsFileCorrect: Boolean;
    Path: String;
    TempRecord: TFieldRecord;
Begin
    With ConstructorForm Do
    Begin
        IsFileCorrect := True;
        Path := OpenDialog.FileName;
        AssignFile(FieldFile, Path);
        Try
            Reset(FieldFile);
        Except
            IsFileCorrect := False;
            MessageBox(ConstructorForm.Handle, 'Не удалось открыть файл!', 'Ошибка', MB_OK Or MB_ICONERROR);
        End;

        If IsFileCorrect Then
            Try
                Read(FieldFile, TempRecord);
            Except
                IsFileCorrect := False;
                MessageBox(ConstructorForm.Handle, 'Файл игрового поля порежден!', 'Ошибка', MB_OK Or MB_ICONERROR);
            End;

        If IsFileCorrect Then
            CloseFile(FieldFile);
    End;

    IsFileInPathCorrect := IsFileCorrect;
End;

Procedure TConstructorForm.LoadTemplateMenuItemClick(Sender: TObject);
Var
    LoadedFieldRecord: TFieldRecord;
    FieldFile: TFieldFile;
Begin
    If OpenDialog.Execute And IsFileInPathCorrect(FieldFile) Then
    Begin
        Reset(FieldFile);
        Read(FieldFile, LoadedFieldRecord);
        CloseFile(FieldFile);

        Field := LoadedFieldRecord.Field;
        ImpossibleCellsMatrix := LoadedFieldRecord.ImpossibleCellsMatrix;

        HideShips();
        ClearShipsCountArr(ShipsCountArr);
        StartLabel.Enabled := True;
        DrawField(UserFieldImage, Field);
        SaveTemplateMenuItem.Enabled := True;
    End;
End;
End.
