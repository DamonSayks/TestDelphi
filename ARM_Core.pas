unit ARM_Core;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus;

type
  TARMCore = class(TForm)
    MainMenu1: TMainMenu;
    M_arm: TMenuItem;
    M_arm_oper: TMenuItem;
    M_arm_stat: TMenuItem;
    M_setting: TMenuItem;
    M_set_bd: TMenuItem;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure MenuClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);

  private
      procedure CheckAccess;                                                    //Проверка доступности программы..

  public
    { Public declarations }
  end;

var
  ARMCore: TARMCore;

implementation

uses
  cls_sql, f_db_setting, ARM_Oper, ARM_Stat, f_sel_arm;                         //Unit'ы классов и дочерних форм..

{$R *.dfm}

procedure TARMCore.FormActivate(Sender: TObject);
begin
    if(Self.Tag <= 0) then Exit;

    //Открываем выбранный АРМ после активации окна....
    if(Self.Tag = 20) then M_arm_oper.Click;
    if(Self.Tag = 21) then M_arm_stat.Click;

    //Сбрасываем..
    Self.Tag := 0;
end;

procedure TARMCore.FormCreate(Sender: TObject);
var SelArm: TFSelArm;
begin
    CheckAccess;
    //Если нет файла конфигураций - откроем окно настроек подключения..
    if(not(M_arm.Enabled)) then  M_set_bd.Click;
    //затем предложим выбрать АРМ..
    if(not(M_arm.Enabled)) then  Exit;

    SelArm := nil;
    try
      SelArm   := TFSelArm.Create(Self);
      Self.Tag := SelArm.ShowModal;                                               //Получим результат..

    except on E: Exception do ShowMessage(E.Message);
    end;
    //Очистка памяти..
    if(SelArm <> nil) then SelArm.Free;
end;


procedure TARMCore.FormDestroy(Sender: TObject);
var
    I: integer;
begin
    //Уничтожить все открытые MDI окна..
    for I := (Self.MDIChildCount - 1) downto 0 do Self.MDIChildren[I].Destroy;
end;

//Событие пунктов меню..
procedure TARMCore.MenuClick(Sender: TObject);
  var
    Oper: TARMOper;
    Stat: TARMStat;
    DB:   TFSettingDB;

begin
    //Определение компонента..
    if(Sender is TMenuItem) then
      case (Sender as TMenuItem).Tag of
          0:  //Настройки подключения к БД..
              begin
                DB := nil;
                try
                  DB := TFSettingDB.Create(Self);
                  DB.ShowModal;
                except on E: Exception do ShowMessage(E.Message);
                end;
                if(DB <> nil) then DB.Free;
                //Определить доступность к БД..
                CheckAccess;
              end;
          1:  //Открыть ARM "Оператор"..
              begin
                Oper := nil;
                try
                  Oper := TARMOper.Create(Self);
                  Oper.Show;
                except on E: Exception do
                  begin
                      ShowMessage(E.Message);
                      Oper.Free;
                  end;
                end;
              end;
          2:  //Открыть ARM "Статист"..
              begin
                Stat := nil;
                try
                  Stat := TARMStat.Create(Self);
                  Stat.Show;
                except on E: Exception do
                  begin
                      ShowMessage(E.Message);
                      Stat.Free;
                  end;
                end;
              end;
      end;
end;

{$region 'Локальные функции'}
//Проверка доступности программы..
procedure TARMCore.CheckAccess;
  var
    SQL:  TCLSSQL;                                                              //Класс запросов..
    chk:  Boolean;
begin
    chk := False;
    SQL := nil;
    try
      SQL := TCLSSQL.Create(Self);                                              //Создаём драйвер для подключения..
      chk := SQL.CheckConnect;                                                  //Проверяем подключение к БД..
    except
      SQL.Free;
    end;

    if(chk = False) then ShowMessage('Отсутствует подключение к БД!');
    //Настраиваем доступность функционалов программы..
    M_arm.Enabled := chk;
end;
{$endregion}

end.
