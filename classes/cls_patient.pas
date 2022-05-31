unit cls_patient;

interface

uses  System.SysUtils, System.Classes,
      cls_var;                                                                  //Класс переменных

type
    TCLSPat = class
      private
        //Структура данных..
          FCartnum   : TCLSV_int64;                                             //Код пациента (номер карты)
          FSurname   : TCLSV_str;                                               //Фамилия
          FName      : TCLSV_str;                                               //Имя
          FMiddlename: TCLSV_str;                                               //Отчество
          FAge       : TCLSV_date;                                              //Дата рождения
          FSex       : TCLSV_int;                                               //Пол

        //Функции..
          //function read Value           //procedure write Value
          function  GetCard: int64;       procedure SetCard(Value: int64);
          function  GetFam : string;      procedure SetFam( Value: string);
          function  GetName: string;      procedure SetName(Value: string);
          function  GetMidl: string;      procedure SetMidl(Value: string);
          function  GetAge : TDate;       procedure SetAge( Value: TDate);
          function  GetSex : integer;     procedure SetSex( Value: integer);
          function  GetMod : Boolean;
          function  GetNull: Boolean;

          procedure InsetData;                                                  //Вставка данных в БД
          procedure UpdateData;                                                 //Изменение данных в БД

          //Формирование строки парамметров..
          function SetParam(itsModify: Boolean; name_field: string; sql_param: string): string;

      public
          constructor Create;
          destructor  Free;

        //Опциональные переменные..
          property Cartnum   : int64   read GetCard write SetCard;
          property Surname   : string  read GetFam  write SetFam;
          property Name      : string  read GetName write SetName;
          property Middlename: string  read GetMidl write SetMidl;
          property Age       : TDate   read GetAge  write SetAge;
          property Sex       : integer read GetSex  write SetSex;
          property isModify  : Boolean read GetMod;
          property isNull    : Boolean read GetNull;

        //Функции..
          procedure Clear;                                                      //Очистка данных..
          procedure Reset;                                                      //Сброс данных..
          procedure Update;                                                     //Применение данных..

          //Работа с БД..
          procedure Load(Value: int64);                                         //Загрузка данных
          procedure Save;                                                       //Сохранение данных
          procedure Delete(Value: int64);                                       //Удаление данных

          procedure New(Owner: TComponent);                                     //Зарегистрировать пациента..
          procedure Open(Owner: TComponent; SendId: int64);                     //Редактировать пациента..

    end;

implementation

uses  FireDAC.Comp.Client,                                                      //Для компонента TFDQuery (DataSet)
      FireDAC.Stan.Param,
      Data.DB,
      cls_sql,                                                                  //Класс подключений..
      pat_edit;                                                                 //Форма данных пациента

{$region 'Конструктор/Деструктор класса'}
constructor TCLSPat.Create;
begin
    //Инициализируем классы..
    FCartnum    := nil;
    FSurname    := nil;
    FName       := nil;
    FMiddlename := nil;
    FAge        := nil;
    FSex        := nil;

    try
      FCartnum    := TCLSV_int64.Create;
      FSurname    := TCLSV_str.Create;
      FName       := TCLSV_str.Create;
      FMiddlename := TCLSV_str.Create;
      FAge        := TCLSV_date.Create;
      FSex        := TCLSV_int.Create;

      //По умолчанию данные при создании назначаются нулевые, но в данном случае дату будем использовать текущую, а не TDate(0)
      Clear;
    except on E: Exception do raise Exception.Create(E.Message);
    end;
end;

destructor TCLSPat.Free;
begin
    //Очищаем память..
    if(FCartnum    <> nil) then FCartnum.Free;
    if(FSurname    <> nil) then FSurname.Free;
    if(FName       <> nil) then FName.Free;
    if(FMiddlename <> nil) then FMiddlename.Free;
    if(FAge        <> nil) then FAge.Free;
    if(FSex        <> nil) then FSex.Free;
