unit cls_sql;

interface

uses
  System.SysUtils, System.Variants, System.Classes, Vcl.Dialogs,
  //Для компонентов FireDac..
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Stan.Pool, FireDAC.Phys,
  FireDAC.Phys.PG, FireDAC.Phys.PGDef, FireDAC.VCLUI.Wait, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TCLSSQL = class
    private
        PgDriv: TFDPhysPgDriverLink;                                            //Драйвер PG

      //Функции..
        procedure CreateDrive(Owner: TComponent);                               //Создать драйвер подключения к PG..

        function GetConnectStr: string;                                         //Получить строку подключения..
        function GetSQLText(index: integer): string;                            //Получить запрос создания таблицы..

    public
      //Переменные..
        Srv:  string;
        Port: string;
        Name: string;
        Usr:  string;
        Pass: string;

        constructor Create;                     overload;
        constructor Create(Owner: TComponent);  overload;
        destructor  Free;

      //Функции..
        //Опции..
        function GetSetting : Boolean;                                          //Получение настроек подключения..
        function SetSetting : Boolean;                                          //Сохранение настроек подключения..
        function HasParamConnect: Boolean;                                      //Факт наличия парамметров подключения..
        //Проверка подключения..
        function CheckConnect(Owner: TComponent) : Boolean;  overload;
        function CheckConnect                    : Boolean;  overload;

        //Настройка компонентов подключения..
        procedure SetConnection(Connect: TFDConnection; Transact: TFDTransaction; Query: TFDQuery);
        //Закрытие подключения и очистка памяти..
        procedure CloseConnect(Connect: TFDConnection; Transact: TFDTransaction; Query: TFDQuery);  overload;
        procedure CloseConnect(Connect:  TFDConnection);  overload;
        procedure CloseConnect(Transact: TFDTransaction); overload;
        procedure CloseConnect(Query:    TFDQuery);       overload;

        function CreateStructDB: Boolean;                                       //Создание структуры таблицы..

      //Упрощённые запросы в БД..
        //Отправка Exec запроса..
        procedure QuickExec(Owner: TComponent; TextQuery: string);  overload;
        procedure QuickExec(TextQuery: string);                     overload;
        procedure QuickExec(Query: TFDQuery);                       overload;
        //Отправка Open запроса (SELECT)..
        function  QuickOpenGetBool(Query: TFDQuery): Boolean;
        function  QuickOpenGetInt64(Query: TFDQuery): int64;
        //Загрузка в виртуальную таблицу..
        procedure QuickLoadToMemTable(MTab: TFDMemTable; TextQuery: string);
  end;

implementation

uses
  IniFiles;                                                                     //Считывание INI файла..

{$region 'Конструктор/деструктор класса'}
//Конструктор..
constructor TCLSSQL.Create;
begin
    CreateDrive(nil);
end;

constructor TCLSSQL.Create(Owner: TComponent);
begin
    CreateDrive(Owner);
end;

//Деструктор..
destructor TCLSSQL.Free;
begin
    //Удаляем драйвер для подключения, если создан..
    if(self.PgDriv = nil) then Exit;

    self.PgDriv.Free;
end;
{$endregion}

{$region 'Опции'}

{$region 'Считывание/запись файла конфигурации'}
//Получение настроек..
function TCLSSQL.GetSetting : Boolean;
var
    Ini: Tinifile;
begin
    //Файл настроек в директории программы..
    Ini := TiniFile.Create(GetCurrentDir + '\setting.ini');
    try
      Self.Srv  := Ini.ReadString('PG', 'Server', Self.Srv);
      Self.Port := Ini.ReadString('PG',   'Port', Self.Port);
      Self.Name := Ini.ReadString('PG',   'Name', Self.Name);
      Self.Usr  := Ini.ReadString('PG',   'User', Self.Usr);
      Self.Pass := Ini.ReadString('PG',   'Pass', Self.Pass);
    except on E: Exception do ShowMessage(E.Message);
    end;
    if(Ini <> nil) then Ini.Free;

    result := HasParamConnect;
