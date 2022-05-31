unit cls_blank;

interface

uses  System.SysUtils, System.Classes,
      cls_var;                                                                  //Класс переменных

type
    TCLSBlank = class
      private
        //Структура данных..
          FId      : TCLSV_int64;                                               //Идентификатор справки
          FDateReg : TCLSV_date;                                                //Дата выдачи
          FCartnum : TCLSV_int64;                                               //Код пациента (номер карты)
          FName    : TCLSV_str;                                                 //Наименование справки

        //Функции..
          //function read Value           //procedure write Value
          function  GetID    : int64;       procedure SetID(   Value: int64);
          function  GetDateR : TDate;       procedure SetDateR(Value: TDate);
          function  GetCard  : int64;       procedure SetCard( Value: int64);
          function  GetName  : string;      procedure SetName( Value: string);
          function  GetMod   : Boolean;
          function  GetNull  : Boolean;

          procedure InsetData;                                                  //Вставка данных в БД
          procedure UpdateData;                                                 //Изменение данных в БД

          //Формирование строки парамметров..
          function SetParam(itsModify: Boolean; name_field: string; sql_param: string): string;

      public
          constructor Create;
          destructor  Free;

        //Опциональные переменные..
          property id       : int64   read GetID    write SetID;
          property DateReg  : TDate   read GetDateR write SetDateR;
          property Cartnum  : int64   read GetCard  write SetCard;
          property Name     : string  read GetName  write SetName;
          property isModify : Boolean read GetMod;
          property isNull   : Boolean read GetNull;

        //Функции..
          procedure Clear;                                                      //Очистка данных..
          procedure Reset;                                                      //Сброс данных..
          procedure Update;                                                     //Применение данных..

          //Работа с БД..
          procedure Load(Value: int64);                                         //Загрузка данных
          procedure Save;                                                       //Сохранение данных
          procedure Delete(Value: int64);                                       //Удаление данных

          procedure New(Owner: TComponent; CodePat: int64);                     //Создать новую справку
          procedure Open(Owner: TComponent; SendId: int64);                     //Редактировать справку

    end;

implementation

uses  FireDAC.Comp.Client,                                                      //Для компонента TFDQuery (DataSet)
      FireDAC.Stan.Param,
      Data.DB,
      cls_sql,                                                                  //Класс подключений..
      f_blank;                                                                  //Форма редактирования данных..

{$region 'Конструктор/Деструктор класса'}
constructor TCLSBlank.Create;
begin
    //Инициализируем классы..
    FId      := nil;
    FDateReg := nil;
    FCartnum := nil;
    FName    := nil;

    try
      FId      := TCLSV_int64.Create;
      FDateReg := TCLSV_date.Create;
      FCartnum := TCLSV_int64.Create;
      FName    := TCLSV_str.Create;

      //По умолчанию данные при создании назначаются нулевые, но в данном случае дату будем использовать текущую, а не TDate(0)
      Clear;
    except on E: Exception do raise Exception.Create(E.Message);
    end;
end;

destructor TCLSBlank.Free;
begin
    //Очищаем память..
    if(FId      <> nil) then FId.Free;
    if(FDateReg <> nil) then FDateReg.Free;
    if(FCartnum <> nil) then FCartnum.Free;
    if(FName    <> nil) then FName.Free;
end;
{$endregion}

{$region 'Опциональные переменные'}
function TCLSBlank.GetID: int64;
begin
    result := FId.Value;
end;

procedure TCLSBlank.SetID(Value: int64);
begin
    FId.Value := Value;
end;

function TCLSBlank.GetCard: int64;
begin
    result := FCartnum.Value;
end;

procedure TCLSBlank.SetCard(Value: int64);
begin
    FCartnum.Value := Value;
end;

function TCLSBlank.GetName: string;
begin
    result := FName.Value;
end;

procedure TCLSBlank.SetName(Value: string);
begin
    FName.Value := Value;
end;

function TCLSBlank.GetDateR: TDate;
begin
    result := FDateReg.Value;
end;

procedure TCLSBlank.SetDateR(Value: TDate);
begin
    FDateReg.Value := Value;
end;

function TCLSBlank.GetMod : Boolean;
begin
    result := False;
    //Проверим факт изменения данных..
    if(FId      <> nil) then result := (result OR FId.isModify);
    if(FDateReg <> nil) then result := (result OR FDateReg.isModify);
    if(FCartnum <> nil) then result := (result OR FCartnum.isModify);
    if(FName    <> nil) then result := (result OR FName.isModify);
end;

function TCLSBlank.GetNull: Boolean;
begin
    result := True;
    //Проверим факт пустых данных
//    if(FId      <> nil) then result := (result AND FId.isNull);               //В момент создания - пустой!
    if(FDateReg <> nil) then result := (result AND FDateReg.isNull);
    if(FCartnum <> nil) then result := (result AND FCartnum.isNull);
    if(FName    <> nil) then result := (result AND FName.isNull);
end;
{$endregion}

