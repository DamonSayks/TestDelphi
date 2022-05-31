unit cls_patient;

interface

uses  System.SysUtils, System.Classes,
      cls_var;                                                                  //����� ����������

type
    TCLSPat = class
      private
        //��������� ������..
          FCartnum   : TCLSV_int64;                                             //��� �������� (����� �����)
          FSurname   : TCLSV_str;                                               //�������
          FName      : TCLSV_str;                                               //���
          FMiddlename: TCLSV_str;                                               //��������
          FAge       : TCLSV_date;                                              //���� ��������
          FSex       : TCLSV_int;                                               //���

        //�������..
          //function read Value           //procedure write Value
          function  GetCard: int64;       procedure SetCard(Value: int64);
          function  GetFam : string;      procedure SetFam( Value: string);
          function  GetName: string;      procedure SetName(Value: string);
          function  GetMidl: string;      procedure SetMidl(Value: string);
          function  GetAge : TDate;       procedure SetAge( Value: TDate);
          function  GetSex : integer;     procedure SetSex( Value: integer);
          function  GetMod : Boolean;
          function  GetNull: Boolean;

          procedure InsetData;                                                  //������� ������ � ��
          procedure UpdateData;                                                 //��������� ������ � ��

          //������������ ������ �����������..
          function SetParam(itsModify: Boolean; name_field: string; sql_param: string): string;

      public
          constructor Create;
          destructor  Free;

        //������������ ����������..
          property Cartnum   : int64   read GetCard write SetCard;
          property Surname   : string  read GetFam  write SetFam;
          property Name      : string  read GetName write SetName;
          property Middlename: string  read GetMidl write SetMidl;
          property Age       : TDate   read GetAge  write SetAge;
          property Sex       : integer read GetSex  write SetSex;
          property isModify  : Boolean read GetMod;
          property isNull    : Boolean read GetNull;

        //�������..
          procedure Clear;                                                      //������� ������..
          procedure Reset;                                                      //����� ������..
          procedure Update;                                                     //���������� ������..

          //������ � ��..
          procedure Load(Value: int64);                                         //�������� ������
          procedure Save;                                                       //���������� ������
          procedure Delete(Value: int64);                                       //�������� ������

          procedure New(Owner: TComponent);                                     //���������������� ��������..
          procedure Open(Owner: TComponent; SendId: int64);                     //������������� ��������..

    end;

implementation

uses  FireDAC.Comp.Client,                                                      //��� ���������� TFDQuery (DataSet)
      FireDAC.Stan.Param,
      Data.DB,
      cls_sql,                                                                  //����� �����������..
      pat_edit;                                                                 //����� ������ ��������

{$region '�����������/���������� ������'}
constructor TCLSPat.Create;
begin
    //�������������� ������..
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

      //�� ��������� ������ ��� �������� ����������� �������, �� � ������ ������ ���� ����� ������������ �������, � �� TDate(0)
      Clear;
    except on E: Exception do raise Exception.Create(E.Message);
    end;
end;

destructor TCLSPat.Free;
begin
    //������� ������..
    if(FCartnum    <> nil) then FCartnum.Free;
    if(FSurname    <> nil) then FSurname.Free;
    if(FName       <> nil) then FName.Free;
    if(FMiddlename <> nil) then FMiddlename.Free;
    if(FAge        <> nil) then FAge.Free;
    if(FSex        <> nil) then FSex.Free;
end;
{$endregion}

{$region '������������ ����������'}
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
    //�������� ���� ��������� ������..
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
    //�������� ���� ������ ������
//    if(FCartnum    <> nil) then result := (result AND FCartnum.isNull);        //����� ���� ������� (�� ������ ��� �����������)
//    if(FMiddlename <> nil) then result := (result AND FMiddlename.isNull);     //����� ���� �������
    if(FSurname <> nil) then result := (result AND FSurname.isNull);
    if(FName    <> nil) then result := (result AND FName.isNull);
    if(FAge     <> nil) then result := (result AND FAge.isNull);
    if(FSex     <> nil) then result := (result AND FSex.isNull);
