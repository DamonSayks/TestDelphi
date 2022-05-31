unit cls_sql;

interface

uses
  System.SysUtils, System.Variants, System.Classes, Vcl.Dialogs,
  //��� ����������� FireDac..
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Stan.Pool, FireDAC.Phys,
  FireDAC.Phys.PG, FireDAC.Phys.PGDef, FireDAC.VCLUI.Wait, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TCLSSQL = class
    private
        PgDriv: TFDPhysPgDriverLink;                                            //������� PG

      //�������..
        procedure CreateDrive(Owner: TComponent);                               //������� ������� ����������� � PG..

        function GetConnectStr: string;                                         //�������� ������ �����������..
        function GetSQLText(index: integer): string;                            //�������� ������ �������� �������..

    public
      //����������..
        Srv:  string;
        Port: string;
        Name: string;
        Usr:  string;
        Pass: string;

        constructor Create;                     overload;
        constructor Create(Owner: TComponent);  overload;
        destructor  Free;

      //�������..
        //�����..
        function GetSetting : Boolean;                                          //��������� �������� �����������..
        function SetSetting : Boolean;                                          //���������� �������� �����������..
        function HasParamConnect: Boolean;                                      //���� ������� ����������� �����������..
        //�������� �����������..
        function CheckConnect(Owner: TComponent) : Boolean;  overload;
        function CheckConnect                    : Boolean;  overload;

        //��������� ����������� �����������..
        procedure SetConnection(Connect: TFDConnection; Transact: TFDTransaction; Query: TFDQuery);
        //�������� ����������� � ������� ������..
        procedure CloseConnect(Connect: TFDConnection; Transact: TFDTransaction; Query: TFDQuery);  overload;
        procedure CloseConnect(Connect:  TFDConnection);  overload;
        procedure CloseConnect(Transact: TFDTransaction); overload;
        procedure CloseConnect(Query:    TFDQuery);       overload;

        function CreateStructDB: Boolean;                                       //�������� ��������� �������..

      //���������� ������� � ��..
        //�������� Exec �������..
        procedure QuickExec(Owner: TComponent; TextQuery: string);  overload;
        procedure QuickExec(TextQuery: string);                     overload;
        procedure QuickExec(Query: TFDQuery);                       overload;
        //�������� Open ������� (SELECT)..
        function  QuickOpenGetBool(Query: TFDQuery): Boolean;
        function  QuickOpenGetInt64(Query: TFDQuery): int64;
        //�������� � ����������� �������..
        procedure QuickLoadToMemTable(MTab: TFDMemTable; TextQuery: string);
  end;

implementation

uses
  IniFiles;                                                                     //���������� INI �����..

{$region '�����������/���������� ������'}
//�����������..
constructor TCLSSQL.Create;
begin
    CreateDrive(nil);
end;

constructor TCLSSQL.Create(Owner: TComponent);
begin
    CreateDrive(Owner);
end;

//����������..
destructor TCLSSQL.Free;
begin
    //������� ������� ��� �����������, ���� ������..
    if(self.PgDriv = nil) then Exit;

    self.PgDriv.Free;
end;
{$endregion}

{$region '�����'}

{$region '����������/������ ����� ������������'}
//��������� ��������..
function TCLSSQL.GetSetting : Boolean;
var
    Ini: Tinifile;
begin
    //���� �������� � ���������� ���������..
    Ini := TiniFile.Create(GetCurrentDir + '\setting.ini');
    try
      Self.Srv  := Ini.ReadString('PG', 'Server', Self.Srv);
      Self.Port := Ini.ReadString('PG',   'Port', Self.Port);
      Self.Name := Ini.ReadString('PG',   'Name', Self.Name);
      Self.Usr  := Ini.ReadString('PG',   'User', Self.Usr);
      Self.Pass := Ini.ReadString('PG',   'Pass', Self.Pass);
    except on E: Exception do ShowMessage(E.Message);
    end;
    if(Ini <> nil) then Ini.Free;

    result := HasParamConnect;
