unit f_blank;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ComCtrls,
  Vcl.ExtCtrls, System.UITypes,
  //Класс данных самого бланка..
  cls_blank;

type
  TFBlank = class(TForm)
    P_reg: TPanel;
    L_reg: TLabel;
    Date_reg: TDateTimePicker;
    P_name: TPanel;
    L_name: TLabel;
    Ed_name: TEdit;
    P_control: TPanel;
    Bt_cancel: TBitBtn;
    Bt_save: TBitBtn;

    procedure FormActivate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure SetValue(Sender: TObject);                                        //Применение изменений..

  private
    Data: TCLSBlank;

    procedure LoadData;                                                         //Установка данных в поля..
    function  Save: Boolean;                                                    //Сохранение данных..

  public
      constructor Create(Owner: TComponent; Sender: TCLSBlank); reintroduce;

  end;

var
  FBlank: TFBlank;

implementation

uses DateUtils;
{$R *.dfm}
//Конструктор..
constructor TFBlank.Create(Owner: TComponent; Sender: TCLSBlank);
begin
    inherited Create(Owner);                                                    //Вызов конструктора TForm..

    Data := Sender;
end;

procedure TFBlank.FormActivate(Sender: TObject);
begin
    LoadData;                                                                   //Перенос данных в поля..
end;

procedure TFBlank.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
    if(Self.ModalResult <> mrOk) then
      begin
          //Проверим факт изменения данных..
          if(Data.isModify) then CanClose := (MessageDlg('Данные не сохранены! Вы действительно хотите закрыть?', mtConfirmation, mbYesNoCancel, 0) = idYes);
          Exit
      end;

    //Сохраняем данные..
    CanClose := Save;
end;

//Применение изменений..
procedure TFBlank.SetValue(Sender: TObject);
begin
    if(Sender = Ed_name) then
      begin
          Data.Name := Ed_name.Text;
          Exit;
      end;
    if(Sender = Date_reg) then
      begin
          try
            //Для начала проверим дату..
            if(Date_reg.Date > Date()  ) then raise Exception.Create('Дата выдачи превышает текущую!');
            if(Date_reg.Date = TDate(0)) then raise Exception.Create('Неккорректная дата выдачи!');
            if(Date_reg.Date < (Date() - 10)) then raise Exception.Create('Дата выдачи не должна быть ранее 10 дней от текущей!');

            //При соблюдении проверок - передаём данные..
            Data.DateReg := Date_reg.Date;
          except on E: Exception do
            begin
                Date_reg.Date := Data.DateReg;                                  //Вернём прежнюю..
                Date_reg.SetFocus;                                              //Вернём фокус на дату..
                if(not(E.Message.IsEmpty)) then ShowMessage(E.Message);
            end;
          end;
          Exit;
      end;
end;

//Установка данных в поля..
procedure TFBlank.LoadData;
begin
    if(Data.id = 0)
      then Self.Caption := 'Регистрация справки..'
      else Self.Caption := 'Редактирование справки..';

    Ed_name.Text  := Data.Name;
    Date_reg.Date := Data.DateReg;
end;

//Сохранение данных..
function TFBlank.Save: Boolean;
begin
    result := True;
    //Если нет изменений - просто выходим..
    if(not(Data.isModify)) then Exit;

    try
      Data.Save;                                                                //Попытка сохранить..
    except on E: Exception do
      begin
          result := False;
          ShowMessage(E.Message);
      end;
    end;
end;


end.
