unit cls_modul_find;

interface

uses
  System.SysUtils, System.Variants, System.Classes, Vcl.Dialogs, Vcl.Controls, Vcl.Forms,
  //����� ������ ������ ���������..
  fr_patient_find;

type
  TClsMODFind = class
    private
      FR: TFrPatientFind;                                                       //����� ������..

    public
        constructor Create(Owner: TComponent);
        destructor  Free;

        procedure ModOper;                                                      //������ ���������..
        procedure ModStat;                                                      //������ ��������..

        procedure Initial;                                                      //������������� ������ ������..
  end;

implementation

{$region '�����������/���������� ������'}
constructor TClsMODFind.Create(Owner: TComponent);
begin
    try
      FR := TFrPatientFind.Create(Owner);                                       //������ �����..
      FR.Parent := (Owner as TWinControl);                                      //����� �������� ������..
    except on E: Exception do
      begin
          FR.Free;
          FR := nil;
          //�������� ���������� ����..
          raise Exception.Create(E.Message);
      end;
    end;
end;

destructor TClsMODFind.Free;
begin
    if(FR <> nil) then FR.Free;
end;
{$endregion}

{$region '����� ������'}
//������ ���������..
procedure TClsMODFind.ModOper;
begin
    if(FR = nil) then Exit;

    FR.Tag := 1;
    FR.P_moditem.Visible    := True;
    FR.GrBox_filter.Visible := False;
    FR.P_top_blanks.Visible := True;
    FR.P_top.Height := 34;
end;
//������ ��������..
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

//������������� ������ ������..
procedure TClsMODFind.Initial;
begin
    if(FR = nil) then Exit;
    //�������� �������� ������..
    FR.LoadData;
end;

end.
