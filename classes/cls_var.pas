unit cls_var;

interface

uses System.SysUtils, System.Variants, System.Classes;

type
    //����� ������ integer..
    TCLSV_int = class
      private
        FOld: integer;                                                          //������ ��������
        FNew: integer;                                                          //����� ��������

        function  GetValue: integer;
        procedure SetValue(SendValue: integer);
        function  GetMod : Boolean;
        function  GetNull: Boolean;

      public
          constructor Create;

        //�����..
          property Value    : integer read GetValue write SetValue;             //�������� ����������
          property isModify : Boolean read GetMod;                              //���� ���������
          property isNull   : Boolean read GetNull;                             //�������� �� ������ ��������

          procedure Clear;                                                      //������� ������
          procedure Send(SendValue: integer);                                   //�������� �������� � �����
          procedure Reset;                                                      //����� ���������
          procedure Update;                                                     //���������� ���������
    end;

    //����� ������ int64..
    TCLSV_int64 = class
      private
        FOld: int64;                                                            //������ ��������
        FNew: int64;                                                            //����� ��������

        function  GetValue: int64;
        procedure SetValue(SendValue: int64);
        function  GetMod: Boolean;
        function  GetNull: Boolean;

      public
          constructor Create;

        //�����..
          property Value    : int64   read GetValue write SetValue;             //�������� ����������
          property isModify : Boolean read GetMod;                              //���� ���������
          property isNull   : Boolean read GetNull;                             //�������� �� ������ ��������

          procedure Clear;                                                      //������� ������
          procedure Send(SendValue: int64);                                     //�������� �������� � �����
          procedure Reset;                                                      //����� ���������
          procedure Update;                                                     //���������� ���������
    end;

    //����� ������ string..
    TCLSV_str = class
      private
        FOld: string;                                                           //������ ��������
        FNew: string;                                                           //����� ��������

        function  GetValue: string;
        procedure SetValue(SendValue: string);
        function  GetMod: Boolean;
        function  GetNull: Boolean;

      public
          constructor Create;

        //�����..
          property Value    : string  read GetValue write SetValue;             //�������� ����������
          property isModify : Boolean read GetMod;                              //���� ���������
          property isNull   : Boolean read GetNull;                             //�������� �� ������ ��������

          procedure Clear;                                                      //������� ������
          procedure Send(SendValue: string);                                    //�������� �������� � �����
          procedure Reset;                                                      //����� ���������
          procedure Update;                                                     //���������� ���������
    end;

    //����� ������ TDate..
    TCLSV_date = class
      private
        FOld: TDate;                                                            //������ ��������
        FNew: TDate;                                                            //����� ��������

        function  GetValue: TDate;
        procedure SetValue(SendValue: TDate);
        function  GetMod: Boolean;
        function  GetNull: Boolean;

      public
          constructor Create;

        //�����..
          property Value    : TDate   read GetValue write SetValue;             //�������� ����������
          property isModify : Boolean read GetMod;                              //���� ���������
          property isNull   : Boolean read GetNull;                             //�������� �� ������ ��������

          procedure Clear;                                                      //������� ������
          procedure Send(SendValue: TDate);                                     //�������� �������� � �����
          procedure Reset;                                                      //����� ���������
          procedure Update;                                                     //���������� ���������

    end;

implementation

{$region '����� ���� ������ integer'}

constructor TCLSV_int.Create;
begin
    Clear;
end;

{$region '������������ ����������'}
function TCLSV_int.GetValue: integer;
begin
    result := FNew;                                                             //���������� ���������(�����)
end;

procedure TCLSV_int.SetValue(SendValue: integer);
begin
    FNew := SendValue;                                                          //������������� ����������(������)
end;

function TCLSV_int.GetMod: Boolean;
begin
    result := (FOld <> FNew);                                                   //���������� ���� ��������� ������ � ����������..
end;

function TCLSV_int.GetNull: Boolean;
begin
    result := (FNew = 0);                                                       //���������� ���� �������� ��������..
end;
{$endregion}

//������� ������
procedure TCLSV_int.Clear;
begin
    FOld := 0;
    FNew := 0;
end;

