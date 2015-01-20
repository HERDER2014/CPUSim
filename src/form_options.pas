unit form_options;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TOptionsFrm }

  TOptionsFrm = class(TForm)
    OptionsFrm_ApplyBtn: TButton;
    OptionsFrm_RAMSizeEdt: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure OptionsFrm_ApplyBtnClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  OptionsFrm: TOptionsFrm;
  rsize: Cardinal;

implementation

{$R *.lfm}

{ TOptionsFrm }

procedure TOptionsFrm.OptionsFrm_ApplyBtnClick(Sender: TObject);
begin
  rsize:=StrToInt(OptionsFrm_RAMSizeEdt.Text);
  Close;
end;

procedure TOptionsFrm.FormCreate(Sender: TObject);
begin

end;

end.

