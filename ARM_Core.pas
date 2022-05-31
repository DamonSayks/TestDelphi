unit ARM_Core;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus;

type
  TARMCore = class(TForm)
    MainMenu1: TMainMenu;
    M_arm: TMenuItem;
    M_arm_oper: TMenuItem;
    M_arm_stat: TMenuItem;
    M_setting: TMenuItem;
    M_set_bd: TMenuItem;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure MenuClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);

  private
      procedure CheckAccess;                                                    //�������� ����������� ���������..

  public
    { Public declarations }
  end;

var
  ARMCore: TARMCore;

implementation

uses
  cls_sql, f_db_setting, ARM_Oper, ARM_Stat, f_sel_arm;                         //Unit'� ������� � �������� ����..

{$R *.dfm}

procedure TARMCore.FormActivate(Sender: TObject);
begin
    if(Self.Tag <= 0) then Exit;

    //��������� ��������� ��� ����� ��������� ����....
    if(Self.Tag = 20) then M_arm_oper.Click;
    if(Self.Tag = 21) then M_arm_stat.Click;

    //����������..
    Self.Tag := 0;
end;

procedure TARMCore.FormCreate(Sender: TObject);
var SelArm: TFSelArm;
begin
    CheckAccess;
    //���� ��� ����� ������������ - ������� ���� �������� �����������..
    if(not(M_arm.Enabled)) then  M_set_bd.Click;
    //����� ��������� ������� ���..
    if(not(M_arm.Enabled)) then  Exit;

    SelArm := nil;
    try
      SelArm   := TFSelArm.Create(Self);
      Self.Tag := SelArm.ShowModal;                                               //������� ���������..

    except on E: Exception do ShowMessage(E.Message);
    end;
    //������� ������..
    if(SelArm <> nil) then SelArm.Free;
end;


procedure TARMCore.FormDestroy(Sender: TObject);
var
    I: integer;
begin
    //���������� ��� �������� MDI ����..
    for I := (Self.MDIChildCount - 1) downto 0 do Self.MDIChildren[I].Destroy;
end;

//������� ������� ����..
procedure TARMCore.MenuClick(Sender: TObject);
  var
    Oper: TARMOper;
    Stat: TARMStat;
    DB:   TFSettingDB;

begin
    //����������� ����������..
    if(Sender is TMenuItem) then
      case (Sender as TMenuItem).Tag of
          0:  //��������� ����������� � ��..
              begin
                DB := nil;
                try
                  DB := TFSettingDB.Create(Self);
                  DB.ShowModal;
                except on E: Exception do ShowMessage(E.Message);
                end;
                if(DB <> nil) then DB.Free;
                //���������� ����������� � ��..
                CheckAccess;
              end;
          1:  //������� ARM "��������"..
              begin
                Oper := nil;
                try
                  Oper := TARMOper.Create(Self);
                  Oper.Show;
                except on E: Exception do
                  begin
                      ShowMessage(E.Message);
                      Oper.Free;
                  end;
                end;
              end;
          2:  //������� ARM "�������"..
              begin
                Stat := nil;
                try
                  Stat := TARMStat.Create(Self);
                  Stat.Show;
                except on E: Exception do
                  begin
                      ShowMessage(E.Message);
                      Stat.Free;
                  end;
                end;
              end;
      end;
end;

{$region '��������� �������'}
//�������� ����������� ���������..
procedure TARMCore.CheckAccess;
  var
    SQL:  TCLSSQL;                                                              //����� ��������..
    chk:  Boolean;
begin
    chk := False;
    SQL := nil;
    try
      SQL := TCLSSQL.Create(Self);                                              //������ ������� ��� �����������..
      chk := SQL.CheckConnect;                                                  //��������� ����������� � ��..
    except
      SQL.Free;
    end;

    if(chk = False) then ShowMessage('����������� ����������� � ��!');
    //����������� ����������� ������������ ���������..
    M_arm.Enabled := chk;
end;
{$endregion}

end.