end;
{$endregion}

{$region 'Опциональные переменные'}
function TCLSPat.GetCard: int64;
begin
    result := FCartnum.Value;
end;

procedure TCLSPat.SetCard(Value: int64);
begin
    FCartnum.Value := Value;
end;

function TCLSPat.GetFam: string;
begin
    result := FSurname.Value;
end;

procedure TCLSPat.SetFam(Value: string);
begin
    FSurname.Value := Value;
end;

function TCLSPat.GetName: string;
begin
    result := FName.Value;
end;

procedure TCLSPat.SetName(Value: string);
begin
    FName.Value := Value;
end;

function TCLSPat.GetMidl: string;
begin
    result := FMiddlename.Value;
end;

procedure TCLSPat.SetMidl(Value: string);
begin
    FMiddlename.Value := Value;
end;

function TCLSPat.GetAge: TDate;
begin
    result := FAge.Value;
end;

procedure TCLSPat.SetAge(Value: TDate);
begin
    FAge.Value := Value;
end;

function TCLSPat.GetSex : integer;
begin
    result := FSex.Value;
end;

procedure TCLSPat.SetSex(Value: integer);
begin
    FSex.Value := Value;
end;

function TCLSPat.GetMod : Boolean;
begin
    result := False;
    //Проверим факт изменения данных..
    if(FCartnum    <> nil) then result := (result OR FCartnum.isModify);
    if(FSurname    <> nil) then result := (result OR FSurname.isModify);
    if(FName       <> nil) then result := (result OR FName.isModify);
    if(FMiddlename <> nil) then result := (result OR FMiddlename.isModify);
    if(FAge        <> nil) then result := (result OR FAge.isModify);
    if(FSex        <> nil) then result := (result OR FSex.isModify);
end;

function TCLSPat.GetNull: Boolean;
begin
    result := True;
    //Проверим факт пустых данных
//    if(FCartnum    <> nil) then result := (result AND FCartnum.isNull);        //Может быть нулевым (но только при регистрации)
//    if(FMiddlename <> nil) then result := (result AND FMiddlename.isNull);     //Может быть нулевым
    if(FSurname <> nil) then result := (result AND FSurname.isNull);
    if(FName    <> nil) then result := (result AND FName.isNull);
    if(FAge     <> nil) then result := (result AND FAge.isNull);
    if(FSex     <> nil) then result := (result AND FSex.isNull);
end;
{$endregion}

{$region 'Работа с данными'}
//Очистка данных..
procedure TCLSPat.Clear;
begin
    //Очистим данные..
    if(FCartnum    <> nil) then FCartnum.Clear;
    if(FSurname    <> nil) then FSurname.Clear;
    if(FName       <> nil) then FName.Clear;
    if(FMiddlename <> nil) then FMiddlename.Clear;
    if(FAge        <> nil) then FAge.Send(Date());                              //Здесь используем текущую дату, а не нулевую (для удобства)
    if(FSex        <> nil) then FSex.Clear;
end;

//Сброс данных..
procedure TCLSPat.Reset;
begin
    //Сбросим данные..
    if(FCartnum    <> nil) then FCartnum.Reset;
    if(FSurname    <> nil) then FSurname.Reset;
    if(FName       <> nil) then FName.Reset;
    if(FMiddlename <> nil) then FMiddlename.Reset;
    if(FAge        <> nil) then FAge.Reset;
    if(FSex        <> nil) then FSex.Reset;
end;

//Применение данных..
procedure TCLSPat.Update;
begin
    //Применим данные..
    if(FCartnum    <> nil) then FCartnum.Update;
    if(FSurname    <> nil) then FSurname.Update;
    if(FName       <> nil) then FName.Update;
    if(FMiddlename <> nil) then FMiddlename.Update;
    if(FAge        <> nil) then FAge.Update;
    if(FSex        <> nil) then FSex.Update;
