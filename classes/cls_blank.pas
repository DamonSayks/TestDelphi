unit cls_blank;

interface

uses  System.SysUtils, System.Classes,
      cls_var;                                                                  //����� ����������

type
    TCLSBlank = class
      private
        //��������� ������..
          FId      : TCLSV_int64;                                               //������������� �������
          FDateReg : TCLSV_date;                                                //���� ������
          FCartnum : TCLSV_int64;                                               //��� �������� (����� �����)
          FName    : TCLSV_str;                                                 //������������ �������

        //�������..
          //function read Value           //procedure write Value
          function  GetID    : int64;       procedure SetID(   Value: int64);
          function  GetDateR : TDate;       procedure SetDateR(Value: TDate);
          function  GetCard  : int64;       procedure SetCard( Value: int64);
          function  GetName  : string;      procedure SetName( Value: string);
          function  GetMod   : Boolean;
          function  GetNull  : Boolean;

          procedure InsetData;                                                  //������� ������ � ��
          procedure UpdateData;                                                 //��������� ������ � ��

          //������������ ������ �����������..
          function SetParam(itsModify: Boolean; name_field: string; sql_param: string): string;

      public
          constructor Create;
          destructor  Free;

        //������������ ����������..
          property id       : int64   read GetID    write SetID;
          property DateReg  : TDate   read GetDateR write SetDateR;
          property Cartnum  : int64   read GetCard  write SetCard;
          property Name     : string  read GetName  write SetName;
          property isModify : Boolean read GetMod;
          property isNull   : Boolean read GetNull;

        //�������..
          procedure Clear;                                                      //������� ������..
          procedure Reset;                                                      //����� ������..
          procedure Update;                                                     //���������� ������..

          //������ � ��..
          procedure Load(Value: int64);                                         //�������� ������
          procedure Save;                                                       //���������� ������
          procedure Delete(Value: int64);                                       //�������� ������

          procedure New(Owner: TComponent; CodePat: int64);                     //������� ����� �������
          procedure Open(Owner: TComponent; SendId: int64);                     //������������� �������

    end;

implementation

uses  FireDAC.Comp.Client,                                                      //��� ���������� TFDQuery (DataSet)
      FireDAC.Stan.Param,
      Data.DB,
      cls_sql,                                                                  //����� �����������..
      f_blank;                                                                  //����� �������������� ������..

{$region '�����������/���������� ������'}
constructor TCLSBlank.Create;
begin
    //�������������� ������..
    FId      := nil;
    FDateReg := nil;
    FCartnum := nil;
    FName    := nil;

    try
      FId      := TCLSV_int64.Create;
      FDateReg := TCLSV_date.Create;
      FCartnum := TCLSV_int64.Create;
      FName    := TCLSV_str.Create;

      //�� ��������� ������ ��� �������� ����������� �������, �� � ������ ������ ���� ����� ������������ �������, � �� TDate(0)
      Clear;
    except on E: Exception do raise Exception.Create(E.Message);
    end;
end;

destructor TCLSBlank.Free;
begin
    //������� ������..
    if(FId      <> nil) then FId.Free;
    if(FDateReg <> nil) then FDateReg.Free;
    if(FCartnum <> nil) then FCartnum.Free;
    if(FName    <> nil) then FName.Free;
end;
{$endregion}

{$region '������������ ����������'}
function TCLSBlank.GetID: int64;
begin
    result := FId.Value;
end;

procedure TCLSBlank.SetID(Value: int64);
begin
    FId.Value := Value;
end;

function TCLSBlank.GetCard: int64;
begin
    result := FCartnum.Value;
end;

procedure TCLSBlank.SetCard(Value: int64);
begin
    FCartnum.Value := Value;
end;

function TCLSBlank.GetName: string;
begin
    result := FName.Value;
end;

procedure TCLSBlank.SetName(Value: string);
begin
    FName.Value := Value;
end;

