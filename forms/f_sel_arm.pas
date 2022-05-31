unit f_sel_arm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, System.UITypes;

type
  TFSelArm = class(TForm)
    Bt_oper: TBitBtn;
    Bt_stat: TBitBtn;

    procedure Select(Sender: TObject);                                          //����� ���'�..
    procedure SelectMouseEnter(Sender: TObject);
    procedure SelectMouseExit(Sender: TObject);

  private
    //������������ ������..
    procedure VisualFocus(Sender: TObject; F: Boolean);
  public
    { Public declarations }
  end;

var
  FSelArm: TFSelArm;

implementation

{$R *.dfm}
//����� ���'�..
procedure TFSelArm.Select(Sender: TObject);
begin
    ModalResult := (Sender as TBitBtn).Tag;
end;

procedure TFSelArm.SelectMouseEnter(Sender: TObject);
begin
    VisualFocus(Sender, True);
end;

procedure TFSelArm.SelectMouseExit(Sender: TObject);
begin
    VisualFocus(Sender, False);
end;

//������������ ������..
procedure TFSelArm.VisualFocus(Sender: TObject; F: Boolean);
begin
    if(not(Sender is TBitBtn)) then Exit;
    //������� ����� � ���� ������ ������ ��� ��������� �������..
    if(F) then
      begin
          (Sender as TBitBtn).Font.Style := ((Sender as TBitBtn).Font.Style + [fsBold]);
          (Sender as TBitBtn).Font.Color :=  clHotLight;
      end
    else
      begin
          (Sender as TBitBtn).Font.Style := ((Sender as TBitBtn).Font.Style - [fsBold]);
          (Sender as TBitBtn).Font.Color :=  clWindowText;
      end;
end;

end.
