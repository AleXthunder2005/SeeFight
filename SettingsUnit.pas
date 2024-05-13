Unit SettingsUnit;

Interface

Uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls;

Type
    ApperanceRecord = Record
        BackgroundColor: TColor;
        ShipColor: TColor;
        FreeCellColor: TColor;
        ImpossibleShipColor: TColor;
        DamagedShipColor: TColor;
    End;

  TSettingsForm = Class(TForm)
    SoundsLabel: TLabel;
    ApperanceLabel: TLabel;
    ApperanceRadioGroup: TRadioGroup;
    BackLabel: TLabel;
    SettingsLabel: TLabel;
    SoundsRadioGroup: TRadioGroup;
    CheckBox: TCheckBox;
    Procedure BackLabelMouseEnter(Sender: TObject);
    Procedure BackLabelMouseLeave(Sender: TObject);
    Procedure BackLabelClick(Sender: TObject);
    Procedure FormClose(Sender: TObject; var Action: TCloseAction);
    Procedure FormCreate(Sender: TObject);
    Procedure ApperanceRadioGroupClick(Sender: TObject);
    Procedure CheckBoxClick(Sender: TObject);
  Private
    { Private declarations }
  Public
    { Public declarations }
  End;

Var
  SettingsForm: TSettingsForm;
  Apperance: ApperanceRecord;
  Sound: String;
  IsSoundAcces: Boolean;

Implementation
Uses
    StartUnit, ConstructorUnit, BattleUnit, ManualUnit, AboutDeveloperUnit, MMSystem;
Const
    ClCoffeBrown = $002F57A1;
    ClCoffeLightBrown = $004A86B1;
    ClCoffeBeige = $00374E6F;
    ClCoffeGrey = $00717D93;
    ClCoffeLightGrey = $00C5F3FF;

    ClSeaDark = $00474116;
    ClSea = $00938341;
    ClSeaLight = $00A2B588;
    ClSeaBlueLight = $00F2D9B1;
    ClSeaLightGrey = $00CEDDDC;

    ClFlowerDark = $00592C56;
    ClFlower = $008C4092;
    ClFlowerLight = $00BC80A9;
    ClFlowerGreyLight = $00F6D0E3;
    ClFlowerGrey = $007B6D9E;

    LightApperance: ApperanceRecord = (
                                        BackgroundColor : ClBtnFace;
                                        ShipColor : ClHighlight;
                                        FreeCellColor : ClWhite;
                                        ImpossibleShipColor : ClMedGray;
                                        DamagedShipColor : ClMaroon;
                                      );
    CoffeApperance: ApperanceRecord = (
                                        BackgroundColor : ClCoffeLightGrey ;
                                        ShipColor : ClCoffeBrown;
                                        FreeCellColor : ClBtnFace;
                                        ImpossibleShipColor : ClCoffeGrey;
                                        DamagedShipColor : ClCoffeBeige;
                                      );
    SeaApperance: ApperanceRecord = (
                                        BackgroundColor : ClSeaBlueLight;
                                        ShipColor : ClSeaDark;
                                        FreeCellColor : ClBtnFace;
                                        ImpossibleShipColor : ClSeaLight;
                                        DamagedShipColor : ClSea;
                                    );
    FlowerApperance: ApperanceRecord = (
                                        BackgroundColor : ClFlowerGreyLight;
                                        ShipColor : ClFlowerDark;
                                        FreeCellColor : ClBtnFace;
                                        ImpossibleShipColor : ClFlowerGrey ;
                                        DamagedShipColor : ClFlowerLight ;
                                    );
{$R *.dfm}

Procedure TSettingsForm.ApperanceRadioGroupClick(Sender: TObject);
Begin
    Case ApperanceRadioGroup.ItemIndex Of
        0: Apperance := LightApperance;
        1: Apperance := CoffeApperance;
        2: Apperance := SeaApperance;
        3: Apperance := FlowerApperance;
    End;
    Color := Apperance.BackgroundColor;
End;

Procedure TSettingsForm.BackLabelClick(Sender: TObject);
Begin
    SettingsForm.Close;
End;

Procedure TSettingsForm.BackLabelMouseEnter(Sender: TObject);
Begin
    With Sender As TLabel Do
    Begin
        Font.Color := ClBlack;
    End;
End;

Procedure TSettingsForm.BackLabelMouseLeave(Sender: TObject);
Begin
    With Sender As TLabel Do
    Begin
        Font.Color := ClGrayText;
    End;
End;

Procedure TSettingsForm.CheckBoxClick(Sender: TObject);
Begin
    IsSoundAcces := CheckBox.Checked;
End;

Procedure TSettingsForm.FormClose(Sender: TObject; Var Action: TCloseAction);
Begin
    Case SoundsRadioGroup.ItemIndex Of
        0: Sound := 'Sounds\Click.wav';
        1: Sound := 'Sounds\Clave.wav';
        2: Sound := 'Sounds\Kick.wav';
        3: Sound := 'Sounds\Snap.wav';
        4: Sound := 'Sounds\Perc.wav';
    End;

    StartForm.Color := Apperance.BackgroundColor;
    ConstructorForm.Color := Apperance.BackgroundColor;
    BattleForm.Color := Apperance.BackgroundColor;
    ManualForm.Color := Apperance.BackgroundColor;
    AboutDeveloperForm.Color := Apperance.BackgroundColor;

    If Not IsSoundAcces Then
        PlaySound(0, 0, SND_PURGE);
End;

Procedure TSettingsForm.FormCreate(Sender: TObject);
Begin
    Apperance := LightApperance;
    Sound := 'Sounds\Click.wav';
    IsSoundAcces := True;
End;
End.
