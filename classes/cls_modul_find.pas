unit cls_modul_find;

interface

uses
  System.SysUtils, System.Variants, System.Classes, Vcl.Dialogs, Vcl.Controls, Vcl.Forms,
  //Фрэйм модуля поиска пациентов..
  fr_patient_find;

type
  TClsMODFind = class
    private
      FR: TFrPatientFind;                                                       //Класс фрэйма..

    public
        constructor Create(Owner: TComponent);
        destructor  Free;

        procedure ModOper;                                                      //Модуль оператора..
        procedure ModStat;                                                      //Модуль статиста..

        procedure Initial;                                                      //Инициализация модуля поиска..
  end;

implementation

{$region 'Конструктор/деструктор класса'}
constructor TClsMODFind.Create(Owner: TComponent);
begin
    try
      FR := TFrPatientFind.Create(Owner);                                       //Создаём фрэйм..
      FR.Parent := (Owner as TWinControl);                                      //Задаём родителя фрэйма..
    except on E: Exception do
      begin
          FR.Free;
          FR := nil;
          //Отправим исключение выше..
          raise Exception.Create(E.Message);
      end;
    end;
end;

destructor TClsMODFind.Free;
begin
    if(FR <> nil) then FR.Free;
end;
{$endregion}

{$region 'Выбор модуля'}
//Модуль оператора..
procedure TClsMODFind.ModOper;
begin
    if(FR = nil) then Exit;

    FR.Tag := 1;
    FR.P_moditem.Visible    := True;
    FR.GrBox_filter.Visible := False;
    FR.P_top_blanks.Visible := True;
    FR.P_top.Height := 34;
end;
//Модуль статиста..
procedure TClsMODFind.ModStat;
begin
    if(FR = nil) then Exit;

    FR.Tag := 2;
    FR.P_moditem.Visible    := False;
    FR.P_top_blanks.Visible := False;
    FR.GrBox_filter.Visible := True;
    FR.P_blanks.Visible     := False;
    FR.P_top.Height := 132;
end;
{$endregion}

//Инициализация модуля поиска..
procedure TClsMODFind.Initial;
begin
    if(FR = nil) then Exit;
    //Включить загрузку данных..
    FR.LoadData;
end;

end.
