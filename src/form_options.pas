unit form_options;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Spin;

type

  { TOptionsFrm }

  TOptionsFrm = class(TForm)
    //OptionsFrm_Step_VelEt: TEdit;
    Label1: TLabel;
    //OptionsFrm_Step_Vel: TLabel;
    OptionsFrm_ApplyBtn: TButton;
    OptionsFrm_RAMSizeEdt: TSpinEdit;
    procedure FormCreate(Sender: TObject);
    procedure OptionsFrm_ApplyBtnClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    ramsize: Cardinal;
  end;

var
  OptionsFrm: TOptionsFrm;

implementation

{$R *.lfm}

{ TOptionsFrm }

procedure TOptionsFrm.OptionsFrm_ApplyBtnClick(Sender: TObject);
begin
  ramsize:=StrToInt(OptionsFrm_RAMSizeEdt.Text);
  Close;
end;

procedure TOptionsFrm.FormCreate(Sender: TObject);
begin
end;

end.