end;
{$endregion}

{$region 'Работа с БД'}
//Загрузка данных
procedure TCLSPat.Load(Value: int64);
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

      Query.SQL.Text := 'SELECT * FROM mis.patient WHERE cartnum = :SENDKEY';
      //Установка парамметров..
      Query.ParamByName('SENDKEY').Value := Value;

      SQL.SetConnection(Connect, Transact, Query);                                  //Применяем настройки..
      Transact.StartTransaction;                                                //Запуск транзакции..

      //Отправка запроса..
      Query.Open;
      //Проверка наличия данных..
      if(Query.IsEmpty) then raise Exception.Create('Нет данных по карте - ' + IntToStr(Value));

      //Получение данных..
      FCartnum.Send(   Query.FieldByName('cartnum'   ).AsLargeInt);
      FSurname.Send(   Query.FieldByName('surname'   ).AsString);
      FName.Send(      Query.FieldByName('name'      ).AsString);
      FMiddlename.Send(Query.FieldByName('middlename').AsString);
      FAge.Send(       Query.FieldByName('age'       ).AsDateTime);
      FSex.Send(       Query.FieldByName('sex'       ).AsInteger);
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
procedure TCLSPat.Save;
begin
    //Не сохраняем когда нет изменений..
    if(not(Self.isModify)) then Exit;

    //В зависимости от наличия номера карты определим регистрация нового или изменение выбранного..
    if(Self.Cartnum > 0)
      then UpdateData
      else InsetData;

    Self.Update;                                                                //Применим изменения..
end;

//Удаление данных из БД
procedure TCLSPat.Delete(Value: int64);
var
    SQL      : TCLSSQL;                                                         //Класс подключений
    Query    : TFDQuery;                                                        //DataSet
    err_txt  : string;                                                          //Строка запроса
begin
    SQL   := nil;
    Query := nil;

    if(Value <= 0) then raise Exception.Create('отсутствует номер карты!');

    err_txt := '';
    try
      SQL   := TCLSSQL.Create;                                                  //Создаём класс подключения..
      Query := TFDQuery.Create(nil);

      //Для начала проверим наличие выданных справок у пациента..
      Query.SQL.Text := 'SELECT (COUNT(*) > 0) mis.blank WHERE cartnum = :SENDKEY';
      //Установка парамметров..
      Query.ParamByName('SENDKEY').Value := Value;

      //Отправка запроса..
      if(SQL.QuickOpenGetBool(Query)) then raise Exception.Create('У пациента есть выданные справки, для начала нужно удалить их!');

      Query.SQL.Text := 'DELETE FROM mis.patient WHERE cartnum = :SENDKEY';
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
procedure TCLSPat.InsetData;
var
    SQL      : TCLSSQL;                                                         //Класс подключений
    Query    : TFDQuery;                                                        //DataSet
    err_txt  : string;                                                          //Строка запроса
    sql_field: string;                                                          //Строка полей..
    sql_param: string;                                                          //Строка парамметров..
