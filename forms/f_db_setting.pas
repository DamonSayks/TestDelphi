unit f_db_setting;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons,
  //Класс подключения..
  cls_sql;

type
  TFSettingDB = class(TForm)
    P_srv: TPanel;
    L_srv: TLabel;
    Ed_srv: TEdit;
    P_port: TPanel;
    L_port: TLabel;
    Ed_port: TEdit;
    P_user: TPanel;
    L_user: TLabel;
    Ed_user: TEdit;
    P_db: TPanel;
    L_db: TLabel;
    Ed_db: TEdit;
    P_pass: TPanel;
    L_pass: TLabel;
    Ed_pass: TEdit;
    P_check: TPanel;
    Bt_check: TBitBtn;
    P_client: TPanel;
    P_control: TPanel;
    Bt_cancel: TBitBtn;
    Bt_save: TBitBtn;
    L_state: TLabel;
    Bt_create: TBitBtn;
    SBt_showpass: TSpeedButton;

    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure BtnClick(Sender: TObject);
    procedure FieldExit(Sender: TObject);
    procedure SBt_showpassMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SBt_showpassMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);

  private
      SQL: TCLSSQL;                                                             //Класс подключения..

    //Процедуры..
      procedure GetData;
      procedure ResultConnectDB(Value : Boolean);

  public
    { Public declarations }
  end;

var
  FSettingDB: TFSettingDB;

implementation

{$R *.dfm}

{$region 'События формы'}
procedure TFSettingDB.FormCreate(Sender: TObject);
begin
    Bt_check.Enabled := false;
    SQL := nil;
    try
      SQL := TCLSSQL.Create(Self);                                              //Создаём драйвер для подключения..
      Bt_check.Enabled := SQL.GetSetting;
    except on E: Exception do
      begin
          if(SQL <> nil) then SQL.Free;
          ShowMessage(E.Message);
      end;
    end;

    GetData;
end;

procedure TFSettingDB.FormDestroy(Sender: TObject);
begin
    if(SQL = nil) then Exit;
    //Очистка памяти..
    SQL.Free;
end;

procedure TFSettingDB.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
    if(Self.ModalResult <> mrOk) then Exit;
    //Сохраняем данные..
    CanClose := SQL.SetSetting;
end;

//Нажатие кнопок..
procedure TFSettingDB.BtnClick(Sender: TObject);
begin
    if(Sender is TBitBtn) then
      case (Sender as TBitBtn).Tag of
          0:  //Проверим подключение..
              begin
                  try
                    ResultConnectDB(SQL.CheckConnect(Self));
                  except on E: Exception do ShowMessage(E.Message);
                  end;
              end;

          1:  //Создание структуры..
              begin
                  try
                    if(SQL.CreateStructDB) then ShowMessage('Структура таблицы создана!');
                  except on E: Exception do ShowMessage(E.Message);
                  end;
              end;
      end;
end;

//Обработка выхода из поля - применение данных в классе..
procedure TFSettingDB.FieldExit(Sender: TObject);
begin
    if(Sender is TEdit) then
      case (Sender as TEdit).Tag of
          0:  Exit;
          1:  SQL.Srv  := Ed_srv.Text;                                          //Имя/адрес сервера PostgreSQL..
          2:  begin
                //Порт сервера PostgreSQL..
                SQL.Port := Ed_port.Text;
                if(SQL.Port.IsEmpty) then
                  begin
                      SQL.Port     := '5432';                                   //по умолчанию - 5432
                      Ed_port.Text := '5432';
                  end;

              end;
          3:  SQL.Name := Ed_db.Text;                                           //Имя базы данных PostgreSQL..
          4:  SQL.Usr  := Ed_user.Text;                                         //Имя пользователя..
          5:  SQL.Pass := Ed_pass.Text;                                         //Пароль пользователя..
      end;
    //Определение доступноксти кнопки "проверки подключения"..
    Bt_check.Enabled := SQL.HasParamConnect;
end;

//Отображение пароля..
procedure TFSettingDB.SBt_showpassMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
    Ed_pass.PasswordChar := #0;
end;
procedure TFSettingDB.SBt_showpassMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
    Ed_pass.PasswordChar := '*';
end;

{$endregion}

{$region 'Локальные функции/процедуры..'}
//Отображение данных..
procedure TFSettingDB.GetData;
begin
    L_state.Caption   := '';
    L_state.Tag       := 0;                                                     //Tag = 0 - нет проверки подключения..
    Bt_save.Enabled   := false;                                                 //Сохранение допускается только после проверки!
    Bt_create.Visible := false;

    //Заносим данные подключения из класса..
    Ed_srv.Text  := SQL.Srv;
    Ed_port.Text := SQL.Port;
    Ed_db.Text   := SQL.Name;
    Ed_user.Text := SQL.Usr;
    Ed_pass.Text := SQL.Pass;

    Bt_check.Enabled := SQL.HasParamConnect;

end;

//Возможность проверки подключения..
procedure TFSettingDB.ResultConnectDB(Value : Boolean);
begin
    if Value then
      begin
        L_state.Tag        := 1;
        L_state.Caption    := 'Подключено';
        L_state.Font.Color := clTeal;
      end
    else
      begin
        L_state.Caption    := 'Не подключено';
        L_state.Tag        := 0;
        L_state.Font.Color := clRed;
      end;

    Bt_save.Enabled   := Value;
    Bt_create.Visible := Value;
end;
{$endregion}

end.
