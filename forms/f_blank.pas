unit f_blank;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ComCtrls,
  Vcl.ExtCtrls, System.UITypes,
  //����� ������ ������ ������..
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
    procedure SetValue(Sender: TObject);                                        //���������� ���������..

  private
    Data: TCLSBlank;

    procedure LoadData;                                                         //��������� ������ � ����..
    function  Save: Boolean;                                                    //���������� ������..

  public
      constructor Create(Owner: TComponent; Sender: TCLSBlank); reintroduce;

  end;

var
  FBlank: TFBlank;

implementation

uses DateUtils;
{$R *.dfm}
//�����������..
constructor TFBlank.Create(Owner: TComponent; Sender: TCLSBlank);
begin
    inherited Create(Owner);                                                    //����� ������������ TForm..

    Data := Sender;
end;

procedure TFBlank.FormActivate(Sender: TObject);
begin
    LoadData;                                                                   //������� ������ � ����..
end;

procedure TFBlank.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
    if(Self.ModalResult <> mrOk) then
      begin
          //�������� ���� ��������� ������..
          if(Data.isModify) then CanClose := (MessageDlg('������ �� ���������! �� ������������� ������ �������?', mtConfirmation, mbYesNoCancel, 0) = idYes);
          Exit
      end;

    //��������� ������..
    CanClose := Save;
end;

//���������� ���������..
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
            //��� ������ �������� ����..
            if(Date_reg.Date > Date()  ) then raise Exception.Create('���� ������ ��������� �������!');
            if(Date_reg.Date = TDate(0)) then raise Exception.Create('������������� ���� ������!');
            if(Date_reg.Date < (Date() - 10)) then raise Exception.Create('���� ������ �� ������ ���� ����� 10 ���� �� �������!');

            //��� ���������� �������� - ������� ������..
            Data.DateReg := Date_reg.Date;
          except on E: Exception do
            begin
                Date_reg.Date := Data.DateReg;                                  //����� �������..
                Date_reg.SetFocus;                                              //����� ����� �� ����..
                if(not(E.Message.IsEmpty)) then ShowMessage(E.Message);
            end;
          end;
          Exit;
      end;
end;

//��������� ������ � ����..
procedure TFBlank.LoadData;
begin
    if(Data.id = 0)
      then Self.Caption := '����������� �������..'
      else Self.Caption := '�������������� �������..';

    Ed_name.Text  := Data.Name;
    Date_reg.Date := Data.DateReg;
end;

//���������� ������..
function TFBlank.Save: Boolean;
begin
    result := True;
    //���� ��� ��������� - ������ �������..
    if(not(Data.isModify)) then Exit;

    try
      Data.Save;                                                                //������� ���������..
    except on E: Exception do
      begin
          result := False;
          ShowMessage(E.Message);
      end;
    end;
end;


end.
