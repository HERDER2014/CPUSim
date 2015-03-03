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
    OptionsFrm_RAMSizeEdt: TSpinEdit;
    OptionsFrm_VRAMSizeEdt: TSpinEdit;
    //OptionsFrm_Step_VelEt: TEdit;
    Label1: TLabel;
    rHex: TRadioButton;
    rDec: TRadioButton;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure OptionsFrm_CloseBtnClick(Sender: TObject);
    procedure OptionsFrm_OkBtnClick(Sender: TObject);
    //function FileSave_ExitActExecute(Sender: TObject) : Boolean;
    procedure OptionsFrm_RAMSizeEdtChange(Sender: TObject);
  private
    { private declarations }
    private procedure ApplyChanges;
  public
    //procedure setRAMSize(ramSize: Word);
    //procedure setVRAMSize(vramSize: Word);

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

procedure TOptionsFrm.FormShow(Sender: TObject);
begin
  OptionsFrm_RAMSizeEdt.Text:= IntToStr(mainFrm.RAMSize);
  OptionsFrm_VRAMSizeEdt.Text:=IntToStr(mainFrm.VRAMSize);
  if mainFrm.numInMode=TNumberInputMode.Hexadecimal then
  begin
    rHex.Checked:=True;
    rDec.Checked:=False;
  end else
  begin
    rDec.Checked:=True;
    rHex.Checked:=False;
  end;
  PrintTimeChkBx.Checked:=mainFrm.trackTime;
  ClearLogOnAsm.Checked:=mainFrm.ClearLog;
  ShowBreakpointsChkBx.Checked:=mainFrm.ShowBreakpoints;
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
