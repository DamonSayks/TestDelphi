unit pat_edit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls,
  Vcl.Buttons, System.UITypes,
  //����� ��������..
  cls_patient;

type
  TFEditPat = class(TForm)
    P_surname: TPanel;
    L_surname: TLabel;
    Ed_surname: TEdit;
    P_name: TPanel;
    L_name: TLabel;
    Ed_name: TEdit;
    P_midlename: TPanel;
    L_midlename: TLabel;
    Ed_midlename: TEdit;
    P_age: TPanel;
    Label1: TLabel;
    Date_age: TDateTimePicker;
    P_control: TPanel;
    Bt_cancel: TBitBtn;
    Bt_save: TBitBtn;
    RGr_sex: TRadioGroup;

    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormActivate(Sender: TObject);
    procedure SetValue(Sender: TObject);                                        //���������� ���������..

  private
    Data: TCLSPat;                                                              //����� �������..

    procedure LoadData;                                                         //��������� ������ � ����..
    function  Save: Boolean;                                                    //���������� ������..

  public
    constructor Create(Owner: TComponent; Sender: TCLSPat);  reintroduce;

  end;

var
  FEditPat: TFEditPat;

implementation

uses DateUtils;
{$R *.dfm}

constructor TFEditPat.Create(Owner: TComponent; Sender: TCLSPat);
begin
    inherited Create(Owner);                                                    //����� ������������ TForm..

    Data := Sender;
end;

procedure TFEditPat.FormActivate(Sender: TObject);
begin
    LoadData;                                                                   //������� ������ � ����..
end;

procedure TFEditPat.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
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
procedure TFEditPat.SetValue(Sender: TObject);
begin
    if(Sender = Ed_surname) then
      begin
          Data.Surname := Ed_surname.Text;
          Exit;
      end;
    if(Sender = Ed_name) then
      begin
          Data.Name := Ed_name.Text;
          Exit;
      end;
    if(Sender = Ed_midlename) then
      begin
          Data.Middlename := Ed_midlename.Text;
          //�������� ��������..
          if(Data.Middlename.IsEmpty) then Exit;

          if(Data.Middlename.Substring((Data.Middlename.Length - 3), 3) = '���') then
            begin
                RGr_sex.ItemIndex := 1;                                         //��� �������..
                Data.Sex := RGr_sex.ItemIndex;
            end;
          if(Data.Middlename.Substring((Data.Middlename.Length - 3), 3) = '���') then
            begin
                RGr_sex.ItemIndex := 0;                                         //��� �������..
                Data.Sex := RGr_sex.ItemIndex;
            end;
          Exit;
      end;
    if(Sender = RGr_sex) then
      begin
          Data.Sex := RGr_sex.ItemIndex;
          Exit;
      end;
    if(Sender = Date_age) then
      begin
          try
            //��� ������ �������� ����..
            if(Date_age.Date > Date()  ) then raise Exception.Create('���� �������� ��������� �������!');
            if(Date_age.Date = TDate(0)) then raise Exception.Create('������������� ���� ��������!');

            if((YearOf(Date()) - YearOf(Date_age.Date)) > 100) then
              begin
                  if(MessageDlg('������� �������� ������ ��� ���! �� �������?', mtConfirmation, mbYesNoCancel, 0) = idNo)
                    then raise Exception.Create('');
              end;

            //��� ���������� �������� - ������� ������..
            Data.Age := Date_age.Date;
          except on E: Exception do
            begin
                Date_age.Date := Data.Age;                                      //����� �������..
                Date_age.SetFocus;                                              //����� ����� �� ����..
                if(not(E.Message.IsEmpty)) then ShowMessage(E.Message);
            end;
          end;
          Exit;
      end;
end;

//��������� ������ � ����..
procedure TFEditPat.LoadData;
begin
    if(Data.Cartnum = 0)
      then Self.Caption := '����������� ��������..'
      else Self.Caption := '�������������� ������ ��������..';

    Ed_surname.Text   := Data.Surname;
    Ed_name.Text      := Data.Name;
    Ed_midlename.Text := Data.Middlename;
    Date_age.Date     := Data.Age;
    RGr_sex.ItemIndex := Data.Sex;
end;

//���������� ������..
function TFEditPat.Save: Boolean;
begin
    result := True;
    //���� ��� ��������� - ������ �������..
    if(not(Data.isModify)) then Exit;

    try
      Data.Save;                                                             //������� ���������..
    except on E: Exception do
      begin
          result := False;
          ShowMessage(E.Message);
      end;
    end;
end;

end.