{$region 'Работа с данными'}
//Очистка данных..
procedure TCLSBlank.Clear;
begin
    //Очистим данные..
    if(FId      <> nil) then FId.Clear;
    if(FDateReg <> nil) then FDateReg.Send(Date());                             //Здесь используем текущую дату, а не нулевую (для удобства)
    if(FCartnum <> nil) then FCartnum.Clear;
    if(FName    <> nil) then FName.Clear;
end;

//Сброс данных..
procedure TCLSBlank.Reset;
begin
    //Сбросим данные..
    if(FId      <> nil) then FId.Reset;
    if(FDateReg <> nil) then FDateReg.Reset;
    if(FCartnum <> nil) then FCartnum.Reset;
    if(FName    <> nil) then FName.Reset;
end;

//Применение данных..
procedure TCLSBlank.Update;
begin
    //Применим данные..
    if(FId      <> nil) then FId.Update;
    if(FDateReg <> nil) then FDateReg.Update;
    if(FCartnum <> nil) then FCartnum.Update;
    if(FName    <> nil) then FName.Update;
end;
{$endregion}

{$region 'Работа с БД'}
//Загрузка данных
procedure TCLSBlank.Load(Value: int64);
var
    SQL    : TCLSSQL;                                                           //Класс подключений
    //Компоненты подключения..
    Connect : TFDConnection;                                                    //Подключение
    Transact: TFDTransaction;                                                   //Транзакция
    Query   : TFDQuery;                                                         //DataSet
    err_txt: string;                                                            //Строка запроса
begin
    SQL := nil;

    Connect  := nil;
    Transact := nil;
    Query    := nil;

    Clear;                                                                      //Очистка данных..
    //Проверка на наличие идентификатора..
    if(Value <= 0) then Exit;

    err_txt := '';
    try
      SQL := TCLSSQL.Create;                                                    //Создаём класс подключения..

      Connect  := TFDConnection.Create(nil);                                    //Попытка подключения..
      Transact := TFDTransaction.Create(nil);                                   //Создаём транзакцию..
      Query    := TFDQuery.Create(nil);

      Query.SQL.Text := 'SELECT * FROM mis.blank WHERE id = :SENDKEY';
      //Установка парамметров..
      Query.ParamByName('SENDKEY').Value := Value;

      SQL.SetConnection(Connect, Transact, Query);                                  //Применяем настройки..
      Transact.StartTransaction;                                                //Запуск транзакции..

      //Отправка запроса..
      Query.Open;
      //Проверка наличия данных..
      if(Query.IsEmpty) then raise Exception.Create('Нет данных по номеру - ' + IntToStr(Value));

      //Получение данных..
      FId.Send(Value);
      FDateReg.Send(Query.FieldByName('date_reg').AsDateTime);
      FCartnum.Send(Query.FieldByName('cartnum' ).AsLargeInt);
      FName.Send(   Query.FieldByName('name'    ).AsString);
    except on E: Exception do err_txt := E.Message;
    end;
    //Очистка памяти..
    if(SQL <> nil) then
      begin
          SQL.CloseConnect(Connect, Transact, Query);
          SQL.Free;
      end;

    //Вернём ошибку, если возникла..
    if(not(err_txt.IsEmpty)) then raise Exception.Create(err_txt);
end;

//Сохранение данных
procedure TCLSBlank.Save;
begin
    //Не сохраняем когда нет изменений..
    if(not(Self.isModify)) then Exit;

    //В зависимости от наличия номера карты определим регистрация нового или изменение выбранного..
    if(Self.id > 0)
      then UpdateData
      else InsetData;

    Self.Update;                                                                //Применим изменения..
end;

//Удаление данных из БД
procedure TCLSBlank.Delete(Value: int64);
var
    SQL      : TCLSSQL;                                                         //Класс подключений
    Query    : TFDQuery;                                                        //DataSet
    err_txt  : string;                                                          //Строка запроса
begin
    SQL   := nil;
    Query := nil;

    if(Value <= 0) then raise Exception.Create('отсутствует номер справки!');

    err_txt := '';
    try
      SQL   := TCLSSQL.Create;                                                  //Создаём класс подключения..
      Query := TFDQuery.Create(nil);

      Query.SQL.Text := 'DELETE FROM mis.blank WHERE id = :SENDKEY';
      //Установка парамметров..
      Query.ParamByName('SENDKEY').Value := Value;

      SQL.QuickExec(Query);                                                     //Отправка запроса..
      //Очистка данных..
      Clear;
    except on E: Exception do err_txt := E.Message;
    end;
    //Очистка памяти..
    if(SQL <> nil) then
      begin
          SQL.CloseConnect(Query);                                              //Закрываем DataSet и очищаем..
          SQL.Free;
      end;

    //Вернём ошибку, если возникла..
    if(not(err_txt.IsEmpty)) then raise Exception.Create('Ошибка удаления: ' + err_txt);
end;

{$region 'Внутрение функции'}
//Вставка данных в БД
procedure TCLSBlank.InsetData;
var
    SQL      : TCLSSQL;                                                         //Класс подключений
    Query    : TFDQuery;                                                        //DataSet
    err_txt  : string;                                                          //Строка запроса