end;

//���������� ��������..
function TCLSSQL.SetSetting : Boolean;
var
    Ini: Tinifile;
begin
    //���� �������� � ���������� ���������..
    Ini := TiniFile.Create(GetCurrentDir + '\setting.ini');
    try
      Ini.WriteString('PG', 'Server', Self.Srv);
      Ini.WriteString('PG',   'Port', Self.Port);
      Ini.WriteString('PG',   'Name', Self.Name);
      Ini.WriteString('PG',   'User', Self.Usr);
      Ini.WriteString('PG',   'Pass', Self.Pass);

      result := true;
    except on E: Exception do
      begin
          ShowMessage(E.Message);
          result := false;
      end;
    end;
    if(Ini <> nil) then Ini.Free;
end;

//���� ������� ����������� �����������..
function TCLSSQL.HasParamConnect: Boolean;
begin
    result := not(Self.Name.IsEmpty OR Self.Usr.IsEmpty OR Self.Pass.IsEmpty OR Self.Srv.IsEmpty);
end;
{$endregion}

{$region '�������� �����������'}
//�������� �����������
function TCLSSQL.CheckConnect(Owner: TComponent): Boolean;
var
    Connect:  TFDConnection;
begin
    result := False;
    //��������� ������� ��� �����������..
    if(self.PgDriv = nil) then
      begin
          ShowMessage('������� ����������� �� ������!');
          Exit;
      end;

    //�������� ������� ��������..
    if(HasParamConnect = False) then
      begin
          //������� �������� ���������..
          if(Self.GetSetting = false) then
          begin
              ShowMessage('�� ��������� �����������!');
              Exit;
          end;
      end;

    //������� �����������..
    Connect := TFDConnection.Create(Owner);
    try
      Connect.ConnectionString := GetConnectStr;                                //������ ������ �����������..
      Connect.Connected        := true;                                         //���������..

      result := Connect.Connected;
    except on E: Exception do ShowMessage(E.Message);
    end;
    if(Connect <> nil) then Connect.Free;
end;

function TCLSSQL.CheckConnect: Boolean;
begin
    result := Self.CheckConnect(nil);
end;
{$endregion}

//��������� ����������� ��� �����������..
procedure TCLSSQL.SetConnection(Connect: TFDConnection; Transact: TFDTransaction; Query: TFDQuery);
begin
    //��������� ������..
    if(Connect  = nil) then raise Exception.Create('�� ������� ��������� �����������!');
    if(Transact = nil) then raise Exception.Create('�� ������� ��������� ����������!');
    if(Query    = nil) then raise Exception.Create('�� ������� ��������� DataSet!');

    //�����������..
    Connect.ConnectionString := GetConnectStr;                                  //�������� ������ �����������..
    Connect.Connected        := true;                                           //���������..
    Connect.Transaction      := Transact;                                       //��������� � ����������� ����������..
    Query.Connection         := Connect;                                        //��������� ����������� � DataSet'�..
end;

{$region '���������� ����������� � ������� ������'}
procedure TCLSSQL.CloseConnect(Connect: TFDConnection; Transact: TFDTransaction; Query: TFDQuery);
begin
    CloseConnect(Query);
    CloseConnect(Transact);
    CloseConnect(Connect);
end;

procedure TCLSSQL.CloseConnect(Connect: TFDConnection);
begin
    if(Connect <> nil) then
    begin
        //�������� �����������..
        if(Connect.Connected) then Connect.Close;
        Connect.Free;
    end;
end;

procedure TCLSSQL.CloseConnect(Transact: TFDTransaction);
begin
    if(Transact <> nil) then
    begin
        //���������� ����������..
        if(Transact.Active) then Transact.Commit;
        Transact.Free;
    end;
end;

