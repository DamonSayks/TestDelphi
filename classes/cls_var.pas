unit cls_var;

interface

uses System.SysUtils, System.Variants, System.Classes;

type
    //Класс данных integer..
    TCLSV_int = class
      private
        FOld: integer;                                                          //Старое значение
        FNew: integer;                                                          //Новое значение

        function  GetValue: integer;
        procedure SetValue(SendValue: integer);
        function  GetMod : Boolean;
        function  GetNull: Boolean;

      public
          constructor Create;

        //Опции..
          property Value    : integer read GetValue write SetValue;             //Значение переменной
          property isModify : Boolean read GetMod;                              //Факт изменения
          property isNull   : Boolean read GetNull;                             //Проверка на пустое значение

          procedure Clear;                                                      //Очистка данных
          procedure Send(SendValue: integer);                                   //Загрузка значения в класс
          procedure Reset;                                                      //Сброс изменений
          procedure Update;                                                     //Применение изменений
    end;

    //Класс данных int64..
    TCLSV_int64 = class
      private
        FOld: int64;                                                            //Старое значение
        FNew: int64;                                                            //Новое значение

        function  GetValue: int64;
        procedure SetValue(SendValue: int64);
        function  GetMod: Boolean;
        function  GetNull: Boolean;

      public
          constructor Create;

        //Опции..
          property Value    : int64   read GetValue write SetValue;             //Значение переменной
          property isModify : Boolean read GetMod;                              //Факт изменения
          property isNull   : Boolean read GetNull;                             //Проверка на пустое значение

          procedure Clear;                                                      //Очистка данных
          procedure Send(SendValue: int64);                                     //Загрузка значения в класс
          procedure Reset;                                                      //Сброс изменений
          procedure Update;                                                     //Применение изменений
    end;

    //Класс данных string..
    TCLSV_str = class
      private
        FOld: string;                                                           //Старое значение
        FNew: string;                                                           //Новое значение

        function  GetValue: string;
        procedure SetValue(SendValue: string);
        function  GetMod: Boolean;
        function  GetNull: Boolean;

      public
          constructor Create;

        //Опции..
          property Value    : string  read GetValue write SetValue;             //Значение переменной
          property isModify : Boolean read GetMod;                              //Факт изменения
          property isNull   : Boolean read GetNull;                             //Проверка на пустое значение

          procedure Clear;                                                      //Очистка данных
          procedure Send(SendValue: string);                                    //Загрузка значения в класс
          procedure Reset;                                                      //Сброс изменений
          procedure Update;                                                     //Применение изменений
    end;

    //Класс данных TDate..
    TCLSV_date = class
      private
        FOld: TDate;                                                            //Старое значение
        FNew: TDate;                                                            //Новое значение

        function  GetValue: TDate;
        procedure SetValue(SendValue: TDate);
        function  GetMod: Boolean;
        function  GetNull: Boolean;

      public
          constructor Create;

        //Опции..
          property Value    : TDate   read GetValue write SetValue;             //Значение переменной
          property isModify : Boolean read GetMod;                              //Факт изменения
          property isNull   : Boolean read GetNull;                             //Проверка на пустое значение

          procedure Clear;                                                      //Очистка данных
          procedure Send(SendValue: TDate);                                     //Загрузка значения в класс
          procedure Reset;                                                      //Сброс изменений
          procedure Update;                                                     //Применение изменений

    end;

implementation

{$region 'Класс типа данных integer'}

constructor TCLSV_int.Create;
begin
    Clear;
end;

{$region 'Опциональные переменные'}
function TCLSV_int.GetValue: integer;
begin
    result := FNew;                                                             //Возвращаем последнее(новое)
end;

procedure TCLSV_int.SetValue(SendValue: integer);
begin
    FNew := SendValue;                                                          //Устанавливаем последнему(новому)
end;

function TCLSV_int.GetMod: Boolean;
begin
    result := (FOld <> FNew);                                                   //Определяем факт изменения данных в переменной..
end;

function TCLSV_int.GetNull: Boolean;
begin
    result := (FNew = 0);                                                       //Определяем факт нулевого значения..
end;
{$endregion}

//Очистка данных
procedure TCLSV_int.Clear;
begin
    FOld := 0;
    FNew := 0;
end;

