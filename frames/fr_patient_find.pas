unit fr_patient_find;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.ExtCtrls,
  Vcl.Grids, Vcl.DBGrids, Vcl.StdCtrls, Vcl.Buttons, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, Vcl.ComCtrls, System.UITypes;

type
  TFrPatientFind = class(TFrame)
    DBGrid_patients: TDBGrid;
    P_find: TPanel;
    Ed_find: TEdit;
    SBt_clear: TSpeedButton;
    DS_list: TDataSource;
    FDMTab_list: TFDMemTable;
    SBt_find: TSpeedButton;
    P_top: TPanel;
    SBt_del: TSpeedButton;
    SBt_mod: TSpeedButton;
    SBt_add: TSpeedButton;
    SBt_update: TSpeedButton;
    P_topsetting: TPanel;
    P_moditem: TPanel;
    GrBox_filter: TGroupBox;
    P_period_reg: TPanel;
    ChkBox_period_reg: TCheckBox;
    Period_reg_begin: TDateTimePicker;
    Label1: TLabel;
    Period_reg_end: TDateTimePicker;
    P_period_age: TPanel;
    Label2: TLabel;
    ChkBox_period_age: TCheckBox;
    Period_age_begin: TDateTimePicker;
    Period_age_end: TDateTimePicker;
    P_filter_control: TPanel;
    Bt_set_filter: TBitBtn;
    P_blanks: TPanel;
    P_patients: TPanel;
    Splitter1: TSplitter;
    P_top_blanks: TPanel;
    SBt_blk_mod: TSpeedButton;
    SBt_blk_del: TSpeedButton;
    SBt_blk_add: TSpeedButton;
    SBt_blk_upd: TSpeedButton;
    DBGrid_blanks: TDBGrid;
    DS_blanks: TDataSource;
    FDMTab_blanks: TFDMemTable;

    procedure FrameResize(Sender: TObject);
    procedure SBtClick(Sender: TObject);
    procedure SBtBlanksClick(Sender: TObject);
    procedure ChkClick(Sender: TObject);
    //Работа с DateTimePicker..
    procedure PeriodEnter(Sender: TObject);
    procedure PeriodKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Ed_findKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure DBGrid_patientsCellClick(Column: TColumn);
    procedure DBGrid_patientsKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure DBGrid_patientsEnter(Sender: TObject);

  private
    procedure ChkAcces(Sender: TCheckBox);                                      //Визуализация выборки фильтра..(CheckBox's)
    procedure BlanksAcces(Vis: Boolean);                                        //Активность блока "список справок"..

    function GetPeriodReg : string;                                             //Получить выбранный период регистрации пациента..
    function GetPeriodAge : string;                                             //Получить выбранный период даты рождения пациента..

    function GetId      : int64;                                                //Получить id выбранного пациента..
    function GetIdBlank : int64;                                                //Получить id выбранной справки..

    procedure LoadDataBlanks();                                                 //Загрузка списка справок пациента..

  public
    procedure LoadData;                                                         //Загрузка списка..

  end;

implementation

uses  cls_sql,                                                                  //Используем класс подключений..
      cls_patient,                                                              //Класс пациента..
      cls_blank,                                                                //Класс справок
      System.DateUtils;                                                         //Работа с датой..
{$R *.dfm}

{$region 'События компонентов'}
procedure TFrPatientFind.FrameResize(Sender: TObject);
var set_h: integer;
begin
    set_h := DBGrid_patients.Width;                                             //Запоминаем ширину таблицу..
    //Отнимаем ширину столбцов 2 и 3..
    set_h := (set_h - DBGrid_patients.Columns.Items[1].Width - DBGrid_patients.Columns.Items[2].Width);
    //Для ФИО устанавливаем ширину для заполнения таблицы (в EhLib есть автоподстройка столбцов)..
    DBGrid_patients.Columns.Items[0].Width := (set_h - 40);

    //Выравним колонки в таблице справок..
    set_h := (DBGrid_blanks.Width - DBGrid_blanks.Columns.Items[0].Width);
    DBGrid_blanks.Columns.Items[1].Width := (set_h - 40);
end;

