unit form_main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls, uCPU, uRAM, uTypen;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    simulator : CPU;
    ram : TRAM;
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  ram := TRAM.Create(0);
  simulator := CPU.Create(ram);

  Label1.Caption := 'AX : ' + IntToStr(simulator.ReadRegister(Integer(RegisterIndex.AX)));
  Label2.Caption := 'BX : ' + IntToStr(simulator.ReadRegister(Integer(RegisterIndex.BX)));
  Label3.Caption := 'CX : ' + IntToStr(simulator.ReadRegister(Integer(RegisterIndex.CX)));
  Label4.Caption := 'DX : ' + IntToStr(simulator.ReadRegister(Integer(RegisterIndex.DX)));

  Label5.Caption := 'IP : ' + IntToStr(simulator.ReadRegister(Integer(RegisterIndex.IP)));
  Label6.Caption := 'SP : ' + IntToStr(simulator.ReadRegister(Integer(RegisterIndex.SP)));
  Label7.Caption := 'BP : ' + IntToStr(simulator.ReadRegister(Integer(RegisterIndex.BP)));
  Label8.Caption := 'FLAGS : ' + IntToStr(simulator.ReadRegister(Integer(RegisterIndex.FLAGS)));
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  simulator.Step();

  Label1.Caption := 'AX : ' + IntToStr(simulator.ReadRegister(Integer(RegisterIndex.AX)));
  Label2.Caption := 'BX : ' + IntToStr(simulator.ReadRegister(Integer(RegisterIndex.BX)));
  Label3.Caption := 'CX : ' + IntToStr(simulator.ReadRegister(Integer(RegisterIndex.CX)));
  Label4.Caption := 'DX : ' + IntToStr(simulator.ReadRegister(Integer(RegisterIndex.DX)));

  Label5.Caption := 'IP : ' + IntToStr(simulator.ReadRegister(Integer(RegisterIndex.IP)));
  Label6.Caption := 'SP : ' + IntToStr(simulator.ReadRegister(Integer(RegisterIndex.SP)));
  Label7.Caption := 'BP : ' + IntToStr(simulator.ReadRegister(Integer(RegisterIndex.BP)));
  Label8.Caption := 'FLAGS : ' + IntToStr(simulator.ReadRegister(Integer(RegisterIndex.FLAGS)));
end;

end.

