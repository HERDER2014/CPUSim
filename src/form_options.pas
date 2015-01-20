unit form_options;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls, form_main;

type

  { TOptionsFrm }

  TOptionsFrm = class(TForm)
    OptionsFrm_RAMSizeEdt: TEdit;
    OptionsFrm_SaveBtn: TButton;
    procedure OptionsFrm_SaveBtnClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  OptionsFrm: TOptionsFrm;

implementation

{$R *.lfm}

{ TOptionsFrm }

procedure TOptionsFrm.OptionsFrm_SaveBtnClick(Sender: TObject);
begin
  //form_main.RAMSize:=StrToFloat(OptionsFrm_RAMSizeEdt.Text);
end;

end.