end;
{$endregion}

{$region '������ � �������'}
//������� ������..
procedure TCLSPat.Clear;
begin
    //������� ������..
    if(FCartnum    <> nil) then FCartnum.Clear;
    if(FSurname    <> nil) then FSurname.Clear;
    if(FName       <> nil) then FName.Clear;
    if(FMiddlename <> nil) then FMiddlename.Clear;
    if(FAge        <> nil) then FAge.Send(Date());                              //����� ���������� ������� ����, � �� ������� (��� ��������)
    if(FSex        <> nil) then FSex.Clear;
end;

//����� ������..
procedure TCLSPat.Reset;
begin
    //������� ������..
    if(FCartnum    <> nil) then FCartnum.Reset;
    if(FSurname    <> nil) then FSurname.Reset;
    if(FName       <> nil) then FName.Reset;
    if(FMiddlename <> nil) then FMiddlename.Reset;
    if(FAge        <> nil) then FAge.Reset;
    if(FSex        <> nil) then FSex.Reset;
end;

//���������� ������..
procedure TCLSPat.Update;
begin
    //�������� ������..
    if(FCartnum    <> nil) then FCartnum.Update;
    if(FSurname    <> nil) then FSurname.Update;
    if(FName       <> nil) then FName.Update;
    if(FMiddlename <> nil) then FMiddlename.Update;
    if(FAge        <> nil) then FAge.Update;
    if(FSex        <> nil) then FSex.Update;
end;
{$endregion}

{$region '������ � ��'}
//�������� ������
procedure TCLSPat.Load(Value: int64);
var
    SQL    : TCLSSQL;                                                           //����� �����������
    //���������� �����������..
    Connect : TFDConnection;                                                    //�����������
    Transact: TFDTransaction;                                                   //����������
    Query   : TFDQuery;                                                         //DataSet
    err_txt: string;                                                            //������ �������
begin
    SQL := nil;

    Connect  := nil;
    Transact := nil;
    Query    := nil;

    Clear;                                                                      //������� ������..
    //�������� �� ������� ��������������..
    if(Value <= 0) then Exit;

    err_txt := '';
    try
      SQL := TCLSSQL.Create;                                                    //������ ����� �����������..

      Connect  := TFDConnection.Create(nil);                                    //������� �����������..
      Transact := TFDTransaction.Create(nil);                                   //������ ����������..
      Query    := TFDQuery.Create(nil);

      Query.SQL.Text := 'SELECT * FROM mis.patient WHERE cartnum = :SENDKEY';
      //��������� �����������..
      Query.ParamByName('SENDKEY').Value := Value;

      SQL.SetConnection(Connect, Transact, Query);                                  //��������� ���������..
      Transact.StartTransaction;                                                //������ ����������..

      //�������� �������..
      Query.Open;
      //�������� ������� ������..
      if(Query.IsEmpty) then raise Exception.Create('��� ������ �� ����� - ' + IntToStr(Value));

      //��������� ������..
      FCartnum.Send(   Query.FieldByName('cartnum'   ).AsLargeInt);
      FSurname.Send(   Query.FieldByName('surname'   ).AsString);
      FName.Send(      Query.FieldByName('name'      ).AsString);
      FMiddlename.Send(Query.FieldByName('middlename').AsString);
      FAge.Send(       Query.FieldByName('age'       ).AsDateTime);
      FSex.Send(       Query.FieldByName('sex'       ).AsInteger);
    except on E: Exception do err_txt := E.Message;
    end;
    //������� ������..
    if(SQL <> nil) then
      begin
          SQL.CloseConnect(Connect, Transact, Query);
          SQL.Free;
      end;

    //����� ������, ���� ��������..
    if(not(err_txt.IsEmpty)) then raise Exception.Create(err_txt);
end;

