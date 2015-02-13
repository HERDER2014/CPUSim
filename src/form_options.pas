unit form_options;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Spin, ActnList, StdActns;

type

  { TOptionsFrm }

  TOptionsFrm = class(TForm)
    FileExitAct: TFileExit;
    FileSaveAsAct: TFileSaveAs;
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
    function FileSave_ExitActExecute(Sender: TObject) : Boolean;
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
  //Free
  Close;
end;

procedure TOptionsFrm.FormCreate(Sender: TObject);
begin
  Saved := true;
end;

procedure TOptionsFrm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  CloseAction:=caFree;
  OptionsFrm := Nil;
end;

procedure TOptionsFrm.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  if FileSave_ExitActExecute(OptionsFrm) then
  begin
    CanClose:=true;
  end else
  begin
    CanClose:=false;
  end;
end;

function TOptionsFrm.FileSave_ExitActExecute(Sender: TObject) : Boolean;
var
  answer: longint;
begin
  if saved then
  begin
    //Application.Terminate;
    Result:=true;
  end else
  begin
    answer := MessageDlg('Do you want to save changes?',
      mtConfirmation, mbYesNoCancel, 0);
    if answer = mrYes then
    begin
      if SavePath='' then
      begin
        Result:=FileSaveAsAct.Execute;
        FileExitAct.Execute;
      end else
      begin
        //InputSynEdit.Lines.SaveToFile(SavePath);
        Saved := true;
        Result:=False;
      end
    end else if answer = mrNo then
    begin
      Result:=true;
      //Application.Terminate;
    end else
    begin
      Result:=False;
    end;
  end;
end;


end.

