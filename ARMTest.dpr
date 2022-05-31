program ARMTest;

uses
  Vcl.Forms,
  ARM_Core in 'ARM_Core.pas' {ARMCore},
  cls_patient in 'classes\cls_patient.pas',
  arm_oper in 'forms\arm_oper.pas' {ARMOper},
  arm_stat in 'forms\arm_stat.pas' {ARMStat},
  fr_patient_find in 'frames\fr_patient_find.pas' {FrPatientFind: TFrame},
  cls_sql in 'classes\cls_sql.pas',
  f_db_setting in 'forms\f_db_setting.pas' {FSettingDB},
  cls_modul_find in 'classes\cls_modul_find.pas',
  pat_edit in 'forms\pat_edit.pas' {FEditPat},
  cls_var in 'classes\cls_var.pas',
  f_blank in 'forms\f_blank.pas' {FBlank},
  cls_blank in 'classes\cls_blank.pas',
  f_sel_arm in 'forms\f_sel_arm.pas' {FSelArm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'ARM Test';
  Application.CreateForm(TARMCore, ARMCore);
  Application.Run;
end.