//���������� ������
procedure TCLSPat.Save;
begin
    //�� ��������� ����� ��� ���������..
    if(not(Self.isModify)) then Exit;

    //� ����������� �� ������� ������ ����� ��������� ����������� ������ ��� ��������� ����������..
    if(Self.Cartnum > 0)
      then UpdateData
      else InsetData;

    Self.Update;                                                                //�������� ���������..
end;

//�������� ������ �� ��
procedure TCLSPat.Delete(Value: int64);
var
    SQL      : TCLSSQL;                                                         //����� �����������
    Query    : TFDQuery;                                                        //DataSet
    err_txt  : string;                                                          //������ �������
begin
    SQL   := nil;
    Query := nil;

    if(Value <= 0) then raise Exception.Create('����������� ����� �����!');

    err_txt := '';
    try
      SQL   := TCLSSQL.Create;                                                  //������ ����� �����������..
      Query := TFDQuery.Create(nil);

      //��� ������ �������� ������� �������� ������� � ��������..
      Query.SQL.Text := 'SELECT (COUNT(*) > 0) mis.blank WHERE cartnum = :SENDKEY';
      //��������� �����������..
      Query.ParamByName('SENDKEY').Value := Value;

      //�������� �������..
      if(SQL.QuickOpenGetBool(Query)) then raise Exception.Create('� �������� ���� �������� �������, ��� ������ ����� ������� ��!');

      Query.SQL.Text := 'DELETE FROM mis.patient WHERE cartnum = :SENDKEY';
      //��������� �����������..
      Query.ParamByName('SENDKEY').Value := Value;

      SQL.QuickExec(Query);                                                     //�������� �������..
      //������� ������..
      Clear;
    except on E: Exception do err_txt := E.Message;
    end;
    //������� ������..
    if(SQL <> nil) then
      begin
          SQL.CloseConnect(Query);                                              //��������� DataSet � �������..
          SQL.Free;
      end;

    //����� ������, ���� ��������..
    if(not(err_txt.IsEmpty)) then raise Exception.Create('������ ��������: ' + err_txt);
end;

{$region '��������� �������'}
//������� ������ � ��
procedure TCLSPat.InsetData;
var
    SQL      : TCLSSQL;                                                         //����� �����������
    Query    : TFDQuery;                                                        //DataSet
    err_txt  : string;                                                          //������ �������
    sql_field: string;                                                          //������ �����..
    sql_param: string;                                                          //������ �����������..
begin
    SQL   := nil;
    Query := nil;

    //��������, ��� ������ �� ������ (����� Cartnum � Middlename, �� ����� ����)..
    if(Self.isNull) then raise Exception.Create('������ �����������: �� ������� ����������� ������!');

    err_txt := '';
    try
      SQL   := TCLSSQL.Create;                                                  //������ ����� �����������..
      Query := TFDQuery.Create(nil);

      sql_field := 'surname, name, age, sex';
      sql_param := ':SENDSURNAME, :SENDNAME, :SENDAGE, :SENDSEX';
      if(not(FMiddlename.isNull)) then
        begin
            //���� ������� ��������, �� ������� � ���.. ����� ��� ����� NULL
            sql_field := (sql_field + ', middlename');
            sql_param := (sql_param + ', :SENDMIDDLE');
        end;

      Query.SQL.Text := 'INSERT INTO mis.patient(' + sql_field + ') VALUES(' + sql_param + ') RETURNING cartnum';
      //��������� �����������..
      Query.ParamByName('SENDSURNAME').Value  := FSurname.Value;
      Query.ParamByName('SENDNAME'   ).Value  := FName.Value;
      Query.ParamByName('SENDAGE'    ).AsDate := FAge.Value;
      Query.ParamByName('SENDSEX'    ).Value  := FSex.Value;
      //������� � ��������, ���� ����..
      if(not(FMiddlename.isNull)) then Query.ParamByName('SENDMIDDLE').Value := FMiddlename.Value;

      //�������� �������..
      FCartnum.Send(SQL.QuickOpenGetInt64(Query));                              //������� cartnum ������������������� ��������..
    except on E: Exception do err_txt := E.Message;
    end;
    //������� ������..
    if(SQL <> nil) then
      begin
          SQL.CloseConnect(Query);                                              //��������� DataSet � �������..
          SQL.Free;
      end;

    //����� ������, ���� ��������..
    if(not(err_txt.IsEmpty)) then raise Exception.Create(err_txt);
