unit ARM_Oper;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls,
  //Класс модуля поиска..
  cls_modul_find;

type
  TARMOper = class(TForm)

    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure FormActivate(Sender: TObject);

  private
    ModFr: TClsMODFind;
  public

  end;

var
  ARMOper: TARMOper;

implementation

{$R *.dfm}

procedure TARMOper.FormCreate(Sender: TObject);
begin
    ModFr  := nil;
    try
      ModFr := TClsMODFind.Create(Self);
      ModFr.ModOper;
    except on E: Exception do
      begin
          ModFr.Free;
          ShowMessage(E.Message);
          //Закрываем форму..
          Self.Close;
      end;
    end;
end;

procedure TARMOper.FormActivate(Sender: TObject);
begin
    ModFr.Initial;                                                              //Запускаем инициализацию фрэйма..
end;

procedure TARMOper.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Action := caFree;
end;

procedure TARMOper.FormDestroy(Sender: TObject);
begin
    if(ModFr <> nil) then ModFr.Free;
end;

end.
