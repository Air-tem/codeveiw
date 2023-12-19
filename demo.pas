/// пример кода с которым работаю. Большой продуктовый проект, с большим количеством легаси кода. 

unit suHKPSingle;

interface


uses
 ..........

const
  cStatusOhne            = 0;
  cStatusErstellt        = 1;
  cStatusGenehmigt       = 2;
  cStatusAbgelehnt       = 3;
 .............
  cZStatusAusGesundh     = 22;
  cZStatusAusFinanzG     = 23;
  cZStatusAusZeitG       = 24;

type
  tHKPSStatus  = cStatusOhne..cStatusZurueckgestellt;
  tHKPSZStatus = cZStatusOhne..cZStatusAusZeitG;

  tHKPSZStatusSet = set of tHKPSZStatus;

const
  cHKPSZStatusErstellt        = [cZStatusOhne..cZStatusKeineUmsetzung];
  cHKPSZStatusGenehmigt       = [cZStatusOhne, cZStatusTerminierung..cZStatusAbgelaufen];
  cHKPSZStatusAbgelehnt       = [cZStatusOhne, cZStatusVonPat..cZStatusVonGut];
  cHKPSZStatusUnrealisiert    = [cZStatusOhne, cZStatusAlternativ..cZStatusPatNichtInf];
  cHKPSZStatusZurueckgestellt = [cZStatusOhne, cZStatusAusGesundh..cZStatusAusZeitG];

  cHKPZusatzMapping: array[tHKPSStatus] of tHKPSZStatusSet = (
    [cZStatusOhne],
    cHKPSZStatusErstellt,
    cHKPSZStatusGenehmigt,
    cHKPSZStatusAbgelehnt,
    cHKPSZStatusUnrealisiert,
    cHKPSZStatusZurueckgestellt
    );

  cHKPStatusText: array[tHKPSStatus] of string = (
    '',
    'Erstellt',
    'Genehmigt',
    'Abgelehnt',
    'Unrealisiert',
    'Zurückgestellt'
    );

  cHKPStatusInPrivat: array[tHKPSStatus] of boolean = (
    True,
    True,
  ..........................
    True
    );

  cHKPZStatusText: array[tHKPSZStatus] of string = (
    '',
    'Prüfen',
    'Patient mitgegeben',
    'bei Krankenkasse',
    'bei Gutachter',
    'keine Umsetzung',
............................
    'gesundheitlich',
    'finanziell',
    'zeitlich'
    );

  cHKPZStatusInPrivat: array[tHKPSZStatus] of boolean = (
    True,
    True,
    True,
    False,
 ...............................................
    True,
    True,
    True,
    True,
    True,
    True
    );

const
 
  .................................................................
  cBetragBG                                   = 52;
  cBetragBGErbracht                           = 53;
  cBetragFremdlaborKV                         = 54;


type
 
  THKPSingleHolder = class(THelpRecHolder_Ersteller, ILaborPlanUpdate)
  private
    
    fBefundAbrString:         string;
    fTheraphieAbrString:      string;
    fVersand:                 Currency;
    fBonus:                   Currency;
    fLabFakt:                 Currency;
    fFrmlLabEigen:            Currency;
    fFrmlLabFremd:            Currency;
  ........................................................
    fAktualWert:              TDate;
    fVorErbracht:             Boolean;
    fZuschussFlag:            Boolean;
    fBeh_LZNR:                TStringList;
    fTerapyTotal:             integer; // 2-4
    fTerapyCurrent:           integer; // 1-4
    procedure setBefund(const Value: string);
    procedure setHKP(const Value: string);
    procedure setHKPIndex(const Value: integer);
    procedure setHKPFORMULAR_FOR_MIT(const Value: integer);