procedure TCLSSQL.CloseConnect(Query: TFDQuery);
begin
    if(Query <> nil) then
    begin
        //�������� DataSet'�..
        if(Query.Active) then Query.Close();
        Query.Free;
    end;
end;
{$endregion}

{$region '��������/�������� ��������� ���� ������'}
//������� ��������� ���� ������..
function TCLSSQL.CreateStructDB: Boolean;
var
    S: integer;                                                                 //�������..
begin
    result := False;
    try
      for S := 1 to 5 do QuickExec(GetSQLText(S));
      //�� ���������� - �����!..
      result := True;
    except on E: Exception do ShowMessage(E.Message);
    end;
end;
{$endregion}

{$region '������� ��������/��������� ������'}
//�������� Exec �������..
procedure TCLSSQL.QuickExec(Owner: TComponent; TextQuery: string);
var
    //���������� �����������..
    Connect:  TFDConnection;
    Transact: TFDTransaction;
    Query:    TFDQuery;
    //����� ������..
    err:  string;
begin
    if(TextQuery.IsEmpty = True) then raise Exception.Create('������ ����� �������!');

    Connect  := nil;
    Transact := nil;
    Query    := nil;

    err := '';
    try
      Connect  := TFDConnection.Create(Owner);                                  //������� �����������..
      Transact := TFDTransaction.Create(Owner);                                 //������ ����������..
      Query    := TFDQuery.Create(Owner);                                       //������ DataSet..

      SetConnection(Connect, Transact, Query);                                  //��������� ���������..
      Transact.StartTransaction;                                                //������ ����������..

      Query.SQL.Text := TextQuery;                                              //��������� �������..
      Query.ExecSQL;                                                            //������ �������..

    except on E: Exception do
      begin
        if(Transact <> nil) then
        begin
            if(Transact.Active) then Transact.Rollback;                         //����� ����������..
        end;
        err := E.Message;
      end;
    end;
    //������� ������..
    CloseConnect(Connect, Transact, Query);

    //�������� ������, ���� ����..
    if(err.IsEmpty = False) then raise Exception.Create(err);
end;

procedure TCLSSQL.QuickExec(TextQuery: string);
begin
    QuickExec(nil, TextQuery);
end;

procedure TCLSSQL.QuickExec(Query: TFDQuery);
var
    //���������� �����������..
    Connect:  TFDConnection;
    Transact: TFDTransaction;
    //����� ������..
    err:  string;
begin
    if(Query = nil) then raise Exception.Create('�� ������� DataSet');

    Connect  := nil;
    Transact := nil;
    Query    := nil;

    err := '';
    try
      Connect  := TFDConnection.Create(nil);                                    //������� �����������..
      Transact := TFDTransaction.Create(nil);                                   //������ ����������..

      SetConnection(Connect, Transact, Query);                                  //��������� ���������..
      Transact.StartTransaction;                                                //������ ����������..

      Query.ExecSQL;                                                            //������ �������..
    except on E: Exception do
      begin
        if(Transact <> nil) then
        begin
            if(Transact.Active) then Transact.Rollback;                         //����� ����������..
        end;
        if(Query.Active) then Query.Close;                                      //��������� DataSet..
        err := E.Message;
      end;
    end;
    //������� ������..
    CloseConnect(Transact);
    CloseConnect(Connect);

    Query.Connection := nil;                                                    //�������� ������ �� �����������

    //�������� ������, ���� ����..
    if(err.IsEmpty = False) then raise Exception.Create(err);
end;

//�������� Open ������� (SELECT)..
function TCLSSQL.QuickOpenGetBool(Query: TFDQuery): Boolean;
var
    //���������� �����������..
    Connect:  TFDConnection;
    Transact: TFDTransaction;
    //����� ������..
    err:  string;
