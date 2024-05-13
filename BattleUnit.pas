Unit BattleUnit;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Menus, Vcl.ExtCtrls, BattleDescribeUnit;

Type
  TBattleForm = Class(TForm)
    ExitLabel: TLabel;
    MainMenu: TMainMenu;
    ManualMenuItem: TMenuItem;
    AboutDeveloperMenuItem: TMenuItem;
    UserFieldImage: TImage;
    BotFieldImage: TImage;
    PointerLabel: TLabel;
    YourFieldLabel: TLabel;
    BotFieldLabel: TLabel;
    BotTimer: TTimer;
    WinnerInfoLabel: TLabel;
    PlaneImage: TImage;
    ActiveTimer: TTimer;
    InformationLabel: TLabel;
    SettingsMenuItem: TMenuItem;
    Procedure ExitLabelMouseEnter(Sender: TObject);
    Procedure ExitLabelMouseLeave(Sender: TObject);
    Procedure ExitLabelClick(Sender: TObject);
    Procedure FormShow(Sender: TObject);
    Procedure BotFieldImageMouseDown(Sender: TObject; Button: TMouseButton;
        Shift: TShiftState; X, Y: Integer);
    Procedure BotFieldImageMouseUp(Sender: TObject; Button: TMouseButton;
        Shift: TShiftState; X, Y: Integer);
    Procedure BotTimerTimer(Sender: TObject);
    Procedure PlaneImageClick(Sender: TObject);
    Procedure ActiveTimerTimer(Sender: TObject);
    Procedure ManualMenuItemClick(Sender: TObject);
    Procedure AboutDeveloperMenuItemClick(Sender: TObject);
    Procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    Procedure CreateParams(Var Params: TCreateParams); Override;
    Procedure SettingsMenuItemClick(Sender: TObject);
    Procedure BotFieldImageMouseMove(Sender: TObject; Shift: TShiftState; X,
        Y: Integer);
    Procedure BotFieldImageMouseLeave(Sender: TObject);
    Procedure FormClose(Sender: TObject; Var Action: TCloseAction);
  Private
    { Private declarations }
  Public
    { Public declarations }
  End;

Var
    BattleForm: TBattleForm;

Implementation
Uses
    GridUnit, FieldGeneratorUnit, ConstructorUnit, ListUnit, AboutDeveloperUnit, ManualUnit, MMSystem, SettingsUnit;

Const
    CELL_WIDTH = 30;

Var
    UserField, DisplayedUserField, BotField, DisplayedBotField: TField;
    ImpossibleCellsMatrix: TImpossibleCellsMatrix;
    WasCorrectShoot, WasHit, IsUserPlaneActive: Boolean;
    BotShipsCountArray: TShipsCountArray;

{$R *.dfm}

Procedure TBattleForm.CreateParams(Var Params: TCreateParams);
Begin
    Inherited;
    Params.ExStyle := Params.ExStyle Or WS_EX_APPWINDOW;
End;

Procedure ShootBotField (Col, Row: ShortInt);
Var
    Ship: TShip;
    IsHorizontal: Boolean;
Begin
    Case BotField[Col, Row] Of
        StImpossible, StFree :
        Begin
            DisplayedBotField[Col, Row] := StImpossible;
            WasHit := False;
        End
    Else
        DisplayedBotField[Col, Row] := BotField[Col, Row];
        WasHit := True;
        ChangeFieldAroundShootPlace(BotField, DisplayedBotField, Col, Row);
        Ship := ConvertFieldStateToShip (BotField[Col, Row]);
        IsHorizontal := IsShipInFieldHorizontal(BotField, Ship, Col, Row);

        If IsShipDestroyed(DisplayedBotField, Ship, Col, Row, IsHorizontal) Then
        Begin
            ChangeFieldForDestroyedShip(BotField, DisplayedBotField, Ship, Col, Row, IsHorizontal);
            Dec(BotShipsCountArray[Ship]);
            If IsShipsCountArrayEmpty(BotShipsCountArray) then
            Begin
                If IsSoundAcces Then
                    PlaySound('Sounds\EndBattleWin.wav', 0, SND_ASYNC);
                BattleForm.WinnerInfoLabel.Caption := 'Это победа!!!';
                BattleForm.WinnerInfoLabel.Visible := True;
                BattleForm.BotFieldImage.Enabled := False;
            End;
        End;
    End;
