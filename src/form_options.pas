unit form_options;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Spin, ActnList, StdActns;

type

  { TOptionsFrm }

  TOptionsFrm = class(TForm)
    OptionsFrm_OkBtn: TButton;
    OptionsFrm_CloseBtn: TButton;
    FileExitAct: TFileExit;
    ActionList1: TActionList;
    //OptionsFrm_Step_VelEt: TEdit;
    Label1: TLabel;
    //OptionsFrm_Step_Vel: TLabel;
    OptionsFrm_ApplyBtn: TButton;
    OptionsFrm_RAMSizeEdt: TSpinEdit;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure OptionsFrm_ApplyBtnClick(Sender: TObject);
    procedure OptionsFrm_CloseBtnClick(Sender: TObject);
    procedure OptionsFrm_OkBtnClick(Sender: TObject);
    //function FileSave_ExitActExecute(Sender: TObject) : Boolean;
    procedure OptionsFrm_RAMSizeEdtChange(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    ramsize: Cardinal;
  end;

var
  OptionsFrm: TOptionsFrm;
  Saved : Boolean;

implementation

uses
  form_main;

{$R *.lfm}

{ TOptionsFrm }


procedure TOptionsFrm.OptionsFrm_ApplyBtnClick(Sender: TObject);
begin
  mainFrm.RAMSize:=StrToInt(OptionsFrm_RAMSizeEdt.Text);
  Saved:=True;
end;

procedure TOptionsFrm.OptionsFrm_CloseBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TOptionsFrm.OptionsFrm_OkBtnClick(Sender: TObject);
begin
  mainFrm.RAMSize:=StrToInt(OptionsFrm_RAMSizeEdt.Text);
  Saved:=True;
  Close;
end;

procedure TOptionsFrm.OptionsFrm_RAMSizeEdtChange(Sender: TObject);
begin
  Saved:=False;
end;

procedure TOptionsFrm.FormCreate(Sender: TObject);
begin
  Saved := True;
end;

procedure TOptionsFrm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  CloseAction:=caFree;
  OptionsFrm := Nil;
end;

procedure TOptionsFrm.FormCloseQuery(Sender: TObject; var CanClose: boolean);
var
  answer: longint;
begin
  if Saved then
  begin
    CanClose:=True;
  end else
  begin
    answer := MessageDlg('Do you want to save changes?',
      mtConfirmation, mbYesNoCancel, 0);
    if answer = mrYes then
    begin
      //Save
      CanClose:=True;
    end else if answer = mrNo then
    begin
      CanClose:=True;
    end else
    begin
      CanClose:=False;
    end;
  end;
end;


end.