//События кнопок (пациенты)..
procedure TFrPatientFind.SBtClick(Sender: TObject);
  label Load;                                                                   //Метка перехода..
  var   id:  Int64;                                                             //Идентификатор элемента.. (в PostgreSQL BIGINT)
        pat: TCLSPat;
begin
    pat := nil;                                                                 //Инициализация класса..

    if(Sender is TSpeedButton) then
      begin
          //Обновление списка/поиск..
          if(((Sender as TSpeedButton).Tag = 0) OR
             ((Sender as TSpeedButton).Tag = 4)) then goto Load;
          if((Sender as TSpeedButton).Tag = 5) then
            begin
                Ed_find.Text := '';
                goto Load;                                                      //Обновление списка..
            end;

          //Смотрим только для кнопок редактирования элеменетов..
          if((Sender as TSpeedButton).Tag = 1) then id := 0                     //Регистрация пациента (Парамметр 0)..
          else
            begin
                //Редактирование или удаление пациента..
                try
                  id := GetId;
                except on E: Exception do
                  begin
                      ShowMessage(E.Message);
                      Exit;
                  end;
                end;
            end;

          if((Sender as TSpeedButton).Tag = 3) then
            begin
                //Удаление пациента..
                if(MessageDlg('Вы действительно хотите удалить данные о пациенте?', mtConfirmation, mbYesNoCancel, 0) = idYes) then
                  begin
                      try
                        pat := TCLSPat.Create;
                        pat.Delete(id);
                      except on E: Exception do ShowMessage(E.Message);
                      end;
                      //Очистка памяти..
                      if(pat <> nil) then pat.Free;
                  end;
                goto Load;
            end;

          //Открываем форму редактирования/регистрации пациента..
          try
            pat := TCLSPat.Create;
            pat.Open(Self, id);
          except on E: Exception do ShowMessage(E.Message);
          end;
          //Очистка памяти..
          if(pat <> nil) then pat.Free;
      end;

    //Загрузка данных..
    Load: LoadData;
end;

//События кнопок (справки)..
procedure TFrPatientFind.SBtBlanksClick(Sender: TObject);
  label Load;                                                                   //Метка перехода..
  var   id:  Int64;                                                             //Идентификатор элемента.. (в PostgreSQL BIGINT)
        blk: TCLSBlank;
begin
    blk := nil;                                                                 //Инициализация класса..

    if(Sender is TSpeedButton) then
      begin
          if((Sender as TSpeedButton).Tag = 0) then goto Load;                  //Обновление списка..

          //Смотрим только для кнопок редактирования элеменетов..
          if((Sender as TSpeedButton).Tag = 1) then id := 0                     //Регистрация пациента (Парамметр 0)..
          else
            begin
                //Редактирование или удаление пациента..
                try
                  id := GetIdBlank;
                except on E: Exception do
                  begin
                      ShowMessage(E.Message);
                      Exit;
                  end;
                end;
            end;

          if((Sender as TSpeedButton).Tag = 3) then
            begin
                //Удаление пациента..
                if(MessageDlg('Вы действительно хотите удалить данные о справке?', mtConfirmation, mbYesNoCancel, 0) = idYes) then
                  begin
                      try
                        blk := TCLSBlank.Create;
                        blk.Delete(id);
                      except on E: Exception do ShowMessage(E.Message);
                      end;
                      //Очистка памяти..
                      if(blk <> nil) then blk.Free;
                  end;
                goto Load;
            end;

          //Открываем форму редактирования/регистрации пациента..
          try
            blk := TCLSBlank.Create;
            if(id <= 0)
              then blk.New(Self, GetId)
              else blk.Open(Self, id);
          except on E: Exception do ShowMessage(E.Message);
          end;
          //Очистка памяти..
          if(blk <> nil) then blk.Free;
      end;

    //Загрузка данных..
    Load: LoadDataBlanks();
end;

{$region 'Событие навигации по таблице'}
//Выбор пациента..
procedure TFrPatientFind.DBGrid_patientsCellClick(Column: TColumn);
begin
    LoadDataBlanks();                                                           //Загрузка списка справок пациента..
end;

procedure TFrPatientFind.DBGrid_patientsEnter(Sender: TObject);
begin
    LoadDataBlanks();                                                           //Загрузка списка справок пациента..
end;

