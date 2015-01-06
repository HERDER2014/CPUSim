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
    FindDlg: TFindDialog;
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
    MainFrm_Menu_File_Spacer2: TMenuItem;
    MainFrm_Menu_File_Exit: TMenuItem;
    MessagesMemo: TMemo;
    OpenDlg: TOpenDialog;
    ReplaceDialog1: TReplaceDialog;
    SaveDlg: TSaveDialog;
    BottomVSplitter: TSplitter;
    StatusBar1: TStatusBar;
    TopVSplitter: TSplitter;
    HSplitter: TSplitter;
    InputSynEdit: TSynEdit;
    RegistersValueList: TValueListEditor;
    ValueListEditor1: TValueListEditor;
    procedure Button1Click(Sender: TObject);
    procedure MainFrm_Menu_Edit_CopyClick(Sender: TObject);
    procedure MainFrm_Menu_Edit_CutClick(Sender: TObject);
    procedure MainFrm_Menu_Edit_FindClick(Sender: TObject);
    procedure MainFrm_Menu_Edit_PasteClick(Sender: TObject);
    procedure MainFrm_Menu_Edit_RedoClick(Sender: TObject);
    procedure MainFrm_Menu_Edit_UndoClick(Sender: TObject);
    procedure MainFrm_Menu_File_NewClick(Sender: TObject);
    procedure MainFrm_Menu_File_OpenRecentClick(Sender: TObject);
    procedure MainFrm_Menu_File_SaveAsClick(Sender: TObject);
    procedure MainFrm_Menu_Help_AboutClick(Sender: TObject);
    procedure MainFrm_Menu_Help_ContentsClick(Sender: TObject);
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

end;

procedure TmainFrm.ShowExitDlg;
var
  answer : LongInt;
begin
  //SaveDlg if saved=false?
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

procedure TmainFrm.MainFrm_Menu_Edit_CopyClick(Sender: TObject);
begin
  InputSynEdit.CopyToClipboard;
end;

procedure TmainFrm.MainFrm_Menu_Edit_CutClick(Sender: TObject);
begin
  InputSynEdit.CutToClipboard;
end;

procedure TmainFrm.MainFrm_Menu_Edit_FindClick(Sender: TObject);
begin
  FindDlg.Execute;
end;

procedure TmainFrm.MainFrm_Menu_Edit_PasteClick(Sender: TObject);
begin
  InputSynEdit.PasteFromClipboard;
end;

procedure TmainFrm.MainFrm_Menu_Edit_RedoClick(Sender: TObject);
begin
  InputSynEdit.Redo;
end;

procedure TmainFrm.MainFrm_Menu_Edit_UndoClick(Sender: TObject);
begin
  InputSynEdit.Undo;
end;


procedure TmainFrm.MainFrm_Menu_File_NewClick(Sender: TObject);
begin
  //TODO
end;

procedure TmainFrm.MainFrm_Menu_File_OpenRecentClick(Sender: TObject);
begin
  //Keep trackk of recent files?
end;

procedure TmainFrm.MainFrm_Menu_File_SaveAsClick(Sender: TObject);
begin
  //SaveDlg
end;

procedure TmainFrm.MainFrm_Menu_Help_AboutClick(Sender: TObject);
var
  AboutStr : PChar;
begin
  AboutStr:='CPU Simulator Herder 14' + sLineBreak + 'by Informatik-LK 14/15 (3.Sem) of the Herder-Gymnasium Berlin';
  MessageDlg('About', AboutStr, mtInformation, [mbClose], '0');
end;

procedure TmainFrm.MainFrm_Menu_Help_ContentsClick(Sender: TObject);
begin

end;

procedure TmainFrm.MessagesMemoChange(Sender: TObject);
begin

end;



procedure TmainFrm.MainFrm_Menu_File_OpenClick(Sender: TObject);
var
  path: AnsiString;
  code: TextFile;
  text2:AnsiString;
begin
  OpenDlg.Execute;
  path:=OpenDlg.FileName;
  AssignFile(code, path);
  reset(code);

  //ReadFileToString(text2);
//  InputSynEdit.Text:=text2;
  // for i to ZEILENLAENGE do
    ReadLn(code,text2);
    //file_line ++
  InputSynEdit.Lines[i]:=text2;


end;

procedure TmainFrm.MainFrm_Menu_File_SaveClick(Sender: TObject);
begin
  //if saved: save; else:
  SaveDlg.Execute;
end;

procedure TmainFrm.InputSynEditChange(Sender: TObject);
begin
end;



end.

