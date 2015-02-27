unit form_options;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Spin, ActnList, uCompiler;

type

  { TOptionsFrm }

  TOptionsFrm = class(TForm)
    ShowBreakpointsChkBx: TCheckBox;
    ClearLogOnAsm: TCheckBox;
    PrintTimeChkBx: TCheckBox;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    MiscGrpBx: TGroupBox;
    Label2: TLabel;
    Label3: TLabel;
    OptionsFrm_OkBtn: TButton;
    OptionsFrm_CloseBtn: TButton;
    //OptionsFrm_Step_VelEt: TEdit;
    Label1: TLabel;
    OptionsFrm_RAMSizeEdt: TSpinEdit;
    OptionsFrm_VRAMSizeEdt: TSpinEdit;
    rHex: TRadioButton;
    rDec: TRadioButton;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure OptionsFrm_CloseBtnClick(Sender: TObject);
    procedure OptionsFrm_OkBtnClick(Sender: TObject);
    //function FileSave_ExitActExecute(Sender: TObject) : Boolean;
    procedure OptionsFrm_RAMSizeEdtChange(Sender: TObject);
  private
    { private declarations }
    private procedure ApplyChanges;
  public
    { public declarations }
    ramsize: cardinal;
  end;

var
  OptionsFrm: TOptionsFrm;
  Saved: boolean;

implementation

uses
  form_main;

{$R *.lfm}

{ TOptionsFrm }


procedure TOptionsFrm.ApplyChanges;
begin
  mainFrm.RAMSize := StrToInt(OptionsFrm_RAMSizeEdt.Text);
  mainFrm.VRAMSize := StrToInt(OptionsFrm_VRAMSizeEdt.Text);
  if rHex.Checked then
    mainFrm.numInMode := TNumberInputMode.Hexadecimal
  else
    mainFrm.numInMode := TNumberInputMode.Decimal;
  mainFrm.trackTime:=PrintTimeChkBx.Checked;
  mainFrm.ClearLog:=ClearLogOnAsm.Checked;
  mainFrm.ShowBreakpoints:=ShowBreakpointsChkBx.Checked;
end;

{* ------------------------------------------------------------------------ *}

procedure TOptionsFrm.OptionsFrm_OkBtnClick(Sender: TObject);
begin
  if (OptionsFrm_RAMSizeEdt.Value + OptionsFrm_VRAMSizeEdt.Value > 65535) then
  begin
    //ShowMessage('The RAM size plus the VRAM size may not be greater then 65535.');
    //exit;
    begin
      if MessageDlg('Warning', 'The RAM size plus the VRAM size may not be greater then 65535.', mtConfirmation, [mbCancel, mbIgnore],0) = mrIgnore then
      begin
        ApplyChanges;
        Saved := True;
        Close;
      end;
    end;
  end
  else
  begin
    ApplyChanges;
    Saved := True;
    Close;
  end;
  exit;
  Close;
  // TODO: ignore?
//
//  ApplyChanges;
//  Saved := True;
//  Close;
end;

procedure TOptionsFrm.OptionsFrm_RAMSizeEdtChange(Sender: TObject);
begin
  Saved := False;
end;



procedure TOptionsFrm.FormCreate(Sender: TObject);
begin
  Saved := True;
end;

procedure TOptionsFrm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  CloseAction := caHide;
end;

procedure TOptionsFrm.OptionsFrm_CloseBtnClick(Sender: TObject);
begin
  Close;
end;


end.
