unit form_main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SynEdit, SynCompletion, SynMemo, Forms, Controls,
  Graphics, Dialogs, StdCtrls, Menus, LCLType, ExtCtrls, ValEdit, Grids,
  ComCtrls;

type

  { TmainFrm }

  TmainFrm = class(TForm)
    MainFrm_Menu: TMainMenu;
    MainFrm_Menu_File: TMenuItem;
    MainFrm_Menu_File_New: TMenuItem;
    MainFrm_Menu_Edit: TMenuItem;
    MainFrm_Menu_Edit_Undo: TMenuItem;
    MainFrm_Menu_Edit_Redo: TMenuItem;
    MainFrm_Menu_Edit_Spacer1: TMenuItem;
    MainFrm_Menu_Edit_Cut: TMenuItem;
    MainFrm_Menu_Edit_Copy: TMenuItem;
    MainFrm_Menu_Edit_Paste: TMenuItem;
    MainFrm_Menu_Edit_Spacer2: TMenuItem;
    MainFrm_Menu_Edit_Find: TMenuItem;
    MainFrm_Menu_Edit_FindNext: TMenuItem;
    MainFrm_Menu_File_Spacer1: TMenuItem;
    MainFrm_Menu_Help: TMenuItem;
    MainFrm_Menu_Help_Contents: TMenuItem;
    MainFrm_Menu_Help_Tutorial: TMenuItem;
    MainFrm_Menu_Help_Spacer1: TMenuItem;
    MainFrm_Menu_Help_About: TMenuItem;
    MainFrm_Menu_File_Open: TMenuItem;
    MainFrm_Menu_File_OpenRecent: TMenuItem;
    MainFrm_Menu_File_Save: TMenuItem;
    MainFrm_Menu_File_SaveAs: TMenuItem;
    MainFrm_Menu_File_Close: TMenuItem;
    MainFrm_Menu_File_Spacer2: TMenuItem;
    MainFrm_Menu_File_Exit: TMenuItem;
    MessagesMemo: TMemo;
    OpenDlg: TOpenDialog;
    SaveDlg: TSaveDialog;
    BottomVSplitter: TSplitter;
    StatusBar1: TStatusBar;
    TopVSplitter: TSplitter;
    HSplitter: TSplitter;
    RAMViewStaticTxt: TStaticText;
    InputSynEdit: TSynEdit;
    RegistersValueList: TValueListEditor;
    procedure Button1Click(Sender: TObject);
    procedure MainFrm_Menu_Help_AboutClick(Sender: TObject);
    procedure MessagesMemoChange(Sender: TObject);
    procedure ShowExitDlg;
    procedure FormCreate(Sender: TObject);
    procedure MainFrm_Menu_File_ExitClick(Sender: TObject);
    procedure MainFrm_Menu_File_OpenClick(Sender: TObject);
    procedure MainFrm_Menu_File_SaveClick(Sender: TObject);
    procedure InputSynEditChange(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  mainFrm: TmainFrm;

implementation

{$R *.lfm}

{ TmainFrm }

procedure TmainFrm.FormCreate(Sender: TObject);
begin
  //example code for registers:
  RegistersValueList.Row := 0;
  RegistersValueList.InsertRow('AX','0000000000000000',true);

  InputSynEdit.Text:='';

  MessagesMemo.Text:='Hit "Run" to test your program!';

  RAMViewStaticTxt.Caption:='';
end;

procedure TmainFrm.ShowExitDlg;
var
  answer : LongInt;
begin
  answer := MessageDlg('Do you really want to quit?', mtConfirmation, mbYesNoCancel, 0);
  if  answer = mrYes then
  begin
    Application.Terminate;
  end else if answer = mrNo then
  begin
    SaveDlg.Execute;
  end;
end;


procedure TmainFrm.MainFrm_Menu_File_ExitClick(Sender: TObject);
begin
  ShowExitDlg;
end;

procedure TmainFrm.Button1Click(Sender: TObject);
begin
end;

procedure TmainFrm.MainFrm_Menu_Help_AboutClick(Sender: TObject);
var
  AboutStr : PChar;
begin
  AboutStr:='CPU Simulator Herder 14' + sLineBreak + 'by Informatik-LK 14/15 (3.Sem) of the Herder-Gymnasium Berlin';
  MessageDlg('About', AboutStr, mtInformation, [mbClose], '0');
end;

procedure TmainFrm.MessagesMemoChange(Sender: TObject);
begin

end;



procedure TmainFrm.MainFrm_Menu_File_OpenClick(Sender: TObject);
begin
  OpenDlg.Execute;
end;

procedure TmainFrm.MainFrm_Menu_File_SaveClick(Sender: TObject);
begin
  SaveDlg.Execute;
end;

procedure TmainFrm.InputSynEditChange(Sender: TObject);
begin
end;



end.