end;

//Сохранение настроек..
function TCLSSQL.SetSetting : Boolean;
var
    Ini: Tinifile;
begin
    //Файл настроек в директории программы..
    Ini := TiniFile.Create(GetCurrentDir + '\setting.ini');
    try
      Ini.WriteString('PG', 'Server', Self.Srv);
      Ini.WriteString('PG',   'Port', Self.Port);
      Ini.WriteString('PG',   'Name', Self.Name);
      Ini.WriteString('PG',   'User', Self.Usr);
      Ini.WriteString('PG',   'Pass', Self.Pass);

      result := true;
    except on E: Exception do
      begin
          ShowMessage(E.Message);
          result := false;
      end;
    end;
    if(Ini <> nil) then Ini.Free;
end;

//Факт наличия парамметров подключения..
function TCLSSQL.HasParamConnect: Boolean;
begin
    result := not(Self.Name.IsEmpty OR Self.Usr.IsEmpty OR Self.Pass.IsEmpty OR Self.Srv.IsEmpty);
end;
{$endregion}

{$region 'Проверка подключения'}
//Проверка подключения
function TCLSSQL.CheckConnect(Owner: TComponent): Boolean;
var
    Connect:  TFDConnection;
begin
    result := False;
    //Проверяем драйвер для подключения..
    if(self.PgDriv = nil) then
      begin
          ShowMessage('Драйвер подключения не создан!');
          Exit;
      end;

    //Проверим наличие настроек..
    if(HasParamConnect = False) then
      begin
          //Пробуем получить настройки..
          if(Self.GetSetting = false) then
          begin
              ShowMessage('Не настроено подключение!');
              Exit;
          end;
      end;

    //Попытка подключения..
    Connect := TFDConnection.Create(Owner);
    try
      Connect.ConnectionString := GetConnectStr;                                //Создаём строку подключения..
      Connect.Connected        := true;                                         //Проверяем..

      result := Connect.Connected;
    except on E: Exception do ShowMessage(E.Message);
    end;
    if(Connect <> nil) then Connect.Free;
end;

function TCLSSQL.CheckConnect: Boolean;
begin
    result := Self.CheckConnect(nil);
end;
{$endregion}

//Установка подключения для компонентов..
procedure TCLSSQL.SetConnection(Connect: TFDConnection; Transact: TFDTransaction; Query: TFDQuery);
begin
    //Обработка ошибок..
    if(Connect  = nil) then raise Exception.Create('Не передан компонент подключения!');
    if(Transact = nil) then raise Exception.Create('Не передан компонент транзакции!');
    if(Query    = nil) then raise Exception.Create('Не передан компонент DataSet!');

    //Настраиваем..
    Connect.ConnectionString := GetConnectStr;                                  //Получаем строку подключения..
    Connect.Connected        := true;                                           //Проверяем..
    Connect.Transaction      := Transact;                                       //Применяем к подключению транзакцию..
    Query.Connection         := Connect;                                        //Применяем подключение к DataSet'у..
end;

{$region 'Завершение подключения и очистка памяти'}
procedure TCLSSQL.CloseConnect(Connect: TFDConnection; Transact: TFDTransaction; Query: TFDQuery);
begin
    CloseConnect(Query);
    CloseConnect(Transact);
    CloseConnect(Connect);
end;

procedure TCLSSQL.CloseConnect(Connect: TFDConnection);
begin
    if(Connect <> nil) then
    begin
        //Закрытие подключения..
        if(Connect.Connected) then Connect.Close;
        Connect.Free;
    end;
end;

procedure TCLSSQL.CloseConnect(Transact: TFDTransaction);
begin
    if(Transact <> nil) then
    begin
        //Применение транзакции..
        if(Transact.Active) then Transact.Commit;
        Transact.Free;
    end;
end;

procedure TCLSSQL.CloseConnect(Query: TFDQuery);
begin
    if(Query <> nil) then
    begin
        //Закрытие DataSet'а..
        if(Query.Active) then Query.Close();
        Query.Free;
    end;