//�������� �������� � �����
procedure TCLSV_int.Send(SendValue: integer);
begin
    //�������� ���������� � ��� ����������..
    FOld := SendValue;
    FNew := SendValue;
end;

//����� ���������
procedure TCLSV_int.Reset;
begin
    FNew := FOld;
end;

//���������� ���������
procedure TCLSV_int.Update;
begin
    FOld := FNew;
end;

{$endregion}

{$region '����� ���� ������ int64'}

constructor TCLSV_int64.Create;
begin
    Clear;
end;

{$region '������������ ����������'}
function TCLSV_int64.GetValue: int64;
begin
    result := FNew;                                                             //���������� ���������(�����)
end;

procedure TCLSV_int64.SetValue(SendValue: int64);
begin
    FNew := SendValue;                                                          //������������� ����������(������)
end;

function TCLSV_int64.GetMod: Boolean;
begin
    result := (FOld <> FNew);                                                   //���������� ���� ��������� ������ � ����������..
end;

function TCLSV_int64.GetNull: Boolean;
begin
    result := (FNew = 0);                                                       //���������� ���� �������� ��������..
end;
{$endregion}

//������� ������
procedure TCLSV_int64.Clear;
begin
    FOld := 0;
    FNew := 0;
end;

//�������� �������� � �����
procedure TCLSV_int64.Send(SendValue: int64);
begin
    //�������� ���������� � ��� ����������..
    FOld := SendValue;
    FNew := SendValue;
end;

//����� ���������
procedure TCLSV_int64.Reset;
begin
    FNew := FOld;
end;

//���������� ���������
procedure TCLSV_int64.Update;
begin
    FOld := FNew;
end;

{$endregion}

{$region '����� ���� ������ string'}

constructor TCLSV_str.Create;
begin
    Clear;
end;

{$region '������������ ����������'}
function TCLSV_str.GetValue: string;
begin
    result := FNew;                                                             //���������� ���������(�����)
end;

procedure TCLSV_str.SetValue(SendValue: string);
begin
    FNew := SendValue;                                                          //������������� ����������(������)
end;

function TCLSV_str.GetMod: Boolean;
begin
    result := (FOld <> FNew);                                                   //���������� ���� ��������� ������ � ����������..
end;

function TCLSV_str.GetNull: Boolean;
begin
    result := FNew.IsEmpty;                                                     //���������� ���� �������� ��������..
end;
{$endregion}

//������� ������
procedure TCLSV_str.Clear;
begin
    FOld := '';
    FNew := '';
end;

//�������� �������� � �����
procedure TCLSV_str.Send(SendValue: string);
begin
    //�������� ���������� � ��� ����������..
    FOld := SendValue;
    FNew := SendValue;
end;

//����� ���������
procedure TCLSV_str.Reset;
begin
    FNew := FOld;
end;

//���������� ���������
procedure TCLSV_str.Update;
begin
    FOld := FNew;
end;

{$endregion}

{$region '����� ���� ������ TDate'}

constructor TCLSV_date.Create;
begin
    Clear;
end;

{$region '������������ ����������'}
function TCLSV_date.GetValue: TDate;
begin
    result := FNew;                                                             //���������� ���������(�����)
end;

procedure TCLSV_date.SetValue(SendValue: TDate);
begin
    FNew := SendValue;                                                          //������������� ����������(������)
end;

function TCLSV_date.GetMod: Boolean;
begin
    result := (FOld <> FNew);                                                   //���������� ���� ��������� ������ � ����������..
end;

function TCLSV_date.GetNull: Boolean;
begin
    result := (FNew = TDate(0));                                                //���������� ���� �������� ��������..
end;
{$endregion}

//������� ������
procedure TCLSV_date.Clear;
begin
    FOld := TDate(0);
    FNew := TDate(0);
end;

//�������� �������� � �����
procedure TCLSV_date.Send(SendValue: TDate);
begin
    //�������� ���������� � ��� ����������..
    FOld := SendValue;
    FNew := SendValue;
end;

//����� ���������
procedure TCLSV_date.Reset;
begin
    FNew := FOld;
end;

//���������� ���������
procedure TCLSV_date.Update;
begin
    FOld := FNew;
end;

{$endregion}

end.