begin
    SQL   := nil;
    Query := nil;

    //Убедимся, что данные не пустые (кроме Cartnum и Middlename, он может быть)..
    if(Self.isNull) then raise Exception.Create('Ошибка регистрации: Не введены необходимые данные!');

    err_txt := '';
    try
      SQL   := TCLSSQL.Create;                                                  //Создаём класс подключения..
      Query := TFDQuery.Create(nil);

      sql_field := 'surname, name, age, sex';
      sql_param := ':SENDSURNAME, :SENDNAME, :SENDAGE, :SENDSEX';
      if(not(FMiddlename.isNull)) then
        begin
            //Если указали отчество, то добавим и его.. иначе оно будет NULL
            sql_field := (sql_field + ', middlename');
            sql_param := (sql_param + ', :SENDMIDDLE');
        end;

      Query.SQL.Text := 'INSERT INTO mis.patient(' + sql_field + ') VALUES(' + sql_param + ') RETURNING cartnum';
      //Установка парамметров..
      Query.ParamByName('SENDSURNAME').Value  := FSurname.Value;
      Query.ParamByName('SENDNAME'   ).Value  := FName.Value;
      Query.ParamByName('SENDAGE'    ).AsDate := FAge.Value;
      Query.ParamByName('SENDSEX'    ).Value  := FSex.Value;
      //Добавим и отчество, если есть..
      if(not(FMiddlename.isNull)) then Query.ParamByName('SENDMIDDLE').Value := FMiddlename.Value;

      //Отправка запроса..
      FCartnum.Send(SQL.QuickOpenGetInt64(Query));                              //Получим cartnum зарегистрированного пациента..
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
procedure TCLSPat.UpdateData;
var
    SQL      : TCLSSQL;                                                         //Класс подключений
    Query    : TFDQuery;                                                        //DataSet
    err_txt  : string;                                                          //Строка запроса
    sql_param: string;                                                          //Строка парамметров..
begin
    SQL   := nil;
    Query := nil;

    if(FCartnum.isNull) then raise Exception.Create('Ошибка сохранения: отсутствует номер карты!');

    err_txt := '';
    try
      SQL   := TCLSSQL.Create;                                                  //Создаём класс подключения..
      Query := TFDQuery.Create(nil);

      //Сохраняем только те данные, которые изменились..
      sql_param := SetParam(   FSurname.isModify,    'surname', sql_param);
      sql_param := SetParam(      FName.isModify,       'name', sql_param);
      sql_param := SetParam(FMiddlename.isModify, 'middlename', sql_param);
      sql_param := SetParam(       FAge.isModify,        'age', sql_param);
      sql_param := SetParam(       FSex.isModify,        'sex', sql_param);

      Query.SQL.Text := ('UPDATE mis.patient SET ' + sql_param + ' WHERE cartnum = :SENDKEY');
      //Установка парамметров..
      Query.ParamByName('SENDKEY').Value := FCartnum.Value;
      //Если указали..
      if(   FSurname.isModify) then Query.ParamByName('SENDSURNAME').Value := FSurname.Value;
      if(      FName.isModify) then Query.ParamByName('SENDNAME'   ).Value := FName.Value;
      if(FMiddlename.isModify) then Query.ParamByName('SENDMIDDLE' ).Value := FMiddlename.Value;
      if(       FAge.isModify) then Query.ParamByName('SENDAGE'    ).Value := FAge.Value;
      if(       FSex.isModify) then Query.ParamByName('SENDSEX'    ).Value := FSex.Value;

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
function TCLSPat.SetParam(itsModify: Boolean; name_field: string; sql_param: string): string;
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
//Зарегистрировать пациента..
procedure TCLSPat.New(Owner: TComponent);
var pForm   : TFEditPat;
    err_txt : string;
begin
    Clear;
    pForm := nil;

    err_txt := '';
    try
      pForm := TFEditPat.Create(Owner, Self);
      pForm.ShowModal;
    except on E: Exception do err_txt := E.Message;
    end;
    //Очистка памяти..
    if(pForm <> nil) then pForm.Free;

    if(not(err_txt.IsEmpty)) then raise Exception.Create(err_txt);
end;

//Редактировать пациента..
procedure TCLSPat.Open(Owner: TComponent; SendId: int64);
var pForm   : TFEditPat;
    err_txt : string;
begin
    pForm := nil;

    err_txt := '';
    try
      Load(SendId);                                                             //Загрузка данных..
      //Открыть форму..
      pForm := TFEditPat.Create(Owner, Self);
      pForm.ShowModal;
    except on E: Exception do err_txt := E.Message;
    end;
    //Очистка памяти..
    if(pForm <> nil) then pForm.Free;

    if(not(err_txt.IsEmpty)) then raise Exception.Create(err_txt);
end;
{$endregion}


end.