end;
{$endregion}

{$region 'Проверка/создание структуры базы данных'}
//Создать структуру базы данных..
function TCLSSQL.CreateStructDB: Boolean;
var
    S: integer;                                                                 //Счётчик..
begin
    result := False;
    try
      for S := 1 to 5 do QuickExec(GetSQLText(S));
      //По завершению - успех!..
      result := True;
    except on E: Exception do ShowMessage(E.Message);
    end;
end;
{$endregion}

{$region 'Быстрая загрузка/изменение данных'}
//Отправка Exec запроса..
procedure TCLSSQL.QuickExec(Owner: TComponent; TextQuery: string);
var
    //Компоненты подключения..
    Connect:  TFDConnection;
    Transact: TFDTransaction;
    Query:    TFDQuery;
    //текст ошибки..
    err:  string;
begin
    if(TextQuery.IsEmpty = True) then raise Exception.Create('Пустой текст запроса!');

    Connect  := nil;
    Transact := nil;
    Query    := nil;

    err := '';
    try
      Connect  := TFDConnection.Create(Owner);                                  //Попытка подключения..
      Transact := TFDTransaction.Create(Owner);                                 //Создаём транзакцию..
      Query    := TFDQuery.Create(Owner);                                       //Создаём DataSet..

      SetConnection(Connect, Transact, Query);                                  //Применяем настройки..
      Transact.StartTransaction;                                                //Запуск транзакции..

      Query.SQL.Text := TextQuery;                                              //Получение запроса..
      Query.ExecSQL;                                                            //Запуск запроса..

    except on E: Exception do
      begin
        if(Transact <> nil) then
        begin
            if(Transact.Active) then Transact.Rollback;                         //Откат транзакции..
        end;
        err := E.Message;
      end;
    end;
    //Очистка памяти..
    CloseConnect(Connect, Transact, Query);

    //Отправим ошибку, если есть..
    if(err.IsEmpty = False) then raise Exception.Create(err);
end;

procedure TCLSSQL.QuickExec(TextQuery: string);
begin
    QuickExec(nil, TextQuery);
end;

procedure TCLSSQL.QuickExec(Query: TFDQuery);
var
    //Компоненты подключения..
    Connect:  TFDConnection;
    Transact: TFDTransaction;
    //текст ошибки..
    err:  string;
begin
    if(Query = nil) then raise Exception.Create('Не передан DataSet');

    Connect  := nil;
    Transact := nil;
    Query    := nil;

    err := '';
    try
      Connect  := TFDConnection.Create(nil);                                    //Попытка подключения..
      Transact := TFDTransaction.Create(nil);                                   //Создаём транзакцию..

      SetConnection(Connect, Transact, Query);                                  //Применяем настройки..
      Transact.StartTransaction;                                                //Запуск транзакции..

      Query.ExecSQL;                                                            //Запуск запроса..
    except on E: Exception do
      begin
        if(Transact <> nil) then
        begin
            if(Transact.Active) then Transact.Rollback;                         //Откат транзакции..
        end;
        if(Query.Active) then Query.Close;                                      //Закрываем DataSet..
        err := E.Message;
      end;
    end;
    //Очистка памяти..
    CloseConnect(Transact);
    CloseConnect(Connect);

    Query.Connection := nil;                                                    //Отменяем ссылку на подключение

    //Отправим ошибку, если есть..
    if(err.IsEmpty = False) then raise Exception.Create(err);
end;

//Отправка Open запроса (SELECT)..
function TCLSSQL.QuickOpenGetBool(Query: TFDQuery): Boolean;
var
    //Компоненты подключения..
    Connect:  TFDConnection;
    Transact: TFDTransaction;
    //текст ошибки..
    err:  string;