procedure TFrPatientFind.DBGrid_patientsKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    if((Key = VK_UP) OR (Key = VK_DOWN)) then LoadDataBlanks();                 //Загрузка списка справок пациента..
end;
{$endregion}

{$region 'Фильтр данных (критерии выборки)'}
//События выборки фильтра..(CheckBox's)
procedure TFrPatientFind.ChkClick(Sender: TObject);
begin
    ChkAcces(Sender as TCheckBox);
end;

//Работа с DateTimePicker..
procedure TFrPatientFind.PeriodEnter(Sender: TObject);
var
    F: string;
begin
    F := (Sender as TDateTimePicker).Format;                                    //Получаем формат даты(определение нулевой)..
    if(F.IsEmpty) then Exit;

    //Включаем отображение в поле и ставим дату текущую..
    (Sender as TDateTimePicker).Format := '';
    (Sender as TDateTimePicker).Date   := Date();                               //Текущий день..
end;

procedure TFrPatientFind.PeriodKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
    case Key of
        VK_DELETE: (Sender as TDateTimePicker).Format := ' ';                   //Отключаем отображение даты..
    end;
end;
{$endregion}

{$region 'События поля поиска..'}
procedure TFrPatientFind.Ed_findKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    if(Key = VK_RETURN) then SBt_find.Click;                                    //В поле поиска при нажатии на Enter - запустить поиск..
end;
{$endregion}

{$endregion}

{$region 'Загрузка данных в таблицы'}
//Загрузка списка пациентов..
procedure TFrPatientFind.LoadData;
var
    SQL:  TCLSSQL;                                                              //Класс подключений..
    txt:      string;                                                           //Текст запроса..
    tfind:    string;                                                           //Выборка/поиск..
    tsort:    string;                                                           //Сортировка..
