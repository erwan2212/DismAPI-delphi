object Form1: TForm1
  Left = 451
  Top = 206
  Width = 1054
  Height = 519
  Caption = 'TinyDISM'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 120
  TextHeight = 16
  object GroupBox1: TGroupBox
    Left = 10
    Top = 10
    Width = 434
    Height = 159
    Caption = 'Mount'
    TabOrder = 0
    object Label1: TLabel
      Left = 10
      Top = 59
      Width = 34
      Height = 16
      Caption = 'folder'
    end
    object Label2: TLabel
      Left = 10
      Top = 30
      Width = 98
      Height = 16
      Caption = 'image (wim/vhd)'
    end
    object txtimage: TEdit
      Left = 118
      Top = 30
      Width = 277
      Height = 21
      TabOrder = 0
      Text = 'C:\_QuickPE\x86\iso\sources\boot.wim'
    end
    object txtfolder: TEdit
      Left = 118
      Top = 59
      Width = 277
      Height = 21
      TabOrder = 1
      Text = 'c:\mount'
    end
    object mount: TButton
      Left = 118
      Top = 89
      Width = 92
      Height = 21
      Caption = 'mount'
      TabOrder = 2
      OnClick = mountClick
    end
    object Button3: TButton
      Left = 303
      Top = 89
      Width = 92
      Height = 21
      Caption = 'unmount'
      TabOrder = 3
      OnClick = Button3Click
    end
    object Button2: TButton
      Left = 217
      Top = 89
      Width = 80
      Height = 21
      Caption = 'DismCleanupMountPoints'
      TabOrder = 4
      Visible = False
      OnClick = Button2Click
    end
    object chkdiscard: TCheckBox
      Left = 305
      Top = 111
      Width = 100
      Height = 21
      Caption = 'Discard'
      TabOrder = 5
    end
    object Button12: TButton
      Left = 118
      Top = 118
      Width = 90
      Height = 21
      Caption = 'GetImageInfo'
      TabOrder = 6
      OnClick = Button12Click
    end
    object Button13: TButton
      Left = 404
      Top = 30
      Width = 21
      Height = 20
      Caption = '.'
      TabOrder = 7
      OnClick = Button13Click
    end
  end
  object GroupBox2: TGroupBox
    Left = 10
    Top = 167
    Width = 434
    Height = 297
    Caption = 'Session'
    TabOrder = 1
    object Label5: TLabel
      Left = 20
      Top = 49
      Width = 34
      Height = 16
      Caption = 'folder'
    end
    object Label3: TLabel
      Left = 20
      Top = 118
      Width = 55
      Height = 16
      Caption = 'Package'
    end
    object Label4: TLabel
      Left = 20
      Top = 177
      Width = 36
      Height = 16
      Caption = 'Driver'
    end
    object Label6: TLabel
      Left = 20
      Top = 236
      Width = 60
      Height = 16
      Caption = 'Capability'
    end
    object txtfolder2: TEdit
      Left = 118
      Top = 49
      Width = 277
      Height = 21
      TabOrder = 0
      Text = 'c:\mount'
    end
    object txtpackage: TEdit
      Left = 118
      Top = 118
      Width = 277
      Height = 21
      TabOrder = 1
      Text = 'c:\winpe-wmi.cab'
    end
    object txtdriver: TEdit
      Left = 118
      Top = 177
      Width = 277
      Height = 21
      TabOrder = 2
      Text = 'C:\Drivers\usb.inf'
    end
    object Button7: TButton
      Left = 303
      Top = 207
      Width = 92
      Height = 21
      Caption = 'AddDriver'
      TabOrder = 3
      OnClick = Button7Click
    end
    object Button6: TButton
      Left = 303
      Top = 148
      Width = 92
      Height = 21
      Caption = 'AddPackage'
      TabOrder = 4
      OnClick = Button6Click
    end
    object Button4: TButton
      Left = 116
      Top = 79
      Width = 92
      Height = 21
      Caption = 'OpenSession'
      TabOrder = 5
      OnClick = Button4Click
    end
    object Button5: TButton
      Left = 303
      Top = 79
      Width = 92
      Height = 21
      Caption = 'CloseSession'
      TabOrder = 6
      OnClick = Button5Click
    end
    object txtcapability: TEdit
      Left = 118
      Top = 236
      Width = 277
      Height = 21
      TabOrder = 7
      Text = 'Language.Basic~~~en-US~0.0.1.0'
    end
    object Button1: TButton
      Left = 305
      Top = 266
      Width = 90
      Height = 21
      Caption = 'AddCapability'
      TabOrder = 8
      OnClick = Button1Click
    end
    object Button8: TButton
      Left = -226
      Top = 384
      Width = 92
      Height = 21
      Caption = 'Button8'
      TabOrder = 9
    end
    object Button9: TButton
      Left = 121
      Top = 151
      Width = 89
      Height = 21
      Caption = 'GetPackages'
      TabOrder = 10
      OnClick = Button9Click
    end
    object Button10: TButton
      Left = 116
      Top = 210
      Width = 90
      Height = 21
      Caption = 'GetDrivers'
      TabOrder = 11
      OnClick = Button10Click
    end
    object Button11: TButton
      Left = 118
      Top = 266
      Width = 100
      Height = 21
      Caption = 'GetFeatures'
      TabOrder = 12
      OnClick = Button11Click
    end
    object Button14: TButton
      Left = 404
      Top = 118
      Width = 21
      Height = 21
      Caption = '.'
      TabOrder = 13
      OnClick = Button14Click
    end
    object Button15: TButton
      Left = 404
      Top = 177
      Width = 21
      Height = 21
      Caption = '.'
      TabOrder = 14
      OnClick = Button15Click
    end
  end
  object GroupBox3: TGroupBox
    Left = 473
    Top = 10
    Width = 552
    Height = 454
    Caption = 'Log'
    TabOrder = 2
    object Memo1: TMemo
      Left = 2
      Top = 18
      Width = 548
      Height = 434
      Align = alClient
      TabOrder = 0
    end
  end
  object OpenDialog1: TOpenDialog
    Left = 352
    Top = 88
  end
end