begin
    SQL   := nil;
    Query := nil;

    //Убедимся, что данные не пустые (кроме Cartnum и Middlename, он может быть)..
    if(Self.isNull) then raise Exception.Create('Ошибка выдачи справки: Не введены необходимые данные!');

    err_txt := '';
    try
      SQL   := TCLSSQL.Create;                                                  //Создаём класс подключения..
      Query := TFDQuery.Create(nil);

      Query.SQL.Text := 'INSERT INTO mis.blank(date_reg, cartnum, name) VALUES(:SENDDATEREG, :SENDCARTNUM, :SENDNAME) RETURNING id';
      //Установка парамметров..
      Query.ParamByName('SENDCARTNUM').Value  := FCartnum.Value;
      Query.ParamByName('SENDDATEREG').AsDate := FDateReg.Value;
      Query.ParamByName('SENDNAME'   ).Value  := FName.Value;

      //Отправка запроса..
      FId.Send(SQL.QuickOpenGetInt64(Query));                                   //Получим cartnum зарегистрированного пациента..
    except on E: Exception do err_txt := E.Message;
    end;
    //Очистка памяти..
    if(SQL <> nil) then
      begin
          SQL.CloseConnect(Query);                                              //Закрываем DataSet и очищаем..
          SQL.Free;
      end;

    //Вернём ошибку, если возникла..
    if(not(err_txt.IsEmpty)) then raise Exception.Create(err_txt);
end;

//Изменение данных в БД
procedure TCLSBlank.UpdateData;
var
    SQL      : TCLSSQL;                                                         //Класс подключений
    Query    : TFDQuery;                                                        //DataSet
    err_txt  : string;                                                          //Строка запроса
    sql_param: string;                                                          //Строка парамметров..
begin
    SQL   := nil;
    Query := nil;

    if(FCartnum.isNull) then raise Exception.Create('Ошибка сохранения: отсутствует номер справки!');

    err_txt := '';
    try
      SQL   := TCLSSQL.Create;                                                  //Создаём класс подключения..
      Query := TFDQuery.Create(nil);

      //Сохраняем только те данные, которые изменились..
      sql_param := SetParam(   FName.isModify,     'name', sql_param);
      sql_param := SetParam(FDateReg.isModify, 'date_reg', sql_param);

      Query.SQL.Text := ('UPDATE mis.blank SET ' + sql_param + ' WHERE id = :SENDKEY');
      //Установка парамметров..
      Query.ParamByName('SENDKEY').Value := FId.Value;
      //Если указали..
      if(   FName.isModify) then Query.ParamByName('SENDNAME'    ).Value := FName.Value;
      if(FDateReg.isModify) then Query.ParamByName('SENDDATE_REG').Value := FDateReg.Value;

      SQL.QuickExec(Query);                                                     //Отправка запроса..
    except on E: Exception do err_txt := E.Message;
    end;
    //Очистка памяти..
    if(SQL <> nil) then
      begin
          SQL.CloseConnect(Query);                                              //Закрываем DataSet и очищаем..
          SQL.Free;
      end;

    //Вернём ошибку, если возникла..
    if(not(err_txt.IsEmpty)) then raise Exception.Create(err_txt);
end;

//Формирование строки парамметров..
function TCLSBlank.SetParam(itsModify: Boolean; name_field: string; sql_param: string): string;
begin
    result := sql_param;
    //Если нет изменений - не указываем в запросе..
    if(not(itsModify)) then Exit;

    if(not(sql_param.IsEmpty)) then result := (sql_param + ', ');               //Если запись не первая - добавим разделитель (', ')..
    //результатом будет - # 'id = :ID'
    result := (sql_param + name_field + ' = :' + name_field.UpperCase(name_field));
end;
{$endregion}

{$endregion}

{$region 'Работа с формой'}
//Создать новую справку
procedure TCLSBlank.New(Owner: TComponent; CodePat: int64);
var pForm   : TFBlank;
    err_txt : string;
begin
    Clear;
    pForm := nil;

    err_txt := '';
    try
      FCartnum.Value := CodePat;

      pForm := TFBlank.Create(Owner, Self);
      pForm.ShowModal;
    except on E: Exception do err_txt := E.Message;
    end;
    //Очистка памяти..
    if(pForm <> nil) then pForm.Free;

    if(not(err_txt.IsEmpty)) then raise Exception.Create(err_txt);
end;

//Редактировать справку
procedure TCLSBlank.Open(Owner: TComponent; SendId: int64);
var pForm   : TFBlank;
    err_txt : string;
begin
    pForm := nil;

    err_txt := '';
    try
      Load(SendId);                                                             //Загрузка данных..
      //Открыть форму..
      pForm := TFBlank.Create(Owner, Self);
      pForm.ShowModal;
    except on E: Exception do err_txt := E.Message;
    end;
    //Очистка памяти..
    if(pForm <> nil) then pForm.Free;

    if(not(err_txt.IsEmpty)) then raise Exception.Create(err_txt);
end;
{$endregion}

end.