begin
    BlanksAcces(False);                                                         //Скроем список справок..

    SQL := nil;

    tfind   := Ed_find.Text;
    tsort   := '';

    try
      SQL := TCLSSQL.Create(Self);

      txt := 'SELECT cartnum, date_reg, (surname || '' '' || name || '' '' || middlename)::varchar AS fio, age FROM mis.patient WHERE 1=1';
      //Поиск по фамилии.. (по нижнему регистру)
      if(not(tfind.IsEmpty)) then tfind := (' AND LOWER(surname) ~ ''^' + tfind.LowerCase(tfind) + '''');

      //Критерии отбора.. (только в АРМ "Статис")
      if(Self.Tag = 2) then
        begin
            //Добавляем выборку по периодам..
            tfind := (tfind + GetPeriodReg);
            tfind := (tfind + GetPeriodAge);
        end;

      //Сортировка записей..
      if(tfind.IsEmpty) then
        begin
            //Для АРМ "Оператор" по умолчанию - Дата создания по убыванию, ограничить 10-ю записями..
            if(Self.Tag = 1) then tsort := ' ORDER BY date_reg DESC LIMIT 10 OFFSET 0';
        end;
      if(tsort.IsEmpty) then tsort := ' ORDER BY surname, name, middlename';    //Сортировка по ФИО..

      //Загрузка данных в таблицу по запросу..
      SQL.QuickLoadToMemTable(FDMTab_list, (txt + tfind + tsort));
    except on E: Exception do ShowMessage(E.Message);
    end;

    if(SQL <> nil) then SQL.Free;
end;

//Загрузка списка справок у пациента..
procedure TFrPatientFind.LoadDataBlanks();
var
    SQL:  TCLSSQL;                                                              //Класс подключений..
    txt:      string;                                                           //Текст запроса..
begin
    //Проверка на отключенный DataSet..
    if(not(FDMTab_list.Active)) then Exit;
    //Проверка на отсутствие данных..
    if(FDMTab_list.FieldByName('cartnum').IsNull) then Exit;

    SQL := nil;
    try
      SQL := TCLSSQL.Create(Self);

      txt := 'SELECT id, date_reg, name FROM mis.blank WHERE cartnum = ' + FDMTab_list.FieldByName('cartnum').AsString + ' ORDER BY date_reg DESC';
      //Загрузка данных в таблицу по запросу..
      SQL.QuickLoadToMemTable(FDMTab_blanks, txt);

      BlanksAcces(True);
    except on E: Exception do ShowMessage(E.Message);
    end;

    if(SQL <> nil) then SQL.Free;
end;

{$endregion}

{$region 'Локальные функции'}
//Визуализация выборки фильтра..(CheckBox's)
procedure TFrPatientFind.ChkAcces(Sender: TCheckBox);
var
    A:  Boolean;                                                                //Факт активации..
begin
    if(not(Sender is TCheckBox)) then Exit;

    A := Sender.Checked;

    //Изменим шрифт CheckBox'а..
    if(A) then Sender.Font.Style := (Sender.Font.Style + [fsBold])
          else Sender.Font.Style := (Sender.Font.Style - [fsBold]);

    //Доступность периода, в зависимости от компонента CheckBox(и подгоним ширину)..
    case Sender.Tag of
        1:  //Период записи..
            begin
                if(A) then Sender.Width := 204
                      else Sender.Width := 180;

                Period_reg_begin.Enabled := A;
                Period_reg_end.Enabled   := A;
            end;
        2:  //Период даты рождения..
            begin
                if(A) then Sender.Width := 186
                      else Sender.Width := 162;

                Period_age_begin.Enabled := A;
                Period_age_end.Enabled   := A;
            end;
    end;
end;

//Активность блока "список справок"..
procedure TFrPatientFind.BlanksAcces(Vis: Boolean);
begin
    P_blanks.Visible  := Vis;
    Splitter1.Visible := Vis;
end;

//Получить выбранный период регистрации пациента..
function TFrPatientFind.GetPeriodReg : string;
begin
    result := '';

    if(not(ChkBox_period_reg.Checked)) then Exit;
    if((Period_reg_begin.Format = ' ') AND (Period_reg_end.Format = ' ')) then Exit;

    if((Period_reg_begin.Format = ' ') OR (Period_reg_end.Format = ' ')) then
      begin
          if(Period_reg_begin.Format = ' ')
            then result := ' AND date_reg < ''' + FormatDateTime('yyyy-mm-dd', Period_reg_end.Date)   + ' 23:59:59.999'''
            else result := ' AND date_reg > ''' + FormatDateTime('yyyy-mm-dd', Period_reg_begin.Date) + ' 00:00:00.000''';
      end
    else result := ' AND date_reg BETWEEN ''' + FormatDateTime('yyyy-mm-dd', Period_reg_begin.Date) + ''' AND '''
                                              + FormatDateTime('yyyy-mm-dd', Period_reg_end.Date) + '''';
end;

//Получить выбранный период даты рождения пациента..
function TFrPatientFind.GetPeriodAge : string;
begin
    result := '';

    if(not(ChkBox_period_age.Checked)) then Exit;
    if((Period_age_begin.Format = ' ') AND (Period_age_end.Format = ' ')) then Exit;

    if((Period_age_begin.Format = ' ') OR (Period_age_end.Format = ' ')) then
      begin
          if(Period_age_begin.Format = ' ')
            then result := ' AND age < ''' + FormatDateTime('yyyy-mm-dd', Period_age_end.Date)   + ' 23:59:59.999'''
            else result := ' AND age > ''' + FormatDateTime('yyyy-mm-dd', Period_age_begin.Date) + ' 00:00:00.000''';
      end
    else result := ' AND age BETWEEN ''' + FormatDateTime('yyyy-mm-dd', Period_age_begin.Date) + ''' AND '''
                                         + FormatDateTime('yyyy-mm-dd', Period_age_end.Date) + '''';
end;

//Получить id выбранного пациента..
function TFrPatientFind.GetId : int64;
begin
    if(not(FDMTab_list.Active)) then raise Exception.Create('DataSet не активен!');
    if(FDMTab_list.FieldByName('cartnum').IsNull) then raise Exception.Create('Не выбран пациент!');

    result := FDMTab_list.FieldByName('cartnum').AsLargeInt;
end;

//Получить id выбранной справки..
function TFrPatientFind.GetIdBlank : int64;
begin
    if(not(FDMTab_blanks.Active)) then raise Exception.Create('DataSet не активен!');
    if(FDMTab_blanks.FieldByName('id').IsNull) then raise Exception.Create('Не выбран пациент!');

    result := FDMTab_blanks.FieldByName('id').AsLargeInt;
end;

{$endregion}

end.