End;

Procedure TBattleForm.AboutDeveloperMenuItemClick(Sender: TObject);
Begin
    AboutDeveloperForm.ShowModal;
End;

Procedure TBattleForm.ActiveTimerTimer(Sender: TObject);
Begin
    If PlaneImage.Visible = True Then
        PlaneImage.Visible := False
    Else
        PlaneImage.Visible := True;
End;

Procedure TBattleForm.BotFieldImageMouseDown(Sender: TObject;
    Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
Var
    Col, Row: ShortInt;
    I, J: ShortInt;
Begin
    Col := X Div CELL_WIDTH;
    Row := Y Div CELL_WIDTH;

    If IsBotPlaneActive or IsUserPlaneActive Then
        InformationLabel.Visible := False;

    If DisplayedBotField[Col, Row] = StFree Then
    Begin
        If IsUserPlaneActive Then
        Begin
            If IsSoundAcces Then
                PlaySound('Sounds\BigBoom.wav', 0, SND_ASYNC);
            For I := Col-1 To Col+1 Do
                For J := Row-1 To Row+1 Do
                    ShootBotField (I, J);

            DrawField(BotFieldImage, DisplayedBotField);
            IsUserPlaneActive := False;
            ActiveTimer.Enabled := False;
            PlaneImage.Visible := False;
            WasHit := False;
        End
        Else
        Begin
            If IsSoundAcces Then
                Case BotField[Col, Row] Of
                    StImpossible, stFree: PlaySound(PWideChar(SettingsUnit.Sound), 0, SND_ASYNC);
                Else
                    PlaySound('Sounds\Shoot4.wav', 0, SND_ASYNC);
                end;

            ShootBotField (Col, Row);
            DrawField(BotFieldImage, DisplayedBotField);
        End;
        WasCorrectShoot := True;
    End;
End;

Procedure TBattleForm.BotFieldImageMouseLeave(Sender: TObject);
Begin
    DrawField(BotFieldImage, DisplayedBotField);
End;

Procedure TBattleForm.BotFieldImageMouseMove(Sender: TObject;
    Shift: TShiftState; X, Y: Integer);
Var
    BufField: TField;
    Col, Row, I, J: ShortInt;
Begin
    If IsUserPlaneActive Then
    Begin
        Col := X Div CELL_WIDTH;
        Row := Y Div CELL_WIDTH;
        BufField := DisplayedBotField;

        For I := -1 To 1 Do
            For J := -1 To 1 Do
                BufField[Col + J, Row + I] := StDamaged;

        DrawField(BotFieldImage, BufField);
    End;
End;

Procedure TBattleForm.BotTimerTimer(Sender: TObject);
Begin
    MakeShoot(DisplayedUserField, WasHit);
    DrawField(UserFieldImage, DisplayedUserField);
    If Not WasHit Then
    Begin
        if IsSoundAcces then
            PlaySound(PWideChar(SettingsUnit.Sound), 0, SND_ASYNC);
        BotTimer.Enabled := False;
        BotFieldImage.Enabled := True;
        PointerLabel.Caption := '>>';
    End
    Else
        if IsSoundAcces then
            PlaySound('Sounds\Shoot4.wav', 0, SND_ASYNC);
    If IsBotPlaneActive Then
    Begin
        if IsSoundAcces then
            PlaySound('Sounds\BigBoom.wav', 0, SND_ASYNC);
        InformationLabel.Caption := 'Авиаудар!!!';
        InformationLabel.Visible := True;
    End;
    If IsShipsCountArrayEmpty(UserShipsCountArray) Then
    Begin
        if IsSoundAcces then
            PlaySound('Sounds\EndBattleLose.wav', 0, SND_ASYNC);
        WinnerInfoLabel.Caption := 'Поражение... :(';
        WinnerInfoLabel.Visible := True;
        BotFieldImage.Enabled := False;
        BotTimer.Enabled := False;
    End;
End;

Procedure TBattleForm.BotFieldImageMouseUp(Sender: TObject;
    Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
Begin
    If WasCorrectShoot And Not WasHit Then
    Begin
        BotFieldImage.Enabled := False;
        BotTimer.Enabled := True;
        PointerLabel.Caption := '<<';
        WasCorrectShoot := False;
    End;
End;

Procedure TBattleForm.ExitLabelClick(Sender: TObject);
Begin
    BattleForm.Close;
End;

Procedure TBattleForm.ExitLabelMouseEnter(Sender: TObject);
Begin
    With Sender As TLabel Do
    Begin
        Font.Color := ClBlack;
    End;
End;

Procedure TBattleForm.ExitLabelMouseLeave(Sender: TObject);
Begin
    With Sender As TLabel Do
    Begin
        Font.Color := ClGrayText;
    End;
End;

Function CreateOnlyShipsField(Field: TField): TField;
Var
    I, J: ShortInt;
    OnlyShipsField: TField;
Begin
    For I := Low(Field) To High(Field) Do
        For J := Low(Field) To High(Field) Do
        Begin
            If Field[J, I] = StImpossible then
                OnlyShipsField[J, I] := StFree
            Else
                OnlyShipsField[J, I] := Field[J, I];
        End;
    CreateOnlyShipsField := OnlyShipsField;
End;

Procedure TBattleForm.FormClose(Sender: TObject; Var Action: TCloseAction);
Begin
    PlaySound(nil, 0, SND_PURGE);
End;

Procedure TBattleForm.FormCloseQuery(Sender: TObject; Var CanClose: Boolean);
Begin
     CanClose := MessageBox(Handle, 'Вы действительно хотите выйти в главное меню?', 'Вы уверены?', MB_YESNO Or MB_ICONQUESTION) = IDYES;
End;

Procedure TBattleForm.FormShow(Sender: TObject);
Begin
    if IsSoundAcces then
        PlaySound('Sounds\StartBattle.wav', 0, SND_ASYNC);
    UserField := ConstructorUnit.Field;
    ImpossibleCellsMatrix := CreateImpossibleCellsMatrix();
    BotField := GenerateField(ImpossibleCellsMatrix);
    DisplayedBotField := CreateField();
    DisplayedUserField := CreateOnlyShipsField(UserField);
    BotShipsCountArray := IinializeShipsCountArray();
    InitializeBot(UserField);
    IsUserPlaneActive := False;
    ActiveTimer.Enabled := False;
    InformationLabel.Visible := False;

    WinnerInfoLabel.Visible := False;
    BotFieldImage.Enabled := True;
    PlaneImage.Visible := True;

    DrawField(UserFieldImage, DisplayedUserField);
    DrawField(BotFieldImage, DisplayedBotField);
End;

Procedure TBattleForm.ManualMenuItemClick(Sender: TObject);
Begin
    ManualForm.ShowModal;
End;

Procedure TBattleForm.PlaneImageClick(Sender: TObject);
Begin
    IsUserPlaneActive := Not IsUserPlaneActive;
    ActiveTimer.Enabled := Not ActiveTimer.Enabled;
    InformationLabel.Caption := 'Приготовьтесь к авиаудару...';
    InformationLabel.Visible := Not InformationLabel.Visible;
End;

Procedure TBattleForm.SettingsMenuItemClick(Sender: TObject);
Begin
    SettingsForm.Position := PoDesktopCenter;
    SettingsForm.ShowModal;
    DrawField(UserFieldImage, DisplayedUserField);
    DrawField(BotFieldImage, DisplayedBotField);
End;

End.
