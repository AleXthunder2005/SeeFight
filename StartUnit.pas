Unit StartUnit;

Interface

Uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.pngimage, Vcl.ExtCtrls, Vcl.StdCtrls;

Type
  TStartForm = Class(TForm)
    BackgroundImage: TImage;
    StartLabel: TLabel;
    SettingsLabel: TLabel;
    AboutDeveloperLabel: TLabel;
    ManualLabel: TLabel;
    ExitLabel: TLabel;
    Procedure LabelMouseLeave(Sender: TObject);
    Procedure LabelMouseEnter(Sender: TObject);
    Procedure ExitLabelClick(Sender: TObject);
    Procedure StartLabelClick(Sender: TObject);
    Procedure SettingsLabelClick(Sender: TObject);
    Procedure ManualLabelClick(Sender: TObject);
    Procedure AboutDeveloperLabelClick(Sender: TObject);
    Procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    Procedure FormShow(Sender: TObject);
  Private
    { Private declarations }
  Public
    { Public declarations }
  End;

Var
  StartForm: TStartForm;

Implementation
Uses
    SettingsUnit, BattleUnit, ConstructorUnit, ManualUnit, AboutDeveloperUnit, MMSystem;
{$R *.dfm}

Procedure TStartForm.AboutDeveloperLabelClick(Sender: TObject);
Begin
    AboutDeveloperForm.Position := PoDesktopCenter;
    AboutDeveloperForm.ShowModal;
End;

Procedure TStartForm.ExitLabelClick(Sender: TObject);
Begin
    StartForm.Close;
End;

Procedure TStartForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
Begin
    CanClose := MessageBox(Handle, 'Вы действительно хотите выйти?', 'Вы уверены?', MB_YESNO Or MB_ICONQUESTION) = IDYES;
End;

Procedure TStartForm.FormShow(Sender: TObject);
Begin
    If IsSoundAcces Then
        PlaySound('Sounds\MainTheme2.wav', 0, SND_ASYNC or SND_LOOP);
End;

Procedure TStartForm.LabelMouseEnter(Sender: TObject);
Begin
    With Sender As TLabel Do
    Begin
        Font.Color := ClBlack;
    End;
End;

Procedure TStartForm.LabelMouseLeave(Sender: TObject);
Begin
    With Sender As TLabel Do
    Begin
        Font.Color := ClGrayText;
    End;
End;

Procedure TStartForm.ManualLabelClick(Sender: TObject);
Begin
    ManualForm.Position := PoDesktopCenter;
    ManualForm.ShowModal;
End;

Procedure TStartForm.SettingsLabelClick(Sender: TObject);
Begin
    SettingsForm.Position := PoDesktopCenter;
    SettingsForm.ShowModal;
End;

Procedure TStartForm.StartLabelClick(Sender: TObject);
Begin
    StartForm.Hide;
    ConstructorForm.Position := PoDesktopCenter;
    ConstructorForm.ShowModal;
    StartForm.Show;
    Position := PoDesktopCenter;
End;

End.
