unit ARM_Stat;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls,
  //Класс модуля поиска..
  cls_modul_find;

type
  TARMStat = class(TForm)

    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);

  private
    ModFr: TClsMODFind;
  public
    { Public declarations }
  end;

var
  ARMStat: TARMStat;

implementation

{$R *.dfm}

procedure TARMStat.FormCreate(Sender: TObject);
begin
    ModFr  := nil;
    try
      ModFr := TClsMODFind.Create(Self);
      ModFr.ModStat;
    except on E: Exception do
      begin
          ModFr.Free;
          ShowMessage(E.Message);
          //Закрываем форму..
          Self.Close;
      end;
    end;
end;

procedure TARMStat.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Action := caFree;
end;

procedure TARMStat.FormDestroy(Sender: TObject);
begin
    if(ModFr <> nil) then ModFr.Free;
end;

end.