//    procedure setMitteilungsnummer(const Value: String);
    procedure setFormularAntragsnummer(const Value: String);
    procedure setKIM_STATUS(const Value: Integer);
    function GetKIM_STATUS: Integer;
    function getKIM_RespID: String;

    procedure setPrev_FormularAntragsnummer(const Value: String);
    procedure setValid(const Value: boolean);
    procedure setLaborBetrag(const Value: Currency);
    procedure setBezeichnung(const Value: string);   // Index zum eigenltlichen HKP
    procedure InitPrintHead;
    procedure InitPrintBody;
    procedure InitPrintFood(aLastPage: boolean);
 ...............................................................
    procedure setFrmlLabFremd(const Value: Currency);
    procedure setEdelmetallVers(const Value: boolean);
    procedure setFrmlMatKo(const Value: Currency);
    procedure setDirektAbr(const Value: boolean);
    procedure setUnfall(const Value: boolean);
  ..................................................................
    Function GetFormularAntragsnummer: String;
  protected
    //Interface für Basisinterface
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: integer; stdcall;
    function _Release: integer; stdcall;

    //Interface ILaborPlanUpdate
    function CanUpdate: boolean;
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure Update(const aLab: TLabHolderCustom);

    procedure DoDelete; override;
    procedure GetQueryData; override;
    procedure SetQueryData; override;
  public
    fFormBemerkung: String;
    constructor Create(aOwner: TSchnittstelle; aIndex: integer = 0); override;
    destructor Destroy; override;
    function Print: boolean;
   ..............................................................................
    function isBundesPolizei: boolean;
    function LaborBeschreibung(typ: tLabDatenbanken): string;

    function CanChange: Boolean;

    property DirektAbr: boolean Read fDirektAbr Write setDirektAbr;
    property TheraphiePlanAbr: string Read fTheraphieAbrString Write setTheraphieAbrString;
 .......................................................................................
    property ZuschussFlag: boolean read fZuschussFlag write fZuschussFlag;
    property Beh_LZNR: TStringList read fBeh_LZNR write SetBeh_LZNR;
    property TerapyTotal: integer Read fTerapyTotal Write setTerapyTotal;
    property TerapyCurrent: integer Read fTerapyCurrent Write setTerapyCurrent;

  end;

  THKPSingle = class(TTabellenSchnittstelle)
  private
    procedure ResetOtherHKPSingles(me: integer);
    procedure setLeistungenErbracht(i: integer; erb: boolean);
    function getHKPSingleItems(Index: integer): THKPSingleHolder;
    function getHKPSingleUnits(Index: integer): THKPSingleHolder;
    procedure HKPNeuNews(Sender: TObject; aEOItem: tExecuteOnItem; aIndexList: TIntegerList);
    function getChildren(Index: integer): TList;
  .....................................
    procedure setLeistungenAktiv(i: integer; a: boolean);
    function getErbrachteLeistungenOL(Index: integer): TList;
   ...................................
    function getGO96Leistungen(Index: integer): TList;
    function getBGLeistungen(Index: integer): TList;
  protected
    procedure SetSQLText(aQuery: TUniQuery; const aIndexList: string); override;
  public
   .......................
    property Kassenleistungen[Index: integer]: TList Read getKassenLeistungen;
    .....................................................................
    property ErbrachteLeistungenOL[Index: integer]: TList Read getErbrachteLeistungenOL;
    { Liefert zurück, ob EINE Leistung erbracht wurde }
    property IsLeistungErbracht[Index: integer]: boolean Read getIsLeistungErbracht;
    property Materialien[Index: integer]: TList Read getMaterialien;
  end;

var
  { Die (einzige?) Instanz der Schnittstelle }
  sHKPSingle: THKPSingle;

implementation

uses
 ...............................................

{ THKPSingleHolder }

{ Lädt die Daten aus der Datenbank.
}
procedure THKPSingleHolder.GetQueryData;
begin
  inherited;
  fCreated                 := Query.FieldByName(cCreatedField).AsDateTime;
  fPatientenID             := Query.FieldByName(cLsPatId).AsInteger;
  .......................
  fFromulardata            := Query.FieldByName(cHKPSingleFormular).AsString;
  fFromulardata07          := Query.FieldByName(cHKPSingleFormular07).AsString;
  fAbrechnerID             := Query.FieldByName(cArztField).AsInteger;
  fErstellungsdatum        := Query.FieldByName(cHKPSingleErstellt).AsDateTime;
  fAnsweredDatum           := Query.FieldByName(cHKPSinglefAnsweredDatum).AsDateTime;
end;

{ Speichert das Tupel in die Datenbank.
}
procedure THKPSingleHolder.SetQueryData;
begin
  inherited;
  SQLText.AddCol(cLsPatId, fPatientenID);
  SQLText.AddCol(cHKPSingleHKPIdx, fHKPIndex);
  SQLText.AddCol(cHKPSingleHKP_MIT_ID, fHKPFORMULAR_FOR_MIT);
 ......................................STATUS);
  SQLText.AddCol(cSendedDatum, fSendedDatum);
end;

procedure THKPSingleHolder.setBefund(const Value: string);
begin
  if (fBefund <> Value) then begin
    fBefund := Value;
    Invalidate;
  end;
end;
.........................................................................
}
procedure THKPSingle.SetSQLText(aQuery: TUniQuery; const aIndexList: string);

  
  function getHKPNeuSelectString: string;
  var
    n: integer;
  begin
    
    Result := ' where ' + cHKPSingleHKPIdx + ' in (0';
    if sHKPNeu.Count > 0 then
      Result := Result + ',';
    for n := 0 to sHKPNeu.Count - 1 do begin
      Result := Result + IntToStr(sHKPNeu.Items[n].Index);
      if (n <> sHKPNeu.Count - 1) then
        Result := Result + ',';
    end;
    Result := Result + ')';
  end;

var
  lStr: string;
begin
  if aIndexList = '' then
    lStr := ''
  else
    lStr := ' and nindex in ' + aIndexList;

  aQuery.SQL.Text := 'select ' + '* ' + 'from ' + cHKPSingleTableName + getHKPNeuSelectString + ' and ' + cLsPatId + '=' + IntToStr(sPatienten.MainIndex) + lStr;
end;

{ Konstruktor.
}
constructor THKPSingle.Create;
begin
  inherited Create(THKPSingleHolder, cHKPSingleTableName);
  fFastLoad := True;
  fListGleichArtig := TStringList.Create;
  sHKPNeu.AddEvent(HKPNeuNews);
end;

{ Destruktor.
}
destructor THKPSingle.Destroy;
begin
  fListGleichArtig.Free;
  sHKPNeu.RemoveEvent(HKPNeuNews);
  inherited;
}
end;
end.