end;

//��������� ������ � ��
procedure TCLSPat.UpdateData;
var
    SQL      : TCLSSQL;                                                         //����� �����������
    Query    : TFDQuery;                                                        //DataSet
    err_txt  : string;                                                          //������ �������
    sql_param: string;                                                          //������ �����������..
begin
    SQL   := nil;
    Query := nil;

    if(FCartnum.isNull) then raise Exception.Create('������ ����������: ����������� ����� �����!');

    err_txt := '';
    try
      SQL   := TCLSSQL.Create;                                                  //������ ����� �����������..
      Query := TFDQuery.Create(nil);

      //��������� ������ �� ������, ������� ����������..
      sql_param := SetParam(   FSurname.isModify,    'surname', sql_param);
      sql_param := SetParam(      FName.isModify,       'name', sql_param);
      sql_param := SetParam(FMiddlename.isModify, 'middlename', sql_param);
      sql_param := SetParam(       FAge.isModify,        'age', sql_param);
      sql_param := SetParam(       FSex.isModify,        'sex', sql_param);

      Query.SQL.Text := ('UPDATE mis.patient SET ' + sql_param + ' WHERE cartnum = :SENDKEY');
      //��������� �����������..
      Query.ParamByName('SENDKEY').Value := FCartnum.Value;
      //���� �������..
      if(   FSurname.isModify) then Query.ParamByName('SENDSURNAME').Value := FSurname.Value;
      if(      FName.isModify) then Query.ParamByName('SENDNAME'   ).Value := FName.Value;
      if(FMiddlename.isModify) then Query.ParamByName('SENDMIDDLE' ).Value := FMiddlename.Value;
      if(       FAge.isModify) then Query.ParamByName('SENDAGE'    ).Value := FAge.Value;
      if(       FSex.isModify) then Query.ParamByName('SENDSEX'    ).Value := FSex.Value;

      SQL.QuickExec(Query);                                                     //�������� �������..
    except on E: Exception do err_txt := E.Message;
    end;
    //������� ������..
    if(SQL <> nil) then
      begin
          SQL.CloseConnect(Query);                                              //��������� DataSet � �������..
          SQL.Free;
      end;

    //����� ������, ���� ��������..
    if(not(err_txt.IsEmpty)) then raise Exception.Create(err_txt);
end;

//������������ ������ �����������..
function TCLSPat.SetParam(itsModify: Boolean; name_field: string; sql_param: string): string;
begin
    result := sql_param;
    //���� ��� ��������� - �� ��������� � �������..
    if(not(itsModify)) then Exit;

    if(not(sql_param.IsEmpty)) then result := (sql_param + ', ');               //���� ������ �� ������ - ������� ����������� (', ')..
    //����������� ����� - # 'id = :ID'
    result := (sql_param + name_field + ' = :' + name_field.UpperCase(name_field));
end;
{$endregion}

{$endregion}

{$region '������ � ������'}
//���������������� ��������..
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
    //������� ������..
    if(pForm <> nil) then pForm.Free;

    if(not(err_txt.IsEmpty)) then raise Exception.Create(err_txt);
end;

//������������� ��������..
procedure TCLSPat.Open(Owner: TComponent; SendId: int64);
var pForm   : TFEditPat;
    err_txt : string;
begin
    pForm := nil;

    err_txt := '';
    try
      Load(SendId);                                                             //�������� ������..
      //������� �����..
      pForm := TFEditPat.Create(Owner, Self);
      pForm.ShowModal;
    except on E: Exception do err_txt := E.Message;
    end;
    //������� ������..
    if(pForm <> nil) then pForm.Free;

    if(not(err_txt.IsEmpty)) then raise Exception.Create(err_txt);
end;
{$endregion}


end.
