unit CLassicBluetoothPas;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Memo.Types,
  FMX.StdCtrls, FMX.ListBox, FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo, System.Bluetooth,
  System.Bluetooth.Components;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    BtnDecouverte: TButton;
    ComboBox1: TComboBox;
    AniIndicator1: TAniIndicator;
    BtnAppareilsAssocies: TButton;
    BtnAppairage: TButton;
    BtnDissocier: TButton;
    procedure FormShow(Sender: TObject);
    procedure BtnDecouverteClick(Sender: TObject);
    procedure BtnAppareilsAssociesClick(Sender: TObject);
    procedure BtnAppairageClick(Sender: TObject);
    procedure BtnDissocierClick(Sender: TObject);
  private
    { Déclarations privées }
    FBluetoothManager : TBluetoothManager;
    FBluetoothDevicesList : TBluetoothDeviceList;
    FAppareilsAssocies : TBluetoothDeviceList;
    FAdapter : TBluetoothAdapter;
    Procedure FinDecouverteAppareils (Const Sender : TObject; Const Adevices : TBluetoothDeviceList);
  public
    { Déclarations publiques }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}
procedure TForm1.BtnAppairageClick(Sender: TObject);
begin
  try
  if FBluetoothManager.ConnectionState=TBluetoothConnectionState.Connected then
  begin
    if ComboBox1.ItemIndex>=0 then
    begin
      FAdapter.Pair(FBluetoothDevicesList[ComboBox1.ItemIndex]);
      Memo1.Lines.Add('Votre appareil est appairé');
    end else
    begin
      Memo1.Lines.Add('Vous n''avez selectionné aucun appareil');
    end;
  end else
  begin
     Memo1.Lines.Add('Votre Bluetooth n''est pas activé');
  end;
  Except
   On E : Exception  do
   begin
     Memo1.Lines.Add('L''apparairage a échoué');
   end;
  end;
end;

procedure TForm1.BtnAppareilsAssociesClick(Sender: TObject);
Var I: Integer;
begin
  ComboBox1.Clear;
  AniIndicator1.Visible:=True;
  AniIndicator1.Enabled:=True;
  if FBluetoothManager.ConnectionState=TBluetoothConnectionState.Connected then
  begin
    FAppareilsAssocies:=FBluetoothManager.GetPairedDevices;
    if FAppareilsAssocies.Count<=0 then
    begin
      Memo1.Lines.Add('Il n''y a pas d''appareils associés à votre périphérique');
    end else
    begin
      for I := 0 to FAppareilsAssocies.Count-1 do
      begin
        ComboBox1.Items.Add(FAppareilsAssocies[I].DeviceName)
      end;
    end;
  end else
  begin
    Memo1.Lines.Add('Votre Bluetooth n''est pas activé');
  end;
  ComboBox1.ItemIndex:=0;
  AniIndicator1.Visible:=False;
  AniIndicator1.Enabled:=False;
end;

procedure TForm1.BtnDecouverteClick(Sender: TObject);
begin
  ComboBox1.Clear;
  AniIndicator1.Visible:=True;
  AniIndicator1.Enabled:=True;

  if FBluetoothManager.ConnectionState=TBluetoothConnectionState.Connected then
  begin
    FBluetoothManager.StartDiscovery(10000);
  end else
  begin
    Memo1.Lines.Add('Votre Bluetooth n''est pas activé');
  end;
end;

procedure TForm1.BtnDissocierClick(Sender: TObject);
begin
  try
  if FBluetoothManager.ConnectionState=TBluetoothConnectionState.Connected then
  begin
    if ComboBox1.ItemIndex>=0 then
    begin
      FAdapter.Unpair(FAppareilsAssocies[ComboBox1.ItemIndex]);
      Memo1.Lines.Add('Votre appareil est dissocié');
    end else
    begin
      Memo1.Lines.Add('Vous n''avez selectionné aucun appareil');
    end;
  end else
  begin
     Memo1.Lines.Add('Votre Bluetooth n''est pas activé');
  end;
  Except
   On E : Exception  do
   begin
     Memo1.Lines.Add('La dissociation a échoué');
   end;
  end;
end;

Procedure Tform1.FinDecouverteAppareils (Const Sender : TObject; Const Adevices : TBluetoothDeviceList);
begin
TThread.Synchronize(nil, procedure
  Var I : Integer ;
  begin
    AniIndicator1.Visible:=False;
    AniIndicator1.Enabled:=False;
    FBluetoothDevicesList:=ADevices;

    if FBluetoothDevicesList.Count>0 then
    begin
      Memo1.Lines.Add('Nbre d''appareils trouvés : ' + IntToStr(FBluetoothDevicesList.Count));
      for I := 0 to FBluetoothDevicesList.Count-1 do
      begin
        ComboBox1.Items.Add(FBluetoothDevicesList.Items[I].DeviceName);
      end;
      ComboBox1.ItemIndex:=0;
    end else
    begin
      Memo1.Lines.Add('Nbre d''appareils trouvés : 0');
    end;
  end);
end;

procedure TForm1.FormShow(Sender: TObject);
begin
   FBluetoothManager:=TBluetoothManager.Current;
   FBluetoothManager.OnDiscoveryEnd:=FinDecouverteAppareils;
   FAdapter:=FBluetoothManager.CurrentAdapter;
end;

end.