begin
    if(Query = nil) then raise Exception.Create('Не передан DataSet');

    Connect  := nil;
    Transact := nil;

    result := False;
    err    := '';
    try
      Connect  := TFDConnection.Create(nil);                                    //Попытка подключения..
      Transact := TFDTransaction.Create(nil);                                   //Создаём транзакцию..

      SetConnection(Connect, Transact, Query);                                  //Применяем настройки..
      Transact.StartTransaction;                                                //Запуск транзакции..

      Query.Open;                                                               //Запуск запроса..
      //Получение данных..
      if(not(Query.Fields.Fields[0].IsNull)) then result := Query.Fields.Fields[0].AsBoolean;

      Query.Close;                                                              //Закрываем DataSet..
    except on E: Exception do
      begin
        if(Transact <> nil) then
        begin
            if(Transact.Active) then Transact.Rollback;                         //Откат транзакции..
        end;
        if(Query.Active) then Query.Close;                                      //Закрываем DataSet..
        err := E.Message;
      end;
    end;
    //Очистка памяти..
    CloseConnect(Transact);
    CloseConnect(Connect);

    Query.Connection := nil;                                                    //Отменяем ссылку на подключение

    //Отправим ошибку, если есть..
    if(err.IsEmpty = False) then raise Exception.Create(err);
end;

function TCLSSQL.QuickOpenGetInt64(Query: TFDQuery): int64;
var
    //Компоненты подключения..
    Connect:  TFDConnection;
    Transact: TFDTransaction;
    //текст ошибки..
    err:  string;
begin
    if(Query = nil) then raise Exception.Create('Не передан DataSet');

    Connect  := nil;
    Transact := nil;

    result := 0;
    err    := '';
    try
      Connect  := TFDConnection.Create(nil);                                    //Попытка подключения..
      Transact := TFDTransaction.Create(nil);                                   //Создаём транзакцию..

      SetConnection(Connect, Transact, Query);                                  //Применяем настройки..
      Transact.StartTransaction;                                                //Запуск транзакции..

      Query.Open;                                                               //Запуск запроса..
      //Получение данных..
      if(not(Query.Fields.Fields[0].IsNull)) then result := Query.Fields.Fields[0].AsLargeInt;

      Query.Close;                                                              //Закрываем DataSet..
    except on E: Exception do
      begin
        if(Transact <> nil) then
        begin
            if(Transact.Active) then Transact.Rollback;                         //Откат транзакции..
        end;
        if(Query.Active) then Query.Close;                                      //Закрываем DataSet..
        err := E.Message;
      end;
    end;
    //Очистка памяти..
    CloseConnect(Transact);
    CloseConnect(Connect);

    Query.Connection := nil;                                                    //Отменяем ссылку на подключение

    //Отправим ошибку, если есть..
    if(err.IsEmpty = False) then raise Exception.Create(err);
end;

//Загрузка в виртуальную таблицу..
procedure TCLSSQL.QuickLoadToMemTable(MTab: TFDMemTable; TextQuery: string);
var
    //Компоненты подключения..
    Connect:  TFDConnection;
    Transact: TFDTransaction;
    Query:    TFDQuery;
    //текст ошибки..
    err:  string;
begin
    if(TextQuery.IsEmpty = True) then raise Exception.Create('Пустой текст запроса!');
    if(MTab = nil) then raise Exception.Create('Не передана виртуальная таблица!');

    Connect  := nil;
    Transact := nil;
    Query    := nil;

    err := '';
    try
      Connect  := TFDConnection.Create(nil);                                    //Попытка подключения..
      Transact := TFDTransaction.Create(nil);                                   //Создаём транзакцию..
      Query    := TFDQuery.Create(nil);                                         //Создаём DataSet..

      SetConnection(Connect, Transact, Query);                                  //Применяем настройки..
      Transact.StartTransaction;                                                //Запуск транзакции..

      Query.SQL.Text := TextQuery;                                              //Получение запроса..
      Query.Open;                                                               //Запуск запроса..

      if(MTab.ControlsDisabled) then MTab.EnableControls;
      if(MTab.Active) then MTab.Close;