begin
    if(Query = nil) then raise Exception.Create('�� ������� DataSet');

    Connect  := nil;
    Transact := nil;

    result := False;
    err    := '';
    try
      Connect  := TFDConnection.Create(nil);                                    //������� �����������..
      Transact := TFDTransaction.Create(nil);                                   //������ ����������..

      SetConnection(Connect, Transact, Query);                                  //��������� ���������..
      Transact.StartTransaction;                                                //������ ����������..

      Query.Open;                                                               //������ �������..
      //��������� ������..
      if(not(Query.Fields.Fields[0].IsNull)) then result := Query.Fields.Fields[0].AsBoolean;

      Query.Close;                                                              //��������� DataSet..
    except on E: Exception do
      begin
        if(Transact <> nil) then
        begin
            if(Transact.Active) then Transact.Rollback;                         //����� ����������..
        end;
        if(Query.Active) then Query.Close;                                      //��������� DataSet..
        err := E.Message;
      end;
    end;
    //������� ������..
    CloseConnect(Transact);
    CloseConnect(Connect);

    Query.Connection := nil;                                                    //�������� ������ �� �����������

    //�������� ������, ���� ����..
    if(err.IsEmpty = False) then raise Exception.Create(err);
end;

function TCLSSQL.QuickOpenGetInt64(Query: TFDQuery): int64;
var
    //���������� �����������..
    Connect:  TFDConnection;
    Transact: TFDTransaction;
    //����� ������..
    err:  string;
begin
    if(Query = nil) then raise Exception.Create('�� ������� DataSet');

    Connect  := nil;
    Transact := nil;

    result := 0;
    err    := '';
    try
      Connect  := TFDConnection.Create(nil);                                    //������� �����������..
      Transact := TFDTransaction.Create(nil);                                   //������ ����������..

      SetConnection(Connect, Transact, Query);                                  //��������� ���������..
      Transact.StartTransaction;                                                //������ ����������..

      Query.Open;                                                               //������ �������..
      //��������� ������..
      if(not(Query.Fields.Fields[0].IsNull)) then result := Query.Fields.Fields[0].AsLargeInt;

      Query.Close;                                                              //��������� DataSet..
    except on E: Exception do
      begin
        if(Transact <> nil) then
        begin
            if(Transact.Active) then Transact.Rollback;                         //����� ����������..
        end;
        if(Query.Active) then Query.Close;                                      //��������� DataSet..
        err := E.Message;
      end;
    end;
    //������� ������..
    CloseConnect(Transact);
    CloseConnect(Connect);

    Query.Connection := nil;                                                    //�������� ������ �� �����������

    //�������� ������, ���� ����..
    if(err.IsEmpty = False) then raise Exception.Create(err);
end;

//�������� � ����������� �������..
procedure TCLSSQL.QuickLoadToMemTable(MTab: TFDMemTable; TextQuery: string);
var
    //���������� �����������..
    Connect:  TFDConnection;
    Transact: TFDTransaction;
    Query:    TFDQuery;
    //����� ������..
    err:  string;
begin
    if(TextQuery.IsEmpty = True) then raise Exception.Create('������ ����� �������!');
    if(MTab = nil) then raise Exception.Create('�� �������� ����������� �������!');

    Connect  := nil;
    Transact := nil;
    Query    := nil;

    err := '';
    try
      Connect  := TFDConnection.Create(nil);                                    //������� �����������..
      Transact := TFDTransaction.Create(nil);                                   //������ ����������..
      Query    := TFDQuery.Create(nil);                                         //������ DataSet..

      SetConnection(Connect, Transact, Query);                                  //��������� ���������..
      Transact.StartTransaction;                                                //������ ����������..

      Query.SQL.Text := TextQuery;                                              //��������� �������..
      Query.Open;                                                               //������ �������..

      if(MTab.ControlsDisabled) then MTab.EnableControls;
      if(MTab.Active) then MTab.Close;