function TCLSBlank.GetDateR: TDate;
begin
    result := FDateReg.Value;
end;

procedure TCLSBlank.SetDateR(Value: TDate);
begin
    FDateReg.Value := Value;
end;

function TCLSBlank.GetMod : Boolean;
begin
    result := False;
    //�������� ���� ��������� ������..
    if(FId      <> nil) then result := (result OR FId.isModify);
    if(FDateReg <> nil) then result := (result OR FDateReg.isModify);
    if(FCartnum <> nil) then result := (result OR FCartnum.isModify);
    if(FName    <> nil) then result := (result OR FName.isModify);
end;

function TCLSBlank.GetNull: Boolean;
begin
    result := True;
    //�������� ���� ������ ������
//    if(FId      <> nil) then result := (result AND FId.isNull);               //� ������ �������� - ������!
    if(FDateReg <> nil) then result := (result AND FDateReg.isNull);
    if(FCartnum <> nil) then result := (result AND FCartnum.isNull);
    if(FName    <> nil) then result := (result AND FName.isNull);
end;
{$endregion}

{$region '������ � �������'}
//������� ������..
procedure TCLSBlank.Clear;
begin
    //������� ������..
    if(FId      <> nil) then FId.Clear;
    if(FDateReg <> nil) then FDateReg.Send(Date());                             //����� ���������� ������� ����, � �� ������� (��� ��������)
    if(FCartnum <> nil) then FCartnum.Clear;
    if(FName    <> nil) then FName.Clear;
end;

//����� ������..
procedure TCLSBlank.Reset;
begin
    //������� ������..
    if(FId      <> nil) then FId.Reset;
    if(FDateReg <> nil) then FDateReg.Reset;
    if(FCartnum <> nil) then FCartnum.Reset;
    if(FName    <> nil) then FName.Reset;
end;

//���������� ������..
procedure TCLSBlank.Update;
begin
    //�������� ������..
    if(FId      <> nil) then FId.Update;
    if(FDateReg <> nil) then FDateReg.Update;
    if(FCartnum <> nil) then FCartnum.Update;
    if(FName    <> nil) then FName.Update;
end;
{$endregion}

{$region '������ � ��'}
//�������� ������
procedure TCLSBlank.Load(Value: int64);
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

      Query.SQL.Text := 'SELECT * FROM mis.blank WHERE id = :SENDKEY';
      //��������� �����������..
      Query.ParamByName('SENDKEY').Value := Value;

      SQL.SetConnection(Connect, Transact, Query);                                  //��������� ���������..
      Transact.StartTransaction;                                                //������ ����������..

      //�������� �������..
      Query.Open;
      //�������� ������� ������..
      if(Query.IsEmpty) then raise Exception.Create('��� ������ �� ������ - ' + IntToStr(Value));

      //��������� ������..
      FId.Send(Value);
      FDateReg.Send(Query.FieldByName('date_reg').AsDateTime);
      FCartnum.Send(Query.FieldByName('cartnum' ).AsLargeInt);
      FName.Send(   Query.FieldByName('name'    ).AsString);
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
procedure TCLSBlank.Save;
begin
    //�� ��������� ����� ��� ���������..
    if(not(Self.isModify)) then Exit;

    //� ����������� �� ������� ������ ����� ��������� ����������� ������ ��� ��������� ����������..
    if(Self.id > 0)
      then UpdateData
      else InsetData;

    Self.Update;                                                                //�������� ���������..
end;

//�������� ������ �� ��
procedure TCLSBlank.Delete(Value: int64);
var
    SQL      : TCLSSQL;                                                         //����� �����������
    Query    : TFDQuery;                                                        //DataSet
    err_txt  : string;                                                          //������ �������
begin
    SQL   := nil;
    Query := nil;

    if(Value <= 0) then raise Exception.Create('����������� ����� �������!');

    err_txt := '';
    try
      SQL   := TCLSSQL.Create;                                                  //������ ����� �����������..
      Query := TFDQuery.Create(nil);

      Query.SQL.Text := 'DELETE FROM mis.blank WHERE id = :SENDKEY';
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
procedure TCLSBlank.InsetData;
var
    SQL      : TCLSSQL;                                                         //����� �����������
    Query    : TFDQuery;                                                        //DataSet
    err_txt  : string;                                                          //������ �������
begin
    SQL   := nil;
    Query := nil;

    //��������, ��� ������ �� ������ (����� Cartnum � Middlename, �� ����� ����)..
    if(Self.isNull) then raise Exception.Create('������ ������ �������: �� ������� ����������� ������!');

    err_txt := '';
    try
      SQL   := TCLSSQL.Create;                                                  //������ ����� �����������..
      Query := TFDQuery.Create(nil);

      Query.SQL.Text := 'INSERT INTO mis.blank(date_reg, cartnum, name) VALUES(:SENDDATEREG, :SENDCARTNUM, :SENDNAME) RETURNING id';
      //��������� �����������..
      Query.ParamByName('SENDCARTNUM').Value  := FCartnum.Value;
      Query.ParamByName('SENDDATEREG').AsDate := FDateReg.Value;
      Query.ParamByName('SENDNAME'   ).Value  := FName.Value;

      //�������� �������..
      FId.Send(SQL.QuickOpenGetInt64(Query));                                   //������� cartnum ������������������� ��������..
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
procedure TCLSBlank.UpdateData;
var
    SQL      : TCLSSQL;                                                         //����� �����������
    Query    : TFDQuery;                                                        //DataSet
    err_txt  : string;                                                          //������ �������
    sql_param: string;                                                          //������ �����������..
begin
    SQL   := nil;
    Query := nil;

    if(FCartnum.isNull) then raise Exception.Create('������ ����������: ����������� ����� �������!');

    err_txt := '';
    try
      SQL   := TCLSSQL.Create;                                                  //������ ����� �����������..
      Query := TFDQuery.Create(nil);

      //��������� ������ �� ������, ������� ����������..
      sql_param := SetParam(   FName.isModify,     'name', sql_param);
      sql_param := SetParam(FDateReg.isModify, 'date_reg', sql_param);

      Query.SQL.Text := ('UPDATE mis.blank SET ' + sql_param + ' WHERE id = :SENDKEY');
      //��������� �����������..
      Query.ParamByName('SENDKEY').Value := FId.Value;
      //���� �������..
      if(   FName.isModify) then Query.ParamByName('SENDNAME'    ).Value := FName.Value;
      if(FDateReg.isModify) then Query.ParamByName('SENDDATE_REG').Value := FDateReg.Value;

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
function TCLSBlank.SetParam(itsModify: Boolean; name_field: string; sql_param: string): string;
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
//������� ����� �������
procedure TCLSBlank.New(Owner: TComponent; CodePat: int64);
var pForm   : TFBlank;
    err_txt : string;
begin
    Clear;
    pForm := nil;

    err_txt := '';
    try
      FCartnum.Value := CodePat;

      pForm := TFBlank.Create(Owner, Self);
      pForm.ShowModal;
    except on E: Exception do err_txt := E.Message;
    end;
    //������� ������..
    if(pForm <> nil) then pForm.Free;

    if(not(err_txt.IsEmpty)) then raise Exception.Create(err_txt);
end;

//������������� �������
procedure TCLSBlank.Open(Owner: TComponent; SendId: int64);
var pForm   : TFBlank;
    err_txt : string;
begin
    pForm := nil;

    err_txt := '';
    try
      Load(SendId);                                                             //�������� ������..
      //������� �����..
      pForm := TFBlank.Create(Owner, Self);
      pForm.ShowModal;
    except on E: Exception do err_txt := E.Message;
    end;
    //������� ������..
    if(pForm <> nil) then pForm.Free;

    if(not(err_txt.IsEmpty)) then raise Exception.Create(err_txt);
end;
{$endregion}

end.