//      MTab.EmptyDataSet;                                                        //Убираем данные из виртуальной таблицы..
      MTab.CopyDataSet(Query, [coStructure, coRestart, coAppend]);              //Загрузка данных в виртуальную таблицу..
    except on E: Exception do
      begin
        if(Transact <> nil) then
        begin
            if(Transact.Active) then Transact.Rollback;                         //Откат транзакции..
        end;
        err := E.Message;
      end;
    end;
    //Очистка памяти..
    CloseConnect(Connect, Transact, Query);

    //Отправим ошибку, если есть..
    if(err.IsEmpty = False) then raise Exception.Create(err);
end;

{$endregion}

{$endregion}

{$region 'Локальные функции'}
//Создание и настройка драйвера подключения..
procedure TCLSSQL.CreateDrive(Owner: TComponent);
begin
    Self.Srv  := '';
    Self.Port := '';
    Self.Name := '';
    Self.Usr  := '';
    Self.Pass := '';

    PgDriv := TFDPhysPgDriverLink.Create(Owner);                                //Создаём драйвер для подключения..
    try
      PgDriv.VendorLib := (GetCurrentDir + '\lib\libpq.dll');                   //Путь к библиотеке Postgres, файл "libpq.dll"..
      //Загрузка настроек подключения..
      if(not(GetSetting)) then raise Exception.Create('Не удалось загрузить настройки подключения!');

    except on E: Exception do
      begin
        PgDriv.Free;
        ShowMessage(E.Message);
      end;
    end;
end;

//Получить строку подключения..
function TCLSSQL.GetConnectStr: string;
begin
    if(HasParamConnect = False) then
      begin
          result := '';
          Exit;
      end;

    result := ('Database='  + Self.Name +
              ';User_Name=' + Self.Usr  +
              ';Password='  + Self.Pass +
              ';Server='    + Self.Srv  +
              ';DriverID=PG');
end;

//Получить запрос создания таблицы..
function TCLSSQL.GetSQLText(index: integer): string;
begin
    //В зависимости от шага, выбираем запрос для создания той или иной таблицы..
    //!!! Запросы для PostgreSQL 14 версии (в крайнем случае свыше 10-й)..

    case index of
        1:  //Создание схемы..
            begin
                result := ('CREATE SCHEMA IF NOT EXISTS mis');
                Exit;
            end;
        2:  //Последовательность для таблицы пациентов..
            begin
                result := ('CREATE SEQUENCE IF NOT EXISTS mis.patient_code AS BIGINT START 1');
                Exit;
            end;
        3:  //Таблица пациентов..
            begin
                result := ('CREATE TABLE IF NOT EXISTS mis.patient('
                              +   'cartnum BIGINT PRIMARY KEY DEFAULT nextval(''mis.patient_code'')'  //Код пациента (номер карты)
                              + ', date_reg TIMESTAMP NOT NULL DEFAULT NOW()'                         //Дата регистрации пациента
                              + ', surname VARCHAR NOT NULL'                                          //Фамилия
                              + ', name VARCHAR NOT NULL'                                             //Имя
                              + ', middlename VARCHAR NULL'                                           //Отчество
                              + ', age DATE NOT NULL'                                                 //Дата рождения
                              + ', sex INTEGER NOT NULL)');                                           //Пол
                Exit;
            end;
        4:  //Последовательность для таблицы справок..
            begin
                result := ('CREATE SEQUENCE IF NOT EXISTS mis.blank_id AS BIGINT START 1');
                Exit;
            end;
        5:  //Таблица справок..
            begin
                result := ('CREATE TABLE IF NOT EXISTS mis.blank('
                              +   'id BIGINT PRIMARY KEY DEFAULT nextval(''mis.blank_id'')' //Идентификатор
                              + ', cartnum BIGINT NOT NULL'                                 //Код пациента
                              + ', date_reg TIMESTAMP NOT NULL DEFAULT NOW()'               //дата регистрации справки(дата выдачи)
                              + ', name VARCHAR NOT NULL)');                                //Наименование справки
                Exit;
            end;
    end;
    result := '';
end;
{$endregion}

end.