//      MTab.EmptyDataSet;                                                        //������� ������ �� ����������� �������..
      MTab.CopyDataSet(Query, [coStructure, coRestart, coAppend]);              //�������� ������ � ����������� �������..
    except on E: Exception do
      begin
        if(Transact <> nil) then
        begin
            if(Transact.Active) then Transact.Rollback;                         //����� ����������..
        end;
        err := E.Message;
      end;
    end;
    //������� ������..
    CloseConnect(Connect, Transact, Query);

    //�������� ������, ���� ����..
    if(err.IsEmpty = False) then raise Exception.Create(err);
end;

{$endregion}

{$endregion}

{$region '��������� �������'}
//�������� � ��������� �������� �����������..
procedure TCLSSQL.CreateDrive(Owner: TComponent);
begin
    Self.Srv  := '';
    Self.Port := '';
    Self.Name := '';
    Self.Usr  := '';
    Self.Pass := '';

    PgDriv := TFDPhysPgDriverLink.Create(Owner);                                //������ ������� ��� �����������..
    try
      PgDriv.VendorLib := (GetCurrentDir + '\lib\libpq.dll');                   //���� � ���������� Postgres, ���� "libpq.dll"..
      //�������� �������� �����������..
      if(not(GetSetting)) then raise Exception.Create('�� ������� ��������� ��������� �����������!');

    except on E: Exception do
      begin
        PgDriv.Free;
        ShowMessage(E.Message);
      end;
    end;
end;

//�������� ������ �����������..
function TCLSSQL.GetConnectStr: string;
begin
    if(HasParamConnect = False) then
      begin
          result := '';
          Exit;
      end;

    result := ('Database='  + Self.Name +
              ';User_Name=' + Self.Usr  +
              ';Password='  + Self.Pass +
              ';Server='    + Self.Srv  +
              ';DriverID=PG');
end;

//�������� ������ �������� �������..
function TCLSSQL.GetSQLText(index: integer): string;
begin
    //� ����������� �� ����, �������� ������ ��� �������� ��� ��� ���� �������..
    //!!! ������� ��� PostgreSQL 14 ������ (� ������� ������ ����� 10-�)..

    case index of
        1:  //�������� �����..
            begin
                result := ('CREATE SCHEMA IF NOT EXISTS mis');
                Exit;
            end;
        2:  //������������������ ��� ������� ���������..
            begin
                result := ('CREATE SEQUENCE IF NOT EXISTS mis.patient_code AS BIGINT START 1');
                Exit;
            end;
        3:  //������� ���������..
            begin
                result := ('CREATE TABLE IF NOT EXISTS mis.patient('
                              +   'cartnum BIGINT PRIMARY KEY DEFAULT nextval(''mis.patient_code'')'  //��� �������� (����� �����)
                              + ', date_reg TIMESTAMP NOT NULL DEFAULT NOW()'                         //���� ����������� ��������
                              + ', surname VARCHAR NOT NULL'                                          //�������
                              + ', name VARCHAR NOT NULL'                                             //���
                              + ', middlename VARCHAR NULL'                                           //��������
                              + ', age DATE NOT NULL'                                                 //���� ��������
                              + ', sex INTEGER NOT NULL)');                                           //���
                Exit;
            end;
        4:  //������������������ ��� ������� �������..
            begin
                result := ('CREATE SEQUENCE IF NOT EXISTS mis.blank_id AS BIGINT START 1');
                Exit;
            end;
        5:  //������� �������..
            begin
                result := ('CREATE TABLE IF NOT EXISTS mis.blank('
                              +   'id BIGINT PRIMARY KEY DEFAULT nextval(''mis.blank_id'')' //�������������
                              + ', cartnum BIGINT NOT NULL'                                 //��� ��������
                              + ', date_reg TIMESTAMP NOT NULL DEFAULT NOW()'               //���� ����������� �������(���� ������)
                              + ', name VARCHAR NOT NULL)');                                //������������ �������
                Exit;
            end;
    end;
    result := '';
end;
{$endregion}

end.