//Загрузка значения в класс
procedure TCLSV_int.Send(SendValue: integer);
begin
    //Загрузка происходит в обе переменные..
    FOld := SendValue;
    FNew := SendValue;
end;

//Сброс изменений
procedure TCLSV_int.Reset;
begin
    FNew := FOld;
end;

//Применение изменений
procedure TCLSV_int.Update;
begin
    FOld := FNew;
end;

{$endregion}

{$region 'Класс типа данных int64'}

constructor TCLSV_int64.Create;
begin
    Clear;
end;

{$region 'Опциональные переменные'}
function TCLSV_int64.GetValue: int64;
begin
    result := FNew;                                                             //Возвращаем последнее(новое)
end;

procedure TCLSV_int64.SetValue(SendValue: int64);
begin
    FNew := SendValue;                                                          //Устанавливаем последнему(новому)
end;

function TCLSV_int64.GetMod: Boolean;
begin
    result := (FOld <> FNew);                                                   //Определяем факт изменения данных в переменной..
end;

function TCLSV_int64.GetNull: Boolean;
begin
    result := (FNew = 0);                                                       //Определяем факт нулевого значения..
end;
{$endregion}

//Очистка данных
procedure TCLSV_int64.Clear;
begin
    FOld := 0;
    FNew := 0;
end;

//Загрузка значения в класс
procedure TCLSV_int64.Send(SendValue: int64);
begin
    //Загрузка происходит в обе переменные..
    FOld := SendValue;
    FNew := SendValue;
end;

//Сброс изменений
procedure TCLSV_int64.Reset;
begin
    FNew := FOld;
end;

//Применение изменений
procedure TCLSV_int64.Update;
begin
    FOld := FNew;
end;

{$endregion}

{$region 'Класс типа данных string'}

constructor TCLSV_str.Create;
begin
    Clear;
end;

{$region 'Опциональные переменные'}
function TCLSV_str.GetValue: string;
begin
    result := FNew;                                                             //Возвращаем последнее(новое)
end;

procedure TCLSV_str.SetValue(SendValue: string);
begin
    FNew := SendValue;                                                          //Устанавливаем последнему(новому)
end;

function TCLSV_str.GetMod: Boolean;
begin
    result := (FOld <> FNew);                                                   //Определяем факт изменения данных в переменной..
end;

function TCLSV_str.GetNull: Boolean;
begin
    result := FNew.IsEmpty;                                                     //Определяем факт нулевого значения..
end;
{$endregion}

//Очистка данных
procedure TCLSV_str.Clear;
begin
    FOld := '';
    FNew := '';
end;

//Загрузка значения в класс
procedure TCLSV_str.Send(SendValue: string);
begin
    //Загрузка происходит в обе переменные..
    FOld := SendValue;
    FNew := SendValue;
end;

//Сброс изменений
procedure TCLSV_str.Reset;
begin
    FNew := FOld;
end;

//Применение изменений
procedure TCLSV_str.Update;
begin
    FOld := FNew;
end;

{$endregion}

{$region 'Класс типа данных TDate'}

constructor TCLSV_date.Create;
begin
    Clear;
end;

{$region 'Опциональные переменные'}
function TCLSV_date.GetValue: TDate;
begin
    result := FNew;                                                             //Возвращаем последнее(новое)
end;

procedure TCLSV_date.SetValue(SendValue: TDate);
begin
    FNew := SendValue;                                                          //Устанавливаем последнему(новому)
end;

function TCLSV_date.GetMod: Boolean;
begin
    result := (FOld <> FNew);                                                   //Определяем факт изменения данных в переменной..
end;

function TCLSV_date.GetNull: Boolean;
begin
    result := (FNew = TDate(0));                                                //Определяем факт нулевого значения..
end;
{$endregion}

//Очистка данных
procedure TCLSV_date.Clear;
begin
    FOld := TDate(0);
    FNew := TDate(0);
end;

//Загрузка значения в класс
procedure TCLSV_date.Send(SendValue: TDate);
begin
    //Загрузка происходит в обе переменные..
    FOld := SendValue;
    FNew := SendValue;
end;

//Сброс изменений
procedure TCLSV_date.Reset;
begin
    FNew := FOld;
end;

//Применение изменений
procedure TCLSV_date.Update;
begin
    FOld := FNew;
end;

{$endregion}

end.
